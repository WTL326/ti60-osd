`timescale 1ns / 1ps
//============================================================================
// tb_hyperram_mask_overlay —— HyperRamMaskOverlayYuv422 的自检测试平台
//----------------------------------------------------------------------------
// `docs/testing.md:40` 提到的同名 testbench 在本检出里不存在（本仓库是部分检出），
// 所以这份是**新写**的，不是扩展。
//
// 组成：
//   1) 位图内存模型：8 个缓冲紧凑排布（每缓冲 W*H/8 字节），供 AXI 读模型取数；
//   2) AXI 读从模型：地址握手 -> 固定延迟 -> 16 拍 x 128bit 连发 -> rlast；
//   3) 视频源：按 FRAME_W x FRAME_H 逐像素激励，遵守 s_valid/s_ready 握手；
//   4) 视频槽：逐像素与**黄金模型**比对（自检测），并统计 AXI 异常；
//   5) 基线导出：+BASELINE=<路径> 时把输出像素序列落盘，供改造前后做回归对比。
//
// 黄金模型（与 RTL 的契约逐项对应）：
//   命中 = 使能 && 0 <= x-left < W && 0 <= disp_y-top < H，disp_y = H-1-y_scan
//   字节地址 = base + (disp_y-top)*(W/8) + ((x-left)>>3)
//   位号 = (x-left)%8            —— BIT_MSB_FIRST=0：LSB 为最左（**当前 RTL**）
//        = 7-((x-left)%8)        —— BIT_MSB_FIRST=1：bit7 为最左（**D1 契约**）
//   输出 = 位为 1 ? OVERLAY_COLOR : 输入像素
//
//   注意黄金模型读的是 bmp[] 本身（与 DUT 同一份内存），不是重新推导图案 ——
//   这样"地址算错"和"位序接反"都会表现为不匹配，而不会被图案的规律掩盖。
//
// 用法（在 sim/ 目录下）：
//     bash sim/run_tb.sh                       # 快速冒烟（FAST_FRAME）
//     bash sim/run_tb.sh +BASELINE=baseline.txt  # 全尺寸 + 导出基线
//============================================================================

// FAST_FRAME：小尺寸快速冒烟，用于改 RTL 时反复迭代。
// 全尺寸（720x576 + 4 路 256x128）跑一次要几百万周期，不适合当每次改动的第一道检查。
// 四种几何，覆盖任务 7.2–7.6 需要的全部尺寸组合：
//   fast（默认）  小尺寸冒烟，改 RTL 时反复迭代用
//   full          全画幅 + 四路 256x128（2x2 并排）
//   menu          **菜单承载路**的实参：544x208（D3 表第 2 行 / D6 上限）
//   max           单路**最大尺寸** 544x288（D6 的上限本身）
//
// 四路的尺寸相同是刻意的：位图在内存模型里按"每缓冲一个槽位"排布，
// 尺寸一致才能用同一套 base_of()/SLOT 算地址。菜单模式因此把四路都取 544x208
// —— 验证的是"菜单那一路（第 2 路）的整幅画布能完整落进窗口、且与其余路互不干扰"，
// 而"其余路也是 544x208"不影响这条结论（它们各自的位图内容不同）。
`ifdef FAST_FRAME
`define TB_FRAME_W  180
`define TB_FRAME_H  144
`define TB_W0 64
`define TB_H0 48
`define TB_POS0 {16'd0,  16'd0}
`define TB_POS1 {16'd70, 16'd0}
`define TB_POS2 {16'd0,  16'd60}
`define TB_POS3 {16'd70, 16'd60}
`elsif TB_MENU
`define TB_FRAME_W  720
`define TB_FRAME_H  576
`define TB_W0 544
`define TB_H0 208
`define TB_POS0 {16'd0,   16'd0}
`define TB_POS1 {16'd88,  16'd368}
`define TB_POS2 {16'd0,   16'd368}
`define TB_POS3 {16'd176, 16'd0}
`elsif TB_MAXWIN
`define TB_FRAME_W  720
`define TB_FRAME_H  576
`define TB_W0 544
`define TB_H0 288
`define TB_POS0 {16'd0,   16'd0}
`define TB_POS1 {16'd176, 16'd144}
`define TB_POS2 {16'd0,   16'd288}
`define TB_POS3 {16'd176, 16'd0}
`else
`define TB_FRAME_W  720
`define TB_FRAME_H  576
`define TB_W0 256
`define TB_H0 128
`define TB_POS0 {16'd0,   16'd0}
`define TB_POS1 {16'd300, 16'd0}
`define TB_POS2 {16'd0,   16'd300}
`define TB_POS3 {16'd300, 16'd300}
`endif

module tb_hyperram_mask_overlay;

    parameter integer FRAME_W = `TB_FRAME_W;
    parameter integer FRAME_H = `TB_FRAME_H;

    parameter integer W0 = `TB_W0, H0 = `TB_H0;
    parameter integer W1 = `TB_W0, H1 = `TB_H0;
    parameter integer W2 = `TB_W0, H2 = `TB_H0;
    parameter integer W3 = `TB_W0, H3 = `TB_H0;

    localparam [31:0] POS0 = `TB_POS0;
    localparam [31:0] POS1 = `TB_POS1;
    localparam [31:0] POS2 = `TB_POS2;
    localparam [31:0] POS3 = `TB_POS3;

    // 位图编码约定：字节内 bit7 对应行内最左像素（MSB first，D1）。
    // 它与 RTL 的 pbitsel 约定是同一件事的两侧，必须同步改动；
    // 若只改一边，表现为"被叠加的像素大面积不匹配"，而透传像素仍然匹配。
    //
    // 编译时加 `+define+TB_LSB_FIRST` 可切成 LSB-first —— 这不是给正式回归用的，
    // 而是用来**反向验证位序探针本身有效**：切成与 RTL 相反的一侧时，
    // 探针必须报错、逐像素比对必须大面积不匹配。一个从不失败的检查等于没有检查。
`ifdef TB_LSB_FIRST
    localparam integer BIT_MSB_FIRST = 0;
`else
    localparam integer BIT_MSB_FIRST = 1;
`endif

    // 叠加色：与 D1 一致，16'h80EB（Y=235 纯白，Cb/Cr=128）。
    // 任务 2.1 之前 RTL 用的是 16'h8010（演播室黑）—— 若 RTL 忘记改，
    // 这里会表现为"所有被叠加的像素都不匹配"，而透传像素仍然匹配。
    localparam [15:0] OVERLAY_COLOR = 16'h80EB;


    // 每路每缓冲的位图字节数（四路同尺寸，取其一）
    localparam integer WIN_BYTES = (W0*H0)/8;

    // 每个缓冲占的地址空间：位图字节数向上取整到 4 KB。
    //
    // 为什么要 4 KB 对齐（首版是"B = A + 位图大小"、路间固定隔 1 MiB）：
    //   32 位地址的高 20 位就是 4 KB 页号，而 region_of() 要靠页号把地址
    //   映回槽位。若 B 与 A 落在同一页（fast 模式位图只有 384 字节，必然同页），
    //   读 B 会被当成读 A —— A/B 切换就永远测不出来，而且错得很安静。
    //   取整到 4 KB 之后，8 个槽位两两不同页，映射无歧义。
    //   位图大于 4 KB 时（max/menu 模式）SLOT 自然跟着变大，也不会重叠。
    localparam integer SLOT = ((WIN_BYTES + 4095) / 4096) * 4096;

    localparam [31:0] B0A = 32'h0040_0000, B0B = B0A + SLOT;
    localparam [31:0] B1A = B0A + 2*SLOT,  B1B = B1A + SLOT;
    localparam [31:0] B2A = B0A + 4*SLOT,  B2B = B2A + SLOT;
    localparam [31:0] B3A = B0A + 6*SLOT,  B3B = B3A + SLOT;

    // 槽位号 -> 基址（0=B0A 1=B0B 2=B1A … 7=B3B，与 region_of 的编号一致）
    function [31:0] base_of;
        input integer slot;
        begin
            case (slot)
                0: base_of = B0A;  1: base_of = B0B;
                2: base_of = B1A;  3: base_of = B1B;
                4: base_of = B2A;  5: base_of = B2B;
                6: base_of = B3A;  default: base_of = B3B;
            endcase
        end
    endfunction

    //------------------------------------------------------------------------
    // 时钟 / 复位
    //------------------------------------------------------------------------
    reg clk = 1'b0;
    reg reset = 1'b1;
    always #5 clk = ~clk;                       // 100 MHz

    //------------------------------------------------------------------------
    // DUT
    //------------------------------------------------------------------------
    // 配置分三层，这是本平台能测"帧边界原子生效"的关键：
    //
    //   p_*  待生效配置 —— 用例改的是它。DUT 看到的就是它（cfg_* 直连 p_*）。
    //   g_*  **黄金模型认为当前帧应当生效**的配置 —— 测试平台在送出 SOF 那一拍
    //        自己锁存 p_*。它是一条独立的"合同断言"：若 DUT 提前生效（帧中途就
    //        换了配置），比对立刻大面积失配。DUT 与模型各自独立地"在 SOF 锁存"，
    //        两者一致才说明锁存点正确。
    //
    // 注意：`en_eff` 原本是从 cfg_* 算的，现在必须从 g_* 算 —— 从 cfg_* 算等于
    // 用 DUT 的输入去校验 DUT 的输出，帧中改配置时永远测不出问题。
    reg         p_global_enable;
    reg  [3:0]  p_enable, p_buffer;
    reg  signed [11:0] p_left0, p_left1, p_left2, p_left3;
    reg  signed [11:0] p_top0,  p_top1,  p_top2,  p_top3;

    reg         g_global_enable;
    reg  [3:0]  g_enable, g_buffer;
    reg  signed [11:0] g_left0, g_left1, g_left2, g_left3;
    reg  signed [11:0] g_top0,  g_top1,  g_top2,  g_top3;

    wire [3:0]  applied_enable;
    wire [31:0] stall_count;

    // cfg_* 直连 p_*（DUT 端口不能接 reg 的表达式，所以这里落成 wire）
    wire        cfg_global_enable = p_global_enable;
    wire [3:0]  cfg_enable        = p_enable;
    wire [3:0]  cfg_buffer        = p_buffer;
    wire signed [11:0] cfg_left0 = p_left0, cfg_left1 = p_left1;
    wire signed [11:0] cfg_left2 = p_left2, cfg_left3 = p_left3;
    wire signed [11:0] cfg_top0  = p_top0,  cfg_top1  = p_top1;
    wire signed [11:0] cfg_top2  = p_top2,  cfg_top3  = p_top3;

    // 黄金模型用的"实际生效使能" = 每路使能 & 全局使能（与 RTL 在 SOF 处的相与一致）。
    // 注意声明位置：必须在 g_enable/g_global_enable 之后，否则 vlog 报
    // "Undefined variable"（首版把它放到了端口声明之前）。
    wire [3:0] en_eff = g_enable & {4{g_global_enable}};

    reg  [15:0] s_data;  reg s_valid, s_sof, s_eol;  wire s_ready;
    wire [15:0] m_data;  wire m_valid, m_sof, m_eol; reg  m_ready;

    wire         avalid;  reg  aready;
    wire [31:0]  aaddr;
    wire [7:0]   aid, alen;
    wire [2:0]   asize;
    wire [1:0]   aburst, alock;
    wire         atype;
    reg  [7:0]   rid;
    reg  [127:0] rdata;
    reg          rlast, rvalid;
    wire         rready;
    reg  [1:0]   rresp;

    wire [15:0] frame_count, read_error_count;
    wire        active;
    wire [3:0]  active_buffer_select;   // D6: 每路各 1 bit

    HyperRamMaskOverlayYuv422 #(
        .OSD0_WIDTH  (W0),  .OSD0_HEIGHT (H0),
        .OSD0_BASE_A (B0A), .OSD0_BASE_B (B0B),
        .OSD1_WIDTH  (W1),  .OSD1_HEIGHT (H1),
        .OSD1_BASE_A (B1A), .OSD1_BASE_B (B1B),
        .OSD2_WIDTH  (W2),  .OSD2_HEIGHT (H2),
        .OSD2_BASE_A (B2A), .OSD2_BASE_B (B2B),
        .OSD3_WIDTH  (W3),  .OSD3_HEIGHT (H3),
        .OSD3_BASE_A (B3A), .OSD3_BASE_B (B3B),
        // 显式给出 8 个基址参数：B 不再由 A + W*H/8 推导（D10 第 3 项），
        // 但测试平台的 A/B 仍按"相差一个位图大小"取值，与 region_of 的映射一致。
        .FRAME_WIDTH (FRAME_W), .FRAME_HEIGHT (FRAME_H),
        .FLIP_VERTICAL_COORDS (1)
    ) dut (
        .clk (clk), .reset (reset),
        .cfg_global_enable (cfg_global_enable),
        .cfg_enable (cfg_enable), .cfg_buffer (cfg_buffer),
        .cfg_left0 (cfg_left0), .cfg_left1 (cfg_left1),
        .cfg_left2 (cfg_left2), .cfg_left3 (cfg_left3),
        .cfg_top0 (cfg_top0), .cfg_top1 (cfg_top1),
        .cfg_top2 (cfg_top2), .cfg_top3 (cfg_top3),
        .s_data (s_data), .s_valid (s_valid), .s_sof (s_sof), .s_eol (s_eol),
        .s_ready (s_ready),
        .m_data (m_data), .m_valid (m_valid), .m_sof (m_sof), .m_eol (m_eol),
        .m_ready (m_ready),
        .avalid (avalid), .aready (aready), .aaddr (aaddr), .aid (aid),
        .alen (alen), .asize (asize), .aburst (aburst), .alock (alock),
        .atype (atype),
        .rid (rid), .rdata (rdata), .rlast (rlast), .rvalid (rvalid),
        .rready (rready), .rresp (rresp),
        .frame_count (frame_count), .read_error_count (read_error_count),
        .active (active), .active_buffer_select (active_buffer_select),
        .applied_enable (applied_enable), .stall_count (stall_count)
    );

    //========================================================================
    // 1) 位图内存模型
    //========================================================================
    reg [7:0] bmp [0:8*WIN_BYTES-1];

    // 地址 -> 缓冲号；-1 表示不属于任何缓冲（预取越过位图末尾时会发生，属正常）
    // 地址 -> 槽位号；-1 = 不属于任何缓冲（预取越过位图末尾时属正常）。
    //
    // 判据是**完整基址 + 位图长度**的区间，不是"页号相等"。
    // 页号版在 SLOT > 4 KB 时会漏（一个缓冲横跨多页，第 2 页起就认不出来了），
    // 而那正好是 max/menu 模式的尺寸 —— 会在整幅画布的后半段读到全 0、
    // 表现为"下半屏不叠加"，很容易误判成 RTL 的问题。
    function integer region_of;
        input [31:0] a;
        integer s;
        begin
            region_of = -1;
            for (s = 0; s < 8; s = s + 1)
                if ((a >= base_of(s)) && (a < (base_of(s) + WIN_BYTES)))
                    region_of = s;
        end
    endfunction

    // 某路的 A / B 缓冲在 bmp[] 里的缓冲号。
    // 注意：缓冲号不是路号！region_of 的编号顺序是
    //   0=B0A 1=B0B 2=B1A 3=B1B 4=B2A 5=B2B 6=B3A 7=B3B
    // 所以 A 缓冲是 0/2/4/6（= sel*2），B 缓冲是 1/3/5/7（= sel*2+1）。
    // 首版把 sel 直接当缓冲号，于是窗口 1/3 读到了全零的 B 缓冲 —— 这类错误
    // 在"四个 A 缓冲填同一图案"的布局下很隐蔽（0/2 恰好同值），故在此显式写出。
    function integer region_of_sel;
        input integer sel;
        input integer is_b;
        begin
            region_of_sel = sel*2 + is_b;
        end
    endfunction

    // 某路的每行字节数
    function integer bpr_of;
        input integer sel;
        begin
            case (sel)
                0: bpr_of = W0/8;
                1: bpr_of = W1/8;
                2: bpr_of = W2/8;
                default: bpr_of = W3/8;
            endcase
        end
    endfunction

    // 某路的宽度 / 高度
    function integer w_of;
        input integer sel;
        begin
            case (sel)
                0: w_of = W0;
                1: w_of = W1;
                2: w_of = W2;
                default: w_of = W3;
            endcase
        end
    endfunction

    function integer h_of;
        input integer sel;
        begin
            case (sel)
                0: h_of = H0;
                1: h_of = H1;
                2: h_of = H2;
                default: h_of = H3;
            endcase
        end
    endfunction

    // 位图图案：像素 (dx,dy) 是否置位。用棋盘格 —— 相邻像素交替取值，
    // 于是字节内 8 个 bit 位置都会被激励到；位序接反会立刻表现为大面积不匹配。
    function bit_set;
        input integer dx, dy;
        begin
            bit_set = (((dx + dy) % 2) == 0);
        end
    endfunction

    // 把某行的一个字节按 BIT_MSB_FIRST 打包
    function [7:0] pack_byte;
        input integer dy, bytecol;
        integer b, dx0;
        begin
            pack_byte = 8'h00;
            dx0 = bytecol * 8;
            for (b = 0; b < 8; b = b + 1) begin
                if (bit_set(dx0 + b, dy)) begin
                    if (BIT_MSB_FIRST)
                        pack_byte = pack_byte | (8'h01 << (7 - b));
                    else
                        pack_byte = pack_byte | (8'h01 << b);
                end
            end
        end
    endfunction

    // 黄金模型：给定扫描坐标，算出期望输出像素
    function [15:0] expected_pixel;
        input integer x, y_scan;
        integer dy_disp, sel, dx, dy, bitno, addr;
        reg hit, bitval;
        begin
            // 输入像素图案：唯一、且落在 0x2000..0x2FFF，
            // 刻意避开 0x8010 / 0x80EB，避免"恰好相等"造成误判
            expected_pixel = 16'h2000 | (((y_scan * FRAME_W) + x) & 16'h0FFF);

            dy_disp = FRAME_H - 1 - y_scan;         // FLIP_VERTICAL_COORDS = 1
            hit = 1'b0;
            bitval = 1'b0;

            // 编号小者优先（测试用的四路互不重叠，不会真正冲突）
            for (sel = 0; sel < 4; sel = sel + 1) begin
                if (!hit) begin
                    case (sel)
                        0: begin dx = x - g_left0; dy = dy_disp - g_top0; end
                        1: begin dx = x - g_left1; dy = dy_disp - g_top1; end
                        2: begin dx = x - g_left2; dy = dy_disp - g_top2; end
                        default: begin dx = x - g_left3; dy = dy_disp - g_top3; end
                    endcase
                    hit = (dx >= 0) && (dx < w_of(sel)) &&
                          (dy >= 0) && (dy < h_of(sel)) &&
                          en_eff[sel];
                    if (hit) begin
                        bitno = BIT_MSB_FIRST ? (7 - (dx % 8)) : (dx % 8);
                        /* 每路**各自**的 A/B 选择（D6）：这里用 g_buffer[sel]，
                         * 所以"只切第 2 路、其余三路不动"能被逐像素验证 ——
                         * 哪一路用了错的缓冲，它那一块区域立刻失配。 */
                        addr  = region_of_sel(sel, g_buffer[sel])*WIN_BYTES
                                + dy*bpr_of(sel) + (dx / 8);
                        bitval = bmp[addr][bitno];
                        if (bitval) expected_pixel = OVERLAY_COLOR;
                    end
                end
            end
        end
    endfunction

    integer ii, jj, kk;
    initial begin
        for (ii = 0; ii < 8*WIN_BYTES; ii = ii + 1) bmp[ii] = 8'h00;
        // 只填 A 缓冲；B 缓冲保持全 0，这样"切到 B"会立刻表现为叠加消失，
        // 是 A/B 双缓冲是否真的生效最直接的证据。
        for (jj = 0; jj < H0; jj = jj + 1)
            for (kk = 0; kk < W0/8; kk = kk + 1) begin
                bmp[0*WIN_BYTES + jj*(W0/8) + kk] = pack_byte(jj, kk);
                bmp[2*WIN_BYTES + jj*(W1/8) + kk] = pack_byte(jj, kk);
                bmp[4*WIN_BYTES + jj*(W2/8) + kk] = pack_byte(jj, kk);
                bmp[6*WIN_BYTES + jj*(W3/8) + kk] = pack_byte(jj, kk);
                // B 缓冲填**反相**图案。首版把 B 留成全 0，那只能证明"切到 B 后
                // 叠加消失"，证明不了"B 的内容被正确读出" —— 读错地址、读到 A，
                // 在全 0 的 B 上都会表现为"叠加消失"，三种病因一个现象。
                // 反相之后 A/B 的叠加分布不同，两个方向都能验，且能与"读错缓冲"区分。
                bmp[1*WIN_BYTES + jj*(W0/8) + kk] = ~pack_byte(jj, kk);
                bmp[3*WIN_BYTES + jj*(W1/8) + kk] = ~pack_byte(jj, kk);
                bmp[5*WIN_BYTES + jj*(W2/8) + kk] = ~pack_byte(jj, kk);
                bmp[7*WIN_BYTES + jj*(W3/8) + kk] = ~pack_byte(jj, kk);
            end
        // 位序探针（任务 2.8）：把窗口 0 的第 0 行改写成两个已知字节，
        // 其余字节清零。绝对期望见 capture 段 —— 这条断言不经过黄金模型。
        for (kk = 0; kk < W0/8; kk = kk + 1)
            bmp[0*WIN_BYTES + 0*(W0/8) + kk] = 8'h00;
        bmp[0*WIN_BYTES + 0*(W0/8) + 0] = 8'h80;   // bit7 置位 => 最左像素置位
        bmp[0*WIN_BYTES + 0*(W0/8) + 1] = 8'h01;   // bit0 置位 => 该字节最右像素置位
    end

    //========================================================================
    // 2) AXI 读从模型
    //========================================================================
    localparam integer RD_LATENCY = 6;      // 地址接受到第一拍数据的周期数

    localparam AXI_IDLE = 2'd0, AXI_LAT = 2'd1, AXI_DATA = 2'd2;

    reg [1:0]  axi_st;
    reg [31:0] axi_addr;
    reg [4:0]  axi_beat;
    reg [7:0]  axi_wait;
    integer    axi_oor;        // 读到 8 个缓冲之外的次数（预取越界属正常）
    integer    axi_misalign;   // 非 256 字节对齐的突发（必须为 0）
    integer    burst_count;    // 地址握手次数 = 实际发出的 AXI 突发数
                               // 这是"预取策略好不好"最直接的观测量：突发越少，
                               // 说明块被复用得越充分；每个突发 256 字节。

    initial begin
        axi_st = AXI_IDLE; axi_addr = 32'd0; axi_beat = 5'd0; axi_wait = 8'd0;
        aready = 1'b0; rvalid = 1'b0; rlast = 1'b0;
        rid = 8'h00; rresp = 2'b00;
        axi_oor = 0; axi_misalign = 0; burst_count = 0;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            axi_st <= AXI_IDLE; aready <= 1'b0; rvalid <= 1'b0; rlast <= 1'b0;
            axi_beat <= 5'd0; axi_wait <= 8'd0;
        end else begin
            case (axi_st)
                AXI_IDLE: begin
                    aready <= 1'b0;
                    rvalid <= 1'b0;
                    rlast  <= 1'b0;
                    if (avalid) begin
                        burst_count = burst_count + 1;
                        axi_addr <= aaddr;
                        axi_wait <= RD_LATENCY[7:0];
                        axi_st   <= AXI_LAT;
                        // DUT 在 ST_DATA 里比对 rid 与 8'hA1（见模块 :442），
                        // 所以读数据阶段必须把 aid 原样回显为 rid，否则每拍都计一次读错误。
                        rid      <= aid;
                        if (aaddr[7:0] != 8'h00) axi_misalign <= axi_misalign + 1;
                    end
                end
                AXI_LAT: begin
                    aready <= 1'b1;                 // 地址握手一拍
                    if (axi_wait == 0) begin
                        aready  <= 1'b0;
                        axi_beat <= 5'd0;
                        rvalid  <= 1'b1;
                        axi_st  <= AXI_DATA;
                    end else begin
                        axi_wait <= axi_wait - 1'b1;
                    end
                end
                AXI_DATA: begin
                    if (rvalid && rready) begin
                        if (axi_beat == 5'd15) begin
                            rvalid <= 1'b0;
                            rlast  <= 1'b0;
                            axi_st <= AXI_IDLE;
                        end else begin
                            axi_beat <= axi_beat + 1'b1;
                            rlast    <= (axi_beat == 5'd14);
                        end
                    end
                end
                default: axi_st <= AXI_IDLE;
            endcase
        end
    end

    // 组合产生当前拍的 16 字节
    //
    // 槽内偏移必须由**地址减去该槽的基址**算出，不能用地址的低 12 位。
    // 低 12 位等价于"缓冲不超过 4 KB"，而菜单承载路的位图是 544x208/8 = 14,144 字节
    // —— 超过 4 KB 之后偏移会被折回开头，读到的行完全不对。
    // 这个错误的表现极具迷惑性：位图是棋盘格，(行 % 2) 一错就整片相位翻转，
    // 看起来像 RTL 的位序接反了；而 BPR=8/32 的两种几何（2 的幂）恰好看不出问题。
    // 首版就是低 12 位版，menu/max 模式全线失败、fast/full 全过，正是这个原因。
    integer bi, off_in_slot;
    always @(*) begin
        rdata = 128'd0;
        off_in_slot = -1;
        if (region_of(axi_addr) >= 0) begin
            off_in_slot = axi_addr - base_of(region_of(axi_addr));
            for (bi = 0; bi < 16; bi = bi + 1)
                rdata[bi*8 +: 8] =
                    bmp[region_of(axi_addr)*WIN_BYTES +
                        ((off_in_slot + axi_beat*16 + bi) % WIN_BYTES)];
        end
    end

    always @(posedge clk) begin
        if (!reset && rvalid && rready && (region_of(axi_addr) < 0))
            axi_oor <= axi_oor + 1;
    end

    //========================================================================
    // 3) 视频源
    //========================================================================
    integer sx, sy;

    function [15:0] mk_pix;
        input integer x, y;
        begin
            mk_pix = 16'h2000 | (((y * FRAME_W) + x) & 16'h0FFF);
        end
    endfunction

    // 逐像素发送一帧。s_ready 不依赖 s_valid（已核对 RTL），
    // 所以"先给数据、再等 ready"的写法是安全的。
    // ---- 帧中改配置（任务 7.4 的"帧边界原子生效"）----
    // 在指定扫描行的第一个像素处改 p_*。注意改的是 **p_***，而黄金模型的 g_*
    // 只在 SOF 锁存 —— 所以本帧必须仍按旧配置输出，新配置要到下一帧才生效。
    // 若 DUT 提前生效（帧中途就换了配置），当前帧的比对会立刻大面积失配。
    reg                mid_change_on;
    integer            mid_change_line, mid_change_sel;
    reg signed [11:0]  mid_change_left, mid_change_top;

    task apply_mid_change;
        begin
            case (mid_change_sel)
                0: begin p_left0 = mid_change_left; p_top0 = mid_change_top; end
                1: begin p_left1 = mid_change_left; p_top1 = mid_change_top; end
                2: begin p_left2 = mid_change_left; p_top2 = mid_change_top; end
                default: begin p_left3 = mid_change_left; p_top3 = mid_change_top; end
            endcase
        end
    endtask

    // 测试平台自己"在 SOF 锁存配置"。它是独立于 DUT 的一份合同断言：
    // DUT 内部的锁存点与这里不一致时，逐像素比对必然失败。
    task latch_golden;
        begin
            g_global_enable = p_global_enable;
            g_enable = p_enable;
            g_buffer = p_buffer;
            g_left0 = p_left0;  g_top0 = p_top0;
            g_left1 = p_left1;  g_top1 = p_top1;
            g_left2 = p_left2;  g_top2 = p_top2;
            g_left3 = p_left3;  g_top3 = p_top3;
        end
    endtask

    task send_frame;
        begin
            for (sy = 0; sy < FRAME_H; sy = sy + 1) begin
                for (sx = 0; sx < FRAME_W; sx = sx + 1) begin
                    if (mid_change_on && (sy == mid_change_line) && (sx == 0))
                        apply_mid_change;
                    @(negedge clk);
                    s_data  = mk_pix(sx, sy);
                    s_sof   = (sx == 0) && (sy == 0);
                    s_eol   = (sx == FRAME_W - 1);
                    s_valid = 1'b1;
                    @(posedge clk);
                    while (!s_ready) @(posedge clk);   // 等 DUT 真正接收
                    // 这一拍 DUT 收下了 SOF 像素 —— 按 D5 它在**此刻**锁存配置。
                    // 平台独立地做同一件事，作为对锁存时点的断言。
                    if (s_sof) latch_golden;
                    @(negedge clk);
                    s_valid = 1'b0;
                end
            end
        end
    endtask

    //========================================================================
    // 4) 视频槽：逐像素自检 + 可选基线导出
    //========================================================================
    // 位序探针的适用条件（见下方探针段的说明）。
    // 探针字节写在 slot 0，也就是**第 0 路的 A 缓冲**的第 0 行；只有"第 0 路在
    // (0,0)、已使能、且正在读 A 缓冲"时，"dx=0 与 dx=15 必被叠加"这个前提才成立。
    // 别的配置下探针会误报 —— 首版没加这个门，6 个用例被它拖红，
    // 而逐像素比对其实一个都没错。这类"检查本身前提不成立"的假警报最费时间。
    wire probe_applicable = en_eff[0] && (g_left0 == 12'sd0) &&
                            (g_top0 == 12'sd0) && (g_buffer[0] == 1'b0);

    integer    err_count, out_count, exp_x, exp_y;
    integer    bitorder_err;
    reg [15:0] exp_data, probe_want;
    integer    baseline_fd;
    reg        baseline_on;
    reg [1023:0] baseline_path;
    integer      en_tmp;

    initial begin
        err_count = 0; out_count = 0; exp_x = 0; exp_y = 0;
        bitorder_err = 0;
        baseline_on = 1'b0; baseline_fd = 0;
        if ($value$plusargs("BASELINE=%s", baseline_path)) baseline_on = 1'b1;
    end

    always @(posedge clk) begin
        if (!reset && m_valid && m_ready) begin
            out_count = out_count + 1;
            if (baseline_on && (baseline_fd != 0))
                $fwrite(baseline_fd, "%04x\n", m_data);

            // 输出侧的帧内坐标：以 SOF 为 (0,0)。
            // 顺序很重要 —— 必须**先**用当前坐标比较，**再**推进到下一位；
            // 反过来写会让期望值整体错位一格（首版就踩了这个坑）。
            if (m_sof) begin
                exp_x = 0; exp_y = 0;
            end

            exp_data = expected_pixel(exp_x, exp_y);
            if (m_data !== exp_data) begin
                err_count = err_count + 1;
                if (err_count <= 10)
                    $display("MISMATCH: scan(x=%0d,y=%0d) got %04x want %04x",
                             exp_x, exp_y, m_data, exp_data);
            end

            // 位序的**绝对**断言（任务 2.8）：不经过黄金模型。
            // 扫描最后一行对应 disp_y = 0，即窗口 0 的第 0 行；
            // 该行第 0 字节写的是 8'h80、第 1 字节写的是 8'h01，故：
            //   dx=0  -> 叠加（bit7 = 最左）
            //   dx=1..7  -> 透传
            //   dx=8..14 -> 透传
            //   dx=15 -> 叠加（第 1 字节的 bit0 = 该字节最右）
            // 若位序接反，dx=0/15 会翻过来，这里立刻报错。
            if (probe_applicable && (exp_y == FRAME_H - 1) && (exp_x < 16)) begin
                probe_want = ((exp_x == 0) || (exp_x == 15))
                             ? OVERLAY_COLOR : mk_pix(exp_x, exp_y);
                if (m_data !== probe_want) begin
                    bitorder_err = bitorder_err + 1;
                    if (bitorder_err <= 5)
                        $display("BITORDER MISMATCH: dx=%0d got %04x want %04x",
                                 exp_x, m_data, probe_want);
                end
            end

            if (m_eol) begin
                exp_x = 0; exp_y = exp_y + 1;
            end else begin
                exp_x = exp_x + 1;
            end
        end
    end

    //========================================================================
    // 5) 用例机制与主流程
    //========================================================================
    integer     case_err0, case_bo0, case_out0;
    integer     case_burst0, case_stall0, case_frame0;   // 每用例的 AXI 统计快照
    integer     cases_run, cases_bad;
    reg [255:0] case_name;

    task begin_case;
        input [255:0] name;
        begin
            case_name = name;
            case_err0 = err_count;
            case_bo0  = bitorder_err;
            case_out0 = out_count;
            case_burst0 = burst_count;
            case_stall0 = stall_count;
            case_frame0 = frame_count;
        end
    endtask

    // 一个用例的判据有三条，缺一不可：
    //   1) 逐像素零不匹配；2) 位序探针零不匹配；3) 输出像素数正好是一帧。
    // 只看第 1 条会被"少跑了几行"骗过去 —— 少输出自然不会不匹配。
    task end_case;
        begin
            cases_run = cases_run + 1;
            if ((err_count == case_err0) && (bitorder_err == case_bo0) &&
                (out_count == case_out0 + FRAME_W*FRAME_H)) begin
                // 突发数/阻塞周期/帧数一并打出来：任务 7.5 要的"每行冷缺失 <= 1 次"
                // 与阻塞预算就靠这三个数，单独跑一次只为拿数字太浪费。
                $display("  PASS  %0s  [突发 %0d 阻塞 %0d 帧 %0d]",
                         case_name, burst_count - case_burst0,
                         stall_count - case_stall0, frame_count - case_frame0);
            end else begin
                cases_bad = cases_bad + 1;
                $display("  FAIL  %0s  失配=%0d/%0d 位序=%0d 像素=%0d/%0d",
                         case_name, err_count - case_err0, FRAME_W*FRAME_H,
                         bitorder_err - case_bo0, out_count - case_out0,
                         FRAME_W*FRAME_H);
            end
        end
    endtask

    task run_case;
        input [255:0] name;
        begin
            begin_case(name);
            send_frame;
            repeat (64) @(posedge clk);     // 等流水线排空
            end_case;
        end
    endtask

    // 回到"四路同显、全用 A、位置取实参默认值"。每个用例都从它出发，
    // 于是用例之间不会互相带状态 —— 否则某条配置泄漏到下一个用例里，
    // 失败会指向错的地方。
    task cfg_default;
        begin
            p_global_enable = 1'b1;
            p_enable = 4'b1111;
            p_buffer = 4'b0000;
            p_left0 = POS0[31:16]; p_top0 = POS0[15:0];
            p_left1 = POS1[31:16]; p_top1 = POS1[15:0];
            p_left2 = POS2[31:16]; p_top2 = POS2[15:0];
            p_left3 = POS3[31:16]; p_top3 = POS3[15:0];
            mid_change_on = 1'b0;
        end
    endtask

    initial begin
        cfg_default;
        latch_golden;                       // 第一帧之前先对齐，避免 g_* 是 X
        s_data = 16'd0; s_valid = 1'b0; s_sof = 1'b0; s_eol = 1'b0;
        m_ready = 1'b1;
        case_err0 = 0; case_bo0 = 0; case_out0 = 0;
        cases_run = 0; cases_bad = 0;

        repeat (8) @(posedge clk);
        reset = 1'b0;
        repeat (4) @(posedge clk);

        if (baseline_on) begin
            baseline_fd = $fopen(baseline_path, "w");
            if (baseline_fd == 0) begin
                $display("FAIL: 无法打开基线文件 %0s", baseline_path);
                $finish;
            end
            $display("基线导出已开启：%0s", baseline_path);
        end

        $display("几何：画面 %0dx%0d，四路各 %0dx%0d，槽位间距 %0d 字节",
                 FRAME_W, FRAME_H, W0, H0, SLOT);
        if ($value$plusargs("ENABLEMASK=%d", en_tmp)) begin
            p_enable = en_tmp[3:0];          // 兼容旧的单帧调用方式
            run_case("ENABLEMASK 单帧");
        end else begin

        $display("--- 7.2 基础语义 ---");
        cfg_default;                        run_case("4 路同显（全用 A 缓冲）");
        cfg_default; p_enable = 4'b1011;    run_case("单路禁用（第 1 路关）");
        cfg_default; p_global_enable = 0;   run_case("全局禁用");
        cfg_default; p_enable = 4'b0000;    run_case("全部禁用（窗口外全透传）");

        $display("--- 7.3 几何 ---");
        cfg_default;
        p_left0 = FRAME_W - W0; p_top0 = FRAME_H - H0;
        run_case("贴右下角（right/bottom 齐边）");
        cfg_default;
        p_left1 = -8; p_top1 = -8;
        run_case("负偏移（左上越界裁剪）");

        $display("--- 7.4 配置 ---");
        cfg_default; p_buffer = 4'b0100;    run_case("只把第 2 路切到 B 缓冲");
        cfg_default; p_buffer = 4'b1111;    run_case("四路全切到 B 缓冲");
        cfg_default;
        mid_change_on = 1'b1; mid_change_line = FRAME_H/2; mid_change_sel = 1;
        mid_change_left = 8;  mid_change_top = 8;
        run_case("帧中改配置：本帧仍按旧配置");
        mid_change_on = 1'b0;
        run_case("下一帧整体生效");

        $display("--- 7.6 菜单承载路（第 2 路）---");
        cfg_default; p_enable = 4'b0010;    run_case("只使能菜单承载路");
        cfg_default; p_enable = 4'b0011;    run_case("菜单路 + 第 1 路同显");

        $display("--- 7.2 位图为 0（放最后：它会改写位图，不恢复）---");
        for (kk = 0; kk < WIN_BYTES; kk = kk + 1) bmp[2*WIN_BYTES + kk] = 8'h00;
        cfg_default; p_enable = 4'b0010;
        run_case("该路位图全 0（完全不叠加）");

        end

        if (baseline_on && (baseline_fd != 0)) $fclose(baseline_fd);

        $display("--------------------------------------------------");
        $display("用例数           : %0d（失败 %0d）", cases_run, cases_bad);
        $display("输出像素数       : %0d", out_count);
        $display("逐像素不匹配     : %0d", err_count);
        $display("位序探针不匹配   : %0d", bitorder_err);
        $display("AXI 突发数       : %0d (每个 256 字节)", burst_count);
        $display("位图等待累计周期 : %0d", stall_count);
        $display("AXI 越界读       : %0d (预取越界属正常)", axi_oor);
        $display("AXI 非 256 对齐  : %0d (必须为 0)", axi_misalign);
        $display("frame_count      : %0d", frame_count);
        $display("read_error_count : %0d", read_error_count);
        $display("--------------------------------------------------");
        if ((cases_bad == 0) && (err_count == 0) && (bitorder_err == 0) &&
            (axi_misalign == 0) && (read_error_count == 0))
            $display("PASS");
        else
            $display("FAIL");
        $finish;
    end

    // 超时保护：握手死锁时不要挂住
    initial begin
        #2_000_000_000;
        $display("FAIL: 仿真超时（可能是握手死锁）");
        $finish;
    end

endmodule
