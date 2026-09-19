`timescale 1ns / 1ps

// TI60 post-ISP control fabric.  This is the only sink of the Sapphire axiA
// peripheral master.  Address routing is inherited from the T120 AXI
// interconnect; feature endpoints remain small independent register blocks.
module Ti60AxiControlFabric #(
    parameter [31:0] BUILD_ID = 32'h0000_0001
) (
    input  wire        clk,
    input  wire        reset,

    input  wire        s_awvalid,
    output wire        s_awready,
    input  wire [31:0] s_awaddr,
    input  wire [7:0]  s_awid,
    input  wire [7:0]  s_awlen,
    input  wire [2:0]  s_awsize,
    input  wire [1:0]  s_awburst,
    input  wire        s_awlock,
    input  wire [3:0]  s_awcache,
    input  wire [2:0]  s_awprot,
    input  wire [3:0]  s_awqos,
    input  wire        s_wvalid,
    output wire        s_wready,
    input  wire [31:0] s_wdata,
    input  wire [3:0]  s_wstrb,
    input  wire        s_wlast,
    output wire        s_bvalid,
    input  wire        s_bready,
    output wire [7:0]  s_bid,
    output wire [1:0]  s_bresp,

    input  wire        s_arvalid,
    output wire        s_arready,
    input  wire [31:0] s_araddr,
    input  wire [7:0]  s_arid,
    input  wire [7:0]  s_arlen,
    input  wire [2:0]  s_arsize,
    input  wire [1:0]  s_arburst,
    input  wire        s_arlock,
    input  wire [3:0]  s_arcache,
    input  wire [2:0]  s_arprot,
    input  wire [3:0]  s_arqos,
    output wire        s_rvalid,
    input  wire        s_rready,
    output wire [31:0] s_rdata,
    output wire [7:0]  s_rid,
    output wire [1:0]  s_rresp,
    output wire        s_rlast,

    output wire        zoom_cfg_enable,
    output wire [10:0] zoom_cfg_left,
    output wire [10:0] zoom_cfg_top,
    output wire [10:0] zoom_cfg_width,
    output wire [10:0] zoom_cfg_height,
    output wire        zoom_cfg_toggle,
    input  wire        zoom_applied_toggle,
    output wire [15:0] zoom_accepted_count,
    output wire [15:0] zoom_rejected_count,

    output wire        mask_cfg_enable,
    output wire        mask_cfg_buffer_select,
    output wire        mask_cfg_toggle,
    input  wire        mask_applied_toggle,
    output wire [15:0] mask_commit_count,

    output wire        hot_cfg_enable,
    output wire        hot_cfg_black_hot,
    output wire        hot_cfg_toggle,
    input  wire        hot_applied_toggle,
    input  wire [10:0] hot_result_x,
    input  wire [9:0]  hot_result_y,
    input  wire [11:0] hot_result_sum,
    input  wire        hot_result_valid,
    input  wire [15:0] hot_result_count,
    input  wire [15:0] hot_dropped_result_count,
    output wire [15:0] hot_commit_count
);
    localparam integer M_COUNT = 4;
    localparam integer SYS_INDEX  = 0;
    localparam integer ZOOM_INDEX = 1;
    localparam integer HOT_INDEX  = 2;
    localparam integer MASK_INDEX = 3;

    wire [M_COUNT*8-1:0]  m_awid;
    wire [M_COUNT*32-1:0] m_awaddr;
    wire [M_COUNT*8-1:0]  m_awlen;
    wire [M_COUNT*3-1:0]  m_awsize;
    wire [M_COUNT*2-1:0]  m_awburst;
    wire [M_COUNT-1:0]    m_awlock;
    wire [M_COUNT*4-1:0]  m_awcache;
    wire [M_COUNT*3-1:0]  m_awprot;
    wire [M_COUNT*4-1:0]  m_awqos;
    wire [M_COUNT*4-1:0]  m_awregion;
    wire [M_COUNT-1:0]    m_awvalid;
    wire [M_COUNT-1:0]    m_awready;
    wire [M_COUNT*32-1:0] m_wdata;
    wire [M_COUNT*4-1:0]  m_wstrb;
    wire [M_COUNT-1:0]    m_wlast;
    wire [M_COUNT-1:0]    m_wvalid;
    wire [M_COUNT-1:0]    m_wready;
    wire [M_COUNT*8-1:0]  m_bid;
    wire [M_COUNT*2-1:0]  m_bresp;
    wire [M_COUNT-1:0]    m_bvalid;
    wire [M_COUNT-1:0]    m_bready;
    wire [M_COUNT*8-1:0]  m_arid;
    wire [M_COUNT*32-1:0] m_araddr;
    wire [M_COUNT*8-1:0]  m_arlen;
    wire [M_COUNT*3-1:0]  m_arsize;
    wire [M_COUNT*2-1:0]  m_arburst;
    wire [M_COUNT-1:0]    m_arlock;
    wire [M_COUNT*4-1:0]  m_arcache;
    wire [M_COUNT*3-1:0]  m_arprot;
    wire [M_COUNT*4-1:0]  m_arqos;
    wire [M_COUNT*4-1:0]  m_arregion;
    wire [M_COUNT-1:0]    m_arvalid;
    wire [M_COUNT-1:0]    m_arready;
    wire [M_COUNT*8-1:0]  m_rid;
    wire [M_COUNT*32-1:0] m_rdata;
    wire [M_COUNT*2-1:0]  m_rresp;
    wire [M_COUNT-1:0]    m_rlast;
    wire [M_COUNT-1:0]    m_rvalid;
    wire [M_COUNT-1:0]    m_rready;

    axi_interconnect #(
        .S_COUNT(1), .M_COUNT(M_COUNT), .DATA_WIDTH(32),
        .ADDR_WIDTH(32), .STRB_WIDTH(4), .ID_WIDTH(8),
        .FORWARD_ID(1),
        // Master index zero occupies the least-significant packed slice.
        .M_BASE_ADDR({32'he104_3000, 32'he104_0000,
                      32'he101_3000, 32'he100_0000}),
        .M_ADDR_WIDTH({32'd12, 32'd12, 32'd12, 32'd12})
    ) u_interconnect (
        .clk(clk), .rst(reset),
        .s_axi_awid(s_awid), .s_axi_awaddr(s_awaddr),
        .s_axi_awlen(s_awlen), .s_axi_awsize(s_awsize),
        .s_axi_awburst(s_awburst), .s_axi_awlock(s_awlock),
        .s_axi_awcache(s_awcache), .s_axi_awprot(s_awprot),
        .s_axi_awqos(s_awqos), .s_axi_awuser(1'b0),
        .s_axi_awvalid(s_awvalid), .s_axi_awready(s_awready),
        .s_axi_wdata(s_wdata), .s_axi_wstrb(s_wstrb),
        .s_axi_wlast(s_wlast), .s_axi_wuser(1'b0),
        .s_axi_wvalid(s_wvalid), .s_axi_wready(s_wready),
        .s_axi_bid(s_bid), .s_axi_bresp(s_bresp), .s_axi_buser(),
        .s_axi_bvalid(s_bvalid), .s_axi_bready(s_bready),
        .s_axi_arid(s_arid), .s_axi_araddr(s_araddr),
        .s_axi_arlen(s_arlen), .s_axi_arsize(s_arsize),
        .s_axi_arburst(s_arburst), .s_axi_arlock(s_arlock),
        .s_axi_arcache(s_arcache), .s_axi_arprot(s_arprot),
        .s_axi_arqos(s_arqos), .s_axi_aruser(1'b0),
        .s_axi_arvalid(s_arvalid), .s_axi_arready(s_arready),
        .s_axi_rid(s_rid), .s_axi_rdata(s_rdata),
        .s_axi_rresp(s_rresp), .s_axi_rlast(s_rlast), .s_axi_ruser(),
        .s_axi_rvalid(s_rvalid), .s_axi_rready(s_rready),

        .m_axi_awid(m_awid), .m_axi_awaddr(m_awaddr),
        .m_axi_awlen(m_awlen), .m_axi_awsize(m_awsize),
        .m_axi_awburst(m_awburst), .m_axi_awlock(m_awlock),
        .m_axi_awcache(m_awcache), .m_axi_awprot(m_awprot),
        .m_axi_awqos(m_awqos), .m_axi_awregion(m_awregion),
        .m_axi_awuser(), .m_axi_awvalid(m_awvalid),
        .m_axi_awready(m_awready),
        .m_axi_wdata(m_wdata), .m_axi_wstrb(m_wstrb),
        .m_axi_wlast(m_wlast), .m_axi_wuser(),
        .m_axi_wvalid(m_wvalid), .m_axi_wready(m_wready),
        .m_axi_bid(m_bid), .m_axi_bresp(m_bresp), .m_axi_buser(4'b0000),
        .m_axi_bvalid(m_bvalid), .m_axi_bready(m_bready),
        .m_axi_arid(m_arid), .m_axi_araddr(m_araddr),
        .m_axi_arlen(m_arlen), .m_axi_arsize(m_arsize),
        .m_axi_arburst(m_arburst), .m_axi_arlock(m_arlock),
        .m_axi_arcache(m_arcache), .m_axi_arprot(m_arprot),
        .m_axi_arqos(m_arqos), .m_axi_arregion(m_arregion),
        .m_axi_aruser(), .m_axi_arvalid(m_arvalid),
        .m_axi_arready(m_arready),
        .m_axi_rid(m_rid), .m_axi_rdata(m_rdata),
        .m_axi_rresp(m_rresp), .m_axi_rlast(m_rlast),
        .m_axi_ruser(4'b0000), .m_axi_rvalid(m_rvalid),
        .m_axi_rready(m_rready)
    );

    Ti60SystemControlRegs #(.BUILD_ID(BUILD_ID)) u_system_regs (
        .clk(clk), .reset(reset),
        .s_awid(m_awid[SYS_INDEX*8 +: 8]),
        .s_awaddr(m_awaddr[SYS_INDEX*32 +: 32]),
        .s_awlen(m_awlen[SYS_INDEX*8 +: 8]),
        .s_awsize(m_awsize[SYS_INDEX*3 +: 3]),
        .s_awvalid(m_awvalid[SYS_INDEX]), .s_awready(m_awready[SYS_INDEX]),
        .s_wdata(m_wdata[SYS_INDEX*32 +: 32]),
        .s_wstrb(m_wstrb[SYS_INDEX*4 +: 4]), .s_wlast(m_wlast[SYS_INDEX]),
        .s_wvalid(m_wvalid[SYS_INDEX]), .s_wready(m_wready[SYS_INDEX]),
        .s_bid(m_bid[SYS_INDEX*8 +: 8]),
        .s_bresp(m_bresp[SYS_INDEX*2 +: 2]),
        .s_bvalid(m_bvalid[SYS_INDEX]), .s_bready(m_bready[SYS_INDEX]),
        .s_arid(m_arid[SYS_INDEX*8 +: 8]),
        .s_araddr(m_araddr[SYS_INDEX*32 +: 32]),
        .s_arlen(m_arlen[SYS_INDEX*8 +: 8]),
        .s_arsize(m_arsize[SYS_INDEX*3 +: 3]),
        .s_arvalid(m_arvalid[SYS_INDEX]), .s_arready(m_arready[SYS_INDEX]),
        .s_rid(m_rid[SYS_INDEX*8 +: 8]),
        .s_rdata(m_rdata[SYS_INDEX*32 +: 32]),
        .s_rresp(m_rresp[SYS_INDEX*2 +: 2]), .s_rlast(m_rlast[SYS_INDEX]),
        .s_rvalid(m_rvalid[SYS_INDEX]), .s_rready(m_rready[SYS_INDEX])
    );

    ElectronicZoomControlRegs u_zoom_regs (
        .clk(clk), .reset(reset),
        .s_awid(m_awid[ZOOM_INDEX*8 +: 8]),
        .s_awaddr(m_awaddr[ZOOM_INDEX*32 +: 32]),
        .s_awlen(m_awlen[ZOOM_INDEX*8 +: 8]),
        .s_awsize(m_awsize[ZOOM_INDEX*3 +: 3]),
        .s_awvalid(m_awvalid[ZOOM_INDEX]), .s_awready(m_awready[ZOOM_INDEX]),
        .s_wdata(m_wdata[ZOOM_INDEX*32 +: 32]),
        .s_wstrb(m_wstrb[ZOOM_INDEX*4 +: 4]), .s_wlast(m_wlast[ZOOM_INDEX]),
        .s_wvalid(m_wvalid[ZOOM_INDEX]), .s_wready(m_wready[ZOOM_INDEX]),
        .s_bid(m_bid[ZOOM_INDEX*8 +: 8]),
        .s_bresp(m_bresp[ZOOM_INDEX*2 +: 2]),
        .s_bvalid(m_bvalid[ZOOM_INDEX]), .s_bready(m_bready[ZOOM_INDEX]),
        .s_arid(m_arid[ZOOM_INDEX*8 +: 8]),
        .s_araddr(m_araddr[ZOOM_INDEX*32 +: 32]),
        .s_arlen(m_arlen[ZOOM_INDEX*8 +: 8]),
        .s_arsize(m_arsize[ZOOM_INDEX*3 +: 3]),
        .s_arvalid(m_arvalid[ZOOM_INDEX]), .s_arready(m_arready[ZOOM_INDEX]),
        .s_rid(m_rid[ZOOM_INDEX*8 +: 8]),
        .s_rdata(m_rdata[ZOOM_INDEX*32 +: 32]),
        .s_rresp(m_rresp[ZOOM_INDEX*2 +: 2]), .s_rlast(m_rlast[ZOOM_INDEX]),
        .s_rvalid(m_rvalid[ZOOM_INDEX]), .s_rready(m_rready[ZOOM_INDEX]),
        .cfg_enable(zoom_cfg_enable), .cfg_left(zoom_cfg_left),
        .cfg_top(zoom_cfg_top), .cfg_width(zoom_cfg_width),
        .cfg_height(zoom_cfg_height), .cfg_toggle(zoom_cfg_toggle),
        .applied_toggle(zoom_applied_toggle),
        .accepted_count(zoom_accepted_count),
        .rejected_count(zoom_rejected_count)
    );

    HotFocusControlRegs u_hot_regs (
        .clk(clk), .reset(reset),
        .s_awid(m_awid[HOT_INDEX*8 +: 8]),
        .s_awaddr(m_awaddr[HOT_INDEX*32 +: 32]),
        .s_awlen(m_awlen[HOT_INDEX*8 +: 8]),
        .s_awsize(m_awsize[HOT_INDEX*3 +: 3]),
        .s_awvalid(m_awvalid[HOT_INDEX]), .s_awready(m_awready[HOT_INDEX]),
        .s_wdata(m_wdata[HOT_INDEX*32 +: 32]),
        .s_wstrb(m_wstrb[HOT_INDEX*4 +: 4]), .s_wlast(m_wlast[HOT_INDEX]),
        .s_wvalid(m_wvalid[HOT_INDEX]), .s_wready(m_wready[HOT_INDEX]),
        .s_bid(m_bid[HOT_INDEX*8 +: 8]),
        .s_bresp(m_bresp[HOT_INDEX*2 +: 2]),
        .s_bvalid(m_bvalid[HOT_INDEX]), .s_bready(m_bready[HOT_INDEX]),
        .s_arid(m_arid[HOT_INDEX*8 +: 8]),
        .s_araddr(m_araddr[HOT_INDEX*32 +: 32]),
        .s_arlen(m_arlen[HOT_INDEX*8 +: 8]),
        .s_arsize(m_arsize[HOT_INDEX*3 +: 3]),
        .s_arvalid(m_arvalid[HOT_INDEX]), .s_arready(m_arready[HOT_INDEX]),
        .s_rid(m_rid[HOT_INDEX*8 +: 8]),
        .s_rdata(m_rdata[HOT_INDEX*32 +: 32]),
        .s_rresp(m_rresp[HOT_INDEX*2 +: 2]), .s_rlast(m_rlast[HOT_INDEX]),
        .s_rvalid(m_rvalid[HOT_INDEX]), .s_rready(m_rready[HOT_INDEX]),
        .cfg_enable(hot_cfg_enable), .cfg_black_hot(hot_cfg_black_hot),
        .cfg_toggle(hot_cfg_toggle), .applied_toggle(hot_applied_toggle),
        .result_x(hot_result_x), .result_y(hot_result_y),
        .result_sum(hot_result_sum), .result_valid(hot_result_valid),
        .result_count(hot_result_count),
        .dropped_result_count(hot_dropped_result_count),
        .commit_count(hot_commit_count)
    );

    MaskControlRegs u_mask_regs (
        .clk(clk), .reset(reset),
        .s_awid(m_awid[MASK_INDEX*8 +: 8]),
        .s_awaddr(m_awaddr[MASK_INDEX*32 +: 32]),
        .s_awlen(m_awlen[MASK_INDEX*8 +: 8]),
        .s_awsize(m_awsize[MASK_INDEX*3 +: 3]),
        .s_awvalid(m_awvalid[MASK_INDEX]), .s_awready(m_awready[MASK_INDEX]),
        .s_wdata(m_wdata[MASK_INDEX*32 +: 32]),
        .s_wstrb(m_wstrb[MASK_INDEX*4 +: 4]), .s_wlast(m_wlast[MASK_INDEX]),
        .s_wvalid(m_wvalid[MASK_INDEX]), .s_wready(m_wready[MASK_INDEX]),
        .s_bid(m_bid[MASK_INDEX*8 +: 8]),
        .s_bresp(m_bresp[MASK_INDEX*2 +: 2]),
        .s_bvalid(m_bvalid[MASK_INDEX]), .s_bready(m_bready[MASK_INDEX]),
        .s_arid(m_arid[MASK_INDEX*8 +: 8]),
        .s_araddr(m_araddr[MASK_INDEX*32 +: 32]),
        .s_arlen(m_arlen[MASK_INDEX*8 +: 8]),
        .s_arsize(m_arsize[MASK_INDEX*3 +: 3]),
        .s_arvalid(m_arvalid[MASK_INDEX]), .s_arready(m_arready[MASK_INDEX]),
        .s_rid(m_rid[MASK_INDEX*8 +: 8]),
        .s_rdata(m_rdata[MASK_INDEX*32 +: 32]),
        .s_rresp(m_rresp[MASK_INDEX*2 +: 2]), .s_rlast(m_rlast[MASK_INDEX]),
        .s_rvalid(m_rvalid[MASK_INDEX]), .s_rready(m_rready[MASK_INDEX]),
        .cfg_enable(mask_cfg_enable),
        .cfg_buffer_select(mask_cfg_buffer_select),
        .cfg_toggle(mask_cfg_toggle), .applied_toggle(mask_applied_toggle),
        .commit_count(mask_commit_count)
    );
endmodule
