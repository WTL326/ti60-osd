`timescale 1ns / 1ps

// Pure-RTL X2000 mask command endpoint.
//
// Packet format (CRC-16/CCITT over BODY):
//   BB | body_length[15:8] | body_length[7:0] |
//   06 | command | 00 | payload | crc[15:8] | crc[7:0] | AA
// Header is BB to separate mask commands from 0xAA machine frames, which
// UartMachineForwarder passes to the machine.  The footer stays AA.
//
// Commands:
//   86: width:u16, height:u16, total:u32
//   87: offset:u32, unpacked mask bytes
//   88: left_x:s16, top_y:s16
//   89: enable:u8
//
// Incoming 420x220 bytes are written directly to the inactive raw-mask
// buffer.  The video overlay samples buffer/position/enable at video SOF.
module RtlMaskUartAxiWriter #(
    parameter integer CLK_HZ = 100000000,
    parameter integer BAUD = 115200,
    parameter [31:0] MASK_A_BASE = 32'h00A0_0000,
    parameter [31:0] MASK_B_BASE = 32'h00B0_0000,
    parameter integer MASK_WIDTH = 420,
    parameter integer MASK_HEIGHT = 220
) (
    input  wire         clk,
    input  wire         reset,
    input  wire         enable,
    input  wire         uart_rx,
    output wire         uart_tx,

    output reg          mask_enable,
    output reg          active_buffer,
    output reg signed [15:0] mask_left,
    output reg signed [15:0] mask_top,

    output wire         avalid,
    input  wire         aready,
    output wire [31:0]  aaddr,
    output wire [7:0]   aid,
    output wire [7:0]   alen,
    output wire [2:0]   asize,
    output wire [1:0]   aburst,
    output wire [1:0]   alock,
    output wire         atype,
    output wire         wvalid,
    input  wire         wready,
    output wire [7:0]   wid,
    output wire [127:0] wdata,
    output wire [15:0]  wstrb,
    output wire         wlast,
    input  wire         bvalid,
    output wire         bready,
    input  wire [7:0]   bid,

    output reg [15:0]   good_packet_count,
    output reg [15:0]   bad_packet_count,
    output reg [31:0]   received_bytes,
    output reg [15:0]   axi_error_count,
    output wire         writer_active
);
    localparam integer CLKS_PER_BIT = CLK_HZ / BAUD;
    localparam integer MASK_BYTES = MASK_WIDTH * MASK_HEIGHT;

    function [15:0] crc16_byte;
        input [15:0] crc_in;
        input [7:0] data;
        integer n;
        reg [15:0] c;
        begin
            c = crc_in ^ {data,8'h00};
            for (n=0; n<8; n=n+1)
                c = c[15] ? ((c << 1) ^ 16'h1021) : (c << 1);
            crc16_byte = c;
        end
    endfunction

    // ---------------------------------------------------------------
    // UART receiver, 8-N-1.  One-cycle rx_byte_valid pulses are in clk.
    // ---------------------------------------------------------------
    reg [1:0] rx_sync;
    reg rx_last;
    reg rx_busy;
    reg [15:0] rx_clock_count;
    reg [3:0] rx_bit_index;
    reg [7:0] rx_shift;
    reg [7:0] rx_byte;
    reg rx_byte_valid;

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
            rx_sync <= {rx_sync[0],uart_rx};
            rx_last <= rx_sync[1];
            rx_byte_valid <= 1'b0;
            if (!enable) begin
                rx_busy <= 1'b0;
            end else if (!rx_busy) begin
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
    // One-byte AXI writes.  A 16-byte aligned beat with one WSTRB bit
    // set avoids any dependency on unaligned narrow-transfer handling.
    // ---------------------------------------------------------------
    localparam [1:0] AXI_IDLE=2'd0, AXI_ADDR=2'd1,
                     AXI_DATA=2'd2, AXI_RESP=2'd3;
    reg [1:0] axi_state;
    reg write_request;
    reg [31:0] write_address;
    reg [7:0] write_byte;
    reg [31:0] axi_address;
    reg [7:0] axi_byte;
    reg [3:0] axi_lane;

    assign writer_active = (axi_state != AXI_IDLE) || write_request;
    assign avalid = (axi_state == AXI_ADDR);
    assign aaddr = {axi_address[31:4],4'b0000};
    assign aid = 8'hB2;
    assign alen = 8'd0;
    assign asize = 3'd4;
    assign aburst = 2'b01;
    assign alock = 2'b00;
    assign atype = 1'b1;
    assign wvalid = (axi_state == AXI_DATA);
    assign wid = 8'hB2;
    assign wdata = {{120{1'b0}},axi_byte} << ({axi_lane,3'b000});
    assign wstrb = 16'h0001 << axi_lane;
    assign wlast = 1'b1;
    assign bready = (axi_state == AXI_RESP);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            axi_state <= AXI_IDLE;
            axi_address <= 0;
            axi_byte <= 0;
            axi_lane <= 0;
            axi_error_count <= 0;
        end else begin
            case (axi_state)
                AXI_IDLE: if (write_request) begin
                    axi_address <= write_address;
                    axi_byte <= write_byte;
                    axi_lane <= write_address[3:0];
                    axi_state <= AXI_ADDR;
                end
                AXI_ADDR: if (aready)
                    axi_state <= AXI_DATA;
                AXI_DATA: if (wready)
                    axi_state <= AXI_RESP;
                AXI_RESP: if (bvalid) begin
                    if (bid != 8'hB2)
                        axi_error_count <= axi_error_count + 1'b1;
                    axi_state <= AXI_IDLE;
                end
                default: axi_state <= AXI_IDLE;
            endcase
        end
    end

    // ---------------------------------------------------------------
    // Packet parser and command execution.
    // ---------------------------------------------------------------
    localparam [3:0] P_HEADER=4'd0, P_LEN_H=4'd1, P_LEN_L=4'd2,
                     P_BODY=4'd3, P_CRC_H=4'd4, P_CRC_L=4'd5,
                     P_FOOTER=4'd6;
    reg [3:0] parser_state;
    reg [15:0] body_length;
    reg [15:0] body_index;
    reg [15:0] body_crc;
    reg [15:0] received_crc;
    reg crc_ok;
    reg packet_error;
    reg [7:0] packet_command;
    reg [15:0] begin_width, begin_height;
    reg [31:0] begin_total;
    reg [31:0] chunk_offset;
    reg signed [15:0] command_left, command_top;
    reg command_enable;
    reg upload_active;
    reg mask_loaded;
    reg upload_buffer;
    reg ack_request;
    reg [7:0] ack_command;
    reg [7:0] ack_status;

    wire [31:0] upload_base = upload_buffer ? MASK_B_BASE : MASK_A_BASE;
    wire [15:0] payload_index = body_index - 16'd3;
    wire [31:0] chunk_data_index = payload_index - 16'd4;
    wire [31:0] chunk_length = (body_length >= 7) ? body_length-7 : 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            parser_state <= P_HEADER;
            body_length <= 0;
            body_index <= 0;
            body_crc <= 0;
            received_crc <= 0;
            crc_ok <= 0;
            packet_error <= 0;
            packet_command <= 0;
            begin_width <= 0;
            begin_height <= 0;
            begin_total <= 0;
            chunk_offset <= 0;
            command_left <= 0;
            command_top <= 0;
            command_enable <= 0;
            upload_active <= 0;
            mask_loaded <= 0;
            upload_buffer <= 1'b1;
            mask_enable <= 0;
            active_buffer <= 0;
            mask_left <= 0;
            mask_top <= 0;
            good_packet_count <= 0;
            bad_packet_count <= 0;
            received_bytes <= 0;
            write_request <= 0;
            write_address <= 0;
            write_byte <= 0;
            ack_request <= 0;
            ack_command <= 0;
            ack_status <= 0;
        end else begin
            ack_request <= 1'b0;
            if (write_request && (axi_state != AXI_IDLE))
                write_request <= 1'b0;

            if (!enable) begin
                parser_state <= P_HEADER;
                body_index <= 0;
                body_crc <= 0;
                packet_error <= 0;
            end else if (rx_byte_valid) begin
                case (parser_state)
                    P_HEADER: if (rx_byte == 8'hBB) begin
                        parser_state <= P_LEN_H;
                        packet_error <= 1'b0;
                        body_crc <= 0;
                        body_index <= 0;
                    end
                    P_LEN_H: begin
                        body_length[15:8] <= rx_byte;
                        parser_state <= P_LEN_L;
                    end
                    P_LEN_L: begin
                        body_length[7:0] <= rx_byte;
                        if ({body_length[15:8],rx_byte} < 3 ||
                            {body_length[15:8],rx_byte} >= 16'd5000) begin
                            parser_state <= P_HEADER;
                            bad_packet_count <= bad_packet_count + 1'b1;
                        end else begin
                            body_index <= 0;
                            parser_state <= P_BODY;
                        end
                    end
                    P_BODY: begin
                        body_crc <= crc16_byte(body_crc,rx_byte);
                        if (body_index == 0) begin
                            if (rx_byte != 8'h06)
                                packet_error <= 1'b1;
                        end else if (body_index == 1) begin
                            packet_command <= rx_byte;
                            if ((rx_byte < 8'h86) || (rx_byte > 8'h89))
                                packet_error <= 1'b1;
                        end else if (body_index == 2) begin
                            if (rx_byte != 8'h00)
                                packet_error <= 1'b1;
                        end else begin
                            case (packet_command)
                                8'h86: case (payload_index)
                                    0: begin_width[15:8] <= rx_byte;
                                    1: begin_width[7:0] <= rx_byte;
                                    2: begin_height[15:8] <= rx_byte;
                                    3: begin_height[7:0] <= rx_byte;
                                    4: begin_total[31:24] <= rx_byte;
                                    5: begin_total[23:16] <= rx_byte;
                                    6: begin_total[15:8] <= rx_byte;
                                    7: begin_total[7:0] <= rx_byte;
                                    default: packet_error <= 1'b1;
                                endcase
                                8'h87: begin
                                    case (payload_index)
                                        0: chunk_offset[31:24] <= rx_byte;
                                        1: chunk_offset[23:16] <= rx_byte;
                                        2: chunk_offset[15:8] <= rx_byte;
                                        3: begin
                                            chunk_offset[7:0] <= rx_byte;
                                            if ({chunk_offset[31:8],rx_byte} != received_bytes)
                                                packet_error <= 1'b1;
                                        end
                                        default: begin
                                            if (!upload_active || write_request ||
                                                (axi_state != AXI_IDLE) ||
                                                (chunk_offset + chunk_data_index >= MASK_BYTES)) begin
                                                packet_error <= 1'b1;
                                            end else begin
                                                write_address <= upload_base + chunk_offset + chunk_data_index;
                                                write_byte <= rx_byte;
                                                write_request <= 1'b1;
                                            end
                                        end
                                    endcase
                                end
                                8'h88: case (payload_index)
                                    0: command_left[15:8] <= rx_byte;
                                    1: command_left[7:0] <= rx_byte;
                                    2: command_top[15:8] <= rx_byte;
                                    3: command_top[7:0] <= rx_byte;
                                    default: packet_error <= 1'b1;
                                endcase
                                8'h89: begin
                                    if (payload_index == 0)
                                        command_enable <= (rx_byte != 0);
                                    else
                                        packet_error <= 1'b1;
                                end
                            endcase
                        end
                        if (body_index == body_length-1'b1)
                            parser_state <= P_CRC_H;
                        else
                            body_index <= body_index + 1'b1;
                    end
                    P_CRC_H: begin
                        received_crc[15:8] <= rx_byte;
                        parser_state <= P_CRC_L;
                    end
                    P_CRC_L: begin
                        received_crc[7:0] <= rx_byte;
                        crc_ok <= ({received_crc[15:8],rx_byte} == body_crc);
                        parser_state <= P_FOOTER;
                    end
                    P_FOOTER: begin
                        ack_command <= packet_command;
                        ack_status <= 8'h00;
                        if ((rx_byte == 8'hAA) && crc_ok && !packet_error &&
                            !write_request && (axi_state == AXI_IDLE)) begin
                            case (packet_command)
                                8'h86: if ((body_length == 11) &&
                                    (begin_width == MASK_WIDTH) &&
                                    (begin_height == MASK_HEIGHT) &&
                                    (begin_total == MASK_BYTES)) begin
                                    upload_active <= 1'b1;
                                    upload_buffer <= ~active_buffer;
                                    received_bytes <= 0;
                                    ack_status <= 8'hFF;
                                    good_packet_count <= good_packet_count + 1'b1;
                                end else begin
                                    bad_packet_count <= bad_packet_count + 1'b1;
                                end
                                8'h87: if ((body_length > 7) && upload_active &&
                                    (chunk_offset == received_bytes) &&
                                    (received_bytes + chunk_length <= MASK_BYTES)) begin
                                    received_bytes <= received_bytes + chunk_length;
                                    ack_status <= 8'hFF;
                                    good_packet_count <= good_packet_count + 1'b1;
                                end else begin
                                    bad_packet_count <= bad_packet_count + 1'b1;
                                end
                                8'h88: if ((body_length == 7) &&
                                    (mask_loaded || (upload_active &&
                                     (received_bytes == MASK_BYTES)))) begin
                                    mask_left <= command_left;
                                    mask_top <= command_top;
                                    if (upload_active &&
                                        (received_bytes == MASK_BYTES)) begin
                                        active_buffer <= upload_buffer;
                                        upload_active <= 1'b0;
                                        mask_loaded <= 1'b1;
                                    end
                                    ack_status <= 8'hFF;
                                    good_packet_count <= good_packet_count + 1'b1;
                                end else begin
                                    bad_packet_count <= bad_packet_count + 1'b1;
                                end
                                8'h89: if (body_length == 4) begin
                                    mask_enable <= command_enable;
                                    ack_status <= 8'hFF;
                                    good_packet_count <= good_packet_count + 1'b1;
                                end else begin
                                    bad_packet_count <= bad_packet_count + 1'b1;
                                end
                                default: bad_packet_count <= bad_packet_count + 1'b1;
                            endcase
                        end else begin
                            bad_packet_count <= bad_packet_count + 1'b1;
                        end
                        ack_request <= 1'b1;
                        parser_state <= P_HEADER;
                    end
                    default: parser_state <= P_HEADER;
                endcase
            end
        end
    end

    // ---------------------------------------------------------------
    // UART ACK transmitter: BB 0004 06 command 02 status CRC AA.
    // ---------------------------------------------------------------
    reg tx_busy;
    reg [3:0] tx_byte_index;
    reg [3:0] tx_bit_index;
    reg [15:0] tx_clock_count;
    reg [7:0] tx_current_byte;
    reg tx_line;
    reg [7:0] tx_command_latched, tx_status_latched;
    reg [15:0] tx_crc_latched;

    function [7:0] response_byte;
        input [3:0] index;
        input [7:0] command;
        input [7:0] status;
        input [15:0] crc;
        begin
            case (index)
                0: response_byte=8'hBB;
                1: response_byte=8'h00;
                2: response_byte=8'h04;
                3: response_byte=8'h06;
                4: response_byte=command;
                5: response_byte=8'h02;
                6: response_byte=status;
                7: response_byte=crc[15:8];
                8: response_byte=crc[7:0];
                // Only the mask frame header changes to 0xBB.  The common
                // protocol footer remains 0xAA.
                default: response_byte=8'hAA;
            endcase
        end
    endfunction

    assign uart_tx = tx_line;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tx_busy <= 0;
            tx_byte_index <= 0;
            tx_bit_index <= 0;
            tx_clock_count <= 0;
            tx_current_byte <= 0;
            tx_line <= 1'b1;
            tx_command_latched <= 0;
            tx_status_latched <= 0;
            tx_crc_latched <= 0;
        end else if (!enable) begin
            tx_busy <= 0;
            tx_line <= 1'b1;
        end else if (!tx_busy) begin
            tx_line <= 1'b1;
            if (ack_request) begin
                tx_command_latched <= ack_command;
                tx_status_latched <= ack_status;
                tx_crc_latched <= crc16_byte(
                    crc16_byte(crc16_byte(crc16_byte(16'h0000,8'h06),
                    ack_command),8'h02),ack_status);
                tx_byte_index <= 0;
                tx_current_byte <= 8'hBB;
                tx_bit_index <= 0;
                tx_clock_count <= CLKS_PER_BIT-1;
                tx_line <= 1'b0;
                tx_busy <= 1'b1;
            end
        end else if (tx_clock_count != 0) begin
            tx_clock_count <= tx_clock_count - 1'b1;
        end else if (tx_bit_index < 8) begin
            tx_line <= tx_current_byte[tx_bit_index];
            tx_bit_index <= tx_bit_index + 1'b1;
            tx_clock_count <= CLKS_PER_BIT-1;
        end else if (tx_bit_index == 8) begin
            tx_line <= 1'b1;
            tx_bit_index <= 9;
            tx_clock_count <= CLKS_PER_BIT-1;
        end else if (tx_byte_index == 9) begin
            tx_busy <= 1'b0;
            tx_line <= 1'b1;
        end else begin
            tx_byte_index <= tx_byte_index + 1'b1;
            tx_current_byte <= response_byte(tx_byte_index+1'b1,
                                             tx_command_latched,
                                             tx_status_latched,
                                             tx_crc_latched);
            tx_bit_index <= 0;
            tx_clock_count <= CLKS_PER_BIT-1;
            tx_line <= 1'b0;
        end
    end
endmodule
