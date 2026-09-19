
build/uartEchoDemo.elf:     file format elf32-littleriscv


Disassembly of section .init:

00001000 <_start>:

_start:
#ifdef USE_GP
.option push
.option norelax
	la gp, __global_pointer$
    1000:	00005197          	auipc	gp,0x5
    1004:	7b818193          	addi	gp,gp,1976 # 67b8 <__global_pointer$>
.global smp_lottery_target
.global smp_lottery_lock
.global smp_slave


  sw x0, smp_lottery_lock, a1
    1008:	8a01ac23          	sw	zero,-1864(gp) # 6070 <smp_lottery_lock>

0000100c <smp_tyranny>:

smp_tyranny:
  csrr a0, mhartid
    100c:	f1402573          	csrr	a0,mhartid
  beqz a0, init
    1010:	02050e63          	beqz	a0,104c <init>

00001014 <smp_slave>:

smp_slave:
	lw a0, smp_lottery_lock
    1014:	8b81a503          	lw	a0,-1864(gp) # 6070 <smp_lottery_lock>
	beqz a0, smp_slave
    1018:	fe050ee3          	beqz	a0,1014 <smp_slave>

	fence r, r
    101c:	0220000f          	fence	r,r
    1020:	0000100f          	.word	0x0000100f
	//li a1, -1
	//amoadd.w x0, a1,(a0)

	.word(0x100F) //i$ flush
	lw a5, smp_lottery_target
    1024:	8b41a783          	lw	a5,-1868(gp) # 606c <__bss_start>
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
    1038:	8aa1aa23          	sw	a0,-1868(gp) # 606c <__bss_start>
	fence w, w
    103c:	0110000f          	fence	w,w
	li a0, 1
    1040:	00100513          	li	a0,1
	sw a0, smp_lottery_lock, a1
    1044:	8aa1ac23          	sw	a0,-1864(gp) # 6070 <smp_lottery_lock>
    ret
    1048:	00008067          	ret

0000104c <init>:
#endif

init:
	la sp, _sp
    104c:	00006117          	auipc	sp,0x6
    1050:	03410113          	addi	sp,sp,52 # 7080 <__freertos_irq_stack_top>

	/* Load data section */
	la a0, _data_lma
    1054:	00005517          	auipc	a0,0x5
    1058:	bbc50513          	addi	a0,a0,-1092 # 5c10 <_data>
	la a1, _data
    105c:	00005597          	auipc	a1,0x5
    1060:	bb458593          	addi	a1,a1,-1100 # 5c10 <_data>
	la a2, _edata
    1064:	00005617          	auipc	a2,0x5
    1068:	00860613          	addi	a2,a2,8 # 606c <__bss_start>
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
    1084:	00005517          	auipc	a0,0x5
    1088:	fe850513          	addi	a0,a0,-24 # 606c <__bss_start>
	la a1, _end
    108c:	00005597          	auipc	a1,0x5
    1090:	fec58593          	addi	a1,a1,-20 # 6078 <_end>
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
    10cc:	00005797          	auipc	a5,0x5
    10d0:	b4478793          	addi	a5,a5,-1212 # 5c10 <_data>
    10d4:	00005417          	auipc	s0,0x5
    10d8:	b3c40413          	addi	s0,s0,-1220 # 5c10 <_data>
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
    1108:	00005797          	auipc	a5,0x5
    110c:	b0878793          	addi	a5,a5,-1272 # 5c10 <_data>
    1110:	00005417          	auipc	s0,0x5
    1114:	b0040413          	addi	s0,s0,-1280 # 5c10 <_data>
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
*
* @brief This function capture the character that user asserted on keyboard and 
*        printed on the terminal. 
*
******************************************************************************/
void main() {
    1154:	ff010113          	addi	sp,sp,-16
    1158:	00112623          	sw	ra,12(sp)
    uint8_t dat;

    bsp_init();
    115c:	32d010ef          	jal	2c88 <bsp_init>
    
    bsp_printf("***Starting Uart Echo Demo*** \r\n");
    1160:	00006537          	lui	a0,0x6
    1164:	c2850513          	addi	a0,a0,-984 # 5c28 <_data+0x18>
    1168:	359010ef          	jal	2cc0 <bsp_printf>
    bsp_printf("Start typing on terminal to send character... \r\n");
    116c:	00006537          	lui	a0,0x6
    1170:	c4c50513          	addi	a0,a0,-948 # 5c4c <_data+0x3c>
    1174:	34d010ef          	jal	2cc0 <bsp_printf>
    1178:	01c0006f          	j	1194 <main+0x40>
    while(1)
    {
    	//bsp_printf("***Starting Uart Echo Demo*** \r\n");
        while(uart_readOccupancy(BSP_UART_TERMINAL)){
            dat=uart_read(BSP_UART_TERMINAL);
    117c:	f8001537          	lui	a0,0xf8001
    1180:	030000ef          	jal	11b0 <uart_read>
    1184:	00050593          	mv	a1,a0
            bsp_printf("Echo character: %c \r\n", dat);
    1188:	00006537          	lui	a0,0x6
    118c:	c8050513          	addi	a0,a0,-896 # 5c80 <_data+0x70>
    1190:	331010ef          	jal	2cc0 <bsp_printf>
        while(uart_readOccupancy(BSP_UART_TERMINAL)){
    1194:	f8001537          	lui	a0,0xf8001
    1198:	00c000ef          	jal	11a4 <uart_readOccupancy>
    119c:	fe050ce3          	beqz	a0,1194 <main+0x40>
    11a0:	fddff06f          	j	117c <main+0x28>

000011a4 <uart_readOccupancy>:
#include "type.h"
#include "soc.h"


    static inline u32 read_u32(u32 address){
        return *((volatile u32*) address);
    11a4:	00452503          	lw	a0,4(a0) # f8001004 <__freertos_irq_stack_top+0xf7ff9f84>
*          of occupied spaces for reading data from bits 31 to 24.
*
******************************************************************************/
    static u32 uart_readOccupancy(u32 reg){
        return read_u32(reg + UART_STATUS) >> 24;
    }
    11a8:	01855513          	srli	a0,a0,0x18
    11ac:	00008067          	ret

000011b0 <uart_read>:
* @note    The function waits until there is data available in the UART buffer
*          for reading. Once data is available, it reads the character data from
*          the UART data register and returns it.
*
******************************************************************************/
    static char uart_read(u32 reg){
    11b0:	ff010113          	addi	sp,sp,-16
    11b4:	00112623          	sw	ra,12(sp)
    11b8:	00812423          	sw	s0,8(sp)
    11bc:	00050413          	mv	s0,a0
        while(uart_readOccupancy(reg) == 0);
    11c0:	00040513          	mv	a0,s0
    11c4:	fe1ff0ef          	jal	11a4 <uart_readOccupancy>
    11c8:	fe050ce3          	beqz	a0,11c0 <uart_read+0x10>
    11cc:	00042503          	lw	a0,0(s0)
        return read_u32(reg + UART_DATA);
    }
    11d0:	0ff57513          	zext.b	a0,a0
    11d4:	00c12083          	lw	ra,12(sp)
    11d8:	00812403          	lw	s0,8(sp)
    11dc:	01010113          	addi	sp,sp,16
    11e0:	00008067          	ret

000011e4 <uart_applyConfig>:
*          value using data length, parity, and stop bit settings from the configuration
*          structure, and writes this value to the UART frame configuration register.
*
******************************************************************************/
    static void uart_applyConfig(u32 reg, Uart_Config *config){
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
    11e4:	00c5a783          	lw	a5,12(a1)
    }
    
    static inline void write_u32(u32 data, u32 address){
        *((volatile u32*) address) = data;
    11e8:	00f52423          	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
    11ec:	0005a783          	lw	a5,0(a1)
    11f0:	fff78793          	addi	a5,a5,-1
    11f4:	0045a703          	lw	a4,4(a1)
    11f8:	00871713          	slli	a4,a4,0x8
    11fc:	00e7e7b3          	or	a5,a5,a4
    1200:	0085a703          	lw	a4,8(a1)
    1204:	01071713          	slli	a4,a4,0x10
    1208:	00e7e7b3          	or	a5,a5,a4
    120c:	00f52623          	sw	a5,12(a0)
    }
    1210:	00008067          	ret
	...

00001220 <sh_write0>:
* @note    None.
*
******************************************************************************/

static void sh_write0(char* buf)
{
    1220:	00050593          	mv	a1,a0
    register int value asm ("a0") = reason;
    1224:	00400513          	li	a0,4
    register void* ptr asm ("a1") = arg;
    1228:	00000013          	nop
    122c:	00000013          	nop
    asm volatile (
    1230:	01f01013          	slli	zero,zero,0x1f
    1234:	00100073          	ebreak
    1238:	40705013          	srai	zero,zero,0x7
    123c:	00000013          	nop
    // Print zero-terminated string
    call_host(SEMIHOSTING_SYS_WRITE0, (void*) buf);
}
    1240:	00008067          	ret
    1244:	00000013          	nop
    1248:	00000013          	nop

0000124c <_putchar_s>:
            bsp_putChar(character);
        #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }

    static void _putchar_s(char *p)
    {
    124c:	ff010113          	addi	sp,sp,-16
    1250:	00112623          	sw	ra,12(sp)
    #if (ENABLE_SEMIHOSTING_PRINT == 1)
        sh_write0(p);
    1254:	fcdff0ef          	jal	1220 <sh_write0>
    #else
        while (*p)
            _putchar(*(p++));
    #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }
    1258:	00c12083          	lw	ra,12(sp)
    125c:	01010113          	addi	sp,sp,16
    1260:	00008067          	ret

00001264 <_out_buffer>:
*
******************************************************************************/

static inline void _out_buffer(char character, void* buffer, size_t idx, size_t maxlen)
{
  if (idx < maxlen) {
    1264:	00d67663          	bgeu	a2,a3,1270 <_out_buffer+0xc>
    ((char*)buffer)[idx] = character;
    1268:	00c585b3          	add	a1,a1,a2
    126c:	00a58023          	sb	a0,0(a1)
  }
}
    1270:	00008067          	ret

00001274 <_out_null>:
*
******************************************************************************/
static inline void _out_null(char character, void* buffer, size_t idx, size_t maxlen)
{
  (void)character; (void)buffer; (void)idx; (void)maxlen;
}
    1274:	00008067          	ret

00001278 <_atoi>:
*
* @return Converted unsigned integer value.
*
******************************************************************************/
static unsigned int _atoi(const char** str)
{
    1278:	00050693          	mv	a3,a0
  unsigned int i = 0U;
    127c:	00000513          	li	a0,0
  while (_is_digit(**str)) {
    1280:	0240006f          	j	12a4 <_atoi+0x2c>
    i = i * 10U + (unsigned int)(*((*str)++) - '0');
    1284:	00251793          	slli	a5,a0,0x2
    1288:	00a787b3          	add	a5,a5,a0
    128c:	00179793          	slli	a5,a5,0x1
    1290:	00170613          	addi	a2,a4,1
    1294:	00c6a023          	sw	a2,0(a3)
    1298:	00074503          	lbu	a0,0(a4)
    129c:	00f50533          	add	a0,a0,a5
    12a0:	fd050513          	addi	a0,a0,-48
  while (_is_digit(**str)) {
    12a4:	0006a703          	lw	a4,0(a3)
    12a8:	00074783          	lbu	a5,0(a4)
  return (ch >= '0') && (ch <= '9');
    12ac:	fd078793          	addi	a5,a5,-48
    12b0:	0ff7f793          	zext.b	a5,a5
  while (_is_digit(**str)) {
    12b4:	00900613          	li	a2,9
    12b8:	fcf676e3          	bgeu	a2,a5,1284 <_atoi+0xc>
  }
  return i;
}
    12bc:	00008067          	ret

000012c0 <_out_rev>:
*
* @return Updated index in the buffer after outputting the string.
*
******************************************************************************/
static size_t _out_rev(out_fct_type out, char* buffer, size_t idx, size_t maxlen, const char* buf, size_t len, unsigned int width, unsigned int flags)
{
    12c0:	fd010113          	addi	sp,sp,-48
    12c4:	02112623          	sw	ra,44(sp)
    12c8:	02812423          	sw	s0,40(sp)
    12cc:	02912223          	sw	s1,36(sp)
    12d0:	03212023          	sw	s2,32(sp)
    12d4:	01312e23          	sw	s3,28(sp)
    12d8:	01412c23          	sw	s4,24(sp)
    12dc:	01512a23          	sw	s5,20(sp)
    12e0:	01612823          	sw	s6,16(sp)
    12e4:	01712623          	sw	s7,12(sp)
    12e8:	01812423          	sw	s8,8(sp)
    12ec:	00050493          	mv	s1,a0
    12f0:	00058913          	mv	s2,a1
    12f4:	00060b93          	mv	s7,a2
    12f8:	00068993          	mv	s3,a3
    12fc:	00070b13          	mv	s6,a4
    1300:	00078413          	mv	s0,a5
    1304:	00080a93          	mv	s5,a6
    1308:	00088c13          	mv	s8,a7
  const size_t start_idx = idx;

  // pad spaces up to given width
  if (!(flags & FLAGS_LEFT) && !(flags & FLAGS_ZEROPAD)) {
    130c:	0038f793          	andi	a5,a7,3
    1310:	04079c63          	bnez	a5,1368 <_out_rev+0xa8>
    1314:	01912223          	sw	s9,4(sp)
    for (size_t i = len; i < width; i++) {
    1318:	00040a13          	mv	s4,s0
    131c:	035a7263          	bgeu	s4,s5,1340 <_out_rev+0x80>
      out(' ', buffer, idx++, maxlen);
    1320:	00160c93          	addi	s9,a2,1
    1324:	00098693          	mv	a3,s3
    1328:	00090593          	mv	a1,s2
    132c:	02000513          	li	a0,32
    1330:	000480e7          	jalr	s1
    for (size_t i = len; i < width; i++) {
    1334:	001a0a13          	addi	s4,s4,1
      out(' ', buffer, idx++, maxlen);
    1338:	000c8613          	mv	a2,s9
    133c:	fe1ff06f          	j	131c <_out_rev+0x5c>
    1340:	00412c83          	lw	s9,4(sp)
    1344:	0240006f          	j	1368 <_out_rev+0xa8>
    }
  }

  // reverse string
  while (len) {
    out(buf[--len], buffer, idx++, maxlen);
    1348:	fff40413          	addi	s0,s0,-1
    134c:	008b07b3          	add	a5,s6,s0
    1350:	00160a13          	addi	s4,a2,1
    1354:	00098693          	mv	a3,s3
    1358:	00090593          	mv	a1,s2
    135c:	0007c503          	lbu	a0,0(a5)
    1360:	000480e7          	jalr	s1
    1364:	000a0613          	mv	a2,s4
  while (len) {
    1368:	fe0410e3          	bnez	s0,1348 <_out_rev+0x88>
  }

  // append pad spaces up to given width
  if (flags & FLAGS_LEFT) {
    136c:	002c7c13          	andi	s8,s8,2
    1370:	020c1c63          	bnez	s8,13a8 <_out_rev+0xe8>
      out(' ', buffer, idx++, maxlen);
    }
  }

  return idx;
}
    1374:	00060513          	mv	a0,a2
    1378:	02c12083          	lw	ra,44(sp)
    137c:	02812403          	lw	s0,40(sp)
    1380:	02412483          	lw	s1,36(sp)
    1384:	02012903          	lw	s2,32(sp)
    1388:	01c12983          	lw	s3,28(sp)
    138c:	01812a03          	lw	s4,24(sp)
    1390:	01412a83          	lw	s5,20(sp)
    1394:	01012b03          	lw	s6,16(sp)
    1398:	00c12b83          	lw	s7,12(sp)
    139c:	00812c03          	lw	s8,8(sp)
    13a0:	03010113          	addi	sp,sp,48
    13a4:	00008067          	ret
    while (idx - start_idx < width) {
    13a8:	417607b3          	sub	a5,a2,s7
    13ac:	fd57f4e3          	bgeu	a5,s5,1374 <_out_rev+0xb4>
      out(' ', buffer, idx++, maxlen);
    13b0:	00160413          	addi	s0,a2,1
    13b4:	00098693          	mv	a3,s3
    13b8:	00090593          	mv	a1,s2
    13bc:	02000513          	li	a0,32
    13c0:	000480e7          	jalr	s1
    13c4:	00040613          	mv	a2,s0
    13c8:	fe1ff06f          	j	13a8 <_out_rev+0xe8>

000013cc <_ntoa_format>:
*
* @return Number of characters written to the buffer.
*
******************************************************************************/
static size_t _ntoa_format(out_fct_type out, char* buffer, size_t idx, size_t maxlen, char* buf, size_t len, bool negative, unsigned int base, unsigned int prec, unsigned int width, unsigned int flags)
{
    13cc:	ff010113          	addi	sp,sp,-16
    13d0:	00112623          	sw	ra,12(sp)
    13d4:	00080f93          	mv	t6,a6
    13d8:	00088f13          	mv	t5,a7
    13dc:	01012e83          	lw	t4,16(sp)
    13e0:	01412803          	lw	a6,20(sp)
    13e4:	01812883          	lw	a7,24(sp)
  // pad leading zeros
  if (!(flags & FLAGS_LEFT)) {
    13e8:	0028f313          	andi	t1,a7,2
    13ec:	06031463          	bnez	t1,1454 <_ntoa_format+0x88>
    if (width && (flags & FLAGS_ZEROPAD) && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
    13f0:	02080863          	beqz	a6,1420 <_ntoa_format+0x54>
    13f4:	0018f313          	andi	t1,a7,1
    13f8:	02030463          	beqz	t1,1420 <_ntoa_format+0x54>
    13fc:	000f9663          	bnez	t6,1408 <_ntoa_format+0x3c>
    1400:	00c8f313          	andi	t1,a7,12
    1404:	00030e63          	beqz	t1,1420 <_ntoa_format+0x54>
      width--;
    1408:	fff80813          	addi	a6,a6,-1
    140c:	0140006f          	j	1420 <_ntoa_format+0x54>
    }
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = '0';
    1410:	00f70333          	add	t1,a4,a5
    1414:	03000e13          	li	t3,48
    1418:	01c30023          	sb	t3,0(t1)
    141c:	00178793          	addi	a5,a5,1
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1420:	01d7f663          	bgeu	a5,t4,142c <_ntoa_format+0x60>
    1424:	01f00313          	li	t1,31
    1428:	fef374e3          	bgeu	t1,a5,1410 <_ntoa_format+0x44>
    }
    while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    142c:	0018f313          	andi	t1,a7,1
    1430:	02030263          	beqz	t1,1454 <_ntoa_format+0x88>
    1434:	0307f063          	bgeu	a5,a6,1454 <_ntoa_format+0x88>
    1438:	01f00313          	li	t1,31
    143c:	00f36c63          	bltu	t1,a5,1454 <_ntoa_format+0x88>
      buf[len++] = '0';
    1440:	00f70333          	add	t1,a4,a5
    1444:	03000e13          	li	t3,48
    1448:	01c30023          	sb	t3,0(t1)
    144c:	00178793          	addi	a5,a5,1
    1450:	fddff06f          	j	142c <_ntoa_format+0x60>
    }
  }

  // handle hash
  if (flags & FLAGS_HASH) {
    1454:	0108f313          	andi	t1,a7,16
    1458:	04030063          	beqz	t1,1498 <_ntoa_format+0xcc>
    if (!(flags & FLAGS_PRECISION) && len && ((len == prec) || (len == width))) {
    145c:	4008f313          	andi	t1,a7,1024
    1460:	00031863          	bnez	t1,1470 <_ntoa_format+0xa4>
    1464:	00078663          	beqz	a5,1470 <_ntoa_format+0xa4>
    1468:	05d78e63          	beq	a5,t4,14c4 <_ntoa_format+0xf8>
    146c:	05078c63          	beq	a5,a6,14c4 <_ntoa_format+0xf8>
      len--;
      if (len && (base == 16U)) {
        len--;
      }
    }
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1470:	01000313          	li	t1,16
    1474:	0a6f0063          	beq	t5,t1,1514 <_ntoa_format+0x148>
      buf[len++] = 'x';
    }
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = 'X';
    }
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1478:	00200313          	li	t1,2
    147c:	0a6f0e63          	beq	t5,t1,1538 <_ntoa_format+0x16c>
      buf[len++] = 'b';
    }
    if (len < PRINTF_NTOA_BUFFER_SIZE) {
    1480:	01f00313          	li	t1,31
    1484:	02f36863          	bltu	t1,a5,14b4 <_ntoa_format+0xe8>
      buf[len++] = '0';
    1488:	00f70333          	add	t1,a4,a5
    148c:	03000e13          	li	t3,48
    1490:	01c30023          	sb	t3,0(t1)
    1494:	00178793          	addi	a5,a5,1
    }
  }

  if (len < PRINTF_NTOA_BUFFER_SIZE) {
    1498:	01f00313          	li	t1,31
    149c:	00f36c63          	bltu	t1,a5,14b4 <_ntoa_format+0xe8>
    if (negative) {
    14a0:	0a0f8a63          	beqz	t6,1554 <_ntoa_format+0x188>
      buf[len++] = '-';
    14a4:	00f70333          	add	t1,a4,a5
    14a8:	02d00e13          	li	t3,45
    14ac:	01c30023          	sb	t3,0(t1)
    14b0:	00178793          	addi	a5,a5,1
    else if (flags & FLAGS_SPACE) {
      buf[len++] = ' ';
    }
  }

  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
    14b4:	e0dff0ef          	jal	12c0 <_out_rev>
}
    14b8:	00c12083          	lw	ra,12(sp)
    14bc:	01010113          	addi	sp,sp,16
    14c0:	00008067          	ret
      len--;
    14c4:	fff78313          	addi	t1,a5,-1
      if (len && (base == 16U)) {
    14c8:	04030263          	beqz	t1,150c <_ntoa_format+0x140>
    14cc:	01000e13          	li	t3,16
    14d0:	03cf0a63          	beq	t5,t3,1504 <_ntoa_format+0x138>
      len--;
    14d4:	00030793          	mv	a5,t1
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    14d8:	01000313          	li	t1,16
    14dc:	f86f1ee3          	bne	t5,t1,1478 <_ntoa_format+0xac>
    14e0:	0208f313          	andi	t1,a7,32
    14e4:	f8030ae3          	beqz	t1,1478 <_ntoa_format+0xac>
    14e8:	01f00313          	li	t1,31
    14ec:	f8f366e3          	bltu	t1,a5,1478 <_ntoa_format+0xac>
      buf[len++] = 'X';
    14f0:	00f70333          	add	t1,a4,a5
    14f4:	05800e13          	li	t3,88
    14f8:	01c30023          	sb	t3,0(t1)
    14fc:	00178793          	addi	a5,a5,1
    1500:	f81ff06f          	j	1480 <_ntoa_format+0xb4>
        len--;
    1504:	ffe78793          	addi	a5,a5,-2
    1508:	f69ff06f          	j	1470 <_ntoa_format+0xa4>
      len--;
    150c:	00030793          	mv	a5,t1
    1510:	f61ff06f          	j	1470 <_ntoa_format+0xa4>
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1514:	0208f313          	andi	t1,a7,32
    1518:	fc0310e3          	bnez	t1,14d8 <_ntoa_format+0x10c>
    151c:	01f00313          	li	t1,31
    1520:	faf36ce3          	bltu	t1,a5,14d8 <_ntoa_format+0x10c>
      buf[len++] = 'x';
    1524:	00f70333          	add	t1,a4,a5
    1528:	07800e13          	li	t3,120
    152c:	01c30023          	sb	t3,0(t1)
    1530:	00178793          	addi	a5,a5,1
    1534:	f4dff06f          	j	1480 <_ntoa_format+0xb4>
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1538:	01f00313          	li	t1,31
    153c:	f6f36ce3          	bltu	t1,a5,14b4 <_ntoa_format+0xe8>
      buf[len++] = 'b';
    1540:	00f70333          	add	t1,a4,a5
    1544:	06200e13          	li	t3,98
    1548:	01c30023          	sb	t3,0(t1)
    154c:	00178793          	addi	a5,a5,1
    1550:	f31ff06f          	j	1480 <_ntoa_format+0xb4>
    else if (flags & FLAGS_PLUS) {
    1554:	0048f313          	andi	t1,a7,4
    1558:	00030c63          	beqz	t1,1570 <_ntoa_format+0x1a4>
      buf[len++] = '+';  // ignore the space if the '+' exists
    155c:	00f70333          	add	t1,a4,a5
    1560:	02b00e13          	li	t3,43
    1564:	01c30023          	sb	t3,0(t1)
    1568:	00178793          	addi	a5,a5,1
    156c:	f49ff06f          	j	14b4 <_ntoa_format+0xe8>
    else if (flags & FLAGS_SPACE) {
    1570:	0088f313          	andi	t1,a7,8
    1574:	f40300e3          	beqz	t1,14b4 <_ntoa_format+0xe8>
      buf[len++] = ' ';
    1578:	00f70333          	add	t1,a4,a5
    157c:	02000e13          	li	t3,32
    1580:	01c30023          	sb	t3,0(t1)
    1584:	00178793          	addi	a5,a5,1
    1588:	f2dff06f          	j	14b4 <_ntoa_format+0xe8>

0000158c <_ntoa_long>:
* @return Number of characters written to the buffer.
*
*
******************************************************************************/
static size_t _ntoa_long(out_fct_type out, char* buffer, size_t idx, size_t maxlen, unsigned long value, bool negative, unsigned long base, unsigned int prec, unsigned int width, unsigned int flags)
{
    158c:	fc010113          	addi	sp,sp,-64
    1590:	02112e23          	sw	ra,60(sp)
    1594:	00078f93          	mv	t6,a5
    1598:	04412f03          	lw	t5,68(sp)
  char buf[PRINTF_NTOA_BUFFER_SIZE];
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
    159c:	00071463          	bnez	a4,15a4 <_ntoa_long+0x18>
    flags &= ~FLAGS_HASH;
    15a0:	feff7f13          	andi	t5,t5,-17
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
    15a4:	400f7e93          	andi	t4,t5,1024
    15a8:	040e8063          	beqz	t4,15e8 <_ntoa_long+0x5c>
    15ac:	06070a63          	beqz	a4,1620 <_ntoa_long+0x94>
    15b0:	00000e93          	li	t4,0
    15b4:	0340006f          	j	15e8 <_ntoa_long+0x5c>
    do {
      const char digit = (char)(value % base);
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    15b8:	030e0e13          	addi	t3,t3,48
    15bc:	0ffe7313          	zext.b	t1,t3
    15c0:	001e8793          	addi	a5,t4,1
    15c4:	030e8e13          	addi	t3,t4,48
    15c8:	002e0eb3          	add	t4,t3,sp
    15cc:	fe6e8023          	sb	t1,-32(t4)
      value /= base;
    15d0:	03075333          	divu	t1,a4,a6
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    15d4:	05076863          	bltu	a4,a6,1624 <_ntoa_long+0x98>
    15d8:	01f00713          	li	a4,31
    15dc:	04f76463          	bltu	a4,a5,1624 <_ntoa_long+0x98>
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    15e0:	00078e93          	mv	t4,a5
      value /= base;
    15e4:	00030713          	mv	a4,t1
      const char digit = (char)(value % base);
    15e8:	03077e33          	remu	t3,a4,a6
    15ec:	0ffe7e13          	zext.b	t3,t3
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    15f0:	00900313          	li	t1,9
    15f4:	fdc372e3          	bgeu	t1,t3,15b8 <_ntoa_long+0x2c>
    15f8:	020f7313          	andi	t1,t5,32
    15fc:	00030e63          	beqz	t1,1618 <_ntoa_long+0x8c>
    1600:	04100313          	li	t1,65
    1604:	01c30333          	add	t1,t1,t3
    1608:	0ff37313          	zext.b	t1,t1
    160c:	ff630313          	addi	t1,t1,-10
    1610:	0ff37313          	zext.b	t1,t1
    1614:	fadff06f          	j	15c0 <_ntoa_long+0x34>
    1618:	06100313          	li	t1,97
    161c:	fe9ff06f          	j	1604 <_ntoa_long+0x78>
  size_t len = 0U;
    1620:	00070793          	mv	a5,a4
  }

  return _ntoa_format(out, buffer, idx, maxlen, buf, len, negative, (unsigned int)base, prec, width, flags);
    1624:	01e12423          	sw	t5,8(sp)
    1628:	04012703          	lw	a4,64(sp)
    162c:	00e12223          	sw	a4,4(sp)
    1630:	01112023          	sw	a7,0(sp)
    1634:	00080893          	mv	a7,a6
    1638:	000f8813          	mv	a6,t6
    163c:	01010713          	addi	a4,sp,16
    1640:	d8dff0ef          	jal	13cc <_ntoa_format>
}
    1644:	03c12083          	lw	ra,60(sp)
    1648:	04010113          	addi	sp,sp,64
    164c:	00008067          	ret

00001650 <_ntoa_long_long>:
*
* @return Number of characters written to the buffer.
*
******************************************************************************/
static size_t _ntoa_long_long(out_fct_type out, char* buffer, size_t idx, size_t maxlen, unsigned long long value, bool negative, unsigned long long base, unsigned int prec, unsigned int width, unsigned int flags)
{
    1650:	f8010113          	addi	sp,sp,-128
    1654:	06112623          	sw	ra,108(sp)
    1658:	06812423          	sw	s0,104(sp)
    165c:	06912223          	sw	s1,100(sp)
    1660:	07212023          	sw	s2,96(sp)
    1664:	05312e23          	sw	s3,92(sp)
    1668:	05412c23          	sw	s4,88(sp)
    166c:	05512a23          	sw	s5,84(sp)
    1670:	05612823          	sw	s6,80(sp)
    1674:	05712623          	sw	s7,76(sp)
    1678:	05812423          	sw	s8,72(sp)
    167c:	05912223          	sw	s9,68(sp)
    1680:	05a12023          	sw	s10,64(sp)
    1684:	03b12e23          	sw	s11,60(sp)
    1688:	00050b93          	mv	s7,a0
    168c:	00058c13          	mv	s8,a1
    1690:	00060c93          	mv	s9,a2
    1694:	00068d13          	mv	s10,a3
    1698:	00070993          	mv	s3,a4
    169c:	00078413          	mv	s0,a5
    16a0:	00080d93          	mv	s11,a6
    16a4:	07112e23          	sw	a7,124(sp)
    16a8:	00088a93          	mv	s5,a7
    16ac:	08012903          	lw	s2,128(sp)
    16b0:	08c12b03          	lw	s6,140(sp)
  char buf[PRINTF_NTOA_BUFFER_SIZE];
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
    16b4:	00f767b3          	or	a5,a4,a5
    16b8:	00079463          	bnez	a5,16c0 <_ntoa_long_long+0x70>
    flags &= ~FLAGS_HASH;
    16bc:	fefb7b13          	andi	s6,s6,-17
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
    16c0:	400b7493          	andi	s1,s6,1024
    16c4:	04048e63          	beqz	s1,1720 <_ntoa_long_long+0xd0>
    16c8:	0089e7b3          	or	a5,s3,s0
    16cc:	0a078263          	beqz	a5,1770 <_ntoa_long_long+0x120>
    16d0:	00000493          	li	s1,0
    16d4:	04c0006f          	j	1720 <_ntoa_long_long+0xd0>
    do {
      const char digit = (char)(value % base);
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    16d8:	03050513          	addi	a0,a0,48
    16dc:	0ff57793          	zext.b	a5,a0
    16e0:	00148a13          	addi	s4,s1,1
    16e4:	03048713          	addi	a4,s1,48
    16e8:	002704b3          	add	s1,a4,sp
    16ec:	fef48023          	sb	a5,-32(s1)
      value /= base;
    16f0:	000a8613          	mv	a2,s5
    16f4:	00090693          	mv	a3,s2
    16f8:	00098513          	mv	a0,s3
    16fc:	00040593          	mv	a1,s0
    1700:	628010ef          	jal	2d28 <__udivdi3>
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    1704:	07246863          	bltu	s0,s2,1774 <_ntoa_long_long+0x124>
    1708:	06890063          	beq	s2,s0,1768 <_ntoa_long_long+0x118>
    170c:	01f00793          	li	a5,31
    1710:	0747e263          	bltu	a5,s4,1774 <_ntoa_long_long+0x124>
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1714:	000a0493          	mv	s1,s4
      value /= base;
    1718:	00050993          	mv	s3,a0
    171c:	00058413          	mv	s0,a1
      const char digit = (char)(value % base);
    1720:	000a8613          	mv	a2,s5
    1724:	00090693          	mv	a3,s2
    1728:	00098513          	mv	a0,s3
    172c:	00040593          	mv	a1,s0
    1730:	2a9010ef          	jal	31d8 <__umoddi3>
    1734:	0ff57513          	zext.b	a0,a0
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1738:	00900793          	li	a5,9
    173c:	f8a7fee3          	bgeu	a5,a0,16d8 <_ntoa_long_long+0x88>
    1740:	020b7793          	andi	a5,s6,32
    1744:	00078e63          	beqz	a5,1760 <_ntoa_long_long+0x110>
    1748:	04100793          	li	a5,65
    174c:	00a787b3          	add	a5,a5,a0
    1750:	0ff7f793          	zext.b	a5,a5
    1754:	ff678793          	addi	a5,a5,-10
    1758:	0ff7f793          	zext.b	a5,a5
    175c:	f85ff06f          	j	16e0 <_ntoa_long_long+0x90>
    1760:	06100793          	li	a5,97
    1764:	fe9ff06f          	j	174c <_ntoa_long_long+0xfc>
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    1768:	fb59f2e3          	bgeu	s3,s5,170c <_ntoa_long_long+0xbc>
    176c:	0080006f          	j	1774 <_ntoa_long_long+0x124>
  size_t len = 0U;
    1770:	00000a13          	li	s4,0
  }

  return _ntoa_format(out, buffer, idx, maxlen, buf, len, negative, (unsigned int)base, prec, width, flags);
    1774:	01612423          	sw	s6,8(sp)
    1778:	08812783          	lw	a5,136(sp)
    177c:	00f12223          	sw	a5,4(sp)
    1780:	08412783          	lw	a5,132(sp)
    1784:	00f12023          	sw	a5,0(sp)
    1788:	000a8893          	mv	a7,s5
    178c:	000d8813          	mv	a6,s11
    1790:	000a0793          	mv	a5,s4
    1794:	01010713          	addi	a4,sp,16
    1798:	000d0693          	mv	a3,s10
    179c:	000c8613          	mv	a2,s9
    17a0:	000c0593          	mv	a1,s8
    17a4:	000b8513          	mv	a0,s7
    17a8:	c25ff0ef          	jal	13cc <_ntoa_format>
}
    17ac:	06c12083          	lw	ra,108(sp)
    17b0:	06812403          	lw	s0,104(sp)
    17b4:	06412483          	lw	s1,100(sp)
    17b8:	06012903          	lw	s2,96(sp)
    17bc:	05c12983          	lw	s3,92(sp)
    17c0:	05812a03          	lw	s4,88(sp)
    17c4:	05412a83          	lw	s5,84(sp)
    17c8:	05012b03          	lw	s6,80(sp)
    17cc:	04c12b83          	lw	s7,76(sp)
    17d0:	04812c03          	lw	s8,72(sp)
    17d4:	04412c83          	lw	s9,68(sp)
    17d8:	04012d03          	lw	s10,64(sp)
    17dc:	03c12d83          	lw	s11,60(sp)
    17e0:	08010113          	addi	sp,sp,128
    17e4:	00008067          	ret

000017e8 <_etoa>:
*
* @note           Contributed by: Martijn Jasperse <m.jasperse@gmail.com>
*
******************************************************************************/
static size_t _etoa(out_fct_type out, char* buffer, size_t idx, size_t maxlen, double value, unsigned int prec, unsigned int width, unsigned int flags)
{
    17e8:	f9010113          	addi	sp,sp,-112
    17ec:	06112623          	sw	ra,108(sp)
    17f0:	06812423          	sw	s0,104(sp)
    17f4:	06912223          	sw	s1,100(sp)
    17f8:	07212023          	sw	s2,96(sp)
    17fc:	05312e23          	sw	s3,92(sp)
    1800:	05412c23          	sw	s4,88(sp)
    1804:	05512a23          	sw	s5,84(sp)
    1808:	05612823          	sw	s6,80(sp)
    180c:	05712623          	sw	s7,76(sp)
    1810:	05812423          	sw	s8,72(sp)
    1814:	00050913          	mv	s2,a0
    1818:	00058993          	mv	s3,a1
    181c:	00060b13          	mv	s6,a2
    1820:	00068a13          	mv	s4,a3
    1824:	00070493          	mv	s1,a4
    1828:	00078413          	mv	s0,a5
    182c:	00080b93          	mv	s7,a6
    1830:	00088a93          	mv	s5,a7
    1834:	07012c03          	lw	s8,112(sp)
  // check for NaN and special values
  if ((value != value) || (value > DBL_MAX) || (value < -DBL_MAX)) {
    1838:	00048613          	mv	a2,s1
    183c:	00040693          	mv	a3,s0
    1840:	00048513          	mv	a0,s1
    1844:	00040593          	mv	a1,s0
    1848:	659020ef          	jal	46a0 <__eqdf2>
    184c:	30051263          	bnez	a0,1b50 <_etoa+0x368>
    1850:	8101a603          	lw	a2,-2032(gp) # 5fc8 <__clz_tab+0x100>
    1854:	8141a683          	lw	a3,-2028(gp) # 5fcc <__clz_tab+0x104>
    1858:	00048513          	mv	a0,s1
    185c:	00040593          	mv	a1,s0
    1860:	6cd020ef          	jal	472c <__gedf2>
    1864:	2ea04663          	bgtz	a0,1b50 <_etoa+0x368>
    1868:	8181a603          	lw	a2,-2024(gp) # 5fd0 <__clz_tab+0x108>
    186c:	81c1a683          	lw	a3,-2020(gp) # 5fd4 <__clz_tab+0x10c>
    1870:	00048513          	mv	a0,s1
    1874:	00040593          	mv	a1,s0
    1878:	7b5020ef          	jal	482c <__ledf2>
    187c:	2c054a63          	bltz	a0,1b50 <_etoa+0x368>
    1880:	05912223          	sw	s9,68(sp)
    1884:	05a12023          	sw	s10,64(sp)
    1888:	03b12e23          	sw	s11,60(sp)
    return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
  }

  // determine the sign
  const bool negative = value < 0;
  if (negative) {
    188c:	00000613          	li	a2,0
    1890:	00000693          	li	a3,0
    1894:	00048513          	mv	a0,s1
    1898:	00040593          	mv	a1,s0
    189c:	791020ef          	jal	482c <__ledf2>
    18a0:	30054463          	bltz	a0,1ba8 <_etoa+0x3c0>
    18a4:	00912823          	sw	s1,16(sp)
    18a8:	00040c93          	mv	s9,s0
    value = -value;
  }

  // default precision
  if (!(flags & FLAGS_PRECISION)) {
    18ac:	400c7793          	andi	a5,s8,1024
    18b0:	02f12623          	sw	a5,44(sp)
    18b4:	00079463          	bnez	a5,18bc <_etoa+0xd4>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    18b8:	00400b93          	li	s7,4
    uint64_t U;
    double   F;
  } conv;

  conv.F = value;
  int exp2 = (int)((conv.U >> 52U) & 0x07FFU) - 1023;           // effectively log2
    18bc:	014cd513          	srli	a0,s9,0x14
    18c0:	7ff57513          	andi	a0,a0,2047
  conv.U = (conv.U & ((1ULL << 52U) - 1U)) | (1023ULL << 52U);  // drop the exponent so conv.F is now in [1,2)
    18c4:	001007b7          	lui	a5,0x100
    18c8:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf8f7f>
    18cc:	00fcf7b3          	and	a5,s9,a5
    18d0:	3ff00d37          	lui	s10,0x3ff00
    18d4:	00fd6d33          	or	s10,s10,a5
  // now approximate log10 from the log2 integer part and an expansion of ln around 1.5
  int expval = (int)(0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
    18d8:	c0150513          	addi	a0,a0,-1023
    18dc:	130040ef          	jal	5a0c <__floatsidf>
    18e0:	8201a603          	lw	a2,-2016(gp) # 5fd8 <__clz_tab+0x110>
    18e4:	8241a683          	lw	a3,-2012(gp) # 5fdc <__clz_tab+0x114>
    18e8:	04c030ef          	jal	4934 <__muldf3>
    18ec:	8281a603          	lw	a2,-2008(gp) # 5fe0 <__clz_tab+0x118>
    18f0:	82c1a683          	lw	a3,-2004(gp) # 5fe4 <__clz_tab+0x11c>
    18f4:	555010ef          	jal	3648 <__adddf3>
    18f8:	00050d93          	mv	s11,a0
    18fc:	00b12a23          	sw	a1,20(sp)
    1900:	8301a603          	lw	a2,-2000(gp) # 5fe8 <__clz_tab+0x120>
    1904:	8341a683          	lw	a3,-1996(gp) # 5fec <__clz_tab+0x124>
    1908:	01012703          	lw	a4,16(sp)
    190c:	00070513          	mv	a0,a4
    1910:	000d0593          	mv	a1,s10
    1914:	6f8030ef          	jal	500c <__subdf3>
    1918:	8381a603          	lw	a2,-1992(gp) # 5ff0 <__clz_tab+0x128>
    191c:	83c1a683          	lw	a3,-1988(gp) # 5ff4 <__clz_tab+0x12c>
    1920:	014030ef          	jal	4934 <__muldf3>
    1924:	00050613          	mv	a2,a0
    1928:	00058693          	mv	a3,a1
    192c:	000d8513          	mv	a0,s11
    1930:	01412583          	lw	a1,20(sp)
    1934:	515010ef          	jal	3648 <__adddf3>
    1938:	7dd030ef          	jal	5914 <__fixdfsi>
    193c:	00050d13          	mv	s10,a0
  // now we want to compute 10^expval but we want to be sure it won't overflow
  exp2 = (int)(expval * 3.321928094887362 + 0.5);
    1940:	0cc040ef          	jal	5a0c <__floatsidf>
    1944:	00a12a23          	sw	a0,20(sp)
    1948:	00b12c23          	sw	a1,24(sp)
    194c:	8401a603          	lw	a2,-1984(gp) # 5ff8 <__clz_tab+0x130>
    1950:	8441a683          	lw	a3,-1980(gp) # 5ffc <__clz_tab+0x134>
    1954:	7e1020ef          	jal	4934 <__muldf3>
    1958:	8481a603          	lw	a2,-1976(gp) # 6000 <__clz_tab+0x138>
    195c:	84c1a683          	lw	a3,-1972(gp) # 6004 <__clz_tab+0x13c>
    1960:	4e9010ef          	jal	3648 <__adddf3>
    1964:	7b1030ef          	jal	5914 <__fixdfsi>
    1968:	00050d93          	mv	s11,a0
  const double z  = expval * 2.302585092994046 - exp2 * 0.6931471805599453;
    196c:	8501a603          	lw	a2,-1968(gp) # 6008 <__clz_tab+0x140>
    1970:	8541a683          	lw	a3,-1964(gp) # 600c <__clz_tab+0x144>
    1974:	01412503          	lw	a0,20(sp)
    1978:	01812583          	lw	a1,24(sp)
    197c:	7b9020ef          	jal	4934 <__muldf3>
    1980:	00a12a23          	sw	a0,20(sp)
    1984:	00b12c23          	sw	a1,24(sp)
    1988:	000d8513          	mv	a0,s11
    198c:	080040ef          	jal	5a0c <__floatsidf>
    1990:	8581a603          	lw	a2,-1960(gp) # 6010 <__clz_tab+0x148>
    1994:	85c1a683          	lw	a3,-1956(gp) # 6014 <__clz_tab+0x14c>
    1998:	79d020ef          	jal	4934 <__muldf3>
    199c:	00050613          	mv	a2,a0
    19a0:	00058693          	mv	a3,a1
    19a4:	01412503          	lw	a0,20(sp)
    19a8:	01812583          	lw	a1,24(sp)
    19ac:	660030ef          	jal	500c <__subdf3>
  const double z2 = z * z;
    19b0:	00a12a23          	sw	a0,20(sp)
    19b4:	00050613          	mv	a2,a0
    19b8:	00b12c23          	sw	a1,24(sp)
    19bc:	00058693          	mv	a3,a1
    19c0:	775020ef          	jal	4934 <__muldf3>
    19c4:	00a12e23          	sw	a0,28(sp)
    19c8:	02b12023          	sw	a1,32(sp)
  conv.U = (uint64_t)(exp2 + 1023) << 52U;
    19cc:	3ffd8d93          	addi	s11,s11,1023
    19d0:	014d9d93          	slli	s11,s11,0x14
  // compute exp(z) using continued fractions, see https://en.wikipedia.org/wiki/Exponential_function#Continued_fractions_for_ex
  conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
    19d4:	01412803          	lw	a6,20(sp)
    19d8:	00080613          	mv	a2,a6
    19dc:	01812783          	lw	a5,24(sp)
    19e0:	00078693          	mv	a3,a5
    19e4:	00080513          	mv	a0,a6
    19e8:	00078593          	mv	a1,a5
    19ec:	45d010ef          	jal	3648 <__adddf3>
    19f0:	02a12223          	sw	a0,36(sp)
    19f4:	02b12423          	sw	a1,40(sp)
    19f8:	01412603          	lw	a2,20(sp)
    19fc:	01812683          	lw	a3,24(sp)
    1a00:	8601a503          	lw	a0,-1952(gp) # 6018 <__clz_tab+0x150>
    1a04:	8641a583          	lw	a1,-1948(gp) # 601c <__clz_tab+0x154>
    1a08:	604030ef          	jal	500c <__subdf3>
    1a0c:	00a12a23          	sw	a0,20(sp)
    1a10:	00b12c23          	sw	a1,24(sp)
    1a14:	8681a603          	lw	a2,-1944(gp) # 6020 <__clz_tab+0x158>
    1a18:	86c1a683          	lw	a3,-1940(gp) # 6024 <__clz_tab+0x15c>
    1a1c:	01c12503          	lw	a0,28(sp)
    1a20:	02012583          	lw	a1,32(sp)
    1a24:	4ec020ef          	jal	3f10 <__divdf3>
    1a28:	8701a603          	lw	a2,-1936(gp) # 6028 <__clz_tab+0x160>
    1a2c:	8741a683          	lw	a3,-1932(gp) # 602c <__clz_tab+0x164>
    1a30:	419010ef          	jal	3648 <__adddf3>
    1a34:	00050613          	mv	a2,a0
    1a38:	00058693          	mv	a3,a1
    1a3c:	01c12503          	lw	a0,28(sp)
    1a40:	02012583          	lw	a1,32(sp)
    1a44:	4cc020ef          	jal	3f10 <__divdf3>
    1a48:	8781a603          	lw	a2,-1928(gp) # 6030 <__clz_tab+0x168>
    1a4c:	87c1a683          	lw	a3,-1924(gp) # 6034 <__clz_tab+0x16c>
    1a50:	3f9010ef          	jal	3648 <__adddf3>
    1a54:	00050613          	mv	a2,a0
    1a58:	00058693          	mv	a3,a1
    1a5c:	01c12503          	lw	a0,28(sp)
    1a60:	02012583          	lw	a1,32(sp)
    1a64:	4ac020ef          	jal	3f10 <__divdf3>
    1a68:	00050613          	mv	a2,a0
    1a6c:	00058693          	mv	a3,a1
    1a70:	01412503          	lw	a0,20(sp)
    1a74:	01812583          	lw	a1,24(sp)
    1a78:	3d1010ef          	jal	3648 <__adddf3>
    1a7c:	00050613          	mv	a2,a0
    1a80:	00058693          	mv	a3,a1
    1a84:	02412503          	lw	a0,36(sp)
    1a88:	02812583          	lw	a1,40(sp)
    1a8c:	484020ef          	jal	3f10 <__divdf3>
    1a90:	8801a603          	lw	a2,-1920(gp) # 6038 <__clz_tab+0x170>
    1a94:	8841a683          	lw	a3,-1916(gp) # 603c <__clz_tab+0x174>
    1a98:	3b1010ef          	jal	3648 <__adddf3>
    1a9c:	00000713          	li	a4,0
    1aa0:	00070613          	mv	a2,a4
    1aa4:	000d8693          	mv	a3,s11
    1aa8:	68d020ef          	jal	4934 <__muldf3>
    1aac:	00050d93          	mv	s11,a0
    1ab0:	00a12c23          	sw	a0,24(sp)
    1ab4:	00b12a23          	sw	a1,20(sp)
    1ab8:	00b12e23          	sw	a1,28(sp)
  // correct for rounding errors
  if (value < conv.F) {
    1abc:	01012703          	lw	a4,16(sp)
    1ac0:	00070613          	mv	a2,a4
    1ac4:	000c8693          	mv	a3,s9
    1ac8:	465020ef          	jal	472c <__gedf2>
    1acc:	02a05263          	blez	a0,1af0 <_etoa+0x308>
    expval--;
    1ad0:	fffd0d13          	addi	s10,s10,-1 # 3fefffff <__freertos_irq_stack_top+0x3fef8f7f>
    conv.F /= 10;
    1ad4:	8701a603          	lw	a2,-1936(gp) # 6028 <__clz_tab+0x160>
    1ad8:	8741a683          	lw	a3,-1932(gp) # 602c <__clz_tab+0x164>
    1adc:	000d8513          	mv	a0,s11
    1ae0:	01412583          	lw	a1,20(sp)
    1ae4:	42c020ef          	jal	3f10 <__divdf3>
    1ae8:	00a12c23          	sw	a0,24(sp)
    1aec:	00b12e23          	sw	a1,28(sp)
  }

  // the exponent format is "%+03d" and largest value is "307", so set aside 4-5 characters
  unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
    1af0:	063d0793          	addi	a5,s10,99
    1af4:	0c600713          	li	a4,198
    1af8:	0cf76063          	bltu	a4,a5,1bb8 <_etoa+0x3d0>
    1afc:	00400d93          	li	s11,4

  // in "%g" mode, "prec" is the number of *significant figures* not decimals
  if (flags & FLAGS_ADAPT_EXP) {
    1b00:	014c1793          	slli	a5,s8,0x14
    1b04:	0c07d663          	bgez	a5,1bd0 <_etoa+0x3e8>
    // do we want to fall-back to "%f" mode?
    if ((value >= 1e-4) && (value < 1e6)) {
    1b08:	8881a603          	lw	a2,-1912(gp) # 6040 <__clz_tab+0x178>
    1b0c:	88c1a683          	lw	a3,-1908(gp) # 6044 <__clz_tab+0x17c>
    1b10:	01012703          	lw	a4,16(sp)
    1b14:	00070513          	mv	a0,a4
    1b18:	000c8593          	mv	a1,s9
    1b1c:	411020ef          	jal	472c <__gedf2>
    1b20:	0c054063          	bltz	a0,1be0 <_etoa+0x3f8>
    1b24:	8901a603          	lw	a2,-1904(gp) # 6048 <__clz_tab+0x180>
    1b28:	8941a683          	lw	a3,-1900(gp) # 604c <__clz_tab+0x184>
    1b2c:	01012703          	lw	a4,16(sp)
    1b30:	00070513          	mv	a0,a4
    1b34:	000c8593          	mv	a1,s9
    1b38:	4f5020ef          	jal	482c <__ledf2>
    1b3c:	0a055263          	bgez	a0,1be0 <_etoa+0x3f8>
      if ((int)prec > expval) {
    1b40:	097d5063          	bge	s10,s7,1bc0 <_etoa+0x3d8>
        prec = (unsigned)((int)prec - expval - 1);
    1b44:	41ab8d33          	sub	s10,s7,s10
    1b48:	fffd0b93          	addi	s7,s10,-1
    1b4c:	0780006f          	j	1bc4 <_etoa+0x3dc>
    return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
    1b50:	01812023          	sw	s8,0(sp)
    1b54:	000a8893          	mv	a7,s5
    1b58:	000b8813          	mv	a6,s7
    1b5c:	00048713          	mv	a4,s1
    1b60:	00040793          	mv	a5,s0
    1b64:	000a0693          	mv	a3,s4
    1b68:	000b0613          	mv	a2,s6
    1b6c:	00098593          	mv	a1,s3
    1b70:	00090513          	mv	a0,s2
    1b74:	1e8000ef          	jal	1d5c <_ftoa>
    if (flags & FLAGS_LEFT) {
      while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
    }
  }
  return idx;
}
    1b78:	06c12083          	lw	ra,108(sp)
    1b7c:	06812403          	lw	s0,104(sp)
    1b80:	06412483          	lw	s1,100(sp)
    1b84:	06012903          	lw	s2,96(sp)
    1b88:	05c12983          	lw	s3,92(sp)
    1b8c:	05812a03          	lw	s4,88(sp)
    1b90:	05412a83          	lw	s5,84(sp)
    1b94:	05012b03          	lw	s6,80(sp)
    1b98:	04c12b83          	lw	s7,76(sp)
    1b9c:	04812c03          	lw	s8,72(sp)
    1ba0:	07010113          	addi	sp,sp,112
    1ba4:	00008067          	ret
    value = -value;
    1ba8:	00912823          	sw	s1,16(sp)
    1bac:	80000cb7          	lui	s9,0x80000
    1bb0:	008cccb3          	xor	s9,s9,s0
    1bb4:	cf9ff06f          	j	18ac <_etoa+0xc4>
  unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
    1bb8:	00500d93          	li	s11,5
    1bbc:	f45ff06f          	j	1b00 <_etoa+0x318>
        prec = 0;
    1bc0:	00000b93          	li	s7,0
      flags |= FLAGS_PRECISION;   // make sure _ftoa respects precision
    1bc4:	400c6c13          	ori	s8,s8,1024
      minwidth = 0U;
    1bc8:	00000d93          	li	s11,0
      expval   = 0;
    1bcc:	00000d13          	li	s10,0
  if (width > minwidth) {
    1bd0:	035df263          	bgeu	s11,s5,1bf4 <_etoa+0x40c>
    fwidth -= minwidth;
    1bd4:	41ba87b3          	sub	a5,s5,s11
    1bd8:	00f12a23          	sw	a5,20(sp)
    1bdc:	01c0006f          	j	1bf8 <_etoa+0x410>
      if ((prec > 0) && (flags & FLAGS_PRECISION)) {
    1be0:	fe0b88e3          	beqz	s7,1bd0 <_etoa+0x3e8>
    1be4:	02c12783          	lw	a5,44(sp)
    1be8:	fe0784e3          	beqz	a5,1bd0 <_etoa+0x3e8>
        --prec;
    1bec:	fffb8b93          	addi	s7,s7,-1
    1bf0:	fe1ff06f          	j	1bd0 <_etoa+0x3e8>
    fwidth = 0U;
    1bf4:	00012a23          	sw	zero,20(sp)
  if ((flags & FLAGS_LEFT) && minwidth) {
    1bf8:	002c7793          	andi	a5,s8,2
    1bfc:	02f12023          	sw	a5,32(sp)
    1c00:	00078663          	beqz	a5,1c0c <_etoa+0x424>
    1c04:	000d8463          	beqz	s11,1c0c <_etoa+0x424>
    fwidth = 0U;
    1c08:	00012a23          	sw	zero,20(sp)
  if (expval) {
    1c0c:	020d0663          	beqz	s10,1c38 <_etoa+0x450>
    value /= conv.F;
    1c10:	01812703          	lw	a4,24(sp)
    1c14:	01c12783          	lw	a5,28(sp)
    1c18:	00070613          	mv	a2,a4
    1c1c:	00078693          	mv	a3,a5
    1c20:	01012703          	lw	a4,16(sp)
    1c24:	00070513          	mv	a0,a4
    1c28:	000c8593          	mv	a1,s9
    1c2c:	2e4020ef          	jal	3f10 <__divdf3>
    1c30:	00a12823          	sw	a0,16(sp)
    1c34:	00058c93          	mv	s9,a1
  idx = _ftoa(out, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);
    1c38:	00000613          	li	a2,0
    1c3c:	00000693          	li	a3,0
    1c40:	00048513          	mv	a0,s1
    1c44:	00040593          	mv	a1,s0
    1c48:	3e5020ef          	jal	482c <__ledf2>
    1c4c:	0a054c63          	bltz	a0,1d04 <_etoa+0x51c>
    1c50:	fffff7b7          	lui	a5,0xfffff
    1c54:	7ff78793          	addi	a5,a5,2047 # fffff7ff <__freertos_irq_stack_top+0xffff877f>
    1c58:	00fc77b3          	and	a5,s8,a5
    1c5c:	00f12023          	sw	a5,0(sp)
    1c60:	01412883          	lw	a7,20(sp)
    1c64:	000b8813          	mv	a6,s7
    1c68:	01012603          	lw	a2,16(sp)
    1c6c:	00060713          	mv	a4,a2
    1c70:	000c8793          	mv	a5,s9
    1c74:	000a0693          	mv	a3,s4
    1c78:	000b0613          	mv	a2,s6
    1c7c:	00098593          	mv	a1,s3
    1c80:	00090513          	mv	a0,s2
    1c84:	0d8000ef          	jal	1d5c <_ftoa>
  if (minwidth) {
    1c88:	0c0d8263          	beqz	s11,1d4c <_etoa+0x564>
    out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
    1c8c:	020c7c13          	andi	s8,s8,32
    1c90:	080c0063          	beqz	s8,1d10 <_etoa+0x528>
    1c94:	04500793          	li	a5,69
    1c98:	00150413          	addi	s0,a0,1
    1c9c:	000a0693          	mv	a3,s4
    1ca0:	00050613          	mv	a2,a0
    1ca4:	00098593          	mv	a1,s3
    1ca8:	00078513          	mv	a0,a5
    1cac:	000900e7          	jalr	s2
    idx = _ntoa_long(out, buffer, idx, maxlen, (expval < 0) ? -expval : expval, expval < 0, 10, 0, minwidth-1, FLAGS_ZEROPAD | FLAGS_PLUS);
    1cb0:	41fd5713          	srai	a4,s10,0x1f
    1cb4:	01a746b3          	xor	a3,a4,s10
    1cb8:	00500793          	li	a5,5
    1cbc:	00f12223          	sw	a5,4(sp)
    1cc0:	fffd8d93          	addi	s11,s11,-1
    1cc4:	01b12023          	sw	s11,0(sp)
    1cc8:	00000893          	li	a7,0
    1ccc:	00a00813          	li	a6,10
    1cd0:	01fd5793          	srli	a5,s10,0x1f
    1cd4:	40e68733          	sub	a4,a3,a4
    1cd8:	000a0693          	mv	a3,s4
    1cdc:	00040613          	mv	a2,s0
    1ce0:	00098593          	mv	a1,s3
    1ce4:	00090513          	mv	a0,s2
    1ce8:	8a5ff0ef          	jal	158c <_ntoa_long>
    if (flags & FLAGS_LEFT) {
    1cec:	02012783          	lw	a5,32(sp)
    1cf0:	04079263          	bnez	a5,1d34 <_etoa+0x54c>
    1cf4:	04412c83          	lw	s9,68(sp)
    1cf8:	04012d03          	lw	s10,64(sp)
    1cfc:	03c12d83          	lw	s11,60(sp)
    1d00:	e79ff06f          	j	1b78 <_etoa+0x390>
  idx = _ftoa(out, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);
    1d04:	800007b7          	lui	a5,0x80000
    1d08:	0197ccb3          	xor	s9,a5,s9
    1d0c:	f45ff06f          	j	1c50 <_etoa+0x468>
    out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
    1d10:	06500793          	li	a5,101
    1d14:	f85ff06f          	j	1c98 <_etoa+0x4b0>
      while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
    1d18:	00150413          	addi	s0,a0,1
    1d1c:	000a0693          	mv	a3,s4
    1d20:	00050613          	mv	a2,a0
    1d24:	00098593          	mv	a1,s3
    1d28:	02000513          	li	a0,32
    1d2c:	000900e7          	jalr	s2
    1d30:	00040513          	mv	a0,s0
    1d34:	416507b3          	sub	a5,a0,s6
    1d38:	ff57e0e3          	bltu	a5,s5,1d18 <_etoa+0x530>
    1d3c:	04412c83          	lw	s9,68(sp)
    1d40:	04012d03          	lw	s10,64(sp)
    1d44:	03c12d83          	lw	s11,60(sp)
    1d48:	e31ff06f          	j	1b78 <_etoa+0x390>
    1d4c:	04412c83          	lw	s9,68(sp)
    1d50:	04012d03          	lw	s10,64(sp)
    1d54:	03c12d83          	lw	s11,60(sp)
    1d58:	e21ff06f          	j	1b78 <_etoa+0x390>

00001d5c <_ftoa>:
{
    1d5c:	f7010113          	addi	sp,sp,-144
    1d60:	08112623          	sw	ra,140(sp)
    1d64:	08912223          	sw	s1,132(sp)
    1d68:	07312e23          	sw	s3,124(sp)
    1d6c:	07412c23          	sw	s4,120(sp)
    1d70:	07612823          	sw	s6,112(sp)
    1d74:	07712623          	sw	s7,108(sp)
    1d78:	07812423          	sw	s8,104(sp)
    1d7c:	07912223          	sw	s9,100(sp)
    1d80:	07a12023          	sw	s10,96(sp)
    1d84:	05b12e23          	sw	s11,92(sp)
    1d88:	00050b93          	mv	s7,a0
    1d8c:	00058c13          	mv	s8,a1
    1d90:	00060c93          	mv	s9,a2
    1d94:	00068d13          	mv	s10,a3
    1d98:	00070a13          	mv	s4,a4
    1d9c:	00078993          	mv	s3,a5
    1da0:	00080493          	mv	s1,a6
    1da4:	00088b13          	mv	s6,a7
    1da8:	09012d83          	lw	s11,144(sp)
  if (value != value)
    1dac:	00070613          	mv	a2,a4
    1db0:	00078693          	mv	a3,a5
    1db4:	00070513          	mv	a0,a4
    1db8:	00078593          	mv	a1,a5
    1dbc:	0e5020ef          	jal	46a0 <__eqdf2>
    1dc0:	0c051463          	bnez	a0,1e88 <_ftoa+0x12c>
  if (value < -DBL_MAX)
    1dc4:	8181a603          	lw	a2,-2024(gp) # 5fd0 <__clz_tab+0x108>
    1dc8:	81c1a683          	lw	a3,-2020(gp) # 5fd4 <__clz_tab+0x10c>
    1dcc:	000a0513          	mv	a0,s4
    1dd0:	00098593          	mv	a1,s3
    1dd4:	259020ef          	jal	482c <__ledf2>
    1dd8:	0c054e63          	bltz	a0,1eb4 <_ftoa+0x158>
  if (value > DBL_MAX)
    1ddc:	8101a603          	lw	a2,-2032(gp) # 5fc8 <__clz_tab+0x100>
    1de0:	8141a683          	lw	a3,-2028(gp) # 5fcc <__clz_tab+0x104>
    1de4:	000a0513          	mv	a0,s4
    1de8:	00098593          	mv	a1,s3
    1dec:	141020ef          	jal	472c <__gedf2>
    1df0:	0ea04863          	bgtz	a0,1ee0 <_ftoa+0x184>
  if ((value > PRINTF_MAX_FLOAT) || (value < -PRINTF_MAX_FLOAT)) {
    1df4:	8981a603          	lw	a2,-1896(gp) # 6050 <__clz_tab+0x188>
    1df8:	89c1a683          	lw	a3,-1892(gp) # 6054 <__clz_tab+0x18c>
    1dfc:	000a0513          	mv	a0,s4
    1e00:	00098593          	mv	a1,s3
    1e04:	129020ef          	jal	472c <__gedf2>
    1e08:	12a04263          	bgtz	a0,1f2c <_ftoa+0x1d0>
    1e0c:	8a01a603          	lw	a2,-1888(gp) # 6058 <__clz_tab+0x190>
    1e10:	8a41a683          	lw	a3,-1884(gp) # 605c <__clz_tab+0x194>
    1e14:	000a0513          	mv	a0,s4
    1e18:	00098593          	mv	a1,s3
    1e1c:	211020ef          	jal	482c <__ledf2>
    1e20:	10054663          	bltz	a0,1f2c <_ftoa+0x1d0>
    1e24:	08812423          	sw	s0,136(sp)
    1e28:	09212023          	sw	s2,128(sp)
    1e2c:	07512a23          	sw	s5,116(sp)
  if (value < 0) {
    1e30:	00000613          	li	a2,0
    1e34:	00000693          	li	a3,0
    1e38:	000a0513          	mv	a0,s4
    1e3c:	00098593          	mv	a1,s3
    1e40:	1ed020ef          	jal	482c <__ledf2>
    1e44:	10054a63          	bltz	a0,1f58 <_ftoa+0x1fc>
  bool negative = false;
    1e48:	02012223          	sw	zero,36(sp)
  if (!(flags & FLAGS_PRECISION)) {
    1e4c:	400df793          	andi	a5,s11,1024
    1e50:	12078863          	beqz	a5,1f80 <_ftoa+0x224>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1e54:	00000413          	li	s0,0
  while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
    1e58:	01f00793          	li	a5,31
    1e5c:	1287e663          	bltu	a5,s0,1f88 <_ftoa+0x22c>
    1e60:	00900793          	li	a5,9
    1e64:	1297f263          	bgeu	a5,s1,1f88 <_ftoa+0x22c>
    buf[len++] = '0';
    1e68:	03040793          	addi	a5,s0,48
    1e6c:	02010713          	addi	a4,sp,32
    1e70:	00e787b3          	add	a5,a5,a4
    1e74:	03000713          	li	a4,48
    1e78:	fee78023          	sb	a4,-32(a5) # 7fffffe0 <__freertos_irq_stack_top+0x7fff8f60>
    prec--;
    1e7c:	fff48493          	addi	s1,s1,-1
    buf[len++] = '0';
    1e80:	00140413          	addi	s0,s0,1
    1e84:	fd5ff06f          	j	1e58 <_ftoa+0xfc>
    return _out_rev(out, buffer, idx, maxlen, "nan", 3, width, flags);
    1e88:	000d8893          	mv	a7,s11
    1e8c:	000b0813          	mv	a6,s6
    1e90:	00300793          	li	a5,3
    1e94:	00006737          	lui	a4,0x6
    1e98:	c1c70713          	addi	a4,a4,-996 # 5c1c <_data+0xc>
    1e9c:	000d0693          	mv	a3,s10
    1ea0:	000c8613          	mv	a2,s9
    1ea4:	000c0593          	mv	a1,s8
    1ea8:	000b8513          	mv	a0,s7
    1eac:	c14ff0ef          	jal	12c0 <_out_rev>
    1eb0:	33c0006f          	j	21ec <_ftoa+0x490>
    return _out_rev(out, buffer, idx, maxlen, "fni-", 4, width, flags);
    1eb4:	000d8893          	mv	a7,s11
    1eb8:	000b0813          	mv	a6,s6
    1ebc:	00400793          	li	a5,4
    1ec0:	00006737          	lui	a4,0x6
    1ec4:	c2070713          	addi	a4,a4,-992 # 5c20 <_data+0x10>
    1ec8:	000d0693          	mv	a3,s10
    1ecc:	000c8613          	mv	a2,s9
    1ed0:	000c0593          	mv	a1,s8
    1ed4:	000b8513          	mv	a0,s7
    1ed8:	be8ff0ef          	jal	12c0 <_out_rev>
    1edc:	3100006f          	j	21ec <_ftoa+0x490>
    return _out_rev(out, buffer, idx, maxlen, (flags & FLAGS_PLUS) ? "fni+" : "fni", (flags & FLAGS_PLUS) ? 4U : 3U, width, flags);
    1ee0:	004df793          	andi	a5,s11,4
    1ee4:	02078a63          	beqz	a5,1f18 <_ftoa+0x1bc>
    1ee8:	00006737          	lui	a4,0x6
    1eec:	c1070713          	addi	a4,a4,-1008 # 5c10 <_data>
    1ef0:	02078a63          	beqz	a5,1f24 <_ftoa+0x1c8>
    1ef4:	00400793          	li	a5,4
    1ef8:	000d8893          	mv	a7,s11
    1efc:	000b0813          	mv	a6,s6
    1f00:	000d0693          	mv	a3,s10
    1f04:	000c8613          	mv	a2,s9
    1f08:	000c0593          	mv	a1,s8
    1f0c:	000b8513          	mv	a0,s7
    1f10:	bb0ff0ef          	jal	12c0 <_out_rev>
    1f14:	2d80006f          	j	21ec <_ftoa+0x490>
    1f18:	00006737          	lui	a4,0x6
    1f1c:	c1870713          	addi	a4,a4,-1000 # 5c18 <_data+0x8>
    1f20:	fd1ff06f          	j	1ef0 <_ftoa+0x194>
    1f24:	00300793          	li	a5,3
    1f28:	fd1ff06f          	j	1ef8 <_ftoa+0x19c>
    return _etoa(out, buffer, idx, maxlen, value, prec, width, flags);
    1f2c:	01b12023          	sw	s11,0(sp)
    1f30:	000b0893          	mv	a7,s6
    1f34:	00048813          	mv	a6,s1
    1f38:	000a0713          	mv	a4,s4
    1f3c:	00098793          	mv	a5,s3
    1f40:	000d0693          	mv	a3,s10
    1f44:	000c8613          	mv	a2,s9
    1f48:	000c0593          	mv	a1,s8
    1f4c:	000b8513          	mv	a0,s7
    1f50:	899ff0ef          	jal	17e8 <_etoa>
    1f54:	2980006f          	j	21ec <_ftoa+0x490>
    value = 0 - value;
    1f58:	000a0613          	mv	a2,s4
    1f5c:	00098693          	mv	a3,s3
    1f60:	00000513          	li	a0,0
    1f64:	00000593          	li	a1,0
    1f68:	0a4030ef          	jal	500c <__subdf3>
    1f6c:	00050a13          	mv	s4,a0
    1f70:	00058993          	mv	s3,a1
    negative = true;
    1f74:	00100793          	li	a5,1
    1f78:	02f12223          	sw	a5,36(sp)
    1f7c:	ed1ff06f          	j	1e4c <_ftoa+0xf0>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1f80:	00400493          	li	s1,4
    1f84:	ed1ff06f          	j	1e54 <_ftoa+0xf8>
  int whole = (int)value;
    1f88:	000a0513          	mv	a0,s4
    1f8c:	00098593          	mv	a1,s3
    1f90:	185030ef          	jal	5914 <__fixdfsi>
    1f94:	00050913          	mv	s2,a0
  double tmp = (value - whole) * pow10[prec];
    1f98:	275030ef          	jal	5a0c <__floatsidf>
    1f9c:	00050613          	mv	a2,a0
    1fa0:	00058693          	mv	a3,a1
    1fa4:	000a0513          	mv	a0,s4
    1fa8:	00098593          	mv	a1,s3
    1fac:	060030ef          	jal	500c <__subdf3>
    1fb0:	000067b7          	lui	a5,0x6
    1fb4:	00349713          	slli	a4,s1,0x3
    1fb8:	e3878793          	addi	a5,a5,-456 # 5e38 <pow10.0>
    1fbc:	00e787b3          	add	a5,a5,a4
    1fc0:	0047a803          	lw	a6,4(a5)
    1fc4:	0007a783          	lw	a5,0(a5)
    1fc8:	02f12423          	sw	a5,40(sp)
    1fcc:	03012623          	sw	a6,44(sp)
    1fd0:	00078613          	mv	a2,a5
    1fd4:	00080693          	mv	a3,a6
    1fd8:	15d020ef          	jal	4934 <__muldf3>
    1fdc:	00a12e23          	sw	a0,28(sp)
    1fe0:	02b12023          	sw	a1,32(sp)
  unsigned long frac = (unsigned long)tmp;
    1fe4:	1b5030ef          	jal	5998 <__fixunsdfsi>
    1fe8:	00050a93          	mv	s5,a0
  diff = tmp - frac;
    1fec:	2d9030ef          	jal	5ac4 <__floatunsidf>
    1ff0:	00050613          	mv	a2,a0
    1ff4:	00058693          	mv	a3,a1
    1ff8:	01c12503          	lw	a0,28(sp)
    1ffc:	02012583          	lw	a1,32(sp)
    2000:	00c030ef          	jal	500c <__subdf3>
    2004:	00a12e23          	sw	a0,28(sp)
    2008:	02b12023          	sw	a1,32(sp)
  if (diff > 0.5) {
    200c:	8481a603          	lw	a2,-1976(gp) # 6000 <__clz_tab+0x138>
    2010:	84c1a683          	lw	a3,-1972(gp) # 6004 <__clz_tab+0x13c>
    2014:	718020ef          	jal	472c <__gedf2>
    2018:	06a05863          	blez	a0,2088 <_ftoa+0x32c>
    ++frac;
    201c:	001a8a93          	addi	s5,s5,1
    if (frac >= pow10[prec]) {
    2020:	000a8513          	mv	a0,s5
    2024:	2a1030ef          	jal	5ac4 <__floatunsidf>
    2028:	00050613          	mv	a2,a0
    202c:	00058693          	mv	a3,a1
    2030:	02812503          	lw	a0,40(sp)
    2034:	02c12583          	lw	a1,44(sp)
    2038:	7f4020ef          	jal	482c <__ledf2>
    203c:	00a04663          	bgtz	a0,2048 <_ftoa+0x2ec>
      ++whole;
    2040:	00190913          	addi	s2,s2,1
      frac = 0;
    2044:	00000a93          	li	s5,0
  if (prec == 0U) {
    2048:	06049663          	bnez	s1,20b4 <_ftoa+0x358>
    diff = value - (double)whole;
    204c:	00090513          	mv	a0,s2
    2050:	1bd030ef          	jal	5a0c <__floatsidf>
    2054:	00050613          	mv	a2,a0
    2058:	00058693          	mv	a3,a1
    205c:	000a0513          	mv	a0,s4
    2060:	00098593          	mv	a1,s3
    2064:	7a9020ef          	jal	500c <__subdf3>
    if ((!(diff < 0.5) || (diff > 0.5)) && (whole & 1)) {
    2068:	8481a603          	lw	a2,-1976(gp) # 6000 <__clz_tab+0x138>
    206c:	84c1a683          	lw	a3,-1972(gp) # 6004 <__clz_tab+0x13c>
    2070:	7bc020ef          	jal	482c <__ledf2>
    2074:	0c054c63          	bltz	a0,214c <_ftoa+0x3f0>
    2078:	00197793          	andi	a5,s2,1
    207c:	0c078863          	beqz	a5,214c <_ftoa+0x3f0>
      ++whole;
    2080:	00190913          	addi	s2,s2,1
    2084:	0c80006f          	j	214c <_ftoa+0x3f0>
  else if (diff < 0.5) {
    2088:	8481a603          	lw	a2,-1976(gp) # 6000 <__clz_tab+0x138>
    208c:	84c1a683          	lw	a3,-1972(gp) # 6004 <__clz_tab+0x13c>
    2090:	01c12503          	lw	a0,28(sp)
    2094:	02012583          	lw	a1,32(sp)
    2098:	794020ef          	jal	482c <__ledf2>
    209c:	fa0546e3          	bltz	a0,2048 <_ftoa+0x2ec>
  else if ((frac == 0U) || (frac & 1U)) {
    20a0:	000a8663          	beqz	s5,20ac <_ftoa+0x350>
    20a4:	001af793          	andi	a5,s5,1
    20a8:	fa0780e3          	beqz	a5,2048 <_ftoa+0x2ec>
    ++frac;
    20ac:	001a8a93          	addi	s5,s5,1
    20b0:	f99ff06f          	j	2048 <_ftoa+0x2ec>
    while (len < PRINTF_FTOA_BUFFER_SIZE) {
    20b4:	01f00793          	li	a5,31
    20b8:	0487e263          	bltu	a5,s0,20fc <_ftoa+0x3a0>
      --count;
    20bc:	fff48493          	addi	s1,s1,-1
      buf[len++] = (char)(48U + (frac % 10U));
    20c0:	00a00793          	li	a5,10
    20c4:	02faf733          	remu	a4,s5,a5
    20c8:	00140693          	addi	a3,s0,1
    20cc:	03070713          	addi	a4,a4,48
    20d0:	03040613          	addi	a2,s0,48
    20d4:	02010593          	addi	a1,sp,32
    20d8:	00b60433          	add	s0,a2,a1
    20dc:	fee40023          	sb	a4,-32(s0)
      if (!(frac /= 10U)) {
    20e0:	02fad7b3          	divu	a5,s5,a5
    20e4:	00900713          	li	a4,9
    20e8:	01577863          	bgeu	a4,s5,20f8 <_ftoa+0x39c>
    20ec:	00078a93          	mv	s5,a5
      buf[len++] = (char)(48U + (frac % 10U));
    20f0:	00068413          	mv	s0,a3
    20f4:	fc1ff06f          	j	20b4 <_ftoa+0x358>
    20f8:	00068413          	mv	s0,a3
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
    20fc:	01f00793          	li	a5,31
    2100:	0287e663          	bltu	a5,s0,212c <_ftoa+0x3d0>
    2104:	fff48793          	addi	a5,s1,-1
    2108:	02048263          	beqz	s1,212c <_ftoa+0x3d0>
      buf[len++] = '0';
    210c:	03040713          	addi	a4,s0,48
    2110:	02010693          	addi	a3,sp,32
    2114:	00d70733          	add	a4,a4,a3
    2118:	03000693          	li	a3,48
    211c:	fed70023          	sb	a3,-32(a4)
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
    2120:	00078493          	mv	s1,a5
      buf[len++] = '0';
    2124:	00140413          	addi	s0,s0,1
    2128:	fd5ff06f          	j	20fc <_ftoa+0x3a0>
    if (len < PRINTF_FTOA_BUFFER_SIZE) {
    212c:	01f00793          	li	a5,31
    2130:	0087ee63          	bltu	a5,s0,214c <_ftoa+0x3f0>
      buf[len++] = '.';
    2134:	03040793          	addi	a5,s0,48
    2138:	02010713          	addi	a4,sp,32
    213c:	00e787b3          	add	a5,a5,a4
    2140:	02e00713          	li	a4,46
    2144:	fee78023          	sb	a4,-32(a5)
    2148:	00140413          	addi	s0,s0,1
  while (len < PRINTF_FTOA_BUFFER_SIZE) {
    214c:	01f00793          	li	a5,31
    2150:	0287ec63          	bltu	a5,s0,2188 <_ftoa+0x42c>
    buf[len++] = (char)(48 + (whole % 10));
    2154:	00a00713          	li	a4,10
    2158:	02e967b3          	rem	a5,s2,a4
    215c:	00140693          	addi	a3,s0,1
    2160:	03078793          	addi	a5,a5,48
    2164:	03040613          	addi	a2,s0,48
    2168:	02010593          	addi	a1,sp,32
    216c:	00b60433          	add	s0,a2,a1
    2170:	fef40023          	sb	a5,-32(s0)
    if (!(whole /= 10)) {
    2174:	02e94933          	div	s2,s2,a4
    2178:	00090663          	beqz	s2,2184 <_ftoa+0x428>
    buf[len++] = (char)(48 + (whole % 10));
    217c:	00068413          	mv	s0,a3
    2180:	fcdff06f          	j	214c <_ftoa+0x3f0>
    2184:	00068413          	mv	s0,a3
  if (!(flags & FLAGS_LEFT) && (flags & FLAGS_ZEROPAD)) {
    2188:	003df713          	andi	a4,s11,3
    218c:	00100793          	li	a5,1
    2190:	08f70663          	beq	a4,a5,221c <_ftoa+0x4c0>
  if (len < PRINTF_FTOA_BUFFER_SIZE) {
    2194:	01f00793          	li	a5,31
    2198:	0287e263          	bltu	a5,s0,21bc <_ftoa+0x460>
    if (negative) {
    219c:	02412783          	lw	a5,36(sp)
    21a0:	0c078063          	beqz	a5,2260 <_ftoa+0x504>
      buf[len++] = '-';
    21a4:	03040793          	addi	a5,s0,48
    21a8:	02010713          	addi	a4,sp,32
    21ac:	00e787b3          	add	a5,a5,a4
    21b0:	02d00713          	li	a4,45
    21b4:	fee78023          	sb	a4,-32(a5)
    21b8:	00140413          	addi	s0,s0,1
  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
    21bc:	000d8893          	mv	a7,s11
    21c0:	000b0813          	mv	a6,s6
    21c4:	00040793          	mv	a5,s0
    21c8:	03010713          	addi	a4,sp,48
    21cc:	000d0693          	mv	a3,s10
    21d0:	000c8613          	mv	a2,s9
    21d4:	000c0593          	mv	a1,s8
    21d8:	000b8513          	mv	a0,s7
    21dc:	8e4ff0ef          	jal	12c0 <_out_rev>
    21e0:	08812403          	lw	s0,136(sp)
    21e4:	08012903          	lw	s2,128(sp)
    21e8:	07412a83          	lw	s5,116(sp)
}
    21ec:	08c12083          	lw	ra,140(sp)
    21f0:	08412483          	lw	s1,132(sp)
    21f4:	07c12983          	lw	s3,124(sp)
    21f8:	07812a03          	lw	s4,120(sp)
    21fc:	07012b03          	lw	s6,112(sp)
    2200:	06c12b83          	lw	s7,108(sp)
    2204:	06812c03          	lw	s8,104(sp)
    2208:	06412c83          	lw	s9,100(sp)
    220c:	06012d03          	lw	s10,96(sp)
    2210:	05c12d83          	lw	s11,92(sp)
    2214:	09010113          	addi	sp,sp,144
    2218:	00008067          	ret
    if (width && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
    221c:	020b0a63          	beqz	s6,2250 <_ftoa+0x4f4>
    2220:	02412783          	lw	a5,36(sp)
    2224:	00079663          	bnez	a5,2230 <_ftoa+0x4d4>
    2228:	00cdf793          	andi	a5,s11,12
    222c:	02078263          	beqz	a5,2250 <_ftoa+0x4f4>
      width--;
    2230:	fffb0b13          	addi	s6,s6,-1
    2234:	01c0006f          	j	2250 <_ftoa+0x4f4>
      buf[len++] = '0';
    2238:	03040793          	addi	a5,s0,48
    223c:	02010713          	addi	a4,sp,32
    2240:	00e787b3          	add	a5,a5,a4
    2244:	03000713          	li	a4,48
    2248:	fee78023          	sb	a4,-32(a5)
    224c:	00140413          	addi	s0,s0,1
    while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
    2250:	f56472e3          	bgeu	s0,s6,2194 <_ftoa+0x438>
    2254:	01f00793          	li	a5,31
    2258:	fe87f0e3          	bgeu	a5,s0,2238 <_ftoa+0x4dc>
    225c:	f39ff06f          	j	2194 <_ftoa+0x438>
    else if (flags & FLAGS_PLUS) {
    2260:	004df793          	andi	a5,s11,4
    2264:	02078063          	beqz	a5,2284 <_ftoa+0x528>
      buf[len++] = '+';  // ignore the space if the '+' exists
    2268:	03040793          	addi	a5,s0,48
    226c:	02010713          	addi	a4,sp,32
    2270:	00e787b3          	add	a5,a5,a4
    2274:	02b00713          	li	a4,43
    2278:	fee78023          	sb	a4,-32(a5)
    227c:	00140413          	addi	s0,s0,1
    2280:	f3dff06f          	j	21bc <_ftoa+0x460>
    else if (flags & FLAGS_SPACE) {
    2284:	008df793          	andi	a5,s11,8
    2288:	f2078ae3          	beqz	a5,21bc <_ftoa+0x460>
      buf[len++] = ' ';
    228c:	03040793          	addi	a5,s0,48
    2290:	02010713          	addi	a4,sp,32
    2294:	00e787b3          	add	a5,a5,a4
    2298:	02000713          	li	a4,32
    229c:	fee78023          	sb	a4,-32(a5)
    22a0:	00140413          	addi	s0,s0,1
    22a4:	f19ff06f          	j	21bc <_ftoa+0x460>

000022a8 <_vsnprintf>:
*                 terminating null character), or a negative value if an error
*                 occurred.
*
******************************************************************************/
static int _vsnprintf(out_fct_type out, char* buffer, const size_t maxlen, const char* format, va_list va)
{
    22a8:	fa010113          	addi	sp,sp,-96
    22ac:	04112e23          	sw	ra,92(sp)
    22b0:	04812c23          	sw	s0,88(sp)
    22b4:	04912a23          	sw	s1,84(sp)
    22b8:	05212823          	sw	s2,80(sp)
    22bc:	05312623          	sw	s3,76(sp)
    22c0:	05412423          	sw	s4,72(sp)
    22c4:	05512223          	sw	s5,68(sp)
    22c8:	05612023          	sw	s6,64(sp)
    22cc:	00050a13          	mv	s4,a0
    22d0:	00058993          	mv	s3,a1
    22d4:	00060913          	mv	s2,a2
    22d8:	00d12e23          	sw	a3,28(sp)
    22dc:	00e12c23          	sw	a4,24(sp)
  unsigned int flags, width, precision, n;
  size_t idx = 0U;

  if (!buffer) {
    22e0:	140588e3          	beqz	a1,2c30 <_vsnprintf+0x988>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
          }
        }
        format++;
        break;
    22e4:	00000493          	li	s1,0
  while (*format)
    22e8:	01c12783          	lw	a5,28(sp)
    22ec:	0007c503          	lbu	a0,0(a5)
    22f0:	140506e3          	beqz	a0,2c3c <_vsnprintf+0x994>
    if (*format != '%') {
    22f4:	02500713          	li	a4,37
    22f8:	02e50663          	beq	a0,a4,2324 <_vsnprintf+0x7c>
      out(*format, buffer, idx++, maxlen);
    22fc:	00148413          	addi	s0,s1,1
    2300:	00090693          	mv	a3,s2
    2304:	00048613          	mv	a2,s1
    2308:	00098593          	mv	a1,s3
    230c:	000a00e7          	jalr	s4
      format++;
    2310:	01c12783          	lw	a5,28(sp)
    2314:	00178793          	addi	a5,a5,1
    2318:	00f12e23          	sw	a5,28(sp)
      out(*format, buffer, idx++, maxlen);
    231c:	00040493          	mv	s1,s0
      continue;
    2320:	fc9ff06f          	j	22e8 <_vsnprintf+0x40>
      format++;
    2324:	00178793          	addi	a5,a5,1
    2328:	00f12e23          	sw	a5,28(sp)
    flags = 0U;
    232c:	00000413          	li	s0,0
    2330:	0700006f          	j	23a0 <_vsnprintf+0xf8>
        case '0': flags |= FLAGS_ZEROPAD; format++; n = 1U; break;
    2334:	00146413          	ori	s0,s0,1
    2338:	00170713          	addi	a4,a4,1
    233c:	00e12e23          	sw	a4,28(sp)
    2340:	00100a93          	li	s5,1
    2344:	0580006f          	j	239c <_vsnprintf+0xf4>
        case '-': flags |= FLAGS_LEFT;    format++; n = 1U; break;
    2348:	00246413          	ori	s0,s0,2
    234c:	00170713          	addi	a4,a4,1
    2350:	00e12e23          	sw	a4,28(sp)
    2354:	00100a93          	li	s5,1
    2358:	0440006f          	j	239c <_vsnprintf+0xf4>
        case '+': flags |= FLAGS_PLUS;    format++; n = 1U; break;
    235c:	00446413          	ori	s0,s0,4
    2360:	00170713          	addi	a4,a4,1
    2364:	00e12e23          	sw	a4,28(sp)
    2368:	00100a93          	li	s5,1
    236c:	0300006f          	j	239c <_vsnprintf+0xf4>
        case ' ': flags |= FLAGS_SPACE;   format++; n = 1U; break;
    2370:	00846413          	ori	s0,s0,8
    2374:	00170713          	addi	a4,a4,1
    2378:	00e12e23          	sw	a4,28(sp)
    237c:	00100a93          	li	s5,1
    2380:	01c0006f          	j	239c <_vsnprintf+0xf4>
        case '#': flags |= FLAGS_HASH;    format++; n = 1U; break;
    2384:	01046413          	ori	s0,s0,16
    2388:	00170713          	addi	a4,a4,1
    238c:	00e12e23          	sw	a4,28(sp)
    2390:	00100a93          	li	s5,1
    2394:	0080006f          	j	239c <_vsnprintf+0xf4>
      switch (*format) {
    2398:	00000a93          	li	s5,0
    } while (n);
    239c:	020a8a63          	beqz	s5,23d0 <_vsnprintf+0x128>
      switch (*format) {
    23a0:	01c12703          	lw	a4,28(sp)
    23a4:	00074783          	lbu	a5,0(a4)
    23a8:	fe078793          	addi	a5,a5,-32
    23ac:	0ff7f613          	zext.b	a2,a5
    23b0:	01000693          	li	a3,16
    23b4:	fec6e2e3          	bltu	a3,a2,2398 <_vsnprintf+0xf0>
    23b8:	00261793          	slli	a5,a2,0x2
    23bc:	000066b7          	lui	a3,0x6
    23c0:	c9868693          	addi	a3,a3,-872 # 5c98 <_data+0x88>
    23c4:	00d787b3          	add	a5,a5,a3
    23c8:	0007a783          	lw	a5,0(a5)
    23cc:	00078067          	jr	a5
    if (_is_digit(*format)) {
    23d0:	01c12783          	lw	a5,28(sp)
    23d4:	0007c703          	lbu	a4,0(a5)
  return (ch >= '0') && (ch <= '9');
    23d8:	fd070793          	addi	a5,a4,-48
    23dc:	0ff7f793          	zext.b	a5,a5
    if (_is_digit(*format)) {
    23e0:	00900693          	li	a3,9
    23e4:	04f6f863          	bgeu	a3,a5,2434 <_vsnprintf+0x18c>
    else if (*format == '*') {
    23e8:	02a00793          	li	a5,42
    23ec:	04f70c63          	beq	a4,a5,2444 <_vsnprintf+0x19c>
    width = 0U;
    23f0:	000a8b13          	mv	s6,s5
    if (*format == '.') {
    23f4:	01c12783          	lw	a5,28(sp)
    23f8:	0007c683          	lbu	a3,0(a5)
    23fc:	02e00713          	li	a4,46
    2400:	06e68a63          	beq	a3,a4,2474 <_vsnprintf+0x1cc>
    switch (*format) {
    2404:	01c12703          	lw	a4,28(sp)
    2408:	00074783          	lbu	a5,0(a4)
    240c:	f9878793          	addi	a5,a5,-104
    2410:	0ff7f613          	zext.b	a2,a5
    2414:	01200693          	li	a3,18
    2418:	12c6e663          	bltu	a3,a2,2544 <_vsnprintf+0x29c>
    241c:	00261793          	slli	a5,a2,0x2
    2420:	000066b7          	lui	a3,0x6
    2424:	cdc68693          	addi	a3,a3,-804 # 5cdc <_data+0xcc>
    2428:	00d787b3          	add	a5,a5,a3
    242c:	0007a783          	lw	a5,0(a5)
    2430:	00078067          	jr	a5
      width = _atoi(&format);
    2434:	01c10513          	addi	a0,sp,28
    2438:	e41fe0ef          	jal	1278 <_atoi>
    243c:	00050b13          	mv	s6,a0
    2440:	fb5ff06f          	j	23f4 <_vsnprintf+0x14c>
      const int w = va_arg(va, int);
    2444:	01812783          	lw	a5,24(sp)
    2448:	00478713          	addi	a4,a5,4
    244c:	00e12c23          	sw	a4,24(sp)
    2450:	0007ab03          	lw	s6,0(a5)
      if (w < 0) {
    2454:	000b4a63          	bltz	s6,2468 <_vsnprintf+0x1c0>
      format++;
    2458:	01c12783          	lw	a5,28(sp)
    245c:	00178793          	addi	a5,a5,1
    2460:	00f12e23          	sw	a5,28(sp)
    2464:	f91ff06f          	j	23f4 <_vsnprintf+0x14c>
        flags |= FLAGS_LEFT;    // reverse padding
    2468:	00246413          	ori	s0,s0,2
        width = (unsigned int)-w;
    246c:	41600b33          	neg	s6,s6
    2470:	fe9ff06f          	j	2458 <_vsnprintf+0x1b0>
      flags |= FLAGS_PRECISION;
    2474:	40046413          	ori	s0,s0,1024
      format++;
    2478:	00178713          	addi	a4,a5,1
    247c:	00e12e23          	sw	a4,28(sp)
      if (_is_digit(*format)) {
    2480:	0017c703          	lbu	a4,1(a5)
  return (ch >= '0') && (ch <= '9');
    2484:	fd070793          	addi	a5,a4,-48
    2488:	0ff7f793          	zext.b	a5,a5
      if (_is_digit(*format)) {
    248c:	00900693          	li	a3,9
    2490:	02f6f863          	bgeu	a3,a5,24c0 <_vsnprintf+0x218>
      else if (*format == '*') {
    2494:	02a00793          	li	a5,42
    2498:	f6f716e3          	bne	a4,a5,2404 <_vsnprintf+0x15c>
        const int prec = (int)va_arg(va, int);
    249c:	01812783          	lw	a5,24(sp)
    24a0:	00478713          	addi	a4,a5,4
    24a4:	00e12c23          	sw	a4,24(sp)
    24a8:	0007aa83          	lw	s5,0(a5)
        precision = prec > 0 ? (unsigned int)prec : 0U;
    24ac:	020ac263          	bltz	s5,24d0 <_vsnprintf+0x228>
        format++;
    24b0:	01c12783          	lw	a5,28(sp)
    24b4:	00178793          	addi	a5,a5,1
    24b8:	00f12e23          	sw	a5,28(sp)
    24bc:	f49ff06f          	j	2404 <_vsnprintf+0x15c>
        precision = _atoi(&format);
    24c0:	01c10513          	addi	a0,sp,28
    24c4:	db5fe0ef          	jal	1278 <_atoi>
    24c8:	00050a93          	mv	s5,a0
    24cc:	f39ff06f          	j	2404 <_vsnprintf+0x15c>
        precision = prec > 0 ? (unsigned int)prec : 0U;
    24d0:	00000a93          	li	s5,0
    24d4:	fddff06f          	j	24b0 <_vsnprintf+0x208>
        flags |= FLAGS_LONG;
    24d8:	10046613          	ori	a2,s0,256
        format++;
    24dc:	00170793          	addi	a5,a4,1
    24e0:	00f12e23          	sw	a5,28(sp)
        if (*format == 'l') {
    24e4:	00174683          	lbu	a3,1(a4)
    24e8:	06c00793          	li	a5,108
    24ec:	00f68663          	beq	a3,a5,24f8 <_vsnprintf+0x250>
        flags |= FLAGS_LONG;
    24f0:	00060413          	mv	s0,a2
    24f4:	0500006f          	j	2544 <_vsnprintf+0x29c>
          flags |= FLAGS_LONG_LONG;
    24f8:	30046413          	ori	s0,s0,768
          format++;
    24fc:	00270713          	addi	a4,a4,2
    2500:	00e12e23          	sw	a4,28(sp)
    2504:	0400006f          	j	2544 <_vsnprintf+0x29c>
        flags |= FLAGS_SHORT;
    2508:	08046613          	ori	a2,s0,128
        format++;
    250c:	00170793          	addi	a5,a4,1
    2510:	00f12e23          	sw	a5,28(sp)
        if (*format == 'h') {
    2514:	00174683          	lbu	a3,1(a4)
    2518:	06800793          	li	a5,104
    251c:	00f68663          	beq	a3,a5,2528 <_vsnprintf+0x280>
        flags |= FLAGS_SHORT;
    2520:	00060413          	mv	s0,a2
    2524:	0200006f          	j	2544 <_vsnprintf+0x29c>
          flags |= FLAGS_CHAR;
    2528:	0c046413          	ori	s0,s0,192
          format++;
    252c:	00270713          	addi	a4,a4,2
    2530:	00e12e23          	sw	a4,28(sp)
    2534:	0100006f          	j	2544 <_vsnprintf+0x29c>
        flags |= (sizeof(ptrdiff_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    2538:	10046413          	ori	s0,s0,256
        format++;
    253c:	00170713          	addi	a4,a4,1
    2540:	00e12e23          	sw	a4,28(sp)
    switch (*format) {
    2544:	01c12783          	lw	a5,28(sp)
    2548:	0007c503          	lbu	a0,0(a5)
    254c:	06700793          	li	a5,103
    2550:	04a7ea63          	bltu	a5,a0,25a4 <_vsnprintf+0x2fc>
    2554:	02500793          	li	a5,37
    2558:	6af56863          	bltu	a0,a5,2c08 <_vsnprintf+0x960>
    255c:	fdb50793          	addi	a5,a0,-37
    2560:	0ff7f693          	zext.b	a3,a5
    2564:	04200713          	li	a4,66
    2568:	6ad76063          	bltu	a4,a3,2c08 <_vsnprintf+0x960>
    256c:	00269793          	slli	a5,a3,0x2
    2570:	00006737          	lui	a4,0x6
    2574:	d2870713          	addi	a4,a4,-728 # 5d28 <_data+0x118>
    2578:	00e787b3          	add	a5,a5,a4
    257c:	0007a783          	lw	a5,0(a5)
    2580:	00078067          	jr	a5
        flags |= (sizeof(intmax_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    2584:	20046413          	ori	s0,s0,512
        format++;
    2588:	00170713          	addi	a4,a4,1
    258c:	00e12e23          	sw	a4,28(sp)
        break;
    2590:	fb5ff06f          	j	2544 <_vsnprintf+0x29c>
        flags |= (sizeof(size_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    2594:	10046413          	ori	s0,s0,256
        format++;
    2598:	00170713          	addi	a4,a4,1
    259c:	00e12e23          	sw	a4,28(sp)
        break;
    25a0:	fa5ff06f          	j	2544 <_vsnprintf+0x29c>
    switch (*format) {
    25a4:	07800793          	li	a5,120
    25a8:	66a7e063          	bltu	a5,a0,2c08 <_vsnprintf+0x960>
    25ac:	06900793          	li	a5,105
    25b0:	64f56c63          	bltu	a0,a5,2c08 <_vsnprintf+0x960>
    25b4:	f9750713          	addi	a4,a0,-105
    25b8:	00100793          	li	a5,1
    25bc:	00e797b3          	sll	a5,a5,a4
    25c0:	00009737          	lui	a4,0x9
    25c4:	04170713          	addi	a4,a4,65 # 9041 <__freertos_irq_stack_top+0x1fc1>
    25c8:	00e7f733          	and	a4,a5,a4
    25cc:	04071263          	bnez	a4,2610 <_vsnprintf+0x368>
    25d0:	0807f713          	andi	a4,a5,128
    25d4:	5a071a63          	bnez	a4,2b88 <_vsnprintf+0x8e0>
    25d8:	4007f793          	andi	a5,a5,1024
    25dc:	62078663          	beqz	a5,2c08 <_vsnprintf+0x960>
    25e0:	03712e23          	sw	s7,60(sp)
    25e4:	03812c23          	sw	s8,56(sp)
    25e8:	03912a23          	sw	s9,52(sp)
    25ec:	03a12823          	sw	s10,48(sp)
      }

      case 's' : {
        const char* p = va_arg(va, char*);
    25f0:	01812783          	lw	a5,24(sp)
    25f4:	00478713          	addi	a4,a5,4
    25f8:	00e12c23          	sw	a4,24(sp)
    25fc:	0007ac03          	lw	s8,0(a5)
        unsigned int l = _strnlen_s(p, precision ? precision : (size_t)-1);
    2600:	4c0a9463          	bnez	s5,2ac8 <_vsnprintf+0x820>
    2604:	fff00713          	li	a4,-1
    2608:	000c0793          	mv	a5,s8
    260c:	4880006f          	j	2a94 <_vsnprintf+0x7ec>
        if (*format == 'x' || *format == 'X') {
    2610:	06f00793          	li	a5,111
    2614:	02f50a63          	beq	a0,a5,2648 <_vsnprintf+0x3a0>
    2618:	00a7ee63          	bltu	a5,a0,2634 <_vsnprintf+0x38c>
    261c:	05800793          	li	a5,88
    2620:	0af50c63          	beq	a0,a5,26d8 <_vsnprintf+0x430>
    2624:	06200793          	li	a5,98
    2628:	00f51a63          	bne	a0,a5,263c <_vsnprintf+0x394>
        flags |= FLAGS_SHORT;
    262c:	00200813          	li	a6,2
    2630:	01c0006f          	j	264c <_vsnprintf+0x3a4>
    2634:	07800793          	li	a5,120
    2638:	0af50463          	beq	a0,a5,26e0 <_vsnprintf+0x438>
          flags &= ~FLAGS_HASH;   // no hash for dec format
    263c:	fef47413          	andi	s0,s0,-17
          base = 10U;
    2640:	00a00813          	li	a6,10
    2644:	0080006f          	j	264c <_vsnprintf+0x3a4>
        flags |= FLAGS_SHORT;
    2648:	00800813          	li	a6,8
        if (*format == 'X') {
    264c:	05800793          	li	a5,88
    2650:	08f50c63          	beq	a0,a5,26e8 <_vsnprintf+0x440>
        if ((*format != 'i') && (*format != 'd')) {
    2654:	06900793          	li	a5,105
    2658:	00f50863          	beq	a0,a5,2668 <_vsnprintf+0x3c0>
    265c:	06400793          	li	a5,100
    2660:	00f50463          	beq	a0,a5,2668 <_vsnprintf+0x3c0>
          flags &= ~(FLAGS_PLUS | FLAGS_SPACE);
    2664:	ff347413          	andi	s0,s0,-13
        if (flags & FLAGS_PRECISION) {
    2668:	40047793          	andi	a5,s0,1024
    266c:	00078463          	beqz	a5,2674 <_vsnprintf+0x3cc>
          flags &= ~FLAGS_ZEROPAD;
    2670:	ffe47413          	andi	s0,s0,-2
        if ((*format == 'i') || (*format == 'd')) {
    2674:	06900793          	li	a5,105
    2678:	06f50c63          	beq	a0,a5,26f0 <_vsnprintf+0x448>
    267c:	06400793          	li	a5,100
    2680:	06f50863          	beq	a0,a5,26f0 <_vsnprintf+0x448>
          if (flags & FLAGS_LONG_LONG) {
    2684:	20047793          	andi	a5,s0,512
    2688:	1a079c63          	bnez	a5,2840 <_vsnprintf+0x598>
          else if (flags & FLAGS_LONG) {
    268c:	10047793          	andi	a5,s0,256
    2690:	20079063          	bnez	a5,2890 <_vsnprintf+0x5e8>
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
    2694:	04047793          	andi	a5,s0,64
    2698:	22078a63          	beqz	a5,28cc <_vsnprintf+0x624>
    269c:	01812783          	lw	a5,24(sp)
    26a0:	00478713          	addi	a4,a5,4
    26a4:	00e12c23          	sw	a4,24(sp)
    26a8:	0007c703          	lbu	a4,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, value, false, base, precision, width, flags);
    26ac:	00812223          	sw	s0,4(sp)
    26b0:	01612023          	sw	s6,0(sp)
    26b4:	000a8893          	mv	a7,s5
    26b8:	00000793          	li	a5,0
    26bc:	00090693          	mv	a3,s2
    26c0:	00048613          	mv	a2,s1
    26c4:	00098593          	mv	a1,s3
    26c8:	000a0513          	mv	a0,s4
    26cc:	ec1fe0ef          	jal	158c <_ntoa_long>
    26d0:	00050493          	mv	s1,a0
    26d4:	0780006f          	j	274c <_vsnprintf+0x4a4>
          base = 10U;
    26d8:	01000813          	li	a6,16
    26dc:	f71ff06f          	j	264c <_vsnprintf+0x3a4>
        flags |= FLAGS_SHORT;
    26e0:	01000813          	li	a6,16
    26e4:	f69ff06f          	j	264c <_vsnprintf+0x3a4>
          flags |= FLAGS_UPPERCASE;
    26e8:	02046413          	ori	s0,s0,32
    26ec:	f69ff06f          	j	2654 <_vsnprintf+0x3ac>
          if (flags & FLAGS_LONG_LONG) {
    26f0:	20047793          	andi	a5,s0,512
    26f4:	06079463          	bnez	a5,275c <_vsnprintf+0x4b4>
          else if (flags & FLAGS_LONG) {
    26f8:	10047793          	andi	a5,s0,256
    26fc:	0c079663          	bnez	a5,27c8 <_vsnprintf+0x520>
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
    2700:	04047793          	andi	a5,s0,64
    2704:	10078663          	beqz	a5,2810 <_vsnprintf+0x568>
    2708:	01812783          	lw	a5,24(sp)
    270c:	00478713          	addi	a4,a5,4
    2710:	00e12c23          	sw	a4,24(sp)
    2714:	0007c783          	lbu	a5,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned int)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    2718:	41f7d713          	srai	a4,a5,0x1f
    271c:	00f746b3          	xor	a3,a4,a5
    2720:	00812223          	sw	s0,4(sp)
    2724:	01612023          	sw	s6,0(sp)
    2728:	000a8893          	mv	a7,s5
    272c:	01f7d793          	srli	a5,a5,0x1f
    2730:	40e68733          	sub	a4,a3,a4
    2734:	00090693          	mv	a3,s2
    2738:	00048613          	mv	a2,s1
    273c:	00098593          	mv	a1,s3
    2740:	000a0513          	mv	a0,s4
    2744:	e49fe0ef          	jal	158c <_ntoa_long>
    2748:	00050493          	mv	s1,a0
        format++;
    274c:	01c12783          	lw	a5,28(sp)
    2750:	00178793          	addi	a5,a5,1
    2754:	00f12e23          	sw	a5,28(sp)
        break;
    2758:	b91ff06f          	j	22e8 <_vsnprintf+0x40>
            const long long value = va_arg(va, long long);
    275c:	01812783          	lw	a5,24(sp)
    2760:	00778793          	addi	a5,a5,7
    2764:	ff87f793          	andi	a5,a5,-8
    2768:	00878713          	addi	a4,a5,8
    276c:	00e12c23          	sw	a4,24(sp)
    2770:	0007a703          	lw	a4,0(a5)
    2774:	0047a583          	lw	a1,4(a5)
            idx = _ntoa_long_long(out, buffer, idx, maxlen, (unsigned long long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    2778:	41f5d693          	srai	a3,a1,0x1f
    277c:	00e6c7b3          	xor	a5,a3,a4
    2780:	00b6c633          	xor	a2,a3,a1
    2784:	40d78733          	sub	a4,a5,a3
    2788:	00e7b7b3          	sltu	a5,a5,a4
    278c:	40d606b3          	sub	a3,a2,a3
    2790:	00812623          	sw	s0,12(sp)
    2794:	01612423          	sw	s6,8(sp)
    2798:	01512223          	sw	s5,4(sp)
    279c:	00012023          	sw	zero,0(sp)
    27a0:	00080893          	mv	a7,a6
    27a4:	01f5d813          	srli	a6,a1,0x1f
    27a8:	40f687b3          	sub	a5,a3,a5
    27ac:	00090693          	mv	a3,s2
    27b0:	00048613          	mv	a2,s1
    27b4:	00098593          	mv	a1,s3
    27b8:	000a0513          	mv	a0,s4
    27bc:	e95fe0ef          	jal	1650 <_ntoa_long_long>
    27c0:	00050493          	mv	s1,a0
    27c4:	f89ff06f          	j	274c <_vsnprintf+0x4a4>
            const long value = va_arg(va, long);
    27c8:	01812783          	lw	a5,24(sp)
    27cc:	00478713          	addi	a4,a5,4
    27d0:	00e12c23          	sw	a4,24(sp)
    27d4:	0007a783          	lw	a5,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    27d8:	41f7d713          	srai	a4,a5,0x1f
    27dc:	00f746b3          	xor	a3,a4,a5
    27e0:	00812223          	sw	s0,4(sp)
    27e4:	01612023          	sw	s6,0(sp)
    27e8:	000a8893          	mv	a7,s5
    27ec:	01f7d793          	srli	a5,a5,0x1f
    27f0:	40e68733          	sub	a4,a3,a4
    27f4:	00090693          	mv	a3,s2
    27f8:	00048613          	mv	a2,s1
    27fc:	00098593          	mv	a1,s3
    2800:	000a0513          	mv	a0,s4
    2804:	d89fe0ef          	jal	158c <_ntoa_long>
    2808:	00050493          	mv	s1,a0
    280c:	f41ff06f          	j	274c <_vsnprintf+0x4a4>
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
    2810:	08047793          	andi	a5,s0,128
    2814:	00078c63          	beqz	a5,282c <_vsnprintf+0x584>
    2818:	01812783          	lw	a5,24(sp)
    281c:	00478713          	addi	a4,a5,4
    2820:	00e12c23          	sw	a4,24(sp)
    2824:	00079783          	lh	a5,0(a5)
    2828:	ef1ff06f          	j	2718 <_vsnprintf+0x470>
    282c:	01812783          	lw	a5,24(sp)
    2830:	00478713          	addi	a4,a5,4
    2834:	00e12c23          	sw	a4,24(sp)
    2838:	0007a783          	lw	a5,0(a5)
    283c:	eddff06f          	j	2718 <_vsnprintf+0x470>
            idx = _ntoa_long_long(out, buffer, idx, maxlen, va_arg(va, unsigned long long), false, base, precision, width, flags);
    2840:	01812783          	lw	a5,24(sp)
    2844:	00778793          	addi	a5,a5,7
    2848:	ff87f793          	andi	a5,a5,-8
    284c:	00878713          	addi	a4,a5,8
    2850:	00e12c23          	sw	a4,24(sp)
    2854:	0007a703          	lw	a4,0(a5)
    2858:	0047a783          	lw	a5,4(a5)
    285c:	00812623          	sw	s0,12(sp)
    2860:	01612423          	sw	s6,8(sp)
    2864:	01512223          	sw	s5,4(sp)
    2868:	00012023          	sw	zero,0(sp)
    286c:	00080893          	mv	a7,a6
    2870:	00000813          	li	a6,0
    2874:	00090693          	mv	a3,s2
    2878:	00048613          	mv	a2,s1
    287c:	00098593          	mv	a1,s3
    2880:	000a0513          	mv	a0,s4
    2884:	dcdfe0ef          	jal	1650 <_ntoa_long_long>
    2888:	00050493          	mv	s1,a0
    288c:	ec1ff06f          	j	274c <_vsnprintf+0x4a4>
            idx = _ntoa_long(out, buffer, idx, maxlen, va_arg(va, unsigned long), false, base, precision, width, flags);
    2890:	01812783          	lw	a5,24(sp)
    2894:	00478713          	addi	a4,a5,4
    2898:	00e12c23          	sw	a4,24(sp)
    289c:	0007a703          	lw	a4,0(a5)
    28a0:	00812223          	sw	s0,4(sp)
    28a4:	01612023          	sw	s6,0(sp)
    28a8:	000a8893          	mv	a7,s5
    28ac:	00000793          	li	a5,0
    28b0:	00090693          	mv	a3,s2
    28b4:	00048613          	mv	a2,s1
    28b8:	00098593          	mv	a1,s3
    28bc:	000a0513          	mv	a0,s4
    28c0:	ccdfe0ef          	jal	158c <_ntoa_long>
    28c4:	00050493          	mv	s1,a0
    28c8:	e85ff06f          	j	274c <_vsnprintf+0x4a4>
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
    28cc:	08047793          	andi	a5,s0,128
    28d0:	00078c63          	beqz	a5,28e8 <_vsnprintf+0x640>
    28d4:	01812783          	lw	a5,24(sp)
    28d8:	00478713          	addi	a4,a5,4
    28dc:	00e12c23          	sw	a4,24(sp)
    28e0:	0007d703          	lhu	a4,0(a5)
    28e4:	dc9ff06f          	j	26ac <_vsnprintf+0x404>
    28e8:	01812783          	lw	a5,24(sp)
    28ec:	00478713          	addi	a4,a5,4
    28f0:	00e12c23          	sw	a4,24(sp)
    28f4:	0007a703          	lw	a4,0(a5)
    28f8:	db5ff06f          	j	26ac <_vsnprintf+0x404>
        if (*format == 'F') flags |= FLAGS_UPPERCASE;
    28fc:	04600793          	li	a5,70
    2900:	04f50a63          	beq	a0,a5,2954 <_vsnprintf+0x6ac>
        idx = _ftoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
    2904:	01812783          	lw	a5,24(sp)
    2908:	00778793          	addi	a5,a5,7
    290c:	ff87f793          	andi	a5,a5,-8
    2910:	00878713          	addi	a4,a5,8
    2914:	00e12c23          	sw	a4,24(sp)
    2918:	0007a703          	lw	a4,0(a5)
    291c:	0047a783          	lw	a5,4(a5)
    2920:	00812023          	sw	s0,0(sp)
    2924:	000b0893          	mv	a7,s6
    2928:	000a8813          	mv	a6,s5
    292c:	00090693          	mv	a3,s2
    2930:	00048613          	mv	a2,s1
    2934:	00098593          	mv	a1,s3
    2938:	000a0513          	mv	a0,s4
    293c:	c20ff0ef          	jal	1d5c <_ftoa>
    2940:	00050493          	mv	s1,a0
        format++;
    2944:	01c12783          	lw	a5,28(sp)
    2948:	00178793          	addi	a5,a5,1
    294c:	00f12e23          	sw	a5,28(sp)
        break;
    2950:	999ff06f          	j	22e8 <_vsnprintf+0x40>
        if (*format == 'F') flags |= FLAGS_UPPERCASE;
    2954:	02046413          	ori	s0,s0,32
    2958:	fadff06f          	j	2904 <_vsnprintf+0x65c>
        if ((*format == 'g')||(*format == 'G')) flags |= FLAGS_ADAPT_EXP;
    295c:	06700793          	li	a5,103
    2960:	00f50663          	beq	a0,a5,296c <_vsnprintf+0x6c4>
    2964:	04700793          	li	a5,71
    2968:	00f51863          	bne	a0,a5,2978 <_vsnprintf+0x6d0>
    296c:	000017b7          	lui	a5,0x1
    2970:	80078793          	addi	a5,a5,-2048 # 800 <CUSTOM2+0x7a5>
    2974:	00f46433          	or	s0,s0,a5
        if ((*format == 'E')||(*format == 'G')) flags |= FLAGS_UPPERCASE;
    2978:	04500793          	li	a5,69
    297c:	00f50663          	beq	a0,a5,2988 <_vsnprintf+0x6e0>
    2980:	04700793          	li	a5,71
    2984:	00f51463          	bne	a0,a5,298c <_vsnprintf+0x6e4>
    2988:	02046413          	ori	s0,s0,32
        idx = _etoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
    298c:	01812783          	lw	a5,24(sp)
    2990:	00778793          	addi	a5,a5,7
    2994:	ff87f793          	andi	a5,a5,-8
    2998:	00878713          	addi	a4,a5,8
    299c:	00e12c23          	sw	a4,24(sp)
    29a0:	0007a703          	lw	a4,0(a5)
    29a4:	0047a783          	lw	a5,4(a5)
    29a8:	00812023          	sw	s0,0(sp)
    29ac:	000b0893          	mv	a7,s6
    29b0:	000a8813          	mv	a6,s5
    29b4:	00090693          	mv	a3,s2
    29b8:	00048613          	mv	a2,s1
    29bc:	00098593          	mv	a1,s3
    29c0:	000a0513          	mv	a0,s4
    29c4:	e25fe0ef          	jal	17e8 <_etoa>
    29c8:	00050493          	mv	s1,a0
        format++;
    29cc:	01c12783          	lw	a5,28(sp)
    29d0:	00178793          	addi	a5,a5,1
    29d4:	00f12e23          	sw	a5,28(sp)
        break;
    29d8:	911ff06f          	j	22e8 <_vsnprintf+0x40>
    29dc:	03712e23          	sw	s7,60(sp)
        if (!(flags & FLAGS_LEFT)) {
    29e0:	00247413          	andi	s0,s0,2
    29e4:	06040a63          	beqz	s0,2a58 <_vsnprintf+0x7b0>
        unsigned int l = 1U;
    29e8:	00100a93          	li	s5,1
        out((char)va_arg(va, int), buffer, idx++, maxlen);
    29ec:	01812783          	lw	a5,24(sp)
    29f0:	00478713          	addi	a4,a5,4
    29f4:	00e12c23          	sw	a4,24(sp)
    29f8:	00148b93          	addi	s7,s1,1
    29fc:	00090693          	mv	a3,s2
    2a00:	00048613          	mv	a2,s1
    2a04:	00098593          	mv	a1,s3
    2a08:	0007c503          	lbu	a0,0(a5)
    2a0c:	000a00e7          	jalr	s4
        if (flags & FLAGS_LEFT) {
    2a10:	06041863          	bnez	s0,2a80 <_vsnprintf+0x7d8>
        format++;
    2a14:	01c12783          	lw	a5,28(sp)
    2a18:	00178793          	addi	a5,a5,1
    2a1c:	00f12e23          	sw	a5,28(sp)
        break;
    2a20:	000b8493          	mv	s1,s7
    2a24:	03c12b83          	lw	s7,60(sp)
    2a28:	8c1ff06f          	j	22e8 <_vsnprintf+0x40>
            out(' ', buffer, idx++, maxlen);
    2a2c:	00148b93          	addi	s7,s1,1
    2a30:	00090693          	mv	a3,s2
    2a34:	00048613          	mv	a2,s1
    2a38:	00098593          	mv	a1,s3
    2a3c:	02000513          	li	a0,32
    2a40:	000a00e7          	jalr	s4
          while (l++ < width) {
    2a44:	000a8793          	mv	a5,s5
            out(' ', buffer, idx++, maxlen);
    2a48:	000b8493          	mv	s1,s7
          while (l++ < width) {
    2a4c:	00178a93          	addi	s5,a5,1
    2a50:	fd67eee3          	bltu	a5,s6,2a2c <_vsnprintf+0x784>
    2a54:	f99ff06f          	j	29ec <_vsnprintf+0x744>
        unsigned int l = 1U;
    2a58:	00100793          	li	a5,1
    2a5c:	ff1ff06f          	j	2a4c <_vsnprintf+0x7a4>
            out(' ', buffer, idx++, maxlen);
    2a60:	001b8493          	addi	s1,s7,1
    2a64:	00090693          	mv	a3,s2
    2a68:	000b8613          	mv	a2,s7
    2a6c:	00098593          	mv	a1,s3
    2a70:	02000513          	li	a0,32
    2a74:	000a00e7          	jalr	s4
          while (l++ < width) {
    2a78:	00040a93          	mv	s5,s0
            out(' ', buffer, idx++, maxlen);
    2a7c:	00048b93          	mv	s7,s1
          while (l++ < width) {
    2a80:	001a8413          	addi	s0,s5,1
    2a84:	fd6aeee3          	bltu	s5,s6,2a60 <_vsnprintf+0x7b8>
    2a88:	f8dff06f          	j	2a14 <_vsnprintf+0x76c>
  for (s = str; *s && maxsize--; ++s);
    2a8c:	00178793          	addi	a5,a5,1
    2a90:	00068713          	mv	a4,a3
    2a94:	0007c683          	lbu	a3,0(a5)
    2a98:	00068663          	beqz	a3,2aa4 <_vsnprintf+0x7fc>
    2a9c:	fff70693          	addi	a3,a4,-1
    2aa0:	fe0716e3          	bnez	a4,2a8c <_vsnprintf+0x7e4>
  return (unsigned int)(s - str);
    2aa4:	41878bb3          	sub	s7,a5,s8
        // pre padding
        if (flags & FLAGS_PRECISION) {
    2aa8:	40047c93          	andi	s9,s0,1024
    2aac:	000c8663          	beqz	s9,2ab8 <_vsnprintf+0x810>
          l = (l < precision ? l : precision);
    2ab0:	017af463          	bgeu	s5,s7,2ab8 <_vsnprintf+0x810>
    2ab4:	000a8b93          	mv	s7,s5
        }
        if (!(flags & FLAGS_LEFT)) {
    2ab8:	00247d13          	andi	s10,s0,2
    2abc:	060d1463          	bnez	s10,2b24 <_vsnprintf+0x87c>
    2ac0:	03b12623          	sw	s11,44(sp)
    2ac4:	02c0006f          	j	2af0 <_vsnprintf+0x848>
        unsigned int l = _strnlen_s(p, precision ? precision : (size_t)-1);
    2ac8:	000a8713          	mv	a4,s5
    2acc:	b3dff06f          	j	2608 <_vsnprintf+0x360>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
    2ad0:	00148d93          	addi	s11,s1,1
    2ad4:	00090693          	mv	a3,s2
    2ad8:	00048613          	mv	a2,s1
    2adc:	00098593          	mv	a1,s3
    2ae0:	02000513          	li	a0,32
    2ae4:	000a00e7          	jalr	s4
          while (l++ < width) {
    2ae8:	00040b93          	mv	s7,s0
            out(' ', buffer, idx++, maxlen);
    2aec:	000d8493          	mv	s1,s11
          while (l++ < width) {
    2af0:	001b8413          	addi	s0,s7,1
    2af4:	fd6beee3          	bltu	s7,s6,2ad0 <_vsnprintf+0x828>
    2af8:	00040b93          	mv	s7,s0
    2afc:	02c12d83          	lw	s11,44(sp)
    2b00:	0240006f          	j	2b24 <_vsnprintf+0x87c>
          }
        }
        // string output
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
    2b04:	00078a93          	mv	s5,a5
          out(*(p++), buffer, idx++, maxlen);
    2b08:	001c0c13          	addi	s8,s8,1
    2b0c:	00148413          	addi	s0,s1,1
    2b10:	00090693          	mv	a3,s2
    2b14:	00048613          	mv	a2,s1
    2b18:	00098593          	mv	a1,s3
    2b1c:	000a00e7          	jalr	s4
    2b20:	00040493          	mv	s1,s0
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
    2b24:	000c4503          	lbu	a0,0(s8)
    2b28:	00050863          	beqz	a0,2b38 <_vsnprintf+0x890>
    2b2c:	fc0c8ee3          	beqz	s9,2b08 <_vsnprintf+0x860>
    2b30:	fffa8793          	addi	a5,s5,-1
    2b34:	fc0a98e3          	bnez	s5,2b04 <_vsnprintf+0x85c>
        }
        // post padding
        if (flags & FLAGS_LEFT) {
    2b38:	040d1263          	bnez	s10,2b7c <_vsnprintf+0x8d4>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
          }
        }
        format++;
    2b3c:	01c12783          	lw	a5,28(sp)
    2b40:	00178793          	addi	a5,a5,1
    2b44:	00f12e23          	sw	a5,28(sp)
        break;
    2b48:	03c12b83          	lw	s7,60(sp)
    2b4c:	03812c03          	lw	s8,56(sp)
    2b50:	03412c83          	lw	s9,52(sp)
    2b54:	03012d03          	lw	s10,48(sp)
    2b58:	f90ff06f          	j	22e8 <_vsnprintf+0x40>
            out(' ', buffer, idx++, maxlen);
    2b5c:	00148a93          	addi	s5,s1,1
    2b60:	00090693          	mv	a3,s2
    2b64:	00048613          	mv	a2,s1
    2b68:	00098593          	mv	a1,s3
    2b6c:	02000513          	li	a0,32
    2b70:	000a00e7          	jalr	s4
          while (l++ < width) {
    2b74:	00040b93          	mv	s7,s0
            out(' ', buffer, idx++, maxlen);
    2b78:	000a8493          	mv	s1,s5
          while (l++ < width) {
    2b7c:	001b8413          	addi	s0,s7,1
    2b80:	fd6beee3          	bltu	s7,s6,2b5c <_vsnprintf+0x8b4>
    2b84:	fb9ff06f          	j	2b3c <_vsnprintf+0x894>
      }

      case 'p' : {
        width = sizeof(void*) * 2U;
        flags |= FLAGS_ZEROPAD | FLAGS_UPPERCASE;
    2b88:	02146413          	ori	s0,s0,33
        if (is_ll) {
          idx = _ntoa_long_long(out, buffer, idx, maxlen, (uintptr_t)va_arg(va, void*), false, 16U, precision, width, flags);
        }
        else {
#endif
          idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)((uintptr_t)va_arg(va, void*)), false, 16U, precision, width, flags);
    2b8c:	01812783          	lw	a5,24(sp)
    2b90:	00478713          	addi	a4,a5,4
    2b94:	00e12c23          	sw	a4,24(sp)
    2b98:	0007a703          	lw	a4,0(a5)
    2b9c:	00812223          	sw	s0,4(sp)
    2ba0:	00800793          	li	a5,8
    2ba4:	00f12023          	sw	a5,0(sp)
    2ba8:	000a8893          	mv	a7,s5
    2bac:	01000813          	li	a6,16
    2bb0:	00000793          	li	a5,0
    2bb4:	00090693          	mv	a3,s2
    2bb8:	00048613          	mv	a2,s1
    2bbc:	00098593          	mv	a1,s3
    2bc0:	000a0513          	mv	a0,s4
    2bc4:	9c9fe0ef          	jal	158c <_ntoa_long>
    2bc8:	00050493          	mv	s1,a0
#if defined(PRINTF_SUPPORT_LONG_LONG)
        }
#endif
        format++;
    2bcc:	01c12783          	lw	a5,28(sp)
    2bd0:	00178793          	addi	a5,a5,1
    2bd4:	00f12e23          	sw	a5,28(sp)
        break;
    2bd8:	f10ff06f          	j	22e8 <_vsnprintf+0x40>
      }

      case '%' :
        out('%', buffer, idx++, maxlen);
    2bdc:	00148413          	addi	s0,s1,1
    2be0:	00090693          	mv	a3,s2
    2be4:	00048613          	mv	a2,s1
    2be8:	00098593          	mv	a1,s3
    2bec:	02500513          	li	a0,37
    2bf0:	000a00e7          	jalr	s4
        format++;
    2bf4:	01c12783          	lw	a5,28(sp)
    2bf8:	00178793          	addi	a5,a5,1
    2bfc:	00f12e23          	sw	a5,28(sp)
        out('%', buffer, idx++, maxlen);
    2c00:	00040493          	mv	s1,s0
        break;
    2c04:	ee4ff06f          	j	22e8 <_vsnprintf+0x40>

      default :
        out(*format, buffer, idx++, maxlen);
    2c08:	00148413          	addi	s0,s1,1
    2c0c:	00090693          	mv	a3,s2
    2c10:	00048613          	mv	a2,s1
    2c14:	00098593          	mv	a1,s3
    2c18:	000a00e7          	jalr	s4
        format++;
    2c1c:	01c12783          	lw	a5,28(sp)
    2c20:	00178793          	addi	a5,a5,1
    2c24:	00f12e23          	sw	a5,28(sp)
        out(*format, buffer, idx++, maxlen);
    2c28:	00040493          	mv	s1,s0
        break;
    2c2c:	ebcff06f          	j	22e8 <_vsnprintf+0x40>
    out = _out_null;
    2c30:	00001a37          	lui	s4,0x1
    2c34:	274a0a13          	addi	s4,s4,628 # 1274 <_out_null>
    2c38:	eacff06f          	j	22e4 <_vsnprintf+0x3c>
    }
  }

  // termination
  out((char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
    2c3c:	0524e263          	bltu	s1,s2,2c80 <_vsnprintf+0x9d8>
    2c40:	fff90613          	addi	a2,s2,-1
    2c44:	00090693          	mv	a3,s2
    2c48:	00098593          	mv	a1,s3
    2c4c:	00000513          	li	a0,0
    2c50:	000a00e7          	jalr	s4

  // return written chars without terminating \0
  return (int)idx;
}
    2c54:	00048513          	mv	a0,s1
    2c58:	05c12083          	lw	ra,92(sp)
    2c5c:	05812403          	lw	s0,88(sp)
    2c60:	05412483          	lw	s1,84(sp)
    2c64:	05012903          	lw	s2,80(sp)
    2c68:	04c12983          	lw	s3,76(sp)
    2c6c:	04812a03          	lw	s4,72(sp)
    2c70:	04412a83          	lw	s5,68(sp)
    2c74:	04012b03          	lw	s6,64(sp)
    2c78:	06010113          	addi	sp,sp,96
    2c7c:	00008067          	ret
  out((char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
    2c80:	00048613          	mv	a2,s1
    2c84:	fc1ff06f          	j	2c44 <_vsnprintf+0x99c>

00002c88 <bsp_init>:
    *   1. UART baudrate
    *   2. 
    */
////////////////////////////////////////////////////////////////////////////////
    static void bsp_init()
    {
    2c88:	fe010113          	addi	sp,sp,-32
    2c8c:	00112e23          	sw	ra,28(sp)
        Uart_Config uartConfig;
        uartConfig.dataLength   = BITS_8;
    2c90:	00800793          	li	a5,8
    2c94:	00f12023          	sw	a5,0(sp)
        uartConfig.parity       = NONE;
    2c98:	00012223          	sw	zero,4(sp)
        uartConfig.stop         = ONE;
    2c9c:	00012423          	sw	zero,8(sp)
        uartConfig.clockDivider = BSP_CLINT_HZ/(BSP_UART_BAUDRATE*BSP_UART_DATA_LEN)-1;
    2ca0:	03500793          	li	a5,53
    2ca4:	00f12623          	sw	a5,12(sp)
        uart_applyConfig(BSP_UART_TERMINAL, &uartConfig);    
    2ca8:	00010593          	mv	a1,sp
    2cac:	f8001537          	lui	a0,0xf8001
    2cb0:	d34fe0ef          	jal	11e4 <uart_applyConfig>
    }
    2cb4:	01c12083          	lw	ra,28(sp)
    2cb8:	02010113          	addi	sp,sp,32
    2cbc:	00008067          	ret

00002cc0 <bsp_printf>:
* @param format Format string followed by the arguments to be formatted.
* @param ... Variable arguments corresponding to the format specifiers in 'format'.
*
******************************************************************************/
    static int bsp_printf(const char* format, ...)
    {
    2cc0:	f6010113          	addi	sp,sp,-160
    2cc4:	06112e23          	sw	ra,124(sp)
    2cc8:	06812c23          	sw	s0,120(sp)
    2ccc:	08b12223          	sw	a1,132(sp)
    2cd0:	08c12423          	sw	a2,136(sp)
    2cd4:	08d12623          	sw	a3,140(sp)
    2cd8:	08e12823          	sw	a4,144(sp)
    2cdc:	08f12a23          	sw	a5,148(sp)
    2ce0:	09012c23          	sw	a6,152(sp)
    2ce4:	09112e23          	sw	a7,156(sp)
      va_list va;
      va_start(va, format);
    2ce8:	08410713          	addi	a4,sp,132
    2cec:	06e12623          	sw	a4,108(sp)

      char buffer[MAX_STRING_BUFFER_SIZE];
        const int ret = _vsnprintf(_out_buffer, buffer, (size_t)-1, format, va);
    2cf0:	00050693          	mv	a3,a0
    2cf4:	fff00613          	li	a2,-1
    2cf8:	00810593          	addi	a1,sp,8
    2cfc:	00001537          	lui	a0,0x1
    2d00:	26450513          	addi	a0,a0,612 # 1264 <_out_buffer>
    2d04:	da4ff0ef          	jal	22a8 <_vsnprintf>
    2d08:	00050413          	mv	s0,a0
        _putchar_s(buffer);
    2d0c:	00810513          	addi	a0,sp,8
    2d10:	d3cfe0ef          	jal	124c <_putchar_s>

      va_end(va);
      return ret;
    }
    2d14:	00040513          	mv	a0,s0
    2d18:	07c12083          	lw	ra,124(sp)
    2d1c:	07812403          	lw	s0,120(sp)
    2d20:	0a010113          	addi	sp,sp,160
    2d24:	00008067          	ret

00002d28 <__udivdi3>:
    2d28:	00060813          	mv	a6,a2
    2d2c:	00050893          	mv	a7,a0
    2d30:	00058713          	mv	a4,a1
    2d34:	0e069063          	bnez	a3,2e14 <__udivdi3+0xec>
    2d38:	12c5fe63          	bgeu	a1,a2,2e74 <__udivdi3+0x14c>
    2d3c:	000107b7          	lui	a5,0x10
    2d40:	1ef66e63          	bltu	a2,a5,2f3c <__udivdi3+0x214>
    2d44:	010007b7          	lui	a5,0x1000
    2d48:	01800693          	li	a3,24
    2d4c:	00f67463          	bgeu	a2,a5,2d54 <__udivdi3+0x2c>
    2d50:	01000693          	li	a3,16
    2d54:	00d65333          	srl	t1,a2,a3
    2d58:	00003797          	auipc	a5,0x3
    2d5c:	17078793          	addi	a5,a5,368 # 5ec8 <__clz_tab>
    2d60:	006787b3          	add	a5,a5,t1
    2d64:	0007c783          	lbu	a5,0(a5)
    2d68:	02000313          	li	t1,32
    2d6c:	00d787b3          	add	a5,a5,a3
    2d70:	40f306b3          	sub	a3,t1,a5
    2d74:	00f30c63          	beq	t1,a5,2d8c <__udivdi3+0x64>
    2d78:	00d59733          	sll	a4,a1,a3
    2d7c:	00f557b3          	srl	a5,a0,a5
    2d80:	00d61833          	sll	a6,a2,a3
    2d84:	00e7e733          	or	a4,a5,a4
    2d88:	00d518b3          	sll	a7,a0,a3
    2d8c:	01085613          	srli	a2,a6,0x10
    2d90:	02c75533          	divu	a0,a4,a2
    2d94:	01081693          	slli	a3,a6,0x10
    2d98:	0106d693          	srli	a3,a3,0x10
    2d9c:	0108d793          	srli	a5,a7,0x10
    2da0:	02c77733          	remu	a4,a4,a2
    2da4:	02a685b3          	mul	a1,a3,a0
    2da8:	01071713          	slli	a4,a4,0x10
    2dac:	00e7e7b3          	or	a5,a5,a4
    2db0:	00b7fc63          	bgeu	a5,a1,2dc8 <__udivdi3+0xa0>
    2db4:	00f807b3          	add	a5,a6,a5
    2db8:	fff50713          	addi	a4,a0,-1
    2dbc:	0107e463          	bltu	a5,a6,2dc4 <__udivdi3+0x9c>
    2dc0:	40b7e063          	bltu	a5,a1,31c0 <__udivdi3+0x498>
    2dc4:	00070513          	mv	a0,a4
    2dc8:	40b787b3          	sub	a5,a5,a1
    2dcc:	02c7d733          	divu	a4,a5,a2
    2dd0:	01089893          	slli	a7,a7,0x10
    2dd4:	0108d893          	srli	a7,a7,0x10
    2dd8:	02c7f7b3          	remu	a5,a5,a2
    2ddc:	02e686b3          	mul	a3,a3,a4
    2de0:	01079793          	slli	a5,a5,0x10
    2de4:	00f8e8b3          	or	a7,a7,a5
    2de8:	00d8fe63          	bgeu	a7,a3,2e04 <__udivdi3+0xdc>
    2dec:	011808b3          	add	a7,a6,a7
    2df0:	fff70793          	addi	a5,a4,-1
    2df4:	0108e663          	bltu	a7,a6,2e00 <__udivdi3+0xd8>
    2df8:	ffe70713          	addi	a4,a4,-2
    2dfc:	00d8e463          	bltu	a7,a3,2e04 <__udivdi3+0xdc>
    2e00:	00078713          	mv	a4,a5
    2e04:	01051513          	slli	a0,a0,0x10
    2e08:	00e56533          	or	a0,a0,a4
    2e0c:	00000593          	li	a1,0
    2e10:	00008067          	ret
    2e14:	00d5f863          	bgeu	a1,a3,2e24 <__udivdi3+0xfc>
    2e18:	00000593          	li	a1,0
    2e1c:	00000513          	li	a0,0
    2e20:	00008067          	ret
    2e24:	000107b7          	lui	a5,0x10
    2e28:	1ef6e863          	bltu	a3,a5,3018 <__udivdi3+0x2f0>
    2e2c:	01000737          	lui	a4,0x1000
    2e30:	01800793          	li	a5,24
    2e34:	00e6f463          	bgeu	a3,a4,2e3c <__udivdi3+0x114>
    2e38:	01000793          	li	a5,16
    2e3c:	00f6d833          	srl	a6,a3,a5
    2e40:	00003717          	auipc	a4,0x3
    2e44:	08870713          	addi	a4,a4,136 # 5ec8 <__clz_tab>
    2e48:	01070733          	add	a4,a4,a6
    2e4c:	00074703          	lbu	a4,0(a4)
    2e50:	02000893          	li	a7,32
    2e54:	00f70733          	add	a4,a4,a5
    2e58:	40e88833          	sub	a6,a7,a4
    2e5c:	1ee89663          	bne	a7,a4,3048 <__udivdi3+0x320>
    2e60:	32b6e463          	bltu	a3,a1,3188 <__udivdi3+0x460>
    2e64:	00c53533          	sltu	a0,a0,a2
    2e68:	00153513          	seqz	a0,a0
    2e6c:	00000593          	li	a1,0
    2e70:	00008067          	ret
    2e74:	0c060c63          	beqz	a2,2f4c <__udivdi3+0x224>
    2e78:	000107b7          	lui	a5,0x10
    2e7c:	2ef67c63          	bgeu	a2,a5,3174 <__udivdi3+0x44c>
    2e80:	10063713          	sltiu	a4,a2,256
    2e84:	00173713          	seqz	a4,a4
    2e88:	00371713          	slli	a4,a4,0x3
    2e8c:	00e656b3          	srl	a3,a2,a4
    2e90:	00003797          	auipc	a5,0x3
    2e94:	03878793          	addi	a5,a5,56 # 5ec8 <__clz_tab>
    2e98:	00d787b3          	add	a5,a5,a3
    2e9c:	0007c783          	lbu	a5,0(a5)
    2ea0:	02000693          	li	a3,32
    2ea4:	00e787b3          	add	a5,a5,a4
    2ea8:	40f68eb3          	sub	t4,a3,a5
    2eac:	0cf69463          	bne	a3,a5,2f74 <__udivdi3+0x24c>
    2eb0:	40c587b3          	sub	a5,a1,a2
    2eb4:	01065693          	srli	a3,a2,0x10
    2eb8:	01061613          	slli	a2,a2,0x10
    2ebc:	01065613          	srli	a2,a2,0x10
    2ec0:	00100593          	li	a1,1
    2ec4:	02d7d533          	divu	a0,a5,a3
    2ec8:	0108d713          	srli	a4,a7,0x10
    2ecc:	02d7f7b3          	remu	a5,a5,a3
    2ed0:	02c50333          	mul	t1,a0,a2
    2ed4:	01079793          	slli	a5,a5,0x10
    2ed8:	00f767b3          	or	a5,a4,a5
    2edc:	0067fc63          	bgeu	a5,t1,2ef4 <__udivdi3+0x1cc>
    2ee0:	00f807b3          	add	a5,a6,a5
    2ee4:	fff50713          	addi	a4,a0,-1
    2ee8:	0107e463          	bltu	a5,a6,2ef0 <__udivdi3+0x1c8>
    2eec:	2c67e463          	bltu	a5,t1,31b4 <__udivdi3+0x48c>
    2ef0:	00070513          	mv	a0,a4
    2ef4:	406787b3          	sub	a5,a5,t1
    2ef8:	02d7d733          	divu	a4,a5,a3
    2efc:	01089893          	slli	a7,a7,0x10
    2f00:	0108d893          	srli	a7,a7,0x10
    2f04:	02d7f7b3          	remu	a5,a5,a3
    2f08:	02c70633          	mul	a2,a4,a2
    2f0c:	01079793          	slli	a5,a5,0x10
    2f10:	00f8e8b3          	or	a7,a7,a5
    2f14:	00c8fe63          	bgeu	a7,a2,2f30 <__udivdi3+0x208>
    2f18:	011808b3          	add	a7,a6,a7
    2f1c:	fff70793          	addi	a5,a4,-1
    2f20:	0108e663          	bltu	a7,a6,2f2c <__udivdi3+0x204>
    2f24:	ffe70713          	addi	a4,a4,-2
    2f28:	00c8e463          	bltu	a7,a2,2f30 <__udivdi3+0x208>
    2f2c:	00078713          	mv	a4,a5
    2f30:	01051513          	slli	a0,a0,0x10
    2f34:	00e56533          	or	a0,a0,a4
    2f38:	00008067          	ret
    2f3c:	10063693          	sltiu	a3,a2,256
    2f40:	0016b693          	seqz	a3,a3
    2f44:	00369693          	slli	a3,a3,0x3
    2f48:	e0dff06f          	j	2d54 <__udivdi3+0x2c>
    2f4c:	00000693          	li	a3,0
    2f50:	00003797          	auipc	a5,0x3
    2f54:	f7878793          	addi	a5,a5,-136 # 5ec8 <__clz_tab>
    2f58:	00d787b3          	add	a5,a5,a3
    2f5c:	0007c783          	lbu	a5,0(a5)
    2f60:	00000713          	li	a4,0
    2f64:	02000693          	li	a3,32
    2f68:	00e787b3          	add	a5,a5,a4
    2f6c:	40f68eb3          	sub	t4,a3,a5
    2f70:	f4f680e3          	beq	a3,a5,2eb0 <__udivdi3+0x188>
    2f74:	01d61833          	sll	a6,a2,t4
    2f78:	00f5d333          	srl	t1,a1,a5
    2f7c:	01085693          	srli	a3,a6,0x10
    2f80:	02d35e33          	divu	t3,t1,a3
    2f84:	01081613          	slli	a2,a6,0x10
    2f88:	01d595b3          	sll	a1,a1,t4
    2f8c:	01065613          	srli	a2,a2,0x10
    2f90:	00f557b3          	srl	a5,a0,a5
    2f94:	00b7e7b3          	or	a5,a5,a1
    2f98:	0107d713          	srli	a4,a5,0x10
    2f9c:	01d518b3          	sll	a7,a0,t4
    2fa0:	02d37333          	remu	t1,t1,a3
    2fa4:	03c605b3          	mul	a1,a2,t3
    2fa8:	01031313          	slli	t1,t1,0x10
    2fac:	00676733          	or	a4,a4,t1
    2fb0:	00b77e63          	bgeu	a4,a1,2fcc <__udivdi3+0x2a4>
    2fb4:	00e80733          	add	a4,a6,a4
    2fb8:	fffe0513          	addi	a0,t3,-1
    2fbc:	1f076463          	bltu	a4,a6,31a4 <__udivdi3+0x47c>
    2fc0:	1eb77263          	bgeu	a4,a1,31a4 <__udivdi3+0x47c>
    2fc4:	ffee0e13          	addi	t3,t3,-2
    2fc8:	01070733          	add	a4,a4,a6
    2fcc:	40b70733          	sub	a4,a4,a1
    2fd0:	02d75533          	divu	a0,a4,a3
    2fd4:	01079793          	slli	a5,a5,0x10
    2fd8:	0107d793          	srli	a5,a5,0x10
    2fdc:	02d77733          	remu	a4,a4,a3
    2fe0:	02a60333          	mul	t1,a2,a0
    2fe4:	01071713          	slli	a4,a4,0x10
    2fe8:	00e7e7b3          	or	a5,a5,a4
    2fec:	0067fe63          	bgeu	a5,t1,3008 <__udivdi3+0x2e0>
    2ff0:	00f807b3          	add	a5,a6,a5
    2ff4:	fff50713          	addi	a4,a0,-1
    2ff8:	1907ee63          	bltu	a5,a6,3194 <__udivdi3+0x46c>
    2ffc:	1867fc63          	bgeu	a5,t1,3194 <__udivdi3+0x46c>
    3000:	ffe50513          	addi	a0,a0,-2
    3004:	010787b3          	add	a5,a5,a6
    3008:	010e1593          	slli	a1,t3,0x10
    300c:	406787b3          	sub	a5,a5,t1
    3010:	00a5e5b3          	or	a1,a1,a0
    3014:	eb1ff06f          	j	2ec4 <__udivdi3+0x19c>
    3018:	1006b793          	sltiu	a5,a3,256
    301c:	0017b793          	seqz	a5,a5
    3020:	00379793          	slli	a5,a5,0x3
    3024:	00f6d833          	srl	a6,a3,a5
    3028:	00003717          	auipc	a4,0x3
    302c:	ea070713          	addi	a4,a4,-352 # 5ec8 <__clz_tab>
    3030:	01070733          	add	a4,a4,a6
    3034:	00074703          	lbu	a4,0(a4)
    3038:	02000893          	li	a7,32
    303c:	00f70733          	add	a4,a4,a5
    3040:	40e88833          	sub	a6,a7,a4
    3044:	e0e88ee3          	beq	a7,a4,2e60 <__udivdi3+0x138>
    3048:	00e65e33          	srl	t3,a2,a4
    304c:	010696b3          	sll	a3,a3,a6
    3050:	00de6e33          	or	t3,t3,a3
    3054:	00e5d8b3          	srl	a7,a1,a4
    3058:	010e5e93          	srli	t4,t3,0x10
    305c:	03d8d7b3          	divu	a5,a7,t4
    3060:	010e1313          	slli	t1,t3,0x10
    3064:	010595b3          	sll	a1,a1,a6
    3068:	01035313          	srli	t1,t1,0x10
    306c:	00e55733          	srl	a4,a0,a4
    3070:	00b76733          	or	a4,a4,a1
    3074:	01075693          	srli	a3,a4,0x10
    3078:	01061633          	sll	a2,a2,a6
    307c:	03d8f8b3          	remu	a7,a7,t4
    3080:	02f305b3          	mul	a1,t1,a5
    3084:	01089893          	slli	a7,a7,0x10
    3088:	0116e6b3          	or	a3,a3,a7
    308c:	00b6fe63          	bgeu	a3,a1,30a8 <__udivdi3+0x380>
    3090:	00de06b3          	add	a3,t3,a3
    3094:	fff78893          	addi	a7,a5,-1
    3098:	11c6ea63          	bltu	a3,t3,31ac <__udivdi3+0x484>
    309c:	10b6f863          	bgeu	a3,a1,31ac <__udivdi3+0x484>
    30a0:	ffe78793          	addi	a5,a5,-2
    30a4:	01c686b3          	add	a3,a3,t3
    30a8:	40b686b3          	sub	a3,a3,a1
    30ac:	03d6d5b3          	divu	a1,a3,t4
    30b0:	01071713          	slli	a4,a4,0x10
    30b4:	01075713          	srli	a4,a4,0x10
    30b8:	03d6f6b3          	remu	a3,a3,t4
    30bc:	02b308b3          	mul	a7,t1,a1
    30c0:	01069693          	slli	a3,a3,0x10
    30c4:	00d76733          	or	a4,a4,a3
    30c8:	01177e63          	bgeu	a4,a7,30e4 <__udivdi3+0x3bc>
    30cc:	00ee0733          	add	a4,t3,a4
    30d0:	fff58693          	addi	a3,a1,-1
    30d4:	0dc76463          	bltu	a4,t3,319c <__udivdi3+0x474>
    30d8:	0d177263          	bgeu	a4,a7,319c <__udivdi3+0x474>
    30dc:	ffe58593          	addi	a1,a1,-2
    30e0:	01c70733          	add	a4,a4,t3
    30e4:	01079793          	slli	a5,a5,0x10
    30e8:	00010eb7          	lui	t4,0x10
    30ec:	00b7e7b3          	or	a5,a5,a1
    30f0:	fffe8693          	addi	a3,t4,-1 # ffff <__freertos_irq_stack_top+0x8f7f>
    30f4:	00d7f5b3          	and	a1,a5,a3
    30f8:	0107d313          	srli	t1,a5,0x10
    30fc:	00d676b3          	and	a3,a2,a3
    3100:	01065613          	srli	a2,a2,0x10
    3104:	02d58e33          	mul	t3,a1,a3
    3108:	41170733          	sub	a4,a4,a7
    310c:	02d306b3          	mul	a3,t1,a3
    3110:	010e5893          	srli	a7,t3,0x10
    3114:	02c585b3          	mul	a1,a1,a2
    3118:	00d585b3          	add	a1,a1,a3
    311c:	00b885b3          	add	a1,a7,a1
    3120:	02c30333          	mul	t1,t1,a2
    3124:	00d5f463          	bgeu	a1,a3,312c <__udivdi3+0x404>
    3128:	01d30333          	add	t1,t1,t4
    312c:	0105d693          	srli	a3,a1,0x10
    3130:	006686b3          	add	a3,a3,t1
    3134:	02d76a63          	bltu	a4,a3,3168 <__udivdi3+0x440>
    3138:	00d70863          	beq	a4,a3,3148 <__udivdi3+0x420>
    313c:	00078513          	mv	a0,a5
    3140:	00000593          	li	a1,0
    3144:	00008067          	ret
    3148:	000106b7          	lui	a3,0x10
    314c:	fff68693          	addi	a3,a3,-1 # ffff <__freertos_irq_stack_top+0x8f7f>
    3150:	00d5f733          	and	a4,a1,a3
    3154:	01071713          	slli	a4,a4,0x10
    3158:	00de7e33          	and	t3,t3,a3
    315c:	01051533          	sll	a0,a0,a6
    3160:	01c70733          	add	a4,a4,t3
    3164:	fce57ce3          	bgeu	a0,a4,313c <__udivdi3+0x414>
    3168:	fff78513          	addi	a0,a5,-1
    316c:	00000593          	li	a1,0
    3170:	00008067          	ret
    3174:	010007b7          	lui	a5,0x1000
    3178:	04f67a63          	bgeu	a2,a5,31cc <__udivdi3+0x4a4>
    317c:	01065693          	srli	a3,a2,0x10
    3180:	01000713          	li	a4,16
    3184:	d0dff06f          	j	2e90 <__udivdi3+0x168>
    3188:	00000593          	li	a1,0
    318c:	00100513          	li	a0,1
    3190:	00008067          	ret
    3194:	00070513          	mv	a0,a4
    3198:	e71ff06f          	j	3008 <__udivdi3+0x2e0>
    319c:	00068593          	mv	a1,a3
    31a0:	f45ff06f          	j	30e4 <__udivdi3+0x3bc>
    31a4:	00050e13          	mv	t3,a0
    31a8:	e25ff06f          	j	2fcc <__udivdi3+0x2a4>
    31ac:	00088793          	mv	a5,a7
    31b0:	ef9ff06f          	j	30a8 <__udivdi3+0x380>
    31b4:	ffe50513          	addi	a0,a0,-2
    31b8:	010787b3          	add	a5,a5,a6
    31bc:	d39ff06f          	j	2ef4 <__udivdi3+0x1cc>
    31c0:	ffe50513          	addi	a0,a0,-2
    31c4:	010787b3          	add	a5,a5,a6
    31c8:	c01ff06f          	j	2dc8 <__udivdi3+0xa0>
    31cc:	01865693          	srli	a3,a2,0x18
    31d0:	01800713          	li	a4,24
    31d4:	cbdff06f          	j	2e90 <__udivdi3+0x168>

000031d8 <__umoddi3>:
    31d8:	00060813          	mv	a6,a2
    31dc:	00050893          	mv	a7,a0
    31e0:	00058793          	mv	a5,a1
    31e4:	00058713          	mv	a4,a1
    31e8:	0c069863          	bnez	a3,32b8 <__umoddi3+0xe0>
    31ec:	12c5fa63          	bgeu	a1,a2,3320 <__umoddi3+0x148>
    31f0:	000107b7          	lui	a5,0x10
    31f4:	1cf66c63          	bltu	a2,a5,33cc <__umoddi3+0x1f4>
    31f8:	010007b7          	lui	a5,0x1000
    31fc:	01800693          	li	a3,24
    3200:	00f67463          	bgeu	a2,a5,3208 <__umoddi3+0x30>
    3204:	01000693          	li	a3,16
    3208:	00d65333          	srl	t1,a2,a3
    320c:	00003797          	auipc	a5,0x3
    3210:	cbc78793          	addi	a5,a5,-836 # 5ec8 <__clz_tab>
    3214:	006787b3          	add	a5,a5,t1
    3218:	0007c783          	lbu	a5,0(a5)
    321c:	02000313          	li	t1,32
    3220:	00d787b3          	add	a5,a5,a3
    3224:	40f306b3          	sub	a3,t1,a5
    3228:	00f30c63          	beq	t1,a5,3240 <__umoddi3+0x68>
    322c:	00d59733          	sll	a4,a1,a3
    3230:	00f557b3          	srl	a5,a0,a5
    3234:	00d61833          	sll	a6,a2,a3
    3238:	00e7e733          	or	a4,a5,a4
    323c:	00d518b3          	sll	a7,a0,a3
    3240:	01085593          	srli	a1,a6,0x10
    3244:	02b75633          	divu	a2,a4,a1
    3248:	01081313          	slli	t1,a6,0x10
    324c:	01035313          	srli	t1,t1,0x10
    3250:	0108d793          	srli	a5,a7,0x10
    3254:	02b77733          	remu	a4,a4,a1
    3258:	02660633          	mul	a2,a2,t1
    325c:	01071713          	slli	a4,a4,0x10
    3260:	00e7e7b3          	or	a5,a5,a4
    3264:	00c7f863          	bgeu	a5,a2,3274 <__umoddi3+0x9c>
    3268:	00f807b3          	add	a5,a6,a5
    326c:	0107e463          	bltu	a5,a6,3274 <__umoddi3+0x9c>
    3270:	3cc7e263          	bltu	a5,a2,3634 <__umoddi3+0x45c>
    3274:	40c787b3          	sub	a5,a5,a2
    3278:	02b7d733          	divu	a4,a5,a1
    327c:	01089513          	slli	a0,a7,0x10
    3280:	01055513          	srli	a0,a0,0x10
    3284:	02b7f7b3          	remu	a5,a5,a1
    3288:	02670733          	mul	a4,a4,t1
    328c:	01079793          	slli	a5,a5,0x10
    3290:	00f56533          	or	a0,a0,a5
    3294:	00e57a63          	bgeu	a0,a4,32a8 <__umoddi3+0xd0>
    3298:	00a80533          	add	a0,a6,a0
    329c:	01056663          	bltu	a0,a6,32a8 <__umoddi3+0xd0>
    32a0:	00e57463          	bgeu	a0,a4,32a8 <__umoddi3+0xd0>
    32a4:	01050533          	add	a0,a0,a6
    32a8:	40e50533          	sub	a0,a0,a4
    32ac:	00d55533          	srl	a0,a0,a3
    32b0:	00000593          	li	a1,0
    32b4:	00008067          	ret
    32b8:	00d5f463          	bgeu	a1,a3,32c0 <__umoddi3+0xe8>
    32bc:	00008067          	ret
    32c0:	00010737          	lui	a4,0x10
    32c4:	1ce6e663          	bltu	a3,a4,3490 <__umoddi3+0x2b8>
    32c8:	01000737          	lui	a4,0x1000
    32cc:	01800813          	li	a6,24
    32d0:	00e6f463          	bgeu	a3,a4,32d8 <__umoddi3+0x100>
    32d4:	01000813          	li	a6,16
    32d8:	0106d333          	srl	t1,a3,a6
    32dc:	00003717          	auipc	a4,0x3
    32e0:	bec70713          	addi	a4,a4,-1044 # 5ec8 <__clz_tab>
    32e4:	00670733          	add	a4,a4,t1
    32e8:	00074703          	lbu	a4,0(a4)
    32ec:	02000313          	li	t1,32
    32f0:	01070733          	add	a4,a4,a6
    32f4:	40e30833          	sub	a6,t1,a4
    32f8:	1ce31463          	bne	t1,a4,34c0 <__umoddi3+0x2e8>
    32fc:	00b6e463          	bltu	a3,a1,3304 <__umoddi3+0x12c>
    3300:	00c56a63          	bltu	a0,a2,3314 <__umoddi3+0x13c>
    3304:	40c508b3          	sub	a7,a0,a2
    3308:	40d586b3          	sub	a3,a1,a3
    330c:	011537b3          	sltu	a5,a0,a7
    3310:	40f687b3          	sub	a5,a3,a5
    3314:	00088513          	mv	a0,a7
    3318:	00078593          	mv	a1,a5
    331c:	00008067          	ret
    3320:	0a060e63          	beqz	a2,33dc <__umoddi3+0x204>
    3324:	000107b7          	lui	a5,0x10
    3328:	2ef67463          	bgeu	a2,a5,3610 <__umoddi3+0x438>
    332c:	10063713          	sltiu	a4,a2,256
    3330:	00173713          	seqz	a4,a4
    3334:	00371713          	slli	a4,a4,0x3
    3338:	00e656b3          	srl	a3,a2,a4
    333c:	00003797          	auipc	a5,0x3
    3340:	b8c78793          	addi	a5,a5,-1140 # 5ec8 <__clz_tab>
    3344:	00d787b3          	add	a5,a5,a3
    3348:	0007c783          	lbu	a5,0(a5)
    334c:	02000313          	li	t1,32
    3350:	00e787b3          	add	a5,a5,a4
    3354:	40f306b3          	sub	a3,t1,a5
    3358:	0af31663          	bne	t1,a5,3404 <__umoddi3+0x22c>
    335c:	40c58733          	sub	a4,a1,a2
    3360:	01065313          	srli	t1,a2,0x10
    3364:	01061613          	slli	a2,a2,0x10
    3368:	01065613          	srli	a2,a2,0x10
    336c:	026755b3          	divu	a1,a4,t1
    3370:	0108d793          	srli	a5,a7,0x10
    3374:	02677733          	remu	a4,a4,t1
    3378:	02c585b3          	mul	a1,a1,a2
    337c:	01071713          	slli	a4,a4,0x10
    3380:	00e7e7b3          	or	a5,a5,a4
    3384:	00b7fa63          	bgeu	a5,a1,3398 <__umoddi3+0x1c0>
    3388:	00f807b3          	add	a5,a6,a5
    338c:	0107e663          	bltu	a5,a6,3398 <__umoddi3+0x1c0>
    3390:	00b7f463          	bgeu	a5,a1,3398 <__umoddi3+0x1c0>
    3394:	010787b3          	add	a5,a5,a6
    3398:	40b787b3          	sub	a5,a5,a1
    339c:	0267d733          	divu	a4,a5,t1
    33a0:	01089893          	slli	a7,a7,0x10
    33a4:	0108d893          	srli	a7,a7,0x10
    33a8:	0267f7b3          	remu	a5,a5,t1
    33ac:	02c70733          	mul	a4,a4,a2
    33b0:	01079513          	slli	a0,a5,0x10
    33b4:	00a8e533          	or	a0,a7,a0
    33b8:	eee560e3          	bltu	a0,a4,3298 <__umoddi3+0xc0>
    33bc:	40e50533          	sub	a0,a0,a4
    33c0:	00d55533          	srl	a0,a0,a3
    33c4:	00000593          	li	a1,0
    33c8:	00008067          	ret
    33cc:	10063693          	sltiu	a3,a2,256
    33d0:	0016b693          	seqz	a3,a3
    33d4:	00369693          	slli	a3,a3,0x3
    33d8:	e31ff06f          	j	3208 <__umoddi3+0x30>
    33dc:	00000693          	li	a3,0
    33e0:	00003797          	auipc	a5,0x3
    33e4:	ae878793          	addi	a5,a5,-1304 # 5ec8 <__clz_tab>
    33e8:	00d787b3          	add	a5,a5,a3
    33ec:	0007c783          	lbu	a5,0(a5)
    33f0:	00000713          	li	a4,0
    33f4:	02000313          	li	t1,32
    33f8:	00e787b3          	add	a5,a5,a4
    33fc:	40f306b3          	sub	a3,t1,a5
    3400:	f4f30ee3          	beq	t1,a5,335c <__umoddi3+0x184>
    3404:	00d61833          	sll	a6,a2,a3
    3408:	00f5de33          	srl	t3,a1,a5
    340c:	01085313          	srli	t1,a6,0x10
    3410:	026e5eb3          	divu	t4,t3,t1
    3414:	01081613          	slli	a2,a6,0x10
    3418:	00d595b3          	sll	a1,a1,a3
    341c:	00f55733          	srl	a4,a0,a5
    3420:	01065613          	srli	a2,a2,0x10
    3424:	00b76733          	or	a4,a4,a1
    3428:	01075793          	srli	a5,a4,0x10
    342c:	00d518b3          	sll	a7,a0,a3
    3430:	026e7e33          	remu	t3,t3,t1
    3434:	02ce85b3          	mul	a1,t4,a2
    3438:	010e1e13          	slli	t3,t3,0x10
    343c:	01c7e7b3          	or	a5,a5,t3
    3440:	00b7fa63          	bgeu	a5,a1,3454 <__umoddi3+0x27c>
    3444:	00f807b3          	add	a5,a6,a5
    3448:	0107e663          	bltu	a5,a6,3454 <__umoddi3+0x27c>
    344c:	00b7f463          	bgeu	a5,a1,3454 <__umoddi3+0x27c>
    3450:	010787b3          	add	a5,a5,a6
    3454:	40b787b3          	sub	a5,a5,a1
    3458:	0267d5b3          	divu	a1,a5,t1
    345c:	01071713          	slli	a4,a4,0x10
    3460:	01075713          	srli	a4,a4,0x10
    3464:	0267f7b3          	remu	a5,a5,t1
    3468:	02c585b3          	mul	a1,a1,a2
    346c:	01079793          	slli	a5,a5,0x10
    3470:	00f76733          	or	a4,a4,a5
    3474:	00b77a63          	bgeu	a4,a1,3488 <__umoddi3+0x2b0>
    3478:	00e80733          	add	a4,a6,a4
    347c:	01076663          	bltu	a4,a6,3488 <__umoddi3+0x2b0>
    3480:	00b77463          	bgeu	a4,a1,3488 <__umoddi3+0x2b0>
    3484:	01070733          	add	a4,a4,a6
    3488:	40b70733          	sub	a4,a4,a1
    348c:	ee1ff06f          	j	336c <__umoddi3+0x194>
    3490:	1006b813          	sltiu	a6,a3,256
    3494:	00183813          	seqz	a6,a6
    3498:	00381813          	slli	a6,a6,0x3
    349c:	0106d333          	srl	t1,a3,a6
    34a0:	00003717          	auipc	a4,0x3
    34a4:	a2870713          	addi	a4,a4,-1496 # 5ec8 <__clz_tab>
    34a8:	00670733          	add	a4,a4,t1
    34ac:	00074703          	lbu	a4,0(a4)
    34b0:	02000313          	li	t1,32
    34b4:	01070733          	add	a4,a4,a6
    34b8:	40e30833          	sub	a6,t1,a4
    34bc:	e4e300e3          	beq	t1,a4,32fc <__umoddi3+0x124>
    34c0:	010696b3          	sll	a3,a3,a6
    34c4:	00e658b3          	srl	a7,a2,a4
    34c8:	00d8e8b3          	or	a7,a7,a3
    34cc:	00e5de33          	srl	t3,a1,a4
    34d0:	0108df13          	srli	t5,a7,0x10
    34d4:	03ee57b3          	divu	a5,t3,t5
    34d8:	01089e93          	slli	t4,a7,0x10
    34dc:	010ede93          	srli	t4,t4,0x10
    34e0:	00e556b3          	srl	a3,a0,a4
    34e4:	01051333          	sll	t1,a0,a6
    34e8:	010595b3          	sll	a1,a1,a6
    34ec:	00b6e5b3          	or	a1,a3,a1
    34f0:	0105d693          	srli	a3,a1,0x10
    34f4:	01061633          	sll	a2,a2,a6
    34f8:	03ee7e33          	remu	t3,t3,t5
    34fc:	02fe8533          	mul	a0,t4,a5
    3500:	010e1e13          	slli	t3,t3,0x10
    3504:	01c6e6b3          	or	a3,a3,t3
    3508:	00a6fe63          	bgeu	a3,a0,3524 <__umoddi3+0x34c>
    350c:	00d886b3          	add	a3,a7,a3
    3510:	fff78e13          	addi	t3,a5,-1
    3514:	1116ec63          	bltu	a3,a7,362c <__umoddi3+0x454>
    3518:	10a6fa63          	bgeu	a3,a0,362c <__umoddi3+0x454>
    351c:	ffe78793          	addi	a5,a5,-2
    3520:	011686b3          	add	a3,a3,a7
    3524:	40a686b3          	sub	a3,a3,a0
    3528:	03e6d533          	divu	a0,a3,t5
    352c:	01059593          	slli	a1,a1,0x10
    3530:	0105d593          	srli	a1,a1,0x10
    3534:	03e6f6b3          	remu	a3,a3,t5
    3538:	02ae8eb3          	mul	t4,t4,a0
    353c:	01069693          	slli	a3,a3,0x10
    3540:	00d5e5b3          	or	a1,a1,a3
    3544:	01d5fe63          	bgeu	a1,t4,3560 <__umoddi3+0x388>
    3548:	00b885b3          	add	a1,a7,a1
    354c:	fff50693          	addi	a3,a0,-1
    3550:	0d15ea63          	bltu	a1,a7,3624 <__umoddi3+0x44c>
    3554:	0dd5f863          	bgeu	a1,t4,3624 <__umoddi3+0x44c>
    3558:	ffe50513          	addi	a0,a0,-2
    355c:	011585b3          	add	a1,a1,a7
    3560:	01079693          	slli	a3,a5,0x10
    3564:	000102b7          	lui	t0,0x10
    3568:	00a6e6b3          	or	a3,a3,a0
    356c:	fff28513          	addi	a0,t0,-1 # ffff <__freertos_irq_stack_top+0x8f7f>
    3570:	00a6fe33          	and	t3,a3,a0
    3574:	01065f93          	srli	t6,a2,0x10
    3578:	0106d693          	srli	a3,a3,0x10
    357c:	00a67533          	and	a0,a2,a0
    3580:	02ae0f33          	mul	t5,t3,a0
    3584:	41d585b3          	sub	a1,a1,t4
    3588:	02a68533          	mul	a0,a3,a0
    358c:	010f5793          	srli	a5,t5,0x10
    3590:	03fe0e33          	mul	t3,t3,t6
    3594:	00ae0e33          	add	t3,t3,a0
    3598:	01c787b3          	add	a5,a5,t3
    359c:	03f686b3          	mul	a3,a3,t6
    35a0:	00a7f463          	bgeu	a5,a0,35a8 <__umoddi3+0x3d0>
    35a4:	005686b3          	add	a3,a3,t0
    35a8:	00010eb7          	lui	t4,0x10
    35ac:	fffe8e93          	addi	t4,t4,-1 # ffff <__freertos_irq_stack_top+0x8f7f>
    35b0:	01d7f533          	and	a0,a5,t4
    35b4:	0107de13          	srli	t3,a5,0x10
    35b8:	01051513          	slli	a0,a0,0x10
    35bc:	01df7f33          	and	t5,t5,t4
    35c0:	00de07b3          	add	a5,t3,a3
    35c4:	01e50533          	add	a0,a0,t5
    35c8:	02f5e863          	bltu	a1,a5,35f8 <__umoddi3+0x420>
    35cc:	02f58463          	beq	a1,a5,35f4 <__umoddi3+0x41c>
    35d0:	40a30533          	sub	a0,t1,a0
    35d4:	00a33333          	sltu	t1,t1,a0
    35d8:	40f585b3          	sub	a1,a1,a5
    35dc:	406585b3          	sub	a1,a1,t1
    35e0:	00e59733          	sll	a4,a1,a4
    35e4:	01055533          	srl	a0,a0,a6
    35e8:	00a76533          	or	a0,a4,a0
    35ec:	0105d5b3          	srl	a1,a1,a6
    35f0:	00008067          	ret
    35f4:	fca37ee3          	bgeu	t1,a0,35d0 <__umoddi3+0x3f8>
    35f8:	40c50633          	sub	a2,a0,a2
    35fc:	00c53533          	sltu	a0,a0,a2
    3600:	011508b3          	add	a7,a0,a7
    3604:	411787b3          	sub	a5,a5,a7
    3608:	00060513          	mv	a0,a2
    360c:	fc5ff06f          	j	35d0 <__umoddi3+0x3f8>
    3610:	010007b7          	lui	a5,0x1000
    3614:	02f67463          	bgeu	a2,a5,363c <__umoddi3+0x464>
    3618:	01065693          	srli	a3,a2,0x10
    361c:	01000713          	li	a4,16
    3620:	d1dff06f          	j	333c <__umoddi3+0x164>
    3624:	00068513          	mv	a0,a3
    3628:	f39ff06f          	j	3560 <__umoddi3+0x388>
    362c:	000e0793          	mv	a5,t3
    3630:	ef5ff06f          	j	3524 <__umoddi3+0x34c>
    3634:	010787b3          	add	a5,a5,a6
    3638:	c3dff06f          	j	3274 <__umoddi3+0x9c>
    363c:	01865693          	srli	a3,a2,0x18
    3640:	01800713          	li	a4,24
    3644:	cf9ff06f          	j	333c <__umoddi3+0x164>

00003648 <__adddf3>:
    3648:	001007b7          	lui	a5,0x100
    364c:	fe010113          	addi	sp,sp,-32
    3650:	fff78e93          	addi	t4,a5,-1 # fffff <__freertos_irq_stack_top+0xf8f7f>
    3654:	00bef833          	and	a6,t4,a1
    3658:	00def7b3          	and	a5,t4,a3
    365c:	0146d313          	srli	t1,a3,0x14
    3660:	01212823          	sw	s2,16(sp)
    3664:	0145d913          	srli	s2,a1,0x14
    3668:	00379793          	slli	a5,a5,0x3
    366c:	00812c23          	sw	s0,24(sp)
    3670:	00381813          	slli	a6,a6,0x3
    3674:	01f5d413          	srli	s0,a1,0x1f
    3678:	01d55713          	srli	a4,a0,0x1d
    367c:	01d65893          	srli	a7,a2,0x1d
    3680:	7ff97913          	andi	s2,s2,2047
    3684:	7ff37313          	andi	t1,t1,2047
    3688:	00112e23          	sw	ra,28(sp)
    368c:	00912a23          	sw	s1,20(sp)
    3690:	01312623          	sw	s3,12(sp)
    3694:	01f6d693          	srli	a3,a3,0x1f
    3698:	00f8e8b3          	or	a7,a7,a5
    369c:	01076733          	or	a4,a4,a6
    36a0:	00351593          	slli	a1,a0,0x3
    36a4:	00361f13          	slli	t5,a2,0x3
    36a8:	406907b3          	sub	a5,s2,t1
    36ac:	1ed40463          	beq	s0,a3,3894 <__adddf3+0x24c>
    36b0:	16f05263          	blez	a5,3814 <__adddf3+0x1cc>
    36b4:	28030663          	beqz	t1,3940 <__adddf3+0x2f8>
    36b8:	7ff00693          	li	a3,2047
    36bc:	42d90663          	beq	s2,a3,3ae8 <__adddf3+0x4a0>
    36c0:	03800693          	li	a3,56
    36c4:	00100613          	li	a2,1
    36c8:	02f6ce63          	blt	a3,a5,3704 <__adddf3+0xbc>
    36cc:	008006b7          	lui	a3,0x800
    36d0:	00d8e8b3          	or	a7,a7,a3
    36d4:	01f00693          	li	a3,31
    36d8:	52f6ce63          	blt	a3,a5,3c14 <__adddf3+0x5cc>
    36dc:	02000693          	li	a3,32
    36e0:	40f686b3          	sub	a3,a3,a5
    36e4:	00d89633          	sll	a2,a7,a3
    36e8:	00ff5533          	srl	a0,t5,a5
    36ec:	00df16b3          	sll	a3,t5,a3
    36f0:	00a66633          	or	a2,a2,a0
    36f4:	00d036b3          	snez	a3,a3
    36f8:	00f8d8b3          	srl	a7,a7,a5
    36fc:	00d66633          	or	a2,a2,a3
    3700:	41170733          	sub	a4,a4,a7
    3704:	40c58633          	sub	a2,a1,a2
    3708:	00c5b5b3          	sltu	a1,a1,a2
    370c:	00060493          	mv	s1,a2
    3710:	40b709b3          	sub	s3,a4,a1
    3714:	00899793          	slli	a5,s3,0x8
    3718:	3207da63          	bgez	a5,3a4c <__adddf3+0x404>
    371c:	008007b7          	lui	a5,0x800
    3720:	fff78793          	addi	a5,a5,-1 # 7fffff <__freertos_irq_stack_top+0x7f8f7f>
    3724:	00f9f9b3          	and	s3,s3,a5
    3728:	2c098863          	beqz	s3,39f8 <__adddf3+0x3b0>
    372c:	00098513          	mv	a0,s3
    3730:	458020ef          	jal	5b88 <__clzsi2>
    3734:	ff850793          	addi	a5,a0,-8
    3738:	02000693          	li	a3,32
    373c:	40f68733          	sub	a4,a3,a5
    3740:	00e4d733          	srl	a4,s1,a4
    3744:	00f999b3          	sll	s3,s3,a5
    3748:	01376733          	or	a4,a4,s3
    374c:	00f494b3          	sll	s1,s1,a5
    3750:	4b27c863          	blt	a5,s2,3c00 <__adddf3+0x5b8>
    3754:	412787b3          	sub	a5,a5,s2
    3758:	00178793          	addi	a5,a5,1
    375c:	40f686b3          	sub	a3,a3,a5
    3760:	00d49633          	sll	a2,s1,a3
    3764:	00f4d9b3          	srl	s3,s1,a5
    3768:	00c03633          	snez	a2,a2
    376c:	01366633          	or	a2,a2,s3
    3770:	00d716b3          	sll	a3,a4,a3
    3774:	00c6e4b3          	or	s1,a3,a2
    3778:	00f759b3          	srl	s3,a4,a5
    377c:	00000913          	li	s2,0
    3780:	0074f793          	andi	a5,s1,7
    3784:	02078063          	beqz	a5,37a4 <__adddf3+0x15c>
    3788:	00f4f793          	andi	a5,s1,15
    378c:	00400713          	li	a4,4
    3790:	00e78a63          	beq	a5,a4,37a4 <__adddf3+0x15c>
    3794:	00448793          	addi	a5,s1,4
    3798:	0097b633          	sltu	a2,a5,s1
    379c:	00c989b3          	add	s3,s3,a2
    37a0:	00078493          	mv	s1,a5
    37a4:	00899793          	slli	a5,s3,0x8
    37a8:	6e07da63          	bgez	a5,3e9c <__adddf3+0x854>
    37ac:	00190793          	addi	a5,s2,1
    37b0:	7ff00713          	li	a4,2047
    37b4:	00040e13          	mv	t3,s0
    37b8:	2ae78663          	beq	a5,a4,3a64 <__adddf3+0x41c>
    37bc:	ff800737          	lui	a4,0xff800
    37c0:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8f7f>
    37c4:	00e9f733          	and	a4,s3,a4
    37c8:	7ff7f793          	andi	a5,a5,2047
    37cc:	01d71813          	slli	a6,a4,0x1d
    37d0:	0034d613          	srli	a2,s1,0x3
    37d4:	00971713          	slli	a4,a4,0x9
    37d8:	00c86833          	or	a6,a6,a2
    37dc:	00c75713          	srli	a4,a4,0xc
    37e0:	01c12083          	lw	ra,28(sp)
    37e4:	01812403          	lw	s0,24(sp)
    37e8:	01479793          	slli	a5,a5,0x14
    37ec:	00e7e7b3          	or	a5,a5,a4
    37f0:	01fe1713          	slli	a4,t3,0x1f
    37f4:	00e7e7b3          	or	a5,a5,a4
    37f8:	01412483          	lw	s1,20(sp)
    37fc:	01012903          	lw	s2,16(sp)
    3800:	00c12983          	lw	s3,12(sp)
    3804:	00080513          	mv	a0,a6
    3808:	00078593          	mv	a1,a5
    380c:	02010113          	addi	sp,sp,32
    3810:	00008067          	ret
    3814:	14078c63          	beqz	a5,396c <__adddf3+0x324>
    3818:	412307b3          	sub	a5,t1,s2
    381c:	3c091263          	bnez	s2,3be0 <__adddf3+0x598>
    3820:	00b76533          	or	a0,a4,a1
    3824:	4c050463          	beqz	a0,3cec <__adddf3+0x6a4>
    3828:	fff78513          	addi	a0,a5,-1
    382c:	60050263          	beqz	a0,3e30 <__adddf3+0x7e8>
    3830:	7ff00813          	li	a6,2047
    3834:	57078663          	beq	a5,a6,3da0 <__adddf3+0x758>
    3838:	03800793          	li	a5,56
    383c:	00100613          	li	a2,1
    3840:	02a7cc63          	blt	a5,a0,3878 <__adddf3+0x230>
    3844:	00050793          	mv	a5,a0
    3848:	01f00613          	li	a2,31
    384c:	56f64c63          	blt	a2,a5,3dc4 <__adddf3+0x77c>
    3850:	02000513          	li	a0,32
    3854:	40f50533          	sub	a0,a0,a5
    3858:	00a71633          	sll	a2,a4,a0
    385c:	00f5d833          	srl	a6,a1,a5
    3860:	00a59533          	sll	a0,a1,a0
    3864:	01066633          	or	a2,a2,a6
    3868:	00a03533          	snez	a0,a0
    386c:	00f75733          	srl	a4,a4,a5
    3870:	00a66633          	or	a2,a2,a0
    3874:	40e888b3          	sub	a7,a7,a4
    3878:	40cf0633          	sub	a2,t5,a2
    387c:	00cf3733          	sltu	a4,t5,a2
    3880:	00060493          	mv	s1,a2
    3884:	40e889b3          	sub	s3,a7,a4
    3888:	00030913          	mv	s2,t1
    388c:	00068413          	mv	s0,a3
    3890:	e85ff06f          	j	3714 <__adddf3+0xcc>
    3894:	1ef05063          	blez	a5,3a74 <__adddf3+0x42c>
    3898:	14031063          	bnez	t1,39d8 <__adddf3+0x390>
    389c:	01e8e6b3          	or	a3,a7,t5
    38a0:	26068c63          	beqz	a3,3b18 <__adddf3+0x4d0>
    38a4:	fff78693          	addi	a3,a5,-1
    38a8:	48068063          	beqz	a3,3d28 <__adddf3+0x6e0>
    38ac:	7ff00613          	li	a2,2047
    38b0:	22c78c63          	beq	a5,a2,3ae8 <__adddf3+0x4a0>
    38b4:	03800793          	li	a5,56
    38b8:	00100993          	li	s3,1
    38bc:	02d7cc63          	blt	a5,a3,38f4 <__adddf3+0x2ac>
    38c0:	00068793          	mv	a5,a3
    38c4:	01f00693          	li	a3,31
    38c8:	4af6c063          	blt	a3,a5,3d68 <__adddf3+0x720>
    38cc:	02000693          	li	a3,32
    38d0:	40f686b3          	sub	a3,a3,a5
    38d4:	00d899b3          	sll	s3,a7,a3
    38d8:	00ff5633          	srl	a2,t5,a5
    38dc:	00df16b3          	sll	a3,t5,a3
    38e0:	00c9e9b3          	or	s3,s3,a2
    38e4:	00d036b3          	snez	a3,a3
    38e8:	00f8d8b3          	srl	a7,a7,a5
    38ec:	00d9e9b3          	or	s3,s3,a3
    38f0:	01170733          	add	a4,a4,a7
    38f4:	00b985b3          	add	a1,s3,a1
    38f8:	0135b9b3          	sltu	s3,a1,s3
    38fc:	00058493          	mv	s1,a1
    3900:	00e989b3          	add	s3,s3,a4
    3904:	00899793          	slli	a5,s3,0x8
    3908:	1407d263          	bgez	a5,3a4c <__adddf3+0x404>
    390c:	00190913          	addi	s2,s2,1
    3910:	7ff00793          	li	a5,2047
    3914:	36f90c63          	beq	s2,a5,3c8c <__adddf3+0x644>
    3918:	ff8007b7          	lui	a5,0xff800
    391c:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8f7f>
    3920:	0014f613          	andi	a2,s1,1
    3924:	00f9f7b3          	and	a5,s3,a5
    3928:	0014d713          	srli	a4,s1,0x1
    392c:	00c76733          	or	a4,a4,a2
    3930:	01f79613          	slli	a2,a5,0x1f
    3934:	00e664b3          	or	s1,a2,a4
    3938:	0017d993          	srli	s3,a5,0x1
    393c:	e45ff06f          	j	3780 <__adddf3+0x138>
    3940:	01e8e6b3          	or	a3,a7,t5
    3944:	1c068a63          	beqz	a3,3b18 <__adddf3+0x4d0>
    3948:	fff78693          	addi	a3,a5,-1
    394c:	40068063          	beqz	a3,3d4c <__adddf3+0x704>
    3950:	7ff00613          	li	a2,2047
    3954:	18c78a63          	beq	a5,a2,3ae8 <__adddf3+0x4a0>
    3958:	03800793          	li	a5,56
    395c:	00100613          	li	a2,1
    3960:	dad7c2e3          	blt	a5,a3,3704 <__adddf3+0xbc>
    3964:	00068793          	mv	a5,a3
    3968:	d6dff06f          	j	36d4 <__adddf3+0x8c>
    396c:	00190813          	addi	a6,s2,1
    3970:	7fe87813          	andi	a6,a6,2046
    3974:	22081c63          	bnez	a6,3bac <__adddf3+0x564>
    3978:	00b76333          	or	t1,a4,a1
    397c:	01e8e833          	or	a6,a7,t5
    3980:	38091063          	bnez	s2,3d00 <__adddf3+0x6b8>
    3984:	46030e63          	beqz	t1,3e00 <__adddf3+0x7b8>
    3988:	40080663          	beqz	a6,3d94 <__adddf3+0x74c>
    398c:	41e589b3          	sub	s3,a1,t5
    3990:	0135b533          	sltu	a0,a1,s3
    3994:	41170633          	sub	a2,a4,a7
    3998:	40a60633          	sub	a2,a2,a0
    399c:	00861513          	slli	a0,a2,0x8
    39a0:	50055e63          	bgez	a0,3ebc <__adddf3+0x874>
    39a4:	40bf05b3          	sub	a1,t5,a1
    39a8:	40e88733          	sub	a4,a7,a4
    39ac:	00bf3f33          	sltu	t5,t5,a1
    39b0:	41e70733          	sub	a4,a4,t5
    39b4:	00871613          	slli	a2,a4,0x8
    39b8:	00058493          	mv	s1,a1
    39bc:	52065e63          	bgez	a2,3ef8 <__adddf3+0x8b0>
    39c0:	ff8007b7          	lui	a5,0xff800
    39c4:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8f7f>
    39c8:	00f77733          	and	a4,a4,a5
    39cc:	00068e13          	mv	t3,a3
    39d0:	00100793          	li	a5,1
    39d4:	df9ff06f          	j	37cc <__adddf3+0x184>
    39d8:	7ff00693          	li	a3,2047
    39dc:	10d90663          	beq	s2,a3,3ae8 <__adddf3+0x4a0>
    39e0:	03800693          	li	a3,56
    39e4:	00100993          	li	s3,1
    39e8:	f0f6c6e3          	blt	a3,a5,38f4 <__adddf3+0x2ac>
    39ec:	008006b7          	lui	a3,0x800
    39f0:	00d8e8b3          	or	a7,a7,a3
    39f4:	ed1ff06f          	j	38c4 <__adddf3+0x27c>
    39f8:	00048513          	mv	a0,s1
    39fc:	18c020ef          	jal	5b88 <__clzsi2>
    3a00:	01850793          	addi	a5,a0,24
    3a04:	01f00693          	li	a3,31
    3a08:	d2f6d8e3          	bge	a3,a5,3738 <__adddf3+0xf0>
    3a0c:	ff850713          	addi	a4,a0,-8
    3a10:	00e49733          	sll	a4,s1,a4
    3a14:	2327c663          	blt	a5,s2,3c40 <__adddf3+0x5f8>
    3a18:	41278933          	sub	s2,a5,s2
    3a1c:	00190793          	addi	a5,s2,1
    3a20:	48f6d663          	bge	a3,a5,3eac <__adddf3+0x864>
    3a24:	fe190913          	addi	s2,s2,-31
    3a28:	02000693          	li	a3,32
    3a2c:	012754b3          	srl	s1,a4,s2
    3a30:	00d78c63          	beq	a5,a3,3a48 <__adddf3+0x400>
    3a34:	04000693          	li	a3,64
    3a38:	40f687b3          	sub	a5,a3,a5
    3a3c:	00f71733          	sll	a4,a4,a5
    3a40:	00e03733          	snez	a4,a4
    3a44:	00e4e4b3          	or	s1,s1,a4
    3a48:	00000913          	li	s2,0
    3a4c:	0074f793          	andi	a5,s1,7
    3a50:	d2079ce3          	bnez	a5,3788 <__adddf3+0x140>
    3a54:	00090793          	mv	a5,s2
    3a58:	0034d613          	srli	a2,s1,0x3
    3a5c:	00098713          	mv	a4,s3
    3a60:	0c00006f          	j	3b20 <__adddf3+0x4d8>
    3a64:	7ff00793          	li	a5,2047
    3a68:	00000713          	li	a4,0
    3a6c:	00000813          	li	a6,0
    3a70:	d71ff06f          	j	37e0 <__adddf3+0x198>
    3a74:	0c078a63          	beqz	a5,3b48 <__adddf3+0x500>
    3a78:	412307b3          	sub	a5,t1,s2
    3a7c:	1e090263          	beqz	s2,3c60 <__adddf3+0x618>
    3a80:	7ff00693          	li	a3,2047
    3a84:	32d30863          	beq	t1,a3,3db4 <__adddf3+0x76c>
    3a88:	03800693          	li	a3,56
    3a8c:	00100993          	li	s3,1
    3a90:	02f6ce63          	blt	a3,a5,3acc <__adddf3+0x484>
    3a94:	008006b7          	lui	a3,0x800
    3a98:	00d76733          	or	a4,a4,a3
    3a9c:	01f00693          	li	a3,31
    3aa0:	3cf6c863          	blt	a3,a5,3e70 <__adddf3+0x828>
    3aa4:	02000693          	li	a3,32
    3aa8:	40f686b3          	sub	a3,a3,a5
    3aac:	00d719b3          	sll	s3,a4,a3
    3ab0:	00f5d633          	srl	a2,a1,a5
    3ab4:	00d596b3          	sll	a3,a1,a3
    3ab8:	00c9e9b3          	or	s3,s3,a2
    3abc:	00d036b3          	snez	a3,a3
    3ac0:	00f75733          	srl	a4,a4,a5
    3ac4:	00d9e9b3          	or	s3,s3,a3
    3ac8:	00e888b3          	add	a7,a7,a4
    3acc:	01e98733          	add	a4,s3,t5
    3ad0:	013739b3          	sltu	s3,a4,s3
    3ad4:	00070493          	mv	s1,a4
    3ad8:	011989b3          	add	s3,s3,a7
    3adc:	00030913          	mv	s2,t1
    3ae0:	e25ff06f          	j	3904 <__adddf3+0x2bc>
    3ae4:	02081063          	bnez	a6,3b04 <__adddf3+0x4bc>
    3ae8:	00351613          	slli	a2,a0,0x3
    3aec:	00365613          	srli	a2,a2,0x3
    3af0:	01d71813          	slli	a6,a4,0x1d
    3af4:	00c86833          	or	a6,a6,a2
    3af8:	00375713          	srli	a4,a4,0x3
    3afc:	01076733          	or	a4,a4,a6
    3b00:	18070663          	beqz	a4,3c8c <__adddf3+0x644>
    3b04:	00000e13          	li	t3,0
    3b08:	7ff00793          	li	a5,2047
    3b0c:	00080737          	lui	a4,0x80
    3b10:	00000813          	li	a6,0
    3b14:	ccdff06f          	j	37e0 <__adddf3+0x198>
    3b18:	00351613          	slli	a2,a0,0x3
    3b1c:	00365613          	srli	a2,a2,0x3
    3b20:	01d71813          	slli	a6,a4,0x1d
    3b24:	7ff00693          	li	a3,2047
    3b28:	00c86833          	or	a6,a6,a2
    3b2c:	00375713          	srli	a4,a4,0x3
    3b30:	fcd786e3          	beq	a5,a3,3afc <__adddf3+0x4b4>
    3b34:	00c71713          	slli	a4,a4,0xc
    3b38:	00c75713          	srli	a4,a4,0xc
    3b3c:	7ff7f793          	andi	a5,a5,2047
    3b40:	00040e13          	mv	t3,s0
    3b44:	c9dff06f          	j	37e0 <__adddf3+0x198>
    3b48:	00190693          	addi	a3,s2,1
    3b4c:	7fe6f813          	andi	a6,a3,2046
    3b50:	14081863          	bnez	a6,3ca0 <__adddf3+0x658>
    3b54:	00b766b3          	or	a3,a4,a1
    3b58:	28091c63          	bnez	s2,3df0 <__adddf3+0x7a8>
    3b5c:	30068263          	beqz	a3,3e60 <__adddf3+0x818>
    3b60:	01e8e6b3          	or	a3,a7,t5
    3b64:	22068863          	beqz	a3,3d94 <__adddf3+0x74c>
    3b68:	01e587b3          	add	a5,a1,t5
    3b6c:	00b7b5b3          	sltu	a1,a5,a1
    3b70:	01170733          	add	a4,a4,a7
    3b74:	00b70733          	add	a4,a4,a1
    3b78:	0037d813          	srli	a6,a5,0x3
    3b7c:	00871793          	slli	a5,a4,0x8
    3b80:	00040e13          	mv	t3,s0
    3b84:	3407de63          	bgez	a5,3ee0 <__adddf3+0x898>
    3b88:	ff8007b7          	lui	a5,0xff800
    3b8c:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8f7f>
    3b90:	00f77733          	and	a4,a4,a5
    3b94:	01d71793          	slli	a5,a4,0x1d
    3b98:	00375713          	srli	a4,a4,0x3
    3b9c:	0107e833          	or	a6,a5,a6
    3ba0:	01d77733          	and	a4,a4,t4
    3ba4:	00100793          	li	a5,1
    3ba8:	c39ff06f          	j	37e0 <__adddf3+0x198>
    3bac:	41e58833          	sub	a6,a1,t5
    3bb0:	0105b7b3          	sltu	a5,a1,a6
    3bb4:	411709b3          	sub	s3,a4,a7
    3bb8:	40f989b3          	sub	s3,s3,a5
    3bbc:	00899793          	slli	a5,s3,0x8
    3bc0:	00080493          	mv	s1,a6
    3bc4:	1007c663          	bltz	a5,3cd0 <__adddf3+0x688>
    3bc8:	01386833          	or	a6,a6,s3
    3bcc:	b4081ee3          	bnez	a6,3728 <__adddf3+0xe0>
    3bd0:	00000e13          	li	t3,0
    3bd4:	00000793          	li	a5,0
    3bd8:	00000713          	li	a4,0
    3bdc:	c05ff06f          	j	37e0 <__adddf3+0x198>
    3be0:	7ff00513          	li	a0,2047
    3be4:	1aa30e63          	beq	t1,a0,3da0 <__adddf3+0x758>
    3be8:	03800513          	li	a0,56
    3bec:	00100613          	li	a2,1
    3bf0:	c8f544e3          	blt	a0,a5,3878 <__adddf3+0x230>
    3bf4:	00800637          	lui	a2,0x800
    3bf8:	00c76733          	or	a4,a4,a2
    3bfc:	c4dff06f          	j	3848 <__adddf3+0x200>
    3c00:	ff8009b7          	lui	s3,0xff800
    3c04:	fff98993          	addi	s3,s3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8f7f>
    3c08:	40f90933          	sub	s2,s2,a5
    3c0c:	013779b3          	and	s3,a4,s3
    3c10:	b71ff06f          	j	3780 <__adddf3+0x138>
    3c14:	fe078693          	addi	a3,a5,-32
    3c18:	02000613          	li	a2,32
    3c1c:	00d8d6b3          	srl	a3,a7,a3
    3c20:	00c78a63          	beq	a5,a2,3c34 <__adddf3+0x5ec>
    3c24:	04000613          	li	a2,64
    3c28:	40f607b3          	sub	a5,a2,a5
    3c2c:	00f897b3          	sll	a5,a7,a5
    3c30:	00ff6f33          	or	t5,t5,a5
    3c34:	01e03633          	snez	a2,t5
    3c38:	00d66633          	or	a2,a2,a3
    3c3c:	ac9ff06f          	j	3704 <__adddf3+0xbc>
    3c40:	ff8006b7          	lui	a3,0xff800
    3c44:	fff68693          	addi	a3,a3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8f7f>
    3c48:	40f907b3          	sub	a5,s2,a5
    3c4c:	00d77733          	and	a4,a4,a3
    3c50:	01d71813          	slli	a6,a4,0x1d
    3c54:	01386833          	or	a6,a6,s3
    3c58:	00375713          	srli	a4,a4,0x3
    3c5c:	ed9ff06f          	j	3b34 <__adddf3+0x4ec>
    3c60:	00b766b3          	or	a3,a4,a1
    3c64:	1e068663          	beqz	a3,3e50 <__adddf3+0x808>
    3c68:	fff78693          	addi	a3,a5,-1
    3c6c:	0a068e63          	beqz	a3,3d28 <__adddf3+0x6e0>
    3c70:	7ff00513          	li	a0,2047
    3c74:	14a78063          	beq	a5,a0,3db4 <__adddf3+0x76c>
    3c78:	03800793          	li	a5,56
    3c7c:	00100993          	li	s3,1
    3c80:	e4d7c6e3          	blt	a5,a3,3acc <__adddf3+0x484>
    3c84:	00068793          	mv	a5,a3
    3c88:	e15ff06f          	j	3a9c <__adddf3+0x454>
    3c8c:	00040e13          	mv	t3,s0
    3c90:	7ff00793          	li	a5,2047
    3c94:	00000713          	li	a4,0
    3c98:	00000813          	li	a6,0
    3c9c:	b45ff06f          	j	37e0 <__adddf3+0x198>
    3ca0:	7ff00793          	li	a5,2047
    3ca4:	fef684e3          	beq	a3,a5,3c8c <__adddf3+0x644>
    3ca8:	01e58f33          	add	t5,a1,t5
    3cac:	00bf35b3          	sltu	a1,t5,a1
    3cb0:	011707b3          	add	a5,a4,a7
    3cb4:	00b787b3          	add	a5,a5,a1
    3cb8:	01f79613          	slli	a2,a5,0x1f
    3cbc:	001f5f13          	srli	t5,t5,0x1
    3cc0:	01e664b3          	or	s1,a2,t5
    3cc4:	0017d993          	srli	s3,a5,0x1
    3cc8:	00068913          	mv	s2,a3
    3ccc:	ab5ff06f          	j	3780 <__adddf3+0x138>
    3cd0:	40bf0633          	sub	a2,t5,a1
    3cd4:	40e887b3          	sub	a5,a7,a4
    3cd8:	00cf3733          	sltu	a4,t5,a2
    3cdc:	00060493          	mv	s1,a2
    3ce0:	40e789b3          	sub	s3,a5,a4
    3ce4:	00068413          	mv	s0,a3
    3ce8:	a41ff06f          	j	3728 <__adddf3+0xe0>
    3cec:	00361613          	slli	a2,a2,0x3
    3cf0:	00365613          	srli	a2,a2,0x3
    3cf4:	00068413          	mv	s0,a3
    3cf8:	00088713          	mv	a4,a7
    3cfc:	e25ff06f          	j	3b20 <__adddf3+0x4d8>
    3d00:	de0312e3          	bnez	t1,3ae4 <__adddf3+0x49c>
    3d04:	1c080663          	beqz	a6,3ed0 <__adddf3+0x888>
    3d08:	0038d713          	srli	a4,a7,0x3
    3d0c:	00361613          	slli	a2,a2,0x3
    3d10:	01d89893          	slli	a7,a7,0x1d
    3d14:	01176733          	or	a4,a4,a7
    3d18:	00365613          	srli	a2,a2,0x3
    3d1c:	00c76733          	or	a4,a4,a2
    3d20:	00068413          	mv	s0,a3
    3d24:	dddff06f          	j	3b00 <__adddf3+0x4b8>
    3d28:	01e58f33          	add	t5,a1,t5
    3d2c:	011708b3          	add	a7,a4,a7
    3d30:	00bf35b3          	sltu	a1,t5,a1
    3d34:	00b889b3          	add	s3,a7,a1
    3d38:	00899793          	slli	a5,s3,0x8
    3d3c:	000f0493          	mv	s1,t5
    3d40:	0e07d463          	bgez	a5,3e28 <__adddf3+0x7e0>
    3d44:	00200913          	li	s2,2
    3d48:	bd1ff06f          	j	3918 <__adddf3+0x2d0>
    3d4c:	41e58f33          	sub	t5,a1,t5
    3d50:	411708b3          	sub	a7,a4,a7
    3d54:	01e5b5b3          	sltu	a1,a1,t5
    3d58:	000f0493          	mv	s1,t5
    3d5c:	40b889b3          	sub	s3,a7,a1
    3d60:	00100913          	li	s2,1
    3d64:	9b1ff06f          	j	3714 <__adddf3+0xcc>
    3d68:	fe078693          	addi	a3,a5,-32
    3d6c:	02000613          	li	a2,32
    3d70:	00d8d6b3          	srl	a3,a7,a3
    3d74:	00c78a63          	beq	a5,a2,3d88 <__adddf3+0x740>
    3d78:	04000613          	li	a2,64
    3d7c:	40f607b3          	sub	a5,a2,a5
    3d80:	00f897b3          	sll	a5,a7,a5
    3d84:	00ff6f33          	or	t5,t5,a5
    3d88:	01e039b3          	snez	s3,t5
    3d8c:	00d9e9b3          	or	s3,s3,a3
    3d90:	b65ff06f          	j	38f4 <__adddf3+0x2ac>
    3d94:	00351613          	slli	a2,a0,0x3
    3d98:	00365993          	srli	s3,a2,0x3
    3d9c:	eb5ff06f          	j	3c50 <__adddf3+0x608>
    3da0:	00361613          	slli	a2,a2,0x3
    3da4:	00365613          	srli	a2,a2,0x3
    3da8:	00068413          	mv	s0,a3
    3dac:	00088713          	mv	a4,a7
    3db0:	d41ff06f          	j	3af0 <__adddf3+0x4a8>
    3db4:	00361613          	slli	a2,a2,0x3
    3db8:	00365613          	srli	a2,a2,0x3
    3dbc:	00088713          	mv	a4,a7
    3dc0:	d31ff06f          	j	3af0 <__adddf3+0x4a8>
    3dc4:	fe078513          	addi	a0,a5,-32
    3dc8:	02000613          	li	a2,32
    3dcc:	00a75533          	srl	a0,a4,a0
    3dd0:	00c78a63          	beq	a5,a2,3de4 <__adddf3+0x79c>
    3dd4:	04000613          	li	a2,64
    3dd8:	40f607b3          	sub	a5,a2,a5
    3ddc:	00f717b3          	sll	a5,a4,a5
    3de0:	00f5e5b3          	or	a1,a1,a5
    3de4:	00b03633          	snez	a2,a1
    3de8:	00a66633          	or	a2,a2,a0
    3dec:	a8dff06f          	j	3878 <__adddf3+0x230>
    3df0:	fc0682e3          	beqz	a3,3db4 <__adddf3+0x76c>
    3df4:	01e8ef33          	or	t5,a7,t5
    3df8:	d00f16e3          	bnez	t5,3b04 <__adddf3+0x4bc>
    3dfc:	cedff06f          	j	3ae8 <__adddf3+0x4a0>
    3e00:	dc0808e3          	beqz	a6,3bd0 <__adddf3+0x588>
    3e04:	00361813          	slli	a6,a2,0x3
    3e08:	01d89793          	slli	a5,a7,0x1d
    3e0c:	00385813          	srli	a6,a6,0x3
    3e10:	0038d713          	srli	a4,a7,0x3
    3e14:	00f86833          	or	a6,a6,a5
    3e18:	01d77733          	and	a4,a4,t4
    3e1c:	00068e13          	mv	t3,a3
    3e20:	00000793          	li	a5,0
    3e24:	9bdff06f          	j	37e0 <__adddf3+0x198>
    3e28:	00100793          	li	a5,1
    3e2c:	c2dff06f          	j	3a58 <__adddf3+0x410>
    3e30:	40bf05b3          	sub	a1,t5,a1
    3e34:	40e888b3          	sub	a7,a7,a4
    3e38:	00bf3733          	sltu	a4,t5,a1
    3e3c:	00058493          	mv	s1,a1
    3e40:	40e889b3          	sub	s3,a7,a4
    3e44:	00068413          	mv	s0,a3
    3e48:	00100913          	li	s2,1
    3e4c:	8c9ff06f          	j	3714 <__adddf3+0xcc>
    3e50:	00361613          	slli	a2,a2,0x3
    3e54:	00365613          	srli	a2,a2,0x3
    3e58:	00088713          	mv	a4,a7
    3e5c:	cc5ff06f          	j	3b20 <__adddf3+0x4d8>
    3e60:	00361613          	slli	a2,a2,0x3
    3e64:	00365993          	srli	s3,a2,0x3
    3e68:	00088713          	mv	a4,a7
    3e6c:	de5ff06f          	j	3c50 <__adddf3+0x608>
    3e70:	fe078693          	addi	a3,a5,-32
    3e74:	02000613          	li	a2,32
    3e78:	00d756b3          	srl	a3,a4,a3
    3e7c:	00c78a63          	beq	a5,a2,3e90 <__adddf3+0x848>
    3e80:	04000613          	li	a2,64
    3e84:	40f607b3          	sub	a5,a2,a5
    3e88:	00f717b3          	sll	a5,a4,a5
    3e8c:	00f5e5b3          	or	a1,a1,a5
    3e90:	00b039b3          	snez	s3,a1
    3e94:	00d9e9b3          	or	s3,s3,a3
    3e98:	c35ff06f          	j	3acc <__adddf3+0x484>
    3e9c:	0034d613          	srli	a2,s1,0x3
    3ea0:	00090793          	mv	a5,s2
    3ea4:	00098713          	mv	a4,s3
    3ea8:	c79ff06f          	j	3b20 <__adddf3+0x4d8>
    3eac:	02000693          	li	a3,32
    3eb0:	40f686b3          	sub	a3,a3,a5
    3eb4:	00000613          	li	a2,0
    3eb8:	8b5ff06f          	j	376c <__adddf3+0x124>
    3ebc:	00c9e833          	or	a6,s3,a2
    3ec0:	d00808e3          	beqz	a6,3bd0 <__adddf3+0x588>
    3ec4:	0039d993          	srli	s3,s3,0x3
    3ec8:	00060713          	mv	a4,a2
    3ecc:	d85ff06f          	j	3c50 <__adddf3+0x608>
    3ed0:	00000e13          	li	t3,0
    3ed4:	7ff00793          	li	a5,2047
    3ed8:	00080737          	lui	a4,0x80
    3edc:	905ff06f          	j	37e0 <__adddf3+0x198>
    3ee0:	01d71793          	slli	a5,a4,0x1d
    3ee4:	00375713          	srli	a4,a4,0x3
    3ee8:	0107e833          	or	a6,a5,a6
    3eec:	01d77733          	and	a4,a4,t4
    3ef0:	00000793          	li	a5,0
    3ef4:	8edff06f          	j	37e0 <__adddf3+0x198>
    3ef8:	01d71813          	slli	a6,a4,0x1d
    3efc:	0035d593          	srli	a1,a1,0x3
    3f00:	00b86833          	or	a6,a6,a1
    3f04:	00375713          	srli	a4,a4,0x3
    3f08:	00068413          	mv	s0,a3
    3f0c:	c29ff06f          	j	3b34 <__adddf3+0x4ec>

00003f10 <__divdf3>:
    3f10:	fd010113          	addi	sp,sp,-48
    3f14:	01312e23          	sw	s3,28(sp)
    3f18:	0145d993          	srli	s3,a1,0x14
    3f1c:	02812423          	sw	s0,40(sp)
    3f20:	02912223          	sw	s1,36(sp)
    3f24:	03212023          	sw	s2,32(sp)
    3f28:	01412c23          	sw	s4,24(sp)
    3f2c:	01712623          	sw	s7,12(sp)
    3f30:	00c59493          	slli	s1,a1,0xc
    3f34:	02112623          	sw	ra,44(sp)
    3f38:	01512a23          	sw	s5,20(sp)
    3f3c:	01612823          	sw	s6,16(sp)
    3f40:	01812423          	sw	s8,8(sp)
    3f44:	7ff9f993          	andi	s3,s3,2047
    3f48:	00050413          	mv	s0,a0
    3f4c:	00060b93          	mv	s7,a2
    3f50:	00068913          	mv	s2,a3
    3f54:	00c4d493          	srli	s1,s1,0xc
    3f58:	01f5da13          	srli	s4,a1,0x1f
    3f5c:	18098c63          	beqz	s3,40f4 <__divdf3+0x1e4>
    3f60:	7ff00793          	li	a5,2047
    3f64:	08f98a63          	beq	s3,a5,3ff8 <__divdf3+0xe8>
    3f68:	00349493          	slli	s1,s1,0x3
    3f6c:	01d55793          	srli	a5,a0,0x1d
    3f70:	0097e7b3          	or	a5,a5,s1
    3f74:	00800737          	lui	a4,0x800
    3f78:	00e7eab3          	or	s5,a5,a4
    3f7c:	00351b13          	slli	s6,a0,0x3
    3f80:	c0198993          	addi	s3,s3,-1023
    3f84:	00000493          	li	s1,0
    3f88:	00000c13          	li	s8,0
    3f8c:	01495793          	srli	a5,s2,0x14
    3f90:	00c91413          	slli	s0,s2,0xc
    3f94:	7ff7f793          	andi	a5,a5,2047
    3f98:	00c45413          	srli	s0,s0,0xc
    3f9c:	01f95913          	srli	s2,s2,0x1f
    3fa0:	08078463          	beqz	a5,4028 <__divdf3+0x118>
    3fa4:	7ff00713          	li	a4,2047
    3fa8:	18e78c63          	beq	a5,a4,4140 <__divdf3+0x230>
    3fac:	00341413          	slli	s0,s0,0x3
    3fb0:	01dbd713          	srli	a4,s7,0x1d
    3fb4:	00876733          	or	a4,a4,s0
    3fb8:	c0178793          	addi	a5,a5,-1023
    3fbc:	00800437          	lui	s0,0x800
    3fc0:	00876433          	or	s0,a4,s0
    3fc4:	003b9893          	slli	a7,s7,0x3
    3fc8:	40f989b3          	sub	s3,s3,a5
    3fcc:	00000613          	li	a2,0
    3fd0:	00f00713          	li	a4,15
    3fd4:	012a46b3          	xor	a3,s4,s2
    3fd8:	24976663          	bltu	a4,s1,4224 <__divdf3+0x314>
    3fdc:	00002717          	auipc	a4,0x2
    3fe0:	eac70713          	addi	a4,a4,-340 # 5e88 <pow10.0+0x50>
    3fe4:	00249493          	slli	s1,s1,0x2
    3fe8:	00e484b3          	add	s1,s1,a4
    3fec:	0004a783          	lw	a5,0(s1)
    3ff0:	00e787b3          	add	a5,a5,a4
    3ff4:	00078067          	jr	a5
    3ff8:	00a4eab3          	or	s5,s1,a0
    3ffc:	1c0a9e63          	bnez	s5,41d8 <__divdf3+0x2c8>
    4000:	01495793          	srli	a5,s2,0x14
    4004:	00c91413          	slli	s0,s2,0xc
    4008:	7ff7f793          	andi	a5,a5,2047
    400c:	00000b13          	li	s6,0
    4010:	00800493          	li	s1,8
    4014:	7ff00993          	li	s3,2047
    4018:	00200c13          	li	s8,2
    401c:	00c45413          	srli	s0,s0,0xc
    4020:	01f95913          	srli	s2,s2,0x1f
    4024:	f80790e3          	bnez	a5,3fa4 <__divdf3+0x94>
    4028:	017468b3          	or	a7,s0,s7
    402c:	1c088263          	beqz	a7,41f0 <__divdf3+0x2e0>
    4030:	4a040a63          	beqz	s0,44e4 <__divdf3+0x5d4>
    4034:	00040513          	mv	a0,s0
    4038:	351010ef          	jal	5b88 <__clzsi2>
    403c:	00050793          	mv	a5,a0
    4040:	ff550693          	addi	a3,a0,-11
    4044:	01d00713          	li	a4,29
    4048:	ff878893          	addi	a7,a5,-8
    404c:	40d70733          	sub	a4,a4,a3
    4050:	01141433          	sll	s0,s0,a7
    4054:	00ebd733          	srl	a4,s7,a4
    4058:	00876433          	or	s0,a4,s0
    405c:	011b98b3          	sll	a7,s7,a7
    4060:	013787b3          	add	a5,a5,s3
    4064:	3f378993          	addi	s3,a5,1011
    4068:	00000613          	li	a2,0
    406c:	f65ff06f          	j	3fd0 <__divdf3+0xc0>
    4070:	40f70733          	sub	a4,a4,a5
    4074:	03800613          	li	a2,56
    4078:	4ee65a63          	bge	a2,a4,456c <__divdf3+0x65c>
    407c:	00000793          	li	a5,0
    4080:	00000613          	li	a2,0
    4084:	00000713          	li	a4,0
    4088:	02c12083          	lw	ra,44(sp)
    408c:	02812403          	lw	s0,40(sp)
    4090:	01479793          	slli	a5,a5,0x14
    4094:	00c7e7b3          	or	a5,a5,a2
    4098:	01f69693          	slli	a3,a3,0x1f
    409c:	00d7e7b3          	or	a5,a5,a3
    40a0:	02412483          	lw	s1,36(sp)
    40a4:	02012903          	lw	s2,32(sp)
    40a8:	01c12983          	lw	s3,28(sp)
    40ac:	01812a03          	lw	s4,24(sp)
    40b0:	01412a83          	lw	s5,20(sp)
    40b4:	01012b03          	lw	s6,16(sp)
    40b8:	00c12b83          	lw	s7,12(sp)
    40bc:	00812c03          	lw	s8,8(sp)
    40c0:	00070513          	mv	a0,a4
    40c4:	00078593          	mv	a1,a5
    40c8:	03010113          	addi	sp,sp,48
    40cc:	00008067          	ret
    40d0:	7ff00793          	li	a5,2047
    40d4:	00000613          	li	a2,0
    40d8:	00000713          	li	a4,0
    40dc:	fadff06f          	j	4088 <__divdf3+0x178>
    40e0:	00000693          	li	a3,0
    40e4:	7ff00793          	li	a5,2047
    40e8:	00080637          	lui	a2,0x80
    40ec:	00000713          	li	a4,0
    40f0:	f99ff06f          	j	4088 <__divdf3+0x178>
    40f4:	00a4eab3          	or	s5,s1,a0
    40f8:	100a8c63          	beqz	s5,4210 <__divdf3+0x300>
    40fc:	40048863          	beqz	s1,450c <__divdf3+0x5fc>
    4100:	00048513          	mv	a0,s1
    4104:	285010ef          	jal	5b88 <__clzsi2>
    4108:	00050713          	mv	a4,a0
    410c:	ff550693          	addi	a3,a0,-11
    4110:	01d00793          	li	a5,29
    4114:	ff870b13          	addi	s6,a4,-8
    4118:	40d787b3          	sub	a5,a5,a3
    411c:	016494b3          	sll	s1,s1,s6
    4120:	00f457b3          	srl	a5,s0,a5
    4124:	0097eab3          	or	s5,a5,s1
    4128:	01641b33          	sll	s6,s0,s6
    412c:	c0d00993          	li	s3,-1011
    4130:	40e989b3          	sub	s3,s3,a4
    4134:	00000493          	li	s1,0
    4138:	00000c13          	li	s8,0
    413c:	e51ff06f          	j	3f8c <__divdf3+0x7c>
    4140:	017468b3          	or	a7,s0,s7
    4144:	80198993          	addi	s3,s3,-2047
    4148:	0a089c63          	bnez	a7,4200 <__divdf3+0x2f0>
    414c:	0024e493          	ori	s1,s1,2
    4150:	00000413          	li	s0,0
    4154:	00200613          	li	a2,2
    4158:	e79ff06f          	j	3fd0 <__divdf3+0xc0>
    415c:	000a0913          	mv	s2,s4
    4160:	000a8413          	mv	s0,s5
    4164:	000b0893          	mv	a7,s6
    4168:	00200793          	li	a5,2
    416c:	4efc0863          	beq	s8,a5,465c <__divdf3+0x74c>
    4170:	00300793          	li	a5,3
    4174:	f6fc06e3          	beq	s8,a5,40e0 <__divdf3+0x1d0>
    4178:	00100793          	li	a5,1
    417c:	00090693          	mv	a3,s2
    4180:	eefc0ee3          	beq	s8,a5,407c <__divdf3+0x16c>
    4184:	3ff98793          	addi	a5,s3,1023
    4188:	2af05663          	blez	a5,4434 <__divdf3+0x524>
    418c:	0078f713          	andi	a4,a7,7
    4190:	4a071663          	bnez	a4,463c <__divdf3+0x72c>
    4194:	00741713          	slli	a4,s0,0x7
    4198:	00075a63          	bgez	a4,41ac <__divdf3+0x29c>
    419c:	ff0007b7          	lui	a5,0xff000
    41a0:	fff78793          	addi	a5,a5,-1 # feffffff <__freertos_irq_stack_top+0xfeff8f7f>
    41a4:	00f47433          	and	s0,s0,a5
    41a8:	40098793          	addi	a5,s3,1024
    41ac:	7fe00713          	li	a4,2046
    41b0:	f2f740e3          	blt	a4,a5,40d0 <__divdf3+0x1c0>
    41b4:	0038d893          	srli	a7,a7,0x3
    41b8:	01d41713          	slli	a4,s0,0x1d
    41bc:	00941613          	slli	a2,s0,0x9
    41c0:	01176733          	or	a4,a4,a7
    41c4:	00c65613          	srli	a2,a2,0xc
    41c8:	7ff7f793          	andi	a5,a5,2047
    41cc:	ebdff06f          	j	4088 <__divdf3+0x178>
    41d0:	00060c13          	mv	s8,a2
    41d4:	f95ff06f          	j	4168 <__divdf3+0x258>
    41d8:	00048a93          	mv	s5,s1
    41dc:	00050b13          	mv	s6,a0
    41e0:	00c00493          	li	s1,12
    41e4:	7ff00993          	li	s3,2047
    41e8:	00300c13          	li	s8,3
    41ec:	da1ff06f          	j	3f8c <__divdf3+0x7c>
    41f0:	0014e493          	ori	s1,s1,1
    41f4:	00000413          	li	s0,0
    41f8:	00100613          	li	a2,1
    41fc:	dd5ff06f          	j	3fd0 <__divdf3+0xc0>
    4200:	0034e493          	ori	s1,s1,3
    4204:	000b8893          	mv	a7,s7
    4208:	00300613          	li	a2,3
    420c:	dc5ff06f          	j	3fd0 <__divdf3+0xc0>
    4210:	00000b13          	li	s6,0
    4214:	00400493          	li	s1,4
    4218:	00000993          	li	s3,0
    421c:	00100c13          	li	s8,1
    4220:	d6dff06f          	j	3f8c <__divdf3+0x7c>
    4224:	2b546463          	bltu	s0,s5,44cc <__divdf3+0x5bc>
    4228:	2a8a8063          	beq	s5,s0,44c8 <__divdf3+0x5b8>
    422c:	000b0313          	mv	t1,s6
    4230:	fff98993          	addi	s3,s3,-1
    4234:	000a8793          	mv	a5,s5
    4238:	00000b13          	li	s6,0
    423c:	00841713          	slli	a4,s0,0x8
    4240:	01075513          	srli	a0,a4,0x10
    4244:	02a7d433          	divu	s0,a5,a0
    4248:	0188d613          	srli	a2,a7,0x18
    424c:	00e66633          	or	a2,a2,a4
    4250:	01061813          	slli	a6,a2,0x10
    4254:	01085813          	srli	a6,a6,0x10
    4258:	00889593          	slli	a1,a7,0x8
    425c:	01035713          	srli	a4,t1,0x10
    4260:	02a7f7b3          	remu	a5,a5,a0
    4264:	028808b3          	mul	a7,a6,s0
    4268:	01079793          	slli	a5,a5,0x10
    426c:	00f767b3          	or	a5,a4,a5
    4270:	0117fa63          	bgeu	a5,a7,4284 <__divdf3+0x374>
    4274:	00f607b3          	add	a5,a2,a5
    4278:	fff40713          	addi	a4,s0,-1 # 7fffff <__freertos_irq_stack_top+0x7f8f7f>
    427c:	2ec7f063          	bgeu	a5,a2,455c <__divdf3+0x64c>
    4280:	00070413          	mv	s0,a4
    4284:	411787b3          	sub	a5,a5,a7
    4288:	02a7d8b3          	divu	a7,a5,a0
    428c:	01031713          	slli	a4,t1,0x10
    4290:	01075713          	srli	a4,a4,0x10
    4294:	02a7f7b3          	remu	a5,a5,a0
    4298:	03180fb3          	mul	t6,a6,a7
    429c:	01079793          	slli	a5,a5,0x10
    42a0:	00f76733          	or	a4,a4,a5
    42a4:	01f77a63          	bgeu	a4,t6,42b8 <__divdf3+0x3a8>
    42a8:	00e60733          	add	a4,a2,a4
    42ac:	fff88793          	addi	a5,a7,-1
    42b0:	28c77e63          	bgeu	a4,a2,454c <__divdf3+0x63c>
    42b4:	00078893          	mv	a7,a5
    42b8:	01041413          	slli	s0,s0,0x10
    42bc:	000102b7          	lui	t0,0x10
    42c0:	01146433          	or	s0,s0,a7
    42c4:	fff28313          	addi	t1,t0,-1 # ffff <__freertos_irq_stack_top+0x8f7f>
    42c8:	006478b3          	and	a7,s0,t1
    42cc:	01045e93          	srli	t4,s0,0x10
    42d0:	0105de13          	srli	t3,a1,0x10
    42d4:	0065f333          	and	t1,a1,t1
    42d8:	03130f33          	mul	t5,t1,a7
    42dc:	41f70733          	sub	a4,a4,t6
    42e0:	031e08b3          	mul	a7,t3,a7
    42e4:	010f5793          	srli	a5,t5,0x10
    42e8:	026e8fb3          	mul	t6,t4,t1
    42ec:	01f888b3          	add	a7,a7,t6
    42f0:	011787b3          	add	a5,a5,a7
    42f4:	03ce8eb3          	mul	t4,t4,t3
    42f8:	01f7f463          	bgeu	a5,t6,4300 <__divdf3+0x3f0>
    42fc:	005e8eb3          	add	t4,t4,t0
    4300:	00010fb7          	lui	t6,0x10
    4304:	ffff8f93          	addi	t6,t6,-1 # ffff <__freertos_irq_stack_top+0x8f7f>
    4308:	0107d893          	srli	a7,a5,0x10
    430c:	01f7f7b3          	and	a5,a5,t6
    4310:	01079793          	slli	a5,a5,0x10
    4314:	01ff7f33          	and	t5,t5,t6
    4318:	01d888b3          	add	a7,a7,t4
    431c:	01e787b3          	add	a5,a5,t5
    4320:	17176e63          	bltu	a4,a7,449c <__divdf3+0x58c>
    4324:	17170a63          	beq	a4,a7,4498 <__divdf3+0x588>
    4328:	40fb07b3          	sub	a5,s6,a5
    432c:	41170733          	sub	a4,a4,a7
    4330:	00fb3b33          	sltu	s6,s6,a5
    4334:	41670733          	sub	a4,a4,s6
    4338:	2ee60063          	beq	a2,a4,4618 <__divdf3+0x708>
    433c:	02a758b3          	divu	a7,a4,a0
    4340:	0107de93          	srli	t4,a5,0x10
    4344:	02a77733          	remu	a4,a4,a0
    4348:	03180f33          	mul	t5,a6,a7
    434c:	01071713          	slli	a4,a4,0x10
    4350:	00eee733          	or	a4,t4,a4
    4354:	01e77e63          	bgeu	a4,t5,4370 <__divdf3+0x460>
    4358:	00e60733          	add	a4,a2,a4
    435c:	fff88e93          	addi	t4,a7,-1
    4360:	2ec76a63          	bltu	a4,a2,4654 <__divdf3+0x744>
    4364:	2fe77863          	bgeu	a4,t5,4654 <__divdf3+0x744>
    4368:	ffe88893          	addi	a7,a7,-2
    436c:	00c70733          	add	a4,a4,a2
    4370:	41e70733          	sub	a4,a4,t5
    4374:	02a75eb3          	divu	t4,a4,a0
    4378:	01079793          	slli	a5,a5,0x10
    437c:	0107d793          	srli	a5,a5,0x10
    4380:	02a77733          	remu	a4,a4,a0
    4384:	03d80833          	mul	a6,a6,t4
    4388:	01071713          	slli	a4,a4,0x10
    438c:	00e7e7b3          	or	a5,a5,a4
    4390:	0107fe63          	bgeu	a5,a6,43ac <__divdf3+0x49c>
    4394:	00f607b3          	add	a5,a2,a5
    4398:	fffe8713          	addi	a4,t4,-1
    439c:	2ac7e863          	bltu	a5,a2,464c <__divdf3+0x73c>
    43a0:	2b07f663          	bgeu	a5,a6,464c <__divdf3+0x73c>
    43a4:	ffee8e93          	addi	t4,t4,-2
    43a8:	00c787b3          	add	a5,a5,a2
    43ac:	01089893          	slli	a7,a7,0x10
    43b0:	01d8e8b3          	or	a7,a7,t4
    43b4:	01089513          	slli	a0,a7,0x10
    43b8:	0108df13          	srli	t5,a7,0x10
    43bc:	01055513          	srli	a0,a0,0x10
    43c0:	02650eb3          	mul	t4,a0,t1
    43c4:	410787b3          	sub	a5,a5,a6
    43c8:	02ae0533          	mul	a0,t3,a0
    43cc:	010ed713          	srli	a4,t4,0x10
    43d0:	026f0333          	mul	t1,t5,t1
    43d4:	00650533          	add	a0,a0,t1
    43d8:	00a70733          	add	a4,a4,a0
    43dc:	03ee0e33          	mul	t3,t3,t5
    43e0:	00677663          	bgeu	a4,t1,43ec <__divdf3+0x4dc>
    43e4:	00010537          	lui	a0,0x10
    43e8:	00ae0e33          	add	t3,t3,a0
    43ec:	00010837          	lui	a6,0x10
    43f0:	fff80813          	addi	a6,a6,-1 # ffff <__freertos_irq_stack_top+0x8f7f>
    43f4:	01075513          	srli	a0,a4,0x10
    43f8:	01077733          	and	a4,a4,a6
    43fc:	01071713          	slli	a4,a4,0x10
    4400:	010efeb3          	and	t4,t4,a6
    4404:	01c50533          	add	a0,a0,t3
    4408:	01d70733          	add	a4,a4,t4
    440c:	12a7f263          	bgeu	a5,a0,4530 <__divdf3+0x620>
    4410:	00f607b3          	add	a5,a2,a5
    4414:	fff88313          	addi	t1,a7,-1
    4418:	00078813          	mv	a6,a5
    441c:	1cc7e463          	bltu	a5,a2,45e4 <__divdf3+0x6d4>
    4420:	24a7e863          	bltu	a5,a0,4670 <__divdf3+0x760>
    4424:	26a78663          	beq	a5,a0,4690 <__divdf3+0x780>
    4428:	00030893          	mv	a7,t1
    442c:	0018e893          	ori	a7,a7,1
    4430:	d55ff06f          	j	4184 <__divdf3+0x274>
    4434:	00100713          	li	a4,1
    4438:	c2079ce3          	bnez	a5,4070 <__divdf3+0x160>
    443c:	41e98993          	addi	s3,s3,1054
    4440:	013897b3          	sll	a5,a7,s3
    4444:	00f037b3          	snez	a5,a5
    4448:	013419b3          	sll	s3,s0,s3
    444c:	0137e7b3          	or	a5,a5,s3
    4450:	00e8d8b3          	srl	a7,a7,a4
    4454:	00f8e8b3          	or	a7,a7,a5
    4458:	0078f793          	andi	a5,a7,7
    445c:	00e45433          	srl	s0,s0,a4
    4460:	02078063          	beqz	a5,4480 <__divdf3+0x570>
    4464:	00f8f793          	andi	a5,a7,15
    4468:	00400713          	li	a4,4
    446c:	00e78a63          	beq	a5,a4,4480 <__divdf3+0x570>
    4470:	00488793          	addi	a5,a7,4
    4474:	0117b8b3          	sltu	a7,a5,a7
    4478:	01140433          	add	s0,s0,a7
    447c:	00078893          	mv	a7,a5
    4480:	00841593          	slli	a1,s0,0x8
    4484:	00100793          	li	a5,1
    4488:	00000613          	li	a2,0
    448c:	00000713          	li	a4,0
    4490:	be05cce3          	bltz	a1,4088 <__divdf3+0x178>
    4494:	1340006f          	j	45c8 <__divdf3+0x6b8>
    4498:	e8fb78e3          	bgeu	s6,a5,4328 <__divdf3+0x418>
    449c:	00bb0eb3          	add	t4,s6,a1
    44a0:	016ebf33          	sltu	t5,t4,s6
    44a4:	00cf0fb3          	add	t6,t5,a2
    44a8:	01f70733          	add	a4,a4,t6
    44ac:	000e8b13          	mv	s6,t4
    44b0:	fff40f93          	addi	t6,s0,-1
    44b4:	08e67463          	bgeu	a2,a4,453c <__divdf3+0x62c>
    44b8:	15176263          	bltu	a4,a7,45fc <__divdf3+0x6ec>
    44bc:	12e88e63          	beq	a7,a4,45f8 <__divdf3+0x6e8>
    44c0:	000f8413          	mv	s0,t6
    44c4:	e65ff06f          	j	4328 <__divdf3+0x418>
    44c8:	d71b62e3          	bltu	s6,a7,422c <__divdf3+0x31c>
    44cc:	001b5713          	srli	a4,s6,0x1
    44d0:	01fa9313          	slli	t1,s5,0x1f
    44d4:	001ad793          	srli	a5,s5,0x1
    44d8:	00e36333          	or	t1,t1,a4
    44dc:	01fb1b13          	slli	s6,s6,0x1f
    44e0:	d5dff06f          	j	423c <__divdf3+0x32c>
    44e4:	000b8513          	mv	a0,s7
    44e8:	6a0010ef          	jal	5b88 <__clzsi2>
    44ec:	01550693          	addi	a3,a0,21 # 10015 <__freertos_irq_stack_top+0x8f95>
    44f0:	01c00713          	li	a4,28
    44f4:	02050793          	addi	a5,a0,32
    44f8:	b4d756e3          	bge	a4,a3,4044 <__divdf3+0x134>
    44fc:	ff850513          	addi	a0,a0,-8
    4500:	00000893          	li	a7,0
    4504:	00ab9433          	sll	s0,s7,a0
    4508:	b59ff06f          	j	4060 <__divdf3+0x150>
    450c:	67c010ef          	jal	5b88 <__clzsi2>
    4510:	01550693          	addi	a3,a0,21
    4514:	01c00793          	li	a5,28
    4518:	02050713          	addi	a4,a0,32
    451c:	bed7dae3          	bge	a5,a3,4110 <__divdf3+0x200>
    4520:	ff850793          	addi	a5,a0,-8
    4524:	00f41ab3          	sll	s5,s0,a5
    4528:	00000b13          	li	s6,0
    452c:	c01ff06f          	j	412c <__divdf3+0x21c>
    4530:	eea79ee3          	bne	a5,a0,442c <__divdf3+0x51c>
    4534:	c40708e3          	beqz	a4,4184 <__divdf3+0x274>
    4538:	ed9ff06f          	j	4410 <__divdf3+0x500>
    453c:	f8e612e3          	bne	a2,a4,44c0 <__divdf3+0x5b0>
    4540:	f60f0ce3          	beqz	t5,44b8 <__divdf3+0x5a8>
    4544:	000f8413          	mv	s0,t6
    4548:	de1ff06f          	j	4328 <__divdf3+0x418>
    454c:	d7f774e3          	bgeu	a4,t6,42b4 <__divdf3+0x3a4>
    4550:	ffe88893          	addi	a7,a7,-2
    4554:	00c70733          	add	a4,a4,a2
    4558:	d61ff06f          	j	42b8 <__divdf3+0x3a8>
    455c:	d317f2e3          	bgeu	a5,a7,4280 <__divdf3+0x370>
    4560:	ffe40413          	addi	s0,s0,-2
    4564:	00c787b3          	add	a5,a5,a2
    4568:	d1dff06f          	j	4284 <__divdf3+0x374>
    456c:	01f00613          	li	a2,31
    4570:	ece656e3          	bge	a2,a4,443c <__divdf3+0x52c>
    4574:	fe100613          	li	a2,-31
    4578:	40f607b3          	sub	a5,a2,a5
    457c:	02000613          	li	a2,32
    4580:	00f457b3          	srl	a5,s0,a5
    4584:	00c70863          	beq	a4,a2,4594 <__divdf3+0x684>
    4588:	43e98993          	addi	s3,s3,1086
    458c:	013419b3          	sll	s3,s0,s3
    4590:	0138e8b3          	or	a7,a7,s3
    4594:	011038b3          	snez	a7,a7
    4598:	00f8e8b3          	or	a7,a7,a5
    459c:	0078f713          	andi	a4,a7,7
    45a0:	00000613          	li	a2,0
    45a4:	02070863          	beqz	a4,45d4 <__divdf3+0x6c4>
    45a8:	00f8f793          	andi	a5,a7,15
    45ac:	00400713          	li	a4,4
    45b0:	00000413          	li	s0,0
    45b4:	00e78a63          	beq	a5,a4,45c8 <__divdf3+0x6b8>
    45b8:	00488793          	addi	a5,a7,4
    45bc:	0117b8b3          	sltu	a7,a5,a7
    45c0:	01103433          	snez	s0,a7
    45c4:	00078893          	mv	a7,a5
    45c8:	00941613          	slli	a2,s0,0x9
    45cc:	01d41713          	slli	a4,s0,0x1d
    45d0:	00c65613          	srli	a2,a2,0xc
    45d4:	0038d893          	srli	a7,a7,0x3
    45d8:	00e8e733          	or	a4,a7,a4
    45dc:	00000793          	li	a5,0
    45e0:	aa9ff06f          	j	4088 <__divdf3+0x178>
    45e4:	00030893          	mv	a7,t1
    45e8:	e4a812e3          	bne	a6,a0,442c <__divdf3+0x51c>
    45ec:	b8b70ce3          	beq	a4,a1,4184 <__divdf3+0x274>
    45f0:	0018e893          	ori	a7,a7,1
    45f4:	b91ff06f          	j	4184 <__divdf3+0x274>
    45f8:	ecfef4e3          	bgeu	t4,a5,44c0 <__divdf3+0x5b0>
    45fc:	01d58eb3          	add	t4,a1,t4
    4600:	00bebf33          	sltu	t5,t4,a1
    4604:	00cf0f33          	add	t5,t5,a2
    4608:	ffe40413          	addi	s0,s0,-2
    460c:	000e8b13          	mv	s6,t4
    4610:	01e70733          	add	a4,a4,t5
    4614:	d15ff06f          	j	4328 <__divdf3+0x418>
    4618:	c0200713          	li	a4,-1022
    461c:	3ff98793          	addi	a5,s3,1023
    4620:	fff00893          	li	a7,-1
    4624:	e0e9c8e3          	blt	s3,a4,4434 <__divdf3+0x524>
    4628:	00488713          	addi	a4,a7,4
    462c:	011738b3          	sltu	a7,a4,a7
    4630:	01140433          	add	s0,s0,a7
    4634:	00070893          	mv	a7,a4
    4638:	b5dff06f          	j	4194 <__divdf3+0x284>
    463c:	00f8f713          	andi	a4,a7,15
    4640:	00400613          	li	a2,4
    4644:	b4c708e3          	beq	a4,a2,4194 <__divdf3+0x284>
    4648:	fe1ff06f          	j	4628 <__divdf3+0x718>
    464c:	00070e93          	mv	t4,a4
    4650:	d5dff06f          	j	43ac <__divdf3+0x49c>
    4654:	000e8893          	mv	a7,t4
    4658:	d19ff06f          	j	4370 <__divdf3+0x460>
    465c:	00090693          	mv	a3,s2
    4660:	7ff00793          	li	a5,2047
    4664:	00000613          	li	a2,0
    4668:	00000713          	li	a4,0
    466c:	a1dff06f          	j	4088 <__divdf3+0x178>
    4670:	00159313          	slli	t1,a1,0x1
    4674:	00b33833          	sltu	a6,t1,a1
    4678:	00c80833          	add	a6,a6,a2
    467c:	01078833          	add	a6,a5,a6
    4680:	ffe88893          	addi	a7,a7,-2
    4684:	00030593          	mv	a1,t1
    4688:	f6a802e3          	beq	a6,a0,45ec <__divdf3+0x6dc>
    468c:	da1ff06f          	j	442c <__divdf3+0x51c>
    4690:	fee5e0e3          	bltu	a1,a4,4670 <__divdf3+0x760>
    4694:	00030893          	mv	a7,t1
    4698:	f4b71ce3          	bne	a4,a1,45f0 <__divdf3+0x6e0>
    469c:	ae9ff06f          	j	4184 <__divdf3+0x274>

000046a0 <__eqdf2>:
    46a0:	0145d713          	srli	a4,a1,0x14
    46a4:	001007b7          	lui	a5,0x100
    46a8:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf8f7f>
    46ac:	0146d813          	srli	a6,a3,0x14
    46b0:	7ff77713          	andi	a4,a4,2047
    46b4:	7ff00313          	li	t1,2047
    46b8:	00b7fe33          	and	t3,a5,a1
    46bc:	00050893          	mv	a7,a0
    46c0:	00d7f7b3          	and	a5,a5,a3
    46c4:	01f5d593          	srli	a1,a1,0x1f
    46c8:	7ff87813          	andi	a6,a6,2047
    46cc:	01f6d693          	srli	a3,a3,0x1f
    46d0:	00100513          	li	a0,1
    46d4:	00670c63          	beq	a4,t1,46ec <__eqdf2+0x4c>
    46d8:	00680863          	beq	a6,t1,46e8 <__eqdf2+0x48>
    46dc:	01071463          	bne	a4,a6,46e4 <__eqdf2+0x44>
    46e0:	02fe0663          	beq	t3,a5,470c <__eqdf2+0x6c>
    46e4:	00008067          	ret
    46e8:	00008067          	ret
    46ec:	fee81ce3          	bne	a6,a4,46e4 <__eqdf2+0x44>
    46f0:	00fe67b3          	or	a5,t3,a5
    46f4:	00c7e7b3          	or	a5,a5,a2
    46f8:	0117e7b3          	or	a5,a5,a7
    46fc:	fe0794e3          	bnez	a5,46e4 <__eqdf2+0x44>
    4700:	40d585b3          	sub	a1,a1,a3
    4704:	00b03533          	snez	a0,a1
    4708:	00008067          	ret
    470c:	fcc89ce3          	bne	a7,a2,46e4 <__eqdf2+0x44>
    4710:	00d58a63          	beq	a1,a3,4724 <__eqdf2+0x84>
    4714:	fc0718e3          	bnez	a4,46e4 <__eqdf2+0x44>
    4718:	011e6e33          	or	t3,t3,a7
    471c:	01c03533          	snez	a0,t3
    4720:	00008067          	ret
    4724:	00000513          	li	a0,0
    4728:	00008067          	ret

0000472c <__gedf2>:
    472c:	0145d893          	srli	a7,a1,0x14
    4730:	001007b7          	lui	a5,0x100
    4734:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf8f7f>
    4738:	0146d713          	srli	a4,a3,0x14
    473c:	7ff8f893          	andi	a7,a7,2047
    4740:	7ff00e13          	li	t3,2047
    4744:	00b7f333          	and	t1,a5,a1
    4748:	00050813          	mv	a6,a0
    474c:	00050e93          	mv	t4,a0
    4750:	00d7f7b3          	and	a5,a5,a3
    4754:	01f5d593          	srli	a1,a1,0x1f
    4758:	00060f13          	mv	t5,a2
    475c:	7ff77513          	andi	a0,a4,2047
    4760:	01f6d693          	srli	a3,a3,0x1f
    4764:	05c88863          	beq	a7,t3,47b4 <__gedf2+0x88>
    4768:	03c50463          	beq	a0,t3,4790 <__gedf2+0x64>
    476c:	06089a63          	bnez	a7,47e0 <__gedf2+0xb4>
    4770:	01036833          	or	a6,t1,a6
    4774:	06051063          	bnez	a0,47d4 <__gedf2+0xa8>
    4778:	00c7e633          	or	a2,a5,a2
    477c:	08060c63          	beqz	a2,4814 <__gedf2+0xe8>
    4780:	0a081263          	bnez	a6,4824 <__gedf2+0xf8>
    4784:	00100513          	li	a0,1
    4788:	08068263          	beqz	a3,480c <__gedf2+0xe0>
    478c:	00008067          	ret
    4790:	00c7e633          	or	a2,a5,a2
    4794:	08061463          	bnez	a2,481c <__gedf2+0xf0>
    4798:	00089663          	bnez	a7,47a4 <__gedf2+0x78>
    479c:	01036333          	or	t1,t1,a6
    47a0:	fe0302e3          	beqz	t1,4784 <__gedf2+0x58>
    47a4:	06d58063          	beq	a1,a3,4804 <__gedf2+0xd8>
    47a8:	06059263          	bnez	a1,480c <__gedf2+0xe0>
    47ac:	00100513          	li	a0,1
    47b0:	00008067          	ret
    47b4:	01036333          	or	t1,t1,a6
    47b8:	06031263          	bnez	t1,481c <__gedf2+0xf0>
    47bc:	ff1516e3          	bne	a0,a7,47a8 <__gedf2+0x7c>
    47c0:	00c7e7b3          	or	a5,a5,a2
    47c4:	04079c63          	bnez	a5,481c <__gedf2+0xf0>
    47c8:	fed590e3          	bne	a1,a3,47a8 <__gedf2+0x7c>
    47cc:	00000513          	li	a0,0
    47d0:	00008067          	ret
    47d4:	fa0808e3          	beqz	a6,4784 <__gedf2+0x58>
    47d8:	fcd598e3          	bne	a1,a3,47a8 <__gedf2+0x7c>
    47dc:	0280006f          	j	4804 <__gedf2+0xd8>
    47e0:	fc0504e3          	beqz	a0,47a8 <__gedf2+0x7c>
    47e4:	fcd592e3          	bne	a1,a3,47a8 <__gedf2+0x7c>
    47e8:	fd1540e3          	blt	a0,a7,47a8 <__gedf2+0x7c>
    47ec:	00a8cc63          	blt	a7,a0,4804 <__gedf2+0xd8>
    47f0:	fa67ece3          	bltu	a5,t1,47a8 <__gedf2+0x7c>
    47f4:	00f31863          	bne	t1,a5,4804 <__gedf2+0xd8>
    47f8:	fbdf68e3          	bltu	t5,t4,47a8 <__gedf2+0x7c>
    47fc:	00000513          	li	a0,0
    4800:	f9eef6e3          	bgeu	t4,t5,478c <__gedf2+0x60>
    4804:	00100513          	li	a0,1
    4808:	f80592e3          	bnez	a1,478c <__gedf2+0x60>
    480c:	fff00513          	li	a0,-1
    4810:	00008067          	ret
    4814:	f8081ae3          	bnez	a6,47a8 <__gedf2+0x7c>
    4818:	00008067          	ret
    481c:	ffe00513          	li	a0,-2
    4820:	00008067          	ret
    4824:	fcd586e3          	beq	a1,a3,47f0 <__gedf2+0xc4>
    4828:	f81ff06f          	j	47a8 <__gedf2+0x7c>

0000482c <__ledf2>:
    482c:	0145d893          	srli	a7,a1,0x14
    4830:	001007b7          	lui	a5,0x100
    4834:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf8f7f>
    4838:	0146d713          	srli	a4,a3,0x14
    483c:	7ff8f893          	andi	a7,a7,2047
    4840:	7ff00313          	li	t1,2047
    4844:	00b7fe33          	and	t3,a5,a1
    4848:	00050813          	mv	a6,a0
    484c:	00050e93          	mv	t4,a0
    4850:	00d7f7b3          	and	a5,a5,a3
    4854:	01f5d593          	srli	a1,a1,0x1f
    4858:	00060f13          	mv	t5,a2
    485c:	7ff77513          	andi	a0,a4,2047
    4860:	01f6d693          	srli	a3,a3,0x1f
    4864:	04688a63          	beq	a7,t1,48b8 <__ledf2+0x8c>
    4868:	02650463          	beq	a0,t1,4890 <__ledf2+0x64>
    486c:	06089863          	bnez	a7,48dc <__ledf2+0xb0>
    4870:	010e6833          	or	a6,t3,a6
    4874:	08051e63          	bnez	a0,4910 <__ledf2+0xe4>
    4878:	00c7e633          	or	a2,a5,a2
    487c:	0a060463          	beqz	a2,4924 <__ledf2+0xf8>
    4880:	0a081663          	bnez	a6,492c <__ledf2+0x100>
    4884:	00100513          	li	a0,1
    4888:	08068063          	beqz	a3,4908 <__ledf2+0xdc>
    488c:	00008067          	ret
    4890:	00c7e633          	or	a2,a5,a2
    4894:	00200513          	li	a0,2
    4898:	fe061ae3          	bnez	a2,488c <__ledf2+0x60>
    489c:	00089663          	bnez	a7,48a8 <__ledf2+0x7c>
    48a0:	010e6e33          	or	t3,t3,a6
    48a4:	fe0e00e3          	beqz	t3,4884 <__ledf2+0x58>
    48a8:	04d58c63          	beq	a1,a3,4900 <__ledf2+0xd4>
    48ac:	04059e63          	bnez	a1,4908 <__ledf2+0xdc>
    48b0:	00100513          	li	a0,1
    48b4:	00008067          	ret
    48b8:	010e6e33          	or	t3,t3,a6
    48bc:	060e1063          	bnez	t3,491c <__ledf2+0xf0>
    48c0:	ff1516e3          	bne	a0,a7,48ac <__ledf2+0x80>
    48c4:	00c7e7b3          	or	a5,a5,a2
    48c8:	00200513          	li	a0,2
    48cc:	fc0790e3          	bnez	a5,488c <__ledf2+0x60>
    48d0:	fcd59ee3          	bne	a1,a3,48ac <__ledf2+0x80>
    48d4:	00000513          	li	a0,0
    48d8:	00008067          	ret
    48dc:	fc0508e3          	beqz	a0,48ac <__ledf2+0x80>
    48e0:	fcd596e3          	bne	a1,a3,48ac <__ledf2+0x80>
    48e4:	fd1544e3          	blt	a0,a7,48ac <__ledf2+0x80>
    48e8:	00a8cc63          	blt	a7,a0,4900 <__ledf2+0xd4>
    48ec:	fdc7e0e3          	bltu	a5,t3,48ac <__ledf2+0x80>
    48f0:	00fe1863          	bne	t3,a5,4900 <__ledf2+0xd4>
    48f4:	fbdf6ce3          	bltu	t5,t4,48ac <__ledf2+0x80>
    48f8:	00000513          	li	a0,0
    48fc:	f9eef8e3          	bgeu	t4,t5,488c <__ledf2+0x60>
    4900:	00100513          	li	a0,1
    4904:	f80594e3          	bnez	a1,488c <__ledf2+0x60>
    4908:	fff00513          	li	a0,-1
    490c:	00008067          	ret
    4910:	f6080ae3          	beqz	a6,4884 <__ledf2+0x58>
    4914:	f8d59ce3          	bne	a1,a3,48ac <__ledf2+0x80>
    4918:	fe9ff06f          	j	4900 <__ledf2+0xd4>
    491c:	00200513          	li	a0,2
    4920:	00008067          	ret
    4924:	f80814e3          	bnez	a6,48ac <__ledf2+0x80>
    4928:	00008067          	ret
    492c:	fcd580e3          	beq	a1,a3,48ec <__ledf2+0xc0>
    4930:	f7dff06f          	j	48ac <__ledf2+0x80>

00004934 <__muldf3>:
    4934:	fd010113          	addi	sp,sp,-48
    4938:	0145d793          	srli	a5,a1,0x14
    493c:	02812423          	sw	s0,40(sp)
    4940:	02912223          	sw	s1,36(sp)
    4944:	03212023          	sw	s2,32(sp)
    4948:	01312e23          	sw	s3,28(sp)
    494c:	01512a23          	sw	s5,20(sp)
    4950:	00c59493          	slli	s1,a1,0xc
    4954:	02112623          	sw	ra,44(sp)
    4958:	01412c23          	sw	s4,24(sp)
    495c:	01612823          	sw	s6,16(sp)
    4960:	01712623          	sw	s7,12(sp)
    4964:	01812423          	sw	s8,8(sp)
    4968:	7ff7f793          	andi	a5,a5,2047
    496c:	00050413          	mv	s0,a0
    4970:	00060a93          	mv	s5,a2
    4974:	00068993          	mv	s3,a3
    4978:	00c4d493          	srli	s1,s1,0xc
    497c:	01f5d913          	srli	s2,a1,0x1f
    4980:	42078463          	beqz	a5,4da8 <__muldf3+0x474>
    4984:	7ff00713          	li	a4,2047
    4988:	0ae78663          	beq	a5,a4,4a34 <__muldf3+0x100>
    498c:	00349693          	slli	a3,s1,0x3
    4990:	01d55713          	srli	a4,a0,0x1d
    4994:	00d76733          	or	a4,a4,a3
    4998:	008006b7          	lui	a3,0x800
    499c:	00d764b3          	or	s1,a4,a3
    49a0:	00351a13          	slli	s4,a0,0x3
    49a4:	c0178c13          	addi	s8,a5,-1023
    49a8:	00000b13          	li	s6,0
    49ac:	00000b93          	li	s7,0
    49b0:	0149d793          	srli	a5,s3,0x14
    49b4:	00c99713          	slli	a4,s3,0xc
    49b8:	7ff7f793          	andi	a5,a5,2047
    49bc:	000a8f13          	mv	t5,s5
    49c0:	00c75413          	srli	s0,a4,0xc
    49c4:	01f9d993          	srli	s3,s3,0x1f
    49c8:	0a078063          	beqz	a5,4a68 <__muldf3+0x134>
    49cc:	7ff00713          	li	a4,2047
    49d0:	14e78e63          	beq	a5,a4,4b2c <__muldf3+0x1f8>
    49d4:	00341713          	slli	a4,s0,0x3
    49d8:	01dad593          	srli	a1,s5,0x1d
    49dc:	00e5e5b3          	or	a1,a1,a4
    49e0:	c0178793          	addi	a5,a5,-1023
    49e4:	00800737          	lui	a4,0x800
    49e8:	00e5e433          	or	s0,a1,a4
    49ec:	003a9f13          	slli	t5,s5,0x3
    49f0:	018788b3          	add	a7,a5,s8
    49f4:	00000313          	li	t1,0
    49f8:	00a00713          	li	a4,10
    49fc:	00188513          	addi	a0,a7,1
    4a00:	0b674c63          	blt	a4,s6,4ab8 <__muldf3+0x184>
    4a04:	013945b3          	xor	a1,s2,s3
    4a08:	00200793          	li	a5,2
    4a0c:	00058813          	mv	a6,a1
    4a10:	1567c663          	blt	a5,s6,4b5c <__muldf3+0x228>
    4a14:	fffb0b13          	addi	s6,s6,-1
    4a18:	00100713          	li	a4,1
    4a1c:	17676063          	bltu	a4,s6,4b7c <__muldf3+0x248>
    4a20:	3cf30a63          	beq	t1,a5,4df4 <__muldf3+0x4c0>
    4a24:	00040493          	mv	s1,s0
    4a28:	000f0a13          	mv	s4,t5
    4a2c:	00030b93          	mv	s7,t1
    4a30:	09c0006f          	j	4acc <__muldf3+0x198>
    4a34:	00a4ea33          	or	s4,s1,a0
    4a38:	3c0a1863          	bnez	s4,4e08 <__muldf3+0x4d4>
    4a3c:	0149d793          	srli	a5,s3,0x14
    4a40:	00c99713          	slli	a4,s3,0xc
    4a44:	7ff7f793          	andi	a5,a5,2047
    4a48:	00000493          	li	s1,0
    4a4c:	00800b13          	li	s6,8
    4a50:	7ff00c13          	li	s8,2047
    4a54:	00200b93          	li	s7,2
    4a58:	000a8f13          	mv	t5,s5
    4a5c:	00c75413          	srli	s0,a4,0xc
    4a60:	01f9d993          	srli	s3,s3,0x1f
    4a64:	f60794e3          	bnez	a5,49cc <__muldf3+0x98>
    4a68:	015467b3          	or	a5,s0,s5
    4a6c:	3c078263          	beqz	a5,4e30 <__muldf3+0x4fc>
    4a70:	4a040063          	beqz	s0,4f10 <__muldf3+0x5dc>
    4a74:	00040513          	mv	a0,s0
    4a78:	110010ef          	jal	5b88 <__clzsi2>
    4a7c:	00050893          	mv	a7,a0
    4a80:	ff550713          	addi	a4,a0,-11
    4a84:	01d00793          	li	a5,29
    4a88:	ff888f13          	addi	t5,a7,-8
    4a8c:	40e787b3          	sub	a5,a5,a4
    4a90:	00fad7b3          	srl	a5,s5,a5
    4a94:	01e41733          	sll	a4,s0,t5
    4a98:	00e7e433          	or	s0,a5,a4
    4a9c:	01ea9f33          	sll	t5,s5,t5
    4aa0:	411c08b3          	sub	a7,s8,a7
    4aa4:	c0d88893          	addi	a7,a7,-1011
    4aa8:	00a00713          	li	a4,10
    4aac:	00000313          	li	t1,0
    4ab0:	00188513          	addi	a0,a7,1
    4ab4:	f56758e3          	bge	a4,s6,4a04 <__muldf3+0xd0>
    4ab8:	00090593          	mv	a1,s2
    4abc:	00200793          	li	a5,2
    4ac0:	32fb8a63          	beq	s7,a5,4df4 <__muldf3+0x4c0>
    4ac4:	00300793          	li	a5,3
    4ac8:	48fb8c63          	beq	s7,a5,4f60 <__muldf3+0x62c>
    4acc:	00100793          	li	a5,1
    4ad0:	00058813          	mv	a6,a1
    4ad4:	46fb9a63          	bne	s7,a5,4f48 <__muldf3+0x614>
    4ad8:	00000793          	li	a5,0
    4adc:	00000693          	li	a3,0
    4ae0:	00000713          	li	a4,0
    4ae4:	02c12083          	lw	ra,44(sp)
    4ae8:	02812403          	lw	s0,40(sp)
    4aec:	01479793          	slli	a5,a5,0x14
    4af0:	00d7e7b3          	or	a5,a5,a3
    4af4:	01f81693          	slli	a3,a6,0x1f
    4af8:	00d7e7b3          	or	a5,a5,a3
    4afc:	02412483          	lw	s1,36(sp)
    4b00:	02012903          	lw	s2,32(sp)
    4b04:	01c12983          	lw	s3,28(sp)
    4b08:	01812a03          	lw	s4,24(sp)
    4b0c:	01412a83          	lw	s5,20(sp)
    4b10:	01012b03          	lw	s6,16(sp)
    4b14:	00c12b83          	lw	s7,12(sp)
    4b18:	00812c03          	lw	s8,8(sp)
    4b1c:	00070513          	mv	a0,a4
    4b20:	00078593          	mv	a1,a5
    4b24:	03010113          	addi	sp,sp,48
    4b28:	00008067          	ret
    4b2c:	01546733          	or	a4,s0,s5
    4b30:	7ffc0893          	addi	a7,s8,2047
    4b34:	30070a63          	beqz	a4,4e48 <__muldf3+0x514>
    4b38:	00001737          	lui	a4,0x1
    4b3c:	01394833          	xor	a6,s2,s3
    4b40:	80070713          	addi	a4,a4,-2048 # 800 <CUSTOM2+0x7a5>
    4b44:	003b6b13          	ori	s6,s6,3
    4b48:	00a00693          	li	a3,10
    4b4c:	00080593          	mv	a1,a6
    4b50:	00ec0533          	add	a0,s8,a4
    4b54:	3966c063          	blt	a3,s6,4ed4 <__muldf3+0x5a0>
    4b58:	00300313          	li	t1,3
    4b5c:	00100613          	li	a2,1
    4b60:	01661633          	sll	a2,a2,s6
    4b64:	53067713          	andi	a4,a2,1328
    4b68:	f4071ae3          	bnez	a4,4abc <__muldf3+0x188>
    4b6c:	24067793          	andi	a5,a2,576
    4b70:	3c079463          	bnez	a5,4f38 <__muldf3+0x604>
    4b74:	08867613          	andi	a2,a2,136
    4b78:	2e061263          	bnez	a2,4e5c <__muldf3+0x528>
    4b7c:	00010fb7          	lui	t6,0x10
    4b80:	ffff8e93          	addi	t4,t6,-1 # ffff <__freertos_irq_stack_top+0x8f7f>
    4b84:	01da77b3          	and	a5,s4,t4
    4b88:	010a5693          	srli	a3,s4,0x10
    4b8c:	01df7eb3          	and	t4,t5,t4
    4b90:	010f5e13          	srli	t3,t5,0x10
    4b94:	03d78733          	mul	a4,a5,t4
    4b98:	03d68333          	mul	t1,a3,t4
    4b9c:	01075593          	srli	a1,a4,0x10
    4ba0:	02fe0633          	mul	a2,t3,a5
    4ba4:	00660633          	add	a2,a2,t1
    4ba8:	00c585b3          	add	a1,a1,a2
    4bac:	03c68f33          	mul	t5,a3,t3
    4bb0:	0065f463          	bgeu	a1,t1,4bb8 <__muldf3+0x284>
    4bb4:	01ff0f33          	add	t5,t5,t6
    4bb8:	000103b7          	lui	t2,0x10
    4bbc:	fff38613          	addi	a2,t2,-1 # ffff <__freertos_irq_stack_top+0x8f7f>
    4bc0:	00c5f333          	and	t1,a1,a2
    4bc4:	01045f93          	srli	t6,s0,0x10
    4bc8:	00c77733          	and	a4,a4,a2
    4bcc:	00c47433          	and	s0,s0,a2
    4bd0:	01031313          	slli	t1,t1,0x10
    4bd4:	028782b3          	mul	t0,a5,s0
    4bd8:	00e30333          	add	t1,t1,a4
    4bdc:	0105d593          	srli	a1,a1,0x10
    4be0:	02868733          	mul	a4,a3,s0
    4be4:	0102d613          	srli	a2,t0,0x10
    4be8:	02ff87b3          	mul	a5,t6,a5
    4bec:	00e787b3          	add	a5,a5,a4
    4bf0:	00f60633          	add	a2,a2,a5
    4bf4:	03f687b3          	mul	a5,a3,t6
    4bf8:	00e67463          	bgeu	a2,a4,4c00 <__muldf3+0x2cc>
    4bfc:	007787b3          	add	a5,a5,t2
    4c00:	00010937          	lui	s2,0x10
    4c04:	fff90993          	addi	s3,s2,-1 # ffff <__freertos_irq_stack_top+0x8f7f>
    4c08:	01367733          	and	a4,a2,s3
    4c0c:	0104d393          	srli	t2,s1,0x10
    4c10:	0134f6b3          	and	a3,s1,s3
    4c14:	0132f2b3          	and	t0,t0,s3
    4c18:	01071713          	slli	a4,a4,0x10
    4c1c:	02de84b3          	mul	s1,t4,a3
    4c20:	00570733          	add	a4,a4,t0
    4c24:	01065613          	srli	a2,a2,0x10
    4c28:	00f60633          	add	a2,a2,a5
    4c2c:	00e585b3          	add	a1,a1,a4
    4c30:	02de02b3          	mul	t0,t3,a3
    4c34:	0104d793          	srli	a5,s1,0x10
    4c38:	03d38eb3          	mul	t4,t2,t4
    4c3c:	01d282b3          	add	t0,t0,t4
    4c40:	005787b3          	add	a5,a5,t0
    4c44:	027e0e33          	mul	t3,t3,t2
    4c48:	01d7f463          	bgeu	a5,t4,4c50 <__muldf3+0x31c>
    4c4c:	012e0e33          	add	t3,t3,s2
    4c50:	000109b7          	lui	s3,0x10
    4c54:	fff98e93          	addi	t4,s3,-1 # ffff <__freertos_irq_stack_top+0x8f7f>
    4c58:	01d7f2b3          	and	t0,a5,t4
    4c5c:	0107d793          	srli	a5,a5,0x10
    4c60:	01c787b3          	add	a5,a5,t3
    4c64:	01d4feb3          	and	t4,s1,t4
    4c68:	01029293          	slli	t0,t0,0x10
    4c6c:	02d40933          	mul	s2,s0,a3
    4c70:	01d282b3          	add	t0,t0,t4
    4c74:	02838433          	mul	s0,t2,s0
    4c78:	01095e13          	srli	t3,s2,0x10
    4c7c:	02df86b3          	mul	a3,t6,a3
    4c80:	008686b3          	add	a3,a3,s0
    4c84:	00de0e33          	add	t3,t3,a3
    4c88:	027f8eb3          	mul	t4,t6,t2
    4c8c:	008e7463          	bgeu	t3,s0,4c94 <__muldf3+0x360>
    4c90:	013e8eb3          	add	t4,t4,s3
    4c94:	00010fb7          	lui	t6,0x10
    4c98:	ffff8f93          	addi	t6,t6,-1 # ffff <__freertos_irq_stack_top+0x8f7f>
    4c9c:	01fe76b3          	and	a3,t3,t6
    4ca0:	01069693          	slli	a3,a3,0x10
    4ca4:	01f97933          	and	s2,s2,t6
    4ca8:	01e585b3          	add	a1,a1,t5
    4cac:	012686b3          	add	a3,a3,s2
    4cb0:	00c68633          	add	a2,a3,a2
    4cb4:	00e5b733          	sltu	a4,a1,a4
    4cb8:	00e60733          	add	a4,a2,a4
    4cbc:	00558f33          	add	t5,a1,t0
    4cc0:	00f707b3          	add	a5,a4,a5
    4cc4:	00bf35b3          	sltu	a1,t5,a1
    4cc8:	00b785b3          	add	a1,a5,a1
    4ccc:	00d636b3          	sltu	a3,a2,a3
    4cd0:	00c73633          	sltu	a2,a4,a2
    4cd4:	00c6e6b3          	or	a3,a3,a2
    4cd8:	00e7b733          	sltu	a4,a5,a4
    4cdc:	010e5e13          	srli	t3,t3,0x10
    4ce0:	00f5b7b3          	sltu	a5,a1,a5
    4ce4:	01c686b3          	add	a3,a3,t3
    4ce8:	00f76733          	or	a4,a4,a5
    4cec:	009f1793          	slli	a5,t5,0x9
    4cf0:	00d70733          	add	a4,a4,a3
    4cf4:	0067e7b3          	or	a5,a5,t1
    4cf8:	01d70733          	add	a4,a4,t4
    4cfc:	00f037b3          	snez	a5,a5
    4d00:	017f5613          	srli	a2,t5,0x17
    4d04:	00971713          	slli	a4,a4,0x9
    4d08:	0175d693          	srli	a3,a1,0x17
    4d0c:	00c7e7b3          	or	a5,a5,a2
    4d10:	00959593          	slli	a1,a1,0x9
    4d14:	00b7ea33          	or	s4,a5,a1
    4d18:	00771793          	slli	a5,a4,0x7
    4d1c:	00d764b3          	or	s1,a4,a3
    4d20:	0207d063          	bgez	a5,4d40 <__muldf3+0x40c>
    4d24:	001a5713          	srli	a4,s4,0x1
    4d28:	001a7793          	andi	a5,s4,1
    4d2c:	01f49693          	slli	a3,s1,0x1f
    4d30:	00f767b3          	or	a5,a4,a5
    4d34:	00d7ea33          	or	s4,a5,a3
    4d38:	0014d493          	srli	s1,s1,0x1
    4d3c:	00050893          	mv	a7,a0
    4d40:	3ff88613          	addi	a2,a7,1023
    4d44:	12c05663          	blez	a2,4e70 <__muldf3+0x53c>
    4d48:	007a7793          	andi	a5,s4,7
    4d4c:	02078063          	beqz	a5,4d6c <__muldf3+0x438>
    4d50:	00fa7793          	andi	a5,s4,15
    4d54:	00400713          	li	a4,4
    4d58:	00e78a63          	beq	a5,a4,4d6c <__muldf3+0x438>
    4d5c:	004a0713          	addi	a4,s4,4
    4d60:	014737b3          	sltu	a5,a4,s4
    4d64:	00f484b3          	add	s1,s1,a5
    4d68:	00070a13          	mv	s4,a4
    4d6c:	00749793          	slli	a5,s1,0x7
    4d70:	0007da63          	bgez	a5,4d84 <__muldf3+0x450>
    4d74:	ff0007b7          	lui	a5,0xff000
    4d78:	fff78793          	addi	a5,a5,-1 # feffffff <__freertos_irq_stack_top+0xfeff8f7f>
    4d7c:	00f4f4b3          	and	s1,s1,a5
    4d80:	40088613          	addi	a2,a7,1024
    4d84:	7fe00793          	li	a5,2046
    4d88:	1cc7c463          	blt	a5,a2,4f50 <__muldf3+0x61c>
    4d8c:	003a5793          	srli	a5,s4,0x3
    4d90:	01d49713          	slli	a4,s1,0x1d
    4d94:	00949693          	slli	a3,s1,0x9
    4d98:	00f76733          	or	a4,a4,a5
    4d9c:	00c6d693          	srli	a3,a3,0xc
    4da0:	7ff67793          	andi	a5,a2,2047
    4da4:	d41ff06f          	j	4ae4 <__muldf3+0x1b0>
    4da8:	00a4ea33          	or	s4,s1,a0
    4dac:	060a0863          	beqz	s4,4e1c <__muldf3+0x4e8>
    4db0:	12048e63          	beqz	s1,4eec <__muldf3+0x5b8>
    4db4:	00048513          	mv	a0,s1
    4db8:	5d1000ef          	jal	5b88 <__clzsi2>
    4dbc:	00050613          	mv	a2,a0
    4dc0:	ff550693          	addi	a3,a0,-11
    4dc4:	01d00713          	li	a4,29
    4dc8:	ff860793          	addi	a5,a2,-8 # 7fff8 <__freertos_irq_stack_top+0x78f78>
    4dcc:	40d70733          	sub	a4,a4,a3
    4dd0:	00e45733          	srl	a4,s0,a4
    4dd4:	00f496b3          	sll	a3,s1,a5
    4dd8:	00d764b3          	or	s1,a4,a3
    4ddc:	00f41a33          	sll	s4,s0,a5
    4de0:	c0d00793          	li	a5,-1011
    4de4:	40c78c33          	sub	s8,a5,a2
    4de8:	00000b13          	li	s6,0
    4dec:	00000b93          	li	s7,0
    4df0:	bc1ff06f          	j	49b0 <__muldf3+0x7c>
    4df4:	00058813          	mv	a6,a1
    4df8:	7ff00793          	li	a5,2047
    4dfc:	00000693          	li	a3,0
    4e00:	00000713          	li	a4,0
    4e04:	ce1ff06f          	j	4ae4 <__muldf3+0x1b0>
    4e08:	00050a13          	mv	s4,a0
    4e0c:	00c00b13          	li	s6,12
    4e10:	7ff00c13          	li	s8,2047
    4e14:	00300b93          	li	s7,3
    4e18:	b99ff06f          	j	49b0 <__muldf3+0x7c>
    4e1c:	00000493          	li	s1,0
    4e20:	00400b13          	li	s6,4
    4e24:	00000c13          	li	s8,0
    4e28:	00100b93          	li	s7,1
    4e2c:	b85ff06f          	j	49b0 <__muldf3+0x7c>
    4e30:	001b6b13          	ori	s6,s6,1
    4e34:	000c0893          	mv	a7,s8
    4e38:	00000413          	li	s0,0
    4e3c:	00000f13          	li	t5,0
    4e40:	00100313          	li	t1,1
    4e44:	bb5ff06f          	j	49f8 <__muldf3+0xc4>
    4e48:	002b6b13          	ori	s6,s6,2
    4e4c:	00000413          	li	s0,0
    4e50:	00000f13          	li	t5,0
    4e54:	00200313          	li	t1,2
    4e58:	ba1ff06f          	j	49f8 <__muldf3+0xc4>
    4e5c:	00040493          	mv	s1,s0
    4e60:	000f0a13          	mv	s4,t5
    4e64:	00030b93          	mv	s7,t1
    4e68:	00098593          	mv	a1,s3
    4e6c:	c51ff06f          	j	4abc <__muldf3+0x188>
    4e70:	00100713          	li	a4,1
    4e74:	10061063          	bnez	a2,4f74 <__muldf3+0x640>
    4e78:	41e88893          	addi	a7,a7,1054
    4e7c:	011a1633          	sll	a2,s4,a7
    4e80:	00c03633          	snez	a2,a2
    4e84:	011498b3          	sll	a7,s1,a7
    4e88:	00ea57b3          	srl	a5,s4,a4
    4e8c:	01166633          	or	a2,a2,a7
    4e90:	00f66633          	or	a2,a2,a5
    4e94:	00767793          	andi	a5,a2,7
    4e98:	00e4d5b3          	srl	a1,s1,a4
    4e9c:	02078063          	beqz	a5,4ebc <__muldf3+0x588>
    4ea0:	00f67793          	andi	a5,a2,15
    4ea4:	00400713          	li	a4,4
    4ea8:	00e78a63          	beq	a5,a4,4ebc <__muldf3+0x588>
    4eac:	00460793          	addi	a5,a2,4
    4eb0:	00c7b633          	sltu	a2,a5,a2
    4eb4:	00c585b3          	add	a1,a1,a2
    4eb8:	00078613          	mv	a2,a5
    4ebc:	00859513          	slli	a0,a1,0x8
    4ec0:	00100793          	li	a5,1
    4ec4:	00000693          	li	a3,0
    4ec8:	00000713          	li	a4,0
    4ecc:	c0054ce3          	bltz	a0,4ae4 <__muldf3+0x1b0>
    4ed0:	10c0006f          	j	4fdc <__muldf3+0x6a8>
    4ed4:	00f00713          	li	a4,15
    4ed8:	12eb1063          	bne	s6,a4,4ff8 <__muldf3+0x6c4>
    4edc:	00000813          	li	a6,0
    4ee0:	000806b7          	lui	a3,0x80
    4ee4:	00000713          	li	a4,0
    4ee8:	bfdff06f          	j	4ae4 <__muldf3+0x1b0>
    4eec:	49d000ef          	jal	5b88 <__clzsi2>
    4ef0:	01550693          	addi	a3,a0,21
    4ef4:	01c00793          	li	a5,28
    4ef8:	02050613          	addi	a2,a0,32
    4efc:	ecd7d4e3          	bge	a5,a3,4dc4 <__muldf3+0x490>
    4f00:	ff850513          	addi	a0,a0,-8
    4f04:	00000a13          	li	s4,0
    4f08:	00a414b3          	sll	s1,s0,a0
    4f0c:	ed5ff06f          	j	4de0 <__muldf3+0x4ac>
    4f10:	000a8513          	mv	a0,s5
    4f14:	475000ef          	jal	5b88 <__clzsi2>
    4f18:	01550713          	addi	a4,a0,21
    4f1c:	01c00793          	li	a5,28
    4f20:	02050893          	addi	a7,a0,32
    4f24:	b6e7d0e3          	bge	a5,a4,4a84 <__muldf3+0x150>
    4f28:	ff850513          	addi	a0,a0,-8
    4f2c:	00000f13          	li	t5,0
    4f30:	00aa9433          	sll	s0,s5,a0
    4f34:	b6dff06f          	j	4aa0 <__muldf3+0x16c>
    4f38:	00000813          	li	a6,0
    4f3c:	7ff00793          	li	a5,2047
    4f40:	000806b7          	lui	a3,0x80
    4f44:	ba1ff06f          	j	4ae4 <__muldf3+0x1b0>
    4f48:	00050893          	mv	a7,a0
    4f4c:	df5ff06f          	j	4d40 <__muldf3+0x40c>
    4f50:	7ff00793          	li	a5,2047
    4f54:	00000693          	li	a3,0
    4f58:	00000713          	li	a4,0
    4f5c:	b89ff06f          	j	4ae4 <__muldf3+0x1b0>
    4f60:	00000813          	li	a6,0
    4f64:	7ff00793          	li	a5,2047
    4f68:	000806b7          	lui	a3,0x80
    4f6c:	00000713          	li	a4,0
    4f70:	b75ff06f          	j	4ae4 <__muldf3+0x1b0>
    4f74:	40c70733          	sub	a4,a4,a2
    4f78:	03800793          	li	a5,56
    4f7c:	b4e7cee3          	blt	a5,a4,4ad8 <__muldf3+0x1a4>
    4f80:	01f00793          	li	a5,31
    4f84:	eee7dae3          	bge	a5,a4,4e78 <__muldf3+0x544>
    4f88:	fe100793          	li	a5,-31
    4f8c:	40c787b3          	sub	a5,a5,a2
    4f90:	02000693          	li	a3,32
    4f94:	00f4d7b3          	srl	a5,s1,a5
    4f98:	00d70863          	beq	a4,a3,4fa8 <__muldf3+0x674>
    4f9c:	43e88893          	addi	a7,a7,1086
    4fa0:	011498b3          	sll	a7,s1,a7
    4fa4:	011a6a33          	or	s4,s4,a7
    4fa8:	01403633          	snez	a2,s4
    4fac:	00f66633          	or	a2,a2,a5
    4fb0:	00767713          	andi	a4,a2,7
    4fb4:	00000693          	li	a3,0
    4fb8:	02070863          	beqz	a4,4fe8 <__muldf3+0x6b4>
    4fbc:	00f67793          	andi	a5,a2,15
    4fc0:	00400713          	li	a4,4
    4fc4:	00000593          	li	a1,0
    4fc8:	00e78a63          	beq	a5,a4,4fdc <__muldf3+0x6a8>
    4fcc:	00460793          	addi	a5,a2,4
    4fd0:	00c7b633          	sltu	a2,a5,a2
    4fd4:	00c035b3          	snez	a1,a2
    4fd8:	00078613          	mv	a2,a5
    4fdc:	00959693          	slli	a3,a1,0x9
    4fe0:	01d59713          	slli	a4,a1,0x1d
    4fe4:	00c6d693          	srli	a3,a3,0xc
    4fe8:	00365613          	srli	a2,a2,0x3
    4fec:	00e66733          	or	a4,a2,a4
    4ff0:	00000793          	li	a5,0
    4ff4:	af1ff06f          	j	4ae4 <__muldf3+0x1b0>
    4ff8:	00040493          	mv	s1,s0
    4ffc:	000a8a13          	mv	s4,s5
    5000:	00300b93          	li	s7,3
    5004:	00098593          	mv	a1,s3
    5008:	ab5ff06f          	j	4abc <__muldf3+0x188>

0000500c <__subdf3>:
    500c:	001007b7          	lui	a5,0x100
    5010:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf8f7f>
    5014:	fe010113          	addi	sp,sp,-32
    5018:	00b7f8b3          	and	a7,a5,a1
    501c:	00d7f833          	and	a6,a5,a3
    5020:	0146d793          	srli	a5,a3,0x14
    5024:	00389893          	slli	a7,a7,0x3
    5028:	00812c23          	sw	s0,24(sp)
    502c:	01312623          	sw	s3,12(sp)
    5030:	01f5d413          	srli	s0,a1,0x1f
    5034:	0145d993          	srli	s3,a1,0x14
    5038:	01d55713          	srli	a4,a0,0x1d
    503c:	00381813          	slli	a6,a6,0x3
    5040:	01d65593          	srli	a1,a2,0x1d
    5044:	00112e23          	sw	ra,28(sp)
    5048:	00912a23          	sw	s1,20(sp)
    504c:	01212823          	sw	s2,16(sp)
    5050:	7ff7ff13          	andi	t5,a5,2047
    5054:	7ff00313          	li	t1,2047
    5058:	01176733          	or	a4,a4,a7
    505c:	7ff9f993          	andi	s3,s3,2047
    5060:	00040e13          	mv	t3,s0
    5064:	00351893          	slli	a7,a0,0x3
    5068:	01f6d693          	srli	a3,a3,0x1f
    506c:	0105e5b3          	or	a1,a1,a6
    5070:	00361e93          	slli	t4,a2,0x3
    5074:	206f0c63          	beq	t5,t1,528c <__subdf3+0x280>
    5078:	0016c693          	xori	a3,a3,1
    507c:	41e987b3          	sub	a5,s3,t5
    5080:	16d40263          	beq	s0,a3,51e4 <__subdf3+0x1d8>
    5084:	00f05ae3          	blez	a5,5898 <__subdf3+0x88c>
    5088:	240f0a63          	beqz	t5,52dc <__subdf3+0x2d0>
    508c:	3c698463          	beq	s3,t1,5454 <__subdf3+0x448>
    5090:	03800693          	li	a3,56
    5094:	00100513          	li	a0,1
    5098:	02f6ce63          	blt	a3,a5,50d4 <__subdf3+0xc8>
    509c:	008006b7          	lui	a3,0x800
    50a0:	00d5e5b3          	or	a1,a1,a3
    50a4:	01f00693          	li	a3,31
    50a8:	4ef6c463          	blt	a3,a5,5590 <__subdf3+0x584>
    50ac:	02000693          	li	a3,32
    50b0:	40f686b3          	sub	a3,a3,a5
    50b4:	00d59533          	sll	a0,a1,a3
    50b8:	00fed633          	srl	a2,t4,a5
    50bc:	00de96b3          	sll	a3,t4,a3
    50c0:	00c56533          	or	a0,a0,a2
    50c4:	00d036b3          	snez	a3,a3
    50c8:	00f5d7b3          	srl	a5,a1,a5
    50cc:	00d56533          	or	a0,a0,a3
    50d0:	40f70733          	sub	a4,a4,a5
    50d4:	40a88533          	sub	a0,a7,a0
    50d8:	00a8b633          	sltu	a2,a7,a0
    50dc:	00050493          	mv	s1,a0
    50e0:	40c70933          	sub	s2,a4,a2
    50e4:	00891793          	slli	a5,s2,0x8
    50e8:	3407d863          	bgez	a5,5438 <__subdf3+0x42c>
    50ec:	008007b7          	lui	a5,0x800
    50f0:	fff78793          	addi	a5,a5,-1 # 7fffff <__freertos_irq_stack_top+0x7f8f7f>
    50f4:	00f97933          	and	s2,s2,a5
    50f8:	2e090663          	beqz	s2,53e4 <__subdf3+0x3d8>
    50fc:	00090513          	mv	a0,s2
    5100:	289000ef          	jal	5b88 <__clzsi2>
    5104:	ff850793          	addi	a5,a0,-8
    5108:	02000693          	li	a3,32
    510c:	40f68733          	sub	a4,a3,a5
    5110:	00e4d733          	srl	a4,s1,a4
    5114:	00f91933          	sll	s2,s2,a5
    5118:	01276733          	or	a4,a4,s2
    511c:	00f494b3          	sll	s1,s1,a5
    5120:	3f37c463          	blt	a5,s3,5508 <__subdf3+0x4fc>
    5124:	413787b3          	sub	a5,a5,s3
    5128:	00178793          	addi	a5,a5,1
    512c:	40f686b3          	sub	a3,a3,a5
    5130:	00d49633          	sll	a2,s1,a3
    5134:	00f4d933          	srl	s2,s1,a5
    5138:	00c03633          	snez	a2,a2
    513c:	00c96633          	or	a2,s2,a2
    5140:	00d716b3          	sll	a3,a4,a3
    5144:	00c6e4b3          	or	s1,a3,a2
    5148:	00f75933          	srl	s2,a4,a5
    514c:	00000993          	li	s3,0
    5150:	0074f793          	andi	a5,s1,7
    5154:	02078063          	beqz	a5,5174 <__subdf3+0x168>
    5158:	00f4f793          	andi	a5,s1,15
    515c:	00400713          	li	a4,4
    5160:	00e78a63          	beq	a5,a4,5174 <__subdf3+0x168>
    5164:	00448793          	addi	a5,s1,4
    5168:	0097b533          	sltu	a0,a5,s1
    516c:	00a90933          	add	s2,s2,a0
    5170:	00078493          	mv	s1,a5
    5174:	00891793          	slli	a5,s2,0x8
    5178:	6c07d063          	bgez	a5,5838 <__subdf3+0x82c>
    517c:	00198793          	addi	a5,s3,1
    5180:	7ff00713          	li	a4,2047
    5184:	24e78663          	beq	a5,a4,53d0 <__subdf3+0x3c4>
    5188:	ff800737          	lui	a4,0xff800
    518c:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8f7f>
    5190:	00e97733          	and	a4,s2,a4
    5194:	7ff7f793          	andi	a5,a5,2047
    5198:	01d71813          	slli	a6,a4,0x1d
    519c:	0034d513          	srli	a0,s1,0x3
    51a0:	00971713          	slli	a4,a4,0x9
    51a4:	00a86833          	or	a6,a6,a0
    51a8:	00c75713          	srli	a4,a4,0xc
    51ac:	00147e13          	andi	t3,s0,1
    51b0:	01c12083          	lw	ra,28(sp)
    51b4:	01812403          	lw	s0,24(sp)
    51b8:	01479793          	slli	a5,a5,0x14
    51bc:	00e7e7b3          	or	a5,a5,a4
    51c0:	01fe1713          	slli	a4,t3,0x1f
    51c4:	00e7e7b3          	or	a5,a5,a4
    51c8:	01412483          	lw	s1,20(sp)
    51cc:	01012903          	lw	s2,16(sp)
    51d0:	00c12983          	lw	s3,12(sp)
    51d4:	00080513          	mv	a0,a6
    51d8:	00078593          	mv	a1,a5
    51dc:	02010113          	addi	sp,sp,32
    51e0:	00008067          	ret
    51e4:	70f05263          	blez	a5,58e8 <__subdf3+0x8dc>
    51e8:	1c0f1663          	bnez	t5,53b4 <__subdf3+0x3a8>
    51ec:	01d5e6b3          	or	a3,a1,t4
    51f0:	26068e63          	beqz	a3,546c <__subdf3+0x460>
    51f4:	fff78693          	addi	a3,a5,-1
    51f8:	46068863          	beqz	a3,5668 <__subdf3+0x65c>
    51fc:	24678c63          	beq	a5,t1,5454 <__subdf3+0x448>
    5200:	03800793          	li	a5,56
    5204:	00100913          	li	s2,1
    5208:	02d7cc63          	blt	a5,a3,5240 <__subdf3+0x234>
    520c:	00068793          	mv	a5,a3
    5210:	01f00693          	li	a3,31
    5214:	48f6ca63          	blt	a3,a5,56a8 <__subdf3+0x69c>
    5218:	02000693          	li	a3,32
    521c:	40f686b3          	sub	a3,a3,a5
    5220:	00d59933          	sll	s2,a1,a3
    5224:	00fed633          	srl	a2,t4,a5
    5228:	00de96b3          	sll	a3,t4,a3
    522c:	00c96933          	or	s2,s2,a2
    5230:	00d036b3          	snez	a3,a3
    5234:	00f5d7b3          	srl	a5,a1,a5
    5238:	00d96933          	or	s2,s2,a3
    523c:	00f70733          	add	a4,a4,a5
    5240:	01190633          	add	a2,s2,a7
    5244:	01263933          	sltu	s2,a2,s2
    5248:	00060493          	mv	s1,a2
    524c:	00e90933          	add	s2,s2,a4
    5250:	00891793          	slli	a5,s2,0x8
    5254:	1e07d263          	bgez	a5,5438 <__subdf3+0x42c>
    5258:	00198993          	addi	s3,s3,1
    525c:	7ff00793          	li	a5,2047
    5260:	16f98863          	beq	s3,a5,53d0 <__subdf3+0x3c4>
    5264:	ff8007b7          	lui	a5,0xff800
    5268:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8f7f>
    526c:	0014f513          	andi	a0,s1,1
    5270:	00f977b3          	and	a5,s2,a5
    5274:	0014d713          	srli	a4,s1,0x1
    5278:	00a76733          	or	a4,a4,a0
    527c:	01f79513          	slli	a0,a5,0x1f
    5280:	00e564b3          	or	s1,a0,a4
    5284:	0017d913          	srli	s2,a5,0x1
    5288:	ec9ff06f          	j	5150 <__subdf3+0x144>
    528c:	01d5e833          	or	a6,a1,t4
    5290:	80198313          	addi	t1,s3,-2047
    5294:	06080863          	beqz	a6,5304 <__subdf3+0x2f8>
    5298:	06d40a63          	beq	s0,a3,530c <__subdf3+0x300>
    529c:	0e030463          	beqz	t1,5384 <__subdf3+0x378>
    52a0:	26098e63          	beqz	s3,551c <__subdf3+0x510>
    52a4:	00361513          	slli	a0,a2,0x3
    52a8:	00355513          	srli	a0,a0,0x3
    52ac:	00068413          	mv	s0,a3
    52b0:	00058713          	mv	a4,a1
    52b4:	01d71813          	slli	a6,a4,0x1d
    52b8:	00a86833          	or	a6,a6,a0
    52bc:	00375713          	srli	a4,a4,0x3
    52c0:	01076733          	or	a4,a4,a6
    52c4:	10070663          	beqz	a4,53d0 <__subdf3+0x3c4>
    52c8:	00000e13          	li	t3,0
    52cc:	7ff00793          	li	a5,2047
    52d0:	00080737          	lui	a4,0x80
    52d4:	00000813          	li	a6,0
    52d8:	ed9ff06f          	j	51b0 <__subdf3+0x1a4>
    52dc:	01d5e6b3          	or	a3,a1,t4
    52e0:	18068663          	beqz	a3,546c <__subdf3+0x460>
    52e4:	fff78693          	addi	a3,a5,-1
    52e8:	3a068263          	beqz	a3,568c <__subdf3+0x680>
    52ec:	16678463          	beq	a5,t1,5454 <__subdf3+0x448>
    52f0:	03800793          	li	a5,56
    52f4:	00100513          	li	a0,1
    52f8:	dcd7cee3          	blt	a5,a3,50d4 <__subdf3+0xc8>
    52fc:	00068793          	mv	a5,a3
    5300:	da5ff06f          	j	50a4 <__subdf3+0x98>
    5304:	0016c693          	xori	a3,a3,1
    5308:	f8d41ae3          	bne	s0,a3,529c <__subdf3+0x290>
    530c:	18030863          	beqz	t1,549c <__subdf3+0x490>
    5310:	2c099063          	bnez	s3,55d0 <__subdf3+0x5c4>
    5314:	7ff00793          	li	a5,2047
    5318:	011766b3          	or	a3,a4,a7
    531c:	48068863          	beqz	a3,57ac <__subdf3+0x7a0>
    5320:	fff78693          	addi	a3,a5,-1
    5324:	34068263          	beqz	a3,5668 <__subdf3+0x65c>
    5328:	7ff00513          	li	a0,2047
    532c:	2aa78263          	beq	a5,a0,55d0 <__subdf3+0x5c4>
    5330:	03800793          	li	a5,56
    5334:	00100913          	li	s2,1
    5338:	02d7ca63          	blt	a5,a3,536c <__subdf3+0x360>
    533c:	01f00793          	li	a5,31
    5340:	4cd7c663          	blt	a5,a3,580c <__subdf3+0x800>
    5344:	02000793          	li	a5,32
    5348:	40d787b3          	sub	a5,a5,a3
    534c:	00f71933          	sll	s2,a4,a5
    5350:	00d8d633          	srl	a2,a7,a3
    5354:	00f897b3          	sll	a5,a7,a5
    5358:	00c96933          	or	s2,s2,a2
    535c:	00f037b3          	snez	a5,a5
    5360:	00d756b3          	srl	a3,a4,a3
    5364:	00f96933          	or	s2,s2,a5
    5368:	00d585b3          	add	a1,a1,a3
    536c:	01d90733          	add	a4,s2,t4
    5370:	01273933          	sltu	s2,a4,s2
    5374:	00070493          	mv	s1,a4
    5378:	00b90933          	add	s2,s2,a1
    537c:	000f0993          	mv	s3,t5
    5380:	ed1ff06f          	j	5250 <__subdf3+0x244>
    5384:	00198793          	addi	a5,s3,1
    5388:	7fe7f793          	andi	a5,a5,2046
    538c:	14079463          	bnez	a5,54d4 <__subdf3+0x4c8>
    5390:	01d5e833          	or	a6,a1,t4
    5394:	011767b3          	or	a5,a4,a7
    5398:	2a099463          	bnez	s3,5640 <__subdf3+0x634>
    539c:	38078e63          	beqz	a5,5738 <__subdf3+0x72c>
    53a0:	3c081063          	bnez	a6,5760 <__subdf3+0x754>
    53a4:	00351513          	slli	a0,a0,0x3
    53a8:	00355913          	srli	s2,a0,0x3
    53ac:	00000793          	li	a5,0
    53b0:	1140006f          	j	54c4 <__subdf3+0x4b8>
    53b4:	0a698063          	beq	s3,t1,5454 <__subdf3+0x448>
    53b8:	03800693          	li	a3,56
    53bc:	00100913          	li	s2,1
    53c0:	e8f6c0e3          	blt	a3,a5,5240 <__subdf3+0x234>
    53c4:	008006b7          	lui	a3,0x800
    53c8:	00d5e5b3          	or	a1,a1,a3
    53cc:	e45ff06f          	j	5210 <__subdf3+0x204>
    53d0:	00147e13          	andi	t3,s0,1
    53d4:	7ff00793          	li	a5,2047
    53d8:	00000713          	li	a4,0
    53dc:	00000813          	li	a6,0
    53e0:	dd1ff06f          	j	51b0 <__subdf3+0x1a4>
    53e4:	00048513          	mv	a0,s1
    53e8:	7a0000ef          	jal	5b88 <__clzsi2>
    53ec:	01850793          	addi	a5,a0,24
    53f0:	01f00693          	li	a3,31
    53f4:	d0f6dae3          	bge	a3,a5,5108 <__subdf3+0xfc>
    53f8:	ff850713          	addi	a4,a0,-8
    53fc:	00e49733          	sll	a4,s1,a4
    5400:	1b37ce63          	blt	a5,s3,55bc <__subdf3+0x5b0>
    5404:	413789b3          	sub	s3,a5,s3
    5408:	00198793          	addi	a5,s3,1
    540c:	42f6de63          	bge	a3,a5,5848 <__subdf3+0x83c>
    5410:	fe198993          	addi	s3,s3,-31
    5414:	02000693          	li	a3,32
    5418:	013754b3          	srl	s1,a4,s3
    541c:	00d78c63          	beq	a5,a3,5434 <__subdf3+0x428>
    5420:	04000693          	li	a3,64
    5424:	40f687b3          	sub	a5,a3,a5
    5428:	00f71733          	sll	a4,a4,a5
    542c:	00e03733          	snez	a4,a4
    5430:	00e4e4b3          	or	s1,s1,a4
    5434:	00000993          	li	s3,0
    5438:	0074f793          	andi	a5,s1,7
    543c:	d0079ee3          	bnez	a5,5158 <__subdf3+0x14c>
    5440:	00098793          	mv	a5,s3
    5444:	0034d513          	srli	a0,s1,0x3
    5448:	00090713          	mv	a4,s2
    544c:	0280006f          	j	5474 <__subdf3+0x468>
    5450:	e6081ce3          	bnez	a6,52c8 <__subdf3+0x2bc>
    5454:	00351513          	slli	a0,a0,0x3
    5458:	01d71813          	slli	a6,a4,0x1d
    545c:	00355513          	srli	a0,a0,0x3
    5460:	00a86833          	or	a6,a6,a0
    5464:	00375713          	srli	a4,a4,0x3
    5468:	e59ff06f          	j	52c0 <__subdf3+0x2b4>
    546c:	00351513          	slli	a0,a0,0x3
    5470:	00355513          	srli	a0,a0,0x3
    5474:	01d71813          	slli	a6,a4,0x1d
    5478:	7ff00693          	li	a3,2047
    547c:	00a86833          	or	a6,a6,a0
    5480:	00375713          	srli	a4,a4,0x3
    5484:	e2d78ee3          	beq	a5,a3,52c0 <__subdf3+0x2b4>
    5488:	00c71713          	slli	a4,a4,0xc
    548c:	00c75713          	srli	a4,a4,0xc
    5490:	7ff7f793          	andi	a5,a5,2047
    5494:	00147e13          	andi	t3,s0,1
    5498:	d19ff06f          	j	51b0 <__subdf3+0x1a4>
    549c:	00198693          	addi	a3,s3,1
    54a0:	7fe6f793          	andi	a5,a3,2046
    54a4:	12079e63          	bnez	a5,55e0 <__subdf3+0x5d4>
    54a8:	011767b3          	or	a5,a4,a7
    54ac:	24099a63          	bnez	s3,5700 <__subdf3+0x6f4>
    54b0:	30078663          	beqz	a5,57bc <__subdf3+0x7b0>
    54b4:	01d5e7b3          	or	a5,a1,t4
    54b8:	30079a63          	bnez	a5,57cc <__subdf3+0x7c0>
    54bc:	00351513          	slli	a0,a0,0x3
    54c0:	00355913          	srli	s2,a0,0x3
    54c4:	01d71813          	slli	a6,a4,0x1d
    54c8:	01286833          	or	a6,a6,s2
    54cc:	00375713          	srli	a4,a4,0x3
    54d0:	fb9ff06f          	j	5488 <__subdf3+0x47c>
    54d4:	41d88833          	sub	a6,a7,t4
    54d8:	0108b7b3          	sltu	a5,a7,a6
    54dc:	40b70933          	sub	s2,a4,a1
    54e0:	40f90933          	sub	s2,s2,a5
    54e4:	00891793          	slli	a5,s2,0x8
    54e8:	00080493          	mv	s1,a6
    54ec:	1207c263          	bltz	a5,5610 <__subdf3+0x604>
    54f0:	01286833          	or	a6,a6,s2
    54f4:	c00812e3          	bnez	a6,50f8 <__subdf3+0xec>
    54f8:	00000e13          	li	t3,0
    54fc:	00000793          	li	a5,0
    5500:	00000713          	li	a4,0
    5504:	cadff06f          	j	51b0 <__subdf3+0x1a4>
    5508:	ff800937          	lui	s2,0xff800
    550c:	fff90913          	addi	s2,s2,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8f7f>
    5510:	40f989b3          	sub	s3,s3,a5
    5514:	01277933          	and	s2,a4,s2
    5518:	c39ff06f          	j	5150 <__subdf3+0x144>
    551c:	7ff00793          	li	a5,2047
    5520:	01176533          	or	a0,a4,a7
    5524:	10050463          	beqz	a0,562c <__subdf3+0x620>
    5528:	fff78813          	addi	a6,a5,-1
    552c:	1e080263          	beqz	a6,5710 <__subdf3+0x704>
    5530:	7ff00513          	li	a0,2047
    5534:	d6a788e3          	beq	a5,a0,52a4 <__subdf3+0x298>
    5538:	03800793          	li	a5,56
    553c:	00068413          	mv	s0,a3
    5540:	00100513          	li	a0,1
    5544:	0307ca63          	blt	a5,a6,5578 <__subdf3+0x56c>
    5548:	01f00793          	li	a5,31
    554c:	1907c463          	blt	a5,a6,56d4 <__subdf3+0x6c8>
    5550:	02000793          	li	a5,32
    5554:	410787b3          	sub	a5,a5,a6
    5558:	00f71533          	sll	a0,a4,a5
    555c:	0108d6b3          	srl	a3,a7,a6
    5560:	00f897b3          	sll	a5,a7,a5
    5564:	00d56533          	or	a0,a0,a3
    5568:	00f037b3          	snez	a5,a5
    556c:	01075833          	srl	a6,a4,a6
    5570:	00f56533          	or	a0,a0,a5
    5574:	410585b3          	sub	a1,a1,a6
    5578:	40ae8533          	sub	a0,t4,a0
    557c:	00aeb733          	sltu	a4,t4,a0
    5580:	00050493          	mv	s1,a0
    5584:	40e58933          	sub	s2,a1,a4
    5588:	000f0993          	mv	s3,t5
    558c:	b59ff06f          	j	50e4 <__subdf3+0xd8>
    5590:	fe078693          	addi	a3,a5,-32
    5594:	02000613          	li	a2,32
    5598:	00d5d6b3          	srl	a3,a1,a3
    559c:	00c78a63          	beq	a5,a2,55b0 <__subdf3+0x5a4>
    55a0:	04000613          	li	a2,64
    55a4:	40f607b3          	sub	a5,a2,a5
    55a8:	00f597b3          	sll	a5,a1,a5
    55ac:	00feeeb3          	or	t4,t4,a5
    55b0:	01d03533          	snez	a0,t4
    55b4:	00d56533          	or	a0,a0,a3
    55b8:	b1dff06f          	j	50d4 <__subdf3+0xc8>
    55bc:	ff8006b7          	lui	a3,0xff800
    55c0:	fff68693          	addi	a3,a3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8f7f>
    55c4:	40f987b3          	sub	a5,s3,a5
    55c8:	00d77733          	and	a4,a4,a3
    55cc:	ef9ff06f          	j	54c4 <__subdf3+0x4b8>
    55d0:	00361513          	slli	a0,a2,0x3
    55d4:	00355513          	srli	a0,a0,0x3
    55d8:	00058713          	mv	a4,a1
    55dc:	cd9ff06f          	j	52b4 <__subdf3+0x2a8>
    55e0:	7ff00793          	li	a5,2047
    55e4:	def686e3          	beq	a3,a5,53d0 <__subdf3+0x3c4>
    55e8:	01d88eb3          	add	t4,a7,t4
    55ec:	011eb633          	sltu	a2,t4,a7
    55f0:	00b707b3          	add	a5,a4,a1
    55f4:	00c787b3          	add	a5,a5,a2
    55f8:	01f79513          	slli	a0,a5,0x1f
    55fc:	001ede93          	srli	t4,t4,0x1
    5600:	01d564b3          	or	s1,a0,t4
    5604:	0017d913          	srli	s2,a5,0x1
    5608:	00068993          	mv	s3,a3
    560c:	b45ff06f          	j	5150 <__subdf3+0x144>
    5610:	411e8633          	sub	a2,t4,a7
    5614:	40e587b3          	sub	a5,a1,a4
    5618:	00ceb733          	sltu	a4,t4,a2
    561c:	00060493          	mv	s1,a2
    5620:	40e78933          	sub	s2,a5,a4
    5624:	00068413          	mv	s0,a3
    5628:	ad1ff06f          	j	50f8 <__subdf3+0xec>
    562c:	00361613          	slli	a2,a2,0x3
    5630:	00365513          	srli	a0,a2,0x3
    5634:	00068413          	mv	s0,a3
    5638:	00058713          	mv	a4,a1
    563c:	e39ff06f          	j	5474 <__subdf3+0x468>
    5640:	e00798e3          	bnez	a5,5450 <__subdf3+0x444>
    5644:	22080663          	beqz	a6,5870 <__subdf3+0x864>
    5648:	0035d713          	srli	a4,a1,0x3
    564c:	00361613          	slli	a2,a2,0x3
    5650:	01d59593          	slli	a1,a1,0x1d
    5654:	00b76733          	or	a4,a4,a1
    5658:	00365613          	srli	a2,a2,0x3
    565c:	00c76733          	or	a4,a4,a2
    5660:	00068413          	mv	s0,a3
    5664:	c61ff06f          	j	52c4 <__subdf3+0x2b8>
    5668:	01d88eb3          	add	t4,a7,t4
    566c:	00b705b3          	add	a1,a4,a1
    5670:	011eb633          	sltu	a2,t4,a7
    5674:	00c58933          	add	s2,a1,a2
    5678:	00891793          	slli	a5,s2,0x8
    567c:	000e8493          	mv	s1,t4
    5680:	0a07d863          	bgez	a5,5730 <__subdf3+0x724>
    5684:	00200993          	li	s3,2
    5688:	bddff06f          	j	5264 <__subdf3+0x258>
    568c:	41d88eb3          	sub	t4,a7,t4
    5690:	40b705b3          	sub	a1,a4,a1
    5694:	01d8b633          	sltu	a2,a7,t4
    5698:	000e8493          	mv	s1,t4
    569c:	40c58933          	sub	s2,a1,a2
    56a0:	00100993          	li	s3,1
    56a4:	a41ff06f          	j	50e4 <__subdf3+0xd8>
    56a8:	fe078693          	addi	a3,a5,-32
    56ac:	02000613          	li	a2,32
    56b0:	00d5d6b3          	srl	a3,a1,a3
    56b4:	00c78a63          	beq	a5,a2,56c8 <__subdf3+0x6bc>
    56b8:	04000613          	li	a2,64
    56bc:	40f607b3          	sub	a5,a2,a5
    56c0:	00f597b3          	sll	a5,a1,a5
    56c4:	00feeeb3          	or	t4,t4,a5
    56c8:	01d03933          	snez	s2,t4
    56cc:	00d96933          	or	s2,s2,a3
    56d0:	b71ff06f          	j	5240 <__subdf3+0x234>
    56d4:	fe080793          	addi	a5,a6,-32
    56d8:	02000693          	li	a3,32
    56dc:	00f757b3          	srl	a5,a4,a5
    56e0:	00d80a63          	beq	a6,a3,56f4 <__subdf3+0x6e8>
    56e4:	04000693          	li	a3,64
    56e8:	410686b3          	sub	a3,a3,a6
    56ec:	00d71733          	sll	a4,a4,a3
    56f0:	00e8e8b3          	or	a7,a7,a4
    56f4:	01103533          	snez	a0,a7
    56f8:	00f56533          	or	a0,a0,a5
    56fc:	e7dff06f          	j	5578 <__subdf3+0x56c>
    5700:	ec0788e3          	beqz	a5,55d0 <__subdf3+0x5c4>
    5704:	01d5eeb3          	or	t4,a1,t4
    5708:	bc0e90e3          	bnez	t4,52c8 <__subdf3+0x2bc>
    570c:	d49ff06f          	j	5454 <__subdf3+0x448>
    5710:	411e8633          	sub	a2,t4,a7
    5714:	40e585b3          	sub	a1,a1,a4
    5718:	00ceb733          	sltu	a4,t4,a2
    571c:	00060493          	mv	s1,a2
    5720:	40e58933          	sub	s2,a1,a4
    5724:	00068413          	mv	s0,a3
    5728:	00100993          	li	s3,1
    572c:	9b9ff06f          	j	50e4 <__subdf3+0xd8>
    5730:	00100793          	li	a5,1
    5734:	d11ff06f          	j	5444 <__subdf3+0x438>
    5738:	dc0800e3          	beqz	a6,54f8 <__subdf3+0x4ec>
    573c:	00361613          	slli	a2,a2,0x3
    5740:	00365793          	srli	a5,a2,0x3
    5744:	01d59813          	slli	a6,a1,0x1d
    5748:	00959713          	slli	a4,a1,0x9
    574c:	00f86833          	or	a6,a6,a5
    5750:	00c75713          	srli	a4,a4,0xc
    5754:	00068e13          	mv	t3,a3
    5758:	00000793          	li	a5,0
    575c:	a55ff06f          	j	51b0 <__subdf3+0x1a4>
    5760:	41d88933          	sub	s2,a7,t4
    5764:	0128b7b3          	sltu	a5,a7,s2
    5768:	40b70633          	sub	a2,a4,a1
    576c:	40f60633          	sub	a2,a2,a5
    5770:	00861793          	slli	a5,a2,0x8
    5774:	0e07d263          	bgez	a5,5858 <__subdf3+0x84c>
    5778:	411e8633          	sub	a2,t4,a7
    577c:	40e58733          	sub	a4,a1,a4
    5780:	00cebeb3          	sltu	t4,t4,a2
    5784:	41d70733          	sub	a4,a4,t4
    5788:	00871793          	slli	a5,a4,0x8
    578c:	00060493          	mv	s1,a2
    5790:	1207de63          	bgez	a5,58cc <__subdf3+0x8c0>
    5794:	ff8007b7          	lui	a5,0xff800
    5798:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8f7f>
    579c:	00f77733          	and	a4,a4,a5
    57a0:	00068413          	mv	s0,a3
    57a4:	00100793          	li	a5,1
    57a8:	9f1ff06f          	j	5198 <__subdf3+0x18c>
    57ac:	00361613          	slli	a2,a2,0x3
    57b0:	00365513          	srli	a0,a2,0x3
    57b4:	00058713          	mv	a4,a1
    57b8:	cbdff06f          	j	5474 <__subdf3+0x468>
    57bc:	00361613          	slli	a2,a2,0x3
    57c0:	00365913          	srli	s2,a2,0x3
    57c4:	00058713          	mv	a4,a1
    57c8:	cfdff06f          	j	54c4 <__subdf3+0x4b8>
    57cc:	01d886b3          	add	a3,a7,t4
    57d0:	00b707b3          	add	a5,a4,a1
    57d4:	0116b633          	sltu	a2,a3,a7
    57d8:	00c787b3          	add	a5,a5,a2
    57dc:	00879713          	slli	a4,a5,0x8
    57e0:	0036d813          	srli	a6,a3,0x3
    57e4:	08075e63          	bgez	a4,5880 <__subdf3+0x874>
    57e8:	ff800737          	lui	a4,0xff800
    57ec:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8f7f>
    57f0:	00e7f7b3          	and	a5,a5,a4
    57f4:	01d79713          	slli	a4,a5,0x1d
    57f8:	00979793          	slli	a5,a5,0x9
    57fc:	01076833          	or	a6,a4,a6
    5800:	00c7d713          	srli	a4,a5,0xc
    5804:	00100793          	li	a5,1
    5808:	9a9ff06f          	j	51b0 <__subdf3+0x1a4>
    580c:	fe068793          	addi	a5,a3,-32
    5810:	02000613          	li	a2,32
    5814:	00f757b3          	srl	a5,a4,a5
    5818:	00c68a63          	beq	a3,a2,582c <__subdf3+0x820>
    581c:	04000613          	li	a2,64
    5820:	40d606b3          	sub	a3,a2,a3
    5824:	00d71733          	sll	a4,a4,a3
    5828:	00e8e8b3          	or	a7,a7,a4
    582c:	01103933          	snez	s2,a7
    5830:	00f96933          	or	s2,s2,a5
    5834:	b39ff06f          	j	536c <__subdf3+0x360>
    5838:	0034d513          	srli	a0,s1,0x3
    583c:	00098793          	mv	a5,s3
    5840:	00090713          	mv	a4,s2
    5844:	c31ff06f          	j	5474 <__subdf3+0x468>
    5848:	02000693          	li	a3,32
    584c:	40f686b3          	sub	a3,a3,a5
    5850:	00000613          	li	a2,0
    5854:	8e9ff06f          	j	513c <__subdf3+0x130>
    5858:	00c96833          	or	a6,s2,a2
    585c:	c8080ee3          	beqz	a6,54f8 <__subdf3+0x4ec>
    5860:	00395913          	srli	s2,s2,0x3
    5864:	00000793          	li	a5,0
    5868:	00060713          	mv	a4,a2
    586c:	c59ff06f          	j	54c4 <__subdf3+0x4b8>
    5870:	00000e13          	li	t3,0
    5874:	7ff00793          	li	a5,2047
    5878:	00080737          	lui	a4,0x80
    587c:	935ff06f          	j	51b0 <__subdf3+0x1a4>
    5880:	01d79713          	slli	a4,a5,0x1d
    5884:	00979793          	slli	a5,a5,0x9
    5888:	01076833          	or	a6,a4,a6
    588c:	00c7d713          	srli	a4,a5,0xc
    5890:	00000793          	li	a5,0
    5894:	91dff06f          	j	51b0 <__subdf3+0x1a4>
    5898:	ae0786e3          	beqz	a5,5384 <__subdf3+0x378>
    589c:	413f0833          	sub	a6,t5,s3
    58a0:	00080793          	mv	a5,a6
    58a4:	c6098ee3          	beqz	s3,5520 <__subdf3+0x514>
    58a8:	03800793          	li	a5,56
    58ac:	0107ca63          	blt	a5,a6,58c0 <__subdf3+0x8b4>
    58b0:	008007b7          	lui	a5,0x800
    58b4:	00f76733          	or	a4,a4,a5
    58b8:	00068413          	mv	s0,a3
    58bc:	c8dff06f          	j	5548 <__subdf3+0x53c>
    58c0:	00068413          	mv	s0,a3
    58c4:	00100513          	li	a0,1
    58c8:	cb1ff06f          	j	5578 <__subdf3+0x56c>
    58cc:	01d71813          	slli	a6,a4,0x1d
    58d0:	00365613          	srli	a2,a2,0x3
    58d4:	00c86833          	or	a6,a6,a2
    58d8:	00375713          	srli	a4,a4,0x3
    58dc:	00000793          	li	a5,0
    58e0:	00068413          	mv	s0,a3
    58e4:	ba5ff06f          	j	5488 <__subdf3+0x47c>
    58e8:	ba078ae3          	beqz	a5,549c <__subdf3+0x490>
    58ec:	413f06b3          	sub	a3,t5,s3
    58f0:	00099663          	bnez	s3,58fc <__subdf3+0x8f0>
    58f4:	00068793          	mv	a5,a3
    58f8:	a21ff06f          	j	5318 <__subdf3+0x30c>
    58fc:	03800793          	li	a5,56
    5900:	00100913          	li	s2,1
    5904:	a6d7c4e3          	blt	a5,a3,536c <__subdf3+0x360>
    5908:	008007b7          	lui	a5,0x800
    590c:	00f76733          	or	a4,a4,a5
    5910:	a2dff06f          	j	533c <__subdf3+0x330>

00005914 <__fixdfsi>:
    5914:	0145d793          	srli	a5,a1,0x14
    5918:	001006b7          	lui	a3,0x100
    591c:	fff68713          	addi	a4,a3,-1 # fffff <__freertos_irq_stack_top+0xf8f7f>
    5920:	7ff7f793          	andi	a5,a5,2047
    5924:	3fe00613          	li	a2,1022
    5928:	00b77733          	and	a4,a4,a1
    592c:	01f5d593          	srli	a1,a1,0x1f
    5930:	00f65e63          	bge	a2,a5,594c <__fixdfsi+0x38>
    5934:	41d00613          	li	a2,1053
    5938:	00f65e63          	bge	a2,a5,5954 <__fixdfsi+0x40>
    593c:	80000537          	lui	a0,0x80000
    5940:	fff50513          	addi	a0,a0,-1 # 7fffffff <__freertos_irq_stack_top+0x7fff8f7f>
    5944:	00a58533          	add	a0,a1,a0
    5948:	00008067          	ret
    594c:	00000513          	li	a0,0
    5950:	00008067          	ret
    5954:	43300613          	li	a2,1075
    5958:	40f60633          	sub	a2,a2,a5
    595c:	01f00813          	li	a6,31
    5960:	00d76733          	or	a4,a4,a3
    5964:	02c85063          	bge	a6,a2,5984 <__fixdfsi+0x70>
    5968:	41300693          	li	a3,1043
    596c:	40f687b3          	sub	a5,a3,a5
    5970:	00f75733          	srl	a4,a4,a5
    5974:	40e00533          	neg	a0,a4
    5978:	fc059ce3          	bnez	a1,5950 <__fixdfsi+0x3c>
    597c:	00070513          	mv	a0,a4
    5980:	00008067          	ret
    5984:	bed78793          	addi	a5,a5,-1043 # 7ffbed <__freertos_irq_stack_top+0x7f8b6d>
    5988:	00f71733          	sll	a4,a4,a5
    598c:	00c55533          	srl	a0,a0,a2
    5990:	00a76733          	or	a4,a4,a0
    5994:	fe1ff06f          	j	5974 <__fixdfsi+0x60>

00005998 <__fixunsdfsi>:
    5998:	0145d793          	srli	a5,a1,0x14
    599c:	00100637          	lui	a2,0x100
    59a0:	fff60713          	addi	a4,a2,-1 # fffff <__freertos_irq_stack_top+0xf8f7f>
    59a4:	7ff7f793          	andi	a5,a5,2047
    59a8:	3fe00813          	li	a6,1022
    59ac:	00050693          	mv	a3,a0
    59b0:	00b77733          	and	a4,a4,a1
    59b4:	00000513          	li	a0,0
    59b8:	01f5d593          	srli	a1,a1,0x1f
    59bc:	00f85463          	bge	a6,a5,59c4 <__fixunsdfsi+0x2c>
    59c0:	00058463          	beqz	a1,59c8 <__fixunsdfsi+0x30>
    59c4:	00008067          	ret
    59c8:	41e00593          	li	a1,1054
    59cc:	fff00513          	li	a0,-1
    59d0:	fef5cae3          	blt	a1,a5,59c4 <__fixunsdfsi+0x2c>
    59d4:	43300593          	li	a1,1075
    59d8:	40f585b3          	sub	a1,a1,a5
    59dc:	01f00513          	li	a0,31
    59e0:	00c76733          	or	a4,a4,a2
    59e4:	00b54c63          	blt	a0,a1,59fc <__fixunsdfsi+0x64>
    59e8:	bed78793          	addi	a5,a5,-1043
    59ec:	00f71733          	sll	a4,a4,a5
    59f0:	00b6d533          	srl	a0,a3,a1
    59f4:	00a76533          	or	a0,a4,a0
    59f8:	00008067          	ret
    59fc:	41300513          	li	a0,1043
    5a00:	40f50533          	sub	a0,a0,a5
    5a04:	00a75533          	srl	a0,a4,a0
    5a08:	00008067          	ret

00005a0c <__floatsidf>:
    5a0c:	ff010113          	addi	sp,sp,-16
    5a10:	00112623          	sw	ra,12(sp)
    5a14:	00812423          	sw	s0,8(sp)
    5a18:	00912223          	sw	s1,4(sp)
    5a1c:	04050a63          	beqz	a0,5a70 <__floatsidf+0x64>
    5a20:	41f55713          	srai	a4,a0,0x1f
    5a24:	00a744b3          	xor	s1,a4,a0
    5a28:	40e484b3          	sub	s1,s1,a4
    5a2c:	00050793          	mv	a5,a0
    5a30:	00048513          	mv	a0,s1
    5a34:	01f7d413          	srli	s0,a5,0x1f
    5a38:	150000ef          	jal	5b88 <__clzsi2>
    5a3c:	41e00793          	li	a5,1054
    5a40:	40a787b3          	sub	a5,a5,a0
    5a44:	00a00713          	li	a4,10
    5a48:	7ff7f793          	andi	a5,a5,2047
    5a4c:	06a74063          	blt	a4,a0,5aac <__floatsidf+0xa0>
    5a50:	00b00713          	li	a4,11
    5a54:	40a70733          	sub	a4,a4,a0
    5a58:	00e4d733          	srl	a4,s1,a4
    5a5c:	01550513          	addi	a0,a0,21
    5a60:	00c71713          	slli	a4,a4,0xc
    5a64:	00a494b3          	sll	s1,s1,a0
    5a68:	00c75713          	srli	a4,a4,0xc
    5a6c:	0140006f          	j	5a80 <__floatsidf+0x74>
    5a70:	00000413          	li	s0,0
    5a74:	00000793          	li	a5,0
    5a78:	00000713          	li	a4,0
    5a7c:	00000493          	li	s1,0
    5a80:	01479793          	slli	a5,a5,0x14
    5a84:	01f41413          	slli	s0,s0,0x1f
    5a88:	00e7e7b3          	or	a5,a5,a4
    5a8c:	00c12083          	lw	ra,12(sp)
    5a90:	0087e7b3          	or	a5,a5,s0
    5a94:	00812403          	lw	s0,8(sp)
    5a98:	00048513          	mv	a0,s1
    5a9c:	00078593          	mv	a1,a5
    5aa0:	00412483          	lw	s1,4(sp)
    5aa4:	01010113          	addi	sp,sp,16
    5aa8:	00008067          	ret
    5aac:	ff550513          	addi	a0,a0,-11
    5ab0:	00a49733          	sll	a4,s1,a0
    5ab4:	00c71713          	slli	a4,a4,0xc
    5ab8:	00c75713          	srli	a4,a4,0xc
    5abc:	00000493          	li	s1,0
    5ac0:	fc1ff06f          	j	5a80 <__floatsidf+0x74>

00005ac4 <__floatunsidf>:
    5ac4:	ff010113          	addi	sp,sp,-16
    5ac8:	00812423          	sw	s0,8(sp)
    5acc:	00112623          	sw	ra,12(sp)
    5ad0:	00050413          	mv	s0,a0
    5ad4:	04050c63          	beqz	a0,5b2c <__floatunsidf+0x68>
    5ad8:	0b0000ef          	jal	5b88 <__clzsi2>
    5adc:	41e00793          	li	a5,1054
    5ae0:	40a787b3          	sub	a5,a5,a0
    5ae4:	00a00713          	li	a4,10
    5ae8:	7ff7f793          	andi	a5,a5,2047
    5aec:	06a74463          	blt	a4,a0,5b54 <__floatunsidf+0x90>
    5af0:	00b00713          	li	a4,11
    5af4:	40a70733          	sub	a4,a4,a0
    5af8:	01550513          	addi	a0,a0,21
    5afc:	00e45733          	srl	a4,s0,a4
    5b00:	00a41433          	sll	s0,s0,a0
    5b04:	00c12083          	lw	ra,12(sp)
    5b08:	00040513          	mv	a0,s0
    5b0c:	00c71713          	slli	a4,a4,0xc
    5b10:	00812403          	lw	s0,8(sp)
    5b14:	00c75713          	srli	a4,a4,0xc
    5b18:	01479793          	slli	a5,a5,0x14
    5b1c:	00e7e7b3          	or	a5,a5,a4
    5b20:	00078593          	mv	a1,a5
    5b24:	01010113          	addi	sp,sp,16
    5b28:	00008067          	ret
    5b2c:	00c12083          	lw	ra,12(sp)
    5b30:	00040513          	mv	a0,s0
    5b34:	00000793          	li	a5,0
    5b38:	00812403          	lw	s0,8(sp)
    5b3c:	00000713          	li	a4,0
    5b40:	01479793          	slli	a5,a5,0x14
    5b44:	00e7e7b3          	or	a5,a5,a4
    5b48:	00078593          	mv	a1,a5
    5b4c:	01010113          	addi	sp,sp,16
    5b50:	00008067          	ret
    5b54:	ff550513          	addi	a0,a0,-11
    5b58:	00a41733          	sll	a4,s0,a0
    5b5c:	00000413          	li	s0,0
    5b60:	00c12083          	lw	ra,12(sp)
    5b64:	00040513          	mv	a0,s0
    5b68:	00c71713          	slli	a4,a4,0xc
    5b6c:	00812403          	lw	s0,8(sp)
    5b70:	00c75713          	srli	a4,a4,0xc
    5b74:	01479793          	slli	a5,a5,0x14
    5b78:	00e7e7b3          	or	a5,a5,a4
    5b7c:	00078593          	mv	a1,a5
    5b80:	01010113          	addi	sp,sp,16
    5b84:	00008067          	ret

00005b88 <__clzsi2>:
    5b88:	000107b7          	lui	a5,0x10
    5b8c:	02f57a63          	bgeu	a0,a5,5bc0 <__clzsi2+0x38>
    5b90:	10053793          	sltiu	a5,a0,256
    5b94:	0017b793          	seqz	a5,a5
    5b98:	00379793          	slli	a5,a5,0x3
    5b9c:	02000713          	li	a4,32
    5ba0:	40f70733          	sub	a4,a4,a5
    5ba4:	00f55533          	srl	a0,a0,a5
    5ba8:	00000797          	auipc	a5,0x0
    5bac:	32078793          	addi	a5,a5,800 # 5ec8 <__clz_tab>
    5bb0:	00a787b3          	add	a5,a5,a0
    5bb4:	0007c503          	lbu	a0,0(a5)
    5bb8:	40a70533          	sub	a0,a4,a0
    5bbc:	00008067          	ret
    5bc0:	010007b7          	lui	a5,0x1000
    5bc4:	02f57463          	bgeu	a0,a5,5bec <__clzsi2+0x64>
    5bc8:	01000793          	li	a5,16
    5bcc:	00f55533          	srl	a0,a0,a5
    5bd0:	00000797          	auipc	a5,0x0
    5bd4:	2f878793          	addi	a5,a5,760 # 5ec8 <__clz_tab>
    5bd8:	00a787b3          	add	a5,a5,a0
    5bdc:	0007c503          	lbu	a0,0(a5)
    5be0:	01000713          	li	a4,16
    5be4:	40a70533          	sub	a0,a4,a0
    5be8:	00008067          	ret
    5bec:	01800793          	li	a5,24
    5bf0:	00f55533          	srl	a0,a0,a5
    5bf4:	00000797          	auipc	a5,0x0
    5bf8:	2d478793          	addi	a5,a5,724 # 5ec8 <__clz_tab>
    5bfc:	00a787b3          	add	a5,a5,a0
    5c00:	0007c503          	lbu	a0,0(a5)
    5c04:	00800713          	li	a4,8
    5c08:	40a70533          	sub	a0,a4,a0
    5c0c:	00008067          	ret
