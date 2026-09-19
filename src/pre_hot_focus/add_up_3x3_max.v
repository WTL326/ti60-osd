`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2025/02/25 20:01:23
// Design Name: 
// Module Name: mean_filter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module add_up_3x3_max #(
    parameter DATA_WIDTH            = 14,
    parameter FRAME_WIDTH           = 640,
    parameter FRAME_HEIGHT          = 512,
    parameter FRAME_WIDTH_BIT       = 10,
    parameter FRAME_HEIGHT_BIT      = 9
) (
    input                           clk,
    input                           rst_n,

    input [DATA_WIDTH - 1 : 0]      in_data,
    input                           in_valid,

    output [FRAME_WIDTH_BIT - 1 : 0]    out_x,
    output [FRAME_HEIGHT_BIT - 1 : 0]   out_y,

    input       [9 : 0]                             left_out,
    input       [9 : 0]                             right_out,
    input       [8 : 0]                             top_out,
    input       [8 : 0]                             bottom_out


);
    
    parameter LATENCY_LINEBUF = FRAME_WIDTH;
    parameter LATENCY_WINDOW = 2;
    parameter LATENCY_FILTER_FUNC = 4;
    parameter LATENCY_TOTAL = LATENCY_LINEBUF + LATENCY_WINDOW + LATENCY_FILTER_FUNC;

    parameter LATENCY_TO_WINDOW_OUT = LATENCY_LINEBUF + LATENCY_WINDOW;

//-------------------------------------------- 输入输出和窗口坐标 begin --------------------------------------

    reg  [FRAME_WIDTH_BIT - 1 : 0]  in_hcnt;
    reg  [FRAME_HEIGHT_BIT - 1 : 0] in_vcnt;
    wire  [FRAME_WIDTH_BIT - 1 : 0]  window_hcnt;
    wire  [FRAME_HEIGHT_BIT - 1 : 0] window_vcnt;   

    always@(posedge clk or negedge rst_n)
        if (!rst_n) begin
            in_hcnt <= 0;
            in_vcnt <= 0;
        end
        else if (in_valid) begin
            if (in_hcnt == FRAME_WIDTH - 1) begin
                if (in_vcnt == FRAME_HEIGHT - 1) begin
                    in_hcnt <= 0;
                    in_vcnt <= 0;
                end
                else begin
                    in_hcnt <= 0;
                    in_vcnt <= in_vcnt + 1;
                end
            end
            else begin
                in_hcnt <= in_hcnt + 1;
                in_vcnt <= in_vcnt;
            end
        end

    LineBuf #(
        .WIDTH  (FRAME_WIDTH_BIT),
        .LATENCY    (LATENCY_TO_WINDOW_OUT)
    ) invcnt_delay_inst (
        .clk     (clk),
        .in_valid(in_valid),
        .data_in (in_hcnt),
        .data_out(window_hcnt)
    );

    LineBuf #(
        .WIDTH  (FRAME_HEIGHT_BIT),
        .LATENCY    (LATENCY_TO_WINDOW_OUT)
    ) inhcnt_delay_inst (
        .clk     (clk),
        .in_valid(in_valid),
        .data_in (in_vcnt),
        .data_out(window_vcnt)
    );

//-------------------------------------------- 输入输出和窗口坐标 end --------------------------------------

// ---------------------------------------- 窗口部分 begin---------------------------------------
    wire [DATA_WIDTH - 1 : 0] linebuf_row1_data_out;
    wire [DATA_WIDTH - 1 : 0] linebuf_row2_data_out;

    LineBuf #(
        .WIDTH(DATA_WIDTH),
        .LATENCY(FRAME_WIDTH)
    )
    linebuf_row1(
        .clk     (clk),
        .in_valid(in_valid),
        .data_in (in_data),
        .data_out(linebuf_row1_data_out)
    );

    LineBuf #(
        .WIDTH(DATA_WIDTH),
        .LATENCY(FRAME_WIDTH)
    )
    linebuf_row2(
        .clk     (clk),
        .in_valid(in_valid),
        .data_in (linebuf_row1_data_out),
        .data_out(linebuf_row2_data_out)
    );

    wire is_first_row = window_vcnt == 0;
    wire is_first_col = window_hcnt == 0;
    wire is_last_row = window_vcnt == FRAME_HEIGHT - 1;
    wire is_last_col = window_hcnt == FRAME_WIDTH - 1;

    wire [DATA_WIDTH - 1 : 0] w11,w12,w13,w21,w22,w23,w31,w32,w33;

    wire [DATA_WIDTH - 1 : 0] w22_pad = w22;

    wire [DATA_WIDTH - 1 : 0] w12_pad = is_first_row ? w22 : w12;
    wire [DATA_WIDTH - 1 : 0] w21_pad = is_first_col ? w22 : w21;
    wire [DATA_WIDTH - 1 : 0] w23_pad = is_last_col ? w22 : w23;
    wire [DATA_WIDTH - 1 : 0] w32_pad = is_last_row ? w22 : w32;

    wire [DATA_WIDTH - 1 : 0] w11_pad = is_first_row ? w21_pad : is_first_col ? w12_pad : w11;
    wire [DATA_WIDTH - 1 : 0] w13_pad = is_first_row ? w23_pad : is_last_col ? w12_pad : w13;
    wire [DATA_WIDTH - 1 : 0] w31_pad = is_last_row ? w21_pad : is_first_col ? w32_pad : w31;
    wire [DATA_WIDTH - 1 : 0] w33_pad = is_last_row ? w23_pad : is_last_col ? w32_pad : w33;    


    window_mean #(
        .WIDTH(DATA_WIDTH)
    ) sliding_window (
        .clk     (clk),
        .in_valid(in_valid),
        .w1_in   (linebuf_row2_data_out),
        .w2_in   (linebuf_row1_data_out),
        .w3_in   (in_data),
        .w11     (w11),
        .w12     (w12),
        .w13     (w13),
        .w21     (w21),
        .w22     (w22),
        .w23     (w23),
        .w31     (w31),
        .w32     (w32),
        .w33     (w33)
    );

    wire [DATA_WIDTH + 3 : 0] data_sum_3x3;

    Filter_Function_mean #(
        .WIDTH      (DATA_WIDTH),
        .window_size(3)
    ) Fil_Func_U1 (
        .rst_n          (rst_n),
        .clk            (clk),
        .in_valid       (in_valid),
        .w11            (w11_pad),
        .w12            (w12_pad),
        .w13            (w13_pad),
        .w21            (w21_pad),
        .w22            (w22_pad),
        .w23            (w23_pad),
        .w31            (w31_pad),
        .w32            (w32_pad),
        .w33            (w33_pad),
        .data_sum_3x3   (data_sum_3x3)
    );

// ---------------------------------------- 窗口部分 end---------------------------------------

// ------------------------------------------ 取一帧内最大值 begin -----------------------------------------

    reg [FRAME_WIDTH_BIT - 1 : 0] window_hcnt_r[LATENCY_FILTER_FUNC - 1 : 0];
    reg [FRAME_HEIGHT_BIT - 1 : 0] window_vcnt_r[LATENCY_FILTER_FUNC - 1 : 0];

    reg [DATA_WIDTH + 4 - 1 : 0] sum_max_temp;
    reg [FRAME_WIDTH_BIT - 1 : 0] hot_x_pos_temp;
    reg [FRAME_HEIGHT_BIT - 1 : 0] hot_y_pos_temp;
    reg [FRAME_WIDTH_BIT - 1 : 0] hot_x_pos_frame;
    reg [FRAME_HEIGHT_BIT - 1 : 0] hot_y_pos_frame;

    integer i;

    always@(posedge clk or negedge rst_n)
        if (!rst_n) begin
            for (i=0;i<=LATENCY_FILTER_FUNC - 1;i=i+1) begin
                window_hcnt_r[i] <= 0;
                window_vcnt_r[i] <= 0;
            end
        end
        else if (in_valid) begin
            for (i=0;i<LATENCY_FILTER_FUNC - 1;i=i+1) begin
                window_hcnt_r[i+1] <= window_hcnt_r[i];
                window_vcnt_r[i+1] <= window_vcnt_r[i];
            end
            window_hcnt_r[0] <= window_hcnt;
            window_vcnt_r[0] <= window_vcnt;
        end

    wire [FRAME_WIDTH_BIT - 1 : 0] contrary_hcnt = window_hcnt_r[LATENCY_FILTER_FUNC - 1];
    wire [FRAME_HEIGHT_BIT - 1 : 0] contrary_vcnt = window_vcnt_r[LATENCY_FILTER_FUNC - 1];

    always@(posedge clk or negedge rst_n)
        if (!rst_n) begin
            sum_max_temp <= 0;
            hot_x_pos_temp <= 0;
            hot_y_pos_temp <= 0;
            hot_x_pos_frame <= 0;
            hot_y_pos_frame <= 0;
        end
        else if (in_valid) begin
            if ((contrary_hcnt <= right_out) & (contrary_hcnt >= left_out) & (contrary_vcnt <= bottom_out) & (contrary_vcnt >= top_out)) begin
                if ((contrary_hcnt == 0) & (contrary_vcnt == 0)) begin
                    hot_x_pos_temp <= contrary_hcnt;
                    hot_y_pos_temp <= contrary_vcnt;
                    sum_max_temp <= data_sum_3x3;
                    hot_x_pos_frame <= hot_x_pos_temp;
                    hot_y_pos_frame <= hot_y_pos_temp;
                end
                else if (data_sum_3x3 > sum_max_temp) begin
                    hot_x_pos_temp <= contrary_hcnt;
                    hot_y_pos_temp <= contrary_vcnt;
                    sum_max_temp <= data_sum_3x3;
                    hot_x_pos_frame <= hot_x_pos_frame;
                    hot_y_pos_frame <= hot_y_pos_frame;
                end
            end
            else if ((contrary_hcnt == 0) & (contrary_vcnt == 0)) begin
                hot_x_pos_temp <= 0;
                hot_y_pos_temp <= 0;
                sum_max_temp <= 0;
                hot_x_pos_frame <= hot_x_pos_temp;
                hot_y_pos_frame <= hot_y_pos_temp;
            end
        end

    assign out_x = hot_x_pos_frame;
    assign out_y = hot_y_pos_frame;

// ------------------------------------------ 取一帧内最大值 end ---------------------------------------------------


endmodule
