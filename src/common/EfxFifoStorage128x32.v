// 128-bit x 32-entry FIFO storage implemented explicitly with Titanium
// EFX_RAM10 blocks.  Pointer/flag control remains in the owning FIFO logic;
// this module only provides the dual-clock storage and its one-cycle
// synchronous read port.
//
// Seven 20-bit RAM slices provide 140 physical bits.  The unused upper
// 12 bits are tied low, so one instance consumes seven RAM10 blocks instead
// of implementing 4096 data bits with flip-flops.
module EfxFifoStorage128x32 (
    input  wire         wr_clk,
    input  wire         wr_en,
    input  wire [4:0]   wr_addr,
    input  wire [127:0] wr_data,
    input  wire         rd_clk,
    input  wire         rd_en,
    input  wire [4:0]   rd_addr,
    output wire [127:0] rd_data
);
    wire [139:0] wr_data_padded = {12'd0, wr_data};
    wire [139:0] rd_data_padded;

    genvar slice;
    generate
        for (slice = 0; slice < 7; slice = slice + 1) begin : g_ram_slice
            EFX_RAM10 #(
                .WRITE_WIDTH(20),
                .READ_WIDTH(20),
                // One instance is used as an AXI-to-pixel asynchronous FIFO.
                // Titanium RAM blocks require READ_UNKNOWN whenever the read
                // and write ports use different clocks.  FIFO pointer control
                // prevents a valid read and write from targeting the same
                // occupied entry, so collision output is never consumed.
                .WRITE_MODE("READ_UNKNOWN"),
                .OUTPUT_REG(1'b0),
                .RESET_RAM("NONE"),
                .RESET_OUTREG("NONE")
            ) u_ram10 (
                .WCLK(wr_clk),
                .WE({2{wr_en}}),
                .WCLKE(1'b1),
                .WADDREN(1'b1),
                .WDATA(wr_data_padded[slice*20 +: 20]),
                .WADDR({4'b0000, wr_addr}),
                .RCLK(rd_clk),
                .RE(rd_en),
                .RST(1'b0),
                .RADDREN(1'b1),
                .RDATA(rd_data_padded[slice*20 +: 20]),
                .RADDR({4'b0000, rd_addr})
            );
        end
    endgenerate

    assign rd_data = rd_data_padded[127:0];
endmodule
