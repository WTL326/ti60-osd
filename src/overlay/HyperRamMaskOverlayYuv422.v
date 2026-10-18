`timescale 1ns / 1ps
//============================================================================
// HyperRamMaskOverlayYuv422 : 四区域 OSD 叠加引擎 (1bit/像素)
//----------------------------------------------------------------------------
// 功能:
//   在 YUV422 视频流(16bit/像素)上叠加最多 4 块互不重叠的 OSD 位图。
//   位图存于 HyperRAM, 每 bit 对应一个像素: 0=视频透传, 1=叠加纯白
//   (Y=235, Cb/Cr=128, 即 16'h80EB)。
//   位图按行打包: 每行 OSD_WIDTH/8 字节, 故 OSD_WIDTH 必须能被 8 整除。
//   限制: OSD 宽/高不超过 2048; 基址建议 256 字节对齐。
//
// 位置配置:
//   mask_0..mask_3: [31:16]=列坐标 left(有符号), [15:0]=行坐标 top(有符号)。
//   允许负坐标, 窗口外像素自动裁剪(视频透传)。
//   mask_enable[3:0]: 每个 OSD 独立使能。
//   mask_buffer_select: 4 块 OSD 共用的双缓冲画布选择(A/B)。
//   4 个区域保证互不重叠, 命中选择按编号优先(0 最高)。
//
// 微架构 (目标 150MHz 以上):
//   11 级全寄存流水线, 每级之间组合逻辑不超过 4 级:
//     S0 输入采样/坐标计数 -> S1 dx/dy -> S2 窗口命中 -> S3 区域选择
//     -> S4 行偏移/基址 -> S5 字节地址 -> S6 cache 读与命中判断
//     -> S7 bank 选择 -> S8 字节提取 -> S9 遮罩位寄存 -> S10 混合输出
//   两段推进式反压: 域1(S0..S6, 遮罩字未捕获)在 cache 未命中时冻结等待
//   AXI 读完成; 域2(S7..S10, 遮罩字已捕获)只要下游能收就继续排空,
//   保证 ready/valid 协议正确(已完成传输的像素不会被重复呈现)。
//   双 bank(各 256 字节)乒乓: 一个 bank 服务当前像素, 另一个预取下一块。
//   AXI 读取: 16 拍 x 128bit INCR 突发, ID 固定 8'hA1, 与原模块一致。
// 综合友好:
//   遮罩字节提取用显式 case(16:1) 而非 128bit 变量移位(避免宽桶形移位器);
//   全部状态寄存器化, 每级之间组合逻辑约 <=5 级 LUT, 目标 150MHz 以上。
//============================================================================
module HyperRamMaskOverlayYuv422 #(
    // OSD0 尺寸(宽必须能被 8 整除, 见展开期参数检查)与双缓冲基址
    parameter integer OSD0_WIDTH  = 256,
    parameter integer OSD0_HEIGHT = 128,
    parameter [31:0]  OSD0_BASE_A = 32'h0040_0000,
    parameter [31:0]  OSD0_BASE_B = 32'h0040_1000,
    // OSD1 尺寸与双缓冲基址
    parameter integer OSD1_WIDTH  = 256,
    parameter integer OSD1_HEIGHT = 128,
    parameter [31:0]  OSD1_BASE_A = 32'h0050_0000,
    parameter [31:0]  OSD1_BASE_B = 32'h0050_1000,
    // OSD2 尺寸与双缓冲基址
    parameter integer OSD2_WIDTH  = 256,
    parameter integer OSD2_HEIGHT = 128,
    parameter [31:0]  OSD2_BASE_A = 32'h0060_0000,
    parameter [31:0]  OSD2_BASE_B = 32'h0060_1000,
    // OSD3 尺寸与双缓冲基址
    parameter integer OSD3_WIDTH  = 256,
    parameter integer OSD3_HEIGHT = 128,
    parameter [31:0]  OSD3_BASE_A = 32'h0070_0000,
    parameter [31:0]  OSD3_BASE_B = 32'h0070_1000,
    // 视频帧尺寸与坐标翻转(下游 DMA 垂直翻转时置 1)
    parameter integer FRAME_WIDTH  = 720,
    parameter integer FRAME_HEIGHT = 576,
    parameter integer FLIP_VERTICAL_COORDS = 0
) (
    // 时钟与复位
    input  wire         clk,
    input  wire         reset,
    // 配置快照: 由 top.v 的 ConfigSnapshotCdc 直连(共 105 bit)。
    // 本模块**不再自带同步器** —— CDC 责任单一归快照, 见 design.md D5。
    input  wire         cfg_global_enable,   // 全局使能 (D6 COMMAND.bit0)
    input  wire [3:0]   cfg_enable,          // 每路独立使能
    input  wire [3:0]   cfg_buffer,          // 每路独立 A/B 画布选择
    // 4 路起始坐标, 均为**有符号 12 bit** (D6): 负值即窗口部分移出画面
    input  wire signed [11:0] cfg_left0,
    input  wire signed [11:0] cfg_left1,
    input  wire signed [11:0] cfg_left2,
    input  wire signed [11:0] cfg_left3,
    input  wire signed [11:0] cfg_top0,
    input  wire signed [11:0] cfg_top1,
    input  wire signed [11:0] cfg_top2,
    input  wire signed [11:0] cfg_top3,
    // 视频流从接口
    input  wire [15:0]  s_data,
    input  wire         s_valid,
    input  wire         s_sof,
    input  wire         s_eol,
    output wire         s_ready,
    // 视频流主接口(叠加后输出)
    output reg  [15:0]  m_data,
    output reg          m_valid,
    output reg          m_sof,
    output reg          m_eol,
    input  wire         m_ready,
    // AXI 读地址通道(固定参数的 16 拍突发读)
    output wire         avalid,
    input  wire         aready,
    output wire [31:0]  aaddr,
    output wire [7:0]   aid,
    output wire [7:0]   alen,
    output wire [2:0]   asize,
    output wire [1:0]   aburst,
    output wire [1:0]   alock,
    output wire         atype,
    // AXI 读数据/响应通道
    input  wire [7:0]   rid,
    input  wire [127:0] rdata,
    input  wire         rlast,
    input  wire         rvalid,
    output wire         rready,
    input  wire [1:0]   rresp,
    // 诊断输出口
    output reg  [15:0]  frame_count,
    output reg  [15:0]  read_error_count,
    output wire         active,
    // 每路当前**实际生效**的 A/B 选择与使能（帧锁存值，供 ACTIVE 回读，D6）
    output reg  [3:0]   active_buffer_select,
    output wire [3:0]   applied_enable,
    // 因等待位图而阻塞视频流的累计周期数（D6 诊断）。宽 32 位以免长时间累加回绕
    output reg  [31:0]  stall_count
);

    //--------------------------------------------------------------------------
    // 本地参数
    //--------------------------------------------------------------------------
    localparam integer CACHE_BEATS = 16;          // 每次突发 16 拍 = 256 字节
    localparam [7:0]   CACHE_AXLEN = CACHE_BEATS - 1;
    localparam integer BPR0 = OSD0_WIDTH / 8;     // 各 OSD 每行字节数
    localparam integer BPR1 = OSD1_WIDTH / 8;
    localparam integer BPR2 = OSD2_WIDTH / 8;
    localparam integer BPR3 = OSD3_WIDTH / 8;
    localparam [1:0] ST_IDLE = 2'd0;              // AXI 读状态机
    localparam [1:0] ST_ADDR = 2'd1;
    localparam [1:0] ST_DATA = 2'd2;

    //--------------------------------------------------------------------------
    // 展开期参数合法性检查 (D6)
    //
    // 约束: 每路 width % 8 == 0 且 8 <= width <= 544, 1 <= height <= 288。
    //       width 必须能被 8 整除是因为位图按字节打包(每行 width/8 字节);
    //       上限 544/288 是 D6 定的单路最大尺寸。
    //
    // 手法: 参数非法时例化一个**不存在**的模块。于是 vlog 与综合在展开期就直接失败,
    //       而且报错信息里带着那个模块名 —— 名字本身就是诊断信息(哪一路、哪个参数、
    //       是"未按 8 对齐"还是"超出范围")。
    //
    // 为什么不用 $error: 写在 initial 块里的 $error 是**运行期**(时刻 0)才触发,
    //       编译本身照样通过。而这里要挡住的恰恰是"编译能过、上板才发现画面错位"
    //       这一类问题 —— 位图行跨距算错不会报错, 只会让画面整体错位。
    //--------------------------------------------------------------------------
    localparam W0_ALIGN_BAD = ((OSD0_WIDTH % 8) != 0);
    localparam W1_ALIGN_BAD = ((OSD1_WIDTH % 8) != 0);
    localparam W2_ALIGN_BAD = ((OSD2_WIDTH % 8) != 0);
    localparam W3_ALIGN_BAD = ((OSD3_WIDTH % 8) != 0);
    localparam W0_RANGE_BAD = (OSD0_WIDTH < 8)   || (OSD0_WIDTH > 544);
    localparam W1_RANGE_BAD = (OSD1_WIDTH < 8)   || (OSD1_WIDTH > 544);
    localparam W2_RANGE_BAD = (OSD2_WIDTH < 8)   || (OSD2_WIDTH > 544);
    localparam W3_RANGE_BAD = (OSD3_WIDTH < 8)   || (OSD3_WIDTH > 544);
    localparam H0_RANGE_BAD = (OSD0_HEIGHT < 1)  || (OSD0_HEIGHT > 288);
    localparam H1_RANGE_BAD = (OSD1_HEIGHT < 1)  || (OSD1_HEIGHT > 288);
    localparam H2_RANGE_BAD = (OSD2_HEIGHT < 1)  || (OSD2_HEIGHT > 288);
    localparam H3_RANGE_BAD = (OSD3_HEIGHT < 1)  || (OSD3_HEIGHT > 288);

    generate
        if (W0_ALIGN_BAD) begin : g_chk_w0a
            OSD0_WIDTH_must_be_a_multiple_of_8 u_err();
        end
        if (W1_ALIGN_BAD) begin : g_chk_w1a
            OSD1_WIDTH_must_be_a_multiple_of_8 u_err();
        end
        if (W2_ALIGN_BAD) begin : g_chk_w2a
            OSD2_WIDTH_must_be_a_multiple_of_8 u_err();
        end
        if (W3_ALIGN_BAD) begin : g_chk_w3a
            OSD3_WIDTH_must_be_a_multiple_of_8 u_err();
        end
        if (W0_RANGE_BAD) begin : g_chk_w0r
            OSD0_WIDTH_must_be_within_8_to_544 u_err();
        end
        if (W1_RANGE_BAD) begin : g_chk_w1r
            OSD1_WIDTH_must_be_within_8_to_544 u_err();
        end
        if (W2_RANGE_BAD) begin : g_chk_w2r
            OSD2_WIDTH_must_be_within_8_to_544 u_err();
        end
        if (W3_RANGE_BAD) begin : g_chk_w3r
            OSD3_WIDTH_must_be_within_8_to_544 u_err();
        end
        if (H0_RANGE_BAD) begin : g_chk_h0r
            OSD0_HEIGHT_must_be_within_1_to_288 u_err();
        end
        if (H1_RANGE_BAD) begin : g_chk_h1r
            OSD1_HEIGHT_must_be_within_1_to_288 u_err();
        end
        if (H2_RANGE_BAD) begin : g_chk_h2r
            OSD2_HEIGHT_must_be_within_1_to_288 u_err();
        end
        if (H3_RANGE_BAD) begin : g_chk_h3r
            OSD3_HEIGHT_must_be_within_1_to_288 u_err();
        end
    endgenerate

    //--------------------------------------------------------------------------
    // 帧内锁存配置: SOF 采样, 一帧之内保持不变(防撕裂)
    //
    // 配置由 top.v 的 ConfigSnapshotCdc 同步后直连本模块, 本模块内不再有同步器。
    // 那组同步器（enable_meta/sync、pos*_meta/sync、buffer_sync）已按 D5 删除：
    // CDC 只由快照承担一处，top.v 里为补偿它们而写的 3 拍 settle 也随之取消。
    //--------------------------------------------------------------------------
    reg        frame_global_enable;
    reg [3:0]  frame_enable;      // 每路使能 (已与全局使能相与)
    reg [3:0]  frame_buffer;      // 每路 A/B 选择
    reg signed [11:0] frame_left0, frame_left1, frame_left2, frame_left3;
    reg signed [11:0] frame_top0,  frame_top1,  frame_top2,  frame_top3;

    // S1 取用的位置源: SOF 像素当拍必须用最新配置值(帧锁存与 S1 计算
    // 同沿写入, 若 S1 读 frame_* 会拿到上一帧旧坐标, 帧首像素错位)
    wire signed [11:0] left0_s1 = s_sof ? cfg_left0 : frame_left0;
    wire signed [11:0] left1_s1 = s_sof ? cfg_left1 : frame_left1;
    wire signed [11:0] left2_s1 = s_sof ? cfg_left2 : frame_left2;
    wire signed [11:0] left3_s1 = s_sof ? cfg_left3 : frame_left3;
    wire signed [11:0] top0_s1  = s_sof ? cfg_top0  : frame_top0;
    wire signed [11:0] top1_s1  = s_sof ? cfg_top1  : frame_top1;
    wire signed [11:0] top2_s1  = s_sof ? cfg_top2  : frame_top2;
    wire signed [11:0] top3_s1  = s_sof ? cfg_top3  : frame_top3;

    //--------------------------------------------------------------------------
    // 像素坐标计数 (S0)
    //--------------------------------------------------------------------------
    reg [10:0] x_count;
    reg [10:0] y_count;
    // 下游 DMA 垂直翻转时, 遮罩按最终显示行取址
    wire [10:0] disp_y = FLIP_VERTICAL_COORDS ?
                         (FRAME_HEIGHT - 1 - y_count) : y_count;

    //--------------------------------------------------------------------------
    // 流水线主体: 数据/标志数组 (S0..S8, S9 为输出级)
    //--------------------------------------------------------------------------
    reg [15:0] pdata   [0:8];
    reg        psof    [0:8];
    reg        peol    [0:8];
    reg        pvalid  [0:8];
    reg        phit    [4:8];   // 命中标志: phit[k] 与 pdata[k-1] 同级像素
    reg [2:0]  pbitsel [4:8];   // 行内位选择 = srcx[2:0], 随 phit 逐级移位

    // S1: 各 OSD 窗口相对坐标(有符号)
    reg signed [16:0] s1_dx0;
    reg signed [16:0] s1_dx1;
    reg signed [16:0] s1_dx2;
    reg signed [16:0] s1_dx3;
    reg signed [16:0] s1_dy0;
    reg signed [16:0] s1_dy1;
    reg signed [16:0] s1_dy2;
    reg signed [16:0] s1_dy3;

    // S2: 各 OSD 窗口命中标志与窗口内坐标(命中时有效)
    reg [3:0]  s2_h;
    reg [10:0] s2_x0;
    reg [10:0] s2_x1;
    reg [10:0] s2_x2;
    reg [10:0] s2_x3;
    reg [10:0] s2_y0;
    reg [10:0] s2_y1;
    reg [10:0] s2_y2;
    reg [10:0] s2_y3;

    // S3: 命中区域编号/总命中/选中坐标
    reg [1:0]  s3_sel;
    reg        s3_hit;
    reg [10:0] s3_srcx;
    reg [10:0] s3_srcy;

    // S4: 行字节偏移与画布基址
    reg [23:0] s4_rowoff;
    reg [31:0] s4_base;
    reg [7:0]  s4_colbyte;   // srcx[10:3]: 行内字节列号

    // S5: 遮罩字节地址
    reg [31:0] s5_byteaddr;

    // S6: cache 读出的字与 bank 命中标志(无停顿时每拍刷新)
    reg [31:0] s6_byteaddr;
    reg [127:0] s6_c0word;
    reg [127:0] s6_c1word;
    reg         s6_c0hit;
    reg         s6_c1hit;

    // S7: bank 选择后的字与字节选择
    reg [127:0] s7_word;
    reg [3:0]   s7_bytesel;

    // S8: 从 128bit 字中提取的遮罩字节
    reg [7:0]   s8_byte;

    // S9: 遮罩位寄存 (与 pdata[8] 级像素对齐, 保证位选与数据同级)
    reg         s9_maskbit;

    // 每路实际生效的使能 = 帧锁存值（全局使能已在锁存处相与）
    assign applied_enable = frame_enable;

    //--------------------------------------------------------------------------
    // 双 bank 乒乓缓存 (各 256 字节 = 16 x 128bit)
    //--------------------------------------------------------------------------
    reg [127:0] cache0_data [0:CACHE_BEATS-1];
    reg [127:0] cache1_data [0:CACHE_BEATS-1];
    reg [31:0]  cache0_addr;
    reg [31:0]  cache1_addr;
    reg         cache0_valid;
    reg         cache1_valid;

    // AXI 读状态机
    reg [1:0]  rd_state;
    reg [31:0] requested_addr;
    reg        fill_bank;
    reg [4:0]  fill_beat;
    reg        replace_bank;
    reg        fill_done_pulse;  // rlast 后一拍有效: 抑制对同一块的重复需求读

    //--------------------------------------------------------------------------
    // 反压/推进控制: 两段流水域 (全部由寄存器状态导出, 组合不超过 3 级)
    //   域1 = S0..S6 : 遮罩字尚未捕获的像素, cache miss 时必须冻结
    //   域2 = S7..S10: 遮罩字已随像素捕获, 只要下游能收就继续排空,
    //                   避免 miss 停顿期间输出级冻结、下游重复采样同一像素
    //--------------------------------------------------------------------------
    wire out_free  = m_ready || !m_valid;
    wire s6_hitany = s6_c0hit | s6_c1hit;
    // 注意: phit[6]/s6_* 对应 pdata[5] 级像素, 有效标志须取 pvalid[5]
    wire miss_block = pvalid[5] && phit[6] && !s6_hitany;
    wire adv2 = out_free;                  // 域2推进: 输出级可接收
    wire adv1 = out_free && !miss_block;   // 域1推进: 输出级可收且当前块命中
    assign s_ready = adv1;

    // 因等待位图而阻塞视频流的累计周期数。
    // 判据取 miss_block(而不是 !adv1): !adv1 也包含"下游背压"造成的停顿,
    // 那种停顿不是位图取数引起的, 计进来会让这个数失去诊断意义。
    always @(posedge clk or posedge reset) begin
        if (reset) stall_count <= 32'd0;
        else if (miss_block) stall_count <= stall_count + 32'd1;
    end
    wire input_take = s_valid && adv1;

    // S6 刷新地址: 域1 推进时取即将进入 S6 的像素地址, 停顿时取当前地址,
    // 保证 cache 填充完成后命中标志能自动变高(解除停顿)
    wire [31:0] s6_eff_addr = adv1 ? s5_byteaddr : s6_byteaddr;

    //--------------------------------------------------------------------------
    // 扫描序预取目标 (D4)
    //
    // 为什么不能沿用"内存序下一块" (block_addr + 256):
    //   1 bit/像素 + 紧凑跨距下, 一个 256 字节块横跨 256/(W/8) 行 —— 256 宽时是 8 行。
    //   于是"内存里的下一块"是 8 行以后才用得到的块, 而扫描**马上**需要的是
    //   同一行里更靠右那个窗口的块。沿用内存序会让 2 bank 缓存每行都换出重读。
    //   (实测: 两路窗口同行带并排 -> 512 个突发/帧, 而理论下限是 32。)
    //
    // 采用 D4 规则 1: 本行中 left 在当前 x 右侧的使能窗口, 取其中 left 最小者的本行块;
    //   没有这样的窗口 -> 目标取当前块本身, 于是 next_cached 成立, 不发预取(规则 4)。
    //
    // 关于 D4 的规则 2/3(下一显示行的首个窗口)在本文的几何下是**多余**的:
    //   一个块横跨 8 行, 所以下一行要的是同一批块; 只有跨行带(每 8 行)时才换块,
    //   那一次由需求读兜住即可 —— 单窗口时每 8 行一次需求缺失, 正是理论下限。
    //   实测也印证: "两窗口不同行带"本来就只有 34 个突发。
    //
    // 用 S0 级的 (x_count, disp_y) 而非 S6 级地址: 预取是前瞻性的, 用 6 级之前的
    //   坐标更贴近"马上要扫到的位置"; 行边界处两种取法都指向同一批块。
    //--------------------------------------------------------------------------
    wire [31:0] cur_block = {s6_byteaddr[31:8], 8'b0};

    // 各窗口在"当前显示行"上是否命中 + 该行所在块的基址
    wire signed [15:0] rel_row0 = $signed({1'b0, disp_y}) - $signed(frame_top0);
    wire signed [15:0] rel_row1 = $signed({1'b0, disp_y}) - $signed(frame_top1);
    wire signed [15:0] rel_row2 = $signed({1'b0, disp_y}) - $signed(frame_top2);
    wire signed [15:0] rel_row3 = $signed({1'b0, disp_y}) - $signed(frame_top3);
    wire in_row0 = frame_enable[0] && (rel_row0 >= 0) && (rel_row0 < OSD0_HEIGHT);
    wire in_row1 = frame_enable[1] && (rel_row1 >= 0) && (rel_row1 < OSD1_HEIGHT);
    wire in_row2 = frame_enable[2] && (rel_row2 >= 0) && (rel_row2 < OSD2_HEIGHT);
    wire in_row3 = frame_enable[3] && (rel_row3 >= 0) && (rel_row3 < OSD3_HEIGHT);

    // 本行块 = 基址 + (行相对坐标 * 每行字节数) 向下取整到 256。
    // 基址本身是 256 对齐的, 所以只需把行偏移取整。
    // 行偏移在 in_row 成立时非负, 24 位足够 (最大 288 * 68 = 19584)。
    wire [23:0] rowoff0 = rel_row0 * BPR0;
    wire [23:0] rowoff1 = rel_row1 * BPR1;
    wire [23:0] rowoff2 = rel_row2 * BPR2;
    wire [23:0] rowoff3 = rel_row3 * BPR3;

    wire [31:0] rb0 = (frame_buffer[0] ? OSD0_BASE_B : OSD0_BASE_A) +
                      {8'd0, rowoff0 & 24'hFFFF00};
    wire [31:0] rb1 = (frame_buffer[1] ? OSD1_BASE_B : OSD1_BASE_A) +
                      {8'd0, rowoff1 & 24'hFFFF00};
    wire [31:0] rb2 = (frame_buffer[2] ? OSD2_BASE_B : OSD2_BASE_A) +
                      {8'd0, rowoff2 & 24'hFFFF00};
    wire [31:0] rb3 = (frame_buffer[3] ? OSD3_BASE_B : OSD3_BASE_A) +
                      {8'd0, rowoff3 & 24'hFFFF00};

    // 候选 = 本行命中且 left 在当前 x 右侧
    wire cand0 = in_row0 && ($signed(frame_left0) > $signed({1'b0, x_count}));
    wire cand1 = in_row1 && ($signed(frame_left1) > $signed({1'b0, x_count}));
    wire cand2 = in_row2 && ($signed(frame_left2) > $signed({1'b0, x_count}));
    wire cand3 = in_row3 && ($signed(frame_left3) > $signed({1'b0, x_count}));

    // 在候选中取 left 最小者(链式比较, 组合深度 3 级)
    wire        pick1 = cand1 && (!cand0 || ($signed(frame_left1) < $signed(frame_left0)));
    wire [31:0] acc1  = pick1 ? rb1 : rb0;
    wire signed [11:0] lft1 = pick1 ? frame_left1 : frame_left0;
    wire        any1  = cand0 || cand1;

    wire        pick2 = cand2 && (!any1 || ($signed(frame_left2) < lft1));
    wire [31:0] acc2  = pick2 ? rb2 : acc1;
    wire signed [11:0] lft2 = pick2 ? frame_left2 : lft1;
    wire        any2  = any1 || cand2;

    wire        pick3 = cand3 && (!any2 || ($signed(frame_left3) < lft2));
    wire [31:0] pf_block = pick3 ? rb3 : acc2;
    wire        pf_valid = any2 || cand3;

    // 无候选时目标取当前块, 使 next_cached 必然成立 -> can_prefetch=0 (规则 4)
    wire [31:0] next_block = pf_valid ? pf_block : cur_block;
    // fill_done_pulse 屏蔽: rlast 后一拍 s6_hitany 寄存器尚未更新,
    // 不屏蔽会对刚读回的同一块再发一次重复需求读(白白翻倍 miss 代价)
    wire need_read = pvalid[5] && phit[6] && !s6_hitany &&
                     !(fill_done_pulse && (requested_addr == cur_block));
    wire next_in_c0 = cache0_valid && (cache0_addr == next_block);
    wire next_in_c1 = cache1_valid && (cache1_addr == next_block);
    wire next_cached = next_in_c0 | next_in_c1;
    wire can_prefetch = pvalid[5] && phit[6] && s6_hitany && !next_cached;
    // 需求读替换策略: 优先保留已缓存下一块的 bank
    wire dem_replace = next_in_c0 ? 1'b1 :
                       next_in_c1 ? 1'b0 : replace_bank;

    //--------------------------------------------------------------------------
    // AXI 从接口 (固定 16 拍 128bit INCR 读, 只读不写)
    //--------------------------------------------------------------------------
    assign avalid = (rd_state == ST_ADDR);
    assign aaddr  = requested_addr;
    assign aid    = 8'hA1;
    assign alen   = CACHE_AXLEN;
    assign asize  = 3'd4;
    assign aburst = 2'b01;
    assign alock  = 2'b00;
    assign atype  = 1'b0;
    assign rready = (rd_state == ST_DATA);
    assign active = (rd_state != ST_IDLE);

    //--------------------------------------------------------------------------
    // 流水线 + 状态机 + 计数器主进程
    //--------------------------------------------------------------------------
    integer k;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // 流水线清空
            for (k = 0; k <= 8; k = k + 1) begin
                pdata[k]   <= 16'd0;
                psof[k]    <= 1'b0;
                peol[k]    <= 1'b0;
                pvalid[k]  <= 1'b0;
            end
            for (k = 4; k <= 8; k = k + 1) begin
                phit[k]    <= 1'b0;
                pbitsel[k] <= 3'd0;
            end
            x_count <= 11'd0;
            y_count <= 11'd0;
            frame_global_enable <= 1'b0;
            frame_enable  <= 4'd0;
            frame_buffer  <= 4'd0;
            frame_left0   <= 12'sd0;  frame_left1 <= 12'sd0;
            frame_left2   <= 12'sd0;  frame_left3 <= 12'sd0;
            frame_top0    <= 12'sd0;  frame_top1  <= 12'sd0;
            frame_top2    <= 12'sd0;  frame_top3  <= 12'sd0;
            active_buffer_select <= 4'd0;
            //stall_count   <= 32'd0;
            frame_count   <= 16'd0;
            read_error_count <= 16'd0;
            s1_dx0 <= 17'sd0;  s1_dx1 <= 17'sd0;
            s1_dx2 <= 17'sd0;  s1_dx3 <= 17'sd0;
            s1_dy0 <= 17'sd0;  s1_dy1 <= 17'sd0;
            s1_dy2 <= 17'sd0;  s1_dy3 <= 17'sd0;
            s2_h   <= 4'd0;
            s2_x0  <= 11'd0;  s2_x1  <= 11'd0;
            s2_x2  <= 11'd0;  s2_x3  <= 11'd0;
            s2_y0  <= 11'd0;  s2_y1  <= 11'd0;
            s2_y2  <= 11'd0;  s2_y3  <= 11'd0;
            s3_sel  <= 2'd0;
            s3_hit  <= 1'b0;
            s3_srcx <= 11'd0;
            s3_srcy <= 11'd0;
            s4_rowoff <= 24'd0;
            s4_base   <= 32'd0;
            s4_colbyte <= 8'd0;
            s5_byteaddr <= 32'd0;
            s6_byteaddr <= 32'd0;
            s6_c0word <= 128'd0;
            s6_c1word <= 128'd0;
            s6_c0hit  <= 1'b0;
            s6_c1hit  <= 1'b0;
            s7_word   <= 128'd0;
            s7_bytesel <= 4'd0;
            s8_byte   <= 8'd0;
            s9_maskbit <= 1'b0;
            m_data  <= 16'd0;
            m_valid <= 1'b0;
            m_sof   <= 1'b0;
            m_eol   <= 1'b0;
            rd_state <= ST_IDLE;
            requested_addr <= 32'd0;
            fill_bank  <= 1'b0;
            fill_beat  <= 5'd0;
            replace_bank <= 1'b0;
            fill_done_pulse <= 1'b0;
            cache0_addr <= 32'd0;
            cache1_addr <= 32'd0;
            cache0_valid <= 1'b0;
            cache1_valid <= 1'b0;
        end else begin
            // rlast 完成一拍脉冲: 默认清零, ST_DATA 的 rlast 分支置位
            fill_done_pulse <= 1'b0;

            //----------------------------------------------------------------
            // S6 cache 读与命中判断: 不受 adv1 门控, 每拍用 eff 地址刷新,
            // 使停顿期间 bank 填充完成后命中标志自动生效
            //----------------------------------------------------------------
            s6_c0word <= cache0_data[s6_eff_addr[7:4]];
            s6_c1word <= cache1_data[s6_eff_addr[7:4]];
            s6_c0hit  <= cache0_valid &&
                         (cache0_addr == {s6_eff_addr[31:8], 8'b0});
            s6_c1hit  <= cache1_valid &&
                         (cache1_addr == {s6_eff_addr[31:8], 8'b0});

            //----------------------------------------------------------------
            // AXI 读状态机
            //----------------------------------------------------------------
            if (rd_state == ST_IDLE) begin
                if (need_read) begin
                    // 需求读优先: 停顿的流水线等待当前块填充
                    requested_addr <= cur_block;
                    fill_bank <= dem_replace;
                    replace_bank <= ~dem_replace;
                    fill_beat  <= 5'd0;
                    if (dem_replace)
                        cache1_valid <= 1'b0;
                    else
                        cache0_valid <= 1'b0;
                    rd_state <= ST_ADDR;
                end else if (can_prefetch) begin
                    // 预取: 填充未在服务的 bank, 不打断当前像素
                    requested_addr <= next_block;
                    fill_bank <= s6_c0hit;
                    fill_beat  <= 5'd0;
                    if (s6_c0hit)
                        cache1_valid <= 1'b0;
                    else
                        cache0_valid <= 1'b0;
                    rd_state <= ST_ADDR;
                end
            end else if (rd_state == ST_ADDR) begin
                if (aready)
                    rd_state <= ST_DATA;
            end else begin // ST_DATA
                if (rvalid) begin
                    if (fill_bank)
                        cache1_data[fill_beat[3:0]] <= rdata;
                    else
                        cache0_data[fill_beat[3:0]] <= rdata;
                    if ((rresp != 2'b00) || (rid != 8'hA1))
                        read_error_count <= read_error_count + 1'b1;
                    if (rlast) begin
                        fill_done_pulse <= 1'b1;
                        if (fill_beat != CACHE_BEATS - 1)
                            read_error_count <= read_error_count + 1'b1;
                        if (fill_bank) begin
                            cache1_addr  <= requested_addr;
                            cache1_valid <= 1'b1;
                        end else begin
                            cache0_addr  <= requested_addr;
                            cache0_valid <= 1'b1;
                        end
                        fill_beat <= 5'd0;
                        rd_state  <= ST_IDLE;
                    end else begin
                        fill_beat <= fill_beat + 1'b1;
                    end
                end
            end

            //----------------------------------------------------------------
            // 域1 (S0..S6): 输入采样/坐标计算/cache 字节地址
            //   adv1=0 (cache miss 或输出背压) 时整段原地保持
            //----------------------------------------------------------------
            if (adv1) begin
                // S0: 输入采样与坐标/帧配置锁存
                pdata[0]  <= s_data;
                psof[0]   <= s_sof;
                peol[0]   <= s_eol;
                pvalid[0] <= s_valid;
                if (input_take) begin
                    if (s_sof) begin
                        // 全局使能与每路使能在锁存处相与: 使能与几何一起在帧边界冻结,
                        // 避免全局使能在帧中变化造成"半帧叠加"
                        frame_global_enable <= cfg_global_enable;
                        frame_enable <= cfg_enable & {4{cfg_global_enable}};
                        frame_buffer <= cfg_buffer;
                        frame_left0  <= cfg_left0;  frame_left1 <= cfg_left1;
                        frame_left2  <= cfg_left2;  frame_left3 <= cfg_left3;
                        frame_top0   <= cfg_top0;   frame_top1  <= cfg_top1;
                        frame_top2   <= cfg_top2;   frame_top3  <= cfg_top3;
                        active_buffer_select <= cfg_buffer;
                        x_count <= s_eol ? 11'd0 : 11'd1;
                        y_count <= 11'd0;
                    end else if (s_eol) begin
                        x_count <= 11'd0;
                        if (y_count == FRAME_HEIGHT - 1) begin
                            y_count <= 11'd0;
                            frame_count <= frame_count + 1'b1;
                        end else begin
                            y_count <= y_count + 1'b1;
                        end
                    end else begin
                        x_count <= x_count + 1'b1;
                    end
                end

                // 域1 内 S1..S5 数据/标志逐级移位
                for (k = 5; k > 0; k = k - 1) begin
                    pdata[k]   <= pdata[k-1];
                    psof[k]    <= psof[k-1];
                    peol[k]    <= peol[k-1];
                    pvalid[k]  <= pvalid[k-1];
                end
                // phit[5]/phit[6] 随像素在域1 内移位
                for (k = 6; k > 4; k = k - 1) begin
                    phit[k]    <= phit[k-1];
                    pbitsel[k] <= pbitsel[k-1];
                end

                // S1: 各 OSD 窗口相对坐标 (S0 级像素, SOF 像素用最新配置)
                s1_dx0 <= $signed({6'b0, x_count}) - $signed(left0_s1);
                s1_dx1 <= $signed({6'b0, x_count}) - $signed(left1_s1);
                s1_dx2 <= $signed({6'b0, x_count}) - $signed(left2_s1);
                s1_dx3 <= $signed({6'b0, x_count}) - $signed(left3_s1);
                s1_dy0 <= $signed({6'b0, disp_y}) - $signed(top0_s1);
                s1_dy1 <= $signed({6'b0, disp_y}) - $signed(top1_s1);
                s1_dy2 <= $signed({6'b0, disp_y}) - $signed(top2_s1);
                s1_dy3 <= $signed({6'b0, disp_y}) - $signed(top3_s1);

                // S2: 窗口命中判断 (S1 级像素)
                s2_h <= {(s1_dx3[16] == 1'b0) && (s1_dx3 < OSD3_WIDTH) &&
                         (s1_dy3[16] == 1'b0) && (s1_dy3 < OSD3_HEIGHT) &&
                         frame_enable[3],
                         (s1_dx2[16] == 1'b0) && (s1_dx2 < OSD2_WIDTH) &&
                         (s1_dy2[16] == 1'b0) && (s1_dy2 < OSD2_HEIGHT) &&
                         frame_enable[2],
                         (s1_dx1[16] == 1'b0) && (s1_dx1 < OSD1_WIDTH) &&
                         (s1_dy1[16] == 1'b0) && (s1_dy1 < OSD1_HEIGHT) &&
                         frame_enable[1],
                         (s1_dx0[16] == 1'b0) && (s1_dx0 < OSD0_WIDTH) &&
                         (s1_dy0[16] == 1'b0) && (s1_dy0 < OSD0_HEIGHT) &&
                         frame_enable[0]};
                s2_x0 <= s1_dx0[10:0];
                s2_x1 <= s1_dx1[10:0];
                s2_x2 <= s1_dx2[10:0];
                s2_x3 <= s1_dx3[10:0];
                s2_y0 <= s1_dy0[10:0];
                s2_y1 <= s1_dy1[10:0];
                s2_y2 <= s1_dy2[10:0];
                s2_y3 <= s1_dy3[10:0];

                // S3: 命中区域选择 (编号小者优先; 区域互不重叠)
                s3_hit  <= |s2_h;
                s3_sel  <= s2_h[0] ? 2'd0 :
                           s2_h[1] ? 2'd1 :
                           s2_h[2] ? 2'd2 : 2'd3;
                s3_srcx <= s2_h[0] ? s2_x0 :
                           s2_h[1] ? s2_x1 :
                           s2_h[2] ? s2_x2 : s2_x3;
                s3_srcy <= s2_h[0] ? s2_y0 :
                           s2_h[1] ? s2_y1 :
                           s2_h[2] ? s2_y2 : s2_y3;
                // S4 级命中标志与位选择: 取 S3 级寄存器旧值(即正移入 S4 的像素)
                // 位号取 7-dx[2:0] 而非 dx[2:0]: 字节内 **bit7 对应行内最左像素**
                // (MSB first), 与 D1 的位图契约一致。这样字库侧
                // (ti60 的 font_row_bits 同样是 bit15=最左) 可以原样搬字节,
                // 不需要任何逐字节的反位操作。
                phit[4]    <= s3_hit;
                pbitsel[4] <= 3'd7 - s3_srcx[2:0];

                // S4: 行字节偏移(常数乘)与画布基址(S3 级像素)
                case (s3_sel)
                    2'd0: s4_rowoff <= s3_srcy * BPR0;
                    2'd1: s4_rowoff <= s3_srcy * BPR1;
                    2'd2: s4_rowoff <= s3_srcy * BPR2;
                    default: s4_rowoff <= s3_srcy * BPR3;
                endcase
                case ({frame_buffer[s3_sel], s3_sel[1:0]})
                    3'd0: s4_base <= OSD0_BASE_A;
                    3'd4: s4_base <= OSD0_BASE_B;
                    3'd1: s4_base <= OSD1_BASE_A;
                    3'd5: s4_base <= OSD1_BASE_B;
                    3'd2: s4_base <= OSD2_BASE_A;
                    3'd6: s4_base <= OSD2_BASE_B;
                    3'd3: s4_base <= OSD3_BASE_A;
                    default: s4_base <= OSD3_BASE_B;
                endcase
                s4_colbyte <= s3_srcx[10:3];

                // S5: 遮罩字节地址 = 基址 + 行偏移 + 行内字节列号 (S4 级像素)
                s5_byteaddr <= s4_base +
                               {8'b0, s4_rowoff} +
                               {24'b0, s4_colbyte};

                // S6: 字节地址随像素下移 (cache 字与命中标志已在上方刷新)
                s6_byteaddr <= s5_byteaddr;
            end

            //----------------------------------------------------------------
            // 域2 (S7..S10): 遮罩字已随像素捕获, 只要输出级能收就推进。
            //   miss 停顿期间域2 继续排空, 边界注入气泡(pvalid=0),
            //   保证握手协议正确: 已被下游接收的像素不会被再次呈现
            //----------------------------------------------------------------
            if (adv2) begin
                // 域边界: 域1 冻结时注入气泡(无效像素), 标志与数据清零
                pdata[6]   <= adv1 ? pdata[5]   : 16'd0;
                psof[6]    <= adv1 ? psof[5]    : 1'b0;
                peol[6]    <= adv1 ? peol[5]    : 1'b0;
                pvalid[6]  <= adv1 ? pvalid[5]  : 1'b0;
                phit[7]    <= adv1 ? phit[6]    : 1'b0;
                pbitsel[7] <= adv1 ? pbitsel[6] : 3'd0;

                // S7: bank 选择与字节选择 (S6 级像素; adv1=0 时装入的是
                //     气泡伴随数据, 输出端由 pvalid 掩蔽, 无影响)
                s7_word    <= s6_c0hit ? s6_c0word : s6_c1word;
                s7_bytesel <= s6_byteaddr[3:0];

                // S7 -> S8: 移位与 16:1 字节选择。
                // 显式 case 而非 128bit 变量移位, 避免综合出宽桶形移位器
                pdata[7]   <= pdata[6];
                psof[7]    <= psof[6];
                peol[7]    <= peol[6];
                pvalid[7]  <= pvalid[6];
                phit[8]    <= phit[7];
                pbitsel[8] <= pbitsel[7];
                case (s7_bytesel)
                    4'd0:  s8_byte <= s7_word[7:0];
                    4'd1:  s8_byte <= s7_word[15:8];
                    4'd2:  s8_byte <= s7_word[23:16];
                    4'd3:  s8_byte <= s7_word[31:24];
                    4'd4:  s8_byte <= s7_word[39:32];
                    4'd5:  s8_byte <= s7_word[47:40];
                    4'd6:  s8_byte <= s7_word[55:48];
                    4'd7:  s8_byte <= s7_word[63:56];
                    4'd8:  s8_byte <= s7_word[71:64];
                    4'd9:  s8_byte <= s7_word[79:72];
                    4'd10: s8_byte <= s7_word[87:80];
                    4'd11: s8_byte <= s7_word[95:88];
                    4'd12: s8_byte <= s7_word[103:96];
                    4'd13: s8_byte <= s7_word[111:104];
                    4'd14: s8_byte <= s7_word[119:112];
                    default: s8_byte <= s7_word[127:120];
                endcase

                // S8 -> S9: 数据移位与遮罩位寄存 (与 pdata[8] 对齐)
                pdata[8]   <= pdata[7];
                psof[8]    <= psof[7];
                peol[8]    <= peol[7];
                pvalid[8]  <= pvalid[7];
                s9_maskbit <= phit[8] && s8_byte[pbitsel[8]];

                // S10: 混合输出 (pdata[8] 级像素, 与 s9_maskbit 同级)
                m_valid <= pvalid[8];
                m_sof   <= psof[8];
                m_eol   <= peol[8];
                m_data  <= s9_maskbit ? 16'h80EB : pdata[8];
            end
        end
    end

endmodule
