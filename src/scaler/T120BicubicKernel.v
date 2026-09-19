`timescale 1ns / 1ps

// Two-dimensional 4x4 bicubic interpolation kernel derived from the T120
// scaler_bicubic/cal_bilinear.v arithmetic.  Despite the historical T120
// filename, this is not bilinear: each axis uses four cubic weights.
//
// frac_x/frac_y are unsigned Q0.10 fractions.  matrix_4x4 is row-major with
// p00 in bits [127:120] and p33 in bits [7:0].  The original T120 datapath
// represents the two outer negative lobes as positive magnitudes and applies
// a checkerboard add/subtract at the 2-D sum.  Here the same truncated Q10
// magnitudes are converted to signed 1-D weights, which is algebraically
// identical and makes the interface reusable for Y, Cb and Cr lanes.
module T120BicubicKernel (
    input  wire         clk,
    input  wire         reset,
    input  wire         in_valid,
    input  wire [127:0] matrix_4x4,
    input  wire [9:0]   frac_x,
    input  wire [9:0]   frac_y,
    output reg          out_valid,
    output reg  [7:0]   out_pixel
);
    function signed [12:0] cubic_weight;
        input [9:0] fraction;
        input [1:0] tap;
        reg [11:0] distance;
        reg [23:0] distance2;
        reg [35:0] distance3;
        reg signed [15:0] magnitude;
        begin
            case (tap)
                2'd0: distance = 12'd1024 + {2'd0, fraction};
                2'd1: distance = {2'd0, fraction};
                2'd2: distance = 12'd1024 - {2'd0, fraction};
                default: distance = 12'd2048 - {2'd0, fraction};
            endcase

            distance2 = distance * distance;
            distance3 = distance * distance2;
            if ((tap == 2'd0) || (tap == 2'd3)) begin
                // |x^3 - 5*x^2 + 8*x - 4|, with x in Q10.
                magnitude = $signed({1'b0, distance3[35:20]}) -
                            5 * $signed({1'b0, distance2[23:10]}) +
                            8 * $signed({1'b0, distance}) - 16'sd4096;
                cubic_weight = -magnitude;
            end else begin
                // x^3 - 2*x^2 + 1, with x in Q10.
                magnitude = $signed({1'b0, distance3[35:20]}) -
                            2 * $signed({1'b0, distance2[23:10]}) +
                            16'sd1024;
                cubic_weight = magnitude;
            end
        end
    endfunction

    function [7:0] matrix_sample;
        input [127:0] matrix;
        input [3:0] index;
        begin
            case (index)
                4'd0: matrix_sample = matrix[127:120];
                4'd1: matrix_sample = matrix[119:112];
                4'd2: matrix_sample = matrix[111:104];
                4'd3: matrix_sample = matrix[103:96];
                4'd4: matrix_sample = matrix[95:88];
                4'd5: matrix_sample = matrix[87:80];
                4'd6: matrix_sample = matrix[79:72];
                4'd7: matrix_sample = matrix[71:64];
                4'd8: matrix_sample = matrix[63:56];
                4'd9: matrix_sample = matrix[55:48];
                4'd10: matrix_sample = matrix[47:40];
                4'd11: matrix_sample = matrix[39:32];
                4'd12: matrix_sample = matrix[31:24];
                4'd13: matrix_sample = matrix[23:16];
                4'd14: matrix_sample = matrix[15:8];
                default: matrix_sample = matrix[7:0];
            endcase
        end
    endfunction

    function [7:0] clip_q20;
        input signed [63:0] value;
        reg signed [63:0] integer_value;
        begin
            integer_value = value >>> 20;
            if (integer_value < 0)
                clip_q20 = 8'd0;
            else if (integer_value > 255)
                clip_q20 = 8'd255;
            else
                clip_q20 = integer_value[7:0];
        end
    endfunction

    wire signed [12:0] kx0 = cubic_weight(frac_x, 2'd0);
    wire signed [12:0] kx1 = cubic_weight(frac_x, 2'd1);
    wire signed [12:0] kx2 = cubic_weight(frac_x, 2'd2);
    wire signed [12:0] kx3 = cubic_weight(frac_x, 2'd3);
    wire signed [12:0] ky0_now = cubic_weight(frac_y, 2'd0);
    wire signed [12:0] ky1_now = cubic_weight(frac_y, 2'd1);
    wire signed [12:0] ky2_now = cubic_weight(frac_y, 2'd2);
    wire signed [12:0] ky3_now = cubic_weight(frac_y, 2'd3);

    reg signed [31:0] horizontal0;
    reg signed [31:0] horizontal1;
    reg signed [31:0] horizontal2;
    reg signed [31:0] horizontal3;
    reg signed [12:0] ky0;
    reg signed [12:0] ky1;
    reg signed [12:0] ky2;
    reg signed [12:0] ky3;
    reg               valid_d;

    wire signed [63:0] vertical_sum =
        horizontal0 * ky0 + horizontal1 * ky1 +
        horizontal2 * ky2 + horizontal3 * ky3;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            horizontal0 <= 0;
            horizontal1 <= 0;
            horizontal2 <= 0;
            horizontal3 <= 0;
            ky0 <= 0;
            ky1 <= 0;
            ky2 <= 0;
            ky3 <= 0;
            valid_d <= 1'b0;
            out_valid <= 1'b0;
            out_pixel <= 8'd0;
        end else begin
            out_valid <= valid_d;
            if (valid_d)
                out_pixel <= clip_q20(vertical_sum);

            valid_d <= in_valid;
            if (in_valid) begin
                horizontal0 <=
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd0)}) * kx0 +
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd1)}) * kx1 +
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd2)}) * kx2 +
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd3)}) * kx3;
                horizontal1 <=
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd4)}) * kx0 +
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd5)}) * kx1 +
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd6)}) * kx2 +
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd7)}) * kx3;
                horizontal2 <=
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd8)}) * kx0 +
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd9)}) * kx1 +
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd10)}) * kx2 +
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd11)}) * kx3;
                horizontal3 <=
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd12)}) * kx0 +
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd13)}) * kx1 +
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd14)}) * kx2 +
                    $signed({1'b0, matrix_sample(matrix_4x4, 4'd15)}) * kx3;
                ky0 <= ky0_now;
                ky1 <= ky1_now;
                ky2 <= ky2_now;
                ky3 <= ky3_now;
            end
        end
    end
endmodule
