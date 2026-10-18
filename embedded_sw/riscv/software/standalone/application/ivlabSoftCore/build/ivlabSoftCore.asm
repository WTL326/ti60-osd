
build/ivlabSoftCore.elf:     file format elf32-littleriscv


Disassembly of section .init:

00001000 <_start>:

_start:
#ifdef USE_GP
.option push
.option norelax
	la gp, __global_pointer$
    1000:	00005197          	auipc	gp,0x5
    1004:	fa818193          	addi	gp,gp,-88 # 5fa8 <__global_pointer$>
.global smp_lottery_target
.global smp_lottery_lock
.global smp_slave


  sw x0, smp_lottery_lock, a1
    1008:	00007597          	auipc	a1,0x7
    100c:	a205ae23          	sw	zero,-1476(a1) # 7a44 <smp_lottery_lock>

00001010 <smp_tyranny>:

smp_tyranny:
  csrr a0, mhartid
    1010:	f1402573          	csrr	a0,mhartid
  beqz a0, init
    1014:	04050663          	beqz	a0,1060 <init>

00001018 <smp_slave>:

smp_slave:
	lw a0, smp_lottery_lock
    1018:	00007517          	auipc	a0,0x7
    101c:	a2c52503          	lw	a0,-1492(a0) # 7a44 <smp_lottery_lock>
	beqz a0, smp_slave
    1020:	fe050ce3          	beqz	a0,1018 <smp_slave>

	fence r, r
    1024:	0220000f          	fence	r,r
    1028:	0000100f          	.word	0x0000100f
	//li a1, -1
	//amoadd.w x0, a1,(a0)

	.word(0x100F) //i$ flush
	lw a5, smp_lottery_target
    102c:	00007797          	auipc	a5,0x7
    1030:	a147a783          	lw	a5,-1516(a5) # 7a40 <smp_lottery_target>
	li a0, 0
    1034:	00000513          	li	a0,0
	li a1, 0
    1038:	00000593          	li	a1,0
	li a2, 0
    103c:	00000613          	li	a2,0
	jr a5
    1040:	00078067          	jr	a5

00001044 <smp_unlock>:

.global   smp_unlock
.type    smp_unlock,%function
smp_unlock:
	sw a0, smp_lottery_target, a1
    1044:	00007597          	auipc	a1,0x7
    1048:	9ea5ae23          	sw	a0,-1540(a1) # 7a40 <smp_lottery_target>
	fence w, w
    104c:	0110000f          	fence	w,w
	li a0, 1
    1050:	00100513          	li	a0,1
	sw a0, smp_lottery_lock, a1
    1054:	00007597          	auipc	a1,0x7
    1058:	9ea5a823          	sw	a0,-1552(a1) # 7a44 <smp_lottery_lock>
    ret
    105c:	00008067          	ret

00001060 <init>:
#endif

init:
	la sp, _sp
    1060:	00008117          	auipc	sp,0x8
    1064:	d6010113          	addi	sp,sp,-672 # 8dc0 <__freertos_irq_stack_top>

	/* Load data section */
	la a0, _data_lma
    1068:	00003517          	auipc	a0,0x3
    106c:	f1c50513          	addi	a0,a0,-228 # 3f84 <_data>
	la a1, _data
    1070:	00003597          	auipc	a1,0x3
    1074:	f1458593          	addi	a1,a1,-236 # 3f84 <_data>
	la a2, _edata
    1078:	00004617          	auipc	a2,0x4
    107c:	74c60613          	addi	a2,a2,1868 # 57c4 <__bss_start>
	bgeu a1, a2, 2f
    1080:	00c5fc63          	bgeu	a1,a2,1098 <init+0x38>
1:
	lw t0, (a0)
    1084:	00052283          	lw	t0,0(a0)
	sw t0, (a1)
    1088:	0055a023          	sw	t0,0(a1)
	addi a0, a0, 4
    108c:	00450513          	addi	a0,a0,4
	addi a1, a1, 4
    1090:	00458593          	addi	a1,a1,4
	bltu a1, a2, 1b
    1094:	fec5e8e3          	bltu	a1,a2,1084 <init+0x24>
2:

	/* Clear bss section */
	la a0, __bss_start
    1098:	00004517          	auipc	a0,0x4
    109c:	72c50513          	addi	a0,a0,1836 # 57c4 <__bss_start>
	la a1, _end
    10a0:	00007597          	auipc	a1,0x7
    10a4:	d2058593          	addi	a1,a1,-736 # 7dc0 <_end>
	bgeu a0, a1, 2f
    10a8:	00b57863          	bgeu	a0,a1,10b8 <init+0x58>
1:
	sw zero, (a0)
    10ac:	00052023          	sw	zero,0(a0)
	addi a0, a0, 4
    10b0:	00450513          	addi	a0,a0,4
	bltu a0, a1, 1b
    10b4:	feb56ce3          	bltu	a0,a1,10ac <init+0x4c>
2:

#ifndef NO_LIBC_INIT_ARRAY
	call __libc_init_array
    10b8:	010000ef          	jal	10c8 <__libc_init_array>
#endif

	call main
    10bc:	0a0000ef          	jal	115c <main>

000010c0 <mainDone>:
mainDone:
    j mainDone
    10c0:	0000006f          	j	10c0 <mainDone>

000010c4 <_init>:


	.globl _init
_init:
    ret
    10c4:	00008067          	ret

Disassembly of section .text:

000010c8 <__libc_init_array>:
    10c8:	ff010113          	addi	sp,sp,-16
    10cc:	00812423          	sw	s0,8(sp)
    10d0:	01212023          	sw	s2,0(sp)
    10d4:	00003797          	auipc	a5,0x3
    10d8:	eb078793          	addi	a5,a5,-336 # 3f84 <_data>
    10dc:	00003417          	auipc	s0,0x3
    10e0:	ea840413          	addi	s0,s0,-344 # 3f84 <_data>
    10e4:	00112623          	sw	ra,12(sp)
    10e8:	00912223          	sw	s1,4(sp)
    10ec:	40878933          	sub	s2,a5,s0
    10f0:	02878063          	beq	a5,s0,1110 <__libc_init_array+0x48>
    10f4:	40295913          	srai	s2,s2,0x2
    10f8:	00000493          	li	s1,0
    10fc:	00042783          	lw	a5,0(s0)
    1100:	00148493          	addi	s1,s1,1
    1104:	00440413          	addi	s0,s0,4
    1108:	000780e7          	jalr	a5
    110c:	ff24e8e3          	bltu	s1,s2,10fc <__libc_init_array+0x34>
    1110:	00003797          	auipc	a5,0x3
    1114:	e7478793          	addi	a5,a5,-396 # 3f84 <_data>
    1118:	00003417          	auipc	s0,0x3
    111c:	e6c40413          	addi	s0,s0,-404 # 3f84 <_data>
    1120:	40878933          	sub	s2,a5,s0
    1124:	40295913          	srai	s2,s2,0x2
    1128:	00878e63          	beq	a5,s0,1144 <__libc_init_array+0x7c>
    112c:	00000493          	li	s1,0
    1130:	00042783          	lw	a5,0(s0)
    1134:	00148493          	addi	s1,s1,1
    1138:	00440413          	addi	s0,s0,4
    113c:	000780e7          	jalr	a5
    1140:	ff24e8e3          	bltu	s1,s2,1130 <__libc_init_array+0x68>
    1144:	00c12083          	lw	ra,12(sp)
    1148:	00812403          	lw	s0,8(sp)
    114c:	00412483          	lw	s1,4(sp)
    1150:	00012903          	lw	s2,0(sp)
    1154:	01010113          	addi	sp,sp,16
    1158:	00008067          	ret

0000115c <main>:
*         proto_uart_init()  配置 uart1 和它的中断源
*         isr_init()      最后才打开中断总开关
*       把 isr_init() 放在最后是关键的：如果先开中断再配 uart1，
*       中间那个窗口里进来的中断会找不到正确的处理路径。
******************************************************************************/
void main() {
    115c:	fd010113          	addi	sp,sp,-48
    1160:	02112623          	sw	ra,44(sp)
    bsp_init();                 /* BSP 的通用初始化，其中包含 uart0 的配置 */
    1164:	039000ef          	jal	199c <bsp_init>
    app_log_init();
    1168:	574000ef          	jal	16dc <app_log_init>
    frame_parser_init(&s_parser);
    116c:	00008537          	lui	a0,0x8
    1170:	81050513          	addi	a0,a0,-2032 # 7810 <s_parser>
    1174:	240010ef          	jal	23b4 <frame_parser_init>
    protocol_init(&s_stats);
    1178:	00008537          	lui	a0,0x8
    117c:	80450513          	addi	a0,a0,-2044 # 7804 <s_stats>
    1180:	35d010ef          	jal	2cdc <protocol_init>
    /* 引擎初始化会清两块画布、渲染并提交第一屏，所以上电即有菜单。
     * 它排在 isr_init() 之前：这期间要写几千次 AXI，中断还没开就不会有
     * 字节挤在接收环里等 —— 虽然不会丢，但没必要留这个尾巴。*/
    osd_engine_boot();
    1184:	17c020ef          	jal	3300 <osd_engine_boot>

    /* 启动横幅。这几行主要是给现场确认"固件确实跑起来了"用的。
     * 把协议出处一并打出来：这条串口线上跑着好几个功能模块的帧，出问题时
     * 第一件要确认的就是"两端说的是不是同一代协议"。*/
    app_log("*** ivlabSoftCore ***");
    1188:	00004537          	lui	a0,0x4
    118c:	41050513          	addi	a0,a0,1040 # 4410 <_data+0x48c>
    1190:	64c000ef          	jal	17dc <app_log>
    app_log("debug channel: semihosting (JTAG)");
    1194:	00004537          	lui	a0,0x4
    1198:	42850513          	addi	a0,a0,1064 # 4428 <_data+0x4a4>
    119c:	640000ef          	jal	17dc <app_log>
    app_log("protocol: BB frame, categories 0x00 (mask) + 0x04 (UI)");
    11a0:	00004537          	lui	a0,0x4
    11a4:	44c50513          	addi	a0,a0,1100 # 444c <_data+0x4c8>
    11a8:	634000ef          	jal	17dc <app_log>
    app_log("osd: menu on OSD1 272x208 1bpp 8x16 cell, canvas A/B = 0x%x / 0x%x",
    11ac:	00b40637          	lui	a2,0xb40
    11b0:	00a405b7          	lui	a1,0xa40
    11b4:	00004537          	lui	a0,0x4
    11b8:	48450513          	addi	a0,a0,1156 # 4484 <_data+0x500>
    11bc:	620000ef          	jal	17dc <app_log>

#if OSD_BOOT_DIAG
    /* 紧接着上电渲染做一次硬件回读。**排在 isr_init() 之前**：这一段要打
     * 几千字符、每次 semihosting 都会让 hart 停一下，中断还没开就不会挤爆
     * uart1 的接收 FIFO。理由与 osd_engine_boot() 排在同一个位置相同。*/
    osd_boot_diag();
    11c0:	61d000ef          	jal	1fdc <osd_boot_diag>

    /* 协议端点可用与否，取决于 SoC 是否生成了 uart1（见 proto_uart.h）。
     * 这里把结果明确打出来：一是让现场知道协议能不能用，二是它的 base 地址
     * 可以和 RTL 侧的 rtl_mask_mode 取值交叉核对，确认"只有一个端点在应答"。*/
    if (PROTO_ENDPOINT_AVAILABLE) {
        proto_uart_init();
    11c4:	5d0010ef          	jal	2794 <proto_uart_init>
        isr_init();
    11c8:	045000ef          	jal	1a0c <isr_init>
        app_log("protocol endpoint: ENABLED on uart1 (base 0x%x)",
    11cc:	f80025b7          	lui	a1,0xf8002
    11d0:	00004537          	lui	a0,0x4
    11d4:	4c850513          	addi	a0,a0,1224 # 44c8 <_data+0x544>
    11d8:	604000ef          	jal	17dc <app_log>
    11dc:	0340006f          	j	1210 <main+0xb4>
         * 这样做的代价是日志不再"实时"——但换来的是协议本身可靠，而且那批
         * 日志会在结束后的 200 ms 内完整出现，排查并不受影响。
         *
         * 另外注意：**画布渲染不在这个循环里**，它随命令在 osd_engine_handle()
         * 里同步完成。所以"线路静默"这条门槛只推迟日志、不推迟画面。*/
        if ((app_log_pending() != 0U) || (s_frames_processed != s_reported_frames)) {
    11e0:	510000ef          	jal	16f0 <app_log_pending>
    11e4:	00051863          	bnez	a0,11f4 <main+0x98>
    11e8:	8641a703          	lw	a4,-1948(gp) # 580c <s_frames_processed>
    11ec:	8441a783          	lw	a5,-1980(gp) # 57ec <s_reported_frames>
    11f0:	02f70063          	beq	a4,a5,1210 <main+0xb4>
            /* 读 CLINT 时间是 3 次 MMIO，不能每轮都做；用计数器粗降频。*/
            s_idle_spins++;
    11f4:	8401a783          	lw	a5,-1984(gp) # 57e8 <s_idle_spins>
    11f8:	00178793          	addi	a5,a5,1
    11fc:	84f1a023          	sw	a5,-1984(gp) # 57e8 <s_idle_spins>
            if ((s_idle_spins & (IDLE_TICKS_DIVIDER - 1U)) == 0U) {
    1200:	00001737          	lui	a4,0x1
    1204:	fff70713          	addi	a4,a4,-1 # fff <CUSTOM2+0xfa4>
    1208:	00e7f7b3          	and	a5,a5,a4
    120c:	04078263          	beqz	a5,1250 <main+0xf4>
        while (proto_uart_rx_pop(&byte)) {
    1210:	00710513          	addi	a0,sp,7
    1214:	614010ef          	jal	2828 <proto_uart_rx_pop>
    1218:	fc0504e3          	beqz	a0,11e0 <main+0x84>
            s_last_rx_ticks = clint_getTime(BSP_CLINT);
    121c:	f8b00537          	lui	a0,0xf8b00
    1220:	74c000ef          	jal	196c <clint_getTime>
    1224:	84a1a423          	sw	a0,-1976(gp) # 57f0 <s_last_rx_ticks>
    1228:	84b1a623          	sw	a1,-1972(gp) # 57f4 <s_last_rx_ticks+0x4>
            if (frame_parser_feed(&s_parser, byte, &frame) != 0) {
    122c:	00810613          	addi	a2,sp,8
    1230:	00714583          	lbu	a1,7(sp)
    1234:	00008537          	lui	a0,0x8
    1238:	81050513          	addi	a0,a0,-2032 # 7810 <s_parser>
    123c:	1cc010ef          	jal	2408 <frame_parser_feed>
    1240:	fc0508e3          	beqz	a0,1210 <main+0xb4>
                handle_frame(&frame);
    1244:	00810513          	addi	a0,sp,8
    1248:	7bd000ef          	jal	2204 <handle_frame>
    124c:	fc5ff06f          	j	1210 <main+0xb4>
                if ((clint_getTime(BSP_CLINT) - s_last_rx_ticks) >= APP_LOG_IDLE_TICKS) {
    1250:	f8b00537          	lui	a0,0xf8b00
    1254:	718000ef          	jal	196c <clint_getTime>
    1258:	8481a783          	lw	a5,-1976(gp) # 57f0 <s_last_rx_ticks>
    125c:	84c1a703          	lw	a4,-1972(gp) # 57f4 <s_last_rx_ticks+0x4>
    1260:	40f507b3          	sub	a5,a0,a5
    1264:	00f53533          	sltu	a0,a0,a5
    1268:	40e585b3          	sub	a1,a1,a4
    126c:	40a58733          	sub	a4,a1,a0
    1270:	00a59a63          	bne	a1,a0,1284 <main+0x128>
    1274:	f8071ee3          	bnez	a4,1210 <main+0xb4>
    1278:	00989737          	lui	a4,0x989
    127c:	67f70713          	addi	a4,a4,1663 # 98967f <__freertos_irq_stack_top+0x9808bf>
    1280:	f8f778e3          	bgeu	a4,a5,1210 <main+0xb4>
                    /* 线路静默够久，说明这一批数据结束了。先补一条汇总，
                     * 保证"这一批收了多少、丢了多少"一定可见——短跑批够不到
                     * STATS_INTERVAL，没有这一条就什么都看不到。*/
                    if (s_frames_processed != s_reported_frames) {
    1284:	8641a703          	lw	a4,-1948(gp) # 580c <s_frames_processed>
    1288:	8441a783          	lw	a5,-1980(gp) # 57ec <s_reported_frames>
    128c:	00f71663          	bne	a4,a5,1298 <main+0x13c>
                        log_stats();
                    }
                    (void)app_log_flush();
    1290:	5f0000ef          	jal	1880 <app_log_flush>
    while (1) {
    1294:	f7dff06f          	j	1210 <main+0xb4>
                        log_stats();
    1298:	6ad000ef          	jal	2144 <log_stats>
    129c:	ff5ff06f          	j	1290 <main+0x134>

000012a0 <emit_char>:
* @note 空间不够时**返回原位置、不写入**，也就是说超长内容是被截断的，
*       而不是溢出。所有输出路径都要经过这个函数，边界检查就只需要在这一处
*       做对。
******************************************************************************/
static uint32_t emit_char(char *out, uint32_t pos, uint32_t cap, char c)
{
    12a0:	00050793          	mv	a5,a0
    12a4:	00058513          	mv	a0,a1
    if ((pos + 1U) < cap) {
    12a8:	00158713          	addi	a4,a1,1 # f8002001 <__freertos_irq_stack_top+0xf7ff9241>
    12ac:	00c76463          	bltu	a4,a2,12b4 <emit_char+0x14>
        out[pos] = c;
        return pos + 1U;
    }
    return pos;
}
    12b0:	00008067          	ret
        out[pos] = c;
    12b4:	00b78533          	add	a0,a5,a1
    12b8:	00d50023          	sb	a3,0(a0) # f8b00000 <__freertos_irq_stack_top+0xf8af7240>
        return pos + 1U;
    12bc:	00070513          	mv	a0,a4
    12c0:	00008067          	ret

000012c4 <emit_str>:
*       格式化 %s 时如果调用者传了个空指针，正常做法是崩溃；但对一个用于
*       排查问题的日志函数来说，崩溃恰恰是最糟的结果——它会把现场毁掉。
*       打印 (null) 既能让人看出"这里传空了"，又不会中断程序。
******************************************************************************/
static uint32_t emit_str(char *out, uint32_t pos, uint32_t cap, const char *s)
{
    12c4:	ff010113          	addi	sp,sp,-16
    12c8:	00112623          	sw	ra,12(sp)
    12cc:	00812423          	sw	s0,8(sp)
    12d0:	00912223          	sw	s1,4(sp)
    12d4:	01212023          	sw	s2,0(sp)
    12d8:	00050493          	mv	s1,a0
    12dc:	00060913          	mv	s2,a2
    12e0:	00068413          	mv	s0,a3
    if (s == 0) {
    12e4:	02069263          	bnez	a3,1308 <emit_str+0x44>
        s = "(null)";
    12e8:	00004437          	lui	s0,0x4
    12ec:	f8440413          	addi	s0,s0,-124 # 3f84 <_data>
    12f0:	0180006f          	j	1308 <emit_str+0x44>
    }
    while (*s != '\0') {
        pos = emit_char(out, pos, cap, *s);
    12f4:	00090613          	mv	a2,s2
    12f8:	00048513          	mv	a0,s1
    12fc:	fa5ff0ef          	jal	12a0 <emit_char>
    1300:	00050593          	mv	a1,a0
        s++;
    1304:	00140413          	addi	s0,s0,1
    while (*s != '\0') {
    1308:	00044683          	lbu	a3,0(s0)
    130c:	fe0694e3          	bnez	a3,12f4 <emit_str+0x30>
    }
    return pos;
}
    1310:	00058513          	mv	a0,a1
    1314:	00c12083          	lw	ra,12(sp)
    1318:	00812403          	lw	s0,8(sp)
    131c:	00412483          	lw	s1,4(sp)
    1320:	00012903          	lw	s2,0(sp)
    1324:	01010113          	addi	sp,sp,16
    1328:	00008067          	ret

0000132c <emit_uint>:
* @note `n < sizeof(tmp)` 这个额外条件是防御性的：即使将来 tmp 的尺寸被改小、
*       或者 base 被传入了别的值，也不会写越界。
******************************************************************************/
static uint32_t emit_uint(char *out, uint32_t pos, uint32_t cap,
                          uint32_t value, uint32_t base, int upper)
{
    132c:	fe010113          	addi	sp,sp,-32
    1330:	00112e23          	sw	ra,28(sp)
    1334:	00912a23          	sw	s1,20(sp)
    1338:	01212823          	sw	s2,16(sp)
    133c:	00050493          	mv	s1,a0
    1340:	00060913          	mv	s2,a2
    const char *digits = upper ? "0123456789ABCDEF" : "0123456789abcdef";
    1344:	04078463          	beqz	a5,138c <emit_uint+0x60>
    1348:	00004537          	lui	a0,0x4
    134c:	f8c50513          	addi	a0,a0,-116 # 3f8c <_data+0x8>
    char        tmp[11];
    uint32_t    n = 0U;

    /* 0 要单独处理：上面的循环是"取余直到商为 0"，对 0 来说一次都不执行，
     * 结果会什么都不输出。而 "0" 显然应该输出一个 0。*/
    if (value == 0U) {
    1350:	04068463          	beqz	a3,1398 <emit_uint+0x6c>
    1354:	00812c23          	sw	s0,24(sp)
    uint32_t    n = 0U;
    1358:	00000413          	li	s0,0
        return emit_char(out, pos, cap, '0');
    }
    while ((value != 0U) && (n < sizeof(tmp))) {
    135c:	06068a63          	beqz	a3,13d0 <emit_uint+0xa4>
    1360:	00a00793          	li	a5,10
    1364:	0687e663          	bltu	a5,s0,13d0 <emit_uint+0xa4>
        tmp[n] = digits[value % base];  /* 取最低位 */
    1368:	02e6f7b3          	remu	a5,a3,a4
    136c:	00f507b3          	add	a5,a0,a5
    1370:	0007c603          	lbu	a2,0(a5)
    1374:	01040793          	addi	a5,s0,16
    1378:	002787b3          	add	a5,a5,sp
    137c:	fec78a23          	sb	a2,-12(a5)
        value /= base;                  /* 去掉最低位 */
    1380:	02e6d6b3          	divu	a3,a3,a4
        n++;
    1384:	00140413          	addi	s0,s0,1
    1388:	fd5ff06f          	j	135c <emit_uint+0x30>
    const char *digits = upper ? "0123456789ABCDEF" : "0123456789abcdef";
    138c:	00004537          	lui	a0,0x4
    1390:	fa050513          	addi	a0,a0,-96 # 3fa0 <_data+0x1c>
    1394:	fbdff06f          	j	1350 <emit_uint+0x24>
        return emit_char(out, pos, cap, '0');
    1398:	03000693          	li	a3,48
    139c:	00090613          	mv	a2,s2
    13a0:	00048513          	mv	a0,s1
    13a4:	efdff0ef          	jal	12a0 <emit_char>
    13a8:	00050593          	mv	a1,a0
    13ac:	02c0006f          	j	13d8 <emit_uint+0xac>
    }
    /* 倒序输出，得到高位在前的正常顺序。*/
    while (n > 0U) {
        n--;
    13b0:	fff40413          	addi	s0,s0,-1
        pos = emit_char(out, pos, cap, tmp[n]);
    13b4:	01040793          	addi	a5,s0,16
    13b8:	002787b3          	add	a5,a5,sp
    13bc:	ff47c683          	lbu	a3,-12(a5)
    13c0:	00090613          	mv	a2,s2
    13c4:	00048513          	mv	a0,s1
    13c8:	ed9ff0ef          	jal	12a0 <emit_char>
    13cc:	00050593          	mv	a1,a0
    while (n > 0U) {
    13d0:	fe0410e3          	bnez	s0,13b0 <emit_uint+0x84>
    13d4:	01812403          	lw	s0,24(sp)
    }
    return pos;
}
    13d8:	00058513          	mv	a0,a1
    13dc:	01c12083          	lw	ra,28(sp)
    13e0:	01412483          	lw	s1,20(sp)
    13e4:	01012903          	lw	s2,16(sp)
    13e8:	02010113          	addi	sp,sp,32
    13ec:	00008067          	ret

000013f0 <app_vformat>:
*       后面可能还有普通字符或别的格式符要处理，必须继续循环。
*       这一点和 frame.c 里状态机的写法正好相反——那里的每个状态处理完这一
*       字节就该返回了。
******************************************************************************/
static uint32_t app_vformat(char *out, uint32_t cap, const char *format, va_list ap)
{
    13f0:	fd010113          	addi	sp,sp,-48
    13f4:	02112623          	sw	ra,44(sp)
    13f8:	00d12623          	sw	a3,12(sp)
    uint32_t pos = 0U;

    if ((out == 0) || (cap == 0U) || (format == 0)) {
    13fc:	2a050a63          	beqz	a0,16b0 <app_vformat+0x2c0>
    1400:	02812423          	sw	s0,40(sp)
    1404:	02912223          	sw	s1,36(sp)
    1408:	03212023          	sw	s2,32(sp)
    140c:	00050913          	mv	s2,a0
    1410:	00058493          	mv	s1,a1
    1414:	00060413          	mv	s0,a2
    1418:	2a058063          	beqz	a1,16b8 <app_vformat+0x2c8>
    141c:	2a060663          	beqz	a2,16c8 <app_vformat+0x2d8>
    1420:	01312e23          	sw	s3,28(sp)
    uint32_t pos = 0U;
    1424:	00000593          	li	a1,0
    1428:	0640006f          	j	148c <app_vformat+0x9c>
    }

    while (*format != '\0') {
        /* 普通字符直接输出。*/
        if (*format != '%') {
            pos = emit_char(out, pos, cap, *format);
    142c:	00048613          	mv	a2,s1
    1430:	00090513          	mv	a0,s2
    1434:	e6dff0ef          	jal	12a0 <emit_char>
    1438:	00050593          	mv	a1,a0
            format++;
    143c:	00140413          	addi	s0,s0,1
            continue;
    1440:	04c0006f          	j	148c <app_vformat+0x9c>
        }

        /* 遇到 '%'，看下一个字符决定怎么处理。
         * format++ 之后 *format 就是格式符本身。*/
        format++;
        switch (*format) {
    1444:	1e078663          	beqz	a5,1630 <app_vformat+0x240>
    1448:	02500713          	li	a4,37
    144c:	20e79063          	bne	a5,a4,164c <app_vformat+0x25c>
            pos = emit_str(out, pos, cap, "0x");
            pos = emit_uint(out, pos, cap, (uint32_t)va_arg(ap, void *), 16U, 0);
            break;
        case '%':
            /* "%%" 表示输出一个真正的百分号。*/
            pos = emit_char(out, pos, cap, '%');
    1450:	02500693          	li	a3,37
    1454:	00048613          	mv	a2,s1
    1458:	00090513          	mv	a0,s2
    145c:	e45ff0ef          	jal	12a0 <emit_char>
    1460:	00050593          	mv	a1,a0
            break;
    1464:	0240006f          	j	1488 <app_vformat+0x98>
            pos = emit_str(out, pos, cap, va_arg(ap, const char *));
    1468:	00c12783          	lw	a5,12(sp)
    146c:	00478713          	addi	a4,a5,4
    1470:	00e12623          	sw	a4,12(sp)
    1474:	0007a683          	lw	a3,0(a5)
    1478:	00048613          	mv	a2,s1
    147c:	00090513          	mv	a0,s2
    1480:	e45ff0ef          	jal	12c4 <emit_str>
    1484:	00050593          	mv	a1,a0
             * 在日志里一眼就能看见。如果静默吞掉，排查时会以为参数丢了。*/
            pos = emit_char(out, pos, cap, '%');
            pos = emit_char(out, pos, cap, *format);
            break;
        }
        format++;
    1488:	00198413          	addi	s0,s3,1
    while (*format != '\0') {
    148c:	00044683          	lbu	a3,0(s0)
    1490:	1e068463          	beqz	a3,1678 <app_vformat+0x288>
        if (*format != '%') {
    1494:	02500793          	li	a5,37
    1498:	f8f69ae3          	bne	a3,a5,142c <app_vformat+0x3c>
        format++;
    149c:	00140993          	addi	s3,s0,1
        switch (*format) {
    14a0:	00144783          	lbu	a5,1(s0)
    14a4:	07800713          	li	a4,120
    14a8:	1af76263          	bltu	a4,a5,164c <app_vformat+0x25c>
    14ac:	05800713          	li	a4,88
    14b0:	f8e7eae3          	bltu	a5,a4,1444 <app_vformat+0x54>
    14b4:	fa878793          	addi	a5,a5,-88
    14b8:	0ff7f693          	zext.b	a3,a5
    14bc:	02000713          	li	a4,32
    14c0:	18d76663          	bltu	a4,a3,164c <app_vformat+0x25c>
    14c4:	00269793          	slli	a5,a3,0x2
    14c8:	00005737          	lui	a4,0x5
    14cc:	8b870713          	addi	a4,a4,-1864 # 48b8 <_data+0x934>
    14d0:	00e787b3          	add	a5,a5,a4
    14d4:	0007a783          	lw	a5,0(a5)
    14d8:	00078067          	jr	a5
            pos = emit_char(out, pos, cap, (char)va_arg(ap, int));
    14dc:	00c12783          	lw	a5,12(sp)
    14e0:	00478713          	addi	a4,a5,4
    14e4:	00e12623          	sw	a4,12(sp)
    14e8:	0007c683          	lbu	a3,0(a5)
    14ec:	00048613          	mv	a2,s1
    14f0:	00090513          	mv	a0,s2
    14f4:	dadff0ef          	jal	12a0 <emit_char>
    14f8:	00050593          	mv	a1,a0
            break;
    14fc:	f8dff06f          	j	1488 <app_vformat+0x98>
            int32_t v = va_arg(ap, int32_t);
    1500:	00c12783          	lw	a5,12(sp)
    1504:	00478713          	addi	a4,a5,4
    1508:	00e12623          	sw	a4,12(sp)
    150c:	0007a403          	lw	s0,0(a5)
            if (v < 0) {
    1510:	02044263          	bltz	s0,1534 <app_vformat+0x144>
                pos = emit_uint(out, pos, cap, (uint32_t)v, 10U, 0);
    1514:	00000793          	li	a5,0
    1518:	00a00713          	li	a4,10
    151c:	00040693          	mv	a3,s0
    1520:	00048613          	mv	a2,s1
    1524:	00090513          	mv	a0,s2
    1528:	e05ff0ef          	jal	132c <emit_uint>
    152c:	00050593          	mv	a1,a0
    1530:	f59ff06f          	j	1488 <app_vformat+0x98>
                pos = emit_char(out, pos, cap, '-');
    1534:	02d00693          	li	a3,45
    1538:	00048613          	mv	a2,s1
    153c:	00090513          	mv	a0,s2
    1540:	d61ff0ef          	jal	12a0 <emit_char>
    1544:	00050593          	mv	a1,a0
                pos = emit_uint(out, pos, cap, (uint32_t)0 - (uint32_t)v, 10U, 0);
    1548:	00000793          	li	a5,0
    154c:	00a00713          	li	a4,10
    1550:	408006b3          	neg	a3,s0
    1554:	00048613          	mv	a2,s1
    1558:	00090513          	mv	a0,s2
    155c:	dd1ff0ef          	jal	132c <emit_uint>
    1560:	00050593          	mv	a1,a0
    1564:	f25ff06f          	j	1488 <app_vformat+0x98>
            pos = emit_uint(out, pos, cap, va_arg(ap, uint32_t), 10U, 0);
    1568:	00c12683          	lw	a3,12(sp)
    156c:	00468793          	addi	a5,a3,4
    1570:	00f12623          	sw	a5,12(sp)
    1574:	00000793          	li	a5,0
    1578:	00a00713          	li	a4,10
    157c:	0006a683          	lw	a3,0(a3)
    1580:	00048613          	mv	a2,s1
    1584:	00090513          	mv	a0,s2
    1588:	da5ff0ef          	jal	132c <emit_uint>
    158c:	00050593          	mv	a1,a0
            break;
    1590:	ef9ff06f          	j	1488 <app_vformat+0x98>
            pos = emit_uint(out, pos, cap, va_arg(ap, uint32_t), 16U, 0);
    1594:	00c12683          	lw	a3,12(sp)
    1598:	00468793          	addi	a5,a3,4
    159c:	00f12623          	sw	a5,12(sp)
    15a0:	00000793          	li	a5,0
    15a4:	01000713          	li	a4,16
    15a8:	0006a683          	lw	a3,0(a3)
    15ac:	00048613          	mv	a2,s1
    15b0:	00090513          	mv	a0,s2
    15b4:	d79ff0ef          	jal	132c <emit_uint>
    15b8:	00050593          	mv	a1,a0
            break;
    15bc:	ecdff06f          	j	1488 <app_vformat+0x98>
            pos = emit_uint(out, pos, cap, va_arg(ap, uint32_t), 16U, 1);
    15c0:	00c12683          	lw	a3,12(sp)
    15c4:	00468793          	addi	a5,a3,4
    15c8:	00f12623          	sw	a5,12(sp)
    15cc:	00100793          	li	a5,1
    15d0:	01000713          	li	a4,16
    15d4:	0006a683          	lw	a3,0(a3)
    15d8:	00048613          	mv	a2,s1
    15dc:	00090513          	mv	a0,s2
    15e0:	d4dff0ef          	jal	132c <emit_uint>
    15e4:	00050593          	mv	a1,a0
            break;
    15e8:	ea1ff06f          	j	1488 <app_vformat+0x98>
            pos = emit_str(out, pos, cap, "0x");
    15ec:	000046b7          	lui	a3,0x4
    15f0:	fb468693          	addi	a3,a3,-76 # 3fb4 <_data+0x30>
    15f4:	00048613          	mv	a2,s1
    15f8:	00090513          	mv	a0,s2
    15fc:	cc9ff0ef          	jal	12c4 <emit_str>
    1600:	00050593          	mv	a1,a0
            pos = emit_uint(out, pos, cap, (uint32_t)va_arg(ap, void *), 16U, 0);
    1604:	00c12683          	lw	a3,12(sp)
    1608:	00468793          	addi	a5,a3,4
    160c:	00f12623          	sw	a5,12(sp)
    1610:	00000793          	li	a5,0
    1614:	01000713          	li	a4,16
    1618:	0006a683          	lw	a3,0(a3)
    161c:	00048613          	mv	a2,s1
    1620:	00090513          	mv	a0,s2
    1624:	d09ff0ef          	jal	132c <emit_uint>
    1628:	00050593          	mv	a1,a0
            break;
    162c:	e5dff06f          	j	1488 <app_vformat+0x98>
            pos = emit_char(out, pos, cap, '%');
    1630:	02500693          	li	a3,37
    1634:	00048613          	mv	a2,s1
    1638:	00090513          	mv	a0,s2
    163c:	c65ff0ef          	jal	12a0 <emit_char>
    1640:	00050593          	mv	a1,a0
            format--;
    1644:	00040993          	mv	s3,s0
            break;
    1648:	e41ff06f          	j	1488 <app_vformat+0x98>
            pos = emit_char(out, pos, cap, '%');
    164c:	02500693          	li	a3,37
    1650:	00048613          	mv	a2,s1
    1654:	00090513          	mv	a0,s2
    1658:	c49ff0ef          	jal	12a0 <emit_char>
    165c:	00050593          	mv	a1,a0
            pos = emit_char(out, pos, cap, *format);
    1660:	00144683          	lbu	a3,1(s0)
    1664:	00048613          	mv	a2,s1
    1668:	00090513          	mv	a0,s2
    166c:	c35ff0ef          	jal	12a0 <emit_char>
    1670:	00050593          	mv	a1,a0
            break;
    1674:	e15ff06f          	j	1488 <app_vformat+0x98>
    }

    /* 补上字符串结束符。
     * 这里用三元表达式做一次边界保护：如果写满到 cap，就写到最后一个字节，
     * 保证 out 始终是一个合法的、有结束符的字符串。*/
    out[(pos < cap) ? pos : (cap - 1U)] = '\0';
    1678:	0295e863          	bltu	a1,s1,16a8 <app_vformat+0x2b8>
    167c:	fff48493          	addi	s1,s1,-1
    1680:	00990933          	add	s2,s2,s1
    1684:	00090023          	sb	zero,0(s2)
    return pos;
    1688:	02812403          	lw	s0,40(sp)
    168c:	02412483          	lw	s1,36(sp)
    1690:	02012903          	lw	s2,32(sp)
    1694:	01c12983          	lw	s3,28(sp)
}
    1698:	00058513          	mv	a0,a1
    169c:	02c12083          	lw	ra,44(sp)
    16a0:	03010113          	addi	sp,sp,48
    16a4:	00008067          	ret
    out[(pos < cap) ? pos : (cap - 1U)] = '\0';
    16a8:	00058493          	mv	s1,a1
    16ac:	fd5ff06f          	j	1680 <app_vformat+0x290>
        return 0U;
    16b0:	00000593          	li	a1,0
    16b4:	fe5ff06f          	j	1698 <app_vformat+0x2a8>
    16b8:	02812403          	lw	s0,40(sp)
    16bc:	02412483          	lw	s1,36(sp)
    16c0:	02012903          	lw	s2,32(sp)
    16c4:	fd5ff06f          	j	1698 <app_vformat+0x2a8>
    16c8:	00000593          	li	a1,0
    16cc:	02812403          	lw	s0,40(sp)
    16d0:	02412483          	lw	s1,36(sp)
    16d4:	02012903          	lw	s2,32(sp)
    16d8:	fc1ff06f          	j	1698 <app_vformat+0x2a8>

000016dc <app_log_init>:
/******************************************************************************
* @brief 清空日志环并清零计数。
******************************************************************************/
void app_log_init(void)
{
    s_head = 0U;
    16dc:	8201a623          	sw	zero,-2004(gp) # 57d4 <s_head>
    s_tail = 0U;
    16e0:	8201a423          	sw	zero,-2008(gp) # 57d0 <s_tail>
    s_dropped = 0U;
    16e4:	8201a223          	sw	zero,-2012(gp) # 57cc <s_dropped>
    s_once_mask = 0U;      /* 清掉"已报过"的位，让 app_log_once 重新从首次开始 */
    16e8:	8201a023          	sw	zero,-2016(gp) # 57c8 <s_once_mask>
}
    16ec:	00008067          	ret

000016f0 <app_log_pending>:
*
* @note 与 proto_uart.c 里同样的环形缓冲技巧：无符号减法 + 掩码取模。
******************************************************************************/
uint32_t app_log_pending(void)
{
    return (s_head - s_tail) & (APP_LOG_RING_SIZE - 1U);
    16f0:	82c1a503          	lw	a0,-2004(gp) # 57d4 <s_head>
    16f4:	8281a783          	lw	a5,-2008(gp) # 57d0 <s_tail>
    16f8:	40f50533          	sub	a0,a0,a5
}
    16fc:	3ff57513          	andi	a0,a0,1023
    1700:	00008067          	ret

00001704 <app_log_v>:
    char     msg[APP_LOG_MSG_MAX];
    uint32_t used;
    uint32_t i;
    uint32_t space;

    if (format == 0) {
    1704:	0c050663          	beqz	a0,17d0 <app_log_v+0xcc>
{
    1708:	f5010113          	addi	sp,sp,-176
    170c:	0a112623          	sw	ra,172(sp)
    1710:	0a812423          	sw	s0,168(sp)
    1714:	00050613          	mv	a2,a0
    1718:	00058693          	mv	a3,a1
        return;
    }

    used = app_vformat(msg, sizeof(msg), format, ap);
    171c:	0a000593          	li	a1,160
    1720:	00010513          	mv	a0,sp
    1724:	ccdff0ef          	jal	13f0 <app_vformat>
    1728:	00050413          	mv	s0,a0

    /* 格式化结果为空就不必进队了。*/
    if (used == 0U) {
    172c:	00051a63          	bnez	a0,1740 <app_log_v+0x3c>
     *
     * 这里补的是**逻辑换行**（只有 '\n' 一个字节）。真正上串口需要的
     * "\r\n" 两个字节由 app_log_flush() 在发送前展开，理由见那个函数的说明。*/
    s_ring[s_head] = '\n';
    s_head = (s_head + 1U) & (APP_LOG_RING_SIZE - 1U);
}
    1730:	0ac12083          	lw	ra,172(sp)
    1734:	0a812403          	lw	s0,168(sp)
    1738:	0b010113          	addi	sp,sp,176
    173c:	00008067          	ret
    space = (APP_LOG_RING_SIZE - 1U) - app_log_pending();
    1740:	fb1ff0ef          	jal	16f0 <app_log_pending>
    1744:	3ff00793          	li	a5,1023
    1748:	40a787b3          	sub	a5,a5,a0
    if ((used + 1U) > space) {
    174c:	00140713          	addi	a4,s0,1
    1750:	00e7e663          	bltu	a5,a4,175c <app_log_v+0x58>
    for (i = 0U; i < used; i++) {
    1754:	00000713          	li	a4,0
    1758:	0480006f          	j	17a0 <app_log_v+0x9c>
        s_dropped++;           /* 放不下整条，丢掉并计数 */
    175c:	8241a783          	lw	a5,-2012(gp) # 57cc <s_dropped>
    1760:	00178793          	addi	a5,a5,1
    1764:	82f1a223          	sw	a5,-2012(gp) # 57cc <s_dropped>
        return;
    1768:	fc9ff06f          	j	1730 <app_log_v+0x2c>
        s_ring[s_head] = msg[i];
    176c:	82c1a583          	lw	a1,-2004(gp) # 57d4 <s_head>
    1770:	0a070793          	addi	a5,a4,160
    1774:	002787b3          	add	a5,a5,sp
    1778:	f607c603          	lbu	a2,-160(a5)
    177c:	000067b7          	lui	a5,0x6
    1780:	86478793          	addi	a5,a5,-1948 # 5864 <s_ring>
    1784:	00b787b3          	add	a5,a5,a1
    1788:	00c78023          	sb	a2,0(a5)
        s_head = (s_head + 1U) & (APP_LOG_RING_SIZE - 1U);
    178c:	82c1a783          	lw	a5,-2004(gp) # 57d4 <s_head>
    1790:	00178793          	addi	a5,a5,1
    1794:	3ff7f793          	andi	a5,a5,1023
    1798:	82f1a623          	sw	a5,-2004(gp) # 57d4 <s_head>
    for (i = 0U; i < used; i++) {
    179c:	00170713          	addi	a4,a4,1
    17a0:	fc8766e3          	bltu	a4,s0,176c <app_log_v+0x68>
    s_ring[s_head] = '\n';
    17a4:	82c1a683          	lw	a3,-2004(gp) # 57d4 <s_head>
    17a8:	000067b7          	lui	a5,0x6
    17ac:	86478793          	addi	a5,a5,-1948 # 5864 <s_ring>
    17b0:	00d787b3          	add	a5,a5,a3
    17b4:	00a00693          	li	a3,10
    17b8:	00d78023          	sb	a3,0(a5)
    s_head = (s_head + 1U) & (APP_LOG_RING_SIZE - 1U);
    17bc:	82c1a783          	lw	a5,-2004(gp) # 57d4 <s_head>
    17c0:	00178793          	addi	a5,a5,1
    17c4:	3ff7f793          	andi	a5,a5,1023
    17c8:	82f1a623          	sw	a5,-2004(gp) # 57d4 <s_head>
    17cc:	f65ff06f          	j	1730 <app_log_v+0x2c>
    17d0:	00008067          	ret

000017d4 <app_log_dropped>:
}
    17d4:	8241a503          	lw	a0,-2012(gp) # 57cc <s_dropped>
    17d8:	00008067          	ret

000017dc <app_log>:
* @brief 格式化一条消息并排进队列。
*
* @param format 格式串，后面跟可变参数。
******************************************************************************/
void app_log(const char *format, ...)
{
    17dc:	fc010113          	addi	sp,sp,-64
    17e0:	00112e23          	sw	ra,28(sp)
    17e4:	02b12223          	sw	a1,36(sp)
    17e8:	02c12423          	sw	a2,40(sp)
    17ec:	02d12623          	sw	a3,44(sp)
    17f0:	02e12823          	sw	a4,48(sp)
    17f4:	02f12a23          	sw	a5,52(sp)
    17f8:	03012c23          	sw	a6,56(sp)
    17fc:	03112e23          	sw	a7,60(sp)
    va_list ap;

    va_start(ap, format);
    1800:	02410593          	addi	a1,sp,36
    1804:	00b12623          	sw	a1,12(sp)
    app_log_v(format, ap);
    1808:	efdff0ef          	jal	1704 <app_log_v>
    va_end(ap);
}
    180c:	01c12083          	lw	ra,28(sp)
    1810:	04010113          	addi	sp,sp,64
    1814:	00008067          	ret

00001818 <app_log_once>:
* @note bitno MUST 小于 32。C 语言里 `1U << 32` 是**未定义行为**（不是简单
*       地得到 0），可能把其它位搅乱。这里显式挡住，因为 bitno 常直接来自枚举，
*       将来给枚举加值时就可能越界，而那种 bug 极难查。
******************************************************************************/
void app_log_once(uint32_t bitno, const char *format, ...)
{
    1818:	fc010113          	addi	sp,sp,-64
    181c:	00112e23          	sw	ra,28(sp)
    1820:	00050313          	mv	t1,a0
    1824:	02c12423          	sw	a2,40(sp)
    1828:	02d12623          	sw	a3,44(sp)
    182c:	02e12823          	sw	a4,48(sp)
    1830:	02f12a23          	sw	a5,52(sp)
    1834:	03012c23          	sw	a6,56(sp)
    1838:	03112e23          	sw	a7,60(sp)
    va_list ap;

    if (bitno >= 32U) {
    183c:	01f00793          	li	a5,31
    1840:	00a7ee63          	bltu	a5,a0,185c <app_log_once+0x44>
    1844:	00058513          	mv	a0,a1
        return;                    /* 越界：宁可不输出，也不能移位越界 */
    }
    if ((s_once_mask & (1U << bitno)) != 0U) {
    1848:	00100793          	li	a5,1
    184c:	006797b3          	sll	a5,a5,t1
    1850:	8201a703          	lw	a4,-2016(gp) # 57c8 <s_once_mask>
    1854:	00e7f6b3          	and	a3,a5,a4
    1858:	00068863          	beqz	a3,1868 <app_log_once+0x50>
    s_once_mask |= (1U << bitno);

    va_start(ap, format);
    app_log_v(format, ap);
    va_end(ap);
}
    185c:	01c12083          	lw	ra,28(sp)
    1860:	04010113          	addi	sp,sp,64
    1864:	00008067          	ret
    s_once_mask |= (1U << bitno);
    1868:	00e7e7b3          	or	a5,a5,a4
    186c:	82f1a023          	sw	a5,-2016(gp) # 57c8 <s_once_mask>
    va_start(ap, format);
    1870:	02810593          	addi	a1,sp,40
    1874:	00b12623          	sw	a1,12(sp)
    app_log_v(format, ap);
    1878:	e8dff0ef          	jal	1704 <app_log_v>
    va_end(ap);
    187c:	fe1ff06f          	j	185c <app_log_once+0x44>

00001880 <app_log_flush>:
* @note 末尾多留一个字节给 '\0'（s_emit 定义为 CHUNK+1 大小），
*       s_emit[out] = '\0' 就是补结束符——这一句不能省，否则打印函数会越过
*       有效内容继续往后读。
******************************************************************************/
uint32_t app_log_flush(void)
{
    1880:	ff010113          	addi	sp,sp,-16
    1884:	00112623          	sw	ra,12(sp)
    /* pending 在循环开始前取一次就够了：本函数是环的唯一消费者，
     * 循环里 s_tail 只会往前走，所以 pending 就是"这次最多能取多少"。*/
    uint32_t pending = app_log_pending();
    1888:	e69ff0ef          	jal	16f0 <app_log_pending>
    188c:	00050613          	mv	a2,a0
    uint32_t consumed = 0U;     /* 已从环里取走的源字节数 */
    uint32_t out = 0U;          /* 已写入 s_emit 的输出字节数 */
    char     c;

    if (pending == 0U) {
    1890:	0a050063          	beqz	a0,1930 <app_log_flush+0xb0>
    uint32_t out = 0U;          /* 已写入 s_emit 的输出字节数 */
    1894:	00000513          	li	a0,0
    uint32_t consumed = 0U;     /* 已从环里取走的源字节数 */
    1898:	00000713          	li	a4,0
    189c:	0480006f          	j	18e4 <app_log_flush+0x64>
             * 后半条日志会覆盖在当前行上；只发 '\n' 又会阶梯错位。
             * 要么整对发出，要么一个都不发。
             *
             * 注：APP_LOG_CHUNK 为 32，所以 out==0 时这个条件必然不成立，
             * 不会出现"一个字节都取不出来"的死循环。*/
            if ((out + 2U) > APP_LOG_CHUNK) {
    18a0:	00250593          	addi	a1,a0,2
    18a4:	02000793          	li	a5,32
    18a8:	06b7ec63          	bltu	a5,a1,1920 <app_log_flush+0xa0>
                break;
            }
            s_emit[out] = '\r';     /* 先回车 */
    18ac:	89818693          	addi	a3,gp,-1896 # 5840 <s_emit>
    18b0:	00a687b3          	add	a5,a3,a0
    18b4:	00d00813          	li	a6,13
    18b8:	01078023          	sb	a6,0(a5)
            out++;
    18bc:	00150793          	addi	a5,a0,1
            s_emit[out] = '\n';     /* 再换行 */
    18c0:	00f686b3          	add	a3,a3,a5
    18c4:	00a00793          	li	a5,10
    18c8:	00f68023          	sb	a5,0(a3)
            out++;
    18cc:	00058513          	mv	a0,a1
            s_emit[out] = c;
            out++;
        }

        /* 到这里这个源字节才算真正被消费掉，推进读指针。*/
        s_tail = (s_tail + 1U) & (APP_LOG_RING_SIZE - 1U);
    18d0:	8281a783          	lw	a5,-2008(gp) # 57d0 <s_tail>
    18d4:	00178793          	addi	a5,a5,1
    18d8:	3ff7f793          	andi	a5,a5,1023
    18dc:	82f1a423          	sw	a5,-2008(gp) # 57d0 <s_tail>
        consumed++;
    18e0:	00170713          	addi	a4,a4,1
    while ((consumed < pending) && (out < APP_LOG_CHUNK)) {
    18e4:	02c77e63          	bgeu	a4,a2,1920 <app_log_flush+0xa0>
    18e8:	01f00793          	li	a5,31
    18ec:	02a7ea63          	bltu	a5,a0,1920 <app_log_flush+0xa0>
        c = s_ring[s_tail];
    18f0:	8281a683          	lw	a3,-2008(gp) # 57d0 <s_tail>
    18f4:	000067b7          	lui	a5,0x6
    18f8:	86478793          	addi	a5,a5,-1948 # 5864 <s_ring>
    18fc:	00d787b3          	add	a5,a5,a3
    1900:	0007c683          	lbu	a3,0(a5)
        if (c == '\n') {
    1904:	00a00793          	li	a5,10
    1908:	f8f68ce3          	beq	a3,a5,18a0 <app_log_flush+0x20>
            s_emit[out] = c;
    190c:	89818793          	addi	a5,gp,-1896 # 5840 <s_emit>
    1910:	00a787b3          	add	a5,a5,a0
    1914:	00d78023          	sb	a3,0(a5)
            out++;
    1918:	00150513          	addi	a0,a0,1
    191c:	fb5ff06f          	j	18d0 <app_log_flush+0x50>
    }

    /* 一个字节都没能发出（理论上只在 APP_LOG_CHUNK < 2 时才会发生），
     * 那就不要调打印函数，避免发一个空字符串白白停顿一次。*/
    if (out == 0U) {
    1920:	00050863          	beqz	a0,1930 <app_log_flush+0xb0>
        return 0U;
    }

    s_emit[out] = '\0';
    1924:	89818793          	addi	a5,gp,-1896 # 5840 <s_emit>
    1928:	00a787b3          	add	a5,a5,a0
    192c:	00078023          	sb	zero,0(a5)
     * 所以它被放在主循环里、在服务完 uart1 之后。*/
    bsp_printf("%s", s_emit);
#endif /* APP_LOG_OFF */

    return out;
}
    1930:	00c12083          	lw	ra,12(sp)
    1934:	01010113          	addi	sp,sp,16
    1938:	00008067          	ret

0000193c <uart_applyConfig>:
*          value using data length, parity, and stop bit settings from the configuration
*          structure, and writes this value to the UART frame configuration register.
*
******************************************************************************/
    static void uart_applyConfig(u32 reg, Uart_Config *config){
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
    193c:	00c5a783          	lw	a5,12(a1)
    static inline u32 read_u32(u32 address){
        return *((volatile u32*) address);
    }
    
    static inline void write_u32(u32 data, u32 address){
        *((volatile u32*) address) = data;
    1940:	00f52423          	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
    1944:	0005a783          	lw	a5,0(a1)
    1948:	fff78793          	addi	a5,a5,-1
    194c:	0045a703          	lw	a4,4(a1)
    1950:	00871713          	slli	a4,a4,0x8
    1954:	00e7e7b3          	or	a5,a5,a4
    1958:	0085a703          	lw	a4,8(a1)
    195c:	01071713          	slli	a4,a4,0x10
    1960:	00e7e7b3          	or	a5,a5,a4
    1964:	00f52623          	sw	a5,12(a0)
    }
    1968:	00008067          	ret

0000196c <clint_getTime>:
*          to guard against rollover. It checks if the high part remains unchanged
*          during the read operation to ensure consistency. The high and low parts
*          are then combined to form the 64-bit current time value.
*
******************************************************************************/
    static u64 clint_getTime(u32 p){
    196c:	00050693          	mv	a3,a0
    readReg_u32 (clint_getTimeHigh, CLINT_TIME_ADDR+4)
    1970:	0000c7b7          	lui	a5,0xc
    1974:	ffc78793          	addi	a5,a5,-4 # bffc <__freertos_irq_stack_top+0x323c>
    1978:	00f687b3          	add	a5,a3,a5
        return *((volatile u32*) address);
    197c:	0007a583          	lw	a1,0(a5)
    readReg_u32 (clint_getTimeLow , CLINT_TIME_ADDR)
    1980:	0000c737          	lui	a4,0xc
    1984:	ff870713          	addi	a4,a4,-8 # bff8 <__freertos_irq_stack_top+0x3238>
    1988:	00e68733          	add	a4,a3,a4
    198c:	00072503          	lw	a0,0(a4)
    1990:	0007a783          	lw	a5,0(a5)
    
        /* Likewise, must guard against rollover when reading */
        do {
            hi = clint_getTimeHigh(p);
            lo = clint_getTimeLow(p);
        } while (clint_getTimeHigh(p) != hi);
    1994:	fcb79ee3          	bne	a5,a1,1970 <clint_getTime+0x4>
    
        return (((u64)hi) << 32) | lo;
    }
    1998:	00008067          	ret

0000199c <bsp_init>:
    *   1. UART baudrate
    *   2. 
    */
////////////////////////////////////////////////////////////////////////////////
    static void bsp_init()
    {
    199c:	fe010113          	addi	sp,sp,-32
    19a0:	00112e23          	sw	ra,28(sp)
        Uart_Config uartConfig;
        uartConfig.dataLength   = BITS_8;
    19a4:	00800793          	li	a5,8
    19a8:	00f12023          	sw	a5,0(sp)
        uartConfig.parity       = NONE;
    19ac:	00012223          	sw	zero,4(sp)
        uartConfig.stop         = ONE;
    19b0:	00012423          	sw	zero,8(sp)
        uartConfig.clockDivider = BSP_CLINT_HZ/(BSP_UART_BAUDRATE*BSP_UART_DATA_LEN)-1;
    19b4:	03500793          	li	a5,53
    19b8:	00f12623          	sw	a5,12(sp)
        uart_applyConfig(BSP_UART_TERMINAL, &uartConfig);    
    19bc:	00010593          	mv	a1,sp
    19c0:	f8001537          	lui	a0,0xf8001
    19c4:	f79ff0ef          	jal	193c <uart_applyConfig>
    }
    19c8:	01c12083          	lw	ra,28(sp)
    19cc:	02010113          	addi	sp,sp,32
    19d0:	00008067          	ret

000019d4 <plic_claim>:
*          value from the calculated address, effectively claiming an interrupt
*          for the specified target in the PLIC.
*
******************************************************************************/
    static u32 plic_claim(u32 plic, u32 target){
        return read_u32(plic + PLIC_CLAIM_BASE + target*PLIC_CONTEXT_PER_HART);
    19d4:	00c59593          	slli	a1,a1,0xc
    19d8:	00a585b3          	add	a1,a1,a0
    19dc:	002007b7          	lui	a5,0x200
    19e0:	00478793          	addi	a5,a5,4 # 200004 <__freertos_irq_stack_top+0x1f7244>
    19e4:	00f585b3          	add	a1,a1,a5
    19e8:	0005a503          	lw	a0,0(a1)
    }
    19ec:	00008067          	ret

000019f0 <plic_release>:
*          to the calculated address, effectively releasing the claimed interrupt
*          for the specified target in the PLIC.
*
******************************************************************************/
    static void plic_release(u32 plic, u32 target, u32 gateway){
        write_u32(gateway,plic + PLIC_CLAIM_BASE + target*PLIC_CONTEXT_PER_HART);
    19f0:	00c59593          	slli	a1,a1,0xc
    19f4:	00a585b3          	add	a1,a1,a0
    19f8:	002007b7          	lui	a5,0x200
    19fc:	00478793          	addi	a5,a5,4 # 200004 <__freertos_irq_stack_top+0x1f7244>
    1a00:	00f585b3          	add	a1,a1,a5
        *((volatile u32*) address) = data;
    1a04:	00c5a023          	sw	a2,0(a1)
    }
    1a08:	00008067          	ret

00001a0c <isr_init>:
    csr_write(mtvec, trap_entry);        /* 异常/中断入口，定义在 ../common/trap.S */
    1a0c:	000047b7          	lui	a5,0x4
    1a10:	ef478793          	addi	a5,a5,-268 # 3ef4 <trap_entry>
    1a14:	30579073          	csrw	mtvec,a5
    csr_set(mie, MIE_MEIE);
    1a18:	000017b7          	lui	a5,0x1
    1a1c:	80078793          	addi	a5,a5,-2048 # 800 <CUSTOM2+0x7a5>
    1a20:	3047a073          	csrs	mie,a5
    csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);
    1a24:	300027f3          	csrr	a5,mstatus
    1a28:	00002737          	lui	a4,0x2
    1a2c:	80870713          	addi	a4,a4,-2040 # 1808 <app_log+0x2c>
    1a30:	00e7e7b3          	or	a5,a5,a4
    1a34:	30079073          	csrw	mstatus,a5
}
    1a38:	00008067          	ret

00001a3c <hex8>:
    for (i = 0; i < 8; i++) {
    1a3c:	00000693          	li	a3,0
    1a40:	0340006f          	j	1a74 <hex8+0x38>
        dst[i] = digits[(v >> ((7 - i) * 4)) & 0xFU];
    1a44:	00700793          	li	a5,7
    1a48:	40d787b3          	sub	a5,a5,a3
    1a4c:	00279793          	slli	a5,a5,0x2
    1a50:	00f5d7b3          	srl	a5,a1,a5
    1a54:	00f7f793          	andi	a5,a5,15
    1a58:	00d50633          	add	a2,a0,a3
    1a5c:	00005737          	lui	a4,0x5
    1a60:	97070713          	addi	a4,a4,-1680 # 4970 <digits.1>
    1a64:	00f707b3          	add	a5,a4,a5
    1a68:	0007c783          	lbu	a5,0(a5)
    1a6c:	00f60023          	sb	a5,0(a2) # b40000 <__freertos_irq_stack_top+0xb37240>
    for (i = 0; i < 8; i++) {
    1a70:	00168693          	addi	a3,a3,1
    1a74:	00700793          	li	a5,7
    1a78:	fcd7d6e3          	bge	a5,a3,1a44 <hex8+0x8>
    dst[8] = '\0';
    1a7c:	00050423          	sb	zero,8(a0) # f8001008 <__freertos_irq_stack_top+0xf7ff8248>
}
    1a80:	00008067          	ret

00001a84 <diag_drain>:
{
    1a84:	ff010113          	addi	sp,sp,-16
    1a88:	00112623          	sw	ra,12(sp)
    while (app_log_pending() != 0U) {
    1a8c:	0080006f          	j	1a94 <diag_drain+0x10>
        (void)app_log_flush();
    1a90:	df1ff0ef          	jal	1880 <app_log_flush>
    while (app_log_pending() != 0U) {
    1a94:	c5dff0ef          	jal	16f0 <app_log_pending>
    1a98:	fe051ce3          	bnez	a0,1a90 <diag_drain+0xc>
}
    1a9c:	00c12083          	lw	ra,12(sp)
    1aa0:	01010113          	addi	sp,sp,16
    1aa4:	00008067          	ret

00001aa8 <diag_dump_regs>:
{
    1aa8:	fb010113          	addi	sp,sp,-80
    1aac:	04112623          	sw	ra,76(sp)
    1ab0:	04812423          	sw	s0,72(sp)
    canvas_read_regs(&r);
    1ab4:	02010513          	addi	a0,sp,32
    1ab8:	6a8010ef          	jal	3160 <canvas_read_regs>
    hex8(b1, r.command);
    1abc:	02012583          	lw	a1,32(sp)
    1ac0:	01410513          	addi	a0,sp,20
    1ac4:	f79ff0ef          	jal	1a3c <hex8>
    app_log("osd regs: COMMAND(readback)=%s staged_g_en=%u", b1, r.command & 1U);
    1ac8:	02012603          	lw	a2,32(sp)
    1acc:	00167613          	andi	a2,a2,1
    1ad0:	01410593          	addi	a1,sp,20
    1ad4:	00004537          	lui	a0,0x4
    1ad8:	fb850513          	addi	a0,a0,-72 # 3fb8 <_data+0x34>
    1adc:	d01ff0ef          	jal	17dc <app_log>
    diag_drain();
    1ae0:	fa5ff0ef          	jal	1a84 <diag_drain>
    hex8(b1, r.status);
    1ae4:	02412583          	lw	a1,36(sp)
    1ae8:	01410513          	addi	a0,sp,20
    1aec:	f51ff0ef          	jal	1a3c <hex8>
            b1, (r.status >> 16) & 0xFFFFU, (r.status >> 2) & 1U, r.status & 1U);
    1af0:	02412603          	lw	a2,36(sp)
    1af4:	00265693          	srli	a3,a2,0x2
    app_log("osd regs: STATUS=%s commit_count=%u pending=%u applied_g_en=%u",
    1af8:	00167713          	andi	a4,a2,1
    1afc:	0016f693          	andi	a3,a3,1
    1b00:	01065613          	srli	a2,a2,0x10
    1b04:	01410593          	addi	a1,sp,20
    1b08:	00004537          	lui	a0,0x4
    1b0c:	fe850513          	addi	a0,a0,-24 # 3fe8 <_data+0x64>
    1b10:	ccdff0ef          	jal	17dc <app_log>
    diag_drain();
    1b14:	f71ff0ef          	jal	1a84 <diag_drain>
    hex8(b1, r.canvas);
    1b18:	02812583          	lw	a1,40(sp)
    1b1c:	01410513          	addi	a0,sp,20
    1b20:	f1dff0ef          	jal	1a3c <hex8>
    app_log("osd regs: CANVAS=%s", b1);
    1b24:	01410593          	addi	a1,sp,20
    1b28:	00004537          	lui	a0,0x4
    1b2c:	02850513          	addi	a0,a0,40 # 4028 <_data+0xa4>
    1b30:	cadff0ef          	jal	17dc <app_log>
    diag_drain();
    1b34:	f51ff0ef          	jal	1a84 <diag_drain>
    hex8(b1, r.active);
    1b38:	02c12583          	lw	a1,44(sp)
    1b3c:	01410513          	addi	a0,sp,20
    1b40:	efdff0ef          	jal	1a3c <hex8>
    app_log("osd regs: ACTIVE=%s", b1);
    1b44:	01410593          	addi	a1,sp,20
    1b48:	00004537          	lui	a0,0x4
    1b4c:	03c50513          	addi	a0,a0,60 # 403c <_data+0xb8>
    1b50:	c8dff0ef          	jal	17dc <app_log>
    diag_drain();
    1b54:	f31ff0ef          	jal	1a84 <diag_drain>
    for (i = 0; i < 4; i++) {
    1b58:	00000413          	li	s0,0
    1b5c:	01c0006f          	j	1b78 <diag_dump_regs+0xd0>
        app_log("osd route%d: enable=%u buffer=%c",
    1b60:	04100693          	li	a3,65
    1b64:	00004537          	lui	a0,0x4
    1b68:	05050513          	addi	a0,a0,80 # 4050 <_data+0xcc>
    1b6c:	c71ff0ef          	jal	17dc <app_log>
        diag_drain();
    1b70:	f15ff0ef          	jal	1a84 <diag_drain>
    for (i = 0; i < 4; i++) {
    1b74:	00140413          	addi	s0,s0,1
    1b78:	00300793          	li	a5,3
    1b7c:	0287c663          	blt	a5,s0,1ba8 <diag_dump_regs+0x100>
        app_log("osd route%d: enable=%u buffer=%c",
    1b80:	00040593          	mv	a1,s0
                (r.active >> (4 + i)) & 1U,
    1b84:	02c12783          	lw	a5,44(sp)
    1b88:	00440613          	addi	a2,s0,4
    1b8c:	00c7d633          	srl	a2,a5,a2
        app_log("osd route%d: enable=%u buffer=%c",
    1b90:	00167613          	andi	a2,a2,1
                ((r.active >> i) & 1U) ? 'B' : 'A');
    1b94:	0087d7b3          	srl	a5,a5,s0
    1b98:	0017f793          	andi	a5,a5,1
        app_log("osd route%d: enable=%u buffer=%c",
    1b9c:	fc0782e3          	beqz	a5,1b60 <diag_dump_regs+0xb8>
    1ba0:	04200693          	li	a3,66
    1ba4:	fc1ff06f          	j	1b64 <diag_dump_regs+0xbc>
    hex8(b1, r.pos_last);
    1ba8:	03812583          	lw	a1,56(sp)
    1bac:	01410513          	addi	a0,sp,20
    1bb0:	e8dff0ef          	jal	1a3c <hex8>
    hex8(b2, r.pos_read);
    1bb4:	03012583          	lw	a1,48(sp)
    1bb8:	00810513          	addi	a0,sp,8
    1bbc:	e81ff0ef          	jal	1a3c <hex8>
    app_log("osd route1 POS: last_written=%s readback=%s (W-only)", b1, b2);
    1bc0:	00810613          	addi	a2,sp,8
    1bc4:	01410593          	addi	a1,sp,20
    1bc8:	00004537          	lui	a0,0x4
    1bcc:	07450513          	addi	a0,a0,116 # 4074 <_data+0xf0>
    1bd0:	c0dff0ef          	jal	17dc <app_log>
    diag_drain();
    1bd4:	eb1ff0ef          	jal	1a84 <diag_drain>
    hex8(b1, r.ctrl_last);
    1bd8:	03c12583          	lw	a1,60(sp)
    1bdc:	01410513          	addi	a0,sp,20
    1be0:	e5dff0ef          	jal	1a3c <hex8>
    hex8(b2, r.ctrl_read);
    1be4:	03412583          	lw	a1,52(sp)
    1be8:	00810513          	addi	a0,sp,8
    1bec:	e51ff0ef          	jal	1a3c <hex8>
    app_log("osd route1 CTRL: last_written=%s readback=%s (W-only)", b1, b2);
    1bf0:	00810613          	addi	a2,sp,8
    1bf4:	01410593          	addi	a1,sp,20
    1bf8:	00004537          	lui	a0,0x4
    1bfc:	0ac50513          	addi	a0,a0,172 # 40ac <_data+0x128>
    1c00:	bddff0ef          	jal	17dc <app_log>
    diag_drain();
    1c04:	e81ff0ef          	jal	1a84 <diag_drain>
}
    1c08:	04c12083          	lw	ra,76(sp)
    1c0c:	04812403          	lw	s0,72(sp)
    1c10:	05010113          	addi	sp,sp,80
    1c14:	00008067          	ret

00001c18 <diag_probe_sticky>:
{
    1c18:	fc010113          	addi	sp,sp,-64
    1c1c:	02112e23          	sw	ra,60(sp)
    hex8(b1, canvas_peek(s_probe_in_bitmap));
    1c20:	8341a503          	lw	a0,-1996(gp) # 57dc <s_probe_in_bitmap>
    1c24:	66c010ef          	jal	3290 <canvas_peek>
    1c28:	00050593          	mv	a1,a0
    1c2c:	02410513          	addi	a0,sp,36
    1c30:	e0dff0ef          	jal	1a3c <hex8>
    hex8(b2, canvas_peek(s_probe_out_bitmap));
    1c34:	8301a503          	lw	a0,-2000(gp) # 57d8 <s_probe_out_bitmap>
    1c38:	658010ef          	jal	3290 <canvas_peek>
    1c3c:	00050593          	mv	a1,a0
    1c40:	01810513          	addi	a0,sp,24
    1c44:	df9ff0ef          	jal	1a3c <hex8>
    hex8(b3, s_probe_value);
    1c48:	5a5aa5b7          	lui	a1,0x5a5aa
    1c4c:	5a558593          	addi	a1,a1,1445 # 5a5aa5a5 <__freertos_irq_stack_top+0x5a5a17e5>
    1c50:	00c10513          	addi	a0,sp,12
    1c54:	de9ff0ef          	jal	1a3c <hex8>
    app_log("osd probe: sticky in-bitmap=%s out-bitmap=%s (wrote %s)", b1, b2, b3);
    1c58:	00c10693          	addi	a3,sp,12
    1c5c:	01810613          	addi	a2,sp,24
    1c60:	02410593          	addi	a1,sp,36
    1c64:	00004537          	lui	a0,0x4
    1c68:	0e450513          	addi	a0,a0,228 # 40e4 <_data+0x160>
    1c6c:	b71ff0ef          	jal	17dc <app_log>
    diag_drain();
    1c70:	e15ff0ef          	jal	1a84 <diag_drain>
}
    1c74:	03c12083          	lw	ra,60(sp)
    1c78:	04010113          	addi	sp,sp,64
    1c7c:	00008067          	ret

00001c80 <diag_probe_memory>:
{
    1c80:	fd010113          	addi	sp,sp,-48
    1c84:	02112623          	sw	ra,44(sp)
    1c88:	02812423          	sw	s0,40(sp)
    1c8c:	02912223          	sw	s1,36(sp)
    hex8(b1, canvas_bytes_written());
    1c90:	614010ef          	jal	32a4 <canvas_bytes_written>
    1c94:	00050593          	mv	a1,a0
    1c98:	01410513          	addi	a0,sp,20
    1c9c:	da1ff0ef          	jal	1a3c <hex8>
    app_log("osd probe: bytes_written(total)=%s", b1);
    1ca0:	01410593          	addi	a1,sp,20
    1ca4:	00004537          	lui	a0,0x4
    1ca8:	13050513          	addi	a0,a0,304 # 4130 <_data+0x1ac>
    1cac:	b31ff0ef          	jal	17dc <app_log>
    diag_drain();
    1cb0:	dd5ff0ef          	jal	1a84 <diag_drain>
    for (i = 0; i < 4; i++) {
    1cb4:	00000413          	li	s0,0
    1cb8:	0540006f          	j	1d0c <diag_probe_memory+0x8c>
        hex8(b1, peek_addr[i]);
    1cbc:	000057b7          	lui	a5,0x5
    1cc0:	00241713          	slli	a4,s0,0x2
    1cc4:	96078793          	addi	a5,a5,-1696 # 4960 <peek_addr.0>
    1cc8:	00e787b3          	add	a5,a5,a4
    1ccc:	0007a483          	lw	s1,0(a5)
    1cd0:	00048593          	mv	a1,s1
    1cd4:	01410513          	addi	a0,sp,20
    1cd8:	d65ff0ef          	jal	1a3c <hex8>
        hex8(b2, canvas_peek(peek_addr[i]));
    1cdc:	00048513          	mv	a0,s1
    1ce0:	5b0010ef          	jal	3290 <canvas_peek>
    1ce4:	00050593          	mv	a1,a0
    1ce8:	00810513          	addi	a0,sp,8
    1cec:	d51ff0ef          	jal	1a3c <hex8>
        app_log("osd probe: rd %s = %s", b1, b2);
    1cf0:	00810613          	addi	a2,sp,8
    1cf4:	01410593          	addi	a1,sp,20
    1cf8:	00004537          	lui	a0,0x4
    1cfc:	15450513          	addi	a0,a0,340 # 4154 <_data+0x1d0>
    1d00:	addff0ef          	jal	17dc <app_log>
        diag_drain();
    1d04:	d81ff0ef          	jal	1a84 <diag_drain>
    for (i = 0; i < 4; i++) {
    1d08:	00140413          	addi	s0,s0,1
    1d0c:	00300793          	li	a5,3
    1d10:	fa87d6e3          	bge	a5,s0,1cbc <diag_probe_memory+0x3c>
    got = canvas_poke(probe_addr, pattern);
    1d14:	a5c365b7          	lui	a1,0xa5c36
    1d18:	a3c58593          	addi	a1,a1,-1476 # a5c35a3c <__freertos_irq_stack_top+0xa5c2cc7c>
    1d1c:	00a60537          	lui	a0,0xa60
    1d20:	578010ef          	jal	3298 <canvas_poke>
    1d24:	00050413          	mv	s0,a0
    hex8(b1, probe_addr);
    1d28:	00a605b7          	lui	a1,0xa60
    1d2c:	01410513          	addi	a0,sp,20
    1d30:	d0dff0ef          	jal	1a3c <hex8>
    hex8(b2, pattern);
    1d34:	a5c365b7          	lui	a1,0xa5c36
    1d38:	a3c58593          	addi	a1,a1,-1476 # a5c35a3c <__freertos_irq_stack_top+0xa5c2cc7c>
    1d3c:	00810513          	addi	a0,sp,8
    1d40:	cfdff0ef          	jal	1a3c <hex8>
    app_log("osd probe: wr %s <- %s", b1, b2);
    1d44:	00810613          	addi	a2,sp,8
    1d48:	01410593          	addi	a1,sp,20
    1d4c:	00004537          	lui	a0,0x4
    1d50:	16c50513          	addi	a0,a0,364 # 416c <_data+0x1e8>
    1d54:	a89ff0ef          	jal	17dc <app_log>
    diag_drain();
    1d58:	d2dff0ef          	jal	1a84 <diag_drain>
    hex8(b1, got);
    1d5c:	00040593          	mv	a1,s0
    1d60:	01410513          	addi	a0,sp,20
    1d64:	cd9ff0ef          	jal	1a3c <hex8>
    hex8(b2, pattern);
    1d68:	a5c365b7          	lui	a1,0xa5c36
    1d6c:	a3c58593          	addi	a1,a1,-1476 # a5c35a3c <__freertos_irq_stack_top+0xa5c2cc7c>
    1d70:	00810513          	addi	a0,sp,8
    1d74:	cc9ff0ef          	jal	1a3c <hex8>
    app_log("osd probe: read back %s %s", b1,
    1d78:	a5c367b7          	lui	a5,0xa5c36
    1d7c:	a3c78793          	addi	a5,a5,-1476 # a5c35a3c <__freertos_irq_stack_top+0xa5c2cc7c>
    1d80:	0af40663          	beq	s0,a5,1e2c <diag_probe_memory+0x1ac>
    1d84:	00004637          	lui	a2,0x4
    1d88:	12460613          	addi	a2,a2,292 # 4124 <_data+0x1a0>
    1d8c:	01410593          	addi	a1,sp,20
    1d90:	00004537          	lui	a0,0x4
    1d94:	18450513          	addi	a0,a0,388 # 4184 <_data+0x200>
    1d98:	a45ff0ef          	jal	17dc <app_log>
    diag_drain();
    1d9c:	ce9ff0ef          	jal	1a84 <diag_drain>
    s_probe_out_bitmap = probe_addr;
    1da0:	00a60737          	lui	a4,0xa60
    1da4:	82e1a823          	sw	a4,-2000(gp) # 57d8 <s_probe_out_bitmap>
    s_probe_in_bitmap  = 0x00A40000u + 0x100u;
    1da8:	00a40537          	lui	a0,0xa40
    1dac:	10050513          	addi	a0,a0,256 # a40100 <__freertos_irq_stack_top+0xa37340>
    1db0:	82a1aa23          	sw	a0,-1996(gp) # 57dc <s_probe_in_bitmap>
    got = canvas_poke(s_probe_in_bitmap, s_probe_value);
    1db4:	5a5aa5b7          	lui	a1,0x5a5aa
    1db8:	5a558593          	addi	a1,a1,1445 # 5a5aa5a5 <__freertos_irq_stack_top+0x5a5a17e5>
    1dbc:	4dc010ef          	jal	3298 <canvas_poke>
    1dc0:	00050413          	mv	s0,a0
    hex8(b1, s_probe_in_bitmap);
    1dc4:	8341a583          	lw	a1,-1996(gp) # 57dc <s_probe_in_bitmap>
    1dc8:	01410513          	addi	a0,sp,20
    1dcc:	c71ff0ef          	jal	1a3c <hex8>
    hex8(b2, s_probe_value);
    1dd0:	5a5aa5b7          	lui	a1,0x5a5aa
    1dd4:	5a558593          	addi	a1,a1,1445 # 5a5aa5a5 <__freertos_irq_stack_top+0x5a5a17e5>
    1dd8:	00810513          	addi	a0,sp,8
    1ddc:	c61ff0ef          	jal	1a3c <hex8>
    app_log("osd probe: [in-bitmap] wr %s <- %s", b1, b2);
    1de0:	00810613          	addi	a2,sp,8
    1de4:	01410593          	addi	a1,sp,20
    1de8:	00004537          	lui	a0,0x4
    1dec:	1a050513          	addi	a0,a0,416 # 41a0 <_data+0x21c>
    1df0:	9edff0ef          	jal	17dc <app_log>
    diag_drain();
    1df4:	c91ff0ef          	jal	1a84 <diag_drain>
    hex8(b1, got);
    1df8:	00040593          	mv	a1,s0
    1dfc:	01410513          	addi	a0,sp,20
    1e00:	c3dff0ef          	jal	1a3c <hex8>
    app_log("osd probe: [in-bitmap] read back now = %s", b1);
    1e04:	01410593          	addi	a1,sp,20
    1e08:	00004537          	lui	a0,0x4
    1e0c:	1c450513          	addi	a0,a0,452 # 41c4 <_data+0x240>
    1e10:	9cdff0ef          	jal	17dc <app_log>
    diag_drain();
    1e14:	c71ff0ef          	jal	1a84 <diag_drain>
}
    1e18:	02c12083          	lw	ra,44(sp)
    1e1c:	02812403          	lw	s0,40(sp)
    1e20:	02412483          	lw	s1,36(sp)
    1e24:	03010113          	addi	sp,sp,48
    1e28:	00008067          	ret
    app_log("osd probe: read back %s %s", b1,
    1e2c:	00004637          	lui	a2,0x4
    1e30:	11c60613          	addi	a2,a2,284 # 411c <_data+0x198>
    1e34:	f59ff06f          	j	1d8c <diag_probe_memory+0x10c>

00001e38 <diag_dump_block>:
{
    1e38:	fb010113          	addi	sp,sp,-80
    1e3c:	04112623          	sw	ra,76(sp)
    1e40:	04812423          	sw	s0,72(sp)
    1e44:	04912223          	sw	s1,68(sp)
    1e48:	05212023          	sw	s2,64(sp)
    1e4c:	03312e23          	sw	s3,60(sp)
    1e50:	03412c23          	sw	s4,56(sp)
    1e54:	00050a13          	mv	s4,a0
    1e58:	00058413          	mv	s0,a1
    (void)canvas_read_block(idx, buf);
    1e5c:	384010ef          	jal	31e0 <canvas_read_block>
    uint32_t hash    = 2166136261U;      /* FNV-1a 的 32 位初值 */
    1e60:	811ca5b7          	lui	a1,0x811ca
    1e64:	dc558593          	addi	a1,a1,-571 # 811c9dc5 <__freertos_irq_stack_top+0x811c1005>
    uint32_t first   = 0xFFFFFFFFU;
    1e68:	fff00993          	li	s3,-1
    uint32_t setbits = 0U;
    1e6c:	00000493          	li	s1,0
    uint32_t nonzero = 0U;
    1e70:	00000913          	li	s2,0
    for (i = 0U; i < DIAG_BYTES; i++) {
    1e74:	00000693          	li	a3,0
    1e78:	0200006f          	j	1e98 <diag_dump_block+0x60>
                first = i;
    1e7c:	00068993          	mv	s3,a3
    1e80:	0480006f          	j	1ec8 <diag_dump_block+0x90>
                setbits++;
    1e84:	00148493          	addi	s1,s1,1
                t = (uint8_t)(t & (uint8_t)(t - 1U));
    1e88:	fff78713          	addi	a4,a5,-1
    1e8c:	00f777b3          	and	a5,a4,a5
            while (t != 0U) {
    1e90:	fe079ae3          	bnez	a5,1e84 <diag_dump_block+0x4c>
    for (i = 0U; i < DIAG_BYTES; i++) {
    1e94:	00168693          	addi	a3,a3,1
    1e98:	000027b7          	lui	a5,0x2
    1e9c:	b9f78793          	addi	a5,a5,-1121 # 1b9f <diag_dump_regs+0xf7>
    1ea0:	02d7e863          	bltu	a5,a3,1ed0 <diag_dump_block+0x98>
        uint8_t b = buf[i];
    1ea4:	00d407b3          	add	a5,s0,a3
    1ea8:	0007c783          	lbu	a5,0(a5)
        hash = (hash ^ (uint32_t)b) * 16777619U;
    1eac:	00b7c5b3          	xor	a1,a5,a1
    1eb0:	01000737          	lui	a4,0x1000
    1eb4:	19370713          	addi	a4,a4,403 # 1000193 <__freertos_irq_stack_top+0xff73d3>
    1eb8:	02e585b3          	mul	a1,a1,a4
        if (b != 0U) {
    1ebc:	fc078ce3          	beqz	a5,1e94 <diag_dump_block+0x5c>
            if (first == 0xFFFFFFFFU) {
    1ec0:	fff00713          	li	a4,-1
    1ec4:	fae98ce3          	beq	s3,a4,1e7c <diag_dump_block+0x44>
            nonzero++;
    1ec8:	00190913          	addi	s2,s2,1
            while (t != 0U) {
    1ecc:	fc5ff06f          	j	1e90 <diag_dump_block+0x58>
    hex8(h, hash);
    1ed0:	00010513          	mv	a0,sp
    1ed4:	b69ff0ef          	jal	1a3c <hex8>
    app_log("osd blk %c: nonzero=%u setbits=%u fnv1a=%s first=%u",
    1ed8:	00100793          	li	a5,1
    1edc:	04fa0463          	beq	s4,a5,1f24 <diag_dump_block+0xec>
    1ee0:	04100a13          	li	s4,65
    1ee4:	00098793          	mv	a5,s3
    1ee8:	00010713          	mv	a4,sp
    1eec:	00048693          	mv	a3,s1
    1ef0:	00090613          	mv	a2,s2
    1ef4:	000a0593          	mv	a1,s4
    1ef8:	00004537          	lui	a0,0x4
    1efc:	1f050513          	addi	a0,a0,496 # 41f0 <_data+0x26c>
    1f00:	8ddff0ef          	jal	17dc <app_log>
    diag_drain();
    1f04:	b81ff0ef          	jal	1a84 <diag_drain>
        app_log("osd blk %c map ('#'=any lit pixel in this 8x8 cell):",
    1f08:	000a0593          	mv	a1,s4
    1f0c:	00004537          	lui	a0,0x4
    1f10:	22450513          	addi	a0,a0,548 # 4224 <_data+0x2a0>
    1f14:	8c9ff0ef          	jal	17dc <app_log>
        diag_drain();
    1f18:	b6dff0ef          	jal	1a84 <diag_drain>
        for (cy = 0U; cy < DIAG_CELLS_Y; cy++) {
    1f1c:	00000493          	li	s1,0
    1f20:	08c0006f          	j	1fac <diag_dump_block+0x174>
    app_log("osd blk %c: nonzero=%u setbits=%u fnv1a=%s first=%u",
    1f24:	04200a13          	li	s4,66
    1f28:	fbdff06f          	j	1ee4 <diag_dump_block+0xac>
                    any = (uint8_t)(any | buf[(cy * 8U + r) * OSD_ROW_STRIDE + cx]);
    1f2c:	00349713          	slli	a4,s1,0x3
    1f30:	00d70733          	add	a4,a4,a3
    1f34:	00471793          	slli	a5,a4,0x4
    1f38:	00e787b3          	add	a5,a5,a4
    1f3c:	00179793          	slli	a5,a5,0x1
    1f40:	00b787b3          	add	a5,a5,a1
    1f44:	00f407b3          	add	a5,s0,a5
    1f48:	0007c783          	lbu	a5,0(a5)
    1f4c:	00c7e633          	or	a2,a5,a2
                for (r = 0U; r < 8U; r++) {
    1f50:	00168693          	addi	a3,a3,1
    1f54:	00700793          	li	a5,7
    1f58:	fcd7fae3          	bgeu	a5,a3,1f2c <diag_dump_block+0xf4>
                line[cx] = any ? '#' : '.';
    1f5c:	02060663          	beqz	a2,1f88 <diag_dump_block+0x150>
    1f60:	02300713          	li	a4,35
    1f64:	03058793          	addi	a5,a1,48
    1f68:	002787b3          	add	a5,a5,sp
    1f6c:	fce78e23          	sb	a4,-36(a5)
            for (cx = 0U; cx < DIAG_CELLS_X; cx++) {
    1f70:	00158593          	addi	a1,a1,1
    1f74:	02100793          	li	a5,33
    1f78:	00b7ec63          	bltu	a5,a1,1f90 <diag_dump_block+0x158>
                for (r = 0U; r < 8U; r++) {
    1f7c:	00000693          	li	a3,0
                uint8_t  any = 0U;
    1f80:	00000613          	li	a2,0
    1f84:	fd1ff06f          	j	1f54 <diag_dump_block+0x11c>
                line[cx] = any ? '#' : '.';
    1f88:	02e00713          	li	a4,46
    1f8c:	fd9ff06f          	j	1f64 <diag_dump_block+0x12c>
            line[DIAG_CELLS_X] = '\0';
    1f90:	02010723          	sb	zero,46(sp)
            app_log("%s", line);
    1f94:	00c10593          	addi	a1,sp,12
    1f98:	00004537          	lui	a0,0x4
    1f9c:	18050513          	addi	a0,a0,384 # 4180 <_data+0x1fc>
    1fa0:	83dff0ef          	jal	17dc <app_log>
            diag_drain();
    1fa4:	ae1ff0ef          	jal	1a84 <diag_drain>
        for (cy = 0U; cy < DIAG_CELLS_Y; cy++) {
    1fa8:	00148493          	addi	s1,s1,1
    1fac:	01900793          	li	a5,25
    1fb0:	0097e663          	bltu	a5,s1,1fbc <diag_dump_block+0x184>
            for (cx = 0U; cx < DIAG_CELLS_X; cx++) {
    1fb4:	00000593          	li	a1,0
    1fb8:	fbdff06f          	j	1f74 <diag_dump_block+0x13c>
}
    1fbc:	04c12083          	lw	ra,76(sp)
    1fc0:	04812403          	lw	s0,72(sp)
    1fc4:	04412483          	lw	s1,68(sp)
    1fc8:	04012903          	lw	s2,64(sp)
    1fcc:	03c12983          	lw	s3,60(sp)
    1fd0:	03812a03          	lw	s4,56(sp)
    1fd4:	05010113          	addi	sp,sp,80
    1fd8:	00008067          	ret

00001fdc <osd_boot_diag>:
{
    1fdc:	ff010113          	addi	sp,sp,-16
    1fe0:	00112623          	sw	ra,12(sp)
    1fe4:	00812423          	sw	s0,8(sp)
    app_log("--- osd boot readback ---");
    1fe8:	00004537          	lui	a0,0x4
    1fec:	25c50513          	addi	a0,a0,604 # 425c <_data+0x2d8>
    1ff0:	fecff0ef          	jal	17dc <app_log>
    diag_drain();
    1ff4:	a91ff0ef          	jal	1a84 <diag_drain>
    diag_dump_regs();
    1ff8:	ab1ff0ef          	jal	1aa8 <diag_dump_regs>
    diag_probe_memory();
    1ffc:	c85ff0ef          	jal	1c80 <diag_probe_memory>
    diag_dump_block(0, s_buf);
    2000:	00006437          	lui	s0,0x6
    2004:	c6440593          	addi	a1,s0,-924 # 5c64 <s_buf.2>
    2008:	00000513          	li	a0,0
    200c:	e2dff0ef          	jal	1e38 <diag_dump_block>
    diag_dump_block(1, s_buf);
    2010:	c6440593          	addi	a1,s0,-924
    2014:	00100513          	li	a0,1
    2018:	e21ff0ef          	jal	1e38 <diag_dump_block>
    diag_probe_sticky();
    201c:	bfdff0ef          	jal	1c18 <diag_probe_sticky>
    app_log("--- osd boot readback end ---");
    2020:	00004537          	lui	a0,0x4
    2024:	27850513          	addi	a0,a0,632 # 4278 <_data+0x2f4>
    2028:	fb4ff0ef          	jal	17dc <app_log>
    diag_drain();
    202c:	a59ff0ef          	jal	1a84 <diag_drain>
}
    2030:	00c12083          	lw	ra,12(sp)
    2034:	00812403          	lw	s0,8(sp)
    2038:	01010113          	addi	sp,sp,16
    203c:	00008067          	ret

00002040 <report_frame>:
static void report_frame(const frame_t *frame, const protocol_response_t *response){
    2040:	ff010113          	addi	sp,sp,-16
    2044:	00112623          	sw	ra,12(sp)
    2048:	00050613          	mv	a2,a0
    const uint32_t bit = (uint32_t)response->reason;
    204c:	0185a503          	lw	a0,24(a1)
    switch (response->reason) {
    2050:	00800793          	li	a5,8
    2054:	08a7e263          	bltu	a5,a0,20d8 <report_frame+0x98>
    2058:	00251793          	slli	a5,a0,0x2
    205c:	00005737          	lui	a4,0x5
    2060:	93c70713          	addi	a4,a4,-1732 # 493c <_data+0x9b8>
    2064:	00e787b3          	add	a5,a5,a4
    2068:	0007a783          	lw	a5,0(a5)
    206c:	00078067          	jr	a5
        app_log_once(bit, "rx cmd=0x%x (%s) len=%u -> not implemented, nak",
    2070:	00465703          	lhu	a4,4(a2)
    2074:	01c5a683          	lw	a3,28(a1)
    2078:	00164603          	lbu	a2,1(a2)
    207c:	000045b7          	lui	a1,0x4
    2080:	29858593          	addi	a1,a1,664 # 4298 <_data+0x314>
    2084:	f94ff0ef          	jal	1818 <app_log_once>
}
    2088:	00c12083          	lw	ra,12(sp)
    208c:	01010113          	addi	sp,sp,16
    2090:	00008067          	ret
        app_log_once(bit, "rx cmd=0x%x unknown, nak", (uint32_t)frame->command);
    2094:	00164603          	lbu	a2,1(a2)
    2098:	000045b7          	lui	a1,0x4
    209c:	2c858593          	addi	a1,a1,712 # 42c8 <_data+0x344>
    20a0:	f78ff0ef          	jal	1818 <app_log_once>
        break;
    20a4:	fe5ff06f          	j	2088 <report_frame+0x48>
        app_log_once(bit, "rx cmd=0x%x (%s) len=%u wrong, nak",
    20a8:	00465703          	lhu	a4,4(a2)
    20ac:	01c5a683          	lw	a3,28(a1)
    20b0:	00164603          	lbu	a2,1(a2)
    20b4:	000045b7          	lui	a1,0x4
    20b8:	2e458593          	addi	a1,a1,740 # 42e4 <_data+0x360>
    20bc:	f5cff0ef          	jal	1818 <app_log_once>
        break;
    20c0:	fc9ff06f          	j	2088 <report_frame+0x48>
        app_log_once(bit, "rx cmd=0x%x bad type, nak", (uint32_t)frame->command);
    20c4:	00164603          	lbu	a2,1(a2)
    20c8:	000045b7          	lui	a1,0x4
    20cc:	30858593          	addi	a1,a1,776 # 4308 <_data+0x384>
    20d0:	f48ff0ef          	jal	1818 <app_log_once>
        break;
    20d4:	fb5ff06f          	j	2088 <report_frame+0x48>
        app_log_once(bit, "rx cmd=0x%x crc/footer bad -> no-ack",
    20d8:	00164603          	lbu	a2,1(a2)
    20dc:	000045b7          	lui	a1,0x4
    20e0:	32458593          	addi	a1,a1,804 # 4324 <_data+0x3a0>
    20e4:	f34ff0ef          	jal	1818 <app_log_once>
}
    20e8:	fa1ff06f          	j	2088 <report_frame+0x48>

000020ec <poll_rx_loss>:
{
    20ec:	ff010113          	addi	sp,sp,-16
    20f0:	00112623          	sw	ra,12(sp)
    20f4:	00812423          	sw	s0,8(sp)
    uint32_t ring_drop = proto_uart_rx_dropped();
    20f8:	774000ef          	jal	286c <proto_uart_rx_dropped>
    20fc:	00050413          	mv	s0,a0
    uint32_t fifo_ovf  = proto_uart_fifo_overflow();
    2100:	774000ef          	jal	2874 <proto_uart_fifo_overflow>
    2104:	00050693          	mv	a3,a0
    if ((ring_drop != s_ring_drop_seen) || (fifo_ovf != s_fifo_ovf_seen)) {
    2108:	83c1a783          	lw	a5,-1988(gp) # 57e4 <s_ring_drop_seen>
    210c:	00879663          	bne	a5,s0,2118 <poll_rx_loss+0x2c>
    2110:	8381a783          	lw	a5,-1992(gp) # 57e0 <s_fifo_ovf_seen>
    2114:	02a78063          	beq	a5,a0,2134 <poll_rx_loss+0x48>
        s_ring_drop_seen = ring_drop;
    2118:	8281ae23          	sw	s0,-1988(gp) # 57e4 <s_ring_drop_seen>
        s_fifo_ovf_seen = fifo_ovf;
    211c:	82d1ac23          	sw	a3,-1992(gp) # 57e0 <s_fifo_ovf_seen>
        app_log_once(ONCE_BIT_RX_DROPPED,
    2120:	00040613          	mv	a2,s0
    2124:	000045b7          	lui	a1,0x4
    2128:	34c58593          	addi	a1,a1,844 # 434c <_data+0x3c8>
    212c:	01000513          	li	a0,16
    2130:	ee8ff0ef          	jal	1818 <app_log_once>
}
    2134:	00c12083          	lw	ra,12(sp)
    2138:	00812403          	lw	s0,8(sp)
    213c:	01010113          	addi	sp,sp,16
    2140:	00008067          	ret

00002144 <log_stats>:
{
    2144:	fc010113          	addi	sp,sp,-64
    2148:	02112e23          	sw	ra,60(sp)
    214c:	02812c23          	sw	s0,56(sp)
    2150:	02912a23          	sw	s1,52(sp)
    2154:	03212823          	sw	s2,48(sp)
    2158:	03312623          	sw	s3,44(sp)
    215c:	03412423          	sw	s4,40(sp)
    2160:	03512223          	sw	s5,36(sp)
    2164:	03612023          	sw	s6,32(sp)
    2168:	01712e23          	sw	s7,28(sp)
    app_log("stats: frames=%u accepted=%u bad=%u other=%u bad_len=%u "
    216c:	8641a983          	lw	s3,-1948(gp) # 580c <s_frames_processed>
    2170:	000087b7          	lui	a5,0x8
    2174:	80478793          	addi	a5,a5,-2044 # 7804 <s_stats>
    2178:	0007aa03          	lw	s4,0(a5)
    217c:	0047aa83          	lw	s5,4(a5)
    2180:	0087ab03          	lw	s6,8(a5)
    2184:	000087b7          	lui	a5,0x8
    2188:	81078793          	addi	a5,a5,-2032 # 7810 <s_parser>
    218c:	0107ab83          	lw	s7,16(a5)
    2190:	6dc000ef          	jal	286c <proto_uart_rx_dropped>
    2194:	00050413          	mv	s0,a0
    2198:	6dc000ef          	jal	2874 <proto_uart_fifo_overflow>
    219c:	00050493          	mv	s1,a0
    21a0:	e34ff0ef          	jal	17d4 <app_log_dropped>
    21a4:	00a12023          	sw	a0,0(sp)
    21a8:	00048893          	mv	a7,s1
    21ac:	00040813          	mv	a6,s0
    21b0:	000b8793          	mv	a5,s7
    21b4:	000b0713          	mv	a4,s6
    21b8:	000a8693          	mv	a3,s5
    21bc:	000a0613          	mv	a2,s4
    21c0:	00098593          	mv	a1,s3
    21c4:	00004537          	lui	a0,0x4
    21c8:	38850513          	addi	a0,a0,904 # 4388 <_data+0x404>
    21cc:	e10ff0ef          	jal	17dc <app_log>
    s_reported_frames = s_frames_processed;
    21d0:	8641a703          	lw	a4,-1948(gp) # 580c <s_frames_processed>
    21d4:	84e1a223          	sw	a4,-1980(gp) # 57ec <s_reported_frames>
}
    21d8:	03c12083          	lw	ra,60(sp)
    21dc:	03812403          	lw	s0,56(sp)
    21e0:	03412483          	lw	s1,52(sp)
    21e4:	03012903          	lw	s2,48(sp)
    21e8:	02c12983          	lw	s3,44(sp)
    21ec:	02812a03          	lw	s4,40(sp)
    21f0:	02412a83          	lw	s5,36(sp)
    21f4:	02012b03          	lw	s6,32(sp)
    21f8:	01c12b83          	lw	s7,28(sp)
    21fc:	04010113          	addi	sp,sp,64
    2200:	00008067          	ret

00002204 <handle_frame>:
static void handle_frame(const frame_t *frame){
    2204:	fb010113          	addi	sp,sp,-80
    2208:	04112623          	sw	ra,76(sp)
    220c:	04812423          	sw	s0,72(sp)
    2210:	04912223          	sw	s1,68(sp)
    2214:	00050413          	mv	s0,a0
    ack_len = osd_engine_handle(&s_stats, frame, &response, ack);
    2218:	00c10693          	addi	a3,sp,12
    221c:	02010613          	addi	a2,sp,32
    2220:	00050593          	mv	a1,a0
    2224:	00008537          	lui	a0,0x8
    2228:	80450513          	addi	a0,a0,-2044 # 7804 <s_stats>
    222c:	134010ef          	jal	3360 <osd_engine_handle>
    2230:	00050493          	mv	s1,a0
    s_frames_processed++;
    2234:	8641a783          	lw	a5,-1948(gp) # 580c <s_frames_processed>
    2238:	00178793          	addi	a5,a5,1
    223c:	86f1a223          	sw	a5,-1948(gp) # 580c <s_frames_processed>
    report_frame(frame, &response);
    2240:	02010593          	addi	a1,sp,32
    2244:	00040513          	mv	a0,s0
    2248:	df9ff0ef          	jal	2040 <report_frame>
    if (ack_len != 0U) {
    224c:	02049463          	bnez	s1,2274 <handle_frame+0x70>
    poll_rx_loss();
    2250:	e9dff0ef          	jal	20ec <poll_rx_loss>
    if ((s_frames_processed % STATS_INTERVAL) == 0U) {
    2254:	8641a783          	lw	a5,-1948(gp) # 580c <s_frames_processed>
    2258:	03f7f793          	andi	a5,a5,63
    225c:	02078463          	beqz	a5,2284 <handle_frame+0x80>
}
    2260:	04c12083          	lw	ra,76(sp)
    2264:	04812403          	lw	s0,72(sp)
    2268:	04412483          	lw	s1,68(sp)
    226c:	05010113          	addi	sp,sp,80
    2270:	00008067          	ret
        (void)proto_uart_write(ack, ack_len);
    2274:	00048593          	mv	a1,s1
    2278:	00c10513          	addi	a0,sp,12
    227c:	6c0000ef          	jal	293c <proto_uart_write>
    2280:	fd1ff06f          	j	2250 <handle_frame+0x4c>
        log_stats();
    2284:	ec1ff0ef          	jal	2144 <log_stats>
}
    2288:	fd9ff06f          	j	2260 <handle_frame+0x5c>

0000228c <isr_routine>:
void isr_routine(){
    228c:	ff010113          	addi	sp,sp,-16
    2290:	00112623          	sw	ra,12(sp)
    2294:	00812423          	sw	s0,8(sp)
    while ((claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)) != 0U) {
    2298:	0180006f          	j	22b0 <isr_routine+0x24>
            proto_uart_isr();      /* 把收到的字节搬进接收环 */
    229c:	60c000ef          	jal	28a8 <proto_uart_isr>
        plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim);
    22a0:	00040613          	mv	a2,s0
    22a4:	00000593          	li	a1,0
    22a8:	f8c00537          	lui	a0,0xf8c00
    22ac:	f44ff0ef          	jal	19f0 <plic_release>
    while ((claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)) != 0U) {
    22b0:	00000593          	li	a1,0
    22b4:	f8c00537          	lui	a0,0xf8c00
    22b8:	f1cff0ef          	jal	19d4 <plic_claim>
    22bc:	00050413          	mv	s0,a0
    22c0:	00050e63          	beqz	a0,22dc <isr_routine+0x50>
        if (claim == SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT) {
    22c4:	00200793          	li	a5,2
    22c8:	fcf40ae3          	beq	s0,a5,229c <isr_routine+0x10>
            s_isr_unknown_source++;
    22cc:	8501a783          	lw	a5,-1968(gp) # 57f8 <s_isr_unknown_source>
    22d0:	00178793          	addi	a5,a5,1
    22d4:	84f1a823          	sw	a5,-1968(gp) # 57f8 <s_isr_unknown_source>
    22d8:	fc9ff06f          	j	22a0 <isr_routine+0x14>
}
    22dc:	00c12083          	lw	ra,12(sp)
    22e0:	00812403          	lw	s0,8(sp)
    22e4:	01010113          	addi	sp,sp,16
    22e8:	00008067          	ret

000022ec <trap>:
void trap(){
    22ec:	ff010113          	addi	sp,sp,-16
    22f0:	00112623          	sw	ra,12(sp)
    int32_t mcause = csr_read(mcause);   /* 读 CSR 寄存器，得到异常/中断原因 */
    22f4:	342025f3          	csrr	a1,mcause
    int32_t cause     = mcause & 0xF;    /* 低 4 位 → 具体原因编号 */
    22f8:	00f5f793          	andi	a5,a1,15
    if (interrupt) {
    22fc:	0205c663          	bltz	a1,2328 <trap+0x3c>
    if (cause == CAUSE_BREAKPOINT) {
    2300:	00300713          	li	a4,3
    2304:	04e78263          	beq	a5,a4,2348 <trap+0x5c>
    s_unexpected_exceptions++;
    2308:	8581a783          	lw	a5,-1960(gp) # 5800 <s_unexpected_exceptions>
    230c:	00178793          	addi	a5,a5,1
    2310:	84f1ac23          	sw	a5,-1960(gp) # 5800 <s_unexpected_exceptions>
    if (!s_unexpected_exception_logged) {
    2314:	8541c783          	lbu	a5,-1964(gp) # 57fc <s_unexpected_exception_logged>
    2318:	04078663          	beqz	a5,2364 <trap+0x78>
}
    231c:	00c12083          	lw	ra,12(sp)
    2320:	01010113          	addi	sp,sp,16
    2324:	00008067          	ret
        if (cause == CAUSE_MACHINE_EXTERNAL) {
    2328:	00b00713          	li	a4,11
    232c:	00e78a63          	beq	a5,a4,2340 <trap+0x54>
            s_unexpected_interrupts++;
    2330:	85c1a783          	lw	a5,-1956(gp) # 5804 <s_unexpected_interrupts>
    2334:	00178793          	addi	a5,a5,1
    2338:	84f1ae23          	sw	a5,-1956(gp) # 5804 <s_unexpected_interrupts>
        return;
    233c:	fe1ff06f          	j	231c <trap+0x30>
            isr_routine();
    2340:	f4dff0ef          	jal	228c <isr_routine>
    2344:	fd9ff06f          	j	231c <trap+0x30>
        s_semihosting_breakpoints++;
    2348:	8601a783          	lw	a5,-1952(gp) # 5808 <s_semihosting_breakpoints>
    234c:	00178793          	addi	a5,a5,1
    2350:	86f1a023          	sw	a5,-1952(gp) # 5808 <s_semihosting_breakpoints>
        csr_write(mepc, csr_read(mepc) + 4);
    2354:	341027f3          	csrr	a5,mepc
    2358:	00478793          	addi	a5,a5,4
    235c:	34179073          	csrw	mepc,a5
        return;
    2360:	fbdff06f          	j	231c <trap+0x30>
        s_unexpected_exception_logged = 1;
    2364:	00100713          	li	a4,1
    2368:	84e18a23          	sb	a4,-1964(gp) # 57fc <s_unexpected_exception_logged>
        app_log("trap: unexpected exception mcause=0x%x", (uint32_t)mcause);
    236c:	00004537          	lui	a0,0x4
    2370:	3e850513          	addi	a0,a0,1000 # 43e8 <_data+0x464>
    2374:	c68ff0ef          	jal	17dc <app_log>
    2378:	fa5ff06f          	j	231c <trap+0x30>

0000237c <start_frame>:
*       好处是链接器不会为它生成对外符号，也不怕和别的文件里的同名函数冲突。
*       本文件里所有辅助函数都用 static。
******************************************************************************/
static int start_frame(frame_parser_t *parser, uint8_t byte)
{
    if (byte != FRAME_HEADER) {
    237c:	0bb00793          	li	a5,187
    2380:	02f59663          	bne	a1,a5,23ac <start_frame+0x30>
        return 0;   /* 不是帧头，当噪声丢掉，继续等 */
    }
    parser->state = ST_LEN_H;
    2384:	00100793          	li	a5,1
    2388:	00f50023          	sb	a5,0(a0)
    parser->body_length = 0U;
    238c:	00051123          	sh	zero,2(a0)
    parser->body_index = 0U;
    2390:	00051223          	sh	zero,4(a0)
    parser->body_crc = 0U;
    2394:	00051323          	sh	zero,6(a0)
    parser->recv_crc = 0U;
    2398:	00051423          	sh	zero,8(a0)
    parser->category = 0U;
    239c:	00050523          	sb	zero,10(a0)
    parser->command = 0U;
    23a0:	000505a3          	sb	zero,11(a0)
    parser->type = 0U;
    23a4:	00050623          	sb	zero,12(a0)
    parser->payload_len = 0U;
    23a8:	00051a23          	sh	zero,20(a0)
    return 0;
}
    23ac:	00000513          	li	a0,0
    23b0:	00008067          	ret

000023b4 <frame_parser_init>:
    if (parser == 0) {
    23b4:	04050863          	beqz	a0,2404 <frame_parser_init+0x50>
    parser->state = ST_HEADER;
    23b8:	00050023          	sb	zero,0(a0)
    parser->body_length = 0U;
    23bc:	00051123          	sh	zero,2(a0)
    parser->body_index = 0U;
    23c0:	00051223          	sh	zero,4(a0)
    parser->body_crc = 0U;
    23c4:	00051323          	sh	zero,6(a0)
    parser->recv_crc = 0U;
    23c8:	00051423          	sh	zero,8(a0)
    parser->category = 0U;
    23cc:	00050523          	sb	zero,10(a0)
    parser->command = 0U;
    23d0:	000505a3          	sb	zero,11(a0)
    parser->type = 0U;
    23d4:	00050623          	sb	zero,12(a0)
    parser->bad_length_count = 0U;
    23d8:	00052823          	sw	zero,16(a0)
    parser->payload_len = 0U;
    23dc:	00051a23          	sh	zero,20(a0)
        for (i = 0U; i < FRAME_PAYLOAD_MAX; i++) {
    23e0:	00000793          	li	a5,0
    23e4:	0180006f          	j	23fc <frame_parser_init+0x48>
            parser->payload[i] = 0U;
    23e8:	00f50733          	add	a4,a0,a5
    23ec:	00070b23          	sb	zero,22(a4)
        for (i = 0U; i < FRAME_PAYLOAD_MAX; i++) {
    23f0:	00178793          	addi	a5,a5,1
    23f4:	01079793          	slli	a5,a5,0x10
    23f8:	0107d793          	srli	a5,a5,0x10
    23fc:	00b00713          	li	a4,11
    2400:	fef774e3          	bgeu	a4,a5,23e8 <frame_parser_init+0x34>
}
    2404:	00008067          	ret

00002408 <frame_parser_feed>:
*       break 导致穿透到下一个 case"这个 C 语言的经典坑；二是每个状态的
*       处理路径互不影响，读代码时不用往回看。
******************************************************************************/
int frame_parser_feed(frame_parser_t *parser, uint8_t byte, frame_t *out)
{
    if ((parser == 0) || (out == 0)) {
    2408:	22050063          	beqz	a0,2628 <frame_parser_feed+0x220>
{
    240c:	ff010113          	addi	sp,sp,-16
    2410:	00112623          	sw	ra,12(sp)
    2414:	00812423          	sw	s0,8(sp)
    2418:	00912223          	sw	s1,4(sp)
    241c:	00050413          	mv	s0,a0
    2420:	00058493          	mv	s1,a1
    if ((parser == 0) || (out == 0)) {
    2424:	20060663          	beqz	a2,2630 <frame_parser_feed+0x228>
        return 0;
    }

    switch (parser->state) {
    2428:	00054783          	lbu	a5,0(a0)
    242c:	00500713          	li	a4,5
    2430:	14f76663          	bltu	a4,a5,257c <frame_parser_feed+0x174>
    2434:	00279793          	slli	a5,a5,0x2
    2438:	00005737          	lui	a4,0x5
    243c:	98470713          	addi	a4,a4,-1660 # 4984 <digits.1+0x14>
    2440:	00e787b3          	add	a5,a5,a4
    2444:	0007a783          	lw	a5,0(a5)
    2448:	00078067          	jr	a5
    /* --- 等帧头：帧与帧之间的所有噪声都在这里被自然丢弃 --- */
    case ST_HEADER:
        return start_frame(parser, byte);
    244c:	f31ff0ef          	jal	237c <start_frame>
    2450:	1e40006f          	j	2634 <frame_parser_feed+0x22c>

    /* --- 长度高字节：先暂存到 body_length 的高 8 位 --- */
    case ST_LEN_H:
        /* (uint16_t)byte << 8 把这一字节挪到高字节，低字节此时还是 0。
         * 用 = 而不是 |= 是刻意的：这里直接覆盖，避免上一帧的残留值混进来。*/
        parser->body_length = (uint16_t)byte << 8;
    2454:	00859493          	slli	s1,a1,0x8
    2458:	00951123          	sh	s1,2(a0)
        parser->state = ST_LEN_L;
    245c:	00200793          	li	a5,2
    2460:	00f50023          	sb	a5,0(a0)
        return 0;
    2464:	00000513          	li	a0,0
    2468:	1cc0006f          	j	2634 <frame_parser_feed+0x22c>

    /* --- 长度低字节：凑成完整长度，并立刻检查是否合法 --- */
    case ST_LEN_L:
        /* |= 把低字节补上，此时 body_length 才是完整的 16 位长度。*/
        parser->body_length |= (uint16_t)byte;
    246c:	00255783          	lhu	a5,2(a0)
    2470:	00f5e7b3          	or	a5,a1,a5
    2474:	00f51123          	sh	a5,2(a0)

        if ((parser->body_length < FRAME_BODY_LEN_MIN) ||
    2478:	ffd78793          	addi	a5,a5,-3
    247c:	01079793          	slli	a5,a5,0x10
    2480:	0107d793          	srli	a5,a5,0x10
    2484:	00001737          	lui	a4,0x1
    2488:	38470713          	addi	a4,a4,900 # 1384 <emit_uint+0x58>
    248c:	00f76c63          	bltu	a4,a5,24a4 <frame_parser_feed+0x9c>
             * 没成为一个帧。*/
            parser->bad_length_count++;
            parser->state = ST_HEADER;
            return 0;
        }
        parser->body_index = 0U;
    2490:	00051223          	sh	zero,4(a0)
        parser->state = ST_BODY;
    2494:	00300793          	li	a5,3
    2498:	00f50023          	sb	a5,0(a0)
        return 0;
    249c:	00000513          	li	a0,0
    24a0:	1940006f          	j	2634 <frame_parser_feed+0x22c>
            parser->bad_length_count++;
    24a4:	01052783          	lw	a5,16(a0)
    24a8:	00178793          	addi	a5,a5,1
    24ac:	00f52823          	sw	a5,16(a0)
            parser->state = ST_HEADER;
    24b0:	00050023          	sb	zero,0(a0)
            return 0;
    24b4:	00000513          	li	a0,0
    24b8:	17c0006f          	j	2634 <frame_parser_feed+0x22c>

    /* --- body：边收边算 CRC，同时把前 3 个字节记下来 --- */
    case ST_BODY:
        parser->body_crc = crc16_ccitt_update(parser->body_crc, byte);
    24bc:	00655503          	lhu	a0,6(a0)
    24c0:	510000ef          	jal	29d0 <crc16_ccitt_update>
    24c4:	00a41323          	sh	a0,6(s0)

        /* 前 3 个字节是固定的头结构，第 3 个 if 之后的都是 payload。
         * 注意这里**只记录、不校验**：大类是路由字段，合法性由上层判断
         * （见 frame.h 里"大类是路由字段，不是格式标记"的说明）。
         * 只有"类型"这一位在帧尾阶段会做校验。*/
        if (parser->body_index == 0U) {
    24c8:	00445783          	lhu	a5,4(s0)
    24cc:	02079663          	bnez	a5,24f8 <frame_parser_feed+0xf0>
            parser->category = byte;
    24d0:	00940523          	sb	s1,10(s0)
        }

        /* 收到第 body_length 个字节时，body 结束，转去收 CRC。
         * body_index 从 0 计，所以最后一个字节的下标是 body_length-1。
         * 这里的减法已经安全：长度在 ST_LEN_L 阶段校验过 >= 3。*/
        if (parser->body_index == (uint16_t)(parser->body_length - 1U)) {
    24d4:	00245703          	lhu	a4,2(s0)
    24d8:	fff70713          	addi	a4,a4,-1
    24dc:	01071713          	slli	a4,a4,0x10
    24e0:	01075713          	srli	a4,a4,0x10
    24e4:	04e78a63          	beq	a5,a4,2538 <frame_parser_feed+0x130>
            parser->state = ST_CRC_H;
        } else {
            parser->body_index++;
    24e8:	00178793          	addi	a5,a5,1
    24ec:	00f41223          	sh	a5,4(s0)
        }
        return 0;
    24f0:	00000513          	li	a0,0
    24f4:	1400006f          	j	2634 <frame_parser_feed+0x22c>
        } else if (parser->body_index == 1U) {
    24f8:	00100713          	li	a4,1
    24fc:	02e78663          	beq	a5,a4,2528 <frame_parser_feed+0x120>
        } else if (parser->body_index == 2U) {
    2500:	00200713          	li	a4,2
    2504:	02e78663          	beq	a5,a4,2530 <frame_parser_feed+0x128>
            uint16_t k = (uint16_t)(parser->body_index - 3U);
    2508:	ffd78713          	addi	a4,a5,-3
    250c:	01071713          	slli	a4,a4,0x10
    2510:	01075713          	srli	a4,a4,0x10
            if (k < FRAME_PAYLOAD_MAX) {
    2514:	00b00693          	li	a3,11
    2518:	fae6eee3          	bltu	a3,a4,24d4 <frame_parser_feed+0xcc>
                parser->payload[k] = byte;
    251c:	00e40733          	add	a4,s0,a4
    2520:	00970b23          	sb	s1,22(a4)
    2524:	fb1ff06f          	j	24d4 <frame_parser_feed+0xcc>
            parser->command = byte;
    2528:	009405a3          	sb	s1,11(s0)
    252c:	fa9ff06f          	j	24d4 <frame_parser_feed+0xcc>
            parser->type = byte;
    2530:	00940623          	sb	s1,12(s0)
    2534:	fa1ff06f          	j	24d4 <frame_parser_feed+0xcc>
            parser->state = ST_CRC_H;
    2538:	00400793          	li	a5,4
    253c:	00f40023          	sb	a5,0(s0)
        return 0;
    2540:	00000513          	li	a0,0
    2544:	0f00006f          	j	2634 <frame_parser_feed+0x22c>

    /* --- CRC 高字节 --- */
    case ST_CRC_H:
        parser->recv_crc = (uint16_t)byte << 8;
    2548:	00859493          	slli	s1,a1,0x8
    254c:	00951423          	sh	s1,8(a0)
        parser->state = ST_CRC_L;
    2550:	00500793          	li	a5,5
    2554:	00f50023          	sb	a5,0(a0)
        return 0;
    2558:	00000513          	li	a0,0
    255c:	0d80006f          	j	2634 <frame_parser_feed+0x22c>

    /* --- CRC 低字节：凑成完整 CRC，转去收帧尾 --- */
    case ST_CRC_L:
        parser->recv_crc |= (uint16_t)byte;
    2560:	00855783          	lhu	a5,8(a0)
    2564:	00f5e7b3          	or	a5,a1,a5
    2568:	00f51423          	sh	a5,8(a0)
        parser->state = ST_FOOTER;
    256c:	00600793          	li	a5,6
    2570:	00f50023          	sb	a5,0(a0)
        return 0;
    2574:	00000513          	li	a0,0
    2578:	0bc0006f          	j	2634 <frame_parser_feed+0x22c>
    default:
        /* default 和 ST_FOOTER 走同一段代码，是防御性写法：万一 state 被
         * 内存踩坏成了非法值，也只会当成"帧尾"处理并立即复位回 ST_HEADER，
         * 不会卡死在非法状态里。*/

        out->category    = parser->category;
    257c:	00a54783          	lbu	a5,10(a0)
    2580:	00f60023          	sb	a5,0(a2)
        out->command     = parser->command;
    2584:	00b54783          	lbu	a5,11(a0)
    2588:	00f600a3          	sb	a5,1(a2)
        out->type        = parser->type;
    258c:	00c54783          	lbu	a5,12(a0)
    2590:	00f60123          	sb	a5,2(a2)
        out->body_length = parser->body_length;
    2594:	00255783          	lhu	a5,2(a0)
    2598:	00f61223          	sh	a5,4(a2)

        /* payload_len 是"帧里声明有多少"（body_length 减去 3 字节 body 头），
         * 可能大于窗口容量；payload[] 里只有前 min(payload_len, 12) 个字节有效。
         * 长度在 ST_LEN_L 阶段校验过 >= 3，所以这里的减法不会下溢。*/
        out->payload_len = (uint16_t)(parser->body_length - 3U);
    259c:	ffd78793          	addi	a5,a5,-3
    25a0:	00f61523          	sh	a5,10(a2)
        {
            uint16_t i;
            for (i = 0U; i < FRAME_PAYLOAD_MAX; i++) {
    25a4:	00000793          	li	a5,0
    25a8:	0200006f          	j	25c8 <frame_parser_feed+0x1c0>
                out->payload[i] = parser->payload[i];
    25ac:	00f40733          	add	a4,s0,a5
    25b0:	01674683          	lbu	a3,22(a4)
    25b4:	00f60733          	add	a4,a2,a5
    25b8:	00d70623          	sb	a3,12(a4)
            for (i = 0U; i < FRAME_PAYLOAD_MAX; i++) {
    25bc:	00178793          	addi	a5,a5,1
    25c0:	01079793          	slli	a5,a5,0x10
    25c4:	0107d793          	srli	a5,a5,0x10
    25c8:	00b00713          	li	a4,11
    25cc:	fef770e3          	bgeu	a4,a5,25ac <frame_parser_feed+0x1a4>
        }

        /* 三个布尔标志都写成 `? 1U : 0U` 而不是直接赋值比较表达式的结果。
         * 因为 C 里比较运算符的结果是 int 类型的 1/0，直接赋给 uint8_t 字段
         * 虽然没问题，但显式写出来能保证字段里只可能是 0 或 1。*/
        out->crc_ok      = (parser->recv_crc == parser->body_crc) ? 1U : 0U;
    25d0:	00845703          	lhu	a4,8(s0)
    25d4:	00645783          	lhu	a5,6(s0)
    25d8:	02f70c63          	beq	a4,a5,2610 <frame_parser_feed+0x208>
    25dc:	00000793          	li	a5,0
    25e0:	00f60323          	sb	a5,6(a2)
        out->footer_ok   = (byte == FRAME_FOOTER) ? 1U : 0U;
    25e4:	0aa00793          	li	a5,170
    25e8:	02f48863          	beq	s1,a5,2618 <frame_parser_feed+0x210>
    25ec:	00000793          	li	a5,0
    25f0:	00f603a3          	sb	a5,7(a2)
        /* 格式校验只有这一条：命令帧的类型必须是"上位机写"。
         * 大类**不在这里校验**——它是路由字段，变倍/热点/UI 的大类都是合法的，
         * 只是不该由本应用处理（在上层分流）。*/
        out->format_ok   = (parser->type == FRAME_TYPE_WRITE) ? 1U : 0U;
    25f4:	00c44783          	lbu	a5,12(s0)
    25f8:	02079463          	bnez	a5,2620 <frame_parser_feed+0x218>
    25fc:	00100793          	li	a5,1
    2600:	00f60423          	sb	a5,8(a2)

        /* 无论这一帧是好是坏，解析器都回到等帧头，准备接下一帧。
         * 这样"坏帧"不会让解析器停摆——上位机可以继续发下一条命令。*/
        parser->state = ST_HEADER;
    2604:	00040023          	sb	zero,0(s0)
        return 1;
    2608:	00100513          	li	a0,1
    260c:	0280006f          	j	2634 <frame_parser_feed+0x22c>
        out->crc_ok      = (parser->recv_crc == parser->body_crc) ? 1U : 0U;
    2610:	00100793          	li	a5,1
    2614:	fcdff06f          	j	25e0 <frame_parser_feed+0x1d8>
        out->footer_ok   = (byte == FRAME_FOOTER) ? 1U : 0U;
    2618:	00100793          	li	a5,1
    261c:	fd5ff06f          	j	25f0 <frame_parser_feed+0x1e8>
        out->format_ok   = (parser->type == FRAME_TYPE_WRITE) ? 1U : 0U;
    2620:	00000793          	li	a5,0
    2624:	fddff06f          	j	2600 <frame_parser_feed+0x1f8>
        return 0;
    2628:	00000513          	li	a0,0
    }
}
    262c:	00008067          	ret
        return 0;
    2630:	00000513          	li	a0,0
}
    2634:	00c12083          	lw	ra,12(sp)
    2638:	00812403          	lw	s0,8(sp)
    263c:	00412483          	lw	s1,4(sp)
    2640:	01010113          	addi	sp,sp,16
    2644:	00008067          	ret

00002648 <uart_writeAvailability>:
        return *((volatile u32*) address);
    2648:	00452503          	lw	a0,4(a0)
        return (read_u32(reg + UART_STATUS) >> 16) & 0xFF;
    264c:	01055513          	srli	a0,a0,0x10
    }
    2650:	0ff57513          	zext.b	a0,a0
    2654:	00008067          	ret

00002658 <uart_readOccupancy>:
    2658:	00452503          	lw	a0,4(a0)
    }
    265c:	01855513          	srli	a0,a0,0x18
    2660:	00008067          	ret

00002664 <uart_read>:
    static char uart_read(u32 reg){
    2664:	ff010113          	addi	sp,sp,-16
    2668:	00112623          	sw	ra,12(sp)
    266c:	00812423          	sw	s0,8(sp)
    2670:	00050413          	mv	s0,a0
        while(uart_readOccupancy(reg) == 0);
    2674:	00040513          	mv	a0,s0
    2678:	fe1ff0ef          	jal	2658 <uart_readOccupancy>
    267c:	fe050ce3          	beqz	a0,2674 <uart_read+0x10>
    2680:	00042503          	lw	a0,0(s0)
    }
    2684:	0ff57513          	zext.b	a0,a0
    2688:	00c12083          	lw	ra,12(sp)
    268c:	00812403          	lw	s0,8(sp)
    2690:	01010113          	addi	sp,sp,16
    2694:	00008067          	ret

00002698 <uart_applyConfig>:
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
    2698:	00c5a783          	lw	a5,12(a1)
        *((volatile u32*) address) = data;
    269c:	00f52423          	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
    26a0:	0005a783          	lw	a5,0(a1)
    26a4:	fff78793          	addi	a5,a5,-1
    26a8:	0045a703          	lw	a4,4(a1)
    26ac:	00871713          	slli	a4,a4,0x8
    26b0:	00e7e7b3          	or	a5,a5,a4
    26b4:	0085a703          	lw	a4,8(a1)
    26b8:	01071713          	slli	a4,a4,0x10
    26bc:	00e7e7b3          	or	a5,a5,a4
    26c0:	00f52623          	sw	a5,12(a0)
    }
    26c4:	00008067          	ret

000026c8 <uart_status_read>:
        return *((volatile u32*) address);
    26c8:	00452503          	lw	a0,4(a0)
*
******************************************************************************/    
    static u32 uart_status_read(u32 reg)
     {
    	 return read_u32(reg+UART_STATUS);
     }
    26cc:	00008067          	ret

000026d0 <uart_status_write>:
        *((volatile u32*) address) = data;
    26d0:	00b52223          	sw	a1,4(a0)
*
******************************************************************************/
    static void uart_status_write(u32 reg, char data)
    {
    	write_u32(data ,reg+UART_STATUS);
    }
    26d4:	00008067          	ret

000026d8 <uart_RX_NotemptyInterruptEna>:
*          clears the second least significant bit to disable the RX not empty interrupt,
*          or sets it to enable the RX not empty interrupt based on the provided flag,
*          and then writes the modified value back to the UART status register.
*
******************************************************************************/
    static void uart_RX_NotemptyInterruptEna(u32 reg, char Ena){
    26d8:	ff010113          	addi	sp,sp,-16
    26dc:	00112623          	sw	ra,12(sp)
    26e0:	00812423          	sw	s0,8(sp)
    26e4:	00912223          	sw	s1,4(sp)
    26e8:	00050493          	mv	s1,a0
    26ec:	00058413          	mv	s0,a1
    	uart_status_write(reg,(uart_status_read(reg) & 0xFFFFFFFD) | (Ena << 1));	
    26f0:	fd9ff0ef          	jal	26c8 <uart_status_read>
    26f4:	0fd57593          	andi	a1,a0,253
    26f8:	00141413          	slli	s0,s0,0x1
    26fc:	0ff47413          	zext.b	s0,s0
    2700:	0085e5b3          	or	a1,a1,s0
    2704:	00048513          	mv	a0,s1
    2708:	fc9ff0ef          	jal	26d0 <uart_status_write>
    }
    270c:	00c12083          	lw	ra,12(sp)
    2710:	00812403          	lw	s0,8(sp)
    2714:	00412483          	lw	s1,4(sp)
    2718:	01010113          	addi	sp,sp,16
    271c:	00008067          	ret

00002720 <plic_set_priority>:
        write_u32(priority, plic + PLIC_PRIORITY_BASE + gateway*4);
    2720:	00259593          	slli	a1,a1,0x2
    2724:	00a585b3          	add	a1,a1,a0
    2728:	00c5a023          	sw	a2,0(a1)
    }
    272c:	00008067          	ret

00002730 <plic_set_enable>:
        u32 word = plic + PLIC_ENABLE_BASE + target * PLIC_ENABLE_PER_HART + (gateway / 32 * 4);
    2730:	00759593          	slli	a1,a1,0x7
    2734:	00a585b3          	add	a1,a1,a0
    2738:	00565793          	srli	a5,a2,0x5
    273c:	00279793          	slli	a5,a5,0x2
    2740:	00f587b3          	add	a5,a1,a5
    2744:	00002737          	lui	a4,0x2
    2748:	00e787b3          	add	a5,a5,a4
        u32 mask = 1 << (gateway % 32);
    274c:	00100713          	li	a4,1
    2750:	00c71633          	sll	a2,a4,a2
        if (enable)
    2754:	00068a63          	beqz	a3,2768 <plic_set_enable+0x38>
        return *((volatile u32*) address);
    2758:	0007a703          	lw	a4,0(a5)
            write_u32(read_u32(word) | mask, word);
    275c:	00e66633          	or	a2,a2,a4
        *((volatile u32*) address) = data;
    2760:	00c7a023          	sw	a2,0(a5)
    }
    2764:	00008067          	ret
        return *((volatile u32*) address);
    2768:	0007a703          	lw	a4,0(a5)
            write_u32(read_u32(word) & ~mask, word);
    276c:	fff64613          	not	a2,a2
    2770:	00e67633          	and	a2,a2,a4
        *((volatile u32*) address) = data;
    2774:	00c7a023          	sw	a2,0(a5)
    }
    2778:	00008067          	ret

0000277c <plic_set_threshold>:
        write_u32(threshold, plic + PLIC_THRESHOLD_BASE + target*PLIC_CONTEXT_PER_HART);
    277c:	00c59593          	slli	a1,a1,0xc
    2780:	00a585b3          	add	a1,a1,a0
    2784:	002007b7          	lui	a5,0x200
    2788:	00f585b3          	add	a1,a1,a5
    278c:	00c5a023          	sw	a2,0(a1)
    }
    2790:	00008067          	ret

00002794 <proto_uart_init>:
* @note 调用顺序上，本函数要在 isr_init() 之前调用（见 main.c）：先把中断源
*       配好，再全局开中断。反过来的话，开中断后到中断源配置好之间可能出现
*       一个"中断已使能但没有正确处理程序"的窗口。
******************************************************************************/
void proto_uart_init(void)
{
    2794:	fe010113          	addi	sp,sp,-32
    2798:	00112e23          	sw	ra,28(sp)
    Uart_Config config;

    config.dataLength   = BITS_8;   /* 8 位数据 */
    279c:	00800793          	li	a5,8
    27a0:	00f12023          	sw	a5,0(sp)
    config.parity       = NONE;     /* 无校验 */
    27a4:	00012223          	sw	zero,4(sp)
    config.stop         = ONE;      /* 1 位停止位 */
    27a8:	00012423          	sw	zero,8(sp)
    /* 分频系数 = 时钟频率 / (波特率 × 每字符位数) - 1
     * 这里的算式与 bsp.h 里 bsp_init() 的一字不差。*/
    config.clockDivider = BSP_CLINT_HZ / (BSP_UART_BAUDRATE * BSP_UART_DATA_LEN) - 1;
    27ac:	03500793          	li	a5,53
    27b0:	00f12623          	sw	a5,12(sp)

    uart_applyConfig(PROTO_UART_BASE, &config);
    27b4:	00010593          	mv	a1,sp
    27b8:	f8002537          	lui	a0,0xf8002
    27bc:	eddff0ef          	jal	2698 <uart_applyConfig>

    /* 清空接收环和计数。*/
    s_head = 0U;
    27c0:	8601a823          	sw	zero,-1936(gp) # 5818 <s_head>
    s_tail = 0U;
    27c4:	8601a623          	sw	zero,-1940(gp) # 5814 <s_tail>
    s_dropped = 0U;
    27c8:	8601a423          	sw	zero,-1944(gp) # 5810 <s_dropped>
    s_fifo_overflow_seen = 0U;
    27cc:	8601aa23          	sw	zero,-1932(gp) # 581c <s_fifo_overflow_seen>
    27d0:	f80027b7          	lui	a5,0xf8002
    27d4:	00200713          	li	a4,2
    27d8:	00e7a823          	sw	a4,16(a5) # f8002010 <__freertos_irq_stack_top+0xf7ff9250>
    /* 上电时硬件里可能留有之前（比如复位前）的溢出标志，先清掉，
     * 否则第一份汇总就会报一个不属于本次运行的溢出。*/
    write_u32(UART_ERR_READ_OVERFLOW, PROTO_UART_BASE + UART_ERROR_REG);

    /* 使能"接收 FIFO 非空"中断：FIFO 里一有数据就产生中断。*/
    uart_RX_NotemptyInterruptEna(PROTO_UART_BASE, 1);
    27dc:	00100593          	li	a1,1
    27e0:	f8002537          	lui	a0,0xf8002
    27e4:	ef5ff0ef          	jal	26d8 <uart_RX_NotemptyInterruptEna>

    /* 把该中断接到本核（CPU 0）上。
     * threshold = 0 表示"优先级高于 0 的中断都接受"，即全部接受。
     * 这三步（threshold / enable / priority）是 PLIC 的标准配置顺序。*/
    plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0);
    27e8:	00000613          	li	a2,0
    27ec:	00000593          	li	a1,0
    27f0:	f8c00537          	lui	a0,0xf8c00
    27f4:	f89ff0ef          	jal	277c <plic_set_threshold>
    plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0,
    27f8:	00100693          	li	a3,1
    27fc:	00200613          	li	a2,2
    2800:	00000593          	li	a1,0
    2804:	f8c00537          	lui	a0,0xf8c00
    2808:	f29ff0ef          	jal	2730 <plic_set_enable>
                    SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT, 1);
    plic_set_priority(BSP_PLIC, SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT, 1);
    280c:	00100613          	li	a2,1
    2810:	00200593          	li	a1,2
    2814:	f8c00537          	lui	a0,0xf8c00
    2818:	f09ff0ef          	jal	2720 <plic_set_priority>
}
    281c:	01c12083          	lw	ra,28(sp)
    2820:	02010113          	addi	sp,sp,32
    2824:	00008067          	ret

00002828 <proto_uart_rx_pop>:
*       如果先推进指针再读数据，中断可能在这两步之间又写入了新字节，我们就会
*       读到下一个字节、把当前这个漏掉。
******************************************************************************/
int proto_uart_rx_pop(uint8_t *byte)
{
    if (s_head == s_tail) {
    2828:	8701a703          	lw	a4,-1936(gp) # 5818 <s_head>
    282c:	86c1a783          	lw	a5,-1940(gp) # 5814 <s_tail>
    2830:	02f70a63          	beq	a4,a5,2864 <proto_uart_rx_pop+0x3c>
        return 0;              /* 环空 */
    }
    *byte = s_ring[s_tail];
    2834:	86c1a683          	lw	a3,-1940(gp) # 5814 <s_tail>
    2838:	000087b7          	lui	a5,0x8
    283c:	83478793          	addi	a5,a5,-1996 # 7834 <s_ring>
    2840:	00d787b3          	add	a5,a5,a3
    2844:	0007c783          	lbu	a5,0(a5)
    2848:	00f50023          	sb	a5,0(a0) # f8c00000 <__freertos_irq_stack_top+0xf8bf7240>
    s_tail = (s_tail + 1U) & (PROTO_RX_RING_SIZE - 1U);
    284c:	86c1a783          	lw	a5,-1940(gp) # 5814 <s_tail>
    2850:	00178793          	addi	a5,a5,1
    2854:	1ff7f793          	andi	a5,a5,511
    2858:	86f1a623          	sw	a5,-1940(gp) # 5814 <s_tail>
    return 1;
    285c:	00100513          	li	a0,1
    2860:	00008067          	ret
        return 0;              /* 环空 */
    2864:	00000513          	li	a0,0
}
    2868:	00008067          	ret

0000286c <proto_uart_rx_dropped>:
/******************************************************************************
* @brief 因接收环满而丢弃的字节数。
******************************************************************************/
uint32_t proto_uart_rx_dropped(void)
{
    return s_dropped;
    286c:	8681a503          	lw	a0,-1944(gp) # 5810 <s_dropped>
}
    2870:	00008067          	ret

00002874 <proto_uart_fifo_overflow>:
        return *((volatile u32*) address);
    2874:	f80027b7          	lui	a5,0xf8002
    2878:	01078793          	addi	a5,a5,16 # f8002010 <__freertos_irq_stack_top+0xf7ff9250>
    287c:	0007a783          	lw	a5,0(a5)
******************************************************************************/
uint32_t proto_uart_fifo_overflow(void)
{
    uint32_t err = read_u32(PROTO_UART_BASE + UART_ERROR_REG);

    if ((err & UART_ERR_READ_OVERFLOW) != 0U) {
    2880:	0027f793          	andi	a5,a5,2
    2884:	00078e63          	beqz	a5,28a0 <proto_uart_fifo_overflow+0x2c>
        s_fifo_overflow_seen++;
    2888:	8741a783          	lw	a5,-1932(gp) # 581c <s_fifo_overflow_seen>
    288c:	00178793          	addi	a5,a5,1
    2890:	86f1aa23          	sw	a5,-1932(gp) # 581c <s_fifo_overflow_seen>
        *((volatile u32*) address) = data;
    2894:	f80027b7          	lui	a5,0xf8002
    2898:	00200713          	li	a4,2
    289c:	00e7a823          	sw	a4,16(a5) # f8002010 <__freertos_irq_stack_top+0xf7ff9250>
        /* 写 1 清零（不是读-改-写：这个寄存器是"写 1 清除对应标志"的语义）。*/
        write_u32(UART_ERR_READ_OVERFLOW, PROTO_UART_BASE + UART_ERROR_REG);
    }
    return s_fifo_overflow_seen;
}
    28a0:	8741a503          	lw	a0,-1932(gp) # 581c <s_fifo_overflow_seen>
    28a4:	00008067          	ret

000028a8 <proto_uart_isr>:
*
* @note 中断服务程序里只做"搬字节"这一件事，不做解析、不做任何输出。
*       解析放在主循环（见 main.c），这样中断的执行时间恒定且极短。
******************************************************************************/
void proto_uart_isr(void)
{
    28a8:	ff010113          	addi	sp,sp,-16
    28ac:	00112623          	sw	ra,12(sp)
    uint32_t status;

    /* 第一步：读出状态寄存器，把"接收非空中断使能"这一位清掉（屏蔽中断源）。*/
    status = uart_status_read(PROTO_UART_BASE);
    28b0:	f8002537          	lui	a0,0xf8002
    28b4:	e15ff0ef          	jal	26c8 <uart_status_read>
    uart_status_write(PROTO_UART_BASE,
    28b8:	0fd57593          	andi	a1,a0,253
    28bc:	f8002537          	lui	a0,0xf8002
    28c0:	e11ff0ef          	jal	26d0 <uart_status_write>
                      (char)(status & ~UART_STATUS_RX_NOTEMPTY_INT_EN));

    /* 第二步：把 FIFO 里现有的字节全部搬进接收环。*/
    while (uart_readOccupancy(PROTO_UART_BASE) != 0U) {
    28c4:	0100006f          	j	28d4 <proto_uart_isr+0x2c>
        uint32_t next = (s_head + 1U) & (PROTO_RX_RING_SIZE - 1U);

        if (next == s_tail) {
            /* 写指针再前进就会追上读指针，说明环满了。丢掉这个字节并计数。
             * 注意这里**不推进** s_head——推进了就等于覆盖掉还没被读走的数据。*/
            s_dropped++;
    28c8:	8681a783          	lw	a5,-1944(gp) # 5810 <s_dropped>
    28cc:	00178793          	addi	a5,a5,1
    28d0:	86f1a423          	sw	a5,-1944(gp) # 5810 <s_dropped>
    while (uart_readOccupancy(PROTO_UART_BASE) != 0U) {
    28d4:	f8002537          	lui	a0,0xf8002
    28d8:	d81ff0ef          	jal	2658 <uart_readOccupancy>
    28dc:	02050e63          	beqz	a0,2918 <proto_uart_isr+0x70>
        uint8_t  b    = (uint8_t)uart_read(PROTO_UART_BASE);
    28e0:	f8002537          	lui	a0,0xf8002
    28e4:	d81ff0ef          	jal	2664 <uart_read>
        uint32_t next = (s_head + 1U) & (PROTO_RX_RING_SIZE - 1U);
    28e8:	8701a783          	lw	a5,-1936(gp) # 5818 <s_head>
    28ec:	00178793          	addi	a5,a5,1
    28f0:	1ff7f793          	andi	a5,a5,511
        if (next == s_tail) {
    28f4:	86c1a703          	lw	a4,-1940(gp) # 5814 <s_tail>
    28f8:	fcf708e3          	beq	a4,a5,28c8 <proto_uart_isr+0x20>
        } else {
            s_ring[s_head] = b;
    28fc:	8701a603          	lw	a2,-1936(gp) # 5818 <s_head>
    2900:	00008737          	lui	a4,0x8
    2904:	83470713          	addi	a4,a4,-1996 # 7834 <s_ring>
    2908:	00c70733          	add	a4,a4,a2
    290c:	00a70023          	sb	a0,0(a4)
            s_head = next;
    2910:	86f1a823          	sw	a5,-1936(gp) # 5818 <s_head>
    2914:	fc1ff06f          	j	28d4 <proto_uart_isr+0x2c>
    /* 第三步：重新使能中断，准备接收下一批。
     * 重新读一次状态寄存器再置位，而不是直接用第一步读到的 status：
     * 因为排空过程中硬件可能改了状态寄存器里的其它位（比如溢出标志），
     * 用旧值回写会把这些变化抹掉。*/
    uart_status_write(PROTO_UART_BASE,
                      (char)(uart_status_read(PROTO_UART_BASE) |
    2918:	f8002537          	lui	a0,0xf8002
    291c:	dadff0ef          	jal	26c8 <uart_status_read>
    uart_status_write(PROTO_UART_BASE,
    2920:	00256593          	ori	a1,a0,2
    2924:	0ff5f593          	zext.b	a1,a1
    2928:	f8002537          	lui	a0,0xf8002
    292c:	da5ff0ef          	jal	26d0 <uart_status_write>
                             UART_STATUS_RX_NOTEMPTY_INT_EN));
}
    2930:	00c12083          	lw	ra,12(sp)
    2934:	01010113          	addi	sp,sp,16
    2938:	00008067          	ret

0000293c <proto_uart_write>:
int proto_uart_write(const uint8_t *data, uint32_t len)
{
    uint32_t i;
    uint32_t guard;

    if (data == 0) {
    293c:	06050663          	beqz	a0,29a8 <proto_uart_write+0x6c>
{
    2940:	fe010113          	addi	sp,sp,-32
    2944:	00112e23          	sw	ra,28(sp)
    2948:	00812c23          	sw	s0,24(sp)
    294c:	00912a23          	sw	s1,20(sp)
    2950:	01212823          	sw	s2,16(sp)
    2954:	01312623          	sw	s3,12(sp)
    2958:	00050913          	mv	s2,a0
    295c:	00058993          	mv	s3,a1
        return 0;
    }

    for (i = 0U; i < len; i++) {
    2960:	00000493          	li	s1,0
    2964:	0180006f          	j	297c <proto_uart_write+0x40>
            guard--;
        }
        /* 直接把字节写到 UART 的数据寄存器。用 write_u32（来自 driver/io.h）
         * 而不是给指针赋值，是为了沿用 driver 里统一的"内存映射寄存器访问"
         * 写法，将来若要加内存屏障之类只需改一处。*/
        write_u32(data[i], PROTO_UART_BASE + UART_DATA);
    2968:	009907b3          	add	a5,s2,s1
    296c:	0007c703          	lbu	a4,0(a5)
    2970:	f80027b7          	lui	a5,0xf8002
    2974:	00e7a023          	sw	a4,0(a5) # f8002000 <__freertos_irq_stack_top+0xf7ff9240>
    for (i = 0U; i < len; i++) {
    2978:	00148493          	addi	s1,s1,1
    297c:	0334f263          	bgeu	s1,s3,29a0 <proto_uart_write+0x64>
        guard = PROTO_TX_TIMEOUT_SPINS;
    2980:	00018437          	lui	s0,0x18
    2984:	6a040413          	addi	s0,s0,1696 # 186a0 <__freertos_irq_stack_top+0xf8e0>
        while (uart_writeAvailability(PROTO_UART_BASE) == 0U) {
    2988:	f8002537          	lui	a0,0xf8002
    298c:	cbdff0ef          	jal	2648 <uart_writeAvailability>
    2990:	fc051ce3          	bnez	a0,2968 <proto_uart_write+0x2c>
            if (guard == 0U) {
    2994:	00040e63          	beqz	s0,29b0 <proto_uart_write+0x74>
            guard--;
    2998:	fff40413          	addi	s0,s0,-1
    299c:	fedff06f          	j	2988 <proto_uart_write+0x4c>
    }
    return 1;
    29a0:	00100513          	li	a0,1
    29a4:	0100006f          	j	29b4 <proto_uart_write+0x78>
        return 0;
    29a8:	00000513          	li	a0,0
}
    29ac:	00008067          	ret
                return 0;   /* 等太久了，放弃这一帧的剩余部分 */
    29b0:	00000513          	li	a0,0
}
    29b4:	01c12083          	lw	ra,28(sp)
    29b8:	01812403          	lw	s0,24(sp)
    29bc:	01412483          	lw	s1,20(sp)
    29c0:	01012903          	lw	s2,16(sp)
    29c4:	00c12983          	lw	s3,12(sp)
    29c8:	02010113          	addi	sp,sp,32
    29cc:	00008067          	ret

000029d0 <crc16_ccitt_update>:
     * 会先"整型提升"成 int，左移 8 位后还是 int，直接和 uint16_t 异或虽然结果
     * 正确，但中间类型带符号、语义不清晰。显式转型让每一步的类型都一目了然。
     *
     * 最外层的 (uint16_t) 是为了把结果截断回 16 位。RTL 里 c 就是 16 位寄存器，
     * 溢出自然丢弃高位；C 里必须显式截断才能和 RTL 完全一致。*/
    uint16_t c = (uint16_t)(crc ^ (uint16_t)((uint16_t)data << 8));
    29d0:	00859593          	slli	a1,a1,0x8
    29d4:	00a5c533          	xor	a0,a1,a0
     *
     * 为什么不用查表法（预生成 256 项的表，一次处理一个字节）：
     * 查表要占 512 字节常量空间，而本模块的调用频率是"每个 body 字节一次"，
     * 在 115200 波特率下每秒最多一万多次，逐位法（每字节 8 次循环）绰绰有余。
     * 用一点 CPU 换掉 512 字节 Flash，对软核更划算。*/
    for (n = 0; n < 8; n++) {
    29d8:	00000793          	li	a5,0
    29dc:	0140006f          	j	29f0 <crc16_ccitt_update+0x20>
        if ((c & 0x8000U) != 0U) {
            /* 0x8000 就是只保留 bit15 的掩码。用 & 判断而不是写成 (c >> 15)，
             * 是为了和 RTL 的 c[15] 取值写法更贴近。*/
            c = (uint16_t)((uint16_t)(c << 1) ^ CRC16_CCITT_POLY);
        } else {
            c = (uint16_t)(c << 1);
    29e0:	00151513          	slli	a0,a0,0x1
    29e4:	01051513          	slli	a0,a0,0x10
    29e8:	01055513          	srli	a0,a0,0x10
    for (n = 0; n < 8; n++) {
    29ec:	00178793          	addi	a5,a5,1
    29f0:	00700713          	li	a4,7
    29f4:	02f74663          	blt	a4,a5,2a20 <crc16_ccitt_update+0x50>
        if ((c & 0x8000U) != 0U) {
    29f8:	01051713          	slli	a4,a0,0x10
    29fc:	41075713          	srai	a4,a4,0x10
    2a00:	fe0750e3          	bgez	a4,29e0 <crc16_ccitt_update+0x10>
            c = (uint16_t)((uint16_t)(c << 1) ^ CRC16_CCITT_POLY);
    2a04:	00151513          	slli	a0,a0,0x1
    2a08:	01051513          	slli	a0,a0,0x10
    2a0c:	01055513          	srli	a0,a0,0x10
    2a10:	00001737          	lui	a4,0x1
    2a14:	02170713          	addi	a4,a4,33 # 1021 <smp_slave+0x9>
    2a18:	00e54533          	xor	a0,a0,a4
    2a1c:	fd1ff06f          	j	29ec <crc16_ccitt_update+0x1c>
        }
    }
    return c;
}
    2a20:	00008067          	ret

00002a24 <handler_not_implemented>:
static uint8_t handler_not_implemented(const frame_t *frame, uint8_t *out,
                                       uint16_t *out_len)
{
    (void)frame;
    (void)out;
    *out_len = 0U;
    2a24:	00061023          	sh	zero,0(a2)
    return PROTOCOL_STATUS_FAIL;
}
    2a28:	00000513          	li	a0,0
    2a2c:	00008067          	ret

00002a30 <handler_ui_not_in_scope>:
static uint8_t handler_ui_not_in_scope(const frame_t *frame, uint8_t *out,
                                       uint16_t *out_len)
{
    (void)frame;
    (void)out;
    *out_len = 0U;
    2a30:	00061023          	sh	zero,0(a2)
    return PROTOCOL_STATUS_FAIL;
}
    2a34:	00000513          	li	a0,0
    2a38:	00008067          	ret

00002a3c <category_lookup>:
******************************************************************************/
static const protocol_category_t *category_lookup(uint8_t category)
{
    uint32_t i;

    for (i = 0U; i < CATEGORY_ENTRIES; i++) {
    2a3c:	00000793          	li	a5,0
    2a40:	00100713          	li	a4,1
    2a44:	02f76e63          	bltu	a4,a5,2a80 <category_lookup+0x44>
        if (s_categories[i].category == category) {
    2a48:	00005737          	lui	a4,0x5
    2a4c:	00179693          	slli	a3,a5,0x1
    2a50:	00f686b3          	add	a3,a3,a5
    2a54:	00269693          	slli	a3,a3,0x2
    2a58:	99c70713          	addi	a4,a4,-1636 # 499c <s_categories>
    2a5c:	00d70733          	add	a4,a4,a3
    2a60:	00074703          	lbu	a4,0(a4)
    2a64:	00a70663          	beq	a4,a0,2a70 <category_lookup+0x34>
    for (i = 0U; i < CATEGORY_ENTRIES; i++) {
    2a68:	00178793          	addi	a5,a5,1
    2a6c:	fd5ff06f          	j	2a40 <category_lookup+0x4>
            return &s_categories[i];
    2a70:	000057b7          	lui	a5,0x5
    2a74:	99c78793          	addi	a5,a5,-1636 # 499c <s_categories>
    2a78:	00f68533          	add	a0,a3,a5
    2a7c:	00008067          	ret
        }
    }
    return 0;
    2a80:	00000513          	li	a0,0
}
    2a84:	00008067          	ret

00002a88 <table_lookup>:
* @note 线性查找而不是二分或哈希：掩膜表 5 行、UI 表 8 行，几次比较的开销可以
*       忽略，而线性代码最简单、最不容易写错。
******************************************************************************/
static const protocol_entry_t *table_lookup(const protocol_category_t *cat,
                                            uint8_t command)
{
    2a88:	00050713          	mv	a4,a0
    uint32_t i;

    for (i = 0U; i < cat->count; i++) {
    2a8c:	00000793          	li	a5,0
    2a90:	0080006f          	j	2a98 <table_lookup+0x10>
    2a94:	00178793          	addi	a5,a5,1
    2a98:	00872683          	lw	a3,8(a4)
    2a9c:	00d7fe63          	bgeu	a5,a3,2ab8 <table_lookup+0x30>
        if (cat->entries[i].command == command) {
    2aa0:	00472503          	lw	a0,4(a4)
    2aa4:	00479693          	slli	a3,a5,0x4
    2aa8:	00d50533          	add	a0,a0,a3
    2aac:	00054683          	lbu	a3,0(a0) # f8002000 <__freertos_irq_stack_top+0xf7ff9240>
    2ab0:	feb692e3          	bne	a3,a1,2a94 <table_lookup+0xc>
    2ab4:	00008067          	ret
            return &cat->entries[i];
        }
    }
    return 0;
    2ab8:	00000513          	li	a0,0
}
    2abc:	00008067          	ret

00002ac0 <entry_length_ok>:
* @param body_length 帧里声明的 body 长度。
* @return 1 表示相符。
******************************************************************************/
static int entry_length_ok(const protocol_entry_t *entry, uint16_t body_length)
{
    if (entry->body_length == LEN_ANY) {
    2ac0:	00255783          	lhu	a5,2(a0)
    2ac4:	00010737          	lui	a4,0x10
    2ac8:	fff70713          	addi	a4,a4,-1 # ffff <__freertos_irq_stack_top+0x723f>
    2acc:	00e78863          	beq	a5,a4,2adc <entry_length_ok+0x1c>
        return (body_length >= entry->min_length) ? 1 : 0;
    }
    return (body_length == entry->body_length) ? 1 : 0;
    2ad0:	40b78533          	sub	a0,a5,a1
    2ad4:	00153513          	seqz	a0,a0
}
    2ad8:	00008067          	ret
        return (body_length >= entry->min_length) ? 1 : 0;
    2adc:	00455503          	lhu	a0,4(a0)
    2ae0:	00a5b5b3          	sltu	a1,a1,a0
    2ae4:	0015b513          	seqz	a0,a1
    2ae8:	00008067          	ret

00002aec <build_ack_common>:
*       加运行时检查只会掩盖"有人把 UI_QUERY_PAYLOAD_LEN 改大了"这个真问题。
******************************************************************************/
static uint16_t build_ack_common(uint8_t *ack, uint8_t category, uint8_t command,
                                 uint8_t status, const uint8_t *payload,
                                 uint16_t payload_len)
{
    2aec:	fd010113          	addi	sp,sp,-48
    2af0:	02112623          	sw	ra,44(sp)
    2af4:	02812423          	sw	s0,40(sp)
    2af8:	02912223          	sw	s1,36(sp)
    2afc:	03212023          	sw	s2,32(sp)
    2b00:	01312e23          	sw	s3,28(sp)
    2b04:	01412c23          	sw	s4,24(sp)
    2b08:	01512a23          	sw	s5,20(sp)
    2b0c:	01612823          	sw	s6,16(sp)
    2b10:	01712623          	sw	s7,12(sp)
    2b14:	00050913          	mv	s2,a0
    2b18:	00058b93          	mv	s7,a1
    2b1c:	00060a93          	mv	s5,a2
    2b20:	00068a13          	mv	s4,a3
    2b24:	00070993          	mv	s3,a4
    2b28:	00078493          	mv	s1,a5
    uint16_t crc = 0U;
    uint16_t body_len;
    uint16_t i;

    body_len = (uint16_t)(4U + payload_len);
    2b2c:	00478b13          	addi	s6,a5,4
    2b30:	010b1b13          	slli	s6,s6,0x10
    2b34:	010b5b13          	srli	s6,s6,0x10

    crc = crc16_ccitt_update(crc, category);
    2b38:	00000513          	li	a0,0
    2b3c:	e95ff0ef          	jal	29d0 <crc16_ccitt_update>
    crc = crc16_ccitt_update(crc, command);
    2b40:	000a8593          	mv	a1,s5
    2b44:	e8dff0ef          	jal	29d0 <crc16_ccitt_update>
    crc = crc16_ccitt_update(crc, PROTOCOL_ACK_TYPE);
    2b48:	00200593          	li	a1,2
    2b4c:	e85ff0ef          	jal	29d0 <crc16_ccitt_update>
    crc = crc16_ccitt_update(crc, status);
    2b50:	000a0593          	mv	a1,s4
    2b54:	e7dff0ef          	jal	29d0 <crc16_ccitt_update>
    for (i = 0U; i < payload_len; i++) {
    2b58:	00000413          	li	s0,0
    2b5c:	01c0006f          	j	2b78 <build_ack_common+0x8c>
        crc = crc16_ccitt_update(crc, payload[i]);
    2b60:	008987b3          	add	a5,s3,s0
    2b64:	0007c583          	lbu	a1,0(a5)
    2b68:	e69ff0ef          	jal	29d0 <crc16_ccitt_update>
    for (i = 0U; i < payload_len; i++) {
    2b6c:	00140413          	addi	s0,s0,1
    2b70:	01041413          	slli	s0,s0,0x10
    2b74:	01045413          	srli	s0,s0,0x10
    2b78:	fe9464e3          	bltu	s0,s1,2b60 <build_ack_common+0x74>
    }

    ack[0] = FRAME_HEADER;                 /* 帧头 0xBB */
    2b7c:	fbb00793          	li	a5,-69
    2b80:	00f90023          	sb	a5,0(s2)
    ack[1] = (uint8_t)(body_len >> 8);     /* body_length 高字节 */
    2b84:	008b5793          	srli	a5,s6,0x8
    2b88:	00f900a3          	sb	a5,1(s2)
    ack[2] = (uint8_t)(body_len & 0xFFU);  /* body_length 低字节 */
    2b8c:	01690123          	sb	s6,2(s2)
    ack[3] = category;                     /* 应答体第 0 字节：回显大类 */
    2b90:	017901a3          	sb	s7,3(s2)
    ack[4] = command;                      /* 应答体第 1 字节：回显子项 */
    2b94:	01590223          	sb	s5,4(s2)
    ack[5] = PROTOCOL_ACK_TYPE;            /* 应答体第 2 字节：0x02 表示应答 */
    2b98:	00200793          	li	a5,2
    2b9c:	00f902a3          	sb	a5,5(s2)
    ack[6] = status;                       /* 应答体第 3 字节 */
    2ba0:	01490323          	sb	s4,6(s2)
    for (i = 0U; i < payload_len; i++) {
    2ba4:	00000693          	li	a3,0
    2ba8:	0240006f          	j	2bcc <build_ack_common+0xe0>
        ack[7U + i] = payload[i];
    2bac:	00768613          	addi	a2,a3,7
    2bb0:	00c90633          	add	a2,s2,a2
    2bb4:	00d987b3          	add	a5,s3,a3
    2bb8:	0007c783          	lbu	a5,0(a5)
    2bbc:	00f60023          	sb	a5,0(a2)
    for (i = 0U; i < payload_len; i++) {
    2bc0:	00168693          	addi	a3,a3,1
    2bc4:	01069693          	slli	a3,a3,0x10
    2bc8:	0106d693          	srli	a3,a3,0x10
    2bcc:	fe96e0e3          	bltu	a3,s1,2bac <build_ack_common+0xc0>
    }
    ack[7U + payload_len] = (uint8_t)(crc >> 8);      /* CRC 高字节 */
    2bd0:	00748793          	addi	a5,s1,7
    2bd4:	00f907b3          	add	a5,s2,a5
    2bd8:	00855713          	srli	a4,a0,0x8
    2bdc:	00e78023          	sb	a4,0(a5)
    ack[8U + payload_len] = (uint8_t)(crc & 0xFFU);   /* CRC 低字节 */
    2be0:	00848793          	addi	a5,s1,8
    2be4:	00f907b3          	add	a5,s2,a5
    2be8:	00a78023          	sb	a0,0(a5)
    ack[9U + payload_len] = FRAME_FOOTER;             /* 帧尾 0xAA */
    2bec:	00948793          	addi	a5,s1,9
    2bf0:	00f90933          	add	s2,s2,a5
    2bf4:	faa00793          	li	a5,-86
    2bf8:	00f90023          	sb	a5,0(s2)

    return (uint16_t)(10U + payload_len);
    2bfc:	00a48513          	addi	a0,s1,10
}
    2c00:	01051513          	slli	a0,a0,0x10
    2c04:	01055513          	srli	a0,a0,0x10
    2c08:	02c12083          	lw	ra,44(sp)
    2c0c:	02812403          	lw	s0,40(sp)
    2c10:	02412483          	lw	s1,36(sp)
    2c14:	02012903          	lw	s2,32(sp)
    2c18:	01c12983          	lw	s3,28(sp)
    2c1c:	01812a03          	lw	s4,24(sp)
    2c20:	01412a83          	lw	s5,20(sp)
    2c24:	01012b03          	lw	s6,16(sp)
    2c28:	00c12b83          	lw	s7,12(sp)
    2c2c:	03010113          	addi	sp,sp,48
    2c30:	00008067          	ret

00002c34 <handler_ui_query_view>:
{
    2c34:	ff010113          	addi	sp,sp,-16
    2c38:	00112623          	sw	ra,12(sp)
    2c3c:	00812423          	sw	s0,8(sp)
    2c40:	00060413          	mv	s0,a2
    (void)ui_query_view(out);
    2c44:	00058513          	mv	a0,a1
    2c48:	024010ef          	jal	3c6c <ui_query_view>
    *out_len = UI_QUERY_PAYLOAD_LEN;
    2c4c:	00800793          	li	a5,8
    2c50:	00f41023          	sh	a5,0(s0)
}
    2c54:	0ff00513          	li	a0,255
    2c58:	00c12083          	lw	ra,12(sp)
    2c5c:	00812403          	lw	s0,8(sp)
    2c60:	01010113          	addi	sp,sp,16
    2c64:	00008067          	ret

00002c68 <handler_ui_set_image_values>:
{
    2c68:	ff010113          	addi	sp,sp,-16
    2c6c:	00112623          	sw	ra,12(sp)
    *out_len = 0U;
    2c70:	00061023          	sh	zero,0(a2)
    return (ui_set_image_values(frame->payload) == 0) ? PROTOCOL_STATUS_OK
    2c74:	00c50513          	addi	a0,a0,12
    2c78:	761000ef          	jal	3bd8 <ui_set_image_values>
                                                      : PROTOCOL_STATUS_FAIL;
    2c7c:	00050a63          	beqz	a0,2c90 <handler_ui_set_image_values+0x28>
    2c80:	00000513          	li	a0,0
}
    2c84:	00c12083          	lw	ra,12(sp)
    2c88:	01010113          	addi	sp,sp,16
    2c8c:	00008067          	ret
                                                      : PROTOCOL_STATUS_FAIL;
    2c90:	0ff00513          	li	a0,255
    2c94:	ff1ff06f          	j	2c84 <handler_ui_set_image_values+0x1c>

00002c98 <handler_ui_set_view>:
{
    2c98:	ff010113          	addi	sp,sp,-16
    2c9c:	00112623          	sw	ra,12(sp)
    *out_len = 0U;                    /* SET_VIEW 的应答是定长 10 字节 */
    2ca0:	00061023          	sh	zero,0(a2)
    page_id = (uint16_t)(((uint16_t)frame->payload[0] << 8) |
    2ca4:	00c54783          	lbu	a5,12(a0)
                          (uint16_t)frame->payload[1]);
    2ca8:	00d54703          	lbu	a4,13(a0)
    page_id = (uint16_t)(((uint16_t)frame->payload[0] << 8) |
    2cac:	00879793          	slli	a5,a5,0x8
    return (ui_set_view(page_id, sel, flags) == 0) ? PROTOCOL_STATUS_OK
    2cb0:	00f54603          	lbu	a2,15(a0)
    2cb4:	00e54583          	lbu	a1,14(a0)
    2cb8:	00f76533          	or	a0,a4,a5
    2cbc:	649000ef          	jal	3b04 <ui_set_view>
                                                   : PROTOCOL_STATUS_FAIL;
    2cc0:	00050a63          	beqz	a0,2cd4 <handler_ui_set_view+0x3c>
    2cc4:	00000513          	li	a0,0
}
    2cc8:	00c12083          	lw	ra,12(sp)
    2ccc:	01010113          	addi	sp,sp,16
    2cd0:	00008067          	ret
                                                   : PROTOCOL_STATUS_FAIL;
    2cd4:	0ff00513          	li	a0,255
    2cd8:	ff1ff06f          	j	2cc8 <handler_ui_set_view+0x30>

00002cdc <protocol_init>:
    if (stats == 0) {
    2cdc:	00050863          	beqz	a0,2cec <protocol_init+0x10>
    stats->accepted_count = 0U;
    2ce0:	00052023          	sw	zero,0(a0)
    stats->bad_packet_count = 0U;
    2ce4:	00052223          	sw	zero,4(a0)
    stats->other_category_count = 0U;
    2ce8:	00052423          	sw	zero,8(a0)
}
    2cec:	00008067          	ret

00002cf0 <protocol_build_ack>:

void protocol_build_ack(uint8_t *ack, uint8_t category, uint8_t command,
                        uint8_t status)
{
    if (ack == 0) {
    2cf0:	02050263          	beqz	a0,2d14 <protocol_build_ack+0x24>
{
    2cf4:	ff010113          	addi	sp,sp,-16
    2cf8:	00112623          	sw	ra,12(sp)
        return;
    }
    (void)build_ack_common(ack, category, command, status, 0, 0U);
    2cfc:	00000793          	li	a5,0
    2d00:	00000713          	li	a4,0
    2d04:	de9ff0ef          	jal	2aec <build_ack_common>
}
    2d08:	00c12083          	lw	ra,12(sp)
    2d0c:	01010113          	addi	sp,sp,16
    2d10:	00008067          	ret
    2d14:	00008067          	ret

00002d18 <protocol_build_ack_payload>:

uint16_t protocol_build_ack_payload(uint8_t *ack, uint8_t category, uint8_t command,
                                    uint8_t status, const uint8_t *payload,
                                    uint16_t payload_len)
{
    if (ack == 0) {
    2d18:	00050e63          	beqz	a0,2d34 <protocol_build_ack_payload+0x1c>
{
    2d1c:	ff010113          	addi	sp,sp,-16
    2d20:	00112623          	sw	ra,12(sp)
        return 0U;
    }
    return build_ack_common(ack, category, command, status, payload, payload_len);
    2d24:	dc9ff0ef          	jal	2aec <build_ack_common>
}
    2d28:	00c12083          	lw	ra,12(sp)
    2d2c:	01010113          	addi	sp,sp,16
    2d30:	00008067          	ret
        return 0U;
    2d34:	00000513          	li	a0,0
}
    2d38:	00008067          	ret

00002d3c <protocol_handle>:
*           子项确实是发给本端点的，只是本期不实现；计成坏包会让链路上真实
*           存在的工具帧把坏包率顶高）。
******************************************************************************/
void protocol_handle(protocol_stats_t *stats, const frame_t *frame,
                     protocol_response_t *response)
{
    2d3c:	fd010113          	addi	sp,sp,-48
    2d40:	02112623          	sw	ra,44(sp)
    const protocol_category_t *cat;
    const protocol_entry_t *entry;
    /* 应答体的参数段。8 字节是编译期常量（UI_QUERY_PAYLOAD_LEN），
     * 只有 QUERY_VIEW 会用到，其余子项 out_len 都是 0。*/
    uint8_t  out[UI_QUERY_PAYLOAD_LEN];
    uint16_t out_len = 0U;
    2d44:	00011323          	sh	zero,6(sp)

    if ((stats == 0) || (frame == 0) || (response == 0)) {
    2d48:	0c050e63          	beqz	a0,2e24 <protocol_handle+0xe8>
    2d4c:	02812423          	sw	s0,40(sp)
    2d50:	02912223          	sw	s1,36(sp)
    2d54:	03212023          	sw	s2,32(sp)
    2d58:	00050913          	mv	s2,a0
    2d5c:	00058493          	mv	s1,a1
    2d60:	00060413          	mv	s0,a2
    2d64:	20058263          	beqz	a1,2f68 <protocol_handle+0x22c>
    2d68:	20060863          	beqz	a2,2f78 <protocol_handle+0x23c>
    }

    /* 先给出默认结论：不发应答、失败、子项名未知。
     * 先把"最保守的默认值"铺好，后面每个分支只需要覆盖它要改的字段，
     * 这样就不会出现"某个分支漏填了某字段、结果带着上一次的残留值发出去"。*/
    response->send_ack = 0;
    2d6c:	000609a3          	sb	zero,19(a2)
    response->defer_ack = 0;
    2d70:	00060a23          	sb	zero,20(a2)
    response->status = PROTOCOL_STATUS_FAIL;
    2d74:	00060aa3          	sb	zero,21(a2)
    response->reason = PROTO_REASON_BAD_INTEGRITY;
    2d78:	00200793          	li	a5,2
    2d7c:	00f62c23          	sw	a5,24(a2)
    response->command_name = "?";
    2d80:	000047b7          	lui	a5,0x4
    2d84:	4f878793          	addi	a5,a5,1272 # 44f8 <_data+0x574>
    2d88:	00f62e23          	sw	a5,28(a2)
    response->ack_len = 0U;
    2d8c:	00060923          	sb	zero,18(a2)

    /* 第 1 关：完整性。CRC 或帧尾任一不对，就认为帧被破坏了。
     * 不应答——理由见函数头。*/
    if ((frame->crc_ok == 0U) || (frame->footer_ok == 0U)) {
    2d90:	0065c783          	lbu	a5,6(a1)
    2d94:	06078c63          	beqz	a5,2e0c <protocol_handle+0xd0>
    2d98:	0075c783          	lbu	a5,7(a1)
    2d9c:	06078863          	beqz	a5,2e0c <protocol_handle+0xd0>
    }

    /* 第 2 关：大类归属。不归本端点管的大类（电子变倍 0x01、热点 0x02、
     * 伪彩色 0x03）既不该执行也不该应答，只记一笔"收到过其它大类的帧"，
     * 便于诊断链路上都有谁在说话。*/
    cat = category_lookup(frame->category);
    2da0:	0005c503          	lbu	a0,0(a1)
    2da4:	c99ff0ef          	jal	2a3c <category_lookup>
    if (cat == 0) {
    2da8:	08050463          	beqz	a0,2e30 <protocol_handle+0xf4>
        return;
    }

    /* 从这一步起，帧确定是本端点的了：**默认每一个都会得到应答**。
     * 唯一的例外是 UI 的 0x01–0x05，它们在下面第 6 关把 send_ack 改回 0。*/
    response->send_ack = 1;
    2dac:	00100793          	li	a5,1
    2db0:	00f409a3          	sb	a5,19(s0)

    /* 第 3 关：类型字段必须是"上位机写"。*/
    if (frame->format_ok == 0U) {
    2db4:	0084c783          	lbu	a5,8(s1)
    2db8:	08079e63          	bnez	a5,2e54 <protocol_handle+0x118>
        response->reason = PROTO_REASON_BAD_FORMAT;
    2dbc:	00300793          	li	a5,3
    2dc0:	00f42c23          	sw	a5,24(s0)
        stats->bad_packet_count++;
    2dc4:	00492783          	lw	a5,4(s2)
    2dc8:	00178793          	addi	a5,a5,1
    2dcc:	00f92223          	sw	a5,4(s2)
    /* 构造应答。只有"大类归本端点、完整性通过、且该子项要应答"才需要发。
     * 大类和子项原样回显，这样上位机能按自己发过的命令去核对。
     *
     * 参数段为空时走定长 10 字节那一支 —— 两条路都落到同一个 build_ack_common，
     * 所以 CRC 覆盖范围与字节序只有一处实现。*/
    if (response->send_ack != 0) {
    2dd0:	01344783          	lbu	a5,19(s0)
    2dd4:	1a078a63          	beqz	a5,2f88 <protocol_handle+0x24c>
        if (out_len == 0U) {
    2dd8:	00615783          	lhu	a5,6(sp)
    2ddc:	16079063          	bnez	a5,2f3c <protocol_handle+0x200>
            protocol_build_ack(response->ack, frame->category, frame->command,
    2de0:	01544683          	lbu	a3,21(s0)
    2de4:	0014c603          	lbu	a2,1(s1)
    2de8:	0004c583          	lbu	a1,0(s1)
    2dec:	00040513          	mv	a0,s0
    2df0:	f01ff0ef          	jal	2cf0 <protocol_build_ack>
                               response->status);
            response->ack_len = PROTOCOL_ACK_LEN;
    2df4:	00a00793          	li	a5,10
    2df8:	00f40923          	sb	a5,18(s0)
    2dfc:	02812403          	lw	s0,40(sp)
    2e00:	02412483          	lw	s1,36(sp)
    2e04:	02012903          	lw	s2,32(sp)
    2e08:	01c0006f          	j	2e24 <protocol_handle+0xe8>
        stats->bad_packet_count++;
    2e0c:	00492783          	lw	a5,4(s2)
    2e10:	00178793          	addi	a5,a5,1
    2e14:	00f92223          	sw	a5,4(s2)
        return;
    2e18:	02812403          	lw	s0,40(sp)
    2e1c:	02412483          	lw	s1,36(sp)
    2e20:	02012903          	lw	s2,32(sp)
            response->ack_len = (uint8_t)protocol_build_ack_payload(
                response->ack, frame->category, frame->command,
                response->status, out, out_len);
        }
    }
}
    2e24:	02c12083          	lw	ra,44(sp)
    2e28:	03010113          	addi	sp,sp,48
    2e2c:	00008067          	ret
        response->reason = PROTO_REASON_OTHER_CATEGORY;
    2e30:	00100793          	li	a5,1
    2e34:	00f42c23          	sw	a5,24(s0)
        stats->other_category_count++;
    2e38:	00892783          	lw	a5,8(s2)
    2e3c:	00178793          	addi	a5,a5,1
    2e40:	00f92423          	sw	a5,8(s2)
        return;
    2e44:	02812403          	lw	s0,40(sp)
    2e48:	02412483          	lw	s1,36(sp)
    2e4c:	02012903          	lw	s2,32(sp)
    2e50:	fd5ff06f          	j	2e24 <protocol_handle+0xe8>
    2e54:	01312e23          	sw	s3,28(sp)
        entry = table_lookup(cat, frame->command);
    2e58:	0014c583          	lbu	a1,1(s1)
    2e5c:	c2dff0ef          	jal	2a88 <table_lookup>
    2e60:	00050993          	mv	s3,a0
        if (entry == 0) {
    2e64:	02050a63          	beqz	a0,2e98 <protocol_handle+0x15c>
            response->command_name = entry->name;
    2e68:	00852783          	lw	a5,8(a0)
    2e6c:	00f42e23          	sw	a5,28(s0)
            if (entry_length_ok(entry, frame->body_length) == 0) {
    2e70:	0044d583          	lhu	a1,4(s1)
    2e74:	c4dff0ef          	jal	2ac0 <entry_length_ok>
    2e78:	02051e63          	bnez	a0,2eb4 <protocol_handle+0x178>
                response->reason = PROTO_REASON_BAD_LENGTH;
    2e7c:	00500793          	li	a5,5
    2e80:	00f42c23          	sw	a5,24(s0)
                stats->bad_packet_count++;
    2e84:	00492783          	lw	a5,4(s2)
    2e88:	00178793          	addi	a5,a5,1
    2e8c:	00f92223          	sw	a5,4(s2)
    2e90:	01c12983          	lw	s3,28(sp)
    2e94:	f3dff06f          	j	2dd0 <protocol_handle+0x94>
            response->reason = PROTO_REASON_UNKNOWN_COMMAND;
    2e98:	00400793          	li	a5,4
    2e9c:	00f42c23          	sw	a5,24(s0)
            stats->bad_packet_count++;
    2ea0:	00492783          	lw	a5,4(s2)
    2ea4:	00178793          	addi	a5,a5,1
    2ea8:	00f92223          	sw	a5,4(s2)
    2eac:	01c12983          	lw	s3,28(sp)
    2eb0:	f21ff06f          	j	2dd0 <protocol_handle+0x94>
            } else if (entry->reply == 0U) {
    2eb4:	0069c783          	lbu	a5,6(s3)
    2eb8:	02079063          	bnez	a5,2ed8 <protocol_handle+0x19c>
                response->send_ack = 0;
    2ebc:	000409a3          	sb	zero,19(s0)
                response->reason = PROTO_REASON_UI_IGNORED;
    2ec0:	00700793          	li	a5,7
    2ec4:	00f42c23          	sw	a5,24(s0)
                response->command_name = entry->name;
    2ec8:	0089a783          	lw	a5,8(s3)
    2ecc:	00f42e23          	sw	a5,28(s0)
    2ed0:	01c12983          	lw	s3,28(sp)
    2ed4:	efdff06f          	j	2dd0 <protocol_handle+0x94>
                stats->accepted_count++;
    2ed8:	00092783          	lw	a5,0(s2)
    2edc:	00178793          	addi	a5,a5,1
    2ee0:	00f92023          	sw	a5,0(s2)
                response->status = entry->handler(frame, out, &out_len);
    2ee4:	00c9a783          	lw	a5,12(s3)
    2ee8:	00610613          	addi	a2,sp,6
    2eec:	00810593          	addi	a1,sp,8
    2ef0:	00048513          	mv	a0,s1
    2ef4:	000780e7          	jalr	a5
    2ef8:	00a40aa3          	sb	a0,21(s0)
                if (response->status == PROTOCOL_STATUS_OK) {
    2efc:	0ff00793          	li	a5,255
    2f00:	00f50a63          	beq	a0,a5,2f14 <protocol_handle+0x1d8>
                    response->reason = PROTO_REASON_NOT_IMPLEMENTED;
    2f04:	00600793          	li	a5,6
    2f08:	00f42c23          	sw	a5,24(s0)
    2f0c:	01c12983          	lw	s3,28(sp)
    2f10:	ec1ff06f          	j	2dd0 <protocol_handle+0x94>
                    response->reason = PROTO_REASON_OK;
    2f14:	00042c23          	sw	zero,24(s0)
                    response->defer_ack = entry->defer;
    2f18:	0079c783          	lbu	a5,7(s3)
    2f1c:	00f40a23          	sb	a5,20(s0)
                    if (entry->defer != 0U) {
    2f20:	00078a63          	beqz	a5,2f34 <protocol_handle+0x1f8>
                        response->reason = PROTO_REASON_DEFERRED;
    2f24:	00800793          	li	a5,8
    2f28:	00f42c23          	sw	a5,24(s0)
    2f2c:	01c12983          	lw	s3,28(sp)
    2f30:	ea1ff06f          	j	2dd0 <protocol_handle+0x94>
    2f34:	01c12983          	lw	s3,28(sp)
    2f38:	e99ff06f          	j	2dd0 <protocol_handle+0x94>
            response->ack_len = (uint8_t)protocol_build_ack_payload(
    2f3c:	00810713          	addi	a4,sp,8
    2f40:	01544683          	lbu	a3,21(s0)
    2f44:	0014c603          	lbu	a2,1(s1)
    2f48:	0004c583          	lbu	a1,0(s1)
    2f4c:	00040513          	mv	a0,s0
    2f50:	dc9ff0ef          	jal	2d18 <protocol_build_ack_payload>
    2f54:	00a40923          	sb	a0,18(s0)
    2f58:	02812403          	lw	s0,40(sp)
    2f5c:	02412483          	lw	s1,36(sp)
    2f60:	02012903          	lw	s2,32(sp)
    2f64:	ec1ff06f          	j	2e24 <protocol_handle+0xe8>
    2f68:	02812403          	lw	s0,40(sp)
    2f6c:	02412483          	lw	s1,36(sp)
    2f70:	02012903          	lw	s2,32(sp)
    2f74:	eb1ff06f          	j	2e24 <protocol_handle+0xe8>
    2f78:	02812403          	lw	s0,40(sp)
    2f7c:	02412483          	lw	s1,36(sp)
    2f80:	02012903          	lw	s2,32(sp)
    2f84:	ea1ff06f          	j	2e24 <protocol_handle+0xe8>
    2f88:	02812403          	lw	s0,40(sp)
    2f8c:	02412483          	lw	s1,36(sp)
    2f90:	02012903          	lw	s2,32(sp)
    2f94:	e91ff06f          	j	2e24 <protocol_handle+0xe8>

00002f98 <reg_write>:
* @note volatile 不能省：这几条写是**有副作用**的（RTL 侧会据此改行为），
*       没有 volatile 编译器有权把它们优化掉或合并。
******************************************************************************/
static void reg_write(uint32_t off, uint32_t val)
{
    *(volatile uint32_t *)(OSD_REG_BASE + off) = val;
    2f98:	e10437b7          	lui	a5,0xe1043
    2f9c:	00f50533          	add	a0,a0,a5
    2fa0:	00b52023          	sw	a1,0(a0)
}
    2fa4:	00008067          	ret

00002fa8 <reg_read>:
* @note 同样要 volatile：地址里的值会被 RTL 随时改动（applied_* 在帧边界更新），
*       没有 volatile 编译器可以把两次读合并成一次。
******************************************************************************/
static uint32_t reg_read(uint32_t off)
{
    return *(volatile uint32_t *)(OSD_REG_BASE + off);
    2fa8:	e10437b7          	lui	a5,0xe1043
    2fac:	00f50533          	add	a0,a0,a5
    2fb0:	00052503          	lw	a0,0(a0)
}
    2fb4:	00008067          	ret

00002fb8 <canvas_select_block>:

void canvas_select_block(int idx) { s_block = (idx == 1) ? 1 : 0; }
    2fb8:	fff50513          	addi	a0,a0,-1
    2fbc:	00153513          	seqz	a0,a0
    2fc0:	88a1a423          	sw	a0,-1912(gp) # 5830 <s_block>
    2fc4:	00008067          	ret

00002fc8 <canvas_set_visible>:

void canvas_set_visible(int on) { s_visible = (on != 0) ? 1 : 0; }
    2fc8:	00a03533          	snez	a0,a0
    2fcc:	88a1a223          	sw	a0,-1916(gp) # 582c <s_visible>
    2fd0:	00008067          	ret

00002fd4 <canvas_write>:
*       也是 RTL 侧按字节读回时看到的顺序。写反了画面会变成每 4 个像素
*       一组错位 —— 这种错在"看起来像图像噪声"里最难认。
******************************************************************************/
void canvas_write(uint32_t off, const uint8_t *src, uint32_t len)
{
    volatile uint8_t *dst = (volatile uint8_t *)((s_block ? OSD_BLOCK1_ADDR
    2fd4:	8881a783          	lw	a5,-1912(gp) # 5830 <s_block>
                                                          : OSD_BLOCK0_ADDR) + off);
    2fd8:	02078663          	beqz	a5,3004 <canvas_write+0x30>
    2fdc:	00b40837          	lui	a6,0xb40
    2fe0:	00a80833          	add	a6,a6,a0
    uint32_t i = 0U;

    if (src == 0) {
    2fe4:	08058263          	beqz	a1,3068 <canvas_write+0x94>
        return;
    }

    s_bytes_written += len;
    2fe8:	8781a783          	lw	a5,-1928(gp) # 5820 <s_bytes_written>
    2fec:	00c787b3          	add	a5,a5,a2
    2ff0:	86f1ac23          	sw	a5,-1928(gp) # 5820 <s_bytes_written>

    if ((off & 3U) == 0U) {
    2ff4:	00357513          	andi	a0,a0,3
    2ff8:	00050a63          	beqz	a0,300c <canvas_write+0x38>
    uint32_t i = 0U;
    2ffc:	00000513          	li	a0,0
    3000:	0640006f          	j	3064 <canvas_write+0x90>
                                                          : OSD_BLOCK0_ADDR) + off);
    3004:	00a40837          	lui	a6,0xa40
    3008:	fd9ff06f          	j	2fe0 <canvas_write+0xc>
        for (; i + 4U <= len; i += 4U) {
    300c:	00450893          	addi	a7,a0,4
    3010:	05166a63          	bltu	a2,a7,3064 <canvas_write+0x90>
            uint32_t w = (uint32_t)src[i]
    3014:	00a58733          	add	a4,a1,a0
    3018:	00074783          	lbu	a5,0(a4)
                       | ((uint32_t)src[i + 1U] << 8)
    301c:	00174683          	lbu	a3,1(a4)
    3020:	00869693          	slli	a3,a3,0x8
    3024:	00d7e7b3          	or	a5,a5,a3
                       | ((uint32_t)src[i + 2U] << 16)
    3028:	00274683          	lbu	a3,2(a4)
    302c:	01069693          	slli	a3,a3,0x10
    3030:	00d7e7b3          	or	a5,a5,a3
                       | ((uint32_t)src[i + 3U] << 24);
    3034:	00374703          	lbu	a4,3(a4)
    3038:	01871713          	slli	a4,a4,0x18
            uint32_t w = (uint32_t)src[i]
    303c:	00e7e7b3          	or	a5,a5,a4
            *(volatile uint32_t *)(dst + i) = w;
    3040:	00a80533          	add	a0,a6,a0
    3044:	00f52023          	sw	a5,0(a0)
        for (; i + 4U <= len; i += 4U) {
    3048:	00088513          	mv	a0,a7
    304c:	fc1ff06f          	j	300c <canvas_write+0x38>
        }
    }
    for (; i < len; i++) {
        dst[i] = src[i];
    3050:	00a807b3          	add	a5,a6,a0
    3054:	00a58733          	add	a4,a1,a0
    3058:	00074703          	lbu	a4,0(a4)
    305c:	00e78023          	sb	a4,0(a5) # e1043000 <__freertos_irq_stack_top+0xe103a240>
    for (; i < len; i++) {
    3060:	00150513          	addi	a0,a0,1
    3064:	fec566e3          	bltu	a0,a2,3050 <canvas_write+0x7c>
    }
}
    3068:	00008067          	ret

0000306c <canvas_fill>:
*
 * @note 清屏是 7,072 字节 × 2 块，走整字能把事务数从 14,144 降到 3,536。
******************************************************************************/
void canvas_fill(uint32_t off, uint8_t v, uint32_t len)
{
    volatile uint8_t *dst = (volatile uint8_t *)((s_block ? OSD_BLOCK1_ADDR
    306c:	8881a783          	lw	a5,-1912(gp) # 5830 <s_block>
                                                          : OSD_BLOCK0_ADDR) + off);
    3070:	02078463          	beqz	a5,3098 <canvas_fill+0x2c>
    3074:	00b40737          	lui	a4,0xb40
    3078:	00a70733          	add	a4,a4,a0
    uint32_t i = 0U;

    s_bytes_written += len;
    307c:	8781a783          	lw	a5,-1928(gp) # 5820 <s_bytes_written>
    3080:	00c787b3          	add	a5,a5,a2
    3084:	86f1ac23          	sw	a5,-1928(gp) # 5820 <s_bytes_written>

    if ((off & 3U) == 0U) {
    3088:	00357513          	andi	a0,a0,3
    308c:	00050a63          	beqz	a0,30a0 <canvas_fill+0x34>
    uint32_t i = 0U;
    3090:	00000513          	li	a0,0
    3094:	0480006f          	j	30dc <canvas_fill+0x70>
                                                          : OSD_BLOCK0_ADDR) + off);
    3098:	00a40737          	lui	a4,0xa40
    309c:	fddff06f          	j	3078 <canvas_fill+0xc>
        uint32_t pat = (uint32_t)v | ((uint32_t)v << 8)
    30a0:	00859693          	slli	a3,a1,0x8
    30a4:	00b686b3          	add	a3,a3,a1
                     | ((uint32_t)v << 16) | ((uint32_t)v << 24);
    30a8:	01059793          	slli	a5,a1,0x10
    30ac:	00f6e6b3          	or	a3,a3,a5
    30b0:	01859793          	slli	a5,a1,0x18
        uint32_t pat = (uint32_t)v | ((uint32_t)v << 8)
    30b4:	00f6e6b3          	or	a3,a3,a5
        for (; i + 4U <= len; i += 4U) {
    30b8:	00450793          	addi	a5,a0,4
    30bc:	02f66063          	bltu	a2,a5,30dc <canvas_fill+0x70>
            *(volatile uint32_t *)(dst + i) = pat;
    30c0:	00a70533          	add	a0,a4,a0
    30c4:	00d52023          	sw	a3,0(a0)
        for (; i + 4U <= len; i += 4U) {
    30c8:	00078513          	mv	a0,a5
    30cc:	fedff06f          	j	30b8 <canvas_fill+0x4c>
        }
    }
    for (; i < len; i++) {
        dst[i] = v;
    30d0:	00a707b3          	add	a5,a4,a0
    30d4:	00b78023          	sb	a1,0(a5)
    for (; i < len; i++) {
    30d8:	00150513          	addi	a0,a0,1
    30dc:	fec56ae3          	bltu	a0,a2,30d0 <canvas_fill+0x64>
    }
}
    30e0:	00008067          	ret

000030e4 <canvas_commit>:
* @note 提交是"置位即返回"，不等 pending 清、不读 ack：RTL 在帧边界整体切换。
*       要确认生效就读 STATUS 的 pending 位（本工程目前不需要，
*       因为下一步操作都在帧率尺度之外）。
******************************************************************************/
void canvas_commit(void)
{
    30e4:	ff010113          	addi	sp,sp,-16
    30e8:	00112623          	sw	ra,12(sp)
    30ec:	00812423          	sw	s0,8(sp)
    uint32_t ctrl = (s_visible ? OSD_CTRL_ENABLE : 0U)
    30f0:	8841a783          	lw	a5,-1916(gp) # 582c <s_visible>
    30f4:	04078e63          	beqz	a5,3150 <canvas_commit+0x6c>
    30f8:	00100413          	li	s0,1
                  | (s_block   ? OSD_CTRL_BUFFER : 0U);
    30fc:	8881a783          	lw	a5,-1912(gp) # 5830 <s_block>
    3100:	04078c63          	beqz	a5,3158 <canvas_commit+0x74>
    3104:	00200793          	li	a5,2
    uint32_t ctrl = (s_visible ? OSD_CTRL_ENABLE : 0U)
    3108:	00f46433          	or	s0,s0,a5
    uint32_t pos = ((uint32_t)((uint32_t)OSD_MENU_TOP & 0xFFFU) << 12)
                 |  (uint32_t)((uint32_t)OSD_MENU_LEFT & 0xFFFU);

    /* 先记下这一组值再写下去：POS/CTRL 只写、回读恒 0，事后想看"写了什么"
     * 就只有这一份记录（见 canvas_read_regs）。*/
    s_pos_written  = pos;
    310c:	000805b7          	lui	a1,0x80
    3110:	02058593          	addi	a1,a1,32 # 80020 <__freertos_irq_stack_top+0x77260>
    3114:	88b1a023          	sw	a1,-1920(gp) # 5828 <s_pos_written>
    s_ctrl_written = ctrl;
    3118:	8681ae23          	sw	s0,-1924(gp) # 5824 <s_ctrl_written>

    reg_write(OSD_REG_POS(OSD_MENU_ROUTE), pos);
    311c:	01800513          	li	a0,24
    3120:	e79ff0ef          	jal	2f98 <reg_write>
    reg_write(OSD_REG_CTRL(OSD_MENU_ROUTE), ctrl);
    3124:	00040593          	mv	a1,s0
    3128:	01c00513          	li	a0,28
    312c:	e6dff0ef          	jal	2f98 <reg_write>
    reg_write(OSD_REG_COMMAND, OSD_CMD_COMMIT | OSD_CMD_GLOBAL_EN);
    3130:	800005b7          	lui	a1,0x80000
    3134:	00158593          	addi	a1,a1,1 # 80000001 <__freertos_irq_stack_top+0x7fff7241>
    3138:	00000513          	li	a0,0
    313c:	e5dff0ef          	jal	2f98 <reg_write>
}
    3140:	00c12083          	lw	ra,12(sp)
    3144:	00812403          	lw	s0,8(sp)
    3148:	01010113          	addi	sp,sp,16
    314c:	00008067          	ret
    uint32_t ctrl = (s_visible ? OSD_CTRL_ENABLE : 0U)
    3150:	00000413          	li	s0,0
    3154:	fa9ff06f          	j	30fc <canvas_commit+0x18>
                  | (s_block   ? OSD_CTRL_BUFFER : 0U);
    3158:	00000793          	li	a5,0
    315c:	fadff06f          	j	3108 <canvas_commit+0x24>

00003160 <canvas_read_regs>:
*       POS/CTRL 也照读一遍并保留在结构体里：它们的值应当恒为 0，打出来
*       正是为了证明"只写"这件事在板级也成立。
******************************************************************************/
void canvas_read_regs(canvas_regs_t *out)
{
    if (out == 0) {
    3160:	06050e63          	beqz	a0,31dc <canvas_read_regs+0x7c>
{
    3164:	ff010113          	addi	sp,sp,-16
    3168:	00112623          	sw	ra,12(sp)
    316c:	00812423          	sw	s0,8(sp)
    3170:	00050413          	mv	s0,a0
        return;
    }

    out->command   = reg_read(OSD_REG_COMMAND);
    3174:	00000513          	li	a0,0
    3178:	e31ff0ef          	jal	2fa8 <reg_read>
    317c:	00a42023          	sw	a0,0(s0)
    out->status    = reg_read(OSD_REG_STATUS);
    3180:	00400513          	li	a0,4
    3184:	e25ff0ef          	jal	2fa8 <reg_read>
    3188:	00a42223          	sw	a0,4(s0)
    out->canvas    = reg_read(OSD_REG_CANVAS);
    318c:	00800513          	li	a0,8
    3190:	e19ff0ef          	jal	2fa8 <reg_read>
    3194:	00a42423          	sw	a0,8(s0)
    out->active    = reg_read(OSD_REG_ACTIVE);
    3198:	00c00513          	li	a0,12
    319c:	e0dff0ef          	jal	2fa8 <reg_read>
    31a0:	00a42623          	sw	a0,12(s0)
    out->pos_read  = reg_read(OSD_REG_POS(OSD_MENU_ROUTE));
    31a4:	01800513          	li	a0,24
    31a8:	e01ff0ef          	jal	2fa8 <reg_read>
    31ac:	00a42823          	sw	a0,16(s0)
    out->ctrl_read = reg_read(OSD_REG_CTRL(OSD_MENU_ROUTE));
    31b0:	01c00513          	li	a0,28
    31b4:	df5ff0ef          	jal	2fa8 <reg_read>
    31b8:	00a42a23          	sw	a0,20(s0)
    out->pos_last  = s_pos_written;
    31bc:	8801a783          	lw	a5,-1920(gp) # 5828 <s_pos_written>
    31c0:	00f42c23          	sw	a5,24(s0)
    out->ctrl_last = s_ctrl_written;
    31c4:	87c1a783          	lw	a5,-1924(gp) # 5824 <s_ctrl_written>
    31c8:	00f42e23          	sw	a5,28(s0)
}
    31cc:	00c12083          	lw	ra,12(sp)
    31d0:	00812403          	lw	s0,8(sp)
    31d4:	01010113          	addi	sp,sp,16
    31d8:	00008067          	ret
    31dc:	00008067          	ret

000031e0 <canvas_read_block>:
*       读时也按这个顺序拆回去。写读不对称的话回读出来的图会每 4 字节一组
*       错位，而那种错在缩略图上表现为"整块花纹"、极难反推。
******************************************************************************/
uint32_t canvas_read_block(int idx, uint8_t *dst)
{
    volatile const uint32_t *src = (volatile const uint32_t *)
    31e0:	00100793          	li	a5,1
    31e4:	00f50a63          	beq	a0,a5,31f8 <canvas_read_block+0x18>
    31e8:	00a40837          	lui	a6,0xa40
        ((idx == 1) ? OSD_BLOCK1_ADDR : OSD_BLOCK0_ADDR);
    uint32_t i = 0U;

    if (dst == 0) {
    31ec:	08058e63          	beqz	a1,3288 <canvas_read_block+0xa8>
    uint32_t i = 0U;
    31f0:	00000793          	li	a5,0
    31f4:	0540006f          	j	3248 <canvas_read_block+0x68>
    volatile const uint32_t *src = (volatile const uint32_t *)
    31f8:	00b40837          	lui	a6,0xb40
    31fc:	ff1ff06f          	j	31ec <canvas_read_block+0xc>
        return 0U;
    }

    for (; i + 4U <= (uint32_t)OSD_BLOCK_BYTES; i += 4U) {
        uint32_t w = src[i >> 2];
    3200:	ffc7f713          	andi	a4,a5,-4
    3204:	00e80733          	add	a4,a6,a4
    3208:	00072703          	lw	a4,0(a4) # a40000 <__freertos_irq_stack_top+0xa37240>
        dst[i]      = (uint8_t)(w & 0xFFU);
    320c:	00f586b3          	add	a3,a1,a5
    3210:	00e68023          	sb	a4,0(a3)
        dst[i + 1U] = (uint8_t)((w >> 8) & 0xFFU);
    3214:	00875513          	srli	a0,a4,0x8
    3218:	00178693          	addi	a3,a5,1
    321c:	00d586b3          	add	a3,a1,a3
    3220:	00a68023          	sb	a0,0(a3)
        dst[i + 2U] = (uint8_t)((w >> 16) & 0xFFU);
    3224:	01075513          	srli	a0,a4,0x10
    3228:	00278693          	addi	a3,a5,2
    322c:	00d586b3          	add	a3,a1,a3
    3230:	00a68023          	sb	a0,0(a3)
        dst[i + 3U] = (uint8_t)((w >> 24) & 0xFFU);
    3234:	00378793          	addi	a5,a5,3
    3238:	00f587b3          	add	a5,a1,a5
    323c:	01875713          	srli	a4,a4,0x18
    3240:	00e78023          	sb	a4,0(a5)
    for (; i + 4U <= (uint32_t)OSD_BLOCK_BYTES; i += 4U) {
    3244:	00060793          	mv	a5,a2
    3248:	00478613          	addi	a2,a5,4
    324c:	00002737          	lui	a4,0x2
    3250:	ba070713          	addi	a4,a4,-1120 # 1ba0 <diag_dump_regs+0xf8>
    3254:	fac776e3          	bgeu	a4,a2,3200 <canvas_read_block+0x20>
    3258:	0180006f          	j	3270 <canvas_read_block+0x90>
    }
    for (; i < (uint32_t)OSD_BLOCK_BYTES; i++) {
        dst[i] = ((volatile const uint8_t *)src)[i];
    325c:	00f806b3          	add	a3,a6,a5
    3260:	00f58733          	add	a4,a1,a5
    3264:	0006c683          	lbu	a3,0(a3)
    3268:	00d70023          	sb	a3,0(a4)
    for (; i < (uint32_t)OSD_BLOCK_BYTES; i++) {
    326c:	00178793          	addi	a5,a5,1
    3270:	00002737          	lui	a4,0x2
    3274:	b9f70713          	addi	a4,a4,-1121 # 1b9f <diag_dump_regs+0xf7>
    3278:	fef772e3          	bgeu	a4,a5,325c <canvas_read_block+0x7c>
    }

    return (uint32_t)OSD_BLOCK_BYTES;
    327c:	00002537          	lui	a0,0x2
    3280:	ba050513          	addi	a0,a0,-1120 # 1ba0 <diag_dump_regs+0xf8>
    3284:	00008067          	ret
        return 0U;
    3288:	00000513          	li	a0,0
}
    328c:	00008067          	ret

00003290 <canvas_peek>:
 * 诊断专用的裸访问与计数
 * ------------------------------------------------------------------------ */

uint32_t canvas_peek(uint32_t addr)
{
    return *(volatile uint32_t *)addr;
    3290:	00052503          	lw	a0,0(a0)
}
    3294:	00008067          	ret

00003298 <canvas_poke>:
*       若有偏移也不会影响结论 —— 偏移会同时作用于写与读、往返照样成立；
*       往返**不成立**就说明写根本没落到那个位置（或读根本读不到）。
******************************************************************************/
uint32_t canvas_poke(uint32_t addr, uint32_t val)
{
    *(volatile uint32_t *)addr = val;
    3298:	00b52023          	sw	a1,0(a0)
    return *(volatile uint32_t *)addr;
    329c:	00052503          	lw	a0,0(a0)
}
    32a0:	00008067          	ret

000032a4 <canvas_bytes_written>:

uint32_t canvas_bytes_written(void)
{
    return s_bytes_written;
}
    32a4:	8781a503          	lw	a0,-1928(gp) # 5820 <s_bytes_written>
    32a8:	00008067          	ret

000032ac <render_and_commit>:
*         3) 渲染 —— 把字符网格（第 0 步的产物）展开成 1 bit/像素位图。
*         4) 提交 —— 置位后立即返回，由 RTL 在帧边界整体切换。
*       之后翻转后台块，下一次写另一块。
******************************************************************************/
static void render_and_commit(void)
{
    32ac:	ff010113          	addi	sp,sp,-16
    32b0:	00112623          	sw	ra,12(sp)
    32b4:	00812423          	sw	s0,8(sp)
    /* 第 0 步：状态 → 字符网格。少了它 composer 画的是一张空白网格
     * （见上面第 0 条的说明）。放在这里而不是各个调用点，是为了让
     * "凡是渲染，网格一定是最新的"成为结构性保证，而不是纪律。*/
    scene_build();
    32b8:	239000ef          	jal	3cf0 <scene_build>

    canvas_set_visible(ui_is_visible());   /* 见上：必须排在 commit 之前 */
    32bc:	201000ef          	jal	3cbc <ui_is_visible>
    32c0:	d09ff0ef          	jal	2fc8 <canvas_set_visible>
    canvas_select_block(s_back);
    32c4:	8941a503          	lw	a0,-1900(gp) # 583c <s_back>
    32c8:	cf1ff0ef          	jal	2fb8 <canvas_select_block>
    composer_render();
    32cc:	128000ef          	jal	33f4 <composer_render>
    canvas_commit();
    32d0:	e15ff0ef          	jal	30e4 <canvas_commit>

    s_back ^= 1;
    32d4:	8941a783          	lw	a5,-1900(gp) # 583c <s_back>
    32d8:	0017c793          	xori	a5,a5,1
    32dc:	88f1aa23          	sw	a5,-1900(gp) # 583c <s_back>
    s_renders++;
    32e0:	8901a783          	lw	a5,-1904(gp) # 5838 <s_renders>
    32e4:	00178793          	addi	a5,a5,1
    32e8:	88f1a823          	sw	a5,-1904(gp) # 5838 <s_renders>
    ui_clear_dirty();
    32ec:	1f5000ef          	jal	3ce0 <ui_clear_dirty>
}
    32f0:	00c12083          	lw	ra,12(sp)
    32f4:	00812403          	lw	s0,8(sp)
    32f8:	01010113          	addi	sp,sp,16
    32fc:	00008067          	ret

00003300 <osd_engine_boot>:

void osd_engine_boot(void)
{
    3300:	ff010113          	addi	sp,sp,-16
    3304:	00112623          	sw	ra,12(sp)
    ui_init();
    3308:	7a8000ef          	jal	3ab0 <ui_init>

    /* 两块都清零：位图是透明底，只清一块的话另一块上前台时会露出旧内容。 */
    canvas_select_block(0);
    330c:	00000513          	li	a0,0
    3310:	ca9ff0ef          	jal	2fb8 <canvas_select_block>
    canvas_fill(0U, 0U, (uint32_t)OSD_BLOCK_BYTES);
    3314:	00002637          	lui	a2,0x2
    3318:	ba060613          	addi	a2,a2,-1120 # 1ba0 <diag_dump_regs+0xf8>
    331c:	00000593          	li	a1,0
    3320:	00000513          	li	a0,0
    3324:	d49ff0ef          	jal	306c <canvas_fill>
    canvas_select_block(1);
    3328:	00100513          	li	a0,1
    332c:	c8dff0ef          	jal	2fb8 <canvas_select_block>
    canvas_fill(0U, 0U, (uint32_t)OSD_BLOCK_BYTES);
    3330:	00002637          	lui	a2,0x2
    3334:	ba060613          	addi	a2,a2,-1120 # 1ba0 <diag_dump_regs+0xf8>
    3338:	00000593          	li	a1,0
    333c:	00000513          	li	a0,0
    3340:	d2dff0ef          	jal	306c <canvas_fill>

    s_back = 0;
    3344:	8801aa23          	sw	zero,-1900(gp) # 583c <s_back>
    s_renders = 0;
    3348:	8801a823          	sw	zero,-1904(gp) # 5838 <s_renders>
    s_last_deferred = 0;
    334c:	8801a623          	sw	zero,-1908(gp) # 5834 <s_last_deferred>
    render_and_commit();            /* 上电即有画面（P1 主菜单） */
    3350:	f5dff0ef          	jal	32ac <render_and_commit>
}
    3354:	00c12083          	lw	ra,12(sp)
    3358:	01010113          	addi	sp,sp,16
    335c:	00008067          	ret

00003360 <osd_engine_handle>:

uint8_t osd_engine_handle(protocol_stats_t *stats, const frame_t *frame,
                          protocol_response_t *resp, uint8_t *ack)
{
    3360:	ff010113          	addi	sp,sp,-16
    3364:	00112623          	sw	ra,12(sp)
    3368:	00812423          	sw	s0,8(sp)
    336c:	00912223          	sw	s1,4(sp)
    3370:	00060413          	mv	s0,a2
    3374:	00068493          	mv	s1,a3
    uint8_t n;

    s_last_deferred = 0;
    3378:	8801a623          	sw	zero,-1908(gp) # 5834 <s_last_deferred>

    protocol_handle(stats, frame, resp);
    337c:	9c1ff0ef          	jal	2d3c <protocol_handle>
    if ((resp->send_ack == 0U) || (ack == 0)) {
    3380:	01344503          	lbu	a0,19(s0)
    3384:	04050a63          	beqz	a0,33d8 <osd_engine_handle+0x78>
    3388:	06048263          	beqz	s1,33ec <osd_engine_handle+0x8c>
        return 0U;
    }

    if (resp->defer_ack != 0U) {
    338c:	01444783          	lbu	a5,20(s0)
    3390:	00078e63          	beqz	a5,33ac <osd_engine_handle+0x4c>
        /* 成功且需要等画布：先把画面做出来、提交掉，再把应答交出去。
         * 失败时 handler 返回 FAIL，defer_ack 为 0，直接走下面那支立即回。 */
        render_and_commit();
    3394:	f19ff0ef          	jal	32ac <render_and_commit>
        s_last_deferred = 1;
    3398:	00100713          	li	a4,1
    339c:	88e1a623          	sw	a4,-1908(gp) # 5834 <s_last_deferred>
         * 触发；留着它是为了让"状态脏了就渲染"这条不变量在引擎层始终成立，
         * 将来加一条"改了状态但不要求延迟应答"的命令时不会静默丢一帧。*/
        render_and_commit();
    }

    n = resp->ack_len;
    33a0:	01244503          	lbu	a0,18(s0)
    {
        uint8_t i;
        for (i = 0U; i < n; i++) {
    33a4:	00000793          	li	a5,0
    33a8:	02c0006f          	j	33d4 <osd_engine_handle+0x74>
    } else if (ui_is_dirty()) {
    33ac:	125000ef          	jal	3cd0 <ui_is_dirty>
    33b0:	fe0508e3          	beqz	a0,33a0 <osd_engine_handle+0x40>
        render_and_commit();
    33b4:	ef9ff0ef          	jal	32ac <render_and_commit>
    33b8:	fe9ff06f          	j	33a0 <osd_engine_handle+0x40>
            ack[i] = resp->ack[i];
    33bc:	00f48733          	add	a4,s1,a5
    33c0:	00f40633          	add	a2,s0,a5
    33c4:	00064603          	lbu	a2,0(a2)
    33c8:	00c70023          	sb	a2,0(a4)
        for (i = 0U; i < n; i++) {
    33cc:	00178793          	addi	a5,a5,1
    33d0:	0ff7f793          	zext.b	a5,a5
    33d4:	fea7e4e3          	bltu	a5,a0,33bc <osd_engine_handle+0x5c>
        }
    }
    return n;
}
    33d8:	00c12083          	lw	ra,12(sp)
    33dc:	00812403          	lw	s0,8(sp)
    33e0:	00412483          	lw	s1,4(sp)
    33e4:	01010113          	addi	sp,sp,16
    33e8:	00008067          	ret
        return 0U;
    33ec:	00000513          	li	a0,0
    33f0:	fe9ff06f          	j	33d8 <osd_engine_handle+0x78>

000033f4 <composer_render>:
#include "font.h"
#include "ui.h"
#include "osd_config.h"

void composer_render(void)
{
    33f4:	fb010113          	addi	sp,sp,-80
    33f8:	04112623          	sw	ra,76(sp)
    33fc:	04812423          	sw	s0,72(sp)
    3400:	04912223          	sw	s1,68(sp)
    3404:	05212023          	sw	s2,64(sp)
    3408:	03312e23          	sw	s3,60(sp)
    340c:	03412c23          	sw	s4,56(sp)
    /* 一行位图 = 34 字节（272/8）。放在栈上：这与画布大小无关，永远只是两行的量级，
     * 不会因为将来改画布尺寸而变成一个大数组。*/
    uint8_t  line[OSD_ROW_STRIDE];
    unsigned r, c, gy;

    for (r = 0u; r < OSD_GRID_ROWS; r++) {
    3410:	00000a13          	li	s4,0
    3414:	0900006f          	j	34a4 <composer_render+0xb0>
                if (idx < 0) {
                    line[c] = OSD_PIXEL_KEY;
                    continue;
                }

                bits = font_row_bits(font_glyph(idx), gy);
    3418:	120000ef          	jal	3538 <font_glyph>
    341c:	00048593          	mv	a1,s1
    3420:	140000ef          	jal	3560 <font_row_bits>

                /* 一个字符格 = 一个字节：字形行的 bit7 最左与位图的 bit7 最左
                 * 是同一条约定，直接落盘即可。*/
                line[c] = bits;
    3424:	03040793          	addi	a5,s0,48
    3428:	002787b3          	add	a5,a5,sp
    342c:	fca78e23          	sb	a0,-36(a5)
            for (c = 0u; c < OSD_GRID_COLS; c++) {
    3430:	00140413          	addi	s0,s0,1
    3434:	02100793          	li	a5,33
    3438:	0287ea63          	bltu	a5,s0,346c <composer_render+0x78>
                int idx = font_lookup(row_cells[c]);
    343c:	00141793          	slli	a5,s0,0x1
    3440:	00f907b3          	add	a5,s2,a5
    3444:	0007d503          	lhu	a0,0(a5)
    3448:	0a4000ef          	jal	34ec <font_lookup>
                if (idx < 0) idx = font_lookup((uint16_t)'?');
    344c:	fc0556e3          	bgez	a0,3418 <composer_render+0x24>
    3450:	03f00513          	li	a0,63
    3454:	098000ef          	jal	34ec <font_lookup>
                if (idx < 0) {
    3458:	fc0550e3          	bgez	a0,3418 <composer_render+0x24>
                    line[c] = OSD_PIXEL_KEY;
    345c:	03040793          	addi	a5,s0,48
    3460:	002787b3          	add	a5,a5,sp
    3464:	fc078e23          	sb	zero,-36(a5)
                    continue;
    3468:	fc9ff06f          	j	3430 <composer_render+0x3c>
            }

            canvas_write((uint32_t)y * (uint32_t)OSD_ROW_STRIDE, line,
    346c:	00499513          	slli	a0,s3,0x4
    3470:	01350533          	add	a0,a0,s3
    3474:	02200613          	li	a2,34
    3478:	00c10593          	addi	a1,sp,12
    347c:	00151513          	slli	a0,a0,0x1
    3480:	b55ff0ef          	jal	2fd4 <canvas_write>
        for (gy = 0u; gy < OSD_GLYPH_H; gy++) {
    3484:	00148493          	addi	s1,s1,1
    3488:	00f00793          	li	a5,15
    348c:	0097ea63          	bltu	a5,s1,34a0 <composer_render+0xac>
            unsigned y = r * OSD_GLYPH_H + gy;
    3490:	004a1993          	slli	s3,s4,0x4
    3494:	009989b3          	add	s3,s3,s1
            for (c = 0u; c < OSD_GRID_COLS; c++) {
    3498:	00000413          	li	s0,0
    349c:	f99ff06f          	j	3434 <composer_render+0x40>
    for (r = 0u; r < OSD_GRID_ROWS; r++) {
    34a0:	001a0a13          	addi	s4,s4,1
    34a4:	00c00793          	li	a5,12
    34a8:	0347e263          	bltu	a5,s4,34cc <composer_render+0xd8>
        const cell_t *row_cells = osd_buf[r];
    34ac:	004a1913          	slli	s2,s4,0x4
    34b0:	01490933          	add	s2,s2,s4
    34b4:	00291913          	slli	s2,s2,0x2
    34b8:	000087b7          	lui	a5,0x8
    34bc:	a4c78793          	addi	a5,a5,-1460 # 7a4c <osd_buf>
    34c0:	00f90933          	add	s2,s2,a5
        for (gy = 0u; gy < OSD_GLYPH_H; gy++) {
    34c4:	00000493          	li	s1,0
    34c8:	fc1ff06f          	j	3488 <composer_render+0x94>
                         (uint32_t)OSD_ROW_STRIDE);
        }
    }
}
    34cc:	04c12083          	lw	ra,76(sp)
    34d0:	04812403          	lw	s0,72(sp)
    34d4:	04412483          	lw	s1,68(sp)
    34d8:	04012903          	lw	s2,64(sp)
    34dc:	03c12983          	lw	s3,60(sp)
    34e0:	03812a03          	lw	s4,56(sp)
    34e4:	05010113          	addi	sp,sp,80
    34e8:	00008067          	ret

000034ec <font_lookup>:
#include "font8x16_bin.h"

uint16_t font_count(void) { return (uint16_t)FONT8X16_COUNT; }

int font_lookup(uint16_t cp)
{
    34ec:	00050593          	mv	a1,a0
    int lo = 0, hi = (int)FONT8X16_COUNT - 1;
    34f0:	0aa00613          	li	a2,170
    34f4:	00000693          	li	a3,0

    while (lo <= hi) {
    34f8:	0080006f          	j	3500 <font_lookup+0x14>
        int mid = (lo + hi) >> 1;
        uint16_t v = font8x16_codepoints[mid];
        if (v == cp) return mid;
        if (v < cp) lo = mid + 1; else hi = mid - 1;
    34fc:	fff50613          	addi	a2,a0,-1
    while (lo <= hi) {
    3500:	02d64863          	blt	a2,a3,3530 <font_lookup+0x44>
        int mid = (lo + hi) >> 1;
    3504:	00c68733          	add	a4,a3,a2
    3508:	40175513          	srai	a0,a4,0x1
        uint16_t v = font8x16_codepoints[mid];
    350c:	000057b7          	lui	a5,0x5
    3510:	ffe77713          	andi	a4,a4,-2
    3514:	53478793          	addi	a5,a5,1332 # 5534 <font8x16_codepoints>
    3518:	00e787b3          	add	a5,a5,a4
    351c:	0007d783          	lhu	a5,0(a5)
        if (v == cp) return mid;
    3520:	00b78a63          	beq	a5,a1,3534 <font_lookup+0x48>
        if (v < cp) lo = mid + 1; else hi = mid - 1;
    3524:	fcb7fce3          	bgeu	a5,a1,34fc <font_lookup+0x10>
    3528:	00150693          	addi	a3,a0,1
    352c:	fd5ff06f          	j	3500 <font_lookup+0x14>
    }
    return -1;
    3530:	fff00513          	li	a0,-1
}
    3534:	00008067          	ret

00003538 <font_glyph>:

const uint8_t *font_glyph(int idx)
{
    if (idx < 0 || idx >= (int)FONT8X16_COUNT) return font8x16_bitmap[0];
    3538:	0aa00793          	li	a5,170
    353c:	00a7ec63          	bltu	a5,a0,3554 <font_glyph+0x1c>
    return font8x16_bitmap[idx];
    3540:	00451513          	slli	a0,a0,0x4
    3544:	000057b7          	lui	a5,0x5
    3548:	a8478793          	addi	a5,a5,-1404 # 4a84 <font8x16_bitmap>
    354c:	00f50533          	add	a0,a0,a5
    3550:	00008067          	ret
    if (idx < 0 || idx >= (int)FONT8X16_COUNT) return font8x16_bitmap[0];
    3554:	00005537          	lui	a0,0x5
    3558:	a8450513          	addi	a0,a0,-1404 # 4a84 <font8x16_bitmap>
}
    355c:	00008067          	ret

00003560 <font_row_bits>:

uint8_t font_row_bits(const uint8_t *g, unsigned row)
{
    if (row >= OSD_GLYPH_H) row = OSD_GLYPH_H - 1u;   /* 越界保护：永远给合法数据 */
    3560:	00f00793          	li	a5,15
    3564:	00b7f463          	bgeu	a5,a1,356c <font_row_bits+0xc>
    3568:	00f00593          	li	a1,15
    /* 一行就是一个字节：字符格宽 8 px、1 bpp，且**行内 bit7 = 最左像素** ——
     * 与位图的位序约定完全相同，所以取出来直接可用，不做任何移位。
     * （16×16 时代是每行 2 字节大端，要移位拼接；格宽改 8 之后这一段就没了。）*/
    return g[row];
    356c:	00b50533          	add	a0,a0,a1
}
    3570:	00054503          	lbu	a0,0(a0)
    3574:	00008067          	ret

00003578 <osd_utf8_seq_len>:

#define OSD_UTF8_BAD  0xFFFDu   /* 非法字节的替换码点 */

static unsigned osd_utf8_seq_len(unsigned char c)
{
    if (c < 0x80u) return 1u;
    3578:	01851793          	slli	a5,a0,0x18
    357c:	4187d793          	srai	a5,a5,0x18
    3580:	0207d863          	bgez	a5,35b0 <osd_utf8_seq_len+0x38>
    if ((c & 0xE0u) == 0xC0u) return 2u;
    3584:	0e057793          	andi	a5,a0,224
    3588:	0c000713          	li	a4,192
    358c:	02e78663          	beq	a5,a4,35b8 <osd_utf8_seq_len+0x40>
    if ((c & 0xF0u) == 0xE0u) return 3u;
    3590:	0f057793          	andi	a5,a0,240
    3594:	0e000713          	li	a4,224
    3598:	02e78463          	beq	a5,a4,35c0 <osd_utf8_seq_len+0x48>
    if ((c & 0xF8u) == 0xF0u) return 4u;
    359c:	0f857513          	andi	a0,a0,248
    35a0:	0f000793          	li	a5,240
    35a4:	02f50263          	beq	a0,a5,35c8 <osd_utf8_seq_len+0x50>
    return 0u;                       /* 孤立续字节：非法 */
    35a8:	00000513          	li	a0,0
    35ac:	00008067          	ret
    if (c < 0x80u) return 1u;
    35b0:	00100513          	li	a0,1
    35b4:	00008067          	ret
    if ((c & 0xE0u) == 0xC0u) return 2u;
    35b8:	00200513          	li	a0,2
    35bc:	00008067          	ret
    if ((c & 0xF0u) == 0xE0u) return 3u;
    35c0:	00300513          	li	a0,3
    35c4:	00008067          	ret
    if ((c & 0xF8u) == 0xF0u) return 4u;
    35c8:	00400513          	li	a0,4
}
    35cc:	00008067          	ret

000035d0 <osd_utf8_decode>:

/* 解码 s[0..] 处的一个字符；*adv = 消耗的字节数。
 * 调用方保证至少还剩 1 字节；不足按非法处理（前进 1 字节）。 */
static uint32_t osd_utf8_decode(const unsigned char *s, unsigned remain, unsigned *adv)
{
    35d0:	fe010113          	addi	sp,sp,-32
    35d4:	00112e23          	sw	ra,28(sp)
    35d8:	00812c23          	sw	s0,24(sp)
    35dc:	00912a23          	sw	s1,20(sp)
    35e0:	01212823          	sw	s2,16(sp)
    35e4:	01312623          	sw	s3,12(sp)
    35e8:	00050493          	mv	s1,a0
    35ec:	00058913          	mv	s2,a1
    35f0:	00060993          	mv	s3,a2
    unsigned n = osd_utf8_seq_len(s[0]);
    35f4:	00054403          	lbu	s0,0(a0)
    35f8:	00040513          	mv	a0,s0
    35fc:	f7dff0ef          	jal	3578 <osd_utf8_seq_len>
    uint32_t cp;

    if (n == 0u || n > remain) { *adv = 1u; return OSD_UTF8_BAD; }
    3600:	04050e63          	beqz	a0,365c <osd_utf8_decode+0x8c>
    3604:	00050793          	mv	a5,a0
    3608:	04a96a63          	bltu	s2,a0,365c <osd_utf8_decode+0x8c>
    if (n > 3u) { *adv = n; return OSD_UTF8_BAD; }   /* 超出 BMP：字库不含 */
    360c:	00300713          	li	a4,3
    3610:	06a76063          	bltu	a4,a0,3670 <osd_utf8_decode+0xa0>

    switch (n) {
    3614:	00100713          	li	a4,1
    3618:	06e50463          	beq	a0,a4,3680 <osd_utf8_decode+0xb0>
    361c:	00200713          	li	a4,2
    3620:	08e50263          	beq	a0,a4,36a4 <osd_utf8_decode+0xd4>
    case 1u: cp = s[0]; break;
    case 2u: cp = ((uint32_t)(s[0] & 0x1Fu) << 6)  | (uint32_t)(s[1] & 0x3Fu); break;
    default: cp = ((uint32_t)(s[0] & 0x0Fu) << 12) | ((uint32_t)(s[1] & 0x3Fu) << 6)
    3624:	00c41413          	slli	s0,s0,0xc
    3628:	00010737          	lui	a4,0x10
    362c:	fff70713          	addi	a4,a4,-1 # ffff <__freertos_irq_stack_top+0x723f>
    3630:	00e47433          	and	s0,s0,a4
    3634:	0014c703          	lbu	a4,1(s1)
    3638:	00671713          	slli	a4,a4,0x6
    363c:	000016b7          	lui	a3,0x1
    3640:	fc068693          	addi	a3,a3,-64 # fc0 <CUSTOM2+0xf65>
    3644:	00d77733          	and	a4,a4,a3
    3648:	00e46433          	or	s0,s0,a4
                   | (uint32_t)(s[2] & 0x3Fu); break;
    364c:	0024c703          	lbu	a4,2(s1)
    3650:	03f77713          	andi	a4,a4,63
    default: cp = ((uint32_t)(s[0] & 0x0Fu) << 12) | ((uint32_t)(s[1] & 0x3Fu) << 6)
    3654:	00e46533          	or	a0,s0,a4
                   | (uint32_t)(s[2] & 0x3Fu); break;
    3658:	02c0006f          	j	3684 <osd_utf8_decode+0xb4>
    if (n == 0u || n > remain) { *adv = 1u; return OSD_UTF8_BAD; }
    365c:	00100793          	li	a5,1
    3660:	00f9a023          	sw	a5,0(s3)
    3664:	00010537          	lui	a0,0x10
    3668:	ffd50513          	addi	a0,a0,-3 # fffd <__freertos_irq_stack_top+0x723d>
    366c:	01c0006f          	j	3688 <osd_utf8_decode+0xb8>
    if (n > 3u) { *adv = n; return OSD_UTF8_BAD; }   /* 超出 BMP：字库不含 */
    3670:	00a9a023          	sw	a0,0(s3)
    3674:	00010537          	lui	a0,0x10
    3678:	ffd50513          	addi	a0,a0,-3 # fffd <__freertos_irq_stack_top+0x723d>
    367c:	00c0006f          	j	3688 <osd_utf8_decode+0xb8>
    case 1u: cp = s[0]; break;
    3680:	00040513          	mv	a0,s0
    }
    *adv = n;
    3684:	00f9a023          	sw	a5,0(s3)
    return cp;
}
    3688:	01c12083          	lw	ra,28(sp)
    368c:	01812403          	lw	s0,24(sp)
    3690:	01412483          	lw	s1,20(sp)
    3694:	01012903          	lw	s2,16(sp)
    3698:	00c12983          	lw	s3,12(sp)
    369c:	02010113          	addi	sp,sp,32
    36a0:	00008067          	ret
    case 2u: cp = ((uint32_t)(s[0] & 0x1Fu) << 6)  | (uint32_t)(s[1] & 0x3Fu); break;
    36a4:	00641413          	slli	s0,s0,0x6
    36a8:	7c047413          	andi	s0,s0,1984
    36ac:	0014c703          	lbu	a4,1(s1)
    36b0:	03f77713          	andi	a4,a4,63
    36b4:	00e46533          	or	a0,s0,a4
    36b8:	fcdff06f          	j	3684 <osd_utf8_decode+0xb4>

000036bc <pick>:
*       编译期或独立配置项，那一列直接可用，不必回头补数据。
******************************************************************************/
static const char *pick(const i18n_t *s)
{
    return s->en;
}
    36bc:	00052503          	lw	a0,0(a0)
    36c0:	00008067          	ret

000036c4 <grid_clear>:
* @note 全量重画语义的一部分：不清空的话，上一页残留的字符会在新页的空白处露出来。
******************************************************************************/
static void grid_clear(void)
{
    unsigned r, c;
    for (r = 0u; r < OSD_GRID_ROWS; r++)
    36c4:	00000593          	li	a1,0
    36c8:	03c0006f          	j	3704 <grid_clear+0x40>
        for (c = 0u; c < OSD_GRID_COLS; c++)
            osd_buf[r][c] = (cell_t)' ';
    36cc:	00008737          	lui	a4,0x8
    36d0:	00459693          	slli	a3,a1,0x4
    36d4:	00b686b3          	add	a3,a3,a1
    36d8:	00169793          	slli	a5,a3,0x1
    36dc:	00c787b3          	add	a5,a5,a2
    36e0:	00179793          	slli	a5,a5,0x1
    36e4:	a4c70713          	addi	a4,a4,-1460 # 7a4c <osd_buf>
    36e8:	00f707b3          	add	a5,a4,a5
    36ec:	02000713          	li	a4,32
    36f0:	00e79023          	sh	a4,0(a5)
        for (c = 0u; c < OSD_GRID_COLS; c++)
    36f4:	00160613          	addi	a2,a2,1
    36f8:	02100793          	li	a5,33
    36fc:	fcc7f8e3          	bgeu	a5,a2,36cc <grid_clear+0x8>
    for (r = 0u; r < OSD_GRID_ROWS; r++)
    3700:	00158593          	addi	a1,a1,1
    3704:	00c00793          	li	a5,12
    3708:	00b7e663          	bltu	a5,a1,3714 <grid_clear+0x50>
        for (c = 0u; c < OSD_GRID_COLS; c++)
    370c:	00000613          	li	a2,0
    3710:	fe9ff06f          	j	36f8 <grid_clear+0x34>
}
    3714:	00008067          	ret

00003718 <utf8_str_cells>:
    }
    osd_buf[row][col] = (cell_t)cp;
}

static unsigned utf8_str_cells(const char *s)
{
    3718:	fe010113          	addi	sp,sp,-32
    371c:	00112e23          	sw	ra,28(sp)
    3720:	00812c23          	sw	s0,24(sp)
    3724:	00912a23          	sw	s1,20(sp)
    3728:	01212823          	sw	s2,16(sp)
    372c:	00050413          	mv	s0,a0
    unsigned n = 0u;
    const unsigned char *p = (const unsigned char *)s;
    unsigned remain = 0u, i;
    for (i = 0u; s[i] != '\0'; i++) remain++;
    3730:	00000793          	li	a5,0
    unsigned remain = 0u, i;
    3734:	00000493          	li	s1,0
    for (i = 0u; s[i] != '\0'; i++) remain++;
    3738:	00c0006f          	j	3744 <utf8_str_cells+0x2c>
    373c:	00148493          	addi	s1,s1,1
    3740:	00178793          	addi	a5,a5,1
    3744:	00f40733          	add	a4,s0,a5
    3748:	00074703          	lbu	a4,0(a4)
    374c:	fe0718e3          	bnez	a4,373c <utf8_str_cells+0x24>
    unsigned n = 0u;
    3750:	00000913          	li	s2,0
    3754:	0240006f          	j	3778 <utf8_str_cells+0x60>
    while (*p != '\0') {
        unsigned adv;
        osd_utf8_decode(p, remain, &adv);
    3758:	00c10613          	addi	a2,sp,12
    375c:	00048593          	mv	a1,s1
    3760:	00040513          	mv	a0,s0
    3764:	e6dff0ef          	jal	35d0 <osd_utf8_decode>
        p += adv; remain -= adv;
    3768:	00c12783          	lw	a5,12(sp)
    376c:	00f40433          	add	s0,s0,a5
    3770:	40f484b3          	sub	s1,s1,a5
        n++;
    3774:	00190913          	addi	s2,s2,1
    while (*p != '\0') {
    3778:	00044783          	lbu	a5,0(s0)
    377c:	fc079ee3          	bnez	a5,3758 <utf8_str_cells+0x40>
    }
    return n;
}
    3780:	00090513          	mv	a0,s2
    3784:	01c12083          	lw	ra,28(sp)
    3788:	01812403          	lw	s0,24(sp)
    378c:	01412483          	lw	s1,20(sp)
    3790:	01012903          	lw	s2,16(sp)
    3794:	02010113          	addi	sp,sp,32
    3798:	00008067          	ret

0000379c <u8_to_dec>:
    grid_put_str(row, start, str, OSD_COL_VALUE_LAST);
}

/* 手写 itoa：无 libc / 无浮点 */
static unsigned u8_to_dec(uint8_t v, char *dst)
{
    379c:	ff010113          	addi	sp,sp,-16
    37a0:	00050713          	mv	a4,a0
    char tmp[4];
    unsigned n = 0u, i;
    37a4:	00000513          	li	a0,0

    do { tmp[n++] = (char)('0' + (v % 10u)); v = (uint8_t)(v / 10u); } while (v != 0u);
    37a8:	00a00613          	li	a2,10
    37ac:	02c776b3          	remu	a3,a4,a2
    37b0:	03068693          	addi	a3,a3,48
    37b4:	01050793          	addi	a5,a0,16
    37b8:	002787b3          	add	a5,a5,sp
    37bc:	00150513          	addi	a0,a0,1
    37c0:	fed78e23          	sb	a3,-4(a5)
    37c4:	00070693          	mv	a3,a4
    37c8:	02c75733          	divu	a4,a4,a2
    37cc:	00900793          	li	a5,9
    37d0:	fcd7ece3          	bltu	a5,a3,37a8 <u8_to_dec+0xc>
    for (i = 0u; i < n; i++) dst[i] = tmp[n - 1u - i];
    37d4:	00000713          	li	a4,0
    37d8:	0200006f          	j	37f8 <u8_to_dec+0x5c>
    37dc:	40e507b3          	sub	a5,a0,a4
    37e0:	00e586b3          	add	a3,a1,a4
    37e4:	00f78793          	addi	a5,a5,15
    37e8:	002787b3          	add	a5,a5,sp
    37ec:	ffc7c783          	lbu	a5,-4(a5)
    37f0:	00f68023          	sb	a5,0(a3)
    37f4:	00170713          	addi	a4,a4,1
    37f8:	fea762e3          	bltu	a4,a0,37dc <u8_to_dec+0x40>
    return n;
}
    37fc:	01010113          	addi	sp,sp,16
    3800:	00008067          	ret

00003804 <grid_put>:
    if (row >= OSD_GRID_ROWS || col >= OSD_GRID_COLS) return;
    3804:	00c00793          	li	a5,12
    3808:	08a7ee63          	bltu	a5,a0,38a4 <grid_put+0xa0>
{
    380c:	ff010113          	addi	sp,sp,-16
    3810:	00112623          	sw	ra,12(sp)
    3814:	00812423          	sw	s0,8(sp)
    3818:	00912223          	sw	s1,4(sp)
    381c:	01212023          	sw	s2,0(sp)
    3820:	00050413          	mv	s0,a0
    3824:	00058913          	mv	s2,a1
    3828:	00060493          	mv	s1,a2
    if (row >= OSD_GRID_ROWS || col >= OSD_GRID_COLS) return;
    382c:	02100793          	li	a5,33
    3830:	04b7e263          	bltu	a5,a1,3874 <grid_put+0x70>
    if (cp > 0xFFFFu) cp = '?';
    3834:	000107b7          	lui	a5,0x10
    3838:	00f66463          	bltu	a2,a5,3840 <grid_put+0x3c>
    383c:	03f00493          	li	s1,63
    if (font_lookup((uint16_t)cp) < 0) {
    3840:	01049513          	slli	a0,s1,0x10
    3844:	01055513          	srli	a0,a0,0x10
    3848:	ca5ff0ef          	jal	34ec <font_lookup>
    384c:	04054063          	bltz	a0,388c <grid_put+0x88>
    osd_buf[row][col] = (cell_t)cp;
    3850:	00008737          	lui	a4,0x8
    3854:	00441793          	slli	a5,s0,0x4
    3858:	008787b3          	add	a5,a5,s0
    385c:	00179793          	slli	a5,a5,0x1
    3860:	012785b3          	add	a1,a5,s2
    3864:	00159593          	slli	a1,a1,0x1
    3868:	a4c70793          	addi	a5,a4,-1460 # 7a4c <osd_buf>
    386c:	00b787b3          	add	a5,a5,a1
    3870:	00979023          	sh	s1,0(a5) # 10000 <__freertos_irq_stack_top+0x7240>
}
    3874:	00c12083          	lw	ra,12(sp)
    3878:	00812403          	lw	s0,8(sp)
    387c:	00412483          	lw	s1,4(sp)
    3880:	00012903          	lw	s2,0(sp)
    3884:	01010113          	addi	sp,sp,16
    3888:	00008067          	ret
        g_font_miss_count++;
    388c:	00008737          	lui	a4,0x8
    3890:	a4872783          	lw	a5,-1464(a4) # 7a48 <g_font_miss_count>
    3894:	00178793          	addi	a5,a5,1
    3898:	a4f72423          	sw	a5,-1464(a4)
        cp = '?';
    389c:	03f00493          	li	s1,63
    38a0:	fb1ff06f          	j	3850 <grid_put+0x4c>
    38a4:	00008067          	ret

000038a8 <grid_fill_row>:
{
    38a8:	ff010113          	addi	sp,sp,-16
    38ac:	00112623          	sw	ra,12(sp)
    38b0:	00812423          	sw	s0,8(sp)
    38b4:	00912223          	sw	s1,4(sp)
    38b8:	01212023          	sw	s2,0(sp)
    38bc:	00050913          	mv	s2,a0
    38c0:	00058493          	mv	s1,a1
    for (c = 0u; c < OSD_GRID_COLS; c++) grid_put(row, c, (uint32_t)ch);
    38c4:	00000413          	li	s0,0
    38c8:	0180006f          	j	38e0 <grid_fill_row+0x38>
    38cc:	00048613          	mv	a2,s1
    38d0:	00040593          	mv	a1,s0
    38d4:	00090513          	mv	a0,s2
    38d8:	f2dff0ef          	jal	3804 <grid_put>
    38dc:	00140413          	addi	s0,s0,1
    38e0:	02100793          	li	a5,33
    38e4:	fe87f4e3          	bgeu	a5,s0,38cc <grid_fill_row+0x24>
}
    38e8:	00c12083          	lw	ra,12(sp)
    38ec:	00812403          	lw	s0,8(sp)
    38f0:	00412483          	lw	s1,4(sp)
    38f4:	00012903          	lw	s2,0(sp)
    38f8:	01010113          	addi	sp,sp,16
    38fc:	00008067          	ret

00003900 <grid_put_str>:
{
    3900:	fd010113          	addi	sp,sp,-48
    3904:	02112623          	sw	ra,44(sp)
    3908:	02812423          	sw	s0,40(sp)
    390c:	02912223          	sw	s1,36(sp)
    3910:	03212023          	sw	s2,32(sp)
    3914:	01312e23          	sw	s3,28(sp)
    3918:	01412c23          	sw	s4,24(sp)
    391c:	00050a13          	mv	s4,a0
    3920:	00058913          	mv	s2,a1
    3924:	00060493          	mv	s1,a2
    3928:	00068993          	mv	s3,a3
    unsigned len = 0u, remain = 0u;
    392c:	00000413          	li	s0,0
    while (str[len] != '\0') len++;
    3930:	0080006f          	j	3938 <grid_put_str+0x38>
    3934:	00140413          	addi	s0,s0,1
    3938:	008487b3          	add	a5,s1,s0
    393c:	0007c783          	lbu	a5,0(a5)
    3940:	fe079ae3          	bnez	a5,3934 <grid_put_str+0x34>
    3944:	0140006f          	j	3958 <grid_put_str+0x58>
        grid_put(row, col, cp);
    3948:	00090593          	mv	a1,s2
    394c:	000a0513          	mv	a0,s4
    3950:	eb5ff0ef          	jal	3804 <grid_put>
        col++;
    3954:	00190913          	addi	s2,s2,1
    while (*p != '\0' && remain > 0u) {
    3958:	0004c783          	lbu	a5,0(s1)
    395c:	02078663          	beqz	a5,3988 <grid_put_str+0x88>
    3960:	02040463          	beqz	s0,3988 <grid_put_str+0x88>
        uint32_t cp = osd_utf8_decode(p, remain, &adv);
    3964:	00c10613          	addi	a2,sp,12
    3968:	00040593          	mv	a1,s0
    396c:	00048513          	mv	a0,s1
    3970:	c61ff0ef          	jal	35d0 <osd_utf8_decode>
    3974:	00050613          	mv	a2,a0
        p += adv; remain -= adv;
    3978:	00c12783          	lw	a5,12(sp)
    397c:	00f484b3          	add	s1,s1,a5
    3980:	40f40433          	sub	s0,s0,a5
        if (col > end_col) break;
    3984:	fd29f2e3          	bgeu	s3,s2,3948 <grid_put_str+0x48>
    if (remain > 0u) grid_put(row, end_col, '?');
    3988:	02041263          	bnez	s0,39ac <grid_put_str+0xac>
}
    398c:	02c12083          	lw	ra,44(sp)
    3990:	02812403          	lw	s0,40(sp)
    3994:	02412483          	lw	s1,36(sp)
    3998:	02012903          	lw	s2,32(sp)
    399c:	01c12983          	lw	s3,28(sp)
    39a0:	01812a03          	lw	s4,24(sp)
    39a4:	03010113          	addi	sp,sp,48
    39a8:	00008067          	ret
    if (remain > 0u) grid_put(row, end_col, '?');
    39ac:	03f00613          	li	a2,63
    39b0:	00098593          	mv	a1,s3
    39b4:	000a0513          	mv	a0,s4
    39b8:	e4dff0ef          	jal	3804 <grid_put>
}
    39bc:	fd1ff06f          	j	398c <grid_put_str+0x8c>

000039c0 <grid_put_centered>:
{
    39c0:	ff010113          	addi	sp,sp,-16
    39c4:	00112623          	sw	ra,12(sp)
    39c8:	00812423          	sw	s0,8(sp)
    39cc:	00912223          	sw	s1,4(sp)
    39d0:	00050493          	mv	s1,a0
    39d4:	00058413          	mv	s0,a1
    unsigned n = utf8_str_cells(str);
    39d8:	00058513          	mv	a0,a1
    39dc:	d3dff0ef          	jal	3718 <utf8_str_cells>
    if (n >= span) { grid_put_str(row, OSD_COL_PREFIX, str, OSD_COL_VALUE_LAST); return; }
    39e0:	01f00793          	li	a5,31
    39e4:	02a7ec63          	bltu	a5,a0,3a1c <grid_put_centered+0x5c>
    start = OSD_COL_PREFIX + (span - n) / 2u;
    39e8:	02000593          	li	a1,32
    39ec:	40a585b3          	sub	a1,a1,a0
    39f0:	0015d593          	srli	a1,a1,0x1
    grid_put_str(row, start, str, OSD_COL_VALUE_LAST);
    39f4:	02000693          	li	a3,32
    39f8:	00040613          	mv	a2,s0
    39fc:	00158593          	addi	a1,a1,1
    3a00:	00048513          	mv	a0,s1
    3a04:	efdff0ef          	jal	3900 <grid_put_str>
}
    3a08:	00c12083          	lw	ra,12(sp)
    3a0c:	00812403          	lw	s0,8(sp)
    3a10:	00412483          	lw	s1,4(sp)
    3a14:	01010113          	addi	sp,sp,16
    3a18:	00008067          	ret
    if (n >= span) { grid_put_str(row, OSD_COL_PREFIX, str, OSD_COL_VALUE_LAST); return; }
    3a1c:	02000693          	li	a3,32
    3a20:	00040613          	mv	a2,s0
    3a24:	00100593          	li	a1,1
    3a28:	00048513          	mv	a0,s1
    3a2c:	ed5ff0ef          	jal	3900 <grid_put_str>
    3a30:	fd9ff06f          	j	3a08 <grid_put_centered+0x48>

00003a34 <grid_put_value>:

/* 数值右对齐：最后一个字符落在 OSD_COL_VALUE_LAST（[n] 形式） */
static void grid_put_value(unsigned row, uint8_t val)
{
    3a34:	fe010113          	addi	sp,sp,-32
    3a38:	00112e23          	sw	ra,28(sp)
    3a3c:	00812c23          	sw	s0,24(sp)
    3a40:	00050413          	mv	s0,a0
    3a44:	00058513          	mv	a0,a1
    char buf[8];
    unsigned len = 0u, start;

    buf[len++] = '[';
    3a48:	05b00793          	li	a5,91
    3a4c:	00f10423          	sb	a5,8(sp)
    len += u8_to_dec(val, &buf[len]);
    3a50:	00910593          	addi	a1,sp,9
    3a54:	d49ff0ef          	jal	379c <u8_to_dec>
    3a58:	00150793          	addi	a5,a0,1
    buf[len++] = ']';
    3a5c:	00250593          	addi	a1,a0,2
    3a60:	01078793          	addi	a5,a5,16
    3a64:	002787b3          	add	a5,a5,sp
    3a68:	05d00713          	li	a4,93
    3a6c:	fee78c23          	sb	a4,-8(a5)
    buf[len] = '\0';
    3a70:	01058793          	addi	a5,a1,16
    3a74:	002787b3          	add	a5,a5,sp
    3a78:	fe078c23          	sb	zero,-8(a5)

    if (len > OSD_COL_VALUE_LAST) len = OSD_COL_VALUE_LAST;
    3a7c:	02000793          	li	a5,32
    3a80:	00b7f463          	bgeu	a5,a1,3a88 <grid_put_value+0x54>
    3a84:	02000593          	li	a1,32
    start = OSD_COL_VALUE_LAST + 1u - len;
    grid_put_str(row, start, buf, OSD_COL_VALUE_LAST);
    3a88:	02000693          	li	a3,32
    3a8c:	00810613          	addi	a2,sp,8
    3a90:	02100793          	li	a5,33
    3a94:	40b785b3          	sub	a1,a5,a1
    3a98:	00040513          	mv	a0,s0
    3a9c:	e65ff0ef          	jal	3900 <grid_put_str>
}
    3aa0:	01c12083          	lw	ra,28(sp)
    3aa4:	01812403          	lw	s0,24(sp)
    3aa8:	02010113          	addi	sp,sp,32
    3aac:	00008067          	ret

00003ab0 <ui_init>:

/* ---------------------------------------------------------------- API */

void ui_init(void)
{
    3ab0:	ff010113          	addi	sp,sp,-16
    3ab4:	00112623          	sw	ra,12(sp)
    s_state.page_id = 0x0000u;
    3ab8:	000087b7          	lui	a5,0x8
    3abc:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3ac0:	00079023          	sh	zero,0(a5)
    s_state.sel     = 0u;
    3ac4:	00078123          	sb	zero,2(a5)
    s_state.flags   = UI_FLAG_VISIBLE;   /* 上电即显示主菜单（bit0 = UI 显示）*/
    3ac8:	00100713          	li	a4,1
    3acc:	00e781a3          	sb	a4,3(a5)
    s_state.v[0]    = 3u;      /* 默认值取自 UI 规格 P2 原型 */
    3ad0:	00300693          	li	a3,3
    3ad4:	00d78223          	sb	a3,4(a5)
    s_state.v[1]    = 5u;
    3ad8:	00500693          	li	a3,5
    3adc:	00d782a3          	sb	a3,5(a5)
    s_state.v[2]    = 7u;
    3ae0:	00700613          	li	a2,7
    3ae4:	00c78323          	sb	a2,6(a5)
    s_state.v[3]    = 5u;
    3ae8:	00d783a3          	sb	a3,7(a5)
    s_state.status  = 0u;
    3aec:	00078423          	sb	zero,8(a5)
    s_state.dirty   = 1u;
    3af0:	00e784a3          	sb	a4,9(a5)
    grid_clear();
    3af4:	bd1ff0ef          	jal	36c4 <grid_clear>
}
    3af8:	00c12083          	lw	ra,12(sp)
    3afc:	01010113          	addi	sp,sp,16
    3b00:	00008067          	ret

00003b04 <ui_set_view>:
*
* @note 失败时**状态完全不变**（含 flags）：这是"整帧拒绝"的口径 —— 部分生效会
*       让上位机回读到的状态既不是旧的也不是它要的新的，比直接失败更难排查。
******************************************************************************/
int ui_set_view(uint16_t page_id, uint8_t sel, uint8_t flags)
{
    3b04:	ff010113          	addi	sp,sp,-16
    3b08:	00112623          	sw	ra,12(sp)
    3b0c:	00812423          	sw	s0,8(sp)
    3b10:	00912223          	sw	s1,4(sp)
    3b14:	01212023          	sw	s2,0(sp)
    3b18:	00050913          	mv	s2,a0
    3b1c:	00058493          	mv	s1,a1
    3b20:	00060413          	mv	s0,a2
    const scene_page_t *pg = scene_find(page_id);
    3b24:	364000ef          	jal	3e88 <scene_find>
    uint8_t f;

    if (pg == 0)               { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    3b28:	04050e63          	beqz	a0,3b84 <ui_set_view+0x80>
    if (sel >= pg->item_count) { s_state.status |= UI_STATUS_BAD_PARAM; return -2; }
    3b2c:	00c52783          	lw	a5,12(a0)
    3b30:	06f4f863          	bgeu	s1,a5,3ba0 <ui_set_view+0x9c>

    f = (uint8_t)(flags & UI_FLAG_MASK);        /* 保留位静默丢弃、不报错 */
    3b34:	00347713          	andi	a4,s0,3
    if ((f & UI_FLAG_EDIT) && (pg->value_slot[sel] < 0)) {
    3b38:	00247413          	andi	s0,s0,2
    3b3c:	00040863          	beqz	s0,3b4c <ui_set_view+0x48>
    3b40:	009507b3          	add	a5,a0,s1
    3b44:	05878783          	lb	a5,88(a5)
    3b48:	0607ca63          	bltz	a5,3bbc <ui_set_view+0xb8>
        s_state.status |= UI_STATUS_BAD_PARAM;
        return -3;
    }

    s_state.page_id = page_id;
    3b4c:	000087b7          	lui	a5,0x8
    3b50:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3b54:	01279023          	sh	s2,0(a5)
    s_state.sel     = sel;
    3b58:	00978123          	sb	s1,2(a5)
    s_state.flags   = f;
    3b5c:	00e781a3          	sb	a4,3(a5)
    s_state.dirty   = 1u;
    3b60:	00100713          	li	a4,1
    3b64:	00e784a3          	sb	a4,9(a5)
    return 0;
    3b68:	00000513          	li	a0,0
}
    3b6c:	00c12083          	lw	ra,12(sp)
    3b70:	00812403          	lw	s0,8(sp)
    3b74:	00412483          	lw	s1,4(sp)
    3b78:	00012903          	lw	s2,0(sp)
    3b7c:	01010113          	addi	sp,sp,16
    3b80:	00008067          	ret
    if (pg == 0)               { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    3b84:	000087b7          	lui	a5,0x8
    3b88:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3b8c:	0087c703          	lbu	a4,8(a5)
    3b90:	00276713          	ori	a4,a4,2
    3b94:	00e78423          	sb	a4,8(a5)
    3b98:	fff00513          	li	a0,-1
    3b9c:	fd1ff06f          	j	3b6c <ui_set_view+0x68>
    if (sel >= pg->item_count) { s_state.status |= UI_STATUS_BAD_PARAM; return -2; }
    3ba0:	000087b7          	lui	a5,0x8
    3ba4:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3ba8:	0087c703          	lbu	a4,8(a5)
    3bac:	00276713          	ori	a4,a4,2
    3bb0:	00e78423          	sb	a4,8(a5)
    3bb4:	ffe00513          	li	a0,-2
    3bb8:	fb5ff06f          	j	3b6c <ui_set_view+0x68>
        s_state.status |= UI_STATUS_BAD_PARAM;
    3bbc:	000087b7          	lui	a5,0x8
    3bc0:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3bc4:	0087c703          	lbu	a4,8(a5)
    3bc8:	00276713          	ori	a4,a4,2
    3bcc:	00e78423          	sb	a4,8(a5)
        return -3;
    3bd0:	ffd00513          	li	a0,-3
    3bd4:	f99ff06f          	j	3b6c <ui_set_view+0x68>

00003bd8 <ui_set_image_values>:
*       菜单回显与前端的 QUERY_VIEW 回读，没有连到任何图像处理通路。
*       这是本期明确的范围（任务 6.10），也是"改了参数画面没变"的原因。
******************************************************************************/
int ui_set_image_values(const uint8_t v[4])
{
    if (v[0] > UI_V_ENHANCE_MAX) { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    3bd8:	00054703          	lbu	a4,0(a0)
    3bdc:	00500793          	li	a5,5
    3be0:	04e7ea63          	bltu	a5,a4,3c34 <ui_set_image_values+0x5c>
    if ((v[1] > UI_V_OTHER_MAX) || (v[2] > UI_V_OTHER_MAX) || (v[3] > UI_V_OTHER_MAX)) {
    3be4:	00154683          	lbu	a3,1(a0)
    3be8:	00a00793          	li	a5,10
    3bec:	06d7e263          	bltu	a5,a3,3c50 <ui_set_image_values+0x78>
    3bf0:	00254683          	lbu	a3,2(a0)
    3bf4:	04d7ee63          	bltu	a5,a3,3c50 <ui_set_image_values+0x78>
    3bf8:	00354683          	lbu	a3,3(a0)
    3bfc:	04d7ea63          	bltu	a5,a3,3c50 <ui_set_image_values+0x78>
        s_state.status |= UI_STATUS_BAD_PARAM;
        return -1;
    }

    s_state.v[0] = v[0];
    3c00:	000087b7          	lui	a5,0x8
    3c04:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3c08:	00e78223          	sb	a4,4(a5)
    s_state.v[1] = v[1];
    3c0c:	00154703          	lbu	a4,1(a0)
    3c10:	00e782a3          	sb	a4,5(a5)
    s_state.v[2] = v[2];
    3c14:	00254703          	lbu	a4,2(a0)
    3c18:	00e78323          	sb	a4,6(a5)
    s_state.v[3] = v[3];
    3c1c:	00354703          	lbu	a4,3(a0)
    3c20:	00e783a3          	sb	a4,7(a5)
    s_state.dirty = 1u;
    3c24:	00100713          	li	a4,1
    3c28:	00e784a3          	sb	a4,9(a5)
    return 0;
    3c2c:	00000513          	li	a0,0
}
    3c30:	00008067          	ret
    if (v[0] > UI_V_ENHANCE_MAX) { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    3c34:	000087b7          	lui	a5,0x8
    3c38:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3c3c:	0087c703          	lbu	a4,8(a5)
    3c40:	00276713          	ori	a4,a4,2
    3c44:	00e78423          	sb	a4,8(a5)
    3c48:	fff00513          	li	a0,-1
    3c4c:	00008067          	ret
        s_state.status |= UI_STATUS_BAD_PARAM;
    3c50:	000087b7          	lui	a5,0x8
    3c54:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3c58:	0087c703          	lbu	a4,8(a5)
    3c5c:	00276713          	ori	a4,a4,2
    3c60:	00e78423          	sb	a4,8(a5)
        return -1;
    3c64:	fff00513          	li	a0,-1
    3c68:	00008067          	ret

00003c6c <ui_query_view>:
* @note **不再有 item_count 与 fw_version**（D11 第 6 项）：协议文档 §3.3 与工具
*       都只认这 8 个字节，多写两个会直接变成 CRC 对不上的 14 字节 body。
******************************************************************************/
int ui_query_view(uint8_t resp[UI_QUERY_PAYLOAD_LEN])
{
    resp[0] = (uint8_t)(s_state.page_id >> 8);
    3c6c:	000087b7          	lui	a5,0x8
    3c70:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3c74:	0007d703          	lhu	a4,0(a5)
    3c78:	00875693          	srli	a3,a4,0x8
    3c7c:	00d50023          	sb	a3,0(a0)
    resp[1] = (uint8_t)(s_state.page_id & 0xFFu);
    3c80:	00e500a3          	sb	a4,1(a0)
    resp[2] = s_state.sel;
    3c84:	0027c703          	lbu	a4,2(a5)
    3c88:	00e50123          	sb	a4,2(a0)
    resp[3] = s_state.flags;
    3c8c:	0037c703          	lbu	a4,3(a5)
    3c90:	00e501a3          	sb	a4,3(a0)
    resp[4] = s_state.v[0];
    3c94:	0047c703          	lbu	a4,4(a5)
    3c98:	00e50223          	sb	a4,4(a0)
    resp[5] = s_state.v[1];
    3c9c:	0057c703          	lbu	a4,5(a5)
    3ca0:	00e502a3          	sb	a4,5(a0)
    resp[6] = s_state.v[2];
    3ca4:	0067c703          	lbu	a4,6(a5)
    3ca8:	00e50323          	sb	a4,6(a0)
    resp[7] = s_state.v[3];
    3cac:	0077c783          	lbu	a5,7(a5)
    3cb0:	00f503a3          	sb	a5,7(a0)
    return 0;
}
    3cb4:	00000513          	li	a0,0
    3cb8:	00008067          	ret

00003cbc <ui_is_visible>:

int  ui_is_visible(void)  { return (s_state.flags & UI_FLAG_VISIBLE) ? 1 : 0; }
    3cbc:	000087b7          	lui	a5,0x8
    3cc0:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3cc4:	0037c503          	lbu	a0,3(a5)
    3cc8:	00157513          	andi	a0,a0,1
    3ccc:	00008067          	ret

00003cd0 <ui_is_dirty>:
int  ui_is_dirty(void)    { return (int)s_state.dirty; }
    3cd0:	000087b7          	lui	a5,0x8
    3cd4:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3cd8:	0097c503          	lbu	a0,9(a5)
    3cdc:	00008067          	ret

00003ce0 <ui_clear_dirty>:
void ui_clear_dirty(void) { s_state.dirty = 0u; }
    3ce0:	000087b7          	lui	a5,0x8
    3ce4:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3ce8:	000784a3          	sb	zero,9(a5)
    3cec:	00008067          	ret

00003cf0 <scene_build>:
void ui_clear_status(void){ s_state.status = 0u; }

/* ---------------------------------------------------------------- 排版 */

void scene_build(void)
{
    3cf0:	fe010113          	addi	sp,sp,-32
    3cf4:	00112e23          	sw	ra,28(sp)
    3cf8:	01212823          	sw	s2,16(sp)
    const scene_page_t *pg = scene_find(s_state.page_id);
    3cfc:	000087b7          	lui	a5,0x8
    3d00:	a347d503          	lhu	a0,-1484(a5) # 7a34 <s_state>
    3d04:	184000ef          	jal	3e88 <scene_find>
    3d08:	00050913          	mv	s2,a0
    unsigned i;

    grid_clear();
    3d0c:	9b9ff0ef          	jal	36c4 <grid_clear>
    if (pg == 0) return;                       /* 命令层已保证不会走到这里 */
    3d10:	16090063          	beqz	s2,3e70 <scene_build+0x180>
    3d14:	00812c23          	sw	s0,24(sp)
    3d18:	00912a23          	sw	s1,20(sp)
    3d1c:	01312623          	sw	s3,12(sp)

    /* 外框：顶/底横线（-），分隔线（-） */
    grid_fill_row(OSD_ROW_BORDER_TOP,    '-');
    3d20:	02d00593          	li	a1,45
    3d24:	00000513          	li	a0,0
    3d28:	b81ff0ef          	jal	38a8 <grid_fill_row>
    grid_fill_row(OSD_ROW_SEPARATOR,     '-');
    3d2c:	02d00593          	li	a1,45
    3d30:	00200513          	li	a0,2
    3d34:	b75ff0ef          	jal	38a8 <grid_fill_row>
    grid_fill_row(OSD_ROW_BORDER_BOTTOM, '-');
    3d38:	02d00593          	li	a1,45
    3d3c:	00c00513          	li	a0,12
    3d40:	b69ff0ef          	jal	38a8 <grid_fill_row>

    /* 标题居中 */
    grid_put_centered(OSD_ROW_TITLE, pick(&pg->title));
    3d44:	00490513          	addi	a0,s2,4
    3d48:	975ff0ef          	jal	36bc <pick>
    3d4c:	00050593          	mv	a1,a0
    3d50:	00100513          	li	a0,1
    3d54:	c6dff0ef          	jal	39c0 <grid_put_centered>

    for (i = 0u; i < pg->item_count; i++) {
    3d58:	00000413          	li	s0,0
    3d5c:	0600006f          	j	3dbc <scene_build+0xcc>
        unsigned row  = OSD_ROW_ITEM0 + i;
        unsigned end  = (pg->value_slot[i] >= 0) ? OSD_COL_LABEL_END : OSD_COL_VALUE_LAST;
    3d60:	02000993          	li	s3,32
    3d64:	0740006f          	j	3dd8 <scene_build+0xe8>
         * 上游用的是 (UI_FLAG_SELECTED | UI_FLAG_EDIT) 这一对位，而现在 bit0 的
         * 含义是"UI 显示"（整块菜单的显隐），与"哪一行是选中行"无关了 ——
         * 选中行由 sel 唯一决定。若照搬上游的写法，菜单一显示就会所有行都带
         * 选中标记，那是把"窗口可见"误当成"这一行被选中"（D11 第 7 项）。*/
        if (i == s_state.sel) {
            grid_put(row, OSD_COL_PREFIX, (s_state.flags & UI_FLAG_EDIT) ? '*' : '>');
    3d68:	03e00613          	li	a2,62
    3d6c:	00100593          	li	a1,1
    3d70:	00048513          	mv	a0,s1
    3d74:	a91ff0ef          	jal	3804 <grid_put>
            grid_put(row, OSD_COL_PREFIX + 1u, ' ');
    3d78:	02000613          	li	a2,32
    3d7c:	00200593          	li	a1,2
    3d80:	00048513          	mv	a0,s1
    3d84:	a81ff0ef          	jal	3804 <grid_put>
            grid_put(row, OSD_COL_PREFIX, ' ');
            grid_put(row, OSD_COL_PREFIX + 1u, ' ');
        }

        /* 标签（超长截断） */
        grid_put_str(row, OSD_COL_LABEL, pick(&pg->items[i]), end);
    3d88:	00240513          	addi	a0,s0,2
    3d8c:	00351513          	slli	a0,a0,0x3
    3d90:	00a90533          	add	a0,s2,a0
    3d94:	929ff0ef          	jal	36bc <pick>
    3d98:	00050613          	mv	a2,a0
    3d9c:	00098693          	mv	a3,s3
    3da0:	00300593          	li	a1,3
    3da4:	00048513          	mv	a0,s1
    3da8:	b59ff0ef          	jal	3900 <grid_put_str>

        /* 数值（v[slot] 右对齐，这是 SET_IMAGE_VALUES 在画面上的唯一出口） */
        if (pg->value_slot[i] >= 0)
    3dac:	008907b3          	add	a5,s2,s0
    3db0:	05878703          	lb	a4,88(a5)
    3db4:	08075a63          	bgez	a4,3e48 <scene_build+0x158>
    for (i = 0u; i < pg->item_count; i++) {
    3db8:	00140413          	addi	s0,s0,1
    3dbc:	00c92783          	lw	a5,12(s2)
    3dc0:	0af47263          	bgeu	s0,a5,3e64 <scene_build+0x174>
        unsigned row  = OSD_ROW_ITEM0 + i;
    3dc4:	00340493          	addi	s1,s0,3
        unsigned end  = (pg->value_slot[i] >= 0) ? OSD_COL_LABEL_END : OSD_COL_VALUE_LAST;
    3dc8:	008907b3          	add	a5,s2,s0
    3dcc:	05878783          	lb	a5,88(a5)
    3dd0:	f807c8e3          	bltz	a5,3d60 <scene_build+0x70>
    3dd4:	01c00993          	li	s3,28
        grid_put(row, OSD_COL_BORDER_L, '|');
    3dd8:	07c00613          	li	a2,124
    3ddc:	00000593          	li	a1,0
    3de0:	00048513          	mv	a0,s1
    3de4:	a21ff0ef          	jal	3804 <grid_put>
        grid_put(row, OSD_COL_BORDER_R, '|');
    3de8:	07c00613          	li	a2,124
    3dec:	02100593          	li	a1,33
    3df0:	00048513          	mv	a0,s1
    3df4:	a11ff0ef          	jal	3804 <grid_put>
        if (i == s_state.sel) {
    3df8:	000087b7          	lui	a5,0x8
    3dfc:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3e00:	0027c783          	lbu	a5,2(a5)
    3e04:	02879063          	bne	a5,s0,3e24 <scene_build+0x134>
            grid_put(row, OSD_COL_PREFIX, (s_state.flags & UI_FLAG_EDIT) ? '*' : '>');
    3e08:	000087b7          	lui	a5,0x8
    3e0c:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3e10:	0037c783          	lbu	a5,3(a5)
    3e14:	0027f793          	andi	a5,a5,2
    3e18:	f40788e3          	beqz	a5,3d68 <scene_build+0x78>
    3e1c:	02a00613          	li	a2,42
    3e20:	f4dff06f          	j	3d6c <scene_build+0x7c>
            grid_put(row, OSD_COL_PREFIX, ' ');
    3e24:	02000613          	li	a2,32
    3e28:	00100593          	li	a1,1
    3e2c:	00048513          	mv	a0,s1
    3e30:	9d5ff0ef          	jal	3804 <grid_put>
            grid_put(row, OSD_COL_PREFIX + 1u, ' ');
    3e34:	02000613          	li	a2,32
    3e38:	00200593          	li	a1,2
    3e3c:	00048513          	mv	a0,s1
    3e40:	9c5ff0ef          	jal	3804 <grid_put>
    3e44:	f45ff06f          	j	3d88 <scene_build+0x98>
            grid_put_value(row, s_state.v[pg->value_slot[i]]);
    3e48:	000087b7          	lui	a5,0x8
    3e4c:	a3478793          	addi	a5,a5,-1484 # 7a34 <s_state>
    3e50:	00e787b3          	add	a5,a5,a4
    3e54:	0047c583          	lbu	a1,4(a5)
    3e58:	00048513          	mv	a0,s1
    3e5c:	bd9ff0ef          	jal	3a34 <grid_put_value>
    3e60:	f59ff06f          	j	3db8 <scene_build+0xc8>
    3e64:	01812403          	lw	s0,24(sp)
    3e68:	01412483          	lw	s1,20(sp)
    3e6c:	00c12983          	lw	s3,12(sp)
    }
}
    3e70:	01c12083          	lw	ra,28(sp)
    3e74:	01012903          	lw	s2,16(sp)
    3e78:	02010113          	addi	sp,sp,32
    3e7c:	00008067          	ret

00003e80 <scene_page_count>:
        },
        { -1, -1, -1, -1 }
    },
};

unsigned scene_page_count(void) { return (unsigned)(sizeof(s_pages) / sizeof(s_pages[0])); }
    3e80:	00300513          	li	a0,3
    3e84:	00008067          	ret

00003e88 <scene_find>:
const scene_page_t *scene_at(unsigned i) { return &s_pages[i]; }

const scene_page_t *scene_find(uint16_t page_id)
{
    3e88:	ff010113          	addi	sp,sp,-16
    3e8c:	00112623          	sw	ra,12(sp)
    3e90:	00812423          	sw	s0,8(sp)
    3e94:	00912223          	sw	s1,4(sp)
    3e98:	00050493          	mv	s1,a0
    unsigned i;
    for (i = 0u; i < scene_page_count(); i++) {
    3e9c:	00000413          	li	s0,0
    3ea0:	0080006f          	j	3ea8 <scene_find+0x20>
    3ea4:	00140413          	addi	s0,s0,1
    3ea8:	fd9ff0ef          	jal	3e80 <scene_page_count>
    3eac:	02a47863          	bgeu	s0,a0,3edc <scene_find+0x54>
        if (s_pages[i].page_id == page_id) return &s_pages[i];
    3eb0:	000057b7          	lui	a5,0x5
    3eb4:	06400713          	li	a4,100
    3eb8:	02e40733          	mul	a4,s0,a4
    3ebc:	68c78793          	addi	a5,a5,1676 # 568c <s_pages>
    3ec0:	00e787b3          	add	a5,a5,a4
    3ec4:	0007d783          	lhu	a5,0(a5)
    3ec8:	fc979ee3          	bne	a5,s1,3ea4 <scene_find+0x1c>
    3ecc:	000057b7          	lui	a5,0x5
    3ed0:	68c78793          	addi	a5,a5,1676 # 568c <s_pages>
    3ed4:	00f70533          	add	a0,a4,a5
    3ed8:	0080006f          	j	3ee0 <scene_find+0x58>
    }
    return 0;   /* 未知 page_id：由命令层判非法（统一口径），不做兜底渲染 */
    3edc:	00000513          	li	a0,0
}
    3ee0:	00c12083          	lw	ra,12(sp)
    3ee4:	00812403          	lw	s0,8(sp)
    3ee8:	00412483          	lw	s1,4(sp)
    3eec:	01010113          	addi	sp,sp,16
    3ef0:	00008067          	ret

00003ef4 <trap_entry>:

trap_entry:
#ifdef __riscv_flen
  addi sp, sp, -STACK_SIZE
#else
  addi sp, sp, -64
    3ef4:	fc010113          	addi	sp,sp,-64
#endif
  sw x1,   0*4(sp)
    3ef8:	00112023          	sw	ra,0(sp)
  sw x5,   1*4(sp)
    3efc:	00512223          	sw	t0,4(sp)
  sw x6,   2*4(sp)
    3f00:	00612423          	sw	t1,8(sp)
  sw x7,   3*4(sp)
    3f04:	00712623          	sw	t2,12(sp)
  sw x10,  4*4(sp)
    3f08:	00a12823          	sw	a0,16(sp)
  sw x11,  5*4(sp)
    3f0c:	00b12a23          	sw	a1,20(sp)
  sw x12,  6*4(sp)
    3f10:	00c12c23          	sw	a2,24(sp)
  sw x13,  7*4(sp)
    3f14:	00d12e23          	sw	a3,28(sp)
  sw x14,  8*4(sp)
    3f18:	02e12023          	sw	a4,32(sp)
  sw x15,  9*4(sp)
    3f1c:	02f12223          	sw	a5,36(sp)
  sw x16, 10*4(sp)
    3f20:	03012423          	sw	a6,40(sp)
  sw x17, 11*4(sp)
    3f24:	03112623          	sw	a7,44(sp)
  sw x28, 12*4(sp)
    3f28:	03c12823          	sw	t3,48(sp)
  sw x29, 13*4(sp)
    3f2c:	03d12a23          	sw	t4,52(sp)
  sw x30, 14*4(sp)
    3f30:	03e12c23          	sw	t5,56(sp)
  sw x31, 15*4(sp)
    3f34:	03f12e23          	sw	t6,60(sp)
  FSTORE f30, 64 + 18*FPR_SIZE(sp)
  FSTORE f31, 64 + 19*FPR_SIZE(sp)
  csrr t0, fcsr
  sw t0, 64 + 20*FPR_SIZE(sp)
#endif
  call trap
    3f38:	bb4fe0ef          	jal	22ec <trap>
  FLOAD f28, 64 + 16*FPR_SIZE(sp)
  FLOAD f29, 64 + 17*FPR_SIZE(sp)
  FLOAD f30, 64 + 18*FPR_SIZE(sp)
  FLOAD f31, 64 + 19*FPR_SIZE(sp)
#endif
  lw x1 ,  0*4(sp)
    3f3c:	00012083          	lw	ra,0(sp)
  lw x5,   1*4(sp)
    3f40:	00412283          	lw	t0,4(sp)
  lw x6,   2*4(sp)
    3f44:	00812303          	lw	t1,8(sp)
  lw x7,   3*4(sp)
    3f48:	00c12383          	lw	t2,12(sp)
  lw x10,  4*4(sp)
    3f4c:	01012503          	lw	a0,16(sp)
  lw x11,  5*4(sp)
    3f50:	01412583          	lw	a1,20(sp)
  lw x12,  6*4(sp)
    3f54:	01812603          	lw	a2,24(sp)
  lw x13,  7*4(sp)
    3f58:	01c12683          	lw	a3,28(sp)
  lw x14,  8*4(sp)
    3f5c:	02012703          	lw	a4,32(sp)
  lw x15,  9*4(sp)
    3f60:	02412783          	lw	a5,36(sp)
  lw x16, 10*4(sp)
    3f64:	02812803          	lw	a6,40(sp)
  lw x17, 11*4(sp)
    3f68:	02c12883          	lw	a7,44(sp)
  lw x28, 12*4(sp)
    3f6c:	03012e03          	lw	t3,48(sp)
  lw x29, 13*4(sp)
    3f70:	03412e83          	lw	t4,52(sp)
  lw x30, 14*4(sp)
    3f74:	03812f03          	lw	t5,56(sp)
  lw x31, 15*4(sp)
    3f78:	03c12f83          	lw	t6,60(sp)
#ifdef __riscv_flen
  addi sp, sp, STACK_SIZE
#else
  addi sp, sp, 64
    3f7c:	04010113          	addi	sp,sp,64
#endif
    3f80:	30200073          	mret
