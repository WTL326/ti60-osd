`timescale 1ns / 1ps

// One-row read-first line history.  Keeping each RAM to one synchronous read
// and one write is required for Efinity to map the array entirely into a
// Titanium RAM block instead of duplicating the read path in logic.
module HotFocusLineBufTi60 #(
    parameter integer DATA_WIDTH  = 8,
    parameter integer FRAME_WIDTH = 1280,
    parameter integer ADDR_WIDTH  = 11
) (
    input  wire                  clk,
    input  wire                  enable,
    input  wire [ADDR_WIDTH-1:0] address,
    input  wire [DATA_WIDTH-1:0] data_in,
    output reg  [DATA_WIDTH-1:0] data_out
);
    (* syn_ramstyle = "block_ram" *)
    reg [DATA_WIDTH-1:0] memory [0:FRAME_WIDTH-1];

    always @(posedge clk) begin
        if (enable) begin
            data_out <= memory[address];
            memory[address] <= data_in;
        end
    end
endmodule
