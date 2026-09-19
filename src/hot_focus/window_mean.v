`timescale 1ns / 1ps

module window_mean #(
    parameter integer WIDTH = 8
) (
    input  wire             clk,
    input  wire             reset,
    input  wire             in_valid,
    input  wire             line_start,
    input  wire [WIDTH-1:0] w1_in,
    input  wire [WIDTH-1:0] w2_in,
    input  wire [WIDTH-1:0] w3_in,
    output wire [WIDTH-1:0] w11,
    output wire [WIDTH-1:0] w12,
    output wire [WIDTH-1:0] w13,
    output wire [WIDTH-1:0] w21,
    output wire [WIDTH-1:0] w22,
    output wire [WIDTH-1:0] w23,
    output wire [WIDTH-1:0] w31,
    output wire [WIDTH-1:0] w32,
    output wire [WIDTH-1:0] w33
);
    reg [WIDTH-1:0] row1_d1, row1_d2;
    reg [WIDTH-1:0] row2_d1, row2_d2;
    reg [WIDTH-1:0] row3_d1, row3_d2;

    assign w11 = row1_d2;
    assign w12 = row1_d1;
    assign w13 = w1_in;
    assign w21 = row2_d2;
    assign w22 = row2_d1;
    assign w23 = w2_in;
    assign w31 = row3_d2;
    assign w32 = row3_d1;
    assign w33 = w3_in;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            row1_d1 <= 0; row1_d2 <= 0;
            row2_d1 <= 0; row2_d2 <= 0;
            row3_d1 <= 0; row3_d2 <= 0;
        end else if (in_valid) begin
            if (line_start) begin
                row1_d1 <= w1_in; row1_d2 <= 0;
                row2_d1 <= w2_in; row2_d2 <= 0;
                row3_d1 <= w3_in; row3_d2 <= 0;
            end else begin
                row1_d2 <= row1_d1; row1_d1 <= w1_in;
                row2_d2 <= row2_d1; row2_d1 <= w2_in;
                row3_d2 <= row3_d1; row3_d1 <= w3_in;
            end
        end
    end
endmodule
