`timescale 1ns / 1ps

// Native 1280x1024 electronic zoom with HyperRAM ping-pong frame storage.
// Raw pixels are canonical {C,Y} YUV422.  AXI transfers are 16-beat,
// 128-bit INCR bursts (256 bytes / 128 pixels), exactly ten bursts per line.
// Four requested source rows are cached before Catmull-Rom interpolation;
// this prevents 16 independent HyperRAM reads per output pixel.
module ElectronicZoomFrameBuffer #(
    parameter [31:0] FRAME_A_BASE = 32'h0100_0000,
    parameter [31:0] FRAME_B_BASE = 32'h0128_0000,
    parameter [31:0] FRAME_C_BASE = 32'h0150_0000,
    // Zero preserves the legacy self-contained decoder CDC used by unit
    // tests.  The top-level hot-focus path sets this to one and supplies an
    // already crossed clk-domain ready/valid stream.
    parameter integer EXTERNAL_INPUT = 0
) (
    input  wire         input_clk,
    input  wire         input_reset,
    input  wire [7:0]   input_y,
    input  wire [7:0]   input_c,
    input  wire         input_valid,
    input  wire         input_sof,
    input  wire         input_eof,
    input  wire         input_sol,
    input  wire         input_eol,
    input  wire         input_drop_epoch,
    output wire         input_ready,

    input  wire         clk,
    input  wire         reset,
    input  wire         y_from_high,
    input  wire         zoom_enable_command,
    input  wire [10:0]  roi_left_command,
    input  wire [10:0]  roi_top_command,
    input  wire [10:0]  roi_width_command,
    input  wire [10:0]  roi_height_command,

    output wire [15:0]  output_word,
    output wire [7:0]   output_y,
    output wire [7:0]   output_c,
    output wire [10:0]  output_x,
    output wire [10:0]  output_line,
    output wire         output_valid,
    output wire         output_sof,
    output wire         output_eof,
    output wire         output_sol,
    output wire         output_eol,
    input  wire         output_ready,

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

    output wire         input_fifo_overflow,
    output reg  [15:0]  captured_frame_count,
    output reg  [15:0]  zoom_output_frame_count,
    output reg  [15:0]  axi_error_count,
    // Logical configuration state.  The calculator remains active when this
    // is zero, using the full-frame 1x ROI.
    output reg          active_zoom,
    output reg  [10:0]  active_left,
    output reg  [10:0]  active_top,
    output reg  [10:0]  active_width,
    output reg  [10:0]  active_height,

    // VIO-only observability.  These buses expose state that is otherwise
    // impossible to distinguish from the frame/error counters at top level.
    output wire [63:0]  debug_capture_state,
    output wire [103:0] debug_calculator_state,
    output wire [43:0]  debug_line_tags,
    output wire [3:0]   debug_line_present,
    output wire [54:0]  debug_need_rows
);
    localparam integer FRAME_WIDTH=1280, FRAME_HEIGHT=1024;
    localparam [20:0] FRAME_PIXELS = FRAME_WIDTH * FRAME_HEIGHT;
    localparam [3:0] Z_WAIT=0,Z_CHECK=1,Z_RD0_WAIT=2,Z_RD0_CAPTURE=3,
                     Z_RD1_WAIT=4,Z_RD1_CAPTURE=5,
                     Z_TAPS=6,Z_VERT=7,Z_OUT=8;
    reg [3:0] zstate;

    // Decoder-to-AXI CDC.  Every frame, including the full-frame 1x case,
    // enters the same source-buffer/scaler/raster pipeline.
    wire [20:0] in_fifo_data;
    wire in_fifo_valid;
    wire in_fifo_ready;
    wire input_fifo_wr_ready;
    wire [20:0] legacy_fifo_data;
    wire legacy_fifo_valid;
    wire legacy_fifo_overflow;
    reg legacy_drop_epoch;
    reg legacy_drop_episode;

    // BT.1120 is a push-only physical source, so wr_ready cannot stall it.
    // Instead, toggle an epoch once per full-FIFO episode.  The read domain
    // rejects the affected frame and resumes only from a later clean SOF.
    always @(posedge input_clk or posedge input_reset) begin
        if (input_reset) begin
            legacy_drop_epoch <= 1'b0;
            legacy_drop_episode <= 1'b0;
        end else if (input_valid && !input_fifo_wr_ready) begin
            if (!legacy_drop_episode)
                legacy_drop_epoch <= ~legacy_drop_epoch;
            legacy_drop_episode <= 1'b1;
        end else if (input_fifo_wr_ready) begin
            legacy_drop_episode <= 1'b0;
        end
    end

    VideoAsyncFifo #(.WIDTH(21),.ADDR_W(13)) u_input_fifo (
        .wr_clk(input_clk), .wr_reset(input_reset),
        .wr_data({legacy_drop_epoch,input_sof,input_eof,input_sol,input_eol,
                  input_c,input_y}),
        .wr_valid(input_valid && !EXTERNAL_INPUT),
        .wr_ready(input_fifo_wr_ready),
        .overflow(legacy_fifo_overflow),
        .rd_clk(clk), .rd_reset(reset), .rd_data(legacy_fifo_data),
        .rd_valid(legacy_fifo_valid),
        .rd_ready(in_fifo_ready && !EXTERNAL_INPUT)
    );

    assign in_fifo_data = EXTERNAL_INPUT ?
        {input_drop_epoch,input_sof,input_eof,input_sol,input_eol,input_c,input_y} :
        legacy_fifo_data;
    assign in_fifo_valid = EXTERNAL_INPUT ? input_valid : legacy_fifo_valid;
    assign input_ready = EXTERNAL_INPUT ? in_fifo_ready : 1'b0;
    assign input_fifo_overflow = EXTERNAL_INPUT ? 1'b0 : legacy_fifo_overflow;

    // ------------------------------------------------------------------
    // Raw-frame burst writer.
    // ------------------------------------------------------------------
    reg [127:0] wr_burst [0:15];
    reg [127:0] wr_burst_q;
    reg [127:0] pack_word;
    reg [2:0] pack_lane;
    reg [3:0] pack_beat;
    reg [20:0] input_pixel_index;
    reg [31:0] wr_burst_addr;
    reg wr_burst_pending, wr_burst_is_eof;
    reg [1:0] write_buffer;
    reg committed_valid;
    reg [1:0] committed_buffer;
    reg [1:0] read_buffer;
    reg capture_started;
    reg capture_drop_epoch;
    reg [15:0] wr_epoch;
    reg [15:0] read_epoch;           // Moved here to be available at line 198
    reg write_burst_complete;         // Moved here to be available at line 290

    function [31:0] source_frame_base;
        input [1:0] index;
        begin
            case (index)
                2'd0: source_frame_base = FRAME_A_BASE;
                2'd1: source_frame_base = FRAME_B_BASE;
                default: source_frame_base = FRAME_C_BASE;
            endcase
        end
    endfunction

    function [1:0] third_source_buffer;
        input [1:0] first;
        input [1:0] second;
        begin
            if ((first != 2'd0) && (second != 2'd0))
                third_source_buffer = 2'd0;
            else if ((first != 2'd1) && (second != 2'd1))
                third_source_buffer = 2'd1;
            else
                third_source_buffer = 2'd2;
        end
    endfunction

    // There is no separate raw bypass.  A disabled zoom command is represented
    // by the full-frame ROI below, so source capture remains active in 1x mode.
    // The source has no back-pressure path to BT.1120, so an overflowing CDC
    // FIFO invalidates the affected frame instead.  Three buffers keep the live
    // writer away from the frame the calculator is reading and the newest frame
    // that has not yet been consumed.
    wire source_has_pending = committed_valid && (read_epoch != wr_epoch);
    wire write_targets_processing = (zstate != Z_WAIT) &&
                                    (write_buffer == read_buffer);
    wire write_targets_pending = source_has_pending &&
                                 (write_buffer == committed_buffer);
    wire source_write_safe = !write_targets_processing &&
                             !write_targets_pending;
    wire [1:0] safe_start_buffer = source_write_safe ? write_buffer :
        (source_has_pending ? third_source_buffer(read_buffer,
                                                  committed_buffer) :
         ((read_buffer == 2'd0) ? 2'd1 : 2'd0));
    wire can_take_input = !capture_started || !wr_burst_pending;
    assign in_fifo_ready = can_take_input;
    wire in_take = in_fifo_valid && in_fifo_ready;
    wire [15:0] canonical_pixel = {in_fifo_data[15:8],in_fifo_data[7:0]};
    wire [31:0] current_write_base = source_frame_base(write_buffer);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pack_word <= 0; pack_lane <= 0; pack_beat <= 0;
            input_pixel_index <= 0; wr_burst_addr <= FRAME_A_BASE;
            wr_burst_pending <= 0; wr_burst_is_eof <= 0;
            write_buffer <= 2'd0; committed_valid <= 0;
            committed_buffer <= 0;
            capture_started <= 0; capture_drop_epoch <= 0;
            captured_frame_count <= 0; wr_epoch <= 0;
        end else begin
            if (in_take) begin
                if (!capture_started) begin
                    // Idle means drain/discard.  Start only on a clean SOF and
                    // only when the selected buffer is not being processed.
                    if (in_fifo_data[19]) begin
                        capture_started<=1;
                        capture_drop_epoch<=in_fifo_data[20];
                        write_buffer<=safe_start_buffer;
                        input_pixel_index<=1;
                        wr_burst_addr<=source_frame_base(safe_start_buffer);
                        pack_word<={{112{1'b0}},canonical_pixel};
                        pack_lane<=1;pack_beat<=0;
                    end
                end else if (in_fifo_data[19]) begin
                    // An SOF before the counter-driven frame completed means
                    // the previous frame was damaged (normally by FIFO
                    // overflow).  Abandon the partial packing and resynchronize
                    // on this SOF.
                    pack_word <= {{112{1'b0}},canonical_pixel};
                    pack_lane <= 1;
                    pack_beat <= 0;
                    input_pixel_index <= 1;
                    capture_drop_epoch <= in_fifo_data[20];
                    write_buffer <= safe_start_buffer;
                    wr_burst_addr <= source_frame_base(safe_start_buffer);
                    wr_burst_is_eof <= 0;
                    capture_started <= 1'b1;
                end else if ((in_fifo_data[20] != capture_drop_epoch) ||
                             (input_pixel_index >= FRAME_PIXELS)) begin
                    // A FIFO overflow episode, or a counter overrun, invalidates
                    // the frame.  Never publish or address beyond one exact
                    // frame; idle draining below finds the next SOF.
                    pack_word <= 0;
                    pack_lane <= 0;
                    pack_beat <= 0;
                    input_pixel_index <= 0;
                    wr_burst_is_eof <= 0;
                    capture_started <= 0;
                end else begin
                    if (pack_lane == 0 && pack_beat == 0)
                        wr_burst_addr <= current_write_base + {input_pixel_index,1'b0};
                    input_pixel_index <= input_pixel_index+1'b1;
                    if (pack_lane == 7) begin
                        wr_burst[pack_beat] <= pack_word |
                            ({{112{1'b0}},canonical_pixel} << 112);
                        pack_word <= 0;
                        pack_lane <= 0;
                        if (pack_beat == 15) begin
                            pack_beat <= 0;
                            wr_burst_pending <= 1'b1;
                            // Frame completion is counter-driven, not timed off
                            // the BT.1120 EOF marker.  The final 128-pixel
                            // burst is the one containing pixel 1280*1024-1.
                            wr_burst_is_eof <=
                                (input_pixel_index == FRAME_PIXELS-1'b1);
                        end else begin
                            pack_beat <= pack_beat+1'b1;
                        end
                    end else begin
                        pack_word <= pack_word |
                            ({{112{1'b0}},canonical_pixel} << ({pack_lane,4'b0000}));
                        pack_lane <= pack_lane+1'b1;
                    end
                end
            end
            if (write_burst_complete) begin
                wr_burst_pending <= 1'b0;
                if (wr_burst_is_eof) begin
                    committed_valid <= 1'b1;
                    committed_buffer <= write_buffer;
                    write_buffer <= third_source_buffer(read_buffer,
                                                        write_buffer);
                    captured_frame_count <= captured_frame_count+1'b1;
                    wr_epoch <= wr_epoch+1'b1;
                    capture_started<=0;
                end
            end
        end
    end

    // ------------------------------------------------------------------
    // Four 1280-pixel source-line caches.  Each entry is exactly one AXI beat
    // (eight {C,Y} pixels), so a line is 160 x 128-bit words.  Keeping the RAM
    // port equal to the AXI width avoids a repacking register and, compared
    // with the former 256-bit entry, halves every interpolation-window mux.
    // ------------------------------------------------------------------
    reg [127:0] line0 [0:159];
    reg [127:0] line1 [0:159];
    reg [127:0] line2 [0:159];
    reg [127:0] line3 [0:159];
    reg [7:0] cache_rd_addr;
    reg [127:0] line_q0, line_q1, line_q2, line_q3;
    reg [10:0] line_tag0, line_tag1, line_tag2, line_tag3;
    reg line_valid0, line_valid1, line_valid2, line_valid3;
    reg line_load_pending;
    reg request_line_load;
    reg invalidate_line_cache;
    reg [10:0] requested_row;
    reg [10:0] load_row;
    reg [1:0] load_bank;
    reg [3:0] load_burst_index;
    reg [3:0] load_beat_index;
    wire [7:0] line_write_addr = {load_burst_index, load_beat_index};
    reg [31:0] read_frame_base;
    // read_epoch already declared at line ~168

    // Accumulator variables used in sy_int calculation
    // Must be declared before use
    reg [26:0] x_acc, y_acc, step_x, step_y;

    wire [10:0] sy_int = y_acc[26:16];
    wire [10:0] need_y0 = (sy_int == 0) ? 0 : sy_int-1'b1;
    wire [10:0] need_y1 = sy_int;
    wire [10:0] need_y2 = (sy_int >= 1023) ? 1023 : sy_int+1'b1;
    wire [10:0] need_y3 = (sy_int >= 1022) ? 1023 : sy_int+2'd2;

    // Keep line_valid/line_tag as explicit operands of these continuous
    // assigns.  A function that reads module regs without taking them as
    // arguments is not part of the assign's sensitivity list, which makes the
    // simulated value stale after a line load completes.
    wire lp0 = (need_y0[1:0]==2'd0) ? (line_valid0 && line_tag0==need_y0) :
               (need_y0[1:0]==2'd1) ? (line_valid1 && line_tag1==need_y0) :
               (need_y0[1:0]==2'd2) ? (line_valid2 && line_tag2==need_y0) :
                                      (line_valid3 && line_tag3==need_y0);
    wire lp1 = (need_y1[1:0]==2'd0) ? (line_valid0 && line_tag0==need_y1) :
               (need_y1[1:0]==2'd1) ? (line_valid1 && line_tag1==need_y1) :
               (need_y1[1:0]==2'd2) ? (line_valid2 && line_tag2==need_y1) :
                                      (line_valid3 && line_tag3==need_y1);
    wire lp2 = (need_y2[1:0]==2'd0) ? (line_valid0 && line_tag0==need_y2) :
               (need_y2[1:0]==2'd1) ? (line_valid1 && line_tag1==need_y2) :
               (need_y2[1:0]==2'd2) ? (line_valid2 && line_tag2==need_y2) :
                                      (line_valid3 && line_tag3==need_y2);
    wire lp3 = (need_y3[1:0]==2'd0) ? (line_valid0 && line_tag0==need_y3) :
               (need_y3[1:0]==2'd1) ? (line_valid1 && line_tag1==need_y3) :
               (need_y3[1:0]==2'd2) ? (line_valid2 && line_tag2==need_y3) :
                                      (line_valid3 && line_tag3==need_y3);

    wire all_lines_present = lp0 && lp1 && lp2 && lp3;
    wire [10:0] first_missing_row = !lp0 ? need_y0 :
                                    !lp1 ? need_y1 :
                                    !lp2 ? need_y2 : need_y3;

    // ------------------------------------------------------------------
    // Shared read/write AXI master. Writer wins only when a complete burst is
    // buffered; the reader receives the bus between raw-frame write bursts.
    // ------------------------------------------------------------------
    localparam [2:0] B_IDLE=0, B_WADDR=1, B_WDATA=2, B_WRESP=3,
                     B_RADDR=4, B_RDATA=5, B_WWAIT=6;
    reg [2:0] bus_state;
    reg [4:0] bus_beat;
    // write_burst_complete already declared earlier
    assign avalid = (bus_state==B_WADDR)||(bus_state==B_RADDR);
    assign aaddr = (bus_state==B_WADDR) ? wr_burst_addr :
                   read_frame_base + load_row*32'd2560 + load_burst_index*32'd256;
    assign aid = (bus_state==B_WADDR) ? 8'hD0 : 8'hD1;
    assign alen=8'd15; assign asize=3'd4; assign aburst=2'b01;
    assign alock=2'b00; assign atype=(bus_state==B_WADDR);
    assign wvalid=(bus_state==B_WDATA);
    assign wid=8'hD0; assign wdata=wr_burst_q;
    assign wstrb=16'hffff; assign wlast=(bus_beat==15);
    assign bready=(bus_state==B_WRESP);
    assign rready=(bus_state==B_RDATA);

    // One synchronous read port plus one write port per line bank.  Writes
    // only occur while a missing source row is fetched, at which time the
    // interpolation FSM is waiting for line_valid, so read/write collisions
    // are deliberately excluded by the controller.
    always @(posedge clk) begin
        line_q0 <= line0[cache_rd_addr];
        line_q1 <= line1[cache_rd_addr];
        line_q2 <= line2[cache_rd_addr];
        line_q3 <= line3[cache_rd_addr];
        if ((bus_state==B_RDATA) && rvalid) begin
            case(load_bank)
                0: line0[line_write_addr] <= rdata;
                1: line1[line_write_addr] <= rdata;
                2: line2[line_write_addr] <= rdata;
                3: line3[line_write_addr] <= rdata;
            endcase
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bus_state<=B_IDLE; bus_beat<=0; write_burst_complete<=0;
            wr_burst_q<=0;
            load_burst_index<=0; load_beat_index<=0;
            line_valid0<=0; line_valid1<=0; line_valid2<=0; line_valid3<=0;
            line_tag0<=0; line_tag1<=0; line_tag2<=0; line_tag3<=0;
            line_load_pending<=0; load_row<=0; load_bank<=0;
            axi_error_count<=0;
        end else begin
            write_burst_complete<=0;
            if (invalidate_line_cache) begin
                line_valid0<=0; line_valid1<=0;
                line_valid2<=0; line_valid3<=0;
            end
            if (request_line_load && !line_load_pending) begin
                load_row<=requested_row;
                load_bank<=requested_row[1:0];
                load_burst_index<=0;
                line_load_pending<=1;
            end
            case (bus_state)
                B_IDLE: begin
                    bus_beat<=0;
                    if (wr_burst_pending) bus_state<=B_WADDR;
                    else if (line_load_pending) bus_state<=B_RADDR;
                end
                B_WADDR: if (aready) begin
                    wr_burst_q<=wr_burst[0];
                    bus_state<=B_WDATA;
                end
                B_WDATA: if (wready) begin
                    if (bus_beat==15) bus_state<=B_WRESP;
                    else begin
                        bus_beat<=bus_beat+1'b1;
                        wr_burst_q<=wr_burst[bus_beat[3:0]+1'b1];
                    end
                end
                B_WRESP: if (bvalid) begin
                    if (bid!=8'hD0) axi_error_count<=axi_error_count+1'b1;
                    write_burst_complete<=1'b1; bus_state<=B_WWAIT;
                end
                // wr_burst_pending is cleared by the packer one cycle after
                // write_burst_complete.  Waiting here prevents the completed
                // burst address from being accepted a second time.
                B_WWAIT: if (!wr_burst_pending) bus_state<=B_IDLE;
                B_RADDR: if (aready) begin
                    load_beat_index<=0; bus_state<=B_RDATA;
                end
                B_RDATA: if (rvalid) begin
                    if (rresp!=0 || rid!=8'hD1) axi_error_count<=axi_error_count+1'b1;
                    if (rlast) begin
                        if (load_burst_index==9) begin
                            case(load_bank)
                                0: begin line_tag0<=load_row; line_valid0<=1; end
                                1: begin line_tag1<=load_row; line_valid1<=1; end
                                2: begin line_tag2<=load_row; line_valid2<=1; end
                                3: begin line_tag3<=load_row; line_valid3<=1; end
                            endcase
                            line_load_pending<=0; load_burst_index<=0;
                        end else load_burst_index<=load_burst_index+1'b1;
                        bus_state<=B_IDLE;
                    end else load_beat_index<=load_beat_index+1'b1;
                end
                default: bus_state<=B_IDLE;
            endcase
        end
    end

    // ------------------------------------------------------------------
    // Bicubic interpolation. Coordinates use Q11.16 accumulators.  The
    // static divisions occur once per output frame, not per pixel.
    // ------------------------------------------------------------------
    // Bicubic arithmetic has moved to the T120-derived T120BicubicKernel.
    // The frame buffer keeps the Q11.16 coordinate accumulator, the four
    // source-line caches and the 16-pixel window selection only.
    function [10:0] clamp_x;
        input signed [12:0] x;
        begin if(x<0)clamp_x=0;else if(x>1279)clamp_x=1279;else clamp_x=x[10:0];end
    endfunction
    // Q16 coordinate steps.  Reciprocal multiplication maps efficiently to
    // DSP48s; constant '/' generated a large LUT/add/subtract network.
    function [26:0] calc_step_x;
        input [10:0] size;
        reg [33:0] product;
        begin
            product=(size-1'b1)*22'd3358067; // approximately 2^32/1279
            calc_step_x={{10{1'b0}},product[32:16]};
        end
    endfunction
    function [26:0] calc_step_y;
        input [10:0] size;
        reg [33:0] product;
        begin
            product=(size-1'b1)*23'd4198405; // ceil(2^32/1023)
            calc_step_y={{10{1'b0}},product[32:16]};
        end
    endfunction
    // A 16-pixel window is prefetched from the synchronous line RAMs and is
    // reused until the monotonic source X coordinate crosses its boundary.
    // Bicubic tap selection is therefore only a mux over registers; it is no
    // longer an asynchronous multi-port read from the complete line memory.
    reg [127:0] window0_a,window0_b,window1_a,window1_b;
    reg [127:0] window2_a,window2_b,window3_a,window3_b;
    reg [7:0] window_word0,window_word1;
    reg window_valid;
    // x_acc, y_acc, step_x, step_y already declared at line 333
    reg [10:0] ox,oy;
    wire [10:0] sx= x_acc[26:16];
    wire [10:0] xx0=clamp_x($signed({1'b0,sx})-1);
    wire [10:0] xx1=sx;
    wire [10:0] xx2=clamp_x($signed({1'b0,sx})+1);
    wire [10:0] xx3=clamp_x($signed({1'b0,sx})+2);
    // Chroma taps stay on the same Cb/Cr parity as the output pixel.
    wire [10:0] cx1={sx[10:1],1'b0}|ox[0];
    wire [10:0] cx0=clamp_x($signed({1'b0,cx1})-2);
    wire [10:0] cx2=clamp_x($signed({1'b0,cx1})+2);
    wire [10:0] cx3=clamp_x($signed({1'b0,cx1})+4);
    wire [10:0] tap_min_x=(xx0<cx0)?xx0:cx0;
    wire [10:0] tap_max_x=(xx3>cx3)?xx3:cx3;
    wire [7:0] desired_word0=tap_min_x[10:3];
    wire [7:0] desired_word1=tap_max_x[10:3];
    wire window_matches=window_valid && window_word0==desired_word0 &&
                        window_word1==desired_word1;
    // Predict the following output pixel.  A narrow cached window must be
    // refreshed exactly when any of its Y/C bicubic taps crosses into a new
    // 128-bit line word; otherwise the remainder of the row reuses stale
    // pixels from the previous window.
    wire [26:0] next_x_acc=x_acc+step_x;
    wire [10:0] next_ox=ox+1'b1;
    wire [10:0] next_sx=next_x_acc[26:16];
    wire [10:0] next_xx0=clamp_x($signed({1'b0,next_sx})-1);
    wire [10:0] next_xx3=clamp_x($signed({1'b0,next_sx})+2);
    wire [10:0] next_cx1={next_sx[10:1],1'b0}|next_ox[0];
    wire [10:0] next_cx0=clamp_x($signed({1'b0,next_cx1})-2);
    wire [10:0] next_cx3=clamp_x($signed({1'b0,next_cx1})+4);
    wire [10:0] next_tap_min_x=(next_xx0<next_cx0)?next_xx0:next_cx0;
    wire [10:0] next_tap_max_x=(next_xx3>next_cx3)?next_xx3:next_cx3;
    wire [7:0] next_word0=next_tap_min_x[10:3];
    wire [7:0] next_word1=next_tap_max_x[10:3];
    wire next_window_matches=window_valid && window_word0==next_word0 &&
                             window_word1==next_word1;
    // Q10 fractional phases consumed by the T120-derived kernel.  x_acc and
    // y_acc stay in Q11.16, so the integer source coordinate remains
    // x_acc[26:16]/y_acc[26:16] and the top ten fraction bits are the Q10
    // phase the T120 kernel expects.
    wire [9:0] frac_x = x_acc[15:6];
    wire [9:0] frac_y = y_acc[15:6];

    // Assemble a T120BicubicKernel-compatible row-major 4x4 window.  Row 0 is
    // the top source row (multiplied by the y-1 tap) and column 0 is the left
    // source column (multiplied by the x-1 tap).
    // Pass the complete window set through the function arguments.  Reading
    // module registers only from inside a function omits them from some
    // simulators' continuous-assignment sensitivity sets, leaving y_matrix
    // and c_matrix stale after a synchronous window refill.
    wire [1023:0] window_bundle = {
        window3_b, window3_a, window2_b, window2_a,
        window1_b, window1_a, window0_b, window0_a
    };

    function [7:0] matrix_byte;
        input [1023:0] windows;
        input [7:0]    cached_word0;
        input [10:0] row_sel;
        input [10:0] tap;
        input        use_c;
        reg [15:0] pix;
        reg [127:0] wa, wb, q;
        begin
            case (row_sel[1:0])
                2'd0: begin wa=windows[127:0];   wb=windows[255:128]; end
                2'd1: begin wa=windows[383:256]; wb=windows[511:384]; end
                2'd2: begin wa=windows[639:512]; wb=windows[767:640]; end
                default: begin wa=windows[895:768]; wb=windows[1023:896]; end
            endcase
            q = (tap[10:3] == cached_word0) ? wa : wb;
            // Explicit slices prevent synthesis from constructing a 256-bit
            // variable barrel shifter for every bicubic tap.
            case (tap[2:0])
                3'h0: pix=q[15:0];    3'h1: pix=q[31:16];
                3'h2: pix=q[47:32];   3'h3: pix=q[63:48];
                3'h4: pix=q[79:64];   3'h5: pix=q[95:80];
                3'h6: pix=q[111:96]; default: pix=q[127:112];
            endcase
            matrix_byte = use_c ? pix[15:8] : pix[7:0];
        end
    endfunction

    function [127:0] yuv_matrix_4x4;
        input [1023:0] windows;
        input [7:0] cached_word0;
        input [10:0] r0, r1, r2, r3;
        input [10:0] t0, t1, t2, t3;
        input        use_c;
        integer      row, col;
        reg [10:0]   row_sel, tap;
        begin
            yuv_matrix_4x4 = 128'd0;
            for (row = 0; row < 4; row = row + 1) begin
                row_sel = (row == 0) ? r0 : (row == 1) ? r1 :
                          (row == 2) ? r2 : r3;
                for (col = 0; col < 4; col = col + 1) begin
                    tap = (col == 0) ? t0 : (col == 1) ? t1 :
                          (col == 2) ? t2 : t3;
                    yuv_matrix_4x4[(3-row)*32 + (3-col)*8 +: 8] =
                        matrix_byte(windows, cached_word0,
                                    row_sel, tap, use_c);
                end
            end
        end
    endfunction

    wire [127:0] y_matrix = yuv_matrix_4x4(
        window_bundle, window_word0,
        need_y0, need_y1, need_y2, need_y3,
        xx0, xx1, xx2, xx3, 1'b0);
    wire [127:0] c_matrix = yuv_matrix_4x4(
        window_bundle, window_word0,
        need_y0, need_y1, need_y2, need_y3,
        cx0, cx1, cx2, cx3, 1'b1);

    wire       y_kernel_valid, c_kernel_valid;
    wire [7:0] y_kernel_pixel, c_kernel_pixel;

    T120BicubicKernel u_y_kernel (
        .clk        (clk),
        .reset      (reset),
        .in_valid   (zstate == Z_TAPS),
        .matrix_4x4 (y_matrix),
        .frac_x     (frac_x),
        .frac_y     (frac_y),
        .out_valid  (y_kernel_valid),
        .out_pixel  (y_kernel_pixel)
    );

    T120BicubicKernel u_c_kernel (
        .clk        (clk),
        .reset      (reset),
        .in_valid   (zstate == Z_TAPS),
        .matrix_4x4 (c_matrix),
        .frac_x     (frac_x),
        .frac_y     (frac_y),
        .out_valid  (c_kernel_valid),
        .out_pixel  (c_kernel_pixel)
    );

    // Z_OUT itself is the output holding register.  Its coordinates and the
    // registered kernel results remain unchanged under back-pressure, so the
    // payload is stable without another wide bank of enabled registers.
    assign output_y = y_kernel_pixel;
    assign output_c = c_kernel_pixel;
    assign output_word = y_from_high ? {y_kernel_pixel,c_kernel_pixel} :
                                      {c_kernel_pixel,y_kernel_pixel};
    assign output_x = ox;
    assign output_line = oy;
    assign output_valid = (zstate == Z_OUT);
    assign output_sof = output_valid && (ox == 0) && (oy == 0);
    assign output_sol = output_valid && (ox == 0);
    assign output_eol = output_valid && (ox == 1279);
    assign output_eof = output_valid && (ox == 1279) && (oy == 1023);

    wire [10:0] requested_left   = zoom_enable_command ? roi_left_command   : 11'd0;
    wire [10:0] requested_top    = zoom_enable_command ? roi_top_command    : 11'd0;
    wire [10:0] requested_width  = zoom_enable_command ? roi_width_command  : 11'd1280;
    wire [10:0] requested_height = zoom_enable_command ? roi_height_command : 11'd1024;

    // debug_capture_state bit assignment:
    // [63:61] AXI state, [60:56] AXI beat, [55]/[51] write buffer MSB/LSB,
    // [54] capture active, [53] burst pending, [52] pending burst is EOF,
    // [50] committed valid, [49]/[48] committed buffer LSB/MSB,
    // [47:44] pack beat, [43:41] pack lane,
    // [40:20] input pixel index, [19:4] write epoch,
    // [3:0] AVALID/AREADY/WVALID/WREADY.
    assign debug_capture_state = {
        bus_state, bus_beat, write_buffer[1], capture_started,
        wr_burst_pending, wr_burst_is_eof, write_buffer[0],
        committed_valid, committed_buffer[0], committed_buffer[1],
        pack_beat, pack_lane, input_pixel_index, wr_epoch,
        avalid, aready, wvalid, wready
    };

    // debug_calculator_state bit assignment:
    // [103:100]/[99:96] X/Y Q10 phase[9:6],
    // [95:92] zoom FSM, [91] active, [90] output ready, [89] output valid,
    // [88] line load pending, [87] load request, [86] all rows cached,
    // [85] pixel window valid, [84:81] cache-bank valid bits,
    // [80:70] output X, [69:59] output Y, [58:48] source X,
    // [47:37] source Y, [36:26] row being loaded,
    // [25:22] row burst, [21:18] row beat, [17:10]/[9:2] window words,
    // [1] a newer captured frame exists, [0] cache invalidate pulse.
    assign debug_calculator_state = {
        x_acc[15:12], y_acc[15:12],
        zstate, active_zoom, output_ready, output_valid,
        line_load_pending, request_line_load, all_lines_present, window_valid,
        line_valid3, line_valid2, line_valid1, line_valid0,
        ox, oy, sx, sy_int, load_row, load_burst_index, load_beat_index,
        window_word0, window_word1, (read_epoch != wr_epoch),
        invalidate_line_cache
    };

    assign debug_line_tags = {line_tag3, line_tag2, line_tag1, line_tag0};
    assign debug_line_present = {lp3, lp2, lp1, lp0};
    assign debug_need_rows = {first_missing_row, need_y3, need_y2, need_y1, need_y0};

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            zstate<=Z_WAIT; x_acc<=0;y_acc<=0;step_x<=27'd65536;step_y<=27'd65536;
            ox<=0;oy<=0;
            zoom_output_frame_count<=0; active_zoom<=0;active_left<=0;active_top<=0;
            active_width<=1280;active_height<=1024;
            read_frame_base<=FRAME_A_BASE;read_buffer<=0;read_epoch<=0;
            request_line_load<=0;invalidate_line_cache<=0;requested_row<=0;
            cache_rd_addr<=0;window_word0<=0;window_word1<=0;window_valid<=0;
            // Window contents are don't-care while window_valid is low.  Do
            // not reset these 1024 datapath FFs: removing a needless reset
            // control set materially improves Efinity cluster packing.
        end else begin
            request_line_load<=0;
            invalidate_line_cache<=0;

            case(zstate)
              Z_WAIT: begin
                if(committed_valid && in_take && in_fifo_data[19]) begin
                    active_zoom<=zoom_enable_command;
                    active_left<=requested_left;active_top<=requested_top;
                    active_width<=requested_width;active_height<=requested_height;
                    step_x<=calc_step_x(requested_width);
                    step_y<=calc_step_y(requested_height);
                    x_acc<={requested_left,16'd0};y_acc<={requested_top,16'd0};
                    ox<=0;oy<=0;
                    read_buffer<=committed_buffer;
                    read_frame_base<=source_frame_base(committed_buffer);
                    read_epoch<=wr_epoch;zstate<=Z_CHECK;
                    invalidate_line_cache<=1;window_valid<=0;
                end
              end
              Z_CHECK: begin
                if(all_lines_present) begin
                    if(window_matches) zstate<=Z_TAPS;
                    else begin
                        cache_rd_addr<=desired_word0;
                        window_word0<=desired_word0;
                        window_word1<=desired_word1;
                        zstate<=Z_RD0_WAIT;
                    end
                end
                else if(!line_load_pending) begin
                    requested_row<=first_missing_row;
                    request_line_load<=1;
                end
              end
              // Synchronous RAM latency is made explicit.  RD*_WAIT lets the
              // RAM output register update; RD*_CAPTURE consumes that output.
              Z_RD0_WAIT: zstate<=Z_RD0_CAPTURE;
              Z_RD0_CAPTURE: begin
                window0_a<=line_q0;window1_a<=line_q1;
                window2_a<=line_q2;window3_a<=line_q3;
                cache_rd_addr<=window_word1;
                zstate<=Z_RD1_WAIT;
              end
              Z_RD1_WAIT: zstate<=Z_RD1_CAPTURE;
              Z_RD1_CAPTURE: begin
                window0_b<=line_q0;window1_b<=line_q1;
                window2_b<=line_q2;window3_b<=line_q3;
                window_valid<=1;
                zstate<=Z_TAPS;
              end
              Z_TAPS: begin
                // The kernels latch matrix_4x4/frac_x/frac_y on this cycle.
                zstate<=Z_VERT;
              end
              Z_VERT: begin
                // T120BicubicKernel has one register stage here.
                zstate<=Z_OUT;
              end
              Z_OUT: begin
                // output_valid is already visible for this entire state;
                // advance only on the corresponding ready handshake.
                if(output_ready && ox==1279) begin
                    ox<=0;x_acc<={active_left,16'd0};
                    if(oy==1023) begin
                        oy<=0;zoom_output_frame_count<=zoom_output_frame_count+1'b1;
                        window_valid<=0;
                        active_zoom<=zoom_enable_command;
                        active_left<=requested_left;active_top<=requested_top;
                        active_width<=requested_width;active_height<=requested_height;
                        step_x<=calc_step_x(requested_width);
                        step_y<=calc_step_y(requested_height);
                        y_acc<={requested_top,16'd0};
                        if(read_epoch!=wr_epoch) begin
                            read_buffer<=committed_buffer;
                            read_frame_base<=source_frame_base(committed_buffer);
                            read_epoch<=wr_epoch;
                            invalidate_line_cache<=1;
                        end
                        zstate<=Z_CHECK;
                    end else begin
                        oy<=oy+1'b1;y_acc<=y_acc+step_y;
                        window_valid<=0;zstate<=Z_CHECK;
                    end
                end else if(output_ready) begin
                    ox<=next_ox;
                    x_acc<=next_x_acc;
                    zstate<=next_window_matches ? Z_TAPS : Z_CHECK;
                end
              end
              default:zstate<=Z_WAIT;
            endcase
        end
    end
endmodule
