`timescale 1ns / 1ps
//============================================================================
// HyperRamMaskOverlayYuv422_4OSD : 四区域 OSD 叠加引擎 (1bit/像素)
//----------------------------------------------------------------------------
// 功能:
//   在 YUV422 视频流(16bit/像素)上叠加最多 4 块互不重叠的 OSD 位图。
//   位图存于 HyperRAM, 每 bit 对应一个像素: 0=视频透传, 1=叠加纯黑
//   (Y=16, Cb/Cr=128, 即 16'h8010 演播室黑)。
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
module HyperRamMaskOverlayYuv422_4OSD #(
    // OSD0 尺寸(宽必须能被 8 整除)与双缓冲基址
    parameter integer OSD0_WIDTH  = 256,
    parameter integer OSD0_HEIGHT = 128,
    parameter [31:0]  OSD0_BASE_A = 32'h0040_0000,
    parameter [31:0]  OSD0_BASE_B = OSD0_BASE_A + OSD0_WIDTH * OSD0_HEIGHT / 8,
    // OSD1 尺寸与双缓冲基址
    parameter integer OSD1_WIDTH  = 256,
    parameter integer OSD1_HEIGHT = 128,
    parameter [31:0]  OSD1_BASE_A = 32'h0050_0000,
    parameter [31:0]  OSD1_BASE_B = OSD1_BASE_A + OSD1_WIDTH * OSD1_HEIGHT / 8,
    // OSD2 尺寸与双缓冲基址
    parameter integer OSD2_WIDTH  = 256,
    parameter integer OSD2_HEIGHT = 128,
    parameter [31:0]  OSD2_BASE_A = 32'h0060_0000,
    parameter [31:0]  OSD2_BASE_B = OSD2_BASE_A + OSD2_WIDTH * OSD2_HEIGHT / 8,
    // OSD3 尺寸与双缓冲基址
    parameter integer OSD3_WIDTH  = 256,
    parameter integer OSD3_HEIGHT = 128,
    parameter [31:0]  OSD3_BASE_A = 32'h0070_0000,
    parameter [31:0]  OSD3_BASE_B = OSD3_BASE_A + OSD3_WIDTH * OSD3_HEIGHT / 8,
    // 视频帧尺寸与坐标翻转(下游 DMA 垂直翻转时置 1)
    parameter integer FRAME_WIDTH  = 720,
    parameter integer FRAME_HEIGHT = 576,
    parameter integer FLIP_VERTICAL_COORDS = 0
) (
    // 时钟与复位
    input  wire         clk,
    input  wire         reset,
    // OSD 控制: 各块独立使能, 共用画布选择
    input  wire [3:0]   mask_enable,
    input  wire         mask_buffer_select,
    // 4 个 OSD 的起始坐标: [31:16]=列 left, [15:0]=行 top, 均为有符号
    input  wire [31:0]  mask_0,
    input  wire [31:0]  mask_1,
    input  wire [31:0]  mask_2,
    input  wire [31:0]  mask_3,
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
    output reg          active_buffer_select
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
    // 配置两级同步 (控制信号跨 CDC 进入本时钟域)
    //--------------------------------------------------------------------------
    reg [3:0]  enable_meta;     // mask_enable 第一级同步 (4bit 完整宽度!)
    reg [3:0]  enable_sync;     // mask_enable 第二级同步
    reg [1:0]  buffer_sync;
    reg [31:0] pos0_meta;
    reg [31:0] pos0_sync;
    reg [31:0] pos1_meta;
    reg [31:0] pos1_sync;
    reg [31:0] pos2_meta;
    reg [31:0] pos2_sync;
    reg [31:0] pos3_meta;
    reg [31:0] pos3_sync;

    wire [3:0] cfg_enable = enable_sync;    // 4bit 完整宽度, 逐位对应 OSD0..3
    wire       cfg_buffer = buffer_sync[1];
    wire [31:0] cfg_pos0  = pos0_sync;
    wire [31:0] cfg_pos1  = pos1_sync;
    wire [31:0] cfg_pos2  = pos2_sync;
    wire [31:0] cfg_pos3  = pos3_sync;

    // 帧内锁存配置: SOF 采样, 一帧之内保持不变(防撕裂)
    reg [3:0]  frame_enable;
    reg        frame_buffer;
    reg [31:0] frame_pos0;
    reg [31:0] frame_pos1;
    reg [31:0] frame_pos2;
    reg [31:0] frame_pos3;

    // S1 取用的位置源: SOF 像素当拍必须用最新同步值(帧锁存与 S1 计算
    // 同沿写入, 若 S1 读 frame_pos* 会拿到上一帧旧坐标, 帧首像素错位)
    wire [31:0] pos0_s1 = s_sof ? cfg_pos0 : frame_pos0;
    wire [31:0] pos1_s1 = s_sof ? cfg_pos1 : frame_pos1;
    wire [31:0] pos2_s1 = s_sof ? cfg_pos2 : frame_pos2;
    wire [31:0] pos3_s1 = s_sof ? cfg_pos3 : frame_pos3;

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
    wire input_take = s_valid && adv1;

    // S6 刷新地址: 域1 推进时取即将进入 S6 的像素地址, 停顿时取当前地址,
    // 保证 cache 填充完成后命中标志能自动变高(解除停顿)
    wire [31:0] s6_eff_addr = adv1 ? s5_byteaddr : s6_byteaddr;

    // AXI 读请求对象 (以当前 S6 像素的 256 字节块为单位)
    wire [31:0] cur_block  = {s6_byteaddr[31:8], 8'b0};
    wire [31:0] next_block = {s6_byteaddr[31:8] + 24'd1, 8'b0};
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
    // 配置同步进程
    //--------------------------------------------------------------------------
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            enable_meta <= 4'b0000;
            enable_sync <= 4'b0000;
            buffer_sync <= 2'b00;
            pos0_meta <= 32'd0;
            pos0_sync <= 32'd0;
            pos1_meta <= 32'd0;
            pos1_sync <= 32'd0;
            pos2_meta <= 32'd0;
            pos2_sync <= 32'd0;
            pos3_meta <= 32'd0;
            pos3_sync <= 32'd0;
        end else begin
            enable_meta <= mask_enable;
            enable_sync <= enable_meta;
            buffer_sync <= {buffer_sync[0], mask_buffer_select};
            pos0_meta <= mask_0;
            pos0_sync <= pos0_meta;
            pos1_meta <= mask_1;
            pos1_sync <= pos1_meta;
            pos2_meta <= mask_2;
            pos2_sync <= pos2_meta;
            pos3_meta <= mask_3;
            pos3_sync <= pos3_meta;
        end
    end

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
            frame_enable  <= 4'd0;
            frame_buffer  <= 1'b0;
            frame_pos0    <= 32'd0;
            frame_pos1    <= 32'd0;
            frame_pos2    <= 32'd0;
            frame_pos3    <= 32'd0;
            active_buffer_select <= 1'b0;
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
                        frame_enable <= cfg_enable;
                        frame_buffer <= cfg_buffer;
                        frame_pos0   <= cfg_pos0;
                        frame_pos1   <= cfg_pos1;
                        frame_pos2   <= cfg_pos2;
                        frame_pos3   <= cfg_pos3;
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
                s1_dx0 <= $signed({6'b0, x_count}) -
                          $signed(pos0_s1[31:16]);
                s1_dx1 <= $signed({6'b0, x_count}) -
                          $signed(pos1_s1[31:16]);
                s1_dx2 <= $signed({6'b0, x_count}) -
                          $signed(pos2_s1[31:16]);
                s1_dx3 <= $signed({6'b0, x_count}) -
                          $signed(pos3_s1[31:16]);
                s1_dy0 <= $signed({6'b0, disp_y}) -
                          $signed(pos0_s1[15:0]);
                s1_dy1 <= $signed({6'b0, disp_y}) -
                          $signed(pos1_s1[15:0]);
                s1_dy2 <= $signed({6'b0, disp_y}) -
                          $signed(pos2_s1[15:0]);
                s1_dy3 <= $signed({6'b0, disp_y}) -
                          $signed(pos3_s1[15:0]);

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
                phit[4]    <= s3_hit;
                pbitsel[4] <= s3_srcx[2:0];

                // S4: 行字节偏移(常数乘)与画布基址(S3 级像素)
                case (s3_sel)
                    2'd0: s4_rowoff <= s3_srcy * BPR0;
                    2'd1: s4_rowoff <= s3_srcy * BPR1;
                    2'd2: s4_rowoff <= s3_srcy * BPR2;
                    default: s4_rowoff <= s3_srcy * BPR3;
                endcase
                case ({frame_buffer, s3_sel[1:0]})
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
                m_data  <= s9_maskbit ? 16'h8010 : pdata[8];
            end
        end
    end

endmodule
