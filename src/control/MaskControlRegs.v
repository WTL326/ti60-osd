`timescale 1ns / 1ps

// 四路 OSD 的控制寄存器端点（D6 的 12 字映射）。
//
// 位图数据仍在 HyperRAM 里；这里只负责"把一组配置原子地发布出去"。
// 发布语义沿用既有做法：写 COMMAND 的 bit31 才提交，提交后由 cfg_toggle 翻转
// 通知跨时钟域的快照，再在帧边界（SOF）整体生效。bit31 这个约定让"误写"
// （比如只写了位置却没带提交位）不会产生任何效果。
//
// 寄存器映射（偏移 -> 字索引 = read_addr[11:2]）：
//   +0x00 w0  COMMAND  W  bit31 提交, bit0 全局使能
//   +0x04 w1  STATUS   R  {commit_count[15:0], 12'd0, pending, 1'b0, applied_global_enable}
//   +0x08 w2  CANVAS   R  {16'd720, 16'd576}（画面尺寸，与窗口无关，保持原样）
//   +0x0C w3  ACTIVE   R  {24'd0, applied_enable[3:0], applied_buffer_select[3:0]}
//   +0x10+8*i+0x0  OSD[i].POS  W  {8'd0, top[11:0], left[11:0]}   —— 均为**有符号**
//   +0x10+8*i+0x4  OSD[i].CTRL W  {30'd0, buffer_select, enable}
//   >= +0x30       R  读 0
//
// 为什么尺寸与基址不在这里：它们是综合期参数（D6），窗口几何属位流的一部分；
// 因此本文件**不提供** SIZE 与基址寄存器。
//
// 为什么 W 寄存器读回 0：D6 把 POS/CTRL 标为 W。需要回读时读 ACTIVE ——
// 它给的是**实际生效**的值，比"刚写进去但还没提交"的值更有意义。
module MaskControlRegs (
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

    // 已提交（待生效）的配置：由快照跨到视频时钟域
    output reg         cfg_global_enable,
    output reg  [3:0]  cfg_enable,
    output reg  [3:0]  cfg_buffer,
    output reg  signed [11:0] cfg_left0,
    output reg  signed [11:0] cfg_left1,
    output reg  signed [11:0] cfg_left2,
    output reg  signed [11:0] cfg_left3,
    output reg  signed [11:0] cfg_top0,
    output reg  signed [11:0] cfg_top1,
    output reg  signed [11:0] cfg_top2,
    output reg  signed [11:0] cfg_top3,
    output reg         cfg_toggle,
    input  wire        applied_toggle,

    // 实际生效的状态（来自叠加模块的帧锁存值，供 ACTIVE 回读）
    input  wire [3:0]  applied_enable,
    input  wire [3:0]  applied_buffer_select,
    input  wire        applied_global_enable,

    output reg  [15:0] commit_count
);
    wire        write_pulse;
    wire [31:0] write_addr;
    wire [31:0] write_data;
    wire [3:0]  write_strb;
    wire [31:0] read_addr;
    reg  [31:0] read_data;

    // pending = "已提交但尚未在帧边界生效"：两个 toggle 不一致即为待生效
    wire pending = cfg_toggle ^ applied_toggle;

    // 暂存区：写 POS/CTRL 只改这里，写 COMMAND 才把它整体推到 cfg_* 输出。
    // 这样"改了第 2 路的位置却没提交"不会影响任何一路 —— 原子提交的前提。
    reg [23:0] pos_stage  [0:3];   // {top[11:0], left[11:0]}
    reg [1:0]  ctrl_stage [0:3];   // {buffer_select, enable}

    // 路号 = (字节地址 >> 3) - 2。核对：0x10/0x14 -> 0，0x18/0x1C -> 1，
    // 0x20/0x24 -> 2，0x28/0x2C -> 3。
    // （首版写成 write_addr[4:3]，在 +0x20 以上会回绕，属典型的手算索引错。）
    wire [2:0] osd_sel = write_addr[5:3] - 3'd2;
    wire [1:0] osd_idx = osd_sel[1:0];

    integer i;

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

    //--------------------------------------------------------------------------
    // 写：暂存区（POS/CTRL）与提交（COMMAND）
    //--------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            cfg_global_enable <= 1'b0;
            cfg_enable        <= 4'd0;
            cfg_buffer        <= 4'd0;
            cfg_left0 <= 12'sd0;  cfg_left1 <= 12'sd0;
            cfg_left2 <= 12'sd0;  cfg_left3 <= 12'sd0;
            cfg_top0  <= 12'sd0;  cfg_top1  <= 12'sd0;
            cfg_top2  <= 12'sd0;  cfg_top3  <= 12'sd0;
            cfg_toggle        <= 1'b0;
            commit_count      <= 16'd0;
            for (i = 0; i < 4; i = i + 1) begin
                pos_stage[i]  <= 24'd0;
                ctrl_stage[i] <= 2'd0;
            end
        end else if (write_pulse) begin
            // bit[3] 的 byte strobe 对应最高字节，提交位在 bit31
            if (write_addr[11:2] == 10'd0) begin
                // COMMAND：只有带提交位且当前无待生效配置时才提交。
                // 待生效期间拒绝新提交 —— 否则"提交计数"与"实际生效的版本"会脱节，
                // 上位机轮询 pending 的流程也就失去意义。
                if (write_strb[3] && write_data[31] && !pending) begin
                    cfg_global_enable <= write_data[0];
                    cfg_left0 <= pos_stage[0][11:0];  cfg_top0 <= pos_stage[0][23:12];
                    cfg_left1 <= pos_stage[1][11:0];  cfg_top1 <= pos_stage[1][23:12];
                    cfg_left2 <= pos_stage[2][11:0];  cfg_top2 <= pos_stage[2][23:12];
                    cfg_left3 <= pos_stage[3][11:0];  cfg_top3 <= pos_stage[3][23:12];
                    cfg_buffer <= {ctrl_stage[3][1], ctrl_stage[2][1],
                                   ctrl_stage[1][1], ctrl_stage[0][1]};
                    cfg_enable <= {ctrl_stage[3][0], ctrl_stage[2][0],
                                   ctrl_stage[1][0], ctrl_stage[0][0]};
                    cfg_toggle    <= ~cfg_toggle;
                    commit_count  <= commit_count + 1'b1;
                end
            end else if ((write_addr[11:2] >= 10'd4) && (write_addr[11:2] <= 10'd11)) begin
                // OSD[i].POS / CTRL：字索引 4..11 交替为 POS/CTRL
                if (write_addr[2] == 1'b0)
                    pos_stage[osd_idx]  <= write_data[23:0];
                else
                    ctrl_stage[osd_idx] <= write_data[1:0];
            end
            // 其余地址（含 >= +0x30）忽略写
        end
    end

    //--------------------------------------------------------------------------
    // 读
    //--------------------------------------------------------------------------
    always @(*) begin
        case (read_addr[11:2])
            10'd0:   read_data = {31'd0, cfg_global_enable};   // COMMAND 为 W，只回读全局使能
            10'd1:   read_data = {commit_count, 13'd0, pending, 1'b0,
                                  applied_global_enable};
            10'd2:   read_data = {16'd720, 16'd576};
            10'd3:   read_data = {24'd0, applied_enable, applied_buffer_select};
            default: read_data = 32'd0;    // 含 POS/CTRL（W）与 +0x30 以上
        endcase
    end
endmodule
