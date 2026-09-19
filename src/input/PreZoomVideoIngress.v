`timescale 1ns / 1ps

// Decoder-to-processing clock crossing shared by hot-focus and electronic
// zoom.  BT.1120 is push-only; a full FIFO therefore marks the whole source
// frame bad by toggling drop_epoch.  The read-side consumers carry that epoch
// with every accepted pixel and independently suppress damaged-frame results.
module PreZoomVideoIngress #(
    parameter integer FIFO_ADDR_W = 13
) (
    input  wire       input_clk,
    input  wire       input_reset,
    input  wire [7:0] input_y,
    input  wire [7:0] input_c,
    input  wire       input_valid,
    input  wire       input_sof,
    input  wire       input_eof,
    input  wire       input_sol,
    input  wire       input_eol,

    input  wire       clk,
    input  wire       reset,
    output wire [7:0] output_y,
    output wire [7:0] output_c,
    output wire       output_valid,
    output wire       output_sof,
    output wire       output_eof,
    output wire       output_sol,
    output wire       output_eol,
    output wire       output_drop_epoch,
    input  wire       output_ready,

    output wire       fifo_overflow
);
    reg input_drop_epoch;
    reg input_drop_episode;
    wire input_fifo_wr_ready;
    wire [20:0] fifo_data;

    always @(posedge input_clk or posedge input_reset) begin
        if (input_reset) begin
            input_drop_epoch <= 1'b0;
            input_drop_episode <= 1'b0;
        end else if (input_valid && !input_fifo_wr_ready) begin
            if (!input_drop_episode)
                input_drop_epoch <= ~input_drop_epoch;
            input_drop_episode <= 1'b1;
        end else if (input_fifo_wr_ready) begin
            input_drop_episode <= 1'b0;
        end
    end

    VideoAsyncFifo #(.WIDTH(21), .ADDR_W(FIFO_ADDR_W)) u_input_fifo (
        .wr_clk(input_clk),
        .wr_reset(input_reset),
        .wr_data({input_drop_epoch, input_sof, input_eof, input_sol,
                  input_eol, input_c, input_y}),
        .wr_valid(input_valid),
        .wr_ready(input_fifo_wr_ready),
        .overflow(fifo_overflow),
        .rd_clk(clk),
        .rd_reset(reset),
        .rd_data(fifo_data),
        .rd_valid(output_valid),
        .rd_ready(output_ready)
    );

    assign output_drop_epoch = fifo_data[20];
    assign output_sof        = fifo_data[19];
    assign output_eof        = fifo_data[18];
    assign output_sol        = fifo_data[17];
    assign output_eol        = fifo_data[16];
    assign output_c          = fifo_data[15:8];
    assign output_y          = fifo_data[7:0];
endmodule
