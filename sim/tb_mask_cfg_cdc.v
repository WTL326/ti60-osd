`timescale 1ns / 1ps
//============================================================================
// tb_mask_cfg_cdc —— 配置快照通路的端到端自检（任务 4.2 / 7.9）
//----------------------------------------------------------------------------
// 这是**顶层那一半**的验证。叠加模块自己的测试平台（tb_hyperram_mask_overlay）
// 把配置直接接在端口上，走的不是真实路径；真实路径是：
//
//   clk50M 寄存器域
//     → ConfigSnapshotCdc #(105)      （toggle/ack 多位原子快照）
//     → 源选择 mux（rtl_mask_mode）
//     → 叠加模块在 **SOF 那一拍**锁存
//     → 帧边界生效后一拍，把实际生效值经 9 位 CDC 送回 clk50M（ACTIVE 回读）
//
// 4.3 删掉"3 拍 settle"之后，生效点从"延迟 3 拍后的 SOF"变成"快照到达后的第一个
// SOF"。这条路径此前没有任何测试覆盖 —— 本平台就是补它。
//
// 覆盖（对应任务 4.2 与 7.9 的验证条目）：
//   1) 4 路配置经 CDC 正确到达叠加模块（逐像素黄金模型，不是只看寄存器）；
//   2) 只切换第 2 路缓冲时，第 0/1/3 路逐像素不变；
//   3) 帧中提交 -> 当前帧几何不变、下一帧整体生效；
//   4) 控制源切换（rtl_mask_mode）仍有效；
//   5) pending 语义：提交后未生效时 dst_pending=1，生效后清零，
//      且 clk50M 侧的 ack 翻转发生在生效**之后**。
//
// 与 tb_hyperram_mask_overlay 的分工：那个平台管"配置对不对"（位序、几何、A/B、
// 预取、突发数），本平台管"配置怎么到达"（快照、mux、锁存时点）。位图图案因此
// 换成一个对**位置与缓冲**敏感、但不必对位序敏感的函数——位序已由那边的棋盘格
// 与探针覆盖，这里重复一遍只是浪费仿真时间。
//============================================================================

`ifdef FAST_FRAME
`define TB_FRAME_W  180
`define TB_FRAME_H  144
`define TB_W        64
`define TB_H        48
`else
`define TB_FRAME_W  360
`define TB_FRAME_H  288
`define TB_W        128
`define TB_H        96
`endif

module tb_mask_cfg_cdc;

    parameter integer FRAME_W = `TB_FRAME_W;
    parameter integer FRAME_H = `TB_FRAME_H;
    parameter integer W = `TB_W, H = `TB_H;

    localparam integer WIN_BYTES = (W*H)/8;
    localparam integer SLOT      = ((WIN_BYTES + 4095) / 4096) * 4096;

    // 四个窗口摆在画面的四个角，两两不重叠（重叠由软件保证，这里取最简单的布局）
    localparam [11:0] L0 = 0,                    T0 = 0;
    localparam [11:0] L1 = FRAME_W - W,          T1 = 0;
    localparam [11:0] L2 = 0,                    T2 = FRAME_H - H;
    localparam [11:0] L3 = FRAME_W - W,          T3 = FRAME_H - H;

    localparam [31:0] B0A = 32'h0040_0000, B0B = B0A + SLOT;
    localparam [31:0] B1A = B0A + 2*SLOT,  B1B = B1A + SLOT;
    localparam [31:0] B2A = B0A + 4*SLOT,  B2B = B2A + SLOT;
    localparam [31:0] B3A = B0A + 6*SLOT,  B3B = B3A + SLOT;

    localparam [15:0] OVERLAY_COLOR = 16'h80EB;

    //------------------------------------------------------------------------
    // 时钟：clk = 100 MHz（视频/AXI），clk50 = 50 MHz（寄存器域）
    //
    // 两个域用**非整数倍**关系更能暴露"用同一份时钟凑出来"的假验证：
    // 100 与 50 是整数倍，但相位由两个独立的 always 产生，不存在隐含同步。
    //------------------------------------------------------------------------
    reg clk = 1'b0, clk50 = 1'b0;
    always #5 clk = ~clk;
    always #10 clk50 = ~clk50;

    reg reset = 1'b1;

    //------------------------------------------------------------------------
    // 105 位配置的字段布局（与 src/top.v 的 mask_cfg_data 逐位对应）
    //
    // 平台**故意自己拼这一份**（而不是从 dst_data 抄）：拼接方式写错一位，
    // 逐像素比对就会红，于是这个布局本身也被验证了。
    //------------------------------------------------------------------------
    function [104:0] pack_cfg;
        input        g_en;
        input [3:0]  en, bsel;
        input signed [11:0] l0, t0, l1, t1, l2, t2, l3, t3;
        begin
            pack_cfg = { g_en,
                         t3, l3, bsel[3], en[3],
                         t2, l2, bsel[2], en[2],
                         t1, l1, bsel[1], en[1],
                         t0, l0, bsel[0], en[0] };
        end
    endfunction

    //------------------------------------------------------------------------
    // clk50M 域：软件侧"已提交"的配置 c_*
    //------------------------------------------------------------------------
    reg         c_global_en;
    reg  [3:0]  c_en, c_buf;
    reg signed [11:0] c_l0, c_t0, c_l1, c_t1, c_l2, c_t2, c_l3, c_t3;
    reg         c_toggle;

    wire        c_ack_toggle;

    // RTL 上传路径的配置（top.v 里由 RtlMaskUartAxiWriter 驱动的常量侧）。
    // 这里取"只开第 0 路、用 A 缓冲"，与视频侧的配置明显不同 —— 这样
    // "控制源切换是否真的换了配置"在画面上是看得出来的（叠加区域完全不同）。
    reg         rtl_mask_mode = 1'b0;
    localparam  RTL_ENABLE = 1'b1, RTL_BUFFER = 1'b0;

    wire [104:0] cfg_from_cdc;
    wire [104:0] cfg_rtl = { 1'b1,
                             {12'sd0,12'sd0,2'b00},
                             {12'sd0,12'sd0,2'b00},
                             {12'sd0,12'sd0,2'b00},
                             {12'sd0,12'sd0, RTL_BUFFER, RTL_ENABLE} };
    wire [104:0] cfg_eff = rtl_mask_mode ? cfg_rtl : cfg_from_cdc;

    //------------------------------------------------------------------------
    // DUT 1：配置快照 CDC（与 top.v 同位宽、同接法）
    //------------------------------------------------------------------------
    reg         src_toggle_r;
    wire [104:0] src_data = pack_cfg(c_global_en, c_en, c_buf,
                                     c_l0, c_t0, c_l1, c_t1, c_l2, c_t2, c_l3, c_t3);
    wire         dst_pending, dst_apply_pulse;
    reg          dst_apply;

    ConfigSnapshotCdc #(.WIDTH(105)) u_cfg_cdc (
        .src_clk         (clk50),
        .src_reset       (reset),
        .src_data        (src_data),
        .src_toggle      (c_toggle),
        .src_ack_toggle  (c_ack_toggle),
        .dst_clk         (clk),
        .dst_reset       (reset),
        .dst_data        (cfg_from_cdc),
        .dst_pending     (dst_pending),
        .dst_apply       (dst_apply),
        .dst_apply_pulse (dst_apply_pulse)
    );

    //------------------------------------------------------------------------
    // DUT 2：叠加模块
    //------------------------------------------------------------------------
    reg s_valid, s_sof, s_eol;  wire s_ready;
    reg  [15:0] s_data;
    wire [15:0] m_data;  wire m_valid, m_sof, m_eol;  reg  m_ready;

    wire        avalid;  reg aready;
    wire [31:0] aaddr;
    wire [7:0]  aid, alen;
    wire [2:0]  asize;
    wire [1:0]  aburst, alock;
    wire        atype;
    reg  [7:0]  rid;
    reg  [127:0] rdata;
    reg         rlast, rvalid;
    wire        rready;
    reg  [1:0]  rresp;

    wire [15:0] frame_count, read_error_count;
    wire        active;
    wire [3:0]  active_buffer_select, applied_enable;
    wire [31:0] stall_count;

    HyperRamMaskOverlayYuv422 #(
        .OSD0_WIDTH (W), .OSD0_HEIGHT (H),
        .OSD0_BASE_A(B0A), .OSD0_BASE_B(B0B),
        .OSD1_WIDTH (W), .OSD1_HEIGHT (H),
        .OSD1_BASE_A(B1A), .OSD1_BASE_B(B1B),
        .OSD2_WIDTH (W), .OSD2_HEIGHT (H),
        .OSD2_BASE_A(B2A), .OSD2_BASE_B(B2B),
        .OSD3_WIDTH (W), .OSD3_HEIGHT (H),
        .OSD3_BASE_A(B3A), .OSD3_BASE_B(B3B),
        .FRAME_WIDTH(FRAME_W), .FRAME_HEIGHT(FRAME_H),
        .FLIP_VERTICAL_COORDS (1)
    ) u_overlay (
        .clk(clk), .reset(reset),
        .cfg_global_enable (cfg_eff[104]),
        .cfg_enable        ({cfg_eff[78], cfg_eff[52], cfg_eff[26], cfg_eff[0]}),
        .cfg_buffer        ({cfg_eff[79], cfg_eff[53], cfg_eff[27], cfg_eff[1]}),
        .cfg_left0(cfg_eff[13:2]),   .cfg_top0(cfg_eff[25:14]),
        .cfg_left1(cfg_eff[39:28]),  .cfg_top1(cfg_eff[51:40]),
        .cfg_left2(cfg_eff[65:54]),  .cfg_top2(cfg_eff[77:66]),
        .cfg_left3(cfg_eff[91:80]),  .cfg_top3(cfg_eff[103:92]),
        .s_data(s_data), .s_valid(s_valid), .s_sof(s_sof), .s_eol(s_eol),
        .s_ready(s_ready),
        .m_data(m_data), .m_valid(m_valid), .m_sof(m_sof), .m_eol(m_eol),
        .m_ready(m_ready),
        .avalid(avalid), .aready(aready), .aaddr(aaddr), .aid(aid),
        .alen(alen), .asize(asize), .aburst(aburst), .alock(alock),
        .atype(atype),
        .rid(rid), .rdata(rdata), .rlast(rlast), .rvalid(rvalid),
        .rready(rready), .rresp(rresp),
        .frame_count(frame_count), .read_error_count(read_error_count),
        .active(active), .active_buffer_select(active_buffer_select),
        .applied_enable(applied_enable), .stall_count(stall_count)
    );

    //------------------------------------------------------------------------
    // 帧边界生效：与 top.v 的 mask_cfg_apply 同一表达式。
    // 用**输入侧**的 SOF 握手（叠加模块就是在这拍锁存配置），而不是输出侧 ——
    // 输出侧要晚 11 级流水，用它会让 pending 的清零与生效点错开整整一条流水线。
    //------------------------------------------------------------------------
    always @(*) dst_apply = dst_pending && s_valid && s_sof && s_ready;

    //------------------------------------------------------------------------
    // DUT 3：生效值回送（9 位），与 top.v 的 u_mask_applied_cdc 同构
    //------------------------------------------------------------------------
    reg  applied_toggle;
    reg  apply_d;
    always @(posedge clk or posedge reset) begin
        if (reset) begin apply_d <= 1'b0; applied_toggle <= 1'b0; end
        else begin
            apply_d <= dst_apply;                 // 生效后一拍再采，帧锁存值已稳
            if (apply_d) applied_toggle <= ~applied_toggle;
        end
    end

    wire [8:0] applied_data = {applied_enable, active_buffer_select, cfg_eff[104]};
    wire [8:0] applied_sync;
    wire       applied_pending;

    ConfigSnapshotCdc #(.WIDTH(9)) u_applied_cdc (
        .src_clk(clk), .src_reset(reset), .src_data(applied_data),
        .src_toggle(applied_toggle), .src_ack_toggle(),
        .dst_clk(clk50), .dst_reset(reset), .dst_data(applied_sync),
        .dst_pending(applied_pending), .dst_apply(applied_pending),
        .dst_apply_pulse()
    );

    //========================================================================
    // 位图内存模型 + AXI 读从模型 + 黄金模型
    //========================================================================
    reg [7:0] bmp [0:8*WIN_BYTES-1];

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

    function integer region_of;
        input [31:0] a;
        integer s;
        begin
            region_of = -1;
            for (s = 0; s < 8; s = s + 1)
                if ((a >= base_of(s)) && (a < (base_of(s) + WIN_BYTES))) region_of = s;
        end
    endfunction

    // 位图图案：(dx*3 + dy*7) % 11 < 5。
    // 选它而不用棋盘格的三个理由：
    //   1) 对 dx、dy 的**平移**敏感（模 11 不是 2 的幂，平移 1 像素图案就变），
    //      所以"位置配置没送到"或"晚了一帧"都会立刻失配；
    //   2) 对缓冲身份敏感（A 与 B 用不同的相位偏移）；
    //   3) 它不是 2 的周期，所以"行号或字节列算错"不会像棋盘格那样恰好自洽。
    // 位序（MSB first）这里按契约写死 —— 位序本身由 tb_hyperram_mask_overlay
    // 的棋盘格与探针覆盖，本平台不必重复。
    function bit_set;
        input integer dx, dy, phase;
        begin
            bit_set = (((dx*3 + dy*7 + phase) % 11) < 5);
        end
    endfunction

    function [7:0] pack_byte;
        input integer dy, bytecol, phase;
        integer b, dx0;
        begin
            pack_byte = 8'h00;
            dx0 = bytecol * 8;
            for (b = 0; b < 8; b = b + 1)
                if (bit_set(dx0 + b, dy, phase))
                    pack_byte = pack_byte | (8'h01 << (7 - b));   // bit7 最左
        end
    endfunction

    integer ii, jj, kk;
    initial begin
        for (ii = 0; ii < 8*WIN_BYTES; ii = ii + 1) bmp[ii] = 8'h00;
        for (jj = 0; jj < H; jj = jj + 1)
            for (kk = 0; kk < W/8; kk = kk + 1) begin
                // A 缓冲：相位 0；B 缓冲：相位 5（11 的一半，图案明显不同）
                bmp[0*WIN_BYTES + jj*(W/8) + kk] = pack_byte(jj, kk, 0);
                bmp[2*WIN_BYTES + jj*(W/8) + kk] = pack_byte(jj, kk, 0);
                bmp[4*WIN_BYTES + jj*(W/8) + kk] = pack_byte(jj, kk, 0);
                bmp[6*WIN_BYTES + jj*(W/8) + kk] = pack_byte(jj, kk, 0);
                bmp[1*WIN_BYTES + jj*(W/8) + kk] = pack_byte(jj, kk, 5);
                bmp[3*WIN_BYTES + jj*(W/8) + kk] = pack_byte(jj, kk, 5);
                bmp[5*WIN_BYTES + jj*(W/8) + kk] = pack_byte(jj, kk, 5);
                bmp[7*WIN_BYTES + jj*(W/8) + kk] = pack_byte(jj, kk, 5);
            end
    end

    // ---- AXI 读从模型（与 tb_hyperram_mask_overlay 同构，槽内偏移用"地址减基址"）----
    localparam integer RD_LATENCY = 4;
    localparam AXI_IDLE = 2'd0, AXI_LAT = 2'd1, AXI_DATA = 2'd2;
    reg [1:0]  axi_st;
    reg [31:0] axi_addr;
    reg [4:0]  axi_beat;
    reg [4:0]  axi_wait;
    integer    axi_oor, axi_misalign, burst_count;

    initial begin axi_st = AXI_IDLE; axi_addr = 32'd0; axi_beat = 5'd0; axi_wait = 5'd0;
                  axi_oor = 0; axi_misalign = 0; burst_count = 0;
                  aready = 1'b0; rid = 8'h00; rdata = 128'd0; rlast = 1'b0;
                  rvalid = 1'b0; rresp = 2'b00; end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            axi_st <= AXI_IDLE; aready <= 1'b0; rvalid <= 1'b0; rlast <= 1'b0;
            rid <= 8'h00; axi_oor <= 0; axi_misalign <= 0; burst_count <= 0;
        end else begin
            case (axi_st)
                AXI_IDLE: if (avalid) begin
                    axi_addr <= aaddr; axi_wait <= RD_LATENCY; axi_st <= AXI_LAT;
                    rid <= aid; burst_count <= burst_count + 1;
                    if (aaddr[7:0] != 8'h00) axi_misalign <= axi_misalign + 1;
                end
                AXI_LAT: begin
                    aready <= 1'b1;
                    if (axi_wait == 0) begin
                        aready <= 1'b0; axi_beat <= 5'd0;
                        rvalid <= 1'b1; axi_st <= AXI_DATA;
                    end else axi_wait <= axi_wait - 1'b1;
                end
                AXI_DATA: if (rvalid && rready) begin
                    if (axi_beat == 5'd15) begin
                        rvalid <= 1'b0; rlast <= 1'b0; axi_st <= AXI_IDLE;
                    end else begin
                        axi_beat <= axi_beat + 1'b1;
                        rlast <= (axi_beat == 5'd14);
                    end
                end
                default: axi_st <= AXI_IDLE;
            endcase
        end
    end

    integer bi, off_in_slot;
    always @(*) begin
        rdata = 128'd0;
        off_in_slot = -1;
        if (region_of(axi_addr) >= 0) begin
            off_in_slot = axi_addr - base_of(region_of(axi_addr));
            for (bi = 0; bi < 16; bi = bi + 1)
                rdata[bi*8 +: 8] = bmp[region_of(axi_addr)*WIN_BYTES +
                                       ((off_in_slot + axi_beat*16 + bi) % WIN_BYTES)];
        end
    end

    always @(posedge clk) begin
        if (!reset && rvalid && rready && (region_of(axi_addr) < 0)) axi_oor <= axi_oor + 1;
    end

    //========================================================================
    // 黄金模型：**只用平台自己认为已提交的配置**算期望值
    //
    // 关键：期望值绝不从 cfg_eff / cfg_from_cdc 取。取了就等于"拿 DUT 的输入
    // 校验 DUT 的输出"，快照送错值、送晚一帧、mux 选错源，全都测不出来。
    // g_* 在**输入侧 SOF 那一拍**锁存，锁存条件是"这一份提交已经跨过来了"
    // （dst_pending 为 1）—— 这正是 D6 说的"帧边界整体生效"。
    //========================================================================
    reg         g_global_en;
    reg  [3:0]  g_en, g_buf;
    reg signed [11:0] g_l0, g_t0, g_l1, g_t1, g_l2, g_t2, g_l3, g_t3;
    wire [3:0]  g_en_eff = g_en & {4{g_global_en}};

    // 源选择生效时，黄金模型的"该看到什么"要跟着换源：
    // rtl_mask_mode 是组合选择的，不过任何时钟域边界，所以平台按同一条件切换。
    reg         g_rtl_mode;
    wire [3:0]  g_en_eff_final = g_rtl_mode ? {3'b000, RTL_ENABLE} : g_en_eff;
    wire [3:0]  g_buf_final    = g_rtl_mode ? {3'b000, RTL_BUFFER} : g_buf;
    wire signed [11:0] g_l0_f = g_rtl_mode ? 12'sd0 : g_l0;
    wire signed [11:0] g_t0_f = g_rtl_mode ? 12'sd0 : g_t0;

    function integer bpr_of; input integer s; begin bpr_of = W/8; end endfunction
    function integer w_of;   input integer s; begin w_of = W; end endfunction
    function integer h_of;   input integer s; begin h_of = H; end endfunction

    function [15:0] expected_pixel;
        input integer x, y_scan;
        integer dy_disp, sel, dx, dy, bitno, addr, phase;
        reg hit, bitval;
        begin
            expected_pixel = 16'h2000 | (((y_scan * FRAME_W) + x) & 16'h0FFF);
            dy_disp = FRAME_H - 1 - y_scan;
            hit = 1'b0; bitval = 1'b0;

            for (sel = 0; sel < 4; sel = sel + 1) begin
                if (!hit) begin
                    case (sel)
                        0: begin dx = x - g_l0_f; dy = dy_disp - g_t0_f; end
                        1: begin dx = x - (g_rtl_mode ? 12'sd0 : g_l1);
                                 dy = dy_disp - (g_rtl_mode ? 12'sd0 : g_t1); end
                        2: begin dx = x - (g_rtl_mode ? 12'sd0 : g_l2);
                                 dy = dy_disp - (g_rtl_mode ? 12'sd0 : g_t2); end
                        default: begin dx = x - (g_rtl_mode ? 12'sd0 : g_l3);
                                 dy = dy_disp - (g_rtl_mode ? 12'sd0 : g_t3); end
                    endcase
                    hit = (dx >= 0) && (dx < w_of(sel)) && (dy >= 0) && (dy < h_of(sel)) &&
                          g_en_eff_final[sel];
                    if (hit) begin
                        bitno = 7 - (dx % 8);
                        phase = g_buf_final[sel] ? 5 : 0;
                        addr  = (sel*2 + g_buf_final[sel])*WIN_BYTES + dy*bpr_of(sel) + (dx/8);
                        bitval = bmp[addr][bitno];
                        if (bitval) expected_pixel = OVERLAY_COLOR;
                    end
                end
            end
        end
    endfunction

    //========================================================================
    // 输出侧逐像素比对
    //========================================================================
    integer err_count, out_count, exp_x, exp_y;
    reg [15:0] exp_data;
    integer    overlay_hits;      // 被叠加的像素数（看配置是否真的生效）

    always @(posedge clk) begin
        if (!reset && m_valid && m_ready) begin
            out_count = out_count + 1;
            if (m_sof) begin exp_x = 0; exp_y = 0; end

            exp_data = expected_pixel(exp_x, exp_y);
            if (m_data !== exp_data) begin
                err_count = err_count + 1;
                if (err_count <= 10)
                    $display("MISMATCH: scan(x=%0d,y=%0d) got %04x want %04x",
                             exp_x, exp_y, m_data, exp_data);
            end
            if (m_data == OVERLAY_COLOR) overlay_hits = overlay_hits + 1;

            if (m_eol) begin exp_x = 0; exp_y = exp_y + 1; end
            else exp_x = exp_x + 1;
        end
    end

    //========================================================================
    // 驱动

    //========================================================================
    // 用例机制
    //========================================================================
    integer     case_err0, case_out0, case_hits0;
    integer     cases_run, cases_bad;
    reg [255:0] case_name;
    reg         ack_before_commit;   // commit_cfg 记下、wait_applied_ack 使用

    //========================================================================
    integer sx, sy;
    function [15:0] mk_pix; input integer x, y;
        begin mk_pix = 16'h2000 | (((y * FRAME_W) + x) & 16'h0FFF); end
    endfunction

    // 帧中提交的注入点（与 tb_hyperram_mask_overlay 同构）
    reg               mid_commit_on;
    integer           mid_commit_line;
    reg signed [11:0] mid_commit_left, mid_commit_top;
    integer           mid_commit_route;

    task latch_golden;
        begin
            if (g_rtl_mode != rtl_mask_mode) g_rtl_mode = rtl_mask_mode;
            if (dst_pending) begin
                g_global_en = c_global_en;
                g_en = c_en;  g_buf = c_buf;
                g_l0 = c_l0;  g_t0 = c_t0;
                g_l1 = c_l1;  g_t1 = c_t1;
                g_l2 = c_l2;  g_t2 = c_t2;
                g_l3 = c_l3;  g_t3 = c_t3;
            end
        end
    endtask

    task send_frame;
        begin
            for (sy = 0; sy < FRAME_H; sy = sy + 1) begin
                for (sx = 0; sx < FRAME_W; sx = sx + 1) begin
                    if (mid_commit_on && (sy == mid_commit_line) && (sx == 0))
                        commit_mid;
                    @(negedge clk);
                    s_data  = mk_pix(sx, sy);
                    s_sof   = (sx == 0) && (sy == 0);
                    s_eol   = (sx == FRAME_W - 1);
                    s_valid = 1'b1;
                    @(posedge clk);
                    while (!s_ready) @(posedge clk);
                    if (s_sof) latch_golden;
                    @(negedge clk);
                    s_valid = 1'b0;
                end
            end
        end
    endtask

    // clk50M 域：把 c_* 推给快照，并等它**跨到视频域**（dst_pending 抬起）。
    //
    // 为什么不等 ack：ack 要等视频域**在帧边界生效之后**才回来，而生效需要有 SOF。
    // 若在这里等 ack，就必须先发一帧 —— 于是"提交"与"生效"的先后就说不清了，
    // 而这两件事的先后正是本平台要验证的东西。等 dst_pending 只说明"快照到了"，
    // 生效仍交给帧边界，语义干净。
    //
    // 也不等固定周期数：那等于把同步器的级数写死在测试里，改 RTL 就要改测试。
    task commit_cfg;
        input        g_en;
        input [3:0]  en, bsel;
        input signed [11:0] l0, t0, l1, t1, l2, t2, l3, t3;
        integer guard;
        begin
            @(negedge clk50);
            c_global_en = g_en; c_en = en; c_buf = bsel;
            c_l0 = l0; c_t0 = t0; c_l1 = l1; c_t1 = t1;
            c_l2 = l2; c_t2 = t2; c_l3 = l3; c_t3 = t3;
            // 记下**提交前**的 ack 值：生效后它才会翻转，wait_applied_ack 靠它判断。
            // 必须在这里取，不能等发完帧再取 —— 那时它早就翻过了，
            // 再"等它翻转"就会一直等下去（首版就是这么错的，3 条用例假红）。
            ack_before_commit = c_ack_toggle;
            c_toggle = ~c_toggle;

            guard = 0;
            // 跨域观察 dst_pending：测试平台允许，综合代码不允许。
            while ((dst_pending !== 1'b1) && (guard < 4000)) begin
                @(posedge clk); guard = guard + 1;
            end
            if (dst_pending !== 1'b1) begin
                cases_bad = cases_bad + 1;
                $display("  FAIL  提交后 dst_pending 未抬起（CDC 没把新配置送过来）");
            end
        end
    endtask

    // 等"生效后的 ack"回来，并核对回送的生效值。只有在**发过一帧之后**调用才有意义。
    task wait_applied_ack;
        input [3:0] want_en, want_buf;
        integer guard;
        begin
            guard = 0;
            while ((c_ack_toggle == ack_before_commit) && (guard < 4000)) begin
                @(negedge clk50); guard = guard + 1;
            end
            cases_run = cases_run + 1;
            if (c_ack_toggle == ack_before_commit) begin
                cases_bad = cases_bad + 1;
                $display("  FAIL  生效后 ack 未翻转");
            end else if (dst_pending !== 1'b0) begin
                cases_bad = cases_bad + 1;
                $display("  FAIL  生效后 dst_pending 仍为 1");
            end else if ((applied_sync[8:5] !== want_en) ||
                         (applied_sync[4:1] !== want_buf)) begin
                cases_bad = cases_bad + 1;
                $display("  FAIL  回送的生效值不符：en=%b bsel=%b（期望 %b/%b）",
                         applied_sync[8:5], applied_sync[4:1], want_en, want_buf);
            end else begin
                $display("  PASS  生效后 ack 翻转、pending 归零，回送 en=%b bsel=%b",
                         applied_sync[8:5], applied_sync[4:1]);
            end
        end
    endtask

    // 帧中提交：只改路由 mid_commit_route 的位置，然后 toggle。
    // 注意不等待 ack —— 这一条正是要验证"提交了但还没到帧边界时，当前帧不变"。
    task commit_mid;
        begin
            @(negedge clk50);
            case (mid_commit_route)
                0: begin c_l0 = mid_commit_left; c_t0 = mid_commit_top; end
                1: begin c_l1 = mid_commit_left; c_t1 = mid_commit_top; end
                2: begin c_l2 = mid_commit_left; c_t2 = mid_commit_top; end
                default: begin c_l3 = mid_commit_left; c_t3 = mid_commit_top; end
            endcase
            c_toggle = ~c_toggle;
        end
    endtask


    task begin_case;
        input [255:0] name;
        begin
            case_name = name;
            case_err0 = err_count; case_out0 = out_count; case_hits0 = overlay_hits;
        end
    endtask

    task end_case;
        begin
            cases_run = cases_run + 1;
            if ((err_count == case_err0) && (out_count == case_out0 + FRAME_W*FRAME_H)) begin
                $display("  PASS  %0s  [叠加像素 %0d]", case_name,
                         overlay_hits - case_hits0);
            end else begin
                cases_bad = cases_bad + 1;
                $display("  FAIL  %0s  失配=%0d/%0d 像素=%0d/%0d", case_name,
                         err_count - case_err0, FRAME_W*FRAME_H,
                         out_count - case_out0, FRAME_W*FRAME_H);
            end
        end
    endtask

    task run_case;
        input [255:0] name;
        begin
            begin_case(name);
            send_frame;
            repeat (64) @(posedge clk);
            end_case;
        end
    endtask

    //========================================================================
    // 主流程
    //========================================================================
    initial begin
        err_count = 0; out_count = 0; exp_x = 0; exp_y = 0;
        overlay_hits = 0; cases_run = 0; cases_bad = 0;
        mid_commit_on = 1'b0;
        c_toggle = 1'b0; c_global_en = 1'b1; c_en = 4'b1111; c_buf = 4'b0000;
        c_l0 = L0; c_t0 = T0; c_l1 = L1; c_t1 = T1;
        c_l2 = L2; c_t2 = T2; c_l3 = L3; c_t3 = T3;
        g_global_en = 1'b1; g_en = 4'b1111; g_buf = 4'b0000;
        g_l0 = L0; g_t0 = T0; g_l1 = L1; g_t1 = T1;
        g_l2 = L2; g_t2 = T2; g_l3 = L3; g_t3 = T3;
        g_rtl_mode = 1'b0;
        s_data = 16'd0; s_valid = 1'b0; s_sof = 1'b0; s_eol = 1'b0;
        m_ready = 1'b1;

        repeat (8) @(posedge clk);
        reset = 1'b0;
        repeat (8) @(posedge clk);

        $display("几何：画面 %0dx%0d，四路各 %0dx%0d，槽距 %0d 字节",
                 FRAME_W, FRAME_H, W, H, SLOT);

        $display("--- 4.2 配置经 CDC 到达 ---");
        // 提交一次默认配置：CDC 需要一次 toggle 才会把 dst_pending 抬起来，
        // 之后 latch_golden 才认这份配置。生效发生在下一帧的 SOF，所以
        // 顺序是"提交 -> 发帧 -> 等 ack"，不能颠倒（见 commit_cfg 的说明）。
        commit_cfg(1'b1, 4'b1111, 4'b0000,
                   L0, T0, L1, T1, L2, T2, L3, T3);
        run_case("默认配置（4 路同显、全 A）");
        wait_applied_ack(4'b1111, 4'b0000);

        $display("--- 7.9 每路独立 A/B ---");
        commit_cfg(1'b1, 4'b1111, 4'b0100,
                   L0, T0, L1, T1, L2, T2, L3, T3);
        run_case("只把第 2 路切到 B（第 0/1/3 路逐像素不变）");
        wait_applied_ack(4'b1111, 4'b0100);
        commit_cfg(1'b1, 4'b1111, 4'b1111,
                   L0, T0, L1, T1, L2, T2, L3, T3);
        run_case("四路全切到 B");
        commit_cfg(1'b1, 4'b1111, 4'b0000,
                   L0, T0, L1, T1, L2, T2, L3, T3);
        run_case("切回全 A");

        $display("--- 7.9 帧中提交：当前帧不变 / 下一帧整体生效 ---");
        mid_commit_on = 1'b1;
        mid_commit_line = FRAME_H/2; mid_commit_route = 1;
        mid_commit_left = L1 + 4; mid_commit_top = T1 + 4;
        run_case("帧中提交：本帧仍按旧配置");
        mid_commit_on = 1'b0;
        run_case("下一帧整体生效");
        // 再提交回去，后面的用例从默认布局出发
        commit_cfg(1'b1, 4'b1111, 4'b0000,
                   L0, T0, L1, T1, L2, T2, L3, T3);
        run_case("恢复默认布局");

        $display("--- 4.2 控制源切换（rtl_mask_mode）---");
        rtl_mask_mode = 1'b1;
        run_case("切到 RTL 上传侧（只开第 0 路、A 缓冲）");
        rtl_mask_mode = 1'b0;
        run_case("切回软核侧（视频配置恢复）");
        wait_applied_ack(4'b1111, 4'b0000);

        $display("--- 使能组合（经 CDC）---");
        commit_cfg(1'b1, 4'b1011, 4'b0000,
                   L0, T0, L1, T1, L2, T2, L3, T3);
        run_case("单路禁用");
        commit_cfg(1'b0, 4'b1111, 4'b0000,
                   L0, T0, L1, T1, L2, T2, L3, T3);
        run_case("全局禁用");
        commit_cfg(1'b1, 4'b1111, 4'b0000,
                   L0, T0, L1, T1, L2, T2, L3, T3);
        run_case("恢复");

        $display("--------------------------------------------------");
        $display("用例数           : %0d（失败 %0d）", cases_run, cases_bad);
        $display("输出像素数       : %0d", out_count);
        $display("逐像素不匹配     : %0d", err_count);
        $display("AXI 突发数       : %0d", burst_count);
        $display("AXI 越界读       : %0d", axi_oor);
        $display("AXI 非 256 对齐  : %0d (必须为 0)", axi_misalign);
        $display("read_error_count : %0d", read_error_count);
        $display("frame_count      : %0d", frame_count);
        $display("--------------------------------------------------");
        if ((cases_bad == 0) && (err_count == 0) && (axi_misalign == 0) &&
            (read_error_count == 0))
            $display("PASS");
        else
            $display("FAIL");
        $finish;
    end

    initial begin
        #500_000_000;
        $display("FAIL: 仿真超时（可能是 CDC 的 ack 没有回来）");
        $finish;
    end

endmodule
