
build/ivlabSoftCore.elf:     file format elf32-littleriscv


Disassembly of section .init:

00001000 <_start>:

_start:
#ifdef USE_GP
.option push
.option norelax
	la gp, __global_pointer$
    1000:	0000a197          	auipc	gp,0xa
    1004:	7b018193          	addi	gp,gp,1968 # b7b0 <__global_pointer$>
.global smp_lottery_target
.global smp_lottery_lock
.global smp_slave


  sw x0, smp_lottery_lock, a1
    1008:	0000e597          	auipc	a1,0xe
    100c:	e605ae23          	sw	zero,-388(a1) # ee84 <smp_lottery_lock>

00001010 <smp_tyranny>:

smp_tyranny:
  csrr a0, mhartid
    1010:	f1402573          	csrr	a0,mhartid
  beqz a0, init
    1014:	04050663          	beqz	a0,1060 <init>

00001018 <smp_slave>:

smp_slave:
	lw a0, smp_lottery_lock
    1018:	0000e517          	auipc	a0,0xe
    101c:	e6c52503          	lw	a0,-404(a0) # ee84 <smp_lottery_lock>
	beqz a0, smp_slave
    1020:	fe050ce3          	beqz	a0,1018 <smp_slave>

	fence r, r
    1024:	0220000f          	fence	r,r
    1028:	0000100f          	.word	0x0000100f
	//li a1, -1
	//amoadd.w x0, a1,(a0)

	.word(0x100F) //i$ flush
	lw a5, smp_lottery_target
    102c:	0000e797          	auipc	a5,0xe
    1030:	e547a783          	lw	a5,-428(a5) # ee80 <smp_lottery_target>
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
    1044:	0000e597          	auipc	a1,0xe
    1048:	e2a5ae23          	sw	a0,-452(a1) # ee80 <smp_lottery_target>
	fence w, w
    104c:	0110000f          	fence	w,w
	li a0, 1
    1050:	00100513          	li	a0,1
	sw a0, smp_lottery_lock, a1
    1054:	0000e597          	auipc	a1,0xe
    1058:	e2a5a823          	sw	a0,-464(a1) # ee84 <smp_lottery_lock>
    ret
    105c:	00008067          	ret

00001060 <init>:
#endif

init:
	la sp, _sp
    1060:	0000f117          	auipc	sp,0xf
    1064:	1a010113          	addi	sp,sp,416 # 10200 <__freertos_irq_stack_top>

	/* Load data section */
	la a0, _data_lma
    1068:	00008517          	auipc	a0,0x8
    106c:	92c50513          	addi	a0,a0,-1748 # 8994 <_data>
	la a1, _data
    1070:	00008597          	auipc	a1,0x8
    1074:	92458593          	addi	a1,a1,-1756 # 8994 <_data>
	la a2, _edata
    1078:	0000a617          	auipc	a2,0xa
    107c:	fec60613          	addi	a2,a2,-20 # b064 <__bss_start>
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
    1098:	0000a517          	auipc	a0,0xa
    109c:	fcc50513          	addi	a0,a0,-52 # b064 <__bss_start>
	la a1, _end
    10a0:	0000e597          	auipc	a1,0xe
    10a4:	16058593          	addi	a1,a1,352 # f200 <_end>
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
    10b8:	018000ef          	jal	10d0 <__libc_init_array>
#endif

	call main
    10bc:	0a8000ef          	jal	1164 <main>

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

000010d0 <__libc_init_array>:
    10d0:	ff010113          	addi	sp,sp,-16
    10d4:	00812423          	sw	s0,8(sp)
    10d8:	01212023          	sw	s2,0(sp)
    10dc:	00008797          	auipc	a5,0x8
    10e0:	8b878793          	addi	a5,a5,-1864 # 8994 <_data>
    10e4:	00008417          	auipc	s0,0x8
    10e8:	8b040413          	addi	s0,s0,-1872 # 8994 <_data>
    10ec:	00112623          	sw	ra,12(sp)
    10f0:	00912223          	sw	s1,4(sp)
    10f4:	40878933          	sub	s2,a5,s0
    10f8:	02878063          	beq	a5,s0,1118 <__libc_init_array+0x48>
    10fc:	40295913          	srai	s2,s2,0x2
    1100:	00000493          	li	s1,0
    1104:	00042783          	lw	a5,0(s0)
    1108:	00148493          	addi	s1,s1,1
    110c:	00440413          	addi	s0,s0,4
    1110:	000780e7          	jalr	a5
    1114:	ff24e8e3          	bltu	s1,s2,1104 <__libc_init_array+0x34>
    1118:	00008797          	auipc	a5,0x8
    111c:	87c78793          	addi	a5,a5,-1924 # 8994 <_data>
    1120:	00008417          	auipc	s0,0x8
    1124:	87440413          	addi	s0,s0,-1932 # 8994 <_data>
    1128:	40878933          	sub	s2,a5,s0
    112c:	40295913          	srai	s2,s2,0x2
    1130:	00878e63          	beq	a5,s0,114c <__libc_init_array+0x7c>
    1134:	00000493          	li	s1,0
    1138:	00042783          	lw	a5,0(s0)
    113c:	00148493          	addi	s1,s1,1
    1140:	00440413          	addi	s0,s0,4
    1144:	000780e7          	jalr	a5
    1148:	ff24e8e3          	bltu	s1,s2,1138 <__libc_init_array+0x68>
    114c:	00c12083          	lw	ra,12(sp)
    1150:	00812403          	lw	s0,8(sp)
    1154:	00412483          	lw	s1,4(sp)
    1158:	00012903          	lw	s2,0(sp)
    115c:	01010113          	addi	sp,sp,16
    1160:	00008067          	ret

00001164 <main>:
*         proto_uart_init()  配置 uart1 和它的中断源
*         isr_init()      最后才打开中断总开关
*       把 isr_init() 放在最后是关键的：如果先开中断再配 uart1，
*       中间那个窗口里进来的中断会找不到正确的处理路径。
******************************************************************************/
void main() {
    1164:	fd010113          	addi	sp,sp,-48
    1168:	02112623          	sw	ra,44(sp)
    bsp_init();                 /* BSP 的通用初始化，其中包含 uart0 的配置 */
    116c:	330020ef          	jal	349c <bsp_init>
    app_log_init();
    1170:	04c020ef          	jal	31bc <app_log_init>
    frame_parser_init(&s_parser);
    1174:	0000f537          	lui	a0,0xf
    1178:	c5050513          	addi	a0,a0,-944 # ec50 <s_parser>
    117c:	52d020ef          	jal	3ea8 <frame_parser_init>
    protocol_init(&s_stats);
    1180:	0000f537          	lui	a0,0xf
    1184:	c4450513          	addi	a0,a0,-956 # ec44 <s_stats>
    1188:	648030ef          	jal	47d0 <protocol_init>
    /* 引擎初始化会清两块画布、渲染并提交第一屏，所以上电即有菜单。
     * 它排在 isr_init() 之前：这期间要写几千次 AXI，中断还没开就不会有
     * 字节挤在接收环里等 —— 虽然不会丢，但没必要留这个尾巴。*/
    osd_engine_boot();
    118c:	469030ef          	jal	4df4 <osd_engine_boot>

    /* 启动横幅。这几行主要是给现场确认"固件确实跑起来了"用的。
     * 把协议出处一并打出来：这条串口线上跑着好几个功能模块的帧，出问题时
     * 第一件要确认的就是"两端说的是不是同一代协议"。*/
    app_log("*** ivlabSoftCore ***");
    1190:	00009537          	lui	a0,0x9
    1194:	e3c50513          	addi	a0,a0,-452 # 8e3c <_data+0x4a8>
    1198:	124020ef          	jal	32bc <app_log>
    app_log("debug channel: semihosting (JTAG)");
    119c:	00009537          	lui	a0,0x9
    11a0:	e5450513          	addi	a0,a0,-428 # 8e54 <_data+0x4c0>
    11a4:	118020ef          	jal	32bc <app_log>
    app_log("protocol: BB frame, categories 0x00 (mask) + 0x04 (UI)");
    11a8:	00009537          	lui	a0,0x9
    11ac:	e7850513          	addi	a0,a0,-392 # 8e78 <_data+0x4e4>
    11b0:	10c020ef          	jal	32bc <app_log>
    app_log("osd: menu on OSD1 544x208 1bpp, canvas A/B = 0x%x / 0x%x",
    11b4:	00b40637          	lui	a2,0xb40
    11b8:	00a405b7          	lui	a1,0xa40
    11bc:	00009537          	lui	a0,0x9
    11c0:	eb050513          	addi	a0,a0,-336 # 8eb0 <_data+0x51c>
    11c4:	0f8020ef          	jal	32bc <app_log>

#if OSD_BOOT_DIAG
    /* 紧接着上电渲染做一次硬件回读。**排在 isr_init() 之前**：这一段要打
     * 几千字符、每次 semihosting 都会让 hart 停一下，中断还没开就不会挤爆
     * uart1 的接收 FIFO。理由与 osd_engine_boot() 排在同一个位置相同。*/
    osd_boot_diag();
    11c8:	115020ef          	jal	3adc <osd_boot_diag>

    /* 协议端点可用与否，取决于 SoC 是否生成了 uart1（见 proto_uart.h）。
     * 这里把结果明确打出来：一是让现场知道协议能不能用，二是它的 base 地址
     * 可以和 RTL 侧的 rtl_mask_mode 取值交叉核对，确认"只有一个端点在应答"。*/
    if (PROTO_ENDPOINT_AVAILABLE) {
        proto_uart_init();
    11cc:	0bc030ef          	jal	4288 <proto_uart_init>
        isr_init();
    11d0:	33c020ef          	jal	350c <isr_init>
        app_log("protocol endpoint: ENABLED on uart1 (base 0x%x)",
    11d4:	f80025b7          	lui	a1,0xf8002
    11d8:	00009537          	lui	a0,0x9
    11dc:	eec50513          	addi	a0,a0,-276 # 8eec <_data+0x558>
    11e0:	0dc020ef          	jal	32bc <app_log>
    11e4:	0340006f          	j	1218 <main+0xb4>
         * 这样做的代价是日志不再"实时"——但换来的是协议本身可靠，而且那批
         * 日志会在结束后的 200 ms 内完整出现，排查并不受影响。
         *
         * 另外注意：**画布渲染不在这个循环里**，它随命令在 osd_engine_handle()
         * 里同步完成。所以"线路静默"这条门槛只推迟日志、不推迟画面。*/
        if ((app_log_pending() != 0U) || (s_frames_processed != s_reported_frames)) {
    11e8:	7e9010ef          	jal	31d0 <app_log_pending>
    11ec:	00051863          	bnez	a0,11fc <main+0x98>
    11f0:	8fc1a703          	lw	a4,-1796(gp) # b0ac <s_frames_processed>
    11f4:	8dc1a783          	lw	a5,-1828(gp) # b08c <s_reported_frames>
    11f8:	02f70063          	beq	a4,a5,1218 <main+0xb4>
            /* 读 CLINT 时间是 3 次 MMIO，不能每轮都做；用计数器粗降频。*/
            s_idle_spins++;
    11fc:	8d81a783          	lw	a5,-1832(gp) # b088 <s_idle_spins>
    1200:	00178793          	addi	a5,a5,1
    1204:	8cf1ac23          	sw	a5,-1832(gp) # b088 <s_idle_spins>
            if ((s_idle_spins & (IDLE_TICKS_DIVIDER - 1U)) == 0U) {
    1208:	00001737          	lui	a4,0x1
    120c:	fff70713          	addi	a4,a4,-1 # fff <CUSTOM2+0xfa4>
    1210:	00e7f7b3          	and	a5,a5,a4
    1214:	04078263          	beqz	a5,1258 <main+0xf4>
        while (proto_uart_rx_pop(&byte)) {
    1218:	00710513          	addi	a0,sp,7
    121c:	100030ef          	jal	431c <proto_uart_rx_pop>
    1220:	fc0504e3          	beqz	a0,11e8 <main+0x84>
            s_last_rx_ticks = clint_getTime(BSP_CLINT);
    1224:	f8b00537          	lui	a0,0xf8b00
    1228:	244020ef          	jal	346c <clint_getTime>
    122c:	8ea1a023          	sw	a0,-1824(gp) # b090 <s_last_rx_ticks>
    1230:	8eb1a223          	sw	a1,-1820(gp) # b094 <s_last_rx_ticks+0x4>
            if (frame_parser_feed(&s_parser, byte, &frame) != 0) {
    1234:	00810613          	addi	a2,sp,8
    1238:	00714583          	lbu	a1,7(sp)
    123c:	0000f537          	lui	a0,0xf
    1240:	c5050513          	addi	a0,a0,-944 # ec50 <s_parser>
    1244:	4b9020ef          	jal	3efc <frame_parser_feed>
    1248:	fc0508e3          	beqz	a0,1218 <main+0xb4>
                handle_frame(&frame);
    124c:	00810513          	addi	a0,sp,8
    1250:	2b5020ef          	jal	3d04 <handle_frame>
    1254:	fc5ff06f          	j	1218 <main+0xb4>
                if ((clint_getTime(BSP_CLINT) - s_last_rx_ticks) >= APP_LOG_IDLE_TICKS) {
    1258:	f8b00537          	lui	a0,0xf8b00
    125c:	210020ef          	jal	346c <clint_getTime>
    1260:	8e01a783          	lw	a5,-1824(gp) # b090 <s_last_rx_ticks>
    1264:	8e41a703          	lw	a4,-1820(gp) # b094 <s_last_rx_ticks+0x4>
    1268:	40f507b3          	sub	a5,a0,a5
    126c:	00f53533          	sltu	a0,a0,a5
    1270:	40e585b3          	sub	a1,a1,a4
    1274:	40a58733          	sub	a4,a1,a0
    1278:	00a59a63          	bne	a1,a0,128c <main+0x128>
    127c:	f8071ee3          	bnez	a4,1218 <main+0xb4>
    1280:	00989737          	lui	a4,0x989
    1284:	67f70713          	addi	a4,a4,1663 # 98967f <__freertos_irq_stack_top+0x97947f>
    1288:	f8f778e3          	bgeu	a4,a5,1218 <main+0xb4>
                    /* 线路静默够久，说明这一批数据结束了。先补一条汇总，
                     * 保证"这一批收了多少、丢了多少"一定可见——短跑批够不到
                     * STATS_INTERVAL，没有这一条就什么都看不到。*/
                    if (s_frames_processed != s_reported_frames) {
    128c:	8fc1a703          	lw	a4,-1796(gp) # b0ac <s_frames_processed>
    1290:	8dc1a783          	lw	a5,-1828(gp) # b08c <s_reported_frames>
    1294:	00f71663          	bne	a4,a5,12a0 <main+0x13c>
                        log_stats();
                    }
                    (void)app_log_flush();
    1298:	0c8020ef          	jal	3360 <app_log_flush>
    while (1) {
    129c:	f7dff06f          	j	1218 <main+0xb4>
                        log_stats();
    12a0:	1a5020ef          	jal	3c44 <log_stats>
    12a4:	ff5ff06f          	j	1298 <main+0x134>
	...

000012b0 <sh_write0>:
* @note    None.
*
******************************************************************************/

static void sh_write0(char* buf)
{
    12b0:	00050593          	mv	a1,a0
    register int value asm ("a0") = reason;
    12b4:	00400513          	li	a0,4
    register void* ptr asm ("a1") = arg;
    12b8:	00000013          	nop
    12bc:	00000013          	nop
    asm volatile (
    12c0:	01f01013          	slli	zero,zero,0x1f
    12c4:	00100073          	ebreak
    12c8:	40705013          	srai	zero,zero,0x7
    12cc:	00000013          	nop
    // Print zero-terminated string
    call_host(SEMIHOSTING_SYS_WRITE0, (void*) buf);
}
    12d0:	00008067          	ret
    12d4:	00000013          	nop
    12d8:	00000013          	nop

000012dc <_putchar_s>:
            bsp_putChar(character);
        #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }

    static void _putchar_s(char *p)
    {
    12dc:	ff010113          	addi	sp,sp,-16
    12e0:	00112623          	sw	ra,12(sp)
    #if (ENABLE_SEMIHOSTING_PRINT == 1)
        sh_write0(p);
    12e4:	fcdff0ef          	jal	12b0 <sh_write0>
    #else
        while (*p)
            _putchar(*(p++));
    #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }
    12e8:	00c12083          	lw	ra,12(sp)
    12ec:	01010113          	addi	sp,sp,16
    12f0:	00008067          	ret

000012f4 <_out_buffer>:
*
******************************************************************************/

static inline void _out_buffer(char character, void* buffer, size_t idx, size_t maxlen)
{
  if (idx < maxlen) {
    12f4:	00d67663          	bgeu	a2,a3,1300 <_out_buffer+0xc>
    ((char*)buffer)[idx] = character;
    12f8:	00c585b3          	add	a1,a1,a2
    12fc:	00a58023          	sb	a0,0(a1) # f8002000 <__freertos_irq_stack_top+0xf7ff1e00>
  }
}
    1300:	00008067          	ret

00001304 <_out_null>:
*
******************************************************************************/
static inline void _out_null(char character, void* buffer, size_t idx, size_t maxlen)
{
  (void)character; (void)buffer; (void)idx; (void)maxlen;
}
    1304:	00008067          	ret

00001308 <_atoi>:
*
* @return Converted unsigned integer value.
*
******************************************************************************/
static unsigned int _atoi(const char** str)
{
    1308:	00050693          	mv	a3,a0
  unsigned int i = 0U;
    130c:	00000513          	li	a0,0
  while (_is_digit(**str)) {
    1310:	0240006f          	j	1334 <_atoi+0x2c>
    i = i * 10U + (unsigned int)(*((*str)++) - '0');
    1314:	00251793          	slli	a5,a0,0x2
    1318:	00a787b3          	add	a5,a5,a0
    131c:	00179793          	slli	a5,a5,0x1
    1320:	00170613          	addi	a2,a4,1
    1324:	00c6a023          	sw	a2,0(a3)
    1328:	00074503          	lbu	a0,0(a4)
    132c:	00f50533          	add	a0,a0,a5
    1330:	fd050513          	addi	a0,a0,-48 # f8afffd0 <__freertos_irq_stack_top+0xf8aefdd0>
  while (_is_digit(**str)) {
    1334:	0006a703          	lw	a4,0(a3)
    1338:	00074783          	lbu	a5,0(a4)
  return (ch >= '0') && (ch <= '9');
    133c:	fd078793          	addi	a5,a5,-48
    1340:	0ff7f793          	zext.b	a5,a5
  while (_is_digit(**str)) {
    1344:	00900613          	li	a2,9
    1348:	fcf676e3          	bgeu	a2,a5,1314 <_atoi+0xc>
  }
  return i;
}
    134c:	00008067          	ret

00001350 <_out_rev>:
*
* @return Updated index in the buffer after outputting the string.
*
******************************************************************************/
static size_t _out_rev(out_fct_type out, char* buffer, size_t idx, size_t maxlen, const char* buf, size_t len, unsigned int width, unsigned int flags)
{
    1350:	fd010113          	addi	sp,sp,-48
    1354:	02112623          	sw	ra,44(sp)
    1358:	02812423          	sw	s0,40(sp)
    135c:	02912223          	sw	s1,36(sp)
    1360:	03212023          	sw	s2,32(sp)
    1364:	01312e23          	sw	s3,28(sp)
    1368:	01412c23          	sw	s4,24(sp)
    136c:	01512a23          	sw	s5,20(sp)
    1370:	01612823          	sw	s6,16(sp)
    1374:	01712623          	sw	s7,12(sp)
    1378:	01812423          	sw	s8,8(sp)
    137c:	00050493          	mv	s1,a0
    1380:	00058913          	mv	s2,a1
    1384:	00060b93          	mv	s7,a2
    1388:	00068993          	mv	s3,a3
    138c:	00070b13          	mv	s6,a4
    1390:	00078413          	mv	s0,a5
    1394:	00080a93          	mv	s5,a6
    1398:	00088c13          	mv	s8,a7
  const size_t start_idx = idx;

  // pad spaces up to given width
  if (!(flags & FLAGS_LEFT) && !(flags & FLAGS_ZEROPAD)) {
    139c:	0038f793          	andi	a5,a7,3
    13a0:	04079c63          	bnez	a5,13f8 <_out_rev+0xa8>
    13a4:	01912223          	sw	s9,4(sp)
    for (size_t i = len; i < width; i++) {
    13a8:	00040a13          	mv	s4,s0
    13ac:	035a7263          	bgeu	s4,s5,13d0 <_out_rev+0x80>
      out(' ', buffer, idx++, maxlen);
    13b0:	00160c93          	addi	s9,a2,1 # b40001 <__freertos_irq_stack_top+0xb2fe01>
    13b4:	00098693          	mv	a3,s3
    13b8:	00090593          	mv	a1,s2
    13bc:	02000513          	li	a0,32
    13c0:	000480e7          	jalr	s1
    for (size_t i = len; i < width; i++) {
    13c4:	001a0a13          	addi	s4,s4,1
      out(' ', buffer, idx++, maxlen);
    13c8:	000c8613          	mv	a2,s9
    13cc:	fe1ff06f          	j	13ac <_out_rev+0x5c>
    13d0:	00412c83          	lw	s9,4(sp)
    13d4:	0240006f          	j	13f8 <_out_rev+0xa8>
    }
  }

  // reverse string
  while (len) {
    out(buf[--len], buffer, idx++, maxlen);
    13d8:	fff40413          	addi	s0,s0,-1
    13dc:	008b07b3          	add	a5,s6,s0
    13e0:	00160a13          	addi	s4,a2,1
    13e4:	00098693          	mv	a3,s3
    13e8:	00090593          	mv	a1,s2
    13ec:	0007c503          	lbu	a0,0(a5)
    13f0:	000480e7          	jalr	s1
    13f4:	000a0613          	mv	a2,s4
  while (len) {
    13f8:	fe0410e3          	bnez	s0,13d8 <_out_rev+0x88>
  }

  // append pad spaces up to given width
  if (flags & FLAGS_LEFT) {
    13fc:	002c7c13          	andi	s8,s8,2
    1400:	020c1c63          	bnez	s8,1438 <_out_rev+0xe8>
      out(' ', buffer, idx++, maxlen);
    }
  }

  return idx;
}
    1404:	00060513          	mv	a0,a2
    1408:	02c12083          	lw	ra,44(sp)
    140c:	02812403          	lw	s0,40(sp)
    1410:	02412483          	lw	s1,36(sp)
    1414:	02012903          	lw	s2,32(sp)
    1418:	01c12983          	lw	s3,28(sp)
    141c:	01812a03          	lw	s4,24(sp)
    1420:	01412a83          	lw	s5,20(sp)
    1424:	01012b03          	lw	s6,16(sp)
    1428:	00c12b83          	lw	s7,12(sp)
    142c:	00812c03          	lw	s8,8(sp)
    1430:	03010113          	addi	sp,sp,48
    1434:	00008067          	ret
    while (idx - start_idx < width) {
    1438:	417607b3          	sub	a5,a2,s7
    143c:	fd57f4e3          	bgeu	a5,s5,1404 <_out_rev+0xb4>
      out(' ', buffer, idx++, maxlen);
    1440:	00160413          	addi	s0,a2,1
    1444:	00098693          	mv	a3,s3
    1448:	00090593          	mv	a1,s2
    144c:	02000513          	li	a0,32
    1450:	000480e7          	jalr	s1
    1454:	00040613          	mv	a2,s0
    1458:	fe1ff06f          	j	1438 <_out_rev+0xe8>

0000145c <_ntoa_format>:
*
* @return Number of characters written to the buffer.
*
******************************************************************************/
static size_t _ntoa_format(out_fct_type out, char* buffer, size_t idx, size_t maxlen, char* buf, size_t len, bool negative, unsigned int base, unsigned int prec, unsigned int width, unsigned int flags)
{
    145c:	ff010113          	addi	sp,sp,-16
    1460:	00112623          	sw	ra,12(sp)
    1464:	00080f93          	mv	t6,a6
    1468:	00088f13          	mv	t5,a7
    146c:	01012e83          	lw	t4,16(sp)
    1470:	01412803          	lw	a6,20(sp)
    1474:	01812883          	lw	a7,24(sp)
  // pad leading zeros
  if (!(flags & FLAGS_LEFT)) {
    1478:	0028f313          	andi	t1,a7,2
    147c:	06031463          	bnez	t1,14e4 <_ntoa_format+0x88>
    if (width && (flags & FLAGS_ZEROPAD) && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
    1480:	02080863          	beqz	a6,14b0 <_ntoa_format+0x54>
    1484:	0018f313          	andi	t1,a7,1
    1488:	02030463          	beqz	t1,14b0 <_ntoa_format+0x54>
    148c:	000f9663          	bnez	t6,1498 <_ntoa_format+0x3c>
    1490:	00c8f313          	andi	t1,a7,12
    1494:	00030e63          	beqz	t1,14b0 <_ntoa_format+0x54>
      width--;
    1498:	fff80813          	addi	a6,a6,-1
    149c:	0140006f          	j	14b0 <_ntoa_format+0x54>
    }
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = '0';
    14a0:	00f70333          	add	t1,a4,a5
    14a4:	03000e13          	li	t3,48
    14a8:	01c30023          	sb	t3,0(t1)
    14ac:	00178793          	addi	a5,a5,1
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    14b0:	01d7f663          	bgeu	a5,t4,14bc <_ntoa_format+0x60>
    14b4:	01f00313          	li	t1,31
    14b8:	fef374e3          	bgeu	t1,a5,14a0 <_ntoa_format+0x44>
    }
    while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    14bc:	0018f313          	andi	t1,a7,1
    14c0:	02030263          	beqz	t1,14e4 <_ntoa_format+0x88>
    14c4:	0307f063          	bgeu	a5,a6,14e4 <_ntoa_format+0x88>
    14c8:	01f00313          	li	t1,31
    14cc:	00f36c63          	bltu	t1,a5,14e4 <_ntoa_format+0x88>
      buf[len++] = '0';
    14d0:	00f70333          	add	t1,a4,a5
    14d4:	03000e13          	li	t3,48
    14d8:	01c30023          	sb	t3,0(t1)
    14dc:	00178793          	addi	a5,a5,1
    14e0:	fddff06f          	j	14bc <_ntoa_format+0x60>
    }
  }

  // handle hash
  if (flags & FLAGS_HASH) {
    14e4:	0108f313          	andi	t1,a7,16
    14e8:	04030063          	beqz	t1,1528 <_ntoa_format+0xcc>
    if (!(flags & FLAGS_PRECISION) && len && ((len == prec) || (len == width))) {
    14ec:	4008f313          	andi	t1,a7,1024
    14f0:	00031863          	bnez	t1,1500 <_ntoa_format+0xa4>
    14f4:	00078663          	beqz	a5,1500 <_ntoa_format+0xa4>
    14f8:	05d78e63          	beq	a5,t4,1554 <_ntoa_format+0xf8>
    14fc:	05078c63          	beq	a5,a6,1554 <_ntoa_format+0xf8>
      len--;
      if (len && (base == 16U)) {
        len--;
      }
    }
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1500:	01000313          	li	t1,16
    1504:	0a6f0063          	beq	t5,t1,15a4 <_ntoa_format+0x148>
      buf[len++] = 'x';
    }
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = 'X';
    }
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1508:	00200313          	li	t1,2
    150c:	0a6f0e63          	beq	t5,t1,15c8 <_ntoa_format+0x16c>
      buf[len++] = 'b';
    }
    if (len < PRINTF_NTOA_BUFFER_SIZE) {
    1510:	01f00313          	li	t1,31
    1514:	02f36863          	bltu	t1,a5,1544 <_ntoa_format+0xe8>
      buf[len++] = '0';
    1518:	00f70333          	add	t1,a4,a5
    151c:	03000e13          	li	t3,48
    1520:	01c30023          	sb	t3,0(t1)
    1524:	00178793          	addi	a5,a5,1
    }
  }

  if (len < PRINTF_NTOA_BUFFER_SIZE) {
    1528:	01f00313          	li	t1,31
    152c:	00f36c63          	bltu	t1,a5,1544 <_ntoa_format+0xe8>
    if (negative) {
    1530:	0a0f8a63          	beqz	t6,15e4 <_ntoa_format+0x188>
      buf[len++] = '-';
    1534:	00f70333          	add	t1,a4,a5
    1538:	02d00e13          	li	t3,45
    153c:	01c30023          	sb	t3,0(t1)
    1540:	00178793          	addi	a5,a5,1
    else if (flags & FLAGS_SPACE) {
      buf[len++] = ' ';
    }
  }

  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
    1544:	e0dff0ef          	jal	1350 <_out_rev>
}
    1548:	00c12083          	lw	ra,12(sp)
    154c:	01010113          	addi	sp,sp,16
    1550:	00008067          	ret
      len--;
    1554:	fff78313          	addi	t1,a5,-1
      if (len && (base == 16U)) {
    1558:	04030263          	beqz	t1,159c <_ntoa_format+0x140>
    155c:	01000e13          	li	t3,16
    1560:	03cf0a63          	beq	t5,t3,1594 <_ntoa_format+0x138>
      len--;
    1564:	00030793          	mv	a5,t1
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1568:	01000313          	li	t1,16
    156c:	f86f1ee3          	bne	t5,t1,1508 <_ntoa_format+0xac>
    1570:	0208f313          	andi	t1,a7,32
    1574:	f8030ae3          	beqz	t1,1508 <_ntoa_format+0xac>
    1578:	01f00313          	li	t1,31
    157c:	f8f366e3          	bltu	t1,a5,1508 <_ntoa_format+0xac>
      buf[len++] = 'X';
    1580:	00f70333          	add	t1,a4,a5
    1584:	05800e13          	li	t3,88
    1588:	01c30023          	sb	t3,0(t1)
    158c:	00178793          	addi	a5,a5,1
    1590:	f81ff06f          	j	1510 <_ntoa_format+0xb4>
        len--;
    1594:	ffe78793          	addi	a5,a5,-2
    1598:	f69ff06f          	j	1500 <_ntoa_format+0xa4>
      len--;
    159c:	00030793          	mv	a5,t1
    15a0:	f61ff06f          	j	1500 <_ntoa_format+0xa4>
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    15a4:	0208f313          	andi	t1,a7,32
    15a8:	fc0310e3          	bnez	t1,1568 <_ntoa_format+0x10c>
    15ac:	01f00313          	li	t1,31
    15b0:	faf36ce3          	bltu	t1,a5,1568 <_ntoa_format+0x10c>
      buf[len++] = 'x';
    15b4:	00f70333          	add	t1,a4,a5
    15b8:	07800e13          	li	t3,120
    15bc:	01c30023          	sb	t3,0(t1)
    15c0:	00178793          	addi	a5,a5,1
    15c4:	f4dff06f          	j	1510 <_ntoa_format+0xb4>
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    15c8:	01f00313          	li	t1,31
    15cc:	f6f36ce3          	bltu	t1,a5,1544 <_ntoa_format+0xe8>
      buf[len++] = 'b';
    15d0:	00f70333          	add	t1,a4,a5
    15d4:	06200e13          	li	t3,98
    15d8:	01c30023          	sb	t3,0(t1)
    15dc:	00178793          	addi	a5,a5,1
    15e0:	f31ff06f          	j	1510 <_ntoa_format+0xb4>
    else if (flags & FLAGS_PLUS) {
    15e4:	0048f313          	andi	t1,a7,4
    15e8:	00030c63          	beqz	t1,1600 <_ntoa_format+0x1a4>
      buf[len++] = '+';  // ignore the space if the '+' exists
    15ec:	00f70333          	add	t1,a4,a5
    15f0:	02b00e13          	li	t3,43
    15f4:	01c30023          	sb	t3,0(t1)
    15f8:	00178793          	addi	a5,a5,1
    15fc:	f49ff06f          	j	1544 <_ntoa_format+0xe8>
    else if (flags & FLAGS_SPACE) {
    1600:	0088f313          	andi	t1,a7,8
    1604:	f40300e3          	beqz	t1,1544 <_ntoa_format+0xe8>
      buf[len++] = ' ';
    1608:	00f70333          	add	t1,a4,a5
    160c:	02000e13          	li	t3,32
    1610:	01c30023          	sb	t3,0(t1)
    1614:	00178793          	addi	a5,a5,1
    1618:	f2dff06f          	j	1544 <_ntoa_format+0xe8>

0000161c <_ntoa_long>:
* @return Number of characters written to the buffer.
*
*
******************************************************************************/
static size_t _ntoa_long(out_fct_type out, char* buffer, size_t idx, size_t maxlen, unsigned long value, bool negative, unsigned long base, unsigned int prec, unsigned int width, unsigned int flags)
{
    161c:	fc010113          	addi	sp,sp,-64
    1620:	02112e23          	sw	ra,60(sp)
    1624:	00078f93          	mv	t6,a5
    1628:	04412f03          	lw	t5,68(sp)
  char buf[PRINTF_NTOA_BUFFER_SIZE];
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
    162c:	00071463          	bnez	a4,1634 <_ntoa_long+0x18>
    flags &= ~FLAGS_HASH;
    1630:	feff7f13          	andi	t5,t5,-17
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
    1634:	400f7e93          	andi	t4,t5,1024
    1638:	040e8063          	beqz	t4,1678 <_ntoa_long+0x5c>
    163c:	06070a63          	beqz	a4,16b0 <_ntoa_long+0x94>
    1640:	00000e93          	li	t4,0
    1644:	0340006f          	j	1678 <_ntoa_long+0x5c>
    do {
      const char digit = (char)(value % base);
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1648:	030e0e13          	addi	t3,t3,48
    164c:	0ffe7313          	zext.b	t1,t3
    1650:	001e8793          	addi	a5,t4,1
    1654:	030e8e13          	addi	t3,t4,48
    1658:	002e0eb3          	add	t4,t3,sp
    165c:	fe6e8023          	sb	t1,-32(t4)
      value /= base;
    1660:	03075333          	divu	t1,a4,a6
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    1664:	05076863          	bltu	a4,a6,16b4 <_ntoa_long+0x98>
    1668:	01f00713          	li	a4,31
    166c:	04f76463          	bltu	a4,a5,16b4 <_ntoa_long+0x98>
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1670:	00078e93          	mv	t4,a5
      value /= base;
    1674:	00030713          	mv	a4,t1
      const char digit = (char)(value % base);
    1678:	03077e33          	remu	t3,a4,a6
    167c:	0ffe7e13          	zext.b	t3,t3
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1680:	00900313          	li	t1,9
    1684:	fdc372e3          	bgeu	t1,t3,1648 <_ntoa_long+0x2c>
    1688:	020f7313          	andi	t1,t5,32
    168c:	00030e63          	beqz	t1,16a8 <_ntoa_long+0x8c>
    1690:	04100313          	li	t1,65
    1694:	01c30333          	add	t1,t1,t3
    1698:	0ff37313          	zext.b	t1,t1
    169c:	ff630313          	addi	t1,t1,-10
    16a0:	0ff37313          	zext.b	t1,t1
    16a4:	fadff06f          	j	1650 <_ntoa_long+0x34>
    16a8:	06100313          	li	t1,97
    16ac:	fe9ff06f          	j	1694 <_ntoa_long+0x78>
  size_t len = 0U;
    16b0:	00070793          	mv	a5,a4
  }

  return _ntoa_format(out, buffer, idx, maxlen, buf, len, negative, (unsigned int)base, prec, width, flags);
    16b4:	01e12423          	sw	t5,8(sp)
    16b8:	04012703          	lw	a4,64(sp)
    16bc:	00e12223          	sw	a4,4(sp)
    16c0:	01112023          	sw	a7,0(sp)
    16c4:	00080893          	mv	a7,a6
    16c8:	000f8813          	mv	a6,t6
    16cc:	01010713          	addi	a4,sp,16
    16d0:	d8dff0ef          	jal	145c <_ntoa_format>
}
    16d4:	03c12083          	lw	ra,60(sp)
    16d8:	04010113          	addi	sp,sp,64
    16dc:	00008067          	ret

000016e0 <_ntoa_long_long>:
*
* @return Number of characters written to the buffer.
*
******************************************************************************/
static size_t _ntoa_long_long(out_fct_type out, char* buffer, size_t idx, size_t maxlen, unsigned long long value, bool negative, unsigned long long base, unsigned int prec, unsigned int width, unsigned int flags)
{
    16e0:	f8010113          	addi	sp,sp,-128
    16e4:	06112623          	sw	ra,108(sp)
    16e8:	06812423          	sw	s0,104(sp)
    16ec:	06912223          	sw	s1,100(sp)
    16f0:	07212023          	sw	s2,96(sp)
    16f4:	05312e23          	sw	s3,92(sp)
    16f8:	05412c23          	sw	s4,88(sp)
    16fc:	05512a23          	sw	s5,84(sp)
    1700:	05612823          	sw	s6,80(sp)
    1704:	05712623          	sw	s7,76(sp)
    1708:	05812423          	sw	s8,72(sp)
    170c:	05912223          	sw	s9,68(sp)
    1710:	05a12023          	sw	s10,64(sp)
    1714:	03b12e23          	sw	s11,60(sp)
    1718:	00050b93          	mv	s7,a0
    171c:	00058c13          	mv	s8,a1
    1720:	00060c93          	mv	s9,a2
    1724:	00068d13          	mv	s10,a3
    1728:	00070993          	mv	s3,a4
    172c:	00078413          	mv	s0,a5
    1730:	00080d93          	mv	s11,a6
    1734:	07112e23          	sw	a7,124(sp)
    1738:	00088a93          	mv	s5,a7
    173c:	08012903          	lw	s2,128(sp)
    1740:	08c12b03          	lw	s6,140(sp)
  char buf[PRINTF_NTOA_BUFFER_SIZE];
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
    1744:	00f767b3          	or	a5,a4,a5
    1748:	00079463          	bnez	a5,1750 <_ntoa_long_long+0x70>
    flags &= ~FLAGS_HASH;
    174c:	fefb7b13          	andi	s6,s6,-17
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
    1750:	400b7493          	andi	s1,s6,1024
    1754:	04048e63          	beqz	s1,17b0 <_ntoa_long_long+0xd0>
    1758:	0089e7b3          	or	a5,s3,s0
    175c:	0a078263          	beqz	a5,1800 <_ntoa_long_long+0x120>
    1760:	00000493          	li	s1,0
    1764:	04c0006f          	j	17b0 <_ntoa_long_long+0xd0>
    do {
      const char digit = (char)(value % base);
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1768:	03050513          	addi	a0,a0,48
    176c:	0ff57793          	zext.b	a5,a0
    1770:	00148a13          	addi	s4,s1,1
    1774:	03048713          	addi	a4,s1,48
    1778:	002704b3          	add	s1,a4,sp
    177c:	fef48023          	sb	a5,-32(s1)
      value /= base;
    1780:	000a8613          	mv	a2,s5
    1784:	00090693          	mv	a3,s2
    1788:	00098513          	mv	a0,s3
    178c:	00040593          	mv	a1,s0
    1790:	31c040ef          	jal	5aac <__udivdi3>
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    1794:	07246863          	bltu	s0,s2,1804 <_ntoa_long_long+0x124>
    1798:	06890063          	beq	s2,s0,17f8 <_ntoa_long_long+0x118>
    179c:	01f00793          	li	a5,31
    17a0:	0747e263          	bltu	a5,s4,1804 <_ntoa_long_long+0x124>
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    17a4:	000a0493          	mv	s1,s4
      value /= base;
    17a8:	00050993          	mv	s3,a0
    17ac:	00058413          	mv	s0,a1
      const char digit = (char)(value % base);
    17b0:	000a8613          	mv	a2,s5
    17b4:	00090693          	mv	a3,s2
    17b8:	00098513          	mv	a0,s3
    17bc:	00040593          	mv	a1,s0
    17c0:	79c040ef          	jal	5f5c <__umoddi3>
    17c4:	0ff57513          	zext.b	a0,a0
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    17c8:	00900793          	li	a5,9
    17cc:	f8a7fee3          	bgeu	a5,a0,1768 <_ntoa_long_long+0x88>
    17d0:	020b7793          	andi	a5,s6,32
    17d4:	00078e63          	beqz	a5,17f0 <_ntoa_long_long+0x110>
    17d8:	04100793          	li	a5,65
    17dc:	00a787b3          	add	a5,a5,a0
    17e0:	0ff7f793          	zext.b	a5,a5
    17e4:	ff678793          	addi	a5,a5,-10
    17e8:	0ff7f793          	zext.b	a5,a5
    17ec:	f85ff06f          	j	1770 <_ntoa_long_long+0x90>
    17f0:	06100793          	li	a5,97
    17f4:	fe9ff06f          	j	17dc <_ntoa_long_long+0xfc>
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    17f8:	fb59f2e3          	bgeu	s3,s5,179c <_ntoa_long_long+0xbc>
    17fc:	0080006f          	j	1804 <_ntoa_long_long+0x124>
  size_t len = 0U;
    1800:	00000a13          	li	s4,0
  }

  return _ntoa_format(out, buffer, idx, maxlen, buf, len, negative, (unsigned int)base, prec, width, flags);
    1804:	01612423          	sw	s6,8(sp)
    1808:	08812783          	lw	a5,136(sp)
    180c:	00f12223          	sw	a5,4(sp)
    1810:	08412783          	lw	a5,132(sp)
    1814:	00f12023          	sw	a5,0(sp)
    1818:	000a8893          	mv	a7,s5
    181c:	000d8813          	mv	a6,s11
    1820:	000a0793          	mv	a5,s4
    1824:	01010713          	addi	a4,sp,16
    1828:	000d0693          	mv	a3,s10
    182c:	000c8613          	mv	a2,s9
    1830:	000c0593          	mv	a1,s8
    1834:	000b8513          	mv	a0,s7
    1838:	c25ff0ef          	jal	145c <_ntoa_format>
}
    183c:	06c12083          	lw	ra,108(sp)
    1840:	06812403          	lw	s0,104(sp)
    1844:	06412483          	lw	s1,100(sp)
    1848:	06012903          	lw	s2,96(sp)
    184c:	05c12983          	lw	s3,92(sp)
    1850:	05812a03          	lw	s4,88(sp)
    1854:	05412a83          	lw	s5,84(sp)
    1858:	05012b03          	lw	s6,80(sp)
    185c:	04c12b83          	lw	s7,76(sp)
    1860:	04812c03          	lw	s8,72(sp)
    1864:	04412c83          	lw	s9,68(sp)
    1868:	04012d03          	lw	s10,64(sp)
    186c:	03c12d83          	lw	s11,60(sp)
    1870:	08010113          	addi	sp,sp,128
    1874:	00008067          	ret

00001878 <_etoa>:
*
* @note           Contributed by: Martijn Jasperse <m.jasperse@gmail.com>
*
******************************************************************************/
static size_t _etoa(out_fct_type out, char* buffer, size_t idx, size_t maxlen, double value, unsigned int prec, unsigned int width, unsigned int flags)
{
    1878:	f9010113          	addi	sp,sp,-112
    187c:	06112623          	sw	ra,108(sp)
    1880:	06812423          	sw	s0,104(sp)
    1884:	06912223          	sw	s1,100(sp)
    1888:	07212023          	sw	s2,96(sp)
    188c:	05312e23          	sw	s3,92(sp)
    1890:	05412c23          	sw	s4,88(sp)
    1894:	05512a23          	sw	s5,84(sp)
    1898:	05612823          	sw	s6,80(sp)
    189c:	05712623          	sw	s7,76(sp)
    18a0:	05812423          	sw	s8,72(sp)
    18a4:	00050913          	mv	s2,a0
    18a8:	00058993          	mv	s3,a1
    18ac:	00060b13          	mv	s6,a2
    18b0:	00068a13          	mv	s4,a3
    18b4:	00070493          	mv	s1,a4
    18b8:	00078413          	mv	s0,a5
    18bc:	00080b93          	mv	s7,a6
    18c0:	00088a93          	mv	s5,a7
    18c4:	07012c03          	lw	s8,112(sp)
  // check for NaN and special values
  if ((value != value) || (value > DBL_MAX) || (value < -DBL_MAX)) {
    18c8:	00048613          	mv	a2,s1
    18cc:	00040693          	mv	a3,s0
    18d0:	00048513          	mv	a0,s1
    18d4:	00040593          	mv	a1,s0
    18d8:	34d050ef          	jal	7424 <__eqdf2>
    18dc:	30051263          	bnez	a0,1be0 <_etoa+0x368>
    18e0:	8101a603          	lw	a2,-2032(gp) # afc0 <__clz_tab+0x104>
    18e4:	8141a683          	lw	a3,-2028(gp) # afc4 <__clz_tab+0x108>
    18e8:	00048513          	mv	a0,s1
    18ec:	00040593          	mv	a1,s0
    18f0:	3c1050ef          	jal	74b0 <__gedf2>
    18f4:	2ea04663          	bgtz	a0,1be0 <_etoa+0x368>
    18f8:	8181a603          	lw	a2,-2024(gp) # afc8 <__clz_tab+0x10c>
    18fc:	81c1a683          	lw	a3,-2020(gp) # afcc <__clz_tab+0x110>
    1900:	00048513          	mv	a0,s1
    1904:	00040593          	mv	a1,s0
    1908:	4a9050ef          	jal	75b0 <__ledf2>
    190c:	2c054a63          	bltz	a0,1be0 <_etoa+0x368>
    1910:	05912223          	sw	s9,68(sp)
    1914:	05a12023          	sw	s10,64(sp)
    1918:	03b12e23          	sw	s11,60(sp)
    return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
  }

  // determine the sign
  const bool negative = value < 0;
  if (negative) {
    191c:	00000613          	li	a2,0
    1920:	00000693          	li	a3,0
    1924:	00048513          	mv	a0,s1
    1928:	00040593          	mv	a1,s0
    192c:	485050ef          	jal	75b0 <__ledf2>
    1930:	30054463          	bltz	a0,1c38 <_etoa+0x3c0>
    1934:	00912823          	sw	s1,16(sp)
    1938:	00040c93          	mv	s9,s0
    value = -value;
  }

  // default precision
  if (!(flags & FLAGS_PRECISION)) {
    193c:	400c7793          	andi	a5,s8,1024
    1940:	02f12623          	sw	a5,44(sp)
    1944:	00079463          	bnez	a5,194c <_etoa+0xd4>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1948:	00400b93          	li	s7,4
    uint64_t U;
    double   F;
  } conv;

  conv.F = value;
  int exp2 = (int)((conv.U >> 52U) & 0x07FFU) - 1023;           // effectively log2
    194c:	014cd513          	srli	a0,s9,0x14
    1950:	7ff57513          	andi	a0,a0,2047
  conv.U = (conv.U & ((1ULL << 52U) - 1U)) | (1023ULL << 52U);  // drop the exponent so conv.F is now in [1,2)
    1954:	001007b7          	lui	a5,0x100
    1958:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xefdff>
    195c:	00fcf7b3          	and	a5,s9,a5
    1960:	3ff00d37          	lui	s10,0x3ff00
    1964:	00fd6d33          	or	s10,s10,a5
  // now approximate log10 from the log2 integer part and an expansion of ln around 1.5
  int expval = (int)(0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
    1968:	c0150513          	addi	a0,a0,-1023
    196c:	625060ef          	jal	8790 <__floatsidf>
    1970:	8201a603          	lw	a2,-2016(gp) # afd0 <__clz_tab+0x114>
    1974:	8241a683          	lw	a3,-2012(gp) # afd4 <__clz_tab+0x118>
    1978:	541050ef          	jal	76b8 <__muldf3>
    197c:	8281a603          	lw	a2,-2008(gp) # afd8 <__clz_tab+0x11c>
    1980:	82c1a683          	lw	a3,-2004(gp) # afdc <__clz_tab+0x120>
    1984:	249040ef          	jal	63cc <__adddf3>
    1988:	00050d93          	mv	s11,a0
    198c:	00b12a23          	sw	a1,20(sp)
    1990:	8301a603          	lw	a2,-2000(gp) # afe0 <__clz_tab+0x124>
    1994:	8341a683          	lw	a3,-1996(gp) # afe4 <__clz_tab+0x128>
    1998:	01012703          	lw	a4,16(sp)
    199c:	00070513          	mv	a0,a4
    19a0:	000d0593          	mv	a1,s10
    19a4:	3ec060ef          	jal	7d90 <__subdf3>
    19a8:	8381a603          	lw	a2,-1992(gp) # afe8 <__clz_tab+0x12c>
    19ac:	83c1a683          	lw	a3,-1988(gp) # afec <__clz_tab+0x130>
    19b0:	509050ef          	jal	76b8 <__muldf3>
    19b4:	00050613          	mv	a2,a0
    19b8:	00058693          	mv	a3,a1
    19bc:	000d8513          	mv	a0,s11
    19c0:	01412583          	lw	a1,20(sp)
    19c4:	209040ef          	jal	63cc <__adddf3>
    19c8:	4d1060ef          	jal	8698 <__fixdfsi>
    19cc:	00050d13          	mv	s10,a0
  // now we want to compute 10^expval but we want to be sure it won't overflow
  exp2 = (int)(expval * 3.321928094887362 + 0.5);
    19d0:	5c1060ef          	jal	8790 <__floatsidf>
    19d4:	00a12a23          	sw	a0,20(sp)
    19d8:	00b12c23          	sw	a1,24(sp)
    19dc:	8401a603          	lw	a2,-1984(gp) # aff0 <__clz_tab+0x134>
    19e0:	8441a683          	lw	a3,-1980(gp) # aff4 <__clz_tab+0x138>
    19e4:	4d5050ef          	jal	76b8 <__muldf3>
    19e8:	8481a603          	lw	a2,-1976(gp) # aff8 <__clz_tab+0x13c>
    19ec:	84c1a683          	lw	a3,-1972(gp) # affc <__clz_tab+0x140>
    19f0:	1dd040ef          	jal	63cc <__adddf3>
    19f4:	4a5060ef          	jal	8698 <__fixdfsi>
    19f8:	00050d93          	mv	s11,a0
  const double z  = expval * 2.302585092994046 - exp2 * 0.6931471805599453;
    19fc:	8501a603          	lw	a2,-1968(gp) # b000 <__clz_tab+0x144>
    1a00:	8541a683          	lw	a3,-1964(gp) # b004 <__clz_tab+0x148>
    1a04:	01412503          	lw	a0,20(sp)
    1a08:	01812583          	lw	a1,24(sp)
    1a0c:	4ad050ef          	jal	76b8 <__muldf3>
    1a10:	00a12a23          	sw	a0,20(sp)
    1a14:	00b12c23          	sw	a1,24(sp)
    1a18:	000d8513          	mv	a0,s11
    1a1c:	575060ef          	jal	8790 <__floatsidf>
    1a20:	8581a603          	lw	a2,-1960(gp) # b008 <__clz_tab+0x14c>
    1a24:	85c1a683          	lw	a3,-1956(gp) # b00c <__clz_tab+0x150>
    1a28:	491050ef          	jal	76b8 <__muldf3>
    1a2c:	00050613          	mv	a2,a0
    1a30:	00058693          	mv	a3,a1
    1a34:	01412503          	lw	a0,20(sp)
    1a38:	01812583          	lw	a1,24(sp)
    1a3c:	354060ef          	jal	7d90 <__subdf3>
  const double z2 = z * z;
    1a40:	00a12a23          	sw	a0,20(sp)
    1a44:	00050613          	mv	a2,a0
    1a48:	00b12c23          	sw	a1,24(sp)
    1a4c:	00058693          	mv	a3,a1
    1a50:	469050ef          	jal	76b8 <__muldf3>
    1a54:	00a12e23          	sw	a0,28(sp)
    1a58:	02b12023          	sw	a1,32(sp)
  conv.U = (uint64_t)(exp2 + 1023) << 52U;
    1a5c:	3ffd8d93          	addi	s11,s11,1023
    1a60:	014d9d93          	slli	s11,s11,0x14
  // compute exp(z) using continued fractions, see https://en.wikipedia.org/wiki/Exponential_function#Continued_fractions_for_ex
  conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
    1a64:	01412803          	lw	a6,20(sp)
    1a68:	00080613          	mv	a2,a6
    1a6c:	01812783          	lw	a5,24(sp)
    1a70:	00078693          	mv	a3,a5
    1a74:	00080513          	mv	a0,a6
    1a78:	00078593          	mv	a1,a5
    1a7c:	151040ef          	jal	63cc <__adddf3>
    1a80:	02a12223          	sw	a0,36(sp)
    1a84:	02b12423          	sw	a1,40(sp)
    1a88:	01412603          	lw	a2,20(sp)
    1a8c:	01812683          	lw	a3,24(sp)
    1a90:	8601a503          	lw	a0,-1952(gp) # b010 <__clz_tab+0x154>
    1a94:	8641a583          	lw	a1,-1948(gp) # b014 <__clz_tab+0x158>
    1a98:	2f8060ef          	jal	7d90 <__subdf3>
    1a9c:	00a12a23          	sw	a0,20(sp)
    1aa0:	00b12c23          	sw	a1,24(sp)
    1aa4:	8681a603          	lw	a2,-1944(gp) # b018 <__clz_tab+0x15c>
    1aa8:	86c1a683          	lw	a3,-1940(gp) # b01c <__clz_tab+0x160>
    1aac:	01c12503          	lw	a0,28(sp)
    1ab0:	02012583          	lw	a1,32(sp)
    1ab4:	1e0050ef          	jal	6c94 <__divdf3>
    1ab8:	8701a603          	lw	a2,-1936(gp) # b020 <__clz_tab+0x164>
    1abc:	8741a683          	lw	a3,-1932(gp) # b024 <__clz_tab+0x168>
    1ac0:	10d040ef          	jal	63cc <__adddf3>
    1ac4:	00050613          	mv	a2,a0
    1ac8:	00058693          	mv	a3,a1
    1acc:	01c12503          	lw	a0,28(sp)
    1ad0:	02012583          	lw	a1,32(sp)
    1ad4:	1c0050ef          	jal	6c94 <__divdf3>
    1ad8:	8781a603          	lw	a2,-1928(gp) # b028 <__clz_tab+0x16c>
    1adc:	87c1a683          	lw	a3,-1924(gp) # b02c <__clz_tab+0x170>
    1ae0:	0ed040ef          	jal	63cc <__adddf3>
    1ae4:	00050613          	mv	a2,a0
    1ae8:	00058693          	mv	a3,a1
    1aec:	01c12503          	lw	a0,28(sp)
    1af0:	02012583          	lw	a1,32(sp)
    1af4:	1a0050ef          	jal	6c94 <__divdf3>
    1af8:	00050613          	mv	a2,a0
    1afc:	00058693          	mv	a3,a1
    1b00:	01412503          	lw	a0,20(sp)
    1b04:	01812583          	lw	a1,24(sp)
    1b08:	0c5040ef          	jal	63cc <__adddf3>
    1b0c:	00050613          	mv	a2,a0
    1b10:	00058693          	mv	a3,a1
    1b14:	02412503          	lw	a0,36(sp)
    1b18:	02812583          	lw	a1,40(sp)
    1b1c:	178050ef          	jal	6c94 <__divdf3>
    1b20:	8801a603          	lw	a2,-1920(gp) # b030 <__clz_tab+0x174>
    1b24:	8841a683          	lw	a3,-1916(gp) # b034 <__clz_tab+0x178>
    1b28:	0a5040ef          	jal	63cc <__adddf3>
    1b2c:	00000713          	li	a4,0
    1b30:	00070613          	mv	a2,a4
    1b34:	000d8693          	mv	a3,s11
    1b38:	381050ef          	jal	76b8 <__muldf3>
    1b3c:	00050d93          	mv	s11,a0
    1b40:	00a12c23          	sw	a0,24(sp)
    1b44:	00b12a23          	sw	a1,20(sp)
    1b48:	00b12e23          	sw	a1,28(sp)
  // correct for rounding errors
  if (value < conv.F) {
    1b4c:	01012703          	lw	a4,16(sp)
    1b50:	00070613          	mv	a2,a4
    1b54:	000c8693          	mv	a3,s9
    1b58:	159050ef          	jal	74b0 <__gedf2>
    1b5c:	02a05263          	blez	a0,1b80 <_etoa+0x308>
    expval--;
    1b60:	fffd0d13          	addi	s10,s10,-1 # 3fefffff <__freertos_irq_stack_top+0x3feefdff>
    conv.F /= 10;
    1b64:	8701a603          	lw	a2,-1936(gp) # b020 <__clz_tab+0x164>
    1b68:	8741a683          	lw	a3,-1932(gp) # b024 <__clz_tab+0x168>
    1b6c:	000d8513          	mv	a0,s11
    1b70:	01412583          	lw	a1,20(sp)
    1b74:	120050ef          	jal	6c94 <__divdf3>
    1b78:	00a12c23          	sw	a0,24(sp)
    1b7c:	00b12e23          	sw	a1,28(sp)
  }

  // the exponent format is "%+03d" and largest value is "307", so set aside 4-5 characters
  unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
    1b80:	063d0793          	addi	a5,s10,99
    1b84:	0c600713          	li	a4,198
    1b88:	0cf76063          	bltu	a4,a5,1c48 <_etoa+0x3d0>
    1b8c:	00400d93          	li	s11,4

  // in "%g" mode, "prec" is the number of *significant figures* not decimals
  if (flags & FLAGS_ADAPT_EXP) {
    1b90:	014c1793          	slli	a5,s8,0x14
    1b94:	0c07d663          	bgez	a5,1c60 <_etoa+0x3e8>
    // do we want to fall-back to "%f" mode?
    if ((value >= 1e-4) && (value < 1e6)) {
    1b98:	8881a603          	lw	a2,-1912(gp) # b038 <__clz_tab+0x17c>
    1b9c:	88c1a683          	lw	a3,-1908(gp) # b03c <__clz_tab+0x180>
    1ba0:	01012703          	lw	a4,16(sp)
    1ba4:	00070513          	mv	a0,a4
    1ba8:	000c8593          	mv	a1,s9
    1bac:	105050ef          	jal	74b0 <__gedf2>
    1bb0:	0c054063          	bltz	a0,1c70 <_etoa+0x3f8>
    1bb4:	8901a603          	lw	a2,-1904(gp) # b040 <__clz_tab+0x184>
    1bb8:	8941a683          	lw	a3,-1900(gp) # b044 <__clz_tab+0x188>
    1bbc:	01012703          	lw	a4,16(sp)
    1bc0:	00070513          	mv	a0,a4
    1bc4:	000c8593          	mv	a1,s9
    1bc8:	1e9050ef          	jal	75b0 <__ledf2>
    1bcc:	0a055263          	bgez	a0,1c70 <_etoa+0x3f8>
      if ((int)prec > expval) {
    1bd0:	097d5063          	bge	s10,s7,1c50 <_etoa+0x3d8>
        prec = (unsigned)((int)prec - expval - 1);
    1bd4:	41ab8d33          	sub	s10,s7,s10
    1bd8:	fffd0b93          	addi	s7,s10,-1
    1bdc:	0780006f          	j	1c54 <_etoa+0x3dc>
    return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
    1be0:	01812023          	sw	s8,0(sp)
    1be4:	000a8893          	mv	a7,s5
    1be8:	000b8813          	mv	a6,s7
    1bec:	00048713          	mv	a4,s1
    1bf0:	00040793          	mv	a5,s0
    1bf4:	000a0693          	mv	a3,s4
    1bf8:	000b0613          	mv	a2,s6
    1bfc:	00098593          	mv	a1,s3
    1c00:	00090513          	mv	a0,s2
    1c04:	1e8000ef          	jal	1dec <_ftoa>
    if (flags & FLAGS_LEFT) {
      while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
    }
  }
  return idx;
}
    1c08:	06c12083          	lw	ra,108(sp)
    1c0c:	06812403          	lw	s0,104(sp)
    1c10:	06412483          	lw	s1,100(sp)
    1c14:	06012903          	lw	s2,96(sp)
    1c18:	05c12983          	lw	s3,92(sp)
    1c1c:	05812a03          	lw	s4,88(sp)
    1c20:	05412a83          	lw	s5,84(sp)
    1c24:	05012b03          	lw	s6,80(sp)
    1c28:	04c12b83          	lw	s7,76(sp)
    1c2c:	04812c03          	lw	s8,72(sp)
    1c30:	07010113          	addi	sp,sp,112
    1c34:	00008067          	ret
    value = -value;
    1c38:	00912823          	sw	s1,16(sp)
    1c3c:	80000cb7          	lui	s9,0x80000
    1c40:	008cccb3          	xor	s9,s9,s0
    1c44:	cf9ff06f          	j	193c <_etoa+0xc4>
  unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
    1c48:	00500d93          	li	s11,5
    1c4c:	f45ff06f          	j	1b90 <_etoa+0x318>
        prec = 0;
    1c50:	00000b93          	li	s7,0
      flags |= FLAGS_PRECISION;   // make sure _ftoa respects precision
    1c54:	400c6c13          	ori	s8,s8,1024
      minwidth = 0U;
    1c58:	00000d93          	li	s11,0
      expval   = 0;
    1c5c:	00000d13          	li	s10,0
  if (width > minwidth) {
    1c60:	035df263          	bgeu	s11,s5,1c84 <_etoa+0x40c>
    fwidth -= minwidth;
    1c64:	41ba87b3          	sub	a5,s5,s11
    1c68:	00f12a23          	sw	a5,20(sp)
    1c6c:	01c0006f          	j	1c88 <_etoa+0x410>
      if ((prec > 0) && (flags & FLAGS_PRECISION)) {
    1c70:	fe0b88e3          	beqz	s7,1c60 <_etoa+0x3e8>
    1c74:	02c12783          	lw	a5,44(sp)
    1c78:	fe0784e3          	beqz	a5,1c60 <_etoa+0x3e8>
        --prec;
    1c7c:	fffb8b93          	addi	s7,s7,-1
    1c80:	fe1ff06f          	j	1c60 <_etoa+0x3e8>
    fwidth = 0U;
    1c84:	00012a23          	sw	zero,20(sp)
  if ((flags & FLAGS_LEFT) && minwidth) {
    1c88:	002c7793          	andi	a5,s8,2
    1c8c:	02f12023          	sw	a5,32(sp)
    1c90:	00078663          	beqz	a5,1c9c <_etoa+0x424>
    1c94:	000d8463          	beqz	s11,1c9c <_etoa+0x424>
    fwidth = 0U;
    1c98:	00012a23          	sw	zero,20(sp)
  if (expval) {
    1c9c:	020d0663          	beqz	s10,1cc8 <_etoa+0x450>
    value /= conv.F;
    1ca0:	01812703          	lw	a4,24(sp)
    1ca4:	01c12783          	lw	a5,28(sp)
    1ca8:	00070613          	mv	a2,a4
    1cac:	00078693          	mv	a3,a5
    1cb0:	01012703          	lw	a4,16(sp)
    1cb4:	00070513          	mv	a0,a4
    1cb8:	000c8593          	mv	a1,s9
    1cbc:	7d9040ef          	jal	6c94 <__divdf3>
    1cc0:	00a12823          	sw	a0,16(sp)
    1cc4:	00058c93          	mv	s9,a1
  idx = _ftoa(out, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);
    1cc8:	00000613          	li	a2,0
    1ccc:	00000693          	li	a3,0
    1cd0:	00048513          	mv	a0,s1
    1cd4:	00040593          	mv	a1,s0
    1cd8:	0d9050ef          	jal	75b0 <__ledf2>
    1cdc:	0a054c63          	bltz	a0,1d94 <_etoa+0x51c>
    1ce0:	fffff7b7          	lui	a5,0xfffff
    1ce4:	7ff78793          	addi	a5,a5,2047 # fffff7ff <__freertos_irq_stack_top+0xfffef5ff>
    1ce8:	00fc77b3          	and	a5,s8,a5
    1cec:	00f12023          	sw	a5,0(sp)
    1cf0:	01412883          	lw	a7,20(sp)
    1cf4:	000b8813          	mv	a6,s7
    1cf8:	01012603          	lw	a2,16(sp)
    1cfc:	00060713          	mv	a4,a2
    1d00:	000c8793          	mv	a5,s9
    1d04:	000a0693          	mv	a3,s4
    1d08:	000b0613          	mv	a2,s6
    1d0c:	00098593          	mv	a1,s3
    1d10:	00090513          	mv	a0,s2
    1d14:	0d8000ef          	jal	1dec <_ftoa>
  if (minwidth) {
    1d18:	0c0d8263          	beqz	s11,1ddc <_etoa+0x564>
    out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
    1d1c:	020c7c13          	andi	s8,s8,32
    1d20:	080c0063          	beqz	s8,1da0 <_etoa+0x528>
    1d24:	04500793          	li	a5,69
    1d28:	00150413          	addi	s0,a0,1
    1d2c:	000a0693          	mv	a3,s4
    1d30:	00050613          	mv	a2,a0
    1d34:	00098593          	mv	a1,s3
    1d38:	00078513          	mv	a0,a5
    1d3c:	000900e7          	jalr	s2
    idx = _ntoa_long(out, buffer, idx, maxlen, (expval < 0) ? -expval : expval, expval < 0, 10, 0, minwidth-1, FLAGS_ZEROPAD | FLAGS_PLUS);
    1d40:	41fd5713          	srai	a4,s10,0x1f
    1d44:	01a746b3          	xor	a3,a4,s10
    1d48:	00500793          	li	a5,5
    1d4c:	00f12223          	sw	a5,4(sp)
    1d50:	fffd8d93          	addi	s11,s11,-1
    1d54:	01b12023          	sw	s11,0(sp)
    1d58:	00000893          	li	a7,0
    1d5c:	00a00813          	li	a6,10
    1d60:	01fd5793          	srli	a5,s10,0x1f
    1d64:	40e68733          	sub	a4,a3,a4
    1d68:	000a0693          	mv	a3,s4
    1d6c:	00040613          	mv	a2,s0
    1d70:	00098593          	mv	a1,s3
    1d74:	00090513          	mv	a0,s2
    1d78:	8a5ff0ef          	jal	161c <_ntoa_long>
    if (flags & FLAGS_LEFT) {
    1d7c:	02012783          	lw	a5,32(sp)
    1d80:	04079263          	bnez	a5,1dc4 <_etoa+0x54c>
    1d84:	04412c83          	lw	s9,68(sp)
    1d88:	04012d03          	lw	s10,64(sp)
    1d8c:	03c12d83          	lw	s11,60(sp)
    1d90:	e79ff06f          	j	1c08 <_etoa+0x390>
  idx = _ftoa(out, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);
    1d94:	800007b7          	lui	a5,0x80000
    1d98:	0197ccb3          	xor	s9,a5,s9
    1d9c:	f45ff06f          	j	1ce0 <_etoa+0x468>
    out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
    1da0:	06500793          	li	a5,101
    1da4:	f85ff06f          	j	1d28 <_etoa+0x4b0>
      while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
    1da8:	00150413          	addi	s0,a0,1
    1dac:	000a0693          	mv	a3,s4
    1db0:	00050613          	mv	a2,a0
    1db4:	00098593          	mv	a1,s3
    1db8:	02000513          	li	a0,32
    1dbc:	000900e7          	jalr	s2
    1dc0:	00040513          	mv	a0,s0
    1dc4:	416507b3          	sub	a5,a0,s6
    1dc8:	ff57e0e3          	bltu	a5,s5,1da8 <_etoa+0x530>
    1dcc:	04412c83          	lw	s9,68(sp)
    1dd0:	04012d03          	lw	s10,64(sp)
    1dd4:	03c12d83          	lw	s11,60(sp)
    1dd8:	e31ff06f          	j	1c08 <_etoa+0x390>
    1ddc:	04412c83          	lw	s9,68(sp)
    1de0:	04012d03          	lw	s10,64(sp)
    1de4:	03c12d83          	lw	s11,60(sp)
    1de8:	e21ff06f          	j	1c08 <_etoa+0x390>

00001dec <_ftoa>:
{
    1dec:	f7010113          	addi	sp,sp,-144
    1df0:	08112623          	sw	ra,140(sp)
    1df4:	08912223          	sw	s1,132(sp)
    1df8:	07312e23          	sw	s3,124(sp)
    1dfc:	07412c23          	sw	s4,120(sp)
    1e00:	07612823          	sw	s6,112(sp)
    1e04:	07712623          	sw	s7,108(sp)
    1e08:	07812423          	sw	s8,104(sp)
    1e0c:	07912223          	sw	s9,100(sp)
    1e10:	07a12023          	sw	s10,96(sp)
    1e14:	05b12e23          	sw	s11,92(sp)
    1e18:	00050b93          	mv	s7,a0
    1e1c:	00058c13          	mv	s8,a1
    1e20:	00060c93          	mv	s9,a2
    1e24:	00068d13          	mv	s10,a3
    1e28:	00070a13          	mv	s4,a4
    1e2c:	00078993          	mv	s3,a5
    1e30:	00080493          	mv	s1,a6
    1e34:	00088b13          	mv	s6,a7
    1e38:	09012d83          	lw	s11,144(sp)
  if (value != value)
    1e3c:	00070613          	mv	a2,a4
    1e40:	00078693          	mv	a3,a5
    1e44:	00070513          	mv	a0,a4
    1e48:	00078593          	mv	a1,a5
    1e4c:	5d8050ef          	jal	7424 <__eqdf2>
    1e50:	0c051463          	bnez	a0,1f18 <_ftoa+0x12c>
  if (value < -DBL_MAX)
    1e54:	8181a603          	lw	a2,-2024(gp) # afc8 <__clz_tab+0x10c>
    1e58:	81c1a683          	lw	a3,-2020(gp) # afcc <__clz_tab+0x110>
    1e5c:	000a0513          	mv	a0,s4
    1e60:	00098593          	mv	a1,s3
    1e64:	74c050ef          	jal	75b0 <__ledf2>
    1e68:	0c054e63          	bltz	a0,1f44 <_ftoa+0x158>
  if (value > DBL_MAX)
    1e6c:	8101a603          	lw	a2,-2032(gp) # afc0 <__clz_tab+0x104>
    1e70:	8141a683          	lw	a3,-2028(gp) # afc4 <__clz_tab+0x108>
    1e74:	000a0513          	mv	a0,s4
    1e78:	00098593          	mv	a1,s3
    1e7c:	634050ef          	jal	74b0 <__gedf2>
    1e80:	0ea04863          	bgtz	a0,1f70 <_ftoa+0x184>
  if ((value > PRINTF_MAX_FLOAT) || (value < -PRINTF_MAX_FLOAT)) {
    1e84:	8981a603          	lw	a2,-1896(gp) # b048 <__clz_tab+0x18c>
    1e88:	89c1a683          	lw	a3,-1892(gp) # b04c <__clz_tab+0x190>
    1e8c:	000a0513          	mv	a0,s4
    1e90:	00098593          	mv	a1,s3
    1e94:	61c050ef          	jal	74b0 <__gedf2>
    1e98:	12a04263          	bgtz	a0,1fbc <_ftoa+0x1d0>
    1e9c:	8a01a603          	lw	a2,-1888(gp) # b050 <__clz_tab+0x194>
    1ea0:	8a41a683          	lw	a3,-1884(gp) # b054 <__clz_tab+0x198>
    1ea4:	000a0513          	mv	a0,s4
    1ea8:	00098593          	mv	a1,s3
    1eac:	704050ef          	jal	75b0 <__ledf2>
    1eb0:	10054663          	bltz	a0,1fbc <_ftoa+0x1d0>
    1eb4:	08812423          	sw	s0,136(sp)
    1eb8:	09212023          	sw	s2,128(sp)
    1ebc:	07512a23          	sw	s5,116(sp)
  if (value < 0) {
    1ec0:	00000613          	li	a2,0
    1ec4:	00000693          	li	a3,0
    1ec8:	000a0513          	mv	a0,s4
    1ecc:	00098593          	mv	a1,s3
    1ed0:	6e0050ef          	jal	75b0 <__ledf2>
    1ed4:	10054a63          	bltz	a0,1fe8 <_ftoa+0x1fc>
  bool negative = false;
    1ed8:	02012223          	sw	zero,36(sp)
  if (!(flags & FLAGS_PRECISION)) {
    1edc:	400df793          	andi	a5,s11,1024
    1ee0:	12078863          	beqz	a5,2010 <_ftoa+0x224>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1ee4:	00000413          	li	s0,0
  while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
    1ee8:	01f00793          	li	a5,31
    1eec:	1287e663          	bltu	a5,s0,2018 <_ftoa+0x22c>
    1ef0:	00900793          	li	a5,9
    1ef4:	1297f263          	bgeu	a5,s1,2018 <_ftoa+0x22c>
    buf[len++] = '0';
    1ef8:	03040793          	addi	a5,s0,48
    1efc:	02010713          	addi	a4,sp,32
    1f00:	00e787b3          	add	a5,a5,a4
    1f04:	03000713          	li	a4,48
    1f08:	fee78023          	sb	a4,-32(a5) # 7fffffe0 <__freertos_irq_stack_top+0x7ffefde0>
    prec--;
    1f0c:	fff48493          	addi	s1,s1,-1
    buf[len++] = '0';
    1f10:	00140413          	addi	s0,s0,1
    1f14:	fd5ff06f          	j	1ee8 <_ftoa+0xfc>
    return _out_rev(out, buffer, idx, maxlen, "nan", 3, width, flags);
    1f18:	000d8893          	mv	a7,s11
    1f1c:	000b0813          	mv	a6,s6
    1f20:	00300793          	li	a5,3
    1f24:	00009737          	lui	a4,0x9
    1f28:	9a470713          	addi	a4,a4,-1628 # 89a4 <_data+0x10>
    1f2c:	000d0693          	mv	a3,s10
    1f30:	000c8613          	mv	a2,s9
    1f34:	000c0593          	mv	a1,s8
    1f38:	000b8513          	mv	a0,s7
    1f3c:	c14ff0ef          	jal	1350 <_out_rev>
    1f40:	33c0006f          	j	227c <_ftoa+0x490>
    return _out_rev(out, buffer, idx, maxlen, "fni-", 4, width, flags);
    1f44:	000d8893          	mv	a7,s11
    1f48:	000b0813          	mv	a6,s6
    1f4c:	00400793          	li	a5,4
    1f50:	00009737          	lui	a4,0x9
    1f54:	9a870713          	addi	a4,a4,-1624 # 89a8 <_data+0x14>
    1f58:	000d0693          	mv	a3,s10
    1f5c:	000c8613          	mv	a2,s9
    1f60:	000c0593          	mv	a1,s8
    1f64:	000b8513          	mv	a0,s7
    1f68:	be8ff0ef          	jal	1350 <_out_rev>
    1f6c:	3100006f          	j	227c <_ftoa+0x490>
    return _out_rev(out, buffer, idx, maxlen, (flags & FLAGS_PLUS) ? "fni+" : "fni", (flags & FLAGS_PLUS) ? 4U : 3U, width, flags);
    1f70:	004df793          	andi	a5,s11,4
    1f74:	02078a63          	beqz	a5,1fa8 <_ftoa+0x1bc>
    1f78:	00009737          	lui	a4,0x9
    1f7c:	99870713          	addi	a4,a4,-1640 # 8998 <_data+0x4>
    1f80:	02078a63          	beqz	a5,1fb4 <_ftoa+0x1c8>
    1f84:	00400793          	li	a5,4
    1f88:	000d8893          	mv	a7,s11
    1f8c:	000b0813          	mv	a6,s6
    1f90:	000d0693          	mv	a3,s10
    1f94:	000c8613          	mv	a2,s9
    1f98:	000c0593          	mv	a1,s8
    1f9c:	000b8513          	mv	a0,s7
    1fa0:	bb0ff0ef          	jal	1350 <_out_rev>
    1fa4:	2d80006f          	j	227c <_ftoa+0x490>
    1fa8:	00009737          	lui	a4,0x9
    1fac:	9a070713          	addi	a4,a4,-1632 # 89a0 <_data+0xc>
    1fb0:	fd1ff06f          	j	1f80 <_ftoa+0x194>
    1fb4:	00300793          	li	a5,3
    1fb8:	fd1ff06f          	j	1f88 <_ftoa+0x19c>
    return _etoa(out, buffer, idx, maxlen, value, prec, width, flags);
    1fbc:	01b12023          	sw	s11,0(sp)
    1fc0:	000b0893          	mv	a7,s6
    1fc4:	00048813          	mv	a6,s1
    1fc8:	000a0713          	mv	a4,s4
    1fcc:	00098793          	mv	a5,s3
    1fd0:	000d0693          	mv	a3,s10
    1fd4:	000c8613          	mv	a2,s9
    1fd8:	000c0593          	mv	a1,s8
    1fdc:	000b8513          	mv	a0,s7
    1fe0:	899ff0ef          	jal	1878 <_etoa>
    1fe4:	2980006f          	j	227c <_ftoa+0x490>
    value = 0 - value;
    1fe8:	000a0613          	mv	a2,s4
    1fec:	00098693          	mv	a3,s3
    1ff0:	00000513          	li	a0,0
    1ff4:	00000593          	li	a1,0
    1ff8:	599050ef          	jal	7d90 <__subdf3>
    1ffc:	00050a13          	mv	s4,a0
    2000:	00058993          	mv	s3,a1
    negative = true;
    2004:	00100793          	li	a5,1
    2008:	02f12223          	sw	a5,36(sp)
    200c:	ed1ff06f          	j	1edc <_ftoa+0xf0>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    2010:	00400493          	li	s1,4
    2014:	ed1ff06f          	j	1ee4 <_ftoa+0xf8>
  int whole = (int)value;
    2018:	000a0513          	mv	a0,s4
    201c:	00098593          	mv	a1,s3
    2020:	678060ef          	jal	8698 <__fixdfsi>
    2024:	00050913          	mv	s2,a0
  double tmp = (value - whole) * pow10[prec];
    2028:	768060ef          	jal	8790 <__floatsidf>
    202c:	00050613          	mv	a2,a0
    2030:	00058693          	mv	a3,a1
    2034:	000a0513          	mv	a0,s4
    2038:	00098593          	mv	a1,s3
    203c:	555050ef          	jal	7d90 <__subdf3>
    2040:	000097b7          	lui	a5,0x9
    2044:	00349713          	slli	a4,s1,0x3
    2048:	50078793          	addi	a5,a5,1280 # 9500 <pow10.0>
    204c:	00e787b3          	add	a5,a5,a4
    2050:	0047a803          	lw	a6,4(a5)
    2054:	0007a783          	lw	a5,0(a5)
    2058:	02f12423          	sw	a5,40(sp)
    205c:	03012623          	sw	a6,44(sp)
    2060:	00078613          	mv	a2,a5
    2064:	00080693          	mv	a3,a6
    2068:	650050ef          	jal	76b8 <__muldf3>
    206c:	00a12e23          	sw	a0,28(sp)
    2070:	02b12023          	sw	a1,32(sp)
  unsigned long frac = (unsigned long)tmp;
    2074:	6a8060ef          	jal	871c <__fixunsdfsi>
    2078:	00050a93          	mv	s5,a0
  diff = tmp - frac;
    207c:	7cc060ef          	jal	8848 <__floatunsidf>
    2080:	00050613          	mv	a2,a0
    2084:	00058693          	mv	a3,a1
    2088:	01c12503          	lw	a0,28(sp)
    208c:	02012583          	lw	a1,32(sp)
    2090:	501050ef          	jal	7d90 <__subdf3>
    2094:	00a12e23          	sw	a0,28(sp)
    2098:	02b12023          	sw	a1,32(sp)
  if (diff > 0.5) {
    209c:	8481a603          	lw	a2,-1976(gp) # aff8 <__clz_tab+0x13c>
    20a0:	84c1a683          	lw	a3,-1972(gp) # affc <__clz_tab+0x140>
    20a4:	40c050ef          	jal	74b0 <__gedf2>
    20a8:	06a05863          	blez	a0,2118 <_ftoa+0x32c>
    ++frac;
    20ac:	001a8a93          	addi	s5,s5,1
    if (frac >= pow10[prec]) {
    20b0:	000a8513          	mv	a0,s5
    20b4:	794060ef          	jal	8848 <__floatunsidf>
    20b8:	00050613          	mv	a2,a0
    20bc:	00058693          	mv	a3,a1
    20c0:	02812503          	lw	a0,40(sp)
    20c4:	02c12583          	lw	a1,44(sp)
    20c8:	4e8050ef          	jal	75b0 <__ledf2>
    20cc:	00a04663          	bgtz	a0,20d8 <_ftoa+0x2ec>
      ++whole;
    20d0:	00190913          	addi	s2,s2,1
      frac = 0;
    20d4:	00000a93          	li	s5,0
  if (prec == 0U) {
    20d8:	06049663          	bnez	s1,2144 <_ftoa+0x358>
    diff = value - (double)whole;
    20dc:	00090513          	mv	a0,s2
    20e0:	6b0060ef          	jal	8790 <__floatsidf>
    20e4:	00050613          	mv	a2,a0
    20e8:	00058693          	mv	a3,a1
    20ec:	000a0513          	mv	a0,s4
    20f0:	00098593          	mv	a1,s3
    20f4:	49d050ef          	jal	7d90 <__subdf3>
    if ((!(diff < 0.5) || (diff > 0.5)) && (whole & 1)) {
    20f8:	8481a603          	lw	a2,-1976(gp) # aff8 <__clz_tab+0x13c>
    20fc:	84c1a683          	lw	a3,-1972(gp) # affc <__clz_tab+0x140>
    2100:	4b0050ef          	jal	75b0 <__ledf2>
    2104:	0c054c63          	bltz	a0,21dc <_ftoa+0x3f0>
    2108:	00197793          	andi	a5,s2,1
    210c:	0c078863          	beqz	a5,21dc <_ftoa+0x3f0>
      ++whole;
    2110:	00190913          	addi	s2,s2,1
    2114:	0c80006f          	j	21dc <_ftoa+0x3f0>
  else if (diff < 0.5) {
    2118:	8481a603          	lw	a2,-1976(gp) # aff8 <__clz_tab+0x13c>
    211c:	84c1a683          	lw	a3,-1972(gp) # affc <__clz_tab+0x140>
    2120:	01c12503          	lw	a0,28(sp)
    2124:	02012583          	lw	a1,32(sp)
    2128:	488050ef          	jal	75b0 <__ledf2>
    212c:	fa0546e3          	bltz	a0,20d8 <_ftoa+0x2ec>
  else if ((frac == 0U) || (frac & 1U)) {
    2130:	000a8663          	beqz	s5,213c <_ftoa+0x350>
    2134:	001af793          	andi	a5,s5,1
    2138:	fa0780e3          	beqz	a5,20d8 <_ftoa+0x2ec>
    ++frac;
    213c:	001a8a93          	addi	s5,s5,1
    2140:	f99ff06f          	j	20d8 <_ftoa+0x2ec>
    while (len < PRINTF_FTOA_BUFFER_SIZE) {
    2144:	01f00793          	li	a5,31
    2148:	0487e263          	bltu	a5,s0,218c <_ftoa+0x3a0>
      --count;
    214c:	fff48493          	addi	s1,s1,-1
      buf[len++] = (char)(48U + (frac % 10U));
    2150:	00a00793          	li	a5,10
    2154:	02faf733          	remu	a4,s5,a5
    2158:	00140693          	addi	a3,s0,1
    215c:	03070713          	addi	a4,a4,48
    2160:	03040613          	addi	a2,s0,48
    2164:	02010593          	addi	a1,sp,32
    2168:	00b60433          	add	s0,a2,a1
    216c:	fee40023          	sb	a4,-32(s0)
      if (!(frac /= 10U)) {
    2170:	02fad7b3          	divu	a5,s5,a5
    2174:	00900713          	li	a4,9
    2178:	01577863          	bgeu	a4,s5,2188 <_ftoa+0x39c>
    217c:	00078a93          	mv	s5,a5
      buf[len++] = (char)(48U + (frac % 10U));
    2180:	00068413          	mv	s0,a3
    2184:	fc1ff06f          	j	2144 <_ftoa+0x358>
    2188:	00068413          	mv	s0,a3
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
    218c:	01f00793          	li	a5,31
    2190:	0287e663          	bltu	a5,s0,21bc <_ftoa+0x3d0>
    2194:	fff48793          	addi	a5,s1,-1
    2198:	02048263          	beqz	s1,21bc <_ftoa+0x3d0>
      buf[len++] = '0';
    219c:	03040713          	addi	a4,s0,48
    21a0:	02010693          	addi	a3,sp,32
    21a4:	00d70733          	add	a4,a4,a3
    21a8:	03000693          	li	a3,48
    21ac:	fed70023          	sb	a3,-32(a4)
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
    21b0:	00078493          	mv	s1,a5
      buf[len++] = '0';
    21b4:	00140413          	addi	s0,s0,1
    21b8:	fd5ff06f          	j	218c <_ftoa+0x3a0>
    if (len < PRINTF_FTOA_BUFFER_SIZE) {
    21bc:	01f00793          	li	a5,31
    21c0:	0087ee63          	bltu	a5,s0,21dc <_ftoa+0x3f0>
      buf[len++] = '.';
    21c4:	03040793          	addi	a5,s0,48
    21c8:	02010713          	addi	a4,sp,32
    21cc:	00e787b3          	add	a5,a5,a4
    21d0:	02e00713          	li	a4,46
    21d4:	fee78023          	sb	a4,-32(a5)
    21d8:	00140413          	addi	s0,s0,1
  while (len < PRINTF_FTOA_BUFFER_SIZE) {
    21dc:	01f00793          	li	a5,31
    21e0:	0287ec63          	bltu	a5,s0,2218 <_ftoa+0x42c>
    buf[len++] = (char)(48 + (whole % 10));
    21e4:	00a00713          	li	a4,10
    21e8:	02e967b3          	rem	a5,s2,a4
    21ec:	00140693          	addi	a3,s0,1
    21f0:	03078793          	addi	a5,a5,48
    21f4:	03040613          	addi	a2,s0,48
    21f8:	02010593          	addi	a1,sp,32
    21fc:	00b60433          	add	s0,a2,a1
    2200:	fef40023          	sb	a5,-32(s0)
    if (!(whole /= 10)) {
    2204:	02e94933          	div	s2,s2,a4
    2208:	00090663          	beqz	s2,2214 <_ftoa+0x428>
    buf[len++] = (char)(48 + (whole % 10));
    220c:	00068413          	mv	s0,a3
    2210:	fcdff06f          	j	21dc <_ftoa+0x3f0>
    2214:	00068413          	mv	s0,a3
  if (!(flags & FLAGS_LEFT) && (flags & FLAGS_ZEROPAD)) {
    2218:	003df713          	andi	a4,s11,3
    221c:	00100793          	li	a5,1
    2220:	08f70663          	beq	a4,a5,22ac <_ftoa+0x4c0>
  if (len < PRINTF_FTOA_BUFFER_SIZE) {
    2224:	01f00793          	li	a5,31
    2228:	0287e263          	bltu	a5,s0,224c <_ftoa+0x460>
    if (negative) {
    222c:	02412783          	lw	a5,36(sp)
    2230:	0c078063          	beqz	a5,22f0 <_ftoa+0x504>
      buf[len++] = '-';
    2234:	03040793          	addi	a5,s0,48
    2238:	02010713          	addi	a4,sp,32
    223c:	00e787b3          	add	a5,a5,a4
    2240:	02d00713          	li	a4,45
    2244:	fee78023          	sb	a4,-32(a5)
    2248:	00140413          	addi	s0,s0,1
  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
    224c:	000d8893          	mv	a7,s11
    2250:	000b0813          	mv	a6,s6
    2254:	00040793          	mv	a5,s0
    2258:	03010713          	addi	a4,sp,48
    225c:	000d0693          	mv	a3,s10
    2260:	000c8613          	mv	a2,s9
    2264:	000c0593          	mv	a1,s8
    2268:	000b8513          	mv	a0,s7
    226c:	8e4ff0ef          	jal	1350 <_out_rev>
    2270:	08812403          	lw	s0,136(sp)
    2274:	08012903          	lw	s2,128(sp)
    2278:	07412a83          	lw	s5,116(sp)
}
    227c:	08c12083          	lw	ra,140(sp)
    2280:	08412483          	lw	s1,132(sp)
    2284:	07c12983          	lw	s3,124(sp)
    2288:	07812a03          	lw	s4,120(sp)
    228c:	07012b03          	lw	s6,112(sp)
    2290:	06c12b83          	lw	s7,108(sp)
    2294:	06812c03          	lw	s8,104(sp)
    2298:	06412c83          	lw	s9,100(sp)
    229c:	06012d03          	lw	s10,96(sp)
    22a0:	05c12d83          	lw	s11,92(sp)
    22a4:	09010113          	addi	sp,sp,144
    22a8:	00008067          	ret
    if (width && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
    22ac:	020b0a63          	beqz	s6,22e0 <_ftoa+0x4f4>
    22b0:	02412783          	lw	a5,36(sp)
    22b4:	00079663          	bnez	a5,22c0 <_ftoa+0x4d4>
    22b8:	00cdf793          	andi	a5,s11,12
    22bc:	02078263          	beqz	a5,22e0 <_ftoa+0x4f4>
      width--;
    22c0:	fffb0b13          	addi	s6,s6,-1
    22c4:	01c0006f          	j	22e0 <_ftoa+0x4f4>
      buf[len++] = '0';
    22c8:	03040793          	addi	a5,s0,48
    22cc:	02010713          	addi	a4,sp,32
    22d0:	00e787b3          	add	a5,a5,a4
    22d4:	03000713          	li	a4,48
    22d8:	fee78023          	sb	a4,-32(a5)
    22dc:	00140413          	addi	s0,s0,1
    while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
    22e0:	f56472e3          	bgeu	s0,s6,2224 <_ftoa+0x438>
    22e4:	01f00793          	li	a5,31
    22e8:	fe87f0e3          	bgeu	a5,s0,22c8 <_ftoa+0x4dc>
    22ec:	f39ff06f          	j	2224 <_ftoa+0x438>
    else if (flags & FLAGS_PLUS) {
    22f0:	004df793          	andi	a5,s11,4
    22f4:	02078063          	beqz	a5,2314 <_ftoa+0x528>
      buf[len++] = '+';  // ignore the space if the '+' exists
    22f8:	03040793          	addi	a5,s0,48
    22fc:	02010713          	addi	a4,sp,32
    2300:	00e787b3          	add	a5,a5,a4
    2304:	02b00713          	li	a4,43
    2308:	fee78023          	sb	a4,-32(a5)
    230c:	00140413          	addi	s0,s0,1
    2310:	f3dff06f          	j	224c <_ftoa+0x460>
    else if (flags & FLAGS_SPACE) {
    2314:	008df793          	andi	a5,s11,8
    2318:	f2078ae3          	beqz	a5,224c <_ftoa+0x460>
      buf[len++] = ' ';
    231c:	03040793          	addi	a5,s0,48
    2320:	02010713          	addi	a4,sp,32
    2324:	00e787b3          	add	a5,a5,a4
    2328:	02000713          	li	a4,32
    232c:	fee78023          	sb	a4,-32(a5)
    2330:	00140413          	addi	s0,s0,1
    2334:	f19ff06f          	j	224c <_ftoa+0x460>

00002338 <_vsnprintf>:
*                 terminating null character), or a negative value if an error
*                 occurred.
*
******************************************************************************/
static int _vsnprintf(out_fct_type out, char* buffer, const size_t maxlen, const char* format, va_list va)
{
    2338:	fa010113          	addi	sp,sp,-96
    233c:	04112e23          	sw	ra,92(sp)
    2340:	04812c23          	sw	s0,88(sp)
    2344:	04912a23          	sw	s1,84(sp)
    2348:	05212823          	sw	s2,80(sp)
    234c:	05312623          	sw	s3,76(sp)
    2350:	05412423          	sw	s4,72(sp)
    2354:	05512223          	sw	s5,68(sp)
    2358:	05612023          	sw	s6,64(sp)
    235c:	00050a13          	mv	s4,a0
    2360:	00058993          	mv	s3,a1
    2364:	00060913          	mv	s2,a2
    2368:	00d12e23          	sw	a3,28(sp)
    236c:	00e12c23          	sw	a4,24(sp)
  unsigned int flags, width, precision, n;
  size_t idx = 0U;

  if (!buffer) {
    2370:	140588e3          	beqz	a1,2cc0 <_vsnprintf+0x988>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
          }
        }
        format++;
        break;
    2374:	00000493          	li	s1,0
  while (*format)
    2378:	01c12783          	lw	a5,28(sp)
    237c:	0007c503          	lbu	a0,0(a5)
    2380:	140506e3          	beqz	a0,2ccc <_vsnprintf+0x994>
    if (*format != '%') {
    2384:	02500713          	li	a4,37
    2388:	02e50663          	beq	a0,a4,23b4 <_vsnprintf+0x7c>
      out(*format, buffer, idx++, maxlen);
    238c:	00148413          	addi	s0,s1,1
    2390:	00090693          	mv	a3,s2
    2394:	00048613          	mv	a2,s1
    2398:	00098593          	mv	a1,s3
    239c:	000a00e7          	jalr	s4
      format++;
    23a0:	01c12783          	lw	a5,28(sp)
    23a4:	00178793          	addi	a5,a5,1
    23a8:	00f12e23          	sw	a5,28(sp)
      out(*format, buffer, idx++, maxlen);
    23ac:	00040493          	mv	s1,s0
      continue;
    23b0:	fc9ff06f          	j	2378 <_vsnprintf+0x40>
      format++;
    23b4:	00178793          	addi	a5,a5,1
    23b8:	00f12e23          	sw	a5,28(sp)
    flags = 0U;
    23bc:	00000413          	li	s0,0
    23c0:	0700006f          	j	2430 <_vsnprintf+0xf8>
        case '0': flags |= FLAGS_ZEROPAD; format++; n = 1U; break;
    23c4:	00146413          	ori	s0,s0,1
    23c8:	00170713          	addi	a4,a4,1
    23cc:	00e12e23          	sw	a4,28(sp)
    23d0:	00100a93          	li	s5,1
    23d4:	0580006f          	j	242c <_vsnprintf+0xf4>
        case '-': flags |= FLAGS_LEFT;    format++; n = 1U; break;
    23d8:	00246413          	ori	s0,s0,2
    23dc:	00170713          	addi	a4,a4,1
    23e0:	00e12e23          	sw	a4,28(sp)
    23e4:	00100a93          	li	s5,1
    23e8:	0440006f          	j	242c <_vsnprintf+0xf4>
        case '+': flags |= FLAGS_PLUS;    format++; n = 1U; break;
    23ec:	00446413          	ori	s0,s0,4
    23f0:	00170713          	addi	a4,a4,1
    23f4:	00e12e23          	sw	a4,28(sp)
    23f8:	00100a93          	li	s5,1
    23fc:	0300006f          	j	242c <_vsnprintf+0xf4>
        case ' ': flags |= FLAGS_SPACE;   format++; n = 1U; break;
    2400:	00846413          	ori	s0,s0,8
    2404:	00170713          	addi	a4,a4,1
    2408:	00e12e23          	sw	a4,28(sp)
    240c:	00100a93          	li	s5,1
    2410:	01c0006f          	j	242c <_vsnprintf+0xf4>
        case '#': flags |= FLAGS_HASH;    format++; n = 1U; break;
    2414:	01046413          	ori	s0,s0,16
    2418:	00170713          	addi	a4,a4,1
    241c:	00e12e23          	sw	a4,28(sp)
    2420:	00100a93          	li	s5,1
    2424:	0080006f          	j	242c <_vsnprintf+0xf4>
      switch (*format) {
    2428:	00000a93          	li	s5,0
    } while (n);
    242c:	020a8a63          	beqz	s5,2460 <_vsnprintf+0x128>
      switch (*format) {
    2430:	01c12703          	lw	a4,28(sp)
    2434:	00074783          	lbu	a5,0(a4)
    2438:	fe078793          	addi	a5,a5,-32
    243c:	0ff7f613          	zext.b	a2,a5
    2440:	01000693          	li	a3,16
    2444:	fec6e2e3          	bltu	a3,a2,2428 <_vsnprintf+0xf0>
    2448:	00261793          	slli	a5,a2,0x2
    244c:	000096b7          	lui	a3,0x9
    2450:	2dc68693          	addi	a3,a3,732 # 92dc <_data+0x948>
    2454:	00d787b3          	add	a5,a5,a3
    2458:	0007a783          	lw	a5,0(a5)
    245c:	00078067          	jr	a5
    if (_is_digit(*format)) {
    2460:	01c12783          	lw	a5,28(sp)
    2464:	0007c703          	lbu	a4,0(a5)
  return (ch >= '0') && (ch <= '9');
    2468:	fd070793          	addi	a5,a4,-48
    246c:	0ff7f793          	zext.b	a5,a5
    if (_is_digit(*format)) {
    2470:	00900693          	li	a3,9
    2474:	04f6f863          	bgeu	a3,a5,24c4 <_vsnprintf+0x18c>
    else if (*format == '*') {
    2478:	02a00793          	li	a5,42
    247c:	04f70c63          	beq	a4,a5,24d4 <_vsnprintf+0x19c>
    width = 0U;
    2480:	000a8b13          	mv	s6,s5
    if (*format == '.') {
    2484:	01c12783          	lw	a5,28(sp)
    2488:	0007c683          	lbu	a3,0(a5)
    248c:	02e00713          	li	a4,46
    2490:	06e68a63          	beq	a3,a4,2504 <_vsnprintf+0x1cc>
    switch (*format) {
    2494:	01c12703          	lw	a4,28(sp)
    2498:	00074783          	lbu	a5,0(a4)
    249c:	f9878793          	addi	a5,a5,-104
    24a0:	0ff7f613          	zext.b	a2,a5
    24a4:	01200693          	li	a3,18
    24a8:	12c6e663          	bltu	a3,a2,25d4 <_vsnprintf+0x29c>
    24ac:	00261793          	slli	a5,a2,0x2
    24b0:	000096b7          	lui	a3,0x9
    24b4:	32068693          	addi	a3,a3,800 # 9320 <_data+0x98c>
    24b8:	00d787b3          	add	a5,a5,a3
    24bc:	0007a783          	lw	a5,0(a5)
    24c0:	00078067          	jr	a5
      width = _atoi(&format);
    24c4:	01c10513          	addi	a0,sp,28
    24c8:	e41fe0ef          	jal	1308 <_atoi>
    24cc:	00050b13          	mv	s6,a0
    24d0:	fb5ff06f          	j	2484 <_vsnprintf+0x14c>
      const int w = va_arg(va, int);
    24d4:	01812783          	lw	a5,24(sp)
    24d8:	00478713          	addi	a4,a5,4
    24dc:	00e12c23          	sw	a4,24(sp)
    24e0:	0007ab03          	lw	s6,0(a5)
      if (w < 0) {
    24e4:	000b4a63          	bltz	s6,24f8 <_vsnprintf+0x1c0>
      format++;
    24e8:	01c12783          	lw	a5,28(sp)
    24ec:	00178793          	addi	a5,a5,1
    24f0:	00f12e23          	sw	a5,28(sp)
    24f4:	f91ff06f          	j	2484 <_vsnprintf+0x14c>
        flags |= FLAGS_LEFT;    // reverse padding
    24f8:	00246413          	ori	s0,s0,2
        width = (unsigned int)-w;
    24fc:	41600b33          	neg	s6,s6
    2500:	fe9ff06f          	j	24e8 <_vsnprintf+0x1b0>
      flags |= FLAGS_PRECISION;
    2504:	40046413          	ori	s0,s0,1024
      format++;
    2508:	00178713          	addi	a4,a5,1
    250c:	00e12e23          	sw	a4,28(sp)
      if (_is_digit(*format)) {
    2510:	0017c703          	lbu	a4,1(a5)
  return (ch >= '0') && (ch <= '9');
    2514:	fd070793          	addi	a5,a4,-48
    2518:	0ff7f793          	zext.b	a5,a5
      if (_is_digit(*format)) {
    251c:	00900693          	li	a3,9
    2520:	02f6f863          	bgeu	a3,a5,2550 <_vsnprintf+0x218>
      else if (*format == '*') {
    2524:	02a00793          	li	a5,42
    2528:	f6f716e3          	bne	a4,a5,2494 <_vsnprintf+0x15c>
        const int prec = (int)va_arg(va, int);
    252c:	01812783          	lw	a5,24(sp)
    2530:	00478713          	addi	a4,a5,4
    2534:	00e12c23          	sw	a4,24(sp)
    2538:	0007aa83          	lw	s5,0(a5)
        precision = prec > 0 ? (unsigned int)prec : 0U;
    253c:	020ac263          	bltz	s5,2560 <_vsnprintf+0x228>
        format++;
    2540:	01c12783          	lw	a5,28(sp)
    2544:	00178793          	addi	a5,a5,1
    2548:	00f12e23          	sw	a5,28(sp)
    254c:	f49ff06f          	j	2494 <_vsnprintf+0x15c>
        precision = _atoi(&format);
    2550:	01c10513          	addi	a0,sp,28
    2554:	db5fe0ef          	jal	1308 <_atoi>
    2558:	00050a93          	mv	s5,a0
    255c:	f39ff06f          	j	2494 <_vsnprintf+0x15c>
        precision = prec > 0 ? (unsigned int)prec : 0U;
    2560:	00000a93          	li	s5,0
    2564:	fddff06f          	j	2540 <_vsnprintf+0x208>
        flags |= FLAGS_LONG;
    2568:	10046613          	ori	a2,s0,256
        format++;
    256c:	00170793          	addi	a5,a4,1
    2570:	00f12e23          	sw	a5,28(sp)
        if (*format == 'l') {
    2574:	00174683          	lbu	a3,1(a4)
    2578:	06c00793          	li	a5,108
    257c:	00f68663          	beq	a3,a5,2588 <_vsnprintf+0x250>
        flags |= FLAGS_LONG;
    2580:	00060413          	mv	s0,a2
    2584:	0500006f          	j	25d4 <_vsnprintf+0x29c>
          flags |= FLAGS_LONG_LONG;
    2588:	30046413          	ori	s0,s0,768
          format++;
    258c:	00270713          	addi	a4,a4,2
    2590:	00e12e23          	sw	a4,28(sp)
    2594:	0400006f          	j	25d4 <_vsnprintf+0x29c>
        flags |= FLAGS_SHORT;
    2598:	08046613          	ori	a2,s0,128
        format++;
    259c:	00170793          	addi	a5,a4,1
    25a0:	00f12e23          	sw	a5,28(sp)
        if (*format == 'h') {
    25a4:	00174683          	lbu	a3,1(a4)
    25a8:	06800793          	li	a5,104
    25ac:	00f68663          	beq	a3,a5,25b8 <_vsnprintf+0x280>
        flags |= FLAGS_SHORT;
    25b0:	00060413          	mv	s0,a2
    25b4:	0200006f          	j	25d4 <_vsnprintf+0x29c>
          flags |= FLAGS_CHAR;
    25b8:	0c046413          	ori	s0,s0,192
          format++;
    25bc:	00270713          	addi	a4,a4,2
    25c0:	00e12e23          	sw	a4,28(sp)
    25c4:	0100006f          	j	25d4 <_vsnprintf+0x29c>
        flags |= (sizeof(ptrdiff_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    25c8:	10046413          	ori	s0,s0,256
        format++;
    25cc:	00170713          	addi	a4,a4,1
    25d0:	00e12e23          	sw	a4,28(sp)
    switch (*format) {
    25d4:	01c12783          	lw	a5,28(sp)
    25d8:	0007c503          	lbu	a0,0(a5)
    25dc:	06700793          	li	a5,103
    25e0:	04a7ea63          	bltu	a5,a0,2634 <_vsnprintf+0x2fc>
    25e4:	02500793          	li	a5,37
    25e8:	6af56863          	bltu	a0,a5,2c98 <_vsnprintf+0x960>
    25ec:	fdb50793          	addi	a5,a0,-37
    25f0:	0ff7f693          	zext.b	a3,a5
    25f4:	04200713          	li	a4,66
    25f8:	6ad76063          	bltu	a4,a3,2c98 <_vsnprintf+0x960>
    25fc:	00269793          	slli	a5,a3,0x2
    2600:	00009737          	lui	a4,0x9
    2604:	36c70713          	addi	a4,a4,876 # 936c <_data+0x9d8>
    2608:	00e787b3          	add	a5,a5,a4
    260c:	0007a783          	lw	a5,0(a5)
    2610:	00078067          	jr	a5
        flags |= (sizeof(intmax_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    2614:	20046413          	ori	s0,s0,512
        format++;
    2618:	00170713          	addi	a4,a4,1
    261c:	00e12e23          	sw	a4,28(sp)
        break;
    2620:	fb5ff06f          	j	25d4 <_vsnprintf+0x29c>
        flags |= (sizeof(size_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    2624:	10046413          	ori	s0,s0,256
        format++;
    2628:	00170713          	addi	a4,a4,1
    262c:	00e12e23          	sw	a4,28(sp)
        break;
    2630:	fa5ff06f          	j	25d4 <_vsnprintf+0x29c>
    switch (*format) {
    2634:	07800793          	li	a5,120
    2638:	66a7e063          	bltu	a5,a0,2c98 <_vsnprintf+0x960>
    263c:	06900793          	li	a5,105
    2640:	64f56c63          	bltu	a0,a5,2c98 <_vsnprintf+0x960>
    2644:	f9750713          	addi	a4,a0,-105
    2648:	00100793          	li	a5,1
    264c:	00e797b3          	sll	a5,a5,a4
    2650:	00009737          	lui	a4,0x9
    2654:	04170713          	addi	a4,a4,65 # 9041 <_data+0x6ad>
    2658:	00e7f733          	and	a4,a5,a4
    265c:	04071263          	bnez	a4,26a0 <_vsnprintf+0x368>
    2660:	0807f713          	andi	a4,a5,128
    2664:	5a071a63          	bnez	a4,2c18 <_vsnprintf+0x8e0>
    2668:	4007f793          	andi	a5,a5,1024
    266c:	62078663          	beqz	a5,2c98 <_vsnprintf+0x960>
    2670:	03712e23          	sw	s7,60(sp)
    2674:	03812c23          	sw	s8,56(sp)
    2678:	03912a23          	sw	s9,52(sp)
    267c:	03a12823          	sw	s10,48(sp)
      }

      case 's' : {
        const char* p = va_arg(va, char*);
    2680:	01812783          	lw	a5,24(sp)
    2684:	00478713          	addi	a4,a5,4
    2688:	00e12c23          	sw	a4,24(sp)
    268c:	0007ac03          	lw	s8,0(a5)
        unsigned int l = _strnlen_s(p, precision ? precision : (size_t)-1);
    2690:	4c0a9463          	bnez	s5,2b58 <_vsnprintf+0x820>
    2694:	fff00713          	li	a4,-1
    2698:	000c0793          	mv	a5,s8
    269c:	4880006f          	j	2b24 <_vsnprintf+0x7ec>
        if (*format == 'x' || *format == 'X') {
    26a0:	06f00793          	li	a5,111
    26a4:	02f50a63          	beq	a0,a5,26d8 <_vsnprintf+0x3a0>
    26a8:	00a7ee63          	bltu	a5,a0,26c4 <_vsnprintf+0x38c>
    26ac:	05800793          	li	a5,88
    26b0:	0af50c63          	beq	a0,a5,2768 <_vsnprintf+0x430>
    26b4:	06200793          	li	a5,98
    26b8:	00f51a63          	bne	a0,a5,26cc <_vsnprintf+0x394>
        flags |= FLAGS_SHORT;
    26bc:	00200813          	li	a6,2
    26c0:	01c0006f          	j	26dc <_vsnprintf+0x3a4>
    26c4:	07800793          	li	a5,120
    26c8:	0af50463          	beq	a0,a5,2770 <_vsnprintf+0x438>
          flags &= ~FLAGS_HASH;   // no hash for dec format
    26cc:	fef47413          	andi	s0,s0,-17
          base = 10U;
    26d0:	00a00813          	li	a6,10
    26d4:	0080006f          	j	26dc <_vsnprintf+0x3a4>
        flags |= FLAGS_SHORT;
    26d8:	00800813          	li	a6,8
        if (*format == 'X') {
    26dc:	05800793          	li	a5,88
    26e0:	08f50c63          	beq	a0,a5,2778 <_vsnprintf+0x440>
        if ((*format != 'i') && (*format != 'd')) {
    26e4:	06900793          	li	a5,105
    26e8:	00f50863          	beq	a0,a5,26f8 <_vsnprintf+0x3c0>
    26ec:	06400793          	li	a5,100
    26f0:	00f50463          	beq	a0,a5,26f8 <_vsnprintf+0x3c0>
          flags &= ~(FLAGS_PLUS | FLAGS_SPACE);
    26f4:	ff347413          	andi	s0,s0,-13
        if (flags & FLAGS_PRECISION) {
    26f8:	40047793          	andi	a5,s0,1024
    26fc:	00078463          	beqz	a5,2704 <_vsnprintf+0x3cc>
          flags &= ~FLAGS_ZEROPAD;
    2700:	ffe47413          	andi	s0,s0,-2
        if ((*format == 'i') || (*format == 'd')) {
    2704:	06900793          	li	a5,105
    2708:	06f50c63          	beq	a0,a5,2780 <_vsnprintf+0x448>
    270c:	06400793          	li	a5,100
    2710:	06f50863          	beq	a0,a5,2780 <_vsnprintf+0x448>
          if (flags & FLAGS_LONG_LONG) {
    2714:	20047793          	andi	a5,s0,512
    2718:	1a079c63          	bnez	a5,28d0 <_vsnprintf+0x598>
          else if (flags & FLAGS_LONG) {
    271c:	10047793          	andi	a5,s0,256
    2720:	20079063          	bnez	a5,2920 <_vsnprintf+0x5e8>
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
    2724:	04047793          	andi	a5,s0,64
    2728:	22078a63          	beqz	a5,295c <_vsnprintf+0x624>
    272c:	01812783          	lw	a5,24(sp)
    2730:	00478713          	addi	a4,a5,4
    2734:	00e12c23          	sw	a4,24(sp)
    2738:	0007c703          	lbu	a4,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, value, false, base, precision, width, flags);
    273c:	00812223          	sw	s0,4(sp)
    2740:	01612023          	sw	s6,0(sp)
    2744:	000a8893          	mv	a7,s5
    2748:	00000793          	li	a5,0
    274c:	00090693          	mv	a3,s2
    2750:	00048613          	mv	a2,s1
    2754:	00098593          	mv	a1,s3
    2758:	000a0513          	mv	a0,s4
    275c:	ec1fe0ef          	jal	161c <_ntoa_long>
    2760:	00050493          	mv	s1,a0
    2764:	0780006f          	j	27dc <_vsnprintf+0x4a4>
          base = 10U;
    2768:	01000813          	li	a6,16
    276c:	f71ff06f          	j	26dc <_vsnprintf+0x3a4>
        flags |= FLAGS_SHORT;
    2770:	01000813          	li	a6,16
    2774:	f69ff06f          	j	26dc <_vsnprintf+0x3a4>
          flags |= FLAGS_UPPERCASE;
    2778:	02046413          	ori	s0,s0,32
    277c:	f69ff06f          	j	26e4 <_vsnprintf+0x3ac>
          if (flags & FLAGS_LONG_LONG) {
    2780:	20047793          	andi	a5,s0,512
    2784:	06079463          	bnez	a5,27ec <_vsnprintf+0x4b4>
          else if (flags & FLAGS_LONG) {
    2788:	10047793          	andi	a5,s0,256
    278c:	0c079663          	bnez	a5,2858 <_vsnprintf+0x520>
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
    2790:	04047793          	andi	a5,s0,64
    2794:	10078663          	beqz	a5,28a0 <_vsnprintf+0x568>
    2798:	01812783          	lw	a5,24(sp)
    279c:	00478713          	addi	a4,a5,4
    27a0:	00e12c23          	sw	a4,24(sp)
    27a4:	0007c783          	lbu	a5,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned int)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    27a8:	41f7d713          	srai	a4,a5,0x1f
    27ac:	00f746b3          	xor	a3,a4,a5
    27b0:	00812223          	sw	s0,4(sp)
    27b4:	01612023          	sw	s6,0(sp)
    27b8:	000a8893          	mv	a7,s5
    27bc:	01f7d793          	srli	a5,a5,0x1f
    27c0:	40e68733          	sub	a4,a3,a4
    27c4:	00090693          	mv	a3,s2
    27c8:	00048613          	mv	a2,s1
    27cc:	00098593          	mv	a1,s3
    27d0:	000a0513          	mv	a0,s4
    27d4:	e49fe0ef          	jal	161c <_ntoa_long>
    27d8:	00050493          	mv	s1,a0
        format++;
    27dc:	01c12783          	lw	a5,28(sp)
    27e0:	00178793          	addi	a5,a5,1
    27e4:	00f12e23          	sw	a5,28(sp)
        break;
    27e8:	b91ff06f          	j	2378 <_vsnprintf+0x40>
            const long long value = va_arg(va, long long);
    27ec:	01812783          	lw	a5,24(sp)
    27f0:	00778793          	addi	a5,a5,7
    27f4:	ff87f793          	andi	a5,a5,-8
    27f8:	00878713          	addi	a4,a5,8
    27fc:	00e12c23          	sw	a4,24(sp)
    2800:	0007a703          	lw	a4,0(a5)
    2804:	0047a583          	lw	a1,4(a5)
            idx = _ntoa_long_long(out, buffer, idx, maxlen, (unsigned long long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    2808:	41f5d693          	srai	a3,a1,0x1f
    280c:	00e6c7b3          	xor	a5,a3,a4
    2810:	00b6c633          	xor	a2,a3,a1
    2814:	40d78733          	sub	a4,a5,a3
    2818:	00e7b7b3          	sltu	a5,a5,a4
    281c:	40d606b3          	sub	a3,a2,a3
    2820:	00812623          	sw	s0,12(sp)
    2824:	01612423          	sw	s6,8(sp)
    2828:	01512223          	sw	s5,4(sp)
    282c:	00012023          	sw	zero,0(sp)
    2830:	00080893          	mv	a7,a6
    2834:	01f5d813          	srli	a6,a1,0x1f
    2838:	40f687b3          	sub	a5,a3,a5
    283c:	00090693          	mv	a3,s2
    2840:	00048613          	mv	a2,s1
    2844:	00098593          	mv	a1,s3
    2848:	000a0513          	mv	a0,s4
    284c:	e95fe0ef          	jal	16e0 <_ntoa_long_long>
    2850:	00050493          	mv	s1,a0
    2854:	f89ff06f          	j	27dc <_vsnprintf+0x4a4>
            const long value = va_arg(va, long);
    2858:	01812783          	lw	a5,24(sp)
    285c:	00478713          	addi	a4,a5,4
    2860:	00e12c23          	sw	a4,24(sp)
    2864:	0007a783          	lw	a5,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    2868:	41f7d713          	srai	a4,a5,0x1f
    286c:	00f746b3          	xor	a3,a4,a5
    2870:	00812223          	sw	s0,4(sp)
    2874:	01612023          	sw	s6,0(sp)
    2878:	000a8893          	mv	a7,s5
    287c:	01f7d793          	srli	a5,a5,0x1f
    2880:	40e68733          	sub	a4,a3,a4
    2884:	00090693          	mv	a3,s2
    2888:	00048613          	mv	a2,s1
    288c:	00098593          	mv	a1,s3
    2890:	000a0513          	mv	a0,s4
    2894:	d89fe0ef          	jal	161c <_ntoa_long>
    2898:	00050493          	mv	s1,a0
    289c:	f41ff06f          	j	27dc <_vsnprintf+0x4a4>
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
    28a0:	08047793          	andi	a5,s0,128
    28a4:	00078c63          	beqz	a5,28bc <_vsnprintf+0x584>
    28a8:	01812783          	lw	a5,24(sp)
    28ac:	00478713          	addi	a4,a5,4
    28b0:	00e12c23          	sw	a4,24(sp)
    28b4:	00079783          	lh	a5,0(a5)
    28b8:	ef1ff06f          	j	27a8 <_vsnprintf+0x470>
    28bc:	01812783          	lw	a5,24(sp)
    28c0:	00478713          	addi	a4,a5,4
    28c4:	00e12c23          	sw	a4,24(sp)
    28c8:	0007a783          	lw	a5,0(a5)
    28cc:	eddff06f          	j	27a8 <_vsnprintf+0x470>
            idx = _ntoa_long_long(out, buffer, idx, maxlen, va_arg(va, unsigned long long), false, base, precision, width, flags);
    28d0:	01812783          	lw	a5,24(sp)
    28d4:	00778793          	addi	a5,a5,7
    28d8:	ff87f793          	andi	a5,a5,-8
    28dc:	00878713          	addi	a4,a5,8
    28e0:	00e12c23          	sw	a4,24(sp)
    28e4:	0007a703          	lw	a4,0(a5)
    28e8:	0047a783          	lw	a5,4(a5)
    28ec:	00812623          	sw	s0,12(sp)
    28f0:	01612423          	sw	s6,8(sp)
    28f4:	01512223          	sw	s5,4(sp)
    28f8:	00012023          	sw	zero,0(sp)
    28fc:	00080893          	mv	a7,a6
    2900:	00000813          	li	a6,0
    2904:	00090693          	mv	a3,s2
    2908:	00048613          	mv	a2,s1
    290c:	00098593          	mv	a1,s3
    2910:	000a0513          	mv	a0,s4
    2914:	dcdfe0ef          	jal	16e0 <_ntoa_long_long>
    2918:	00050493          	mv	s1,a0
    291c:	ec1ff06f          	j	27dc <_vsnprintf+0x4a4>
            idx = _ntoa_long(out, buffer, idx, maxlen, va_arg(va, unsigned long), false, base, precision, width, flags);
    2920:	01812783          	lw	a5,24(sp)
    2924:	00478713          	addi	a4,a5,4
    2928:	00e12c23          	sw	a4,24(sp)
    292c:	0007a703          	lw	a4,0(a5)
    2930:	00812223          	sw	s0,4(sp)
    2934:	01612023          	sw	s6,0(sp)
    2938:	000a8893          	mv	a7,s5
    293c:	00000793          	li	a5,0
    2940:	00090693          	mv	a3,s2
    2944:	00048613          	mv	a2,s1
    2948:	00098593          	mv	a1,s3
    294c:	000a0513          	mv	a0,s4
    2950:	ccdfe0ef          	jal	161c <_ntoa_long>
    2954:	00050493          	mv	s1,a0
    2958:	e85ff06f          	j	27dc <_vsnprintf+0x4a4>
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
    295c:	08047793          	andi	a5,s0,128
    2960:	00078c63          	beqz	a5,2978 <_vsnprintf+0x640>
    2964:	01812783          	lw	a5,24(sp)
    2968:	00478713          	addi	a4,a5,4
    296c:	00e12c23          	sw	a4,24(sp)
    2970:	0007d703          	lhu	a4,0(a5)
    2974:	dc9ff06f          	j	273c <_vsnprintf+0x404>
    2978:	01812783          	lw	a5,24(sp)
    297c:	00478713          	addi	a4,a5,4
    2980:	00e12c23          	sw	a4,24(sp)
    2984:	0007a703          	lw	a4,0(a5)
    2988:	db5ff06f          	j	273c <_vsnprintf+0x404>
        if (*format == 'F') flags |= FLAGS_UPPERCASE;
    298c:	04600793          	li	a5,70
    2990:	04f50a63          	beq	a0,a5,29e4 <_vsnprintf+0x6ac>
        idx = _ftoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
    2994:	01812783          	lw	a5,24(sp)
    2998:	00778793          	addi	a5,a5,7
    299c:	ff87f793          	andi	a5,a5,-8
    29a0:	00878713          	addi	a4,a5,8
    29a4:	00e12c23          	sw	a4,24(sp)
    29a8:	0007a703          	lw	a4,0(a5)
    29ac:	0047a783          	lw	a5,4(a5)
    29b0:	00812023          	sw	s0,0(sp)
    29b4:	000b0893          	mv	a7,s6
    29b8:	000a8813          	mv	a6,s5
    29bc:	00090693          	mv	a3,s2
    29c0:	00048613          	mv	a2,s1
    29c4:	00098593          	mv	a1,s3
    29c8:	000a0513          	mv	a0,s4
    29cc:	c20ff0ef          	jal	1dec <_ftoa>
    29d0:	00050493          	mv	s1,a0
        format++;
    29d4:	01c12783          	lw	a5,28(sp)
    29d8:	00178793          	addi	a5,a5,1
    29dc:	00f12e23          	sw	a5,28(sp)
        break;
    29e0:	999ff06f          	j	2378 <_vsnprintf+0x40>
        if (*format == 'F') flags |= FLAGS_UPPERCASE;
    29e4:	02046413          	ori	s0,s0,32
    29e8:	fadff06f          	j	2994 <_vsnprintf+0x65c>
        if ((*format == 'g')||(*format == 'G')) flags |= FLAGS_ADAPT_EXP;
    29ec:	06700793          	li	a5,103
    29f0:	00f50663          	beq	a0,a5,29fc <_vsnprintf+0x6c4>
    29f4:	04700793          	li	a5,71
    29f8:	00f51863          	bne	a0,a5,2a08 <_vsnprintf+0x6d0>
    29fc:	000017b7          	lui	a5,0x1
    2a00:	80078793          	addi	a5,a5,-2048 # 800 <CUSTOM2+0x7a5>
    2a04:	00f46433          	or	s0,s0,a5
        if ((*format == 'E')||(*format == 'G')) flags |= FLAGS_UPPERCASE;
    2a08:	04500793          	li	a5,69
    2a0c:	00f50663          	beq	a0,a5,2a18 <_vsnprintf+0x6e0>
    2a10:	04700793          	li	a5,71
    2a14:	00f51463          	bne	a0,a5,2a1c <_vsnprintf+0x6e4>
    2a18:	02046413          	ori	s0,s0,32
        idx = _etoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
    2a1c:	01812783          	lw	a5,24(sp)
    2a20:	00778793          	addi	a5,a5,7
    2a24:	ff87f793          	andi	a5,a5,-8
    2a28:	00878713          	addi	a4,a5,8
    2a2c:	00e12c23          	sw	a4,24(sp)
    2a30:	0007a703          	lw	a4,0(a5)
    2a34:	0047a783          	lw	a5,4(a5)
    2a38:	00812023          	sw	s0,0(sp)
    2a3c:	000b0893          	mv	a7,s6
    2a40:	000a8813          	mv	a6,s5
    2a44:	00090693          	mv	a3,s2
    2a48:	00048613          	mv	a2,s1
    2a4c:	00098593          	mv	a1,s3
    2a50:	000a0513          	mv	a0,s4
    2a54:	e25fe0ef          	jal	1878 <_etoa>
    2a58:	00050493          	mv	s1,a0
        format++;
    2a5c:	01c12783          	lw	a5,28(sp)
    2a60:	00178793          	addi	a5,a5,1
    2a64:	00f12e23          	sw	a5,28(sp)
        break;
    2a68:	911ff06f          	j	2378 <_vsnprintf+0x40>
    2a6c:	03712e23          	sw	s7,60(sp)
        if (!(flags & FLAGS_LEFT)) {
    2a70:	00247413          	andi	s0,s0,2
    2a74:	06040a63          	beqz	s0,2ae8 <_vsnprintf+0x7b0>
        unsigned int l = 1U;
    2a78:	00100a93          	li	s5,1
        out((char)va_arg(va, int), buffer, idx++, maxlen);
    2a7c:	01812783          	lw	a5,24(sp)
    2a80:	00478713          	addi	a4,a5,4
    2a84:	00e12c23          	sw	a4,24(sp)
    2a88:	00148b93          	addi	s7,s1,1
    2a8c:	00090693          	mv	a3,s2
    2a90:	00048613          	mv	a2,s1
    2a94:	00098593          	mv	a1,s3
    2a98:	0007c503          	lbu	a0,0(a5)
    2a9c:	000a00e7          	jalr	s4
        if (flags & FLAGS_LEFT) {
    2aa0:	06041863          	bnez	s0,2b10 <_vsnprintf+0x7d8>
        format++;
    2aa4:	01c12783          	lw	a5,28(sp)
    2aa8:	00178793          	addi	a5,a5,1
    2aac:	00f12e23          	sw	a5,28(sp)
        break;
    2ab0:	000b8493          	mv	s1,s7
    2ab4:	03c12b83          	lw	s7,60(sp)
    2ab8:	8c1ff06f          	j	2378 <_vsnprintf+0x40>
            out(' ', buffer, idx++, maxlen);
    2abc:	00148b93          	addi	s7,s1,1
    2ac0:	00090693          	mv	a3,s2
    2ac4:	00048613          	mv	a2,s1
    2ac8:	00098593          	mv	a1,s3
    2acc:	02000513          	li	a0,32
    2ad0:	000a00e7          	jalr	s4
          while (l++ < width) {
    2ad4:	000a8793          	mv	a5,s5
            out(' ', buffer, idx++, maxlen);
    2ad8:	000b8493          	mv	s1,s7
          while (l++ < width) {
    2adc:	00178a93          	addi	s5,a5,1
    2ae0:	fd67eee3          	bltu	a5,s6,2abc <_vsnprintf+0x784>
    2ae4:	f99ff06f          	j	2a7c <_vsnprintf+0x744>
        unsigned int l = 1U;
    2ae8:	00100793          	li	a5,1
    2aec:	ff1ff06f          	j	2adc <_vsnprintf+0x7a4>
            out(' ', buffer, idx++, maxlen);
    2af0:	001b8493          	addi	s1,s7,1
    2af4:	00090693          	mv	a3,s2
    2af8:	000b8613          	mv	a2,s7
    2afc:	00098593          	mv	a1,s3
    2b00:	02000513          	li	a0,32
    2b04:	000a00e7          	jalr	s4
          while (l++ < width) {
    2b08:	00040a93          	mv	s5,s0
            out(' ', buffer, idx++, maxlen);
    2b0c:	00048b93          	mv	s7,s1
          while (l++ < width) {
    2b10:	001a8413          	addi	s0,s5,1
    2b14:	fd6aeee3          	bltu	s5,s6,2af0 <_vsnprintf+0x7b8>
    2b18:	f8dff06f          	j	2aa4 <_vsnprintf+0x76c>
  for (s = str; *s && maxsize--; ++s);
    2b1c:	00178793          	addi	a5,a5,1
    2b20:	00068713          	mv	a4,a3
    2b24:	0007c683          	lbu	a3,0(a5)
    2b28:	00068663          	beqz	a3,2b34 <_vsnprintf+0x7fc>
    2b2c:	fff70693          	addi	a3,a4,-1
    2b30:	fe0716e3          	bnez	a4,2b1c <_vsnprintf+0x7e4>
  return (unsigned int)(s - str);
    2b34:	41878bb3          	sub	s7,a5,s8
        // pre padding
        if (flags & FLAGS_PRECISION) {
    2b38:	40047c93          	andi	s9,s0,1024
    2b3c:	000c8663          	beqz	s9,2b48 <_vsnprintf+0x810>
          l = (l < precision ? l : precision);
    2b40:	017af463          	bgeu	s5,s7,2b48 <_vsnprintf+0x810>
    2b44:	000a8b93          	mv	s7,s5
        }
        if (!(flags & FLAGS_LEFT)) {
    2b48:	00247d13          	andi	s10,s0,2
    2b4c:	060d1463          	bnez	s10,2bb4 <_vsnprintf+0x87c>
    2b50:	03b12623          	sw	s11,44(sp)
    2b54:	02c0006f          	j	2b80 <_vsnprintf+0x848>
        unsigned int l = _strnlen_s(p, precision ? precision : (size_t)-1);
    2b58:	000a8713          	mv	a4,s5
    2b5c:	b3dff06f          	j	2698 <_vsnprintf+0x360>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
    2b60:	00148d93          	addi	s11,s1,1
    2b64:	00090693          	mv	a3,s2
    2b68:	00048613          	mv	a2,s1
    2b6c:	00098593          	mv	a1,s3
    2b70:	02000513          	li	a0,32
    2b74:	000a00e7          	jalr	s4
          while (l++ < width) {
    2b78:	00040b93          	mv	s7,s0
            out(' ', buffer, idx++, maxlen);
    2b7c:	000d8493          	mv	s1,s11
          while (l++ < width) {
    2b80:	001b8413          	addi	s0,s7,1
    2b84:	fd6beee3          	bltu	s7,s6,2b60 <_vsnprintf+0x828>
    2b88:	00040b93          	mv	s7,s0
    2b8c:	02c12d83          	lw	s11,44(sp)
    2b90:	0240006f          	j	2bb4 <_vsnprintf+0x87c>
          }
        }
        // string output
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
    2b94:	00078a93          	mv	s5,a5
          out(*(p++), buffer, idx++, maxlen);
    2b98:	001c0c13          	addi	s8,s8,1
    2b9c:	00148413          	addi	s0,s1,1
    2ba0:	00090693          	mv	a3,s2
    2ba4:	00048613          	mv	a2,s1
    2ba8:	00098593          	mv	a1,s3
    2bac:	000a00e7          	jalr	s4
    2bb0:	00040493          	mv	s1,s0
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
    2bb4:	000c4503          	lbu	a0,0(s8)
    2bb8:	00050863          	beqz	a0,2bc8 <_vsnprintf+0x890>
    2bbc:	fc0c8ee3          	beqz	s9,2b98 <_vsnprintf+0x860>
    2bc0:	fffa8793          	addi	a5,s5,-1
    2bc4:	fc0a98e3          	bnez	s5,2b94 <_vsnprintf+0x85c>
        }
        // post padding
        if (flags & FLAGS_LEFT) {
    2bc8:	040d1263          	bnez	s10,2c0c <_vsnprintf+0x8d4>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
          }
        }
        format++;
    2bcc:	01c12783          	lw	a5,28(sp)
    2bd0:	00178793          	addi	a5,a5,1
    2bd4:	00f12e23          	sw	a5,28(sp)
        break;
    2bd8:	03c12b83          	lw	s7,60(sp)
    2bdc:	03812c03          	lw	s8,56(sp)
    2be0:	03412c83          	lw	s9,52(sp)
    2be4:	03012d03          	lw	s10,48(sp)
    2be8:	f90ff06f          	j	2378 <_vsnprintf+0x40>
            out(' ', buffer, idx++, maxlen);
    2bec:	00148a93          	addi	s5,s1,1
    2bf0:	00090693          	mv	a3,s2
    2bf4:	00048613          	mv	a2,s1
    2bf8:	00098593          	mv	a1,s3
    2bfc:	02000513          	li	a0,32
    2c00:	000a00e7          	jalr	s4
          while (l++ < width) {
    2c04:	00040b93          	mv	s7,s0
            out(' ', buffer, idx++, maxlen);
    2c08:	000a8493          	mv	s1,s5
          while (l++ < width) {
    2c0c:	001b8413          	addi	s0,s7,1
    2c10:	fd6beee3          	bltu	s7,s6,2bec <_vsnprintf+0x8b4>
    2c14:	fb9ff06f          	j	2bcc <_vsnprintf+0x894>
      }

      case 'p' : {
        width = sizeof(void*) * 2U;
        flags |= FLAGS_ZEROPAD | FLAGS_UPPERCASE;
    2c18:	02146413          	ori	s0,s0,33
        if (is_ll) {
          idx = _ntoa_long_long(out, buffer, idx, maxlen, (uintptr_t)va_arg(va, void*), false, 16U, precision, width, flags);
        }
        else {
#endif
          idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)((uintptr_t)va_arg(va, void*)), false, 16U, precision, width, flags);
    2c1c:	01812783          	lw	a5,24(sp)
    2c20:	00478713          	addi	a4,a5,4
    2c24:	00e12c23          	sw	a4,24(sp)
    2c28:	0007a703          	lw	a4,0(a5)
    2c2c:	00812223          	sw	s0,4(sp)
    2c30:	00800793          	li	a5,8
    2c34:	00f12023          	sw	a5,0(sp)
    2c38:	000a8893          	mv	a7,s5
    2c3c:	01000813          	li	a6,16
    2c40:	00000793          	li	a5,0
    2c44:	00090693          	mv	a3,s2
    2c48:	00048613          	mv	a2,s1
    2c4c:	00098593          	mv	a1,s3
    2c50:	000a0513          	mv	a0,s4
    2c54:	9c9fe0ef          	jal	161c <_ntoa_long>
    2c58:	00050493          	mv	s1,a0
#if defined(PRINTF_SUPPORT_LONG_LONG)
        }
#endif
        format++;
    2c5c:	01c12783          	lw	a5,28(sp)
    2c60:	00178793          	addi	a5,a5,1
    2c64:	00f12e23          	sw	a5,28(sp)
        break;
    2c68:	f10ff06f          	j	2378 <_vsnprintf+0x40>
      }

      case '%' :
        out('%', buffer, idx++, maxlen);
    2c6c:	00148413          	addi	s0,s1,1
    2c70:	00090693          	mv	a3,s2
    2c74:	00048613          	mv	a2,s1
    2c78:	00098593          	mv	a1,s3
    2c7c:	02500513          	li	a0,37
    2c80:	000a00e7          	jalr	s4
        format++;
    2c84:	01c12783          	lw	a5,28(sp)
    2c88:	00178793          	addi	a5,a5,1
    2c8c:	00f12e23          	sw	a5,28(sp)
        out('%', buffer, idx++, maxlen);
    2c90:	00040493          	mv	s1,s0
        break;
    2c94:	ee4ff06f          	j	2378 <_vsnprintf+0x40>

      default :
        out(*format, buffer, idx++, maxlen);
    2c98:	00148413          	addi	s0,s1,1
    2c9c:	00090693          	mv	a3,s2
    2ca0:	00048613          	mv	a2,s1
    2ca4:	00098593          	mv	a1,s3
    2ca8:	000a00e7          	jalr	s4
        format++;
    2cac:	01c12783          	lw	a5,28(sp)
    2cb0:	00178793          	addi	a5,a5,1
    2cb4:	00f12e23          	sw	a5,28(sp)
        out(*format, buffer, idx++, maxlen);
    2cb8:	00040493          	mv	s1,s0
        break;
    2cbc:	ebcff06f          	j	2378 <_vsnprintf+0x40>
    out = _out_null;
    2cc0:	00001a37          	lui	s4,0x1
    2cc4:	304a0a13          	addi	s4,s4,772 # 1304 <_out_null>
    2cc8:	eacff06f          	j	2374 <_vsnprintf+0x3c>
    }
  }

  // termination
  out((char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
    2ccc:	0524e263          	bltu	s1,s2,2d10 <_vsnprintf+0x9d8>
    2cd0:	fff90613          	addi	a2,s2,-1
    2cd4:	00090693          	mv	a3,s2
    2cd8:	00098593          	mv	a1,s3
    2cdc:	00000513          	li	a0,0
    2ce0:	000a00e7          	jalr	s4

  // return written chars without terminating \0
  return (int)idx;
}
    2ce4:	00048513          	mv	a0,s1
    2ce8:	05c12083          	lw	ra,92(sp)
    2cec:	05812403          	lw	s0,88(sp)
    2cf0:	05412483          	lw	s1,84(sp)
    2cf4:	05012903          	lw	s2,80(sp)
    2cf8:	04c12983          	lw	s3,76(sp)
    2cfc:	04812a03          	lw	s4,72(sp)
    2d00:	04412a83          	lw	s5,68(sp)
    2d04:	04012b03          	lw	s6,64(sp)
    2d08:	06010113          	addi	sp,sp,96
    2d0c:	00008067          	ret
  out((char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
    2d10:	00048613          	mv	a2,s1
    2d14:	fc1ff06f          	j	2cd4 <_vsnprintf+0x99c>

00002d18 <emit_char>:
* @note 空间不够时**返回原位置、不写入**，也就是说超长内容是被截断的，
*       而不是溢出。所有输出路径都要经过这个函数，边界检查就只需要在这一处
*       做对。
******************************************************************************/
static uint32_t emit_char(char *out, uint32_t pos, uint32_t cap, char c)
{
    2d18:	00050793          	mv	a5,a0
    2d1c:	00058513          	mv	a0,a1
    if ((pos + 1U) < cap) {
    2d20:	00158713          	addi	a4,a1,1
    2d24:	00c76463          	bltu	a4,a2,2d2c <emit_char+0x14>
        out[pos] = c;
        return pos + 1U;
    }
    return pos;
}
    2d28:	00008067          	ret
        out[pos] = c;
    2d2c:	00b78533          	add	a0,a5,a1
    2d30:	00d50023          	sb	a3,0(a0)
        return pos + 1U;
    2d34:	00070513          	mv	a0,a4
    2d38:	00008067          	ret

00002d3c <emit_str>:
*       格式化 %s 时如果调用者传了个空指针，正常做法是崩溃；但对一个用于
*       排查问题的日志函数来说，崩溃恰恰是最糟的结果——它会把现场毁掉。
*       打印 (null) 既能让人看出"这里传空了"，又不会中断程序。
******************************************************************************/
static uint32_t emit_str(char *out, uint32_t pos, uint32_t cap, const char *s)
{
    2d3c:	ff010113          	addi	sp,sp,-16
    2d40:	00112623          	sw	ra,12(sp)
    2d44:	00812423          	sw	s0,8(sp)
    2d48:	00912223          	sw	s1,4(sp)
    2d4c:	01212023          	sw	s2,0(sp)
    2d50:	00050493          	mv	s1,a0
    2d54:	00060913          	mv	s2,a2
    2d58:	00068413          	mv	s0,a3
    if (s == 0) {
    2d5c:	02069263          	bnez	a3,2d80 <emit_str+0x44>
        s = "(null)";
    2d60:	00009437          	lui	s0,0x9
    2d64:	9b040413          	addi	s0,s0,-1616 # 89b0 <_data+0x1c>
    2d68:	0180006f          	j	2d80 <emit_str+0x44>
    }
    while (*s != '\0') {
        pos = emit_char(out, pos, cap, *s);
    2d6c:	00090613          	mv	a2,s2
    2d70:	00048513          	mv	a0,s1
    2d74:	fa5ff0ef          	jal	2d18 <emit_char>
    2d78:	00050593          	mv	a1,a0
        s++;
    2d7c:	00140413          	addi	s0,s0,1
    while (*s != '\0') {
    2d80:	00044683          	lbu	a3,0(s0)
    2d84:	fe0694e3          	bnez	a3,2d6c <emit_str+0x30>
    }
    return pos;
}
    2d88:	00058513          	mv	a0,a1
    2d8c:	00c12083          	lw	ra,12(sp)
    2d90:	00812403          	lw	s0,8(sp)
    2d94:	00412483          	lw	s1,4(sp)
    2d98:	00012903          	lw	s2,0(sp)
    2d9c:	01010113          	addi	sp,sp,16
    2da0:	00008067          	ret

00002da4 <emit_uint>:
* @note `n < sizeof(tmp)` 这个额外条件是防御性的：即使将来 tmp 的尺寸被改小、
*       或者 base 被传入了别的值，也不会写越界。
******************************************************************************/
static uint32_t emit_uint(char *out, uint32_t pos, uint32_t cap,
                          uint32_t value, uint32_t base, int upper)
{
    2da4:	fe010113          	addi	sp,sp,-32
    2da8:	00112e23          	sw	ra,28(sp)
    2dac:	00912a23          	sw	s1,20(sp)
    2db0:	01212823          	sw	s2,16(sp)
    2db4:	00050493          	mv	s1,a0
    2db8:	00060913          	mv	s2,a2
    const char *digits = upper ? "0123456789ABCDEF" : "0123456789abcdef";
    2dbc:	04078463          	beqz	a5,2e04 <emit_uint+0x60>
    2dc0:	00009537          	lui	a0,0x9
    2dc4:	9b850513          	addi	a0,a0,-1608 # 89b8 <_data+0x24>
    char        tmp[11];
    uint32_t    n = 0U;

    /* 0 要单独处理：上面的循环是"取余直到商为 0"，对 0 来说一次都不执行，
     * 结果会什么都不输出。而 "0" 显然应该输出一个 0。*/
    if (value == 0U) {
    2dc8:	04068463          	beqz	a3,2e10 <emit_uint+0x6c>
    2dcc:	00812c23          	sw	s0,24(sp)
    uint32_t    n = 0U;
    2dd0:	00000413          	li	s0,0
        return emit_char(out, pos, cap, '0');
    }
    while ((value != 0U) && (n < sizeof(tmp))) {
    2dd4:	06068a63          	beqz	a3,2e48 <emit_uint+0xa4>
    2dd8:	00a00793          	li	a5,10
    2ddc:	0687e663          	bltu	a5,s0,2e48 <emit_uint+0xa4>
        tmp[n] = digits[value % base];  /* 取最低位 */
    2de0:	02e6f7b3          	remu	a5,a3,a4
    2de4:	00f507b3          	add	a5,a0,a5
    2de8:	0007c603          	lbu	a2,0(a5)
    2dec:	01040793          	addi	a5,s0,16
    2df0:	002787b3          	add	a5,a5,sp
    2df4:	fec78a23          	sb	a2,-12(a5)
        value /= base;                  /* 去掉最低位 */
    2df8:	02e6d6b3          	divu	a3,a3,a4
        n++;
    2dfc:	00140413          	addi	s0,s0,1
    2e00:	fd5ff06f          	j	2dd4 <emit_uint+0x30>
    const char *digits = upper ? "0123456789ABCDEF" : "0123456789abcdef";
    2e04:	00009537          	lui	a0,0x9
    2e08:	9cc50513          	addi	a0,a0,-1588 # 89cc <_data+0x38>
    2e0c:	fbdff06f          	j	2dc8 <emit_uint+0x24>
        return emit_char(out, pos, cap, '0');
    2e10:	03000693          	li	a3,48
    2e14:	00090613          	mv	a2,s2
    2e18:	00048513          	mv	a0,s1
    2e1c:	efdff0ef          	jal	2d18 <emit_char>
    2e20:	00050593          	mv	a1,a0
    2e24:	02c0006f          	j	2e50 <emit_uint+0xac>
    }
    /* 倒序输出，得到高位在前的正常顺序。*/
    while (n > 0U) {
        n--;
    2e28:	fff40413          	addi	s0,s0,-1
        pos = emit_char(out, pos, cap, tmp[n]);
    2e2c:	01040793          	addi	a5,s0,16
    2e30:	002787b3          	add	a5,a5,sp
    2e34:	ff47c683          	lbu	a3,-12(a5)
    2e38:	00090613          	mv	a2,s2
    2e3c:	00048513          	mv	a0,s1
    2e40:	ed9ff0ef          	jal	2d18 <emit_char>
    2e44:	00050593          	mv	a1,a0
    while (n > 0U) {
    2e48:	fe0410e3          	bnez	s0,2e28 <emit_uint+0x84>
    2e4c:	01812403          	lw	s0,24(sp)
    }
    return pos;
}
    2e50:	00058513          	mv	a0,a1
    2e54:	01c12083          	lw	ra,28(sp)
    2e58:	01412483          	lw	s1,20(sp)
    2e5c:	01012903          	lw	s2,16(sp)
    2e60:	02010113          	addi	sp,sp,32
    2e64:	00008067          	ret

00002e68 <app_vformat>:
*       后面可能还有普通字符或别的格式符要处理，必须继续循环。
*       这一点和 frame.c 里状态机的写法正好相反——那里的每个状态处理完这一
*       字节就该返回了。
******************************************************************************/
static uint32_t app_vformat(char *out, uint32_t cap, const char *format, va_list ap)
{
    2e68:	fd010113          	addi	sp,sp,-48
    2e6c:	02112623          	sw	ra,44(sp)
    2e70:	00d12623          	sw	a3,12(sp)
    uint32_t pos = 0U;

    if ((out == 0) || (cap == 0U) || (format == 0)) {
    2e74:	2a050a63          	beqz	a0,3128 <app_vformat+0x2c0>
    2e78:	02812423          	sw	s0,40(sp)
    2e7c:	02912223          	sw	s1,36(sp)
    2e80:	03212023          	sw	s2,32(sp)
    2e84:	00050913          	mv	s2,a0
    2e88:	00058493          	mv	s1,a1
    2e8c:	00060413          	mv	s0,a2
    2e90:	2a058063          	beqz	a1,3130 <app_vformat+0x2c8>
    2e94:	2a060663          	beqz	a2,3140 <app_vformat+0x2d8>
    2e98:	01312e23          	sw	s3,28(sp)
    uint32_t pos = 0U;
    2e9c:	00000593          	li	a1,0
    2ea0:	0640006f          	j	2f04 <app_vformat+0x9c>
    }

    while (*format != '\0') {
        /* 普通字符直接输出。*/
        if (*format != '%') {
            pos = emit_char(out, pos, cap, *format);
    2ea4:	00048613          	mv	a2,s1
    2ea8:	00090513          	mv	a0,s2
    2eac:	e6dff0ef          	jal	2d18 <emit_char>
    2eb0:	00050593          	mv	a1,a0
            format++;
    2eb4:	00140413          	addi	s0,s0,1
            continue;
    2eb8:	04c0006f          	j	2f04 <app_vformat+0x9c>
        }

        /* 遇到 '%'，看下一个字符决定怎么处理。
         * format++ 之后 *format 就是格式符本身。*/
        format++;
        switch (*format) {
    2ebc:	1e078663          	beqz	a5,30a8 <app_vformat+0x240>
    2ec0:	02500713          	li	a4,37
    2ec4:	20e79063          	bne	a5,a4,30c4 <app_vformat+0x25c>
            pos = emit_str(out, pos, cap, "0x");
            pos = emit_uint(out, pos, cap, (uint32_t)va_arg(ap, void *), 16U, 0);
            break;
        case '%':
            /* "%%" 表示输出一个真正的百分号。*/
            pos = emit_char(out, pos, cap, '%');
    2ec8:	02500693          	li	a3,37
    2ecc:	00048613          	mv	a2,s1
    2ed0:	00090513          	mv	a0,s2
    2ed4:	e45ff0ef          	jal	2d18 <emit_char>
    2ed8:	00050593          	mv	a1,a0
            break;
    2edc:	0240006f          	j	2f00 <app_vformat+0x98>
            pos = emit_str(out, pos, cap, va_arg(ap, const char *));
    2ee0:	00c12783          	lw	a5,12(sp)
    2ee4:	00478713          	addi	a4,a5,4
    2ee8:	00e12623          	sw	a4,12(sp)
    2eec:	0007a683          	lw	a3,0(a5)
    2ef0:	00048613          	mv	a2,s1
    2ef4:	00090513          	mv	a0,s2
    2ef8:	e45ff0ef          	jal	2d3c <emit_str>
    2efc:	00050593          	mv	a1,a0
             * 在日志里一眼就能看见。如果静默吞掉，排查时会以为参数丢了。*/
            pos = emit_char(out, pos, cap, '%');
            pos = emit_char(out, pos, cap, *format);
            break;
        }
        format++;
    2f00:	00198413          	addi	s0,s3,1
    while (*format != '\0') {
    2f04:	00044683          	lbu	a3,0(s0)
    2f08:	1e068463          	beqz	a3,30f0 <app_vformat+0x288>
        if (*format != '%') {
    2f0c:	02500793          	li	a5,37
    2f10:	f8f69ae3          	bne	a3,a5,2ea4 <app_vformat+0x3c>
        format++;
    2f14:	00140993          	addi	s3,s0,1
        switch (*format) {
    2f18:	00144783          	lbu	a5,1(s0)
    2f1c:	07800713          	li	a4,120
    2f20:	1af76263          	bltu	a4,a5,30c4 <app_vformat+0x25c>
    2f24:	05800713          	li	a4,88
    2f28:	f8e7eae3          	bltu	a5,a4,2ebc <app_vformat+0x54>
    2f2c:	fa878793          	addi	a5,a5,-88
    2f30:	0ff7f693          	zext.b	a3,a5
    2f34:	02000713          	li	a4,32
    2f38:	18d76663          	bltu	a4,a3,30c4 <app_vformat+0x25c>
    2f3c:	00269793          	slli	a5,a3,0x2
    2f40:	00009737          	lui	a4,0x9
    2f44:	47870713          	addi	a4,a4,1144 # 9478 <_data+0xae4>
    2f48:	00e787b3          	add	a5,a5,a4
    2f4c:	0007a783          	lw	a5,0(a5)
    2f50:	00078067          	jr	a5
            pos = emit_char(out, pos, cap, (char)va_arg(ap, int));
    2f54:	00c12783          	lw	a5,12(sp)
    2f58:	00478713          	addi	a4,a5,4
    2f5c:	00e12623          	sw	a4,12(sp)
    2f60:	0007c683          	lbu	a3,0(a5)
    2f64:	00048613          	mv	a2,s1
    2f68:	00090513          	mv	a0,s2
    2f6c:	dadff0ef          	jal	2d18 <emit_char>
    2f70:	00050593          	mv	a1,a0
            break;
    2f74:	f8dff06f          	j	2f00 <app_vformat+0x98>
            int32_t v = va_arg(ap, int32_t);
    2f78:	00c12783          	lw	a5,12(sp)
    2f7c:	00478713          	addi	a4,a5,4
    2f80:	00e12623          	sw	a4,12(sp)
    2f84:	0007a403          	lw	s0,0(a5)
            if (v < 0) {
    2f88:	02044263          	bltz	s0,2fac <app_vformat+0x144>
                pos = emit_uint(out, pos, cap, (uint32_t)v, 10U, 0);
    2f8c:	00000793          	li	a5,0
    2f90:	00a00713          	li	a4,10
    2f94:	00040693          	mv	a3,s0
    2f98:	00048613          	mv	a2,s1
    2f9c:	00090513          	mv	a0,s2
    2fa0:	e05ff0ef          	jal	2da4 <emit_uint>
    2fa4:	00050593          	mv	a1,a0
    2fa8:	f59ff06f          	j	2f00 <app_vformat+0x98>
                pos = emit_char(out, pos, cap, '-');
    2fac:	02d00693          	li	a3,45
    2fb0:	00048613          	mv	a2,s1
    2fb4:	00090513          	mv	a0,s2
    2fb8:	d61ff0ef          	jal	2d18 <emit_char>
    2fbc:	00050593          	mv	a1,a0
                pos = emit_uint(out, pos, cap, (uint32_t)0 - (uint32_t)v, 10U, 0);
    2fc0:	00000793          	li	a5,0
    2fc4:	00a00713          	li	a4,10
    2fc8:	408006b3          	neg	a3,s0
    2fcc:	00048613          	mv	a2,s1
    2fd0:	00090513          	mv	a0,s2
    2fd4:	dd1ff0ef          	jal	2da4 <emit_uint>
    2fd8:	00050593          	mv	a1,a0
    2fdc:	f25ff06f          	j	2f00 <app_vformat+0x98>
            pos = emit_uint(out, pos, cap, va_arg(ap, uint32_t), 10U, 0);
    2fe0:	00c12683          	lw	a3,12(sp)
    2fe4:	00468793          	addi	a5,a3,4
    2fe8:	00f12623          	sw	a5,12(sp)
    2fec:	00000793          	li	a5,0
    2ff0:	00a00713          	li	a4,10
    2ff4:	0006a683          	lw	a3,0(a3)
    2ff8:	00048613          	mv	a2,s1
    2ffc:	00090513          	mv	a0,s2
    3000:	da5ff0ef          	jal	2da4 <emit_uint>
    3004:	00050593          	mv	a1,a0
            break;
    3008:	ef9ff06f          	j	2f00 <app_vformat+0x98>
            pos = emit_uint(out, pos, cap, va_arg(ap, uint32_t), 16U, 0);
    300c:	00c12683          	lw	a3,12(sp)
    3010:	00468793          	addi	a5,a3,4
    3014:	00f12623          	sw	a5,12(sp)
    3018:	00000793          	li	a5,0
    301c:	01000713          	li	a4,16
    3020:	0006a683          	lw	a3,0(a3)
    3024:	00048613          	mv	a2,s1
    3028:	00090513          	mv	a0,s2
    302c:	d79ff0ef          	jal	2da4 <emit_uint>
    3030:	00050593          	mv	a1,a0
            break;
    3034:	ecdff06f          	j	2f00 <app_vformat+0x98>
            pos = emit_uint(out, pos, cap, va_arg(ap, uint32_t), 16U, 1);
    3038:	00c12683          	lw	a3,12(sp)
    303c:	00468793          	addi	a5,a3,4
    3040:	00f12623          	sw	a5,12(sp)
    3044:	00100793          	li	a5,1
    3048:	01000713          	li	a4,16
    304c:	0006a683          	lw	a3,0(a3)
    3050:	00048613          	mv	a2,s1
    3054:	00090513          	mv	a0,s2
    3058:	d4dff0ef          	jal	2da4 <emit_uint>
    305c:	00050593          	mv	a1,a0
            break;
    3060:	ea1ff06f          	j	2f00 <app_vformat+0x98>
            pos = emit_str(out, pos, cap, "0x");
    3064:	000096b7          	lui	a3,0x9
    3068:	9e068693          	addi	a3,a3,-1568 # 89e0 <_data+0x4c>
    306c:	00048613          	mv	a2,s1
    3070:	00090513          	mv	a0,s2
    3074:	cc9ff0ef          	jal	2d3c <emit_str>
    3078:	00050593          	mv	a1,a0
            pos = emit_uint(out, pos, cap, (uint32_t)va_arg(ap, void *), 16U, 0);
    307c:	00c12683          	lw	a3,12(sp)
    3080:	00468793          	addi	a5,a3,4
    3084:	00f12623          	sw	a5,12(sp)
    3088:	00000793          	li	a5,0
    308c:	01000713          	li	a4,16
    3090:	0006a683          	lw	a3,0(a3)
    3094:	00048613          	mv	a2,s1
    3098:	00090513          	mv	a0,s2
    309c:	d09ff0ef          	jal	2da4 <emit_uint>
    30a0:	00050593          	mv	a1,a0
            break;
    30a4:	e5dff06f          	j	2f00 <app_vformat+0x98>
            pos = emit_char(out, pos, cap, '%');
    30a8:	02500693          	li	a3,37
    30ac:	00048613          	mv	a2,s1
    30b0:	00090513          	mv	a0,s2
    30b4:	c65ff0ef          	jal	2d18 <emit_char>
    30b8:	00050593          	mv	a1,a0
            format--;
    30bc:	00040993          	mv	s3,s0
            break;
    30c0:	e41ff06f          	j	2f00 <app_vformat+0x98>
            pos = emit_char(out, pos, cap, '%');
    30c4:	02500693          	li	a3,37
    30c8:	00048613          	mv	a2,s1
    30cc:	00090513          	mv	a0,s2
    30d0:	c49ff0ef          	jal	2d18 <emit_char>
    30d4:	00050593          	mv	a1,a0
            pos = emit_char(out, pos, cap, *format);
    30d8:	00144683          	lbu	a3,1(s0)
    30dc:	00048613          	mv	a2,s1
    30e0:	00090513          	mv	a0,s2
    30e4:	c35ff0ef          	jal	2d18 <emit_char>
    30e8:	00050593          	mv	a1,a0
            break;
    30ec:	e15ff06f          	j	2f00 <app_vformat+0x98>
    }

    /* 补上字符串结束符。
     * 这里用三元表达式做一次边界保护：如果写满到 cap，就写到最后一个字节，
     * 保证 out 始终是一个合法的、有结束符的字符串。*/
    out[(pos < cap) ? pos : (cap - 1U)] = '\0';
    30f0:	0295e863          	bltu	a1,s1,3120 <app_vformat+0x2b8>
    30f4:	fff48493          	addi	s1,s1,-1
    30f8:	00990933          	add	s2,s2,s1
    30fc:	00090023          	sb	zero,0(s2)
    return pos;
    3100:	02812403          	lw	s0,40(sp)
    3104:	02412483          	lw	s1,36(sp)
    3108:	02012903          	lw	s2,32(sp)
    310c:	01c12983          	lw	s3,28(sp)
}
    3110:	00058513          	mv	a0,a1
    3114:	02c12083          	lw	ra,44(sp)
    3118:	03010113          	addi	sp,sp,48
    311c:	00008067          	ret
    out[(pos < cap) ? pos : (cap - 1U)] = '\0';
    3120:	00058493          	mv	s1,a1
    3124:	fd5ff06f          	j	30f8 <app_vformat+0x290>
        return 0U;
    3128:	00000593          	li	a1,0
    312c:	fe5ff06f          	j	3110 <app_vformat+0x2a8>
    3130:	02812403          	lw	s0,40(sp)
    3134:	02412483          	lw	s1,36(sp)
    3138:	02012903          	lw	s2,32(sp)
    313c:	fd5ff06f          	j	3110 <app_vformat+0x2a8>
    3140:	00000593          	li	a1,0
    3144:	02812403          	lw	s0,40(sp)
    3148:	02412483          	lw	s1,36(sp)
    314c:	02012903          	lw	s2,32(sp)
    3150:	fc1ff06f          	j	3110 <app_vformat+0x2a8>

00003154 <bsp_printf>:
* @param format Format string followed by the arguments to be formatted.
* @param ... Variable arguments corresponding to the format specifiers in 'format'.
*
******************************************************************************/
    static int bsp_printf(const char* format, ...)
    {
    3154:	f6010113          	addi	sp,sp,-160
    3158:	06112e23          	sw	ra,124(sp)
    315c:	06812c23          	sw	s0,120(sp)
    3160:	08b12223          	sw	a1,132(sp)
    3164:	08c12423          	sw	a2,136(sp)
    3168:	08d12623          	sw	a3,140(sp)
    316c:	08e12823          	sw	a4,144(sp)
    3170:	08f12a23          	sw	a5,148(sp)
    3174:	09012c23          	sw	a6,152(sp)
    3178:	09112e23          	sw	a7,156(sp)
      va_list va;
      va_start(va, format);
    317c:	08410713          	addi	a4,sp,132
    3180:	06e12623          	sw	a4,108(sp)

      char buffer[MAX_STRING_BUFFER_SIZE];
        const int ret = _vsnprintf(_out_buffer, buffer, (size_t)-1, format, va);
    3184:	00050693          	mv	a3,a0
    3188:	fff00613          	li	a2,-1
    318c:	00810593          	addi	a1,sp,8
    3190:	00001537          	lui	a0,0x1
    3194:	2f450513          	addi	a0,a0,756 # 12f4 <_out_buffer>
    3198:	9a0ff0ef          	jal	2338 <_vsnprintf>
    319c:	00050413          	mv	s0,a0
        _putchar_s(buffer);
    31a0:	00810513          	addi	a0,sp,8
    31a4:	938fe0ef          	jal	12dc <_putchar_s>

      va_end(va);
      return ret;
    }
    31a8:	00040513          	mv	a0,s0
    31ac:	07c12083          	lw	ra,124(sp)
    31b0:	07812403          	lw	s0,120(sp)
    31b4:	0a010113          	addi	sp,sp,160
    31b8:	00008067          	ret

000031bc <app_log_init>:
/******************************************************************************
* @brief 清空日志环并清零计数。
******************************************************************************/
void app_log_init(void)
{
    s_head = 0U;
    31bc:	8c01a223          	sw	zero,-1852(gp) # b074 <s_head>
    s_tail = 0U;
    31c0:	8c01a023          	sw	zero,-1856(gp) # b070 <s_tail>
    s_dropped = 0U;
    31c4:	8a01ae23          	sw	zero,-1860(gp) # b06c <s_dropped>
    s_once_mask = 0U;      /* 清掉"已报过"的位，让 app_log_once 重新从首次开始 */
    31c8:	8a01ac23          	sw	zero,-1864(gp) # b068 <s_once_mask>
}
    31cc:	00008067          	ret

000031d0 <app_log_pending>:
*
* @note 与 proto_uart.c 里同样的环形缓冲技巧：无符号减法 + 掩码取模。
******************************************************************************/
uint32_t app_log_pending(void)
{
    return (s_head - s_tail) & (APP_LOG_RING_SIZE - 1U);
    31d0:	8c41a503          	lw	a0,-1852(gp) # b074 <s_head>
    31d4:	8c01a783          	lw	a5,-1856(gp) # b070 <s_tail>
    31d8:	40f50533          	sub	a0,a0,a5
}
    31dc:	3ff57513          	andi	a0,a0,1023
    31e0:	00008067          	ret

000031e4 <app_log_v>:
    char     msg[APP_LOG_MSG_MAX];
    uint32_t used;
    uint32_t i;
    uint32_t space;

    if (format == 0) {
    31e4:	0c050663          	beqz	a0,32b0 <app_log_v+0xcc>
{
    31e8:	f5010113          	addi	sp,sp,-176
    31ec:	0a112623          	sw	ra,172(sp)
    31f0:	0a812423          	sw	s0,168(sp)
    31f4:	00050613          	mv	a2,a0
    31f8:	00058693          	mv	a3,a1
        return;
    }

    used = app_vformat(msg, sizeof(msg), format, ap);
    31fc:	0a000593          	li	a1,160
    3200:	00010513          	mv	a0,sp
    3204:	c65ff0ef          	jal	2e68 <app_vformat>
    3208:	00050413          	mv	s0,a0

    /* 格式化结果为空就不必进队了。*/
    if (used == 0U) {
    320c:	00051a63          	bnez	a0,3220 <app_log_v+0x3c>
     *
     * 这里补的是**逻辑换行**（只有 '\n' 一个字节）。真正上串口需要的
     * "\r\n" 两个字节由 app_log_flush() 在发送前展开，理由见那个函数的说明。*/
    s_ring[s_head] = '\n';
    s_head = (s_head + 1U) & (APP_LOG_RING_SIZE - 1U);
}
    3210:	0ac12083          	lw	ra,172(sp)
    3214:	0a812403          	lw	s0,168(sp)
    3218:	0b010113          	addi	sp,sp,176
    321c:	00008067          	ret
    space = (APP_LOG_RING_SIZE - 1U) - app_log_pending();
    3220:	fb1ff0ef          	jal	31d0 <app_log_pending>
    3224:	3ff00793          	li	a5,1023
    3228:	40a787b3          	sub	a5,a5,a0
    if ((used + 1U) > space) {
    322c:	00140713          	addi	a4,s0,1
    3230:	00e7e663          	bltu	a5,a4,323c <app_log_v+0x58>
    for (i = 0U; i < used; i++) {
    3234:	00000713          	li	a4,0
    3238:	0480006f          	j	3280 <app_log_v+0x9c>
        s_dropped++;           /* 放不下整条，丢掉并计数 */
    323c:	8bc1a783          	lw	a5,-1860(gp) # b06c <s_dropped>
    3240:	00178793          	addi	a5,a5,1
    3244:	8af1ae23          	sw	a5,-1860(gp) # b06c <s_dropped>
        return;
    3248:	fc9ff06f          	j	3210 <app_log_v+0x2c>
        s_ring[s_head] = msg[i];
    324c:	8c41a583          	lw	a1,-1852(gp) # b074 <s_head>
    3250:	0a070793          	addi	a5,a4,160
    3254:	002787b3          	add	a5,a5,sp
    3258:	f607c603          	lbu	a2,-160(a5)
    325c:	0000b7b7          	lui	a5,0xb
    3260:	10478793          	addi	a5,a5,260 # b104 <s_ring>
    3264:	00b787b3          	add	a5,a5,a1
    3268:	00c78023          	sb	a2,0(a5)
        s_head = (s_head + 1U) & (APP_LOG_RING_SIZE - 1U);
    326c:	8c41a783          	lw	a5,-1852(gp) # b074 <s_head>
    3270:	00178793          	addi	a5,a5,1
    3274:	3ff7f793          	andi	a5,a5,1023
    3278:	8cf1a223          	sw	a5,-1852(gp) # b074 <s_head>
    for (i = 0U; i < used; i++) {
    327c:	00170713          	addi	a4,a4,1
    3280:	fc8766e3          	bltu	a4,s0,324c <app_log_v+0x68>
    s_ring[s_head] = '\n';
    3284:	8c41a683          	lw	a3,-1852(gp) # b074 <s_head>
    3288:	0000b7b7          	lui	a5,0xb
    328c:	10478793          	addi	a5,a5,260 # b104 <s_ring>
    3290:	00d787b3          	add	a5,a5,a3
    3294:	00a00693          	li	a3,10
    3298:	00d78023          	sb	a3,0(a5)
    s_head = (s_head + 1U) & (APP_LOG_RING_SIZE - 1U);
    329c:	8c41a783          	lw	a5,-1852(gp) # b074 <s_head>
    32a0:	00178793          	addi	a5,a5,1
    32a4:	3ff7f793          	andi	a5,a5,1023
    32a8:	8cf1a223          	sw	a5,-1852(gp) # b074 <s_head>
    32ac:	f65ff06f          	j	3210 <app_log_v+0x2c>
    32b0:	00008067          	ret

000032b4 <app_log_dropped>:
}
    32b4:	8bc1a503          	lw	a0,-1860(gp) # b06c <s_dropped>
    32b8:	00008067          	ret

000032bc <app_log>:
* @brief 格式化一条消息并排进队列。
*
* @param format 格式串，后面跟可变参数。
******************************************************************************/
void app_log(const char *format, ...)
{
    32bc:	fc010113          	addi	sp,sp,-64
    32c0:	00112e23          	sw	ra,28(sp)
    32c4:	02b12223          	sw	a1,36(sp)
    32c8:	02c12423          	sw	a2,40(sp)
    32cc:	02d12623          	sw	a3,44(sp)
    32d0:	02e12823          	sw	a4,48(sp)
    32d4:	02f12a23          	sw	a5,52(sp)
    32d8:	03012c23          	sw	a6,56(sp)
    32dc:	03112e23          	sw	a7,60(sp)
    va_list ap;

    va_start(ap, format);
    32e0:	02410593          	addi	a1,sp,36
    32e4:	00b12623          	sw	a1,12(sp)
    app_log_v(format, ap);
    32e8:	efdff0ef          	jal	31e4 <app_log_v>
    va_end(ap);
}
    32ec:	01c12083          	lw	ra,28(sp)
    32f0:	04010113          	addi	sp,sp,64
    32f4:	00008067          	ret

000032f8 <app_log_once>:
* @note bitno MUST 小于 32。C 语言里 `1U << 32` 是**未定义行为**（不是简单
*       地得到 0），可能把其它位搅乱。这里显式挡住，因为 bitno 常直接来自枚举，
*       将来给枚举加值时就可能越界，而那种 bug 极难查。
******************************************************************************/
void app_log_once(uint32_t bitno, const char *format, ...)
{
    32f8:	fc010113          	addi	sp,sp,-64
    32fc:	00112e23          	sw	ra,28(sp)
    3300:	00050313          	mv	t1,a0
    3304:	02c12423          	sw	a2,40(sp)
    3308:	02d12623          	sw	a3,44(sp)
    330c:	02e12823          	sw	a4,48(sp)
    3310:	02f12a23          	sw	a5,52(sp)
    3314:	03012c23          	sw	a6,56(sp)
    3318:	03112e23          	sw	a7,60(sp)
    va_list ap;

    if (bitno >= 32U) {
    331c:	01f00793          	li	a5,31
    3320:	00a7ee63          	bltu	a5,a0,333c <app_log_once+0x44>
    3324:	00058513          	mv	a0,a1
        return;                    /* 越界：宁可不输出，也不能移位越界 */
    }
    if ((s_once_mask & (1U << bitno)) != 0U) {
    3328:	00100793          	li	a5,1
    332c:	006797b3          	sll	a5,a5,t1
    3330:	8b81a703          	lw	a4,-1864(gp) # b068 <s_once_mask>
    3334:	00e7f6b3          	and	a3,a5,a4
    3338:	00068863          	beqz	a3,3348 <app_log_once+0x50>
    s_once_mask |= (1U << bitno);

    va_start(ap, format);
    app_log_v(format, ap);
    va_end(ap);
}
    333c:	01c12083          	lw	ra,28(sp)
    3340:	04010113          	addi	sp,sp,64
    3344:	00008067          	ret
    s_once_mask |= (1U << bitno);
    3348:	00e7e7b3          	or	a5,a5,a4
    334c:	8af1ac23          	sw	a5,-1864(gp) # b068 <s_once_mask>
    va_start(ap, format);
    3350:	02810593          	addi	a1,sp,40
    3354:	00b12623          	sw	a1,12(sp)
    app_log_v(format, ap);
    3358:	e8dff0ef          	jal	31e4 <app_log_v>
    va_end(ap);
    335c:	fe1ff06f          	j	333c <app_log_once+0x44>

00003360 <app_log_flush>:
* @note 末尾多留一个字节给 '\0'（s_emit 定义为 CHUNK+1 大小），
*       s_emit[out] = '\0' 就是补结束符——这一句不能省，否则打印函数会越过
*       有效内容继续往后读。
******************************************************************************/
uint32_t app_log_flush(void)
{
    3360:	ff010113          	addi	sp,sp,-16
    3364:	00112623          	sw	ra,12(sp)
    3368:	00812423          	sw	s0,8(sp)
    /* pending 在循环开始前取一次就够了：本函数是环的唯一消费者，
     * 循环里 s_tail 只会往前走，所以 pending 就是"这次最多能取多少"。*/
    uint32_t pending = app_log_pending();
    336c:	e65ff0ef          	jal	31d0 <app_log_pending>
    uint32_t consumed = 0U;     /* 已从环里取走的源字节数 */
    uint32_t out = 0U;          /* 已写入 s_emit 的输出字节数 */
    char     c;

    if (pending == 0U) {
    3370:	0a050a63          	beqz	a0,3424 <app_log_flush+0xc4>
    uint32_t out = 0U;          /* 已写入 s_emit 的输出字节数 */
    3374:	00000413          	li	s0,0
    uint32_t consumed = 0U;     /* 已从环里取走的源字节数 */
    3378:	00000713          	li	a4,0
    337c:	0480006f          	j	33c4 <app_log_flush+0x64>
             * 后半条日志会覆盖在当前行上；只发 '\n' 又会阶梯错位。
             * 要么整对发出，要么一个都不发。
             *
             * 注：APP_LOG_CHUNK 为 32，所以 out==0 时这个条件必然不成立，
             * 不会出现"一个字节都取不出来"的死循环。*/
            if ((out + 2U) > APP_LOG_CHUNK) {
    3380:	00240693          	addi	a3,s0,2
    3384:	02000793          	li	a5,32
    3388:	06d7ec63          	bltu	a5,a3,3400 <app_log_flush+0xa0>
                break;
            }
            s_emit[out] = '\r';     /* 先回车 */
    338c:	93018793          	addi	a5,gp,-1744 # b0e0 <s_emit>
    3390:	00878633          	add	a2,a5,s0
    3394:	00d00593          	li	a1,13
    3398:	00b60023          	sb	a1,0(a2)
            out++;
    339c:	00140413          	addi	s0,s0,1
            s_emit[out] = '\n';     /* 再换行 */
    33a0:	008787b3          	add	a5,a5,s0
    33a4:	00a00613          	li	a2,10
    33a8:	00c78023          	sb	a2,0(a5)
            out++;
    33ac:	00068413          	mv	s0,a3
            s_emit[out] = c;
            out++;
        }

        /* 到这里这个源字节才算真正被消费掉，推进读指针。*/
        s_tail = (s_tail + 1U) & (APP_LOG_RING_SIZE - 1U);
    33b0:	8c01a783          	lw	a5,-1856(gp) # b070 <s_tail>
    33b4:	00178793          	addi	a5,a5,1
    33b8:	3ff7f793          	andi	a5,a5,1023
    33bc:	8cf1a023          	sw	a5,-1856(gp) # b070 <s_tail>
        consumed++;
    33c0:	00170713          	addi	a4,a4,1
    while ((consumed < pending) && (out < APP_LOG_CHUNK)) {
    33c4:	02a77e63          	bgeu	a4,a0,3400 <app_log_flush+0xa0>
    33c8:	01f00793          	li	a5,31
    33cc:	0287ea63          	bltu	a5,s0,3400 <app_log_flush+0xa0>
        c = s_ring[s_tail];
    33d0:	8c01a683          	lw	a3,-1856(gp) # b070 <s_tail>
    33d4:	0000b7b7          	lui	a5,0xb
    33d8:	10478793          	addi	a5,a5,260 # b104 <s_ring>
    33dc:	00d787b3          	add	a5,a5,a3
    33e0:	0007c683          	lbu	a3,0(a5)
        if (c == '\n') {
    33e4:	00a00793          	li	a5,10
    33e8:	f8f68ce3          	beq	a3,a5,3380 <app_log_flush+0x20>
            s_emit[out] = c;
    33ec:	93018793          	addi	a5,gp,-1744 # b0e0 <s_emit>
    33f0:	008787b3          	add	a5,a5,s0
    33f4:	00d78023          	sb	a3,0(a5)
            out++;
    33f8:	00140413          	addi	s0,s0,1
    33fc:	fb5ff06f          	j	33b0 <app_log_flush+0x50>
    }

    /* 一个字节都没能发出（理论上只在 APP_LOG_CHUNK < 2 时才会发生），
     * 那就不要调打印函数，避免发一个空字符串白白停顿一次。*/
    if (out == 0U) {
    3400:	02040463          	beqz	s0,3428 <app_log_flush+0xc8>
        return 0U;
    }

    s_emit[out] = '\0';
    3404:	93018793          	addi	a5,gp,-1744 # b0e0 <s_emit>
    3408:	008787b3          	add	a5,a5,s0
    340c:	00078023          	sb	zero,0(a5)

    /* 唯一的硬件调用点。这一句会让 CPU 停顿若干时间（见 app_log.h），
     * 所以它被放在主循环里、在服务完 uart1 之后。*/
    bsp_printf("%s", s_emit);
    3410:	93018593          	addi	a1,gp,-1744 # b0e0 <s_emit>
    3414:	00009537          	lui	a0,0x9
    3418:	bac50513          	addi	a0,a0,-1108 # 8bac <_data+0x218>
    341c:	d39ff0ef          	jal	3154 <bsp_printf>

    return out;
    3420:	0080006f          	j	3428 <app_log_flush+0xc8>
        return 0U;              /* 没东西可发，不碰硬件 */
    3424:	00050413          	mv	s0,a0
}
    3428:	00040513          	mv	a0,s0
    342c:	00c12083          	lw	ra,12(sp)
    3430:	00812403          	lw	s0,8(sp)
    3434:	01010113          	addi	sp,sp,16
    3438:	00008067          	ret

0000343c <uart_applyConfig>:
*          value using data length, parity, and stop bit settings from the configuration
*          structure, and writes this value to the UART frame configuration register.
*
******************************************************************************/
    static void uart_applyConfig(u32 reg, Uart_Config *config){
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
    343c:	00c5a783          	lw	a5,12(a1)
    static inline u32 read_u32(u32 address){
        return *((volatile u32*) address);
    }
    
    static inline void write_u32(u32 data, u32 address){
        *((volatile u32*) address) = data;
    3440:	00f52423          	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
    3444:	0005a783          	lw	a5,0(a1)
    3448:	fff78793          	addi	a5,a5,-1
    344c:	0045a703          	lw	a4,4(a1)
    3450:	00871713          	slli	a4,a4,0x8
    3454:	00e7e7b3          	or	a5,a5,a4
    3458:	0085a703          	lw	a4,8(a1)
    345c:	01071713          	slli	a4,a4,0x10
    3460:	00e7e7b3          	or	a5,a5,a4
    3464:	00f52623          	sw	a5,12(a0)
    }
    3468:	00008067          	ret

0000346c <clint_getTime>:
*          to guard against rollover. It checks if the high part remains unchanged
*          during the read operation to ensure consistency. The high and low parts
*          are then combined to form the 64-bit current time value.
*
******************************************************************************/
    static u64 clint_getTime(u32 p){
    346c:	00050693          	mv	a3,a0
    readReg_u32 (clint_getTimeHigh, CLINT_TIME_ADDR+4)
    3470:	0000c7b7          	lui	a5,0xc
    3474:	ffc78793          	addi	a5,a5,-4 # bffc <__global_pointer$+0x84c>
    3478:	00f687b3          	add	a5,a3,a5
        return *((volatile u32*) address);
    347c:	0007a583          	lw	a1,0(a5)
    readReg_u32 (clint_getTimeLow , CLINT_TIME_ADDR)
    3480:	0000c737          	lui	a4,0xc
    3484:	ff870713          	addi	a4,a4,-8 # bff8 <__global_pointer$+0x848>
    3488:	00e68733          	add	a4,a3,a4
    348c:	00072503          	lw	a0,0(a4)
    3490:	0007a783          	lw	a5,0(a5)
    
        /* Likewise, must guard against rollover when reading */
        do {
            hi = clint_getTimeHigh(p);
            lo = clint_getTimeLow(p);
        } while (clint_getTimeHigh(p) != hi);
    3494:	fcb79ee3          	bne	a5,a1,3470 <clint_getTime+0x4>
    
        return (((u64)hi) << 32) | lo;
    }
    3498:	00008067          	ret

0000349c <bsp_init>:
    *   1. UART baudrate
    *   2. 
    */
////////////////////////////////////////////////////////////////////////////////
    static void bsp_init()
    {
    349c:	fe010113          	addi	sp,sp,-32
    34a0:	00112e23          	sw	ra,28(sp)
        Uart_Config uartConfig;
        uartConfig.dataLength   = BITS_8;
    34a4:	00800793          	li	a5,8
    34a8:	00f12023          	sw	a5,0(sp)
        uartConfig.parity       = NONE;
    34ac:	00012223          	sw	zero,4(sp)
        uartConfig.stop         = ONE;
    34b0:	00012423          	sw	zero,8(sp)
        uartConfig.clockDivider = BSP_CLINT_HZ/(BSP_UART_BAUDRATE*BSP_UART_DATA_LEN)-1;
    34b4:	03500793          	li	a5,53
    34b8:	00f12623          	sw	a5,12(sp)
        uart_applyConfig(BSP_UART_TERMINAL, &uartConfig);    
    34bc:	00010593          	mv	a1,sp
    34c0:	f8001537          	lui	a0,0xf8001
    34c4:	f79ff0ef          	jal	343c <uart_applyConfig>
    }
    34c8:	01c12083          	lw	ra,28(sp)
    34cc:	02010113          	addi	sp,sp,32
    34d0:	00008067          	ret

000034d4 <plic_claim>:
*          value from the calculated address, effectively claiming an interrupt
*          for the specified target in the PLIC.
*
******************************************************************************/
    static u32 plic_claim(u32 plic, u32 target){
        return read_u32(plic + PLIC_CLAIM_BASE + target*PLIC_CONTEXT_PER_HART);
    34d4:	00c59593          	slli	a1,a1,0xc
    34d8:	00a585b3          	add	a1,a1,a0
    34dc:	002007b7          	lui	a5,0x200
    34e0:	00478793          	addi	a5,a5,4 # 200004 <__freertos_irq_stack_top+0x1efe04>
    34e4:	00f585b3          	add	a1,a1,a5
    34e8:	0005a503          	lw	a0,0(a1)
    }
    34ec:	00008067          	ret

000034f0 <plic_release>:
*          to the calculated address, effectively releasing the claimed interrupt
*          for the specified target in the PLIC.
*
******************************************************************************/
    static void plic_release(u32 plic, u32 target, u32 gateway){
        write_u32(gateway,plic + PLIC_CLAIM_BASE + target*PLIC_CONTEXT_PER_HART);
    34f0:	00c59593          	slli	a1,a1,0xc
    34f4:	00a585b3          	add	a1,a1,a0
    34f8:	002007b7          	lui	a5,0x200
    34fc:	00478793          	addi	a5,a5,4 # 200004 <__freertos_irq_stack_top+0x1efe04>
    3500:	00f585b3          	add	a1,a1,a5
        *((volatile u32*) address) = data;
    3504:	00c5a023          	sw	a2,0(a1)
    }
    3508:	00008067          	ret

0000350c <isr_init>:
    csr_write(mtvec, trap_entry);        /* 异常/中断入口，定义在 ../common/trap.S */
    350c:	000067b7          	lui	a5,0x6
    3510:	a1c78793          	addi	a5,a5,-1508 # 5a1c <trap_entry>
    3514:	30579073          	csrw	mtvec,a5
    csr_set(mie, MIE_MEIE);
    3518:	000017b7          	lui	a5,0x1
    351c:	80078793          	addi	a5,a5,-2048 # 800 <CUSTOM2+0x7a5>
    3520:	3047a073          	csrs	mie,a5
    csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);
    3524:	300027f3          	csrr	a5,mstatus
    3528:	00002737          	lui	a4,0x2
    352c:	80870713          	addi	a4,a4,-2040 # 1808 <_ntoa_long_long+0x128>
    3530:	00e7e7b3          	or	a5,a5,a4
    3534:	30079073          	csrw	mstatus,a5
}
    3538:	00008067          	ret

0000353c <hex8>:
    for (i = 0; i < 8; i++) {
    353c:	00000693          	li	a3,0
    3540:	0340006f          	j	3574 <hex8+0x38>
        dst[i] = digits[(v >> ((7 - i) * 4)) & 0xFU];
    3544:	00700793          	li	a5,7
    3548:	40d787b3          	sub	a5,a5,a3
    354c:	00279793          	slli	a5,a5,0x2
    3550:	00f5d7b3          	srl	a5,a1,a5
    3554:	00f7f793          	andi	a5,a5,15
    3558:	00d50633          	add	a2,a0,a3
    355c:	00009737          	lui	a4,0x9
    3560:	58470713          	addi	a4,a4,1412 # 9584 <digits.1>
    3564:	00f707b3          	add	a5,a4,a5
    3568:	0007c783          	lbu	a5,0(a5)
    356c:	00f60023          	sb	a5,0(a2)
    for (i = 0; i < 8; i++) {
    3570:	00168693          	addi	a3,a3,1
    3574:	00700793          	li	a5,7
    3578:	fcd7d6e3          	bge	a5,a3,3544 <hex8+0x8>
    dst[8] = '\0';
    357c:	00050423          	sb	zero,8(a0) # f8001008 <__freertos_irq_stack_top+0xf7ff0e08>
}
    3580:	00008067          	ret

00003584 <diag_drain>:
{
    3584:	ff010113          	addi	sp,sp,-16
    3588:	00112623          	sw	ra,12(sp)
    while (app_log_pending() != 0U) {
    358c:	0080006f          	j	3594 <diag_drain+0x10>
        (void)app_log_flush();
    3590:	dd1ff0ef          	jal	3360 <app_log_flush>
    while (app_log_pending() != 0U) {
    3594:	c3dff0ef          	jal	31d0 <app_log_pending>
    3598:	fe051ce3          	bnez	a0,3590 <diag_drain+0xc>
}
    359c:	00c12083          	lw	ra,12(sp)
    35a0:	01010113          	addi	sp,sp,16
    35a4:	00008067          	ret

000035a8 <diag_dump_regs>:
{
    35a8:	fb010113          	addi	sp,sp,-80
    35ac:	04112623          	sw	ra,76(sp)
    35b0:	04812423          	sw	s0,72(sp)
    canvas_read_regs(&r);
    35b4:	02010513          	addi	a0,sp,32
    35b8:	69c010ef          	jal	4c54 <canvas_read_regs>
    hex8(b1, r.command);
    35bc:	02012583          	lw	a1,32(sp)
    35c0:	01410513          	addi	a0,sp,20
    35c4:	f79ff0ef          	jal	353c <hex8>
    app_log("osd regs: COMMAND(readback)=%s staged_g_en=%u", b1, r.command & 1U);
    35c8:	02012603          	lw	a2,32(sp)
    35cc:	00167613          	andi	a2,a2,1
    35d0:	01410593          	addi	a1,sp,20
    35d4:	00009537          	lui	a0,0x9
    35d8:	9e450513          	addi	a0,a0,-1564 # 89e4 <_data+0x50>
    35dc:	ce1ff0ef          	jal	32bc <app_log>
    diag_drain();
    35e0:	fa5ff0ef          	jal	3584 <diag_drain>
    hex8(b1, r.status);
    35e4:	02412583          	lw	a1,36(sp)
    35e8:	01410513          	addi	a0,sp,20
    35ec:	f51ff0ef          	jal	353c <hex8>
            b1, (r.status >> 16) & 0xFFFFU, (r.status >> 2) & 1U, r.status & 1U);
    35f0:	02412603          	lw	a2,36(sp)
    35f4:	00265693          	srli	a3,a2,0x2
    app_log("osd regs: STATUS=%s commit_count=%u pending=%u applied_g_en=%u",
    35f8:	00167713          	andi	a4,a2,1
    35fc:	0016f693          	andi	a3,a3,1
    3600:	01065613          	srli	a2,a2,0x10
    3604:	01410593          	addi	a1,sp,20
    3608:	00009537          	lui	a0,0x9
    360c:	a1450513          	addi	a0,a0,-1516 # 8a14 <_data+0x80>
    3610:	cadff0ef          	jal	32bc <app_log>
    diag_drain();
    3614:	f71ff0ef          	jal	3584 <diag_drain>
    hex8(b1, r.canvas);
    3618:	02812583          	lw	a1,40(sp)
    361c:	01410513          	addi	a0,sp,20
    3620:	f1dff0ef          	jal	353c <hex8>
    app_log("osd regs: CANVAS=%s", b1);
    3624:	01410593          	addi	a1,sp,20
    3628:	00009537          	lui	a0,0x9
    362c:	a5450513          	addi	a0,a0,-1452 # 8a54 <_data+0xc0>
    3630:	c8dff0ef          	jal	32bc <app_log>
    diag_drain();
    3634:	f51ff0ef          	jal	3584 <diag_drain>
    hex8(b1, r.active);
    3638:	02c12583          	lw	a1,44(sp)
    363c:	01410513          	addi	a0,sp,20
    3640:	efdff0ef          	jal	353c <hex8>
    app_log("osd regs: ACTIVE=%s", b1);
    3644:	01410593          	addi	a1,sp,20
    3648:	00009537          	lui	a0,0x9
    364c:	a6850513          	addi	a0,a0,-1432 # 8a68 <_data+0xd4>
    3650:	c6dff0ef          	jal	32bc <app_log>
    diag_drain();
    3654:	f31ff0ef          	jal	3584 <diag_drain>
    for (i = 0; i < 4; i++) {
    3658:	00000413          	li	s0,0
    365c:	01c0006f          	j	3678 <diag_dump_regs+0xd0>
        app_log("osd route%d: enable=%u buffer=%c",
    3660:	04100693          	li	a3,65
    3664:	00009537          	lui	a0,0x9
    3668:	a7c50513          	addi	a0,a0,-1412 # 8a7c <_data+0xe8>
    366c:	c51ff0ef          	jal	32bc <app_log>
        diag_drain();
    3670:	f15ff0ef          	jal	3584 <diag_drain>
    for (i = 0; i < 4; i++) {
    3674:	00140413          	addi	s0,s0,1
    3678:	00300793          	li	a5,3
    367c:	0287c663          	blt	a5,s0,36a8 <diag_dump_regs+0x100>
        app_log("osd route%d: enable=%u buffer=%c",
    3680:	00040593          	mv	a1,s0
                (r.active >> (4 + i)) & 1U,
    3684:	02c12783          	lw	a5,44(sp)
    3688:	00440613          	addi	a2,s0,4
    368c:	00c7d633          	srl	a2,a5,a2
        app_log("osd route%d: enable=%u buffer=%c",
    3690:	00167613          	andi	a2,a2,1
                ((r.active >> i) & 1U) ? 'B' : 'A');
    3694:	0087d7b3          	srl	a5,a5,s0
    3698:	0017f793          	andi	a5,a5,1
        app_log("osd route%d: enable=%u buffer=%c",
    369c:	fc0782e3          	beqz	a5,3660 <diag_dump_regs+0xb8>
    36a0:	04200693          	li	a3,66
    36a4:	fc1ff06f          	j	3664 <diag_dump_regs+0xbc>
    hex8(b1, r.pos_last);
    36a8:	03812583          	lw	a1,56(sp)
    36ac:	01410513          	addi	a0,sp,20
    36b0:	e8dff0ef          	jal	353c <hex8>
    hex8(b2, r.pos_read);
    36b4:	03012583          	lw	a1,48(sp)
    36b8:	00810513          	addi	a0,sp,8
    36bc:	e81ff0ef          	jal	353c <hex8>
    app_log("osd route1 POS: last_written=%s readback=%s (W-only)", b1, b2);
    36c0:	00810613          	addi	a2,sp,8
    36c4:	01410593          	addi	a1,sp,20
    36c8:	00009537          	lui	a0,0x9
    36cc:	aa050513          	addi	a0,a0,-1376 # 8aa0 <_data+0x10c>
    36d0:	bedff0ef          	jal	32bc <app_log>
    diag_drain();
    36d4:	eb1ff0ef          	jal	3584 <diag_drain>
    hex8(b1, r.ctrl_last);
    36d8:	03c12583          	lw	a1,60(sp)
    36dc:	01410513          	addi	a0,sp,20
    36e0:	e5dff0ef          	jal	353c <hex8>
    hex8(b2, r.ctrl_read);
    36e4:	03412583          	lw	a1,52(sp)
    36e8:	00810513          	addi	a0,sp,8
    36ec:	e51ff0ef          	jal	353c <hex8>
    app_log("osd route1 CTRL: last_written=%s readback=%s (W-only)", b1, b2);
    36f0:	00810613          	addi	a2,sp,8
    36f4:	01410593          	addi	a1,sp,20
    36f8:	00009537          	lui	a0,0x9
    36fc:	ad850513          	addi	a0,a0,-1320 # 8ad8 <_data+0x144>
    3700:	bbdff0ef          	jal	32bc <app_log>
    diag_drain();
    3704:	e81ff0ef          	jal	3584 <diag_drain>
}
    3708:	04c12083          	lw	ra,76(sp)
    370c:	04812403          	lw	s0,72(sp)
    3710:	05010113          	addi	sp,sp,80
    3714:	00008067          	ret

00003718 <diag_probe_sticky>:
{
    3718:	fc010113          	addi	sp,sp,-64
    371c:	02112e23          	sw	ra,60(sp)
    hex8(b1, canvas_peek(s_probe_in_bitmap));
    3720:	8cc1a503          	lw	a0,-1844(gp) # b07c <s_probe_in_bitmap>
    3724:	660010ef          	jal	4d84 <canvas_peek>
    3728:	00050593          	mv	a1,a0
    372c:	02410513          	addi	a0,sp,36
    3730:	e0dff0ef          	jal	353c <hex8>
    hex8(b2, canvas_peek(s_probe_out_bitmap));
    3734:	8c81a503          	lw	a0,-1848(gp) # b078 <s_probe_out_bitmap>
    3738:	64c010ef          	jal	4d84 <canvas_peek>
    373c:	00050593          	mv	a1,a0
    3740:	01810513          	addi	a0,sp,24
    3744:	df9ff0ef          	jal	353c <hex8>
    hex8(b3, s_probe_value);
    3748:	5a5aa5b7          	lui	a1,0x5a5aa
    374c:	5a558593          	addi	a1,a1,1445 # 5a5aa5a5 <__freertos_irq_stack_top+0x5a59a3a5>
    3750:	00c10513          	addi	a0,sp,12
    3754:	de9ff0ef          	jal	353c <hex8>
    app_log("osd probe: sticky in-bitmap=%s out-bitmap=%s (wrote %s)", b1, b2, b3);
    3758:	00c10693          	addi	a3,sp,12
    375c:	01810613          	addi	a2,sp,24
    3760:	02410593          	addi	a1,sp,36
    3764:	00009537          	lui	a0,0x9
    3768:	b1050513          	addi	a0,a0,-1264 # 8b10 <_data+0x17c>
    376c:	b51ff0ef          	jal	32bc <app_log>
    diag_drain();
    3770:	e15ff0ef          	jal	3584 <diag_drain>
}
    3774:	03c12083          	lw	ra,60(sp)
    3778:	04010113          	addi	sp,sp,64
    377c:	00008067          	ret

00003780 <diag_probe_memory>:
{
    3780:	fd010113          	addi	sp,sp,-48
    3784:	02112623          	sw	ra,44(sp)
    3788:	02812423          	sw	s0,40(sp)
    378c:	02912223          	sw	s1,36(sp)
    hex8(b1, canvas_bytes_written());
    3790:	608010ef          	jal	4d98 <canvas_bytes_written>
    3794:	00050593          	mv	a1,a0
    3798:	01410513          	addi	a0,sp,20
    379c:	da1ff0ef          	jal	353c <hex8>
    app_log("osd probe: bytes_written(total)=%s", b1);
    37a0:	01410593          	addi	a1,sp,20
    37a4:	00009537          	lui	a0,0x9
    37a8:	b5c50513          	addi	a0,a0,-1188 # 8b5c <_data+0x1c8>
    37ac:	b11ff0ef          	jal	32bc <app_log>
    diag_drain();
    37b0:	dd5ff0ef          	jal	3584 <diag_drain>
    for (i = 0; i < 4; i++) {
    37b4:	00000413          	li	s0,0
    37b8:	0540006f          	j	380c <diag_probe_memory+0x8c>
        hex8(b1, peek_addr[i]);
    37bc:	000097b7          	lui	a5,0x9
    37c0:	00241713          	slli	a4,s0,0x2
    37c4:	57478793          	addi	a5,a5,1396 # 9574 <peek_addr.0>
    37c8:	00e787b3          	add	a5,a5,a4
    37cc:	0007a483          	lw	s1,0(a5)
    37d0:	00048593          	mv	a1,s1
    37d4:	01410513          	addi	a0,sp,20
    37d8:	d65ff0ef          	jal	353c <hex8>
        hex8(b2, canvas_peek(peek_addr[i]));
    37dc:	00048513          	mv	a0,s1
    37e0:	5a4010ef          	jal	4d84 <canvas_peek>
    37e4:	00050593          	mv	a1,a0
    37e8:	00810513          	addi	a0,sp,8
    37ec:	d51ff0ef          	jal	353c <hex8>
        app_log("osd probe: rd %s = %s", b1, b2);
    37f0:	00810613          	addi	a2,sp,8
    37f4:	01410593          	addi	a1,sp,20
    37f8:	00009537          	lui	a0,0x9
    37fc:	b8050513          	addi	a0,a0,-1152 # 8b80 <_data+0x1ec>
    3800:	abdff0ef          	jal	32bc <app_log>
        diag_drain();
    3804:	d81ff0ef          	jal	3584 <diag_drain>
    for (i = 0; i < 4; i++) {
    3808:	00140413          	addi	s0,s0,1
    380c:	00300793          	li	a5,3
    3810:	fa87d6e3          	bge	a5,s0,37bc <diag_probe_memory+0x3c>
    got = canvas_poke(probe_addr, pattern);
    3814:	a5c365b7          	lui	a1,0xa5c36
    3818:	a3c58593          	addi	a1,a1,-1476 # a5c35a3c <__freertos_irq_stack_top+0xa5c2583c>
    381c:	00a60537          	lui	a0,0xa60
    3820:	56c010ef          	jal	4d8c <canvas_poke>
    3824:	00050413          	mv	s0,a0
    hex8(b1, probe_addr);
    3828:	00a605b7          	lui	a1,0xa60
    382c:	01410513          	addi	a0,sp,20
    3830:	d0dff0ef          	jal	353c <hex8>
    hex8(b2, pattern);
    3834:	a5c365b7          	lui	a1,0xa5c36
    3838:	a3c58593          	addi	a1,a1,-1476 # a5c35a3c <__freertos_irq_stack_top+0xa5c2583c>
    383c:	00810513          	addi	a0,sp,8
    3840:	cfdff0ef          	jal	353c <hex8>
    app_log("osd probe: wr %s <- %s", b1, b2);
    3844:	00810613          	addi	a2,sp,8
    3848:	01410593          	addi	a1,sp,20
    384c:	00009537          	lui	a0,0x9
    3850:	b9850513          	addi	a0,a0,-1128 # 8b98 <_data+0x204>
    3854:	a69ff0ef          	jal	32bc <app_log>
    diag_drain();
    3858:	d2dff0ef          	jal	3584 <diag_drain>
    hex8(b1, got);
    385c:	00040593          	mv	a1,s0
    3860:	01410513          	addi	a0,sp,20
    3864:	cd9ff0ef          	jal	353c <hex8>
    hex8(b2, pattern);
    3868:	a5c365b7          	lui	a1,0xa5c36
    386c:	a3c58593          	addi	a1,a1,-1476 # a5c35a3c <__freertos_irq_stack_top+0xa5c2583c>
    3870:	00810513          	addi	a0,sp,8
    3874:	cc9ff0ef          	jal	353c <hex8>
    app_log("osd probe: read back %s %s", b1,
    3878:	a5c367b7          	lui	a5,0xa5c36
    387c:	a3c78793          	addi	a5,a5,-1476 # a5c35a3c <__freertos_irq_stack_top+0xa5c2583c>
    3880:	0af40663          	beq	s0,a5,392c <diag_probe_memory+0x1ac>
    3884:	00009637          	lui	a2,0x9
    3888:	b5060613          	addi	a2,a2,-1200 # 8b50 <_data+0x1bc>
    388c:	01410593          	addi	a1,sp,20
    3890:	00009537          	lui	a0,0x9
    3894:	bb050513          	addi	a0,a0,-1104 # 8bb0 <_data+0x21c>
    3898:	a25ff0ef          	jal	32bc <app_log>
    diag_drain();
    389c:	ce9ff0ef          	jal	3584 <diag_drain>
    s_probe_out_bitmap = probe_addr;
    38a0:	00a60737          	lui	a4,0xa60
    38a4:	8ce1a423          	sw	a4,-1848(gp) # b078 <s_probe_out_bitmap>
    s_probe_in_bitmap  = 0x00A40000u + 0x100u;
    38a8:	00a40537          	lui	a0,0xa40
    38ac:	10050513          	addi	a0,a0,256 # a40100 <__freertos_irq_stack_top+0xa2ff00>
    38b0:	8ca1a623          	sw	a0,-1844(gp) # b07c <s_probe_in_bitmap>
    got = canvas_poke(s_probe_in_bitmap, s_probe_value);
    38b4:	5a5aa5b7          	lui	a1,0x5a5aa
    38b8:	5a558593          	addi	a1,a1,1445 # 5a5aa5a5 <__freertos_irq_stack_top+0x5a59a3a5>
    38bc:	4d0010ef          	jal	4d8c <canvas_poke>
    38c0:	00050413          	mv	s0,a0
    hex8(b1, s_probe_in_bitmap);
    38c4:	8cc1a583          	lw	a1,-1844(gp) # b07c <s_probe_in_bitmap>
    38c8:	01410513          	addi	a0,sp,20
    38cc:	c71ff0ef          	jal	353c <hex8>
    hex8(b2, s_probe_value);
    38d0:	5a5aa5b7          	lui	a1,0x5a5aa
    38d4:	5a558593          	addi	a1,a1,1445 # 5a5aa5a5 <__freertos_irq_stack_top+0x5a59a3a5>
    38d8:	00810513          	addi	a0,sp,8
    38dc:	c61ff0ef          	jal	353c <hex8>
    app_log("osd probe: [in-bitmap] wr %s <- %s", b1, b2);
    38e0:	00810613          	addi	a2,sp,8
    38e4:	01410593          	addi	a1,sp,20
    38e8:	00009537          	lui	a0,0x9
    38ec:	bcc50513          	addi	a0,a0,-1076 # 8bcc <_data+0x238>
    38f0:	9cdff0ef          	jal	32bc <app_log>
    diag_drain();
    38f4:	c91ff0ef          	jal	3584 <diag_drain>
    hex8(b1, got);
    38f8:	00040593          	mv	a1,s0
    38fc:	01410513          	addi	a0,sp,20
    3900:	c3dff0ef          	jal	353c <hex8>
    app_log("osd probe: [in-bitmap] read back now = %s", b1);
    3904:	01410593          	addi	a1,sp,20
    3908:	00009537          	lui	a0,0x9
    390c:	bf050513          	addi	a0,a0,-1040 # 8bf0 <_data+0x25c>
    3910:	9adff0ef          	jal	32bc <app_log>
    diag_drain();
    3914:	c71ff0ef          	jal	3584 <diag_drain>
}
    3918:	02c12083          	lw	ra,44(sp)
    391c:	02812403          	lw	s0,40(sp)
    3920:	02412483          	lw	s1,36(sp)
    3924:	03010113          	addi	sp,sp,48
    3928:	00008067          	ret
    app_log("osd probe: read back %s %s", b1,
    392c:	00009637          	lui	a2,0x9
    3930:	b4860613          	addi	a2,a2,-1208 # 8b48 <_data+0x1b4>
    3934:	f59ff06f          	j	388c <diag_probe_memory+0x10c>

00003938 <diag_dump_block>:
{
    3938:	f8010113          	addi	sp,sp,-128
    393c:	06112e23          	sw	ra,124(sp)
    3940:	06812c23          	sw	s0,120(sp)
    3944:	06912a23          	sw	s1,116(sp)
    3948:	07212823          	sw	s2,112(sp)
    394c:	07312623          	sw	s3,108(sp)
    3950:	07412423          	sw	s4,104(sp)
    3954:	00050a13          	mv	s4,a0
    3958:	00058413          	mv	s0,a1
    (void)canvas_read_block(idx, buf);
    395c:	378010ef          	jal	4cd4 <canvas_read_block>
    uint32_t hash    = 2166136261U;      /* FNV-1a 的 32 位初值 */
    3960:	811ca5b7          	lui	a1,0x811ca
    3964:	dc558593          	addi	a1,a1,-571 # 811c9dc5 <__freertos_irq_stack_top+0x811b9bc5>
    uint32_t first   = 0xFFFFFFFFU;
    3968:	fff00993          	li	s3,-1
    uint32_t setbits = 0U;
    396c:	00000493          	li	s1,0
    uint32_t nonzero = 0U;
    3970:	00000913          	li	s2,0
    for (i = 0U; i < DIAG_BYTES; i++) {
    3974:	00000713          	li	a4,0
    3978:	0200006f          	j	3998 <diag_dump_block+0x60>
                first = i;
    397c:	00070993          	mv	s3,a4
    3980:	0480006f          	j	39c8 <diag_dump_block+0x90>
                setbits++;
    3984:	00148493          	addi	s1,s1,1
                t = (uint8_t)(t & (uint8_t)(t - 1U));
    3988:	fff78693          	addi	a3,a5,-1
    398c:	00f6f7b3          	and	a5,a3,a5
            while (t != 0U) {
    3990:	fe079ae3          	bnez	a5,3984 <diag_dump_block+0x4c>
    for (i = 0U; i < DIAG_BYTES; i++) {
    3994:	00170713          	addi	a4,a4,1 # a60001 <__freertos_irq_stack_top+0xa4fe01>
    3998:	000037b7          	lui	a5,0x3
    399c:	73f78793          	addi	a5,a5,1855 # 373f <diag_probe_sticky+0x27>
    39a0:	02e7e863          	bltu	a5,a4,39d0 <diag_dump_block+0x98>
        uint8_t b = buf[i];
    39a4:	00e407b3          	add	a5,s0,a4
    39a8:	0007c783          	lbu	a5,0(a5)
        hash = (hash ^ (uint32_t)b) * 16777619U;
    39ac:	00b7c5b3          	xor	a1,a5,a1
    39b0:	010006b7          	lui	a3,0x1000
    39b4:	19368693          	addi	a3,a3,403 # 1000193 <__freertos_irq_stack_top+0xfeff93>
    39b8:	02d585b3          	mul	a1,a1,a3
        if (b != 0U) {
    39bc:	fc078ce3          	beqz	a5,3994 <diag_dump_block+0x5c>
            if (first == 0xFFFFFFFFU) {
    39c0:	fff00693          	li	a3,-1
    39c4:	fad98ce3          	beq	s3,a3,397c <diag_dump_block+0x44>
            nonzero++;
    39c8:	00190913          	addi	s2,s2,1
            while (t != 0U) {
    39cc:	fc5ff06f          	j	3990 <diag_dump_block+0x58>
    hex8(h, hash);
    39d0:	00c10513          	addi	a0,sp,12
    39d4:	b69ff0ef          	jal	353c <hex8>
    app_log("osd blk %c: nonzero=%u setbits=%u fnv1a=%s first=%u",
    39d8:	00100793          	li	a5,1
    39dc:	04fa0463          	beq	s4,a5,3a24 <diag_dump_block+0xec>
    39e0:	04100a13          	li	s4,65
    39e4:	00098793          	mv	a5,s3
    39e8:	00c10713          	addi	a4,sp,12
    39ec:	00048693          	mv	a3,s1
    39f0:	00090613          	mv	a2,s2
    39f4:	000a0593          	mv	a1,s4
    39f8:	00009537          	lui	a0,0x9
    39fc:	c1c50513          	addi	a0,a0,-996 # 8c1c <_data+0x288>
    3a00:	8bdff0ef          	jal	32bc <app_log>
    diag_drain();
    3a04:	b81ff0ef          	jal	3584 <diag_drain>
        app_log("osd blk %c map ('#'=any lit pixel in this 8x8 cell):",
    3a08:	000a0593          	mv	a1,s4
    3a0c:	00009537          	lui	a0,0x9
    3a10:	c5050513          	addi	a0,a0,-944 # 8c50 <_data+0x2bc>
    3a14:	8a9ff0ef          	jal	32bc <app_log>
        diag_drain();
    3a18:	b6dff0ef          	jal	3584 <diag_drain>
        for (cy = 0U; cy < DIAG_CELLS_Y; cy++) {
    3a1c:	00000493          	li	s1,0
    3a20:	08c0006f          	j	3aac <diag_dump_block+0x174>
    app_log("osd blk %c: nonzero=%u setbits=%u fnv1a=%s first=%u",
    3a24:	04200a13          	li	s4,66
    3a28:	fbdff06f          	j	39e4 <diag_dump_block+0xac>
                    any = (uint8_t)(any | buf[(cy * 8U + r) * OSD_ROW_STRIDE + cx]);
    3a2c:	00349713          	slli	a4,s1,0x3
    3a30:	00d70733          	add	a4,a4,a3
    3a34:	00471793          	slli	a5,a4,0x4
    3a38:	00e787b3          	add	a5,a5,a4
    3a3c:	00279793          	slli	a5,a5,0x2
    3a40:	00b787b3          	add	a5,a5,a1
    3a44:	00f407b3          	add	a5,s0,a5
    3a48:	0007c783          	lbu	a5,0(a5)
    3a4c:	00c7e633          	or	a2,a5,a2
                for (r = 0U; r < 8U; r++) {
    3a50:	00168693          	addi	a3,a3,1
    3a54:	00700793          	li	a5,7
    3a58:	fcd7fae3          	bgeu	a5,a3,3a2c <diag_dump_block+0xf4>
                line[cx] = any ? '#' : '.';
    3a5c:	02060663          	beqz	a2,3a88 <diag_dump_block+0x150>
    3a60:	02300713          	li	a4,35
    3a64:	06058793          	addi	a5,a1,96
    3a68:	002787b3          	add	a5,a5,sp
    3a6c:	fae78c23          	sb	a4,-72(a5)
            for (cx = 0U; cx < DIAG_CELLS_X; cx++) {
    3a70:	00158593          	addi	a1,a1,1
    3a74:	04300793          	li	a5,67
    3a78:	00b7ec63          	bltu	a5,a1,3a90 <diag_dump_block+0x158>
                for (r = 0U; r < 8U; r++) {
    3a7c:	00000693          	li	a3,0
                uint8_t  any = 0U;
    3a80:	00000613          	li	a2,0
    3a84:	fd1ff06f          	j	3a54 <diag_dump_block+0x11c>
                line[cx] = any ? '#' : '.';
    3a88:	02e00713          	li	a4,46
    3a8c:	fd9ff06f          	j	3a64 <diag_dump_block+0x12c>
            line[DIAG_CELLS_X] = '\0';
    3a90:	04010e23          	sb	zero,92(sp)
            app_log("%s", line);
    3a94:	01810593          	addi	a1,sp,24
    3a98:	00009537          	lui	a0,0x9
    3a9c:	bac50513          	addi	a0,a0,-1108 # 8bac <_data+0x218>
    3aa0:	81dff0ef          	jal	32bc <app_log>
            diag_drain();
    3aa4:	ae1ff0ef          	jal	3584 <diag_drain>
        for (cy = 0U; cy < DIAG_CELLS_Y; cy++) {
    3aa8:	00148493          	addi	s1,s1,1
    3aac:	01900793          	li	a5,25
    3ab0:	0097e663          	bltu	a5,s1,3abc <diag_dump_block+0x184>
            for (cx = 0U; cx < DIAG_CELLS_X; cx++) {
    3ab4:	00000593          	li	a1,0
    3ab8:	fbdff06f          	j	3a74 <diag_dump_block+0x13c>
}
    3abc:	07c12083          	lw	ra,124(sp)
    3ac0:	07812403          	lw	s0,120(sp)
    3ac4:	07412483          	lw	s1,116(sp)
    3ac8:	07012903          	lw	s2,112(sp)
    3acc:	06c12983          	lw	s3,108(sp)
    3ad0:	06812a03          	lw	s4,104(sp)
    3ad4:	08010113          	addi	sp,sp,128
    3ad8:	00008067          	ret

00003adc <osd_boot_diag>:
{
    3adc:	ff010113          	addi	sp,sp,-16
    3ae0:	00112623          	sw	ra,12(sp)
    3ae4:	00812423          	sw	s0,8(sp)
    app_log("--- osd boot readback ---");
    3ae8:	00009537          	lui	a0,0x9
    3aec:	c8850513          	addi	a0,a0,-888 # 8c88 <_data+0x2f4>
    3af0:	fccff0ef          	jal	32bc <app_log>
    diag_drain();
    3af4:	a91ff0ef          	jal	3584 <diag_drain>
    diag_dump_regs();
    3af8:	ab1ff0ef          	jal	35a8 <diag_dump_regs>
    diag_probe_memory();
    3afc:	c85ff0ef          	jal	3780 <diag_probe_memory>
    diag_dump_block(0, s_buf);
    3b00:	0000b437          	lui	s0,0xb
    3b04:	50440593          	addi	a1,s0,1284 # b504 <s_buf.2>
    3b08:	00000513          	li	a0,0
    3b0c:	e2dff0ef          	jal	3938 <diag_dump_block>
    diag_dump_block(1, s_buf);
    3b10:	50440593          	addi	a1,s0,1284
    3b14:	00100513          	li	a0,1
    3b18:	e21ff0ef          	jal	3938 <diag_dump_block>
    diag_probe_sticky();
    3b1c:	bfdff0ef          	jal	3718 <diag_probe_sticky>
    app_log("--- osd boot readback end ---");
    3b20:	00009537          	lui	a0,0x9
    3b24:	ca450513          	addi	a0,a0,-860 # 8ca4 <_data+0x310>
    3b28:	f94ff0ef          	jal	32bc <app_log>
    diag_drain();
    3b2c:	a59ff0ef          	jal	3584 <diag_drain>
}
    3b30:	00c12083          	lw	ra,12(sp)
    3b34:	00812403          	lw	s0,8(sp)
    3b38:	01010113          	addi	sp,sp,16
    3b3c:	00008067          	ret

00003b40 <report_frame>:
static void report_frame(const frame_t *frame, const protocol_response_t *response){
    3b40:	ff010113          	addi	sp,sp,-16
    3b44:	00112623          	sw	ra,12(sp)
    3b48:	00050613          	mv	a2,a0
    const uint32_t bit = (uint32_t)response->reason;
    3b4c:	0185a503          	lw	a0,24(a1)
    switch (response->reason) {
    3b50:	00800793          	li	a5,8
    3b54:	08a7e263          	bltu	a5,a0,3bd8 <report_frame+0x98>
    3b58:	00251793          	slli	a5,a0,0x2
    3b5c:	00009737          	lui	a4,0x9
    3b60:	55070713          	addi	a4,a4,1360 # 9550 <pow10.0+0x50>
    3b64:	00e787b3          	add	a5,a5,a4
    3b68:	0007a783          	lw	a5,0(a5)
    3b6c:	00078067          	jr	a5
        app_log_once(bit, "rx cmd=0x%x (%s) len=%u -> not implemented, nak",
    3b70:	00465703          	lhu	a4,4(a2)
    3b74:	01c5a683          	lw	a3,28(a1)
    3b78:	00164603          	lbu	a2,1(a2)
    3b7c:	000095b7          	lui	a1,0x9
    3b80:	cc458593          	addi	a1,a1,-828 # 8cc4 <_data+0x330>
    3b84:	f74ff0ef          	jal	32f8 <app_log_once>
}
    3b88:	00c12083          	lw	ra,12(sp)
    3b8c:	01010113          	addi	sp,sp,16
    3b90:	00008067          	ret
        app_log_once(bit, "rx cmd=0x%x unknown, nak", (uint32_t)frame->command);
    3b94:	00164603          	lbu	a2,1(a2)
    3b98:	000095b7          	lui	a1,0x9
    3b9c:	cf458593          	addi	a1,a1,-780 # 8cf4 <_data+0x360>
    3ba0:	f58ff0ef          	jal	32f8 <app_log_once>
        break;
    3ba4:	fe5ff06f          	j	3b88 <report_frame+0x48>
        app_log_once(bit, "rx cmd=0x%x (%s) len=%u wrong, nak",
    3ba8:	00465703          	lhu	a4,4(a2)
    3bac:	01c5a683          	lw	a3,28(a1)
    3bb0:	00164603          	lbu	a2,1(a2)
    3bb4:	000095b7          	lui	a1,0x9
    3bb8:	d1058593          	addi	a1,a1,-752 # 8d10 <_data+0x37c>
    3bbc:	f3cff0ef          	jal	32f8 <app_log_once>
        break;
    3bc0:	fc9ff06f          	j	3b88 <report_frame+0x48>
        app_log_once(bit, "rx cmd=0x%x bad type, nak", (uint32_t)frame->command);
    3bc4:	00164603          	lbu	a2,1(a2)
    3bc8:	000095b7          	lui	a1,0x9
    3bcc:	d3458593          	addi	a1,a1,-716 # 8d34 <_data+0x3a0>
    3bd0:	f28ff0ef          	jal	32f8 <app_log_once>
        break;
    3bd4:	fb5ff06f          	j	3b88 <report_frame+0x48>
        app_log_once(bit, "rx cmd=0x%x crc/footer bad -> no-ack",
    3bd8:	00164603          	lbu	a2,1(a2)
    3bdc:	000095b7          	lui	a1,0x9
    3be0:	d5058593          	addi	a1,a1,-688 # 8d50 <_data+0x3bc>
    3be4:	f14ff0ef          	jal	32f8 <app_log_once>
}
    3be8:	fa1ff06f          	j	3b88 <report_frame+0x48>

00003bec <poll_rx_loss>:
{
    3bec:	ff010113          	addi	sp,sp,-16
    3bf0:	00112623          	sw	ra,12(sp)
    3bf4:	00812423          	sw	s0,8(sp)
    uint32_t ring_drop = proto_uart_rx_dropped();
    3bf8:	768000ef          	jal	4360 <proto_uart_rx_dropped>
    3bfc:	00050413          	mv	s0,a0
    uint32_t fifo_ovf  = proto_uart_fifo_overflow();
    3c00:	768000ef          	jal	4368 <proto_uart_fifo_overflow>
    3c04:	00050693          	mv	a3,a0
    if ((ring_drop != s_ring_drop_seen) || (fifo_ovf != s_fifo_ovf_seen)) {
    3c08:	8d41a783          	lw	a5,-1836(gp) # b084 <s_ring_drop_seen>
    3c0c:	00879663          	bne	a5,s0,3c18 <poll_rx_loss+0x2c>
    3c10:	8d01a783          	lw	a5,-1840(gp) # b080 <s_fifo_ovf_seen>
    3c14:	02a78063          	beq	a5,a0,3c34 <poll_rx_loss+0x48>
        s_ring_drop_seen = ring_drop;
    3c18:	8c81aa23          	sw	s0,-1836(gp) # b084 <s_ring_drop_seen>
        s_fifo_ovf_seen = fifo_ovf;
    3c1c:	8cd1a823          	sw	a3,-1840(gp) # b080 <s_fifo_ovf_seen>
        app_log_once(ONCE_BIT_RX_DROPPED,
    3c20:	00040613          	mv	a2,s0
    3c24:	000095b7          	lui	a1,0x9
    3c28:	d7858593          	addi	a1,a1,-648 # 8d78 <_data+0x3e4>
    3c2c:	01000513          	li	a0,16
    3c30:	ec8ff0ef          	jal	32f8 <app_log_once>
}
    3c34:	00c12083          	lw	ra,12(sp)
    3c38:	00812403          	lw	s0,8(sp)
    3c3c:	01010113          	addi	sp,sp,16
    3c40:	00008067          	ret

00003c44 <log_stats>:
{
    3c44:	fc010113          	addi	sp,sp,-64
    3c48:	02112e23          	sw	ra,60(sp)
    3c4c:	02812c23          	sw	s0,56(sp)
    3c50:	02912a23          	sw	s1,52(sp)
    3c54:	03212823          	sw	s2,48(sp)
    3c58:	03312623          	sw	s3,44(sp)
    3c5c:	03412423          	sw	s4,40(sp)
    3c60:	03512223          	sw	s5,36(sp)
    3c64:	03612023          	sw	s6,32(sp)
    3c68:	01712e23          	sw	s7,28(sp)
    app_log("stats: frames=%u accepted=%u bad=%u other=%u bad_len=%u "
    3c6c:	8fc1a983          	lw	s3,-1796(gp) # b0ac <s_frames_processed>
    3c70:	0000f7b7          	lui	a5,0xf
    3c74:	c4478793          	addi	a5,a5,-956 # ec44 <s_stats>
    3c78:	0007aa03          	lw	s4,0(a5)
    3c7c:	0047aa83          	lw	s5,4(a5)
    3c80:	0087ab03          	lw	s6,8(a5)
    3c84:	0000f7b7          	lui	a5,0xf
    3c88:	c5078793          	addi	a5,a5,-944 # ec50 <s_parser>
    3c8c:	0107ab83          	lw	s7,16(a5)
    3c90:	6d0000ef          	jal	4360 <proto_uart_rx_dropped>
    3c94:	00050413          	mv	s0,a0
    3c98:	6d0000ef          	jal	4368 <proto_uart_fifo_overflow>
    3c9c:	00050493          	mv	s1,a0
    3ca0:	e14ff0ef          	jal	32b4 <app_log_dropped>
    3ca4:	00a12023          	sw	a0,0(sp)
    3ca8:	00048893          	mv	a7,s1
    3cac:	00040813          	mv	a6,s0
    3cb0:	000b8793          	mv	a5,s7
    3cb4:	000b0713          	mv	a4,s6
    3cb8:	000a8693          	mv	a3,s5
    3cbc:	000a0613          	mv	a2,s4
    3cc0:	00098593          	mv	a1,s3
    3cc4:	00009537          	lui	a0,0x9
    3cc8:	db450513          	addi	a0,a0,-588 # 8db4 <_data+0x420>
    3ccc:	df0ff0ef          	jal	32bc <app_log>
    s_reported_frames = s_frames_processed;
    3cd0:	8fc1a703          	lw	a4,-1796(gp) # b0ac <s_frames_processed>
    3cd4:	8ce1ae23          	sw	a4,-1828(gp) # b08c <s_reported_frames>
}
    3cd8:	03c12083          	lw	ra,60(sp)
    3cdc:	03812403          	lw	s0,56(sp)
    3ce0:	03412483          	lw	s1,52(sp)
    3ce4:	03012903          	lw	s2,48(sp)
    3ce8:	02c12983          	lw	s3,44(sp)
    3cec:	02812a03          	lw	s4,40(sp)
    3cf0:	02412a83          	lw	s5,36(sp)
    3cf4:	02012b03          	lw	s6,32(sp)
    3cf8:	01c12b83          	lw	s7,28(sp)
    3cfc:	04010113          	addi	sp,sp,64
    3d00:	00008067          	ret

00003d04 <handle_frame>:
static void handle_frame(const frame_t *frame){
    3d04:	fb010113          	addi	sp,sp,-80
    3d08:	04112623          	sw	ra,76(sp)
    3d0c:	04812423          	sw	s0,72(sp)
    3d10:	04912223          	sw	s1,68(sp)
    3d14:	00050413          	mv	s0,a0
    ack_len = osd_engine_handle(&s_stats, frame, &response, ack);
    3d18:	00c10693          	addi	a3,sp,12
    3d1c:	02010613          	addi	a2,sp,32
    3d20:	00050593          	mv	a1,a0
    3d24:	0000f537          	lui	a0,0xf
    3d28:	c4450513          	addi	a0,a0,-956 # ec44 <s_stats>
    3d2c:	128010ef          	jal	4e54 <osd_engine_handle>
    3d30:	00050493          	mv	s1,a0
    s_frames_processed++;
    3d34:	8fc1a783          	lw	a5,-1796(gp) # b0ac <s_frames_processed>
    3d38:	00178793          	addi	a5,a5,1
    3d3c:	8ef1ae23          	sw	a5,-1796(gp) # b0ac <s_frames_processed>
    report_frame(frame, &response);
    3d40:	02010593          	addi	a1,sp,32
    3d44:	00040513          	mv	a0,s0
    3d48:	df9ff0ef          	jal	3b40 <report_frame>
    if (ack_len != 0U) {
    3d4c:	02049463          	bnez	s1,3d74 <handle_frame+0x70>
    poll_rx_loss();
    3d50:	e9dff0ef          	jal	3bec <poll_rx_loss>
    if ((s_frames_processed % STATS_INTERVAL) == 0U) {
    3d54:	8fc1a783          	lw	a5,-1796(gp) # b0ac <s_frames_processed>
    3d58:	03f7f793          	andi	a5,a5,63
    3d5c:	02078463          	beqz	a5,3d84 <handle_frame+0x80>
}
    3d60:	04c12083          	lw	ra,76(sp)
    3d64:	04812403          	lw	s0,72(sp)
    3d68:	04412483          	lw	s1,68(sp)
    3d6c:	05010113          	addi	sp,sp,80
    3d70:	00008067          	ret
        (void)proto_uart_write(ack, ack_len);
    3d74:	00048593          	mv	a1,s1
    3d78:	00c10513          	addi	a0,sp,12
    3d7c:	6b4000ef          	jal	4430 <proto_uart_write>
    3d80:	fd1ff06f          	j	3d50 <handle_frame+0x4c>
        log_stats();
    3d84:	ec1ff0ef          	jal	3c44 <log_stats>
}
    3d88:	fd9ff06f          	j	3d60 <handle_frame+0x5c>

00003d8c <isr_routine>:
void isr_routine(){
    3d8c:	ff010113          	addi	sp,sp,-16
    3d90:	00112623          	sw	ra,12(sp)
    3d94:	00812423          	sw	s0,8(sp)
    while ((claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)) != 0U) {
    3d98:	0180006f          	j	3db0 <isr_routine+0x24>
            proto_uart_isr();      /* 把收到的字节搬进接收环 */
    3d9c:	600000ef          	jal	439c <proto_uart_isr>
        plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim);
    3da0:	00040613          	mv	a2,s0
    3da4:	00000593          	li	a1,0
    3da8:	f8c00537          	lui	a0,0xf8c00
    3dac:	f44ff0ef          	jal	34f0 <plic_release>
    while ((claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)) != 0U) {
    3db0:	00000593          	li	a1,0
    3db4:	f8c00537          	lui	a0,0xf8c00
    3db8:	f1cff0ef          	jal	34d4 <plic_claim>
    3dbc:	00050413          	mv	s0,a0
    3dc0:	00050e63          	beqz	a0,3ddc <isr_routine+0x50>
        if (claim == SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT) {
    3dc4:	00200793          	li	a5,2
    3dc8:	fcf40ae3          	beq	s0,a5,3d9c <isr_routine+0x10>
            s_isr_unknown_source++;
    3dcc:	8e81a783          	lw	a5,-1816(gp) # b098 <s_isr_unknown_source>
    3dd0:	00178793          	addi	a5,a5,1
    3dd4:	8ef1a423          	sw	a5,-1816(gp) # b098 <s_isr_unknown_source>
    3dd8:	fc9ff06f          	j	3da0 <isr_routine+0x14>
}
    3ddc:	00c12083          	lw	ra,12(sp)
    3de0:	00812403          	lw	s0,8(sp)
    3de4:	01010113          	addi	sp,sp,16
    3de8:	00008067          	ret

00003dec <trap>:
void trap(){
    3dec:	ff010113          	addi	sp,sp,-16
    3df0:	00112623          	sw	ra,12(sp)
    int32_t mcause = csr_read(mcause);   /* 读 CSR 寄存器，得到异常/中断原因 */
    3df4:	342025f3          	csrr	a1,mcause
    int32_t cause     = mcause & 0xF;    /* 低 4 位 → 具体原因编号 */
    3df8:	00f5f793          	andi	a5,a1,15
    if (interrupt) {
    3dfc:	0205c663          	bltz	a1,3e28 <trap+0x3c>
    if (cause == CAUSE_BREAKPOINT) {
    3e00:	00300713          	li	a4,3
    3e04:	04e78263          	beq	a5,a4,3e48 <trap+0x5c>
    s_unexpected_exceptions++;
    3e08:	8f01a783          	lw	a5,-1808(gp) # b0a0 <s_unexpected_exceptions>
    3e0c:	00178793          	addi	a5,a5,1
    3e10:	8ef1a823          	sw	a5,-1808(gp) # b0a0 <s_unexpected_exceptions>
    if (!s_unexpected_exception_logged) {
    3e14:	8ec1c783          	lbu	a5,-1812(gp) # b09c <s_unexpected_exception_logged>
    3e18:	04078063          	beqz	a5,3e58 <trap+0x6c>
}
    3e1c:	00c12083          	lw	ra,12(sp)
    3e20:	01010113          	addi	sp,sp,16
    3e24:	00008067          	ret
        if (cause == CAUSE_MACHINE_EXTERNAL) {
    3e28:	00b00713          	li	a4,11
    3e2c:	00e78a63          	beq	a5,a4,3e40 <trap+0x54>
            s_unexpected_interrupts++;
    3e30:	8f41a783          	lw	a5,-1804(gp) # b0a4 <s_unexpected_interrupts>
    3e34:	00178793          	addi	a5,a5,1
    3e38:	8ef1aa23          	sw	a5,-1804(gp) # b0a4 <s_unexpected_interrupts>
        return;
    3e3c:	fe1ff06f          	j	3e1c <trap+0x30>
            isr_routine();
    3e40:	f4dff0ef          	jal	3d8c <isr_routine>
    3e44:	fd9ff06f          	j	3e1c <trap+0x30>
        s_semihosting_breakpoints++;
    3e48:	8f81a783          	lw	a5,-1800(gp) # b0a8 <s_semihosting_breakpoints>
    3e4c:	00178793          	addi	a5,a5,1
    3e50:	8ef1ac23          	sw	a5,-1800(gp) # b0a8 <s_semihosting_breakpoints>
        return;
    3e54:	fc9ff06f          	j	3e1c <trap+0x30>
        s_unexpected_exception_logged = 1;
    3e58:	00100713          	li	a4,1
    3e5c:	8ee18623          	sb	a4,-1812(gp) # b09c <s_unexpected_exception_logged>
        app_log("trap: unexpected exception mcause=0x%x", (uint32_t)mcause);
    3e60:	00009537          	lui	a0,0x9
    3e64:	e1450513          	addi	a0,a0,-492 # 8e14 <_data+0x480>
    3e68:	c54ff0ef          	jal	32bc <app_log>
    3e6c:	fb1ff06f          	j	3e1c <trap+0x30>

00003e70 <start_frame>:
*       好处是链接器不会为它生成对外符号，也不怕和别的文件里的同名函数冲突。
*       本文件里所有辅助函数都用 static。
******************************************************************************/
static int start_frame(frame_parser_t *parser, uint8_t byte)
{
    if (byte != FRAME_HEADER) {
    3e70:	0bb00793          	li	a5,187
    3e74:	02f59663          	bne	a1,a5,3ea0 <start_frame+0x30>
        return 0;   /* 不是帧头，当噪声丢掉，继续等 */
    }
    parser->state = ST_LEN_H;
    3e78:	00100793          	li	a5,1
    3e7c:	00f50023          	sb	a5,0(a0)
    parser->body_length = 0U;
    3e80:	00051123          	sh	zero,2(a0)
    parser->body_index = 0U;
    3e84:	00051223          	sh	zero,4(a0)
    parser->body_crc = 0U;
    3e88:	00051323          	sh	zero,6(a0)
    parser->recv_crc = 0U;
    3e8c:	00051423          	sh	zero,8(a0)
    parser->category = 0U;
    3e90:	00050523          	sb	zero,10(a0)
    parser->command = 0U;
    3e94:	000505a3          	sb	zero,11(a0)
    parser->type = 0U;
    3e98:	00050623          	sb	zero,12(a0)
    parser->payload_len = 0U;
    3e9c:	00051a23          	sh	zero,20(a0)
    return 0;
}
    3ea0:	00000513          	li	a0,0
    3ea4:	00008067          	ret

00003ea8 <frame_parser_init>:
    if (parser == 0) {
    3ea8:	04050863          	beqz	a0,3ef8 <frame_parser_init+0x50>
    parser->state = ST_HEADER;
    3eac:	00050023          	sb	zero,0(a0)
    parser->body_length = 0U;
    3eb0:	00051123          	sh	zero,2(a0)
    parser->body_index = 0U;
    3eb4:	00051223          	sh	zero,4(a0)
    parser->body_crc = 0U;
    3eb8:	00051323          	sh	zero,6(a0)
    parser->recv_crc = 0U;
    3ebc:	00051423          	sh	zero,8(a0)
    parser->category = 0U;
    3ec0:	00050523          	sb	zero,10(a0)
    parser->command = 0U;
    3ec4:	000505a3          	sb	zero,11(a0)
    parser->type = 0U;
    3ec8:	00050623          	sb	zero,12(a0)
    parser->bad_length_count = 0U;
    3ecc:	00052823          	sw	zero,16(a0)
    parser->payload_len = 0U;
    3ed0:	00051a23          	sh	zero,20(a0)
        for (i = 0U; i < FRAME_PAYLOAD_MAX; i++) {
    3ed4:	00000793          	li	a5,0
    3ed8:	0180006f          	j	3ef0 <frame_parser_init+0x48>
            parser->payload[i] = 0U;
    3edc:	00f50733          	add	a4,a0,a5
    3ee0:	00070b23          	sb	zero,22(a4)
        for (i = 0U; i < FRAME_PAYLOAD_MAX; i++) {
    3ee4:	00178793          	addi	a5,a5,1
    3ee8:	01079793          	slli	a5,a5,0x10
    3eec:	0107d793          	srli	a5,a5,0x10
    3ef0:	00b00713          	li	a4,11
    3ef4:	fef774e3          	bgeu	a4,a5,3edc <frame_parser_init+0x34>
}
    3ef8:	00008067          	ret

00003efc <frame_parser_feed>:
*       break 导致穿透到下一个 case"这个 C 语言的经典坑；二是每个状态的
*       处理路径互不影响，读代码时不用往回看。
******************************************************************************/
int frame_parser_feed(frame_parser_t *parser, uint8_t byte, frame_t *out)
{
    if ((parser == 0) || (out == 0)) {
    3efc:	22050063          	beqz	a0,411c <frame_parser_feed+0x220>
{
    3f00:	ff010113          	addi	sp,sp,-16
    3f04:	00112623          	sw	ra,12(sp)
    3f08:	00812423          	sw	s0,8(sp)
    3f0c:	00912223          	sw	s1,4(sp)
    3f10:	00050413          	mv	s0,a0
    3f14:	00058493          	mv	s1,a1
    if ((parser == 0) || (out == 0)) {
    3f18:	20060663          	beqz	a2,4124 <frame_parser_feed+0x228>
        return 0;
    }

    switch (parser->state) {
    3f1c:	00054783          	lbu	a5,0(a0)
    3f20:	00500713          	li	a4,5
    3f24:	14f76663          	bltu	a4,a5,4070 <frame_parser_feed+0x174>
    3f28:	00279793          	slli	a5,a5,0x2
    3f2c:	00009737          	lui	a4,0x9
    3f30:	59870713          	addi	a4,a4,1432 # 9598 <digits.1+0x14>
    3f34:	00e787b3          	add	a5,a5,a4
    3f38:	0007a783          	lw	a5,0(a5)
    3f3c:	00078067          	jr	a5
    /* --- 等帧头：帧与帧之间的所有噪声都在这里被自然丢弃 --- */
    case ST_HEADER:
        return start_frame(parser, byte);
    3f40:	f31ff0ef          	jal	3e70 <start_frame>
    3f44:	1e40006f          	j	4128 <frame_parser_feed+0x22c>

    /* --- 长度高字节：先暂存到 body_length 的高 8 位 --- */
    case ST_LEN_H:
        /* (uint16_t)byte << 8 把这一字节挪到高字节，低字节此时还是 0。
         * 用 = 而不是 |= 是刻意的：这里直接覆盖，避免上一帧的残留值混进来。*/
        parser->body_length = (uint16_t)byte << 8;
    3f48:	00859493          	slli	s1,a1,0x8
    3f4c:	00951123          	sh	s1,2(a0)
        parser->state = ST_LEN_L;
    3f50:	00200793          	li	a5,2
    3f54:	00f50023          	sb	a5,0(a0)
        return 0;
    3f58:	00000513          	li	a0,0
    3f5c:	1cc0006f          	j	4128 <frame_parser_feed+0x22c>

    /* --- 长度低字节：凑成完整长度，并立刻检查是否合法 --- */
    case ST_LEN_L:
        /* |= 把低字节补上，此时 body_length 才是完整的 16 位长度。*/
        parser->body_length |= (uint16_t)byte;
    3f60:	00255783          	lhu	a5,2(a0)
    3f64:	00f5e7b3          	or	a5,a1,a5
    3f68:	00f51123          	sh	a5,2(a0)

        if ((parser->body_length < FRAME_BODY_LEN_MIN) ||
    3f6c:	ffd78793          	addi	a5,a5,-3
    3f70:	01079793          	slli	a5,a5,0x10
    3f74:	0107d793          	srli	a5,a5,0x10
    3f78:	00001737          	lui	a4,0x1
    3f7c:	38470713          	addi	a4,a4,900 # 1384 <_out_rev+0x34>
    3f80:	00f76c63          	bltu	a4,a5,3f98 <frame_parser_feed+0x9c>
             * 没成为一个帧。*/
            parser->bad_length_count++;
            parser->state = ST_HEADER;
            return 0;
        }
        parser->body_index = 0U;
    3f84:	00051223          	sh	zero,4(a0)
        parser->state = ST_BODY;
    3f88:	00300793          	li	a5,3
    3f8c:	00f50023          	sb	a5,0(a0)
        return 0;
    3f90:	00000513          	li	a0,0
    3f94:	1940006f          	j	4128 <frame_parser_feed+0x22c>
            parser->bad_length_count++;
    3f98:	01052783          	lw	a5,16(a0)
    3f9c:	00178793          	addi	a5,a5,1
    3fa0:	00f52823          	sw	a5,16(a0)
            parser->state = ST_HEADER;
    3fa4:	00050023          	sb	zero,0(a0)
            return 0;
    3fa8:	00000513          	li	a0,0
    3fac:	17c0006f          	j	4128 <frame_parser_feed+0x22c>

    /* --- body：边收边算 CRC，同时把前 3 个字节记下来 --- */
    case ST_BODY:
        parser->body_crc = crc16_ccitt_update(parser->body_crc, byte);
    3fb0:	00655503          	lhu	a0,6(a0)
    3fb4:	510000ef          	jal	44c4 <crc16_ccitt_update>
    3fb8:	00a41323          	sh	a0,6(s0)

        /* 前 3 个字节是固定的头结构，第 3 个 if 之后的都是 payload。
         * 注意这里**只记录、不校验**：大类是路由字段，合法性由上层判断
         * （见 frame.h 里"大类是路由字段，不是格式标记"的说明）。
         * 只有"类型"这一位在帧尾阶段会做校验。*/
        if (parser->body_index == 0U) {
    3fbc:	00445783          	lhu	a5,4(s0)
    3fc0:	02079663          	bnez	a5,3fec <frame_parser_feed+0xf0>
            parser->category = byte;
    3fc4:	00940523          	sb	s1,10(s0)
        }

        /* 收到第 body_length 个字节时，body 结束，转去收 CRC。
         * body_index 从 0 计，所以最后一个字节的下标是 body_length-1。
         * 这里的减法已经安全：长度在 ST_LEN_L 阶段校验过 >= 3。*/
        if (parser->body_index == (uint16_t)(parser->body_length - 1U)) {
    3fc8:	00245703          	lhu	a4,2(s0)
    3fcc:	fff70713          	addi	a4,a4,-1
    3fd0:	01071713          	slli	a4,a4,0x10
    3fd4:	01075713          	srli	a4,a4,0x10
    3fd8:	04e78a63          	beq	a5,a4,402c <frame_parser_feed+0x130>
            parser->state = ST_CRC_H;
        } else {
            parser->body_index++;
    3fdc:	00178793          	addi	a5,a5,1
    3fe0:	00f41223          	sh	a5,4(s0)
        }
        return 0;
    3fe4:	00000513          	li	a0,0
    3fe8:	1400006f          	j	4128 <frame_parser_feed+0x22c>
        } else if (parser->body_index == 1U) {
    3fec:	00100713          	li	a4,1
    3ff0:	02e78663          	beq	a5,a4,401c <frame_parser_feed+0x120>
        } else if (parser->body_index == 2U) {
    3ff4:	00200713          	li	a4,2
    3ff8:	02e78663          	beq	a5,a4,4024 <frame_parser_feed+0x128>
            uint16_t k = (uint16_t)(parser->body_index - 3U);
    3ffc:	ffd78713          	addi	a4,a5,-3
    4000:	01071713          	slli	a4,a4,0x10
    4004:	01075713          	srli	a4,a4,0x10
            if (k < FRAME_PAYLOAD_MAX) {
    4008:	00b00693          	li	a3,11
    400c:	fae6eee3          	bltu	a3,a4,3fc8 <frame_parser_feed+0xcc>
                parser->payload[k] = byte;
    4010:	00e40733          	add	a4,s0,a4
    4014:	00970b23          	sb	s1,22(a4)
    4018:	fb1ff06f          	j	3fc8 <frame_parser_feed+0xcc>
            parser->command = byte;
    401c:	009405a3          	sb	s1,11(s0)
    4020:	fa9ff06f          	j	3fc8 <frame_parser_feed+0xcc>
            parser->type = byte;
    4024:	00940623          	sb	s1,12(s0)
    4028:	fa1ff06f          	j	3fc8 <frame_parser_feed+0xcc>
            parser->state = ST_CRC_H;
    402c:	00400793          	li	a5,4
    4030:	00f40023          	sb	a5,0(s0)
        return 0;
    4034:	00000513          	li	a0,0
    4038:	0f00006f          	j	4128 <frame_parser_feed+0x22c>

    /* --- CRC 高字节 --- */
    case ST_CRC_H:
        parser->recv_crc = (uint16_t)byte << 8;
    403c:	00859493          	slli	s1,a1,0x8
    4040:	00951423          	sh	s1,8(a0)
        parser->state = ST_CRC_L;
    4044:	00500793          	li	a5,5
    4048:	00f50023          	sb	a5,0(a0)
        return 0;
    404c:	00000513          	li	a0,0
    4050:	0d80006f          	j	4128 <frame_parser_feed+0x22c>

    /* --- CRC 低字节：凑成完整 CRC，转去收帧尾 --- */
    case ST_CRC_L:
        parser->recv_crc |= (uint16_t)byte;
    4054:	00855783          	lhu	a5,8(a0)
    4058:	00f5e7b3          	or	a5,a1,a5
    405c:	00f51423          	sh	a5,8(a0)
        parser->state = ST_FOOTER;
    4060:	00600793          	li	a5,6
    4064:	00f50023          	sb	a5,0(a0)
        return 0;
    4068:	00000513          	li	a0,0
    406c:	0bc0006f          	j	4128 <frame_parser_feed+0x22c>
    default:
        /* default 和 ST_FOOTER 走同一段代码，是防御性写法：万一 state 被
         * 内存踩坏成了非法值，也只会当成"帧尾"处理并立即复位回 ST_HEADER，
         * 不会卡死在非法状态里。*/

        out->category    = parser->category;
    4070:	00a54783          	lbu	a5,10(a0)
    4074:	00f60023          	sb	a5,0(a2)
        out->command     = parser->command;
    4078:	00b54783          	lbu	a5,11(a0)
    407c:	00f600a3          	sb	a5,1(a2)
        out->type        = parser->type;
    4080:	00c54783          	lbu	a5,12(a0)
    4084:	00f60123          	sb	a5,2(a2)
        out->body_length = parser->body_length;
    4088:	00255783          	lhu	a5,2(a0)
    408c:	00f61223          	sh	a5,4(a2)

        /* payload_len 是"帧里声明有多少"（body_length 减去 3 字节 body 头），
         * 可能大于窗口容量；payload[] 里只有前 min(payload_len, 12) 个字节有效。
         * 长度在 ST_LEN_L 阶段校验过 >= 3，所以这里的减法不会下溢。*/
        out->payload_len = (uint16_t)(parser->body_length - 3U);
    4090:	ffd78793          	addi	a5,a5,-3
    4094:	00f61523          	sh	a5,10(a2)
        {
            uint16_t i;
            for (i = 0U; i < FRAME_PAYLOAD_MAX; i++) {
    4098:	00000793          	li	a5,0
    409c:	0200006f          	j	40bc <frame_parser_feed+0x1c0>
                out->payload[i] = parser->payload[i];
    40a0:	00f40733          	add	a4,s0,a5
    40a4:	01674683          	lbu	a3,22(a4)
    40a8:	00f60733          	add	a4,a2,a5
    40ac:	00d70623          	sb	a3,12(a4)
            for (i = 0U; i < FRAME_PAYLOAD_MAX; i++) {
    40b0:	00178793          	addi	a5,a5,1
    40b4:	01079793          	slli	a5,a5,0x10
    40b8:	0107d793          	srli	a5,a5,0x10
    40bc:	00b00713          	li	a4,11
    40c0:	fef770e3          	bgeu	a4,a5,40a0 <frame_parser_feed+0x1a4>
        }

        /* 三个布尔标志都写成 `? 1U : 0U` 而不是直接赋值比较表达式的结果。
         * 因为 C 里比较运算符的结果是 int 类型的 1/0，直接赋给 uint8_t 字段
         * 虽然没问题，但显式写出来能保证字段里只可能是 0 或 1。*/
        out->crc_ok      = (parser->recv_crc == parser->body_crc) ? 1U : 0U;
    40c4:	00845703          	lhu	a4,8(s0)
    40c8:	00645783          	lhu	a5,6(s0)
    40cc:	02f70c63          	beq	a4,a5,4104 <frame_parser_feed+0x208>
    40d0:	00000793          	li	a5,0
    40d4:	00f60323          	sb	a5,6(a2)
        out->footer_ok   = (byte == FRAME_FOOTER) ? 1U : 0U;
    40d8:	0aa00793          	li	a5,170
    40dc:	02f48863          	beq	s1,a5,410c <frame_parser_feed+0x210>
    40e0:	00000793          	li	a5,0
    40e4:	00f603a3          	sb	a5,7(a2)
        /* 格式校验只有这一条：命令帧的类型必须是"上位机写"。
         * 大类**不在这里校验**——它是路由字段，变倍/热点/UI 的大类都是合法的，
         * 只是不该由本应用处理（在上层分流）。*/
        out->format_ok   = (parser->type == FRAME_TYPE_WRITE) ? 1U : 0U;
    40e8:	00c44783          	lbu	a5,12(s0)
    40ec:	02079463          	bnez	a5,4114 <frame_parser_feed+0x218>
    40f0:	00100793          	li	a5,1
    40f4:	00f60423          	sb	a5,8(a2)

        /* 无论这一帧是好是坏，解析器都回到等帧头，准备接下一帧。
         * 这样"坏帧"不会让解析器停摆——上位机可以继续发下一条命令。*/
        parser->state = ST_HEADER;
    40f8:	00040023          	sb	zero,0(s0)
        return 1;
    40fc:	00100513          	li	a0,1
    4100:	0280006f          	j	4128 <frame_parser_feed+0x22c>
        out->crc_ok      = (parser->recv_crc == parser->body_crc) ? 1U : 0U;
    4104:	00100793          	li	a5,1
    4108:	fcdff06f          	j	40d4 <frame_parser_feed+0x1d8>
        out->footer_ok   = (byte == FRAME_FOOTER) ? 1U : 0U;
    410c:	00100793          	li	a5,1
    4110:	fd5ff06f          	j	40e4 <frame_parser_feed+0x1e8>
        out->format_ok   = (parser->type == FRAME_TYPE_WRITE) ? 1U : 0U;
    4114:	00000793          	li	a5,0
    4118:	fddff06f          	j	40f4 <frame_parser_feed+0x1f8>
        return 0;
    411c:	00000513          	li	a0,0
    }
}
    4120:	00008067          	ret
        return 0;
    4124:	00000513          	li	a0,0
}
    4128:	00c12083          	lw	ra,12(sp)
    412c:	00812403          	lw	s0,8(sp)
    4130:	00412483          	lw	s1,4(sp)
    4134:	01010113          	addi	sp,sp,16
    4138:	00008067          	ret

0000413c <uart_writeAvailability>:
        return *((volatile u32*) address);
    413c:	00452503          	lw	a0,4(a0)
        return (read_u32(reg + UART_STATUS) >> 16) & 0xFF;
    4140:	01055513          	srli	a0,a0,0x10
    }
    4144:	0ff57513          	zext.b	a0,a0
    4148:	00008067          	ret

0000414c <uart_readOccupancy>:
    414c:	00452503          	lw	a0,4(a0)
    }
    4150:	01855513          	srli	a0,a0,0x18
    4154:	00008067          	ret

00004158 <uart_read>:
    static char uart_read(u32 reg){
    4158:	ff010113          	addi	sp,sp,-16
    415c:	00112623          	sw	ra,12(sp)
    4160:	00812423          	sw	s0,8(sp)
    4164:	00050413          	mv	s0,a0
        while(uart_readOccupancy(reg) == 0);
    4168:	00040513          	mv	a0,s0
    416c:	fe1ff0ef          	jal	414c <uart_readOccupancy>
    4170:	fe050ce3          	beqz	a0,4168 <uart_read+0x10>
    4174:	00042503          	lw	a0,0(s0)
    }
    4178:	0ff57513          	zext.b	a0,a0
    417c:	00c12083          	lw	ra,12(sp)
    4180:	00812403          	lw	s0,8(sp)
    4184:	01010113          	addi	sp,sp,16
    4188:	00008067          	ret

0000418c <uart_applyConfig>:
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
    418c:	00c5a783          	lw	a5,12(a1)
        *((volatile u32*) address) = data;
    4190:	00f52423          	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
    4194:	0005a783          	lw	a5,0(a1)
    4198:	fff78793          	addi	a5,a5,-1
    419c:	0045a703          	lw	a4,4(a1)
    41a0:	00871713          	slli	a4,a4,0x8
    41a4:	00e7e7b3          	or	a5,a5,a4
    41a8:	0085a703          	lw	a4,8(a1)
    41ac:	01071713          	slli	a4,a4,0x10
    41b0:	00e7e7b3          	or	a5,a5,a4
    41b4:	00f52623          	sw	a5,12(a0)
    }
    41b8:	00008067          	ret

000041bc <uart_status_read>:
        return *((volatile u32*) address);
    41bc:	00452503          	lw	a0,4(a0)
*
******************************************************************************/    
    static u32 uart_status_read(u32 reg)
     {
    	 return read_u32(reg+UART_STATUS);
     }
    41c0:	00008067          	ret

000041c4 <uart_status_write>:
        *((volatile u32*) address) = data;
    41c4:	00b52223          	sw	a1,4(a0)
*
******************************************************************************/
    static void uart_status_write(u32 reg, char data)
    {
    	write_u32(data ,reg+UART_STATUS);
    }
    41c8:	00008067          	ret

000041cc <uart_RX_NotemptyInterruptEna>:
*          clears the second least significant bit to disable the RX not empty interrupt,
*          or sets it to enable the RX not empty interrupt based on the provided flag,
*          and then writes the modified value back to the UART status register.
*
******************************************************************************/
    static void uart_RX_NotemptyInterruptEna(u32 reg, char Ena){
    41cc:	ff010113          	addi	sp,sp,-16
    41d0:	00112623          	sw	ra,12(sp)
    41d4:	00812423          	sw	s0,8(sp)
    41d8:	00912223          	sw	s1,4(sp)
    41dc:	00050493          	mv	s1,a0
    41e0:	00058413          	mv	s0,a1
    	uart_status_write(reg,(uart_status_read(reg) & 0xFFFFFFFD) | (Ena << 1));	
    41e4:	fd9ff0ef          	jal	41bc <uart_status_read>
    41e8:	0fd57593          	andi	a1,a0,253
    41ec:	00141413          	slli	s0,s0,0x1
    41f0:	0ff47413          	zext.b	s0,s0
    41f4:	0085e5b3          	or	a1,a1,s0
    41f8:	00048513          	mv	a0,s1
    41fc:	fc9ff0ef          	jal	41c4 <uart_status_write>
    }
    4200:	00c12083          	lw	ra,12(sp)
    4204:	00812403          	lw	s0,8(sp)
    4208:	00412483          	lw	s1,4(sp)
    420c:	01010113          	addi	sp,sp,16
    4210:	00008067          	ret

00004214 <plic_set_priority>:
        write_u32(priority, plic + PLIC_PRIORITY_BASE + gateway*4);
    4214:	00259593          	slli	a1,a1,0x2
    4218:	00a585b3          	add	a1,a1,a0
    421c:	00c5a023          	sw	a2,0(a1)
    }
    4220:	00008067          	ret

00004224 <plic_set_enable>:
        u32 word = plic + PLIC_ENABLE_BASE + target * PLIC_ENABLE_PER_HART + (gateway / 32 * 4);
    4224:	00759593          	slli	a1,a1,0x7
    4228:	00a585b3          	add	a1,a1,a0
    422c:	00565793          	srli	a5,a2,0x5
    4230:	00279793          	slli	a5,a5,0x2
    4234:	00f587b3          	add	a5,a1,a5
    4238:	00002737          	lui	a4,0x2
    423c:	00e787b3          	add	a5,a5,a4
        u32 mask = 1 << (gateway % 32);
    4240:	00100713          	li	a4,1
    4244:	00c71633          	sll	a2,a4,a2
        if (enable)
    4248:	00068a63          	beqz	a3,425c <plic_set_enable+0x38>
        return *((volatile u32*) address);
    424c:	0007a703          	lw	a4,0(a5)
            write_u32(read_u32(word) | mask, word);
    4250:	00e66633          	or	a2,a2,a4
        *((volatile u32*) address) = data;
    4254:	00c7a023          	sw	a2,0(a5)
    }
    4258:	00008067          	ret
        return *((volatile u32*) address);
    425c:	0007a703          	lw	a4,0(a5)
            write_u32(read_u32(word) & ~mask, word);
    4260:	fff64613          	not	a2,a2
    4264:	00e67633          	and	a2,a2,a4
        *((volatile u32*) address) = data;
    4268:	00c7a023          	sw	a2,0(a5)
    }
    426c:	00008067          	ret

00004270 <plic_set_threshold>:
        write_u32(threshold, plic + PLIC_THRESHOLD_BASE + target*PLIC_CONTEXT_PER_HART);
    4270:	00c59593          	slli	a1,a1,0xc
    4274:	00a585b3          	add	a1,a1,a0
    4278:	002007b7          	lui	a5,0x200
    427c:	00f585b3          	add	a1,a1,a5
    4280:	00c5a023          	sw	a2,0(a1)
    }
    4284:	00008067          	ret

00004288 <proto_uart_init>:
* @note 调用顺序上，本函数要在 isr_init() 之前调用（见 main.c）：先把中断源
*       配好，再全局开中断。反过来的话，开中断后到中断源配置好之间可能出现
*       一个"中断已使能但没有正确处理程序"的窗口。
******************************************************************************/
void proto_uart_init(void)
{
    4288:	fe010113          	addi	sp,sp,-32
    428c:	00112e23          	sw	ra,28(sp)
    Uart_Config config;

    config.dataLength   = BITS_8;   /* 8 位数据 */
    4290:	00800793          	li	a5,8
    4294:	00f12023          	sw	a5,0(sp)
    config.parity       = NONE;     /* 无校验 */
    4298:	00012223          	sw	zero,4(sp)
    config.stop         = ONE;      /* 1 位停止位 */
    429c:	00012423          	sw	zero,8(sp)
    /* 分频系数 = 时钟频率 / (波特率 × 每字符位数) - 1
     * 这里的算式与 bsp.h 里 bsp_init() 的一字不差。*/
    config.clockDivider = BSP_CLINT_HZ / (BSP_UART_BAUDRATE * BSP_UART_DATA_LEN) - 1;
    42a0:	03500793          	li	a5,53
    42a4:	00f12623          	sw	a5,12(sp)

    uart_applyConfig(PROTO_UART_BASE, &config);
    42a8:	00010593          	mv	a1,sp
    42ac:	f8002537          	lui	a0,0xf8002
    42b0:	eddff0ef          	jal	418c <uart_applyConfig>

    /* 清空接收环和计数。*/
    s_head = 0U;
    42b4:	9001a423          	sw	zero,-1784(gp) # b0b8 <s_head>
    s_tail = 0U;
    42b8:	9001a223          	sw	zero,-1788(gp) # b0b4 <s_tail>
    s_dropped = 0U;
    42bc:	9001a023          	sw	zero,-1792(gp) # b0b0 <s_dropped>
    s_fifo_overflow_seen = 0U;
    42c0:	9001a623          	sw	zero,-1780(gp) # b0bc <s_fifo_overflow_seen>
    42c4:	f80027b7          	lui	a5,0xf8002
    42c8:	00200713          	li	a4,2
    42cc:	00e7a823          	sw	a4,16(a5) # f8002010 <__freertos_irq_stack_top+0xf7ff1e10>
    /* 上电时硬件里可能留有之前（比如复位前）的溢出标志，先清掉，
     * 否则第一份汇总就会报一个不属于本次运行的溢出。*/
    write_u32(UART_ERR_READ_OVERFLOW, PROTO_UART_BASE + UART_ERROR_REG);

    /* 使能"接收 FIFO 非空"中断：FIFO 里一有数据就产生中断。*/
    uart_RX_NotemptyInterruptEna(PROTO_UART_BASE, 1);
    42d0:	00100593          	li	a1,1
    42d4:	f8002537          	lui	a0,0xf8002
    42d8:	ef5ff0ef          	jal	41cc <uart_RX_NotemptyInterruptEna>

    /* 把该中断接到本核（CPU 0）上。
     * threshold = 0 表示"优先级高于 0 的中断都接受"，即全部接受。
     * 这三步（threshold / enable / priority）是 PLIC 的标准配置顺序。*/
    plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0);
    42dc:	00000613          	li	a2,0
    42e0:	00000593          	li	a1,0
    42e4:	f8c00537          	lui	a0,0xf8c00
    42e8:	f89ff0ef          	jal	4270 <plic_set_threshold>
    plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0,
    42ec:	00100693          	li	a3,1
    42f0:	00200613          	li	a2,2
    42f4:	00000593          	li	a1,0
    42f8:	f8c00537          	lui	a0,0xf8c00
    42fc:	f29ff0ef          	jal	4224 <plic_set_enable>
                    SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT, 1);
    plic_set_priority(BSP_PLIC, SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT, 1);
    4300:	00100613          	li	a2,1
    4304:	00200593          	li	a1,2
    4308:	f8c00537          	lui	a0,0xf8c00
    430c:	f09ff0ef          	jal	4214 <plic_set_priority>
}
    4310:	01c12083          	lw	ra,28(sp)
    4314:	02010113          	addi	sp,sp,32
    4318:	00008067          	ret

0000431c <proto_uart_rx_pop>:
*       如果先推进指针再读数据，中断可能在这两步之间又写入了新字节，我们就会
*       读到下一个字节、把当前这个漏掉。
******************************************************************************/
int proto_uart_rx_pop(uint8_t *byte)
{
    if (s_head == s_tail) {
    431c:	9081a703          	lw	a4,-1784(gp) # b0b8 <s_head>
    4320:	9041a783          	lw	a5,-1788(gp) # b0b4 <s_tail>
    4324:	02f70a63          	beq	a4,a5,4358 <proto_uart_rx_pop+0x3c>
        return 0;              /* 环空 */
    }
    *byte = s_ring[s_tail];
    4328:	9041a683          	lw	a3,-1788(gp) # b0b4 <s_tail>
    432c:	0000f7b7          	lui	a5,0xf
    4330:	c7478793          	addi	a5,a5,-908 # ec74 <s_ring>
    4334:	00d787b3          	add	a5,a5,a3
    4338:	0007c783          	lbu	a5,0(a5)
    433c:	00f50023          	sb	a5,0(a0) # f8c00000 <__freertos_irq_stack_top+0xf8befe00>
    s_tail = (s_tail + 1U) & (PROTO_RX_RING_SIZE - 1U);
    4340:	9041a783          	lw	a5,-1788(gp) # b0b4 <s_tail>
    4344:	00178793          	addi	a5,a5,1
    4348:	1ff7f793          	andi	a5,a5,511
    434c:	90f1a223          	sw	a5,-1788(gp) # b0b4 <s_tail>
    return 1;
    4350:	00100513          	li	a0,1
    4354:	00008067          	ret
        return 0;              /* 环空 */
    4358:	00000513          	li	a0,0
}
    435c:	00008067          	ret

00004360 <proto_uart_rx_dropped>:
/******************************************************************************
* @brief 因接收环满而丢弃的字节数。
******************************************************************************/
uint32_t proto_uart_rx_dropped(void)
{
    return s_dropped;
    4360:	9001a503          	lw	a0,-1792(gp) # b0b0 <s_dropped>
}
    4364:	00008067          	ret

00004368 <proto_uart_fifo_overflow>:
        return *((volatile u32*) address);
    4368:	f80027b7          	lui	a5,0xf8002
    436c:	01078793          	addi	a5,a5,16 # f8002010 <__freertos_irq_stack_top+0xf7ff1e10>
    4370:	0007a783          	lw	a5,0(a5)
******************************************************************************/
uint32_t proto_uart_fifo_overflow(void)
{
    uint32_t err = read_u32(PROTO_UART_BASE + UART_ERROR_REG);

    if ((err & UART_ERR_READ_OVERFLOW) != 0U) {
    4374:	0027f793          	andi	a5,a5,2
    4378:	00078e63          	beqz	a5,4394 <proto_uart_fifo_overflow+0x2c>
        s_fifo_overflow_seen++;
    437c:	90c1a783          	lw	a5,-1780(gp) # b0bc <s_fifo_overflow_seen>
    4380:	00178793          	addi	a5,a5,1
    4384:	90f1a623          	sw	a5,-1780(gp) # b0bc <s_fifo_overflow_seen>
        *((volatile u32*) address) = data;
    4388:	f80027b7          	lui	a5,0xf8002
    438c:	00200713          	li	a4,2
    4390:	00e7a823          	sw	a4,16(a5) # f8002010 <__freertos_irq_stack_top+0xf7ff1e10>
        /* 写 1 清零（不是读-改-写：这个寄存器是"写 1 清除对应标志"的语义）。*/
        write_u32(UART_ERR_READ_OVERFLOW, PROTO_UART_BASE + UART_ERROR_REG);
    }
    return s_fifo_overflow_seen;
}
    4394:	90c1a503          	lw	a0,-1780(gp) # b0bc <s_fifo_overflow_seen>
    4398:	00008067          	ret

0000439c <proto_uart_isr>:
*
* @note 中断服务程序里只做"搬字节"这一件事，不做解析、不做任何输出。
*       解析放在主循环（见 main.c），这样中断的执行时间恒定且极短。
******************************************************************************/
void proto_uart_isr(void)
{
    439c:	ff010113          	addi	sp,sp,-16
    43a0:	00112623          	sw	ra,12(sp)
    uint32_t status;

    /* 第一步：读出状态寄存器，把"接收非空中断使能"这一位清掉（屏蔽中断源）。*/
    status = uart_status_read(PROTO_UART_BASE);
    43a4:	f8002537          	lui	a0,0xf8002
    43a8:	e15ff0ef          	jal	41bc <uart_status_read>
    uart_status_write(PROTO_UART_BASE,
    43ac:	0fd57593          	andi	a1,a0,253
    43b0:	f8002537          	lui	a0,0xf8002
    43b4:	e11ff0ef          	jal	41c4 <uart_status_write>
                      (char)(status & ~UART_STATUS_RX_NOTEMPTY_INT_EN));

    /* 第二步：把 FIFO 里现有的字节全部搬进接收环。*/
    while (uart_readOccupancy(PROTO_UART_BASE) != 0U) {
    43b8:	0100006f          	j	43c8 <proto_uart_isr+0x2c>
        uint32_t next = (s_head + 1U) & (PROTO_RX_RING_SIZE - 1U);

        if (next == s_tail) {
            /* 写指针再前进就会追上读指针，说明环满了。丢掉这个字节并计数。
             * 注意这里**不推进** s_head——推进了就等于覆盖掉还没被读走的数据。*/
            s_dropped++;
    43bc:	9001a783          	lw	a5,-1792(gp) # b0b0 <s_dropped>
    43c0:	00178793          	addi	a5,a5,1
    43c4:	90f1a023          	sw	a5,-1792(gp) # b0b0 <s_dropped>
    while (uart_readOccupancy(PROTO_UART_BASE) != 0U) {
    43c8:	f8002537          	lui	a0,0xf8002
    43cc:	d81ff0ef          	jal	414c <uart_readOccupancy>
    43d0:	02050e63          	beqz	a0,440c <proto_uart_isr+0x70>
        uint8_t  b    = (uint8_t)uart_read(PROTO_UART_BASE);
    43d4:	f8002537          	lui	a0,0xf8002
    43d8:	d81ff0ef          	jal	4158 <uart_read>
        uint32_t next = (s_head + 1U) & (PROTO_RX_RING_SIZE - 1U);
    43dc:	9081a783          	lw	a5,-1784(gp) # b0b8 <s_head>
    43e0:	00178793          	addi	a5,a5,1
    43e4:	1ff7f793          	andi	a5,a5,511
        if (next == s_tail) {
    43e8:	9041a703          	lw	a4,-1788(gp) # b0b4 <s_tail>
    43ec:	fcf708e3          	beq	a4,a5,43bc <proto_uart_isr+0x20>
        } else {
            s_ring[s_head] = b;
    43f0:	9081a603          	lw	a2,-1784(gp) # b0b8 <s_head>
    43f4:	0000f737          	lui	a4,0xf
    43f8:	c7470713          	addi	a4,a4,-908 # ec74 <s_ring>
    43fc:	00c70733          	add	a4,a4,a2
    4400:	00a70023          	sb	a0,0(a4)
            s_head = next;
    4404:	90f1a423          	sw	a5,-1784(gp) # b0b8 <s_head>
    4408:	fc1ff06f          	j	43c8 <proto_uart_isr+0x2c>
    /* 第三步：重新使能中断，准备接收下一批。
     * 重新读一次状态寄存器再置位，而不是直接用第一步读到的 status：
     * 因为排空过程中硬件可能改了状态寄存器里的其它位（比如溢出标志），
     * 用旧值回写会把这些变化抹掉。*/
    uart_status_write(PROTO_UART_BASE,
                      (char)(uart_status_read(PROTO_UART_BASE) |
    440c:	f8002537          	lui	a0,0xf8002
    4410:	dadff0ef          	jal	41bc <uart_status_read>
    uart_status_write(PROTO_UART_BASE,
    4414:	00256593          	ori	a1,a0,2
    4418:	0ff5f593          	zext.b	a1,a1
    441c:	f8002537          	lui	a0,0xf8002
    4420:	da5ff0ef          	jal	41c4 <uart_status_write>
                             UART_STATUS_RX_NOTEMPTY_INT_EN));
}
    4424:	00c12083          	lw	ra,12(sp)
    4428:	01010113          	addi	sp,sp,16
    442c:	00008067          	ret

00004430 <proto_uart_write>:
int proto_uart_write(const uint8_t *data, uint32_t len)
{
    uint32_t i;
    uint32_t guard;

    if (data == 0) {
    4430:	06050663          	beqz	a0,449c <proto_uart_write+0x6c>
{
    4434:	fe010113          	addi	sp,sp,-32
    4438:	00112e23          	sw	ra,28(sp)
    443c:	00812c23          	sw	s0,24(sp)
    4440:	00912a23          	sw	s1,20(sp)
    4444:	01212823          	sw	s2,16(sp)
    4448:	01312623          	sw	s3,12(sp)
    444c:	00050913          	mv	s2,a0
    4450:	00058993          	mv	s3,a1
        return 0;
    }

    for (i = 0U; i < len; i++) {
    4454:	00000493          	li	s1,0
    4458:	0180006f          	j	4470 <proto_uart_write+0x40>
            guard--;
        }
        /* 直接把字节写到 UART 的数据寄存器。用 write_u32（来自 driver/io.h）
         * 而不是给指针赋值，是为了沿用 driver 里统一的"内存映射寄存器访问"
         * 写法，将来若要加内存屏障之类只需改一处。*/
        write_u32(data[i], PROTO_UART_BASE + UART_DATA);
    445c:	009907b3          	add	a5,s2,s1
    4460:	0007c703          	lbu	a4,0(a5)
    4464:	f80027b7          	lui	a5,0xf8002
    4468:	00e7a023          	sw	a4,0(a5) # f8002000 <__freertos_irq_stack_top+0xf7ff1e00>
    for (i = 0U; i < len; i++) {
    446c:	00148493          	addi	s1,s1,1
    4470:	0334f263          	bgeu	s1,s3,4494 <proto_uart_write+0x64>
        guard = PROTO_TX_TIMEOUT_SPINS;
    4474:	00018437          	lui	s0,0x18
    4478:	6a040413          	addi	s0,s0,1696 # 186a0 <__freertos_irq_stack_top+0x84a0>
        while (uart_writeAvailability(PROTO_UART_BASE) == 0U) {
    447c:	f8002537          	lui	a0,0xf8002
    4480:	cbdff0ef          	jal	413c <uart_writeAvailability>
    4484:	fc051ce3          	bnez	a0,445c <proto_uart_write+0x2c>
            if (guard == 0U) {
    4488:	00040e63          	beqz	s0,44a4 <proto_uart_write+0x74>
            guard--;
    448c:	fff40413          	addi	s0,s0,-1
    4490:	fedff06f          	j	447c <proto_uart_write+0x4c>
    }
    return 1;
    4494:	00100513          	li	a0,1
    4498:	0100006f          	j	44a8 <proto_uart_write+0x78>
        return 0;
    449c:	00000513          	li	a0,0
}
    44a0:	00008067          	ret
                return 0;   /* 等太久了，放弃这一帧的剩余部分 */
    44a4:	00000513          	li	a0,0
}
    44a8:	01c12083          	lw	ra,28(sp)
    44ac:	01812403          	lw	s0,24(sp)
    44b0:	01412483          	lw	s1,20(sp)
    44b4:	01012903          	lw	s2,16(sp)
    44b8:	00c12983          	lw	s3,12(sp)
    44bc:	02010113          	addi	sp,sp,32
    44c0:	00008067          	ret

000044c4 <crc16_ccitt_update>:
     * 会先"整型提升"成 int，左移 8 位后还是 int，直接和 uint16_t 异或虽然结果
     * 正确，但中间类型带符号、语义不清晰。显式转型让每一步的类型都一目了然。
     *
     * 最外层的 (uint16_t) 是为了把结果截断回 16 位。RTL 里 c 就是 16 位寄存器，
     * 溢出自然丢弃高位；C 里必须显式截断才能和 RTL 完全一致。*/
    uint16_t c = (uint16_t)(crc ^ (uint16_t)((uint16_t)data << 8));
    44c4:	00859593          	slli	a1,a1,0x8
    44c8:	00a5c533          	xor	a0,a1,a0
     *
     * 为什么不用查表法（预生成 256 项的表，一次处理一个字节）：
     * 查表要占 512 字节常量空间，而本模块的调用频率是"每个 body 字节一次"，
     * 在 115200 波特率下每秒最多一万多次，逐位法（每字节 8 次循环）绰绰有余。
     * 用一点 CPU 换掉 512 字节 Flash，对软核更划算。*/
    for (n = 0; n < 8; n++) {
    44cc:	00000793          	li	a5,0
    44d0:	0140006f          	j	44e4 <crc16_ccitt_update+0x20>
        if ((c & 0x8000U) != 0U) {
            /* 0x8000 就是只保留 bit15 的掩码。用 & 判断而不是写成 (c >> 15)，
             * 是为了和 RTL 的 c[15] 取值写法更贴近。*/
            c = (uint16_t)((uint16_t)(c << 1) ^ CRC16_CCITT_POLY);
        } else {
            c = (uint16_t)(c << 1);
    44d4:	00151513          	slli	a0,a0,0x1
    44d8:	01051513          	slli	a0,a0,0x10
    44dc:	01055513          	srli	a0,a0,0x10
    for (n = 0; n < 8; n++) {
    44e0:	00178793          	addi	a5,a5,1
    44e4:	00700713          	li	a4,7
    44e8:	02f74663          	blt	a4,a5,4514 <crc16_ccitt_update+0x50>
        if ((c & 0x8000U) != 0U) {
    44ec:	01051713          	slli	a4,a0,0x10
    44f0:	41075713          	srai	a4,a4,0x10
    44f4:	fe0750e3          	bgez	a4,44d4 <crc16_ccitt_update+0x10>
            c = (uint16_t)((uint16_t)(c << 1) ^ CRC16_CCITT_POLY);
    44f8:	00151513          	slli	a0,a0,0x1
    44fc:	01051513          	slli	a0,a0,0x10
    4500:	01055513          	srli	a0,a0,0x10
    4504:	00001737          	lui	a4,0x1
    4508:	02170713          	addi	a4,a4,33 # 1021 <smp_slave+0x9>
    450c:	00e54533          	xor	a0,a0,a4
    4510:	fd1ff06f          	j	44e0 <crc16_ccitt_update+0x1c>
        }
    }
    return c;
}
    4514:	00008067          	ret

00004518 <handler_not_implemented>:
static uint8_t handler_not_implemented(const frame_t *frame, uint8_t *out,
                                       uint16_t *out_len)
{
    (void)frame;
    (void)out;
    *out_len = 0U;
    4518:	00061023          	sh	zero,0(a2)
    return PROTOCOL_STATUS_FAIL;
}
    451c:	00000513          	li	a0,0
    4520:	00008067          	ret

00004524 <handler_ui_not_in_scope>:
static uint8_t handler_ui_not_in_scope(const frame_t *frame, uint8_t *out,
                                       uint16_t *out_len)
{
    (void)frame;
    (void)out;
    *out_len = 0U;
    4524:	00061023          	sh	zero,0(a2)
    return PROTOCOL_STATUS_FAIL;
}
    4528:	00000513          	li	a0,0
    452c:	00008067          	ret

00004530 <category_lookup>:
******************************************************************************/
static const protocol_category_t *category_lookup(uint8_t category)
{
    uint32_t i;

    for (i = 0U; i < CATEGORY_ENTRIES; i++) {
    4530:	00000793          	li	a5,0
    4534:	00100713          	li	a4,1
    4538:	02f76e63          	bltu	a4,a5,4574 <category_lookup+0x44>
        if (s_categories[i].category == category) {
    453c:	00009737          	lui	a4,0x9
    4540:	00179693          	slli	a3,a5,0x1
    4544:	00f686b3          	add	a3,a3,a5
    4548:	00269693          	slli	a3,a3,0x2
    454c:	5b070713          	addi	a4,a4,1456 # 95b0 <s_categories>
    4550:	00d70733          	add	a4,a4,a3
    4554:	00074703          	lbu	a4,0(a4)
    4558:	00a70663          	beq	a4,a0,4564 <category_lookup+0x34>
    for (i = 0U; i < CATEGORY_ENTRIES; i++) {
    455c:	00178793          	addi	a5,a5,1
    4560:	fd5ff06f          	j	4534 <category_lookup+0x4>
            return &s_categories[i];
    4564:	000097b7          	lui	a5,0x9
    4568:	5b078793          	addi	a5,a5,1456 # 95b0 <s_categories>
    456c:	00f68533          	add	a0,a3,a5
    4570:	00008067          	ret
        }
    }
    return 0;
    4574:	00000513          	li	a0,0
}
    4578:	00008067          	ret

0000457c <table_lookup>:
* @note 线性查找而不是二分或哈希：掩膜表 5 行、UI 表 8 行，几次比较的开销可以
*       忽略，而线性代码最简单、最不容易写错。
******************************************************************************/
static const protocol_entry_t *table_lookup(const protocol_category_t *cat,
                                            uint8_t command)
{
    457c:	00050713          	mv	a4,a0
    uint32_t i;

    for (i = 0U; i < cat->count; i++) {
    4580:	00000793          	li	a5,0
    4584:	0080006f          	j	458c <table_lookup+0x10>
    4588:	00178793          	addi	a5,a5,1
    458c:	00872683          	lw	a3,8(a4)
    4590:	00d7fe63          	bgeu	a5,a3,45ac <table_lookup+0x30>
        if (cat->entries[i].command == command) {
    4594:	00472503          	lw	a0,4(a4)
    4598:	00479693          	slli	a3,a5,0x4
    459c:	00d50533          	add	a0,a0,a3
    45a0:	00054683          	lbu	a3,0(a0) # f8002000 <__freertos_irq_stack_top+0xf7ff1e00>
    45a4:	feb692e3          	bne	a3,a1,4588 <table_lookup+0xc>
    45a8:	00008067          	ret
            return &cat->entries[i];
        }
    }
    return 0;
    45ac:	00000513          	li	a0,0
}
    45b0:	00008067          	ret

000045b4 <entry_length_ok>:
* @param body_length 帧里声明的 body 长度。
* @return 1 表示相符。
******************************************************************************/
static int entry_length_ok(const protocol_entry_t *entry, uint16_t body_length)
{
    if (entry->body_length == LEN_ANY) {
    45b4:	00255783          	lhu	a5,2(a0)
    45b8:	00010737          	lui	a4,0x10
    45bc:	fff70713          	addi	a4,a4,-1 # ffff <_end+0xdff>
    45c0:	00e78863          	beq	a5,a4,45d0 <entry_length_ok+0x1c>
        return (body_length >= entry->min_length) ? 1 : 0;
    }
    return (body_length == entry->body_length) ? 1 : 0;
    45c4:	40b78533          	sub	a0,a5,a1
    45c8:	00153513          	seqz	a0,a0
}
    45cc:	00008067          	ret
        return (body_length >= entry->min_length) ? 1 : 0;
    45d0:	00455503          	lhu	a0,4(a0)
    45d4:	00a5b5b3          	sltu	a1,a1,a0
    45d8:	0015b513          	seqz	a0,a1
    45dc:	00008067          	ret

000045e0 <build_ack_common>:
*       加运行时检查只会掩盖"有人把 UI_QUERY_PAYLOAD_LEN 改大了"这个真问题。
******************************************************************************/
static uint16_t build_ack_common(uint8_t *ack, uint8_t category, uint8_t command,
                                 uint8_t status, const uint8_t *payload,
                                 uint16_t payload_len)
{
    45e0:	fd010113          	addi	sp,sp,-48
    45e4:	02112623          	sw	ra,44(sp)
    45e8:	02812423          	sw	s0,40(sp)
    45ec:	02912223          	sw	s1,36(sp)
    45f0:	03212023          	sw	s2,32(sp)
    45f4:	01312e23          	sw	s3,28(sp)
    45f8:	01412c23          	sw	s4,24(sp)
    45fc:	01512a23          	sw	s5,20(sp)
    4600:	01612823          	sw	s6,16(sp)
    4604:	01712623          	sw	s7,12(sp)
    4608:	00050913          	mv	s2,a0
    460c:	00058b93          	mv	s7,a1
    4610:	00060a93          	mv	s5,a2
    4614:	00068a13          	mv	s4,a3
    4618:	00070993          	mv	s3,a4
    461c:	00078493          	mv	s1,a5
    uint16_t crc = 0U;
    uint16_t body_len;
    uint16_t i;

    body_len = (uint16_t)(4U + payload_len);
    4620:	00478b13          	addi	s6,a5,4
    4624:	010b1b13          	slli	s6,s6,0x10
    4628:	010b5b13          	srli	s6,s6,0x10

    crc = crc16_ccitt_update(crc, category);
    462c:	00000513          	li	a0,0
    4630:	e95ff0ef          	jal	44c4 <crc16_ccitt_update>
    crc = crc16_ccitt_update(crc, command);
    4634:	000a8593          	mv	a1,s5
    4638:	e8dff0ef          	jal	44c4 <crc16_ccitt_update>
    crc = crc16_ccitt_update(crc, PROTOCOL_ACK_TYPE);
    463c:	00200593          	li	a1,2
    4640:	e85ff0ef          	jal	44c4 <crc16_ccitt_update>
    crc = crc16_ccitt_update(crc, status);
    4644:	000a0593          	mv	a1,s4
    4648:	e7dff0ef          	jal	44c4 <crc16_ccitt_update>
    for (i = 0U; i < payload_len; i++) {
    464c:	00000413          	li	s0,0
    4650:	01c0006f          	j	466c <build_ack_common+0x8c>
        crc = crc16_ccitt_update(crc, payload[i]);
    4654:	008987b3          	add	a5,s3,s0
    4658:	0007c583          	lbu	a1,0(a5)
    465c:	e69ff0ef          	jal	44c4 <crc16_ccitt_update>
    for (i = 0U; i < payload_len; i++) {
    4660:	00140413          	addi	s0,s0,1
    4664:	01041413          	slli	s0,s0,0x10
    4668:	01045413          	srli	s0,s0,0x10
    466c:	fe9464e3          	bltu	s0,s1,4654 <build_ack_common+0x74>
    }

    ack[0] = FRAME_HEADER;                 /* 帧头 0xBB */
    4670:	fbb00793          	li	a5,-69
    4674:	00f90023          	sb	a5,0(s2)
    ack[1] = (uint8_t)(body_len >> 8);     /* body_length 高字节 */
    4678:	008b5793          	srli	a5,s6,0x8
    467c:	00f900a3          	sb	a5,1(s2)
    ack[2] = (uint8_t)(body_len & 0xFFU);  /* body_length 低字节 */
    4680:	01690123          	sb	s6,2(s2)
    ack[3] = category;                     /* 应答体第 0 字节：回显大类 */
    4684:	017901a3          	sb	s7,3(s2)
    ack[4] = command;                      /* 应答体第 1 字节：回显子项 */
    4688:	01590223          	sb	s5,4(s2)
    ack[5] = PROTOCOL_ACK_TYPE;            /* 应答体第 2 字节：0x02 表示应答 */
    468c:	00200793          	li	a5,2
    4690:	00f902a3          	sb	a5,5(s2)
    ack[6] = status;                       /* 应答体第 3 字节 */
    4694:	01490323          	sb	s4,6(s2)
    for (i = 0U; i < payload_len; i++) {
    4698:	00000693          	li	a3,0
    469c:	0240006f          	j	46c0 <build_ack_common+0xe0>
        ack[7U + i] = payload[i];
    46a0:	00768613          	addi	a2,a3,7
    46a4:	00c90633          	add	a2,s2,a2
    46a8:	00d987b3          	add	a5,s3,a3
    46ac:	0007c783          	lbu	a5,0(a5)
    46b0:	00f60023          	sb	a5,0(a2)
    for (i = 0U; i < payload_len; i++) {
    46b4:	00168693          	addi	a3,a3,1
    46b8:	01069693          	slli	a3,a3,0x10
    46bc:	0106d693          	srli	a3,a3,0x10
    46c0:	fe96e0e3          	bltu	a3,s1,46a0 <build_ack_common+0xc0>
    }
    ack[7U + payload_len] = (uint8_t)(crc >> 8);      /* CRC 高字节 */
    46c4:	00748793          	addi	a5,s1,7
    46c8:	00f907b3          	add	a5,s2,a5
    46cc:	00855713          	srli	a4,a0,0x8
    46d0:	00e78023          	sb	a4,0(a5)
    ack[8U + payload_len] = (uint8_t)(crc & 0xFFU);   /* CRC 低字节 */
    46d4:	00848793          	addi	a5,s1,8
    46d8:	00f907b3          	add	a5,s2,a5
    46dc:	00a78023          	sb	a0,0(a5)
    ack[9U + payload_len] = FRAME_FOOTER;             /* 帧尾 0xAA */
    46e0:	00948793          	addi	a5,s1,9
    46e4:	00f90933          	add	s2,s2,a5
    46e8:	faa00793          	li	a5,-86
    46ec:	00f90023          	sb	a5,0(s2)

    return (uint16_t)(10U + payload_len);
    46f0:	00a48513          	addi	a0,s1,10
}
    46f4:	01051513          	slli	a0,a0,0x10
    46f8:	01055513          	srli	a0,a0,0x10
    46fc:	02c12083          	lw	ra,44(sp)
    4700:	02812403          	lw	s0,40(sp)
    4704:	02412483          	lw	s1,36(sp)
    4708:	02012903          	lw	s2,32(sp)
    470c:	01c12983          	lw	s3,28(sp)
    4710:	01812a03          	lw	s4,24(sp)
    4714:	01412a83          	lw	s5,20(sp)
    4718:	01012b03          	lw	s6,16(sp)
    471c:	00c12b83          	lw	s7,12(sp)
    4720:	03010113          	addi	sp,sp,48
    4724:	00008067          	ret

00004728 <handler_ui_query_view>:
{
    4728:	ff010113          	addi	sp,sp,-16
    472c:	00112623          	sw	ra,12(sp)
    4730:	00812423          	sw	s0,8(sp)
    4734:	00060413          	mv	s0,a2
    (void)ui_query_view(out);
    4738:	00058513          	mv	a0,a1
    473c:	058010ef          	jal	5794 <ui_query_view>
    *out_len = UI_QUERY_PAYLOAD_LEN;
    4740:	00800793          	li	a5,8
    4744:	00f41023          	sh	a5,0(s0)
}
    4748:	0ff00513          	li	a0,255
    474c:	00c12083          	lw	ra,12(sp)
    4750:	00812403          	lw	s0,8(sp)
    4754:	01010113          	addi	sp,sp,16
    4758:	00008067          	ret

0000475c <handler_ui_set_image_values>:
{
    475c:	ff010113          	addi	sp,sp,-16
    4760:	00112623          	sw	ra,12(sp)
    *out_len = 0U;
    4764:	00061023          	sh	zero,0(a2)
    return (ui_set_image_values(frame->payload) == 0) ? PROTOCOL_STATUS_OK
    4768:	00c50513          	addi	a0,a0,12
    476c:	795000ef          	jal	5700 <ui_set_image_values>
                                                      : PROTOCOL_STATUS_FAIL;
    4770:	00050a63          	beqz	a0,4784 <handler_ui_set_image_values+0x28>
    4774:	00000513          	li	a0,0
}
    4778:	00c12083          	lw	ra,12(sp)
    477c:	01010113          	addi	sp,sp,16
    4780:	00008067          	ret
                                                      : PROTOCOL_STATUS_FAIL;
    4784:	0ff00513          	li	a0,255
    4788:	ff1ff06f          	j	4778 <handler_ui_set_image_values+0x1c>

0000478c <handler_ui_set_view>:
{
    478c:	ff010113          	addi	sp,sp,-16
    4790:	00112623          	sw	ra,12(sp)
    *out_len = 0U;                    /* SET_VIEW 的应答是定长 10 字节 */
    4794:	00061023          	sh	zero,0(a2)
    page_id = (uint16_t)(((uint16_t)frame->payload[0] << 8) |
    4798:	00c54783          	lbu	a5,12(a0)
                          (uint16_t)frame->payload[1]);
    479c:	00d54703          	lbu	a4,13(a0)
    page_id = (uint16_t)(((uint16_t)frame->payload[0] << 8) |
    47a0:	00879793          	slli	a5,a5,0x8
    return (ui_set_view(page_id, sel, flags) == 0) ? PROTOCOL_STATUS_OK
    47a4:	00f54603          	lbu	a2,15(a0)
    47a8:	00e54583          	lbu	a1,14(a0)
    47ac:	00f76533          	or	a0,a4,a5
    47b0:	67d000ef          	jal	562c <ui_set_view>
                                                   : PROTOCOL_STATUS_FAIL;
    47b4:	00050a63          	beqz	a0,47c8 <handler_ui_set_view+0x3c>
    47b8:	00000513          	li	a0,0
}
    47bc:	00c12083          	lw	ra,12(sp)
    47c0:	01010113          	addi	sp,sp,16
    47c4:	00008067          	ret
                                                   : PROTOCOL_STATUS_FAIL;
    47c8:	0ff00513          	li	a0,255
    47cc:	ff1ff06f          	j	47bc <handler_ui_set_view+0x30>

000047d0 <protocol_init>:
    if (stats == 0) {
    47d0:	00050863          	beqz	a0,47e0 <protocol_init+0x10>
    stats->accepted_count = 0U;
    47d4:	00052023          	sw	zero,0(a0)
    stats->bad_packet_count = 0U;
    47d8:	00052223          	sw	zero,4(a0)
    stats->other_category_count = 0U;
    47dc:	00052423          	sw	zero,8(a0)
}
    47e0:	00008067          	ret

000047e4 <protocol_build_ack>:

void protocol_build_ack(uint8_t *ack, uint8_t category, uint8_t command,
                        uint8_t status)
{
    if (ack == 0) {
    47e4:	02050263          	beqz	a0,4808 <protocol_build_ack+0x24>
{
    47e8:	ff010113          	addi	sp,sp,-16
    47ec:	00112623          	sw	ra,12(sp)
        return;
    }
    (void)build_ack_common(ack, category, command, status, 0, 0U);
    47f0:	00000793          	li	a5,0
    47f4:	00000713          	li	a4,0
    47f8:	de9ff0ef          	jal	45e0 <build_ack_common>
}
    47fc:	00c12083          	lw	ra,12(sp)
    4800:	01010113          	addi	sp,sp,16
    4804:	00008067          	ret
    4808:	00008067          	ret

0000480c <protocol_build_ack_payload>:

uint16_t protocol_build_ack_payload(uint8_t *ack, uint8_t category, uint8_t command,
                                    uint8_t status, const uint8_t *payload,
                                    uint16_t payload_len)
{
    if (ack == 0) {
    480c:	00050e63          	beqz	a0,4828 <protocol_build_ack_payload+0x1c>
{
    4810:	ff010113          	addi	sp,sp,-16
    4814:	00112623          	sw	ra,12(sp)
        return 0U;
    }
    return build_ack_common(ack, category, command, status, payload, payload_len);
    4818:	dc9ff0ef          	jal	45e0 <build_ack_common>
}
    481c:	00c12083          	lw	ra,12(sp)
    4820:	01010113          	addi	sp,sp,16
    4824:	00008067          	ret
        return 0U;
    4828:	00000513          	li	a0,0
}
    482c:	00008067          	ret

00004830 <protocol_handle>:
*           子项确实是发给本端点的，只是本期不实现；计成坏包会让链路上真实
*           存在的工具帧把坏包率顶高）。
******************************************************************************/
void protocol_handle(protocol_stats_t *stats, const frame_t *frame,
                     protocol_response_t *response)
{
    4830:	fd010113          	addi	sp,sp,-48
    4834:	02112623          	sw	ra,44(sp)
    const protocol_category_t *cat;
    const protocol_entry_t *entry;
    /* 应答体的参数段。8 字节是编译期常量（UI_QUERY_PAYLOAD_LEN），
     * 只有 QUERY_VIEW 会用到，其余子项 out_len 都是 0。*/
    uint8_t  out[UI_QUERY_PAYLOAD_LEN];
    uint16_t out_len = 0U;
    4838:	00011323          	sh	zero,6(sp)

    if ((stats == 0) || (frame == 0) || (response == 0)) {
    483c:	0c050e63          	beqz	a0,4918 <protocol_handle+0xe8>
    4840:	02812423          	sw	s0,40(sp)
    4844:	02912223          	sw	s1,36(sp)
    4848:	03212023          	sw	s2,32(sp)
    484c:	00050913          	mv	s2,a0
    4850:	00058493          	mv	s1,a1
    4854:	00060413          	mv	s0,a2
    4858:	20058263          	beqz	a1,4a5c <protocol_handle+0x22c>
    485c:	20060863          	beqz	a2,4a6c <protocol_handle+0x23c>
    }

    /* 先给出默认结论：不发应答、失败、子项名未知。
     * 先把"最保守的默认值"铺好，后面每个分支只需要覆盖它要改的字段，
     * 这样就不会出现"某个分支漏填了某字段、结果带着上一次的残留值发出去"。*/
    response->send_ack = 0;
    4860:	000609a3          	sb	zero,19(a2)
    response->defer_ack = 0;
    4864:	00060a23          	sb	zero,20(a2)
    response->status = PROTOCOL_STATUS_FAIL;
    4868:	00060aa3          	sb	zero,21(a2)
    response->reason = PROTO_REASON_BAD_INTEGRITY;
    486c:	00200793          	li	a5,2
    4870:	00f62c23          	sw	a5,24(a2)
    response->command_name = "?";
    4874:	000097b7          	lui	a5,0x9
    4878:	f1c78793          	addi	a5,a5,-228 # 8f1c <_data+0x588>
    487c:	00f62e23          	sw	a5,28(a2)
    response->ack_len = 0U;
    4880:	00060923          	sb	zero,18(a2)

    /* 第 1 关：完整性。CRC 或帧尾任一不对，就认为帧被破坏了。
     * 不应答——理由见函数头。*/
    if ((frame->crc_ok == 0U) || (frame->footer_ok == 0U)) {
    4884:	0065c783          	lbu	a5,6(a1)
    4888:	06078c63          	beqz	a5,4900 <protocol_handle+0xd0>
    488c:	0075c783          	lbu	a5,7(a1)
    4890:	06078863          	beqz	a5,4900 <protocol_handle+0xd0>
    }

    /* 第 2 关：大类归属。不归本端点管的大类（电子变倍 0x01、热点 0x02、
     * 伪彩色 0x03）既不该执行也不该应答，只记一笔"收到过其它大类的帧"，
     * 便于诊断链路上都有谁在说话。*/
    cat = category_lookup(frame->category);
    4894:	0005c503          	lbu	a0,0(a1)
    4898:	c99ff0ef          	jal	4530 <category_lookup>
    if (cat == 0) {
    489c:	08050463          	beqz	a0,4924 <protocol_handle+0xf4>
        return;
    }

    /* 从这一步起，帧确定是本端点的了：**默认每一个都会得到应答**。
     * 唯一的例外是 UI 的 0x01–0x05，它们在下面第 6 关把 send_ack 改回 0。*/
    response->send_ack = 1;
    48a0:	00100793          	li	a5,1
    48a4:	00f409a3          	sb	a5,19(s0)

    /* 第 3 关：类型字段必须是"上位机写"。*/
    if (frame->format_ok == 0U) {
    48a8:	0084c783          	lbu	a5,8(s1)
    48ac:	08079e63          	bnez	a5,4948 <protocol_handle+0x118>
        response->reason = PROTO_REASON_BAD_FORMAT;
    48b0:	00300793          	li	a5,3
    48b4:	00f42c23          	sw	a5,24(s0)
        stats->bad_packet_count++;
    48b8:	00492783          	lw	a5,4(s2)
    48bc:	00178793          	addi	a5,a5,1
    48c0:	00f92223          	sw	a5,4(s2)
    /* 构造应答。只有"大类归本端点、完整性通过、且该子项要应答"才需要发。
     * 大类和子项原样回显，这样上位机能按自己发过的命令去核对。
     *
     * 参数段为空时走定长 10 字节那一支 —— 两条路都落到同一个 build_ack_common，
     * 所以 CRC 覆盖范围与字节序只有一处实现。*/
    if (response->send_ack != 0) {
    48c4:	01344783          	lbu	a5,19(s0)
    48c8:	1a078a63          	beqz	a5,4a7c <protocol_handle+0x24c>
        if (out_len == 0U) {
    48cc:	00615783          	lhu	a5,6(sp)
    48d0:	16079063          	bnez	a5,4a30 <protocol_handle+0x200>
            protocol_build_ack(response->ack, frame->category, frame->command,
    48d4:	01544683          	lbu	a3,21(s0)
    48d8:	0014c603          	lbu	a2,1(s1)
    48dc:	0004c583          	lbu	a1,0(s1)
    48e0:	00040513          	mv	a0,s0
    48e4:	f01ff0ef          	jal	47e4 <protocol_build_ack>
                               response->status);
            response->ack_len = PROTOCOL_ACK_LEN;
    48e8:	00a00793          	li	a5,10
    48ec:	00f40923          	sb	a5,18(s0)
    48f0:	02812403          	lw	s0,40(sp)
    48f4:	02412483          	lw	s1,36(sp)
    48f8:	02012903          	lw	s2,32(sp)
    48fc:	01c0006f          	j	4918 <protocol_handle+0xe8>
        stats->bad_packet_count++;
    4900:	00492783          	lw	a5,4(s2)
    4904:	00178793          	addi	a5,a5,1
    4908:	00f92223          	sw	a5,4(s2)
        return;
    490c:	02812403          	lw	s0,40(sp)
    4910:	02412483          	lw	s1,36(sp)
    4914:	02012903          	lw	s2,32(sp)
            response->ack_len = (uint8_t)protocol_build_ack_payload(
                response->ack, frame->category, frame->command,
                response->status, out, out_len);
        }
    }
}
    4918:	02c12083          	lw	ra,44(sp)
    491c:	03010113          	addi	sp,sp,48
    4920:	00008067          	ret
        response->reason = PROTO_REASON_OTHER_CATEGORY;
    4924:	00100793          	li	a5,1
    4928:	00f42c23          	sw	a5,24(s0)
        stats->other_category_count++;
    492c:	00892783          	lw	a5,8(s2)
    4930:	00178793          	addi	a5,a5,1
    4934:	00f92423          	sw	a5,8(s2)
        return;
    4938:	02812403          	lw	s0,40(sp)
    493c:	02412483          	lw	s1,36(sp)
    4940:	02012903          	lw	s2,32(sp)
    4944:	fd5ff06f          	j	4918 <protocol_handle+0xe8>
    4948:	01312e23          	sw	s3,28(sp)
        entry = table_lookup(cat, frame->command);
    494c:	0014c583          	lbu	a1,1(s1)
    4950:	c2dff0ef          	jal	457c <table_lookup>
    4954:	00050993          	mv	s3,a0
        if (entry == 0) {
    4958:	02050a63          	beqz	a0,498c <protocol_handle+0x15c>
            response->command_name = entry->name;
    495c:	00852783          	lw	a5,8(a0)
    4960:	00f42e23          	sw	a5,28(s0)
            if (entry_length_ok(entry, frame->body_length) == 0) {
    4964:	0044d583          	lhu	a1,4(s1)
    4968:	c4dff0ef          	jal	45b4 <entry_length_ok>
    496c:	02051e63          	bnez	a0,49a8 <protocol_handle+0x178>
                response->reason = PROTO_REASON_BAD_LENGTH;
    4970:	00500793          	li	a5,5
    4974:	00f42c23          	sw	a5,24(s0)
                stats->bad_packet_count++;
    4978:	00492783          	lw	a5,4(s2)
    497c:	00178793          	addi	a5,a5,1
    4980:	00f92223          	sw	a5,4(s2)
    4984:	01c12983          	lw	s3,28(sp)
    4988:	f3dff06f          	j	48c4 <protocol_handle+0x94>
            response->reason = PROTO_REASON_UNKNOWN_COMMAND;
    498c:	00400793          	li	a5,4
    4990:	00f42c23          	sw	a5,24(s0)
            stats->bad_packet_count++;
    4994:	00492783          	lw	a5,4(s2)
    4998:	00178793          	addi	a5,a5,1
    499c:	00f92223          	sw	a5,4(s2)
    49a0:	01c12983          	lw	s3,28(sp)
    49a4:	f21ff06f          	j	48c4 <protocol_handle+0x94>
            } else if (entry->reply == 0U) {
    49a8:	0069c783          	lbu	a5,6(s3)
    49ac:	02079063          	bnez	a5,49cc <protocol_handle+0x19c>
                response->send_ack = 0;
    49b0:	000409a3          	sb	zero,19(s0)
                response->reason = PROTO_REASON_UI_IGNORED;
    49b4:	00700793          	li	a5,7
    49b8:	00f42c23          	sw	a5,24(s0)
                response->command_name = entry->name;
    49bc:	0089a783          	lw	a5,8(s3)
    49c0:	00f42e23          	sw	a5,28(s0)
    49c4:	01c12983          	lw	s3,28(sp)
    49c8:	efdff06f          	j	48c4 <protocol_handle+0x94>
                stats->accepted_count++;
    49cc:	00092783          	lw	a5,0(s2)
    49d0:	00178793          	addi	a5,a5,1
    49d4:	00f92023          	sw	a5,0(s2)
                response->status = entry->handler(frame, out, &out_len);
    49d8:	00c9a783          	lw	a5,12(s3)
    49dc:	00610613          	addi	a2,sp,6
    49e0:	00810593          	addi	a1,sp,8
    49e4:	00048513          	mv	a0,s1
    49e8:	000780e7          	jalr	a5
    49ec:	00a40aa3          	sb	a0,21(s0)
                if (response->status == PROTOCOL_STATUS_OK) {
    49f0:	0ff00793          	li	a5,255
    49f4:	00f50a63          	beq	a0,a5,4a08 <protocol_handle+0x1d8>
                    response->reason = PROTO_REASON_NOT_IMPLEMENTED;
    49f8:	00600793          	li	a5,6
    49fc:	00f42c23          	sw	a5,24(s0)
    4a00:	01c12983          	lw	s3,28(sp)
    4a04:	ec1ff06f          	j	48c4 <protocol_handle+0x94>
                    response->reason = PROTO_REASON_OK;
    4a08:	00042c23          	sw	zero,24(s0)
                    response->defer_ack = entry->defer;
    4a0c:	0079c783          	lbu	a5,7(s3)
    4a10:	00f40a23          	sb	a5,20(s0)
                    if (entry->defer != 0U) {
    4a14:	00078a63          	beqz	a5,4a28 <protocol_handle+0x1f8>
                        response->reason = PROTO_REASON_DEFERRED;
    4a18:	00800793          	li	a5,8
    4a1c:	00f42c23          	sw	a5,24(s0)
    4a20:	01c12983          	lw	s3,28(sp)
    4a24:	ea1ff06f          	j	48c4 <protocol_handle+0x94>
    4a28:	01c12983          	lw	s3,28(sp)
    4a2c:	e99ff06f          	j	48c4 <protocol_handle+0x94>
            response->ack_len = (uint8_t)protocol_build_ack_payload(
    4a30:	00810713          	addi	a4,sp,8
    4a34:	01544683          	lbu	a3,21(s0)
    4a38:	0014c603          	lbu	a2,1(s1)
    4a3c:	0004c583          	lbu	a1,0(s1)
    4a40:	00040513          	mv	a0,s0
    4a44:	dc9ff0ef          	jal	480c <protocol_build_ack_payload>
    4a48:	00a40923          	sb	a0,18(s0)
    4a4c:	02812403          	lw	s0,40(sp)
    4a50:	02412483          	lw	s1,36(sp)
    4a54:	02012903          	lw	s2,32(sp)
    4a58:	ec1ff06f          	j	4918 <protocol_handle+0xe8>
    4a5c:	02812403          	lw	s0,40(sp)
    4a60:	02412483          	lw	s1,36(sp)
    4a64:	02012903          	lw	s2,32(sp)
    4a68:	eb1ff06f          	j	4918 <protocol_handle+0xe8>
    4a6c:	02812403          	lw	s0,40(sp)
    4a70:	02412483          	lw	s1,36(sp)
    4a74:	02012903          	lw	s2,32(sp)
    4a78:	ea1ff06f          	j	4918 <protocol_handle+0xe8>
    4a7c:	02812403          	lw	s0,40(sp)
    4a80:	02412483          	lw	s1,36(sp)
    4a84:	02012903          	lw	s2,32(sp)
    4a88:	e91ff06f          	j	4918 <protocol_handle+0xe8>

00004a8c <reg_write>:
* @note volatile 不能省：这几条写是**有副作用**的（RTL 侧会据此改行为），
*       没有 volatile 编译器有权把它们优化掉或合并。
******************************************************************************/
static void reg_write(uint32_t off, uint32_t val)
{
    *(volatile uint32_t *)(OSD_REG_BASE + off) = val;
    4a8c:	e10437b7          	lui	a5,0xe1043
    4a90:	00f50533          	add	a0,a0,a5
    4a94:	00b52023          	sw	a1,0(a0)
}
    4a98:	00008067          	ret

00004a9c <reg_read>:
* @note 同样要 volatile：地址里的值会被 RTL 随时改动（applied_* 在帧边界更新），
*       没有 volatile 编译器可以把两次读合并成一次。
******************************************************************************/
static uint32_t reg_read(uint32_t off)
{
    return *(volatile uint32_t *)(OSD_REG_BASE + off);
    4a9c:	e10437b7          	lui	a5,0xe1043
    4aa0:	00f50533          	add	a0,a0,a5
    4aa4:	00052503          	lw	a0,0(a0)
}
    4aa8:	00008067          	ret

00004aac <canvas_select_block>:

void canvas_select_block(int idx) { s_block = (idx == 1) ? 1 : 0; }
    4aac:	fff50513          	addi	a0,a0,-1
    4ab0:	00153513          	seqz	a0,a0
    4ab4:	92a1a023          	sw	a0,-1760(gp) # b0d0 <s_block>
    4ab8:	00008067          	ret

00004abc <canvas_set_visible>:

void canvas_set_visible(int on) { s_visible = (on != 0) ? 1 : 0; }
    4abc:	00a03533          	snez	a0,a0
    4ac0:	90a1ae23          	sw	a0,-1764(gp) # b0cc <s_visible>
    4ac4:	00008067          	ret

00004ac8 <canvas_write>:
*       也是 RTL 侧按字节读回时看到的顺序。写反了画面会变成每 4 个像素
*       一组错位 —— 这种错在"看起来像图像噪声"里最难认。
******************************************************************************/
void canvas_write(uint32_t off, const uint8_t *src, uint32_t len)
{
    volatile uint8_t *dst = (volatile uint8_t *)((s_block ? OSD_BLOCK1_ADDR
    4ac8:	9201a783          	lw	a5,-1760(gp) # b0d0 <s_block>
                                                          : OSD_BLOCK0_ADDR) + off);
    4acc:	02078663          	beqz	a5,4af8 <canvas_write+0x30>
    4ad0:	00b40837          	lui	a6,0xb40
    4ad4:	00a80833          	add	a6,a6,a0
    uint32_t i = 0U;

    if (src == 0) {
    4ad8:	08058263          	beqz	a1,4b5c <canvas_write+0x94>
        return;
    }

    s_bytes_written += len;
    4adc:	9101a783          	lw	a5,-1776(gp) # b0c0 <s_bytes_written>
    4ae0:	00c787b3          	add	a5,a5,a2
    4ae4:	90f1a823          	sw	a5,-1776(gp) # b0c0 <s_bytes_written>

    if ((off & 3U) == 0U) {
    4ae8:	00357513          	andi	a0,a0,3
    4aec:	00050a63          	beqz	a0,4b00 <canvas_write+0x38>
    uint32_t i = 0U;
    4af0:	00000513          	li	a0,0
    4af4:	0640006f          	j	4b58 <canvas_write+0x90>
                                                          : OSD_BLOCK0_ADDR) + off);
    4af8:	00a40837          	lui	a6,0xa40
    4afc:	fd9ff06f          	j	4ad4 <canvas_write+0xc>
        for (; i + 4U <= len; i += 4U) {
    4b00:	00450893          	addi	a7,a0,4
    4b04:	05166a63          	bltu	a2,a7,4b58 <canvas_write+0x90>
            uint32_t w = (uint32_t)src[i]
    4b08:	00a58733          	add	a4,a1,a0
    4b0c:	00074783          	lbu	a5,0(a4)
                       | ((uint32_t)src[i + 1U] << 8)
    4b10:	00174683          	lbu	a3,1(a4)
    4b14:	00869693          	slli	a3,a3,0x8
    4b18:	00d7e7b3          	or	a5,a5,a3
                       | ((uint32_t)src[i + 2U] << 16)
    4b1c:	00274683          	lbu	a3,2(a4)
    4b20:	01069693          	slli	a3,a3,0x10
    4b24:	00d7e7b3          	or	a5,a5,a3
                       | ((uint32_t)src[i + 3U] << 24);
    4b28:	00374703          	lbu	a4,3(a4)
    4b2c:	01871713          	slli	a4,a4,0x18
            uint32_t w = (uint32_t)src[i]
    4b30:	00e7e7b3          	or	a5,a5,a4
            *(volatile uint32_t *)(dst + i) = w;
    4b34:	00a80533          	add	a0,a6,a0
    4b38:	00f52023          	sw	a5,0(a0)
        for (; i + 4U <= len; i += 4U) {
    4b3c:	00088513          	mv	a0,a7
    4b40:	fc1ff06f          	j	4b00 <canvas_write+0x38>
        }
    }
    for (; i < len; i++) {
        dst[i] = src[i];
    4b44:	00a807b3          	add	a5,a6,a0
    4b48:	00a58733          	add	a4,a1,a0
    4b4c:	00074703          	lbu	a4,0(a4)
    4b50:	00e78023          	sb	a4,0(a5) # e1043000 <__freertos_irq_stack_top+0xe1032e00>
    for (; i < len; i++) {
    4b54:	00150513          	addi	a0,a0,1
    4b58:	fec566e3          	bltu	a0,a2,4b44 <canvas_write+0x7c>
    }
}
    4b5c:	00008067          	ret

00004b60 <canvas_fill>:
*
* @note 清屏是 14,144 字节 × 2 块，走整字能把事务数从 28,288 降到 7,072。
******************************************************************************/
void canvas_fill(uint32_t off, uint8_t v, uint32_t len)
{
    volatile uint8_t *dst = (volatile uint8_t *)((s_block ? OSD_BLOCK1_ADDR
    4b60:	9201a783          	lw	a5,-1760(gp) # b0d0 <s_block>
                                                          : OSD_BLOCK0_ADDR) + off);
    4b64:	02078463          	beqz	a5,4b8c <canvas_fill+0x2c>
    4b68:	00b40737          	lui	a4,0xb40
    4b6c:	00a70733          	add	a4,a4,a0
    uint32_t i = 0U;

    s_bytes_written += len;
    4b70:	9101a783          	lw	a5,-1776(gp) # b0c0 <s_bytes_written>
    4b74:	00c787b3          	add	a5,a5,a2
    4b78:	90f1a823          	sw	a5,-1776(gp) # b0c0 <s_bytes_written>

    if ((off & 3U) == 0U) {
    4b7c:	00357513          	andi	a0,a0,3
    4b80:	00050a63          	beqz	a0,4b94 <canvas_fill+0x34>
    uint32_t i = 0U;
    4b84:	00000513          	li	a0,0
    4b88:	0480006f          	j	4bd0 <canvas_fill+0x70>
                                                          : OSD_BLOCK0_ADDR) + off);
    4b8c:	00a40737          	lui	a4,0xa40
    4b90:	fddff06f          	j	4b6c <canvas_fill+0xc>
        uint32_t pat = (uint32_t)v | ((uint32_t)v << 8)
    4b94:	00859693          	slli	a3,a1,0x8
    4b98:	00b686b3          	add	a3,a3,a1
                     | ((uint32_t)v << 16) | ((uint32_t)v << 24);
    4b9c:	01059793          	slli	a5,a1,0x10
    4ba0:	00f6e6b3          	or	a3,a3,a5
    4ba4:	01859793          	slli	a5,a1,0x18
        uint32_t pat = (uint32_t)v | ((uint32_t)v << 8)
    4ba8:	00f6e6b3          	or	a3,a3,a5
        for (; i + 4U <= len; i += 4U) {
    4bac:	00450793          	addi	a5,a0,4
    4bb0:	02f66063          	bltu	a2,a5,4bd0 <canvas_fill+0x70>
            *(volatile uint32_t *)(dst + i) = pat;
    4bb4:	00a70533          	add	a0,a4,a0
    4bb8:	00d52023          	sw	a3,0(a0)
        for (; i + 4U <= len; i += 4U) {
    4bbc:	00078513          	mv	a0,a5
    4bc0:	fedff06f          	j	4bac <canvas_fill+0x4c>
        }
    }
    for (; i < len; i++) {
        dst[i] = v;
    4bc4:	00a707b3          	add	a5,a4,a0
    4bc8:	00b78023          	sb	a1,0(a5)
    for (; i < len; i++) {
    4bcc:	00150513          	addi	a0,a0,1
    4bd0:	fec56ae3          	bltu	a0,a2,4bc4 <canvas_fill+0x64>
    }
}
    4bd4:	00008067          	ret

00004bd8 <canvas_commit>:
* @note 提交是"置位即返回"，不等 pending 清、不读 ack：RTL 在帧边界整体切换。
*       要确认生效就读 STATUS 的 pending 位（本工程目前不需要，
*       因为下一步操作都在帧率尺度之外）。
******************************************************************************/
void canvas_commit(void)
{
    4bd8:	ff010113          	addi	sp,sp,-16
    4bdc:	00112623          	sw	ra,12(sp)
    4be0:	00812423          	sw	s0,8(sp)
    uint32_t ctrl = (s_visible ? OSD_CTRL_ENABLE : 0U)
    4be4:	91c1a783          	lw	a5,-1764(gp) # b0cc <s_visible>
    4be8:	04078e63          	beqz	a5,4c44 <canvas_commit+0x6c>
    4bec:	00100413          	li	s0,1
                  | (s_block   ? OSD_CTRL_BUFFER : 0U);
    4bf0:	9201a783          	lw	a5,-1760(gp) # b0d0 <s_block>
    4bf4:	04078c63          	beqz	a5,4c4c <canvas_commit+0x74>
    4bf8:	00200793          	li	a5,2
    uint32_t ctrl = (s_visible ? OSD_CTRL_ENABLE : 0U)
    4bfc:	00f46433          	or	s0,s0,a5
    uint32_t pos = ((uint32_t)((uint32_t)OSD_MENU_TOP & 0xFFFU) << 12)
                 |  (uint32_t)((uint32_t)OSD_MENU_LEFT & 0xFFFU);

    /* 先记下这一组值再写下去：POS/CTRL 只写、回读恒 0，事后想看"写了什么"
     * 就只有这一份记录（见 canvas_read_regs）。*/
    s_pos_written  = pos;
    4c00:	000b85b7          	lui	a1,0xb8
    4c04:	05858593          	addi	a1,a1,88 # b8058 <__freertos_irq_stack_top+0xa7e58>
    4c08:	90b1ac23          	sw	a1,-1768(gp) # b0c8 <s_pos_written>
    s_ctrl_written = ctrl;
    4c0c:	9081aa23          	sw	s0,-1772(gp) # b0c4 <s_ctrl_written>

    reg_write(OSD_REG_POS(OSD_MENU_ROUTE), pos);
    4c10:	01800513          	li	a0,24
    4c14:	e79ff0ef          	jal	4a8c <reg_write>
    reg_write(OSD_REG_CTRL(OSD_MENU_ROUTE), ctrl);
    4c18:	00040593          	mv	a1,s0
    4c1c:	01c00513          	li	a0,28
    4c20:	e6dff0ef          	jal	4a8c <reg_write>
    reg_write(OSD_REG_COMMAND, OSD_CMD_COMMIT | OSD_CMD_GLOBAL_EN);
    4c24:	800005b7          	lui	a1,0x80000
    4c28:	00158593          	addi	a1,a1,1 # 80000001 <__freertos_irq_stack_top+0x7ffefe01>
    4c2c:	00000513          	li	a0,0
    4c30:	e5dff0ef          	jal	4a8c <reg_write>
}
    4c34:	00c12083          	lw	ra,12(sp)
    4c38:	00812403          	lw	s0,8(sp)
    4c3c:	01010113          	addi	sp,sp,16
    4c40:	00008067          	ret
    uint32_t ctrl = (s_visible ? OSD_CTRL_ENABLE : 0U)
    4c44:	00000413          	li	s0,0
    4c48:	fa9ff06f          	j	4bf0 <canvas_commit+0x18>
                  | (s_block   ? OSD_CTRL_BUFFER : 0U);
    4c4c:	00000793          	li	a5,0
    4c50:	fadff06f          	j	4bfc <canvas_commit+0x24>

00004c54 <canvas_read_regs>:
*       POS/CTRL 也照读一遍并保留在结构体里：它们的值应当恒为 0，打出来
*       正是为了证明"只写"这件事在板级也成立。
******************************************************************************/
void canvas_read_regs(canvas_regs_t *out)
{
    if (out == 0) {
    4c54:	06050e63          	beqz	a0,4cd0 <canvas_read_regs+0x7c>
{
    4c58:	ff010113          	addi	sp,sp,-16
    4c5c:	00112623          	sw	ra,12(sp)
    4c60:	00812423          	sw	s0,8(sp)
    4c64:	00050413          	mv	s0,a0
        return;
    }

    out->command   = reg_read(OSD_REG_COMMAND);
    4c68:	00000513          	li	a0,0
    4c6c:	e31ff0ef          	jal	4a9c <reg_read>
    4c70:	00a42023          	sw	a0,0(s0)
    out->status    = reg_read(OSD_REG_STATUS);
    4c74:	00400513          	li	a0,4
    4c78:	e25ff0ef          	jal	4a9c <reg_read>
    4c7c:	00a42223          	sw	a0,4(s0)
    out->canvas    = reg_read(OSD_REG_CANVAS);
    4c80:	00800513          	li	a0,8
    4c84:	e19ff0ef          	jal	4a9c <reg_read>
    4c88:	00a42423          	sw	a0,8(s0)
    out->active    = reg_read(OSD_REG_ACTIVE);
    4c8c:	00c00513          	li	a0,12
    4c90:	e0dff0ef          	jal	4a9c <reg_read>
    4c94:	00a42623          	sw	a0,12(s0)
    out->pos_read  = reg_read(OSD_REG_POS(OSD_MENU_ROUTE));
    4c98:	01800513          	li	a0,24
    4c9c:	e01ff0ef          	jal	4a9c <reg_read>
    4ca0:	00a42823          	sw	a0,16(s0)
    out->ctrl_read = reg_read(OSD_REG_CTRL(OSD_MENU_ROUTE));
    4ca4:	01c00513          	li	a0,28
    4ca8:	df5ff0ef          	jal	4a9c <reg_read>
    4cac:	00a42a23          	sw	a0,20(s0)
    out->pos_last  = s_pos_written;
    4cb0:	9181a783          	lw	a5,-1768(gp) # b0c8 <s_pos_written>
    4cb4:	00f42c23          	sw	a5,24(s0)
    out->ctrl_last = s_ctrl_written;
    4cb8:	9141a783          	lw	a5,-1772(gp) # b0c4 <s_ctrl_written>
    4cbc:	00f42e23          	sw	a5,28(s0)
}
    4cc0:	00c12083          	lw	ra,12(sp)
    4cc4:	00812403          	lw	s0,8(sp)
    4cc8:	01010113          	addi	sp,sp,16
    4ccc:	00008067          	ret
    4cd0:	00008067          	ret

00004cd4 <canvas_read_block>:
*       读时也按这个顺序拆回去。写读不对称的话回读出来的图会每 4 字节一组
*       错位，而那种错在缩略图上表现为"整块花纹"、极难反推。
******************************************************************************/
uint32_t canvas_read_block(int idx, uint8_t *dst)
{
    volatile const uint32_t *src = (volatile const uint32_t *)
    4cd4:	00100793          	li	a5,1
    4cd8:	00f50a63          	beq	a0,a5,4cec <canvas_read_block+0x18>
    4cdc:	00a40837          	lui	a6,0xa40
        ((idx == 1) ? OSD_BLOCK1_ADDR : OSD_BLOCK0_ADDR);
    uint32_t i = 0U;

    if (dst == 0) {
    4ce0:	08058e63          	beqz	a1,4d7c <canvas_read_block+0xa8>
    uint32_t i = 0U;
    4ce4:	00000793          	li	a5,0
    4ce8:	0540006f          	j	4d3c <canvas_read_block+0x68>
    volatile const uint32_t *src = (volatile const uint32_t *)
    4cec:	00b40837          	lui	a6,0xb40
    4cf0:	ff1ff06f          	j	4ce0 <canvas_read_block+0xc>
        return 0U;
    }

    for (; i + 4U <= (uint32_t)OSD_BLOCK_BYTES; i += 4U) {
        uint32_t w = src[i >> 2];
    4cf4:	ffc7f713          	andi	a4,a5,-4
    4cf8:	00e80733          	add	a4,a6,a4
    4cfc:	00072703          	lw	a4,0(a4) # a40000 <__freertos_irq_stack_top+0xa2fe00>
        dst[i]      = (uint8_t)(w & 0xFFU);
    4d00:	00f586b3          	add	a3,a1,a5
    4d04:	00e68023          	sb	a4,0(a3)
        dst[i + 1U] = (uint8_t)((w >> 8) & 0xFFU);
    4d08:	00875513          	srli	a0,a4,0x8
    4d0c:	00178693          	addi	a3,a5,1
    4d10:	00d586b3          	add	a3,a1,a3
    4d14:	00a68023          	sb	a0,0(a3)
        dst[i + 2U] = (uint8_t)((w >> 16) & 0xFFU);
    4d18:	01075513          	srli	a0,a4,0x10
    4d1c:	00278693          	addi	a3,a5,2
    4d20:	00d586b3          	add	a3,a1,a3
    4d24:	00a68023          	sb	a0,0(a3)
        dst[i + 3U] = (uint8_t)((w >> 24) & 0xFFU);
    4d28:	00378793          	addi	a5,a5,3
    4d2c:	00f587b3          	add	a5,a1,a5
    4d30:	01875713          	srli	a4,a4,0x18
    4d34:	00e78023          	sb	a4,0(a5)
    for (; i + 4U <= (uint32_t)OSD_BLOCK_BYTES; i += 4U) {
    4d38:	00060793          	mv	a5,a2
    4d3c:	00478613          	addi	a2,a5,4
    4d40:	00003737          	lui	a4,0x3
    4d44:	74070713          	addi	a4,a4,1856 # 3740 <diag_probe_sticky+0x28>
    4d48:	fac776e3          	bgeu	a4,a2,4cf4 <canvas_read_block+0x20>
    4d4c:	0180006f          	j	4d64 <canvas_read_block+0x90>
    }
    for (; i < (uint32_t)OSD_BLOCK_BYTES; i++) {
        dst[i] = ((volatile const uint8_t *)src)[i];
    4d50:	00f806b3          	add	a3,a6,a5
    4d54:	00f58733          	add	a4,a1,a5
    4d58:	0006c683          	lbu	a3,0(a3)
    4d5c:	00d70023          	sb	a3,0(a4)
    for (; i < (uint32_t)OSD_BLOCK_BYTES; i++) {
    4d60:	00178793          	addi	a5,a5,1
    4d64:	00003737          	lui	a4,0x3
    4d68:	73f70713          	addi	a4,a4,1855 # 373f <diag_probe_sticky+0x27>
    4d6c:	fef772e3          	bgeu	a4,a5,4d50 <canvas_read_block+0x7c>
    }

    return (uint32_t)OSD_BLOCK_BYTES;
    4d70:	00003537          	lui	a0,0x3
    4d74:	74050513          	addi	a0,a0,1856 # 3740 <diag_probe_sticky+0x28>
    4d78:	00008067          	ret
        return 0U;
    4d7c:	00000513          	li	a0,0
}
    4d80:	00008067          	ret

00004d84 <canvas_peek>:
 * 诊断专用的裸访问与计数
 * ------------------------------------------------------------------------ */

uint32_t canvas_peek(uint32_t addr)
{
    return *(volatile uint32_t *)addr;
    4d84:	00052503          	lw	a0,0(a0)
}
    4d88:	00008067          	ret

00004d8c <canvas_poke>:
*       若有偏移也不会影响结论 —— 偏移会同时作用于写与读、往返照样成立；
*       往返**不成立**就说明写根本没落到那个位置（或读根本读不到）。
******************************************************************************/
uint32_t canvas_poke(uint32_t addr, uint32_t val)
{
    *(volatile uint32_t *)addr = val;
    4d8c:	00b52023          	sw	a1,0(a0)
    return *(volatile uint32_t *)addr;
    4d90:	00052503          	lw	a0,0(a0)
}
    4d94:	00008067          	ret

00004d98 <canvas_bytes_written>:

uint32_t canvas_bytes_written(void)
{
    return s_bytes_written;
}
    4d98:	9101a503          	lw	a0,-1776(gp) # b0c0 <s_bytes_written>
    4d9c:	00008067          	ret

00004da0 <render_and_commit>:
*         3) 渲染 —— 把字符网格（第 0 步的产物）展开成 1 bit/像素位图。
*         4) 提交 —— 置位后立即返回，由 RTL 在帧边界整体切换。
*       之后翻转后台块，下一次写另一块。
******************************************************************************/
static void render_and_commit(void)
{
    4da0:	ff010113          	addi	sp,sp,-16
    4da4:	00112623          	sw	ra,12(sp)
    4da8:	00812423          	sw	s0,8(sp)
    /* 第 0 步：状态 → 字符网格。少了它 composer 画的是一张空白网格
     * （见上面第 0 条的说明）。放在这里而不是各个调用点，是为了让
     * "凡是渲染，网格一定是最新的"成为结构性保证，而不是纪律。*/
    scene_build();
    4dac:	26d000ef          	jal	5818 <scene_build>

    canvas_set_visible(ui_is_visible());   /* 见上：必须排在 commit 之前 */
    4db0:	235000ef          	jal	57e4 <ui_is_visible>
    4db4:	d09ff0ef          	jal	4abc <canvas_set_visible>
    canvas_select_block(s_back);
    4db8:	92c1a503          	lw	a0,-1748(gp) # b0dc <s_back>
    4dbc:	cf1ff0ef          	jal	4aac <canvas_select_block>
    composer_render();
    4dc0:	128000ef          	jal	4ee8 <composer_render>
    canvas_commit();
    4dc4:	e15ff0ef          	jal	4bd8 <canvas_commit>

    s_back ^= 1;
    4dc8:	92c1a783          	lw	a5,-1748(gp) # b0dc <s_back>
    4dcc:	0017c793          	xori	a5,a5,1
    4dd0:	92f1a623          	sw	a5,-1748(gp) # b0dc <s_back>
    s_renders++;
    4dd4:	9281a783          	lw	a5,-1752(gp) # b0d8 <s_renders>
    4dd8:	00178793          	addi	a5,a5,1
    4ddc:	92f1a423          	sw	a5,-1752(gp) # b0d8 <s_renders>
    ui_clear_dirty();
    4de0:	229000ef          	jal	5808 <ui_clear_dirty>
}
    4de4:	00c12083          	lw	ra,12(sp)
    4de8:	00812403          	lw	s0,8(sp)
    4dec:	01010113          	addi	sp,sp,16
    4df0:	00008067          	ret

00004df4 <osd_engine_boot>:

void osd_engine_boot(void)
{
    4df4:	ff010113          	addi	sp,sp,-16
    4df8:	00112623          	sw	ra,12(sp)
    ui_init();
    4dfc:	7dc000ef          	jal	55d8 <ui_init>

    /* 两块都清零：位图是透明底，只清一块的话另一块上前台时会露出旧内容。 */
    canvas_select_block(0);
    4e00:	00000513          	li	a0,0
    4e04:	ca9ff0ef          	jal	4aac <canvas_select_block>
    canvas_fill(0U, 0U, (uint32_t)OSD_BLOCK_BYTES);
    4e08:	00003637          	lui	a2,0x3
    4e0c:	74060613          	addi	a2,a2,1856 # 3740 <diag_probe_sticky+0x28>
    4e10:	00000593          	li	a1,0
    4e14:	00000513          	li	a0,0
    4e18:	d49ff0ef          	jal	4b60 <canvas_fill>
    canvas_select_block(1);
    4e1c:	00100513          	li	a0,1
    4e20:	c8dff0ef          	jal	4aac <canvas_select_block>
    canvas_fill(0U, 0U, (uint32_t)OSD_BLOCK_BYTES);
    4e24:	00003637          	lui	a2,0x3
    4e28:	74060613          	addi	a2,a2,1856 # 3740 <diag_probe_sticky+0x28>
    4e2c:	00000593          	li	a1,0
    4e30:	00000513          	li	a0,0
    4e34:	d2dff0ef          	jal	4b60 <canvas_fill>

    s_back = 0;
    4e38:	9201a623          	sw	zero,-1748(gp) # b0dc <s_back>
    s_renders = 0;
    4e3c:	9201a423          	sw	zero,-1752(gp) # b0d8 <s_renders>
    s_last_deferred = 0;
    4e40:	9201a223          	sw	zero,-1756(gp) # b0d4 <s_last_deferred>
    render_and_commit();            /* 上电即有画面（P1 主菜单） */
    4e44:	f5dff0ef          	jal	4da0 <render_and_commit>
}
    4e48:	00c12083          	lw	ra,12(sp)
    4e4c:	01010113          	addi	sp,sp,16
    4e50:	00008067          	ret

00004e54 <osd_engine_handle>:

uint8_t osd_engine_handle(protocol_stats_t *stats, const frame_t *frame,
                          protocol_response_t *resp, uint8_t *ack)
{
    4e54:	ff010113          	addi	sp,sp,-16
    4e58:	00112623          	sw	ra,12(sp)
    4e5c:	00812423          	sw	s0,8(sp)
    4e60:	00912223          	sw	s1,4(sp)
    4e64:	00060413          	mv	s0,a2
    4e68:	00068493          	mv	s1,a3
    uint8_t n;

    s_last_deferred = 0;
    4e6c:	9201a223          	sw	zero,-1756(gp) # b0d4 <s_last_deferred>

    protocol_handle(stats, frame, resp);
    4e70:	9c1ff0ef          	jal	4830 <protocol_handle>
    if ((resp->send_ack == 0U) || (ack == 0)) {
    4e74:	01344503          	lbu	a0,19(s0)
    4e78:	04050a63          	beqz	a0,4ecc <osd_engine_handle+0x78>
    4e7c:	06048263          	beqz	s1,4ee0 <osd_engine_handle+0x8c>
        return 0U;
    }

    if (resp->defer_ack != 0U) {
    4e80:	01444783          	lbu	a5,20(s0)
    4e84:	00078e63          	beqz	a5,4ea0 <osd_engine_handle+0x4c>
        /* 成功且需要等画布：先把画面做出来、提交掉，再把应答交出去。
         * 失败时 handler 返回 FAIL，defer_ack 为 0，直接走下面那支立即回。 */
        render_and_commit();
    4e88:	f19ff0ef          	jal	4da0 <render_and_commit>
        s_last_deferred = 1;
    4e8c:	00100713          	li	a4,1
    4e90:	92e1a223          	sw	a4,-1756(gp) # b0d4 <s_last_deferred>
         * 触发；留着它是为了让"状态脏了就渲染"这条不变量在引擎层始终成立，
         * 将来加一条"改了状态但不要求延迟应答"的命令时不会静默丢一帧。*/
        render_and_commit();
    }

    n = resp->ack_len;
    4e94:	01244503          	lbu	a0,18(s0)
    {
        uint8_t i;
        for (i = 0U; i < n; i++) {
    4e98:	00000793          	li	a5,0
    4e9c:	02c0006f          	j	4ec8 <osd_engine_handle+0x74>
    } else if (ui_is_dirty()) {
    4ea0:	159000ef          	jal	57f8 <ui_is_dirty>
    4ea4:	fe0508e3          	beqz	a0,4e94 <osd_engine_handle+0x40>
        render_and_commit();
    4ea8:	ef9ff0ef          	jal	4da0 <render_and_commit>
    4eac:	fe9ff06f          	j	4e94 <osd_engine_handle+0x40>
            ack[i] = resp->ack[i];
    4eb0:	00f48733          	add	a4,s1,a5
    4eb4:	00f40633          	add	a2,s0,a5
    4eb8:	00064603          	lbu	a2,0(a2)
    4ebc:	00c70023          	sb	a2,0(a4)
        for (i = 0U; i < n; i++) {
    4ec0:	00178793          	addi	a5,a5,1
    4ec4:	0ff7f793          	zext.b	a5,a5
    4ec8:	fea7e4e3          	bltu	a5,a0,4eb0 <osd_engine_handle+0x5c>
        }
    }
    return n;
}
    4ecc:	00c12083          	lw	ra,12(sp)
    4ed0:	00812403          	lw	s0,8(sp)
    4ed4:	00412483          	lw	s1,4(sp)
    4ed8:	01010113          	addi	sp,sp,16
    4edc:	00008067          	ret
        return 0U;
    4ee0:	00000513          	li	a0,0
    4ee4:	fe9ff06f          	j	4ecc <osd_engine_handle+0x78>

00004ee8 <composer_render>:
#include "font.h"
#include "ui.h"
#include "osd_config.h"

void composer_render(void)
{
    4ee8:	f9010113          	addi	sp,sp,-112
    4eec:	06112623          	sw	ra,108(sp)
    4ef0:	06812423          	sw	s0,104(sp)
    4ef4:	06912223          	sw	s1,100(sp)
    4ef8:	07212023          	sw	s2,96(sp)
    4efc:	05312e23          	sw	s3,92(sp)
    4f00:	05412c23          	sw	s4,88(sp)
    4f04:	05512a23          	sw	s5,84(sp)
    /* 一行位图 = 68 字节。放在栈上：这与画布大小无关，永远只是两行的量级，
     * 不会因为将来改画布尺寸而变成一个大数组。*/
    uint8_t  line[OSD_ROW_STRIDE];
    unsigned r, c, gy;

    for (r = 0u; r < OSD_GRID_ROWS; r++) {
    4f08:	00000a93          	li	s5,0
    4f0c:	0ac0006f          	j	4fb8 <composer_render+0xd0>
                    line[c * 2u]      = OSD_PIXEL_KEY;
                    line[c * 2u + 1u] = OSD_PIXEL_KEY;
                    continue;
                }

                bits = font_row_bits(font_glyph(idx), gy);
    4f10:	140000ef          	jal	5050 <font_glyph>
    4f14:	00090593          	mv	a1,s2
    4f18:	160000ef          	jal	5078 <font_row_bits>

                /* 高字节在前：bit 15..8 先落盘，于是"bit 7 最左"这条位图约定
                 * 与"bit 15 最左"的字形约定自动对齐。*/
                line[c * 2u]      = (uint8_t)(bits >> 8);
    4f1c:	00855713          	srli	a4,a0,0x8
    4f20:	05040793          	addi	a5,s0,80
    4f24:	002787b3          	add	a5,a5,sp
    4f28:	fae78e23          	sb	a4,-68(a5)
                line[c * 2u + 1u] = (uint8_t)(bits & 0xFFu);
    4f2c:	05140793          	addi	a5,s0,81
    4f30:	00278433          	add	s0,a5,sp
    4f34:	faa40e23          	sb	a0,-68(s0)
            for (c = 0u; c < OSD_GRID_COLS; c++) {
    4f38:	00148493          	addi	s1,s1,1
    4f3c:	02100793          	li	a5,33
    4f40:	0497e063          	bltu	a5,s1,4f80 <composer_render+0x98>
                int idx = font_lookup(row_cells[c]);
    4f44:	00149413          	slli	s0,s1,0x1
    4f48:	008987b3          	add	a5,s3,s0
    4f4c:	0007d503          	lhu	a0,0(a5)
    4f50:	0b4000ef          	jal	5004 <font_lookup>
                if (idx < 0) idx = font_lookup((uint16_t)'?');
    4f54:	fa055ee3          	bgez	a0,4f10 <composer_render+0x28>
    4f58:	03f00513          	li	a0,63
    4f5c:	0a8000ef          	jal	5004 <font_lookup>
                if (idx < 0) {
    4f60:	fa0558e3          	bgez	a0,4f10 <composer_render+0x28>
                    line[c * 2u]      = OSD_PIXEL_KEY;
    4f64:	05040793          	addi	a5,s0,80
    4f68:	002787b3          	add	a5,a5,sp
    4f6c:	fa078e23          	sb	zero,-68(a5)
                    line[c * 2u + 1u] = OSD_PIXEL_KEY;
    4f70:	05140793          	addi	a5,s0,81
    4f74:	00278433          	add	s0,a5,sp
    4f78:	fa040e23          	sb	zero,-68(s0)
                    continue;
    4f7c:	fbdff06f          	j	4f38 <composer_render+0x50>
            }

            canvas_write((uint32_t)y * (uint32_t)OSD_ROW_STRIDE, line,
    4f80:	004a1513          	slli	a0,s4,0x4
    4f84:	01450533          	add	a0,a0,s4
    4f88:	04400613          	li	a2,68
    4f8c:	00c10593          	addi	a1,sp,12
    4f90:	00251513          	slli	a0,a0,0x2
    4f94:	b35ff0ef          	jal	4ac8 <canvas_write>
        for (gy = 0u; gy < OSD_GLYPH_H; gy++) {
    4f98:	00190913          	addi	s2,s2,1
    4f9c:	00f00793          	li	a5,15
    4fa0:	0127ea63          	bltu	a5,s2,4fb4 <composer_render+0xcc>
            unsigned y = r * OSD_GLYPH_H + gy;
    4fa4:	004a9a13          	slli	s4,s5,0x4
    4fa8:	012a0a33          	add	s4,s4,s2
            for (c = 0u; c < OSD_GRID_COLS; c++) {
    4fac:	00000493          	li	s1,0
    4fb0:	f8dff06f          	j	4f3c <composer_render+0x54>
    for (r = 0u; r < OSD_GRID_ROWS; r++) {
    4fb4:	001a8a93          	addi	s5,s5,1
    4fb8:	00c00793          	li	a5,12
    4fbc:	0357e263          	bltu	a5,s5,4fe0 <composer_render+0xf8>
        const cell_t *row_cells = osd_buf[r];
    4fc0:	004a9993          	slli	s3,s5,0x4
    4fc4:	015989b3          	add	s3,s3,s5
    4fc8:	00299993          	slli	s3,s3,0x2
    4fcc:	0000f7b7          	lui	a5,0xf
    4fd0:	e8c78793          	addi	a5,a5,-372 # ee8c <osd_buf>
    4fd4:	00f989b3          	add	s3,s3,a5
        for (gy = 0u; gy < OSD_GLYPH_H; gy++) {
    4fd8:	00000913          	li	s2,0
    4fdc:	fc1ff06f          	j	4f9c <composer_render+0xb4>
                         (uint32_t)OSD_ROW_STRIDE);
        }
    }
}
    4fe0:	06c12083          	lw	ra,108(sp)
    4fe4:	06812403          	lw	s0,104(sp)
    4fe8:	06412483          	lw	s1,100(sp)
    4fec:	06012903          	lw	s2,96(sp)
    4ff0:	05c12983          	lw	s3,92(sp)
    4ff4:	05812a03          	lw	s4,88(sp)
    4ff8:	05412a83          	lw	s5,84(sp)
    4ffc:	07010113          	addi	sp,sp,112
    5000:	00008067          	ret

00005004 <font_lookup>:
#include "font16_bin.h"

uint16_t font_count(void) { return (uint16_t)FONT16_COUNT; }

int font_lookup(uint16_t cp)
{
    5004:	00050593          	mv	a1,a0
    int lo = 0, hi = (int)FONT16_COUNT - 1;
    5008:	0aa00613          	li	a2,170
    500c:	00000693          	li	a3,0

    while (lo <= hi) {
    5010:	0080006f          	j	5018 <font_lookup+0x14>
        int mid = (lo + hi) >> 1;
        uint16_t v = font16_codepoints[mid];
        if (v == cp) return mid;
        if (v < cp) lo = mid + 1; else hi = mid - 1;
    5014:	fff50613          	addi	a2,a0,-1
    while (lo <= hi) {
    5018:	02d64863          	blt	a2,a3,5048 <font_lookup+0x44>
        int mid = (lo + hi) >> 1;
    501c:	00c68733          	add	a4,a3,a2
    5020:	40175513          	srai	a0,a4,0x1
        uint16_t v = font16_codepoints[mid];
    5024:	0000b7b7          	lui	a5,0xb
    5028:	ffe77713          	andi	a4,a4,-2
    502c:	bf878793          	addi	a5,a5,-1032 # abf8 <font16_codepoints>
    5030:	00e787b3          	add	a5,a5,a4
    5034:	0007d783          	lhu	a5,0(a5)
        if (v == cp) return mid;
    5038:	00b78a63          	beq	a5,a1,504c <font_lookup+0x48>
        if (v < cp) lo = mid + 1; else hi = mid - 1;
    503c:	fcb7fce3          	bgeu	a5,a1,5014 <font_lookup+0x10>
    5040:	00150693          	addi	a3,a0,1
    5044:	fd5ff06f          	j	5018 <font_lookup+0x14>
    }
    return -1;
    5048:	fff00513          	li	a0,-1
}
    504c:	00008067          	ret

00005050 <font_glyph>:

const uint8_t *font_glyph(int idx)
{
    if (idx < 0 || idx >= (int)FONT16_COUNT) return font16_bitmap[0];
    5050:	0aa00793          	li	a5,170
    5054:	00a7ec63          	bltu	a5,a0,506c <font_glyph+0x1c>
    return font16_bitmap[idx];
    5058:	00551513          	slli	a0,a0,0x5
    505c:	000097b7          	lui	a5,0x9
    5060:	69878793          	addi	a5,a5,1688 # 9698 <font16_bitmap>
    5064:	00f50533          	add	a0,a0,a5
    5068:	00008067          	ret
    if (idx < 0 || idx >= (int)FONT16_COUNT) return font16_bitmap[0];
    506c:	00009537          	lui	a0,0x9
    5070:	69850513          	addi	a0,a0,1688 # 9698 <font16_bitmap>
}
    5074:	00008067          	ret

00005078 <font_row_bits>:

uint16_t font_row_bits(const uint8_t *g, unsigned row)
{
    if (row >= OSD_GLYPH_H) row = OSD_GLYPH_H - 1u;   /* 越界保护：永远给合法数据 */
    5078:	00f00793          	li	a5,15
    507c:	00b7f463          	bgeu	a5,a1,5084 <font_row_bits+0xc>
    5080:	00f00593          	li	a1,15
    return (uint16_t)(((uint16_t)g[row * 2u] << 8) | g[row * 2u + 1u]);
    5084:	00159593          	slli	a1,a1,0x1
    5088:	00b50533          	add	a0,a0,a1
    508c:	00054783          	lbu	a5,0(a0)
    5090:	00154503          	lbu	a0,1(a0)
    5094:	00879793          	slli	a5,a5,0x8
}
    5098:	00f56533          	or	a0,a0,a5
    509c:	00008067          	ret

000050a0 <osd_utf8_seq_len>:

#define OSD_UTF8_BAD  0xFFFDu   /* 非法字节的替换码点 */

static unsigned osd_utf8_seq_len(unsigned char c)
{
    if (c < 0x80u) return 1u;
    50a0:	01851793          	slli	a5,a0,0x18
    50a4:	4187d793          	srai	a5,a5,0x18
    50a8:	0207d863          	bgez	a5,50d8 <osd_utf8_seq_len+0x38>
    if ((c & 0xE0u) == 0xC0u) return 2u;
    50ac:	0e057793          	andi	a5,a0,224
    50b0:	0c000713          	li	a4,192
    50b4:	02e78663          	beq	a5,a4,50e0 <osd_utf8_seq_len+0x40>
    if ((c & 0xF0u) == 0xE0u) return 3u;
    50b8:	0f057793          	andi	a5,a0,240
    50bc:	0e000713          	li	a4,224
    50c0:	02e78463          	beq	a5,a4,50e8 <osd_utf8_seq_len+0x48>
    if ((c & 0xF8u) == 0xF0u) return 4u;
    50c4:	0f857513          	andi	a0,a0,248
    50c8:	0f000793          	li	a5,240
    50cc:	02f50263          	beq	a0,a5,50f0 <osd_utf8_seq_len+0x50>
    return 0u;                       /* 孤立续字节：非法 */
    50d0:	00000513          	li	a0,0
    50d4:	00008067          	ret
    if (c < 0x80u) return 1u;
    50d8:	00100513          	li	a0,1
    50dc:	00008067          	ret
    if ((c & 0xE0u) == 0xC0u) return 2u;
    50e0:	00200513          	li	a0,2
    50e4:	00008067          	ret
    if ((c & 0xF0u) == 0xE0u) return 3u;
    50e8:	00300513          	li	a0,3
    50ec:	00008067          	ret
    if ((c & 0xF8u) == 0xF0u) return 4u;
    50f0:	00400513          	li	a0,4
}
    50f4:	00008067          	ret

000050f8 <osd_utf8_decode>:

/* 解码 s[0..] 处的一个字符；*adv = 消耗的字节数。
 * 调用方保证至少还剩 1 字节；不足按非法处理（前进 1 字节）。 */
static uint32_t osd_utf8_decode(const unsigned char *s, unsigned remain, unsigned *adv)
{
    50f8:	fe010113          	addi	sp,sp,-32
    50fc:	00112e23          	sw	ra,28(sp)
    5100:	00812c23          	sw	s0,24(sp)
    5104:	00912a23          	sw	s1,20(sp)
    5108:	01212823          	sw	s2,16(sp)
    510c:	01312623          	sw	s3,12(sp)
    5110:	00050493          	mv	s1,a0
    5114:	00058913          	mv	s2,a1
    5118:	00060993          	mv	s3,a2
    unsigned n = osd_utf8_seq_len(s[0]);
    511c:	00054403          	lbu	s0,0(a0)
    5120:	00040513          	mv	a0,s0
    5124:	f7dff0ef          	jal	50a0 <osd_utf8_seq_len>
    uint32_t cp;

    if (n == 0u || n > remain) { *adv = 1u; return OSD_UTF8_BAD; }
    5128:	04050e63          	beqz	a0,5184 <osd_utf8_decode+0x8c>
    512c:	00050793          	mv	a5,a0
    5130:	04a96a63          	bltu	s2,a0,5184 <osd_utf8_decode+0x8c>
    if (n > 3u) { *adv = n; return OSD_UTF8_BAD; }   /* 超出 BMP：字库不含 */
    5134:	00300713          	li	a4,3
    5138:	06a76063          	bltu	a4,a0,5198 <osd_utf8_decode+0xa0>

    switch (n) {
    513c:	00100713          	li	a4,1
    5140:	06e50463          	beq	a0,a4,51a8 <osd_utf8_decode+0xb0>
    5144:	00200713          	li	a4,2
    5148:	08e50263          	beq	a0,a4,51cc <osd_utf8_decode+0xd4>
    case 1u: cp = s[0]; break;
    case 2u: cp = ((uint32_t)(s[0] & 0x1Fu) << 6)  | (uint32_t)(s[1] & 0x3Fu); break;
    default: cp = ((uint32_t)(s[0] & 0x0Fu) << 12) | ((uint32_t)(s[1] & 0x3Fu) << 6)
    514c:	00c41413          	slli	s0,s0,0xc
    5150:	00010737          	lui	a4,0x10
    5154:	fff70713          	addi	a4,a4,-1 # ffff <_end+0xdff>
    5158:	00e47433          	and	s0,s0,a4
    515c:	0014c703          	lbu	a4,1(s1)
    5160:	00671713          	slli	a4,a4,0x6
    5164:	000016b7          	lui	a3,0x1
    5168:	fc068693          	addi	a3,a3,-64 # fc0 <CUSTOM2+0xf65>
    516c:	00d77733          	and	a4,a4,a3
    5170:	00e46433          	or	s0,s0,a4
                   | (uint32_t)(s[2] & 0x3Fu); break;
    5174:	0024c703          	lbu	a4,2(s1)
    5178:	03f77713          	andi	a4,a4,63
    default: cp = ((uint32_t)(s[0] & 0x0Fu) << 12) | ((uint32_t)(s[1] & 0x3Fu) << 6)
    517c:	00e46533          	or	a0,s0,a4
                   | (uint32_t)(s[2] & 0x3Fu); break;
    5180:	02c0006f          	j	51ac <osd_utf8_decode+0xb4>
    if (n == 0u || n > remain) { *adv = 1u; return OSD_UTF8_BAD; }
    5184:	00100793          	li	a5,1
    5188:	00f9a023          	sw	a5,0(s3)
    518c:	00010537          	lui	a0,0x10
    5190:	ffd50513          	addi	a0,a0,-3 # fffd <_end+0xdfd>
    5194:	01c0006f          	j	51b0 <osd_utf8_decode+0xb8>
    if (n > 3u) { *adv = n; return OSD_UTF8_BAD; }   /* 超出 BMP：字库不含 */
    5198:	00a9a023          	sw	a0,0(s3)
    519c:	00010537          	lui	a0,0x10
    51a0:	ffd50513          	addi	a0,a0,-3 # fffd <_end+0xdfd>
    51a4:	00c0006f          	j	51b0 <osd_utf8_decode+0xb8>
    case 1u: cp = s[0]; break;
    51a8:	00040513          	mv	a0,s0
    }
    *adv = n;
    51ac:	00f9a023          	sw	a5,0(s3)
    return cp;
}
    51b0:	01c12083          	lw	ra,28(sp)
    51b4:	01812403          	lw	s0,24(sp)
    51b8:	01412483          	lw	s1,20(sp)
    51bc:	01012903          	lw	s2,16(sp)
    51c0:	00c12983          	lw	s3,12(sp)
    51c4:	02010113          	addi	sp,sp,32
    51c8:	00008067          	ret
    case 2u: cp = ((uint32_t)(s[0] & 0x1Fu) << 6)  | (uint32_t)(s[1] & 0x3Fu); break;
    51cc:	00641413          	slli	s0,s0,0x6
    51d0:	7c047413          	andi	s0,s0,1984
    51d4:	0014c703          	lbu	a4,1(s1)
    51d8:	03f77713          	andi	a4,a4,63
    51dc:	00e46533          	or	a0,s0,a4
    51e0:	fcdff06f          	j	51ac <osd_utf8_decode+0xb4>

000051e4 <pick>:
*       编译期或独立配置项，那一列直接可用，不必回头补数据。
******************************************************************************/
static const char *pick(const i18n_t *s)
{
    return s->en;
}
    51e4:	00052503          	lw	a0,0(a0)
    51e8:	00008067          	ret

000051ec <grid_clear>:
* @note 全量重画语义的一部分：不清空的话，上一页残留的字符会在新页的空白处露出来。
******************************************************************************/
static void grid_clear(void)
{
    unsigned r, c;
    for (r = 0u; r < OSD_GRID_ROWS; r++)
    51ec:	00000593          	li	a1,0
    51f0:	03c0006f          	j	522c <grid_clear+0x40>
        for (c = 0u; c < OSD_GRID_COLS; c++)
            osd_buf[r][c] = (cell_t)' ';
    51f4:	0000f737          	lui	a4,0xf
    51f8:	00459693          	slli	a3,a1,0x4
    51fc:	00b686b3          	add	a3,a3,a1
    5200:	00169793          	slli	a5,a3,0x1
    5204:	00c787b3          	add	a5,a5,a2
    5208:	00179793          	slli	a5,a5,0x1
    520c:	e8c70713          	addi	a4,a4,-372 # ee8c <osd_buf>
    5210:	00f707b3          	add	a5,a4,a5
    5214:	02000713          	li	a4,32
    5218:	00e79023          	sh	a4,0(a5)
        for (c = 0u; c < OSD_GRID_COLS; c++)
    521c:	00160613          	addi	a2,a2,1
    5220:	02100793          	li	a5,33
    5224:	fcc7f8e3          	bgeu	a5,a2,51f4 <grid_clear+0x8>
    for (r = 0u; r < OSD_GRID_ROWS; r++)
    5228:	00158593          	addi	a1,a1,1
    522c:	00c00793          	li	a5,12
    5230:	00b7e663          	bltu	a5,a1,523c <grid_clear+0x50>
        for (c = 0u; c < OSD_GRID_COLS; c++)
    5234:	00000613          	li	a2,0
    5238:	fe9ff06f          	j	5220 <grid_clear+0x34>
}
    523c:	00008067          	ret

00005240 <utf8_str_cells>:
    }
    osd_buf[row][col] = (cell_t)cp;
}

static unsigned utf8_str_cells(const char *s)
{
    5240:	fe010113          	addi	sp,sp,-32
    5244:	00112e23          	sw	ra,28(sp)
    5248:	00812c23          	sw	s0,24(sp)
    524c:	00912a23          	sw	s1,20(sp)
    5250:	01212823          	sw	s2,16(sp)
    5254:	00050413          	mv	s0,a0
    unsigned n = 0u;
    const unsigned char *p = (const unsigned char *)s;
    unsigned remain = 0u, i;
    for (i = 0u; s[i] != '\0'; i++) remain++;
    5258:	00000793          	li	a5,0
    unsigned remain = 0u, i;
    525c:	00000493          	li	s1,0
    for (i = 0u; s[i] != '\0'; i++) remain++;
    5260:	00c0006f          	j	526c <utf8_str_cells+0x2c>
    5264:	00148493          	addi	s1,s1,1
    5268:	00178793          	addi	a5,a5,1
    526c:	00f40733          	add	a4,s0,a5
    5270:	00074703          	lbu	a4,0(a4)
    5274:	fe0718e3          	bnez	a4,5264 <utf8_str_cells+0x24>
    unsigned n = 0u;
    5278:	00000913          	li	s2,0
    527c:	0240006f          	j	52a0 <utf8_str_cells+0x60>
    while (*p != '\0') {
        unsigned adv;
        osd_utf8_decode(p, remain, &adv);
    5280:	00c10613          	addi	a2,sp,12
    5284:	00048593          	mv	a1,s1
    5288:	00040513          	mv	a0,s0
    528c:	e6dff0ef          	jal	50f8 <osd_utf8_decode>
        p += adv; remain -= adv;
    5290:	00c12783          	lw	a5,12(sp)
    5294:	00f40433          	add	s0,s0,a5
    5298:	40f484b3          	sub	s1,s1,a5
        n++;
    529c:	00190913          	addi	s2,s2,1
    while (*p != '\0') {
    52a0:	00044783          	lbu	a5,0(s0)
    52a4:	fc079ee3          	bnez	a5,5280 <utf8_str_cells+0x40>
    }
    return n;
}
    52a8:	00090513          	mv	a0,s2
    52ac:	01c12083          	lw	ra,28(sp)
    52b0:	01812403          	lw	s0,24(sp)
    52b4:	01412483          	lw	s1,20(sp)
    52b8:	01012903          	lw	s2,16(sp)
    52bc:	02010113          	addi	sp,sp,32
    52c0:	00008067          	ret

000052c4 <u8_to_dec>:
    grid_put_str(row, start, str, OSD_COL_VALUE_LAST);
}

/* 手写 itoa：无 libc / 无浮点 */
static unsigned u8_to_dec(uint8_t v, char *dst)
{
    52c4:	ff010113          	addi	sp,sp,-16
    52c8:	00050713          	mv	a4,a0
    char tmp[4];
    unsigned n = 0u, i;
    52cc:	00000513          	li	a0,0

    do { tmp[n++] = (char)('0' + (v % 10u)); v = (uint8_t)(v / 10u); } while (v != 0u);
    52d0:	00a00613          	li	a2,10
    52d4:	02c776b3          	remu	a3,a4,a2
    52d8:	03068693          	addi	a3,a3,48
    52dc:	01050793          	addi	a5,a0,16
    52e0:	002787b3          	add	a5,a5,sp
    52e4:	00150513          	addi	a0,a0,1
    52e8:	fed78e23          	sb	a3,-4(a5)
    52ec:	00070693          	mv	a3,a4
    52f0:	02c75733          	divu	a4,a4,a2
    52f4:	00900793          	li	a5,9
    52f8:	fcd7ece3          	bltu	a5,a3,52d0 <u8_to_dec+0xc>
    for (i = 0u; i < n; i++) dst[i] = tmp[n - 1u - i];
    52fc:	00000713          	li	a4,0
    5300:	0200006f          	j	5320 <u8_to_dec+0x5c>
    5304:	40e507b3          	sub	a5,a0,a4
    5308:	00e586b3          	add	a3,a1,a4
    530c:	00f78793          	addi	a5,a5,15
    5310:	002787b3          	add	a5,a5,sp
    5314:	ffc7c783          	lbu	a5,-4(a5)
    5318:	00f68023          	sb	a5,0(a3)
    531c:	00170713          	addi	a4,a4,1
    5320:	fea762e3          	bltu	a4,a0,5304 <u8_to_dec+0x40>
    return n;
}
    5324:	01010113          	addi	sp,sp,16
    5328:	00008067          	ret

0000532c <grid_put>:
    if (row >= OSD_GRID_ROWS || col >= OSD_GRID_COLS) return;
    532c:	00c00793          	li	a5,12
    5330:	08a7ee63          	bltu	a5,a0,53cc <grid_put+0xa0>
{
    5334:	ff010113          	addi	sp,sp,-16
    5338:	00112623          	sw	ra,12(sp)
    533c:	00812423          	sw	s0,8(sp)
    5340:	00912223          	sw	s1,4(sp)
    5344:	01212023          	sw	s2,0(sp)
    5348:	00050413          	mv	s0,a0
    534c:	00058913          	mv	s2,a1
    5350:	00060493          	mv	s1,a2
    if (row >= OSD_GRID_ROWS || col >= OSD_GRID_COLS) return;
    5354:	02100793          	li	a5,33
    5358:	04b7e263          	bltu	a5,a1,539c <grid_put+0x70>
    if (cp > 0xFFFFu) cp = '?';
    535c:	000107b7          	lui	a5,0x10
    5360:	00f66463          	bltu	a2,a5,5368 <grid_put+0x3c>
    5364:	03f00493          	li	s1,63
    if (font_lookup((uint16_t)cp) < 0) {
    5368:	01049513          	slli	a0,s1,0x10
    536c:	01055513          	srli	a0,a0,0x10
    5370:	c95ff0ef          	jal	5004 <font_lookup>
    5374:	04054063          	bltz	a0,53b4 <grid_put+0x88>
    osd_buf[row][col] = (cell_t)cp;
    5378:	0000f737          	lui	a4,0xf
    537c:	00441793          	slli	a5,s0,0x4
    5380:	008787b3          	add	a5,a5,s0
    5384:	00179793          	slli	a5,a5,0x1
    5388:	012785b3          	add	a1,a5,s2
    538c:	00159593          	slli	a1,a1,0x1
    5390:	e8c70793          	addi	a5,a4,-372 # ee8c <osd_buf>
    5394:	00b787b3          	add	a5,a5,a1
    5398:	00979023          	sh	s1,0(a5) # 10000 <_end+0xe00>
}
    539c:	00c12083          	lw	ra,12(sp)
    53a0:	00812403          	lw	s0,8(sp)
    53a4:	00412483          	lw	s1,4(sp)
    53a8:	00012903          	lw	s2,0(sp)
    53ac:	01010113          	addi	sp,sp,16
    53b0:	00008067          	ret
        g_font_miss_count++;
    53b4:	0000f737          	lui	a4,0xf
    53b8:	e8872783          	lw	a5,-376(a4) # ee88 <g_font_miss_count>
    53bc:	00178793          	addi	a5,a5,1
    53c0:	e8f72423          	sw	a5,-376(a4)
        cp = '?';
    53c4:	03f00493          	li	s1,63
    53c8:	fb1ff06f          	j	5378 <grid_put+0x4c>
    53cc:	00008067          	ret

000053d0 <grid_fill_row>:
{
    53d0:	ff010113          	addi	sp,sp,-16
    53d4:	00112623          	sw	ra,12(sp)
    53d8:	00812423          	sw	s0,8(sp)
    53dc:	00912223          	sw	s1,4(sp)
    53e0:	01212023          	sw	s2,0(sp)
    53e4:	00050913          	mv	s2,a0
    53e8:	00058493          	mv	s1,a1
    for (c = 0u; c < OSD_GRID_COLS; c++) grid_put(row, c, (uint32_t)ch);
    53ec:	00000413          	li	s0,0
    53f0:	0180006f          	j	5408 <grid_fill_row+0x38>
    53f4:	00048613          	mv	a2,s1
    53f8:	00040593          	mv	a1,s0
    53fc:	00090513          	mv	a0,s2
    5400:	f2dff0ef          	jal	532c <grid_put>
    5404:	00140413          	addi	s0,s0,1
    5408:	02100793          	li	a5,33
    540c:	fe87f4e3          	bgeu	a5,s0,53f4 <grid_fill_row+0x24>
}
    5410:	00c12083          	lw	ra,12(sp)
    5414:	00812403          	lw	s0,8(sp)
    5418:	00412483          	lw	s1,4(sp)
    541c:	00012903          	lw	s2,0(sp)
    5420:	01010113          	addi	sp,sp,16
    5424:	00008067          	ret

00005428 <grid_put_str>:
{
    5428:	fd010113          	addi	sp,sp,-48
    542c:	02112623          	sw	ra,44(sp)
    5430:	02812423          	sw	s0,40(sp)
    5434:	02912223          	sw	s1,36(sp)
    5438:	03212023          	sw	s2,32(sp)
    543c:	01312e23          	sw	s3,28(sp)
    5440:	01412c23          	sw	s4,24(sp)
    5444:	00050a13          	mv	s4,a0
    5448:	00058913          	mv	s2,a1
    544c:	00060493          	mv	s1,a2
    5450:	00068993          	mv	s3,a3
    unsigned len = 0u, remain = 0u;
    5454:	00000413          	li	s0,0
    while (str[len] != '\0') len++;
    5458:	0080006f          	j	5460 <grid_put_str+0x38>
    545c:	00140413          	addi	s0,s0,1
    5460:	008487b3          	add	a5,s1,s0
    5464:	0007c783          	lbu	a5,0(a5)
    5468:	fe079ae3          	bnez	a5,545c <grid_put_str+0x34>
    546c:	0140006f          	j	5480 <grid_put_str+0x58>
        grid_put(row, col, cp);
    5470:	00090593          	mv	a1,s2
    5474:	000a0513          	mv	a0,s4
    5478:	eb5ff0ef          	jal	532c <grid_put>
        col++;
    547c:	00190913          	addi	s2,s2,1
    while (*p != '\0' && remain > 0u) {
    5480:	0004c783          	lbu	a5,0(s1)
    5484:	02078663          	beqz	a5,54b0 <grid_put_str+0x88>
    5488:	02040463          	beqz	s0,54b0 <grid_put_str+0x88>
        uint32_t cp = osd_utf8_decode(p, remain, &adv);
    548c:	00c10613          	addi	a2,sp,12
    5490:	00040593          	mv	a1,s0
    5494:	00048513          	mv	a0,s1
    5498:	c61ff0ef          	jal	50f8 <osd_utf8_decode>
    549c:	00050613          	mv	a2,a0
        p += adv; remain -= adv;
    54a0:	00c12783          	lw	a5,12(sp)
    54a4:	00f484b3          	add	s1,s1,a5
    54a8:	40f40433          	sub	s0,s0,a5
        if (col > end_col) break;
    54ac:	fd29f2e3          	bgeu	s3,s2,5470 <grid_put_str+0x48>
    if (remain > 0u) grid_put(row, end_col, '?');
    54b0:	02041263          	bnez	s0,54d4 <grid_put_str+0xac>
}
    54b4:	02c12083          	lw	ra,44(sp)
    54b8:	02812403          	lw	s0,40(sp)
    54bc:	02412483          	lw	s1,36(sp)
    54c0:	02012903          	lw	s2,32(sp)
    54c4:	01c12983          	lw	s3,28(sp)
    54c8:	01812a03          	lw	s4,24(sp)
    54cc:	03010113          	addi	sp,sp,48
    54d0:	00008067          	ret
    if (remain > 0u) grid_put(row, end_col, '?');
    54d4:	03f00613          	li	a2,63
    54d8:	00098593          	mv	a1,s3
    54dc:	000a0513          	mv	a0,s4
    54e0:	e4dff0ef          	jal	532c <grid_put>
}
    54e4:	fd1ff06f          	j	54b4 <grid_put_str+0x8c>

000054e8 <grid_put_centered>:
{
    54e8:	ff010113          	addi	sp,sp,-16
    54ec:	00112623          	sw	ra,12(sp)
    54f0:	00812423          	sw	s0,8(sp)
    54f4:	00912223          	sw	s1,4(sp)
    54f8:	00050493          	mv	s1,a0
    54fc:	00058413          	mv	s0,a1
    unsigned n = utf8_str_cells(str);
    5500:	00058513          	mv	a0,a1
    5504:	d3dff0ef          	jal	5240 <utf8_str_cells>
    if (n >= span) { grid_put_str(row, OSD_COL_PREFIX, str, OSD_COL_VALUE_LAST); return; }
    5508:	01f00793          	li	a5,31
    550c:	02a7ec63          	bltu	a5,a0,5544 <grid_put_centered+0x5c>
    start = OSD_COL_PREFIX + (span - n) / 2u;
    5510:	02000593          	li	a1,32
    5514:	40a585b3          	sub	a1,a1,a0
    5518:	0015d593          	srli	a1,a1,0x1
    grid_put_str(row, start, str, OSD_COL_VALUE_LAST);
    551c:	02000693          	li	a3,32
    5520:	00040613          	mv	a2,s0
    5524:	00158593          	addi	a1,a1,1
    5528:	00048513          	mv	a0,s1
    552c:	efdff0ef          	jal	5428 <grid_put_str>
}
    5530:	00c12083          	lw	ra,12(sp)
    5534:	00812403          	lw	s0,8(sp)
    5538:	00412483          	lw	s1,4(sp)
    553c:	01010113          	addi	sp,sp,16
    5540:	00008067          	ret
    if (n >= span) { grid_put_str(row, OSD_COL_PREFIX, str, OSD_COL_VALUE_LAST); return; }
    5544:	02000693          	li	a3,32
    5548:	00040613          	mv	a2,s0
    554c:	00100593          	li	a1,1
    5550:	00048513          	mv	a0,s1
    5554:	ed5ff0ef          	jal	5428 <grid_put_str>
    5558:	fd9ff06f          	j	5530 <grid_put_centered+0x48>

0000555c <grid_put_value>:

/* 数值右对齐：最后一个字符落在 OSD_COL_VALUE_LAST（[n] 形式） */
static void grid_put_value(unsigned row, uint8_t val)
{
    555c:	fe010113          	addi	sp,sp,-32
    5560:	00112e23          	sw	ra,28(sp)
    5564:	00812c23          	sw	s0,24(sp)
    5568:	00050413          	mv	s0,a0
    556c:	00058513          	mv	a0,a1
    char buf[8];
    unsigned len = 0u, start;

    buf[len++] = '[';
    5570:	05b00793          	li	a5,91
    5574:	00f10423          	sb	a5,8(sp)
    len += u8_to_dec(val, &buf[len]);
    5578:	00910593          	addi	a1,sp,9
    557c:	d49ff0ef          	jal	52c4 <u8_to_dec>
    5580:	00150793          	addi	a5,a0,1
    buf[len++] = ']';
    5584:	00250593          	addi	a1,a0,2
    5588:	01078793          	addi	a5,a5,16
    558c:	002787b3          	add	a5,a5,sp
    5590:	05d00713          	li	a4,93
    5594:	fee78c23          	sb	a4,-8(a5)
    buf[len] = '\0';
    5598:	01058793          	addi	a5,a1,16
    559c:	002787b3          	add	a5,a5,sp
    55a0:	fe078c23          	sb	zero,-8(a5)

    if (len > OSD_COL_VALUE_LAST) len = OSD_COL_VALUE_LAST;
    55a4:	02000793          	li	a5,32
    55a8:	00b7f463          	bgeu	a5,a1,55b0 <grid_put_value+0x54>
    55ac:	02000593          	li	a1,32
    start = OSD_COL_VALUE_LAST + 1u - len;
    grid_put_str(row, start, buf, OSD_COL_VALUE_LAST);
    55b0:	02000693          	li	a3,32
    55b4:	00810613          	addi	a2,sp,8
    55b8:	02100793          	li	a5,33
    55bc:	40b785b3          	sub	a1,a5,a1
    55c0:	00040513          	mv	a0,s0
    55c4:	e65ff0ef          	jal	5428 <grid_put_str>
}
    55c8:	01c12083          	lw	ra,28(sp)
    55cc:	01812403          	lw	s0,24(sp)
    55d0:	02010113          	addi	sp,sp,32
    55d4:	00008067          	ret

000055d8 <ui_init>:

/* ---------------------------------------------------------------- API */

void ui_init(void)
{
    55d8:	ff010113          	addi	sp,sp,-16
    55dc:	00112623          	sw	ra,12(sp)
    s_state.page_id = 0x0000u;
    55e0:	0000f7b7          	lui	a5,0xf
    55e4:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    55e8:	00079023          	sh	zero,0(a5)
    s_state.sel     = 0u;
    55ec:	00078123          	sb	zero,2(a5)
    s_state.flags   = UI_FLAG_VISIBLE;   /* 上电即显示主菜单（bit0 = UI 显示）*/
    55f0:	00100713          	li	a4,1
    55f4:	00e781a3          	sb	a4,3(a5)
    s_state.v[0]    = 3u;      /* 默认值取自 UI 规格 P2 原型 */
    55f8:	00300693          	li	a3,3
    55fc:	00d78223          	sb	a3,4(a5)
    s_state.v[1]    = 5u;
    5600:	00500693          	li	a3,5
    5604:	00d782a3          	sb	a3,5(a5)
    s_state.v[2]    = 7u;
    5608:	00700613          	li	a2,7
    560c:	00c78323          	sb	a2,6(a5)
    s_state.v[3]    = 5u;
    5610:	00d783a3          	sb	a3,7(a5)
    s_state.status  = 0u;
    5614:	00078423          	sb	zero,8(a5)
    s_state.dirty   = 1u;
    5618:	00e784a3          	sb	a4,9(a5)
    grid_clear();
    561c:	bd1ff0ef          	jal	51ec <grid_clear>
}
    5620:	00c12083          	lw	ra,12(sp)
    5624:	01010113          	addi	sp,sp,16
    5628:	00008067          	ret

0000562c <ui_set_view>:
*
* @note 失败时**状态完全不变**（含 flags）：这是"整帧拒绝"的口径 —— 部分生效会
*       让上位机回读到的状态既不是旧的也不是它要的新的，比直接失败更难排查。
******************************************************************************/
int ui_set_view(uint16_t page_id, uint8_t sel, uint8_t flags)
{
    562c:	ff010113          	addi	sp,sp,-16
    5630:	00112623          	sw	ra,12(sp)
    5634:	00812423          	sw	s0,8(sp)
    5638:	00912223          	sw	s1,4(sp)
    563c:	01212023          	sw	s2,0(sp)
    5640:	00050913          	mv	s2,a0
    5644:	00058493          	mv	s1,a1
    5648:	00060413          	mv	s0,a2
    const scene_page_t *pg = scene_find(page_id);
    564c:	364000ef          	jal	59b0 <scene_find>
    uint8_t f;

    if (pg == 0)               { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    5650:	04050e63          	beqz	a0,56ac <ui_set_view+0x80>
    if (sel >= pg->item_count) { s_state.status |= UI_STATUS_BAD_PARAM; return -2; }
    5654:	00c52783          	lw	a5,12(a0)
    5658:	06f4f863          	bgeu	s1,a5,56c8 <ui_set_view+0x9c>

    f = (uint8_t)(flags & UI_FLAG_MASK);        /* 保留位静默丢弃、不报错 */
    565c:	00347713          	andi	a4,s0,3
    if ((f & UI_FLAG_EDIT) && (pg->value_slot[sel] < 0)) {
    5660:	00247413          	andi	s0,s0,2
    5664:	00040863          	beqz	s0,5674 <ui_set_view+0x48>
    5668:	009507b3          	add	a5,a0,s1
    566c:	05878783          	lb	a5,88(a5)
    5670:	0607ca63          	bltz	a5,56e4 <ui_set_view+0xb8>
        s_state.status |= UI_STATUS_BAD_PARAM;
        return -3;
    }

    s_state.page_id = page_id;
    5674:	0000f7b7          	lui	a5,0xf
    5678:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    567c:	01279023          	sh	s2,0(a5)
    s_state.sel     = sel;
    5680:	00978123          	sb	s1,2(a5)
    s_state.flags   = f;
    5684:	00e781a3          	sb	a4,3(a5)
    s_state.dirty   = 1u;
    5688:	00100713          	li	a4,1
    568c:	00e784a3          	sb	a4,9(a5)
    return 0;
    5690:	00000513          	li	a0,0
}
    5694:	00c12083          	lw	ra,12(sp)
    5698:	00812403          	lw	s0,8(sp)
    569c:	00412483          	lw	s1,4(sp)
    56a0:	00012903          	lw	s2,0(sp)
    56a4:	01010113          	addi	sp,sp,16
    56a8:	00008067          	ret
    if (pg == 0)               { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    56ac:	0000f7b7          	lui	a5,0xf
    56b0:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    56b4:	0087c703          	lbu	a4,8(a5)
    56b8:	00276713          	ori	a4,a4,2
    56bc:	00e78423          	sb	a4,8(a5)
    56c0:	fff00513          	li	a0,-1
    56c4:	fd1ff06f          	j	5694 <ui_set_view+0x68>
    if (sel >= pg->item_count) { s_state.status |= UI_STATUS_BAD_PARAM; return -2; }
    56c8:	0000f7b7          	lui	a5,0xf
    56cc:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    56d0:	0087c703          	lbu	a4,8(a5)
    56d4:	00276713          	ori	a4,a4,2
    56d8:	00e78423          	sb	a4,8(a5)
    56dc:	ffe00513          	li	a0,-2
    56e0:	fb5ff06f          	j	5694 <ui_set_view+0x68>
        s_state.status |= UI_STATUS_BAD_PARAM;
    56e4:	0000f7b7          	lui	a5,0xf
    56e8:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    56ec:	0087c703          	lbu	a4,8(a5)
    56f0:	00276713          	ori	a4,a4,2
    56f4:	00e78423          	sb	a4,8(a5)
        return -3;
    56f8:	ffd00513          	li	a0,-3
    56fc:	f99ff06f          	j	5694 <ui_set_view+0x68>

00005700 <ui_set_image_values>:
*       菜单回显与前端的 QUERY_VIEW 回读，没有连到任何图像处理通路。
*       这是本期明确的范围（任务 6.10），也是"改了参数画面没变"的原因。
******************************************************************************/
int ui_set_image_values(const uint8_t v[4])
{
    if (v[0] > UI_V_ENHANCE_MAX) { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    5700:	00054703          	lbu	a4,0(a0)
    5704:	00500793          	li	a5,5
    5708:	04e7ea63          	bltu	a5,a4,575c <ui_set_image_values+0x5c>
    if ((v[1] > UI_V_OTHER_MAX) || (v[2] > UI_V_OTHER_MAX) || (v[3] > UI_V_OTHER_MAX)) {
    570c:	00154683          	lbu	a3,1(a0)
    5710:	00a00793          	li	a5,10
    5714:	06d7e263          	bltu	a5,a3,5778 <ui_set_image_values+0x78>
    5718:	00254683          	lbu	a3,2(a0)
    571c:	04d7ee63          	bltu	a5,a3,5778 <ui_set_image_values+0x78>
    5720:	00354683          	lbu	a3,3(a0)
    5724:	04d7ea63          	bltu	a5,a3,5778 <ui_set_image_values+0x78>
        s_state.status |= UI_STATUS_BAD_PARAM;
        return -1;
    }

    s_state.v[0] = v[0];
    5728:	0000f7b7          	lui	a5,0xf
    572c:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    5730:	00e78223          	sb	a4,4(a5)
    s_state.v[1] = v[1];
    5734:	00154703          	lbu	a4,1(a0)
    5738:	00e782a3          	sb	a4,5(a5)
    s_state.v[2] = v[2];
    573c:	00254703          	lbu	a4,2(a0)
    5740:	00e78323          	sb	a4,6(a5)
    s_state.v[3] = v[3];
    5744:	00354703          	lbu	a4,3(a0)
    5748:	00e783a3          	sb	a4,7(a5)
    s_state.dirty = 1u;
    574c:	00100713          	li	a4,1
    5750:	00e784a3          	sb	a4,9(a5)
    return 0;
    5754:	00000513          	li	a0,0
}
    5758:	00008067          	ret
    if (v[0] > UI_V_ENHANCE_MAX) { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    575c:	0000f7b7          	lui	a5,0xf
    5760:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    5764:	0087c703          	lbu	a4,8(a5)
    5768:	00276713          	ori	a4,a4,2
    576c:	00e78423          	sb	a4,8(a5)
    5770:	fff00513          	li	a0,-1
    5774:	00008067          	ret
        s_state.status |= UI_STATUS_BAD_PARAM;
    5778:	0000f7b7          	lui	a5,0xf
    577c:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    5780:	0087c703          	lbu	a4,8(a5)
    5784:	00276713          	ori	a4,a4,2
    5788:	00e78423          	sb	a4,8(a5)
        return -1;
    578c:	fff00513          	li	a0,-1
    5790:	00008067          	ret

00005794 <ui_query_view>:
* @note **不再有 item_count 与 fw_version**（D11 第 6 项）：协议文档 §3.3 与工具
*       都只认这 8 个字节，多写两个会直接变成 CRC 对不上的 14 字节 body。
******************************************************************************/
int ui_query_view(uint8_t resp[UI_QUERY_PAYLOAD_LEN])
{
    resp[0] = (uint8_t)(s_state.page_id >> 8);
    5794:	0000f7b7          	lui	a5,0xf
    5798:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    579c:	0007d703          	lhu	a4,0(a5)
    57a0:	00875693          	srli	a3,a4,0x8
    57a4:	00d50023          	sb	a3,0(a0)
    resp[1] = (uint8_t)(s_state.page_id & 0xFFu);
    57a8:	00e500a3          	sb	a4,1(a0)
    resp[2] = s_state.sel;
    57ac:	0027c703          	lbu	a4,2(a5)
    57b0:	00e50123          	sb	a4,2(a0)
    resp[3] = s_state.flags;
    57b4:	0037c703          	lbu	a4,3(a5)
    57b8:	00e501a3          	sb	a4,3(a0)
    resp[4] = s_state.v[0];
    57bc:	0047c703          	lbu	a4,4(a5)
    57c0:	00e50223          	sb	a4,4(a0)
    resp[5] = s_state.v[1];
    57c4:	0057c703          	lbu	a4,5(a5)
    57c8:	00e502a3          	sb	a4,5(a0)
    resp[6] = s_state.v[2];
    57cc:	0067c703          	lbu	a4,6(a5)
    57d0:	00e50323          	sb	a4,6(a0)
    resp[7] = s_state.v[3];
    57d4:	0077c783          	lbu	a5,7(a5)
    57d8:	00f503a3          	sb	a5,7(a0)
    return 0;
}
    57dc:	00000513          	li	a0,0
    57e0:	00008067          	ret

000057e4 <ui_is_visible>:

int  ui_is_visible(void)  { return (s_state.flags & UI_FLAG_VISIBLE) ? 1 : 0; }
    57e4:	0000f7b7          	lui	a5,0xf
    57e8:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    57ec:	0037c503          	lbu	a0,3(a5)
    57f0:	00157513          	andi	a0,a0,1
    57f4:	00008067          	ret

000057f8 <ui_is_dirty>:
int  ui_is_dirty(void)    { return (int)s_state.dirty; }
    57f8:	0000f7b7          	lui	a5,0xf
    57fc:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    5800:	0097c503          	lbu	a0,9(a5)
    5804:	00008067          	ret

00005808 <ui_clear_dirty>:
void ui_clear_dirty(void) { s_state.dirty = 0u; }
    5808:	0000f7b7          	lui	a5,0xf
    580c:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    5810:	000784a3          	sb	zero,9(a5)
    5814:	00008067          	ret

00005818 <scene_build>:
void ui_clear_status(void){ s_state.status = 0u; }

/* ---------------------------------------------------------------- 排版 */

void scene_build(void)
{
    5818:	fe010113          	addi	sp,sp,-32
    581c:	00112e23          	sw	ra,28(sp)
    5820:	01212823          	sw	s2,16(sp)
    const scene_page_t *pg = scene_find(s_state.page_id);
    5824:	0000f7b7          	lui	a5,0xf
    5828:	e747d503          	lhu	a0,-396(a5) # ee74 <s_state>
    582c:	184000ef          	jal	59b0 <scene_find>
    5830:	00050913          	mv	s2,a0
    unsigned i;

    grid_clear();
    5834:	9b9ff0ef          	jal	51ec <grid_clear>
    if (pg == 0) return;                       /* 命令层已保证不会走到这里 */
    5838:	16090063          	beqz	s2,5998 <scene_build+0x180>
    583c:	00812c23          	sw	s0,24(sp)
    5840:	00912a23          	sw	s1,20(sp)
    5844:	01312623          	sw	s3,12(sp)

    /* 外框：顶/底横线（-），分隔线（-） */
    grid_fill_row(OSD_ROW_BORDER_TOP,    '-');
    5848:	02d00593          	li	a1,45
    584c:	00000513          	li	a0,0
    5850:	b81ff0ef          	jal	53d0 <grid_fill_row>
    grid_fill_row(OSD_ROW_SEPARATOR,     '-');
    5854:	02d00593          	li	a1,45
    5858:	00200513          	li	a0,2
    585c:	b75ff0ef          	jal	53d0 <grid_fill_row>
    grid_fill_row(OSD_ROW_BORDER_BOTTOM, '-');
    5860:	02d00593          	li	a1,45
    5864:	00c00513          	li	a0,12
    5868:	b69ff0ef          	jal	53d0 <grid_fill_row>

    /* 标题居中 */
    grid_put_centered(OSD_ROW_TITLE, pick(&pg->title));
    586c:	00490513          	addi	a0,s2,4
    5870:	975ff0ef          	jal	51e4 <pick>
    5874:	00050593          	mv	a1,a0
    5878:	00100513          	li	a0,1
    587c:	c6dff0ef          	jal	54e8 <grid_put_centered>

    for (i = 0u; i < pg->item_count; i++) {
    5880:	00000413          	li	s0,0
    5884:	0600006f          	j	58e4 <scene_build+0xcc>
        unsigned row  = OSD_ROW_ITEM0 + i;
        unsigned end  = (pg->value_slot[i] >= 0) ? OSD_COL_LABEL_END : OSD_COL_VALUE_LAST;
    5888:	02000993          	li	s3,32
    588c:	0740006f          	j	5900 <scene_build+0xe8>
         * 上游用的是 (UI_FLAG_SELECTED | UI_FLAG_EDIT) 这一对位，而现在 bit0 的
         * 含义是"UI 显示"（整块菜单的显隐），与"哪一行是选中行"无关了 ——
         * 选中行由 sel 唯一决定。若照搬上游的写法，菜单一显示就会所有行都带
         * 选中标记，那是把"窗口可见"误当成"这一行被选中"（D11 第 7 项）。*/
        if (i == s_state.sel) {
            grid_put(row, OSD_COL_PREFIX, (s_state.flags & UI_FLAG_EDIT) ? '*' : '>');
    5890:	03e00613          	li	a2,62
    5894:	00100593          	li	a1,1
    5898:	00048513          	mv	a0,s1
    589c:	a91ff0ef          	jal	532c <grid_put>
            grid_put(row, OSD_COL_PREFIX + 1u, ' ');
    58a0:	02000613          	li	a2,32
    58a4:	00200593          	li	a1,2
    58a8:	00048513          	mv	a0,s1
    58ac:	a81ff0ef          	jal	532c <grid_put>
            grid_put(row, OSD_COL_PREFIX, ' ');
            grid_put(row, OSD_COL_PREFIX + 1u, ' ');
        }

        /* 标签（超长截断） */
        grid_put_str(row, OSD_COL_LABEL, pick(&pg->items[i]), end);
    58b0:	00240513          	addi	a0,s0,2
    58b4:	00351513          	slli	a0,a0,0x3
    58b8:	00a90533          	add	a0,s2,a0
    58bc:	929ff0ef          	jal	51e4 <pick>
    58c0:	00050613          	mv	a2,a0
    58c4:	00098693          	mv	a3,s3
    58c8:	00300593          	li	a1,3
    58cc:	00048513          	mv	a0,s1
    58d0:	b59ff0ef          	jal	5428 <grid_put_str>

        /* 数值（v[slot] 右对齐，这是 SET_IMAGE_VALUES 在画面上的唯一出口） */
        if (pg->value_slot[i] >= 0)
    58d4:	008907b3          	add	a5,s2,s0
    58d8:	05878703          	lb	a4,88(a5)
    58dc:	08075a63          	bgez	a4,5970 <scene_build+0x158>
    for (i = 0u; i < pg->item_count; i++) {
    58e0:	00140413          	addi	s0,s0,1
    58e4:	00c92783          	lw	a5,12(s2)
    58e8:	0af47263          	bgeu	s0,a5,598c <scene_build+0x174>
        unsigned row  = OSD_ROW_ITEM0 + i;
    58ec:	00340493          	addi	s1,s0,3
        unsigned end  = (pg->value_slot[i] >= 0) ? OSD_COL_LABEL_END : OSD_COL_VALUE_LAST;
    58f0:	008907b3          	add	a5,s2,s0
    58f4:	05878783          	lb	a5,88(a5)
    58f8:	f807c8e3          	bltz	a5,5888 <scene_build+0x70>
    58fc:	01c00993          	li	s3,28
        grid_put(row, OSD_COL_BORDER_L, '|');
    5900:	07c00613          	li	a2,124
    5904:	00000593          	li	a1,0
    5908:	00048513          	mv	a0,s1
    590c:	a21ff0ef          	jal	532c <grid_put>
        grid_put(row, OSD_COL_BORDER_R, '|');
    5910:	07c00613          	li	a2,124
    5914:	02100593          	li	a1,33
    5918:	00048513          	mv	a0,s1
    591c:	a11ff0ef          	jal	532c <grid_put>
        if (i == s_state.sel) {
    5920:	0000f7b7          	lui	a5,0xf
    5924:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    5928:	0027c783          	lbu	a5,2(a5)
    592c:	02879063          	bne	a5,s0,594c <scene_build+0x134>
            grid_put(row, OSD_COL_PREFIX, (s_state.flags & UI_FLAG_EDIT) ? '*' : '>');
    5930:	0000f7b7          	lui	a5,0xf
    5934:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    5938:	0037c783          	lbu	a5,3(a5)
    593c:	0027f793          	andi	a5,a5,2
    5940:	f40788e3          	beqz	a5,5890 <scene_build+0x78>
    5944:	02a00613          	li	a2,42
    5948:	f4dff06f          	j	5894 <scene_build+0x7c>
            grid_put(row, OSD_COL_PREFIX, ' ');
    594c:	02000613          	li	a2,32
    5950:	00100593          	li	a1,1
    5954:	00048513          	mv	a0,s1
    5958:	9d5ff0ef          	jal	532c <grid_put>
            grid_put(row, OSD_COL_PREFIX + 1u, ' ');
    595c:	02000613          	li	a2,32
    5960:	00200593          	li	a1,2
    5964:	00048513          	mv	a0,s1
    5968:	9c5ff0ef          	jal	532c <grid_put>
    596c:	f45ff06f          	j	58b0 <scene_build+0x98>
            grid_put_value(row, s_state.v[pg->value_slot[i]]);
    5970:	0000f7b7          	lui	a5,0xf
    5974:	e7478793          	addi	a5,a5,-396 # ee74 <s_state>
    5978:	00e787b3          	add	a5,a5,a4
    597c:	0047c583          	lbu	a1,4(a5)
    5980:	00048513          	mv	a0,s1
    5984:	bd9ff0ef          	jal	555c <grid_put_value>
    5988:	f59ff06f          	j	58e0 <scene_build+0xc8>
    598c:	01812403          	lw	s0,24(sp)
    5990:	01412483          	lw	s1,20(sp)
    5994:	00c12983          	lw	s3,12(sp)
    }
}
    5998:	01c12083          	lw	ra,28(sp)
    599c:	01012903          	lw	s2,16(sp)
    59a0:	02010113          	addi	sp,sp,32
    59a4:	00008067          	ret

000059a8 <scene_page_count>:
        },
        { -1, -1, -1, -1 }
    },
};

unsigned scene_page_count(void) { return (unsigned)(sizeof(s_pages) / sizeof(s_pages[0])); }
    59a8:	00300513          	li	a0,3
    59ac:	00008067          	ret

000059b0 <scene_find>:
const scene_page_t *scene_at(unsigned i) { return &s_pages[i]; }

const scene_page_t *scene_find(uint16_t page_id)
{
    59b0:	ff010113          	addi	sp,sp,-16
    59b4:	00112623          	sw	ra,12(sp)
    59b8:	00812423          	sw	s0,8(sp)
    59bc:	00912223          	sw	s1,4(sp)
    59c0:	00050493          	mv	s1,a0
    unsigned i;
    for (i = 0u; i < scene_page_count(); i++) {
    59c4:	00000413          	li	s0,0
    59c8:	0080006f          	j	59d0 <scene_find+0x20>
    59cc:	00140413          	addi	s0,s0,1
    59d0:	fd9ff0ef          	jal	59a8 <scene_page_count>
    59d4:	02a47863          	bgeu	s0,a0,5a04 <scene_find+0x54>
        if (s_pages[i].page_id == page_id) return &s_pages[i];
    59d8:	0000b7b7          	lui	a5,0xb
    59dc:	06400713          	li	a4,100
    59e0:	02e40733          	mul	a4,s0,a4
    59e4:	d5078793          	addi	a5,a5,-688 # ad50 <s_pages>
    59e8:	00e787b3          	add	a5,a5,a4
    59ec:	0007d783          	lhu	a5,0(a5)
    59f0:	fc979ee3          	bne	a5,s1,59cc <scene_find+0x1c>
    59f4:	0000b7b7          	lui	a5,0xb
    59f8:	d5078793          	addi	a5,a5,-688 # ad50 <s_pages>
    59fc:	00f70533          	add	a0,a4,a5
    5a00:	0080006f          	j	5a08 <scene_find+0x58>
    }
    return 0;   /* 未知 page_id：由命令层判非法（统一口径），不做兜底渲染 */
    5a04:	00000513          	li	a0,0
}
    5a08:	00c12083          	lw	ra,12(sp)
    5a0c:	00812403          	lw	s0,8(sp)
    5a10:	00412483          	lw	s1,4(sp)
    5a14:	01010113          	addi	sp,sp,16
    5a18:	00008067          	ret

00005a1c <trap_entry>:

trap_entry:
#ifdef __riscv_flen
  addi sp, sp, -STACK_SIZE
#else
  addi sp, sp, -64
    5a1c:	fc010113          	addi	sp,sp,-64
#endif
  sw x1,   0*4(sp)
    5a20:	00112023          	sw	ra,0(sp)
  sw x5,   1*4(sp)
    5a24:	00512223          	sw	t0,4(sp)
  sw x6,   2*4(sp)
    5a28:	00612423          	sw	t1,8(sp)
  sw x7,   3*4(sp)
    5a2c:	00712623          	sw	t2,12(sp)
  sw x10,  4*4(sp)
    5a30:	00a12823          	sw	a0,16(sp)
  sw x11,  5*4(sp)
    5a34:	00b12a23          	sw	a1,20(sp)
  sw x12,  6*4(sp)
    5a38:	00c12c23          	sw	a2,24(sp)
  sw x13,  7*4(sp)
    5a3c:	00d12e23          	sw	a3,28(sp)
  sw x14,  8*4(sp)
    5a40:	02e12023          	sw	a4,32(sp)
  sw x15,  9*4(sp)
    5a44:	02f12223          	sw	a5,36(sp)
  sw x16, 10*4(sp)
    5a48:	03012423          	sw	a6,40(sp)
  sw x17, 11*4(sp)
    5a4c:	03112623          	sw	a7,44(sp)
  sw x28, 12*4(sp)
    5a50:	03c12823          	sw	t3,48(sp)
  sw x29, 13*4(sp)
    5a54:	03d12a23          	sw	t4,52(sp)
  sw x30, 14*4(sp)
    5a58:	03e12c23          	sw	t5,56(sp)
  sw x31, 15*4(sp)
    5a5c:	03f12e23          	sw	t6,60(sp)
  FSTORE f30, 64 + 18*FPR_SIZE(sp)
  FSTORE f31, 64 + 19*FPR_SIZE(sp)
  csrr t0, fcsr
  sw t0, 64 + 20*FPR_SIZE(sp)
#endif
  call trap
    5a60:	b8cfe0ef          	jal	3dec <trap>
  FLOAD f28, 64 + 16*FPR_SIZE(sp)
  FLOAD f29, 64 + 17*FPR_SIZE(sp)
  FLOAD f30, 64 + 18*FPR_SIZE(sp)
  FLOAD f31, 64 + 19*FPR_SIZE(sp)
#endif
  lw x1 ,  0*4(sp)
    5a64:	00012083          	lw	ra,0(sp)
  lw x5,   1*4(sp)
    5a68:	00412283          	lw	t0,4(sp)
  lw x6,   2*4(sp)
    5a6c:	00812303          	lw	t1,8(sp)
  lw x7,   3*4(sp)
    5a70:	00c12383          	lw	t2,12(sp)
  lw x10,  4*4(sp)
    5a74:	01012503          	lw	a0,16(sp)
  lw x11,  5*4(sp)
    5a78:	01412583          	lw	a1,20(sp)
  lw x12,  6*4(sp)
    5a7c:	01812603          	lw	a2,24(sp)
  lw x13,  7*4(sp)
    5a80:	01c12683          	lw	a3,28(sp)
  lw x14,  8*4(sp)
    5a84:	02012703          	lw	a4,32(sp)
  lw x15,  9*4(sp)
    5a88:	02412783          	lw	a5,36(sp)
  lw x16, 10*4(sp)
    5a8c:	02812803          	lw	a6,40(sp)
  lw x17, 11*4(sp)
    5a90:	02c12883          	lw	a7,44(sp)
  lw x28, 12*4(sp)
    5a94:	03012e03          	lw	t3,48(sp)
  lw x29, 13*4(sp)
    5a98:	03412e83          	lw	t4,52(sp)
  lw x30, 14*4(sp)
    5a9c:	03812f03          	lw	t5,56(sp)
  lw x31, 15*4(sp)
    5aa0:	03c12f83          	lw	t6,60(sp)
#ifdef __riscv_flen
  addi sp, sp, STACK_SIZE
#else
  addi sp, sp, 64
    5aa4:	04010113          	addi	sp,sp,64
#endif
    5aa8:	30200073          	mret

00005aac <__udivdi3>:
    5aac:	00060813          	mv	a6,a2
    5ab0:	00050893          	mv	a7,a0
    5ab4:	00058713          	mv	a4,a1
    5ab8:	0e069063          	bnez	a3,5b98 <__udivdi3+0xec>
    5abc:	12c5fe63          	bgeu	a1,a2,5bf8 <__udivdi3+0x14c>
    5ac0:	000107b7          	lui	a5,0x10
    5ac4:	1ef66e63          	bltu	a2,a5,5cc0 <__udivdi3+0x214>
    5ac8:	010007b7          	lui	a5,0x1000
    5acc:	01800693          	li	a3,24
    5ad0:	00f67463          	bgeu	a2,a5,5ad8 <__udivdi3+0x2c>
    5ad4:	01000693          	li	a3,16
    5ad8:	00d65333          	srl	t1,a2,a3
    5adc:	00005797          	auipc	a5,0x5
    5ae0:	3e078793          	addi	a5,a5,992 # aebc <__clz_tab>
    5ae4:	006787b3          	add	a5,a5,t1
    5ae8:	0007c783          	lbu	a5,0(a5)
    5aec:	02000313          	li	t1,32
    5af0:	00d787b3          	add	a5,a5,a3
    5af4:	40f306b3          	sub	a3,t1,a5
    5af8:	00f30c63          	beq	t1,a5,5b10 <__udivdi3+0x64>
    5afc:	00d59733          	sll	a4,a1,a3
    5b00:	00f557b3          	srl	a5,a0,a5
    5b04:	00d61833          	sll	a6,a2,a3
    5b08:	00e7e733          	or	a4,a5,a4
    5b0c:	00d518b3          	sll	a7,a0,a3
    5b10:	01085613          	srli	a2,a6,0x10
    5b14:	02c75533          	divu	a0,a4,a2
    5b18:	01081693          	slli	a3,a6,0x10
    5b1c:	0106d693          	srli	a3,a3,0x10
    5b20:	0108d793          	srli	a5,a7,0x10
    5b24:	02c77733          	remu	a4,a4,a2
    5b28:	02a685b3          	mul	a1,a3,a0
    5b2c:	01071713          	slli	a4,a4,0x10
    5b30:	00e7e7b3          	or	a5,a5,a4
    5b34:	00b7fc63          	bgeu	a5,a1,5b4c <__udivdi3+0xa0>
    5b38:	00f807b3          	add	a5,a6,a5
    5b3c:	fff50713          	addi	a4,a0,-1
    5b40:	0107e463          	bltu	a5,a6,5b48 <__udivdi3+0x9c>
    5b44:	40b7e063          	bltu	a5,a1,5f44 <__udivdi3+0x498>
    5b48:	00070513          	mv	a0,a4
    5b4c:	40b787b3          	sub	a5,a5,a1
    5b50:	02c7d733          	divu	a4,a5,a2
    5b54:	01089893          	slli	a7,a7,0x10
    5b58:	0108d893          	srli	a7,a7,0x10
    5b5c:	02c7f7b3          	remu	a5,a5,a2
    5b60:	02e686b3          	mul	a3,a3,a4
    5b64:	01079793          	slli	a5,a5,0x10
    5b68:	00f8e8b3          	or	a7,a7,a5
    5b6c:	00d8fe63          	bgeu	a7,a3,5b88 <__udivdi3+0xdc>
    5b70:	011808b3          	add	a7,a6,a7
    5b74:	fff70793          	addi	a5,a4,-1
    5b78:	0108e663          	bltu	a7,a6,5b84 <__udivdi3+0xd8>
    5b7c:	ffe70713          	addi	a4,a4,-2
    5b80:	00d8e463          	bltu	a7,a3,5b88 <__udivdi3+0xdc>
    5b84:	00078713          	mv	a4,a5
    5b88:	01051513          	slli	a0,a0,0x10
    5b8c:	00e56533          	or	a0,a0,a4
    5b90:	00000593          	li	a1,0
    5b94:	00008067          	ret
    5b98:	00d5f863          	bgeu	a1,a3,5ba8 <__udivdi3+0xfc>
    5b9c:	00000593          	li	a1,0
    5ba0:	00000513          	li	a0,0
    5ba4:	00008067          	ret
    5ba8:	000107b7          	lui	a5,0x10
    5bac:	1ef6e863          	bltu	a3,a5,5d9c <__udivdi3+0x2f0>
    5bb0:	01000737          	lui	a4,0x1000
    5bb4:	01800793          	li	a5,24
    5bb8:	00e6f463          	bgeu	a3,a4,5bc0 <__udivdi3+0x114>
    5bbc:	01000793          	li	a5,16
    5bc0:	00f6d833          	srl	a6,a3,a5
    5bc4:	00005717          	auipc	a4,0x5
    5bc8:	2f870713          	addi	a4,a4,760 # aebc <__clz_tab>
    5bcc:	01070733          	add	a4,a4,a6
    5bd0:	00074703          	lbu	a4,0(a4)
    5bd4:	02000893          	li	a7,32
    5bd8:	00f70733          	add	a4,a4,a5
    5bdc:	40e88833          	sub	a6,a7,a4
    5be0:	1ee89663          	bne	a7,a4,5dcc <__udivdi3+0x320>
    5be4:	32b6e463          	bltu	a3,a1,5f0c <__udivdi3+0x460>
    5be8:	00c53533          	sltu	a0,a0,a2
    5bec:	00153513          	seqz	a0,a0
    5bf0:	00000593          	li	a1,0
    5bf4:	00008067          	ret
    5bf8:	0c060c63          	beqz	a2,5cd0 <__udivdi3+0x224>
    5bfc:	000107b7          	lui	a5,0x10
    5c00:	2ef67c63          	bgeu	a2,a5,5ef8 <__udivdi3+0x44c>
    5c04:	10063713          	sltiu	a4,a2,256
    5c08:	00173713          	seqz	a4,a4
    5c0c:	00371713          	slli	a4,a4,0x3
    5c10:	00e656b3          	srl	a3,a2,a4
    5c14:	00005797          	auipc	a5,0x5
    5c18:	2a878793          	addi	a5,a5,680 # aebc <__clz_tab>
    5c1c:	00d787b3          	add	a5,a5,a3
    5c20:	0007c783          	lbu	a5,0(a5)
    5c24:	02000693          	li	a3,32
    5c28:	00e787b3          	add	a5,a5,a4
    5c2c:	40f68eb3          	sub	t4,a3,a5
    5c30:	0cf69463          	bne	a3,a5,5cf8 <__udivdi3+0x24c>
    5c34:	40c587b3          	sub	a5,a1,a2
    5c38:	01065693          	srli	a3,a2,0x10
    5c3c:	01061613          	slli	a2,a2,0x10
    5c40:	01065613          	srli	a2,a2,0x10
    5c44:	00100593          	li	a1,1
    5c48:	02d7d533          	divu	a0,a5,a3
    5c4c:	0108d713          	srli	a4,a7,0x10
    5c50:	02d7f7b3          	remu	a5,a5,a3
    5c54:	02c50333          	mul	t1,a0,a2
    5c58:	01079793          	slli	a5,a5,0x10
    5c5c:	00f767b3          	or	a5,a4,a5
    5c60:	0067fc63          	bgeu	a5,t1,5c78 <__udivdi3+0x1cc>
    5c64:	00f807b3          	add	a5,a6,a5
    5c68:	fff50713          	addi	a4,a0,-1
    5c6c:	0107e463          	bltu	a5,a6,5c74 <__udivdi3+0x1c8>
    5c70:	2c67e463          	bltu	a5,t1,5f38 <__udivdi3+0x48c>
    5c74:	00070513          	mv	a0,a4
    5c78:	406787b3          	sub	a5,a5,t1
    5c7c:	02d7d733          	divu	a4,a5,a3
    5c80:	01089893          	slli	a7,a7,0x10
    5c84:	0108d893          	srli	a7,a7,0x10
    5c88:	02d7f7b3          	remu	a5,a5,a3
    5c8c:	02c70633          	mul	a2,a4,a2
    5c90:	01079793          	slli	a5,a5,0x10
    5c94:	00f8e8b3          	or	a7,a7,a5
    5c98:	00c8fe63          	bgeu	a7,a2,5cb4 <__udivdi3+0x208>
    5c9c:	011808b3          	add	a7,a6,a7
    5ca0:	fff70793          	addi	a5,a4,-1
    5ca4:	0108e663          	bltu	a7,a6,5cb0 <__udivdi3+0x204>
    5ca8:	ffe70713          	addi	a4,a4,-2
    5cac:	00c8e463          	bltu	a7,a2,5cb4 <__udivdi3+0x208>
    5cb0:	00078713          	mv	a4,a5
    5cb4:	01051513          	slli	a0,a0,0x10
    5cb8:	00e56533          	or	a0,a0,a4
    5cbc:	00008067          	ret
    5cc0:	10063693          	sltiu	a3,a2,256
    5cc4:	0016b693          	seqz	a3,a3
    5cc8:	00369693          	slli	a3,a3,0x3
    5ccc:	e0dff06f          	j	5ad8 <__udivdi3+0x2c>
    5cd0:	00000693          	li	a3,0
    5cd4:	00005797          	auipc	a5,0x5
    5cd8:	1e878793          	addi	a5,a5,488 # aebc <__clz_tab>
    5cdc:	00d787b3          	add	a5,a5,a3
    5ce0:	0007c783          	lbu	a5,0(a5)
    5ce4:	00000713          	li	a4,0
    5ce8:	02000693          	li	a3,32
    5cec:	00e787b3          	add	a5,a5,a4
    5cf0:	40f68eb3          	sub	t4,a3,a5
    5cf4:	f4f680e3          	beq	a3,a5,5c34 <__udivdi3+0x188>
    5cf8:	01d61833          	sll	a6,a2,t4
    5cfc:	00f5d333          	srl	t1,a1,a5
    5d00:	01085693          	srli	a3,a6,0x10
    5d04:	02d35e33          	divu	t3,t1,a3
    5d08:	01081613          	slli	a2,a6,0x10
    5d0c:	01d595b3          	sll	a1,a1,t4
    5d10:	01065613          	srli	a2,a2,0x10
    5d14:	00f557b3          	srl	a5,a0,a5
    5d18:	00b7e7b3          	or	a5,a5,a1
    5d1c:	0107d713          	srli	a4,a5,0x10
    5d20:	01d518b3          	sll	a7,a0,t4
    5d24:	02d37333          	remu	t1,t1,a3
    5d28:	03c605b3          	mul	a1,a2,t3
    5d2c:	01031313          	slli	t1,t1,0x10
    5d30:	00676733          	or	a4,a4,t1
    5d34:	00b77e63          	bgeu	a4,a1,5d50 <__udivdi3+0x2a4>
    5d38:	00e80733          	add	a4,a6,a4
    5d3c:	fffe0513          	addi	a0,t3,-1
    5d40:	1f076463          	bltu	a4,a6,5f28 <__udivdi3+0x47c>
    5d44:	1eb77263          	bgeu	a4,a1,5f28 <__udivdi3+0x47c>
    5d48:	ffee0e13          	addi	t3,t3,-2
    5d4c:	01070733          	add	a4,a4,a6
    5d50:	40b70733          	sub	a4,a4,a1
    5d54:	02d75533          	divu	a0,a4,a3
    5d58:	01079793          	slli	a5,a5,0x10
    5d5c:	0107d793          	srli	a5,a5,0x10
    5d60:	02d77733          	remu	a4,a4,a3
    5d64:	02a60333          	mul	t1,a2,a0
    5d68:	01071713          	slli	a4,a4,0x10
    5d6c:	00e7e7b3          	or	a5,a5,a4
    5d70:	0067fe63          	bgeu	a5,t1,5d8c <__udivdi3+0x2e0>
    5d74:	00f807b3          	add	a5,a6,a5
    5d78:	fff50713          	addi	a4,a0,-1
    5d7c:	1907ee63          	bltu	a5,a6,5f18 <__udivdi3+0x46c>
    5d80:	1867fc63          	bgeu	a5,t1,5f18 <__udivdi3+0x46c>
    5d84:	ffe50513          	addi	a0,a0,-2
    5d88:	010787b3          	add	a5,a5,a6
    5d8c:	010e1593          	slli	a1,t3,0x10
    5d90:	406787b3          	sub	a5,a5,t1
    5d94:	00a5e5b3          	or	a1,a1,a0
    5d98:	eb1ff06f          	j	5c48 <__udivdi3+0x19c>
    5d9c:	1006b793          	sltiu	a5,a3,256
    5da0:	0017b793          	seqz	a5,a5
    5da4:	00379793          	slli	a5,a5,0x3
    5da8:	00f6d833          	srl	a6,a3,a5
    5dac:	00005717          	auipc	a4,0x5
    5db0:	11070713          	addi	a4,a4,272 # aebc <__clz_tab>
    5db4:	01070733          	add	a4,a4,a6
    5db8:	00074703          	lbu	a4,0(a4)
    5dbc:	02000893          	li	a7,32
    5dc0:	00f70733          	add	a4,a4,a5
    5dc4:	40e88833          	sub	a6,a7,a4
    5dc8:	e0e88ee3          	beq	a7,a4,5be4 <__udivdi3+0x138>
    5dcc:	00e65e33          	srl	t3,a2,a4
    5dd0:	010696b3          	sll	a3,a3,a6
    5dd4:	00de6e33          	or	t3,t3,a3
    5dd8:	00e5d8b3          	srl	a7,a1,a4
    5ddc:	010e5e93          	srli	t4,t3,0x10
    5de0:	03d8d7b3          	divu	a5,a7,t4
    5de4:	010e1313          	slli	t1,t3,0x10
    5de8:	010595b3          	sll	a1,a1,a6
    5dec:	01035313          	srli	t1,t1,0x10
    5df0:	00e55733          	srl	a4,a0,a4
    5df4:	00b76733          	or	a4,a4,a1
    5df8:	01075693          	srli	a3,a4,0x10
    5dfc:	01061633          	sll	a2,a2,a6
    5e00:	03d8f8b3          	remu	a7,a7,t4
    5e04:	02f305b3          	mul	a1,t1,a5
    5e08:	01089893          	slli	a7,a7,0x10
    5e0c:	0116e6b3          	or	a3,a3,a7
    5e10:	00b6fe63          	bgeu	a3,a1,5e2c <__udivdi3+0x380>
    5e14:	00de06b3          	add	a3,t3,a3
    5e18:	fff78893          	addi	a7,a5,-1
    5e1c:	11c6ea63          	bltu	a3,t3,5f30 <__udivdi3+0x484>
    5e20:	10b6f863          	bgeu	a3,a1,5f30 <__udivdi3+0x484>
    5e24:	ffe78793          	addi	a5,a5,-2
    5e28:	01c686b3          	add	a3,a3,t3
    5e2c:	40b686b3          	sub	a3,a3,a1
    5e30:	03d6d5b3          	divu	a1,a3,t4
    5e34:	01071713          	slli	a4,a4,0x10
    5e38:	01075713          	srli	a4,a4,0x10
    5e3c:	03d6f6b3          	remu	a3,a3,t4
    5e40:	02b308b3          	mul	a7,t1,a1
    5e44:	01069693          	slli	a3,a3,0x10
    5e48:	00d76733          	or	a4,a4,a3
    5e4c:	01177e63          	bgeu	a4,a7,5e68 <__udivdi3+0x3bc>
    5e50:	00ee0733          	add	a4,t3,a4
    5e54:	fff58693          	addi	a3,a1,-1
    5e58:	0dc76463          	bltu	a4,t3,5f20 <__udivdi3+0x474>
    5e5c:	0d177263          	bgeu	a4,a7,5f20 <__udivdi3+0x474>
    5e60:	ffe58593          	addi	a1,a1,-2
    5e64:	01c70733          	add	a4,a4,t3
    5e68:	01079793          	slli	a5,a5,0x10
    5e6c:	00010eb7          	lui	t4,0x10
    5e70:	00b7e7b3          	or	a5,a5,a1
    5e74:	fffe8693          	addi	a3,t4,-1 # ffff <_end+0xdff>
    5e78:	00d7f5b3          	and	a1,a5,a3
    5e7c:	0107d313          	srli	t1,a5,0x10
    5e80:	00d676b3          	and	a3,a2,a3
    5e84:	01065613          	srli	a2,a2,0x10
    5e88:	02d58e33          	mul	t3,a1,a3
    5e8c:	41170733          	sub	a4,a4,a7
    5e90:	02d306b3          	mul	a3,t1,a3
    5e94:	010e5893          	srli	a7,t3,0x10
    5e98:	02c585b3          	mul	a1,a1,a2
    5e9c:	00d585b3          	add	a1,a1,a3
    5ea0:	00b885b3          	add	a1,a7,a1
    5ea4:	02c30333          	mul	t1,t1,a2
    5ea8:	00d5f463          	bgeu	a1,a3,5eb0 <__udivdi3+0x404>
    5eac:	01d30333          	add	t1,t1,t4
    5eb0:	0105d693          	srli	a3,a1,0x10
    5eb4:	006686b3          	add	a3,a3,t1
    5eb8:	02d76a63          	bltu	a4,a3,5eec <__udivdi3+0x440>
    5ebc:	00d70863          	beq	a4,a3,5ecc <__udivdi3+0x420>
    5ec0:	00078513          	mv	a0,a5
    5ec4:	00000593          	li	a1,0
    5ec8:	00008067          	ret
    5ecc:	000106b7          	lui	a3,0x10
    5ed0:	fff68693          	addi	a3,a3,-1 # ffff <_end+0xdff>
    5ed4:	00d5f733          	and	a4,a1,a3
    5ed8:	01071713          	slli	a4,a4,0x10
    5edc:	00de7e33          	and	t3,t3,a3
    5ee0:	01051533          	sll	a0,a0,a6
    5ee4:	01c70733          	add	a4,a4,t3
    5ee8:	fce57ce3          	bgeu	a0,a4,5ec0 <__udivdi3+0x414>
    5eec:	fff78513          	addi	a0,a5,-1
    5ef0:	00000593          	li	a1,0
    5ef4:	00008067          	ret
    5ef8:	010007b7          	lui	a5,0x1000
    5efc:	04f67a63          	bgeu	a2,a5,5f50 <__udivdi3+0x4a4>
    5f00:	01065693          	srli	a3,a2,0x10
    5f04:	01000713          	li	a4,16
    5f08:	d0dff06f          	j	5c14 <__udivdi3+0x168>
    5f0c:	00000593          	li	a1,0
    5f10:	00100513          	li	a0,1
    5f14:	00008067          	ret
    5f18:	00070513          	mv	a0,a4
    5f1c:	e71ff06f          	j	5d8c <__udivdi3+0x2e0>
    5f20:	00068593          	mv	a1,a3
    5f24:	f45ff06f          	j	5e68 <__udivdi3+0x3bc>
    5f28:	00050e13          	mv	t3,a0
    5f2c:	e25ff06f          	j	5d50 <__udivdi3+0x2a4>
    5f30:	00088793          	mv	a5,a7
    5f34:	ef9ff06f          	j	5e2c <__udivdi3+0x380>
    5f38:	ffe50513          	addi	a0,a0,-2
    5f3c:	010787b3          	add	a5,a5,a6
    5f40:	d39ff06f          	j	5c78 <__udivdi3+0x1cc>
    5f44:	ffe50513          	addi	a0,a0,-2
    5f48:	010787b3          	add	a5,a5,a6
    5f4c:	c01ff06f          	j	5b4c <__udivdi3+0xa0>
    5f50:	01865693          	srli	a3,a2,0x18
    5f54:	01800713          	li	a4,24
    5f58:	cbdff06f          	j	5c14 <__udivdi3+0x168>

00005f5c <__umoddi3>:
    5f5c:	00060813          	mv	a6,a2
    5f60:	00050893          	mv	a7,a0
    5f64:	00058793          	mv	a5,a1
    5f68:	00058713          	mv	a4,a1
    5f6c:	0c069863          	bnez	a3,603c <__umoddi3+0xe0>
    5f70:	12c5fa63          	bgeu	a1,a2,60a4 <__umoddi3+0x148>
    5f74:	000107b7          	lui	a5,0x10
    5f78:	1cf66c63          	bltu	a2,a5,6150 <__umoddi3+0x1f4>
    5f7c:	010007b7          	lui	a5,0x1000
    5f80:	01800693          	li	a3,24
    5f84:	00f67463          	bgeu	a2,a5,5f8c <__umoddi3+0x30>
    5f88:	01000693          	li	a3,16
    5f8c:	00d65333          	srl	t1,a2,a3
    5f90:	00005797          	auipc	a5,0x5
    5f94:	f2c78793          	addi	a5,a5,-212 # aebc <__clz_tab>
    5f98:	006787b3          	add	a5,a5,t1
    5f9c:	0007c783          	lbu	a5,0(a5)
    5fa0:	02000313          	li	t1,32
    5fa4:	00d787b3          	add	a5,a5,a3
    5fa8:	40f306b3          	sub	a3,t1,a5
    5fac:	00f30c63          	beq	t1,a5,5fc4 <__umoddi3+0x68>
    5fb0:	00d59733          	sll	a4,a1,a3
    5fb4:	00f557b3          	srl	a5,a0,a5
    5fb8:	00d61833          	sll	a6,a2,a3
    5fbc:	00e7e733          	or	a4,a5,a4
    5fc0:	00d518b3          	sll	a7,a0,a3
    5fc4:	01085593          	srli	a1,a6,0x10
    5fc8:	02b75633          	divu	a2,a4,a1
    5fcc:	01081313          	slli	t1,a6,0x10
    5fd0:	01035313          	srli	t1,t1,0x10
    5fd4:	0108d793          	srli	a5,a7,0x10
    5fd8:	02b77733          	remu	a4,a4,a1
    5fdc:	02660633          	mul	a2,a2,t1
    5fe0:	01071713          	slli	a4,a4,0x10
    5fe4:	00e7e7b3          	or	a5,a5,a4
    5fe8:	00c7f863          	bgeu	a5,a2,5ff8 <__umoddi3+0x9c>
    5fec:	00f807b3          	add	a5,a6,a5
    5ff0:	0107e463          	bltu	a5,a6,5ff8 <__umoddi3+0x9c>
    5ff4:	3cc7e263          	bltu	a5,a2,63b8 <__umoddi3+0x45c>
    5ff8:	40c787b3          	sub	a5,a5,a2
    5ffc:	02b7d733          	divu	a4,a5,a1
    6000:	01089513          	slli	a0,a7,0x10
    6004:	01055513          	srli	a0,a0,0x10
    6008:	02b7f7b3          	remu	a5,a5,a1
    600c:	02670733          	mul	a4,a4,t1
    6010:	01079793          	slli	a5,a5,0x10
    6014:	00f56533          	or	a0,a0,a5
    6018:	00e57a63          	bgeu	a0,a4,602c <__umoddi3+0xd0>
    601c:	00a80533          	add	a0,a6,a0
    6020:	01056663          	bltu	a0,a6,602c <__umoddi3+0xd0>
    6024:	00e57463          	bgeu	a0,a4,602c <__umoddi3+0xd0>
    6028:	01050533          	add	a0,a0,a6
    602c:	40e50533          	sub	a0,a0,a4
    6030:	00d55533          	srl	a0,a0,a3
    6034:	00000593          	li	a1,0
    6038:	00008067          	ret
    603c:	00d5f463          	bgeu	a1,a3,6044 <__umoddi3+0xe8>
    6040:	00008067          	ret
    6044:	00010737          	lui	a4,0x10
    6048:	1ce6e663          	bltu	a3,a4,6214 <__umoddi3+0x2b8>
    604c:	01000737          	lui	a4,0x1000
    6050:	01800813          	li	a6,24
    6054:	00e6f463          	bgeu	a3,a4,605c <__umoddi3+0x100>
    6058:	01000813          	li	a6,16
    605c:	0106d333          	srl	t1,a3,a6
    6060:	00005717          	auipc	a4,0x5
    6064:	e5c70713          	addi	a4,a4,-420 # aebc <__clz_tab>
    6068:	00670733          	add	a4,a4,t1
    606c:	00074703          	lbu	a4,0(a4)
    6070:	02000313          	li	t1,32
    6074:	01070733          	add	a4,a4,a6
    6078:	40e30833          	sub	a6,t1,a4
    607c:	1ce31463          	bne	t1,a4,6244 <__umoddi3+0x2e8>
    6080:	00b6e463          	bltu	a3,a1,6088 <__umoddi3+0x12c>
    6084:	00c56a63          	bltu	a0,a2,6098 <__umoddi3+0x13c>
    6088:	40c508b3          	sub	a7,a0,a2
    608c:	40d586b3          	sub	a3,a1,a3
    6090:	011537b3          	sltu	a5,a0,a7
    6094:	40f687b3          	sub	a5,a3,a5
    6098:	00088513          	mv	a0,a7
    609c:	00078593          	mv	a1,a5
    60a0:	00008067          	ret
    60a4:	0a060e63          	beqz	a2,6160 <__umoddi3+0x204>
    60a8:	000107b7          	lui	a5,0x10
    60ac:	2ef67463          	bgeu	a2,a5,6394 <__umoddi3+0x438>
    60b0:	10063713          	sltiu	a4,a2,256
    60b4:	00173713          	seqz	a4,a4
    60b8:	00371713          	slli	a4,a4,0x3
    60bc:	00e656b3          	srl	a3,a2,a4
    60c0:	00005797          	auipc	a5,0x5
    60c4:	dfc78793          	addi	a5,a5,-516 # aebc <__clz_tab>
    60c8:	00d787b3          	add	a5,a5,a3
    60cc:	0007c783          	lbu	a5,0(a5)
    60d0:	02000313          	li	t1,32
    60d4:	00e787b3          	add	a5,a5,a4
    60d8:	40f306b3          	sub	a3,t1,a5
    60dc:	0af31663          	bne	t1,a5,6188 <__umoddi3+0x22c>
    60e0:	40c58733          	sub	a4,a1,a2
    60e4:	01065313          	srli	t1,a2,0x10
    60e8:	01061613          	slli	a2,a2,0x10
    60ec:	01065613          	srli	a2,a2,0x10
    60f0:	026755b3          	divu	a1,a4,t1
    60f4:	0108d793          	srli	a5,a7,0x10
    60f8:	02677733          	remu	a4,a4,t1
    60fc:	02c585b3          	mul	a1,a1,a2
    6100:	01071713          	slli	a4,a4,0x10
    6104:	00e7e7b3          	or	a5,a5,a4
    6108:	00b7fa63          	bgeu	a5,a1,611c <__umoddi3+0x1c0>
    610c:	00f807b3          	add	a5,a6,a5
    6110:	0107e663          	bltu	a5,a6,611c <__umoddi3+0x1c0>
    6114:	00b7f463          	bgeu	a5,a1,611c <__umoddi3+0x1c0>
    6118:	010787b3          	add	a5,a5,a6
    611c:	40b787b3          	sub	a5,a5,a1
    6120:	0267d733          	divu	a4,a5,t1
    6124:	01089893          	slli	a7,a7,0x10
    6128:	0108d893          	srli	a7,a7,0x10
    612c:	0267f7b3          	remu	a5,a5,t1
    6130:	02c70733          	mul	a4,a4,a2
    6134:	01079513          	slli	a0,a5,0x10
    6138:	00a8e533          	or	a0,a7,a0
    613c:	eee560e3          	bltu	a0,a4,601c <__umoddi3+0xc0>
    6140:	40e50533          	sub	a0,a0,a4
    6144:	00d55533          	srl	a0,a0,a3
    6148:	00000593          	li	a1,0
    614c:	00008067          	ret
    6150:	10063693          	sltiu	a3,a2,256
    6154:	0016b693          	seqz	a3,a3
    6158:	00369693          	slli	a3,a3,0x3
    615c:	e31ff06f          	j	5f8c <__umoddi3+0x30>
    6160:	00000693          	li	a3,0
    6164:	00005797          	auipc	a5,0x5
    6168:	d5878793          	addi	a5,a5,-680 # aebc <__clz_tab>
    616c:	00d787b3          	add	a5,a5,a3
    6170:	0007c783          	lbu	a5,0(a5)
    6174:	00000713          	li	a4,0
    6178:	02000313          	li	t1,32
    617c:	00e787b3          	add	a5,a5,a4
    6180:	40f306b3          	sub	a3,t1,a5
    6184:	f4f30ee3          	beq	t1,a5,60e0 <__umoddi3+0x184>
    6188:	00d61833          	sll	a6,a2,a3
    618c:	00f5de33          	srl	t3,a1,a5
    6190:	01085313          	srli	t1,a6,0x10
    6194:	026e5eb3          	divu	t4,t3,t1
    6198:	01081613          	slli	a2,a6,0x10
    619c:	00d595b3          	sll	a1,a1,a3
    61a0:	00f55733          	srl	a4,a0,a5
    61a4:	01065613          	srli	a2,a2,0x10
    61a8:	00b76733          	or	a4,a4,a1
    61ac:	01075793          	srli	a5,a4,0x10
    61b0:	00d518b3          	sll	a7,a0,a3
    61b4:	026e7e33          	remu	t3,t3,t1
    61b8:	02ce85b3          	mul	a1,t4,a2
    61bc:	010e1e13          	slli	t3,t3,0x10
    61c0:	01c7e7b3          	or	a5,a5,t3
    61c4:	00b7fa63          	bgeu	a5,a1,61d8 <__umoddi3+0x27c>
    61c8:	00f807b3          	add	a5,a6,a5
    61cc:	0107e663          	bltu	a5,a6,61d8 <__umoddi3+0x27c>
    61d0:	00b7f463          	bgeu	a5,a1,61d8 <__umoddi3+0x27c>
    61d4:	010787b3          	add	a5,a5,a6
    61d8:	40b787b3          	sub	a5,a5,a1
    61dc:	0267d5b3          	divu	a1,a5,t1
    61e0:	01071713          	slli	a4,a4,0x10
    61e4:	01075713          	srli	a4,a4,0x10
    61e8:	0267f7b3          	remu	a5,a5,t1
    61ec:	02c585b3          	mul	a1,a1,a2
    61f0:	01079793          	slli	a5,a5,0x10
    61f4:	00f76733          	or	a4,a4,a5
    61f8:	00b77a63          	bgeu	a4,a1,620c <__umoddi3+0x2b0>
    61fc:	00e80733          	add	a4,a6,a4
    6200:	01076663          	bltu	a4,a6,620c <__umoddi3+0x2b0>
    6204:	00b77463          	bgeu	a4,a1,620c <__umoddi3+0x2b0>
    6208:	01070733          	add	a4,a4,a6
    620c:	40b70733          	sub	a4,a4,a1
    6210:	ee1ff06f          	j	60f0 <__umoddi3+0x194>
    6214:	1006b813          	sltiu	a6,a3,256
    6218:	00183813          	seqz	a6,a6
    621c:	00381813          	slli	a6,a6,0x3
    6220:	0106d333          	srl	t1,a3,a6
    6224:	00005717          	auipc	a4,0x5
    6228:	c9870713          	addi	a4,a4,-872 # aebc <__clz_tab>
    622c:	00670733          	add	a4,a4,t1
    6230:	00074703          	lbu	a4,0(a4)
    6234:	02000313          	li	t1,32
    6238:	01070733          	add	a4,a4,a6
    623c:	40e30833          	sub	a6,t1,a4
    6240:	e4e300e3          	beq	t1,a4,6080 <__umoddi3+0x124>
    6244:	010696b3          	sll	a3,a3,a6
    6248:	00e658b3          	srl	a7,a2,a4
    624c:	00d8e8b3          	or	a7,a7,a3
    6250:	00e5de33          	srl	t3,a1,a4
    6254:	0108df13          	srli	t5,a7,0x10
    6258:	03ee57b3          	divu	a5,t3,t5
    625c:	01089e93          	slli	t4,a7,0x10
    6260:	010ede93          	srli	t4,t4,0x10
    6264:	00e556b3          	srl	a3,a0,a4
    6268:	01051333          	sll	t1,a0,a6
    626c:	010595b3          	sll	a1,a1,a6
    6270:	00b6e5b3          	or	a1,a3,a1
    6274:	0105d693          	srli	a3,a1,0x10
    6278:	01061633          	sll	a2,a2,a6
    627c:	03ee7e33          	remu	t3,t3,t5
    6280:	02fe8533          	mul	a0,t4,a5
    6284:	010e1e13          	slli	t3,t3,0x10
    6288:	01c6e6b3          	or	a3,a3,t3
    628c:	00a6fe63          	bgeu	a3,a0,62a8 <__umoddi3+0x34c>
    6290:	00d886b3          	add	a3,a7,a3
    6294:	fff78e13          	addi	t3,a5,-1
    6298:	1116ec63          	bltu	a3,a7,63b0 <__umoddi3+0x454>
    629c:	10a6fa63          	bgeu	a3,a0,63b0 <__umoddi3+0x454>
    62a0:	ffe78793          	addi	a5,a5,-2
    62a4:	011686b3          	add	a3,a3,a7
    62a8:	40a686b3          	sub	a3,a3,a0
    62ac:	03e6d533          	divu	a0,a3,t5
    62b0:	01059593          	slli	a1,a1,0x10
    62b4:	0105d593          	srli	a1,a1,0x10
    62b8:	03e6f6b3          	remu	a3,a3,t5
    62bc:	02ae8eb3          	mul	t4,t4,a0
    62c0:	01069693          	slli	a3,a3,0x10
    62c4:	00d5e5b3          	or	a1,a1,a3
    62c8:	01d5fe63          	bgeu	a1,t4,62e4 <__umoddi3+0x388>
    62cc:	00b885b3          	add	a1,a7,a1
    62d0:	fff50693          	addi	a3,a0,-1
    62d4:	0d15ea63          	bltu	a1,a7,63a8 <__umoddi3+0x44c>
    62d8:	0dd5f863          	bgeu	a1,t4,63a8 <__umoddi3+0x44c>
    62dc:	ffe50513          	addi	a0,a0,-2
    62e0:	011585b3          	add	a1,a1,a7
    62e4:	01079693          	slli	a3,a5,0x10
    62e8:	000102b7          	lui	t0,0x10
    62ec:	00a6e6b3          	or	a3,a3,a0
    62f0:	fff28513          	addi	a0,t0,-1 # ffff <_end+0xdff>
    62f4:	00a6fe33          	and	t3,a3,a0
    62f8:	01065f93          	srli	t6,a2,0x10
    62fc:	0106d693          	srli	a3,a3,0x10
    6300:	00a67533          	and	a0,a2,a0
    6304:	02ae0f33          	mul	t5,t3,a0
    6308:	41d585b3          	sub	a1,a1,t4
    630c:	02a68533          	mul	a0,a3,a0
    6310:	010f5793          	srli	a5,t5,0x10
    6314:	03fe0e33          	mul	t3,t3,t6
    6318:	00ae0e33          	add	t3,t3,a0
    631c:	01c787b3          	add	a5,a5,t3
    6320:	03f686b3          	mul	a3,a3,t6
    6324:	00a7f463          	bgeu	a5,a0,632c <__umoddi3+0x3d0>
    6328:	005686b3          	add	a3,a3,t0
    632c:	00010eb7          	lui	t4,0x10
    6330:	fffe8e93          	addi	t4,t4,-1 # ffff <_end+0xdff>
    6334:	01d7f533          	and	a0,a5,t4
    6338:	0107de13          	srli	t3,a5,0x10
    633c:	01051513          	slli	a0,a0,0x10
    6340:	01df7f33          	and	t5,t5,t4
    6344:	00de07b3          	add	a5,t3,a3
    6348:	01e50533          	add	a0,a0,t5
    634c:	02f5e863          	bltu	a1,a5,637c <__umoddi3+0x420>
    6350:	02f58463          	beq	a1,a5,6378 <__umoddi3+0x41c>
    6354:	40a30533          	sub	a0,t1,a0
    6358:	00a33333          	sltu	t1,t1,a0
    635c:	40f585b3          	sub	a1,a1,a5
    6360:	406585b3          	sub	a1,a1,t1
    6364:	00e59733          	sll	a4,a1,a4
    6368:	01055533          	srl	a0,a0,a6
    636c:	00a76533          	or	a0,a4,a0
    6370:	0105d5b3          	srl	a1,a1,a6
    6374:	00008067          	ret
    6378:	fca37ee3          	bgeu	t1,a0,6354 <__umoddi3+0x3f8>
    637c:	40c50633          	sub	a2,a0,a2
    6380:	00c53533          	sltu	a0,a0,a2
    6384:	011508b3          	add	a7,a0,a7
    6388:	411787b3          	sub	a5,a5,a7
    638c:	00060513          	mv	a0,a2
    6390:	fc5ff06f          	j	6354 <__umoddi3+0x3f8>
    6394:	010007b7          	lui	a5,0x1000
    6398:	02f67463          	bgeu	a2,a5,63c0 <__umoddi3+0x464>
    639c:	01065693          	srli	a3,a2,0x10
    63a0:	01000713          	li	a4,16
    63a4:	d1dff06f          	j	60c0 <__umoddi3+0x164>
    63a8:	00068513          	mv	a0,a3
    63ac:	f39ff06f          	j	62e4 <__umoddi3+0x388>
    63b0:	000e0793          	mv	a5,t3
    63b4:	ef5ff06f          	j	62a8 <__umoddi3+0x34c>
    63b8:	010787b3          	add	a5,a5,a6
    63bc:	c3dff06f          	j	5ff8 <__umoddi3+0x9c>
    63c0:	01865693          	srli	a3,a2,0x18
    63c4:	01800713          	li	a4,24
    63c8:	cf9ff06f          	j	60c0 <__umoddi3+0x164>

000063cc <__adddf3>:
    63cc:	001007b7          	lui	a5,0x100
    63d0:	fe010113          	addi	sp,sp,-32
    63d4:	fff78e93          	addi	t4,a5,-1 # fffff <__freertos_irq_stack_top+0xefdff>
    63d8:	00bef833          	and	a6,t4,a1
    63dc:	00def7b3          	and	a5,t4,a3
    63e0:	0146d313          	srli	t1,a3,0x14
    63e4:	01212823          	sw	s2,16(sp)
    63e8:	0145d913          	srli	s2,a1,0x14
    63ec:	00379793          	slli	a5,a5,0x3
    63f0:	00812c23          	sw	s0,24(sp)
    63f4:	00381813          	slli	a6,a6,0x3
    63f8:	01f5d413          	srli	s0,a1,0x1f
    63fc:	01d55713          	srli	a4,a0,0x1d
    6400:	01d65893          	srli	a7,a2,0x1d
    6404:	7ff97913          	andi	s2,s2,2047
    6408:	7ff37313          	andi	t1,t1,2047
    640c:	00112e23          	sw	ra,28(sp)
    6410:	00912a23          	sw	s1,20(sp)
    6414:	01312623          	sw	s3,12(sp)
    6418:	01f6d693          	srli	a3,a3,0x1f
    641c:	00f8e8b3          	or	a7,a7,a5
    6420:	01076733          	or	a4,a4,a6
    6424:	00351593          	slli	a1,a0,0x3
    6428:	00361f13          	slli	t5,a2,0x3
    642c:	406907b3          	sub	a5,s2,t1
    6430:	1ed40463          	beq	s0,a3,6618 <__adddf3+0x24c>
    6434:	16f05263          	blez	a5,6598 <__adddf3+0x1cc>
    6438:	28030663          	beqz	t1,66c4 <__adddf3+0x2f8>
    643c:	7ff00693          	li	a3,2047
    6440:	42d90663          	beq	s2,a3,686c <__adddf3+0x4a0>
    6444:	03800693          	li	a3,56
    6448:	00100613          	li	a2,1
    644c:	02f6ce63          	blt	a3,a5,6488 <__adddf3+0xbc>
    6450:	008006b7          	lui	a3,0x800
    6454:	00d8e8b3          	or	a7,a7,a3
    6458:	01f00693          	li	a3,31
    645c:	52f6ce63          	blt	a3,a5,6998 <__adddf3+0x5cc>
    6460:	02000693          	li	a3,32
    6464:	40f686b3          	sub	a3,a3,a5
    6468:	00d89633          	sll	a2,a7,a3
    646c:	00ff5533          	srl	a0,t5,a5
    6470:	00df16b3          	sll	a3,t5,a3
    6474:	00a66633          	or	a2,a2,a0
    6478:	00d036b3          	snez	a3,a3
    647c:	00f8d8b3          	srl	a7,a7,a5
    6480:	00d66633          	or	a2,a2,a3
    6484:	41170733          	sub	a4,a4,a7
    6488:	40c58633          	sub	a2,a1,a2
    648c:	00c5b5b3          	sltu	a1,a1,a2
    6490:	00060493          	mv	s1,a2
    6494:	40b709b3          	sub	s3,a4,a1
    6498:	00899793          	slli	a5,s3,0x8
    649c:	3207da63          	bgez	a5,67d0 <__adddf3+0x404>
    64a0:	008007b7          	lui	a5,0x800
    64a4:	fff78793          	addi	a5,a5,-1 # 7fffff <__freertos_irq_stack_top+0x7efdff>
    64a8:	00f9f9b3          	and	s3,s3,a5
    64ac:	2c098863          	beqz	s3,677c <__adddf3+0x3b0>
    64b0:	00098513          	mv	a0,s3
    64b4:	458020ef          	jal	890c <__clzsi2>
    64b8:	ff850793          	addi	a5,a0,-8
    64bc:	02000693          	li	a3,32
    64c0:	40f68733          	sub	a4,a3,a5
    64c4:	00e4d733          	srl	a4,s1,a4
    64c8:	00f999b3          	sll	s3,s3,a5
    64cc:	01376733          	or	a4,a4,s3
    64d0:	00f494b3          	sll	s1,s1,a5
    64d4:	4b27c863          	blt	a5,s2,6984 <__adddf3+0x5b8>
    64d8:	412787b3          	sub	a5,a5,s2
    64dc:	00178793          	addi	a5,a5,1
    64e0:	40f686b3          	sub	a3,a3,a5
    64e4:	00d49633          	sll	a2,s1,a3
    64e8:	00f4d9b3          	srl	s3,s1,a5
    64ec:	00c03633          	snez	a2,a2
    64f0:	01366633          	or	a2,a2,s3
    64f4:	00d716b3          	sll	a3,a4,a3
    64f8:	00c6e4b3          	or	s1,a3,a2
    64fc:	00f759b3          	srl	s3,a4,a5
    6500:	00000913          	li	s2,0
    6504:	0074f793          	andi	a5,s1,7
    6508:	02078063          	beqz	a5,6528 <__adddf3+0x15c>
    650c:	00f4f793          	andi	a5,s1,15
    6510:	00400713          	li	a4,4
    6514:	00e78a63          	beq	a5,a4,6528 <__adddf3+0x15c>
    6518:	00448793          	addi	a5,s1,4
    651c:	0097b633          	sltu	a2,a5,s1
    6520:	00c989b3          	add	s3,s3,a2
    6524:	00078493          	mv	s1,a5
    6528:	00899793          	slli	a5,s3,0x8
    652c:	6e07da63          	bgez	a5,6c20 <__adddf3+0x854>
    6530:	00190793          	addi	a5,s2,1
    6534:	7ff00713          	li	a4,2047
    6538:	00040e13          	mv	t3,s0
    653c:	2ae78663          	beq	a5,a4,67e8 <__adddf3+0x41c>
    6540:	ff800737          	lui	a4,0xff800
    6544:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7efdff>
    6548:	00e9f733          	and	a4,s3,a4
    654c:	7ff7f793          	andi	a5,a5,2047
    6550:	01d71813          	slli	a6,a4,0x1d
    6554:	0034d613          	srli	a2,s1,0x3
    6558:	00971713          	slli	a4,a4,0x9
    655c:	00c86833          	or	a6,a6,a2
    6560:	00c75713          	srli	a4,a4,0xc
    6564:	01c12083          	lw	ra,28(sp)
    6568:	01812403          	lw	s0,24(sp)
    656c:	01479793          	slli	a5,a5,0x14
    6570:	00e7e7b3          	or	a5,a5,a4
    6574:	01fe1713          	slli	a4,t3,0x1f
    6578:	00e7e7b3          	or	a5,a5,a4
    657c:	01412483          	lw	s1,20(sp)
    6580:	01012903          	lw	s2,16(sp)
    6584:	00c12983          	lw	s3,12(sp)
    6588:	00080513          	mv	a0,a6
    658c:	00078593          	mv	a1,a5
    6590:	02010113          	addi	sp,sp,32
    6594:	00008067          	ret
    6598:	14078c63          	beqz	a5,66f0 <__adddf3+0x324>
    659c:	412307b3          	sub	a5,t1,s2
    65a0:	3c091263          	bnez	s2,6964 <__adddf3+0x598>
    65a4:	00b76533          	or	a0,a4,a1
    65a8:	4c050463          	beqz	a0,6a70 <__adddf3+0x6a4>
    65ac:	fff78513          	addi	a0,a5,-1
    65b0:	60050263          	beqz	a0,6bb4 <__adddf3+0x7e8>
    65b4:	7ff00813          	li	a6,2047
    65b8:	57078663          	beq	a5,a6,6b24 <__adddf3+0x758>
    65bc:	03800793          	li	a5,56
    65c0:	00100613          	li	a2,1
    65c4:	02a7cc63          	blt	a5,a0,65fc <__adddf3+0x230>
    65c8:	00050793          	mv	a5,a0
    65cc:	01f00613          	li	a2,31
    65d0:	56f64c63          	blt	a2,a5,6b48 <__adddf3+0x77c>
    65d4:	02000513          	li	a0,32
    65d8:	40f50533          	sub	a0,a0,a5
    65dc:	00a71633          	sll	a2,a4,a0
    65e0:	00f5d833          	srl	a6,a1,a5
    65e4:	00a59533          	sll	a0,a1,a0
    65e8:	01066633          	or	a2,a2,a6
    65ec:	00a03533          	snez	a0,a0
    65f0:	00f75733          	srl	a4,a4,a5
    65f4:	00a66633          	or	a2,a2,a0
    65f8:	40e888b3          	sub	a7,a7,a4
    65fc:	40cf0633          	sub	a2,t5,a2
    6600:	00cf3733          	sltu	a4,t5,a2
    6604:	00060493          	mv	s1,a2
    6608:	40e889b3          	sub	s3,a7,a4
    660c:	00030913          	mv	s2,t1
    6610:	00068413          	mv	s0,a3
    6614:	e85ff06f          	j	6498 <__adddf3+0xcc>
    6618:	1ef05063          	blez	a5,67f8 <__adddf3+0x42c>
    661c:	14031063          	bnez	t1,675c <__adddf3+0x390>
    6620:	01e8e6b3          	or	a3,a7,t5
    6624:	26068c63          	beqz	a3,689c <__adddf3+0x4d0>
    6628:	fff78693          	addi	a3,a5,-1
    662c:	48068063          	beqz	a3,6aac <__adddf3+0x6e0>
    6630:	7ff00613          	li	a2,2047
    6634:	22c78c63          	beq	a5,a2,686c <__adddf3+0x4a0>
    6638:	03800793          	li	a5,56
    663c:	00100993          	li	s3,1
    6640:	02d7cc63          	blt	a5,a3,6678 <__adddf3+0x2ac>
    6644:	00068793          	mv	a5,a3
    6648:	01f00693          	li	a3,31
    664c:	4af6c063          	blt	a3,a5,6aec <__adddf3+0x720>
    6650:	02000693          	li	a3,32
    6654:	40f686b3          	sub	a3,a3,a5
    6658:	00d899b3          	sll	s3,a7,a3
    665c:	00ff5633          	srl	a2,t5,a5
    6660:	00df16b3          	sll	a3,t5,a3
    6664:	00c9e9b3          	or	s3,s3,a2
    6668:	00d036b3          	snez	a3,a3
    666c:	00f8d8b3          	srl	a7,a7,a5
    6670:	00d9e9b3          	or	s3,s3,a3
    6674:	01170733          	add	a4,a4,a7
    6678:	00b985b3          	add	a1,s3,a1
    667c:	0135b9b3          	sltu	s3,a1,s3
    6680:	00058493          	mv	s1,a1
    6684:	00e989b3          	add	s3,s3,a4
    6688:	00899793          	slli	a5,s3,0x8
    668c:	1407d263          	bgez	a5,67d0 <__adddf3+0x404>
    6690:	00190913          	addi	s2,s2,1
    6694:	7ff00793          	li	a5,2047
    6698:	36f90c63          	beq	s2,a5,6a10 <__adddf3+0x644>
    669c:	ff8007b7          	lui	a5,0xff800
    66a0:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7efdff>
    66a4:	0014f613          	andi	a2,s1,1
    66a8:	00f9f7b3          	and	a5,s3,a5
    66ac:	0014d713          	srli	a4,s1,0x1
    66b0:	00c76733          	or	a4,a4,a2
    66b4:	01f79613          	slli	a2,a5,0x1f
    66b8:	00e664b3          	or	s1,a2,a4
    66bc:	0017d993          	srli	s3,a5,0x1
    66c0:	e45ff06f          	j	6504 <__adddf3+0x138>
    66c4:	01e8e6b3          	or	a3,a7,t5
    66c8:	1c068a63          	beqz	a3,689c <__adddf3+0x4d0>
    66cc:	fff78693          	addi	a3,a5,-1
    66d0:	40068063          	beqz	a3,6ad0 <__adddf3+0x704>
    66d4:	7ff00613          	li	a2,2047
    66d8:	18c78a63          	beq	a5,a2,686c <__adddf3+0x4a0>
    66dc:	03800793          	li	a5,56
    66e0:	00100613          	li	a2,1
    66e4:	dad7c2e3          	blt	a5,a3,6488 <__adddf3+0xbc>
    66e8:	00068793          	mv	a5,a3
    66ec:	d6dff06f          	j	6458 <__adddf3+0x8c>
    66f0:	00190813          	addi	a6,s2,1
    66f4:	7fe87813          	andi	a6,a6,2046
    66f8:	22081c63          	bnez	a6,6930 <__adddf3+0x564>
    66fc:	00b76333          	or	t1,a4,a1
    6700:	01e8e833          	or	a6,a7,t5
    6704:	38091063          	bnez	s2,6a84 <__adddf3+0x6b8>
    6708:	46030e63          	beqz	t1,6b84 <__adddf3+0x7b8>
    670c:	40080663          	beqz	a6,6b18 <__adddf3+0x74c>
    6710:	41e589b3          	sub	s3,a1,t5
    6714:	0135b533          	sltu	a0,a1,s3
    6718:	41170633          	sub	a2,a4,a7
    671c:	40a60633          	sub	a2,a2,a0
    6720:	00861513          	slli	a0,a2,0x8
    6724:	50055e63          	bgez	a0,6c40 <__adddf3+0x874>
    6728:	40bf05b3          	sub	a1,t5,a1
    672c:	40e88733          	sub	a4,a7,a4
    6730:	00bf3f33          	sltu	t5,t5,a1
    6734:	41e70733          	sub	a4,a4,t5
    6738:	00871613          	slli	a2,a4,0x8
    673c:	00058493          	mv	s1,a1
    6740:	52065e63          	bgez	a2,6c7c <__adddf3+0x8b0>
    6744:	ff8007b7          	lui	a5,0xff800
    6748:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7efdff>
    674c:	00f77733          	and	a4,a4,a5
    6750:	00068e13          	mv	t3,a3
    6754:	00100793          	li	a5,1
    6758:	df9ff06f          	j	6550 <__adddf3+0x184>
    675c:	7ff00693          	li	a3,2047
    6760:	10d90663          	beq	s2,a3,686c <__adddf3+0x4a0>
    6764:	03800693          	li	a3,56
    6768:	00100993          	li	s3,1
    676c:	f0f6c6e3          	blt	a3,a5,6678 <__adddf3+0x2ac>
    6770:	008006b7          	lui	a3,0x800
    6774:	00d8e8b3          	or	a7,a7,a3
    6778:	ed1ff06f          	j	6648 <__adddf3+0x27c>
    677c:	00048513          	mv	a0,s1
    6780:	18c020ef          	jal	890c <__clzsi2>
    6784:	01850793          	addi	a5,a0,24
    6788:	01f00693          	li	a3,31
    678c:	d2f6d8e3          	bge	a3,a5,64bc <__adddf3+0xf0>
    6790:	ff850713          	addi	a4,a0,-8
    6794:	00e49733          	sll	a4,s1,a4
    6798:	2327c663          	blt	a5,s2,69c4 <__adddf3+0x5f8>
    679c:	41278933          	sub	s2,a5,s2
    67a0:	00190793          	addi	a5,s2,1
    67a4:	48f6d663          	bge	a3,a5,6c30 <__adddf3+0x864>
    67a8:	fe190913          	addi	s2,s2,-31
    67ac:	02000693          	li	a3,32
    67b0:	012754b3          	srl	s1,a4,s2
    67b4:	00d78c63          	beq	a5,a3,67cc <__adddf3+0x400>
    67b8:	04000693          	li	a3,64
    67bc:	40f687b3          	sub	a5,a3,a5
    67c0:	00f71733          	sll	a4,a4,a5
    67c4:	00e03733          	snez	a4,a4
    67c8:	00e4e4b3          	or	s1,s1,a4
    67cc:	00000913          	li	s2,0
    67d0:	0074f793          	andi	a5,s1,7
    67d4:	d2079ce3          	bnez	a5,650c <__adddf3+0x140>
    67d8:	00090793          	mv	a5,s2
    67dc:	0034d613          	srli	a2,s1,0x3
    67e0:	00098713          	mv	a4,s3
    67e4:	0c00006f          	j	68a4 <__adddf3+0x4d8>
    67e8:	7ff00793          	li	a5,2047
    67ec:	00000713          	li	a4,0
    67f0:	00000813          	li	a6,0
    67f4:	d71ff06f          	j	6564 <__adddf3+0x198>
    67f8:	0c078a63          	beqz	a5,68cc <__adddf3+0x500>
    67fc:	412307b3          	sub	a5,t1,s2
    6800:	1e090263          	beqz	s2,69e4 <__adddf3+0x618>
    6804:	7ff00693          	li	a3,2047
    6808:	32d30863          	beq	t1,a3,6b38 <__adddf3+0x76c>
    680c:	03800693          	li	a3,56
    6810:	00100993          	li	s3,1
    6814:	02f6ce63          	blt	a3,a5,6850 <__adddf3+0x484>
    6818:	008006b7          	lui	a3,0x800
    681c:	00d76733          	or	a4,a4,a3
    6820:	01f00693          	li	a3,31
    6824:	3cf6c863          	blt	a3,a5,6bf4 <__adddf3+0x828>
    6828:	02000693          	li	a3,32
    682c:	40f686b3          	sub	a3,a3,a5
    6830:	00d719b3          	sll	s3,a4,a3
    6834:	00f5d633          	srl	a2,a1,a5
    6838:	00d596b3          	sll	a3,a1,a3
    683c:	00c9e9b3          	or	s3,s3,a2
    6840:	00d036b3          	snez	a3,a3
    6844:	00f75733          	srl	a4,a4,a5
    6848:	00d9e9b3          	or	s3,s3,a3
    684c:	00e888b3          	add	a7,a7,a4
    6850:	01e98733          	add	a4,s3,t5
    6854:	013739b3          	sltu	s3,a4,s3
    6858:	00070493          	mv	s1,a4
    685c:	011989b3          	add	s3,s3,a7
    6860:	00030913          	mv	s2,t1
    6864:	e25ff06f          	j	6688 <__adddf3+0x2bc>
    6868:	02081063          	bnez	a6,6888 <__adddf3+0x4bc>
    686c:	00351613          	slli	a2,a0,0x3
    6870:	00365613          	srli	a2,a2,0x3
    6874:	01d71813          	slli	a6,a4,0x1d
    6878:	00c86833          	or	a6,a6,a2
    687c:	00375713          	srli	a4,a4,0x3
    6880:	01076733          	or	a4,a4,a6
    6884:	18070663          	beqz	a4,6a10 <__adddf3+0x644>
    6888:	00000e13          	li	t3,0
    688c:	7ff00793          	li	a5,2047
    6890:	00080737          	lui	a4,0x80
    6894:	00000813          	li	a6,0
    6898:	ccdff06f          	j	6564 <__adddf3+0x198>
    689c:	00351613          	slli	a2,a0,0x3
    68a0:	00365613          	srli	a2,a2,0x3
    68a4:	01d71813          	slli	a6,a4,0x1d
    68a8:	7ff00693          	li	a3,2047
    68ac:	00c86833          	or	a6,a6,a2
    68b0:	00375713          	srli	a4,a4,0x3
    68b4:	fcd786e3          	beq	a5,a3,6880 <__adddf3+0x4b4>
    68b8:	00c71713          	slli	a4,a4,0xc
    68bc:	00c75713          	srli	a4,a4,0xc
    68c0:	7ff7f793          	andi	a5,a5,2047
    68c4:	00040e13          	mv	t3,s0
    68c8:	c9dff06f          	j	6564 <__adddf3+0x198>
    68cc:	00190693          	addi	a3,s2,1
    68d0:	7fe6f813          	andi	a6,a3,2046
    68d4:	14081863          	bnez	a6,6a24 <__adddf3+0x658>
    68d8:	00b766b3          	or	a3,a4,a1
    68dc:	28091c63          	bnez	s2,6b74 <__adddf3+0x7a8>
    68e0:	30068263          	beqz	a3,6be4 <__adddf3+0x818>
    68e4:	01e8e6b3          	or	a3,a7,t5
    68e8:	22068863          	beqz	a3,6b18 <__adddf3+0x74c>
    68ec:	01e587b3          	add	a5,a1,t5
    68f0:	00b7b5b3          	sltu	a1,a5,a1
    68f4:	01170733          	add	a4,a4,a7
    68f8:	00b70733          	add	a4,a4,a1
    68fc:	0037d813          	srli	a6,a5,0x3
    6900:	00871793          	slli	a5,a4,0x8
    6904:	00040e13          	mv	t3,s0
    6908:	3407de63          	bgez	a5,6c64 <__adddf3+0x898>
    690c:	ff8007b7          	lui	a5,0xff800
    6910:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7efdff>
    6914:	00f77733          	and	a4,a4,a5
    6918:	01d71793          	slli	a5,a4,0x1d
    691c:	00375713          	srli	a4,a4,0x3
    6920:	0107e833          	or	a6,a5,a6
    6924:	01d77733          	and	a4,a4,t4
    6928:	00100793          	li	a5,1
    692c:	c39ff06f          	j	6564 <__adddf3+0x198>
    6930:	41e58833          	sub	a6,a1,t5
    6934:	0105b7b3          	sltu	a5,a1,a6
    6938:	411709b3          	sub	s3,a4,a7
    693c:	40f989b3          	sub	s3,s3,a5
    6940:	00899793          	slli	a5,s3,0x8
    6944:	00080493          	mv	s1,a6
    6948:	1007c663          	bltz	a5,6a54 <__adddf3+0x688>
    694c:	01386833          	or	a6,a6,s3
    6950:	b4081ee3          	bnez	a6,64ac <__adddf3+0xe0>
    6954:	00000e13          	li	t3,0
    6958:	00000793          	li	a5,0
    695c:	00000713          	li	a4,0
    6960:	c05ff06f          	j	6564 <__adddf3+0x198>
    6964:	7ff00513          	li	a0,2047
    6968:	1aa30e63          	beq	t1,a0,6b24 <__adddf3+0x758>
    696c:	03800513          	li	a0,56
    6970:	00100613          	li	a2,1
    6974:	c8f544e3          	blt	a0,a5,65fc <__adddf3+0x230>
    6978:	00800637          	lui	a2,0x800
    697c:	00c76733          	or	a4,a4,a2
    6980:	c4dff06f          	j	65cc <__adddf3+0x200>
    6984:	ff8009b7          	lui	s3,0xff800
    6988:	fff98993          	addi	s3,s3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7efdff>
    698c:	40f90933          	sub	s2,s2,a5
    6990:	013779b3          	and	s3,a4,s3
    6994:	b71ff06f          	j	6504 <__adddf3+0x138>
    6998:	fe078693          	addi	a3,a5,-32
    699c:	02000613          	li	a2,32
    69a0:	00d8d6b3          	srl	a3,a7,a3
    69a4:	00c78a63          	beq	a5,a2,69b8 <__adddf3+0x5ec>
    69a8:	04000613          	li	a2,64
    69ac:	40f607b3          	sub	a5,a2,a5
    69b0:	00f897b3          	sll	a5,a7,a5
    69b4:	00ff6f33          	or	t5,t5,a5
    69b8:	01e03633          	snez	a2,t5
    69bc:	00d66633          	or	a2,a2,a3
    69c0:	ac9ff06f          	j	6488 <__adddf3+0xbc>
    69c4:	ff8006b7          	lui	a3,0xff800
    69c8:	fff68693          	addi	a3,a3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7efdff>
    69cc:	40f907b3          	sub	a5,s2,a5
    69d0:	00d77733          	and	a4,a4,a3
    69d4:	01d71813          	slli	a6,a4,0x1d
    69d8:	01386833          	or	a6,a6,s3
    69dc:	00375713          	srli	a4,a4,0x3
    69e0:	ed9ff06f          	j	68b8 <__adddf3+0x4ec>
    69e4:	00b766b3          	or	a3,a4,a1
    69e8:	1e068663          	beqz	a3,6bd4 <__adddf3+0x808>
    69ec:	fff78693          	addi	a3,a5,-1
    69f0:	0a068e63          	beqz	a3,6aac <__adddf3+0x6e0>
    69f4:	7ff00513          	li	a0,2047
    69f8:	14a78063          	beq	a5,a0,6b38 <__adddf3+0x76c>
    69fc:	03800793          	li	a5,56
    6a00:	00100993          	li	s3,1
    6a04:	e4d7c6e3          	blt	a5,a3,6850 <__adddf3+0x484>
    6a08:	00068793          	mv	a5,a3
    6a0c:	e15ff06f          	j	6820 <__adddf3+0x454>
    6a10:	00040e13          	mv	t3,s0
    6a14:	7ff00793          	li	a5,2047
    6a18:	00000713          	li	a4,0
    6a1c:	00000813          	li	a6,0
    6a20:	b45ff06f          	j	6564 <__adddf3+0x198>
    6a24:	7ff00793          	li	a5,2047
    6a28:	fef684e3          	beq	a3,a5,6a10 <__adddf3+0x644>
    6a2c:	01e58f33          	add	t5,a1,t5
    6a30:	00bf35b3          	sltu	a1,t5,a1
    6a34:	011707b3          	add	a5,a4,a7
    6a38:	00b787b3          	add	a5,a5,a1
    6a3c:	01f79613          	slli	a2,a5,0x1f
    6a40:	001f5f13          	srli	t5,t5,0x1
    6a44:	01e664b3          	or	s1,a2,t5
    6a48:	0017d993          	srli	s3,a5,0x1
    6a4c:	00068913          	mv	s2,a3
    6a50:	ab5ff06f          	j	6504 <__adddf3+0x138>
    6a54:	40bf0633          	sub	a2,t5,a1
    6a58:	40e887b3          	sub	a5,a7,a4
    6a5c:	00cf3733          	sltu	a4,t5,a2
    6a60:	00060493          	mv	s1,a2
    6a64:	40e789b3          	sub	s3,a5,a4
    6a68:	00068413          	mv	s0,a3
    6a6c:	a41ff06f          	j	64ac <__adddf3+0xe0>
    6a70:	00361613          	slli	a2,a2,0x3
    6a74:	00365613          	srli	a2,a2,0x3
    6a78:	00068413          	mv	s0,a3
    6a7c:	00088713          	mv	a4,a7
    6a80:	e25ff06f          	j	68a4 <__adddf3+0x4d8>
    6a84:	de0312e3          	bnez	t1,6868 <__adddf3+0x49c>
    6a88:	1c080663          	beqz	a6,6c54 <__adddf3+0x888>
    6a8c:	0038d713          	srli	a4,a7,0x3
    6a90:	00361613          	slli	a2,a2,0x3
    6a94:	01d89893          	slli	a7,a7,0x1d
    6a98:	01176733          	or	a4,a4,a7
    6a9c:	00365613          	srli	a2,a2,0x3
    6aa0:	00c76733          	or	a4,a4,a2
    6aa4:	00068413          	mv	s0,a3
    6aa8:	dddff06f          	j	6884 <__adddf3+0x4b8>
    6aac:	01e58f33          	add	t5,a1,t5
    6ab0:	011708b3          	add	a7,a4,a7
    6ab4:	00bf35b3          	sltu	a1,t5,a1
    6ab8:	00b889b3          	add	s3,a7,a1
    6abc:	00899793          	slli	a5,s3,0x8
    6ac0:	000f0493          	mv	s1,t5
    6ac4:	0e07d463          	bgez	a5,6bac <__adddf3+0x7e0>
    6ac8:	00200913          	li	s2,2
    6acc:	bd1ff06f          	j	669c <__adddf3+0x2d0>
    6ad0:	41e58f33          	sub	t5,a1,t5
    6ad4:	411708b3          	sub	a7,a4,a7
    6ad8:	01e5b5b3          	sltu	a1,a1,t5
    6adc:	000f0493          	mv	s1,t5
    6ae0:	40b889b3          	sub	s3,a7,a1
    6ae4:	00100913          	li	s2,1
    6ae8:	9b1ff06f          	j	6498 <__adddf3+0xcc>
    6aec:	fe078693          	addi	a3,a5,-32
    6af0:	02000613          	li	a2,32
    6af4:	00d8d6b3          	srl	a3,a7,a3
    6af8:	00c78a63          	beq	a5,a2,6b0c <__adddf3+0x740>
    6afc:	04000613          	li	a2,64
    6b00:	40f607b3          	sub	a5,a2,a5
    6b04:	00f897b3          	sll	a5,a7,a5
    6b08:	00ff6f33          	or	t5,t5,a5
    6b0c:	01e039b3          	snez	s3,t5
    6b10:	00d9e9b3          	or	s3,s3,a3
    6b14:	b65ff06f          	j	6678 <__adddf3+0x2ac>
    6b18:	00351613          	slli	a2,a0,0x3
    6b1c:	00365993          	srli	s3,a2,0x3
    6b20:	eb5ff06f          	j	69d4 <__adddf3+0x608>
    6b24:	00361613          	slli	a2,a2,0x3
    6b28:	00365613          	srli	a2,a2,0x3
    6b2c:	00068413          	mv	s0,a3
    6b30:	00088713          	mv	a4,a7
    6b34:	d41ff06f          	j	6874 <__adddf3+0x4a8>
    6b38:	00361613          	slli	a2,a2,0x3
    6b3c:	00365613          	srli	a2,a2,0x3
    6b40:	00088713          	mv	a4,a7
    6b44:	d31ff06f          	j	6874 <__adddf3+0x4a8>
    6b48:	fe078513          	addi	a0,a5,-32
    6b4c:	02000613          	li	a2,32
    6b50:	00a75533          	srl	a0,a4,a0
    6b54:	00c78a63          	beq	a5,a2,6b68 <__adddf3+0x79c>
    6b58:	04000613          	li	a2,64
    6b5c:	40f607b3          	sub	a5,a2,a5
    6b60:	00f717b3          	sll	a5,a4,a5
    6b64:	00f5e5b3          	or	a1,a1,a5
    6b68:	00b03633          	snez	a2,a1
    6b6c:	00a66633          	or	a2,a2,a0
    6b70:	a8dff06f          	j	65fc <__adddf3+0x230>
    6b74:	fc0682e3          	beqz	a3,6b38 <__adddf3+0x76c>
    6b78:	01e8ef33          	or	t5,a7,t5
    6b7c:	d00f16e3          	bnez	t5,6888 <__adddf3+0x4bc>
    6b80:	cedff06f          	j	686c <__adddf3+0x4a0>
    6b84:	dc0808e3          	beqz	a6,6954 <__adddf3+0x588>
    6b88:	00361813          	slli	a6,a2,0x3
    6b8c:	01d89793          	slli	a5,a7,0x1d
    6b90:	00385813          	srli	a6,a6,0x3
    6b94:	0038d713          	srli	a4,a7,0x3
    6b98:	00f86833          	or	a6,a6,a5
    6b9c:	01d77733          	and	a4,a4,t4
    6ba0:	00068e13          	mv	t3,a3
    6ba4:	00000793          	li	a5,0
    6ba8:	9bdff06f          	j	6564 <__adddf3+0x198>
    6bac:	00100793          	li	a5,1
    6bb0:	c2dff06f          	j	67dc <__adddf3+0x410>
    6bb4:	40bf05b3          	sub	a1,t5,a1
    6bb8:	40e888b3          	sub	a7,a7,a4
    6bbc:	00bf3733          	sltu	a4,t5,a1
    6bc0:	00058493          	mv	s1,a1
    6bc4:	40e889b3          	sub	s3,a7,a4
    6bc8:	00068413          	mv	s0,a3
    6bcc:	00100913          	li	s2,1
    6bd0:	8c9ff06f          	j	6498 <__adddf3+0xcc>
    6bd4:	00361613          	slli	a2,a2,0x3
    6bd8:	00365613          	srli	a2,a2,0x3
    6bdc:	00088713          	mv	a4,a7
    6be0:	cc5ff06f          	j	68a4 <__adddf3+0x4d8>
    6be4:	00361613          	slli	a2,a2,0x3
    6be8:	00365993          	srli	s3,a2,0x3
    6bec:	00088713          	mv	a4,a7
    6bf0:	de5ff06f          	j	69d4 <__adddf3+0x608>
    6bf4:	fe078693          	addi	a3,a5,-32
    6bf8:	02000613          	li	a2,32
    6bfc:	00d756b3          	srl	a3,a4,a3
    6c00:	00c78a63          	beq	a5,a2,6c14 <__adddf3+0x848>
    6c04:	04000613          	li	a2,64
    6c08:	40f607b3          	sub	a5,a2,a5
    6c0c:	00f717b3          	sll	a5,a4,a5
    6c10:	00f5e5b3          	or	a1,a1,a5
    6c14:	00b039b3          	snez	s3,a1
    6c18:	00d9e9b3          	or	s3,s3,a3
    6c1c:	c35ff06f          	j	6850 <__adddf3+0x484>
    6c20:	0034d613          	srli	a2,s1,0x3
    6c24:	00090793          	mv	a5,s2
    6c28:	00098713          	mv	a4,s3
    6c2c:	c79ff06f          	j	68a4 <__adddf3+0x4d8>
    6c30:	02000693          	li	a3,32
    6c34:	40f686b3          	sub	a3,a3,a5
    6c38:	00000613          	li	a2,0
    6c3c:	8b5ff06f          	j	64f0 <__adddf3+0x124>
    6c40:	00c9e833          	or	a6,s3,a2
    6c44:	d00808e3          	beqz	a6,6954 <__adddf3+0x588>
    6c48:	0039d993          	srli	s3,s3,0x3
    6c4c:	00060713          	mv	a4,a2
    6c50:	d85ff06f          	j	69d4 <__adddf3+0x608>
    6c54:	00000e13          	li	t3,0
    6c58:	7ff00793          	li	a5,2047
    6c5c:	00080737          	lui	a4,0x80
    6c60:	905ff06f          	j	6564 <__adddf3+0x198>
    6c64:	01d71793          	slli	a5,a4,0x1d
    6c68:	00375713          	srli	a4,a4,0x3
    6c6c:	0107e833          	or	a6,a5,a6
    6c70:	01d77733          	and	a4,a4,t4
    6c74:	00000793          	li	a5,0
    6c78:	8edff06f          	j	6564 <__adddf3+0x198>
    6c7c:	01d71813          	slli	a6,a4,0x1d
    6c80:	0035d593          	srli	a1,a1,0x3
    6c84:	00b86833          	or	a6,a6,a1
    6c88:	00375713          	srli	a4,a4,0x3
    6c8c:	00068413          	mv	s0,a3
    6c90:	c29ff06f          	j	68b8 <__adddf3+0x4ec>

00006c94 <__divdf3>:
    6c94:	fd010113          	addi	sp,sp,-48
    6c98:	01312e23          	sw	s3,28(sp)
    6c9c:	0145d993          	srli	s3,a1,0x14
    6ca0:	02812423          	sw	s0,40(sp)
    6ca4:	02912223          	sw	s1,36(sp)
    6ca8:	03212023          	sw	s2,32(sp)
    6cac:	01412c23          	sw	s4,24(sp)
    6cb0:	01712623          	sw	s7,12(sp)
    6cb4:	00c59493          	slli	s1,a1,0xc
    6cb8:	02112623          	sw	ra,44(sp)
    6cbc:	01512a23          	sw	s5,20(sp)
    6cc0:	01612823          	sw	s6,16(sp)
    6cc4:	01812423          	sw	s8,8(sp)
    6cc8:	7ff9f993          	andi	s3,s3,2047
    6ccc:	00050413          	mv	s0,a0
    6cd0:	00060b93          	mv	s7,a2
    6cd4:	00068913          	mv	s2,a3
    6cd8:	00c4d493          	srli	s1,s1,0xc
    6cdc:	01f5da13          	srli	s4,a1,0x1f
    6ce0:	18098c63          	beqz	s3,6e78 <__divdf3+0x1e4>
    6ce4:	7ff00793          	li	a5,2047
    6ce8:	08f98a63          	beq	s3,a5,6d7c <__divdf3+0xe8>
    6cec:	00349493          	slli	s1,s1,0x3
    6cf0:	01d55793          	srli	a5,a0,0x1d
    6cf4:	0097e7b3          	or	a5,a5,s1
    6cf8:	00800737          	lui	a4,0x800
    6cfc:	00e7eab3          	or	s5,a5,a4
    6d00:	00351b13          	slli	s6,a0,0x3
    6d04:	c0198993          	addi	s3,s3,-1023
    6d08:	00000493          	li	s1,0
    6d0c:	00000c13          	li	s8,0
    6d10:	01495793          	srli	a5,s2,0x14
    6d14:	00c91413          	slli	s0,s2,0xc
    6d18:	7ff7f793          	andi	a5,a5,2047
    6d1c:	00c45413          	srli	s0,s0,0xc
    6d20:	01f95913          	srli	s2,s2,0x1f
    6d24:	08078463          	beqz	a5,6dac <__divdf3+0x118>
    6d28:	7ff00713          	li	a4,2047
    6d2c:	18e78c63          	beq	a5,a4,6ec4 <__divdf3+0x230>
    6d30:	00341413          	slli	s0,s0,0x3
    6d34:	01dbd713          	srli	a4,s7,0x1d
    6d38:	00876733          	or	a4,a4,s0
    6d3c:	c0178793          	addi	a5,a5,-1023
    6d40:	00800437          	lui	s0,0x800
    6d44:	00876433          	or	s0,a4,s0
    6d48:	003b9893          	slli	a7,s7,0x3
    6d4c:	40f989b3          	sub	s3,s3,a5
    6d50:	00000613          	li	a2,0
    6d54:	00f00713          	li	a4,15
    6d58:	012a46b3          	xor	a3,s4,s2
    6d5c:	24976663          	bltu	a4,s1,6fa8 <__divdf3+0x314>
    6d60:	00004717          	auipc	a4,0x4
    6d64:	11c70713          	addi	a4,a4,284 # ae7c <s_pages+0x12c>
    6d68:	00249493          	slli	s1,s1,0x2
    6d6c:	00e484b3          	add	s1,s1,a4
    6d70:	0004a783          	lw	a5,0(s1)
    6d74:	00e787b3          	add	a5,a5,a4
    6d78:	00078067          	jr	a5
    6d7c:	00a4eab3          	or	s5,s1,a0
    6d80:	1c0a9e63          	bnez	s5,6f5c <__divdf3+0x2c8>
    6d84:	01495793          	srli	a5,s2,0x14
    6d88:	00c91413          	slli	s0,s2,0xc
    6d8c:	7ff7f793          	andi	a5,a5,2047
    6d90:	00000b13          	li	s6,0
    6d94:	00800493          	li	s1,8
    6d98:	7ff00993          	li	s3,2047
    6d9c:	00200c13          	li	s8,2
    6da0:	00c45413          	srli	s0,s0,0xc
    6da4:	01f95913          	srli	s2,s2,0x1f
    6da8:	f80790e3          	bnez	a5,6d28 <__divdf3+0x94>
    6dac:	017468b3          	or	a7,s0,s7
    6db0:	1c088263          	beqz	a7,6f74 <__divdf3+0x2e0>
    6db4:	4a040a63          	beqz	s0,7268 <__divdf3+0x5d4>
    6db8:	00040513          	mv	a0,s0
    6dbc:	351010ef          	jal	890c <__clzsi2>
    6dc0:	00050793          	mv	a5,a0
    6dc4:	ff550693          	addi	a3,a0,-11
    6dc8:	01d00713          	li	a4,29
    6dcc:	ff878893          	addi	a7,a5,-8
    6dd0:	40d70733          	sub	a4,a4,a3
    6dd4:	01141433          	sll	s0,s0,a7
    6dd8:	00ebd733          	srl	a4,s7,a4
    6ddc:	00876433          	or	s0,a4,s0
    6de0:	011b98b3          	sll	a7,s7,a7
    6de4:	013787b3          	add	a5,a5,s3
    6de8:	3f378993          	addi	s3,a5,1011
    6dec:	00000613          	li	a2,0
    6df0:	f65ff06f          	j	6d54 <__divdf3+0xc0>
    6df4:	40f70733          	sub	a4,a4,a5
    6df8:	03800613          	li	a2,56
    6dfc:	4ee65a63          	bge	a2,a4,72f0 <__divdf3+0x65c>
    6e00:	00000793          	li	a5,0
    6e04:	00000613          	li	a2,0
    6e08:	00000713          	li	a4,0
    6e0c:	02c12083          	lw	ra,44(sp)
    6e10:	02812403          	lw	s0,40(sp)
    6e14:	01479793          	slli	a5,a5,0x14
    6e18:	00c7e7b3          	or	a5,a5,a2
    6e1c:	01f69693          	slli	a3,a3,0x1f
    6e20:	00d7e7b3          	or	a5,a5,a3
    6e24:	02412483          	lw	s1,36(sp)
    6e28:	02012903          	lw	s2,32(sp)
    6e2c:	01c12983          	lw	s3,28(sp)
    6e30:	01812a03          	lw	s4,24(sp)
    6e34:	01412a83          	lw	s5,20(sp)
    6e38:	01012b03          	lw	s6,16(sp)
    6e3c:	00c12b83          	lw	s7,12(sp)
    6e40:	00812c03          	lw	s8,8(sp)
    6e44:	00070513          	mv	a0,a4
    6e48:	00078593          	mv	a1,a5
    6e4c:	03010113          	addi	sp,sp,48
    6e50:	00008067          	ret
    6e54:	7ff00793          	li	a5,2047
    6e58:	00000613          	li	a2,0
    6e5c:	00000713          	li	a4,0
    6e60:	fadff06f          	j	6e0c <__divdf3+0x178>
    6e64:	00000693          	li	a3,0
    6e68:	7ff00793          	li	a5,2047
    6e6c:	00080637          	lui	a2,0x80
    6e70:	00000713          	li	a4,0
    6e74:	f99ff06f          	j	6e0c <__divdf3+0x178>
    6e78:	00a4eab3          	or	s5,s1,a0
    6e7c:	100a8c63          	beqz	s5,6f94 <__divdf3+0x300>
    6e80:	40048863          	beqz	s1,7290 <__divdf3+0x5fc>
    6e84:	00048513          	mv	a0,s1
    6e88:	285010ef          	jal	890c <__clzsi2>
    6e8c:	00050713          	mv	a4,a0
    6e90:	ff550693          	addi	a3,a0,-11
    6e94:	01d00793          	li	a5,29
    6e98:	ff870b13          	addi	s6,a4,-8
    6e9c:	40d787b3          	sub	a5,a5,a3
    6ea0:	016494b3          	sll	s1,s1,s6
    6ea4:	00f457b3          	srl	a5,s0,a5
    6ea8:	0097eab3          	or	s5,a5,s1
    6eac:	01641b33          	sll	s6,s0,s6
    6eb0:	c0d00993          	li	s3,-1011
    6eb4:	40e989b3          	sub	s3,s3,a4
    6eb8:	00000493          	li	s1,0
    6ebc:	00000c13          	li	s8,0
    6ec0:	e51ff06f          	j	6d10 <__divdf3+0x7c>
    6ec4:	017468b3          	or	a7,s0,s7
    6ec8:	80198993          	addi	s3,s3,-2047
    6ecc:	0a089c63          	bnez	a7,6f84 <__divdf3+0x2f0>
    6ed0:	0024e493          	ori	s1,s1,2
    6ed4:	00000413          	li	s0,0
    6ed8:	00200613          	li	a2,2
    6edc:	e79ff06f          	j	6d54 <__divdf3+0xc0>
    6ee0:	000a0913          	mv	s2,s4
    6ee4:	000a8413          	mv	s0,s5
    6ee8:	000b0893          	mv	a7,s6
    6eec:	00200793          	li	a5,2
    6ef0:	4efc0863          	beq	s8,a5,73e0 <__divdf3+0x74c>
    6ef4:	00300793          	li	a5,3
    6ef8:	f6fc06e3          	beq	s8,a5,6e64 <__divdf3+0x1d0>
    6efc:	00100793          	li	a5,1
    6f00:	00090693          	mv	a3,s2
    6f04:	eefc0ee3          	beq	s8,a5,6e00 <__divdf3+0x16c>
    6f08:	3ff98793          	addi	a5,s3,1023
    6f0c:	2af05663          	blez	a5,71b8 <__divdf3+0x524>
    6f10:	0078f713          	andi	a4,a7,7
    6f14:	4a071663          	bnez	a4,73c0 <__divdf3+0x72c>
    6f18:	00741713          	slli	a4,s0,0x7
    6f1c:	00075a63          	bgez	a4,6f30 <__divdf3+0x29c>
    6f20:	ff0007b7          	lui	a5,0xff000
    6f24:	fff78793          	addi	a5,a5,-1 # feffffff <__freertos_irq_stack_top+0xfefefdff>
    6f28:	00f47433          	and	s0,s0,a5
    6f2c:	40098793          	addi	a5,s3,1024
    6f30:	7fe00713          	li	a4,2046
    6f34:	f2f740e3          	blt	a4,a5,6e54 <__divdf3+0x1c0>
    6f38:	0038d893          	srli	a7,a7,0x3
    6f3c:	01d41713          	slli	a4,s0,0x1d
    6f40:	00941613          	slli	a2,s0,0x9
    6f44:	01176733          	or	a4,a4,a7
    6f48:	00c65613          	srli	a2,a2,0xc
    6f4c:	7ff7f793          	andi	a5,a5,2047
    6f50:	ebdff06f          	j	6e0c <__divdf3+0x178>
    6f54:	00060c13          	mv	s8,a2
    6f58:	f95ff06f          	j	6eec <__divdf3+0x258>
    6f5c:	00048a93          	mv	s5,s1
    6f60:	00050b13          	mv	s6,a0
    6f64:	00c00493          	li	s1,12
    6f68:	7ff00993          	li	s3,2047
    6f6c:	00300c13          	li	s8,3
    6f70:	da1ff06f          	j	6d10 <__divdf3+0x7c>
    6f74:	0014e493          	ori	s1,s1,1
    6f78:	00000413          	li	s0,0
    6f7c:	00100613          	li	a2,1
    6f80:	dd5ff06f          	j	6d54 <__divdf3+0xc0>
    6f84:	0034e493          	ori	s1,s1,3
    6f88:	000b8893          	mv	a7,s7
    6f8c:	00300613          	li	a2,3
    6f90:	dc5ff06f          	j	6d54 <__divdf3+0xc0>
    6f94:	00000b13          	li	s6,0
    6f98:	00400493          	li	s1,4
    6f9c:	00000993          	li	s3,0
    6fa0:	00100c13          	li	s8,1
    6fa4:	d6dff06f          	j	6d10 <__divdf3+0x7c>
    6fa8:	2b546463          	bltu	s0,s5,7250 <__divdf3+0x5bc>
    6fac:	2a8a8063          	beq	s5,s0,724c <__divdf3+0x5b8>
    6fb0:	000b0313          	mv	t1,s6
    6fb4:	fff98993          	addi	s3,s3,-1
    6fb8:	000a8793          	mv	a5,s5
    6fbc:	00000b13          	li	s6,0
    6fc0:	00841713          	slli	a4,s0,0x8
    6fc4:	01075513          	srli	a0,a4,0x10
    6fc8:	02a7d433          	divu	s0,a5,a0
    6fcc:	0188d613          	srli	a2,a7,0x18
    6fd0:	00e66633          	or	a2,a2,a4
    6fd4:	01061813          	slli	a6,a2,0x10
    6fd8:	01085813          	srli	a6,a6,0x10
    6fdc:	00889593          	slli	a1,a7,0x8
    6fe0:	01035713          	srli	a4,t1,0x10
    6fe4:	02a7f7b3          	remu	a5,a5,a0
    6fe8:	028808b3          	mul	a7,a6,s0
    6fec:	01079793          	slli	a5,a5,0x10
    6ff0:	00f767b3          	or	a5,a4,a5
    6ff4:	0117fa63          	bgeu	a5,a7,7008 <__divdf3+0x374>
    6ff8:	00f607b3          	add	a5,a2,a5
    6ffc:	fff40713          	addi	a4,s0,-1 # 7fffff <__freertos_irq_stack_top+0x7efdff>
    7000:	2ec7f063          	bgeu	a5,a2,72e0 <__divdf3+0x64c>
    7004:	00070413          	mv	s0,a4
    7008:	411787b3          	sub	a5,a5,a7
    700c:	02a7d8b3          	divu	a7,a5,a0
    7010:	01031713          	slli	a4,t1,0x10
    7014:	01075713          	srli	a4,a4,0x10
    7018:	02a7f7b3          	remu	a5,a5,a0
    701c:	03180fb3          	mul	t6,a6,a7
    7020:	01079793          	slli	a5,a5,0x10
    7024:	00f76733          	or	a4,a4,a5
    7028:	01f77a63          	bgeu	a4,t6,703c <__divdf3+0x3a8>
    702c:	00e60733          	add	a4,a2,a4
    7030:	fff88793          	addi	a5,a7,-1
    7034:	28c77e63          	bgeu	a4,a2,72d0 <__divdf3+0x63c>
    7038:	00078893          	mv	a7,a5
    703c:	01041413          	slli	s0,s0,0x10
    7040:	000102b7          	lui	t0,0x10
    7044:	01146433          	or	s0,s0,a7
    7048:	fff28313          	addi	t1,t0,-1 # ffff <_end+0xdff>
    704c:	006478b3          	and	a7,s0,t1
    7050:	01045e93          	srli	t4,s0,0x10
    7054:	0105de13          	srli	t3,a1,0x10
    7058:	0065f333          	and	t1,a1,t1
    705c:	03130f33          	mul	t5,t1,a7
    7060:	41f70733          	sub	a4,a4,t6
    7064:	031e08b3          	mul	a7,t3,a7
    7068:	010f5793          	srli	a5,t5,0x10
    706c:	026e8fb3          	mul	t6,t4,t1
    7070:	01f888b3          	add	a7,a7,t6
    7074:	011787b3          	add	a5,a5,a7
    7078:	03ce8eb3          	mul	t4,t4,t3
    707c:	01f7f463          	bgeu	a5,t6,7084 <__divdf3+0x3f0>
    7080:	005e8eb3          	add	t4,t4,t0
    7084:	00010fb7          	lui	t6,0x10
    7088:	ffff8f93          	addi	t6,t6,-1 # ffff <_end+0xdff>
    708c:	0107d893          	srli	a7,a5,0x10
    7090:	01f7f7b3          	and	a5,a5,t6
    7094:	01079793          	slli	a5,a5,0x10
    7098:	01ff7f33          	and	t5,t5,t6
    709c:	01d888b3          	add	a7,a7,t4
    70a0:	01e787b3          	add	a5,a5,t5
    70a4:	17176e63          	bltu	a4,a7,7220 <__divdf3+0x58c>
    70a8:	17170a63          	beq	a4,a7,721c <__divdf3+0x588>
    70ac:	40fb07b3          	sub	a5,s6,a5
    70b0:	41170733          	sub	a4,a4,a7
    70b4:	00fb3b33          	sltu	s6,s6,a5
    70b8:	41670733          	sub	a4,a4,s6
    70bc:	2ee60063          	beq	a2,a4,739c <__divdf3+0x708>
    70c0:	02a758b3          	divu	a7,a4,a0
    70c4:	0107de93          	srli	t4,a5,0x10
    70c8:	02a77733          	remu	a4,a4,a0
    70cc:	03180f33          	mul	t5,a6,a7
    70d0:	01071713          	slli	a4,a4,0x10
    70d4:	00eee733          	or	a4,t4,a4
    70d8:	01e77e63          	bgeu	a4,t5,70f4 <__divdf3+0x460>
    70dc:	00e60733          	add	a4,a2,a4
    70e0:	fff88e93          	addi	t4,a7,-1
    70e4:	2ec76a63          	bltu	a4,a2,73d8 <__divdf3+0x744>
    70e8:	2fe77863          	bgeu	a4,t5,73d8 <__divdf3+0x744>
    70ec:	ffe88893          	addi	a7,a7,-2
    70f0:	00c70733          	add	a4,a4,a2
    70f4:	41e70733          	sub	a4,a4,t5
    70f8:	02a75eb3          	divu	t4,a4,a0
    70fc:	01079793          	slli	a5,a5,0x10
    7100:	0107d793          	srli	a5,a5,0x10
    7104:	02a77733          	remu	a4,a4,a0
    7108:	03d80833          	mul	a6,a6,t4
    710c:	01071713          	slli	a4,a4,0x10
    7110:	00e7e7b3          	or	a5,a5,a4
    7114:	0107fe63          	bgeu	a5,a6,7130 <__divdf3+0x49c>
    7118:	00f607b3          	add	a5,a2,a5
    711c:	fffe8713          	addi	a4,t4,-1
    7120:	2ac7e863          	bltu	a5,a2,73d0 <__divdf3+0x73c>
    7124:	2b07f663          	bgeu	a5,a6,73d0 <__divdf3+0x73c>
    7128:	ffee8e93          	addi	t4,t4,-2
    712c:	00c787b3          	add	a5,a5,a2
    7130:	01089893          	slli	a7,a7,0x10
    7134:	01d8e8b3          	or	a7,a7,t4
    7138:	01089513          	slli	a0,a7,0x10
    713c:	0108df13          	srli	t5,a7,0x10
    7140:	01055513          	srli	a0,a0,0x10
    7144:	02650eb3          	mul	t4,a0,t1
    7148:	410787b3          	sub	a5,a5,a6
    714c:	02ae0533          	mul	a0,t3,a0
    7150:	010ed713          	srli	a4,t4,0x10
    7154:	026f0333          	mul	t1,t5,t1
    7158:	00650533          	add	a0,a0,t1
    715c:	00a70733          	add	a4,a4,a0
    7160:	03ee0e33          	mul	t3,t3,t5
    7164:	00677663          	bgeu	a4,t1,7170 <__divdf3+0x4dc>
    7168:	00010537          	lui	a0,0x10
    716c:	00ae0e33          	add	t3,t3,a0
    7170:	00010837          	lui	a6,0x10
    7174:	fff80813          	addi	a6,a6,-1 # ffff <_end+0xdff>
    7178:	01075513          	srli	a0,a4,0x10
    717c:	01077733          	and	a4,a4,a6
    7180:	01071713          	slli	a4,a4,0x10
    7184:	010efeb3          	and	t4,t4,a6
    7188:	01c50533          	add	a0,a0,t3
    718c:	01d70733          	add	a4,a4,t4
    7190:	12a7f263          	bgeu	a5,a0,72b4 <__divdf3+0x620>
    7194:	00f607b3          	add	a5,a2,a5
    7198:	fff88313          	addi	t1,a7,-1
    719c:	00078813          	mv	a6,a5
    71a0:	1cc7e463          	bltu	a5,a2,7368 <__divdf3+0x6d4>
    71a4:	24a7e863          	bltu	a5,a0,73f4 <__divdf3+0x760>
    71a8:	26a78663          	beq	a5,a0,7414 <__divdf3+0x780>
    71ac:	00030893          	mv	a7,t1
    71b0:	0018e893          	ori	a7,a7,1
    71b4:	d55ff06f          	j	6f08 <__divdf3+0x274>
    71b8:	00100713          	li	a4,1
    71bc:	c2079ce3          	bnez	a5,6df4 <__divdf3+0x160>
    71c0:	41e98993          	addi	s3,s3,1054
    71c4:	013897b3          	sll	a5,a7,s3
    71c8:	00f037b3          	snez	a5,a5
    71cc:	013419b3          	sll	s3,s0,s3
    71d0:	0137e7b3          	or	a5,a5,s3
    71d4:	00e8d8b3          	srl	a7,a7,a4
    71d8:	00f8e8b3          	or	a7,a7,a5
    71dc:	0078f793          	andi	a5,a7,7
    71e0:	00e45433          	srl	s0,s0,a4
    71e4:	02078063          	beqz	a5,7204 <__divdf3+0x570>
    71e8:	00f8f793          	andi	a5,a7,15
    71ec:	00400713          	li	a4,4
    71f0:	00e78a63          	beq	a5,a4,7204 <__divdf3+0x570>
    71f4:	00488793          	addi	a5,a7,4
    71f8:	0117b8b3          	sltu	a7,a5,a7
    71fc:	01140433          	add	s0,s0,a7
    7200:	00078893          	mv	a7,a5
    7204:	00841593          	slli	a1,s0,0x8
    7208:	00100793          	li	a5,1
    720c:	00000613          	li	a2,0
    7210:	00000713          	li	a4,0
    7214:	be05cce3          	bltz	a1,6e0c <__divdf3+0x178>
    7218:	1340006f          	j	734c <__divdf3+0x6b8>
    721c:	e8fb78e3          	bgeu	s6,a5,70ac <__divdf3+0x418>
    7220:	00bb0eb3          	add	t4,s6,a1
    7224:	016ebf33          	sltu	t5,t4,s6
    7228:	00cf0fb3          	add	t6,t5,a2
    722c:	01f70733          	add	a4,a4,t6
    7230:	000e8b13          	mv	s6,t4
    7234:	fff40f93          	addi	t6,s0,-1
    7238:	08e67463          	bgeu	a2,a4,72c0 <__divdf3+0x62c>
    723c:	15176263          	bltu	a4,a7,7380 <__divdf3+0x6ec>
    7240:	12e88e63          	beq	a7,a4,737c <__divdf3+0x6e8>
    7244:	000f8413          	mv	s0,t6
    7248:	e65ff06f          	j	70ac <__divdf3+0x418>
    724c:	d71b62e3          	bltu	s6,a7,6fb0 <__divdf3+0x31c>
    7250:	001b5713          	srli	a4,s6,0x1
    7254:	01fa9313          	slli	t1,s5,0x1f
    7258:	001ad793          	srli	a5,s5,0x1
    725c:	00e36333          	or	t1,t1,a4
    7260:	01fb1b13          	slli	s6,s6,0x1f
    7264:	d5dff06f          	j	6fc0 <__divdf3+0x32c>
    7268:	000b8513          	mv	a0,s7
    726c:	6a0010ef          	jal	890c <__clzsi2>
    7270:	01550693          	addi	a3,a0,21 # 10015 <_end+0xe15>
    7274:	01c00713          	li	a4,28
    7278:	02050793          	addi	a5,a0,32
    727c:	b4d756e3          	bge	a4,a3,6dc8 <__divdf3+0x134>
    7280:	ff850513          	addi	a0,a0,-8
    7284:	00000893          	li	a7,0
    7288:	00ab9433          	sll	s0,s7,a0
    728c:	b59ff06f          	j	6de4 <__divdf3+0x150>
    7290:	67c010ef          	jal	890c <__clzsi2>
    7294:	01550693          	addi	a3,a0,21
    7298:	01c00793          	li	a5,28
    729c:	02050713          	addi	a4,a0,32
    72a0:	bed7dae3          	bge	a5,a3,6e94 <__divdf3+0x200>
    72a4:	ff850793          	addi	a5,a0,-8
    72a8:	00f41ab3          	sll	s5,s0,a5
    72ac:	00000b13          	li	s6,0
    72b0:	c01ff06f          	j	6eb0 <__divdf3+0x21c>
    72b4:	eea79ee3          	bne	a5,a0,71b0 <__divdf3+0x51c>
    72b8:	c40708e3          	beqz	a4,6f08 <__divdf3+0x274>
    72bc:	ed9ff06f          	j	7194 <__divdf3+0x500>
    72c0:	f8e612e3          	bne	a2,a4,7244 <__divdf3+0x5b0>
    72c4:	f60f0ce3          	beqz	t5,723c <__divdf3+0x5a8>
    72c8:	000f8413          	mv	s0,t6
    72cc:	de1ff06f          	j	70ac <__divdf3+0x418>
    72d0:	d7f774e3          	bgeu	a4,t6,7038 <__divdf3+0x3a4>
    72d4:	ffe88893          	addi	a7,a7,-2
    72d8:	00c70733          	add	a4,a4,a2
    72dc:	d61ff06f          	j	703c <__divdf3+0x3a8>
    72e0:	d317f2e3          	bgeu	a5,a7,7004 <__divdf3+0x370>
    72e4:	ffe40413          	addi	s0,s0,-2
    72e8:	00c787b3          	add	a5,a5,a2
    72ec:	d1dff06f          	j	7008 <__divdf3+0x374>
    72f0:	01f00613          	li	a2,31
    72f4:	ece656e3          	bge	a2,a4,71c0 <__divdf3+0x52c>
    72f8:	fe100613          	li	a2,-31
    72fc:	40f607b3          	sub	a5,a2,a5
    7300:	02000613          	li	a2,32
    7304:	00f457b3          	srl	a5,s0,a5
    7308:	00c70863          	beq	a4,a2,7318 <__divdf3+0x684>
    730c:	43e98993          	addi	s3,s3,1086
    7310:	013419b3          	sll	s3,s0,s3
    7314:	0138e8b3          	or	a7,a7,s3
    7318:	011038b3          	snez	a7,a7
    731c:	00f8e8b3          	or	a7,a7,a5
    7320:	0078f713          	andi	a4,a7,7
    7324:	00000613          	li	a2,0
    7328:	02070863          	beqz	a4,7358 <__divdf3+0x6c4>
    732c:	00f8f793          	andi	a5,a7,15
    7330:	00400713          	li	a4,4
    7334:	00000413          	li	s0,0
    7338:	00e78a63          	beq	a5,a4,734c <__divdf3+0x6b8>
    733c:	00488793          	addi	a5,a7,4
    7340:	0117b8b3          	sltu	a7,a5,a7
    7344:	01103433          	snez	s0,a7
    7348:	00078893          	mv	a7,a5
    734c:	00941613          	slli	a2,s0,0x9
    7350:	01d41713          	slli	a4,s0,0x1d
    7354:	00c65613          	srli	a2,a2,0xc
    7358:	0038d893          	srli	a7,a7,0x3
    735c:	00e8e733          	or	a4,a7,a4
    7360:	00000793          	li	a5,0
    7364:	aa9ff06f          	j	6e0c <__divdf3+0x178>
    7368:	00030893          	mv	a7,t1
    736c:	e4a812e3          	bne	a6,a0,71b0 <__divdf3+0x51c>
    7370:	b8b70ce3          	beq	a4,a1,6f08 <__divdf3+0x274>
    7374:	0018e893          	ori	a7,a7,1
    7378:	b91ff06f          	j	6f08 <__divdf3+0x274>
    737c:	ecfef4e3          	bgeu	t4,a5,7244 <__divdf3+0x5b0>
    7380:	01d58eb3          	add	t4,a1,t4
    7384:	00bebf33          	sltu	t5,t4,a1
    7388:	00cf0f33          	add	t5,t5,a2
    738c:	ffe40413          	addi	s0,s0,-2
    7390:	000e8b13          	mv	s6,t4
    7394:	01e70733          	add	a4,a4,t5
    7398:	d15ff06f          	j	70ac <__divdf3+0x418>
    739c:	c0200713          	li	a4,-1022
    73a0:	3ff98793          	addi	a5,s3,1023
    73a4:	fff00893          	li	a7,-1
    73a8:	e0e9c8e3          	blt	s3,a4,71b8 <__divdf3+0x524>
    73ac:	00488713          	addi	a4,a7,4
    73b0:	011738b3          	sltu	a7,a4,a7
    73b4:	01140433          	add	s0,s0,a7
    73b8:	00070893          	mv	a7,a4
    73bc:	b5dff06f          	j	6f18 <__divdf3+0x284>
    73c0:	00f8f713          	andi	a4,a7,15
    73c4:	00400613          	li	a2,4
    73c8:	b4c708e3          	beq	a4,a2,6f18 <__divdf3+0x284>
    73cc:	fe1ff06f          	j	73ac <__divdf3+0x718>
    73d0:	00070e93          	mv	t4,a4
    73d4:	d5dff06f          	j	7130 <__divdf3+0x49c>
    73d8:	000e8893          	mv	a7,t4
    73dc:	d19ff06f          	j	70f4 <__divdf3+0x460>
    73e0:	00090693          	mv	a3,s2
    73e4:	7ff00793          	li	a5,2047
    73e8:	00000613          	li	a2,0
    73ec:	00000713          	li	a4,0
    73f0:	a1dff06f          	j	6e0c <__divdf3+0x178>
    73f4:	00159313          	slli	t1,a1,0x1
    73f8:	00b33833          	sltu	a6,t1,a1
    73fc:	00c80833          	add	a6,a6,a2
    7400:	01078833          	add	a6,a5,a6
    7404:	ffe88893          	addi	a7,a7,-2
    7408:	00030593          	mv	a1,t1
    740c:	f6a802e3          	beq	a6,a0,7370 <__divdf3+0x6dc>
    7410:	da1ff06f          	j	71b0 <__divdf3+0x51c>
    7414:	fee5e0e3          	bltu	a1,a4,73f4 <__divdf3+0x760>
    7418:	00030893          	mv	a7,t1
    741c:	f4b71ce3          	bne	a4,a1,7374 <__divdf3+0x6e0>
    7420:	ae9ff06f          	j	6f08 <__divdf3+0x274>

00007424 <__eqdf2>:
    7424:	0145d713          	srli	a4,a1,0x14
    7428:	001007b7          	lui	a5,0x100
    742c:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xefdff>
    7430:	0146d813          	srli	a6,a3,0x14
    7434:	7ff77713          	andi	a4,a4,2047
    7438:	7ff00313          	li	t1,2047
    743c:	00b7fe33          	and	t3,a5,a1
    7440:	00050893          	mv	a7,a0
    7444:	00d7f7b3          	and	a5,a5,a3
    7448:	01f5d593          	srli	a1,a1,0x1f
    744c:	7ff87813          	andi	a6,a6,2047
    7450:	01f6d693          	srli	a3,a3,0x1f
    7454:	00100513          	li	a0,1
    7458:	00670c63          	beq	a4,t1,7470 <__eqdf2+0x4c>
    745c:	00680863          	beq	a6,t1,746c <__eqdf2+0x48>
    7460:	01071463          	bne	a4,a6,7468 <__eqdf2+0x44>
    7464:	02fe0663          	beq	t3,a5,7490 <__eqdf2+0x6c>
    7468:	00008067          	ret
    746c:	00008067          	ret
    7470:	fee81ce3          	bne	a6,a4,7468 <__eqdf2+0x44>
    7474:	00fe67b3          	or	a5,t3,a5
    7478:	00c7e7b3          	or	a5,a5,a2
    747c:	0117e7b3          	or	a5,a5,a7
    7480:	fe0794e3          	bnez	a5,7468 <__eqdf2+0x44>
    7484:	40d585b3          	sub	a1,a1,a3
    7488:	00b03533          	snez	a0,a1
    748c:	00008067          	ret
    7490:	fcc89ce3          	bne	a7,a2,7468 <__eqdf2+0x44>
    7494:	00d58a63          	beq	a1,a3,74a8 <__eqdf2+0x84>
    7498:	fc0718e3          	bnez	a4,7468 <__eqdf2+0x44>
    749c:	011e6e33          	or	t3,t3,a7
    74a0:	01c03533          	snez	a0,t3
    74a4:	00008067          	ret
    74a8:	00000513          	li	a0,0
    74ac:	00008067          	ret

000074b0 <__gedf2>:
    74b0:	0145d893          	srli	a7,a1,0x14
    74b4:	001007b7          	lui	a5,0x100
    74b8:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xefdff>
    74bc:	0146d713          	srli	a4,a3,0x14
    74c0:	7ff8f893          	andi	a7,a7,2047
    74c4:	7ff00e13          	li	t3,2047
    74c8:	00b7f333          	and	t1,a5,a1
    74cc:	00050813          	mv	a6,a0
    74d0:	00050e93          	mv	t4,a0
    74d4:	00d7f7b3          	and	a5,a5,a3
    74d8:	01f5d593          	srli	a1,a1,0x1f
    74dc:	00060f13          	mv	t5,a2
    74e0:	7ff77513          	andi	a0,a4,2047
    74e4:	01f6d693          	srli	a3,a3,0x1f
    74e8:	05c88863          	beq	a7,t3,7538 <__gedf2+0x88>
    74ec:	03c50463          	beq	a0,t3,7514 <__gedf2+0x64>
    74f0:	06089a63          	bnez	a7,7564 <__gedf2+0xb4>
    74f4:	01036833          	or	a6,t1,a6
    74f8:	06051063          	bnez	a0,7558 <__gedf2+0xa8>
    74fc:	00c7e633          	or	a2,a5,a2
    7500:	08060c63          	beqz	a2,7598 <__gedf2+0xe8>
    7504:	0a081263          	bnez	a6,75a8 <__gedf2+0xf8>
    7508:	00100513          	li	a0,1
    750c:	08068263          	beqz	a3,7590 <__gedf2+0xe0>
    7510:	00008067          	ret
    7514:	00c7e633          	or	a2,a5,a2
    7518:	08061463          	bnez	a2,75a0 <__gedf2+0xf0>
    751c:	00089663          	bnez	a7,7528 <__gedf2+0x78>
    7520:	01036333          	or	t1,t1,a6
    7524:	fe0302e3          	beqz	t1,7508 <__gedf2+0x58>
    7528:	06d58063          	beq	a1,a3,7588 <__gedf2+0xd8>
    752c:	06059263          	bnez	a1,7590 <__gedf2+0xe0>
    7530:	00100513          	li	a0,1
    7534:	00008067          	ret
    7538:	01036333          	or	t1,t1,a6
    753c:	06031263          	bnez	t1,75a0 <__gedf2+0xf0>
    7540:	ff1516e3          	bne	a0,a7,752c <__gedf2+0x7c>
    7544:	00c7e7b3          	or	a5,a5,a2
    7548:	04079c63          	bnez	a5,75a0 <__gedf2+0xf0>
    754c:	fed590e3          	bne	a1,a3,752c <__gedf2+0x7c>
    7550:	00000513          	li	a0,0
    7554:	00008067          	ret
    7558:	fa0808e3          	beqz	a6,7508 <__gedf2+0x58>
    755c:	fcd598e3          	bne	a1,a3,752c <__gedf2+0x7c>
    7560:	0280006f          	j	7588 <__gedf2+0xd8>
    7564:	fc0504e3          	beqz	a0,752c <__gedf2+0x7c>
    7568:	fcd592e3          	bne	a1,a3,752c <__gedf2+0x7c>
    756c:	fd1540e3          	blt	a0,a7,752c <__gedf2+0x7c>
    7570:	00a8cc63          	blt	a7,a0,7588 <__gedf2+0xd8>
    7574:	fa67ece3          	bltu	a5,t1,752c <__gedf2+0x7c>
    7578:	00f31863          	bne	t1,a5,7588 <__gedf2+0xd8>
    757c:	fbdf68e3          	bltu	t5,t4,752c <__gedf2+0x7c>
    7580:	00000513          	li	a0,0
    7584:	f9eef6e3          	bgeu	t4,t5,7510 <__gedf2+0x60>
    7588:	00100513          	li	a0,1
    758c:	f80592e3          	bnez	a1,7510 <__gedf2+0x60>
    7590:	fff00513          	li	a0,-1
    7594:	00008067          	ret
    7598:	f8081ae3          	bnez	a6,752c <__gedf2+0x7c>
    759c:	00008067          	ret
    75a0:	ffe00513          	li	a0,-2
    75a4:	00008067          	ret
    75a8:	fcd586e3          	beq	a1,a3,7574 <__gedf2+0xc4>
    75ac:	f81ff06f          	j	752c <__gedf2+0x7c>

000075b0 <__ledf2>:
    75b0:	0145d893          	srli	a7,a1,0x14
    75b4:	001007b7          	lui	a5,0x100
    75b8:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xefdff>
    75bc:	0146d713          	srli	a4,a3,0x14
    75c0:	7ff8f893          	andi	a7,a7,2047
    75c4:	7ff00313          	li	t1,2047
    75c8:	00b7fe33          	and	t3,a5,a1
    75cc:	00050813          	mv	a6,a0
    75d0:	00050e93          	mv	t4,a0
    75d4:	00d7f7b3          	and	a5,a5,a3
    75d8:	01f5d593          	srli	a1,a1,0x1f
    75dc:	00060f13          	mv	t5,a2
    75e0:	7ff77513          	andi	a0,a4,2047
    75e4:	01f6d693          	srli	a3,a3,0x1f
    75e8:	04688a63          	beq	a7,t1,763c <__ledf2+0x8c>
    75ec:	02650463          	beq	a0,t1,7614 <__ledf2+0x64>
    75f0:	06089863          	bnez	a7,7660 <__ledf2+0xb0>
    75f4:	010e6833          	or	a6,t3,a6
    75f8:	08051e63          	bnez	a0,7694 <__ledf2+0xe4>
    75fc:	00c7e633          	or	a2,a5,a2
    7600:	0a060463          	beqz	a2,76a8 <__ledf2+0xf8>
    7604:	0a081663          	bnez	a6,76b0 <__ledf2+0x100>
    7608:	00100513          	li	a0,1
    760c:	08068063          	beqz	a3,768c <__ledf2+0xdc>
    7610:	00008067          	ret
    7614:	00c7e633          	or	a2,a5,a2
    7618:	00200513          	li	a0,2
    761c:	fe061ae3          	bnez	a2,7610 <__ledf2+0x60>
    7620:	00089663          	bnez	a7,762c <__ledf2+0x7c>
    7624:	010e6e33          	or	t3,t3,a6
    7628:	fe0e00e3          	beqz	t3,7608 <__ledf2+0x58>
    762c:	04d58c63          	beq	a1,a3,7684 <__ledf2+0xd4>
    7630:	04059e63          	bnez	a1,768c <__ledf2+0xdc>
    7634:	00100513          	li	a0,1
    7638:	00008067          	ret
    763c:	010e6e33          	or	t3,t3,a6
    7640:	060e1063          	bnez	t3,76a0 <__ledf2+0xf0>
    7644:	ff1516e3          	bne	a0,a7,7630 <__ledf2+0x80>
    7648:	00c7e7b3          	or	a5,a5,a2
    764c:	00200513          	li	a0,2
    7650:	fc0790e3          	bnez	a5,7610 <__ledf2+0x60>
    7654:	fcd59ee3          	bne	a1,a3,7630 <__ledf2+0x80>
    7658:	00000513          	li	a0,0
    765c:	00008067          	ret
    7660:	fc0508e3          	beqz	a0,7630 <__ledf2+0x80>
    7664:	fcd596e3          	bne	a1,a3,7630 <__ledf2+0x80>
    7668:	fd1544e3          	blt	a0,a7,7630 <__ledf2+0x80>
    766c:	00a8cc63          	blt	a7,a0,7684 <__ledf2+0xd4>
    7670:	fdc7e0e3          	bltu	a5,t3,7630 <__ledf2+0x80>
    7674:	00fe1863          	bne	t3,a5,7684 <__ledf2+0xd4>
    7678:	fbdf6ce3          	bltu	t5,t4,7630 <__ledf2+0x80>
    767c:	00000513          	li	a0,0
    7680:	f9eef8e3          	bgeu	t4,t5,7610 <__ledf2+0x60>
    7684:	00100513          	li	a0,1
    7688:	f80594e3          	bnez	a1,7610 <__ledf2+0x60>
    768c:	fff00513          	li	a0,-1
    7690:	00008067          	ret
    7694:	f6080ae3          	beqz	a6,7608 <__ledf2+0x58>
    7698:	f8d59ce3          	bne	a1,a3,7630 <__ledf2+0x80>
    769c:	fe9ff06f          	j	7684 <__ledf2+0xd4>
    76a0:	00200513          	li	a0,2
    76a4:	00008067          	ret
    76a8:	f80814e3          	bnez	a6,7630 <__ledf2+0x80>
    76ac:	00008067          	ret
    76b0:	fcd580e3          	beq	a1,a3,7670 <__ledf2+0xc0>
    76b4:	f7dff06f          	j	7630 <__ledf2+0x80>

000076b8 <__muldf3>:
    76b8:	fd010113          	addi	sp,sp,-48
    76bc:	0145d793          	srli	a5,a1,0x14
    76c0:	02812423          	sw	s0,40(sp)
    76c4:	02912223          	sw	s1,36(sp)
    76c8:	03212023          	sw	s2,32(sp)
    76cc:	01312e23          	sw	s3,28(sp)
    76d0:	01512a23          	sw	s5,20(sp)
    76d4:	00c59493          	slli	s1,a1,0xc
    76d8:	02112623          	sw	ra,44(sp)
    76dc:	01412c23          	sw	s4,24(sp)
    76e0:	01612823          	sw	s6,16(sp)
    76e4:	01712623          	sw	s7,12(sp)
    76e8:	01812423          	sw	s8,8(sp)
    76ec:	7ff7f793          	andi	a5,a5,2047
    76f0:	00050413          	mv	s0,a0
    76f4:	00060a93          	mv	s5,a2
    76f8:	00068993          	mv	s3,a3
    76fc:	00c4d493          	srli	s1,s1,0xc
    7700:	01f5d913          	srli	s2,a1,0x1f
    7704:	42078463          	beqz	a5,7b2c <__muldf3+0x474>
    7708:	7ff00713          	li	a4,2047
    770c:	0ae78663          	beq	a5,a4,77b8 <__muldf3+0x100>
    7710:	00349693          	slli	a3,s1,0x3
    7714:	01d55713          	srli	a4,a0,0x1d
    7718:	00d76733          	or	a4,a4,a3
    771c:	008006b7          	lui	a3,0x800
    7720:	00d764b3          	or	s1,a4,a3
    7724:	00351a13          	slli	s4,a0,0x3
    7728:	c0178c13          	addi	s8,a5,-1023
    772c:	00000b13          	li	s6,0
    7730:	00000b93          	li	s7,0
    7734:	0149d793          	srli	a5,s3,0x14
    7738:	00c99713          	slli	a4,s3,0xc
    773c:	7ff7f793          	andi	a5,a5,2047
    7740:	000a8f13          	mv	t5,s5
    7744:	00c75413          	srli	s0,a4,0xc
    7748:	01f9d993          	srli	s3,s3,0x1f
    774c:	0a078063          	beqz	a5,77ec <__muldf3+0x134>
    7750:	7ff00713          	li	a4,2047
    7754:	14e78e63          	beq	a5,a4,78b0 <__muldf3+0x1f8>
    7758:	00341713          	slli	a4,s0,0x3
    775c:	01dad593          	srli	a1,s5,0x1d
    7760:	00e5e5b3          	or	a1,a1,a4
    7764:	c0178793          	addi	a5,a5,-1023
    7768:	00800737          	lui	a4,0x800
    776c:	00e5e433          	or	s0,a1,a4
    7770:	003a9f13          	slli	t5,s5,0x3
    7774:	018788b3          	add	a7,a5,s8
    7778:	00000313          	li	t1,0
    777c:	00a00713          	li	a4,10
    7780:	00188513          	addi	a0,a7,1
    7784:	0b674c63          	blt	a4,s6,783c <__muldf3+0x184>
    7788:	013945b3          	xor	a1,s2,s3
    778c:	00200793          	li	a5,2
    7790:	00058813          	mv	a6,a1
    7794:	1567c663          	blt	a5,s6,78e0 <__muldf3+0x228>
    7798:	fffb0b13          	addi	s6,s6,-1
    779c:	00100713          	li	a4,1
    77a0:	17676063          	bltu	a4,s6,7900 <__muldf3+0x248>
    77a4:	3cf30a63          	beq	t1,a5,7b78 <__muldf3+0x4c0>
    77a8:	00040493          	mv	s1,s0
    77ac:	000f0a13          	mv	s4,t5
    77b0:	00030b93          	mv	s7,t1
    77b4:	09c0006f          	j	7850 <__muldf3+0x198>
    77b8:	00a4ea33          	or	s4,s1,a0
    77bc:	3c0a1863          	bnez	s4,7b8c <__muldf3+0x4d4>
    77c0:	0149d793          	srli	a5,s3,0x14
    77c4:	00c99713          	slli	a4,s3,0xc
    77c8:	7ff7f793          	andi	a5,a5,2047
    77cc:	00000493          	li	s1,0
    77d0:	00800b13          	li	s6,8
    77d4:	7ff00c13          	li	s8,2047
    77d8:	00200b93          	li	s7,2
    77dc:	000a8f13          	mv	t5,s5
    77e0:	00c75413          	srli	s0,a4,0xc
    77e4:	01f9d993          	srli	s3,s3,0x1f
    77e8:	f60794e3          	bnez	a5,7750 <__muldf3+0x98>
    77ec:	015467b3          	or	a5,s0,s5
    77f0:	3c078263          	beqz	a5,7bb4 <__muldf3+0x4fc>
    77f4:	4a040063          	beqz	s0,7c94 <__muldf3+0x5dc>
    77f8:	00040513          	mv	a0,s0
    77fc:	110010ef          	jal	890c <__clzsi2>
    7800:	00050893          	mv	a7,a0
    7804:	ff550713          	addi	a4,a0,-11
    7808:	01d00793          	li	a5,29
    780c:	ff888f13          	addi	t5,a7,-8
    7810:	40e787b3          	sub	a5,a5,a4
    7814:	00fad7b3          	srl	a5,s5,a5
    7818:	01e41733          	sll	a4,s0,t5
    781c:	00e7e433          	or	s0,a5,a4
    7820:	01ea9f33          	sll	t5,s5,t5
    7824:	411c08b3          	sub	a7,s8,a7
    7828:	c0d88893          	addi	a7,a7,-1011
    782c:	00a00713          	li	a4,10
    7830:	00000313          	li	t1,0
    7834:	00188513          	addi	a0,a7,1
    7838:	f56758e3          	bge	a4,s6,7788 <__muldf3+0xd0>
    783c:	00090593          	mv	a1,s2
    7840:	00200793          	li	a5,2
    7844:	32fb8a63          	beq	s7,a5,7b78 <__muldf3+0x4c0>
    7848:	00300793          	li	a5,3
    784c:	48fb8c63          	beq	s7,a5,7ce4 <__muldf3+0x62c>
    7850:	00100793          	li	a5,1
    7854:	00058813          	mv	a6,a1
    7858:	46fb9a63          	bne	s7,a5,7ccc <__muldf3+0x614>
    785c:	00000793          	li	a5,0
    7860:	00000693          	li	a3,0
    7864:	00000713          	li	a4,0
    7868:	02c12083          	lw	ra,44(sp)
    786c:	02812403          	lw	s0,40(sp)
    7870:	01479793          	slli	a5,a5,0x14
    7874:	00d7e7b3          	or	a5,a5,a3
    7878:	01f81693          	slli	a3,a6,0x1f
    787c:	00d7e7b3          	or	a5,a5,a3
    7880:	02412483          	lw	s1,36(sp)
    7884:	02012903          	lw	s2,32(sp)
    7888:	01c12983          	lw	s3,28(sp)
    788c:	01812a03          	lw	s4,24(sp)
    7890:	01412a83          	lw	s5,20(sp)
    7894:	01012b03          	lw	s6,16(sp)
    7898:	00c12b83          	lw	s7,12(sp)
    789c:	00812c03          	lw	s8,8(sp)
    78a0:	00070513          	mv	a0,a4
    78a4:	00078593          	mv	a1,a5
    78a8:	03010113          	addi	sp,sp,48
    78ac:	00008067          	ret
    78b0:	01546733          	or	a4,s0,s5
    78b4:	7ffc0893          	addi	a7,s8,2047
    78b8:	30070a63          	beqz	a4,7bcc <__muldf3+0x514>
    78bc:	00001737          	lui	a4,0x1
    78c0:	01394833          	xor	a6,s2,s3
    78c4:	80070713          	addi	a4,a4,-2048 # 800 <CUSTOM2+0x7a5>
    78c8:	003b6b13          	ori	s6,s6,3
    78cc:	00a00693          	li	a3,10
    78d0:	00080593          	mv	a1,a6
    78d4:	00ec0533          	add	a0,s8,a4
    78d8:	3966c063          	blt	a3,s6,7c58 <__muldf3+0x5a0>
    78dc:	00300313          	li	t1,3
    78e0:	00100613          	li	a2,1
    78e4:	01661633          	sll	a2,a2,s6
    78e8:	53067713          	andi	a4,a2,1328
    78ec:	f4071ae3          	bnez	a4,7840 <__muldf3+0x188>
    78f0:	24067793          	andi	a5,a2,576
    78f4:	3c079463          	bnez	a5,7cbc <__muldf3+0x604>
    78f8:	08867613          	andi	a2,a2,136
    78fc:	2e061263          	bnez	a2,7be0 <__muldf3+0x528>
    7900:	00010fb7          	lui	t6,0x10
    7904:	ffff8e93          	addi	t4,t6,-1 # ffff <_end+0xdff>
    7908:	01da77b3          	and	a5,s4,t4
    790c:	010a5693          	srli	a3,s4,0x10
    7910:	01df7eb3          	and	t4,t5,t4
    7914:	010f5e13          	srli	t3,t5,0x10
    7918:	03d78733          	mul	a4,a5,t4
    791c:	03d68333          	mul	t1,a3,t4
    7920:	01075593          	srli	a1,a4,0x10
    7924:	02fe0633          	mul	a2,t3,a5
    7928:	00660633          	add	a2,a2,t1
    792c:	00c585b3          	add	a1,a1,a2
    7930:	03c68f33          	mul	t5,a3,t3
    7934:	0065f463          	bgeu	a1,t1,793c <__muldf3+0x284>
    7938:	01ff0f33          	add	t5,t5,t6
    793c:	000103b7          	lui	t2,0x10
    7940:	fff38613          	addi	a2,t2,-1 # ffff <_end+0xdff>
    7944:	00c5f333          	and	t1,a1,a2
    7948:	01045f93          	srli	t6,s0,0x10
    794c:	00c77733          	and	a4,a4,a2
    7950:	00c47433          	and	s0,s0,a2
    7954:	01031313          	slli	t1,t1,0x10
    7958:	028782b3          	mul	t0,a5,s0
    795c:	00e30333          	add	t1,t1,a4
    7960:	0105d593          	srli	a1,a1,0x10
    7964:	02868733          	mul	a4,a3,s0
    7968:	0102d613          	srli	a2,t0,0x10
    796c:	02ff87b3          	mul	a5,t6,a5
    7970:	00e787b3          	add	a5,a5,a4
    7974:	00f60633          	add	a2,a2,a5
    7978:	03f687b3          	mul	a5,a3,t6
    797c:	00e67463          	bgeu	a2,a4,7984 <__muldf3+0x2cc>
    7980:	007787b3          	add	a5,a5,t2
    7984:	00010937          	lui	s2,0x10
    7988:	fff90993          	addi	s3,s2,-1 # ffff <_end+0xdff>
    798c:	01367733          	and	a4,a2,s3
    7990:	0104d393          	srli	t2,s1,0x10
    7994:	0134f6b3          	and	a3,s1,s3
    7998:	0132f2b3          	and	t0,t0,s3
    799c:	01071713          	slli	a4,a4,0x10
    79a0:	02de84b3          	mul	s1,t4,a3
    79a4:	00570733          	add	a4,a4,t0
    79a8:	01065613          	srli	a2,a2,0x10
    79ac:	00f60633          	add	a2,a2,a5
    79b0:	00e585b3          	add	a1,a1,a4
    79b4:	02de02b3          	mul	t0,t3,a3
    79b8:	0104d793          	srli	a5,s1,0x10
    79bc:	03d38eb3          	mul	t4,t2,t4
    79c0:	01d282b3          	add	t0,t0,t4
    79c4:	005787b3          	add	a5,a5,t0
    79c8:	027e0e33          	mul	t3,t3,t2
    79cc:	01d7f463          	bgeu	a5,t4,79d4 <__muldf3+0x31c>
    79d0:	012e0e33          	add	t3,t3,s2
    79d4:	000109b7          	lui	s3,0x10
    79d8:	fff98e93          	addi	t4,s3,-1 # ffff <_end+0xdff>
    79dc:	01d7f2b3          	and	t0,a5,t4
    79e0:	0107d793          	srli	a5,a5,0x10
    79e4:	01c787b3          	add	a5,a5,t3
    79e8:	01d4feb3          	and	t4,s1,t4
    79ec:	01029293          	slli	t0,t0,0x10
    79f0:	02d40933          	mul	s2,s0,a3
    79f4:	01d282b3          	add	t0,t0,t4
    79f8:	02838433          	mul	s0,t2,s0
    79fc:	01095e13          	srli	t3,s2,0x10
    7a00:	02df86b3          	mul	a3,t6,a3
    7a04:	008686b3          	add	a3,a3,s0
    7a08:	00de0e33          	add	t3,t3,a3
    7a0c:	027f8eb3          	mul	t4,t6,t2
    7a10:	008e7463          	bgeu	t3,s0,7a18 <__muldf3+0x360>
    7a14:	013e8eb3          	add	t4,t4,s3
    7a18:	00010fb7          	lui	t6,0x10
    7a1c:	ffff8f93          	addi	t6,t6,-1 # ffff <_end+0xdff>
    7a20:	01fe76b3          	and	a3,t3,t6
    7a24:	01069693          	slli	a3,a3,0x10
    7a28:	01f97933          	and	s2,s2,t6
    7a2c:	01e585b3          	add	a1,a1,t5
    7a30:	012686b3          	add	a3,a3,s2
    7a34:	00c68633          	add	a2,a3,a2
    7a38:	00e5b733          	sltu	a4,a1,a4
    7a3c:	00e60733          	add	a4,a2,a4
    7a40:	00558f33          	add	t5,a1,t0
    7a44:	00f707b3          	add	a5,a4,a5
    7a48:	00bf35b3          	sltu	a1,t5,a1
    7a4c:	00b785b3          	add	a1,a5,a1
    7a50:	00d636b3          	sltu	a3,a2,a3
    7a54:	00c73633          	sltu	a2,a4,a2
    7a58:	00c6e6b3          	or	a3,a3,a2
    7a5c:	00e7b733          	sltu	a4,a5,a4
    7a60:	010e5e13          	srli	t3,t3,0x10
    7a64:	00f5b7b3          	sltu	a5,a1,a5
    7a68:	01c686b3          	add	a3,a3,t3
    7a6c:	00f76733          	or	a4,a4,a5
    7a70:	009f1793          	slli	a5,t5,0x9
    7a74:	00d70733          	add	a4,a4,a3
    7a78:	0067e7b3          	or	a5,a5,t1
    7a7c:	01d70733          	add	a4,a4,t4
    7a80:	00f037b3          	snez	a5,a5
    7a84:	017f5613          	srli	a2,t5,0x17
    7a88:	00971713          	slli	a4,a4,0x9
    7a8c:	0175d693          	srli	a3,a1,0x17
    7a90:	00c7e7b3          	or	a5,a5,a2
    7a94:	00959593          	slli	a1,a1,0x9
    7a98:	00b7ea33          	or	s4,a5,a1
    7a9c:	00771793          	slli	a5,a4,0x7
    7aa0:	00d764b3          	or	s1,a4,a3
    7aa4:	0207d063          	bgez	a5,7ac4 <__muldf3+0x40c>
    7aa8:	001a5713          	srli	a4,s4,0x1
    7aac:	001a7793          	andi	a5,s4,1
    7ab0:	01f49693          	slli	a3,s1,0x1f
    7ab4:	00f767b3          	or	a5,a4,a5
    7ab8:	00d7ea33          	or	s4,a5,a3
    7abc:	0014d493          	srli	s1,s1,0x1
    7ac0:	00050893          	mv	a7,a0
    7ac4:	3ff88613          	addi	a2,a7,1023
    7ac8:	12c05663          	blez	a2,7bf4 <__muldf3+0x53c>
    7acc:	007a7793          	andi	a5,s4,7
    7ad0:	02078063          	beqz	a5,7af0 <__muldf3+0x438>
    7ad4:	00fa7793          	andi	a5,s4,15
    7ad8:	00400713          	li	a4,4
    7adc:	00e78a63          	beq	a5,a4,7af0 <__muldf3+0x438>
    7ae0:	004a0713          	addi	a4,s4,4
    7ae4:	014737b3          	sltu	a5,a4,s4
    7ae8:	00f484b3          	add	s1,s1,a5
    7aec:	00070a13          	mv	s4,a4
    7af0:	00749793          	slli	a5,s1,0x7
    7af4:	0007da63          	bgez	a5,7b08 <__muldf3+0x450>
    7af8:	ff0007b7          	lui	a5,0xff000
    7afc:	fff78793          	addi	a5,a5,-1 # feffffff <__freertos_irq_stack_top+0xfefefdff>
    7b00:	00f4f4b3          	and	s1,s1,a5
    7b04:	40088613          	addi	a2,a7,1024
    7b08:	7fe00793          	li	a5,2046
    7b0c:	1cc7c463          	blt	a5,a2,7cd4 <__muldf3+0x61c>
    7b10:	003a5793          	srli	a5,s4,0x3
    7b14:	01d49713          	slli	a4,s1,0x1d
    7b18:	00949693          	slli	a3,s1,0x9
    7b1c:	00f76733          	or	a4,a4,a5
    7b20:	00c6d693          	srli	a3,a3,0xc
    7b24:	7ff67793          	andi	a5,a2,2047
    7b28:	d41ff06f          	j	7868 <__muldf3+0x1b0>
    7b2c:	00a4ea33          	or	s4,s1,a0
    7b30:	060a0863          	beqz	s4,7ba0 <__muldf3+0x4e8>
    7b34:	12048e63          	beqz	s1,7c70 <__muldf3+0x5b8>
    7b38:	00048513          	mv	a0,s1
    7b3c:	5d1000ef          	jal	890c <__clzsi2>
    7b40:	00050613          	mv	a2,a0
    7b44:	ff550693          	addi	a3,a0,-11
    7b48:	01d00713          	li	a4,29
    7b4c:	ff860793          	addi	a5,a2,-8 # 7fff8 <__freertos_irq_stack_top+0x6fdf8>
    7b50:	40d70733          	sub	a4,a4,a3
    7b54:	00e45733          	srl	a4,s0,a4
    7b58:	00f496b3          	sll	a3,s1,a5
    7b5c:	00d764b3          	or	s1,a4,a3
    7b60:	00f41a33          	sll	s4,s0,a5
    7b64:	c0d00793          	li	a5,-1011
    7b68:	40c78c33          	sub	s8,a5,a2
    7b6c:	00000b13          	li	s6,0
    7b70:	00000b93          	li	s7,0
    7b74:	bc1ff06f          	j	7734 <__muldf3+0x7c>
    7b78:	00058813          	mv	a6,a1
    7b7c:	7ff00793          	li	a5,2047
    7b80:	00000693          	li	a3,0
    7b84:	00000713          	li	a4,0
    7b88:	ce1ff06f          	j	7868 <__muldf3+0x1b0>
    7b8c:	00050a13          	mv	s4,a0
    7b90:	00c00b13          	li	s6,12
    7b94:	7ff00c13          	li	s8,2047
    7b98:	00300b93          	li	s7,3
    7b9c:	b99ff06f          	j	7734 <__muldf3+0x7c>
    7ba0:	00000493          	li	s1,0
    7ba4:	00400b13          	li	s6,4
    7ba8:	00000c13          	li	s8,0
    7bac:	00100b93          	li	s7,1
    7bb0:	b85ff06f          	j	7734 <__muldf3+0x7c>
    7bb4:	001b6b13          	ori	s6,s6,1
    7bb8:	000c0893          	mv	a7,s8
    7bbc:	00000413          	li	s0,0
    7bc0:	00000f13          	li	t5,0
    7bc4:	00100313          	li	t1,1
    7bc8:	bb5ff06f          	j	777c <__muldf3+0xc4>
    7bcc:	002b6b13          	ori	s6,s6,2
    7bd0:	00000413          	li	s0,0
    7bd4:	00000f13          	li	t5,0
    7bd8:	00200313          	li	t1,2
    7bdc:	ba1ff06f          	j	777c <__muldf3+0xc4>
    7be0:	00040493          	mv	s1,s0
    7be4:	000f0a13          	mv	s4,t5
    7be8:	00030b93          	mv	s7,t1
    7bec:	00098593          	mv	a1,s3
    7bf0:	c51ff06f          	j	7840 <__muldf3+0x188>
    7bf4:	00100713          	li	a4,1
    7bf8:	10061063          	bnez	a2,7cf8 <__muldf3+0x640>
    7bfc:	41e88893          	addi	a7,a7,1054
    7c00:	011a1633          	sll	a2,s4,a7
    7c04:	00c03633          	snez	a2,a2
    7c08:	011498b3          	sll	a7,s1,a7
    7c0c:	00ea57b3          	srl	a5,s4,a4
    7c10:	01166633          	or	a2,a2,a7
    7c14:	00f66633          	or	a2,a2,a5
    7c18:	00767793          	andi	a5,a2,7
    7c1c:	00e4d5b3          	srl	a1,s1,a4
    7c20:	02078063          	beqz	a5,7c40 <__muldf3+0x588>
    7c24:	00f67793          	andi	a5,a2,15
    7c28:	00400713          	li	a4,4
    7c2c:	00e78a63          	beq	a5,a4,7c40 <__muldf3+0x588>
    7c30:	00460793          	addi	a5,a2,4
    7c34:	00c7b633          	sltu	a2,a5,a2
    7c38:	00c585b3          	add	a1,a1,a2
    7c3c:	00078613          	mv	a2,a5
    7c40:	00859513          	slli	a0,a1,0x8
    7c44:	00100793          	li	a5,1
    7c48:	00000693          	li	a3,0
    7c4c:	00000713          	li	a4,0
    7c50:	c0054ce3          	bltz	a0,7868 <__muldf3+0x1b0>
    7c54:	10c0006f          	j	7d60 <__muldf3+0x6a8>
    7c58:	00f00713          	li	a4,15
    7c5c:	12eb1063          	bne	s6,a4,7d7c <__muldf3+0x6c4>
    7c60:	00000813          	li	a6,0
    7c64:	000806b7          	lui	a3,0x80
    7c68:	00000713          	li	a4,0
    7c6c:	bfdff06f          	j	7868 <__muldf3+0x1b0>
    7c70:	49d000ef          	jal	890c <__clzsi2>
    7c74:	01550693          	addi	a3,a0,21
    7c78:	01c00793          	li	a5,28
    7c7c:	02050613          	addi	a2,a0,32
    7c80:	ecd7d4e3          	bge	a5,a3,7b48 <__muldf3+0x490>
    7c84:	ff850513          	addi	a0,a0,-8
    7c88:	00000a13          	li	s4,0
    7c8c:	00a414b3          	sll	s1,s0,a0
    7c90:	ed5ff06f          	j	7b64 <__muldf3+0x4ac>
    7c94:	000a8513          	mv	a0,s5
    7c98:	475000ef          	jal	890c <__clzsi2>
    7c9c:	01550713          	addi	a4,a0,21
    7ca0:	01c00793          	li	a5,28
    7ca4:	02050893          	addi	a7,a0,32
    7ca8:	b6e7d0e3          	bge	a5,a4,7808 <__muldf3+0x150>
    7cac:	ff850513          	addi	a0,a0,-8
    7cb0:	00000f13          	li	t5,0
    7cb4:	00aa9433          	sll	s0,s5,a0
    7cb8:	b6dff06f          	j	7824 <__muldf3+0x16c>
    7cbc:	00000813          	li	a6,0
    7cc0:	7ff00793          	li	a5,2047
    7cc4:	000806b7          	lui	a3,0x80
    7cc8:	ba1ff06f          	j	7868 <__muldf3+0x1b0>
    7ccc:	00050893          	mv	a7,a0
    7cd0:	df5ff06f          	j	7ac4 <__muldf3+0x40c>
    7cd4:	7ff00793          	li	a5,2047
    7cd8:	00000693          	li	a3,0
    7cdc:	00000713          	li	a4,0
    7ce0:	b89ff06f          	j	7868 <__muldf3+0x1b0>
    7ce4:	00000813          	li	a6,0
    7ce8:	7ff00793          	li	a5,2047
    7cec:	000806b7          	lui	a3,0x80
    7cf0:	00000713          	li	a4,0
    7cf4:	b75ff06f          	j	7868 <__muldf3+0x1b0>
    7cf8:	40c70733          	sub	a4,a4,a2
    7cfc:	03800793          	li	a5,56
    7d00:	b4e7cee3          	blt	a5,a4,785c <__muldf3+0x1a4>
    7d04:	01f00793          	li	a5,31
    7d08:	eee7dae3          	bge	a5,a4,7bfc <__muldf3+0x544>
    7d0c:	fe100793          	li	a5,-31
    7d10:	40c787b3          	sub	a5,a5,a2
    7d14:	02000693          	li	a3,32
    7d18:	00f4d7b3          	srl	a5,s1,a5
    7d1c:	00d70863          	beq	a4,a3,7d2c <__muldf3+0x674>
    7d20:	43e88893          	addi	a7,a7,1086
    7d24:	011498b3          	sll	a7,s1,a7
    7d28:	011a6a33          	or	s4,s4,a7
    7d2c:	01403633          	snez	a2,s4
    7d30:	00f66633          	or	a2,a2,a5
    7d34:	00767713          	andi	a4,a2,7
    7d38:	00000693          	li	a3,0
    7d3c:	02070863          	beqz	a4,7d6c <__muldf3+0x6b4>
    7d40:	00f67793          	andi	a5,a2,15
    7d44:	00400713          	li	a4,4
    7d48:	00000593          	li	a1,0
    7d4c:	00e78a63          	beq	a5,a4,7d60 <__muldf3+0x6a8>
    7d50:	00460793          	addi	a5,a2,4
    7d54:	00c7b633          	sltu	a2,a5,a2
    7d58:	00c035b3          	snez	a1,a2
    7d5c:	00078613          	mv	a2,a5
    7d60:	00959693          	slli	a3,a1,0x9
    7d64:	01d59713          	slli	a4,a1,0x1d
    7d68:	00c6d693          	srli	a3,a3,0xc
    7d6c:	00365613          	srli	a2,a2,0x3
    7d70:	00e66733          	or	a4,a2,a4
    7d74:	00000793          	li	a5,0
    7d78:	af1ff06f          	j	7868 <__muldf3+0x1b0>
    7d7c:	00040493          	mv	s1,s0
    7d80:	000a8a13          	mv	s4,s5
    7d84:	00300b93          	li	s7,3
    7d88:	00098593          	mv	a1,s3
    7d8c:	ab5ff06f          	j	7840 <__muldf3+0x188>

00007d90 <__subdf3>:
    7d90:	001007b7          	lui	a5,0x100
    7d94:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xefdff>
    7d98:	fe010113          	addi	sp,sp,-32
    7d9c:	00b7f8b3          	and	a7,a5,a1
    7da0:	00d7f833          	and	a6,a5,a3
    7da4:	0146d793          	srli	a5,a3,0x14
    7da8:	00389893          	slli	a7,a7,0x3
    7dac:	00812c23          	sw	s0,24(sp)
    7db0:	01312623          	sw	s3,12(sp)
    7db4:	01f5d413          	srli	s0,a1,0x1f
    7db8:	0145d993          	srli	s3,a1,0x14
    7dbc:	01d55713          	srli	a4,a0,0x1d
    7dc0:	00381813          	slli	a6,a6,0x3
    7dc4:	01d65593          	srli	a1,a2,0x1d
    7dc8:	00112e23          	sw	ra,28(sp)
    7dcc:	00912a23          	sw	s1,20(sp)
    7dd0:	01212823          	sw	s2,16(sp)
    7dd4:	7ff7ff13          	andi	t5,a5,2047
    7dd8:	7ff00313          	li	t1,2047
    7ddc:	01176733          	or	a4,a4,a7
    7de0:	7ff9f993          	andi	s3,s3,2047
    7de4:	00040e13          	mv	t3,s0
    7de8:	00351893          	slli	a7,a0,0x3
    7dec:	01f6d693          	srli	a3,a3,0x1f
    7df0:	0105e5b3          	or	a1,a1,a6
    7df4:	00361e93          	slli	t4,a2,0x3
    7df8:	206f0c63          	beq	t5,t1,8010 <__subdf3+0x280>
    7dfc:	0016c693          	xori	a3,a3,1
    7e00:	41e987b3          	sub	a5,s3,t5
    7e04:	16d40263          	beq	s0,a3,7f68 <__subdf3+0x1d8>
    7e08:	00f05ae3          	blez	a5,861c <__subdf3+0x88c>
    7e0c:	240f0a63          	beqz	t5,8060 <__subdf3+0x2d0>
    7e10:	3c698463          	beq	s3,t1,81d8 <__subdf3+0x448>
    7e14:	03800693          	li	a3,56
    7e18:	00100513          	li	a0,1
    7e1c:	02f6ce63          	blt	a3,a5,7e58 <__subdf3+0xc8>
    7e20:	008006b7          	lui	a3,0x800
    7e24:	00d5e5b3          	or	a1,a1,a3
    7e28:	01f00693          	li	a3,31
    7e2c:	4ef6c463          	blt	a3,a5,8314 <__subdf3+0x584>
    7e30:	02000693          	li	a3,32
    7e34:	40f686b3          	sub	a3,a3,a5
    7e38:	00d59533          	sll	a0,a1,a3
    7e3c:	00fed633          	srl	a2,t4,a5
    7e40:	00de96b3          	sll	a3,t4,a3
    7e44:	00c56533          	or	a0,a0,a2
    7e48:	00d036b3          	snez	a3,a3
    7e4c:	00f5d7b3          	srl	a5,a1,a5
    7e50:	00d56533          	or	a0,a0,a3
    7e54:	40f70733          	sub	a4,a4,a5
    7e58:	40a88533          	sub	a0,a7,a0
    7e5c:	00a8b633          	sltu	a2,a7,a0
    7e60:	00050493          	mv	s1,a0
    7e64:	40c70933          	sub	s2,a4,a2
    7e68:	00891793          	slli	a5,s2,0x8
    7e6c:	3407d863          	bgez	a5,81bc <__subdf3+0x42c>
    7e70:	008007b7          	lui	a5,0x800
    7e74:	fff78793          	addi	a5,a5,-1 # 7fffff <__freertos_irq_stack_top+0x7efdff>
    7e78:	00f97933          	and	s2,s2,a5
    7e7c:	2e090663          	beqz	s2,8168 <__subdf3+0x3d8>
    7e80:	00090513          	mv	a0,s2
    7e84:	289000ef          	jal	890c <__clzsi2>
    7e88:	ff850793          	addi	a5,a0,-8
    7e8c:	02000693          	li	a3,32
    7e90:	40f68733          	sub	a4,a3,a5
    7e94:	00e4d733          	srl	a4,s1,a4
    7e98:	00f91933          	sll	s2,s2,a5
    7e9c:	01276733          	or	a4,a4,s2
    7ea0:	00f494b3          	sll	s1,s1,a5
    7ea4:	3f37c463          	blt	a5,s3,828c <__subdf3+0x4fc>
    7ea8:	413787b3          	sub	a5,a5,s3
    7eac:	00178793          	addi	a5,a5,1
    7eb0:	40f686b3          	sub	a3,a3,a5
    7eb4:	00d49633          	sll	a2,s1,a3
    7eb8:	00f4d933          	srl	s2,s1,a5
    7ebc:	00c03633          	snez	a2,a2
    7ec0:	00c96633          	or	a2,s2,a2
    7ec4:	00d716b3          	sll	a3,a4,a3
    7ec8:	00c6e4b3          	or	s1,a3,a2
    7ecc:	00f75933          	srl	s2,a4,a5
    7ed0:	00000993          	li	s3,0
    7ed4:	0074f793          	andi	a5,s1,7
    7ed8:	02078063          	beqz	a5,7ef8 <__subdf3+0x168>
    7edc:	00f4f793          	andi	a5,s1,15
    7ee0:	00400713          	li	a4,4
    7ee4:	00e78a63          	beq	a5,a4,7ef8 <__subdf3+0x168>
    7ee8:	00448793          	addi	a5,s1,4
    7eec:	0097b533          	sltu	a0,a5,s1
    7ef0:	00a90933          	add	s2,s2,a0
    7ef4:	00078493          	mv	s1,a5
    7ef8:	00891793          	slli	a5,s2,0x8
    7efc:	6c07d063          	bgez	a5,85bc <__subdf3+0x82c>
    7f00:	00198793          	addi	a5,s3,1
    7f04:	7ff00713          	li	a4,2047
    7f08:	24e78663          	beq	a5,a4,8154 <__subdf3+0x3c4>
    7f0c:	ff800737          	lui	a4,0xff800
    7f10:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7efdff>
    7f14:	00e97733          	and	a4,s2,a4
    7f18:	7ff7f793          	andi	a5,a5,2047
    7f1c:	01d71813          	slli	a6,a4,0x1d
    7f20:	0034d513          	srli	a0,s1,0x3
    7f24:	00971713          	slli	a4,a4,0x9
    7f28:	00a86833          	or	a6,a6,a0
    7f2c:	00c75713          	srli	a4,a4,0xc
    7f30:	00147e13          	andi	t3,s0,1
    7f34:	01c12083          	lw	ra,28(sp)
    7f38:	01812403          	lw	s0,24(sp)
    7f3c:	01479793          	slli	a5,a5,0x14
    7f40:	00e7e7b3          	or	a5,a5,a4
    7f44:	01fe1713          	slli	a4,t3,0x1f
    7f48:	00e7e7b3          	or	a5,a5,a4
    7f4c:	01412483          	lw	s1,20(sp)
    7f50:	01012903          	lw	s2,16(sp)
    7f54:	00c12983          	lw	s3,12(sp)
    7f58:	00080513          	mv	a0,a6
    7f5c:	00078593          	mv	a1,a5
    7f60:	02010113          	addi	sp,sp,32
    7f64:	00008067          	ret
    7f68:	70f05263          	blez	a5,866c <__subdf3+0x8dc>
    7f6c:	1c0f1663          	bnez	t5,8138 <__subdf3+0x3a8>
    7f70:	01d5e6b3          	or	a3,a1,t4
    7f74:	26068e63          	beqz	a3,81f0 <__subdf3+0x460>
    7f78:	fff78693          	addi	a3,a5,-1
    7f7c:	46068863          	beqz	a3,83ec <__subdf3+0x65c>
    7f80:	24678c63          	beq	a5,t1,81d8 <__subdf3+0x448>
    7f84:	03800793          	li	a5,56
    7f88:	00100913          	li	s2,1
    7f8c:	02d7cc63          	blt	a5,a3,7fc4 <__subdf3+0x234>
    7f90:	00068793          	mv	a5,a3
    7f94:	01f00693          	li	a3,31
    7f98:	48f6ca63          	blt	a3,a5,842c <__subdf3+0x69c>
    7f9c:	02000693          	li	a3,32
    7fa0:	40f686b3          	sub	a3,a3,a5
    7fa4:	00d59933          	sll	s2,a1,a3
    7fa8:	00fed633          	srl	a2,t4,a5
    7fac:	00de96b3          	sll	a3,t4,a3
    7fb0:	00c96933          	or	s2,s2,a2
    7fb4:	00d036b3          	snez	a3,a3
    7fb8:	00f5d7b3          	srl	a5,a1,a5
    7fbc:	00d96933          	or	s2,s2,a3
    7fc0:	00f70733          	add	a4,a4,a5
    7fc4:	01190633          	add	a2,s2,a7
    7fc8:	01263933          	sltu	s2,a2,s2
    7fcc:	00060493          	mv	s1,a2
    7fd0:	00e90933          	add	s2,s2,a4
    7fd4:	00891793          	slli	a5,s2,0x8
    7fd8:	1e07d263          	bgez	a5,81bc <__subdf3+0x42c>
    7fdc:	00198993          	addi	s3,s3,1
    7fe0:	7ff00793          	li	a5,2047
    7fe4:	16f98863          	beq	s3,a5,8154 <__subdf3+0x3c4>
    7fe8:	ff8007b7          	lui	a5,0xff800
    7fec:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7efdff>
    7ff0:	0014f513          	andi	a0,s1,1
    7ff4:	00f977b3          	and	a5,s2,a5
    7ff8:	0014d713          	srli	a4,s1,0x1
    7ffc:	00a76733          	or	a4,a4,a0
    8000:	01f79513          	slli	a0,a5,0x1f
    8004:	00e564b3          	or	s1,a0,a4
    8008:	0017d913          	srli	s2,a5,0x1
    800c:	ec9ff06f          	j	7ed4 <__subdf3+0x144>
    8010:	01d5e833          	or	a6,a1,t4
    8014:	80198313          	addi	t1,s3,-2047
    8018:	06080863          	beqz	a6,8088 <__subdf3+0x2f8>
    801c:	06d40a63          	beq	s0,a3,8090 <__subdf3+0x300>
    8020:	0e030463          	beqz	t1,8108 <__subdf3+0x378>
    8024:	26098e63          	beqz	s3,82a0 <__subdf3+0x510>
    8028:	00361513          	slli	a0,a2,0x3
    802c:	00355513          	srli	a0,a0,0x3
    8030:	00068413          	mv	s0,a3
    8034:	00058713          	mv	a4,a1
    8038:	01d71813          	slli	a6,a4,0x1d
    803c:	00a86833          	or	a6,a6,a0
    8040:	00375713          	srli	a4,a4,0x3
    8044:	01076733          	or	a4,a4,a6
    8048:	10070663          	beqz	a4,8154 <__subdf3+0x3c4>
    804c:	00000e13          	li	t3,0
    8050:	7ff00793          	li	a5,2047
    8054:	00080737          	lui	a4,0x80
    8058:	00000813          	li	a6,0
    805c:	ed9ff06f          	j	7f34 <__subdf3+0x1a4>
    8060:	01d5e6b3          	or	a3,a1,t4
    8064:	18068663          	beqz	a3,81f0 <__subdf3+0x460>
    8068:	fff78693          	addi	a3,a5,-1
    806c:	3a068263          	beqz	a3,8410 <__subdf3+0x680>
    8070:	16678463          	beq	a5,t1,81d8 <__subdf3+0x448>
    8074:	03800793          	li	a5,56
    8078:	00100513          	li	a0,1
    807c:	dcd7cee3          	blt	a5,a3,7e58 <__subdf3+0xc8>
    8080:	00068793          	mv	a5,a3
    8084:	da5ff06f          	j	7e28 <__subdf3+0x98>
    8088:	0016c693          	xori	a3,a3,1
    808c:	f8d41ae3          	bne	s0,a3,8020 <__subdf3+0x290>
    8090:	18030863          	beqz	t1,8220 <__subdf3+0x490>
    8094:	2c099063          	bnez	s3,8354 <__subdf3+0x5c4>
    8098:	7ff00793          	li	a5,2047
    809c:	011766b3          	or	a3,a4,a7
    80a0:	48068863          	beqz	a3,8530 <__subdf3+0x7a0>
    80a4:	fff78693          	addi	a3,a5,-1
    80a8:	34068263          	beqz	a3,83ec <__subdf3+0x65c>
    80ac:	7ff00513          	li	a0,2047
    80b0:	2aa78263          	beq	a5,a0,8354 <__subdf3+0x5c4>
    80b4:	03800793          	li	a5,56
    80b8:	00100913          	li	s2,1
    80bc:	02d7ca63          	blt	a5,a3,80f0 <__subdf3+0x360>
    80c0:	01f00793          	li	a5,31
    80c4:	4cd7c663          	blt	a5,a3,8590 <__subdf3+0x800>
    80c8:	02000793          	li	a5,32
    80cc:	40d787b3          	sub	a5,a5,a3
    80d0:	00f71933          	sll	s2,a4,a5
    80d4:	00d8d633          	srl	a2,a7,a3
    80d8:	00f897b3          	sll	a5,a7,a5
    80dc:	00c96933          	or	s2,s2,a2
    80e0:	00f037b3          	snez	a5,a5
    80e4:	00d756b3          	srl	a3,a4,a3
    80e8:	00f96933          	or	s2,s2,a5
    80ec:	00d585b3          	add	a1,a1,a3
    80f0:	01d90733          	add	a4,s2,t4
    80f4:	01273933          	sltu	s2,a4,s2
    80f8:	00070493          	mv	s1,a4
    80fc:	00b90933          	add	s2,s2,a1
    8100:	000f0993          	mv	s3,t5
    8104:	ed1ff06f          	j	7fd4 <__subdf3+0x244>
    8108:	00198793          	addi	a5,s3,1
    810c:	7fe7f793          	andi	a5,a5,2046
    8110:	14079463          	bnez	a5,8258 <__subdf3+0x4c8>
    8114:	01d5e833          	or	a6,a1,t4
    8118:	011767b3          	or	a5,a4,a7
    811c:	2a099463          	bnez	s3,83c4 <__subdf3+0x634>
    8120:	38078e63          	beqz	a5,84bc <__subdf3+0x72c>
    8124:	3c081063          	bnez	a6,84e4 <__subdf3+0x754>
    8128:	00351513          	slli	a0,a0,0x3
    812c:	00355913          	srli	s2,a0,0x3
    8130:	00000793          	li	a5,0
    8134:	1140006f          	j	8248 <__subdf3+0x4b8>
    8138:	0a698063          	beq	s3,t1,81d8 <__subdf3+0x448>
    813c:	03800693          	li	a3,56
    8140:	00100913          	li	s2,1
    8144:	e8f6c0e3          	blt	a3,a5,7fc4 <__subdf3+0x234>
    8148:	008006b7          	lui	a3,0x800
    814c:	00d5e5b3          	or	a1,a1,a3
    8150:	e45ff06f          	j	7f94 <__subdf3+0x204>
    8154:	00147e13          	andi	t3,s0,1
    8158:	7ff00793          	li	a5,2047
    815c:	00000713          	li	a4,0
    8160:	00000813          	li	a6,0
    8164:	dd1ff06f          	j	7f34 <__subdf3+0x1a4>
    8168:	00048513          	mv	a0,s1
    816c:	7a0000ef          	jal	890c <__clzsi2>
    8170:	01850793          	addi	a5,a0,24
    8174:	01f00693          	li	a3,31
    8178:	d0f6dae3          	bge	a3,a5,7e8c <__subdf3+0xfc>
    817c:	ff850713          	addi	a4,a0,-8
    8180:	00e49733          	sll	a4,s1,a4
    8184:	1b37ce63          	blt	a5,s3,8340 <__subdf3+0x5b0>
    8188:	413789b3          	sub	s3,a5,s3
    818c:	00198793          	addi	a5,s3,1
    8190:	42f6de63          	bge	a3,a5,85cc <__subdf3+0x83c>
    8194:	fe198993          	addi	s3,s3,-31
    8198:	02000693          	li	a3,32
    819c:	013754b3          	srl	s1,a4,s3
    81a0:	00d78c63          	beq	a5,a3,81b8 <__subdf3+0x428>
    81a4:	04000693          	li	a3,64
    81a8:	40f687b3          	sub	a5,a3,a5
    81ac:	00f71733          	sll	a4,a4,a5
    81b0:	00e03733          	snez	a4,a4
    81b4:	00e4e4b3          	or	s1,s1,a4
    81b8:	00000993          	li	s3,0
    81bc:	0074f793          	andi	a5,s1,7
    81c0:	d0079ee3          	bnez	a5,7edc <__subdf3+0x14c>
    81c4:	00098793          	mv	a5,s3
    81c8:	0034d513          	srli	a0,s1,0x3
    81cc:	00090713          	mv	a4,s2
    81d0:	0280006f          	j	81f8 <__subdf3+0x468>
    81d4:	e6081ce3          	bnez	a6,804c <__subdf3+0x2bc>
    81d8:	00351513          	slli	a0,a0,0x3
    81dc:	01d71813          	slli	a6,a4,0x1d
    81e0:	00355513          	srli	a0,a0,0x3
    81e4:	00a86833          	or	a6,a6,a0
    81e8:	00375713          	srli	a4,a4,0x3
    81ec:	e59ff06f          	j	8044 <__subdf3+0x2b4>
    81f0:	00351513          	slli	a0,a0,0x3
    81f4:	00355513          	srli	a0,a0,0x3
    81f8:	01d71813          	slli	a6,a4,0x1d
    81fc:	7ff00693          	li	a3,2047
    8200:	00a86833          	or	a6,a6,a0
    8204:	00375713          	srli	a4,a4,0x3
    8208:	e2d78ee3          	beq	a5,a3,8044 <__subdf3+0x2b4>
    820c:	00c71713          	slli	a4,a4,0xc
    8210:	00c75713          	srli	a4,a4,0xc
    8214:	7ff7f793          	andi	a5,a5,2047
    8218:	00147e13          	andi	t3,s0,1
    821c:	d19ff06f          	j	7f34 <__subdf3+0x1a4>
    8220:	00198693          	addi	a3,s3,1
    8224:	7fe6f793          	andi	a5,a3,2046
    8228:	12079e63          	bnez	a5,8364 <__subdf3+0x5d4>
    822c:	011767b3          	or	a5,a4,a7
    8230:	24099a63          	bnez	s3,8484 <__subdf3+0x6f4>
    8234:	30078663          	beqz	a5,8540 <__subdf3+0x7b0>
    8238:	01d5e7b3          	or	a5,a1,t4
    823c:	30079a63          	bnez	a5,8550 <__subdf3+0x7c0>
    8240:	00351513          	slli	a0,a0,0x3
    8244:	00355913          	srli	s2,a0,0x3
    8248:	01d71813          	slli	a6,a4,0x1d
    824c:	01286833          	or	a6,a6,s2
    8250:	00375713          	srli	a4,a4,0x3
    8254:	fb9ff06f          	j	820c <__subdf3+0x47c>
    8258:	41d88833          	sub	a6,a7,t4
    825c:	0108b7b3          	sltu	a5,a7,a6
    8260:	40b70933          	sub	s2,a4,a1
    8264:	40f90933          	sub	s2,s2,a5
    8268:	00891793          	slli	a5,s2,0x8
    826c:	00080493          	mv	s1,a6
    8270:	1207c263          	bltz	a5,8394 <__subdf3+0x604>
    8274:	01286833          	or	a6,a6,s2
    8278:	c00812e3          	bnez	a6,7e7c <__subdf3+0xec>
    827c:	00000e13          	li	t3,0
    8280:	00000793          	li	a5,0
    8284:	00000713          	li	a4,0
    8288:	cadff06f          	j	7f34 <__subdf3+0x1a4>
    828c:	ff800937          	lui	s2,0xff800
    8290:	fff90913          	addi	s2,s2,-1 # ff7fffff <__freertos_irq_stack_top+0xff7efdff>
    8294:	40f989b3          	sub	s3,s3,a5
    8298:	01277933          	and	s2,a4,s2
    829c:	c39ff06f          	j	7ed4 <__subdf3+0x144>
    82a0:	7ff00793          	li	a5,2047
    82a4:	01176533          	or	a0,a4,a7
    82a8:	10050463          	beqz	a0,83b0 <__subdf3+0x620>
    82ac:	fff78813          	addi	a6,a5,-1
    82b0:	1e080263          	beqz	a6,8494 <__subdf3+0x704>
    82b4:	7ff00513          	li	a0,2047
    82b8:	d6a788e3          	beq	a5,a0,8028 <__subdf3+0x298>
    82bc:	03800793          	li	a5,56
    82c0:	00068413          	mv	s0,a3
    82c4:	00100513          	li	a0,1
    82c8:	0307ca63          	blt	a5,a6,82fc <__subdf3+0x56c>
    82cc:	01f00793          	li	a5,31
    82d0:	1907c463          	blt	a5,a6,8458 <__subdf3+0x6c8>
    82d4:	02000793          	li	a5,32
    82d8:	410787b3          	sub	a5,a5,a6
    82dc:	00f71533          	sll	a0,a4,a5
    82e0:	0108d6b3          	srl	a3,a7,a6
    82e4:	00f897b3          	sll	a5,a7,a5
    82e8:	00d56533          	or	a0,a0,a3
    82ec:	00f037b3          	snez	a5,a5
    82f0:	01075833          	srl	a6,a4,a6
    82f4:	00f56533          	or	a0,a0,a5
    82f8:	410585b3          	sub	a1,a1,a6
    82fc:	40ae8533          	sub	a0,t4,a0
    8300:	00aeb733          	sltu	a4,t4,a0
    8304:	00050493          	mv	s1,a0
    8308:	40e58933          	sub	s2,a1,a4
    830c:	000f0993          	mv	s3,t5
    8310:	b59ff06f          	j	7e68 <__subdf3+0xd8>
    8314:	fe078693          	addi	a3,a5,-32
    8318:	02000613          	li	a2,32
    831c:	00d5d6b3          	srl	a3,a1,a3
    8320:	00c78a63          	beq	a5,a2,8334 <__subdf3+0x5a4>
    8324:	04000613          	li	a2,64
    8328:	40f607b3          	sub	a5,a2,a5
    832c:	00f597b3          	sll	a5,a1,a5
    8330:	00feeeb3          	or	t4,t4,a5
    8334:	01d03533          	snez	a0,t4
    8338:	00d56533          	or	a0,a0,a3
    833c:	b1dff06f          	j	7e58 <__subdf3+0xc8>
    8340:	ff8006b7          	lui	a3,0xff800
    8344:	fff68693          	addi	a3,a3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7efdff>
    8348:	40f987b3          	sub	a5,s3,a5
    834c:	00d77733          	and	a4,a4,a3
    8350:	ef9ff06f          	j	8248 <__subdf3+0x4b8>
    8354:	00361513          	slli	a0,a2,0x3
    8358:	00355513          	srli	a0,a0,0x3
    835c:	00058713          	mv	a4,a1
    8360:	cd9ff06f          	j	8038 <__subdf3+0x2a8>
    8364:	7ff00793          	li	a5,2047
    8368:	def686e3          	beq	a3,a5,8154 <__subdf3+0x3c4>
    836c:	01d88eb3          	add	t4,a7,t4
    8370:	011eb633          	sltu	a2,t4,a7
    8374:	00b707b3          	add	a5,a4,a1
    8378:	00c787b3          	add	a5,a5,a2
    837c:	01f79513          	slli	a0,a5,0x1f
    8380:	001ede93          	srli	t4,t4,0x1
    8384:	01d564b3          	or	s1,a0,t4
    8388:	0017d913          	srli	s2,a5,0x1
    838c:	00068993          	mv	s3,a3
    8390:	b45ff06f          	j	7ed4 <__subdf3+0x144>
    8394:	411e8633          	sub	a2,t4,a7
    8398:	40e587b3          	sub	a5,a1,a4
    839c:	00ceb733          	sltu	a4,t4,a2
    83a0:	00060493          	mv	s1,a2
    83a4:	40e78933          	sub	s2,a5,a4
    83a8:	00068413          	mv	s0,a3
    83ac:	ad1ff06f          	j	7e7c <__subdf3+0xec>
    83b0:	00361613          	slli	a2,a2,0x3
    83b4:	00365513          	srli	a0,a2,0x3
    83b8:	00068413          	mv	s0,a3
    83bc:	00058713          	mv	a4,a1
    83c0:	e39ff06f          	j	81f8 <__subdf3+0x468>
    83c4:	e00798e3          	bnez	a5,81d4 <__subdf3+0x444>
    83c8:	22080663          	beqz	a6,85f4 <__subdf3+0x864>
    83cc:	0035d713          	srli	a4,a1,0x3
    83d0:	00361613          	slli	a2,a2,0x3
    83d4:	01d59593          	slli	a1,a1,0x1d
    83d8:	00b76733          	or	a4,a4,a1
    83dc:	00365613          	srli	a2,a2,0x3
    83e0:	00c76733          	or	a4,a4,a2
    83e4:	00068413          	mv	s0,a3
    83e8:	c61ff06f          	j	8048 <__subdf3+0x2b8>
    83ec:	01d88eb3          	add	t4,a7,t4
    83f0:	00b705b3          	add	a1,a4,a1
    83f4:	011eb633          	sltu	a2,t4,a7
    83f8:	00c58933          	add	s2,a1,a2
    83fc:	00891793          	slli	a5,s2,0x8
    8400:	000e8493          	mv	s1,t4
    8404:	0a07d863          	bgez	a5,84b4 <__subdf3+0x724>
    8408:	00200993          	li	s3,2
    840c:	bddff06f          	j	7fe8 <__subdf3+0x258>
    8410:	41d88eb3          	sub	t4,a7,t4
    8414:	40b705b3          	sub	a1,a4,a1
    8418:	01d8b633          	sltu	a2,a7,t4
    841c:	000e8493          	mv	s1,t4
    8420:	40c58933          	sub	s2,a1,a2
    8424:	00100993          	li	s3,1
    8428:	a41ff06f          	j	7e68 <__subdf3+0xd8>
    842c:	fe078693          	addi	a3,a5,-32
    8430:	02000613          	li	a2,32
    8434:	00d5d6b3          	srl	a3,a1,a3
    8438:	00c78a63          	beq	a5,a2,844c <__subdf3+0x6bc>
    843c:	04000613          	li	a2,64
    8440:	40f607b3          	sub	a5,a2,a5
    8444:	00f597b3          	sll	a5,a1,a5
    8448:	00feeeb3          	or	t4,t4,a5
    844c:	01d03933          	snez	s2,t4
    8450:	00d96933          	or	s2,s2,a3
    8454:	b71ff06f          	j	7fc4 <__subdf3+0x234>
    8458:	fe080793          	addi	a5,a6,-32
    845c:	02000693          	li	a3,32
    8460:	00f757b3          	srl	a5,a4,a5
    8464:	00d80a63          	beq	a6,a3,8478 <__subdf3+0x6e8>
    8468:	04000693          	li	a3,64
    846c:	410686b3          	sub	a3,a3,a6
    8470:	00d71733          	sll	a4,a4,a3
    8474:	00e8e8b3          	or	a7,a7,a4
    8478:	01103533          	snez	a0,a7
    847c:	00f56533          	or	a0,a0,a5
    8480:	e7dff06f          	j	82fc <__subdf3+0x56c>
    8484:	ec0788e3          	beqz	a5,8354 <__subdf3+0x5c4>
    8488:	01d5eeb3          	or	t4,a1,t4
    848c:	bc0e90e3          	bnez	t4,804c <__subdf3+0x2bc>
    8490:	d49ff06f          	j	81d8 <__subdf3+0x448>
    8494:	411e8633          	sub	a2,t4,a7
    8498:	40e585b3          	sub	a1,a1,a4
    849c:	00ceb733          	sltu	a4,t4,a2
    84a0:	00060493          	mv	s1,a2
    84a4:	40e58933          	sub	s2,a1,a4
    84a8:	00068413          	mv	s0,a3
    84ac:	00100993          	li	s3,1
    84b0:	9b9ff06f          	j	7e68 <__subdf3+0xd8>
    84b4:	00100793          	li	a5,1
    84b8:	d11ff06f          	j	81c8 <__subdf3+0x438>
    84bc:	dc0800e3          	beqz	a6,827c <__subdf3+0x4ec>
    84c0:	00361613          	slli	a2,a2,0x3
    84c4:	00365793          	srli	a5,a2,0x3
    84c8:	01d59813          	slli	a6,a1,0x1d
    84cc:	00959713          	slli	a4,a1,0x9
    84d0:	00f86833          	or	a6,a6,a5
    84d4:	00c75713          	srli	a4,a4,0xc
    84d8:	00068e13          	mv	t3,a3
    84dc:	00000793          	li	a5,0
    84e0:	a55ff06f          	j	7f34 <__subdf3+0x1a4>
    84e4:	41d88933          	sub	s2,a7,t4
    84e8:	0128b7b3          	sltu	a5,a7,s2
    84ec:	40b70633          	sub	a2,a4,a1
    84f0:	40f60633          	sub	a2,a2,a5
    84f4:	00861793          	slli	a5,a2,0x8
    84f8:	0e07d263          	bgez	a5,85dc <__subdf3+0x84c>
    84fc:	411e8633          	sub	a2,t4,a7
    8500:	40e58733          	sub	a4,a1,a4
    8504:	00cebeb3          	sltu	t4,t4,a2
    8508:	41d70733          	sub	a4,a4,t4
    850c:	00871793          	slli	a5,a4,0x8
    8510:	00060493          	mv	s1,a2
    8514:	1207de63          	bgez	a5,8650 <__subdf3+0x8c0>
    8518:	ff8007b7          	lui	a5,0xff800
    851c:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7efdff>
    8520:	00f77733          	and	a4,a4,a5
    8524:	00068413          	mv	s0,a3
    8528:	00100793          	li	a5,1
    852c:	9f1ff06f          	j	7f1c <__subdf3+0x18c>
    8530:	00361613          	slli	a2,a2,0x3
    8534:	00365513          	srli	a0,a2,0x3
    8538:	00058713          	mv	a4,a1
    853c:	cbdff06f          	j	81f8 <__subdf3+0x468>
    8540:	00361613          	slli	a2,a2,0x3
    8544:	00365913          	srli	s2,a2,0x3
    8548:	00058713          	mv	a4,a1
    854c:	cfdff06f          	j	8248 <__subdf3+0x4b8>
    8550:	01d886b3          	add	a3,a7,t4
    8554:	00b707b3          	add	a5,a4,a1
    8558:	0116b633          	sltu	a2,a3,a7
    855c:	00c787b3          	add	a5,a5,a2
    8560:	00879713          	slli	a4,a5,0x8
    8564:	0036d813          	srli	a6,a3,0x3
    8568:	08075e63          	bgez	a4,8604 <__subdf3+0x874>
    856c:	ff800737          	lui	a4,0xff800
    8570:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7efdff>
    8574:	00e7f7b3          	and	a5,a5,a4
    8578:	01d79713          	slli	a4,a5,0x1d
    857c:	00979793          	slli	a5,a5,0x9
    8580:	01076833          	or	a6,a4,a6
    8584:	00c7d713          	srli	a4,a5,0xc
    8588:	00100793          	li	a5,1
    858c:	9a9ff06f          	j	7f34 <__subdf3+0x1a4>
    8590:	fe068793          	addi	a5,a3,-32
    8594:	02000613          	li	a2,32
    8598:	00f757b3          	srl	a5,a4,a5
    859c:	00c68a63          	beq	a3,a2,85b0 <__subdf3+0x820>
    85a0:	04000613          	li	a2,64
    85a4:	40d606b3          	sub	a3,a2,a3
    85a8:	00d71733          	sll	a4,a4,a3
    85ac:	00e8e8b3          	or	a7,a7,a4
    85b0:	01103933          	snez	s2,a7
    85b4:	00f96933          	or	s2,s2,a5
    85b8:	b39ff06f          	j	80f0 <__subdf3+0x360>
    85bc:	0034d513          	srli	a0,s1,0x3
    85c0:	00098793          	mv	a5,s3
    85c4:	00090713          	mv	a4,s2
    85c8:	c31ff06f          	j	81f8 <__subdf3+0x468>
    85cc:	02000693          	li	a3,32
    85d0:	40f686b3          	sub	a3,a3,a5
    85d4:	00000613          	li	a2,0
    85d8:	8e9ff06f          	j	7ec0 <__subdf3+0x130>
    85dc:	00c96833          	or	a6,s2,a2
    85e0:	c8080ee3          	beqz	a6,827c <__subdf3+0x4ec>
    85e4:	00395913          	srli	s2,s2,0x3
    85e8:	00000793          	li	a5,0
    85ec:	00060713          	mv	a4,a2
    85f0:	c59ff06f          	j	8248 <__subdf3+0x4b8>
    85f4:	00000e13          	li	t3,0
    85f8:	7ff00793          	li	a5,2047
    85fc:	00080737          	lui	a4,0x80
    8600:	935ff06f          	j	7f34 <__subdf3+0x1a4>
    8604:	01d79713          	slli	a4,a5,0x1d
    8608:	00979793          	slli	a5,a5,0x9
    860c:	01076833          	or	a6,a4,a6
    8610:	00c7d713          	srli	a4,a5,0xc
    8614:	00000793          	li	a5,0
    8618:	91dff06f          	j	7f34 <__subdf3+0x1a4>
    861c:	ae0786e3          	beqz	a5,8108 <__subdf3+0x378>
    8620:	413f0833          	sub	a6,t5,s3
    8624:	00080793          	mv	a5,a6
    8628:	c6098ee3          	beqz	s3,82a4 <__subdf3+0x514>
    862c:	03800793          	li	a5,56
    8630:	0107ca63          	blt	a5,a6,8644 <__subdf3+0x8b4>
    8634:	008007b7          	lui	a5,0x800
    8638:	00f76733          	or	a4,a4,a5
    863c:	00068413          	mv	s0,a3
    8640:	c8dff06f          	j	82cc <__subdf3+0x53c>
    8644:	00068413          	mv	s0,a3
    8648:	00100513          	li	a0,1
    864c:	cb1ff06f          	j	82fc <__subdf3+0x56c>
    8650:	01d71813          	slli	a6,a4,0x1d
    8654:	00365613          	srli	a2,a2,0x3
    8658:	00c86833          	or	a6,a6,a2
    865c:	00375713          	srli	a4,a4,0x3
    8660:	00000793          	li	a5,0
    8664:	00068413          	mv	s0,a3
    8668:	ba5ff06f          	j	820c <__subdf3+0x47c>
    866c:	ba078ae3          	beqz	a5,8220 <__subdf3+0x490>
    8670:	413f06b3          	sub	a3,t5,s3
    8674:	00099663          	bnez	s3,8680 <__subdf3+0x8f0>
    8678:	00068793          	mv	a5,a3
    867c:	a21ff06f          	j	809c <__subdf3+0x30c>
    8680:	03800793          	li	a5,56
    8684:	00100913          	li	s2,1
    8688:	a6d7c4e3          	blt	a5,a3,80f0 <__subdf3+0x360>
    868c:	008007b7          	lui	a5,0x800
    8690:	00f76733          	or	a4,a4,a5
    8694:	a2dff06f          	j	80c0 <__subdf3+0x330>

00008698 <__fixdfsi>:
    8698:	0145d793          	srli	a5,a1,0x14
    869c:	001006b7          	lui	a3,0x100
    86a0:	fff68713          	addi	a4,a3,-1 # fffff <__freertos_irq_stack_top+0xefdff>
    86a4:	7ff7f793          	andi	a5,a5,2047
    86a8:	3fe00613          	li	a2,1022
    86ac:	00b77733          	and	a4,a4,a1
    86b0:	01f5d593          	srli	a1,a1,0x1f
    86b4:	00f65e63          	bge	a2,a5,86d0 <__fixdfsi+0x38>
    86b8:	41d00613          	li	a2,1053
    86bc:	00f65e63          	bge	a2,a5,86d8 <__fixdfsi+0x40>
    86c0:	80000537          	lui	a0,0x80000
    86c4:	fff50513          	addi	a0,a0,-1 # 7fffffff <__freertos_irq_stack_top+0x7ffefdff>
    86c8:	00a58533          	add	a0,a1,a0
    86cc:	00008067          	ret
    86d0:	00000513          	li	a0,0
    86d4:	00008067          	ret
    86d8:	43300613          	li	a2,1075
    86dc:	40f60633          	sub	a2,a2,a5
    86e0:	01f00813          	li	a6,31
    86e4:	00d76733          	or	a4,a4,a3
    86e8:	02c85063          	bge	a6,a2,8708 <__fixdfsi+0x70>
    86ec:	41300693          	li	a3,1043
    86f0:	40f687b3          	sub	a5,a3,a5
    86f4:	00f75733          	srl	a4,a4,a5
    86f8:	40e00533          	neg	a0,a4
    86fc:	fc059ce3          	bnez	a1,86d4 <__fixdfsi+0x3c>
    8700:	00070513          	mv	a0,a4
    8704:	00008067          	ret
    8708:	bed78793          	addi	a5,a5,-1043 # 7ffbed <__freertos_irq_stack_top+0x7ef9ed>
    870c:	00f71733          	sll	a4,a4,a5
    8710:	00c55533          	srl	a0,a0,a2
    8714:	00a76733          	or	a4,a4,a0
    8718:	fe1ff06f          	j	86f8 <__fixdfsi+0x60>

0000871c <__fixunsdfsi>:
    871c:	0145d793          	srli	a5,a1,0x14
    8720:	00100637          	lui	a2,0x100
    8724:	fff60713          	addi	a4,a2,-1 # fffff <__freertos_irq_stack_top+0xefdff>
    8728:	7ff7f793          	andi	a5,a5,2047
    872c:	3fe00813          	li	a6,1022
    8730:	00050693          	mv	a3,a0
    8734:	00b77733          	and	a4,a4,a1
    8738:	00000513          	li	a0,0
    873c:	01f5d593          	srli	a1,a1,0x1f
    8740:	00f85463          	bge	a6,a5,8748 <__fixunsdfsi+0x2c>
    8744:	00058463          	beqz	a1,874c <__fixunsdfsi+0x30>
    8748:	00008067          	ret
    874c:	41e00593          	li	a1,1054
    8750:	fff00513          	li	a0,-1
    8754:	fef5cae3          	blt	a1,a5,8748 <__fixunsdfsi+0x2c>
    8758:	43300593          	li	a1,1075
    875c:	40f585b3          	sub	a1,a1,a5
    8760:	01f00513          	li	a0,31
    8764:	00c76733          	or	a4,a4,a2
    8768:	00b54c63          	blt	a0,a1,8780 <__fixunsdfsi+0x64>
    876c:	bed78793          	addi	a5,a5,-1043
    8770:	00f71733          	sll	a4,a4,a5
    8774:	00b6d533          	srl	a0,a3,a1
    8778:	00a76533          	or	a0,a4,a0
    877c:	00008067          	ret
    8780:	41300513          	li	a0,1043
    8784:	40f50533          	sub	a0,a0,a5
    8788:	00a75533          	srl	a0,a4,a0
    878c:	00008067          	ret

00008790 <__floatsidf>:
    8790:	ff010113          	addi	sp,sp,-16
    8794:	00112623          	sw	ra,12(sp)
    8798:	00812423          	sw	s0,8(sp)
    879c:	00912223          	sw	s1,4(sp)
    87a0:	04050a63          	beqz	a0,87f4 <__floatsidf+0x64>
    87a4:	41f55713          	srai	a4,a0,0x1f
    87a8:	00a744b3          	xor	s1,a4,a0
    87ac:	40e484b3          	sub	s1,s1,a4
    87b0:	00050793          	mv	a5,a0
    87b4:	00048513          	mv	a0,s1
    87b8:	01f7d413          	srli	s0,a5,0x1f
    87bc:	150000ef          	jal	890c <__clzsi2>
    87c0:	41e00793          	li	a5,1054
    87c4:	40a787b3          	sub	a5,a5,a0
    87c8:	00a00713          	li	a4,10
    87cc:	7ff7f793          	andi	a5,a5,2047
    87d0:	06a74063          	blt	a4,a0,8830 <__floatsidf+0xa0>
    87d4:	00b00713          	li	a4,11
    87d8:	40a70733          	sub	a4,a4,a0
    87dc:	00e4d733          	srl	a4,s1,a4
    87e0:	01550513          	addi	a0,a0,21
    87e4:	00c71713          	slli	a4,a4,0xc
    87e8:	00a494b3          	sll	s1,s1,a0
    87ec:	00c75713          	srli	a4,a4,0xc
    87f0:	0140006f          	j	8804 <__floatsidf+0x74>
    87f4:	00000413          	li	s0,0
    87f8:	00000793          	li	a5,0
    87fc:	00000713          	li	a4,0
    8800:	00000493          	li	s1,0
    8804:	01479793          	slli	a5,a5,0x14
    8808:	01f41413          	slli	s0,s0,0x1f
    880c:	00e7e7b3          	or	a5,a5,a4
    8810:	00c12083          	lw	ra,12(sp)
    8814:	0087e7b3          	or	a5,a5,s0
    8818:	00812403          	lw	s0,8(sp)
    881c:	00048513          	mv	a0,s1
    8820:	00078593          	mv	a1,a5
    8824:	00412483          	lw	s1,4(sp)
    8828:	01010113          	addi	sp,sp,16
    882c:	00008067          	ret
    8830:	ff550513          	addi	a0,a0,-11
    8834:	00a49733          	sll	a4,s1,a0
    8838:	00c71713          	slli	a4,a4,0xc
    883c:	00c75713          	srli	a4,a4,0xc
    8840:	00000493          	li	s1,0
    8844:	fc1ff06f          	j	8804 <__floatsidf+0x74>

00008848 <__floatunsidf>:
    8848:	ff010113          	addi	sp,sp,-16
    884c:	00812423          	sw	s0,8(sp)
    8850:	00112623          	sw	ra,12(sp)
    8854:	00050413          	mv	s0,a0
    8858:	04050c63          	beqz	a0,88b0 <__floatunsidf+0x68>
    885c:	0b0000ef          	jal	890c <__clzsi2>
    8860:	41e00793          	li	a5,1054
    8864:	40a787b3          	sub	a5,a5,a0
    8868:	00a00713          	li	a4,10
    886c:	7ff7f793          	andi	a5,a5,2047
    8870:	06a74463          	blt	a4,a0,88d8 <__floatunsidf+0x90>
    8874:	00b00713          	li	a4,11
    8878:	40a70733          	sub	a4,a4,a0
    887c:	01550513          	addi	a0,a0,21
    8880:	00e45733          	srl	a4,s0,a4
    8884:	00a41433          	sll	s0,s0,a0
    8888:	00c12083          	lw	ra,12(sp)
    888c:	00040513          	mv	a0,s0
    8890:	00c71713          	slli	a4,a4,0xc
    8894:	00812403          	lw	s0,8(sp)
    8898:	00c75713          	srli	a4,a4,0xc
    889c:	01479793          	slli	a5,a5,0x14
    88a0:	00e7e7b3          	or	a5,a5,a4
    88a4:	00078593          	mv	a1,a5
    88a8:	01010113          	addi	sp,sp,16
    88ac:	00008067          	ret
    88b0:	00c12083          	lw	ra,12(sp)
    88b4:	00040513          	mv	a0,s0
    88b8:	00000793          	li	a5,0
    88bc:	00812403          	lw	s0,8(sp)
    88c0:	00000713          	li	a4,0
    88c4:	01479793          	slli	a5,a5,0x14
    88c8:	00e7e7b3          	or	a5,a5,a4
    88cc:	00078593          	mv	a1,a5
    88d0:	01010113          	addi	sp,sp,16
    88d4:	00008067          	ret
    88d8:	ff550513          	addi	a0,a0,-11
    88dc:	00a41733          	sll	a4,s0,a0
    88e0:	00000413          	li	s0,0
    88e4:	00c12083          	lw	ra,12(sp)
    88e8:	00040513          	mv	a0,s0
    88ec:	00c71713          	slli	a4,a4,0xc
    88f0:	00812403          	lw	s0,8(sp)
    88f4:	00c75713          	srli	a4,a4,0xc
    88f8:	01479793          	slli	a5,a5,0x14
    88fc:	00e7e7b3          	or	a5,a5,a4
    8900:	00078593          	mv	a1,a5
    8904:	01010113          	addi	sp,sp,16
    8908:	00008067          	ret

0000890c <__clzsi2>:
    890c:	000107b7          	lui	a5,0x10
    8910:	02f57a63          	bgeu	a0,a5,8944 <__clzsi2+0x38>
    8914:	10053793          	sltiu	a5,a0,256
    8918:	0017b793          	seqz	a5,a5
    891c:	00379793          	slli	a5,a5,0x3
    8920:	02000713          	li	a4,32
    8924:	40f70733          	sub	a4,a4,a5
    8928:	00f55533          	srl	a0,a0,a5
    892c:	00002797          	auipc	a5,0x2
    8930:	59078793          	addi	a5,a5,1424 # aebc <__clz_tab>
    8934:	00a787b3          	add	a5,a5,a0
    8938:	0007c503          	lbu	a0,0(a5)
    893c:	40a70533          	sub	a0,a4,a0
    8940:	00008067          	ret
    8944:	010007b7          	lui	a5,0x1000
    8948:	02f57463          	bgeu	a0,a5,8970 <__clzsi2+0x64>
    894c:	01000793          	li	a5,16
    8950:	00f55533          	srl	a0,a0,a5
    8954:	00002797          	auipc	a5,0x2
    8958:	56878793          	addi	a5,a5,1384 # aebc <__clz_tab>
    895c:	00a787b3          	add	a5,a5,a0
    8960:	0007c503          	lbu	a0,0(a5)
    8964:	01000713          	li	a4,16
    8968:	40a70533          	sub	a0,a4,a0
    896c:	00008067          	ret
    8970:	01800793          	li	a5,24
    8974:	00f55533          	srl	a0,a0,a5
    8978:	00002797          	auipc	a5,0x2
    897c:	54478793          	addi	a5,a5,1348 # aebc <__clz_tab>
    8980:	00a787b3          	add	a5,a5,a0
    8984:	0007c503          	lbu	a0,0(a5)
    8988:	00800713          	li	a4,8
    898c:	40a70533          	sub	a0,a4,a0
    8990:	00008067          	ret
