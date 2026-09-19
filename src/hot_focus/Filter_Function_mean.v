`timescale 1ns / 1ps

module Filter_Function_mean #(
    parameter integer WIDTH = 8
) (
    input  wire             clk,
    input  wire             reset,
    input  wire             in_valid,
    input  wire [WIDTH-1:0] w11, w12, w13,
    input  wire [WIDTH-1:0] w21, w22, w23,
    input  wire [WIDTH-1:0] w31, w32, w33,
    output reg  [WIDTH+3:0] data_sum_3x3,
    output reg              out_valid
);
    reg [WIDTH:0]   sum0, sum1, sum2, sum3;
    reg [WIDTH-1:0] center0, center1, center2;
    reg [WIDTH+1:0] sum4_0, sum4_1;
    reg [WIDTH+2:0] sum8;
    reg [2:0] valid_pipe;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sum0 <= 0; sum1 <= 0; sum2 <= 0; sum3 <= 0;
            center0 <= 0; center1 <= 0; center2 <= 0;
            sum4_0 <= 0; sum4_1 <= 0; sum8 <= 0;
            data_sum_3x3 <= 0;
            valid_pipe <= 0;
            out_valid <= 1'b0;
        end else begin
            out_valid <= valid_pipe[2];
            valid_pipe <= {valid_pipe[1:0], in_valid};
            if (in_valid) begin
                sum0 <= w11 + w12;
                sum1 <= w13 + w21;
                sum2 <= w23 + w31;
                sum3 <= w32 + w33;
                center0 <= w22;
            end
            if (valid_pipe[0]) begin
                sum4_0 <= sum0 + sum1;
                sum4_1 <= sum2 + sum3;
                center1 <= center0;
            end
            if (valid_pipe[1]) begin
                sum8 <= sum4_0 + sum4_1;
                center2 <= center1;
            end
            if (valid_pipe[2])
                data_sum_3x3 <= sum8 + center2;
        end
    end
endmodule
