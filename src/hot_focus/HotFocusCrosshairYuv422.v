`timescale 1ns / 1ps

// Pre-zoom 1280x1024 YUV422 crosshair.  The complete sideband packet remains
// aligned under backpressure and only C/Y are changed on a crosshair hit.
module HotFocusCrosshairYuv422 #(
    parameter integer FRAME_WIDTH  = 1280,
    parameter integer FRAME_HEIGHT = 1024,
    parameter integer HALF_LENGTH  = 10,
    parameter integer HALF_WIDTH   = 2,
    parameter [7:0] CROSS_Y  = 8'd81,
    parameter [7:0] CROSS_CB = 8'd90,
    parameter [7:0] CROSS_CR = 8'd240
) (
    input  wire        clk,
    input  wire        reset,
    input  wire [7:0]  s_y,
    input  wire [7:0]  s_c,
    input  wire        s_valid,
    input  wire        s_sof,
    input  wire        s_eof,
    input  wire        s_sol,
    input  wire        s_eol,
    input  wire        s_drop_epoch,
    output wire        s_ready,
    output wire [7:0]  m_y,
    output wire [7:0]  m_c,
    output wire        m_valid,
    output wire        m_sof,
    output wire        m_eof,
    output wire        m_sol,
    output wire        m_eol,
    output wire        m_drop_epoch,
    input  wire        m_ready,
    input  wire        cross_enable,
    input  wire [10:0] cross_x,
    input  wire [9:0]  cross_y
);
    reg [10:0] pixel_x;
    reg [9:0] pixel_y;
    reg enable_latched;
    reg [10:0] cross_x_latched;
    reg [9:0] cross_y_latched;

    wire fire = s_valid && s_ready;
    assign s_ready = m_ready;
    assign m_valid = s_valid;
    assign m_sof = s_sof; assign m_eof = s_eof;
    assign m_sol = s_sol; assign m_eol = s_eol;
    assign m_drop_epoch = s_drop_epoch;

    wire [10:0] clamped_x = (cross_x < FRAME_WIDTH) ? cross_x : FRAME_WIDTH-1;
    wire [9:0] clamped_y = (cross_y < FRAME_HEIGHT) ? cross_y : FRAME_HEIGHT-1;
    wire [10:0] draw_x = (s_sof || s_sol) ? 0 : pixel_x;
    wire [9:0] draw_y = s_sof ? 0 : pixel_y;
    wire draw_enable = s_sof ? cross_enable : enable_latched;
    wire [10:0] draw_cross_x = s_sof ? clamped_x : cross_x_latched;
    wire [9:0] draw_cross_y = s_sof ? clamped_y : cross_y_latched;
    wire [11:0] delta_x = (draw_x >= draw_cross_x) ?
                          draw_x-draw_cross_x : draw_cross_x-draw_x;
    wire [10:0] delta_y = (draw_y >= draw_cross_y) ?
                          draw_y-draw_cross_y : draw_cross_y-draw_y;
    wire cross_hit = draw_enable &&
        (((delta_x <= HALF_LENGTH) && (delta_y <= HALF_WIDTH)) ||
         ((delta_x <= HALF_WIDTH) && (delta_y <= HALF_LENGTH)));

    assign m_y = cross_hit ? CROSS_Y : s_y;
    assign m_c = cross_hit ? (draw_x[0] ? CROSS_CR : CROSS_CB) : s_c;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pixel_x <= 0; pixel_y <= 0;
            enable_latched <= 1'b0;
            cross_x_latched <= FRAME_WIDTH/2;
            cross_y_latched <= FRAME_HEIGHT/2;
        end else if (fire) begin
            if (s_sof) begin
                enable_latched <= cross_enable;
                cross_x_latched <= clamped_x;
                cross_y_latched <= clamped_y;
            end
            if (s_eol) begin
                pixel_x <= 0;
                pixel_y <= (draw_y == FRAME_HEIGHT-1) ? 0 : draw_y+1'b1;
            end else begin
                pixel_x <= draw_x+1'b1;
                pixel_y <= draw_y;
            end
        end
    end
endmodule
