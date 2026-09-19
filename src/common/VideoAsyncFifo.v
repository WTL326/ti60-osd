// Small dual-clock FIFO used between the BT.1120 input clock and the 100 MHz
// video-processing clock. DEPTH is 2**ADDR_W.
module VideoAsyncFifo #(
    parameter integer WIDTH  = 18,
    parameter integer ADDR_W = 11
) (
    input  wire             wr_clk,
    input  wire             wr_reset,
    input  wire [WIDTH-1:0] wr_data,
    input  wire             wr_valid,
    output wire             wr_ready,
    output reg              overflow,

    input  wire             rd_clk,
    input  wire             rd_reset,
    output wire [WIDTH-1:0] rd_data,
    output wire             rd_valid,
    input  wire             rd_ready
);
    localparam integer DEPTH = (1 << ADDR_W);
    reg [WIDTH-1:0] mem [0:DEPTH-1];

    reg [ADDR_W:0] wr_bin, wr_gray;
    reg [ADDR_W:0] rd_bin, rd_gray;
    (* async_reg = "true" *) reg [ADDR_W:0] rd_gray_w1, rd_gray_w2;
    (* async_reg = "true" *) reg [ADDR_W:0] wr_gray_r1, wr_gray_r2;

    wire [ADDR_W:0] wr_bin_plus  = wr_bin + 1'b1;
    wire [ADDR_W:0] wr_gray_plus = (wr_bin_plus >> 1) ^ wr_bin_plus;
    wire fifo_full = (wr_gray_plus ==
                     {~rd_gray_w2[ADDR_W:ADDR_W-1],rd_gray_w2[ADDR_W-2:0]});
    wire fifo_empty = (rd_gray == wr_gray_r2);

    reg [WIDTH-1:0] rd_data_reg;
    reg             rd_valid_reg;
    wire            rd_fetch = (!rd_valid_reg || rd_ready) && !fifo_empty;

    assign wr_ready = !fifo_full;
    assign rd_valid = rd_valid_reg;
    assign rd_data  = rd_data_reg;

    always @(posedge wr_clk or posedge wr_reset) begin
        if (wr_reset) begin
            wr_bin     <= 0;
            wr_gray    <= 0;
            rd_gray_w1 <= 0;
            rd_gray_w2 <= 0;
            overflow   <= 1'b0;
        end else begin
            rd_gray_w1 <= rd_gray;
            rd_gray_w2 <= rd_gray_w1;
            if (wr_valid && wr_ready) begin
                mem[wr_bin[ADDR_W-1:0]] <= wr_data;
                wr_bin  <= wr_bin_plus;
                wr_gray <= wr_gray_plus;
            end else if (wr_valid) begin
                overflow <= 1'b1;
            end
        end
    end

    always @(posedge rd_clk or posedge rd_reset) begin
        if (rd_reset) begin
            rd_bin     <= 0;
            rd_gray    <= 0;
            rd_data_reg<= 0;
            rd_valid_reg<=1'b0;
            wr_gray_r1 <= 0;
            wr_gray_r2 <= 0;
        end else begin
            wr_gray_r1 <= wr_gray;
            wr_gray_r2 <= wr_gray_r1;
            if (rd_fetch) begin
                rd_data_reg <= mem[rd_bin[ADDR_W-1:0]];
                rd_bin  <= rd_bin + 1'b1;
                rd_gray <= (((rd_bin + 1'b1) >> 1) ^ (rd_bin + 1'b1));
                rd_valid_reg <= 1'b1;
            end else if (rd_valid_reg && rd_ready) begin
                rd_valid_reg <= 1'b0;
            end
        end
    end
endmodule
