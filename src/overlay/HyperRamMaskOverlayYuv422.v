`timescale 1ns / 1ps

// HyperRAM-backed mask overlay.  Legacy mode keeps the original 720x576
// canvases at 0x0040_0000/0x0050_0000.  Raw mode consumes an unscaled
// 420x220 image at a signed top-left position and clips it at the frame edge.
module HyperRamMaskOverlayYuv422 #(
    parameter [31:0] MASK0_BASE = 32'h0040_0000,
    parameter [31:0] MASK1_BASE = 32'h0050_0000,
    parameter [31:0] RTL_MASK0_BASE = 32'h00A0_0000,
    parameter [31:0] RTL_MASK1_BASE = 32'h00B0_0000,
    parameter integer FRAME_WIDTH = 720,
    parameter integer FRAME_HEIGHT = 576,
    parameter integer RAW_MASK_WIDTH = 420,
    parameter integer RAW_MASK_HEIGHT = 220,
    // The live-video frame DMA reverses rows after this overlay.  Address the
    // mask with the final display row so the mask itself remains upright.
    parameter integer FLIP_VERTICAL_COORDS = 0
) (
    input wire clk, input wire reset,
    input wire mask_enable,
    input wire mask_buffer_select,
    input wire raw_mode,
    input wire signed [15:0] mask_left,
    input wire signed [15:0] mask_top,

    input wire [15:0] s_data, input wire s_valid,
    input wire s_sof, input wire s_eol, output wire s_ready,
    output wire [15:0] m_data, output wire m_valid,
    output wire m_sof, output wire m_eol, input wire m_ready,

    output wire avalid, input wire aready,
    output wire [31:0] aaddr, output wire [7:0] aid,
    output wire [7:0] alen, output wire [2:0] asize,
    output wire [1:0] aburst, output wire [1:0] alock,
    output wire atype,
    input wire [7:0] rid, input wire [127:0] rdata,
    input wire rlast, input wire rvalid, output wire rready,
    input wire [1:0] rresp,

    output reg [15:0] frame_count,
    output reg [15:0] read_error_count,
    output wire active,
    output reg active_buffer_select
);
    // Read the mask in 256-byte (16 x 128-bit) bursts.  Two cache banks are
    // used as ping-pong buffers: while pixels consume one block, the next
    // sequential block is fetched into the other bank.  The previous
    // implementation issued a single-beat read every 16 pixels and stalled
    // the live video stream for every cache miss, which could overflow the
    // scaler CDC FIFO.
    localparam integer CACHE_BEATS = 16;
    localparam [7:0] CACHE_AXLEN = CACHE_BEATS-1;
    localparam ST_IDLE = 2'd0, ST_ADDR = 2'd1, ST_DATA = 2'd2;
    reg [1:0] rd_state;
    reg [31:0] requested_addr;
    reg fill_bank;
    reg [4:0] fill_beat;
    reg replace_bank;
    reg [31:0] cache0_addr, cache1_addr;
    reg cache0_valid, cache1_valid;
    reg [127:0] cache0_data [0:CACHE_BEATS-1];
    reg [127:0] cache1_data [0:CACHE_BEATS-1];

    reg frame_enable;
    reg frame_raw_mode;
    reg signed [15:0] frame_left;
    reg signed [15:0] frame_top;
    reg [9:0] x_count;
    reg [9:0] y_count;
    reg in_frame;

    reg [1:0] enable_sync, buffer_sync, raw_sync;
    reg signed [15:0] left_meta, left_sync;
    reg signed [15:0] top_meta, top_sync;
    wire cfg_enable = enable_sync[1];
    wire cfg_buffer = buffer_sync[1];
    wire cfg_raw = raw_sync[1];

    // For the SOF pixel use the just-synchronised settings.  For every other
    // pixel use the frame-latched settings so commands cannot tear a frame.
    wire pixel_enable = s_sof ? cfg_enable : frame_enable;
    wire pixel_raw = s_sof ? cfg_raw : frame_raw_mode;
    wire pixel_buffer = s_sof ? cfg_buffer : active_buffer_select;
    wire signed [15:0] pixel_left = s_sof ? left_sync : frame_left;
    wire signed [15:0] pixel_top = s_sof ? top_sync : frame_top;

    wire [9:0] display_y = FLIP_VERTICAL_COORDS ?
                           (FRAME_HEIGHT-1-y_count) : y_count;
    wire signed [16:0] source_x = $signed({1'b0,x_count}) - pixel_left;
    wire signed [16:0] source_y = $signed({1'b0,display_y}) - pixel_top;
    wire raw_inside = (source_x >= 0) && (source_x < RAW_MASK_WIDTH) &&
                      (source_y >= 0) && (source_y < RAW_MASK_HEIGHT);
    wire legacy_inside = (x_count < FRAME_WIDTH) && (y_count < FRAME_HEIGHT);
    wire use_mask_pixel = pixel_enable &&
                          (pixel_raw ? raw_inside : legacy_inside);

    wire [31:0] raw_row_offset =
        ({15'd0,source_y} << 8) + ({15'd0,source_y} << 7) +
        ({15'd0,source_y} << 5) + ({15'd0,source_y} << 2);
    wire [31:0] legacy_row_offset =
        ({22'd0,display_y} << 9) + ({22'd0,display_y} << 7) +
        ({22'd0,display_y} << 6) + ({22'd0,display_y} << 4);
    wire [31:0] pixel_offset = pixel_raw ?
        (raw_row_offset + source_x[15:0]) :
        (legacy_row_offset + x_count);
    wire [31:0] selected_base = pixel_raw ?
        (pixel_buffer ? RTL_MASK1_BASE : RTL_MASK0_BASE) :
        (pixel_buffer ? MASK1_BASE : MASK0_BASE);
    wire [31:0] pixel_addr = selected_base + pixel_offset;
    wire [31:0] block_addr = {pixel_addr[31:8],8'b00000000};
    wire cache0_hit = cache0_valid && (cache0_addr == block_addr);
    wire cache1_hit = cache1_valid && (cache1_addr == block_addr);
    wire cache_hit = cache0_hit || cache1_hit;
    wire need_read = s_valid && use_mask_pixel && !cache_hit;
    wire [31:0] next_block_addr = block_addr + 32'd256;
    wire next_block_cached = (cache0_valid && (cache0_addr == next_block_addr)) ||
                             (cache1_valid && (cache1_addr == next_block_addr));
    wire can_prefetch = s_valid && use_mask_pixel && cache_hit &&
                        !next_block_cached;

    assign avalid = (rd_state == ST_ADDR);
    assign aaddr = requested_addr;
    assign aid = 8'hA1;
    assign alen = CACHE_AXLEN;
    assign asize = 3'd4;
    assign aburst = 2'b01;
    assign alock = 2'b00;
    assign atype = 1'b0;
    assign rready = (rd_state == ST_DATA);
    assign active = (rd_state != ST_IDLE);

    wire [127:0] selected_cache_word = cache0_hit ?
        cache0_data[pixel_addr[7:4]] : cache1_data[pixel_addr[7:4]];
    reg [7:0] mask_byte;
    always @* begin
        case (pixel_addr[3:0])
          4'd0: mask_byte = selected_cache_word[7:0];
          4'd1: mask_byte = selected_cache_word[15:8];
          4'd2: mask_byte = selected_cache_word[23:16];
          4'd3: mask_byte = selected_cache_word[31:24];
          4'd4: mask_byte = selected_cache_word[39:32];
          4'd5: mask_byte = selected_cache_word[47:40];
          4'd6: mask_byte = selected_cache_word[55:48];
          4'd7: mask_byte = selected_cache_word[63:56];
          4'd8: mask_byte = selected_cache_word[71:64];
          4'd9: mask_byte = selected_cache_word[79:72];
          4'd10: mask_byte = selected_cache_word[87:80];
          4'd11: mask_byte = selected_cache_word[95:88];
          4'd12: mask_byte = selected_cache_word[103:96];
          4'd13: mask_byte = selected_cache_word[111:104];
          4'd14: mask_byte = selected_cache_word[119:112];
          default: mask_byte = selected_cache_word[127:120];
        endcase
    end

    wire can_forward = !use_mask_pixel || cache_hit;
    wire transfer = s_valid && can_forward && m_ready;
    assign s_ready = can_forward && m_ready;
    assign m_valid = s_valid && can_forward;
    // Studio-range white in YCbCr: Y=235, Cb/Cr=128.
    assign m_data = (use_mask_pixel && cache_hit && (mask_byte != 0)) ?
                    16'h80EB : s_data;
    assign m_sof = s_sof;
    assign m_eol = s_eol;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            rd_state <= ST_IDLE;
            requested_addr <= 0;
            fill_bank <= 0;
            fill_beat <= 0;
            replace_bank <= 0;
            cache0_addr <= 0; cache1_addr <= 0;
            cache0_valid <= 0; cache1_valid <= 0;
            frame_enable <= 0;
            frame_raw_mode <= 0;
            frame_left <= 0;
            frame_top <= 0;
            active_buffer_select <= 0;
            enable_sync <= 0;
            buffer_sync <= 0;
            raw_sync <= 0;
            left_meta <= 0; left_sync <= 0;
            top_meta <= 0; top_sync <= 0;
            x_count <= 0; y_count <= 0; in_frame <= 0;
            frame_count <= 0;
            read_error_count <= 0;
        end else begin
            enable_sync <= {enable_sync[0],mask_enable};
            buffer_sync <= {buffer_sync[0],mask_buffer_select};
            raw_sync <= {raw_sync[0],raw_mode};
            left_meta <= mask_left; left_sync <= left_meta;
            top_meta <= mask_top; top_sync <= top_meta;

            if (rd_state == ST_IDLE) begin
                if (need_read) begin
                    // Demand reads have priority.  On a discontinuous address
                    // jump, replace banks in round-robin order.
                    requested_addr <= block_addr;
                    fill_bank <= replace_bank;
                    replace_bank <= ~replace_bank;
                    fill_beat <= 0;
                    if (replace_bank)
                        cache1_valid <= 1'b0;
                    else
                        cache0_valid <= 1'b0;
                    rd_state <= ST_ADDR;
                end else if (can_prefetch) begin
                    // Preserve the bank serving the current pixel and fill the
                    // other bank with the next sequential block.
                    requested_addr <= next_block_addr;
                    fill_bank <= cache0_hit;
                    fill_beat <= 0;
                    if (cache0_hit)
                        cache1_valid <= 1'b0;
                    else
                        cache0_valid <= 1'b0;
                    rd_state <= ST_ADDR;
                end
            end
            if ((rd_state == ST_ADDR) && aready)
                rd_state <= ST_DATA;
            if ((rd_state == ST_DATA) && rvalid) begin
                if (fill_bank)
                    cache1_data[fill_beat[3:0]] <= rdata;
                else
                    cache0_data[fill_beat[3:0]] <= rdata;
                if ((rresp != 2'b00) || (rid != 8'hA1))
                    read_error_count <= read_error_count + 1'b1;
                if (rlast) begin
                    if (fill_beat != CACHE_BEATS-1)
                        read_error_count <= read_error_count + 1'b1;
                    if (fill_bank) begin
                        cache1_addr <= requested_addr;
                        cache1_valid <= 1'b1;
                    end else begin
                        cache0_addr <= requested_addr;
                        cache0_valid <= 1'b1;
                    end
                    fill_beat <= 0;
                    rd_state <= ST_IDLE;
                end else begin
                    fill_beat <= fill_beat + 1'b1;
                end
            end

            if (transfer) begin
                if (s_sof) begin
                    frame_enable <= cfg_enable;
                    frame_raw_mode <= cfg_raw;
                    frame_left <= left_sync;
                    frame_top <= top_sync;
                    active_buffer_select <= cfg_buffer;
                    in_frame <= 1'b1;
                    x_count <= s_eol ? 0 : 1;
                    y_count <= 0;
                end else if (s_eol) begin
                    x_count <= 0;
                    if (y_count == FRAME_HEIGHT-1) begin
                        y_count <= 0;
                        in_frame <= 1'b0;
                        frame_count <= frame_count + 1'b1;
                    end else begin
                        y_count <= y_count + 1'b1;
                    end
                end else begin
                    x_count <= x_count + 1'b1;
                end
            end
        end
    end
endmodule
