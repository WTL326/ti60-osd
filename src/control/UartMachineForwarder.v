`timescale 1ns / 1ps

// Machine-command UART forwarder.
//
// X2000 sends every command on UART_ST_FR.  Frames with the machine header
// (0xAA) belong to the machine and are forwarded byte-for-byte on
// UART_FPGA_RX after the complete frame has been received and validated.
// Mask frames (0xBB) are consumed by RtlMaskUartAxiWriter and are ignored
// here.  Machine reply frames (0x55) appear only on the return path and are
// passed through untouched in top.
//
// Machine frame format:
//   AA | body_len | payload[0..n-2] | checksum | EB | AA
// body_len counts the body bytes including the checksum byte (1..255).
// checksum = (AA + body_len + payload bytes) mod 256.
//
// Two ping-pong buffers hold the current frame while the previous one is
// still being re-serialized, so back-to-back frames are not lost.
module UartMachineForwarder #(
    parameter integer CLK_HZ = 100000000,
    parameter integer BAUD = 115200,
    parameter [7:0] MACHINE_HEADER = 8'hAA,
    parameter [7:0] TAIL_BYTE0 = 8'hEB,
    parameter [7:0] TAIL_BYTE1 = 8'hAA,
    parameter integer FRAME_TIMEOUT_US = 2000
) (
    input  wire        clk,
    input  wire        reset,
    input  wire        uart_rx,
    output wire        machine_tx,

    output reg  [15:0] good_frame_count,
    output reg  [15:0] bad_frame_count,
    output reg  [31:0] forwarded_bytes
);
    localparam integer CLKS_PER_BIT = CLK_HZ / BAUD;
    localparam integer MAX_BODY = 255;
    localparam integer BUF_DEPTH = MAX_BODY + 4;   // header+len+body+2 tail
    localparam [31:0] TIMEOUT_CLKS = FRAME_TIMEOUT_US * (CLK_HZ / 1000000);

    // ---------------------------------------------------------------
    // UART RX (8N1), same structure as the mask endpoint receiver.
    // ---------------------------------------------------------------
    reg [1:0]  rx_sync;
    reg        rx_last;
    reg        rx_busy;
    reg [15:0] rx_clock_count;
    reg [3:0]  rx_bit_index;
    reg [7:0]  rx_shift;
    reg [7:0]  rx_byte;
    reg        rx_byte_valid;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rx_sync <= 2'b11;
            rx_last <= 1'b1;
            rx_busy <= 1'b0;
            rx_clock_count <= 0;
            rx_bit_index <= 0;
            rx_shift <= 0;
            rx_byte <= 0;
            rx_byte_valid <= 1'b0;
        end else begin
            rx_sync <= {rx_sync[0], uart_rx};
            rx_last <= rx_sync[1];
            rx_byte_valid <= 1'b0;
            if (!rx_busy) begin
                if (rx_last && !rx_sync[1]) begin
                    rx_busy <= 1'b1;
                    rx_bit_index <= 0;
                    rx_clock_count <= CLKS_PER_BIT + (CLKS_PER_BIT/2) - 1;
                end
            end else if (rx_clock_count != 0) begin
                rx_clock_count <= rx_clock_count - 1'b1;
            end else if (rx_bit_index < 8) begin
                rx_shift[rx_bit_index] <= rx_sync[1];
                rx_bit_index <= rx_bit_index + 1'b1;
                rx_clock_count <= CLKS_PER_BIT - 1;
            end else begin
                rx_busy <= 1'b0;
                if (rx_sync[1]) begin
                    rx_byte <= rx_shift;
                    rx_byte_valid <= 1'b1;
                end
            end
        end
    end

    // ---------------------------------------------------------------
    // Frame parser with store-and-forward ping-pong buffers.
    // ---------------------------------------------------------------
    localparam [2:0] F_IDLE=3'd0, F_LEN=3'd1, F_BODY=3'd2,
                     F_TAIL0=3'd3, F_TAIL1=3'd4;
    reg [2:0]  f_state;
    reg [7:0]  body_len;
    reg [7:0]  body_index;
    reg [15:0] checksum;
    reg        checksum_ok;
    reg [8:0]  buf_index;
    reg        write_sel;
    reg        read_sel;
    // The two 259-byte ping-pong banks occupy the lower 259 addresses of each
    // 512-byte half of one Titanium RAM10.  Explicit instantiation avoids the
    // tool-dependent multidimensional dual-port RAM inference that otherwise
    // expands this storage into more than four thousand FFs.
    reg [8:0]  tx_mem_addr;
    wire [7:0] tx_mem_q;
    wire       frame_ram_we;
    wire [9:0] frame_ram_waddr;
    reg [31:0] idle_clks;
    reg        tx_req;
    reg [8:0]  dispatch_len;

    assign frame_ram_we = rx_byte_valid &&
        (((f_state == F_IDLE) && (rx_byte == MACHINE_HEADER)) ||
         (f_state == F_LEN) || (f_state == F_BODY) ||
         (f_state == F_TAIL0) || (f_state == F_TAIL1));
    assign frame_ram_waddr = {write_sel,
                              (f_state == F_IDLE) ? 9'd0 : buf_index};

    EFX_RAM10 #(
        .WRITE_WIDTH(8),
        .READ_WIDTH(8),
        .WRITE_MODE("READ_FIRST"),
        .OUTPUT_REG(1'b0),
        .RESET_RAM("NONE"),
        .RESET_OUTREG("NONE")
    ) u_frame_ram10 (
        .WCLK(clk),
        .WE({2{frame_ram_we}}),
        .WCLKE(1'b1),
        .WADDREN(1'b1),
        .WDATA(rx_byte),
        .WADDR(frame_ram_waddr),
        .RCLK(clk),
        .RE(1'b1),
        .RST(1'b0),
        .RADDREN(1'b1),
        .RDATA(tx_mem_q),
        .RADDR({read_sel, tx_mem_addr})
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            f_state <= F_IDLE;
            body_len <= 0;
            body_index <= 0;
            checksum <= 0;
            checksum_ok <= 0;
            buf_index <= 0;
            write_sel <= 0;
            read_sel <= 0;
            idle_clks <= 0;
            tx_req <= 0;
            dispatch_len <= 0;
            good_frame_count <= 0;
            bad_frame_count <= 0;
            forwarded_bytes <= 0;
        end else begin
            // req/ack handshake with the TX block: tx_req is owned by this
            // block, tx_ack by the TX block.
            if (tx_ack)
                tx_req <= 1'b0;
            if (f_state != F_IDLE) begin
                if (idle_clks >= TIMEOUT_CLKS) begin
                    f_state <= F_IDLE;
                    // A lone header byte (e.g. a 0xAA mask-footer or reply
                    // byte between frames) is not a committed frame.
                    if (f_state != F_LEN)
                        bad_frame_count <= bad_frame_count + 1'b1;
                end else begin
                    idle_clks <= idle_clks + 1'b1;
                end
            end
            if (rx_byte_valid) begin
                idle_clks <= 0;
                case (f_state)
                    F_IDLE: if (rx_byte == MACHINE_HEADER) begin
                        buf_index <= 1;
                        checksum <= {8'd0, MACHINE_HEADER};
                        f_state <= F_LEN;
                    end
                    F_LEN: begin
                        buf_index <= buf_index + 1'b1;
                        checksum <= checksum + {8'd0, rx_byte};
                        if (rx_byte == 8'h00) begin
                            f_state <= F_IDLE;
                            bad_frame_count <= bad_frame_count + 1'b1;
                        end else begin
                            // Every non-zero 8-bit body length is legal.
                            // In particular 0x55, 0xAA and 0xBB must not be
                            // confused with headers while in the length state.
                            body_len <= rx_byte;
                            body_index <= 0;
                            f_state <= F_BODY;
                        end
                    end
                    F_BODY: begin
                        buf_index <= buf_index + 1'b1;
                        if (body_index == body_len - 1'b1) begin
                            checksum_ok <= (rx_byte == checksum[7:0]);
                            f_state <= F_TAIL0;
                        end else begin
                            checksum <= checksum + {8'd0, rx_byte};
                            body_index <= body_index + 1'b1;
                        end
                    end
                    F_TAIL0: begin
                        buf_index <= buf_index + 1'b1;
                        if (rx_byte == TAIL_BYTE0)
                            f_state <= F_TAIL1;
                        else begin
                            f_state <= F_IDLE;
                            bad_frame_count <= bad_frame_count + 1'b1;
                        end
                    end
                    F_TAIL1: begin
                        if ((rx_byte == TAIL_BYTE1) && checksum_ok &&
                            !tx_req && !tx_busy) begin
                            tx_req <= 1'b1;
                            dispatch_len <= {1'b0, body_len} + 9'd4;
                            read_sel <= write_sel;
                            write_sel <= ~write_sel;
                            good_frame_count <= good_frame_count + 1'b1;
                            forwarded_bytes <= forwarded_bytes +
                                {23'd0, body_len} + 32'd4;
                        end else begin
                            bad_frame_count <= bad_frame_count + 1'b1;
                        end
                        f_state <= F_IDLE;
                    end
                    default: f_state <= F_IDLE;
                endcase
            end
        end
    end

    // ---------------------------------------------------------------
    // UART TX: replays the validated frame byte-for-byte to the machine.
    // ---------------------------------------------------------------
    reg        tx_busy;
    reg        tx_ack;
    reg [8:0]  tx_index;
    reg [3:0]  tx_bit_index;
    reg [15:0] tx_clock_count;
    reg [7:0]  tx_current_byte;
    reg        tx_line;
    reg [8:0]  tx_frame_len;
    reg [1:0]  tx_prefetch;

    assign machine_tx = tx_line;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_busy <= 1'b0;
            tx_ack <= 1'b0;
            tx_index <= 0;
            tx_bit_index <= 0;
            tx_clock_count <= 0;
            tx_current_byte <= 0;
            tx_line <= 1'b1;
            tx_frame_len <= 0;
            tx_mem_addr <= 0;
            tx_prefetch <= 0;
        end else begin
            tx_ack <= 1'b0;
            if (!tx_busy) begin
                tx_line <= 1'b1;
                if (tx_req) begin
                    tx_ack <= 1'b1;
                    tx_frame_len <= dispatch_len;
                    tx_index <= 0;
                    tx_mem_addr <= 0;
                    // One cycle presents address zero to the RAM and the
                    // second consumes its registered output.
                    tx_prefetch <= 2;
                    tx_busy <= 1'b1;
                end
            end else if (tx_prefetch != 0) begin
                tx_line <= 1'b1;
                if (tx_prefetch == 2) begin
                    tx_prefetch <= 1;
                end else begin
                    tx_current_byte <= tx_mem_q;
                    tx_bit_index <= 0;
                    tx_clock_count <= CLKS_PER_BIT - 1;
                    tx_line <= 1'b0;
                    tx_prefetch <= 0;
                end
            end else if (tx_clock_count != 0) begin
                tx_clock_count <= tx_clock_count - 1'b1;
            end else if (tx_bit_index < 8) begin
                tx_line <= tx_current_byte[tx_bit_index];
                tx_bit_index <= tx_bit_index + 1'b1;
                tx_clock_count <= CLKS_PER_BIT - 1;
            end else if (tx_bit_index == 8) begin
                tx_line <= 1'b1;
                tx_bit_index <= 9;
                tx_clock_count <= CLKS_PER_BIT - 1;
            end else if (tx_index == tx_frame_len - 1'b1) begin
                tx_busy <= 1'b0;
                tx_line <= 1'b1;
            end else begin
                tx_index <= tx_index + 1'b1;
                tx_mem_addr <= tx_index + 1'b1;
                tx_prefetch <= 2;
                tx_line <= 1'b1;
            end
        end
    end
endmodule
