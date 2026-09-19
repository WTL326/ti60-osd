`timescale 1ns / 1ps

// Readable platform identity and a scratch register used to prove that the
// soft-core peripheral AXI path is alive before feature commands are enabled.
module Ti60SystemControlRegs #(
    parameter [31:0] BUILD_ID = 32'h0000_0001
) (
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
    input  wire        s_rready
);
    localparam [31:0] PLATFORM_ID = 32'h4932_3339; // ASCII "I239"
    localparam [31:0] VERSION     = 32'h0001_0001; // ABI 1.1
    localparam [31:0] CAPABILITY  = 32'h0000_0007; // bit0 zoom, bit1 mask, bit2 hot focus

    wire        write_pulse;
    wire [31:0] write_addr;
    wire [31:0] write_data;
    wire [3:0]  write_strb;
    wire [31:0] read_addr;
    reg  [31:0] read_data;
    reg  [31:0] scratch;
    integer byte_index;

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
            scratch <= 32'd0;
        end else if (write_pulse && write_addr[11:2] == 10'd4) begin
            for (byte_index = 0; byte_index < 4; byte_index = byte_index + 1)
                if (write_strb[byte_index])
                    scratch[byte_index*8 +: 8] <=
                        write_data[byte_index*8 +: 8];
        end
    end

    always @(*) begin
        case (read_addr[11:2])
            10'd0: read_data = PLATFORM_ID;
            10'd1: read_data = VERSION;
            10'd2: read_data = CAPABILITY;
            10'd3: read_data = BUILD_ID;
            10'd4: read_data = scratch;
            default: read_data = 32'd0;
        endcase
    end
endmodule
