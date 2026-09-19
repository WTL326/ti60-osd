`timescale 1ns / 1ps

// Ready/valid pass-through wrapper around the passive hot-focus calculator.
module HotFocusCal #(
    parameter integer FRAME_WIDTH = 1280,
    parameter integer FRAME_HEIGHT = 1024
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
    input  wire        enable,
    input  wire        polarity_black_hot,
    input  wire [10:0] roi_left,
    input  wire [10:0] roi_right,
    input  wire [9:0]  roi_top,
    input  wire [9:0]  roi_bottom,
    output wire [10:0] hot_x,
    output wire [9:0]  hot_y,
    output wire [11:0] hot_sum,
    output wire        hot_valid,
    output wire [15:0] result_count,
    output wire [15:0] dropped_result_count
);
    wire fire = s_valid && s_ready;
    assign s_ready = m_ready;
    assign m_y = s_y; assign m_c = s_c;
    assign m_valid = s_valid; assign m_sof = s_sof;
    assign m_eof = s_eof; assign m_sol = s_sol; assign m_eol = s_eol;
    assign m_drop_epoch = s_drop_epoch;

    HotFocus3x3Max #(
        .DATA_WIDTH(8), .FRAME_WIDTH(FRAME_WIDTH),
        .FRAME_HEIGHT(FRAME_HEIGHT), .X_WIDTH(11), .Y_WIDTH(10)
    ) u_tracker (
        .clk(clk), .reset(reset), .pixel_y(s_y), .pixel_valid(fire),
        .pixel_sof(s_sof), .pixel_sol(s_sol), .pixel_eol(s_eol),
        .pixel_drop_epoch(s_drop_epoch), .enable(enable),
        .polarity_black_hot(polarity_black_hot),
        .roi_left(roi_left), .roi_right(roi_right),
        .roi_top(roi_top), .roi_bottom(roi_bottom),
        .hot_x(hot_x), .hot_y(hot_y), .hot_sum(hot_sum),
        .hot_valid(hot_valid), .result_count(result_count),
        .dropped_result_count(dropped_result_count)
    );
endmodule
