
build/gpioDemo.elf:     file format elf32-littleriscv


Disassembly of section .init:

00001000 <_start>:

_start:
#ifdef USE_GP
.option push
.option norelax
	la gp, __global_pointer$
    1000:	00001197          	auipc	gp,0x1
    1004:	f3818193          	addi	gp,gp,-200 # 1f38 <__global_pointer$>
.global smp_lottery_target
.global smp_lottery_lock
.global smp_slave


  sw x0, smp_lottery_lock, a1
    1008:	8201a023          	sw	zero,-2016(gp) # 1758 <smp_lottery_lock>

0000100c <smp_tyranny>:

smp_tyranny:
  csrr a0, mhartid
    100c:	f1402573          	csrr	a0,mhartid
  beqz a0, init
    1010:	02050e63          	beqz	a0,104c <init>

00001014 <smp_slave>:

smp_slave:
	lw a0, smp_lottery_lock
    1014:	8201a503          	lw	a0,-2016(gp) # 1758 <smp_lottery_lock>
	beqz a0, smp_slave
    1018:	fe050ee3          	beqz	a0,1014 <smp_slave>

	fence r, r
    101c:	0220000f          	fence	r,r
    1020:	0000100f          	.word	0x0000100f
	//li a1, -1
	//amoadd.w x0, a1,(a0)

	.word(0x100F) //i$ flush
	lw a5, smp_lottery_target
    1024:	81c1a783          	lw	a5,-2020(gp) # 1754 <__bss_start>
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
    1038:	80a1ae23          	sw	a0,-2020(gp) # 1754 <__bss_start>
	fence w, w
    103c:	0110000f          	fence	w,w
	li a0, 1
    1040:	00100513          	li	a0,1
	sw a0, smp_lottery_lock, a1
    1044:	82a1a023          	sw	a0,-2016(gp) # 1758 <smp_lottery_lock>
    ret
    1048:	00008067          	ret

0000104c <init>:
#endif

init:
	la sp, _sp
    104c:	00001117          	auipc	sp,0x1
    1050:	71410113          	addi	sp,sp,1812 # 2760 <__freertos_irq_stack_top>

	/* Load data section */
	la a0, _data_lma
    1054:	00000517          	auipc	a0,0x0
    1058:	5bc50513          	addi	a0,a0,1468 # 1610 <_data>
	la a1, _data
    105c:	00000597          	auipc	a1,0x0
    1060:	5b458593          	addi	a1,a1,1460 # 1610 <_data>
	la a2, _edata
    1064:	00000617          	auipc	a2,0x0
    1068:	6f060613          	addi	a2,a2,1776 # 1754 <__bss_start>
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
    1084:	00000517          	auipc	a0,0x0
    1088:	6d050513          	addi	a0,a0,1744 # 1754 <__bss_start>
	la a1, _end
    108c:	00000597          	auipc	a1,0x0
    1090:	6d458593          	addi	a1,a1,1748 # 1760 <_end>
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
    10a4:	010000ef          	jal	10b4 <__libc_init_array>
#endif

	call main
    10a8:	0a0000ef          	jal	1148 <main>

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

000010b4 <__libc_init_array>:
    10b4:	ff010113          	addi	sp,sp,-16
    10b8:	00812423          	sw	s0,8(sp)
    10bc:	01212023          	sw	s2,0(sp)
    10c0:	00000797          	auipc	a5,0x0
    10c4:	55078793          	addi	a5,a5,1360 # 1610 <_data>
    10c8:	00000417          	auipc	s0,0x0
    10cc:	54840413          	addi	s0,s0,1352 # 1610 <_data>
    10d0:	00112623          	sw	ra,12(sp)
    10d4:	00912223          	sw	s1,4(sp)
    10d8:	40878933          	sub	s2,a5,s0
    10dc:	02878063          	beq	a5,s0,10fc <__libc_init_array+0x48>
    10e0:	40295913          	srai	s2,s2,0x2
    10e4:	00000493          	li	s1,0
    10e8:	00042783          	lw	a5,0(s0)
    10ec:	00148493          	addi	s1,s1,1
    10f0:	00440413          	addi	s0,s0,4
    10f4:	000780e7          	jalr	a5
    10f8:	ff24e8e3          	bltu	s1,s2,10e8 <__libc_init_array+0x34>
    10fc:	00000797          	auipc	a5,0x0
    1100:	51478793          	addi	a5,a5,1300 # 1610 <_data>
    1104:	00000417          	auipc	s0,0x0
    1108:	50c40413          	addi	s0,s0,1292 # 1610 <_data>
    110c:	40878933          	sub	s2,a5,s0
    1110:	40295913          	srai	s2,s2,0x2
    1114:	00878e63          	beq	a5,s0,1130 <__libc_init_array+0x7c>
    1118:	00000493          	li	s1,0
    111c:	00042783          	lw	a5,0(s0)
    1120:	00148493          	addi	s1,s1,1
    1124:	00440413          	addi	s0,s0,4
    1128:	000780e7          	jalr	a5
    112c:	ff24e8e3          	bltu	s1,s2,111c <__libc_init_array+0x68>
    1130:	00c12083          	lw	ra,12(sp)
    1134:	00812403          	lw	s0,8(sp)
    1138:	00412483          	lw	s1,4(sp)
    113c:	00012903          	lw	s2,0(sp)
    1140:	01010113          	addi	sp,sp,16
    1144:	00008067          	ret

00001148 <main>:
*        and release various onboard buttons (sw4, sw6, sw7) corresponding to
*        different timer intervals.
*
******************************************************************************/

void main() {
    1148:	ff010113          	addi	sp,sp,-16
    114c:	00112623          	sw	ra,12(sp)
    1150:	00812423          	sw	s0,8(sp)
    bsp_init();
    1154:	354000ef          	jal	14a8 <bsp_init>
    bsp_printf("***Starting GPIO Demo*** \r\n");
    1158:	00001537          	lui	a0,0x1
    115c:	68450513          	addi	a0,a0,1668 # 1684 <_data+0x74>
    1160:	380000ef          	jal	14e0 <bsp_printf>
    bsp_printf("Configure GPIOs to blink .. \r\n");
    1164:	00001537          	lui	a0,0x1
    1168:	6a050513          	addi	a0,a0,1696 # 16a0 <_data+0x90>
    116c:	374000ef          	jal	14e0 <bsp_printf>
    static inline u32 read_u32(u32 address){
        return *((volatile u32*) address);
    }
    
    static inline void write_u32(u32 data, u32 address){
        *((volatile u32*) address) = data;
    1170:	f800d7b7          	lui	a5,0xf800d
    1174:	00e00713          	li	a4,14
    1178:	00e7a423          	sw	a4,8(a5) # f800d008 <__freertos_irq_stack_top+0xf800a8a8>
    117c:	f800d7b7          	lui	a5,0xf800d
    1180:	0007a223          	sw	zero,4(a5) # f800d004 <__freertos_irq_stack_top+0xf800a8a4>
    1184:	f800d437          	lui	s0,0xf800d
    1188:	00042223          	sw	zero,4(s0) # f800d004 <__freertos_irq_stack_top+0xf800a8a4>
    // Set GPIO to output
    gpio_setOutputEnable(GPIO0, 0xe);
    gpio_setOutput(GPIO0, 0x0);
    while(1) {
        gpio_setOutput(GPIO0, 0x0);
        bsp_uDelay(LOOP_UDELAY);
    118c:	f8b00637          	lui	a2,0xf8b00
    1190:	02faf5b7          	lui	a1,0x2faf
    1194:	08058593          	addi	a1,a1,128 # 2faf080 <__freertos_irq_stack_top+0x2fac920>
    1198:	001e8537          	lui	a0,0x1e8
    119c:	48050513          	addi	a0,a0,1152 # 1e8480 <__freertos_irq_stack_top+0x1e5d20>
    11a0:	0a4000ef          	jal	1244 <clint_uDelay>
    11a4:	00100793          	li	a5,1
    11a8:	00f42223          	sw	a5,4(s0)
        gpio_setOutput(GPIO0, 0x1);
        bsp_uDelay(LOOP_UDELAY);
    11ac:	f8b00637          	lui	a2,0xf8b00
    11b0:	02faf5b7          	lui	a1,0x2faf
    11b4:	08058593          	addi	a1,a1,128 # 2faf080 <__freertos_irq_stack_top+0x2fac920>
    11b8:	001e8537          	lui	a0,0x1e8
    11bc:	48050513          	addi	a0,a0,1152 # 1e8480 <__freertos_irq_stack_top+0x1e5d20>
    11c0:	084000ef          	jal	1244 <clint_uDelay>
    while(1) {
    11c4:	fc1ff06f          	j	1184 <main+0x3c>

000011c8 <uart_writeAvailability>:
        return *((volatile u32*) address);
    11c8:	00452503          	lw	a0,4(a0)
*          of available spaces for writing data from bits 23 to 16. It then
*          returns this value after masking with 0xFF.
*
******************************************************************************/
    static u32 uart_writeAvailability(u32 reg){
        return (read_u32(reg + UART_STATUS) >> 16) & 0xFF;
    11cc:	01055513          	srli	a0,a0,0x10
    }
    11d0:	0ff57513          	zext.b	a0,a0
    11d4:	00008067          	ret

000011d8 <uart_write>:
* @note    The function waits until there is available space in the UART buffer
*          for writing data. Once space is available, it writes the character
*          data to the UART data register.
*
******************************************************************************/
    static void uart_write(u32 reg, char data){
    11d8:	ff010113          	addi	sp,sp,-16
    11dc:	00112623          	sw	ra,12(sp)
    11e0:	00812423          	sw	s0,8(sp)
    11e4:	00912223          	sw	s1,4(sp)
    11e8:	00050413          	mv	s0,a0
    11ec:	00058493          	mv	s1,a1
        while(uart_writeAvailability(reg) == 0);
    11f0:	00040513          	mv	a0,s0
    11f4:	fd5ff0ef          	jal	11c8 <uart_writeAvailability>
    11f8:	fe050ce3          	beqz	a0,11f0 <uart_write+0x18>
        *((volatile u32*) address) = data;
    11fc:	00942023          	sw	s1,0(s0)
        write_u32(data, reg + UART_DATA);
    }
    1200:	00c12083          	lw	ra,12(sp)
    1204:	00812403          	lw	s0,8(sp)
    1208:	00412483          	lw	s1,4(sp)
    120c:	01010113          	addi	sp,sp,16
    1210:	00008067          	ret

00001214 <uart_applyConfig>:
*          value using data length, parity, and stop bit settings from the configuration
*          structure, and writes this value to the UART frame configuration register.
*
******************************************************************************/
    static void uart_applyConfig(u32 reg, Uart_Config *config){
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
    1214:	00c5a783          	lw	a5,12(a1)
    1218:	00f52423          	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
    121c:	0005a783          	lw	a5,0(a1)
    1220:	fff78793          	addi	a5,a5,-1
    1224:	0045a703          	lw	a4,4(a1)
    1228:	00871713          	slli	a4,a4,0x8
    122c:	00e7e7b3          	or	a5,a5,a4
    1230:	0085a703          	lw	a4,8(a1)
    1234:	01071713          	slli	a4,a4,0x10
    1238:	00e7e7b3          	or	a5,a5,a4
    123c:	00f52623          	sw	a5,12(a0)
    }
    1240:	00008067          	ret

00001244 <clint_uDelay>:
*          and the time limit is non-negative, indicating that the delay has
*          not yet elapsed.
*
******************************************************************************/
    static void clint_uDelay(u32 usec, u32 hz, u32 reg){
        u32 mTimePerUsec = hz/1000000;
    1244:	000f47b7          	lui	a5,0xf4
    1248:	24078793          	addi	a5,a5,576 # f4240 <__freertos_irq_stack_top+0xf1ae0>
    124c:	02f5d5b3          	divu	a1,a1,a5
    readReg_u32 (clint_getTimeLow , CLINT_TIME_ADDR)
    1250:	0000c7b7          	lui	a5,0xc
    1254:	ff878793          	addi	a5,a5,-8 # bff8 <__freertos_irq_stack_top+0x9898>
    1258:	00f60633          	add	a2,a2,a5
        return *((volatile u32*) address);
    125c:	00062783          	lw	a5,0(a2) # f8b00000 <__freertos_irq_stack_top+0xf8afd8a0>
        u32 limit = clint_getTimeLow(reg) + usec*mTimePerUsec;
    1260:	02a585b3          	mul	a1,a1,a0
    1264:	00f58733          	add	a4,a1,a5
    1268:	00062783          	lw	a5,0(a2)
        while((int32_t)(limit-(clint_getTimeLow(reg))) >= 0);
    126c:	40f707b3          	sub	a5,a4,a5
    1270:	fe07dce3          	bgez	a5,1268 <clint_uDelay+0x24>
    1274:	00008067          	ret

00001278 <_putchar>:
#include <math.h>
#include <string.h>
#include "bsp.h"

#if (ENABLE_BSP_PRINTF)
    static void _putchar(char character){
    1278:	ff010113          	addi	sp,sp,-16
    127c:	00112623          	sw	ra,12(sp)
    1280:	00050593          	mv	a1,a0
        #if (ENABLE_SEMIHOSTING_PRINT == 1)
            sh_writec(character);
        #else
            bsp_putChar(character);
    1284:	f8001537          	lui	a0,0xf8001
    1288:	f51ff0ef          	jal	11d8 <uart_write>
        #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }
    128c:	00c12083          	lw	ra,12(sp)
    1290:	01010113          	addi	sp,sp,16
    1294:	00008067          	ret

00001298 <_putchar_s>:

    static void _putchar_s(char *p)
    {
    1298:	ff010113          	addi	sp,sp,-16
    129c:	00112623          	sw	ra,12(sp)
    12a0:	00812423          	sw	s0,8(sp)
    12a4:	00050413          	mv	s0,a0
    #if (ENABLE_SEMIHOSTING_PRINT == 1)
        sh_write0(p);
    #else
        while (*p)
    12a8:	00c0006f          	j	12b4 <_putchar_s+0x1c>
            _putchar(*(p++));
    12ac:	00140413          	addi	s0,s0,1
    12b0:	fc9ff0ef          	jal	1278 <_putchar>
        while (*p)
    12b4:	00044503          	lbu	a0,0(s0)
    12b8:	fe051ae3          	bnez	a0,12ac <_putchar_s+0x14>
    #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }
    12bc:	00c12083          	lw	ra,12(sp)
    12c0:	00812403          	lw	s0,8(sp)
    12c4:	01010113          	addi	sp,sp,16
    12c8:	00008067          	ret

000012cc <bsp_printHex>:

        static void bsp_printHex(uint32_t val)
    {
    12cc:	ff010113          	addi	sp,sp,-16
    12d0:	00112623          	sw	ra,12(sp)
    12d4:	00812423          	sw	s0,8(sp)
    12d8:	00912223          	sw	s1,4(sp)
    12dc:	00050493          	mv	s1,a0
        uint32_t digits;
        digits =8;

        for (int i = (4*digits)-4; i >= 0; i -= 4) {
    12e0:	01c00413          	li	s0,28
    12e4:	0240006f          	j	1308 <bsp_printHex+0x3c>
            _putchar("0123456789ABCDEF"[(val >> i) % 16]);
    12e8:	0084d733          	srl	a4,s1,s0
    12ec:	00f77713          	andi	a4,a4,15
    12f0:	000017b7          	lui	a5,0x1
    12f4:	61078793          	addi	a5,a5,1552 # 1610 <_data>
    12f8:	00e787b3          	add	a5,a5,a4
    12fc:	0007c503          	lbu	a0,0(a5)
    1300:	f79ff0ef          	jal	1278 <_putchar>
        for (int i = (4*digits)-4; i >= 0; i -= 4) {
    1304:	ffc40413          	addi	s0,s0,-4
    1308:	fe0450e3          	bgez	s0,12e8 <bsp_printHex+0x1c>
        }
    }
    130c:	00c12083          	lw	ra,12(sp)
    1310:	00812403          	lw	s0,8(sp)
    1314:	00412483          	lw	s1,4(sp)
    1318:	01010113          	addi	sp,sp,16
    131c:	00008067          	ret

00001320 <bsp_printHex_lower>:

    static void bsp_printHex_lower(uint32_t val)
    {
    1320:	ff010113          	addi	sp,sp,-16
    1324:	00112623          	sw	ra,12(sp)
    1328:	00812423          	sw	s0,8(sp)
    132c:	00912223          	sw	s1,4(sp)
    1330:	00050493          	mv	s1,a0
        uint32_t digits;
        digits =8;

        for (int i = (4*digits)-4; i >= 0; i -= 4) {
    1334:	01c00413          	li	s0,28
    1338:	0240006f          	j	135c <bsp_printHex_lower+0x3c>
            _putchar("0123456789abcdef"[(val >> i) % 16]);
    133c:	0084d733          	srl	a4,s1,s0
    1340:	00f77713          	andi	a4,a4,15
    1344:	000017b7          	lui	a5,0x1
    1348:	62478793          	addi	a5,a5,1572 # 1624 <_data+0x14>
    134c:	00e787b3          	add	a5,a5,a4
    1350:	0007c503          	lbu	a0,0(a5)
    1354:	f25ff0ef          	jal	1278 <_putchar>
        for (int i = (4*digits)-4; i >= 0; i -= 4) {
    1358:	ffc40413          	addi	s0,s0,-4
    135c:	fe0450e3          	bgez	s0,133c <bsp_printHex_lower+0x1c>

        }
    }
    1360:	00c12083          	lw	ra,12(sp)
    1364:	00812403          	lw	s0,8(sp)
    1368:	00412483          	lw	s1,4(sp)
    136c:	01010113          	addi	sp,sp,16
    1370:	00008067          	ret

00001374 <bsp_printf_c>:
*
* @param c: The character to be output.
*
******************************************************************************/
    static void bsp_printf_c(int c)
    {
    1374:	ff010113          	addi	sp,sp,-16
    1378:	00112623          	sw	ra,12(sp)
        _putchar(c);
    137c:	0ff57513          	zext.b	a0,a0
    1380:	ef9ff0ef          	jal	1278 <_putchar>
    }
    1384:	00c12083          	lw	ra,12(sp)
    1388:	01010113          	addi	sp,sp,16
    138c:	00008067          	ret

00001390 <bsp_printf_s>:
*
* @param s: A pointer to the null-terminated string to be output.
*
*******************************************************************************/
    static void bsp_printf_s(char *p)
    {
    1390:	ff010113          	addi	sp,sp,-16
    1394:	00112623          	sw	ra,12(sp)
        _putchar_s(p);
    1398:	f01ff0ef          	jal	1298 <_putchar_s>
    }
    139c:	00c12083          	lw	ra,12(sp)
    13a0:	01010113          	addi	sp,sp,16
    13a4:	00008067          	ret

000013a8 <bsp_printf_d>:
* - Handles negative numbers by printing a '-' sign.
* - Uses the 'bsp_printf_c' function to print each character.
*
******************************************************************************/
    static void bsp_printf_d(int val)
    {
    13a8:	fd010113          	addi	sp,sp,-48
    13ac:	02112623          	sw	ra,44(sp)
    13b0:	02812423          	sw	s0,40(sp)
    13b4:	02912223          	sw	s1,36(sp)
    13b8:	00050493          	mv	s1,a0
        char buffer[32];
        char *p = buffer;
        if (val < 0) {
    13bc:	00054663          	bltz	a0,13c8 <bsp_printf_d+0x20>
    {
    13c0:	00010413          	mv	s0,sp
    13c4:	02c0006f          	j	13f0 <bsp_printf_d+0x48>
            bsp_printf_c('-');
    13c8:	02d00513          	li	a0,45
    13cc:	fa9ff0ef          	jal	1374 <bsp_printf_c>
            val = -val;
    13d0:	409004b3          	neg	s1,s1
    13d4:	fedff06f          	j	13c0 <bsp_printf_d+0x18>
        }
        while (val || p == buffer) {
            *(p++) = '0' + val % 10;
    13d8:	00a00713          	li	a4,10
    13dc:	02e4e7b3          	rem	a5,s1,a4
    13e0:	03078793          	addi	a5,a5,48
    13e4:	00f40023          	sb	a5,0(s0)
            val = val / 10;
    13e8:	02e4c4b3          	div	s1,s1,a4
            *(p++) = '0' + val % 10;
    13ec:	00140413          	addi	s0,s0,1
        while (val || p == buffer) {
    13f0:	fe0494e3          	bnez	s1,13d8 <bsp_printf_d+0x30>
    13f4:	00010793          	mv	a5,sp
    13f8:	fef400e3          	beq	s0,a5,13d8 <bsp_printf_d+0x30>
        }
        while (p != buffer)
    13fc:	00010793          	mv	a5,sp
    1400:	00f40a63          	beq	s0,a5,1414 <bsp_printf_d+0x6c>
            bsp_printf_c(*(--p));
    1404:	fff40413          	addi	s0,s0,-1
    1408:	00044503          	lbu	a0,0(s0)
    140c:	f69ff0ef          	jal	1374 <bsp_printf_c>
    1410:	fedff06f          	j	13fc <bsp_printf_d+0x54>
    }
    1414:	02c12083          	lw	ra,44(sp)
    1418:	02812403          	lw	s0,40(sp)
    141c:	02412483          	lw	s1,36(sp)
    1420:	03010113          	addi	sp,sp,48
    1424:	00008067          	ret

00001428 <bsp_printf_x>:
* - Calls 'bsp_printHex_lower' to print the hexadecimal representation.
* - Determines the number of leading zeros to be printed based on the value.
*
******************************************************************************/
    static void bsp_printf_x(int val)
    {
    1428:	ff010113          	addi	sp,sp,-16
    142c:	00112623          	sw	ra,12(sp)
        int i,digi=2;

        for(i=0;i<8;i++)
    1430:	00000713          	li	a4,0
    1434:	00700793          	li	a5,7
    1438:	02e7c063          	blt	a5,a4,1458 <bsp_printf_x+0x30>
        {
            if((val & (0xFFFFFFF0 <<(4*i))) == 0)
    143c:	00271693          	slli	a3,a4,0x2
    1440:	ff000793          	li	a5,-16
    1444:	00d797b3          	sll	a5,a5,a3
    1448:	00f577b3          	and	a5,a0,a5
    144c:	00078663          	beqz	a5,1458 <bsp_printf_x+0x30>
        for(i=0;i<8;i++)
    1450:	00170713          	addi	a4,a4,1
    1454:	fe1ff06f          	j	1434 <bsp_printf_x+0xc>
            {
                digi=i+1;
                break;
            }
        }
        bsp_printHex_lower(val);
    1458:	ec9ff0ef          	jal	1320 <bsp_printHex_lower>
    }
    145c:	00c12083          	lw	ra,12(sp)
    1460:	01010113          	addi	sp,sp,16
    1464:	00008067          	ret

00001468 <bsp_printf_X>:
* - Calls 'bsp_printHex' to print the uppercase hexadecimal representation.
* - Determines the number of leading zeros to be printed based on the value.
*
******************************************************************************/
    static void bsp_printf_X(int val)
        {
    1468:	ff010113          	addi	sp,sp,-16
    146c:	00112623          	sw	ra,12(sp)
            int i,digi=2;

            for(i=0;i<8;i++)
    1470:	00000713          	li	a4,0
    1474:	00700793          	li	a5,7
    1478:	02e7c063          	blt	a5,a4,1498 <bsp_printf_X+0x30>
            {
                if((val & (0xFFFFFFF0 <<(4*i))) == 0)
    147c:	00271693          	slli	a3,a4,0x2
    1480:	ff000793          	li	a5,-16
    1484:	00d797b3          	sll	a5,a5,a3
    1488:	00f577b3          	and	a5,a0,a5
    148c:	00078663          	beqz	a5,1498 <bsp_printf_X+0x30>
            for(i=0;i<8;i++)
    1490:	00170713          	addi	a4,a4,1
    1494:	fe1ff06f          	j	1474 <bsp_printf_X+0xc>
                {
                    digi=i+1;
                    break;
                }
            }
            bsp_printHex(val);
    1498:	e35ff0ef          	jal	12cc <bsp_printHex>
        }
    149c:	00c12083          	lw	ra,12(sp)
    14a0:	01010113          	addi	sp,sp,16
    14a4:	00008067          	ret

000014a8 <bsp_init>:
    *   1. UART baudrate
    *   2. 
    */
////////////////////////////////////////////////////////////////////////////////
    static void bsp_init()
    {
    14a8:	fe010113          	addi	sp,sp,-32
    14ac:	00112e23          	sw	ra,28(sp)
        Uart_Config uartConfig;
        uartConfig.dataLength   = BITS_8;
    14b0:	00800793          	li	a5,8
    14b4:	00f12023          	sw	a5,0(sp)
        uartConfig.parity       = NONE;
    14b8:	00012223          	sw	zero,4(sp)
        uartConfig.stop         = ONE;
    14bc:	00012423          	sw	zero,8(sp)
        uartConfig.clockDivider = BSP_CLINT_HZ/(BSP_UART_BAUDRATE*BSP_UART_DATA_LEN)-1;
    14c0:	03500793          	li	a5,53
    14c4:	00f12623          	sw	a5,12(sp)
        uart_applyConfig(BSP_UART_TERMINAL, &uartConfig);    
    14c8:	00010593          	mv	a1,sp
    14cc:	f8001537          	lui	a0,0xf8001
    14d0:	d45ff0ef          	jal	1214 <uart_applyConfig>
    }
    14d4:	01c12083          	lw	ra,28(sp)
    14d8:	02010113          	addi	sp,sp,32
    14dc:	00008067          	ret

000014e0 <bsp_printf>:
* - Handles each format specifier by calling the appropriate helper function.
* - If floating-point support is disabled, prints a warning for the 'f' specifier.
*
******************************************************************************/
    static void bsp_printf(const char *format, ...)
    {
    14e0:	fc010113          	addi	sp,sp,-64
    14e4:	00112e23          	sw	ra,28(sp)
    14e8:	00812c23          	sw	s0,24(sp)
    14ec:	00912a23          	sw	s1,20(sp)
    14f0:	00050493          	mv	s1,a0
    14f4:	02b12223          	sw	a1,36(sp)
    14f8:	02c12423          	sw	a2,40(sp)
    14fc:	02d12623          	sw	a3,44(sp)
    1500:	02e12823          	sw	a4,48(sp)
    1504:	02f12a23          	sw	a5,52(sp)
    1508:	03012c23          	sw	a6,56(sp)
    150c:	03112e23          	sw	a7,60(sp)
        int i;
        va_list ap;

        va_start(ap, format);
    1510:	02410793          	addi	a5,sp,36
    1514:	00f12623          	sw	a5,12(sp)

        for (i = 0; format[i]; i++)
    1518:	00000413          	li	s0,0
    151c:	01c0006f          	j	1538 <bsp_printf+0x58>
            if (format[i] == '%') {
                while (format[++i]) {
                    if (format[i] == 'c') {
                        bsp_printf_c(va_arg(ap,int));
    1520:	00c12783          	lw	a5,12(sp)
    1524:	00478713          	addi	a4,a5,4
    1528:	00e12623          	sw	a4,12(sp)
    152c:	0007a503          	lw	a0,0(a5)
    1530:	e45ff0ef          	jal	1374 <bsp_printf_c>
        for (i = 0; format[i]; i++)
    1534:	00140413          	addi	s0,s0,1
    1538:	008487b3          	add	a5,s1,s0
    153c:	0007c503          	lbu	a0,0(a5)
    1540:	0a050e63          	beqz	a0,15fc <bsp_printf+0x11c>
            if (format[i] == '%') {
    1544:	02500793          	li	a5,37
    1548:	06f50e63          	beq	a0,a5,15c4 <bsp_printf+0xe4>
                        break;
                    }
#endif //#if (ENABLE_FLOATING_POINT_SUPPORT)
                }
            } else
                bsp_printf_c(format[i]);
    154c:	e29ff0ef          	jal	1374 <bsp_printf_c>
    1550:	fe5ff06f          	j	1534 <bsp_printf+0x54>
                        bsp_printf_s(va_arg(ap,char*));
    1554:	00c12783          	lw	a5,12(sp)
    1558:	00478713          	addi	a4,a5,4
    155c:	00e12623          	sw	a4,12(sp)
    1560:	0007a503          	lw	a0,0(a5)
    1564:	e2dff0ef          	jal	1390 <bsp_printf_s>
                        break;
    1568:	fcdff06f          	j	1534 <bsp_printf+0x54>
                        bsp_printf_d(va_arg(ap,int));
    156c:	00c12783          	lw	a5,12(sp)
    1570:	00478713          	addi	a4,a5,4
    1574:	00e12623          	sw	a4,12(sp)
    1578:	0007a503          	lw	a0,0(a5)
    157c:	e2dff0ef          	jal	13a8 <bsp_printf_d>
                        break;
    1580:	fb5ff06f          	j	1534 <bsp_printf+0x54>
                        bsp_printf_X(va_arg(ap,int));
    1584:	00c12783          	lw	a5,12(sp)
    1588:	00478713          	addi	a4,a5,4
    158c:	00e12623          	sw	a4,12(sp)
    1590:	0007a503          	lw	a0,0(a5)
    1594:	ed5ff0ef          	jal	1468 <bsp_printf_X>
                        break;
    1598:	f9dff06f          	j	1534 <bsp_printf+0x54>
                        bsp_printf_x(va_arg(ap,int));
    159c:	00c12783          	lw	a5,12(sp)
    15a0:	00478713          	addi	a4,a5,4
    15a4:	00e12623          	sw	a4,12(sp)
    15a8:	0007a503          	lw	a0,0(a5)
    15ac:	e7dff0ef          	jal	1428 <bsp_printf_x>
                        break;
    15b0:	f85ff06f          	j	1534 <bsp_printf+0x54>
                        bsp_printf_s("<Floating point printing not enable. Please Enable it at bsp.h first...>");
    15b4:	00001537          	lui	a0,0x1
    15b8:	63850513          	addi	a0,a0,1592 # 1638 <_data+0x28>
    15bc:	dd5ff0ef          	jal	1390 <bsp_printf_s>
                        break;
    15c0:	f75ff06f          	j	1534 <bsp_printf+0x54>
                while (format[++i]) {
    15c4:	00140413          	addi	s0,s0,1
    15c8:	008487b3          	add	a5,s1,s0
    15cc:	0007c783          	lbu	a5,0(a5)
    15d0:	f60782e3          	beqz	a5,1534 <bsp_printf+0x54>
                    if (format[i] == 'c') {
    15d4:	fa878793          	addi	a5,a5,-88
    15d8:	0ff7f693          	zext.b	a3,a5
    15dc:	02000713          	li	a4,32
    15e0:	fed762e3          	bltu	a4,a3,15c4 <bsp_printf+0xe4>
    15e4:	00269793          	slli	a5,a3,0x2
    15e8:	00001737          	lui	a4,0x1
    15ec:	6c070713          	addi	a4,a4,1728 # 16c0 <_data+0xb0>
    15f0:	00e787b3          	add	a5,a5,a4
    15f4:	0007a783          	lw	a5,0(a5)
    15f8:	00078067          	jr	a5

        va_end(ap);
    }
    15fc:	01c12083          	lw	ra,28(sp)
    1600:	01812403          	lw	s0,24(sp)
    1604:	01412483          	lw	s1,20(sp)
    1608:	04010113          	addi	sp,sp,64
    160c:	00008067          	ret
