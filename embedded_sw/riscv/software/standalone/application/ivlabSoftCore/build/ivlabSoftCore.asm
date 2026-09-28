
build/ivlabSoftCore.elf:     file format elf32-littleriscv


Disassembly of section .init:

00001000 <_start>:

_start:
#ifdef USE_GP
.option push
.option norelax
	la gp, __global_pointer$
    1000:	00009197          	auipc	gp,0x9
    1004:	64018193          	addi	gp,gp,1600 # a640 <__global_pointer$>
.global smp_lottery_target
.global smp_lottery_lock
.global smp_slave


  sw x0, smp_lottery_lock, a1
    1008:	f801a023          	sw	zero,-128(gp) # a5c0 <smp_lottery_lock>

0000100c <smp_tyranny>:

smp_tyranny:
  csrr a0, mhartid
    100c:	f1402573          	csrr	a0,mhartid
  beqz a0, init
    1010:	02050e63          	beqz	a0,104c <init>

00001014 <smp_slave>:

smp_slave:
	lw a0, smp_lottery_lock
    1014:	f801a503          	lw	a0,-128(gp) # a5c0 <smp_lottery_lock>
	beqz a0, smp_slave
    1018:	fe050ee3          	beqz	a0,1014 <smp_slave>

	fence r, r
    101c:	0220000f          	fence	r,r
    1020:	0000100f          	.word	0x0000100f
	//li a1, -1
	//amoadd.w x0, a1,(a0)

	.word(0x100F) //i$ flush
	lw a5, smp_lottery_target
    1024:	f7c1a783          	lw	a5,-132(gp) # a5bc <smp_lottery_target>
	li a0, 0
    1028:	00000513          	li	a0,0
	li a1, 0
    102c:	00000593          	li	a1,0
	li a2, 0
    1030:	00000613          	li	a2,0
	jr a5
    1034:	00078067          	jr	a5

00001038 <smp_unlock>:

.global   smp_unlock
.type    smp_unlock,%function
smp_unlock:
	sw a0, smp_lottery_target, a1
    1038:	f6a1ae23          	sw	a0,-132(gp) # a5bc <smp_lottery_target>
	fence w, w
    103c:	0110000f          	fence	w,w
	li a0, 1
    1040:	00100513          	li	a0,1
	sw a0, smp_lottery_lock, a1
    1044:	f8a1a023          	sw	a0,-128(gp) # a5c0 <smp_lottery_lock>
    ret
    1048:	00008067          	ret

0000104c <init>:
#endif

init:
	la sp, _sp
    104c:	0000b117          	auipc	sp,0xb
    1050:	8f410113          	addi	sp,sp,-1804 # b940 <__freertos_irq_stack_top>

	/* Load data section */
	la a0, _data_lma
    1054:	00007517          	auipc	a0,0x7
    1058:	adc50513          	addi	a0,a0,-1316 # 7b30 <_data>
	la a1, _data
    105c:	00007597          	auipc	a1,0x7
    1060:	ad458593          	addi	a1,a1,-1324 # 7b30 <_data>
	la a2, _edata
    1064:	00009617          	auipc	a2,0x9
    1068:	e9060613          	addi	a2,a2,-368 # 9ef4 <__bss_start>
	bgeu a1, a2, 2f
    106c:	00c5fc63          	bgeu	a1,a2,1084 <init+0x38>
1:
	lw t0, (a0)
    1070:	00052283          	lw	t0,0(a0)
	sw t0, (a1)
    1074:	0055a023          	sw	t0,0(a1)
	addi a0, a0, 4
    1078:	00450513          	addi	a0,a0,4
	addi a1, a1, 4
    107c:	00458593          	addi	a1,a1,4
	bltu a1, a2, 1b
    1080:	fec5e8e3          	bltu	a1,a2,1070 <init+0x24>
2:

	/* Clear bss section */
	la a0, __bss_start
    1084:	00009517          	auipc	a0,0x9
    1088:	e7050513          	addi	a0,a0,-400 # 9ef4 <__bss_start>
	la a1, _end
    108c:	0000a597          	auipc	a1,0xa
    1090:	8b458593          	addi	a1,a1,-1868 # a940 <_end>
	bgeu a0, a1, 2f
    1094:	00b57863          	bgeu	a0,a1,10a4 <init+0x58>
1:
	sw zero, (a0)
    1098:	00052023          	sw	zero,0(a0)
	addi a0, a0, 4
    109c:	00450513          	addi	a0,a0,4
	bltu a0, a1, 1b
    10a0:	feb56ce3          	bltu	a0,a1,1098 <init+0x4c>
2:

#ifndef NO_LIBC_INIT_ARRAY
	call __libc_init_array
    10a4:	01c000ef          	jal	10c0 <__libc_init_array>
#endif

	call main
    10a8:	0ac000ef          	jal	1154 <main>

000010ac <mainDone>:
mainDone:
    j mainDone
    10ac:	0000006f          	j	10ac <mainDone>

000010b0 <_init>:


	.globl _init
_init:
    ret
    10b0:	00008067          	ret

Disassembly of section .text:

000010c0 <__libc_init_array>:
    10c0:	ff010113          	addi	sp,sp,-16
    10c4:	00812423          	sw	s0,8(sp)
    10c8:	01212023          	sw	s2,0(sp)
    10cc:	00007797          	auipc	a5,0x7
    10d0:	a6478793          	addi	a5,a5,-1436 # 7b30 <_data>
    10d4:	00007417          	auipc	s0,0x7
    10d8:	a5c40413          	addi	s0,s0,-1444 # 7b30 <_data>
    10dc:	00112623          	sw	ra,12(sp)
    10e0:	00912223          	sw	s1,4(sp)
    10e4:	40878933          	sub	s2,a5,s0
    10e8:	02878063          	beq	a5,s0,1108 <__libc_init_array+0x48>
    10ec:	40295913          	srai	s2,s2,0x2
    10f0:	00000493          	li	s1,0
    10f4:	00042783          	lw	a5,0(s0)
    10f8:	00148493          	addi	s1,s1,1
    10fc:	00440413          	addi	s0,s0,4
    1100:	000780e7          	jalr	a5
    1104:	ff24e8e3          	bltu	s1,s2,10f4 <__libc_init_array+0x34>
    1108:	00007797          	auipc	a5,0x7
    110c:	a2878793          	addi	a5,a5,-1496 # 7b30 <_data>
    1110:	00007417          	auipc	s0,0x7
    1114:	a2040413          	addi	s0,s0,-1504 # 7b30 <_data>
    1118:	40878933          	sub	s2,a5,s0
    111c:	40295913          	srai	s2,s2,0x2
    1120:	00878e63          	beq	a5,s0,113c <__libc_init_array+0x7c>
    1124:	00000493          	li	s1,0
    1128:	00042783          	lw	a5,0(s0)
    112c:	00148493          	addi	s1,s1,1
    1130:	00440413          	addi	s0,s0,4
    1134:	000780e7          	jalr	a5
    1138:	ff24e8e3          	bltu	s1,s2,1128 <__libc_init_array+0x68>
    113c:	00c12083          	lw	ra,12(sp)
    1140:	00812403          	lw	s0,8(sp)
    1144:	00412483          	lw	s1,4(sp)
    1148:	00012903          	lw	s2,0(sp)
    114c:	01010113          	addi	sp,sp,16
    1150:	00008067          	ret

00001154 <main>:
*         proto_uart_init()  配置 uart1 和它的中断源
*         isr_init()      最后才打开中断总开关
*       把 isr_init() 放在最后是关键的：如果先开中断再配 uart1，
*       中间那个窗口里进来的中断会找不到正确的处理路径。
******************************************************************************/
void main() {
    1154:	fd010113          	addi	sp,sp,-48
    1158:	02112623          	sw	ra,44(sp)
    bsp_init();                 /* BSP 的通用初始化，其中包含 uart0 的配置 */
    115c:	320020ef          	jal	347c <bsp_init>
    app_log_init();
    1160:	03c020ef          	jal	319c <app_log_init>
    frame_parser_init(&s_parser);
    1164:	d4c18513          	addi	a0,gp,-692 # a38c <s_parser>
    1168:	710020ef          	jal	3878 <frame_parser_init>
    protocol_init(&s_stats);
    116c:	d4018513          	addi	a0,gp,-704 # a380 <s_stats>
    1170:	028030ef          	jal	4198 <protocol_init>
    /* 引擎初始化会清两块画布、渲染并提交第一屏，所以上电即有菜单。
     * 它排在 isr_init() 之前：这期间要写几千次 AXI，中断还没开就不会有
     * 字节挤在接收环里等 —— 虽然不会丢，但没必要留这个尾巴。*/
    osd_engine_boot();
    1174:	4c8030ef          	jal	463c <osd_engine_boot>

    /* 启动横幅。这几行主要是给现场确认"固件确实跑起来了"用的。
     * 把协议出处一并打出来：这条串口线上跑着好几个功能模块的帧，出问题时
     * 第一件要确认的就是"两端说的是不是同一代协议"。*/
    app_log("*** ivlabSoftCore ***");
    1178:	00008537          	lui	a0,0x8
    117c:	cf850513          	addi	a0,a0,-776 # 7cf8 <_data+0x1c8>
    1180:	11c020ef          	jal	329c <app_log>
    app_log("debug channel: semihosting (JTAG)");
    1184:	00008537          	lui	a0,0x8
    1188:	d1050513          	addi	a0,a0,-752 # 7d10 <_data+0x1e0>
    118c:	110020ef          	jal	329c <app_log>
    app_log("protocol: BB frame, categories 0x00 (mask) + 0x04 (UI)");
    1190:	00008537          	lui	a0,0x8
    1194:	d3450513          	addi	a0,a0,-716 # 7d34 <_data+0x204>
    1198:	104020ef          	jal	329c <app_log>
    app_log("osd: menu on OSD1 544x208 1bpp, canvas A/B = 0x%x / 0x%x",
    119c:	00b40637          	lui	a2,0xb40
    11a0:	00a405b7          	lui	a1,0xa40
    11a4:	00008537          	lui	a0,0x8
    11a8:	d6c50513          	addi	a0,a0,-660 # 7d6c <_data+0x23c>
    11ac:	0f0020ef          	jal	329c <app_log>

    /* 协议端点可用与否，取决于 SoC 是否生成了 uart1（见 proto_uart.h）。
     * 这里把结果明确打出来：一是让现场知道协议能不能用，二是它的 base 地址
     * 可以和 RTL 侧的 rtl_mask_mode 取值交叉核对，确认"只有一个端点在应答"。*/
    if (PROTO_ENDPOINT_AVAILABLE) {
        proto_uart_init();
    11b0:	2a9020ef          	jal	3c58 <proto_uart_init>
        isr_init();
    11b4:	338020ef          	jal	34ec <isr_init>
        app_log("protocol endpoint: ENABLED on uart1 (base 0x%x)",
    11b8:	f80025b7          	lui	a1,0xf8002
    11bc:	00008537          	lui	a0,0x8
    11c0:	da850513          	addi	a0,a0,-600 # 7da8 <_data+0x278>
    11c4:	0d8020ef          	jal	329c <app_log>
    11c8:	0340006f          	j	11fc <main+0xa8>
         * 这样做的代价是日志不再"实时"——但换来的是协议本身可靠，而且那批
         * 日志会在结束后的 200 ms 内完整出现，排查并不受影响。
         *
         * 另外注意：**画布渲染不在这个循环里**，它随命令在 osd_engine_handle()
         * 里同步完成。所以"线路静默"这条门槛只推迟日志、不推迟画面。*/
        if ((app_log_pending() != 0U) || (s_frames_processed != s_reported_frames)) {
    11cc:	7e5010ef          	jal	31b0 <app_log_pending>
    11d0:	00051863          	bnez	a0,11e0 <main+0x8c>
    11d4:	8f41a703          	lw	a4,-1804(gp) # 9f34 <s_frames_processed>
    11d8:	8d41a783          	lw	a5,-1836(gp) # 9f14 <s_reported_frames>
    11dc:	02f70063          	beq	a4,a5,11fc <main+0xa8>
            /* 读 CLINT 时间是 3 次 MMIO，不能每轮都做；用计数器粗降频。*/
            s_idle_spins++;
    11e0:	8d01a783          	lw	a5,-1840(gp) # 9f10 <s_idle_spins>
    11e4:	00178793          	addi	a5,a5,1
    11e8:	8cf1a823          	sw	a5,-1840(gp) # 9f10 <s_idle_spins>
            if ((s_idle_spins & (IDLE_TICKS_DIVIDER - 1U)) == 0U) {
    11ec:	00001737          	lui	a4,0x1
    11f0:	fff70713          	addi	a4,a4,-1 # fff <CUSTOM2+0xfa4>
    11f4:	00e7f7b3          	and	a5,a5,a4
    11f8:	04078063          	beqz	a5,1238 <main+0xe4>
        while (proto_uart_rx_pop(&byte)) {
    11fc:	00710513          	addi	a0,sp,7
    1200:	2ed020ef          	jal	3cec <proto_uart_rx_pop>
    1204:	fc0504e3          	beqz	a0,11cc <main+0x78>
            s_last_rx_ticks = clint_getTime(BSP_CLINT);
    1208:	f8b00537          	lui	a0,0xf8b00
    120c:	240020ef          	jal	344c <clint_getTime>
    1210:	8ca1ac23          	sw	a0,-1832(gp) # 9f18 <s_last_rx_ticks>
    1214:	8cb1ae23          	sw	a1,-1828(gp) # 9f1c <s_last_rx_ticks+0x4>
            if (frame_parser_feed(&s_parser, byte, &frame) != 0) {
    1218:	00810613          	addi	a2,sp,8
    121c:	00714583          	lbu	a1,7(sp)
    1220:	d4c18513          	addi	a0,gp,-692 # a38c <s_parser>
    1224:	6a8020ef          	jal	38cc <frame_parser_feed>
    1228:	fc050ae3          	beqz	a0,11fc <main+0xa8>
                handle_frame(&frame);
    122c:	00810513          	addi	a0,sp,8
    1230:	4a8020ef          	jal	36d8 <handle_frame>
    1234:	fc9ff06f          	j	11fc <main+0xa8>
                if ((clint_getTime(BSP_CLINT) - s_last_rx_ticks) >= APP_LOG_IDLE_TICKS) {
    1238:	f8b00537          	lui	a0,0xf8b00
    123c:	210020ef          	jal	344c <clint_getTime>
    1240:	8d81a783          	lw	a5,-1832(gp) # 9f18 <s_last_rx_ticks>
    1244:	8dc1a703          	lw	a4,-1828(gp) # 9f1c <s_last_rx_ticks+0x4>
    1248:	40f507b3          	sub	a5,a0,a5
    124c:	00f53533          	sltu	a0,a0,a5
    1250:	40e585b3          	sub	a1,a1,a4
    1254:	40a58733          	sub	a4,a1,a0
    1258:	00a59a63          	bne	a1,a0,126c <main+0x118>
    125c:	fa0710e3          	bnez	a4,11fc <main+0xa8>
    1260:	00989737          	lui	a4,0x989
    1264:	67f70713          	addi	a4,a4,1663 # 98967f <__freertos_irq_stack_top+0x97dd3f>
    1268:	f8f77ae3          	bgeu	a4,a5,11fc <main+0xa8>
                    /* 线路静默够久，说明这一批数据结束了。先补一条汇总，
                     * 保证"这一批收了多少、丢了多少"一定可见——短跑批够不到
                     * STATS_INTERVAL，没有这一条就什么都看不到。*/
                    if (s_frames_processed != s_reported_frames) {
    126c:	8f41a703          	lw	a4,-1804(gp) # 9f34 <s_frames_processed>
    1270:	8d41a783          	lw	a5,-1836(gp) # 9f14 <s_reported_frames>
    1274:	00f71663          	bne	a4,a5,1280 <main+0x12c>
                        log_stats();
                    }
                    (void)app_log_flush();
    1278:	0c8020ef          	jal	3340 <app_log_flush>
    while (1) {
    127c:	f81ff06f          	j	11fc <main+0xa8>
                        log_stats();
    1280:	3a0020ef          	jal	3620 <log_stats>
    1284:	ff5ff06f          	j	1278 <main+0x124>
	...

00001290 <sh_write0>:
* @note    None.
*
******************************************************************************/

static void sh_write0(char* buf)
{
    1290:	00050593          	mv	a1,a0
    register int value asm ("a0") = reason;
    1294:	00400513          	li	a0,4
    register void* ptr asm ("a1") = arg;
    1298:	00000013          	nop
    129c:	00000013          	nop
    asm volatile (
    12a0:	01f01013          	slli	zero,zero,0x1f
    12a4:	00100073          	ebreak
    12a8:	40705013          	srai	zero,zero,0x7
    12ac:	00000013          	nop
    // Print zero-terminated string
    call_host(SEMIHOSTING_SYS_WRITE0, (void*) buf);
}
    12b0:	00008067          	ret
    12b4:	00000013          	nop
    12b8:	00000013          	nop

000012bc <_putchar_s>:
            bsp_putChar(character);
        #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }

    static void _putchar_s(char *p)
    {
    12bc:	ff010113          	addi	sp,sp,-16
    12c0:	00112623          	sw	ra,12(sp)
    #if (ENABLE_SEMIHOSTING_PRINT == 1)
        sh_write0(p);
    12c4:	fcdff0ef          	jal	1290 <sh_write0>
    #else
        while (*p)
            _putchar(*(p++));
    #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }
    12c8:	00c12083          	lw	ra,12(sp)
    12cc:	01010113          	addi	sp,sp,16
    12d0:	00008067          	ret

000012d4 <_out_buffer>:
*
******************************************************************************/

static inline void _out_buffer(char character, void* buffer, size_t idx, size_t maxlen)
{
  if (idx < maxlen) {
    12d4:	00d67663          	bgeu	a2,a3,12e0 <_out_buffer+0xc>
    ((char*)buffer)[idx] = character;
    12d8:	00c585b3          	add	a1,a1,a2
    12dc:	00a58023          	sb	a0,0(a1) # f8002000 <__freertos_irq_stack_top+0xf7ff66c0>
  }
}
    12e0:	00008067          	ret

000012e4 <_out_null>:
*
******************************************************************************/
static inline void _out_null(char character, void* buffer, size_t idx, size_t maxlen)
{
  (void)character; (void)buffer; (void)idx; (void)maxlen;
}
    12e4:	00008067          	ret

000012e8 <_atoi>:
*
* @return Converted unsigned integer value.
*
******************************************************************************/
static unsigned int _atoi(const char** str)
{
    12e8:	00050693          	mv	a3,a0
  unsigned int i = 0U;
    12ec:	00000513          	li	a0,0
  while (_is_digit(**str)) {
    12f0:	0240006f          	j	1314 <_atoi+0x2c>
    i = i * 10U + (unsigned int)(*((*str)++) - '0');
    12f4:	00251793          	slli	a5,a0,0x2
    12f8:	00a787b3          	add	a5,a5,a0
    12fc:	00179793          	slli	a5,a5,0x1
    1300:	00170613          	addi	a2,a4,1
    1304:	00c6a023          	sw	a2,0(a3)
    1308:	00074503          	lbu	a0,0(a4)
    130c:	00f50533          	add	a0,a0,a5
    1310:	fd050513          	addi	a0,a0,-48 # f8afffd0 <__freertos_irq_stack_top+0xf8af4690>
  while (_is_digit(**str)) {
    1314:	0006a703          	lw	a4,0(a3)
    1318:	00074783          	lbu	a5,0(a4)
  return (ch >= '0') && (ch <= '9');
    131c:	fd078793          	addi	a5,a5,-48
    1320:	0ff7f793          	zext.b	a5,a5
  while (_is_digit(**str)) {
    1324:	00900613          	li	a2,9
    1328:	fcf676e3          	bgeu	a2,a5,12f4 <_atoi+0xc>
  }
  return i;
}
    132c:	00008067          	ret

00001330 <_out_rev>:
*
* @return Updated index in the buffer after outputting the string.
*
******************************************************************************/
static size_t _out_rev(out_fct_type out, char* buffer, size_t idx, size_t maxlen, const char* buf, size_t len, unsigned int width, unsigned int flags)
{
    1330:	fd010113          	addi	sp,sp,-48
    1334:	02112623          	sw	ra,44(sp)
    1338:	02812423          	sw	s0,40(sp)
    133c:	02912223          	sw	s1,36(sp)
    1340:	03212023          	sw	s2,32(sp)
    1344:	01312e23          	sw	s3,28(sp)
    1348:	01412c23          	sw	s4,24(sp)
    134c:	01512a23          	sw	s5,20(sp)
    1350:	01612823          	sw	s6,16(sp)
    1354:	01712623          	sw	s7,12(sp)
    1358:	01812423          	sw	s8,8(sp)
    135c:	00050493          	mv	s1,a0
    1360:	00058913          	mv	s2,a1
    1364:	00060b93          	mv	s7,a2
    1368:	00068993          	mv	s3,a3
    136c:	00070b13          	mv	s6,a4
    1370:	00078413          	mv	s0,a5
    1374:	00080a93          	mv	s5,a6
    1378:	00088c13          	mv	s8,a7
  const size_t start_idx = idx;

  // pad spaces up to given width
  if (!(flags & FLAGS_LEFT) && !(flags & FLAGS_ZEROPAD)) {
    137c:	0038f793          	andi	a5,a7,3
    1380:	04079c63          	bnez	a5,13d8 <_out_rev+0xa8>
    1384:	01912223          	sw	s9,4(sp)
    for (size_t i = len; i < width; i++) {
    1388:	00040a13          	mv	s4,s0
    138c:	035a7263          	bgeu	s4,s5,13b0 <_out_rev+0x80>
      out(' ', buffer, idx++, maxlen);
    1390:	00160c93          	addi	s9,a2,1 # b40001 <__freertos_irq_stack_top+0xb346c1>
    1394:	00098693          	mv	a3,s3
    1398:	00090593          	mv	a1,s2
    139c:	02000513          	li	a0,32
    13a0:	000480e7          	jalr	s1
    for (size_t i = len; i < width; i++) {
    13a4:	001a0a13          	addi	s4,s4,1
      out(' ', buffer, idx++, maxlen);
    13a8:	000c8613          	mv	a2,s9
    13ac:	fe1ff06f          	j	138c <_out_rev+0x5c>
    13b0:	00412c83          	lw	s9,4(sp)
    13b4:	0240006f          	j	13d8 <_out_rev+0xa8>
    }
  }

  // reverse string
  while (len) {
    out(buf[--len], buffer, idx++, maxlen);
    13b8:	fff40413          	addi	s0,s0,-1
    13bc:	008b07b3          	add	a5,s6,s0
    13c0:	00160a13          	addi	s4,a2,1
    13c4:	00098693          	mv	a3,s3
    13c8:	00090593          	mv	a1,s2
    13cc:	0007c503          	lbu	a0,0(a5)
    13d0:	000480e7          	jalr	s1
    13d4:	000a0613          	mv	a2,s4
  while (len) {
    13d8:	fe0410e3          	bnez	s0,13b8 <_out_rev+0x88>
  }

  // append pad spaces up to given width
  if (flags & FLAGS_LEFT) {
    13dc:	002c7c13          	andi	s8,s8,2
    13e0:	020c1c63          	bnez	s8,1418 <_out_rev+0xe8>
      out(' ', buffer, idx++, maxlen);
    }
  }

  return idx;
}
    13e4:	00060513          	mv	a0,a2
    13e8:	02c12083          	lw	ra,44(sp)
    13ec:	02812403          	lw	s0,40(sp)
    13f0:	02412483          	lw	s1,36(sp)
    13f4:	02012903          	lw	s2,32(sp)
    13f8:	01c12983          	lw	s3,28(sp)
    13fc:	01812a03          	lw	s4,24(sp)
    1400:	01412a83          	lw	s5,20(sp)
    1404:	01012b03          	lw	s6,16(sp)
    1408:	00c12b83          	lw	s7,12(sp)
    140c:	00812c03          	lw	s8,8(sp)
    1410:	03010113          	addi	sp,sp,48
    1414:	00008067          	ret
    while (idx - start_idx < width) {
    1418:	417607b3          	sub	a5,a2,s7
    141c:	fd57f4e3          	bgeu	a5,s5,13e4 <_out_rev+0xb4>
      out(' ', buffer, idx++, maxlen);
    1420:	00160413          	addi	s0,a2,1
    1424:	00098693          	mv	a3,s3
    1428:	00090593          	mv	a1,s2
    142c:	02000513          	li	a0,32
    1430:	000480e7          	jalr	s1
    1434:	00040613          	mv	a2,s0
    1438:	fe1ff06f          	j	1418 <_out_rev+0xe8>

0000143c <_ntoa_format>:
*
* @return Number of characters written to the buffer.
*
******************************************************************************/
static size_t _ntoa_format(out_fct_type out, char* buffer, size_t idx, size_t maxlen, char* buf, size_t len, bool negative, unsigned int base, unsigned int prec, unsigned int width, unsigned int flags)
{
    143c:	ff010113          	addi	sp,sp,-16
    1440:	00112623          	sw	ra,12(sp)
    1444:	00080f93          	mv	t6,a6
    1448:	00088f13          	mv	t5,a7
    144c:	01012e83          	lw	t4,16(sp)
    1450:	01412803          	lw	a6,20(sp)
    1454:	01812883          	lw	a7,24(sp)
  // pad leading zeros
  if (!(flags & FLAGS_LEFT)) {
    1458:	0028f313          	andi	t1,a7,2
    145c:	06031463          	bnez	t1,14c4 <_ntoa_format+0x88>
    if (width && (flags & FLAGS_ZEROPAD) && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
    1460:	02080863          	beqz	a6,1490 <_ntoa_format+0x54>
    1464:	0018f313          	andi	t1,a7,1
    1468:	02030463          	beqz	t1,1490 <_ntoa_format+0x54>
    146c:	000f9663          	bnez	t6,1478 <_ntoa_format+0x3c>
    1470:	00c8f313          	andi	t1,a7,12
    1474:	00030e63          	beqz	t1,1490 <_ntoa_format+0x54>
      width--;
    1478:	fff80813          	addi	a6,a6,-1
    147c:	0140006f          	j	1490 <_ntoa_format+0x54>
    }
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = '0';
    1480:	00f70333          	add	t1,a4,a5
    1484:	03000e13          	li	t3,48
    1488:	01c30023          	sb	t3,0(t1)
    148c:	00178793          	addi	a5,a5,1
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1490:	01d7f663          	bgeu	a5,t4,149c <_ntoa_format+0x60>
    1494:	01f00313          	li	t1,31
    1498:	fef374e3          	bgeu	t1,a5,1480 <_ntoa_format+0x44>
    }
    while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    149c:	0018f313          	andi	t1,a7,1
    14a0:	02030263          	beqz	t1,14c4 <_ntoa_format+0x88>
    14a4:	0307f063          	bgeu	a5,a6,14c4 <_ntoa_format+0x88>
    14a8:	01f00313          	li	t1,31
    14ac:	00f36c63          	bltu	t1,a5,14c4 <_ntoa_format+0x88>
      buf[len++] = '0';
    14b0:	00f70333          	add	t1,a4,a5
    14b4:	03000e13          	li	t3,48
    14b8:	01c30023          	sb	t3,0(t1)
    14bc:	00178793          	addi	a5,a5,1
    14c0:	fddff06f          	j	149c <_ntoa_format+0x60>
    }
  }

  // handle hash
  if (flags & FLAGS_HASH) {
    14c4:	0108f313          	andi	t1,a7,16
    14c8:	04030063          	beqz	t1,1508 <_ntoa_format+0xcc>
    if (!(flags & FLAGS_PRECISION) && len && ((len == prec) || (len == width))) {
    14cc:	4008f313          	andi	t1,a7,1024
    14d0:	00031863          	bnez	t1,14e0 <_ntoa_format+0xa4>
    14d4:	00078663          	beqz	a5,14e0 <_ntoa_format+0xa4>
    14d8:	05d78e63          	beq	a5,t4,1534 <_ntoa_format+0xf8>
    14dc:	05078c63          	beq	a5,a6,1534 <_ntoa_format+0xf8>
      len--;
      if (len && (base == 16U)) {
        len--;
      }
    }
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    14e0:	01000313          	li	t1,16
    14e4:	0a6f0063          	beq	t5,t1,1584 <_ntoa_format+0x148>
      buf[len++] = 'x';
    }
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = 'X';
    }
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    14e8:	00200313          	li	t1,2
    14ec:	0a6f0e63          	beq	t5,t1,15a8 <_ntoa_format+0x16c>
      buf[len++] = 'b';
    }
    if (len < PRINTF_NTOA_BUFFER_SIZE) {
    14f0:	01f00313          	li	t1,31
    14f4:	02f36863          	bltu	t1,a5,1524 <_ntoa_format+0xe8>
      buf[len++] = '0';
    14f8:	00f70333          	add	t1,a4,a5
    14fc:	03000e13          	li	t3,48
    1500:	01c30023          	sb	t3,0(t1)
    1504:	00178793          	addi	a5,a5,1
    }
  }

  if (len < PRINTF_NTOA_BUFFER_SIZE) {
    1508:	01f00313          	li	t1,31
    150c:	00f36c63          	bltu	t1,a5,1524 <_ntoa_format+0xe8>
    if (negative) {
    1510:	0a0f8a63          	beqz	t6,15c4 <_ntoa_format+0x188>
      buf[len++] = '-';
    1514:	00f70333          	add	t1,a4,a5
    1518:	02d00e13          	li	t3,45
    151c:	01c30023          	sb	t3,0(t1)
    1520:	00178793          	addi	a5,a5,1
    else if (flags & FLAGS_SPACE) {
      buf[len++] = ' ';
    }
  }

  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
    1524:	e0dff0ef          	jal	1330 <_out_rev>
}
    1528:	00c12083          	lw	ra,12(sp)
    152c:	01010113          	addi	sp,sp,16
    1530:	00008067          	ret
      len--;
    1534:	fff78313          	addi	t1,a5,-1
      if (len && (base == 16U)) {
    1538:	04030263          	beqz	t1,157c <_ntoa_format+0x140>
    153c:	01000e13          	li	t3,16
    1540:	03cf0a63          	beq	t5,t3,1574 <_ntoa_format+0x138>
      len--;
    1544:	00030793          	mv	a5,t1
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1548:	01000313          	li	t1,16
    154c:	f86f1ee3          	bne	t5,t1,14e8 <_ntoa_format+0xac>
    1550:	0208f313          	andi	t1,a7,32
    1554:	f8030ae3          	beqz	t1,14e8 <_ntoa_format+0xac>
    1558:	01f00313          	li	t1,31
    155c:	f8f366e3          	bltu	t1,a5,14e8 <_ntoa_format+0xac>
      buf[len++] = 'X';
    1560:	00f70333          	add	t1,a4,a5
    1564:	05800e13          	li	t3,88
    1568:	01c30023          	sb	t3,0(t1)
    156c:	00178793          	addi	a5,a5,1
    1570:	f81ff06f          	j	14f0 <_ntoa_format+0xb4>
        len--;
    1574:	ffe78793          	addi	a5,a5,-2
    1578:	f69ff06f          	j	14e0 <_ntoa_format+0xa4>
      len--;
    157c:	00030793          	mv	a5,t1
    1580:	f61ff06f          	j	14e0 <_ntoa_format+0xa4>
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1584:	0208f313          	andi	t1,a7,32
    1588:	fc0310e3          	bnez	t1,1548 <_ntoa_format+0x10c>
    158c:	01f00313          	li	t1,31
    1590:	faf36ce3          	bltu	t1,a5,1548 <_ntoa_format+0x10c>
      buf[len++] = 'x';
    1594:	00f70333          	add	t1,a4,a5
    1598:	07800e13          	li	t3,120
    159c:	01c30023          	sb	t3,0(t1)
    15a0:	00178793          	addi	a5,a5,1
    15a4:	f4dff06f          	j	14f0 <_ntoa_format+0xb4>
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    15a8:	01f00313          	li	t1,31
    15ac:	f6f36ce3          	bltu	t1,a5,1524 <_ntoa_format+0xe8>
      buf[len++] = 'b';
    15b0:	00f70333          	add	t1,a4,a5
    15b4:	06200e13          	li	t3,98
    15b8:	01c30023          	sb	t3,0(t1)
    15bc:	00178793          	addi	a5,a5,1
    15c0:	f31ff06f          	j	14f0 <_ntoa_format+0xb4>
    else if (flags & FLAGS_PLUS) {
    15c4:	0048f313          	andi	t1,a7,4
    15c8:	00030c63          	beqz	t1,15e0 <_ntoa_format+0x1a4>
      buf[len++] = '+';  // ignore the space if the '+' exists
    15cc:	00f70333          	add	t1,a4,a5
    15d0:	02b00e13          	li	t3,43
    15d4:	01c30023          	sb	t3,0(t1)
    15d8:	00178793          	addi	a5,a5,1
    15dc:	f49ff06f          	j	1524 <_ntoa_format+0xe8>
    else if (flags & FLAGS_SPACE) {
    15e0:	0088f313          	andi	t1,a7,8
    15e4:	f40300e3          	beqz	t1,1524 <_ntoa_format+0xe8>
      buf[len++] = ' ';
    15e8:	00f70333          	add	t1,a4,a5
    15ec:	02000e13          	li	t3,32
    15f0:	01c30023          	sb	t3,0(t1)
    15f4:	00178793          	addi	a5,a5,1
    15f8:	f2dff06f          	j	1524 <_ntoa_format+0xe8>

000015fc <_ntoa_long>:
* @return Number of characters written to the buffer.
*
*
******************************************************************************/
static size_t _ntoa_long(out_fct_type out, char* buffer, size_t idx, size_t maxlen, unsigned long value, bool negative, unsigned long base, unsigned int prec, unsigned int width, unsigned int flags)
{
    15fc:	fc010113          	addi	sp,sp,-64
    1600:	02112e23          	sw	ra,60(sp)
    1604:	00078f93          	mv	t6,a5
    1608:	04412f03          	lw	t5,68(sp)
  char buf[PRINTF_NTOA_BUFFER_SIZE];
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
    160c:	00071463          	bnez	a4,1614 <_ntoa_long+0x18>
    flags &= ~FLAGS_HASH;
    1610:	feff7f13          	andi	t5,t5,-17
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
    1614:	400f7e93          	andi	t4,t5,1024
    1618:	040e8063          	beqz	t4,1658 <_ntoa_long+0x5c>
    161c:	06070a63          	beqz	a4,1690 <_ntoa_long+0x94>
    1620:	00000e93          	li	t4,0
    1624:	0340006f          	j	1658 <_ntoa_long+0x5c>
    do {
      const char digit = (char)(value % base);
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1628:	030e0e13          	addi	t3,t3,48
    162c:	0ffe7313          	zext.b	t1,t3
    1630:	001e8793          	addi	a5,t4,1
    1634:	030e8e13          	addi	t3,t4,48
    1638:	002e0eb3          	add	t4,t3,sp
    163c:	fe6e8023          	sb	t1,-32(t4)
      value /= base;
    1640:	03075333          	divu	t1,a4,a6
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    1644:	05076863          	bltu	a4,a6,1694 <_ntoa_long+0x98>
    1648:	01f00713          	li	a4,31
    164c:	04f76463          	bltu	a4,a5,1694 <_ntoa_long+0x98>
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1650:	00078e93          	mv	t4,a5
      value /= base;
    1654:	00030713          	mv	a4,t1
      const char digit = (char)(value % base);
    1658:	03077e33          	remu	t3,a4,a6
    165c:	0ffe7e13          	zext.b	t3,t3
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1660:	00900313          	li	t1,9
    1664:	fdc372e3          	bgeu	t1,t3,1628 <_ntoa_long+0x2c>
    1668:	020f7313          	andi	t1,t5,32
    166c:	00030e63          	beqz	t1,1688 <_ntoa_long+0x8c>
    1670:	04100313          	li	t1,65
    1674:	01c30333          	add	t1,t1,t3
    1678:	0ff37313          	zext.b	t1,t1
    167c:	ff630313          	addi	t1,t1,-10
    1680:	0ff37313          	zext.b	t1,t1
    1684:	fadff06f          	j	1630 <_ntoa_long+0x34>
    1688:	06100313          	li	t1,97
    168c:	fe9ff06f          	j	1674 <_ntoa_long+0x78>
  size_t len = 0U;
    1690:	00070793          	mv	a5,a4
  }

  return _ntoa_format(out, buffer, idx, maxlen, buf, len, negative, (unsigned int)base, prec, width, flags);
    1694:	01e12423          	sw	t5,8(sp)
    1698:	04012703          	lw	a4,64(sp)
    169c:	00e12223          	sw	a4,4(sp)
    16a0:	01112023          	sw	a7,0(sp)
    16a4:	00080893          	mv	a7,a6
    16a8:	000f8813          	mv	a6,t6
    16ac:	01010713          	addi	a4,sp,16
    16b0:	d8dff0ef          	jal	143c <_ntoa_format>
}
    16b4:	03c12083          	lw	ra,60(sp)
    16b8:	04010113          	addi	sp,sp,64
    16bc:	00008067          	ret

000016c0 <_ntoa_long_long>:
*
* @return Number of characters written to the buffer.
*
******************************************************************************/
static size_t _ntoa_long_long(out_fct_type out, char* buffer, size_t idx, size_t maxlen, unsigned long long value, bool negative, unsigned long long base, unsigned int prec, unsigned int width, unsigned int flags)
{
    16c0:	f8010113          	addi	sp,sp,-128
    16c4:	06112623          	sw	ra,108(sp)
    16c8:	06812423          	sw	s0,104(sp)
    16cc:	06912223          	sw	s1,100(sp)
    16d0:	07212023          	sw	s2,96(sp)
    16d4:	05312e23          	sw	s3,92(sp)
    16d8:	05412c23          	sw	s4,88(sp)
    16dc:	05512a23          	sw	s5,84(sp)
    16e0:	05612823          	sw	s6,80(sp)
    16e4:	05712623          	sw	s7,76(sp)
    16e8:	05812423          	sw	s8,72(sp)
    16ec:	05912223          	sw	s9,68(sp)
    16f0:	05a12023          	sw	s10,64(sp)
    16f4:	03b12e23          	sw	s11,60(sp)
    16f8:	00050b93          	mv	s7,a0
    16fc:	00058c13          	mv	s8,a1
    1700:	00060c93          	mv	s9,a2
    1704:	00068d13          	mv	s10,a3
    1708:	00070993          	mv	s3,a4
    170c:	00078413          	mv	s0,a5
    1710:	00080d93          	mv	s11,a6
    1714:	07112e23          	sw	a7,124(sp)
    1718:	00088a93          	mv	s5,a7
    171c:	08012903          	lw	s2,128(sp)
    1720:	08c12b03          	lw	s6,140(sp)
  char buf[PRINTF_NTOA_BUFFER_SIZE];
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
    1724:	00f767b3          	or	a5,a4,a5
    1728:	00079463          	bnez	a5,1730 <_ntoa_long_long+0x70>
    flags &= ~FLAGS_HASH;
    172c:	fefb7b13          	andi	s6,s6,-17
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
    1730:	400b7493          	andi	s1,s6,1024
    1734:	04048e63          	beqz	s1,1790 <_ntoa_long_long+0xd0>
    1738:	0089e7b3          	or	a5,s3,s0
    173c:	0a078263          	beqz	a5,17e0 <_ntoa_long_long+0x120>
    1740:	00000493          	li	s1,0
    1744:	04c0006f          	j	1790 <_ntoa_long_long+0xd0>
    do {
      const char digit = (char)(value % base);
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1748:	03050513          	addi	a0,a0,48
    174c:	0ff57793          	zext.b	a5,a0
    1750:	00148a13          	addi	s4,s1,1
    1754:	03048713          	addi	a4,s1,48
    1758:	002704b3          	add	s1,a4,sp
    175c:	fef48023          	sb	a5,-32(s1)
      value /= base;
    1760:	000a8613          	mv	a2,s5
    1764:	00090693          	mv	a3,s2
    1768:	00098513          	mv	a0,s3
    176c:	00040593          	mv	a1,s0
    1770:	4d8030ef          	jal	4c48 <__udivdi3>
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    1774:	07246863          	bltu	s0,s2,17e4 <_ntoa_long_long+0x124>
    1778:	06890063          	beq	s2,s0,17d8 <_ntoa_long_long+0x118>
    177c:	01f00793          	li	a5,31
    1780:	0747e263          	bltu	a5,s4,17e4 <_ntoa_long_long+0x124>
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1784:	000a0493          	mv	s1,s4
      value /= base;
    1788:	00050993          	mv	s3,a0
    178c:	00058413          	mv	s0,a1
      const char digit = (char)(value % base);
    1790:	000a8613          	mv	a2,s5
    1794:	00090693          	mv	a3,s2
    1798:	00098513          	mv	a0,s3
    179c:	00040593          	mv	a1,s0
    17a0:	159030ef          	jal	50f8 <__umoddi3>
    17a4:	0ff57513          	zext.b	a0,a0
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    17a8:	00900793          	li	a5,9
    17ac:	f8a7fee3          	bgeu	a5,a0,1748 <_ntoa_long_long+0x88>
    17b0:	020b7793          	andi	a5,s6,32
    17b4:	00078e63          	beqz	a5,17d0 <_ntoa_long_long+0x110>
    17b8:	04100793          	li	a5,65
    17bc:	00a787b3          	add	a5,a5,a0
    17c0:	0ff7f793          	zext.b	a5,a5
    17c4:	ff678793          	addi	a5,a5,-10
    17c8:	0ff7f793          	zext.b	a5,a5
    17cc:	f85ff06f          	j	1750 <_ntoa_long_long+0x90>
    17d0:	06100793          	li	a5,97
    17d4:	fe9ff06f          	j	17bc <_ntoa_long_long+0xfc>
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    17d8:	fb59f2e3          	bgeu	s3,s5,177c <_ntoa_long_long+0xbc>
    17dc:	0080006f          	j	17e4 <_ntoa_long_long+0x124>
  size_t len = 0U;
    17e0:	00000a13          	li	s4,0
  }

  return _ntoa_format(out, buffer, idx, maxlen, buf, len, negative, (unsigned int)base, prec, width, flags);
    17e4:	01612423          	sw	s6,8(sp)
    17e8:	08812783          	lw	a5,136(sp)
    17ec:	00f12223          	sw	a5,4(sp)
    17f0:	08412783          	lw	a5,132(sp)
    17f4:	00f12023          	sw	a5,0(sp)
    17f8:	000a8893          	mv	a7,s5
    17fc:	000d8813          	mv	a6,s11
    1800:	000a0793          	mv	a5,s4
    1804:	01010713          	addi	a4,sp,16
    1808:	000d0693          	mv	a3,s10
    180c:	000c8613          	mv	a2,s9
    1810:	000c0593          	mv	a1,s8
    1814:	000b8513          	mv	a0,s7
    1818:	c25ff0ef          	jal	143c <_ntoa_format>
}
    181c:	06c12083          	lw	ra,108(sp)
    1820:	06812403          	lw	s0,104(sp)
    1824:	06412483          	lw	s1,100(sp)
    1828:	06012903          	lw	s2,96(sp)
    182c:	05c12983          	lw	s3,92(sp)
    1830:	05812a03          	lw	s4,88(sp)
    1834:	05412a83          	lw	s5,84(sp)
    1838:	05012b03          	lw	s6,80(sp)
    183c:	04c12b83          	lw	s7,76(sp)
    1840:	04812c03          	lw	s8,72(sp)
    1844:	04412c83          	lw	s9,68(sp)
    1848:	04012d03          	lw	s10,64(sp)
    184c:	03c12d83          	lw	s11,60(sp)
    1850:	08010113          	addi	sp,sp,128
    1854:	00008067          	ret

00001858 <_etoa>:
*
* @note           Contributed by: Martijn Jasperse <m.jasperse@gmail.com>
*
******************************************************************************/
static size_t _etoa(out_fct_type out, char* buffer, size_t idx, size_t maxlen, double value, unsigned int prec, unsigned int width, unsigned int flags)
{
    1858:	f9010113          	addi	sp,sp,-112
    185c:	06112623          	sw	ra,108(sp)
    1860:	06812423          	sw	s0,104(sp)
    1864:	06912223          	sw	s1,100(sp)
    1868:	07212023          	sw	s2,96(sp)
    186c:	05312e23          	sw	s3,92(sp)
    1870:	05412c23          	sw	s4,88(sp)
    1874:	05512a23          	sw	s5,84(sp)
    1878:	05612823          	sw	s6,80(sp)
    187c:	05712623          	sw	s7,76(sp)
    1880:	05812423          	sw	s8,72(sp)
    1884:	00050913          	mv	s2,a0
    1888:	00058993          	mv	s3,a1
    188c:	00060b13          	mv	s6,a2
    1890:	00068a13          	mv	s4,a3
    1894:	00070493          	mv	s1,a4
    1898:	00078413          	mv	s0,a5
    189c:	00080b93          	mv	s7,a6
    18a0:	00088a93          	mv	s5,a7
    18a4:	07012c03          	lw	s8,112(sp)
  // check for NaN and special values
  if ((value != value) || (value > DBL_MAX) || (value < -DBL_MAX)) {
    18a8:	00048613          	mv	a2,s1
    18ac:	00040693          	mv	a3,s0
    18b0:	00048513          	mv	a0,s1
    18b4:	00040593          	mv	a1,s0
    18b8:	509040ef          	jal	65c0 <__eqdf2>
    18bc:	30051263          	bnez	a0,1bc0 <_etoa+0x368>
    18c0:	8101a603          	lw	a2,-2032(gp) # 9e50 <__clz_tab+0x100>
    18c4:	8141a683          	lw	a3,-2028(gp) # 9e54 <__clz_tab+0x104>
    18c8:	00048513          	mv	a0,s1
    18cc:	00040593          	mv	a1,s0
    18d0:	57d040ef          	jal	664c <__gedf2>
    18d4:	2ea04663          	bgtz	a0,1bc0 <_etoa+0x368>
    18d8:	8181a603          	lw	a2,-2024(gp) # 9e58 <__clz_tab+0x108>
    18dc:	81c1a683          	lw	a3,-2020(gp) # 9e5c <__clz_tab+0x10c>
    18e0:	00048513          	mv	a0,s1
    18e4:	00040593          	mv	a1,s0
    18e8:	665040ef          	jal	674c <__ledf2>
    18ec:	2c054a63          	bltz	a0,1bc0 <_etoa+0x368>
    18f0:	05912223          	sw	s9,68(sp)
    18f4:	05a12023          	sw	s10,64(sp)
    18f8:	03b12e23          	sw	s11,60(sp)
    return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
  }

  // determine the sign
  const bool negative = value < 0;
  if (negative) {
    18fc:	00000613          	li	a2,0
    1900:	00000693          	li	a3,0
    1904:	00048513          	mv	a0,s1
    1908:	00040593          	mv	a1,s0
    190c:	641040ef          	jal	674c <__ledf2>
    1910:	30054463          	bltz	a0,1c18 <_etoa+0x3c0>
    1914:	00912823          	sw	s1,16(sp)
    1918:	00040c93          	mv	s9,s0
    value = -value;
  }

  // default precision
  if (!(flags & FLAGS_PRECISION)) {
    191c:	400c7793          	andi	a5,s8,1024
    1920:	02f12623          	sw	a5,44(sp)
    1924:	00079463          	bnez	a5,192c <_etoa+0xd4>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1928:	00400b93          	li	s7,4
    uint64_t U;
    double   F;
  } conv;

  conv.F = value;
  int exp2 = (int)((conv.U >> 52U) & 0x07FFU) - 1023;           // effectively log2
    192c:	014cd513          	srli	a0,s9,0x14
    1930:	7ff57513          	andi	a0,a0,2047
  conv.U = (conv.U & ((1ULL << 52U) - 1U)) | (1023ULL << 52U);  // drop the exponent so conv.F is now in [1,2)
    1934:	001007b7          	lui	a5,0x100
    1938:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf46bf>
    193c:	00fcf7b3          	and	a5,s9,a5
    1940:	3ff00d37          	lui	s10,0x3ff00
    1944:	00fd6d33          	or	s10,s10,a5
  // now approximate log10 from the log2 integer part and an expansion of ln around 1.5
  int expval = (int)(0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
    1948:	c0150513          	addi	a0,a0,-1023
    194c:	7e1050ef          	jal	792c <__floatsidf>
    1950:	8201a603          	lw	a2,-2016(gp) # 9e60 <__clz_tab+0x110>
    1954:	8241a683          	lw	a3,-2012(gp) # 9e64 <__clz_tab+0x114>
    1958:	6fd040ef          	jal	6854 <__muldf3>
    195c:	8281a603          	lw	a2,-2008(gp) # 9e68 <__clz_tab+0x118>
    1960:	82c1a683          	lw	a3,-2004(gp) # 9e6c <__clz_tab+0x11c>
    1964:	405030ef          	jal	5568 <__adddf3>
    1968:	00050d93          	mv	s11,a0
    196c:	00b12a23          	sw	a1,20(sp)
    1970:	8301a603          	lw	a2,-2000(gp) # 9e70 <__clz_tab+0x120>
    1974:	8341a683          	lw	a3,-1996(gp) # 9e74 <__clz_tab+0x124>
    1978:	01012703          	lw	a4,16(sp)
    197c:	00070513          	mv	a0,a4
    1980:	000d0593          	mv	a1,s10
    1984:	5a8050ef          	jal	6f2c <__subdf3>
    1988:	8381a603          	lw	a2,-1992(gp) # 9e78 <__clz_tab+0x128>
    198c:	83c1a683          	lw	a3,-1988(gp) # 9e7c <__clz_tab+0x12c>
    1990:	6c5040ef          	jal	6854 <__muldf3>
    1994:	00050613          	mv	a2,a0
    1998:	00058693          	mv	a3,a1
    199c:	000d8513          	mv	a0,s11
    19a0:	01412583          	lw	a1,20(sp)
    19a4:	3c5030ef          	jal	5568 <__adddf3>
    19a8:	68d050ef          	jal	7834 <__fixdfsi>
    19ac:	00050d13          	mv	s10,a0
  // now we want to compute 10^expval but we want to be sure it won't overflow
  exp2 = (int)(expval * 3.321928094887362 + 0.5);
    19b0:	77d050ef          	jal	792c <__floatsidf>
    19b4:	00a12a23          	sw	a0,20(sp)
    19b8:	00b12c23          	sw	a1,24(sp)
    19bc:	8401a603          	lw	a2,-1984(gp) # 9e80 <__clz_tab+0x130>
    19c0:	8441a683          	lw	a3,-1980(gp) # 9e84 <__clz_tab+0x134>
    19c4:	691040ef          	jal	6854 <__muldf3>
    19c8:	8481a603          	lw	a2,-1976(gp) # 9e88 <__clz_tab+0x138>
    19cc:	84c1a683          	lw	a3,-1972(gp) # 9e8c <__clz_tab+0x13c>
    19d0:	399030ef          	jal	5568 <__adddf3>
    19d4:	661050ef          	jal	7834 <__fixdfsi>
    19d8:	00050d93          	mv	s11,a0
  const double z  = expval * 2.302585092994046 - exp2 * 0.6931471805599453;
    19dc:	8501a603          	lw	a2,-1968(gp) # 9e90 <__clz_tab+0x140>
    19e0:	8541a683          	lw	a3,-1964(gp) # 9e94 <__clz_tab+0x144>
    19e4:	01412503          	lw	a0,20(sp)
    19e8:	01812583          	lw	a1,24(sp)
    19ec:	669040ef          	jal	6854 <__muldf3>
    19f0:	00a12a23          	sw	a0,20(sp)
    19f4:	00b12c23          	sw	a1,24(sp)
    19f8:	000d8513          	mv	a0,s11
    19fc:	731050ef          	jal	792c <__floatsidf>
    1a00:	8581a603          	lw	a2,-1960(gp) # 9e98 <__clz_tab+0x148>
    1a04:	85c1a683          	lw	a3,-1956(gp) # 9e9c <__clz_tab+0x14c>
    1a08:	64d040ef          	jal	6854 <__muldf3>
    1a0c:	00050613          	mv	a2,a0
    1a10:	00058693          	mv	a3,a1
    1a14:	01412503          	lw	a0,20(sp)
    1a18:	01812583          	lw	a1,24(sp)
    1a1c:	510050ef          	jal	6f2c <__subdf3>
  const double z2 = z * z;
    1a20:	00a12a23          	sw	a0,20(sp)
    1a24:	00050613          	mv	a2,a0
    1a28:	00b12c23          	sw	a1,24(sp)
    1a2c:	00058693          	mv	a3,a1
    1a30:	625040ef          	jal	6854 <__muldf3>
    1a34:	00a12e23          	sw	a0,28(sp)
    1a38:	02b12023          	sw	a1,32(sp)
  conv.U = (uint64_t)(exp2 + 1023) << 52U;
    1a3c:	3ffd8d93          	addi	s11,s11,1023
    1a40:	014d9d93          	slli	s11,s11,0x14
  // compute exp(z) using continued fractions, see https://en.wikipedia.org/wiki/Exponential_function#Continued_fractions_for_ex
  conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
    1a44:	01412803          	lw	a6,20(sp)
    1a48:	00080613          	mv	a2,a6
    1a4c:	01812783          	lw	a5,24(sp)
    1a50:	00078693          	mv	a3,a5
    1a54:	00080513          	mv	a0,a6
    1a58:	00078593          	mv	a1,a5
    1a5c:	30d030ef          	jal	5568 <__adddf3>
    1a60:	02a12223          	sw	a0,36(sp)
    1a64:	02b12423          	sw	a1,40(sp)
    1a68:	01412603          	lw	a2,20(sp)
    1a6c:	01812683          	lw	a3,24(sp)
    1a70:	8601a503          	lw	a0,-1952(gp) # 9ea0 <__clz_tab+0x150>
    1a74:	8641a583          	lw	a1,-1948(gp) # 9ea4 <__clz_tab+0x154>
    1a78:	4b4050ef          	jal	6f2c <__subdf3>
    1a7c:	00a12a23          	sw	a0,20(sp)
    1a80:	00b12c23          	sw	a1,24(sp)
    1a84:	8681a603          	lw	a2,-1944(gp) # 9ea8 <__clz_tab+0x158>
    1a88:	86c1a683          	lw	a3,-1940(gp) # 9eac <__clz_tab+0x15c>
    1a8c:	01c12503          	lw	a0,28(sp)
    1a90:	02012583          	lw	a1,32(sp)
    1a94:	39c040ef          	jal	5e30 <__divdf3>
    1a98:	8701a603          	lw	a2,-1936(gp) # 9eb0 <__clz_tab+0x160>
    1a9c:	8741a683          	lw	a3,-1932(gp) # 9eb4 <__clz_tab+0x164>
    1aa0:	2c9030ef          	jal	5568 <__adddf3>
    1aa4:	00050613          	mv	a2,a0
    1aa8:	00058693          	mv	a3,a1
    1aac:	01c12503          	lw	a0,28(sp)
    1ab0:	02012583          	lw	a1,32(sp)
    1ab4:	37c040ef          	jal	5e30 <__divdf3>
    1ab8:	8781a603          	lw	a2,-1928(gp) # 9eb8 <__clz_tab+0x168>
    1abc:	87c1a683          	lw	a3,-1924(gp) # 9ebc <__clz_tab+0x16c>
    1ac0:	2a9030ef          	jal	5568 <__adddf3>
    1ac4:	00050613          	mv	a2,a0
    1ac8:	00058693          	mv	a3,a1
    1acc:	01c12503          	lw	a0,28(sp)
    1ad0:	02012583          	lw	a1,32(sp)
    1ad4:	35c040ef          	jal	5e30 <__divdf3>
    1ad8:	00050613          	mv	a2,a0
    1adc:	00058693          	mv	a3,a1
    1ae0:	01412503          	lw	a0,20(sp)
    1ae4:	01812583          	lw	a1,24(sp)
    1ae8:	281030ef          	jal	5568 <__adddf3>
    1aec:	00050613          	mv	a2,a0
    1af0:	00058693          	mv	a3,a1
    1af4:	02412503          	lw	a0,36(sp)
    1af8:	02812583          	lw	a1,40(sp)
    1afc:	334040ef          	jal	5e30 <__divdf3>
    1b00:	8801a603          	lw	a2,-1920(gp) # 9ec0 <__clz_tab+0x170>
    1b04:	8841a683          	lw	a3,-1916(gp) # 9ec4 <__clz_tab+0x174>
    1b08:	261030ef          	jal	5568 <__adddf3>
    1b0c:	00000713          	li	a4,0
    1b10:	00070613          	mv	a2,a4
    1b14:	000d8693          	mv	a3,s11
    1b18:	53d040ef          	jal	6854 <__muldf3>
    1b1c:	00050d93          	mv	s11,a0
    1b20:	00a12c23          	sw	a0,24(sp)
    1b24:	00b12a23          	sw	a1,20(sp)
    1b28:	00b12e23          	sw	a1,28(sp)
  // correct for rounding errors
  if (value < conv.F) {
    1b2c:	01012703          	lw	a4,16(sp)
    1b30:	00070613          	mv	a2,a4
    1b34:	000c8693          	mv	a3,s9
    1b38:	315040ef          	jal	664c <__gedf2>
    1b3c:	02a05263          	blez	a0,1b60 <_etoa+0x308>
    expval--;
    1b40:	fffd0d13          	addi	s10,s10,-1 # 3fefffff <__freertos_irq_stack_top+0x3fef46bf>
    conv.F /= 10;
    1b44:	8701a603          	lw	a2,-1936(gp) # 9eb0 <__clz_tab+0x160>
    1b48:	8741a683          	lw	a3,-1932(gp) # 9eb4 <__clz_tab+0x164>
    1b4c:	000d8513          	mv	a0,s11
    1b50:	01412583          	lw	a1,20(sp)
    1b54:	2dc040ef          	jal	5e30 <__divdf3>
    1b58:	00a12c23          	sw	a0,24(sp)
    1b5c:	00b12e23          	sw	a1,28(sp)
  }

  // the exponent format is "%+03d" and largest value is "307", so set aside 4-5 characters
  unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
    1b60:	063d0793          	addi	a5,s10,99
    1b64:	0c600713          	li	a4,198
    1b68:	0cf76063          	bltu	a4,a5,1c28 <_etoa+0x3d0>
    1b6c:	00400d93          	li	s11,4

  // in "%g" mode, "prec" is the number of *significant figures* not decimals
  if (flags & FLAGS_ADAPT_EXP) {
    1b70:	014c1793          	slli	a5,s8,0x14
    1b74:	0c07d663          	bgez	a5,1c40 <_etoa+0x3e8>
    // do we want to fall-back to "%f" mode?
    if ((value >= 1e-4) && (value < 1e6)) {
    1b78:	8881a603          	lw	a2,-1912(gp) # 9ec8 <__clz_tab+0x178>
    1b7c:	88c1a683          	lw	a3,-1908(gp) # 9ecc <__clz_tab+0x17c>
    1b80:	01012703          	lw	a4,16(sp)
    1b84:	00070513          	mv	a0,a4
    1b88:	000c8593          	mv	a1,s9
    1b8c:	2c1040ef          	jal	664c <__gedf2>
    1b90:	0c054063          	bltz	a0,1c50 <_etoa+0x3f8>
    1b94:	8901a603          	lw	a2,-1904(gp) # 9ed0 <__clz_tab+0x180>
    1b98:	8941a683          	lw	a3,-1900(gp) # 9ed4 <__clz_tab+0x184>
    1b9c:	01012703          	lw	a4,16(sp)
    1ba0:	00070513          	mv	a0,a4
    1ba4:	000c8593          	mv	a1,s9
    1ba8:	3a5040ef          	jal	674c <__ledf2>
    1bac:	0a055263          	bgez	a0,1c50 <_etoa+0x3f8>
      if ((int)prec > expval) {
    1bb0:	097d5063          	bge	s10,s7,1c30 <_etoa+0x3d8>
        prec = (unsigned)((int)prec - expval - 1);
    1bb4:	41ab8d33          	sub	s10,s7,s10
    1bb8:	fffd0b93          	addi	s7,s10,-1
    1bbc:	0780006f          	j	1c34 <_etoa+0x3dc>
    return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
    1bc0:	01812023          	sw	s8,0(sp)
    1bc4:	000a8893          	mv	a7,s5
    1bc8:	000b8813          	mv	a6,s7
    1bcc:	00048713          	mv	a4,s1
    1bd0:	00040793          	mv	a5,s0
    1bd4:	000a0693          	mv	a3,s4
    1bd8:	000b0613          	mv	a2,s6
    1bdc:	00098593          	mv	a1,s3
    1be0:	00090513          	mv	a0,s2
    1be4:	1e8000ef          	jal	1dcc <_ftoa>
    if (flags & FLAGS_LEFT) {
      while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
    }
  }
  return idx;
}
    1be8:	06c12083          	lw	ra,108(sp)
    1bec:	06812403          	lw	s0,104(sp)
    1bf0:	06412483          	lw	s1,100(sp)
    1bf4:	06012903          	lw	s2,96(sp)
    1bf8:	05c12983          	lw	s3,92(sp)
    1bfc:	05812a03          	lw	s4,88(sp)
    1c00:	05412a83          	lw	s5,84(sp)
    1c04:	05012b03          	lw	s6,80(sp)
    1c08:	04c12b83          	lw	s7,76(sp)
    1c0c:	04812c03          	lw	s8,72(sp)
    1c10:	07010113          	addi	sp,sp,112
    1c14:	00008067          	ret
    value = -value;
    1c18:	00912823          	sw	s1,16(sp)
    1c1c:	80000cb7          	lui	s9,0x80000
    1c20:	008cccb3          	xor	s9,s9,s0
    1c24:	cf9ff06f          	j	191c <_etoa+0xc4>
  unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
    1c28:	00500d93          	li	s11,5
    1c2c:	f45ff06f          	j	1b70 <_etoa+0x318>
        prec = 0;
    1c30:	00000b93          	li	s7,0
      flags |= FLAGS_PRECISION;   // make sure _ftoa respects precision
    1c34:	400c6c13          	ori	s8,s8,1024
      minwidth = 0U;
    1c38:	00000d93          	li	s11,0
      expval   = 0;
    1c3c:	00000d13          	li	s10,0
  if (width > minwidth) {
    1c40:	035df263          	bgeu	s11,s5,1c64 <_etoa+0x40c>
    fwidth -= minwidth;
    1c44:	41ba87b3          	sub	a5,s5,s11
    1c48:	00f12a23          	sw	a5,20(sp)
    1c4c:	01c0006f          	j	1c68 <_etoa+0x410>
      if ((prec > 0) && (flags & FLAGS_PRECISION)) {
    1c50:	fe0b88e3          	beqz	s7,1c40 <_etoa+0x3e8>
    1c54:	02c12783          	lw	a5,44(sp)
    1c58:	fe0784e3          	beqz	a5,1c40 <_etoa+0x3e8>
        --prec;
    1c5c:	fffb8b93          	addi	s7,s7,-1
    1c60:	fe1ff06f          	j	1c40 <_etoa+0x3e8>
    fwidth = 0U;
    1c64:	00012a23          	sw	zero,20(sp)
  if ((flags & FLAGS_LEFT) && minwidth) {
    1c68:	002c7793          	andi	a5,s8,2
    1c6c:	02f12023          	sw	a5,32(sp)
    1c70:	00078663          	beqz	a5,1c7c <_etoa+0x424>
    1c74:	000d8463          	beqz	s11,1c7c <_etoa+0x424>
    fwidth = 0U;
    1c78:	00012a23          	sw	zero,20(sp)
  if (expval) {
    1c7c:	020d0663          	beqz	s10,1ca8 <_etoa+0x450>
    value /= conv.F;
    1c80:	01812703          	lw	a4,24(sp)
    1c84:	01c12783          	lw	a5,28(sp)
    1c88:	00070613          	mv	a2,a4
    1c8c:	00078693          	mv	a3,a5
    1c90:	01012703          	lw	a4,16(sp)
    1c94:	00070513          	mv	a0,a4
    1c98:	000c8593          	mv	a1,s9
    1c9c:	194040ef          	jal	5e30 <__divdf3>
    1ca0:	00a12823          	sw	a0,16(sp)
    1ca4:	00058c93          	mv	s9,a1
  idx = _ftoa(out, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);
    1ca8:	00000613          	li	a2,0
    1cac:	00000693          	li	a3,0
    1cb0:	00048513          	mv	a0,s1
    1cb4:	00040593          	mv	a1,s0
    1cb8:	295040ef          	jal	674c <__ledf2>
    1cbc:	0a054c63          	bltz	a0,1d74 <_etoa+0x51c>
    1cc0:	fffff7b7          	lui	a5,0xfffff
    1cc4:	7ff78793          	addi	a5,a5,2047 # fffff7ff <__freertos_irq_stack_top+0xffff3ebf>
    1cc8:	00fc77b3          	and	a5,s8,a5
    1ccc:	00f12023          	sw	a5,0(sp)
    1cd0:	01412883          	lw	a7,20(sp)
    1cd4:	000b8813          	mv	a6,s7
    1cd8:	01012603          	lw	a2,16(sp)
    1cdc:	00060713          	mv	a4,a2
    1ce0:	000c8793          	mv	a5,s9
    1ce4:	000a0693          	mv	a3,s4
    1ce8:	000b0613          	mv	a2,s6
    1cec:	00098593          	mv	a1,s3
    1cf0:	00090513          	mv	a0,s2
    1cf4:	0d8000ef          	jal	1dcc <_ftoa>
  if (minwidth) {
    1cf8:	0c0d8263          	beqz	s11,1dbc <_etoa+0x564>
    out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
    1cfc:	020c7c13          	andi	s8,s8,32
    1d00:	080c0063          	beqz	s8,1d80 <_etoa+0x528>
    1d04:	04500793          	li	a5,69
    1d08:	00150413          	addi	s0,a0,1
    1d0c:	000a0693          	mv	a3,s4
    1d10:	00050613          	mv	a2,a0
    1d14:	00098593          	mv	a1,s3
    1d18:	00078513          	mv	a0,a5
    1d1c:	000900e7          	jalr	s2
    idx = _ntoa_long(out, buffer, idx, maxlen, (expval < 0) ? -expval : expval, expval < 0, 10, 0, minwidth-1, FLAGS_ZEROPAD | FLAGS_PLUS);
    1d20:	41fd5713          	srai	a4,s10,0x1f
    1d24:	01a746b3          	xor	a3,a4,s10
    1d28:	00500793          	li	a5,5
    1d2c:	00f12223          	sw	a5,4(sp)
    1d30:	fffd8d93          	addi	s11,s11,-1
    1d34:	01b12023          	sw	s11,0(sp)
    1d38:	00000893          	li	a7,0
    1d3c:	00a00813          	li	a6,10
    1d40:	01fd5793          	srli	a5,s10,0x1f
    1d44:	40e68733          	sub	a4,a3,a4
    1d48:	000a0693          	mv	a3,s4
    1d4c:	00040613          	mv	a2,s0
    1d50:	00098593          	mv	a1,s3
    1d54:	00090513          	mv	a0,s2
    1d58:	8a5ff0ef          	jal	15fc <_ntoa_long>
    if (flags & FLAGS_LEFT) {
    1d5c:	02012783          	lw	a5,32(sp)
    1d60:	04079263          	bnez	a5,1da4 <_etoa+0x54c>
    1d64:	04412c83          	lw	s9,68(sp)
    1d68:	04012d03          	lw	s10,64(sp)
    1d6c:	03c12d83          	lw	s11,60(sp)
    1d70:	e79ff06f          	j	1be8 <_etoa+0x390>
  idx = _ftoa(out, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);
    1d74:	800007b7          	lui	a5,0x80000
    1d78:	0197ccb3          	xor	s9,a5,s9
    1d7c:	f45ff06f          	j	1cc0 <_etoa+0x468>
    out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
    1d80:	06500793          	li	a5,101
    1d84:	f85ff06f          	j	1d08 <_etoa+0x4b0>
      while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
    1d88:	00150413          	addi	s0,a0,1
    1d8c:	000a0693          	mv	a3,s4
    1d90:	00050613          	mv	a2,a0
    1d94:	00098593          	mv	a1,s3
    1d98:	02000513          	li	a0,32
    1d9c:	000900e7          	jalr	s2
    1da0:	00040513          	mv	a0,s0
    1da4:	416507b3          	sub	a5,a0,s6
    1da8:	ff57e0e3          	bltu	a5,s5,1d88 <_etoa+0x530>
    1dac:	04412c83          	lw	s9,68(sp)
    1db0:	04012d03          	lw	s10,64(sp)
    1db4:	03c12d83          	lw	s11,60(sp)
    1db8:	e31ff06f          	j	1be8 <_etoa+0x390>
    1dbc:	04412c83          	lw	s9,68(sp)
    1dc0:	04012d03          	lw	s10,64(sp)
    1dc4:	03c12d83          	lw	s11,60(sp)
    1dc8:	e21ff06f          	j	1be8 <_etoa+0x390>

00001dcc <_ftoa>:
{
    1dcc:	f7010113          	addi	sp,sp,-144
    1dd0:	08112623          	sw	ra,140(sp)
    1dd4:	08912223          	sw	s1,132(sp)
    1dd8:	07312e23          	sw	s3,124(sp)
    1ddc:	07412c23          	sw	s4,120(sp)
    1de0:	07612823          	sw	s6,112(sp)
    1de4:	07712623          	sw	s7,108(sp)
    1de8:	07812423          	sw	s8,104(sp)
    1dec:	07912223          	sw	s9,100(sp)
    1df0:	07a12023          	sw	s10,96(sp)
    1df4:	05b12e23          	sw	s11,92(sp)
    1df8:	00050b93          	mv	s7,a0
    1dfc:	00058c13          	mv	s8,a1
    1e00:	00060c93          	mv	s9,a2
    1e04:	00068d13          	mv	s10,a3
    1e08:	00070a13          	mv	s4,a4
    1e0c:	00078993          	mv	s3,a5
    1e10:	00080493          	mv	s1,a6
    1e14:	00088b13          	mv	s6,a7
    1e18:	09012d83          	lw	s11,144(sp)
  if (value != value)
    1e1c:	00070613          	mv	a2,a4
    1e20:	00078693          	mv	a3,a5
    1e24:	00070513          	mv	a0,a4
    1e28:	00078593          	mv	a1,a5
    1e2c:	794040ef          	jal	65c0 <__eqdf2>
    1e30:	0c051463          	bnez	a0,1ef8 <_ftoa+0x12c>
  if (value < -DBL_MAX)
    1e34:	8181a603          	lw	a2,-2024(gp) # 9e58 <__clz_tab+0x108>
    1e38:	81c1a683          	lw	a3,-2020(gp) # 9e5c <__clz_tab+0x10c>
    1e3c:	000a0513          	mv	a0,s4
    1e40:	00098593          	mv	a1,s3
    1e44:	109040ef          	jal	674c <__ledf2>
    1e48:	0c054e63          	bltz	a0,1f24 <_ftoa+0x158>
  if (value > DBL_MAX)
    1e4c:	8101a603          	lw	a2,-2032(gp) # 9e50 <__clz_tab+0x100>
    1e50:	8141a683          	lw	a3,-2028(gp) # 9e54 <__clz_tab+0x104>
    1e54:	000a0513          	mv	a0,s4
    1e58:	00098593          	mv	a1,s3
    1e5c:	7f0040ef          	jal	664c <__gedf2>
    1e60:	0ea04863          	bgtz	a0,1f50 <_ftoa+0x184>
  if ((value > PRINTF_MAX_FLOAT) || (value < -PRINTF_MAX_FLOAT)) {
    1e64:	8981a603          	lw	a2,-1896(gp) # 9ed8 <__clz_tab+0x188>
    1e68:	89c1a683          	lw	a3,-1892(gp) # 9edc <__clz_tab+0x18c>
    1e6c:	000a0513          	mv	a0,s4
    1e70:	00098593          	mv	a1,s3
    1e74:	7d8040ef          	jal	664c <__gedf2>
    1e78:	12a04263          	bgtz	a0,1f9c <_ftoa+0x1d0>
    1e7c:	8a01a603          	lw	a2,-1888(gp) # 9ee0 <__clz_tab+0x190>
    1e80:	8a41a683          	lw	a3,-1884(gp) # 9ee4 <__clz_tab+0x194>
    1e84:	000a0513          	mv	a0,s4
    1e88:	00098593          	mv	a1,s3
    1e8c:	0c1040ef          	jal	674c <__ledf2>
    1e90:	10054663          	bltz	a0,1f9c <_ftoa+0x1d0>
    1e94:	08812423          	sw	s0,136(sp)
    1e98:	09212023          	sw	s2,128(sp)
    1e9c:	07512a23          	sw	s5,116(sp)
  if (value < 0) {
    1ea0:	00000613          	li	a2,0
    1ea4:	00000693          	li	a3,0
    1ea8:	000a0513          	mv	a0,s4
    1eac:	00098593          	mv	a1,s3
    1eb0:	09d040ef          	jal	674c <__ledf2>
    1eb4:	10054a63          	bltz	a0,1fc8 <_ftoa+0x1fc>
  bool negative = false;
    1eb8:	02012223          	sw	zero,36(sp)
  if (!(flags & FLAGS_PRECISION)) {
    1ebc:	400df793          	andi	a5,s11,1024
    1ec0:	12078863          	beqz	a5,1ff0 <_ftoa+0x224>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1ec4:	00000413          	li	s0,0
  while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
    1ec8:	01f00793          	li	a5,31
    1ecc:	1287e663          	bltu	a5,s0,1ff8 <_ftoa+0x22c>
    1ed0:	00900793          	li	a5,9
    1ed4:	1297f263          	bgeu	a5,s1,1ff8 <_ftoa+0x22c>
    buf[len++] = '0';
    1ed8:	03040793          	addi	a5,s0,48
    1edc:	02010713          	addi	a4,sp,32
    1ee0:	00e787b3          	add	a5,a5,a4
    1ee4:	03000713          	li	a4,48
    1ee8:	fee78023          	sb	a4,-32(a5) # 7fffffe0 <__freertos_irq_stack_top+0x7fff46a0>
    prec--;
    1eec:	fff48493          	addi	s1,s1,-1
    buf[len++] = '0';
    1ef0:	00140413          	addi	s0,s0,1
    1ef4:	fd5ff06f          	j	1ec8 <_ftoa+0xfc>
    return _out_rev(out, buffer, idx, maxlen, "nan", 3, width, flags);
    1ef8:	000d8893          	mv	a7,s11
    1efc:	000b0813          	mv	a6,s6
    1f00:	00300793          	li	a5,3
    1f04:	00008737          	lui	a4,0x8
    1f08:	b3c70713          	addi	a4,a4,-1220 # 7b3c <_data+0xc>
    1f0c:	000d0693          	mv	a3,s10
    1f10:	000c8613          	mv	a2,s9
    1f14:	000c0593          	mv	a1,s8
    1f18:	000b8513          	mv	a0,s7
    1f1c:	c14ff0ef          	jal	1330 <_out_rev>
    1f20:	33c0006f          	j	225c <_ftoa+0x490>
    return _out_rev(out, buffer, idx, maxlen, "fni-", 4, width, flags);
    1f24:	000d8893          	mv	a7,s11
    1f28:	000b0813          	mv	a6,s6
    1f2c:	00400793          	li	a5,4
    1f30:	00008737          	lui	a4,0x8
    1f34:	b4070713          	addi	a4,a4,-1216 # 7b40 <_data+0x10>
    1f38:	000d0693          	mv	a3,s10
    1f3c:	000c8613          	mv	a2,s9
    1f40:	000c0593          	mv	a1,s8
    1f44:	000b8513          	mv	a0,s7
    1f48:	be8ff0ef          	jal	1330 <_out_rev>
    1f4c:	3100006f          	j	225c <_ftoa+0x490>
    return _out_rev(out, buffer, idx, maxlen, (flags & FLAGS_PLUS) ? "fni+" : "fni", (flags & FLAGS_PLUS) ? 4U : 3U, width, flags);
    1f50:	004df793          	andi	a5,s11,4
    1f54:	02078a63          	beqz	a5,1f88 <_ftoa+0x1bc>
    1f58:	00008737          	lui	a4,0x8
    1f5c:	b3070713          	addi	a4,a4,-1232 # 7b30 <_data>
    1f60:	02078a63          	beqz	a5,1f94 <_ftoa+0x1c8>
    1f64:	00400793          	li	a5,4
    1f68:	000d8893          	mv	a7,s11
    1f6c:	000b0813          	mv	a6,s6
    1f70:	000d0693          	mv	a3,s10
    1f74:	000c8613          	mv	a2,s9
    1f78:	000c0593          	mv	a1,s8
    1f7c:	000b8513          	mv	a0,s7
    1f80:	bb0ff0ef          	jal	1330 <_out_rev>
    1f84:	2d80006f          	j	225c <_ftoa+0x490>
    1f88:	00008737          	lui	a4,0x8
    1f8c:	b3870713          	addi	a4,a4,-1224 # 7b38 <_data+0x8>
    1f90:	fd1ff06f          	j	1f60 <_ftoa+0x194>
    1f94:	00300793          	li	a5,3
    1f98:	fd1ff06f          	j	1f68 <_ftoa+0x19c>
    return _etoa(out, buffer, idx, maxlen, value, prec, width, flags);
    1f9c:	01b12023          	sw	s11,0(sp)
    1fa0:	000b0893          	mv	a7,s6
    1fa4:	00048813          	mv	a6,s1
    1fa8:	000a0713          	mv	a4,s4
    1fac:	00098793          	mv	a5,s3
    1fb0:	000d0693          	mv	a3,s10
    1fb4:	000c8613          	mv	a2,s9
    1fb8:	000c0593          	mv	a1,s8
    1fbc:	000b8513          	mv	a0,s7
    1fc0:	899ff0ef          	jal	1858 <_etoa>
    1fc4:	2980006f          	j	225c <_ftoa+0x490>
    value = 0 - value;
    1fc8:	000a0613          	mv	a2,s4
    1fcc:	00098693          	mv	a3,s3
    1fd0:	00000513          	li	a0,0
    1fd4:	00000593          	li	a1,0
    1fd8:	755040ef          	jal	6f2c <__subdf3>
    1fdc:	00050a13          	mv	s4,a0
    1fe0:	00058993          	mv	s3,a1
    negative = true;
    1fe4:	00100793          	li	a5,1
    1fe8:	02f12223          	sw	a5,36(sp)
    1fec:	ed1ff06f          	j	1ebc <_ftoa+0xf0>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1ff0:	00400493          	li	s1,4
    1ff4:	ed1ff06f          	j	1ec4 <_ftoa+0xf8>
  int whole = (int)value;
    1ff8:	000a0513          	mv	a0,s4
    1ffc:	00098593          	mv	a1,s3
    2000:	035050ef          	jal	7834 <__fixdfsi>
    2004:	00050913          	mv	s2,a0
  double tmp = (value - whole) * pow10[prec];
    2008:	125050ef          	jal	792c <__floatsidf>
    200c:	00050613          	mv	a2,a0
    2010:	00058693          	mv	a3,a1
    2014:	000a0513          	mv	a0,s4
    2018:	00098593          	mv	a1,s3
    201c:	711040ef          	jal	6f2c <__subdf3>
    2020:	000087b7          	lui	a5,0x8
    2024:	00349713          	slli	a4,s1,0x3
    2028:	3b878793          	addi	a5,a5,952 # 83b8 <pow10.0>
    202c:	00e787b3          	add	a5,a5,a4
    2030:	0047a803          	lw	a6,4(a5)
    2034:	0007a783          	lw	a5,0(a5)
    2038:	02f12423          	sw	a5,40(sp)
    203c:	03012623          	sw	a6,44(sp)
    2040:	00078613          	mv	a2,a5
    2044:	00080693          	mv	a3,a6
    2048:	00d040ef          	jal	6854 <__muldf3>
    204c:	00a12e23          	sw	a0,28(sp)
    2050:	02b12023          	sw	a1,32(sp)
  unsigned long frac = (unsigned long)tmp;
    2054:	065050ef          	jal	78b8 <__fixunsdfsi>
    2058:	00050a93          	mv	s5,a0
  diff = tmp - frac;
    205c:	189050ef          	jal	79e4 <__floatunsidf>
    2060:	00050613          	mv	a2,a0
    2064:	00058693          	mv	a3,a1
    2068:	01c12503          	lw	a0,28(sp)
    206c:	02012583          	lw	a1,32(sp)
    2070:	6bd040ef          	jal	6f2c <__subdf3>
    2074:	00a12e23          	sw	a0,28(sp)
    2078:	02b12023          	sw	a1,32(sp)
  if (diff > 0.5) {
    207c:	8481a603          	lw	a2,-1976(gp) # 9e88 <__clz_tab+0x138>
    2080:	84c1a683          	lw	a3,-1972(gp) # 9e8c <__clz_tab+0x13c>
    2084:	5c8040ef          	jal	664c <__gedf2>
    2088:	06a05863          	blez	a0,20f8 <_ftoa+0x32c>
    ++frac;
    208c:	001a8a93          	addi	s5,s5,1
    if (frac >= pow10[prec]) {
    2090:	000a8513          	mv	a0,s5
    2094:	151050ef          	jal	79e4 <__floatunsidf>
    2098:	00050613          	mv	a2,a0
    209c:	00058693          	mv	a3,a1
    20a0:	02812503          	lw	a0,40(sp)
    20a4:	02c12583          	lw	a1,44(sp)
    20a8:	6a4040ef          	jal	674c <__ledf2>
    20ac:	00a04663          	bgtz	a0,20b8 <_ftoa+0x2ec>
      ++whole;
    20b0:	00190913          	addi	s2,s2,1
      frac = 0;
    20b4:	00000a93          	li	s5,0
  if (prec == 0U) {
    20b8:	06049663          	bnez	s1,2124 <_ftoa+0x358>
    diff = value - (double)whole;
    20bc:	00090513          	mv	a0,s2
    20c0:	06d050ef          	jal	792c <__floatsidf>
    20c4:	00050613          	mv	a2,a0
    20c8:	00058693          	mv	a3,a1
    20cc:	000a0513          	mv	a0,s4
    20d0:	00098593          	mv	a1,s3
    20d4:	659040ef          	jal	6f2c <__subdf3>
    if ((!(diff < 0.5) || (diff > 0.5)) && (whole & 1)) {
    20d8:	8481a603          	lw	a2,-1976(gp) # 9e88 <__clz_tab+0x138>
    20dc:	84c1a683          	lw	a3,-1972(gp) # 9e8c <__clz_tab+0x13c>
    20e0:	66c040ef          	jal	674c <__ledf2>
    20e4:	0c054c63          	bltz	a0,21bc <_ftoa+0x3f0>
    20e8:	00197793          	andi	a5,s2,1
    20ec:	0c078863          	beqz	a5,21bc <_ftoa+0x3f0>
      ++whole;
    20f0:	00190913          	addi	s2,s2,1
    20f4:	0c80006f          	j	21bc <_ftoa+0x3f0>
  else if (diff < 0.5) {
    20f8:	8481a603          	lw	a2,-1976(gp) # 9e88 <__clz_tab+0x138>
    20fc:	84c1a683          	lw	a3,-1972(gp) # 9e8c <__clz_tab+0x13c>
    2100:	01c12503          	lw	a0,28(sp)
    2104:	02012583          	lw	a1,32(sp)
    2108:	644040ef          	jal	674c <__ledf2>
    210c:	fa0546e3          	bltz	a0,20b8 <_ftoa+0x2ec>
  else if ((frac == 0U) || (frac & 1U)) {
    2110:	000a8663          	beqz	s5,211c <_ftoa+0x350>
    2114:	001af793          	andi	a5,s5,1
    2118:	fa0780e3          	beqz	a5,20b8 <_ftoa+0x2ec>
    ++frac;
    211c:	001a8a93          	addi	s5,s5,1
    2120:	f99ff06f          	j	20b8 <_ftoa+0x2ec>
    while (len < PRINTF_FTOA_BUFFER_SIZE) {
    2124:	01f00793          	li	a5,31
    2128:	0487e263          	bltu	a5,s0,216c <_ftoa+0x3a0>
      --count;
    212c:	fff48493          	addi	s1,s1,-1
      buf[len++] = (char)(48U + (frac % 10U));
    2130:	00a00793          	li	a5,10
    2134:	02faf733          	remu	a4,s5,a5
    2138:	00140693          	addi	a3,s0,1
    213c:	03070713          	addi	a4,a4,48
    2140:	03040613          	addi	a2,s0,48
    2144:	02010593          	addi	a1,sp,32
    2148:	00b60433          	add	s0,a2,a1
    214c:	fee40023          	sb	a4,-32(s0)
      if (!(frac /= 10U)) {
    2150:	02fad7b3          	divu	a5,s5,a5
    2154:	00900713          	li	a4,9
    2158:	01577863          	bgeu	a4,s5,2168 <_ftoa+0x39c>
    215c:	00078a93          	mv	s5,a5
      buf[len++] = (char)(48U + (frac % 10U));
    2160:	00068413          	mv	s0,a3
    2164:	fc1ff06f          	j	2124 <_ftoa+0x358>
    2168:	00068413          	mv	s0,a3
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
    216c:	01f00793          	li	a5,31
    2170:	0287e663          	bltu	a5,s0,219c <_ftoa+0x3d0>
    2174:	fff48793          	addi	a5,s1,-1
    2178:	02048263          	beqz	s1,219c <_ftoa+0x3d0>
      buf[len++] = '0';
    217c:	03040713          	addi	a4,s0,48
    2180:	02010693          	addi	a3,sp,32
    2184:	00d70733          	add	a4,a4,a3
    2188:	03000693          	li	a3,48
    218c:	fed70023          	sb	a3,-32(a4)
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
    2190:	00078493          	mv	s1,a5
      buf[len++] = '0';
    2194:	00140413          	addi	s0,s0,1
    2198:	fd5ff06f          	j	216c <_ftoa+0x3a0>
    if (len < PRINTF_FTOA_BUFFER_SIZE) {
    219c:	01f00793          	li	a5,31
    21a0:	0087ee63          	bltu	a5,s0,21bc <_ftoa+0x3f0>
      buf[len++] = '.';
    21a4:	03040793          	addi	a5,s0,48
    21a8:	02010713          	addi	a4,sp,32
    21ac:	00e787b3          	add	a5,a5,a4
    21b0:	02e00713          	li	a4,46
    21b4:	fee78023          	sb	a4,-32(a5)
    21b8:	00140413          	addi	s0,s0,1
  while (len < PRINTF_FTOA_BUFFER_SIZE) {
    21bc:	01f00793          	li	a5,31
    21c0:	0287ec63          	bltu	a5,s0,21f8 <_ftoa+0x42c>
    buf[len++] = (char)(48 + (whole % 10));
    21c4:	00a00713          	li	a4,10
    21c8:	02e967b3          	rem	a5,s2,a4
    21cc:	00140693          	addi	a3,s0,1
    21d0:	03078793          	addi	a5,a5,48
    21d4:	03040613          	addi	a2,s0,48
    21d8:	02010593          	addi	a1,sp,32
    21dc:	00b60433          	add	s0,a2,a1
    21e0:	fef40023          	sb	a5,-32(s0)
    if (!(whole /= 10)) {
    21e4:	02e94933          	div	s2,s2,a4
    21e8:	00090663          	beqz	s2,21f4 <_ftoa+0x428>
    buf[len++] = (char)(48 + (whole % 10));
    21ec:	00068413          	mv	s0,a3
    21f0:	fcdff06f          	j	21bc <_ftoa+0x3f0>
    21f4:	00068413          	mv	s0,a3
  if (!(flags & FLAGS_LEFT) && (flags & FLAGS_ZEROPAD)) {
    21f8:	003df713          	andi	a4,s11,3
    21fc:	00100793          	li	a5,1
    2200:	08f70663          	beq	a4,a5,228c <_ftoa+0x4c0>
  if (len < PRINTF_FTOA_BUFFER_SIZE) {
    2204:	01f00793          	li	a5,31
    2208:	0287e263          	bltu	a5,s0,222c <_ftoa+0x460>
    if (negative) {
    220c:	02412783          	lw	a5,36(sp)
    2210:	0c078063          	beqz	a5,22d0 <_ftoa+0x504>
      buf[len++] = '-';
    2214:	03040793          	addi	a5,s0,48
    2218:	02010713          	addi	a4,sp,32
    221c:	00e787b3          	add	a5,a5,a4
    2220:	02d00713          	li	a4,45
    2224:	fee78023          	sb	a4,-32(a5)
    2228:	00140413          	addi	s0,s0,1
  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
    222c:	000d8893          	mv	a7,s11
    2230:	000b0813          	mv	a6,s6
    2234:	00040793          	mv	a5,s0
    2238:	03010713          	addi	a4,sp,48
    223c:	000d0693          	mv	a3,s10
    2240:	000c8613          	mv	a2,s9
    2244:	000c0593          	mv	a1,s8
    2248:	000b8513          	mv	a0,s7
    224c:	8e4ff0ef          	jal	1330 <_out_rev>
    2250:	08812403          	lw	s0,136(sp)
    2254:	08012903          	lw	s2,128(sp)
    2258:	07412a83          	lw	s5,116(sp)
}
    225c:	08c12083          	lw	ra,140(sp)
    2260:	08412483          	lw	s1,132(sp)
    2264:	07c12983          	lw	s3,124(sp)
    2268:	07812a03          	lw	s4,120(sp)
    226c:	07012b03          	lw	s6,112(sp)
    2270:	06c12b83          	lw	s7,108(sp)
    2274:	06812c03          	lw	s8,104(sp)
    2278:	06412c83          	lw	s9,100(sp)
    227c:	06012d03          	lw	s10,96(sp)
    2280:	05c12d83          	lw	s11,92(sp)
    2284:	09010113          	addi	sp,sp,144
    2288:	00008067          	ret
    if (width && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
    228c:	020b0a63          	beqz	s6,22c0 <_ftoa+0x4f4>
    2290:	02412783          	lw	a5,36(sp)
    2294:	00079663          	bnez	a5,22a0 <_ftoa+0x4d4>
    2298:	00cdf793          	andi	a5,s11,12
    229c:	02078263          	beqz	a5,22c0 <_ftoa+0x4f4>
      width--;
    22a0:	fffb0b13          	addi	s6,s6,-1
    22a4:	01c0006f          	j	22c0 <_ftoa+0x4f4>
      buf[len++] = '0';
    22a8:	03040793          	addi	a5,s0,48
    22ac:	02010713          	addi	a4,sp,32
    22b0:	00e787b3          	add	a5,a5,a4
    22b4:	03000713          	li	a4,48
    22b8:	fee78023          	sb	a4,-32(a5)
    22bc:	00140413          	addi	s0,s0,1
    while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
    22c0:	f56472e3          	bgeu	s0,s6,2204 <_ftoa+0x438>
    22c4:	01f00793          	li	a5,31
    22c8:	fe87f0e3          	bgeu	a5,s0,22a8 <_ftoa+0x4dc>
    22cc:	f39ff06f          	j	2204 <_ftoa+0x438>
    else if (flags & FLAGS_PLUS) {
    22d0:	004df793          	andi	a5,s11,4
    22d4:	02078063          	beqz	a5,22f4 <_ftoa+0x528>
      buf[len++] = '+';  // ignore the space if the '+' exists
    22d8:	03040793          	addi	a5,s0,48
    22dc:	02010713          	addi	a4,sp,32
    22e0:	00e787b3          	add	a5,a5,a4
    22e4:	02b00713          	li	a4,43
    22e8:	fee78023          	sb	a4,-32(a5)
    22ec:	00140413          	addi	s0,s0,1
    22f0:	f3dff06f          	j	222c <_ftoa+0x460>
    else if (flags & FLAGS_SPACE) {
    22f4:	008df793          	andi	a5,s11,8
    22f8:	f2078ae3          	beqz	a5,222c <_ftoa+0x460>
      buf[len++] = ' ';
    22fc:	03040793          	addi	a5,s0,48
    2300:	02010713          	addi	a4,sp,32
    2304:	00e787b3          	add	a5,a5,a4
    2308:	02000713          	li	a4,32
    230c:	fee78023          	sb	a4,-32(a5)
    2310:	00140413          	addi	s0,s0,1
    2314:	f19ff06f          	j	222c <_ftoa+0x460>

00002318 <_vsnprintf>:
*                 terminating null character), or a negative value if an error
*                 occurred.
*
******************************************************************************/
static int _vsnprintf(out_fct_type out, char* buffer, const size_t maxlen, const char* format, va_list va)
{
    2318:	fa010113          	addi	sp,sp,-96
    231c:	04112e23          	sw	ra,92(sp)
    2320:	04812c23          	sw	s0,88(sp)
    2324:	04912a23          	sw	s1,84(sp)
    2328:	05212823          	sw	s2,80(sp)
    232c:	05312623          	sw	s3,76(sp)
    2330:	05412423          	sw	s4,72(sp)
    2334:	05512223          	sw	s5,68(sp)
    2338:	05612023          	sw	s6,64(sp)
    233c:	00050a13          	mv	s4,a0
    2340:	00058993          	mv	s3,a1
    2344:	00060913          	mv	s2,a2
    2348:	00d12e23          	sw	a3,28(sp)
    234c:	00e12c23          	sw	a4,24(sp)
  unsigned int flags, width, precision, n;
  size_t idx = 0U;

  if (!buffer) {
    2350:	140588e3          	beqz	a1,2ca0 <_vsnprintf+0x988>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
          }
        }
        format++;
        break;
    2354:	00000493          	li	s1,0
  while (*format)
    2358:	01c12783          	lw	a5,28(sp)
    235c:	0007c503          	lbu	a0,0(a5)
    2360:	140506e3          	beqz	a0,2cac <_vsnprintf+0x994>
    if (*format != '%') {
    2364:	02500713          	li	a4,37
    2368:	02e50663          	beq	a0,a4,2394 <_vsnprintf+0x7c>
      out(*format, buffer, idx++, maxlen);
    236c:	00148413          	addi	s0,s1,1
    2370:	00090693          	mv	a3,s2
    2374:	00048613          	mv	a2,s1
    2378:	00098593          	mv	a1,s3
    237c:	000a00e7          	jalr	s4
      format++;
    2380:	01c12783          	lw	a5,28(sp)
    2384:	00178793          	addi	a5,a5,1
    2388:	00f12e23          	sw	a5,28(sp)
      out(*format, buffer, idx++, maxlen);
    238c:	00040493          	mv	s1,s0
      continue;
    2390:	fc9ff06f          	j	2358 <_vsnprintf+0x40>
      format++;
    2394:	00178793          	addi	a5,a5,1
    2398:	00f12e23          	sw	a5,28(sp)
    flags = 0U;
    239c:	00000413          	li	s0,0
    23a0:	0700006f          	j	2410 <_vsnprintf+0xf8>
        case '0': flags |= FLAGS_ZEROPAD; format++; n = 1U; break;
    23a4:	00146413          	ori	s0,s0,1
    23a8:	00170713          	addi	a4,a4,1
    23ac:	00e12e23          	sw	a4,28(sp)
    23b0:	00100a93          	li	s5,1
    23b4:	0580006f          	j	240c <_vsnprintf+0xf4>
        case '-': flags |= FLAGS_LEFT;    format++; n = 1U; break;
    23b8:	00246413          	ori	s0,s0,2
    23bc:	00170713          	addi	a4,a4,1
    23c0:	00e12e23          	sw	a4,28(sp)
    23c4:	00100a93          	li	s5,1
    23c8:	0440006f          	j	240c <_vsnprintf+0xf4>
        case '+': flags |= FLAGS_PLUS;    format++; n = 1U; break;
    23cc:	00446413          	ori	s0,s0,4
    23d0:	00170713          	addi	a4,a4,1
    23d4:	00e12e23          	sw	a4,28(sp)
    23d8:	00100a93          	li	s5,1
    23dc:	0300006f          	j	240c <_vsnprintf+0xf4>
        case ' ': flags |= FLAGS_SPACE;   format++; n = 1U; break;
    23e0:	00846413          	ori	s0,s0,8
    23e4:	00170713          	addi	a4,a4,1
    23e8:	00e12e23          	sw	a4,28(sp)
    23ec:	00100a93          	li	s5,1
    23f0:	01c0006f          	j	240c <_vsnprintf+0xf4>
        case '#': flags |= FLAGS_HASH;    format++; n = 1U; break;
    23f4:	01046413          	ori	s0,s0,16
    23f8:	00170713          	addi	a4,a4,1
    23fc:	00e12e23          	sw	a4,28(sp)
    2400:	00100a93          	li	s5,1
    2404:	0080006f          	j	240c <_vsnprintf+0xf4>
      switch (*format) {
    2408:	00000a93          	li	s5,0
    } while (n);
    240c:	020a8a63          	beqz	s5,2440 <_vsnprintf+0x128>
      switch (*format) {
    2410:	01c12703          	lw	a4,28(sp)
    2414:	00074783          	lbu	a5,0(a4)
    2418:	fe078793          	addi	a5,a5,-32
    241c:	0ff7f613          	zext.b	a2,a5
    2420:	01000693          	li	a3,16
    2424:	fec6e2e3          	bltu	a3,a2,2408 <_vsnprintf+0xf0>
    2428:	00261793          	slli	a5,a2,0x2
    242c:	000086b7          	lui	a3,0x8
    2430:	19868693          	addi	a3,a3,408 # 8198 <_data+0x668>
    2434:	00d787b3          	add	a5,a5,a3
    2438:	0007a783          	lw	a5,0(a5)
    243c:	00078067          	jr	a5
    if (_is_digit(*format)) {
    2440:	01c12783          	lw	a5,28(sp)
    2444:	0007c703          	lbu	a4,0(a5)
  return (ch >= '0') && (ch <= '9');
    2448:	fd070793          	addi	a5,a4,-48
    244c:	0ff7f793          	zext.b	a5,a5
    if (_is_digit(*format)) {
    2450:	00900693          	li	a3,9
    2454:	04f6f863          	bgeu	a3,a5,24a4 <_vsnprintf+0x18c>
    else if (*format == '*') {
    2458:	02a00793          	li	a5,42
    245c:	04f70c63          	beq	a4,a5,24b4 <_vsnprintf+0x19c>
    width = 0U;
    2460:	000a8b13          	mv	s6,s5
    if (*format == '.') {
    2464:	01c12783          	lw	a5,28(sp)
    2468:	0007c683          	lbu	a3,0(a5)
    246c:	02e00713          	li	a4,46
    2470:	06e68a63          	beq	a3,a4,24e4 <_vsnprintf+0x1cc>
    switch (*format) {
    2474:	01c12703          	lw	a4,28(sp)
    2478:	00074783          	lbu	a5,0(a4)
    247c:	f9878793          	addi	a5,a5,-104
    2480:	0ff7f613          	zext.b	a2,a5
    2484:	01200693          	li	a3,18
    2488:	12c6e663          	bltu	a3,a2,25b4 <_vsnprintf+0x29c>
    248c:	00261793          	slli	a5,a2,0x2
    2490:	000086b7          	lui	a3,0x8
    2494:	1dc68693          	addi	a3,a3,476 # 81dc <_data+0x6ac>
    2498:	00d787b3          	add	a5,a5,a3
    249c:	0007a783          	lw	a5,0(a5)
    24a0:	00078067          	jr	a5
      width = _atoi(&format);
    24a4:	01c10513          	addi	a0,sp,28
    24a8:	e41fe0ef          	jal	12e8 <_atoi>
    24ac:	00050b13          	mv	s6,a0
    24b0:	fb5ff06f          	j	2464 <_vsnprintf+0x14c>
      const int w = va_arg(va, int);
    24b4:	01812783          	lw	a5,24(sp)
    24b8:	00478713          	addi	a4,a5,4
    24bc:	00e12c23          	sw	a4,24(sp)
    24c0:	0007ab03          	lw	s6,0(a5)
      if (w < 0) {
    24c4:	000b4a63          	bltz	s6,24d8 <_vsnprintf+0x1c0>
      format++;
    24c8:	01c12783          	lw	a5,28(sp)
    24cc:	00178793          	addi	a5,a5,1
    24d0:	00f12e23          	sw	a5,28(sp)
    24d4:	f91ff06f          	j	2464 <_vsnprintf+0x14c>
        flags |= FLAGS_LEFT;    // reverse padding
    24d8:	00246413          	ori	s0,s0,2
        width = (unsigned int)-w;
    24dc:	41600b33          	neg	s6,s6
    24e0:	fe9ff06f          	j	24c8 <_vsnprintf+0x1b0>
      flags |= FLAGS_PRECISION;
    24e4:	40046413          	ori	s0,s0,1024
      format++;
    24e8:	00178713          	addi	a4,a5,1
    24ec:	00e12e23          	sw	a4,28(sp)
      if (_is_digit(*format)) {
    24f0:	0017c703          	lbu	a4,1(a5)
  return (ch >= '0') && (ch <= '9');
    24f4:	fd070793          	addi	a5,a4,-48
    24f8:	0ff7f793          	zext.b	a5,a5
      if (_is_digit(*format)) {
    24fc:	00900693          	li	a3,9
    2500:	02f6f863          	bgeu	a3,a5,2530 <_vsnprintf+0x218>
      else if (*format == '*') {
    2504:	02a00793          	li	a5,42
    2508:	f6f716e3          	bne	a4,a5,2474 <_vsnprintf+0x15c>
        const int prec = (int)va_arg(va, int);
    250c:	01812783          	lw	a5,24(sp)
    2510:	00478713          	addi	a4,a5,4
    2514:	00e12c23          	sw	a4,24(sp)
    2518:	0007aa83          	lw	s5,0(a5)
        precision = prec > 0 ? (unsigned int)prec : 0U;
    251c:	020ac263          	bltz	s5,2540 <_vsnprintf+0x228>
        format++;
    2520:	01c12783          	lw	a5,28(sp)
    2524:	00178793          	addi	a5,a5,1
    2528:	00f12e23          	sw	a5,28(sp)
    252c:	f49ff06f          	j	2474 <_vsnprintf+0x15c>
        precision = _atoi(&format);
    2530:	01c10513          	addi	a0,sp,28
    2534:	db5fe0ef          	jal	12e8 <_atoi>
    2538:	00050a93          	mv	s5,a0
    253c:	f39ff06f          	j	2474 <_vsnprintf+0x15c>
        precision = prec > 0 ? (unsigned int)prec : 0U;
    2540:	00000a93          	li	s5,0
    2544:	fddff06f          	j	2520 <_vsnprintf+0x208>
        flags |= FLAGS_LONG;
    2548:	10046613          	ori	a2,s0,256
        format++;
    254c:	00170793          	addi	a5,a4,1
    2550:	00f12e23          	sw	a5,28(sp)
        if (*format == 'l') {
    2554:	00174683          	lbu	a3,1(a4)
    2558:	06c00793          	li	a5,108
    255c:	00f68663          	beq	a3,a5,2568 <_vsnprintf+0x250>
        flags |= FLAGS_LONG;
    2560:	00060413          	mv	s0,a2
    2564:	0500006f          	j	25b4 <_vsnprintf+0x29c>
          flags |= FLAGS_LONG_LONG;
    2568:	30046413          	ori	s0,s0,768
          format++;
    256c:	00270713          	addi	a4,a4,2
    2570:	00e12e23          	sw	a4,28(sp)
    2574:	0400006f          	j	25b4 <_vsnprintf+0x29c>
        flags |= FLAGS_SHORT;
    2578:	08046613          	ori	a2,s0,128
        format++;
    257c:	00170793          	addi	a5,a4,1
    2580:	00f12e23          	sw	a5,28(sp)
        if (*format == 'h') {
    2584:	00174683          	lbu	a3,1(a4)
    2588:	06800793          	li	a5,104
    258c:	00f68663          	beq	a3,a5,2598 <_vsnprintf+0x280>
        flags |= FLAGS_SHORT;
    2590:	00060413          	mv	s0,a2
    2594:	0200006f          	j	25b4 <_vsnprintf+0x29c>
          flags |= FLAGS_CHAR;
    2598:	0c046413          	ori	s0,s0,192
          format++;
    259c:	00270713          	addi	a4,a4,2
    25a0:	00e12e23          	sw	a4,28(sp)
    25a4:	0100006f          	j	25b4 <_vsnprintf+0x29c>
        flags |= (sizeof(ptrdiff_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    25a8:	10046413          	ori	s0,s0,256
        format++;
    25ac:	00170713          	addi	a4,a4,1
    25b0:	00e12e23          	sw	a4,28(sp)
    switch (*format) {
    25b4:	01c12783          	lw	a5,28(sp)
    25b8:	0007c503          	lbu	a0,0(a5)
    25bc:	06700793          	li	a5,103
    25c0:	04a7ea63          	bltu	a5,a0,2614 <_vsnprintf+0x2fc>
    25c4:	02500793          	li	a5,37
    25c8:	6af56863          	bltu	a0,a5,2c78 <_vsnprintf+0x960>
    25cc:	fdb50793          	addi	a5,a0,-37
    25d0:	0ff7f693          	zext.b	a3,a5
    25d4:	04200713          	li	a4,66
    25d8:	6ad76063          	bltu	a4,a3,2c78 <_vsnprintf+0x960>
    25dc:	00269793          	slli	a5,a3,0x2
    25e0:	00008737          	lui	a4,0x8
    25e4:	22870713          	addi	a4,a4,552 # 8228 <_data+0x6f8>
    25e8:	00e787b3          	add	a5,a5,a4
    25ec:	0007a783          	lw	a5,0(a5)
    25f0:	00078067          	jr	a5
        flags |= (sizeof(intmax_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    25f4:	20046413          	ori	s0,s0,512
        format++;
    25f8:	00170713          	addi	a4,a4,1
    25fc:	00e12e23          	sw	a4,28(sp)
        break;
    2600:	fb5ff06f          	j	25b4 <_vsnprintf+0x29c>
        flags |= (sizeof(size_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    2604:	10046413          	ori	s0,s0,256
        format++;
    2608:	00170713          	addi	a4,a4,1
    260c:	00e12e23          	sw	a4,28(sp)
        break;
    2610:	fa5ff06f          	j	25b4 <_vsnprintf+0x29c>
    switch (*format) {
    2614:	07800793          	li	a5,120
    2618:	66a7e063          	bltu	a5,a0,2c78 <_vsnprintf+0x960>
    261c:	06900793          	li	a5,105
    2620:	64f56c63          	bltu	a0,a5,2c78 <_vsnprintf+0x960>
    2624:	f9750713          	addi	a4,a0,-105
    2628:	00100793          	li	a5,1
    262c:	00e797b3          	sll	a5,a5,a4
    2630:	00009737          	lui	a4,0x9
    2634:	04170713          	addi	a4,a4,65 # 9041 <font16_bitmap+0xb15>
    2638:	00e7f733          	and	a4,a5,a4
    263c:	04071263          	bnez	a4,2680 <_vsnprintf+0x368>
    2640:	0807f713          	andi	a4,a5,128
    2644:	5a071a63          	bnez	a4,2bf8 <_vsnprintf+0x8e0>
    2648:	4007f793          	andi	a5,a5,1024
    264c:	62078663          	beqz	a5,2c78 <_vsnprintf+0x960>
    2650:	03712e23          	sw	s7,60(sp)
    2654:	03812c23          	sw	s8,56(sp)
    2658:	03912a23          	sw	s9,52(sp)
    265c:	03a12823          	sw	s10,48(sp)
      }

      case 's' : {
        const char* p = va_arg(va, char*);
    2660:	01812783          	lw	a5,24(sp)
    2664:	00478713          	addi	a4,a5,4
    2668:	00e12c23          	sw	a4,24(sp)
    266c:	0007ac03          	lw	s8,0(a5)
        unsigned int l = _strnlen_s(p, precision ? precision : (size_t)-1);
    2670:	4c0a9463          	bnez	s5,2b38 <_vsnprintf+0x820>
    2674:	fff00713          	li	a4,-1
    2678:	000c0793          	mv	a5,s8
    267c:	4880006f          	j	2b04 <_vsnprintf+0x7ec>
        if (*format == 'x' || *format == 'X') {
    2680:	06f00793          	li	a5,111
    2684:	02f50a63          	beq	a0,a5,26b8 <_vsnprintf+0x3a0>
    2688:	00a7ee63          	bltu	a5,a0,26a4 <_vsnprintf+0x38c>
    268c:	05800793          	li	a5,88
    2690:	0af50c63          	beq	a0,a5,2748 <_vsnprintf+0x430>
    2694:	06200793          	li	a5,98
    2698:	00f51a63          	bne	a0,a5,26ac <_vsnprintf+0x394>
        flags |= FLAGS_SHORT;
    269c:	00200813          	li	a6,2
    26a0:	01c0006f          	j	26bc <_vsnprintf+0x3a4>
    26a4:	07800793          	li	a5,120
    26a8:	0af50463          	beq	a0,a5,2750 <_vsnprintf+0x438>
          flags &= ~FLAGS_HASH;   // no hash for dec format
    26ac:	fef47413          	andi	s0,s0,-17
          base = 10U;
    26b0:	00a00813          	li	a6,10
    26b4:	0080006f          	j	26bc <_vsnprintf+0x3a4>
        flags |= FLAGS_SHORT;
    26b8:	00800813          	li	a6,8
        if (*format == 'X') {
    26bc:	05800793          	li	a5,88
    26c0:	08f50c63          	beq	a0,a5,2758 <_vsnprintf+0x440>
        if ((*format != 'i') && (*format != 'd')) {
    26c4:	06900793          	li	a5,105
    26c8:	00f50863          	beq	a0,a5,26d8 <_vsnprintf+0x3c0>
    26cc:	06400793          	li	a5,100
    26d0:	00f50463          	beq	a0,a5,26d8 <_vsnprintf+0x3c0>
          flags &= ~(FLAGS_PLUS | FLAGS_SPACE);
    26d4:	ff347413          	andi	s0,s0,-13
        if (flags & FLAGS_PRECISION) {
    26d8:	40047793          	andi	a5,s0,1024
    26dc:	00078463          	beqz	a5,26e4 <_vsnprintf+0x3cc>
          flags &= ~FLAGS_ZEROPAD;
    26e0:	ffe47413          	andi	s0,s0,-2
        if ((*format == 'i') || (*format == 'd')) {
    26e4:	06900793          	li	a5,105
    26e8:	06f50c63          	beq	a0,a5,2760 <_vsnprintf+0x448>
    26ec:	06400793          	li	a5,100
    26f0:	06f50863          	beq	a0,a5,2760 <_vsnprintf+0x448>
          if (flags & FLAGS_LONG_LONG) {
    26f4:	20047793          	andi	a5,s0,512
    26f8:	1a079c63          	bnez	a5,28b0 <_vsnprintf+0x598>
          else if (flags & FLAGS_LONG) {
    26fc:	10047793          	andi	a5,s0,256
    2700:	20079063          	bnez	a5,2900 <_vsnprintf+0x5e8>
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
    2704:	04047793          	andi	a5,s0,64
    2708:	22078a63          	beqz	a5,293c <_vsnprintf+0x624>
    270c:	01812783          	lw	a5,24(sp)
    2710:	00478713          	addi	a4,a5,4
    2714:	00e12c23          	sw	a4,24(sp)
    2718:	0007c703          	lbu	a4,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, value, false, base, precision, width, flags);
    271c:	00812223          	sw	s0,4(sp)
    2720:	01612023          	sw	s6,0(sp)
    2724:	000a8893          	mv	a7,s5
    2728:	00000793          	li	a5,0
    272c:	00090693          	mv	a3,s2
    2730:	00048613          	mv	a2,s1
    2734:	00098593          	mv	a1,s3
    2738:	000a0513          	mv	a0,s4
    273c:	ec1fe0ef          	jal	15fc <_ntoa_long>
    2740:	00050493          	mv	s1,a0
    2744:	0780006f          	j	27bc <_vsnprintf+0x4a4>
          base = 10U;
    2748:	01000813          	li	a6,16
    274c:	f71ff06f          	j	26bc <_vsnprintf+0x3a4>
        flags |= FLAGS_SHORT;
    2750:	01000813          	li	a6,16
    2754:	f69ff06f          	j	26bc <_vsnprintf+0x3a4>
          flags |= FLAGS_UPPERCASE;
    2758:	02046413          	ori	s0,s0,32
    275c:	f69ff06f          	j	26c4 <_vsnprintf+0x3ac>
          if (flags & FLAGS_LONG_LONG) {
    2760:	20047793          	andi	a5,s0,512
    2764:	06079463          	bnez	a5,27cc <_vsnprintf+0x4b4>
          else if (flags & FLAGS_LONG) {
    2768:	10047793          	andi	a5,s0,256
    276c:	0c079663          	bnez	a5,2838 <_vsnprintf+0x520>
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
    2770:	04047793          	andi	a5,s0,64
    2774:	10078663          	beqz	a5,2880 <_vsnprintf+0x568>
    2778:	01812783          	lw	a5,24(sp)
    277c:	00478713          	addi	a4,a5,4
    2780:	00e12c23          	sw	a4,24(sp)
    2784:	0007c783          	lbu	a5,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned int)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    2788:	41f7d713          	srai	a4,a5,0x1f
    278c:	00f746b3          	xor	a3,a4,a5
    2790:	00812223          	sw	s0,4(sp)
    2794:	01612023          	sw	s6,0(sp)
    2798:	000a8893          	mv	a7,s5
    279c:	01f7d793          	srli	a5,a5,0x1f
    27a0:	40e68733          	sub	a4,a3,a4
    27a4:	00090693          	mv	a3,s2
    27a8:	00048613          	mv	a2,s1
    27ac:	00098593          	mv	a1,s3
    27b0:	000a0513          	mv	a0,s4
    27b4:	e49fe0ef          	jal	15fc <_ntoa_long>
    27b8:	00050493          	mv	s1,a0
        format++;
    27bc:	01c12783          	lw	a5,28(sp)
    27c0:	00178793          	addi	a5,a5,1
    27c4:	00f12e23          	sw	a5,28(sp)
        break;
    27c8:	b91ff06f          	j	2358 <_vsnprintf+0x40>
            const long long value = va_arg(va, long long);
    27cc:	01812783          	lw	a5,24(sp)
    27d0:	00778793          	addi	a5,a5,7
    27d4:	ff87f793          	andi	a5,a5,-8
    27d8:	00878713          	addi	a4,a5,8
    27dc:	00e12c23          	sw	a4,24(sp)
    27e0:	0007a703          	lw	a4,0(a5)
    27e4:	0047a583          	lw	a1,4(a5)
            idx = _ntoa_long_long(out, buffer, idx, maxlen, (unsigned long long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    27e8:	41f5d693          	srai	a3,a1,0x1f
    27ec:	00e6c7b3          	xor	a5,a3,a4
    27f0:	00b6c633          	xor	a2,a3,a1
    27f4:	40d78733          	sub	a4,a5,a3
    27f8:	00e7b7b3          	sltu	a5,a5,a4
    27fc:	40d606b3          	sub	a3,a2,a3
    2800:	00812623          	sw	s0,12(sp)
    2804:	01612423          	sw	s6,8(sp)
    2808:	01512223          	sw	s5,4(sp)
    280c:	00012023          	sw	zero,0(sp)
    2810:	00080893          	mv	a7,a6
    2814:	01f5d813          	srli	a6,a1,0x1f
    2818:	40f687b3          	sub	a5,a3,a5
    281c:	00090693          	mv	a3,s2
    2820:	00048613          	mv	a2,s1
    2824:	00098593          	mv	a1,s3
    2828:	000a0513          	mv	a0,s4
    282c:	e95fe0ef          	jal	16c0 <_ntoa_long_long>
    2830:	00050493          	mv	s1,a0
    2834:	f89ff06f          	j	27bc <_vsnprintf+0x4a4>
            const long value = va_arg(va, long);
    2838:	01812783          	lw	a5,24(sp)
    283c:	00478713          	addi	a4,a5,4
    2840:	00e12c23          	sw	a4,24(sp)
    2844:	0007a783          	lw	a5,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    2848:	41f7d713          	srai	a4,a5,0x1f
    284c:	00f746b3          	xor	a3,a4,a5
    2850:	00812223          	sw	s0,4(sp)
    2854:	01612023          	sw	s6,0(sp)
    2858:	000a8893          	mv	a7,s5
    285c:	01f7d793          	srli	a5,a5,0x1f
    2860:	40e68733          	sub	a4,a3,a4
    2864:	00090693          	mv	a3,s2
    2868:	00048613          	mv	a2,s1
    286c:	00098593          	mv	a1,s3
    2870:	000a0513          	mv	a0,s4
    2874:	d89fe0ef          	jal	15fc <_ntoa_long>
    2878:	00050493          	mv	s1,a0
    287c:	f41ff06f          	j	27bc <_vsnprintf+0x4a4>
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
    2880:	08047793          	andi	a5,s0,128
    2884:	00078c63          	beqz	a5,289c <_vsnprintf+0x584>
    2888:	01812783          	lw	a5,24(sp)
    288c:	00478713          	addi	a4,a5,4
    2890:	00e12c23          	sw	a4,24(sp)
    2894:	00079783          	lh	a5,0(a5)
    2898:	ef1ff06f          	j	2788 <_vsnprintf+0x470>
    289c:	01812783          	lw	a5,24(sp)
    28a0:	00478713          	addi	a4,a5,4
    28a4:	00e12c23          	sw	a4,24(sp)
    28a8:	0007a783          	lw	a5,0(a5)
    28ac:	eddff06f          	j	2788 <_vsnprintf+0x470>
            idx = _ntoa_long_long(out, buffer, idx, maxlen, va_arg(va, unsigned long long), false, base, precision, width, flags);
    28b0:	01812783          	lw	a5,24(sp)
    28b4:	00778793          	addi	a5,a5,7
    28b8:	ff87f793          	andi	a5,a5,-8
    28bc:	00878713          	addi	a4,a5,8
    28c0:	00e12c23          	sw	a4,24(sp)
    28c4:	0007a703          	lw	a4,0(a5)
    28c8:	0047a783          	lw	a5,4(a5)
    28cc:	00812623          	sw	s0,12(sp)
    28d0:	01612423          	sw	s6,8(sp)
    28d4:	01512223          	sw	s5,4(sp)
    28d8:	00012023          	sw	zero,0(sp)
    28dc:	00080893          	mv	a7,a6
    28e0:	00000813          	li	a6,0
    28e4:	00090693          	mv	a3,s2
    28e8:	00048613          	mv	a2,s1
    28ec:	00098593          	mv	a1,s3
    28f0:	000a0513          	mv	a0,s4
    28f4:	dcdfe0ef          	jal	16c0 <_ntoa_long_long>
    28f8:	00050493          	mv	s1,a0
    28fc:	ec1ff06f          	j	27bc <_vsnprintf+0x4a4>
            idx = _ntoa_long(out, buffer, idx, maxlen, va_arg(va, unsigned long), false, base, precision, width, flags);
    2900:	01812783          	lw	a5,24(sp)
    2904:	00478713          	addi	a4,a5,4
    2908:	00e12c23          	sw	a4,24(sp)
    290c:	0007a703          	lw	a4,0(a5)
    2910:	00812223          	sw	s0,4(sp)
    2914:	01612023          	sw	s6,0(sp)
    2918:	000a8893          	mv	a7,s5
    291c:	00000793          	li	a5,0
    2920:	00090693          	mv	a3,s2
    2924:	00048613          	mv	a2,s1
    2928:	00098593          	mv	a1,s3
    292c:	000a0513          	mv	a0,s4
    2930:	ccdfe0ef          	jal	15fc <_ntoa_long>
    2934:	00050493          	mv	s1,a0
    2938:	e85ff06f          	j	27bc <_vsnprintf+0x4a4>
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
    293c:	08047793          	andi	a5,s0,128
    2940:	00078c63          	beqz	a5,2958 <_vsnprintf+0x640>
    2944:	01812783          	lw	a5,24(sp)
    2948:	00478713          	addi	a4,a5,4
    294c:	00e12c23          	sw	a4,24(sp)
    2950:	0007d703          	lhu	a4,0(a5)
    2954:	dc9ff06f          	j	271c <_vsnprintf+0x404>
    2958:	01812783          	lw	a5,24(sp)
    295c:	00478713          	addi	a4,a5,4
    2960:	00e12c23          	sw	a4,24(sp)
    2964:	0007a703          	lw	a4,0(a5)
    2968:	db5ff06f          	j	271c <_vsnprintf+0x404>
        if (*format == 'F') flags |= FLAGS_UPPERCASE;
    296c:	04600793          	li	a5,70
    2970:	04f50a63          	beq	a0,a5,29c4 <_vsnprintf+0x6ac>
        idx = _ftoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
    2974:	01812783          	lw	a5,24(sp)
    2978:	00778793          	addi	a5,a5,7
    297c:	ff87f793          	andi	a5,a5,-8
    2980:	00878713          	addi	a4,a5,8
    2984:	00e12c23          	sw	a4,24(sp)
    2988:	0007a703          	lw	a4,0(a5)
    298c:	0047a783          	lw	a5,4(a5)
    2990:	00812023          	sw	s0,0(sp)
    2994:	000b0893          	mv	a7,s6
    2998:	000a8813          	mv	a6,s5
    299c:	00090693          	mv	a3,s2
    29a0:	00048613          	mv	a2,s1
    29a4:	00098593          	mv	a1,s3
    29a8:	000a0513          	mv	a0,s4
    29ac:	c20ff0ef          	jal	1dcc <_ftoa>
    29b0:	00050493          	mv	s1,a0
        format++;
    29b4:	01c12783          	lw	a5,28(sp)
    29b8:	00178793          	addi	a5,a5,1
    29bc:	00f12e23          	sw	a5,28(sp)
        break;
    29c0:	999ff06f          	j	2358 <_vsnprintf+0x40>
        if (*format == 'F') flags |= FLAGS_UPPERCASE;
    29c4:	02046413          	ori	s0,s0,32
    29c8:	fadff06f          	j	2974 <_vsnprintf+0x65c>
        if ((*format == 'g')||(*format == 'G')) flags |= FLAGS_ADAPT_EXP;
    29cc:	06700793          	li	a5,103
    29d0:	00f50663          	beq	a0,a5,29dc <_vsnprintf+0x6c4>
    29d4:	04700793          	li	a5,71
    29d8:	00f51863          	bne	a0,a5,29e8 <_vsnprintf+0x6d0>
    29dc:	000017b7          	lui	a5,0x1
    29e0:	80078793          	addi	a5,a5,-2048 # 800 <CUSTOM2+0x7a5>
    29e4:	00f46433          	or	s0,s0,a5
        if ((*format == 'E')||(*format == 'G')) flags |= FLAGS_UPPERCASE;
    29e8:	04500793          	li	a5,69
    29ec:	00f50663          	beq	a0,a5,29f8 <_vsnprintf+0x6e0>
    29f0:	04700793          	li	a5,71
    29f4:	00f51463          	bne	a0,a5,29fc <_vsnprintf+0x6e4>
    29f8:	02046413          	ori	s0,s0,32
        idx = _etoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
    29fc:	01812783          	lw	a5,24(sp)
    2a00:	00778793          	addi	a5,a5,7
    2a04:	ff87f793          	andi	a5,a5,-8
    2a08:	00878713          	addi	a4,a5,8
    2a0c:	00e12c23          	sw	a4,24(sp)
    2a10:	0007a703          	lw	a4,0(a5)
    2a14:	0047a783          	lw	a5,4(a5)
    2a18:	00812023          	sw	s0,0(sp)
    2a1c:	000b0893          	mv	a7,s6
    2a20:	000a8813          	mv	a6,s5
    2a24:	00090693          	mv	a3,s2
    2a28:	00048613          	mv	a2,s1
    2a2c:	00098593          	mv	a1,s3
    2a30:	000a0513          	mv	a0,s4
    2a34:	e25fe0ef          	jal	1858 <_etoa>
    2a38:	00050493          	mv	s1,a0
        format++;
    2a3c:	01c12783          	lw	a5,28(sp)
    2a40:	00178793          	addi	a5,a5,1
    2a44:	00f12e23          	sw	a5,28(sp)
        break;
    2a48:	911ff06f          	j	2358 <_vsnprintf+0x40>
    2a4c:	03712e23          	sw	s7,60(sp)
        if (!(flags & FLAGS_LEFT)) {
    2a50:	00247413          	andi	s0,s0,2
    2a54:	06040a63          	beqz	s0,2ac8 <_vsnprintf+0x7b0>
        unsigned int l = 1U;
    2a58:	00100a93          	li	s5,1
        out((char)va_arg(va, int), buffer, idx++, maxlen);
    2a5c:	01812783          	lw	a5,24(sp)
    2a60:	00478713          	addi	a4,a5,4
    2a64:	00e12c23          	sw	a4,24(sp)
    2a68:	00148b93          	addi	s7,s1,1
    2a6c:	00090693          	mv	a3,s2
    2a70:	00048613          	mv	a2,s1
    2a74:	00098593          	mv	a1,s3
    2a78:	0007c503          	lbu	a0,0(a5)
    2a7c:	000a00e7          	jalr	s4
        if (flags & FLAGS_LEFT) {
    2a80:	06041863          	bnez	s0,2af0 <_vsnprintf+0x7d8>
        format++;
    2a84:	01c12783          	lw	a5,28(sp)
    2a88:	00178793          	addi	a5,a5,1
    2a8c:	00f12e23          	sw	a5,28(sp)
        break;
    2a90:	000b8493          	mv	s1,s7
    2a94:	03c12b83          	lw	s7,60(sp)
    2a98:	8c1ff06f          	j	2358 <_vsnprintf+0x40>
            out(' ', buffer, idx++, maxlen);
    2a9c:	00148b93          	addi	s7,s1,1
    2aa0:	00090693          	mv	a3,s2
    2aa4:	00048613          	mv	a2,s1
    2aa8:	00098593          	mv	a1,s3
    2aac:	02000513          	li	a0,32
    2ab0:	000a00e7          	jalr	s4
          while (l++ < width) {
    2ab4:	000a8793          	mv	a5,s5
            out(' ', buffer, idx++, maxlen);
    2ab8:	000b8493          	mv	s1,s7
          while (l++ < width) {
    2abc:	00178a93          	addi	s5,a5,1
    2ac0:	fd67eee3          	bltu	a5,s6,2a9c <_vsnprintf+0x784>
    2ac4:	f99ff06f          	j	2a5c <_vsnprintf+0x744>
        unsigned int l = 1U;
    2ac8:	00100793          	li	a5,1
    2acc:	ff1ff06f          	j	2abc <_vsnprintf+0x7a4>
            out(' ', buffer, idx++, maxlen);
    2ad0:	001b8493          	addi	s1,s7,1
    2ad4:	00090693          	mv	a3,s2
    2ad8:	000b8613          	mv	a2,s7
    2adc:	00098593          	mv	a1,s3
    2ae0:	02000513          	li	a0,32
    2ae4:	000a00e7          	jalr	s4
          while (l++ < width) {
    2ae8:	00040a93          	mv	s5,s0
            out(' ', buffer, idx++, maxlen);
    2aec:	00048b93          	mv	s7,s1
          while (l++ < width) {
    2af0:	001a8413          	addi	s0,s5,1
    2af4:	fd6aeee3          	bltu	s5,s6,2ad0 <_vsnprintf+0x7b8>
    2af8:	f8dff06f          	j	2a84 <_vsnprintf+0x76c>
  for (s = str; *s && maxsize--; ++s);
    2afc:	00178793          	addi	a5,a5,1
    2b00:	00068713          	mv	a4,a3
    2b04:	0007c683          	lbu	a3,0(a5)
    2b08:	00068663          	beqz	a3,2b14 <_vsnprintf+0x7fc>
    2b0c:	fff70693          	addi	a3,a4,-1
    2b10:	fe0716e3          	bnez	a4,2afc <_vsnprintf+0x7e4>
  return (unsigned int)(s - str);
    2b14:	41878bb3          	sub	s7,a5,s8
        // pre padding
        if (flags & FLAGS_PRECISION) {
    2b18:	40047c93          	andi	s9,s0,1024
    2b1c:	000c8663          	beqz	s9,2b28 <_vsnprintf+0x810>
          l = (l < precision ? l : precision);
    2b20:	017af463          	bgeu	s5,s7,2b28 <_vsnprintf+0x810>
    2b24:	000a8b93          	mv	s7,s5
        }
        if (!(flags & FLAGS_LEFT)) {
    2b28:	00247d13          	andi	s10,s0,2
    2b2c:	060d1463          	bnez	s10,2b94 <_vsnprintf+0x87c>
    2b30:	03b12623          	sw	s11,44(sp)
    2b34:	02c0006f          	j	2b60 <_vsnprintf+0x848>
        unsigned int l = _strnlen_s(p, precision ? precision : (size_t)-1);
    2b38:	000a8713          	mv	a4,s5
    2b3c:	b3dff06f          	j	2678 <_vsnprintf+0x360>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
    2b40:	00148d93          	addi	s11,s1,1
    2b44:	00090693          	mv	a3,s2
    2b48:	00048613          	mv	a2,s1
    2b4c:	00098593          	mv	a1,s3
    2b50:	02000513          	li	a0,32
    2b54:	000a00e7          	jalr	s4
          while (l++ < width) {
    2b58:	00040b93          	mv	s7,s0
            out(' ', buffer, idx++, maxlen);
    2b5c:	000d8493          	mv	s1,s11
          while (l++ < width) {
    2b60:	001b8413          	addi	s0,s7,1
    2b64:	fd6beee3          	bltu	s7,s6,2b40 <_vsnprintf+0x828>
    2b68:	00040b93          	mv	s7,s0
    2b6c:	02c12d83          	lw	s11,44(sp)
    2b70:	0240006f          	j	2b94 <_vsnprintf+0x87c>
          }
        }
        // string output
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
    2b74:	00078a93          	mv	s5,a5
          out(*(p++), buffer, idx++, maxlen);
    2b78:	001c0c13          	addi	s8,s8,1
    2b7c:	00148413          	addi	s0,s1,1
    2b80:	00090693          	mv	a3,s2
    2b84:	00048613          	mv	a2,s1
    2b88:	00098593          	mv	a1,s3
    2b8c:	000a00e7          	jalr	s4
    2b90:	00040493          	mv	s1,s0
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
    2b94:	000c4503          	lbu	a0,0(s8)
    2b98:	00050863          	beqz	a0,2ba8 <_vsnprintf+0x890>
    2b9c:	fc0c8ee3          	beqz	s9,2b78 <_vsnprintf+0x860>
    2ba0:	fffa8793          	addi	a5,s5,-1
    2ba4:	fc0a98e3          	bnez	s5,2b74 <_vsnprintf+0x85c>
        }
        // post padding
        if (flags & FLAGS_LEFT) {
    2ba8:	040d1263          	bnez	s10,2bec <_vsnprintf+0x8d4>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
          }
        }
        format++;
    2bac:	01c12783          	lw	a5,28(sp)
    2bb0:	00178793          	addi	a5,a5,1
    2bb4:	00f12e23          	sw	a5,28(sp)
        break;
    2bb8:	03c12b83          	lw	s7,60(sp)
    2bbc:	03812c03          	lw	s8,56(sp)
    2bc0:	03412c83          	lw	s9,52(sp)
    2bc4:	03012d03          	lw	s10,48(sp)
    2bc8:	f90ff06f          	j	2358 <_vsnprintf+0x40>
            out(' ', buffer, idx++, maxlen);
    2bcc:	00148a93          	addi	s5,s1,1
    2bd0:	00090693          	mv	a3,s2
    2bd4:	00048613          	mv	a2,s1
    2bd8:	00098593          	mv	a1,s3
    2bdc:	02000513          	li	a0,32
    2be0:	000a00e7          	jalr	s4
          while (l++ < width) {
    2be4:	00040b93          	mv	s7,s0
            out(' ', buffer, idx++, maxlen);
    2be8:	000a8493          	mv	s1,s5
          while (l++ < width) {
    2bec:	001b8413          	addi	s0,s7,1
    2bf0:	fd6beee3          	bltu	s7,s6,2bcc <_vsnprintf+0x8b4>
    2bf4:	fb9ff06f          	j	2bac <_vsnprintf+0x894>
      }

      case 'p' : {
        width = sizeof(void*) * 2U;
        flags |= FLAGS_ZEROPAD | FLAGS_UPPERCASE;
    2bf8:	02146413          	ori	s0,s0,33
        if (is_ll) {
          idx = _ntoa_long_long(out, buffer, idx, maxlen, (uintptr_t)va_arg(va, void*), false, 16U, precision, width, flags);
        }
        else {
#endif
          idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)((uintptr_t)va_arg(va, void*)), false, 16U, precision, width, flags);
    2bfc:	01812783          	lw	a5,24(sp)
    2c00:	00478713          	addi	a4,a5,4
    2c04:	00e12c23          	sw	a4,24(sp)
    2c08:	0007a703          	lw	a4,0(a5)
    2c0c:	00812223          	sw	s0,4(sp)
    2c10:	00800793          	li	a5,8
    2c14:	00f12023          	sw	a5,0(sp)
    2c18:	000a8893          	mv	a7,s5
    2c1c:	01000813          	li	a6,16
    2c20:	00000793          	li	a5,0
    2c24:	00090693          	mv	a3,s2
    2c28:	00048613          	mv	a2,s1
    2c2c:	00098593          	mv	a1,s3
    2c30:	000a0513          	mv	a0,s4
    2c34:	9c9fe0ef          	jal	15fc <_ntoa_long>
    2c38:	00050493          	mv	s1,a0
#if defined(PRINTF_SUPPORT_LONG_LONG)
        }
#endif
        format++;
    2c3c:	01c12783          	lw	a5,28(sp)
    2c40:	00178793          	addi	a5,a5,1
    2c44:	00f12e23          	sw	a5,28(sp)
        break;
    2c48:	f10ff06f          	j	2358 <_vsnprintf+0x40>
      }

      case '%' :
        out('%', buffer, idx++, maxlen);
    2c4c:	00148413          	addi	s0,s1,1
    2c50:	00090693          	mv	a3,s2
    2c54:	00048613          	mv	a2,s1
    2c58:	00098593          	mv	a1,s3
    2c5c:	02500513          	li	a0,37
    2c60:	000a00e7          	jalr	s4
        format++;
    2c64:	01c12783          	lw	a5,28(sp)
    2c68:	00178793          	addi	a5,a5,1
    2c6c:	00f12e23          	sw	a5,28(sp)
        out('%', buffer, idx++, maxlen);
    2c70:	00040493          	mv	s1,s0
        break;
    2c74:	ee4ff06f          	j	2358 <_vsnprintf+0x40>

      default :
        out(*format, buffer, idx++, maxlen);
    2c78:	00148413          	addi	s0,s1,1
    2c7c:	00090693          	mv	a3,s2
    2c80:	00048613          	mv	a2,s1
    2c84:	00098593          	mv	a1,s3
    2c88:	000a00e7          	jalr	s4
        format++;
    2c8c:	01c12783          	lw	a5,28(sp)
    2c90:	00178793          	addi	a5,a5,1
    2c94:	00f12e23          	sw	a5,28(sp)
        out(*format, buffer, idx++, maxlen);
    2c98:	00040493          	mv	s1,s0
        break;
    2c9c:	ebcff06f          	j	2358 <_vsnprintf+0x40>
    out = _out_null;
    2ca0:	00001a37          	lui	s4,0x1
    2ca4:	2e4a0a13          	addi	s4,s4,740 # 12e4 <_out_null>
    2ca8:	eacff06f          	j	2354 <_vsnprintf+0x3c>
    }
  }

  // termination
  out((char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
    2cac:	0524e263          	bltu	s1,s2,2cf0 <_vsnprintf+0x9d8>
    2cb0:	fff90613          	addi	a2,s2,-1
    2cb4:	00090693          	mv	a3,s2
    2cb8:	00098593          	mv	a1,s3
    2cbc:	00000513          	li	a0,0
    2cc0:	000a00e7          	jalr	s4

  // return written chars without terminating \0
  return (int)idx;
}
    2cc4:	00048513          	mv	a0,s1
    2cc8:	05c12083          	lw	ra,92(sp)
    2ccc:	05812403          	lw	s0,88(sp)
    2cd0:	05412483          	lw	s1,84(sp)
    2cd4:	05012903          	lw	s2,80(sp)
    2cd8:	04c12983          	lw	s3,76(sp)
    2cdc:	04812a03          	lw	s4,72(sp)
    2ce0:	04412a83          	lw	s5,68(sp)
    2ce4:	04012b03          	lw	s6,64(sp)
    2ce8:	06010113          	addi	sp,sp,96
    2cec:	00008067          	ret
  out((char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
    2cf0:	00048613          	mv	a2,s1
    2cf4:	fc1ff06f          	j	2cb4 <_vsnprintf+0x99c>

00002cf8 <emit_char>:
* @note 空间不够时**返回原位置、不写入**，也就是说超长内容是被截断的，
*       而不是溢出。所有输出路径都要经过这个函数，边界检查就只需要在这一处
*       做对。
******************************************************************************/
static uint32_t emit_char(char *out, uint32_t pos, uint32_t cap, char c)
{
    2cf8:	00050793          	mv	a5,a0
    2cfc:	00058513          	mv	a0,a1
    if ((pos + 1U) < cap) {
    2d00:	00158713          	addi	a4,a1,1
    2d04:	00c76463          	bltu	a4,a2,2d0c <emit_char+0x14>
        out[pos] = c;
        return pos + 1U;
    }
    return pos;
}
    2d08:	00008067          	ret
        out[pos] = c;
    2d0c:	00b78533          	add	a0,a5,a1
    2d10:	00d50023          	sb	a3,0(a0)
        return pos + 1U;
    2d14:	00070513          	mv	a0,a4
    2d18:	00008067          	ret

00002d1c <emit_str>:
*       格式化 %s 时如果调用者传了个空指针，正常做法是崩溃；但对一个用于
*       排查问题的日志函数来说，崩溃恰恰是最糟的结果——它会把现场毁掉。
*       打印 (null) 既能让人看出"这里传空了"，又不会中断程序。
******************************************************************************/
static uint32_t emit_str(char *out, uint32_t pos, uint32_t cap, const char *s)
{
    2d1c:	ff010113          	addi	sp,sp,-16
    2d20:	00112623          	sw	ra,12(sp)
    2d24:	00812423          	sw	s0,8(sp)
    2d28:	00912223          	sw	s1,4(sp)
    2d2c:	01212023          	sw	s2,0(sp)
    2d30:	00050493          	mv	s1,a0
    2d34:	00060913          	mv	s2,a2
    2d38:	00068413          	mv	s0,a3
    if (s == 0) {
    2d3c:	02069263          	bnez	a3,2d60 <emit_str+0x44>
        s = "(null)";
    2d40:	00008437          	lui	s0,0x8
    2d44:	b4840413          	addi	s0,s0,-1208 # 7b48 <_data+0x18>
    2d48:	0180006f          	j	2d60 <emit_str+0x44>
    }
    while (*s != '\0') {
        pos = emit_char(out, pos, cap, *s);
    2d4c:	00090613          	mv	a2,s2
    2d50:	00048513          	mv	a0,s1
    2d54:	fa5ff0ef          	jal	2cf8 <emit_char>
    2d58:	00050593          	mv	a1,a0
        s++;
    2d5c:	00140413          	addi	s0,s0,1
    while (*s != '\0') {
    2d60:	00044683          	lbu	a3,0(s0)
    2d64:	fe0694e3          	bnez	a3,2d4c <emit_str+0x30>
    }
    return pos;
}
    2d68:	00058513          	mv	a0,a1
    2d6c:	00c12083          	lw	ra,12(sp)
    2d70:	00812403          	lw	s0,8(sp)
    2d74:	00412483          	lw	s1,4(sp)
    2d78:	00012903          	lw	s2,0(sp)
    2d7c:	01010113          	addi	sp,sp,16
    2d80:	00008067          	ret

00002d84 <emit_uint>:
* @note `n < sizeof(tmp)` 这个额外条件是防御性的：即使将来 tmp 的尺寸被改小、
*       或者 base 被传入了别的值，也不会写越界。
******************************************************************************/
static uint32_t emit_uint(char *out, uint32_t pos, uint32_t cap,
                          uint32_t value, uint32_t base, int upper)
{
    2d84:	fe010113          	addi	sp,sp,-32
    2d88:	00112e23          	sw	ra,28(sp)
    2d8c:	00912a23          	sw	s1,20(sp)
    2d90:	01212823          	sw	s2,16(sp)
    2d94:	00050493          	mv	s1,a0
    2d98:	00060913          	mv	s2,a2
    const char *digits = upper ? "0123456789ABCDEF" : "0123456789abcdef";
    2d9c:	04078463          	beqz	a5,2de4 <emit_uint+0x60>
    2da0:	00008537          	lui	a0,0x8
    2da4:	b5050513          	addi	a0,a0,-1200 # 7b50 <_data+0x20>
    char        tmp[11];
    uint32_t    n = 0U;

    /* 0 要单独处理：上面的循环是"取余直到商为 0"，对 0 来说一次都不执行，
     * 结果会什么都不输出。而 "0" 显然应该输出一个 0。*/
    if (value == 0U) {
    2da8:	04068463          	beqz	a3,2df0 <emit_uint+0x6c>
    2dac:	00812c23          	sw	s0,24(sp)
    uint32_t    n = 0U;
    2db0:	00000413          	li	s0,0
        return emit_char(out, pos, cap, '0');
    }
    while ((value != 0U) && (n < sizeof(tmp))) {
    2db4:	06068a63          	beqz	a3,2e28 <emit_uint+0xa4>
    2db8:	00a00793          	li	a5,10
    2dbc:	0687e663          	bltu	a5,s0,2e28 <emit_uint+0xa4>
        tmp[n] = digits[value % base];  /* 取最低位 */
    2dc0:	02e6f7b3          	remu	a5,a3,a4
    2dc4:	00f507b3          	add	a5,a0,a5
    2dc8:	0007c603          	lbu	a2,0(a5)
    2dcc:	01040793          	addi	a5,s0,16
    2dd0:	002787b3          	add	a5,a5,sp
    2dd4:	fec78a23          	sb	a2,-12(a5)
        value /= base;                  /* 去掉最低位 */
    2dd8:	02e6d6b3          	divu	a3,a3,a4
        n++;
    2ddc:	00140413          	addi	s0,s0,1
    2de0:	fd5ff06f          	j	2db4 <emit_uint+0x30>
    const char *digits = upper ? "0123456789ABCDEF" : "0123456789abcdef";
    2de4:	00008537          	lui	a0,0x8
    2de8:	b6450513          	addi	a0,a0,-1180 # 7b64 <_data+0x34>
    2dec:	fbdff06f          	j	2da8 <emit_uint+0x24>
        return emit_char(out, pos, cap, '0');
    2df0:	03000693          	li	a3,48
    2df4:	00090613          	mv	a2,s2
    2df8:	00048513          	mv	a0,s1
    2dfc:	efdff0ef          	jal	2cf8 <emit_char>
    2e00:	00050593          	mv	a1,a0
    2e04:	02c0006f          	j	2e30 <emit_uint+0xac>
    }
    /* 倒序输出，得到高位在前的正常顺序。*/
    while (n > 0U) {
        n--;
    2e08:	fff40413          	addi	s0,s0,-1
        pos = emit_char(out, pos, cap, tmp[n]);
    2e0c:	01040793          	addi	a5,s0,16
    2e10:	002787b3          	add	a5,a5,sp
    2e14:	ff47c683          	lbu	a3,-12(a5)
    2e18:	00090613          	mv	a2,s2
    2e1c:	00048513          	mv	a0,s1
    2e20:	ed9ff0ef          	jal	2cf8 <emit_char>
    2e24:	00050593          	mv	a1,a0
    while (n > 0U) {
    2e28:	fe0410e3          	bnez	s0,2e08 <emit_uint+0x84>
    2e2c:	01812403          	lw	s0,24(sp)
    }
    return pos;
}
    2e30:	00058513          	mv	a0,a1
    2e34:	01c12083          	lw	ra,28(sp)
    2e38:	01412483          	lw	s1,20(sp)
    2e3c:	01012903          	lw	s2,16(sp)
    2e40:	02010113          	addi	sp,sp,32
    2e44:	00008067          	ret

00002e48 <app_vformat>:
*       后面可能还有普通字符或别的格式符要处理，必须继续循环。
*       这一点和 frame.c 里状态机的写法正好相反——那里的每个状态处理完这一
*       字节就该返回了。
******************************************************************************/
static uint32_t app_vformat(char *out, uint32_t cap, const char *format, va_list ap)
{
    2e48:	fd010113          	addi	sp,sp,-48
    2e4c:	02112623          	sw	ra,44(sp)
    2e50:	00d12623          	sw	a3,12(sp)
    uint32_t pos = 0U;

    if ((out == 0) || (cap == 0U) || (format == 0)) {
    2e54:	2a050a63          	beqz	a0,3108 <app_vformat+0x2c0>
    2e58:	02812423          	sw	s0,40(sp)
    2e5c:	02912223          	sw	s1,36(sp)
    2e60:	03212023          	sw	s2,32(sp)
    2e64:	00050913          	mv	s2,a0
    2e68:	00058493          	mv	s1,a1
    2e6c:	00060413          	mv	s0,a2
    2e70:	2a058063          	beqz	a1,3110 <app_vformat+0x2c8>
    2e74:	2a060663          	beqz	a2,3120 <app_vformat+0x2d8>
    2e78:	01312e23          	sw	s3,28(sp)
    uint32_t pos = 0U;
    2e7c:	00000593          	li	a1,0
    2e80:	0640006f          	j	2ee4 <app_vformat+0x9c>
    }

    while (*format != '\0') {
        /* 普通字符直接输出。*/
        if (*format != '%') {
            pos = emit_char(out, pos, cap, *format);
    2e84:	00048613          	mv	a2,s1
    2e88:	00090513          	mv	a0,s2
    2e8c:	e6dff0ef          	jal	2cf8 <emit_char>
    2e90:	00050593          	mv	a1,a0
            format++;
    2e94:	00140413          	addi	s0,s0,1
            continue;
    2e98:	04c0006f          	j	2ee4 <app_vformat+0x9c>
        }

        /* 遇到 '%'，看下一个字符决定怎么处理。
         * format++ 之后 *format 就是格式符本身。*/
        format++;
        switch (*format) {
    2e9c:	1e078663          	beqz	a5,3088 <app_vformat+0x240>
    2ea0:	02500713          	li	a4,37
    2ea4:	20e79063          	bne	a5,a4,30a4 <app_vformat+0x25c>
            pos = emit_str(out, pos, cap, "0x");
            pos = emit_uint(out, pos, cap, (uint32_t)va_arg(ap, void *), 16U, 0);
            break;
        case '%':
            /* "%%" 表示输出一个真正的百分号。*/
            pos = emit_char(out, pos, cap, '%');
    2ea8:	02500693          	li	a3,37
    2eac:	00048613          	mv	a2,s1
    2eb0:	00090513          	mv	a0,s2
    2eb4:	e45ff0ef          	jal	2cf8 <emit_char>
    2eb8:	00050593          	mv	a1,a0
            break;
    2ebc:	0240006f          	j	2ee0 <app_vformat+0x98>
            pos = emit_str(out, pos, cap, va_arg(ap, const char *));
    2ec0:	00c12783          	lw	a5,12(sp)
    2ec4:	00478713          	addi	a4,a5,4
    2ec8:	00e12623          	sw	a4,12(sp)
    2ecc:	0007a683          	lw	a3,0(a5)
    2ed0:	00048613          	mv	a2,s1
    2ed4:	00090513          	mv	a0,s2
    2ed8:	e45ff0ef          	jal	2d1c <emit_str>
    2edc:	00050593          	mv	a1,a0
             * 在日志里一眼就能看见。如果静默吞掉，排查时会以为参数丢了。*/
            pos = emit_char(out, pos, cap, '%');
            pos = emit_char(out, pos, cap, *format);
            break;
        }
        format++;
    2ee0:	00198413          	addi	s0,s3,1
    while (*format != '\0') {
    2ee4:	00044683          	lbu	a3,0(s0)
    2ee8:	1e068463          	beqz	a3,30d0 <app_vformat+0x288>
        if (*format != '%') {
    2eec:	02500793          	li	a5,37
    2ef0:	f8f69ae3          	bne	a3,a5,2e84 <app_vformat+0x3c>
        format++;
    2ef4:	00140993          	addi	s3,s0,1
        switch (*format) {
    2ef8:	00144783          	lbu	a5,1(s0)
    2efc:	07800713          	li	a4,120
    2f00:	1af76263          	bltu	a4,a5,30a4 <app_vformat+0x25c>
    2f04:	05800713          	li	a4,88
    2f08:	f8e7eae3          	bltu	a5,a4,2e9c <app_vformat+0x54>
    2f0c:	fa878793          	addi	a5,a5,-88
    2f10:	0ff7f693          	zext.b	a3,a5
    2f14:	02000713          	li	a4,32
    2f18:	18d76663          	bltu	a4,a3,30a4 <app_vformat+0x25c>
    2f1c:	00269793          	slli	a5,a3,0x2
    2f20:	00008737          	lui	a4,0x8
    2f24:	33470713          	addi	a4,a4,820 # 8334 <_data+0x804>
    2f28:	00e787b3          	add	a5,a5,a4
    2f2c:	0007a783          	lw	a5,0(a5)
    2f30:	00078067          	jr	a5
            pos = emit_char(out, pos, cap, (char)va_arg(ap, int));
    2f34:	00c12783          	lw	a5,12(sp)
    2f38:	00478713          	addi	a4,a5,4
    2f3c:	00e12623          	sw	a4,12(sp)
    2f40:	0007c683          	lbu	a3,0(a5)
    2f44:	00048613          	mv	a2,s1
    2f48:	00090513          	mv	a0,s2
    2f4c:	dadff0ef          	jal	2cf8 <emit_char>
    2f50:	00050593          	mv	a1,a0
            break;
    2f54:	f8dff06f          	j	2ee0 <app_vformat+0x98>
            int32_t v = va_arg(ap, int32_t);
    2f58:	00c12783          	lw	a5,12(sp)
    2f5c:	00478713          	addi	a4,a5,4
    2f60:	00e12623          	sw	a4,12(sp)
    2f64:	0007a403          	lw	s0,0(a5)
            if (v < 0) {
    2f68:	02044263          	bltz	s0,2f8c <app_vformat+0x144>
                pos = emit_uint(out, pos, cap, (uint32_t)v, 10U, 0);
    2f6c:	00000793          	li	a5,0
    2f70:	00a00713          	li	a4,10
    2f74:	00040693          	mv	a3,s0
    2f78:	00048613          	mv	a2,s1
    2f7c:	00090513          	mv	a0,s2
    2f80:	e05ff0ef          	jal	2d84 <emit_uint>
    2f84:	00050593          	mv	a1,a0
    2f88:	f59ff06f          	j	2ee0 <app_vformat+0x98>
                pos = emit_char(out, pos, cap, '-');
    2f8c:	02d00693          	li	a3,45
    2f90:	00048613          	mv	a2,s1
    2f94:	00090513          	mv	a0,s2
    2f98:	d61ff0ef          	jal	2cf8 <emit_char>
    2f9c:	00050593          	mv	a1,a0
                pos = emit_uint(out, pos, cap, (uint32_t)0 - (uint32_t)v, 10U, 0);
    2fa0:	00000793          	li	a5,0
    2fa4:	00a00713          	li	a4,10
    2fa8:	408006b3          	neg	a3,s0
    2fac:	00048613          	mv	a2,s1
    2fb0:	00090513          	mv	a0,s2
    2fb4:	dd1ff0ef          	jal	2d84 <emit_uint>
    2fb8:	00050593          	mv	a1,a0
    2fbc:	f25ff06f          	j	2ee0 <app_vformat+0x98>
            pos = emit_uint(out, pos, cap, va_arg(ap, uint32_t), 10U, 0);
    2fc0:	00c12683          	lw	a3,12(sp)
    2fc4:	00468793          	addi	a5,a3,4
    2fc8:	00f12623          	sw	a5,12(sp)
    2fcc:	00000793          	li	a5,0
    2fd0:	00a00713          	li	a4,10
    2fd4:	0006a683          	lw	a3,0(a3)
    2fd8:	00048613          	mv	a2,s1
    2fdc:	00090513          	mv	a0,s2
    2fe0:	da5ff0ef          	jal	2d84 <emit_uint>
    2fe4:	00050593          	mv	a1,a0
            break;
    2fe8:	ef9ff06f          	j	2ee0 <app_vformat+0x98>
            pos = emit_uint(out, pos, cap, va_arg(ap, uint32_t), 16U, 0);
    2fec:	00c12683          	lw	a3,12(sp)
    2ff0:	00468793          	addi	a5,a3,4
    2ff4:	00f12623          	sw	a5,12(sp)
    2ff8:	00000793          	li	a5,0
    2ffc:	01000713          	li	a4,16
    3000:	0006a683          	lw	a3,0(a3)
    3004:	00048613          	mv	a2,s1
    3008:	00090513          	mv	a0,s2
    300c:	d79ff0ef          	jal	2d84 <emit_uint>
    3010:	00050593          	mv	a1,a0
            break;
    3014:	ecdff06f          	j	2ee0 <app_vformat+0x98>
            pos = emit_uint(out, pos, cap, va_arg(ap, uint32_t), 16U, 1);
    3018:	00c12683          	lw	a3,12(sp)
    301c:	00468793          	addi	a5,a3,4
    3020:	00f12623          	sw	a5,12(sp)
    3024:	00100793          	li	a5,1
    3028:	01000713          	li	a4,16
    302c:	0006a683          	lw	a3,0(a3)
    3030:	00048613          	mv	a2,s1
    3034:	00090513          	mv	a0,s2
    3038:	d4dff0ef          	jal	2d84 <emit_uint>
    303c:	00050593          	mv	a1,a0
            break;
    3040:	ea1ff06f          	j	2ee0 <app_vformat+0x98>
            pos = emit_str(out, pos, cap, "0x");
    3044:	000086b7          	lui	a3,0x8
    3048:	b7868693          	addi	a3,a3,-1160 # 7b78 <_data+0x48>
    304c:	00048613          	mv	a2,s1
    3050:	00090513          	mv	a0,s2
    3054:	cc9ff0ef          	jal	2d1c <emit_str>
    3058:	00050593          	mv	a1,a0
            pos = emit_uint(out, pos, cap, (uint32_t)va_arg(ap, void *), 16U, 0);
    305c:	00c12683          	lw	a3,12(sp)
    3060:	00468793          	addi	a5,a3,4
    3064:	00f12623          	sw	a5,12(sp)
    3068:	00000793          	li	a5,0
    306c:	01000713          	li	a4,16
    3070:	0006a683          	lw	a3,0(a3)
    3074:	00048613          	mv	a2,s1
    3078:	00090513          	mv	a0,s2
    307c:	d09ff0ef          	jal	2d84 <emit_uint>
    3080:	00050593          	mv	a1,a0
            break;
    3084:	e5dff06f          	j	2ee0 <app_vformat+0x98>
            pos = emit_char(out, pos, cap, '%');
    3088:	02500693          	li	a3,37
    308c:	00048613          	mv	a2,s1
    3090:	00090513          	mv	a0,s2
    3094:	c65ff0ef          	jal	2cf8 <emit_char>
    3098:	00050593          	mv	a1,a0
            format--;
    309c:	00040993          	mv	s3,s0
            break;
    30a0:	e41ff06f          	j	2ee0 <app_vformat+0x98>
            pos = emit_char(out, pos, cap, '%');
    30a4:	02500693          	li	a3,37
    30a8:	00048613          	mv	a2,s1
    30ac:	00090513          	mv	a0,s2
    30b0:	c49ff0ef          	jal	2cf8 <emit_char>
    30b4:	00050593          	mv	a1,a0
            pos = emit_char(out, pos, cap, *format);
    30b8:	00144683          	lbu	a3,1(s0)
    30bc:	00048613          	mv	a2,s1
    30c0:	00090513          	mv	a0,s2
    30c4:	c35ff0ef          	jal	2cf8 <emit_char>
    30c8:	00050593          	mv	a1,a0
            break;
    30cc:	e15ff06f          	j	2ee0 <app_vformat+0x98>
    }

    /* 补上字符串结束符。
     * 这里用三元表达式做一次边界保护：如果写满到 cap，就写到最后一个字节，
     * 保证 out 始终是一个合法的、有结束符的字符串。*/
    out[(pos < cap) ? pos : (cap - 1U)] = '\0';
    30d0:	0295e863          	bltu	a1,s1,3100 <app_vformat+0x2b8>
    30d4:	fff48493          	addi	s1,s1,-1
    30d8:	00990933          	add	s2,s2,s1
    30dc:	00090023          	sb	zero,0(s2)
    return pos;
    30e0:	02812403          	lw	s0,40(sp)
    30e4:	02412483          	lw	s1,36(sp)
    30e8:	02012903          	lw	s2,32(sp)
    30ec:	01c12983          	lw	s3,28(sp)
}
    30f0:	00058513          	mv	a0,a1
    30f4:	02c12083          	lw	ra,44(sp)
    30f8:	03010113          	addi	sp,sp,48
    30fc:	00008067          	ret
    out[(pos < cap) ? pos : (cap - 1U)] = '\0';
    3100:	00058493          	mv	s1,a1
    3104:	fd5ff06f          	j	30d8 <app_vformat+0x290>
        return 0U;
    3108:	00000593          	li	a1,0
    310c:	fe5ff06f          	j	30f0 <app_vformat+0x2a8>
    3110:	02812403          	lw	s0,40(sp)
    3114:	02412483          	lw	s1,36(sp)
    3118:	02012903          	lw	s2,32(sp)
    311c:	fd5ff06f          	j	30f0 <app_vformat+0x2a8>
    3120:	00000593          	li	a1,0
    3124:	02812403          	lw	s0,40(sp)
    3128:	02412483          	lw	s1,36(sp)
    312c:	02012903          	lw	s2,32(sp)
    3130:	fc1ff06f          	j	30f0 <app_vformat+0x2a8>

00003134 <bsp_printf>:
* @param format Format string followed by the arguments to be formatted.
* @param ... Variable arguments corresponding to the format specifiers in 'format'.
*
******************************************************************************/
    static int bsp_printf(const char* format, ...)
    {
    3134:	f6010113          	addi	sp,sp,-160
    3138:	06112e23          	sw	ra,124(sp)
    313c:	06812c23          	sw	s0,120(sp)
    3140:	08b12223          	sw	a1,132(sp)
    3144:	08c12423          	sw	a2,136(sp)
    3148:	08d12623          	sw	a3,140(sp)
    314c:	08e12823          	sw	a4,144(sp)
    3150:	08f12a23          	sw	a5,148(sp)
    3154:	09012c23          	sw	a6,152(sp)
    3158:	09112e23          	sw	a7,156(sp)
      va_list va;
      va_start(va, format);
    315c:	08410713          	addi	a4,sp,132
    3160:	06e12623          	sw	a4,108(sp)

      char buffer[MAX_STRING_BUFFER_SIZE];
        const int ret = _vsnprintf(_out_buffer, buffer, (size_t)-1, format, va);
    3164:	00050693          	mv	a3,a0
    3168:	fff00613          	li	a2,-1
    316c:	00810593          	addi	a1,sp,8
    3170:	00001537          	lui	a0,0x1
    3174:	2d450513          	addi	a0,a0,724 # 12d4 <_out_buffer>
    3178:	9a0ff0ef          	jal	2318 <_vsnprintf>
    317c:	00050413          	mv	s0,a0
        _putchar_s(buffer);
    3180:	00810513          	addi	a0,sp,8
    3184:	938fe0ef          	jal	12bc <_putchar_s>

      va_end(va);
      return ret;
    }
    3188:	00040513          	mv	a0,s0
    318c:	07c12083          	lw	ra,124(sp)
    3190:	07812403          	lw	s0,120(sp)
    3194:	0a010113          	addi	sp,sp,160
    3198:	00008067          	ret

0000319c <app_log_init>:
/******************************************************************************
* @brief 清空日志环并清零计数。
******************************************************************************/
void app_log_init(void)
{
    s_head = 0U;
    319c:	8c01a223          	sw	zero,-1852(gp) # 9f04 <s_head>
    s_tail = 0U;
    31a0:	8c01a023          	sw	zero,-1856(gp) # 9f00 <s_tail>
    s_dropped = 0U;
    31a4:	8a01ae23          	sw	zero,-1860(gp) # 9efc <s_dropped>
    s_once_mask = 0U;      /* 清掉"已报过"的位，让 app_log_once 重新从首次开始 */
    31a8:	8a01ac23          	sw	zero,-1864(gp) # 9ef8 <s_once_mask>
}
    31ac:	00008067          	ret

000031b0 <app_log_pending>:
*
* @note 与 proto_uart.c 里同样的环形缓冲技巧：无符号减法 + 掩码取模。
******************************************************************************/
uint32_t app_log_pending(void)
{
    return (s_head - s_tail) & (APP_LOG_RING_SIZE - 1U);
    31b0:	8c41a503          	lw	a0,-1852(gp) # 9f04 <s_head>
    31b4:	8c01a783          	lw	a5,-1856(gp) # 9f00 <s_tail>
    31b8:	40f50533          	sub	a0,a0,a5
}
    31bc:	3ff57513          	andi	a0,a0,1023
    31c0:	00008067          	ret

000031c4 <app_log_v>:
    char     msg[APP_LOG_MSG_MAX];
    uint32_t used;
    uint32_t i;
    uint32_t space;

    if (format == 0) {
    31c4:	0c050663          	beqz	a0,3290 <app_log_v+0xcc>
{
    31c8:	f5010113          	addi	sp,sp,-176
    31cc:	0a112623          	sw	ra,172(sp)
    31d0:	0a812423          	sw	s0,168(sp)
    31d4:	00050613          	mv	a2,a0
    31d8:	00058693          	mv	a3,a1
        return;
    }

    used = app_vformat(msg, sizeof(msg), format, ap);
    31dc:	0a000593          	li	a1,160
    31e0:	00010513          	mv	a0,sp
    31e4:	c65ff0ef          	jal	2e48 <app_vformat>
    31e8:	00050413          	mv	s0,a0

    /* 格式化结果为空就不必进队了。*/
    if (used == 0U) {
    31ec:	00051a63          	bnez	a0,3200 <app_log_v+0x3c>
     *
     * 这里补的是**逻辑换行**（只有 '\n' 一个字节）。真正上串口需要的
     * "\r\n" 两个字节由 app_log_flush() 在发送前展开，理由见那个函数的说明。*/
    s_ring[s_head] = '\n';
    s_head = (s_head + 1U) & (APP_LOG_RING_SIZE - 1U);
}
    31f0:	0ac12083          	lw	ra,172(sp)
    31f4:	0a812403          	lw	s0,168(sp)
    31f8:	0b010113          	addi	sp,sp,176
    31fc:	00008067          	ret
    space = (APP_LOG_RING_SIZE - 1U) - app_log_pending();
    3200:	fb1ff0ef          	jal	31b0 <app_log_pending>
    3204:	3ff00793          	li	a5,1023
    3208:	40a787b3          	sub	a5,a5,a0
    if ((used + 1U) > space) {
    320c:	00140713          	addi	a4,s0,1
    3210:	00e7e663          	bltu	a5,a4,321c <app_log_v+0x58>
    for (i = 0U; i < used; i++) {
    3214:	00000713          	li	a4,0
    3218:	0480006f          	j	3260 <app_log_v+0x9c>
        s_dropped++;           /* 放不下整条，丢掉并计数 */
    321c:	8bc1a783          	lw	a5,-1860(gp) # 9efc <s_dropped>
    3220:	00178793          	addi	a5,a5,1
    3224:	8af1ae23          	sw	a5,-1860(gp) # 9efc <s_dropped>
        return;
    3228:	fc9ff06f          	j	31f0 <app_log_v+0x2c>
        s_ring[s_head] = msg[i];
    322c:	8c41a583          	lw	a1,-1852(gp) # 9f04 <s_head>
    3230:	0a070793          	addi	a5,a4,160
    3234:	002787b3          	add	a5,a5,sp
    3238:	f607c603          	lbu	a2,-160(a5)
    323c:	0000a7b7          	lui	a5,0xa
    3240:	f8078793          	addi	a5,a5,-128 # 9f80 <s_ring>
    3244:	00b787b3          	add	a5,a5,a1
    3248:	00c78023          	sb	a2,0(a5)
        s_head = (s_head + 1U) & (APP_LOG_RING_SIZE - 1U);
    324c:	8c41a783          	lw	a5,-1852(gp) # 9f04 <s_head>
    3250:	00178793          	addi	a5,a5,1
    3254:	3ff7f793          	andi	a5,a5,1023
    3258:	8cf1a223          	sw	a5,-1852(gp) # 9f04 <s_head>
    for (i = 0U; i < used; i++) {
    325c:	00170713          	addi	a4,a4,1
    3260:	fc8766e3          	bltu	a4,s0,322c <app_log_v+0x68>
    s_ring[s_head] = '\n';
    3264:	8c41a683          	lw	a3,-1852(gp) # 9f04 <s_head>
    3268:	0000a7b7          	lui	a5,0xa
    326c:	f8078793          	addi	a5,a5,-128 # 9f80 <s_ring>
    3270:	00d787b3          	add	a5,a5,a3
    3274:	00a00693          	li	a3,10
    3278:	00d78023          	sb	a3,0(a5)
    s_head = (s_head + 1U) & (APP_LOG_RING_SIZE - 1U);
    327c:	8c41a783          	lw	a5,-1852(gp) # 9f04 <s_head>
    3280:	00178793          	addi	a5,a5,1
    3284:	3ff7f793          	andi	a5,a5,1023
    3288:	8cf1a223          	sw	a5,-1852(gp) # 9f04 <s_head>
    328c:	f65ff06f          	j	31f0 <app_log_v+0x2c>
    3290:	00008067          	ret

00003294 <app_log_dropped>:
}
    3294:	8bc1a503          	lw	a0,-1860(gp) # 9efc <s_dropped>
    3298:	00008067          	ret

0000329c <app_log>:
* @brief 格式化一条消息并排进队列。
*
* @param format 格式串，后面跟可变参数。
******************************************************************************/
void app_log(const char *format, ...)
{
    329c:	fc010113          	addi	sp,sp,-64
    32a0:	00112e23          	sw	ra,28(sp)
    32a4:	02b12223          	sw	a1,36(sp)
    32a8:	02c12423          	sw	a2,40(sp)
    32ac:	02d12623          	sw	a3,44(sp)
    32b0:	02e12823          	sw	a4,48(sp)
    32b4:	02f12a23          	sw	a5,52(sp)
    32b8:	03012c23          	sw	a6,56(sp)
    32bc:	03112e23          	sw	a7,60(sp)
    va_list ap;

    va_start(ap, format);
    32c0:	02410593          	addi	a1,sp,36
    32c4:	00b12623          	sw	a1,12(sp)
    app_log_v(format, ap);
    32c8:	efdff0ef          	jal	31c4 <app_log_v>
    va_end(ap);
}
    32cc:	01c12083          	lw	ra,28(sp)
    32d0:	04010113          	addi	sp,sp,64
    32d4:	00008067          	ret

000032d8 <app_log_once>:
* @note bitno MUST 小于 32。C 语言里 `1U << 32` 是**未定义行为**（不是简单
*       地得到 0），可能把其它位搅乱。这里显式挡住，因为 bitno 常直接来自枚举，
*       将来给枚举加值时就可能越界，而那种 bug 极难查。
******************************************************************************/
void app_log_once(uint32_t bitno, const char *format, ...)
{
    32d8:	fc010113          	addi	sp,sp,-64
    32dc:	00112e23          	sw	ra,28(sp)
    32e0:	00050313          	mv	t1,a0
    32e4:	02c12423          	sw	a2,40(sp)
    32e8:	02d12623          	sw	a3,44(sp)
    32ec:	02e12823          	sw	a4,48(sp)
    32f0:	02f12a23          	sw	a5,52(sp)
    32f4:	03012c23          	sw	a6,56(sp)
    32f8:	03112e23          	sw	a7,60(sp)
    va_list ap;

    if (bitno >= 32U) {
    32fc:	01f00793          	li	a5,31
    3300:	00a7ee63          	bltu	a5,a0,331c <app_log_once+0x44>
    3304:	00058513          	mv	a0,a1
        return;                    /* 越界：宁可不输出，也不能移位越界 */
    }
    if ((s_once_mask & (1U << bitno)) != 0U) {
    3308:	00100793          	li	a5,1
    330c:	006797b3          	sll	a5,a5,t1
    3310:	8b81a703          	lw	a4,-1864(gp) # 9ef8 <s_once_mask>
    3314:	00e7f6b3          	and	a3,a5,a4
    3318:	00068863          	beqz	a3,3328 <app_log_once+0x50>
    s_once_mask |= (1U << bitno);

    va_start(ap, format);
    app_log_v(format, ap);
    va_end(ap);
}
    331c:	01c12083          	lw	ra,28(sp)
    3320:	04010113          	addi	sp,sp,64
    3324:	00008067          	ret
    s_once_mask |= (1U << bitno);
    3328:	00e7e7b3          	or	a5,a5,a4
    332c:	8af1ac23          	sw	a5,-1864(gp) # 9ef8 <s_once_mask>
    va_start(ap, format);
    3330:	02810593          	addi	a1,sp,40
    3334:	00b12623          	sw	a1,12(sp)
    app_log_v(format, ap);
    3338:	e8dff0ef          	jal	31c4 <app_log_v>
    va_end(ap);
    333c:	fe1ff06f          	j	331c <app_log_once+0x44>

00003340 <app_log_flush>:
* @note 末尾多留一个字节给 '\0'（s_emit 定义为 CHUNK+1 大小），
*       s_emit[out] = '\0' 就是补结束符——这一句不能省，否则打印函数会越过
*       有效内容继续往后读。
******************************************************************************/
uint32_t app_log_flush(void)
{
    3340:	ff010113          	addi	sp,sp,-16
    3344:	00112623          	sw	ra,12(sp)
    3348:	00812423          	sw	s0,8(sp)
    /* pending 在循环开始前取一次就够了：本函数是环的唯一消费者，
     * 循环里 s_tail 只会往前走，所以 pending 就是"这次最多能取多少"。*/
    uint32_t pending = app_log_pending();
    334c:	e65ff0ef          	jal	31b0 <app_log_pending>
    uint32_t consumed = 0U;     /* 已从环里取走的源字节数 */
    uint32_t out = 0U;          /* 已写入 s_emit 的输出字节数 */
    char     c;

    if (pending == 0U) {
    3350:	0a050a63          	beqz	a0,3404 <app_log_flush+0xc4>
    uint32_t out = 0U;          /* 已写入 s_emit 的输出字节数 */
    3354:	00000413          	li	s0,0
    uint32_t consumed = 0U;     /* 已从环里取走的源字节数 */
    3358:	00000713          	li	a4,0
    335c:	0480006f          	j	33a4 <app_log_flush+0x64>
             * 后半条日志会覆盖在当前行上；只发 '\n' 又会阶梯错位。
             * 要么整对发出，要么一个都不发。
             *
             * 注：APP_LOG_CHUNK 为 32，所以 out==0 时这个条件必然不成立，
             * 不会出现"一个字节都取不出来"的死循环。*/
            if ((out + 2U) > APP_LOG_CHUNK) {
    3360:	00240693          	addi	a3,s0,2
    3364:	02000793          	li	a5,32
    3368:	06d7ec63          	bltu	a5,a3,33e0 <app_log_flush+0xa0>
                break;
            }
            s_emit[out] = '\r';     /* 先回车 */
    336c:	91c18793          	addi	a5,gp,-1764 # 9f5c <s_emit>
    3370:	00878633          	add	a2,a5,s0
    3374:	00d00593          	li	a1,13
    3378:	00b60023          	sb	a1,0(a2)
            out++;
    337c:	00140413          	addi	s0,s0,1
            s_emit[out] = '\n';     /* 再换行 */
    3380:	008787b3          	add	a5,a5,s0
    3384:	00a00613          	li	a2,10
    3388:	00c78023          	sb	a2,0(a5)
            out++;
    338c:	00068413          	mv	s0,a3
            s_emit[out] = c;
            out++;
        }

        /* 到这里这个源字节才算真正被消费掉，推进读指针。*/
        s_tail = (s_tail + 1U) & (APP_LOG_RING_SIZE - 1U);
    3390:	8c01a783          	lw	a5,-1856(gp) # 9f00 <s_tail>
    3394:	00178793          	addi	a5,a5,1
    3398:	3ff7f793          	andi	a5,a5,1023
    339c:	8cf1a023          	sw	a5,-1856(gp) # 9f00 <s_tail>
        consumed++;
    33a0:	00170713          	addi	a4,a4,1
    while ((consumed < pending) && (out < APP_LOG_CHUNK)) {
    33a4:	02a77e63          	bgeu	a4,a0,33e0 <app_log_flush+0xa0>
    33a8:	01f00793          	li	a5,31
    33ac:	0287ea63          	bltu	a5,s0,33e0 <app_log_flush+0xa0>
        c = s_ring[s_tail];
    33b0:	8c01a683          	lw	a3,-1856(gp) # 9f00 <s_tail>
    33b4:	0000a7b7          	lui	a5,0xa
    33b8:	f8078793          	addi	a5,a5,-128 # 9f80 <s_ring>
    33bc:	00d787b3          	add	a5,a5,a3
    33c0:	0007c683          	lbu	a3,0(a5)
        if (c == '\n') {
    33c4:	00a00793          	li	a5,10
    33c8:	f8f68ce3          	beq	a3,a5,3360 <app_log_flush+0x20>
            s_emit[out] = c;
    33cc:	91c18793          	addi	a5,gp,-1764 # 9f5c <s_emit>
    33d0:	008787b3          	add	a5,a5,s0
    33d4:	00d78023          	sb	a3,0(a5)
            out++;
    33d8:	00140413          	addi	s0,s0,1
    33dc:	fb5ff06f          	j	3390 <app_log_flush+0x50>
    }

    /* 一个字节都没能发出（理论上只在 APP_LOG_CHUNK < 2 时才会发生），
     * 那就不要调打印函数，避免发一个空字符串白白停顿一次。*/
    if (out == 0U) {
    33e0:	02040463          	beqz	s0,3408 <app_log_flush+0xc8>
        return 0U;
    }

    s_emit[out] = '\0';
    33e4:	91c18793          	addi	a5,gp,-1764 # 9f5c <s_emit>
    33e8:	008787b3          	add	a5,a5,s0
    33ec:	00078023          	sb	zero,0(a5)

    /* 唯一的硬件调用点。这一句会让 CPU 停顿若干时间（见 app_log.h），
     * 所以它被放在主循环里、在服务完 uart1 之后。*/
    bsp_printf("%s", s_emit);
    33f0:	91c18593          	addi	a1,gp,-1764 # 9f5c <s_emit>
    33f4:	00008537          	lui	a0,0x8
    33f8:	b7c50513          	addi	a0,a0,-1156 # 7b7c <_data+0x4c>
    33fc:	d39ff0ef          	jal	3134 <bsp_printf>

    return out;
    3400:	0080006f          	j	3408 <app_log_flush+0xc8>
        return 0U;              /* 没东西可发，不碰硬件 */
    3404:	00050413          	mv	s0,a0
}
    3408:	00040513          	mv	a0,s0
    340c:	00c12083          	lw	ra,12(sp)
    3410:	00812403          	lw	s0,8(sp)
    3414:	01010113          	addi	sp,sp,16
    3418:	00008067          	ret

0000341c <uart_applyConfig>:
*          value using data length, parity, and stop bit settings from the configuration
*          structure, and writes this value to the UART frame configuration register.
*
******************************************************************************/
    static void uart_applyConfig(u32 reg, Uart_Config *config){
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
    341c:	00c5a783          	lw	a5,12(a1)
    static inline u32 read_u32(u32 address){
        return *((volatile u32*) address);
    }
    
    static inline void write_u32(u32 data, u32 address){
        *((volatile u32*) address) = data;
    3420:	00f52423          	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
    3424:	0005a783          	lw	a5,0(a1)
    3428:	fff78793          	addi	a5,a5,-1
    342c:	0045a703          	lw	a4,4(a1)
    3430:	00871713          	slli	a4,a4,0x8
    3434:	00e7e7b3          	or	a5,a5,a4
    3438:	0085a703          	lw	a4,8(a1)
    343c:	01071713          	slli	a4,a4,0x10
    3440:	00e7e7b3          	or	a5,a5,a4
    3444:	00f52623          	sw	a5,12(a0)
    }
    3448:	00008067          	ret

0000344c <clint_getTime>:
*          to guard against rollover. It checks if the high part remains unchanged
*          during the read operation to ensure consistency. The high and low parts
*          are then combined to form the 64-bit current time value.
*
******************************************************************************/
    static u64 clint_getTime(u32 p){
    344c:	00050693          	mv	a3,a0
    readReg_u32 (clint_getTimeHigh, CLINT_TIME_ADDR+4)
    3450:	0000c7b7          	lui	a5,0xc
    3454:	ffc78793          	addi	a5,a5,-4 # bffc <__freertos_irq_stack_top+0x6bc>
    3458:	00f687b3          	add	a5,a3,a5
        return *((volatile u32*) address);
    345c:	0007a583          	lw	a1,0(a5)
    readReg_u32 (clint_getTimeLow , CLINT_TIME_ADDR)
    3460:	0000c737          	lui	a4,0xc
    3464:	ff870713          	addi	a4,a4,-8 # bff8 <__freertos_irq_stack_top+0x6b8>
    3468:	00e68733          	add	a4,a3,a4
    346c:	00072503          	lw	a0,0(a4)
    3470:	0007a783          	lw	a5,0(a5)
    
        /* Likewise, must guard against rollover when reading */
        do {
            hi = clint_getTimeHigh(p);
            lo = clint_getTimeLow(p);
        } while (clint_getTimeHigh(p) != hi);
    3474:	fcb79ee3          	bne	a5,a1,3450 <clint_getTime+0x4>
    
        return (((u64)hi) << 32) | lo;
    }
    3478:	00008067          	ret

0000347c <bsp_init>:
    *   1. UART baudrate
    *   2. 
    */
////////////////////////////////////////////////////////////////////////////////
    static void bsp_init()
    {
    347c:	fe010113          	addi	sp,sp,-32
    3480:	00112e23          	sw	ra,28(sp)
        Uart_Config uartConfig;
        uartConfig.dataLength   = BITS_8;
    3484:	00800793          	li	a5,8
    3488:	00f12023          	sw	a5,0(sp)
        uartConfig.parity       = NONE;
    348c:	00012223          	sw	zero,4(sp)
        uartConfig.stop         = ONE;
    3490:	00012423          	sw	zero,8(sp)
        uartConfig.clockDivider = BSP_CLINT_HZ/(BSP_UART_BAUDRATE*BSP_UART_DATA_LEN)-1;
    3494:	03500793          	li	a5,53
    3498:	00f12623          	sw	a5,12(sp)
        uart_applyConfig(BSP_UART_TERMINAL, &uartConfig);    
    349c:	00010593          	mv	a1,sp
    34a0:	f8001537          	lui	a0,0xf8001
    34a4:	f79ff0ef          	jal	341c <uart_applyConfig>
    }
    34a8:	01c12083          	lw	ra,28(sp)
    34ac:	02010113          	addi	sp,sp,32
    34b0:	00008067          	ret

000034b4 <plic_claim>:
*          value from the calculated address, effectively claiming an interrupt
*          for the specified target in the PLIC.
*
******************************************************************************/
    static u32 plic_claim(u32 plic, u32 target){
        return read_u32(plic + PLIC_CLAIM_BASE + target*PLIC_CONTEXT_PER_HART);
    34b4:	00c59593          	slli	a1,a1,0xc
    34b8:	00a585b3          	add	a1,a1,a0
    34bc:	002007b7          	lui	a5,0x200
    34c0:	00478793          	addi	a5,a5,4 # 200004 <__freertos_irq_stack_top+0x1f46c4>
    34c4:	00f585b3          	add	a1,a1,a5
    34c8:	0005a503          	lw	a0,0(a1)
    }
    34cc:	00008067          	ret

000034d0 <plic_release>:
*          to the calculated address, effectively releasing the claimed interrupt
*          for the specified target in the PLIC.
*
******************************************************************************/
    static void plic_release(u32 plic, u32 target, u32 gateway){
        write_u32(gateway,plic + PLIC_CLAIM_BASE + target*PLIC_CONTEXT_PER_HART);
    34d0:	00c59593          	slli	a1,a1,0xc
    34d4:	00a585b3          	add	a1,a1,a0
    34d8:	002007b7          	lui	a5,0x200
    34dc:	00478793          	addi	a5,a5,4 # 200004 <__freertos_irq_stack_top+0x1f46c4>
    34e0:	00f585b3          	add	a1,a1,a5
        *((volatile u32*) address) = data;
    34e4:	00c5a023          	sw	a2,0(a1)
    }
    34e8:	00008067          	ret

000034ec <isr_init>:
    csr_write(mtvec, trap_entry);        /* 异常/中断入口，定义在 ../common/trap.S */
    34ec:	000057b7          	lui	a5,0x5
    34f0:	bb878793          	addi	a5,a5,-1096 # 4bb8 <trap_entry>
    34f4:	30579073          	csrw	mtvec,a5
    csr_set(mie, MIE_MEIE);
    34f8:	000017b7          	lui	a5,0x1
    34fc:	80078793          	addi	a5,a5,-2048 # 800 <CUSTOM2+0x7a5>
    3500:	3047a073          	csrs	mie,a5
    csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);
    3504:	300027f3          	csrr	a5,mstatus
    3508:	00002737          	lui	a4,0x2
    350c:	80870713          	addi	a4,a4,-2040 # 1808 <_ntoa_long_long+0x148>
    3510:	00e7e7b3          	or	a5,a5,a4
    3514:	30079073          	csrw	mstatus,a5
}
    3518:	00008067          	ret

0000351c <report_frame>:
static void report_frame(const frame_t *frame, const protocol_response_t *response){
    351c:	ff010113          	addi	sp,sp,-16
    3520:	00112623          	sw	ra,12(sp)
    3524:	00050613          	mv	a2,a0
    const uint32_t bit = (uint32_t)response->reason;
    3528:	0185a503          	lw	a0,24(a1)
    switch (response->reason) {
    352c:	00800793          	li	a5,8
    3530:	08a7e263          	bltu	a5,a0,35b4 <report_frame+0x98>
    3534:	00251793          	slli	a5,a0,0x2
    3538:	00008737          	lui	a4,0x8
    353c:	40870713          	addi	a4,a4,1032 # 8408 <pow10.0+0x50>
    3540:	00e787b3          	add	a5,a5,a4
    3544:	0007a783          	lw	a5,0(a5)
    3548:	00078067          	jr	a5
        app_log_once(bit, "rx cmd=0x%x (%s) len=%u -> not implemented, nak",
    354c:	00465703          	lhu	a4,4(a2)
    3550:	01c5a683          	lw	a3,28(a1)
    3554:	00164603          	lbu	a2,1(a2)
    3558:	000085b7          	lui	a1,0x8
    355c:	b8058593          	addi	a1,a1,-1152 # 7b80 <_data+0x50>
    3560:	d79ff0ef          	jal	32d8 <app_log_once>
}
    3564:	00c12083          	lw	ra,12(sp)
    3568:	01010113          	addi	sp,sp,16
    356c:	00008067          	ret
        app_log_once(bit, "rx cmd=0x%x unknown, nak", (uint32_t)frame->command);
    3570:	00164603          	lbu	a2,1(a2)
    3574:	000085b7          	lui	a1,0x8
    3578:	bb058593          	addi	a1,a1,-1104 # 7bb0 <_data+0x80>
    357c:	d5dff0ef          	jal	32d8 <app_log_once>
        break;
    3580:	fe5ff06f          	j	3564 <report_frame+0x48>
        app_log_once(bit, "rx cmd=0x%x (%s) len=%u wrong, nak",
    3584:	00465703          	lhu	a4,4(a2)
    3588:	01c5a683          	lw	a3,28(a1)
    358c:	00164603          	lbu	a2,1(a2)
    3590:	000085b7          	lui	a1,0x8
    3594:	bcc58593          	addi	a1,a1,-1076 # 7bcc <_data+0x9c>
    3598:	d41ff0ef          	jal	32d8 <app_log_once>
        break;
    359c:	fc9ff06f          	j	3564 <report_frame+0x48>
        app_log_once(bit, "rx cmd=0x%x bad type, nak", (uint32_t)frame->command);
    35a0:	00164603          	lbu	a2,1(a2)
    35a4:	000085b7          	lui	a1,0x8
    35a8:	bf058593          	addi	a1,a1,-1040 # 7bf0 <_data+0xc0>
    35ac:	d2dff0ef          	jal	32d8 <app_log_once>
        break;
    35b0:	fb5ff06f          	j	3564 <report_frame+0x48>
        app_log_once(bit, "rx cmd=0x%x crc/footer bad -> no-ack",
    35b4:	00164603          	lbu	a2,1(a2)
    35b8:	000085b7          	lui	a1,0x8
    35bc:	c0c58593          	addi	a1,a1,-1012 # 7c0c <_data+0xdc>
    35c0:	d19ff0ef          	jal	32d8 <app_log_once>
}
    35c4:	fa1ff06f          	j	3564 <report_frame+0x48>

000035c8 <poll_rx_loss>:
{
    35c8:	ff010113          	addi	sp,sp,-16
    35cc:	00112623          	sw	ra,12(sp)
    35d0:	00812423          	sw	s0,8(sp)
    uint32_t ring_drop = proto_uart_rx_dropped();
    35d4:	758000ef          	jal	3d2c <proto_uart_rx_dropped>
    35d8:	00050413          	mv	s0,a0
    uint32_t fifo_ovf  = proto_uart_fifo_overflow();
    35dc:	758000ef          	jal	3d34 <proto_uart_fifo_overflow>
    35e0:	00050693          	mv	a3,a0
    if ((ring_drop != s_ring_drop_seen) || (fifo_ovf != s_fifo_ovf_seen)) {
    35e4:	8cc1a783          	lw	a5,-1844(gp) # 9f0c <s_ring_drop_seen>
    35e8:	00879663          	bne	a5,s0,35f4 <poll_rx_loss+0x2c>
    35ec:	8c81a783          	lw	a5,-1848(gp) # 9f08 <s_fifo_ovf_seen>
    35f0:	02a78063          	beq	a5,a0,3610 <poll_rx_loss+0x48>
        s_ring_drop_seen = ring_drop;
    35f4:	8c81a623          	sw	s0,-1844(gp) # 9f0c <s_ring_drop_seen>
        s_fifo_ovf_seen = fifo_ovf;
    35f8:	8cd1a423          	sw	a3,-1848(gp) # 9f08 <s_fifo_ovf_seen>
        app_log_once(ONCE_BIT_RX_DROPPED,
    35fc:	00040613          	mv	a2,s0
    3600:	000085b7          	lui	a1,0x8
    3604:	c3458593          	addi	a1,a1,-972 # 7c34 <_data+0x104>
    3608:	01000513          	li	a0,16
    360c:	ccdff0ef          	jal	32d8 <app_log_once>
}
    3610:	00c12083          	lw	ra,12(sp)
    3614:	00812403          	lw	s0,8(sp)
    3618:	01010113          	addi	sp,sp,16
    361c:	00008067          	ret

00003620 <log_stats>:
{
    3620:	fc010113          	addi	sp,sp,-64
    3624:	02112e23          	sw	ra,60(sp)
    3628:	02812c23          	sw	s0,56(sp)
    362c:	02912a23          	sw	s1,52(sp)
    3630:	03212823          	sw	s2,48(sp)
    3634:	03312623          	sw	s3,44(sp)
    3638:	03412423          	sw	s4,40(sp)
    363c:	03512223          	sw	s5,36(sp)
    3640:	03612023          	sw	s6,32(sp)
    3644:	01712e23          	sw	s7,28(sp)
    app_log("stats: frames=%u accepted=%u bad=%u other=%u bad_len=%u "
    3648:	8f41a983          	lw	s3,-1804(gp) # 9f34 <s_frames_processed>
    364c:	d4018793          	addi	a5,gp,-704 # a380 <s_stats>
    3650:	0007aa03          	lw	s4,0(a5)
    3654:	0047aa83          	lw	s5,4(a5)
    3658:	0087ab03          	lw	s6,8(a5)
    365c:	d4c18793          	addi	a5,gp,-692 # a38c <s_parser>
    3660:	0107ab83          	lw	s7,16(a5)
    3664:	6c8000ef          	jal	3d2c <proto_uart_rx_dropped>
    3668:	00050413          	mv	s0,a0
    366c:	6c8000ef          	jal	3d34 <proto_uart_fifo_overflow>
    3670:	00050493          	mv	s1,a0
    3674:	c21ff0ef          	jal	3294 <app_log_dropped>
    3678:	00a12023          	sw	a0,0(sp)
    367c:	00048893          	mv	a7,s1
    3680:	00040813          	mv	a6,s0
    3684:	000b8793          	mv	a5,s7
    3688:	000b0713          	mv	a4,s6
    368c:	000a8693          	mv	a3,s5
    3690:	000a0613          	mv	a2,s4
    3694:	00098593          	mv	a1,s3
    3698:	00008537          	lui	a0,0x8
    369c:	c7050513          	addi	a0,a0,-912 # 7c70 <_data+0x140>
    36a0:	bfdff0ef          	jal	329c <app_log>
    s_reported_frames = s_frames_processed;
    36a4:	8f41a703          	lw	a4,-1804(gp) # 9f34 <s_frames_processed>
    36a8:	8ce1aa23          	sw	a4,-1836(gp) # 9f14 <s_reported_frames>
}
    36ac:	03c12083          	lw	ra,60(sp)
    36b0:	03812403          	lw	s0,56(sp)
    36b4:	03412483          	lw	s1,52(sp)
    36b8:	03012903          	lw	s2,48(sp)
    36bc:	02c12983          	lw	s3,44(sp)
    36c0:	02812a03          	lw	s4,40(sp)
    36c4:	02412a83          	lw	s5,36(sp)
    36c8:	02012b03          	lw	s6,32(sp)
    36cc:	01c12b83          	lw	s7,28(sp)
    36d0:	04010113          	addi	sp,sp,64
    36d4:	00008067          	ret

000036d8 <handle_frame>:
static void handle_frame(const frame_t *frame){
    36d8:	fb010113          	addi	sp,sp,-80
    36dc:	04112623          	sw	ra,76(sp)
    36e0:	04812423          	sw	s0,72(sp)
    36e4:	04912223          	sw	s1,68(sp)
    36e8:	00050413          	mv	s0,a0
    ack_len = osd_engine_handle(&s_stats, frame, &response, ack);
    36ec:	00c10693          	addi	a3,sp,12
    36f0:	02010613          	addi	a2,sp,32
    36f4:	00050593          	mv	a1,a0
    36f8:	d4018513          	addi	a0,gp,-704 # a380 <s_stats>
    36fc:	7a1000ef          	jal	469c <osd_engine_handle>
    3700:	00050493          	mv	s1,a0
    s_frames_processed++;
    3704:	8f41a783          	lw	a5,-1804(gp) # 9f34 <s_frames_processed>
    3708:	00178793          	addi	a5,a5,1
    370c:	8ef1aa23          	sw	a5,-1804(gp) # 9f34 <s_frames_processed>
    report_frame(frame, &response);
    3710:	02010593          	addi	a1,sp,32
    3714:	00040513          	mv	a0,s0
    3718:	e05ff0ef          	jal	351c <report_frame>
    if (ack_len != 0U) {
    371c:	02049463          	bnez	s1,3744 <handle_frame+0x6c>
    poll_rx_loss();
    3720:	ea9ff0ef          	jal	35c8 <poll_rx_loss>
    if ((s_frames_processed % STATS_INTERVAL) == 0U) {
    3724:	8f41a783          	lw	a5,-1804(gp) # 9f34 <s_frames_processed>
    3728:	03f7f793          	andi	a5,a5,63
    372c:	02078463          	beqz	a5,3754 <handle_frame+0x7c>
}
    3730:	04c12083          	lw	ra,76(sp)
    3734:	04812403          	lw	s0,72(sp)
    3738:	04412483          	lw	s1,68(sp)
    373c:	05010113          	addi	sp,sp,80
    3740:	00008067          	ret
        (void)proto_uart_write(ack, ack_len);
    3744:	00048593          	mv	a1,s1
    3748:	00c10513          	addi	a0,sp,12
    374c:	6ac000ef          	jal	3df8 <proto_uart_write>
    3750:	fd1ff06f          	j	3720 <handle_frame+0x48>
        log_stats();
    3754:	ecdff0ef          	jal	3620 <log_stats>
}
    3758:	fd9ff06f          	j	3730 <handle_frame+0x58>

0000375c <isr_routine>:
void isr_routine(){
    375c:	ff010113          	addi	sp,sp,-16
    3760:	00112623          	sw	ra,12(sp)
    3764:	00812423          	sw	s0,8(sp)
    while ((claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)) != 0U) {
    3768:	0180006f          	j	3780 <isr_routine+0x24>
            proto_uart_isr();      /* 把收到的字节搬进接收环 */
    376c:	5fc000ef          	jal	3d68 <proto_uart_isr>
        plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim);
    3770:	00040613          	mv	a2,s0
    3774:	00000593          	li	a1,0
    3778:	f8c00537          	lui	a0,0xf8c00
    377c:	d55ff0ef          	jal	34d0 <plic_release>
    while ((claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)) != 0U) {
    3780:	00000593          	li	a1,0
    3784:	f8c00537          	lui	a0,0xf8c00
    3788:	d2dff0ef          	jal	34b4 <plic_claim>
    378c:	00050413          	mv	s0,a0
    3790:	00050e63          	beqz	a0,37ac <isr_routine+0x50>
        if (claim == SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT) {
    3794:	00200793          	li	a5,2
    3798:	fcf40ae3          	beq	s0,a5,376c <isr_routine+0x10>
            s_isr_unknown_source++;
    379c:	8e01a783          	lw	a5,-1824(gp) # 9f20 <s_isr_unknown_source>
    37a0:	00178793          	addi	a5,a5,1
    37a4:	8ef1a023          	sw	a5,-1824(gp) # 9f20 <s_isr_unknown_source>
    37a8:	fc9ff06f          	j	3770 <isr_routine+0x14>
}
    37ac:	00c12083          	lw	ra,12(sp)
    37b0:	00812403          	lw	s0,8(sp)
    37b4:	01010113          	addi	sp,sp,16
    37b8:	00008067          	ret

000037bc <trap>:
void trap(){
    37bc:	ff010113          	addi	sp,sp,-16
    37c0:	00112623          	sw	ra,12(sp)
    int32_t mcause = csr_read(mcause);   /* 读 CSR 寄存器，得到异常/中断原因 */
    37c4:	342025f3          	csrr	a1,mcause
    int32_t cause     = mcause & 0xF;    /* 低 4 位 → 具体原因编号 */
    37c8:	00f5f793          	andi	a5,a1,15
    if (interrupt) {
    37cc:	0205c663          	bltz	a1,37f8 <trap+0x3c>
    if (cause == CAUSE_BREAKPOINT) {
    37d0:	00300713          	li	a4,3
    37d4:	04e78263          	beq	a5,a4,3818 <trap+0x5c>
    s_unexpected_exceptions++;
    37d8:	8e81a783          	lw	a5,-1816(gp) # 9f28 <s_unexpected_exceptions>
    37dc:	00178793          	addi	a5,a5,1
    37e0:	8ef1a423          	sw	a5,-1816(gp) # 9f28 <s_unexpected_exceptions>
    if (!s_unexpected_exception_logged) {
    37e4:	8e41c783          	lbu	a5,-1820(gp) # 9f24 <s_unexpected_exception_logged>
    37e8:	04078063          	beqz	a5,3828 <trap+0x6c>
}
    37ec:	00c12083          	lw	ra,12(sp)
    37f0:	01010113          	addi	sp,sp,16
    37f4:	00008067          	ret
        if (cause == CAUSE_MACHINE_EXTERNAL) {
    37f8:	00b00713          	li	a4,11
    37fc:	00e78a63          	beq	a5,a4,3810 <trap+0x54>
            s_unexpected_interrupts++;
    3800:	8ec1a783          	lw	a5,-1812(gp) # 9f2c <s_unexpected_interrupts>
    3804:	00178793          	addi	a5,a5,1
    3808:	8ef1a623          	sw	a5,-1812(gp) # 9f2c <s_unexpected_interrupts>
        return;
    380c:	fe1ff06f          	j	37ec <trap+0x30>
            isr_routine();
    3810:	f4dff0ef          	jal	375c <isr_routine>
    3814:	fd9ff06f          	j	37ec <trap+0x30>
        s_semihosting_breakpoints++;
    3818:	8f01a783          	lw	a5,-1808(gp) # 9f30 <s_semihosting_breakpoints>
    381c:	00178793          	addi	a5,a5,1
    3820:	8ef1a823          	sw	a5,-1808(gp) # 9f30 <s_semihosting_breakpoints>
        return;
    3824:	fc9ff06f          	j	37ec <trap+0x30>
        s_unexpected_exception_logged = 1;
    3828:	00100713          	li	a4,1
    382c:	8ee18223          	sb	a4,-1820(gp) # 9f24 <s_unexpected_exception_logged>
        app_log("trap: unexpected exception mcause=0x%x", (uint32_t)mcause);
    3830:	00008537          	lui	a0,0x8
    3834:	cd050513          	addi	a0,a0,-816 # 7cd0 <_data+0x1a0>
    3838:	a65ff0ef          	jal	329c <app_log>
    383c:	fb1ff06f          	j	37ec <trap+0x30>

00003840 <start_frame>:
*       好处是链接器不会为它生成对外符号，也不怕和别的文件里的同名函数冲突。
*       本文件里所有辅助函数都用 static。
******************************************************************************/
static int start_frame(frame_parser_t *parser, uint8_t byte)
{
    if (byte != FRAME_HEADER) {
    3840:	0bb00793          	li	a5,187
    3844:	02f59663          	bne	a1,a5,3870 <start_frame+0x30>
        return 0;   /* 不是帧头，当噪声丢掉，继续等 */
    }
    parser->state = ST_LEN_H;
    3848:	00100793          	li	a5,1
    384c:	00f50023          	sb	a5,0(a0)
    parser->body_length = 0U;
    3850:	00051123          	sh	zero,2(a0)
    parser->body_index = 0U;
    3854:	00051223          	sh	zero,4(a0)
    parser->body_crc = 0U;
    3858:	00051323          	sh	zero,6(a0)
    parser->recv_crc = 0U;
    385c:	00051423          	sh	zero,8(a0)
    parser->category = 0U;
    3860:	00050523          	sb	zero,10(a0)
    parser->command = 0U;
    3864:	000505a3          	sb	zero,11(a0)
    parser->type = 0U;
    3868:	00050623          	sb	zero,12(a0)
    parser->payload_len = 0U;
    386c:	00051a23          	sh	zero,20(a0)
    return 0;
}
    3870:	00000513          	li	a0,0
    3874:	00008067          	ret

00003878 <frame_parser_init>:
    if (parser == 0) {
    3878:	04050863          	beqz	a0,38c8 <frame_parser_init+0x50>
    parser->state = ST_HEADER;
    387c:	00050023          	sb	zero,0(a0)
    parser->body_length = 0U;
    3880:	00051123          	sh	zero,2(a0)
    parser->body_index = 0U;
    3884:	00051223          	sh	zero,4(a0)
    parser->body_crc = 0U;
    3888:	00051323          	sh	zero,6(a0)
    parser->recv_crc = 0U;
    388c:	00051423          	sh	zero,8(a0)
    parser->category = 0U;
    3890:	00050523          	sb	zero,10(a0)
    parser->command = 0U;
    3894:	000505a3          	sb	zero,11(a0)
    parser->type = 0U;
    3898:	00050623          	sb	zero,12(a0)
    parser->bad_length_count = 0U;
    389c:	00052823          	sw	zero,16(a0)
    parser->payload_len = 0U;
    38a0:	00051a23          	sh	zero,20(a0)
        for (i = 0U; i < FRAME_PAYLOAD_MAX; i++) {
    38a4:	00000793          	li	a5,0
    38a8:	0180006f          	j	38c0 <frame_parser_init+0x48>
            parser->payload[i] = 0U;
    38ac:	00f50733          	add	a4,a0,a5
    38b0:	00070b23          	sb	zero,22(a4)
        for (i = 0U; i < FRAME_PAYLOAD_MAX; i++) {
    38b4:	00178793          	addi	a5,a5,1
    38b8:	01079793          	slli	a5,a5,0x10
    38bc:	0107d793          	srli	a5,a5,0x10
    38c0:	00b00713          	li	a4,11
    38c4:	fef774e3          	bgeu	a4,a5,38ac <frame_parser_init+0x34>
}
    38c8:	00008067          	ret

000038cc <frame_parser_feed>:
*       break 导致穿透到下一个 case"这个 C 语言的经典坑；二是每个状态的
*       处理路径互不影响，读代码时不用往回看。
******************************************************************************/
int frame_parser_feed(frame_parser_t *parser, uint8_t byte, frame_t *out)
{
    if ((parser == 0) || (out == 0)) {
    38cc:	22050063          	beqz	a0,3aec <frame_parser_feed+0x220>
{
    38d0:	ff010113          	addi	sp,sp,-16
    38d4:	00112623          	sw	ra,12(sp)
    38d8:	00812423          	sw	s0,8(sp)
    38dc:	00912223          	sw	s1,4(sp)
    38e0:	00050413          	mv	s0,a0
    38e4:	00058493          	mv	s1,a1
    if ((parser == 0) || (out == 0)) {
    38e8:	20060663          	beqz	a2,3af4 <frame_parser_feed+0x228>
        return 0;
    }

    switch (parser->state) {
    38ec:	00054783          	lbu	a5,0(a0)
    38f0:	00500713          	li	a4,5
    38f4:	14f76663          	bltu	a4,a5,3a40 <frame_parser_feed+0x174>
    38f8:	00279793          	slli	a5,a5,0x2
    38fc:	00008737          	lui	a4,0x8
    3900:	42c70713          	addi	a4,a4,1068 # 842c <pow10.0+0x74>
    3904:	00e787b3          	add	a5,a5,a4
    3908:	0007a783          	lw	a5,0(a5)
    390c:	00078067          	jr	a5
    /* --- 等帧头：帧与帧之间的所有噪声都在这里被自然丢弃 --- */
    case ST_HEADER:
        return start_frame(parser, byte);
    3910:	f31ff0ef          	jal	3840 <start_frame>
    3914:	1e40006f          	j	3af8 <frame_parser_feed+0x22c>

    /* --- 长度高字节：先暂存到 body_length 的高 8 位 --- */
    case ST_LEN_H:
        /* (uint16_t)byte << 8 把这一字节挪到高字节，低字节此时还是 0。
         * 用 = 而不是 |= 是刻意的：这里直接覆盖，避免上一帧的残留值混进来。*/
        parser->body_length = (uint16_t)byte << 8;
    3918:	00859493          	slli	s1,a1,0x8
    391c:	00951123          	sh	s1,2(a0)
        parser->state = ST_LEN_L;
    3920:	00200793          	li	a5,2
    3924:	00f50023          	sb	a5,0(a0)
        return 0;
    3928:	00000513          	li	a0,0
    392c:	1cc0006f          	j	3af8 <frame_parser_feed+0x22c>

    /* --- 长度低字节：凑成完整长度，并立刻检查是否合法 --- */
    case ST_LEN_L:
        /* |= 把低字节补上，此时 body_length 才是完整的 16 位长度。*/
        parser->body_length |= (uint16_t)byte;
    3930:	00255783          	lhu	a5,2(a0)
    3934:	00f5e7b3          	or	a5,a1,a5
    3938:	00f51123          	sh	a5,2(a0)

        if ((parser->body_length < FRAME_BODY_LEN_MIN) ||
    393c:	ffd78793          	addi	a5,a5,-3
    3940:	01079793          	slli	a5,a5,0x10
    3944:	0107d793          	srli	a5,a5,0x10
    3948:	00001737          	lui	a4,0x1
    394c:	38470713          	addi	a4,a4,900 # 1384 <_out_rev+0x54>
    3950:	00f76c63          	bltu	a4,a5,3968 <frame_parser_feed+0x9c>
             * 没成为一个帧。*/
            parser->bad_length_count++;
            parser->state = ST_HEADER;
            return 0;
        }
        parser->body_index = 0U;
    3954:	00051223          	sh	zero,4(a0)
        parser->state = ST_BODY;
    3958:	00300793          	li	a5,3
    395c:	00f50023          	sb	a5,0(a0)
        return 0;
    3960:	00000513          	li	a0,0
    3964:	1940006f          	j	3af8 <frame_parser_feed+0x22c>
            parser->bad_length_count++;
    3968:	01052783          	lw	a5,16(a0)
    396c:	00178793          	addi	a5,a5,1
    3970:	00f52823          	sw	a5,16(a0)
            parser->state = ST_HEADER;
    3974:	00050023          	sb	zero,0(a0)
            return 0;
    3978:	00000513          	li	a0,0
    397c:	17c0006f          	j	3af8 <frame_parser_feed+0x22c>

    /* --- body：边收边算 CRC，同时把前 3 个字节记下来 --- */
    case ST_BODY:
        parser->body_crc = crc16_ccitt_update(parser->body_crc, byte);
    3980:	00655503          	lhu	a0,6(a0)
    3984:	508000ef          	jal	3e8c <crc16_ccitt_update>
    3988:	00a41323          	sh	a0,6(s0)

        /* 前 3 个字节是固定的头结构，第 3 个 if 之后的都是 payload。
         * 注意这里**只记录、不校验**：大类是路由字段，合法性由上层判断
         * （见 frame.h 里"大类是路由字段，不是格式标记"的说明）。
         * 只有"类型"这一位在帧尾阶段会做校验。*/
        if (parser->body_index == 0U) {
    398c:	00445783          	lhu	a5,4(s0)
    3990:	02079663          	bnez	a5,39bc <frame_parser_feed+0xf0>
            parser->category = byte;
    3994:	00940523          	sb	s1,10(s0)
        }

        /* 收到第 body_length 个字节时，body 结束，转去收 CRC。
         * body_index 从 0 计，所以最后一个字节的下标是 body_length-1。
         * 这里的减法已经安全：长度在 ST_LEN_L 阶段校验过 >= 3。*/
        if (parser->body_index == (uint16_t)(parser->body_length - 1U)) {
    3998:	00245703          	lhu	a4,2(s0)
    399c:	fff70713          	addi	a4,a4,-1
    39a0:	01071713          	slli	a4,a4,0x10
    39a4:	01075713          	srli	a4,a4,0x10
    39a8:	04e78a63          	beq	a5,a4,39fc <frame_parser_feed+0x130>
            parser->state = ST_CRC_H;
        } else {
            parser->body_index++;
    39ac:	00178793          	addi	a5,a5,1
    39b0:	00f41223          	sh	a5,4(s0)
        }
        return 0;
    39b4:	00000513          	li	a0,0
    39b8:	1400006f          	j	3af8 <frame_parser_feed+0x22c>
        } else if (parser->body_index == 1U) {
    39bc:	00100713          	li	a4,1
    39c0:	02e78663          	beq	a5,a4,39ec <frame_parser_feed+0x120>
        } else if (parser->body_index == 2U) {
    39c4:	00200713          	li	a4,2
    39c8:	02e78663          	beq	a5,a4,39f4 <frame_parser_feed+0x128>
            uint16_t k = (uint16_t)(parser->body_index - 3U);
    39cc:	ffd78713          	addi	a4,a5,-3
    39d0:	01071713          	slli	a4,a4,0x10
    39d4:	01075713          	srli	a4,a4,0x10
            if (k < FRAME_PAYLOAD_MAX) {
    39d8:	00b00693          	li	a3,11
    39dc:	fae6eee3          	bltu	a3,a4,3998 <frame_parser_feed+0xcc>
                parser->payload[k] = byte;
    39e0:	00e40733          	add	a4,s0,a4
    39e4:	00970b23          	sb	s1,22(a4)
    39e8:	fb1ff06f          	j	3998 <frame_parser_feed+0xcc>
            parser->command = byte;
    39ec:	009405a3          	sb	s1,11(s0)
    39f0:	fa9ff06f          	j	3998 <frame_parser_feed+0xcc>
            parser->type = byte;
    39f4:	00940623          	sb	s1,12(s0)
    39f8:	fa1ff06f          	j	3998 <frame_parser_feed+0xcc>
            parser->state = ST_CRC_H;
    39fc:	00400793          	li	a5,4
    3a00:	00f40023          	sb	a5,0(s0)
        return 0;
    3a04:	00000513          	li	a0,0
    3a08:	0f00006f          	j	3af8 <frame_parser_feed+0x22c>

    /* --- CRC 高字节 --- */
    case ST_CRC_H:
        parser->recv_crc = (uint16_t)byte << 8;
    3a0c:	00859493          	slli	s1,a1,0x8
    3a10:	00951423          	sh	s1,8(a0)
        parser->state = ST_CRC_L;
    3a14:	00500793          	li	a5,5
    3a18:	00f50023          	sb	a5,0(a0)
        return 0;
    3a1c:	00000513          	li	a0,0
    3a20:	0d80006f          	j	3af8 <frame_parser_feed+0x22c>

    /* --- CRC 低字节：凑成完整 CRC，转去收帧尾 --- */
    case ST_CRC_L:
        parser->recv_crc |= (uint16_t)byte;
    3a24:	00855783          	lhu	a5,8(a0)
    3a28:	00f5e7b3          	or	a5,a1,a5
    3a2c:	00f51423          	sh	a5,8(a0)
        parser->state = ST_FOOTER;
    3a30:	00600793          	li	a5,6
    3a34:	00f50023          	sb	a5,0(a0)
        return 0;
    3a38:	00000513          	li	a0,0
    3a3c:	0bc0006f          	j	3af8 <frame_parser_feed+0x22c>
    default:
        /* default 和 ST_FOOTER 走同一段代码，是防御性写法：万一 state 被
         * 内存踩坏成了非法值，也只会当成"帧尾"处理并立即复位回 ST_HEADER，
         * 不会卡死在非法状态里。*/

        out->category    = parser->category;
    3a40:	00a54783          	lbu	a5,10(a0)
    3a44:	00f60023          	sb	a5,0(a2)
        out->command     = parser->command;
    3a48:	00b54783          	lbu	a5,11(a0)
    3a4c:	00f600a3          	sb	a5,1(a2)
        out->type        = parser->type;
    3a50:	00c54783          	lbu	a5,12(a0)
    3a54:	00f60123          	sb	a5,2(a2)
        out->body_length = parser->body_length;
    3a58:	00255783          	lhu	a5,2(a0)
    3a5c:	00f61223          	sh	a5,4(a2)

        /* payload_len 是"帧里声明有多少"（body_length 减去 3 字节 body 头），
         * 可能大于窗口容量；payload[] 里只有前 min(payload_len, 12) 个字节有效。
         * 长度在 ST_LEN_L 阶段校验过 >= 3，所以这里的减法不会下溢。*/
        out->payload_len = (uint16_t)(parser->body_length - 3U);
    3a60:	ffd78793          	addi	a5,a5,-3
    3a64:	00f61523          	sh	a5,10(a2)
        {
            uint16_t i;
            for (i = 0U; i < FRAME_PAYLOAD_MAX; i++) {
    3a68:	00000793          	li	a5,0
    3a6c:	0200006f          	j	3a8c <frame_parser_feed+0x1c0>
                out->payload[i] = parser->payload[i];
    3a70:	00f40733          	add	a4,s0,a5
    3a74:	01674683          	lbu	a3,22(a4)
    3a78:	00f60733          	add	a4,a2,a5
    3a7c:	00d70623          	sb	a3,12(a4)
            for (i = 0U; i < FRAME_PAYLOAD_MAX; i++) {
    3a80:	00178793          	addi	a5,a5,1
    3a84:	01079793          	slli	a5,a5,0x10
    3a88:	0107d793          	srli	a5,a5,0x10
    3a8c:	00b00713          	li	a4,11
    3a90:	fef770e3          	bgeu	a4,a5,3a70 <frame_parser_feed+0x1a4>
        }

        /* 三个布尔标志都写成 `? 1U : 0U` 而不是直接赋值比较表达式的结果。
         * 因为 C 里比较运算符的结果是 int 类型的 1/0，直接赋给 uint8_t 字段
         * 虽然没问题，但显式写出来能保证字段里只可能是 0 或 1。*/
        out->crc_ok      = (parser->recv_crc == parser->body_crc) ? 1U : 0U;
    3a94:	00845703          	lhu	a4,8(s0)
    3a98:	00645783          	lhu	a5,6(s0)
    3a9c:	02f70c63          	beq	a4,a5,3ad4 <frame_parser_feed+0x208>
    3aa0:	00000793          	li	a5,0
    3aa4:	00f60323          	sb	a5,6(a2)
        out->footer_ok   = (byte == FRAME_FOOTER) ? 1U : 0U;
    3aa8:	0aa00793          	li	a5,170
    3aac:	02f48863          	beq	s1,a5,3adc <frame_parser_feed+0x210>
    3ab0:	00000793          	li	a5,0
    3ab4:	00f603a3          	sb	a5,7(a2)
        /* 格式校验只有这一条：命令帧的类型必须是"上位机写"。
         * 大类**不在这里校验**——它是路由字段，变倍/热点/UI 的大类都是合法的，
         * 只是不该由本应用处理（在上层分流）。*/
        out->format_ok   = (parser->type == FRAME_TYPE_WRITE) ? 1U : 0U;
    3ab8:	00c44783          	lbu	a5,12(s0)
    3abc:	02079463          	bnez	a5,3ae4 <frame_parser_feed+0x218>
    3ac0:	00100793          	li	a5,1
    3ac4:	00f60423          	sb	a5,8(a2)

        /* 无论这一帧是好是坏，解析器都回到等帧头，准备接下一帧。
         * 这样"坏帧"不会让解析器停摆——上位机可以继续发下一条命令。*/
        parser->state = ST_HEADER;
    3ac8:	00040023          	sb	zero,0(s0)
        return 1;
    3acc:	00100513          	li	a0,1
    3ad0:	0280006f          	j	3af8 <frame_parser_feed+0x22c>
        out->crc_ok      = (parser->recv_crc == parser->body_crc) ? 1U : 0U;
    3ad4:	00100793          	li	a5,1
    3ad8:	fcdff06f          	j	3aa4 <frame_parser_feed+0x1d8>
        out->footer_ok   = (byte == FRAME_FOOTER) ? 1U : 0U;
    3adc:	00100793          	li	a5,1
    3ae0:	fd5ff06f          	j	3ab4 <frame_parser_feed+0x1e8>
        out->format_ok   = (parser->type == FRAME_TYPE_WRITE) ? 1U : 0U;
    3ae4:	00000793          	li	a5,0
    3ae8:	fddff06f          	j	3ac4 <frame_parser_feed+0x1f8>
        return 0;
    3aec:	00000513          	li	a0,0
    }
}
    3af0:	00008067          	ret
        return 0;
    3af4:	00000513          	li	a0,0
}
    3af8:	00c12083          	lw	ra,12(sp)
    3afc:	00812403          	lw	s0,8(sp)
    3b00:	00412483          	lw	s1,4(sp)
    3b04:	01010113          	addi	sp,sp,16
    3b08:	00008067          	ret

00003b0c <uart_writeAvailability>:
        return *((volatile u32*) address);
    3b0c:	00452503          	lw	a0,4(a0)
        return (read_u32(reg + UART_STATUS) >> 16) & 0xFF;
    3b10:	01055513          	srli	a0,a0,0x10
    }
    3b14:	0ff57513          	zext.b	a0,a0
    3b18:	00008067          	ret

00003b1c <uart_readOccupancy>:
    3b1c:	00452503          	lw	a0,4(a0)
    }
    3b20:	01855513          	srli	a0,a0,0x18
    3b24:	00008067          	ret

00003b28 <uart_read>:
    static char uart_read(u32 reg){
    3b28:	ff010113          	addi	sp,sp,-16
    3b2c:	00112623          	sw	ra,12(sp)
    3b30:	00812423          	sw	s0,8(sp)
    3b34:	00050413          	mv	s0,a0
        while(uart_readOccupancy(reg) == 0);
    3b38:	00040513          	mv	a0,s0
    3b3c:	fe1ff0ef          	jal	3b1c <uart_readOccupancy>
    3b40:	fe050ce3          	beqz	a0,3b38 <uart_read+0x10>
    3b44:	00042503          	lw	a0,0(s0)
    }
    3b48:	0ff57513          	zext.b	a0,a0
    3b4c:	00c12083          	lw	ra,12(sp)
    3b50:	00812403          	lw	s0,8(sp)
    3b54:	01010113          	addi	sp,sp,16
    3b58:	00008067          	ret

00003b5c <uart_applyConfig>:
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
    3b5c:	00c5a783          	lw	a5,12(a1)
        *((volatile u32*) address) = data;
    3b60:	00f52423          	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
    3b64:	0005a783          	lw	a5,0(a1)
    3b68:	fff78793          	addi	a5,a5,-1
    3b6c:	0045a703          	lw	a4,4(a1)
    3b70:	00871713          	slli	a4,a4,0x8
    3b74:	00e7e7b3          	or	a5,a5,a4
    3b78:	0085a703          	lw	a4,8(a1)
    3b7c:	01071713          	slli	a4,a4,0x10
    3b80:	00e7e7b3          	or	a5,a5,a4
    3b84:	00f52623          	sw	a5,12(a0)
    }
    3b88:	00008067          	ret

00003b8c <uart_status_read>:
        return *((volatile u32*) address);
    3b8c:	00452503          	lw	a0,4(a0)
*
******************************************************************************/    
    static u32 uart_status_read(u32 reg)
     {
    	 return read_u32(reg+UART_STATUS);
     }
    3b90:	00008067          	ret

00003b94 <uart_status_write>:
        *((volatile u32*) address) = data;
    3b94:	00b52223          	sw	a1,4(a0)
*
******************************************************************************/
    static void uart_status_write(u32 reg, char data)
    {
    	write_u32(data ,reg+UART_STATUS);
    }
    3b98:	00008067          	ret

00003b9c <uart_RX_NotemptyInterruptEna>:
*          clears the second least significant bit to disable the RX not empty interrupt,
*          or sets it to enable the RX not empty interrupt based on the provided flag,
*          and then writes the modified value back to the UART status register.
*
******************************************************************************/
    static void uart_RX_NotemptyInterruptEna(u32 reg, char Ena){
    3b9c:	ff010113          	addi	sp,sp,-16
    3ba0:	00112623          	sw	ra,12(sp)
    3ba4:	00812423          	sw	s0,8(sp)
    3ba8:	00912223          	sw	s1,4(sp)
    3bac:	00050493          	mv	s1,a0
    3bb0:	00058413          	mv	s0,a1
    	uart_status_write(reg,(uart_status_read(reg) & 0xFFFFFFFD) | (Ena << 1));	
    3bb4:	fd9ff0ef          	jal	3b8c <uart_status_read>
    3bb8:	0fd57593          	andi	a1,a0,253
    3bbc:	00141413          	slli	s0,s0,0x1
    3bc0:	0ff47413          	zext.b	s0,s0
    3bc4:	0085e5b3          	or	a1,a1,s0
    3bc8:	00048513          	mv	a0,s1
    3bcc:	fc9ff0ef          	jal	3b94 <uart_status_write>
    }
    3bd0:	00c12083          	lw	ra,12(sp)
    3bd4:	00812403          	lw	s0,8(sp)
    3bd8:	00412483          	lw	s1,4(sp)
    3bdc:	01010113          	addi	sp,sp,16
    3be0:	00008067          	ret

00003be4 <plic_set_priority>:
        write_u32(priority, plic + PLIC_PRIORITY_BASE + gateway*4);
    3be4:	00259593          	slli	a1,a1,0x2
    3be8:	00a585b3          	add	a1,a1,a0
    3bec:	00c5a023          	sw	a2,0(a1)
    }
    3bf0:	00008067          	ret

00003bf4 <plic_set_enable>:
        u32 word = plic + PLIC_ENABLE_BASE + target * PLIC_ENABLE_PER_HART + (gateway / 32 * 4);
    3bf4:	00759593          	slli	a1,a1,0x7
    3bf8:	00a585b3          	add	a1,a1,a0
    3bfc:	00565793          	srli	a5,a2,0x5
    3c00:	00279793          	slli	a5,a5,0x2
    3c04:	00f587b3          	add	a5,a1,a5
    3c08:	00002737          	lui	a4,0x2
    3c0c:	00e787b3          	add	a5,a5,a4
        u32 mask = 1 << (gateway % 32);
    3c10:	00100713          	li	a4,1
    3c14:	00c71633          	sll	a2,a4,a2
        if (enable)
    3c18:	00068a63          	beqz	a3,3c2c <plic_set_enable+0x38>
        return *((volatile u32*) address);
    3c1c:	0007a703          	lw	a4,0(a5)
            write_u32(read_u32(word) | mask, word);
    3c20:	00e66633          	or	a2,a2,a4
        *((volatile u32*) address) = data;
    3c24:	00c7a023          	sw	a2,0(a5)
    }
    3c28:	00008067          	ret
        return *((volatile u32*) address);
    3c2c:	0007a703          	lw	a4,0(a5)
            write_u32(read_u32(word) & ~mask, word);
    3c30:	fff64613          	not	a2,a2
    3c34:	00e67633          	and	a2,a2,a4
        *((volatile u32*) address) = data;
    3c38:	00c7a023          	sw	a2,0(a5)
    }
    3c3c:	00008067          	ret

00003c40 <plic_set_threshold>:
        write_u32(threshold, plic + PLIC_THRESHOLD_BASE + target*PLIC_CONTEXT_PER_HART);
    3c40:	00c59593          	slli	a1,a1,0xc
    3c44:	00a585b3          	add	a1,a1,a0
    3c48:	002007b7          	lui	a5,0x200
    3c4c:	00f585b3          	add	a1,a1,a5
    3c50:	00c5a023          	sw	a2,0(a1)
    }
    3c54:	00008067          	ret

00003c58 <proto_uart_init>:
* @note 调用顺序上，本函数要在 isr_init() 之前调用（见 main.c）：先把中断源
*       配好，再全局开中断。反过来的话，开中断后到中断源配置好之间可能出现
*       一个"中断已使能但没有正确处理程序"的窗口。
******************************************************************************/
void proto_uart_init(void)
{
    3c58:	fe010113          	addi	sp,sp,-32
    3c5c:	00112e23          	sw	ra,28(sp)
    Uart_Config config;

    config.dataLength   = BITS_8;   /* 8 位数据 */
    3c60:	00800793          	li	a5,8
    3c64:	00f12023          	sw	a5,0(sp)
    config.parity       = NONE;     /* 无校验 */
    3c68:	00012223          	sw	zero,4(sp)
    config.stop         = ONE;      /* 1 位停止位 */
    3c6c:	00012423          	sw	zero,8(sp)
    /* 分频系数 = 时钟频率 / (波特率 × 每字符位数) - 1
     * 这里的算式与 bsp.h 里 bsp_init() 的一字不差。*/
    config.clockDivider = BSP_CLINT_HZ / (BSP_UART_BAUDRATE * BSP_UART_DATA_LEN) - 1;
    3c70:	03500793          	li	a5,53
    3c74:	00f12623          	sw	a5,12(sp)

    uart_applyConfig(PROTO_UART_BASE, &config);
    3c78:	00010593          	mv	a1,sp
    3c7c:	f8002537          	lui	a0,0xf8002
    3c80:	eddff0ef          	jal	3b5c <uart_applyConfig>

    /* 清空接收环和计数。*/
    s_head = 0U;
    3c84:	9001a023          	sw	zero,-1792(gp) # 9f40 <s_head>
    s_tail = 0U;
    3c88:	8e01ae23          	sw	zero,-1796(gp) # 9f3c <s_tail>
    s_dropped = 0U;
    3c8c:	8e01ac23          	sw	zero,-1800(gp) # 9f38 <s_dropped>
    s_fifo_overflow_seen = 0U;
    3c90:	9001a223          	sw	zero,-1788(gp) # 9f44 <s_fifo_overflow_seen>
    3c94:	f80027b7          	lui	a5,0xf8002
    3c98:	00200713          	li	a4,2
    3c9c:	00e7a823          	sw	a4,16(a5) # f8002010 <__freertos_irq_stack_top+0xf7ff66d0>
    /* 上电时硬件里可能留有之前（比如复位前）的溢出标志，先清掉，
     * 否则第一份汇总就会报一个不属于本次运行的溢出。*/
    write_u32(UART_ERR_READ_OVERFLOW, PROTO_UART_BASE + UART_ERROR_REG);

    /* 使能"接收 FIFO 非空"中断：FIFO 里一有数据就产生中断。*/
    uart_RX_NotemptyInterruptEna(PROTO_UART_BASE, 1);
    3ca0:	00100593          	li	a1,1
    3ca4:	f8002537          	lui	a0,0xf8002
    3ca8:	ef5ff0ef          	jal	3b9c <uart_RX_NotemptyInterruptEna>

    /* 把该中断接到本核（CPU 0）上。
     * threshold = 0 表示"优先级高于 0 的中断都接受"，即全部接受。
     * 这三步（threshold / enable / priority）是 PLIC 的标准配置顺序。*/
    plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0);
    3cac:	00000613          	li	a2,0
    3cb0:	00000593          	li	a1,0
    3cb4:	f8c00537          	lui	a0,0xf8c00
    3cb8:	f89ff0ef          	jal	3c40 <plic_set_threshold>
    plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0,
    3cbc:	00100693          	li	a3,1
    3cc0:	00200613          	li	a2,2
    3cc4:	00000593          	li	a1,0
    3cc8:	f8c00537          	lui	a0,0xf8c00
    3ccc:	f29ff0ef          	jal	3bf4 <plic_set_enable>
                    SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT, 1);
    plic_set_priority(BSP_PLIC, SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT, 1);
    3cd0:	00100613          	li	a2,1
    3cd4:	00200593          	li	a1,2
    3cd8:	f8c00537          	lui	a0,0xf8c00
    3cdc:	f09ff0ef          	jal	3be4 <plic_set_priority>
}
    3ce0:	01c12083          	lw	ra,28(sp)
    3ce4:	02010113          	addi	sp,sp,32
    3ce8:	00008067          	ret

00003cec <proto_uart_rx_pop>:
*       如果先推进指针再读数据，中断可能在这两步之间又写入了新字节，我们就会
*       读到下一个字节、把当前这个漏掉。
******************************************************************************/
int proto_uart_rx_pop(uint8_t *byte)
{
    if (s_head == s_tail) {
    3cec:	9001a703          	lw	a4,-1792(gp) # 9f40 <s_head>
    3cf0:	8fc1a783          	lw	a5,-1796(gp) # 9f3c <s_tail>
    3cf4:	02f70863          	beq	a4,a5,3d24 <proto_uart_rx_pop+0x38>
        return 0;              /* 环空 */
    }
    *byte = s_ring[s_tail];
    3cf8:	8fc1a683          	lw	a3,-1796(gp) # 9f3c <s_tail>
    3cfc:	d7018793          	addi	a5,gp,-656 # a3b0 <s_ring>
    3d00:	00d787b3          	add	a5,a5,a3
    3d04:	0007c783          	lbu	a5,0(a5)
    3d08:	00f50023          	sb	a5,0(a0) # f8c00000 <__freertos_irq_stack_top+0xf8bf46c0>
    s_tail = (s_tail + 1U) & (PROTO_RX_RING_SIZE - 1U);
    3d0c:	8fc1a783          	lw	a5,-1796(gp) # 9f3c <s_tail>
    3d10:	00178793          	addi	a5,a5,1
    3d14:	1ff7f793          	andi	a5,a5,511
    3d18:	8ef1ae23          	sw	a5,-1796(gp) # 9f3c <s_tail>
    return 1;
    3d1c:	00100513          	li	a0,1
    3d20:	00008067          	ret
        return 0;              /* 环空 */
    3d24:	00000513          	li	a0,0
}
    3d28:	00008067          	ret

00003d2c <proto_uart_rx_dropped>:
/******************************************************************************
* @brief 因接收环满而丢弃的字节数。
******************************************************************************/
uint32_t proto_uart_rx_dropped(void)
{
    return s_dropped;
    3d2c:	8f81a503          	lw	a0,-1800(gp) # 9f38 <s_dropped>
}
    3d30:	00008067          	ret

00003d34 <proto_uart_fifo_overflow>:
        return *((volatile u32*) address);
    3d34:	f80027b7          	lui	a5,0xf8002
    3d38:	01078793          	addi	a5,a5,16 # f8002010 <__freertos_irq_stack_top+0xf7ff66d0>
    3d3c:	0007a783          	lw	a5,0(a5)
******************************************************************************/
uint32_t proto_uart_fifo_overflow(void)
{
    uint32_t err = read_u32(PROTO_UART_BASE + UART_ERROR_REG);

    if ((err & UART_ERR_READ_OVERFLOW) != 0U) {
    3d40:	0027f793          	andi	a5,a5,2
    3d44:	00078e63          	beqz	a5,3d60 <proto_uart_fifo_overflow+0x2c>
        s_fifo_overflow_seen++;
    3d48:	9041a783          	lw	a5,-1788(gp) # 9f44 <s_fifo_overflow_seen>
    3d4c:	00178793          	addi	a5,a5,1
    3d50:	90f1a223          	sw	a5,-1788(gp) # 9f44 <s_fifo_overflow_seen>
        *((volatile u32*) address) = data;
    3d54:	f80027b7          	lui	a5,0xf8002
    3d58:	00200713          	li	a4,2
    3d5c:	00e7a823          	sw	a4,16(a5) # f8002010 <__freertos_irq_stack_top+0xf7ff66d0>
        /* 写 1 清零（不是读-改-写：这个寄存器是"写 1 清除对应标志"的语义）。*/
        write_u32(UART_ERR_READ_OVERFLOW, PROTO_UART_BASE + UART_ERROR_REG);
    }
    return s_fifo_overflow_seen;
}
    3d60:	9041a503          	lw	a0,-1788(gp) # 9f44 <s_fifo_overflow_seen>
    3d64:	00008067          	ret

00003d68 <proto_uart_isr>:
*
* @note 中断服务程序里只做"搬字节"这一件事，不做解析、不做任何输出。
*       解析放在主循环（见 main.c），这样中断的执行时间恒定且极短。
******************************************************************************/
void proto_uart_isr(void)
{
    3d68:	ff010113          	addi	sp,sp,-16
    3d6c:	00112623          	sw	ra,12(sp)
    uint32_t status;

    /* 第一步：读出状态寄存器，把"接收非空中断使能"这一位清掉（屏蔽中断源）。*/
    status = uart_status_read(PROTO_UART_BASE);
    3d70:	f8002537          	lui	a0,0xf8002
    3d74:	e19ff0ef          	jal	3b8c <uart_status_read>
    uart_status_write(PROTO_UART_BASE,
    3d78:	0fd57593          	andi	a1,a0,253
    3d7c:	f8002537          	lui	a0,0xf8002
    3d80:	e15ff0ef          	jal	3b94 <uart_status_write>
                      (char)(status & ~UART_STATUS_RX_NOTEMPTY_INT_EN));

    /* 第二步：把 FIFO 里现有的字节全部搬进接收环。*/
    while (uart_readOccupancy(PROTO_UART_BASE) != 0U) {
    3d84:	0100006f          	j	3d94 <proto_uart_isr+0x2c>
        uint32_t next = (s_head + 1U) & (PROTO_RX_RING_SIZE - 1U);

        if (next == s_tail) {
            /* 写指针再前进就会追上读指针，说明环满了。丢掉这个字节并计数。
             * 注意这里**不推进** s_head——推进了就等于覆盖掉还没被读走的数据。*/
            s_dropped++;
    3d88:	8f81a783          	lw	a5,-1800(gp) # 9f38 <s_dropped>
    3d8c:	00178793          	addi	a5,a5,1
    3d90:	8ef1ac23          	sw	a5,-1800(gp) # 9f38 <s_dropped>
    while (uart_readOccupancy(PROTO_UART_BASE) != 0U) {
    3d94:	f8002537          	lui	a0,0xf8002
    3d98:	d85ff0ef          	jal	3b1c <uart_readOccupancy>
    3d9c:	02050c63          	beqz	a0,3dd4 <proto_uart_isr+0x6c>
        uint8_t  b    = (uint8_t)uart_read(PROTO_UART_BASE);
    3da0:	f8002537          	lui	a0,0xf8002
    3da4:	d85ff0ef          	jal	3b28 <uart_read>
        uint32_t next = (s_head + 1U) & (PROTO_RX_RING_SIZE - 1U);
    3da8:	9001a783          	lw	a5,-1792(gp) # 9f40 <s_head>
    3dac:	00178793          	addi	a5,a5,1
    3db0:	1ff7f793          	andi	a5,a5,511
        if (next == s_tail) {
    3db4:	8fc1a703          	lw	a4,-1796(gp) # 9f3c <s_tail>
    3db8:	fcf708e3          	beq	a4,a5,3d88 <proto_uart_isr+0x20>
        } else {
            s_ring[s_head] = b;
    3dbc:	9001a603          	lw	a2,-1792(gp) # 9f40 <s_head>
    3dc0:	d7018713          	addi	a4,gp,-656 # a3b0 <s_ring>
    3dc4:	00c70733          	add	a4,a4,a2
    3dc8:	00a70023          	sb	a0,0(a4) # 2000 <_ftoa+0x234>
            s_head = next;
    3dcc:	90f1a023          	sw	a5,-1792(gp) # 9f40 <s_head>
    3dd0:	fc5ff06f          	j	3d94 <proto_uart_isr+0x2c>
    /* 第三步：重新使能中断，准备接收下一批。
     * 重新读一次状态寄存器再置位，而不是直接用第一步读到的 status：
     * 因为排空过程中硬件可能改了状态寄存器里的其它位（比如溢出标志），
     * 用旧值回写会把这些变化抹掉。*/
    uart_status_write(PROTO_UART_BASE,
                      (char)(uart_status_read(PROTO_UART_BASE) |
    3dd4:	f8002537          	lui	a0,0xf8002
    3dd8:	db5ff0ef          	jal	3b8c <uart_status_read>
    uart_status_write(PROTO_UART_BASE,
    3ddc:	00256593          	ori	a1,a0,2
    3de0:	0ff5f593          	zext.b	a1,a1
    3de4:	f8002537          	lui	a0,0xf8002
    3de8:	dadff0ef          	jal	3b94 <uart_status_write>
                             UART_STATUS_RX_NOTEMPTY_INT_EN));
}
    3dec:	00c12083          	lw	ra,12(sp)
    3df0:	01010113          	addi	sp,sp,16
    3df4:	00008067          	ret

00003df8 <proto_uart_write>:
int proto_uart_write(const uint8_t *data, uint32_t len)
{
    uint32_t i;
    uint32_t guard;

    if (data == 0) {
    3df8:	06050663          	beqz	a0,3e64 <proto_uart_write+0x6c>
{
    3dfc:	fe010113          	addi	sp,sp,-32
    3e00:	00112e23          	sw	ra,28(sp)
    3e04:	00812c23          	sw	s0,24(sp)
    3e08:	00912a23          	sw	s1,20(sp)
    3e0c:	01212823          	sw	s2,16(sp)
    3e10:	01312623          	sw	s3,12(sp)
    3e14:	00050913          	mv	s2,a0
    3e18:	00058993          	mv	s3,a1
        return 0;
    }

    for (i = 0U; i < len; i++) {
    3e1c:	00000493          	li	s1,0
    3e20:	0180006f          	j	3e38 <proto_uart_write+0x40>
            guard--;
        }
        /* 直接把字节写到 UART 的数据寄存器。用 write_u32（来自 driver/io.h）
         * 而不是给指针赋值，是为了沿用 driver 里统一的"内存映射寄存器访问"
         * 写法，将来若要加内存屏障之类只需改一处。*/
        write_u32(data[i], PROTO_UART_BASE + UART_DATA);
    3e24:	009907b3          	add	a5,s2,s1
    3e28:	0007c703          	lbu	a4,0(a5)
    3e2c:	f80027b7          	lui	a5,0xf8002
    3e30:	00e7a023          	sw	a4,0(a5) # f8002000 <__freertos_irq_stack_top+0xf7ff66c0>
    for (i = 0U; i < len; i++) {
    3e34:	00148493          	addi	s1,s1,1
    3e38:	0334f263          	bgeu	s1,s3,3e5c <proto_uart_write+0x64>
        guard = PROTO_TX_TIMEOUT_SPINS;
    3e3c:	00018437          	lui	s0,0x18
    3e40:	6a040413          	addi	s0,s0,1696 # 186a0 <__freertos_irq_stack_top+0xcd60>
        while (uart_writeAvailability(PROTO_UART_BASE) == 0U) {
    3e44:	f8002537          	lui	a0,0xf8002
    3e48:	cc5ff0ef          	jal	3b0c <uart_writeAvailability>
    3e4c:	fc051ce3          	bnez	a0,3e24 <proto_uart_write+0x2c>
            if (guard == 0U) {
    3e50:	00040e63          	beqz	s0,3e6c <proto_uart_write+0x74>
            guard--;
    3e54:	fff40413          	addi	s0,s0,-1
    3e58:	fedff06f          	j	3e44 <proto_uart_write+0x4c>
    }
    return 1;
    3e5c:	00100513          	li	a0,1
    3e60:	0100006f          	j	3e70 <proto_uart_write+0x78>
        return 0;
    3e64:	00000513          	li	a0,0
}
    3e68:	00008067          	ret
                return 0;   /* 等太久了，放弃这一帧的剩余部分 */
    3e6c:	00000513          	li	a0,0
}
    3e70:	01c12083          	lw	ra,28(sp)
    3e74:	01812403          	lw	s0,24(sp)
    3e78:	01412483          	lw	s1,20(sp)
    3e7c:	01012903          	lw	s2,16(sp)
    3e80:	00c12983          	lw	s3,12(sp)
    3e84:	02010113          	addi	sp,sp,32
    3e88:	00008067          	ret

00003e8c <crc16_ccitt_update>:
     * 会先"整型提升"成 int，左移 8 位后还是 int，直接和 uint16_t 异或虽然结果
     * 正确，但中间类型带符号、语义不清晰。显式转型让每一步的类型都一目了然。
     *
     * 最外层的 (uint16_t) 是为了把结果截断回 16 位。RTL 里 c 就是 16 位寄存器，
     * 溢出自然丢弃高位；C 里必须显式截断才能和 RTL 完全一致。*/
    uint16_t c = (uint16_t)(crc ^ (uint16_t)((uint16_t)data << 8));
    3e8c:	00859593          	slli	a1,a1,0x8
    3e90:	00a5c533          	xor	a0,a1,a0
     *
     * 为什么不用查表法（预生成 256 项的表，一次处理一个字节）：
     * 查表要占 512 字节常量空间，而本模块的调用频率是"每个 body 字节一次"，
     * 在 115200 波特率下每秒最多一万多次，逐位法（每字节 8 次循环）绰绰有余。
     * 用一点 CPU 换掉 512 字节 Flash，对软核更划算。*/
    for (n = 0; n < 8; n++) {
    3e94:	00000793          	li	a5,0
    3e98:	0140006f          	j	3eac <crc16_ccitt_update+0x20>
        if ((c & 0x8000U) != 0U) {
            /* 0x8000 就是只保留 bit15 的掩码。用 & 判断而不是写成 (c >> 15)，
             * 是为了和 RTL 的 c[15] 取值写法更贴近。*/
            c = (uint16_t)((uint16_t)(c << 1) ^ CRC16_CCITT_POLY);
        } else {
            c = (uint16_t)(c << 1);
    3e9c:	00151513          	slli	a0,a0,0x1
    3ea0:	01051513          	slli	a0,a0,0x10
    3ea4:	01055513          	srli	a0,a0,0x10
    for (n = 0; n < 8; n++) {
    3ea8:	00178793          	addi	a5,a5,1
    3eac:	00700713          	li	a4,7
    3eb0:	02f74663          	blt	a4,a5,3edc <crc16_ccitt_update+0x50>
        if ((c & 0x8000U) != 0U) {
    3eb4:	01051713          	slli	a4,a0,0x10
    3eb8:	41075713          	srai	a4,a4,0x10
    3ebc:	fe0750e3          	bgez	a4,3e9c <crc16_ccitt_update+0x10>
            c = (uint16_t)((uint16_t)(c << 1) ^ CRC16_CCITT_POLY);
    3ec0:	00151513          	slli	a0,a0,0x1
    3ec4:	01051513          	slli	a0,a0,0x10
    3ec8:	01055513          	srli	a0,a0,0x10
    3ecc:	00001737          	lui	a4,0x1
    3ed0:	02170713          	addi	a4,a4,33 # 1021 <smp_slave+0xd>
    3ed4:	00e54533          	xor	a0,a0,a4
    3ed8:	fd1ff06f          	j	3ea8 <crc16_ccitt_update+0x1c>
        }
    }
    return c;
}
    3edc:	00008067          	ret

00003ee0 <handler_not_implemented>:
static uint8_t handler_not_implemented(const frame_t *frame, uint8_t *out,
                                       uint16_t *out_len)
{
    (void)frame;
    (void)out;
    *out_len = 0U;
    3ee0:	00061023          	sh	zero,0(a2)
    return PROTOCOL_STATUS_FAIL;
}
    3ee4:	00000513          	li	a0,0
    3ee8:	00008067          	ret

00003eec <handler_ui_not_in_scope>:
static uint8_t handler_ui_not_in_scope(const frame_t *frame, uint8_t *out,
                                       uint16_t *out_len)
{
    (void)frame;
    (void)out;
    *out_len = 0U;
    3eec:	00061023          	sh	zero,0(a2)
    return PROTOCOL_STATUS_FAIL;
}
    3ef0:	00000513          	li	a0,0
    3ef4:	00008067          	ret

00003ef8 <category_lookup>:
******************************************************************************/
static const protocol_category_t *category_lookup(uint8_t category)
{
    uint32_t i;

    for (i = 0U; i < CATEGORY_ENTRIES; i++) {
    3ef8:	00000793          	li	a5,0
    3efc:	00100713          	li	a4,1
    3f00:	02f76e63          	bltu	a4,a5,3f3c <category_lookup+0x44>
        if (s_categories[i].category == category) {
    3f04:	00008737          	lui	a4,0x8
    3f08:	00179693          	slli	a3,a5,0x1
    3f0c:	00f686b3          	add	a3,a3,a5
    3f10:	00269693          	slli	a3,a3,0x2
    3f14:	44470713          	addi	a4,a4,1092 # 8444 <s_categories>
    3f18:	00d70733          	add	a4,a4,a3
    3f1c:	00074703          	lbu	a4,0(a4)
    3f20:	00a70663          	beq	a4,a0,3f2c <category_lookup+0x34>
    for (i = 0U; i < CATEGORY_ENTRIES; i++) {
    3f24:	00178793          	addi	a5,a5,1
    3f28:	fd5ff06f          	j	3efc <category_lookup+0x4>
            return &s_categories[i];
    3f2c:	000087b7          	lui	a5,0x8
    3f30:	44478793          	addi	a5,a5,1092 # 8444 <s_categories>
    3f34:	00f68533          	add	a0,a3,a5
    3f38:	00008067          	ret
        }
    }
    return 0;
    3f3c:	00000513          	li	a0,0
}
    3f40:	00008067          	ret

00003f44 <table_lookup>:
* @note 线性查找而不是二分或哈希：掩膜表 5 行、UI 表 8 行，几次比较的开销可以
*       忽略，而线性代码最简单、最不容易写错。
******************************************************************************/
static const protocol_entry_t *table_lookup(const protocol_category_t *cat,
                                            uint8_t command)
{
    3f44:	00050713          	mv	a4,a0
    uint32_t i;

    for (i = 0U; i < cat->count; i++) {
    3f48:	00000793          	li	a5,0
    3f4c:	0080006f          	j	3f54 <table_lookup+0x10>
    3f50:	00178793          	addi	a5,a5,1
    3f54:	00872683          	lw	a3,8(a4)
    3f58:	00d7fe63          	bgeu	a5,a3,3f74 <table_lookup+0x30>
        if (cat->entries[i].command == command) {
    3f5c:	00472503          	lw	a0,4(a4)
    3f60:	00479693          	slli	a3,a5,0x4
    3f64:	00d50533          	add	a0,a0,a3
    3f68:	00054683          	lbu	a3,0(a0) # f8002000 <__freertos_irq_stack_top+0xf7ff66c0>
    3f6c:	feb692e3          	bne	a3,a1,3f50 <table_lookup+0xc>
    3f70:	00008067          	ret
            return &cat->entries[i];
        }
    }
    return 0;
    3f74:	00000513          	li	a0,0
}
    3f78:	00008067          	ret

00003f7c <entry_length_ok>:
* @param body_length 帧里声明的 body 长度。
* @return 1 表示相符。
******************************************************************************/
static int entry_length_ok(const protocol_entry_t *entry, uint16_t body_length)
{
    if (entry->body_length == LEN_ANY) {
    3f7c:	00255783          	lhu	a5,2(a0)
    3f80:	00010737          	lui	a4,0x10
    3f84:	fff70713          	addi	a4,a4,-1 # ffff <__freertos_irq_stack_top+0x46bf>
    3f88:	00e78863          	beq	a5,a4,3f98 <entry_length_ok+0x1c>
        return (body_length >= entry->min_length) ? 1 : 0;
    }
    return (body_length == entry->body_length) ? 1 : 0;
    3f8c:	40b78533          	sub	a0,a5,a1
    3f90:	00153513          	seqz	a0,a0
}
    3f94:	00008067          	ret
        return (body_length >= entry->min_length) ? 1 : 0;
    3f98:	00455503          	lhu	a0,4(a0)
    3f9c:	00a5b5b3          	sltu	a1,a1,a0
    3fa0:	0015b513          	seqz	a0,a1
    3fa4:	00008067          	ret

00003fa8 <build_ack_common>:
*       加运行时检查只会掩盖"有人把 UI_QUERY_PAYLOAD_LEN 改大了"这个真问题。
******************************************************************************/
static uint16_t build_ack_common(uint8_t *ack, uint8_t category, uint8_t command,
                                 uint8_t status, const uint8_t *payload,
                                 uint16_t payload_len)
{
    3fa8:	fd010113          	addi	sp,sp,-48
    3fac:	02112623          	sw	ra,44(sp)
    3fb0:	02812423          	sw	s0,40(sp)
    3fb4:	02912223          	sw	s1,36(sp)
    3fb8:	03212023          	sw	s2,32(sp)
    3fbc:	01312e23          	sw	s3,28(sp)
    3fc0:	01412c23          	sw	s4,24(sp)
    3fc4:	01512a23          	sw	s5,20(sp)
    3fc8:	01612823          	sw	s6,16(sp)
    3fcc:	01712623          	sw	s7,12(sp)
    3fd0:	00050913          	mv	s2,a0
    3fd4:	00058b93          	mv	s7,a1
    3fd8:	00060a93          	mv	s5,a2
    3fdc:	00068a13          	mv	s4,a3
    3fe0:	00070993          	mv	s3,a4
    3fe4:	00078493          	mv	s1,a5
    uint16_t crc = 0U;
    uint16_t body_len;
    uint16_t i;

    body_len = (uint16_t)(4U + payload_len);
    3fe8:	00478b13          	addi	s6,a5,4
    3fec:	010b1b13          	slli	s6,s6,0x10
    3ff0:	010b5b13          	srli	s6,s6,0x10

    crc = crc16_ccitt_update(crc, category);
    3ff4:	00000513          	li	a0,0
    3ff8:	e95ff0ef          	jal	3e8c <crc16_ccitt_update>
    crc = crc16_ccitt_update(crc, command);
    3ffc:	000a8593          	mv	a1,s5
    4000:	e8dff0ef          	jal	3e8c <crc16_ccitt_update>
    crc = crc16_ccitt_update(crc, PROTOCOL_ACK_TYPE);
    4004:	00200593          	li	a1,2
    4008:	e85ff0ef          	jal	3e8c <crc16_ccitt_update>
    crc = crc16_ccitt_update(crc, status);
    400c:	000a0593          	mv	a1,s4
    4010:	e7dff0ef          	jal	3e8c <crc16_ccitt_update>
    for (i = 0U; i < payload_len; i++) {
    4014:	00000413          	li	s0,0
    4018:	01c0006f          	j	4034 <build_ack_common+0x8c>
        crc = crc16_ccitt_update(crc, payload[i]);
    401c:	008987b3          	add	a5,s3,s0
    4020:	0007c583          	lbu	a1,0(a5)
    4024:	e69ff0ef          	jal	3e8c <crc16_ccitt_update>
    for (i = 0U; i < payload_len; i++) {
    4028:	00140413          	addi	s0,s0,1
    402c:	01041413          	slli	s0,s0,0x10
    4030:	01045413          	srli	s0,s0,0x10
    4034:	fe9464e3          	bltu	s0,s1,401c <build_ack_common+0x74>
    }

    ack[0] = FRAME_HEADER;                 /* 帧头 0xBB */
    4038:	fbb00793          	li	a5,-69
    403c:	00f90023          	sb	a5,0(s2)
    ack[1] = (uint8_t)(body_len >> 8);     /* body_length 高字节 */
    4040:	008b5793          	srli	a5,s6,0x8
    4044:	00f900a3          	sb	a5,1(s2)
    ack[2] = (uint8_t)(body_len & 0xFFU);  /* body_length 低字节 */
    4048:	01690123          	sb	s6,2(s2)
    ack[3] = category;                     /* 应答体第 0 字节：回显大类 */
    404c:	017901a3          	sb	s7,3(s2)
    ack[4] = command;                      /* 应答体第 1 字节：回显子项 */
    4050:	01590223          	sb	s5,4(s2)
    ack[5] = PROTOCOL_ACK_TYPE;            /* 应答体第 2 字节：0x02 表示应答 */
    4054:	00200793          	li	a5,2
    4058:	00f902a3          	sb	a5,5(s2)
    ack[6] = status;                       /* 应答体第 3 字节 */
    405c:	01490323          	sb	s4,6(s2)
    for (i = 0U; i < payload_len; i++) {
    4060:	00000693          	li	a3,0
    4064:	0240006f          	j	4088 <build_ack_common+0xe0>
        ack[7U + i] = payload[i];
    4068:	00768613          	addi	a2,a3,7
    406c:	00c90633          	add	a2,s2,a2
    4070:	00d987b3          	add	a5,s3,a3
    4074:	0007c783          	lbu	a5,0(a5)
    4078:	00f60023          	sb	a5,0(a2)
    for (i = 0U; i < payload_len; i++) {
    407c:	00168693          	addi	a3,a3,1
    4080:	01069693          	slli	a3,a3,0x10
    4084:	0106d693          	srli	a3,a3,0x10
    4088:	fe96e0e3          	bltu	a3,s1,4068 <build_ack_common+0xc0>
    }
    ack[7U + payload_len] = (uint8_t)(crc >> 8);      /* CRC 高字节 */
    408c:	00748793          	addi	a5,s1,7
    4090:	00f907b3          	add	a5,s2,a5
    4094:	00855713          	srli	a4,a0,0x8
    4098:	00e78023          	sb	a4,0(a5)
    ack[8U + payload_len] = (uint8_t)(crc & 0xFFU);   /* CRC 低字节 */
    409c:	00848793          	addi	a5,s1,8
    40a0:	00f907b3          	add	a5,s2,a5
    40a4:	00a78023          	sb	a0,0(a5)
    ack[9U + payload_len] = FRAME_FOOTER;             /* 帧尾 0xAA */
    40a8:	00948793          	addi	a5,s1,9
    40ac:	00f90933          	add	s2,s2,a5
    40b0:	faa00793          	li	a5,-86
    40b4:	00f90023          	sb	a5,0(s2)

    return (uint16_t)(10U + payload_len);
    40b8:	00a48513          	addi	a0,s1,10
}
    40bc:	01051513          	slli	a0,a0,0x10
    40c0:	01055513          	srli	a0,a0,0x10
    40c4:	02c12083          	lw	ra,44(sp)
    40c8:	02812403          	lw	s0,40(sp)
    40cc:	02412483          	lw	s1,36(sp)
    40d0:	02012903          	lw	s2,32(sp)
    40d4:	01c12983          	lw	s3,28(sp)
    40d8:	01812a03          	lw	s4,24(sp)
    40dc:	01412a83          	lw	s5,20(sp)
    40e0:	01012b03          	lw	s6,16(sp)
    40e4:	00c12b83          	lw	s7,12(sp)
    40e8:	03010113          	addi	sp,sp,48
    40ec:	00008067          	ret

000040f0 <handler_ui_query_view>:
{
    40f0:	ff010113          	addi	sp,sp,-16
    40f4:	00112623          	sw	ra,12(sp)
    40f8:	00812423          	sw	s0,8(sp)
    40fc:	00060413          	mv	s0,a2
    (void)ui_query_view(out);
    4100:	00058513          	mv	a0,a1
    4104:	1cd000ef          	jal	4ad0 <ui_query_view>
    *out_len = UI_QUERY_PAYLOAD_LEN;
    4108:	00800793          	li	a5,8
    410c:	00f41023          	sh	a5,0(s0)
}
    4110:	0ff00513          	li	a0,255
    4114:	00c12083          	lw	ra,12(sp)
    4118:	00812403          	lw	s0,8(sp)
    411c:	01010113          	addi	sp,sp,16
    4120:	00008067          	ret

00004124 <handler_ui_set_image_values>:
{
    4124:	ff010113          	addi	sp,sp,-16
    4128:	00112623          	sw	ra,12(sp)
    *out_len = 0U;
    412c:	00061023          	sh	zero,0(a2)
    return (ui_set_image_values(frame->payload) == 0) ? PROTOCOL_STATUS_OK
    4130:	00c50513          	addi	a0,a0,12
    4134:	115000ef          	jal	4a48 <ui_set_image_values>
                                                      : PROTOCOL_STATUS_FAIL;
    4138:	00050a63          	beqz	a0,414c <handler_ui_set_image_values+0x28>
    413c:	00000513          	li	a0,0
}
    4140:	00c12083          	lw	ra,12(sp)
    4144:	01010113          	addi	sp,sp,16
    4148:	00008067          	ret
                                                      : PROTOCOL_STATUS_FAIL;
    414c:	0ff00513          	li	a0,255
    4150:	ff1ff06f          	j	4140 <handler_ui_set_image_values+0x1c>

00004154 <handler_ui_set_view>:
{
    4154:	ff010113          	addi	sp,sp,-16
    4158:	00112623          	sw	ra,12(sp)
    *out_len = 0U;                    /* SET_VIEW 的应答是定长 10 字节 */
    415c:	00061023          	sh	zero,0(a2)
    page_id = (uint16_t)(((uint16_t)frame->payload[0] << 8) |
    4160:	00c54783          	lbu	a5,12(a0)
                          (uint16_t)frame->payload[1]);
    4164:	00d54703          	lbu	a4,13(a0)
    page_id = (uint16_t)(((uint16_t)frame->payload[0] << 8) |
    4168:	00879793          	slli	a5,a5,0x8
    return (ui_set_view(page_id, sel, flags) == 0) ? PROTOCOL_STATUS_OK
    416c:	00f54603          	lbu	a2,15(a0)
    4170:	00e54583          	lbu	a1,14(a0)
    4174:	00f76533          	or	a0,a4,a5
    4178:	00d000ef          	jal	4984 <ui_set_view>
                                                   : PROTOCOL_STATUS_FAIL;
    417c:	00050a63          	beqz	a0,4190 <handler_ui_set_view+0x3c>
    4180:	00000513          	li	a0,0
}
    4184:	00c12083          	lw	ra,12(sp)
    4188:	01010113          	addi	sp,sp,16
    418c:	00008067          	ret
                                                   : PROTOCOL_STATUS_FAIL;
    4190:	0ff00513          	li	a0,255
    4194:	ff1ff06f          	j	4184 <handler_ui_set_view+0x30>

00004198 <protocol_init>:
    if (stats == 0) {
    4198:	00050863          	beqz	a0,41a8 <protocol_init+0x10>
    stats->accepted_count = 0U;
    419c:	00052023          	sw	zero,0(a0)
    stats->bad_packet_count = 0U;
    41a0:	00052223          	sw	zero,4(a0)
    stats->other_category_count = 0U;
    41a4:	00052423          	sw	zero,8(a0)
}
    41a8:	00008067          	ret

000041ac <protocol_build_ack>:

void protocol_build_ack(uint8_t *ack, uint8_t category, uint8_t command,
                        uint8_t status)
{
    if (ack == 0) {
    41ac:	02050263          	beqz	a0,41d0 <protocol_build_ack+0x24>
{
    41b0:	ff010113          	addi	sp,sp,-16
    41b4:	00112623          	sw	ra,12(sp)
        return;
    }
    (void)build_ack_common(ack, category, command, status, 0, 0U);
    41b8:	00000793          	li	a5,0
    41bc:	00000713          	li	a4,0
    41c0:	de9ff0ef          	jal	3fa8 <build_ack_common>
}
    41c4:	00c12083          	lw	ra,12(sp)
    41c8:	01010113          	addi	sp,sp,16
    41cc:	00008067          	ret
    41d0:	00008067          	ret

000041d4 <protocol_build_ack_payload>:

uint16_t protocol_build_ack_payload(uint8_t *ack, uint8_t category, uint8_t command,
                                    uint8_t status, const uint8_t *payload,
                                    uint16_t payload_len)
{
    if (ack == 0) {
    41d4:	00050e63          	beqz	a0,41f0 <protocol_build_ack_payload+0x1c>
{
    41d8:	ff010113          	addi	sp,sp,-16
    41dc:	00112623          	sw	ra,12(sp)
        return 0U;
    }
    return build_ack_common(ack, category, command, status, payload, payload_len);
    41e0:	dc9ff0ef          	jal	3fa8 <build_ack_common>
}
    41e4:	00c12083          	lw	ra,12(sp)
    41e8:	01010113          	addi	sp,sp,16
    41ec:	00008067          	ret
        return 0U;
    41f0:	00000513          	li	a0,0
}
    41f4:	00008067          	ret

000041f8 <protocol_handle>:
*           子项确实是发给本端点的，只是本期不实现；计成坏包会让链路上真实
*           存在的工具帧把坏包率顶高）。
******************************************************************************/
void protocol_handle(protocol_stats_t *stats, const frame_t *frame,
                     protocol_response_t *response)
{
    41f8:	fd010113          	addi	sp,sp,-48
    41fc:	02112623          	sw	ra,44(sp)
    const protocol_category_t *cat;
    const protocol_entry_t *entry;
    /* 应答体的参数段。8 字节是编译期常量（UI_QUERY_PAYLOAD_LEN），
     * 只有 QUERY_VIEW 会用到，其余子项 out_len 都是 0。*/
    uint8_t  out[UI_QUERY_PAYLOAD_LEN];
    uint16_t out_len = 0U;
    4200:	00011323          	sh	zero,6(sp)

    if ((stats == 0) || (frame == 0) || (response == 0)) {
    4204:	0c050e63          	beqz	a0,42e0 <protocol_handle+0xe8>
    4208:	02812423          	sw	s0,40(sp)
    420c:	02912223          	sw	s1,36(sp)
    4210:	03212023          	sw	s2,32(sp)
    4214:	00050913          	mv	s2,a0
    4218:	00058493          	mv	s1,a1
    421c:	00060413          	mv	s0,a2
    4220:	20058263          	beqz	a1,4424 <protocol_handle+0x22c>
    4224:	20060863          	beqz	a2,4434 <protocol_handle+0x23c>
    }

    /* 先给出默认结论：不发应答、失败、子项名未知。
     * 先把"最保守的默认值"铺好，后面每个分支只需要覆盖它要改的字段，
     * 这样就不会出现"某个分支漏填了某字段、结果带着上一次的残留值发出去"。*/
    response->send_ack = 0;
    4228:	000609a3          	sb	zero,19(a2)
    response->defer_ack = 0;
    422c:	00060a23          	sb	zero,20(a2)
    response->status = PROTOCOL_STATUS_FAIL;
    4230:	00060aa3          	sb	zero,21(a2)
    response->reason = PROTO_REASON_BAD_INTEGRITY;
    4234:	00200793          	li	a5,2
    4238:	00f62c23          	sw	a5,24(a2)
    response->command_name = "?";
    423c:	000087b7          	lui	a5,0x8
    4240:	dd878793          	addi	a5,a5,-552 # 7dd8 <_data+0x2a8>
    4244:	00f62e23          	sw	a5,28(a2)
    response->ack_len = 0U;
    4248:	00060923          	sb	zero,18(a2)

    /* 第 1 关：完整性。CRC 或帧尾任一不对，就认为帧被破坏了。
     * 不应答——理由见函数头。*/
    if ((frame->crc_ok == 0U) || (frame->footer_ok == 0U)) {
    424c:	0065c783          	lbu	a5,6(a1)
    4250:	06078c63          	beqz	a5,42c8 <protocol_handle+0xd0>
    4254:	0075c783          	lbu	a5,7(a1)
    4258:	06078863          	beqz	a5,42c8 <protocol_handle+0xd0>
    }

    /* 第 2 关：大类归属。不归本端点管的大类（电子变倍 0x01、热点 0x02、
     * 伪彩色 0x03）既不该执行也不该应答，只记一笔"收到过其它大类的帧"，
     * 便于诊断链路上都有谁在说话。*/
    cat = category_lookup(frame->category);
    425c:	0005c503          	lbu	a0,0(a1)
    4260:	c99ff0ef          	jal	3ef8 <category_lookup>
    if (cat == 0) {
    4264:	08050463          	beqz	a0,42ec <protocol_handle+0xf4>
        return;
    }

    /* 从这一步起，帧确定是本端点的了：**默认每一个都会得到应答**。
     * 唯一的例外是 UI 的 0x01–0x05，它们在下面第 6 关把 send_ack 改回 0。*/
    response->send_ack = 1;
    4268:	00100793          	li	a5,1
    426c:	00f409a3          	sb	a5,19(s0)

    /* 第 3 关：类型字段必须是"上位机写"。*/
    if (frame->format_ok == 0U) {
    4270:	0084c783          	lbu	a5,8(s1)
    4274:	08079e63          	bnez	a5,4310 <protocol_handle+0x118>
        response->reason = PROTO_REASON_BAD_FORMAT;
    4278:	00300793          	li	a5,3
    427c:	00f42c23          	sw	a5,24(s0)
        stats->bad_packet_count++;
    4280:	00492783          	lw	a5,4(s2)
    4284:	00178793          	addi	a5,a5,1
    4288:	00f92223          	sw	a5,4(s2)
    /* 构造应答。只有"大类归本端点、完整性通过、且该子项要应答"才需要发。
     * 大类和子项原样回显，这样上位机能按自己发过的命令去核对。
     *
     * 参数段为空时走定长 10 字节那一支 —— 两条路都落到同一个 build_ack_common，
     * 所以 CRC 覆盖范围与字节序只有一处实现。*/
    if (response->send_ack != 0) {
    428c:	01344783          	lbu	a5,19(s0)
    4290:	1a078a63          	beqz	a5,4444 <protocol_handle+0x24c>
        if (out_len == 0U) {
    4294:	00615783          	lhu	a5,6(sp)
    4298:	16079063          	bnez	a5,43f8 <protocol_handle+0x200>
            protocol_build_ack(response->ack, frame->category, frame->command,
    429c:	01544683          	lbu	a3,21(s0)
    42a0:	0014c603          	lbu	a2,1(s1)
    42a4:	0004c583          	lbu	a1,0(s1)
    42a8:	00040513          	mv	a0,s0
    42ac:	f01ff0ef          	jal	41ac <protocol_build_ack>
                               response->status);
            response->ack_len = PROTOCOL_ACK_LEN;
    42b0:	00a00793          	li	a5,10
    42b4:	00f40923          	sb	a5,18(s0)
    42b8:	02812403          	lw	s0,40(sp)
    42bc:	02412483          	lw	s1,36(sp)
    42c0:	02012903          	lw	s2,32(sp)
    42c4:	01c0006f          	j	42e0 <protocol_handle+0xe8>
        stats->bad_packet_count++;
    42c8:	00492783          	lw	a5,4(s2)
    42cc:	00178793          	addi	a5,a5,1
    42d0:	00f92223          	sw	a5,4(s2)
        return;
    42d4:	02812403          	lw	s0,40(sp)
    42d8:	02412483          	lw	s1,36(sp)
    42dc:	02012903          	lw	s2,32(sp)
            response->ack_len = (uint8_t)protocol_build_ack_payload(
                response->ack, frame->category, frame->command,
                response->status, out, out_len);
        }
    }
}
    42e0:	02c12083          	lw	ra,44(sp)
    42e4:	03010113          	addi	sp,sp,48
    42e8:	00008067          	ret
        response->reason = PROTO_REASON_OTHER_CATEGORY;
    42ec:	00100793          	li	a5,1
    42f0:	00f42c23          	sw	a5,24(s0)
        stats->other_category_count++;
    42f4:	00892783          	lw	a5,8(s2)
    42f8:	00178793          	addi	a5,a5,1
    42fc:	00f92423          	sw	a5,8(s2)
        return;
    4300:	02812403          	lw	s0,40(sp)
    4304:	02412483          	lw	s1,36(sp)
    4308:	02012903          	lw	s2,32(sp)
    430c:	fd5ff06f          	j	42e0 <protocol_handle+0xe8>
    4310:	01312e23          	sw	s3,28(sp)
        entry = table_lookup(cat, frame->command);
    4314:	0014c583          	lbu	a1,1(s1)
    4318:	c2dff0ef          	jal	3f44 <table_lookup>
    431c:	00050993          	mv	s3,a0
        if (entry == 0) {
    4320:	02050a63          	beqz	a0,4354 <protocol_handle+0x15c>
            response->command_name = entry->name;
    4324:	00852783          	lw	a5,8(a0)
    4328:	00f42e23          	sw	a5,28(s0)
            if (entry_length_ok(entry, frame->body_length) == 0) {
    432c:	0044d583          	lhu	a1,4(s1)
    4330:	c4dff0ef          	jal	3f7c <entry_length_ok>
    4334:	02051e63          	bnez	a0,4370 <protocol_handle+0x178>
                response->reason = PROTO_REASON_BAD_LENGTH;
    4338:	00500793          	li	a5,5
    433c:	00f42c23          	sw	a5,24(s0)
                stats->bad_packet_count++;
    4340:	00492783          	lw	a5,4(s2)
    4344:	00178793          	addi	a5,a5,1
    4348:	00f92223          	sw	a5,4(s2)
    434c:	01c12983          	lw	s3,28(sp)
    4350:	f3dff06f          	j	428c <protocol_handle+0x94>
            response->reason = PROTO_REASON_UNKNOWN_COMMAND;
    4354:	00400793          	li	a5,4
    4358:	00f42c23          	sw	a5,24(s0)
            stats->bad_packet_count++;
    435c:	00492783          	lw	a5,4(s2)
    4360:	00178793          	addi	a5,a5,1
    4364:	00f92223          	sw	a5,4(s2)
    4368:	01c12983          	lw	s3,28(sp)
    436c:	f21ff06f          	j	428c <protocol_handle+0x94>
            } else if (entry->reply == 0U) {
    4370:	0069c783          	lbu	a5,6(s3)
    4374:	02079063          	bnez	a5,4394 <protocol_handle+0x19c>
                response->send_ack = 0;
    4378:	000409a3          	sb	zero,19(s0)
                response->reason = PROTO_REASON_UI_IGNORED;
    437c:	00700793          	li	a5,7
    4380:	00f42c23          	sw	a5,24(s0)
                response->command_name = entry->name;
    4384:	0089a783          	lw	a5,8(s3)
    4388:	00f42e23          	sw	a5,28(s0)
    438c:	01c12983          	lw	s3,28(sp)
    4390:	efdff06f          	j	428c <protocol_handle+0x94>
                stats->accepted_count++;
    4394:	00092783          	lw	a5,0(s2)
    4398:	00178793          	addi	a5,a5,1
    439c:	00f92023          	sw	a5,0(s2)
                response->status = entry->handler(frame, out, &out_len);
    43a0:	00c9a783          	lw	a5,12(s3)
    43a4:	00610613          	addi	a2,sp,6
    43a8:	00810593          	addi	a1,sp,8
    43ac:	00048513          	mv	a0,s1
    43b0:	000780e7          	jalr	a5
    43b4:	00a40aa3          	sb	a0,21(s0)
                if (response->status == PROTOCOL_STATUS_OK) {
    43b8:	0ff00793          	li	a5,255
    43bc:	00f50a63          	beq	a0,a5,43d0 <protocol_handle+0x1d8>
                    response->reason = PROTO_REASON_NOT_IMPLEMENTED;
    43c0:	00600793          	li	a5,6
    43c4:	00f42c23          	sw	a5,24(s0)
    43c8:	01c12983          	lw	s3,28(sp)
    43cc:	ec1ff06f          	j	428c <protocol_handle+0x94>
                    response->reason = PROTO_REASON_OK;
    43d0:	00042c23          	sw	zero,24(s0)
                    response->defer_ack = entry->defer;
    43d4:	0079c783          	lbu	a5,7(s3)
    43d8:	00f40a23          	sb	a5,20(s0)
                    if (entry->defer != 0U) {
    43dc:	00078a63          	beqz	a5,43f0 <protocol_handle+0x1f8>
                        response->reason = PROTO_REASON_DEFERRED;
    43e0:	00800793          	li	a5,8
    43e4:	00f42c23          	sw	a5,24(s0)
    43e8:	01c12983          	lw	s3,28(sp)
    43ec:	ea1ff06f          	j	428c <protocol_handle+0x94>
    43f0:	01c12983          	lw	s3,28(sp)
    43f4:	e99ff06f          	j	428c <protocol_handle+0x94>
            response->ack_len = (uint8_t)protocol_build_ack_payload(
    43f8:	00810713          	addi	a4,sp,8
    43fc:	01544683          	lbu	a3,21(s0)
    4400:	0014c603          	lbu	a2,1(s1)
    4404:	0004c583          	lbu	a1,0(s1)
    4408:	00040513          	mv	a0,s0
    440c:	dc9ff0ef          	jal	41d4 <protocol_build_ack_payload>
    4410:	00a40923          	sb	a0,18(s0)
    4414:	02812403          	lw	s0,40(sp)
    4418:	02412483          	lw	s1,36(sp)
    441c:	02012903          	lw	s2,32(sp)
    4420:	ec1ff06f          	j	42e0 <protocol_handle+0xe8>
    4424:	02812403          	lw	s0,40(sp)
    4428:	02412483          	lw	s1,36(sp)
    442c:	02012903          	lw	s2,32(sp)
    4430:	eb1ff06f          	j	42e0 <protocol_handle+0xe8>
    4434:	02812403          	lw	s0,40(sp)
    4438:	02412483          	lw	s1,36(sp)
    443c:	02012903          	lw	s2,32(sp)
    4440:	ea1ff06f          	j	42e0 <protocol_handle+0xe8>
    4444:	02812403          	lw	s0,40(sp)
    4448:	02412483          	lw	s1,36(sp)
    444c:	02012903          	lw	s2,32(sp)
    4450:	e91ff06f          	j	42e0 <protocol_handle+0xe8>

00004454 <reg_write>:
* @note volatile 不能省：这几条写是**有副作用**的（RTL 侧会据此改行为），
*       没有 volatile 编译器有权把它们优化掉或合并。
******************************************************************************/
static void reg_write(uint32_t off, uint32_t val)
{
    *(volatile uint32_t *)(OSD_REG_BASE + off) = val;
    4454:	e10437b7          	lui	a5,0xe1043
    4458:	00f50533          	add	a0,a0,a5
    445c:	00b52023          	sw	a1,0(a0)
}
    4460:	00008067          	ret

00004464 <canvas_select_block>:

void canvas_select_block(int idx) { s_block = (idx == 1) ? 1 : 0; }
    4464:	fff50513          	addi	a0,a0,-1
    4468:	00153513          	seqz	a0,a0
    446c:	90a1a623          	sw	a0,-1780(gp) # 9f4c <s_block>
    4470:	00008067          	ret

00004474 <canvas_set_visible>:

void canvas_set_visible(int on) { s_visible = (on != 0) ? 1 : 0; }
    4474:	00a03533          	snez	a0,a0
    4478:	90a1a423          	sw	a0,-1784(gp) # 9f48 <s_visible>
    447c:	00008067          	ret

00004480 <canvas_write>:
*       也是 RTL 侧按字节读回时看到的顺序。写反了画面会变成每 4 个像素
*       一组错位 —— 这种错在"看起来像图像噪声"里最难认。
******************************************************************************/
void canvas_write(uint32_t off, const uint8_t *src, uint32_t len)
{
    volatile uint8_t *dst = (volatile uint8_t *)((s_block ? OSD_BLOCK1_ADDR
    4480:	90c1a783          	lw	a5,-1780(gp) # 9f4c <s_block>
                                                          : OSD_BLOCK0_ADDR) + off);
    4484:	02078063          	beqz	a5,44a4 <canvas_write+0x24>
    4488:	00b40837          	lui	a6,0xb40
    448c:	00a80833          	add	a6,a6,a0
    uint32_t i = 0U;

    if (src == 0) {
    4490:	06058c63          	beqz	a1,4508 <canvas_write+0x88>
        return;
    }

    if ((off & 3U) == 0U) {
    4494:	00357513          	andi	a0,a0,3
    4498:	00050a63          	beqz	a0,44ac <canvas_write+0x2c>
    uint32_t i = 0U;
    449c:	00000513          	li	a0,0
    44a0:	0640006f          	j	4504 <canvas_write+0x84>
                                                          : OSD_BLOCK0_ADDR) + off);
    44a4:	00a40837          	lui	a6,0xa40
    44a8:	fe5ff06f          	j	448c <canvas_write+0xc>
        for (; i + 4U <= len; i += 4U) {
    44ac:	00450893          	addi	a7,a0,4
    44b0:	05166a63          	bltu	a2,a7,4504 <canvas_write+0x84>
            uint32_t w = (uint32_t)src[i]
    44b4:	00a58733          	add	a4,a1,a0
    44b8:	00074783          	lbu	a5,0(a4)
                       | ((uint32_t)src[i + 1U] << 8)
    44bc:	00174683          	lbu	a3,1(a4)
    44c0:	00869693          	slli	a3,a3,0x8
    44c4:	00d7e7b3          	or	a5,a5,a3
                       | ((uint32_t)src[i + 2U] << 16)
    44c8:	00274683          	lbu	a3,2(a4)
    44cc:	01069693          	slli	a3,a3,0x10
    44d0:	00d7e7b3          	or	a5,a5,a3
                       | ((uint32_t)src[i + 3U] << 24);
    44d4:	00374703          	lbu	a4,3(a4)
    44d8:	01871713          	slli	a4,a4,0x18
            uint32_t w = (uint32_t)src[i]
    44dc:	00e7e7b3          	or	a5,a5,a4
            *(volatile uint32_t *)(dst + i) = w;
    44e0:	00a80533          	add	a0,a6,a0
    44e4:	00f52023          	sw	a5,0(a0)
        for (; i + 4U <= len; i += 4U) {
    44e8:	00088513          	mv	a0,a7
    44ec:	fc1ff06f          	j	44ac <canvas_write+0x2c>
        }
    }
    for (; i < len; i++) {
        dst[i] = src[i];
    44f0:	00a807b3          	add	a5,a6,a0
    44f4:	00a58733          	add	a4,a1,a0
    44f8:	00074703          	lbu	a4,0(a4)
    44fc:	00e78023          	sb	a4,0(a5) # e1043000 <__freertos_irq_stack_top+0xe10376c0>
    for (; i < len; i++) {
    4500:	00150513          	addi	a0,a0,1
    4504:	fec566e3          	bltu	a0,a2,44f0 <canvas_write+0x70>
    }
}
    4508:	00008067          	ret

0000450c <canvas_fill>:
*
* @note 清屏是 14,144 字节 × 2 块，走整字能把事务数从 28,288 降到 7,072。
******************************************************************************/
void canvas_fill(uint32_t off, uint8_t v, uint32_t len)
{
    volatile uint8_t *dst = (volatile uint8_t *)((s_block ? OSD_BLOCK1_ADDR
    450c:	90c1a783          	lw	a5,-1780(gp) # 9f4c <s_block>
                                                          : OSD_BLOCK0_ADDR) + off);
    4510:	00078e63          	beqz	a5,452c <canvas_fill+0x20>
    4514:	00b40737          	lui	a4,0xb40
    4518:	00a70733          	add	a4,a4,a0
    uint32_t i = 0U;

    if ((off & 3U) == 0U) {
    451c:	00357513          	andi	a0,a0,3
    4520:	00050a63          	beqz	a0,4534 <canvas_fill+0x28>
    uint32_t i = 0U;
    4524:	00000513          	li	a0,0
    4528:	0480006f          	j	4570 <canvas_fill+0x64>
                                                          : OSD_BLOCK0_ADDR) + off);
    452c:	00a40737          	lui	a4,0xa40
    4530:	fe9ff06f          	j	4518 <canvas_fill+0xc>
        uint32_t pat = (uint32_t)v | ((uint32_t)v << 8)
    4534:	00859693          	slli	a3,a1,0x8
    4538:	00b686b3          	add	a3,a3,a1
                     | ((uint32_t)v << 16) | ((uint32_t)v << 24);
    453c:	01059793          	slli	a5,a1,0x10
    4540:	00f6e6b3          	or	a3,a3,a5
    4544:	01859793          	slli	a5,a1,0x18
        uint32_t pat = (uint32_t)v | ((uint32_t)v << 8)
    4548:	00f6e6b3          	or	a3,a3,a5
        for (; i + 4U <= len; i += 4U) {
    454c:	00450793          	addi	a5,a0,4
    4550:	02f66063          	bltu	a2,a5,4570 <canvas_fill+0x64>
            *(volatile uint32_t *)(dst + i) = pat;
    4554:	00a70533          	add	a0,a4,a0
    4558:	00d52023          	sw	a3,0(a0)
        for (; i + 4U <= len; i += 4U) {
    455c:	00078513          	mv	a0,a5
    4560:	fedff06f          	j	454c <canvas_fill+0x40>
        }
    }
    for (; i < len; i++) {
        dst[i] = v;
    4564:	00a707b3          	add	a5,a4,a0
    4568:	00b78023          	sb	a1,0(a5)
    for (; i < len; i++) {
    456c:	00150513          	addi	a0,a0,1
    4570:	fec56ae3          	bltu	a0,a2,4564 <canvas_fill+0x58>
    }
}
    4574:	00008067          	ret

00004578 <canvas_commit>:
* @note 提交是"置位即返回"，不等 pending 清、不读 ack：RTL 在帧边界整体切换。
*       要确认生效就读 STATUS 的 pending 位（本工程目前不需要，
*       因为下一步操作都在帧率尺度之外）。
******************************************************************************/
void canvas_commit(void)
{
    4578:	ff010113          	addi	sp,sp,-16
    457c:	00112623          	sw	ra,12(sp)
    4580:	00812423          	sw	s0,8(sp)
    uint32_t ctrl = (s_visible ? OSD_CTRL_ENABLE : 0U)
    4584:	9081a783          	lw	a5,-1784(gp) # 9f48 <s_visible>
    4588:	04078a63          	beqz	a5,45dc <canvas_commit+0x64>
    458c:	00100413          	li	s0,1
                  | (s_block   ? OSD_CTRL_BUFFER : 0U);
    4590:	90c1a783          	lw	a5,-1780(gp) # 9f4c <s_block>
    4594:	04078863          	beqz	a5,45e4 <canvas_commit+0x6c>
    4598:	00200793          	li	a5,2
    uint32_t ctrl = (s_visible ? OSD_CTRL_ENABLE : 0U)
    459c:	00f46433          	or	s0,s0,a5

    reg_write(OSD_REG_POS(OSD_MENU_ROUTE),
    45a0:	000b85b7          	lui	a1,0xb8
    45a4:	05858593          	addi	a1,a1,88 # b8058 <__freertos_irq_stack_top+0xac718>
    45a8:	01800513          	li	a0,24
    45ac:	ea9ff0ef          	jal	4454 <reg_write>
              ((uint32_t)((uint32_t)OSD_MENU_TOP & 0xFFFU) << 12)
            |  (uint32_t)((uint32_t)OSD_MENU_LEFT & 0xFFFU));
    reg_write(OSD_REG_CTRL(OSD_MENU_ROUTE), ctrl);
    45b0:	00040593          	mv	a1,s0
    45b4:	01c00513          	li	a0,28
    45b8:	e9dff0ef          	jal	4454 <reg_write>
    reg_write(OSD_REG_COMMAND, OSD_CMD_COMMIT | OSD_CMD_GLOBAL_EN);
    45bc:	800005b7          	lui	a1,0x80000
    45c0:	00158593          	addi	a1,a1,1 # 80000001 <__freertos_irq_stack_top+0x7fff46c1>
    45c4:	00000513          	li	a0,0
    45c8:	e8dff0ef          	jal	4454 <reg_write>
}
    45cc:	00c12083          	lw	ra,12(sp)
    45d0:	00812403          	lw	s0,8(sp)
    45d4:	01010113          	addi	sp,sp,16
    45d8:	00008067          	ret
    uint32_t ctrl = (s_visible ? OSD_CTRL_ENABLE : 0U)
    45dc:	00000413          	li	s0,0
    45e0:	fb1ff06f          	j	4590 <canvas_commit+0x18>
                  | (s_block   ? OSD_CTRL_BUFFER : 0U);
    45e4:	00000793          	li	a5,0
    45e8:	fb5ff06f          	j	459c <canvas_commit+0x24>

000045ec <render_and_commit>:
*         3) 渲染 —— 把字符网格展开成 1 bit/像素位图。
*         4) 提交 —— 置位后立即返回，由 RTL 在帧边界整体切换。
*       之后翻转后台块，下一次写另一块。
******************************************************************************/
static void render_and_commit(void)
{
    45ec:	ff010113          	addi	sp,sp,-16
    45f0:	00112623          	sw	ra,12(sp)
    45f4:	00812423          	sw	s0,8(sp)
    canvas_set_visible(ui_is_visible());   /* 见上：必须排在 commit 之前 */
    45f8:	524000ef          	jal	4b1c <ui_is_visible>
    45fc:	e79ff0ef          	jal	4474 <canvas_set_visible>
    canvas_select_block(s_back);
    4600:	9181a503          	lw	a0,-1768(gp) # 9f58 <s_back>
    4604:	e61ff0ef          	jal	4464 <canvas_select_block>
    composer_render();
    4608:	128000ef          	jal	4730 <composer_render>
    canvas_commit();
    460c:	f6dff0ef          	jal	4578 <canvas_commit>

    s_back ^= 1;
    4610:	9181a783          	lw	a5,-1768(gp) # 9f58 <s_back>
    4614:	0017c793          	xori	a5,a5,1
    4618:	90f1ac23          	sw	a5,-1768(gp) # 9f58 <s_back>
    s_renders++;
    461c:	9141a783          	lw	a5,-1772(gp) # 9f54 <s_renders>
    4620:	00178793          	addi	a5,a5,1
    4624:	90f1aa23          	sw	a5,-1772(gp) # 9f54 <s_renders>
    ui_clear_dirty();
    4628:	510000ef          	jal	4b38 <ui_clear_dirty>
}
    462c:	00c12083          	lw	ra,12(sp)
    4630:	00812403          	lw	s0,8(sp)
    4634:	01010113          	addi	sp,sp,16
    4638:	00008067          	ret

0000463c <osd_engine_boot>:

void osd_engine_boot(void)
{
    463c:	ff010113          	addi	sp,sp,-16
    4640:	00112623          	sw	ra,12(sp)
    ui_init();
    4644:	2f0000ef          	jal	4934 <ui_init>

    /* 两块都清零：位图是透明底，只清一块的话另一块上前台时会露出旧内容。 */
    canvas_select_block(0);
    4648:	00000513          	li	a0,0
    464c:	e19ff0ef          	jal	4464 <canvas_select_block>
    canvas_fill(0U, 0U, (uint32_t)OSD_BLOCK_BYTES);
    4650:	00003637          	lui	a2,0x3
    4654:	74060613          	addi	a2,a2,1856 # 3740 <handle_frame+0x68>
    4658:	00000593          	li	a1,0
    465c:	00000513          	li	a0,0
    4660:	eadff0ef          	jal	450c <canvas_fill>
    canvas_select_block(1);
    4664:	00100513          	li	a0,1
    4668:	dfdff0ef          	jal	4464 <canvas_select_block>
    canvas_fill(0U, 0U, (uint32_t)OSD_BLOCK_BYTES);
    466c:	00003637          	lui	a2,0x3
    4670:	74060613          	addi	a2,a2,1856 # 3740 <handle_frame+0x68>
    4674:	00000593          	li	a1,0
    4678:	00000513          	li	a0,0
    467c:	e91ff0ef          	jal	450c <canvas_fill>

    s_back = 0;
    4680:	9001ac23          	sw	zero,-1768(gp) # 9f58 <s_back>
    s_renders = 0;
    4684:	9001aa23          	sw	zero,-1772(gp) # 9f54 <s_renders>
    s_last_deferred = 0;
    4688:	9001a823          	sw	zero,-1776(gp) # 9f50 <s_last_deferred>
    render_and_commit();            /* 上电即有画面（P1 主菜单） */
    468c:	f61ff0ef          	jal	45ec <render_and_commit>
}
    4690:	00c12083          	lw	ra,12(sp)
    4694:	01010113          	addi	sp,sp,16
    4698:	00008067          	ret

0000469c <osd_engine_handle>:

uint8_t osd_engine_handle(protocol_stats_t *stats, const frame_t *frame,
                          protocol_response_t *resp, uint8_t *ack)
{
    469c:	ff010113          	addi	sp,sp,-16
    46a0:	00112623          	sw	ra,12(sp)
    46a4:	00812423          	sw	s0,8(sp)
    46a8:	00912223          	sw	s1,4(sp)
    46ac:	00060413          	mv	s0,a2
    46b0:	00068493          	mv	s1,a3
    uint8_t n;

    s_last_deferred = 0;
    46b4:	9001a823          	sw	zero,-1776(gp) # 9f50 <s_last_deferred>

    protocol_handle(stats, frame, resp);
    46b8:	b41ff0ef          	jal	41f8 <protocol_handle>
    if ((resp->send_ack == 0U) || (ack == 0)) {
    46bc:	01344503          	lbu	a0,19(s0)
    46c0:	04050a63          	beqz	a0,4714 <osd_engine_handle+0x78>
    46c4:	06048263          	beqz	s1,4728 <osd_engine_handle+0x8c>
        return 0U;
    }

    if (resp->defer_ack != 0U) {
    46c8:	01444783          	lbu	a5,20(s0)
    46cc:	00078e63          	beqz	a5,46e8 <osd_engine_handle+0x4c>
        /* 成功且需要等画布：先把画面做出来、提交掉，再把应答交出去。
         * 失败时 handler 返回 FAIL，defer_ack 为 0，直接走下面那支立即回。 */
        render_and_commit();
    46d0:	f1dff0ef          	jal	45ec <render_and_commit>
        s_last_deferred = 1;
    46d4:	00100713          	li	a4,1
    46d8:	90e1a823          	sw	a4,-1776(gp) # 9f50 <s_last_deferred>
         * 触发；留着它是为了让"状态脏了就渲染"这条不变量在引擎层始终成立，
         * 将来加一条"改了状态但不要求延迟应答"的命令时不会静默丢一帧。*/
        render_and_commit();
    }

    n = resp->ack_len;
    46dc:	01244503          	lbu	a0,18(s0)
    {
        uint8_t i;
        for (i = 0U; i < n; i++) {
    46e0:	00000793          	li	a5,0
    46e4:	02c0006f          	j	4710 <osd_engine_handle+0x74>
    } else if (ui_is_dirty()) {
    46e8:	444000ef          	jal	4b2c <ui_is_dirty>
    46ec:	fe0508e3          	beqz	a0,46dc <osd_engine_handle+0x40>
        render_and_commit();
    46f0:	efdff0ef          	jal	45ec <render_and_commit>
    46f4:	fe9ff06f          	j	46dc <osd_engine_handle+0x40>
            ack[i] = resp->ack[i];
    46f8:	00f48733          	add	a4,s1,a5
    46fc:	00f40633          	add	a2,s0,a5
    4700:	00064603          	lbu	a2,0(a2)
    4704:	00c70023          	sb	a2,0(a4) # a40000 <__freertos_irq_stack_top+0xa346c0>
        for (i = 0U; i < n; i++) {
    4708:	00178793          	addi	a5,a5,1
    470c:	0ff7f793          	zext.b	a5,a5
    4710:	fea7e4e3          	bltu	a5,a0,46f8 <osd_engine_handle+0x5c>
        }
    }
    return n;
}
    4714:	00c12083          	lw	ra,12(sp)
    4718:	00812403          	lw	s0,8(sp)
    471c:	00412483          	lw	s1,4(sp)
    4720:	01010113          	addi	sp,sp,16
    4724:	00008067          	ret
        return 0U;
    4728:	00000513          	li	a0,0
    472c:	fe9ff06f          	j	4714 <osd_engine_handle+0x78>

00004730 <composer_render>:
#include "font.h"
#include "ui.h"
#include "osd_config.h"

void composer_render(void)
{
    4730:	f9010113          	addi	sp,sp,-112
    4734:	06112623          	sw	ra,108(sp)
    4738:	06812423          	sw	s0,104(sp)
    473c:	06912223          	sw	s1,100(sp)
    4740:	07212023          	sw	s2,96(sp)
    4744:	05312e23          	sw	s3,92(sp)
    4748:	05412c23          	sw	s4,88(sp)
    474c:	05512a23          	sw	s5,84(sp)
    /* 一行位图 = 68 字节。放在栈上：这与画布大小无关，永远只是两行的量级，
     * 不会因为将来改画布尺寸而变成一个大数组。*/
    uint8_t  line[OSD_ROW_STRIDE];
    unsigned r, c, gy;

    for (r = 0u; r < OSD_GRID_ROWS; r++) {
    4750:	00000a93          	li	s5,0
    4754:	0ac0006f          	j	4800 <composer_render+0xd0>
                    line[c * 2u]      = OSD_PIXEL_KEY;
                    line[c * 2u + 1u] = OSD_PIXEL_KEY;
                    continue;
                }

                bits = font_row_bits(font_glyph(idx), gy);
    4758:	13c000ef          	jal	4894 <font_glyph>
    475c:	00090593          	mv	a1,s2
    4760:	15c000ef          	jal	48bc <font_row_bits>

                /* 高字节在前：bit 15..8 先落盘，于是"bit 7 最左"这条位图约定
                 * 与"bit 15 最左"的字形约定自动对齐。*/
                line[c * 2u]      = (uint8_t)(bits >> 8);
    4764:	00855713          	srli	a4,a0,0x8
    4768:	05040793          	addi	a5,s0,80
    476c:	002787b3          	add	a5,a5,sp
    4770:	fae78e23          	sb	a4,-68(a5)
                line[c * 2u + 1u] = (uint8_t)(bits & 0xFFu);
    4774:	05140793          	addi	a5,s0,81
    4778:	00278433          	add	s0,a5,sp
    477c:	faa40e23          	sb	a0,-68(s0)
            for (c = 0u; c < OSD_GRID_COLS; c++) {
    4780:	00148493          	addi	s1,s1,1
    4784:	02100793          	li	a5,33
    4788:	0497e063          	bltu	a5,s1,47c8 <composer_render+0x98>
                int idx = font_lookup(row_cells[c]);
    478c:	00149413          	slli	s0,s1,0x1
    4790:	008987b3          	add	a5,s3,s0
    4794:	0007d503          	lhu	a0,0(a5)
    4798:	0b0000ef          	jal	4848 <font_lookup>
                if (idx < 0) idx = font_lookup((uint16_t)'?');
    479c:	fa055ee3          	bgez	a0,4758 <composer_render+0x28>
    47a0:	03f00513          	li	a0,63
    47a4:	0a4000ef          	jal	4848 <font_lookup>
                if (idx < 0) {
    47a8:	fa0558e3          	bgez	a0,4758 <composer_render+0x28>
                    line[c * 2u]      = OSD_PIXEL_KEY;
    47ac:	05040793          	addi	a5,s0,80
    47b0:	002787b3          	add	a5,a5,sp
    47b4:	fa078e23          	sb	zero,-68(a5)
                    line[c * 2u + 1u] = OSD_PIXEL_KEY;
    47b8:	05140793          	addi	a5,s0,81
    47bc:	00278433          	add	s0,a5,sp
    47c0:	fa040e23          	sb	zero,-68(s0)
                    continue;
    47c4:	fbdff06f          	j	4780 <composer_render+0x50>
            }

            canvas_write((uint32_t)y * (uint32_t)OSD_ROW_STRIDE, line,
    47c8:	004a1513          	slli	a0,s4,0x4
    47cc:	01450533          	add	a0,a0,s4
    47d0:	04400613          	li	a2,68
    47d4:	00c10593          	addi	a1,sp,12
    47d8:	00251513          	slli	a0,a0,0x2
    47dc:	ca5ff0ef          	jal	4480 <canvas_write>
        for (gy = 0u; gy < OSD_GLYPH_H; gy++) {
    47e0:	00190913          	addi	s2,s2,1
    47e4:	00f00793          	li	a5,15
    47e8:	0127ea63          	bltu	a5,s2,47fc <composer_render+0xcc>
            unsigned y = r * OSD_GLYPH_H + gy;
    47ec:	004a9a13          	slli	s4,s5,0x4
    47f0:	012a0a33          	add	s4,s4,s2
            for (c = 0u; c < OSD_GRID_COLS; c++) {
    47f4:	00000493          	li	s1,0
    47f8:	f8dff06f          	j	4784 <composer_render+0x54>
    for (r = 0u; r < OSD_GRID_ROWS; r++) {
    47fc:	001a8a93          	addi	s5,s5,1
    4800:	00c00793          	li	a5,12
    4804:	0357e063          	bltu	a5,s5,4824 <composer_render+0xf4>
        const cell_t *row_cells = osd_buf[r];
    4808:	004a9993          	slli	s3,s5,0x4
    480c:	015989b3          	add	s3,s3,s5
    4810:	00299993          	slli	s3,s3,0x2
    4814:	f8818793          	addi	a5,gp,-120 # a5c8 <osd_buf>
    4818:	00f989b3          	add	s3,s3,a5
        for (gy = 0u; gy < OSD_GLYPH_H; gy++) {
    481c:	00000913          	li	s2,0
    4820:	fc5ff06f          	j	47e4 <composer_render+0xb4>
                         (uint32_t)OSD_ROW_STRIDE);
        }
    }
}
    4824:	06c12083          	lw	ra,108(sp)
    4828:	06812403          	lw	s0,104(sp)
    482c:	06412483          	lw	s1,100(sp)
    4830:	06012903          	lw	s2,96(sp)
    4834:	05c12983          	lw	s3,92(sp)
    4838:	05812a03          	lw	s4,88(sp)
    483c:	05412a83          	lw	s5,84(sp)
    4840:	07010113          	addi	sp,sp,112
    4844:	00008067          	ret

00004848 <font_lookup>:
#include "font16_bin.h"

uint16_t font_count(void) { return (uint16_t)FONT16_COUNT; }

int font_lookup(uint16_t cp)
{
    4848:	00050593          	mv	a1,a0
    int lo = 0, hi = (int)FONT16_COUNT - 1;
    484c:	0aa00613          	li	a2,170
    4850:	00000693          	li	a3,0

    while (lo <= hi) {
    4854:	0080006f          	j	485c <font_lookup+0x14>
        int mid = (lo + hi) >> 1;
        uint16_t v = font16_codepoints[mid];
        if (v == cp) return mid;
        if (v < cp) lo = mid + 1; else hi = mid - 1;
    4858:	fff50613          	addi	a2,a0,-1
    while (lo <= hi) {
    485c:	02d64863          	blt	a2,a3,488c <font_lookup+0x44>
        int mid = (lo + hi) >> 1;
    4860:	00c68733          	add	a4,a3,a2
    4864:	40175513          	srai	a0,a4,0x1
        uint16_t v = font16_codepoints[mid];
    4868:	0000a7b7          	lui	a5,0xa
    486c:	ffe77713          	andi	a4,a4,-2
    4870:	a8c78793          	addi	a5,a5,-1396 # 9a8c <font16_codepoints>
    4874:	00e787b3          	add	a5,a5,a4
    4878:	0007d783          	lhu	a5,0(a5)
        if (v == cp) return mid;
    487c:	00b78a63          	beq	a5,a1,4890 <font_lookup+0x48>
        if (v < cp) lo = mid + 1; else hi = mid - 1;
    4880:	fcb7fce3          	bgeu	a5,a1,4858 <font_lookup+0x10>
    4884:	00150693          	addi	a3,a0,1
    4888:	fd5ff06f          	j	485c <font_lookup+0x14>
    }
    return -1;
    488c:	fff00513          	li	a0,-1
}
    4890:	00008067          	ret

00004894 <font_glyph>:

const uint8_t *font_glyph(int idx)
{
    if (idx < 0 || idx >= (int)FONT16_COUNT) return font16_bitmap[0];
    4894:	0aa00793          	li	a5,170
    4898:	00a7ec63          	bltu	a5,a0,48b0 <font_glyph+0x1c>
    return font16_bitmap[idx];
    489c:	00551513          	slli	a0,a0,0x5
    48a0:	000087b7          	lui	a5,0x8
    48a4:	52c78793          	addi	a5,a5,1324 # 852c <font16_bitmap>
    48a8:	00f50533          	add	a0,a0,a5
    48ac:	00008067          	ret
    if (idx < 0 || idx >= (int)FONT16_COUNT) return font16_bitmap[0];
    48b0:	00008537          	lui	a0,0x8
    48b4:	52c50513          	addi	a0,a0,1324 # 852c <font16_bitmap>
}
    48b8:	00008067          	ret

000048bc <font_row_bits>:

uint16_t font_row_bits(const uint8_t *g, unsigned row)
{
    if (row >= OSD_GLYPH_H) row = OSD_GLYPH_H - 1u;   /* 越界保护：永远给合法数据 */
    48bc:	00f00793          	li	a5,15
    48c0:	00b7f463          	bgeu	a5,a1,48c8 <font_row_bits+0xc>
    48c4:	00f00593          	li	a1,15
    return (uint16_t)(((uint16_t)g[row * 2u] << 8) | g[row * 2u + 1u]);
    48c8:	00159593          	slli	a1,a1,0x1
    48cc:	00b50533          	add	a0,a0,a1
    48d0:	00054783          	lbu	a5,0(a0)
    48d4:	00154503          	lbu	a0,1(a0)
    48d8:	00879793          	slli	a5,a5,0x8
}
    48dc:	00f56533          	or	a0,a0,a5
    48e0:	00008067          	ret

000048e4 <grid_clear>:
* @note 全量重画语义的一部分：不清空的话，上一页残留的字符会在新页的空白处露出来。
******************************************************************************/
static void grid_clear(void)
{
    unsigned r, c;
    for (r = 0u; r < OSD_GRID_ROWS; r++)
    48e4:	00000593          	li	a1,0
    48e8:	0380006f          	j	4920 <grid_clear+0x3c>
        for (c = 0u; c < OSD_GRID_COLS; c++)
            osd_buf[r][c] = (cell_t)' ';
    48ec:	00459693          	slli	a3,a1,0x4
    48f0:	00b686b3          	add	a3,a3,a1
    48f4:	00169793          	slli	a5,a3,0x1
    48f8:	00c787b3          	add	a5,a5,a2
    48fc:	00179793          	slli	a5,a5,0x1
    4900:	f8818713          	addi	a4,gp,-120 # a5c8 <osd_buf>
    4904:	00f707b3          	add	a5,a4,a5
    4908:	02000713          	li	a4,32
    490c:	00e79023          	sh	a4,0(a5)
        for (c = 0u; c < OSD_GRID_COLS; c++)
    4910:	00160613          	addi	a2,a2,1
    4914:	02100793          	li	a5,33
    4918:	fcc7fae3          	bgeu	a5,a2,48ec <grid_clear+0x8>
    for (r = 0u; r < OSD_GRID_ROWS; r++)
    491c:	00158593          	addi	a1,a1,1
    4920:	00c00793          	li	a5,12
    4924:	00b7e663          	bltu	a5,a1,4930 <grid_clear+0x4c>
        for (c = 0u; c < OSD_GRID_COLS; c++)
    4928:	00000613          	li	a2,0
    492c:	fe9ff06f          	j	4914 <grid_clear+0x30>
}
    4930:	00008067          	ret

00004934 <ui_init>:
}

/* ---------------------------------------------------------------- API */

void ui_init(void)
{
    4934:	ff010113          	addi	sp,sp,-16
    4938:	00112623          	sw	ra,12(sp)
    s_state.page_id = 0x0000u;
    493c:	f7018793          	addi	a5,gp,-144 # a5b0 <s_state>
    4940:	00079023          	sh	zero,0(a5)
    s_state.sel     = 0u;
    4944:	00078123          	sb	zero,2(a5)
    s_state.flags   = UI_FLAG_VISIBLE;   /* 上电即显示主菜单（bit0 = UI 显示）*/
    4948:	00100713          	li	a4,1
    494c:	00e781a3          	sb	a4,3(a5)
    s_state.v[0]    = 3u;      /* 默认值取自 UI 规格 P2 原型 */
    4950:	00300693          	li	a3,3
    4954:	00d78223          	sb	a3,4(a5)
    s_state.v[1]    = 5u;
    4958:	00500693          	li	a3,5
    495c:	00d782a3          	sb	a3,5(a5)
    s_state.v[2]    = 7u;
    4960:	00700613          	li	a2,7
    4964:	00c78323          	sb	a2,6(a5)
    s_state.v[3]    = 5u;
    4968:	00d783a3          	sb	a3,7(a5)
    s_state.status  = 0u;
    496c:	00078423          	sb	zero,8(a5)
    s_state.dirty   = 1u;
    4970:	00e784a3          	sb	a4,9(a5)
    grid_clear();
    4974:	f71ff0ef          	jal	48e4 <grid_clear>
}
    4978:	00c12083          	lw	ra,12(sp)
    497c:	01010113          	addi	sp,sp,16
    4980:	00008067          	ret

00004984 <ui_set_view>:
*
* @note 失败时**状态完全不变**（含 flags）：这是"整帧拒绝"的口径 —— 部分生效会
*       让上位机回读到的状态既不是旧的也不是它要的新的，比直接失败更难排查。
******************************************************************************/
int ui_set_view(uint16_t page_id, uint8_t sel, uint8_t flags)
{
    4984:	ff010113          	addi	sp,sp,-16
    4988:	00112623          	sw	ra,12(sp)
    498c:	00812423          	sw	s0,8(sp)
    4990:	00912223          	sw	s1,4(sp)
    4994:	01212023          	sw	s2,0(sp)
    4998:	00050913          	mv	s2,a0
    499c:	00058493          	mv	s1,a1
    49a0:	00060413          	mv	s0,a2
    const scene_page_t *pg = scene_find(page_id);
    49a4:	1a8000ef          	jal	4b4c <scene_find>
    uint8_t f;

    if (pg == 0)               { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    49a8:	04050c63          	beqz	a0,4a00 <ui_set_view+0x7c>
    if (sel >= pg->item_count) { s_state.status |= UI_STATUS_BAD_PARAM; return -2; }
    49ac:	00c52783          	lw	a5,12(a0)
    49b0:	06f4f463          	bgeu	s1,a5,4a18 <ui_set_view+0x94>

    f = (uint8_t)(flags & UI_FLAG_MASK);        /* 保留位静默丢弃、不报错 */
    49b4:	00347713          	andi	a4,s0,3
    if ((f & UI_FLAG_EDIT) && (pg->value_slot[sel] < 0)) {
    49b8:	00247413          	andi	s0,s0,2
    49bc:	00040863          	beqz	s0,49cc <ui_set_view+0x48>
    49c0:	009507b3          	add	a5,a0,s1
    49c4:	05878783          	lb	a5,88(a5)
    49c8:	0607c463          	bltz	a5,4a30 <ui_set_view+0xac>
        s_state.status |= UI_STATUS_BAD_PARAM;
        return -3;
    }

    s_state.page_id = page_id;
    49cc:	f7018793          	addi	a5,gp,-144 # a5b0 <s_state>
    49d0:	01279023          	sh	s2,0(a5)
    s_state.sel     = sel;
    49d4:	00978123          	sb	s1,2(a5)
    s_state.flags   = f;
    49d8:	00e781a3          	sb	a4,3(a5)
    s_state.dirty   = 1u;
    49dc:	00100713          	li	a4,1
    49e0:	00e784a3          	sb	a4,9(a5)
    return 0;
    49e4:	00000513          	li	a0,0
}
    49e8:	00c12083          	lw	ra,12(sp)
    49ec:	00812403          	lw	s0,8(sp)
    49f0:	00412483          	lw	s1,4(sp)
    49f4:	00012903          	lw	s2,0(sp)
    49f8:	01010113          	addi	sp,sp,16
    49fc:	00008067          	ret
    if (pg == 0)               { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    4a00:	f7018793          	addi	a5,gp,-144 # a5b0 <s_state>
    4a04:	0087c703          	lbu	a4,8(a5)
    4a08:	00276713          	ori	a4,a4,2
    4a0c:	00e78423          	sb	a4,8(a5)
    4a10:	fff00513          	li	a0,-1
    4a14:	fd5ff06f          	j	49e8 <ui_set_view+0x64>
    if (sel >= pg->item_count) { s_state.status |= UI_STATUS_BAD_PARAM; return -2; }
    4a18:	f7018793          	addi	a5,gp,-144 # a5b0 <s_state>
    4a1c:	0087c703          	lbu	a4,8(a5)
    4a20:	00276713          	ori	a4,a4,2
    4a24:	00e78423          	sb	a4,8(a5)
    4a28:	ffe00513          	li	a0,-2
    4a2c:	fbdff06f          	j	49e8 <ui_set_view+0x64>
        s_state.status |= UI_STATUS_BAD_PARAM;
    4a30:	f7018793          	addi	a5,gp,-144 # a5b0 <s_state>
    4a34:	0087c703          	lbu	a4,8(a5)
    4a38:	00276713          	ori	a4,a4,2
    4a3c:	00e78423          	sb	a4,8(a5)
        return -3;
    4a40:	ffd00513          	li	a0,-3
    4a44:	fa5ff06f          	j	49e8 <ui_set_view+0x64>

00004a48 <ui_set_image_values>:
*       菜单回显与前端的 QUERY_VIEW 回读，没有连到任何图像处理通路。
*       这是本期明确的范围（任务 6.10），也是"改了参数画面没变"的原因。
******************************************************************************/
int ui_set_image_values(const uint8_t v[4])
{
    if (v[0] > UI_V_ENHANCE_MAX) { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    4a48:	00054703          	lbu	a4,0(a0)
    4a4c:	00500793          	li	a5,5
    4a50:	04e7e863          	bltu	a5,a4,4aa0 <ui_set_image_values+0x58>
    if ((v[1] > UI_V_OTHER_MAX) || (v[2] > UI_V_OTHER_MAX) || (v[3] > UI_V_OTHER_MAX)) {
    4a54:	00154683          	lbu	a3,1(a0)
    4a58:	00a00793          	li	a5,10
    4a5c:	04d7ee63          	bltu	a5,a3,4ab8 <ui_set_image_values+0x70>
    4a60:	00254683          	lbu	a3,2(a0)
    4a64:	04d7ea63          	bltu	a5,a3,4ab8 <ui_set_image_values+0x70>
    4a68:	00354683          	lbu	a3,3(a0)
    4a6c:	04d7e663          	bltu	a5,a3,4ab8 <ui_set_image_values+0x70>
        s_state.status |= UI_STATUS_BAD_PARAM;
        return -1;
    }

    s_state.v[0] = v[0];
    4a70:	f7018793          	addi	a5,gp,-144 # a5b0 <s_state>
    4a74:	00e78223          	sb	a4,4(a5)
    s_state.v[1] = v[1];
    4a78:	00154703          	lbu	a4,1(a0)
    4a7c:	00e782a3          	sb	a4,5(a5)
    s_state.v[2] = v[2];
    4a80:	00254703          	lbu	a4,2(a0)
    4a84:	00e78323          	sb	a4,6(a5)
    s_state.v[3] = v[3];
    4a88:	00354703          	lbu	a4,3(a0)
    4a8c:	00e783a3          	sb	a4,7(a5)
    s_state.dirty = 1u;
    4a90:	00100713          	li	a4,1
    4a94:	00e784a3          	sb	a4,9(a5)
    return 0;
    4a98:	00000513          	li	a0,0
}
    4a9c:	00008067          	ret
    if (v[0] > UI_V_ENHANCE_MAX) { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    4aa0:	f7018793          	addi	a5,gp,-144 # a5b0 <s_state>
    4aa4:	0087c703          	lbu	a4,8(a5)
    4aa8:	00276713          	ori	a4,a4,2
    4aac:	00e78423          	sb	a4,8(a5)
    4ab0:	fff00513          	li	a0,-1
    4ab4:	00008067          	ret
        s_state.status |= UI_STATUS_BAD_PARAM;
    4ab8:	f7018793          	addi	a5,gp,-144 # a5b0 <s_state>
    4abc:	0087c703          	lbu	a4,8(a5)
    4ac0:	00276713          	ori	a4,a4,2
    4ac4:	00e78423          	sb	a4,8(a5)
        return -1;
    4ac8:	fff00513          	li	a0,-1
    4acc:	00008067          	ret

00004ad0 <ui_query_view>:
* @note **不再有 item_count 与 fw_version**（D11 第 6 项）：协议文档 §3.3 与工具
*       都只认这 8 个字节，多写两个会直接变成 CRC 对不上的 14 字节 body。
******************************************************************************/
int ui_query_view(uint8_t resp[UI_QUERY_PAYLOAD_LEN])
{
    resp[0] = (uint8_t)(s_state.page_id >> 8);
    4ad0:	f7018793          	addi	a5,gp,-144 # a5b0 <s_state>
    4ad4:	0007d703          	lhu	a4,0(a5)
    4ad8:	00875693          	srli	a3,a4,0x8
    4adc:	00d50023          	sb	a3,0(a0)
    resp[1] = (uint8_t)(s_state.page_id & 0xFFu);
    4ae0:	00e500a3          	sb	a4,1(a0)
    resp[2] = s_state.sel;
    4ae4:	0027c703          	lbu	a4,2(a5)
    4ae8:	00e50123          	sb	a4,2(a0)
    resp[3] = s_state.flags;
    4aec:	0037c703          	lbu	a4,3(a5)
    4af0:	00e501a3          	sb	a4,3(a0)
    resp[4] = s_state.v[0];
    4af4:	0047c703          	lbu	a4,4(a5)
    4af8:	00e50223          	sb	a4,4(a0)
    resp[5] = s_state.v[1];
    4afc:	0057c703          	lbu	a4,5(a5)
    4b00:	00e502a3          	sb	a4,5(a0)
    resp[6] = s_state.v[2];
    4b04:	0067c703          	lbu	a4,6(a5)
    4b08:	00e50323          	sb	a4,6(a0)
    resp[7] = s_state.v[3];
    4b0c:	0077c783          	lbu	a5,7(a5)
    4b10:	00f503a3          	sb	a5,7(a0)
    return 0;
}
    4b14:	00000513          	li	a0,0
    4b18:	00008067          	ret

00004b1c <ui_is_visible>:

int  ui_is_visible(void)  { return (s_state.flags & UI_FLAG_VISIBLE) ? 1 : 0; }
    4b1c:	f7018793          	addi	a5,gp,-144 # a5b0 <s_state>
    4b20:	0037c503          	lbu	a0,3(a5)
    4b24:	00157513          	andi	a0,a0,1
    4b28:	00008067          	ret

00004b2c <ui_is_dirty>:
int  ui_is_dirty(void)    { return (int)s_state.dirty; }
    4b2c:	f7018793          	addi	a5,gp,-144 # a5b0 <s_state>
    4b30:	0097c503          	lbu	a0,9(a5)
    4b34:	00008067          	ret

00004b38 <ui_clear_dirty>:
void ui_clear_dirty(void) { s_state.dirty = 0u; }
    4b38:	f7018793          	addi	a5,gp,-144 # a5b0 <s_state>
    4b3c:	000784a3          	sb	zero,9(a5)
    4b40:	00008067          	ret

00004b44 <scene_page_count>:
        },
        { -1, -1, -1, -1 }
    },
};

unsigned scene_page_count(void) { return (unsigned)(sizeof(s_pages) / sizeof(s_pages[0])); }
    4b44:	00300513          	li	a0,3
    4b48:	00008067          	ret

00004b4c <scene_find>:
const scene_page_t *scene_at(unsigned i) { return &s_pages[i]; }

const scene_page_t *scene_find(uint16_t page_id)
{
    4b4c:	ff010113          	addi	sp,sp,-16
    4b50:	00112623          	sw	ra,12(sp)
    4b54:	00812423          	sw	s0,8(sp)
    4b58:	00912223          	sw	s1,4(sp)
    4b5c:	00050493          	mv	s1,a0
    unsigned i;
    for (i = 0u; i < scene_page_count(); i++) {
    4b60:	00000413          	li	s0,0
    4b64:	0080006f          	j	4b6c <scene_find+0x20>
    4b68:	00140413          	addi	s0,s0,1
    4b6c:	fd9ff0ef          	jal	4b44 <scene_page_count>
    4b70:	02a47863          	bgeu	s0,a0,4ba0 <scene_find+0x54>
        if (s_pages[i].page_id == page_id) return &s_pages[i];
    4b74:	0000a7b7          	lui	a5,0xa
    4b78:	06400713          	li	a4,100
    4b7c:	02e40733          	mul	a4,s0,a4
    4b80:	be478793          	addi	a5,a5,-1052 # 9be4 <s_pages>
    4b84:	00e787b3          	add	a5,a5,a4
    4b88:	0007d783          	lhu	a5,0(a5)
    4b8c:	fc979ee3          	bne	a5,s1,4b68 <scene_find+0x1c>
    4b90:	0000a7b7          	lui	a5,0xa
    4b94:	be478793          	addi	a5,a5,-1052 # 9be4 <s_pages>
    4b98:	00f70533          	add	a0,a4,a5
    4b9c:	0080006f          	j	4ba4 <scene_find+0x58>
    }
    return 0;   /* 未知 page_id：由命令层判非法（统一口径），不做兜底渲染 */
    4ba0:	00000513          	li	a0,0
}
    4ba4:	00c12083          	lw	ra,12(sp)
    4ba8:	00812403          	lw	s0,8(sp)
    4bac:	00412483          	lw	s1,4(sp)
    4bb0:	01010113          	addi	sp,sp,16
    4bb4:	00008067          	ret

00004bb8 <trap_entry>:

trap_entry:
#ifdef __riscv_flen
  addi sp, sp, -STACK_SIZE
#else
  addi sp, sp, -64
    4bb8:	fc010113          	addi	sp,sp,-64
#endif
  sw x1,   0*4(sp)
    4bbc:	00112023          	sw	ra,0(sp)
  sw x5,   1*4(sp)
    4bc0:	00512223          	sw	t0,4(sp)
  sw x6,   2*4(sp)
    4bc4:	00612423          	sw	t1,8(sp)
  sw x7,   3*4(sp)
    4bc8:	00712623          	sw	t2,12(sp)
  sw x10,  4*4(sp)
    4bcc:	00a12823          	sw	a0,16(sp)
  sw x11,  5*4(sp)
    4bd0:	00b12a23          	sw	a1,20(sp)
  sw x12,  6*4(sp)
    4bd4:	00c12c23          	sw	a2,24(sp)
  sw x13,  7*4(sp)
    4bd8:	00d12e23          	sw	a3,28(sp)
  sw x14,  8*4(sp)
    4bdc:	02e12023          	sw	a4,32(sp)
  sw x15,  9*4(sp)
    4be0:	02f12223          	sw	a5,36(sp)
  sw x16, 10*4(sp)
    4be4:	03012423          	sw	a6,40(sp)
  sw x17, 11*4(sp)
    4be8:	03112623          	sw	a7,44(sp)
  sw x28, 12*4(sp)
    4bec:	03c12823          	sw	t3,48(sp)
  sw x29, 13*4(sp)
    4bf0:	03d12a23          	sw	t4,52(sp)
  sw x30, 14*4(sp)
    4bf4:	03e12c23          	sw	t5,56(sp)
  sw x31, 15*4(sp)
    4bf8:	03f12e23          	sw	t6,60(sp)
  FSTORE f30, 64 + 18*FPR_SIZE(sp)
  FSTORE f31, 64 + 19*FPR_SIZE(sp)
  csrr t0, fcsr
  sw t0, 64 + 20*FPR_SIZE(sp)
#endif
  call trap
    4bfc:	bc1fe0ef          	jal	37bc <trap>
  FLOAD f28, 64 + 16*FPR_SIZE(sp)
  FLOAD f29, 64 + 17*FPR_SIZE(sp)
  FLOAD f30, 64 + 18*FPR_SIZE(sp)
  FLOAD f31, 64 + 19*FPR_SIZE(sp)
#endif
  lw x1 ,  0*4(sp)
    4c00:	00012083          	lw	ra,0(sp)
  lw x5,   1*4(sp)
    4c04:	00412283          	lw	t0,4(sp)
  lw x6,   2*4(sp)
    4c08:	00812303          	lw	t1,8(sp)
  lw x7,   3*4(sp)
    4c0c:	00c12383          	lw	t2,12(sp)
  lw x10,  4*4(sp)
    4c10:	01012503          	lw	a0,16(sp)
  lw x11,  5*4(sp)
    4c14:	01412583          	lw	a1,20(sp)
  lw x12,  6*4(sp)
    4c18:	01812603          	lw	a2,24(sp)
  lw x13,  7*4(sp)
    4c1c:	01c12683          	lw	a3,28(sp)
  lw x14,  8*4(sp)
    4c20:	02012703          	lw	a4,32(sp)
  lw x15,  9*4(sp)
    4c24:	02412783          	lw	a5,36(sp)
  lw x16, 10*4(sp)
    4c28:	02812803          	lw	a6,40(sp)
  lw x17, 11*4(sp)
    4c2c:	02c12883          	lw	a7,44(sp)
  lw x28, 12*4(sp)
    4c30:	03012e03          	lw	t3,48(sp)
  lw x29, 13*4(sp)
    4c34:	03412e83          	lw	t4,52(sp)
  lw x30, 14*4(sp)
    4c38:	03812f03          	lw	t5,56(sp)
  lw x31, 15*4(sp)
    4c3c:	03c12f83          	lw	t6,60(sp)
#ifdef __riscv_flen
  addi sp, sp, STACK_SIZE
#else
  addi sp, sp, 64
    4c40:	04010113          	addi	sp,sp,64
#endif
    4c44:	30200073          	mret

00004c48 <__udivdi3>:
    4c48:	00060813          	mv	a6,a2
    4c4c:	00050893          	mv	a7,a0
    4c50:	00058713          	mv	a4,a1
    4c54:	0e069063          	bnez	a3,4d34 <__udivdi3+0xec>
    4c58:	12c5fe63          	bgeu	a1,a2,4d94 <__udivdi3+0x14c>
    4c5c:	000107b7          	lui	a5,0x10
    4c60:	1ef66e63          	bltu	a2,a5,4e5c <__udivdi3+0x214>
    4c64:	010007b7          	lui	a5,0x1000
    4c68:	01800693          	li	a3,24
    4c6c:	00f67463          	bgeu	a2,a5,4c74 <__udivdi3+0x2c>
    4c70:	01000693          	li	a3,16
    4c74:	00d65333          	srl	t1,a2,a3
    4c78:	00005797          	auipc	a5,0x5
    4c7c:	0d878793          	addi	a5,a5,216 # 9d50 <__clz_tab>
    4c80:	006787b3          	add	a5,a5,t1
    4c84:	0007c783          	lbu	a5,0(a5)
    4c88:	02000313          	li	t1,32
    4c8c:	00d787b3          	add	a5,a5,a3
    4c90:	40f306b3          	sub	a3,t1,a5
    4c94:	00f30c63          	beq	t1,a5,4cac <__udivdi3+0x64>
    4c98:	00d59733          	sll	a4,a1,a3
    4c9c:	00f557b3          	srl	a5,a0,a5
    4ca0:	00d61833          	sll	a6,a2,a3
    4ca4:	00e7e733          	or	a4,a5,a4
    4ca8:	00d518b3          	sll	a7,a0,a3
    4cac:	01085613          	srli	a2,a6,0x10
    4cb0:	02c75533          	divu	a0,a4,a2
    4cb4:	01081693          	slli	a3,a6,0x10
    4cb8:	0106d693          	srli	a3,a3,0x10
    4cbc:	0108d793          	srli	a5,a7,0x10
    4cc0:	02c77733          	remu	a4,a4,a2
    4cc4:	02a685b3          	mul	a1,a3,a0
    4cc8:	01071713          	slli	a4,a4,0x10
    4ccc:	00e7e7b3          	or	a5,a5,a4
    4cd0:	00b7fc63          	bgeu	a5,a1,4ce8 <__udivdi3+0xa0>
    4cd4:	00f807b3          	add	a5,a6,a5
    4cd8:	fff50713          	addi	a4,a0,-1
    4cdc:	0107e463          	bltu	a5,a6,4ce4 <__udivdi3+0x9c>
    4ce0:	40b7e063          	bltu	a5,a1,50e0 <__udivdi3+0x498>
    4ce4:	00070513          	mv	a0,a4
    4ce8:	40b787b3          	sub	a5,a5,a1
    4cec:	02c7d733          	divu	a4,a5,a2
    4cf0:	01089893          	slli	a7,a7,0x10
    4cf4:	0108d893          	srli	a7,a7,0x10
    4cf8:	02c7f7b3          	remu	a5,a5,a2
    4cfc:	02e686b3          	mul	a3,a3,a4
    4d00:	01079793          	slli	a5,a5,0x10
    4d04:	00f8e8b3          	or	a7,a7,a5
    4d08:	00d8fe63          	bgeu	a7,a3,4d24 <__udivdi3+0xdc>
    4d0c:	011808b3          	add	a7,a6,a7
    4d10:	fff70793          	addi	a5,a4,-1
    4d14:	0108e663          	bltu	a7,a6,4d20 <__udivdi3+0xd8>
    4d18:	ffe70713          	addi	a4,a4,-2
    4d1c:	00d8e463          	bltu	a7,a3,4d24 <__udivdi3+0xdc>
    4d20:	00078713          	mv	a4,a5
    4d24:	01051513          	slli	a0,a0,0x10
    4d28:	00e56533          	or	a0,a0,a4
    4d2c:	00000593          	li	a1,0
    4d30:	00008067          	ret
    4d34:	00d5f863          	bgeu	a1,a3,4d44 <__udivdi3+0xfc>
    4d38:	00000593          	li	a1,0
    4d3c:	00000513          	li	a0,0
    4d40:	00008067          	ret
    4d44:	000107b7          	lui	a5,0x10
    4d48:	1ef6e863          	bltu	a3,a5,4f38 <__udivdi3+0x2f0>
    4d4c:	01000737          	lui	a4,0x1000
    4d50:	01800793          	li	a5,24
    4d54:	00e6f463          	bgeu	a3,a4,4d5c <__udivdi3+0x114>
    4d58:	01000793          	li	a5,16
    4d5c:	00f6d833          	srl	a6,a3,a5
    4d60:	00005717          	auipc	a4,0x5
    4d64:	ff070713          	addi	a4,a4,-16 # 9d50 <__clz_tab>
    4d68:	01070733          	add	a4,a4,a6
    4d6c:	00074703          	lbu	a4,0(a4)
    4d70:	02000893          	li	a7,32
    4d74:	00f70733          	add	a4,a4,a5
    4d78:	40e88833          	sub	a6,a7,a4
    4d7c:	1ee89663          	bne	a7,a4,4f68 <__udivdi3+0x320>
    4d80:	32b6e463          	bltu	a3,a1,50a8 <__udivdi3+0x460>
    4d84:	00c53533          	sltu	a0,a0,a2
    4d88:	00153513          	seqz	a0,a0
    4d8c:	00000593          	li	a1,0
    4d90:	00008067          	ret
    4d94:	0c060c63          	beqz	a2,4e6c <__udivdi3+0x224>
    4d98:	000107b7          	lui	a5,0x10
    4d9c:	2ef67c63          	bgeu	a2,a5,5094 <__udivdi3+0x44c>
    4da0:	10063713          	sltiu	a4,a2,256
    4da4:	00173713          	seqz	a4,a4
    4da8:	00371713          	slli	a4,a4,0x3
    4dac:	00e656b3          	srl	a3,a2,a4
    4db0:	00005797          	auipc	a5,0x5
    4db4:	fa078793          	addi	a5,a5,-96 # 9d50 <__clz_tab>
    4db8:	00d787b3          	add	a5,a5,a3
    4dbc:	0007c783          	lbu	a5,0(a5)
    4dc0:	02000693          	li	a3,32
    4dc4:	00e787b3          	add	a5,a5,a4
    4dc8:	40f68eb3          	sub	t4,a3,a5
    4dcc:	0cf69463          	bne	a3,a5,4e94 <__udivdi3+0x24c>
    4dd0:	40c587b3          	sub	a5,a1,a2
    4dd4:	01065693          	srli	a3,a2,0x10
    4dd8:	01061613          	slli	a2,a2,0x10
    4ddc:	01065613          	srli	a2,a2,0x10
    4de0:	00100593          	li	a1,1
    4de4:	02d7d533          	divu	a0,a5,a3
    4de8:	0108d713          	srli	a4,a7,0x10
    4dec:	02d7f7b3          	remu	a5,a5,a3
    4df0:	02c50333          	mul	t1,a0,a2
    4df4:	01079793          	slli	a5,a5,0x10
    4df8:	00f767b3          	or	a5,a4,a5
    4dfc:	0067fc63          	bgeu	a5,t1,4e14 <__udivdi3+0x1cc>
    4e00:	00f807b3          	add	a5,a6,a5
    4e04:	fff50713          	addi	a4,a0,-1
    4e08:	0107e463          	bltu	a5,a6,4e10 <__udivdi3+0x1c8>
    4e0c:	2c67e463          	bltu	a5,t1,50d4 <__udivdi3+0x48c>
    4e10:	00070513          	mv	a0,a4
    4e14:	406787b3          	sub	a5,a5,t1
    4e18:	02d7d733          	divu	a4,a5,a3
    4e1c:	01089893          	slli	a7,a7,0x10
    4e20:	0108d893          	srli	a7,a7,0x10
    4e24:	02d7f7b3          	remu	a5,a5,a3
    4e28:	02c70633          	mul	a2,a4,a2
    4e2c:	01079793          	slli	a5,a5,0x10
    4e30:	00f8e8b3          	or	a7,a7,a5
    4e34:	00c8fe63          	bgeu	a7,a2,4e50 <__udivdi3+0x208>
    4e38:	011808b3          	add	a7,a6,a7
    4e3c:	fff70793          	addi	a5,a4,-1
    4e40:	0108e663          	bltu	a7,a6,4e4c <__udivdi3+0x204>
    4e44:	ffe70713          	addi	a4,a4,-2
    4e48:	00c8e463          	bltu	a7,a2,4e50 <__udivdi3+0x208>
    4e4c:	00078713          	mv	a4,a5
    4e50:	01051513          	slli	a0,a0,0x10
    4e54:	00e56533          	or	a0,a0,a4
    4e58:	00008067          	ret
    4e5c:	10063693          	sltiu	a3,a2,256
    4e60:	0016b693          	seqz	a3,a3
    4e64:	00369693          	slli	a3,a3,0x3
    4e68:	e0dff06f          	j	4c74 <__udivdi3+0x2c>
    4e6c:	00000693          	li	a3,0
    4e70:	00005797          	auipc	a5,0x5
    4e74:	ee078793          	addi	a5,a5,-288 # 9d50 <__clz_tab>
    4e78:	00d787b3          	add	a5,a5,a3
    4e7c:	0007c783          	lbu	a5,0(a5)
    4e80:	00000713          	li	a4,0
    4e84:	02000693          	li	a3,32
    4e88:	00e787b3          	add	a5,a5,a4
    4e8c:	40f68eb3          	sub	t4,a3,a5
    4e90:	f4f680e3          	beq	a3,a5,4dd0 <__udivdi3+0x188>
    4e94:	01d61833          	sll	a6,a2,t4
    4e98:	00f5d333          	srl	t1,a1,a5
    4e9c:	01085693          	srli	a3,a6,0x10
    4ea0:	02d35e33          	divu	t3,t1,a3
    4ea4:	01081613          	slli	a2,a6,0x10
    4ea8:	01d595b3          	sll	a1,a1,t4
    4eac:	01065613          	srli	a2,a2,0x10
    4eb0:	00f557b3          	srl	a5,a0,a5
    4eb4:	00b7e7b3          	or	a5,a5,a1
    4eb8:	0107d713          	srli	a4,a5,0x10
    4ebc:	01d518b3          	sll	a7,a0,t4
    4ec0:	02d37333          	remu	t1,t1,a3
    4ec4:	03c605b3          	mul	a1,a2,t3
    4ec8:	01031313          	slli	t1,t1,0x10
    4ecc:	00676733          	or	a4,a4,t1
    4ed0:	00b77e63          	bgeu	a4,a1,4eec <__udivdi3+0x2a4>
    4ed4:	00e80733          	add	a4,a6,a4
    4ed8:	fffe0513          	addi	a0,t3,-1
    4edc:	1f076463          	bltu	a4,a6,50c4 <__udivdi3+0x47c>
    4ee0:	1eb77263          	bgeu	a4,a1,50c4 <__udivdi3+0x47c>
    4ee4:	ffee0e13          	addi	t3,t3,-2
    4ee8:	01070733          	add	a4,a4,a6
    4eec:	40b70733          	sub	a4,a4,a1
    4ef0:	02d75533          	divu	a0,a4,a3
    4ef4:	01079793          	slli	a5,a5,0x10
    4ef8:	0107d793          	srli	a5,a5,0x10
    4efc:	02d77733          	remu	a4,a4,a3
    4f00:	02a60333          	mul	t1,a2,a0
    4f04:	01071713          	slli	a4,a4,0x10
    4f08:	00e7e7b3          	or	a5,a5,a4
    4f0c:	0067fe63          	bgeu	a5,t1,4f28 <__udivdi3+0x2e0>
    4f10:	00f807b3          	add	a5,a6,a5
    4f14:	fff50713          	addi	a4,a0,-1
    4f18:	1907ee63          	bltu	a5,a6,50b4 <__udivdi3+0x46c>
    4f1c:	1867fc63          	bgeu	a5,t1,50b4 <__udivdi3+0x46c>
    4f20:	ffe50513          	addi	a0,a0,-2
    4f24:	010787b3          	add	a5,a5,a6
    4f28:	010e1593          	slli	a1,t3,0x10
    4f2c:	406787b3          	sub	a5,a5,t1
    4f30:	00a5e5b3          	or	a1,a1,a0
    4f34:	eb1ff06f          	j	4de4 <__udivdi3+0x19c>
    4f38:	1006b793          	sltiu	a5,a3,256
    4f3c:	0017b793          	seqz	a5,a5
    4f40:	00379793          	slli	a5,a5,0x3
    4f44:	00f6d833          	srl	a6,a3,a5
    4f48:	00005717          	auipc	a4,0x5
    4f4c:	e0870713          	addi	a4,a4,-504 # 9d50 <__clz_tab>
    4f50:	01070733          	add	a4,a4,a6
    4f54:	00074703          	lbu	a4,0(a4)
    4f58:	02000893          	li	a7,32
    4f5c:	00f70733          	add	a4,a4,a5
    4f60:	40e88833          	sub	a6,a7,a4
    4f64:	e0e88ee3          	beq	a7,a4,4d80 <__udivdi3+0x138>
    4f68:	00e65e33          	srl	t3,a2,a4
    4f6c:	010696b3          	sll	a3,a3,a6
    4f70:	00de6e33          	or	t3,t3,a3
    4f74:	00e5d8b3          	srl	a7,a1,a4
    4f78:	010e5e93          	srli	t4,t3,0x10
    4f7c:	03d8d7b3          	divu	a5,a7,t4
    4f80:	010e1313          	slli	t1,t3,0x10
    4f84:	010595b3          	sll	a1,a1,a6
    4f88:	01035313          	srli	t1,t1,0x10
    4f8c:	00e55733          	srl	a4,a0,a4
    4f90:	00b76733          	or	a4,a4,a1
    4f94:	01075693          	srli	a3,a4,0x10
    4f98:	01061633          	sll	a2,a2,a6
    4f9c:	03d8f8b3          	remu	a7,a7,t4
    4fa0:	02f305b3          	mul	a1,t1,a5
    4fa4:	01089893          	slli	a7,a7,0x10
    4fa8:	0116e6b3          	or	a3,a3,a7
    4fac:	00b6fe63          	bgeu	a3,a1,4fc8 <__udivdi3+0x380>
    4fb0:	00de06b3          	add	a3,t3,a3
    4fb4:	fff78893          	addi	a7,a5,-1
    4fb8:	11c6ea63          	bltu	a3,t3,50cc <__udivdi3+0x484>
    4fbc:	10b6f863          	bgeu	a3,a1,50cc <__udivdi3+0x484>
    4fc0:	ffe78793          	addi	a5,a5,-2
    4fc4:	01c686b3          	add	a3,a3,t3
    4fc8:	40b686b3          	sub	a3,a3,a1
    4fcc:	03d6d5b3          	divu	a1,a3,t4
    4fd0:	01071713          	slli	a4,a4,0x10
    4fd4:	01075713          	srli	a4,a4,0x10
    4fd8:	03d6f6b3          	remu	a3,a3,t4
    4fdc:	02b308b3          	mul	a7,t1,a1
    4fe0:	01069693          	slli	a3,a3,0x10
    4fe4:	00d76733          	or	a4,a4,a3
    4fe8:	01177e63          	bgeu	a4,a7,5004 <__udivdi3+0x3bc>
    4fec:	00ee0733          	add	a4,t3,a4
    4ff0:	fff58693          	addi	a3,a1,-1
    4ff4:	0dc76463          	bltu	a4,t3,50bc <__udivdi3+0x474>
    4ff8:	0d177263          	bgeu	a4,a7,50bc <__udivdi3+0x474>
    4ffc:	ffe58593          	addi	a1,a1,-2
    5000:	01c70733          	add	a4,a4,t3
    5004:	01079793          	slli	a5,a5,0x10
    5008:	00010eb7          	lui	t4,0x10
    500c:	00b7e7b3          	or	a5,a5,a1
    5010:	fffe8693          	addi	a3,t4,-1 # ffff <__freertos_irq_stack_top+0x46bf>
    5014:	00d7f5b3          	and	a1,a5,a3
    5018:	0107d313          	srli	t1,a5,0x10
    501c:	00d676b3          	and	a3,a2,a3
    5020:	01065613          	srli	a2,a2,0x10
    5024:	02d58e33          	mul	t3,a1,a3
    5028:	41170733          	sub	a4,a4,a7
    502c:	02d306b3          	mul	a3,t1,a3
    5030:	010e5893          	srli	a7,t3,0x10
    5034:	02c585b3          	mul	a1,a1,a2
    5038:	00d585b3          	add	a1,a1,a3
    503c:	00b885b3          	add	a1,a7,a1
    5040:	02c30333          	mul	t1,t1,a2
    5044:	00d5f463          	bgeu	a1,a3,504c <__udivdi3+0x404>
    5048:	01d30333          	add	t1,t1,t4
    504c:	0105d693          	srli	a3,a1,0x10
    5050:	006686b3          	add	a3,a3,t1
    5054:	02d76a63          	bltu	a4,a3,5088 <__udivdi3+0x440>
    5058:	00d70863          	beq	a4,a3,5068 <__udivdi3+0x420>
    505c:	00078513          	mv	a0,a5
    5060:	00000593          	li	a1,0
    5064:	00008067          	ret
    5068:	000106b7          	lui	a3,0x10
    506c:	fff68693          	addi	a3,a3,-1 # ffff <__freertos_irq_stack_top+0x46bf>
    5070:	00d5f733          	and	a4,a1,a3
    5074:	01071713          	slli	a4,a4,0x10
    5078:	00de7e33          	and	t3,t3,a3
    507c:	01051533          	sll	a0,a0,a6
    5080:	01c70733          	add	a4,a4,t3
    5084:	fce57ce3          	bgeu	a0,a4,505c <__udivdi3+0x414>
    5088:	fff78513          	addi	a0,a5,-1
    508c:	00000593          	li	a1,0
    5090:	00008067          	ret
    5094:	010007b7          	lui	a5,0x1000
    5098:	04f67a63          	bgeu	a2,a5,50ec <__udivdi3+0x4a4>
    509c:	01065693          	srli	a3,a2,0x10
    50a0:	01000713          	li	a4,16
    50a4:	d0dff06f          	j	4db0 <__udivdi3+0x168>
    50a8:	00000593          	li	a1,0
    50ac:	00100513          	li	a0,1
    50b0:	00008067          	ret
    50b4:	00070513          	mv	a0,a4
    50b8:	e71ff06f          	j	4f28 <__udivdi3+0x2e0>
    50bc:	00068593          	mv	a1,a3
    50c0:	f45ff06f          	j	5004 <__udivdi3+0x3bc>
    50c4:	00050e13          	mv	t3,a0
    50c8:	e25ff06f          	j	4eec <__udivdi3+0x2a4>
    50cc:	00088793          	mv	a5,a7
    50d0:	ef9ff06f          	j	4fc8 <__udivdi3+0x380>
    50d4:	ffe50513          	addi	a0,a0,-2
    50d8:	010787b3          	add	a5,a5,a6
    50dc:	d39ff06f          	j	4e14 <__udivdi3+0x1cc>
    50e0:	ffe50513          	addi	a0,a0,-2
    50e4:	010787b3          	add	a5,a5,a6
    50e8:	c01ff06f          	j	4ce8 <__udivdi3+0xa0>
    50ec:	01865693          	srli	a3,a2,0x18
    50f0:	01800713          	li	a4,24
    50f4:	cbdff06f          	j	4db0 <__udivdi3+0x168>

000050f8 <__umoddi3>:
    50f8:	00060813          	mv	a6,a2
    50fc:	00050893          	mv	a7,a0
    5100:	00058793          	mv	a5,a1
    5104:	00058713          	mv	a4,a1
    5108:	0c069863          	bnez	a3,51d8 <__umoddi3+0xe0>
    510c:	12c5fa63          	bgeu	a1,a2,5240 <__umoddi3+0x148>
    5110:	000107b7          	lui	a5,0x10
    5114:	1cf66c63          	bltu	a2,a5,52ec <__umoddi3+0x1f4>
    5118:	010007b7          	lui	a5,0x1000
    511c:	01800693          	li	a3,24
    5120:	00f67463          	bgeu	a2,a5,5128 <__umoddi3+0x30>
    5124:	01000693          	li	a3,16
    5128:	00d65333          	srl	t1,a2,a3
    512c:	00005797          	auipc	a5,0x5
    5130:	c2478793          	addi	a5,a5,-988 # 9d50 <__clz_tab>
    5134:	006787b3          	add	a5,a5,t1
    5138:	0007c783          	lbu	a5,0(a5)
    513c:	02000313          	li	t1,32
    5140:	00d787b3          	add	a5,a5,a3
    5144:	40f306b3          	sub	a3,t1,a5
    5148:	00f30c63          	beq	t1,a5,5160 <__umoddi3+0x68>
    514c:	00d59733          	sll	a4,a1,a3
    5150:	00f557b3          	srl	a5,a0,a5
    5154:	00d61833          	sll	a6,a2,a3
    5158:	00e7e733          	or	a4,a5,a4
    515c:	00d518b3          	sll	a7,a0,a3
    5160:	01085593          	srli	a1,a6,0x10
    5164:	02b75633          	divu	a2,a4,a1
    5168:	01081313          	slli	t1,a6,0x10
    516c:	01035313          	srli	t1,t1,0x10
    5170:	0108d793          	srli	a5,a7,0x10
    5174:	02b77733          	remu	a4,a4,a1
    5178:	02660633          	mul	a2,a2,t1
    517c:	01071713          	slli	a4,a4,0x10
    5180:	00e7e7b3          	or	a5,a5,a4
    5184:	00c7f863          	bgeu	a5,a2,5194 <__umoddi3+0x9c>
    5188:	00f807b3          	add	a5,a6,a5
    518c:	0107e463          	bltu	a5,a6,5194 <__umoddi3+0x9c>
    5190:	3cc7e263          	bltu	a5,a2,5554 <__umoddi3+0x45c>
    5194:	40c787b3          	sub	a5,a5,a2
    5198:	02b7d733          	divu	a4,a5,a1
    519c:	01089513          	slli	a0,a7,0x10
    51a0:	01055513          	srli	a0,a0,0x10
    51a4:	02b7f7b3          	remu	a5,a5,a1
    51a8:	02670733          	mul	a4,a4,t1
    51ac:	01079793          	slli	a5,a5,0x10
    51b0:	00f56533          	or	a0,a0,a5
    51b4:	00e57a63          	bgeu	a0,a4,51c8 <__umoddi3+0xd0>
    51b8:	00a80533          	add	a0,a6,a0
    51bc:	01056663          	bltu	a0,a6,51c8 <__umoddi3+0xd0>
    51c0:	00e57463          	bgeu	a0,a4,51c8 <__umoddi3+0xd0>
    51c4:	01050533          	add	a0,a0,a6
    51c8:	40e50533          	sub	a0,a0,a4
    51cc:	00d55533          	srl	a0,a0,a3
    51d0:	00000593          	li	a1,0
    51d4:	00008067          	ret
    51d8:	00d5f463          	bgeu	a1,a3,51e0 <__umoddi3+0xe8>
    51dc:	00008067          	ret
    51e0:	00010737          	lui	a4,0x10
    51e4:	1ce6e663          	bltu	a3,a4,53b0 <__umoddi3+0x2b8>
    51e8:	01000737          	lui	a4,0x1000
    51ec:	01800813          	li	a6,24
    51f0:	00e6f463          	bgeu	a3,a4,51f8 <__umoddi3+0x100>
    51f4:	01000813          	li	a6,16
    51f8:	0106d333          	srl	t1,a3,a6
    51fc:	00005717          	auipc	a4,0x5
    5200:	b5470713          	addi	a4,a4,-1196 # 9d50 <__clz_tab>
    5204:	00670733          	add	a4,a4,t1
    5208:	00074703          	lbu	a4,0(a4)
    520c:	02000313          	li	t1,32
    5210:	01070733          	add	a4,a4,a6
    5214:	40e30833          	sub	a6,t1,a4
    5218:	1ce31463          	bne	t1,a4,53e0 <__umoddi3+0x2e8>
    521c:	00b6e463          	bltu	a3,a1,5224 <__umoddi3+0x12c>
    5220:	00c56a63          	bltu	a0,a2,5234 <__umoddi3+0x13c>
    5224:	40c508b3          	sub	a7,a0,a2
    5228:	40d586b3          	sub	a3,a1,a3
    522c:	011537b3          	sltu	a5,a0,a7
    5230:	40f687b3          	sub	a5,a3,a5
    5234:	00088513          	mv	a0,a7
    5238:	00078593          	mv	a1,a5
    523c:	00008067          	ret
    5240:	0a060e63          	beqz	a2,52fc <__umoddi3+0x204>
    5244:	000107b7          	lui	a5,0x10
    5248:	2ef67463          	bgeu	a2,a5,5530 <__umoddi3+0x438>
    524c:	10063713          	sltiu	a4,a2,256
    5250:	00173713          	seqz	a4,a4
    5254:	00371713          	slli	a4,a4,0x3
    5258:	00e656b3          	srl	a3,a2,a4
    525c:	00005797          	auipc	a5,0x5
    5260:	af478793          	addi	a5,a5,-1292 # 9d50 <__clz_tab>
    5264:	00d787b3          	add	a5,a5,a3
    5268:	0007c783          	lbu	a5,0(a5)
    526c:	02000313          	li	t1,32
    5270:	00e787b3          	add	a5,a5,a4
    5274:	40f306b3          	sub	a3,t1,a5
    5278:	0af31663          	bne	t1,a5,5324 <__umoddi3+0x22c>
    527c:	40c58733          	sub	a4,a1,a2
    5280:	01065313          	srli	t1,a2,0x10
    5284:	01061613          	slli	a2,a2,0x10
    5288:	01065613          	srli	a2,a2,0x10
    528c:	026755b3          	divu	a1,a4,t1
    5290:	0108d793          	srli	a5,a7,0x10
    5294:	02677733          	remu	a4,a4,t1
    5298:	02c585b3          	mul	a1,a1,a2
    529c:	01071713          	slli	a4,a4,0x10
    52a0:	00e7e7b3          	or	a5,a5,a4
    52a4:	00b7fa63          	bgeu	a5,a1,52b8 <__umoddi3+0x1c0>
    52a8:	00f807b3          	add	a5,a6,a5
    52ac:	0107e663          	bltu	a5,a6,52b8 <__umoddi3+0x1c0>
    52b0:	00b7f463          	bgeu	a5,a1,52b8 <__umoddi3+0x1c0>
    52b4:	010787b3          	add	a5,a5,a6
    52b8:	40b787b3          	sub	a5,a5,a1
    52bc:	0267d733          	divu	a4,a5,t1
    52c0:	01089893          	slli	a7,a7,0x10
    52c4:	0108d893          	srli	a7,a7,0x10
    52c8:	0267f7b3          	remu	a5,a5,t1
    52cc:	02c70733          	mul	a4,a4,a2
    52d0:	01079513          	slli	a0,a5,0x10
    52d4:	00a8e533          	or	a0,a7,a0
    52d8:	eee560e3          	bltu	a0,a4,51b8 <__umoddi3+0xc0>
    52dc:	40e50533          	sub	a0,a0,a4
    52e0:	00d55533          	srl	a0,a0,a3
    52e4:	00000593          	li	a1,0
    52e8:	00008067          	ret
    52ec:	10063693          	sltiu	a3,a2,256
    52f0:	0016b693          	seqz	a3,a3
    52f4:	00369693          	slli	a3,a3,0x3
    52f8:	e31ff06f          	j	5128 <__umoddi3+0x30>
    52fc:	00000693          	li	a3,0
    5300:	00005797          	auipc	a5,0x5
    5304:	a5078793          	addi	a5,a5,-1456 # 9d50 <__clz_tab>
    5308:	00d787b3          	add	a5,a5,a3
    530c:	0007c783          	lbu	a5,0(a5)
    5310:	00000713          	li	a4,0
    5314:	02000313          	li	t1,32
    5318:	00e787b3          	add	a5,a5,a4
    531c:	40f306b3          	sub	a3,t1,a5
    5320:	f4f30ee3          	beq	t1,a5,527c <__umoddi3+0x184>
    5324:	00d61833          	sll	a6,a2,a3
    5328:	00f5de33          	srl	t3,a1,a5
    532c:	01085313          	srli	t1,a6,0x10
    5330:	026e5eb3          	divu	t4,t3,t1
    5334:	01081613          	slli	a2,a6,0x10
    5338:	00d595b3          	sll	a1,a1,a3
    533c:	00f55733          	srl	a4,a0,a5
    5340:	01065613          	srli	a2,a2,0x10
    5344:	00b76733          	or	a4,a4,a1
    5348:	01075793          	srli	a5,a4,0x10
    534c:	00d518b3          	sll	a7,a0,a3
    5350:	026e7e33          	remu	t3,t3,t1
    5354:	02ce85b3          	mul	a1,t4,a2
    5358:	010e1e13          	slli	t3,t3,0x10
    535c:	01c7e7b3          	or	a5,a5,t3
    5360:	00b7fa63          	bgeu	a5,a1,5374 <__umoddi3+0x27c>
    5364:	00f807b3          	add	a5,a6,a5
    5368:	0107e663          	bltu	a5,a6,5374 <__umoddi3+0x27c>
    536c:	00b7f463          	bgeu	a5,a1,5374 <__umoddi3+0x27c>
    5370:	010787b3          	add	a5,a5,a6
    5374:	40b787b3          	sub	a5,a5,a1
    5378:	0267d5b3          	divu	a1,a5,t1
    537c:	01071713          	slli	a4,a4,0x10
    5380:	01075713          	srli	a4,a4,0x10
    5384:	0267f7b3          	remu	a5,a5,t1
    5388:	02c585b3          	mul	a1,a1,a2
    538c:	01079793          	slli	a5,a5,0x10
    5390:	00f76733          	or	a4,a4,a5
    5394:	00b77a63          	bgeu	a4,a1,53a8 <__umoddi3+0x2b0>
    5398:	00e80733          	add	a4,a6,a4
    539c:	01076663          	bltu	a4,a6,53a8 <__umoddi3+0x2b0>
    53a0:	00b77463          	bgeu	a4,a1,53a8 <__umoddi3+0x2b0>
    53a4:	01070733          	add	a4,a4,a6
    53a8:	40b70733          	sub	a4,a4,a1
    53ac:	ee1ff06f          	j	528c <__umoddi3+0x194>
    53b0:	1006b813          	sltiu	a6,a3,256
    53b4:	00183813          	seqz	a6,a6
    53b8:	00381813          	slli	a6,a6,0x3
    53bc:	0106d333          	srl	t1,a3,a6
    53c0:	00005717          	auipc	a4,0x5
    53c4:	99070713          	addi	a4,a4,-1648 # 9d50 <__clz_tab>
    53c8:	00670733          	add	a4,a4,t1
    53cc:	00074703          	lbu	a4,0(a4)
    53d0:	02000313          	li	t1,32
    53d4:	01070733          	add	a4,a4,a6
    53d8:	40e30833          	sub	a6,t1,a4
    53dc:	e4e300e3          	beq	t1,a4,521c <__umoddi3+0x124>
    53e0:	010696b3          	sll	a3,a3,a6
    53e4:	00e658b3          	srl	a7,a2,a4
    53e8:	00d8e8b3          	or	a7,a7,a3
    53ec:	00e5de33          	srl	t3,a1,a4
    53f0:	0108df13          	srli	t5,a7,0x10
    53f4:	03ee57b3          	divu	a5,t3,t5
    53f8:	01089e93          	slli	t4,a7,0x10
    53fc:	010ede93          	srli	t4,t4,0x10
    5400:	00e556b3          	srl	a3,a0,a4
    5404:	01051333          	sll	t1,a0,a6
    5408:	010595b3          	sll	a1,a1,a6
    540c:	00b6e5b3          	or	a1,a3,a1
    5410:	0105d693          	srli	a3,a1,0x10
    5414:	01061633          	sll	a2,a2,a6
    5418:	03ee7e33          	remu	t3,t3,t5
    541c:	02fe8533          	mul	a0,t4,a5
    5420:	010e1e13          	slli	t3,t3,0x10
    5424:	01c6e6b3          	or	a3,a3,t3
    5428:	00a6fe63          	bgeu	a3,a0,5444 <__umoddi3+0x34c>
    542c:	00d886b3          	add	a3,a7,a3
    5430:	fff78e13          	addi	t3,a5,-1
    5434:	1116ec63          	bltu	a3,a7,554c <__umoddi3+0x454>
    5438:	10a6fa63          	bgeu	a3,a0,554c <__umoddi3+0x454>
    543c:	ffe78793          	addi	a5,a5,-2
    5440:	011686b3          	add	a3,a3,a7
    5444:	40a686b3          	sub	a3,a3,a0
    5448:	03e6d533          	divu	a0,a3,t5
    544c:	01059593          	slli	a1,a1,0x10
    5450:	0105d593          	srli	a1,a1,0x10
    5454:	03e6f6b3          	remu	a3,a3,t5
    5458:	02ae8eb3          	mul	t4,t4,a0
    545c:	01069693          	slli	a3,a3,0x10
    5460:	00d5e5b3          	or	a1,a1,a3
    5464:	01d5fe63          	bgeu	a1,t4,5480 <__umoddi3+0x388>
    5468:	00b885b3          	add	a1,a7,a1
    546c:	fff50693          	addi	a3,a0,-1
    5470:	0d15ea63          	bltu	a1,a7,5544 <__umoddi3+0x44c>
    5474:	0dd5f863          	bgeu	a1,t4,5544 <__umoddi3+0x44c>
    5478:	ffe50513          	addi	a0,a0,-2
    547c:	011585b3          	add	a1,a1,a7
    5480:	01079693          	slli	a3,a5,0x10
    5484:	000102b7          	lui	t0,0x10
    5488:	00a6e6b3          	or	a3,a3,a0
    548c:	fff28513          	addi	a0,t0,-1 # ffff <__freertos_irq_stack_top+0x46bf>
    5490:	00a6fe33          	and	t3,a3,a0
    5494:	01065f93          	srli	t6,a2,0x10
    5498:	0106d693          	srli	a3,a3,0x10
    549c:	00a67533          	and	a0,a2,a0
    54a0:	02ae0f33          	mul	t5,t3,a0
    54a4:	41d585b3          	sub	a1,a1,t4
    54a8:	02a68533          	mul	a0,a3,a0
    54ac:	010f5793          	srli	a5,t5,0x10
    54b0:	03fe0e33          	mul	t3,t3,t6
    54b4:	00ae0e33          	add	t3,t3,a0
    54b8:	01c787b3          	add	a5,a5,t3
    54bc:	03f686b3          	mul	a3,a3,t6
    54c0:	00a7f463          	bgeu	a5,a0,54c8 <__umoddi3+0x3d0>
    54c4:	005686b3          	add	a3,a3,t0
    54c8:	00010eb7          	lui	t4,0x10
    54cc:	fffe8e93          	addi	t4,t4,-1 # ffff <__freertos_irq_stack_top+0x46bf>
    54d0:	01d7f533          	and	a0,a5,t4
    54d4:	0107de13          	srli	t3,a5,0x10
    54d8:	01051513          	slli	a0,a0,0x10
    54dc:	01df7f33          	and	t5,t5,t4
    54e0:	00de07b3          	add	a5,t3,a3
    54e4:	01e50533          	add	a0,a0,t5
    54e8:	02f5e863          	bltu	a1,a5,5518 <__umoddi3+0x420>
    54ec:	02f58463          	beq	a1,a5,5514 <__umoddi3+0x41c>
    54f0:	40a30533          	sub	a0,t1,a0
    54f4:	00a33333          	sltu	t1,t1,a0
    54f8:	40f585b3          	sub	a1,a1,a5
    54fc:	406585b3          	sub	a1,a1,t1
    5500:	00e59733          	sll	a4,a1,a4
    5504:	01055533          	srl	a0,a0,a6
    5508:	00a76533          	or	a0,a4,a0
    550c:	0105d5b3          	srl	a1,a1,a6
    5510:	00008067          	ret
    5514:	fca37ee3          	bgeu	t1,a0,54f0 <__umoddi3+0x3f8>
    5518:	40c50633          	sub	a2,a0,a2
    551c:	00c53533          	sltu	a0,a0,a2
    5520:	011508b3          	add	a7,a0,a7
    5524:	411787b3          	sub	a5,a5,a7
    5528:	00060513          	mv	a0,a2
    552c:	fc5ff06f          	j	54f0 <__umoddi3+0x3f8>
    5530:	010007b7          	lui	a5,0x1000
    5534:	02f67463          	bgeu	a2,a5,555c <__umoddi3+0x464>
    5538:	01065693          	srli	a3,a2,0x10
    553c:	01000713          	li	a4,16
    5540:	d1dff06f          	j	525c <__umoddi3+0x164>
    5544:	00068513          	mv	a0,a3
    5548:	f39ff06f          	j	5480 <__umoddi3+0x388>
    554c:	000e0793          	mv	a5,t3
    5550:	ef5ff06f          	j	5444 <__umoddi3+0x34c>
    5554:	010787b3          	add	a5,a5,a6
    5558:	c3dff06f          	j	5194 <__umoddi3+0x9c>
    555c:	01865693          	srli	a3,a2,0x18
    5560:	01800713          	li	a4,24
    5564:	cf9ff06f          	j	525c <__umoddi3+0x164>

00005568 <__adddf3>:
    5568:	001007b7          	lui	a5,0x100
    556c:	fe010113          	addi	sp,sp,-32
    5570:	fff78e93          	addi	t4,a5,-1 # fffff <__freertos_irq_stack_top+0xf46bf>
    5574:	00bef833          	and	a6,t4,a1
    5578:	00def7b3          	and	a5,t4,a3
    557c:	0146d313          	srli	t1,a3,0x14
    5580:	01212823          	sw	s2,16(sp)
    5584:	0145d913          	srli	s2,a1,0x14
    5588:	00379793          	slli	a5,a5,0x3
    558c:	00812c23          	sw	s0,24(sp)
    5590:	00381813          	slli	a6,a6,0x3
    5594:	01f5d413          	srli	s0,a1,0x1f
    5598:	01d55713          	srli	a4,a0,0x1d
    559c:	01d65893          	srli	a7,a2,0x1d
    55a0:	7ff97913          	andi	s2,s2,2047
    55a4:	7ff37313          	andi	t1,t1,2047
    55a8:	00112e23          	sw	ra,28(sp)
    55ac:	00912a23          	sw	s1,20(sp)
    55b0:	01312623          	sw	s3,12(sp)
    55b4:	01f6d693          	srli	a3,a3,0x1f
    55b8:	00f8e8b3          	or	a7,a7,a5
    55bc:	01076733          	or	a4,a4,a6
    55c0:	00351593          	slli	a1,a0,0x3
    55c4:	00361f13          	slli	t5,a2,0x3
    55c8:	406907b3          	sub	a5,s2,t1
    55cc:	1ed40463          	beq	s0,a3,57b4 <__adddf3+0x24c>
    55d0:	16f05263          	blez	a5,5734 <__adddf3+0x1cc>
    55d4:	28030663          	beqz	t1,5860 <__adddf3+0x2f8>
    55d8:	7ff00693          	li	a3,2047
    55dc:	42d90663          	beq	s2,a3,5a08 <__adddf3+0x4a0>
    55e0:	03800693          	li	a3,56
    55e4:	00100613          	li	a2,1
    55e8:	02f6ce63          	blt	a3,a5,5624 <__adddf3+0xbc>
    55ec:	008006b7          	lui	a3,0x800
    55f0:	00d8e8b3          	or	a7,a7,a3
    55f4:	01f00693          	li	a3,31
    55f8:	52f6ce63          	blt	a3,a5,5b34 <__adddf3+0x5cc>
    55fc:	02000693          	li	a3,32
    5600:	40f686b3          	sub	a3,a3,a5
    5604:	00d89633          	sll	a2,a7,a3
    5608:	00ff5533          	srl	a0,t5,a5
    560c:	00df16b3          	sll	a3,t5,a3
    5610:	00a66633          	or	a2,a2,a0
    5614:	00d036b3          	snez	a3,a3
    5618:	00f8d8b3          	srl	a7,a7,a5
    561c:	00d66633          	or	a2,a2,a3
    5620:	41170733          	sub	a4,a4,a7
    5624:	40c58633          	sub	a2,a1,a2
    5628:	00c5b5b3          	sltu	a1,a1,a2
    562c:	00060493          	mv	s1,a2
    5630:	40b709b3          	sub	s3,a4,a1
    5634:	00899793          	slli	a5,s3,0x8
    5638:	3207da63          	bgez	a5,596c <__adddf3+0x404>
    563c:	008007b7          	lui	a5,0x800
    5640:	fff78793          	addi	a5,a5,-1 # 7fffff <__freertos_irq_stack_top+0x7f46bf>
    5644:	00f9f9b3          	and	s3,s3,a5
    5648:	2c098863          	beqz	s3,5918 <__adddf3+0x3b0>
    564c:	00098513          	mv	a0,s3
    5650:	458020ef          	jal	7aa8 <__clzsi2>
    5654:	ff850793          	addi	a5,a0,-8
    5658:	02000693          	li	a3,32
    565c:	40f68733          	sub	a4,a3,a5
    5660:	00e4d733          	srl	a4,s1,a4
    5664:	00f999b3          	sll	s3,s3,a5
    5668:	01376733          	or	a4,a4,s3
    566c:	00f494b3          	sll	s1,s1,a5
    5670:	4b27c863          	blt	a5,s2,5b20 <__adddf3+0x5b8>
    5674:	412787b3          	sub	a5,a5,s2
    5678:	00178793          	addi	a5,a5,1
    567c:	40f686b3          	sub	a3,a3,a5
    5680:	00d49633          	sll	a2,s1,a3
    5684:	00f4d9b3          	srl	s3,s1,a5
    5688:	00c03633          	snez	a2,a2
    568c:	01366633          	or	a2,a2,s3
    5690:	00d716b3          	sll	a3,a4,a3
    5694:	00c6e4b3          	or	s1,a3,a2
    5698:	00f759b3          	srl	s3,a4,a5
    569c:	00000913          	li	s2,0
    56a0:	0074f793          	andi	a5,s1,7
    56a4:	02078063          	beqz	a5,56c4 <__adddf3+0x15c>
    56a8:	00f4f793          	andi	a5,s1,15
    56ac:	00400713          	li	a4,4
    56b0:	00e78a63          	beq	a5,a4,56c4 <__adddf3+0x15c>
    56b4:	00448793          	addi	a5,s1,4
    56b8:	0097b633          	sltu	a2,a5,s1
    56bc:	00c989b3          	add	s3,s3,a2
    56c0:	00078493          	mv	s1,a5
    56c4:	00899793          	slli	a5,s3,0x8
    56c8:	6e07da63          	bgez	a5,5dbc <__adddf3+0x854>
    56cc:	00190793          	addi	a5,s2,1
    56d0:	7ff00713          	li	a4,2047
    56d4:	00040e13          	mv	t3,s0
    56d8:	2ae78663          	beq	a5,a4,5984 <__adddf3+0x41c>
    56dc:	ff800737          	lui	a4,0xff800
    56e0:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f46bf>
    56e4:	00e9f733          	and	a4,s3,a4
    56e8:	7ff7f793          	andi	a5,a5,2047
    56ec:	01d71813          	slli	a6,a4,0x1d
    56f0:	0034d613          	srli	a2,s1,0x3
    56f4:	00971713          	slli	a4,a4,0x9
    56f8:	00c86833          	or	a6,a6,a2
    56fc:	00c75713          	srli	a4,a4,0xc
    5700:	01c12083          	lw	ra,28(sp)
    5704:	01812403          	lw	s0,24(sp)
    5708:	01479793          	slli	a5,a5,0x14
    570c:	00e7e7b3          	or	a5,a5,a4
    5710:	01fe1713          	slli	a4,t3,0x1f
    5714:	00e7e7b3          	or	a5,a5,a4
    5718:	01412483          	lw	s1,20(sp)
    571c:	01012903          	lw	s2,16(sp)
    5720:	00c12983          	lw	s3,12(sp)
    5724:	00080513          	mv	a0,a6
    5728:	00078593          	mv	a1,a5
    572c:	02010113          	addi	sp,sp,32
    5730:	00008067          	ret
    5734:	14078c63          	beqz	a5,588c <__adddf3+0x324>
    5738:	412307b3          	sub	a5,t1,s2
    573c:	3c091263          	bnez	s2,5b00 <__adddf3+0x598>
    5740:	00b76533          	or	a0,a4,a1
    5744:	4c050463          	beqz	a0,5c0c <__adddf3+0x6a4>
    5748:	fff78513          	addi	a0,a5,-1
    574c:	60050263          	beqz	a0,5d50 <__adddf3+0x7e8>
    5750:	7ff00813          	li	a6,2047
    5754:	57078663          	beq	a5,a6,5cc0 <__adddf3+0x758>
    5758:	03800793          	li	a5,56
    575c:	00100613          	li	a2,1
    5760:	02a7cc63          	blt	a5,a0,5798 <__adddf3+0x230>
    5764:	00050793          	mv	a5,a0
    5768:	01f00613          	li	a2,31
    576c:	56f64c63          	blt	a2,a5,5ce4 <__adddf3+0x77c>
    5770:	02000513          	li	a0,32
    5774:	40f50533          	sub	a0,a0,a5
    5778:	00a71633          	sll	a2,a4,a0
    577c:	00f5d833          	srl	a6,a1,a5
    5780:	00a59533          	sll	a0,a1,a0
    5784:	01066633          	or	a2,a2,a6
    5788:	00a03533          	snez	a0,a0
    578c:	00f75733          	srl	a4,a4,a5
    5790:	00a66633          	or	a2,a2,a0
    5794:	40e888b3          	sub	a7,a7,a4
    5798:	40cf0633          	sub	a2,t5,a2
    579c:	00cf3733          	sltu	a4,t5,a2
    57a0:	00060493          	mv	s1,a2
    57a4:	40e889b3          	sub	s3,a7,a4
    57a8:	00030913          	mv	s2,t1
    57ac:	00068413          	mv	s0,a3
    57b0:	e85ff06f          	j	5634 <__adddf3+0xcc>
    57b4:	1ef05063          	blez	a5,5994 <__adddf3+0x42c>
    57b8:	14031063          	bnez	t1,58f8 <__adddf3+0x390>
    57bc:	01e8e6b3          	or	a3,a7,t5
    57c0:	26068c63          	beqz	a3,5a38 <__adddf3+0x4d0>
    57c4:	fff78693          	addi	a3,a5,-1
    57c8:	48068063          	beqz	a3,5c48 <__adddf3+0x6e0>
    57cc:	7ff00613          	li	a2,2047
    57d0:	22c78c63          	beq	a5,a2,5a08 <__adddf3+0x4a0>
    57d4:	03800793          	li	a5,56
    57d8:	00100993          	li	s3,1
    57dc:	02d7cc63          	blt	a5,a3,5814 <__adddf3+0x2ac>
    57e0:	00068793          	mv	a5,a3
    57e4:	01f00693          	li	a3,31
    57e8:	4af6c063          	blt	a3,a5,5c88 <__adddf3+0x720>
    57ec:	02000693          	li	a3,32
    57f0:	40f686b3          	sub	a3,a3,a5
    57f4:	00d899b3          	sll	s3,a7,a3
    57f8:	00ff5633          	srl	a2,t5,a5
    57fc:	00df16b3          	sll	a3,t5,a3
    5800:	00c9e9b3          	or	s3,s3,a2
    5804:	00d036b3          	snez	a3,a3
    5808:	00f8d8b3          	srl	a7,a7,a5
    580c:	00d9e9b3          	or	s3,s3,a3
    5810:	01170733          	add	a4,a4,a7
    5814:	00b985b3          	add	a1,s3,a1
    5818:	0135b9b3          	sltu	s3,a1,s3
    581c:	00058493          	mv	s1,a1
    5820:	00e989b3          	add	s3,s3,a4
    5824:	00899793          	slli	a5,s3,0x8
    5828:	1407d263          	bgez	a5,596c <__adddf3+0x404>
    582c:	00190913          	addi	s2,s2,1
    5830:	7ff00793          	li	a5,2047
    5834:	36f90c63          	beq	s2,a5,5bac <__adddf3+0x644>
    5838:	ff8007b7          	lui	a5,0xff800
    583c:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f46bf>
    5840:	0014f613          	andi	a2,s1,1
    5844:	00f9f7b3          	and	a5,s3,a5
    5848:	0014d713          	srli	a4,s1,0x1
    584c:	00c76733          	or	a4,a4,a2
    5850:	01f79613          	slli	a2,a5,0x1f
    5854:	00e664b3          	or	s1,a2,a4
    5858:	0017d993          	srli	s3,a5,0x1
    585c:	e45ff06f          	j	56a0 <__adddf3+0x138>
    5860:	01e8e6b3          	or	a3,a7,t5
    5864:	1c068a63          	beqz	a3,5a38 <__adddf3+0x4d0>
    5868:	fff78693          	addi	a3,a5,-1
    586c:	40068063          	beqz	a3,5c6c <__adddf3+0x704>
    5870:	7ff00613          	li	a2,2047
    5874:	18c78a63          	beq	a5,a2,5a08 <__adddf3+0x4a0>
    5878:	03800793          	li	a5,56
    587c:	00100613          	li	a2,1
    5880:	dad7c2e3          	blt	a5,a3,5624 <__adddf3+0xbc>
    5884:	00068793          	mv	a5,a3
    5888:	d6dff06f          	j	55f4 <__adddf3+0x8c>
    588c:	00190813          	addi	a6,s2,1
    5890:	7fe87813          	andi	a6,a6,2046
    5894:	22081c63          	bnez	a6,5acc <__adddf3+0x564>
    5898:	00b76333          	or	t1,a4,a1
    589c:	01e8e833          	or	a6,a7,t5
    58a0:	38091063          	bnez	s2,5c20 <__adddf3+0x6b8>
    58a4:	46030e63          	beqz	t1,5d20 <__adddf3+0x7b8>
    58a8:	40080663          	beqz	a6,5cb4 <__adddf3+0x74c>
    58ac:	41e589b3          	sub	s3,a1,t5
    58b0:	0135b533          	sltu	a0,a1,s3
    58b4:	41170633          	sub	a2,a4,a7
    58b8:	40a60633          	sub	a2,a2,a0
    58bc:	00861513          	slli	a0,a2,0x8
    58c0:	50055e63          	bgez	a0,5ddc <__adddf3+0x874>
    58c4:	40bf05b3          	sub	a1,t5,a1
    58c8:	40e88733          	sub	a4,a7,a4
    58cc:	00bf3f33          	sltu	t5,t5,a1
    58d0:	41e70733          	sub	a4,a4,t5
    58d4:	00871613          	slli	a2,a4,0x8
    58d8:	00058493          	mv	s1,a1
    58dc:	52065e63          	bgez	a2,5e18 <__adddf3+0x8b0>
    58e0:	ff8007b7          	lui	a5,0xff800
    58e4:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f46bf>
    58e8:	00f77733          	and	a4,a4,a5
    58ec:	00068e13          	mv	t3,a3
    58f0:	00100793          	li	a5,1
    58f4:	df9ff06f          	j	56ec <__adddf3+0x184>
    58f8:	7ff00693          	li	a3,2047
    58fc:	10d90663          	beq	s2,a3,5a08 <__adddf3+0x4a0>
    5900:	03800693          	li	a3,56
    5904:	00100993          	li	s3,1
    5908:	f0f6c6e3          	blt	a3,a5,5814 <__adddf3+0x2ac>
    590c:	008006b7          	lui	a3,0x800
    5910:	00d8e8b3          	or	a7,a7,a3
    5914:	ed1ff06f          	j	57e4 <__adddf3+0x27c>
    5918:	00048513          	mv	a0,s1
    591c:	18c020ef          	jal	7aa8 <__clzsi2>
    5920:	01850793          	addi	a5,a0,24
    5924:	01f00693          	li	a3,31
    5928:	d2f6d8e3          	bge	a3,a5,5658 <__adddf3+0xf0>
    592c:	ff850713          	addi	a4,a0,-8
    5930:	00e49733          	sll	a4,s1,a4
    5934:	2327c663          	blt	a5,s2,5b60 <__adddf3+0x5f8>
    5938:	41278933          	sub	s2,a5,s2
    593c:	00190793          	addi	a5,s2,1
    5940:	48f6d663          	bge	a3,a5,5dcc <__adddf3+0x864>
    5944:	fe190913          	addi	s2,s2,-31
    5948:	02000693          	li	a3,32
    594c:	012754b3          	srl	s1,a4,s2
    5950:	00d78c63          	beq	a5,a3,5968 <__adddf3+0x400>
    5954:	04000693          	li	a3,64
    5958:	40f687b3          	sub	a5,a3,a5
    595c:	00f71733          	sll	a4,a4,a5
    5960:	00e03733          	snez	a4,a4
    5964:	00e4e4b3          	or	s1,s1,a4
    5968:	00000913          	li	s2,0
    596c:	0074f793          	andi	a5,s1,7
    5970:	d2079ce3          	bnez	a5,56a8 <__adddf3+0x140>
    5974:	00090793          	mv	a5,s2
    5978:	0034d613          	srli	a2,s1,0x3
    597c:	00098713          	mv	a4,s3
    5980:	0c00006f          	j	5a40 <__adddf3+0x4d8>
    5984:	7ff00793          	li	a5,2047
    5988:	00000713          	li	a4,0
    598c:	00000813          	li	a6,0
    5990:	d71ff06f          	j	5700 <__adddf3+0x198>
    5994:	0c078a63          	beqz	a5,5a68 <__adddf3+0x500>
    5998:	412307b3          	sub	a5,t1,s2
    599c:	1e090263          	beqz	s2,5b80 <__adddf3+0x618>
    59a0:	7ff00693          	li	a3,2047
    59a4:	32d30863          	beq	t1,a3,5cd4 <__adddf3+0x76c>
    59a8:	03800693          	li	a3,56
    59ac:	00100993          	li	s3,1
    59b0:	02f6ce63          	blt	a3,a5,59ec <__adddf3+0x484>
    59b4:	008006b7          	lui	a3,0x800
    59b8:	00d76733          	or	a4,a4,a3
    59bc:	01f00693          	li	a3,31
    59c0:	3cf6c863          	blt	a3,a5,5d90 <__adddf3+0x828>
    59c4:	02000693          	li	a3,32
    59c8:	40f686b3          	sub	a3,a3,a5
    59cc:	00d719b3          	sll	s3,a4,a3
    59d0:	00f5d633          	srl	a2,a1,a5
    59d4:	00d596b3          	sll	a3,a1,a3
    59d8:	00c9e9b3          	or	s3,s3,a2
    59dc:	00d036b3          	snez	a3,a3
    59e0:	00f75733          	srl	a4,a4,a5
    59e4:	00d9e9b3          	or	s3,s3,a3
    59e8:	00e888b3          	add	a7,a7,a4
    59ec:	01e98733          	add	a4,s3,t5
    59f0:	013739b3          	sltu	s3,a4,s3
    59f4:	00070493          	mv	s1,a4
    59f8:	011989b3          	add	s3,s3,a7
    59fc:	00030913          	mv	s2,t1
    5a00:	e25ff06f          	j	5824 <__adddf3+0x2bc>
    5a04:	02081063          	bnez	a6,5a24 <__adddf3+0x4bc>
    5a08:	00351613          	slli	a2,a0,0x3
    5a0c:	00365613          	srli	a2,a2,0x3
    5a10:	01d71813          	slli	a6,a4,0x1d
    5a14:	00c86833          	or	a6,a6,a2
    5a18:	00375713          	srli	a4,a4,0x3
    5a1c:	01076733          	or	a4,a4,a6
    5a20:	18070663          	beqz	a4,5bac <__adddf3+0x644>
    5a24:	00000e13          	li	t3,0
    5a28:	7ff00793          	li	a5,2047
    5a2c:	00080737          	lui	a4,0x80
    5a30:	00000813          	li	a6,0
    5a34:	ccdff06f          	j	5700 <__adddf3+0x198>
    5a38:	00351613          	slli	a2,a0,0x3
    5a3c:	00365613          	srli	a2,a2,0x3
    5a40:	01d71813          	slli	a6,a4,0x1d
    5a44:	7ff00693          	li	a3,2047
    5a48:	00c86833          	or	a6,a6,a2
    5a4c:	00375713          	srli	a4,a4,0x3
    5a50:	fcd786e3          	beq	a5,a3,5a1c <__adddf3+0x4b4>
    5a54:	00c71713          	slli	a4,a4,0xc
    5a58:	00c75713          	srli	a4,a4,0xc
    5a5c:	7ff7f793          	andi	a5,a5,2047
    5a60:	00040e13          	mv	t3,s0
    5a64:	c9dff06f          	j	5700 <__adddf3+0x198>
    5a68:	00190693          	addi	a3,s2,1
    5a6c:	7fe6f813          	andi	a6,a3,2046
    5a70:	14081863          	bnez	a6,5bc0 <__adddf3+0x658>
    5a74:	00b766b3          	or	a3,a4,a1
    5a78:	28091c63          	bnez	s2,5d10 <__adddf3+0x7a8>
    5a7c:	30068263          	beqz	a3,5d80 <__adddf3+0x818>
    5a80:	01e8e6b3          	or	a3,a7,t5
    5a84:	22068863          	beqz	a3,5cb4 <__adddf3+0x74c>
    5a88:	01e587b3          	add	a5,a1,t5
    5a8c:	00b7b5b3          	sltu	a1,a5,a1
    5a90:	01170733          	add	a4,a4,a7
    5a94:	00b70733          	add	a4,a4,a1
    5a98:	0037d813          	srli	a6,a5,0x3
    5a9c:	00871793          	slli	a5,a4,0x8
    5aa0:	00040e13          	mv	t3,s0
    5aa4:	3407de63          	bgez	a5,5e00 <__adddf3+0x898>
    5aa8:	ff8007b7          	lui	a5,0xff800
    5aac:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f46bf>
    5ab0:	00f77733          	and	a4,a4,a5
    5ab4:	01d71793          	slli	a5,a4,0x1d
    5ab8:	00375713          	srli	a4,a4,0x3
    5abc:	0107e833          	or	a6,a5,a6
    5ac0:	01d77733          	and	a4,a4,t4
    5ac4:	00100793          	li	a5,1
    5ac8:	c39ff06f          	j	5700 <__adddf3+0x198>
    5acc:	41e58833          	sub	a6,a1,t5
    5ad0:	0105b7b3          	sltu	a5,a1,a6
    5ad4:	411709b3          	sub	s3,a4,a7
    5ad8:	40f989b3          	sub	s3,s3,a5
    5adc:	00899793          	slli	a5,s3,0x8
    5ae0:	00080493          	mv	s1,a6
    5ae4:	1007c663          	bltz	a5,5bf0 <__adddf3+0x688>
    5ae8:	01386833          	or	a6,a6,s3
    5aec:	b4081ee3          	bnez	a6,5648 <__adddf3+0xe0>
    5af0:	00000e13          	li	t3,0
    5af4:	00000793          	li	a5,0
    5af8:	00000713          	li	a4,0
    5afc:	c05ff06f          	j	5700 <__adddf3+0x198>
    5b00:	7ff00513          	li	a0,2047
    5b04:	1aa30e63          	beq	t1,a0,5cc0 <__adddf3+0x758>
    5b08:	03800513          	li	a0,56
    5b0c:	00100613          	li	a2,1
    5b10:	c8f544e3          	blt	a0,a5,5798 <__adddf3+0x230>
    5b14:	00800637          	lui	a2,0x800
    5b18:	00c76733          	or	a4,a4,a2
    5b1c:	c4dff06f          	j	5768 <__adddf3+0x200>
    5b20:	ff8009b7          	lui	s3,0xff800
    5b24:	fff98993          	addi	s3,s3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f46bf>
    5b28:	40f90933          	sub	s2,s2,a5
    5b2c:	013779b3          	and	s3,a4,s3
    5b30:	b71ff06f          	j	56a0 <__adddf3+0x138>
    5b34:	fe078693          	addi	a3,a5,-32
    5b38:	02000613          	li	a2,32
    5b3c:	00d8d6b3          	srl	a3,a7,a3
    5b40:	00c78a63          	beq	a5,a2,5b54 <__adddf3+0x5ec>
    5b44:	04000613          	li	a2,64
    5b48:	40f607b3          	sub	a5,a2,a5
    5b4c:	00f897b3          	sll	a5,a7,a5
    5b50:	00ff6f33          	or	t5,t5,a5
    5b54:	01e03633          	snez	a2,t5
    5b58:	00d66633          	or	a2,a2,a3
    5b5c:	ac9ff06f          	j	5624 <__adddf3+0xbc>
    5b60:	ff8006b7          	lui	a3,0xff800
    5b64:	fff68693          	addi	a3,a3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f46bf>
    5b68:	40f907b3          	sub	a5,s2,a5
    5b6c:	00d77733          	and	a4,a4,a3
    5b70:	01d71813          	slli	a6,a4,0x1d
    5b74:	01386833          	or	a6,a6,s3
    5b78:	00375713          	srli	a4,a4,0x3
    5b7c:	ed9ff06f          	j	5a54 <__adddf3+0x4ec>
    5b80:	00b766b3          	or	a3,a4,a1
    5b84:	1e068663          	beqz	a3,5d70 <__adddf3+0x808>
    5b88:	fff78693          	addi	a3,a5,-1
    5b8c:	0a068e63          	beqz	a3,5c48 <__adddf3+0x6e0>
    5b90:	7ff00513          	li	a0,2047
    5b94:	14a78063          	beq	a5,a0,5cd4 <__adddf3+0x76c>
    5b98:	03800793          	li	a5,56
    5b9c:	00100993          	li	s3,1
    5ba0:	e4d7c6e3          	blt	a5,a3,59ec <__adddf3+0x484>
    5ba4:	00068793          	mv	a5,a3
    5ba8:	e15ff06f          	j	59bc <__adddf3+0x454>
    5bac:	00040e13          	mv	t3,s0
    5bb0:	7ff00793          	li	a5,2047
    5bb4:	00000713          	li	a4,0
    5bb8:	00000813          	li	a6,0
    5bbc:	b45ff06f          	j	5700 <__adddf3+0x198>
    5bc0:	7ff00793          	li	a5,2047
    5bc4:	fef684e3          	beq	a3,a5,5bac <__adddf3+0x644>
    5bc8:	01e58f33          	add	t5,a1,t5
    5bcc:	00bf35b3          	sltu	a1,t5,a1
    5bd0:	011707b3          	add	a5,a4,a7
    5bd4:	00b787b3          	add	a5,a5,a1
    5bd8:	01f79613          	slli	a2,a5,0x1f
    5bdc:	001f5f13          	srli	t5,t5,0x1
    5be0:	01e664b3          	or	s1,a2,t5
    5be4:	0017d993          	srli	s3,a5,0x1
    5be8:	00068913          	mv	s2,a3
    5bec:	ab5ff06f          	j	56a0 <__adddf3+0x138>
    5bf0:	40bf0633          	sub	a2,t5,a1
    5bf4:	40e887b3          	sub	a5,a7,a4
    5bf8:	00cf3733          	sltu	a4,t5,a2
    5bfc:	00060493          	mv	s1,a2
    5c00:	40e789b3          	sub	s3,a5,a4
    5c04:	00068413          	mv	s0,a3
    5c08:	a41ff06f          	j	5648 <__adddf3+0xe0>
    5c0c:	00361613          	slli	a2,a2,0x3
    5c10:	00365613          	srli	a2,a2,0x3
    5c14:	00068413          	mv	s0,a3
    5c18:	00088713          	mv	a4,a7
    5c1c:	e25ff06f          	j	5a40 <__adddf3+0x4d8>
    5c20:	de0312e3          	bnez	t1,5a04 <__adddf3+0x49c>
    5c24:	1c080663          	beqz	a6,5df0 <__adddf3+0x888>
    5c28:	0038d713          	srli	a4,a7,0x3
    5c2c:	00361613          	slli	a2,a2,0x3
    5c30:	01d89893          	slli	a7,a7,0x1d
    5c34:	01176733          	or	a4,a4,a7
    5c38:	00365613          	srli	a2,a2,0x3
    5c3c:	00c76733          	or	a4,a4,a2
    5c40:	00068413          	mv	s0,a3
    5c44:	dddff06f          	j	5a20 <__adddf3+0x4b8>
    5c48:	01e58f33          	add	t5,a1,t5
    5c4c:	011708b3          	add	a7,a4,a7
    5c50:	00bf35b3          	sltu	a1,t5,a1
    5c54:	00b889b3          	add	s3,a7,a1
    5c58:	00899793          	slli	a5,s3,0x8
    5c5c:	000f0493          	mv	s1,t5
    5c60:	0e07d463          	bgez	a5,5d48 <__adddf3+0x7e0>
    5c64:	00200913          	li	s2,2
    5c68:	bd1ff06f          	j	5838 <__adddf3+0x2d0>
    5c6c:	41e58f33          	sub	t5,a1,t5
    5c70:	411708b3          	sub	a7,a4,a7
    5c74:	01e5b5b3          	sltu	a1,a1,t5
    5c78:	000f0493          	mv	s1,t5
    5c7c:	40b889b3          	sub	s3,a7,a1
    5c80:	00100913          	li	s2,1
    5c84:	9b1ff06f          	j	5634 <__adddf3+0xcc>
    5c88:	fe078693          	addi	a3,a5,-32
    5c8c:	02000613          	li	a2,32
    5c90:	00d8d6b3          	srl	a3,a7,a3
    5c94:	00c78a63          	beq	a5,a2,5ca8 <__adddf3+0x740>
    5c98:	04000613          	li	a2,64
    5c9c:	40f607b3          	sub	a5,a2,a5
    5ca0:	00f897b3          	sll	a5,a7,a5
    5ca4:	00ff6f33          	or	t5,t5,a5
    5ca8:	01e039b3          	snez	s3,t5
    5cac:	00d9e9b3          	or	s3,s3,a3
    5cb0:	b65ff06f          	j	5814 <__adddf3+0x2ac>
    5cb4:	00351613          	slli	a2,a0,0x3
    5cb8:	00365993          	srli	s3,a2,0x3
    5cbc:	eb5ff06f          	j	5b70 <__adddf3+0x608>
    5cc0:	00361613          	slli	a2,a2,0x3
    5cc4:	00365613          	srli	a2,a2,0x3
    5cc8:	00068413          	mv	s0,a3
    5ccc:	00088713          	mv	a4,a7
    5cd0:	d41ff06f          	j	5a10 <__adddf3+0x4a8>
    5cd4:	00361613          	slli	a2,a2,0x3
    5cd8:	00365613          	srli	a2,a2,0x3
    5cdc:	00088713          	mv	a4,a7
    5ce0:	d31ff06f          	j	5a10 <__adddf3+0x4a8>
    5ce4:	fe078513          	addi	a0,a5,-32
    5ce8:	02000613          	li	a2,32
    5cec:	00a75533          	srl	a0,a4,a0
    5cf0:	00c78a63          	beq	a5,a2,5d04 <__adddf3+0x79c>
    5cf4:	04000613          	li	a2,64
    5cf8:	40f607b3          	sub	a5,a2,a5
    5cfc:	00f717b3          	sll	a5,a4,a5
    5d00:	00f5e5b3          	or	a1,a1,a5
    5d04:	00b03633          	snez	a2,a1
    5d08:	00a66633          	or	a2,a2,a0
    5d0c:	a8dff06f          	j	5798 <__adddf3+0x230>
    5d10:	fc0682e3          	beqz	a3,5cd4 <__adddf3+0x76c>
    5d14:	01e8ef33          	or	t5,a7,t5
    5d18:	d00f16e3          	bnez	t5,5a24 <__adddf3+0x4bc>
    5d1c:	cedff06f          	j	5a08 <__adddf3+0x4a0>
    5d20:	dc0808e3          	beqz	a6,5af0 <__adddf3+0x588>
    5d24:	00361813          	slli	a6,a2,0x3
    5d28:	01d89793          	slli	a5,a7,0x1d
    5d2c:	00385813          	srli	a6,a6,0x3
    5d30:	0038d713          	srli	a4,a7,0x3
    5d34:	00f86833          	or	a6,a6,a5
    5d38:	01d77733          	and	a4,a4,t4
    5d3c:	00068e13          	mv	t3,a3
    5d40:	00000793          	li	a5,0
    5d44:	9bdff06f          	j	5700 <__adddf3+0x198>
    5d48:	00100793          	li	a5,1
    5d4c:	c2dff06f          	j	5978 <__adddf3+0x410>
    5d50:	40bf05b3          	sub	a1,t5,a1
    5d54:	40e888b3          	sub	a7,a7,a4
    5d58:	00bf3733          	sltu	a4,t5,a1
    5d5c:	00058493          	mv	s1,a1
    5d60:	40e889b3          	sub	s3,a7,a4
    5d64:	00068413          	mv	s0,a3
    5d68:	00100913          	li	s2,1
    5d6c:	8c9ff06f          	j	5634 <__adddf3+0xcc>
    5d70:	00361613          	slli	a2,a2,0x3
    5d74:	00365613          	srli	a2,a2,0x3
    5d78:	00088713          	mv	a4,a7
    5d7c:	cc5ff06f          	j	5a40 <__adddf3+0x4d8>
    5d80:	00361613          	slli	a2,a2,0x3
    5d84:	00365993          	srli	s3,a2,0x3
    5d88:	00088713          	mv	a4,a7
    5d8c:	de5ff06f          	j	5b70 <__adddf3+0x608>
    5d90:	fe078693          	addi	a3,a5,-32
    5d94:	02000613          	li	a2,32
    5d98:	00d756b3          	srl	a3,a4,a3
    5d9c:	00c78a63          	beq	a5,a2,5db0 <__adddf3+0x848>
    5da0:	04000613          	li	a2,64
    5da4:	40f607b3          	sub	a5,a2,a5
    5da8:	00f717b3          	sll	a5,a4,a5
    5dac:	00f5e5b3          	or	a1,a1,a5
    5db0:	00b039b3          	snez	s3,a1
    5db4:	00d9e9b3          	or	s3,s3,a3
    5db8:	c35ff06f          	j	59ec <__adddf3+0x484>
    5dbc:	0034d613          	srli	a2,s1,0x3
    5dc0:	00090793          	mv	a5,s2
    5dc4:	00098713          	mv	a4,s3
    5dc8:	c79ff06f          	j	5a40 <__adddf3+0x4d8>
    5dcc:	02000693          	li	a3,32
    5dd0:	40f686b3          	sub	a3,a3,a5
    5dd4:	00000613          	li	a2,0
    5dd8:	8b5ff06f          	j	568c <__adddf3+0x124>
    5ddc:	00c9e833          	or	a6,s3,a2
    5de0:	d00808e3          	beqz	a6,5af0 <__adddf3+0x588>
    5de4:	0039d993          	srli	s3,s3,0x3
    5de8:	00060713          	mv	a4,a2
    5dec:	d85ff06f          	j	5b70 <__adddf3+0x608>
    5df0:	00000e13          	li	t3,0
    5df4:	7ff00793          	li	a5,2047
    5df8:	00080737          	lui	a4,0x80
    5dfc:	905ff06f          	j	5700 <__adddf3+0x198>
    5e00:	01d71793          	slli	a5,a4,0x1d
    5e04:	00375713          	srli	a4,a4,0x3
    5e08:	0107e833          	or	a6,a5,a6
    5e0c:	01d77733          	and	a4,a4,t4
    5e10:	00000793          	li	a5,0
    5e14:	8edff06f          	j	5700 <__adddf3+0x198>
    5e18:	01d71813          	slli	a6,a4,0x1d
    5e1c:	0035d593          	srli	a1,a1,0x3
    5e20:	00b86833          	or	a6,a6,a1
    5e24:	00375713          	srli	a4,a4,0x3
    5e28:	00068413          	mv	s0,a3
    5e2c:	c29ff06f          	j	5a54 <__adddf3+0x4ec>

00005e30 <__divdf3>:
    5e30:	fd010113          	addi	sp,sp,-48
    5e34:	01312e23          	sw	s3,28(sp)
    5e38:	0145d993          	srli	s3,a1,0x14
    5e3c:	02812423          	sw	s0,40(sp)
    5e40:	02912223          	sw	s1,36(sp)
    5e44:	03212023          	sw	s2,32(sp)
    5e48:	01412c23          	sw	s4,24(sp)
    5e4c:	01712623          	sw	s7,12(sp)
    5e50:	00c59493          	slli	s1,a1,0xc
    5e54:	02112623          	sw	ra,44(sp)
    5e58:	01512a23          	sw	s5,20(sp)
    5e5c:	01612823          	sw	s6,16(sp)
    5e60:	01812423          	sw	s8,8(sp)
    5e64:	7ff9f993          	andi	s3,s3,2047
    5e68:	00050413          	mv	s0,a0
    5e6c:	00060b93          	mv	s7,a2
    5e70:	00068913          	mv	s2,a3
    5e74:	00c4d493          	srli	s1,s1,0xc
    5e78:	01f5da13          	srli	s4,a1,0x1f
    5e7c:	18098c63          	beqz	s3,6014 <__divdf3+0x1e4>
    5e80:	7ff00793          	li	a5,2047
    5e84:	08f98a63          	beq	s3,a5,5f18 <__divdf3+0xe8>
    5e88:	00349493          	slli	s1,s1,0x3
    5e8c:	01d55793          	srli	a5,a0,0x1d
    5e90:	0097e7b3          	or	a5,a5,s1
    5e94:	00800737          	lui	a4,0x800
    5e98:	00e7eab3          	or	s5,a5,a4
    5e9c:	00351b13          	slli	s6,a0,0x3
    5ea0:	c0198993          	addi	s3,s3,-1023
    5ea4:	00000493          	li	s1,0
    5ea8:	00000c13          	li	s8,0
    5eac:	01495793          	srli	a5,s2,0x14
    5eb0:	00c91413          	slli	s0,s2,0xc
    5eb4:	7ff7f793          	andi	a5,a5,2047
    5eb8:	00c45413          	srli	s0,s0,0xc
    5ebc:	01f95913          	srli	s2,s2,0x1f
    5ec0:	08078463          	beqz	a5,5f48 <__divdf3+0x118>
    5ec4:	7ff00713          	li	a4,2047
    5ec8:	18e78c63          	beq	a5,a4,6060 <__divdf3+0x230>
    5ecc:	00341413          	slli	s0,s0,0x3
    5ed0:	01dbd713          	srli	a4,s7,0x1d
    5ed4:	00876733          	or	a4,a4,s0
    5ed8:	c0178793          	addi	a5,a5,-1023
    5edc:	00800437          	lui	s0,0x800
    5ee0:	00876433          	or	s0,a4,s0
    5ee4:	003b9893          	slli	a7,s7,0x3
    5ee8:	40f989b3          	sub	s3,s3,a5
    5eec:	00000613          	li	a2,0
    5ef0:	00f00713          	li	a4,15
    5ef4:	012a46b3          	xor	a3,s4,s2
    5ef8:	24976663          	bltu	a4,s1,6144 <__divdf3+0x314>
    5efc:	00004717          	auipc	a4,0x4
    5f00:	e1470713          	addi	a4,a4,-492 # 9d10 <s_pages+0x12c>
    5f04:	00249493          	slli	s1,s1,0x2
    5f08:	00e484b3          	add	s1,s1,a4
    5f0c:	0004a783          	lw	a5,0(s1)
    5f10:	00e787b3          	add	a5,a5,a4
    5f14:	00078067          	jr	a5
    5f18:	00a4eab3          	or	s5,s1,a0
    5f1c:	1c0a9e63          	bnez	s5,60f8 <__divdf3+0x2c8>
    5f20:	01495793          	srli	a5,s2,0x14
    5f24:	00c91413          	slli	s0,s2,0xc
    5f28:	7ff7f793          	andi	a5,a5,2047
    5f2c:	00000b13          	li	s6,0
    5f30:	00800493          	li	s1,8
    5f34:	7ff00993          	li	s3,2047
    5f38:	00200c13          	li	s8,2
    5f3c:	00c45413          	srli	s0,s0,0xc
    5f40:	01f95913          	srli	s2,s2,0x1f
    5f44:	f80790e3          	bnez	a5,5ec4 <__divdf3+0x94>
    5f48:	017468b3          	or	a7,s0,s7
    5f4c:	1c088263          	beqz	a7,6110 <__divdf3+0x2e0>
    5f50:	4a040a63          	beqz	s0,6404 <__divdf3+0x5d4>
    5f54:	00040513          	mv	a0,s0
    5f58:	351010ef          	jal	7aa8 <__clzsi2>
    5f5c:	00050793          	mv	a5,a0
    5f60:	ff550693          	addi	a3,a0,-11
    5f64:	01d00713          	li	a4,29
    5f68:	ff878893          	addi	a7,a5,-8
    5f6c:	40d70733          	sub	a4,a4,a3
    5f70:	01141433          	sll	s0,s0,a7
    5f74:	00ebd733          	srl	a4,s7,a4
    5f78:	00876433          	or	s0,a4,s0
    5f7c:	011b98b3          	sll	a7,s7,a7
    5f80:	013787b3          	add	a5,a5,s3
    5f84:	3f378993          	addi	s3,a5,1011
    5f88:	00000613          	li	a2,0
    5f8c:	f65ff06f          	j	5ef0 <__divdf3+0xc0>
    5f90:	40f70733          	sub	a4,a4,a5
    5f94:	03800613          	li	a2,56
    5f98:	4ee65a63          	bge	a2,a4,648c <__divdf3+0x65c>
    5f9c:	00000793          	li	a5,0
    5fa0:	00000613          	li	a2,0
    5fa4:	00000713          	li	a4,0
    5fa8:	02c12083          	lw	ra,44(sp)
    5fac:	02812403          	lw	s0,40(sp)
    5fb0:	01479793          	slli	a5,a5,0x14
    5fb4:	00c7e7b3          	or	a5,a5,a2
    5fb8:	01f69693          	slli	a3,a3,0x1f
    5fbc:	00d7e7b3          	or	a5,a5,a3
    5fc0:	02412483          	lw	s1,36(sp)
    5fc4:	02012903          	lw	s2,32(sp)
    5fc8:	01c12983          	lw	s3,28(sp)
    5fcc:	01812a03          	lw	s4,24(sp)
    5fd0:	01412a83          	lw	s5,20(sp)
    5fd4:	01012b03          	lw	s6,16(sp)
    5fd8:	00c12b83          	lw	s7,12(sp)
    5fdc:	00812c03          	lw	s8,8(sp)
    5fe0:	00070513          	mv	a0,a4
    5fe4:	00078593          	mv	a1,a5
    5fe8:	03010113          	addi	sp,sp,48
    5fec:	00008067          	ret
    5ff0:	7ff00793          	li	a5,2047
    5ff4:	00000613          	li	a2,0
    5ff8:	00000713          	li	a4,0
    5ffc:	fadff06f          	j	5fa8 <__divdf3+0x178>
    6000:	00000693          	li	a3,0
    6004:	7ff00793          	li	a5,2047
    6008:	00080637          	lui	a2,0x80
    600c:	00000713          	li	a4,0
    6010:	f99ff06f          	j	5fa8 <__divdf3+0x178>
    6014:	00a4eab3          	or	s5,s1,a0
    6018:	100a8c63          	beqz	s5,6130 <__divdf3+0x300>
    601c:	40048863          	beqz	s1,642c <__divdf3+0x5fc>
    6020:	00048513          	mv	a0,s1
    6024:	285010ef          	jal	7aa8 <__clzsi2>
    6028:	00050713          	mv	a4,a0
    602c:	ff550693          	addi	a3,a0,-11
    6030:	01d00793          	li	a5,29
    6034:	ff870b13          	addi	s6,a4,-8
    6038:	40d787b3          	sub	a5,a5,a3
    603c:	016494b3          	sll	s1,s1,s6
    6040:	00f457b3          	srl	a5,s0,a5
    6044:	0097eab3          	or	s5,a5,s1
    6048:	01641b33          	sll	s6,s0,s6
    604c:	c0d00993          	li	s3,-1011
    6050:	40e989b3          	sub	s3,s3,a4
    6054:	00000493          	li	s1,0
    6058:	00000c13          	li	s8,0
    605c:	e51ff06f          	j	5eac <__divdf3+0x7c>
    6060:	017468b3          	or	a7,s0,s7
    6064:	80198993          	addi	s3,s3,-2047
    6068:	0a089c63          	bnez	a7,6120 <__divdf3+0x2f0>
    606c:	0024e493          	ori	s1,s1,2
    6070:	00000413          	li	s0,0
    6074:	00200613          	li	a2,2
    6078:	e79ff06f          	j	5ef0 <__divdf3+0xc0>
    607c:	000a0913          	mv	s2,s4
    6080:	000a8413          	mv	s0,s5
    6084:	000b0893          	mv	a7,s6
    6088:	00200793          	li	a5,2
    608c:	4efc0863          	beq	s8,a5,657c <__divdf3+0x74c>
    6090:	00300793          	li	a5,3
    6094:	f6fc06e3          	beq	s8,a5,6000 <__divdf3+0x1d0>
    6098:	00100793          	li	a5,1
    609c:	00090693          	mv	a3,s2
    60a0:	eefc0ee3          	beq	s8,a5,5f9c <__divdf3+0x16c>
    60a4:	3ff98793          	addi	a5,s3,1023
    60a8:	2af05663          	blez	a5,6354 <__divdf3+0x524>
    60ac:	0078f713          	andi	a4,a7,7
    60b0:	4a071663          	bnez	a4,655c <__divdf3+0x72c>
    60b4:	00741713          	slli	a4,s0,0x7
    60b8:	00075a63          	bgez	a4,60cc <__divdf3+0x29c>
    60bc:	ff0007b7          	lui	a5,0xff000
    60c0:	fff78793          	addi	a5,a5,-1 # feffffff <__freertos_irq_stack_top+0xfeff46bf>
    60c4:	00f47433          	and	s0,s0,a5
    60c8:	40098793          	addi	a5,s3,1024
    60cc:	7fe00713          	li	a4,2046
    60d0:	f2f740e3          	blt	a4,a5,5ff0 <__divdf3+0x1c0>
    60d4:	0038d893          	srli	a7,a7,0x3
    60d8:	01d41713          	slli	a4,s0,0x1d
    60dc:	00941613          	slli	a2,s0,0x9
    60e0:	01176733          	or	a4,a4,a7
    60e4:	00c65613          	srli	a2,a2,0xc
    60e8:	7ff7f793          	andi	a5,a5,2047
    60ec:	ebdff06f          	j	5fa8 <__divdf3+0x178>
    60f0:	00060c13          	mv	s8,a2
    60f4:	f95ff06f          	j	6088 <__divdf3+0x258>
    60f8:	00048a93          	mv	s5,s1
    60fc:	00050b13          	mv	s6,a0
    6100:	00c00493          	li	s1,12
    6104:	7ff00993          	li	s3,2047
    6108:	00300c13          	li	s8,3
    610c:	da1ff06f          	j	5eac <__divdf3+0x7c>
    6110:	0014e493          	ori	s1,s1,1
    6114:	00000413          	li	s0,0
    6118:	00100613          	li	a2,1
    611c:	dd5ff06f          	j	5ef0 <__divdf3+0xc0>
    6120:	0034e493          	ori	s1,s1,3
    6124:	000b8893          	mv	a7,s7
    6128:	00300613          	li	a2,3
    612c:	dc5ff06f          	j	5ef0 <__divdf3+0xc0>
    6130:	00000b13          	li	s6,0
    6134:	00400493          	li	s1,4
    6138:	00000993          	li	s3,0
    613c:	00100c13          	li	s8,1
    6140:	d6dff06f          	j	5eac <__divdf3+0x7c>
    6144:	2b546463          	bltu	s0,s5,63ec <__divdf3+0x5bc>
    6148:	2a8a8063          	beq	s5,s0,63e8 <__divdf3+0x5b8>
    614c:	000b0313          	mv	t1,s6
    6150:	fff98993          	addi	s3,s3,-1
    6154:	000a8793          	mv	a5,s5
    6158:	00000b13          	li	s6,0
    615c:	00841713          	slli	a4,s0,0x8
    6160:	01075513          	srli	a0,a4,0x10
    6164:	02a7d433          	divu	s0,a5,a0
    6168:	0188d613          	srli	a2,a7,0x18
    616c:	00e66633          	or	a2,a2,a4
    6170:	01061813          	slli	a6,a2,0x10
    6174:	01085813          	srli	a6,a6,0x10
    6178:	00889593          	slli	a1,a7,0x8
    617c:	01035713          	srli	a4,t1,0x10
    6180:	02a7f7b3          	remu	a5,a5,a0
    6184:	028808b3          	mul	a7,a6,s0
    6188:	01079793          	slli	a5,a5,0x10
    618c:	00f767b3          	or	a5,a4,a5
    6190:	0117fa63          	bgeu	a5,a7,61a4 <__divdf3+0x374>
    6194:	00f607b3          	add	a5,a2,a5
    6198:	fff40713          	addi	a4,s0,-1 # 7fffff <__freertos_irq_stack_top+0x7f46bf>
    619c:	2ec7f063          	bgeu	a5,a2,647c <__divdf3+0x64c>
    61a0:	00070413          	mv	s0,a4
    61a4:	411787b3          	sub	a5,a5,a7
    61a8:	02a7d8b3          	divu	a7,a5,a0
    61ac:	01031713          	slli	a4,t1,0x10
    61b0:	01075713          	srli	a4,a4,0x10
    61b4:	02a7f7b3          	remu	a5,a5,a0
    61b8:	03180fb3          	mul	t6,a6,a7
    61bc:	01079793          	slli	a5,a5,0x10
    61c0:	00f76733          	or	a4,a4,a5
    61c4:	01f77a63          	bgeu	a4,t6,61d8 <__divdf3+0x3a8>
    61c8:	00e60733          	add	a4,a2,a4
    61cc:	fff88793          	addi	a5,a7,-1
    61d0:	28c77e63          	bgeu	a4,a2,646c <__divdf3+0x63c>
    61d4:	00078893          	mv	a7,a5
    61d8:	01041413          	slli	s0,s0,0x10
    61dc:	000102b7          	lui	t0,0x10
    61e0:	01146433          	or	s0,s0,a7
    61e4:	fff28313          	addi	t1,t0,-1 # ffff <__freertos_irq_stack_top+0x46bf>
    61e8:	006478b3          	and	a7,s0,t1
    61ec:	01045e93          	srli	t4,s0,0x10
    61f0:	0105de13          	srli	t3,a1,0x10
    61f4:	0065f333          	and	t1,a1,t1
    61f8:	03130f33          	mul	t5,t1,a7
    61fc:	41f70733          	sub	a4,a4,t6
    6200:	031e08b3          	mul	a7,t3,a7
    6204:	010f5793          	srli	a5,t5,0x10
    6208:	026e8fb3          	mul	t6,t4,t1
    620c:	01f888b3          	add	a7,a7,t6
    6210:	011787b3          	add	a5,a5,a7
    6214:	03ce8eb3          	mul	t4,t4,t3
    6218:	01f7f463          	bgeu	a5,t6,6220 <__divdf3+0x3f0>
    621c:	005e8eb3          	add	t4,t4,t0
    6220:	00010fb7          	lui	t6,0x10
    6224:	ffff8f93          	addi	t6,t6,-1 # ffff <__freertos_irq_stack_top+0x46bf>
    6228:	0107d893          	srli	a7,a5,0x10
    622c:	01f7f7b3          	and	a5,a5,t6
    6230:	01079793          	slli	a5,a5,0x10
    6234:	01ff7f33          	and	t5,t5,t6
    6238:	01d888b3          	add	a7,a7,t4
    623c:	01e787b3          	add	a5,a5,t5
    6240:	17176e63          	bltu	a4,a7,63bc <__divdf3+0x58c>
    6244:	17170a63          	beq	a4,a7,63b8 <__divdf3+0x588>
    6248:	40fb07b3          	sub	a5,s6,a5
    624c:	41170733          	sub	a4,a4,a7
    6250:	00fb3b33          	sltu	s6,s6,a5
    6254:	41670733          	sub	a4,a4,s6
    6258:	2ee60063          	beq	a2,a4,6538 <__divdf3+0x708>
    625c:	02a758b3          	divu	a7,a4,a0
    6260:	0107de93          	srli	t4,a5,0x10
    6264:	02a77733          	remu	a4,a4,a0
    6268:	03180f33          	mul	t5,a6,a7
    626c:	01071713          	slli	a4,a4,0x10
    6270:	00eee733          	or	a4,t4,a4
    6274:	01e77e63          	bgeu	a4,t5,6290 <__divdf3+0x460>
    6278:	00e60733          	add	a4,a2,a4
    627c:	fff88e93          	addi	t4,a7,-1
    6280:	2ec76a63          	bltu	a4,a2,6574 <__divdf3+0x744>
    6284:	2fe77863          	bgeu	a4,t5,6574 <__divdf3+0x744>
    6288:	ffe88893          	addi	a7,a7,-2
    628c:	00c70733          	add	a4,a4,a2
    6290:	41e70733          	sub	a4,a4,t5
    6294:	02a75eb3          	divu	t4,a4,a0
    6298:	01079793          	slli	a5,a5,0x10
    629c:	0107d793          	srli	a5,a5,0x10
    62a0:	02a77733          	remu	a4,a4,a0
    62a4:	03d80833          	mul	a6,a6,t4
    62a8:	01071713          	slli	a4,a4,0x10
    62ac:	00e7e7b3          	or	a5,a5,a4
    62b0:	0107fe63          	bgeu	a5,a6,62cc <__divdf3+0x49c>
    62b4:	00f607b3          	add	a5,a2,a5
    62b8:	fffe8713          	addi	a4,t4,-1
    62bc:	2ac7e863          	bltu	a5,a2,656c <__divdf3+0x73c>
    62c0:	2b07f663          	bgeu	a5,a6,656c <__divdf3+0x73c>
    62c4:	ffee8e93          	addi	t4,t4,-2
    62c8:	00c787b3          	add	a5,a5,a2
    62cc:	01089893          	slli	a7,a7,0x10
    62d0:	01d8e8b3          	or	a7,a7,t4
    62d4:	01089513          	slli	a0,a7,0x10
    62d8:	0108df13          	srli	t5,a7,0x10
    62dc:	01055513          	srli	a0,a0,0x10
    62e0:	02650eb3          	mul	t4,a0,t1
    62e4:	410787b3          	sub	a5,a5,a6
    62e8:	02ae0533          	mul	a0,t3,a0
    62ec:	010ed713          	srli	a4,t4,0x10
    62f0:	026f0333          	mul	t1,t5,t1
    62f4:	00650533          	add	a0,a0,t1
    62f8:	00a70733          	add	a4,a4,a0
    62fc:	03ee0e33          	mul	t3,t3,t5
    6300:	00677663          	bgeu	a4,t1,630c <__divdf3+0x4dc>
    6304:	00010537          	lui	a0,0x10
    6308:	00ae0e33          	add	t3,t3,a0
    630c:	00010837          	lui	a6,0x10
    6310:	fff80813          	addi	a6,a6,-1 # ffff <__freertos_irq_stack_top+0x46bf>
    6314:	01075513          	srli	a0,a4,0x10
    6318:	01077733          	and	a4,a4,a6
    631c:	01071713          	slli	a4,a4,0x10
    6320:	010efeb3          	and	t4,t4,a6
    6324:	01c50533          	add	a0,a0,t3
    6328:	01d70733          	add	a4,a4,t4
    632c:	12a7f263          	bgeu	a5,a0,6450 <__divdf3+0x620>
    6330:	00f607b3          	add	a5,a2,a5
    6334:	fff88313          	addi	t1,a7,-1
    6338:	00078813          	mv	a6,a5
    633c:	1cc7e463          	bltu	a5,a2,6504 <__divdf3+0x6d4>
    6340:	24a7e863          	bltu	a5,a0,6590 <__divdf3+0x760>
    6344:	26a78663          	beq	a5,a0,65b0 <__divdf3+0x780>
    6348:	00030893          	mv	a7,t1
    634c:	0018e893          	ori	a7,a7,1
    6350:	d55ff06f          	j	60a4 <__divdf3+0x274>
    6354:	00100713          	li	a4,1
    6358:	c2079ce3          	bnez	a5,5f90 <__divdf3+0x160>
    635c:	41e98993          	addi	s3,s3,1054
    6360:	013897b3          	sll	a5,a7,s3
    6364:	00f037b3          	snez	a5,a5
    6368:	013419b3          	sll	s3,s0,s3
    636c:	0137e7b3          	or	a5,a5,s3
    6370:	00e8d8b3          	srl	a7,a7,a4
    6374:	00f8e8b3          	or	a7,a7,a5
    6378:	0078f793          	andi	a5,a7,7
    637c:	00e45433          	srl	s0,s0,a4
    6380:	02078063          	beqz	a5,63a0 <__divdf3+0x570>
    6384:	00f8f793          	andi	a5,a7,15
    6388:	00400713          	li	a4,4
    638c:	00e78a63          	beq	a5,a4,63a0 <__divdf3+0x570>
    6390:	00488793          	addi	a5,a7,4
    6394:	0117b8b3          	sltu	a7,a5,a7
    6398:	01140433          	add	s0,s0,a7
    639c:	00078893          	mv	a7,a5
    63a0:	00841593          	slli	a1,s0,0x8
    63a4:	00100793          	li	a5,1
    63a8:	00000613          	li	a2,0
    63ac:	00000713          	li	a4,0
    63b0:	be05cce3          	bltz	a1,5fa8 <__divdf3+0x178>
    63b4:	1340006f          	j	64e8 <__divdf3+0x6b8>
    63b8:	e8fb78e3          	bgeu	s6,a5,6248 <__divdf3+0x418>
    63bc:	00bb0eb3          	add	t4,s6,a1
    63c0:	016ebf33          	sltu	t5,t4,s6
    63c4:	00cf0fb3          	add	t6,t5,a2
    63c8:	01f70733          	add	a4,a4,t6
    63cc:	000e8b13          	mv	s6,t4
    63d0:	fff40f93          	addi	t6,s0,-1
    63d4:	08e67463          	bgeu	a2,a4,645c <__divdf3+0x62c>
    63d8:	15176263          	bltu	a4,a7,651c <__divdf3+0x6ec>
    63dc:	12e88e63          	beq	a7,a4,6518 <__divdf3+0x6e8>
    63e0:	000f8413          	mv	s0,t6
    63e4:	e65ff06f          	j	6248 <__divdf3+0x418>
    63e8:	d71b62e3          	bltu	s6,a7,614c <__divdf3+0x31c>
    63ec:	001b5713          	srli	a4,s6,0x1
    63f0:	01fa9313          	slli	t1,s5,0x1f
    63f4:	001ad793          	srli	a5,s5,0x1
    63f8:	00e36333          	or	t1,t1,a4
    63fc:	01fb1b13          	slli	s6,s6,0x1f
    6400:	d5dff06f          	j	615c <__divdf3+0x32c>
    6404:	000b8513          	mv	a0,s7
    6408:	6a0010ef          	jal	7aa8 <__clzsi2>
    640c:	01550693          	addi	a3,a0,21 # 10015 <__freertos_irq_stack_top+0x46d5>
    6410:	01c00713          	li	a4,28
    6414:	02050793          	addi	a5,a0,32
    6418:	b4d756e3          	bge	a4,a3,5f64 <__divdf3+0x134>
    641c:	ff850513          	addi	a0,a0,-8
    6420:	00000893          	li	a7,0
    6424:	00ab9433          	sll	s0,s7,a0
    6428:	b59ff06f          	j	5f80 <__divdf3+0x150>
    642c:	67c010ef          	jal	7aa8 <__clzsi2>
    6430:	01550693          	addi	a3,a0,21
    6434:	01c00793          	li	a5,28
    6438:	02050713          	addi	a4,a0,32
    643c:	bed7dae3          	bge	a5,a3,6030 <__divdf3+0x200>
    6440:	ff850793          	addi	a5,a0,-8
    6444:	00f41ab3          	sll	s5,s0,a5
    6448:	00000b13          	li	s6,0
    644c:	c01ff06f          	j	604c <__divdf3+0x21c>
    6450:	eea79ee3          	bne	a5,a0,634c <__divdf3+0x51c>
    6454:	c40708e3          	beqz	a4,60a4 <__divdf3+0x274>
    6458:	ed9ff06f          	j	6330 <__divdf3+0x500>
    645c:	f8e612e3          	bne	a2,a4,63e0 <__divdf3+0x5b0>
    6460:	f60f0ce3          	beqz	t5,63d8 <__divdf3+0x5a8>
    6464:	000f8413          	mv	s0,t6
    6468:	de1ff06f          	j	6248 <__divdf3+0x418>
    646c:	d7f774e3          	bgeu	a4,t6,61d4 <__divdf3+0x3a4>
    6470:	ffe88893          	addi	a7,a7,-2
    6474:	00c70733          	add	a4,a4,a2
    6478:	d61ff06f          	j	61d8 <__divdf3+0x3a8>
    647c:	d317f2e3          	bgeu	a5,a7,61a0 <__divdf3+0x370>
    6480:	ffe40413          	addi	s0,s0,-2
    6484:	00c787b3          	add	a5,a5,a2
    6488:	d1dff06f          	j	61a4 <__divdf3+0x374>
    648c:	01f00613          	li	a2,31
    6490:	ece656e3          	bge	a2,a4,635c <__divdf3+0x52c>
    6494:	fe100613          	li	a2,-31
    6498:	40f607b3          	sub	a5,a2,a5
    649c:	02000613          	li	a2,32
    64a0:	00f457b3          	srl	a5,s0,a5
    64a4:	00c70863          	beq	a4,a2,64b4 <__divdf3+0x684>
    64a8:	43e98993          	addi	s3,s3,1086
    64ac:	013419b3          	sll	s3,s0,s3
    64b0:	0138e8b3          	or	a7,a7,s3
    64b4:	011038b3          	snez	a7,a7
    64b8:	00f8e8b3          	or	a7,a7,a5
    64bc:	0078f713          	andi	a4,a7,7
    64c0:	00000613          	li	a2,0
    64c4:	02070863          	beqz	a4,64f4 <__divdf3+0x6c4>
    64c8:	00f8f793          	andi	a5,a7,15
    64cc:	00400713          	li	a4,4
    64d0:	00000413          	li	s0,0
    64d4:	00e78a63          	beq	a5,a4,64e8 <__divdf3+0x6b8>
    64d8:	00488793          	addi	a5,a7,4
    64dc:	0117b8b3          	sltu	a7,a5,a7
    64e0:	01103433          	snez	s0,a7
    64e4:	00078893          	mv	a7,a5
    64e8:	00941613          	slli	a2,s0,0x9
    64ec:	01d41713          	slli	a4,s0,0x1d
    64f0:	00c65613          	srli	a2,a2,0xc
    64f4:	0038d893          	srli	a7,a7,0x3
    64f8:	00e8e733          	or	a4,a7,a4
    64fc:	00000793          	li	a5,0
    6500:	aa9ff06f          	j	5fa8 <__divdf3+0x178>
    6504:	00030893          	mv	a7,t1
    6508:	e4a812e3          	bne	a6,a0,634c <__divdf3+0x51c>
    650c:	b8b70ce3          	beq	a4,a1,60a4 <__divdf3+0x274>
    6510:	0018e893          	ori	a7,a7,1
    6514:	b91ff06f          	j	60a4 <__divdf3+0x274>
    6518:	ecfef4e3          	bgeu	t4,a5,63e0 <__divdf3+0x5b0>
    651c:	01d58eb3          	add	t4,a1,t4
    6520:	00bebf33          	sltu	t5,t4,a1
    6524:	00cf0f33          	add	t5,t5,a2
    6528:	ffe40413          	addi	s0,s0,-2
    652c:	000e8b13          	mv	s6,t4
    6530:	01e70733          	add	a4,a4,t5
    6534:	d15ff06f          	j	6248 <__divdf3+0x418>
    6538:	c0200713          	li	a4,-1022
    653c:	3ff98793          	addi	a5,s3,1023
    6540:	fff00893          	li	a7,-1
    6544:	e0e9c8e3          	blt	s3,a4,6354 <__divdf3+0x524>
    6548:	00488713          	addi	a4,a7,4
    654c:	011738b3          	sltu	a7,a4,a7
    6550:	01140433          	add	s0,s0,a7
    6554:	00070893          	mv	a7,a4
    6558:	b5dff06f          	j	60b4 <__divdf3+0x284>
    655c:	00f8f713          	andi	a4,a7,15
    6560:	00400613          	li	a2,4
    6564:	b4c708e3          	beq	a4,a2,60b4 <__divdf3+0x284>
    6568:	fe1ff06f          	j	6548 <__divdf3+0x718>
    656c:	00070e93          	mv	t4,a4
    6570:	d5dff06f          	j	62cc <__divdf3+0x49c>
    6574:	000e8893          	mv	a7,t4
    6578:	d19ff06f          	j	6290 <__divdf3+0x460>
    657c:	00090693          	mv	a3,s2
    6580:	7ff00793          	li	a5,2047
    6584:	00000613          	li	a2,0
    6588:	00000713          	li	a4,0
    658c:	a1dff06f          	j	5fa8 <__divdf3+0x178>
    6590:	00159313          	slli	t1,a1,0x1
    6594:	00b33833          	sltu	a6,t1,a1
    6598:	00c80833          	add	a6,a6,a2
    659c:	01078833          	add	a6,a5,a6
    65a0:	ffe88893          	addi	a7,a7,-2
    65a4:	00030593          	mv	a1,t1
    65a8:	f6a802e3          	beq	a6,a0,650c <__divdf3+0x6dc>
    65ac:	da1ff06f          	j	634c <__divdf3+0x51c>
    65b0:	fee5e0e3          	bltu	a1,a4,6590 <__divdf3+0x760>
    65b4:	00030893          	mv	a7,t1
    65b8:	f4b71ce3          	bne	a4,a1,6510 <__divdf3+0x6e0>
    65bc:	ae9ff06f          	j	60a4 <__divdf3+0x274>

000065c0 <__eqdf2>:
    65c0:	0145d713          	srli	a4,a1,0x14
    65c4:	001007b7          	lui	a5,0x100
    65c8:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf46bf>
    65cc:	0146d813          	srli	a6,a3,0x14
    65d0:	7ff77713          	andi	a4,a4,2047
    65d4:	7ff00313          	li	t1,2047
    65d8:	00b7fe33          	and	t3,a5,a1
    65dc:	00050893          	mv	a7,a0
    65e0:	00d7f7b3          	and	a5,a5,a3
    65e4:	01f5d593          	srli	a1,a1,0x1f
    65e8:	7ff87813          	andi	a6,a6,2047
    65ec:	01f6d693          	srli	a3,a3,0x1f
    65f0:	00100513          	li	a0,1
    65f4:	00670c63          	beq	a4,t1,660c <__eqdf2+0x4c>
    65f8:	00680863          	beq	a6,t1,6608 <__eqdf2+0x48>
    65fc:	01071463          	bne	a4,a6,6604 <__eqdf2+0x44>
    6600:	02fe0663          	beq	t3,a5,662c <__eqdf2+0x6c>
    6604:	00008067          	ret
    6608:	00008067          	ret
    660c:	fee81ce3          	bne	a6,a4,6604 <__eqdf2+0x44>
    6610:	00fe67b3          	or	a5,t3,a5
    6614:	00c7e7b3          	or	a5,a5,a2
    6618:	0117e7b3          	or	a5,a5,a7
    661c:	fe0794e3          	bnez	a5,6604 <__eqdf2+0x44>
    6620:	40d585b3          	sub	a1,a1,a3
    6624:	00b03533          	snez	a0,a1
    6628:	00008067          	ret
    662c:	fcc89ce3          	bne	a7,a2,6604 <__eqdf2+0x44>
    6630:	00d58a63          	beq	a1,a3,6644 <__eqdf2+0x84>
    6634:	fc0718e3          	bnez	a4,6604 <__eqdf2+0x44>
    6638:	011e6e33          	or	t3,t3,a7
    663c:	01c03533          	snez	a0,t3
    6640:	00008067          	ret
    6644:	00000513          	li	a0,0
    6648:	00008067          	ret

0000664c <__gedf2>:
    664c:	0145d893          	srli	a7,a1,0x14
    6650:	001007b7          	lui	a5,0x100
    6654:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf46bf>
    6658:	0146d713          	srli	a4,a3,0x14
    665c:	7ff8f893          	andi	a7,a7,2047
    6660:	7ff00e13          	li	t3,2047
    6664:	00b7f333          	and	t1,a5,a1
    6668:	00050813          	mv	a6,a0
    666c:	00050e93          	mv	t4,a0
    6670:	00d7f7b3          	and	a5,a5,a3
    6674:	01f5d593          	srli	a1,a1,0x1f
    6678:	00060f13          	mv	t5,a2
    667c:	7ff77513          	andi	a0,a4,2047
    6680:	01f6d693          	srli	a3,a3,0x1f
    6684:	05c88863          	beq	a7,t3,66d4 <__gedf2+0x88>
    6688:	03c50463          	beq	a0,t3,66b0 <__gedf2+0x64>
    668c:	06089a63          	bnez	a7,6700 <__gedf2+0xb4>
    6690:	01036833          	or	a6,t1,a6
    6694:	06051063          	bnez	a0,66f4 <__gedf2+0xa8>
    6698:	00c7e633          	or	a2,a5,a2
    669c:	08060c63          	beqz	a2,6734 <__gedf2+0xe8>
    66a0:	0a081263          	bnez	a6,6744 <__gedf2+0xf8>
    66a4:	00100513          	li	a0,1
    66a8:	08068263          	beqz	a3,672c <__gedf2+0xe0>
    66ac:	00008067          	ret
    66b0:	00c7e633          	or	a2,a5,a2
    66b4:	08061463          	bnez	a2,673c <__gedf2+0xf0>
    66b8:	00089663          	bnez	a7,66c4 <__gedf2+0x78>
    66bc:	01036333          	or	t1,t1,a6
    66c0:	fe0302e3          	beqz	t1,66a4 <__gedf2+0x58>
    66c4:	06d58063          	beq	a1,a3,6724 <__gedf2+0xd8>
    66c8:	06059263          	bnez	a1,672c <__gedf2+0xe0>
    66cc:	00100513          	li	a0,1
    66d0:	00008067          	ret
    66d4:	01036333          	or	t1,t1,a6
    66d8:	06031263          	bnez	t1,673c <__gedf2+0xf0>
    66dc:	ff1516e3          	bne	a0,a7,66c8 <__gedf2+0x7c>
    66e0:	00c7e7b3          	or	a5,a5,a2
    66e4:	04079c63          	bnez	a5,673c <__gedf2+0xf0>
    66e8:	fed590e3          	bne	a1,a3,66c8 <__gedf2+0x7c>
    66ec:	00000513          	li	a0,0
    66f0:	00008067          	ret
    66f4:	fa0808e3          	beqz	a6,66a4 <__gedf2+0x58>
    66f8:	fcd598e3          	bne	a1,a3,66c8 <__gedf2+0x7c>
    66fc:	0280006f          	j	6724 <__gedf2+0xd8>
    6700:	fc0504e3          	beqz	a0,66c8 <__gedf2+0x7c>
    6704:	fcd592e3          	bne	a1,a3,66c8 <__gedf2+0x7c>
    6708:	fd1540e3          	blt	a0,a7,66c8 <__gedf2+0x7c>
    670c:	00a8cc63          	blt	a7,a0,6724 <__gedf2+0xd8>
    6710:	fa67ece3          	bltu	a5,t1,66c8 <__gedf2+0x7c>
    6714:	00f31863          	bne	t1,a5,6724 <__gedf2+0xd8>
    6718:	fbdf68e3          	bltu	t5,t4,66c8 <__gedf2+0x7c>
    671c:	00000513          	li	a0,0
    6720:	f9eef6e3          	bgeu	t4,t5,66ac <__gedf2+0x60>
    6724:	00100513          	li	a0,1
    6728:	f80592e3          	bnez	a1,66ac <__gedf2+0x60>
    672c:	fff00513          	li	a0,-1
    6730:	00008067          	ret
    6734:	f8081ae3          	bnez	a6,66c8 <__gedf2+0x7c>
    6738:	00008067          	ret
    673c:	ffe00513          	li	a0,-2
    6740:	00008067          	ret
    6744:	fcd586e3          	beq	a1,a3,6710 <__gedf2+0xc4>
    6748:	f81ff06f          	j	66c8 <__gedf2+0x7c>

0000674c <__ledf2>:
    674c:	0145d893          	srli	a7,a1,0x14
    6750:	001007b7          	lui	a5,0x100
    6754:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf46bf>
    6758:	0146d713          	srli	a4,a3,0x14
    675c:	7ff8f893          	andi	a7,a7,2047
    6760:	7ff00313          	li	t1,2047
    6764:	00b7fe33          	and	t3,a5,a1
    6768:	00050813          	mv	a6,a0
    676c:	00050e93          	mv	t4,a0
    6770:	00d7f7b3          	and	a5,a5,a3
    6774:	01f5d593          	srli	a1,a1,0x1f
    6778:	00060f13          	mv	t5,a2
    677c:	7ff77513          	andi	a0,a4,2047
    6780:	01f6d693          	srli	a3,a3,0x1f
    6784:	04688a63          	beq	a7,t1,67d8 <__ledf2+0x8c>
    6788:	02650463          	beq	a0,t1,67b0 <__ledf2+0x64>
    678c:	06089863          	bnez	a7,67fc <__ledf2+0xb0>
    6790:	010e6833          	or	a6,t3,a6
    6794:	08051e63          	bnez	a0,6830 <__ledf2+0xe4>
    6798:	00c7e633          	or	a2,a5,a2
    679c:	0a060463          	beqz	a2,6844 <__ledf2+0xf8>
    67a0:	0a081663          	bnez	a6,684c <__ledf2+0x100>
    67a4:	00100513          	li	a0,1
    67a8:	08068063          	beqz	a3,6828 <__ledf2+0xdc>
    67ac:	00008067          	ret
    67b0:	00c7e633          	or	a2,a5,a2
    67b4:	00200513          	li	a0,2
    67b8:	fe061ae3          	bnez	a2,67ac <__ledf2+0x60>
    67bc:	00089663          	bnez	a7,67c8 <__ledf2+0x7c>
    67c0:	010e6e33          	or	t3,t3,a6
    67c4:	fe0e00e3          	beqz	t3,67a4 <__ledf2+0x58>
    67c8:	04d58c63          	beq	a1,a3,6820 <__ledf2+0xd4>
    67cc:	04059e63          	bnez	a1,6828 <__ledf2+0xdc>
    67d0:	00100513          	li	a0,1
    67d4:	00008067          	ret
    67d8:	010e6e33          	or	t3,t3,a6
    67dc:	060e1063          	bnez	t3,683c <__ledf2+0xf0>
    67e0:	ff1516e3          	bne	a0,a7,67cc <__ledf2+0x80>
    67e4:	00c7e7b3          	or	a5,a5,a2
    67e8:	00200513          	li	a0,2
    67ec:	fc0790e3          	bnez	a5,67ac <__ledf2+0x60>
    67f0:	fcd59ee3          	bne	a1,a3,67cc <__ledf2+0x80>
    67f4:	00000513          	li	a0,0
    67f8:	00008067          	ret
    67fc:	fc0508e3          	beqz	a0,67cc <__ledf2+0x80>
    6800:	fcd596e3          	bne	a1,a3,67cc <__ledf2+0x80>
    6804:	fd1544e3          	blt	a0,a7,67cc <__ledf2+0x80>
    6808:	00a8cc63          	blt	a7,a0,6820 <__ledf2+0xd4>
    680c:	fdc7e0e3          	bltu	a5,t3,67cc <__ledf2+0x80>
    6810:	00fe1863          	bne	t3,a5,6820 <__ledf2+0xd4>
    6814:	fbdf6ce3          	bltu	t5,t4,67cc <__ledf2+0x80>
    6818:	00000513          	li	a0,0
    681c:	f9eef8e3          	bgeu	t4,t5,67ac <__ledf2+0x60>
    6820:	00100513          	li	a0,1
    6824:	f80594e3          	bnez	a1,67ac <__ledf2+0x60>
    6828:	fff00513          	li	a0,-1
    682c:	00008067          	ret
    6830:	f6080ae3          	beqz	a6,67a4 <__ledf2+0x58>
    6834:	f8d59ce3          	bne	a1,a3,67cc <__ledf2+0x80>
    6838:	fe9ff06f          	j	6820 <__ledf2+0xd4>
    683c:	00200513          	li	a0,2
    6840:	00008067          	ret
    6844:	f80814e3          	bnez	a6,67cc <__ledf2+0x80>
    6848:	00008067          	ret
    684c:	fcd580e3          	beq	a1,a3,680c <__ledf2+0xc0>
    6850:	f7dff06f          	j	67cc <__ledf2+0x80>

00006854 <__muldf3>:
    6854:	fd010113          	addi	sp,sp,-48
    6858:	0145d793          	srli	a5,a1,0x14
    685c:	02812423          	sw	s0,40(sp)
    6860:	02912223          	sw	s1,36(sp)
    6864:	03212023          	sw	s2,32(sp)
    6868:	01312e23          	sw	s3,28(sp)
    686c:	01512a23          	sw	s5,20(sp)
    6870:	00c59493          	slli	s1,a1,0xc
    6874:	02112623          	sw	ra,44(sp)
    6878:	01412c23          	sw	s4,24(sp)
    687c:	01612823          	sw	s6,16(sp)
    6880:	01712623          	sw	s7,12(sp)
    6884:	01812423          	sw	s8,8(sp)
    6888:	7ff7f793          	andi	a5,a5,2047
    688c:	00050413          	mv	s0,a0
    6890:	00060a93          	mv	s5,a2
    6894:	00068993          	mv	s3,a3
    6898:	00c4d493          	srli	s1,s1,0xc
    689c:	01f5d913          	srli	s2,a1,0x1f
    68a0:	42078463          	beqz	a5,6cc8 <__muldf3+0x474>
    68a4:	7ff00713          	li	a4,2047
    68a8:	0ae78663          	beq	a5,a4,6954 <__muldf3+0x100>
    68ac:	00349693          	slli	a3,s1,0x3
    68b0:	01d55713          	srli	a4,a0,0x1d
    68b4:	00d76733          	or	a4,a4,a3
    68b8:	008006b7          	lui	a3,0x800
    68bc:	00d764b3          	or	s1,a4,a3
    68c0:	00351a13          	slli	s4,a0,0x3
    68c4:	c0178c13          	addi	s8,a5,-1023
    68c8:	00000b13          	li	s6,0
    68cc:	00000b93          	li	s7,0
    68d0:	0149d793          	srli	a5,s3,0x14
    68d4:	00c99713          	slli	a4,s3,0xc
    68d8:	7ff7f793          	andi	a5,a5,2047
    68dc:	000a8f13          	mv	t5,s5
    68e0:	00c75413          	srli	s0,a4,0xc
    68e4:	01f9d993          	srli	s3,s3,0x1f
    68e8:	0a078063          	beqz	a5,6988 <__muldf3+0x134>
    68ec:	7ff00713          	li	a4,2047
    68f0:	14e78e63          	beq	a5,a4,6a4c <__muldf3+0x1f8>
    68f4:	00341713          	slli	a4,s0,0x3
    68f8:	01dad593          	srli	a1,s5,0x1d
    68fc:	00e5e5b3          	or	a1,a1,a4
    6900:	c0178793          	addi	a5,a5,-1023
    6904:	00800737          	lui	a4,0x800
    6908:	00e5e433          	or	s0,a1,a4
    690c:	003a9f13          	slli	t5,s5,0x3
    6910:	018788b3          	add	a7,a5,s8
    6914:	00000313          	li	t1,0
    6918:	00a00713          	li	a4,10
    691c:	00188513          	addi	a0,a7,1
    6920:	0b674c63          	blt	a4,s6,69d8 <__muldf3+0x184>
    6924:	013945b3          	xor	a1,s2,s3
    6928:	00200793          	li	a5,2
    692c:	00058813          	mv	a6,a1
    6930:	1567c663          	blt	a5,s6,6a7c <__muldf3+0x228>
    6934:	fffb0b13          	addi	s6,s6,-1
    6938:	00100713          	li	a4,1
    693c:	17676063          	bltu	a4,s6,6a9c <__muldf3+0x248>
    6940:	3cf30a63          	beq	t1,a5,6d14 <__muldf3+0x4c0>
    6944:	00040493          	mv	s1,s0
    6948:	000f0a13          	mv	s4,t5
    694c:	00030b93          	mv	s7,t1
    6950:	09c0006f          	j	69ec <__muldf3+0x198>
    6954:	00a4ea33          	or	s4,s1,a0
    6958:	3c0a1863          	bnez	s4,6d28 <__muldf3+0x4d4>
    695c:	0149d793          	srli	a5,s3,0x14
    6960:	00c99713          	slli	a4,s3,0xc
    6964:	7ff7f793          	andi	a5,a5,2047
    6968:	00000493          	li	s1,0
    696c:	00800b13          	li	s6,8
    6970:	7ff00c13          	li	s8,2047
    6974:	00200b93          	li	s7,2
    6978:	000a8f13          	mv	t5,s5
    697c:	00c75413          	srli	s0,a4,0xc
    6980:	01f9d993          	srli	s3,s3,0x1f
    6984:	f60794e3          	bnez	a5,68ec <__muldf3+0x98>
    6988:	015467b3          	or	a5,s0,s5
    698c:	3c078263          	beqz	a5,6d50 <__muldf3+0x4fc>
    6990:	4a040063          	beqz	s0,6e30 <__muldf3+0x5dc>
    6994:	00040513          	mv	a0,s0
    6998:	110010ef          	jal	7aa8 <__clzsi2>
    699c:	00050893          	mv	a7,a0
    69a0:	ff550713          	addi	a4,a0,-11
    69a4:	01d00793          	li	a5,29
    69a8:	ff888f13          	addi	t5,a7,-8
    69ac:	40e787b3          	sub	a5,a5,a4
    69b0:	00fad7b3          	srl	a5,s5,a5
    69b4:	01e41733          	sll	a4,s0,t5
    69b8:	00e7e433          	or	s0,a5,a4
    69bc:	01ea9f33          	sll	t5,s5,t5
    69c0:	411c08b3          	sub	a7,s8,a7
    69c4:	c0d88893          	addi	a7,a7,-1011
    69c8:	00a00713          	li	a4,10
    69cc:	00000313          	li	t1,0
    69d0:	00188513          	addi	a0,a7,1
    69d4:	f56758e3          	bge	a4,s6,6924 <__muldf3+0xd0>
    69d8:	00090593          	mv	a1,s2
    69dc:	00200793          	li	a5,2
    69e0:	32fb8a63          	beq	s7,a5,6d14 <__muldf3+0x4c0>
    69e4:	00300793          	li	a5,3
    69e8:	48fb8c63          	beq	s7,a5,6e80 <__muldf3+0x62c>
    69ec:	00100793          	li	a5,1
    69f0:	00058813          	mv	a6,a1
    69f4:	46fb9a63          	bne	s7,a5,6e68 <__muldf3+0x614>
    69f8:	00000793          	li	a5,0
    69fc:	00000693          	li	a3,0
    6a00:	00000713          	li	a4,0
    6a04:	02c12083          	lw	ra,44(sp)
    6a08:	02812403          	lw	s0,40(sp)
    6a0c:	01479793          	slli	a5,a5,0x14
    6a10:	00d7e7b3          	or	a5,a5,a3
    6a14:	01f81693          	slli	a3,a6,0x1f
    6a18:	00d7e7b3          	or	a5,a5,a3
    6a1c:	02412483          	lw	s1,36(sp)
    6a20:	02012903          	lw	s2,32(sp)
    6a24:	01c12983          	lw	s3,28(sp)
    6a28:	01812a03          	lw	s4,24(sp)
    6a2c:	01412a83          	lw	s5,20(sp)
    6a30:	01012b03          	lw	s6,16(sp)
    6a34:	00c12b83          	lw	s7,12(sp)
    6a38:	00812c03          	lw	s8,8(sp)
    6a3c:	00070513          	mv	a0,a4
    6a40:	00078593          	mv	a1,a5
    6a44:	03010113          	addi	sp,sp,48
    6a48:	00008067          	ret
    6a4c:	01546733          	or	a4,s0,s5
    6a50:	7ffc0893          	addi	a7,s8,2047
    6a54:	30070a63          	beqz	a4,6d68 <__muldf3+0x514>
    6a58:	00001737          	lui	a4,0x1
    6a5c:	01394833          	xor	a6,s2,s3
    6a60:	80070713          	addi	a4,a4,-2048 # 800 <CUSTOM2+0x7a5>
    6a64:	003b6b13          	ori	s6,s6,3
    6a68:	00a00693          	li	a3,10
    6a6c:	00080593          	mv	a1,a6
    6a70:	00ec0533          	add	a0,s8,a4
    6a74:	3966c063          	blt	a3,s6,6df4 <__muldf3+0x5a0>
    6a78:	00300313          	li	t1,3
    6a7c:	00100613          	li	a2,1
    6a80:	01661633          	sll	a2,a2,s6
    6a84:	53067713          	andi	a4,a2,1328
    6a88:	f4071ae3          	bnez	a4,69dc <__muldf3+0x188>
    6a8c:	24067793          	andi	a5,a2,576
    6a90:	3c079463          	bnez	a5,6e58 <__muldf3+0x604>
    6a94:	08867613          	andi	a2,a2,136
    6a98:	2e061263          	bnez	a2,6d7c <__muldf3+0x528>
    6a9c:	00010fb7          	lui	t6,0x10
    6aa0:	ffff8e93          	addi	t4,t6,-1 # ffff <__freertos_irq_stack_top+0x46bf>
    6aa4:	01da77b3          	and	a5,s4,t4
    6aa8:	010a5693          	srli	a3,s4,0x10
    6aac:	01df7eb3          	and	t4,t5,t4
    6ab0:	010f5e13          	srli	t3,t5,0x10
    6ab4:	03d78733          	mul	a4,a5,t4
    6ab8:	03d68333          	mul	t1,a3,t4
    6abc:	01075593          	srli	a1,a4,0x10
    6ac0:	02fe0633          	mul	a2,t3,a5
    6ac4:	00660633          	add	a2,a2,t1
    6ac8:	00c585b3          	add	a1,a1,a2
    6acc:	03c68f33          	mul	t5,a3,t3
    6ad0:	0065f463          	bgeu	a1,t1,6ad8 <__muldf3+0x284>
    6ad4:	01ff0f33          	add	t5,t5,t6
    6ad8:	000103b7          	lui	t2,0x10
    6adc:	fff38613          	addi	a2,t2,-1 # ffff <__freertos_irq_stack_top+0x46bf>
    6ae0:	00c5f333          	and	t1,a1,a2
    6ae4:	01045f93          	srli	t6,s0,0x10
    6ae8:	00c77733          	and	a4,a4,a2
    6aec:	00c47433          	and	s0,s0,a2
    6af0:	01031313          	slli	t1,t1,0x10
    6af4:	028782b3          	mul	t0,a5,s0
    6af8:	00e30333          	add	t1,t1,a4
    6afc:	0105d593          	srli	a1,a1,0x10
    6b00:	02868733          	mul	a4,a3,s0
    6b04:	0102d613          	srli	a2,t0,0x10
    6b08:	02ff87b3          	mul	a5,t6,a5
    6b0c:	00e787b3          	add	a5,a5,a4
    6b10:	00f60633          	add	a2,a2,a5
    6b14:	03f687b3          	mul	a5,a3,t6
    6b18:	00e67463          	bgeu	a2,a4,6b20 <__muldf3+0x2cc>
    6b1c:	007787b3          	add	a5,a5,t2
    6b20:	00010937          	lui	s2,0x10
    6b24:	fff90993          	addi	s3,s2,-1 # ffff <__freertos_irq_stack_top+0x46bf>
    6b28:	01367733          	and	a4,a2,s3
    6b2c:	0104d393          	srli	t2,s1,0x10
    6b30:	0134f6b3          	and	a3,s1,s3
    6b34:	0132f2b3          	and	t0,t0,s3
    6b38:	01071713          	slli	a4,a4,0x10
    6b3c:	02de84b3          	mul	s1,t4,a3
    6b40:	00570733          	add	a4,a4,t0
    6b44:	01065613          	srli	a2,a2,0x10
    6b48:	00f60633          	add	a2,a2,a5
    6b4c:	00e585b3          	add	a1,a1,a4
    6b50:	02de02b3          	mul	t0,t3,a3
    6b54:	0104d793          	srli	a5,s1,0x10
    6b58:	03d38eb3          	mul	t4,t2,t4
    6b5c:	01d282b3          	add	t0,t0,t4
    6b60:	005787b3          	add	a5,a5,t0
    6b64:	027e0e33          	mul	t3,t3,t2
    6b68:	01d7f463          	bgeu	a5,t4,6b70 <__muldf3+0x31c>
    6b6c:	012e0e33          	add	t3,t3,s2
    6b70:	000109b7          	lui	s3,0x10
    6b74:	fff98e93          	addi	t4,s3,-1 # ffff <__freertos_irq_stack_top+0x46bf>
    6b78:	01d7f2b3          	and	t0,a5,t4
    6b7c:	0107d793          	srli	a5,a5,0x10
    6b80:	01c787b3          	add	a5,a5,t3
    6b84:	01d4feb3          	and	t4,s1,t4
    6b88:	01029293          	slli	t0,t0,0x10
    6b8c:	02d40933          	mul	s2,s0,a3
    6b90:	01d282b3          	add	t0,t0,t4
    6b94:	02838433          	mul	s0,t2,s0
    6b98:	01095e13          	srli	t3,s2,0x10
    6b9c:	02df86b3          	mul	a3,t6,a3
    6ba0:	008686b3          	add	a3,a3,s0
    6ba4:	00de0e33          	add	t3,t3,a3
    6ba8:	027f8eb3          	mul	t4,t6,t2
    6bac:	008e7463          	bgeu	t3,s0,6bb4 <__muldf3+0x360>
    6bb0:	013e8eb3          	add	t4,t4,s3
    6bb4:	00010fb7          	lui	t6,0x10
    6bb8:	ffff8f93          	addi	t6,t6,-1 # ffff <__freertos_irq_stack_top+0x46bf>
    6bbc:	01fe76b3          	and	a3,t3,t6
    6bc0:	01069693          	slli	a3,a3,0x10
    6bc4:	01f97933          	and	s2,s2,t6
    6bc8:	01e585b3          	add	a1,a1,t5
    6bcc:	012686b3          	add	a3,a3,s2
    6bd0:	00c68633          	add	a2,a3,a2
    6bd4:	00e5b733          	sltu	a4,a1,a4
    6bd8:	00e60733          	add	a4,a2,a4
    6bdc:	00558f33          	add	t5,a1,t0
    6be0:	00f707b3          	add	a5,a4,a5
    6be4:	00bf35b3          	sltu	a1,t5,a1
    6be8:	00b785b3          	add	a1,a5,a1
    6bec:	00d636b3          	sltu	a3,a2,a3
    6bf0:	00c73633          	sltu	a2,a4,a2
    6bf4:	00c6e6b3          	or	a3,a3,a2
    6bf8:	00e7b733          	sltu	a4,a5,a4
    6bfc:	010e5e13          	srli	t3,t3,0x10
    6c00:	00f5b7b3          	sltu	a5,a1,a5
    6c04:	01c686b3          	add	a3,a3,t3
    6c08:	00f76733          	or	a4,a4,a5
    6c0c:	009f1793          	slli	a5,t5,0x9
    6c10:	00d70733          	add	a4,a4,a3
    6c14:	0067e7b3          	or	a5,a5,t1
    6c18:	01d70733          	add	a4,a4,t4
    6c1c:	00f037b3          	snez	a5,a5
    6c20:	017f5613          	srli	a2,t5,0x17
    6c24:	00971713          	slli	a4,a4,0x9
    6c28:	0175d693          	srli	a3,a1,0x17
    6c2c:	00c7e7b3          	or	a5,a5,a2
    6c30:	00959593          	slli	a1,a1,0x9
    6c34:	00b7ea33          	or	s4,a5,a1
    6c38:	00771793          	slli	a5,a4,0x7
    6c3c:	00d764b3          	or	s1,a4,a3
    6c40:	0207d063          	bgez	a5,6c60 <__muldf3+0x40c>
    6c44:	001a5713          	srli	a4,s4,0x1
    6c48:	001a7793          	andi	a5,s4,1
    6c4c:	01f49693          	slli	a3,s1,0x1f
    6c50:	00f767b3          	or	a5,a4,a5
    6c54:	00d7ea33          	or	s4,a5,a3
    6c58:	0014d493          	srli	s1,s1,0x1
    6c5c:	00050893          	mv	a7,a0
    6c60:	3ff88613          	addi	a2,a7,1023
    6c64:	12c05663          	blez	a2,6d90 <__muldf3+0x53c>
    6c68:	007a7793          	andi	a5,s4,7
    6c6c:	02078063          	beqz	a5,6c8c <__muldf3+0x438>
    6c70:	00fa7793          	andi	a5,s4,15
    6c74:	00400713          	li	a4,4
    6c78:	00e78a63          	beq	a5,a4,6c8c <__muldf3+0x438>
    6c7c:	004a0713          	addi	a4,s4,4
    6c80:	014737b3          	sltu	a5,a4,s4
    6c84:	00f484b3          	add	s1,s1,a5
    6c88:	00070a13          	mv	s4,a4
    6c8c:	00749793          	slli	a5,s1,0x7
    6c90:	0007da63          	bgez	a5,6ca4 <__muldf3+0x450>
    6c94:	ff0007b7          	lui	a5,0xff000
    6c98:	fff78793          	addi	a5,a5,-1 # feffffff <__freertos_irq_stack_top+0xfeff46bf>
    6c9c:	00f4f4b3          	and	s1,s1,a5
    6ca0:	40088613          	addi	a2,a7,1024
    6ca4:	7fe00793          	li	a5,2046
    6ca8:	1cc7c463          	blt	a5,a2,6e70 <__muldf3+0x61c>
    6cac:	003a5793          	srli	a5,s4,0x3
    6cb0:	01d49713          	slli	a4,s1,0x1d
    6cb4:	00949693          	slli	a3,s1,0x9
    6cb8:	00f76733          	or	a4,a4,a5
    6cbc:	00c6d693          	srli	a3,a3,0xc
    6cc0:	7ff67793          	andi	a5,a2,2047
    6cc4:	d41ff06f          	j	6a04 <__muldf3+0x1b0>
    6cc8:	00a4ea33          	or	s4,s1,a0
    6ccc:	060a0863          	beqz	s4,6d3c <__muldf3+0x4e8>
    6cd0:	12048e63          	beqz	s1,6e0c <__muldf3+0x5b8>
    6cd4:	00048513          	mv	a0,s1
    6cd8:	5d1000ef          	jal	7aa8 <__clzsi2>
    6cdc:	00050613          	mv	a2,a0
    6ce0:	ff550693          	addi	a3,a0,-11
    6ce4:	01d00713          	li	a4,29
    6ce8:	ff860793          	addi	a5,a2,-8 # 7fff8 <__freertos_irq_stack_top+0x746b8>
    6cec:	40d70733          	sub	a4,a4,a3
    6cf0:	00e45733          	srl	a4,s0,a4
    6cf4:	00f496b3          	sll	a3,s1,a5
    6cf8:	00d764b3          	or	s1,a4,a3
    6cfc:	00f41a33          	sll	s4,s0,a5
    6d00:	c0d00793          	li	a5,-1011
    6d04:	40c78c33          	sub	s8,a5,a2
    6d08:	00000b13          	li	s6,0
    6d0c:	00000b93          	li	s7,0
    6d10:	bc1ff06f          	j	68d0 <__muldf3+0x7c>
    6d14:	00058813          	mv	a6,a1
    6d18:	7ff00793          	li	a5,2047
    6d1c:	00000693          	li	a3,0
    6d20:	00000713          	li	a4,0
    6d24:	ce1ff06f          	j	6a04 <__muldf3+0x1b0>
    6d28:	00050a13          	mv	s4,a0
    6d2c:	00c00b13          	li	s6,12
    6d30:	7ff00c13          	li	s8,2047
    6d34:	00300b93          	li	s7,3
    6d38:	b99ff06f          	j	68d0 <__muldf3+0x7c>
    6d3c:	00000493          	li	s1,0
    6d40:	00400b13          	li	s6,4
    6d44:	00000c13          	li	s8,0
    6d48:	00100b93          	li	s7,1
    6d4c:	b85ff06f          	j	68d0 <__muldf3+0x7c>
    6d50:	001b6b13          	ori	s6,s6,1
    6d54:	000c0893          	mv	a7,s8
    6d58:	00000413          	li	s0,0
    6d5c:	00000f13          	li	t5,0
    6d60:	00100313          	li	t1,1
    6d64:	bb5ff06f          	j	6918 <__muldf3+0xc4>
    6d68:	002b6b13          	ori	s6,s6,2
    6d6c:	00000413          	li	s0,0
    6d70:	00000f13          	li	t5,0
    6d74:	00200313          	li	t1,2
    6d78:	ba1ff06f          	j	6918 <__muldf3+0xc4>
    6d7c:	00040493          	mv	s1,s0
    6d80:	000f0a13          	mv	s4,t5
    6d84:	00030b93          	mv	s7,t1
    6d88:	00098593          	mv	a1,s3
    6d8c:	c51ff06f          	j	69dc <__muldf3+0x188>
    6d90:	00100713          	li	a4,1
    6d94:	10061063          	bnez	a2,6e94 <__muldf3+0x640>
    6d98:	41e88893          	addi	a7,a7,1054
    6d9c:	011a1633          	sll	a2,s4,a7
    6da0:	00c03633          	snez	a2,a2
    6da4:	011498b3          	sll	a7,s1,a7
    6da8:	00ea57b3          	srl	a5,s4,a4
    6dac:	01166633          	or	a2,a2,a7
    6db0:	00f66633          	or	a2,a2,a5
    6db4:	00767793          	andi	a5,a2,7
    6db8:	00e4d5b3          	srl	a1,s1,a4
    6dbc:	02078063          	beqz	a5,6ddc <__muldf3+0x588>
    6dc0:	00f67793          	andi	a5,a2,15
    6dc4:	00400713          	li	a4,4
    6dc8:	00e78a63          	beq	a5,a4,6ddc <__muldf3+0x588>
    6dcc:	00460793          	addi	a5,a2,4
    6dd0:	00c7b633          	sltu	a2,a5,a2
    6dd4:	00c585b3          	add	a1,a1,a2
    6dd8:	00078613          	mv	a2,a5
    6ddc:	00859513          	slli	a0,a1,0x8
    6de0:	00100793          	li	a5,1
    6de4:	00000693          	li	a3,0
    6de8:	00000713          	li	a4,0
    6dec:	c0054ce3          	bltz	a0,6a04 <__muldf3+0x1b0>
    6df0:	10c0006f          	j	6efc <__muldf3+0x6a8>
    6df4:	00f00713          	li	a4,15
    6df8:	12eb1063          	bne	s6,a4,6f18 <__muldf3+0x6c4>
    6dfc:	00000813          	li	a6,0
    6e00:	000806b7          	lui	a3,0x80
    6e04:	00000713          	li	a4,0
    6e08:	bfdff06f          	j	6a04 <__muldf3+0x1b0>
    6e0c:	49d000ef          	jal	7aa8 <__clzsi2>
    6e10:	01550693          	addi	a3,a0,21
    6e14:	01c00793          	li	a5,28
    6e18:	02050613          	addi	a2,a0,32
    6e1c:	ecd7d4e3          	bge	a5,a3,6ce4 <__muldf3+0x490>
    6e20:	ff850513          	addi	a0,a0,-8
    6e24:	00000a13          	li	s4,0
    6e28:	00a414b3          	sll	s1,s0,a0
    6e2c:	ed5ff06f          	j	6d00 <__muldf3+0x4ac>
    6e30:	000a8513          	mv	a0,s5
    6e34:	475000ef          	jal	7aa8 <__clzsi2>
    6e38:	01550713          	addi	a4,a0,21
    6e3c:	01c00793          	li	a5,28
    6e40:	02050893          	addi	a7,a0,32
    6e44:	b6e7d0e3          	bge	a5,a4,69a4 <__muldf3+0x150>
    6e48:	ff850513          	addi	a0,a0,-8
    6e4c:	00000f13          	li	t5,0
    6e50:	00aa9433          	sll	s0,s5,a0
    6e54:	b6dff06f          	j	69c0 <__muldf3+0x16c>
    6e58:	00000813          	li	a6,0
    6e5c:	7ff00793          	li	a5,2047
    6e60:	000806b7          	lui	a3,0x80
    6e64:	ba1ff06f          	j	6a04 <__muldf3+0x1b0>
    6e68:	00050893          	mv	a7,a0
    6e6c:	df5ff06f          	j	6c60 <__muldf3+0x40c>
    6e70:	7ff00793          	li	a5,2047
    6e74:	00000693          	li	a3,0
    6e78:	00000713          	li	a4,0
    6e7c:	b89ff06f          	j	6a04 <__muldf3+0x1b0>
    6e80:	00000813          	li	a6,0
    6e84:	7ff00793          	li	a5,2047
    6e88:	000806b7          	lui	a3,0x80
    6e8c:	00000713          	li	a4,0
    6e90:	b75ff06f          	j	6a04 <__muldf3+0x1b0>
    6e94:	40c70733          	sub	a4,a4,a2
    6e98:	03800793          	li	a5,56
    6e9c:	b4e7cee3          	blt	a5,a4,69f8 <__muldf3+0x1a4>
    6ea0:	01f00793          	li	a5,31
    6ea4:	eee7dae3          	bge	a5,a4,6d98 <__muldf3+0x544>
    6ea8:	fe100793          	li	a5,-31
    6eac:	40c787b3          	sub	a5,a5,a2
    6eb0:	02000693          	li	a3,32
    6eb4:	00f4d7b3          	srl	a5,s1,a5
    6eb8:	00d70863          	beq	a4,a3,6ec8 <__muldf3+0x674>
    6ebc:	43e88893          	addi	a7,a7,1086
    6ec0:	011498b3          	sll	a7,s1,a7
    6ec4:	011a6a33          	or	s4,s4,a7
    6ec8:	01403633          	snez	a2,s4
    6ecc:	00f66633          	or	a2,a2,a5
    6ed0:	00767713          	andi	a4,a2,7
    6ed4:	00000693          	li	a3,0
    6ed8:	02070863          	beqz	a4,6f08 <__muldf3+0x6b4>
    6edc:	00f67793          	andi	a5,a2,15
    6ee0:	00400713          	li	a4,4
    6ee4:	00000593          	li	a1,0
    6ee8:	00e78a63          	beq	a5,a4,6efc <__muldf3+0x6a8>
    6eec:	00460793          	addi	a5,a2,4
    6ef0:	00c7b633          	sltu	a2,a5,a2
    6ef4:	00c035b3          	snez	a1,a2
    6ef8:	00078613          	mv	a2,a5
    6efc:	00959693          	slli	a3,a1,0x9
    6f00:	01d59713          	slli	a4,a1,0x1d
    6f04:	00c6d693          	srli	a3,a3,0xc
    6f08:	00365613          	srli	a2,a2,0x3
    6f0c:	00e66733          	or	a4,a2,a4
    6f10:	00000793          	li	a5,0
    6f14:	af1ff06f          	j	6a04 <__muldf3+0x1b0>
    6f18:	00040493          	mv	s1,s0
    6f1c:	000a8a13          	mv	s4,s5
    6f20:	00300b93          	li	s7,3
    6f24:	00098593          	mv	a1,s3
    6f28:	ab5ff06f          	j	69dc <__muldf3+0x188>

00006f2c <__subdf3>:
    6f2c:	001007b7          	lui	a5,0x100
    6f30:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf46bf>
    6f34:	fe010113          	addi	sp,sp,-32
    6f38:	00b7f8b3          	and	a7,a5,a1
    6f3c:	00d7f833          	and	a6,a5,a3
    6f40:	0146d793          	srli	a5,a3,0x14
    6f44:	00389893          	slli	a7,a7,0x3
    6f48:	00812c23          	sw	s0,24(sp)
    6f4c:	01312623          	sw	s3,12(sp)
    6f50:	01f5d413          	srli	s0,a1,0x1f
    6f54:	0145d993          	srli	s3,a1,0x14
    6f58:	01d55713          	srli	a4,a0,0x1d
    6f5c:	00381813          	slli	a6,a6,0x3
    6f60:	01d65593          	srli	a1,a2,0x1d
    6f64:	00112e23          	sw	ra,28(sp)
    6f68:	00912a23          	sw	s1,20(sp)
    6f6c:	01212823          	sw	s2,16(sp)
    6f70:	7ff7ff13          	andi	t5,a5,2047
    6f74:	7ff00313          	li	t1,2047
    6f78:	01176733          	or	a4,a4,a7
    6f7c:	7ff9f993          	andi	s3,s3,2047
    6f80:	00040e13          	mv	t3,s0
    6f84:	00351893          	slli	a7,a0,0x3
    6f88:	01f6d693          	srli	a3,a3,0x1f
    6f8c:	0105e5b3          	or	a1,a1,a6
    6f90:	00361e93          	slli	t4,a2,0x3
    6f94:	206f0c63          	beq	t5,t1,71ac <__subdf3+0x280>
    6f98:	0016c693          	xori	a3,a3,1
    6f9c:	41e987b3          	sub	a5,s3,t5
    6fa0:	16d40263          	beq	s0,a3,7104 <__subdf3+0x1d8>
    6fa4:	00f05ae3          	blez	a5,77b8 <__subdf3+0x88c>
    6fa8:	240f0a63          	beqz	t5,71fc <__subdf3+0x2d0>
    6fac:	3c698463          	beq	s3,t1,7374 <__subdf3+0x448>
    6fb0:	03800693          	li	a3,56
    6fb4:	00100513          	li	a0,1
    6fb8:	02f6ce63          	blt	a3,a5,6ff4 <__subdf3+0xc8>
    6fbc:	008006b7          	lui	a3,0x800
    6fc0:	00d5e5b3          	or	a1,a1,a3
    6fc4:	01f00693          	li	a3,31
    6fc8:	4ef6c463          	blt	a3,a5,74b0 <__subdf3+0x584>
    6fcc:	02000693          	li	a3,32
    6fd0:	40f686b3          	sub	a3,a3,a5
    6fd4:	00d59533          	sll	a0,a1,a3
    6fd8:	00fed633          	srl	a2,t4,a5
    6fdc:	00de96b3          	sll	a3,t4,a3
    6fe0:	00c56533          	or	a0,a0,a2
    6fe4:	00d036b3          	snez	a3,a3
    6fe8:	00f5d7b3          	srl	a5,a1,a5
    6fec:	00d56533          	or	a0,a0,a3
    6ff0:	40f70733          	sub	a4,a4,a5
    6ff4:	40a88533          	sub	a0,a7,a0
    6ff8:	00a8b633          	sltu	a2,a7,a0
    6ffc:	00050493          	mv	s1,a0
    7000:	40c70933          	sub	s2,a4,a2
    7004:	00891793          	slli	a5,s2,0x8
    7008:	3407d863          	bgez	a5,7358 <__subdf3+0x42c>
    700c:	008007b7          	lui	a5,0x800
    7010:	fff78793          	addi	a5,a5,-1 # 7fffff <__freertos_irq_stack_top+0x7f46bf>
    7014:	00f97933          	and	s2,s2,a5
    7018:	2e090663          	beqz	s2,7304 <__subdf3+0x3d8>
    701c:	00090513          	mv	a0,s2
    7020:	289000ef          	jal	7aa8 <__clzsi2>
    7024:	ff850793          	addi	a5,a0,-8
    7028:	02000693          	li	a3,32
    702c:	40f68733          	sub	a4,a3,a5
    7030:	00e4d733          	srl	a4,s1,a4
    7034:	00f91933          	sll	s2,s2,a5
    7038:	01276733          	or	a4,a4,s2
    703c:	00f494b3          	sll	s1,s1,a5
    7040:	3f37c463          	blt	a5,s3,7428 <__subdf3+0x4fc>
    7044:	413787b3          	sub	a5,a5,s3
    7048:	00178793          	addi	a5,a5,1
    704c:	40f686b3          	sub	a3,a3,a5
    7050:	00d49633          	sll	a2,s1,a3
    7054:	00f4d933          	srl	s2,s1,a5
    7058:	00c03633          	snez	a2,a2
    705c:	00c96633          	or	a2,s2,a2
    7060:	00d716b3          	sll	a3,a4,a3
    7064:	00c6e4b3          	or	s1,a3,a2
    7068:	00f75933          	srl	s2,a4,a5
    706c:	00000993          	li	s3,0
    7070:	0074f793          	andi	a5,s1,7
    7074:	02078063          	beqz	a5,7094 <__subdf3+0x168>
    7078:	00f4f793          	andi	a5,s1,15
    707c:	00400713          	li	a4,4
    7080:	00e78a63          	beq	a5,a4,7094 <__subdf3+0x168>
    7084:	00448793          	addi	a5,s1,4
    7088:	0097b533          	sltu	a0,a5,s1
    708c:	00a90933          	add	s2,s2,a0
    7090:	00078493          	mv	s1,a5
    7094:	00891793          	slli	a5,s2,0x8
    7098:	6c07d063          	bgez	a5,7758 <__subdf3+0x82c>
    709c:	00198793          	addi	a5,s3,1
    70a0:	7ff00713          	li	a4,2047
    70a4:	24e78663          	beq	a5,a4,72f0 <__subdf3+0x3c4>
    70a8:	ff800737          	lui	a4,0xff800
    70ac:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f46bf>
    70b0:	00e97733          	and	a4,s2,a4
    70b4:	7ff7f793          	andi	a5,a5,2047
    70b8:	01d71813          	slli	a6,a4,0x1d
    70bc:	0034d513          	srli	a0,s1,0x3
    70c0:	00971713          	slli	a4,a4,0x9
    70c4:	00a86833          	or	a6,a6,a0
    70c8:	00c75713          	srli	a4,a4,0xc
    70cc:	00147e13          	andi	t3,s0,1
    70d0:	01c12083          	lw	ra,28(sp)
    70d4:	01812403          	lw	s0,24(sp)
    70d8:	01479793          	slli	a5,a5,0x14
    70dc:	00e7e7b3          	or	a5,a5,a4
    70e0:	01fe1713          	slli	a4,t3,0x1f
    70e4:	00e7e7b3          	or	a5,a5,a4
    70e8:	01412483          	lw	s1,20(sp)
    70ec:	01012903          	lw	s2,16(sp)
    70f0:	00c12983          	lw	s3,12(sp)
    70f4:	00080513          	mv	a0,a6
    70f8:	00078593          	mv	a1,a5
    70fc:	02010113          	addi	sp,sp,32
    7100:	00008067          	ret
    7104:	70f05263          	blez	a5,7808 <__subdf3+0x8dc>
    7108:	1c0f1663          	bnez	t5,72d4 <__subdf3+0x3a8>
    710c:	01d5e6b3          	or	a3,a1,t4
    7110:	26068e63          	beqz	a3,738c <__subdf3+0x460>
    7114:	fff78693          	addi	a3,a5,-1
    7118:	46068863          	beqz	a3,7588 <__subdf3+0x65c>
    711c:	24678c63          	beq	a5,t1,7374 <__subdf3+0x448>
    7120:	03800793          	li	a5,56
    7124:	00100913          	li	s2,1
    7128:	02d7cc63          	blt	a5,a3,7160 <__subdf3+0x234>
    712c:	00068793          	mv	a5,a3
    7130:	01f00693          	li	a3,31
    7134:	48f6ca63          	blt	a3,a5,75c8 <__subdf3+0x69c>
    7138:	02000693          	li	a3,32
    713c:	40f686b3          	sub	a3,a3,a5
    7140:	00d59933          	sll	s2,a1,a3
    7144:	00fed633          	srl	a2,t4,a5
    7148:	00de96b3          	sll	a3,t4,a3
    714c:	00c96933          	or	s2,s2,a2
    7150:	00d036b3          	snez	a3,a3
    7154:	00f5d7b3          	srl	a5,a1,a5
    7158:	00d96933          	or	s2,s2,a3
    715c:	00f70733          	add	a4,a4,a5
    7160:	01190633          	add	a2,s2,a7
    7164:	01263933          	sltu	s2,a2,s2
    7168:	00060493          	mv	s1,a2
    716c:	00e90933          	add	s2,s2,a4
    7170:	00891793          	slli	a5,s2,0x8
    7174:	1e07d263          	bgez	a5,7358 <__subdf3+0x42c>
    7178:	00198993          	addi	s3,s3,1
    717c:	7ff00793          	li	a5,2047
    7180:	16f98863          	beq	s3,a5,72f0 <__subdf3+0x3c4>
    7184:	ff8007b7          	lui	a5,0xff800
    7188:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f46bf>
    718c:	0014f513          	andi	a0,s1,1
    7190:	00f977b3          	and	a5,s2,a5
    7194:	0014d713          	srli	a4,s1,0x1
    7198:	00a76733          	or	a4,a4,a0
    719c:	01f79513          	slli	a0,a5,0x1f
    71a0:	00e564b3          	or	s1,a0,a4
    71a4:	0017d913          	srli	s2,a5,0x1
    71a8:	ec9ff06f          	j	7070 <__subdf3+0x144>
    71ac:	01d5e833          	or	a6,a1,t4
    71b0:	80198313          	addi	t1,s3,-2047
    71b4:	06080863          	beqz	a6,7224 <__subdf3+0x2f8>
    71b8:	06d40a63          	beq	s0,a3,722c <__subdf3+0x300>
    71bc:	0e030463          	beqz	t1,72a4 <__subdf3+0x378>
    71c0:	26098e63          	beqz	s3,743c <__subdf3+0x510>
    71c4:	00361513          	slli	a0,a2,0x3
    71c8:	00355513          	srli	a0,a0,0x3
    71cc:	00068413          	mv	s0,a3
    71d0:	00058713          	mv	a4,a1
    71d4:	01d71813          	slli	a6,a4,0x1d
    71d8:	00a86833          	or	a6,a6,a0
    71dc:	00375713          	srli	a4,a4,0x3
    71e0:	01076733          	or	a4,a4,a6
    71e4:	10070663          	beqz	a4,72f0 <__subdf3+0x3c4>
    71e8:	00000e13          	li	t3,0
    71ec:	7ff00793          	li	a5,2047
    71f0:	00080737          	lui	a4,0x80
    71f4:	00000813          	li	a6,0
    71f8:	ed9ff06f          	j	70d0 <__subdf3+0x1a4>
    71fc:	01d5e6b3          	or	a3,a1,t4
    7200:	18068663          	beqz	a3,738c <__subdf3+0x460>
    7204:	fff78693          	addi	a3,a5,-1
    7208:	3a068263          	beqz	a3,75ac <__subdf3+0x680>
    720c:	16678463          	beq	a5,t1,7374 <__subdf3+0x448>
    7210:	03800793          	li	a5,56
    7214:	00100513          	li	a0,1
    7218:	dcd7cee3          	blt	a5,a3,6ff4 <__subdf3+0xc8>
    721c:	00068793          	mv	a5,a3
    7220:	da5ff06f          	j	6fc4 <__subdf3+0x98>
    7224:	0016c693          	xori	a3,a3,1
    7228:	f8d41ae3          	bne	s0,a3,71bc <__subdf3+0x290>
    722c:	18030863          	beqz	t1,73bc <__subdf3+0x490>
    7230:	2c099063          	bnez	s3,74f0 <__subdf3+0x5c4>
    7234:	7ff00793          	li	a5,2047
    7238:	011766b3          	or	a3,a4,a7
    723c:	48068863          	beqz	a3,76cc <__subdf3+0x7a0>
    7240:	fff78693          	addi	a3,a5,-1
    7244:	34068263          	beqz	a3,7588 <__subdf3+0x65c>
    7248:	7ff00513          	li	a0,2047
    724c:	2aa78263          	beq	a5,a0,74f0 <__subdf3+0x5c4>
    7250:	03800793          	li	a5,56
    7254:	00100913          	li	s2,1
    7258:	02d7ca63          	blt	a5,a3,728c <__subdf3+0x360>
    725c:	01f00793          	li	a5,31
    7260:	4cd7c663          	blt	a5,a3,772c <__subdf3+0x800>
    7264:	02000793          	li	a5,32
    7268:	40d787b3          	sub	a5,a5,a3
    726c:	00f71933          	sll	s2,a4,a5
    7270:	00d8d633          	srl	a2,a7,a3
    7274:	00f897b3          	sll	a5,a7,a5
    7278:	00c96933          	or	s2,s2,a2
    727c:	00f037b3          	snez	a5,a5
    7280:	00d756b3          	srl	a3,a4,a3
    7284:	00f96933          	or	s2,s2,a5
    7288:	00d585b3          	add	a1,a1,a3
    728c:	01d90733          	add	a4,s2,t4
    7290:	01273933          	sltu	s2,a4,s2
    7294:	00070493          	mv	s1,a4
    7298:	00b90933          	add	s2,s2,a1
    729c:	000f0993          	mv	s3,t5
    72a0:	ed1ff06f          	j	7170 <__subdf3+0x244>
    72a4:	00198793          	addi	a5,s3,1
    72a8:	7fe7f793          	andi	a5,a5,2046
    72ac:	14079463          	bnez	a5,73f4 <__subdf3+0x4c8>
    72b0:	01d5e833          	or	a6,a1,t4
    72b4:	011767b3          	or	a5,a4,a7
    72b8:	2a099463          	bnez	s3,7560 <__subdf3+0x634>
    72bc:	38078e63          	beqz	a5,7658 <__subdf3+0x72c>
    72c0:	3c081063          	bnez	a6,7680 <__subdf3+0x754>
    72c4:	00351513          	slli	a0,a0,0x3
    72c8:	00355913          	srli	s2,a0,0x3
    72cc:	00000793          	li	a5,0
    72d0:	1140006f          	j	73e4 <__subdf3+0x4b8>
    72d4:	0a698063          	beq	s3,t1,7374 <__subdf3+0x448>
    72d8:	03800693          	li	a3,56
    72dc:	00100913          	li	s2,1
    72e0:	e8f6c0e3          	blt	a3,a5,7160 <__subdf3+0x234>
    72e4:	008006b7          	lui	a3,0x800
    72e8:	00d5e5b3          	or	a1,a1,a3
    72ec:	e45ff06f          	j	7130 <__subdf3+0x204>
    72f0:	00147e13          	andi	t3,s0,1
    72f4:	7ff00793          	li	a5,2047
    72f8:	00000713          	li	a4,0
    72fc:	00000813          	li	a6,0
    7300:	dd1ff06f          	j	70d0 <__subdf3+0x1a4>
    7304:	00048513          	mv	a0,s1
    7308:	7a0000ef          	jal	7aa8 <__clzsi2>
    730c:	01850793          	addi	a5,a0,24
    7310:	01f00693          	li	a3,31
    7314:	d0f6dae3          	bge	a3,a5,7028 <__subdf3+0xfc>
    7318:	ff850713          	addi	a4,a0,-8
    731c:	00e49733          	sll	a4,s1,a4
    7320:	1b37ce63          	blt	a5,s3,74dc <__subdf3+0x5b0>
    7324:	413789b3          	sub	s3,a5,s3
    7328:	00198793          	addi	a5,s3,1
    732c:	42f6de63          	bge	a3,a5,7768 <__subdf3+0x83c>
    7330:	fe198993          	addi	s3,s3,-31
    7334:	02000693          	li	a3,32
    7338:	013754b3          	srl	s1,a4,s3
    733c:	00d78c63          	beq	a5,a3,7354 <__subdf3+0x428>
    7340:	04000693          	li	a3,64
    7344:	40f687b3          	sub	a5,a3,a5
    7348:	00f71733          	sll	a4,a4,a5
    734c:	00e03733          	snez	a4,a4
    7350:	00e4e4b3          	or	s1,s1,a4
    7354:	00000993          	li	s3,0
    7358:	0074f793          	andi	a5,s1,7
    735c:	d0079ee3          	bnez	a5,7078 <__subdf3+0x14c>
    7360:	00098793          	mv	a5,s3
    7364:	0034d513          	srli	a0,s1,0x3
    7368:	00090713          	mv	a4,s2
    736c:	0280006f          	j	7394 <__subdf3+0x468>
    7370:	e6081ce3          	bnez	a6,71e8 <__subdf3+0x2bc>
    7374:	00351513          	slli	a0,a0,0x3
    7378:	01d71813          	slli	a6,a4,0x1d
    737c:	00355513          	srli	a0,a0,0x3
    7380:	00a86833          	or	a6,a6,a0
    7384:	00375713          	srli	a4,a4,0x3
    7388:	e59ff06f          	j	71e0 <__subdf3+0x2b4>
    738c:	00351513          	slli	a0,a0,0x3
    7390:	00355513          	srli	a0,a0,0x3
    7394:	01d71813          	slli	a6,a4,0x1d
    7398:	7ff00693          	li	a3,2047
    739c:	00a86833          	or	a6,a6,a0
    73a0:	00375713          	srli	a4,a4,0x3
    73a4:	e2d78ee3          	beq	a5,a3,71e0 <__subdf3+0x2b4>
    73a8:	00c71713          	slli	a4,a4,0xc
    73ac:	00c75713          	srli	a4,a4,0xc
    73b0:	7ff7f793          	andi	a5,a5,2047
    73b4:	00147e13          	andi	t3,s0,1
    73b8:	d19ff06f          	j	70d0 <__subdf3+0x1a4>
    73bc:	00198693          	addi	a3,s3,1
    73c0:	7fe6f793          	andi	a5,a3,2046
    73c4:	12079e63          	bnez	a5,7500 <__subdf3+0x5d4>
    73c8:	011767b3          	or	a5,a4,a7
    73cc:	24099a63          	bnez	s3,7620 <__subdf3+0x6f4>
    73d0:	30078663          	beqz	a5,76dc <__subdf3+0x7b0>
    73d4:	01d5e7b3          	or	a5,a1,t4
    73d8:	30079a63          	bnez	a5,76ec <__subdf3+0x7c0>
    73dc:	00351513          	slli	a0,a0,0x3
    73e0:	00355913          	srli	s2,a0,0x3
    73e4:	01d71813          	slli	a6,a4,0x1d
    73e8:	01286833          	or	a6,a6,s2
    73ec:	00375713          	srli	a4,a4,0x3
    73f0:	fb9ff06f          	j	73a8 <__subdf3+0x47c>
    73f4:	41d88833          	sub	a6,a7,t4
    73f8:	0108b7b3          	sltu	a5,a7,a6
    73fc:	40b70933          	sub	s2,a4,a1
    7400:	40f90933          	sub	s2,s2,a5
    7404:	00891793          	slli	a5,s2,0x8
    7408:	00080493          	mv	s1,a6
    740c:	1207c263          	bltz	a5,7530 <__subdf3+0x604>
    7410:	01286833          	or	a6,a6,s2
    7414:	c00812e3          	bnez	a6,7018 <__subdf3+0xec>
    7418:	00000e13          	li	t3,0
    741c:	00000793          	li	a5,0
    7420:	00000713          	li	a4,0
    7424:	cadff06f          	j	70d0 <__subdf3+0x1a4>
    7428:	ff800937          	lui	s2,0xff800
    742c:	fff90913          	addi	s2,s2,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f46bf>
    7430:	40f989b3          	sub	s3,s3,a5
    7434:	01277933          	and	s2,a4,s2
    7438:	c39ff06f          	j	7070 <__subdf3+0x144>
    743c:	7ff00793          	li	a5,2047
    7440:	01176533          	or	a0,a4,a7
    7444:	10050463          	beqz	a0,754c <__subdf3+0x620>
    7448:	fff78813          	addi	a6,a5,-1
    744c:	1e080263          	beqz	a6,7630 <__subdf3+0x704>
    7450:	7ff00513          	li	a0,2047
    7454:	d6a788e3          	beq	a5,a0,71c4 <__subdf3+0x298>
    7458:	03800793          	li	a5,56
    745c:	00068413          	mv	s0,a3
    7460:	00100513          	li	a0,1
    7464:	0307ca63          	blt	a5,a6,7498 <__subdf3+0x56c>
    7468:	01f00793          	li	a5,31
    746c:	1907c463          	blt	a5,a6,75f4 <__subdf3+0x6c8>
    7470:	02000793          	li	a5,32
    7474:	410787b3          	sub	a5,a5,a6
    7478:	00f71533          	sll	a0,a4,a5
    747c:	0108d6b3          	srl	a3,a7,a6
    7480:	00f897b3          	sll	a5,a7,a5
    7484:	00d56533          	or	a0,a0,a3
    7488:	00f037b3          	snez	a5,a5
    748c:	01075833          	srl	a6,a4,a6
    7490:	00f56533          	or	a0,a0,a5
    7494:	410585b3          	sub	a1,a1,a6
    7498:	40ae8533          	sub	a0,t4,a0
    749c:	00aeb733          	sltu	a4,t4,a0
    74a0:	00050493          	mv	s1,a0
    74a4:	40e58933          	sub	s2,a1,a4
    74a8:	000f0993          	mv	s3,t5
    74ac:	b59ff06f          	j	7004 <__subdf3+0xd8>
    74b0:	fe078693          	addi	a3,a5,-32
    74b4:	02000613          	li	a2,32
    74b8:	00d5d6b3          	srl	a3,a1,a3
    74bc:	00c78a63          	beq	a5,a2,74d0 <__subdf3+0x5a4>
    74c0:	04000613          	li	a2,64
    74c4:	40f607b3          	sub	a5,a2,a5
    74c8:	00f597b3          	sll	a5,a1,a5
    74cc:	00feeeb3          	or	t4,t4,a5
    74d0:	01d03533          	snez	a0,t4
    74d4:	00d56533          	or	a0,a0,a3
    74d8:	b1dff06f          	j	6ff4 <__subdf3+0xc8>
    74dc:	ff8006b7          	lui	a3,0xff800
    74e0:	fff68693          	addi	a3,a3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f46bf>
    74e4:	40f987b3          	sub	a5,s3,a5
    74e8:	00d77733          	and	a4,a4,a3
    74ec:	ef9ff06f          	j	73e4 <__subdf3+0x4b8>
    74f0:	00361513          	slli	a0,a2,0x3
    74f4:	00355513          	srli	a0,a0,0x3
    74f8:	00058713          	mv	a4,a1
    74fc:	cd9ff06f          	j	71d4 <__subdf3+0x2a8>
    7500:	7ff00793          	li	a5,2047
    7504:	def686e3          	beq	a3,a5,72f0 <__subdf3+0x3c4>
    7508:	01d88eb3          	add	t4,a7,t4
    750c:	011eb633          	sltu	a2,t4,a7
    7510:	00b707b3          	add	a5,a4,a1
    7514:	00c787b3          	add	a5,a5,a2
    7518:	01f79513          	slli	a0,a5,0x1f
    751c:	001ede93          	srli	t4,t4,0x1
    7520:	01d564b3          	or	s1,a0,t4
    7524:	0017d913          	srli	s2,a5,0x1
    7528:	00068993          	mv	s3,a3
    752c:	b45ff06f          	j	7070 <__subdf3+0x144>
    7530:	411e8633          	sub	a2,t4,a7
    7534:	40e587b3          	sub	a5,a1,a4
    7538:	00ceb733          	sltu	a4,t4,a2
    753c:	00060493          	mv	s1,a2
    7540:	40e78933          	sub	s2,a5,a4
    7544:	00068413          	mv	s0,a3
    7548:	ad1ff06f          	j	7018 <__subdf3+0xec>
    754c:	00361613          	slli	a2,a2,0x3
    7550:	00365513          	srli	a0,a2,0x3
    7554:	00068413          	mv	s0,a3
    7558:	00058713          	mv	a4,a1
    755c:	e39ff06f          	j	7394 <__subdf3+0x468>
    7560:	e00798e3          	bnez	a5,7370 <__subdf3+0x444>
    7564:	22080663          	beqz	a6,7790 <__subdf3+0x864>
    7568:	0035d713          	srli	a4,a1,0x3
    756c:	00361613          	slli	a2,a2,0x3
    7570:	01d59593          	slli	a1,a1,0x1d
    7574:	00b76733          	or	a4,a4,a1
    7578:	00365613          	srli	a2,a2,0x3
    757c:	00c76733          	or	a4,a4,a2
    7580:	00068413          	mv	s0,a3
    7584:	c61ff06f          	j	71e4 <__subdf3+0x2b8>
    7588:	01d88eb3          	add	t4,a7,t4
    758c:	00b705b3          	add	a1,a4,a1
    7590:	011eb633          	sltu	a2,t4,a7
    7594:	00c58933          	add	s2,a1,a2
    7598:	00891793          	slli	a5,s2,0x8
    759c:	000e8493          	mv	s1,t4
    75a0:	0a07d863          	bgez	a5,7650 <__subdf3+0x724>
    75a4:	00200993          	li	s3,2
    75a8:	bddff06f          	j	7184 <__subdf3+0x258>
    75ac:	41d88eb3          	sub	t4,a7,t4
    75b0:	40b705b3          	sub	a1,a4,a1
    75b4:	01d8b633          	sltu	a2,a7,t4
    75b8:	000e8493          	mv	s1,t4
    75bc:	40c58933          	sub	s2,a1,a2
    75c0:	00100993          	li	s3,1
    75c4:	a41ff06f          	j	7004 <__subdf3+0xd8>
    75c8:	fe078693          	addi	a3,a5,-32
    75cc:	02000613          	li	a2,32
    75d0:	00d5d6b3          	srl	a3,a1,a3
    75d4:	00c78a63          	beq	a5,a2,75e8 <__subdf3+0x6bc>
    75d8:	04000613          	li	a2,64
    75dc:	40f607b3          	sub	a5,a2,a5
    75e0:	00f597b3          	sll	a5,a1,a5
    75e4:	00feeeb3          	or	t4,t4,a5
    75e8:	01d03933          	snez	s2,t4
    75ec:	00d96933          	or	s2,s2,a3
    75f0:	b71ff06f          	j	7160 <__subdf3+0x234>
    75f4:	fe080793          	addi	a5,a6,-32
    75f8:	02000693          	li	a3,32
    75fc:	00f757b3          	srl	a5,a4,a5
    7600:	00d80a63          	beq	a6,a3,7614 <__subdf3+0x6e8>
    7604:	04000693          	li	a3,64
    7608:	410686b3          	sub	a3,a3,a6
    760c:	00d71733          	sll	a4,a4,a3
    7610:	00e8e8b3          	or	a7,a7,a4
    7614:	01103533          	snez	a0,a7
    7618:	00f56533          	or	a0,a0,a5
    761c:	e7dff06f          	j	7498 <__subdf3+0x56c>
    7620:	ec0788e3          	beqz	a5,74f0 <__subdf3+0x5c4>
    7624:	01d5eeb3          	or	t4,a1,t4
    7628:	bc0e90e3          	bnez	t4,71e8 <__subdf3+0x2bc>
    762c:	d49ff06f          	j	7374 <__subdf3+0x448>
    7630:	411e8633          	sub	a2,t4,a7
    7634:	40e585b3          	sub	a1,a1,a4
    7638:	00ceb733          	sltu	a4,t4,a2
    763c:	00060493          	mv	s1,a2
    7640:	40e58933          	sub	s2,a1,a4
    7644:	00068413          	mv	s0,a3
    7648:	00100993          	li	s3,1
    764c:	9b9ff06f          	j	7004 <__subdf3+0xd8>
    7650:	00100793          	li	a5,1
    7654:	d11ff06f          	j	7364 <__subdf3+0x438>
    7658:	dc0800e3          	beqz	a6,7418 <__subdf3+0x4ec>
    765c:	00361613          	slli	a2,a2,0x3
    7660:	00365793          	srli	a5,a2,0x3
    7664:	01d59813          	slli	a6,a1,0x1d
    7668:	00959713          	slli	a4,a1,0x9
    766c:	00f86833          	or	a6,a6,a5
    7670:	00c75713          	srli	a4,a4,0xc
    7674:	00068e13          	mv	t3,a3
    7678:	00000793          	li	a5,0
    767c:	a55ff06f          	j	70d0 <__subdf3+0x1a4>
    7680:	41d88933          	sub	s2,a7,t4
    7684:	0128b7b3          	sltu	a5,a7,s2
    7688:	40b70633          	sub	a2,a4,a1
    768c:	40f60633          	sub	a2,a2,a5
    7690:	00861793          	slli	a5,a2,0x8
    7694:	0e07d263          	bgez	a5,7778 <__subdf3+0x84c>
    7698:	411e8633          	sub	a2,t4,a7
    769c:	40e58733          	sub	a4,a1,a4
    76a0:	00cebeb3          	sltu	t4,t4,a2
    76a4:	41d70733          	sub	a4,a4,t4
    76a8:	00871793          	slli	a5,a4,0x8
    76ac:	00060493          	mv	s1,a2
    76b0:	1207de63          	bgez	a5,77ec <__subdf3+0x8c0>
    76b4:	ff8007b7          	lui	a5,0xff800
    76b8:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f46bf>
    76bc:	00f77733          	and	a4,a4,a5
    76c0:	00068413          	mv	s0,a3
    76c4:	00100793          	li	a5,1
    76c8:	9f1ff06f          	j	70b8 <__subdf3+0x18c>
    76cc:	00361613          	slli	a2,a2,0x3
    76d0:	00365513          	srli	a0,a2,0x3
    76d4:	00058713          	mv	a4,a1
    76d8:	cbdff06f          	j	7394 <__subdf3+0x468>
    76dc:	00361613          	slli	a2,a2,0x3
    76e0:	00365913          	srli	s2,a2,0x3
    76e4:	00058713          	mv	a4,a1
    76e8:	cfdff06f          	j	73e4 <__subdf3+0x4b8>
    76ec:	01d886b3          	add	a3,a7,t4
    76f0:	00b707b3          	add	a5,a4,a1
    76f4:	0116b633          	sltu	a2,a3,a7
    76f8:	00c787b3          	add	a5,a5,a2
    76fc:	00879713          	slli	a4,a5,0x8
    7700:	0036d813          	srli	a6,a3,0x3
    7704:	08075e63          	bgez	a4,77a0 <__subdf3+0x874>
    7708:	ff800737          	lui	a4,0xff800
    770c:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f46bf>
    7710:	00e7f7b3          	and	a5,a5,a4
    7714:	01d79713          	slli	a4,a5,0x1d
    7718:	00979793          	slli	a5,a5,0x9
    771c:	01076833          	or	a6,a4,a6
    7720:	00c7d713          	srli	a4,a5,0xc
    7724:	00100793          	li	a5,1
    7728:	9a9ff06f          	j	70d0 <__subdf3+0x1a4>
    772c:	fe068793          	addi	a5,a3,-32
    7730:	02000613          	li	a2,32
    7734:	00f757b3          	srl	a5,a4,a5
    7738:	00c68a63          	beq	a3,a2,774c <__subdf3+0x820>
    773c:	04000613          	li	a2,64
    7740:	40d606b3          	sub	a3,a2,a3
    7744:	00d71733          	sll	a4,a4,a3
    7748:	00e8e8b3          	or	a7,a7,a4
    774c:	01103933          	snez	s2,a7
    7750:	00f96933          	or	s2,s2,a5
    7754:	b39ff06f          	j	728c <__subdf3+0x360>
    7758:	0034d513          	srli	a0,s1,0x3
    775c:	00098793          	mv	a5,s3
    7760:	00090713          	mv	a4,s2
    7764:	c31ff06f          	j	7394 <__subdf3+0x468>
    7768:	02000693          	li	a3,32
    776c:	40f686b3          	sub	a3,a3,a5
    7770:	00000613          	li	a2,0
    7774:	8e9ff06f          	j	705c <__subdf3+0x130>
    7778:	00c96833          	or	a6,s2,a2
    777c:	c8080ee3          	beqz	a6,7418 <__subdf3+0x4ec>
    7780:	00395913          	srli	s2,s2,0x3
    7784:	00000793          	li	a5,0
    7788:	00060713          	mv	a4,a2
    778c:	c59ff06f          	j	73e4 <__subdf3+0x4b8>
    7790:	00000e13          	li	t3,0
    7794:	7ff00793          	li	a5,2047
    7798:	00080737          	lui	a4,0x80
    779c:	935ff06f          	j	70d0 <__subdf3+0x1a4>
    77a0:	01d79713          	slli	a4,a5,0x1d
    77a4:	00979793          	slli	a5,a5,0x9
    77a8:	01076833          	or	a6,a4,a6
    77ac:	00c7d713          	srli	a4,a5,0xc
    77b0:	00000793          	li	a5,0
    77b4:	91dff06f          	j	70d0 <__subdf3+0x1a4>
    77b8:	ae0786e3          	beqz	a5,72a4 <__subdf3+0x378>
    77bc:	413f0833          	sub	a6,t5,s3
    77c0:	00080793          	mv	a5,a6
    77c4:	c6098ee3          	beqz	s3,7440 <__subdf3+0x514>
    77c8:	03800793          	li	a5,56
    77cc:	0107ca63          	blt	a5,a6,77e0 <__subdf3+0x8b4>
    77d0:	008007b7          	lui	a5,0x800
    77d4:	00f76733          	or	a4,a4,a5
    77d8:	00068413          	mv	s0,a3
    77dc:	c8dff06f          	j	7468 <__subdf3+0x53c>
    77e0:	00068413          	mv	s0,a3
    77e4:	00100513          	li	a0,1
    77e8:	cb1ff06f          	j	7498 <__subdf3+0x56c>
    77ec:	01d71813          	slli	a6,a4,0x1d
    77f0:	00365613          	srli	a2,a2,0x3
    77f4:	00c86833          	or	a6,a6,a2
    77f8:	00375713          	srli	a4,a4,0x3
    77fc:	00000793          	li	a5,0
    7800:	00068413          	mv	s0,a3
    7804:	ba5ff06f          	j	73a8 <__subdf3+0x47c>
    7808:	ba078ae3          	beqz	a5,73bc <__subdf3+0x490>
    780c:	413f06b3          	sub	a3,t5,s3
    7810:	00099663          	bnez	s3,781c <__subdf3+0x8f0>
    7814:	00068793          	mv	a5,a3
    7818:	a21ff06f          	j	7238 <__subdf3+0x30c>
    781c:	03800793          	li	a5,56
    7820:	00100913          	li	s2,1
    7824:	a6d7c4e3          	blt	a5,a3,728c <__subdf3+0x360>
    7828:	008007b7          	lui	a5,0x800
    782c:	00f76733          	or	a4,a4,a5
    7830:	a2dff06f          	j	725c <__subdf3+0x330>

00007834 <__fixdfsi>:
    7834:	0145d793          	srli	a5,a1,0x14
    7838:	001006b7          	lui	a3,0x100
    783c:	fff68713          	addi	a4,a3,-1 # fffff <__freertos_irq_stack_top+0xf46bf>
    7840:	7ff7f793          	andi	a5,a5,2047
    7844:	3fe00613          	li	a2,1022
    7848:	00b77733          	and	a4,a4,a1
    784c:	01f5d593          	srli	a1,a1,0x1f
    7850:	00f65e63          	bge	a2,a5,786c <__fixdfsi+0x38>
    7854:	41d00613          	li	a2,1053
    7858:	00f65e63          	bge	a2,a5,7874 <__fixdfsi+0x40>
    785c:	80000537          	lui	a0,0x80000
    7860:	fff50513          	addi	a0,a0,-1 # 7fffffff <__freertos_irq_stack_top+0x7fff46bf>
    7864:	00a58533          	add	a0,a1,a0
    7868:	00008067          	ret
    786c:	00000513          	li	a0,0
    7870:	00008067          	ret
    7874:	43300613          	li	a2,1075
    7878:	40f60633          	sub	a2,a2,a5
    787c:	01f00813          	li	a6,31
    7880:	00d76733          	or	a4,a4,a3
    7884:	02c85063          	bge	a6,a2,78a4 <__fixdfsi+0x70>
    7888:	41300693          	li	a3,1043
    788c:	40f687b3          	sub	a5,a3,a5
    7890:	00f75733          	srl	a4,a4,a5
    7894:	40e00533          	neg	a0,a4
    7898:	fc059ce3          	bnez	a1,7870 <__fixdfsi+0x3c>
    789c:	00070513          	mv	a0,a4
    78a0:	00008067          	ret
    78a4:	bed78793          	addi	a5,a5,-1043 # 7ffbed <__freertos_irq_stack_top+0x7f42ad>
    78a8:	00f71733          	sll	a4,a4,a5
    78ac:	00c55533          	srl	a0,a0,a2
    78b0:	00a76733          	or	a4,a4,a0
    78b4:	fe1ff06f          	j	7894 <__fixdfsi+0x60>

000078b8 <__fixunsdfsi>:
    78b8:	0145d793          	srli	a5,a1,0x14
    78bc:	00100637          	lui	a2,0x100
    78c0:	fff60713          	addi	a4,a2,-1 # fffff <__freertos_irq_stack_top+0xf46bf>
    78c4:	7ff7f793          	andi	a5,a5,2047
    78c8:	3fe00813          	li	a6,1022
    78cc:	00050693          	mv	a3,a0
    78d0:	00b77733          	and	a4,a4,a1
    78d4:	00000513          	li	a0,0
    78d8:	01f5d593          	srli	a1,a1,0x1f
    78dc:	00f85463          	bge	a6,a5,78e4 <__fixunsdfsi+0x2c>
    78e0:	00058463          	beqz	a1,78e8 <__fixunsdfsi+0x30>
    78e4:	00008067          	ret
    78e8:	41e00593          	li	a1,1054
    78ec:	fff00513          	li	a0,-1
    78f0:	fef5cae3          	blt	a1,a5,78e4 <__fixunsdfsi+0x2c>
    78f4:	43300593          	li	a1,1075
    78f8:	40f585b3          	sub	a1,a1,a5
    78fc:	01f00513          	li	a0,31
    7900:	00c76733          	or	a4,a4,a2
    7904:	00b54c63          	blt	a0,a1,791c <__fixunsdfsi+0x64>
    7908:	bed78793          	addi	a5,a5,-1043
    790c:	00f71733          	sll	a4,a4,a5
    7910:	00b6d533          	srl	a0,a3,a1
    7914:	00a76533          	or	a0,a4,a0
    7918:	00008067          	ret
    791c:	41300513          	li	a0,1043
    7920:	40f50533          	sub	a0,a0,a5
    7924:	00a75533          	srl	a0,a4,a0
    7928:	00008067          	ret

0000792c <__floatsidf>:
    792c:	ff010113          	addi	sp,sp,-16
    7930:	00112623          	sw	ra,12(sp)
    7934:	00812423          	sw	s0,8(sp)
    7938:	00912223          	sw	s1,4(sp)
    793c:	04050a63          	beqz	a0,7990 <__floatsidf+0x64>
    7940:	41f55713          	srai	a4,a0,0x1f
    7944:	00a744b3          	xor	s1,a4,a0
    7948:	40e484b3          	sub	s1,s1,a4
    794c:	00050793          	mv	a5,a0
    7950:	00048513          	mv	a0,s1
    7954:	01f7d413          	srli	s0,a5,0x1f
    7958:	150000ef          	jal	7aa8 <__clzsi2>
    795c:	41e00793          	li	a5,1054
    7960:	40a787b3          	sub	a5,a5,a0
    7964:	00a00713          	li	a4,10
    7968:	7ff7f793          	andi	a5,a5,2047
    796c:	06a74063          	blt	a4,a0,79cc <__floatsidf+0xa0>
    7970:	00b00713          	li	a4,11
    7974:	40a70733          	sub	a4,a4,a0
    7978:	00e4d733          	srl	a4,s1,a4
    797c:	01550513          	addi	a0,a0,21
    7980:	00c71713          	slli	a4,a4,0xc
    7984:	00a494b3          	sll	s1,s1,a0
    7988:	00c75713          	srli	a4,a4,0xc
    798c:	0140006f          	j	79a0 <__floatsidf+0x74>
    7990:	00000413          	li	s0,0
    7994:	00000793          	li	a5,0
    7998:	00000713          	li	a4,0
    799c:	00000493          	li	s1,0
    79a0:	01479793          	slli	a5,a5,0x14
    79a4:	01f41413          	slli	s0,s0,0x1f
    79a8:	00e7e7b3          	or	a5,a5,a4
    79ac:	00c12083          	lw	ra,12(sp)
    79b0:	0087e7b3          	or	a5,a5,s0
    79b4:	00812403          	lw	s0,8(sp)
    79b8:	00048513          	mv	a0,s1
    79bc:	00078593          	mv	a1,a5
    79c0:	00412483          	lw	s1,4(sp)
    79c4:	01010113          	addi	sp,sp,16
    79c8:	00008067          	ret
    79cc:	ff550513          	addi	a0,a0,-11
    79d0:	00a49733          	sll	a4,s1,a0
    79d4:	00c71713          	slli	a4,a4,0xc
    79d8:	00c75713          	srli	a4,a4,0xc
    79dc:	00000493          	li	s1,0
    79e0:	fc1ff06f          	j	79a0 <__floatsidf+0x74>

000079e4 <__floatunsidf>:
    79e4:	ff010113          	addi	sp,sp,-16
    79e8:	00812423          	sw	s0,8(sp)
    79ec:	00112623          	sw	ra,12(sp)
    79f0:	00050413          	mv	s0,a0
    79f4:	04050c63          	beqz	a0,7a4c <__floatunsidf+0x68>
    79f8:	0b0000ef          	jal	7aa8 <__clzsi2>
    79fc:	41e00793          	li	a5,1054
    7a00:	40a787b3          	sub	a5,a5,a0
    7a04:	00a00713          	li	a4,10
    7a08:	7ff7f793          	andi	a5,a5,2047
    7a0c:	06a74463          	blt	a4,a0,7a74 <__floatunsidf+0x90>
    7a10:	00b00713          	li	a4,11
    7a14:	40a70733          	sub	a4,a4,a0
    7a18:	01550513          	addi	a0,a0,21
    7a1c:	00e45733          	srl	a4,s0,a4
    7a20:	00a41433          	sll	s0,s0,a0
    7a24:	00c12083          	lw	ra,12(sp)
    7a28:	00040513          	mv	a0,s0
    7a2c:	00c71713          	slli	a4,a4,0xc
    7a30:	00812403          	lw	s0,8(sp)
    7a34:	00c75713          	srli	a4,a4,0xc
    7a38:	01479793          	slli	a5,a5,0x14
    7a3c:	00e7e7b3          	or	a5,a5,a4
    7a40:	00078593          	mv	a1,a5
    7a44:	01010113          	addi	sp,sp,16
    7a48:	00008067          	ret
    7a4c:	00c12083          	lw	ra,12(sp)
    7a50:	00040513          	mv	a0,s0
    7a54:	00000793          	li	a5,0
    7a58:	00812403          	lw	s0,8(sp)
    7a5c:	00000713          	li	a4,0
    7a60:	01479793          	slli	a5,a5,0x14
    7a64:	00e7e7b3          	or	a5,a5,a4
    7a68:	00078593          	mv	a1,a5
    7a6c:	01010113          	addi	sp,sp,16
    7a70:	00008067          	ret
    7a74:	ff550513          	addi	a0,a0,-11
    7a78:	00a41733          	sll	a4,s0,a0
    7a7c:	00000413          	li	s0,0
    7a80:	00c12083          	lw	ra,12(sp)
    7a84:	00040513          	mv	a0,s0
    7a88:	00c71713          	slli	a4,a4,0xc
    7a8c:	00812403          	lw	s0,8(sp)
    7a90:	00c75713          	srli	a4,a4,0xc
    7a94:	01479793          	slli	a5,a5,0x14
    7a98:	00e7e7b3          	or	a5,a5,a4
    7a9c:	00078593          	mv	a1,a5
    7aa0:	01010113          	addi	sp,sp,16
    7aa4:	00008067          	ret

00007aa8 <__clzsi2>:
    7aa8:	000107b7          	lui	a5,0x10
    7aac:	02f57a63          	bgeu	a0,a5,7ae0 <__clzsi2+0x38>
    7ab0:	10053793          	sltiu	a5,a0,256
    7ab4:	0017b793          	seqz	a5,a5
    7ab8:	00379793          	slli	a5,a5,0x3
    7abc:	02000713          	li	a4,32
    7ac0:	40f70733          	sub	a4,a4,a5
    7ac4:	00f55533          	srl	a0,a0,a5
    7ac8:	00002797          	auipc	a5,0x2
    7acc:	28878793          	addi	a5,a5,648 # 9d50 <__clz_tab>
    7ad0:	00a787b3          	add	a5,a5,a0
    7ad4:	0007c503          	lbu	a0,0(a5)
    7ad8:	40a70533          	sub	a0,a4,a0
    7adc:	00008067          	ret
    7ae0:	010007b7          	lui	a5,0x1000
    7ae4:	02f57463          	bgeu	a0,a5,7b0c <__clzsi2+0x64>
    7ae8:	01000793          	li	a5,16
    7aec:	00f55533          	srl	a0,a0,a5
    7af0:	00002797          	auipc	a5,0x2
    7af4:	26078793          	addi	a5,a5,608 # 9d50 <__clz_tab>
    7af8:	00a787b3          	add	a5,a5,a0
    7afc:	0007c503          	lbu	a0,0(a5)
    7b00:	01000713          	li	a4,16
    7b04:	40a70533          	sub	a0,a4,a0
    7b08:	00008067          	ret
    7b0c:	01800793          	li	a5,24
    7b10:	00f55533          	srl	a0,a0,a5
    7b14:	00002797          	auipc	a5,0x2
    7b18:	23c78793          	addi	a5,a5,572 # 9d50 <__clz_tab>
    7b1c:	00a787b3          	add	a5,a5,a0
    7b20:	0007c503          	lbu	a0,0(a5)
    7b24:	00800713          	li	a4,8
    7b28:	40a70533          	sub	a0,a4,a0
    7b2c:	00008067          	ret
