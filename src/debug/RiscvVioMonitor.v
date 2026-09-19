// Lightweight, non-intrusive Sapphire/RISC-V diagnostics for Efinity VIO.
// This block does not halt the CPU and is not a replacement for a JTAG
// debugger.  It observes the external-memory AXI master and decodes the
// selected 115200-baud UART pins so bring-up failures can be localized.
module RiscvVioMonitor #(
  parameter integer CLK_HZ = 100000000,
  parameter integer UART_BAUD = 115200
) (
  input  wire        clk,
  input  wire        reset,
  input  wire        clear,
  input  wire        hbc_cal_pass,
  input  wire        cpu_enable,
  input  wire        cpu_reset,
  input  wire        gpio_activity,
  input  wire        uart_rx,
  input  wire        uart_tx,
  input  wire        axi_arw_valid,
  input  wire        axi_arw_ready,
  input  wire        axi_arw_write,
  input  wire [31:0] axi_arw_addr,
  input  wire        axi_w_valid,
  input  wire        axi_w_ready,
  input  wire        axi_b_valid,
  input  wire        axi_b_ready,
  input  wire [1:0]  axi_b_resp,
  input  wire        axi_r_valid,
  input  wire        axi_r_ready,
  input  wire [127:0] axi_r_data,
  input  wire [1:0]  axi_r_resp,
  output reg  [15:0] heartbeat,
  output reg  [7:0]  boot_flags,
  output reg  [7:0]  last_rx_byte,
  output reg  [15:0] rx_good_bytes,
  output reg  [15:0] rx_bad_frames,
  output reg  [7:0]  last_error,
  output reg  [15:0] axi_errors,
  output reg  [31:0] rx_bytes,
  output reg  [31:0] tx_bytes,
  output reg  [31:0] last_axi_addr,
  output reg  [127:0] boot_read_data,
  output reg  [15:0] axi_write_addresses,
  output reg  [31:0] axi_write_beats,
  output reg  [15:0] axi_write_responses,
  output reg  [15:0] axi_read_addresses,
  output reg  [31:0] axi_read_beats
);
  localparam integer HEARTBEAT_DIV = CLK_HZ;

  wire [7:0] rx_data;
  wire       rx_valid;
  wire       rx_frame_error;
  wire [7:0] tx_data_unused;
  wire       tx_valid;
  wire       tx_frame_error;

  reg [31:0] heartbeat_divider;
  reg        cpu_activity_seen;
  reg        capture_boot_read;

  RiscvUartByteMonitor #(.CLK_HZ(CLK_HZ), .UART_BAUD(UART_BAUD)) u_rx_mon (
    .clk(clk), .reset(reset | clear), .serial_in(uart_rx),
    .data(rx_data), .valid(rx_valid), .frame_error(rx_frame_error)
  );

  RiscvUartByteMonitor #(.CLK_HZ(CLK_HZ), .UART_BAUD(UART_BAUD)) u_tx_mon (
    .clk(clk), .reset(reset | clear), .serial_in(uart_tx),
    .data(tx_data_unused), .valid(tx_valid), .frame_error(tx_frame_error)
  );

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      heartbeat          <= 16'd0;
      boot_flags         <= 8'd0;
      last_rx_byte       <= 8'd0;
      rx_good_bytes      <= 16'd0;
      rx_bad_frames      <= 16'd0;
      last_error         <= 8'd0;
      axi_errors         <= 16'd0;
      rx_bytes           <= 32'd0;
      tx_bytes           <= 32'd0;
      last_axi_addr      <= 32'd0;
      boot_read_data     <= 128'd0;
      axi_write_addresses <= 16'd0;
      axi_write_beats    <= 32'd0;
      axi_write_responses <= 16'd0;
      axi_read_addresses <= 16'd0;
      axi_read_beats     <= 32'd0;
      heartbeat_divider  <= 32'd0;
      cpu_activity_seen  <= 1'b0;
      capture_boot_read  <= 1'b0;
    end else if (clear) begin
      heartbeat          <= 16'd0;
      boot_flags         <= {1'b0, gpio_activity, 3'b000,
                             ~cpu_reset, cpu_enable, hbc_cal_pass};
      last_rx_byte       <= 8'd0;
      rx_good_bytes      <= 16'd0;
      rx_bad_frames      <= 16'd0;
      last_error         <= 8'd0;
      axi_errors         <= 16'd0;
      rx_bytes           <= 32'd0;
      tx_bytes           <= 32'd0;
      last_axi_addr      <= 32'd0;
      boot_read_data     <= 128'd0;
      axi_write_addresses <= 16'd0;
      axi_write_beats    <= 32'd0;
      axi_write_responses <= 16'd0;
      axi_read_addresses <= 16'd0;
      axi_read_beats     <= 32'd0;
      heartbeat_divider  <= 32'd0;
      cpu_activity_seen  <= 1'b0;
      capture_boot_read  <= 1'b0;
    end else begin
      // Live status in bits 0..2; sticky evidence in bits 3..7.
      boot_flags[0] <= hbc_cal_pass;
      boot_flags[1] <= cpu_enable;
      boot_flags[2] <= ~cpu_reset;
      if (axi_arw_valid && axi_arw_ready) begin
        cpu_activity_seen <= 1'b1;
        last_axi_addr <= axi_arw_addr;
        if (axi_arw_write)
          begin
            boot_flags[5] <= 1'b1;
            axi_write_addresses <= axi_write_addresses + 1'b1;
          end
        else begin
          boot_flags[3] <= 1'b1;
          axi_read_addresses <= axi_read_addresses + 1'b1;
          if (axi_arw_addr == 32'h00001000)
            capture_boot_read <= 1'b1;
        end
      end
      if (axi_w_valid && axi_w_ready)
        axi_write_beats <= axi_write_beats + 1'b1;
      if (axi_b_valid && axi_b_ready)
        axi_write_responses <= axi_write_responses + 1'b1;
      if (axi_r_valid && axi_r_ready) begin
        boot_flags[4] <= 1'b1;
        axi_read_beats <= axi_read_beats + 1'b1;
        if (capture_boot_read) begin
          boot_read_data <= axi_r_data;
          capture_boot_read <= 1'b0;
        end
      end
      if (gpio_activity)
        boot_flags[6] <= 1'b1;
      if (rx_valid)
        boot_flags[7] <= 1'b1;

      if (heartbeat_divider == HEARTBEAT_DIV-1) begin
        heartbeat_divider <= 32'd0;
        if (cpu_activity_seen)
          heartbeat <= heartbeat + 1'b1;
        cpu_activity_seen <= 1'b0;
      end else begin
        heartbeat_divider <= heartbeat_divider + 1'b1;
      end

      if (rx_valid) begin
        last_rx_byte  <= rx_data;
        rx_good_bytes <= rx_good_bytes + 1'b1;
        rx_bytes      <= rx_bytes + 1'b1;
      end
      if (tx_valid)
        tx_bytes <= tx_bytes + 1'b1;

      if (rx_frame_error) begin
        rx_bad_frames <= rx_bad_frames + 1'b1;
        last_error <= 8'h01; // selected UART RX framing error
      end
      if (tx_frame_error)
        last_error <= 8'h02; // soft-core UART TX framing error

      if (axi_b_valid && axi_b_ready && (axi_b_resp != 2'b00)) begin
        axi_errors <= axi_errors + 1'b1;
        last_error <= {4'h1, 2'b00, axi_b_resp};
      end
      if (axi_r_valid && axi_r_ready && (axi_r_resp != 2'b00)) begin
        axi_errors <= axi_errors + 1'b1;
        last_error <= {4'h2, 2'b00, axi_r_resp};
      end
    end
  end
endmodule

module RiscvUartByteMonitor #(
  parameter integer CLK_HZ = 100000000,
  parameter integer UART_BAUD = 115200
) (
  input  wire       clk,
  input  wire       reset,
  input  wire       serial_in,
  output reg  [7:0] data,
  output reg        valid,
  output reg        frame_error
);
  localparam integer CLKS_PER_BIT = CLK_HZ / UART_BAUD;
  localparam integer HALF_BIT = CLKS_PER_BIT / 2;
  localparam [1:0] IDLE = 2'd0, START = 2'd1, DATA = 2'd2, STOP = 2'd3;

  reg [1:0]  state;
  reg [15:0] timer;
  reg [2:0]  bit_index;
  reg [7:0]  shift;
  reg [1:0]  serial_sync;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state         <= IDLE;
      timer         <= 16'd0;
      bit_index     <= 3'd0;
      shift         <= 8'd0;
      serial_sync   <= 2'b11;
      data          <= 8'd0;
      valid         <= 1'b0;
      frame_error   <= 1'b0;
    end else begin
      serial_sync <= {serial_sync[0], serial_in};
      valid       <= 1'b0;
      frame_error <= 1'b0;
      case (state)
        IDLE: begin
          timer <= 16'd0;
          if (serial_sync[1] == 1'b0)
            state <= START;
        end
        START: begin
          if (timer == HALF_BIT-1) begin
            timer <= 16'd0;
            if (serial_sync[1] == 1'b0) begin
              bit_index <= 3'd0;
              state <= DATA;
            end else begin
              state <= IDLE;
            end
          end else timer <= timer + 1'b1;
        end
        DATA: begin
          if (timer == CLKS_PER_BIT-1) begin
            timer <= 16'd0;
            shift[bit_index] <= serial_sync[1];
            if (bit_index == 3'd7)
              state <= STOP;
            else
              bit_index <= bit_index + 1'b1;
          end else timer <= timer + 1'b1;
        end
        STOP: begin
          if (timer == CLKS_PER_BIT-1) begin
            timer <= 16'd0;
            if (serial_sync[1]) begin
              data  <= shift;
              valid <= 1'b1;
            end else begin
              frame_error <= 1'b1;
            end
            state <= IDLE;
          end else timer <= timer + 1'b1;
        end
        default: state <= IDLE;
      endcase
    end
  end
endmodule
