// Frame-stable crosshair overlay for the 720x576 progressive YUV422 stream.
//
// Pixel packing follows the existing video path:
//   pixel[7:0]  = Y
//   pixel[15:8] = Cb on even x, Cr on odd x
//
// The module is a zero-latency ready/valid stage.  Coordinates advance only
// on a successful transfer, so downstream backpressure cannot move the
// crosshair relative to the image.  Control values are clamped and captured
// at SOF, keeping every accepted frame internally consistent.
module VideoCrosshairYuv422 #(
    parameter integer FRAME_WIDTH  = 720,
    parameter integer FRAME_HEIGHT = 576,
    parameter integer HALF_LENGTH  = 10,
    parameter integer HALF_WIDTH   = 2,
    parameter [7:0] CROSS_Y  = 8'd81,
    parameter [7:0] CROSS_CB = 8'd90,
    parameter [7:0] CROSS_CR = 8'd240
) (
    input  wire        clk,
    input  wire        reset,

    input  wire [15:0] s_data,
    input  wire        s_valid,
    input  wire        s_sof,
    input  wire        s_eol,
    output wire        s_ready,

    output wire [15:0] m_data,
    output wire        m_valid,
    output wire        m_sof,
    output wire        m_eol,
    input  wire        m_ready,

    input  wire        cross_enable,
    input  wire [9:0]  cross_x,
    input  wire [9:0]  cross_y
);
    reg [9:0] pixel_x;
    reg [9:0] pixel_y;
    reg       cross_enable_latched;
    reg [9:0] cross_x_latched;
    reg [9:0] cross_y_latched;

    wire fire = s_valid && s_ready;
    assign s_ready = m_ready;
    assign m_valid = s_valid;
    assign m_sof   = s_sof;
    assign m_eol   = s_eol;

    wire [9:0] cross_x_clamped =
        (cross_x < FRAME_WIDTH) ? cross_x : FRAME_WIDTH-1;
    wire [9:0] cross_y_clamped =
        (cross_y < FRAME_HEIGHT) ? cross_y : FRAME_HEIGHT-1;

    // SOF describes the pixel currently on s_data.  Select the new controls
    // combinationally for that first pixel as well as latching them below.
    wire [9:0] draw_x = s_sof ? 10'd0 : pixel_x;
    wire [9:0] draw_y = s_sof ? 10'd0 : pixel_y;
    wire       draw_enable = s_sof ? cross_enable : cross_enable_latched;
    wire [9:0] draw_cross_x = s_sof ? cross_x_clamped : cross_x_latched;
    wire [9:0] draw_cross_y = s_sof ? cross_y_clamped : cross_y_latched;

    wire [10:0] delta_x = (draw_x >= draw_cross_x) ?
                          (draw_x-draw_cross_x) : (draw_cross_x-draw_x);
    wire [10:0] delta_y = (draw_y >= draw_cross_y) ?
                          (draw_y-draw_cross_y) : (draw_cross_y-draw_y);
    wire in_horizontal = (delta_x <= HALF_LENGTH) &&
                         (delta_y <= HALF_WIDTH);
    wire in_vertical   = (delta_x <= HALF_WIDTH) &&
                         (delta_y <= HALF_LENGTH);
    wire cross_hit = draw_enable && (in_horizontal || in_vertical);
    wire [7:0] cross_chroma = draw_x[0] ? CROSS_CR : CROSS_CB;

    assign m_data = cross_hit ? {cross_chroma,CROSS_Y} : s_data;

    always @(posedge clk or posedge reset) begin
        if(reset) begin
            pixel_x <= 0;
            pixel_y <= 0;
            cross_enable_latched <= 1'b0;
            cross_x_latched <= 10'd360;
            cross_y_latched <= 10'd288;
        end else if(fire) begin
            if(s_sof) begin
                cross_enable_latched <= cross_enable;
                cross_x_latched <= cross_x_clamped;
                cross_y_latched <= cross_y_clamped;
            end

            if(s_eol) begin
                pixel_x <= 0;
                if((s_sof && (FRAME_HEIGHT == 1)) ||
                   (!s_sof && (pixel_y == FRAME_HEIGHT-1)))
                    pixel_y <= 0;
                else if(s_sof)
                    pixel_y <= 1;
                else
                    pixel_y <= pixel_y+1'b1;
            end else begin
                pixel_x <= draw_x+1'b1;
                pixel_y <= draw_y;
            end
        end
    end
endmodule
