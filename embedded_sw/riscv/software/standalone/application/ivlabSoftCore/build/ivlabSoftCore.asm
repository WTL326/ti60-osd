
build/ivlabSoftCore.elf:     file format elf32-littleriscv


Disassembly of section .init:

00001000 <_start>:

_start:
#ifdef USE_GP
.option push
.option norelax
	la gp, __global_pointer$
    1000:	00007197          	auipc	gp,0x7
    1004:	f2818193          	addi	gp,gp,-216 # 7f28 <__global_pointer$>
.global smp_lottery_target
.global smp_lottery_lock
.global smp_slave


  sw x0, smp_lottery_lock, a1
    1008:	f401a823          	sw	zero,-176(gp) # 7e78 <smp_lottery_lock>

0000100c <smp_tyranny>:

smp_tyranny:
  csrr a0, mhartid
    100c:	f1402573          	csrr	a0,mhartid
  beqz a0, init
    1010:	02050e63          	beqz	a0,104c <init>

00001014 <smp_slave>:

smp_slave:
	lw a0, smp_lottery_lock
    1014:	f501a503          	lw	a0,-176(gp) # 7e78 <smp_lottery_lock>
	beqz a0, smp_slave
    1018:	fe050ee3          	beqz	a0,1014 <smp_slave>

	fence r, r
    101c:	0220000f          	fence	r,r
    1020:	0000100f          	.word	0x0000100f
	//li a1, -1
	//amoadd.w x0, a1,(a0)

	.word(0x100F) //i$ flush
	lw a5, smp_lottery_target
    1024:	f4c1a783          	lw	a5,-180(gp) # 7e74 <smp_lottery_target>
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
    1038:	f4a1a623          	sw	a0,-180(gp) # 7e74 <smp_lottery_target>
	fence w, w
    103c:	0110000f          	fence	w,w
	li a0, 1
    1040:	00100513          	li	a0,1
	sw a0, smp_lottery_lock, a1
    1044:	f4a1a823          	sw	a0,-176(gp) # 7e78 <smp_lottery_lock>
    ret
    1048:	00008067          	ret

0000104c <init>:
#endif

init:
	la sp, _sp
    104c:	00008117          	auipc	sp,0x8
    1050:	e3410113          	addi	sp,sp,-460 # 8e80 <__freertos_irq_stack_top>

	/* Load data section */
	la a0, _data_lma
    1054:	00006517          	auipc	a0,0x6
    1058:	00450513          	addi	a0,a0,4 # 7058 <_data>
	la a1, _data
    105c:	00006597          	auipc	a1,0x6
    1060:	ffc58593          	addi	a1,a1,-4 # 7058 <_data>
	la a2, _edata
    1064:	00006617          	auipc	a2,0x6
    1068:	77860613          	addi	a2,a2,1912 # 77dc <__bss_start>
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
    1084:	00006517          	auipc	a0,0x6
    1088:	75850513          	addi	a0,a0,1880 # 77dc <__bss_start>
	la a1, _end
    108c:	00007597          	auipc	a1,0x7
    1090:	df458593          	addi	a1,a1,-524 # 7e80 <_end>
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
    10cc:	00006797          	auipc	a5,0x6
    10d0:	f8c78793          	addi	a5,a5,-116 # 7058 <_data>
    10d4:	00006417          	auipc	s0,0x6
    10d8:	f8440413          	addi	s0,s0,-124 # 7058 <_data>
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
    1108:	00006797          	auipc	a5,0x6
    110c:	f5078793          	addi	a5,a5,-176 # 7058 <_data>
    1110:	00006417          	auipc	s0,0x6
    1114:	f4840413          	addi	s0,s0,-184 # 7058 <_data>
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
    1154:	fe010113          	addi	sp,sp,-32
    1158:	00112e23          	sw	ra,28(sp)
    bsp_init();                 /* BSP 的通用初始化，其中包含 uart0 的配置 */
    115c:	300020ef          	jal	345c <bsp_init>
    app_log_init();
    1160:	01c020ef          	jal	317c <app_log_init>
    frame_parser_init(&s_parser);
    1164:	d3818513          	addi	a0,gp,-712 # 7c60 <s_parser>
    1168:	6e0020ef          	jal	3848 <frame_parser_init>
    protocol_init(&s_stats);
    116c:	d2c18513          	addi	a0,gp,-724 # 7c54 <s_stats>
    1170:	53d020ef          	jal	3eac <protocol_init>

    /* 启动横幅。这几行主要是给现场确认"固件确实跑起来了"用的。
     * 把协议出处一并打出来：这条串口线上跑着好几个功能模块的帧，出问题时
     * 第一件要确认的就是"两端说的是不是同一代协议"。*/
    app_log("*** ivlabSoftCore ***");
    1174:	00007537          	lui	a0,0x7
    1178:	22050513          	addi	a0,a0,544 # 7220 <_data+0x1c8>
    117c:	100020ef          	jal	327c <app_log>
    app_log("debug channel: semihosting (JTAG)");
    1180:	00007537          	lui	a0,0x7
    1184:	23850513          	addi	a0,a0,568 # 7238 <_data+0x1e0>
    1188:	0f4020ef          	jal	327c <app_log>
    app_log("protocol: BB frame, mask category 0x00 (docs/测试说明.md)");
    118c:	00007537          	lui	a0,0x7
    1190:	25c50513          	addi	a0,a0,604 # 725c <_data+0x204>
    1194:	0e8020ef          	jal	327c <app_log>

    /* 协议端点可用与否，取决于 SoC 是否生成了 uart1（见 proto_uart.h）。
     * 这里把结果明确打出来：一是让现场知道协议能不能用，二是它的 base 地址
     * 可以和 RTL 侧的 rtl_mask_mode 取值交叉核对，确认"只有一个端点在应答"。*/
    if (PROTO_ENDPOINT_AVAILABLE) {
        proto_uart_init();
    1198:	215020ef          	jal	3bac <proto_uart_init>
        isr_init();
    119c:	330020ef          	jal	34cc <isr_init>
        app_log("protocol endpoint: ENABLED on uart1 (base 0x%x)",
    11a0:	f80025b7          	lui	a1,0xf8002
    11a4:	00007537          	lui	a0,0x7
    11a8:	29c50513          	addi	a0,a0,668 # 729c <_data+0x244>
    11ac:	0d0020ef          	jal	327c <app_log>
    11b0:	0340006f          	j	11e4 <main+0x90>
         * 因此一次上传期间这个条件根本不会成立，日志会一直待在环里，等整批
         * 结束后一次性发出，上传期间一次停顿都没有。
         *
         * 这样做的代价是日志不再"实时"——但换来的是协议本身可靠，而且那批
         * 日志会在结束后的 200 ms 内完整出现，排查并不受影响。*/
        if ((app_log_pending() != 0U) || (s_frames_processed != s_reported_frames)) {
    11b4:	7dd010ef          	jal	3190 <app_log_pending>
    11b8:	00051863          	bnez	a0,11c8 <main+0x74>
    11bc:	8f41a703          	lw	a4,-1804(gp) # 781c <s_frames_processed>
    11c0:	8d41a783          	lw	a5,-1836(gp) # 77fc <s_reported_frames>
    11c4:	02f70063          	beq	a4,a5,11e4 <main+0x90>
            /* 读 CLINT 时间是 3 次 MMIO，不能每轮都做；用计数器粗降频。*/
            s_idle_spins++;
    11c8:	8d01a783          	lw	a5,-1840(gp) # 77f8 <s_idle_spins>
    11cc:	00178793          	addi	a5,a5,1
    11d0:	8cf1a823          	sw	a5,-1840(gp) # 77f8 <s_idle_spins>
            if ((s_idle_spins & (IDLE_TICKS_DIVIDER - 1U)) == 0U) {
    11d4:	00001737          	lui	a4,0x1
    11d8:	fff70713          	addi	a4,a4,-1 # fff <CUSTOM2+0xfa4>
    11dc:	00e7f7b3          	and	a5,a5,a4
    11e0:	04078063          	beqz	a5,1220 <main+0xcc>
        while (proto_uart_rx_pop(&byte)) {
    11e4:	00310513          	addi	a0,sp,3
    11e8:	259020ef          	jal	3c40 <proto_uart_rx_pop>
    11ec:	fc0504e3          	beqz	a0,11b4 <main+0x60>
            s_last_rx_ticks = clint_getTime(BSP_CLINT);
    11f0:	f8b00537          	lui	a0,0xf8b00
    11f4:	238020ef          	jal	342c <clint_getTime>
    11f8:	8ca1ac23          	sw	a0,-1832(gp) # 7800 <s_last_rx_ticks>
    11fc:	8cb1ae23          	sw	a1,-1828(gp) # 7804 <s_last_rx_ticks+0x4>
            if (frame_parser_feed(&s_parser, byte, &frame) != 0) {
    1200:	00410613          	addi	a2,sp,4
    1204:	00314583          	lbu	a1,3(sp)
    1208:	d3818513          	addi	a0,gp,-712 # 7c60 <s_parser>
    120c:	668020ef          	jal	3874 <frame_parser_feed>
    1210:	fc050ae3          	beqz	a0,11e4 <main+0x90>
                handle_frame(&frame);
    1214:	00410513          	addi	a0,sp,4
    1218:	4a0020ef          	jal	36b8 <handle_frame>
    121c:	fc9ff06f          	j	11e4 <main+0x90>
                if ((clint_getTime(BSP_CLINT) - s_last_rx_ticks) >= APP_LOG_IDLE_TICKS) {
    1220:	f8b00537          	lui	a0,0xf8b00
    1224:	208020ef          	jal	342c <clint_getTime>
    1228:	8d81a783          	lw	a5,-1832(gp) # 7800 <s_last_rx_ticks>
    122c:	8dc1a703          	lw	a4,-1828(gp) # 7804 <s_last_rx_ticks+0x4>
    1230:	40f507b3          	sub	a5,a0,a5
    1234:	00f53533          	sltu	a0,a0,a5
    1238:	40e585b3          	sub	a1,a1,a4
    123c:	40a58733          	sub	a4,a1,a0
    1240:	00a59a63          	bne	a1,a0,1254 <main+0x100>
    1244:	fa0710e3          	bnez	a4,11e4 <main+0x90>
    1248:	00989737          	lui	a4,0x989
    124c:	67f70713          	addi	a4,a4,1663 # 98967f <__freertos_irq_stack_top+0x9807ff>
    1250:	f8f77ae3          	bgeu	a4,a5,11e4 <main+0x90>
                    /* 线路静默够久，说明这一批数据结束了。先补一条汇总，
                     * 保证"这一批收了多少、丢了多少"一定可见——短跑批够不到
                     * STATS_INTERVAL，没有这一条就什么都看不到。*/
                    if (s_frames_processed != s_reported_frames) {
    1254:	8f41a703          	lw	a4,-1804(gp) # 781c <s_frames_processed>
    1258:	8d41a783          	lw	a5,-1836(gp) # 77fc <s_reported_frames>
    125c:	00f71663          	bne	a4,a5,1268 <main+0x114>
                        log_stats();
                    }
                    (void)app_log_flush();
    1260:	0c0020ef          	jal	3320 <app_log_flush>
    while (1) {
    1264:	f81ff06f          	j	11e4 <main+0x90>
                        log_stats();
    1268:	398020ef          	jal	3600 <log_stats>
    126c:	ff5ff06f          	j	1260 <main+0x10c>

00001270 <sh_write0>:
* @note    None.
*
******************************************************************************/

static void sh_write0(char* buf)
{
    1270:	00050593          	mv	a1,a0
    register int value asm ("a0") = reason;
    1274:	00400513          	li	a0,4
    register void* ptr asm ("a1") = arg;
    1278:	00000013          	nop
    127c:	00000013          	nop
    asm volatile (
    1280:	01f01013          	slli	zero,zero,0x1f
    1284:	00100073          	ebreak
    1288:	40705013          	srai	zero,zero,0x7
    128c:	00000013          	nop
    // Print zero-terminated string
    call_host(SEMIHOSTING_SYS_WRITE0, (void*) buf);
}
    1290:	00008067          	ret
    1294:	00000013          	nop
    1298:	00000013          	nop

0000129c <_putchar_s>:
            bsp_putChar(character);
        #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }

    static void _putchar_s(char *p)
    {
    129c:	ff010113          	addi	sp,sp,-16
    12a0:	00112623          	sw	ra,12(sp)
    #if (ENABLE_SEMIHOSTING_PRINT == 1)
        sh_write0(p);
    12a4:	fcdff0ef          	jal	1270 <sh_write0>
    #else
        while (*p)
            _putchar(*(p++));
    #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }
    12a8:	00c12083          	lw	ra,12(sp)
    12ac:	01010113          	addi	sp,sp,16
    12b0:	00008067          	ret

000012b4 <_out_buffer>:
*
******************************************************************************/

static inline void _out_buffer(char character, void* buffer, size_t idx, size_t maxlen)
{
  if (idx < maxlen) {
    12b4:	00d67663          	bgeu	a2,a3,12c0 <_out_buffer+0xc>
    ((char*)buffer)[idx] = character;
    12b8:	00c585b3          	add	a1,a1,a2
    12bc:	00a58023          	sb	a0,0(a1) # f8002000 <__freertos_irq_stack_top+0xf7ff9180>
  }
}
    12c0:	00008067          	ret

000012c4 <_out_null>:
*
******************************************************************************/
static inline void _out_null(char character, void* buffer, size_t idx, size_t maxlen)
{
  (void)character; (void)buffer; (void)idx; (void)maxlen;
}
    12c4:	00008067          	ret

000012c8 <_atoi>:
*
* @return Converted unsigned integer value.
*
******************************************************************************/
static unsigned int _atoi(const char** str)
{
    12c8:	00050693          	mv	a3,a0
  unsigned int i = 0U;
    12cc:	00000513          	li	a0,0
  while (_is_digit(**str)) {
    12d0:	0240006f          	j	12f4 <_atoi+0x2c>
    i = i * 10U + (unsigned int)(*((*str)++) - '0');
    12d4:	00251793          	slli	a5,a0,0x2
    12d8:	00a787b3          	add	a5,a5,a0
    12dc:	00179793          	slli	a5,a5,0x1
    12e0:	00170613          	addi	a2,a4,1
    12e4:	00c6a023          	sw	a2,0(a3)
    12e8:	00074503          	lbu	a0,0(a4)
    12ec:	00f50533          	add	a0,a0,a5
    12f0:	fd050513          	addi	a0,a0,-48 # f8afffd0 <__freertos_irq_stack_top+0xf8af7150>
  while (_is_digit(**str)) {
    12f4:	0006a703          	lw	a4,0(a3)
    12f8:	00074783          	lbu	a5,0(a4)
  return (ch >= '0') && (ch <= '9');
    12fc:	fd078793          	addi	a5,a5,-48
    1300:	0ff7f793          	zext.b	a5,a5
  while (_is_digit(**str)) {
    1304:	00900613          	li	a2,9
    1308:	fcf676e3          	bgeu	a2,a5,12d4 <_atoi+0xc>
  }
  return i;
}
    130c:	00008067          	ret

00001310 <_out_rev>:
*
* @return Updated index in the buffer after outputting the string.
*
******************************************************************************/
static size_t _out_rev(out_fct_type out, char* buffer, size_t idx, size_t maxlen, const char* buf, size_t len, unsigned int width, unsigned int flags)
{
    1310:	fd010113          	addi	sp,sp,-48
    1314:	02112623          	sw	ra,44(sp)
    1318:	02812423          	sw	s0,40(sp)
    131c:	02912223          	sw	s1,36(sp)
    1320:	03212023          	sw	s2,32(sp)
    1324:	01312e23          	sw	s3,28(sp)
    1328:	01412c23          	sw	s4,24(sp)
    132c:	01512a23          	sw	s5,20(sp)
    1330:	01612823          	sw	s6,16(sp)
    1334:	01712623          	sw	s7,12(sp)
    1338:	01812423          	sw	s8,8(sp)
    133c:	00050493          	mv	s1,a0
    1340:	00058913          	mv	s2,a1
    1344:	00060b93          	mv	s7,a2
    1348:	00068993          	mv	s3,a3
    134c:	00070b13          	mv	s6,a4
    1350:	00078413          	mv	s0,a5
    1354:	00080a93          	mv	s5,a6
    1358:	00088c13          	mv	s8,a7
  const size_t start_idx = idx;

  // pad spaces up to given width
  if (!(flags & FLAGS_LEFT) && !(flags & FLAGS_ZEROPAD)) {
    135c:	0038f793          	andi	a5,a7,3
    1360:	04079c63          	bnez	a5,13b8 <_out_rev+0xa8>
    1364:	01912223          	sw	s9,4(sp)
    for (size_t i = len; i < width; i++) {
    1368:	00040a13          	mv	s4,s0
    136c:	035a7263          	bgeu	s4,s5,1390 <_out_rev+0x80>
      out(' ', buffer, idx++, maxlen);
    1370:	00160c93          	addi	s9,a2,1
    1374:	00098693          	mv	a3,s3
    1378:	00090593          	mv	a1,s2
    137c:	02000513          	li	a0,32
    1380:	000480e7          	jalr	s1
    for (size_t i = len; i < width; i++) {
    1384:	001a0a13          	addi	s4,s4,1
      out(' ', buffer, idx++, maxlen);
    1388:	000c8613          	mv	a2,s9
    138c:	fe1ff06f          	j	136c <_out_rev+0x5c>
    1390:	00412c83          	lw	s9,4(sp)
    1394:	0240006f          	j	13b8 <_out_rev+0xa8>
    }
  }

  // reverse string
  while (len) {
    out(buf[--len], buffer, idx++, maxlen);
    1398:	fff40413          	addi	s0,s0,-1
    139c:	008b07b3          	add	a5,s6,s0
    13a0:	00160a13          	addi	s4,a2,1
    13a4:	00098693          	mv	a3,s3
    13a8:	00090593          	mv	a1,s2
    13ac:	0007c503          	lbu	a0,0(a5)
    13b0:	000480e7          	jalr	s1
    13b4:	000a0613          	mv	a2,s4
  while (len) {
    13b8:	fe0410e3          	bnez	s0,1398 <_out_rev+0x88>
  }

  // append pad spaces up to given width
  if (flags & FLAGS_LEFT) {
    13bc:	002c7c13          	andi	s8,s8,2
    13c0:	020c1c63          	bnez	s8,13f8 <_out_rev+0xe8>
      out(' ', buffer, idx++, maxlen);
    }
  }

  return idx;
}
    13c4:	00060513          	mv	a0,a2
    13c8:	02c12083          	lw	ra,44(sp)
    13cc:	02812403          	lw	s0,40(sp)
    13d0:	02412483          	lw	s1,36(sp)
    13d4:	02012903          	lw	s2,32(sp)
    13d8:	01c12983          	lw	s3,28(sp)
    13dc:	01812a03          	lw	s4,24(sp)
    13e0:	01412a83          	lw	s5,20(sp)
    13e4:	01012b03          	lw	s6,16(sp)
    13e8:	00c12b83          	lw	s7,12(sp)
    13ec:	00812c03          	lw	s8,8(sp)
    13f0:	03010113          	addi	sp,sp,48
    13f4:	00008067          	ret
    while (idx - start_idx < width) {
    13f8:	417607b3          	sub	a5,a2,s7
    13fc:	fd57f4e3          	bgeu	a5,s5,13c4 <_out_rev+0xb4>
      out(' ', buffer, idx++, maxlen);
    1400:	00160413          	addi	s0,a2,1
    1404:	00098693          	mv	a3,s3
    1408:	00090593          	mv	a1,s2
    140c:	02000513          	li	a0,32
    1410:	000480e7          	jalr	s1
    1414:	00040613          	mv	a2,s0
    1418:	fe1ff06f          	j	13f8 <_out_rev+0xe8>

0000141c <_ntoa_format>:
*
* @return Number of characters written to the buffer.
*
******************************************************************************/
static size_t _ntoa_format(out_fct_type out, char* buffer, size_t idx, size_t maxlen, char* buf, size_t len, bool negative, unsigned int base, unsigned int prec, unsigned int width, unsigned int flags)
{
    141c:	ff010113          	addi	sp,sp,-16
    1420:	00112623          	sw	ra,12(sp)
    1424:	00080f93          	mv	t6,a6
    1428:	00088f13          	mv	t5,a7
    142c:	01012e83          	lw	t4,16(sp)
    1430:	01412803          	lw	a6,20(sp)
    1434:	01812883          	lw	a7,24(sp)
  // pad leading zeros
  if (!(flags & FLAGS_LEFT)) {
    1438:	0028f313          	andi	t1,a7,2
    143c:	06031463          	bnez	t1,14a4 <_ntoa_format+0x88>
    if (width && (flags & FLAGS_ZEROPAD) && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
    1440:	02080863          	beqz	a6,1470 <_ntoa_format+0x54>
    1444:	0018f313          	andi	t1,a7,1
    1448:	02030463          	beqz	t1,1470 <_ntoa_format+0x54>
    144c:	000f9663          	bnez	t6,1458 <_ntoa_format+0x3c>
    1450:	00c8f313          	andi	t1,a7,12
    1454:	00030e63          	beqz	t1,1470 <_ntoa_format+0x54>
      width--;
    1458:	fff80813          	addi	a6,a6,-1
    145c:	0140006f          	j	1470 <_ntoa_format+0x54>
    }
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = '0';
    1460:	00f70333          	add	t1,a4,a5
    1464:	03000e13          	li	t3,48
    1468:	01c30023          	sb	t3,0(t1)
    146c:	00178793          	addi	a5,a5,1
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1470:	01d7f663          	bgeu	a5,t4,147c <_ntoa_format+0x60>
    1474:	01f00313          	li	t1,31
    1478:	fef374e3          	bgeu	t1,a5,1460 <_ntoa_format+0x44>
    }
    while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    147c:	0018f313          	andi	t1,a7,1
    1480:	02030263          	beqz	t1,14a4 <_ntoa_format+0x88>
    1484:	0307f063          	bgeu	a5,a6,14a4 <_ntoa_format+0x88>
    1488:	01f00313          	li	t1,31
    148c:	00f36c63          	bltu	t1,a5,14a4 <_ntoa_format+0x88>
      buf[len++] = '0';
    1490:	00f70333          	add	t1,a4,a5
    1494:	03000e13          	li	t3,48
    1498:	01c30023          	sb	t3,0(t1)
    149c:	00178793          	addi	a5,a5,1
    14a0:	fddff06f          	j	147c <_ntoa_format+0x60>
    }
  }

  // handle hash
  if (flags & FLAGS_HASH) {
    14a4:	0108f313          	andi	t1,a7,16
    14a8:	04030063          	beqz	t1,14e8 <_ntoa_format+0xcc>
    if (!(flags & FLAGS_PRECISION) && len && ((len == prec) || (len == width))) {
    14ac:	4008f313          	andi	t1,a7,1024
    14b0:	00031863          	bnez	t1,14c0 <_ntoa_format+0xa4>
    14b4:	00078663          	beqz	a5,14c0 <_ntoa_format+0xa4>
    14b8:	05d78e63          	beq	a5,t4,1514 <_ntoa_format+0xf8>
    14bc:	05078c63          	beq	a5,a6,1514 <_ntoa_format+0xf8>
      len--;
      if (len && (base == 16U)) {
        len--;
      }
    }
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    14c0:	01000313          	li	t1,16
    14c4:	0a6f0063          	beq	t5,t1,1564 <_ntoa_format+0x148>
      buf[len++] = 'x';
    }
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = 'X';
    }
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    14c8:	00200313          	li	t1,2
    14cc:	0a6f0e63          	beq	t5,t1,1588 <_ntoa_format+0x16c>
      buf[len++] = 'b';
    }
    if (len < PRINTF_NTOA_BUFFER_SIZE) {
    14d0:	01f00313          	li	t1,31
    14d4:	02f36863          	bltu	t1,a5,1504 <_ntoa_format+0xe8>
      buf[len++] = '0';
    14d8:	00f70333          	add	t1,a4,a5
    14dc:	03000e13          	li	t3,48
    14e0:	01c30023          	sb	t3,0(t1)
    14e4:	00178793          	addi	a5,a5,1
    }
  }

  if (len < PRINTF_NTOA_BUFFER_SIZE) {
    14e8:	01f00313          	li	t1,31
    14ec:	00f36c63          	bltu	t1,a5,1504 <_ntoa_format+0xe8>
    if (negative) {
    14f0:	0a0f8a63          	beqz	t6,15a4 <_ntoa_format+0x188>
      buf[len++] = '-';
    14f4:	00f70333          	add	t1,a4,a5
    14f8:	02d00e13          	li	t3,45
    14fc:	01c30023          	sb	t3,0(t1)
    1500:	00178793          	addi	a5,a5,1
    else if (flags & FLAGS_SPACE) {
      buf[len++] = ' ';
    }
  }

  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
    1504:	e0dff0ef          	jal	1310 <_out_rev>
}
    1508:	00c12083          	lw	ra,12(sp)
    150c:	01010113          	addi	sp,sp,16
    1510:	00008067          	ret
      len--;
    1514:	fff78313          	addi	t1,a5,-1
      if (len && (base == 16U)) {
    1518:	04030263          	beqz	t1,155c <_ntoa_format+0x140>
    151c:	01000e13          	li	t3,16
    1520:	03cf0a63          	beq	t5,t3,1554 <_ntoa_format+0x138>
      len--;
    1524:	00030793          	mv	a5,t1
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1528:	01000313          	li	t1,16
    152c:	f86f1ee3          	bne	t5,t1,14c8 <_ntoa_format+0xac>
    1530:	0208f313          	andi	t1,a7,32
    1534:	f8030ae3          	beqz	t1,14c8 <_ntoa_format+0xac>
    1538:	01f00313          	li	t1,31
    153c:	f8f366e3          	bltu	t1,a5,14c8 <_ntoa_format+0xac>
      buf[len++] = 'X';
    1540:	00f70333          	add	t1,a4,a5
    1544:	05800e13          	li	t3,88
    1548:	01c30023          	sb	t3,0(t1)
    154c:	00178793          	addi	a5,a5,1
    1550:	f81ff06f          	j	14d0 <_ntoa_format+0xb4>
        len--;
    1554:	ffe78793          	addi	a5,a5,-2
    1558:	f69ff06f          	j	14c0 <_ntoa_format+0xa4>
      len--;
    155c:	00030793          	mv	a5,t1
    1560:	f61ff06f          	j	14c0 <_ntoa_format+0xa4>
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1564:	0208f313          	andi	t1,a7,32
    1568:	fc0310e3          	bnez	t1,1528 <_ntoa_format+0x10c>
    156c:	01f00313          	li	t1,31
    1570:	faf36ce3          	bltu	t1,a5,1528 <_ntoa_format+0x10c>
      buf[len++] = 'x';
    1574:	00f70333          	add	t1,a4,a5
    1578:	07800e13          	li	t3,120
    157c:	01c30023          	sb	t3,0(t1)
    1580:	00178793          	addi	a5,a5,1
    1584:	f4dff06f          	j	14d0 <_ntoa_format+0xb4>
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1588:	01f00313          	li	t1,31
    158c:	f6f36ce3          	bltu	t1,a5,1504 <_ntoa_format+0xe8>
      buf[len++] = 'b';
    1590:	00f70333          	add	t1,a4,a5
    1594:	06200e13          	li	t3,98
    1598:	01c30023          	sb	t3,0(t1)
    159c:	00178793          	addi	a5,a5,1
    15a0:	f31ff06f          	j	14d0 <_ntoa_format+0xb4>
    else if (flags & FLAGS_PLUS) {
    15a4:	0048f313          	andi	t1,a7,4
    15a8:	00030c63          	beqz	t1,15c0 <_ntoa_format+0x1a4>
      buf[len++] = '+';  // ignore the space if the '+' exists
    15ac:	00f70333          	add	t1,a4,a5
    15b0:	02b00e13          	li	t3,43
    15b4:	01c30023          	sb	t3,0(t1)
    15b8:	00178793          	addi	a5,a5,1
    15bc:	f49ff06f          	j	1504 <_ntoa_format+0xe8>
    else if (flags & FLAGS_SPACE) {
    15c0:	0088f313          	andi	t1,a7,8
    15c4:	f40300e3          	beqz	t1,1504 <_ntoa_format+0xe8>
      buf[len++] = ' ';
    15c8:	00f70333          	add	t1,a4,a5
    15cc:	02000e13          	li	t3,32
    15d0:	01c30023          	sb	t3,0(t1)
    15d4:	00178793          	addi	a5,a5,1
    15d8:	f2dff06f          	j	1504 <_ntoa_format+0xe8>

000015dc <_ntoa_long>:
* @return Number of characters written to the buffer.
*
*
******************************************************************************/
static size_t _ntoa_long(out_fct_type out, char* buffer, size_t idx, size_t maxlen, unsigned long value, bool negative, unsigned long base, unsigned int prec, unsigned int width, unsigned int flags)
{
    15dc:	fc010113          	addi	sp,sp,-64
    15e0:	02112e23          	sw	ra,60(sp)
    15e4:	00078f93          	mv	t6,a5
    15e8:	04412f03          	lw	t5,68(sp)
  char buf[PRINTF_NTOA_BUFFER_SIZE];
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
    15ec:	00071463          	bnez	a4,15f4 <_ntoa_long+0x18>
    flags &= ~FLAGS_HASH;
    15f0:	feff7f13          	andi	t5,t5,-17
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
    15f4:	400f7e93          	andi	t4,t5,1024
    15f8:	040e8063          	beqz	t4,1638 <_ntoa_long+0x5c>
    15fc:	06070a63          	beqz	a4,1670 <_ntoa_long+0x94>
    1600:	00000e93          	li	t4,0
    1604:	0340006f          	j	1638 <_ntoa_long+0x5c>
    do {
      const char digit = (char)(value % base);
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1608:	030e0e13          	addi	t3,t3,48
    160c:	0ffe7313          	zext.b	t1,t3
    1610:	001e8793          	addi	a5,t4,1
    1614:	030e8e13          	addi	t3,t4,48
    1618:	002e0eb3          	add	t4,t3,sp
    161c:	fe6e8023          	sb	t1,-32(t4)
      value /= base;
    1620:	03075333          	divu	t1,a4,a6
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    1624:	05076863          	bltu	a4,a6,1674 <_ntoa_long+0x98>
    1628:	01f00713          	li	a4,31
    162c:	04f76463          	bltu	a4,a5,1674 <_ntoa_long+0x98>
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1630:	00078e93          	mv	t4,a5
      value /= base;
    1634:	00030713          	mv	a4,t1
      const char digit = (char)(value % base);
    1638:	03077e33          	remu	t3,a4,a6
    163c:	0ffe7e13          	zext.b	t3,t3
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1640:	00900313          	li	t1,9
    1644:	fdc372e3          	bgeu	t1,t3,1608 <_ntoa_long+0x2c>
    1648:	020f7313          	andi	t1,t5,32
    164c:	00030e63          	beqz	t1,1668 <_ntoa_long+0x8c>
    1650:	04100313          	li	t1,65
    1654:	01c30333          	add	t1,t1,t3
    1658:	0ff37313          	zext.b	t1,t1
    165c:	ff630313          	addi	t1,t1,-10
    1660:	0ff37313          	zext.b	t1,t1
    1664:	fadff06f          	j	1610 <_ntoa_long+0x34>
    1668:	06100313          	li	t1,97
    166c:	fe9ff06f          	j	1654 <_ntoa_long+0x78>
  size_t len = 0U;
    1670:	00070793          	mv	a5,a4
  }

  return _ntoa_format(out, buffer, idx, maxlen, buf, len, negative, (unsigned int)base, prec, width, flags);
    1674:	01e12423          	sw	t5,8(sp)
    1678:	04012703          	lw	a4,64(sp)
    167c:	00e12223          	sw	a4,4(sp)
    1680:	01112023          	sw	a7,0(sp)
    1684:	00080893          	mv	a7,a6
    1688:	000f8813          	mv	a6,t6
    168c:	01010713          	addi	a4,sp,16
    1690:	d8dff0ef          	jal	141c <_ntoa_format>
}
    1694:	03c12083          	lw	ra,60(sp)
    1698:	04010113          	addi	sp,sp,64
    169c:	00008067          	ret

000016a0 <_ntoa_long_long>:
*
* @return Number of characters written to the buffer.
*
******************************************************************************/
static size_t _ntoa_long_long(out_fct_type out, char* buffer, size_t idx, size_t maxlen, unsigned long long value, bool negative, unsigned long long base, unsigned int prec, unsigned int width, unsigned int flags)
{
    16a0:	f8010113          	addi	sp,sp,-128
    16a4:	06112623          	sw	ra,108(sp)
    16a8:	06812423          	sw	s0,104(sp)
    16ac:	06912223          	sw	s1,100(sp)
    16b0:	07212023          	sw	s2,96(sp)
    16b4:	05312e23          	sw	s3,92(sp)
    16b8:	05412c23          	sw	s4,88(sp)
    16bc:	05512a23          	sw	s5,84(sp)
    16c0:	05612823          	sw	s6,80(sp)
    16c4:	05712623          	sw	s7,76(sp)
    16c8:	05812423          	sw	s8,72(sp)
    16cc:	05912223          	sw	s9,68(sp)
    16d0:	05a12023          	sw	s10,64(sp)
    16d4:	03b12e23          	sw	s11,60(sp)
    16d8:	00050b93          	mv	s7,a0
    16dc:	00058c13          	mv	s8,a1
    16e0:	00060c93          	mv	s9,a2
    16e4:	00068d13          	mv	s10,a3
    16e8:	00070993          	mv	s3,a4
    16ec:	00078413          	mv	s0,a5
    16f0:	00080d93          	mv	s11,a6
    16f4:	07112e23          	sw	a7,124(sp)
    16f8:	00088a93          	mv	s5,a7
    16fc:	08012903          	lw	s2,128(sp)
    1700:	08c12b03          	lw	s6,140(sp)
  char buf[PRINTF_NTOA_BUFFER_SIZE];
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
    1704:	00f767b3          	or	a5,a4,a5
    1708:	00079463          	bnez	a5,1710 <_ntoa_long_long+0x70>
    flags &= ~FLAGS_HASH;
    170c:	fefb7b13          	andi	s6,s6,-17
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
    1710:	400b7493          	andi	s1,s6,1024
    1714:	04048e63          	beqz	s1,1770 <_ntoa_long_long+0xd0>
    1718:	0089e7b3          	or	a5,s3,s0
    171c:	0a078263          	beqz	a5,17c0 <_ntoa_long_long+0x120>
    1720:	00000493          	li	s1,0
    1724:	04c0006f          	j	1770 <_ntoa_long_long+0xd0>
    do {
      const char digit = (char)(value % base);
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1728:	03050513          	addi	a0,a0,48
    172c:	0ff57793          	zext.b	a5,a0
    1730:	00148a13          	addi	s4,s1,1
    1734:	03048713          	addi	a4,s1,48
    1738:	002704b3          	add	s1,a4,sp
    173c:	fef48023          	sb	a5,-32(s1)
      value /= base;
    1740:	000a8613          	mv	a2,s5
    1744:	00090693          	mv	a3,s2
    1748:	00098513          	mv	a0,s3
    174c:	00040593          	mv	a1,s0
    1750:	221020ef          	jal	4170 <__udivdi3>
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    1754:	07246863          	bltu	s0,s2,17c4 <_ntoa_long_long+0x124>
    1758:	06890063          	beq	s2,s0,17b8 <_ntoa_long_long+0x118>
    175c:	01f00793          	li	a5,31
    1760:	0747e263          	bltu	a5,s4,17c4 <_ntoa_long_long+0x124>
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1764:	000a0493          	mv	s1,s4
      value /= base;
    1768:	00050993          	mv	s3,a0
    176c:	00058413          	mv	s0,a1
      const char digit = (char)(value % base);
    1770:	000a8613          	mv	a2,s5
    1774:	00090693          	mv	a3,s2
    1778:	00098513          	mv	a0,s3
    177c:	00040593          	mv	a1,s0
    1780:	6a1020ef          	jal	4620 <__umoddi3>
    1784:	0ff57513          	zext.b	a0,a0
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1788:	00900793          	li	a5,9
    178c:	f8a7fee3          	bgeu	a5,a0,1728 <_ntoa_long_long+0x88>
    1790:	020b7793          	andi	a5,s6,32
    1794:	00078e63          	beqz	a5,17b0 <_ntoa_long_long+0x110>
    1798:	04100793          	li	a5,65
    179c:	00a787b3          	add	a5,a5,a0
    17a0:	0ff7f793          	zext.b	a5,a5
    17a4:	ff678793          	addi	a5,a5,-10
    17a8:	0ff7f793          	zext.b	a5,a5
    17ac:	f85ff06f          	j	1730 <_ntoa_long_long+0x90>
    17b0:	06100793          	li	a5,97
    17b4:	fe9ff06f          	j	179c <_ntoa_long_long+0xfc>
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    17b8:	fb59f2e3          	bgeu	s3,s5,175c <_ntoa_long_long+0xbc>
    17bc:	0080006f          	j	17c4 <_ntoa_long_long+0x124>
  size_t len = 0U;
    17c0:	00000a13          	li	s4,0
  }

  return _ntoa_format(out, buffer, idx, maxlen, buf, len, negative, (unsigned int)base, prec, width, flags);
    17c4:	01612423          	sw	s6,8(sp)
    17c8:	08812783          	lw	a5,136(sp)
    17cc:	00f12223          	sw	a5,4(sp)
    17d0:	08412783          	lw	a5,132(sp)
    17d4:	00f12023          	sw	a5,0(sp)
    17d8:	000a8893          	mv	a7,s5
    17dc:	000d8813          	mv	a6,s11
    17e0:	000a0793          	mv	a5,s4
    17e4:	01010713          	addi	a4,sp,16
    17e8:	000d0693          	mv	a3,s10
    17ec:	000c8613          	mv	a2,s9
    17f0:	000c0593          	mv	a1,s8
    17f4:	000b8513          	mv	a0,s7
    17f8:	c25ff0ef          	jal	141c <_ntoa_format>
}
    17fc:	06c12083          	lw	ra,108(sp)
    1800:	06812403          	lw	s0,104(sp)
    1804:	06412483          	lw	s1,100(sp)
    1808:	06012903          	lw	s2,96(sp)
    180c:	05c12983          	lw	s3,92(sp)
    1810:	05812a03          	lw	s4,88(sp)
    1814:	05412a83          	lw	s5,84(sp)
    1818:	05012b03          	lw	s6,80(sp)
    181c:	04c12b83          	lw	s7,76(sp)
    1820:	04812c03          	lw	s8,72(sp)
    1824:	04412c83          	lw	s9,68(sp)
    1828:	04012d03          	lw	s10,64(sp)
    182c:	03c12d83          	lw	s11,60(sp)
    1830:	08010113          	addi	sp,sp,128
    1834:	00008067          	ret

00001838 <_etoa>:
*
* @note           Contributed by: Martijn Jasperse <m.jasperse@gmail.com>
*
******************************************************************************/
static size_t _etoa(out_fct_type out, char* buffer, size_t idx, size_t maxlen, double value, unsigned int prec, unsigned int width, unsigned int flags)
{
    1838:	f9010113          	addi	sp,sp,-112
    183c:	06112623          	sw	ra,108(sp)
    1840:	06812423          	sw	s0,104(sp)
    1844:	06912223          	sw	s1,100(sp)
    1848:	07212023          	sw	s2,96(sp)
    184c:	05312e23          	sw	s3,92(sp)
    1850:	05412c23          	sw	s4,88(sp)
    1854:	05512a23          	sw	s5,84(sp)
    1858:	05612823          	sw	s6,80(sp)
    185c:	05712623          	sw	s7,76(sp)
    1860:	05812423          	sw	s8,72(sp)
    1864:	00050913          	mv	s2,a0
    1868:	00058993          	mv	s3,a1
    186c:	00060b13          	mv	s6,a2
    1870:	00068a13          	mv	s4,a3
    1874:	00070493          	mv	s1,a4
    1878:	00078413          	mv	s0,a5
    187c:	00080b93          	mv	s7,a6
    1880:	00088a93          	mv	s5,a7
    1884:	07012c03          	lw	s8,112(sp)
  // check for NaN and special values
  if ((value != value) || (value > DBL_MAX) || (value < -DBL_MAX)) {
    1888:	00048613          	mv	a2,s1
    188c:	00040693          	mv	a3,s0
    1890:	00048513          	mv	a0,s1
    1894:	00040593          	mv	a1,s0
    1898:	250040ef          	jal	5ae8 <__eqdf2>
    189c:	30051263          	bnez	a0,1ba0 <_etoa+0x368>
    18a0:	8101a603          	lw	a2,-2032(gp) # 7738 <__clz_tab+0x104>
    18a4:	8141a683          	lw	a3,-2028(gp) # 773c <__clz_tab+0x108>
    18a8:	00048513          	mv	a0,s1
    18ac:	00040593          	mv	a1,s0
    18b0:	2c4040ef          	jal	5b74 <__gedf2>
    18b4:	2ea04663          	bgtz	a0,1ba0 <_etoa+0x368>
    18b8:	8181a603          	lw	a2,-2024(gp) # 7740 <__clz_tab+0x10c>
    18bc:	81c1a683          	lw	a3,-2020(gp) # 7744 <__clz_tab+0x110>
    18c0:	00048513          	mv	a0,s1
    18c4:	00040593          	mv	a1,s0
    18c8:	3ac040ef          	jal	5c74 <__ledf2>
    18cc:	2c054a63          	bltz	a0,1ba0 <_etoa+0x368>
    18d0:	05912223          	sw	s9,68(sp)
    18d4:	05a12023          	sw	s10,64(sp)
    18d8:	03b12e23          	sw	s11,60(sp)
    return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
  }

  // determine the sign
  const bool negative = value < 0;
  if (negative) {
    18dc:	00000613          	li	a2,0
    18e0:	00000693          	li	a3,0
    18e4:	00048513          	mv	a0,s1
    18e8:	00040593          	mv	a1,s0
    18ec:	388040ef          	jal	5c74 <__ledf2>
    18f0:	30054463          	bltz	a0,1bf8 <_etoa+0x3c0>
    18f4:	00912823          	sw	s1,16(sp)
    18f8:	00040c93          	mv	s9,s0
    value = -value;
  }

  // default precision
  if (!(flags & FLAGS_PRECISION)) {
    18fc:	400c7793          	andi	a5,s8,1024
    1900:	02f12623          	sw	a5,44(sp)
    1904:	00079463          	bnez	a5,190c <_etoa+0xd4>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1908:	00400b93          	li	s7,4
    uint64_t U;
    double   F;
  } conv;

  conv.F = value;
  int exp2 = (int)((conv.U >> 52U) & 0x07FFU) - 1023;           // effectively log2
    190c:	014cd513          	srli	a0,s9,0x14
    1910:	7ff57513          	andi	a0,a0,2047
  conv.U = (conv.U & ((1ULL << 52U) - 1U)) | (1023ULL << 52U);  // drop the exponent so conv.F is now in [1,2)
    1914:	001007b7          	lui	a5,0x100
    1918:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf717f>
    191c:	00fcf7b3          	and	a5,s9,a5
    1920:	3ff00d37          	lui	s10,0x3ff00
    1924:	00fd6d33          	or	s10,s10,a5
  // now approximate log10 from the log2 integer part and an expansion of ln around 1.5
  int expval = (int)(0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
    1928:	c0150513          	addi	a0,a0,-1023
    192c:	528050ef          	jal	6e54 <__floatsidf>
    1930:	8201a603          	lw	a2,-2016(gp) # 7748 <__clz_tab+0x114>
    1934:	8241a683          	lw	a3,-2012(gp) # 774c <__clz_tab+0x118>
    1938:	444040ef          	jal	5d7c <__muldf3>
    193c:	8281a603          	lw	a2,-2008(gp) # 7750 <__clz_tab+0x11c>
    1940:	82c1a683          	lw	a3,-2004(gp) # 7754 <__clz_tab+0x120>
    1944:	14c030ef          	jal	4a90 <__adddf3>
    1948:	00050d93          	mv	s11,a0
    194c:	00b12a23          	sw	a1,20(sp)
    1950:	8301a603          	lw	a2,-2000(gp) # 7758 <__clz_tab+0x124>
    1954:	8341a683          	lw	a3,-1996(gp) # 775c <__clz_tab+0x128>
    1958:	01012703          	lw	a4,16(sp)
    195c:	00070513          	mv	a0,a4
    1960:	000d0593          	mv	a1,s10
    1964:	2f1040ef          	jal	6454 <__subdf3>
    1968:	8381a603          	lw	a2,-1992(gp) # 7760 <__clz_tab+0x12c>
    196c:	83c1a683          	lw	a3,-1988(gp) # 7764 <__clz_tab+0x130>
    1970:	40c040ef          	jal	5d7c <__muldf3>
    1974:	00050613          	mv	a2,a0
    1978:	00058693          	mv	a3,a1
    197c:	000d8513          	mv	a0,s11
    1980:	01412583          	lw	a1,20(sp)
    1984:	10c030ef          	jal	4a90 <__adddf3>
    1988:	3d4050ef          	jal	6d5c <__fixdfsi>
    198c:	00050d13          	mv	s10,a0
  // now we want to compute 10^expval but we want to be sure it won't overflow
  exp2 = (int)(expval * 3.321928094887362 + 0.5);
    1990:	4c4050ef          	jal	6e54 <__floatsidf>
    1994:	00a12a23          	sw	a0,20(sp)
    1998:	00b12c23          	sw	a1,24(sp)
    199c:	8401a603          	lw	a2,-1984(gp) # 7768 <__clz_tab+0x134>
    19a0:	8441a683          	lw	a3,-1980(gp) # 776c <__clz_tab+0x138>
    19a4:	3d8040ef          	jal	5d7c <__muldf3>
    19a8:	8481a603          	lw	a2,-1976(gp) # 7770 <__clz_tab+0x13c>
    19ac:	84c1a683          	lw	a3,-1972(gp) # 7774 <__clz_tab+0x140>
    19b0:	0e0030ef          	jal	4a90 <__adddf3>
    19b4:	3a8050ef          	jal	6d5c <__fixdfsi>
    19b8:	00050d93          	mv	s11,a0
  const double z  = expval * 2.302585092994046 - exp2 * 0.6931471805599453;
    19bc:	8501a603          	lw	a2,-1968(gp) # 7778 <__clz_tab+0x144>
    19c0:	8541a683          	lw	a3,-1964(gp) # 777c <__clz_tab+0x148>
    19c4:	01412503          	lw	a0,20(sp)
    19c8:	01812583          	lw	a1,24(sp)
    19cc:	3b0040ef          	jal	5d7c <__muldf3>
    19d0:	00a12a23          	sw	a0,20(sp)
    19d4:	00b12c23          	sw	a1,24(sp)
    19d8:	000d8513          	mv	a0,s11
    19dc:	478050ef          	jal	6e54 <__floatsidf>
    19e0:	8581a603          	lw	a2,-1960(gp) # 7780 <__clz_tab+0x14c>
    19e4:	85c1a683          	lw	a3,-1956(gp) # 7784 <__clz_tab+0x150>
    19e8:	394040ef          	jal	5d7c <__muldf3>
    19ec:	00050613          	mv	a2,a0
    19f0:	00058693          	mv	a3,a1
    19f4:	01412503          	lw	a0,20(sp)
    19f8:	01812583          	lw	a1,24(sp)
    19fc:	259040ef          	jal	6454 <__subdf3>
  const double z2 = z * z;
    1a00:	00a12a23          	sw	a0,20(sp)
    1a04:	00050613          	mv	a2,a0
    1a08:	00b12c23          	sw	a1,24(sp)
    1a0c:	00058693          	mv	a3,a1
    1a10:	36c040ef          	jal	5d7c <__muldf3>
    1a14:	00a12e23          	sw	a0,28(sp)
    1a18:	02b12023          	sw	a1,32(sp)
  conv.U = (uint64_t)(exp2 + 1023) << 52U;
    1a1c:	3ffd8d93          	addi	s11,s11,1023
    1a20:	014d9d93          	slli	s11,s11,0x14
  // compute exp(z) using continued fractions, see https://en.wikipedia.org/wiki/Exponential_function#Continued_fractions_for_ex
  conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
    1a24:	01412803          	lw	a6,20(sp)
    1a28:	00080613          	mv	a2,a6
    1a2c:	01812783          	lw	a5,24(sp)
    1a30:	00078693          	mv	a3,a5
    1a34:	00080513          	mv	a0,a6
    1a38:	00078593          	mv	a1,a5
    1a3c:	054030ef          	jal	4a90 <__adddf3>
    1a40:	02a12223          	sw	a0,36(sp)
    1a44:	02b12423          	sw	a1,40(sp)
    1a48:	01412603          	lw	a2,20(sp)
    1a4c:	01812683          	lw	a3,24(sp)
    1a50:	8601a503          	lw	a0,-1952(gp) # 7788 <__clz_tab+0x154>
    1a54:	8641a583          	lw	a1,-1948(gp) # 778c <__clz_tab+0x158>
    1a58:	1fd040ef          	jal	6454 <__subdf3>
    1a5c:	00a12a23          	sw	a0,20(sp)
    1a60:	00b12c23          	sw	a1,24(sp)
    1a64:	8681a603          	lw	a2,-1944(gp) # 7790 <__clz_tab+0x15c>
    1a68:	86c1a683          	lw	a3,-1940(gp) # 7794 <__clz_tab+0x160>
    1a6c:	01c12503          	lw	a0,28(sp)
    1a70:	02012583          	lw	a1,32(sp)
    1a74:	0e5030ef          	jal	5358 <__divdf3>
    1a78:	8701a603          	lw	a2,-1936(gp) # 7798 <__clz_tab+0x164>
    1a7c:	8741a683          	lw	a3,-1932(gp) # 779c <__clz_tab+0x168>
    1a80:	010030ef          	jal	4a90 <__adddf3>
    1a84:	00050613          	mv	a2,a0
    1a88:	00058693          	mv	a3,a1
    1a8c:	01c12503          	lw	a0,28(sp)
    1a90:	02012583          	lw	a1,32(sp)
    1a94:	0c5030ef          	jal	5358 <__divdf3>
    1a98:	8781a603          	lw	a2,-1928(gp) # 77a0 <__clz_tab+0x16c>
    1a9c:	87c1a683          	lw	a3,-1924(gp) # 77a4 <__clz_tab+0x170>
    1aa0:	7f1020ef          	jal	4a90 <__adddf3>
    1aa4:	00050613          	mv	a2,a0
    1aa8:	00058693          	mv	a3,a1
    1aac:	01c12503          	lw	a0,28(sp)
    1ab0:	02012583          	lw	a1,32(sp)
    1ab4:	0a5030ef          	jal	5358 <__divdf3>
    1ab8:	00050613          	mv	a2,a0
    1abc:	00058693          	mv	a3,a1
    1ac0:	01412503          	lw	a0,20(sp)
    1ac4:	01812583          	lw	a1,24(sp)
    1ac8:	7c9020ef          	jal	4a90 <__adddf3>
    1acc:	00050613          	mv	a2,a0
    1ad0:	00058693          	mv	a3,a1
    1ad4:	02412503          	lw	a0,36(sp)
    1ad8:	02812583          	lw	a1,40(sp)
    1adc:	07d030ef          	jal	5358 <__divdf3>
    1ae0:	8801a603          	lw	a2,-1920(gp) # 77a8 <__clz_tab+0x174>
    1ae4:	8841a683          	lw	a3,-1916(gp) # 77ac <__clz_tab+0x178>
    1ae8:	7a9020ef          	jal	4a90 <__adddf3>
    1aec:	00000713          	li	a4,0
    1af0:	00070613          	mv	a2,a4
    1af4:	000d8693          	mv	a3,s11
    1af8:	284040ef          	jal	5d7c <__muldf3>
    1afc:	00050d93          	mv	s11,a0
    1b00:	00a12c23          	sw	a0,24(sp)
    1b04:	00b12a23          	sw	a1,20(sp)
    1b08:	00b12e23          	sw	a1,28(sp)
  // correct for rounding errors
  if (value < conv.F) {
    1b0c:	01012703          	lw	a4,16(sp)
    1b10:	00070613          	mv	a2,a4
    1b14:	000c8693          	mv	a3,s9
    1b18:	05c040ef          	jal	5b74 <__gedf2>
    1b1c:	02a05263          	blez	a0,1b40 <_etoa+0x308>
    expval--;
    1b20:	fffd0d13          	addi	s10,s10,-1 # 3fefffff <__freertos_irq_stack_top+0x3fef717f>
    conv.F /= 10;
    1b24:	8701a603          	lw	a2,-1936(gp) # 7798 <__clz_tab+0x164>
    1b28:	8741a683          	lw	a3,-1932(gp) # 779c <__clz_tab+0x168>
    1b2c:	000d8513          	mv	a0,s11
    1b30:	01412583          	lw	a1,20(sp)
    1b34:	025030ef          	jal	5358 <__divdf3>
    1b38:	00a12c23          	sw	a0,24(sp)
    1b3c:	00b12e23          	sw	a1,28(sp)
  }

  // the exponent format is "%+03d" and largest value is "307", so set aside 4-5 characters
  unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
    1b40:	063d0793          	addi	a5,s10,99
    1b44:	0c600713          	li	a4,198
    1b48:	0cf76063          	bltu	a4,a5,1c08 <_etoa+0x3d0>
    1b4c:	00400d93          	li	s11,4

  // in "%g" mode, "prec" is the number of *significant figures* not decimals
  if (flags & FLAGS_ADAPT_EXP) {
    1b50:	014c1793          	slli	a5,s8,0x14
    1b54:	0c07d663          	bgez	a5,1c20 <_etoa+0x3e8>
    // do we want to fall-back to "%f" mode?
    if ((value >= 1e-4) && (value < 1e6)) {
    1b58:	8881a603          	lw	a2,-1912(gp) # 77b0 <__clz_tab+0x17c>
    1b5c:	88c1a683          	lw	a3,-1908(gp) # 77b4 <__clz_tab+0x180>
    1b60:	01012703          	lw	a4,16(sp)
    1b64:	00070513          	mv	a0,a4
    1b68:	000c8593          	mv	a1,s9
    1b6c:	008040ef          	jal	5b74 <__gedf2>
    1b70:	0c054063          	bltz	a0,1c30 <_etoa+0x3f8>
    1b74:	8901a603          	lw	a2,-1904(gp) # 77b8 <__clz_tab+0x184>
    1b78:	8941a683          	lw	a3,-1900(gp) # 77bc <__clz_tab+0x188>
    1b7c:	01012703          	lw	a4,16(sp)
    1b80:	00070513          	mv	a0,a4
    1b84:	000c8593          	mv	a1,s9
    1b88:	0ec040ef          	jal	5c74 <__ledf2>
    1b8c:	0a055263          	bgez	a0,1c30 <_etoa+0x3f8>
      if ((int)prec > expval) {
    1b90:	097d5063          	bge	s10,s7,1c10 <_etoa+0x3d8>
        prec = (unsigned)((int)prec - expval - 1);
    1b94:	41ab8d33          	sub	s10,s7,s10
    1b98:	fffd0b93          	addi	s7,s10,-1
    1b9c:	0780006f          	j	1c14 <_etoa+0x3dc>
    return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
    1ba0:	01812023          	sw	s8,0(sp)
    1ba4:	000a8893          	mv	a7,s5
    1ba8:	000b8813          	mv	a6,s7
    1bac:	00048713          	mv	a4,s1
    1bb0:	00040793          	mv	a5,s0
    1bb4:	000a0693          	mv	a3,s4
    1bb8:	000b0613          	mv	a2,s6
    1bbc:	00098593          	mv	a1,s3
    1bc0:	00090513          	mv	a0,s2
    1bc4:	1e8000ef          	jal	1dac <_ftoa>
    if (flags & FLAGS_LEFT) {
      while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
    }
  }
  return idx;
}
    1bc8:	06c12083          	lw	ra,108(sp)
    1bcc:	06812403          	lw	s0,104(sp)
    1bd0:	06412483          	lw	s1,100(sp)
    1bd4:	06012903          	lw	s2,96(sp)
    1bd8:	05c12983          	lw	s3,92(sp)
    1bdc:	05812a03          	lw	s4,88(sp)
    1be0:	05412a83          	lw	s5,84(sp)
    1be4:	05012b03          	lw	s6,80(sp)
    1be8:	04c12b83          	lw	s7,76(sp)
    1bec:	04812c03          	lw	s8,72(sp)
    1bf0:	07010113          	addi	sp,sp,112
    1bf4:	00008067          	ret
    value = -value;
    1bf8:	00912823          	sw	s1,16(sp)
    1bfc:	80000cb7          	lui	s9,0x80000
    1c00:	008cccb3          	xor	s9,s9,s0
    1c04:	cf9ff06f          	j	18fc <_etoa+0xc4>
  unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
    1c08:	00500d93          	li	s11,5
    1c0c:	f45ff06f          	j	1b50 <_etoa+0x318>
        prec = 0;
    1c10:	00000b93          	li	s7,0
      flags |= FLAGS_PRECISION;   // make sure _ftoa respects precision
    1c14:	400c6c13          	ori	s8,s8,1024
      minwidth = 0U;
    1c18:	00000d93          	li	s11,0
      expval   = 0;
    1c1c:	00000d13          	li	s10,0
  if (width > minwidth) {
    1c20:	035df263          	bgeu	s11,s5,1c44 <_etoa+0x40c>
    fwidth -= minwidth;
    1c24:	41ba87b3          	sub	a5,s5,s11
    1c28:	00f12a23          	sw	a5,20(sp)
    1c2c:	01c0006f          	j	1c48 <_etoa+0x410>
      if ((prec > 0) && (flags & FLAGS_PRECISION)) {
    1c30:	fe0b88e3          	beqz	s7,1c20 <_etoa+0x3e8>
    1c34:	02c12783          	lw	a5,44(sp)
    1c38:	fe0784e3          	beqz	a5,1c20 <_etoa+0x3e8>
        --prec;
    1c3c:	fffb8b93          	addi	s7,s7,-1
    1c40:	fe1ff06f          	j	1c20 <_etoa+0x3e8>
    fwidth = 0U;
    1c44:	00012a23          	sw	zero,20(sp)
  if ((flags & FLAGS_LEFT) && minwidth) {
    1c48:	002c7793          	andi	a5,s8,2
    1c4c:	02f12023          	sw	a5,32(sp)
    1c50:	00078663          	beqz	a5,1c5c <_etoa+0x424>
    1c54:	000d8463          	beqz	s11,1c5c <_etoa+0x424>
    fwidth = 0U;
    1c58:	00012a23          	sw	zero,20(sp)
  if (expval) {
    1c5c:	020d0663          	beqz	s10,1c88 <_etoa+0x450>
    value /= conv.F;
    1c60:	01812703          	lw	a4,24(sp)
    1c64:	01c12783          	lw	a5,28(sp)
    1c68:	00070613          	mv	a2,a4
    1c6c:	00078693          	mv	a3,a5
    1c70:	01012703          	lw	a4,16(sp)
    1c74:	00070513          	mv	a0,a4
    1c78:	000c8593          	mv	a1,s9
    1c7c:	6dc030ef          	jal	5358 <__divdf3>
    1c80:	00a12823          	sw	a0,16(sp)
    1c84:	00058c93          	mv	s9,a1
  idx = _ftoa(out, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);
    1c88:	00000613          	li	a2,0
    1c8c:	00000693          	li	a3,0
    1c90:	00048513          	mv	a0,s1
    1c94:	00040593          	mv	a1,s0
    1c98:	7dd030ef          	jal	5c74 <__ledf2>
    1c9c:	0a054c63          	bltz	a0,1d54 <_etoa+0x51c>
    1ca0:	fffff7b7          	lui	a5,0xfffff
    1ca4:	7ff78793          	addi	a5,a5,2047 # fffff7ff <__freertos_irq_stack_top+0xffff697f>
    1ca8:	00fc77b3          	and	a5,s8,a5
    1cac:	00f12023          	sw	a5,0(sp)
    1cb0:	01412883          	lw	a7,20(sp)
    1cb4:	000b8813          	mv	a6,s7
    1cb8:	01012603          	lw	a2,16(sp)
    1cbc:	00060713          	mv	a4,a2
    1cc0:	000c8793          	mv	a5,s9
    1cc4:	000a0693          	mv	a3,s4
    1cc8:	000b0613          	mv	a2,s6
    1ccc:	00098593          	mv	a1,s3
    1cd0:	00090513          	mv	a0,s2
    1cd4:	0d8000ef          	jal	1dac <_ftoa>
  if (minwidth) {
    1cd8:	0c0d8263          	beqz	s11,1d9c <_etoa+0x564>
    out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
    1cdc:	020c7c13          	andi	s8,s8,32
    1ce0:	080c0063          	beqz	s8,1d60 <_etoa+0x528>
    1ce4:	04500793          	li	a5,69
    1ce8:	00150413          	addi	s0,a0,1
    1cec:	000a0693          	mv	a3,s4
    1cf0:	00050613          	mv	a2,a0
    1cf4:	00098593          	mv	a1,s3
    1cf8:	00078513          	mv	a0,a5
    1cfc:	000900e7          	jalr	s2
    idx = _ntoa_long(out, buffer, idx, maxlen, (expval < 0) ? -expval : expval, expval < 0, 10, 0, minwidth-1, FLAGS_ZEROPAD | FLAGS_PLUS);
    1d00:	41fd5713          	srai	a4,s10,0x1f
    1d04:	01a746b3          	xor	a3,a4,s10
    1d08:	00500793          	li	a5,5
    1d0c:	00f12223          	sw	a5,4(sp)
    1d10:	fffd8d93          	addi	s11,s11,-1
    1d14:	01b12023          	sw	s11,0(sp)
    1d18:	00000893          	li	a7,0
    1d1c:	00a00813          	li	a6,10
    1d20:	01fd5793          	srli	a5,s10,0x1f
    1d24:	40e68733          	sub	a4,a3,a4
    1d28:	000a0693          	mv	a3,s4
    1d2c:	00040613          	mv	a2,s0
    1d30:	00098593          	mv	a1,s3
    1d34:	00090513          	mv	a0,s2
    1d38:	8a5ff0ef          	jal	15dc <_ntoa_long>
    if (flags & FLAGS_LEFT) {
    1d3c:	02012783          	lw	a5,32(sp)
    1d40:	04079263          	bnez	a5,1d84 <_etoa+0x54c>
    1d44:	04412c83          	lw	s9,68(sp)
    1d48:	04012d03          	lw	s10,64(sp)
    1d4c:	03c12d83          	lw	s11,60(sp)
    1d50:	e79ff06f          	j	1bc8 <_etoa+0x390>
  idx = _ftoa(out, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);
    1d54:	800007b7          	lui	a5,0x80000
    1d58:	0197ccb3          	xor	s9,a5,s9
    1d5c:	f45ff06f          	j	1ca0 <_etoa+0x468>
    out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
    1d60:	06500793          	li	a5,101
    1d64:	f85ff06f          	j	1ce8 <_etoa+0x4b0>
      while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
    1d68:	00150413          	addi	s0,a0,1
    1d6c:	000a0693          	mv	a3,s4
    1d70:	00050613          	mv	a2,a0
    1d74:	00098593          	mv	a1,s3
    1d78:	02000513          	li	a0,32
    1d7c:	000900e7          	jalr	s2
    1d80:	00040513          	mv	a0,s0
    1d84:	416507b3          	sub	a5,a0,s6
    1d88:	ff57e0e3          	bltu	a5,s5,1d68 <_etoa+0x530>
    1d8c:	04412c83          	lw	s9,68(sp)
    1d90:	04012d03          	lw	s10,64(sp)
    1d94:	03c12d83          	lw	s11,60(sp)
    1d98:	e31ff06f          	j	1bc8 <_etoa+0x390>
    1d9c:	04412c83          	lw	s9,68(sp)
    1da0:	04012d03          	lw	s10,64(sp)
    1da4:	03c12d83          	lw	s11,60(sp)
    1da8:	e21ff06f          	j	1bc8 <_etoa+0x390>

00001dac <_ftoa>:
{
    1dac:	f7010113          	addi	sp,sp,-144
    1db0:	08112623          	sw	ra,140(sp)
    1db4:	08912223          	sw	s1,132(sp)
    1db8:	07312e23          	sw	s3,124(sp)
    1dbc:	07412c23          	sw	s4,120(sp)
    1dc0:	07612823          	sw	s6,112(sp)
    1dc4:	07712623          	sw	s7,108(sp)
    1dc8:	07812423          	sw	s8,104(sp)
    1dcc:	07912223          	sw	s9,100(sp)
    1dd0:	07a12023          	sw	s10,96(sp)
    1dd4:	05b12e23          	sw	s11,92(sp)
    1dd8:	00050b93          	mv	s7,a0
    1ddc:	00058c13          	mv	s8,a1
    1de0:	00060c93          	mv	s9,a2
    1de4:	00068d13          	mv	s10,a3
    1de8:	00070a13          	mv	s4,a4
    1dec:	00078993          	mv	s3,a5
    1df0:	00080493          	mv	s1,a6
    1df4:	00088b13          	mv	s6,a7
    1df8:	09012d83          	lw	s11,144(sp)
  if (value != value)
    1dfc:	00070613          	mv	a2,a4
    1e00:	00078693          	mv	a3,a5
    1e04:	00070513          	mv	a0,a4
    1e08:	00078593          	mv	a1,a5
    1e0c:	4dd030ef          	jal	5ae8 <__eqdf2>
    1e10:	0c051463          	bnez	a0,1ed8 <_ftoa+0x12c>
  if (value < -DBL_MAX)
    1e14:	8181a603          	lw	a2,-2024(gp) # 7740 <__clz_tab+0x10c>
    1e18:	81c1a683          	lw	a3,-2020(gp) # 7744 <__clz_tab+0x110>
    1e1c:	000a0513          	mv	a0,s4
    1e20:	00098593          	mv	a1,s3
    1e24:	651030ef          	jal	5c74 <__ledf2>
    1e28:	0c054e63          	bltz	a0,1f04 <_ftoa+0x158>
  if (value > DBL_MAX)
    1e2c:	8101a603          	lw	a2,-2032(gp) # 7738 <__clz_tab+0x104>
    1e30:	8141a683          	lw	a3,-2028(gp) # 773c <__clz_tab+0x108>
    1e34:	000a0513          	mv	a0,s4
    1e38:	00098593          	mv	a1,s3
    1e3c:	539030ef          	jal	5b74 <__gedf2>
    1e40:	0ea04863          	bgtz	a0,1f30 <_ftoa+0x184>
  if ((value > PRINTF_MAX_FLOAT) || (value < -PRINTF_MAX_FLOAT)) {
    1e44:	8981a603          	lw	a2,-1896(gp) # 77c0 <__clz_tab+0x18c>
    1e48:	89c1a683          	lw	a3,-1892(gp) # 77c4 <__clz_tab+0x190>
    1e4c:	000a0513          	mv	a0,s4
    1e50:	00098593          	mv	a1,s3
    1e54:	521030ef          	jal	5b74 <__gedf2>
    1e58:	12a04263          	bgtz	a0,1f7c <_ftoa+0x1d0>
    1e5c:	8a01a603          	lw	a2,-1888(gp) # 77c8 <__clz_tab+0x194>
    1e60:	8a41a683          	lw	a3,-1884(gp) # 77cc <__clz_tab+0x198>
    1e64:	000a0513          	mv	a0,s4
    1e68:	00098593          	mv	a1,s3
    1e6c:	609030ef          	jal	5c74 <__ledf2>
    1e70:	10054663          	bltz	a0,1f7c <_ftoa+0x1d0>
    1e74:	08812423          	sw	s0,136(sp)
    1e78:	09212023          	sw	s2,128(sp)
    1e7c:	07512a23          	sw	s5,116(sp)
  if (value < 0) {
    1e80:	00000613          	li	a2,0
    1e84:	00000693          	li	a3,0
    1e88:	000a0513          	mv	a0,s4
    1e8c:	00098593          	mv	a1,s3
    1e90:	5e5030ef          	jal	5c74 <__ledf2>
    1e94:	10054a63          	bltz	a0,1fa8 <_ftoa+0x1fc>
  bool negative = false;
    1e98:	02012223          	sw	zero,36(sp)
  if (!(flags & FLAGS_PRECISION)) {
    1e9c:	400df793          	andi	a5,s11,1024
    1ea0:	12078863          	beqz	a5,1fd0 <_ftoa+0x224>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1ea4:	00000413          	li	s0,0
  while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
    1ea8:	01f00793          	li	a5,31
    1eac:	1287e663          	bltu	a5,s0,1fd8 <_ftoa+0x22c>
    1eb0:	00900793          	li	a5,9
    1eb4:	1297f263          	bgeu	a5,s1,1fd8 <_ftoa+0x22c>
    buf[len++] = '0';
    1eb8:	03040793          	addi	a5,s0,48
    1ebc:	02010713          	addi	a4,sp,32
    1ec0:	00e787b3          	add	a5,a5,a4
    1ec4:	03000713          	li	a4,48
    1ec8:	fee78023          	sb	a4,-32(a5) # 7fffffe0 <__freertos_irq_stack_top+0x7fff7160>
    prec--;
    1ecc:	fff48493          	addi	s1,s1,-1
    buf[len++] = '0';
    1ed0:	00140413          	addi	s0,s0,1
    1ed4:	fd5ff06f          	j	1ea8 <_ftoa+0xfc>
    return _out_rev(out, buffer, idx, maxlen, "nan", 3, width, flags);
    1ed8:	000d8893          	mv	a7,s11
    1edc:	000b0813          	mv	a6,s6
    1ee0:	00300793          	li	a5,3
    1ee4:	00007737          	lui	a4,0x7
    1ee8:	06470713          	addi	a4,a4,100 # 7064 <_data+0xc>
    1eec:	000d0693          	mv	a3,s10
    1ef0:	000c8613          	mv	a2,s9
    1ef4:	000c0593          	mv	a1,s8
    1ef8:	000b8513          	mv	a0,s7
    1efc:	c14ff0ef          	jal	1310 <_out_rev>
    1f00:	33c0006f          	j	223c <_ftoa+0x490>
    return _out_rev(out, buffer, idx, maxlen, "fni-", 4, width, flags);
    1f04:	000d8893          	mv	a7,s11
    1f08:	000b0813          	mv	a6,s6
    1f0c:	00400793          	li	a5,4
    1f10:	00007737          	lui	a4,0x7
    1f14:	06870713          	addi	a4,a4,104 # 7068 <_data+0x10>
    1f18:	000d0693          	mv	a3,s10
    1f1c:	000c8613          	mv	a2,s9
    1f20:	000c0593          	mv	a1,s8
    1f24:	000b8513          	mv	a0,s7
    1f28:	be8ff0ef          	jal	1310 <_out_rev>
    1f2c:	3100006f          	j	223c <_ftoa+0x490>
    return _out_rev(out, buffer, idx, maxlen, (flags & FLAGS_PLUS) ? "fni+" : "fni", (flags & FLAGS_PLUS) ? 4U : 3U, width, flags);
    1f30:	004df793          	andi	a5,s11,4
    1f34:	02078a63          	beqz	a5,1f68 <_ftoa+0x1bc>
    1f38:	00007737          	lui	a4,0x7
    1f3c:	05870713          	addi	a4,a4,88 # 7058 <_data>
    1f40:	02078a63          	beqz	a5,1f74 <_ftoa+0x1c8>
    1f44:	00400793          	li	a5,4
    1f48:	000d8893          	mv	a7,s11
    1f4c:	000b0813          	mv	a6,s6
    1f50:	000d0693          	mv	a3,s10
    1f54:	000c8613          	mv	a2,s9
    1f58:	000c0593          	mv	a1,s8
    1f5c:	000b8513          	mv	a0,s7
    1f60:	bb0ff0ef          	jal	1310 <_out_rev>
    1f64:	2d80006f          	j	223c <_ftoa+0x490>
    1f68:	00007737          	lui	a4,0x7
    1f6c:	06070713          	addi	a4,a4,96 # 7060 <_data+0x8>
    1f70:	fd1ff06f          	j	1f40 <_ftoa+0x194>
    1f74:	00300793          	li	a5,3
    1f78:	fd1ff06f          	j	1f48 <_ftoa+0x19c>
    return _etoa(out, buffer, idx, maxlen, value, prec, width, flags);
    1f7c:	01b12023          	sw	s11,0(sp)
    1f80:	000b0893          	mv	a7,s6
    1f84:	00048813          	mv	a6,s1
    1f88:	000a0713          	mv	a4,s4
    1f8c:	00098793          	mv	a5,s3
    1f90:	000d0693          	mv	a3,s10
    1f94:	000c8613          	mv	a2,s9
    1f98:	000c0593          	mv	a1,s8
    1f9c:	000b8513          	mv	a0,s7
    1fa0:	899ff0ef          	jal	1838 <_etoa>
    1fa4:	2980006f          	j	223c <_ftoa+0x490>
    value = 0 - value;
    1fa8:	000a0613          	mv	a2,s4
    1fac:	00098693          	mv	a3,s3
    1fb0:	00000513          	li	a0,0
    1fb4:	00000593          	li	a1,0
    1fb8:	49c040ef          	jal	6454 <__subdf3>
    1fbc:	00050a13          	mv	s4,a0
    1fc0:	00058993          	mv	s3,a1
    negative = true;
    1fc4:	00100793          	li	a5,1
    1fc8:	02f12223          	sw	a5,36(sp)
    1fcc:	ed1ff06f          	j	1e9c <_ftoa+0xf0>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1fd0:	00400493          	li	s1,4
    1fd4:	ed1ff06f          	j	1ea4 <_ftoa+0xf8>
  int whole = (int)value;
    1fd8:	000a0513          	mv	a0,s4
    1fdc:	00098593          	mv	a1,s3
    1fe0:	57d040ef          	jal	6d5c <__fixdfsi>
    1fe4:	00050913          	mv	s2,a0
  double tmp = (value - whole) * pow10[prec];
    1fe8:	66d040ef          	jal	6e54 <__floatsidf>
    1fec:	00050613          	mv	a2,a0
    1ff0:	00058693          	mv	a3,a1
    1ff4:	000a0513          	mv	a0,s4
    1ff8:	00098593          	mv	a1,s3
    1ffc:	458040ef          	jal	6454 <__subdf3>
    2000:	000077b7          	lui	a5,0x7
    2004:	00349713          	slli	a4,s1,0x3
    2008:	52078793          	addi	a5,a5,1312 # 7520 <pow10.0>
    200c:	00e787b3          	add	a5,a5,a4
    2010:	0047a803          	lw	a6,4(a5)
    2014:	0007a783          	lw	a5,0(a5)
    2018:	02f12423          	sw	a5,40(sp)
    201c:	03012623          	sw	a6,44(sp)
    2020:	00078613          	mv	a2,a5
    2024:	00080693          	mv	a3,a6
    2028:	555030ef          	jal	5d7c <__muldf3>
    202c:	00a12e23          	sw	a0,28(sp)
    2030:	02b12023          	sw	a1,32(sp)
  unsigned long frac = (unsigned long)tmp;
    2034:	5ad040ef          	jal	6de0 <__fixunsdfsi>
    2038:	00050a93          	mv	s5,a0
  diff = tmp - frac;
    203c:	6d1040ef          	jal	6f0c <__floatunsidf>
    2040:	00050613          	mv	a2,a0
    2044:	00058693          	mv	a3,a1
    2048:	01c12503          	lw	a0,28(sp)
    204c:	02012583          	lw	a1,32(sp)
    2050:	404040ef          	jal	6454 <__subdf3>
    2054:	00a12e23          	sw	a0,28(sp)
    2058:	02b12023          	sw	a1,32(sp)
  if (diff > 0.5) {
    205c:	8481a603          	lw	a2,-1976(gp) # 7770 <__clz_tab+0x13c>
    2060:	84c1a683          	lw	a3,-1972(gp) # 7774 <__clz_tab+0x140>
    2064:	311030ef          	jal	5b74 <__gedf2>
    2068:	06a05863          	blez	a0,20d8 <_ftoa+0x32c>
    ++frac;
    206c:	001a8a93          	addi	s5,s5,1
    if (frac >= pow10[prec]) {
    2070:	000a8513          	mv	a0,s5
    2074:	699040ef          	jal	6f0c <__floatunsidf>
    2078:	00050613          	mv	a2,a0
    207c:	00058693          	mv	a3,a1
    2080:	02812503          	lw	a0,40(sp)
    2084:	02c12583          	lw	a1,44(sp)
    2088:	3ed030ef          	jal	5c74 <__ledf2>
    208c:	00a04663          	bgtz	a0,2098 <_ftoa+0x2ec>
      ++whole;
    2090:	00190913          	addi	s2,s2,1
      frac = 0;
    2094:	00000a93          	li	s5,0
  if (prec == 0U) {
    2098:	06049663          	bnez	s1,2104 <_ftoa+0x358>
    diff = value - (double)whole;
    209c:	00090513          	mv	a0,s2
    20a0:	5b5040ef          	jal	6e54 <__floatsidf>
    20a4:	00050613          	mv	a2,a0
    20a8:	00058693          	mv	a3,a1
    20ac:	000a0513          	mv	a0,s4
    20b0:	00098593          	mv	a1,s3
    20b4:	3a0040ef          	jal	6454 <__subdf3>
    if ((!(diff < 0.5) || (diff > 0.5)) && (whole & 1)) {
    20b8:	8481a603          	lw	a2,-1976(gp) # 7770 <__clz_tab+0x13c>
    20bc:	84c1a683          	lw	a3,-1972(gp) # 7774 <__clz_tab+0x140>
    20c0:	3b5030ef          	jal	5c74 <__ledf2>
    20c4:	0c054c63          	bltz	a0,219c <_ftoa+0x3f0>
    20c8:	00197793          	andi	a5,s2,1
    20cc:	0c078863          	beqz	a5,219c <_ftoa+0x3f0>
      ++whole;
    20d0:	00190913          	addi	s2,s2,1
    20d4:	0c80006f          	j	219c <_ftoa+0x3f0>
  else if (diff < 0.5) {
    20d8:	8481a603          	lw	a2,-1976(gp) # 7770 <__clz_tab+0x13c>
    20dc:	84c1a683          	lw	a3,-1972(gp) # 7774 <__clz_tab+0x140>
    20e0:	01c12503          	lw	a0,28(sp)
    20e4:	02012583          	lw	a1,32(sp)
    20e8:	38d030ef          	jal	5c74 <__ledf2>
    20ec:	fa0546e3          	bltz	a0,2098 <_ftoa+0x2ec>
  else if ((frac == 0U) || (frac & 1U)) {
    20f0:	000a8663          	beqz	s5,20fc <_ftoa+0x350>
    20f4:	001af793          	andi	a5,s5,1
    20f8:	fa0780e3          	beqz	a5,2098 <_ftoa+0x2ec>
    ++frac;
    20fc:	001a8a93          	addi	s5,s5,1
    2100:	f99ff06f          	j	2098 <_ftoa+0x2ec>
    while (len < PRINTF_FTOA_BUFFER_SIZE) {
    2104:	01f00793          	li	a5,31
    2108:	0487e263          	bltu	a5,s0,214c <_ftoa+0x3a0>
      --count;
    210c:	fff48493          	addi	s1,s1,-1
      buf[len++] = (char)(48U + (frac % 10U));
    2110:	00a00793          	li	a5,10
    2114:	02faf733          	remu	a4,s5,a5
    2118:	00140693          	addi	a3,s0,1
    211c:	03070713          	addi	a4,a4,48
    2120:	03040613          	addi	a2,s0,48
    2124:	02010593          	addi	a1,sp,32
    2128:	00b60433          	add	s0,a2,a1
    212c:	fee40023          	sb	a4,-32(s0)
      if (!(frac /= 10U)) {
    2130:	02fad7b3          	divu	a5,s5,a5
    2134:	00900713          	li	a4,9
    2138:	01577863          	bgeu	a4,s5,2148 <_ftoa+0x39c>
    213c:	00078a93          	mv	s5,a5
      buf[len++] = (char)(48U + (frac % 10U));
    2140:	00068413          	mv	s0,a3
    2144:	fc1ff06f          	j	2104 <_ftoa+0x358>
    2148:	00068413          	mv	s0,a3
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
    214c:	01f00793          	li	a5,31
    2150:	0287e663          	bltu	a5,s0,217c <_ftoa+0x3d0>
    2154:	fff48793          	addi	a5,s1,-1
    2158:	02048263          	beqz	s1,217c <_ftoa+0x3d0>
      buf[len++] = '0';
    215c:	03040713          	addi	a4,s0,48
    2160:	02010693          	addi	a3,sp,32
    2164:	00d70733          	add	a4,a4,a3
    2168:	03000693          	li	a3,48
    216c:	fed70023          	sb	a3,-32(a4)
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
    2170:	00078493          	mv	s1,a5
      buf[len++] = '0';
    2174:	00140413          	addi	s0,s0,1
    2178:	fd5ff06f          	j	214c <_ftoa+0x3a0>
    if (len < PRINTF_FTOA_BUFFER_SIZE) {
    217c:	01f00793          	li	a5,31
    2180:	0087ee63          	bltu	a5,s0,219c <_ftoa+0x3f0>
      buf[len++] = '.';
    2184:	03040793          	addi	a5,s0,48
    2188:	02010713          	addi	a4,sp,32
    218c:	00e787b3          	add	a5,a5,a4
    2190:	02e00713          	li	a4,46
    2194:	fee78023          	sb	a4,-32(a5)
    2198:	00140413          	addi	s0,s0,1
  while (len < PRINTF_FTOA_BUFFER_SIZE) {
    219c:	01f00793          	li	a5,31
    21a0:	0287ec63          	bltu	a5,s0,21d8 <_ftoa+0x42c>
    buf[len++] = (char)(48 + (whole % 10));
    21a4:	00a00713          	li	a4,10
    21a8:	02e967b3          	rem	a5,s2,a4
    21ac:	00140693          	addi	a3,s0,1
    21b0:	03078793          	addi	a5,a5,48
    21b4:	03040613          	addi	a2,s0,48
    21b8:	02010593          	addi	a1,sp,32
    21bc:	00b60433          	add	s0,a2,a1
    21c0:	fef40023          	sb	a5,-32(s0)
    if (!(whole /= 10)) {
    21c4:	02e94933          	div	s2,s2,a4
    21c8:	00090663          	beqz	s2,21d4 <_ftoa+0x428>
    buf[len++] = (char)(48 + (whole % 10));
    21cc:	00068413          	mv	s0,a3
    21d0:	fcdff06f          	j	219c <_ftoa+0x3f0>
    21d4:	00068413          	mv	s0,a3
  if (!(flags & FLAGS_LEFT) && (flags & FLAGS_ZEROPAD)) {
    21d8:	003df713          	andi	a4,s11,3
    21dc:	00100793          	li	a5,1
    21e0:	08f70663          	beq	a4,a5,226c <_ftoa+0x4c0>
  if (len < PRINTF_FTOA_BUFFER_SIZE) {
    21e4:	01f00793          	li	a5,31
    21e8:	0287e263          	bltu	a5,s0,220c <_ftoa+0x460>
    if (negative) {
    21ec:	02412783          	lw	a5,36(sp)
    21f0:	0c078063          	beqz	a5,22b0 <_ftoa+0x504>
      buf[len++] = '-';
    21f4:	03040793          	addi	a5,s0,48
    21f8:	02010713          	addi	a4,sp,32
    21fc:	00e787b3          	add	a5,a5,a4
    2200:	02d00713          	li	a4,45
    2204:	fee78023          	sb	a4,-32(a5)
    2208:	00140413          	addi	s0,s0,1
  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
    220c:	000d8893          	mv	a7,s11
    2210:	000b0813          	mv	a6,s6
    2214:	00040793          	mv	a5,s0
    2218:	03010713          	addi	a4,sp,48
    221c:	000d0693          	mv	a3,s10
    2220:	000c8613          	mv	a2,s9
    2224:	000c0593          	mv	a1,s8
    2228:	000b8513          	mv	a0,s7
    222c:	8e4ff0ef          	jal	1310 <_out_rev>
    2230:	08812403          	lw	s0,136(sp)
    2234:	08012903          	lw	s2,128(sp)
    2238:	07412a83          	lw	s5,116(sp)
}
    223c:	08c12083          	lw	ra,140(sp)
    2240:	08412483          	lw	s1,132(sp)
    2244:	07c12983          	lw	s3,124(sp)
    2248:	07812a03          	lw	s4,120(sp)
    224c:	07012b03          	lw	s6,112(sp)
    2250:	06c12b83          	lw	s7,108(sp)
    2254:	06812c03          	lw	s8,104(sp)
    2258:	06412c83          	lw	s9,100(sp)
    225c:	06012d03          	lw	s10,96(sp)
    2260:	05c12d83          	lw	s11,92(sp)
    2264:	09010113          	addi	sp,sp,144
    2268:	00008067          	ret
    if (width && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
    226c:	020b0a63          	beqz	s6,22a0 <_ftoa+0x4f4>
    2270:	02412783          	lw	a5,36(sp)
    2274:	00079663          	bnez	a5,2280 <_ftoa+0x4d4>
    2278:	00cdf793          	andi	a5,s11,12
    227c:	02078263          	beqz	a5,22a0 <_ftoa+0x4f4>
      width--;
    2280:	fffb0b13          	addi	s6,s6,-1
    2284:	01c0006f          	j	22a0 <_ftoa+0x4f4>
      buf[len++] = '0';
    2288:	03040793          	addi	a5,s0,48
    228c:	02010713          	addi	a4,sp,32
    2290:	00e787b3          	add	a5,a5,a4
    2294:	03000713          	li	a4,48
    2298:	fee78023          	sb	a4,-32(a5)
    229c:	00140413          	addi	s0,s0,1
    while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
    22a0:	f56472e3          	bgeu	s0,s6,21e4 <_ftoa+0x438>
    22a4:	01f00793          	li	a5,31
    22a8:	fe87f0e3          	bgeu	a5,s0,2288 <_ftoa+0x4dc>
    22ac:	f39ff06f          	j	21e4 <_ftoa+0x438>
    else if (flags & FLAGS_PLUS) {
    22b0:	004df793          	andi	a5,s11,4
    22b4:	02078063          	beqz	a5,22d4 <_ftoa+0x528>
      buf[len++] = '+';  // ignore the space if the '+' exists
    22b8:	03040793          	addi	a5,s0,48
    22bc:	02010713          	addi	a4,sp,32
    22c0:	00e787b3          	add	a5,a5,a4
    22c4:	02b00713          	li	a4,43
    22c8:	fee78023          	sb	a4,-32(a5)
    22cc:	00140413          	addi	s0,s0,1
    22d0:	f3dff06f          	j	220c <_ftoa+0x460>
    else if (flags & FLAGS_SPACE) {
    22d4:	008df793          	andi	a5,s11,8
    22d8:	f2078ae3          	beqz	a5,220c <_ftoa+0x460>
      buf[len++] = ' ';
    22dc:	03040793          	addi	a5,s0,48
    22e0:	02010713          	addi	a4,sp,32
    22e4:	00e787b3          	add	a5,a5,a4
    22e8:	02000713          	li	a4,32
    22ec:	fee78023          	sb	a4,-32(a5)
    22f0:	00140413          	addi	s0,s0,1
    22f4:	f19ff06f          	j	220c <_ftoa+0x460>

000022f8 <_vsnprintf>:
*                 terminating null character), or a negative value if an error
*                 occurred.
*
******************************************************************************/
static int _vsnprintf(out_fct_type out, char* buffer, const size_t maxlen, const char* format, va_list va)
{
    22f8:	fa010113          	addi	sp,sp,-96
    22fc:	04112e23          	sw	ra,92(sp)
    2300:	04812c23          	sw	s0,88(sp)
    2304:	04912a23          	sw	s1,84(sp)
    2308:	05212823          	sw	s2,80(sp)
    230c:	05312623          	sw	s3,76(sp)
    2310:	05412423          	sw	s4,72(sp)
    2314:	05512223          	sw	s5,68(sp)
    2318:	05612023          	sw	s6,64(sp)
    231c:	00050a13          	mv	s4,a0
    2320:	00058993          	mv	s3,a1
    2324:	00060913          	mv	s2,a2
    2328:	00d12e23          	sw	a3,28(sp)
    232c:	00e12c23          	sw	a4,24(sp)
  unsigned int flags, width, precision, n;
  size_t idx = 0U;

  if (!buffer) {
    2330:	140588e3          	beqz	a1,2c80 <_vsnprintf+0x988>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
          }
        }
        format++;
        break;
    2334:	00000493          	li	s1,0
  while (*format)
    2338:	01c12783          	lw	a5,28(sp)
    233c:	0007c503          	lbu	a0,0(a5)
    2340:	140506e3          	beqz	a0,2c8c <_vsnprintf+0x994>
    if (*format != '%') {
    2344:	02500713          	li	a4,37
    2348:	02e50663          	beq	a0,a4,2374 <_vsnprintf+0x7c>
      out(*format, buffer, idx++, maxlen);
    234c:	00148413          	addi	s0,s1,1
    2350:	00090693          	mv	a3,s2
    2354:	00048613          	mv	a2,s1
    2358:	00098593          	mv	a1,s3
    235c:	000a00e7          	jalr	s4
      format++;
    2360:	01c12783          	lw	a5,28(sp)
    2364:	00178793          	addi	a5,a5,1
    2368:	00f12e23          	sw	a5,28(sp)
      out(*format, buffer, idx++, maxlen);
    236c:	00040493          	mv	s1,s0
      continue;
    2370:	fc9ff06f          	j	2338 <_vsnprintf+0x40>
      format++;
    2374:	00178793          	addi	a5,a5,1
    2378:	00f12e23          	sw	a5,28(sp)
    flags = 0U;
    237c:	00000413          	li	s0,0
    2380:	0700006f          	j	23f0 <_vsnprintf+0xf8>
        case '0': flags |= FLAGS_ZEROPAD; format++; n = 1U; break;
    2384:	00146413          	ori	s0,s0,1
    2388:	00170713          	addi	a4,a4,1
    238c:	00e12e23          	sw	a4,28(sp)
    2390:	00100a93          	li	s5,1
    2394:	0580006f          	j	23ec <_vsnprintf+0xf4>
        case '-': flags |= FLAGS_LEFT;    format++; n = 1U; break;
    2398:	00246413          	ori	s0,s0,2
    239c:	00170713          	addi	a4,a4,1
    23a0:	00e12e23          	sw	a4,28(sp)
    23a4:	00100a93          	li	s5,1
    23a8:	0440006f          	j	23ec <_vsnprintf+0xf4>
        case '+': flags |= FLAGS_PLUS;    format++; n = 1U; break;
    23ac:	00446413          	ori	s0,s0,4
    23b0:	00170713          	addi	a4,a4,1
    23b4:	00e12e23          	sw	a4,28(sp)
    23b8:	00100a93          	li	s5,1
    23bc:	0300006f          	j	23ec <_vsnprintf+0xf4>
        case ' ': flags |= FLAGS_SPACE;   format++; n = 1U; break;
    23c0:	00846413          	ori	s0,s0,8
    23c4:	00170713          	addi	a4,a4,1
    23c8:	00e12e23          	sw	a4,28(sp)
    23cc:	00100a93          	li	s5,1
    23d0:	01c0006f          	j	23ec <_vsnprintf+0xf4>
        case '#': flags |= FLAGS_HASH;    format++; n = 1U; break;
    23d4:	01046413          	ori	s0,s0,16
    23d8:	00170713          	addi	a4,a4,1
    23dc:	00e12e23          	sw	a4,28(sp)
    23e0:	00100a93          	li	s5,1
    23e4:	0080006f          	j	23ec <_vsnprintf+0xf4>
      switch (*format) {
    23e8:	00000a93          	li	s5,0
    } while (n);
    23ec:	020a8a63          	beqz	s5,2420 <_vsnprintf+0x128>
      switch (*format) {
    23f0:	01c12703          	lw	a4,28(sp)
    23f4:	00074783          	lbu	a5,0(a4)
    23f8:	fe078793          	addi	a5,a5,-32
    23fc:	0ff7f613          	zext.b	a2,a5
    2400:	01000693          	li	a3,16
    2404:	fec6e2e3          	bltu	a3,a2,23e8 <_vsnprintf+0xf0>
    2408:	00261793          	slli	a5,a2,0x2
    240c:	000076b7          	lui	a3,0x7
    2410:	2fc68693          	addi	a3,a3,764 # 72fc <_data+0x2a4>
    2414:	00d787b3          	add	a5,a5,a3
    2418:	0007a783          	lw	a5,0(a5)
    241c:	00078067          	jr	a5
    if (_is_digit(*format)) {
    2420:	01c12783          	lw	a5,28(sp)
    2424:	0007c703          	lbu	a4,0(a5)
  return (ch >= '0') && (ch <= '9');
    2428:	fd070793          	addi	a5,a4,-48
    242c:	0ff7f793          	zext.b	a5,a5
    if (_is_digit(*format)) {
    2430:	00900693          	li	a3,9
    2434:	04f6f863          	bgeu	a3,a5,2484 <_vsnprintf+0x18c>
    else if (*format == '*') {
    2438:	02a00793          	li	a5,42
    243c:	04f70c63          	beq	a4,a5,2494 <_vsnprintf+0x19c>
    width = 0U;
    2440:	000a8b13          	mv	s6,s5
    if (*format == '.') {
    2444:	01c12783          	lw	a5,28(sp)
    2448:	0007c683          	lbu	a3,0(a5)
    244c:	02e00713          	li	a4,46
    2450:	06e68a63          	beq	a3,a4,24c4 <_vsnprintf+0x1cc>
    switch (*format) {
    2454:	01c12703          	lw	a4,28(sp)
    2458:	00074783          	lbu	a5,0(a4)
    245c:	f9878793          	addi	a5,a5,-104
    2460:	0ff7f613          	zext.b	a2,a5
    2464:	01200693          	li	a3,18
    2468:	12c6e663          	bltu	a3,a2,2594 <_vsnprintf+0x29c>
    246c:	00261793          	slli	a5,a2,0x2
    2470:	000076b7          	lui	a3,0x7
    2474:	34068693          	addi	a3,a3,832 # 7340 <_data+0x2e8>
    2478:	00d787b3          	add	a5,a5,a3
    247c:	0007a783          	lw	a5,0(a5)
    2480:	00078067          	jr	a5
      width = _atoi(&format);
    2484:	01c10513          	addi	a0,sp,28
    2488:	e41fe0ef          	jal	12c8 <_atoi>
    248c:	00050b13          	mv	s6,a0
    2490:	fb5ff06f          	j	2444 <_vsnprintf+0x14c>
      const int w = va_arg(va, int);
    2494:	01812783          	lw	a5,24(sp)
    2498:	00478713          	addi	a4,a5,4
    249c:	00e12c23          	sw	a4,24(sp)
    24a0:	0007ab03          	lw	s6,0(a5)
      if (w < 0) {
    24a4:	000b4a63          	bltz	s6,24b8 <_vsnprintf+0x1c0>
      format++;
    24a8:	01c12783          	lw	a5,28(sp)
    24ac:	00178793          	addi	a5,a5,1
    24b0:	00f12e23          	sw	a5,28(sp)
    24b4:	f91ff06f          	j	2444 <_vsnprintf+0x14c>
        flags |= FLAGS_LEFT;    // reverse padding
    24b8:	00246413          	ori	s0,s0,2
        width = (unsigned int)-w;
    24bc:	41600b33          	neg	s6,s6
    24c0:	fe9ff06f          	j	24a8 <_vsnprintf+0x1b0>
      flags |= FLAGS_PRECISION;
    24c4:	40046413          	ori	s0,s0,1024
      format++;
    24c8:	00178713          	addi	a4,a5,1
    24cc:	00e12e23          	sw	a4,28(sp)
      if (_is_digit(*format)) {
    24d0:	0017c703          	lbu	a4,1(a5)
  return (ch >= '0') && (ch <= '9');
    24d4:	fd070793          	addi	a5,a4,-48
    24d8:	0ff7f793          	zext.b	a5,a5
      if (_is_digit(*format)) {
    24dc:	00900693          	li	a3,9
    24e0:	02f6f863          	bgeu	a3,a5,2510 <_vsnprintf+0x218>
      else if (*format == '*') {
    24e4:	02a00793          	li	a5,42
    24e8:	f6f716e3          	bne	a4,a5,2454 <_vsnprintf+0x15c>
        const int prec = (int)va_arg(va, int);
    24ec:	01812783          	lw	a5,24(sp)
    24f0:	00478713          	addi	a4,a5,4
    24f4:	00e12c23          	sw	a4,24(sp)
    24f8:	0007aa83          	lw	s5,0(a5)
        precision = prec > 0 ? (unsigned int)prec : 0U;
    24fc:	020ac263          	bltz	s5,2520 <_vsnprintf+0x228>
        format++;
    2500:	01c12783          	lw	a5,28(sp)
    2504:	00178793          	addi	a5,a5,1
    2508:	00f12e23          	sw	a5,28(sp)
    250c:	f49ff06f          	j	2454 <_vsnprintf+0x15c>
        precision = _atoi(&format);
    2510:	01c10513          	addi	a0,sp,28
    2514:	db5fe0ef          	jal	12c8 <_atoi>
    2518:	00050a93          	mv	s5,a0
    251c:	f39ff06f          	j	2454 <_vsnprintf+0x15c>
        precision = prec > 0 ? (unsigned int)prec : 0U;
    2520:	00000a93          	li	s5,0
    2524:	fddff06f          	j	2500 <_vsnprintf+0x208>
        flags |= FLAGS_LONG;
    2528:	10046613          	ori	a2,s0,256
        format++;
    252c:	00170793          	addi	a5,a4,1
    2530:	00f12e23          	sw	a5,28(sp)
        if (*format == 'l') {
    2534:	00174683          	lbu	a3,1(a4)
    2538:	06c00793          	li	a5,108
    253c:	00f68663          	beq	a3,a5,2548 <_vsnprintf+0x250>
        flags |= FLAGS_LONG;
    2540:	00060413          	mv	s0,a2
    2544:	0500006f          	j	2594 <_vsnprintf+0x29c>
          flags |= FLAGS_LONG_LONG;
    2548:	30046413          	ori	s0,s0,768
          format++;
    254c:	00270713          	addi	a4,a4,2
    2550:	00e12e23          	sw	a4,28(sp)
    2554:	0400006f          	j	2594 <_vsnprintf+0x29c>
        flags |= FLAGS_SHORT;
    2558:	08046613          	ori	a2,s0,128
        format++;
    255c:	00170793          	addi	a5,a4,1
    2560:	00f12e23          	sw	a5,28(sp)
        if (*format == 'h') {
    2564:	00174683          	lbu	a3,1(a4)
    2568:	06800793          	li	a5,104
    256c:	00f68663          	beq	a3,a5,2578 <_vsnprintf+0x280>
        flags |= FLAGS_SHORT;
    2570:	00060413          	mv	s0,a2
    2574:	0200006f          	j	2594 <_vsnprintf+0x29c>
          flags |= FLAGS_CHAR;
    2578:	0c046413          	ori	s0,s0,192
          format++;
    257c:	00270713          	addi	a4,a4,2
    2580:	00e12e23          	sw	a4,28(sp)
    2584:	0100006f          	j	2594 <_vsnprintf+0x29c>
        flags |= (sizeof(ptrdiff_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    2588:	10046413          	ori	s0,s0,256
        format++;
    258c:	00170713          	addi	a4,a4,1
    2590:	00e12e23          	sw	a4,28(sp)
    switch (*format) {
    2594:	01c12783          	lw	a5,28(sp)
    2598:	0007c503          	lbu	a0,0(a5)
    259c:	06700793          	li	a5,103
    25a0:	04a7ea63          	bltu	a5,a0,25f4 <_vsnprintf+0x2fc>
    25a4:	02500793          	li	a5,37
    25a8:	6af56863          	bltu	a0,a5,2c58 <_vsnprintf+0x960>
    25ac:	fdb50793          	addi	a5,a0,-37
    25b0:	0ff7f693          	zext.b	a3,a5
    25b4:	04200713          	li	a4,66
    25b8:	6ad76063          	bltu	a4,a3,2c58 <_vsnprintf+0x960>
    25bc:	00269793          	slli	a5,a3,0x2
    25c0:	00007737          	lui	a4,0x7
    25c4:	38c70713          	addi	a4,a4,908 # 738c <_data+0x334>
    25c8:	00e787b3          	add	a5,a5,a4
    25cc:	0007a783          	lw	a5,0(a5)
    25d0:	00078067          	jr	a5
        flags |= (sizeof(intmax_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    25d4:	20046413          	ori	s0,s0,512
        format++;
    25d8:	00170713          	addi	a4,a4,1
    25dc:	00e12e23          	sw	a4,28(sp)
        break;
    25e0:	fb5ff06f          	j	2594 <_vsnprintf+0x29c>
        flags |= (sizeof(size_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    25e4:	10046413          	ori	s0,s0,256
        format++;
    25e8:	00170713          	addi	a4,a4,1
    25ec:	00e12e23          	sw	a4,28(sp)
        break;
    25f0:	fa5ff06f          	j	2594 <_vsnprintf+0x29c>
    switch (*format) {
    25f4:	07800793          	li	a5,120
    25f8:	66a7e063          	bltu	a5,a0,2c58 <_vsnprintf+0x960>
    25fc:	06900793          	li	a5,105
    2600:	64f56c63          	bltu	a0,a5,2c58 <_vsnprintf+0x960>
    2604:	f9750713          	addi	a4,a0,-105
    2608:	00100793          	li	a5,1
    260c:	00e797b3          	sll	a5,a5,a4
    2610:	00009737          	lui	a4,0x9
    2614:	04170713          	addi	a4,a4,65 # 9041 <__freertos_irq_stack_top+0x1c1>
    2618:	00e7f733          	and	a4,a5,a4
    261c:	04071263          	bnez	a4,2660 <_vsnprintf+0x368>
    2620:	0807f713          	andi	a4,a5,128
    2624:	5a071a63          	bnez	a4,2bd8 <_vsnprintf+0x8e0>
    2628:	4007f793          	andi	a5,a5,1024
    262c:	62078663          	beqz	a5,2c58 <_vsnprintf+0x960>
    2630:	03712e23          	sw	s7,60(sp)
    2634:	03812c23          	sw	s8,56(sp)
    2638:	03912a23          	sw	s9,52(sp)
    263c:	03a12823          	sw	s10,48(sp)
      }

      case 's' : {
        const char* p = va_arg(va, char*);
    2640:	01812783          	lw	a5,24(sp)
    2644:	00478713          	addi	a4,a5,4
    2648:	00e12c23          	sw	a4,24(sp)
    264c:	0007ac03          	lw	s8,0(a5)
        unsigned int l = _strnlen_s(p, precision ? precision : (size_t)-1);
    2650:	4c0a9463          	bnez	s5,2b18 <_vsnprintf+0x820>
    2654:	fff00713          	li	a4,-1
    2658:	000c0793          	mv	a5,s8
    265c:	4880006f          	j	2ae4 <_vsnprintf+0x7ec>
        if (*format == 'x' || *format == 'X') {
    2660:	06f00793          	li	a5,111
    2664:	02f50a63          	beq	a0,a5,2698 <_vsnprintf+0x3a0>
    2668:	00a7ee63          	bltu	a5,a0,2684 <_vsnprintf+0x38c>
    266c:	05800793          	li	a5,88
    2670:	0af50c63          	beq	a0,a5,2728 <_vsnprintf+0x430>
    2674:	06200793          	li	a5,98
    2678:	00f51a63          	bne	a0,a5,268c <_vsnprintf+0x394>
        flags |= FLAGS_SHORT;
    267c:	00200813          	li	a6,2
    2680:	01c0006f          	j	269c <_vsnprintf+0x3a4>
    2684:	07800793          	li	a5,120
    2688:	0af50463          	beq	a0,a5,2730 <_vsnprintf+0x438>
          flags &= ~FLAGS_HASH;   // no hash for dec format
    268c:	fef47413          	andi	s0,s0,-17
          base = 10U;
    2690:	00a00813          	li	a6,10
    2694:	0080006f          	j	269c <_vsnprintf+0x3a4>
        flags |= FLAGS_SHORT;
    2698:	00800813          	li	a6,8
        if (*format == 'X') {
    269c:	05800793          	li	a5,88
    26a0:	08f50c63          	beq	a0,a5,2738 <_vsnprintf+0x440>
        if ((*format != 'i') && (*format != 'd')) {
    26a4:	06900793          	li	a5,105
    26a8:	00f50863          	beq	a0,a5,26b8 <_vsnprintf+0x3c0>
    26ac:	06400793          	li	a5,100
    26b0:	00f50463          	beq	a0,a5,26b8 <_vsnprintf+0x3c0>
          flags &= ~(FLAGS_PLUS | FLAGS_SPACE);
    26b4:	ff347413          	andi	s0,s0,-13
        if (flags & FLAGS_PRECISION) {
    26b8:	40047793          	andi	a5,s0,1024
    26bc:	00078463          	beqz	a5,26c4 <_vsnprintf+0x3cc>
          flags &= ~FLAGS_ZEROPAD;
    26c0:	ffe47413          	andi	s0,s0,-2
        if ((*format == 'i') || (*format == 'd')) {
    26c4:	06900793          	li	a5,105
    26c8:	06f50c63          	beq	a0,a5,2740 <_vsnprintf+0x448>
    26cc:	06400793          	li	a5,100
    26d0:	06f50863          	beq	a0,a5,2740 <_vsnprintf+0x448>
          if (flags & FLAGS_LONG_LONG) {
    26d4:	20047793          	andi	a5,s0,512
    26d8:	1a079c63          	bnez	a5,2890 <_vsnprintf+0x598>
          else if (flags & FLAGS_LONG) {
    26dc:	10047793          	andi	a5,s0,256
    26e0:	20079063          	bnez	a5,28e0 <_vsnprintf+0x5e8>
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
    26e4:	04047793          	andi	a5,s0,64
    26e8:	22078a63          	beqz	a5,291c <_vsnprintf+0x624>
    26ec:	01812783          	lw	a5,24(sp)
    26f0:	00478713          	addi	a4,a5,4
    26f4:	00e12c23          	sw	a4,24(sp)
    26f8:	0007c703          	lbu	a4,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, value, false, base, precision, width, flags);
    26fc:	00812223          	sw	s0,4(sp)
    2700:	01612023          	sw	s6,0(sp)
    2704:	000a8893          	mv	a7,s5
    2708:	00000793          	li	a5,0
    270c:	00090693          	mv	a3,s2
    2710:	00048613          	mv	a2,s1
    2714:	00098593          	mv	a1,s3
    2718:	000a0513          	mv	a0,s4
    271c:	ec1fe0ef          	jal	15dc <_ntoa_long>
    2720:	00050493          	mv	s1,a0
    2724:	0780006f          	j	279c <_vsnprintf+0x4a4>
          base = 10U;
    2728:	01000813          	li	a6,16
    272c:	f71ff06f          	j	269c <_vsnprintf+0x3a4>
        flags |= FLAGS_SHORT;
    2730:	01000813          	li	a6,16
    2734:	f69ff06f          	j	269c <_vsnprintf+0x3a4>
          flags |= FLAGS_UPPERCASE;
    2738:	02046413          	ori	s0,s0,32
    273c:	f69ff06f          	j	26a4 <_vsnprintf+0x3ac>
          if (flags & FLAGS_LONG_LONG) {
    2740:	20047793          	andi	a5,s0,512
    2744:	06079463          	bnez	a5,27ac <_vsnprintf+0x4b4>
          else if (flags & FLAGS_LONG) {
    2748:	10047793          	andi	a5,s0,256
    274c:	0c079663          	bnez	a5,2818 <_vsnprintf+0x520>
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
    2750:	04047793          	andi	a5,s0,64
    2754:	10078663          	beqz	a5,2860 <_vsnprintf+0x568>
    2758:	01812783          	lw	a5,24(sp)
    275c:	00478713          	addi	a4,a5,4
    2760:	00e12c23          	sw	a4,24(sp)
    2764:	0007c783          	lbu	a5,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned int)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    2768:	41f7d713          	srai	a4,a5,0x1f
    276c:	00f746b3          	xor	a3,a4,a5
    2770:	00812223          	sw	s0,4(sp)
    2774:	01612023          	sw	s6,0(sp)
    2778:	000a8893          	mv	a7,s5
    277c:	01f7d793          	srli	a5,a5,0x1f
    2780:	40e68733          	sub	a4,a3,a4
    2784:	00090693          	mv	a3,s2
    2788:	00048613          	mv	a2,s1
    278c:	00098593          	mv	a1,s3
    2790:	000a0513          	mv	a0,s4
    2794:	e49fe0ef          	jal	15dc <_ntoa_long>
    2798:	00050493          	mv	s1,a0
        format++;
    279c:	01c12783          	lw	a5,28(sp)
    27a0:	00178793          	addi	a5,a5,1
    27a4:	00f12e23          	sw	a5,28(sp)
        break;
    27a8:	b91ff06f          	j	2338 <_vsnprintf+0x40>
            const long long value = va_arg(va, long long);
    27ac:	01812783          	lw	a5,24(sp)
    27b0:	00778793          	addi	a5,a5,7
    27b4:	ff87f793          	andi	a5,a5,-8
    27b8:	00878713          	addi	a4,a5,8
    27bc:	00e12c23          	sw	a4,24(sp)
    27c0:	0007a703          	lw	a4,0(a5)
    27c4:	0047a583          	lw	a1,4(a5)
            idx = _ntoa_long_long(out, buffer, idx, maxlen, (unsigned long long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    27c8:	41f5d693          	srai	a3,a1,0x1f
    27cc:	00e6c7b3          	xor	a5,a3,a4
    27d0:	00b6c633          	xor	a2,a3,a1
    27d4:	40d78733          	sub	a4,a5,a3
    27d8:	00e7b7b3          	sltu	a5,a5,a4
    27dc:	40d606b3          	sub	a3,a2,a3
    27e0:	00812623          	sw	s0,12(sp)
    27e4:	01612423          	sw	s6,8(sp)
    27e8:	01512223          	sw	s5,4(sp)
    27ec:	00012023          	sw	zero,0(sp)
    27f0:	00080893          	mv	a7,a6
    27f4:	01f5d813          	srli	a6,a1,0x1f
    27f8:	40f687b3          	sub	a5,a3,a5
    27fc:	00090693          	mv	a3,s2
    2800:	00048613          	mv	a2,s1
    2804:	00098593          	mv	a1,s3
    2808:	000a0513          	mv	a0,s4
    280c:	e95fe0ef          	jal	16a0 <_ntoa_long_long>
    2810:	00050493          	mv	s1,a0
    2814:	f89ff06f          	j	279c <_vsnprintf+0x4a4>
            const long value = va_arg(va, long);
    2818:	01812783          	lw	a5,24(sp)
    281c:	00478713          	addi	a4,a5,4
    2820:	00e12c23          	sw	a4,24(sp)
    2824:	0007a783          	lw	a5,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    2828:	41f7d713          	srai	a4,a5,0x1f
    282c:	00f746b3          	xor	a3,a4,a5
    2830:	00812223          	sw	s0,4(sp)
    2834:	01612023          	sw	s6,0(sp)
    2838:	000a8893          	mv	a7,s5
    283c:	01f7d793          	srli	a5,a5,0x1f
    2840:	40e68733          	sub	a4,a3,a4
    2844:	00090693          	mv	a3,s2
    2848:	00048613          	mv	a2,s1
    284c:	00098593          	mv	a1,s3
    2850:	000a0513          	mv	a0,s4
    2854:	d89fe0ef          	jal	15dc <_ntoa_long>
    2858:	00050493          	mv	s1,a0
    285c:	f41ff06f          	j	279c <_vsnprintf+0x4a4>
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
    2860:	08047793          	andi	a5,s0,128
    2864:	00078c63          	beqz	a5,287c <_vsnprintf+0x584>
    2868:	01812783          	lw	a5,24(sp)
    286c:	00478713          	addi	a4,a5,4
    2870:	00e12c23          	sw	a4,24(sp)
    2874:	00079783          	lh	a5,0(a5)
    2878:	ef1ff06f          	j	2768 <_vsnprintf+0x470>
    287c:	01812783          	lw	a5,24(sp)
    2880:	00478713          	addi	a4,a5,4
    2884:	00e12c23          	sw	a4,24(sp)
    2888:	0007a783          	lw	a5,0(a5)
    288c:	eddff06f          	j	2768 <_vsnprintf+0x470>
            idx = _ntoa_long_long(out, buffer, idx, maxlen, va_arg(va, unsigned long long), false, base, precision, width, flags);
    2890:	01812783          	lw	a5,24(sp)
    2894:	00778793          	addi	a5,a5,7
    2898:	ff87f793          	andi	a5,a5,-8
    289c:	00878713          	addi	a4,a5,8
    28a0:	00e12c23          	sw	a4,24(sp)
    28a4:	0007a703          	lw	a4,0(a5)
    28a8:	0047a783          	lw	a5,4(a5)
    28ac:	00812623          	sw	s0,12(sp)
    28b0:	01612423          	sw	s6,8(sp)
    28b4:	01512223          	sw	s5,4(sp)
    28b8:	00012023          	sw	zero,0(sp)
    28bc:	00080893          	mv	a7,a6
    28c0:	00000813          	li	a6,0
    28c4:	00090693          	mv	a3,s2
    28c8:	00048613          	mv	a2,s1
    28cc:	00098593          	mv	a1,s3
    28d0:	000a0513          	mv	a0,s4
    28d4:	dcdfe0ef          	jal	16a0 <_ntoa_long_long>
    28d8:	00050493          	mv	s1,a0
    28dc:	ec1ff06f          	j	279c <_vsnprintf+0x4a4>
            idx = _ntoa_long(out, buffer, idx, maxlen, va_arg(va, unsigned long), false, base, precision, width, flags);
    28e0:	01812783          	lw	a5,24(sp)
    28e4:	00478713          	addi	a4,a5,4
    28e8:	00e12c23          	sw	a4,24(sp)
    28ec:	0007a703          	lw	a4,0(a5)
    28f0:	00812223          	sw	s0,4(sp)
    28f4:	01612023          	sw	s6,0(sp)
    28f8:	000a8893          	mv	a7,s5
    28fc:	00000793          	li	a5,0
    2900:	00090693          	mv	a3,s2
    2904:	00048613          	mv	a2,s1
    2908:	00098593          	mv	a1,s3
    290c:	000a0513          	mv	a0,s4
    2910:	ccdfe0ef          	jal	15dc <_ntoa_long>
    2914:	00050493          	mv	s1,a0
    2918:	e85ff06f          	j	279c <_vsnprintf+0x4a4>
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
    291c:	08047793          	andi	a5,s0,128
    2920:	00078c63          	beqz	a5,2938 <_vsnprintf+0x640>
    2924:	01812783          	lw	a5,24(sp)
    2928:	00478713          	addi	a4,a5,4
    292c:	00e12c23          	sw	a4,24(sp)
    2930:	0007d703          	lhu	a4,0(a5)
    2934:	dc9ff06f          	j	26fc <_vsnprintf+0x404>
    2938:	01812783          	lw	a5,24(sp)
    293c:	00478713          	addi	a4,a5,4
    2940:	00e12c23          	sw	a4,24(sp)
    2944:	0007a703          	lw	a4,0(a5)
    2948:	db5ff06f          	j	26fc <_vsnprintf+0x404>
        if (*format == 'F') flags |= FLAGS_UPPERCASE;
    294c:	04600793          	li	a5,70
    2950:	04f50a63          	beq	a0,a5,29a4 <_vsnprintf+0x6ac>
        idx = _ftoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
    2954:	01812783          	lw	a5,24(sp)
    2958:	00778793          	addi	a5,a5,7
    295c:	ff87f793          	andi	a5,a5,-8
    2960:	00878713          	addi	a4,a5,8
    2964:	00e12c23          	sw	a4,24(sp)
    2968:	0007a703          	lw	a4,0(a5)
    296c:	0047a783          	lw	a5,4(a5)
    2970:	00812023          	sw	s0,0(sp)
    2974:	000b0893          	mv	a7,s6
    2978:	000a8813          	mv	a6,s5
    297c:	00090693          	mv	a3,s2
    2980:	00048613          	mv	a2,s1
    2984:	00098593          	mv	a1,s3
    2988:	000a0513          	mv	a0,s4
    298c:	c20ff0ef          	jal	1dac <_ftoa>
    2990:	00050493          	mv	s1,a0
        format++;
    2994:	01c12783          	lw	a5,28(sp)
    2998:	00178793          	addi	a5,a5,1
    299c:	00f12e23          	sw	a5,28(sp)
        break;
    29a0:	999ff06f          	j	2338 <_vsnprintf+0x40>
        if (*format == 'F') flags |= FLAGS_UPPERCASE;
    29a4:	02046413          	ori	s0,s0,32
    29a8:	fadff06f          	j	2954 <_vsnprintf+0x65c>
        if ((*format == 'g')||(*format == 'G')) flags |= FLAGS_ADAPT_EXP;
    29ac:	06700793          	li	a5,103
    29b0:	00f50663          	beq	a0,a5,29bc <_vsnprintf+0x6c4>
    29b4:	04700793          	li	a5,71
    29b8:	00f51863          	bne	a0,a5,29c8 <_vsnprintf+0x6d0>
    29bc:	000017b7          	lui	a5,0x1
    29c0:	80078793          	addi	a5,a5,-2048 # 800 <CUSTOM2+0x7a5>
    29c4:	00f46433          	or	s0,s0,a5
        if ((*format == 'E')||(*format == 'G')) flags |= FLAGS_UPPERCASE;
    29c8:	04500793          	li	a5,69
    29cc:	00f50663          	beq	a0,a5,29d8 <_vsnprintf+0x6e0>
    29d0:	04700793          	li	a5,71
    29d4:	00f51463          	bne	a0,a5,29dc <_vsnprintf+0x6e4>
    29d8:	02046413          	ori	s0,s0,32
        idx = _etoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
    29dc:	01812783          	lw	a5,24(sp)
    29e0:	00778793          	addi	a5,a5,7
    29e4:	ff87f793          	andi	a5,a5,-8
    29e8:	00878713          	addi	a4,a5,8
    29ec:	00e12c23          	sw	a4,24(sp)
    29f0:	0007a703          	lw	a4,0(a5)
    29f4:	0047a783          	lw	a5,4(a5)
    29f8:	00812023          	sw	s0,0(sp)
    29fc:	000b0893          	mv	a7,s6
    2a00:	000a8813          	mv	a6,s5
    2a04:	00090693          	mv	a3,s2
    2a08:	00048613          	mv	a2,s1
    2a0c:	00098593          	mv	a1,s3
    2a10:	000a0513          	mv	a0,s4
    2a14:	e25fe0ef          	jal	1838 <_etoa>
    2a18:	00050493          	mv	s1,a0
        format++;
    2a1c:	01c12783          	lw	a5,28(sp)
    2a20:	00178793          	addi	a5,a5,1
    2a24:	00f12e23          	sw	a5,28(sp)
        break;
    2a28:	911ff06f          	j	2338 <_vsnprintf+0x40>
    2a2c:	03712e23          	sw	s7,60(sp)
        if (!(flags & FLAGS_LEFT)) {
    2a30:	00247413          	andi	s0,s0,2
    2a34:	06040a63          	beqz	s0,2aa8 <_vsnprintf+0x7b0>
        unsigned int l = 1U;
    2a38:	00100a93          	li	s5,1
        out((char)va_arg(va, int), buffer, idx++, maxlen);
    2a3c:	01812783          	lw	a5,24(sp)
    2a40:	00478713          	addi	a4,a5,4
    2a44:	00e12c23          	sw	a4,24(sp)
    2a48:	00148b93          	addi	s7,s1,1
    2a4c:	00090693          	mv	a3,s2
    2a50:	00048613          	mv	a2,s1
    2a54:	00098593          	mv	a1,s3
    2a58:	0007c503          	lbu	a0,0(a5)
    2a5c:	000a00e7          	jalr	s4
        if (flags & FLAGS_LEFT) {
    2a60:	06041863          	bnez	s0,2ad0 <_vsnprintf+0x7d8>
        format++;
    2a64:	01c12783          	lw	a5,28(sp)
    2a68:	00178793          	addi	a5,a5,1
    2a6c:	00f12e23          	sw	a5,28(sp)
        break;
    2a70:	000b8493          	mv	s1,s7
    2a74:	03c12b83          	lw	s7,60(sp)
    2a78:	8c1ff06f          	j	2338 <_vsnprintf+0x40>
            out(' ', buffer, idx++, maxlen);
    2a7c:	00148b93          	addi	s7,s1,1
    2a80:	00090693          	mv	a3,s2
    2a84:	00048613          	mv	a2,s1
    2a88:	00098593          	mv	a1,s3
    2a8c:	02000513          	li	a0,32
    2a90:	000a00e7          	jalr	s4
          while (l++ < width) {
    2a94:	000a8793          	mv	a5,s5
            out(' ', buffer, idx++, maxlen);
    2a98:	000b8493          	mv	s1,s7
          while (l++ < width) {
    2a9c:	00178a93          	addi	s5,a5,1
    2aa0:	fd67eee3          	bltu	a5,s6,2a7c <_vsnprintf+0x784>
    2aa4:	f99ff06f          	j	2a3c <_vsnprintf+0x744>
        unsigned int l = 1U;
    2aa8:	00100793          	li	a5,1
    2aac:	ff1ff06f          	j	2a9c <_vsnprintf+0x7a4>
            out(' ', buffer, idx++, maxlen);
    2ab0:	001b8493          	addi	s1,s7,1
    2ab4:	00090693          	mv	a3,s2
    2ab8:	000b8613          	mv	a2,s7
    2abc:	00098593          	mv	a1,s3
    2ac0:	02000513          	li	a0,32
    2ac4:	000a00e7          	jalr	s4
          while (l++ < width) {
    2ac8:	00040a93          	mv	s5,s0
            out(' ', buffer, idx++, maxlen);
    2acc:	00048b93          	mv	s7,s1
          while (l++ < width) {
    2ad0:	001a8413          	addi	s0,s5,1
    2ad4:	fd6aeee3          	bltu	s5,s6,2ab0 <_vsnprintf+0x7b8>
    2ad8:	f8dff06f          	j	2a64 <_vsnprintf+0x76c>
  for (s = str; *s && maxsize--; ++s);
    2adc:	00178793          	addi	a5,a5,1
    2ae0:	00068713          	mv	a4,a3
    2ae4:	0007c683          	lbu	a3,0(a5)
    2ae8:	00068663          	beqz	a3,2af4 <_vsnprintf+0x7fc>
    2aec:	fff70693          	addi	a3,a4,-1
    2af0:	fe0716e3          	bnez	a4,2adc <_vsnprintf+0x7e4>
  return (unsigned int)(s - str);
    2af4:	41878bb3          	sub	s7,a5,s8
        // pre padding
        if (flags & FLAGS_PRECISION) {
    2af8:	40047c93          	andi	s9,s0,1024
    2afc:	000c8663          	beqz	s9,2b08 <_vsnprintf+0x810>
          l = (l < precision ? l : precision);
    2b00:	017af463          	bgeu	s5,s7,2b08 <_vsnprintf+0x810>
    2b04:	000a8b93          	mv	s7,s5
        }
        if (!(flags & FLAGS_LEFT)) {
    2b08:	00247d13          	andi	s10,s0,2
    2b0c:	060d1463          	bnez	s10,2b74 <_vsnprintf+0x87c>
    2b10:	03b12623          	sw	s11,44(sp)
    2b14:	02c0006f          	j	2b40 <_vsnprintf+0x848>
        unsigned int l = _strnlen_s(p, precision ? precision : (size_t)-1);
    2b18:	000a8713          	mv	a4,s5
    2b1c:	b3dff06f          	j	2658 <_vsnprintf+0x360>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
    2b20:	00148d93          	addi	s11,s1,1
    2b24:	00090693          	mv	a3,s2
    2b28:	00048613          	mv	a2,s1
    2b2c:	00098593          	mv	a1,s3
    2b30:	02000513          	li	a0,32
    2b34:	000a00e7          	jalr	s4
          while (l++ < width) {
    2b38:	00040b93          	mv	s7,s0
            out(' ', buffer, idx++, maxlen);
    2b3c:	000d8493          	mv	s1,s11
          while (l++ < width) {
    2b40:	001b8413          	addi	s0,s7,1
    2b44:	fd6beee3          	bltu	s7,s6,2b20 <_vsnprintf+0x828>
    2b48:	00040b93          	mv	s7,s0
    2b4c:	02c12d83          	lw	s11,44(sp)
    2b50:	0240006f          	j	2b74 <_vsnprintf+0x87c>
          }
        }
        // string output
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
    2b54:	00078a93          	mv	s5,a5
          out(*(p++), buffer, idx++, maxlen);
    2b58:	001c0c13          	addi	s8,s8,1
    2b5c:	00148413          	addi	s0,s1,1
    2b60:	00090693          	mv	a3,s2
    2b64:	00048613          	mv	a2,s1
    2b68:	00098593          	mv	a1,s3
    2b6c:	000a00e7          	jalr	s4
    2b70:	00040493          	mv	s1,s0
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
    2b74:	000c4503          	lbu	a0,0(s8)
    2b78:	00050863          	beqz	a0,2b88 <_vsnprintf+0x890>
    2b7c:	fc0c8ee3          	beqz	s9,2b58 <_vsnprintf+0x860>
    2b80:	fffa8793          	addi	a5,s5,-1
    2b84:	fc0a98e3          	bnez	s5,2b54 <_vsnprintf+0x85c>
        }
        // post padding
        if (flags & FLAGS_LEFT) {
    2b88:	040d1263          	bnez	s10,2bcc <_vsnprintf+0x8d4>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
          }
        }
        format++;
    2b8c:	01c12783          	lw	a5,28(sp)
    2b90:	00178793          	addi	a5,a5,1
    2b94:	00f12e23          	sw	a5,28(sp)
        break;
    2b98:	03c12b83          	lw	s7,60(sp)
    2b9c:	03812c03          	lw	s8,56(sp)
    2ba0:	03412c83          	lw	s9,52(sp)
    2ba4:	03012d03          	lw	s10,48(sp)
    2ba8:	f90ff06f          	j	2338 <_vsnprintf+0x40>
            out(' ', buffer, idx++, maxlen);
    2bac:	00148a93          	addi	s5,s1,1
    2bb0:	00090693          	mv	a3,s2
    2bb4:	00048613          	mv	a2,s1
    2bb8:	00098593          	mv	a1,s3
    2bbc:	02000513          	li	a0,32
    2bc0:	000a00e7          	jalr	s4
          while (l++ < width) {
    2bc4:	00040b93          	mv	s7,s0
            out(' ', buffer, idx++, maxlen);
    2bc8:	000a8493          	mv	s1,s5
          while (l++ < width) {
    2bcc:	001b8413          	addi	s0,s7,1
    2bd0:	fd6beee3          	bltu	s7,s6,2bac <_vsnprintf+0x8b4>
    2bd4:	fb9ff06f          	j	2b8c <_vsnprintf+0x894>
      }

      case 'p' : {
        width = sizeof(void*) * 2U;
        flags |= FLAGS_ZEROPAD | FLAGS_UPPERCASE;
    2bd8:	02146413          	ori	s0,s0,33
        if (is_ll) {
          idx = _ntoa_long_long(out, buffer, idx, maxlen, (uintptr_t)va_arg(va, void*), false, 16U, precision, width, flags);
        }
        else {
#endif
          idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)((uintptr_t)va_arg(va, void*)), false, 16U, precision, width, flags);
    2bdc:	01812783          	lw	a5,24(sp)
    2be0:	00478713          	addi	a4,a5,4
    2be4:	00e12c23          	sw	a4,24(sp)
    2be8:	0007a703          	lw	a4,0(a5)
    2bec:	00812223          	sw	s0,4(sp)
    2bf0:	00800793          	li	a5,8
    2bf4:	00f12023          	sw	a5,0(sp)
    2bf8:	000a8893          	mv	a7,s5
    2bfc:	01000813          	li	a6,16
    2c00:	00000793          	li	a5,0
    2c04:	00090693          	mv	a3,s2
    2c08:	00048613          	mv	a2,s1
    2c0c:	00098593          	mv	a1,s3
    2c10:	000a0513          	mv	a0,s4
    2c14:	9c9fe0ef          	jal	15dc <_ntoa_long>
    2c18:	00050493          	mv	s1,a0
#if defined(PRINTF_SUPPORT_LONG_LONG)
        }
#endif
        format++;
    2c1c:	01c12783          	lw	a5,28(sp)
    2c20:	00178793          	addi	a5,a5,1
    2c24:	00f12e23          	sw	a5,28(sp)
        break;
    2c28:	f10ff06f          	j	2338 <_vsnprintf+0x40>
      }

      case '%' :
        out('%', buffer, idx++, maxlen);
    2c2c:	00148413          	addi	s0,s1,1
    2c30:	00090693          	mv	a3,s2
    2c34:	00048613          	mv	a2,s1
    2c38:	00098593          	mv	a1,s3
    2c3c:	02500513          	li	a0,37
    2c40:	000a00e7          	jalr	s4
        format++;
    2c44:	01c12783          	lw	a5,28(sp)
    2c48:	00178793          	addi	a5,a5,1
    2c4c:	00f12e23          	sw	a5,28(sp)
        out('%', buffer, idx++, maxlen);
    2c50:	00040493          	mv	s1,s0
        break;
    2c54:	ee4ff06f          	j	2338 <_vsnprintf+0x40>

      default :
        out(*format, buffer, idx++, maxlen);
    2c58:	00148413          	addi	s0,s1,1
    2c5c:	00090693          	mv	a3,s2
    2c60:	00048613          	mv	a2,s1
    2c64:	00098593          	mv	a1,s3
    2c68:	000a00e7          	jalr	s4
        format++;
    2c6c:	01c12783          	lw	a5,28(sp)
    2c70:	00178793          	addi	a5,a5,1
    2c74:	00f12e23          	sw	a5,28(sp)
        out(*format, buffer, idx++, maxlen);
    2c78:	00040493          	mv	s1,s0
        break;
    2c7c:	ebcff06f          	j	2338 <_vsnprintf+0x40>
    out = _out_null;
    2c80:	00001a37          	lui	s4,0x1
    2c84:	2c4a0a13          	addi	s4,s4,708 # 12c4 <_out_null>
    2c88:	eacff06f          	j	2334 <_vsnprintf+0x3c>
    }
  }

  // termination
  out((char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
    2c8c:	0524e263          	bltu	s1,s2,2cd0 <_vsnprintf+0x9d8>
    2c90:	fff90613          	addi	a2,s2,-1
    2c94:	00090693          	mv	a3,s2
    2c98:	00098593          	mv	a1,s3
    2c9c:	00000513          	li	a0,0
    2ca0:	000a00e7          	jalr	s4

  // return written chars without terminating \0
  return (int)idx;
}
    2ca4:	00048513          	mv	a0,s1
    2ca8:	05c12083          	lw	ra,92(sp)
    2cac:	05812403          	lw	s0,88(sp)
    2cb0:	05412483          	lw	s1,84(sp)
    2cb4:	05012903          	lw	s2,80(sp)
    2cb8:	04c12983          	lw	s3,76(sp)
    2cbc:	04812a03          	lw	s4,72(sp)
    2cc0:	04412a83          	lw	s5,68(sp)
    2cc4:	04012b03          	lw	s6,64(sp)
    2cc8:	06010113          	addi	sp,sp,96
    2ccc:	00008067          	ret
  out((char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
    2cd0:	00048613          	mv	a2,s1
    2cd4:	fc1ff06f          	j	2c94 <_vsnprintf+0x99c>

00002cd8 <emit_char>:
* @note 空间不够时**返回原位置、不写入**，也就是说超长内容是被截断的，
*       而不是溢出。所有输出路径都要经过这个函数，边界检查就只需要在这一处
*       做对。
******************************************************************************/
static uint32_t emit_char(char *out, uint32_t pos, uint32_t cap, char c)
{
    2cd8:	00050793          	mv	a5,a0
    2cdc:	00058513          	mv	a0,a1
    if ((pos + 1U) < cap) {
    2ce0:	00158713          	addi	a4,a1,1
    2ce4:	00c76463          	bltu	a4,a2,2cec <emit_char+0x14>
        out[pos] = c;
        return pos + 1U;
    }
    return pos;
}
    2ce8:	00008067          	ret
        out[pos] = c;
    2cec:	00b78533          	add	a0,a5,a1
    2cf0:	00d50023          	sb	a3,0(a0)
        return pos + 1U;
    2cf4:	00070513          	mv	a0,a4
    2cf8:	00008067          	ret

00002cfc <emit_str>:
*       格式化 %s 时如果调用者传了个空指针，正常做法是崩溃；但对一个用于
*       排查问题的日志函数来说，崩溃恰恰是最糟的结果——它会把现场毁掉。
*       打印 (null) 既能让人看出"这里传空了"，又不会中断程序。
******************************************************************************/
static uint32_t emit_str(char *out, uint32_t pos, uint32_t cap, const char *s)
{
    2cfc:	ff010113          	addi	sp,sp,-16
    2d00:	00112623          	sw	ra,12(sp)
    2d04:	00812423          	sw	s0,8(sp)
    2d08:	00912223          	sw	s1,4(sp)
    2d0c:	01212023          	sw	s2,0(sp)
    2d10:	00050493          	mv	s1,a0
    2d14:	00060913          	mv	s2,a2
    2d18:	00068413          	mv	s0,a3
    if (s == 0) {
    2d1c:	02069263          	bnez	a3,2d40 <emit_str+0x44>
        s = "(null)";
    2d20:	00007437          	lui	s0,0x7
    2d24:	07040413          	addi	s0,s0,112 # 7070 <_data+0x18>
    2d28:	0180006f          	j	2d40 <emit_str+0x44>
    }
    while (*s != '\0') {
        pos = emit_char(out, pos, cap, *s);
    2d2c:	00090613          	mv	a2,s2
    2d30:	00048513          	mv	a0,s1
    2d34:	fa5ff0ef          	jal	2cd8 <emit_char>
    2d38:	00050593          	mv	a1,a0
        s++;
    2d3c:	00140413          	addi	s0,s0,1
    while (*s != '\0') {
    2d40:	00044683          	lbu	a3,0(s0)
    2d44:	fe0694e3          	bnez	a3,2d2c <emit_str+0x30>
    }
    return pos;
}
    2d48:	00058513          	mv	a0,a1
    2d4c:	00c12083          	lw	ra,12(sp)
    2d50:	00812403          	lw	s0,8(sp)
    2d54:	00412483          	lw	s1,4(sp)
    2d58:	00012903          	lw	s2,0(sp)
    2d5c:	01010113          	addi	sp,sp,16
    2d60:	00008067          	ret

00002d64 <emit_uint>:
* @note `n < sizeof(tmp)` 这个额外条件是防御性的：即使将来 tmp 的尺寸被改小、
*       或者 base 被传入了别的值，也不会写越界。
******************************************************************************/
static uint32_t emit_uint(char *out, uint32_t pos, uint32_t cap,
                          uint32_t value, uint32_t base, int upper)
{
    2d64:	fe010113          	addi	sp,sp,-32
    2d68:	00112e23          	sw	ra,28(sp)
    2d6c:	00912a23          	sw	s1,20(sp)
    2d70:	01212823          	sw	s2,16(sp)
    2d74:	00050493          	mv	s1,a0
    2d78:	00060913          	mv	s2,a2
    const char *digits = upper ? "0123456789ABCDEF" : "0123456789abcdef";
    2d7c:	04078463          	beqz	a5,2dc4 <emit_uint+0x60>
    2d80:	00007537          	lui	a0,0x7
    2d84:	07850513          	addi	a0,a0,120 # 7078 <_data+0x20>
    char        tmp[11];
    uint32_t    n = 0U;

    /* 0 要单独处理：上面的循环是"取余直到商为 0"，对 0 来说一次都不执行，
     * 结果会什么都不输出。而 "0" 显然应该输出一个 0。*/
    if (value == 0U) {
    2d88:	04068463          	beqz	a3,2dd0 <emit_uint+0x6c>
    2d8c:	00812c23          	sw	s0,24(sp)
    uint32_t    n = 0U;
    2d90:	00000413          	li	s0,0
        return emit_char(out, pos, cap, '0');
    }
    while ((value != 0U) && (n < sizeof(tmp))) {
    2d94:	06068a63          	beqz	a3,2e08 <emit_uint+0xa4>
    2d98:	00a00793          	li	a5,10
    2d9c:	0687e663          	bltu	a5,s0,2e08 <emit_uint+0xa4>
        tmp[n] = digits[value % base];  /* 取最低位 */
    2da0:	02e6f7b3          	remu	a5,a3,a4
    2da4:	00f507b3          	add	a5,a0,a5
    2da8:	0007c603          	lbu	a2,0(a5)
    2dac:	01040793          	addi	a5,s0,16
    2db0:	002787b3          	add	a5,a5,sp
    2db4:	fec78a23          	sb	a2,-12(a5)
        value /= base;                  /* 去掉最低位 */
    2db8:	02e6d6b3          	divu	a3,a3,a4
        n++;
    2dbc:	00140413          	addi	s0,s0,1
    2dc0:	fd5ff06f          	j	2d94 <emit_uint+0x30>
    const char *digits = upper ? "0123456789ABCDEF" : "0123456789abcdef";
    2dc4:	00007537          	lui	a0,0x7
    2dc8:	08c50513          	addi	a0,a0,140 # 708c <_data+0x34>
    2dcc:	fbdff06f          	j	2d88 <emit_uint+0x24>
        return emit_char(out, pos, cap, '0');
    2dd0:	03000693          	li	a3,48
    2dd4:	00090613          	mv	a2,s2
    2dd8:	00048513          	mv	a0,s1
    2ddc:	efdff0ef          	jal	2cd8 <emit_char>
    2de0:	00050593          	mv	a1,a0
    2de4:	02c0006f          	j	2e10 <emit_uint+0xac>
    }
    /* 倒序输出，得到高位在前的正常顺序。*/
    while (n > 0U) {
        n--;
    2de8:	fff40413          	addi	s0,s0,-1
        pos = emit_char(out, pos, cap, tmp[n]);
    2dec:	01040793          	addi	a5,s0,16
    2df0:	002787b3          	add	a5,a5,sp
    2df4:	ff47c683          	lbu	a3,-12(a5)
    2df8:	00090613          	mv	a2,s2
    2dfc:	00048513          	mv	a0,s1
    2e00:	ed9ff0ef          	jal	2cd8 <emit_char>
    2e04:	00050593          	mv	a1,a0
    while (n > 0U) {
    2e08:	fe0410e3          	bnez	s0,2de8 <emit_uint+0x84>
    2e0c:	01812403          	lw	s0,24(sp)
    }
    return pos;
}
    2e10:	00058513          	mv	a0,a1
    2e14:	01c12083          	lw	ra,28(sp)
    2e18:	01412483          	lw	s1,20(sp)
    2e1c:	01012903          	lw	s2,16(sp)
    2e20:	02010113          	addi	sp,sp,32
    2e24:	00008067          	ret

00002e28 <app_vformat>:
*       后面可能还有普通字符或别的格式符要处理，必须继续循环。
*       这一点和 frame.c 里状态机的写法正好相反——那里的每个状态处理完这一
*       字节就该返回了。
******************************************************************************/
static uint32_t app_vformat(char *out, uint32_t cap, const char *format, va_list ap)
{
    2e28:	fd010113          	addi	sp,sp,-48
    2e2c:	02112623          	sw	ra,44(sp)
    2e30:	00d12623          	sw	a3,12(sp)
    uint32_t pos = 0U;

    if ((out == 0) || (cap == 0U) || (format == 0)) {
    2e34:	2a050a63          	beqz	a0,30e8 <app_vformat+0x2c0>
    2e38:	02812423          	sw	s0,40(sp)
    2e3c:	02912223          	sw	s1,36(sp)
    2e40:	03212023          	sw	s2,32(sp)
    2e44:	00050913          	mv	s2,a0
    2e48:	00058493          	mv	s1,a1
    2e4c:	00060413          	mv	s0,a2
    2e50:	2a058063          	beqz	a1,30f0 <app_vformat+0x2c8>
    2e54:	2a060663          	beqz	a2,3100 <app_vformat+0x2d8>
    2e58:	01312e23          	sw	s3,28(sp)
    uint32_t pos = 0U;
    2e5c:	00000593          	li	a1,0
    2e60:	0640006f          	j	2ec4 <app_vformat+0x9c>
    }

    while (*format != '\0') {
        /* 普通字符直接输出。*/
        if (*format != '%') {
            pos = emit_char(out, pos, cap, *format);
    2e64:	00048613          	mv	a2,s1
    2e68:	00090513          	mv	a0,s2
    2e6c:	e6dff0ef          	jal	2cd8 <emit_char>
    2e70:	00050593          	mv	a1,a0
            format++;
    2e74:	00140413          	addi	s0,s0,1
            continue;
    2e78:	04c0006f          	j	2ec4 <app_vformat+0x9c>
        }

        /* 遇到 '%'，看下一个字符决定怎么处理。
         * format++ 之后 *format 就是格式符本身。*/
        format++;
        switch (*format) {
    2e7c:	1e078663          	beqz	a5,3068 <app_vformat+0x240>
    2e80:	02500713          	li	a4,37
    2e84:	20e79063          	bne	a5,a4,3084 <app_vformat+0x25c>
            pos = emit_str(out, pos, cap, "0x");
            pos = emit_uint(out, pos, cap, (uint32_t)va_arg(ap, void *), 16U, 0);
            break;
        case '%':
            /* "%%" 表示输出一个真正的百分号。*/
            pos = emit_char(out, pos, cap, '%');
    2e88:	02500693          	li	a3,37
    2e8c:	00048613          	mv	a2,s1
    2e90:	00090513          	mv	a0,s2
    2e94:	e45ff0ef          	jal	2cd8 <emit_char>
    2e98:	00050593          	mv	a1,a0
            break;
    2e9c:	0240006f          	j	2ec0 <app_vformat+0x98>
            pos = emit_str(out, pos, cap, va_arg(ap, const char *));
    2ea0:	00c12783          	lw	a5,12(sp)
    2ea4:	00478713          	addi	a4,a5,4
    2ea8:	00e12623          	sw	a4,12(sp)
    2eac:	0007a683          	lw	a3,0(a5)
    2eb0:	00048613          	mv	a2,s1
    2eb4:	00090513          	mv	a0,s2
    2eb8:	e45ff0ef          	jal	2cfc <emit_str>
    2ebc:	00050593          	mv	a1,a0
             * 在日志里一眼就能看见。如果静默吞掉，排查时会以为参数丢了。*/
            pos = emit_char(out, pos, cap, '%');
            pos = emit_char(out, pos, cap, *format);
            break;
        }
        format++;
    2ec0:	00198413          	addi	s0,s3,1
    while (*format != '\0') {
    2ec4:	00044683          	lbu	a3,0(s0)
    2ec8:	1e068463          	beqz	a3,30b0 <app_vformat+0x288>
        if (*format != '%') {
    2ecc:	02500793          	li	a5,37
    2ed0:	f8f69ae3          	bne	a3,a5,2e64 <app_vformat+0x3c>
        format++;
    2ed4:	00140993          	addi	s3,s0,1
        switch (*format) {
    2ed8:	00144783          	lbu	a5,1(s0)
    2edc:	07800713          	li	a4,120
    2ee0:	1af76263          	bltu	a4,a5,3084 <app_vformat+0x25c>
    2ee4:	05800713          	li	a4,88
    2ee8:	f8e7eae3          	bltu	a5,a4,2e7c <app_vformat+0x54>
    2eec:	fa878793          	addi	a5,a5,-88
    2ef0:	0ff7f693          	zext.b	a3,a5
    2ef4:	02000713          	li	a4,32
    2ef8:	18d76663          	bltu	a4,a3,3084 <app_vformat+0x25c>
    2efc:	00269793          	slli	a5,a3,0x2
    2f00:	00007737          	lui	a4,0x7
    2f04:	49870713          	addi	a4,a4,1176 # 7498 <_data+0x440>
    2f08:	00e787b3          	add	a5,a5,a4
    2f0c:	0007a783          	lw	a5,0(a5)
    2f10:	00078067          	jr	a5
            pos = emit_char(out, pos, cap, (char)va_arg(ap, int));
    2f14:	00c12783          	lw	a5,12(sp)
    2f18:	00478713          	addi	a4,a5,4
    2f1c:	00e12623          	sw	a4,12(sp)
    2f20:	0007c683          	lbu	a3,0(a5)
    2f24:	00048613          	mv	a2,s1
    2f28:	00090513          	mv	a0,s2
    2f2c:	dadff0ef          	jal	2cd8 <emit_char>
    2f30:	00050593          	mv	a1,a0
            break;
    2f34:	f8dff06f          	j	2ec0 <app_vformat+0x98>
            int32_t v = va_arg(ap, int32_t);
    2f38:	00c12783          	lw	a5,12(sp)
    2f3c:	00478713          	addi	a4,a5,4
    2f40:	00e12623          	sw	a4,12(sp)
    2f44:	0007a403          	lw	s0,0(a5)
            if (v < 0) {
    2f48:	02044263          	bltz	s0,2f6c <app_vformat+0x144>
                pos = emit_uint(out, pos, cap, (uint32_t)v, 10U, 0);
    2f4c:	00000793          	li	a5,0
    2f50:	00a00713          	li	a4,10
    2f54:	00040693          	mv	a3,s0
    2f58:	00048613          	mv	a2,s1
    2f5c:	00090513          	mv	a0,s2
    2f60:	e05ff0ef          	jal	2d64 <emit_uint>
    2f64:	00050593          	mv	a1,a0
    2f68:	f59ff06f          	j	2ec0 <app_vformat+0x98>
                pos = emit_char(out, pos, cap, '-');
    2f6c:	02d00693          	li	a3,45
    2f70:	00048613          	mv	a2,s1
    2f74:	00090513          	mv	a0,s2
    2f78:	d61ff0ef          	jal	2cd8 <emit_char>
    2f7c:	00050593          	mv	a1,a0
                pos = emit_uint(out, pos, cap, (uint32_t)0 - (uint32_t)v, 10U, 0);
    2f80:	00000793          	li	a5,0
    2f84:	00a00713          	li	a4,10
    2f88:	408006b3          	neg	a3,s0
    2f8c:	00048613          	mv	a2,s1
    2f90:	00090513          	mv	a0,s2
    2f94:	dd1ff0ef          	jal	2d64 <emit_uint>
    2f98:	00050593          	mv	a1,a0
    2f9c:	f25ff06f          	j	2ec0 <app_vformat+0x98>
            pos = emit_uint(out, pos, cap, va_arg(ap, uint32_t), 10U, 0);
    2fa0:	00c12683          	lw	a3,12(sp)
    2fa4:	00468793          	addi	a5,a3,4
    2fa8:	00f12623          	sw	a5,12(sp)
    2fac:	00000793          	li	a5,0
    2fb0:	00a00713          	li	a4,10
    2fb4:	0006a683          	lw	a3,0(a3)
    2fb8:	00048613          	mv	a2,s1
    2fbc:	00090513          	mv	a0,s2
    2fc0:	da5ff0ef          	jal	2d64 <emit_uint>
    2fc4:	00050593          	mv	a1,a0
            break;
    2fc8:	ef9ff06f          	j	2ec0 <app_vformat+0x98>
            pos = emit_uint(out, pos, cap, va_arg(ap, uint32_t), 16U, 0);
    2fcc:	00c12683          	lw	a3,12(sp)
    2fd0:	00468793          	addi	a5,a3,4
    2fd4:	00f12623          	sw	a5,12(sp)
    2fd8:	00000793          	li	a5,0
    2fdc:	01000713          	li	a4,16
    2fe0:	0006a683          	lw	a3,0(a3)
    2fe4:	00048613          	mv	a2,s1
    2fe8:	00090513          	mv	a0,s2
    2fec:	d79ff0ef          	jal	2d64 <emit_uint>
    2ff0:	00050593          	mv	a1,a0
            break;
    2ff4:	ecdff06f          	j	2ec0 <app_vformat+0x98>
            pos = emit_uint(out, pos, cap, va_arg(ap, uint32_t), 16U, 1);
    2ff8:	00c12683          	lw	a3,12(sp)
    2ffc:	00468793          	addi	a5,a3,4
    3000:	00f12623          	sw	a5,12(sp)
    3004:	00100793          	li	a5,1
    3008:	01000713          	li	a4,16
    300c:	0006a683          	lw	a3,0(a3)
    3010:	00048613          	mv	a2,s1
    3014:	00090513          	mv	a0,s2
    3018:	d4dff0ef          	jal	2d64 <emit_uint>
    301c:	00050593          	mv	a1,a0
            break;
    3020:	ea1ff06f          	j	2ec0 <app_vformat+0x98>
            pos = emit_str(out, pos, cap, "0x");
    3024:	000076b7          	lui	a3,0x7
    3028:	0a068693          	addi	a3,a3,160 # 70a0 <_data+0x48>
    302c:	00048613          	mv	a2,s1
    3030:	00090513          	mv	a0,s2
    3034:	cc9ff0ef          	jal	2cfc <emit_str>
    3038:	00050593          	mv	a1,a0
            pos = emit_uint(out, pos, cap, (uint32_t)va_arg(ap, void *), 16U, 0);
    303c:	00c12683          	lw	a3,12(sp)
    3040:	00468793          	addi	a5,a3,4
    3044:	00f12623          	sw	a5,12(sp)
    3048:	00000793          	li	a5,0
    304c:	01000713          	li	a4,16
    3050:	0006a683          	lw	a3,0(a3)
    3054:	00048613          	mv	a2,s1
    3058:	00090513          	mv	a0,s2
    305c:	d09ff0ef          	jal	2d64 <emit_uint>
    3060:	00050593          	mv	a1,a0
            break;
    3064:	e5dff06f          	j	2ec0 <app_vformat+0x98>
            pos = emit_char(out, pos, cap, '%');
    3068:	02500693          	li	a3,37
    306c:	00048613          	mv	a2,s1
    3070:	00090513          	mv	a0,s2
    3074:	c65ff0ef          	jal	2cd8 <emit_char>
    3078:	00050593          	mv	a1,a0
            format--;
    307c:	00040993          	mv	s3,s0
            break;
    3080:	e41ff06f          	j	2ec0 <app_vformat+0x98>
            pos = emit_char(out, pos, cap, '%');
    3084:	02500693          	li	a3,37
    3088:	00048613          	mv	a2,s1
    308c:	00090513          	mv	a0,s2
    3090:	c49ff0ef          	jal	2cd8 <emit_char>
    3094:	00050593          	mv	a1,a0
            pos = emit_char(out, pos, cap, *format);
    3098:	00144683          	lbu	a3,1(s0)
    309c:	00048613          	mv	a2,s1
    30a0:	00090513          	mv	a0,s2
    30a4:	c35ff0ef          	jal	2cd8 <emit_char>
    30a8:	00050593          	mv	a1,a0
            break;
    30ac:	e15ff06f          	j	2ec0 <app_vformat+0x98>
    }

    /* 补上字符串结束符。
     * 这里用三元表达式做一次边界保护：如果写满到 cap，就写到最后一个字节，
     * 保证 out 始终是一个合法的、有结束符的字符串。*/
    out[(pos < cap) ? pos : (cap - 1U)] = '\0';
    30b0:	0295e863          	bltu	a1,s1,30e0 <app_vformat+0x2b8>
    30b4:	fff48493          	addi	s1,s1,-1
    30b8:	00990933          	add	s2,s2,s1
    30bc:	00090023          	sb	zero,0(s2)
    return pos;
    30c0:	02812403          	lw	s0,40(sp)
    30c4:	02412483          	lw	s1,36(sp)
    30c8:	02012903          	lw	s2,32(sp)
    30cc:	01c12983          	lw	s3,28(sp)
}
    30d0:	00058513          	mv	a0,a1
    30d4:	02c12083          	lw	ra,44(sp)
    30d8:	03010113          	addi	sp,sp,48
    30dc:	00008067          	ret
    out[(pos < cap) ? pos : (cap - 1U)] = '\0';
    30e0:	00058493          	mv	s1,a1
    30e4:	fd5ff06f          	j	30b8 <app_vformat+0x290>
        return 0U;
    30e8:	00000593          	li	a1,0
    30ec:	fe5ff06f          	j	30d0 <app_vformat+0x2a8>
    30f0:	02812403          	lw	s0,40(sp)
    30f4:	02412483          	lw	s1,36(sp)
    30f8:	02012903          	lw	s2,32(sp)
    30fc:	fd5ff06f          	j	30d0 <app_vformat+0x2a8>
    3100:	00000593          	li	a1,0
    3104:	02812403          	lw	s0,40(sp)
    3108:	02412483          	lw	s1,36(sp)
    310c:	02012903          	lw	s2,32(sp)
    3110:	fc1ff06f          	j	30d0 <app_vformat+0x2a8>

00003114 <bsp_printf>:
* @param format Format string followed by the arguments to be formatted.
* @param ... Variable arguments corresponding to the format specifiers in 'format'.
*
******************************************************************************/
    static int bsp_printf(const char* format, ...)
    {
    3114:	f6010113          	addi	sp,sp,-160
    3118:	06112e23          	sw	ra,124(sp)
    311c:	06812c23          	sw	s0,120(sp)
    3120:	08b12223          	sw	a1,132(sp)
    3124:	08c12423          	sw	a2,136(sp)
    3128:	08d12623          	sw	a3,140(sp)
    312c:	08e12823          	sw	a4,144(sp)
    3130:	08f12a23          	sw	a5,148(sp)
    3134:	09012c23          	sw	a6,152(sp)
    3138:	09112e23          	sw	a7,156(sp)
      va_list va;
      va_start(va, format);
    313c:	08410713          	addi	a4,sp,132
    3140:	06e12623          	sw	a4,108(sp)

      char buffer[MAX_STRING_BUFFER_SIZE];
        const int ret = _vsnprintf(_out_buffer, buffer, (size_t)-1, format, va);
    3144:	00050693          	mv	a3,a0
    3148:	fff00613          	li	a2,-1
    314c:	00810593          	addi	a1,sp,8
    3150:	00001537          	lui	a0,0x1
    3154:	2b450513          	addi	a0,a0,692 # 12b4 <_out_buffer>
    3158:	9a0ff0ef          	jal	22f8 <_vsnprintf>
    315c:	00050413          	mv	s0,a0
        _putchar_s(buffer);
    3160:	00810513          	addi	a0,sp,8
    3164:	938fe0ef          	jal	129c <_putchar_s>

      va_end(va);
      return ret;
    }
    3168:	00040513          	mv	a0,s0
    316c:	07c12083          	lw	ra,124(sp)
    3170:	07812403          	lw	s0,120(sp)
    3174:	0a010113          	addi	sp,sp,160
    3178:	00008067          	ret

0000317c <app_log_init>:
/******************************************************************************
* @brief 清空日志环并清零计数。
******************************************************************************/
void app_log_init(void)
{
    s_head = 0U;
    317c:	8c01a223          	sw	zero,-1852(gp) # 77ec <s_head>
    s_tail = 0U;
    3180:	8c01a023          	sw	zero,-1856(gp) # 77e8 <s_tail>
    s_dropped = 0U;
    3184:	8a01ae23          	sw	zero,-1860(gp) # 77e4 <s_dropped>
    s_once_mask = 0U;      /* 清掉"已报过"的位，让 app_log_once 重新从首次开始 */
    3188:	8a01ac23          	sw	zero,-1864(gp) # 77e0 <s_once_mask>
}
    318c:	00008067          	ret

00003190 <app_log_pending>:
*
* @note 与 proto_uart.c 里同样的环形缓冲技巧：无符号减法 + 掩码取模。
******************************************************************************/
uint32_t app_log_pending(void)
{
    return (s_head - s_tail) & (APP_LOG_RING_SIZE - 1U);
    3190:	8c41a503          	lw	a0,-1852(gp) # 77ec <s_head>
    3194:	8c01a783          	lw	a5,-1856(gp) # 77e8 <s_tail>
    3198:	40f50533          	sub	a0,a0,a5
}
    319c:	3ff57513          	andi	a0,a0,1023
    31a0:	00008067          	ret

000031a4 <app_log_v>:
    char     msg[APP_LOG_MSG_MAX];
    uint32_t used;
    uint32_t i;
    uint32_t space;

    if (format == 0) {
    31a4:	0c050663          	beqz	a0,3270 <app_log_v+0xcc>
{
    31a8:	f5010113          	addi	sp,sp,-176
    31ac:	0a112623          	sw	ra,172(sp)
    31b0:	0a812423          	sw	s0,168(sp)
    31b4:	00050613          	mv	a2,a0
    31b8:	00058693          	mv	a3,a1
        return;
    }

    used = app_vformat(msg, sizeof(msg), format, ap);
    31bc:	0a000593          	li	a1,160
    31c0:	00010513          	mv	a0,sp
    31c4:	c65ff0ef          	jal	2e28 <app_vformat>
    31c8:	00050413          	mv	s0,a0

    /* 格式化结果为空就不必进队了。*/
    if (used == 0U) {
    31cc:	00051a63          	bnez	a0,31e0 <app_log_v+0x3c>
     *
     * 这里补的是**逻辑换行**（只有 '\n' 一个字节）。真正上串口需要的
     * "\r\n" 两个字节由 app_log_flush() 在发送前展开，理由见那个函数的说明。*/
    s_ring[s_head] = '\n';
    s_head = (s_head + 1U) & (APP_LOG_RING_SIZE - 1U);
}
    31d0:	0ac12083          	lw	ra,172(sp)
    31d4:	0a812403          	lw	s0,168(sp)
    31d8:	0b010113          	addi	sp,sp,176
    31dc:	00008067          	ret
    space = (APP_LOG_RING_SIZE - 1U) - app_log_pending();
    31e0:	fb1ff0ef          	jal	3190 <app_log_pending>
    31e4:	3ff00793          	li	a5,1023
    31e8:	40a787b3          	sub	a5,a5,a0
    if ((used + 1U) > space) {
    31ec:	00140713          	addi	a4,s0,1
    31f0:	00e7e663          	bltu	a5,a4,31fc <app_log_v+0x58>
    for (i = 0U; i < used; i++) {
    31f4:	00000713          	li	a4,0
    31f8:	0480006f          	j	3240 <app_log_v+0x9c>
        s_dropped++;           /* 放不下整条，丢掉并计数 */
    31fc:	8bc1a783          	lw	a5,-1860(gp) # 77e4 <s_dropped>
    3200:	00178793          	addi	a5,a5,1
    3204:	8af1ae23          	sw	a5,-1860(gp) # 77e4 <s_dropped>
        return;
    3208:	fc9ff06f          	j	31d0 <app_log_v+0x2c>
        s_ring[s_head] = msg[i];
    320c:	8c41a583          	lw	a1,-1852(gp) # 77ec <s_head>
    3210:	0a070793          	addi	a5,a4,160
    3214:	002787b3          	add	a5,a5,sp
    3218:	f607c603          	lbu	a2,-160(a5)
    321c:	000087b7          	lui	a5,0x8
    3220:	85478793          	addi	a5,a5,-1964 # 7854 <s_ring>
    3224:	00b787b3          	add	a5,a5,a1
    3228:	00c78023          	sb	a2,0(a5)
        s_head = (s_head + 1U) & (APP_LOG_RING_SIZE - 1U);
    322c:	8c41a783          	lw	a5,-1852(gp) # 77ec <s_head>
    3230:	00178793          	addi	a5,a5,1
    3234:	3ff7f793          	andi	a5,a5,1023
    3238:	8cf1a223          	sw	a5,-1852(gp) # 77ec <s_head>
    for (i = 0U; i < used; i++) {
    323c:	00170713          	addi	a4,a4,1
    3240:	fc8766e3          	bltu	a4,s0,320c <app_log_v+0x68>
    s_ring[s_head] = '\n';
    3244:	8c41a683          	lw	a3,-1852(gp) # 77ec <s_head>
    3248:	000087b7          	lui	a5,0x8
    324c:	85478793          	addi	a5,a5,-1964 # 7854 <s_ring>
    3250:	00d787b3          	add	a5,a5,a3
    3254:	00a00693          	li	a3,10
    3258:	00d78023          	sb	a3,0(a5)
    s_head = (s_head + 1U) & (APP_LOG_RING_SIZE - 1U);
    325c:	8c41a783          	lw	a5,-1852(gp) # 77ec <s_head>
    3260:	00178793          	addi	a5,a5,1
    3264:	3ff7f793          	andi	a5,a5,1023
    3268:	8cf1a223          	sw	a5,-1852(gp) # 77ec <s_head>
    326c:	f65ff06f          	j	31d0 <app_log_v+0x2c>
    3270:	00008067          	ret

00003274 <app_log_dropped>:
}
    3274:	8bc1a503          	lw	a0,-1860(gp) # 77e4 <s_dropped>
    3278:	00008067          	ret

0000327c <app_log>:
* @brief 格式化一条消息并排进队列。
*
* @param format 格式串，后面跟可变参数。
******************************************************************************/
void app_log(const char *format, ...)
{
    327c:	fc010113          	addi	sp,sp,-64
    3280:	00112e23          	sw	ra,28(sp)
    3284:	02b12223          	sw	a1,36(sp)
    3288:	02c12423          	sw	a2,40(sp)
    328c:	02d12623          	sw	a3,44(sp)
    3290:	02e12823          	sw	a4,48(sp)
    3294:	02f12a23          	sw	a5,52(sp)
    3298:	03012c23          	sw	a6,56(sp)
    329c:	03112e23          	sw	a7,60(sp)
    va_list ap;

    va_start(ap, format);
    32a0:	02410593          	addi	a1,sp,36
    32a4:	00b12623          	sw	a1,12(sp)
    app_log_v(format, ap);
    32a8:	efdff0ef          	jal	31a4 <app_log_v>
    va_end(ap);
}
    32ac:	01c12083          	lw	ra,28(sp)
    32b0:	04010113          	addi	sp,sp,64
    32b4:	00008067          	ret

000032b8 <app_log_once>:
* @note bitno MUST 小于 32。C 语言里 `1U << 32` 是**未定义行为**（不是简单
*       地得到 0），可能把其它位搅乱。这里显式挡住，因为 bitno 常直接来自枚举，
*       将来给枚举加值时就可能越界，而那种 bug 极难查。
******************************************************************************/
void app_log_once(uint32_t bitno, const char *format, ...)
{
    32b8:	fc010113          	addi	sp,sp,-64
    32bc:	00112e23          	sw	ra,28(sp)
    32c0:	00050313          	mv	t1,a0
    32c4:	02c12423          	sw	a2,40(sp)
    32c8:	02d12623          	sw	a3,44(sp)
    32cc:	02e12823          	sw	a4,48(sp)
    32d0:	02f12a23          	sw	a5,52(sp)
    32d4:	03012c23          	sw	a6,56(sp)
    32d8:	03112e23          	sw	a7,60(sp)
    va_list ap;

    if (bitno >= 32U) {
    32dc:	01f00793          	li	a5,31
    32e0:	00a7ee63          	bltu	a5,a0,32fc <app_log_once+0x44>
    32e4:	00058513          	mv	a0,a1
        return;                    /* 越界：宁可不输出，也不能移位越界 */
    }
    if ((s_once_mask & (1U << bitno)) != 0U) {
    32e8:	00100793          	li	a5,1
    32ec:	006797b3          	sll	a5,a5,t1
    32f0:	8b81a703          	lw	a4,-1864(gp) # 77e0 <s_once_mask>
    32f4:	00e7f6b3          	and	a3,a5,a4
    32f8:	00068863          	beqz	a3,3308 <app_log_once+0x50>
    s_once_mask |= (1U << bitno);

    va_start(ap, format);
    app_log_v(format, ap);
    va_end(ap);
}
    32fc:	01c12083          	lw	ra,28(sp)
    3300:	04010113          	addi	sp,sp,64
    3304:	00008067          	ret
    s_once_mask |= (1U << bitno);
    3308:	00e7e7b3          	or	a5,a5,a4
    330c:	8af1ac23          	sw	a5,-1864(gp) # 77e0 <s_once_mask>
    va_start(ap, format);
    3310:	02810593          	addi	a1,sp,40
    3314:	00b12623          	sw	a1,12(sp)
    app_log_v(format, ap);
    3318:	e8dff0ef          	jal	31a4 <app_log_v>
    va_end(ap);
    331c:	fe1ff06f          	j	32fc <app_log_once+0x44>

00003320 <app_log_flush>:
* @note 末尾多留一个字节给 '\0'（s_emit 定义为 CHUNK+1 大小），
*       s_emit[out] = '\0' 就是补结束符——这一句不能省，否则打印函数会越过
*       有效内容继续往后读。
******************************************************************************/
uint32_t app_log_flush(void)
{
    3320:	ff010113          	addi	sp,sp,-16
    3324:	00112623          	sw	ra,12(sp)
    3328:	00812423          	sw	s0,8(sp)
    /* pending 在循环开始前取一次就够了：本函数是环的唯一消费者，
     * 循环里 s_tail 只会往前走，所以 pending 就是"这次最多能取多少"。*/
    uint32_t pending = app_log_pending();
    332c:	e65ff0ef          	jal	3190 <app_log_pending>
    uint32_t consumed = 0U;     /* 已从环里取走的源字节数 */
    uint32_t out = 0U;          /* 已写入 s_emit 的输出字节数 */
    char     c;

    if (pending == 0U) {
    3330:	0a050a63          	beqz	a0,33e4 <app_log_flush+0xc4>
    uint32_t out = 0U;          /* 已写入 s_emit 的输出字节数 */
    3334:	00000413          	li	s0,0
    uint32_t consumed = 0U;     /* 已从环里取走的源字节数 */
    3338:	00000713          	li	a4,0
    333c:	0480006f          	j	3384 <app_log_flush+0x64>
             * 后半条日志会覆盖在当前行上；只发 '\n' 又会阶梯错位。
             * 要么整对发出，要么一个都不发。
             *
             * 注：APP_LOG_CHUNK 为 32，所以 out==0 时这个条件必然不成立，
             * 不会出现"一个字节都取不出来"的死循环。*/
            if ((out + 2U) > APP_LOG_CHUNK) {
    3340:	00240693          	addi	a3,s0,2
    3344:	02000793          	li	a5,32
    3348:	06d7ec63          	bltu	a5,a3,33c0 <app_log_flush+0xa0>
                break;
            }
            s_emit[out] = '\r';     /* 先回车 */
    334c:	90818793          	addi	a5,gp,-1784 # 7830 <s_emit>
    3350:	00878633          	add	a2,a5,s0
    3354:	00d00593          	li	a1,13
    3358:	00b60023          	sb	a1,0(a2)
            out++;
    335c:	00140413          	addi	s0,s0,1
            s_emit[out] = '\n';     /* 再换行 */
    3360:	008787b3          	add	a5,a5,s0
    3364:	00a00613          	li	a2,10
    3368:	00c78023          	sb	a2,0(a5)
            out++;
    336c:	00068413          	mv	s0,a3
            s_emit[out] = c;
            out++;
        }

        /* 到这里这个源字节才算真正被消费掉，推进读指针。*/
        s_tail = (s_tail + 1U) & (APP_LOG_RING_SIZE - 1U);
    3370:	8c01a783          	lw	a5,-1856(gp) # 77e8 <s_tail>
    3374:	00178793          	addi	a5,a5,1
    3378:	3ff7f793          	andi	a5,a5,1023
    337c:	8cf1a023          	sw	a5,-1856(gp) # 77e8 <s_tail>
        consumed++;
    3380:	00170713          	addi	a4,a4,1
    while ((consumed < pending) && (out < APP_LOG_CHUNK)) {
    3384:	02a77e63          	bgeu	a4,a0,33c0 <app_log_flush+0xa0>
    3388:	01f00793          	li	a5,31
    338c:	0287ea63          	bltu	a5,s0,33c0 <app_log_flush+0xa0>
        c = s_ring[s_tail];
    3390:	8c01a683          	lw	a3,-1856(gp) # 77e8 <s_tail>
    3394:	000087b7          	lui	a5,0x8
    3398:	85478793          	addi	a5,a5,-1964 # 7854 <s_ring>
    339c:	00d787b3          	add	a5,a5,a3
    33a0:	0007c683          	lbu	a3,0(a5)
        if (c == '\n') {
    33a4:	00a00793          	li	a5,10
    33a8:	f8f68ce3          	beq	a3,a5,3340 <app_log_flush+0x20>
            s_emit[out] = c;
    33ac:	90818793          	addi	a5,gp,-1784 # 7830 <s_emit>
    33b0:	008787b3          	add	a5,a5,s0
    33b4:	00d78023          	sb	a3,0(a5)
            out++;
    33b8:	00140413          	addi	s0,s0,1
    33bc:	fb5ff06f          	j	3370 <app_log_flush+0x50>
    }

    /* 一个字节都没能发出（理论上只在 APP_LOG_CHUNK < 2 时才会发生），
     * 那就不要调打印函数，避免发一个空字符串白白停顿一次。*/
    if (out == 0U) {
    33c0:	02040463          	beqz	s0,33e8 <app_log_flush+0xc8>
        return 0U;
    }

    s_emit[out] = '\0';
    33c4:	90818793          	addi	a5,gp,-1784 # 7830 <s_emit>
    33c8:	008787b3          	add	a5,a5,s0
    33cc:	00078023          	sb	zero,0(a5)

    /* 唯一的硬件调用点。这一句会让 CPU 停顿若干时间（见 app_log.h），
     * 所以它被放在主循环里、在服务完 uart1 之后。*/
    bsp_printf("%s", s_emit);
    33d0:	90818593          	addi	a1,gp,-1784 # 7830 <s_emit>
    33d4:	00007537          	lui	a0,0x7
    33d8:	0a450513          	addi	a0,a0,164 # 70a4 <_data+0x4c>
    33dc:	d39ff0ef          	jal	3114 <bsp_printf>

    return out;
    33e0:	0080006f          	j	33e8 <app_log_flush+0xc8>
        return 0U;              /* 没东西可发，不碰硬件 */
    33e4:	00050413          	mv	s0,a0
}
    33e8:	00040513          	mv	a0,s0
    33ec:	00c12083          	lw	ra,12(sp)
    33f0:	00812403          	lw	s0,8(sp)
    33f4:	01010113          	addi	sp,sp,16
    33f8:	00008067          	ret

000033fc <uart_applyConfig>:
*          value using data length, parity, and stop bit settings from the configuration
*          structure, and writes this value to the UART frame configuration register.
*
******************************************************************************/
    static void uart_applyConfig(u32 reg, Uart_Config *config){
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
    33fc:	00c5a783          	lw	a5,12(a1)
    static inline u32 read_u32(u32 address){
        return *((volatile u32*) address);
    }
    
    static inline void write_u32(u32 data, u32 address){
        *((volatile u32*) address) = data;
    3400:	00f52423          	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
    3404:	0005a783          	lw	a5,0(a1)
    3408:	fff78793          	addi	a5,a5,-1
    340c:	0045a703          	lw	a4,4(a1)
    3410:	00871713          	slli	a4,a4,0x8
    3414:	00e7e7b3          	or	a5,a5,a4
    3418:	0085a703          	lw	a4,8(a1)
    341c:	01071713          	slli	a4,a4,0x10
    3420:	00e7e7b3          	or	a5,a5,a4
    3424:	00f52623          	sw	a5,12(a0)
    }
    3428:	00008067          	ret

0000342c <clint_getTime>:
*          to guard against rollover. It checks if the high part remains unchanged
*          during the read operation to ensure consistency. The high and low parts
*          are then combined to form the 64-bit current time value.
*
******************************************************************************/
    static u64 clint_getTime(u32 p){
    342c:	00050693          	mv	a3,a0
    readReg_u32 (clint_getTimeHigh, CLINT_TIME_ADDR+4)
    3430:	0000c7b7          	lui	a5,0xc
    3434:	ffc78793          	addi	a5,a5,-4 # bffc <__freertos_irq_stack_top+0x317c>
    3438:	00f687b3          	add	a5,a3,a5
        return *((volatile u32*) address);
    343c:	0007a583          	lw	a1,0(a5)
    readReg_u32 (clint_getTimeLow , CLINT_TIME_ADDR)
    3440:	0000c737          	lui	a4,0xc
    3444:	ff870713          	addi	a4,a4,-8 # bff8 <__freertos_irq_stack_top+0x3178>
    3448:	00e68733          	add	a4,a3,a4
    344c:	00072503          	lw	a0,0(a4)
    3450:	0007a783          	lw	a5,0(a5)
    
        /* Likewise, must guard against rollover when reading */
        do {
            hi = clint_getTimeHigh(p);
            lo = clint_getTimeLow(p);
        } while (clint_getTimeHigh(p) != hi);
    3454:	fcb79ee3          	bne	a5,a1,3430 <clint_getTime+0x4>
    
        return (((u64)hi) << 32) | lo;
    }
    3458:	00008067          	ret

0000345c <bsp_init>:
    *   1. UART baudrate
    *   2. 
    */
////////////////////////////////////////////////////////////////////////////////
    static void bsp_init()
    {
    345c:	fe010113          	addi	sp,sp,-32
    3460:	00112e23          	sw	ra,28(sp)
        Uart_Config uartConfig;
        uartConfig.dataLength   = BITS_8;
    3464:	00800793          	li	a5,8
    3468:	00f12023          	sw	a5,0(sp)
        uartConfig.parity       = NONE;
    346c:	00012223          	sw	zero,4(sp)
        uartConfig.stop         = ONE;
    3470:	00012423          	sw	zero,8(sp)
        uartConfig.clockDivider = BSP_CLINT_HZ/(BSP_UART_BAUDRATE*BSP_UART_DATA_LEN)-1;
    3474:	03500793          	li	a5,53
    3478:	00f12623          	sw	a5,12(sp)
        uart_applyConfig(BSP_UART_TERMINAL, &uartConfig);    
    347c:	00010593          	mv	a1,sp
    3480:	f8001537          	lui	a0,0xf8001
    3484:	f79ff0ef          	jal	33fc <uart_applyConfig>
    }
    3488:	01c12083          	lw	ra,28(sp)
    348c:	02010113          	addi	sp,sp,32
    3490:	00008067          	ret

00003494 <plic_claim>:
*          value from the calculated address, effectively claiming an interrupt
*          for the specified target in the PLIC.
*
******************************************************************************/
    static u32 plic_claim(u32 plic, u32 target){
        return read_u32(plic + PLIC_CLAIM_BASE + target*PLIC_CONTEXT_PER_HART);
    3494:	00c59593          	slli	a1,a1,0xc
    3498:	00a585b3          	add	a1,a1,a0
    349c:	002007b7          	lui	a5,0x200
    34a0:	00478793          	addi	a5,a5,4 # 200004 <__freertos_irq_stack_top+0x1f7184>
    34a4:	00f585b3          	add	a1,a1,a5
    34a8:	0005a503          	lw	a0,0(a1)
    }
    34ac:	00008067          	ret

000034b0 <plic_release>:
*          to the calculated address, effectively releasing the claimed interrupt
*          for the specified target in the PLIC.
*
******************************************************************************/
    static void plic_release(u32 plic, u32 target, u32 gateway){
        write_u32(gateway,plic + PLIC_CLAIM_BASE + target*PLIC_CONTEXT_PER_HART);
    34b0:	00c59593          	slli	a1,a1,0xc
    34b4:	00a585b3          	add	a1,a1,a0
    34b8:	002007b7          	lui	a5,0x200
    34bc:	00478793          	addi	a5,a5,4 # 200004 <__freertos_irq_stack_top+0x1f7184>
    34c0:	00f585b3          	add	a1,a1,a5
        *((volatile u32*) address) = data;
    34c4:	00c5a023          	sw	a2,0(a1)
    }
    34c8:	00008067          	ret

000034cc <isr_init>:
    csr_write(mtvec, trap_entry);        /* 异常/中断入口，定义在 ../common/trap.S */
    34cc:	000047b7          	lui	a5,0x4
    34d0:	0e078793          	addi	a5,a5,224 # 40e0 <trap_entry>
    34d4:	30579073          	csrw	mtvec,a5
    csr_set(mie, MIE_MEIE);
    34d8:	000017b7          	lui	a5,0x1
    34dc:	80078793          	addi	a5,a5,-2048 # 800 <CUSTOM2+0x7a5>
    34e0:	3047a073          	csrs	mie,a5
    csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);
    34e4:	300027f3          	csrr	a5,mstatus
    34e8:	00002737          	lui	a4,0x2
    34ec:	80870713          	addi	a4,a4,-2040 # 1808 <_ntoa_long_long+0x168>
    34f0:	00e7e7b3          	or	a5,a5,a4
    34f4:	30079073          	csrw	mstatus,a5
}
    34f8:	00008067          	ret

000034fc <report_frame>:
static void report_frame(const frame_t *frame, const protocol_response_t *response){
    34fc:	ff010113          	addi	sp,sp,-16
    3500:	00112623          	sw	ra,12(sp)
    3504:	00050613          	mv	a2,a0
    const uint32_t bit = (uint32_t)response->reason;
    3508:	00c5a503          	lw	a0,12(a1)
    switch (response->reason) {
    350c:	00600793          	li	a5,6
    3510:	08a7e263          	bltu	a5,a0,3594 <report_frame+0x98>
    3514:	00251793          	slli	a5,a0,0x2
    3518:	00007737          	lui	a4,0x7
    351c:	57070713          	addi	a4,a4,1392 # 7570 <pow10.0+0x50>
    3520:	00e787b3          	add	a5,a5,a4
    3524:	0007a783          	lw	a5,0(a5)
    3528:	00078067          	jr	a5
        app_log_once(bit, "rx cmd=0x%x (%s) len=%u -> not implemented, nak",
    352c:	00465703          	lhu	a4,4(a2)
    3530:	0105a683          	lw	a3,16(a1)
    3534:	00164603          	lbu	a2,1(a2)
    3538:	000075b7          	lui	a1,0x7
    353c:	0a858593          	addi	a1,a1,168 # 70a8 <_data+0x50>
    3540:	d79ff0ef          	jal	32b8 <app_log_once>
}
    3544:	00c12083          	lw	ra,12(sp)
    3548:	01010113          	addi	sp,sp,16
    354c:	00008067          	ret
        app_log_once(bit, "rx cmd=0x%x unknown, nak", (uint32_t)frame->command);
    3550:	00164603          	lbu	a2,1(a2)
    3554:	000075b7          	lui	a1,0x7
    3558:	0d858593          	addi	a1,a1,216 # 70d8 <_data+0x80>
    355c:	d5dff0ef          	jal	32b8 <app_log_once>
        break;
    3560:	fe5ff06f          	j	3544 <report_frame+0x48>
        app_log_once(bit, "rx cmd=0x%x (%s) len=%u wrong, nak",
    3564:	00465703          	lhu	a4,4(a2)
    3568:	0105a683          	lw	a3,16(a1)
    356c:	00164603          	lbu	a2,1(a2)
    3570:	000075b7          	lui	a1,0x7
    3574:	0f458593          	addi	a1,a1,244 # 70f4 <_data+0x9c>
    3578:	d41ff0ef          	jal	32b8 <app_log_once>
        break;
    357c:	fc9ff06f          	j	3544 <report_frame+0x48>
        app_log_once(bit, "rx cmd=0x%x bad type, nak", (uint32_t)frame->command);
    3580:	00164603          	lbu	a2,1(a2)
    3584:	000075b7          	lui	a1,0x7
    3588:	11858593          	addi	a1,a1,280 # 7118 <_data+0xc0>
    358c:	d2dff0ef          	jal	32b8 <app_log_once>
        break;
    3590:	fb5ff06f          	j	3544 <report_frame+0x48>
        app_log_once(bit, "rx cmd=0x%x crc/footer bad -> no-ack",
    3594:	00164603          	lbu	a2,1(a2)
    3598:	000075b7          	lui	a1,0x7
    359c:	13458593          	addi	a1,a1,308 # 7134 <_data+0xdc>
    35a0:	d19ff0ef          	jal	32b8 <app_log_once>
}
    35a4:	fa1ff06f          	j	3544 <report_frame+0x48>

000035a8 <poll_rx_loss>:
{
    35a8:	ff010113          	addi	sp,sp,-16
    35ac:	00112623          	sw	ra,12(sp)
    35b0:	00812423          	sw	s0,8(sp)
    uint32_t ring_drop = proto_uart_rx_dropped();
    35b4:	6cc000ef          	jal	3c80 <proto_uart_rx_dropped>
    35b8:	00050413          	mv	s0,a0
    uint32_t fifo_ovf  = proto_uart_fifo_overflow();
    35bc:	6cc000ef          	jal	3c88 <proto_uart_fifo_overflow>
    35c0:	00050693          	mv	a3,a0
    if ((ring_drop != s_ring_drop_seen) || (fifo_ovf != s_fifo_ovf_seen)) {
    35c4:	8cc1a783          	lw	a5,-1844(gp) # 77f4 <s_ring_drop_seen>
    35c8:	00879663          	bne	a5,s0,35d4 <poll_rx_loss+0x2c>
    35cc:	8c81a783          	lw	a5,-1848(gp) # 77f0 <s_fifo_ovf_seen>
    35d0:	02a78063          	beq	a5,a0,35f0 <poll_rx_loss+0x48>
        s_ring_drop_seen = ring_drop;
    35d4:	8c81a623          	sw	s0,-1844(gp) # 77f4 <s_ring_drop_seen>
        s_fifo_ovf_seen = fifo_ovf;
    35d8:	8cd1a423          	sw	a3,-1848(gp) # 77f0 <s_fifo_ovf_seen>
        app_log_once(ONCE_BIT_RX_DROPPED,
    35dc:	00040613          	mv	a2,s0
    35e0:	000075b7          	lui	a1,0x7
    35e4:	15c58593          	addi	a1,a1,348 # 715c <_data+0x104>
    35e8:	01000513          	li	a0,16
    35ec:	ccdff0ef          	jal	32b8 <app_log_once>
}
    35f0:	00c12083          	lw	ra,12(sp)
    35f4:	00812403          	lw	s0,8(sp)
    35f8:	01010113          	addi	sp,sp,16
    35fc:	00008067          	ret

00003600 <log_stats>:
{
    3600:	fc010113          	addi	sp,sp,-64
    3604:	02112e23          	sw	ra,60(sp)
    3608:	02812c23          	sw	s0,56(sp)
    360c:	02912a23          	sw	s1,52(sp)
    3610:	03212823          	sw	s2,48(sp)
    3614:	03312623          	sw	s3,44(sp)
    3618:	03412423          	sw	s4,40(sp)
    361c:	03512223          	sw	s5,36(sp)
    3620:	03612023          	sw	s6,32(sp)
    3624:	01712e23          	sw	s7,28(sp)
    app_log("stats: frames=%u accepted=%u bad=%u other=%u bad_len=%u "
    3628:	8f41a983          	lw	s3,-1804(gp) # 781c <s_frames_processed>
    362c:	d2c18793          	addi	a5,gp,-724 # 7c54 <s_stats>
    3630:	0007aa03          	lw	s4,0(a5)
    3634:	0047aa83          	lw	s5,4(a5)
    3638:	0087ab03          	lw	s6,8(a5)
    363c:	d3818793          	addi	a5,gp,-712 # 7c60 <s_parser>
    3640:	0107ab83          	lw	s7,16(a5)
    3644:	63c000ef          	jal	3c80 <proto_uart_rx_dropped>
    3648:	00050413          	mv	s0,a0
    364c:	63c000ef          	jal	3c88 <proto_uart_fifo_overflow>
    3650:	00050493          	mv	s1,a0
    3654:	c21ff0ef          	jal	3274 <app_log_dropped>
    3658:	00a12023          	sw	a0,0(sp)
    365c:	00048893          	mv	a7,s1
    3660:	00040813          	mv	a6,s0
    3664:	000b8793          	mv	a5,s7
    3668:	000b0713          	mv	a4,s6
    366c:	000a8693          	mv	a3,s5
    3670:	000a0613          	mv	a2,s4
    3674:	00098593          	mv	a1,s3
    3678:	00007537          	lui	a0,0x7
    367c:	19850513          	addi	a0,a0,408 # 7198 <_data+0x140>
    3680:	bfdff0ef          	jal	327c <app_log>
    s_reported_frames = s_frames_processed;
    3684:	8f41a703          	lw	a4,-1804(gp) # 781c <s_frames_processed>
    3688:	8ce1aa23          	sw	a4,-1836(gp) # 77fc <s_reported_frames>
}
    368c:	03c12083          	lw	ra,60(sp)
    3690:	03812403          	lw	s0,56(sp)
    3694:	03412483          	lw	s1,52(sp)
    3698:	03012903          	lw	s2,48(sp)
    369c:	02c12983          	lw	s3,44(sp)
    36a0:	02812a03          	lw	s4,40(sp)
    36a4:	02412a83          	lw	s5,36(sp)
    36a8:	02012b03          	lw	s6,32(sp)
    36ac:	01c12b83          	lw	s7,28(sp)
    36b0:	04010113          	addi	sp,sp,64
    36b4:	00008067          	ret

000036b8 <handle_frame>:
static void handle_frame(const frame_t *frame){
    36b8:	fd010113          	addi	sp,sp,-48
    36bc:	02112623          	sw	ra,44(sp)
    36c0:	02812423          	sw	s0,40(sp)
    36c4:	00050413          	mv	s0,a0
    protocol_handle(&s_stats, frame, &response);
    36c8:	00c10613          	addi	a2,sp,12
    36cc:	00050593          	mv	a1,a0
    36d0:	d2c18513          	addi	a0,gp,-724 # 7c54 <s_stats>
    36d4:	095000ef          	jal	3f68 <protocol_handle>
    s_frames_processed++;
    36d8:	8f41a783          	lw	a5,-1804(gp) # 781c <s_frames_processed>
    36dc:	00178793          	addi	a5,a5,1
    36e0:	8ef1aa23          	sw	a5,-1804(gp) # 781c <s_frames_processed>
    report_frame(frame, &response);
    36e4:	00c10593          	addi	a1,sp,12
    36e8:	00040513          	mv	a0,s0
    36ec:	e11ff0ef          	jal	34fc <report_frame>
    if (response.send_ack != 0) {
    36f0:	01614783          	lbu	a5,22(sp)
    36f4:	02079263          	bnez	a5,3718 <handle_frame+0x60>
    poll_rx_loss();
    36f8:	eb1ff0ef          	jal	35a8 <poll_rx_loss>
    if ((s_frames_processed % STATS_INTERVAL) == 0U) {
    36fc:	8f41a783          	lw	a5,-1804(gp) # 781c <s_frames_processed>
    3700:	03f7f793          	andi	a5,a5,63
    3704:	02078263          	beqz	a5,3728 <handle_frame+0x70>
}
    3708:	02c12083          	lw	ra,44(sp)
    370c:	02812403          	lw	s0,40(sp)
    3710:	03010113          	addi	sp,sp,48
    3714:	00008067          	ret
        (void)proto_uart_write(response.ack, PROTOCOL_ACK_LEN);
    3718:	00a00593          	li	a1,10
    371c:	00c10513          	addi	a0,sp,12
    3720:	62c000ef          	jal	3d4c <proto_uart_write>
    3724:	fd5ff06f          	j	36f8 <handle_frame+0x40>
        log_stats();
    3728:	ed9ff0ef          	jal	3600 <log_stats>
}
    372c:	fddff06f          	j	3708 <handle_frame+0x50>

00003730 <isr_routine>:
void isr_routine(){
    3730:	ff010113          	addi	sp,sp,-16
    3734:	00112623          	sw	ra,12(sp)
    3738:	00812423          	sw	s0,8(sp)
    while ((claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)) != 0U) {
    373c:	0180006f          	j	3754 <isr_routine+0x24>
            proto_uart_isr();      /* 把收到的字节搬进接收环 */
    3740:	57c000ef          	jal	3cbc <proto_uart_isr>
        plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim);
    3744:	00040613          	mv	a2,s0
    3748:	00000593          	li	a1,0
    374c:	f8c00537          	lui	a0,0xf8c00
    3750:	d61ff0ef          	jal	34b0 <plic_release>
    while ((claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)) != 0U) {
    3754:	00000593          	li	a1,0
    3758:	f8c00537          	lui	a0,0xf8c00
    375c:	d39ff0ef          	jal	3494 <plic_claim>
    3760:	00050413          	mv	s0,a0
    3764:	00050e63          	beqz	a0,3780 <isr_routine+0x50>
        if (claim == SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT) {
    3768:	00200793          	li	a5,2
    376c:	fcf40ae3          	beq	s0,a5,3740 <isr_routine+0x10>
            s_isr_unknown_source++;
    3770:	8e01a783          	lw	a5,-1824(gp) # 7808 <s_isr_unknown_source>
    3774:	00178793          	addi	a5,a5,1
    3778:	8ef1a023          	sw	a5,-1824(gp) # 7808 <s_isr_unknown_source>
    377c:	fc9ff06f          	j	3744 <isr_routine+0x14>
}
    3780:	00c12083          	lw	ra,12(sp)
    3784:	00812403          	lw	s0,8(sp)
    3788:	01010113          	addi	sp,sp,16
    378c:	00008067          	ret

00003790 <trap>:
void trap(){
    3790:	ff010113          	addi	sp,sp,-16
    3794:	00112623          	sw	ra,12(sp)
    int32_t mcause = csr_read(mcause);   /* 读 CSR 寄存器，得到异常/中断原因 */
    3798:	342025f3          	csrr	a1,mcause
    int32_t cause     = mcause & 0xF;    /* 低 4 位 → 具体原因编号 */
    379c:	00f5f793          	andi	a5,a1,15
    if (interrupt) {
    37a0:	0205c663          	bltz	a1,37cc <trap+0x3c>
    if (cause == CAUSE_BREAKPOINT) {
    37a4:	00300713          	li	a4,3
    37a8:	04e78263          	beq	a5,a4,37ec <trap+0x5c>
    s_unexpected_exceptions++;
    37ac:	8e81a783          	lw	a5,-1816(gp) # 7810 <s_unexpected_exceptions>
    37b0:	00178793          	addi	a5,a5,1
    37b4:	8ef1a423          	sw	a5,-1816(gp) # 7810 <s_unexpected_exceptions>
    if (!s_unexpected_exception_logged) {
    37b8:	8e41c783          	lbu	a5,-1820(gp) # 780c <s_unexpected_exception_logged>
    37bc:	04078063          	beqz	a5,37fc <trap+0x6c>
}
    37c0:	00c12083          	lw	ra,12(sp)
    37c4:	01010113          	addi	sp,sp,16
    37c8:	00008067          	ret
        if (cause == CAUSE_MACHINE_EXTERNAL) {
    37cc:	00b00713          	li	a4,11
    37d0:	00e78a63          	beq	a5,a4,37e4 <trap+0x54>
            s_unexpected_interrupts++;
    37d4:	8ec1a783          	lw	a5,-1812(gp) # 7814 <s_unexpected_interrupts>
    37d8:	00178793          	addi	a5,a5,1
    37dc:	8ef1a623          	sw	a5,-1812(gp) # 7814 <s_unexpected_interrupts>
        return;
    37e0:	fe1ff06f          	j	37c0 <trap+0x30>
            isr_routine();
    37e4:	f4dff0ef          	jal	3730 <isr_routine>
    37e8:	fd9ff06f          	j	37c0 <trap+0x30>
        s_semihosting_breakpoints++;
    37ec:	8f01a783          	lw	a5,-1808(gp) # 7818 <s_semihosting_breakpoints>
    37f0:	00178793          	addi	a5,a5,1
    37f4:	8ef1a823          	sw	a5,-1808(gp) # 7818 <s_semihosting_breakpoints>
        return;
    37f8:	fc9ff06f          	j	37c0 <trap+0x30>
        s_unexpected_exception_logged = 1;
    37fc:	00100713          	li	a4,1
    3800:	8ee18223          	sb	a4,-1820(gp) # 780c <s_unexpected_exception_logged>
        app_log("trap: unexpected exception mcause=0x%x", (uint32_t)mcause);
    3804:	00007537          	lui	a0,0x7
    3808:	1f850513          	addi	a0,a0,504 # 71f8 <_data+0x1a0>
    380c:	a71ff0ef          	jal	327c <app_log>
    3810:	fb1ff06f          	j	37c0 <trap+0x30>

00003814 <start_frame>:
*       好处是链接器不会为它生成对外符号，也不怕和别的文件里的同名函数冲突。
*       本文件里所有辅助函数都用 static。
******************************************************************************/
static int start_frame(frame_parser_t *parser, uint8_t byte)
{
    if (byte != FRAME_HEADER) {
    3814:	0bb00793          	li	a5,187
    3818:	02f59463          	bne	a1,a5,3840 <start_frame+0x2c>
        return 0;   /* 不是帧头，当噪声丢掉，继续等 */
    }
    parser->state = ST_LEN_H;
    381c:	00100793          	li	a5,1
    3820:	00f50023          	sb	a5,0(a0)
    parser->body_length = 0U;
    3824:	00051123          	sh	zero,2(a0)
    parser->body_index = 0U;
    3828:	00051223          	sh	zero,4(a0)
    parser->body_crc = 0U;
    382c:	00051323          	sh	zero,6(a0)
    parser->recv_crc = 0U;
    3830:	00051423          	sh	zero,8(a0)
    parser->category = 0U;
    3834:	00050523          	sb	zero,10(a0)
    parser->command = 0U;
    3838:	000505a3          	sb	zero,11(a0)
    parser->type = 0U;
    383c:	00050623          	sb	zero,12(a0)
    return 0;
}
    3840:	00000513          	li	a0,0
    3844:	00008067          	ret

00003848 <frame_parser_init>:
    if (parser == 0) {
    3848:	02050463          	beqz	a0,3870 <frame_parser_init+0x28>
    parser->state = ST_HEADER;
    384c:	00050023          	sb	zero,0(a0)
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
    parser->bad_length_count = 0U;
    386c:	00052823          	sw	zero,16(a0)
}
    3870:	00008067          	ret

00003874 <frame_parser_feed>:
*       break 导致穿透到下一个 case"这个 C 语言的经典坑；二是每个状态的
*       处理路径互不影响，读代码时不用往回看。
******************************************************************************/
int frame_parser_feed(frame_parser_t *parser, uint8_t byte, frame_t *out)
{
    if ((parser == 0) || (out == 0)) {
    3874:	1c050663          	beqz	a0,3a40 <frame_parser_feed+0x1cc>
{
    3878:	ff010113          	addi	sp,sp,-16
    387c:	00112623          	sw	ra,12(sp)
    3880:	00812423          	sw	s0,8(sp)
    3884:	00912223          	sw	s1,4(sp)
    3888:	00050413          	mv	s0,a0
    388c:	00058493          	mv	s1,a1
    if ((parser == 0) || (out == 0)) {
    3890:	1a060c63          	beqz	a2,3a48 <frame_parser_feed+0x1d4>
        return 0;
    }

    switch (parser->state) {
    3894:	00054783          	lbu	a5,0(a0)
    3898:	00500713          	li	a4,5
    389c:	12f76663          	bltu	a4,a5,39c8 <frame_parser_feed+0x154>
    38a0:	00279793          	slli	a5,a5,0x2
    38a4:	00007737          	lui	a4,0x7
    38a8:	58c70713          	addi	a4,a4,1420 # 758c <pow10.0+0x6c>
    38ac:	00e787b3          	add	a5,a5,a4
    38b0:	0007a783          	lw	a5,0(a5)
    38b4:	00078067          	jr	a5
    /* --- 等帧头：帧与帧之间的所有噪声都在这里被自然丢弃 --- */
    case ST_HEADER:
        return start_frame(parser, byte);
    38b8:	f5dff0ef          	jal	3814 <start_frame>
    38bc:	1900006f          	j	3a4c <frame_parser_feed+0x1d8>

    /* --- 长度高字节：先暂存到 body_length 的高 8 位 --- */
    case ST_LEN_H:
        /* (uint16_t)byte << 8 把这一字节挪到高字节，低字节此时还是 0。
         * 用 = 而不是 |= 是刻意的：这里直接覆盖，避免上一帧的残留值混进来。*/
        parser->body_length = (uint16_t)byte << 8;
    38c0:	00859593          	slli	a1,a1,0x8
    38c4:	00b51123          	sh	a1,2(a0)
        parser->state = ST_LEN_L;
    38c8:	00200793          	li	a5,2
    38cc:	00f50023          	sb	a5,0(a0)
        return 0;
    38d0:	00000513          	li	a0,0
    38d4:	1780006f          	j	3a4c <frame_parser_feed+0x1d8>

    /* --- 长度低字节：凑成完整长度，并立刻检查是否合法 --- */
    case ST_LEN_L:
        /* |= 把低字节补上，此时 body_length 才是完整的 16 位长度。*/
        parser->body_length |= (uint16_t)byte;
    38d8:	00255783          	lhu	a5,2(a0)
    38dc:	00f5e7b3          	or	a5,a1,a5
    38e0:	00f51123          	sh	a5,2(a0)

        if ((parser->body_length < FRAME_BODY_LEN_MIN) ||
    38e4:	ffd78793          	addi	a5,a5,-3
    38e8:	01079793          	slli	a5,a5,0x10
    38ec:	0107d793          	srli	a5,a5,0x10
    38f0:	00001737          	lui	a4,0x1
    38f4:	38470713          	addi	a4,a4,900 # 1384 <_out_rev+0x74>
    38f8:	00f76c63          	bltu	a4,a5,3910 <frame_parser_feed+0x9c>
             * 没成为一个帧。*/
            parser->bad_length_count++;
            parser->state = ST_HEADER;
            return 0;
        }
        parser->body_index = 0U;
    38fc:	00051223          	sh	zero,4(a0)
        parser->state = ST_BODY;
    3900:	00300793          	li	a5,3
    3904:	00f50023          	sb	a5,0(a0)
        return 0;
    3908:	00000513          	li	a0,0
    390c:	1400006f          	j	3a4c <frame_parser_feed+0x1d8>
            parser->bad_length_count++;
    3910:	01052783          	lw	a5,16(a0)
    3914:	00178793          	addi	a5,a5,1
    3918:	00f52823          	sw	a5,16(a0)
            parser->state = ST_HEADER;
    391c:	00050023          	sb	zero,0(a0)
            return 0;
    3920:	00000513          	li	a0,0
    3924:	1280006f          	j	3a4c <frame_parser_feed+0x1d8>

    /* --- body：边收边算 CRC，同时把前 3 个字节记下来 --- */
    case ST_BODY:
        parser->body_crc = crc16_ccitt_update(parser->body_crc, byte);
    3928:	00655503          	lhu	a0,6(a0)
    392c:	4b4000ef          	jal	3de0 <crc16_ccitt_update>
    3930:	00a41323          	sh	a0,6(s0)

        /* 前 3 个字节是固定的头结构，第 3 个 if 之后的都是 payload。
         * 注意这里**只记录、不校验**：大类是路由字段，合法性由上层判断
         * （见 frame.h 里"大类是路由字段，不是格式标记"的说明）。
         * 只有"类型"这一位在帧尾阶段会做校验。*/
        if (parser->body_index == 0U) {
    3934:	00445703          	lhu	a4,4(s0)
    3938:	02071663          	bnez	a4,3964 <frame_parser_feed+0xf0>
            parser->category = byte;
    393c:	00940523          	sb	s1,10(s0)
         * 实现分块写入（子项 0x02），再针对那一条命令单独缓存即可。*/

        /* 收到第 body_length 个字节时，body 结束，转去收 CRC。
         * body_index 从 0 计，所以最后一个字节的下标是 body_length-1。
         * 这里的减法已经安全：长度在 ST_LEN_L 阶段校验过 >= 3。*/
        if (parser->body_index == (uint16_t)(parser->body_length - 1U)) {
    3940:	00245783          	lhu	a5,2(s0)
    3944:	fff78793          	addi	a5,a5,-1
    3948:	01079793          	slli	a5,a5,0x10
    394c:	0107d793          	srli	a5,a5,0x10
    3950:	02f70a63          	beq	a4,a5,3984 <frame_parser_feed+0x110>
            parser->state = ST_CRC_H;
        } else {
            parser->body_index++;
    3954:	00170713          	addi	a4,a4,1
    3958:	00e41223          	sh	a4,4(s0)
        }
        return 0;
    395c:	00000513          	li	a0,0
    3960:	0ec0006f          	j	3a4c <frame_parser_feed+0x1d8>
        } else if (parser->body_index == 1U) {
    3964:	00100793          	li	a5,1
    3968:	00f70a63          	beq	a4,a5,397c <frame_parser_feed+0x108>
        } else if (parser->body_index == 2U) {
    396c:	00200793          	li	a5,2
    3970:	fcf718e3          	bne	a4,a5,3940 <frame_parser_feed+0xcc>
            parser->type = byte;
    3974:	00940623          	sb	s1,12(s0)
    3978:	fc9ff06f          	j	3940 <frame_parser_feed+0xcc>
            parser->command = byte;
    397c:	009405a3          	sb	s1,11(s0)
    3980:	fc1ff06f          	j	3940 <frame_parser_feed+0xcc>
            parser->state = ST_CRC_H;
    3984:	00400793          	li	a5,4
    3988:	00f40023          	sb	a5,0(s0)
        return 0;
    398c:	00000513          	li	a0,0
    3990:	0bc0006f          	j	3a4c <frame_parser_feed+0x1d8>

    /* --- CRC 高字节 --- */
    case ST_CRC_H:
        parser->recv_crc = (uint16_t)byte << 8;
    3994:	00859593          	slli	a1,a1,0x8
    3998:	00b51423          	sh	a1,8(a0)
        parser->state = ST_CRC_L;
    399c:	00500793          	li	a5,5
    39a0:	00f50023          	sb	a5,0(a0)
        return 0;
    39a4:	00000513          	li	a0,0
    39a8:	0a40006f          	j	3a4c <frame_parser_feed+0x1d8>

    /* --- CRC 低字节：凑成完整 CRC，转去收帧尾 --- */
    case ST_CRC_L:
        parser->recv_crc |= (uint16_t)byte;
    39ac:	00855783          	lhu	a5,8(a0)
    39b0:	00f5e7b3          	or	a5,a1,a5
    39b4:	00f51423          	sh	a5,8(a0)
        parser->state = ST_FOOTER;
    39b8:	00600793          	li	a5,6
    39bc:	00f50023          	sb	a5,0(a0)
        return 0;
    39c0:	00000513          	li	a0,0
    39c4:	0880006f          	j	3a4c <frame_parser_feed+0x1d8>
    default:
        /* default 和 ST_FOOTER 走同一段代码，是防御性写法：万一 state 被
         * 内存踩坏成了非法值，也只会当成"帧尾"处理并立即复位回 ST_HEADER，
         * 不会卡死在非法状态里。*/

        out->category    = parser->category;
    39c8:	00a54783          	lbu	a5,10(a0)
    39cc:	00f60023          	sb	a5,0(a2)
        out->command     = parser->command;
    39d0:	00b54783          	lbu	a5,11(a0)
    39d4:	00f600a3          	sb	a5,1(a2)
        out->type        = parser->type;
    39d8:	00c54783          	lbu	a5,12(a0)
    39dc:	00f60123          	sb	a5,2(a2)
        out->body_length = parser->body_length;
    39e0:	00255783          	lhu	a5,2(a0)
    39e4:	00f61223          	sh	a5,4(a2)

        /* 三个布尔标志都写成 `? 1U : 0U` 而不是直接赋值比较表达式的结果。
         * 因为 C 里比较运算符的结果是 int 类型的 1/0，直接赋给 uint8_t 字段
         * 虽然没问题，但显式写出来能保证字段里只可能是 0 或 1。*/
        out->crc_ok      = (parser->recv_crc == parser->body_crc) ? 1U : 0U;
    39e8:	00855703          	lhu	a4,8(a0)
    39ec:	00655783          	lhu	a5,6(a0)
    39f0:	02f70c63          	beq	a4,a5,3a28 <frame_parser_feed+0x1b4>
    39f4:	00000793          	li	a5,0
    39f8:	00f60323          	sb	a5,6(a2)
        out->footer_ok   = (byte == FRAME_FOOTER) ? 1U : 0U;
    39fc:	0aa00793          	li	a5,170
    3a00:	02f48863          	beq	s1,a5,3a30 <frame_parser_feed+0x1bc>
    3a04:	00000793          	li	a5,0
    3a08:	00f603a3          	sb	a5,7(a2)
        /* 格式校验只有这一条：命令帧的类型必须是"上位机写"。
         * 大类**不在这里校验**——它是路由字段，变倍/热点/UI 的大类都是合法的，
         * 只是不该由本应用处理（在上层分流）。*/
        out->format_ok   = (parser->type == FRAME_TYPE_WRITE) ? 1U : 0U;
    3a0c:	00c44783          	lbu	a5,12(s0)
    3a10:	02079463          	bnez	a5,3a38 <frame_parser_feed+0x1c4>
    3a14:	00100793          	li	a5,1
    3a18:	00f60423          	sb	a5,8(a2)

        /* 无论这一帧是好是坏，解析器都回到等帧头，准备接下一帧。
         * 这样"坏帧"不会让解析器停摆——上位机可以继续发下一条命令。*/
        parser->state = ST_HEADER;
    3a1c:	00040023          	sb	zero,0(s0)
        return 1;
    3a20:	00100513          	li	a0,1
    3a24:	0280006f          	j	3a4c <frame_parser_feed+0x1d8>
        out->crc_ok      = (parser->recv_crc == parser->body_crc) ? 1U : 0U;
    3a28:	00100793          	li	a5,1
    3a2c:	fcdff06f          	j	39f8 <frame_parser_feed+0x184>
        out->footer_ok   = (byte == FRAME_FOOTER) ? 1U : 0U;
    3a30:	00100793          	li	a5,1
    3a34:	fd5ff06f          	j	3a08 <frame_parser_feed+0x194>
        out->format_ok   = (parser->type == FRAME_TYPE_WRITE) ? 1U : 0U;
    3a38:	00000793          	li	a5,0
    3a3c:	fddff06f          	j	3a18 <frame_parser_feed+0x1a4>
        return 0;
    3a40:	00000513          	li	a0,0
    }
}
    3a44:	00008067          	ret
        return 0;
    3a48:	00000513          	li	a0,0
}
    3a4c:	00c12083          	lw	ra,12(sp)
    3a50:	00812403          	lw	s0,8(sp)
    3a54:	00412483          	lw	s1,4(sp)
    3a58:	01010113          	addi	sp,sp,16
    3a5c:	00008067          	ret

00003a60 <uart_writeAvailability>:
        return *((volatile u32*) address);
    3a60:	00452503          	lw	a0,4(a0)
        return (read_u32(reg + UART_STATUS) >> 16) & 0xFF;
    3a64:	01055513          	srli	a0,a0,0x10
    }
    3a68:	0ff57513          	zext.b	a0,a0
    3a6c:	00008067          	ret

00003a70 <uart_readOccupancy>:
    3a70:	00452503          	lw	a0,4(a0)
    }
    3a74:	01855513          	srli	a0,a0,0x18
    3a78:	00008067          	ret

00003a7c <uart_read>:
    static char uart_read(u32 reg){
    3a7c:	ff010113          	addi	sp,sp,-16
    3a80:	00112623          	sw	ra,12(sp)
    3a84:	00812423          	sw	s0,8(sp)
    3a88:	00050413          	mv	s0,a0
        while(uart_readOccupancy(reg) == 0);
    3a8c:	00040513          	mv	a0,s0
    3a90:	fe1ff0ef          	jal	3a70 <uart_readOccupancy>
    3a94:	fe050ce3          	beqz	a0,3a8c <uart_read+0x10>
    3a98:	00042503          	lw	a0,0(s0)
    }
    3a9c:	0ff57513          	zext.b	a0,a0
    3aa0:	00c12083          	lw	ra,12(sp)
    3aa4:	00812403          	lw	s0,8(sp)
    3aa8:	01010113          	addi	sp,sp,16
    3aac:	00008067          	ret

00003ab0 <uart_applyConfig>:
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
    3ab0:	00c5a783          	lw	a5,12(a1)
        *((volatile u32*) address) = data;
    3ab4:	00f52423          	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
    3ab8:	0005a783          	lw	a5,0(a1)
    3abc:	fff78793          	addi	a5,a5,-1
    3ac0:	0045a703          	lw	a4,4(a1)
    3ac4:	00871713          	slli	a4,a4,0x8
    3ac8:	00e7e7b3          	or	a5,a5,a4
    3acc:	0085a703          	lw	a4,8(a1)
    3ad0:	01071713          	slli	a4,a4,0x10
    3ad4:	00e7e7b3          	or	a5,a5,a4
    3ad8:	00f52623          	sw	a5,12(a0)
    }
    3adc:	00008067          	ret

00003ae0 <uart_status_read>:
        return *((volatile u32*) address);
    3ae0:	00452503          	lw	a0,4(a0)
*
******************************************************************************/    
    static u32 uart_status_read(u32 reg)
     {
    	 return read_u32(reg+UART_STATUS);
     }
    3ae4:	00008067          	ret

00003ae8 <uart_status_write>:
        *((volatile u32*) address) = data;
    3ae8:	00b52223          	sw	a1,4(a0)
*
******************************************************************************/
    static void uart_status_write(u32 reg, char data)
    {
    	write_u32(data ,reg+UART_STATUS);
    }
    3aec:	00008067          	ret

00003af0 <uart_RX_NotemptyInterruptEna>:
*          clears the second least significant bit to disable the RX not empty interrupt,
*          or sets it to enable the RX not empty interrupt based on the provided flag,
*          and then writes the modified value back to the UART status register.
*
******************************************************************************/
    static void uart_RX_NotemptyInterruptEna(u32 reg, char Ena){
    3af0:	ff010113          	addi	sp,sp,-16
    3af4:	00112623          	sw	ra,12(sp)
    3af8:	00812423          	sw	s0,8(sp)
    3afc:	00912223          	sw	s1,4(sp)
    3b00:	00050493          	mv	s1,a0
    3b04:	00058413          	mv	s0,a1
    	uart_status_write(reg,(uart_status_read(reg) & 0xFFFFFFFD) | (Ena << 1));	
    3b08:	fd9ff0ef          	jal	3ae0 <uart_status_read>
    3b0c:	0fd57593          	andi	a1,a0,253
    3b10:	00141413          	slli	s0,s0,0x1
    3b14:	0ff47413          	zext.b	s0,s0
    3b18:	0085e5b3          	or	a1,a1,s0
    3b1c:	00048513          	mv	a0,s1
    3b20:	fc9ff0ef          	jal	3ae8 <uart_status_write>
    }
    3b24:	00c12083          	lw	ra,12(sp)
    3b28:	00812403          	lw	s0,8(sp)
    3b2c:	00412483          	lw	s1,4(sp)
    3b30:	01010113          	addi	sp,sp,16
    3b34:	00008067          	ret

00003b38 <plic_set_priority>:
        write_u32(priority, plic + PLIC_PRIORITY_BASE + gateway*4);
    3b38:	00259593          	slli	a1,a1,0x2
    3b3c:	00a585b3          	add	a1,a1,a0
    3b40:	00c5a023          	sw	a2,0(a1)
    }
    3b44:	00008067          	ret

00003b48 <plic_set_enable>:
        u32 word = plic + PLIC_ENABLE_BASE + target * PLIC_ENABLE_PER_HART + (gateway / 32 * 4);
    3b48:	00759593          	slli	a1,a1,0x7
    3b4c:	00a585b3          	add	a1,a1,a0
    3b50:	00565793          	srli	a5,a2,0x5
    3b54:	00279793          	slli	a5,a5,0x2
    3b58:	00f587b3          	add	a5,a1,a5
    3b5c:	00002737          	lui	a4,0x2
    3b60:	00e787b3          	add	a5,a5,a4
        u32 mask = 1 << (gateway % 32);
    3b64:	00100713          	li	a4,1
    3b68:	00c71633          	sll	a2,a4,a2
        if (enable)
    3b6c:	00068a63          	beqz	a3,3b80 <plic_set_enable+0x38>
        return *((volatile u32*) address);
    3b70:	0007a703          	lw	a4,0(a5)
            write_u32(read_u32(word) | mask, word);
    3b74:	00e66633          	or	a2,a2,a4
        *((volatile u32*) address) = data;
    3b78:	00c7a023          	sw	a2,0(a5)
    }
    3b7c:	00008067          	ret
        return *((volatile u32*) address);
    3b80:	0007a703          	lw	a4,0(a5)
            write_u32(read_u32(word) & ~mask, word);
    3b84:	fff64613          	not	a2,a2
    3b88:	00e67633          	and	a2,a2,a4
        *((volatile u32*) address) = data;
    3b8c:	00c7a023          	sw	a2,0(a5)
    }
    3b90:	00008067          	ret

00003b94 <plic_set_threshold>:
        write_u32(threshold, plic + PLIC_THRESHOLD_BASE + target*PLIC_CONTEXT_PER_HART);
    3b94:	00c59593          	slli	a1,a1,0xc
    3b98:	00a585b3          	add	a1,a1,a0
    3b9c:	002007b7          	lui	a5,0x200
    3ba0:	00f585b3          	add	a1,a1,a5
    3ba4:	00c5a023          	sw	a2,0(a1)
    }
    3ba8:	00008067          	ret

00003bac <proto_uart_init>:
* @note 调用顺序上，本函数要在 isr_init() 之前调用（见 main.c）：先把中断源
*       配好，再全局开中断。反过来的话，开中断后到中断源配置好之间可能出现
*       一个"中断已使能但没有正确处理程序"的窗口。
******************************************************************************/
void proto_uart_init(void)
{
    3bac:	fe010113          	addi	sp,sp,-32
    3bb0:	00112e23          	sw	ra,28(sp)
    Uart_Config config;

    config.dataLength   = BITS_8;   /* 8 位数据 */
    3bb4:	00800793          	li	a5,8
    3bb8:	00f12023          	sw	a5,0(sp)
    config.parity       = NONE;     /* 无校验 */
    3bbc:	00012223          	sw	zero,4(sp)
    config.stop         = ONE;      /* 1 位停止位 */
    3bc0:	00012423          	sw	zero,8(sp)
    /* 分频系数 = 时钟频率 / (波特率 × 每字符位数) - 1
     * 这里的算式与 bsp.h 里 bsp_init() 的一字不差。*/
    config.clockDivider = BSP_CLINT_HZ / (BSP_UART_BAUDRATE * BSP_UART_DATA_LEN) - 1;
    3bc4:	03500793          	li	a5,53
    3bc8:	00f12623          	sw	a5,12(sp)

    uart_applyConfig(PROTO_UART_BASE, &config);
    3bcc:	00010593          	mv	a1,sp
    3bd0:	f8002537          	lui	a0,0xf8002
    3bd4:	eddff0ef          	jal	3ab0 <uart_applyConfig>

    /* 清空接收环和计数。*/
    s_head = 0U;
    3bd8:	9001a023          	sw	zero,-1792(gp) # 7828 <s_head>
    s_tail = 0U;
    3bdc:	8e01ae23          	sw	zero,-1796(gp) # 7824 <s_tail>
    s_dropped = 0U;
    3be0:	8e01ac23          	sw	zero,-1800(gp) # 7820 <s_dropped>
    s_fifo_overflow_seen = 0U;
    3be4:	9001a223          	sw	zero,-1788(gp) # 782c <s_fifo_overflow_seen>
    3be8:	f80027b7          	lui	a5,0xf8002
    3bec:	00200713          	li	a4,2
    3bf0:	00e7a823          	sw	a4,16(a5) # f8002010 <__freertos_irq_stack_top+0xf7ff9190>
    /* 上电时硬件里可能留有之前（比如复位前）的溢出标志，先清掉，
     * 否则第一份汇总就会报一个不属于本次运行的溢出。*/
    write_u32(UART_ERR_READ_OVERFLOW, PROTO_UART_BASE + UART_ERROR_REG);

    /* 使能"接收 FIFO 非空"中断：FIFO 里一有数据就产生中断。*/
    uart_RX_NotemptyInterruptEna(PROTO_UART_BASE, 1);
    3bf4:	00100593          	li	a1,1
    3bf8:	f8002537          	lui	a0,0xf8002
    3bfc:	ef5ff0ef          	jal	3af0 <uart_RX_NotemptyInterruptEna>

    /* 把该中断接到本核（CPU 0）上。
     * threshold = 0 表示"优先级高于 0 的中断都接受"，即全部接受。
     * 这三步（threshold / enable / priority）是 PLIC 的标准配置顺序。*/
    plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0);
    3c00:	00000613          	li	a2,0
    3c04:	00000593          	li	a1,0
    3c08:	f8c00537          	lui	a0,0xf8c00
    3c0c:	f89ff0ef          	jal	3b94 <plic_set_threshold>
    plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0,
    3c10:	00100693          	li	a3,1
    3c14:	00200613          	li	a2,2
    3c18:	00000593          	li	a1,0
    3c1c:	f8c00537          	lui	a0,0xf8c00
    3c20:	f29ff0ef          	jal	3b48 <plic_set_enable>
                    SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT, 1);
    plic_set_priority(BSP_PLIC, SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT, 1);
    3c24:	00100613          	li	a2,1
    3c28:	00200593          	li	a1,2
    3c2c:	f8c00537          	lui	a0,0xf8c00
    3c30:	f09ff0ef          	jal	3b38 <plic_set_priority>
}
    3c34:	01c12083          	lw	ra,28(sp)
    3c38:	02010113          	addi	sp,sp,32
    3c3c:	00008067          	ret

00003c40 <proto_uart_rx_pop>:
*       如果先推进指针再读数据，中断可能在这两步之间又写入了新字节，我们就会
*       读到下一个字节、把当前这个漏掉。
******************************************************************************/
int proto_uart_rx_pop(uint8_t *byte)
{
    if (s_head == s_tail) {
    3c40:	9001a703          	lw	a4,-1792(gp) # 7828 <s_head>
    3c44:	8fc1a783          	lw	a5,-1796(gp) # 7824 <s_tail>
    3c48:	02f70863          	beq	a4,a5,3c78 <proto_uart_rx_pop+0x38>
        return 0;              /* 环空 */
    }
    *byte = s_ring[s_tail];
    3c4c:	8fc1a683          	lw	a3,-1796(gp) # 7824 <s_tail>
    3c50:	d4c18793          	addi	a5,gp,-692 # 7c74 <s_ring>
    3c54:	00d787b3          	add	a5,a5,a3
    3c58:	0007c783          	lbu	a5,0(a5)
    3c5c:	00f50023          	sb	a5,0(a0) # f8c00000 <__freertos_irq_stack_top+0xf8bf7180>
    s_tail = (s_tail + 1U) & (PROTO_RX_RING_SIZE - 1U);
    3c60:	8fc1a783          	lw	a5,-1796(gp) # 7824 <s_tail>
    3c64:	00178793          	addi	a5,a5,1
    3c68:	1ff7f793          	andi	a5,a5,511
    3c6c:	8ef1ae23          	sw	a5,-1796(gp) # 7824 <s_tail>
    return 1;
    3c70:	00100513          	li	a0,1
    3c74:	00008067          	ret
        return 0;              /* 环空 */
    3c78:	00000513          	li	a0,0
}
    3c7c:	00008067          	ret

00003c80 <proto_uart_rx_dropped>:
/******************************************************************************
* @brief 因接收环满而丢弃的字节数。
******************************************************************************/
uint32_t proto_uart_rx_dropped(void)
{
    return s_dropped;
    3c80:	8f81a503          	lw	a0,-1800(gp) # 7820 <s_dropped>
}
    3c84:	00008067          	ret

00003c88 <proto_uart_fifo_overflow>:
        return *((volatile u32*) address);
    3c88:	f80027b7          	lui	a5,0xf8002
    3c8c:	01078793          	addi	a5,a5,16 # f8002010 <__freertos_irq_stack_top+0xf7ff9190>
    3c90:	0007a783          	lw	a5,0(a5)
******************************************************************************/
uint32_t proto_uart_fifo_overflow(void)
{
    uint32_t err = read_u32(PROTO_UART_BASE + UART_ERROR_REG);

    if ((err & UART_ERR_READ_OVERFLOW) != 0U) {
    3c94:	0027f793          	andi	a5,a5,2
    3c98:	00078e63          	beqz	a5,3cb4 <proto_uart_fifo_overflow+0x2c>
        s_fifo_overflow_seen++;
    3c9c:	9041a783          	lw	a5,-1788(gp) # 782c <s_fifo_overflow_seen>
    3ca0:	00178793          	addi	a5,a5,1
    3ca4:	90f1a223          	sw	a5,-1788(gp) # 782c <s_fifo_overflow_seen>
        *((volatile u32*) address) = data;
    3ca8:	f80027b7          	lui	a5,0xf8002
    3cac:	00200713          	li	a4,2
    3cb0:	00e7a823          	sw	a4,16(a5) # f8002010 <__freertos_irq_stack_top+0xf7ff9190>
        /* 写 1 清零（不是读-改-写：这个寄存器是"写 1 清除对应标志"的语义）。*/
        write_u32(UART_ERR_READ_OVERFLOW, PROTO_UART_BASE + UART_ERROR_REG);
    }
    return s_fifo_overflow_seen;
}
    3cb4:	9041a503          	lw	a0,-1788(gp) # 782c <s_fifo_overflow_seen>
    3cb8:	00008067          	ret

00003cbc <proto_uart_isr>:
*
* @note 中断服务程序里只做"搬字节"这一件事，不做解析、不做任何输出。
*       解析放在主循环（见 main.c），这样中断的执行时间恒定且极短。
******************************************************************************/
void proto_uart_isr(void)
{
    3cbc:	ff010113          	addi	sp,sp,-16
    3cc0:	00112623          	sw	ra,12(sp)
    uint32_t status;

    /* 第一步：读出状态寄存器，把"接收非空中断使能"这一位清掉（屏蔽中断源）。*/
    status = uart_status_read(PROTO_UART_BASE);
    3cc4:	f8002537          	lui	a0,0xf8002
    3cc8:	e19ff0ef          	jal	3ae0 <uart_status_read>
    uart_status_write(PROTO_UART_BASE,
    3ccc:	0fd57593          	andi	a1,a0,253
    3cd0:	f8002537          	lui	a0,0xf8002
    3cd4:	e15ff0ef          	jal	3ae8 <uart_status_write>
                      (char)(status & ~UART_STATUS_RX_NOTEMPTY_INT_EN));

    /* 第二步：把 FIFO 里现有的字节全部搬进接收环。*/
    while (uart_readOccupancy(PROTO_UART_BASE) != 0U) {
    3cd8:	0100006f          	j	3ce8 <proto_uart_isr+0x2c>
        uint32_t next = (s_head + 1U) & (PROTO_RX_RING_SIZE - 1U);

        if (next == s_tail) {
            /* 写指针再前进就会追上读指针，说明环满了。丢掉这个字节并计数。
             * 注意这里**不推进** s_head——推进了就等于覆盖掉还没被读走的数据。*/
            s_dropped++;
    3cdc:	8f81a783          	lw	a5,-1800(gp) # 7820 <s_dropped>
    3ce0:	00178793          	addi	a5,a5,1
    3ce4:	8ef1ac23          	sw	a5,-1800(gp) # 7820 <s_dropped>
    while (uart_readOccupancy(PROTO_UART_BASE) != 0U) {
    3ce8:	f8002537          	lui	a0,0xf8002
    3cec:	d85ff0ef          	jal	3a70 <uart_readOccupancy>
    3cf0:	02050c63          	beqz	a0,3d28 <proto_uart_isr+0x6c>
        uint8_t  b    = (uint8_t)uart_read(PROTO_UART_BASE);
    3cf4:	f8002537          	lui	a0,0xf8002
    3cf8:	d85ff0ef          	jal	3a7c <uart_read>
        uint32_t next = (s_head + 1U) & (PROTO_RX_RING_SIZE - 1U);
    3cfc:	9001a783          	lw	a5,-1792(gp) # 7828 <s_head>
    3d00:	00178793          	addi	a5,a5,1
    3d04:	1ff7f793          	andi	a5,a5,511
        if (next == s_tail) {
    3d08:	8fc1a703          	lw	a4,-1796(gp) # 7824 <s_tail>
    3d0c:	fcf708e3          	beq	a4,a5,3cdc <proto_uart_isr+0x20>
        } else {
            s_ring[s_head] = b;
    3d10:	9001a603          	lw	a2,-1792(gp) # 7828 <s_head>
    3d14:	d4c18713          	addi	a4,gp,-692 # 7c74 <s_ring>
    3d18:	00c70733          	add	a4,a4,a2
    3d1c:	00a70023          	sb	a0,0(a4) # 2000 <_ftoa+0x254>
            s_head = next;
    3d20:	90f1a023          	sw	a5,-1792(gp) # 7828 <s_head>
    3d24:	fc5ff06f          	j	3ce8 <proto_uart_isr+0x2c>
    /* 第三步：重新使能中断，准备接收下一批。
     * 重新读一次状态寄存器再置位，而不是直接用第一步读到的 status：
     * 因为排空过程中硬件可能改了状态寄存器里的其它位（比如溢出标志），
     * 用旧值回写会把这些变化抹掉。*/
    uart_status_write(PROTO_UART_BASE,
                      (char)(uart_status_read(PROTO_UART_BASE) |
    3d28:	f8002537          	lui	a0,0xf8002
    3d2c:	db5ff0ef          	jal	3ae0 <uart_status_read>
    uart_status_write(PROTO_UART_BASE,
    3d30:	00256593          	ori	a1,a0,2
    3d34:	0ff5f593          	zext.b	a1,a1
    3d38:	f8002537          	lui	a0,0xf8002
    3d3c:	dadff0ef          	jal	3ae8 <uart_status_write>
                             UART_STATUS_RX_NOTEMPTY_INT_EN));
}
    3d40:	00c12083          	lw	ra,12(sp)
    3d44:	01010113          	addi	sp,sp,16
    3d48:	00008067          	ret

00003d4c <proto_uart_write>:
int proto_uart_write(const uint8_t *data, uint32_t len)
{
    uint32_t i;
    uint32_t guard;

    if (data == 0) {
    3d4c:	06050663          	beqz	a0,3db8 <proto_uart_write+0x6c>
{
    3d50:	fe010113          	addi	sp,sp,-32
    3d54:	00112e23          	sw	ra,28(sp)
    3d58:	00812c23          	sw	s0,24(sp)
    3d5c:	00912a23          	sw	s1,20(sp)
    3d60:	01212823          	sw	s2,16(sp)
    3d64:	01312623          	sw	s3,12(sp)
    3d68:	00050913          	mv	s2,a0
    3d6c:	00058993          	mv	s3,a1
        return 0;
    }

    for (i = 0U; i < len; i++) {
    3d70:	00000493          	li	s1,0
    3d74:	0180006f          	j	3d8c <proto_uart_write+0x40>
            guard--;
        }
        /* 直接把字节写到 UART 的数据寄存器。用 write_u32（来自 driver/io.h）
         * 而不是给指针赋值，是为了沿用 driver 里统一的"内存映射寄存器访问"
         * 写法，将来若要加内存屏障之类只需改一处。*/
        write_u32(data[i], PROTO_UART_BASE + UART_DATA);
    3d78:	009907b3          	add	a5,s2,s1
    3d7c:	0007c703          	lbu	a4,0(a5)
    3d80:	f80027b7          	lui	a5,0xf8002
    3d84:	00e7a023          	sw	a4,0(a5) # f8002000 <__freertos_irq_stack_top+0xf7ff9180>
    for (i = 0U; i < len; i++) {
    3d88:	00148493          	addi	s1,s1,1
    3d8c:	0334f263          	bgeu	s1,s3,3db0 <proto_uart_write+0x64>
        guard = PROTO_TX_TIMEOUT_SPINS;
    3d90:	00018437          	lui	s0,0x18
    3d94:	6a040413          	addi	s0,s0,1696 # 186a0 <__freertos_irq_stack_top+0xf820>
        while (uart_writeAvailability(PROTO_UART_BASE) == 0U) {
    3d98:	f8002537          	lui	a0,0xf8002
    3d9c:	cc5ff0ef          	jal	3a60 <uart_writeAvailability>
    3da0:	fc051ce3          	bnez	a0,3d78 <proto_uart_write+0x2c>
            if (guard == 0U) {
    3da4:	00040e63          	beqz	s0,3dc0 <proto_uart_write+0x74>
            guard--;
    3da8:	fff40413          	addi	s0,s0,-1
    3dac:	fedff06f          	j	3d98 <proto_uart_write+0x4c>
    }
    return 1;
    3db0:	00100513          	li	a0,1
    3db4:	0100006f          	j	3dc4 <proto_uart_write+0x78>
        return 0;
    3db8:	00000513          	li	a0,0
}
    3dbc:	00008067          	ret
                return 0;   /* 等太久了，放弃这一帧的剩余部分 */
    3dc0:	00000513          	li	a0,0
}
    3dc4:	01c12083          	lw	ra,28(sp)
    3dc8:	01812403          	lw	s0,24(sp)
    3dcc:	01412483          	lw	s1,20(sp)
    3dd0:	01012903          	lw	s2,16(sp)
    3dd4:	00c12983          	lw	s3,12(sp)
    3dd8:	02010113          	addi	sp,sp,32
    3ddc:	00008067          	ret

00003de0 <crc16_ccitt_update>:
     * 会先"整型提升"成 int，左移 8 位后还是 int，直接和 uint16_t 异或虽然结果
     * 正确，但中间类型带符号、语义不清晰。显式转型让每一步的类型都一目了然。
     *
     * 最外层的 (uint16_t) 是为了把结果截断回 16 位。RTL 里 c 就是 16 位寄存器，
     * 溢出自然丢弃高位；C 里必须显式截断才能和 RTL 完全一致。*/
    uint16_t c = (uint16_t)(crc ^ (uint16_t)((uint16_t)data << 8));
    3de0:	00859593          	slli	a1,a1,0x8
    3de4:	00a5c533          	xor	a0,a1,a0
     *
     * 为什么不用查表法（预生成 256 项的表，一次处理一个字节）：
     * 查表要占 512 字节常量空间，而本模块的调用频率是"每个 body 字节一次"，
     * 在 115200 波特率下每秒最多一万多次，逐位法（每字节 8 次循环）绰绰有余。
     * 用一点 CPU 换掉 512 字节 Flash，对软核更划算。*/
    for (n = 0; n < 8; n++) {
    3de8:	00000793          	li	a5,0
    3dec:	0140006f          	j	3e00 <crc16_ccitt_update+0x20>
        if ((c & 0x8000U) != 0U) {
            /* 0x8000 就是只保留 bit15 的掩码。用 & 判断而不是写成 (c >> 15)，
             * 是为了和 RTL 的 c[15] 取值写法更贴近。*/
            c = (uint16_t)((uint16_t)(c << 1) ^ CRC16_CCITT_POLY);
        } else {
            c = (uint16_t)(c << 1);
    3df0:	00151513          	slli	a0,a0,0x1
    3df4:	01051513          	slli	a0,a0,0x10
    3df8:	01055513          	srli	a0,a0,0x10
    for (n = 0; n < 8; n++) {
    3dfc:	00178793          	addi	a5,a5,1
    3e00:	00700713          	li	a4,7
    3e04:	02f74663          	blt	a4,a5,3e30 <crc16_ccitt_update+0x50>
        if ((c & 0x8000U) != 0U) {
    3e08:	01051713          	slli	a4,a0,0x10
    3e0c:	41075713          	srai	a4,a4,0x10
    3e10:	fe0750e3          	bgez	a4,3df0 <crc16_ccitt_update+0x10>
            c = (uint16_t)((uint16_t)(c << 1) ^ CRC16_CCITT_POLY);
    3e14:	00151513          	slli	a0,a0,0x1
    3e18:	01051513          	slli	a0,a0,0x10
    3e1c:	01055513          	srli	a0,a0,0x10
    3e20:	00001737          	lui	a4,0x1
    3e24:	02170713          	addi	a4,a4,33 # 1021 <smp_slave+0xd>
    3e28:	00e54533          	xor	a0,a0,a4
    3e2c:	fd1ff06f          	j	3dfc <crc16_ccitt_update+0x1c>
        }
    }
    return c;
}
    3e30:	00008067          	ret

00003e34 <handler_not_implemented>:
******************************************************************************/
static uint8_t handler_not_implemented(const frame_t *frame)
{
    (void)frame;
    return PROTOCOL_STATUS_FAIL;
}
    3e34:	00000513          	li	a0,0
    3e38:	00008067          	ret

00003e3c <table_lookup>:
******************************************************************************/
static const protocol_entry_t *table_lookup(uint8_t command)
{
    uint32_t i;

    for (i = 0U; i < TABLE_ENTRIES; i++) {
    3e3c:	00000713          	li	a4,0
    3e40:	00400793          	li	a5,4
    3e44:	02e7ea63          	bltu	a5,a4,3e78 <table_lookup+0x3c>
        if (s_table[i].command == command) {
    3e48:	000077b7          	lui	a5,0x7
    3e4c:	00471693          	slli	a3,a4,0x4
    3e50:	5a478793          	addi	a5,a5,1444 # 75a4 <s_table>
    3e54:	00d787b3          	add	a5,a5,a3
    3e58:	0007c783          	lbu	a5,0(a5)
    3e5c:	00a78663          	beq	a5,a0,3e68 <table_lookup+0x2c>
    for (i = 0U; i < TABLE_ENTRIES; i++) {
    3e60:	00170713          	addi	a4,a4,1
    3e64:	fddff06f          	j	3e40 <table_lookup+0x4>
            return &s_table[i];
    3e68:	000077b7          	lui	a5,0x7
    3e6c:	5a478793          	addi	a5,a5,1444 # 75a4 <s_table>
    3e70:	00f68533          	add	a0,a3,a5
    3e74:	00008067          	ret
        }
    }
    return 0;
    3e78:	00000513          	li	a0,0
}
    3e7c:	00008067          	ret

00003e80 <entry_length_ok>:
* @param body_length 帧里声明的 body 长度。
* @return 1 表示相符。
******************************************************************************/
static int entry_length_ok(const protocol_entry_t *entry, uint16_t body_length)
{
    if (entry->body_length == LEN_ANY) {
    3e80:	00255783          	lhu	a5,2(a0) # f8002002 <__freertos_irq_stack_top+0xf7ff9182>
    3e84:	00010737          	lui	a4,0x10
    3e88:	fff70713          	addi	a4,a4,-1 # ffff <__freertos_irq_stack_top+0x717f>
    3e8c:	00e78863          	beq	a5,a4,3e9c <entry_length_ok+0x1c>
        return (body_length >= entry->min_length) ? 1 : 0;
    }
    return (body_length == entry->body_length) ? 1 : 0;
    3e90:	40b78533          	sub	a0,a5,a1
    3e94:	00153513          	seqz	a0,a0
}
    3e98:	00008067          	ret
        return (body_length >= entry->min_length) ? 1 : 0;
    3e9c:	00455503          	lhu	a0,4(a0)
    3ea0:	00a5b5b3          	sltu	a1,a1,a0
    3ea4:	0015b513          	seqz	a0,a1
    3ea8:	00008067          	ret

00003eac <protocol_init>:
*
* @param stats 统计结构，允许为空。
******************************************************************************/
void protocol_init(protocol_stats_t *stats)
{
    if (stats == 0) {
    3eac:	00050863          	beqz	a0,3ebc <protocol_init+0x10>
        return;
    }
    stats->accepted_count = 0U;
    3eb0:	00052023          	sw	zero,0(a0)
    stats->bad_packet_count = 0U;
    3eb4:	00052223          	sw	zero,4(a0)
    stats->other_category_count = 0U;
    3eb8:	00052423          	sw	zero,8(a0)
}
    3ebc:	00008067          	ret

00003ec0 <protocol_build_ack>:
void protocol_build_ack(uint8_t *ack, uint8_t category, uint8_t command,
                        uint8_t status)
{
    uint16_t crc = 0U;

    if (ack == 0) {
    3ec0:	0a050263          	beqz	a0,3f64 <protocol_build_ack+0xa4>
{
    3ec4:	fe010113          	addi	sp,sp,-32
    3ec8:	00112e23          	sw	ra,28(sp)
    3ecc:	00812c23          	sw	s0,24(sp)
    3ed0:	00912a23          	sw	s1,20(sp)
    3ed4:	01212823          	sw	s2,16(sp)
    3ed8:	01312623          	sw	s3,12(sp)
    3edc:	00050413          	mv	s0,a0
    3ee0:	00058993          	mv	s3,a1
    3ee4:	00060913          	mv	s2,a2
    3ee8:	00068493          	mv	s1,a3
        return;
    }

    crc = crc16_ccitt_update(crc, category);
    3eec:	00000513          	li	a0,0
    3ef0:	ef1ff0ef          	jal	3de0 <crc16_ccitt_update>
    crc = crc16_ccitt_update(crc, command);
    3ef4:	00090593          	mv	a1,s2
    3ef8:	ee9ff0ef          	jal	3de0 <crc16_ccitt_update>
    crc = crc16_ccitt_update(crc, PROTOCOL_ACK_TYPE);
    3efc:	00200593          	li	a1,2
    3f00:	ee1ff0ef          	jal	3de0 <crc16_ccitt_update>
    crc = crc16_ccitt_update(crc, status);
    3f04:	00048593          	mv	a1,s1
    3f08:	ed9ff0ef          	jal	3de0 <crc16_ccitt_update>

    ack[0] = FRAME_HEADER;              /* 帧头 0xBB */
    3f0c:	fbb00793          	li	a5,-69
    3f10:	00f40023          	sb	a5,0(s0)
    ack[1] = 0x00U;                     /* body_length 高字节 */
    3f14:	000400a3          	sb	zero,1(s0)
    ack[2] = 0x04U;                     /* body_length 低字节，应答体固定 4 字节 */
    3f18:	00400793          	li	a5,4
    3f1c:	00f40123          	sb	a5,2(s0)
    ack[3] = category;                  /* 应答体第 0 字节：回显大类 */
    3f20:	013401a3          	sb	s3,3(s0)
    ack[4] = command;                   /* 应答体第 1 字节：回显子项 */
    3f24:	01240223          	sb	s2,4(s0)
    ack[5] = PROTOCOL_ACK_TYPE;         /* 应答体第 2 字节：0x02 表示应答 */
    3f28:	00200793          	li	a5,2
    3f2c:	00f402a3          	sb	a5,5(s0)
    ack[6] = status;                    /* 应答体第 3 字节 */
    3f30:	00940323          	sb	s1,6(s0)
    ack[7] = (uint8_t)(crc >> 8);       /* CRC 高字节 */
    3f34:	00855793          	srli	a5,a0,0x8
    3f38:	00f403a3          	sb	a5,7(s0)
    ack[8] = (uint8_t)(crc & 0xFFU);    /* CRC 低字节 */
    3f3c:	00a40423          	sb	a0,8(s0)
    ack[9] = FRAME_FOOTER;              /* 帧尾 0xAA */
    3f40:	faa00793          	li	a5,-86
    3f44:	00f404a3          	sb	a5,9(s0)
}
    3f48:	01c12083          	lw	ra,28(sp)
    3f4c:	01812403          	lw	s0,24(sp)
    3f50:	01412483          	lw	s1,20(sp)
    3f54:	01012903          	lw	s2,16(sp)
    3f58:	00c12983          	lw	s3,12(sp)
    3f5c:	02010113          	addi	sp,sp,32
    3f60:	00008067          	ret
    3f64:	00008067          	ret

00003f68 <protocol_handle>:
void protocol_handle(protocol_stats_t *stats, const frame_t *frame,
                     protocol_response_t *response)
{
    const protocol_entry_t *entry;

    if ((stats == 0) || (frame == 0) || (response == 0)) {
    3f68:	16050a63          	beqz	a0,40dc <protocol_handle+0x174>
{
    3f6c:	fe010113          	addi	sp,sp,-32
    3f70:	00112e23          	sw	ra,28(sp)
    3f74:	00812c23          	sw	s0,24(sp)
    3f78:	00912a23          	sw	s1,20(sp)
    3f7c:	01212823          	sw	s2,16(sp)
    3f80:	00050913          	mv	s2,a0
    3f84:	00058493          	mv	s1,a1
    3f88:	00060413          	mv	s0,a2
    if ((stats == 0) || (frame == 0) || (response == 0)) {
    3f8c:	08058263          	beqz	a1,4010 <protocol_handle+0xa8>
    3f90:	08060063          	beqz	a2,4010 <protocol_handle+0xa8>
    }

    /* 先给出默认结论：不发应答、失败、子项名未知。
     * 先把"最保守的默认值"铺好，后面每个分支只需要覆盖它要改的字段，
     * 这样就不会出现"某个分支漏填了某字段、结果带着上一次的残留值发出去"。*/
    response->send_ack = 0;
    3f94:	00060523          	sb	zero,10(a2)
    response->status = PROTOCOL_STATUS_FAIL;
    3f98:	000605a3          	sb	zero,11(a2)
    response->reason = PROTO_REASON_BAD_INTEGRITY;
    3f9c:	00200793          	li	a5,2
    3fa0:	00f62623          	sw	a5,12(a2)
    response->command_name = "?";
    3fa4:	000077b7          	lui	a5,0x7
    3fa8:	2cc78793          	addi	a5,a5,716 # 72cc <_data+0x274>
    3fac:	00f62823          	sw	a5,16(a2)

    /* 第 1 关：完整性。CRC 或帧尾任一不对，就认为帧被破坏了。
     * 不应答——理由见函数头。*/
    if ((frame->crc_ok == 0U) || (frame->footer_ok == 0U)) {
    3fb0:	0065c783          	lbu	a5,6(a1)
    3fb4:	04078863          	beqz	a5,4004 <protocol_handle+0x9c>
    3fb8:	0075c783          	lbu	a5,7(a1)
    3fbc:	04078463          	beqz	a5,4004 <protocol_handle+0x9c>
    }

    /* 第 2 关：大类。不是掩膜就说明这一帧属于别的功能模块（电子变倍 0x01、
     * 热点 0x02、伪彩色 0x03、UI 0x04），本端点既不该执行也不该应答。
     * 只记一笔"收到过其它大类的帧"，便于诊断链路上都有谁在说话。*/
    if (frame->category != FRAME_CATEGORY_MASK) {
    3fc0:	0005c783          	lbu	a5,0(a1)
    3fc4:	06079263          	bnez	a5,4028 <protocol_handle+0xc0>
        stats->other_category_count++;
        return;
    }

    /* 从这一步起，帧确定是本端点（掩膜）的了：**每一个都会得到应答**。*/
    response->send_ack = 1;
    3fc8:	00100793          	li	a5,1
    3fcc:	00f60523          	sb	a5,10(a2)

    /* 第 3 关：类型字段必须是"上位机写"。*/
    if (frame->format_ok == 0U) {
    3fd0:	0085c783          	lbu	a5,8(a1)
    3fd4:	06079663          	bnez	a5,4040 <protocol_handle+0xd8>
        response->reason = PROTO_REASON_BAD_FORMAT;
    3fd8:	00300793          	li	a5,3
    3fdc:	00f62623          	sw	a5,12(a2)
        stats->bad_packet_count++;
    3fe0:	00452783          	lw	a5,4(a0)
    3fe4:	00178793          	addi	a5,a5,1
    3fe8:	00f52223          	sw	a5,4(a0)
        }
    }

    /* 构造应答。只有走到这里（大类是掩膜、完整性通过）才需要发。
     * 大类和子项原样回显，这样上位机能按自己发过的命令去核对。*/
    protocol_build_ack(response->ack, frame->category, frame->command,
    3fec:	00b44683          	lbu	a3,11(s0)
    3ff0:	0014c603          	lbu	a2,1(s1)
    3ff4:	0004c583          	lbu	a1,0(s1)
    3ff8:	00040513          	mv	a0,s0
    3ffc:	ec5ff0ef          	jal	3ec0 <protocol_build_ack>
    4000:	0100006f          	j	4010 <protocol_handle+0xa8>
        stats->bad_packet_count++;
    4004:	00492783          	lw	a5,4(s2)
    4008:	00178793          	addi	a5,a5,1
    400c:	00f92223          	sw	a5,4(s2)
                       response->status);
}
    4010:	01c12083          	lw	ra,28(sp)
    4014:	01812403          	lw	s0,24(sp)
    4018:	01412483          	lw	s1,20(sp)
    401c:	01012903          	lw	s2,16(sp)
    4020:	02010113          	addi	sp,sp,32
    4024:	00008067          	ret
        response->reason = PROTO_REASON_OTHER_CATEGORY;
    4028:	00100793          	li	a5,1
    402c:	00f62623          	sw	a5,12(a2)
        stats->other_category_count++;
    4030:	00852783          	lw	a5,8(a0)
    4034:	00178793          	addi	a5,a5,1
    4038:	00f52423          	sw	a5,8(a0)
        return;
    403c:	fd5ff06f          	j	4010 <protocol_handle+0xa8>
    4040:	01312623          	sw	s3,12(sp)
        entry = table_lookup(frame->command);
    4044:	0015c503          	lbu	a0,1(a1)
    4048:	df5ff0ef          	jal	3e3c <table_lookup>
    404c:	00050993          	mv	s3,a0
        if (entry == 0) {
    4050:	02050a63          	beqz	a0,4084 <protocol_handle+0x11c>
            response->command_name = entry->name;
    4054:	00852783          	lw	a5,8(a0)
    4058:	00f42823          	sw	a5,16(s0)
            if (entry_length_ok(entry, frame->body_length) == 0) {
    405c:	0044d583          	lhu	a1,4(s1)
    4060:	e21ff0ef          	jal	3e80 <entry_length_ok>
    4064:	02051e63          	bnez	a0,40a0 <protocol_handle+0x138>
                response->reason = PROTO_REASON_BAD_LENGTH;
    4068:	00500793          	li	a5,5
    406c:	00f42623          	sw	a5,12(s0)
                stats->bad_packet_count++;
    4070:	00492783          	lw	a5,4(s2)
    4074:	00178793          	addi	a5,a5,1
    4078:	00f92223          	sw	a5,4(s2)
    407c:	00c12983          	lw	s3,12(sp)
    4080:	f6dff06f          	j	3fec <protocol_handle+0x84>
            response->reason = PROTO_REASON_UNKNOWN_COMMAND;
    4084:	00400793          	li	a5,4
    4088:	00f42623          	sw	a5,12(s0)
            stats->bad_packet_count++;
    408c:	00492783          	lw	a5,4(s2)
    4090:	00178793          	addi	a5,a5,1
    4094:	00f92223          	sw	a5,4(s2)
    4098:	00c12983          	lw	s3,12(sp)
    409c:	f51ff06f          	j	3fec <protocol_handle+0x84>
                stats->accepted_count++;
    40a0:	00092783          	lw	a5,0(s2)
    40a4:	00178793          	addi	a5,a5,1
    40a8:	00f92023          	sw	a5,0(s2)
                response->status = entry->handler(frame);
    40ac:	00c9a783          	lw	a5,12(s3)
    40b0:	00048513          	mv	a0,s1
    40b4:	000780e7          	jalr	a5
    40b8:	00a405a3          	sb	a0,11(s0)
                                       : PROTO_REASON_NOT_IMPLEMENTED;
    40bc:	0ff00793          	li	a5,255
    40c0:	00f50a63          	beq	a0,a5,40d4 <protocol_handle+0x16c>
    40c4:	00600793          	li	a5,6
                response->reason = (response->status == PROTOCOL_STATUS_OK)
    40c8:	00f42623          	sw	a5,12(s0)
    40cc:	00c12983          	lw	s3,12(sp)
    40d0:	f1dff06f          	j	3fec <protocol_handle+0x84>
                                       : PROTO_REASON_NOT_IMPLEMENTED;
    40d4:	00000793          	li	a5,0
    40d8:	ff1ff06f          	j	40c8 <protocol_handle+0x160>
    40dc:	00008067          	ret

000040e0 <trap_entry>:

trap_entry:
#ifdef __riscv_flen
  addi sp, sp, -STACK_SIZE
#else
  addi sp, sp, -64
    40e0:	fc010113          	addi	sp,sp,-64
#endif
  sw x1,   0*4(sp)
    40e4:	00112023          	sw	ra,0(sp)
  sw x5,   1*4(sp)
    40e8:	00512223          	sw	t0,4(sp)
  sw x6,   2*4(sp)
    40ec:	00612423          	sw	t1,8(sp)
  sw x7,   3*4(sp)
    40f0:	00712623          	sw	t2,12(sp)
  sw x10,  4*4(sp)
    40f4:	00a12823          	sw	a0,16(sp)
  sw x11,  5*4(sp)
    40f8:	00b12a23          	sw	a1,20(sp)
  sw x12,  6*4(sp)
    40fc:	00c12c23          	sw	a2,24(sp)
  sw x13,  7*4(sp)
    4100:	00d12e23          	sw	a3,28(sp)
  sw x14,  8*4(sp)
    4104:	02e12023          	sw	a4,32(sp)
  sw x15,  9*4(sp)
    4108:	02f12223          	sw	a5,36(sp)
  sw x16, 10*4(sp)
    410c:	03012423          	sw	a6,40(sp)
  sw x17, 11*4(sp)
    4110:	03112623          	sw	a7,44(sp)
  sw x28, 12*4(sp)
    4114:	03c12823          	sw	t3,48(sp)
  sw x29, 13*4(sp)
    4118:	03d12a23          	sw	t4,52(sp)
  sw x30, 14*4(sp)
    411c:	03e12c23          	sw	t5,56(sp)
  sw x31, 15*4(sp)
    4120:	03f12e23          	sw	t6,60(sp)
  FSTORE f30, 64 + 18*FPR_SIZE(sp)
  FSTORE f31, 64 + 19*FPR_SIZE(sp)
  csrr t0, fcsr
  sw t0, 64 + 20*FPR_SIZE(sp)
#endif
  call trap
    4124:	e6cff0ef          	jal	3790 <trap>
  FLOAD f28, 64 + 16*FPR_SIZE(sp)
  FLOAD f29, 64 + 17*FPR_SIZE(sp)
  FLOAD f30, 64 + 18*FPR_SIZE(sp)
  FLOAD f31, 64 + 19*FPR_SIZE(sp)
#endif
  lw x1 ,  0*4(sp)
    4128:	00012083          	lw	ra,0(sp)
  lw x5,   1*4(sp)
    412c:	00412283          	lw	t0,4(sp)
  lw x6,   2*4(sp)
    4130:	00812303          	lw	t1,8(sp)
  lw x7,   3*4(sp)
    4134:	00c12383          	lw	t2,12(sp)
  lw x10,  4*4(sp)
    4138:	01012503          	lw	a0,16(sp)
  lw x11,  5*4(sp)
    413c:	01412583          	lw	a1,20(sp)
  lw x12,  6*4(sp)
    4140:	01812603          	lw	a2,24(sp)
  lw x13,  7*4(sp)
    4144:	01c12683          	lw	a3,28(sp)
  lw x14,  8*4(sp)
    4148:	02012703          	lw	a4,32(sp)
  lw x15,  9*4(sp)
    414c:	02412783          	lw	a5,36(sp)
  lw x16, 10*4(sp)
    4150:	02812803          	lw	a6,40(sp)
  lw x17, 11*4(sp)
    4154:	02c12883          	lw	a7,44(sp)
  lw x28, 12*4(sp)
    4158:	03012e03          	lw	t3,48(sp)
  lw x29, 13*4(sp)
    415c:	03412e83          	lw	t4,52(sp)
  lw x30, 14*4(sp)
    4160:	03812f03          	lw	t5,56(sp)
  lw x31, 15*4(sp)
    4164:	03c12f83          	lw	t6,60(sp)
#ifdef __riscv_flen
  addi sp, sp, STACK_SIZE
#else
  addi sp, sp, 64
    4168:	04010113          	addi	sp,sp,64
#endif
    416c:	30200073          	mret

00004170 <__udivdi3>:
    4170:	00060813          	mv	a6,a2
    4174:	00050893          	mv	a7,a0
    4178:	00058713          	mv	a4,a1
    417c:	0e069063          	bnez	a3,425c <__udivdi3+0xec>
    4180:	12c5fe63          	bgeu	a1,a2,42bc <__udivdi3+0x14c>
    4184:	000107b7          	lui	a5,0x10
    4188:	1ef66e63          	bltu	a2,a5,4384 <__udivdi3+0x214>
    418c:	010007b7          	lui	a5,0x1000
    4190:	01800693          	li	a3,24
    4194:	00f67463          	bgeu	a2,a5,419c <__udivdi3+0x2c>
    4198:	01000693          	li	a3,16
    419c:	00d65333          	srl	t1,a2,a3
    41a0:	00003797          	auipc	a5,0x3
    41a4:	49478793          	addi	a5,a5,1172 # 7634 <__clz_tab>
    41a8:	006787b3          	add	a5,a5,t1
    41ac:	0007c783          	lbu	a5,0(a5)
    41b0:	02000313          	li	t1,32
    41b4:	00d787b3          	add	a5,a5,a3
    41b8:	40f306b3          	sub	a3,t1,a5
    41bc:	00f30c63          	beq	t1,a5,41d4 <__udivdi3+0x64>
    41c0:	00d59733          	sll	a4,a1,a3
    41c4:	00f557b3          	srl	a5,a0,a5
    41c8:	00d61833          	sll	a6,a2,a3
    41cc:	00e7e733          	or	a4,a5,a4
    41d0:	00d518b3          	sll	a7,a0,a3
    41d4:	01085613          	srli	a2,a6,0x10
    41d8:	02c75533          	divu	a0,a4,a2
    41dc:	01081693          	slli	a3,a6,0x10
    41e0:	0106d693          	srli	a3,a3,0x10
    41e4:	0108d793          	srli	a5,a7,0x10
    41e8:	02c77733          	remu	a4,a4,a2
    41ec:	02a685b3          	mul	a1,a3,a0
    41f0:	01071713          	slli	a4,a4,0x10
    41f4:	00e7e7b3          	or	a5,a5,a4
    41f8:	00b7fc63          	bgeu	a5,a1,4210 <__udivdi3+0xa0>
    41fc:	00f807b3          	add	a5,a6,a5
    4200:	fff50713          	addi	a4,a0,-1
    4204:	0107e463          	bltu	a5,a6,420c <__udivdi3+0x9c>
    4208:	40b7e063          	bltu	a5,a1,4608 <__udivdi3+0x498>
    420c:	00070513          	mv	a0,a4
    4210:	40b787b3          	sub	a5,a5,a1
    4214:	02c7d733          	divu	a4,a5,a2
    4218:	01089893          	slli	a7,a7,0x10
    421c:	0108d893          	srli	a7,a7,0x10
    4220:	02c7f7b3          	remu	a5,a5,a2
    4224:	02e686b3          	mul	a3,a3,a4
    4228:	01079793          	slli	a5,a5,0x10
    422c:	00f8e8b3          	or	a7,a7,a5
    4230:	00d8fe63          	bgeu	a7,a3,424c <__udivdi3+0xdc>
    4234:	011808b3          	add	a7,a6,a7
    4238:	fff70793          	addi	a5,a4,-1
    423c:	0108e663          	bltu	a7,a6,4248 <__udivdi3+0xd8>
    4240:	ffe70713          	addi	a4,a4,-2
    4244:	00d8e463          	bltu	a7,a3,424c <__udivdi3+0xdc>
    4248:	00078713          	mv	a4,a5
    424c:	01051513          	slli	a0,a0,0x10
    4250:	00e56533          	or	a0,a0,a4
    4254:	00000593          	li	a1,0
    4258:	00008067          	ret
    425c:	00d5f863          	bgeu	a1,a3,426c <__udivdi3+0xfc>
    4260:	00000593          	li	a1,0
    4264:	00000513          	li	a0,0
    4268:	00008067          	ret
    426c:	000107b7          	lui	a5,0x10
    4270:	1ef6e863          	bltu	a3,a5,4460 <__udivdi3+0x2f0>
    4274:	01000737          	lui	a4,0x1000
    4278:	01800793          	li	a5,24
    427c:	00e6f463          	bgeu	a3,a4,4284 <__udivdi3+0x114>
    4280:	01000793          	li	a5,16
    4284:	00f6d833          	srl	a6,a3,a5
    4288:	00003717          	auipc	a4,0x3
    428c:	3ac70713          	addi	a4,a4,940 # 7634 <__clz_tab>
    4290:	01070733          	add	a4,a4,a6
    4294:	00074703          	lbu	a4,0(a4)
    4298:	02000893          	li	a7,32
    429c:	00f70733          	add	a4,a4,a5
    42a0:	40e88833          	sub	a6,a7,a4
    42a4:	1ee89663          	bne	a7,a4,4490 <__udivdi3+0x320>
    42a8:	32b6e463          	bltu	a3,a1,45d0 <__udivdi3+0x460>
    42ac:	00c53533          	sltu	a0,a0,a2
    42b0:	00153513          	seqz	a0,a0
    42b4:	00000593          	li	a1,0
    42b8:	00008067          	ret
    42bc:	0c060c63          	beqz	a2,4394 <__udivdi3+0x224>
    42c0:	000107b7          	lui	a5,0x10
    42c4:	2ef67c63          	bgeu	a2,a5,45bc <__udivdi3+0x44c>
    42c8:	10063713          	sltiu	a4,a2,256
    42cc:	00173713          	seqz	a4,a4
    42d0:	00371713          	slli	a4,a4,0x3
    42d4:	00e656b3          	srl	a3,a2,a4
    42d8:	00003797          	auipc	a5,0x3
    42dc:	35c78793          	addi	a5,a5,860 # 7634 <__clz_tab>
    42e0:	00d787b3          	add	a5,a5,a3
    42e4:	0007c783          	lbu	a5,0(a5)
    42e8:	02000693          	li	a3,32
    42ec:	00e787b3          	add	a5,a5,a4
    42f0:	40f68eb3          	sub	t4,a3,a5
    42f4:	0cf69463          	bne	a3,a5,43bc <__udivdi3+0x24c>
    42f8:	40c587b3          	sub	a5,a1,a2
    42fc:	01065693          	srli	a3,a2,0x10
    4300:	01061613          	slli	a2,a2,0x10
    4304:	01065613          	srli	a2,a2,0x10
    4308:	00100593          	li	a1,1
    430c:	02d7d533          	divu	a0,a5,a3
    4310:	0108d713          	srli	a4,a7,0x10
    4314:	02d7f7b3          	remu	a5,a5,a3
    4318:	02c50333          	mul	t1,a0,a2
    431c:	01079793          	slli	a5,a5,0x10
    4320:	00f767b3          	or	a5,a4,a5
    4324:	0067fc63          	bgeu	a5,t1,433c <__udivdi3+0x1cc>
    4328:	00f807b3          	add	a5,a6,a5
    432c:	fff50713          	addi	a4,a0,-1
    4330:	0107e463          	bltu	a5,a6,4338 <__udivdi3+0x1c8>
    4334:	2c67e463          	bltu	a5,t1,45fc <__udivdi3+0x48c>
    4338:	00070513          	mv	a0,a4
    433c:	406787b3          	sub	a5,a5,t1
    4340:	02d7d733          	divu	a4,a5,a3
    4344:	01089893          	slli	a7,a7,0x10
    4348:	0108d893          	srli	a7,a7,0x10
    434c:	02d7f7b3          	remu	a5,a5,a3
    4350:	02c70633          	mul	a2,a4,a2
    4354:	01079793          	slli	a5,a5,0x10
    4358:	00f8e8b3          	or	a7,a7,a5
    435c:	00c8fe63          	bgeu	a7,a2,4378 <__udivdi3+0x208>
    4360:	011808b3          	add	a7,a6,a7
    4364:	fff70793          	addi	a5,a4,-1
    4368:	0108e663          	bltu	a7,a6,4374 <__udivdi3+0x204>
    436c:	ffe70713          	addi	a4,a4,-2
    4370:	00c8e463          	bltu	a7,a2,4378 <__udivdi3+0x208>
    4374:	00078713          	mv	a4,a5
    4378:	01051513          	slli	a0,a0,0x10
    437c:	00e56533          	or	a0,a0,a4
    4380:	00008067          	ret
    4384:	10063693          	sltiu	a3,a2,256
    4388:	0016b693          	seqz	a3,a3
    438c:	00369693          	slli	a3,a3,0x3
    4390:	e0dff06f          	j	419c <__udivdi3+0x2c>
    4394:	00000693          	li	a3,0
    4398:	00003797          	auipc	a5,0x3
    439c:	29c78793          	addi	a5,a5,668 # 7634 <__clz_tab>
    43a0:	00d787b3          	add	a5,a5,a3
    43a4:	0007c783          	lbu	a5,0(a5)
    43a8:	00000713          	li	a4,0
    43ac:	02000693          	li	a3,32
    43b0:	00e787b3          	add	a5,a5,a4
    43b4:	40f68eb3          	sub	t4,a3,a5
    43b8:	f4f680e3          	beq	a3,a5,42f8 <__udivdi3+0x188>
    43bc:	01d61833          	sll	a6,a2,t4
    43c0:	00f5d333          	srl	t1,a1,a5
    43c4:	01085693          	srli	a3,a6,0x10
    43c8:	02d35e33          	divu	t3,t1,a3
    43cc:	01081613          	slli	a2,a6,0x10
    43d0:	01d595b3          	sll	a1,a1,t4
    43d4:	01065613          	srli	a2,a2,0x10
    43d8:	00f557b3          	srl	a5,a0,a5
    43dc:	00b7e7b3          	or	a5,a5,a1
    43e0:	0107d713          	srli	a4,a5,0x10
    43e4:	01d518b3          	sll	a7,a0,t4
    43e8:	02d37333          	remu	t1,t1,a3
    43ec:	03c605b3          	mul	a1,a2,t3
    43f0:	01031313          	slli	t1,t1,0x10
    43f4:	00676733          	or	a4,a4,t1
    43f8:	00b77e63          	bgeu	a4,a1,4414 <__udivdi3+0x2a4>
    43fc:	00e80733          	add	a4,a6,a4
    4400:	fffe0513          	addi	a0,t3,-1
    4404:	1f076463          	bltu	a4,a6,45ec <__udivdi3+0x47c>
    4408:	1eb77263          	bgeu	a4,a1,45ec <__udivdi3+0x47c>
    440c:	ffee0e13          	addi	t3,t3,-2
    4410:	01070733          	add	a4,a4,a6
    4414:	40b70733          	sub	a4,a4,a1
    4418:	02d75533          	divu	a0,a4,a3
    441c:	01079793          	slli	a5,a5,0x10
    4420:	0107d793          	srli	a5,a5,0x10
    4424:	02d77733          	remu	a4,a4,a3
    4428:	02a60333          	mul	t1,a2,a0
    442c:	01071713          	slli	a4,a4,0x10
    4430:	00e7e7b3          	or	a5,a5,a4
    4434:	0067fe63          	bgeu	a5,t1,4450 <__udivdi3+0x2e0>
    4438:	00f807b3          	add	a5,a6,a5
    443c:	fff50713          	addi	a4,a0,-1
    4440:	1907ee63          	bltu	a5,a6,45dc <__udivdi3+0x46c>
    4444:	1867fc63          	bgeu	a5,t1,45dc <__udivdi3+0x46c>
    4448:	ffe50513          	addi	a0,a0,-2
    444c:	010787b3          	add	a5,a5,a6
    4450:	010e1593          	slli	a1,t3,0x10
    4454:	406787b3          	sub	a5,a5,t1
    4458:	00a5e5b3          	or	a1,a1,a0
    445c:	eb1ff06f          	j	430c <__udivdi3+0x19c>
    4460:	1006b793          	sltiu	a5,a3,256
    4464:	0017b793          	seqz	a5,a5
    4468:	00379793          	slli	a5,a5,0x3
    446c:	00f6d833          	srl	a6,a3,a5
    4470:	00003717          	auipc	a4,0x3
    4474:	1c470713          	addi	a4,a4,452 # 7634 <__clz_tab>
    4478:	01070733          	add	a4,a4,a6
    447c:	00074703          	lbu	a4,0(a4)
    4480:	02000893          	li	a7,32
    4484:	00f70733          	add	a4,a4,a5
    4488:	40e88833          	sub	a6,a7,a4
    448c:	e0e88ee3          	beq	a7,a4,42a8 <__udivdi3+0x138>
    4490:	00e65e33          	srl	t3,a2,a4
    4494:	010696b3          	sll	a3,a3,a6
    4498:	00de6e33          	or	t3,t3,a3
    449c:	00e5d8b3          	srl	a7,a1,a4
    44a0:	010e5e93          	srli	t4,t3,0x10
    44a4:	03d8d7b3          	divu	a5,a7,t4
    44a8:	010e1313          	slli	t1,t3,0x10
    44ac:	010595b3          	sll	a1,a1,a6
    44b0:	01035313          	srli	t1,t1,0x10
    44b4:	00e55733          	srl	a4,a0,a4
    44b8:	00b76733          	or	a4,a4,a1
    44bc:	01075693          	srli	a3,a4,0x10
    44c0:	01061633          	sll	a2,a2,a6
    44c4:	03d8f8b3          	remu	a7,a7,t4
    44c8:	02f305b3          	mul	a1,t1,a5
    44cc:	01089893          	slli	a7,a7,0x10
    44d0:	0116e6b3          	or	a3,a3,a7
    44d4:	00b6fe63          	bgeu	a3,a1,44f0 <__udivdi3+0x380>
    44d8:	00de06b3          	add	a3,t3,a3
    44dc:	fff78893          	addi	a7,a5,-1
    44e0:	11c6ea63          	bltu	a3,t3,45f4 <__udivdi3+0x484>
    44e4:	10b6f863          	bgeu	a3,a1,45f4 <__udivdi3+0x484>
    44e8:	ffe78793          	addi	a5,a5,-2
    44ec:	01c686b3          	add	a3,a3,t3
    44f0:	40b686b3          	sub	a3,a3,a1
    44f4:	03d6d5b3          	divu	a1,a3,t4
    44f8:	01071713          	slli	a4,a4,0x10
    44fc:	01075713          	srli	a4,a4,0x10
    4500:	03d6f6b3          	remu	a3,a3,t4
    4504:	02b308b3          	mul	a7,t1,a1
    4508:	01069693          	slli	a3,a3,0x10
    450c:	00d76733          	or	a4,a4,a3
    4510:	01177e63          	bgeu	a4,a7,452c <__udivdi3+0x3bc>
    4514:	00ee0733          	add	a4,t3,a4
    4518:	fff58693          	addi	a3,a1,-1
    451c:	0dc76463          	bltu	a4,t3,45e4 <__udivdi3+0x474>
    4520:	0d177263          	bgeu	a4,a7,45e4 <__udivdi3+0x474>
    4524:	ffe58593          	addi	a1,a1,-2
    4528:	01c70733          	add	a4,a4,t3
    452c:	01079793          	slli	a5,a5,0x10
    4530:	00010eb7          	lui	t4,0x10
    4534:	00b7e7b3          	or	a5,a5,a1
    4538:	fffe8693          	addi	a3,t4,-1 # ffff <__freertos_irq_stack_top+0x717f>
    453c:	00d7f5b3          	and	a1,a5,a3
    4540:	0107d313          	srli	t1,a5,0x10
    4544:	00d676b3          	and	a3,a2,a3
    4548:	01065613          	srli	a2,a2,0x10
    454c:	02d58e33          	mul	t3,a1,a3
    4550:	41170733          	sub	a4,a4,a7
    4554:	02d306b3          	mul	a3,t1,a3
    4558:	010e5893          	srli	a7,t3,0x10
    455c:	02c585b3          	mul	a1,a1,a2
    4560:	00d585b3          	add	a1,a1,a3
    4564:	00b885b3          	add	a1,a7,a1
    4568:	02c30333          	mul	t1,t1,a2
    456c:	00d5f463          	bgeu	a1,a3,4574 <__udivdi3+0x404>
    4570:	01d30333          	add	t1,t1,t4
    4574:	0105d693          	srli	a3,a1,0x10
    4578:	006686b3          	add	a3,a3,t1
    457c:	02d76a63          	bltu	a4,a3,45b0 <__udivdi3+0x440>
    4580:	00d70863          	beq	a4,a3,4590 <__udivdi3+0x420>
    4584:	00078513          	mv	a0,a5
    4588:	00000593          	li	a1,0
    458c:	00008067          	ret
    4590:	000106b7          	lui	a3,0x10
    4594:	fff68693          	addi	a3,a3,-1 # ffff <__freertos_irq_stack_top+0x717f>
    4598:	00d5f733          	and	a4,a1,a3
    459c:	01071713          	slli	a4,a4,0x10
    45a0:	00de7e33          	and	t3,t3,a3
    45a4:	01051533          	sll	a0,a0,a6
    45a8:	01c70733          	add	a4,a4,t3
    45ac:	fce57ce3          	bgeu	a0,a4,4584 <__udivdi3+0x414>
    45b0:	fff78513          	addi	a0,a5,-1
    45b4:	00000593          	li	a1,0
    45b8:	00008067          	ret
    45bc:	010007b7          	lui	a5,0x1000
    45c0:	04f67a63          	bgeu	a2,a5,4614 <__udivdi3+0x4a4>
    45c4:	01065693          	srli	a3,a2,0x10
    45c8:	01000713          	li	a4,16
    45cc:	d0dff06f          	j	42d8 <__udivdi3+0x168>
    45d0:	00000593          	li	a1,0
    45d4:	00100513          	li	a0,1
    45d8:	00008067          	ret
    45dc:	00070513          	mv	a0,a4
    45e0:	e71ff06f          	j	4450 <__udivdi3+0x2e0>
    45e4:	00068593          	mv	a1,a3
    45e8:	f45ff06f          	j	452c <__udivdi3+0x3bc>
    45ec:	00050e13          	mv	t3,a0
    45f0:	e25ff06f          	j	4414 <__udivdi3+0x2a4>
    45f4:	00088793          	mv	a5,a7
    45f8:	ef9ff06f          	j	44f0 <__udivdi3+0x380>
    45fc:	ffe50513          	addi	a0,a0,-2
    4600:	010787b3          	add	a5,a5,a6
    4604:	d39ff06f          	j	433c <__udivdi3+0x1cc>
    4608:	ffe50513          	addi	a0,a0,-2
    460c:	010787b3          	add	a5,a5,a6
    4610:	c01ff06f          	j	4210 <__udivdi3+0xa0>
    4614:	01865693          	srli	a3,a2,0x18
    4618:	01800713          	li	a4,24
    461c:	cbdff06f          	j	42d8 <__udivdi3+0x168>

00004620 <__umoddi3>:
    4620:	00060813          	mv	a6,a2
    4624:	00050893          	mv	a7,a0
    4628:	00058793          	mv	a5,a1
    462c:	00058713          	mv	a4,a1
    4630:	0c069863          	bnez	a3,4700 <__umoddi3+0xe0>
    4634:	12c5fa63          	bgeu	a1,a2,4768 <__umoddi3+0x148>
    4638:	000107b7          	lui	a5,0x10
    463c:	1cf66c63          	bltu	a2,a5,4814 <__umoddi3+0x1f4>
    4640:	010007b7          	lui	a5,0x1000
    4644:	01800693          	li	a3,24
    4648:	00f67463          	bgeu	a2,a5,4650 <__umoddi3+0x30>
    464c:	01000693          	li	a3,16
    4650:	00d65333          	srl	t1,a2,a3
    4654:	00003797          	auipc	a5,0x3
    4658:	fe078793          	addi	a5,a5,-32 # 7634 <__clz_tab>
    465c:	006787b3          	add	a5,a5,t1
    4660:	0007c783          	lbu	a5,0(a5)
    4664:	02000313          	li	t1,32
    4668:	00d787b3          	add	a5,a5,a3
    466c:	40f306b3          	sub	a3,t1,a5
    4670:	00f30c63          	beq	t1,a5,4688 <__umoddi3+0x68>
    4674:	00d59733          	sll	a4,a1,a3
    4678:	00f557b3          	srl	a5,a0,a5
    467c:	00d61833          	sll	a6,a2,a3
    4680:	00e7e733          	or	a4,a5,a4
    4684:	00d518b3          	sll	a7,a0,a3
    4688:	01085593          	srli	a1,a6,0x10
    468c:	02b75633          	divu	a2,a4,a1
    4690:	01081313          	slli	t1,a6,0x10
    4694:	01035313          	srli	t1,t1,0x10
    4698:	0108d793          	srli	a5,a7,0x10
    469c:	02b77733          	remu	a4,a4,a1
    46a0:	02660633          	mul	a2,a2,t1
    46a4:	01071713          	slli	a4,a4,0x10
    46a8:	00e7e7b3          	or	a5,a5,a4
    46ac:	00c7f863          	bgeu	a5,a2,46bc <__umoddi3+0x9c>
    46b0:	00f807b3          	add	a5,a6,a5
    46b4:	0107e463          	bltu	a5,a6,46bc <__umoddi3+0x9c>
    46b8:	3cc7e263          	bltu	a5,a2,4a7c <__umoddi3+0x45c>
    46bc:	40c787b3          	sub	a5,a5,a2
    46c0:	02b7d733          	divu	a4,a5,a1
    46c4:	01089513          	slli	a0,a7,0x10
    46c8:	01055513          	srli	a0,a0,0x10
    46cc:	02b7f7b3          	remu	a5,a5,a1
    46d0:	02670733          	mul	a4,a4,t1
    46d4:	01079793          	slli	a5,a5,0x10
    46d8:	00f56533          	or	a0,a0,a5
    46dc:	00e57a63          	bgeu	a0,a4,46f0 <__umoddi3+0xd0>
    46e0:	00a80533          	add	a0,a6,a0
    46e4:	01056663          	bltu	a0,a6,46f0 <__umoddi3+0xd0>
    46e8:	00e57463          	bgeu	a0,a4,46f0 <__umoddi3+0xd0>
    46ec:	01050533          	add	a0,a0,a6
    46f0:	40e50533          	sub	a0,a0,a4
    46f4:	00d55533          	srl	a0,a0,a3
    46f8:	00000593          	li	a1,0
    46fc:	00008067          	ret
    4700:	00d5f463          	bgeu	a1,a3,4708 <__umoddi3+0xe8>
    4704:	00008067          	ret
    4708:	00010737          	lui	a4,0x10
    470c:	1ce6e663          	bltu	a3,a4,48d8 <__umoddi3+0x2b8>
    4710:	01000737          	lui	a4,0x1000
    4714:	01800813          	li	a6,24
    4718:	00e6f463          	bgeu	a3,a4,4720 <__umoddi3+0x100>
    471c:	01000813          	li	a6,16
    4720:	0106d333          	srl	t1,a3,a6
    4724:	00003717          	auipc	a4,0x3
    4728:	f1070713          	addi	a4,a4,-240 # 7634 <__clz_tab>
    472c:	00670733          	add	a4,a4,t1
    4730:	00074703          	lbu	a4,0(a4)
    4734:	02000313          	li	t1,32
    4738:	01070733          	add	a4,a4,a6
    473c:	40e30833          	sub	a6,t1,a4
    4740:	1ce31463          	bne	t1,a4,4908 <__umoddi3+0x2e8>
    4744:	00b6e463          	bltu	a3,a1,474c <__umoddi3+0x12c>
    4748:	00c56a63          	bltu	a0,a2,475c <__umoddi3+0x13c>
    474c:	40c508b3          	sub	a7,a0,a2
    4750:	40d586b3          	sub	a3,a1,a3
    4754:	011537b3          	sltu	a5,a0,a7
    4758:	40f687b3          	sub	a5,a3,a5
    475c:	00088513          	mv	a0,a7
    4760:	00078593          	mv	a1,a5
    4764:	00008067          	ret
    4768:	0a060e63          	beqz	a2,4824 <__umoddi3+0x204>
    476c:	000107b7          	lui	a5,0x10
    4770:	2ef67463          	bgeu	a2,a5,4a58 <__umoddi3+0x438>
    4774:	10063713          	sltiu	a4,a2,256
    4778:	00173713          	seqz	a4,a4
    477c:	00371713          	slli	a4,a4,0x3
    4780:	00e656b3          	srl	a3,a2,a4
    4784:	00003797          	auipc	a5,0x3
    4788:	eb078793          	addi	a5,a5,-336 # 7634 <__clz_tab>
    478c:	00d787b3          	add	a5,a5,a3
    4790:	0007c783          	lbu	a5,0(a5)
    4794:	02000313          	li	t1,32
    4798:	00e787b3          	add	a5,a5,a4
    479c:	40f306b3          	sub	a3,t1,a5
    47a0:	0af31663          	bne	t1,a5,484c <__umoddi3+0x22c>
    47a4:	40c58733          	sub	a4,a1,a2
    47a8:	01065313          	srli	t1,a2,0x10
    47ac:	01061613          	slli	a2,a2,0x10
    47b0:	01065613          	srli	a2,a2,0x10
    47b4:	026755b3          	divu	a1,a4,t1
    47b8:	0108d793          	srli	a5,a7,0x10
    47bc:	02677733          	remu	a4,a4,t1
    47c0:	02c585b3          	mul	a1,a1,a2
    47c4:	01071713          	slli	a4,a4,0x10
    47c8:	00e7e7b3          	or	a5,a5,a4
    47cc:	00b7fa63          	bgeu	a5,a1,47e0 <__umoddi3+0x1c0>
    47d0:	00f807b3          	add	a5,a6,a5
    47d4:	0107e663          	bltu	a5,a6,47e0 <__umoddi3+0x1c0>
    47d8:	00b7f463          	bgeu	a5,a1,47e0 <__umoddi3+0x1c0>
    47dc:	010787b3          	add	a5,a5,a6
    47e0:	40b787b3          	sub	a5,a5,a1
    47e4:	0267d733          	divu	a4,a5,t1
    47e8:	01089893          	slli	a7,a7,0x10
    47ec:	0108d893          	srli	a7,a7,0x10
    47f0:	0267f7b3          	remu	a5,a5,t1
    47f4:	02c70733          	mul	a4,a4,a2
    47f8:	01079513          	slli	a0,a5,0x10
    47fc:	00a8e533          	or	a0,a7,a0
    4800:	eee560e3          	bltu	a0,a4,46e0 <__umoddi3+0xc0>
    4804:	40e50533          	sub	a0,a0,a4
    4808:	00d55533          	srl	a0,a0,a3
    480c:	00000593          	li	a1,0
    4810:	00008067          	ret
    4814:	10063693          	sltiu	a3,a2,256
    4818:	0016b693          	seqz	a3,a3
    481c:	00369693          	slli	a3,a3,0x3
    4820:	e31ff06f          	j	4650 <__umoddi3+0x30>
    4824:	00000693          	li	a3,0
    4828:	00003797          	auipc	a5,0x3
    482c:	e0c78793          	addi	a5,a5,-500 # 7634 <__clz_tab>
    4830:	00d787b3          	add	a5,a5,a3
    4834:	0007c783          	lbu	a5,0(a5)
    4838:	00000713          	li	a4,0
    483c:	02000313          	li	t1,32
    4840:	00e787b3          	add	a5,a5,a4
    4844:	40f306b3          	sub	a3,t1,a5
    4848:	f4f30ee3          	beq	t1,a5,47a4 <__umoddi3+0x184>
    484c:	00d61833          	sll	a6,a2,a3
    4850:	00f5de33          	srl	t3,a1,a5
    4854:	01085313          	srli	t1,a6,0x10
    4858:	026e5eb3          	divu	t4,t3,t1
    485c:	01081613          	slli	a2,a6,0x10
    4860:	00d595b3          	sll	a1,a1,a3
    4864:	00f55733          	srl	a4,a0,a5
    4868:	01065613          	srli	a2,a2,0x10
    486c:	00b76733          	or	a4,a4,a1
    4870:	01075793          	srli	a5,a4,0x10
    4874:	00d518b3          	sll	a7,a0,a3
    4878:	026e7e33          	remu	t3,t3,t1
    487c:	02ce85b3          	mul	a1,t4,a2
    4880:	010e1e13          	slli	t3,t3,0x10
    4884:	01c7e7b3          	or	a5,a5,t3
    4888:	00b7fa63          	bgeu	a5,a1,489c <__umoddi3+0x27c>
    488c:	00f807b3          	add	a5,a6,a5
    4890:	0107e663          	bltu	a5,a6,489c <__umoddi3+0x27c>
    4894:	00b7f463          	bgeu	a5,a1,489c <__umoddi3+0x27c>
    4898:	010787b3          	add	a5,a5,a6
    489c:	40b787b3          	sub	a5,a5,a1
    48a0:	0267d5b3          	divu	a1,a5,t1
    48a4:	01071713          	slli	a4,a4,0x10
    48a8:	01075713          	srli	a4,a4,0x10
    48ac:	0267f7b3          	remu	a5,a5,t1
    48b0:	02c585b3          	mul	a1,a1,a2
    48b4:	01079793          	slli	a5,a5,0x10
    48b8:	00f76733          	or	a4,a4,a5
    48bc:	00b77a63          	bgeu	a4,a1,48d0 <__umoddi3+0x2b0>
    48c0:	00e80733          	add	a4,a6,a4
    48c4:	01076663          	bltu	a4,a6,48d0 <__umoddi3+0x2b0>
    48c8:	00b77463          	bgeu	a4,a1,48d0 <__umoddi3+0x2b0>
    48cc:	01070733          	add	a4,a4,a6
    48d0:	40b70733          	sub	a4,a4,a1
    48d4:	ee1ff06f          	j	47b4 <__umoddi3+0x194>
    48d8:	1006b813          	sltiu	a6,a3,256
    48dc:	00183813          	seqz	a6,a6
    48e0:	00381813          	slli	a6,a6,0x3
    48e4:	0106d333          	srl	t1,a3,a6
    48e8:	00003717          	auipc	a4,0x3
    48ec:	d4c70713          	addi	a4,a4,-692 # 7634 <__clz_tab>
    48f0:	00670733          	add	a4,a4,t1
    48f4:	00074703          	lbu	a4,0(a4)
    48f8:	02000313          	li	t1,32
    48fc:	01070733          	add	a4,a4,a6
    4900:	40e30833          	sub	a6,t1,a4
    4904:	e4e300e3          	beq	t1,a4,4744 <__umoddi3+0x124>
    4908:	010696b3          	sll	a3,a3,a6
    490c:	00e658b3          	srl	a7,a2,a4
    4910:	00d8e8b3          	or	a7,a7,a3
    4914:	00e5de33          	srl	t3,a1,a4
    4918:	0108df13          	srli	t5,a7,0x10
    491c:	03ee57b3          	divu	a5,t3,t5
    4920:	01089e93          	slli	t4,a7,0x10
    4924:	010ede93          	srli	t4,t4,0x10
    4928:	00e556b3          	srl	a3,a0,a4
    492c:	01051333          	sll	t1,a0,a6
    4930:	010595b3          	sll	a1,a1,a6
    4934:	00b6e5b3          	or	a1,a3,a1
    4938:	0105d693          	srli	a3,a1,0x10
    493c:	01061633          	sll	a2,a2,a6
    4940:	03ee7e33          	remu	t3,t3,t5
    4944:	02fe8533          	mul	a0,t4,a5
    4948:	010e1e13          	slli	t3,t3,0x10
    494c:	01c6e6b3          	or	a3,a3,t3
    4950:	00a6fe63          	bgeu	a3,a0,496c <__umoddi3+0x34c>
    4954:	00d886b3          	add	a3,a7,a3
    4958:	fff78e13          	addi	t3,a5,-1
    495c:	1116ec63          	bltu	a3,a7,4a74 <__umoddi3+0x454>
    4960:	10a6fa63          	bgeu	a3,a0,4a74 <__umoddi3+0x454>
    4964:	ffe78793          	addi	a5,a5,-2
    4968:	011686b3          	add	a3,a3,a7
    496c:	40a686b3          	sub	a3,a3,a0
    4970:	03e6d533          	divu	a0,a3,t5
    4974:	01059593          	slli	a1,a1,0x10
    4978:	0105d593          	srli	a1,a1,0x10
    497c:	03e6f6b3          	remu	a3,a3,t5
    4980:	02ae8eb3          	mul	t4,t4,a0
    4984:	01069693          	slli	a3,a3,0x10
    4988:	00d5e5b3          	or	a1,a1,a3
    498c:	01d5fe63          	bgeu	a1,t4,49a8 <__umoddi3+0x388>
    4990:	00b885b3          	add	a1,a7,a1
    4994:	fff50693          	addi	a3,a0,-1
    4998:	0d15ea63          	bltu	a1,a7,4a6c <__umoddi3+0x44c>
    499c:	0dd5f863          	bgeu	a1,t4,4a6c <__umoddi3+0x44c>
    49a0:	ffe50513          	addi	a0,a0,-2
    49a4:	011585b3          	add	a1,a1,a7
    49a8:	01079693          	slli	a3,a5,0x10
    49ac:	000102b7          	lui	t0,0x10
    49b0:	00a6e6b3          	or	a3,a3,a0
    49b4:	fff28513          	addi	a0,t0,-1 # ffff <__freertos_irq_stack_top+0x717f>
    49b8:	00a6fe33          	and	t3,a3,a0
    49bc:	01065f93          	srli	t6,a2,0x10
    49c0:	0106d693          	srli	a3,a3,0x10
    49c4:	00a67533          	and	a0,a2,a0
    49c8:	02ae0f33          	mul	t5,t3,a0
    49cc:	41d585b3          	sub	a1,a1,t4
    49d0:	02a68533          	mul	a0,a3,a0
    49d4:	010f5793          	srli	a5,t5,0x10
    49d8:	03fe0e33          	mul	t3,t3,t6
    49dc:	00ae0e33          	add	t3,t3,a0
    49e0:	01c787b3          	add	a5,a5,t3
    49e4:	03f686b3          	mul	a3,a3,t6
    49e8:	00a7f463          	bgeu	a5,a0,49f0 <__umoddi3+0x3d0>
    49ec:	005686b3          	add	a3,a3,t0
    49f0:	00010eb7          	lui	t4,0x10
    49f4:	fffe8e93          	addi	t4,t4,-1 # ffff <__freertos_irq_stack_top+0x717f>
    49f8:	01d7f533          	and	a0,a5,t4
    49fc:	0107de13          	srli	t3,a5,0x10
    4a00:	01051513          	slli	a0,a0,0x10
    4a04:	01df7f33          	and	t5,t5,t4
    4a08:	00de07b3          	add	a5,t3,a3
    4a0c:	01e50533          	add	a0,a0,t5
    4a10:	02f5e863          	bltu	a1,a5,4a40 <__umoddi3+0x420>
    4a14:	02f58463          	beq	a1,a5,4a3c <__umoddi3+0x41c>
    4a18:	40a30533          	sub	a0,t1,a0
    4a1c:	00a33333          	sltu	t1,t1,a0
    4a20:	40f585b3          	sub	a1,a1,a5
    4a24:	406585b3          	sub	a1,a1,t1
    4a28:	00e59733          	sll	a4,a1,a4
    4a2c:	01055533          	srl	a0,a0,a6
    4a30:	00a76533          	or	a0,a4,a0
    4a34:	0105d5b3          	srl	a1,a1,a6
    4a38:	00008067          	ret
    4a3c:	fca37ee3          	bgeu	t1,a0,4a18 <__umoddi3+0x3f8>
    4a40:	40c50633          	sub	a2,a0,a2
    4a44:	00c53533          	sltu	a0,a0,a2
    4a48:	011508b3          	add	a7,a0,a7
    4a4c:	411787b3          	sub	a5,a5,a7
    4a50:	00060513          	mv	a0,a2
    4a54:	fc5ff06f          	j	4a18 <__umoddi3+0x3f8>
    4a58:	010007b7          	lui	a5,0x1000
    4a5c:	02f67463          	bgeu	a2,a5,4a84 <__umoddi3+0x464>
    4a60:	01065693          	srli	a3,a2,0x10
    4a64:	01000713          	li	a4,16
    4a68:	d1dff06f          	j	4784 <__umoddi3+0x164>
    4a6c:	00068513          	mv	a0,a3
    4a70:	f39ff06f          	j	49a8 <__umoddi3+0x388>
    4a74:	000e0793          	mv	a5,t3
    4a78:	ef5ff06f          	j	496c <__umoddi3+0x34c>
    4a7c:	010787b3          	add	a5,a5,a6
    4a80:	c3dff06f          	j	46bc <__umoddi3+0x9c>
    4a84:	01865693          	srli	a3,a2,0x18
    4a88:	01800713          	li	a4,24
    4a8c:	cf9ff06f          	j	4784 <__umoddi3+0x164>

00004a90 <__adddf3>:
    4a90:	001007b7          	lui	a5,0x100
    4a94:	fe010113          	addi	sp,sp,-32
    4a98:	fff78e93          	addi	t4,a5,-1 # fffff <__freertos_irq_stack_top+0xf717f>
    4a9c:	00bef833          	and	a6,t4,a1
    4aa0:	00def7b3          	and	a5,t4,a3
    4aa4:	0146d313          	srli	t1,a3,0x14
    4aa8:	01212823          	sw	s2,16(sp)
    4aac:	0145d913          	srli	s2,a1,0x14
    4ab0:	00379793          	slli	a5,a5,0x3
    4ab4:	00812c23          	sw	s0,24(sp)
    4ab8:	00381813          	slli	a6,a6,0x3
    4abc:	01f5d413          	srli	s0,a1,0x1f
    4ac0:	01d55713          	srli	a4,a0,0x1d
    4ac4:	01d65893          	srli	a7,a2,0x1d
    4ac8:	7ff97913          	andi	s2,s2,2047
    4acc:	7ff37313          	andi	t1,t1,2047
    4ad0:	00112e23          	sw	ra,28(sp)
    4ad4:	00912a23          	sw	s1,20(sp)
    4ad8:	01312623          	sw	s3,12(sp)
    4adc:	01f6d693          	srli	a3,a3,0x1f
    4ae0:	00f8e8b3          	or	a7,a7,a5
    4ae4:	01076733          	or	a4,a4,a6
    4ae8:	00351593          	slli	a1,a0,0x3
    4aec:	00361f13          	slli	t5,a2,0x3
    4af0:	406907b3          	sub	a5,s2,t1
    4af4:	1ed40463          	beq	s0,a3,4cdc <__adddf3+0x24c>
    4af8:	16f05263          	blez	a5,4c5c <__adddf3+0x1cc>
    4afc:	28030663          	beqz	t1,4d88 <__adddf3+0x2f8>
    4b00:	7ff00693          	li	a3,2047
    4b04:	42d90663          	beq	s2,a3,4f30 <__adddf3+0x4a0>
    4b08:	03800693          	li	a3,56
    4b0c:	00100613          	li	a2,1
    4b10:	02f6ce63          	blt	a3,a5,4b4c <__adddf3+0xbc>
    4b14:	008006b7          	lui	a3,0x800
    4b18:	00d8e8b3          	or	a7,a7,a3
    4b1c:	01f00693          	li	a3,31
    4b20:	52f6ce63          	blt	a3,a5,505c <__adddf3+0x5cc>
    4b24:	02000693          	li	a3,32
    4b28:	40f686b3          	sub	a3,a3,a5
    4b2c:	00d89633          	sll	a2,a7,a3
    4b30:	00ff5533          	srl	a0,t5,a5
    4b34:	00df16b3          	sll	a3,t5,a3
    4b38:	00a66633          	or	a2,a2,a0
    4b3c:	00d036b3          	snez	a3,a3
    4b40:	00f8d8b3          	srl	a7,a7,a5
    4b44:	00d66633          	or	a2,a2,a3
    4b48:	41170733          	sub	a4,a4,a7
    4b4c:	40c58633          	sub	a2,a1,a2
    4b50:	00c5b5b3          	sltu	a1,a1,a2
    4b54:	00060493          	mv	s1,a2
    4b58:	40b709b3          	sub	s3,a4,a1
    4b5c:	00899793          	slli	a5,s3,0x8
    4b60:	3207da63          	bgez	a5,4e94 <__adddf3+0x404>
    4b64:	008007b7          	lui	a5,0x800
    4b68:	fff78793          	addi	a5,a5,-1 # 7fffff <__freertos_irq_stack_top+0x7f717f>
    4b6c:	00f9f9b3          	and	s3,s3,a5
    4b70:	2c098863          	beqz	s3,4e40 <__adddf3+0x3b0>
    4b74:	00098513          	mv	a0,s3
    4b78:	458020ef          	jal	6fd0 <__clzsi2>
    4b7c:	ff850793          	addi	a5,a0,-8
    4b80:	02000693          	li	a3,32
    4b84:	40f68733          	sub	a4,a3,a5
    4b88:	00e4d733          	srl	a4,s1,a4
    4b8c:	00f999b3          	sll	s3,s3,a5
    4b90:	01376733          	or	a4,a4,s3
    4b94:	00f494b3          	sll	s1,s1,a5
    4b98:	4b27c863          	blt	a5,s2,5048 <__adddf3+0x5b8>
    4b9c:	412787b3          	sub	a5,a5,s2
    4ba0:	00178793          	addi	a5,a5,1
    4ba4:	40f686b3          	sub	a3,a3,a5
    4ba8:	00d49633          	sll	a2,s1,a3
    4bac:	00f4d9b3          	srl	s3,s1,a5
    4bb0:	00c03633          	snez	a2,a2
    4bb4:	01366633          	or	a2,a2,s3
    4bb8:	00d716b3          	sll	a3,a4,a3
    4bbc:	00c6e4b3          	or	s1,a3,a2
    4bc0:	00f759b3          	srl	s3,a4,a5
    4bc4:	00000913          	li	s2,0
    4bc8:	0074f793          	andi	a5,s1,7
    4bcc:	02078063          	beqz	a5,4bec <__adddf3+0x15c>
    4bd0:	00f4f793          	andi	a5,s1,15
    4bd4:	00400713          	li	a4,4
    4bd8:	00e78a63          	beq	a5,a4,4bec <__adddf3+0x15c>
    4bdc:	00448793          	addi	a5,s1,4
    4be0:	0097b633          	sltu	a2,a5,s1
    4be4:	00c989b3          	add	s3,s3,a2
    4be8:	00078493          	mv	s1,a5
    4bec:	00899793          	slli	a5,s3,0x8
    4bf0:	6e07da63          	bgez	a5,52e4 <__adddf3+0x854>
    4bf4:	00190793          	addi	a5,s2,1
    4bf8:	7ff00713          	li	a4,2047
    4bfc:	00040e13          	mv	t3,s0
    4c00:	2ae78663          	beq	a5,a4,4eac <__adddf3+0x41c>
    4c04:	ff800737          	lui	a4,0xff800
    4c08:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f717f>
    4c0c:	00e9f733          	and	a4,s3,a4
    4c10:	7ff7f793          	andi	a5,a5,2047
    4c14:	01d71813          	slli	a6,a4,0x1d
    4c18:	0034d613          	srli	a2,s1,0x3
    4c1c:	00971713          	slli	a4,a4,0x9
    4c20:	00c86833          	or	a6,a6,a2
    4c24:	00c75713          	srli	a4,a4,0xc
    4c28:	01c12083          	lw	ra,28(sp)
    4c2c:	01812403          	lw	s0,24(sp)
    4c30:	01479793          	slli	a5,a5,0x14
    4c34:	00e7e7b3          	or	a5,a5,a4
    4c38:	01fe1713          	slli	a4,t3,0x1f
    4c3c:	00e7e7b3          	or	a5,a5,a4
    4c40:	01412483          	lw	s1,20(sp)
    4c44:	01012903          	lw	s2,16(sp)
    4c48:	00c12983          	lw	s3,12(sp)
    4c4c:	00080513          	mv	a0,a6
    4c50:	00078593          	mv	a1,a5
    4c54:	02010113          	addi	sp,sp,32
    4c58:	00008067          	ret
    4c5c:	14078c63          	beqz	a5,4db4 <__adddf3+0x324>
    4c60:	412307b3          	sub	a5,t1,s2
    4c64:	3c091263          	bnez	s2,5028 <__adddf3+0x598>
    4c68:	00b76533          	or	a0,a4,a1
    4c6c:	4c050463          	beqz	a0,5134 <__adddf3+0x6a4>
    4c70:	fff78513          	addi	a0,a5,-1
    4c74:	60050263          	beqz	a0,5278 <__adddf3+0x7e8>
    4c78:	7ff00813          	li	a6,2047
    4c7c:	57078663          	beq	a5,a6,51e8 <__adddf3+0x758>
    4c80:	03800793          	li	a5,56
    4c84:	00100613          	li	a2,1
    4c88:	02a7cc63          	blt	a5,a0,4cc0 <__adddf3+0x230>
    4c8c:	00050793          	mv	a5,a0
    4c90:	01f00613          	li	a2,31
    4c94:	56f64c63          	blt	a2,a5,520c <__adddf3+0x77c>
    4c98:	02000513          	li	a0,32
    4c9c:	40f50533          	sub	a0,a0,a5
    4ca0:	00a71633          	sll	a2,a4,a0
    4ca4:	00f5d833          	srl	a6,a1,a5
    4ca8:	00a59533          	sll	a0,a1,a0
    4cac:	01066633          	or	a2,a2,a6
    4cb0:	00a03533          	snez	a0,a0
    4cb4:	00f75733          	srl	a4,a4,a5
    4cb8:	00a66633          	or	a2,a2,a0
    4cbc:	40e888b3          	sub	a7,a7,a4
    4cc0:	40cf0633          	sub	a2,t5,a2
    4cc4:	00cf3733          	sltu	a4,t5,a2
    4cc8:	00060493          	mv	s1,a2
    4ccc:	40e889b3          	sub	s3,a7,a4
    4cd0:	00030913          	mv	s2,t1
    4cd4:	00068413          	mv	s0,a3
    4cd8:	e85ff06f          	j	4b5c <__adddf3+0xcc>
    4cdc:	1ef05063          	blez	a5,4ebc <__adddf3+0x42c>
    4ce0:	14031063          	bnez	t1,4e20 <__adddf3+0x390>
    4ce4:	01e8e6b3          	or	a3,a7,t5
    4ce8:	26068c63          	beqz	a3,4f60 <__adddf3+0x4d0>
    4cec:	fff78693          	addi	a3,a5,-1
    4cf0:	48068063          	beqz	a3,5170 <__adddf3+0x6e0>
    4cf4:	7ff00613          	li	a2,2047
    4cf8:	22c78c63          	beq	a5,a2,4f30 <__adddf3+0x4a0>
    4cfc:	03800793          	li	a5,56
    4d00:	00100993          	li	s3,1
    4d04:	02d7cc63          	blt	a5,a3,4d3c <__adddf3+0x2ac>
    4d08:	00068793          	mv	a5,a3
    4d0c:	01f00693          	li	a3,31
    4d10:	4af6c063          	blt	a3,a5,51b0 <__adddf3+0x720>
    4d14:	02000693          	li	a3,32
    4d18:	40f686b3          	sub	a3,a3,a5
    4d1c:	00d899b3          	sll	s3,a7,a3
    4d20:	00ff5633          	srl	a2,t5,a5
    4d24:	00df16b3          	sll	a3,t5,a3
    4d28:	00c9e9b3          	or	s3,s3,a2
    4d2c:	00d036b3          	snez	a3,a3
    4d30:	00f8d8b3          	srl	a7,a7,a5
    4d34:	00d9e9b3          	or	s3,s3,a3
    4d38:	01170733          	add	a4,a4,a7
    4d3c:	00b985b3          	add	a1,s3,a1
    4d40:	0135b9b3          	sltu	s3,a1,s3
    4d44:	00058493          	mv	s1,a1
    4d48:	00e989b3          	add	s3,s3,a4
    4d4c:	00899793          	slli	a5,s3,0x8
    4d50:	1407d263          	bgez	a5,4e94 <__adddf3+0x404>
    4d54:	00190913          	addi	s2,s2,1
    4d58:	7ff00793          	li	a5,2047
    4d5c:	36f90c63          	beq	s2,a5,50d4 <__adddf3+0x644>
    4d60:	ff8007b7          	lui	a5,0xff800
    4d64:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f717f>
    4d68:	0014f613          	andi	a2,s1,1
    4d6c:	00f9f7b3          	and	a5,s3,a5
    4d70:	0014d713          	srli	a4,s1,0x1
    4d74:	00c76733          	or	a4,a4,a2
    4d78:	01f79613          	slli	a2,a5,0x1f
    4d7c:	00e664b3          	or	s1,a2,a4
    4d80:	0017d993          	srli	s3,a5,0x1
    4d84:	e45ff06f          	j	4bc8 <__adddf3+0x138>
    4d88:	01e8e6b3          	or	a3,a7,t5
    4d8c:	1c068a63          	beqz	a3,4f60 <__adddf3+0x4d0>
    4d90:	fff78693          	addi	a3,a5,-1
    4d94:	40068063          	beqz	a3,5194 <__adddf3+0x704>
    4d98:	7ff00613          	li	a2,2047
    4d9c:	18c78a63          	beq	a5,a2,4f30 <__adddf3+0x4a0>
    4da0:	03800793          	li	a5,56
    4da4:	00100613          	li	a2,1
    4da8:	dad7c2e3          	blt	a5,a3,4b4c <__adddf3+0xbc>
    4dac:	00068793          	mv	a5,a3
    4db0:	d6dff06f          	j	4b1c <__adddf3+0x8c>
    4db4:	00190813          	addi	a6,s2,1
    4db8:	7fe87813          	andi	a6,a6,2046
    4dbc:	22081c63          	bnez	a6,4ff4 <__adddf3+0x564>
    4dc0:	00b76333          	or	t1,a4,a1
    4dc4:	01e8e833          	or	a6,a7,t5
    4dc8:	38091063          	bnez	s2,5148 <__adddf3+0x6b8>
    4dcc:	46030e63          	beqz	t1,5248 <__adddf3+0x7b8>
    4dd0:	40080663          	beqz	a6,51dc <__adddf3+0x74c>
    4dd4:	41e589b3          	sub	s3,a1,t5
    4dd8:	0135b533          	sltu	a0,a1,s3
    4ddc:	41170633          	sub	a2,a4,a7
    4de0:	40a60633          	sub	a2,a2,a0
    4de4:	00861513          	slli	a0,a2,0x8
    4de8:	50055e63          	bgez	a0,5304 <__adddf3+0x874>
    4dec:	40bf05b3          	sub	a1,t5,a1
    4df0:	40e88733          	sub	a4,a7,a4
    4df4:	00bf3f33          	sltu	t5,t5,a1
    4df8:	41e70733          	sub	a4,a4,t5
    4dfc:	00871613          	slli	a2,a4,0x8
    4e00:	00058493          	mv	s1,a1
    4e04:	52065e63          	bgez	a2,5340 <__adddf3+0x8b0>
    4e08:	ff8007b7          	lui	a5,0xff800
    4e0c:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f717f>
    4e10:	00f77733          	and	a4,a4,a5
    4e14:	00068e13          	mv	t3,a3
    4e18:	00100793          	li	a5,1
    4e1c:	df9ff06f          	j	4c14 <__adddf3+0x184>
    4e20:	7ff00693          	li	a3,2047
    4e24:	10d90663          	beq	s2,a3,4f30 <__adddf3+0x4a0>
    4e28:	03800693          	li	a3,56
    4e2c:	00100993          	li	s3,1
    4e30:	f0f6c6e3          	blt	a3,a5,4d3c <__adddf3+0x2ac>
    4e34:	008006b7          	lui	a3,0x800
    4e38:	00d8e8b3          	or	a7,a7,a3
    4e3c:	ed1ff06f          	j	4d0c <__adddf3+0x27c>
    4e40:	00048513          	mv	a0,s1
    4e44:	18c020ef          	jal	6fd0 <__clzsi2>
    4e48:	01850793          	addi	a5,a0,24
    4e4c:	01f00693          	li	a3,31
    4e50:	d2f6d8e3          	bge	a3,a5,4b80 <__adddf3+0xf0>
    4e54:	ff850713          	addi	a4,a0,-8
    4e58:	00e49733          	sll	a4,s1,a4
    4e5c:	2327c663          	blt	a5,s2,5088 <__adddf3+0x5f8>
    4e60:	41278933          	sub	s2,a5,s2
    4e64:	00190793          	addi	a5,s2,1
    4e68:	48f6d663          	bge	a3,a5,52f4 <__adddf3+0x864>
    4e6c:	fe190913          	addi	s2,s2,-31
    4e70:	02000693          	li	a3,32
    4e74:	012754b3          	srl	s1,a4,s2
    4e78:	00d78c63          	beq	a5,a3,4e90 <__adddf3+0x400>
    4e7c:	04000693          	li	a3,64
    4e80:	40f687b3          	sub	a5,a3,a5
    4e84:	00f71733          	sll	a4,a4,a5
    4e88:	00e03733          	snez	a4,a4
    4e8c:	00e4e4b3          	or	s1,s1,a4
    4e90:	00000913          	li	s2,0
    4e94:	0074f793          	andi	a5,s1,7
    4e98:	d2079ce3          	bnez	a5,4bd0 <__adddf3+0x140>
    4e9c:	00090793          	mv	a5,s2
    4ea0:	0034d613          	srli	a2,s1,0x3
    4ea4:	00098713          	mv	a4,s3
    4ea8:	0c00006f          	j	4f68 <__adddf3+0x4d8>
    4eac:	7ff00793          	li	a5,2047
    4eb0:	00000713          	li	a4,0
    4eb4:	00000813          	li	a6,0
    4eb8:	d71ff06f          	j	4c28 <__adddf3+0x198>
    4ebc:	0c078a63          	beqz	a5,4f90 <__adddf3+0x500>
    4ec0:	412307b3          	sub	a5,t1,s2
    4ec4:	1e090263          	beqz	s2,50a8 <__adddf3+0x618>
    4ec8:	7ff00693          	li	a3,2047
    4ecc:	32d30863          	beq	t1,a3,51fc <__adddf3+0x76c>
    4ed0:	03800693          	li	a3,56
    4ed4:	00100993          	li	s3,1
    4ed8:	02f6ce63          	blt	a3,a5,4f14 <__adddf3+0x484>
    4edc:	008006b7          	lui	a3,0x800
    4ee0:	00d76733          	or	a4,a4,a3
    4ee4:	01f00693          	li	a3,31
    4ee8:	3cf6c863          	blt	a3,a5,52b8 <__adddf3+0x828>
    4eec:	02000693          	li	a3,32
    4ef0:	40f686b3          	sub	a3,a3,a5
    4ef4:	00d719b3          	sll	s3,a4,a3
    4ef8:	00f5d633          	srl	a2,a1,a5
    4efc:	00d596b3          	sll	a3,a1,a3
    4f00:	00c9e9b3          	or	s3,s3,a2
    4f04:	00d036b3          	snez	a3,a3
    4f08:	00f75733          	srl	a4,a4,a5
    4f0c:	00d9e9b3          	or	s3,s3,a3
    4f10:	00e888b3          	add	a7,a7,a4
    4f14:	01e98733          	add	a4,s3,t5
    4f18:	013739b3          	sltu	s3,a4,s3
    4f1c:	00070493          	mv	s1,a4
    4f20:	011989b3          	add	s3,s3,a7
    4f24:	00030913          	mv	s2,t1
    4f28:	e25ff06f          	j	4d4c <__adddf3+0x2bc>
    4f2c:	02081063          	bnez	a6,4f4c <__adddf3+0x4bc>
    4f30:	00351613          	slli	a2,a0,0x3
    4f34:	00365613          	srli	a2,a2,0x3
    4f38:	01d71813          	slli	a6,a4,0x1d
    4f3c:	00c86833          	or	a6,a6,a2
    4f40:	00375713          	srli	a4,a4,0x3
    4f44:	01076733          	or	a4,a4,a6
    4f48:	18070663          	beqz	a4,50d4 <__adddf3+0x644>
    4f4c:	00000e13          	li	t3,0
    4f50:	7ff00793          	li	a5,2047
    4f54:	00080737          	lui	a4,0x80
    4f58:	00000813          	li	a6,0
    4f5c:	ccdff06f          	j	4c28 <__adddf3+0x198>
    4f60:	00351613          	slli	a2,a0,0x3
    4f64:	00365613          	srli	a2,a2,0x3
    4f68:	01d71813          	slli	a6,a4,0x1d
    4f6c:	7ff00693          	li	a3,2047
    4f70:	00c86833          	or	a6,a6,a2
    4f74:	00375713          	srli	a4,a4,0x3
    4f78:	fcd786e3          	beq	a5,a3,4f44 <__adddf3+0x4b4>
    4f7c:	00c71713          	slli	a4,a4,0xc
    4f80:	00c75713          	srli	a4,a4,0xc
    4f84:	7ff7f793          	andi	a5,a5,2047
    4f88:	00040e13          	mv	t3,s0
    4f8c:	c9dff06f          	j	4c28 <__adddf3+0x198>
    4f90:	00190693          	addi	a3,s2,1
    4f94:	7fe6f813          	andi	a6,a3,2046
    4f98:	14081863          	bnez	a6,50e8 <__adddf3+0x658>
    4f9c:	00b766b3          	or	a3,a4,a1
    4fa0:	28091c63          	bnez	s2,5238 <__adddf3+0x7a8>
    4fa4:	30068263          	beqz	a3,52a8 <__adddf3+0x818>
    4fa8:	01e8e6b3          	or	a3,a7,t5
    4fac:	22068863          	beqz	a3,51dc <__adddf3+0x74c>
    4fb0:	01e587b3          	add	a5,a1,t5
    4fb4:	00b7b5b3          	sltu	a1,a5,a1
    4fb8:	01170733          	add	a4,a4,a7
    4fbc:	00b70733          	add	a4,a4,a1
    4fc0:	0037d813          	srli	a6,a5,0x3
    4fc4:	00871793          	slli	a5,a4,0x8
    4fc8:	00040e13          	mv	t3,s0
    4fcc:	3407de63          	bgez	a5,5328 <__adddf3+0x898>
    4fd0:	ff8007b7          	lui	a5,0xff800
    4fd4:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f717f>
    4fd8:	00f77733          	and	a4,a4,a5
    4fdc:	01d71793          	slli	a5,a4,0x1d
    4fe0:	00375713          	srli	a4,a4,0x3
    4fe4:	0107e833          	or	a6,a5,a6
    4fe8:	01d77733          	and	a4,a4,t4
    4fec:	00100793          	li	a5,1
    4ff0:	c39ff06f          	j	4c28 <__adddf3+0x198>
    4ff4:	41e58833          	sub	a6,a1,t5
    4ff8:	0105b7b3          	sltu	a5,a1,a6
    4ffc:	411709b3          	sub	s3,a4,a7
    5000:	40f989b3          	sub	s3,s3,a5
    5004:	00899793          	slli	a5,s3,0x8
    5008:	00080493          	mv	s1,a6
    500c:	1007c663          	bltz	a5,5118 <__adddf3+0x688>
    5010:	01386833          	or	a6,a6,s3
    5014:	b4081ee3          	bnez	a6,4b70 <__adddf3+0xe0>
    5018:	00000e13          	li	t3,0
    501c:	00000793          	li	a5,0
    5020:	00000713          	li	a4,0
    5024:	c05ff06f          	j	4c28 <__adddf3+0x198>
    5028:	7ff00513          	li	a0,2047
    502c:	1aa30e63          	beq	t1,a0,51e8 <__adddf3+0x758>
    5030:	03800513          	li	a0,56
    5034:	00100613          	li	a2,1
    5038:	c8f544e3          	blt	a0,a5,4cc0 <__adddf3+0x230>
    503c:	00800637          	lui	a2,0x800
    5040:	00c76733          	or	a4,a4,a2
    5044:	c4dff06f          	j	4c90 <__adddf3+0x200>
    5048:	ff8009b7          	lui	s3,0xff800
    504c:	fff98993          	addi	s3,s3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f717f>
    5050:	40f90933          	sub	s2,s2,a5
    5054:	013779b3          	and	s3,a4,s3
    5058:	b71ff06f          	j	4bc8 <__adddf3+0x138>
    505c:	fe078693          	addi	a3,a5,-32
    5060:	02000613          	li	a2,32
    5064:	00d8d6b3          	srl	a3,a7,a3
    5068:	00c78a63          	beq	a5,a2,507c <__adddf3+0x5ec>
    506c:	04000613          	li	a2,64
    5070:	40f607b3          	sub	a5,a2,a5
    5074:	00f897b3          	sll	a5,a7,a5
    5078:	00ff6f33          	or	t5,t5,a5
    507c:	01e03633          	snez	a2,t5
    5080:	00d66633          	or	a2,a2,a3
    5084:	ac9ff06f          	j	4b4c <__adddf3+0xbc>
    5088:	ff8006b7          	lui	a3,0xff800
    508c:	fff68693          	addi	a3,a3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f717f>
    5090:	40f907b3          	sub	a5,s2,a5
    5094:	00d77733          	and	a4,a4,a3
    5098:	01d71813          	slli	a6,a4,0x1d
    509c:	01386833          	or	a6,a6,s3
    50a0:	00375713          	srli	a4,a4,0x3
    50a4:	ed9ff06f          	j	4f7c <__adddf3+0x4ec>
    50a8:	00b766b3          	or	a3,a4,a1
    50ac:	1e068663          	beqz	a3,5298 <__adddf3+0x808>
    50b0:	fff78693          	addi	a3,a5,-1
    50b4:	0a068e63          	beqz	a3,5170 <__adddf3+0x6e0>
    50b8:	7ff00513          	li	a0,2047
    50bc:	14a78063          	beq	a5,a0,51fc <__adddf3+0x76c>
    50c0:	03800793          	li	a5,56
    50c4:	00100993          	li	s3,1
    50c8:	e4d7c6e3          	blt	a5,a3,4f14 <__adddf3+0x484>
    50cc:	00068793          	mv	a5,a3
    50d0:	e15ff06f          	j	4ee4 <__adddf3+0x454>
    50d4:	00040e13          	mv	t3,s0
    50d8:	7ff00793          	li	a5,2047
    50dc:	00000713          	li	a4,0
    50e0:	00000813          	li	a6,0
    50e4:	b45ff06f          	j	4c28 <__adddf3+0x198>
    50e8:	7ff00793          	li	a5,2047
    50ec:	fef684e3          	beq	a3,a5,50d4 <__adddf3+0x644>
    50f0:	01e58f33          	add	t5,a1,t5
    50f4:	00bf35b3          	sltu	a1,t5,a1
    50f8:	011707b3          	add	a5,a4,a7
    50fc:	00b787b3          	add	a5,a5,a1
    5100:	01f79613          	slli	a2,a5,0x1f
    5104:	001f5f13          	srli	t5,t5,0x1
    5108:	01e664b3          	or	s1,a2,t5
    510c:	0017d993          	srli	s3,a5,0x1
    5110:	00068913          	mv	s2,a3
    5114:	ab5ff06f          	j	4bc8 <__adddf3+0x138>
    5118:	40bf0633          	sub	a2,t5,a1
    511c:	40e887b3          	sub	a5,a7,a4
    5120:	00cf3733          	sltu	a4,t5,a2
    5124:	00060493          	mv	s1,a2
    5128:	40e789b3          	sub	s3,a5,a4
    512c:	00068413          	mv	s0,a3
    5130:	a41ff06f          	j	4b70 <__adddf3+0xe0>
    5134:	00361613          	slli	a2,a2,0x3
    5138:	00365613          	srli	a2,a2,0x3
    513c:	00068413          	mv	s0,a3
    5140:	00088713          	mv	a4,a7
    5144:	e25ff06f          	j	4f68 <__adddf3+0x4d8>
    5148:	de0312e3          	bnez	t1,4f2c <__adddf3+0x49c>
    514c:	1c080663          	beqz	a6,5318 <__adddf3+0x888>
    5150:	0038d713          	srli	a4,a7,0x3
    5154:	00361613          	slli	a2,a2,0x3
    5158:	01d89893          	slli	a7,a7,0x1d
    515c:	01176733          	or	a4,a4,a7
    5160:	00365613          	srli	a2,a2,0x3
    5164:	00c76733          	or	a4,a4,a2
    5168:	00068413          	mv	s0,a3
    516c:	dddff06f          	j	4f48 <__adddf3+0x4b8>
    5170:	01e58f33          	add	t5,a1,t5
    5174:	011708b3          	add	a7,a4,a7
    5178:	00bf35b3          	sltu	a1,t5,a1
    517c:	00b889b3          	add	s3,a7,a1
    5180:	00899793          	slli	a5,s3,0x8
    5184:	000f0493          	mv	s1,t5
    5188:	0e07d463          	bgez	a5,5270 <__adddf3+0x7e0>
    518c:	00200913          	li	s2,2
    5190:	bd1ff06f          	j	4d60 <__adddf3+0x2d0>
    5194:	41e58f33          	sub	t5,a1,t5
    5198:	411708b3          	sub	a7,a4,a7
    519c:	01e5b5b3          	sltu	a1,a1,t5
    51a0:	000f0493          	mv	s1,t5
    51a4:	40b889b3          	sub	s3,a7,a1
    51a8:	00100913          	li	s2,1
    51ac:	9b1ff06f          	j	4b5c <__adddf3+0xcc>
    51b0:	fe078693          	addi	a3,a5,-32
    51b4:	02000613          	li	a2,32
    51b8:	00d8d6b3          	srl	a3,a7,a3
    51bc:	00c78a63          	beq	a5,a2,51d0 <__adddf3+0x740>
    51c0:	04000613          	li	a2,64
    51c4:	40f607b3          	sub	a5,a2,a5
    51c8:	00f897b3          	sll	a5,a7,a5
    51cc:	00ff6f33          	or	t5,t5,a5
    51d0:	01e039b3          	snez	s3,t5
    51d4:	00d9e9b3          	or	s3,s3,a3
    51d8:	b65ff06f          	j	4d3c <__adddf3+0x2ac>
    51dc:	00351613          	slli	a2,a0,0x3
    51e0:	00365993          	srli	s3,a2,0x3
    51e4:	eb5ff06f          	j	5098 <__adddf3+0x608>
    51e8:	00361613          	slli	a2,a2,0x3
    51ec:	00365613          	srli	a2,a2,0x3
    51f0:	00068413          	mv	s0,a3
    51f4:	00088713          	mv	a4,a7
    51f8:	d41ff06f          	j	4f38 <__adddf3+0x4a8>
    51fc:	00361613          	slli	a2,a2,0x3
    5200:	00365613          	srli	a2,a2,0x3
    5204:	00088713          	mv	a4,a7
    5208:	d31ff06f          	j	4f38 <__adddf3+0x4a8>
    520c:	fe078513          	addi	a0,a5,-32
    5210:	02000613          	li	a2,32
    5214:	00a75533          	srl	a0,a4,a0
    5218:	00c78a63          	beq	a5,a2,522c <__adddf3+0x79c>
    521c:	04000613          	li	a2,64
    5220:	40f607b3          	sub	a5,a2,a5
    5224:	00f717b3          	sll	a5,a4,a5
    5228:	00f5e5b3          	or	a1,a1,a5
    522c:	00b03633          	snez	a2,a1
    5230:	00a66633          	or	a2,a2,a0
    5234:	a8dff06f          	j	4cc0 <__adddf3+0x230>
    5238:	fc0682e3          	beqz	a3,51fc <__adddf3+0x76c>
    523c:	01e8ef33          	or	t5,a7,t5
    5240:	d00f16e3          	bnez	t5,4f4c <__adddf3+0x4bc>
    5244:	cedff06f          	j	4f30 <__adddf3+0x4a0>
    5248:	dc0808e3          	beqz	a6,5018 <__adddf3+0x588>
    524c:	00361813          	slli	a6,a2,0x3
    5250:	01d89793          	slli	a5,a7,0x1d
    5254:	00385813          	srli	a6,a6,0x3
    5258:	0038d713          	srli	a4,a7,0x3
    525c:	00f86833          	or	a6,a6,a5
    5260:	01d77733          	and	a4,a4,t4
    5264:	00068e13          	mv	t3,a3
    5268:	00000793          	li	a5,0
    526c:	9bdff06f          	j	4c28 <__adddf3+0x198>
    5270:	00100793          	li	a5,1
    5274:	c2dff06f          	j	4ea0 <__adddf3+0x410>
    5278:	40bf05b3          	sub	a1,t5,a1
    527c:	40e888b3          	sub	a7,a7,a4
    5280:	00bf3733          	sltu	a4,t5,a1
    5284:	00058493          	mv	s1,a1
    5288:	40e889b3          	sub	s3,a7,a4
    528c:	00068413          	mv	s0,a3
    5290:	00100913          	li	s2,1
    5294:	8c9ff06f          	j	4b5c <__adddf3+0xcc>
    5298:	00361613          	slli	a2,a2,0x3
    529c:	00365613          	srli	a2,a2,0x3
    52a0:	00088713          	mv	a4,a7
    52a4:	cc5ff06f          	j	4f68 <__adddf3+0x4d8>
    52a8:	00361613          	slli	a2,a2,0x3
    52ac:	00365993          	srli	s3,a2,0x3
    52b0:	00088713          	mv	a4,a7
    52b4:	de5ff06f          	j	5098 <__adddf3+0x608>
    52b8:	fe078693          	addi	a3,a5,-32
    52bc:	02000613          	li	a2,32
    52c0:	00d756b3          	srl	a3,a4,a3
    52c4:	00c78a63          	beq	a5,a2,52d8 <__adddf3+0x848>
    52c8:	04000613          	li	a2,64
    52cc:	40f607b3          	sub	a5,a2,a5
    52d0:	00f717b3          	sll	a5,a4,a5
    52d4:	00f5e5b3          	or	a1,a1,a5
    52d8:	00b039b3          	snez	s3,a1
    52dc:	00d9e9b3          	or	s3,s3,a3
    52e0:	c35ff06f          	j	4f14 <__adddf3+0x484>
    52e4:	0034d613          	srli	a2,s1,0x3
    52e8:	00090793          	mv	a5,s2
    52ec:	00098713          	mv	a4,s3
    52f0:	c79ff06f          	j	4f68 <__adddf3+0x4d8>
    52f4:	02000693          	li	a3,32
    52f8:	40f686b3          	sub	a3,a3,a5
    52fc:	00000613          	li	a2,0
    5300:	8b5ff06f          	j	4bb4 <__adddf3+0x124>
    5304:	00c9e833          	or	a6,s3,a2
    5308:	d00808e3          	beqz	a6,5018 <__adddf3+0x588>
    530c:	0039d993          	srli	s3,s3,0x3
    5310:	00060713          	mv	a4,a2
    5314:	d85ff06f          	j	5098 <__adddf3+0x608>
    5318:	00000e13          	li	t3,0
    531c:	7ff00793          	li	a5,2047
    5320:	00080737          	lui	a4,0x80
    5324:	905ff06f          	j	4c28 <__adddf3+0x198>
    5328:	01d71793          	slli	a5,a4,0x1d
    532c:	00375713          	srli	a4,a4,0x3
    5330:	0107e833          	or	a6,a5,a6
    5334:	01d77733          	and	a4,a4,t4
    5338:	00000793          	li	a5,0
    533c:	8edff06f          	j	4c28 <__adddf3+0x198>
    5340:	01d71813          	slli	a6,a4,0x1d
    5344:	0035d593          	srli	a1,a1,0x3
    5348:	00b86833          	or	a6,a6,a1
    534c:	00375713          	srli	a4,a4,0x3
    5350:	00068413          	mv	s0,a3
    5354:	c29ff06f          	j	4f7c <__adddf3+0x4ec>

00005358 <__divdf3>:
    5358:	fd010113          	addi	sp,sp,-48
    535c:	01312e23          	sw	s3,28(sp)
    5360:	0145d993          	srli	s3,a1,0x14
    5364:	02812423          	sw	s0,40(sp)
    5368:	02912223          	sw	s1,36(sp)
    536c:	03212023          	sw	s2,32(sp)
    5370:	01412c23          	sw	s4,24(sp)
    5374:	01712623          	sw	s7,12(sp)
    5378:	00c59493          	slli	s1,a1,0xc
    537c:	02112623          	sw	ra,44(sp)
    5380:	01512a23          	sw	s5,20(sp)
    5384:	01612823          	sw	s6,16(sp)
    5388:	01812423          	sw	s8,8(sp)
    538c:	7ff9f993          	andi	s3,s3,2047
    5390:	00050413          	mv	s0,a0
    5394:	00060b93          	mv	s7,a2
    5398:	00068913          	mv	s2,a3
    539c:	00c4d493          	srli	s1,s1,0xc
    53a0:	01f5da13          	srli	s4,a1,0x1f
    53a4:	18098c63          	beqz	s3,553c <__divdf3+0x1e4>
    53a8:	7ff00793          	li	a5,2047
    53ac:	08f98a63          	beq	s3,a5,5440 <__divdf3+0xe8>
    53b0:	00349493          	slli	s1,s1,0x3
    53b4:	01d55793          	srli	a5,a0,0x1d
    53b8:	0097e7b3          	or	a5,a5,s1
    53bc:	00800737          	lui	a4,0x800
    53c0:	00e7eab3          	or	s5,a5,a4
    53c4:	00351b13          	slli	s6,a0,0x3
    53c8:	c0198993          	addi	s3,s3,-1023
    53cc:	00000493          	li	s1,0
    53d0:	00000c13          	li	s8,0
    53d4:	01495793          	srli	a5,s2,0x14
    53d8:	00c91413          	slli	s0,s2,0xc
    53dc:	7ff7f793          	andi	a5,a5,2047
    53e0:	00c45413          	srli	s0,s0,0xc
    53e4:	01f95913          	srli	s2,s2,0x1f
    53e8:	08078463          	beqz	a5,5470 <__divdf3+0x118>
    53ec:	7ff00713          	li	a4,2047
    53f0:	18e78c63          	beq	a5,a4,5588 <__divdf3+0x230>
    53f4:	00341413          	slli	s0,s0,0x3
    53f8:	01dbd713          	srli	a4,s7,0x1d
    53fc:	00876733          	or	a4,a4,s0
    5400:	c0178793          	addi	a5,a5,-1023
    5404:	00800437          	lui	s0,0x800
    5408:	00876433          	or	s0,a4,s0
    540c:	003b9893          	slli	a7,s7,0x3
    5410:	40f989b3          	sub	s3,s3,a5
    5414:	00000613          	li	a2,0
    5418:	00f00713          	li	a4,15
    541c:	012a46b3          	xor	a3,s4,s2
    5420:	24976663          	bltu	a4,s1,566c <__divdf3+0x314>
    5424:	00002717          	auipc	a4,0x2
    5428:	1d070713          	addi	a4,a4,464 # 75f4 <s_table+0x50>
    542c:	00249493          	slli	s1,s1,0x2
    5430:	00e484b3          	add	s1,s1,a4
    5434:	0004a783          	lw	a5,0(s1)
    5438:	00e787b3          	add	a5,a5,a4
    543c:	00078067          	jr	a5
    5440:	00a4eab3          	or	s5,s1,a0
    5444:	1c0a9e63          	bnez	s5,5620 <__divdf3+0x2c8>
    5448:	01495793          	srli	a5,s2,0x14
    544c:	00c91413          	slli	s0,s2,0xc
    5450:	7ff7f793          	andi	a5,a5,2047
    5454:	00000b13          	li	s6,0
    5458:	00800493          	li	s1,8
    545c:	7ff00993          	li	s3,2047
    5460:	00200c13          	li	s8,2
    5464:	00c45413          	srli	s0,s0,0xc
    5468:	01f95913          	srli	s2,s2,0x1f
    546c:	f80790e3          	bnez	a5,53ec <__divdf3+0x94>
    5470:	017468b3          	or	a7,s0,s7
    5474:	1c088263          	beqz	a7,5638 <__divdf3+0x2e0>
    5478:	4a040a63          	beqz	s0,592c <__divdf3+0x5d4>
    547c:	00040513          	mv	a0,s0
    5480:	351010ef          	jal	6fd0 <__clzsi2>
    5484:	00050793          	mv	a5,a0
    5488:	ff550693          	addi	a3,a0,-11
    548c:	01d00713          	li	a4,29
    5490:	ff878893          	addi	a7,a5,-8
    5494:	40d70733          	sub	a4,a4,a3
    5498:	01141433          	sll	s0,s0,a7
    549c:	00ebd733          	srl	a4,s7,a4
    54a0:	00876433          	or	s0,a4,s0
    54a4:	011b98b3          	sll	a7,s7,a7
    54a8:	013787b3          	add	a5,a5,s3
    54ac:	3f378993          	addi	s3,a5,1011
    54b0:	00000613          	li	a2,0
    54b4:	f65ff06f          	j	5418 <__divdf3+0xc0>
    54b8:	40f70733          	sub	a4,a4,a5
    54bc:	03800613          	li	a2,56
    54c0:	4ee65a63          	bge	a2,a4,59b4 <__divdf3+0x65c>
    54c4:	00000793          	li	a5,0
    54c8:	00000613          	li	a2,0
    54cc:	00000713          	li	a4,0
    54d0:	02c12083          	lw	ra,44(sp)
    54d4:	02812403          	lw	s0,40(sp)
    54d8:	01479793          	slli	a5,a5,0x14
    54dc:	00c7e7b3          	or	a5,a5,a2
    54e0:	01f69693          	slli	a3,a3,0x1f
    54e4:	00d7e7b3          	or	a5,a5,a3
    54e8:	02412483          	lw	s1,36(sp)
    54ec:	02012903          	lw	s2,32(sp)
    54f0:	01c12983          	lw	s3,28(sp)
    54f4:	01812a03          	lw	s4,24(sp)
    54f8:	01412a83          	lw	s5,20(sp)
    54fc:	01012b03          	lw	s6,16(sp)
    5500:	00c12b83          	lw	s7,12(sp)
    5504:	00812c03          	lw	s8,8(sp)
    5508:	00070513          	mv	a0,a4
    550c:	00078593          	mv	a1,a5
    5510:	03010113          	addi	sp,sp,48
    5514:	00008067          	ret
    5518:	7ff00793          	li	a5,2047
    551c:	00000613          	li	a2,0
    5520:	00000713          	li	a4,0
    5524:	fadff06f          	j	54d0 <__divdf3+0x178>
    5528:	00000693          	li	a3,0
    552c:	7ff00793          	li	a5,2047
    5530:	00080637          	lui	a2,0x80
    5534:	00000713          	li	a4,0
    5538:	f99ff06f          	j	54d0 <__divdf3+0x178>
    553c:	00a4eab3          	or	s5,s1,a0
    5540:	100a8c63          	beqz	s5,5658 <__divdf3+0x300>
    5544:	40048863          	beqz	s1,5954 <__divdf3+0x5fc>
    5548:	00048513          	mv	a0,s1
    554c:	285010ef          	jal	6fd0 <__clzsi2>
    5550:	00050713          	mv	a4,a0
    5554:	ff550693          	addi	a3,a0,-11
    5558:	01d00793          	li	a5,29
    555c:	ff870b13          	addi	s6,a4,-8
    5560:	40d787b3          	sub	a5,a5,a3
    5564:	016494b3          	sll	s1,s1,s6
    5568:	00f457b3          	srl	a5,s0,a5
    556c:	0097eab3          	or	s5,a5,s1
    5570:	01641b33          	sll	s6,s0,s6
    5574:	c0d00993          	li	s3,-1011
    5578:	40e989b3          	sub	s3,s3,a4
    557c:	00000493          	li	s1,0
    5580:	00000c13          	li	s8,0
    5584:	e51ff06f          	j	53d4 <__divdf3+0x7c>
    5588:	017468b3          	or	a7,s0,s7
    558c:	80198993          	addi	s3,s3,-2047
    5590:	0a089c63          	bnez	a7,5648 <__divdf3+0x2f0>
    5594:	0024e493          	ori	s1,s1,2
    5598:	00000413          	li	s0,0
    559c:	00200613          	li	a2,2
    55a0:	e79ff06f          	j	5418 <__divdf3+0xc0>
    55a4:	000a0913          	mv	s2,s4
    55a8:	000a8413          	mv	s0,s5
    55ac:	000b0893          	mv	a7,s6
    55b0:	00200793          	li	a5,2
    55b4:	4efc0863          	beq	s8,a5,5aa4 <__divdf3+0x74c>
    55b8:	00300793          	li	a5,3
    55bc:	f6fc06e3          	beq	s8,a5,5528 <__divdf3+0x1d0>
    55c0:	00100793          	li	a5,1
    55c4:	00090693          	mv	a3,s2
    55c8:	eefc0ee3          	beq	s8,a5,54c4 <__divdf3+0x16c>
    55cc:	3ff98793          	addi	a5,s3,1023
    55d0:	2af05663          	blez	a5,587c <__divdf3+0x524>
    55d4:	0078f713          	andi	a4,a7,7
    55d8:	4a071663          	bnez	a4,5a84 <__divdf3+0x72c>
    55dc:	00741713          	slli	a4,s0,0x7
    55e0:	00075a63          	bgez	a4,55f4 <__divdf3+0x29c>
    55e4:	ff0007b7          	lui	a5,0xff000
    55e8:	fff78793          	addi	a5,a5,-1 # feffffff <__freertos_irq_stack_top+0xfeff717f>
    55ec:	00f47433          	and	s0,s0,a5
    55f0:	40098793          	addi	a5,s3,1024
    55f4:	7fe00713          	li	a4,2046
    55f8:	f2f740e3          	blt	a4,a5,5518 <__divdf3+0x1c0>
    55fc:	0038d893          	srli	a7,a7,0x3
    5600:	01d41713          	slli	a4,s0,0x1d
    5604:	00941613          	slli	a2,s0,0x9
    5608:	01176733          	or	a4,a4,a7
    560c:	00c65613          	srli	a2,a2,0xc
    5610:	7ff7f793          	andi	a5,a5,2047
    5614:	ebdff06f          	j	54d0 <__divdf3+0x178>
    5618:	00060c13          	mv	s8,a2
    561c:	f95ff06f          	j	55b0 <__divdf3+0x258>
    5620:	00048a93          	mv	s5,s1
    5624:	00050b13          	mv	s6,a0
    5628:	00c00493          	li	s1,12
    562c:	7ff00993          	li	s3,2047
    5630:	00300c13          	li	s8,3
    5634:	da1ff06f          	j	53d4 <__divdf3+0x7c>
    5638:	0014e493          	ori	s1,s1,1
    563c:	00000413          	li	s0,0
    5640:	00100613          	li	a2,1
    5644:	dd5ff06f          	j	5418 <__divdf3+0xc0>
    5648:	0034e493          	ori	s1,s1,3
    564c:	000b8893          	mv	a7,s7
    5650:	00300613          	li	a2,3
    5654:	dc5ff06f          	j	5418 <__divdf3+0xc0>
    5658:	00000b13          	li	s6,0
    565c:	00400493          	li	s1,4
    5660:	00000993          	li	s3,0
    5664:	00100c13          	li	s8,1
    5668:	d6dff06f          	j	53d4 <__divdf3+0x7c>
    566c:	2b546463          	bltu	s0,s5,5914 <__divdf3+0x5bc>
    5670:	2a8a8063          	beq	s5,s0,5910 <__divdf3+0x5b8>
    5674:	000b0313          	mv	t1,s6
    5678:	fff98993          	addi	s3,s3,-1
    567c:	000a8793          	mv	a5,s5
    5680:	00000b13          	li	s6,0
    5684:	00841713          	slli	a4,s0,0x8
    5688:	01075513          	srli	a0,a4,0x10
    568c:	02a7d433          	divu	s0,a5,a0
    5690:	0188d613          	srli	a2,a7,0x18
    5694:	00e66633          	or	a2,a2,a4
    5698:	01061813          	slli	a6,a2,0x10
    569c:	01085813          	srli	a6,a6,0x10
    56a0:	00889593          	slli	a1,a7,0x8
    56a4:	01035713          	srli	a4,t1,0x10
    56a8:	02a7f7b3          	remu	a5,a5,a0
    56ac:	028808b3          	mul	a7,a6,s0
    56b0:	01079793          	slli	a5,a5,0x10
    56b4:	00f767b3          	or	a5,a4,a5
    56b8:	0117fa63          	bgeu	a5,a7,56cc <__divdf3+0x374>
    56bc:	00f607b3          	add	a5,a2,a5
    56c0:	fff40713          	addi	a4,s0,-1 # 7fffff <__freertos_irq_stack_top+0x7f717f>
    56c4:	2ec7f063          	bgeu	a5,a2,59a4 <__divdf3+0x64c>
    56c8:	00070413          	mv	s0,a4
    56cc:	411787b3          	sub	a5,a5,a7
    56d0:	02a7d8b3          	divu	a7,a5,a0
    56d4:	01031713          	slli	a4,t1,0x10
    56d8:	01075713          	srli	a4,a4,0x10
    56dc:	02a7f7b3          	remu	a5,a5,a0
    56e0:	03180fb3          	mul	t6,a6,a7
    56e4:	01079793          	slli	a5,a5,0x10
    56e8:	00f76733          	or	a4,a4,a5
    56ec:	01f77a63          	bgeu	a4,t6,5700 <__divdf3+0x3a8>
    56f0:	00e60733          	add	a4,a2,a4
    56f4:	fff88793          	addi	a5,a7,-1
    56f8:	28c77e63          	bgeu	a4,a2,5994 <__divdf3+0x63c>
    56fc:	00078893          	mv	a7,a5
    5700:	01041413          	slli	s0,s0,0x10
    5704:	000102b7          	lui	t0,0x10
    5708:	01146433          	or	s0,s0,a7
    570c:	fff28313          	addi	t1,t0,-1 # ffff <__freertos_irq_stack_top+0x717f>
    5710:	006478b3          	and	a7,s0,t1
    5714:	01045e93          	srli	t4,s0,0x10
    5718:	0105de13          	srli	t3,a1,0x10
    571c:	0065f333          	and	t1,a1,t1
    5720:	03130f33          	mul	t5,t1,a7
    5724:	41f70733          	sub	a4,a4,t6
    5728:	031e08b3          	mul	a7,t3,a7
    572c:	010f5793          	srli	a5,t5,0x10
    5730:	026e8fb3          	mul	t6,t4,t1
    5734:	01f888b3          	add	a7,a7,t6
    5738:	011787b3          	add	a5,a5,a7
    573c:	03ce8eb3          	mul	t4,t4,t3
    5740:	01f7f463          	bgeu	a5,t6,5748 <__divdf3+0x3f0>
    5744:	005e8eb3          	add	t4,t4,t0
    5748:	00010fb7          	lui	t6,0x10
    574c:	ffff8f93          	addi	t6,t6,-1 # ffff <__freertos_irq_stack_top+0x717f>
    5750:	0107d893          	srli	a7,a5,0x10
    5754:	01f7f7b3          	and	a5,a5,t6
    5758:	01079793          	slli	a5,a5,0x10
    575c:	01ff7f33          	and	t5,t5,t6
    5760:	01d888b3          	add	a7,a7,t4
    5764:	01e787b3          	add	a5,a5,t5
    5768:	17176e63          	bltu	a4,a7,58e4 <__divdf3+0x58c>
    576c:	17170a63          	beq	a4,a7,58e0 <__divdf3+0x588>
    5770:	40fb07b3          	sub	a5,s6,a5
    5774:	41170733          	sub	a4,a4,a7
    5778:	00fb3b33          	sltu	s6,s6,a5
    577c:	41670733          	sub	a4,a4,s6
    5780:	2ee60063          	beq	a2,a4,5a60 <__divdf3+0x708>
    5784:	02a758b3          	divu	a7,a4,a0
    5788:	0107de93          	srli	t4,a5,0x10
    578c:	02a77733          	remu	a4,a4,a0
    5790:	03180f33          	mul	t5,a6,a7
    5794:	01071713          	slli	a4,a4,0x10
    5798:	00eee733          	or	a4,t4,a4
    579c:	01e77e63          	bgeu	a4,t5,57b8 <__divdf3+0x460>
    57a0:	00e60733          	add	a4,a2,a4
    57a4:	fff88e93          	addi	t4,a7,-1
    57a8:	2ec76a63          	bltu	a4,a2,5a9c <__divdf3+0x744>
    57ac:	2fe77863          	bgeu	a4,t5,5a9c <__divdf3+0x744>
    57b0:	ffe88893          	addi	a7,a7,-2
    57b4:	00c70733          	add	a4,a4,a2
    57b8:	41e70733          	sub	a4,a4,t5
    57bc:	02a75eb3          	divu	t4,a4,a0
    57c0:	01079793          	slli	a5,a5,0x10
    57c4:	0107d793          	srli	a5,a5,0x10
    57c8:	02a77733          	remu	a4,a4,a0
    57cc:	03d80833          	mul	a6,a6,t4
    57d0:	01071713          	slli	a4,a4,0x10
    57d4:	00e7e7b3          	or	a5,a5,a4
    57d8:	0107fe63          	bgeu	a5,a6,57f4 <__divdf3+0x49c>
    57dc:	00f607b3          	add	a5,a2,a5
    57e0:	fffe8713          	addi	a4,t4,-1
    57e4:	2ac7e863          	bltu	a5,a2,5a94 <__divdf3+0x73c>
    57e8:	2b07f663          	bgeu	a5,a6,5a94 <__divdf3+0x73c>
    57ec:	ffee8e93          	addi	t4,t4,-2
    57f0:	00c787b3          	add	a5,a5,a2
    57f4:	01089893          	slli	a7,a7,0x10
    57f8:	01d8e8b3          	or	a7,a7,t4
    57fc:	01089513          	slli	a0,a7,0x10
    5800:	0108df13          	srli	t5,a7,0x10
    5804:	01055513          	srli	a0,a0,0x10
    5808:	02650eb3          	mul	t4,a0,t1
    580c:	410787b3          	sub	a5,a5,a6
    5810:	02ae0533          	mul	a0,t3,a0
    5814:	010ed713          	srli	a4,t4,0x10
    5818:	026f0333          	mul	t1,t5,t1
    581c:	00650533          	add	a0,a0,t1
    5820:	00a70733          	add	a4,a4,a0
    5824:	03ee0e33          	mul	t3,t3,t5
    5828:	00677663          	bgeu	a4,t1,5834 <__divdf3+0x4dc>
    582c:	00010537          	lui	a0,0x10
    5830:	00ae0e33          	add	t3,t3,a0
    5834:	00010837          	lui	a6,0x10
    5838:	fff80813          	addi	a6,a6,-1 # ffff <__freertos_irq_stack_top+0x717f>
    583c:	01075513          	srli	a0,a4,0x10
    5840:	01077733          	and	a4,a4,a6
    5844:	01071713          	slli	a4,a4,0x10
    5848:	010efeb3          	and	t4,t4,a6
    584c:	01c50533          	add	a0,a0,t3
    5850:	01d70733          	add	a4,a4,t4
    5854:	12a7f263          	bgeu	a5,a0,5978 <__divdf3+0x620>
    5858:	00f607b3          	add	a5,a2,a5
    585c:	fff88313          	addi	t1,a7,-1
    5860:	00078813          	mv	a6,a5
    5864:	1cc7e463          	bltu	a5,a2,5a2c <__divdf3+0x6d4>
    5868:	24a7e863          	bltu	a5,a0,5ab8 <__divdf3+0x760>
    586c:	26a78663          	beq	a5,a0,5ad8 <__divdf3+0x780>
    5870:	00030893          	mv	a7,t1
    5874:	0018e893          	ori	a7,a7,1
    5878:	d55ff06f          	j	55cc <__divdf3+0x274>
    587c:	00100713          	li	a4,1
    5880:	c2079ce3          	bnez	a5,54b8 <__divdf3+0x160>
    5884:	41e98993          	addi	s3,s3,1054
    5888:	013897b3          	sll	a5,a7,s3
    588c:	00f037b3          	snez	a5,a5
    5890:	013419b3          	sll	s3,s0,s3
    5894:	0137e7b3          	or	a5,a5,s3
    5898:	00e8d8b3          	srl	a7,a7,a4
    589c:	00f8e8b3          	or	a7,a7,a5
    58a0:	0078f793          	andi	a5,a7,7
    58a4:	00e45433          	srl	s0,s0,a4
    58a8:	02078063          	beqz	a5,58c8 <__divdf3+0x570>
    58ac:	00f8f793          	andi	a5,a7,15
    58b0:	00400713          	li	a4,4
    58b4:	00e78a63          	beq	a5,a4,58c8 <__divdf3+0x570>
    58b8:	00488793          	addi	a5,a7,4
    58bc:	0117b8b3          	sltu	a7,a5,a7
    58c0:	01140433          	add	s0,s0,a7
    58c4:	00078893          	mv	a7,a5
    58c8:	00841593          	slli	a1,s0,0x8
    58cc:	00100793          	li	a5,1
    58d0:	00000613          	li	a2,0
    58d4:	00000713          	li	a4,0
    58d8:	be05cce3          	bltz	a1,54d0 <__divdf3+0x178>
    58dc:	1340006f          	j	5a10 <__divdf3+0x6b8>
    58e0:	e8fb78e3          	bgeu	s6,a5,5770 <__divdf3+0x418>
    58e4:	00bb0eb3          	add	t4,s6,a1
    58e8:	016ebf33          	sltu	t5,t4,s6
    58ec:	00cf0fb3          	add	t6,t5,a2
    58f0:	01f70733          	add	a4,a4,t6
    58f4:	000e8b13          	mv	s6,t4
    58f8:	fff40f93          	addi	t6,s0,-1
    58fc:	08e67463          	bgeu	a2,a4,5984 <__divdf3+0x62c>
    5900:	15176263          	bltu	a4,a7,5a44 <__divdf3+0x6ec>
    5904:	12e88e63          	beq	a7,a4,5a40 <__divdf3+0x6e8>
    5908:	000f8413          	mv	s0,t6
    590c:	e65ff06f          	j	5770 <__divdf3+0x418>
    5910:	d71b62e3          	bltu	s6,a7,5674 <__divdf3+0x31c>
    5914:	001b5713          	srli	a4,s6,0x1
    5918:	01fa9313          	slli	t1,s5,0x1f
    591c:	001ad793          	srli	a5,s5,0x1
    5920:	00e36333          	or	t1,t1,a4
    5924:	01fb1b13          	slli	s6,s6,0x1f
    5928:	d5dff06f          	j	5684 <__divdf3+0x32c>
    592c:	000b8513          	mv	a0,s7
    5930:	6a0010ef          	jal	6fd0 <__clzsi2>
    5934:	01550693          	addi	a3,a0,21 # 10015 <__freertos_irq_stack_top+0x7195>
    5938:	01c00713          	li	a4,28
    593c:	02050793          	addi	a5,a0,32
    5940:	b4d756e3          	bge	a4,a3,548c <__divdf3+0x134>
    5944:	ff850513          	addi	a0,a0,-8
    5948:	00000893          	li	a7,0
    594c:	00ab9433          	sll	s0,s7,a0
    5950:	b59ff06f          	j	54a8 <__divdf3+0x150>
    5954:	67c010ef          	jal	6fd0 <__clzsi2>
    5958:	01550693          	addi	a3,a0,21
    595c:	01c00793          	li	a5,28
    5960:	02050713          	addi	a4,a0,32
    5964:	bed7dae3          	bge	a5,a3,5558 <__divdf3+0x200>
    5968:	ff850793          	addi	a5,a0,-8
    596c:	00f41ab3          	sll	s5,s0,a5
    5970:	00000b13          	li	s6,0
    5974:	c01ff06f          	j	5574 <__divdf3+0x21c>
    5978:	eea79ee3          	bne	a5,a0,5874 <__divdf3+0x51c>
    597c:	c40708e3          	beqz	a4,55cc <__divdf3+0x274>
    5980:	ed9ff06f          	j	5858 <__divdf3+0x500>
    5984:	f8e612e3          	bne	a2,a4,5908 <__divdf3+0x5b0>
    5988:	f60f0ce3          	beqz	t5,5900 <__divdf3+0x5a8>
    598c:	000f8413          	mv	s0,t6
    5990:	de1ff06f          	j	5770 <__divdf3+0x418>
    5994:	d7f774e3          	bgeu	a4,t6,56fc <__divdf3+0x3a4>
    5998:	ffe88893          	addi	a7,a7,-2
    599c:	00c70733          	add	a4,a4,a2
    59a0:	d61ff06f          	j	5700 <__divdf3+0x3a8>
    59a4:	d317f2e3          	bgeu	a5,a7,56c8 <__divdf3+0x370>
    59a8:	ffe40413          	addi	s0,s0,-2
    59ac:	00c787b3          	add	a5,a5,a2
    59b0:	d1dff06f          	j	56cc <__divdf3+0x374>
    59b4:	01f00613          	li	a2,31
    59b8:	ece656e3          	bge	a2,a4,5884 <__divdf3+0x52c>
    59bc:	fe100613          	li	a2,-31
    59c0:	40f607b3          	sub	a5,a2,a5
    59c4:	02000613          	li	a2,32
    59c8:	00f457b3          	srl	a5,s0,a5
    59cc:	00c70863          	beq	a4,a2,59dc <__divdf3+0x684>
    59d0:	43e98993          	addi	s3,s3,1086
    59d4:	013419b3          	sll	s3,s0,s3
    59d8:	0138e8b3          	or	a7,a7,s3
    59dc:	011038b3          	snez	a7,a7
    59e0:	00f8e8b3          	or	a7,a7,a5
    59e4:	0078f713          	andi	a4,a7,7
    59e8:	00000613          	li	a2,0
    59ec:	02070863          	beqz	a4,5a1c <__divdf3+0x6c4>
    59f0:	00f8f793          	andi	a5,a7,15
    59f4:	00400713          	li	a4,4
    59f8:	00000413          	li	s0,0
    59fc:	00e78a63          	beq	a5,a4,5a10 <__divdf3+0x6b8>
    5a00:	00488793          	addi	a5,a7,4
    5a04:	0117b8b3          	sltu	a7,a5,a7
    5a08:	01103433          	snez	s0,a7
    5a0c:	00078893          	mv	a7,a5
    5a10:	00941613          	slli	a2,s0,0x9
    5a14:	01d41713          	slli	a4,s0,0x1d
    5a18:	00c65613          	srli	a2,a2,0xc
    5a1c:	0038d893          	srli	a7,a7,0x3
    5a20:	00e8e733          	or	a4,a7,a4
    5a24:	00000793          	li	a5,0
    5a28:	aa9ff06f          	j	54d0 <__divdf3+0x178>
    5a2c:	00030893          	mv	a7,t1
    5a30:	e4a812e3          	bne	a6,a0,5874 <__divdf3+0x51c>
    5a34:	b8b70ce3          	beq	a4,a1,55cc <__divdf3+0x274>
    5a38:	0018e893          	ori	a7,a7,1
    5a3c:	b91ff06f          	j	55cc <__divdf3+0x274>
    5a40:	ecfef4e3          	bgeu	t4,a5,5908 <__divdf3+0x5b0>
    5a44:	01d58eb3          	add	t4,a1,t4
    5a48:	00bebf33          	sltu	t5,t4,a1
    5a4c:	00cf0f33          	add	t5,t5,a2
    5a50:	ffe40413          	addi	s0,s0,-2
    5a54:	000e8b13          	mv	s6,t4
    5a58:	01e70733          	add	a4,a4,t5
    5a5c:	d15ff06f          	j	5770 <__divdf3+0x418>
    5a60:	c0200713          	li	a4,-1022
    5a64:	3ff98793          	addi	a5,s3,1023
    5a68:	fff00893          	li	a7,-1
    5a6c:	e0e9c8e3          	blt	s3,a4,587c <__divdf3+0x524>
    5a70:	00488713          	addi	a4,a7,4
    5a74:	011738b3          	sltu	a7,a4,a7
    5a78:	01140433          	add	s0,s0,a7
    5a7c:	00070893          	mv	a7,a4
    5a80:	b5dff06f          	j	55dc <__divdf3+0x284>
    5a84:	00f8f713          	andi	a4,a7,15
    5a88:	00400613          	li	a2,4
    5a8c:	b4c708e3          	beq	a4,a2,55dc <__divdf3+0x284>
    5a90:	fe1ff06f          	j	5a70 <__divdf3+0x718>
    5a94:	00070e93          	mv	t4,a4
    5a98:	d5dff06f          	j	57f4 <__divdf3+0x49c>
    5a9c:	000e8893          	mv	a7,t4
    5aa0:	d19ff06f          	j	57b8 <__divdf3+0x460>
    5aa4:	00090693          	mv	a3,s2
    5aa8:	7ff00793          	li	a5,2047
    5aac:	00000613          	li	a2,0
    5ab0:	00000713          	li	a4,0
    5ab4:	a1dff06f          	j	54d0 <__divdf3+0x178>
    5ab8:	00159313          	slli	t1,a1,0x1
    5abc:	00b33833          	sltu	a6,t1,a1
    5ac0:	00c80833          	add	a6,a6,a2
    5ac4:	01078833          	add	a6,a5,a6
    5ac8:	ffe88893          	addi	a7,a7,-2
    5acc:	00030593          	mv	a1,t1
    5ad0:	f6a802e3          	beq	a6,a0,5a34 <__divdf3+0x6dc>
    5ad4:	da1ff06f          	j	5874 <__divdf3+0x51c>
    5ad8:	fee5e0e3          	bltu	a1,a4,5ab8 <__divdf3+0x760>
    5adc:	00030893          	mv	a7,t1
    5ae0:	f4b71ce3          	bne	a4,a1,5a38 <__divdf3+0x6e0>
    5ae4:	ae9ff06f          	j	55cc <__divdf3+0x274>

00005ae8 <__eqdf2>:
    5ae8:	0145d713          	srli	a4,a1,0x14
    5aec:	001007b7          	lui	a5,0x100
    5af0:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf717f>
    5af4:	0146d813          	srli	a6,a3,0x14
    5af8:	7ff77713          	andi	a4,a4,2047
    5afc:	7ff00313          	li	t1,2047
    5b00:	00b7fe33          	and	t3,a5,a1
    5b04:	00050893          	mv	a7,a0
    5b08:	00d7f7b3          	and	a5,a5,a3
    5b0c:	01f5d593          	srli	a1,a1,0x1f
    5b10:	7ff87813          	andi	a6,a6,2047
    5b14:	01f6d693          	srli	a3,a3,0x1f
    5b18:	00100513          	li	a0,1
    5b1c:	00670c63          	beq	a4,t1,5b34 <__eqdf2+0x4c>
    5b20:	00680863          	beq	a6,t1,5b30 <__eqdf2+0x48>
    5b24:	01071463          	bne	a4,a6,5b2c <__eqdf2+0x44>
    5b28:	02fe0663          	beq	t3,a5,5b54 <__eqdf2+0x6c>
    5b2c:	00008067          	ret
    5b30:	00008067          	ret
    5b34:	fee81ce3          	bne	a6,a4,5b2c <__eqdf2+0x44>
    5b38:	00fe67b3          	or	a5,t3,a5
    5b3c:	00c7e7b3          	or	a5,a5,a2
    5b40:	0117e7b3          	or	a5,a5,a7
    5b44:	fe0794e3          	bnez	a5,5b2c <__eqdf2+0x44>
    5b48:	40d585b3          	sub	a1,a1,a3
    5b4c:	00b03533          	snez	a0,a1
    5b50:	00008067          	ret
    5b54:	fcc89ce3          	bne	a7,a2,5b2c <__eqdf2+0x44>
    5b58:	00d58a63          	beq	a1,a3,5b6c <__eqdf2+0x84>
    5b5c:	fc0718e3          	bnez	a4,5b2c <__eqdf2+0x44>
    5b60:	011e6e33          	or	t3,t3,a7
    5b64:	01c03533          	snez	a0,t3
    5b68:	00008067          	ret
    5b6c:	00000513          	li	a0,0
    5b70:	00008067          	ret

00005b74 <__gedf2>:
    5b74:	0145d893          	srli	a7,a1,0x14
    5b78:	001007b7          	lui	a5,0x100
    5b7c:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf717f>
    5b80:	0146d713          	srli	a4,a3,0x14
    5b84:	7ff8f893          	andi	a7,a7,2047
    5b88:	7ff00e13          	li	t3,2047
    5b8c:	00b7f333          	and	t1,a5,a1
    5b90:	00050813          	mv	a6,a0
    5b94:	00050e93          	mv	t4,a0
    5b98:	00d7f7b3          	and	a5,a5,a3
    5b9c:	01f5d593          	srli	a1,a1,0x1f
    5ba0:	00060f13          	mv	t5,a2
    5ba4:	7ff77513          	andi	a0,a4,2047
    5ba8:	01f6d693          	srli	a3,a3,0x1f
    5bac:	05c88863          	beq	a7,t3,5bfc <__gedf2+0x88>
    5bb0:	03c50463          	beq	a0,t3,5bd8 <__gedf2+0x64>
    5bb4:	06089a63          	bnez	a7,5c28 <__gedf2+0xb4>
    5bb8:	01036833          	or	a6,t1,a6
    5bbc:	06051063          	bnez	a0,5c1c <__gedf2+0xa8>
    5bc0:	00c7e633          	or	a2,a5,a2
    5bc4:	08060c63          	beqz	a2,5c5c <__gedf2+0xe8>
    5bc8:	0a081263          	bnez	a6,5c6c <__gedf2+0xf8>
    5bcc:	00100513          	li	a0,1
    5bd0:	08068263          	beqz	a3,5c54 <__gedf2+0xe0>
    5bd4:	00008067          	ret
    5bd8:	00c7e633          	or	a2,a5,a2
    5bdc:	08061463          	bnez	a2,5c64 <__gedf2+0xf0>
    5be0:	00089663          	bnez	a7,5bec <__gedf2+0x78>
    5be4:	01036333          	or	t1,t1,a6
    5be8:	fe0302e3          	beqz	t1,5bcc <__gedf2+0x58>
    5bec:	06d58063          	beq	a1,a3,5c4c <__gedf2+0xd8>
    5bf0:	06059263          	bnez	a1,5c54 <__gedf2+0xe0>
    5bf4:	00100513          	li	a0,1
    5bf8:	00008067          	ret
    5bfc:	01036333          	or	t1,t1,a6
    5c00:	06031263          	bnez	t1,5c64 <__gedf2+0xf0>
    5c04:	ff1516e3          	bne	a0,a7,5bf0 <__gedf2+0x7c>
    5c08:	00c7e7b3          	or	a5,a5,a2
    5c0c:	04079c63          	bnez	a5,5c64 <__gedf2+0xf0>
    5c10:	fed590e3          	bne	a1,a3,5bf0 <__gedf2+0x7c>
    5c14:	00000513          	li	a0,0
    5c18:	00008067          	ret
    5c1c:	fa0808e3          	beqz	a6,5bcc <__gedf2+0x58>
    5c20:	fcd598e3          	bne	a1,a3,5bf0 <__gedf2+0x7c>
    5c24:	0280006f          	j	5c4c <__gedf2+0xd8>
    5c28:	fc0504e3          	beqz	a0,5bf0 <__gedf2+0x7c>
    5c2c:	fcd592e3          	bne	a1,a3,5bf0 <__gedf2+0x7c>
    5c30:	fd1540e3          	blt	a0,a7,5bf0 <__gedf2+0x7c>
    5c34:	00a8cc63          	blt	a7,a0,5c4c <__gedf2+0xd8>
    5c38:	fa67ece3          	bltu	a5,t1,5bf0 <__gedf2+0x7c>
    5c3c:	00f31863          	bne	t1,a5,5c4c <__gedf2+0xd8>
    5c40:	fbdf68e3          	bltu	t5,t4,5bf0 <__gedf2+0x7c>
    5c44:	00000513          	li	a0,0
    5c48:	f9eef6e3          	bgeu	t4,t5,5bd4 <__gedf2+0x60>
    5c4c:	00100513          	li	a0,1
    5c50:	f80592e3          	bnez	a1,5bd4 <__gedf2+0x60>
    5c54:	fff00513          	li	a0,-1
    5c58:	00008067          	ret
    5c5c:	f8081ae3          	bnez	a6,5bf0 <__gedf2+0x7c>
    5c60:	00008067          	ret
    5c64:	ffe00513          	li	a0,-2
    5c68:	00008067          	ret
    5c6c:	fcd586e3          	beq	a1,a3,5c38 <__gedf2+0xc4>
    5c70:	f81ff06f          	j	5bf0 <__gedf2+0x7c>

00005c74 <__ledf2>:
    5c74:	0145d893          	srli	a7,a1,0x14
    5c78:	001007b7          	lui	a5,0x100
    5c7c:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf717f>
    5c80:	0146d713          	srli	a4,a3,0x14
    5c84:	7ff8f893          	andi	a7,a7,2047
    5c88:	7ff00313          	li	t1,2047
    5c8c:	00b7fe33          	and	t3,a5,a1
    5c90:	00050813          	mv	a6,a0
    5c94:	00050e93          	mv	t4,a0
    5c98:	00d7f7b3          	and	a5,a5,a3
    5c9c:	01f5d593          	srli	a1,a1,0x1f
    5ca0:	00060f13          	mv	t5,a2
    5ca4:	7ff77513          	andi	a0,a4,2047
    5ca8:	01f6d693          	srli	a3,a3,0x1f
    5cac:	04688a63          	beq	a7,t1,5d00 <__ledf2+0x8c>
    5cb0:	02650463          	beq	a0,t1,5cd8 <__ledf2+0x64>
    5cb4:	06089863          	bnez	a7,5d24 <__ledf2+0xb0>
    5cb8:	010e6833          	or	a6,t3,a6
    5cbc:	08051e63          	bnez	a0,5d58 <__ledf2+0xe4>
    5cc0:	00c7e633          	or	a2,a5,a2
    5cc4:	0a060463          	beqz	a2,5d6c <__ledf2+0xf8>
    5cc8:	0a081663          	bnez	a6,5d74 <__ledf2+0x100>
    5ccc:	00100513          	li	a0,1
    5cd0:	08068063          	beqz	a3,5d50 <__ledf2+0xdc>
    5cd4:	00008067          	ret
    5cd8:	00c7e633          	or	a2,a5,a2
    5cdc:	00200513          	li	a0,2
    5ce0:	fe061ae3          	bnez	a2,5cd4 <__ledf2+0x60>
    5ce4:	00089663          	bnez	a7,5cf0 <__ledf2+0x7c>
    5ce8:	010e6e33          	or	t3,t3,a6
    5cec:	fe0e00e3          	beqz	t3,5ccc <__ledf2+0x58>
    5cf0:	04d58c63          	beq	a1,a3,5d48 <__ledf2+0xd4>
    5cf4:	04059e63          	bnez	a1,5d50 <__ledf2+0xdc>
    5cf8:	00100513          	li	a0,1
    5cfc:	00008067          	ret
    5d00:	010e6e33          	or	t3,t3,a6
    5d04:	060e1063          	bnez	t3,5d64 <__ledf2+0xf0>
    5d08:	ff1516e3          	bne	a0,a7,5cf4 <__ledf2+0x80>
    5d0c:	00c7e7b3          	or	a5,a5,a2
    5d10:	00200513          	li	a0,2
    5d14:	fc0790e3          	bnez	a5,5cd4 <__ledf2+0x60>
    5d18:	fcd59ee3          	bne	a1,a3,5cf4 <__ledf2+0x80>
    5d1c:	00000513          	li	a0,0
    5d20:	00008067          	ret
    5d24:	fc0508e3          	beqz	a0,5cf4 <__ledf2+0x80>
    5d28:	fcd596e3          	bne	a1,a3,5cf4 <__ledf2+0x80>
    5d2c:	fd1544e3          	blt	a0,a7,5cf4 <__ledf2+0x80>
    5d30:	00a8cc63          	blt	a7,a0,5d48 <__ledf2+0xd4>
    5d34:	fdc7e0e3          	bltu	a5,t3,5cf4 <__ledf2+0x80>
    5d38:	00fe1863          	bne	t3,a5,5d48 <__ledf2+0xd4>
    5d3c:	fbdf6ce3          	bltu	t5,t4,5cf4 <__ledf2+0x80>
    5d40:	00000513          	li	a0,0
    5d44:	f9eef8e3          	bgeu	t4,t5,5cd4 <__ledf2+0x60>
    5d48:	00100513          	li	a0,1
    5d4c:	f80594e3          	bnez	a1,5cd4 <__ledf2+0x60>
    5d50:	fff00513          	li	a0,-1
    5d54:	00008067          	ret
    5d58:	f6080ae3          	beqz	a6,5ccc <__ledf2+0x58>
    5d5c:	f8d59ce3          	bne	a1,a3,5cf4 <__ledf2+0x80>
    5d60:	fe9ff06f          	j	5d48 <__ledf2+0xd4>
    5d64:	00200513          	li	a0,2
    5d68:	00008067          	ret
    5d6c:	f80814e3          	bnez	a6,5cf4 <__ledf2+0x80>
    5d70:	00008067          	ret
    5d74:	fcd580e3          	beq	a1,a3,5d34 <__ledf2+0xc0>
    5d78:	f7dff06f          	j	5cf4 <__ledf2+0x80>

00005d7c <__muldf3>:
    5d7c:	fd010113          	addi	sp,sp,-48
    5d80:	0145d793          	srli	a5,a1,0x14
    5d84:	02812423          	sw	s0,40(sp)
    5d88:	02912223          	sw	s1,36(sp)
    5d8c:	03212023          	sw	s2,32(sp)
    5d90:	01312e23          	sw	s3,28(sp)
    5d94:	01512a23          	sw	s5,20(sp)
    5d98:	00c59493          	slli	s1,a1,0xc
    5d9c:	02112623          	sw	ra,44(sp)
    5da0:	01412c23          	sw	s4,24(sp)
    5da4:	01612823          	sw	s6,16(sp)
    5da8:	01712623          	sw	s7,12(sp)
    5dac:	01812423          	sw	s8,8(sp)
    5db0:	7ff7f793          	andi	a5,a5,2047
    5db4:	00050413          	mv	s0,a0
    5db8:	00060a93          	mv	s5,a2
    5dbc:	00068993          	mv	s3,a3
    5dc0:	00c4d493          	srli	s1,s1,0xc
    5dc4:	01f5d913          	srli	s2,a1,0x1f
    5dc8:	42078463          	beqz	a5,61f0 <__muldf3+0x474>
    5dcc:	7ff00713          	li	a4,2047
    5dd0:	0ae78663          	beq	a5,a4,5e7c <__muldf3+0x100>
    5dd4:	00349693          	slli	a3,s1,0x3
    5dd8:	01d55713          	srli	a4,a0,0x1d
    5ddc:	00d76733          	or	a4,a4,a3
    5de0:	008006b7          	lui	a3,0x800
    5de4:	00d764b3          	or	s1,a4,a3
    5de8:	00351a13          	slli	s4,a0,0x3
    5dec:	c0178c13          	addi	s8,a5,-1023
    5df0:	00000b13          	li	s6,0
    5df4:	00000b93          	li	s7,0
    5df8:	0149d793          	srli	a5,s3,0x14
    5dfc:	00c99713          	slli	a4,s3,0xc
    5e00:	7ff7f793          	andi	a5,a5,2047
    5e04:	000a8f13          	mv	t5,s5
    5e08:	00c75413          	srli	s0,a4,0xc
    5e0c:	01f9d993          	srli	s3,s3,0x1f
    5e10:	0a078063          	beqz	a5,5eb0 <__muldf3+0x134>
    5e14:	7ff00713          	li	a4,2047
    5e18:	14e78e63          	beq	a5,a4,5f74 <__muldf3+0x1f8>
    5e1c:	00341713          	slli	a4,s0,0x3
    5e20:	01dad593          	srli	a1,s5,0x1d
    5e24:	00e5e5b3          	or	a1,a1,a4
    5e28:	c0178793          	addi	a5,a5,-1023
    5e2c:	00800737          	lui	a4,0x800
    5e30:	00e5e433          	or	s0,a1,a4
    5e34:	003a9f13          	slli	t5,s5,0x3
    5e38:	018788b3          	add	a7,a5,s8
    5e3c:	00000313          	li	t1,0
    5e40:	00a00713          	li	a4,10
    5e44:	00188513          	addi	a0,a7,1
    5e48:	0b674c63          	blt	a4,s6,5f00 <__muldf3+0x184>
    5e4c:	013945b3          	xor	a1,s2,s3
    5e50:	00200793          	li	a5,2
    5e54:	00058813          	mv	a6,a1
    5e58:	1567c663          	blt	a5,s6,5fa4 <__muldf3+0x228>
    5e5c:	fffb0b13          	addi	s6,s6,-1
    5e60:	00100713          	li	a4,1
    5e64:	17676063          	bltu	a4,s6,5fc4 <__muldf3+0x248>
    5e68:	3cf30a63          	beq	t1,a5,623c <__muldf3+0x4c0>
    5e6c:	00040493          	mv	s1,s0
    5e70:	000f0a13          	mv	s4,t5
    5e74:	00030b93          	mv	s7,t1
    5e78:	09c0006f          	j	5f14 <__muldf3+0x198>
    5e7c:	00a4ea33          	or	s4,s1,a0
    5e80:	3c0a1863          	bnez	s4,6250 <__muldf3+0x4d4>
    5e84:	0149d793          	srli	a5,s3,0x14
    5e88:	00c99713          	slli	a4,s3,0xc
    5e8c:	7ff7f793          	andi	a5,a5,2047
    5e90:	00000493          	li	s1,0
    5e94:	00800b13          	li	s6,8
    5e98:	7ff00c13          	li	s8,2047
    5e9c:	00200b93          	li	s7,2
    5ea0:	000a8f13          	mv	t5,s5
    5ea4:	00c75413          	srli	s0,a4,0xc
    5ea8:	01f9d993          	srli	s3,s3,0x1f
    5eac:	f60794e3          	bnez	a5,5e14 <__muldf3+0x98>
    5eb0:	015467b3          	or	a5,s0,s5
    5eb4:	3c078263          	beqz	a5,6278 <__muldf3+0x4fc>
    5eb8:	4a040063          	beqz	s0,6358 <__muldf3+0x5dc>
    5ebc:	00040513          	mv	a0,s0
    5ec0:	110010ef          	jal	6fd0 <__clzsi2>
    5ec4:	00050893          	mv	a7,a0
    5ec8:	ff550713          	addi	a4,a0,-11
    5ecc:	01d00793          	li	a5,29
    5ed0:	ff888f13          	addi	t5,a7,-8
    5ed4:	40e787b3          	sub	a5,a5,a4
    5ed8:	00fad7b3          	srl	a5,s5,a5
    5edc:	01e41733          	sll	a4,s0,t5
    5ee0:	00e7e433          	or	s0,a5,a4
    5ee4:	01ea9f33          	sll	t5,s5,t5
    5ee8:	411c08b3          	sub	a7,s8,a7
    5eec:	c0d88893          	addi	a7,a7,-1011
    5ef0:	00a00713          	li	a4,10
    5ef4:	00000313          	li	t1,0
    5ef8:	00188513          	addi	a0,a7,1
    5efc:	f56758e3          	bge	a4,s6,5e4c <__muldf3+0xd0>
    5f00:	00090593          	mv	a1,s2
    5f04:	00200793          	li	a5,2
    5f08:	32fb8a63          	beq	s7,a5,623c <__muldf3+0x4c0>
    5f0c:	00300793          	li	a5,3
    5f10:	48fb8c63          	beq	s7,a5,63a8 <__muldf3+0x62c>
    5f14:	00100793          	li	a5,1
    5f18:	00058813          	mv	a6,a1
    5f1c:	46fb9a63          	bne	s7,a5,6390 <__muldf3+0x614>
    5f20:	00000793          	li	a5,0
    5f24:	00000693          	li	a3,0
    5f28:	00000713          	li	a4,0
    5f2c:	02c12083          	lw	ra,44(sp)
    5f30:	02812403          	lw	s0,40(sp)
    5f34:	01479793          	slli	a5,a5,0x14
    5f38:	00d7e7b3          	or	a5,a5,a3
    5f3c:	01f81693          	slli	a3,a6,0x1f
    5f40:	00d7e7b3          	or	a5,a5,a3
    5f44:	02412483          	lw	s1,36(sp)
    5f48:	02012903          	lw	s2,32(sp)
    5f4c:	01c12983          	lw	s3,28(sp)
    5f50:	01812a03          	lw	s4,24(sp)
    5f54:	01412a83          	lw	s5,20(sp)
    5f58:	01012b03          	lw	s6,16(sp)
    5f5c:	00c12b83          	lw	s7,12(sp)
    5f60:	00812c03          	lw	s8,8(sp)
    5f64:	00070513          	mv	a0,a4
    5f68:	00078593          	mv	a1,a5
    5f6c:	03010113          	addi	sp,sp,48
    5f70:	00008067          	ret
    5f74:	01546733          	or	a4,s0,s5
    5f78:	7ffc0893          	addi	a7,s8,2047
    5f7c:	30070a63          	beqz	a4,6290 <__muldf3+0x514>
    5f80:	00001737          	lui	a4,0x1
    5f84:	01394833          	xor	a6,s2,s3
    5f88:	80070713          	addi	a4,a4,-2048 # 800 <CUSTOM2+0x7a5>
    5f8c:	003b6b13          	ori	s6,s6,3
    5f90:	00a00693          	li	a3,10
    5f94:	00080593          	mv	a1,a6
    5f98:	00ec0533          	add	a0,s8,a4
    5f9c:	3966c063          	blt	a3,s6,631c <__muldf3+0x5a0>
    5fa0:	00300313          	li	t1,3
    5fa4:	00100613          	li	a2,1
    5fa8:	01661633          	sll	a2,a2,s6
    5fac:	53067713          	andi	a4,a2,1328
    5fb0:	f4071ae3          	bnez	a4,5f04 <__muldf3+0x188>
    5fb4:	24067793          	andi	a5,a2,576
    5fb8:	3c079463          	bnez	a5,6380 <__muldf3+0x604>
    5fbc:	08867613          	andi	a2,a2,136
    5fc0:	2e061263          	bnez	a2,62a4 <__muldf3+0x528>
    5fc4:	00010fb7          	lui	t6,0x10
    5fc8:	ffff8e93          	addi	t4,t6,-1 # ffff <__freertos_irq_stack_top+0x717f>
    5fcc:	01da77b3          	and	a5,s4,t4
    5fd0:	010a5693          	srli	a3,s4,0x10
    5fd4:	01df7eb3          	and	t4,t5,t4
    5fd8:	010f5e13          	srli	t3,t5,0x10
    5fdc:	03d78733          	mul	a4,a5,t4
    5fe0:	03d68333          	mul	t1,a3,t4
    5fe4:	01075593          	srli	a1,a4,0x10
    5fe8:	02fe0633          	mul	a2,t3,a5
    5fec:	00660633          	add	a2,a2,t1
    5ff0:	00c585b3          	add	a1,a1,a2
    5ff4:	03c68f33          	mul	t5,a3,t3
    5ff8:	0065f463          	bgeu	a1,t1,6000 <__muldf3+0x284>
    5ffc:	01ff0f33          	add	t5,t5,t6
    6000:	000103b7          	lui	t2,0x10
    6004:	fff38613          	addi	a2,t2,-1 # ffff <__freertos_irq_stack_top+0x717f>
    6008:	00c5f333          	and	t1,a1,a2
    600c:	01045f93          	srli	t6,s0,0x10
    6010:	00c77733          	and	a4,a4,a2
    6014:	00c47433          	and	s0,s0,a2
    6018:	01031313          	slli	t1,t1,0x10
    601c:	028782b3          	mul	t0,a5,s0
    6020:	00e30333          	add	t1,t1,a4
    6024:	0105d593          	srli	a1,a1,0x10
    6028:	02868733          	mul	a4,a3,s0
    602c:	0102d613          	srli	a2,t0,0x10
    6030:	02ff87b3          	mul	a5,t6,a5
    6034:	00e787b3          	add	a5,a5,a4
    6038:	00f60633          	add	a2,a2,a5
    603c:	03f687b3          	mul	a5,a3,t6
    6040:	00e67463          	bgeu	a2,a4,6048 <__muldf3+0x2cc>
    6044:	007787b3          	add	a5,a5,t2
    6048:	00010937          	lui	s2,0x10
    604c:	fff90993          	addi	s3,s2,-1 # ffff <__freertos_irq_stack_top+0x717f>
    6050:	01367733          	and	a4,a2,s3
    6054:	0104d393          	srli	t2,s1,0x10
    6058:	0134f6b3          	and	a3,s1,s3
    605c:	0132f2b3          	and	t0,t0,s3
    6060:	01071713          	slli	a4,a4,0x10
    6064:	02de84b3          	mul	s1,t4,a3
    6068:	00570733          	add	a4,a4,t0
    606c:	01065613          	srli	a2,a2,0x10
    6070:	00f60633          	add	a2,a2,a5
    6074:	00e585b3          	add	a1,a1,a4
    6078:	02de02b3          	mul	t0,t3,a3
    607c:	0104d793          	srli	a5,s1,0x10
    6080:	03d38eb3          	mul	t4,t2,t4
    6084:	01d282b3          	add	t0,t0,t4
    6088:	005787b3          	add	a5,a5,t0
    608c:	027e0e33          	mul	t3,t3,t2
    6090:	01d7f463          	bgeu	a5,t4,6098 <__muldf3+0x31c>
    6094:	012e0e33          	add	t3,t3,s2
    6098:	000109b7          	lui	s3,0x10
    609c:	fff98e93          	addi	t4,s3,-1 # ffff <__freertos_irq_stack_top+0x717f>
    60a0:	01d7f2b3          	and	t0,a5,t4
    60a4:	0107d793          	srli	a5,a5,0x10
    60a8:	01c787b3          	add	a5,a5,t3
    60ac:	01d4feb3          	and	t4,s1,t4
    60b0:	01029293          	slli	t0,t0,0x10
    60b4:	02d40933          	mul	s2,s0,a3
    60b8:	01d282b3          	add	t0,t0,t4
    60bc:	02838433          	mul	s0,t2,s0
    60c0:	01095e13          	srli	t3,s2,0x10
    60c4:	02df86b3          	mul	a3,t6,a3
    60c8:	008686b3          	add	a3,a3,s0
    60cc:	00de0e33          	add	t3,t3,a3
    60d0:	027f8eb3          	mul	t4,t6,t2
    60d4:	008e7463          	bgeu	t3,s0,60dc <__muldf3+0x360>
    60d8:	013e8eb3          	add	t4,t4,s3
    60dc:	00010fb7          	lui	t6,0x10
    60e0:	ffff8f93          	addi	t6,t6,-1 # ffff <__freertos_irq_stack_top+0x717f>
    60e4:	01fe76b3          	and	a3,t3,t6
    60e8:	01069693          	slli	a3,a3,0x10
    60ec:	01f97933          	and	s2,s2,t6
    60f0:	01e585b3          	add	a1,a1,t5
    60f4:	012686b3          	add	a3,a3,s2
    60f8:	00c68633          	add	a2,a3,a2
    60fc:	00e5b733          	sltu	a4,a1,a4
    6100:	00e60733          	add	a4,a2,a4
    6104:	00558f33          	add	t5,a1,t0
    6108:	00f707b3          	add	a5,a4,a5
    610c:	00bf35b3          	sltu	a1,t5,a1
    6110:	00b785b3          	add	a1,a5,a1
    6114:	00d636b3          	sltu	a3,a2,a3
    6118:	00c73633          	sltu	a2,a4,a2
    611c:	00c6e6b3          	or	a3,a3,a2
    6120:	00e7b733          	sltu	a4,a5,a4
    6124:	010e5e13          	srli	t3,t3,0x10
    6128:	00f5b7b3          	sltu	a5,a1,a5
    612c:	01c686b3          	add	a3,a3,t3
    6130:	00f76733          	or	a4,a4,a5
    6134:	009f1793          	slli	a5,t5,0x9
    6138:	00d70733          	add	a4,a4,a3
    613c:	0067e7b3          	or	a5,a5,t1
    6140:	01d70733          	add	a4,a4,t4
    6144:	00f037b3          	snez	a5,a5
    6148:	017f5613          	srli	a2,t5,0x17
    614c:	00971713          	slli	a4,a4,0x9
    6150:	0175d693          	srli	a3,a1,0x17
    6154:	00c7e7b3          	or	a5,a5,a2
    6158:	00959593          	slli	a1,a1,0x9
    615c:	00b7ea33          	or	s4,a5,a1
    6160:	00771793          	slli	a5,a4,0x7
    6164:	00d764b3          	or	s1,a4,a3
    6168:	0207d063          	bgez	a5,6188 <__muldf3+0x40c>
    616c:	001a5713          	srli	a4,s4,0x1
    6170:	001a7793          	andi	a5,s4,1
    6174:	01f49693          	slli	a3,s1,0x1f
    6178:	00f767b3          	or	a5,a4,a5
    617c:	00d7ea33          	or	s4,a5,a3
    6180:	0014d493          	srli	s1,s1,0x1
    6184:	00050893          	mv	a7,a0
    6188:	3ff88613          	addi	a2,a7,1023
    618c:	12c05663          	blez	a2,62b8 <__muldf3+0x53c>
    6190:	007a7793          	andi	a5,s4,7
    6194:	02078063          	beqz	a5,61b4 <__muldf3+0x438>
    6198:	00fa7793          	andi	a5,s4,15
    619c:	00400713          	li	a4,4
    61a0:	00e78a63          	beq	a5,a4,61b4 <__muldf3+0x438>
    61a4:	004a0713          	addi	a4,s4,4
    61a8:	014737b3          	sltu	a5,a4,s4
    61ac:	00f484b3          	add	s1,s1,a5
    61b0:	00070a13          	mv	s4,a4
    61b4:	00749793          	slli	a5,s1,0x7
    61b8:	0007da63          	bgez	a5,61cc <__muldf3+0x450>
    61bc:	ff0007b7          	lui	a5,0xff000
    61c0:	fff78793          	addi	a5,a5,-1 # feffffff <__freertos_irq_stack_top+0xfeff717f>
    61c4:	00f4f4b3          	and	s1,s1,a5
    61c8:	40088613          	addi	a2,a7,1024
    61cc:	7fe00793          	li	a5,2046
    61d0:	1cc7c463          	blt	a5,a2,6398 <__muldf3+0x61c>
    61d4:	003a5793          	srli	a5,s4,0x3
    61d8:	01d49713          	slli	a4,s1,0x1d
    61dc:	00949693          	slli	a3,s1,0x9
    61e0:	00f76733          	or	a4,a4,a5
    61e4:	00c6d693          	srli	a3,a3,0xc
    61e8:	7ff67793          	andi	a5,a2,2047
    61ec:	d41ff06f          	j	5f2c <__muldf3+0x1b0>
    61f0:	00a4ea33          	or	s4,s1,a0
    61f4:	060a0863          	beqz	s4,6264 <__muldf3+0x4e8>
    61f8:	12048e63          	beqz	s1,6334 <__muldf3+0x5b8>
    61fc:	00048513          	mv	a0,s1
    6200:	5d1000ef          	jal	6fd0 <__clzsi2>
    6204:	00050613          	mv	a2,a0
    6208:	ff550693          	addi	a3,a0,-11
    620c:	01d00713          	li	a4,29
    6210:	ff860793          	addi	a5,a2,-8 # 7fff8 <__freertos_irq_stack_top+0x77178>
    6214:	40d70733          	sub	a4,a4,a3
    6218:	00e45733          	srl	a4,s0,a4
    621c:	00f496b3          	sll	a3,s1,a5
    6220:	00d764b3          	or	s1,a4,a3
    6224:	00f41a33          	sll	s4,s0,a5
    6228:	c0d00793          	li	a5,-1011
    622c:	40c78c33          	sub	s8,a5,a2
    6230:	00000b13          	li	s6,0
    6234:	00000b93          	li	s7,0
    6238:	bc1ff06f          	j	5df8 <__muldf3+0x7c>
    623c:	00058813          	mv	a6,a1
    6240:	7ff00793          	li	a5,2047
    6244:	00000693          	li	a3,0
    6248:	00000713          	li	a4,0
    624c:	ce1ff06f          	j	5f2c <__muldf3+0x1b0>
    6250:	00050a13          	mv	s4,a0
    6254:	00c00b13          	li	s6,12
    6258:	7ff00c13          	li	s8,2047
    625c:	00300b93          	li	s7,3
    6260:	b99ff06f          	j	5df8 <__muldf3+0x7c>
    6264:	00000493          	li	s1,0
    6268:	00400b13          	li	s6,4
    626c:	00000c13          	li	s8,0
    6270:	00100b93          	li	s7,1
    6274:	b85ff06f          	j	5df8 <__muldf3+0x7c>
    6278:	001b6b13          	ori	s6,s6,1
    627c:	000c0893          	mv	a7,s8
    6280:	00000413          	li	s0,0
    6284:	00000f13          	li	t5,0
    6288:	00100313          	li	t1,1
    628c:	bb5ff06f          	j	5e40 <__muldf3+0xc4>
    6290:	002b6b13          	ori	s6,s6,2
    6294:	00000413          	li	s0,0
    6298:	00000f13          	li	t5,0
    629c:	00200313          	li	t1,2
    62a0:	ba1ff06f          	j	5e40 <__muldf3+0xc4>
    62a4:	00040493          	mv	s1,s0
    62a8:	000f0a13          	mv	s4,t5
    62ac:	00030b93          	mv	s7,t1
    62b0:	00098593          	mv	a1,s3
    62b4:	c51ff06f          	j	5f04 <__muldf3+0x188>
    62b8:	00100713          	li	a4,1
    62bc:	10061063          	bnez	a2,63bc <__muldf3+0x640>
    62c0:	41e88893          	addi	a7,a7,1054
    62c4:	011a1633          	sll	a2,s4,a7
    62c8:	00c03633          	snez	a2,a2
    62cc:	011498b3          	sll	a7,s1,a7
    62d0:	00ea57b3          	srl	a5,s4,a4
    62d4:	01166633          	or	a2,a2,a7
    62d8:	00f66633          	or	a2,a2,a5
    62dc:	00767793          	andi	a5,a2,7
    62e0:	00e4d5b3          	srl	a1,s1,a4
    62e4:	02078063          	beqz	a5,6304 <__muldf3+0x588>
    62e8:	00f67793          	andi	a5,a2,15
    62ec:	00400713          	li	a4,4
    62f0:	00e78a63          	beq	a5,a4,6304 <__muldf3+0x588>
    62f4:	00460793          	addi	a5,a2,4
    62f8:	00c7b633          	sltu	a2,a5,a2
    62fc:	00c585b3          	add	a1,a1,a2
    6300:	00078613          	mv	a2,a5
    6304:	00859513          	slli	a0,a1,0x8
    6308:	00100793          	li	a5,1
    630c:	00000693          	li	a3,0
    6310:	00000713          	li	a4,0
    6314:	c0054ce3          	bltz	a0,5f2c <__muldf3+0x1b0>
    6318:	10c0006f          	j	6424 <__muldf3+0x6a8>
    631c:	00f00713          	li	a4,15
    6320:	12eb1063          	bne	s6,a4,6440 <__muldf3+0x6c4>
    6324:	00000813          	li	a6,0
    6328:	000806b7          	lui	a3,0x80
    632c:	00000713          	li	a4,0
    6330:	bfdff06f          	j	5f2c <__muldf3+0x1b0>
    6334:	49d000ef          	jal	6fd0 <__clzsi2>
    6338:	01550693          	addi	a3,a0,21
    633c:	01c00793          	li	a5,28
    6340:	02050613          	addi	a2,a0,32
    6344:	ecd7d4e3          	bge	a5,a3,620c <__muldf3+0x490>
    6348:	ff850513          	addi	a0,a0,-8
    634c:	00000a13          	li	s4,0
    6350:	00a414b3          	sll	s1,s0,a0
    6354:	ed5ff06f          	j	6228 <__muldf3+0x4ac>
    6358:	000a8513          	mv	a0,s5
    635c:	475000ef          	jal	6fd0 <__clzsi2>
    6360:	01550713          	addi	a4,a0,21
    6364:	01c00793          	li	a5,28
    6368:	02050893          	addi	a7,a0,32
    636c:	b6e7d0e3          	bge	a5,a4,5ecc <__muldf3+0x150>
    6370:	ff850513          	addi	a0,a0,-8
    6374:	00000f13          	li	t5,0
    6378:	00aa9433          	sll	s0,s5,a0
    637c:	b6dff06f          	j	5ee8 <__muldf3+0x16c>
    6380:	00000813          	li	a6,0
    6384:	7ff00793          	li	a5,2047
    6388:	000806b7          	lui	a3,0x80
    638c:	ba1ff06f          	j	5f2c <__muldf3+0x1b0>
    6390:	00050893          	mv	a7,a0
    6394:	df5ff06f          	j	6188 <__muldf3+0x40c>
    6398:	7ff00793          	li	a5,2047
    639c:	00000693          	li	a3,0
    63a0:	00000713          	li	a4,0
    63a4:	b89ff06f          	j	5f2c <__muldf3+0x1b0>
    63a8:	00000813          	li	a6,0
    63ac:	7ff00793          	li	a5,2047
    63b0:	000806b7          	lui	a3,0x80
    63b4:	00000713          	li	a4,0
    63b8:	b75ff06f          	j	5f2c <__muldf3+0x1b0>
    63bc:	40c70733          	sub	a4,a4,a2
    63c0:	03800793          	li	a5,56
    63c4:	b4e7cee3          	blt	a5,a4,5f20 <__muldf3+0x1a4>
    63c8:	01f00793          	li	a5,31
    63cc:	eee7dae3          	bge	a5,a4,62c0 <__muldf3+0x544>
    63d0:	fe100793          	li	a5,-31
    63d4:	40c787b3          	sub	a5,a5,a2
    63d8:	02000693          	li	a3,32
    63dc:	00f4d7b3          	srl	a5,s1,a5
    63e0:	00d70863          	beq	a4,a3,63f0 <__muldf3+0x674>
    63e4:	43e88893          	addi	a7,a7,1086
    63e8:	011498b3          	sll	a7,s1,a7
    63ec:	011a6a33          	or	s4,s4,a7
    63f0:	01403633          	snez	a2,s4
    63f4:	00f66633          	or	a2,a2,a5
    63f8:	00767713          	andi	a4,a2,7
    63fc:	00000693          	li	a3,0
    6400:	02070863          	beqz	a4,6430 <__muldf3+0x6b4>
    6404:	00f67793          	andi	a5,a2,15
    6408:	00400713          	li	a4,4
    640c:	00000593          	li	a1,0
    6410:	00e78a63          	beq	a5,a4,6424 <__muldf3+0x6a8>
    6414:	00460793          	addi	a5,a2,4
    6418:	00c7b633          	sltu	a2,a5,a2
    641c:	00c035b3          	snez	a1,a2
    6420:	00078613          	mv	a2,a5
    6424:	00959693          	slli	a3,a1,0x9
    6428:	01d59713          	slli	a4,a1,0x1d
    642c:	00c6d693          	srli	a3,a3,0xc
    6430:	00365613          	srli	a2,a2,0x3
    6434:	00e66733          	or	a4,a2,a4
    6438:	00000793          	li	a5,0
    643c:	af1ff06f          	j	5f2c <__muldf3+0x1b0>
    6440:	00040493          	mv	s1,s0
    6444:	000a8a13          	mv	s4,s5
    6448:	00300b93          	li	s7,3
    644c:	00098593          	mv	a1,s3
    6450:	ab5ff06f          	j	5f04 <__muldf3+0x188>

00006454 <__subdf3>:
    6454:	001007b7          	lui	a5,0x100
    6458:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf717f>
    645c:	fe010113          	addi	sp,sp,-32
    6460:	00b7f8b3          	and	a7,a5,a1
    6464:	00d7f833          	and	a6,a5,a3
    6468:	0146d793          	srli	a5,a3,0x14
    646c:	00389893          	slli	a7,a7,0x3
    6470:	00812c23          	sw	s0,24(sp)
    6474:	01312623          	sw	s3,12(sp)
    6478:	01f5d413          	srli	s0,a1,0x1f
    647c:	0145d993          	srli	s3,a1,0x14
    6480:	01d55713          	srli	a4,a0,0x1d
    6484:	00381813          	slli	a6,a6,0x3
    6488:	01d65593          	srli	a1,a2,0x1d
    648c:	00112e23          	sw	ra,28(sp)
    6490:	00912a23          	sw	s1,20(sp)
    6494:	01212823          	sw	s2,16(sp)
    6498:	7ff7ff13          	andi	t5,a5,2047
    649c:	7ff00313          	li	t1,2047
    64a0:	01176733          	or	a4,a4,a7
    64a4:	7ff9f993          	andi	s3,s3,2047
    64a8:	00040e13          	mv	t3,s0
    64ac:	00351893          	slli	a7,a0,0x3
    64b0:	01f6d693          	srli	a3,a3,0x1f
    64b4:	0105e5b3          	or	a1,a1,a6
    64b8:	00361e93          	slli	t4,a2,0x3
    64bc:	206f0c63          	beq	t5,t1,66d4 <__subdf3+0x280>
    64c0:	0016c693          	xori	a3,a3,1
    64c4:	41e987b3          	sub	a5,s3,t5
    64c8:	16d40263          	beq	s0,a3,662c <__subdf3+0x1d8>
    64cc:	00f05ae3          	blez	a5,6ce0 <__subdf3+0x88c>
    64d0:	240f0a63          	beqz	t5,6724 <__subdf3+0x2d0>
    64d4:	3c698463          	beq	s3,t1,689c <__subdf3+0x448>
    64d8:	03800693          	li	a3,56
    64dc:	00100513          	li	a0,1
    64e0:	02f6ce63          	blt	a3,a5,651c <__subdf3+0xc8>
    64e4:	008006b7          	lui	a3,0x800
    64e8:	00d5e5b3          	or	a1,a1,a3
    64ec:	01f00693          	li	a3,31
    64f0:	4ef6c463          	blt	a3,a5,69d8 <__subdf3+0x584>
    64f4:	02000693          	li	a3,32
    64f8:	40f686b3          	sub	a3,a3,a5
    64fc:	00d59533          	sll	a0,a1,a3
    6500:	00fed633          	srl	a2,t4,a5
    6504:	00de96b3          	sll	a3,t4,a3
    6508:	00c56533          	or	a0,a0,a2
    650c:	00d036b3          	snez	a3,a3
    6510:	00f5d7b3          	srl	a5,a1,a5
    6514:	00d56533          	or	a0,a0,a3
    6518:	40f70733          	sub	a4,a4,a5
    651c:	40a88533          	sub	a0,a7,a0
    6520:	00a8b633          	sltu	a2,a7,a0
    6524:	00050493          	mv	s1,a0
    6528:	40c70933          	sub	s2,a4,a2
    652c:	00891793          	slli	a5,s2,0x8
    6530:	3407d863          	bgez	a5,6880 <__subdf3+0x42c>
    6534:	008007b7          	lui	a5,0x800
    6538:	fff78793          	addi	a5,a5,-1 # 7fffff <__freertos_irq_stack_top+0x7f717f>
    653c:	00f97933          	and	s2,s2,a5
    6540:	2e090663          	beqz	s2,682c <__subdf3+0x3d8>
    6544:	00090513          	mv	a0,s2
    6548:	289000ef          	jal	6fd0 <__clzsi2>
    654c:	ff850793          	addi	a5,a0,-8
    6550:	02000693          	li	a3,32
    6554:	40f68733          	sub	a4,a3,a5
    6558:	00e4d733          	srl	a4,s1,a4
    655c:	00f91933          	sll	s2,s2,a5
    6560:	01276733          	or	a4,a4,s2
    6564:	00f494b3          	sll	s1,s1,a5
    6568:	3f37c463          	blt	a5,s3,6950 <__subdf3+0x4fc>
    656c:	413787b3          	sub	a5,a5,s3
    6570:	00178793          	addi	a5,a5,1
    6574:	40f686b3          	sub	a3,a3,a5
    6578:	00d49633          	sll	a2,s1,a3
    657c:	00f4d933          	srl	s2,s1,a5
    6580:	00c03633          	snez	a2,a2
    6584:	00c96633          	or	a2,s2,a2
    6588:	00d716b3          	sll	a3,a4,a3
    658c:	00c6e4b3          	or	s1,a3,a2
    6590:	00f75933          	srl	s2,a4,a5
    6594:	00000993          	li	s3,0
    6598:	0074f793          	andi	a5,s1,7
    659c:	02078063          	beqz	a5,65bc <__subdf3+0x168>
    65a0:	00f4f793          	andi	a5,s1,15
    65a4:	00400713          	li	a4,4
    65a8:	00e78a63          	beq	a5,a4,65bc <__subdf3+0x168>
    65ac:	00448793          	addi	a5,s1,4
    65b0:	0097b533          	sltu	a0,a5,s1
    65b4:	00a90933          	add	s2,s2,a0
    65b8:	00078493          	mv	s1,a5
    65bc:	00891793          	slli	a5,s2,0x8
    65c0:	6c07d063          	bgez	a5,6c80 <__subdf3+0x82c>
    65c4:	00198793          	addi	a5,s3,1
    65c8:	7ff00713          	li	a4,2047
    65cc:	24e78663          	beq	a5,a4,6818 <__subdf3+0x3c4>
    65d0:	ff800737          	lui	a4,0xff800
    65d4:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f717f>
    65d8:	00e97733          	and	a4,s2,a4
    65dc:	7ff7f793          	andi	a5,a5,2047
    65e0:	01d71813          	slli	a6,a4,0x1d
    65e4:	0034d513          	srli	a0,s1,0x3
    65e8:	00971713          	slli	a4,a4,0x9
    65ec:	00a86833          	or	a6,a6,a0
    65f0:	00c75713          	srli	a4,a4,0xc
    65f4:	00147e13          	andi	t3,s0,1
    65f8:	01c12083          	lw	ra,28(sp)
    65fc:	01812403          	lw	s0,24(sp)
    6600:	01479793          	slli	a5,a5,0x14
    6604:	00e7e7b3          	or	a5,a5,a4
    6608:	01fe1713          	slli	a4,t3,0x1f
    660c:	00e7e7b3          	or	a5,a5,a4
    6610:	01412483          	lw	s1,20(sp)
    6614:	01012903          	lw	s2,16(sp)
    6618:	00c12983          	lw	s3,12(sp)
    661c:	00080513          	mv	a0,a6
    6620:	00078593          	mv	a1,a5
    6624:	02010113          	addi	sp,sp,32
    6628:	00008067          	ret
    662c:	70f05263          	blez	a5,6d30 <__subdf3+0x8dc>
    6630:	1c0f1663          	bnez	t5,67fc <__subdf3+0x3a8>
    6634:	01d5e6b3          	or	a3,a1,t4
    6638:	26068e63          	beqz	a3,68b4 <__subdf3+0x460>
    663c:	fff78693          	addi	a3,a5,-1
    6640:	46068863          	beqz	a3,6ab0 <__subdf3+0x65c>
    6644:	24678c63          	beq	a5,t1,689c <__subdf3+0x448>
    6648:	03800793          	li	a5,56
    664c:	00100913          	li	s2,1
    6650:	02d7cc63          	blt	a5,a3,6688 <__subdf3+0x234>
    6654:	00068793          	mv	a5,a3
    6658:	01f00693          	li	a3,31
    665c:	48f6ca63          	blt	a3,a5,6af0 <__subdf3+0x69c>
    6660:	02000693          	li	a3,32
    6664:	40f686b3          	sub	a3,a3,a5
    6668:	00d59933          	sll	s2,a1,a3
    666c:	00fed633          	srl	a2,t4,a5
    6670:	00de96b3          	sll	a3,t4,a3
    6674:	00c96933          	or	s2,s2,a2
    6678:	00d036b3          	snez	a3,a3
    667c:	00f5d7b3          	srl	a5,a1,a5
    6680:	00d96933          	or	s2,s2,a3
    6684:	00f70733          	add	a4,a4,a5
    6688:	01190633          	add	a2,s2,a7
    668c:	01263933          	sltu	s2,a2,s2
    6690:	00060493          	mv	s1,a2
    6694:	00e90933          	add	s2,s2,a4
    6698:	00891793          	slli	a5,s2,0x8
    669c:	1e07d263          	bgez	a5,6880 <__subdf3+0x42c>
    66a0:	00198993          	addi	s3,s3,1
    66a4:	7ff00793          	li	a5,2047
    66a8:	16f98863          	beq	s3,a5,6818 <__subdf3+0x3c4>
    66ac:	ff8007b7          	lui	a5,0xff800
    66b0:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f717f>
    66b4:	0014f513          	andi	a0,s1,1
    66b8:	00f977b3          	and	a5,s2,a5
    66bc:	0014d713          	srli	a4,s1,0x1
    66c0:	00a76733          	or	a4,a4,a0
    66c4:	01f79513          	slli	a0,a5,0x1f
    66c8:	00e564b3          	or	s1,a0,a4
    66cc:	0017d913          	srli	s2,a5,0x1
    66d0:	ec9ff06f          	j	6598 <__subdf3+0x144>
    66d4:	01d5e833          	or	a6,a1,t4
    66d8:	80198313          	addi	t1,s3,-2047
    66dc:	06080863          	beqz	a6,674c <__subdf3+0x2f8>
    66e0:	06d40a63          	beq	s0,a3,6754 <__subdf3+0x300>
    66e4:	0e030463          	beqz	t1,67cc <__subdf3+0x378>
    66e8:	26098e63          	beqz	s3,6964 <__subdf3+0x510>
    66ec:	00361513          	slli	a0,a2,0x3
    66f0:	00355513          	srli	a0,a0,0x3
    66f4:	00068413          	mv	s0,a3
    66f8:	00058713          	mv	a4,a1
    66fc:	01d71813          	slli	a6,a4,0x1d
    6700:	00a86833          	or	a6,a6,a0
    6704:	00375713          	srli	a4,a4,0x3
    6708:	01076733          	or	a4,a4,a6
    670c:	10070663          	beqz	a4,6818 <__subdf3+0x3c4>
    6710:	00000e13          	li	t3,0
    6714:	7ff00793          	li	a5,2047
    6718:	00080737          	lui	a4,0x80
    671c:	00000813          	li	a6,0
    6720:	ed9ff06f          	j	65f8 <__subdf3+0x1a4>
    6724:	01d5e6b3          	or	a3,a1,t4
    6728:	18068663          	beqz	a3,68b4 <__subdf3+0x460>
    672c:	fff78693          	addi	a3,a5,-1
    6730:	3a068263          	beqz	a3,6ad4 <__subdf3+0x680>
    6734:	16678463          	beq	a5,t1,689c <__subdf3+0x448>
    6738:	03800793          	li	a5,56
    673c:	00100513          	li	a0,1
    6740:	dcd7cee3          	blt	a5,a3,651c <__subdf3+0xc8>
    6744:	00068793          	mv	a5,a3
    6748:	da5ff06f          	j	64ec <__subdf3+0x98>
    674c:	0016c693          	xori	a3,a3,1
    6750:	f8d41ae3          	bne	s0,a3,66e4 <__subdf3+0x290>
    6754:	18030863          	beqz	t1,68e4 <__subdf3+0x490>
    6758:	2c099063          	bnez	s3,6a18 <__subdf3+0x5c4>
    675c:	7ff00793          	li	a5,2047
    6760:	011766b3          	or	a3,a4,a7
    6764:	48068863          	beqz	a3,6bf4 <__subdf3+0x7a0>
    6768:	fff78693          	addi	a3,a5,-1
    676c:	34068263          	beqz	a3,6ab0 <__subdf3+0x65c>
    6770:	7ff00513          	li	a0,2047
    6774:	2aa78263          	beq	a5,a0,6a18 <__subdf3+0x5c4>
    6778:	03800793          	li	a5,56
    677c:	00100913          	li	s2,1
    6780:	02d7ca63          	blt	a5,a3,67b4 <__subdf3+0x360>
    6784:	01f00793          	li	a5,31
    6788:	4cd7c663          	blt	a5,a3,6c54 <__subdf3+0x800>
    678c:	02000793          	li	a5,32
    6790:	40d787b3          	sub	a5,a5,a3
    6794:	00f71933          	sll	s2,a4,a5
    6798:	00d8d633          	srl	a2,a7,a3
    679c:	00f897b3          	sll	a5,a7,a5
    67a0:	00c96933          	or	s2,s2,a2
    67a4:	00f037b3          	snez	a5,a5
    67a8:	00d756b3          	srl	a3,a4,a3
    67ac:	00f96933          	or	s2,s2,a5
    67b0:	00d585b3          	add	a1,a1,a3
    67b4:	01d90733          	add	a4,s2,t4
    67b8:	01273933          	sltu	s2,a4,s2
    67bc:	00070493          	mv	s1,a4
    67c0:	00b90933          	add	s2,s2,a1
    67c4:	000f0993          	mv	s3,t5
    67c8:	ed1ff06f          	j	6698 <__subdf3+0x244>
    67cc:	00198793          	addi	a5,s3,1
    67d0:	7fe7f793          	andi	a5,a5,2046
    67d4:	14079463          	bnez	a5,691c <__subdf3+0x4c8>
    67d8:	01d5e833          	or	a6,a1,t4
    67dc:	011767b3          	or	a5,a4,a7
    67e0:	2a099463          	bnez	s3,6a88 <__subdf3+0x634>
    67e4:	38078e63          	beqz	a5,6b80 <__subdf3+0x72c>
    67e8:	3c081063          	bnez	a6,6ba8 <__subdf3+0x754>
    67ec:	00351513          	slli	a0,a0,0x3
    67f0:	00355913          	srli	s2,a0,0x3
    67f4:	00000793          	li	a5,0
    67f8:	1140006f          	j	690c <__subdf3+0x4b8>
    67fc:	0a698063          	beq	s3,t1,689c <__subdf3+0x448>
    6800:	03800693          	li	a3,56
    6804:	00100913          	li	s2,1
    6808:	e8f6c0e3          	blt	a3,a5,6688 <__subdf3+0x234>
    680c:	008006b7          	lui	a3,0x800
    6810:	00d5e5b3          	or	a1,a1,a3
    6814:	e45ff06f          	j	6658 <__subdf3+0x204>
    6818:	00147e13          	andi	t3,s0,1
    681c:	7ff00793          	li	a5,2047
    6820:	00000713          	li	a4,0
    6824:	00000813          	li	a6,0
    6828:	dd1ff06f          	j	65f8 <__subdf3+0x1a4>
    682c:	00048513          	mv	a0,s1
    6830:	7a0000ef          	jal	6fd0 <__clzsi2>
    6834:	01850793          	addi	a5,a0,24
    6838:	01f00693          	li	a3,31
    683c:	d0f6dae3          	bge	a3,a5,6550 <__subdf3+0xfc>
    6840:	ff850713          	addi	a4,a0,-8
    6844:	00e49733          	sll	a4,s1,a4
    6848:	1b37ce63          	blt	a5,s3,6a04 <__subdf3+0x5b0>
    684c:	413789b3          	sub	s3,a5,s3
    6850:	00198793          	addi	a5,s3,1
    6854:	42f6de63          	bge	a3,a5,6c90 <__subdf3+0x83c>
    6858:	fe198993          	addi	s3,s3,-31
    685c:	02000693          	li	a3,32
    6860:	013754b3          	srl	s1,a4,s3
    6864:	00d78c63          	beq	a5,a3,687c <__subdf3+0x428>
    6868:	04000693          	li	a3,64
    686c:	40f687b3          	sub	a5,a3,a5
    6870:	00f71733          	sll	a4,a4,a5
    6874:	00e03733          	snez	a4,a4
    6878:	00e4e4b3          	or	s1,s1,a4
    687c:	00000993          	li	s3,0
    6880:	0074f793          	andi	a5,s1,7
    6884:	d0079ee3          	bnez	a5,65a0 <__subdf3+0x14c>
    6888:	00098793          	mv	a5,s3
    688c:	0034d513          	srli	a0,s1,0x3
    6890:	00090713          	mv	a4,s2
    6894:	0280006f          	j	68bc <__subdf3+0x468>
    6898:	e6081ce3          	bnez	a6,6710 <__subdf3+0x2bc>
    689c:	00351513          	slli	a0,a0,0x3
    68a0:	01d71813          	slli	a6,a4,0x1d
    68a4:	00355513          	srli	a0,a0,0x3
    68a8:	00a86833          	or	a6,a6,a0
    68ac:	00375713          	srli	a4,a4,0x3
    68b0:	e59ff06f          	j	6708 <__subdf3+0x2b4>
    68b4:	00351513          	slli	a0,a0,0x3
    68b8:	00355513          	srli	a0,a0,0x3
    68bc:	01d71813          	slli	a6,a4,0x1d
    68c0:	7ff00693          	li	a3,2047
    68c4:	00a86833          	or	a6,a6,a0
    68c8:	00375713          	srli	a4,a4,0x3
    68cc:	e2d78ee3          	beq	a5,a3,6708 <__subdf3+0x2b4>
    68d0:	00c71713          	slli	a4,a4,0xc
    68d4:	00c75713          	srli	a4,a4,0xc
    68d8:	7ff7f793          	andi	a5,a5,2047
    68dc:	00147e13          	andi	t3,s0,1
    68e0:	d19ff06f          	j	65f8 <__subdf3+0x1a4>
    68e4:	00198693          	addi	a3,s3,1
    68e8:	7fe6f793          	andi	a5,a3,2046
    68ec:	12079e63          	bnez	a5,6a28 <__subdf3+0x5d4>
    68f0:	011767b3          	or	a5,a4,a7
    68f4:	24099a63          	bnez	s3,6b48 <__subdf3+0x6f4>
    68f8:	30078663          	beqz	a5,6c04 <__subdf3+0x7b0>
    68fc:	01d5e7b3          	or	a5,a1,t4
    6900:	30079a63          	bnez	a5,6c14 <__subdf3+0x7c0>
    6904:	00351513          	slli	a0,a0,0x3
    6908:	00355913          	srli	s2,a0,0x3
    690c:	01d71813          	slli	a6,a4,0x1d
    6910:	01286833          	or	a6,a6,s2
    6914:	00375713          	srli	a4,a4,0x3
    6918:	fb9ff06f          	j	68d0 <__subdf3+0x47c>
    691c:	41d88833          	sub	a6,a7,t4
    6920:	0108b7b3          	sltu	a5,a7,a6
    6924:	40b70933          	sub	s2,a4,a1
    6928:	40f90933          	sub	s2,s2,a5
    692c:	00891793          	slli	a5,s2,0x8
    6930:	00080493          	mv	s1,a6
    6934:	1207c263          	bltz	a5,6a58 <__subdf3+0x604>
    6938:	01286833          	or	a6,a6,s2
    693c:	c00812e3          	bnez	a6,6540 <__subdf3+0xec>
    6940:	00000e13          	li	t3,0
    6944:	00000793          	li	a5,0
    6948:	00000713          	li	a4,0
    694c:	cadff06f          	j	65f8 <__subdf3+0x1a4>
    6950:	ff800937          	lui	s2,0xff800
    6954:	fff90913          	addi	s2,s2,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f717f>
    6958:	40f989b3          	sub	s3,s3,a5
    695c:	01277933          	and	s2,a4,s2
    6960:	c39ff06f          	j	6598 <__subdf3+0x144>
    6964:	7ff00793          	li	a5,2047
    6968:	01176533          	or	a0,a4,a7
    696c:	10050463          	beqz	a0,6a74 <__subdf3+0x620>
    6970:	fff78813          	addi	a6,a5,-1
    6974:	1e080263          	beqz	a6,6b58 <__subdf3+0x704>
    6978:	7ff00513          	li	a0,2047
    697c:	d6a788e3          	beq	a5,a0,66ec <__subdf3+0x298>
    6980:	03800793          	li	a5,56
    6984:	00068413          	mv	s0,a3
    6988:	00100513          	li	a0,1
    698c:	0307ca63          	blt	a5,a6,69c0 <__subdf3+0x56c>
    6990:	01f00793          	li	a5,31
    6994:	1907c463          	blt	a5,a6,6b1c <__subdf3+0x6c8>
    6998:	02000793          	li	a5,32
    699c:	410787b3          	sub	a5,a5,a6
    69a0:	00f71533          	sll	a0,a4,a5
    69a4:	0108d6b3          	srl	a3,a7,a6
    69a8:	00f897b3          	sll	a5,a7,a5
    69ac:	00d56533          	or	a0,a0,a3
    69b0:	00f037b3          	snez	a5,a5
    69b4:	01075833          	srl	a6,a4,a6
    69b8:	00f56533          	or	a0,a0,a5
    69bc:	410585b3          	sub	a1,a1,a6
    69c0:	40ae8533          	sub	a0,t4,a0
    69c4:	00aeb733          	sltu	a4,t4,a0
    69c8:	00050493          	mv	s1,a0
    69cc:	40e58933          	sub	s2,a1,a4
    69d0:	000f0993          	mv	s3,t5
    69d4:	b59ff06f          	j	652c <__subdf3+0xd8>
    69d8:	fe078693          	addi	a3,a5,-32
    69dc:	02000613          	li	a2,32
    69e0:	00d5d6b3          	srl	a3,a1,a3
    69e4:	00c78a63          	beq	a5,a2,69f8 <__subdf3+0x5a4>
    69e8:	04000613          	li	a2,64
    69ec:	40f607b3          	sub	a5,a2,a5
    69f0:	00f597b3          	sll	a5,a1,a5
    69f4:	00feeeb3          	or	t4,t4,a5
    69f8:	01d03533          	snez	a0,t4
    69fc:	00d56533          	or	a0,a0,a3
    6a00:	b1dff06f          	j	651c <__subdf3+0xc8>
    6a04:	ff8006b7          	lui	a3,0xff800
    6a08:	fff68693          	addi	a3,a3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f717f>
    6a0c:	40f987b3          	sub	a5,s3,a5
    6a10:	00d77733          	and	a4,a4,a3
    6a14:	ef9ff06f          	j	690c <__subdf3+0x4b8>
    6a18:	00361513          	slli	a0,a2,0x3
    6a1c:	00355513          	srli	a0,a0,0x3
    6a20:	00058713          	mv	a4,a1
    6a24:	cd9ff06f          	j	66fc <__subdf3+0x2a8>
    6a28:	7ff00793          	li	a5,2047
    6a2c:	def686e3          	beq	a3,a5,6818 <__subdf3+0x3c4>
    6a30:	01d88eb3          	add	t4,a7,t4
    6a34:	011eb633          	sltu	a2,t4,a7
    6a38:	00b707b3          	add	a5,a4,a1
    6a3c:	00c787b3          	add	a5,a5,a2
    6a40:	01f79513          	slli	a0,a5,0x1f
    6a44:	001ede93          	srli	t4,t4,0x1
    6a48:	01d564b3          	or	s1,a0,t4
    6a4c:	0017d913          	srli	s2,a5,0x1
    6a50:	00068993          	mv	s3,a3
    6a54:	b45ff06f          	j	6598 <__subdf3+0x144>
    6a58:	411e8633          	sub	a2,t4,a7
    6a5c:	40e587b3          	sub	a5,a1,a4
    6a60:	00ceb733          	sltu	a4,t4,a2
    6a64:	00060493          	mv	s1,a2
    6a68:	40e78933          	sub	s2,a5,a4
    6a6c:	00068413          	mv	s0,a3
    6a70:	ad1ff06f          	j	6540 <__subdf3+0xec>
    6a74:	00361613          	slli	a2,a2,0x3
    6a78:	00365513          	srli	a0,a2,0x3
    6a7c:	00068413          	mv	s0,a3
    6a80:	00058713          	mv	a4,a1
    6a84:	e39ff06f          	j	68bc <__subdf3+0x468>
    6a88:	e00798e3          	bnez	a5,6898 <__subdf3+0x444>
    6a8c:	22080663          	beqz	a6,6cb8 <__subdf3+0x864>
    6a90:	0035d713          	srli	a4,a1,0x3
    6a94:	00361613          	slli	a2,a2,0x3
    6a98:	01d59593          	slli	a1,a1,0x1d
    6a9c:	00b76733          	or	a4,a4,a1
    6aa0:	00365613          	srli	a2,a2,0x3
    6aa4:	00c76733          	or	a4,a4,a2
    6aa8:	00068413          	mv	s0,a3
    6aac:	c61ff06f          	j	670c <__subdf3+0x2b8>
    6ab0:	01d88eb3          	add	t4,a7,t4
    6ab4:	00b705b3          	add	a1,a4,a1
    6ab8:	011eb633          	sltu	a2,t4,a7
    6abc:	00c58933          	add	s2,a1,a2
    6ac0:	00891793          	slli	a5,s2,0x8
    6ac4:	000e8493          	mv	s1,t4
    6ac8:	0a07d863          	bgez	a5,6b78 <__subdf3+0x724>
    6acc:	00200993          	li	s3,2
    6ad0:	bddff06f          	j	66ac <__subdf3+0x258>
    6ad4:	41d88eb3          	sub	t4,a7,t4
    6ad8:	40b705b3          	sub	a1,a4,a1
    6adc:	01d8b633          	sltu	a2,a7,t4
    6ae0:	000e8493          	mv	s1,t4
    6ae4:	40c58933          	sub	s2,a1,a2
    6ae8:	00100993          	li	s3,1
    6aec:	a41ff06f          	j	652c <__subdf3+0xd8>
    6af0:	fe078693          	addi	a3,a5,-32
    6af4:	02000613          	li	a2,32
    6af8:	00d5d6b3          	srl	a3,a1,a3
    6afc:	00c78a63          	beq	a5,a2,6b10 <__subdf3+0x6bc>
    6b00:	04000613          	li	a2,64
    6b04:	40f607b3          	sub	a5,a2,a5
    6b08:	00f597b3          	sll	a5,a1,a5
    6b0c:	00feeeb3          	or	t4,t4,a5
    6b10:	01d03933          	snez	s2,t4
    6b14:	00d96933          	or	s2,s2,a3
    6b18:	b71ff06f          	j	6688 <__subdf3+0x234>
    6b1c:	fe080793          	addi	a5,a6,-32
    6b20:	02000693          	li	a3,32
    6b24:	00f757b3          	srl	a5,a4,a5
    6b28:	00d80a63          	beq	a6,a3,6b3c <__subdf3+0x6e8>
    6b2c:	04000693          	li	a3,64
    6b30:	410686b3          	sub	a3,a3,a6
    6b34:	00d71733          	sll	a4,a4,a3
    6b38:	00e8e8b3          	or	a7,a7,a4
    6b3c:	01103533          	snez	a0,a7
    6b40:	00f56533          	or	a0,a0,a5
    6b44:	e7dff06f          	j	69c0 <__subdf3+0x56c>
    6b48:	ec0788e3          	beqz	a5,6a18 <__subdf3+0x5c4>
    6b4c:	01d5eeb3          	or	t4,a1,t4
    6b50:	bc0e90e3          	bnez	t4,6710 <__subdf3+0x2bc>
    6b54:	d49ff06f          	j	689c <__subdf3+0x448>
    6b58:	411e8633          	sub	a2,t4,a7
    6b5c:	40e585b3          	sub	a1,a1,a4
    6b60:	00ceb733          	sltu	a4,t4,a2
    6b64:	00060493          	mv	s1,a2
    6b68:	40e58933          	sub	s2,a1,a4
    6b6c:	00068413          	mv	s0,a3
    6b70:	00100993          	li	s3,1
    6b74:	9b9ff06f          	j	652c <__subdf3+0xd8>
    6b78:	00100793          	li	a5,1
    6b7c:	d11ff06f          	j	688c <__subdf3+0x438>
    6b80:	dc0800e3          	beqz	a6,6940 <__subdf3+0x4ec>
    6b84:	00361613          	slli	a2,a2,0x3
    6b88:	00365793          	srli	a5,a2,0x3
    6b8c:	01d59813          	slli	a6,a1,0x1d
    6b90:	00959713          	slli	a4,a1,0x9
    6b94:	00f86833          	or	a6,a6,a5
    6b98:	00c75713          	srli	a4,a4,0xc
    6b9c:	00068e13          	mv	t3,a3
    6ba0:	00000793          	li	a5,0
    6ba4:	a55ff06f          	j	65f8 <__subdf3+0x1a4>
    6ba8:	41d88933          	sub	s2,a7,t4
    6bac:	0128b7b3          	sltu	a5,a7,s2
    6bb0:	40b70633          	sub	a2,a4,a1
    6bb4:	40f60633          	sub	a2,a2,a5
    6bb8:	00861793          	slli	a5,a2,0x8
    6bbc:	0e07d263          	bgez	a5,6ca0 <__subdf3+0x84c>
    6bc0:	411e8633          	sub	a2,t4,a7
    6bc4:	40e58733          	sub	a4,a1,a4
    6bc8:	00cebeb3          	sltu	t4,t4,a2
    6bcc:	41d70733          	sub	a4,a4,t4
    6bd0:	00871793          	slli	a5,a4,0x8
    6bd4:	00060493          	mv	s1,a2
    6bd8:	1207de63          	bgez	a5,6d14 <__subdf3+0x8c0>
    6bdc:	ff8007b7          	lui	a5,0xff800
    6be0:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f717f>
    6be4:	00f77733          	and	a4,a4,a5
    6be8:	00068413          	mv	s0,a3
    6bec:	00100793          	li	a5,1
    6bf0:	9f1ff06f          	j	65e0 <__subdf3+0x18c>
    6bf4:	00361613          	slli	a2,a2,0x3
    6bf8:	00365513          	srli	a0,a2,0x3
    6bfc:	00058713          	mv	a4,a1
    6c00:	cbdff06f          	j	68bc <__subdf3+0x468>
    6c04:	00361613          	slli	a2,a2,0x3
    6c08:	00365913          	srli	s2,a2,0x3
    6c0c:	00058713          	mv	a4,a1
    6c10:	cfdff06f          	j	690c <__subdf3+0x4b8>
    6c14:	01d886b3          	add	a3,a7,t4
    6c18:	00b707b3          	add	a5,a4,a1
    6c1c:	0116b633          	sltu	a2,a3,a7
    6c20:	00c787b3          	add	a5,a5,a2
    6c24:	00879713          	slli	a4,a5,0x8
    6c28:	0036d813          	srli	a6,a3,0x3
    6c2c:	08075e63          	bgez	a4,6cc8 <__subdf3+0x874>
    6c30:	ff800737          	lui	a4,0xff800
    6c34:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f717f>
    6c38:	00e7f7b3          	and	a5,a5,a4
    6c3c:	01d79713          	slli	a4,a5,0x1d
    6c40:	00979793          	slli	a5,a5,0x9
    6c44:	01076833          	or	a6,a4,a6
    6c48:	00c7d713          	srli	a4,a5,0xc
    6c4c:	00100793          	li	a5,1
    6c50:	9a9ff06f          	j	65f8 <__subdf3+0x1a4>
    6c54:	fe068793          	addi	a5,a3,-32
    6c58:	02000613          	li	a2,32
    6c5c:	00f757b3          	srl	a5,a4,a5
    6c60:	00c68a63          	beq	a3,a2,6c74 <__subdf3+0x820>
    6c64:	04000613          	li	a2,64
    6c68:	40d606b3          	sub	a3,a2,a3
    6c6c:	00d71733          	sll	a4,a4,a3
    6c70:	00e8e8b3          	or	a7,a7,a4
    6c74:	01103933          	snez	s2,a7
    6c78:	00f96933          	or	s2,s2,a5
    6c7c:	b39ff06f          	j	67b4 <__subdf3+0x360>
    6c80:	0034d513          	srli	a0,s1,0x3
    6c84:	00098793          	mv	a5,s3
    6c88:	00090713          	mv	a4,s2
    6c8c:	c31ff06f          	j	68bc <__subdf3+0x468>
    6c90:	02000693          	li	a3,32
    6c94:	40f686b3          	sub	a3,a3,a5
    6c98:	00000613          	li	a2,0
    6c9c:	8e9ff06f          	j	6584 <__subdf3+0x130>
    6ca0:	00c96833          	or	a6,s2,a2
    6ca4:	c8080ee3          	beqz	a6,6940 <__subdf3+0x4ec>
    6ca8:	00395913          	srli	s2,s2,0x3
    6cac:	00000793          	li	a5,0
    6cb0:	00060713          	mv	a4,a2
    6cb4:	c59ff06f          	j	690c <__subdf3+0x4b8>
    6cb8:	00000e13          	li	t3,0
    6cbc:	7ff00793          	li	a5,2047
    6cc0:	00080737          	lui	a4,0x80
    6cc4:	935ff06f          	j	65f8 <__subdf3+0x1a4>
    6cc8:	01d79713          	slli	a4,a5,0x1d
    6ccc:	00979793          	slli	a5,a5,0x9
    6cd0:	01076833          	or	a6,a4,a6
    6cd4:	00c7d713          	srli	a4,a5,0xc
    6cd8:	00000793          	li	a5,0
    6cdc:	91dff06f          	j	65f8 <__subdf3+0x1a4>
    6ce0:	ae0786e3          	beqz	a5,67cc <__subdf3+0x378>
    6ce4:	413f0833          	sub	a6,t5,s3
    6ce8:	00080793          	mv	a5,a6
    6cec:	c6098ee3          	beqz	s3,6968 <__subdf3+0x514>
    6cf0:	03800793          	li	a5,56
    6cf4:	0107ca63          	blt	a5,a6,6d08 <__subdf3+0x8b4>
    6cf8:	008007b7          	lui	a5,0x800
    6cfc:	00f76733          	or	a4,a4,a5
    6d00:	00068413          	mv	s0,a3
    6d04:	c8dff06f          	j	6990 <__subdf3+0x53c>
    6d08:	00068413          	mv	s0,a3
    6d0c:	00100513          	li	a0,1
    6d10:	cb1ff06f          	j	69c0 <__subdf3+0x56c>
    6d14:	01d71813          	slli	a6,a4,0x1d
    6d18:	00365613          	srli	a2,a2,0x3
    6d1c:	00c86833          	or	a6,a6,a2
    6d20:	00375713          	srli	a4,a4,0x3
    6d24:	00000793          	li	a5,0
    6d28:	00068413          	mv	s0,a3
    6d2c:	ba5ff06f          	j	68d0 <__subdf3+0x47c>
    6d30:	ba078ae3          	beqz	a5,68e4 <__subdf3+0x490>
    6d34:	413f06b3          	sub	a3,t5,s3
    6d38:	00099663          	bnez	s3,6d44 <__subdf3+0x8f0>
    6d3c:	00068793          	mv	a5,a3
    6d40:	a21ff06f          	j	6760 <__subdf3+0x30c>
    6d44:	03800793          	li	a5,56
    6d48:	00100913          	li	s2,1
    6d4c:	a6d7c4e3          	blt	a5,a3,67b4 <__subdf3+0x360>
    6d50:	008007b7          	lui	a5,0x800
    6d54:	00f76733          	or	a4,a4,a5
    6d58:	a2dff06f          	j	6784 <__subdf3+0x330>

00006d5c <__fixdfsi>:
    6d5c:	0145d793          	srli	a5,a1,0x14
    6d60:	001006b7          	lui	a3,0x100
    6d64:	fff68713          	addi	a4,a3,-1 # fffff <__freertos_irq_stack_top+0xf717f>
    6d68:	7ff7f793          	andi	a5,a5,2047
    6d6c:	3fe00613          	li	a2,1022
    6d70:	00b77733          	and	a4,a4,a1
    6d74:	01f5d593          	srli	a1,a1,0x1f
    6d78:	00f65e63          	bge	a2,a5,6d94 <__fixdfsi+0x38>
    6d7c:	41d00613          	li	a2,1053
    6d80:	00f65e63          	bge	a2,a5,6d9c <__fixdfsi+0x40>
    6d84:	80000537          	lui	a0,0x80000
    6d88:	fff50513          	addi	a0,a0,-1 # 7fffffff <__freertos_irq_stack_top+0x7fff717f>
    6d8c:	00a58533          	add	a0,a1,a0
    6d90:	00008067          	ret
    6d94:	00000513          	li	a0,0
    6d98:	00008067          	ret
    6d9c:	43300613          	li	a2,1075
    6da0:	40f60633          	sub	a2,a2,a5
    6da4:	01f00813          	li	a6,31
    6da8:	00d76733          	or	a4,a4,a3
    6dac:	02c85063          	bge	a6,a2,6dcc <__fixdfsi+0x70>
    6db0:	41300693          	li	a3,1043
    6db4:	40f687b3          	sub	a5,a3,a5
    6db8:	00f75733          	srl	a4,a4,a5
    6dbc:	40e00533          	neg	a0,a4
    6dc0:	fc059ce3          	bnez	a1,6d98 <__fixdfsi+0x3c>
    6dc4:	00070513          	mv	a0,a4
    6dc8:	00008067          	ret
    6dcc:	bed78793          	addi	a5,a5,-1043 # 7ffbed <__freertos_irq_stack_top+0x7f6d6d>
    6dd0:	00f71733          	sll	a4,a4,a5
    6dd4:	00c55533          	srl	a0,a0,a2
    6dd8:	00a76733          	or	a4,a4,a0
    6ddc:	fe1ff06f          	j	6dbc <__fixdfsi+0x60>

00006de0 <__fixunsdfsi>:
    6de0:	0145d793          	srli	a5,a1,0x14
    6de4:	00100637          	lui	a2,0x100
    6de8:	fff60713          	addi	a4,a2,-1 # fffff <__freertos_irq_stack_top+0xf717f>
    6dec:	7ff7f793          	andi	a5,a5,2047
    6df0:	3fe00813          	li	a6,1022
    6df4:	00050693          	mv	a3,a0
    6df8:	00b77733          	and	a4,a4,a1
    6dfc:	00000513          	li	a0,0
    6e00:	01f5d593          	srli	a1,a1,0x1f
    6e04:	00f85463          	bge	a6,a5,6e0c <__fixunsdfsi+0x2c>
    6e08:	00058463          	beqz	a1,6e10 <__fixunsdfsi+0x30>
    6e0c:	00008067          	ret
    6e10:	41e00593          	li	a1,1054
    6e14:	fff00513          	li	a0,-1
    6e18:	fef5cae3          	blt	a1,a5,6e0c <__fixunsdfsi+0x2c>
    6e1c:	43300593          	li	a1,1075
    6e20:	40f585b3          	sub	a1,a1,a5
    6e24:	01f00513          	li	a0,31
    6e28:	00c76733          	or	a4,a4,a2
    6e2c:	00b54c63          	blt	a0,a1,6e44 <__fixunsdfsi+0x64>
    6e30:	bed78793          	addi	a5,a5,-1043
    6e34:	00f71733          	sll	a4,a4,a5
    6e38:	00b6d533          	srl	a0,a3,a1
    6e3c:	00a76533          	or	a0,a4,a0
    6e40:	00008067          	ret
    6e44:	41300513          	li	a0,1043
    6e48:	40f50533          	sub	a0,a0,a5
    6e4c:	00a75533          	srl	a0,a4,a0
    6e50:	00008067          	ret

00006e54 <__floatsidf>:
    6e54:	ff010113          	addi	sp,sp,-16
    6e58:	00112623          	sw	ra,12(sp)
    6e5c:	00812423          	sw	s0,8(sp)
    6e60:	00912223          	sw	s1,4(sp)
    6e64:	04050a63          	beqz	a0,6eb8 <__floatsidf+0x64>
    6e68:	41f55713          	srai	a4,a0,0x1f
    6e6c:	00a744b3          	xor	s1,a4,a0
    6e70:	40e484b3          	sub	s1,s1,a4
    6e74:	00050793          	mv	a5,a0
    6e78:	00048513          	mv	a0,s1
    6e7c:	01f7d413          	srli	s0,a5,0x1f
    6e80:	150000ef          	jal	6fd0 <__clzsi2>
    6e84:	41e00793          	li	a5,1054
    6e88:	40a787b3          	sub	a5,a5,a0
    6e8c:	00a00713          	li	a4,10
    6e90:	7ff7f793          	andi	a5,a5,2047
    6e94:	06a74063          	blt	a4,a0,6ef4 <__floatsidf+0xa0>
    6e98:	00b00713          	li	a4,11
    6e9c:	40a70733          	sub	a4,a4,a0
    6ea0:	00e4d733          	srl	a4,s1,a4
    6ea4:	01550513          	addi	a0,a0,21
    6ea8:	00c71713          	slli	a4,a4,0xc
    6eac:	00a494b3          	sll	s1,s1,a0
    6eb0:	00c75713          	srli	a4,a4,0xc
    6eb4:	0140006f          	j	6ec8 <__floatsidf+0x74>
    6eb8:	00000413          	li	s0,0
    6ebc:	00000793          	li	a5,0
    6ec0:	00000713          	li	a4,0
    6ec4:	00000493          	li	s1,0
    6ec8:	01479793          	slli	a5,a5,0x14
    6ecc:	01f41413          	slli	s0,s0,0x1f
    6ed0:	00e7e7b3          	or	a5,a5,a4
    6ed4:	00c12083          	lw	ra,12(sp)
    6ed8:	0087e7b3          	or	a5,a5,s0
    6edc:	00812403          	lw	s0,8(sp)
    6ee0:	00048513          	mv	a0,s1
    6ee4:	00078593          	mv	a1,a5
    6ee8:	00412483          	lw	s1,4(sp)
    6eec:	01010113          	addi	sp,sp,16
    6ef0:	00008067          	ret
    6ef4:	ff550513          	addi	a0,a0,-11
    6ef8:	00a49733          	sll	a4,s1,a0
    6efc:	00c71713          	slli	a4,a4,0xc
    6f00:	00c75713          	srli	a4,a4,0xc
    6f04:	00000493          	li	s1,0
    6f08:	fc1ff06f          	j	6ec8 <__floatsidf+0x74>

00006f0c <__floatunsidf>:
    6f0c:	ff010113          	addi	sp,sp,-16
    6f10:	00812423          	sw	s0,8(sp)
    6f14:	00112623          	sw	ra,12(sp)
    6f18:	00050413          	mv	s0,a0
    6f1c:	04050c63          	beqz	a0,6f74 <__floatunsidf+0x68>
    6f20:	0b0000ef          	jal	6fd0 <__clzsi2>
    6f24:	41e00793          	li	a5,1054
    6f28:	40a787b3          	sub	a5,a5,a0
    6f2c:	00a00713          	li	a4,10
    6f30:	7ff7f793          	andi	a5,a5,2047
    6f34:	06a74463          	blt	a4,a0,6f9c <__floatunsidf+0x90>
    6f38:	00b00713          	li	a4,11
    6f3c:	40a70733          	sub	a4,a4,a0
    6f40:	01550513          	addi	a0,a0,21
    6f44:	00e45733          	srl	a4,s0,a4
    6f48:	00a41433          	sll	s0,s0,a0
    6f4c:	00c12083          	lw	ra,12(sp)
    6f50:	00040513          	mv	a0,s0
    6f54:	00c71713          	slli	a4,a4,0xc
    6f58:	00812403          	lw	s0,8(sp)
    6f5c:	00c75713          	srli	a4,a4,0xc
    6f60:	01479793          	slli	a5,a5,0x14
    6f64:	00e7e7b3          	or	a5,a5,a4
    6f68:	00078593          	mv	a1,a5
    6f6c:	01010113          	addi	sp,sp,16
    6f70:	00008067          	ret
    6f74:	00c12083          	lw	ra,12(sp)
    6f78:	00040513          	mv	a0,s0
    6f7c:	00000793          	li	a5,0
    6f80:	00812403          	lw	s0,8(sp)
    6f84:	00000713          	li	a4,0
    6f88:	01479793          	slli	a5,a5,0x14
    6f8c:	00e7e7b3          	or	a5,a5,a4
    6f90:	00078593          	mv	a1,a5
    6f94:	01010113          	addi	sp,sp,16
    6f98:	00008067          	ret
    6f9c:	ff550513          	addi	a0,a0,-11
    6fa0:	00a41733          	sll	a4,s0,a0
    6fa4:	00000413          	li	s0,0
    6fa8:	00c12083          	lw	ra,12(sp)
    6fac:	00040513          	mv	a0,s0
    6fb0:	00c71713          	slli	a4,a4,0xc
    6fb4:	00812403          	lw	s0,8(sp)
    6fb8:	00c75713          	srli	a4,a4,0xc
    6fbc:	01479793          	slli	a5,a5,0x14
    6fc0:	00e7e7b3          	or	a5,a5,a4
    6fc4:	00078593          	mv	a1,a5
    6fc8:	01010113          	addi	sp,sp,16
    6fcc:	00008067          	ret

00006fd0 <__clzsi2>:
    6fd0:	000107b7          	lui	a5,0x10
    6fd4:	02f57a63          	bgeu	a0,a5,7008 <__clzsi2+0x38>
    6fd8:	10053793          	sltiu	a5,a0,256
    6fdc:	0017b793          	seqz	a5,a5
    6fe0:	00379793          	slli	a5,a5,0x3
    6fe4:	02000713          	li	a4,32
    6fe8:	40f70733          	sub	a4,a4,a5
    6fec:	00f55533          	srl	a0,a0,a5
    6ff0:	00000797          	auipc	a5,0x0
    6ff4:	64478793          	addi	a5,a5,1604 # 7634 <__clz_tab>
    6ff8:	00a787b3          	add	a5,a5,a0
    6ffc:	0007c503          	lbu	a0,0(a5)
    7000:	40a70533          	sub	a0,a4,a0
    7004:	00008067          	ret
    7008:	010007b7          	lui	a5,0x1000
    700c:	02f57463          	bgeu	a0,a5,7034 <__clzsi2+0x64>
    7010:	01000793          	li	a5,16
    7014:	00f55533          	srl	a0,a0,a5
    7018:	00000797          	auipc	a5,0x0
    701c:	61c78793          	addi	a5,a5,1564 # 7634 <__clz_tab>
    7020:	00a787b3          	add	a5,a5,a0
    7024:	0007c503          	lbu	a0,0(a5)
    7028:	01000713          	li	a4,16
    702c:	40a70533          	sub	a0,a4,a0
    7030:	00008067          	ret
    7034:	01800793          	li	a5,24
    7038:	00f55533          	srl	a0,a0,a5
    703c:	00000797          	auipc	a5,0x0
    7040:	5f878793          	addi	a5,a5,1528 # 7634 <__clz_tab>
    7044:	00a787b3          	add	a5,a5,a0
    7048:	0007c503          	lbu	a0,0(a5)
    704c:	00800713          	li	a4,8
    7050:	40a70533          	sub	a0,a4,a0
    7054:	00008067          	ret
