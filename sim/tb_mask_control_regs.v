`timescale 1ns / 1ps
//============================================================================
// tb_mask_control_regs —— MaskControlRegs（D6 的 12 字映射）自检测试平台
//
// 覆盖任务 3.1 / 3.2：
//   * 12 字映射的读回：CANVAS / STATUS / ACTIVE，以及 W 寄存器与 +0x30 以上读 0
//   * 暂存语义：只写 POS/CTRL 不提交 -> 输出不变（未提交的写入不生效）
//   * 原子提交：一次 COMMAND 把 4 路的 POS/CTRL 一起推出去
//   * pending 期间拒绝二次提交，且已提交内容不被破坏
//   * ACTIVE 回读的是 applied_* 输入（帧边界前是旧值、之后是新值）
//
// AXI 主模型按单拍读写实现（本模块只有单拍端点）。
//============================================================================
module tb_mask_control_regs;

    localparam [31:0] A_COMMAND = 32'h00, A_STATUS = 32'h04, A_CANVAS = 32'h08,
                      A_ACTIVE  = 32'h0C,
                      A_POS0    = 32'h10, A_CTRL0  = 32'h14,
                      A_POS1    = 32'h18, A_CTRL1  = 32'h1C,
                      A_POS2    = 32'h20, A_CTRL2  = 32'h24,
                      A_POS3    = 32'h28, A_CTRL3  = 32'h2C;

    reg clk = 1'b0, reset = 1'b1;
    always #5 clk = ~clk;

    reg  [7:0]  s_awid;   reg [31:0] s_awaddr;  reg [7:0] s_awlen;
    reg  [2:0]  s_awsize; reg        s_awvalid; wire s_awready;
    reg  [31:0] s_wdata;  reg [3:0]  s_wstrb;   reg s_wlast, s_wvalid;
    wire        s_wready;
    wire [7:0]  s_bid;    wire [1:0] s_bresp;   wire s_bvalid;  reg s_bready;
    reg  [7:0]  s_arid;   reg [31:0] s_araddr;  reg [7:0] s_arlen;
    reg  [2:0]  s_arsize; reg        s_arvalid; wire s_arready;
    wire [7:0]  s_rid;    wire [31:0] s_rdata;  wire [1:0] s_rresp;
    wire        s_rlast, s_rvalid;  reg s_rready;

    wire         cfg_global_enable;
    wire [3:0]   cfg_enable, cfg_buffer;
    wire signed [11:0] cfg_left0, cfg_left1, cfg_left2, cfg_left3;
    wire signed [11:0] cfg_top0,  cfg_top1,  cfg_top2,  cfg_top3;
    wire         cfg_toggle;
    reg          applied_toggle;
    reg  [3:0]   applied_enable, applied_buffer_select;
    reg          applied_global_enable;
    wire [15:0]  commit_count;

    MaskControlRegs dut (
        .clk(clk), .reset(reset),
        .s_awid(s_awid), .s_awaddr(s_awaddr), .s_awlen(s_awlen),
        .s_awsize(s_awsize), .s_awvalid(s_awvalid), .s_awready(s_awready),
        .s_wdata(s_wdata), .s_wstrb(s_wstrb), .s_wlast(s_wlast),
        .s_wvalid(s_wvalid), .s_wready(s_wready),
        .s_bid(s_bid), .s_bresp(s_bresp), .s_bvalid(s_bvalid), .s_bready(s_bready),
        .s_arid(s_arid), .s_araddr(s_araddr), .s_arlen(s_arlen),
        .s_arsize(s_arsize), .s_arvalid(s_arvalid), .s_arready(s_arready),
        .s_rid(s_rid), .s_rdata(s_rdata), .s_rresp(s_rresp),
        .s_rlast(s_rlast), .s_rvalid(s_rvalid), .s_rready(s_rready),
        .cfg_global_enable(cfg_global_enable),
        .cfg_enable(cfg_enable), .cfg_buffer(cfg_buffer),
        .cfg_left0(cfg_left0), .cfg_left1(cfg_left1),
        .cfg_left2(cfg_left2), .cfg_left3(cfg_left3),
        .cfg_top0(cfg_top0), .cfg_top1(cfg_top1),
        .cfg_top2(cfg_top2), .cfg_top3(cfg_top3),
        .cfg_toggle(cfg_toggle), .applied_toggle(applied_toggle),
        .applied_enable(applied_enable),
        .applied_buffer_select(applied_buffer_select),
        .applied_global_enable(applied_global_enable),
        .commit_count(commit_count)
    );

    integer err_count;
    integer rd_value;

    //------------------------------------------------------------------------
    // 单拍 AXI 读写
    //------------------------------------------------------------------------
    //------------------------------------------------------------------------
    // 单拍 AXI 读写
    //
    // 采样纪律（这里踩过坑，写清楚）：**在 negedge 观察 ready，在随后的 posedge
    // 完成握手，握手后再撤销 valid**。原因是 awready/wready 是组合值，且它们
    // 恰恰在握手那一拍的 posedge 之后被拉低（aw_pending 置起）—— 若在 posedge
    // 之后才去读 ready，看到的是"下一拍"的值，会误判成"还没握手"而死等。
    //------------------------------------------------------------------------
    task axi_write;
        input [31:0] addr;
        input [31:0] data;
        reg aw_ok, w_ok;
        begin
            @(negedge clk);
            s_awaddr = addr; s_awlen = 8'd0; s_awsize = 3'd2; s_awvalid = 1'b1;
            s_wdata = data;  s_wstrb = 4'hF; s_wlast = 1'b1;  s_wvalid = 1'b1;
            aw_ok = 1'b0; w_ok = 1'b0;
            while (!(aw_ok && w_ok)) begin
                if (!aw_ok && s_awready) aw_ok = 1'b1;
                if (!w_ok  && s_wready)  w_ok  = 1'b1;
                @(posedge clk);
                if (aw_ok) s_awvalid = 1'b0;
                if (w_ok)  s_wvalid  = 1'b0;
                @(negedge clk);
            end
            s_wlast  = 1'b0;
            s_bready = 1'b1;
            while (!s_bvalid) @(negedge clk);
            @(negedge clk);
            s_bready = 1'b0;
        end
    endtask

    task axi_read;
        input  [31:0] addr;
        output integer value;
        reg ar_ok;
        begin
            @(negedge clk);
            s_araddr = addr; s_arlen = 8'd0; s_arsize = 3'd2; s_arvalid = 1'b1;
            ar_ok = 1'b0;
            while (!ar_ok) begin
                if (s_arready) ar_ok = 1'b1;
                @(posedge clk);
                if (ar_ok) s_arvalid = 1'b0;
                @(negedge clk);
            end
            s_rready = 1'b1;
            while (!s_rvalid) @(negedge clk);
            value = s_rdata;
            @(negedge clk);
            s_rready = 1'b0;
        end
    endtask

    task check;
        input [255:0] what;
        input integer got;
        input integer want;
        begin
            if (got !== want) begin
                err_count = err_count + 1;
                $display("MISMATCH: %0s got %0d(%08x) want %0d(%08x)",
                         what, got, got, want, want);
            end
        end
    endtask

    integer v;

    initial begin
        err_count = 0;
        s_awid = 8'h00; s_awaddr = 32'd0; s_awlen = 8'd0; s_awsize = 3'd2;
        s_awvalid = 1'b0; s_wdata = 32'd0; s_wstrb = 4'h0; s_wlast = 1'b0;
        s_wvalid = 1'b0; s_bready = 1'b0;
        s_arid = 8'h00; s_araddr = 32'd0; s_arlen = 8'd0; s_arsize = 3'd2;
        s_arvalid = 1'b0; s_rready = 1'b0;
        applied_toggle = 1'b0;
        applied_enable = 4'b0000;
        applied_buffer_select = 4'b0000;
        applied_global_enable = 1'b0;

        repeat (6) @(posedge clk);
        reset = 1'b0;
        repeat (2) @(posedge clk);

        // ---- 复位后的静态值 ----
        axi_read(A_CANVAS, v);   check("CANVAS",   v, 32'h02D0_0240);
        axi_read(A_STATUS, v);   check("STATUS.pending 初始", v[2], 1'b0);
        axi_read(A_ACTIVE, v);   check("ACTIVE 初始", v, 32'd0);
        axi_read(32'h30, v);     check("+0x30 读 0", v, 32'd0);
        axi_read(32'h40, v);     check("+0x40 读 0", v, 32'd0);

        // ---- 暂存：只写 POS/CTRL 不提交，输出必须不动（任务 3.1）----
        axi_write(A_POS0, {8'd0, 12'sd10, 12'sd20});     // top=10, left=20
        axi_write(A_CTRL0, 32'h3);                        // buffer=1, enable=1
        axi_write(A_POS1, {8'd0, 12'sd30, 12'sd40});
        axi_write(A_CTRL1, 32'h1);
        check("未提交时 cfg_enable", cfg_enable, 4'd0);
        check("未提交时 cfg_left0",  cfg_left0,  12'sd0);
        check("未提交时 commit_count", commit_count, 16'd0);

        // ---- 提交：4 路一起生效（原子）----
        axi_write(A_POS2, {8'd0, 12'sd50, 12'sd60});
        axi_write(A_CTRL2, 32'h2);
        axi_write(A_POS3, {8'd0, 12'sd70, 12'sd80});
        axi_write(A_CTRL3, 32'h3);
        axi_write(A_COMMAND, 32'h8000_0001);              // commit + 全局使能
        check("提交后 cfg_global_enable", cfg_global_enable, 1'b1);
        check("提交后 cfg_enable",  cfg_enable,  4'b1011);
        check("提交后 cfg_buffer",  cfg_buffer,  4'b1101);
        check("提交后 cfg_left0",   cfg_left0,   12'sd20);
        check("提交后 cfg_top0",    cfg_top0,    12'sd10);
        check("提交后 cfg_left1",   cfg_left1,   12'sd40);
        check("提交后 cfg_left3",   cfg_left3,   12'sd80);
        check("提交后 commit_count", commit_count, 16'd1);

        // ---- pending 期间拒绝二次提交，且内容不被破坏（任务 3.1）----
        axi_write(A_POS0, {8'd0, 12'sd11, 12'sd21});
        axi_write(A_COMMAND, 32'h8000_0000);   // 试图二次提交
        check("pending 期间 commit_count 不变", commit_count, 16'd1);
        check("pending 期间 cfg_left0 不被破坏", cfg_left0, 12'sd20);

        // ---- 帧边界：applied_toggle 翻转 -> pending 清零 ----
        applied_enable = 4'b1111;
        applied_buffer_select = 4'b1101;
        applied_global_enable = 1'b1;
        @(negedge clk); applied_toggle = cfg_toggle;
        @(posedge clk); @(posedge clk);
        axi_read(A_STATUS, v);
        check("生效后 pending", v[2], 1'b0);
        check("STATUS.applied_global_enable", v[0], 1'b1);
        check("STATUS.commit_count", v[31:16], 16'd1);
        axi_read(A_ACTIVE, v);
        // ACTIVE = {24'd0, applied_enable[3:0], applied_buffer_select[3:0]}
        // —— enable 在高半字节。首版把两者写反了（RTL 是对的）。
        check("ACTIVE.applied_buffer_select", v[3:0], 4'b1101);
        check("ACTIVE.applied_enable", v[7:4], 4'b1111);

        // ---- 生效后可以再次提交（任务 3.1 的正向路径）----
        axi_write(A_COMMAND, 32'h8000_0000);   // 不带全局使能 -> 关全局
        check("二次提交生效", commit_count, 16'd2);
        check("二次提交 cfg_global_enable=0", cfg_global_enable, 1'b0);

        // ---- ACTIVE 跟随即时输入（帧边界前是旧值、之后是新值，任务 3.2）----
        applied_enable = 4'b0010;
        applied_buffer_select = 4'b0100;
        @(posedge clk); @(posedge clk);
        axi_read(A_ACTIVE, v);
        check("ACTIVE 跟随新输入", v, {24'd0, 4'b0010, 4'b0100});

        $display("--------------------------------------------------");
        $display("MaskControlRegs 断言失败数: %0d", err_count);
        $display("--------------------------------------------------");
        if (err_count == 0) $display("PASS"); else $display("FAIL");
        $finish;
    end

    initial begin
        #2_000_000;
        $display("FAIL: 仿真超时（可能是 AXI 握手死锁）");
        $finish;
    end

endmodule
