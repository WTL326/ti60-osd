
build/spiDemo.elf:     file format elf32-littleriscv


Disassembly of section .init:

00001000 <_start>:

_start:
#ifdef USE_GP
.option push
.option norelax
	la gp, __global_pointer$
    1000:	00006197          	auipc	gp,0x6
    1004:	00018193          	mv	gp,gp
.global smp_lottery_target
.global smp_lottery_lock
.global smp_slave


  sw x0, smp_lottery_lock, a1
    1008:	8a01ac23          	sw	zero,-1864(gp) # 68b8 <smp_lottery_lock>

0000100c <smp_tyranny>:

smp_tyranny:
  csrr a0, mhartid
    100c:	f1402573          	csrr	a0,mhartid
  beqz a0, init
    1010:	02050e63          	beqz	a0,104c <init>

00001014 <smp_slave>:

smp_slave:
	lw a0, smp_lottery_lock
    1014:	8b81a503          	lw	a0,-1864(gp) # 68b8 <smp_lottery_lock>
	beqz a0, smp_slave
    1018:	fe050ee3          	beqz	a0,1014 <smp_slave>

	fence r, r
    101c:	0220000f          	fence	r,r
    1020:	0000100f          	.word	0x0000100f
	//li a1, -1
	//amoadd.w x0, a1,(a0)

	.word(0x100F) //i$ flush
	lw a5, smp_lottery_target
    1024:	8b41a783          	lw	a5,-1868(gp) # 68b4 <__bss_start>
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
    1038:	8aa1aa23          	sw	a0,-1868(gp) # 68b4 <__bss_start>
	fence w, w
    103c:	0110000f          	fence	w,w
	li a0, 1
    1040:	00100513          	li	a0,1
	sw a0, smp_lottery_lock, a1
    1044:	8aa1ac23          	sw	a0,-1864(gp) # 68b8 <smp_lottery_lock>
    ret
    1048:	00008067          	ret

0000104c <init>:
#endif

init:
	la sp, _sp
    104c:	00007117          	auipc	sp,0x7
    1050:	87410113          	addi	sp,sp,-1932 # 78c0 <__freertos_irq_stack_top>

	/* Load data section */
	la a0, _data_lma
    1054:	00005517          	auipc	a0,0x5
    1058:	3ac50513          	addi	a0,a0,940 # 6400 <_data>
	la a1, _data
    105c:	00005597          	auipc	a1,0x5
    1060:	3a458593          	addi	a1,a1,932 # 6400 <_data>
	la a2, _edata
    1064:	00006617          	auipc	a2,0x6
    1068:	85060613          	addi	a2,a2,-1968 # 68b4 <__bss_start>
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
    1088:	83050513          	addi	a0,a0,-2000 # 68b4 <__bss_start>
	la a1, _end
    108c:	00006597          	auipc	a1,0x6
    1090:	83458593          	addi	a1,a1,-1996 # 68c0 <_end>
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
    10d0:	33478793          	addi	a5,a5,820 # 6400 <_data>
    10d4:	00005417          	auipc	s0,0x5
    10d8:	32c40413          	addi	s0,s0,812 # 6400 <_data>
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
    110c:	2f878793          	addi	a5,a5,760 # 6400 <_data>
    1110:	00005417          	auipc	s0,0x5
    1114:	2f040413          	addi	s0,s0,752 # 6400 <_data>
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
* @brief This main function initializes the SPI interface, selects the SPI device,
*        writes to SPI flash starting from a specific address and for a specified LENgth.
*
******************************************************************************/
void main() {
    1154:	ff010113          	addi	sp,sp,-16
    1158:	00112623          	sw	ra,12(sp)
    115c:	00812423          	sw	s0,8(sp)

    bsp_init();
    1160:	389010ef          	jal	2ce8 <bsp_init>
    bsp_printf("***Starting SPI Demo*** \r\n");
    1164:	00006537          	lui	a0,0x6
    1168:	44050513          	addi	a0,a0,1088 # 6440 <_data+0x40>
    116c:	1e8020ef          	jal	3354 <bsp_printf>
    spiInit();
    1170:	24c020ef          	jal	33bc <spiInit>
    bsp_printf("Device ID : %x \r\n", spiFlash_manufacturer_id(SPI,SPI_CS));
    1174:	00000593          	li	a1,0
    1178:	f8006537          	lui	a0,0xf8006
    117c:	090020ef          	jal	320c <spiFlash_manufacturer_id>
    1180:	00050593          	mv	a1,a0
    1184:	00006537          	lui	a0,0x6
    1188:	45c50513          	addi	a0,a0,1116 # 645c <_data+0x5c>
    118c:	1c8020ef          	jal	3354 <bsp_printf>
    bsp_printf("Writing data to flash .. \r\n");
    1190:	00006537          	lui	a0,0x6
    1194:	47050513          	addi	a0,a0,1136 # 6470 <_data+0x70>
    1198:	1bc020ef          	jal	3354 <bsp_printf>
    spiWriteData_toFlash(SPI,SPI_CS,FLASH_START_ADDR);
    119c:	00410637          	lui	a2,0x410
    11a0:	00000593          	li	a1,0
    11a4:	f8006537          	lui	a0,0xf8006
    11a8:	25c020ef          	jal	3404 <spiWriteData_toFlash>

    bsp_printf("Reading from flash .. \r\n");
    11ac:	00006537          	lui	a0,0x6
    11b0:	48c50513          	addi	a0,a0,1164 # 648c <_data+0x8c>
    11b4:	1a0020ef          	jal	3354 <bsp_printf>
    for(int i=FLASH_START_ADDR;i< (FLASH_START_ADDR+LEN) ;i++)
    11b8:	00410437          	lui	s0,0x410
    11bc:	02c0006f          	j	11e8 <main+0x94>
    {
        bsp_printf("Read address %x := %x \r\n", i, spiReadData_fromFlash(SPI,SPI_CS,i));
    11c0:	00040613          	mv	a2,s0
    11c4:	00000593          	li	a1,0
    11c8:	f8006537          	lui	a0,0xf8006
    11cc:	4cd010ef          	jal	2e98 <spiReadData_fromFlash>
    11d0:	00050613          	mv	a2,a0
    11d4:	00040593          	mv	a1,s0
    11d8:	00006537          	lui	a0,0x6
    11dc:	4a850513          	addi	a0,a0,1192 # 64a8 <_data+0xa8>
    11e0:	174020ef          	jal	3354 <bsp_printf>
    for(int i=FLASH_START_ADDR;i< (FLASH_START_ADDR+LEN) ;i++)
    11e4:	00140413          	addi	s0,s0,1 # 410001 <__freertos_irq_stack_top+0x408741>
    11e8:	004107b7          	lui	a5,0x410
    11ec:	0ff78793          	addi	a5,a5,255 # 4100ff <__freertos_irq_stack_top+0x40883f>
    11f0:	fc87d8e3          	bge	a5,s0,11c0 <main+0x6c>
    }

    bsp_printf("***Successfully Ran Demo*** \r\n");
    11f4:	00006537          	lui	a0,0x6
    11f8:	4c450513          	addi	a0,a0,1220 # 64c4 <_data+0xc4>
    11fc:	158020ef          	jal	3354 <bsp_printf>

}
    1200:	00c12083          	lw	ra,12(sp)
    1204:	00812403          	lw	s0,8(sp)
    1208:	01010113          	addi	sp,sp,16
    120c:	00008067          	ret

00001210 <uart_applyConfig>:
*          value using data length, parity, and stop bit settings from the configuration
*          structure, and writes this value to the UART frame configuration register.
*
******************************************************************************/
    static void uart_applyConfig(u32 reg, Uart_Config *config){
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
    1210:	00c5a783          	lw	a5,12(a1)
    static inline u32 read_u32(u32 address){
        return *((volatile u32*) address);
    }
    
    static inline void write_u32(u32 data, u32 address){
        *((volatile u32*) address) = data;
    1214:	00f52423          	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
    1218:	0005a783          	lw	a5,0(a1)
    121c:	fff78793          	addi	a5,a5,-1
    1220:	0045a703          	lw	a4,4(a1)
    1224:	00871713          	slli	a4,a4,0x8
    1228:	00e7e7b3          	or	a5,a5,a4
    122c:	0085a703          	lw	a4,8(a1)
    1230:	01071713          	slli	a4,a4,0x10
    1234:	00e7e7b3          	or	a5,a5,a4
    1238:	00f52623          	sw	a5,12(a0)
    }
    123c:	00008067          	ret

00001240 <clint_uDelay>:
*          and the time limit is non-negative, indicating that the delay has
*          not yet elapsed.
*
******************************************************************************/
    static void clint_uDelay(u32 usec, u32 hz, u32 reg){
        u32 mTimePerUsec = hz/1000000;
    1240:	000f47b7          	lui	a5,0xf4
    1244:	24078793          	addi	a5,a5,576 # f4240 <__freertos_irq_stack_top+0xec980>
    1248:	02f5d5b3          	divu	a1,a1,a5
    readReg_u32 (clint_getTimeLow , CLINT_TIME_ADDR)
    124c:	0000c7b7          	lui	a5,0xc
    1250:	ff878793          	addi	a5,a5,-8 # bff8 <__freertos_irq_stack_top+0x4738>
    1254:	00f60633          	add	a2,a2,a5
        return *((volatile u32*) address);
    1258:	00062783          	lw	a5,0(a2) # 410000 <__freertos_irq_stack_top+0x408740>
        u32 limit = clint_getTimeLow(reg) + usec*mTimePerUsec;
    125c:	02a585b3          	mul	a1,a1,a0
    1260:	00f58733          	add	a4,a1,a5
    1264:	00062783          	lw	a5,0(a2)
        while((int32_t)(limit-(clint_getTimeLow(reg))) >= 0);
    1268:	40f707b3          	sub	a5,a4,a5
    126c:	fe07dce3          	bgez	a5,1264 <clint_uDelay+0x24>
    1270:	00008067          	ret
	...

00001280 <sh_write0>:
* @note    None.
*
******************************************************************************/

static void sh_write0(char* buf)
{
    1280:	00050593          	mv	a1,a0
    register int value asm ("a0") = reason;
    1284:	00400513          	li	a0,4
    register void* ptr asm ("a1") = arg;
    1288:	00000013          	nop
    128c:	00000013          	nop
    asm volatile (
    1290:	01f01013          	slli	zero,zero,0x1f
    1294:	00100073          	ebreak
    1298:	40705013          	srai	zero,zero,0x7
    129c:	00000013          	nop
    // Print zero-terminated string
    call_host(SEMIHOSTING_SYS_WRITE0, (void*) buf);
}
    12a0:	00008067          	ret
    12a4:	00000013          	nop
    12a8:	00000013          	nop

000012ac <_putchar_s>:
            bsp_putChar(character);
        #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }

    static void _putchar_s(char *p)
    {
    12ac:	ff010113          	addi	sp,sp,-16
    12b0:	00112623          	sw	ra,12(sp)
    #if (ENABLE_SEMIHOSTING_PRINT == 1)
        sh_write0(p);
    12b4:	fcdff0ef          	jal	1280 <sh_write0>
    #else
        while (*p)
            _putchar(*(p++));
    #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }
    12b8:	00c12083          	lw	ra,12(sp)
    12bc:	01010113          	addi	sp,sp,16
    12c0:	00008067          	ret

000012c4 <_out_buffer>:
*
******************************************************************************/

static inline void _out_buffer(char character, void* buffer, size_t idx, size_t maxlen)
{
  if (idx < maxlen) {
    12c4:	00d67663          	bgeu	a2,a3,12d0 <_out_buffer+0xc>
    ((char*)buffer)[idx] = character;
    12c8:	00c585b3          	add	a1,a1,a2
    12cc:	00a58023          	sb	a0,0(a1)
  }
}
    12d0:	00008067          	ret

000012d4 <_out_null>:
*
******************************************************************************/
static inline void _out_null(char character, void* buffer, size_t idx, size_t maxlen)
{
  (void)character; (void)buffer; (void)idx; (void)maxlen;
}
    12d4:	00008067          	ret

000012d8 <_atoi>:
*
* @return Converted unsigned integer value.
*
******************************************************************************/
static unsigned int _atoi(const char** str)
{
    12d8:	00050693          	mv	a3,a0
  unsigned int i = 0U;
    12dc:	00000513          	li	a0,0
  while (_is_digit(**str)) {
    12e0:	0240006f          	j	1304 <_atoi+0x2c>
    i = i * 10U + (unsigned int)(*((*str)++) - '0');
    12e4:	00251793          	slli	a5,a0,0x2
    12e8:	00a787b3          	add	a5,a5,a0
    12ec:	00179793          	slli	a5,a5,0x1
    12f0:	00170613          	addi	a2,a4,1
    12f4:	00c6a023          	sw	a2,0(a3)
    12f8:	00074503          	lbu	a0,0(a4)
    12fc:	00f50533          	add	a0,a0,a5
    1300:	fd050513          	addi	a0,a0,-48
  while (_is_digit(**str)) {
    1304:	0006a703          	lw	a4,0(a3)
    1308:	00074783          	lbu	a5,0(a4)
  return (ch >= '0') && (ch <= '9');
    130c:	fd078793          	addi	a5,a5,-48
    1310:	0ff7f793          	zext.b	a5,a5
  while (_is_digit(**str)) {
    1314:	00900613          	li	a2,9
    1318:	fcf676e3          	bgeu	a2,a5,12e4 <_atoi+0xc>
  }
  return i;
}
    131c:	00008067          	ret

00001320 <_out_rev>:
*
* @return Updated index in the buffer after outputting the string.
*
******************************************************************************/
static size_t _out_rev(out_fct_type out, char* buffer, size_t idx, size_t maxlen, const char* buf, size_t len, unsigned int width, unsigned int flags)
{
    1320:	fd010113          	addi	sp,sp,-48
    1324:	02112623          	sw	ra,44(sp)
    1328:	02812423          	sw	s0,40(sp)
    132c:	02912223          	sw	s1,36(sp)
    1330:	03212023          	sw	s2,32(sp)
    1334:	01312e23          	sw	s3,28(sp)
    1338:	01412c23          	sw	s4,24(sp)
    133c:	01512a23          	sw	s5,20(sp)
    1340:	01612823          	sw	s6,16(sp)
    1344:	01712623          	sw	s7,12(sp)
    1348:	01812423          	sw	s8,8(sp)
    134c:	00050493          	mv	s1,a0
    1350:	00058913          	mv	s2,a1
    1354:	00060b93          	mv	s7,a2
    1358:	00068993          	mv	s3,a3
    135c:	00070b13          	mv	s6,a4
    1360:	00078413          	mv	s0,a5
    1364:	00080a93          	mv	s5,a6
    1368:	00088c13          	mv	s8,a7
  const size_t start_idx = idx;

  // pad spaces up to given width
  if (!(flags & FLAGS_LEFT) && !(flags & FLAGS_ZEROPAD)) {
    136c:	0038f793          	andi	a5,a7,3
    1370:	04079c63          	bnez	a5,13c8 <_out_rev+0xa8>
    1374:	01912223          	sw	s9,4(sp)
    for (size_t i = len; i < width; i++) {
    1378:	00040a13          	mv	s4,s0
    137c:	035a7263          	bgeu	s4,s5,13a0 <_out_rev+0x80>
      out(' ', buffer, idx++, maxlen);
    1380:	00160c93          	addi	s9,a2,1
    1384:	00098693          	mv	a3,s3
    1388:	00090593          	mv	a1,s2
    138c:	02000513          	li	a0,32
    1390:	000480e7          	jalr	s1
    for (size_t i = len; i < width; i++) {
    1394:	001a0a13          	addi	s4,s4,1
      out(' ', buffer, idx++, maxlen);
    1398:	000c8613          	mv	a2,s9
    139c:	fe1ff06f          	j	137c <_out_rev+0x5c>
    13a0:	00412c83          	lw	s9,4(sp)
    13a4:	0240006f          	j	13c8 <_out_rev+0xa8>
    }
  }

  // reverse string
  while (len) {
    out(buf[--len], buffer, idx++, maxlen);
    13a8:	fff40413          	addi	s0,s0,-1
    13ac:	008b07b3          	add	a5,s6,s0
    13b0:	00160a13          	addi	s4,a2,1
    13b4:	00098693          	mv	a3,s3
    13b8:	00090593          	mv	a1,s2
    13bc:	0007c503          	lbu	a0,0(a5)
    13c0:	000480e7          	jalr	s1
    13c4:	000a0613          	mv	a2,s4
  while (len) {
    13c8:	fe0410e3          	bnez	s0,13a8 <_out_rev+0x88>
  }

  // append pad spaces up to given width
  if (flags & FLAGS_LEFT) {
    13cc:	002c7c13          	andi	s8,s8,2
    13d0:	020c1c63          	bnez	s8,1408 <_out_rev+0xe8>
      out(' ', buffer, idx++, maxlen);
    }
  }

  return idx;
}
    13d4:	00060513          	mv	a0,a2
    13d8:	02c12083          	lw	ra,44(sp)
    13dc:	02812403          	lw	s0,40(sp)
    13e0:	02412483          	lw	s1,36(sp)
    13e4:	02012903          	lw	s2,32(sp)
    13e8:	01c12983          	lw	s3,28(sp)
    13ec:	01812a03          	lw	s4,24(sp)
    13f0:	01412a83          	lw	s5,20(sp)
    13f4:	01012b03          	lw	s6,16(sp)
    13f8:	00c12b83          	lw	s7,12(sp)
    13fc:	00812c03          	lw	s8,8(sp)
    1400:	03010113          	addi	sp,sp,48
    1404:	00008067          	ret
    while (idx - start_idx < width) {
    1408:	417607b3          	sub	a5,a2,s7
    140c:	fd57f4e3          	bgeu	a5,s5,13d4 <_out_rev+0xb4>
      out(' ', buffer, idx++, maxlen);
    1410:	00160413          	addi	s0,a2,1
    1414:	00098693          	mv	a3,s3
    1418:	00090593          	mv	a1,s2
    141c:	02000513          	li	a0,32
    1420:	000480e7          	jalr	s1
    1424:	00040613          	mv	a2,s0
    1428:	fe1ff06f          	j	1408 <_out_rev+0xe8>

0000142c <_ntoa_format>:
*
* @return Number of characters written to the buffer.
*
******************************************************************************/
static size_t _ntoa_format(out_fct_type out, char* buffer, size_t idx, size_t maxlen, char* buf, size_t len, bool negative, unsigned int base, unsigned int prec, unsigned int width, unsigned int flags)
{
    142c:	ff010113          	addi	sp,sp,-16
    1430:	00112623          	sw	ra,12(sp)
    1434:	00080f93          	mv	t6,a6
    1438:	00088f13          	mv	t5,a7
    143c:	01012e83          	lw	t4,16(sp)
    1440:	01412803          	lw	a6,20(sp)
    1444:	01812883          	lw	a7,24(sp)
  // pad leading zeros
  if (!(flags & FLAGS_LEFT)) {
    1448:	0028f313          	andi	t1,a7,2
    144c:	06031463          	bnez	t1,14b4 <_ntoa_format+0x88>
    if (width && (flags & FLAGS_ZEROPAD) && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
    1450:	02080863          	beqz	a6,1480 <_ntoa_format+0x54>
    1454:	0018f313          	andi	t1,a7,1
    1458:	02030463          	beqz	t1,1480 <_ntoa_format+0x54>
    145c:	000f9663          	bnez	t6,1468 <_ntoa_format+0x3c>
    1460:	00c8f313          	andi	t1,a7,12
    1464:	00030e63          	beqz	t1,1480 <_ntoa_format+0x54>
      width--;
    1468:	fff80813          	addi	a6,a6,-1
    146c:	0140006f          	j	1480 <_ntoa_format+0x54>
    }
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = '0';
    1470:	00f70333          	add	t1,a4,a5
    1474:	03000e13          	li	t3,48
    1478:	01c30023          	sb	t3,0(t1)
    147c:	00178793          	addi	a5,a5,1
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1480:	01d7f663          	bgeu	a5,t4,148c <_ntoa_format+0x60>
    1484:	01f00313          	li	t1,31
    1488:	fef374e3          	bgeu	t1,a5,1470 <_ntoa_format+0x44>
    }
    while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    148c:	0018f313          	andi	t1,a7,1
    1490:	02030263          	beqz	t1,14b4 <_ntoa_format+0x88>
    1494:	0307f063          	bgeu	a5,a6,14b4 <_ntoa_format+0x88>
    1498:	01f00313          	li	t1,31
    149c:	00f36c63          	bltu	t1,a5,14b4 <_ntoa_format+0x88>
      buf[len++] = '0';
    14a0:	00f70333          	add	t1,a4,a5
    14a4:	03000e13          	li	t3,48
    14a8:	01c30023          	sb	t3,0(t1)
    14ac:	00178793          	addi	a5,a5,1
    14b0:	fddff06f          	j	148c <_ntoa_format+0x60>
    }
  }

  // handle hash
  if (flags & FLAGS_HASH) {
    14b4:	0108f313          	andi	t1,a7,16
    14b8:	04030063          	beqz	t1,14f8 <_ntoa_format+0xcc>
    if (!(flags & FLAGS_PRECISION) && len && ((len == prec) || (len == width))) {
    14bc:	4008f313          	andi	t1,a7,1024
    14c0:	00031863          	bnez	t1,14d0 <_ntoa_format+0xa4>
    14c4:	00078663          	beqz	a5,14d0 <_ntoa_format+0xa4>
    14c8:	05d78e63          	beq	a5,t4,1524 <_ntoa_format+0xf8>
    14cc:	05078c63          	beq	a5,a6,1524 <_ntoa_format+0xf8>
      len--;
      if (len && (base == 16U)) {
        len--;
      }
    }
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    14d0:	01000313          	li	t1,16
    14d4:	0a6f0063          	beq	t5,t1,1574 <_ntoa_format+0x148>
      buf[len++] = 'x';
    }
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = 'X';
    }
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    14d8:	00200313          	li	t1,2
    14dc:	0a6f0e63          	beq	t5,t1,1598 <_ntoa_format+0x16c>
      buf[len++] = 'b';
    }
    if (len < PRINTF_NTOA_BUFFER_SIZE) {
    14e0:	01f00313          	li	t1,31
    14e4:	02f36863          	bltu	t1,a5,1514 <_ntoa_format+0xe8>
      buf[len++] = '0';
    14e8:	00f70333          	add	t1,a4,a5
    14ec:	03000e13          	li	t3,48
    14f0:	01c30023          	sb	t3,0(t1)
    14f4:	00178793          	addi	a5,a5,1
    }
  }

  if (len < PRINTF_NTOA_BUFFER_SIZE) {
    14f8:	01f00313          	li	t1,31
    14fc:	00f36c63          	bltu	t1,a5,1514 <_ntoa_format+0xe8>
    if (negative) {
    1500:	0a0f8a63          	beqz	t6,15b4 <_ntoa_format+0x188>
      buf[len++] = '-';
    1504:	00f70333          	add	t1,a4,a5
    1508:	02d00e13          	li	t3,45
    150c:	01c30023          	sb	t3,0(t1)
    1510:	00178793          	addi	a5,a5,1
    else if (flags & FLAGS_SPACE) {
      buf[len++] = ' ';
    }
  }

  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
    1514:	e0dff0ef          	jal	1320 <_out_rev>
}
    1518:	00c12083          	lw	ra,12(sp)
    151c:	01010113          	addi	sp,sp,16
    1520:	00008067          	ret
      len--;
    1524:	fff78313          	addi	t1,a5,-1
      if (len && (base == 16U)) {
    1528:	04030263          	beqz	t1,156c <_ntoa_format+0x140>
    152c:	01000e13          	li	t3,16
    1530:	03cf0a63          	beq	t5,t3,1564 <_ntoa_format+0x138>
      len--;
    1534:	00030793          	mv	a5,t1
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1538:	01000313          	li	t1,16
    153c:	f86f1ee3          	bne	t5,t1,14d8 <_ntoa_format+0xac>
    1540:	0208f313          	andi	t1,a7,32
    1544:	f8030ae3          	beqz	t1,14d8 <_ntoa_format+0xac>
    1548:	01f00313          	li	t1,31
    154c:	f8f366e3          	bltu	t1,a5,14d8 <_ntoa_format+0xac>
      buf[len++] = 'X';
    1550:	00f70333          	add	t1,a4,a5
    1554:	05800e13          	li	t3,88
    1558:	01c30023          	sb	t3,0(t1)
    155c:	00178793          	addi	a5,a5,1
    1560:	f81ff06f          	j	14e0 <_ntoa_format+0xb4>
        len--;
    1564:	ffe78793          	addi	a5,a5,-2
    1568:	f69ff06f          	j	14d0 <_ntoa_format+0xa4>
      len--;
    156c:	00030793          	mv	a5,t1
    1570:	f61ff06f          	j	14d0 <_ntoa_format+0xa4>
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1574:	0208f313          	andi	t1,a7,32
    1578:	fc0310e3          	bnez	t1,1538 <_ntoa_format+0x10c>
    157c:	01f00313          	li	t1,31
    1580:	faf36ce3          	bltu	t1,a5,1538 <_ntoa_format+0x10c>
      buf[len++] = 'x';
    1584:	00f70333          	add	t1,a4,a5
    1588:	07800e13          	li	t3,120
    158c:	01c30023          	sb	t3,0(t1)
    1590:	00178793          	addi	a5,a5,1
    1594:	f4dff06f          	j	14e0 <_ntoa_format+0xb4>
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1598:	01f00313          	li	t1,31
    159c:	f6f36ce3          	bltu	t1,a5,1514 <_ntoa_format+0xe8>
      buf[len++] = 'b';
    15a0:	00f70333          	add	t1,a4,a5
    15a4:	06200e13          	li	t3,98
    15a8:	01c30023          	sb	t3,0(t1)
    15ac:	00178793          	addi	a5,a5,1
    15b0:	f31ff06f          	j	14e0 <_ntoa_format+0xb4>
    else if (flags & FLAGS_PLUS) {
    15b4:	0048f313          	andi	t1,a7,4
    15b8:	00030c63          	beqz	t1,15d0 <_ntoa_format+0x1a4>
      buf[len++] = '+';  // ignore the space if the '+' exists
    15bc:	00f70333          	add	t1,a4,a5
    15c0:	02b00e13          	li	t3,43
    15c4:	01c30023          	sb	t3,0(t1)
    15c8:	00178793          	addi	a5,a5,1
    15cc:	f49ff06f          	j	1514 <_ntoa_format+0xe8>
    else if (flags & FLAGS_SPACE) {
    15d0:	0088f313          	andi	t1,a7,8
    15d4:	f40300e3          	beqz	t1,1514 <_ntoa_format+0xe8>
      buf[len++] = ' ';
    15d8:	00f70333          	add	t1,a4,a5
    15dc:	02000e13          	li	t3,32
    15e0:	01c30023          	sb	t3,0(t1)
    15e4:	00178793          	addi	a5,a5,1
    15e8:	f2dff06f          	j	1514 <_ntoa_format+0xe8>

000015ec <_ntoa_long>:
* @return Number of characters written to the buffer.
*
*
******************************************************************************/
static size_t _ntoa_long(out_fct_type out, char* buffer, size_t idx, size_t maxlen, unsigned long value, bool negative, unsigned long base, unsigned int prec, unsigned int width, unsigned int flags)
{
    15ec:	fc010113          	addi	sp,sp,-64
    15f0:	02112e23          	sw	ra,60(sp)
    15f4:	00078f93          	mv	t6,a5
    15f8:	04412f03          	lw	t5,68(sp)
  char buf[PRINTF_NTOA_BUFFER_SIZE];
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
    15fc:	00071463          	bnez	a4,1604 <_ntoa_long+0x18>
    flags &= ~FLAGS_HASH;
    1600:	feff7f13          	andi	t5,t5,-17
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
    1604:	400f7e93          	andi	t4,t5,1024
    1608:	040e8063          	beqz	t4,1648 <_ntoa_long+0x5c>
    160c:	06070a63          	beqz	a4,1680 <_ntoa_long+0x94>
    1610:	00000e93          	li	t4,0
    1614:	0340006f          	j	1648 <_ntoa_long+0x5c>
    do {
      const char digit = (char)(value % base);
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1618:	030e0e13          	addi	t3,t3,48
    161c:	0ffe7313          	zext.b	t1,t3
    1620:	001e8793          	addi	a5,t4,1
    1624:	030e8e13          	addi	t3,t4,48
    1628:	002e0eb3          	add	t4,t3,sp
    162c:	fe6e8023          	sb	t1,-32(t4)
      value /= base;
    1630:	03075333          	divu	t1,a4,a6
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    1634:	05076863          	bltu	a4,a6,1684 <_ntoa_long+0x98>
    1638:	01f00713          	li	a4,31
    163c:	04f76463          	bltu	a4,a5,1684 <_ntoa_long+0x98>
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1640:	00078e93          	mv	t4,a5
      value /= base;
    1644:	00030713          	mv	a4,t1
      const char digit = (char)(value % base);
    1648:	03077e33          	remu	t3,a4,a6
    164c:	0ffe7e13          	zext.b	t3,t3
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1650:	00900313          	li	t1,9
    1654:	fdc372e3          	bgeu	t1,t3,1618 <_ntoa_long+0x2c>
    1658:	020f7313          	andi	t1,t5,32
    165c:	00030e63          	beqz	t1,1678 <_ntoa_long+0x8c>
    1660:	04100313          	li	t1,65
    1664:	01c30333          	add	t1,t1,t3
    1668:	0ff37313          	zext.b	t1,t1
    166c:	ff630313          	addi	t1,t1,-10
    1670:	0ff37313          	zext.b	t1,t1
    1674:	fadff06f          	j	1620 <_ntoa_long+0x34>
    1678:	06100313          	li	t1,97
    167c:	fe9ff06f          	j	1664 <_ntoa_long+0x78>
  size_t len = 0U;
    1680:	00070793          	mv	a5,a4
  }

  return _ntoa_format(out, buffer, idx, maxlen, buf, len, negative, (unsigned int)base, prec, width, flags);
    1684:	01e12423          	sw	t5,8(sp)
    1688:	04012703          	lw	a4,64(sp)
    168c:	00e12223          	sw	a4,4(sp)
    1690:	01112023          	sw	a7,0(sp)
    1694:	00080893          	mv	a7,a6
    1698:	000f8813          	mv	a6,t6
    169c:	01010713          	addi	a4,sp,16
    16a0:	d8dff0ef          	jal	142c <_ntoa_format>
}
    16a4:	03c12083          	lw	ra,60(sp)
    16a8:	04010113          	addi	sp,sp,64
    16ac:	00008067          	ret

000016b0 <_ntoa_long_long>:
*
* @return Number of characters written to the buffer.
*
******************************************************************************/
static size_t _ntoa_long_long(out_fct_type out, char* buffer, size_t idx, size_t maxlen, unsigned long long value, bool negative, unsigned long long base, unsigned int prec, unsigned int width, unsigned int flags)
{
    16b0:	f8010113          	addi	sp,sp,-128
    16b4:	06112623          	sw	ra,108(sp)
    16b8:	06812423          	sw	s0,104(sp)
    16bc:	06912223          	sw	s1,100(sp)
    16c0:	07212023          	sw	s2,96(sp)
    16c4:	05312e23          	sw	s3,92(sp)
    16c8:	05412c23          	sw	s4,88(sp)
    16cc:	05512a23          	sw	s5,84(sp)
    16d0:	05612823          	sw	s6,80(sp)
    16d4:	05712623          	sw	s7,76(sp)
    16d8:	05812423          	sw	s8,72(sp)
    16dc:	05912223          	sw	s9,68(sp)
    16e0:	05a12023          	sw	s10,64(sp)
    16e4:	03b12e23          	sw	s11,60(sp)
    16e8:	00050b93          	mv	s7,a0
    16ec:	00058c13          	mv	s8,a1
    16f0:	00060c93          	mv	s9,a2
    16f4:	00068d13          	mv	s10,a3
    16f8:	00070993          	mv	s3,a4
    16fc:	00078413          	mv	s0,a5
    1700:	00080d93          	mv	s11,a6
    1704:	07112e23          	sw	a7,124(sp)
    1708:	00088a93          	mv	s5,a7
    170c:	08012903          	lw	s2,128(sp)
    1710:	08c12b03          	lw	s6,140(sp)
  char buf[PRINTF_NTOA_BUFFER_SIZE];
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
    1714:	00f767b3          	or	a5,a4,a5
    1718:	00079463          	bnez	a5,1720 <_ntoa_long_long+0x70>
    flags &= ~FLAGS_HASH;
    171c:	fefb7b13          	andi	s6,s6,-17
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
    1720:	400b7493          	andi	s1,s6,1024
    1724:	04048e63          	beqz	s1,1780 <_ntoa_long_long+0xd0>
    1728:	0089e7b3          	or	a5,s3,s0
    172c:	0a078263          	beqz	a5,17d0 <_ntoa_long_long+0x120>
    1730:	00000493          	li	s1,0
    1734:	04c0006f          	j	1780 <_ntoa_long_long+0xd0>
    do {
      const char digit = (char)(value % base);
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1738:	03050513          	addi	a0,a0,48
    173c:	0ff57793          	zext.b	a5,a0
    1740:	00148a13          	addi	s4,s1,1
    1744:	03048713          	addi	a4,s1,48
    1748:	002704b3          	add	s1,a4,sp
    174c:	fef48023          	sb	a5,-32(s1)
      value /= base;
    1750:	000a8613          	mv	a2,s5
    1754:	00090693          	mv	a3,s2
    1758:	00098513          	mv	a0,s3
    175c:	00040593          	mv	a1,s0
    1760:	5b9010ef          	jal	3518 <__udivdi3>
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    1764:	07246863          	bltu	s0,s2,17d4 <_ntoa_long_long+0x124>
    1768:	06890063          	beq	s2,s0,17c8 <_ntoa_long_long+0x118>
    176c:	01f00793          	li	a5,31
    1770:	0747e263          	bltu	a5,s4,17d4 <_ntoa_long_long+0x124>
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1774:	000a0493          	mv	s1,s4
      value /= base;
    1778:	00050993          	mv	s3,a0
    177c:	00058413          	mv	s0,a1
      const char digit = (char)(value % base);
    1780:	000a8613          	mv	a2,s5
    1784:	00090693          	mv	a3,s2
    1788:	00098513          	mv	a0,s3
    178c:	00040593          	mv	a1,s0
    1790:	238020ef          	jal	39c8 <__umoddi3>
    1794:	0ff57513          	zext.b	a0,a0
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1798:	00900793          	li	a5,9
    179c:	f8a7fee3          	bgeu	a5,a0,1738 <_ntoa_long_long+0x88>
    17a0:	020b7793          	andi	a5,s6,32
    17a4:	00078e63          	beqz	a5,17c0 <_ntoa_long_long+0x110>
    17a8:	04100793          	li	a5,65
    17ac:	00a787b3          	add	a5,a5,a0
    17b0:	0ff7f793          	zext.b	a5,a5
    17b4:	ff678793          	addi	a5,a5,-10
    17b8:	0ff7f793          	zext.b	a5,a5
    17bc:	f85ff06f          	j	1740 <_ntoa_long_long+0x90>
    17c0:	06100793          	li	a5,97
    17c4:	fe9ff06f          	j	17ac <_ntoa_long_long+0xfc>
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    17c8:	fb59f2e3          	bgeu	s3,s5,176c <_ntoa_long_long+0xbc>
    17cc:	0080006f          	j	17d4 <_ntoa_long_long+0x124>
  size_t len = 0U;
    17d0:	00000a13          	li	s4,0
  }

  return _ntoa_format(out, buffer, idx, maxlen, buf, len, negative, (unsigned int)base, prec, width, flags);
    17d4:	01612423          	sw	s6,8(sp)
    17d8:	08812783          	lw	a5,136(sp)
    17dc:	00f12223          	sw	a5,4(sp)
    17e0:	08412783          	lw	a5,132(sp)
    17e4:	00f12023          	sw	a5,0(sp)
    17e8:	000a8893          	mv	a7,s5
    17ec:	000d8813          	mv	a6,s11
    17f0:	000a0793          	mv	a5,s4
    17f4:	01010713          	addi	a4,sp,16
    17f8:	000d0693          	mv	a3,s10
    17fc:	000c8613          	mv	a2,s9
    1800:	000c0593          	mv	a1,s8
    1804:	000b8513          	mv	a0,s7
    1808:	c25ff0ef          	jal	142c <_ntoa_format>
}
    180c:	06c12083          	lw	ra,108(sp)
    1810:	06812403          	lw	s0,104(sp)
    1814:	06412483          	lw	s1,100(sp)
    1818:	06012903          	lw	s2,96(sp)
    181c:	05c12983          	lw	s3,92(sp)
    1820:	05812a03          	lw	s4,88(sp)
    1824:	05412a83          	lw	s5,84(sp)
    1828:	05012b03          	lw	s6,80(sp)
    182c:	04c12b83          	lw	s7,76(sp)
    1830:	04812c03          	lw	s8,72(sp)
    1834:	04412c83          	lw	s9,68(sp)
    1838:	04012d03          	lw	s10,64(sp)
    183c:	03c12d83          	lw	s11,60(sp)
    1840:	08010113          	addi	sp,sp,128
    1844:	00008067          	ret

00001848 <_etoa>:
*
* @note           Contributed by: Martijn Jasperse <m.jasperse@gmail.com>
*
******************************************************************************/
static size_t _etoa(out_fct_type out, char* buffer, size_t idx, size_t maxlen, double value, unsigned int prec, unsigned int width, unsigned int flags)
{
    1848:	f9010113          	addi	sp,sp,-112
    184c:	06112623          	sw	ra,108(sp)
    1850:	06812423          	sw	s0,104(sp)
    1854:	06912223          	sw	s1,100(sp)
    1858:	07212023          	sw	s2,96(sp)
    185c:	05312e23          	sw	s3,92(sp)
    1860:	05412c23          	sw	s4,88(sp)
    1864:	05512a23          	sw	s5,84(sp)
    1868:	05612823          	sw	s6,80(sp)
    186c:	05712623          	sw	s7,76(sp)
    1870:	05812423          	sw	s8,72(sp)
    1874:	00050913          	mv	s2,a0
    1878:	00058993          	mv	s3,a1
    187c:	00060b13          	mv	s6,a2
    1880:	00068a13          	mv	s4,a3
    1884:	00070493          	mv	s1,a4
    1888:	00078413          	mv	s0,a5
    188c:	00080b93          	mv	s7,a6
    1890:	00088a93          	mv	s5,a7
    1894:	07012c03          	lw	s8,112(sp)
  // check for NaN and special values
  if ((value != value) || (value > DBL_MAX) || (value < -DBL_MAX)) {
    1898:	00048613          	mv	a2,s1
    189c:	00040693          	mv	a3,s0
    18a0:	00048513          	mv	a0,s1
    18a4:	00040593          	mv	a1,s0
    18a8:	5e8030ef          	jal	4e90 <__eqdf2>
    18ac:	30051263          	bnez	a0,1bb0 <_etoa+0x368>
    18b0:	8101a603          	lw	a2,-2032(gp) # 6810 <__clz_tab+0x100>
    18b4:	8141a683          	lw	a3,-2028(gp) # 6814 <__clz_tab+0x104>
    18b8:	00048513          	mv	a0,s1
    18bc:	00040593          	mv	a1,s0
    18c0:	65c030ef          	jal	4f1c <__gedf2>
    18c4:	2ea04663          	bgtz	a0,1bb0 <_etoa+0x368>
    18c8:	8181a603          	lw	a2,-2024(gp) # 6818 <__clz_tab+0x108>
    18cc:	81c1a683          	lw	a3,-2020(gp) # 681c <__clz_tab+0x10c>
    18d0:	00048513          	mv	a0,s1
    18d4:	00040593          	mv	a1,s0
    18d8:	744030ef          	jal	501c <__ledf2>
    18dc:	2c054a63          	bltz	a0,1bb0 <_etoa+0x368>
    18e0:	05912223          	sw	s9,68(sp)
    18e4:	05a12023          	sw	s10,64(sp)
    18e8:	03b12e23          	sw	s11,60(sp)
    return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
  }

  // determine the sign
  const bool negative = value < 0;
  if (negative) {
    18ec:	00000613          	li	a2,0
    18f0:	00000693          	li	a3,0
    18f4:	00048513          	mv	a0,s1
    18f8:	00040593          	mv	a1,s0
    18fc:	720030ef          	jal	501c <__ledf2>
    1900:	30054463          	bltz	a0,1c08 <_etoa+0x3c0>
    1904:	00912823          	sw	s1,16(sp)
    1908:	00040c93          	mv	s9,s0
    value = -value;
  }

  // default precision
  if (!(flags & FLAGS_PRECISION)) {
    190c:	400c7793          	andi	a5,s8,1024
    1910:	02f12623          	sw	a5,44(sp)
    1914:	00079463          	bnez	a5,191c <_etoa+0xd4>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1918:	00400b93          	li	s7,4
    uint64_t U;
    double   F;
  } conv;

  conv.F = value;
  int exp2 = (int)((conv.U >> 52U) & 0x07FFU) - 1023;           // effectively log2
    191c:	014cd513          	srli	a0,s9,0x14
    1920:	7ff57513          	andi	a0,a0,2047
  conv.U = (conv.U & ((1ULL << 52U) - 1U)) | (1023ULL << 52U);  // drop the exponent so conv.F is now in [1,2)
    1924:	001007b7          	lui	a5,0x100
    1928:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf873f>
    192c:	00fcf7b3          	and	a5,s9,a5
    1930:	3ff00d37          	lui	s10,0x3ff00
    1934:	00fd6d33          	or	s10,s10,a5
  // now approximate log10 from the log2 integer part and an expansion of ln around 1.5
  int expval = (int)(0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
    1938:	c0150513          	addi	a0,a0,-1023
    193c:	0c1040ef          	jal	61fc <__floatsidf>
    1940:	8201a603          	lw	a2,-2016(gp) # 6820 <__clz_tab+0x110>
    1944:	8241a683          	lw	a3,-2012(gp) # 6824 <__clz_tab+0x114>
    1948:	7dc030ef          	jal	5124 <__muldf3>
    194c:	8281a603          	lw	a2,-2008(gp) # 6828 <__clz_tab+0x118>
    1950:	82c1a683          	lw	a3,-2004(gp) # 682c <__clz_tab+0x11c>
    1954:	4e4020ef          	jal	3e38 <__adddf3>
    1958:	00050d93          	mv	s11,a0
    195c:	00b12a23          	sw	a1,20(sp)
    1960:	8301a603          	lw	a2,-2000(gp) # 6830 <__clz_tab+0x120>
    1964:	8341a683          	lw	a3,-1996(gp) # 6834 <__clz_tab+0x124>
    1968:	01012703          	lw	a4,16(sp)
    196c:	00070513          	mv	a0,a4
    1970:	000d0593          	mv	a1,s10
    1974:	689030ef          	jal	57fc <__subdf3>
    1978:	8381a603          	lw	a2,-1992(gp) # 6838 <__clz_tab+0x128>
    197c:	83c1a683          	lw	a3,-1988(gp) # 683c <__clz_tab+0x12c>
    1980:	7a4030ef          	jal	5124 <__muldf3>
    1984:	00050613          	mv	a2,a0
    1988:	00058693          	mv	a3,a1
    198c:	000d8513          	mv	a0,s11
    1990:	01412583          	lw	a1,20(sp)
    1994:	4a4020ef          	jal	3e38 <__adddf3>
    1998:	76c040ef          	jal	6104 <__fixdfsi>
    199c:	00050d13          	mv	s10,a0
  // now we want to compute 10^expval but we want to be sure it won't overflow
  exp2 = (int)(expval * 3.321928094887362 + 0.5);
    19a0:	05d040ef          	jal	61fc <__floatsidf>
    19a4:	00a12a23          	sw	a0,20(sp)
    19a8:	00b12c23          	sw	a1,24(sp)
    19ac:	8401a603          	lw	a2,-1984(gp) # 6840 <__clz_tab+0x130>
    19b0:	8441a683          	lw	a3,-1980(gp) # 6844 <__clz_tab+0x134>
    19b4:	770030ef          	jal	5124 <__muldf3>
    19b8:	8481a603          	lw	a2,-1976(gp) # 6848 <__clz_tab+0x138>
    19bc:	84c1a683          	lw	a3,-1972(gp) # 684c <__clz_tab+0x13c>
    19c0:	478020ef          	jal	3e38 <__adddf3>
    19c4:	740040ef          	jal	6104 <__fixdfsi>
    19c8:	00050d93          	mv	s11,a0
  const double z  = expval * 2.302585092994046 - exp2 * 0.6931471805599453;
    19cc:	8501a603          	lw	a2,-1968(gp) # 6850 <__clz_tab+0x140>
    19d0:	8541a683          	lw	a3,-1964(gp) # 6854 <__clz_tab+0x144>
    19d4:	01412503          	lw	a0,20(sp)
    19d8:	01812583          	lw	a1,24(sp)
    19dc:	748030ef          	jal	5124 <__muldf3>
    19e0:	00a12a23          	sw	a0,20(sp)
    19e4:	00b12c23          	sw	a1,24(sp)
    19e8:	000d8513          	mv	a0,s11
    19ec:	011040ef          	jal	61fc <__floatsidf>
    19f0:	8581a603          	lw	a2,-1960(gp) # 6858 <__clz_tab+0x148>
    19f4:	85c1a683          	lw	a3,-1956(gp) # 685c <__clz_tab+0x14c>
    19f8:	72c030ef          	jal	5124 <__muldf3>
    19fc:	00050613          	mv	a2,a0
    1a00:	00058693          	mv	a3,a1
    1a04:	01412503          	lw	a0,20(sp)
    1a08:	01812583          	lw	a1,24(sp)
    1a0c:	5f1030ef          	jal	57fc <__subdf3>
  const double z2 = z * z;
    1a10:	00a12a23          	sw	a0,20(sp)
    1a14:	00050613          	mv	a2,a0
    1a18:	00b12c23          	sw	a1,24(sp)
    1a1c:	00058693          	mv	a3,a1
    1a20:	704030ef          	jal	5124 <__muldf3>
    1a24:	00a12e23          	sw	a0,28(sp)
    1a28:	02b12023          	sw	a1,32(sp)
  conv.U = (uint64_t)(exp2 + 1023) << 52U;
    1a2c:	3ffd8d93          	addi	s11,s11,1023
    1a30:	014d9d93          	slli	s11,s11,0x14
  // compute exp(z) using continued fractions, see https://en.wikipedia.org/wiki/Exponential_function#Continued_fractions_for_ex
  conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
    1a34:	01412803          	lw	a6,20(sp)
    1a38:	00080613          	mv	a2,a6
    1a3c:	01812783          	lw	a5,24(sp)
    1a40:	00078693          	mv	a3,a5
    1a44:	00080513          	mv	a0,a6
    1a48:	00078593          	mv	a1,a5
    1a4c:	3ec020ef          	jal	3e38 <__adddf3>
    1a50:	02a12223          	sw	a0,36(sp)
    1a54:	02b12423          	sw	a1,40(sp)
    1a58:	01412603          	lw	a2,20(sp)
    1a5c:	01812683          	lw	a3,24(sp)
    1a60:	8601a503          	lw	a0,-1952(gp) # 6860 <__clz_tab+0x150>
    1a64:	8641a583          	lw	a1,-1948(gp) # 6864 <__clz_tab+0x154>
    1a68:	595030ef          	jal	57fc <__subdf3>
    1a6c:	00a12a23          	sw	a0,20(sp)
    1a70:	00b12c23          	sw	a1,24(sp)
    1a74:	8681a603          	lw	a2,-1944(gp) # 6868 <__clz_tab+0x158>
    1a78:	86c1a683          	lw	a3,-1940(gp) # 686c <__clz_tab+0x15c>
    1a7c:	01c12503          	lw	a0,28(sp)
    1a80:	02012583          	lw	a1,32(sp)
    1a84:	47d020ef          	jal	4700 <__divdf3>
    1a88:	8701a603          	lw	a2,-1936(gp) # 6870 <__clz_tab+0x160>
    1a8c:	8741a683          	lw	a3,-1932(gp) # 6874 <__clz_tab+0x164>
    1a90:	3a8020ef          	jal	3e38 <__adddf3>
    1a94:	00050613          	mv	a2,a0
    1a98:	00058693          	mv	a3,a1
    1a9c:	01c12503          	lw	a0,28(sp)
    1aa0:	02012583          	lw	a1,32(sp)
    1aa4:	45d020ef          	jal	4700 <__divdf3>
    1aa8:	8781a603          	lw	a2,-1928(gp) # 6878 <__clz_tab+0x168>
    1aac:	87c1a683          	lw	a3,-1924(gp) # 687c <__clz_tab+0x16c>
    1ab0:	388020ef          	jal	3e38 <__adddf3>
    1ab4:	00050613          	mv	a2,a0
    1ab8:	00058693          	mv	a3,a1
    1abc:	01c12503          	lw	a0,28(sp)
    1ac0:	02012583          	lw	a1,32(sp)
    1ac4:	43d020ef          	jal	4700 <__divdf3>
    1ac8:	00050613          	mv	a2,a0
    1acc:	00058693          	mv	a3,a1
    1ad0:	01412503          	lw	a0,20(sp)
    1ad4:	01812583          	lw	a1,24(sp)
    1ad8:	360020ef          	jal	3e38 <__adddf3>
    1adc:	00050613          	mv	a2,a0
    1ae0:	00058693          	mv	a3,a1
    1ae4:	02412503          	lw	a0,36(sp)
    1ae8:	02812583          	lw	a1,40(sp)
    1aec:	415020ef          	jal	4700 <__divdf3>
    1af0:	8801a603          	lw	a2,-1920(gp) # 6880 <__clz_tab+0x170>
    1af4:	8841a683          	lw	a3,-1916(gp) # 6884 <__clz_tab+0x174>
    1af8:	340020ef          	jal	3e38 <__adddf3>
    1afc:	00000713          	li	a4,0
    1b00:	00070613          	mv	a2,a4
    1b04:	000d8693          	mv	a3,s11
    1b08:	61c030ef          	jal	5124 <__muldf3>
    1b0c:	00050d93          	mv	s11,a0
    1b10:	00a12c23          	sw	a0,24(sp)
    1b14:	00b12a23          	sw	a1,20(sp)
    1b18:	00b12e23          	sw	a1,28(sp)
  // correct for rounding errors
  if (value < conv.F) {
    1b1c:	01012703          	lw	a4,16(sp)
    1b20:	00070613          	mv	a2,a4
    1b24:	000c8693          	mv	a3,s9
    1b28:	3f4030ef          	jal	4f1c <__gedf2>
    1b2c:	02a05263          	blez	a0,1b50 <_etoa+0x308>
    expval--;
    1b30:	fffd0d13          	addi	s10,s10,-1 # 3fefffff <__freertos_irq_stack_top+0x3fef873f>
    conv.F /= 10;
    1b34:	8701a603          	lw	a2,-1936(gp) # 6870 <__clz_tab+0x160>
    1b38:	8741a683          	lw	a3,-1932(gp) # 6874 <__clz_tab+0x164>
    1b3c:	000d8513          	mv	a0,s11
    1b40:	01412583          	lw	a1,20(sp)
    1b44:	3bd020ef          	jal	4700 <__divdf3>
    1b48:	00a12c23          	sw	a0,24(sp)
    1b4c:	00b12e23          	sw	a1,28(sp)
  }

  // the exponent format is "%+03d" and largest value is "307", so set aside 4-5 characters
  unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
    1b50:	063d0793          	addi	a5,s10,99
    1b54:	0c600713          	li	a4,198
    1b58:	0cf76063          	bltu	a4,a5,1c18 <_etoa+0x3d0>
    1b5c:	00400d93          	li	s11,4

  // in "%g" mode, "prec" is the number of *significant figures* not decimals
  if (flags & FLAGS_ADAPT_EXP) {
    1b60:	014c1793          	slli	a5,s8,0x14
    1b64:	0c07d663          	bgez	a5,1c30 <_etoa+0x3e8>
    // do we want to fall-back to "%f" mode?
    if ((value >= 1e-4) && (value < 1e6)) {
    1b68:	8881a603          	lw	a2,-1912(gp) # 6888 <__clz_tab+0x178>
    1b6c:	88c1a683          	lw	a3,-1908(gp) # 688c <__clz_tab+0x17c>
    1b70:	01012703          	lw	a4,16(sp)
    1b74:	00070513          	mv	a0,a4
    1b78:	000c8593          	mv	a1,s9
    1b7c:	3a0030ef          	jal	4f1c <__gedf2>
    1b80:	0c054063          	bltz	a0,1c40 <_etoa+0x3f8>
    1b84:	8901a603          	lw	a2,-1904(gp) # 6890 <__clz_tab+0x180>
    1b88:	8941a683          	lw	a3,-1900(gp) # 6894 <__clz_tab+0x184>
    1b8c:	01012703          	lw	a4,16(sp)
    1b90:	00070513          	mv	a0,a4
    1b94:	000c8593          	mv	a1,s9
    1b98:	484030ef          	jal	501c <__ledf2>
    1b9c:	0a055263          	bgez	a0,1c40 <_etoa+0x3f8>
      if ((int)prec > expval) {
    1ba0:	097d5063          	bge	s10,s7,1c20 <_etoa+0x3d8>
        prec = (unsigned)((int)prec - expval - 1);
    1ba4:	41ab8d33          	sub	s10,s7,s10
    1ba8:	fffd0b93          	addi	s7,s10,-1
    1bac:	0780006f          	j	1c24 <_etoa+0x3dc>
    return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
    1bb0:	01812023          	sw	s8,0(sp)
    1bb4:	000a8893          	mv	a7,s5
    1bb8:	000b8813          	mv	a6,s7
    1bbc:	00048713          	mv	a4,s1
    1bc0:	00040793          	mv	a5,s0
    1bc4:	000a0693          	mv	a3,s4
    1bc8:	000b0613          	mv	a2,s6
    1bcc:	00098593          	mv	a1,s3
    1bd0:	00090513          	mv	a0,s2
    1bd4:	1e8000ef          	jal	1dbc <_ftoa>
    if (flags & FLAGS_LEFT) {
      while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
    }
  }
  return idx;
}
    1bd8:	06c12083          	lw	ra,108(sp)
    1bdc:	06812403          	lw	s0,104(sp)
    1be0:	06412483          	lw	s1,100(sp)
    1be4:	06012903          	lw	s2,96(sp)
    1be8:	05c12983          	lw	s3,92(sp)
    1bec:	05812a03          	lw	s4,88(sp)
    1bf0:	05412a83          	lw	s5,84(sp)
    1bf4:	05012b03          	lw	s6,80(sp)
    1bf8:	04c12b83          	lw	s7,76(sp)
    1bfc:	04812c03          	lw	s8,72(sp)
    1c00:	07010113          	addi	sp,sp,112
    1c04:	00008067          	ret
    value = -value;
    1c08:	00912823          	sw	s1,16(sp)
    1c0c:	80000cb7          	lui	s9,0x80000
    1c10:	008cccb3          	xor	s9,s9,s0
    1c14:	cf9ff06f          	j	190c <_etoa+0xc4>
  unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
    1c18:	00500d93          	li	s11,5
    1c1c:	f45ff06f          	j	1b60 <_etoa+0x318>
        prec = 0;
    1c20:	00000b93          	li	s7,0
      flags |= FLAGS_PRECISION;   // make sure _ftoa respects precision
    1c24:	400c6c13          	ori	s8,s8,1024
      minwidth = 0U;
    1c28:	00000d93          	li	s11,0
      expval   = 0;
    1c2c:	00000d13          	li	s10,0
  if (width > minwidth) {
    1c30:	035df263          	bgeu	s11,s5,1c54 <_etoa+0x40c>
    fwidth -= minwidth;
    1c34:	41ba87b3          	sub	a5,s5,s11
    1c38:	00f12a23          	sw	a5,20(sp)
    1c3c:	01c0006f          	j	1c58 <_etoa+0x410>
      if ((prec > 0) && (flags & FLAGS_PRECISION)) {
    1c40:	fe0b88e3          	beqz	s7,1c30 <_etoa+0x3e8>
    1c44:	02c12783          	lw	a5,44(sp)
    1c48:	fe0784e3          	beqz	a5,1c30 <_etoa+0x3e8>
        --prec;
    1c4c:	fffb8b93          	addi	s7,s7,-1
    1c50:	fe1ff06f          	j	1c30 <_etoa+0x3e8>
    fwidth = 0U;
    1c54:	00012a23          	sw	zero,20(sp)
  if ((flags & FLAGS_LEFT) && minwidth) {
    1c58:	002c7793          	andi	a5,s8,2
    1c5c:	02f12023          	sw	a5,32(sp)
    1c60:	00078663          	beqz	a5,1c6c <_etoa+0x424>
    1c64:	000d8463          	beqz	s11,1c6c <_etoa+0x424>
    fwidth = 0U;
    1c68:	00012a23          	sw	zero,20(sp)
  if (expval) {
    1c6c:	020d0663          	beqz	s10,1c98 <_etoa+0x450>
    value /= conv.F;
    1c70:	01812703          	lw	a4,24(sp)
    1c74:	01c12783          	lw	a5,28(sp)
    1c78:	00070613          	mv	a2,a4
    1c7c:	00078693          	mv	a3,a5
    1c80:	01012703          	lw	a4,16(sp)
    1c84:	00070513          	mv	a0,a4
    1c88:	000c8593          	mv	a1,s9
    1c8c:	275020ef          	jal	4700 <__divdf3>
    1c90:	00a12823          	sw	a0,16(sp)
    1c94:	00058c93          	mv	s9,a1
  idx = _ftoa(out, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);
    1c98:	00000613          	li	a2,0
    1c9c:	00000693          	li	a3,0
    1ca0:	00048513          	mv	a0,s1
    1ca4:	00040593          	mv	a1,s0
    1ca8:	374030ef          	jal	501c <__ledf2>
    1cac:	0a054c63          	bltz	a0,1d64 <_etoa+0x51c>
    1cb0:	fffff7b7          	lui	a5,0xfffff
    1cb4:	7ff78793          	addi	a5,a5,2047 # fffff7ff <__freertos_irq_stack_top+0xffff7f3f>
    1cb8:	00fc77b3          	and	a5,s8,a5
    1cbc:	00f12023          	sw	a5,0(sp)
    1cc0:	01412883          	lw	a7,20(sp)
    1cc4:	000b8813          	mv	a6,s7
    1cc8:	01012603          	lw	a2,16(sp)
    1ccc:	00060713          	mv	a4,a2
    1cd0:	000c8793          	mv	a5,s9
    1cd4:	000a0693          	mv	a3,s4
    1cd8:	000b0613          	mv	a2,s6
    1cdc:	00098593          	mv	a1,s3
    1ce0:	00090513          	mv	a0,s2
    1ce4:	0d8000ef          	jal	1dbc <_ftoa>
  if (minwidth) {
    1ce8:	0c0d8263          	beqz	s11,1dac <_etoa+0x564>
    out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
    1cec:	020c7c13          	andi	s8,s8,32
    1cf0:	080c0063          	beqz	s8,1d70 <_etoa+0x528>
    1cf4:	04500793          	li	a5,69
    1cf8:	00150413          	addi	s0,a0,1
    1cfc:	000a0693          	mv	a3,s4
    1d00:	00050613          	mv	a2,a0
    1d04:	00098593          	mv	a1,s3
    1d08:	00078513          	mv	a0,a5
    1d0c:	000900e7          	jalr	s2
    idx = _ntoa_long(out, buffer, idx, maxlen, (expval < 0) ? -expval : expval, expval < 0, 10, 0, minwidth-1, FLAGS_ZEROPAD | FLAGS_PLUS);
    1d10:	41fd5713          	srai	a4,s10,0x1f
    1d14:	01a746b3          	xor	a3,a4,s10
    1d18:	00500793          	li	a5,5
    1d1c:	00f12223          	sw	a5,4(sp)
    1d20:	fffd8d93          	addi	s11,s11,-1
    1d24:	01b12023          	sw	s11,0(sp)
    1d28:	00000893          	li	a7,0
    1d2c:	00a00813          	li	a6,10
    1d30:	01fd5793          	srli	a5,s10,0x1f
    1d34:	40e68733          	sub	a4,a3,a4
    1d38:	000a0693          	mv	a3,s4
    1d3c:	00040613          	mv	a2,s0
    1d40:	00098593          	mv	a1,s3
    1d44:	00090513          	mv	a0,s2
    1d48:	8a5ff0ef          	jal	15ec <_ntoa_long>
    if (flags & FLAGS_LEFT) {
    1d4c:	02012783          	lw	a5,32(sp)
    1d50:	04079263          	bnez	a5,1d94 <_etoa+0x54c>
    1d54:	04412c83          	lw	s9,68(sp)
    1d58:	04012d03          	lw	s10,64(sp)
    1d5c:	03c12d83          	lw	s11,60(sp)
    1d60:	e79ff06f          	j	1bd8 <_etoa+0x390>
  idx = _ftoa(out, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);
    1d64:	800007b7          	lui	a5,0x80000
    1d68:	0197ccb3          	xor	s9,a5,s9
    1d6c:	f45ff06f          	j	1cb0 <_etoa+0x468>
    out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
    1d70:	06500793          	li	a5,101
    1d74:	f85ff06f          	j	1cf8 <_etoa+0x4b0>
      while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
    1d78:	00150413          	addi	s0,a0,1
    1d7c:	000a0693          	mv	a3,s4
    1d80:	00050613          	mv	a2,a0
    1d84:	00098593          	mv	a1,s3
    1d88:	02000513          	li	a0,32
    1d8c:	000900e7          	jalr	s2
    1d90:	00040513          	mv	a0,s0
    1d94:	416507b3          	sub	a5,a0,s6
    1d98:	ff57e0e3          	bltu	a5,s5,1d78 <_etoa+0x530>
    1d9c:	04412c83          	lw	s9,68(sp)
    1da0:	04012d03          	lw	s10,64(sp)
    1da4:	03c12d83          	lw	s11,60(sp)
    1da8:	e31ff06f          	j	1bd8 <_etoa+0x390>
    1dac:	04412c83          	lw	s9,68(sp)
    1db0:	04012d03          	lw	s10,64(sp)
    1db4:	03c12d83          	lw	s11,60(sp)
    1db8:	e21ff06f          	j	1bd8 <_etoa+0x390>

00001dbc <_ftoa>:
{
    1dbc:	f7010113          	addi	sp,sp,-144
    1dc0:	08112623          	sw	ra,140(sp)
    1dc4:	08912223          	sw	s1,132(sp)
    1dc8:	07312e23          	sw	s3,124(sp)
    1dcc:	07412c23          	sw	s4,120(sp)
    1dd0:	07612823          	sw	s6,112(sp)
    1dd4:	07712623          	sw	s7,108(sp)
    1dd8:	07812423          	sw	s8,104(sp)
    1ddc:	07912223          	sw	s9,100(sp)
    1de0:	07a12023          	sw	s10,96(sp)
    1de4:	05b12e23          	sw	s11,92(sp)
    1de8:	00050b93          	mv	s7,a0
    1dec:	00058c13          	mv	s8,a1
    1df0:	00060c93          	mv	s9,a2
    1df4:	00068d13          	mv	s10,a3
    1df8:	00070a13          	mv	s4,a4
    1dfc:	00078993          	mv	s3,a5
    1e00:	00080493          	mv	s1,a6
    1e04:	00088b13          	mv	s6,a7
    1e08:	09012d83          	lw	s11,144(sp)
  if (value != value)
    1e0c:	00070613          	mv	a2,a4
    1e10:	00078693          	mv	a3,a5
    1e14:	00070513          	mv	a0,a4
    1e18:	00078593          	mv	a1,a5
    1e1c:	074030ef          	jal	4e90 <__eqdf2>
    1e20:	0c051463          	bnez	a0,1ee8 <_ftoa+0x12c>
  if (value < -DBL_MAX)
    1e24:	8181a603          	lw	a2,-2024(gp) # 6818 <__clz_tab+0x108>
    1e28:	81c1a683          	lw	a3,-2020(gp) # 681c <__clz_tab+0x10c>
    1e2c:	000a0513          	mv	a0,s4
    1e30:	00098593          	mv	a1,s3
    1e34:	1e8030ef          	jal	501c <__ledf2>
    1e38:	0c054e63          	bltz	a0,1f14 <_ftoa+0x158>
  if (value > DBL_MAX)
    1e3c:	8101a603          	lw	a2,-2032(gp) # 6810 <__clz_tab+0x100>
    1e40:	8141a683          	lw	a3,-2028(gp) # 6814 <__clz_tab+0x104>
    1e44:	000a0513          	mv	a0,s4
    1e48:	00098593          	mv	a1,s3
    1e4c:	0d0030ef          	jal	4f1c <__gedf2>
    1e50:	0ea04863          	bgtz	a0,1f40 <_ftoa+0x184>
  if ((value > PRINTF_MAX_FLOAT) || (value < -PRINTF_MAX_FLOAT)) {
    1e54:	8981a603          	lw	a2,-1896(gp) # 6898 <__clz_tab+0x188>
    1e58:	89c1a683          	lw	a3,-1892(gp) # 689c <__clz_tab+0x18c>
    1e5c:	000a0513          	mv	a0,s4
    1e60:	00098593          	mv	a1,s3
    1e64:	0b8030ef          	jal	4f1c <__gedf2>
    1e68:	12a04263          	bgtz	a0,1f8c <_ftoa+0x1d0>
    1e6c:	8a01a603          	lw	a2,-1888(gp) # 68a0 <__clz_tab+0x190>
    1e70:	8a41a683          	lw	a3,-1884(gp) # 68a4 <__clz_tab+0x194>
    1e74:	000a0513          	mv	a0,s4
    1e78:	00098593          	mv	a1,s3
    1e7c:	1a0030ef          	jal	501c <__ledf2>
    1e80:	10054663          	bltz	a0,1f8c <_ftoa+0x1d0>
    1e84:	08812423          	sw	s0,136(sp)
    1e88:	09212023          	sw	s2,128(sp)
    1e8c:	07512a23          	sw	s5,116(sp)
  if (value < 0) {
    1e90:	00000613          	li	a2,0
    1e94:	00000693          	li	a3,0
    1e98:	000a0513          	mv	a0,s4
    1e9c:	00098593          	mv	a1,s3
    1ea0:	17c030ef          	jal	501c <__ledf2>
    1ea4:	10054a63          	bltz	a0,1fb8 <_ftoa+0x1fc>
  bool negative = false;
    1ea8:	02012223          	sw	zero,36(sp)
  if (!(flags & FLAGS_PRECISION)) {
    1eac:	400df793          	andi	a5,s11,1024
    1eb0:	12078863          	beqz	a5,1fe0 <_ftoa+0x224>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1eb4:	00000413          	li	s0,0
  while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
    1eb8:	01f00793          	li	a5,31
    1ebc:	1287e663          	bltu	a5,s0,1fe8 <_ftoa+0x22c>
    1ec0:	00900793          	li	a5,9
    1ec4:	1297f263          	bgeu	a5,s1,1fe8 <_ftoa+0x22c>
    buf[len++] = '0';
    1ec8:	03040793          	addi	a5,s0,48
    1ecc:	02010713          	addi	a4,sp,32
    1ed0:	00e787b3          	add	a5,a5,a4
    1ed4:	03000713          	li	a4,48
    1ed8:	fee78023          	sb	a4,-32(a5) # 7fffffe0 <__freertos_irq_stack_top+0x7fff8720>
    prec--;
    1edc:	fff48493          	addi	s1,s1,-1
    buf[len++] = '0';
    1ee0:	00140413          	addi	s0,s0,1
    1ee4:	fd5ff06f          	j	1eb8 <_ftoa+0xfc>
    return _out_rev(out, buffer, idx, maxlen, "nan", 3, width, flags);
    1ee8:	000d8893          	mv	a7,s11
    1eec:	000b0813          	mv	a6,s6
    1ef0:	00300793          	li	a5,3
    1ef4:	00006737          	lui	a4,0x6
    1ef8:	40c70713          	addi	a4,a4,1036 # 640c <_data+0xc>
    1efc:	000d0693          	mv	a3,s10
    1f00:	000c8613          	mv	a2,s9
    1f04:	000c0593          	mv	a1,s8
    1f08:	000b8513          	mv	a0,s7
    1f0c:	c14ff0ef          	jal	1320 <_out_rev>
    1f10:	33c0006f          	j	224c <_ftoa+0x490>
    return _out_rev(out, buffer, idx, maxlen, "fni-", 4, width, flags);
    1f14:	000d8893          	mv	a7,s11
    1f18:	000b0813          	mv	a6,s6
    1f1c:	00400793          	li	a5,4
    1f20:	00006737          	lui	a4,0x6
    1f24:	41070713          	addi	a4,a4,1040 # 6410 <_data+0x10>
    1f28:	000d0693          	mv	a3,s10
    1f2c:	000c8613          	mv	a2,s9
    1f30:	000c0593          	mv	a1,s8
    1f34:	000b8513          	mv	a0,s7
    1f38:	be8ff0ef          	jal	1320 <_out_rev>
    1f3c:	3100006f          	j	224c <_ftoa+0x490>
    return _out_rev(out, buffer, idx, maxlen, (flags & FLAGS_PLUS) ? "fni+" : "fni", (flags & FLAGS_PLUS) ? 4U : 3U, width, flags);
    1f40:	004df793          	andi	a5,s11,4
    1f44:	02078a63          	beqz	a5,1f78 <_ftoa+0x1bc>
    1f48:	00006737          	lui	a4,0x6
    1f4c:	40070713          	addi	a4,a4,1024 # 6400 <_data>
    1f50:	02078a63          	beqz	a5,1f84 <_ftoa+0x1c8>
    1f54:	00400793          	li	a5,4
    1f58:	000d8893          	mv	a7,s11
    1f5c:	000b0813          	mv	a6,s6
    1f60:	000d0693          	mv	a3,s10
    1f64:	000c8613          	mv	a2,s9
    1f68:	000c0593          	mv	a1,s8
    1f6c:	000b8513          	mv	a0,s7
    1f70:	bb0ff0ef          	jal	1320 <_out_rev>
    1f74:	2d80006f          	j	224c <_ftoa+0x490>
    1f78:	00006737          	lui	a4,0x6
    1f7c:	40870713          	addi	a4,a4,1032 # 6408 <_data+0x8>
    1f80:	fd1ff06f          	j	1f50 <_ftoa+0x194>
    1f84:	00300793          	li	a5,3
    1f88:	fd1ff06f          	j	1f58 <_ftoa+0x19c>
    return _etoa(out, buffer, idx, maxlen, value, prec, width, flags);
    1f8c:	01b12023          	sw	s11,0(sp)
    1f90:	000b0893          	mv	a7,s6
    1f94:	00048813          	mv	a6,s1
    1f98:	000a0713          	mv	a4,s4
    1f9c:	00098793          	mv	a5,s3
    1fa0:	000d0693          	mv	a3,s10
    1fa4:	000c8613          	mv	a2,s9
    1fa8:	000c0593          	mv	a1,s8
    1fac:	000b8513          	mv	a0,s7
    1fb0:	899ff0ef          	jal	1848 <_etoa>
    1fb4:	2980006f          	j	224c <_ftoa+0x490>
    value = 0 - value;
    1fb8:	000a0613          	mv	a2,s4
    1fbc:	00098693          	mv	a3,s3
    1fc0:	00000513          	li	a0,0
    1fc4:	00000593          	li	a1,0
    1fc8:	035030ef          	jal	57fc <__subdf3>
    1fcc:	00050a13          	mv	s4,a0
    1fd0:	00058993          	mv	s3,a1
    negative = true;
    1fd4:	00100793          	li	a5,1
    1fd8:	02f12223          	sw	a5,36(sp)
    1fdc:	ed1ff06f          	j	1eac <_ftoa+0xf0>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1fe0:	00400493          	li	s1,4
    1fe4:	ed1ff06f          	j	1eb4 <_ftoa+0xf8>
  int whole = (int)value;
    1fe8:	000a0513          	mv	a0,s4
    1fec:	00098593          	mv	a1,s3
    1ff0:	114040ef          	jal	6104 <__fixdfsi>
    1ff4:	00050913          	mv	s2,a0
  double tmp = (value - whole) * pow10[prec];
    1ff8:	204040ef          	jal	61fc <__floatsidf>
    1ffc:	00050613          	mv	a2,a0
    2000:	00058693          	mv	a3,a1
    2004:	000a0513          	mv	a0,s4
    2008:	00098593          	mv	a1,s3
    200c:	7f0030ef          	jal	57fc <__subdf3>
    2010:	000067b7          	lui	a5,0x6
    2014:	00349713          	slli	a4,s1,0x3
    2018:	68078793          	addi	a5,a5,1664 # 6680 <pow10.0>
    201c:	00e787b3          	add	a5,a5,a4
    2020:	0047a803          	lw	a6,4(a5)
    2024:	0007a783          	lw	a5,0(a5)
    2028:	02f12423          	sw	a5,40(sp)
    202c:	03012623          	sw	a6,44(sp)
    2030:	00078613          	mv	a2,a5
    2034:	00080693          	mv	a3,a6
    2038:	0ec030ef          	jal	5124 <__muldf3>
    203c:	00a12e23          	sw	a0,28(sp)
    2040:	02b12023          	sw	a1,32(sp)
  unsigned long frac = (unsigned long)tmp;
    2044:	144040ef          	jal	6188 <__fixunsdfsi>
    2048:	00050a93          	mv	s5,a0
  diff = tmp - frac;
    204c:	268040ef          	jal	62b4 <__floatunsidf>
    2050:	00050613          	mv	a2,a0
    2054:	00058693          	mv	a3,a1
    2058:	01c12503          	lw	a0,28(sp)
    205c:	02012583          	lw	a1,32(sp)
    2060:	79c030ef          	jal	57fc <__subdf3>
    2064:	00a12e23          	sw	a0,28(sp)
    2068:	02b12023          	sw	a1,32(sp)
  if (diff > 0.5) {
    206c:	8481a603          	lw	a2,-1976(gp) # 6848 <__clz_tab+0x138>
    2070:	84c1a683          	lw	a3,-1972(gp) # 684c <__clz_tab+0x13c>
    2074:	6a9020ef          	jal	4f1c <__gedf2>
    2078:	06a05863          	blez	a0,20e8 <_ftoa+0x32c>
    ++frac;
    207c:	001a8a93          	addi	s5,s5,1
    if (frac >= pow10[prec]) {
    2080:	000a8513          	mv	a0,s5
    2084:	230040ef          	jal	62b4 <__floatunsidf>
    2088:	00050613          	mv	a2,a0
    208c:	00058693          	mv	a3,a1
    2090:	02812503          	lw	a0,40(sp)
    2094:	02c12583          	lw	a1,44(sp)
    2098:	785020ef          	jal	501c <__ledf2>
    209c:	00a04663          	bgtz	a0,20a8 <_ftoa+0x2ec>
      ++whole;
    20a0:	00190913          	addi	s2,s2,1
      frac = 0;
    20a4:	00000a93          	li	s5,0
  if (prec == 0U) {
    20a8:	06049663          	bnez	s1,2114 <_ftoa+0x358>
    diff = value - (double)whole;
    20ac:	00090513          	mv	a0,s2
    20b0:	14c040ef          	jal	61fc <__floatsidf>
    20b4:	00050613          	mv	a2,a0
    20b8:	00058693          	mv	a3,a1
    20bc:	000a0513          	mv	a0,s4
    20c0:	00098593          	mv	a1,s3
    20c4:	738030ef          	jal	57fc <__subdf3>
    if ((!(diff < 0.5) || (diff > 0.5)) && (whole & 1)) {
    20c8:	8481a603          	lw	a2,-1976(gp) # 6848 <__clz_tab+0x138>
    20cc:	84c1a683          	lw	a3,-1972(gp) # 684c <__clz_tab+0x13c>
    20d0:	74d020ef          	jal	501c <__ledf2>
    20d4:	0c054c63          	bltz	a0,21ac <_ftoa+0x3f0>
    20d8:	00197793          	andi	a5,s2,1
    20dc:	0c078863          	beqz	a5,21ac <_ftoa+0x3f0>
      ++whole;
    20e0:	00190913          	addi	s2,s2,1
    20e4:	0c80006f          	j	21ac <_ftoa+0x3f0>
  else if (diff < 0.5) {
    20e8:	8481a603          	lw	a2,-1976(gp) # 6848 <__clz_tab+0x138>
    20ec:	84c1a683          	lw	a3,-1972(gp) # 684c <__clz_tab+0x13c>
    20f0:	01c12503          	lw	a0,28(sp)
    20f4:	02012583          	lw	a1,32(sp)
    20f8:	725020ef          	jal	501c <__ledf2>
    20fc:	fa0546e3          	bltz	a0,20a8 <_ftoa+0x2ec>
  else if ((frac == 0U) || (frac & 1U)) {
    2100:	000a8663          	beqz	s5,210c <_ftoa+0x350>
    2104:	001af793          	andi	a5,s5,1
    2108:	fa0780e3          	beqz	a5,20a8 <_ftoa+0x2ec>
    ++frac;
    210c:	001a8a93          	addi	s5,s5,1
    2110:	f99ff06f          	j	20a8 <_ftoa+0x2ec>
    while (len < PRINTF_FTOA_BUFFER_SIZE) {
    2114:	01f00793          	li	a5,31
    2118:	0487e263          	bltu	a5,s0,215c <_ftoa+0x3a0>
      --count;
    211c:	fff48493          	addi	s1,s1,-1
      buf[len++] = (char)(48U + (frac % 10U));
    2120:	00a00793          	li	a5,10
    2124:	02faf733          	remu	a4,s5,a5
    2128:	00140693          	addi	a3,s0,1
    212c:	03070713          	addi	a4,a4,48
    2130:	03040613          	addi	a2,s0,48
    2134:	02010593          	addi	a1,sp,32
    2138:	00b60433          	add	s0,a2,a1
    213c:	fee40023          	sb	a4,-32(s0)
      if (!(frac /= 10U)) {
    2140:	02fad7b3          	divu	a5,s5,a5
    2144:	00900713          	li	a4,9
    2148:	01577863          	bgeu	a4,s5,2158 <_ftoa+0x39c>
    214c:	00078a93          	mv	s5,a5
      buf[len++] = (char)(48U + (frac % 10U));
    2150:	00068413          	mv	s0,a3
    2154:	fc1ff06f          	j	2114 <_ftoa+0x358>
    2158:	00068413          	mv	s0,a3
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
    215c:	01f00793          	li	a5,31
    2160:	0287e663          	bltu	a5,s0,218c <_ftoa+0x3d0>
    2164:	fff48793          	addi	a5,s1,-1
    2168:	02048263          	beqz	s1,218c <_ftoa+0x3d0>
      buf[len++] = '0';
    216c:	03040713          	addi	a4,s0,48
    2170:	02010693          	addi	a3,sp,32
    2174:	00d70733          	add	a4,a4,a3
    2178:	03000693          	li	a3,48
    217c:	fed70023          	sb	a3,-32(a4)
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
    2180:	00078493          	mv	s1,a5
      buf[len++] = '0';
    2184:	00140413          	addi	s0,s0,1
    2188:	fd5ff06f          	j	215c <_ftoa+0x3a0>
    if (len < PRINTF_FTOA_BUFFER_SIZE) {
    218c:	01f00793          	li	a5,31
    2190:	0087ee63          	bltu	a5,s0,21ac <_ftoa+0x3f0>
      buf[len++] = '.';
    2194:	03040793          	addi	a5,s0,48
    2198:	02010713          	addi	a4,sp,32
    219c:	00e787b3          	add	a5,a5,a4
    21a0:	02e00713          	li	a4,46
    21a4:	fee78023          	sb	a4,-32(a5)
    21a8:	00140413          	addi	s0,s0,1
  while (len < PRINTF_FTOA_BUFFER_SIZE) {
    21ac:	01f00793          	li	a5,31
    21b0:	0287ec63          	bltu	a5,s0,21e8 <_ftoa+0x42c>
    buf[len++] = (char)(48 + (whole % 10));
    21b4:	00a00713          	li	a4,10
    21b8:	02e967b3          	rem	a5,s2,a4
    21bc:	00140693          	addi	a3,s0,1
    21c0:	03078793          	addi	a5,a5,48
    21c4:	03040613          	addi	a2,s0,48
    21c8:	02010593          	addi	a1,sp,32
    21cc:	00b60433          	add	s0,a2,a1
    21d0:	fef40023          	sb	a5,-32(s0)
    if (!(whole /= 10)) {
    21d4:	02e94933          	div	s2,s2,a4
    21d8:	00090663          	beqz	s2,21e4 <_ftoa+0x428>
    buf[len++] = (char)(48 + (whole % 10));
    21dc:	00068413          	mv	s0,a3
    21e0:	fcdff06f          	j	21ac <_ftoa+0x3f0>
    21e4:	00068413          	mv	s0,a3
  if (!(flags & FLAGS_LEFT) && (flags & FLAGS_ZEROPAD)) {
    21e8:	003df713          	andi	a4,s11,3
    21ec:	00100793          	li	a5,1
    21f0:	08f70663          	beq	a4,a5,227c <_ftoa+0x4c0>
  if (len < PRINTF_FTOA_BUFFER_SIZE) {
    21f4:	01f00793          	li	a5,31
    21f8:	0287e263          	bltu	a5,s0,221c <_ftoa+0x460>
    if (negative) {
    21fc:	02412783          	lw	a5,36(sp)
    2200:	0c078063          	beqz	a5,22c0 <_ftoa+0x504>
      buf[len++] = '-';
    2204:	03040793          	addi	a5,s0,48
    2208:	02010713          	addi	a4,sp,32
    220c:	00e787b3          	add	a5,a5,a4
    2210:	02d00713          	li	a4,45
    2214:	fee78023          	sb	a4,-32(a5)
    2218:	00140413          	addi	s0,s0,1
  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
    221c:	000d8893          	mv	a7,s11
    2220:	000b0813          	mv	a6,s6
    2224:	00040793          	mv	a5,s0
    2228:	03010713          	addi	a4,sp,48
    222c:	000d0693          	mv	a3,s10
    2230:	000c8613          	mv	a2,s9
    2234:	000c0593          	mv	a1,s8
    2238:	000b8513          	mv	a0,s7
    223c:	8e4ff0ef          	jal	1320 <_out_rev>
    2240:	08812403          	lw	s0,136(sp)
    2244:	08012903          	lw	s2,128(sp)
    2248:	07412a83          	lw	s5,116(sp)
}
    224c:	08c12083          	lw	ra,140(sp)
    2250:	08412483          	lw	s1,132(sp)
    2254:	07c12983          	lw	s3,124(sp)
    2258:	07812a03          	lw	s4,120(sp)
    225c:	07012b03          	lw	s6,112(sp)
    2260:	06c12b83          	lw	s7,108(sp)
    2264:	06812c03          	lw	s8,104(sp)
    2268:	06412c83          	lw	s9,100(sp)
    226c:	06012d03          	lw	s10,96(sp)
    2270:	05c12d83          	lw	s11,92(sp)
    2274:	09010113          	addi	sp,sp,144
    2278:	00008067          	ret
    if (width && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
    227c:	020b0a63          	beqz	s6,22b0 <_ftoa+0x4f4>
    2280:	02412783          	lw	a5,36(sp)
    2284:	00079663          	bnez	a5,2290 <_ftoa+0x4d4>
    2288:	00cdf793          	andi	a5,s11,12
    228c:	02078263          	beqz	a5,22b0 <_ftoa+0x4f4>
      width--;
    2290:	fffb0b13          	addi	s6,s6,-1
    2294:	01c0006f          	j	22b0 <_ftoa+0x4f4>
      buf[len++] = '0';
    2298:	03040793          	addi	a5,s0,48
    229c:	02010713          	addi	a4,sp,32
    22a0:	00e787b3          	add	a5,a5,a4
    22a4:	03000713          	li	a4,48
    22a8:	fee78023          	sb	a4,-32(a5)
    22ac:	00140413          	addi	s0,s0,1
    while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
    22b0:	f56472e3          	bgeu	s0,s6,21f4 <_ftoa+0x438>
    22b4:	01f00793          	li	a5,31
    22b8:	fe87f0e3          	bgeu	a5,s0,2298 <_ftoa+0x4dc>
    22bc:	f39ff06f          	j	21f4 <_ftoa+0x438>
    else if (flags & FLAGS_PLUS) {
    22c0:	004df793          	andi	a5,s11,4
    22c4:	02078063          	beqz	a5,22e4 <_ftoa+0x528>
      buf[len++] = '+';  // ignore the space if the '+' exists
    22c8:	03040793          	addi	a5,s0,48
    22cc:	02010713          	addi	a4,sp,32
    22d0:	00e787b3          	add	a5,a5,a4
    22d4:	02b00713          	li	a4,43
    22d8:	fee78023          	sb	a4,-32(a5)
    22dc:	00140413          	addi	s0,s0,1
    22e0:	f3dff06f          	j	221c <_ftoa+0x460>
    else if (flags & FLAGS_SPACE) {
    22e4:	008df793          	andi	a5,s11,8
    22e8:	f2078ae3          	beqz	a5,221c <_ftoa+0x460>
      buf[len++] = ' ';
    22ec:	03040793          	addi	a5,s0,48
    22f0:	02010713          	addi	a4,sp,32
    22f4:	00e787b3          	add	a5,a5,a4
    22f8:	02000713          	li	a4,32
    22fc:	fee78023          	sb	a4,-32(a5)
    2300:	00140413          	addi	s0,s0,1
    2304:	f19ff06f          	j	221c <_ftoa+0x460>

00002308 <_vsnprintf>:
*                 terminating null character), or a negative value if an error
*                 occurred.
*
******************************************************************************/
static int _vsnprintf(out_fct_type out, char* buffer, const size_t maxlen, const char* format, va_list va)
{
    2308:	fa010113          	addi	sp,sp,-96
    230c:	04112e23          	sw	ra,92(sp)
    2310:	04812c23          	sw	s0,88(sp)
    2314:	04912a23          	sw	s1,84(sp)
    2318:	05212823          	sw	s2,80(sp)
    231c:	05312623          	sw	s3,76(sp)
    2320:	05412423          	sw	s4,72(sp)
    2324:	05512223          	sw	s5,68(sp)
    2328:	05612023          	sw	s6,64(sp)
    232c:	00050a13          	mv	s4,a0
    2330:	00058993          	mv	s3,a1
    2334:	00060913          	mv	s2,a2
    2338:	00d12e23          	sw	a3,28(sp)
    233c:	00e12c23          	sw	a4,24(sp)
  unsigned int flags, width, precision, n;
  size_t idx = 0U;

  if (!buffer) {
    2340:	140588e3          	beqz	a1,2c90 <_vsnprintf+0x988>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
          }
        }
        format++;
        break;
    2344:	00000493          	li	s1,0
  while (*format)
    2348:	01c12783          	lw	a5,28(sp)
    234c:	0007c503          	lbu	a0,0(a5)
    2350:	140506e3          	beqz	a0,2c9c <_vsnprintf+0x994>
    if (*format != '%') {
    2354:	02500713          	li	a4,37
    2358:	02e50663          	beq	a0,a4,2384 <_vsnprintf+0x7c>
      out(*format, buffer, idx++, maxlen);
    235c:	00148413          	addi	s0,s1,1
    2360:	00090693          	mv	a3,s2
    2364:	00048613          	mv	a2,s1
    2368:	00098593          	mv	a1,s3
    236c:	000a00e7          	jalr	s4
      format++;
    2370:	01c12783          	lw	a5,28(sp)
    2374:	00178793          	addi	a5,a5,1
    2378:	00f12e23          	sw	a5,28(sp)
      out(*format, buffer, idx++, maxlen);
    237c:	00040493          	mv	s1,s0
      continue;
    2380:	fc9ff06f          	j	2348 <_vsnprintf+0x40>
      format++;
    2384:	00178793          	addi	a5,a5,1
    2388:	00f12e23          	sw	a5,28(sp)
    flags = 0U;
    238c:	00000413          	li	s0,0
    2390:	0700006f          	j	2400 <_vsnprintf+0xf8>
        case '0': flags |= FLAGS_ZEROPAD; format++; n = 1U; break;
    2394:	00146413          	ori	s0,s0,1
    2398:	00170713          	addi	a4,a4,1
    239c:	00e12e23          	sw	a4,28(sp)
    23a0:	00100a93          	li	s5,1
    23a4:	0580006f          	j	23fc <_vsnprintf+0xf4>
        case '-': flags |= FLAGS_LEFT;    format++; n = 1U; break;
    23a8:	00246413          	ori	s0,s0,2
    23ac:	00170713          	addi	a4,a4,1
    23b0:	00e12e23          	sw	a4,28(sp)
    23b4:	00100a93          	li	s5,1
    23b8:	0440006f          	j	23fc <_vsnprintf+0xf4>
        case '+': flags |= FLAGS_PLUS;    format++; n = 1U; break;
    23bc:	00446413          	ori	s0,s0,4
    23c0:	00170713          	addi	a4,a4,1
    23c4:	00e12e23          	sw	a4,28(sp)
    23c8:	00100a93          	li	s5,1
    23cc:	0300006f          	j	23fc <_vsnprintf+0xf4>
        case ' ': flags |= FLAGS_SPACE;   format++; n = 1U; break;
    23d0:	00846413          	ori	s0,s0,8
    23d4:	00170713          	addi	a4,a4,1
    23d8:	00e12e23          	sw	a4,28(sp)
    23dc:	00100a93          	li	s5,1
    23e0:	01c0006f          	j	23fc <_vsnprintf+0xf4>
        case '#': flags |= FLAGS_HASH;    format++; n = 1U; break;
    23e4:	01046413          	ori	s0,s0,16
    23e8:	00170713          	addi	a4,a4,1
    23ec:	00e12e23          	sw	a4,28(sp)
    23f0:	00100a93          	li	s5,1
    23f4:	0080006f          	j	23fc <_vsnprintf+0xf4>
      switch (*format) {
    23f8:	00000a93          	li	s5,0
    } while (n);
    23fc:	020a8a63          	beqz	s5,2430 <_vsnprintf+0x128>
      switch (*format) {
    2400:	01c12703          	lw	a4,28(sp)
    2404:	00074783          	lbu	a5,0(a4)
    2408:	fe078793          	addi	a5,a5,-32
    240c:	0ff7f613          	zext.b	a2,a5
    2410:	01000693          	li	a3,16
    2414:	fec6e2e3          	bltu	a3,a2,23f8 <_vsnprintf+0xf0>
    2418:	00261793          	slli	a5,a2,0x2
    241c:	000066b7          	lui	a3,0x6
    2420:	4e468693          	addi	a3,a3,1252 # 64e4 <_data+0xe4>
    2424:	00d787b3          	add	a5,a5,a3
    2428:	0007a783          	lw	a5,0(a5)
    242c:	00078067          	jr	a5
    if (_is_digit(*format)) {
    2430:	01c12783          	lw	a5,28(sp)
    2434:	0007c703          	lbu	a4,0(a5)
  return (ch >= '0') && (ch <= '9');
    2438:	fd070793          	addi	a5,a4,-48
    243c:	0ff7f793          	zext.b	a5,a5
    if (_is_digit(*format)) {
    2440:	00900693          	li	a3,9
    2444:	04f6f863          	bgeu	a3,a5,2494 <_vsnprintf+0x18c>
    else if (*format == '*') {
    2448:	02a00793          	li	a5,42
    244c:	04f70c63          	beq	a4,a5,24a4 <_vsnprintf+0x19c>
    width = 0U;
    2450:	000a8b13          	mv	s6,s5
    if (*format == '.') {
    2454:	01c12783          	lw	a5,28(sp)
    2458:	0007c683          	lbu	a3,0(a5)
    245c:	02e00713          	li	a4,46
    2460:	06e68a63          	beq	a3,a4,24d4 <_vsnprintf+0x1cc>
    switch (*format) {
    2464:	01c12703          	lw	a4,28(sp)
    2468:	00074783          	lbu	a5,0(a4)
    246c:	f9878793          	addi	a5,a5,-104
    2470:	0ff7f613          	zext.b	a2,a5
    2474:	01200693          	li	a3,18
    2478:	12c6e663          	bltu	a3,a2,25a4 <_vsnprintf+0x29c>
    247c:	00261793          	slli	a5,a2,0x2
    2480:	000066b7          	lui	a3,0x6
    2484:	52868693          	addi	a3,a3,1320 # 6528 <_data+0x128>
    2488:	00d787b3          	add	a5,a5,a3
    248c:	0007a783          	lw	a5,0(a5)
    2490:	00078067          	jr	a5
      width = _atoi(&format);
    2494:	01c10513          	addi	a0,sp,28
    2498:	e41fe0ef          	jal	12d8 <_atoi>
    249c:	00050b13          	mv	s6,a0
    24a0:	fb5ff06f          	j	2454 <_vsnprintf+0x14c>
      const int w = va_arg(va, int);
    24a4:	01812783          	lw	a5,24(sp)
    24a8:	00478713          	addi	a4,a5,4
    24ac:	00e12c23          	sw	a4,24(sp)
    24b0:	0007ab03          	lw	s6,0(a5)
      if (w < 0) {
    24b4:	000b4a63          	bltz	s6,24c8 <_vsnprintf+0x1c0>
      format++;
    24b8:	01c12783          	lw	a5,28(sp)
    24bc:	00178793          	addi	a5,a5,1
    24c0:	00f12e23          	sw	a5,28(sp)
    24c4:	f91ff06f          	j	2454 <_vsnprintf+0x14c>
        flags |= FLAGS_LEFT;    // reverse padding
    24c8:	00246413          	ori	s0,s0,2
        width = (unsigned int)-w;
    24cc:	41600b33          	neg	s6,s6
    24d0:	fe9ff06f          	j	24b8 <_vsnprintf+0x1b0>
      flags |= FLAGS_PRECISION;
    24d4:	40046413          	ori	s0,s0,1024
      format++;
    24d8:	00178713          	addi	a4,a5,1
    24dc:	00e12e23          	sw	a4,28(sp)
      if (_is_digit(*format)) {
    24e0:	0017c703          	lbu	a4,1(a5)
  return (ch >= '0') && (ch <= '9');
    24e4:	fd070793          	addi	a5,a4,-48
    24e8:	0ff7f793          	zext.b	a5,a5
      if (_is_digit(*format)) {
    24ec:	00900693          	li	a3,9
    24f0:	02f6f863          	bgeu	a3,a5,2520 <_vsnprintf+0x218>
      else if (*format == '*') {
    24f4:	02a00793          	li	a5,42
    24f8:	f6f716e3          	bne	a4,a5,2464 <_vsnprintf+0x15c>
        const int prec = (int)va_arg(va, int);
    24fc:	01812783          	lw	a5,24(sp)
    2500:	00478713          	addi	a4,a5,4
    2504:	00e12c23          	sw	a4,24(sp)
    2508:	0007aa83          	lw	s5,0(a5)
        precision = prec > 0 ? (unsigned int)prec : 0U;
    250c:	020ac263          	bltz	s5,2530 <_vsnprintf+0x228>
        format++;
    2510:	01c12783          	lw	a5,28(sp)
    2514:	00178793          	addi	a5,a5,1
    2518:	00f12e23          	sw	a5,28(sp)
    251c:	f49ff06f          	j	2464 <_vsnprintf+0x15c>
        precision = _atoi(&format);
    2520:	01c10513          	addi	a0,sp,28
    2524:	db5fe0ef          	jal	12d8 <_atoi>
    2528:	00050a93          	mv	s5,a0
    252c:	f39ff06f          	j	2464 <_vsnprintf+0x15c>
        precision = prec > 0 ? (unsigned int)prec : 0U;
    2530:	00000a93          	li	s5,0
    2534:	fddff06f          	j	2510 <_vsnprintf+0x208>
        flags |= FLAGS_LONG;
    2538:	10046613          	ori	a2,s0,256
        format++;
    253c:	00170793          	addi	a5,a4,1
    2540:	00f12e23          	sw	a5,28(sp)
        if (*format == 'l') {
    2544:	00174683          	lbu	a3,1(a4)
    2548:	06c00793          	li	a5,108
    254c:	00f68663          	beq	a3,a5,2558 <_vsnprintf+0x250>
        flags |= FLAGS_LONG;
    2550:	00060413          	mv	s0,a2
    2554:	0500006f          	j	25a4 <_vsnprintf+0x29c>
          flags |= FLAGS_LONG_LONG;
    2558:	30046413          	ori	s0,s0,768
          format++;
    255c:	00270713          	addi	a4,a4,2
    2560:	00e12e23          	sw	a4,28(sp)
    2564:	0400006f          	j	25a4 <_vsnprintf+0x29c>
        flags |= FLAGS_SHORT;
    2568:	08046613          	ori	a2,s0,128
        format++;
    256c:	00170793          	addi	a5,a4,1
    2570:	00f12e23          	sw	a5,28(sp)
        if (*format == 'h') {
    2574:	00174683          	lbu	a3,1(a4)
    2578:	06800793          	li	a5,104
    257c:	00f68663          	beq	a3,a5,2588 <_vsnprintf+0x280>
        flags |= FLAGS_SHORT;
    2580:	00060413          	mv	s0,a2
    2584:	0200006f          	j	25a4 <_vsnprintf+0x29c>
          flags |= FLAGS_CHAR;
    2588:	0c046413          	ori	s0,s0,192
          format++;
    258c:	00270713          	addi	a4,a4,2
    2590:	00e12e23          	sw	a4,28(sp)
    2594:	0100006f          	j	25a4 <_vsnprintf+0x29c>
        flags |= (sizeof(ptrdiff_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    2598:	10046413          	ori	s0,s0,256
        format++;
    259c:	00170713          	addi	a4,a4,1
    25a0:	00e12e23          	sw	a4,28(sp)
    switch (*format) {
    25a4:	01c12783          	lw	a5,28(sp)
    25a8:	0007c503          	lbu	a0,0(a5)
    25ac:	06700793          	li	a5,103
    25b0:	04a7ea63          	bltu	a5,a0,2604 <_vsnprintf+0x2fc>
    25b4:	02500793          	li	a5,37
    25b8:	6af56863          	bltu	a0,a5,2c68 <_vsnprintf+0x960>
    25bc:	fdb50793          	addi	a5,a0,-37
    25c0:	0ff7f693          	zext.b	a3,a5
    25c4:	04200713          	li	a4,66
    25c8:	6ad76063          	bltu	a4,a3,2c68 <_vsnprintf+0x960>
    25cc:	00269793          	slli	a5,a3,0x2
    25d0:	00006737          	lui	a4,0x6
    25d4:	57470713          	addi	a4,a4,1396 # 6574 <_data+0x174>
    25d8:	00e787b3          	add	a5,a5,a4
    25dc:	0007a783          	lw	a5,0(a5)
    25e0:	00078067          	jr	a5
        flags |= (sizeof(intmax_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    25e4:	20046413          	ori	s0,s0,512
        format++;
    25e8:	00170713          	addi	a4,a4,1
    25ec:	00e12e23          	sw	a4,28(sp)
        break;
    25f0:	fb5ff06f          	j	25a4 <_vsnprintf+0x29c>
        flags |= (sizeof(size_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    25f4:	10046413          	ori	s0,s0,256
        format++;
    25f8:	00170713          	addi	a4,a4,1
    25fc:	00e12e23          	sw	a4,28(sp)
        break;
    2600:	fa5ff06f          	j	25a4 <_vsnprintf+0x29c>
    switch (*format) {
    2604:	07800793          	li	a5,120
    2608:	66a7e063          	bltu	a5,a0,2c68 <_vsnprintf+0x960>
    260c:	06900793          	li	a5,105
    2610:	64f56c63          	bltu	a0,a5,2c68 <_vsnprintf+0x960>
    2614:	f9750713          	addi	a4,a0,-105
    2618:	00100793          	li	a5,1
    261c:	00e797b3          	sll	a5,a5,a4
    2620:	00009737          	lui	a4,0x9
    2624:	04170713          	addi	a4,a4,65 # 9041 <__freertos_irq_stack_top+0x1781>
    2628:	00e7f733          	and	a4,a5,a4
    262c:	04071263          	bnez	a4,2670 <_vsnprintf+0x368>
    2630:	0807f713          	andi	a4,a5,128
    2634:	5a071a63          	bnez	a4,2be8 <_vsnprintf+0x8e0>
    2638:	4007f793          	andi	a5,a5,1024
    263c:	62078663          	beqz	a5,2c68 <_vsnprintf+0x960>
    2640:	03712e23          	sw	s7,60(sp)
    2644:	03812c23          	sw	s8,56(sp)
    2648:	03912a23          	sw	s9,52(sp)
    264c:	03a12823          	sw	s10,48(sp)
      }

      case 's' : {
        const char* p = va_arg(va, char*);
    2650:	01812783          	lw	a5,24(sp)
    2654:	00478713          	addi	a4,a5,4
    2658:	00e12c23          	sw	a4,24(sp)
    265c:	0007ac03          	lw	s8,0(a5)
        unsigned int l = _strnlen_s(p, precision ? precision : (size_t)-1);
    2660:	4c0a9463          	bnez	s5,2b28 <_vsnprintf+0x820>
    2664:	fff00713          	li	a4,-1
    2668:	000c0793          	mv	a5,s8
    266c:	4880006f          	j	2af4 <_vsnprintf+0x7ec>
        if (*format == 'x' || *format == 'X') {
    2670:	06f00793          	li	a5,111
    2674:	02f50a63          	beq	a0,a5,26a8 <_vsnprintf+0x3a0>
    2678:	00a7ee63          	bltu	a5,a0,2694 <_vsnprintf+0x38c>
    267c:	05800793          	li	a5,88
    2680:	0af50c63          	beq	a0,a5,2738 <_vsnprintf+0x430>
    2684:	06200793          	li	a5,98
    2688:	00f51a63          	bne	a0,a5,269c <_vsnprintf+0x394>
        flags |= FLAGS_SHORT;
    268c:	00200813          	li	a6,2
    2690:	01c0006f          	j	26ac <_vsnprintf+0x3a4>
    2694:	07800793          	li	a5,120
    2698:	0af50463          	beq	a0,a5,2740 <_vsnprintf+0x438>
          flags &= ~FLAGS_HASH;   // no hash for dec format
    269c:	fef47413          	andi	s0,s0,-17
          base = 10U;
    26a0:	00a00813          	li	a6,10
    26a4:	0080006f          	j	26ac <_vsnprintf+0x3a4>
        flags |= FLAGS_SHORT;
    26a8:	00800813          	li	a6,8
        if (*format == 'X') {
    26ac:	05800793          	li	a5,88
    26b0:	08f50c63          	beq	a0,a5,2748 <_vsnprintf+0x440>
        if ((*format != 'i') && (*format != 'd')) {
    26b4:	06900793          	li	a5,105
    26b8:	00f50863          	beq	a0,a5,26c8 <_vsnprintf+0x3c0>
    26bc:	06400793          	li	a5,100
    26c0:	00f50463          	beq	a0,a5,26c8 <_vsnprintf+0x3c0>
          flags &= ~(FLAGS_PLUS | FLAGS_SPACE);
    26c4:	ff347413          	andi	s0,s0,-13
        if (flags & FLAGS_PRECISION) {
    26c8:	40047793          	andi	a5,s0,1024
    26cc:	00078463          	beqz	a5,26d4 <_vsnprintf+0x3cc>
          flags &= ~FLAGS_ZEROPAD;
    26d0:	ffe47413          	andi	s0,s0,-2
        if ((*format == 'i') || (*format == 'd')) {
    26d4:	06900793          	li	a5,105
    26d8:	06f50c63          	beq	a0,a5,2750 <_vsnprintf+0x448>
    26dc:	06400793          	li	a5,100
    26e0:	06f50863          	beq	a0,a5,2750 <_vsnprintf+0x448>
          if (flags & FLAGS_LONG_LONG) {
    26e4:	20047793          	andi	a5,s0,512
    26e8:	1a079c63          	bnez	a5,28a0 <_vsnprintf+0x598>
          else if (flags & FLAGS_LONG) {
    26ec:	10047793          	andi	a5,s0,256
    26f0:	20079063          	bnez	a5,28f0 <_vsnprintf+0x5e8>
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
    26f4:	04047793          	andi	a5,s0,64
    26f8:	22078a63          	beqz	a5,292c <_vsnprintf+0x624>
    26fc:	01812783          	lw	a5,24(sp)
    2700:	00478713          	addi	a4,a5,4
    2704:	00e12c23          	sw	a4,24(sp)
    2708:	0007c703          	lbu	a4,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, value, false, base, precision, width, flags);
    270c:	00812223          	sw	s0,4(sp)
    2710:	01612023          	sw	s6,0(sp)
    2714:	000a8893          	mv	a7,s5
    2718:	00000793          	li	a5,0
    271c:	00090693          	mv	a3,s2
    2720:	00048613          	mv	a2,s1
    2724:	00098593          	mv	a1,s3
    2728:	000a0513          	mv	a0,s4
    272c:	ec1fe0ef          	jal	15ec <_ntoa_long>
    2730:	00050493          	mv	s1,a0
    2734:	0780006f          	j	27ac <_vsnprintf+0x4a4>
          base = 10U;
    2738:	01000813          	li	a6,16
    273c:	f71ff06f          	j	26ac <_vsnprintf+0x3a4>
        flags |= FLAGS_SHORT;
    2740:	01000813          	li	a6,16
    2744:	f69ff06f          	j	26ac <_vsnprintf+0x3a4>
          flags |= FLAGS_UPPERCASE;
    2748:	02046413          	ori	s0,s0,32
    274c:	f69ff06f          	j	26b4 <_vsnprintf+0x3ac>
          if (flags & FLAGS_LONG_LONG) {
    2750:	20047793          	andi	a5,s0,512
    2754:	06079463          	bnez	a5,27bc <_vsnprintf+0x4b4>
          else if (flags & FLAGS_LONG) {
    2758:	10047793          	andi	a5,s0,256
    275c:	0c079663          	bnez	a5,2828 <_vsnprintf+0x520>
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
    2760:	04047793          	andi	a5,s0,64
    2764:	10078663          	beqz	a5,2870 <_vsnprintf+0x568>
    2768:	01812783          	lw	a5,24(sp)
    276c:	00478713          	addi	a4,a5,4
    2770:	00e12c23          	sw	a4,24(sp)
    2774:	0007c783          	lbu	a5,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned int)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    2778:	41f7d713          	srai	a4,a5,0x1f
    277c:	00f746b3          	xor	a3,a4,a5
    2780:	00812223          	sw	s0,4(sp)
    2784:	01612023          	sw	s6,0(sp)
    2788:	000a8893          	mv	a7,s5
    278c:	01f7d793          	srli	a5,a5,0x1f
    2790:	40e68733          	sub	a4,a3,a4
    2794:	00090693          	mv	a3,s2
    2798:	00048613          	mv	a2,s1
    279c:	00098593          	mv	a1,s3
    27a0:	000a0513          	mv	a0,s4
    27a4:	e49fe0ef          	jal	15ec <_ntoa_long>
    27a8:	00050493          	mv	s1,a0
        format++;
    27ac:	01c12783          	lw	a5,28(sp)
    27b0:	00178793          	addi	a5,a5,1
    27b4:	00f12e23          	sw	a5,28(sp)
        break;
    27b8:	b91ff06f          	j	2348 <_vsnprintf+0x40>
            const long long value = va_arg(va, long long);
    27bc:	01812783          	lw	a5,24(sp)
    27c0:	00778793          	addi	a5,a5,7
    27c4:	ff87f793          	andi	a5,a5,-8
    27c8:	00878713          	addi	a4,a5,8
    27cc:	00e12c23          	sw	a4,24(sp)
    27d0:	0007a703          	lw	a4,0(a5)
    27d4:	0047a583          	lw	a1,4(a5)
            idx = _ntoa_long_long(out, buffer, idx, maxlen, (unsigned long long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    27d8:	41f5d693          	srai	a3,a1,0x1f
    27dc:	00e6c7b3          	xor	a5,a3,a4
    27e0:	00b6c633          	xor	a2,a3,a1
    27e4:	40d78733          	sub	a4,a5,a3
    27e8:	00e7b7b3          	sltu	a5,a5,a4
    27ec:	40d606b3          	sub	a3,a2,a3
    27f0:	00812623          	sw	s0,12(sp)
    27f4:	01612423          	sw	s6,8(sp)
    27f8:	01512223          	sw	s5,4(sp)
    27fc:	00012023          	sw	zero,0(sp)
    2800:	00080893          	mv	a7,a6
    2804:	01f5d813          	srli	a6,a1,0x1f
    2808:	40f687b3          	sub	a5,a3,a5
    280c:	00090693          	mv	a3,s2
    2810:	00048613          	mv	a2,s1
    2814:	00098593          	mv	a1,s3
    2818:	000a0513          	mv	a0,s4
    281c:	e95fe0ef          	jal	16b0 <_ntoa_long_long>
    2820:	00050493          	mv	s1,a0
    2824:	f89ff06f          	j	27ac <_vsnprintf+0x4a4>
            const long value = va_arg(va, long);
    2828:	01812783          	lw	a5,24(sp)
    282c:	00478713          	addi	a4,a5,4
    2830:	00e12c23          	sw	a4,24(sp)
    2834:	0007a783          	lw	a5,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    2838:	41f7d713          	srai	a4,a5,0x1f
    283c:	00f746b3          	xor	a3,a4,a5
    2840:	00812223          	sw	s0,4(sp)
    2844:	01612023          	sw	s6,0(sp)
    2848:	000a8893          	mv	a7,s5
    284c:	01f7d793          	srli	a5,a5,0x1f
    2850:	40e68733          	sub	a4,a3,a4
    2854:	00090693          	mv	a3,s2
    2858:	00048613          	mv	a2,s1
    285c:	00098593          	mv	a1,s3
    2860:	000a0513          	mv	a0,s4
    2864:	d89fe0ef          	jal	15ec <_ntoa_long>
    2868:	00050493          	mv	s1,a0
    286c:	f41ff06f          	j	27ac <_vsnprintf+0x4a4>
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
    2870:	08047793          	andi	a5,s0,128
    2874:	00078c63          	beqz	a5,288c <_vsnprintf+0x584>
    2878:	01812783          	lw	a5,24(sp)
    287c:	00478713          	addi	a4,a5,4
    2880:	00e12c23          	sw	a4,24(sp)
    2884:	00079783          	lh	a5,0(a5)
    2888:	ef1ff06f          	j	2778 <_vsnprintf+0x470>
    288c:	01812783          	lw	a5,24(sp)
    2890:	00478713          	addi	a4,a5,4
    2894:	00e12c23          	sw	a4,24(sp)
    2898:	0007a783          	lw	a5,0(a5)
    289c:	eddff06f          	j	2778 <_vsnprintf+0x470>
            idx = _ntoa_long_long(out, buffer, idx, maxlen, va_arg(va, unsigned long long), false, base, precision, width, flags);
    28a0:	01812783          	lw	a5,24(sp)
    28a4:	00778793          	addi	a5,a5,7
    28a8:	ff87f793          	andi	a5,a5,-8
    28ac:	00878713          	addi	a4,a5,8
    28b0:	00e12c23          	sw	a4,24(sp)
    28b4:	0007a703          	lw	a4,0(a5)
    28b8:	0047a783          	lw	a5,4(a5)
    28bc:	00812623          	sw	s0,12(sp)
    28c0:	01612423          	sw	s6,8(sp)
    28c4:	01512223          	sw	s5,4(sp)
    28c8:	00012023          	sw	zero,0(sp)
    28cc:	00080893          	mv	a7,a6
    28d0:	00000813          	li	a6,0
    28d4:	00090693          	mv	a3,s2
    28d8:	00048613          	mv	a2,s1
    28dc:	00098593          	mv	a1,s3
    28e0:	000a0513          	mv	a0,s4
    28e4:	dcdfe0ef          	jal	16b0 <_ntoa_long_long>
    28e8:	00050493          	mv	s1,a0
    28ec:	ec1ff06f          	j	27ac <_vsnprintf+0x4a4>
            idx = _ntoa_long(out, buffer, idx, maxlen, va_arg(va, unsigned long), false, base, precision, width, flags);
    28f0:	01812783          	lw	a5,24(sp)
    28f4:	00478713          	addi	a4,a5,4
    28f8:	00e12c23          	sw	a4,24(sp)
    28fc:	0007a703          	lw	a4,0(a5)
    2900:	00812223          	sw	s0,4(sp)
    2904:	01612023          	sw	s6,0(sp)
    2908:	000a8893          	mv	a7,s5
    290c:	00000793          	li	a5,0
    2910:	00090693          	mv	a3,s2
    2914:	00048613          	mv	a2,s1
    2918:	00098593          	mv	a1,s3
    291c:	000a0513          	mv	a0,s4
    2920:	ccdfe0ef          	jal	15ec <_ntoa_long>
    2924:	00050493          	mv	s1,a0
    2928:	e85ff06f          	j	27ac <_vsnprintf+0x4a4>
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
    292c:	08047793          	andi	a5,s0,128
    2930:	00078c63          	beqz	a5,2948 <_vsnprintf+0x640>
    2934:	01812783          	lw	a5,24(sp)
    2938:	00478713          	addi	a4,a5,4
    293c:	00e12c23          	sw	a4,24(sp)
    2940:	0007d703          	lhu	a4,0(a5)
    2944:	dc9ff06f          	j	270c <_vsnprintf+0x404>
    2948:	01812783          	lw	a5,24(sp)
    294c:	00478713          	addi	a4,a5,4
    2950:	00e12c23          	sw	a4,24(sp)
    2954:	0007a703          	lw	a4,0(a5)
    2958:	db5ff06f          	j	270c <_vsnprintf+0x404>
        if (*format == 'F') flags |= FLAGS_UPPERCASE;
    295c:	04600793          	li	a5,70
    2960:	04f50a63          	beq	a0,a5,29b4 <_vsnprintf+0x6ac>
        idx = _ftoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
    2964:	01812783          	lw	a5,24(sp)
    2968:	00778793          	addi	a5,a5,7
    296c:	ff87f793          	andi	a5,a5,-8
    2970:	00878713          	addi	a4,a5,8
    2974:	00e12c23          	sw	a4,24(sp)
    2978:	0007a703          	lw	a4,0(a5)
    297c:	0047a783          	lw	a5,4(a5)
    2980:	00812023          	sw	s0,0(sp)
    2984:	000b0893          	mv	a7,s6
    2988:	000a8813          	mv	a6,s5
    298c:	00090693          	mv	a3,s2
    2990:	00048613          	mv	a2,s1
    2994:	00098593          	mv	a1,s3
    2998:	000a0513          	mv	a0,s4
    299c:	c20ff0ef          	jal	1dbc <_ftoa>
    29a0:	00050493          	mv	s1,a0
        format++;
    29a4:	01c12783          	lw	a5,28(sp)
    29a8:	00178793          	addi	a5,a5,1
    29ac:	00f12e23          	sw	a5,28(sp)
        break;
    29b0:	999ff06f          	j	2348 <_vsnprintf+0x40>
        if (*format == 'F') flags |= FLAGS_UPPERCASE;
    29b4:	02046413          	ori	s0,s0,32
    29b8:	fadff06f          	j	2964 <_vsnprintf+0x65c>
        if ((*format == 'g')||(*format == 'G')) flags |= FLAGS_ADAPT_EXP;
    29bc:	06700793          	li	a5,103
    29c0:	00f50663          	beq	a0,a5,29cc <_vsnprintf+0x6c4>
    29c4:	04700793          	li	a5,71
    29c8:	00f51863          	bne	a0,a5,29d8 <_vsnprintf+0x6d0>
    29cc:	000017b7          	lui	a5,0x1
    29d0:	80078793          	addi	a5,a5,-2048 # 800 <CUSTOM2+0x7a5>
    29d4:	00f46433          	or	s0,s0,a5
        if ((*format == 'E')||(*format == 'G')) flags |= FLAGS_UPPERCASE;
    29d8:	04500793          	li	a5,69
    29dc:	00f50663          	beq	a0,a5,29e8 <_vsnprintf+0x6e0>
    29e0:	04700793          	li	a5,71
    29e4:	00f51463          	bne	a0,a5,29ec <_vsnprintf+0x6e4>
    29e8:	02046413          	ori	s0,s0,32
        idx = _etoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
    29ec:	01812783          	lw	a5,24(sp)
    29f0:	00778793          	addi	a5,a5,7
    29f4:	ff87f793          	andi	a5,a5,-8
    29f8:	00878713          	addi	a4,a5,8
    29fc:	00e12c23          	sw	a4,24(sp)
    2a00:	0007a703          	lw	a4,0(a5)
    2a04:	0047a783          	lw	a5,4(a5)
    2a08:	00812023          	sw	s0,0(sp)
    2a0c:	000b0893          	mv	a7,s6
    2a10:	000a8813          	mv	a6,s5
    2a14:	00090693          	mv	a3,s2
    2a18:	00048613          	mv	a2,s1
    2a1c:	00098593          	mv	a1,s3
    2a20:	000a0513          	mv	a0,s4
    2a24:	e25fe0ef          	jal	1848 <_etoa>
    2a28:	00050493          	mv	s1,a0
        format++;
    2a2c:	01c12783          	lw	a5,28(sp)
    2a30:	00178793          	addi	a5,a5,1
    2a34:	00f12e23          	sw	a5,28(sp)
        break;
    2a38:	911ff06f          	j	2348 <_vsnprintf+0x40>
    2a3c:	03712e23          	sw	s7,60(sp)
        if (!(flags & FLAGS_LEFT)) {
    2a40:	00247413          	andi	s0,s0,2
    2a44:	06040a63          	beqz	s0,2ab8 <_vsnprintf+0x7b0>
        unsigned int l = 1U;
    2a48:	00100a93          	li	s5,1
        out((char)va_arg(va, int), buffer, idx++, maxlen);
    2a4c:	01812783          	lw	a5,24(sp)
    2a50:	00478713          	addi	a4,a5,4
    2a54:	00e12c23          	sw	a4,24(sp)
    2a58:	00148b93          	addi	s7,s1,1
    2a5c:	00090693          	mv	a3,s2
    2a60:	00048613          	mv	a2,s1
    2a64:	00098593          	mv	a1,s3
    2a68:	0007c503          	lbu	a0,0(a5)
    2a6c:	000a00e7          	jalr	s4
        if (flags & FLAGS_LEFT) {
    2a70:	06041863          	bnez	s0,2ae0 <_vsnprintf+0x7d8>
        format++;
    2a74:	01c12783          	lw	a5,28(sp)
    2a78:	00178793          	addi	a5,a5,1
    2a7c:	00f12e23          	sw	a5,28(sp)
        break;
    2a80:	000b8493          	mv	s1,s7
    2a84:	03c12b83          	lw	s7,60(sp)
    2a88:	8c1ff06f          	j	2348 <_vsnprintf+0x40>
            out(' ', buffer, idx++, maxlen);
    2a8c:	00148b93          	addi	s7,s1,1
    2a90:	00090693          	mv	a3,s2
    2a94:	00048613          	mv	a2,s1
    2a98:	00098593          	mv	a1,s3
    2a9c:	02000513          	li	a0,32
    2aa0:	000a00e7          	jalr	s4
          while (l++ < width) {
    2aa4:	000a8793          	mv	a5,s5
            out(' ', buffer, idx++, maxlen);
    2aa8:	000b8493          	mv	s1,s7
          while (l++ < width) {
    2aac:	00178a93          	addi	s5,a5,1
    2ab0:	fd67eee3          	bltu	a5,s6,2a8c <_vsnprintf+0x784>
    2ab4:	f99ff06f          	j	2a4c <_vsnprintf+0x744>
        unsigned int l = 1U;
    2ab8:	00100793          	li	a5,1
    2abc:	ff1ff06f          	j	2aac <_vsnprintf+0x7a4>
            out(' ', buffer, idx++, maxlen);
    2ac0:	001b8493          	addi	s1,s7,1
    2ac4:	00090693          	mv	a3,s2
    2ac8:	000b8613          	mv	a2,s7
    2acc:	00098593          	mv	a1,s3
    2ad0:	02000513          	li	a0,32
    2ad4:	000a00e7          	jalr	s4
          while (l++ < width) {
    2ad8:	00040a93          	mv	s5,s0
            out(' ', buffer, idx++, maxlen);
    2adc:	00048b93          	mv	s7,s1
          while (l++ < width) {
    2ae0:	001a8413          	addi	s0,s5,1
    2ae4:	fd6aeee3          	bltu	s5,s6,2ac0 <_vsnprintf+0x7b8>
    2ae8:	f8dff06f          	j	2a74 <_vsnprintf+0x76c>
  for (s = str; *s && maxsize--; ++s);
    2aec:	00178793          	addi	a5,a5,1
    2af0:	00068713          	mv	a4,a3
    2af4:	0007c683          	lbu	a3,0(a5)
    2af8:	00068663          	beqz	a3,2b04 <_vsnprintf+0x7fc>
    2afc:	fff70693          	addi	a3,a4,-1
    2b00:	fe0716e3          	bnez	a4,2aec <_vsnprintf+0x7e4>
  return (unsigned int)(s - str);
    2b04:	41878bb3          	sub	s7,a5,s8
        // pre padding
        if (flags & FLAGS_PRECISION) {
    2b08:	40047c93          	andi	s9,s0,1024
    2b0c:	000c8663          	beqz	s9,2b18 <_vsnprintf+0x810>
          l = (l < precision ? l : precision);
    2b10:	017af463          	bgeu	s5,s7,2b18 <_vsnprintf+0x810>
    2b14:	000a8b93          	mv	s7,s5
        }
        if (!(flags & FLAGS_LEFT)) {
    2b18:	00247d13          	andi	s10,s0,2
    2b1c:	060d1463          	bnez	s10,2b84 <_vsnprintf+0x87c>
    2b20:	03b12623          	sw	s11,44(sp)
    2b24:	02c0006f          	j	2b50 <_vsnprintf+0x848>
        unsigned int l = _strnlen_s(p, precision ? precision : (size_t)-1);
    2b28:	000a8713          	mv	a4,s5
    2b2c:	b3dff06f          	j	2668 <_vsnprintf+0x360>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
    2b30:	00148d93          	addi	s11,s1,1
    2b34:	00090693          	mv	a3,s2
    2b38:	00048613          	mv	a2,s1
    2b3c:	00098593          	mv	a1,s3
    2b40:	02000513          	li	a0,32
    2b44:	000a00e7          	jalr	s4
          while (l++ < width) {
    2b48:	00040b93          	mv	s7,s0
            out(' ', buffer, idx++, maxlen);
    2b4c:	000d8493          	mv	s1,s11
          while (l++ < width) {
    2b50:	001b8413          	addi	s0,s7,1
    2b54:	fd6beee3          	bltu	s7,s6,2b30 <_vsnprintf+0x828>
    2b58:	00040b93          	mv	s7,s0
    2b5c:	02c12d83          	lw	s11,44(sp)
    2b60:	0240006f          	j	2b84 <_vsnprintf+0x87c>
          }
        }
        // string output
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
    2b64:	00078a93          	mv	s5,a5
          out(*(p++), buffer, idx++, maxlen);
    2b68:	001c0c13          	addi	s8,s8,1
    2b6c:	00148413          	addi	s0,s1,1
    2b70:	00090693          	mv	a3,s2
    2b74:	00048613          	mv	a2,s1
    2b78:	00098593          	mv	a1,s3
    2b7c:	000a00e7          	jalr	s4
    2b80:	00040493          	mv	s1,s0
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
    2b84:	000c4503          	lbu	a0,0(s8)
    2b88:	00050863          	beqz	a0,2b98 <_vsnprintf+0x890>
    2b8c:	fc0c8ee3          	beqz	s9,2b68 <_vsnprintf+0x860>
    2b90:	fffa8793          	addi	a5,s5,-1
    2b94:	fc0a98e3          	bnez	s5,2b64 <_vsnprintf+0x85c>
        }
        // post padding
        if (flags & FLAGS_LEFT) {
    2b98:	040d1263          	bnez	s10,2bdc <_vsnprintf+0x8d4>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
          }
        }
        format++;
    2b9c:	01c12783          	lw	a5,28(sp)
    2ba0:	00178793          	addi	a5,a5,1
    2ba4:	00f12e23          	sw	a5,28(sp)
        break;
    2ba8:	03c12b83          	lw	s7,60(sp)
    2bac:	03812c03          	lw	s8,56(sp)
    2bb0:	03412c83          	lw	s9,52(sp)
    2bb4:	03012d03          	lw	s10,48(sp)
    2bb8:	f90ff06f          	j	2348 <_vsnprintf+0x40>
            out(' ', buffer, idx++, maxlen);
    2bbc:	00148a93          	addi	s5,s1,1
    2bc0:	00090693          	mv	a3,s2
    2bc4:	00048613          	mv	a2,s1
    2bc8:	00098593          	mv	a1,s3
    2bcc:	02000513          	li	a0,32
    2bd0:	000a00e7          	jalr	s4
          while (l++ < width) {
    2bd4:	00040b93          	mv	s7,s0
            out(' ', buffer, idx++, maxlen);
    2bd8:	000a8493          	mv	s1,s5
          while (l++ < width) {
    2bdc:	001b8413          	addi	s0,s7,1
    2be0:	fd6beee3          	bltu	s7,s6,2bbc <_vsnprintf+0x8b4>
    2be4:	fb9ff06f          	j	2b9c <_vsnprintf+0x894>
      }

      case 'p' : {
        width = sizeof(void*) * 2U;
        flags |= FLAGS_ZEROPAD | FLAGS_UPPERCASE;
    2be8:	02146413          	ori	s0,s0,33
        if (is_ll) {
          idx = _ntoa_long_long(out, buffer, idx, maxlen, (uintptr_t)va_arg(va, void*), false, 16U, precision, width, flags);
        }
        else {
#endif
          idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)((uintptr_t)va_arg(va, void*)), false, 16U, precision, width, flags);
    2bec:	01812783          	lw	a5,24(sp)
    2bf0:	00478713          	addi	a4,a5,4
    2bf4:	00e12c23          	sw	a4,24(sp)
    2bf8:	0007a703          	lw	a4,0(a5)
    2bfc:	00812223          	sw	s0,4(sp)
    2c00:	00800793          	li	a5,8
    2c04:	00f12023          	sw	a5,0(sp)
    2c08:	000a8893          	mv	a7,s5
    2c0c:	01000813          	li	a6,16
    2c10:	00000793          	li	a5,0
    2c14:	00090693          	mv	a3,s2
    2c18:	00048613          	mv	a2,s1
    2c1c:	00098593          	mv	a1,s3
    2c20:	000a0513          	mv	a0,s4
    2c24:	9c9fe0ef          	jal	15ec <_ntoa_long>
    2c28:	00050493          	mv	s1,a0
#if defined(PRINTF_SUPPORT_LONG_LONG)
        }
#endif
        format++;
    2c2c:	01c12783          	lw	a5,28(sp)
    2c30:	00178793          	addi	a5,a5,1
    2c34:	00f12e23          	sw	a5,28(sp)
        break;
    2c38:	f10ff06f          	j	2348 <_vsnprintf+0x40>
      }

      case '%' :
        out('%', buffer, idx++, maxlen);
    2c3c:	00148413          	addi	s0,s1,1
    2c40:	00090693          	mv	a3,s2
    2c44:	00048613          	mv	a2,s1
    2c48:	00098593          	mv	a1,s3
    2c4c:	02500513          	li	a0,37
    2c50:	000a00e7          	jalr	s4
        format++;
    2c54:	01c12783          	lw	a5,28(sp)
    2c58:	00178793          	addi	a5,a5,1
    2c5c:	00f12e23          	sw	a5,28(sp)
        out('%', buffer, idx++, maxlen);
    2c60:	00040493          	mv	s1,s0
        break;
    2c64:	ee4ff06f          	j	2348 <_vsnprintf+0x40>

      default :
        out(*format, buffer, idx++, maxlen);
    2c68:	00148413          	addi	s0,s1,1
    2c6c:	00090693          	mv	a3,s2
    2c70:	00048613          	mv	a2,s1
    2c74:	00098593          	mv	a1,s3
    2c78:	000a00e7          	jalr	s4
        format++;
    2c7c:	01c12783          	lw	a5,28(sp)
    2c80:	00178793          	addi	a5,a5,1
    2c84:	00f12e23          	sw	a5,28(sp)
        out(*format, buffer, idx++, maxlen);
    2c88:	00040493          	mv	s1,s0
        break;
    2c8c:	ebcff06f          	j	2348 <_vsnprintf+0x40>
    out = _out_null;
    2c90:	00001a37          	lui	s4,0x1
    2c94:	2d4a0a13          	addi	s4,s4,724 # 12d4 <_out_null>
    2c98:	eacff06f          	j	2344 <_vsnprintf+0x3c>
    }
  }

  // termination
  out((char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
    2c9c:	0524e263          	bltu	s1,s2,2ce0 <_vsnprintf+0x9d8>
    2ca0:	fff90613          	addi	a2,s2,-1
    2ca4:	00090693          	mv	a3,s2
    2ca8:	00098593          	mv	a1,s3
    2cac:	00000513          	li	a0,0
    2cb0:	000a00e7          	jalr	s4

  // return written chars without terminating \0
  return (int)idx;
}
    2cb4:	00048513          	mv	a0,s1
    2cb8:	05c12083          	lw	ra,92(sp)
    2cbc:	05812403          	lw	s0,88(sp)
    2cc0:	05412483          	lw	s1,84(sp)
    2cc4:	05012903          	lw	s2,80(sp)
    2cc8:	04c12983          	lw	s3,76(sp)
    2ccc:	04812a03          	lw	s4,72(sp)
    2cd0:	04412a83          	lw	s5,68(sp)
    2cd4:	04012b03          	lw	s6,64(sp)
    2cd8:	06010113          	addi	sp,sp,96
    2cdc:	00008067          	ret
  out((char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
    2ce0:	00048613          	mv	a2,s1
    2ce4:	fc1ff06f          	j	2ca4 <_vsnprintf+0x99c>

00002ce8 <bsp_init>:
    *   1. UART baudrate
    *   2. 
    */
////////////////////////////////////////////////////////////////////////////////
    static void bsp_init()
    {
    2ce8:	fe010113          	addi	sp,sp,-32
    2cec:	00112e23          	sw	ra,28(sp)
        Uart_Config uartConfig;
        uartConfig.dataLength   = BITS_8;
    2cf0:	00800793          	li	a5,8
    2cf4:	00f12023          	sw	a5,0(sp)
        uartConfig.parity       = NONE;
    2cf8:	00012223          	sw	zero,4(sp)
        uartConfig.stop         = ONE;
    2cfc:	00012423          	sw	zero,8(sp)
        uartConfig.clockDivider = BSP_CLINT_HZ/(BSP_UART_BAUDRATE*BSP_UART_DATA_LEN)-1;
    2d00:	03500793          	li	a5,53
    2d04:	00f12623          	sw	a5,12(sp)
        uart_applyConfig(BSP_UART_TERMINAL, &uartConfig);    
    2d08:	00010593          	mv	a1,sp
    2d0c:	f8001537          	lui	a0,0xf8001
    2d10:	d00fe0ef          	jal	1210 <uart_applyConfig>
    }
    2d14:	01c12083          	lw	ra,28(sp)
    2d18:	02010113          	addi	sp,sp,32
    2d1c:	00008067          	ret

00002d20 <spi_cmdAvailability>:
    2d20:	00452503          	lw	a0,4(a0) # f8001004 <__freertos_irq_stack_top+0xf7ff9744>
 * @return The availability of command buffer space (lower 16 bits of SPI buffer)
 *
 ******************************************************************************/
    static u32 spi_cmdAvailability(u32 reg){
        return read_u32(reg + SPI_BUFFER) & 0xFFFF;
    }
    2d24:	01051513          	slli	a0,a0,0x10
    2d28:	01055513          	srli	a0,a0,0x10
    2d2c:	00008067          	ret

00002d30 <spi_rspOccupancy>:
    2d30:	00452503          	lw	a0,4(a0)
 * @return The occupancy of response buffer space (upper 16 bits of SPI buffer)
 *
 ******************************************************************************/
    static u32 spi_rspOccupancy(u32 reg){
        return read_u32(reg + SPI_BUFFER) >> 16;
    }
    2d34:	01055513          	srli	a0,a0,0x10
    2d38:	00008067          	ret

00002d3c <spi_write>:
 * @param reg The base address of the SPI register
 *
 * @param data The data to be written
 *
 ******************************************************************************/
    static void spi_write(u32 reg, u8 data){
    2d3c:	ff010113          	addi	sp,sp,-16
    2d40:	00112623          	sw	ra,12(sp)
    2d44:	00812423          	sw	s0,8(sp)
    2d48:	00912223          	sw	s1,4(sp)
    2d4c:	00050413          	mv	s0,a0
    2d50:	00058493          	mv	s1,a1
        while(spi_cmdAvailability(reg) == 0);
    2d54:	00040513          	mv	a0,s0
    2d58:	fc9ff0ef          	jal	2d20 <spi_cmdAvailability>
    2d5c:	fe050ce3          	beqz	a0,2d54 <spi_write+0x18>
        write_u32(data | SPI_CMD_WRITE, reg + SPI_DATA);
    2d60:	1004e493          	ori	s1,s1,256
        *((volatile u32*) address) = data;
    2d64:	00942023          	sw	s1,0(s0)
    }
    2d68:	00c12083          	lw	ra,12(sp)
    2d6c:	00812403          	lw	s0,8(sp)
    2d70:	00412483          	lw	s1,4(sp)
    2d74:	01010113          	addi	sp,sp,16
    2d78:	00008067          	ret

00002d7c <spi_read>:
 * @param reg The base address of the SPI register
 *
 * @return The data read from the SPI data register
 *
 ******************************************************************************/   
    static u8 spi_read(u32 reg){
    2d7c:	ff010113          	addi	sp,sp,-16
    2d80:	00112623          	sw	ra,12(sp)
    2d84:	00812423          	sw	s0,8(sp)
    2d88:	00050413          	mv	s0,a0
        while(spi_cmdAvailability(reg) == 0);
    2d8c:	00040513          	mv	a0,s0
    2d90:	f91ff0ef          	jal	2d20 <spi_cmdAvailability>
    2d94:	fe050ce3          	beqz	a0,2d8c <spi_read+0x10>
    2d98:	20000793          	li	a5,512
    2d9c:	00f42023          	sw	a5,0(s0)
        write_u32(SPI_CMD_READ, reg + SPI_DATA);
        while(spi_rspOccupancy(reg) == 0);
    2da0:	00040513          	mv	a0,s0
    2da4:	f8dff0ef          	jal	2d30 <spi_rspOccupancy>
    2da8:	fe050ce3          	beqz	a0,2da0 <spi_read+0x24>
        return *((volatile u32*) address);
    2dac:	00042503          	lw	a0,0(s0)
        return read_u32(reg + SPI_DATA);
    }
    2db0:	0ff57513          	zext.b	a0,a0
    2db4:	00c12083          	lw	ra,12(sp)
    2db8:	00812403          	lw	s0,8(sp)
    2dbc:	01010113          	addi	sp,sp,16
    2dc0:	00008067          	ret

00002dc4 <spi_select>:
 *
 * @param reg The base address of the SPI register
 * @param slaveId The ID of the slave device to select
 *
 ******************************************************************************/
    static void spi_select(u32 reg, u32 slaveId){
    2dc4:	ff010113          	addi	sp,sp,-16
    2dc8:	00112623          	sw	ra,12(sp)
    2dcc:	00812423          	sw	s0,8(sp)
    2dd0:	00912223          	sw	s1,4(sp)
    2dd4:	00050413          	mv	s0,a0
    2dd8:	00058493          	mv	s1,a1
        while(spi_cmdAvailability(reg) == 0);
    2ddc:	00040513          	mv	a0,s0
    2de0:	f41ff0ef          	jal	2d20 <spi_cmdAvailability>
    2de4:	fe050ce3          	beqz	a0,2ddc <spi_select+0x18>
        write_u32(slaveId | 0x80 | SPI_CMD_SS, reg + SPI_DATA);
    2de8:	000017b7          	lui	a5,0x1
    2dec:	88078793          	addi	a5,a5,-1920 # 880 <CUSTOM2+0x825>
    2df0:	00f4e4b3          	or	s1,s1,a5
        *((volatile u32*) address) = data;
    2df4:	00942023          	sw	s1,0(s0)
    }
    2df8:	00c12083          	lw	ra,12(sp)
    2dfc:	00812403          	lw	s0,8(sp)
    2e00:	00412483          	lw	s1,4(sp)
    2e04:	01010113          	addi	sp,sp,16
    2e08:	00008067          	ret

00002e0c <spi_diselect>:
 *
 * @param reg The base address of the SPI register
 * @param slaveId The ID of the slave device to deselect
 *
 ******************************************************************************/  
    static void spi_diselect(u32 reg, u32 slaveId){
    2e0c:	ff010113          	addi	sp,sp,-16
    2e10:	00112623          	sw	ra,12(sp)
    2e14:	00812423          	sw	s0,8(sp)
    2e18:	00912223          	sw	s1,4(sp)
    2e1c:	00050413          	mv	s0,a0
    2e20:	00058493          	mv	s1,a1
        while(spi_cmdAvailability(reg) == 0);
    2e24:	00040513          	mv	a0,s0
    2e28:	ef9ff0ef          	jal	2d20 <spi_cmdAvailability>
    2e2c:	fe050ce3          	beqz	a0,2e24 <spi_diselect+0x18>
        write_u32(slaveId | 0x00 | SPI_CMD_SS, reg + SPI_DATA);
    2e30:	000017b7          	lui	a5,0x1
    2e34:	80078793          	addi	a5,a5,-2048 # 800 <CUSTOM2+0x7a5>
    2e38:	00f4e4b3          	or	s1,s1,a5
    2e3c:	00942023          	sw	s1,0(s0)
    }
    2e40:	00c12083          	lw	ra,12(sp)
    2e44:	00812403          	lw	s0,8(sp)
    2e48:	00412483          	lw	s1,4(sp)
    2e4c:	01010113          	addi	sp,sp,16
    2e50:	00008067          	ret

00002e54 <spi_applyConfig>:
 * @param reg The base address of the SPI register
 * @param config Pointer to a Spi_Config structure containing the configuration settings
 *
 ******************************************************************************/
    static void spi_applyConfig(u32 reg, Spi_Config *config){
        write_u32((config->cpol << 0) | (config->cpha << 1) | (config->mode << 4), reg + SPI_CONFIG);
    2e54:	0005a783          	lw	a5,0(a1)
    2e58:	0045a703          	lw	a4,4(a1)
    2e5c:	00171713          	slli	a4,a4,0x1
    2e60:	00e7e7b3          	or	a5,a5,a4
    2e64:	0085a703          	lw	a4,8(a1)
    2e68:	00471713          	slli	a4,a4,0x4
    2e6c:	00e7e7b3          	or	a5,a5,a4
    2e70:	00f52423          	sw	a5,8(a0)
        write_u32(config->clkDivider, reg + SPI_CLK_DIVIDER);
    2e74:	00c5a783          	lw	a5,12(a1)
    2e78:	02f52023          	sw	a5,32(a0)
        write_u32(config->ssSetup, reg + SPI_SS_SETUP);
    2e7c:	0105a783          	lw	a5,16(a1)
    2e80:	02f52223          	sw	a5,36(a0)
        write_u32(config->ssHold, reg + SPI_SS_HOLD);
    2e84:	0145a783          	lw	a5,20(a1)
    2e88:	02f52423          	sw	a5,40(a0)
        write_u32(config->ssDisable, reg + SPI_SS_DISABLE);
    2e8c:	0185a783          	lw	a5,24(a1)
    2e90:	02f52623          	sw	a5,44(a0)
    }
    2e94:	00008067          	ret

00002e98 <spiReadData_fromFlash>:
	* @param reg SPI base address
	* @param cs 32-bit bitwise chip select setting
	* @param addr 32-bit address for reading
*
******************************************************************************/
    static u8 spiReadData_fromFlash(u32 reg, u32 cs, u32 addr){
    2e98:	ff010113          	addi	sp,sp,-16
    2e9c:	00112623          	sw	ra,12(sp)
    2ea0:	00812423          	sw	s0,8(sp)
    2ea4:	00912223          	sw	s1,4(sp)
    2ea8:	01212023          	sw	s2,0(sp)
    2eac:	00050413          	mv	s0,a0
    2eb0:	00058913          	mv	s2,a1
    2eb4:	00060493          	mv	s1,a2
    	u8 out;
        spi_select(reg, cs);
    2eb8:	f0dff0ef          	jal	2dc4 <spi_select>
        spi_write(reg, READ_DATA);
    2ebc:	00300593          	li	a1,3
    2ec0:	00040513          	mv	a0,s0
    2ec4:	e79ff0ef          	jal	2d3c <spi_write>
        spi_write(reg, (addr>>16) & 0xFF);
    2ec8:	0104d593          	srli	a1,s1,0x10
    2ecc:	0ff5f593          	zext.b	a1,a1
    2ed0:	00040513          	mv	a0,s0
    2ed4:	e69ff0ef          	jal	2d3c <spi_write>
        spi_write(reg, (addr>>8) & 0xFF);
    2ed8:	0084d593          	srli	a1,s1,0x8
    2edc:	0ff5f593          	zext.b	a1,a1
    2ee0:	00040513          	mv	a0,s0
    2ee4:	e59ff0ef          	jal	2d3c <spi_write>
        spi_write(reg, addr & 0xFF);
    2ee8:	0ff4f593          	zext.b	a1,s1
    2eec:	00040513          	mv	a0,s0
    2ef0:	e4dff0ef          	jal	2d3c <spi_write>
        out = spi_read(reg);
    2ef4:	00040513          	mv	a0,s0
    2ef8:	e85ff0ef          	jal	2d7c <spi_read>
    2efc:	00050493          	mv	s1,a0
        spi_diselect(reg, cs);
    2f00:	00090593          	mv	a1,s2
    2f04:	00040513          	mv	a0,s0
    2f08:	f05ff0ef          	jal	2e0c <spi_diselect>
        return out;

    }
    2f0c:	00048513          	mv	a0,s1
    2f10:	00c12083          	lw	ra,12(sp)
    2f14:	00812403          	lw	s0,8(sp)
    2f18:	00412483          	lw	s1,4(sp)
    2f1c:	00012903          	lw	s2,0(sp)
    2f20:	01010113          	addi	sp,sp,16
    2f24:	00008067          	ret

00002f28 <spiReadStatusRegister>:
	*
	* @param reg SPI base address
	* @param cs 32-bit bitwise chip select setting
*
******************************************************************************/
    static u8 spiReadStatusRegister(u32 reg, u32 cs){
    2f28:	ff010113          	addi	sp,sp,-16
    2f2c:	00112623          	sw	ra,12(sp)
    2f30:	00812423          	sw	s0,8(sp)
    2f34:	00912223          	sw	s1,4(sp)
    2f38:	01212023          	sw	s2,0(sp)
    2f3c:	00050413          	mv	s0,a0
    2f40:	00058913          	mv	s2,a1
    	spi_select(reg, cs);
    2f44:	e81ff0ef          	jal	2dc4 <spi_select>
    	spi_write(reg, READ_STATUS_REG); //Read Status Register
    2f48:	00500593          	li	a1,5
    2f4c:	00040513          	mv	a0,s0
    2f50:	dedff0ef          	jal	2d3c <spi_write>
    	u8 value = spi_read(reg);
    2f54:	00040513          	mv	a0,s0
    2f58:	e25ff0ef          	jal	2d7c <spi_read>
    2f5c:	00050493          	mv	s1,a0
    	spi_diselect(reg, cs);
    2f60:	00090593          	mv	a1,s2
    2f64:	00040513          	mv	a0,s0
    2f68:	ea5ff0ef          	jal	2e0c <spi_diselect>
    	return value;
    }
    2f6c:	00048513          	mv	a0,s1
    2f70:	00c12083          	lw	ra,12(sp)
    2f74:	00812403          	lw	s0,8(sp)
    2f78:	00412483          	lw	s1,4(sp)
    2f7c:	00012903          	lw	s2,0(sp)
    2f80:	01010113          	addi	sp,sp,16
    2f84:	00008067          	ret

00002f88 <spiWaitBusy>:
    {
    2f88:	ff010113          	addi	sp,sp,-16
    2f8c:	00112623          	sw	ra,12(sp)
    2f90:	00812423          	sw	s0,8(sp)
    2f94:	00912223          	sw	s1,4(sp)
    2f98:	01212023          	sw	s2,0(sp)
    2f9c:	00050913          	mv	s2,a0
    2fa0:	00058493          	mv	s1,a1
        u16 timeout=0;
    2fa4:	00000413          	li	s0,0
            bsp_uDelay(1*1000);
    2fa8:	f8b00637          	lui	a2,0xf8b00
    2fac:	02faf5b7          	lui	a1,0x2faf
    2fb0:	08058593          	addi	a1,a1,128 # 2faf080 <__freertos_irq_stack_top+0x2fa77c0>
    2fb4:	3e800513          	li	a0,1000
    2fb8:	a88fe0ef          	jal	1240 <clint_uDelay>
            out = spiReadStatusRegister(reg, cs);
    2fbc:	00048593          	mv	a1,s1
    2fc0:	00090513          	mv	a0,s2
    2fc4:	f65ff0ef          	jal	2f28 <spiReadStatusRegister>
            if((out & 0x01) ==0x00)
    2fc8:	00157513          	andi	a0,a0,1
    2fcc:	00050e63          	beqz	a0,2fe8 <spiWaitBusy+0x60>
            timeout++;
    2fd0:	00140413          	addi	s0,s0,1
    2fd4:	01041413          	slli	s0,s0,0x10
    2fd8:	01045413          	srli	s0,s0,0x10
            if(timeout >=400)
    2fdc:	18f00793          	li	a5,399
    2fe0:	fc87f4e3          	bgeu	a5,s0,2fa8 <spiWaitBusy+0x20>
                return 1; //Time out
    2fe4:	00100513          	li	a0,1
    }
    2fe8:	00c12083          	lw	ra,12(sp)
    2fec:	00812403          	lw	s0,8(sp)
    2ff0:	00412483          	lw	s1,4(sp)
    2ff4:	00012903          	lw	s2,0(sp)
    2ff8:	01010113          	addi	sp,sp,16
    2ffc:	00008067          	ret

00003000 <spiWriteStatusRegister>:
	* @param reg SPI base address
	* @param cs 32-bit bitwise chip select setting
	* @param data 8-bit data
*
******************************************************************************/
    static void spiWriteStatusRegister(u32 reg, u32 cs, u8 data){
    3000:	ff010113          	addi	sp,sp,-16
    3004:	00112623          	sw	ra,12(sp)
    3008:	00812423          	sw	s0,8(sp)
    300c:	00912223          	sw	s1,4(sp)
    3010:	01212023          	sw	s2,0(sp)
    3014:	00050413          	mv	s0,a0
    3018:	00058493          	mv	s1,a1
    301c:	00060913          	mv	s2,a2

    	spi_select(reg, cs);
    3020:	da5ff0ef          	jal	2dc4 <spi_select>
		spi_write(reg, WRITE_STATUS_REG); //Write Status Register
    3024:	00100593          	li	a1,1
    3028:	00040513          	mv	a0,s0
    302c:	d11ff0ef          	jal	2d3c <spi_write>
		spi_write(reg, data); //Write Status Register
    3030:	00090593          	mv	a1,s2
    3034:	00040513          	mv	a0,s0
    3038:	d05ff0ef          	jal	2d3c <spi_write>
		spi_diselect(reg, cs);
    303c:	00048593          	mv	a1,s1
    3040:	00040513          	mv	a0,s0
    3044:	dc9ff0ef          	jal	2e0c <spi_diselect>
    }
    3048:	00c12083          	lw	ra,12(sp)
    304c:	00812403          	lw	s0,8(sp)
    3050:	00412483          	lw	s1,4(sp)
    3054:	00012903          	lw	s2,0(sp)
    3058:	01010113          	addi	sp,sp,16
    305c:	00008067          	ret

00003060 <macronix_disable_write_protect>:
    static void macronix_disable_write_protect (u32 reg, u32 cs){ // Disable SRWD (status register write protect)
    3060:	ff010113          	addi	sp,sp,-16
    3064:	00112623          	sw	ra,12(sp)
    3068:	00812423          	sw	s0,8(sp)
    306c:	00912223          	sw	s1,4(sp)
    3070:	00050413          	mv	s0,a0
    3074:	00058493          	mv	s1,a1
    	status=spiReadStatusRegister(reg,0);
    3078:	00000593          	li	a1,0
    307c:	eadff0ef          	jal	2f28 <spiReadStatusRegister>
    	spiWriteStatusRegister(reg,cs,status);
    3080:	04357613          	andi	a2,a0,67
    3084:	00048593          	mv	a1,s1
    3088:	00040513          	mv	a0,s0
    308c:	f75ff0ef          	jal	3000 <spiWriteStatusRegister>
    }
    3090:	00c12083          	lw	ra,12(sp)
    3094:	00812403          	lw	s0,8(sp)
    3098:	00412483          	lw	s1,4(sp)
    309c:	01010113          	addi	sp,sp,16
    30a0:	00008067          	ret

000030a4 <macronix_enable_write_protect>:
    static void macronix_enable_write_protect (u32 reg, u32 cs){ // Enable SRWD (status register write protect)
    30a4:	ff010113          	addi	sp,sp,-16
    30a8:	00112623          	sw	ra,12(sp)
    30ac:	00812423          	sw	s0,8(sp)
    30b0:	00050413          	mv	s0,a0
    	status=spiReadStatusRegister(reg,0);
    30b4:	00000593          	li	a1,0
    30b8:	e71ff0ef          	jal	2f28 <spiReadStatusRegister>
    	status= (status | 0xBC) & 0xFD;
    30bc:	0fd57613          	andi	a2,a0,253
    	spiWriteStatusRegister(reg,0,status);
    30c0:	0bc66613          	ori	a2,a2,188
    30c4:	00000593          	li	a1,0
    30c8:	00040513          	mv	a0,s0
    30cc:	f35ff0ef          	jal	3000 <spiWriteStatusRegister>
    }
    30d0:	00c12083          	lw	ra,12(sp)
    30d4:	00812403          	lw	s0,8(sp)
    30d8:	01010113          	addi	sp,sp,16
    30dc:	00008067          	ret

000030e0 <spiWriteEnable>:
	*
	* @param reg SPI base address
	* @param cs 32-bit bitwise chip select setting
*
******************************************************************************/
    static void spiWriteEnable(u32 reg, u32 cs){
    30e0:	ff010113          	addi	sp,sp,-16
    30e4:	00112623          	sw	ra,12(sp)
    30e8:	00812423          	sw	s0,8(sp)
    30ec:	00912223          	sw	s1,4(sp)
    30f0:	00050413          	mv	s0,a0
    30f4:	00058493          	mv	s1,a1
		spi_select(reg, cs);
    30f8:	ccdff0ef          	jal	2dc4 <spi_select>
		spi_write(reg, WRITE_ENABLE); // Write Enable Sequence
    30fc:	00600593          	li	a1,6
    3100:	00040513          	mv	a0,s0
    3104:	c39ff0ef          	jal	2d3c <spi_write>
		spi_diselect(reg, cs);
    3108:	00048593          	mv	a1,s1
    310c:	00040513          	mv	a0,s0
    3110:	cfdff0ef          	jal	2e0c <spi_diselect>
	}
    3114:	00c12083          	lw	ra,12(sp)
    3118:	00812403          	lw	s0,8(sp)
    311c:	00412483          	lw	s1,4(sp)
    3120:	01010113          	addi	sp,sp,16
    3124:	00008067          	ret

00003128 <spiSectorErase>:
    {
    3128:	ff010113          	addi	sp,sp,-16
    312c:	00112623          	sw	ra,12(sp)
    3130:	00812423          	sw	s0,8(sp)
    3134:	00912223          	sw	s1,4(sp)
    3138:	01212023          	sw	s2,0(sp)
    313c:	00050413          	mv	s0,a0
    3140:	00058493          	mv	s1,a1
    3144:	00060913          	mv	s2,a2
    	spiWriteEnable(reg,cs);
    3148:	f99ff0ef          	jal	30e0 <spiWriteEnable>
        spi_select(reg, cs);
    314c:	00048593          	mv	a1,s1
    3150:	00040513          	mv	a0,s0
    3154:	c71ff0ef          	jal	2dc4 <spi_select>
        spi_write(reg, SECTOR_ERASE);
    3158:	02000593          	li	a1,32
    315c:	00040513          	mv	a0,s0
    3160:	bddff0ef          	jal	2d3c <spi_write>
        spi_write(reg, (Addr>>16)&0xFF);
    3164:	01095593          	srli	a1,s2,0x10
    3168:	0ff5f593          	zext.b	a1,a1
    316c:	00040513          	mv	a0,s0
    3170:	bcdff0ef          	jal	2d3c <spi_write>
        spi_write(reg, (Addr>>8)&0xFF);
    3174:	00895593          	srli	a1,s2,0x8
    3178:	0ff5f593          	zext.b	a1,a1
    317c:	00040513          	mv	a0,s0
    3180:	bbdff0ef          	jal	2d3c <spi_write>
        spi_write(reg, Addr&0xFF);
    3184:	0ff97593          	zext.b	a1,s2
    3188:	00040513          	mv	a0,s0
    318c:	bb1ff0ef          	jal	2d3c <spi_write>
        spi_diselect(reg, cs);
    3190:	00048593          	mv	a1,s1
    3194:	00040513          	mv	a0,s0
    3198:	c75ff0ef          	jal	2e0c <spi_diselect>
        spiWaitBusy(reg,cs);
    319c:	00048593          	mv	a1,s1
    31a0:	00040513          	mv	a0,s0
    31a4:	de5ff0ef          	jal	2f88 <spiWaitBusy>
    }
    31a8:	00c12083          	lw	ra,12(sp)
    31ac:	00812403          	lw	s0,8(sp)
    31b0:	00412483          	lw	s1,4(sp)
    31b4:	00012903          	lw	s2,0(sp)
    31b8:	01010113          	addi	sp,sp,16
    31bc:	00008067          	ret

000031c0 <spiFlash_manufacturer_id_>:
    *
    * @param spi SPI port base address
    * @param cs 32-bit bitwise chip select setting.
*
******************************************************************************/
    static inline u8 spiFlash_manufacturer_id_(u32 spi, u32 cs){
    31c0:	ff010113          	addi	sp,sp,-16
    31c4:	00112623          	sw	ra,12(sp)
    31c8:	00812423          	sw	s0,8(sp)
    31cc:	00050413          	mv	s0,a0
#if defined(GD25_FLASH)
        spi_write(spi, 0x9E);
#else
        spi_write(spi, READ_MANUFACTURER);
    31d0:	09f00593          	li	a1,159
    31d4:	b69ff0ef          	jal	2d3c <spi_write>
        // spi_write(spi, 0x00);
        // spi_write(spi, 0x00);
        // spi_write(spi, 0x00);
#endif
        u8 mid = spi_read(spi);
    31d8:	00040513          	mv	a0,s0
    31dc:	ba1ff0ef          	jal	2d7c <spi_read>
    31e0:	00050413          	mv	s0,a0
        bsp_uDelay(300);
    31e4:	f8b00637          	lui	a2,0xf8b00
    31e8:	02faf5b7          	lui	a1,0x2faf
    31ec:	08058593          	addi	a1,a1,128 # 2faf080 <__freertos_irq_stack_top+0x2fa77c0>
    31f0:	12c00513          	li	a0,300
    31f4:	84cfe0ef          	jal	1240 <clint_uDelay>
        return mid;
    }
    31f8:	00040513          	mv	a0,s0
    31fc:	00c12083          	lw	ra,12(sp)
    3200:	00812403          	lw	s0,8(sp)
    3204:	01010113          	addi	sp,sp,16
    3208:	00008067          	ret

0000320c <spiFlash_manufacturer_id>:
    static u8 spiFlash_manufacturer_id(u32 spi, u32 cs){
    320c:	ff010113          	addi	sp,sp,-16
    3210:	00112623          	sw	ra,12(sp)
    3214:	00812423          	sw	s0,8(sp)
    3218:	00912223          	sw	s1,4(sp)
    321c:	01212023          	sw	s2,0(sp)
    3220:	00050413          	mv	s0,a0
    3224:	00058493          	mv	s1,a1
        spi_select(spi,cs);
    3228:	b9dff0ef          	jal	2dc4 <spi_select>
        id =spiFlash_manufacturer_id_(spi,cs);
    322c:	00048593          	mv	a1,s1
    3230:	00040513          	mv	a0,s0
    3234:	f8dff0ef          	jal	31c0 <spiFlash_manufacturer_id_>
    3238:	00050913          	mv	s2,a0
        spi_diselect(spi,cs);
    323c:	00048593          	mv	a1,s1
    3240:	00040513          	mv	a0,s0
    3244:	bc9ff0ef          	jal	2e0c <spi_diselect>
    }
    3248:	00090513          	mv	a0,s2
    324c:	00c12083          	lw	ra,12(sp)
    3250:	00812403          	lw	s0,8(sp)
    3254:	00412483          	lw	s1,4(sp)
    3258:	00012903          	lw	s2,0(sp)
    325c:	01010113          	addi	sp,sp,16
    3260:	00008067          	ret

00003264 <spiGlobalUnlock>:
    {
    3264:	ff010113          	addi	sp,sp,-16
    3268:	00112623          	sw	ra,12(sp)
    326c:	00812423          	sw	s0,8(sp)
    3270:	00912223          	sw	s1,4(sp)
    3274:	00050413          	mv	s0,a0
    3278:	00058493          	mv	s1,a1
    	spiWriteEnable(reg,cs);
    327c:	e65ff0ef          	jal	30e0 <spiWriteEnable>
        spi_select(reg, cs);
    3280:	00048593          	mv	a1,s1
    3284:	00040513          	mv	a0,s0
    3288:	b3dff0ef          	jal	2dc4 <spi_select>
        spi_write(reg, GLOBAL_UNLOCK);
    328c:	09800593          	li	a1,152
    3290:	00040513          	mv	a0,s0
    3294:	aa9ff0ef          	jal	2d3c <spi_write>
        spi_diselect(reg, cs);
    3298:	00048593          	mv	a1,s1
    329c:	00040513          	mv	a0,s0
    32a0:	b6dff0ef          	jal	2e0c <spi_diselect>
    	if (spiFlash_manufacturer_id(reg,cs) == MACRONIX_ID)
    32a4:	00048593          	mv	a1,s1
    32a8:	00040513          	mv	a0,s0
    32ac:	f61ff0ef          	jal	320c <spiFlash_manufacturer_id>
    32b0:	0c200793          	li	a5,194
    32b4:	00f50c63          	beq	a0,a5,32cc <spiGlobalUnlock+0x68>
    }
    32b8:	00c12083          	lw	ra,12(sp)
    32bc:	00812403          	lw	s0,8(sp)
    32c0:	00412483          	lw	s1,4(sp)
    32c4:	01010113          	addi	sp,sp,16
    32c8:	00008067          	ret
    		macronix_disable_write_protect(reg,cs);
    32cc:	00048593          	mv	a1,s1
    32d0:	00040513          	mv	a0,s0
    32d4:	d8dff0ef          	jal	3060 <macronix_disable_write_protect>
    }
    32d8:	fe1ff06f          	j	32b8 <spiGlobalUnlock+0x54>

000032dc <spiGlobalLock>:
    {
    32dc:	ff010113          	addi	sp,sp,-16
    32e0:	00112623          	sw	ra,12(sp)
    32e4:	00812423          	sw	s0,8(sp)
    32e8:	00912223          	sw	s1,4(sp)
    32ec:	00050413          	mv	s0,a0
    32f0:	00058493          	mv	s1,a1
    	spiWriteEnable(reg,cs);
    32f4:	dedff0ef          	jal	30e0 <spiWriteEnable>
        spi_select(reg, cs);
    32f8:	00048593          	mv	a1,s1
    32fc:	00040513          	mv	a0,s0
    3300:	ac5ff0ef          	jal	2dc4 <spi_select>
        spi_write(reg, GLOBAL_LOCK);
    3304:	07e00593          	li	a1,126
    3308:	00040513          	mv	a0,s0
    330c:	a31ff0ef          	jal	2d3c <spi_write>
        spi_diselect(reg, cs);
    3310:	00048593          	mv	a1,s1
    3314:	00040513          	mv	a0,s0
    3318:	af5ff0ef          	jal	2e0c <spi_diselect>
    	if (spiFlash_manufacturer_id(reg,cs) == MACRONIX_ID)
    331c:	00048593          	mv	a1,s1
    3320:	00040513          	mv	a0,s0
    3324:	ee9ff0ef          	jal	320c <spiFlash_manufacturer_id>
    3328:	0c200793          	li	a5,194
    332c:	00f50c63          	beq	a0,a5,3344 <spiGlobalLock+0x68>
    }
    3330:	00c12083          	lw	ra,12(sp)
    3334:	00812403          	lw	s0,8(sp)
    3338:	00412483          	lw	s1,4(sp)
    333c:	01010113          	addi	sp,sp,16
    3340:	00008067          	ret
    		macronix_enable_write_protect(reg,cs);
    3344:	00048593          	mv	a1,s1
    3348:	00040513          	mv	a0,s0
    334c:	d59ff0ef          	jal	30a4 <macronix_enable_write_protect>
    }
    3350:	fe1ff06f          	j	3330 <spiGlobalLock+0x54>

00003354 <bsp_printf>:
* @param format Format string followed by the arguments to be formatted.
* @param ... Variable arguments corresponding to the format specifiers in 'format'.
*
******************************************************************************/
    static int bsp_printf(const char* format, ...)
    {
    3354:	f6010113          	addi	sp,sp,-160
    3358:	06112e23          	sw	ra,124(sp)
    335c:	06812c23          	sw	s0,120(sp)
    3360:	08b12223          	sw	a1,132(sp)
    3364:	08c12423          	sw	a2,136(sp)
    3368:	08d12623          	sw	a3,140(sp)
    336c:	08e12823          	sw	a4,144(sp)
    3370:	08f12a23          	sw	a5,148(sp)
    3374:	09012c23          	sw	a6,152(sp)
    3378:	09112e23          	sw	a7,156(sp)
      va_list va;
      va_start(va, format);
    337c:	08410713          	addi	a4,sp,132
    3380:	06e12623          	sw	a4,108(sp)

      char buffer[MAX_STRING_BUFFER_SIZE];
        const int ret = _vsnprintf(_out_buffer, buffer, (size_t)-1, format, va);
    3384:	00050693          	mv	a3,a0
    3388:	fff00613          	li	a2,-1
    338c:	00810593          	addi	a1,sp,8
    3390:	00001537          	lui	a0,0x1
    3394:	2c450513          	addi	a0,a0,708 # 12c4 <_out_buffer>
    3398:	f71fe0ef          	jal	2308 <_vsnprintf>
    339c:	00050413          	mv	s0,a0
        _putchar_s(buffer);
    33a0:	00810513          	addi	a0,sp,8
    33a4:	f09fd0ef          	jal	12ac <_putchar_s>

      va_end(va);
      return ret;
    }
    33a8:	00040513          	mv	a0,s0
    33ac:	07c12083          	lw	ra,124(sp)
    33b0:	07812403          	lw	s0,120(sp)
    33b4:	0a010113          	addi	sp,sp,160
    33b8:	00008067          	ret

000033bc <spiInit>:
void spiInit(){
    33bc:	fd010113          	addi	sp,sp,-48
    33c0:	02112623          	sw	ra,44(sp)
    spiA.cpol       = 1;
    33c4:	00100793          	li	a5,1
    33c8:	00f12223          	sw	a5,4(sp)
    spiA.cpha       = 1;
    33cc:	00f12423          	sw	a5,8(sp)
    spiA.mode       = 0; 
    33d0:	00012623          	sw	zero,12(sp)
    spiA.clkDivider = 19;
    33d4:	01300793          	li	a5,19
    33d8:	00f12823          	sw	a5,16(sp)
    spiA.ssSetup    = 5;
    33dc:	00500793          	li	a5,5
    33e0:	00f12a23          	sw	a5,20(sp)
    spiA.ssHold     = 5;
    33e4:	00f12c23          	sw	a5,24(sp)
    spiA.ssDisable  = 5;
    33e8:	00f12e23          	sw	a5,28(sp)
    spi_applyConfig(SPI, &spiA);
    33ec:	00410593          	addi	a1,sp,4
    33f0:	f8006537          	lui	a0,0xf8006
    33f4:	a61ff0ef          	jal	2e54 <spi_applyConfig>
}
    33f8:	02c12083          	lw	ra,44(sp)
    33fc:	03010113          	addi	sp,sp,48
    3400:	00008067          	ret

00003404 <spiWriteData_toFlash>:
void spiWriteData_toFlash(u32 reg ,u32 cs, u32 addr){
    3404:	fe010113          	addi	sp,sp,-32
    3408:	00112e23          	sw	ra,28(sp)
    340c:	00812c23          	sw	s0,24(sp)
    3410:	00912a23          	sw	s1,20(sp)
    3414:	01212823          	sw	s2,16(sp)
    3418:	01312623          	sw	s3,12(sp)
    341c:	00050493          	mv	s1,a0
    3420:	00058993          	mv	s3,a1
    3424:	00060913          	mv	s2,a2
    spiGlobalUnlock(reg,cs);
    3428:	e3dff0ef          	jal	3264 <spiGlobalUnlock>
    spiSectorErase(reg,cs,addr);
    342c:	00090613          	mv	a2,s2
    3430:	00098593          	mv	a1,s3
    3434:	00048513          	mv	a0,s1
    3438:	cf1ff0ef          	jal	3128 <spiSectorErase>
    spiWriteEnable(reg,cs);
    343c:	00098593          	mv	a1,s3
    3440:	00048513          	mv	a0,s1
    3444:	c9dff0ef          	jal	30e0 <spiWriteEnable>
    spi_select(reg, 0);
    3448:	00000593          	li	a1,0
    344c:	00048513          	mv	a0,s1
    3450:	975ff0ef          	jal	2dc4 <spi_select>
    spi_write(reg, PAGE_PROGRAM_OP);
    3454:	00200593          	li	a1,2
    3458:	00048513          	mv	a0,s1
    345c:	8e1ff0ef          	jal	2d3c <spi_write>
    spi_write(reg, (addr>>16) & 0xFF);
    3460:	01095593          	srli	a1,s2,0x10
    3464:	0ff5f593          	zext.b	a1,a1
    3468:	00048513          	mv	a0,s1
    346c:	8d1ff0ef          	jal	2d3c <spi_write>
    spi_write(reg, (addr>>8) & 0xFF);
    3470:	00895593          	srli	a1,s2,0x8
    3474:	0ff5f593          	zext.b	a1,a1
    3478:	00048513          	mv	a0,s1
    347c:	8c1ff0ef          	jal	2d3c <spi_write>
    spi_write(reg, addr & 0xFF);
    3480:	0ff97593          	zext.b	a1,s2
    3484:	00048513          	mv	a0,s1
    3488:	8b5ff0ef          	jal	2d3c <spi_write>
    for(int i=0; i<LEN; i++)
    348c:	00000413          	li	s0,0
    3490:	0280006f          	j	34b8 <spiWriteData_toFlash+0xb4>
        spi_write(reg, i & 0xFF );
    3494:	0ff47593          	zext.b	a1,s0
    3498:	00048513          	mv	a0,s1
    349c:	8a1ff0ef          	jal	2d3c <spi_write>
        bsp_printf("Write address %x := %x \r\n", addr+i, i & 0xFF );
    34a0:	0ff47613          	zext.b	a2,s0
    34a4:	012405b3          	add	a1,s0,s2
    34a8:	00006537          	lui	a0,0x6
    34ac:	41850513          	addi	a0,a0,1048 # 6418 <_data+0x18>
    34b0:	ea5ff0ef          	jal	3354 <bsp_printf>
    for(int i=0; i<LEN; i++)
    34b4:	00140413          	addi	s0,s0,1
    34b8:	0ff00793          	li	a5,255
    34bc:	fc87dce3          	bge	a5,s0,3494 <spiWriteData_toFlash+0x90>
    spi_diselect(reg, cs);
    34c0:	00098593          	mv	a1,s3
    34c4:	00048513          	mv	a0,s1
    34c8:	945ff0ef          	jal	2e0c <spi_diselect>
    if (spiWaitBusy(reg,cs) == 1) bsp_printf("Timeout!\r\n");
    34cc:	00098593          	mv	a1,s3
    34d0:	00048513          	mv	a0,s1
    34d4:	ab5ff0ef          	jal	2f88 <spiWaitBusy>
    34d8:	00100793          	li	a5,1
    34dc:	02f50663          	beq	a0,a5,3508 <spiWriteData_toFlash+0x104>
    spiGlobalLock(reg,cs);
    34e0:	00098593          	mv	a1,s3
    34e4:	00048513          	mv	a0,s1
    34e8:	df5ff0ef          	jal	32dc <spiGlobalLock>
}
    34ec:	01c12083          	lw	ra,28(sp)
    34f0:	01812403          	lw	s0,24(sp)
    34f4:	01412483          	lw	s1,20(sp)
    34f8:	01012903          	lw	s2,16(sp)
    34fc:	00c12983          	lw	s3,12(sp)
    3500:	02010113          	addi	sp,sp,32
    3504:	00008067          	ret
    if (spiWaitBusy(reg,cs) == 1) bsp_printf("Timeout!\r\n");
    3508:	00006537          	lui	a0,0x6
    350c:	43450513          	addi	a0,a0,1076 # 6434 <_data+0x34>
    3510:	e45ff0ef          	jal	3354 <bsp_printf>
    3514:	fcdff06f          	j	34e0 <spiWriteData_toFlash+0xdc>

00003518 <__udivdi3>:
    3518:	00060813          	mv	a6,a2
    351c:	00050893          	mv	a7,a0
    3520:	00058713          	mv	a4,a1
    3524:	0e069063          	bnez	a3,3604 <__udivdi3+0xec>
    3528:	12c5fe63          	bgeu	a1,a2,3664 <__udivdi3+0x14c>
    352c:	000107b7          	lui	a5,0x10
    3530:	1ef66e63          	bltu	a2,a5,372c <__udivdi3+0x214>
    3534:	010007b7          	lui	a5,0x1000
    3538:	01800693          	li	a3,24
    353c:	00f67463          	bgeu	a2,a5,3544 <__udivdi3+0x2c>
    3540:	01000693          	li	a3,16
    3544:	00d65333          	srl	t1,a2,a3
    3548:	00003797          	auipc	a5,0x3
    354c:	1c878793          	addi	a5,a5,456 # 6710 <__clz_tab>
    3550:	006787b3          	add	a5,a5,t1
    3554:	0007c783          	lbu	a5,0(a5)
    3558:	02000313          	li	t1,32
    355c:	00d787b3          	add	a5,a5,a3
    3560:	40f306b3          	sub	a3,t1,a5
    3564:	00f30c63          	beq	t1,a5,357c <__udivdi3+0x64>
    3568:	00d59733          	sll	a4,a1,a3
    356c:	00f557b3          	srl	a5,a0,a5
    3570:	00d61833          	sll	a6,a2,a3
    3574:	00e7e733          	or	a4,a5,a4
    3578:	00d518b3          	sll	a7,a0,a3
    357c:	01085613          	srli	a2,a6,0x10
    3580:	02c75533          	divu	a0,a4,a2
    3584:	01081693          	slli	a3,a6,0x10
    3588:	0106d693          	srli	a3,a3,0x10
    358c:	0108d793          	srli	a5,a7,0x10
    3590:	02c77733          	remu	a4,a4,a2
    3594:	02a685b3          	mul	a1,a3,a0
    3598:	01071713          	slli	a4,a4,0x10
    359c:	00e7e7b3          	or	a5,a5,a4
    35a0:	00b7fc63          	bgeu	a5,a1,35b8 <__udivdi3+0xa0>
    35a4:	00f807b3          	add	a5,a6,a5
    35a8:	fff50713          	addi	a4,a0,-1
    35ac:	0107e463          	bltu	a5,a6,35b4 <__udivdi3+0x9c>
    35b0:	40b7e063          	bltu	a5,a1,39b0 <__udivdi3+0x498>
    35b4:	00070513          	mv	a0,a4
    35b8:	40b787b3          	sub	a5,a5,a1
    35bc:	02c7d733          	divu	a4,a5,a2
    35c0:	01089893          	slli	a7,a7,0x10
    35c4:	0108d893          	srli	a7,a7,0x10
    35c8:	02c7f7b3          	remu	a5,a5,a2
    35cc:	02e686b3          	mul	a3,a3,a4
    35d0:	01079793          	slli	a5,a5,0x10
    35d4:	00f8e8b3          	or	a7,a7,a5
    35d8:	00d8fe63          	bgeu	a7,a3,35f4 <__udivdi3+0xdc>
    35dc:	011808b3          	add	a7,a6,a7
    35e0:	fff70793          	addi	a5,a4,-1
    35e4:	0108e663          	bltu	a7,a6,35f0 <__udivdi3+0xd8>
    35e8:	ffe70713          	addi	a4,a4,-2
    35ec:	00d8e463          	bltu	a7,a3,35f4 <__udivdi3+0xdc>
    35f0:	00078713          	mv	a4,a5
    35f4:	01051513          	slli	a0,a0,0x10
    35f8:	00e56533          	or	a0,a0,a4
    35fc:	00000593          	li	a1,0
    3600:	00008067          	ret
    3604:	00d5f863          	bgeu	a1,a3,3614 <__udivdi3+0xfc>
    3608:	00000593          	li	a1,0
    360c:	00000513          	li	a0,0
    3610:	00008067          	ret
    3614:	000107b7          	lui	a5,0x10
    3618:	1ef6e863          	bltu	a3,a5,3808 <__udivdi3+0x2f0>
    361c:	01000737          	lui	a4,0x1000
    3620:	01800793          	li	a5,24
    3624:	00e6f463          	bgeu	a3,a4,362c <__udivdi3+0x114>
    3628:	01000793          	li	a5,16
    362c:	00f6d833          	srl	a6,a3,a5
    3630:	00003717          	auipc	a4,0x3
    3634:	0e070713          	addi	a4,a4,224 # 6710 <__clz_tab>
    3638:	01070733          	add	a4,a4,a6
    363c:	00074703          	lbu	a4,0(a4)
    3640:	02000893          	li	a7,32
    3644:	00f70733          	add	a4,a4,a5
    3648:	40e88833          	sub	a6,a7,a4
    364c:	1ee89663          	bne	a7,a4,3838 <__udivdi3+0x320>
    3650:	32b6e463          	bltu	a3,a1,3978 <__udivdi3+0x460>
    3654:	00c53533          	sltu	a0,a0,a2
    3658:	00153513          	seqz	a0,a0
    365c:	00000593          	li	a1,0
    3660:	00008067          	ret
    3664:	0c060c63          	beqz	a2,373c <__udivdi3+0x224>
    3668:	000107b7          	lui	a5,0x10
    366c:	2ef67c63          	bgeu	a2,a5,3964 <__udivdi3+0x44c>
    3670:	10063713          	sltiu	a4,a2,256
    3674:	00173713          	seqz	a4,a4
    3678:	00371713          	slli	a4,a4,0x3
    367c:	00e656b3          	srl	a3,a2,a4
    3680:	00003797          	auipc	a5,0x3
    3684:	09078793          	addi	a5,a5,144 # 6710 <__clz_tab>
    3688:	00d787b3          	add	a5,a5,a3
    368c:	0007c783          	lbu	a5,0(a5)
    3690:	02000693          	li	a3,32
    3694:	00e787b3          	add	a5,a5,a4
    3698:	40f68eb3          	sub	t4,a3,a5
    369c:	0cf69463          	bne	a3,a5,3764 <__udivdi3+0x24c>
    36a0:	40c587b3          	sub	a5,a1,a2
    36a4:	01065693          	srli	a3,a2,0x10
    36a8:	01061613          	slli	a2,a2,0x10
    36ac:	01065613          	srli	a2,a2,0x10
    36b0:	00100593          	li	a1,1
    36b4:	02d7d533          	divu	a0,a5,a3
    36b8:	0108d713          	srli	a4,a7,0x10
    36bc:	02d7f7b3          	remu	a5,a5,a3
    36c0:	02c50333          	mul	t1,a0,a2
    36c4:	01079793          	slli	a5,a5,0x10
    36c8:	00f767b3          	or	a5,a4,a5
    36cc:	0067fc63          	bgeu	a5,t1,36e4 <__udivdi3+0x1cc>
    36d0:	00f807b3          	add	a5,a6,a5
    36d4:	fff50713          	addi	a4,a0,-1
    36d8:	0107e463          	bltu	a5,a6,36e0 <__udivdi3+0x1c8>
    36dc:	2c67e463          	bltu	a5,t1,39a4 <__udivdi3+0x48c>
    36e0:	00070513          	mv	a0,a4
    36e4:	406787b3          	sub	a5,a5,t1
    36e8:	02d7d733          	divu	a4,a5,a3
    36ec:	01089893          	slli	a7,a7,0x10
    36f0:	0108d893          	srli	a7,a7,0x10
    36f4:	02d7f7b3          	remu	a5,a5,a3
    36f8:	02c70633          	mul	a2,a4,a2
    36fc:	01079793          	slli	a5,a5,0x10
    3700:	00f8e8b3          	or	a7,a7,a5
    3704:	00c8fe63          	bgeu	a7,a2,3720 <__udivdi3+0x208>
    3708:	011808b3          	add	a7,a6,a7
    370c:	fff70793          	addi	a5,a4,-1
    3710:	0108e663          	bltu	a7,a6,371c <__udivdi3+0x204>
    3714:	ffe70713          	addi	a4,a4,-2
    3718:	00c8e463          	bltu	a7,a2,3720 <__udivdi3+0x208>
    371c:	00078713          	mv	a4,a5
    3720:	01051513          	slli	a0,a0,0x10
    3724:	00e56533          	or	a0,a0,a4
    3728:	00008067          	ret
    372c:	10063693          	sltiu	a3,a2,256
    3730:	0016b693          	seqz	a3,a3
    3734:	00369693          	slli	a3,a3,0x3
    3738:	e0dff06f          	j	3544 <__udivdi3+0x2c>
    373c:	00000693          	li	a3,0
    3740:	00003797          	auipc	a5,0x3
    3744:	fd078793          	addi	a5,a5,-48 # 6710 <__clz_tab>
    3748:	00d787b3          	add	a5,a5,a3
    374c:	0007c783          	lbu	a5,0(a5)
    3750:	00000713          	li	a4,0
    3754:	02000693          	li	a3,32
    3758:	00e787b3          	add	a5,a5,a4
    375c:	40f68eb3          	sub	t4,a3,a5
    3760:	f4f680e3          	beq	a3,a5,36a0 <__udivdi3+0x188>
    3764:	01d61833          	sll	a6,a2,t4
    3768:	00f5d333          	srl	t1,a1,a5
    376c:	01085693          	srli	a3,a6,0x10
    3770:	02d35e33          	divu	t3,t1,a3
    3774:	01081613          	slli	a2,a6,0x10
    3778:	01d595b3          	sll	a1,a1,t4
    377c:	01065613          	srli	a2,a2,0x10
    3780:	00f557b3          	srl	a5,a0,a5
    3784:	00b7e7b3          	or	a5,a5,a1
    3788:	0107d713          	srli	a4,a5,0x10
    378c:	01d518b3          	sll	a7,a0,t4
    3790:	02d37333          	remu	t1,t1,a3
    3794:	03c605b3          	mul	a1,a2,t3
    3798:	01031313          	slli	t1,t1,0x10
    379c:	00676733          	or	a4,a4,t1
    37a0:	00b77e63          	bgeu	a4,a1,37bc <__udivdi3+0x2a4>
    37a4:	00e80733          	add	a4,a6,a4
    37a8:	fffe0513          	addi	a0,t3,-1
    37ac:	1f076463          	bltu	a4,a6,3994 <__udivdi3+0x47c>
    37b0:	1eb77263          	bgeu	a4,a1,3994 <__udivdi3+0x47c>
    37b4:	ffee0e13          	addi	t3,t3,-2
    37b8:	01070733          	add	a4,a4,a6
    37bc:	40b70733          	sub	a4,a4,a1
    37c0:	02d75533          	divu	a0,a4,a3
    37c4:	01079793          	slli	a5,a5,0x10
    37c8:	0107d793          	srli	a5,a5,0x10
    37cc:	02d77733          	remu	a4,a4,a3
    37d0:	02a60333          	mul	t1,a2,a0
    37d4:	01071713          	slli	a4,a4,0x10
    37d8:	00e7e7b3          	or	a5,a5,a4
    37dc:	0067fe63          	bgeu	a5,t1,37f8 <__udivdi3+0x2e0>
    37e0:	00f807b3          	add	a5,a6,a5
    37e4:	fff50713          	addi	a4,a0,-1
    37e8:	1907ee63          	bltu	a5,a6,3984 <__udivdi3+0x46c>
    37ec:	1867fc63          	bgeu	a5,t1,3984 <__udivdi3+0x46c>
    37f0:	ffe50513          	addi	a0,a0,-2
    37f4:	010787b3          	add	a5,a5,a6
    37f8:	010e1593          	slli	a1,t3,0x10
    37fc:	406787b3          	sub	a5,a5,t1
    3800:	00a5e5b3          	or	a1,a1,a0
    3804:	eb1ff06f          	j	36b4 <__udivdi3+0x19c>
    3808:	1006b793          	sltiu	a5,a3,256
    380c:	0017b793          	seqz	a5,a5
    3810:	00379793          	slli	a5,a5,0x3
    3814:	00f6d833          	srl	a6,a3,a5
    3818:	00003717          	auipc	a4,0x3
    381c:	ef870713          	addi	a4,a4,-264 # 6710 <__clz_tab>
    3820:	01070733          	add	a4,a4,a6
    3824:	00074703          	lbu	a4,0(a4)
    3828:	02000893          	li	a7,32
    382c:	00f70733          	add	a4,a4,a5
    3830:	40e88833          	sub	a6,a7,a4
    3834:	e0e88ee3          	beq	a7,a4,3650 <__udivdi3+0x138>
    3838:	00e65e33          	srl	t3,a2,a4
    383c:	010696b3          	sll	a3,a3,a6
    3840:	00de6e33          	or	t3,t3,a3
    3844:	00e5d8b3          	srl	a7,a1,a4
    3848:	010e5e93          	srli	t4,t3,0x10
    384c:	03d8d7b3          	divu	a5,a7,t4
    3850:	010e1313          	slli	t1,t3,0x10
    3854:	010595b3          	sll	a1,a1,a6
    3858:	01035313          	srli	t1,t1,0x10
    385c:	00e55733          	srl	a4,a0,a4
    3860:	00b76733          	or	a4,a4,a1
    3864:	01075693          	srli	a3,a4,0x10
    3868:	01061633          	sll	a2,a2,a6
    386c:	03d8f8b3          	remu	a7,a7,t4
    3870:	02f305b3          	mul	a1,t1,a5
    3874:	01089893          	slli	a7,a7,0x10
    3878:	0116e6b3          	or	a3,a3,a7
    387c:	00b6fe63          	bgeu	a3,a1,3898 <__udivdi3+0x380>
    3880:	00de06b3          	add	a3,t3,a3
    3884:	fff78893          	addi	a7,a5,-1
    3888:	11c6ea63          	bltu	a3,t3,399c <__udivdi3+0x484>
    388c:	10b6f863          	bgeu	a3,a1,399c <__udivdi3+0x484>
    3890:	ffe78793          	addi	a5,a5,-2
    3894:	01c686b3          	add	a3,a3,t3
    3898:	40b686b3          	sub	a3,a3,a1
    389c:	03d6d5b3          	divu	a1,a3,t4
    38a0:	01071713          	slli	a4,a4,0x10
    38a4:	01075713          	srli	a4,a4,0x10
    38a8:	03d6f6b3          	remu	a3,a3,t4
    38ac:	02b308b3          	mul	a7,t1,a1
    38b0:	01069693          	slli	a3,a3,0x10
    38b4:	00d76733          	or	a4,a4,a3
    38b8:	01177e63          	bgeu	a4,a7,38d4 <__udivdi3+0x3bc>
    38bc:	00ee0733          	add	a4,t3,a4
    38c0:	fff58693          	addi	a3,a1,-1
    38c4:	0dc76463          	bltu	a4,t3,398c <__udivdi3+0x474>
    38c8:	0d177263          	bgeu	a4,a7,398c <__udivdi3+0x474>
    38cc:	ffe58593          	addi	a1,a1,-2
    38d0:	01c70733          	add	a4,a4,t3
    38d4:	01079793          	slli	a5,a5,0x10
    38d8:	00010eb7          	lui	t4,0x10
    38dc:	00b7e7b3          	or	a5,a5,a1
    38e0:	fffe8693          	addi	a3,t4,-1 # ffff <__freertos_irq_stack_top+0x873f>
    38e4:	00d7f5b3          	and	a1,a5,a3
    38e8:	0107d313          	srli	t1,a5,0x10
    38ec:	00d676b3          	and	a3,a2,a3
    38f0:	01065613          	srli	a2,a2,0x10
    38f4:	02d58e33          	mul	t3,a1,a3
    38f8:	41170733          	sub	a4,a4,a7
    38fc:	02d306b3          	mul	a3,t1,a3
    3900:	010e5893          	srli	a7,t3,0x10
    3904:	02c585b3          	mul	a1,a1,a2
    3908:	00d585b3          	add	a1,a1,a3
    390c:	00b885b3          	add	a1,a7,a1
    3910:	02c30333          	mul	t1,t1,a2
    3914:	00d5f463          	bgeu	a1,a3,391c <__udivdi3+0x404>
    3918:	01d30333          	add	t1,t1,t4
    391c:	0105d693          	srli	a3,a1,0x10
    3920:	006686b3          	add	a3,a3,t1
    3924:	02d76a63          	bltu	a4,a3,3958 <__udivdi3+0x440>
    3928:	00d70863          	beq	a4,a3,3938 <__udivdi3+0x420>
    392c:	00078513          	mv	a0,a5
    3930:	00000593          	li	a1,0
    3934:	00008067          	ret
    3938:	000106b7          	lui	a3,0x10
    393c:	fff68693          	addi	a3,a3,-1 # ffff <__freertos_irq_stack_top+0x873f>
    3940:	00d5f733          	and	a4,a1,a3
    3944:	01071713          	slli	a4,a4,0x10
    3948:	00de7e33          	and	t3,t3,a3
    394c:	01051533          	sll	a0,a0,a6
    3950:	01c70733          	add	a4,a4,t3
    3954:	fce57ce3          	bgeu	a0,a4,392c <__udivdi3+0x414>
    3958:	fff78513          	addi	a0,a5,-1
    395c:	00000593          	li	a1,0
    3960:	00008067          	ret
    3964:	010007b7          	lui	a5,0x1000
    3968:	04f67a63          	bgeu	a2,a5,39bc <__udivdi3+0x4a4>
    396c:	01065693          	srli	a3,a2,0x10
    3970:	01000713          	li	a4,16
    3974:	d0dff06f          	j	3680 <__udivdi3+0x168>
    3978:	00000593          	li	a1,0
    397c:	00100513          	li	a0,1
    3980:	00008067          	ret
    3984:	00070513          	mv	a0,a4
    3988:	e71ff06f          	j	37f8 <__udivdi3+0x2e0>
    398c:	00068593          	mv	a1,a3
    3990:	f45ff06f          	j	38d4 <__udivdi3+0x3bc>
    3994:	00050e13          	mv	t3,a0
    3998:	e25ff06f          	j	37bc <__udivdi3+0x2a4>
    399c:	00088793          	mv	a5,a7
    39a0:	ef9ff06f          	j	3898 <__udivdi3+0x380>
    39a4:	ffe50513          	addi	a0,a0,-2
    39a8:	010787b3          	add	a5,a5,a6
    39ac:	d39ff06f          	j	36e4 <__udivdi3+0x1cc>
    39b0:	ffe50513          	addi	a0,a0,-2
    39b4:	010787b3          	add	a5,a5,a6
    39b8:	c01ff06f          	j	35b8 <__udivdi3+0xa0>
    39bc:	01865693          	srli	a3,a2,0x18
    39c0:	01800713          	li	a4,24
    39c4:	cbdff06f          	j	3680 <__udivdi3+0x168>

000039c8 <__umoddi3>:
    39c8:	00060813          	mv	a6,a2
    39cc:	00050893          	mv	a7,a0
    39d0:	00058793          	mv	a5,a1
    39d4:	00058713          	mv	a4,a1
    39d8:	0c069863          	bnez	a3,3aa8 <__umoddi3+0xe0>
    39dc:	12c5fa63          	bgeu	a1,a2,3b10 <__umoddi3+0x148>
    39e0:	000107b7          	lui	a5,0x10
    39e4:	1cf66c63          	bltu	a2,a5,3bbc <__umoddi3+0x1f4>
    39e8:	010007b7          	lui	a5,0x1000
    39ec:	01800693          	li	a3,24
    39f0:	00f67463          	bgeu	a2,a5,39f8 <__umoddi3+0x30>
    39f4:	01000693          	li	a3,16
    39f8:	00d65333          	srl	t1,a2,a3
    39fc:	00003797          	auipc	a5,0x3
    3a00:	d1478793          	addi	a5,a5,-748 # 6710 <__clz_tab>
    3a04:	006787b3          	add	a5,a5,t1
    3a08:	0007c783          	lbu	a5,0(a5)
    3a0c:	02000313          	li	t1,32
    3a10:	00d787b3          	add	a5,a5,a3
    3a14:	40f306b3          	sub	a3,t1,a5
    3a18:	00f30c63          	beq	t1,a5,3a30 <__umoddi3+0x68>
    3a1c:	00d59733          	sll	a4,a1,a3
    3a20:	00f557b3          	srl	a5,a0,a5
    3a24:	00d61833          	sll	a6,a2,a3
    3a28:	00e7e733          	or	a4,a5,a4
    3a2c:	00d518b3          	sll	a7,a0,a3
    3a30:	01085593          	srli	a1,a6,0x10
    3a34:	02b75633          	divu	a2,a4,a1
    3a38:	01081313          	slli	t1,a6,0x10
    3a3c:	01035313          	srli	t1,t1,0x10
    3a40:	0108d793          	srli	a5,a7,0x10
    3a44:	02b77733          	remu	a4,a4,a1
    3a48:	02660633          	mul	a2,a2,t1
    3a4c:	01071713          	slli	a4,a4,0x10
    3a50:	00e7e7b3          	or	a5,a5,a4
    3a54:	00c7f863          	bgeu	a5,a2,3a64 <__umoddi3+0x9c>
    3a58:	00f807b3          	add	a5,a6,a5
    3a5c:	0107e463          	bltu	a5,a6,3a64 <__umoddi3+0x9c>
    3a60:	3cc7e263          	bltu	a5,a2,3e24 <__umoddi3+0x45c>
    3a64:	40c787b3          	sub	a5,a5,a2
    3a68:	02b7d733          	divu	a4,a5,a1
    3a6c:	01089513          	slli	a0,a7,0x10
    3a70:	01055513          	srli	a0,a0,0x10
    3a74:	02b7f7b3          	remu	a5,a5,a1
    3a78:	02670733          	mul	a4,a4,t1
    3a7c:	01079793          	slli	a5,a5,0x10
    3a80:	00f56533          	or	a0,a0,a5
    3a84:	00e57a63          	bgeu	a0,a4,3a98 <__umoddi3+0xd0>
    3a88:	00a80533          	add	a0,a6,a0
    3a8c:	01056663          	bltu	a0,a6,3a98 <__umoddi3+0xd0>
    3a90:	00e57463          	bgeu	a0,a4,3a98 <__umoddi3+0xd0>
    3a94:	01050533          	add	a0,a0,a6
    3a98:	40e50533          	sub	a0,a0,a4
    3a9c:	00d55533          	srl	a0,a0,a3
    3aa0:	00000593          	li	a1,0
    3aa4:	00008067          	ret
    3aa8:	00d5f463          	bgeu	a1,a3,3ab0 <__umoddi3+0xe8>
    3aac:	00008067          	ret
    3ab0:	00010737          	lui	a4,0x10
    3ab4:	1ce6e663          	bltu	a3,a4,3c80 <__umoddi3+0x2b8>
    3ab8:	01000737          	lui	a4,0x1000
    3abc:	01800813          	li	a6,24
    3ac0:	00e6f463          	bgeu	a3,a4,3ac8 <__umoddi3+0x100>
    3ac4:	01000813          	li	a6,16
    3ac8:	0106d333          	srl	t1,a3,a6
    3acc:	00003717          	auipc	a4,0x3
    3ad0:	c4470713          	addi	a4,a4,-956 # 6710 <__clz_tab>
    3ad4:	00670733          	add	a4,a4,t1
    3ad8:	00074703          	lbu	a4,0(a4)
    3adc:	02000313          	li	t1,32
    3ae0:	01070733          	add	a4,a4,a6
    3ae4:	40e30833          	sub	a6,t1,a4
    3ae8:	1ce31463          	bne	t1,a4,3cb0 <__umoddi3+0x2e8>
    3aec:	00b6e463          	bltu	a3,a1,3af4 <__umoddi3+0x12c>
    3af0:	00c56a63          	bltu	a0,a2,3b04 <__umoddi3+0x13c>
    3af4:	40c508b3          	sub	a7,a0,a2
    3af8:	40d586b3          	sub	a3,a1,a3
    3afc:	011537b3          	sltu	a5,a0,a7
    3b00:	40f687b3          	sub	a5,a3,a5
    3b04:	00088513          	mv	a0,a7
    3b08:	00078593          	mv	a1,a5
    3b0c:	00008067          	ret
    3b10:	0a060e63          	beqz	a2,3bcc <__umoddi3+0x204>
    3b14:	000107b7          	lui	a5,0x10
    3b18:	2ef67463          	bgeu	a2,a5,3e00 <__umoddi3+0x438>
    3b1c:	10063713          	sltiu	a4,a2,256
    3b20:	00173713          	seqz	a4,a4
    3b24:	00371713          	slli	a4,a4,0x3
    3b28:	00e656b3          	srl	a3,a2,a4
    3b2c:	00003797          	auipc	a5,0x3
    3b30:	be478793          	addi	a5,a5,-1052 # 6710 <__clz_tab>
    3b34:	00d787b3          	add	a5,a5,a3
    3b38:	0007c783          	lbu	a5,0(a5)
    3b3c:	02000313          	li	t1,32
    3b40:	00e787b3          	add	a5,a5,a4
    3b44:	40f306b3          	sub	a3,t1,a5
    3b48:	0af31663          	bne	t1,a5,3bf4 <__umoddi3+0x22c>
    3b4c:	40c58733          	sub	a4,a1,a2
    3b50:	01065313          	srli	t1,a2,0x10
    3b54:	01061613          	slli	a2,a2,0x10
    3b58:	01065613          	srli	a2,a2,0x10
    3b5c:	026755b3          	divu	a1,a4,t1
    3b60:	0108d793          	srli	a5,a7,0x10
    3b64:	02677733          	remu	a4,a4,t1
    3b68:	02c585b3          	mul	a1,a1,a2
    3b6c:	01071713          	slli	a4,a4,0x10
    3b70:	00e7e7b3          	or	a5,a5,a4
    3b74:	00b7fa63          	bgeu	a5,a1,3b88 <__umoddi3+0x1c0>
    3b78:	00f807b3          	add	a5,a6,a5
    3b7c:	0107e663          	bltu	a5,a6,3b88 <__umoddi3+0x1c0>
    3b80:	00b7f463          	bgeu	a5,a1,3b88 <__umoddi3+0x1c0>
    3b84:	010787b3          	add	a5,a5,a6
    3b88:	40b787b3          	sub	a5,a5,a1
    3b8c:	0267d733          	divu	a4,a5,t1
    3b90:	01089893          	slli	a7,a7,0x10
    3b94:	0108d893          	srli	a7,a7,0x10
    3b98:	0267f7b3          	remu	a5,a5,t1
    3b9c:	02c70733          	mul	a4,a4,a2
    3ba0:	01079513          	slli	a0,a5,0x10
    3ba4:	00a8e533          	or	a0,a7,a0
    3ba8:	eee560e3          	bltu	a0,a4,3a88 <__umoddi3+0xc0>
    3bac:	40e50533          	sub	a0,a0,a4
    3bb0:	00d55533          	srl	a0,a0,a3
    3bb4:	00000593          	li	a1,0
    3bb8:	00008067          	ret
    3bbc:	10063693          	sltiu	a3,a2,256
    3bc0:	0016b693          	seqz	a3,a3
    3bc4:	00369693          	slli	a3,a3,0x3
    3bc8:	e31ff06f          	j	39f8 <__umoddi3+0x30>
    3bcc:	00000693          	li	a3,0
    3bd0:	00003797          	auipc	a5,0x3
    3bd4:	b4078793          	addi	a5,a5,-1216 # 6710 <__clz_tab>
    3bd8:	00d787b3          	add	a5,a5,a3
    3bdc:	0007c783          	lbu	a5,0(a5)
    3be0:	00000713          	li	a4,0
    3be4:	02000313          	li	t1,32
    3be8:	00e787b3          	add	a5,a5,a4
    3bec:	40f306b3          	sub	a3,t1,a5
    3bf0:	f4f30ee3          	beq	t1,a5,3b4c <__umoddi3+0x184>
    3bf4:	00d61833          	sll	a6,a2,a3
    3bf8:	00f5de33          	srl	t3,a1,a5
    3bfc:	01085313          	srli	t1,a6,0x10
    3c00:	026e5eb3          	divu	t4,t3,t1
    3c04:	01081613          	slli	a2,a6,0x10
    3c08:	00d595b3          	sll	a1,a1,a3
    3c0c:	00f55733          	srl	a4,a0,a5
    3c10:	01065613          	srli	a2,a2,0x10
    3c14:	00b76733          	or	a4,a4,a1
    3c18:	01075793          	srli	a5,a4,0x10
    3c1c:	00d518b3          	sll	a7,a0,a3
    3c20:	026e7e33          	remu	t3,t3,t1
    3c24:	02ce85b3          	mul	a1,t4,a2
    3c28:	010e1e13          	slli	t3,t3,0x10
    3c2c:	01c7e7b3          	or	a5,a5,t3
    3c30:	00b7fa63          	bgeu	a5,a1,3c44 <__umoddi3+0x27c>
    3c34:	00f807b3          	add	a5,a6,a5
    3c38:	0107e663          	bltu	a5,a6,3c44 <__umoddi3+0x27c>
    3c3c:	00b7f463          	bgeu	a5,a1,3c44 <__umoddi3+0x27c>
    3c40:	010787b3          	add	a5,a5,a6
    3c44:	40b787b3          	sub	a5,a5,a1
    3c48:	0267d5b3          	divu	a1,a5,t1
    3c4c:	01071713          	slli	a4,a4,0x10
    3c50:	01075713          	srli	a4,a4,0x10
    3c54:	0267f7b3          	remu	a5,a5,t1
    3c58:	02c585b3          	mul	a1,a1,a2
    3c5c:	01079793          	slli	a5,a5,0x10
    3c60:	00f76733          	or	a4,a4,a5
    3c64:	00b77a63          	bgeu	a4,a1,3c78 <__umoddi3+0x2b0>
    3c68:	00e80733          	add	a4,a6,a4
    3c6c:	01076663          	bltu	a4,a6,3c78 <__umoddi3+0x2b0>
    3c70:	00b77463          	bgeu	a4,a1,3c78 <__umoddi3+0x2b0>
    3c74:	01070733          	add	a4,a4,a6
    3c78:	40b70733          	sub	a4,a4,a1
    3c7c:	ee1ff06f          	j	3b5c <__umoddi3+0x194>
    3c80:	1006b813          	sltiu	a6,a3,256
    3c84:	00183813          	seqz	a6,a6
    3c88:	00381813          	slli	a6,a6,0x3
    3c8c:	0106d333          	srl	t1,a3,a6
    3c90:	00003717          	auipc	a4,0x3
    3c94:	a8070713          	addi	a4,a4,-1408 # 6710 <__clz_tab>
    3c98:	00670733          	add	a4,a4,t1
    3c9c:	00074703          	lbu	a4,0(a4)
    3ca0:	02000313          	li	t1,32
    3ca4:	01070733          	add	a4,a4,a6
    3ca8:	40e30833          	sub	a6,t1,a4
    3cac:	e4e300e3          	beq	t1,a4,3aec <__umoddi3+0x124>
    3cb0:	010696b3          	sll	a3,a3,a6
    3cb4:	00e658b3          	srl	a7,a2,a4
    3cb8:	00d8e8b3          	or	a7,a7,a3
    3cbc:	00e5de33          	srl	t3,a1,a4
    3cc0:	0108df13          	srli	t5,a7,0x10
    3cc4:	03ee57b3          	divu	a5,t3,t5
    3cc8:	01089e93          	slli	t4,a7,0x10
    3ccc:	010ede93          	srli	t4,t4,0x10
    3cd0:	00e556b3          	srl	a3,a0,a4
    3cd4:	01051333          	sll	t1,a0,a6
    3cd8:	010595b3          	sll	a1,a1,a6
    3cdc:	00b6e5b3          	or	a1,a3,a1
    3ce0:	0105d693          	srli	a3,a1,0x10
    3ce4:	01061633          	sll	a2,a2,a6
    3ce8:	03ee7e33          	remu	t3,t3,t5
    3cec:	02fe8533          	mul	a0,t4,a5
    3cf0:	010e1e13          	slli	t3,t3,0x10
    3cf4:	01c6e6b3          	or	a3,a3,t3
    3cf8:	00a6fe63          	bgeu	a3,a0,3d14 <__umoddi3+0x34c>
    3cfc:	00d886b3          	add	a3,a7,a3
    3d00:	fff78e13          	addi	t3,a5,-1
    3d04:	1116ec63          	bltu	a3,a7,3e1c <__umoddi3+0x454>
    3d08:	10a6fa63          	bgeu	a3,a0,3e1c <__umoddi3+0x454>
    3d0c:	ffe78793          	addi	a5,a5,-2
    3d10:	011686b3          	add	a3,a3,a7
    3d14:	40a686b3          	sub	a3,a3,a0
    3d18:	03e6d533          	divu	a0,a3,t5
    3d1c:	01059593          	slli	a1,a1,0x10
    3d20:	0105d593          	srli	a1,a1,0x10
    3d24:	03e6f6b3          	remu	a3,a3,t5
    3d28:	02ae8eb3          	mul	t4,t4,a0
    3d2c:	01069693          	slli	a3,a3,0x10
    3d30:	00d5e5b3          	or	a1,a1,a3
    3d34:	01d5fe63          	bgeu	a1,t4,3d50 <__umoddi3+0x388>
    3d38:	00b885b3          	add	a1,a7,a1
    3d3c:	fff50693          	addi	a3,a0,-1
    3d40:	0d15ea63          	bltu	a1,a7,3e14 <__umoddi3+0x44c>
    3d44:	0dd5f863          	bgeu	a1,t4,3e14 <__umoddi3+0x44c>
    3d48:	ffe50513          	addi	a0,a0,-2
    3d4c:	011585b3          	add	a1,a1,a7
    3d50:	01079693          	slli	a3,a5,0x10
    3d54:	000102b7          	lui	t0,0x10
    3d58:	00a6e6b3          	or	a3,a3,a0
    3d5c:	fff28513          	addi	a0,t0,-1 # ffff <__freertos_irq_stack_top+0x873f>
    3d60:	00a6fe33          	and	t3,a3,a0
    3d64:	01065f93          	srli	t6,a2,0x10
    3d68:	0106d693          	srli	a3,a3,0x10
    3d6c:	00a67533          	and	a0,a2,a0
    3d70:	02ae0f33          	mul	t5,t3,a0
    3d74:	41d585b3          	sub	a1,a1,t4
    3d78:	02a68533          	mul	a0,a3,a0
    3d7c:	010f5793          	srli	a5,t5,0x10
    3d80:	03fe0e33          	mul	t3,t3,t6
    3d84:	00ae0e33          	add	t3,t3,a0
    3d88:	01c787b3          	add	a5,a5,t3
    3d8c:	03f686b3          	mul	a3,a3,t6
    3d90:	00a7f463          	bgeu	a5,a0,3d98 <__umoddi3+0x3d0>
    3d94:	005686b3          	add	a3,a3,t0
    3d98:	00010eb7          	lui	t4,0x10
    3d9c:	fffe8e93          	addi	t4,t4,-1 # ffff <__freertos_irq_stack_top+0x873f>
    3da0:	01d7f533          	and	a0,a5,t4
    3da4:	0107de13          	srli	t3,a5,0x10
    3da8:	01051513          	slli	a0,a0,0x10
    3dac:	01df7f33          	and	t5,t5,t4
    3db0:	00de07b3          	add	a5,t3,a3
    3db4:	01e50533          	add	a0,a0,t5
    3db8:	02f5e863          	bltu	a1,a5,3de8 <__umoddi3+0x420>
    3dbc:	02f58463          	beq	a1,a5,3de4 <__umoddi3+0x41c>
    3dc0:	40a30533          	sub	a0,t1,a0
    3dc4:	00a33333          	sltu	t1,t1,a0
    3dc8:	40f585b3          	sub	a1,a1,a5
    3dcc:	406585b3          	sub	a1,a1,t1
    3dd0:	00e59733          	sll	a4,a1,a4
    3dd4:	01055533          	srl	a0,a0,a6
    3dd8:	00a76533          	or	a0,a4,a0
    3ddc:	0105d5b3          	srl	a1,a1,a6
    3de0:	00008067          	ret
    3de4:	fca37ee3          	bgeu	t1,a0,3dc0 <__umoddi3+0x3f8>
    3de8:	40c50633          	sub	a2,a0,a2
    3dec:	00c53533          	sltu	a0,a0,a2
    3df0:	011508b3          	add	a7,a0,a7
    3df4:	411787b3          	sub	a5,a5,a7
    3df8:	00060513          	mv	a0,a2
    3dfc:	fc5ff06f          	j	3dc0 <__umoddi3+0x3f8>
    3e00:	010007b7          	lui	a5,0x1000
    3e04:	02f67463          	bgeu	a2,a5,3e2c <__umoddi3+0x464>
    3e08:	01065693          	srli	a3,a2,0x10
    3e0c:	01000713          	li	a4,16
    3e10:	d1dff06f          	j	3b2c <__umoddi3+0x164>
    3e14:	00068513          	mv	a0,a3
    3e18:	f39ff06f          	j	3d50 <__umoddi3+0x388>
    3e1c:	000e0793          	mv	a5,t3
    3e20:	ef5ff06f          	j	3d14 <__umoddi3+0x34c>
    3e24:	010787b3          	add	a5,a5,a6
    3e28:	c3dff06f          	j	3a64 <__umoddi3+0x9c>
    3e2c:	01865693          	srli	a3,a2,0x18
    3e30:	01800713          	li	a4,24
    3e34:	cf9ff06f          	j	3b2c <__umoddi3+0x164>

00003e38 <__adddf3>:
    3e38:	001007b7          	lui	a5,0x100
    3e3c:	fe010113          	addi	sp,sp,-32
    3e40:	fff78e93          	addi	t4,a5,-1 # fffff <__freertos_irq_stack_top+0xf873f>
    3e44:	00bef833          	and	a6,t4,a1
    3e48:	00def7b3          	and	a5,t4,a3
    3e4c:	0146d313          	srli	t1,a3,0x14
    3e50:	01212823          	sw	s2,16(sp)
    3e54:	0145d913          	srli	s2,a1,0x14
    3e58:	00379793          	slli	a5,a5,0x3
    3e5c:	00812c23          	sw	s0,24(sp)
    3e60:	00381813          	slli	a6,a6,0x3
    3e64:	01f5d413          	srli	s0,a1,0x1f
    3e68:	01d55713          	srli	a4,a0,0x1d
    3e6c:	01d65893          	srli	a7,a2,0x1d
    3e70:	7ff97913          	andi	s2,s2,2047
    3e74:	7ff37313          	andi	t1,t1,2047
    3e78:	00112e23          	sw	ra,28(sp)
    3e7c:	00912a23          	sw	s1,20(sp)
    3e80:	01312623          	sw	s3,12(sp)
    3e84:	01f6d693          	srli	a3,a3,0x1f
    3e88:	00f8e8b3          	or	a7,a7,a5
    3e8c:	01076733          	or	a4,a4,a6
    3e90:	00351593          	slli	a1,a0,0x3
    3e94:	00361f13          	slli	t5,a2,0x3
    3e98:	406907b3          	sub	a5,s2,t1
    3e9c:	1ed40463          	beq	s0,a3,4084 <__adddf3+0x24c>
    3ea0:	16f05263          	blez	a5,4004 <__adddf3+0x1cc>
    3ea4:	28030663          	beqz	t1,4130 <__adddf3+0x2f8>
    3ea8:	7ff00693          	li	a3,2047
    3eac:	42d90663          	beq	s2,a3,42d8 <__adddf3+0x4a0>
    3eb0:	03800693          	li	a3,56
    3eb4:	00100613          	li	a2,1
    3eb8:	02f6ce63          	blt	a3,a5,3ef4 <__adddf3+0xbc>
    3ebc:	008006b7          	lui	a3,0x800
    3ec0:	00d8e8b3          	or	a7,a7,a3
    3ec4:	01f00693          	li	a3,31
    3ec8:	52f6ce63          	blt	a3,a5,4404 <__adddf3+0x5cc>
    3ecc:	02000693          	li	a3,32
    3ed0:	40f686b3          	sub	a3,a3,a5
    3ed4:	00d89633          	sll	a2,a7,a3
    3ed8:	00ff5533          	srl	a0,t5,a5
    3edc:	00df16b3          	sll	a3,t5,a3
    3ee0:	00a66633          	or	a2,a2,a0
    3ee4:	00d036b3          	snez	a3,a3
    3ee8:	00f8d8b3          	srl	a7,a7,a5
    3eec:	00d66633          	or	a2,a2,a3
    3ef0:	41170733          	sub	a4,a4,a7
    3ef4:	40c58633          	sub	a2,a1,a2
    3ef8:	00c5b5b3          	sltu	a1,a1,a2
    3efc:	00060493          	mv	s1,a2
    3f00:	40b709b3          	sub	s3,a4,a1
    3f04:	00899793          	slli	a5,s3,0x8
    3f08:	3207da63          	bgez	a5,423c <__adddf3+0x404>
    3f0c:	008007b7          	lui	a5,0x800
    3f10:	fff78793          	addi	a5,a5,-1 # 7fffff <__freertos_irq_stack_top+0x7f873f>
    3f14:	00f9f9b3          	and	s3,s3,a5
    3f18:	2c098863          	beqz	s3,41e8 <__adddf3+0x3b0>
    3f1c:	00098513          	mv	a0,s3
    3f20:	458020ef          	jal	6378 <__clzsi2>
    3f24:	ff850793          	addi	a5,a0,-8
    3f28:	02000693          	li	a3,32
    3f2c:	40f68733          	sub	a4,a3,a5
    3f30:	00e4d733          	srl	a4,s1,a4
    3f34:	00f999b3          	sll	s3,s3,a5
    3f38:	01376733          	or	a4,a4,s3
    3f3c:	00f494b3          	sll	s1,s1,a5
    3f40:	4b27c863          	blt	a5,s2,43f0 <__adddf3+0x5b8>
    3f44:	412787b3          	sub	a5,a5,s2
    3f48:	00178793          	addi	a5,a5,1
    3f4c:	40f686b3          	sub	a3,a3,a5
    3f50:	00d49633          	sll	a2,s1,a3
    3f54:	00f4d9b3          	srl	s3,s1,a5
    3f58:	00c03633          	snez	a2,a2
    3f5c:	01366633          	or	a2,a2,s3
    3f60:	00d716b3          	sll	a3,a4,a3
    3f64:	00c6e4b3          	or	s1,a3,a2
    3f68:	00f759b3          	srl	s3,a4,a5
    3f6c:	00000913          	li	s2,0
    3f70:	0074f793          	andi	a5,s1,7
    3f74:	02078063          	beqz	a5,3f94 <__adddf3+0x15c>
    3f78:	00f4f793          	andi	a5,s1,15
    3f7c:	00400713          	li	a4,4
    3f80:	00e78a63          	beq	a5,a4,3f94 <__adddf3+0x15c>
    3f84:	00448793          	addi	a5,s1,4
    3f88:	0097b633          	sltu	a2,a5,s1
    3f8c:	00c989b3          	add	s3,s3,a2
    3f90:	00078493          	mv	s1,a5
    3f94:	00899793          	slli	a5,s3,0x8
    3f98:	6e07da63          	bgez	a5,468c <__adddf3+0x854>
    3f9c:	00190793          	addi	a5,s2,1
    3fa0:	7ff00713          	li	a4,2047
    3fa4:	00040e13          	mv	t3,s0
    3fa8:	2ae78663          	beq	a5,a4,4254 <__adddf3+0x41c>
    3fac:	ff800737          	lui	a4,0xff800
    3fb0:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f873f>
    3fb4:	00e9f733          	and	a4,s3,a4
    3fb8:	7ff7f793          	andi	a5,a5,2047
    3fbc:	01d71813          	slli	a6,a4,0x1d
    3fc0:	0034d613          	srli	a2,s1,0x3
    3fc4:	00971713          	slli	a4,a4,0x9
    3fc8:	00c86833          	or	a6,a6,a2
    3fcc:	00c75713          	srli	a4,a4,0xc
    3fd0:	01c12083          	lw	ra,28(sp)
    3fd4:	01812403          	lw	s0,24(sp)
    3fd8:	01479793          	slli	a5,a5,0x14
    3fdc:	00e7e7b3          	or	a5,a5,a4
    3fe0:	01fe1713          	slli	a4,t3,0x1f
    3fe4:	00e7e7b3          	or	a5,a5,a4
    3fe8:	01412483          	lw	s1,20(sp)
    3fec:	01012903          	lw	s2,16(sp)
    3ff0:	00c12983          	lw	s3,12(sp)
    3ff4:	00080513          	mv	a0,a6
    3ff8:	00078593          	mv	a1,a5
    3ffc:	02010113          	addi	sp,sp,32
    4000:	00008067          	ret
    4004:	14078c63          	beqz	a5,415c <__adddf3+0x324>
    4008:	412307b3          	sub	a5,t1,s2
    400c:	3c091263          	bnez	s2,43d0 <__adddf3+0x598>
    4010:	00b76533          	or	a0,a4,a1
    4014:	4c050463          	beqz	a0,44dc <__adddf3+0x6a4>
    4018:	fff78513          	addi	a0,a5,-1
    401c:	60050263          	beqz	a0,4620 <__adddf3+0x7e8>
    4020:	7ff00813          	li	a6,2047
    4024:	57078663          	beq	a5,a6,4590 <__adddf3+0x758>
    4028:	03800793          	li	a5,56
    402c:	00100613          	li	a2,1
    4030:	02a7cc63          	blt	a5,a0,4068 <__adddf3+0x230>
    4034:	00050793          	mv	a5,a0
    4038:	01f00613          	li	a2,31
    403c:	56f64c63          	blt	a2,a5,45b4 <__adddf3+0x77c>
    4040:	02000513          	li	a0,32
    4044:	40f50533          	sub	a0,a0,a5
    4048:	00a71633          	sll	a2,a4,a0
    404c:	00f5d833          	srl	a6,a1,a5
    4050:	00a59533          	sll	a0,a1,a0
    4054:	01066633          	or	a2,a2,a6
    4058:	00a03533          	snez	a0,a0
    405c:	00f75733          	srl	a4,a4,a5
    4060:	00a66633          	or	a2,a2,a0
    4064:	40e888b3          	sub	a7,a7,a4
    4068:	40cf0633          	sub	a2,t5,a2
    406c:	00cf3733          	sltu	a4,t5,a2
    4070:	00060493          	mv	s1,a2
    4074:	40e889b3          	sub	s3,a7,a4
    4078:	00030913          	mv	s2,t1
    407c:	00068413          	mv	s0,a3
    4080:	e85ff06f          	j	3f04 <__adddf3+0xcc>
    4084:	1ef05063          	blez	a5,4264 <__adddf3+0x42c>
    4088:	14031063          	bnez	t1,41c8 <__adddf3+0x390>
    408c:	01e8e6b3          	or	a3,a7,t5
    4090:	26068c63          	beqz	a3,4308 <__adddf3+0x4d0>
    4094:	fff78693          	addi	a3,a5,-1
    4098:	48068063          	beqz	a3,4518 <__adddf3+0x6e0>
    409c:	7ff00613          	li	a2,2047
    40a0:	22c78c63          	beq	a5,a2,42d8 <__adddf3+0x4a0>
    40a4:	03800793          	li	a5,56
    40a8:	00100993          	li	s3,1
    40ac:	02d7cc63          	blt	a5,a3,40e4 <__adddf3+0x2ac>
    40b0:	00068793          	mv	a5,a3
    40b4:	01f00693          	li	a3,31
    40b8:	4af6c063          	blt	a3,a5,4558 <__adddf3+0x720>
    40bc:	02000693          	li	a3,32
    40c0:	40f686b3          	sub	a3,a3,a5
    40c4:	00d899b3          	sll	s3,a7,a3
    40c8:	00ff5633          	srl	a2,t5,a5
    40cc:	00df16b3          	sll	a3,t5,a3
    40d0:	00c9e9b3          	or	s3,s3,a2
    40d4:	00d036b3          	snez	a3,a3
    40d8:	00f8d8b3          	srl	a7,a7,a5
    40dc:	00d9e9b3          	or	s3,s3,a3
    40e0:	01170733          	add	a4,a4,a7
    40e4:	00b985b3          	add	a1,s3,a1
    40e8:	0135b9b3          	sltu	s3,a1,s3
    40ec:	00058493          	mv	s1,a1
    40f0:	00e989b3          	add	s3,s3,a4
    40f4:	00899793          	slli	a5,s3,0x8
    40f8:	1407d263          	bgez	a5,423c <__adddf3+0x404>
    40fc:	00190913          	addi	s2,s2,1
    4100:	7ff00793          	li	a5,2047
    4104:	36f90c63          	beq	s2,a5,447c <__adddf3+0x644>
    4108:	ff8007b7          	lui	a5,0xff800
    410c:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f873f>
    4110:	0014f613          	andi	a2,s1,1
    4114:	00f9f7b3          	and	a5,s3,a5
    4118:	0014d713          	srli	a4,s1,0x1
    411c:	00c76733          	or	a4,a4,a2
    4120:	01f79613          	slli	a2,a5,0x1f
    4124:	00e664b3          	or	s1,a2,a4
    4128:	0017d993          	srli	s3,a5,0x1
    412c:	e45ff06f          	j	3f70 <__adddf3+0x138>
    4130:	01e8e6b3          	or	a3,a7,t5
    4134:	1c068a63          	beqz	a3,4308 <__adddf3+0x4d0>
    4138:	fff78693          	addi	a3,a5,-1
    413c:	40068063          	beqz	a3,453c <__adddf3+0x704>
    4140:	7ff00613          	li	a2,2047
    4144:	18c78a63          	beq	a5,a2,42d8 <__adddf3+0x4a0>
    4148:	03800793          	li	a5,56
    414c:	00100613          	li	a2,1
    4150:	dad7c2e3          	blt	a5,a3,3ef4 <__adddf3+0xbc>
    4154:	00068793          	mv	a5,a3
    4158:	d6dff06f          	j	3ec4 <__adddf3+0x8c>
    415c:	00190813          	addi	a6,s2,1
    4160:	7fe87813          	andi	a6,a6,2046
    4164:	22081c63          	bnez	a6,439c <__adddf3+0x564>
    4168:	00b76333          	or	t1,a4,a1
    416c:	01e8e833          	or	a6,a7,t5
    4170:	38091063          	bnez	s2,44f0 <__adddf3+0x6b8>
    4174:	46030e63          	beqz	t1,45f0 <__adddf3+0x7b8>
    4178:	40080663          	beqz	a6,4584 <__adddf3+0x74c>
    417c:	41e589b3          	sub	s3,a1,t5
    4180:	0135b533          	sltu	a0,a1,s3
    4184:	41170633          	sub	a2,a4,a7
    4188:	40a60633          	sub	a2,a2,a0
    418c:	00861513          	slli	a0,a2,0x8
    4190:	50055e63          	bgez	a0,46ac <__adddf3+0x874>
    4194:	40bf05b3          	sub	a1,t5,a1
    4198:	40e88733          	sub	a4,a7,a4
    419c:	00bf3f33          	sltu	t5,t5,a1
    41a0:	41e70733          	sub	a4,a4,t5
    41a4:	00871613          	slli	a2,a4,0x8
    41a8:	00058493          	mv	s1,a1
    41ac:	52065e63          	bgez	a2,46e8 <__adddf3+0x8b0>
    41b0:	ff8007b7          	lui	a5,0xff800
    41b4:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f873f>
    41b8:	00f77733          	and	a4,a4,a5
    41bc:	00068e13          	mv	t3,a3
    41c0:	00100793          	li	a5,1
    41c4:	df9ff06f          	j	3fbc <__adddf3+0x184>
    41c8:	7ff00693          	li	a3,2047
    41cc:	10d90663          	beq	s2,a3,42d8 <__adddf3+0x4a0>
    41d0:	03800693          	li	a3,56
    41d4:	00100993          	li	s3,1
    41d8:	f0f6c6e3          	blt	a3,a5,40e4 <__adddf3+0x2ac>
    41dc:	008006b7          	lui	a3,0x800
    41e0:	00d8e8b3          	or	a7,a7,a3
    41e4:	ed1ff06f          	j	40b4 <__adddf3+0x27c>
    41e8:	00048513          	mv	a0,s1
    41ec:	18c020ef          	jal	6378 <__clzsi2>
    41f0:	01850793          	addi	a5,a0,24
    41f4:	01f00693          	li	a3,31
    41f8:	d2f6d8e3          	bge	a3,a5,3f28 <__adddf3+0xf0>
    41fc:	ff850713          	addi	a4,a0,-8
    4200:	00e49733          	sll	a4,s1,a4
    4204:	2327c663          	blt	a5,s2,4430 <__adddf3+0x5f8>
    4208:	41278933          	sub	s2,a5,s2
    420c:	00190793          	addi	a5,s2,1
    4210:	48f6d663          	bge	a3,a5,469c <__adddf3+0x864>
    4214:	fe190913          	addi	s2,s2,-31
    4218:	02000693          	li	a3,32
    421c:	012754b3          	srl	s1,a4,s2
    4220:	00d78c63          	beq	a5,a3,4238 <__adddf3+0x400>
    4224:	04000693          	li	a3,64
    4228:	40f687b3          	sub	a5,a3,a5
    422c:	00f71733          	sll	a4,a4,a5
    4230:	00e03733          	snez	a4,a4
    4234:	00e4e4b3          	or	s1,s1,a4
    4238:	00000913          	li	s2,0
    423c:	0074f793          	andi	a5,s1,7
    4240:	d2079ce3          	bnez	a5,3f78 <__adddf3+0x140>
    4244:	00090793          	mv	a5,s2
    4248:	0034d613          	srli	a2,s1,0x3
    424c:	00098713          	mv	a4,s3
    4250:	0c00006f          	j	4310 <__adddf3+0x4d8>
    4254:	7ff00793          	li	a5,2047
    4258:	00000713          	li	a4,0
    425c:	00000813          	li	a6,0
    4260:	d71ff06f          	j	3fd0 <__adddf3+0x198>
    4264:	0c078a63          	beqz	a5,4338 <__adddf3+0x500>
    4268:	412307b3          	sub	a5,t1,s2
    426c:	1e090263          	beqz	s2,4450 <__adddf3+0x618>
    4270:	7ff00693          	li	a3,2047
    4274:	32d30863          	beq	t1,a3,45a4 <__adddf3+0x76c>
    4278:	03800693          	li	a3,56
    427c:	00100993          	li	s3,1
    4280:	02f6ce63          	blt	a3,a5,42bc <__adddf3+0x484>
    4284:	008006b7          	lui	a3,0x800
    4288:	00d76733          	or	a4,a4,a3
    428c:	01f00693          	li	a3,31
    4290:	3cf6c863          	blt	a3,a5,4660 <__adddf3+0x828>
    4294:	02000693          	li	a3,32
    4298:	40f686b3          	sub	a3,a3,a5
    429c:	00d719b3          	sll	s3,a4,a3
    42a0:	00f5d633          	srl	a2,a1,a5
    42a4:	00d596b3          	sll	a3,a1,a3
    42a8:	00c9e9b3          	or	s3,s3,a2
    42ac:	00d036b3          	snez	a3,a3
    42b0:	00f75733          	srl	a4,a4,a5
    42b4:	00d9e9b3          	or	s3,s3,a3
    42b8:	00e888b3          	add	a7,a7,a4
    42bc:	01e98733          	add	a4,s3,t5
    42c0:	013739b3          	sltu	s3,a4,s3
    42c4:	00070493          	mv	s1,a4
    42c8:	011989b3          	add	s3,s3,a7
    42cc:	00030913          	mv	s2,t1
    42d0:	e25ff06f          	j	40f4 <__adddf3+0x2bc>
    42d4:	02081063          	bnez	a6,42f4 <__adddf3+0x4bc>
    42d8:	00351613          	slli	a2,a0,0x3
    42dc:	00365613          	srli	a2,a2,0x3
    42e0:	01d71813          	slli	a6,a4,0x1d
    42e4:	00c86833          	or	a6,a6,a2
    42e8:	00375713          	srli	a4,a4,0x3
    42ec:	01076733          	or	a4,a4,a6
    42f0:	18070663          	beqz	a4,447c <__adddf3+0x644>
    42f4:	00000e13          	li	t3,0
    42f8:	7ff00793          	li	a5,2047
    42fc:	00080737          	lui	a4,0x80
    4300:	00000813          	li	a6,0
    4304:	ccdff06f          	j	3fd0 <__adddf3+0x198>
    4308:	00351613          	slli	a2,a0,0x3
    430c:	00365613          	srli	a2,a2,0x3
    4310:	01d71813          	slli	a6,a4,0x1d
    4314:	7ff00693          	li	a3,2047
    4318:	00c86833          	or	a6,a6,a2
    431c:	00375713          	srli	a4,a4,0x3
    4320:	fcd786e3          	beq	a5,a3,42ec <__adddf3+0x4b4>
    4324:	00c71713          	slli	a4,a4,0xc
    4328:	00c75713          	srli	a4,a4,0xc
    432c:	7ff7f793          	andi	a5,a5,2047
    4330:	00040e13          	mv	t3,s0
    4334:	c9dff06f          	j	3fd0 <__adddf3+0x198>
    4338:	00190693          	addi	a3,s2,1
    433c:	7fe6f813          	andi	a6,a3,2046
    4340:	14081863          	bnez	a6,4490 <__adddf3+0x658>
    4344:	00b766b3          	or	a3,a4,a1
    4348:	28091c63          	bnez	s2,45e0 <__adddf3+0x7a8>
    434c:	30068263          	beqz	a3,4650 <__adddf3+0x818>
    4350:	01e8e6b3          	or	a3,a7,t5
    4354:	22068863          	beqz	a3,4584 <__adddf3+0x74c>
    4358:	01e587b3          	add	a5,a1,t5
    435c:	00b7b5b3          	sltu	a1,a5,a1
    4360:	01170733          	add	a4,a4,a7
    4364:	00b70733          	add	a4,a4,a1
    4368:	0037d813          	srli	a6,a5,0x3
    436c:	00871793          	slli	a5,a4,0x8
    4370:	00040e13          	mv	t3,s0
    4374:	3407de63          	bgez	a5,46d0 <__adddf3+0x898>
    4378:	ff8007b7          	lui	a5,0xff800
    437c:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f873f>
    4380:	00f77733          	and	a4,a4,a5
    4384:	01d71793          	slli	a5,a4,0x1d
    4388:	00375713          	srli	a4,a4,0x3
    438c:	0107e833          	or	a6,a5,a6
    4390:	01d77733          	and	a4,a4,t4
    4394:	00100793          	li	a5,1
    4398:	c39ff06f          	j	3fd0 <__adddf3+0x198>
    439c:	41e58833          	sub	a6,a1,t5
    43a0:	0105b7b3          	sltu	a5,a1,a6
    43a4:	411709b3          	sub	s3,a4,a7
    43a8:	40f989b3          	sub	s3,s3,a5
    43ac:	00899793          	slli	a5,s3,0x8
    43b0:	00080493          	mv	s1,a6
    43b4:	1007c663          	bltz	a5,44c0 <__adddf3+0x688>
    43b8:	01386833          	or	a6,a6,s3
    43bc:	b4081ee3          	bnez	a6,3f18 <__adddf3+0xe0>
    43c0:	00000e13          	li	t3,0
    43c4:	00000793          	li	a5,0
    43c8:	00000713          	li	a4,0
    43cc:	c05ff06f          	j	3fd0 <__adddf3+0x198>
    43d0:	7ff00513          	li	a0,2047
    43d4:	1aa30e63          	beq	t1,a0,4590 <__adddf3+0x758>
    43d8:	03800513          	li	a0,56
    43dc:	00100613          	li	a2,1
    43e0:	c8f544e3          	blt	a0,a5,4068 <__adddf3+0x230>
    43e4:	00800637          	lui	a2,0x800
    43e8:	00c76733          	or	a4,a4,a2
    43ec:	c4dff06f          	j	4038 <__adddf3+0x200>
    43f0:	ff8009b7          	lui	s3,0xff800
    43f4:	fff98993          	addi	s3,s3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f873f>
    43f8:	40f90933          	sub	s2,s2,a5
    43fc:	013779b3          	and	s3,a4,s3
    4400:	b71ff06f          	j	3f70 <__adddf3+0x138>
    4404:	fe078693          	addi	a3,a5,-32
    4408:	02000613          	li	a2,32
    440c:	00d8d6b3          	srl	a3,a7,a3
    4410:	00c78a63          	beq	a5,a2,4424 <__adddf3+0x5ec>
    4414:	04000613          	li	a2,64
    4418:	40f607b3          	sub	a5,a2,a5
    441c:	00f897b3          	sll	a5,a7,a5
    4420:	00ff6f33          	or	t5,t5,a5
    4424:	01e03633          	snez	a2,t5
    4428:	00d66633          	or	a2,a2,a3
    442c:	ac9ff06f          	j	3ef4 <__adddf3+0xbc>
    4430:	ff8006b7          	lui	a3,0xff800
    4434:	fff68693          	addi	a3,a3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f873f>
    4438:	40f907b3          	sub	a5,s2,a5
    443c:	00d77733          	and	a4,a4,a3
    4440:	01d71813          	slli	a6,a4,0x1d
    4444:	01386833          	or	a6,a6,s3
    4448:	00375713          	srli	a4,a4,0x3
    444c:	ed9ff06f          	j	4324 <__adddf3+0x4ec>
    4450:	00b766b3          	or	a3,a4,a1
    4454:	1e068663          	beqz	a3,4640 <__adddf3+0x808>
    4458:	fff78693          	addi	a3,a5,-1
    445c:	0a068e63          	beqz	a3,4518 <__adddf3+0x6e0>
    4460:	7ff00513          	li	a0,2047
    4464:	14a78063          	beq	a5,a0,45a4 <__adddf3+0x76c>
    4468:	03800793          	li	a5,56
    446c:	00100993          	li	s3,1
    4470:	e4d7c6e3          	blt	a5,a3,42bc <__adddf3+0x484>
    4474:	00068793          	mv	a5,a3
    4478:	e15ff06f          	j	428c <__adddf3+0x454>
    447c:	00040e13          	mv	t3,s0
    4480:	7ff00793          	li	a5,2047
    4484:	00000713          	li	a4,0
    4488:	00000813          	li	a6,0
    448c:	b45ff06f          	j	3fd0 <__adddf3+0x198>
    4490:	7ff00793          	li	a5,2047
    4494:	fef684e3          	beq	a3,a5,447c <__adddf3+0x644>
    4498:	01e58f33          	add	t5,a1,t5
    449c:	00bf35b3          	sltu	a1,t5,a1
    44a0:	011707b3          	add	a5,a4,a7
    44a4:	00b787b3          	add	a5,a5,a1
    44a8:	01f79613          	slli	a2,a5,0x1f
    44ac:	001f5f13          	srli	t5,t5,0x1
    44b0:	01e664b3          	or	s1,a2,t5
    44b4:	0017d993          	srli	s3,a5,0x1
    44b8:	00068913          	mv	s2,a3
    44bc:	ab5ff06f          	j	3f70 <__adddf3+0x138>
    44c0:	40bf0633          	sub	a2,t5,a1
    44c4:	40e887b3          	sub	a5,a7,a4
    44c8:	00cf3733          	sltu	a4,t5,a2
    44cc:	00060493          	mv	s1,a2
    44d0:	40e789b3          	sub	s3,a5,a4
    44d4:	00068413          	mv	s0,a3
    44d8:	a41ff06f          	j	3f18 <__adddf3+0xe0>
    44dc:	00361613          	slli	a2,a2,0x3
    44e0:	00365613          	srli	a2,a2,0x3
    44e4:	00068413          	mv	s0,a3
    44e8:	00088713          	mv	a4,a7
    44ec:	e25ff06f          	j	4310 <__adddf3+0x4d8>
    44f0:	de0312e3          	bnez	t1,42d4 <__adddf3+0x49c>
    44f4:	1c080663          	beqz	a6,46c0 <__adddf3+0x888>
    44f8:	0038d713          	srli	a4,a7,0x3
    44fc:	00361613          	slli	a2,a2,0x3
    4500:	01d89893          	slli	a7,a7,0x1d
    4504:	01176733          	or	a4,a4,a7
    4508:	00365613          	srli	a2,a2,0x3
    450c:	00c76733          	or	a4,a4,a2
    4510:	00068413          	mv	s0,a3
    4514:	dddff06f          	j	42f0 <__adddf3+0x4b8>
    4518:	01e58f33          	add	t5,a1,t5
    451c:	011708b3          	add	a7,a4,a7
    4520:	00bf35b3          	sltu	a1,t5,a1
    4524:	00b889b3          	add	s3,a7,a1
    4528:	00899793          	slli	a5,s3,0x8
    452c:	000f0493          	mv	s1,t5
    4530:	0e07d463          	bgez	a5,4618 <__adddf3+0x7e0>
    4534:	00200913          	li	s2,2
    4538:	bd1ff06f          	j	4108 <__adddf3+0x2d0>
    453c:	41e58f33          	sub	t5,a1,t5
    4540:	411708b3          	sub	a7,a4,a7
    4544:	01e5b5b3          	sltu	a1,a1,t5
    4548:	000f0493          	mv	s1,t5
    454c:	40b889b3          	sub	s3,a7,a1
    4550:	00100913          	li	s2,1
    4554:	9b1ff06f          	j	3f04 <__adddf3+0xcc>
    4558:	fe078693          	addi	a3,a5,-32
    455c:	02000613          	li	a2,32
    4560:	00d8d6b3          	srl	a3,a7,a3
    4564:	00c78a63          	beq	a5,a2,4578 <__adddf3+0x740>
    4568:	04000613          	li	a2,64
    456c:	40f607b3          	sub	a5,a2,a5
    4570:	00f897b3          	sll	a5,a7,a5
    4574:	00ff6f33          	or	t5,t5,a5
    4578:	01e039b3          	snez	s3,t5
    457c:	00d9e9b3          	or	s3,s3,a3
    4580:	b65ff06f          	j	40e4 <__adddf3+0x2ac>
    4584:	00351613          	slli	a2,a0,0x3
    4588:	00365993          	srli	s3,a2,0x3
    458c:	eb5ff06f          	j	4440 <__adddf3+0x608>
    4590:	00361613          	slli	a2,a2,0x3
    4594:	00365613          	srli	a2,a2,0x3
    4598:	00068413          	mv	s0,a3
    459c:	00088713          	mv	a4,a7
    45a0:	d41ff06f          	j	42e0 <__adddf3+0x4a8>
    45a4:	00361613          	slli	a2,a2,0x3
    45a8:	00365613          	srli	a2,a2,0x3
    45ac:	00088713          	mv	a4,a7
    45b0:	d31ff06f          	j	42e0 <__adddf3+0x4a8>
    45b4:	fe078513          	addi	a0,a5,-32
    45b8:	02000613          	li	a2,32
    45bc:	00a75533          	srl	a0,a4,a0
    45c0:	00c78a63          	beq	a5,a2,45d4 <__adddf3+0x79c>
    45c4:	04000613          	li	a2,64
    45c8:	40f607b3          	sub	a5,a2,a5
    45cc:	00f717b3          	sll	a5,a4,a5
    45d0:	00f5e5b3          	or	a1,a1,a5
    45d4:	00b03633          	snez	a2,a1
    45d8:	00a66633          	or	a2,a2,a0
    45dc:	a8dff06f          	j	4068 <__adddf3+0x230>
    45e0:	fc0682e3          	beqz	a3,45a4 <__adddf3+0x76c>
    45e4:	01e8ef33          	or	t5,a7,t5
    45e8:	d00f16e3          	bnez	t5,42f4 <__adddf3+0x4bc>
    45ec:	cedff06f          	j	42d8 <__adddf3+0x4a0>
    45f0:	dc0808e3          	beqz	a6,43c0 <__adddf3+0x588>
    45f4:	00361813          	slli	a6,a2,0x3
    45f8:	01d89793          	slli	a5,a7,0x1d
    45fc:	00385813          	srli	a6,a6,0x3
    4600:	0038d713          	srli	a4,a7,0x3
    4604:	00f86833          	or	a6,a6,a5
    4608:	01d77733          	and	a4,a4,t4
    460c:	00068e13          	mv	t3,a3
    4610:	00000793          	li	a5,0
    4614:	9bdff06f          	j	3fd0 <__adddf3+0x198>
    4618:	00100793          	li	a5,1
    461c:	c2dff06f          	j	4248 <__adddf3+0x410>
    4620:	40bf05b3          	sub	a1,t5,a1
    4624:	40e888b3          	sub	a7,a7,a4
    4628:	00bf3733          	sltu	a4,t5,a1
    462c:	00058493          	mv	s1,a1
    4630:	40e889b3          	sub	s3,a7,a4
    4634:	00068413          	mv	s0,a3
    4638:	00100913          	li	s2,1
    463c:	8c9ff06f          	j	3f04 <__adddf3+0xcc>
    4640:	00361613          	slli	a2,a2,0x3
    4644:	00365613          	srli	a2,a2,0x3
    4648:	00088713          	mv	a4,a7
    464c:	cc5ff06f          	j	4310 <__adddf3+0x4d8>
    4650:	00361613          	slli	a2,a2,0x3
    4654:	00365993          	srli	s3,a2,0x3
    4658:	00088713          	mv	a4,a7
    465c:	de5ff06f          	j	4440 <__adddf3+0x608>
    4660:	fe078693          	addi	a3,a5,-32
    4664:	02000613          	li	a2,32
    4668:	00d756b3          	srl	a3,a4,a3
    466c:	00c78a63          	beq	a5,a2,4680 <__adddf3+0x848>
    4670:	04000613          	li	a2,64
    4674:	40f607b3          	sub	a5,a2,a5
    4678:	00f717b3          	sll	a5,a4,a5
    467c:	00f5e5b3          	or	a1,a1,a5
    4680:	00b039b3          	snez	s3,a1
    4684:	00d9e9b3          	or	s3,s3,a3
    4688:	c35ff06f          	j	42bc <__adddf3+0x484>
    468c:	0034d613          	srli	a2,s1,0x3
    4690:	00090793          	mv	a5,s2
    4694:	00098713          	mv	a4,s3
    4698:	c79ff06f          	j	4310 <__adddf3+0x4d8>
    469c:	02000693          	li	a3,32
    46a0:	40f686b3          	sub	a3,a3,a5
    46a4:	00000613          	li	a2,0
    46a8:	8b5ff06f          	j	3f5c <__adddf3+0x124>
    46ac:	00c9e833          	or	a6,s3,a2
    46b0:	d00808e3          	beqz	a6,43c0 <__adddf3+0x588>
    46b4:	0039d993          	srli	s3,s3,0x3
    46b8:	00060713          	mv	a4,a2
    46bc:	d85ff06f          	j	4440 <__adddf3+0x608>
    46c0:	00000e13          	li	t3,0
    46c4:	7ff00793          	li	a5,2047
    46c8:	00080737          	lui	a4,0x80
    46cc:	905ff06f          	j	3fd0 <__adddf3+0x198>
    46d0:	01d71793          	slli	a5,a4,0x1d
    46d4:	00375713          	srli	a4,a4,0x3
    46d8:	0107e833          	or	a6,a5,a6
    46dc:	01d77733          	and	a4,a4,t4
    46e0:	00000793          	li	a5,0
    46e4:	8edff06f          	j	3fd0 <__adddf3+0x198>
    46e8:	01d71813          	slli	a6,a4,0x1d
    46ec:	0035d593          	srli	a1,a1,0x3
    46f0:	00b86833          	or	a6,a6,a1
    46f4:	00375713          	srli	a4,a4,0x3
    46f8:	00068413          	mv	s0,a3
    46fc:	c29ff06f          	j	4324 <__adddf3+0x4ec>

00004700 <__divdf3>:
    4700:	fd010113          	addi	sp,sp,-48
    4704:	01312e23          	sw	s3,28(sp)
    4708:	0145d993          	srli	s3,a1,0x14
    470c:	02812423          	sw	s0,40(sp)
    4710:	02912223          	sw	s1,36(sp)
    4714:	03212023          	sw	s2,32(sp)
    4718:	01412c23          	sw	s4,24(sp)
    471c:	01712623          	sw	s7,12(sp)
    4720:	00c59493          	slli	s1,a1,0xc
    4724:	02112623          	sw	ra,44(sp)
    4728:	01512a23          	sw	s5,20(sp)
    472c:	01612823          	sw	s6,16(sp)
    4730:	01812423          	sw	s8,8(sp)
    4734:	7ff9f993          	andi	s3,s3,2047
    4738:	00050413          	mv	s0,a0
    473c:	00060b93          	mv	s7,a2
    4740:	00068913          	mv	s2,a3
    4744:	00c4d493          	srli	s1,s1,0xc
    4748:	01f5da13          	srli	s4,a1,0x1f
    474c:	18098c63          	beqz	s3,48e4 <__divdf3+0x1e4>
    4750:	7ff00793          	li	a5,2047
    4754:	08f98a63          	beq	s3,a5,47e8 <__divdf3+0xe8>
    4758:	00349493          	slli	s1,s1,0x3
    475c:	01d55793          	srli	a5,a0,0x1d
    4760:	0097e7b3          	or	a5,a5,s1
    4764:	00800737          	lui	a4,0x800
    4768:	00e7eab3          	or	s5,a5,a4
    476c:	00351b13          	slli	s6,a0,0x3
    4770:	c0198993          	addi	s3,s3,-1023
    4774:	00000493          	li	s1,0
    4778:	00000c13          	li	s8,0
    477c:	01495793          	srli	a5,s2,0x14
    4780:	00c91413          	slli	s0,s2,0xc
    4784:	7ff7f793          	andi	a5,a5,2047
    4788:	00c45413          	srli	s0,s0,0xc
    478c:	01f95913          	srli	s2,s2,0x1f
    4790:	08078463          	beqz	a5,4818 <__divdf3+0x118>
    4794:	7ff00713          	li	a4,2047
    4798:	18e78c63          	beq	a5,a4,4930 <__divdf3+0x230>
    479c:	00341413          	slli	s0,s0,0x3
    47a0:	01dbd713          	srli	a4,s7,0x1d
    47a4:	00876733          	or	a4,a4,s0
    47a8:	c0178793          	addi	a5,a5,-1023
    47ac:	00800437          	lui	s0,0x800
    47b0:	00876433          	or	s0,a4,s0
    47b4:	003b9893          	slli	a7,s7,0x3
    47b8:	40f989b3          	sub	s3,s3,a5
    47bc:	00000613          	li	a2,0
    47c0:	00f00713          	li	a4,15
    47c4:	012a46b3          	xor	a3,s4,s2
    47c8:	24976663          	bltu	a4,s1,4a14 <__divdf3+0x314>
    47cc:	00002717          	auipc	a4,0x2
    47d0:	f0470713          	addi	a4,a4,-252 # 66d0 <pow10.0+0x50>
    47d4:	00249493          	slli	s1,s1,0x2
    47d8:	00e484b3          	add	s1,s1,a4
    47dc:	0004a783          	lw	a5,0(s1)
    47e0:	00e787b3          	add	a5,a5,a4
    47e4:	00078067          	jr	a5
    47e8:	00a4eab3          	or	s5,s1,a0
    47ec:	1c0a9e63          	bnez	s5,49c8 <__divdf3+0x2c8>
    47f0:	01495793          	srli	a5,s2,0x14
    47f4:	00c91413          	slli	s0,s2,0xc
    47f8:	7ff7f793          	andi	a5,a5,2047
    47fc:	00000b13          	li	s6,0
    4800:	00800493          	li	s1,8
    4804:	7ff00993          	li	s3,2047
    4808:	00200c13          	li	s8,2
    480c:	00c45413          	srli	s0,s0,0xc
    4810:	01f95913          	srli	s2,s2,0x1f
    4814:	f80790e3          	bnez	a5,4794 <__divdf3+0x94>
    4818:	017468b3          	or	a7,s0,s7
    481c:	1c088263          	beqz	a7,49e0 <__divdf3+0x2e0>
    4820:	4a040a63          	beqz	s0,4cd4 <__divdf3+0x5d4>
    4824:	00040513          	mv	a0,s0
    4828:	351010ef          	jal	6378 <__clzsi2>
    482c:	00050793          	mv	a5,a0
    4830:	ff550693          	addi	a3,a0,-11
    4834:	01d00713          	li	a4,29
    4838:	ff878893          	addi	a7,a5,-8
    483c:	40d70733          	sub	a4,a4,a3
    4840:	01141433          	sll	s0,s0,a7
    4844:	00ebd733          	srl	a4,s7,a4
    4848:	00876433          	or	s0,a4,s0
    484c:	011b98b3          	sll	a7,s7,a7
    4850:	013787b3          	add	a5,a5,s3
    4854:	3f378993          	addi	s3,a5,1011
    4858:	00000613          	li	a2,0
    485c:	f65ff06f          	j	47c0 <__divdf3+0xc0>
    4860:	40f70733          	sub	a4,a4,a5
    4864:	03800613          	li	a2,56
    4868:	4ee65a63          	bge	a2,a4,4d5c <__divdf3+0x65c>
    486c:	00000793          	li	a5,0
    4870:	00000613          	li	a2,0
    4874:	00000713          	li	a4,0
    4878:	02c12083          	lw	ra,44(sp)
    487c:	02812403          	lw	s0,40(sp)
    4880:	01479793          	slli	a5,a5,0x14
    4884:	00c7e7b3          	or	a5,a5,a2
    4888:	01f69693          	slli	a3,a3,0x1f
    488c:	00d7e7b3          	or	a5,a5,a3
    4890:	02412483          	lw	s1,36(sp)
    4894:	02012903          	lw	s2,32(sp)
    4898:	01c12983          	lw	s3,28(sp)
    489c:	01812a03          	lw	s4,24(sp)
    48a0:	01412a83          	lw	s5,20(sp)
    48a4:	01012b03          	lw	s6,16(sp)
    48a8:	00c12b83          	lw	s7,12(sp)
    48ac:	00812c03          	lw	s8,8(sp)
    48b0:	00070513          	mv	a0,a4
    48b4:	00078593          	mv	a1,a5
    48b8:	03010113          	addi	sp,sp,48
    48bc:	00008067          	ret
    48c0:	7ff00793          	li	a5,2047
    48c4:	00000613          	li	a2,0
    48c8:	00000713          	li	a4,0
    48cc:	fadff06f          	j	4878 <__divdf3+0x178>
    48d0:	00000693          	li	a3,0
    48d4:	7ff00793          	li	a5,2047
    48d8:	00080637          	lui	a2,0x80
    48dc:	00000713          	li	a4,0
    48e0:	f99ff06f          	j	4878 <__divdf3+0x178>
    48e4:	00a4eab3          	or	s5,s1,a0
    48e8:	100a8c63          	beqz	s5,4a00 <__divdf3+0x300>
    48ec:	40048863          	beqz	s1,4cfc <__divdf3+0x5fc>
    48f0:	00048513          	mv	a0,s1
    48f4:	285010ef          	jal	6378 <__clzsi2>
    48f8:	00050713          	mv	a4,a0
    48fc:	ff550693          	addi	a3,a0,-11
    4900:	01d00793          	li	a5,29
    4904:	ff870b13          	addi	s6,a4,-8
    4908:	40d787b3          	sub	a5,a5,a3
    490c:	016494b3          	sll	s1,s1,s6
    4910:	00f457b3          	srl	a5,s0,a5
    4914:	0097eab3          	or	s5,a5,s1
    4918:	01641b33          	sll	s6,s0,s6
    491c:	c0d00993          	li	s3,-1011
    4920:	40e989b3          	sub	s3,s3,a4
    4924:	00000493          	li	s1,0
    4928:	00000c13          	li	s8,0
    492c:	e51ff06f          	j	477c <__divdf3+0x7c>
    4930:	017468b3          	or	a7,s0,s7
    4934:	80198993          	addi	s3,s3,-2047
    4938:	0a089c63          	bnez	a7,49f0 <__divdf3+0x2f0>
    493c:	0024e493          	ori	s1,s1,2
    4940:	00000413          	li	s0,0
    4944:	00200613          	li	a2,2
    4948:	e79ff06f          	j	47c0 <__divdf3+0xc0>
    494c:	000a0913          	mv	s2,s4
    4950:	000a8413          	mv	s0,s5
    4954:	000b0893          	mv	a7,s6
    4958:	00200793          	li	a5,2
    495c:	4efc0863          	beq	s8,a5,4e4c <__divdf3+0x74c>
    4960:	00300793          	li	a5,3
    4964:	f6fc06e3          	beq	s8,a5,48d0 <__divdf3+0x1d0>
    4968:	00100793          	li	a5,1
    496c:	00090693          	mv	a3,s2
    4970:	eefc0ee3          	beq	s8,a5,486c <__divdf3+0x16c>
    4974:	3ff98793          	addi	a5,s3,1023
    4978:	2af05663          	blez	a5,4c24 <__divdf3+0x524>
    497c:	0078f713          	andi	a4,a7,7
    4980:	4a071663          	bnez	a4,4e2c <__divdf3+0x72c>
    4984:	00741713          	slli	a4,s0,0x7
    4988:	00075a63          	bgez	a4,499c <__divdf3+0x29c>
    498c:	ff0007b7          	lui	a5,0xff000
    4990:	fff78793          	addi	a5,a5,-1 # feffffff <__freertos_irq_stack_top+0xfeff873f>
    4994:	00f47433          	and	s0,s0,a5
    4998:	40098793          	addi	a5,s3,1024
    499c:	7fe00713          	li	a4,2046
    49a0:	f2f740e3          	blt	a4,a5,48c0 <__divdf3+0x1c0>
    49a4:	0038d893          	srli	a7,a7,0x3
    49a8:	01d41713          	slli	a4,s0,0x1d
    49ac:	00941613          	slli	a2,s0,0x9
    49b0:	01176733          	or	a4,a4,a7
    49b4:	00c65613          	srli	a2,a2,0xc
    49b8:	7ff7f793          	andi	a5,a5,2047
    49bc:	ebdff06f          	j	4878 <__divdf3+0x178>
    49c0:	00060c13          	mv	s8,a2
    49c4:	f95ff06f          	j	4958 <__divdf3+0x258>
    49c8:	00048a93          	mv	s5,s1
    49cc:	00050b13          	mv	s6,a0
    49d0:	00c00493          	li	s1,12
    49d4:	7ff00993          	li	s3,2047
    49d8:	00300c13          	li	s8,3
    49dc:	da1ff06f          	j	477c <__divdf3+0x7c>
    49e0:	0014e493          	ori	s1,s1,1
    49e4:	00000413          	li	s0,0
    49e8:	00100613          	li	a2,1
    49ec:	dd5ff06f          	j	47c0 <__divdf3+0xc0>
    49f0:	0034e493          	ori	s1,s1,3
    49f4:	000b8893          	mv	a7,s7
    49f8:	00300613          	li	a2,3
    49fc:	dc5ff06f          	j	47c0 <__divdf3+0xc0>
    4a00:	00000b13          	li	s6,0
    4a04:	00400493          	li	s1,4
    4a08:	00000993          	li	s3,0
    4a0c:	00100c13          	li	s8,1
    4a10:	d6dff06f          	j	477c <__divdf3+0x7c>
    4a14:	2b546463          	bltu	s0,s5,4cbc <__divdf3+0x5bc>
    4a18:	2a8a8063          	beq	s5,s0,4cb8 <__divdf3+0x5b8>
    4a1c:	000b0313          	mv	t1,s6
    4a20:	fff98993          	addi	s3,s3,-1
    4a24:	000a8793          	mv	a5,s5
    4a28:	00000b13          	li	s6,0
    4a2c:	00841713          	slli	a4,s0,0x8
    4a30:	01075513          	srli	a0,a4,0x10
    4a34:	02a7d433          	divu	s0,a5,a0
    4a38:	0188d613          	srli	a2,a7,0x18
    4a3c:	00e66633          	or	a2,a2,a4
    4a40:	01061813          	slli	a6,a2,0x10
    4a44:	01085813          	srli	a6,a6,0x10
    4a48:	00889593          	slli	a1,a7,0x8
    4a4c:	01035713          	srli	a4,t1,0x10
    4a50:	02a7f7b3          	remu	a5,a5,a0
    4a54:	028808b3          	mul	a7,a6,s0
    4a58:	01079793          	slli	a5,a5,0x10
    4a5c:	00f767b3          	or	a5,a4,a5
    4a60:	0117fa63          	bgeu	a5,a7,4a74 <__divdf3+0x374>
    4a64:	00f607b3          	add	a5,a2,a5
    4a68:	fff40713          	addi	a4,s0,-1 # 7fffff <__freertos_irq_stack_top+0x7f873f>
    4a6c:	2ec7f063          	bgeu	a5,a2,4d4c <__divdf3+0x64c>
    4a70:	00070413          	mv	s0,a4
    4a74:	411787b3          	sub	a5,a5,a7
    4a78:	02a7d8b3          	divu	a7,a5,a0
    4a7c:	01031713          	slli	a4,t1,0x10
    4a80:	01075713          	srli	a4,a4,0x10
    4a84:	02a7f7b3          	remu	a5,a5,a0
    4a88:	03180fb3          	mul	t6,a6,a7
    4a8c:	01079793          	slli	a5,a5,0x10
    4a90:	00f76733          	or	a4,a4,a5
    4a94:	01f77a63          	bgeu	a4,t6,4aa8 <__divdf3+0x3a8>
    4a98:	00e60733          	add	a4,a2,a4
    4a9c:	fff88793          	addi	a5,a7,-1
    4aa0:	28c77e63          	bgeu	a4,a2,4d3c <__divdf3+0x63c>
    4aa4:	00078893          	mv	a7,a5
    4aa8:	01041413          	slli	s0,s0,0x10
    4aac:	000102b7          	lui	t0,0x10
    4ab0:	01146433          	or	s0,s0,a7
    4ab4:	fff28313          	addi	t1,t0,-1 # ffff <__freertos_irq_stack_top+0x873f>
    4ab8:	006478b3          	and	a7,s0,t1
    4abc:	01045e93          	srli	t4,s0,0x10
    4ac0:	0105de13          	srli	t3,a1,0x10
    4ac4:	0065f333          	and	t1,a1,t1
    4ac8:	03130f33          	mul	t5,t1,a7
    4acc:	41f70733          	sub	a4,a4,t6
    4ad0:	031e08b3          	mul	a7,t3,a7
    4ad4:	010f5793          	srli	a5,t5,0x10
    4ad8:	026e8fb3          	mul	t6,t4,t1
    4adc:	01f888b3          	add	a7,a7,t6
    4ae0:	011787b3          	add	a5,a5,a7
    4ae4:	03ce8eb3          	mul	t4,t4,t3
    4ae8:	01f7f463          	bgeu	a5,t6,4af0 <__divdf3+0x3f0>
    4aec:	005e8eb3          	add	t4,t4,t0
    4af0:	00010fb7          	lui	t6,0x10
    4af4:	ffff8f93          	addi	t6,t6,-1 # ffff <__freertos_irq_stack_top+0x873f>
    4af8:	0107d893          	srli	a7,a5,0x10
    4afc:	01f7f7b3          	and	a5,a5,t6
    4b00:	01079793          	slli	a5,a5,0x10
    4b04:	01ff7f33          	and	t5,t5,t6
    4b08:	01d888b3          	add	a7,a7,t4
    4b0c:	01e787b3          	add	a5,a5,t5
    4b10:	17176e63          	bltu	a4,a7,4c8c <__divdf3+0x58c>
    4b14:	17170a63          	beq	a4,a7,4c88 <__divdf3+0x588>
    4b18:	40fb07b3          	sub	a5,s6,a5
    4b1c:	41170733          	sub	a4,a4,a7
    4b20:	00fb3b33          	sltu	s6,s6,a5
    4b24:	41670733          	sub	a4,a4,s6
    4b28:	2ee60063          	beq	a2,a4,4e08 <__divdf3+0x708>
    4b2c:	02a758b3          	divu	a7,a4,a0
    4b30:	0107de93          	srli	t4,a5,0x10
    4b34:	02a77733          	remu	a4,a4,a0
    4b38:	03180f33          	mul	t5,a6,a7
    4b3c:	01071713          	slli	a4,a4,0x10
    4b40:	00eee733          	or	a4,t4,a4
    4b44:	01e77e63          	bgeu	a4,t5,4b60 <__divdf3+0x460>
    4b48:	00e60733          	add	a4,a2,a4
    4b4c:	fff88e93          	addi	t4,a7,-1
    4b50:	2ec76a63          	bltu	a4,a2,4e44 <__divdf3+0x744>
    4b54:	2fe77863          	bgeu	a4,t5,4e44 <__divdf3+0x744>
    4b58:	ffe88893          	addi	a7,a7,-2
    4b5c:	00c70733          	add	a4,a4,a2
    4b60:	41e70733          	sub	a4,a4,t5
    4b64:	02a75eb3          	divu	t4,a4,a0
    4b68:	01079793          	slli	a5,a5,0x10
    4b6c:	0107d793          	srli	a5,a5,0x10
    4b70:	02a77733          	remu	a4,a4,a0
    4b74:	03d80833          	mul	a6,a6,t4
    4b78:	01071713          	slli	a4,a4,0x10
    4b7c:	00e7e7b3          	or	a5,a5,a4
    4b80:	0107fe63          	bgeu	a5,a6,4b9c <__divdf3+0x49c>
    4b84:	00f607b3          	add	a5,a2,a5
    4b88:	fffe8713          	addi	a4,t4,-1
    4b8c:	2ac7e863          	bltu	a5,a2,4e3c <__divdf3+0x73c>
    4b90:	2b07f663          	bgeu	a5,a6,4e3c <__divdf3+0x73c>
    4b94:	ffee8e93          	addi	t4,t4,-2
    4b98:	00c787b3          	add	a5,a5,a2
    4b9c:	01089893          	slli	a7,a7,0x10
    4ba0:	01d8e8b3          	or	a7,a7,t4
    4ba4:	01089513          	slli	a0,a7,0x10
    4ba8:	0108df13          	srli	t5,a7,0x10
    4bac:	01055513          	srli	a0,a0,0x10
    4bb0:	02650eb3          	mul	t4,a0,t1
    4bb4:	410787b3          	sub	a5,a5,a6
    4bb8:	02ae0533          	mul	a0,t3,a0
    4bbc:	010ed713          	srli	a4,t4,0x10
    4bc0:	026f0333          	mul	t1,t5,t1
    4bc4:	00650533          	add	a0,a0,t1
    4bc8:	00a70733          	add	a4,a4,a0
    4bcc:	03ee0e33          	mul	t3,t3,t5
    4bd0:	00677663          	bgeu	a4,t1,4bdc <__divdf3+0x4dc>
    4bd4:	00010537          	lui	a0,0x10
    4bd8:	00ae0e33          	add	t3,t3,a0
    4bdc:	00010837          	lui	a6,0x10
    4be0:	fff80813          	addi	a6,a6,-1 # ffff <__freertos_irq_stack_top+0x873f>
    4be4:	01075513          	srli	a0,a4,0x10
    4be8:	01077733          	and	a4,a4,a6
    4bec:	01071713          	slli	a4,a4,0x10
    4bf0:	010efeb3          	and	t4,t4,a6
    4bf4:	01c50533          	add	a0,a0,t3
    4bf8:	01d70733          	add	a4,a4,t4
    4bfc:	12a7f263          	bgeu	a5,a0,4d20 <__divdf3+0x620>
    4c00:	00f607b3          	add	a5,a2,a5
    4c04:	fff88313          	addi	t1,a7,-1
    4c08:	00078813          	mv	a6,a5
    4c0c:	1cc7e463          	bltu	a5,a2,4dd4 <__divdf3+0x6d4>
    4c10:	24a7e863          	bltu	a5,a0,4e60 <__divdf3+0x760>
    4c14:	26a78663          	beq	a5,a0,4e80 <__divdf3+0x780>
    4c18:	00030893          	mv	a7,t1
    4c1c:	0018e893          	ori	a7,a7,1
    4c20:	d55ff06f          	j	4974 <__divdf3+0x274>
    4c24:	00100713          	li	a4,1
    4c28:	c2079ce3          	bnez	a5,4860 <__divdf3+0x160>
    4c2c:	41e98993          	addi	s3,s3,1054
    4c30:	013897b3          	sll	a5,a7,s3
    4c34:	00f037b3          	snez	a5,a5
    4c38:	013419b3          	sll	s3,s0,s3
    4c3c:	0137e7b3          	or	a5,a5,s3
    4c40:	00e8d8b3          	srl	a7,a7,a4
    4c44:	00f8e8b3          	or	a7,a7,a5
    4c48:	0078f793          	andi	a5,a7,7
    4c4c:	00e45433          	srl	s0,s0,a4
    4c50:	02078063          	beqz	a5,4c70 <__divdf3+0x570>
    4c54:	00f8f793          	andi	a5,a7,15
    4c58:	00400713          	li	a4,4
    4c5c:	00e78a63          	beq	a5,a4,4c70 <__divdf3+0x570>
    4c60:	00488793          	addi	a5,a7,4
    4c64:	0117b8b3          	sltu	a7,a5,a7
    4c68:	01140433          	add	s0,s0,a7
    4c6c:	00078893          	mv	a7,a5
    4c70:	00841593          	slli	a1,s0,0x8
    4c74:	00100793          	li	a5,1
    4c78:	00000613          	li	a2,0
    4c7c:	00000713          	li	a4,0
    4c80:	be05cce3          	bltz	a1,4878 <__divdf3+0x178>
    4c84:	1340006f          	j	4db8 <__divdf3+0x6b8>
    4c88:	e8fb78e3          	bgeu	s6,a5,4b18 <__divdf3+0x418>
    4c8c:	00bb0eb3          	add	t4,s6,a1
    4c90:	016ebf33          	sltu	t5,t4,s6
    4c94:	00cf0fb3          	add	t6,t5,a2
    4c98:	01f70733          	add	a4,a4,t6
    4c9c:	000e8b13          	mv	s6,t4
    4ca0:	fff40f93          	addi	t6,s0,-1
    4ca4:	08e67463          	bgeu	a2,a4,4d2c <__divdf3+0x62c>
    4ca8:	15176263          	bltu	a4,a7,4dec <__divdf3+0x6ec>
    4cac:	12e88e63          	beq	a7,a4,4de8 <__divdf3+0x6e8>
    4cb0:	000f8413          	mv	s0,t6
    4cb4:	e65ff06f          	j	4b18 <__divdf3+0x418>
    4cb8:	d71b62e3          	bltu	s6,a7,4a1c <__divdf3+0x31c>
    4cbc:	001b5713          	srli	a4,s6,0x1
    4cc0:	01fa9313          	slli	t1,s5,0x1f
    4cc4:	001ad793          	srli	a5,s5,0x1
    4cc8:	00e36333          	or	t1,t1,a4
    4ccc:	01fb1b13          	slli	s6,s6,0x1f
    4cd0:	d5dff06f          	j	4a2c <__divdf3+0x32c>
    4cd4:	000b8513          	mv	a0,s7
    4cd8:	6a0010ef          	jal	6378 <__clzsi2>
    4cdc:	01550693          	addi	a3,a0,21 # 10015 <__freertos_irq_stack_top+0x8755>
    4ce0:	01c00713          	li	a4,28
    4ce4:	02050793          	addi	a5,a0,32
    4ce8:	b4d756e3          	bge	a4,a3,4834 <__divdf3+0x134>
    4cec:	ff850513          	addi	a0,a0,-8
    4cf0:	00000893          	li	a7,0
    4cf4:	00ab9433          	sll	s0,s7,a0
    4cf8:	b59ff06f          	j	4850 <__divdf3+0x150>
    4cfc:	67c010ef          	jal	6378 <__clzsi2>
    4d00:	01550693          	addi	a3,a0,21
    4d04:	01c00793          	li	a5,28
    4d08:	02050713          	addi	a4,a0,32
    4d0c:	bed7dae3          	bge	a5,a3,4900 <__divdf3+0x200>
    4d10:	ff850793          	addi	a5,a0,-8
    4d14:	00f41ab3          	sll	s5,s0,a5
    4d18:	00000b13          	li	s6,0
    4d1c:	c01ff06f          	j	491c <__divdf3+0x21c>
    4d20:	eea79ee3          	bne	a5,a0,4c1c <__divdf3+0x51c>
    4d24:	c40708e3          	beqz	a4,4974 <__divdf3+0x274>
    4d28:	ed9ff06f          	j	4c00 <__divdf3+0x500>
    4d2c:	f8e612e3          	bne	a2,a4,4cb0 <__divdf3+0x5b0>
    4d30:	f60f0ce3          	beqz	t5,4ca8 <__divdf3+0x5a8>
    4d34:	000f8413          	mv	s0,t6
    4d38:	de1ff06f          	j	4b18 <__divdf3+0x418>
    4d3c:	d7f774e3          	bgeu	a4,t6,4aa4 <__divdf3+0x3a4>
    4d40:	ffe88893          	addi	a7,a7,-2
    4d44:	00c70733          	add	a4,a4,a2
    4d48:	d61ff06f          	j	4aa8 <__divdf3+0x3a8>
    4d4c:	d317f2e3          	bgeu	a5,a7,4a70 <__divdf3+0x370>
    4d50:	ffe40413          	addi	s0,s0,-2
    4d54:	00c787b3          	add	a5,a5,a2
    4d58:	d1dff06f          	j	4a74 <__divdf3+0x374>
    4d5c:	01f00613          	li	a2,31
    4d60:	ece656e3          	bge	a2,a4,4c2c <__divdf3+0x52c>
    4d64:	fe100613          	li	a2,-31
    4d68:	40f607b3          	sub	a5,a2,a5
    4d6c:	02000613          	li	a2,32
    4d70:	00f457b3          	srl	a5,s0,a5
    4d74:	00c70863          	beq	a4,a2,4d84 <__divdf3+0x684>
    4d78:	43e98993          	addi	s3,s3,1086
    4d7c:	013419b3          	sll	s3,s0,s3
    4d80:	0138e8b3          	or	a7,a7,s3
    4d84:	011038b3          	snez	a7,a7
    4d88:	00f8e8b3          	or	a7,a7,a5
    4d8c:	0078f713          	andi	a4,a7,7
    4d90:	00000613          	li	a2,0
    4d94:	02070863          	beqz	a4,4dc4 <__divdf3+0x6c4>
    4d98:	00f8f793          	andi	a5,a7,15
    4d9c:	00400713          	li	a4,4
    4da0:	00000413          	li	s0,0
    4da4:	00e78a63          	beq	a5,a4,4db8 <__divdf3+0x6b8>
    4da8:	00488793          	addi	a5,a7,4
    4dac:	0117b8b3          	sltu	a7,a5,a7
    4db0:	01103433          	snez	s0,a7
    4db4:	00078893          	mv	a7,a5
    4db8:	00941613          	slli	a2,s0,0x9
    4dbc:	01d41713          	slli	a4,s0,0x1d
    4dc0:	00c65613          	srli	a2,a2,0xc
    4dc4:	0038d893          	srli	a7,a7,0x3
    4dc8:	00e8e733          	or	a4,a7,a4
    4dcc:	00000793          	li	a5,0
    4dd0:	aa9ff06f          	j	4878 <__divdf3+0x178>
    4dd4:	00030893          	mv	a7,t1
    4dd8:	e4a812e3          	bne	a6,a0,4c1c <__divdf3+0x51c>
    4ddc:	b8b70ce3          	beq	a4,a1,4974 <__divdf3+0x274>
    4de0:	0018e893          	ori	a7,a7,1
    4de4:	b91ff06f          	j	4974 <__divdf3+0x274>
    4de8:	ecfef4e3          	bgeu	t4,a5,4cb0 <__divdf3+0x5b0>
    4dec:	01d58eb3          	add	t4,a1,t4
    4df0:	00bebf33          	sltu	t5,t4,a1
    4df4:	00cf0f33          	add	t5,t5,a2
    4df8:	ffe40413          	addi	s0,s0,-2
    4dfc:	000e8b13          	mv	s6,t4
    4e00:	01e70733          	add	a4,a4,t5
    4e04:	d15ff06f          	j	4b18 <__divdf3+0x418>
    4e08:	c0200713          	li	a4,-1022
    4e0c:	3ff98793          	addi	a5,s3,1023
    4e10:	fff00893          	li	a7,-1
    4e14:	e0e9c8e3          	blt	s3,a4,4c24 <__divdf3+0x524>
    4e18:	00488713          	addi	a4,a7,4
    4e1c:	011738b3          	sltu	a7,a4,a7
    4e20:	01140433          	add	s0,s0,a7
    4e24:	00070893          	mv	a7,a4
    4e28:	b5dff06f          	j	4984 <__divdf3+0x284>
    4e2c:	00f8f713          	andi	a4,a7,15
    4e30:	00400613          	li	a2,4
    4e34:	b4c708e3          	beq	a4,a2,4984 <__divdf3+0x284>
    4e38:	fe1ff06f          	j	4e18 <__divdf3+0x718>
    4e3c:	00070e93          	mv	t4,a4
    4e40:	d5dff06f          	j	4b9c <__divdf3+0x49c>
    4e44:	000e8893          	mv	a7,t4
    4e48:	d19ff06f          	j	4b60 <__divdf3+0x460>
    4e4c:	00090693          	mv	a3,s2
    4e50:	7ff00793          	li	a5,2047
    4e54:	00000613          	li	a2,0
    4e58:	00000713          	li	a4,0
    4e5c:	a1dff06f          	j	4878 <__divdf3+0x178>
    4e60:	00159313          	slli	t1,a1,0x1
    4e64:	00b33833          	sltu	a6,t1,a1
    4e68:	00c80833          	add	a6,a6,a2
    4e6c:	01078833          	add	a6,a5,a6
    4e70:	ffe88893          	addi	a7,a7,-2
    4e74:	00030593          	mv	a1,t1
    4e78:	f6a802e3          	beq	a6,a0,4ddc <__divdf3+0x6dc>
    4e7c:	da1ff06f          	j	4c1c <__divdf3+0x51c>
    4e80:	fee5e0e3          	bltu	a1,a4,4e60 <__divdf3+0x760>
    4e84:	00030893          	mv	a7,t1
    4e88:	f4b71ce3          	bne	a4,a1,4de0 <__divdf3+0x6e0>
    4e8c:	ae9ff06f          	j	4974 <__divdf3+0x274>

00004e90 <__eqdf2>:
    4e90:	0145d713          	srli	a4,a1,0x14
    4e94:	001007b7          	lui	a5,0x100
    4e98:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf873f>
    4e9c:	0146d813          	srli	a6,a3,0x14
    4ea0:	7ff77713          	andi	a4,a4,2047
    4ea4:	7ff00313          	li	t1,2047
    4ea8:	00b7fe33          	and	t3,a5,a1
    4eac:	00050893          	mv	a7,a0
    4eb0:	00d7f7b3          	and	a5,a5,a3
    4eb4:	01f5d593          	srli	a1,a1,0x1f
    4eb8:	7ff87813          	andi	a6,a6,2047
    4ebc:	01f6d693          	srli	a3,a3,0x1f
    4ec0:	00100513          	li	a0,1
    4ec4:	00670c63          	beq	a4,t1,4edc <__eqdf2+0x4c>
    4ec8:	00680863          	beq	a6,t1,4ed8 <__eqdf2+0x48>
    4ecc:	01071463          	bne	a4,a6,4ed4 <__eqdf2+0x44>
    4ed0:	02fe0663          	beq	t3,a5,4efc <__eqdf2+0x6c>
    4ed4:	00008067          	ret
    4ed8:	00008067          	ret
    4edc:	fee81ce3          	bne	a6,a4,4ed4 <__eqdf2+0x44>
    4ee0:	00fe67b3          	or	a5,t3,a5
    4ee4:	00c7e7b3          	or	a5,a5,a2
    4ee8:	0117e7b3          	or	a5,a5,a7
    4eec:	fe0794e3          	bnez	a5,4ed4 <__eqdf2+0x44>
    4ef0:	40d585b3          	sub	a1,a1,a3
    4ef4:	00b03533          	snez	a0,a1
    4ef8:	00008067          	ret
    4efc:	fcc89ce3          	bne	a7,a2,4ed4 <__eqdf2+0x44>
    4f00:	00d58a63          	beq	a1,a3,4f14 <__eqdf2+0x84>
    4f04:	fc0718e3          	bnez	a4,4ed4 <__eqdf2+0x44>
    4f08:	011e6e33          	or	t3,t3,a7
    4f0c:	01c03533          	snez	a0,t3
    4f10:	00008067          	ret
    4f14:	00000513          	li	a0,0
    4f18:	00008067          	ret

00004f1c <__gedf2>:
    4f1c:	0145d893          	srli	a7,a1,0x14
    4f20:	001007b7          	lui	a5,0x100
    4f24:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf873f>
    4f28:	0146d713          	srli	a4,a3,0x14
    4f2c:	7ff8f893          	andi	a7,a7,2047
    4f30:	7ff00e13          	li	t3,2047
    4f34:	00b7f333          	and	t1,a5,a1
    4f38:	00050813          	mv	a6,a0
    4f3c:	00050e93          	mv	t4,a0
    4f40:	00d7f7b3          	and	a5,a5,a3
    4f44:	01f5d593          	srli	a1,a1,0x1f
    4f48:	00060f13          	mv	t5,a2
    4f4c:	7ff77513          	andi	a0,a4,2047
    4f50:	01f6d693          	srli	a3,a3,0x1f
    4f54:	05c88863          	beq	a7,t3,4fa4 <__gedf2+0x88>
    4f58:	03c50463          	beq	a0,t3,4f80 <__gedf2+0x64>
    4f5c:	06089a63          	bnez	a7,4fd0 <__gedf2+0xb4>
    4f60:	01036833          	or	a6,t1,a6
    4f64:	06051063          	bnez	a0,4fc4 <__gedf2+0xa8>
    4f68:	00c7e633          	or	a2,a5,a2
    4f6c:	08060c63          	beqz	a2,5004 <__gedf2+0xe8>
    4f70:	0a081263          	bnez	a6,5014 <__gedf2+0xf8>
    4f74:	00100513          	li	a0,1
    4f78:	08068263          	beqz	a3,4ffc <__gedf2+0xe0>
    4f7c:	00008067          	ret
    4f80:	00c7e633          	or	a2,a5,a2
    4f84:	08061463          	bnez	a2,500c <__gedf2+0xf0>
    4f88:	00089663          	bnez	a7,4f94 <__gedf2+0x78>
    4f8c:	01036333          	or	t1,t1,a6
    4f90:	fe0302e3          	beqz	t1,4f74 <__gedf2+0x58>
    4f94:	06d58063          	beq	a1,a3,4ff4 <__gedf2+0xd8>
    4f98:	06059263          	bnez	a1,4ffc <__gedf2+0xe0>
    4f9c:	00100513          	li	a0,1
    4fa0:	00008067          	ret
    4fa4:	01036333          	or	t1,t1,a6
    4fa8:	06031263          	bnez	t1,500c <__gedf2+0xf0>
    4fac:	ff1516e3          	bne	a0,a7,4f98 <__gedf2+0x7c>
    4fb0:	00c7e7b3          	or	a5,a5,a2
    4fb4:	04079c63          	bnez	a5,500c <__gedf2+0xf0>
    4fb8:	fed590e3          	bne	a1,a3,4f98 <__gedf2+0x7c>
    4fbc:	00000513          	li	a0,0
    4fc0:	00008067          	ret
    4fc4:	fa0808e3          	beqz	a6,4f74 <__gedf2+0x58>
    4fc8:	fcd598e3          	bne	a1,a3,4f98 <__gedf2+0x7c>
    4fcc:	0280006f          	j	4ff4 <__gedf2+0xd8>
    4fd0:	fc0504e3          	beqz	a0,4f98 <__gedf2+0x7c>
    4fd4:	fcd592e3          	bne	a1,a3,4f98 <__gedf2+0x7c>
    4fd8:	fd1540e3          	blt	a0,a7,4f98 <__gedf2+0x7c>
    4fdc:	00a8cc63          	blt	a7,a0,4ff4 <__gedf2+0xd8>
    4fe0:	fa67ece3          	bltu	a5,t1,4f98 <__gedf2+0x7c>
    4fe4:	00f31863          	bne	t1,a5,4ff4 <__gedf2+0xd8>
    4fe8:	fbdf68e3          	bltu	t5,t4,4f98 <__gedf2+0x7c>
    4fec:	00000513          	li	a0,0
    4ff0:	f9eef6e3          	bgeu	t4,t5,4f7c <__gedf2+0x60>
    4ff4:	00100513          	li	a0,1
    4ff8:	f80592e3          	bnez	a1,4f7c <__gedf2+0x60>
    4ffc:	fff00513          	li	a0,-1
    5000:	00008067          	ret
    5004:	f8081ae3          	bnez	a6,4f98 <__gedf2+0x7c>
    5008:	00008067          	ret
    500c:	ffe00513          	li	a0,-2
    5010:	00008067          	ret
    5014:	fcd586e3          	beq	a1,a3,4fe0 <__gedf2+0xc4>
    5018:	f81ff06f          	j	4f98 <__gedf2+0x7c>

0000501c <__ledf2>:
    501c:	0145d893          	srli	a7,a1,0x14
    5020:	001007b7          	lui	a5,0x100
    5024:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf873f>
    5028:	0146d713          	srli	a4,a3,0x14
    502c:	7ff8f893          	andi	a7,a7,2047
    5030:	7ff00313          	li	t1,2047
    5034:	00b7fe33          	and	t3,a5,a1
    5038:	00050813          	mv	a6,a0
    503c:	00050e93          	mv	t4,a0
    5040:	00d7f7b3          	and	a5,a5,a3
    5044:	01f5d593          	srli	a1,a1,0x1f
    5048:	00060f13          	mv	t5,a2
    504c:	7ff77513          	andi	a0,a4,2047
    5050:	01f6d693          	srli	a3,a3,0x1f
    5054:	04688a63          	beq	a7,t1,50a8 <__ledf2+0x8c>
    5058:	02650463          	beq	a0,t1,5080 <__ledf2+0x64>
    505c:	06089863          	bnez	a7,50cc <__ledf2+0xb0>
    5060:	010e6833          	or	a6,t3,a6
    5064:	08051e63          	bnez	a0,5100 <__ledf2+0xe4>
    5068:	00c7e633          	or	a2,a5,a2
    506c:	0a060463          	beqz	a2,5114 <__ledf2+0xf8>
    5070:	0a081663          	bnez	a6,511c <__ledf2+0x100>
    5074:	00100513          	li	a0,1
    5078:	08068063          	beqz	a3,50f8 <__ledf2+0xdc>
    507c:	00008067          	ret
    5080:	00c7e633          	or	a2,a5,a2
    5084:	00200513          	li	a0,2
    5088:	fe061ae3          	bnez	a2,507c <__ledf2+0x60>
    508c:	00089663          	bnez	a7,5098 <__ledf2+0x7c>
    5090:	010e6e33          	or	t3,t3,a6
    5094:	fe0e00e3          	beqz	t3,5074 <__ledf2+0x58>
    5098:	04d58c63          	beq	a1,a3,50f0 <__ledf2+0xd4>
    509c:	04059e63          	bnez	a1,50f8 <__ledf2+0xdc>
    50a0:	00100513          	li	a0,1
    50a4:	00008067          	ret
    50a8:	010e6e33          	or	t3,t3,a6
    50ac:	060e1063          	bnez	t3,510c <__ledf2+0xf0>
    50b0:	ff1516e3          	bne	a0,a7,509c <__ledf2+0x80>
    50b4:	00c7e7b3          	or	a5,a5,a2
    50b8:	00200513          	li	a0,2
    50bc:	fc0790e3          	bnez	a5,507c <__ledf2+0x60>
    50c0:	fcd59ee3          	bne	a1,a3,509c <__ledf2+0x80>
    50c4:	00000513          	li	a0,0
    50c8:	00008067          	ret
    50cc:	fc0508e3          	beqz	a0,509c <__ledf2+0x80>
    50d0:	fcd596e3          	bne	a1,a3,509c <__ledf2+0x80>
    50d4:	fd1544e3          	blt	a0,a7,509c <__ledf2+0x80>
    50d8:	00a8cc63          	blt	a7,a0,50f0 <__ledf2+0xd4>
    50dc:	fdc7e0e3          	bltu	a5,t3,509c <__ledf2+0x80>
    50e0:	00fe1863          	bne	t3,a5,50f0 <__ledf2+0xd4>
    50e4:	fbdf6ce3          	bltu	t5,t4,509c <__ledf2+0x80>
    50e8:	00000513          	li	a0,0
    50ec:	f9eef8e3          	bgeu	t4,t5,507c <__ledf2+0x60>
    50f0:	00100513          	li	a0,1
    50f4:	f80594e3          	bnez	a1,507c <__ledf2+0x60>
    50f8:	fff00513          	li	a0,-1
    50fc:	00008067          	ret
    5100:	f6080ae3          	beqz	a6,5074 <__ledf2+0x58>
    5104:	f8d59ce3          	bne	a1,a3,509c <__ledf2+0x80>
    5108:	fe9ff06f          	j	50f0 <__ledf2+0xd4>
    510c:	00200513          	li	a0,2
    5110:	00008067          	ret
    5114:	f80814e3          	bnez	a6,509c <__ledf2+0x80>
    5118:	00008067          	ret
    511c:	fcd580e3          	beq	a1,a3,50dc <__ledf2+0xc0>
    5120:	f7dff06f          	j	509c <__ledf2+0x80>

00005124 <__muldf3>:
    5124:	fd010113          	addi	sp,sp,-48
    5128:	0145d793          	srli	a5,a1,0x14
    512c:	02812423          	sw	s0,40(sp)
    5130:	02912223          	sw	s1,36(sp)
    5134:	03212023          	sw	s2,32(sp)
    5138:	01312e23          	sw	s3,28(sp)
    513c:	01512a23          	sw	s5,20(sp)
    5140:	00c59493          	slli	s1,a1,0xc
    5144:	02112623          	sw	ra,44(sp)
    5148:	01412c23          	sw	s4,24(sp)
    514c:	01612823          	sw	s6,16(sp)
    5150:	01712623          	sw	s7,12(sp)
    5154:	01812423          	sw	s8,8(sp)
    5158:	7ff7f793          	andi	a5,a5,2047
    515c:	00050413          	mv	s0,a0
    5160:	00060a93          	mv	s5,a2
    5164:	00068993          	mv	s3,a3
    5168:	00c4d493          	srli	s1,s1,0xc
    516c:	01f5d913          	srli	s2,a1,0x1f
    5170:	42078463          	beqz	a5,5598 <__muldf3+0x474>
    5174:	7ff00713          	li	a4,2047
    5178:	0ae78663          	beq	a5,a4,5224 <__muldf3+0x100>
    517c:	00349693          	slli	a3,s1,0x3
    5180:	01d55713          	srli	a4,a0,0x1d
    5184:	00d76733          	or	a4,a4,a3
    5188:	008006b7          	lui	a3,0x800
    518c:	00d764b3          	or	s1,a4,a3
    5190:	00351a13          	slli	s4,a0,0x3
    5194:	c0178c13          	addi	s8,a5,-1023
    5198:	00000b13          	li	s6,0
    519c:	00000b93          	li	s7,0
    51a0:	0149d793          	srli	a5,s3,0x14
    51a4:	00c99713          	slli	a4,s3,0xc
    51a8:	7ff7f793          	andi	a5,a5,2047
    51ac:	000a8f13          	mv	t5,s5
    51b0:	00c75413          	srli	s0,a4,0xc
    51b4:	01f9d993          	srli	s3,s3,0x1f
    51b8:	0a078063          	beqz	a5,5258 <__muldf3+0x134>
    51bc:	7ff00713          	li	a4,2047
    51c0:	14e78e63          	beq	a5,a4,531c <__muldf3+0x1f8>
    51c4:	00341713          	slli	a4,s0,0x3
    51c8:	01dad593          	srli	a1,s5,0x1d
    51cc:	00e5e5b3          	or	a1,a1,a4
    51d0:	c0178793          	addi	a5,a5,-1023
    51d4:	00800737          	lui	a4,0x800
    51d8:	00e5e433          	or	s0,a1,a4
    51dc:	003a9f13          	slli	t5,s5,0x3
    51e0:	018788b3          	add	a7,a5,s8
    51e4:	00000313          	li	t1,0
    51e8:	00a00713          	li	a4,10
    51ec:	00188513          	addi	a0,a7,1
    51f0:	0b674c63          	blt	a4,s6,52a8 <__muldf3+0x184>
    51f4:	013945b3          	xor	a1,s2,s3
    51f8:	00200793          	li	a5,2
    51fc:	00058813          	mv	a6,a1
    5200:	1567c663          	blt	a5,s6,534c <__muldf3+0x228>
    5204:	fffb0b13          	addi	s6,s6,-1
    5208:	00100713          	li	a4,1
    520c:	17676063          	bltu	a4,s6,536c <__muldf3+0x248>
    5210:	3cf30a63          	beq	t1,a5,55e4 <__muldf3+0x4c0>
    5214:	00040493          	mv	s1,s0
    5218:	000f0a13          	mv	s4,t5
    521c:	00030b93          	mv	s7,t1
    5220:	09c0006f          	j	52bc <__muldf3+0x198>
    5224:	00a4ea33          	or	s4,s1,a0
    5228:	3c0a1863          	bnez	s4,55f8 <__muldf3+0x4d4>
    522c:	0149d793          	srli	a5,s3,0x14
    5230:	00c99713          	slli	a4,s3,0xc
    5234:	7ff7f793          	andi	a5,a5,2047
    5238:	00000493          	li	s1,0
    523c:	00800b13          	li	s6,8
    5240:	7ff00c13          	li	s8,2047
    5244:	00200b93          	li	s7,2
    5248:	000a8f13          	mv	t5,s5
    524c:	00c75413          	srli	s0,a4,0xc
    5250:	01f9d993          	srli	s3,s3,0x1f
    5254:	f60794e3          	bnez	a5,51bc <__muldf3+0x98>
    5258:	015467b3          	or	a5,s0,s5
    525c:	3c078263          	beqz	a5,5620 <__muldf3+0x4fc>
    5260:	4a040063          	beqz	s0,5700 <__muldf3+0x5dc>
    5264:	00040513          	mv	a0,s0
    5268:	110010ef          	jal	6378 <__clzsi2>
    526c:	00050893          	mv	a7,a0
    5270:	ff550713          	addi	a4,a0,-11
    5274:	01d00793          	li	a5,29
    5278:	ff888f13          	addi	t5,a7,-8
    527c:	40e787b3          	sub	a5,a5,a4
    5280:	00fad7b3          	srl	a5,s5,a5
    5284:	01e41733          	sll	a4,s0,t5
    5288:	00e7e433          	or	s0,a5,a4
    528c:	01ea9f33          	sll	t5,s5,t5
    5290:	411c08b3          	sub	a7,s8,a7
    5294:	c0d88893          	addi	a7,a7,-1011
    5298:	00a00713          	li	a4,10
    529c:	00000313          	li	t1,0
    52a0:	00188513          	addi	a0,a7,1
    52a4:	f56758e3          	bge	a4,s6,51f4 <__muldf3+0xd0>
    52a8:	00090593          	mv	a1,s2
    52ac:	00200793          	li	a5,2
    52b0:	32fb8a63          	beq	s7,a5,55e4 <__muldf3+0x4c0>
    52b4:	00300793          	li	a5,3
    52b8:	48fb8c63          	beq	s7,a5,5750 <__muldf3+0x62c>
    52bc:	00100793          	li	a5,1
    52c0:	00058813          	mv	a6,a1
    52c4:	46fb9a63          	bne	s7,a5,5738 <__muldf3+0x614>
    52c8:	00000793          	li	a5,0
    52cc:	00000693          	li	a3,0
    52d0:	00000713          	li	a4,0
    52d4:	02c12083          	lw	ra,44(sp)
    52d8:	02812403          	lw	s0,40(sp)
    52dc:	01479793          	slli	a5,a5,0x14
    52e0:	00d7e7b3          	or	a5,a5,a3
    52e4:	01f81693          	slli	a3,a6,0x1f
    52e8:	00d7e7b3          	or	a5,a5,a3
    52ec:	02412483          	lw	s1,36(sp)
    52f0:	02012903          	lw	s2,32(sp)
    52f4:	01c12983          	lw	s3,28(sp)
    52f8:	01812a03          	lw	s4,24(sp)
    52fc:	01412a83          	lw	s5,20(sp)
    5300:	01012b03          	lw	s6,16(sp)
    5304:	00c12b83          	lw	s7,12(sp)
    5308:	00812c03          	lw	s8,8(sp)
    530c:	00070513          	mv	a0,a4
    5310:	00078593          	mv	a1,a5
    5314:	03010113          	addi	sp,sp,48
    5318:	00008067          	ret
    531c:	01546733          	or	a4,s0,s5
    5320:	7ffc0893          	addi	a7,s8,2047
    5324:	30070a63          	beqz	a4,5638 <__muldf3+0x514>
    5328:	00001737          	lui	a4,0x1
    532c:	01394833          	xor	a6,s2,s3
    5330:	80070713          	addi	a4,a4,-2048 # 800 <CUSTOM2+0x7a5>
    5334:	003b6b13          	ori	s6,s6,3
    5338:	00a00693          	li	a3,10
    533c:	00080593          	mv	a1,a6
    5340:	00ec0533          	add	a0,s8,a4
    5344:	3966c063          	blt	a3,s6,56c4 <__muldf3+0x5a0>
    5348:	00300313          	li	t1,3
    534c:	00100613          	li	a2,1
    5350:	01661633          	sll	a2,a2,s6
    5354:	53067713          	andi	a4,a2,1328
    5358:	f4071ae3          	bnez	a4,52ac <__muldf3+0x188>
    535c:	24067793          	andi	a5,a2,576
    5360:	3c079463          	bnez	a5,5728 <__muldf3+0x604>
    5364:	08867613          	andi	a2,a2,136
    5368:	2e061263          	bnez	a2,564c <__muldf3+0x528>
    536c:	00010fb7          	lui	t6,0x10
    5370:	ffff8e93          	addi	t4,t6,-1 # ffff <__freertos_irq_stack_top+0x873f>
    5374:	01da77b3          	and	a5,s4,t4
    5378:	010a5693          	srli	a3,s4,0x10
    537c:	01df7eb3          	and	t4,t5,t4
    5380:	010f5e13          	srli	t3,t5,0x10
    5384:	03d78733          	mul	a4,a5,t4
    5388:	03d68333          	mul	t1,a3,t4
    538c:	01075593          	srli	a1,a4,0x10
    5390:	02fe0633          	mul	a2,t3,a5
    5394:	00660633          	add	a2,a2,t1
    5398:	00c585b3          	add	a1,a1,a2
    539c:	03c68f33          	mul	t5,a3,t3
    53a0:	0065f463          	bgeu	a1,t1,53a8 <__muldf3+0x284>
    53a4:	01ff0f33          	add	t5,t5,t6
    53a8:	000103b7          	lui	t2,0x10
    53ac:	fff38613          	addi	a2,t2,-1 # ffff <__freertos_irq_stack_top+0x873f>
    53b0:	00c5f333          	and	t1,a1,a2
    53b4:	01045f93          	srli	t6,s0,0x10
    53b8:	00c77733          	and	a4,a4,a2
    53bc:	00c47433          	and	s0,s0,a2
    53c0:	01031313          	slli	t1,t1,0x10
    53c4:	028782b3          	mul	t0,a5,s0
    53c8:	00e30333          	add	t1,t1,a4
    53cc:	0105d593          	srli	a1,a1,0x10
    53d0:	02868733          	mul	a4,a3,s0
    53d4:	0102d613          	srli	a2,t0,0x10
    53d8:	02ff87b3          	mul	a5,t6,a5
    53dc:	00e787b3          	add	a5,a5,a4
    53e0:	00f60633          	add	a2,a2,a5
    53e4:	03f687b3          	mul	a5,a3,t6
    53e8:	00e67463          	bgeu	a2,a4,53f0 <__muldf3+0x2cc>
    53ec:	007787b3          	add	a5,a5,t2
    53f0:	00010937          	lui	s2,0x10
    53f4:	fff90993          	addi	s3,s2,-1 # ffff <__freertos_irq_stack_top+0x873f>
    53f8:	01367733          	and	a4,a2,s3
    53fc:	0104d393          	srli	t2,s1,0x10
    5400:	0134f6b3          	and	a3,s1,s3
    5404:	0132f2b3          	and	t0,t0,s3
    5408:	01071713          	slli	a4,a4,0x10
    540c:	02de84b3          	mul	s1,t4,a3
    5410:	00570733          	add	a4,a4,t0
    5414:	01065613          	srli	a2,a2,0x10
    5418:	00f60633          	add	a2,a2,a5
    541c:	00e585b3          	add	a1,a1,a4
    5420:	02de02b3          	mul	t0,t3,a3
    5424:	0104d793          	srli	a5,s1,0x10
    5428:	03d38eb3          	mul	t4,t2,t4
    542c:	01d282b3          	add	t0,t0,t4
    5430:	005787b3          	add	a5,a5,t0
    5434:	027e0e33          	mul	t3,t3,t2
    5438:	01d7f463          	bgeu	a5,t4,5440 <__muldf3+0x31c>
    543c:	012e0e33          	add	t3,t3,s2
    5440:	000109b7          	lui	s3,0x10
    5444:	fff98e93          	addi	t4,s3,-1 # ffff <__freertos_irq_stack_top+0x873f>
    5448:	01d7f2b3          	and	t0,a5,t4
    544c:	0107d793          	srli	a5,a5,0x10
    5450:	01c787b3          	add	a5,a5,t3
    5454:	01d4feb3          	and	t4,s1,t4
    5458:	01029293          	slli	t0,t0,0x10
    545c:	02d40933          	mul	s2,s0,a3
    5460:	01d282b3          	add	t0,t0,t4
    5464:	02838433          	mul	s0,t2,s0
    5468:	01095e13          	srli	t3,s2,0x10
    546c:	02df86b3          	mul	a3,t6,a3
    5470:	008686b3          	add	a3,a3,s0
    5474:	00de0e33          	add	t3,t3,a3
    5478:	027f8eb3          	mul	t4,t6,t2
    547c:	008e7463          	bgeu	t3,s0,5484 <__muldf3+0x360>
    5480:	013e8eb3          	add	t4,t4,s3
    5484:	00010fb7          	lui	t6,0x10
    5488:	ffff8f93          	addi	t6,t6,-1 # ffff <__freertos_irq_stack_top+0x873f>
    548c:	01fe76b3          	and	a3,t3,t6
    5490:	01069693          	slli	a3,a3,0x10
    5494:	01f97933          	and	s2,s2,t6
    5498:	01e585b3          	add	a1,a1,t5
    549c:	012686b3          	add	a3,a3,s2
    54a0:	00c68633          	add	a2,a3,a2
    54a4:	00e5b733          	sltu	a4,a1,a4
    54a8:	00e60733          	add	a4,a2,a4
    54ac:	00558f33          	add	t5,a1,t0
    54b0:	00f707b3          	add	a5,a4,a5
    54b4:	00bf35b3          	sltu	a1,t5,a1
    54b8:	00b785b3          	add	a1,a5,a1
    54bc:	00d636b3          	sltu	a3,a2,a3
    54c0:	00c73633          	sltu	a2,a4,a2
    54c4:	00c6e6b3          	or	a3,a3,a2
    54c8:	00e7b733          	sltu	a4,a5,a4
    54cc:	010e5e13          	srli	t3,t3,0x10
    54d0:	00f5b7b3          	sltu	a5,a1,a5
    54d4:	01c686b3          	add	a3,a3,t3
    54d8:	00f76733          	or	a4,a4,a5
    54dc:	009f1793          	slli	a5,t5,0x9
    54e0:	00d70733          	add	a4,a4,a3
    54e4:	0067e7b3          	or	a5,a5,t1
    54e8:	01d70733          	add	a4,a4,t4
    54ec:	00f037b3          	snez	a5,a5
    54f0:	017f5613          	srli	a2,t5,0x17
    54f4:	00971713          	slli	a4,a4,0x9
    54f8:	0175d693          	srli	a3,a1,0x17
    54fc:	00c7e7b3          	or	a5,a5,a2
    5500:	00959593          	slli	a1,a1,0x9
    5504:	00b7ea33          	or	s4,a5,a1
    5508:	00771793          	slli	a5,a4,0x7
    550c:	00d764b3          	or	s1,a4,a3
    5510:	0207d063          	bgez	a5,5530 <__muldf3+0x40c>
    5514:	001a5713          	srli	a4,s4,0x1
    5518:	001a7793          	andi	a5,s4,1
    551c:	01f49693          	slli	a3,s1,0x1f
    5520:	00f767b3          	or	a5,a4,a5
    5524:	00d7ea33          	or	s4,a5,a3
    5528:	0014d493          	srli	s1,s1,0x1
    552c:	00050893          	mv	a7,a0
    5530:	3ff88613          	addi	a2,a7,1023
    5534:	12c05663          	blez	a2,5660 <__muldf3+0x53c>
    5538:	007a7793          	andi	a5,s4,7
    553c:	02078063          	beqz	a5,555c <__muldf3+0x438>
    5540:	00fa7793          	andi	a5,s4,15
    5544:	00400713          	li	a4,4
    5548:	00e78a63          	beq	a5,a4,555c <__muldf3+0x438>
    554c:	004a0713          	addi	a4,s4,4
    5550:	014737b3          	sltu	a5,a4,s4
    5554:	00f484b3          	add	s1,s1,a5
    5558:	00070a13          	mv	s4,a4
    555c:	00749793          	slli	a5,s1,0x7
    5560:	0007da63          	bgez	a5,5574 <__muldf3+0x450>
    5564:	ff0007b7          	lui	a5,0xff000
    5568:	fff78793          	addi	a5,a5,-1 # feffffff <__freertos_irq_stack_top+0xfeff873f>
    556c:	00f4f4b3          	and	s1,s1,a5
    5570:	40088613          	addi	a2,a7,1024
    5574:	7fe00793          	li	a5,2046
    5578:	1cc7c463          	blt	a5,a2,5740 <__muldf3+0x61c>
    557c:	003a5793          	srli	a5,s4,0x3
    5580:	01d49713          	slli	a4,s1,0x1d
    5584:	00949693          	slli	a3,s1,0x9
    5588:	00f76733          	or	a4,a4,a5
    558c:	00c6d693          	srli	a3,a3,0xc
    5590:	7ff67793          	andi	a5,a2,2047
    5594:	d41ff06f          	j	52d4 <__muldf3+0x1b0>
    5598:	00a4ea33          	or	s4,s1,a0
    559c:	060a0863          	beqz	s4,560c <__muldf3+0x4e8>
    55a0:	12048e63          	beqz	s1,56dc <__muldf3+0x5b8>
    55a4:	00048513          	mv	a0,s1
    55a8:	5d1000ef          	jal	6378 <__clzsi2>
    55ac:	00050613          	mv	a2,a0
    55b0:	ff550693          	addi	a3,a0,-11
    55b4:	01d00713          	li	a4,29
    55b8:	ff860793          	addi	a5,a2,-8 # 7fff8 <__freertos_irq_stack_top+0x78738>
    55bc:	40d70733          	sub	a4,a4,a3
    55c0:	00e45733          	srl	a4,s0,a4
    55c4:	00f496b3          	sll	a3,s1,a5
    55c8:	00d764b3          	or	s1,a4,a3
    55cc:	00f41a33          	sll	s4,s0,a5
    55d0:	c0d00793          	li	a5,-1011
    55d4:	40c78c33          	sub	s8,a5,a2
    55d8:	00000b13          	li	s6,0
    55dc:	00000b93          	li	s7,0
    55e0:	bc1ff06f          	j	51a0 <__muldf3+0x7c>
    55e4:	00058813          	mv	a6,a1
    55e8:	7ff00793          	li	a5,2047
    55ec:	00000693          	li	a3,0
    55f0:	00000713          	li	a4,0
    55f4:	ce1ff06f          	j	52d4 <__muldf3+0x1b0>
    55f8:	00050a13          	mv	s4,a0
    55fc:	00c00b13          	li	s6,12
    5600:	7ff00c13          	li	s8,2047
    5604:	00300b93          	li	s7,3
    5608:	b99ff06f          	j	51a0 <__muldf3+0x7c>
    560c:	00000493          	li	s1,0
    5610:	00400b13          	li	s6,4
    5614:	00000c13          	li	s8,0
    5618:	00100b93          	li	s7,1
    561c:	b85ff06f          	j	51a0 <__muldf3+0x7c>
    5620:	001b6b13          	ori	s6,s6,1
    5624:	000c0893          	mv	a7,s8
    5628:	00000413          	li	s0,0
    562c:	00000f13          	li	t5,0
    5630:	00100313          	li	t1,1
    5634:	bb5ff06f          	j	51e8 <__muldf3+0xc4>
    5638:	002b6b13          	ori	s6,s6,2
    563c:	00000413          	li	s0,0
    5640:	00000f13          	li	t5,0
    5644:	00200313          	li	t1,2
    5648:	ba1ff06f          	j	51e8 <__muldf3+0xc4>
    564c:	00040493          	mv	s1,s0
    5650:	000f0a13          	mv	s4,t5
    5654:	00030b93          	mv	s7,t1
    5658:	00098593          	mv	a1,s3
    565c:	c51ff06f          	j	52ac <__muldf3+0x188>
    5660:	00100713          	li	a4,1
    5664:	10061063          	bnez	a2,5764 <__muldf3+0x640>
    5668:	41e88893          	addi	a7,a7,1054
    566c:	011a1633          	sll	a2,s4,a7
    5670:	00c03633          	snez	a2,a2
    5674:	011498b3          	sll	a7,s1,a7
    5678:	00ea57b3          	srl	a5,s4,a4
    567c:	01166633          	or	a2,a2,a7
    5680:	00f66633          	or	a2,a2,a5
    5684:	00767793          	andi	a5,a2,7
    5688:	00e4d5b3          	srl	a1,s1,a4
    568c:	02078063          	beqz	a5,56ac <__muldf3+0x588>
    5690:	00f67793          	andi	a5,a2,15
    5694:	00400713          	li	a4,4
    5698:	00e78a63          	beq	a5,a4,56ac <__muldf3+0x588>
    569c:	00460793          	addi	a5,a2,4
    56a0:	00c7b633          	sltu	a2,a5,a2
    56a4:	00c585b3          	add	a1,a1,a2
    56a8:	00078613          	mv	a2,a5
    56ac:	00859513          	slli	a0,a1,0x8
    56b0:	00100793          	li	a5,1
    56b4:	00000693          	li	a3,0
    56b8:	00000713          	li	a4,0
    56bc:	c0054ce3          	bltz	a0,52d4 <__muldf3+0x1b0>
    56c0:	10c0006f          	j	57cc <__muldf3+0x6a8>
    56c4:	00f00713          	li	a4,15
    56c8:	12eb1063          	bne	s6,a4,57e8 <__muldf3+0x6c4>
    56cc:	00000813          	li	a6,0
    56d0:	000806b7          	lui	a3,0x80
    56d4:	00000713          	li	a4,0
    56d8:	bfdff06f          	j	52d4 <__muldf3+0x1b0>
    56dc:	49d000ef          	jal	6378 <__clzsi2>
    56e0:	01550693          	addi	a3,a0,21
    56e4:	01c00793          	li	a5,28
    56e8:	02050613          	addi	a2,a0,32
    56ec:	ecd7d4e3          	bge	a5,a3,55b4 <__muldf3+0x490>
    56f0:	ff850513          	addi	a0,a0,-8
    56f4:	00000a13          	li	s4,0
    56f8:	00a414b3          	sll	s1,s0,a0
    56fc:	ed5ff06f          	j	55d0 <__muldf3+0x4ac>
    5700:	000a8513          	mv	a0,s5
    5704:	475000ef          	jal	6378 <__clzsi2>
    5708:	01550713          	addi	a4,a0,21
    570c:	01c00793          	li	a5,28
    5710:	02050893          	addi	a7,a0,32
    5714:	b6e7d0e3          	bge	a5,a4,5274 <__muldf3+0x150>
    5718:	ff850513          	addi	a0,a0,-8
    571c:	00000f13          	li	t5,0
    5720:	00aa9433          	sll	s0,s5,a0
    5724:	b6dff06f          	j	5290 <__muldf3+0x16c>
    5728:	00000813          	li	a6,0
    572c:	7ff00793          	li	a5,2047
    5730:	000806b7          	lui	a3,0x80
    5734:	ba1ff06f          	j	52d4 <__muldf3+0x1b0>
    5738:	00050893          	mv	a7,a0
    573c:	df5ff06f          	j	5530 <__muldf3+0x40c>
    5740:	7ff00793          	li	a5,2047
    5744:	00000693          	li	a3,0
    5748:	00000713          	li	a4,0
    574c:	b89ff06f          	j	52d4 <__muldf3+0x1b0>
    5750:	00000813          	li	a6,0
    5754:	7ff00793          	li	a5,2047
    5758:	000806b7          	lui	a3,0x80
    575c:	00000713          	li	a4,0
    5760:	b75ff06f          	j	52d4 <__muldf3+0x1b0>
    5764:	40c70733          	sub	a4,a4,a2
    5768:	03800793          	li	a5,56
    576c:	b4e7cee3          	blt	a5,a4,52c8 <__muldf3+0x1a4>
    5770:	01f00793          	li	a5,31
    5774:	eee7dae3          	bge	a5,a4,5668 <__muldf3+0x544>
    5778:	fe100793          	li	a5,-31
    577c:	40c787b3          	sub	a5,a5,a2
    5780:	02000693          	li	a3,32
    5784:	00f4d7b3          	srl	a5,s1,a5
    5788:	00d70863          	beq	a4,a3,5798 <__muldf3+0x674>
    578c:	43e88893          	addi	a7,a7,1086
    5790:	011498b3          	sll	a7,s1,a7
    5794:	011a6a33          	or	s4,s4,a7
    5798:	01403633          	snez	a2,s4
    579c:	00f66633          	or	a2,a2,a5
    57a0:	00767713          	andi	a4,a2,7
    57a4:	00000693          	li	a3,0
    57a8:	02070863          	beqz	a4,57d8 <__muldf3+0x6b4>
    57ac:	00f67793          	andi	a5,a2,15
    57b0:	00400713          	li	a4,4
    57b4:	00000593          	li	a1,0
    57b8:	00e78a63          	beq	a5,a4,57cc <__muldf3+0x6a8>
    57bc:	00460793          	addi	a5,a2,4
    57c0:	00c7b633          	sltu	a2,a5,a2
    57c4:	00c035b3          	snez	a1,a2
    57c8:	00078613          	mv	a2,a5
    57cc:	00959693          	slli	a3,a1,0x9
    57d0:	01d59713          	slli	a4,a1,0x1d
    57d4:	00c6d693          	srli	a3,a3,0xc
    57d8:	00365613          	srli	a2,a2,0x3
    57dc:	00e66733          	or	a4,a2,a4
    57e0:	00000793          	li	a5,0
    57e4:	af1ff06f          	j	52d4 <__muldf3+0x1b0>
    57e8:	00040493          	mv	s1,s0
    57ec:	000a8a13          	mv	s4,s5
    57f0:	00300b93          	li	s7,3
    57f4:	00098593          	mv	a1,s3
    57f8:	ab5ff06f          	j	52ac <__muldf3+0x188>

000057fc <__subdf3>:
    57fc:	001007b7          	lui	a5,0x100
    5800:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf873f>
    5804:	fe010113          	addi	sp,sp,-32
    5808:	00b7f8b3          	and	a7,a5,a1
    580c:	00d7f833          	and	a6,a5,a3
    5810:	0146d793          	srli	a5,a3,0x14
    5814:	00389893          	slli	a7,a7,0x3
    5818:	00812c23          	sw	s0,24(sp)
    581c:	01312623          	sw	s3,12(sp)
    5820:	01f5d413          	srli	s0,a1,0x1f
    5824:	0145d993          	srli	s3,a1,0x14
    5828:	01d55713          	srli	a4,a0,0x1d
    582c:	00381813          	slli	a6,a6,0x3
    5830:	01d65593          	srli	a1,a2,0x1d
    5834:	00112e23          	sw	ra,28(sp)
    5838:	00912a23          	sw	s1,20(sp)
    583c:	01212823          	sw	s2,16(sp)
    5840:	7ff7ff13          	andi	t5,a5,2047
    5844:	7ff00313          	li	t1,2047
    5848:	01176733          	or	a4,a4,a7
    584c:	7ff9f993          	andi	s3,s3,2047
    5850:	00040e13          	mv	t3,s0
    5854:	00351893          	slli	a7,a0,0x3
    5858:	01f6d693          	srli	a3,a3,0x1f
    585c:	0105e5b3          	or	a1,a1,a6
    5860:	00361e93          	slli	t4,a2,0x3
    5864:	206f0c63          	beq	t5,t1,5a7c <__subdf3+0x280>
    5868:	0016c693          	xori	a3,a3,1
    586c:	41e987b3          	sub	a5,s3,t5
    5870:	16d40263          	beq	s0,a3,59d4 <__subdf3+0x1d8>
    5874:	00f05ae3          	blez	a5,6088 <__subdf3+0x88c>
    5878:	240f0a63          	beqz	t5,5acc <__subdf3+0x2d0>
    587c:	3c698463          	beq	s3,t1,5c44 <__subdf3+0x448>
    5880:	03800693          	li	a3,56
    5884:	00100513          	li	a0,1
    5888:	02f6ce63          	blt	a3,a5,58c4 <__subdf3+0xc8>
    588c:	008006b7          	lui	a3,0x800
    5890:	00d5e5b3          	or	a1,a1,a3
    5894:	01f00693          	li	a3,31
    5898:	4ef6c463          	blt	a3,a5,5d80 <__subdf3+0x584>
    589c:	02000693          	li	a3,32
    58a0:	40f686b3          	sub	a3,a3,a5
    58a4:	00d59533          	sll	a0,a1,a3
    58a8:	00fed633          	srl	a2,t4,a5
    58ac:	00de96b3          	sll	a3,t4,a3
    58b0:	00c56533          	or	a0,a0,a2
    58b4:	00d036b3          	snez	a3,a3
    58b8:	00f5d7b3          	srl	a5,a1,a5
    58bc:	00d56533          	or	a0,a0,a3
    58c0:	40f70733          	sub	a4,a4,a5
    58c4:	40a88533          	sub	a0,a7,a0
    58c8:	00a8b633          	sltu	a2,a7,a0
    58cc:	00050493          	mv	s1,a0
    58d0:	40c70933          	sub	s2,a4,a2
    58d4:	00891793          	slli	a5,s2,0x8
    58d8:	3407d863          	bgez	a5,5c28 <__subdf3+0x42c>
    58dc:	008007b7          	lui	a5,0x800
    58e0:	fff78793          	addi	a5,a5,-1 # 7fffff <__freertos_irq_stack_top+0x7f873f>
    58e4:	00f97933          	and	s2,s2,a5
    58e8:	2e090663          	beqz	s2,5bd4 <__subdf3+0x3d8>
    58ec:	00090513          	mv	a0,s2
    58f0:	289000ef          	jal	6378 <__clzsi2>
    58f4:	ff850793          	addi	a5,a0,-8
    58f8:	02000693          	li	a3,32
    58fc:	40f68733          	sub	a4,a3,a5
    5900:	00e4d733          	srl	a4,s1,a4
    5904:	00f91933          	sll	s2,s2,a5
    5908:	01276733          	or	a4,a4,s2
    590c:	00f494b3          	sll	s1,s1,a5
    5910:	3f37c463          	blt	a5,s3,5cf8 <__subdf3+0x4fc>
    5914:	413787b3          	sub	a5,a5,s3
    5918:	00178793          	addi	a5,a5,1
    591c:	40f686b3          	sub	a3,a3,a5
    5920:	00d49633          	sll	a2,s1,a3
    5924:	00f4d933          	srl	s2,s1,a5
    5928:	00c03633          	snez	a2,a2
    592c:	00c96633          	or	a2,s2,a2
    5930:	00d716b3          	sll	a3,a4,a3
    5934:	00c6e4b3          	or	s1,a3,a2
    5938:	00f75933          	srl	s2,a4,a5
    593c:	00000993          	li	s3,0
    5940:	0074f793          	andi	a5,s1,7
    5944:	02078063          	beqz	a5,5964 <__subdf3+0x168>
    5948:	00f4f793          	andi	a5,s1,15
    594c:	00400713          	li	a4,4
    5950:	00e78a63          	beq	a5,a4,5964 <__subdf3+0x168>
    5954:	00448793          	addi	a5,s1,4
    5958:	0097b533          	sltu	a0,a5,s1
    595c:	00a90933          	add	s2,s2,a0
    5960:	00078493          	mv	s1,a5
    5964:	00891793          	slli	a5,s2,0x8
    5968:	6c07d063          	bgez	a5,6028 <__subdf3+0x82c>
    596c:	00198793          	addi	a5,s3,1
    5970:	7ff00713          	li	a4,2047
    5974:	24e78663          	beq	a5,a4,5bc0 <__subdf3+0x3c4>
    5978:	ff800737          	lui	a4,0xff800
    597c:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f873f>
    5980:	00e97733          	and	a4,s2,a4
    5984:	7ff7f793          	andi	a5,a5,2047
    5988:	01d71813          	slli	a6,a4,0x1d
    598c:	0034d513          	srli	a0,s1,0x3
    5990:	00971713          	slli	a4,a4,0x9
    5994:	00a86833          	or	a6,a6,a0
    5998:	00c75713          	srli	a4,a4,0xc
    599c:	00147e13          	andi	t3,s0,1
    59a0:	01c12083          	lw	ra,28(sp)
    59a4:	01812403          	lw	s0,24(sp)
    59a8:	01479793          	slli	a5,a5,0x14
    59ac:	00e7e7b3          	or	a5,a5,a4
    59b0:	01fe1713          	slli	a4,t3,0x1f
    59b4:	00e7e7b3          	or	a5,a5,a4
    59b8:	01412483          	lw	s1,20(sp)
    59bc:	01012903          	lw	s2,16(sp)
    59c0:	00c12983          	lw	s3,12(sp)
    59c4:	00080513          	mv	a0,a6
    59c8:	00078593          	mv	a1,a5
    59cc:	02010113          	addi	sp,sp,32
    59d0:	00008067          	ret
    59d4:	70f05263          	blez	a5,60d8 <__subdf3+0x8dc>
    59d8:	1c0f1663          	bnez	t5,5ba4 <__subdf3+0x3a8>
    59dc:	01d5e6b3          	or	a3,a1,t4
    59e0:	26068e63          	beqz	a3,5c5c <__subdf3+0x460>
    59e4:	fff78693          	addi	a3,a5,-1
    59e8:	46068863          	beqz	a3,5e58 <__subdf3+0x65c>
    59ec:	24678c63          	beq	a5,t1,5c44 <__subdf3+0x448>
    59f0:	03800793          	li	a5,56
    59f4:	00100913          	li	s2,1
    59f8:	02d7cc63          	blt	a5,a3,5a30 <__subdf3+0x234>
    59fc:	00068793          	mv	a5,a3
    5a00:	01f00693          	li	a3,31
    5a04:	48f6ca63          	blt	a3,a5,5e98 <__subdf3+0x69c>
    5a08:	02000693          	li	a3,32
    5a0c:	40f686b3          	sub	a3,a3,a5
    5a10:	00d59933          	sll	s2,a1,a3
    5a14:	00fed633          	srl	a2,t4,a5
    5a18:	00de96b3          	sll	a3,t4,a3
    5a1c:	00c96933          	or	s2,s2,a2
    5a20:	00d036b3          	snez	a3,a3
    5a24:	00f5d7b3          	srl	a5,a1,a5
    5a28:	00d96933          	or	s2,s2,a3
    5a2c:	00f70733          	add	a4,a4,a5
    5a30:	01190633          	add	a2,s2,a7
    5a34:	01263933          	sltu	s2,a2,s2
    5a38:	00060493          	mv	s1,a2
    5a3c:	00e90933          	add	s2,s2,a4
    5a40:	00891793          	slli	a5,s2,0x8
    5a44:	1e07d263          	bgez	a5,5c28 <__subdf3+0x42c>
    5a48:	00198993          	addi	s3,s3,1
    5a4c:	7ff00793          	li	a5,2047
    5a50:	16f98863          	beq	s3,a5,5bc0 <__subdf3+0x3c4>
    5a54:	ff8007b7          	lui	a5,0xff800
    5a58:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f873f>
    5a5c:	0014f513          	andi	a0,s1,1
    5a60:	00f977b3          	and	a5,s2,a5
    5a64:	0014d713          	srli	a4,s1,0x1
    5a68:	00a76733          	or	a4,a4,a0
    5a6c:	01f79513          	slli	a0,a5,0x1f
    5a70:	00e564b3          	or	s1,a0,a4
    5a74:	0017d913          	srli	s2,a5,0x1
    5a78:	ec9ff06f          	j	5940 <__subdf3+0x144>
    5a7c:	01d5e833          	or	a6,a1,t4
    5a80:	80198313          	addi	t1,s3,-2047
    5a84:	06080863          	beqz	a6,5af4 <__subdf3+0x2f8>
    5a88:	06d40a63          	beq	s0,a3,5afc <__subdf3+0x300>
    5a8c:	0e030463          	beqz	t1,5b74 <__subdf3+0x378>
    5a90:	26098e63          	beqz	s3,5d0c <__subdf3+0x510>
    5a94:	00361513          	slli	a0,a2,0x3
    5a98:	00355513          	srli	a0,a0,0x3
    5a9c:	00068413          	mv	s0,a3
    5aa0:	00058713          	mv	a4,a1
    5aa4:	01d71813          	slli	a6,a4,0x1d
    5aa8:	00a86833          	or	a6,a6,a0
    5aac:	00375713          	srli	a4,a4,0x3
    5ab0:	01076733          	or	a4,a4,a6
    5ab4:	10070663          	beqz	a4,5bc0 <__subdf3+0x3c4>
    5ab8:	00000e13          	li	t3,0
    5abc:	7ff00793          	li	a5,2047
    5ac0:	00080737          	lui	a4,0x80
    5ac4:	00000813          	li	a6,0
    5ac8:	ed9ff06f          	j	59a0 <__subdf3+0x1a4>
    5acc:	01d5e6b3          	or	a3,a1,t4
    5ad0:	18068663          	beqz	a3,5c5c <__subdf3+0x460>
    5ad4:	fff78693          	addi	a3,a5,-1
    5ad8:	3a068263          	beqz	a3,5e7c <__subdf3+0x680>
    5adc:	16678463          	beq	a5,t1,5c44 <__subdf3+0x448>
    5ae0:	03800793          	li	a5,56
    5ae4:	00100513          	li	a0,1
    5ae8:	dcd7cee3          	blt	a5,a3,58c4 <__subdf3+0xc8>
    5aec:	00068793          	mv	a5,a3
    5af0:	da5ff06f          	j	5894 <__subdf3+0x98>
    5af4:	0016c693          	xori	a3,a3,1
    5af8:	f8d41ae3          	bne	s0,a3,5a8c <__subdf3+0x290>
    5afc:	18030863          	beqz	t1,5c8c <__subdf3+0x490>
    5b00:	2c099063          	bnez	s3,5dc0 <__subdf3+0x5c4>
    5b04:	7ff00793          	li	a5,2047
    5b08:	011766b3          	or	a3,a4,a7
    5b0c:	48068863          	beqz	a3,5f9c <__subdf3+0x7a0>
    5b10:	fff78693          	addi	a3,a5,-1
    5b14:	34068263          	beqz	a3,5e58 <__subdf3+0x65c>
    5b18:	7ff00513          	li	a0,2047
    5b1c:	2aa78263          	beq	a5,a0,5dc0 <__subdf3+0x5c4>
    5b20:	03800793          	li	a5,56
    5b24:	00100913          	li	s2,1
    5b28:	02d7ca63          	blt	a5,a3,5b5c <__subdf3+0x360>
    5b2c:	01f00793          	li	a5,31
    5b30:	4cd7c663          	blt	a5,a3,5ffc <__subdf3+0x800>
    5b34:	02000793          	li	a5,32
    5b38:	40d787b3          	sub	a5,a5,a3
    5b3c:	00f71933          	sll	s2,a4,a5
    5b40:	00d8d633          	srl	a2,a7,a3
    5b44:	00f897b3          	sll	a5,a7,a5
    5b48:	00c96933          	or	s2,s2,a2
    5b4c:	00f037b3          	snez	a5,a5
    5b50:	00d756b3          	srl	a3,a4,a3
    5b54:	00f96933          	or	s2,s2,a5
    5b58:	00d585b3          	add	a1,a1,a3
    5b5c:	01d90733          	add	a4,s2,t4
    5b60:	01273933          	sltu	s2,a4,s2
    5b64:	00070493          	mv	s1,a4
    5b68:	00b90933          	add	s2,s2,a1
    5b6c:	000f0993          	mv	s3,t5
    5b70:	ed1ff06f          	j	5a40 <__subdf3+0x244>
    5b74:	00198793          	addi	a5,s3,1
    5b78:	7fe7f793          	andi	a5,a5,2046
    5b7c:	14079463          	bnez	a5,5cc4 <__subdf3+0x4c8>
    5b80:	01d5e833          	or	a6,a1,t4
    5b84:	011767b3          	or	a5,a4,a7
    5b88:	2a099463          	bnez	s3,5e30 <__subdf3+0x634>
    5b8c:	38078e63          	beqz	a5,5f28 <__subdf3+0x72c>
    5b90:	3c081063          	bnez	a6,5f50 <__subdf3+0x754>
    5b94:	00351513          	slli	a0,a0,0x3
    5b98:	00355913          	srli	s2,a0,0x3
    5b9c:	00000793          	li	a5,0
    5ba0:	1140006f          	j	5cb4 <__subdf3+0x4b8>
    5ba4:	0a698063          	beq	s3,t1,5c44 <__subdf3+0x448>
    5ba8:	03800693          	li	a3,56
    5bac:	00100913          	li	s2,1
    5bb0:	e8f6c0e3          	blt	a3,a5,5a30 <__subdf3+0x234>
    5bb4:	008006b7          	lui	a3,0x800
    5bb8:	00d5e5b3          	or	a1,a1,a3
    5bbc:	e45ff06f          	j	5a00 <__subdf3+0x204>
    5bc0:	00147e13          	andi	t3,s0,1
    5bc4:	7ff00793          	li	a5,2047
    5bc8:	00000713          	li	a4,0
    5bcc:	00000813          	li	a6,0
    5bd0:	dd1ff06f          	j	59a0 <__subdf3+0x1a4>
    5bd4:	00048513          	mv	a0,s1
    5bd8:	7a0000ef          	jal	6378 <__clzsi2>
    5bdc:	01850793          	addi	a5,a0,24
    5be0:	01f00693          	li	a3,31
    5be4:	d0f6dae3          	bge	a3,a5,58f8 <__subdf3+0xfc>
    5be8:	ff850713          	addi	a4,a0,-8
    5bec:	00e49733          	sll	a4,s1,a4
    5bf0:	1b37ce63          	blt	a5,s3,5dac <__subdf3+0x5b0>
    5bf4:	413789b3          	sub	s3,a5,s3
    5bf8:	00198793          	addi	a5,s3,1
    5bfc:	42f6de63          	bge	a3,a5,6038 <__subdf3+0x83c>
    5c00:	fe198993          	addi	s3,s3,-31
    5c04:	02000693          	li	a3,32
    5c08:	013754b3          	srl	s1,a4,s3
    5c0c:	00d78c63          	beq	a5,a3,5c24 <__subdf3+0x428>
    5c10:	04000693          	li	a3,64
    5c14:	40f687b3          	sub	a5,a3,a5
    5c18:	00f71733          	sll	a4,a4,a5
    5c1c:	00e03733          	snez	a4,a4
    5c20:	00e4e4b3          	or	s1,s1,a4
    5c24:	00000993          	li	s3,0
    5c28:	0074f793          	andi	a5,s1,7
    5c2c:	d0079ee3          	bnez	a5,5948 <__subdf3+0x14c>
    5c30:	00098793          	mv	a5,s3
    5c34:	0034d513          	srli	a0,s1,0x3
    5c38:	00090713          	mv	a4,s2
    5c3c:	0280006f          	j	5c64 <__subdf3+0x468>
    5c40:	e6081ce3          	bnez	a6,5ab8 <__subdf3+0x2bc>
    5c44:	00351513          	slli	a0,a0,0x3
    5c48:	01d71813          	slli	a6,a4,0x1d
    5c4c:	00355513          	srli	a0,a0,0x3
    5c50:	00a86833          	or	a6,a6,a0
    5c54:	00375713          	srli	a4,a4,0x3
    5c58:	e59ff06f          	j	5ab0 <__subdf3+0x2b4>
    5c5c:	00351513          	slli	a0,a0,0x3
    5c60:	00355513          	srli	a0,a0,0x3
    5c64:	01d71813          	slli	a6,a4,0x1d
    5c68:	7ff00693          	li	a3,2047
    5c6c:	00a86833          	or	a6,a6,a0
    5c70:	00375713          	srli	a4,a4,0x3
    5c74:	e2d78ee3          	beq	a5,a3,5ab0 <__subdf3+0x2b4>
    5c78:	00c71713          	slli	a4,a4,0xc
    5c7c:	00c75713          	srli	a4,a4,0xc
    5c80:	7ff7f793          	andi	a5,a5,2047
    5c84:	00147e13          	andi	t3,s0,1
    5c88:	d19ff06f          	j	59a0 <__subdf3+0x1a4>
    5c8c:	00198693          	addi	a3,s3,1
    5c90:	7fe6f793          	andi	a5,a3,2046
    5c94:	12079e63          	bnez	a5,5dd0 <__subdf3+0x5d4>
    5c98:	011767b3          	or	a5,a4,a7
    5c9c:	24099a63          	bnez	s3,5ef0 <__subdf3+0x6f4>
    5ca0:	30078663          	beqz	a5,5fac <__subdf3+0x7b0>
    5ca4:	01d5e7b3          	or	a5,a1,t4
    5ca8:	30079a63          	bnez	a5,5fbc <__subdf3+0x7c0>
    5cac:	00351513          	slli	a0,a0,0x3
    5cb0:	00355913          	srli	s2,a0,0x3
    5cb4:	01d71813          	slli	a6,a4,0x1d
    5cb8:	01286833          	or	a6,a6,s2
    5cbc:	00375713          	srli	a4,a4,0x3
    5cc0:	fb9ff06f          	j	5c78 <__subdf3+0x47c>
    5cc4:	41d88833          	sub	a6,a7,t4
    5cc8:	0108b7b3          	sltu	a5,a7,a6
    5ccc:	40b70933          	sub	s2,a4,a1
    5cd0:	40f90933          	sub	s2,s2,a5
    5cd4:	00891793          	slli	a5,s2,0x8
    5cd8:	00080493          	mv	s1,a6
    5cdc:	1207c263          	bltz	a5,5e00 <__subdf3+0x604>
    5ce0:	01286833          	or	a6,a6,s2
    5ce4:	c00812e3          	bnez	a6,58e8 <__subdf3+0xec>
    5ce8:	00000e13          	li	t3,0
    5cec:	00000793          	li	a5,0
    5cf0:	00000713          	li	a4,0
    5cf4:	cadff06f          	j	59a0 <__subdf3+0x1a4>
    5cf8:	ff800937          	lui	s2,0xff800
    5cfc:	fff90913          	addi	s2,s2,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f873f>
    5d00:	40f989b3          	sub	s3,s3,a5
    5d04:	01277933          	and	s2,a4,s2
    5d08:	c39ff06f          	j	5940 <__subdf3+0x144>
    5d0c:	7ff00793          	li	a5,2047
    5d10:	01176533          	or	a0,a4,a7
    5d14:	10050463          	beqz	a0,5e1c <__subdf3+0x620>
    5d18:	fff78813          	addi	a6,a5,-1
    5d1c:	1e080263          	beqz	a6,5f00 <__subdf3+0x704>
    5d20:	7ff00513          	li	a0,2047
    5d24:	d6a788e3          	beq	a5,a0,5a94 <__subdf3+0x298>
    5d28:	03800793          	li	a5,56
    5d2c:	00068413          	mv	s0,a3
    5d30:	00100513          	li	a0,1
    5d34:	0307ca63          	blt	a5,a6,5d68 <__subdf3+0x56c>
    5d38:	01f00793          	li	a5,31
    5d3c:	1907c463          	blt	a5,a6,5ec4 <__subdf3+0x6c8>
    5d40:	02000793          	li	a5,32
    5d44:	410787b3          	sub	a5,a5,a6
    5d48:	00f71533          	sll	a0,a4,a5
    5d4c:	0108d6b3          	srl	a3,a7,a6
    5d50:	00f897b3          	sll	a5,a7,a5
    5d54:	00d56533          	or	a0,a0,a3
    5d58:	00f037b3          	snez	a5,a5
    5d5c:	01075833          	srl	a6,a4,a6
    5d60:	00f56533          	or	a0,a0,a5
    5d64:	410585b3          	sub	a1,a1,a6
    5d68:	40ae8533          	sub	a0,t4,a0
    5d6c:	00aeb733          	sltu	a4,t4,a0
    5d70:	00050493          	mv	s1,a0
    5d74:	40e58933          	sub	s2,a1,a4
    5d78:	000f0993          	mv	s3,t5
    5d7c:	b59ff06f          	j	58d4 <__subdf3+0xd8>
    5d80:	fe078693          	addi	a3,a5,-32
    5d84:	02000613          	li	a2,32
    5d88:	00d5d6b3          	srl	a3,a1,a3
    5d8c:	00c78a63          	beq	a5,a2,5da0 <__subdf3+0x5a4>
    5d90:	04000613          	li	a2,64
    5d94:	40f607b3          	sub	a5,a2,a5
    5d98:	00f597b3          	sll	a5,a1,a5
    5d9c:	00feeeb3          	or	t4,t4,a5
    5da0:	01d03533          	snez	a0,t4
    5da4:	00d56533          	or	a0,a0,a3
    5da8:	b1dff06f          	j	58c4 <__subdf3+0xc8>
    5dac:	ff8006b7          	lui	a3,0xff800
    5db0:	fff68693          	addi	a3,a3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f873f>
    5db4:	40f987b3          	sub	a5,s3,a5
    5db8:	00d77733          	and	a4,a4,a3
    5dbc:	ef9ff06f          	j	5cb4 <__subdf3+0x4b8>
    5dc0:	00361513          	slli	a0,a2,0x3
    5dc4:	00355513          	srli	a0,a0,0x3
    5dc8:	00058713          	mv	a4,a1
    5dcc:	cd9ff06f          	j	5aa4 <__subdf3+0x2a8>
    5dd0:	7ff00793          	li	a5,2047
    5dd4:	def686e3          	beq	a3,a5,5bc0 <__subdf3+0x3c4>
    5dd8:	01d88eb3          	add	t4,a7,t4
    5ddc:	011eb633          	sltu	a2,t4,a7
    5de0:	00b707b3          	add	a5,a4,a1
    5de4:	00c787b3          	add	a5,a5,a2
    5de8:	01f79513          	slli	a0,a5,0x1f
    5dec:	001ede93          	srli	t4,t4,0x1
    5df0:	01d564b3          	or	s1,a0,t4
    5df4:	0017d913          	srli	s2,a5,0x1
    5df8:	00068993          	mv	s3,a3
    5dfc:	b45ff06f          	j	5940 <__subdf3+0x144>
    5e00:	411e8633          	sub	a2,t4,a7
    5e04:	40e587b3          	sub	a5,a1,a4
    5e08:	00ceb733          	sltu	a4,t4,a2
    5e0c:	00060493          	mv	s1,a2
    5e10:	40e78933          	sub	s2,a5,a4
    5e14:	00068413          	mv	s0,a3
    5e18:	ad1ff06f          	j	58e8 <__subdf3+0xec>
    5e1c:	00361613          	slli	a2,a2,0x3
    5e20:	00365513          	srli	a0,a2,0x3
    5e24:	00068413          	mv	s0,a3
    5e28:	00058713          	mv	a4,a1
    5e2c:	e39ff06f          	j	5c64 <__subdf3+0x468>
    5e30:	e00798e3          	bnez	a5,5c40 <__subdf3+0x444>
    5e34:	22080663          	beqz	a6,6060 <__subdf3+0x864>
    5e38:	0035d713          	srli	a4,a1,0x3
    5e3c:	00361613          	slli	a2,a2,0x3
    5e40:	01d59593          	slli	a1,a1,0x1d
    5e44:	00b76733          	or	a4,a4,a1
    5e48:	00365613          	srli	a2,a2,0x3
    5e4c:	00c76733          	or	a4,a4,a2
    5e50:	00068413          	mv	s0,a3
    5e54:	c61ff06f          	j	5ab4 <__subdf3+0x2b8>
    5e58:	01d88eb3          	add	t4,a7,t4
    5e5c:	00b705b3          	add	a1,a4,a1
    5e60:	011eb633          	sltu	a2,t4,a7
    5e64:	00c58933          	add	s2,a1,a2
    5e68:	00891793          	slli	a5,s2,0x8
    5e6c:	000e8493          	mv	s1,t4
    5e70:	0a07d863          	bgez	a5,5f20 <__subdf3+0x724>
    5e74:	00200993          	li	s3,2
    5e78:	bddff06f          	j	5a54 <__subdf3+0x258>
    5e7c:	41d88eb3          	sub	t4,a7,t4
    5e80:	40b705b3          	sub	a1,a4,a1
    5e84:	01d8b633          	sltu	a2,a7,t4
    5e88:	000e8493          	mv	s1,t4
    5e8c:	40c58933          	sub	s2,a1,a2
    5e90:	00100993          	li	s3,1
    5e94:	a41ff06f          	j	58d4 <__subdf3+0xd8>
    5e98:	fe078693          	addi	a3,a5,-32
    5e9c:	02000613          	li	a2,32
    5ea0:	00d5d6b3          	srl	a3,a1,a3
    5ea4:	00c78a63          	beq	a5,a2,5eb8 <__subdf3+0x6bc>
    5ea8:	04000613          	li	a2,64
    5eac:	40f607b3          	sub	a5,a2,a5
    5eb0:	00f597b3          	sll	a5,a1,a5
    5eb4:	00feeeb3          	or	t4,t4,a5
    5eb8:	01d03933          	snez	s2,t4
    5ebc:	00d96933          	or	s2,s2,a3
    5ec0:	b71ff06f          	j	5a30 <__subdf3+0x234>
    5ec4:	fe080793          	addi	a5,a6,-32
    5ec8:	02000693          	li	a3,32
    5ecc:	00f757b3          	srl	a5,a4,a5
    5ed0:	00d80a63          	beq	a6,a3,5ee4 <__subdf3+0x6e8>
    5ed4:	04000693          	li	a3,64
    5ed8:	410686b3          	sub	a3,a3,a6
    5edc:	00d71733          	sll	a4,a4,a3
    5ee0:	00e8e8b3          	or	a7,a7,a4
    5ee4:	01103533          	snez	a0,a7
    5ee8:	00f56533          	or	a0,a0,a5
    5eec:	e7dff06f          	j	5d68 <__subdf3+0x56c>
    5ef0:	ec0788e3          	beqz	a5,5dc0 <__subdf3+0x5c4>
    5ef4:	01d5eeb3          	or	t4,a1,t4
    5ef8:	bc0e90e3          	bnez	t4,5ab8 <__subdf3+0x2bc>
    5efc:	d49ff06f          	j	5c44 <__subdf3+0x448>
    5f00:	411e8633          	sub	a2,t4,a7
    5f04:	40e585b3          	sub	a1,a1,a4
    5f08:	00ceb733          	sltu	a4,t4,a2
    5f0c:	00060493          	mv	s1,a2
    5f10:	40e58933          	sub	s2,a1,a4
    5f14:	00068413          	mv	s0,a3
    5f18:	00100993          	li	s3,1
    5f1c:	9b9ff06f          	j	58d4 <__subdf3+0xd8>
    5f20:	00100793          	li	a5,1
    5f24:	d11ff06f          	j	5c34 <__subdf3+0x438>
    5f28:	dc0800e3          	beqz	a6,5ce8 <__subdf3+0x4ec>
    5f2c:	00361613          	slli	a2,a2,0x3
    5f30:	00365793          	srli	a5,a2,0x3
    5f34:	01d59813          	slli	a6,a1,0x1d
    5f38:	00959713          	slli	a4,a1,0x9
    5f3c:	00f86833          	or	a6,a6,a5
    5f40:	00c75713          	srli	a4,a4,0xc
    5f44:	00068e13          	mv	t3,a3
    5f48:	00000793          	li	a5,0
    5f4c:	a55ff06f          	j	59a0 <__subdf3+0x1a4>
    5f50:	41d88933          	sub	s2,a7,t4
    5f54:	0128b7b3          	sltu	a5,a7,s2
    5f58:	40b70633          	sub	a2,a4,a1
    5f5c:	40f60633          	sub	a2,a2,a5
    5f60:	00861793          	slli	a5,a2,0x8
    5f64:	0e07d263          	bgez	a5,6048 <__subdf3+0x84c>
    5f68:	411e8633          	sub	a2,t4,a7
    5f6c:	40e58733          	sub	a4,a1,a4
    5f70:	00cebeb3          	sltu	t4,t4,a2
    5f74:	41d70733          	sub	a4,a4,t4
    5f78:	00871793          	slli	a5,a4,0x8
    5f7c:	00060493          	mv	s1,a2
    5f80:	1207de63          	bgez	a5,60bc <__subdf3+0x8c0>
    5f84:	ff8007b7          	lui	a5,0xff800
    5f88:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f873f>
    5f8c:	00f77733          	and	a4,a4,a5
    5f90:	00068413          	mv	s0,a3
    5f94:	00100793          	li	a5,1
    5f98:	9f1ff06f          	j	5988 <__subdf3+0x18c>
    5f9c:	00361613          	slli	a2,a2,0x3
    5fa0:	00365513          	srli	a0,a2,0x3
    5fa4:	00058713          	mv	a4,a1
    5fa8:	cbdff06f          	j	5c64 <__subdf3+0x468>
    5fac:	00361613          	slli	a2,a2,0x3
    5fb0:	00365913          	srli	s2,a2,0x3
    5fb4:	00058713          	mv	a4,a1
    5fb8:	cfdff06f          	j	5cb4 <__subdf3+0x4b8>
    5fbc:	01d886b3          	add	a3,a7,t4
    5fc0:	00b707b3          	add	a5,a4,a1
    5fc4:	0116b633          	sltu	a2,a3,a7
    5fc8:	00c787b3          	add	a5,a5,a2
    5fcc:	00879713          	slli	a4,a5,0x8
    5fd0:	0036d813          	srli	a6,a3,0x3
    5fd4:	08075e63          	bgez	a4,6070 <__subdf3+0x874>
    5fd8:	ff800737          	lui	a4,0xff800
    5fdc:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f873f>
    5fe0:	00e7f7b3          	and	a5,a5,a4
    5fe4:	01d79713          	slli	a4,a5,0x1d
    5fe8:	00979793          	slli	a5,a5,0x9
    5fec:	01076833          	or	a6,a4,a6
    5ff0:	00c7d713          	srli	a4,a5,0xc
    5ff4:	00100793          	li	a5,1
    5ff8:	9a9ff06f          	j	59a0 <__subdf3+0x1a4>
    5ffc:	fe068793          	addi	a5,a3,-32
    6000:	02000613          	li	a2,32
    6004:	00f757b3          	srl	a5,a4,a5
    6008:	00c68a63          	beq	a3,a2,601c <__subdf3+0x820>
    600c:	04000613          	li	a2,64
    6010:	40d606b3          	sub	a3,a2,a3
    6014:	00d71733          	sll	a4,a4,a3
    6018:	00e8e8b3          	or	a7,a7,a4
    601c:	01103933          	snez	s2,a7
    6020:	00f96933          	or	s2,s2,a5
    6024:	b39ff06f          	j	5b5c <__subdf3+0x360>
    6028:	0034d513          	srli	a0,s1,0x3
    602c:	00098793          	mv	a5,s3
    6030:	00090713          	mv	a4,s2
    6034:	c31ff06f          	j	5c64 <__subdf3+0x468>
    6038:	02000693          	li	a3,32
    603c:	40f686b3          	sub	a3,a3,a5
    6040:	00000613          	li	a2,0
    6044:	8e9ff06f          	j	592c <__subdf3+0x130>
    6048:	00c96833          	or	a6,s2,a2
    604c:	c8080ee3          	beqz	a6,5ce8 <__subdf3+0x4ec>
    6050:	00395913          	srli	s2,s2,0x3
    6054:	00000793          	li	a5,0
    6058:	00060713          	mv	a4,a2
    605c:	c59ff06f          	j	5cb4 <__subdf3+0x4b8>
    6060:	00000e13          	li	t3,0
    6064:	7ff00793          	li	a5,2047
    6068:	00080737          	lui	a4,0x80
    606c:	935ff06f          	j	59a0 <__subdf3+0x1a4>
    6070:	01d79713          	slli	a4,a5,0x1d
    6074:	00979793          	slli	a5,a5,0x9
    6078:	01076833          	or	a6,a4,a6
    607c:	00c7d713          	srli	a4,a5,0xc
    6080:	00000793          	li	a5,0
    6084:	91dff06f          	j	59a0 <__subdf3+0x1a4>
    6088:	ae0786e3          	beqz	a5,5b74 <__subdf3+0x378>
    608c:	413f0833          	sub	a6,t5,s3
    6090:	00080793          	mv	a5,a6
    6094:	c6098ee3          	beqz	s3,5d10 <__subdf3+0x514>
    6098:	03800793          	li	a5,56
    609c:	0107ca63          	blt	a5,a6,60b0 <__subdf3+0x8b4>
    60a0:	008007b7          	lui	a5,0x800
    60a4:	00f76733          	or	a4,a4,a5
    60a8:	00068413          	mv	s0,a3
    60ac:	c8dff06f          	j	5d38 <__subdf3+0x53c>
    60b0:	00068413          	mv	s0,a3
    60b4:	00100513          	li	a0,1
    60b8:	cb1ff06f          	j	5d68 <__subdf3+0x56c>
    60bc:	01d71813          	slli	a6,a4,0x1d
    60c0:	00365613          	srli	a2,a2,0x3
    60c4:	00c86833          	or	a6,a6,a2
    60c8:	00375713          	srli	a4,a4,0x3
    60cc:	00000793          	li	a5,0
    60d0:	00068413          	mv	s0,a3
    60d4:	ba5ff06f          	j	5c78 <__subdf3+0x47c>
    60d8:	ba078ae3          	beqz	a5,5c8c <__subdf3+0x490>
    60dc:	413f06b3          	sub	a3,t5,s3
    60e0:	00099663          	bnez	s3,60ec <__subdf3+0x8f0>
    60e4:	00068793          	mv	a5,a3
    60e8:	a21ff06f          	j	5b08 <__subdf3+0x30c>
    60ec:	03800793          	li	a5,56
    60f0:	00100913          	li	s2,1
    60f4:	a6d7c4e3          	blt	a5,a3,5b5c <__subdf3+0x360>
    60f8:	008007b7          	lui	a5,0x800
    60fc:	00f76733          	or	a4,a4,a5
    6100:	a2dff06f          	j	5b2c <__subdf3+0x330>

00006104 <__fixdfsi>:
    6104:	0145d793          	srli	a5,a1,0x14
    6108:	001006b7          	lui	a3,0x100
    610c:	fff68713          	addi	a4,a3,-1 # fffff <__freertos_irq_stack_top+0xf873f>
    6110:	7ff7f793          	andi	a5,a5,2047
    6114:	3fe00613          	li	a2,1022
    6118:	00b77733          	and	a4,a4,a1
    611c:	01f5d593          	srli	a1,a1,0x1f
    6120:	00f65e63          	bge	a2,a5,613c <__fixdfsi+0x38>
    6124:	41d00613          	li	a2,1053
    6128:	00f65e63          	bge	a2,a5,6144 <__fixdfsi+0x40>
    612c:	80000537          	lui	a0,0x80000
    6130:	fff50513          	addi	a0,a0,-1 # 7fffffff <__freertos_irq_stack_top+0x7fff873f>
    6134:	00a58533          	add	a0,a1,a0
    6138:	00008067          	ret
    613c:	00000513          	li	a0,0
    6140:	00008067          	ret
    6144:	43300613          	li	a2,1075
    6148:	40f60633          	sub	a2,a2,a5
    614c:	01f00813          	li	a6,31
    6150:	00d76733          	or	a4,a4,a3
    6154:	02c85063          	bge	a6,a2,6174 <__fixdfsi+0x70>
    6158:	41300693          	li	a3,1043
    615c:	40f687b3          	sub	a5,a3,a5
    6160:	00f75733          	srl	a4,a4,a5
    6164:	40e00533          	neg	a0,a4
    6168:	fc059ce3          	bnez	a1,6140 <__fixdfsi+0x3c>
    616c:	00070513          	mv	a0,a4
    6170:	00008067          	ret
    6174:	bed78793          	addi	a5,a5,-1043 # 7ffbed <__freertos_irq_stack_top+0x7f832d>
    6178:	00f71733          	sll	a4,a4,a5
    617c:	00c55533          	srl	a0,a0,a2
    6180:	00a76733          	or	a4,a4,a0
    6184:	fe1ff06f          	j	6164 <__fixdfsi+0x60>

00006188 <__fixunsdfsi>:
    6188:	0145d793          	srli	a5,a1,0x14
    618c:	00100637          	lui	a2,0x100
    6190:	fff60713          	addi	a4,a2,-1 # fffff <__freertos_irq_stack_top+0xf873f>
    6194:	7ff7f793          	andi	a5,a5,2047
    6198:	3fe00813          	li	a6,1022
    619c:	00050693          	mv	a3,a0
    61a0:	00b77733          	and	a4,a4,a1
    61a4:	00000513          	li	a0,0
    61a8:	01f5d593          	srli	a1,a1,0x1f
    61ac:	00f85463          	bge	a6,a5,61b4 <__fixunsdfsi+0x2c>
    61b0:	00058463          	beqz	a1,61b8 <__fixunsdfsi+0x30>
    61b4:	00008067          	ret
    61b8:	41e00593          	li	a1,1054
    61bc:	fff00513          	li	a0,-1
    61c0:	fef5cae3          	blt	a1,a5,61b4 <__fixunsdfsi+0x2c>
    61c4:	43300593          	li	a1,1075
    61c8:	40f585b3          	sub	a1,a1,a5
    61cc:	01f00513          	li	a0,31
    61d0:	00c76733          	or	a4,a4,a2
    61d4:	00b54c63          	blt	a0,a1,61ec <__fixunsdfsi+0x64>
    61d8:	bed78793          	addi	a5,a5,-1043
    61dc:	00f71733          	sll	a4,a4,a5
    61e0:	00b6d533          	srl	a0,a3,a1
    61e4:	00a76533          	or	a0,a4,a0
    61e8:	00008067          	ret
    61ec:	41300513          	li	a0,1043
    61f0:	40f50533          	sub	a0,a0,a5
    61f4:	00a75533          	srl	a0,a4,a0
    61f8:	00008067          	ret

000061fc <__floatsidf>:
    61fc:	ff010113          	addi	sp,sp,-16
    6200:	00112623          	sw	ra,12(sp)
    6204:	00812423          	sw	s0,8(sp)
    6208:	00912223          	sw	s1,4(sp)
    620c:	04050a63          	beqz	a0,6260 <__floatsidf+0x64>
    6210:	41f55713          	srai	a4,a0,0x1f
    6214:	00a744b3          	xor	s1,a4,a0
    6218:	40e484b3          	sub	s1,s1,a4
    621c:	00050793          	mv	a5,a0
    6220:	00048513          	mv	a0,s1
    6224:	01f7d413          	srli	s0,a5,0x1f
    6228:	150000ef          	jal	6378 <__clzsi2>
    622c:	41e00793          	li	a5,1054
    6230:	40a787b3          	sub	a5,a5,a0
    6234:	00a00713          	li	a4,10
    6238:	7ff7f793          	andi	a5,a5,2047
    623c:	06a74063          	blt	a4,a0,629c <__floatsidf+0xa0>
    6240:	00b00713          	li	a4,11
    6244:	40a70733          	sub	a4,a4,a0
    6248:	00e4d733          	srl	a4,s1,a4
    624c:	01550513          	addi	a0,a0,21
    6250:	00c71713          	slli	a4,a4,0xc
    6254:	00a494b3          	sll	s1,s1,a0
    6258:	00c75713          	srli	a4,a4,0xc
    625c:	0140006f          	j	6270 <__floatsidf+0x74>
    6260:	00000413          	li	s0,0
    6264:	00000793          	li	a5,0
    6268:	00000713          	li	a4,0
    626c:	00000493          	li	s1,0
    6270:	01479793          	slli	a5,a5,0x14
    6274:	01f41413          	slli	s0,s0,0x1f
    6278:	00e7e7b3          	or	a5,a5,a4
    627c:	00c12083          	lw	ra,12(sp)
    6280:	0087e7b3          	or	a5,a5,s0
    6284:	00812403          	lw	s0,8(sp)
    6288:	00048513          	mv	a0,s1
    628c:	00078593          	mv	a1,a5
    6290:	00412483          	lw	s1,4(sp)
    6294:	01010113          	addi	sp,sp,16
    6298:	00008067          	ret
    629c:	ff550513          	addi	a0,a0,-11
    62a0:	00a49733          	sll	a4,s1,a0
    62a4:	00c71713          	slli	a4,a4,0xc
    62a8:	00c75713          	srli	a4,a4,0xc
    62ac:	00000493          	li	s1,0
    62b0:	fc1ff06f          	j	6270 <__floatsidf+0x74>

000062b4 <__floatunsidf>:
    62b4:	ff010113          	addi	sp,sp,-16
    62b8:	00812423          	sw	s0,8(sp)
    62bc:	00112623          	sw	ra,12(sp)
    62c0:	00050413          	mv	s0,a0
    62c4:	04050c63          	beqz	a0,631c <__floatunsidf+0x68>
    62c8:	0b0000ef          	jal	6378 <__clzsi2>
    62cc:	41e00793          	li	a5,1054
    62d0:	40a787b3          	sub	a5,a5,a0
    62d4:	00a00713          	li	a4,10
    62d8:	7ff7f793          	andi	a5,a5,2047
    62dc:	06a74463          	blt	a4,a0,6344 <__floatunsidf+0x90>
    62e0:	00b00713          	li	a4,11
    62e4:	40a70733          	sub	a4,a4,a0
    62e8:	01550513          	addi	a0,a0,21
    62ec:	00e45733          	srl	a4,s0,a4
    62f0:	00a41433          	sll	s0,s0,a0
    62f4:	00c12083          	lw	ra,12(sp)
    62f8:	00040513          	mv	a0,s0
    62fc:	00c71713          	slli	a4,a4,0xc
    6300:	00812403          	lw	s0,8(sp)
    6304:	00c75713          	srli	a4,a4,0xc
    6308:	01479793          	slli	a5,a5,0x14
    630c:	00e7e7b3          	or	a5,a5,a4
    6310:	00078593          	mv	a1,a5
    6314:	01010113          	addi	sp,sp,16
    6318:	00008067          	ret
    631c:	00c12083          	lw	ra,12(sp)
    6320:	00040513          	mv	a0,s0
    6324:	00000793          	li	a5,0
    6328:	00812403          	lw	s0,8(sp)
    632c:	00000713          	li	a4,0
    6330:	01479793          	slli	a5,a5,0x14
    6334:	00e7e7b3          	or	a5,a5,a4
    6338:	00078593          	mv	a1,a5
    633c:	01010113          	addi	sp,sp,16
    6340:	00008067          	ret
    6344:	ff550513          	addi	a0,a0,-11
    6348:	00a41733          	sll	a4,s0,a0
    634c:	00000413          	li	s0,0
    6350:	00c12083          	lw	ra,12(sp)
    6354:	00040513          	mv	a0,s0
    6358:	00c71713          	slli	a4,a4,0xc
    635c:	00812403          	lw	s0,8(sp)
    6360:	00c75713          	srli	a4,a4,0xc
    6364:	01479793          	slli	a5,a5,0x14
    6368:	00e7e7b3          	or	a5,a5,a4
    636c:	00078593          	mv	a1,a5
    6370:	01010113          	addi	sp,sp,16
    6374:	00008067          	ret

00006378 <__clzsi2>:
    6378:	000107b7          	lui	a5,0x10
    637c:	02f57a63          	bgeu	a0,a5,63b0 <__clzsi2+0x38>
    6380:	10053793          	sltiu	a5,a0,256
    6384:	0017b793          	seqz	a5,a5
    6388:	00379793          	slli	a5,a5,0x3
    638c:	02000713          	li	a4,32
    6390:	40f70733          	sub	a4,a4,a5
    6394:	00f55533          	srl	a0,a0,a5
    6398:	00000797          	auipc	a5,0x0
    639c:	37878793          	addi	a5,a5,888 # 6710 <__clz_tab>
    63a0:	00a787b3          	add	a5,a5,a0
    63a4:	0007c503          	lbu	a0,0(a5)
    63a8:	40a70533          	sub	a0,a4,a0
    63ac:	00008067          	ret
    63b0:	010007b7          	lui	a5,0x1000
    63b4:	02f57463          	bgeu	a0,a5,63dc <__clzsi2+0x64>
    63b8:	01000793          	li	a5,16
    63bc:	00f55533          	srl	a0,a0,a5
    63c0:	00000797          	auipc	a5,0x0
    63c4:	35078793          	addi	a5,a5,848 # 6710 <__clz_tab>
    63c8:	00a787b3          	add	a5,a5,a0
    63cc:	0007c503          	lbu	a0,0(a5)
    63d0:	01000713          	li	a4,16
    63d4:	40a70533          	sub	a0,a4,a0
    63d8:	00008067          	ret
    63dc:	01800793          	li	a5,24
    63e0:	00f55533          	srl	a0,a0,a5
    63e4:	00000797          	auipc	a5,0x0
    63e8:	32c78793          	addi	a5,a5,812 # 6710 <__clz_tab>
    63ec:	00a787b3          	add	a5,a5,a0
    63f0:	0007c503          	lbu	a0,0(a5)
    63f4:	00800713          	li	a4,8
    63f8:	40a70533          	sub	a0,a4,a0
    63fc:	00008067          	ret
