`timescale 1ns / 1ps

// Decouples the bursty electronic-zoom calculator from real-time video.
//
// The calculator writes complete 1280x1024 canonical {C,Y} frames into a
// HyperRAM ping-pong pair.  Only a completely committed frame is selected by
// the reader.  The reader then emits a deterministic raster: one 16-bit pixel
// every two 100 MHz clocks, with explicit line and frame blanking.  This is
// slow enough for the 8-bit/100-MHz DVP serializer and regular enough for the
// CVBS downsample/scaler pipeline.
module ElectronicZoomRasterBuffer #(
    parameter [31:0] FRAME_A_BASE = 32'h0180_0000,
    parameter [31:0] FRAME_B_BASE = 32'h01A8_0000,
    parameter [31:0] FRAME_C_BASE = 32'h01D0_0000,
    // In steady state the DvpFormatter's SOL prefill is pure latency: it
    // delays the previous line end and the next line start equally, so the
    // DVP inter-line blanking equals the raster gap plus one cycle (verified
    // by tb_dvp_formatter_cadence: blank = source interval - 1).  LINE_GAP=401
    // therefore emits 2560 active + ~402 blank byte clocks per line, the
    // native LGCS123 cadence the X2000 DVP receiver was commissioned with.
    // The old 64-cycle gap left only ~65 blank byte clocks and the receiver's
    // line framing rolled vertically.
    parameter integer LINE_GAP_CYCLES  = 401,
    // 1024 lines x (2560 + LINE_GAP) + FRAME_GAP = 3,333,333 cycles at
    // 100 MHz = 30.00 Hz (same bookkeeping as the original 646357 value).
    parameter integer FRAME_GAP_CYCLES = 301269
) (
    input  wire         clk,
    input  wire         reset,
    input  wire         enable,

    input  wire [15:0]  input_pixel,       // canonical {C,Y}
    input  wire         input_valid,
    input  wire         input_sof,
    input  wire         input_eof,
    output wire         input_ready,

    output reg  [15:0]  output_pixel,      // canonical {C,Y}
    output reg  [10:0]  output_x,
    output reg  [10:0]  output_line,
    output reg          output_valid,
    output reg          output_sof,
    output reg          output_eof,
    output reg          output_sol,
    output reg          output_eol,

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
    input  wire         rvalid,
    output wire         rready,
    input  wire [127:0] rdata,
    input  wire [7:0]   rid,
    input  wire [1:0]   rresp,
    input  wire         rlast,

    output wire         frame_available,
    output reg  [15:0]  completed_frame_count,
    output reg  [15:0]  displayed_frame_count,
    output reg  [15:0]  output_underflow_count,
    output reg  [15:0]  axi_error_count,

    // VIO-only observability for the result writer and deterministic reader.
    output wire [63:0]  debug_writer_state,
    output wire [95:0]  debug_reader_state
);
    localparam integer FRAME_WIDTH  = 1280;
    localparam integer FRAME_HEIGHT = 1024;
    localparam integer FRAME_PIXELS = FRAME_WIDTH*FRAME_HEIGHT;
    localparam integer FRAME_BEATS  = FRAME_PIXELS/8;
    localparam integer FRAME_BURSTS = FRAME_BEATS/16;

    // ------------------------------------------------------------------
    // Sparse calculator output -> 16-beat AXI write bursts.
    // ------------------------------------------------------------------
    reg [127:0] wr_burst [0:15];
    reg [127:0] wr_data_q;
    reg [127:0] pack_word;
    reg [2:0]   pack_lane;
    reg [3:0]   pack_beat;
    reg [20:0]  write_pixel_index;
    reg [31:0]  write_burst_addr;
    reg         write_burst_pending;
    reg         write_burst_eof;
    reg         capture_active;
    reg [1:0]   write_buffer;
    reg         committed_valid;
    reg [1:0]   committed_buffer;
    reg         write_complete_pulse;
    reg         frame_commit_pulse;
    reg [15:0]  write_epoch;
    reg [15:0]  display_epoch;

    function [31:0] raster_frame_base;
        input [1:0] index;
        begin
            case (index)
                2'd0: raster_frame_base = FRAME_A_BASE;
                2'd1: raster_frame_base = FRAME_B_BASE;
                default: raster_frame_base = FRAME_C_BASE;
            endcase
        end
    endfunction

    function [1:0] third_raster_buffer;
        input [1:0] first;
        input [1:0] second;
        begin
            if ((first != 2'd0) && (second != 2'd0))
                third_raster_buffer = 2'd0;
            else if ((first != 2'd1) && (second != 2'd1))
                third_raster_buffer = 2'd1;
            else
                third_raster_buffer = 2'd2;
        end
    endfunction

    // The next ping-pong target must never be the frame currently displayed.
    reg         display_initialized;
    reg [1:0]   display_buffer;
    wire raster_has_pending = committed_valid &&
                              (display_epoch != write_epoch);
    wire write_buffer_safe = !display_initialized ||
        ((write_buffer != display_buffer) &&
         (!raster_has_pending || (write_buffer != committed_buffer)));
    wire [1:0] safe_start_buffer = write_buffer_safe ? write_buffer :
        (raster_has_pending ? third_raster_buffer(display_buffer,
                                                  committed_buffer) :
         ((display_buffer == 2'd0) ? 2'd1 : 2'd0));
    assign input_ready = !write_burst_pending;
    assign frame_available = committed_valid;
    wire [31:0] selected_write_base = raster_frame_base(write_buffer);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pack_word<=0; pack_lane<=0; pack_beat<=0;
            write_pixel_index<=0; write_burst_addr<=FRAME_A_BASE;
            write_burst_pending<=0; write_burst_eof<=0;
            capture_active<=0; write_buffer<=0;
            committed_valid<=0; committed_buffer<=0;
            completed_frame_count<=0; frame_commit_pulse<=0;
            write_epoch<=0;
        end else begin
            frame_commit_pulse<=0;
            if (input_valid && input_ready) begin
                if (!capture_active) begin
                    if (input_sof) begin
                        capture_active<=1;
                        write_buffer<=safe_start_buffer;
                        write_pixel_index<=1;
                        write_burst_addr<=raster_frame_base(safe_start_buffer);
                        pack_word<={112'd0,input_pixel};
                        pack_lane<=1; pack_beat<=0;
                    end
                end else begin
                    if (pack_lane==0 && pack_beat==0)
                        write_burst_addr<=selected_write_base+
                                          {write_pixel_index,1'b0};
                    write_pixel_index<=write_pixel_index+1'b1;
                    if (pack_lane==7) begin
                        wr_burst[pack_beat]<=pack_word |
                            ({{112{1'b0}},input_pixel} << 112);
                        pack_word<=0; pack_lane<=0;
                        if (pack_beat==15) begin
                            pack_beat<=0;
                            write_burst_pending<=1;
                            write_burst_eof<=input_eof;
                        end else pack_beat<=pack_beat+1'b1;
                    end else begin
                        pack_word<=pack_word |
                            ({{112{1'b0}},input_pixel} << {pack_lane,4'b0000});
                        pack_lane<=pack_lane+1'b1;
                    end
                end
            end
            if (write_complete_pulse) begin
                write_burst_pending<=0;
                if (write_burst_eof) begin
                    capture_active<=0;
                    committed_valid<=1;
                    committed_buffer<=write_buffer;
                    write_buffer<=third_raster_buffer(display_buffer,
                                                      write_buffer);
                    write_epoch<=write_epoch+1'b1;
                    completed_frame_count<=completed_frame_count+1'b1;
                    frame_commit_pulse<=1;
                end
            end
        end
    end

    // ------------------------------------------------------------------
    // AXI read prefetch FIFO.  One entry is one 128-bit AXI beat/eight pixels.
    // ------------------------------------------------------------------
    wire [127:0] read_fifo_data;
    wire read_fifo_valid, read_fifo_ready;
    wire read_fifo_overflow;
    reg  read_fifo_overflow_seen;
    wire read_fifo_push;
    wire read_fifo_pop;
    VideoAsyncFifo #(.WIDTH(128),.ADDR_W(8)) u_read_fifo (
        .wr_clk(clk), .wr_reset(reset),
        .wr_data(rdata), .wr_valid(read_fifo_push),
        .wr_ready(read_fifo_ready), .overflow(read_fifo_overflow),
        .rd_clk(clk), .rd_reset(reset),
        .rd_data(read_fifo_data), .rd_valid(read_fifo_valid),
        .rd_ready(read_fifo_pop)
    );

    reg [17:0] buffered_beats;
    reg [17:0] received_beats;
    reg [17:0] consumed_beats;
    reg        start_read_frame;
    reg [31:0] read_frame_base;
    reg [13:0] read_burst_index;
    // Keep almost a full BRAM FIFO prefetched.  The old 64-beat start / 128-
    // beat refill thresholds exposed the deterministic raster to normal
    // round-robin HyperRAM latency after only 512 pixels.
    localparam [17:0] READ_FIFO_REFILL_BEATS = 18'd224;
    localparam [17:0] READ_FIFO_START_BEATS  = 18'd192;
    wire read_fill_needed = display_initialized &&
                             (read_burst_index < FRAME_BURSTS) &&
                             (buffered_beats < READ_FIFO_REFILL_BEATS) &&
                             read_fifo_ready;

    // ------------------------------------------------------------------
    // Deterministic output raster.  A word is emitted every other clk so the
    // downstream DvpFormatter can serialize its two bytes without underflow.
    // ------------------------------------------------------------------
    reg raster_active;
    reg pixel_phase;
    reg [2:0] beat_lane;
    reg [15:0] line_gap_count;
    reg [19:0] frame_gap_count;

    function [15:0] select_pixel;
        input [127:0] beat;
        input [2:0] lane;
        begin
            case(lane)
              0:select_pixel=beat[15:0];   1:select_pixel=beat[31:16];
              2:select_pixel=beat[47:32];  3:select_pixel=beat[63:48];
              4:select_pixel=beat[79:64];  5:select_pixel=beat[95:80];
              6:select_pixel=beat[111:96]; default:select_pixel=beat[127:112];
            endcase
        end
    endfunction

    assign read_fifo_pop = raster_active && (line_gap_count==0) &&
                           pixel_phase && (beat_lane==7) && read_fifo_valid;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            display_initialized<=0; display_buffer<=0; display_epoch<=0;
            read_frame_base<=FRAME_A_BASE; start_read_frame<=0;
            buffered_beats<=0; received_beats<=0; consumed_beats<=0;
            raster_active<=0; pixel_phase<=0; beat_lane<=0;
            output_pixel<=0; output_x<=0; output_line<=0;
            output_valid<=0; output_sof<=0; output_eof<=0;
            output_sol<=0; output_eol<=0;
            line_gap_count<=0; frame_gap_count<=FRAME_GAP_CYCLES;
            displayed_frame_count<=0; output_underflow_count<=0;
        end else begin
            start_read_frame<=0;
            output_valid<=0; output_sof<=0; output_eof<=0;
            output_sol<=0; output_eol<=0;

            if (read_fifo_push && !read_fifo_pop) begin
                buffered_beats<=buffered_beats+1'b1;
                received_beats<=received_beats+1'b1;
            end else if (!read_fifo_push && read_fifo_pop) begin
                buffered_beats<=buffered_beats-1'b1;
                consumed_beats<=consumed_beats+1'b1;
            end else if (read_fifo_push && read_fifo_pop) begin
                received_beats<=received_beats+1'b1;
                consumed_beats<=consumed_beats+1'b1;
            end

            // First complete result primes the display reader.  Later commits
            // are adopted only after the current displayed frame is complete.
            if (frame_commit_pulse && !display_initialized) begin
                display_initialized<=1;
                display_buffer<=committed_buffer;
                display_epoch<=write_epoch;
                read_frame_base<=raster_frame_base(committed_buffer);
                buffered_beats<=0; received_beats<=0; consumed_beats<=0;
                start_read_frame<=1;
            end

            if (!raster_active) begin
                pixel_phase<=0; beat_lane<=0;
                if (frame_gap_count < FRAME_GAP_CYCLES)
                    frame_gap_count<=frame_gap_count+1'b1;
                if (enable && display_initialized &&
                    frame_gap_count>=FRAME_GAP_CYCLES &&
                     buffered_beats>=READ_FIFO_START_BEATS && read_fifo_valid) begin
                    raster_active<=1;
                    output_x<=0; output_line<=0;
                    frame_gap_count<=0; line_gap_count<=0;
                end
            end else if (line_gap_count!=0) begin
                line_gap_count<=line_gap_count-1'b1;
            end else if (!pixel_phase) begin
                if (read_fifo_valid) begin
                    output_pixel<=select_pixel(read_fifo_data,beat_lane);
                    output_valid<=1;
                    output_sof<=(output_x==0 && output_line==0);
                    output_sol<=(output_x==0);
                    output_eol<=(output_x==1279);
                    output_eof<=(output_x==1279 && output_line==1023);
                    pixel_phase<=1;
                end else begin
                    output_underflow_count<=output_underflow_count+1'b1;
                end
            end else begin
                pixel_phase<=0;
                if (beat_lane==7) beat_lane<=0;
                else beat_lane<=beat_lane+1'b1;

                if (output_x==1279) begin
                    output_x<=0;
                    if (output_line==1023) begin
                        output_line<=0; raster_active<=0;
                        displayed_frame_count<=displayed_frame_count+1'b1;
                        // Switch only here: no output frame can contain pixels
                        // from two different calculated frames.
                        if (raster_has_pending) begin
                            display_buffer<=committed_buffer;
                            display_epoch<=write_epoch;
                            read_frame_base<=raster_frame_base(committed_buffer);
                        end else begin
                            read_frame_base<=raster_frame_base(display_buffer);
                        end
                        buffered_beats<=0; received_beats<=0; consumed_beats<=0;
                        start_read_frame<=1;
                    end else begin
                        output_line<=output_line+1'b1;
                        line_gap_count<=LINE_GAP_CYCLES;
                    end
                end else output_x<=output_x+1'b1;
            end
        end
    end

    // ------------------------------------------------------------------
    // One-outstanding-burst AXI master shared by output writes and display
    // prefetch reads.  Writes have priority so the sparse calculator can be
    // back-pressured only at a 128-pixel boundary.
    // ------------------------------------------------------------------
    localparam [2:0] B_IDLE=0,B_WADDR=1,B_WDATA=2,B_WRESP=3,
                     B_WWAIT=4,B_RADDR=5,B_RDATA=6;
    reg [2:0] bus_state;
    reg [4:0] bus_beat;

    assign avalid=(bus_state==B_WADDR)||(bus_state==B_RADDR);
    assign aaddr=(bus_state==B_WADDR) ? write_burst_addr :
                 read_frame_base + read_burst_index*32'd256;
    assign aid=(bus_state==B_WADDR)?8'hE0:8'hE1;
    assign alen=8'd15; assign asize=3'd4; assign aburst=2'b01;
    assign alock=2'b00; assign atype=(bus_state==B_WADDR);
    assign wvalid=(bus_state==B_WDATA);
    assign wid=8'hE0; assign wdata=wr_data_q; assign wstrb=16'hffff;
    assign wlast=(bus_beat==15);
    assign bready=(bus_state==B_WRESP);
    assign rready=(bus_state==B_RDATA) && read_fifo_ready;
    assign read_fifo_push=(bus_state==B_RDATA) && rvalid && rready;

    // debug_writer_state bit assignment:
    // [63:61] AXI state, [60:56] AXI beat, [55]/[47] write buffer MSB/LSB,
    // [54:51] input valid/ready/SOF/EOF, [50] capture active,
    // [49] burst pending, [48] pending EOF, [46] committed valid,
    // [45]/[44] committed buffer LSB/MSB,
    // [43] write-complete pulse, [42] frame-commit pulse,
    // [41:38] pack beat, [37:35] pack lane,
    // [34:14] write pixel index, [13:0] read burst index.
    assign debug_writer_state = {
        bus_state, bus_beat, write_buffer[1], input_valid, input_ready,
        input_sof, input_eof, capture_active, write_burst_pending,
        write_burst_eof, write_buffer[0], committed_valid,
        committed_buffer[0], committed_buffer[1],
        write_complete_pulse, frame_commit_pulse,
        pack_beat, pack_lane, write_pixel_index, read_burst_index
    };

    // debug_reader_state bit assignment:
    // [95:94] display buffer, [93] raster active,
    // [92] pixel phase, [91:89] beat lane, [88:84] FIFO valid/ready/
    // pop/push/overflow, [83] restart pulse, [82] frame available,
    // [81:64] buffered beats, [63:46] received beats,
    // [45:28] consumed beats, [27:17] output X, [16:6] output line,
    // [5] in line gap, [4] frame gap elapsed, [3:1] AXI state, [0] enable.
    assign debug_reader_state = {
        display_buffer, raster_active, pixel_phase,
        beat_lane, read_fifo_valid, read_fifo_ready, read_fifo_pop,
        read_fifo_push, read_fifo_overflow, start_read_frame, frame_available,
        buffered_beats, received_beats, consumed_beats, output_x, output_line,
        (line_gap_count != 0), (frame_gap_count >= FRAME_GAP_CYCLES),
        bus_state, enable
    };

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bus_state<=B_IDLE; bus_beat<=0; wr_data_q<=0;
            write_complete_pulse<=0; read_burst_index<=0;
            axi_error_count<=0; read_fifo_overflow_seen<=0;
        end else begin
            write_complete_pulse<=0;
            if (start_read_frame) read_burst_index<=0;
            case(bus_state)
              B_IDLE: begin
                  bus_beat<=0;
                  if (write_burst_pending) bus_state<=B_WADDR;
                  else if (read_fill_needed) bus_state<=B_RADDR;
              end
              B_WADDR: if (aready) begin
                  wr_data_q<=wr_burst[0]; bus_state<=B_WDATA;
              end
              B_WDATA: if (wready) begin
                  if (bus_beat==15) bus_state<=B_WRESP;
                  else begin
                      bus_beat<=bus_beat+1'b1;
                      wr_data_q<=wr_burst[bus_beat[3:0]+1'b1];
                  end
              end
              B_WRESP: if (bvalid) begin
                  if (bid!=8'hE0) axi_error_count<=axi_error_count+1'b1;
                  write_complete_pulse<=1; bus_state<=B_WWAIT;
              end
              B_WWAIT: if (!write_burst_pending) bus_state<=B_IDLE;
              B_RADDR: if (aready) begin bus_beat<=0; bus_state<=B_RDATA; end
              B_RDATA: if (rvalid && rready) begin
                  if (rresp!=0 || rid!=8'hE1)
                      axi_error_count<=axi_error_count+1'b1;
                  if (rlast) begin
                      read_burst_index<=read_burst_index+1'b1;
                      bus_state<=B_IDLE;
                  end else bus_beat<=bus_beat+1'b1;
              end
              default: bus_state<=B_IDLE;
            endcase
            // VideoAsyncFifo keeps overflow asserted until reset. Count the
            // incident once rather than incrementing the diagnostic forever.
            if (read_fifo_overflow && !read_fifo_overflow_seen) begin
                read_fifo_overflow_seen<=1'b1;
                axi_error_count<=axi_error_count+1'b1;
            end
        end
    end
endmodule
