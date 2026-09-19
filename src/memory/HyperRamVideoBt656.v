// 16-bit YUV422 frame DMA for the dual-HyperRAM video path.
// Stores three 720x576 frames as {C,Y} pixels.  One buffer is displayed, one
// may hold the latest complete frame, and the third remains available to the
// writer while the design waits for a PAL frame boundary.
module HyperRamVideoBt656 #(
    parameter [31:0] FRAME0_BASE = 32'h00C0_0000,
    parameter [31:0] FRAME1_BASE = 32'h00D0_0000,
    parameter [31:0] FRAME2_BASE = 32'h00E0_0000,
    parameter integer BURST_LEN = 16,
    parameter integer RFIFO_AW = 5,
    // Horizontal reversal is performed before overlays.  Store live-video
    // rows upside down here to complete the 180-degree background rotation.
    parameter integer FLIP_LIVE_VIDEO_VERTICAL = 0
) (
    input  wire         axi_clk,
    input  wire         axi_resetn,
    input  wire         start,
    input  wire [15:0]  pixel_in,
    input  wire         pixel_in_valid,
    input  wire         pixel_in_sof,
    input  wire         pixel_in_eol,
    output wire         pixel_in_ready,
    input  wire         input_error,
    input  wire         integrity_clear,

    input  wire         pixel_clk,
    input  wire         pixel_reset,

    output wire [7:0]   aid,
    output wire [31:0]  aaddr,
    output wire [7:0]   alen,
    output wire [2:0]   asize,
    output wire [1:0]   aburst,
    output wire [1:0]   alock,
    output wire         avalid,
    input  wire         aready,
    output wire         atype,
    output wire [7:0]   wid,
    output wire [127:0] wdata,
    output wire [15:0]  wstrb,
    output wire         wlast,
    output wire         wvalid,
    input  wire         wready,
    input  wire [7:0]   rid,
    input  wire [127:0] rdata,
    input  wire         rlast,
    input  wire         rvalid,
    output wire         rready,
    input  wire [1:0]   rresp,
    input  wire [7:0]   bid,
    input  wire         bvalid,
    output wire         bready,

    output reg          frame_good,
    output reg          frame_error,
    output reg [15:0]   read_fifo_underflow_count,
    output reg [15:0]   frame_switch_count,
    output reg [15:0]   rejected_sof_count,
    output reg [15:0]   pal_frame_boundary_count,
    // Passive per-frame integrity diagnostics.  In dual-HyperRAM mode the
    // lower and upper 64-bit halves correspond to the two memory lanes.
    output reg [31:0]   integrity_checked_frames,
    output reg [31:0]   integrity_low64_errors,
    output reg [31:0]   integrity_high64_errors,
    output reg          integrity_first_error_valid,
    output reg [31:0]   integrity_first_error_addr,
    output reg [15:0]   integrity_first_expected_low64,
    output reg [15:0]   integrity_first_actual_low64,
    output reg [15:0]   integrity_first_expected_high64,
    output reg [15:0]   integrity_first_actual_high64,
    output wire [2:0]   integrity_buffer_valid,
    output reg          integrity_last_low64_mismatch,
    output reg          integrity_last_high64_mismatch,
    output reg [9:0]    integrity_read_line,
    output wire [1:0]   integrity_display_buffer,
    output wire [7:0]   bt656_data,
    output wire         bt656_vsync,
    output wire         bt656_lsync
);
    localparam integer PIXELS = 720*576;
    localparam integer PIXELS_PER_BEAT = 8;
    localparam integer FRAME_BEATS = PIXELS/PIXELS_PER_BEAT;
    localparam integer LAST_BEAT = FRAME_BEATS-1;
    localparam integer BURST_BYTES = BURST_LEN*16;

    localparam [3:0] ST_WAIT = 0, ST_INIT_A = 1, ST_INIT_W = 2,
                     ST_RUN = 3, ST_W_A = 4, ST_W_D = 5,
                     ST_R_A = 6, ST_R_D = 7;
    reg [3:0] state;
    reg [31:0] address;
    reg [4:0] burst_beat;

    assign aid=0; assign wid=0; assign aaddr=address;
    // The power-on pattern is written as ordinary 16-beat bursts.  Live
    // video is stored in PAL field order, so a burst must stop at the end of
    // each 720-pixel (90 AXI-beat) source line before the address jumps to
    // the even- or odd-field region.
    reg [4:0] video_burst_len;
    assign alen=((state==ST_W_A)||(state==ST_W_D)) ?
                (video_burst_len-1'b1) : (BURST_LEN-1);
    assign asize=3'd4;
    assign aburst=2'b01; assign alock=0;
    assign avalid=(state==ST_INIT_A)||(state==ST_W_A)||(state==ST_R_A);
    assign atype=(state==ST_INIT_A)||(state==ST_W_A);
    assign wstrb=16'hffff;
    assign wlast=(state==ST_W_D) ?
                 (burst_beat==video_burst_len-1'b1) :
                 (burst_beat==BURST_LEN-1);
    assign wvalid=(state==ST_INIT_W)||(state==ST_W_D);
    // Always consume AXI write responses.  Holding BREADY low can leave a
    // response permanently outstanding and eventually stall later writes.
    assign bready=1'b1;

    // ------------------------------------------------------------------
    // Tiny generated power-on test pattern. It replaces the 204-BRAM image
    // ROM while retaining a deterministic CVBS diagnostic before BT.1120 is
    // present.
    // ------------------------------------------------------------------
    reg [16:0] init_beat;
    reg [9:0] test_x;
    reg [9:0] test_y;
    function [15:0] test_pixel;
        input [9:0] x;
        input [9:0] y;
        reg [7:0] yy, cb, cr;
        begin
            if      (x <  90) begin yy=235; cb=128; cr=128; end
            else if (x < 180) begin yy=210; cb=16;  cr=146; end
            else if (x < 270) begin yy=170; cb=166; cr=16;  end
            else if (x < 360) begin yy=145; cb=54;  cr=34;  end
            else if (x < 450) begin yy=106; cb=202; cr=222; end
            else if (x < 540) begin yy=81;  cb=90;  cr=240; end
            else if (x < 630) begin yy=41;  cb=240; cr=110; end
            else              begin yy=16;  cb=128; cr=128; end
            test_pixel = {x[0] ? cr : cb, yy};
        end
    endfunction
    function [127:0] test_word;
        input [9:0] x;
        input [9:0] y;
        integer n;
        begin
            for(n=0;n<8;n=n+1)
                test_word[n*16 +: 16] = test_pixel(x+n,y);
        end
    endfunction

    function [31:0] frame_base;
        input [1:0] buffer_index;
        begin
            case(buffer_index)
                2'd0: frame_base = FRAME0_BASE;
                2'd1: frame_base = FRAME1_BASE;
                default: frame_base = FRAME2_BASE;
            endcase
        end
    endfunction

    // Return the member of {0,1,2} that is different from both arguments.
    // The caller guarantees that buffer_a and buffer_b are different.
    function [1:0] third_buffer;
        input [1:0] buffer_a;
        input [1:0] buffer_b;
        begin
            if((buffer_a != 2'd0) && (buffer_b != 2'd0))
                third_buffer = 2'd0;
            else if((buffer_a != 2'd1) && (buffer_b != 2'd1))
                third_buffer = 2'd1;
            else
                third_buffer = 2'd2;
        end
    endfunction

    // Convert the synchronized read pointer back to binary in the AXI clock
    // domain.  The two-flop synchronizer can only make the observed pointer
    // stale, so the resulting free-space estimate is conservative.
    function [RFIFO_AW:0] gray_to_bin;
        input [RFIFO_AW:0] gray;
        integer bit_index;
        begin
            gray_to_bin[RFIFO_AW] = gray[RFIFO_AW];
            for(bit_index=RFIFO_AW-1; bit_index>=0; bit_index=bit_index-1)
                gray_to_bin[bit_index] = gray_to_bin[bit_index+1] ^
                                         gray[bit_index];
        end
    endfunction

    // ------------------------------------------------------------------
    // Scaler output packer and 32-beat write queue. A complete burst is
    // collected before it owns the shared AXI bus, so frame reads cannot be
    // starved by the relatively sparse scaler stream.
    // ------------------------------------------------------------------
    reg [127:0] pack_data;
    reg [2:0] pack_count;
    reg [18:0] frame_pixel_count;
    reg capture_frame;
    reg write_frame_active;
    reg [1:0] write_buffer;
    reg [16:0] write_sent;
    reg [9:0] write_line;
    reg [6:0] write_line_beat;

    // The PAL formatter consumes 288 active lines with F=0, followed by
    // 288 active lines with F=1.  A progressive frame therefore has to be
    // laid out as even source lines first, then odd source lines:
    //   memory line 0..287   = source line 0,2,...,574
    //   memory line 288..575 = source line 1,3,...,575
    // Reading the frame linearly then supplies the correct two PAL fields.
    wire [9:0] write_target_line = FLIP_LIVE_VIDEO_VERTICAL ?
                                   (10'd575-write_line) : write_line;
    wire [9:0] write_field_line = {1'b0,write_target_line[9:1]} +
                                  (write_target_line[0] ? 10'd288 : 10'd0);
    wire [31:0] write_field_offset =
        ({22'd0,write_field_line} << 10) +
        ({22'd0,write_field_line} << 8)  +
        ({22'd0,write_field_line} << 7)  +
        ({22'd0,write_field_line} << 5)  +
        ({25'd0,write_line_beat} << 4);
    wire [7:0] write_beats_to_eol = 8'd90-{1'b0,write_line_beat};
    wire [4:0] next_video_burst_len =
        (write_beats_to_eol >= BURST_LEN) ? BURST_LEN[4:0] :
                                            write_beats_to_eol[4:0];

    reg         wq_last[0:31];
    reg [5:0] wq_count;
    reg [4:0] wq_wptr, wq_rptr;

    // The write queue data is block-RAM backed.  EFX_RAM10 has a one-cycle
    // synchronous read, so while the current word is accepted we address the
    // following word.  This keeps the next AXI beat available without adding
    // a bubble; during a stall the current address and data remain selected.
    wire [127:0] wq_read_data;

    reg frame_pending;
    reg [1:0] pending_buffer;
    reg [1:0] display_buffer;
    reg display_valid;
    reg read_frame_complete;
    reg pal_boundary_pending;

    // The PAL formatter consumes a complete 720x576 source frame in the
    // pixel domain.  A toggle crosses that event back to the AXI domain so
    // the reader never starts/switches the next memory frame mid-PAL-frame.
    reg output_frame_toggle;
    (* async_reg="true" *) reg pal_toggle_a1, pal_toggle_a2;
    reg pal_toggle_seen;
    wire pal_frame_boundary_axi = pal_toggle_a2 ^ pal_toggle_seen;

    // ------------------------------------------------------------------
    // Passive HyperRAM data-integrity checker.
    //
    // Live video data is not known in advance, so each completed write frame
    // stores an order-independent 16-bit folded XOR signature for each half
    // of the
    // 128-bit AXI word.  The linear readback path recomputes the signatures
    // and compares them at the end of the corresponding frame.  There are
    // only three signature slots (one per video buffer), which deliberately
    // avoids a large multi-ported inferred memory.  This adds no AXI traffic
    // and therefore does not hide a marginal RAM timing problem by changing
    // the external-memory access pattern.
    // ------------------------------------------------------------------
    reg [15:0] frame_hash_low0, frame_hash_low1, frame_hash_low2;
    reg [15:0] frame_hash_high0, frame_hash_high1, frame_hash_high2;
    reg [2:0]  frame_hash_buffer_valid;
    reg [15:0] init_frame_hash_low, init_frame_hash_high;
    reg [15:0] write_frame_hash_low, write_frame_hash_high;
    reg [15:0] read_frame_hash_low, read_frame_hash_high;
    reg [6:0]  integrity_read_line_beat;

    wire [15:0] expected_frame_hash_low =
        (display_buffer==2'd0) ? frame_hash_low0 :
        (display_buffer==2'd1) ? frame_hash_low1 : frame_hash_low2;
    wire [15:0] expected_frame_hash_high =
        (display_buffer==2'd0) ? frame_hash_high0 :
        (display_buffer==2'd1) ? frame_hash_high1 : frame_hash_high2;
    // Fold each 64-bit lane to 16 bits before accumulation.  This keeps the
    // diagnostic fanout small in the marginal 200 MHz AXI domain.
    wire [15:0] wdata_low_fold = wdata[15:0] ^ wdata[31:16] ^
                                 wdata[47:32] ^ wdata[63:48];
    wire [15:0] wdata_high_fold = wdata[79:64] ^ wdata[95:80] ^
                                  wdata[111:96] ^ wdata[127:112];
    wire [15:0] rdata_low_fold = rdata[15:0] ^ rdata[31:16] ^
                                 rdata[47:32] ^ rdata[63:48];
    wire [15:0] rdata_high_fold = rdata[79:64] ^ rdata[95:80] ^
                                  rdata[111:96] ^ rdata[127:112];
    wire [15:0] read_frame_hash_low_next =
        read_frame_hash_low ^ rdata_low_fold;
    wire [15:0] read_frame_hash_high_next =
        read_frame_hash_high ^ rdata_high_fold;

    assign integrity_buffer_valid = frame_hash_buffer_valid;
    assign integrity_display_buffer = display_buffer;

    // A pending complete frame no longer blocks capture.  With three buffers,
    // write_buffer remains distinct from the displayed and pending buffers.
    wire can_start_frame = display_valid && !write_frame_active &&
                           (write_buffer != display_buffer) &&
                           (!frame_pending || (write_buffer != pending_buffer));
    assign pixel_in_ready = !capture_frame || (wq_count < 31);
    wire input_take = pixel_in_valid && pixel_in_ready;
    wire pack_take = input_take && (capture_frame ||
                                    (pixel_in_sof && can_start_frame));
    wire wq_push = pack_take && capture_frame && (pack_count==3'd7);
    wire [127:0] wq_push_data = {pixel_in,pack_data[127:16]};
    wire wq_push_last = (frame_pixel_count == PIXELS-1);
    wire wq_pop = (state==ST_W_D) && wready;
    wire [4:0] wq_read_addr = wq_rptr + (wq_pop ? 1'b1 : 1'b0);

    EfxFifoStorage128x32 u_write_queue_storage (
        .wr_clk(axi_clk),
        .wr_en(wq_push),
        .wr_addr(wq_wptr),
        .wr_data(wq_push_data),
        .rd_clk(axi_clk),
        .rd_en(1'b1),
        .rd_addr(wq_read_addr),
        .rd_data(wq_read_data)
    );

    // ------------------------------------------------------------------
    // AXI read FIFO to 27 MHz. Each 128-bit word contains eight {C,Y} pixels.
    // ------------------------------------------------------------------
    localparam integer RDEPTH=(1<<RFIFO_AW);
    reg [RFIFO_AW:0] rwr_bin,rwr_gray,rrd_bin,rrd_gray;
    (* async_reg="true" *) reg [RFIFO_AW:0] rrd_g1,rrd_g2,rwr_g1,rwr_g2;
    wire [RFIFO_AW:0] rwr_next=rwr_bin+1'b1;
    wire [RFIFO_AW:0] rwr_gray_next=(rwr_next>>1)^rwr_next;
    wire rfifo_full=(rwr_gray_next=={~rrd_g2[RFIFO_AW:RFIFO_AW-1],rrd_g2[RFIFO_AW-2:0]});
    wire rfifo_empty=(rrd_gray==rwr_g2);
    wire [RFIFO_AW:0] rrd_bin_axi=gray_to_bin(rrd_g2);
    wire [RFIFO_AW:0] rfifo_used_axi=rwr_bin-rrd_bin_axi;
    localparam [RFIFO_AW:0] RFIFO_DEPTH_COUNT=(1<<RFIFO_AW);
    localparam [RFIFO_AW:0] READ_BURST_COUNT=BURST_LEN;
    wire [RFIFO_AW:0] rfifo_free_axi=RFIFO_DEPTH_COUNT-rfifo_used_axi;
    wire rfifo_can_accept_burst=(rfifo_free_axi>=READ_BURST_COUNT);
    // Once AR is accepted, consume the complete burst without propagating the
    // 27 MHz pixel FIFO's backpressure into the shared 100 MHz memory fabric.
    assign rready=(state==ST_R_D);
    wire read_fire=rvalid&&rready;

    reg [16:0] read_index;

    assign wdata=(state==ST_INIT_W)?test_word(test_x,test_y):wq_read_data;

    always @(posedge axi_clk or negedge axi_resetn) begin
        if(!axi_resetn) begin
            state<=ST_WAIT; address<=FRAME0_BASE; burst_beat<=0;
            video_burst_len<=BURST_LEN[4:0];
            init_beat<=0; test_x<=0; test_y<=0;
            pack_data<=0; pack_count<=0; frame_pixel_count<=0;
            capture_frame<=0; write_frame_active<=0; write_buffer<=2'd1;
            write_sent<=0; write_line<=0; write_line_beat<=0;
            wq_count<=0; wq_wptr<=0; wq_rptr<=0;
            frame_pending<=0; pending_buffer<=0; display_buffer<=0;
            display_valid<=0; read_index<=0; read_frame_complete<=0;
            pal_boundary_pending<=0;
            pal_toggle_a1<=0; pal_toggle_a2<=0; pal_toggle_seen<=0;
            frame_switch_count<=0; rejected_sof_count<=0;
            pal_frame_boundary_count<=0;
            rwr_bin<=0; rwr_gray<=0; rrd_g1<=0; rrd_g2<=0;
            frame_good<=0; frame_error<=0;
            frame_hash_low0<=0; frame_hash_low1<=0; frame_hash_low2<=0;
            frame_hash_high0<=0; frame_hash_high1<=0; frame_hash_high2<=0;
            frame_hash_buffer_valid<=3'b000;
            init_frame_hash_low<=0; init_frame_hash_high<=0;
            write_frame_hash_low<=0; write_frame_hash_high<=0;
            read_frame_hash_low<=0; read_frame_hash_high<=0;
            integrity_read_line_beat<=0; integrity_read_line<=0;
            integrity_checked_frames<=0;
            integrity_low64_errors<=0; integrity_high64_errors<=0;
            integrity_first_error_valid<=0;
            integrity_first_error_addr<=0;
            integrity_first_expected_low64<=0;
            integrity_first_actual_low64<=0;
            integrity_first_expected_high64<=0;
            integrity_first_actual_high64<=0;
            integrity_last_low64_mismatch<=0;
            integrity_last_high64_mismatch<=0;
        end else begin
            rrd_g1<=rrd_gray; rrd_g2<=rrd_g1;
            pal_toggle_a1<=output_frame_toggle;
            pal_toggle_a2<=pal_toggle_a1;
            pal_toggle_seen<=pal_toggle_a2;
            if(pal_frame_boundary_axi) begin
                pal_boundary_pending<=1'b1;
                pal_frame_boundary_count<=pal_frame_boundary_count+1'b1;
            end
            if(input_error) frame_error<=1'b1;
            if(integrity_clear) begin
                integrity_checked_frames<=0;
                integrity_low64_errors<=0;
                integrity_high64_errors<=0;
                integrity_first_error_valid<=0;
                integrity_first_error_addr<=0;
                integrity_first_expected_low64<=0;
                integrity_first_actual_low64<=0;
                integrity_first_expected_high64<=0;
                integrity_first_actual_high64<=0;
                integrity_last_low64_mismatch<=0;
                integrity_last_high64_mismatch<=0;
            end

            // Input frame admission and packing.
            if(input_take) begin
                if(!capture_frame) begin
                    if(pixel_in_sof) begin
                        if(can_start_frame) begin
                            capture_frame<=1'b1;
                            write_frame_active<=1'b1;
                            frame_pixel_count<=1;
                            pack_count<=1;
                             pack_data<={pixel_in,112'd0};
                             write_sent<=0;
                            write_line<=0;
                            write_line_beat<=0;
                        end else begin
                            rejected_sof_count<=rejected_sof_count+1'b1;
                        end
                    end
                end else begin
                    if(pixel_in_sof) begin
                        frame_error<=1'b1;
                        rejected_sof_count<=rejected_sof_count+1'b1;
                    end
                    frame_pixel_count<=frame_pixel_count+1'b1;
                    pack_data<={pixel_in,pack_data[127:16]};
                    if(pack_count==7) begin
                        pack_count<=0;
                        if(frame_pixel_count==PIXELS-1)
                            capture_frame<=1'b0;
                    end else pack_count<=pack_count+1'b1;
                end
            end
            if(wq_push) begin
                wq_last[wq_wptr]<=wq_push_last;
                wq_wptr<=wq_wptr+1'b1;
            end
            if(wq_pop) wq_rptr<=wq_rptr+1'b1;
            case({wq_push,wq_pop})
                2'b10:wq_count<=wq_count+1'b1;
                2'b01:wq_count<=wq_count-1'b1;
                default:wq_count<=wq_count;
            endcase

            case(state)
                ST_WAIT: if(start) begin
                    address<=FRAME0_BASE; init_beat<=0; burst_beat<=0;
                    test_x<=0; test_y<=0; state<=ST_INIT_A;
                end
                ST_INIT_A: if(aready) begin burst_beat<=0; state<=ST_INIT_W; end
                ST_INIT_W: if(wready) begin
                    init_frame_hash_low<=init_frame_hash_low^wdata_low_fold;
                    init_frame_hash_high<=init_frame_hash_high^wdata_high_fold;
                    init_beat<=init_beat+1'b1;
                    if(test_x==712) begin test_x<=0; test_y<=test_y+1'b1; end
                    else test_x<=test_x+8;
                    if(init_beat==LAST_BEAT) begin
                        frame_hash_low0<=init_frame_hash_low^wdata_low_fold;
                        frame_hash_high0<=init_frame_hash_high^wdata_high_fold;
                        display_valid<=1'b1; display_buffer<=2'd0;
                        frame_hash_buffer_valid[0]<=1'b1;
                        write_buffer<=2'd1; frame_good<=1'b1;
                        read_index<=0; state<=ST_RUN;
                    end else if(burst_beat==BURST_LEN-1) begin
                        address<=address+BURST_BYTES; burst_beat<=0; state<=ST_INIT_A;
                    end else burst_beat<=burst_beat+1'b1;
                end
                ST_RUN: begin
                    if(read_frame_complete && pal_boundary_pending) begin
                        read_frame_complete<=1'b0;
                        pal_boundary_pending<=1'b0;
                        read_index<=0;
                        if(frame_pending) begin
                            display_buffer<=pending_buffer;
                            // Do not redirect an in-progress write.  When no
                            // write is active, the old display buffer is free.
                            if(!write_frame_active)
                                write_buffer<=display_buffer;
                            frame_pending<=1'b0;
                            frame_good<=1'b1;
                            frame_switch_count<=frame_switch_count+1'b1;
                        end
                    end else if(wq_count>=next_video_burst_len) begin
                        address<=frame_base(write_buffer)+write_field_offset;
                        video_burst_len<=next_video_burst_len;
                        burst_beat<=0; state<=ST_W_A;
                    end else if(display_valid && !read_frame_complete &&
                                rfifo_can_accept_burst) begin
                        address<=frame_base(display_buffer)+{read_index,4'b0000};
                        burst_beat<=0; state<=ST_R_A;
                    end
                end
                ST_W_A: if(aready) begin burst_beat<=0; state<=ST_W_D; end
                ST_W_D: if(wready) begin
                    write_frame_hash_low<=write_frame_hash_low^wdata_low_fold;
                    write_frame_hash_high<=write_frame_hash_high^wdata_high_fold;
                    write_sent<=write_sent+1'b1;
                    if(write_line_beat==7'd89) begin
                        write_line_beat<=0;
                        if(write_line==10'd575)
                            write_line<=0;
                        else
                            write_line<=write_line+1'b1;
                    end else begin
                        write_line_beat<=write_line_beat+1'b1;
                    end
                    if(wq_last[wq_rptr]) begin
                        case(write_buffer)
                            2'd0: begin
                                frame_hash_low0<=write_frame_hash_low^wdata_low_fold;
                                frame_hash_high0<=write_frame_hash_high^wdata_high_fold;
                            end
                            2'd1: begin
                                frame_hash_low1<=write_frame_hash_low^wdata_low_fold;
                                frame_hash_high1<=write_frame_hash_high^wdata_high_fold;
                            end
                            default: begin
                                frame_hash_low2<=write_frame_hash_low^wdata_low_fold;
                                frame_hash_high2<=write_frame_hash_high^wdata_high_fold;
                            end
                        endcase
                        frame_hash_buffer_valid[write_buffer]<=1'b1;
                        write_frame_hash_low<=0;
                        write_frame_hash_high<=0;
                        // Publish the newest complete frame.  If an older
                        // complete frame is still pending, replace it and
                        // immediately recycle that old pending buffer.
                        if(frame_pending) begin
                            pending_buffer<=write_buffer;
                            write_buffer<=pending_buffer;
                        end else begin
                            frame_pending<=1'b1;
                            pending_buffer<=write_buffer;
                            write_buffer<=third_buffer(display_buffer,
                                                       write_buffer);
                        end
                        write_line<=0;
                        write_line_beat<=0;
                        write_frame_active<=1'b0; burst_beat<=0; state<=ST_RUN;
                    end else if(burst_beat==video_burst_len-1'b1) begin
                        burst_beat<=0; state<=ST_RUN;
                    end else burst_beat<=burst_beat+1'b1;
                end
                ST_R_A: if(aready) begin burst_beat<=0; state<=ST_R_D; end
                ST_R_D: if(read_fire) begin
                    read_frame_hash_low<=read_frame_hash_low_next;
                    read_frame_hash_high<=read_frame_hash_high_next;
                    if(integrity_read_line_beat==7'd89) begin
                        integrity_read_line_beat<=0;
                        if(integrity_read_line==10'd575)
                            integrity_read_line<=0;
                        else
                            integrity_read_line<=integrity_read_line+1'b1;
                    end else begin
                        integrity_read_line_beat<=integrity_read_line_beat+1'b1;
                    end
                    if(read_index==LAST_BEAT) begin
                        read_frame_hash_low<=0;
                        read_frame_hash_high<=0;
                        if(frame_hash_buffer_valid[display_buffer]) begin
                            integrity_checked_frames<=integrity_checked_frames+1'b1;
                            integrity_last_low64_mismatch<=
                                (read_frame_hash_low_next!=expected_frame_hash_low);
                            integrity_last_high64_mismatch<=
                                (read_frame_hash_high_next!=expected_frame_hash_high);
                            if(read_frame_hash_low_next!=expected_frame_hash_low) begin
                                integrity_low64_errors<=integrity_low64_errors+1'b1;
                            end
                            if(read_frame_hash_high_next!=expected_frame_hash_high) begin
                                integrity_high64_errors<=integrity_high64_errors+1'b1;
                            end
                            if(!integrity_first_error_valid &&
                               ((read_frame_hash_low_next!=expected_frame_hash_low) ||
                                (read_frame_hash_high_next!=expected_frame_hash_high))) begin
                                integrity_first_error_valid<=1'b1;
                                integrity_first_error_addr<=frame_base(display_buffer);
                                integrity_first_expected_low64<=expected_frame_hash_low;
                                integrity_first_actual_low64<=read_frame_hash_low_next;
                                integrity_first_expected_high64<=expected_frame_hash_high;
                                integrity_first_actual_high64<=read_frame_hash_high_next;
                            end
                        end
                    end
                    rwr_bin<=rwr_next; rwr_gray<=rwr_gray_next;
                    if(rresp!=0) frame_error<=1'b1;
                    if(read_index==LAST_BEAT) begin
                        read_index<=0;
                        read_frame_complete<=1'b1;
                        state<=ST_RUN;
                    end else begin
                        read_index<=read_index+1'b1;
                        if(rlast || burst_beat==BURST_LEN-1) begin burst_beat<=0; state<=ST_RUN; end
                        else burst_beat<=burst_beat+1'b1;
                    end
                end
                default:state<=ST_WAIT;
            endcase
        end
    end

    // Pixel-domain serializer.
    reg [127:0] beat_shift;
    reg [3:0] pixels_left;
    reg load_pending;
    reg [9:0] px,py;
    reg [7:0] axis_y,axis_c;
    reg axis_valid,axis_user,axis_last,axis_frame_last;
    reg output_stream_active;
    reg underflow_latched;
    wire axis_ready;
    wire axis_take=!axis_valid||axis_ready;
    wire axis_handshake=axis_valid&&axis_ready;

    // AXI-to-pixel storage uses independent EFX_RAM10 clocks.  The existing
    // load_pending state is intentionally retained: it is the latency stage
    // between asserting rfifo_ram_rd_en and consuming the synchronous BRAM
    // output in the pixel clock domain.
    wire [127:0] rfifo_read_data;
    wire rfifo_ram_rd_en = axis_take && (pixels_left==0) &&
                           !load_pending && !rfifo_empty;

    EfxFifoStorage128x32 u_read_fifo_storage (
        .wr_clk(axi_clk),
        .wr_en(read_fire),
        .wr_addr(rwr_bin[RFIFO_AW-1:0]),
        .wr_data(rdata),
        .rd_clk(pixel_clk),
        .rd_en(rfifo_ram_rd_en),
        .rd_addr(rrd_bin[RFIFO_AW-1:0]),
        .rd_data(rfifo_read_data)
    );

    always @(posedge pixel_clk or posedge pixel_reset) begin
        if(pixel_reset) begin
            rrd_bin<=0; rrd_gray<=0; rwr_g1<=0; rwr_g2<=0;
            beat_shift<=0; pixels_left<=0; load_pending<=0;
            px<=0;py<=0;axis_y<=16;axis_c<=128;
            axis_valid<=0;axis_user<=0;axis_last<=0;axis_frame_last<=0;
            output_frame_toggle<=0; output_stream_active<=0;
            underflow_latched<=0; read_fifo_underflow_count<=0;
        end else begin
            rwr_g1<=rwr_gray; rwr_g2<=rwr_g1;
            if(axis_handshake && axis_user)
                output_stream_active<=1'b1;
            if(axis_handshake && axis_frame_last) begin
                output_stream_active<=1'b0;
                output_frame_toggle<=~output_frame_toggle;
            end
            if(load_pending) begin
                beat_shift<=rfifo_read_data;
                pixels_left<=8; rrd_bin<=rrd_bin+1'b1;
                rrd_gray<=((rrd_bin+1'b1)>>1)^(rrd_bin+1'b1);
                load_pending<=0; underflow_latched<=0;
            end else if(axis_take) begin
                if(pixels_left!=0) begin
                    axis_y<=beat_shift[7:0]; axis_c<=beat_shift[15:8];
                    axis_valid<=1; axis_user<=(px==0)&&(py==0); axis_last<=(px==719);
                    axis_frame_last<=(px==719)&&(py==575);
                    beat_shift<=beat_shift>>16; pixels_left<=pixels_left-1'b1;
                    if(px==719) begin px<=0; if(py==575)py<=0;else py<=py+1'b1; end
                    else px<=px+1'b1;
                end else begin
                    axis_valid<=0; axis_frame_last<=0;
                    if(!rfifo_empty) begin
                        load_pending<=1;
                        underflow_latched<=0;
                    end else if(output_stream_active &&
                                !(axis_handshake && axis_frame_last) &&
                                !underflow_latched) begin
                        read_fifo_underflow_count<=read_fifo_underflow_count+1'b1;
                        underflow_latched<=1'b1;
                    end
                end
            end
        end
    end

    Adv7391SdrTop_Axis2Bt656V2_1 u_axis_to_bt656(
        .io_mode(2'b00),.io_outen(1'b1),
        .io_saxis_tvalid(axis_valid),.io_saxis_tready(axis_ready),
        .io_saxis_tdata(axis_y),.io_saxis_cdata(axis_c),
        .io_saxis_tkeep(1'b1),.io_saxis_tdest(4'b0),
        .io_saxis_tlast(axis_last),.io_saxis_tuser(axis_user),
        .io_bt656_data(bt656_data),.io_bt656_vsync(bt656_vsync),
        .io_bt656_lsync(bt656_lsync),.io_pixel_clk(pixel_clk),.io_reset(pixel_reset));
endmodule
