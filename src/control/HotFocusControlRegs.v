`timescale 1ns / 1ps

// +0x00 COMMAND    bit31 commit, bit1 black_hot, bit0 enable
// +0x04 STATUS     {commit_count,12'd0,result_valid,pending,black_hot,enable}
// +0x08 RESULT_XY  {6'd0,y[9:0],5'd0,x[10:0]}
// +0x0c RESULT_SUM {result_count,sum[11:0]}
// +0x10 COUNTERS   {dropped_result_count,result_count}
module HotFocusControlRegs (
    input  wire        clk,
    input  wire        reset,
    input  wire [7:0]  s_awid,
    input  wire [31:0] s_awaddr,
    input  wire [7:0]  s_awlen,
    input  wire [2:0]  s_awsize,
    input  wire        s_awvalid,
    output wire        s_awready,
    input  wire [31:0] s_wdata,
    input  wire [3:0]  s_wstrb,
    input  wire        s_wlast,
    input  wire        s_wvalid,
    output wire        s_wready,
    output wire [7:0]  s_bid,
    output wire [1:0]  s_bresp,
    output wire        s_bvalid,
    input  wire        s_bready,
    input  wire [7:0]  s_arid,
    input  wire [31:0] s_araddr,
    input  wire [7:0]  s_arlen,
    input  wire [2:0]  s_arsize,
    input  wire        s_arvalid,
    output wire        s_arready,
    output wire [7:0]  s_rid,
    output wire [31:0] s_rdata,
    output wire [1:0]  s_rresp,
    output wire        s_rlast,
    output wire        s_rvalid,
    input  wire        s_rready,
    output reg         cfg_enable,
    output reg         cfg_black_hot,
    output reg         cfg_toggle,
    input  wire        applied_toggle,
    input  wire [10:0] result_x,
    input  wire [9:0]  result_y,
    input  wire [11:0] result_sum,
    input  wire        result_valid,
    input  wire [15:0] result_count,
    input  wire [15:0] dropped_result_count,
    output reg  [15:0] commit_count
);
    wire write_pulse;
    wire [31:0] write_addr, write_data, read_addr;
    wire [3:0] write_strb;
    reg [31:0] read_data;
    wire pending = cfg_toggle ^ applied_toggle;

    AxiSingleBeatEndpoint u_endpoint (
        .clk(clk), .reset(reset),
        .s_awid(s_awid), .s_awaddr(s_awaddr), .s_awlen(s_awlen),
        .s_awsize(s_awsize), .s_awvalid(s_awvalid), .s_awready(s_awready),
        .s_wdata(s_wdata), .s_wstrb(s_wstrb), .s_wlast(s_wlast),
        .s_wvalid(s_wvalid), .s_wready(s_wready),
        .s_bid(s_bid), .s_bresp(s_bresp), .s_bvalid(s_bvalid),
        .s_bready(s_bready),
        .s_arid(s_arid), .s_araddr(s_araddr), .s_arlen(s_arlen),
        .s_arsize(s_arsize), .s_arvalid(s_arvalid), .s_arready(s_arready),
        .s_rid(s_rid), .s_rdata(s_rdata), .s_rresp(s_rresp),
        .s_rlast(s_rlast), .s_rvalid(s_rvalid), .s_rready(s_rready),
        .write_pulse(write_pulse), .write_addr(write_addr),
        .write_data(write_data), .write_strb(write_strb),
        .write_resp(2'b00), .read_addr(read_addr),
        .read_data(read_data), .read_resp(2'b00)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cfg_enable <= 1'b0;
            cfg_black_hot <= 1'b0;
            cfg_toggle <= 1'b0;
            commit_count <= 0;
        end else if (write_pulse && write_addr[11:2] == 0 &&
                     write_strb[3] && write_data[31] && !pending) begin
            cfg_enable <= write_data[0];
            cfg_black_hot <= write_data[1];
            cfg_toggle <= ~cfg_toggle;
            commit_count <= commit_count + 1'b1;
        end
    end

    always @(*) begin
        case (read_addr[11:2])
            10'd0: read_data = {30'd0, cfg_black_hot, cfg_enable};
            10'd1: read_data = {commit_count, 12'd0, result_valid,
                                pending, cfg_black_hot, cfg_enable};
            10'd2: read_data = {6'd0, result_y, 5'd0, result_x};
            10'd3: read_data = {result_count, 4'd0, result_sum};
            10'd4: read_data = {dropped_result_count, result_count};
            default: read_data = 0;
        endcase
    end
endmodule
