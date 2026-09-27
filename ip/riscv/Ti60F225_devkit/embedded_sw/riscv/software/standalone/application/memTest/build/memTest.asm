
build/memTest.elf:     file format elf32-littleriscv


Disassembly of section .init:

00001000 <_start>:

_start:
#ifdef USE_GP
.option push
.option norelax
	la gp, __global_pointer$
    1000:	00005197          	auipc	gp,0x5
    1004:	77018193          	addi	gp,gp,1904 # 6770 <__global_pointer$>
.global smp_lottery_target
.global smp_lottery_lock
.global smp_slave


  sw x0, smp_lottery_lock, a1
    1008:	8a01ac23          	sw	zero,-1864(gp) # 6028 <smp_lottery_lock>

0000100c <smp_tyranny>:

smp_tyranny:
  csrr a0, mhartid
    100c:	f1402573          	csrr	a0,mhartid
  beqz a0, init
    1010:	02050e63          	beqz	a0,104c <init>

00001014 <smp_slave>:

smp_slave:
	lw a0, smp_lottery_lock
    1014:	8b81a503          	lw	a0,-1864(gp) # 6028 <smp_lottery_lock>
	beqz a0, smp_slave
    1018:	fe050ee3          	beqz	a0,1014 <smp_slave>

	fence r, r
    101c:	0220000f          	fence	r,r
    1020:	0000100f          	.word	0x0000100f
	//li a1, -1
	//amoadd.w x0, a1,(a0)

	.word(0x100F) //i$ flush
	lw a5, smp_lottery_target
    1024:	8b41a783          	lw	a5,-1868(gp) # 6024 <__bss_start>
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
    1038:	8aa1aa23          	sw	a0,-1868(gp) # 6024 <__bss_start>
	fence w, w
    103c:	0110000f          	fence	w,w
	li a0, 1
    1040:	00100513          	li	a0,1
	sw a0, smp_lottery_lock, a1
    1044:	8aa1ac23          	sw	a0,-1864(gp) # 6028 <smp_lottery_lock>
    ret
    1048:	00008067          	ret

0000104c <init>:
#endif

init:
	la sp, _sp
    104c:	00006117          	auipc	sp,0x6
    1050:	fe410113          	addi	sp,sp,-28 # 7030 <__freertos_irq_stack_top>

	/* Load data section */
	la a0, _data_lma
    1054:	00005517          	auipc	a0,0x5
    1058:	b4c50513          	addi	a0,a0,-1204 # 5ba0 <_data>
	la a1, _data
    105c:	00005597          	auipc	a1,0x5
    1060:	b4458593          	addi	a1,a1,-1212 # 5ba0 <_data>
	la a2, _edata
    1064:	00005617          	auipc	a2,0x5
    1068:	fc060613          	addi	a2,a2,-64 # 6024 <__bss_start>
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
    1088:	fa050513          	addi	a0,a0,-96 # 6024 <__bss_start>
	la a1, _end
    108c:	00005597          	auipc	a1,0x5
    1090:	fa458593          	addi	a1,a1,-92 # 6030 <_end>
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
    10d0:	ad478793          	addi	a5,a5,-1324 # 5ba0 <_data>
    10d4:	00005417          	auipc	s0,0x5
    10d8:	acc40413          	addi	s0,s0,-1332 # 5ba0 <_data>
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
    110c:	a9878793          	addi	a5,a5,-1384 # 5ba0 <_data>
    1110:	00005417          	auipc	s0,0x5
    1114:	a9040413          	addi	s0,s0,-1392 # 5ba0 <_data>
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
*         to a memory array and then reading and checking each value. 
*         If a mismatch is found between the expected and read values, 
*         it prints an error message and enters an infinite loop.
*
******************************************************************************/
void main() {
    1154:	ff010113          	addi	sp,sp,-16
    1158:	00112623          	sw	ra,12(sp)

    bsp_printf("***Starting Memory Test*** \r\n");
    115c:	00006537          	lui	a0,0x6
    1160:	bb850513          	addi	a0,a0,-1096 # 5bb8 <_data+0x18>
    1164:	2ed010ef          	jal	2c50 <bsp_printf>
    for(int i=0; i<MAX_WORDS; i++) MEM_LOC[i] = i;
    1168:	00000793          	li	a5,0
    116c:	0180006f          	j	1184 <main+0x30>
    1170:	00279693          	slli	a3,a5,0x2
    1174:	00400737          	lui	a4,0x400
    1178:	00d70733          	add	a4,a4,a3
    117c:	00f72023          	sw	a5,0(a4) # 400000 <__freertos_irq_stack_top+0x3f8fd0>
    1180:	00178793          	addi	a5,a5,1
    1184:	00100737          	lui	a4,0x100
    1188:	fee7c4e3          	blt	a5,a4,1170 <main+0x1c>

    for(int i=0; i<MAX_WORDS; i++) {
    118c:	00000593          	li	a1,0
    1190:	001007b7          	lui	a5,0x100
    1194:	02f5da63          	bge	a1,a5,11c8 <main+0x74>
       // bsp_printf("0x%x \r\n", i);
        if (MEM_LOC[i] != i) {
    1198:	00259713          	slli	a4,a1,0x2
    119c:	004007b7          	lui	a5,0x400
    11a0:	00e787b3          	add	a5,a5,a4
    11a4:	0007a703          	lw	a4,0(a5) # 400000 <__freertos_irq_stack_top+0x3f8fd0>
    11a8:	00e59663          	bne	a1,a4,11b4 <main+0x60>
    for(int i=0; i<MAX_WORDS; i++) {
    11ac:	00158593          	addi	a1,a1,1
    11b0:	fe1ff06f          	j	1190 <main+0x3c>
            bsp_printf("Data mismatched at address 0x%x with value of 0x%x \r\n", i, MEM_LOC[i]);
    11b4:	0007a603          	lw	a2,0(a5)
    11b8:	00006537          	lui	a0,0x6
    11bc:	bd850513          	addi	a0,a0,-1064 # 5bd8 <_data+0x38>
    11c0:	291010ef          	jal	2c50 <bsp_printf>
            while(1) {
    11c4:	0000006f          	j	11c4 <main+0x70>
                // Halt on error
            }
        }
    }
    bsp_printf("Data matched .. Test PASSED\r\n");
    11c8:	00006537          	lui	a0,0x6
    11cc:	c1050513          	addi	a0,a0,-1008 # 5c10 <_data+0x70>
    11d0:	281010ef          	jal	2c50 <bsp_printf>
    bsp_printf("***Succesfully Ran Demo*** \r\n");
    11d4:	00006537          	lui	a0,0x6
    11d8:	c3050513          	addi	a0,a0,-976 # 5c30 <_data+0x90>
    11dc:	275010ef          	jal	2c50 <bsp_printf>
}
    11e0:	00c12083          	lw	ra,12(sp)
    11e4:	01010113          	addi	sp,sp,16
    11e8:	00008067          	ret
    11ec:	0000                	.insn	2, 0x0000
	...

000011f0 <sh_write0>:
* @note    None.
*
******************************************************************************/

static void sh_write0(char* buf)
{
    11f0:	00050593          	mv	a1,a0
    register int value asm ("a0") = reason;
    11f4:	00400513          	li	a0,4
    register void* ptr asm ("a1") = arg;
    11f8:	00000013          	nop
    11fc:	00000013          	nop
    asm volatile (
    1200:	01f01013          	slli	zero,zero,0x1f
    1204:	00100073          	ebreak
    1208:	40705013          	srai	zero,zero,0x7
    120c:	00000013          	nop
    // Print zero-terminated string
    call_host(SEMIHOSTING_SYS_WRITE0, (void*) buf);
}
    1210:	00008067          	ret
    1214:	00000013          	nop
    1218:	00000013          	nop

0000121c <_putchar_s>:
            bsp_putChar(character);
        #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }

    static void _putchar_s(char *p)
    {
    121c:	ff010113          	addi	sp,sp,-16
    1220:	00112623          	sw	ra,12(sp)
    #if (ENABLE_SEMIHOSTING_PRINT == 1)
        sh_write0(p);
    1224:	fcdff0ef          	jal	11f0 <sh_write0>
    #else
        while (*p)
            _putchar(*(p++));
    #endif // (ENABLE_SEMIHOSTING_PRINT == 1)
    }
    1228:	00c12083          	lw	ra,12(sp)
    122c:	01010113          	addi	sp,sp,16
    1230:	00008067          	ret

00001234 <_out_buffer>:
*
******************************************************************************/

static inline void _out_buffer(char character, void* buffer, size_t idx, size_t maxlen)
{
  if (idx < maxlen) {
    1234:	00d67663          	bgeu	a2,a3,1240 <_out_buffer+0xc>
    ((char*)buffer)[idx] = character;
    1238:	00c585b3          	add	a1,a1,a2
    123c:	00a58023          	sb	a0,0(a1)
  }
}
    1240:	00008067          	ret

00001244 <_out_null>:
*
******************************************************************************/
static inline void _out_null(char character, void* buffer, size_t idx, size_t maxlen)
{
  (void)character; (void)buffer; (void)idx; (void)maxlen;
}
    1244:	00008067          	ret

00001248 <_atoi>:
*
* @return Converted unsigned integer value.
*
******************************************************************************/
static unsigned int _atoi(const char** str)
{
    1248:	00050693          	mv	a3,a0
  unsigned int i = 0U;
    124c:	00000513          	li	a0,0
  while (_is_digit(**str)) {
    1250:	0240006f          	j	1274 <_atoi+0x2c>
    i = i * 10U + (unsigned int)(*((*str)++) - '0');
    1254:	00251793          	slli	a5,a0,0x2
    1258:	00a787b3          	add	a5,a5,a0
    125c:	00179793          	slli	a5,a5,0x1
    1260:	00170613          	addi	a2,a4,1 # 100001 <__freertos_irq_stack_top+0xf8fd1>
    1264:	00c6a023          	sw	a2,0(a3)
    1268:	00074503          	lbu	a0,0(a4)
    126c:	00f50533          	add	a0,a0,a5
    1270:	fd050513          	addi	a0,a0,-48
  while (_is_digit(**str)) {
    1274:	0006a703          	lw	a4,0(a3)
    1278:	00074783          	lbu	a5,0(a4)
  return (ch >= '0') && (ch <= '9');
    127c:	fd078793          	addi	a5,a5,-48
    1280:	0ff7f793          	zext.b	a5,a5
  while (_is_digit(**str)) {
    1284:	00900613          	li	a2,9
    1288:	fcf676e3          	bgeu	a2,a5,1254 <_atoi+0xc>
  }
  return i;
}
    128c:	00008067          	ret

00001290 <_out_rev>:
*
* @return Updated index in the buffer after outputting the string.
*
******************************************************************************/
static size_t _out_rev(out_fct_type out, char* buffer, size_t idx, size_t maxlen, const char* buf, size_t len, unsigned int width, unsigned int flags)
{
    1290:	fd010113          	addi	sp,sp,-48
    1294:	02112623          	sw	ra,44(sp)
    1298:	02812423          	sw	s0,40(sp)
    129c:	02912223          	sw	s1,36(sp)
    12a0:	03212023          	sw	s2,32(sp)
    12a4:	01312e23          	sw	s3,28(sp)
    12a8:	01412c23          	sw	s4,24(sp)
    12ac:	01512a23          	sw	s5,20(sp)
    12b0:	01612823          	sw	s6,16(sp)
    12b4:	01712623          	sw	s7,12(sp)
    12b8:	01812423          	sw	s8,8(sp)
    12bc:	00050493          	mv	s1,a0
    12c0:	00058913          	mv	s2,a1
    12c4:	00060b93          	mv	s7,a2
    12c8:	00068993          	mv	s3,a3
    12cc:	00070b13          	mv	s6,a4
    12d0:	00078413          	mv	s0,a5
    12d4:	00080a93          	mv	s5,a6
    12d8:	00088c13          	mv	s8,a7
  const size_t start_idx = idx;

  // pad spaces up to given width
  if (!(flags & FLAGS_LEFT) && !(flags & FLAGS_ZEROPAD)) {
    12dc:	0038f793          	andi	a5,a7,3
    12e0:	04079c63          	bnez	a5,1338 <_out_rev+0xa8>
    12e4:	01912223          	sw	s9,4(sp)
    for (size_t i = len; i < width; i++) {
    12e8:	00040a13          	mv	s4,s0
    12ec:	035a7263          	bgeu	s4,s5,1310 <_out_rev+0x80>
      out(' ', buffer, idx++, maxlen);
    12f0:	00160c93          	addi	s9,a2,1
    12f4:	00098693          	mv	a3,s3
    12f8:	00090593          	mv	a1,s2
    12fc:	02000513          	li	a0,32
    1300:	000480e7          	jalr	s1
    for (size_t i = len; i < width; i++) {
    1304:	001a0a13          	addi	s4,s4,1
      out(' ', buffer, idx++, maxlen);
    1308:	000c8613          	mv	a2,s9
    130c:	fe1ff06f          	j	12ec <_out_rev+0x5c>
    1310:	00412c83          	lw	s9,4(sp)
    1314:	0240006f          	j	1338 <_out_rev+0xa8>
    }
  }

  // reverse string
  while (len) {
    out(buf[--len], buffer, idx++, maxlen);
    1318:	fff40413          	addi	s0,s0,-1
    131c:	008b07b3          	add	a5,s6,s0
    1320:	00160a13          	addi	s4,a2,1
    1324:	00098693          	mv	a3,s3
    1328:	00090593          	mv	a1,s2
    132c:	0007c503          	lbu	a0,0(a5)
    1330:	000480e7          	jalr	s1
    1334:	000a0613          	mv	a2,s4
  while (len) {
    1338:	fe0410e3          	bnez	s0,1318 <_out_rev+0x88>
  }

  // append pad spaces up to given width
  if (flags & FLAGS_LEFT) {
    133c:	002c7c13          	andi	s8,s8,2
    1340:	020c1c63          	bnez	s8,1378 <_out_rev+0xe8>
      out(' ', buffer, idx++, maxlen);
    }
  }

  return idx;
}
    1344:	00060513          	mv	a0,a2
    1348:	02c12083          	lw	ra,44(sp)
    134c:	02812403          	lw	s0,40(sp)
    1350:	02412483          	lw	s1,36(sp)
    1354:	02012903          	lw	s2,32(sp)
    1358:	01c12983          	lw	s3,28(sp)
    135c:	01812a03          	lw	s4,24(sp)
    1360:	01412a83          	lw	s5,20(sp)
    1364:	01012b03          	lw	s6,16(sp)
    1368:	00c12b83          	lw	s7,12(sp)
    136c:	00812c03          	lw	s8,8(sp)
    1370:	03010113          	addi	sp,sp,48
    1374:	00008067          	ret
    while (idx - start_idx < width) {
    1378:	417607b3          	sub	a5,a2,s7
    137c:	fd57f4e3          	bgeu	a5,s5,1344 <_out_rev+0xb4>
      out(' ', buffer, idx++, maxlen);
    1380:	00160413          	addi	s0,a2,1
    1384:	00098693          	mv	a3,s3
    1388:	00090593          	mv	a1,s2
    138c:	02000513          	li	a0,32
    1390:	000480e7          	jalr	s1
    1394:	00040613          	mv	a2,s0
    1398:	fe1ff06f          	j	1378 <_out_rev+0xe8>

0000139c <_ntoa_format>:
*
* @return Number of characters written to the buffer.
*
******************************************************************************/
static size_t _ntoa_format(out_fct_type out, char* buffer, size_t idx, size_t maxlen, char* buf, size_t len, bool negative, unsigned int base, unsigned int prec, unsigned int width, unsigned int flags)
{
    139c:	ff010113          	addi	sp,sp,-16
    13a0:	00112623          	sw	ra,12(sp)
    13a4:	00080f93          	mv	t6,a6
    13a8:	00088f13          	mv	t5,a7
    13ac:	01012e83          	lw	t4,16(sp)
    13b0:	01412803          	lw	a6,20(sp)
    13b4:	01812883          	lw	a7,24(sp)
  // pad leading zeros
  if (!(flags & FLAGS_LEFT)) {
    13b8:	0028f313          	andi	t1,a7,2
    13bc:	06031463          	bnez	t1,1424 <_ntoa_format+0x88>
    if (width && (flags & FLAGS_ZEROPAD) && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
    13c0:	02080863          	beqz	a6,13f0 <_ntoa_format+0x54>
    13c4:	0018f313          	andi	t1,a7,1
    13c8:	02030463          	beqz	t1,13f0 <_ntoa_format+0x54>
    13cc:	000f9663          	bnez	t6,13d8 <_ntoa_format+0x3c>
    13d0:	00c8f313          	andi	t1,a7,12
    13d4:	00030e63          	beqz	t1,13f0 <_ntoa_format+0x54>
      width--;
    13d8:	fff80813          	addi	a6,a6,-1
    13dc:	0140006f          	j	13f0 <_ntoa_format+0x54>
    }
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = '0';
    13e0:	00f70333          	add	t1,a4,a5
    13e4:	03000e13          	li	t3,48
    13e8:	01c30023          	sb	t3,0(t1)
    13ec:	00178793          	addi	a5,a5,1
    while ((len < prec) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    13f0:	01d7f663          	bgeu	a5,t4,13fc <_ntoa_format+0x60>
    13f4:	01f00313          	li	t1,31
    13f8:	fef374e3          	bgeu	t1,a5,13e0 <_ntoa_format+0x44>
    }
    while ((flags & FLAGS_ZEROPAD) && (len < width) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    13fc:	0018f313          	andi	t1,a7,1
    1400:	02030263          	beqz	t1,1424 <_ntoa_format+0x88>
    1404:	0307f063          	bgeu	a5,a6,1424 <_ntoa_format+0x88>
    1408:	01f00313          	li	t1,31
    140c:	00f36c63          	bltu	t1,a5,1424 <_ntoa_format+0x88>
      buf[len++] = '0';
    1410:	00f70333          	add	t1,a4,a5
    1414:	03000e13          	li	t3,48
    1418:	01c30023          	sb	t3,0(t1)
    141c:	00178793          	addi	a5,a5,1
    1420:	fddff06f          	j	13fc <_ntoa_format+0x60>
    }
  }

  // handle hash
  if (flags & FLAGS_HASH) {
    1424:	0108f313          	andi	t1,a7,16
    1428:	04030063          	beqz	t1,1468 <_ntoa_format+0xcc>
    if (!(flags & FLAGS_PRECISION) && len && ((len == prec) || (len == width))) {
    142c:	4008f313          	andi	t1,a7,1024
    1430:	00031863          	bnez	t1,1440 <_ntoa_format+0xa4>
    1434:	00078663          	beqz	a5,1440 <_ntoa_format+0xa4>
    1438:	05d78e63          	beq	a5,t4,1494 <_ntoa_format+0xf8>
    143c:	05078c63          	beq	a5,a6,1494 <_ntoa_format+0xf8>
      len--;
      if (len && (base == 16U)) {
        len--;
      }
    }
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1440:	01000313          	li	t1,16
    1444:	0a6f0063          	beq	t5,t1,14e4 <_ntoa_format+0x148>
      buf[len++] = 'x';
    }
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
      buf[len++] = 'X';
    }
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1448:	00200313          	li	t1,2
    144c:	0a6f0e63          	beq	t5,t1,1508 <_ntoa_format+0x16c>
      buf[len++] = 'b';
    }
    if (len < PRINTF_NTOA_BUFFER_SIZE) {
    1450:	01f00313          	li	t1,31
    1454:	02f36863          	bltu	t1,a5,1484 <_ntoa_format+0xe8>
      buf[len++] = '0';
    1458:	00f70333          	add	t1,a4,a5
    145c:	03000e13          	li	t3,48
    1460:	01c30023          	sb	t3,0(t1)
    1464:	00178793          	addi	a5,a5,1
    }
  }

  if (len < PRINTF_NTOA_BUFFER_SIZE) {
    1468:	01f00313          	li	t1,31
    146c:	00f36c63          	bltu	t1,a5,1484 <_ntoa_format+0xe8>
    if (negative) {
    1470:	0a0f8a63          	beqz	t6,1524 <_ntoa_format+0x188>
      buf[len++] = '-';
    1474:	00f70333          	add	t1,a4,a5
    1478:	02d00e13          	li	t3,45
    147c:	01c30023          	sb	t3,0(t1)
    1480:	00178793          	addi	a5,a5,1
    else if (flags & FLAGS_SPACE) {
      buf[len++] = ' ';
    }
  }

  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
    1484:	e0dff0ef          	jal	1290 <_out_rev>
}
    1488:	00c12083          	lw	ra,12(sp)
    148c:	01010113          	addi	sp,sp,16
    1490:	00008067          	ret
      len--;
    1494:	fff78313          	addi	t1,a5,-1
      if (len && (base == 16U)) {
    1498:	04030263          	beqz	t1,14dc <_ntoa_format+0x140>
    149c:	01000e13          	li	t3,16
    14a0:	03cf0a63          	beq	t5,t3,14d4 <_ntoa_format+0x138>
      len--;
    14a4:	00030793          	mv	a5,t1
    else if ((base == 16U) && (flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    14a8:	01000313          	li	t1,16
    14ac:	f86f1ee3          	bne	t5,t1,1448 <_ntoa_format+0xac>
    14b0:	0208f313          	andi	t1,a7,32
    14b4:	f8030ae3          	beqz	t1,1448 <_ntoa_format+0xac>
    14b8:	01f00313          	li	t1,31
    14bc:	f8f366e3          	bltu	t1,a5,1448 <_ntoa_format+0xac>
      buf[len++] = 'X';
    14c0:	00f70333          	add	t1,a4,a5
    14c4:	05800e13          	li	t3,88
    14c8:	01c30023          	sb	t3,0(t1)
    14cc:	00178793          	addi	a5,a5,1
    14d0:	f81ff06f          	j	1450 <_ntoa_format+0xb4>
        len--;
    14d4:	ffe78793          	addi	a5,a5,-2
    14d8:	f69ff06f          	j	1440 <_ntoa_format+0xa4>
      len--;
    14dc:	00030793          	mv	a5,t1
    14e0:	f61ff06f          	j	1440 <_ntoa_format+0xa4>
    if ((base == 16U) && !(flags & FLAGS_UPPERCASE) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    14e4:	0208f313          	andi	t1,a7,32
    14e8:	fc0310e3          	bnez	t1,14a8 <_ntoa_format+0x10c>
    14ec:	01f00313          	li	t1,31
    14f0:	faf36ce3          	bltu	t1,a5,14a8 <_ntoa_format+0x10c>
      buf[len++] = 'x';
    14f4:	00f70333          	add	t1,a4,a5
    14f8:	07800e13          	li	t3,120
    14fc:	01c30023          	sb	t3,0(t1)
    1500:	00178793          	addi	a5,a5,1
    1504:	f4dff06f          	j	1450 <_ntoa_format+0xb4>
    else if ((base == 2U) && (len < PRINTF_NTOA_BUFFER_SIZE)) {
    1508:	01f00313          	li	t1,31
    150c:	f6f36ce3          	bltu	t1,a5,1484 <_ntoa_format+0xe8>
      buf[len++] = 'b';
    1510:	00f70333          	add	t1,a4,a5
    1514:	06200e13          	li	t3,98
    1518:	01c30023          	sb	t3,0(t1)
    151c:	00178793          	addi	a5,a5,1
    1520:	f31ff06f          	j	1450 <_ntoa_format+0xb4>
    else if (flags & FLAGS_PLUS) {
    1524:	0048f313          	andi	t1,a7,4
    1528:	00030c63          	beqz	t1,1540 <_ntoa_format+0x1a4>
      buf[len++] = '+';  // ignore the space if the '+' exists
    152c:	00f70333          	add	t1,a4,a5
    1530:	02b00e13          	li	t3,43
    1534:	01c30023          	sb	t3,0(t1)
    1538:	00178793          	addi	a5,a5,1
    153c:	f49ff06f          	j	1484 <_ntoa_format+0xe8>
    else if (flags & FLAGS_SPACE) {
    1540:	0088f313          	andi	t1,a7,8
    1544:	f40300e3          	beqz	t1,1484 <_ntoa_format+0xe8>
      buf[len++] = ' ';
    1548:	00f70333          	add	t1,a4,a5
    154c:	02000e13          	li	t3,32
    1550:	01c30023          	sb	t3,0(t1)
    1554:	00178793          	addi	a5,a5,1
    1558:	f2dff06f          	j	1484 <_ntoa_format+0xe8>

0000155c <_ntoa_long>:
* @return Number of characters written to the buffer.
*
*
******************************************************************************/
static size_t _ntoa_long(out_fct_type out, char* buffer, size_t idx, size_t maxlen, unsigned long value, bool negative, unsigned long base, unsigned int prec, unsigned int width, unsigned int flags)
{
    155c:	fc010113          	addi	sp,sp,-64
    1560:	02112e23          	sw	ra,60(sp)
    1564:	00078f93          	mv	t6,a5
    1568:	04412f03          	lw	t5,68(sp)
  char buf[PRINTF_NTOA_BUFFER_SIZE];
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
    156c:	00071463          	bnez	a4,1574 <_ntoa_long+0x18>
    flags &= ~FLAGS_HASH;
    1570:	feff7f13          	andi	t5,t5,-17
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
    1574:	400f7e93          	andi	t4,t5,1024
    1578:	040e8063          	beqz	t4,15b8 <_ntoa_long+0x5c>
    157c:	06070a63          	beqz	a4,15f0 <_ntoa_long+0x94>
    1580:	00000e93          	li	t4,0
    1584:	0340006f          	j	15b8 <_ntoa_long+0x5c>
    do {
      const char digit = (char)(value % base);
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1588:	030e0e13          	addi	t3,t3,48
    158c:	0ffe7313          	zext.b	t1,t3
    1590:	001e8793          	addi	a5,t4,1
    1594:	030e8e13          	addi	t3,t4,48
    1598:	002e0eb3          	add	t4,t3,sp
    159c:	fe6e8023          	sb	t1,-32(t4)
      value /= base;
    15a0:	03075333          	divu	t1,a4,a6
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    15a4:	05076863          	bltu	a4,a6,15f4 <_ntoa_long+0x98>
    15a8:	01f00713          	li	a4,31
    15ac:	04f76463          	bltu	a4,a5,15f4 <_ntoa_long+0x98>
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    15b0:	00078e93          	mv	t4,a5
      value /= base;
    15b4:	00030713          	mv	a4,t1
      const char digit = (char)(value % base);
    15b8:	03077e33          	remu	t3,a4,a6
    15bc:	0ffe7e13          	zext.b	t3,t3
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    15c0:	00900313          	li	t1,9
    15c4:	fdc372e3          	bgeu	t1,t3,1588 <_ntoa_long+0x2c>
    15c8:	020f7313          	andi	t1,t5,32
    15cc:	00030e63          	beqz	t1,15e8 <_ntoa_long+0x8c>
    15d0:	04100313          	li	t1,65
    15d4:	01c30333          	add	t1,t1,t3
    15d8:	0ff37313          	zext.b	t1,t1
    15dc:	ff630313          	addi	t1,t1,-10
    15e0:	0ff37313          	zext.b	t1,t1
    15e4:	fadff06f          	j	1590 <_ntoa_long+0x34>
    15e8:	06100313          	li	t1,97
    15ec:	fe9ff06f          	j	15d4 <_ntoa_long+0x78>
  size_t len = 0U;
    15f0:	00070793          	mv	a5,a4
  }

  return _ntoa_format(out, buffer, idx, maxlen, buf, len, negative, (unsigned int)base, prec, width, flags);
    15f4:	01e12423          	sw	t5,8(sp)
    15f8:	04012703          	lw	a4,64(sp)
    15fc:	00e12223          	sw	a4,4(sp)
    1600:	01112023          	sw	a7,0(sp)
    1604:	00080893          	mv	a7,a6
    1608:	000f8813          	mv	a6,t6
    160c:	01010713          	addi	a4,sp,16
    1610:	d8dff0ef          	jal	139c <_ntoa_format>
}
    1614:	03c12083          	lw	ra,60(sp)
    1618:	04010113          	addi	sp,sp,64
    161c:	00008067          	ret

00001620 <_ntoa_long_long>:
*
* @return Number of characters written to the buffer.
*
******************************************************************************/
static size_t _ntoa_long_long(out_fct_type out, char* buffer, size_t idx, size_t maxlen, unsigned long long value, bool negative, unsigned long long base, unsigned int prec, unsigned int width, unsigned int flags)
{
    1620:	f8010113          	addi	sp,sp,-128
    1624:	06112623          	sw	ra,108(sp)
    1628:	06812423          	sw	s0,104(sp)
    162c:	06912223          	sw	s1,100(sp)
    1630:	07212023          	sw	s2,96(sp)
    1634:	05312e23          	sw	s3,92(sp)
    1638:	05412c23          	sw	s4,88(sp)
    163c:	05512a23          	sw	s5,84(sp)
    1640:	05612823          	sw	s6,80(sp)
    1644:	05712623          	sw	s7,76(sp)
    1648:	05812423          	sw	s8,72(sp)
    164c:	05912223          	sw	s9,68(sp)
    1650:	05a12023          	sw	s10,64(sp)
    1654:	03b12e23          	sw	s11,60(sp)
    1658:	00050b93          	mv	s7,a0
    165c:	00058c13          	mv	s8,a1
    1660:	00060c93          	mv	s9,a2
    1664:	00068d13          	mv	s10,a3
    1668:	00070993          	mv	s3,a4
    166c:	00078413          	mv	s0,a5
    1670:	00080d93          	mv	s11,a6
    1674:	07112e23          	sw	a7,124(sp)
    1678:	00088a93          	mv	s5,a7
    167c:	08012903          	lw	s2,128(sp)
    1680:	08c12b03          	lw	s6,140(sp)
  char buf[PRINTF_NTOA_BUFFER_SIZE];
  size_t len = 0U;

  // no hash for 0 values
  if (!value) {
    1684:	00f767b3          	or	a5,a4,a5
    1688:	00079463          	bnez	a5,1690 <_ntoa_long_long+0x70>
    flags &= ~FLAGS_HASH;
    168c:	fefb7b13          	andi	s6,s6,-17
  }

  // write if precision != 0 and value is != 0
  if (!(flags & FLAGS_PRECISION) || value) {
    1690:	400b7493          	andi	s1,s6,1024
    1694:	04048e63          	beqz	s1,16f0 <_ntoa_long_long+0xd0>
    1698:	0089e7b3          	or	a5,s3,s0
    169c:	0a078263          	beqz	a5,1740 <_ntoa_long_long+0x120>
    16a0:	00000493          	li	s1,0
    16a4:	04c0006f          	j	16f0 <_ntoa_long_long+0xd0>
    do {
      const char digit = (char)(value % base);
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    16a8:	03050513          	addi	a0,a0,48
    16ac:	0ff57793          	zext.b	a5,a0
    16b0:	00148a13          	addi	s4,s1,1
    16b4:	03048713          	addi	a4,s1,48
    16b8:	002704b3          	add	s1,a4,sp
    16bc:	fef48023          	sb	a5,-32(s1)
      value /= base;
    16c0:	000a8613          	mv	a2,s5
    16c4:	00090693          	mv	a3,s2
    16c8:	00098513          	mv	a0,s3
    16cc:	00040593          	mv	a1,s0
    16d0:	5e8010ef          	jal	2cb8 <__udivdi3>
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    16d4:	07246863          	bltu	s0,s2,1744 <_ntoa_long_long+0x124>
    16d8:	06890063          	beq	s2,s0,1738 <_ntoa_long_long+0x118>
    16dc:	01f00793          	li	a5,31
    16e0:	0747e263          	bltu	a5,s4,1744 <_ntoa_long_long+0x124>
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    16e4:	000a0493          	mv	s1,s4
      value /= base;
    16e8:	00050993          	mv	s3,a0
    16ec:	00058413          	mv	s0,a1
      const char digit = (char)(value % base);
    16f0:	000a8613          	mv	a2,s5
    16f4:	00090693          	mv	a3,s2
    16f8:	00098513          	mv	a0,s3
    16fc:	00040593          	mv	a1,s0
    1700:	269010ef          	jal	3168 <__umoddi3>
    1704:	0ff57513          	zext.b	a0,a0
      buf[len++] = digit < 10 ? '0' + digit : (flags & FLAGS_UPPERCASE ? 'A' : 'a') + digit - 10;
    1708:	00900793          	li	a5,9
    170c:	f8a7fee3          	bgeu	a5,a0,16a8 <_ntoa_long_long+0x88>
    1710:	020b7793          	andi	a5,s6,32
    1714:	00078e63          	beqz	a5,1730 <_ntoa_long_long+0x110>
    1718:	04100793          	li	a5,65
    171c:	00a787b3          	add	a5,a5,a0
    1720:	0ff7f793          	zext.b	a5,a5
    1724:	ff678793          	addi	a5,a5,-10
    1728:	0ff7f793          	zext.b	a5,a5
    172c:	f85ff06f          	j	16b0 <_ntoa_long_long+0x90>
    1730:	06100793          	li	a5,97
    1734:	fe9ff06f          	j	171c <_ntoa_long_long+0xfc>
    } while (value && (len < PRINTF_NTOA_BUFFER_SIZE));
    1738:	fb59f2e3          	bgeu	s3,s5,16dc <_ntoa_long_long+0xbc>
    173c:	0080006f          	j	1744 <_ntoa_long_long+0x124>
  size_t len = 0U;
    1740:	00000a13          	li	s4,0
  }

  return _ntoa_format(out, buffer, idx, maxlen, buf, len, negative, (unsigned int)base, prec, width, flags);
    1744:	01612423          	sw	s6,8(sp)
    1748:	08812783          	lw	a5,136(sp)
    174c:	00f12223          	sw	a5,4(sp)
    1750:	08412783          	lw	a5,132(sp)
    1754:	00f12023          	sw	a5,0(sp)
    1758:	000a8893          	mv	a7,s5
    175c:	000d8813          	mv	a6,s11
    1760:	000a0793          	mv	a5,s4
    1764:	01010713          	addi	a4,sp,16
    1768:	000d0693          	mv	a3,s10
    176c:	000c8613          	mv	a2,s9
    1770:	000c0593          	mv	a1,s8
    1774:	000b8513          	mv	a0,s7
    1778:	c25ff0ef          	jal	139c <_ntoa_format>
}
    177c:	06c12083          	lw	ra,108(sp)
    1780:	06812403          	lw	s0,104(sp)
    1784:	06412483          	lw	s1,100(sp)
    1788:	06012903          	lw	s2,96(sp)
    178c:	05c12983          	lw	s3,92(sp)
    1790:	05812a03          	lw	s4,88(sp)
    1794:	05412a83          	lw	s5,84(sp)
    1798:	05012b03          	lw	s6,80(sp)
    179c:	04c12b83          	lw	s7,76(sp)
    17a0:	04812c03          	lw	s8,72(sp)
    17a4:	04412c83          	lw	s9,68(sp)
    17a8:	04012d03          	lw	s10,64(sp)
    17ac:	03c12d83          	lw	s11,60(sp)
    17b0:	08010113          	addi	sp,sp,128
    17b4:	00008067          	ret

000017b8 <_etoa>:
*
* @note           Contributed by: Martijn Jasperse <m.jasperse@gmail.com>
*
******************************************************************************/
static size_t _etoa(out_fct_type out, char* buffer, size_t idx, size_t maxlen, double value, unsigned int prec, unsigned int width, unsigned int flags)
{
    17b8:	f9010113          	addi	sp,sp,-112
    17bc:	06112623          	sw	ra,108(sp)
    17c0:	06812423          	sw	s0,104(sp)
    17c4:	06912223          	sw	s1,100(sp)
    17c8:	07212023          	sw	s2,96(sp)
    17cc:	05312e23          	sw	s3,92(sp)
    17d0:	05412c23          	sw	s4,88(sp)
    17d4:	05512a23          	sw	s5,84(sp)
    17d8:	05612823          	sw	s6,80(sp)
    17dc:	05712623          	sw	s7,76(sp)
    17e0:	05812423          	sw	s8,72(sp)
    17e4:	00050913          	mv	s2,a0
    17e8:	00058993          	mv	s3,a1
    17ec:	00060b13          	mv	s6,a2
    17f0:	00068a13          	mv	s4,a3
    17f4:	00070493          	mv	s1,a4
    17f8:	00078413          	mv	s0,a5
    17fc:	00080b93          	mv	s7,a6
    1800:	00088a93          	mv	s5,a7
    1804:	07012c03          	lw	s8,112(sp)
  // check for NaN and special values
  if ((value != value) || (value > DBL_MAX) || (value < -DBL_MAX)) {
    1808:	00048613          	mv	a2,s1
    180c:	00040693          	mv	a3,s0
    1810:	00048513          	mv	a0,s1
    1814:	00040593          	mv	a1,s0
    1818:	619020ef          	jal	4630 <__eqdf2>
    181c:	30051263          	bnez	a0,1b20 <_etoa+0x368>
    1820:	8101a603          	lw	a2,-2032(gp) # 5f80 <__clz_tab+0x100>
    1824:	8141a683          	lw	a3,-2028(gp) # 5f84 <__clz_tab+0x104>
    1828:	00048513          	mv	a0,s1
    182c:	00040593          	mv	a1,s0
    1830:	68d020ef          	jal	46bc <__gedf2>
    1834:	2ea04663          	bgtz	a0,1b20 <_etoa+0x368>
    1838:	8181a603          	lw	a2,-2024(gp) # 5f88 <__clz_tab+0x108>
    183c:	81c1a683          	lw	a3,-2020(gp) # 5f8c <__clz_tab+0x10c>
    1840:	00048513          	mv	a0,s1
    1844:	00040593          	mv	a1,s0
    1848:	775020ef          	jal	47bc <__ledf2>
    184c:	2c054a63          	bltz	a0,1b20 <_etoa+0x368>
    1850:	05912223          	sw	s9,68(sp)
    1854:	05a12023          	sw	s10,64(sp)
    1858:	03b12e23          	sw	s11,60(sp)
    return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
  }

  // determine the sign
  const bool negative = value < 0;
  if (negative) {
    185c:	00000613          	li	a2,0
    1860:	00000693          	li	a3,0
    1864:	00048513          	mv	a0,s1
    1868:	00040593          	mv	a1,s0
    186c:	751020ef          	jal	47bc <__ledf2>
    1870:	30054463          	bltz	a0,1b78 <_etoa+0x3c0>
    1874:	00912823          	sw	s1,16(sp)
    1878:	00040c93          	mv	s9,s0
    value = -value;
  }

  // default precision
  if (!(flags & FLAGS_PRECISION)) {
    187c:	400c7793          	andi	a5,s8,1024
    1880:	02f12623          	sw	a5,44(sp)
    1884:	00079463          	bnez	a5,188c <_etoa+0xd4>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1888:	00400b93          	li	s7,4
    uint64_t U;
    double   F;
  } conv;

  conv.F = value;
  int exp2 = (int)((conv.U >> 52U) & 0x07FFU) - 1023;           // effectively log2
    188c:	014cd513          	srli	a0,s9,0x14
    1890:	7ff57513          	andi	a0,a0,2047
  conv.U = (conv.U & ((1ULL << 52U) - 1U)) | (1023ULL << 52U);  // drop the exponent so conv.F is now in [1,2)
    1894:	001007b7          	lui	a5,0x100
    1898:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf8fcf>
    189c:	00fcf7b3          	and	a5,s9,a5
    18a0:	3ff00d37          	lui	s10,0x3ff00
    18a4:	00fd6d33          	or	s10,s10,a5
  // now approximate log10 from the log2 integer part and an expansion of ln around 1.5
  int expval = (int)(0.1760912590558 + exp2 * 0.301029995663981 + (conv.F - 1.5) * 0.289529654602168);
    18a8:	c0150513          	addi	a0,a0,-1023
    18ac:	0f0040ef          	jal	599c <__floatsidf>
    18b0:	8201a603          	lw	a2,-2016(gp) # 5f90 <__clz_tab+0x110>
    18b4:	8241a683          	lw	a3,-2012(gp) # 5f94 <__clz_tab+0x114>
    18b8:	00c030ef          	jal	48c4 <__muldf3>
    18bc:	8281a603          	lw	a2,-2008(gp) # 5f98 <__clz_tab+0x118>
    18c0:	82c1a683          	lw	a3,-2004(gp) # 5f9c <__clz_tab+0x11c>
    18c4:	515010ef          	jal	35d8 <__adddf3>
    18c8:	00050d93          	mv	s11,a0
    18cc:	00b12a23          	sw	a1,20(sp)
    18d0:	8301a603          	lw	a2,-2000(gp) # 5fa0 <__clz_tab+0x120>
    18d4:	8341a683          	lw	a3,-1996(gp) # 5fa4 <__clz_tab+0x124>
    18d8:	01012703          	lw	a4,16(sp)
    18dc:	00070513          	mv	a0,a4
    18e0:	000d0593          	mv	a1,s10
    18e4:	6b8030ef          	jal	4f9c <__subdf3>
    18e8:	8381a603          	lw	a2,-1992(gp) # 5fa8 <__clz_tab+0x128>
    18ec:	83c1a683          	lw	a3,-1988(gp) # 5fac <__clz_tab+0x12c>
    18f0:	7d5020ef          	jal	48c4 <__muldf3>
    18f4:	00050613          	mv	a2,a0
    18f8:	00058693          	mv	a3,a1
    18fc:	000d8513          	mv	a0,s11
    1900:	01412583          	lw	a1,20(sp)
    1904:	4d5010ef          	jal	35d8 <__adddf3>
    1908:	79d030ef          	jal	58a4 <__fixdfsi>
    190c:	00050d13          	mv	s10,a0
  // now we want to compute 10^expval but we want to be sure it won't overflow
  exp2 = (int)(expval * 3.321928094887362 + 0.5);
    1910:	08c040ef          	jal	599c <__floatsidf>
    1914:	00a12a23          	sw	a0,20(sp)
    1918:	00b12c23          	sw	a1,24(sp)
    191c:	8401a603          	lw	a2,-1984(gp) # 5fb0 <__clz_tab+0x130>
    1920:	8441a683          	lw	a3,-1980(gp) # 5fb4 <__clz_tab+0x134>
    1924:	7a1020ef          	jal	48c4 <__muldf3>
    1928:	8481a603          	lw	a2,-1976(gp) # 5fb8 <__clz_tab+0x138>
    192c:	84c1a683          	lw	a3,-1972(gp) # 5fbc <__clz_tab+0x13c>
    1930:	4a9010ef          	jal	35d8 <__adddf3>
    1934:	771030ef          	jal	58a4 <__fixdfsi>
    1938:	00050d93          	mv	s11,a0
  const double z  = expval * 2.302585092994046 - exp2 * 0.6931471805599453;
    193c:	8501a603          	lw	a2,-1968(gp) # 5fc0 <__clz_tab+0x140>
    1940:	8541a683          	lw	a3,-1964(gp) # 5fc4 <__clz_tab+0x144>
    1944:	01412503          	lw	a0,20(sp)
    1948:	01812583          	lw	a1,24(sp)
    194c:	779020ef          	jal	48c4 <__muldf3>
    1950:	00a12a23          	sw	a0,20(sp)
    1954:	00b12c23          	sw	a1,24(sp)
    1958:	000d8513          	mv	a0,s11
    195c:	040040ef          	jal	599c <__floatsidf>
    1960:	8581a603          	lw	a2,-1960(gp) # 5fc8 <__clz_tab+0x148>
    1964:	85c1a683          	lw	a3,-1956(gp) # 5fcc <__clz_tab+0x14c>
    1968:	75d020ef          	jal	48c4 <__muldf3>
    196c:	00050613          	mv	a2,a0
    1970:	00058693          	mv	a3,a1
    1974:	01412503          	lw	a0,20(sp)
    1978:	01812583          	lw	a1,24(sp)
    197c:	620030ef          	jal	4f9c <__subdf3>
  const double z2 = z * z;
    1980:	00a12a23          	sw	a0,20(sp)
    1984:	00050613          	mv	a2,a0
    1988:	00b12c23          	sw	a1,24(sp)
    198c:	00058693          	mv	a3,a1
    1990:	735020ef          	jal	48c4 <__muldf3>
    1994:	00a12e23          	sw	a0,28(sp)
    1998:	02b12023          	sw	a1,32(sp)
  conv.U = (uint64_t)(exp2 + 1023) << 52U;
    199c:	3ffd8d93          	addi	s11,s11,1023
    19a0:	014d9d93          	slli	s11,s11,0x14
  // compute exp(z) using continued fractions, see https://en.wikipedia.org/wiki/Exponential_function#Continued_fractions_for_ex
  conv.F *= 1 + 2 * z / (2 - z + (z2 / (6 + (z2 / (10 + z2 / 14)))));
    19a4:	01412803          	lw	a6,20(sp)
    19a8:	00080613          	mv	a2,a6
    19ac:	01812783          	lw	a5,24(sp)
    19b0:	00078693          	mv	a3,a5
    19b4:	00080513          	mv	a0,a6
    19b8:	00078593          	mv	a1,a5
    19bc:	41d010ef          	jal	35d8 <__adddf3>
    19c0:	02a12223          	sw	a0,36(sp)
    19c4:	02b12423          	sw	a1,40(sp)
    19c8:	01412603          	lw	a2,20(sp)
    19cc:	01812683          	lw	a3,24(sp)
    19d0:	8601a503          	lw	a0,-1952(gp) # 5fd0 <__clz_tab+0x150>
    19d4:	8641a583          	lw	a1,-1948(gp) # 5fd4 <__clz_tab+0x154>
    19d8:	5c4030ef          	jal	4f9c <__subdf3>
    19dc:	00a12a23          	sw	a0,20(sp)
    19e0:	00b12c23          	sw	a1,24(sp)
    19e4:	8681a603          	lw	a2,-1944(gp) # 5fd8 <__clz_tab+0x158>
    19e8:	86c1a683          	lw	a3,-1940(gp) # 5fdc <__clz_tab+0x15c>
    19ec:	01c12503          	lw	a0,28(sp)
    19f0:	02012583          	lw	a1,32(sp)
    19f4:	4ac020ef          	jal	3ea0 <__divdf3>
    19f8:	8701a603          	lw	a2,-1936(gp) # 5fe0 <__clz_tab+0x160>
    19fc:	8741a683          	lw	a3,-1932(gp) # 5fe4 <__clz_tab+0x164>
    1a00:	3d9010ef          	jal	35d8 <__adddf3>
    1a04:	00050613          	mv	a2,a0
    1a08:	00058693          	mv	a3,a1
    1a0c:	01c12503          	lw	a0,28(sp)
    1a10:	02012583          	lw	a1,32(sp)
    1a14:	48c020ef          	jal	3ea0 <__divdf3>
    1a18:	8781a603          	lw	a2,-1928(gp) # 5fe8 <__clz_tab+0x168>
    1a1c:	87c1a683          	lw	a3,-1924(gp) # 5fec <__clz_tab+0x16c>
    1a20:	3b9010ef          	jal	35d8 <__adddf3>
    1a24:	00050613          	mv	a2,a0
    1a28:	00058693          	mv	a3,a1
    1a2c:	01c12503          	lw	a0,28(sp)
    1a30:	02012583          	lw	a1,32(sp)
    1a34:	46c020ef          	jal	3ea0 <__divdf3>
    1a38:	00050613          	mv	a2,a0
    1a3c:	00058693          	mv	a3,a1
    1a40:	01412503          	lw	a0,20(sp)
    1a44:	01812583          	lw	a1,24(sp)
    1a48:	391010ef          	jal	35d8 <__adddf3>
    1a4c:	00050613          	mv	a2,a0
    1a50:	00058693          	mv	a3,a1
    1a54:	02412503          	lw	a0,36(sp)
    1a58:	02812583          	lw	a1,40(sp)
    1a5c:	444020ef          	jal	3ea0 <__divdf3>
    1a60:	8801a603          	lw	a2,-1920(gp) # 5ff0 <__clz_tab+0x170>
    1a64:	8841a683          	lw	a3,-1916(gp) # 5ff4 <__clz_tab+0x174>
    1a68:	371010ef          	jal	35d8 <__adddf3>
    1a6c:	00000713          	li	a4,0
    1a70:	00070613          	mv	a2,a4
    1a74:	000d8693          	mv	a3,s11
    1a78:	64d020ef          	jal	48c4 <__muldf3>
    1a7c:	00050d93          	mv	s11,a0
    1a80:	00a12c23          	sw	a0,24(sp)
    1a84:	00b12a23          	sw	a1,20(sp)
    1a88:	00b12e23          	sw	a1,28(sp)
  // correct for rounding errors
  if (value < conv.F) {
    1a8c:	01012703          	lw	a4,16(sp)
    1a90:	00070613          	mv	a2,a4
    1a94:	000c8693          	mv	a3,s9
    1a98:	425020ef          	jal	46bc <__gedf2>
    1a9c:	02a05263          	blez	a0,1ac0 <_etoa+0x308>
    expval--;
    1aa0:	fffd0d13          	addi	s10,s10,-1 # 3fefffff <__freertos_irq_stack_top+0x3fef8fcf>
    conv.F /= 10;
    1aa4:	8701a603          	lw	a2,-1936(gp) # 5fe0 <__clz_tab+0x160>
    1aa8:	8741a683          	lw	a3,-1932(gp) # 5fe4 <__clz_tab+0x164>
    1aac:	000d8513          	mv	a0,s11
    1ab0:	01412583          	lw	a1,20(sp)
    1ab4:	3ec020ef          	jal	3ea0 <__divdf3>
    1ab8:	00a12c23          	sw	a0,24(sp)
    1abc:	00b12e23          	sw	a1,28(sp)
  }

  // the exponent format is "%+03d" and largest value is "307", so set aside 4-5 characters
  unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
    1ac0:	063d0793          	addi	a5,s10,99
    1ac4:	0c600713          	li	a4,198
    1ac8:	0cf76063          	bltu	a4,a5,1b88 <_etoa+0x3d0>
    1acc:	00400d93          	li	s11,4

  // in "%g" mode, "prec" is the number of *significant figures* not decimals
  if (flags & FLAGS_ADAPT_EXP) {
    1ad0:	014c1793          	slli	a5,s8,0x14
    1ad4:	0c07d663          	bgez	a5,1ba0 <_etoa+0x3e8>
    // do we want to fall-back to "%f" mode?
    if ((value >= 1e-4) && (value < 1e6)) {
    1ad8:	8881a603          	lw	a2,-1912(gp) # 5ff8 <__clz_tab+0x178>
    1adc:	88c1a683          	lw	a3,-1908(gp) # 5ffc <__clz_tab+0x17c>
    1ae0:	01012703          	lw	a4,16(sp)
    1ae4:	00070513          	mv	a0,a4
    1ae8:	000c8593          	mv	a1,s9
    1aec:	3d1020ef          	jal	46bc <__gedf2>
    1af0:	0c054063          	bltz	a0,1bb0 <_etoa+0x3f8>
    1af4:	8901a603          	lw	a2,-1904(gp) # 6000 <__clz_tab+0x180>
    1af8:	8941a683          	lw	a3,-1900(gp) # 6004 <__clz_tab+0x184>
    1afc:	01012703          	lw	a4,16(sp)
    1b00:	00070513          	mv	a0,a4
    1b04:	000c8593          	mv	a1,s9
    1b08:	4b5020ef          	jal	47bc <__ledf2>
    1b0c:	0a055263          	bgez	a0,1bb0 <_etoa+0x3f8>
      if ((int)prec > expval) {
    1b10:	097d5063          	bge	s10,s7,1b90 <_etoa+0x3d8>
        prec = (unsigned)((int)prec - expval - 1);
    1b14:	41ab8d33          	sub	s10,s7,s10
    1b18:	fffd0b93          	addi	s7,s10,-1
    1b1c:	0780006f          	j	1b94 <_etoa+0x3dc>
    return _ftoa(out, buffer, idx, maxlen, value, prec, width, flags);
    1b20:	01812023          	sw	s8,0(sp)
    1b24:	000a8893          	mv	a7,s5
    1b28:	000b8813          	mv	a6,s7
    1b2c:	00048713          	mv	a4,s1
    1b30:	00040793          	mv	a5,s0
    1b34:	000a0693          	mv	a3,s4
    1b38:	000b0613          	mv	a2,s6
    1b3c:	00098593          	mv	a1,s3
    1b40:	00090513          	mv	a0,s2
    1b44:	1e8000ef          	jal	1d2c <_ftoa>
    if (flags & FLAGS_LEFT) {
      while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
    }
  }
  return idx;
}
    1b48:	06c12083          	lw	ra,108(sp)
    1b4c:	06812403          	lw	s0,104(sp)
    1b50:	06412483          	lw	s1,100(sp)
    1b54:	06012903          	lw	s2,96(sp)
    1b58:	05c12983          	lw	s3,92(sp)
    1b5c:	05812a03          	lw	s4,88(sp)
    1b60:	05412a83          	lw	s5,84(sp)
    1b64:	05012b03          	lw	s6,80(sp)
    1b68:	04c12b83          	lw	s7,76(sp)
    1b6c:	04812c03          	lw	s8,72(sp)
    1b70:	07010113          	addi	sp,sp,112
    1b74:	00008067          	ret
    value = -value;
    1b78:	00912823          	sw	s1,16(sp)
    1b7c:	80000cb7          	lui	s9,0x80000
    1b80:	008cccb3          	xor	s9,s9,s0
    1b84:	cf9ff06f          	j	187c <_etoa+0xc4>
  unsigned int minwidth = ((expval < 100) && (expval > -100)) ? 4U : 5U;
    1b88:	00500d93          	li	s11,5
    1b8c:	f45ff06f          	j	1ad0 <_etoa+0x318>
        prec = 0;
    1b90:	00000b93          	li	s7,0
      flags |= FLAGS_PRECISION;   // make sure _ftoa respects precision
    1b94:	400c6c13          	ori	s8,s8,1024
      minwidth = 0U;
    1b98:	00000d93          	li	s11,0
      expval   = 0;
    1b9c:	00000d13          	li	s10,0
  if (width > minwidth) {
    1ba0:	035df263          	bgeu	s11,s5,1bc4 <_etoa+0x40c>
    fwidth -= minwidth;
    1ba4:	41ba87b3          	sub	a5,s5,s11
    1ba8:	00f12a23          	sw	a5,20(sp)
    1bac:	01c0006f          	j	1bc8 <_etoa+0x410>
      if ((prec > 0) && (flags & FLAGS_PRECISION)) {
    1bb0:	fe0b88e3          	beqz	s7,1ba0 <_etoa+0x3e8>
    1bb4:	02c12783          	lw	a5,44(sp)
    1bb8:	fe0784e3          	beqz	a5,1ba0 <_etoa+0x3e8>
        --prec;
    1bbc:	fffb8b93          	addi	s7,s7,-1
    1bc0:	fe1ff06f          	j	1ba0 <_etoa+0x3e8>
    fwidth = 0U;
    1bc4:	00012a23          	sw	zero,20(sp)
  if ((flags & FLAGS_LEFT) && minwidth) {
    1bc8:	002c7793          	andi	a5,s8,2
    1bcc:	02f12023          	sw	a5,32(sp)
    1bd0:	00078663          	beqz	a5,1bdc <_etoa+0x424>
    1bd4:	000d8463          	beqz	s11,1bdc <_etoa+0x424>
    fwidth = 0U;
    1bd8:	00012a23          	sw	zero,20(sp)
  if (expval) {
    1bdc:	020d0663          	beqz	s10,1c08 <_etoa+0x450>
    value /= conv.F;
    1be0:	01812703          	lw	a4,24(sp)
    1be4:	01c12783          	lw	a5,28(sp)
    1be8:	00070613          	mv	a2,a4
    1bec:	00078693          	mv	a3,a5
    1bf0:	01012703          	lw	a4,16(sp)
    1bf4:	00070513          	mv	a0,a4
    1bf8:	000c8593          	mv	a1,s9
    1bfc:	2a4020ef          	jal	3ea0 <__divdf3>
    1c00:	00a12823          	sw	a0,16(sp)
    1c04:	00058c93          	mv	s9,a1
  idx = _ftoa(out, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);
    1c08:	00000613          	li	a2,0
    1c0c:	00000693          	li	a3,0
    1c10:	00048513          	mv	a0,s1
    1c14:	00040593          	mv	a1,s0
    1c18:	3a5020ef          	jal	47bc <__ledf2>
    1c1c:	0a054c63          	bltz	a0,1cd4 <_etoa+0x51c>
    1c20:	fffff7b7          	lui	a5,0xfffff
    1c24:	7ff78793          	addi	a5,a5,2047 # fffff7ff <__freertos_irq_stack_top+0xffff87cf>
    1c28:	00fc77b3          	and	a5,s8,a5
    1c2c:	00f12023          	sw	a5,0(sp)
    1c30:	01412883          	lw	a7,20(sp)
    1c34:	000b8813          	mv	a6,s7
    1c38:	01012603          	lw	a2,16(sp)
    1c3c:	00060713          	mv	a4,a2
    1c40:	000c8793          	mv	a5,s9
    1c44:	000a0693          	mv	a3,s4
    1c48:	000b0613          	mv	a2,s6
    1c4c:	00098593          	mv	a1,s3
    1c50:	00090513          	mv	a0,s2
    1c54:	0d8000ef          	jal	1d2c <_ftoa>
  if (minwidth) {
    1c58:	0c0d8263          	beqz	s11,1d1c <_etoa+0x564>
    out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
    1c5c:	020c7c13          	andi	s8,s8,32
    1c60:	080c0063          	beqz	s8,1ce0 <_etoa+0x528>
    1c64:	04500793          	li	a5,69
    1c68:	00150413          	addi	s0,a0,1
    1c6c:	000a0693          	mv	a3,s4
    1c70:	00050613          	mv	a2,a0
    1c74:	00098593          	mv	a1,s3
    1c78:	00078513          	mv	a0,a5
    1c7c:	000900e7          	jalr	s2
    idx = _ntoa_long(out, buffer, idx, maxlen, (expval < 0) ? -expval : expval, expval < 0, 10, 0, minwidth-1, FLAGS_ZEROPAD | FLAGS_PLUS);
    1c80:	41fd5713          	srai	a4,s10,0x1f
    1c84:	01a746b3          	xor	a3,a4,s10
    1c88:	00500793          	li	a5,5
    1c8c:	00f12223          	sw	a5,4(sp)
    1c90:	fffd8d93          	addi	s11,s11,-1
    1c94:	01b12023          	sw	s11,0(sp)
    1c98:	00000893          	li	a7,0
    1c9c:	00a00813          	li	a6,10
    1ca0:	01fd5793          	srli	a5,s10,0x1f
    1ca4:	40e68733          	sub	a4,a3,a4
    1ca8:	000a0693          	mv	a3,s4
    1cac:	00040613          	mv	a2,s0
    1cb0:	00098593          	mv	a1,s3
    1cb4:	00090513          	mv	a0,s2
    1cb8:	8a5ff0ef          	jal	155c <_ntoa_long>
    if (flags & FLAGS_LEFT) {
    1cbc:	02012783          	lw	a5,32(sp)
    1cc0:	04079263          	bnez	a5,1d04 <_etoa+0x54c>
    1cc4:	04412c83          	lw	s9,68(sp)
    1cc8:	04012d03          	lw	s10,64(sp)
    1ccc:	03c12d83          	lw	s11,60(sp)
    1cd0:	e79ff06f          	j	1b48 <_etoa+0x390>
  idx = _ftoa(out, buffer, idx, maxlen, negative ? -value : value, prec, fwidth, flags & ~FLAGS_ADAPT_EXP);
    1cd4:	800007b7          	lui	a5,0x80000
    1cd8:	0197ccb3          	xor	s9,a5,s9
    1cdc:	f45ff06f          	j	1c20 <_etoa+0x468>
    out((flags & FLAGS_UPPERCASE) ? 'E' : 'e', buffer, idx++, maxlen);
    1ce0:	06500793          	li	a5,101
    1ce4:	f85ff06f          	j	1c68 <_etoa+0x4b0>
      while (idx - start_idx < width) out(' ', buffer, idx++, maxlen);
    1ce8:	00150413          	addi	s0,a0,1
    1cec:	000a0693          	mv	a3,s4
    1cf0:	00050613          	mv	a2,a0
    1cf4:	00098593          	mv	a1,s3
    1cf8:	02000513          	li	a0,32
    1cfc:	000900e7          	jalr	s2
    1d00:	00040513          	mv	a0,s0
    1d04:	416507b3          	sub	a5,a0,s6
    1d08:	ff57e0e3          	bltu	a5,s5,1ce8 <_etoa+0x530>
    1d0c:	04412c83          	lw	s9,68(sp)
    1d10:	04012d03          	lw	s10,64(sp)
    1d14:	03c12d83          	lw	s11,60(sp)
    1d18:	e31ff06f          	j	1b48 <_etoa+0x390>
    1d1c:	04412c83          	lw	s9,68(sp)
    1d20:	04012d03          	lw	s10,64(sp)
    1d24:	03c12d83          	lw	s11,60(sp)
    1d28:	e21ff06f          	j	1b48 <_etoa+0x390>

00001d2c <_ftoa>:
{
    1d2c:	f7010113          	addi	sp,sp,-144
    1d30:	08112623          	sw	ra,140(sp)
    1d34:	08912223          	sw	s1,132(sp)
    1d38:	07312e23          	sw	s3,124(sp)
    1d3c:	07412c23          	sw	s4,120(sp)
    1d40:	07612823          	sw	s6,112(sp)
    1d44:	07712623          	sw	s7,108(sp)
    1d48:	07812423          	sw	s8,104(sp)
    1d4c:	07912223          	sw	s9,100(sp)
    1d50:	07a12023          	sw	s10,96(sp)
    1d54:	05b12e23          	sw	s11,92(sp)
    1d58:	00050b93          	mv	s7,a0
    1d5c:	00058c13          	mv	s8,a1
    1d60:	00060c93          	mv	s9,a2
    1d64:	00068d13          	mv	s10,a3
    1d68:	00070a13          	mv	s4,a4
    1d6c:	00078993          	mv	s3,a5
    1d70:	00080493          	mv	s1,a6
    1d74:	00088b13          	mv	s6,a7
    1d78:	09012d83          	lw	s11,144(sp)
  if (value != value)
    1d7c:	00070613          	mv	a2,a4
    1d80:	00078693          	mv	a3,a5
    1d84:	00070513          	mv	a0,a4
    1d88:	00078593          	mv	a1,a5
    1d8c:	0a5020ef          	jal	4630 <__eqdf2>
    1d90:	0c051463          	bnez	a0,1e58 <_ftoa+0x12c>
  if (value < -DBL_MAX)
    1d94:	8181a603          	lw	a2,-2024(gp) # 5f88 <__clz_tab+0x108>
    1d98:	81c1a683          	lw	a3,-2020(gp) # 5f8c <__clz_tab+0x10c>
    1d9c:	000a0513          	mv	a0,s4
    1da0:	00098593          	mv	a1,s3
    1da4:	219020ef          	jal	47bc <__ledf2>
    1da8:	0c054e63          	bltz	a0,1e84 <_ftoa+0x158>
  if (value > DBL_MAX)
    1dac:	8101a603          	lw	a2,-2032(gp) # 5f80 <__clz_tab+0x100>
    1db0:	8141a683          	lw	a3,-2028(gp) # 5f84 <__clz_tab+0x104>
    1db4:	000a0513          	mv	a0,s4
    1db8:	00098593          	mv	a1,s3
    1dbc:	101020ef          	jal	46bc <__gedf2>
    1dc0:	0ea04863          	bgtz	a0,1eb0 <_ftoa+0x184>
  if ((value > PRINTF_MAX_FLOAT) || (value < -PRINTF_MAX_FLOAT)) {
    1dc4:	8981a603          	lw	a2,-1896(gp) # 6008 <__clz_tab+0x188>
    1dc8:	89c1a683          	lw	a3,-1892(gp) # 600c <__clz_tab+0x18c>
    1dcc:	000a0513          	mv	a0,s4
    1dd0:	00098593          	mv	a1,s3
    1dd4:	0e9020ef          	jal	46bc <__gedf2>
    1dd8:	12a04263          	bgtz	a0,1efc <_ftoa+0x1d0>
    1ddc:	8a01a603          	lw	a2,-1888(gp) # 6010 <__clz_tab+0x190>
    1de0:	8a41a683          	lw	a3,-1884(gp) # 6014 <__clz_tab+0x194>
    1de4:	000a0513          	mv	a0,s4
    1de8:	00098593          	mv	a1,s3
    1dec:	1d1020ef          	jal	47bc <__ledf2>
    1df0:	10054663          	bltz	a0,1efc <_ftoa+0x1d0>
    1df4:	08812423          	sw	s0,136(sp)
    1df8:	09212023          	sw	s2,128(sp)
    1dfc:	07512a23          	sw	s5,116(sp)
  if (value < 0) {
    1e00:	00000613          	li	a2,0
    1e04:	00000693          	li	a3,0
    1e08:	000a0513          	mv	a0,s4
    1e0c:	00098593          	mv	a1,s3
    1e10:	1ad020ef          	jal	47bc <__ledf2>
    1e14:	10054a63          	bltz	a0,1f28 <_ftoa+0x1fc>
  bool negative = false;
    1e18:	02012223          	sw	zero,36(sp)
  if (!(flags & FLAGS_PRECISION)) {
    1e1c:	400df793          	andi	a5,s11,1024
    1e20:	12078863          	beqz	a5,1f50 <_ftoa+0x224>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1e24:	00000413          	li	s0,0
  while ((len < PRINTF_FTOA_BUFFER_SIZE) && (prec > 9U)) {
    1e28:	01f00793          	li	a5,31
    1e2c:	1287e663          	bltu	a5,s0,1f58 <_ftoa+0x22c>
    1e30:	00900793          	li	a5,9
    1e34:	1297f263          	bgeu	a5,s1,1f58 <_ftoa+0x22c>
    buf[len++] = '0';
    1e38:	03040793          	addi	a5,s0,48
    1e3c:	02010713          	addi	a4,sp,32
    1e40:	00e787b3          	add	a5,a5,a4
    1e44:	03000713          	li	a4,48
    1e48:	fee78023          	sb	a4,-32(a5) # 7fffffe0 <__freertos_irq_stack_top+0x7fff8fb0>
    prec--;
    1e4c:	fff48493          	addi	s1,s1,-1
    buf[len++] = '0';
    1e50:	00140413          	addi	s0,s0,1
    1e54:	fd5ff06f          	j	1e28 <_ftoa+0xfc>
    return _out_rev(out, buffer, idx, maxlen, "nan", 3, width, flags);
    1e58:	000d8893          	mv	a7,s11
    1e5c:	000b0813          	mv	a6,s6
    1e60:	00300793          	li	a5,3
    1e64:	00006737          	lui	a4,0x6
    1e68:	bac70713          	addi	a4,a4,-1108 # 5bac <_data+0xc>
    1e6c:	000d0693          	mv	a3,s10
    1e70:	000c8613          	mv	a2,s9
    1e74:	000c0593          	mv	a1,s8
    1e78:	000b8513          	mv	a0,s7
    1e7c:	c14ff0ef          	jal	1290 <_out_rev>
    1e80:	33c0006f          	j	21bc <_ftoa+0x490>
    return _out_rev(out, buffer, idx, maxlen, "fni-", 4, width, flags);
    1e84:	000d8893          	mv	a7,s11
    1e88:	000b0813          	mv	a6,s6
    1e8c:	00400793          	li	a5,4
    1e90:	00006737          	lui	a4,0x6
    1e94:	bb070713          	addi	a4,a4,-1104 # 5bb0 <_data+0x10>
    1e98:	000d0693          	mv	a3,s10
    1e9c:	000c8613          	mv	a2,s9
    1ea0:	000c0593          	mv	a1,s8
    1ea4:	000b8513          	mv	a0,s7
    1ea8:	be8ff0ef          	jal	1290 <_out_rev>
    1eac:	3100006f          	j	21bc <_ftoa+0x490>
    return _out_rev(out, buffer, idx, maxlen, (flags & FLAGS_PLUS) ? "fni+" : "fni", (flags & FLAGS_PLUS) ? 4U : 3U, width, flags);
    1eb0:	004df793          	andi	a5,s11,4
    1eb4:	02078a63          	beqz	a5,1ee8 <_ftoa+0x1bc>
    1eb8:	00006737          	lui	a4,0x6
    1ebc:	ba070713          	addi	a4,a4,-1120 # 5ba0 <_data>
    1ec0:	02078a63          	beqz	a5,1ef4 <_ftoa+0x1c8>
    1ec4:	00400793          	li	a5,4
    1ec8:	000d8893          	mv	a7,s11
    1ecc:	000b0813          	mv	a6,s6
    1ed0:	000d0693          	mv	a3,s10
    1ed4:	000c8613          	mv	a2,s9
    1ed8:	000c0593          	mv	a1,s8
    1edc:	000b8513          	mv	a0,s7
    1ee0:	bb0ff0ef          	jal	1290 <_out_rev>
    1ee4:	2d80006f          	j	21bc <_ftoa+0x490>
    1ee8:	00006737          	lui	a4,0x6
    1eec:	ba870713          	addi	a4,a4,-1112 # 5ba8 <_data+0x8>
    1ef0:	fd1ff06f          	j	1ec0 <_ftoa+0x194>
    1ef4:	00300793          	li	a5,3
    1ef8:	fd1ff06f          	j	1ec8 <_ftoa+0x19c>
    return _etoa(out, buffer, idx, maxlen, value, prec, width, flags);
    1efc:	01b12023          	sw	s11,0(sp)
    1f00:	000b0893          	mv	a7,s6
    1f04:	00048813          	mv	a6,s1
    1f08:	000a0713          	mv	a4,s4
    1f0c:	00098793          	mv	a5,s3
    1f10:	000d0693          	mv	a3,s10
    1f14:	000c8613          	mv	a2,s9
    1f18:	000c0593          	mv	a1,s8
    1f1c:	000b8513          	mv	a0,s7
    1f20:	899ff0ef          	jal	17b8 <_etoa>
    1f24:	2980006f          	j	21bc <_ftoa+0x490>
    value = 0 - value;
    1f28:	000a0613          	mv	a2,s4
    1f2c:	00098693          	mv	a3,s3
    1f30:	00000513          	li	a0,0
    1f34:	00000593          	li	a1,0
    1f38:	064030ef          	jal	4f9c <__subdf3>
    1f3c:	00050a13          	mv	s4,a0
    1f40:	00058993          	mv	s3,a1
    negative = true;
    1f44:	00100793          	li	a5,1
    1f48:	02f12223          	sw	a5,36(sp)
    1f4c:	ed1ff06f          	j	1e1c <_ftoa+0xf0>
    prec = PRINTF_DEFAULT_FLOAT_PRECISION;
    1f50:	00400493          	li	s1,4
    1f54:	ed1ff06f          	j	1e24 <_ftoa+0xf8>
  int whole = (int)value;
    1f58:	000a0513          	mv	a0,s4
    1f5c:	00098593          	mv	a1,s3
    1f60:	145030ef          	jal	58a4 <__fixdfsi>
    1f64:	00050913          	mv	s2,a0
  double tmp = (value - whole) * pow10[prec];
    1f68:	235030ef          	jal	599c <__floatsidf>
    1f6c:	00050613          	mv	a2,a0
    1f70:	00058693          	mv	a3,a1
    1f74:	000a0513          	mv	a0,s4
    1f78:	00098593          	mv	a1,s3
    1f7c:	020030ef          	jal	4f9c <__subdf3>
    1f80:	000067b7          	lui	a5,0x6
    1f84:	00349713          	slli	a4,s1,0x3
    1f88:	df078793          	addi	a5,a5,-528 # 5df0 <pow10.0>
    1f8c:	00e787b3          	add	a5,a5,a4
    1f90:	0047a803          	lw	a6,4(a5)
    1f94:	0007a783          	lw	a5,0(a5)
    1f98:	02f12423          	sw	a5,40(sp)
    1f9c:	03012623          	sw	a6,44(sp)
    1fa0:	00078613          	mv	a2,a5
    1fa4:	00080693          	mv	a3,a6
    1fa8:	11d020ef          	jal	48c4 <__muldf3>
    1fac:	00a12e23          	sw	a0,28(sp)
    1fb0:	02b12023          	sw	a1,32(sp)
  unsigned long frac = (unsigned long)tmp;
    1fb4:	175030ef          	jal	5928 <__fixunsdfsi>
    1fb8:	00050a93          	mv	s5,a0
  diff = tmp - frac;
    1fbc:	299030ef          	jal	5a54 <__floatunsidf>
    1fc0:	00050613          	mv	a2,a0
    1fc4:	00058693          	mv	a3,a1
    1fc8:	01c12503          	lw	a0,28(sp)
    1fcc:	02012583          	lw	a1,32(sp)
    1fd0:	7cd020ef          	jal	4f9c <__subdf3>
    1fd4:	00a12e23          	sw	a0,28(sp)
    1fd8:	02b12023          	sw	a1,32(sp)
  if (diff > 0.5) {
    1fdc:	8481a603          	lw	a2,-1976(gp) # 5fb8 <__clz_tab+0x138>
    1fe0:	84c1a683          	lw	a3,-1972(gp) # 5fbc <__clz_tab+0x13c>
    1fe4:	6d8020ef          	jal	46bc <__gedf2>
    1fe8:	06a05863          	blez	a0,2058 <_ftoa+0x32c>
    ++frac;
    1fec:	001a8a93          	addi	s5,s5,1
    if (frac >= pow10[prec]) {
    1ff0:	000a8513          	mv	a0,s5
    1ff4:	261030ef          	jal	5a54 <__floatunsidf>
    1ff8:	00050613          	mv	a2,a0
    1ffc:	00058693          	mv	a3,a1
    2000:	02812503          	lw	a0,40(sp)
    2004:	02c12583          	lw	a1,44(sp)
    2008:	7b4020ef          	jal	47bc <__ledf2>
    200c:	00a04663          	bgtz	a0,2018 <_ftoa+0x2ec>
      ++whole;
    2010:	00190913          	addi	s2,s2,1
      frac = 0;
    2014:	00000a93          	li	s5,0
  if (prec == 0U) {
    2018:	06049663          	bnez	s1,2084 <_ftoa+0x358>
    diff = value - (double)whole;
    201c:	00090513          	mv	a0,s2
    2020:	17d030ef          	jal	599c <__floatsidf>
    2024:	00050613          	mv	a2,a0
    2028:	00058693          	mv	a3,a1
    202c:	000a0513          	mv	a0,s4
    2030:	00098593          	mv	a1,s3
    2034:	769020ef          	jal	4f9c <__subdf3>
    if ((!(diff < 0.5) || (diff > 0.5)) && (whole & 1)) {
    2038:	8481a603          	lw	a2,-1976(gp) # 5fb8 <__clz_tab+0x138>
    203c:	84c1a683          	lw	a3,-1972(gp) # 5fbc <__clz_tab+0x13c>
    2040:	77c020ef          	jal	47bc <__ledf2>
    2044:	0c054c63          	bltz	a0,211c <_ftoa+0x3f0>
    2048:	00197793          	andi	a5,s2,1
    204c:	0c078863          	beqz	a5,211c <_ftoa+0x3f0>
      ++whole;
    2050:	00190913          	addi	s2,s2,1
    2054:	0c80006f          	j	211c <_ftoa+0x3f0>
  else if (diff < 0.5) {
    2058:	8481a603          	lw	a2,-1976(gp) # 5fb8 <__clz_tab+0x138>
    205c:	84c1a683          	lw	a3,-1972(gp) # 5fbc <__clz_tab+0x13c>
    2060:	01c12503          	lw	a0,28(sp)
    2064:	02012583          	lw	a1,32(sp)
    2068:	754020ef          	jal	47bc <__ledf2>
    206c:	fa0546e3          	bltz	a0,2018 <_ftoa+0x2ec>
  else if ((frac == 0U) || (frac & 1U)) {
    2070:	000a8663          	beqz	s5,207c <_ftoa+0x350>
    2074:	001af793          	andi	a5,s5,1
    2078:	fa0780e3          	beqz	a5,2018 <_ftoa+0x2ec>
    ++frac;
    207c:	001a8a93          	addi	s5,s5,1
    2080:	f99ff06f          	j	2018 <_ftoa+0x2ec>
    while (len < PRINTF_FTOA_BUFFER_SIZE) {
    2084:	01f00793          	li	a5,31
    2088:	0487e263          	bltu	a5,s0,20cc <_ftoa+0x3a0>
      --count;
    208c:	fff48493          	addi	s1,s1,-1
      buf[len++] = (char)(48U + (frac % 10U));
    2090:	00a00793          	li	a5,10
    2094:	02faf733          	remu	a4,s5,a5
    2098:	00140693          	addi	a3,s0,1
    209c:	03070713          	addi	a4,a4,48
    20a0:	03040613          	addi	a2,s0,48
    20a4:	02010593          	addi	a1,sp,32
    20a8:	00b60433          	add	s0,a2,a1
    20ac:	fee40023          	sb	a4,-32(s0)
      if (!(frac /= 10U)) {
    20b0:	02fad7b3          	divu	a5,s5,a5
    20b4:	00900713          	li	a4,9
    20b8:	01577863          	bgeu	a4,s5,20c8 <_ftoa+0x39c>
    20bc:	00078a93          	mv	s5,a5
      buf[len++] = (char)(48U + (frac % 10U));
    20c0:	00068413          	mv	s0,a3
    20c4:	fc1ff06f          	j	2084 <_ftoa+0x358>
    20c8:	00068413          	mv	s0,a3
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
    20cc:	01f00793          	li	a5,31
    20d0:	0287e663          	bltu	a5,s0,20fc <_ftoa+0x3d0>
    20d4:	fff48793          	addi	a5,s1,-1
    20d8:	02048263          	beqz	s1,20fc <_ftoa+0x3d0>
      buf[len++] = '0';
    20dc:	03040713          	addi	a4,s0,48
    20e0:	02010693          	addi	a3,sp,32
    20e4:	00d70733          	add	a4,a4,a3
    20e8:	03000693          	li	a3,48
    20ec:	fed70023          	sb	a3,-32(a4)
    while ((len < PRINTF_FTOA_BUFFER_SIZE) && (count-- > 0U)) {
    20f0:	00078493          	mv	s1,a5
      buf[len++] = '0';
    20f4:	00140413          	addi	s0,s0,1
    20f8:	fd5ff06f          	j	20cc <_ftoa+0x3a0>
    if (len < PRINTF_FTOA_BUFFER_SIZE) {
    20fc:	01f00793          	li	a5,31
    2100:	0087ee63          	bltu	a5,s0,211c <_ftoa+0x3f0>
      buf[len++] = '.';
    2104:	03040793          	addi	a5,s0,48
    2108:	02010713          	addi	a4,sp,32
    210c:	00e787b3          	add	a5,a5,a4
    2110:	02e00713          	li	a4,46
    2114:	fee78023          	sb	a4,-32(a5)
    2118:	00140413          	addi	s0,s0,1
  while (len < PRINTF_FTOA_BUFFER_SIZE) {
    211c:	01f00793          	li	a5,31
    2120:	0287ec63          	bltu	a5,s0,2158 <_ftoa+0x42c>
    buf[len++] = (char)(48 + (whole % 10));
    2124:	00a00713          	li	a4,10
    2128:	02e967b3          	rem	a5,s2,a4
    212c:	00140693          	addi	a3,s0,1
    2130:	03078793          	addi	a5,a5,48
    2134:	03040613          	addi	a2,s0,48
    2138:	02010593          	addi	a1,sp,32
    213c:	00b60433          	add	s0,a2,a1
    2140:	fef40023          	sb	a5,-32(s0)
    if (!(whole /= 10)) {
    2144:	02e94933          	div	s2,s2,a4
    2148:	00090663          	beqz	s2,2154 <_ftoa+0x428>
    buf[len++] = (char)(48 + (whole % 10));
    214c:	00068413          	mv	s0,a3
    2150:	fcdff06f          	j	211c <_ftoa+0x3f0>
    2154:	00068413          	mv	s0,a3
  if (!(flags & FLAGS_LEFT) && (flags & FLAGS_ZEROPAD)) {
    2158:	003df713          	andi	a4,s11,3
    215c:	00100793          	li	a5,1
    2160:	08f70663          	beq	a4,a5,21ec <_ftoa+0x4c0>
  if (len < PRINTF_FTOA_BUFFER_SIZE) {
    2164:	01f00793          	li	a5,31
    2168:	0287e263          	bltu	a5,s0,218c <_ftoa+0x460>
    if (negative) {
    216c:	02412783          	lw	a5,36(sp)
    2170:	0c078063          	beqz	a5,2230 <_ftoa+0x504>
      buf[len++] = '-';
    2174:	03040793          	addi	a5,s0,48
    2178:	02010713          	addi	a4,sp,32
    217c:	00e787b3          	add	a5,a5,a4
    2180:	02d00713          	li	a4,45
    2184:	fee78023          	sb	a4,-32(a5)
    2188:	00140413          	addi	s0,s0,1
  return _out_rev(out, buffer, idx, maxlen, buf, len, width, flags);
    218c:	000d8893          	mv	a7,s11
    2190:	000b0813          	mv	a6,s6
    2194:	00040793          	mv	a5,s0
    2198:	03010713          	addi	a4,sp,48
    219c:	000d0693          	mv	a3,s10
    21a0:	000c8613          	mv	a2,s9
    21a4:	000c0593          	mv	a1,s8
    21a8:	000b8513          	mv	a0,s7
    21ac:	8e4ff0ef          	jal	1290 <_out_rev>
    21b0:	08812403          	lw	s0,136(sp)
    21b4:	08012903          	lw	s2,128(sp)
    21b8:	07412a83          	lw	s5,116(sp)
}
    21bc:	08c12083          	lw	ra,140(sp)
    21c0:	08412483          	lw	s1,132(sp)
    21c4:	07c12983          	lw	s3,124(sp)
    21c8:	07812a03          	lw	s4,120(sp)
    21cc:	07012b03          	lw	s6,112(sp)
    21d0:	06c12b83          	lw	s7,108(sp)
    21d4:	06812c03          	lw	s8,104(sp)
    21d8:	06412c83          	lw	s9,100(sp)
    21dc:	06012d03          	lw	s10,96(sp)
    21e0:	05c12d83          	lw	s11,92(sp)
    21e4:	09010113          	addi	sp,sp,144
    21e8:	00008067          	ret
    if (width && (negative || (flags & (FLAGS_PLUS | FLAGS_SPACE)))) {
    21ec:	020b0a63          	beqz	s6,2220 <_ftoa+0x4f4>
    21f0:	02412783          	lw	a5,36(sp)
    21f4:	00079663          	bnez	a5,2200 <_ftoa+0x4d4>
    21f8:	00cdf793          	andi	a5,s11,12
    21fc:	02078263          	beqz	a5,2220 <_ftoa+0x4f4>
      width--;
    2200:	fffb0b13          	addi	s6,s6,-1
    2204:	01c0006f          	j	2220 <_ftoa+0x4f4>
      buf[len++] = '0';
    2208:	03040793          	addi	a5,s0,48
    220c:	02010713          	addi	a4,sp,32
    2210:	00e787b3          	add	a5,a5,a4
    2214:	03000713          	li	a4,48
    2218:	fee78023          	sb	a4,-32(a5)
    221c:	00140413          	addi	s0,s0,1
    while ((len < width) && (len < PRINTF_FTOA_BUFFER_SIZE)) {
    2220:	f56472e3          	bgeu	s0,s6,2164 <_ftoa+0x438>
    2224:	01f00793          	li	a5,31
    2228:	fe87f0e3          	bgeu	a5,s0,2208 <_ftoa+0x4dc>
    222c:	f39ff06f          	j	2164 <_ftoa+0x438>
    else if (flags & FLAGS_PLUS) {
    2230:	004df793          	andi	a5,s11,4
    2234:	02078063          	beqz	a5,2254 <_ftoa+0x528>
      buf[len++] = '+';  // ignore the space if the '+' exists
    2238:	03040793          	addi	a5,s0,48
    223c:	02010713          	addi	a4,sp,32
    2240:	00e787b3          	add	a5,a5,a4
    2244:	02b00713          	li	a4,43
    2248:	fee78023          	sb	a4,-32(a5)
    224c:	00140413          	addi	s0,s0,1
    2250:	f3dff06f          	j	218c <_ftoa+0x460>
    else if (flags & FLAGS_SPACE) {
    2254:	008df793          	andi	a5,s11,8
    2258:	f2078ae3          	beqz	a5,218c <_ftoa+0x460>
      buf[len++] = ' ';
    225c:	03040793          	addi	a5,s0,48
    2260:	02010713          	addi	a4,sp,32
    2264:	00e787b3          	add	a5,a5,a4
    2268:	02000713          	li	a4,32
    226c:	fee78023          	sb	a4,-32(a5)
    2270:	00140413          	addi	s0,s0,1
    2274:	f19ff06f          	j	218c <_ftoa+0x460>

00002278 <_vsnprintf>:
*                 terminating null character), or a negative value if an error
*                 occurred.
*
******************************************************************************/
static int _vsnprintf(out_fct_type out, char* buffer, const size_t maxlen, const char* format, va_list va)
{
    2278:	fb010113          	addi	sp,sp,-80
    227c:	04112623          	sw	ra,76(sp)
    2280:	04812423          	sw	s0,72(sp)
    2284:	04912223          	sw	s1,68(sp)
    2288:	05212023          	sw	s2,64(sp)
    228c:	03312e23          	sw	s3,60(sp)
    2290:	03412c23          	sw	s4,56(sp)
    2294:	03512a23          	sw	s5,52(sp)
    2298:	03612823          	sw	s6,48(sp)
    229c:	00050a13          	mv	s4,a0
    22a0:	00058993          	mv	s3,a1
    22a4:	00060913          	mv	s2,a2
    22a8:	00d12e23          	sw	a3,28(sp)
    22ac:	00e12c23          	sw	a4,24(sp)
  unsigned int flags, width, precision, n;
  size_t idx = 0U;

  if (!buffer) {
    22b0:	140584e3          	beqz	a1,2bf8 <_vsnprintf+0x980>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
          }
        }
        format++;
        break;
    22b4:	00000493          	li	s1,0
  while (*format)
    22b8:	01c12783          	lw	a5,28(sp)
    22bc:	0007c503          	lbu	a0,0(a5)
    22c0:	140502e3          	beqz	a0,2c04 <_vsnprintf+0x98c>
    if (*format != '%') {
    22c4:	02500713          	li	a4,37
    22c8:	02e50663          	beq	a0,a4,22f4 <_vsnprintf+0x7c>
      out(*format, buffer, idx++, maxlen);
    22cc:	00148413          	addi	s0,s1,1
    22d0:	00090693          	mv	a3,s2
    22d4:	00048613          	mv	a2,s1
    22d8:	00098593          	mv	a1,s3
    22dc:	000a00e7          	jalr	s4
      format++;
    22e0:	01c12783          	lw	a5,28(sp)
    22e4:	00178793          	addi	a5,a5,1
    22e8:	00f12e23          	sw	a5,28(sp)
      out(*format, buffer, idx++, maxlen);
    22ec:	00040493          	mv	s1,s0
      continue;
    22f0:	fc9ff06f          	j	22b8 <_vsnprintf+0x40>
      format++;
    22f4:	00178793          	addi	a5,a5,1
    22f8:	00f12e23          	sw	a5,28(sp)
    flags = 0U;
    22fc:	00000413          	li	s0,0
    2300:	0700006f          	j	2370 <_vsnprintf+0xf8>
        case '0': flags |= FLAGS_ZEROPAD; format++; n = 1U; break;
    2304:	00146413          	ori	s0,s0,1
    2308:	00170713          	addi	a4,a4,1
    230c:	00e12e23          	sw	a4,28(sp)
    2310:	00100a93          	li	s5,1
    2314:	0580006f          	j	236c <_vsnprintf+0xf4>
        case '-': flags |= FLAGS_LEFT;    format++; n = 1U; break;
    2318:	00246413          	ori	s0,s0,2
    231c:	00170713          	addi	a4,a4,1
    2320:	00e12e23          	sw	a4,28(sp)
    2324:	00100a93          	li	s5,1
    2328:	0440006f          	j	236c <_vsnprintf+0xf4>
        case '+': flags |= FLAGS_PLUS;    format++; n = 1U; break;
    232c:	00446413          	ori	s0,s0,4
    2330:	00170713          	addi	a4,a4,1
    2334:	00e12e23          	sw	a4,28(sp)
    2338:	00100a93          	li	s5,1
    233c:	0300006f          	j	236c <_vsnprintf+0xf4>
        case ' ': flags |= FLAGS_SPACE;   format++; n = 1U; break;
    2340:	00846413          	ori	s0,s0,8
    2344:	00170713          	addi	a4,a4,1
    2348:	00e12e23          	sw	a4,28(sp)
    234c:	00100a93          	li	s5,1
    2350:	01c0006f          	j	236c <_vsnprintf+0xf4>
        case '#': flags |= FLAGS_HASH;    format++; n = 1U; break;
    2354:	01046413          	ori	s0,s0,16
    2358:	00170713          	addi	a4,a4,1
    235c:	00e12e23          	sw	a4,28(sp)
    2360:	00100a93          	li	s5,1
    2364:	0080006f          	j	236c <_vsnprintf+0xf4>
      switch (*format) {
    2368:	00000a93          	li	s5,0
    } while (n);
    236c:	020a8a63          	beqz	s5,23a0 <_vsnprintf+0x128>
      switch (*format) {
    2370:	01c12703          	lw	a4,28(sp)
    2374:	00074783          	lbu	a5,0(a4)
    2378:	fe078793          	addi	a5,a5,-32
    237c:	0ff7f613          	zext.b	a2,a5
    2380:	01000693          	li	a3,16
    2384:	fec6e2e3          	bltu	a3,a2,2368 <_vsnprintf+0xf0>
    2388:	00261793          	slli	a5,a2,0x2
    238c:	000066b7          	lui	a3,0x6
    2390:	c5068693          	addi	a3,a3,-944 # 5c50 <_data+0xb0>
    2394:	00d787b3          	add	a5,a5,a3
    2398:	0007a783          	lw	a5,0(a5)
    239c:	00078067          	jr	a5
    if (_is_digit(*format)) {
    23a0:	01c12783          	lw	a5,28(sp)
    23a4:	0007c703          	lbu	a4,0(a5)
  return (ch >= '0') && (ch <= '9');
    23a8:	fd070793          	addi	a5,a4,-48
    23ac:	0ff7f793          	zext.b	a5,a5
    if (_is_digit(*format)) {
    23b0:	00900693          	li	a3,9
    23b4:	04f6f863          	bgeu	a3,a5,2404 <_vsnprintf+0x18c>
    else if (*format == '*') {
    23b8:	02a00793          	li	a5,42
    23bc:	04f70c63          	beq	a4,a5,2414 <_vsnprintf+0x19c>
    width = 0U;
    23c0:	000a8b13          	mv	s6,s5
    if (*format == '.') {
    23c4:	01c12783          	lw	a5,28(sp)
    23c8:	0007c683          	lbu	a3,0(a5)
    23cc:	02e00713          	li	a4,46
    23d0:	06e68a63          	beq	a3,a4,2444 <_vsnprintf+0x1cc>
    switch (*format) {
    23d4:	01c12703          	lw	a4,28(sp)
    23d8:	00074783          	lbu	a5,0(a4)
    23dc:	f9878793          	addi	a5,a5,-104
    23e0:	0ff7f613          	zext.b	a2,a5
    23e4:	01200693          	li	a3,18
    23e8:	12c6e663          	bltu	a3,a2,2514 <_vsnprintf+0x29c>
    23ec:	00261793          	slli	a5,a2,0x2
    23f0:	000066b7          	lui	a3,0x6
    23f4:	c9468693          	addi	a3,a3,-876 # 5c94 <_data+0xf4>
    23f8:	00d787b3          	add	a5,a5,a3
    23fc:	0007a783          	lw	a5,0(a5)
    2400:	00078067          	jr	a5
      width = _atoi(&format);
    2404:	01c10513          	addi	a0,sp,28
    2408:	e41fe0ef          	jal	1248 <_atoi>
    240c:	00050b13          	mv	s6,a0
    2410:	fb5ff06f          	j	23c4 <_vsnprintf+0x14c>
      const int w = va_arg(va, int);
    2414:	01812783          	lw	a5,24(sp)
    2418:	00478713          	addi	a4,a5,4
    241c:	00e12c23          	sw	a4,24(sp)
    2420:	0007ab03          	lw	s6,0(a5)
      if (w < 0) {
    2424:	000b4a63          	bltz	s6,2438 <_vsnprintf+0x1c0>
      format++;
    2428:	01c12783          	lw	a5,28(sp)
    242c:	00178793          	addi	a5,a5,1
    2430:	00f12e23          	sw	a5,28(sp)
    2434:	f91ff06f          	j	23c4 <_vsnprintf+0x14c>
        flags |= FLAGS_LEFT;    // reverse padding
    2438:	00246413          	ori	s0,s0,2
        width = (unsigned int)-w;
    243c:	41600b33          	neg	s6,s6
    2440:	fe9ff06f          	j	2428 <_vsnprintf+0x1b0>
      flags |= FLAGS_PRECISION;
    2444:	40046413          	ori	s0,s0,1024
      format++;
    2448:	00178713          	addi	a4,a5,1
    244c:	00e12e23          	sw	a4,28(sp)
      if (_is_digit(*format)) {
    2450:	0017c703          	lbu	a4,1(a5)
  return (ch >= '0') && (ch <= '9');
    2454:	fd070793          	addi	a5,a4,-48
    2458:	0ff7f793          	zext.b	a5,a5
      if (_is_digit(*format)) {
    245c:	00900693          	li	a3,9
    2460:	02f6f863          	bgeu	a3,a5,2490 <_vsnprintf+0x218>
      else if (*format == '*') {
    2464:	02a00793          	li	a5,42
    2468:	f6f716e3          	bne	a4,a5,23d4 <_vsnprintf+0x15c>
        const int prec = (int)va_arg(va, int);
    246c:	01812783          	lw	a5,24(sp)
    2470:	00478713          	addi	a4,a5,4
    2474:	00e12c23          	sw	a4,24(sp)
    2478:	0007aa83          	lw	s5,0(a5)
        precision = prec > 0 ? (unsigned int)prec : 0U;
    247c:	020ac263          	bltz	s5,24a0 <_vsnprintf+0x228>
        format++;
    2480:	01c12783          	lw	a5,28(sp)
    2484:	00178793          	addi	a5,a5,1
    2488:	00f12e23          	sw	a5,28(sp)
    248c:	f49ff06f          	j	23d4 <_vsnprintf+0x15c>
        precision = _atoi(&format);
    2490:	01c10513          	addi	a0,sp,28
    2494:	db5fe0ef          	jal	1248 <_atoi>
    2498:	00050a93          	mv	s5,a0
    249c:	f39ff06f          	j	23d4 <_vsnprintf+0x15c>
        precision = prec > 0 ? (unsigned int)prec : 0U;
    24a0:	00000a93          	li	s5,0
    24a4:	fddff06f          	j	2480 <_vsnprintf+0x208>
        flags |= FLAGS_LONG;
    24a8:	10046613          	ori	a2,s0,256
        format++;
    24ac:	00170793          	addi	a5,a4,1
    24b0:	00f12e23          	sw	a5,28(sp)
        if (*format == 'l') {
    24b4:	00174683          	lbu	a3,1(a4)
    24b8:	06c00793          	li	a5,108
    24bc:	00f68663          	beq	a3,a5,24c8 <_vsnprintf+0x250>
        flags |= FLAGS_LONG;
    24c0:	00060413          	mv	s0,a2
    24c4:	0500006f          	j	2514 <_vsnprintf+0x29c>
          flags |= FLAGS_LONG_LONG;
    24c8:	30046413          	ori	s0,s0,768
          format++;
    24cc:	00270713          	addi	a4,a4,2
    24d0:	00e12e23          	sw	a4,28(sp)
    24d4:	0400006f          	j	2514 <_vsnprintf+0x29c>
        flags |= FLAGS_SHORT;
    24d8:	08046613          	ori	a2,s0,128
        format++;
    24dc:	00170793          	addi	a5,a4,1
    24e0:	00f12e23          	sw	a5,28(sp)
        if (*format == 'h') {
    24e4:	00174683          	lbu	a3,1(a4)
    24e8:	06800793          	li	a5,104
    24ec:	00f68663          	beq	a3,a5,24f8 <_vsnprintf+0x280>
        flags |= FLAGS_SHORT;
    24f0:	00060413          	mv	s0,a2
    24f4:	0200006f          	j	2514 <_vsnprintf+0x29c>
          flags |= FLAGS_CHAR;
    24f8:	0c046413          	ori	s0,s0,192
          format++;
    24fc:	00270713          	addi	a4,a4,2
    2500:	00e12e23          	sw	a4,28(sp)
    2504:	0100006f          	j	2514 <_vsnprintf+0x29c>
        flags |= (sizeof(ptrdiff_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    2508:	10046413          	ori	s0,s0,256
        format++;
    250c:	00170713          	addi	a4,a4,1
    2510:	00e12e23          	sw	a4,28(sp)
    switch (*format) {
    2514:	01c12783          	lw	a5,28(sp)
    2518:	0007c503          	lbu	a0,0(a5)
    251c:	06700793          	li	a5,103
    2520:	04a7ea63          	bltu	a5,a0,2574 <_vsnprintf+0x2fc>
    2524:	02500793          	li	a5,37
    2528:	6af56463          	bltu	a0,a5,2bd0 <_vsnprintf+0x958>
    252c:	fdb50793          	addi	a5,a0,-37
    2530:	0ff7f693          	zext.b	a3,a5
    2534:	04200713          	li	a4,66
    2538:	68d76c63          	bltu	a4,a3,2bd0 <_vsnprintf+0x958>
    253c:	00269793          	slli	a5,a3,0x2
    2540:	00006737          	lui	a4,0x6
    2544:	ce070713          	addi	a4,a4,-800 # 5ce0 <_data+0x140>
    2548:	00e787b3          	add	a5,a5,a4
    254c:	0007a783          	lw	a5,0(a5)
    2550:	00078067          	jr	a5
        flags |= (sizeof(intmax_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    2554:	20046413          	ori	s0,s0,512
        format++;
    2558:	00170713          	addi	a4,a4,1
    255c:	00e12e23          	sw	a4,28(sp)
        break;
    2560:	fb5ff06f          	j	2514 <_vsnprintf+0x29c>
        flags |= (sizeof(size_t) == sizeof(long) ? FLAGS_LONG : FLAGS_LONG_LONG);
    2564:	10046413          	ori	s0,s0,256
        format++;
    2568:	00170713          	addi	a4,a4,1
    256c:	00e12e23          	sw	a4,28(sp)
        break;
    2570:	fa5ff06f          	j	2514 <_vsnprintf+0x29c>
    switch (*format) {
    2574:	07800793          	li	a5,120
    2578:	64a7ec63          	bltu	a5,a0,2bd0 <_vsnprintf+0x958>
    257c:	06900793          	li	a5,105
    2580:	64f56863          	bltu	a0,a5,2bd0 <_vsnprintf+0x958>
    2584:	f9750713          	addi	a4,a0,-105
    2588:	00100793          	li	a5,1
    258c:	00e797b3          	sll	a5,a5,a4
    2590:	00009737          	lui	a4,0x9
    2594:	04170713          	addi	a4,a4,65 # 9041 <__freertos_irq_stack_top+0x2011>
    2598:	00e7f733          	and	a4,a5,a4
    259c:	04071263          	bnez	a4,25e0 <_vsnprintf+0x368>
    25a0:	0807f713          	andi	a4,a5,128
    25a4:	5a071663          	bnez	a4,2b50 <_vsnprintf+0x8d8>
    25a8:	4007f793          	andi	a5,a5,1024
    25ac:	62078263          	beqz	a5,2bd0 <_vsnprintf+0x958>
    25b0:	03712623          	sw	s7,44(sp)
    25b4:	03812423          	sw	s8,40(sp)
    25b8:	03912223          	sw	s9,36(sp)
    25bc:	03a12023          	sw	s10,32(sp)
      }

      case 's' : {
        const char* p = va_arg(va, char*);
    25c0:	01812783          	lw	a5,24(sp)
    25c4:	00478713          	addi	a4,a5,4
    25c8:	00e12c23          	sw	a4,24(sp)
    25cc:	0007ab83          	lw	s7,0(a5)
        unsigned int l = _strnlen_s(p, precision ? precision : (size_t)-1);
    25d0:	4c0a9463          	bnez	s5,2a98 <_vsnprintf+0x820>
    25d4:	fff00713          	li	a4,-1
    25d8:	000b8793          	mv	a5,s7
    25dc:	4880006f          	j	2a64 <_vsnprintf+0x7ec>
        if (*format == 'x' || *format == 'X') {
    25e0:	06f00793          	li	a5,111
    25e4:	02f50a63          	beq	a0,a5,2618 <_vsnprintf+0x3a0>
    25e8:	00a7ee63          	bltu	a5,a0,2604 <_vsnprintf+0x38c>
    25ec:	05800793          	li	a5,88
    25f0:	0af50c63          	beq	a0,a5,26a8 <_vsnprintf+0x430>
    25f4:	06200793          	li	a5,98
    25f8:	00f51a63          	bne	a0,a5,260c <_vsnprintf+0x394>
        flags |= FLAGS_SHORT;
    25fc:	00200813          	li	a6,2
    2600:	01c0006f          	j	261c <_vsnprintf+0x3a4>
    2604:	07800793          	li	a5,120
    2608:	0af50463          	beq	a0,a5,26b0 <_vsnprintf+0x438>
          flags &= ~FLAGS_HASH;   // no hash for dec format
    260c:	fef47413          	andi	s0,s0,-17
          base = 10U;
    2610:	00a00813          	li	a6,10
    2614:	0080006f          	j	261c <_vsnprintf+0x3a4>
        flags |= FLAGS_SHORT;
    2618:	00800813          	li	a6,8
        if (*format == 'X') {
    261c:	05800793          	li	a5,88
    2620:	08f50c63          	beq	a0,a5,26b8 <_vsnprintf+0x440>
        if ((*format != 'i') && (*format != 'd')) {
    2624:	06900793          	li	a5,105
    2628:	00f50863          	beq	a0,a5,2638 <_vsnprintf+0x3c0>
    262c:	06400793          	li	a5,100
    2630:	00f50463          	beq	a0,a5,2638 <_vsnprintf+0x3c0>
          flags &= ~(FLAGS_PLUS | FLAGS_SPACE);
    2634:	ff347413          	andi	s0,s0,-13
        if (flags & FLAGS_PRECISION) {
    2638:	40047793          	andi	a5,s0,1024
    263c:	00078463          	beqz	a5,2644 <_vsnprintf+0x3cc>
          flags &= ~FLAGS_ZEROPAD;
    2640:	ffe47413          	andi	s0,s0,-2
        if ((*format == 'i') || (*format == 'd')) {
    2644:	06900793          	li	a5,105
    2648:	06f50c63          	beq	a0,a5,26c0 <_vsnprintf+0x448>
    264c:	06400793          	li	a5,100
    2650:	06f50863          	beq	a0,a5,26c0 <_vsnprintf+0x448>
          if (flags & FLAGS_LONG_LONG) {
    2654:	20047793          	andi	a5,s0,512
    2658:	1a079c63          	bnez	a5,2810 <_vsnprintf+0x598>
          else if (flags & FLAGS_LONG) {
    265c:	10047793          	andi	a5,s0,256
    2660:	20079063          	bnez	a5,2860 <_vsnprintf+0x5e8>
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
    2664:	04047793          	andi	a5,s0,64
    2668:	22078a63          	beqz	a5,289c <_vsnprintf+0x624>
    266c:	01812783          	lw	a5,24(sp)
    2670:	00478713          	addi	a4,a5,4
    2674:	00e12c23          	sw	a4,24(sp)
    2678:	0007c703          	lbu	a4,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, value, false, base, precision, width, flags);
    267c:	00812223          	sw	s0,4(sp)
    2680:	01612023          	sw	s6,0(sp)
    2684:	000a8893          	mv	a7,s5
    2688:	00000793          	li	a5,0
    268c:	00090693          	mv	a3,s2
    2690:	00048613          	mv	a2,s1
    2694:	00098593          	mv	a1,s3
    2698:	000a0513          	mv	a0,s4
    269c:	ec1fe0ef          	jal	155c <_ntoa_long>
    26a0:	00050493          	mv	s1,a0
    26a4:	0780006f          	j	271c <_vsnprintf+0x4a4>
          base = 10U;
    26a8:	01000813          	li	a6,16
    26ac:	f71ff06f          	j	261c <_vsnprintf+0x3a4>
        flags |= FLAGS_SHORT;
    26b0:	01000813          	li	a6,16
    26b4:	f69ff06f          	j	261c <_vsnprintf+0x3a4>
          flags |= FLAGS_UPPERCASE;
    26b8:	02046413          	ori	s0,s0,32
    26bc:	f69ff06f          	j	2624 <_vsnprintf+0x3ac>
          if (flags & FLAGS_LONG_LONG) {
    26c0:	20047793          	andi	a5,s0,512
    26c4:	06079463          	bnez	a5,272c <_vsnprintf+0x4b4>
          else if (flags & FLAGS_LONG) {
    26c8:	10047793          	andi	a5,s0,256
    26cc:	0c079663          	bnez	a5,2798 <_vsnprintf+0x520>
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
    26d0:	04047793          	andi	a5,s0,64
    26d4:	10078663          	beqz	a5,27e0 <_vsnprintf+0x568>
    26d8:	01812783          	lw	a5,24(sp)
    26dc:	00478713          	addi	a4,a5,4
    26e0:	00e12c23          	sw	a4,24(sp)
    26e4:	0007c783          	lbu	a5,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned int)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    26e8:	41f7d713          	srai	a4,a5,0x1f
    26ec:	00f746b3          	xor	a3,a4,a5
    26f0:	00812223          	sw	s0,4(sp)
    26f4:	01612023          	sw	s6,0(sp)
    26f8:	000a8893          	mv	a7,s5
    26fc:	01f7d793          	srli	a5,a5,0x1f
    2700:	40e68733          	sub	a4,a3,a4
    2704:	00090693          	mv	a3,s2
    2708:	00048613          	mv	a2,s1
    270c:	00098593          	mv	a1,s3
    2710:	000a0513          	mv	a0,s4
    2714:	e49fe0ef          	jal	155c <_ntoa_long>
    2718:	00050493          	mv	s1,a0
        format++;
    271c:	01c12783          	lw	a5,28(sp)
    2720:	00178793          	addi	a5,a5,1
    2724:	00f12e23          	sw	a5,28(sp)
        break;
    2728:	b91ff06f          	j	22b8 <_vsnprintf+0x40>
            const long long value = va_arg(va, long long);
    272c:	01812783          	lw	a5,24(sp)
    2730:	00778793          	addi	a5,a5,7
    2734:	ff87f793          	andi	a5,a5,-8
    2738:	00878713          	addi	a4,a5,8
    273c:	00e12c23          	sw	a4,24(sp)
    2740:	0007a703          	lw	a4,0(a5)
    2744:	0047a583          	lw	a1,4(a5)
            idx = _ntoa_long_long(out, buffer, idx, maxlen, (unsigned long long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
    2748:	41f5d693          	srai	a3,a1,0x1f
    274c:	00e6c7b3          	xor	a5,a3,a4
    2750:	00b6c633          	xor	a2,a3,a1
    2754:	40d78733          	sub	a4,a5,a3
    2758:	00e7b7b3          	sltu	a5,a5,a4
    275c:	40d606b3          	sub	a3,a2,a3
    2760:	00812623          	sw	s0,12(sp)
    2764:	01612423          	sw	s6,8(sp)
    2768:	01512223          	sw	s5,4(sp)
    276c:	00012023          	sw	zero,0(sp)
    2770:	00080893          	mv	a7,a6
    2774:	01f5d813          	srli	a6,a1,0x1f
    2778:	40f687b3          	sub	a5,a3,a5
    277c:	00090693          	mv	a3,s2
    2780:	00048613          	mv	a2,s1
    2784:	00098593          	mv	a1,s3
    2788:	000a0513          	mv	a0,s4
    278c:	e95fe0ef          	jal	1620 <_ntoa_long_long>
    2790:	00050493          	mv	s1,a0
    2794:	f89ff06f          	j	271c <_vsnprintf+0x4a4>
            const long value = va_arg(va, long);
    2798:	01812783          	lw	a5,24(sp)
    279c:	00478713          	addi	a4,a5,4
    27a0:	00e12c23          	sw	a4,24(sp)
    27a4:	0007a783          	lw	a5,0(a5)
            idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)(value > 0 ? value : 0 - value), value < 0, base, precision, width, flags);
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
    27d4:	d89fe0ef          	jal	155c <_ntoa_long>
    27d8:	00050493          	mv	s1,a0
    27dc:	f41ff06f          	j	271c <_vsnprintf+0x4a4>
            const int value = (flags & FLAGS_CHAR) ? (char)va_arg(va, int) : (flags & FLAGS_SHORT) ? (short int)va_arg(va, int) : va_arg(va, int);
    27e0:	08047793          	andi	a5,s0,128
    27e4:	00078c63          	beqz	a5,27fc <_vsnprintf+0x584>
    27e8:	01812783          	lw	a5,24(sp)
    27ec:	00478713          	addi	a4,a5,4
    27f0:	00e12c23          	sw	a4,24(sp)
    27f4:	00079783          	lh	a5,0(a5)
    27f8:	ef1ff06f          	j	26e8 <_vsnprintf+0x470>
    27fc:	01812783          	lw	a5,24(sp)
    2800:	00478713          	addi	a4,a5,4
    2804:	00e12c23          	sw	a4,24(sp)
    2808:	0007a783          	lw	a5,0(a5)
    280c:	eddff06f          	j	26e8 <_vsnprintf+0x470>
            idx = _ntoa_long_long(out, buffer, idx, maxlen, va_arg(va, unsigned long long), false, base, precision, width, flags);
    2810:	01812783          	lw	a5,24(sp)
    2814:	00778793          	addi	a5,a5,7
    2818:	ff87f793          	andi	a5,a5,-8
    281c:	00878713          	addi	a4,a5,8
    2820:	00e12c23          	sw	a4,24(sp)
    2824:	0007a703          	lw	a4,0(a5)
    2828:	0047a783          	lw	a5,4(a5)
    282c:	00812623          	sw	s0,12(sp)
    2830:	01612423          	sw	s6,8(sp)
    2834:	01512223          	sw	s5,4(sp)
    2838:	00012023          	sw	zero,0(sp)
    283c:	00080893          	mv	a7,a6
    2840:	00000813          	li	a6,0
    2844:	00090693          	mv	a3,s2
    2848:	00048613          	mv	a2,s1
    284c:	00098593          	mv	a1,s3
    2850:	000a0513          	mv	a0,s4
    2854:	dcdfe0ef          	jal	1620 <_ntoa_long_long>
    2858:	00050493          	mv	s1,a0
    285c:	ec1ff06f          	j	271c <_vsnprintf+0x4a4>
            idx = _ntoa_long(out, buffer, idx, maxlen, va_arg(va, unsigned long), false, base, precision, width, flags);
    2860:	01812783          	lw	a5,24(sp)
    2864:	00478713          	addi	a4,a5,4
    2868:	00e12c23          	sw	a4,24(sp)
    286c:	0007a703          	lw	a4,0(a5)
    2870:	00812223          	sw	s0,4(sp)
    2874:	01612023          	sw	s6,0(sp)
    2878:	000a8893          	mv	a7,s5
    287c:	00000793          	li	a5,0
    2880:	00090693          	mv	a3,s2
    2884:	00048613          	mv	a2,s1
    2888:	00098593          	mv	a1,s3
    288c:	000a0513          	mv	a0,s4
    2890:	ccdfe0ef          	jal	155c <_ntoa_long>
    2894:	00050493          	mv	s1,a0
    2898:	e85ff06f          	j	271c <_vsnprintf+0x4a4>
            const unsigned int value = (flags & FLAGS_CHAR) ? (unsigned char)va_arg(va, unsigned int) : (flags & FLAGS_SHORT) ? (unsigned short int)va_arg(va, unsigned int) : va_arg(va, unsigned int);
    289c:	08047793          	andi	a5,s0,128
    28a0:	00078c63          	beqz	a5,28b8 <_vsnprintf+0x640>
    28a4:	01812783          	lw	a5,24(sp)
    28a8:	00478713          	addi	a4,a5,4
    28ac:	00e12c23          	sw	a4,24(sp)
    28b0:	0007d703          	lhu	a4,0(a5)
    28b4:	dc9ff06f          	j	267c <_vsnprintf+0x404>
    28b8:	01812783          	lw	a5,24(sp)
    28bc:	00478713          	addi	a4,a5,4
    28c0:	00e12c23          	sw	a4,24(sp)
    28c4:	0007a703          	lw	a4,0(a5)
    28c8:	db5ff06f          	j	267c <_vsnprintf+0x404>
        if (*format == 'F') flags |= FLAGS_UPPERCASE;
    28cc:	04600793          	li	a5,70
    28d0:	04f50a63          	beq	a0,a5,2924 <_vsnprintf+0x6ac>
        idx = _ftoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
    28d4:	01812783          	lw	a5,24(sp)
    28d8:	00778793          	addi	a5,a5,7
    28dc:	ff87f793          	andi	a5,a5,-8
    28e0:	00878713          	addi	a4,a5,8
    28e4:	00e12c23          	sw	a4,24(sp)
    28e8:	0007a703          	lw	a4,0(a5)
    28ec:	0047a783          	lw	a5,4(a5)
    28f0:	00812023          	sw	s0,0(sp)
    28f4:	000b0893          	mv	a7,s6
    28f8:	000a8813          	mv	a6,s5
    28fc:	00090693          	mv	a3,s2
    2900:	00048613          	mv	a2,s1
    2904:	00098593          	mv	a1,s3
    2908:	000a0513          	mv	a0,s4
    290c:	c20ff0ef          	jal	1d2c <_ftoa>
    2910:	00050493          	mv	s1,a0
        format++;
    2914:	01c12783          	lw	a5,28(sp)
    2918:	00178793          	addi	a5,a5,1
    291c:	00f12e23          	sw	a5,28(sp)
        break;
    2920:	999ff06f          	j	22b8 <_vsnprintf+0x40>
        if (*format == 'F') flags |= FLAGS_UPPERCASE;
    2924:	02046413          	ori	s0,s0,32
    2928:	fadff06f          	j	28d4 <_vsnprintf+0x65c>
        if ((*format == 'g')||(*format == 'G')) flags |= FLAGS_ADAPT_EXP;
    292c:	06700793          	li	a5,103
    2930:	00f50663          	beq	a0,a5,293c <_vsnprintf+0x6c4>
    2934:	04700793          	li	a5,71
    2938:	00f51863          	bne	a0,a5,2948 <_vsnprintf+0x6d0>
    293c:	000017b7          	lui	a5,0x1
    2940:	80078793          	addi	a5,a5,-2048 # 800 <CUSTOM2+0x7a5>
    2944:	00f46433          	or	s0,s0,a5
        if ((*format == 'E')||(*format == 'G')) flags |= FLAGS_UPPERCASE;
    2948:	04500793          	li	a5,69
    294c:	00f50663          	beq	a0,a5,2958 <_vsnprintf+0x6e0>
    2950:	04700793          	li	a5,71
    2954:	00f51463          	bne	a0,a5,295c <_vsnprintf+0x6e4>
    2958:	02046413          	ori	s0,s0,32
        idx = _etoa(out, buffer, idx, maxlen, va_arg(va, double), precision, width, flags);
    295c:	01812783          	lw	a5,24(sp)
    2960:	00778793          	addi	a5,a5,7
    2964:	ff87f793          	andi	a5,a5,-8
    2968:	00878713          	addi	a4,a5,8
    296c:	00e12c23          	sw	a4,24(sp)
    2970:	0007a703          	lw	a4,0(a5)
    2974:	0047a783          	lw	a5,4(a5)
    2978:	00812023          	sw	s0,0(sp)
    297c:	000b0893          	mv	a7,s6
    2980:	000a8813          	mv	a6,s5
    2984:	00090693          	mv	a3,s2
    2988:	00048613          	mv	a2,s1
    298c:	00098593          	mv	a1,s3
    2990:	000a0513          	mv	a0,s4
    2994:	e25fe0ef          	jal	17b8 <_etoa>
    2998:	00050493          	mv	s1,a0
        format++;
    299c:	01c12783          	lw	a5,28(sp)
    29a0:	00178793          	addi	a5,a5,1
    29a4:	00f12e23          	sw	a5,28(sp)
        break;
    29a8:	911ff06f          	j	22b8 <_vsnprintf+0x40>
    29ac:	03712623          	sw	s7,44(sp)
        if (!(flags & FLAGS_LEFT)) {
    29b0:	00247413          	andi	s0,s0,2
    29b4:	06040a63          	beqz	s0,2a28 <_vsnprintf+0x7b0>
        unsigned int l = 1U;
    29b8:	00100a93          	li	s5,1
        out((char)va_arg(va, int), buffer, idx++, maxlen);
    29bc:	01812783          	lw	a5,24(sp)
    29c0:	00478713          	addi	a4,a5,4
    29c4:	00e12c23          	sw	a4,24(sp)
    29c8:	00148b93          	addi	s7,s1,1
    29cc:	00090693          	mv	a3,s2
    29d0:	00048613          	mv	a2,s1
    29d4:	00098593          	mv	a1,s3
    29d8:	0007c503          	lbu	a0,0(a5)
    29dc:	000a00e7          	jalr	s4
        if (flags & FLAGS_LEFT) {
    29e0:	06041863          	bnez	s0,2a50 <_vsnprintf+0x7d8>
        format++;
    29e4:	01c12783          	lw	a5,28(sp)
    29e8:	00178793          	addi	a5,a5,1
    29ec:	00f12e23          	sw	a5,28(sp)
        break;
    29f0:	000b8493          	mv	s1,s7
    29f4:	02c12b83          	lw	s7,44(sp)
    29f8:	8c1ff06f          	j	22b8 <_vsnprintf+0x40>
            out(' ', buffer, idx++, maxlen);
    29fc:	00148b93          	addi	s7,s1,1
    2a00:	00090693          	mv	a3,s2
    2a04:	00048613          	mv	a2,s1
    2a08:	00098593          	mv	a1,s3
    2a0c:	02000513          	li	a0,32
    2a10:	000a00e7          	jalr	s4
          while (l++ < width) {
    2a14:	000a8793          	mv	a5,s5
            out(' ', buffer, idx++, maxlen);
    2a18:	000b8493          	mv	s1,s7
          while (l++ < width) {
    2a1c:	00178a93          	addi	s5,a5,1
    2a20:	fd67eee3          	bltu	a5,s6,29fc <_vsnprintf+0x784>
    2a24:	f99ff06f          	j	29bc <_vsnprintf+0x744>
        unsigned int l = 1U;
    2a28:	00100793          	li	a5,1
    2a2c:	ff1ff06f          	j	2a1c <_vsnprintf+0x7a4>
            out(' ', buffer, idx++, maxlen);
    2a30:	001b8493          	addi	s1,s7,1
    2a34:	00090693          	mv	a3,s2
    2a38:	000b8613          	mv	a2,s7
    2a3c:	00098593          	mv	a1,s3
    2a40:	02000513          	li	a0,32
    2a44:	000a00e7          	jalr	s4
          while (l++ < width) {
    2a48:	00040a93          	mv	s5,s0
            out(' ', buffer, idx++, maxlen);
    2a4c:	00048b93          	mv	s7,s1
          while (l++ < width) {
    2a50:	001a8413          	addi	s0,s5,1
    2a54:	fd6aeee3          	bltu	s5,s6,2a30 <_vsnprintf+0x7b8>
    2a58:	f8dff06f          	j	29e4 <_vsnprintf+0x76c>
  for (s = str; *s && maxsize--; ++s);
    2a5c:	00178793          	addi	a5,a5,1
    2a60:	00068713          	mv	a4,a3
    2a64:	0007c683          	lbu	a3,0(a5)
    2a68:	00068663          	beqz	a3,2a74 <_vsnprintf+0x7fc>
    2a6c:	fff70693          	addi	a3,a4,-1
    2a70:	fe0716e3          	bnez	a4,2a5c <_vsnprintf+0x7e4>
  return (unsigned int)(s - str);
    2a74:	417787b3          	sub	a5,a5,s7
        // pre padding
        if (flags & FLAGS_PRECISION) {
    2a78:	40047c13          	andi	s8,s0,1024
    2a7c:	000c0663          	beqz	s8,2a88 <_vsnprintf+0x810>
          l = (l < precision ? l : precision);
    2a80:	00faf463          	bgeu	s5,a5,2a88 <_vsnprintf+0x810>
    2a84:	000a8793          	mv	a5,s5
        }
        if (!(flags & FLAGS_LEFT)) {
    2a88:	00247c93          	andi	s9,s0,2
    2a8c:	020c8a63          	beqz	s9,2ac0 <_vsnprintf+0x848>
    2a90:	00078413          	mv	s0,a5
    2a94:	0580006f          	j	2aec <_vsnprintf+0x874>
        unsigned int l = _strnlen_s(p, precision ? precision : (size_t)-1);
    2a98:	000a8713          	mv	a4,s5
    2a9c:	b3dff06f          	j	25d8 <_vsnprintf+0x360>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
    2aa0:	00148d13          	addi	s10,s1,1
    2aa4:	00090693          	mv	a3,s2
    2aa8:	00048613          	mv	a2,s1
    2aac:	00098593          	mv	a1,s3
    2ab0:	02000513          	li	a0,32
    2ab4:	000a00e7          	jalr	s4
          while (l++ < width) {
    2ab8:	00040793          	mv	a5,s0
            out(' ', buffer, idx++, maxlen);
    2abc:	000d0493          	mv	s1,s10
          while (l++ < width) {
    2ac0:	00178413          	addi	s0,a5,1
    2ac4:	fd67eee3          	bltu	a5,s6,2aa0 <_vsnprintf+0x828>
    2ac8:	0240006f          	j	2aec <_vsnprintf+0x874>
          }
        }
        // string output
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
    2acc:	00078a93          	mv	s5,a5
          out(*(p++), buffer, idx++, maxlen);
    2ad0:	001b8b93          	addi	s7,s7,1
    2ad4:	00148d13          	addi	s10,s1,1
    2ad8:	00090693          	mv	a3,s2
    2adc:	00048613          	mv	a2,s1
    2ae0:	00098593          	mv	a1,s3
    2ae4:	000a00e7          	jalr	s4
    2ae8:	000d0493          	mv	s1,s10
        while ((*p != 0) && (!(flags & FLAGS_PRECISION) || precision--)) {
    2aec:	000bc503          	lbu	a0,0(s7)
    2af0:	00050863          	beqz	a0,2b00 <_vsnprintf+0x888>
    2af4:	fc0c0ee3          	beqz	s8,2ad0 <_vsnprintf+0x858>
    2af8:	fffa8793          	addi	a5,s5,-1
    2afc:	fc0a98e3          	bnez	s5,2acc <_vsnprintf+0x854>
        }
        // post padding
        if (flags & FLAGS_LEFT) {
    2b00:	040c9263          	bnez	s9,2b44 <_vsnprintf+0x8cc>
          while (l++ < width) {
            out(' ', buffer, idx++, maxlen);
          }
        }
        format++;
    2b04:	01c12783          	lw	a5,28(sp)
    2b08:	00178793          	addi	a5,a5,1
    2b0c:	00f12e23          	sw	a5,28(sp)
        break;
    2b10:	02c12b83          	lw	s7,44(sp)
    2b14:	02812c03          	lw	s8,40(sp)
    2b18:	02412c83          	lw	s9,36(sp)
    2b1c:	02012d03          	lw	s10,32(sp)
    2b20:	f98ff06f          	j	22b8 <_vsnprintf+0x40>
            out(' ', buffer, idx++, maxlen);
    2b24:	00148b93          	addi	s7,s1,1
    2b28:	00090693          	mv	a3,s2
    2b2c:	00048613          	mv	a2,s1
    2b30:	00098593          	mv	a1,s3
    2b34:	02000513          	li	a0,32
    2b38:	000a00e7          	jalr	s4
          while (l++ < width) {
    2b3c:	000a8413          	mv	s0,s5
            out(' ', buffer, idx++, maxlen);
    2b40:	000b8493          	mv	s1,s7
          while (l++ < width) {
    2b44:	00140a93          	addi	s5,s0,1
    2b48:	fd646ee3          	bltu	s0,s6,2b24 <_vsnprintf+0x8ac>
    2b4c:	fb9ff06f          	j	2b04 <_vsnprintf+0x88c>
      }

      case 'p' : {
        width = sizeof(void*) * 2U;
        flags |= FLAGS_ZEROPAD | FLAGS_UPPERCASE;
    2b50:	02146413          	ori	s0,s0,33
        if (is_ll) {
          idx = _ntoa_long_long(out, buffer, idx, maxlen, (uintptr_t)va_arg(va, void*), false, 16U, precision, width, flags);
        }
        else {
#endif
          idx = _ntoa_long(out, buffer, idx, maxlen, (unsigned long)((uintptr_t)va_arg(va, void*)), false, 16U, precision, width, flags);
    2b54:	01812783          	lw	a5,24(sp)
    2b58:	00478713          	addi	a4,a5,4
    2b5c:	00e12c23          	sw	a4,24(sp)
    2b60:	0007a703          	lw	a4,0(a5)
    2b64:	00812223          	sw	s0,4(sp)
    2b68:	00800793          	li	a5,8
    2b6c:	00f12023          	sw	a5,0(sp)
    2b70:	000a8893          	mv	a7,s5
    2b74:	01000813          	li	a6,16
    2b78:	00000793          	li	a5,0
    2b7c:	00090693          	mv	a3,s2
    2b80:	00048613          	mv	a2,s1
    2b84:	00098593          	mv	a1,s3
    2b88:	000a0513          	mv	a0,s4
    2b8c:	9d1fe0ef          	jal	155c <_ntoa_long>
    2b90:	00050493          	mv	s1,a0
#if defined(PRINTF_SUPPORT_LONG_LONG)
        }
#endif
        format++;
    2b94:	01c12783          	lw	a5,28(sp)
    2b98:	00178793          	addi	a5,a5,1
    2b9c:	00f12e23          	sw	a5,28(sp)
        break;
    2ba0:	f18ff06f          	j	22b8 <_vsnprintf+0x40>
      }

      case '%' :
        out('%', buffer, idx++, maxlen);
    2ba4:	00148413          	addi	s0,s1,1
    2ba8:	00090693          	mv	a3,s2
    2bac:	00048613          	mv	a2,s1
    2bb0:	00098593          	mv	a1,s3
    2bb4:	02500513          	li	a0,37
    2bb8:	000a00e7          	jalr	s4
        format++;
    2bbc:	01c12783          	lw	a5,28(sp)
    2bc0:	00178793          	addi	a5,a5,1
    2bc4:	00f12e23          	sw	a5,28(sp)
        out('%', buffer, idx++, maxlen);
    2bc8:	00040493          	mv	s1,s0
        break;
    2bcc:	eecff06f          	j	22b8 <_vsnprintf+0x40>

      default :
        out(*format, buffer, idx++, maxlen);
    2bd0:	00148413          	addi	s0,s1,1
    2bd4:	00090693          	mv	a3,s2
    2bd8:	00048613          	mv	a2,s1
    2bdc:	00098593          	mv	a1,s3
    2be0:	000a00e7          	jalr	s4
        format++;
    2be4:	01c12783          	lw	a5,28(sp)
    2be8:	00178793          	addi	a5,a5,1
    2bec:	00f12e23          	sw	a5,28(sp)
        out(*format, buffer, idx++, maxlen);
    2bf0:	00040493          	mv	s1,s0
        break;
    2bf4:	ec4ff06f          	j	22b8 <_vsnprintf+0x40>
    out = _out_null;
    2bf8:	00001a37          	lui	s4,0x1
    2bfc:	244a0a13          	addi	s4,s4,580 # 1244 <_out_null>
    2c00:	eb4ff06f          	j	22b4 <_vsnprintf+0x3c>
    }
  }

  // termination
  out((char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
    2c04:	0524e263          	bltu	s1,s2,2c48 <_vsnprintf+0x9d0>
    2c08:	fff90613          	addi	a2,s2,-1
    2c0c:	00090693          	mv	a3,s2
    2c10:	00098593          	mv	a1,s3
    2c14:	00000513          	li	a0,0
    2c18:	000a00e7          	jalr	s4

  // return written chars without terminating \0
  return (int)idx;
}
    2c1c:	00048513          	mv	a0,s1
    2c20:	04c12083          	lw	ra,76(sp)
    2c24:	04812403          	lw	s0,72(sp)
    2c28:	04412483          	lw	s1,68(sp)
    2c2c:	04012903          	lw	s2,64(sp)
    2c30:	03c12983          	lw	s3,60(sp)
    2c34:	03812a03          	lw	s4,56(sp)
    2c38:	03412a83          	lw	s5,52(sp)
    2c3c:	03012b03          	lw	s6,48(sp)
    2c40:	05010113          	addi	sp,sp,80
    2c44:	00008067          	ret
  out((char)0, buffer, idx < maxlen ? idx : maxlen - 1U, maxlen);
    2c48:	00048613          	mv	a2,s1
    2c4c:	fc1ff06f          	j	2c0c <_vsnprintf+0x994>

00002c50 <bsp_printf>:
* @param format Format string followed by the arguments to be formatted.
* @param ... Variable arguments corresponding to the format specifiers in 'format'.
*
******************************************************************************/
    static int bsp_printf(const char* format, ...)
    {
    2c50:	f6010113          	addi	sp,sp,-160
    2c54:	06112e23          	sw	ra,124(sp)
    2c58:	06812c23          	sw	s0,120(sp)
    2c5c:	08b12223          	sw	a1,132(sp)
    2c60:	08c12423          	sw	a2,136(sp)
    2c64:	08d12623          	sw	a3,140(sp)
    2c68:	08e12823          	sw	a4,144(sp)
    2c6c:	08f12a23          	sw	a5,148(sp)
    2c70:	09012c23          	sw	a6,152(sp)
    2c74:	09112e23          	sw	a7,156(sp)
      va_list va;
      va_start(va, format);
    2c78:	08410713          	addi	a4,sp,132
    2c7c:	06e12623          	sw	a4,108(sp)

      char buffer[MAX_STRING_BUFFER_SIZE];
        const int ret = _vsnprintf(_out_buffer, buffer, (size_t)-1, format, va);
    2c80:	00050693          	mv	a3,a0
    2c84:	fff00613          	li	a2,-1
    2c88:	00810593          	addi	a1,sp,8
    2c8c:	00001537          	lui	a0,0x1
    2c90:	23450513          	addi	a0,a0,564 # 1234 <_out_buffer>
    2c94:	de4ff0ef          	jal	2278 <_vsnprintf>
    2c98:	00050413          	mv	s0,a0
        _putchar_s(buffer);
    2c9c:	00810513          	addi	a0,sp,8
    2ca0:	d7cfe0ef          	jal	121c <_putchar_s>

      va_end(va);
      return ret;
    }
    2ca4:	00040513          	mv	a0,s0
    2ca8:	07c12083          	lw	ra,124(sp)
    2cac:	07812403          	lw	s0,120(sp)
    2cb0:	0a010113          	addi	sp,sp,160
    2cb4:	00008067          	ret

00002cb8 <__udivdi3>:
    2cb8:	00060813          	mv	a6,a2
    2cbc:	00050893          	mv	a7,a0
    2cc0:	00058713          	mv	a4,a1
    2cc4:	0e069063          	bnez	a3,2da4 <__udivdi3+0xec>
    2cc8:	12c5fe63          	bgeu	a1,a2,2e04 <__udivdi3+0x14c>
    2ccc:	000107b7          	lui	a5,0x10
    2cd0:	1ef66e63          	bltu	a2,a5,2ecc <__udivdi3+0x214>
    2cd4:	010007b7          	lui	a5,0x1000
    2cd8:	01800693          	li	a3,24
    2cdc:	00f67463          	bgeu	a2,a5,2ce4 <__udivdi3+0x2c>
    2ce0:	01000693          	li	a3,16
    2ce4:	00d65333          	srl	t1,a2,a3
    2ce8:	00003797          	auipc	a5,0x3
    2cec:	19878793          	addi	a5,a5,408 # 5e80 <__clz_tab>
    2cf0:	006787b3          	add	a5,a5,t1
    2cf4:	0007c783          	lbu	a5,0(a5)
    2cf8:	02000313          	li	t1,32
    2cfc:	00d787b3          	add	a5,a5,a3
    2d00:	40f306b3          	sub	a3,t1,a5
    2d04:	00f30c63          	beq	t1,a5,2d1c <__udivdi3+0x64>
    2d08:	00d59733          	sll	a4,a1,a3
    2d0c:	00f557b3          	srl	a5,a0,a5
    2d10:	00d61833          	sll	a6,a2,a3
    2d14:	00e7e733          	or	a4,a5,a4
    2d18:	00d518b3          	sll	a7,a0,a3
    2d1c:	01085613          	srli	a2,a6,0x10
    2d20:	02c75533          	divu	a0,a4,a2
    2d24:	01081693          	slli	a3,a6,0x10
    2d28:	0106d693          	srli	a3,a3,0x10
    2d2c:	0108d793          	srli	a5,a7,0x10
    2d30:	02c77733          	remu	a4,a4,a2
    2d34:	02a685b3          	mul	a1,a3,a0
    2d38:	01071713          	slli	a4,a4,0x10
    2d3c:	00e7e7b3          	or	a5,a5,a4
    2d40:	00b7fc63          	bgeu	a5,a1,2d58 <__udivdi3+0xa0>
    2d44:	00f807b3          	add	a5,a6,a5
    2d48:	fff50713          	addi	a4,a0,-1
    2d4c:	0107e463          	bltu	a5,a6,2d54 <__udivdi3+0x9c>
    2d50:	40b7e063          	bltu	a5,a1,3150 <__udivdi3+0x498>
    2d54:	00070513          	mv	a0,a4
    2d58:	40b787b3          	sub	a5,a5,a1
    2d5c:	02c7d733          	divu	a4,a5,a2
    2d60:	01089893          	slli	a7,a7,0x10
    2d64:	0108d893          	srli	a7,a7,0x10
    2d68:	02c7f7b3          	remu	a5,a5,a2
    2d6c:	02e686b3          	mul	a3,a3,a4
    2d70:	01079793          	slli	a5,a5,0x10
    2d74:	00f8e8b3          	or	a7,a7,a5
    2d78:	00d8fe63          	bgeu	a7,a3,2d94 <__udivdi3+0xdc>
    2d7c:	011808b3          	add	a7,a6,a7
    2d80:	fff70793          	addi	a5,a4,-1
    2d84:	0108e663          	bltu	a7,a6,2d90 <__udivdi3+0xd8>
    2d88:	ffe70713          	addi	a4,a4,-2
    2d8c:	00d8e463          	bltu	a7,a3,2d94 <__udivdi3+0xdc>
    2d90:	00078713          	mv	a4,a5
    2d94:	01051513          	slli	a0,a0,0x10
    2d98:	00e56533          	or	a0,a0,a4
    2d9c:	00000593          	li	a1,0
    2da0:	00008067          	ret
    2da4:	00d5f863          	bgeu	a1,a3,2db4 <__udivdi3+0xfc>
    2da8:	00000593          	li	a1,0
    2dac:	00000513          	li	a0,0
    2db0:	00008067          	ret
    2db4:	000107b7          	lui	a5,0x10
    2db8:	1ef6e863          	bltu	a3,a5,2fa8 <__udivdi3+0x2f0>
    2dbc:	01000737          	lui	a4,0x1000
    2dc0:	01800793          	li	a5,24
    2dc4:	00e6f463          	bgeu	a3,a4,2dcc <__udivdi3+0x114>
    2dc8:	01000793          	li	a5,16
    2dcc:	00f6d833          	srl	a6,a3,a5
    2dd0:	00003717          	auipc	a4,0x3
    2dd4:	0b070713          	addi	a4,a4,176 # 5e80 <__clz_tab>
    2dd8:	01070733          	add	a4,a4,a6
    2ddc:	00074703          	lbu	a4,0(a4)
    2de0:	02000893          	li	a7,32
    2de4:	00f70733          	add	a4,a4,a5
    2de8:	40e88833          	sub	a6,a7,a4
    2dec:	1ee89663          	bne	a7,a4,2fd8 <__udivdi3+0x320>
    2df0:	32b6e463          	bltu	a3,a1,3118 <__udivdi3+0x460>
    2df4:	00c53533          	sltu	a0,a0,a2
    2df8:	00153513          	seqz	a0,a0
    2dfc:	00000593          	li	a1,0
    2e00:	00008067          	ret
    2e04:	0c060c63          	beqz	a2,2edc <__udivdi3+0x224>
    2e08:	000107b7          	lui	a5,0x10
    2e0c:	2ef67c63          	bgeu	a2,a5,3104 <__udivdi3+0x44c>
    2e10:	10063713          	sltiu	a4,a2,256
    2e14:	00173713          	seqz	a4,a4
    2e18:	00371713          	slli	a4,a4,0x3
    2e1c:	00e656b3          	srl	a3,a2,a4
    2e20:	00003797          	auipc	a5,0x3
    2e24:	06078793          	addi	a5,a5,96 # 5e80 <__clz_tab>
    2e28:	00d787b3          	add	a5,a5,a3
    2e2c:	0007c783          	lbu	a5,0(a5)
    2e30:	02000693          	li	a3,32
    2e34:	00e787b3          	add	a5,a5,a4
    2e38:	40f68eb3          	sub	t4,a3,a5
    2e3c:	0cf69463          	bne	a3,a5,2f04 <__udivdi3+0x24c>
    2e40:	40c587b3          	sub	a5,a1,a2
    2e44:	01065693          	srli	a3,a2,0x10
    2e48:	01061613          	slli	a2,a2,0x10
    2e4c:	01065613          	srli	a2,a2,0x10
    2e50:	00100593          	li	a1,1
    2e54:	02d7d533          	divu	a0,a5,a3
    2e58:	0108d713          	srli	a4,a7,0x10
    2e5c:	02d7f7b3          	remu	a5,a5,a3
    2e60:	02c50333          	mul	t1,a0,a2
    2e64:	01079793          	slli	a5,a5,0x10
    2e68:	00f767b3          	or	a5,a4,a5
    2e6c:	0067fc63          	bgeu	a5,t1,2e84 <__udivdi3+0x1cc>
    2e70:	00f807b3          	add	a5,a6,a5
    2e74:	fff50713          	addi	a4,a0,-1
    2e78:	0107e463          	bltu	a5,a6,2e80 <__udivdi3+0x1c8>
    2e7c:	2c67e463          	bltu	a5,t1,3144 <__udivdi3+0x48c>
    2e80:	00070513          	mv	a0,a4
    2e84:	406787b3          	sub	a5,a5,t1
    2e88:	02d7d733          	divu	a4,a5,a3
    2e8c:	01089893          	slli	a7,a7,0x10
    2e90:	0108d893          	srli	a7,a7,0x10
    2e94:	02d7f7b3          	remu	a5,a5,a3
    2e98:	02c70633          	mul	a2,a4,a2
    2e9c:	01079793          	slli	a5,a5,0x10
    2ea0:	00f8e8b3          	or	a7,a7,a5
    2ea4:	00c8fe63          	bgeu	a7,a2,2ec0 <__udivdi3+0x208>
    2ea8:	011808b3          	add	a7,a6,a7
    2eac:	fff70793          	addi	a5,a4,-1
    2eb0:	0108e663          	bltu	a7,a6,2ebc <__udivdi3+0x204>
    2eb4:	ffe70713          	addi	a4,a4,-2
    2eb8:	00c8e463          	bltu	a7,a2,2ec0 <__udivdi3+0x208>
    2ebc:	00078713          	mv	a4,a5
    2ec0:	01051513          	slli	a0,a0,0x10
    2ec4:	00e56533          	or	a0,a0,a4
    2ec8:	00008067          	ret
    2ecc:	10063693          	sltiu	a3,a2,256
    2ed0:	0016b693          	seqz	a3,a3
    2ed4:	00369693          	slli	a3,a3,0x3
    2ed8:	e0dff06f          	j	2ce4 <__udivdi3+0x2c>
    2edc:	00000693          	li	a3,0
    2ee0:	00003797          	auipc	a5,0x3
    2ee4:	fa078793          	addi	a5,a5,-96 # 5e80 <__clz_tab>
    2ee8:	00d787b3          	add	a5,a5,a3
    2eec:	0007c783          	lbu	a5,0(a5)
    2ef0:	00000713          	li	a4,0
    2ef4:	02000693          	li	a3,32
    2ef8:	00e787b3          	add	a5,a5,a4
    2efc:	40f68eb3          	sub	t4,a3,a5
    2f00:	f4f680e3          	beq	a3,a5,2e40 <__udivdi3+0x188>
    2f04:	01d61833          	sll	a6,a2,t4
    2f08:	00f5d333          	srl	t1,a1,a5
    2f0c:	01085693          	srli	a3,a6,0x10
    2f10:	02d35e33          	divu	t3,t1,a3
    2f14:	01081613          	slli	a2,a6,0x10
    2f18:	01d595b3          	sll	a1,a1,t4
    2f1c:	01065613          	srli	a2,a2,0x10
    2f20:	00f557b3          	srl	a5,a0,a5
    2f24:	00b7e7b3          	or	a5,a5,a1
    2f28:	0107d713          	srli	a4,a5,0x10
    2f2c:	01d518b3          	sll	a7,a0,t4
    2f30:	02d37333          	remu	t1,t1,a3
    2f34:	03c605b3          	mul	a1,a2,t3
    2f38:	01031313          	slli	t1,t1,0x10
    2f3c:	00676733          	or	a4,a4,t1
    2f40:	00b77e63          	bgeu	a4,a1,2f5c <__udivdi3+0x2a4>
    2f44:	00e80733          	add	a4,a6,a4
    2f48:	fffe0513          	addi	a0,t3,-1
    2f4c:	1f076463          	bltu	a4,a6,3134 <__udivdi3+0x47c>
    2f50:	1eb77263          	bgeu	a4,a1,3134 <__udivdi3+0x47c>
    2f54:	ffee0e13          	addi	t3,t3,-2
    2f58:	01070733          	add	a4,a4,a6
    2f5c:	40b70733          	sub	a4,a4,a1
    2f60:	02d75533          	divu	a0,a4,a3
    2f64:	01079793          	slli	a5,a5,0x10
    2f68:	0107d793          	srli	a5,a5,0x10
    2f6c:	02d77733          	remu	a4,a4,a3
    2f70:	02a60333          	mul	t1,a2,a0
    2f74:	01071713          	slli	a4,a4,0x10
    2f78:	00e7e7b3          	or	a5,a5,a4
    2f7c:	0067fe63          	bgeu	a5,t1,2f98 <__udivdi3+0x2e0>
    2f80:	00f807b3          	add	a5,a6,a5
    2f84:	fff50713          	addi	a4,a0,-1
    2f88:	1907ee63          	bltu	a5,a6,3124 <__udivdi3+0x46c>
    2f8c:	1867fc63          	bgeu	a5,t1,3124 <__udivdi3+0x46c>
    2f90:	ffe50513          	addi	a0,a0,-2
    2f94:	010787b3          	add	a5,a5,a6
    2f98:	010e1593          	slli	a1,t3,0x10
    2f9c:	406787b3          	sub	a5,a5,t1
    2fa0:	00a5e5b3          	or	a1,a1,a0
    2fa4:	eb1ff06f          	j	2e54 <__udivdi3+0x19c>
    2fa8:	1006b793          	sltiu	a5,a3,256
    2fac:	0017b793          	seqz	a5,a5
    2fb0:	00379793          	slli	a5,a5,0x3
    2fb4:	00f6d833          	srl	a6,a3,a5
    2fb8:	00003717          	auipc	a4,0x3
    2fbc:	ec870713          	addi	a4,a4,-312 # 5e80 <__clz_tab>
    2fc0:	01070733          	add	a4,a4,a6
    2fc4:	00074703          	lbu	a4,0(a4)
    2fc8:	02000893          	li	a7,32
    2fcc:	00f70733          	add	a4,a4,a5
    2fd0:	40e88833          	sub	a6,a7,a4
    2fd4:	e0e88ee3          	beq	a7,a4,2df0 <__udivdi3+0x138>
    2fd8:	00e65e33          	srl	t3,a2,a4
    2fdc:	010696b3          	sll	a3,a3,a6
    2fe0:	00de6e33          	or	t3,t3,a3
    2fe4:	00e5d8b3          	srl	a7,a1,a4
    2fe8:	010e5e93          	srli	t4,t3,0x10
    2fec:	03d8d7b3          	divu	a5,a7,t4
    2ff0:	010e1313          	slli	t1,t3,0x10
    2ff4:	010595b3          	sll	a1,a1,a6
    2ff8:	01035313          	srli	t1,t1,0x10
    2ffc:	00e55733          	srl	a4,a0,a4
    3000:	00b76733          	or	a4,a4,a1
    3004:	01075693          	srli	a3,a4,0x10
    3008:	01061633          	sll	a2,a2,a6
    300c:	03d8f8b3          	remu	a7,a7,t4
    3010:	02f305b3          	mul	a1,t1,a5
    3014:	01089893          	slli	a7,a7,0x10
    3018:	0116e6b3          	or	a3,a3,a7
    301c:	00b6fe63          	bgeu	a3,a1,3038 <__udivdi3+0x380>
    3020:	00de06b3          	add	a3,t3,a3
    3024:	fff78893          	addi	a7,a5,-1
    3028:	11c6ea63          	bltu	a3,t3,313c <__udivdi3+0x484>
    302c:	10b6f863          	bgeu	a3,a1,313c <__udivdi3+0x484>
    3030:	ffe78793          	addi	a5,a5,-2
    3034:	01c686b3          	add	a3,a3,t3
    3038:	40b686b3          	sub	a3,a3,a1
    303c:	03d6d5b3          	divu	a1,a3,t4
    3040:	01071713          	slli	a4,a4,0x10
    3044:	01075713          	srli	a4,a4,0x10
    3048:	03d6f6b3          	remu	a3,a3,t4
    304c:	02b308b3          	mul	a7,t1,a1
    3050:	01069693          	slli	a3,a3,0x10
    3054:	00d76733          	or	a4,a4,a3
    3058:	01177e63          	bgeu	a4,a7,3074 <__udivdi3+0x3bc>
    305c:	00ee0733          	add	a4,t3,a4
    3060:	fff58693          	addi	a3,a1,-1
    3064:	0dc76463          	bltu	a4,t3,312c <__udivdi3+0x474>
    3068:	0d177263          	bgeu	a4,a7,312c <__udivdi3+0x474>
    306c:	ffe58593          	addi	a1,a1,-2
    3070:	01c70733          	add	a4,a4,t3
    3074:	01079793          	slli	a5,a5,0x10
    3078:	00010eb7          	lui	t4,0x10
    307c:	00b7e7b3          	or	a5,a5,a1
    3080:	fffe8693          	addi	a3,t4,-1 # ffff <__freertos_irq_stack_top+0x8fcf>
    3084:	00d7f5b3          	and	a1,a5,a3
    3088:	0107d313          	srli	t1,a5,0x10
    308c:	00d676b3          	and	a3,a2,a3
    3090:	01065613          	srli	a2,a2,0x10
    3094:	02d58e33          	mul	t3,a1,a3
    3098:	41170733          	sub	a4,a4,a7
    309c:	02d306b3          	mul	a3,t1,a3
    30a0:	010e5893          	srli	a7,t3,0x10
    30a4:	02c585b3          	mul	a1,a1,a2
    30a8:	00d585b3          	add	a1,a1,a3
    30ac:	00b885b3          	add	a1,a7,a1
    30b0:	02c30333          	mul	t1,t1,a2
    30b4:	00d5f463          	bgeu	a1,a3,30bc <__udivdi3+0x404>
    30b8:	01d30333          	add	t1,t1,t4
    30bc:	0105d693          	srli	a3,a1,0x10
    30c0:	006686b3          	add	a3,a3,t1
    30c4:	02d76a63          	bltu	a4,a3,30f8 <__udivdi3+0x440>
    30c8:	00d70863          	beq	a4,a3,30d8 <__udivdi3+0x420>
    30cc:	00078513          	mv	a0,a5
    30d0:	00000593          	li	a1,0
    30d4:	00008067          	ret
    30d8:	000106b7          	lui	a3,0x10
    30dc:	fff68693          	addi	a3,a3,-1 # ffff <__freertos_irq_stack_top+0x8fcf>
    30e0:	00d5f733          	and	a4,a1,a3
    30e4:	01071713          	slli	a4,a4,0x10
    30e8:	00de7e33          	and	t3,t3,a3
    30ec:	01051533          	sll	a0,a0,a6
    30f0:	01c70733          	add	a4,a4,t3
    30f4:	fce57ce3          	bgeu	a0,a4,30cc <__udivdi3+0x414>
    30f8:	fff78513          	addi	a0,a5,-1
    30fc:	00000593          	li	a1,0
    3100:	00008067          	ret
    3104:	010007b7          	lui	a5,0x1000
    3108:	04f67a63          	bgeu	a2,a5,315c <__udivdi3+0x4a4>
    310c:	01065693          	srli	a3,a2,0x10
    3110:	01000713          	li	a4,16
    3114:	d0dff06f          	j	2e20 <__udivdi3+0x168>
    3118:	00000593          	li	a1,0
    311c:	00100513          	li	a0,1
    3120:	00008067          	ret
    3124:	00070513          	mv	a0,a4
    3128:	e71ff06f          	j	2f98 <__udivdi3+0x2e0>
    312c:	00068593          	mv	a1,a3
    3130:	f45ff06f          	j	3074 <__udivdi3+0x3bc>
    3134:	00050e13          	mv	t3,a0
    3138:	e25ff06f          	j	2f5c <__udivdi3+0x2a4>
    313c:	00088793          	mv	a5,a7
    3140:	ef9ff06f          	j	3038 <__udivdi3+0x380>
    3144:	ffe50513          	addi	a0,a0,-2
    3148:	010787b3          	add	a5,a5,a6
    314c:	d39ff06f          	j	2e84 <__udivdi3+0x1cc>
    3150:	ffe50513          	addi	a0,a0,-2
    3154:	010787b3          	add	a5,a5,a6
    3158:	c01ff06f          	j	2d58 <__udivdi3+0xa0>
    315c:	01865693          	srli	a3,a2,0x18
    3160:	01800713          	li	a4,24
    3164:	cbdff06f          	j	2e20 <__udivdi3+0x168>

00003168 <__umoddi3>:
    3168:	00060813          	mv	a6,a2
    316c:	00050893          	mv	a7,a0
    3170:	00058793          	mv	a5,a1
    3174:	00058713          	mv	a4,a1
    3178:	0c069863          	bnez	a3,3248 <__umoddi3+0xe0>
    317c:	12c5fa63          	bgeu	a1,a2,32b0 <__umoddi3+0x148>
    3180:	000107b7          	lui	a5,0x10
    3184:	1cf66c63          	bltu	a2,a5,335c <__umoddi3+0x1f4>
    3188:	010007b7          	lui	a5,0x1000
    318c:	01800693          	li	a3,24
    3190:	00f67463          	bgeu	a2,a5,3198 <__umoddi3+0x30>
    3194:	01000693          	li	a3,16
    3198:	00d65333          	srl	t1,a2,a3
    319c:	00003797          	auipc	a5,0x3
    31a0:	ce478793          	addi	a5,a5,-796 # 5e80 <__clz_tab>
    31a4:	006787b3          	add	a5,a5,t1
    31a8:	0007c783          	lbu	a5,0(a5)
    31ac:	02000313          	li	t1,32
    31b0:	00d787b3          	add	a5,a5,a3
    31b4:	40f306b3          	sub	a3,t1,a5
    31b8:	00f30c63          	beq	t1,a5,31d0 <__umoddi3+0x68>
    31bc:	00d59733          	sll	a4,a1,a3
    31c0:	00f557b3          	srl	a5,a0,a5
    31c4:	00d61833          	sll	a6,a2,a3
    31c8:	00e7e733          	or	a4,a5,a4
    31cc:	00d518b3          	sll	a7,a0,a3
    31d0:	01085593          	srli	a1,a6,0x10
    31d4:	02b75633          	divu	a2,a4,a1
    31d8:	01081313          	slli	t1,a6,0x10
    31dc:	01035313          	srli	t1,t1,0x10
    31e0:	0108d793          	srli	a5,a7,0x10
    31e4:	02b77733          	remu	a4,a4,a1
    31e8:	02660633          	mul	a2,a2,t1
    31ec:	01071713          	slli	a4,a4,0x10
    31f0:	00e7e7b3          	or	a5,a5,a4
    31f4:	00c7f863          	bgeu	a5,a2,3204 <__umoddi3+0x9c>
    31f8:	00f807b3          	add	a5,a6,a5
    31fc:	0107e463          	bltu	a5,a6,3204 <__umoddi3+0x9c>
    3200:	3cc7e263          	bltu	a5,a2,35c4 <__umoddi3+0x45c>
    3204:	40c787b3          	sub	a5,a5,a2
    3208:	02b7d733          	divu	a4,a5,a1
    320c:	01089513          	slli	a0,a7,0x10
    3210:	01055513          	srli	a0,a0,0x10
    3214:	02b7f7b3          	remu	a5,a5,a1
    3218:	02670733          	mul	a4,a4,t1
    321c:	01079793          	slli	a5,a5,0x10
    3220:	00f56533          	or	a0,a0,a5
    3224:	00e57a63          	bgeu	a0,a4,3238 <__umoddi3+0xd0>
    3228:	00a80533          	add	a0,a6,a0
    322c:	01056663          	bltu	a0,a6,3238 <__umoddi3+0xd0>
    3230:	00e57463          	bgeu	a0,a4,3238 <__umoddi3+0xd0>
    3234:	01050533          	add	a0,a0,a6
    3238:	40e50533          	sub	a0,a0,a4
    323c:	00d55533          	srl	a0,a0,a3
    3240:	00000593          	li	a1,0
    3244:	00008067          	ret
    3248:	00d5f463          	bgeu	a1,a3,3250 <__umoddi3+0xe8>
    324c:	00008067          	ret
    3250:	00010737          	lui	a4,0x10
    3254:	1ce6e663          	bltu	a3,a4,3420 <__umoddi3+0x2b8>
    3258:	01000737          	lui	a4,0x1000
    325c:	01800813          	li	a6,24
    3260:	00e6f463          	bgeu	a3,a4,3268 <__umoddi3+0x100>
    3264:	01000813          	li	a6,16
    3268:	0106d333          	srl	t1,a3,a6
    326c:	00003717          	auipc	a4,0x3
    3270:	c1470713          	addi	a4,a4,-1004 # 5e80 <__clz_tab>
    3274:	00670733          	add	a4,a4,t1
    3278:	00074703          	lbu	a4,0(a4)
    327c:	02000313          	li	t1,32
    3280:	01070733          	add	a4,a4,a6
    3284:	40e30833          	sub	a6,t1,a4
    3288:	1ce31463          	bne	t1,a4,3450 <__umoddi3+0x2e8>
    328c:	00b6e463          	bltu	a3,a1,3294 <__umoddi3+0x12c>
    3290:	00c56a63          	bltu	a0,a2,32a4 <__umoddi3+0x13c>
    3294:	40c508b3          	sub	a7,a0,a2
    3298:	40d586b3          	sub	a3,a1,a3
    329c:	011537b3          	sltu	a5,a0,a7
    32a0:	40f687b3          	sub	a5,a3,a5
    32a4:	00088513          	mv	a0,a7
    32a8:	00078593          	mv	a1,a5
    32ac:	00008067          	ret
    32b0:	0a060e63          	beqz	a2,336c <__umoddi3+0x204>
    32b4:	000107b7          	lui	a5,0x10
    32b8:	2ef67463          	bgeu	a2,a5,35a0 <__umoddi3+0x438>
    32bc:	10063713          	sltiu	a4,a2,256
    32c0:	00173713          	seqz	a4,a4
    32c4:	00371713          	slli	a4,a4,0x3
    32c8:	00e656b3          	srl	a3,a2,a4
    32cc:	00003797          	auipc	a5,0x3
    32d0:	bb478793          	addi	a5,a5,-1100 # 5e80 <__clz_tab>
    32d4:	00d787b3          	add	a5,a5,a3
    32d8:	0007c783          	lbu	a5,0(a5)
    32dc:	02000313          	li	t1,32
    32e0:	00e787b3          	add	a5,a5,a4
    32e4:	40f306b3          	sub	a3,t1,a5
    32e8:	0af31663          	bne	t1,a5,3394 <__umoddi3+0x22c>
    32ec:	40c58733          	sub	a4,a1,a2
    32f0:	01065313          	srli	t1,a2,0x10
    32f4:	01061613          	slli	a2,a2,0x10
    32f8:	01065613          	srli	a2,a2,0x10
    32fc:	026755b3          	divu	a1,a4,t1
    3300:	0108d793          	srli	a5,a7,0x10
    3304:	02677733          	remu	a4,a4,t1
    3308:	02c585b3          	mul	a1,a1,a2
    330c:	01071713          	slli	a4,a4,0x10
    3310:	00e7e7b3          	or	a5,a5,a4
    3314:	00b7fa63          	bgeu	a5,a1,3328 <__umoddi3+0x1c0>
    3318:	00f807b3          	add	a5,a6,a5
    331c:	0107e663          	bltu	a5,a6,3328 <__umoddi3+0x1c0>
    3320:	00b7f463          	bgeu	a5,a1,3328 <__umoddi3+0x1c0>
    3324:	010787b3          	add	a5,a5,a6
    3328:	40b787b3          	sub	a5,a5,a1
    332c:	0267d733          	divu	a4,a5,t1
    3330:	01089893          	slli	a7,a7,0x10
    3334:	0108d893          	srli	a7,a7,0x10
    3338:	0267f7b3          	remu	a5,a5,t1
    333c:	02c70733          	mul	a4,a4,a2
    3340:	01079513          	slli	a0,a5,0x10
    3344:	00a8e533          	or	a0,a7,a0
    3348:	eee560e3          	bltu	a0,a4,3228 <__umoddi3+0xc0>
    334c:	40e50533          	sub	a0,a0,a4
    3350:	00d55533          	srl	a0,a0,a3
    3354:	00000593          	li	a1,0
    3358:	00008067          	ret
    335c:	10063693          	sltiu	a3,a2,256
    3360:	0016b693          	seqz	a3,a3
    3364:	00369693          	slli	a3,a3,0x3
    3368:	e31ff06f          	j	3198 <__umoddi3+0x30>
    336c:	00000693          	li	a3,0
    3370:	00003797          	auipc	a5,0x3
    3374:	b1078793          	addi	a5,a5,-1264 # 5e80 <__clz_tab>
    3378:	00d787b3          	add	a5,a5,a3
    337c:	0007c783          	lbu	a5,0(a5)
    3380:	00000713          	li	a4,0
    3384:	02000313          	li	t1,32
    3388:	00e787b3          	add	a5,a5,a4
    338c:	40f306b3          	sub	a3,t1,a5
    3390:	f4f30ee3          	beq	t1,a5,32ec <__umoddi3+0x184>
    3394:	00d61833          	sll	a6,a2,a3
    3398:	00f5de33          	srl	t3,a1,a5
    339c:	01085313          	srli	t1,a6,0x10
    33a0:	026e5eb3          	divu	t4,t3,t1
    33a4:	01081613          	slli	a2,a6,0x10
    33a8:	00d595b3          	sll	a1,a1,a3
    33ac:	00f55733          	srl	a4,a0,a5
    33b0:	01065613          	srli	a2,a2,0x10
    33b4:	00b76733          	or	a4,a4,a1
    33b8:	01075793          	srli	a5,a4,0x10
    33bc:	00d518b3          	sll	a7,a0,a3
    33c0:	026e7e33          	remu	t3,t3,t1
    33c4:	02ce85b3          	mul	a1,t4,a2
    33c8:	010e1e13          	slli	t3,t3,0x10
    33cc:	01c7e7b3          	or	a5,a5,t3
    33d0:	00b7fa63          	bgeu	a5,a1,33e4 <__umoddi3+0x27c>
    33d4:	00f807b3          	add	a5,a6,a5
    33d8:	0107e663          	bltu	a5,a6,33e4 <__umoddi3+0x27c>
    33dc:	00b7f463          	bgeu	a5,a1,33e4 <__umoddi3+0x27c>
    33e0:	010787b3          	add	a5,a5,a6
    33e4:	40b787b3          	sub	a5,a5,a1
    33e8:	0267d5b3          	divu	a1,a5,t1
    33ec:	01071713          	slli	a4,a4,0x10
    33f0:	01075713          	srli	a4,a4,0x10
    33f4:	0267f7b3          	remu	a5,a5,t1
    33f8:	02c585b3          	mul	a1,a1,a2
    33fc:	01079793          	slli	a5,a5,0x10
    3400:	00f76733          	or	a4,a4,a5
    3404:	00b77a63          	bgeu	a4,a1,3418 <__umoddi3+0x2b0>
    3408:	00e80733          	add	a4,a6,a4
    340c:	01076663          	bltu	a4,a6,3418 <__umoddi3+0x2b0>
    3410:	00b77463          	bgeu	a4,a1,3418 <__umoddi3+0x2b0>
    3414:	01070733          	add	a4,a4,a6
    3418:	40b70733          	sub	a4,a4,a1
    341c:	ee1ff06f          	j	32fc <__umoddi3+0x194>
    3420:	1006b813          	sltiu	a6,a3,256
    3424:	00183813          	seqz	a6,a6
    3428:	00381813          	slli	a6,a6,0x3
    342c:	0106d333          	srl	t1,a3,a6
    3430:	00003717          	auipc	a4,0x3
    3434:	a5070713          	addi	a4,a4,-1456 # 5e80 <__clz_tab>
    3438:	00670733          	add	a4,a4,t1
    343c:	00074703          	lbu	a4,0(a4)
    3440:	02000313          	li	t1,32
    3444:	01070733          	add	a4,a4,a6
    3448:	40e30833          	sub	a6,t1,a4
    344c:	e4e300e3          	beq	t1,a4,328c <__umoddi3+0x124>
    3450:	010696b3          	sll	a3,a3,a6
    3454:	00e658b3          	srl	a7,a2,a4
    3458:	00d8e8b3          	or	a7,a7,a3
    345c:	00e5de33          	srl	t3,a1,a4
    3460:	0108df13          	srli	t5,a7,0x10
    3464:	03ee57b3          	divu	a5,t3,t5
    3468:	01089e93          	slli	t4,a7,0x10
    346c:	010ede93          	srli	t4,t4,0x10
    3470:	00e556b3          	srl	a3,a0,a4
    3474:	01051333          	sll	t1,a0,a6
    3478:	010595b3          	sll	a1,a1,a6
    347c:	00b6e5b3          	or	a1,a3,a1
    3480:	0105d693          	srli	a3,a1,0x10
    3484:	01061633          	sll	a2,a2,a6
    3488:	03ee7e33          	remu	t3,t3,t5
    348c:	02fe8533          	mul	a0,t4,a5
    3490:	010e1e13          	slli	t3,t3,0x10
    3494:	01c6e6b3          	or	a3,a3,t3
    3498:	00a6fe63          	bgeu	a3,a0,34b4 <__umoddi3+0x34c>
    349c:	00d886b3          	add	a3,a7,a3
    34a0:	fff78e13          	addi	t3,a5,-1
    34a4:	1116ec63          	bltu	a3,a7,35bc <__umoddi3+0x454>
    34a8:	10a6fa63          	bgeu	a3,a0,35bc <__umoddi3+0x454>
    34ac:	ffe78793          	addi	a5,a5,-2
    34b0:	011686b3          	add	a3,a3,a7
    34b4:	40a686b3          	sub	a3,a3,a0
    34b8:	03e6d533          	divu	a0,a3,t5
    34bc:	01059593          	slli	a1,a1,0x10
    34c0:	0105d593          	srli	a1,a1,0x10
    34c4:	03e6f6b3          	remu	a3,a3,t5
    34c8:	02ae8eb3          	mul	t4,t4,a0
    34cc:	01069693          	slli	a3,a3,0x10
    34d0:	00d5e5b3          	or	a1,a1,a3
    34d4:	01d5fe63          	bgeu	a1,t4,34f0 <__umoddi3+0x388>
    34d8:	00b885b3          	add	a1,a7,a1
    34dc:	fff50693          	addi	a3,a0,-1
    34e0:	0d15ea63          	bltu	a1,a7,35b4 <__umoddi3+0x44c>
    34e4:	0dd5f863          	bgeu	a1,t4,35b4 <__umoddi3+0x44c>
    34e8:	ffe50513          	addi	a0,a0,-2
    34ec:	011585b3          	add	a1,a1,a7
    34f0:	01079693          	slli	a3,a5,0x10
    34f4:	000102b7          	lui	t0,0x10
    34f8:	00a6e6b3          	or	a3,a3,a0
    34fc:	fff28513          	addi	a0,t0,-1 # ffff <__freertos_irq_stack_top+0x8fcf>
    3500:	00a6fe33          	and	t3,a3,a0
    3504:	01065f93          	srli	t6,a2,0x10
    3508:	0106d693          	srli	a3,a3,0x10
    350c:	00a67533          	and	a0,a2,a0
    3510:	02ae0f33          	mul	t5,t3,a0
    3514:	41d585b3          	sub	a1,a1,t4
    3518:	02a68533          	mul	a0,a3,a0
    351c:	010f5793          	srli	a5,t5,0x10
    3520:	03fe0e33          	mul	t3,t3,t6
    3524:	00ae0e33          	add	t3,t3,a0
    3528:	01c787b3          	add	a5,a5,t3
    352c:	03f686b3          	mul	a3,a3,t6
    3530:	00a7f463          	bgeu	a5,a0,3538 <__umoddi3+0x3d0>
    3534:	005686b3          	add	a3,a3,t0
    3538:	00010eb7          	lui	t4,0x10
    353c:	fffe8e93          	addi	t4,t4,-1 # ffff <__freertos_irq_stack_top+0x8fcf>
    3540:	01d7f533          	and	a0,a5,t4
    3544:	0107de13          	srli	t3,a5,0x10
    3548:	01051513          	slli	a0,a0,0x10
    354c:	01df7f33          	and	t5,t5,t4
    3550:	00de07b3          	add	a5,t3,a3
    3554:	01e50533          	add	a0,a0,t5
    3558:	02f5e863          	bltu	a1,a5,3588 <__umoddi3+0x420>
    355c:	02f58463          	beq	a1,a5,3584 <__umoddi3+0x41c>
    3560:	40a30533          	sub	a0,t1,a0
    3564:	00a33333          	sltu	t1,t1,a0
    3568:	40f585b3          	sub	a1,a1,a5
    356c:	406585b3          	sub	a1,a1,t1
    3570:	00e59733          	sll	a4,a1,a4
    3574:	01055533          	srl	a0,a0,a6
    3578:	00a76533          	or	a0,a4,a0
    357c:	0105d5b3          	srl	a1,a1,a6
    3580:	00008067          	ret
    3584:	fca37ee3          	bgeu	t1,a0,3560 <__umoddi3+0x3f8>
    3588:	40c50633          	sub	a2,a0,a2
    358c:	00c53533          	sltu	a0,a0,a2
    3590:	011508b3          	add	a7,a0,a7
    3594:	411787b3          	sub	a5,a5,a7
    3598:	00060513          	mv	a0,a2
    359c:	fc5ff06f          	j	3560 <__umoddi3+0x3f8>
    35a0:	010007b7          	lui	a5,0x1000
    35a4:	02f67463          	bgeu	a2,a5,35cc <__umoddi3+0x464>
    35a8:	01065693          	srli	a3,a2,0x10
    35ac:	01000713          	li	a4,16
    35b0:	d1dff06f          	j	32cc <__umoddi3+0x164>
    35b4:	00068513          	mv	a0,a3
    35b8:	f39ff06f          	j	34f0 <__umoddi3+0x388>
    35bc:	000e0793          	mv	a5,t3
    35c0:	ef5ff06f          	j	34b4 <__umoddi3+0x34c>
    35c4:	010787b3          	add	a5,a5,a6
    35c8:	c3dff06f          	j	3204 <__umoddi3+0x9c>
    35cc:	01865693          	srli	a3,a2,0x18
    35d0:	01800713          	li	a4,24
    35d4:	cf9ff06f          	j	32cc <__umoddi3+0x164>

000035d8 <__adddf3>:
    35d8:	001007b7          	lui	a5,0x100
    35dc:	fe010113          	addi	sp,sp,-32
    35e0:	fff78e93          	addi	t4,a5,-1 # fffff <__freertos_irq_stack_top+0xf8fcf>
    35e4:	00bef833          	and	a6,t4,a1
    35e8:	00def7b3          	and	a5,t4,a3
    35ec:	0146d313          	srli	t1,a3,0x14
    35f0:	01212823          	sw	s2,16(sp)
    35f4:	0145d913          	srli	s2,a1,0x14
    35f8:	00379793          	slli	a5,a5,0x3
    35fc:	00812c23          	sw	s0,24(sp)
    3600:	00381813          	slli	a6,a6,0x3
    3604:	01f5d413          	srli	s0,a1,0x1f
    3608:	01d55713          	srli	a4,a0,0x1d
    360c:	01d65893          	srli	a7,a2,0x1d
    3610:	7ff97913          	andi	s2,s2,2047
    3614:	7ff37313          	andi	t1,t1,2047
    3618:	00112e23          	sw	ra,28(sp)
    361c:	00912a23          	sw	s1,20(sp)
    3620:	01312623          	sw	s3,12(sp)
    3624:	01f6d693          	srli	a3,a3,0x1f
    3628:	00f8e8b3          	or	a7,a7,a5
    362c:	01076733          	or	a4,a4,a6
    3630:	00351593          	slli	a1,a0,0x3
    3634:	00361f13          	slli	t5,a2,0x3
    3638:	406907b3          	sub	a5,s2,t1
    363c:	1ed40463          	beq	s0,a3,3824 <__adddf3+0x24c>
    3640:	16f05263          	blez	a5,37a4 <__adddf3+0x1cc>
    3644:	28030663          	beqz	t1,38d0 <__adddf3+0x2f8>
    3648:	7ff00693          	li	a3,2047
    364c:	42d90663          	beq	s2,a3,3a78 <__adddf3+0x4a0>
    3650:	03800693          	li	a3,56
    3654:	00100613          	li	a2,1
    3658:	02f6ce63          	blt	a3,a5,3694 <__adddf3+0xbc>
    365c:	008006b7          	lui	a3,0x800
    3660:	00d8e8b3          	or	a7,a7,a3
    3664:	01f00693          	li	a3,31
    3668:	52f6ce63          	blt	a3,a5,3ba4 <__adddf3+0x5cc>
    366c:	02000693          	li	a3,32
    3670:	40f686b3          	sub	a3,a3,a5
    3674:	00d89633          	sll	a2,a7,a3
    3678:	00ff5533          	srl	a0,t5,a5
    367c:	00df16b3          	sll	a3,t5,a3
    3680:	00a66633          	or	a2,a2,a0
    3684:	00d036b3          	snez	a3,a3
    3688:	00f8d8b3          	srl	a7,a7,a5
    368c:	00d66633          	or	a2,a2,a3
    3690:	41170733          	sub	a4,a4,a7
    3694:	40c58633          	sub	a2,a1,a2
    3698:	00c5b5b3          	sltu	a1,a1,a2
    369c:	00060493          	mv	s1,a2
    36a0:	40b709b3          	sub	s3,a4,a1
    36a4:	00899793          	slli	a5,s3,0x8
    36a8:	3207da63          	bgez	a5,39dc <__adddf3+0x404>
    36ac:	008007b7          	lui	a5,0x800
    36b0:	fff78793          	addi	a5,a5,-1 # 7fffff <__freertos_irq_stack_top+0x7f8fcf>
    36b4:	00f9f9b3          	and	s3,s3,a5
    36b8:	2c098863          	beqz	s3,3988 <__adddf3+0x3b0>
    36bc:	00098513          	mv	a0,s3
    36c0:	458020ef          	jal	5b18 <__clzsi2>
    36c4:	ff850793          	addi	a5,a0,-8
    36c8:	02000693          	li	a3,32
    36cc:	40f68733          	sub	a4,a3,a5
    36d0:	00e4d733          	srl	a4,s1,a4
    36d4:	00f999b3          	sll	s3,s3,a5
    36d8:	01376733          	or	a4,a4,s3
    36dc:	00f494b3          	sll	s1,s1,a5
    36e0:	4b27c863          	blt	a5,s2,3b90 <__adddf3+0x5b8>
    36e4:	412787b3          	sub	a5,a5,s2
    36e8:	00178793          	addi	a5,a5,1
    36ec:	40f686b3          	sub	a3,a3,a5
    36f0:	00d49633          	sll	a2,s1,a3
    36f4:	00f4d9b3          	srl	s3,s1,a5
    36f8:	00c03633          	snez	a2,a2
    36fc:	01366633          	or	a2,a2,s3
    3700:	00d716b3          	sll	a3,a4,a3
    3704:	00c6e4b3          	or	s1,a3,a2
    3708:	00f759b3          	srl	s3,a4,a5
    370c:	00000913          	li	s2,0
    3710:	0074f793          	andi	a5,s1,7
    3714:	02078063          	beqz	a5,3734 <__adddf3+0x15c>
    3718:	00f4f793          	andi	a5,s1,15
    371c:	00400713          	li	a4,4
    3720:	00e78a63          	beq	a5,a4,3734 <__adddf3+0x15c>
    3724:	00448793          	addi	a5,s1,4
    3728:	0097b633          	sltu	a2,a5,s1
    372c:	00c989b3          	add	s3,s3,a2
    3730:	00078493          	mv	s1,a5
    3734:	00899793          	slli	a5,s3,0x8
    3738:	6e07da63          	bgez	a5,3e2c <__adddf3+0x854>
    373c:	00190793          	addi	a5,s2,1
    3740:	7ff00713          	li	a4,2047
    3744:	00040e13          	mv	t3,s0
    3748:	2ae78663          	beq	a5,a4,39f4 <__adddf3+0x41c>
    374c:	ff800737          	lui	a4,0xff800
    3750:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8fcf>
    3754:	00e9f733          	and	a4,s3,a4
    3758:	7ff7f793          	andi	a5,a5,2047
    375c:	01d71813          	slli	a6,a4,0x1d
    3760:	0034d613          	srli	a2,s1,0x3
    3764:	00971713          	slli	a4,a4,0x9
    3768:	00c86833          	or	a6,a6,a2
    376c:	00c75713          	srli	a4,a4,0xc
    3770:	01c12083          	lw	ra,28(sp)
    3774:	01812403          	lw	s0,24(sp)
    3778:	01479793          	slli	a5,a5,0x14
    377c:	00e7e7b3          	or	a5,a5,a4
    3780:	01fe1713          	slli	a4,t3,0x1f
    3784:	00e7e7b3          	or	a5,a5,a4
    3788:	01412483          	lw	s1,20(sp)
    378c:	01012903          	lw	s2,16(sp)
    3790:	00c12983          	lw	s3,12(sp)
    3794:	00080513          	mv	a0,a6
    3798:	00078593          	mv	a1,a5
    379c:	02010113          	addi	sp,sp,32
    37a0:	00008067          	ret
    37a4:	14078c63          	beqz	a5,38fc <__adddf3+0x324>
    37a8:	412307b3          	sub	a5,t1,s2
    37ac:	3c091263          	bnez	s2,3b70 <__adddf3+0x598>
    37b0:	00b76533          	or	a0,a4,a1
    37b4:	4c050463          	beqz	a0,3c7c <__adddf3+0x6a4>
    37b8:	fff78513          	addi	a0,a5,-1
    37bc:	60050263          	beqz	a0,3dc0 <__adddf3+0x7e8>
    37c0:	7ff00813          	li	a6,2047
    37c4:	57078663          	beq	a5,a6,3d30 <__adddf3+0x758>
    37c8:	03800793          	li	a5,56
    37cc:	00100613          	li	a2,1
    37d0:	02a7cc63          	blt	a5,a0,3808 <__adddf3+0x230>
    37d4:	00050793          	mv	a5,a0
    37d8:	01f00613          	li	a2,31
    37dc:	56f64c63          	blt	a2,a5,3d54 <__adddf3+0x77c>
    37e0:	02000513          	li	a0,32
    37e4:	40f50533          	sub	a0,a0,a5
    37e8:	00a71633          	sll	a2,a4,a0
    37ec:	00f5d833          	srl	a6,a1,a5
    37f0:	00a59533          	sll	a0,a1,a0
    37f4:	01066633          	or	a2,a2,a6
    37f8:	00a03533          	snez	a0,a0
    37fc:	00f75733          	srl	a4,a4,a5
    3800:	00a66633          	or	a2,a2,a0
    3804:	40e888b3          	sub	a7,a7,a4
    3808:	40cf0633          	sub	a2,t5,a2
    380c:	00cf3733          	sltu	a4,t5,a2
    3810:	00060493          	mv	s1,a2
    3814:	40e889b3          	sub	s3,a7,a4
    3818:	00030913          	mv	s2,t1
    381c:	00068413          	mv	s0,a3
    3820:	e85ff06f          	j	36a4 <__adddf3+0xcc>
    3824:	1ef05063          	blez	a5,3a04 <__adddf3+0x42c>
    3828:	14031063          	bnez	t1,3968 <__adddf3+0x390>
    382c:	01e8e6b3          	or	a3,a7,t5
    3830:	26068c63          	beqz	a3,3aa8 <__adddf3+0x4d0>
    3834:	fff78693          	addi	a3,a5,-1
    3838:	48068063          	beqz	a3,3cb8 <__adddf3+0x6e0>
    383c:	7ff00613          	li	a2,2047
    3840:	22c78c63          	beq	a5,a2,3a78 <__adddf3+0x4a0>
    3844:	03800793          	li	a5,56
    3848:	00100993          	li	s3,1
    384c:	02d7cc63          	blt	a5,a3,3884 <__adddf3+0x2ac>
    3850:	00068793          	mv	a5,a3
    3854:	01f00693          	li	a3,31
    3858:	4af6c063          	blt	a3,a5,3cf8 <__adddf3+0x720>
    385c:	02000693          	li	a3,32
    3860:	40f686b3          	sub	a3,a3,a5
    3864:	00d899b3          	sll	s3,a7,a3
    3868:	00ff5633          	srl	a2,t5,a5
    386c:	00df16b3          	sll	a3,t5,a3
    3870:	00c9e9b3          	or	s3,s3,a2
    3874:	00d036b3          	snez	a3,a3
    3878:	00f8d8b3          	srl	a7,a7,a5
    387c:	00d9e9b3          	or	s3,s3,a3
    3880:	01170733          	add	a4,a4,a7
    3884:	00b985b3          	add	a1,s3,a1
    3888:	0135b9b3          	sltu	s3,a1,s3
    388c:	00058493          	mv	s1,a1
    3890:	00e989b3          	add	s3,s3,a4
    3894:	00899793          	slli	a5,s3,0x8
    3898:	1407d263          	bgez	a5,39dc <__adddf3+0x404>
    389c:	00190913          	addi	s2,s2,1
    38a0:	7ff00793          	li	a5,2047
    38a4:	36f90c63          	beq	s2,a5,3c1c <__adddf3+0x644>
    38a8:	ff8007b7          	lui	a5,0xff800
    38ac:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8fcf>
    38b0:	0014f613          	andi	a2,s1,1
    38b4:	00f9f7b3          	and	a5,s3,a5
    38b8:	0014d713          	srli	a4,s1,0x1
    38bc:	00c76733          	or	a4,a4,a2
    38c0:	01f79613          	slli	a2,a5,0x1f
    38c4:	00e664b3          	or	s1,a2,a4
    38c8:	0017d993          	srli	s3,a5,0x1
    38cc:	e45ff06f          	j	3710 <__adddf3+0x138>
    38d0:	01e8e6b3          	or	a3,a7,t5
    38d4:	1c068a63          	beqz	a3,3aa8 <__adddf3+0x4d0>
    38d8:	fff78693          	addi	a3,a5,-1
    38dc:	40068063          	beqz	a3,3cdc <__adddf3+0x704>
    38e0:	7ff00613          	li	a2,2047
    38e4:	18c78a63          	beq	a5,a2,3a78 <__adddf3+0x4a0>
    38e8:	03800793          	li	a5,56
    38ec:	00100613          	li	a2,1
    38f0:	dad7c2e3          	blt	a5,a3,3694 <__adddf3+0xbc>
    38f4:	00068793          	mv	a5,a3
    38f8:	d6dff06f          	j	3664 <__adddf3+0x8c>
    38fc:	00190813          	addi	a6,s2,1
    3900:	7fe87813          	andi	a6,a6,2046
    3904:	22081c63          	bnez	a6,3b3c <__adddf3+0x564>
    3908:	00b76333          	or	t1,a4,a1
    390c:	01e8e833          	or	a6,a7,t5
    3910:	38091063          	bnez	s2,3c90 <__adddf3+0x6b8>
    3914:	46030e63          	beqz	t1,3d90 <__adddf3+0x7b8>
    3918:	40080663          	beqz	a6,3d24 <__adddf3+0x74c>
    391c:	41e589b3          	sub	s3,a1,t5
    3920:	0135b533          	sltu	a0,a1,s3
    3924:	41170633          	sub	a2,a4,a7
    3928:	40a60633          	sub	a2,a2,a0
    392c:	00861513          	slli	a0,a2,0x8
    3930:	50055e63          	bgez	a0,3e4c <__adddf3+0x874>
    3934:	40bf05b3          	sub	a1,t5,a1
    3938:	40e88733          	sub	a4,a7,a4
    393c:	00bf3f33          	sltu	t5,t5,a1
    3940:	41e70733          	sub	a4,a4,t5
    3944:	00871613          	slli	a2,a4,0x8
    3948:	00058493          	mv	s1,a1
    394c:	52065e63          	bgez	a2,3e88 <__adddf3+0x8b0>
    3950:	ff8007b7          	lui	a5,0xff800
    3954:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8fcf>
    3958:	00f77733          	and	a4,a4,a5
    395c:	00068e13          	mv	t3,a3
    3960:	00100793          	li	a5,1
    3964:	df9ff06f          	j	375c <__adddf3+0x184>
    3968:	7ff00693          	li	a3,2047
    396c:	10d90663          	beq	s2,a3,3a78 <__adddf3+0x4a0>
    3970:	03800693          	li	a3,56
    3974:	00100993          	li	s3,1
    3978:	f0f6c6e3          	blt	a3,a5,3884 <__adddf3+0x2ac>
    397c:	008006b7          	lui	a3,0x800
    3980:	00d8e8b3          	or	a7,a7,a3
    3984:	ed1ff06f          	j	3854 <__adddf3+0x27c>
    3988:	00048513          	mv	a0,s1
    398c:	18c020ef          	jal	5b18 <__clzsi2>
    3990:	01850793          	addi	a5,a0,24
    3994:	01f00693          	li	a3,31
    3998:	d2f6d8e3          	bge	a3,a5,36c8 <__adddf3+0xf0>
    399c:	ff850713          	addi	a4,a0,-8
    39a0:	00e49733          	sll	a4,s1,a4
    39a4:	2327c663          	blt	a5,s2,3bd0 <__adddf3+0x5f8>
    39a8:	41278933          	sub	s2,a5,s2
    39ac:	00190793          	addi	a5,s2,1
    39b0:	48f6d663          	bge	a3,a5,3e3c <__adddf3+0x864>
    39b4:	fe190913          	addi	s2,s2,-31
    39b8:	02000693          	li	a3,32
    39bc:	012754b3          	srl	s1,a4,s2
    39c0:	00d78c63          	beq	a5,a3,39d8 <__adddf3+0x400>
    39c4:	04000693          	li	a3,64
    39c8:	40f687b3          	sub	a5,a3,a5
    39cc:	00f71733          	sll	a4,a4,a5
    39d0:	00e03733          	snez	a4,a4
    39d4:	00e4e4b3          	or	s1,s1,a4
    39d8:	00000913          	li	s2,0
    39dc:	0074f793          	andi	a5,s1,7
    39e0:	d2079ce3          	bnez	a5,3718 <__adddf3+0x140>
    39e4:	00090793          	mv	a5,s2
    39e8:	0034d613          	srli	a2,s1,0x3
    39ec:	00098713          	mv	a4,s3
    39f0:	0c00006f          	j	3ab0 <__adddf3+0x4d8>
    39f4:	7ff00793          	li	a5,2047
    39f8:	00000713          	li	a4,0
    39fc:	00000813          	li	a6,0
    3a00:	d71ff06f          	j	3770 <__adddf3+0x198>
    3a04:	0c078a63          	beqz	a5,3ad8 <__adddf3+0x500>
    3a08:	412307b3          	sub	a5,t1,s2
    3a0c:	1e090263          	beqz	s2,3bf0 <__adddf3+0x618>
    3a10:	7ff00693          	li	a3,2047
    3a14:	32d30863          	beq	t1,a3,3d44 <__adddf3+0x76c>
    3a18:	03800693          	li	a3,56
    3a1c:	00100993          	li	s3,1
    3a20:	02f6ce63          	blt	a3,a5,3a5c <__adddf3+0x484>
    3a24:	008006b7          	lui	a3,0x800
    3a28:	00d76733          	or	a4,a4,a3
    3a2c:	01f00693          	li	a3,31
    3a30:	3cf6c863          	blt	a3,a5,3e00 <__adddf3+0x828>
    3a34:	02000693          	li	a3,32
    3a38:	40f686b3          	sub	a3,a3,a5
    3a3c:	00d719b3          	sll	s3,a4,a3
    3a40:	00f5d633          	srl	a2,a1,a5
    3a44:	00d596b3          	sll	a3,a1,a3
    3a48:	00c9e9b3          	or	s3,s3,a2
    3a4c:	00d036b3          	snez	a3,a3
    3a50:	00f75733          	srl	a4,a4,a5
    3a54:	00d9e9b3          	or	s3,s3,a3
    3a58:	00e888b3          	add	a7,a7,a4
    3a5c:	01e98733          	add	a4,s3,t5
    3a60:	013739b3          	sltu	s3,a4,s3
    3a64:	00070493          	mv	s1,a4
    3a68:	011989b3          	add	s3,s3,a7
    3a6c:	00030913          	mv	s2,t1
    3a70:	e25ff06f          	j	3894 <__adddf3+0x2bc>
    3a74:	02081063          	bnez	a6,3a94 <__adddf3+0x4bc>
    3a78:	00351613          	slli	a2,a0,0x3
    3a7c:	00365613          	srli	a2,a2,0x3
    3a80:	01d71813          	slli	a6,a4,0x1d
    3a84:	00c86833          	or	a6,a6,a2
    3a88:	00375713          	srli	a4,a4,0x3
    3a8c:	01076733          	or	a4,a4,a6
    3a90:	18070663          	beqz	a4,3c1c <__adddf3+0x644>
    3a94:	00000e13          	li	t3,0
    3a98:	7ff00793          	li	a5,2047
    3a9c:	00080737          	lui	a4,0x80
    3aa0:	00000813          	li	a6,0
    3aa4:	ccdff06f          	j	3770 <__adddf3+0x198>
    3aa8:	00351613          	slli	a2,a0,0x3
    3aac:	00365613          	srli	a2,a2,0x3
    3ab0:	01d71813          	slli	a6,a4,0x1d
    3ab4:	7ff00693          	li	a3,2047
    3ab8:	00c86833          	or	a6,a6,a2
    3abc:	00375713          	srli	a4,a4,0x3
    3ac0:	fcd786e3          	beq	a5,a3,3a8c <__adddf3+0x4b4>
    3ac4:	00c71713          	slli	a4,a4,0xc
    3ac8:	00c75713          	srli	a4,a4,0xc
    3acc:	7ff7f793          	andi	a5,a5,2047
    3ad0:	00040e13          	mv	t3,s0
    3ad4:	c9dff06f          	j	3770 <__adddf3+0x198>
    3ad8:	00190693          	addi	a3,s2,1
    3adc:	7fe6f813          	andi	a6,a3,2046
    3ae0:	14081863          	bnez	a6,3c30 <__adddf3+0x658>
    3ae4:	00b766b3          	or	a3,a4,a1
    3ae8:	28091c63          	bnez	s2,3d80 <__adddf3+0x7a8>
    3aec:	30068263          	beqz	a3,3df0 <__adddf3+0x818>
    3af0:	01e8e6b3          	or	a3,a7,t5
    3af4:	22068863          	beqz	a3,3d24 <__adddf3+0x74c>
    3af8:	01e587b3          	add	a5,a1,t5
    3afc:	00b7b5b3          	sltu	a1,a5,a1
    3b00:	01170733          	add	a4,a4,a7
    3b04:	00b70733          	add	a4,a4,a1
    3b08:	0037d813          	srli	a6,a5,0x3
    3b0c:	00871793          	slli	a5,a4,0x8
    3b10:	00040e13          	mv	t3,s0
    3b14:	3407de63          	bgez	a5,3e70 <__adddf3+0x898>
    3b18:	ff8007b7          	lui	a5,0xff800
    3b1c:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8fcf>
    3b20:	00f77733          	and	a4,a4,a5
    3b24:	01d71793          	slli	a5,a4,0x1d
    3b28:	00375713          	srli	a4,a4,0x3
    3b2c:	0107e833          	or	a6,a5,a6
    3b30:	01d77733          	and	a4,a4,t4
    3b34:	00100793          	li	a5,1
    3b38:	c39ff06f          	j	3770 <__adddf3+0x198>
    3b3c:	41e58833          	sub	a6,a1,t5
    3b40:	0105b7b3          	sltu	a5,a1,a6
    3b44:	411709b3          	sub	s3,a4,a7
    3b48:	40f989b3          	sub	s3,s3,a5
    3b4c:	00899793          	slli	a5,s3,0x8
    3b50:	00080493          	mv	s1,a6
    3b54:	1007c663          	bltz	a5,3c60 <__adddf3+0x688>
    3b58:	01386833          	or	a6,a6,s3
    3b5c:	b4081ee3          	bnez	a6,36b8 <__adddf3+0xe0>
    3b60:	00000e13          	li	t3,0
    3b64:	00000793          	li	a5,0
    3b68:	00000713          	li	a4,0
    3b6c:	c05ff06f          	j	3770 <__adddf3+0x198>
    3b70:	7ff00513          	li	a0,2047
    3b74:	1aa30e63          	beq	t1,a0,3d30 <__adddf3+0x758>
    3b78:	03800513          	li	a0,56
    3b7c:	00100613          	li	a2,1
    3b80:	c8f544e3          	blt	a0,a5,3808 <__adddf3+0x230>
    3b84:	00800637          	lui	a2,0x800
    3b88:	00c76733          	or	a4,a4,a2
    3b8c:	c4dff06f          	j	37d8 <__adddf3+0x200>
    3b90:	ff8009b7          	lui	s3,0xff800
    3b94:	fff98993          	addi	s3,s3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8fcf>
    3b98:	40f90933          	sub	s2,s2,a5
    3b9c:	013779b3          	and	s3,a4,s3
    3ba0:	b71ff06f          	j	3710 <__adddf3+0x138>
    3ba4:	fe078693          	addi	a3,a5,-32
    3ba8:	02000613          	li	a2,32
    3bac:	00d8d6b3          	srl	a3,a7,a3
    3bb0:	00c78a63          	beq	a5,a2,3bc4 <__adddf3+0x5ec>
    3bb4:	04000613          	li	a2,64
    3bb8:	40f607b3          	sub	a5,a2,a5
    3bbc:	00f897b3          	sll	a5,a7,a5
    3bc0:	00ff6f33          	or	t5,t5,a5
    3bc4:	01e03633          	snez	a2,t5
    3bc8:	00d66633          	or	a2,a2,a3
    3bcc:	ac9ff06f          	j	3694 <__adddf3+0xbc>
    3bd0:	ff8006b7          	lui	a3,0xff800
    3bd4:	fff68693          	addi	a3,a3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8fcf>
    3bd8:	40f907b3          	sub	a5,s2,a5
    3bdc:	00d77733          	and	a4,a4,a3
    3be0:	01d71813          	slli	a6,a4,0x1d
    3be4:	01386833          	or	a6,a6,s3
    3be8:	00375713          	srli	a4,a4,0x3
    3bec:	ed9ff06f          	j	3ac4 <__adddf3+0x4ec>
    3bf0:	00b766b3          	or	a3,a4,a1
    3bf4:	1e068663          	beqz	a3,3de0 <__adddf3+0x808>
    3bf8:	fff78693          	addi	a3,a5,-1
    3bfc:	0a068e63          	beqz	a3,3cb8 <__adddf3+0x6e0>
    3c00:	7ff00513          	li	a0,2047
    3c04:	14a78063          	beq	a5,a0,3d44 <__adddf3+0x76c>
    3c08:	03800793          	li	a5,56
    3c0c:	00100993          	li	s3,1
    3c10:	e4d7c6e3          	blt	a5,a3,3a5c <__adddf3+0x484>
    3c14:	00068793          	mv	a5,a3
    3c18:	e15ff06f          	j	3a2c <__adddf3+0x454>
    3c1c:	00040e13          	mv	t3,s0
    3c20:	7ff00793          	li	a5,2047
    3c24:	00000713          	li	a4,0
    3c28:	00000813          	li	a6,0
    3c2c:	b45ff06f          	j	3770 <__adddf3+0x198>
    3c30:	7ff00793          	li	a5,2047
    3c34:	fef684e3          	beq	a3,a5,3c1c <__adddf3+0x644>
    3c38:	01e58f33          	add	t5,a1,t5
    3c3c:	00bf35b3          	sltu	a1,t5,a1
    3c40:	011707b3          	add	a5,a4,a7
    3c44:	00b787b3          	add	a5,a5,a1
    3c48:	01f79613          	slli	a2,a5,0x1f
    3c4c:	001f5f13          	srli	t5,t5,0x1
    3c50:	01e664b3          	or	s1,a2,t5
    3c54:	0017d993          	srli	s3,a5,0x1
    3c58:	00068913          	mv	s2,a3
    3c5c:	ab5ff06f          	j	3710 <__adddf3+0x138>
    3c60:	40bf0633          	sub	a2,t5,a1
    3c64:	40e887b3          	sub	a5,a7,a4
    3c68:	00cf3733          	sltu	a4,t5,a2
    3c6c:	00060493          	mv	s1,a2
    3c70:	40e789b3          	sub	s3,a5,a4
    3c74:	00068413          	mv	s0,a3
    3c78:	a41ff06f          	j	36b8 <__adddf3+0xe0>
    3c7c:	00361613          	slli	a2,a2,0x3
    3c80:	00365613          	srli	a2,a2,0x3
    3c84:	00068413          	mv	s0,a3
    3c88:	00088713          	mv	a4,a7
    3c8c:	e25ff06f          	j	3ab0 <__adddf3+0x4d8>
    3c90:	de0312e3          	bnez	t1,3a74 <__adddf3+0x49c>
    3c94:	1c080663          	beqz	a6,3e60 <__adddf3+0x888>
    3c98:	0038d713          	srli	a4,a7,0x3
    3c9c:	00361613          	slli	a2,a2,0x3
    3ca0:	01d89893          	slli	a7,a7,0x1d
    3ca4:	01176733          	or	a4,a4,a7
    3ca8:	00365613          	srli	a2,a2,0x3
    3cac:	00c76733          	or	a4,a4,a2
    3cb0:	00068413          	mv	s0,a3
    3cb4:	dddff06f          	j	3a90 <__adddf3+0x4b8>
    3cb8:	01e58f33          	add	t5,a1,t5
    3cbc:	011708b3          	add	a7,a4,a7
    3cc0:	00bf35b3          	sltu	a1,t5,a1
    3cc4:	00b889b3          	add	s3,a7,a1
    3cc8:	00899793          	slli	a5,s3,0x8
    3ccc:	000f0493          	mv	s1,t5
    3cd0:	0e07d463          	bgez	a5,3db8 <__adddf3+0x7e0>
    3cd4:	00200913          	li	s2,2
    3cd8:	bd1ff06f          	j	38a8 <__adddf3+0x2d0>
    3cdc:	41e58f33          	sub	t5,a1,t5
    3ce0:	411708b3          	sub	a7,a4,a7
    3ce4:	01e5b5b3          	sltu	a1,a1,t5
    3ce8:	000f0493          	mv	s1,t5
    3cec:	40b889b3          	sub	s3,a7,a1
    3cf0:	00100913          	li	s2,1
    3cf4:	9b1ff06f          	j	36a4 <__adddf3+0xcc>
    3cf8:	fe078693          	addi	a3,a5,-32
    3cfc:	02000613          	li	a2,32
    3d00:	00d8d6b3          	srl	a3,a7,a3
    3d04:	00c78a63          	beq	a5,a2,3d18 <__adddf3+0x740>
    3d08:	04000613          	li	a2,64
    3d0c:	40f607b3          	sub	a5,a2,a5
    3d10:	00f897b3          	sll	a5,a7,a5
    3d14:	00ff6f33          	or	t5,t5,a5
    3d18:	01e039b3          	snez	s3,t5
    3d1c:	00d9e9b3          	or	s3,s3,a3
    3d20:	b65ff06f          	j	3884 <__adddf3+0x2ac>
    3d24:	00351613          	slli	a2,a0,0x3
    3d28:	00365993          	srli	s3,a2,0x3
    3d2c:	eb5ff06f          	j	3be0 <__adddf3+0x608>
    3d30:	00361613          	slli	a2,a2,0x3
    3d34:	00365613          	srli	a2,a2,0x3
    3d38:	00068413          	mv	s0,a3
    3d3c:	00088713          	mv	a4,a7
    3d40:	d41ff06f          	j	3a80 <__adddf3+0x4a8>
    3d44:	00361613          	slli	a2,a2,0x3
    3d48:	00365613          	srli	a2,a2,0x3
    3d4c:	00088713          	mv	a4,a7
    3d50:	d31ff06f          	j	3a80 <__adddf3+0x4a8>
    3d54:	fe078513          	addi	a0,a5,-32
    3d58:	02000613          	li	a2,32
    3d5c:	00a75533          	srl	a0,a4,a0
    3d60:	00c78a63          	beq	a5,a2,3d74 <__adddf3+0x79c>
    3d64:	04000613          	li	a2,64
    3d68:	40f607b3          	sub	a5,a2,a5
    3d6c:	00f717b3          	sll	a5,a4,a5
    3d70:	00f5e5b3          	or	a1,a1,a5
    3d74:	00b03633          	snez	a2,a1
    3d78:	00a66633          	or	a2,a2,a0
    3d7c:	a8dff06f          	j	3808 <__adddf3+0x230>
    3d80:	fc0682e3          	beqz	a3,3d44 <__adddf3+0x76c>
    3d84:	01e8ef33          	or	t5,a7,t5
    3d88:	d00f16e3          	bnez	t5,3a94 <__adddf3+0x4bc>
    3d8c:	cedff06f          	j	3a78 <__adddf3+0x4a0>
    3d90:	dc0808e3          	beqz	a6,3b60 <__adddf3+0x588>
    3d94:	00361813          	slli	a6,a2,0x3
    3d98:	01d89793          	slli	a5,a7,0x1d
    3d9c:	00385813          	srli	a6,a6,0x3
    3da0:	0038d713          	srli	a4,a7,0x3
    3da4:	00f86833          	or	a6,a6,a5
    3da8:	01d77733          	and	a4,a4,t4
    3dac:	00068e13          	mv	t3,a3
    3db0:	00000793          	li	a5,0
    3db4:	9bdff06f          	j	3770 <__adddf3+0x198>
    3db8:	00100793          	li	a5,1
    3dbc:	c2dff06f          	j	39e8 <__adddf3+0x410>
    3dc0:	40bf05b3          	sub	a1,t5,a1
    3dc4:	40e888b3          	sub	a7,a7,a4
    3dc8:	00bf3733          	sltu	a4,t5,a1
    3dcc:	00058493          	mv	s1,a1
    3dd0:	40e889b3          	sub	s3,a7,a4
    3dd4:	00068413          	mv	s0,a3
    3dd8:	00100913          	li	s2,1
    3ddc:	8c9ff06f          	j	36a4 <__adddf3+0xcc>
    3de0:	00361613          	slli	a2,a2,0x3
    3de4:	00365613          	srli	a2,a2,0x3
    3de8:	00088713          	mv	a4,a7
    3dec:	cc5ff06f          	j	3ab0 <__adddf3+0x4d8>
    3df0:	00361613          	slli	a2,a2,0x3
    3df4:	00365993          	srli	s3,a2,0x3
    3df8:	00088713          	mv	a4,a7
    3dfc:	de5ff06f          	j	3be0 <__adddf3+0x608>
    3e00:	fe078693          	addi	a3,a5,-32
    3e04:	02000613          	li	a2,32
    3e08:	00d756b3          	srl	a3,a4,a3
    3e0c:	00c78a63          	beq	a5,a2,3e20 <__adddf3+0x848>
    3e10:	04000613          	li	a2,64
    3e14:	40f607b3          	sub	a5,a2,a5
    3e18:	00f717b3          	sll	a5,a4,a5
    3e1c:	00f5e5b3          	or	a1,a1,a5
    3e20:	00b039b3          	snez	s3,a1
    3e24:	00d9e9b3          	or	s3,s3,a3
    3e28:	c35ff06f          	j	3a5c <__adddf3+0x484>
    3e2c:	0034d613          	srli	a2,s1,0x3
    3e30:	00090793          	mv	a5,s2
    3e34:	00098713          	mv	a4,s3
    3e38:	c79ff06f          	j	3ab0 <__adddf3+0x4d8>
    3e3c:	02000693          	li	a3,32
    3e40:	40f686b3          	sub	a3,a3,a5
    3e44:	00000613          	li	a2,0
    3e48:	8b5ff06f          	j	36fc <__adddf3+0x124>
    3e4c:	00c9e833          	or	a6,s3,a2
    3e50:	d00808e3          	beqz	a6,3b60 <__adddf3+0x588>
    3e54:	0039d993          	srli	s3,s3,0x3
    3e58:	00060713          	mv	a4,a2
    3e5c:	d85ff06f          	j	3be0 <__adddf3+0x608>
    3e60:	00000e13          	li	t3,0
    3e64:	7ff00793          	li	a5,2047
    3e68:	00080737          	lui	a4,0x80
    3e6c:	905ff06f          	j	3770 <__adddf3+0x198>
    3e70:	01d71793          	slli	a5,a4,0x1d
    3e74:	00375713          	srli	a4,a4,0x3
    3e78:	0107e833          	or	a6,a5,a6
    3e7c:	01d77733          	and	a4,a4,t4
    3e80:	00000793          	li	a5,0
    3e84:	8edff06f          	j	3770 <__adddf3+0x198>
    3e88:	01d71813          	slli	a6,a4,0x1d
    3e8c:	0035d593          	srli	a1,a1,0x3
    3e90:	00b86833          	or	a6,a6,a1
    3e94:	00375713          	srli	a4,a4,0x3
    3e98:	00068413          	mv	s0,a3
    3e9c:	c29ff06f          	j	3ac4 <__adddf3+0x4ec>

00003ea0 <__divdf3>:
    3ea0:	fd010113          	addi	sp,sp,-48
    3ea4:	01312e23          	sw	s3,28(sp)
    3ea8:	0145d993          	srli	s3,a1,0x14
    3eac:	02812423          	sw	s0,40(sp)
    3eb0:	02912223          	sw	s1,36(sp)
    3eb4:	03212023          	sw	s2,32(sp)
    3eb8:	01412c23          	sw	s4,24(sp)
    3ebc:	01712623          	sw	s7,12(sp)
    3ec0:	00c59493          	slli	s1,a1,0xc
    3ec4:	02112623          	sw	ra,44(sp)
    3ec8:	01512a23          	sw	s5,20(sp)
    3ecc:	01612823          	sw	s6,16(sp)
    3ed0:	01812423          	sw	s8,8(sp)
    3ed4:	7ff9f993          	andi	s3,s3,2047
    3ed8:	00050413          	mv	s0,a0
    3edc:	00060b93          	mv	s7,a2
    3ee0:	00068913          	mv	s2,a3
    3ee4:	00c4d493          	srli	s1,s1,0xc
    3ee8:	01f5da13          	srli	s4,a1,0x1f
    3eec:	18098c63          	beqz	s3,4084 <__divdf3+0x1e4>
    3ef0:	7ff00793          	li	a5,2047
    3ef4:	08f98a63          	beq	s3,a5,3f88 <__divdf3+0xe8>
    3ef8:	00349493          	slli	s1,s1,0x3
    3efc:	01d55793          	srli	a5,a0,0x1d
    3f00:	0097e7b3          	or	a5,a5,s1
    3f04:	00800737          	lui	a4,0x800
    3f08:	00e7eab3          	or	s5,a5,a4
    3f0c:	00351b13          	slli	s6,a0,0x3
    3f10:	c0198993          	addi	s3,s3,-1023
    3f14:	00000493          	li	s1,0
    3f18:	00000c13          	li	s8,0
    3f1c:	01495793          	srli	a5,s2,0x14
    3f20:	00c91413          	slli	s0,s2,0xc
    3f24:	7ff7f793          	andi	a5,a5,2047
    3f28:	00c45413          	srli	s0,s0,0xc
    3f2c:	01f95913          	srli	s2,s2,0x1f
    3f30:	08078463          	beqz	a5,3fb8 <__divdf3+0x118>
    3f34:	7ff00713          	li	a4,2047
    3f38:	18e78c63          	beq	a5,a4,40d0 <__divdf3+0x230>
    3f3c:	00341413          	slli	s0,s0,0x3
    3f40:	01dbd713          	srli	a4,s7,0x1d
    3f44:	00876733          	or	a4,a4,s0
    3f48:	c0178793          	addi	a5,a5,-1023
    3f4c:	00800437          	lui	s0,0x800
    3f50:	00876433          	or	s0,a4,s0
    3f54:	003b9893          	slli	a7,s7,0x3
    3f58:	40f989b3          	sub	s3,s3,a5
    3f5c:	00000613          	li	a2,0
    3f60:	00f00713          	li	a4,15
    3f64:	012a46b3          	xor	a3,s4,s2
    3f68:	24976663          	bltu	a4,s1,41b4 <__divdf3+0x314>
    3f6c:	00002717          	auipc	a4,0x2
    3f70:	ed470713          	addi	a4,a4,-300 # 5e40 <pow10.0+0x50>
    3f74:	00249493          	slli	s1,s1,0x2
    3f78:	00e484b3          	add	s1,s1,a4
    3f7c:	0004a783          	lw	a5,0(s1)
    3f80:	00e787b3          	add	a5,a5,a4
    3f84:	00078067          	jr	a5
    3f88:	00a4eab3          	or	s5,s1,a0
    3f8c:	1c0a9e63          	bnez	s5,4168 <__divdf3+0x2c8>
    3f90:	01495793          	srli	a5,s2,0x14
    3f94:	00c91413          	slli	s0,s2,0xc
    3f98:	7ff7f793          	andi	a5,a5,2047
    3f9c:	00000b13          	li	s6,0
    3fa0:	00800493          	li	s1,8
    3fa4:	7ff00993          	li	s3,2047
    3fa8:	00200c13          	li	s8,2
    3fac:	00c45413          	srli	s0,s0,0xc
    3fb0:	01f95913          	srli	s2,s2,0x1f
    3fb4:	f80790e3          	bnez	a5,3f34 <__divdf3+0x94>
    3fb8:	017468b3          	or	a7,s0,s7
    3fbc:	1c088263          	beqz	a7,4180 <__divdf3+0x2e0>
    3fc0:	4a040a63          	beqz	s0,4474 <__divdf3+0x5d4>
    3fc4:	00040513          	mv	a0,s0
    3fc8:	351010ef          	jal	5b18 <__clzsi2>
    3fcc:	00050793          	mv	a5,a0
    3fd0:	ff550693          	addi	a3,a0,-11
    3fd4:	01d00713          	li	a4,29
    3fd8:	ff878893          	addi	a7,a5,-8
    3fdc:	40d70733          	sub	a4,a4,a3
    3fe0:	01141433          	sll	s0,s0,a7
    3fe4:	00ebd733          	srl	a4,s7,a4
    3fe8:	00876433          	or	s0,a4,s0
    3fec:	011b98b3          	sll	a7,s7,a7
    3ff0:	013787b3          	add	a5,a5,s3
    3ff4:	3f378993          	addi	s3,a5,1011
    3ff8:	00000613          	li	a2,0
    3ffc:	f65ff06f          	j	3f60 <__divdf3+0xc0>
    4000:	40f70733          	sub	a4,a4,a5
    4004:	03800613          	li	a2,56
    4008:	4ee65a63          	bge	a2,a4,44fc <__divdf3+0x65c>
    400c:	00000793          	li	a5,0
    4010:	00000613          	li	a2,0
    4014:	00000713          	li	a4,0
    4018:	02c12083          	lw	ra,44(sp)
    401c:	02812403          	lw	s0,40(sp)
    4020:	01479793          	slli	a5,a5,0x14
    4024:	00c7e7b3          	or	a5,a5,a2
    4028:	01f69693          	slli	a3,a3,0x1f
    402c:	00d7e7b3          	or	a5,a5,a3
    4030:	02412483          	lw	s1,36(sp)
    4034:	02012903          	lw	s2,32(sp)
    4038:	01c12983          	lw	s3,28(sp)
    403c:	01812a03          	lw	s4,24(sp)
    4040:	01412a83          	lw	s5,20(sp)
    4044:	01012b03          	lw	s6,16(sp)
    4048:	00c12b83          	lw	s7,12(sp)
    404c:	00812c03          	lw	s8,8(sp)
    4050:	00070513          	mv	a0,a4
    4054:	00078593          	mv	a1,a5
    4058:	03010113          	addi	sp,sp,48
    405c:	00008067          	ret
    4060:	7ff00793          	li	a5,2047
    4064:	00000613          	li	a2,0
    4068:	00000713          	li	a4,0
    406c:	fadff06f          	j	4018 <__divdf3+0x178>
    4070:	00000693          	li	a3,0
    4074:	7ff00793          	li	a5,2047
    4078:	00080637          	lui	a2,0x80
    407c:	00000713          	li	a4,0
    4080:	f99ff06f          	j	4018 <__divdf3+0x178>
    4084:	00a4eab3          	or	s5,s1,a0
    4088:	100a8c63          	beqz	s5,41a0 <__divdf3+0x300>
    408c:	40048863          	beqz	s1,449c <__divdf3+0x5fc>
    4090:	00048513          	mv	a0,s1
    4094:	285010ef          	jal	5b18 <__clzsi2>
    4098:	00050713          	mv	a4,a0
    409c:	ff550693          	addi	a3,a0,-11
    40a0:	01d00793          	li	a5,29
    40a4:	ff870b13          	addi	s6,a4,-8
    40a8:	40d787b3          	sub	a5,a5,a3
    40ac:	016494b3          	sll	s1,s1,s6
    40b0:	00f457b3          	srl	a5,s0,a5
    40b4:	0097eab3          	or	s5,a5,s1
    40b8:	01641b33          	sll	s6,s0,s6
    40bc:	c0d00993          	li	s3,-1011
    40c0:	40e989b3          	sub	s3,s3,a4
    40c4:	00000493          	li	s1,0
    40c8:	00000c13          	li	s8,0
    40cc:	e51ff06f          	j	3f1c <__divdf3+0x7c>
    40d0:	017468b3          	or	a7,s0,s7
    40d4:	80198993          	addi	s3,s3,-2047
    40d8:	0a089c63          	bnez	a7,4190 <__divdf3+0x2f0>
    40dc:	0024e493          	ori	s1,s1,2
    40e0:	00000413          	li	s0,0
    40e4:	00200613          	li	a2,2
    40e8:	e79ff06f          	j	3f60 <__divdf3+0xc0>
    40ec:	000a0913          	mv	s2,s4
    40f0:	000a8413          	mv	s0,s5
    40f4:	000b0893          	mv	a7,s6
    40f8:	00200793          	li	a5,2
    40fc:	4efc0863          	beq	s8,a5,45ec <__divdf3+0x74c>
    4100:	00300793          	li	a5,3
    4104:	f6fc06e3          	beq	s8,a5,4070 <__divdf3+0x1d0>
    4108:	00100793          	li	a5,1
    410c:	00090693          	mv	a3,s2
    4110:	eefc0ee3          	beq	s8,a5,400c <__divdf3+0x16c>
    4114:	3ff98793          	addi	a5,s3,1023
    4118:	2af05663          	blez	a5,43c4 <__divdf3+0x524>
    411c:	0078f713          	andi	a4,a7,7
    4120:	4a071663          	bnez	a4,45cc <__divdf3+0x72c>
    4124:	00741713          	slli	a4,s0,0x7
    4128:	00075a63          	bgez	a4,413c <__divdf3+0x29c>
    412c:	ff0007b7          	lui	a5,0xff000
    4130:	fff78793          	addi	a5,a5,-1 # feffffff <__freertos_irq_stack_top+0xfeff8fcf>
    4134:	00f47433          	and	s0,s0,a5
    4138:	40098793          	addi	a5,s3,1024
    413c:	7fe00713          	li	a4,2046
    4140:	f2f740e3          	blt	a4,a5,4060 <__divdf3+0x1c0>
    4144:	0038d893          	srli	a7,a7,0x3
    4148:	01d41713          	slli	a4,s0,0x1d
    414c:	00941613          	slli	a2,s0,0x9
    4150:	01176733          	or	a4,a4,a7
    4154:	00c65613          	srli	a2,a2,0xc
    4158:	7ff7f793          	andi	a5,a5,2047
    415c:	ebdff06f          	j	4018 <__divdf3+0x178>
    4160:	00060c13          	mv	s8,a2
    4164:	f95ff06f          	j	40f8 <__divdf3+0x258>
    4168:	00048a93          	mv	s5,s1
    416c:	00050b13          	mv	s6,a0
    4170:	00c00493          	li	s1,12
    4174:	7ff00993          	li	s3,2047
    4178:	00300c13          	li	s8,3
    417c:	da1ff06f          	j	3f1c <__divdf3+0x7c>
    4180:	0014e493          	ori	s1,s1,1
    4184:	00000413          	li	s0,0
    4188:	00100613          	li	a2,1
    418c:	dd5ff06f          	j	3f60 <__divdf3+0xc0>
    4190:	0034e493          	ori	s1,s1,3
    4194:	000b8893          	mv	a7,s7
    4198:	00300613          	li	a2,3
    419c:	dc5ff06f          	j	3f60 <__divdf3+0xc0>
    41a0:	00000b13          	li	s6,0
    41a4:	00400493          	li	s1,4
    41a8:	00000993          	li	s3,0
    41ac:	00100c13          	li	s8,1
    41b0:	d6dff06f          	j	3f1c <__divdf3+0x7c>
    41b4:	2b546463          	bltu	s0,s5,445c <__divdf3+0x5bc>
    41b8:	2a8a8063          	beq	s5,s0,4458 <__divdf3+0x5b8>
    41bc:	000b0313          	mv	t1,s6
    41c0:	fff98993          	addi	s3,s3,-1
    41c4:	000a8793          	mv	a5,s5
    41c8:	00000b13          	li	s6,0
    41cc:	00841713          	slli	a4,s0,0x8
    41d0:	01075513          	srli	a0,a4,0x10
    41d4:	02a7d433          	divu	s0,a5,a0
    41d8:	0188d613          	srli	a2,a7,0x18
    41dc:	00e66633          	or	a2,a2,a4
    41e0:	01061813          	slli	a6,a2,0x10
    41e4:	01085813          	srli	a6,a6,0x10
    41e8:	00889593          	slli	a1,a7,0x8
    41ec:	01035713          	srli	a4,t1,0x10
    41f0:	02a7f7b3          	remu	a5,a5,a0
    41f4:	028808b3          	mul	a7,a6,s0
    41f8:	01079793          	slli	a5,a5,0x10
    41fc:	00f767b3          	or	a5,a4,a5
    4200:	0117fa63          	bgeu	a5,a7,4214 <__divdf3+0x374>
    4204:	00f607b3          	add	a5,a2,a5
    4208:	fff40713          	addi	a4,s0,-1 # 7fffff <__freertos_irq_stack_top+0x7f8fcf>
    420c:	2ec7f063          	bgeu	a5,a2,44ec <__divdf3+0x64c>
    4210:	00070413          	mv	s0,a4
    4214:	411787b3          	sub	a5,a5,a7
    4218:	02a7d8b3          	divu	a7,a5,a0
    421c:	01031713          	slli	a4,t1,0x10
    4220:	01075713          	srli	a4,a4,0x10
    4224:	02a7f7b3          	remu	a5,a5,a0
    4228:	03180fb3          	mul	t6,a6,a7
    422c:	01079793          	slli	a5,a5,0x10
    4230:	00f76733          	or	a4,a4,a5
    4234:	01f77a63          	bgeu	a4,t6,4248 <__divdf3+0x3a8>
    4238:	00e60733          	add	a4,a2,a4
    423c:	fff88793          	addi	a5,a7,-1
    4240:	28c77e63          	bgeu	a4,a2,44dc <__divdf3+0x63c>
    4244:	00078893          	mv	a7,a5
    4248:	01041413          	slli	s0,s0,0x10
    424c:	000102b7          	lui	t0,0x10
    4250:	01146433          	or	s0,s0,a7
    4254:	fff28313          	addi	t1,t0,-1 # ffff <__freertos_irq_stack_top+0x8fcf>
    4258:	006478b3          	and	a7,s0,t1
    425c:	01045e93          	srli	t4,s0,0x10
    4260:	0105de13          	srli	t3,a1,0x10
    4264:	0065f333          	and	t1,a1,t1
    4268:	03130f33          	mul	t5,t1,a7
    426c:	41f70733          	sub	a4,a4,t6
    4270:	031e08b3          	mul	a7,t3,a7
    4274:	010f5793          	srli	a5,t5,0x10
    4278:	026e8fb3          	mul	t6,t4,t1
    427c:	01f888b3          	add	a7,a7,t6
    4280:	011787b3          	add	a5,a5,a7
    4284:	03ce8eb3          	mul	t4,t4,t3
    4288:	01f7f463          	bgeu	a5,t6,4290 <__divdf3+0x3f0>
    428c:	005e8eb3          	add	t4,t4,t0
    4290:	00010fb7          	lui	t6,0x10
    4294:	ffff8f93          	addi	t6,t6,-1 # ffff <__freertos_irq_stack_top+0x8fcf>
    4298:	0107d893          	srli	a7,a5,0x10
    429c:	01f7f7b3          	and	a5,a5,t6
    42a0:	01079793          	slli	a5,a5,0x10
    42a4:	01ff7f33          	and	t5,t5,t6
    42a8:	01d888b3          	add	a7,a7,t4
    42ac:	01e787b3          	add	a5,a5,t5
    42b0:	17176e63          	bltu	a4,a7,442c <__divdf3+0x58c>
    42b4:	17170a63          	beq	a4,a7,4428 <__divdf3+0x588>
    42b8:	40fb07b3          	sub	a5,s6,a5
    42bc:	41170733          	sub	a4,a4,a7
    42c0:	00fb3b33          	sltu	s6,s6,a5
    42c4:	41670733          	sub	a4,a4,s6
    42c8:	2ee60063          	beq	a2,a4,45a8 <__divdf3+0x708>
    42cc:	02a758b3          	divu	a7,a4,a0
    42d0:	0107de93          	srli	t4,a5,0x10
    42d4:	02a77733          	remu	a4,a4,a0
    42d8:	03180f33          	mul	t5,a6,a7
    42dc:	01071713          	slli	a4,a4,0x10
    42e0:	00eee733          	or	a4,t4,a4
    42e4:	01e77e63          	bgeu	a4,t5,4300 <__divdf3+0x460>
    42e8:	00e60733          	add	a4,a2,a4
    42ec:	fff88e93          	addi	t4,a7,-1
    42f0:	2ec76a63          	bltu	a4,a2,45e4 <__divdf3+0x744>
    42f4:	2fe77863          	bgeu	a4,t5,45e4 <__divdf3+0x744>
    42f8:	ffe88893          	addi	a7,a7,-2
    42fc:	00c70733          	add	a4,a4,a2
    4300:	41e70733          	sub	a4,a4,t5
    4304:	02a75eb3          	divu	t4,a4,a0
    4308:	01079793          	slli	a5,a5,0x10
    430c:	0107d793          	srli	a5,a5,0x10
    4310:	02a77733          	remu	a4,a4,a0
    4314:	03d80833          	mul	a6,a6,t4
    4318:	01071713          	slli	a4,a4,0x10
    431c:	00e7e7b3          	or	a5,a5,a4
    4320:	0107fe63          	bgeu	a5,a6,433c <__divdf3+0x49c>
    4324:	00f607b3          	add	a5,a2,a5
    4328:	fffe8713          	addi	a4,t4,-1
    432c:	2ac7e863          	bltu	a5,a2,45dc <__divdf3+0x73c>
    4330:	2b07f663          	bgeu	a5,a6,45dc <__divdf3+0x73c>
    4334:	ffee8e93          	addi	t4,t4,-2
    4338:	00c787b3          	add	a5,a5,a2
    433c:	01089893          	slli	a7,a7,0x10
    4340:	01d8e8b3          	or	a7,a7,t4
    4344:	01089513          	slli	a0,a7,0x10
    4348:	0108df13          	srli	t5,a7,0x10
    434c:	01055513          	srli	a0,a0,0x10
    4350:	02650eb3          	mul	t4,a0,t1
    4354:	410787b3          	sub	a5,a5,a6
    4358:	02ae0533          	mul	a0,t3,a0
    435c:	010ed713          	srli	a4,t4,0x10
    4360:	026f0333          	mul	t1,t5,t1
    4364:	00650533          	add	a0,a0,t1
    4368:	00a70733          	add	a4,a4,a0
    436c:	03ee0e33          	mul	t3,t3,t5
    4370:	00677663          	bgeu	a4,t1,437c <__divdf3+0x4dc>
    4374:	00010537          	lui	a0,0x10
    4378:	00ae0e33          	add	t3,t3,a0
    437c:	00010837          	lui	a6,0x10
    4380:	fff80813          	addi	a6,a6,-1 # ffff <__freertos_irq_stack_top+0x8fcf>
    4384:	01075513          	srli	a0,a4,0x10
    4388:	01077733          	and	a4,a4,a6
    438c:	01071713          	slli	a4,a4,0x10
    4390:	010efeb3          	and	t4,t4,a6
    4394:	01c50533          	add	a0,a0,t3
    4398:	01d70733          	add	a4,a4,t4
    439c:	12a7f263          	bgeu	a5,a0,44c0 <__divdf3+0x620>
    43a0:	00f607b3          	add	a5,a2,a5
    43a4:	fff88313          	addi	t1,a7,-1
    43a8:	00078813          	mv	a6,a5
    43ac:	1cc7e463          	bltu	a5,a2,4574 <__divdf3+0x6d4>
    43b0:	24a7e863          	bltu	a5,a0,4600 <__divdf3+0x760>
    43b4:	26a78663          	beq	a5,a0,4620 <__divdf3+0x780>
    43b8:	00030893          	mv	a7,t1
    43bc:	0018e893          	ori	a7,a7,1
    43c0:	d55ff06f          	j	4114 <__divdf3+0x274>
    43c4:	00100713          	li	a4,1
    43c8:	c2079ce3          	bnez	a5,4000 <__divdf3+0x160>
    43cc:	41e98993          	addi	s3,s3,1054
    43d0:	013897b3          	sll	a5,a7,s3
    43d4:	00f037b3          	snez	a5,a5
    43d8:	013419b3          	sll	s3,s0,s3
    43dc:	0137e7b3          	or	a5,a5,s3
    43e0:	00e8d8b3          	srl	a7,a7,a4
    43e4:	00f8e8b3          	or	a7,a7,a5
    43e8:	0078f793          	andi	a5,a7,7
    43ec:	00e45433          	srl	s0,s0,a4
    43f0:	02078063          	beqz	a5,4410 <__divdf3+0x570>
    43f4:	00f8f793          	andi	a5,a7,15
    43f8:	00400713          	li	a4,4
    43fc:	00e78a63          	beq	a5,a4,4410 <__divdf3+0x570>
    4400:	00488793          	addi	a5,a7,4
    4404:	0117b8b3          	sltu	a7,a5,a7
    4408:	01140433          	add	s0,s0,a7
    440c:	00078893          	mv	a7,a5
    4410:	00841593          	slli	a1,s0,0x8
    4414:	00100793          	li	a5,1
    4418:	00000613          	li	a2,0
    441c:	00000713          	li	a4,0
    4420:	be05cce3          	bltz	a1,4018 <__divdf3+0x178>
    4424:	1340006f          	j	4558 <__divdf3+0x6b8>
    4428:	e8fb78e3          	bgeu	s6,a5,42b8 <__divdf3+0x418>
    442c:	00bb0eb3          	add	t4,s6,a1
    4430:	016ebf33          	sltu	t5,t4,s6
    4434:	00cf0fb3          	add	t6,t5,a2
    4438:	01f70733          	add	a4,a4,t6
    443c:	000e8b13          	mv	s6,t4
    4440:	fff40f93          	addi	t6,s0,-1
    4444:	08e67463          	bgeu	a2,a4,44cc <__divdf3+0x62c>
    4448:	15176263          	bltu	a4,a7,458c <__divdf3+0x6ec>
    444c:	12e88e63          	beq	a7,a4,4588 <__divdf3+0x6e8>
    4450:	000f8413          	mv	s0,t6
    4454:	e65ff06f          	j	42b8 <__divdf3+0x418>
    4458:	d71b62e3          	bltu	s6,a7,41bc <__divdf3+0x31c>
    445c:	001b5713          	srli	a4,s6,0x1
    4460:	01fa9313          	slli	t1,s5,0x1f
    4464:	001ad793          	srli	a5,s5,0x1
    4468:	00e36333          	or	t1,t1,a4
    446c:	01fb1b13          	slli	s6,s6,0x1f
    4470:	d5dff06f          	j	41cc <__divdf3+0x32c>
    4474:	000b8513          	mv	a0,s7
    4478:	6a0010ef          	jal	5b18 <__clzsi2>
    447c:	01550693          	addi	a3,a0,21 # 10015 <__freertos_irq_stack_top+0x8fe5>
    4480:	01c00713          	li	a4,28
    4484:	02050793          	addi	a5,a0,32
    4488:	b4d756e3          	bge	a4,a3,3fd4 <__divdf3+0x134>
    448c:	ff850513          	addi	a0,a0,-8
    4490:	00000893          	li	a7,0
    4494:	00ab9433          	sll	s0,s7,a0
    4498:	b59ff06f          	j	3ff0 <__divdf3+0x150>
    449c:	67c010ef          	jal	5b18 <__clzsi2>
    44a0:	01550693          	addi	a3,a0,21
    44a4:	01c00793          	li	a5,28
    44a8:	02050713          	addi	a4,a0,32
    44ac:	bed7dae3          	bge	a5,a3,40a0 <__divdf3+0x200>
    44b0:	ff850793          	addi	a5,a0,-8
    44b4:	00f41ab3          	sll	s5,s0,a5
    44b8:	00000b13          	li	s6,0
    44bc:	c01ff06f          	j	40bc <__divdf3+0x21c>
    44c0:	eea79ee3          	bne	a5,a0,43bc <__divdf3+0x51c>
    44c4:	c40708e3          	beqz	a4,4114 <__divdf3+0x274>
    44c8:	ed9ff06f          	j	43a0 <__divdf3+0x500>
    44cc:	f8e612e3          	bne	a2,a4,4450 <__divdf3+0x5b0>
    44d0:	f60f0ce3          	beqz	t5,4448 <__divdf3+0x5a8>
    44d4:	000f8413          	mv	s0,t6
    44d8:	de1ff06f          	j	42b8 <__divdf3+0x418>
    44dc:	d7f774e3          	bgeu	a4,t6,4244 <__divdf3+0x3a4>
    44e0:	ffe88893          	addi	a7,a7,-2
    44e4:	00c70733          	add	a4,a4,a2
    44e8:	d61ff06f          	j	4248 <__divdf3+0x3a8>
    44ec:	d317f2e3          	bgeu	a5,a7,4210 <__divdf3+0x370>
    44f0:	ffe40413          	addi	s0,s0,-2
    44f4:	00c787b3          	add	a5,a5,a2
    44f8:	d1dff06f          	j	4214 <__divdf3+0x374>
    44fc:	01f00613          	li	a2,31
    4500:	ece656e3          	bge	a2,a4,43cc <__divdf3+0x52c>
    4504:	fe100613          	li	a2,-31
    4508:	40f607b3          	sub	a5,a2,a5
    450c:	02000613          	li	a2,32
    4510:	00f457b3          	srl	a5,s0,a5
    4514:	00c70863          	beq	a4,a2,4524 <__divdf3+0x684>
    4518:	43e98993          	addi	s3,s3,1086
    451c:	013419b3          	sll	s3,s0,s3
    4520:	0138e8b3          	or	a7,a7,s3
    4524:	011038b3          	snez	a7,a7
    4528:	00f8e8b3          	or	a7,a7,a5
    452c:	0078f713          	andi	a4,a7,7
    4530:	00000613          	li	a2,0
    4534:	02070863          	beqz	a4,4564 <__divdf3+0x6c4>
    4538:	00f8f793          	andi	a5,a7,15
    453c:	00400713          	li	a4,4
    4540:	00000413          	li	s0,0
    4544:	00e78a63          	beq	a5,a4,4558 <__divdf3+0x6b8>
    4548:	00488793          	addi	a5,a7,4
    454c:	0117b8b3          	sltu	a7,a5,a7
    4550:	01103433          	snez	s0,a7
    4554:	00078893          	mv	a7,a5
    4558:	00941613          	slli	a2,s0,0x9
    455c:	01d41713          	slli	a4,s0,0x1d
    4560:	00c65613          	srli	a2,a2,0xc
    4564:	0038d893          	srli	a7,a7,0x3
    4568:	00e8e733          	or	a4,a7,a4
    456c:	00000793          	li	a5,0
    4570:	aa9ff06f          	j	4018 <__divdf3+0x178>
    4574:	00030893          	mv	a7,t1
    4578:	e4a812e3          	bne	a6,a0,43bc <__divdf3+0x51c>
    457c:	b8b70ce3          	beq	a4,a1,4114 <__divdf3+0x274>
    4580:	0018e893          	ori	a7,a7,1
    4584:	b91ff06f          	j	4114 <__divdf3+0x274>
    4588:	ecfef4e3          	bgeu	t4,a5,4450 <__divdf3+0x5b0>
    458c:	01d58eb3          	add	t4,a1,t4
    4590:	00bebf33          	sltu	t5,t4,a1
    4594:	00cf0f33          	add	t5,t5,a2
    4598:	ffe40413          	addi	s0,s0,-2
    459c:	000e8b13          	mv	s6,t4
    45a0:	01e70733          	add	a4,a4,t5
    45a4:	d15ff06f          	j	42b8 <__divdf3+0x418>
    45a8:	c0200713          	li	a4,-1022
    45ac:	3ff98793          	addi	a5,s3,1023
    45b0:	fff00893          	li	a7,-1
    45b4:	e0e9c8e3          	blt	s3,a4,43c4 <__divdf3+0x524>
    45b8:	00488713          	addi	a4,a7,4
    45bc:	011738b3          	sltu	a7,a4,a7
    45c0:	01140433          	add	s0,s0,a7
    45c4:	00070893          	mv	a7,a4
    45c8:	b5dff06f          	j	4124 <__divdf3+0x284>
    45cc:	00f8f713          	andi	a4,a7,15
    45d0:	00400613          	li	a2,4
    45d4:	b4c708e3          	beq	a4,a2,4124 <__divdf3+0x284>
    45d8:	fe1ff06f          	j	45b8 <__divdf3+0x718>
    45dc:	00070e93          	mv	t4,a4
    45e0:	d5dff06f          	j	433c <__divdf3+0x49c>
    45e4:	000e8893          	mv	a7,t4
    45e8:	d19ff06f          	j	4300 <__divdf3+0x460>
    45ec:	00090693          	mv	a3,s2
    45f0:	7ff00793          	li	a5,2047
    45f4:	00000613          	li	a2,0
    45f8:	00000713          	li	a4,0
    45fc:	a1dff06f          	j	4018 <__divdf3+0x178>
    4600:	00159313          	slli	t1,a1,0x1
    4604:	00b33833          	sltu	a6,t1,a1
    4608:	00c80833          	add	a6,a6,a2
    460c:	01078833          	add	a6,a5,a6
    4610:	ffe88893          	addi	a7,a7,-2
    4614:	00030593          	mv	a1,t1
    4618:	f6a802e3          	beq	a6,a0,457c <__divdf3+0x6dc>
    461c:	da1ff06f          	j	43bc <__divdf3+0x51c>
    4620:	fee5e0e3          	bltu	a1,a4,4600 <__divdf3+0x760>
    4624:	00030893          	mv	a7,t1
    4628:	f4b71ce3          	bne	a4,a1,4580 <__divdf3+0x6e0>
    462c:	ae9ff06f          	j	4114 <__divdf3+0x274>

00004630 <__eqdf2>:
    4630:	0145d713          	srli	a4,a1,0x14
    4634:	001007b7          	lui	a5,0x100
    4638:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf8fcf>
    463c:	0146d813          	srli	a6,a3,0x14
    4640:	7ff77713          	andi	a4,a4,2047
    4644:	7ff00313          	li	t1,2047
    4648:	00b7fe33          	and	t3,a5,a1
    464c:	00050893          	mv	a7,a0
    4650:	00d7f7b3          	and	a5,a5,a3
    4654:	01f5d593          	srli	a1,a1,0x1f
    4658:	7ff87813          	andi	a6,a6,2047
    465c:	01f6d693          	srli	a3,a3,0x1f
    4660:	00100513          	li	a0,1
    4664:	00670c63          	beq	a4,t1,467c <__eqdf2+0x4c>
    4668:	00680863          	beq	a6,t1,4678 <__eqdf2+0x48>
    466c:	01071463          	bne	a4,a6,4674 <__eqdf2+0x44>
    4670:	02fe0663          	beq	t3,a5,469c <__eqdf2+0x6c>
    4674:	00008067          	ret
    4678:	00008067          	ret
    467c:	fee81ce3          	bne	a6,a4,4674 <__eqdf2+0x44>
    4680:	00fe67b3          	or	a5,t3,a5
    4684:	00c7e7b3          	or	a5,a5,a2
    4688:	0117e7b3          	or	a5,a5,a7
    468c:	fe0794e3          	bnez	a5,4674 <__eqdf2+0x44>
    4690:	40d585b3          	sub	a1,a1,a3
    4694:	00b03533          	snez	a0,a1
    4698:	00008067          	ret
    469c:	fcc89ce3          	bne	a7,a2,4674 <__eqdf2+0x44>
    46a0:	00d58a63          	beq	a1,a3,46b4 <__eqdf2+0x84>
    46a4:	fc0718e3          	bnez	a4,4674 <__eqdf2+0x44>
    46a8:	011e6e33          	or	t3,t3,a7
    46ac:	01c03533          	snez	a0,t3
    46b0:	00008067          	ret
    46b4:	00000513          	li	a0,0
    46b8:	00008067          	ret

000046bc <__gedf2>:
    46bc:	0145d893          	srli	a7,a1,0x14
    46c0:	001007b7          	lui	a5,0x100
    46c4:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf8fcf>
    46c8:	0146d713          	srli	a4,a3,0x14
    46cc:	7ff8f893          	andi	a7,a7,2047
    46d0:	7ff00e13          	li	t3,2047
    46d4:	00b7f333          	and	t1,a5,a1
    46d8:	00050813          	mv	a6,a0
    46dc:	00050e93          	mv	t4,a0
    46e0:	00d7f7b3          	and	a5,a5,a3
    46e4:	01f5d593          	srli	a1,a1,0x1f
    46e8:	00060f13          	mv	t5,a2
    46ec:	7ff77513          	andi	a0,a4,2047
    46f0:	01f6d693          	srli	a3,a3,0x1f
    46f4:	05c88863          	beq	a7,t3,4744 <__gedf2+0x88>
    46f8:	03c50463          	beq	a0,t3,4720 <__gedf2+0x64>
    46fc:	06089a63          	bnez	a7,4770 <__gedf2+0xb4>
    4700:	01036833          	or	a6,t1,a6
    4704:	06051063          	bnez	a0,4764 <__gedf2+0xa8>
    4708:	00c7e633          	or	a2,a5,a2
    470c:	08060c63          	beqz	a2,47a4 <__gedf2+0xe8>
    4710:	0a081263          	bnez	a6,47b4 <__gedf2+0xf8>
    4714:	00100513          	li	a0,1
    4718:	08068263          	beqz	a3,479c <__gedf2+0xe0>
    471c:	00008067          	ret
    4720:	00c7e633          	or	a2,a5,a2
    4724:	08061463          	bnez	a2,47ac <__gedf2+0xf0>
    4728:	00089663          	bnez	a7,4734 <__gedf2+0x78>
    472c:	01036333          	or	t1,t1,a6
    4730:	fe0302e3          	beqz	t1,4714 <__gedf2+0x58>
    4734:	06d58063          	beq	a1,a3,4794 <__gedf2+0xd8>
    4738:	06059263          	bnez	a1,479c <__gedf2+0xe0>
    473c:	00100513          	li	a0,1
    4740:	00008067          	ret
    4744:	01036333          	or	t1,t1,a6
    4748:	06031263          	bnez	t1,47ac <__gedf2+0xf0>
    474c:	ff1516e3          	bne	a0,a7,4738 <__gedf2+0x7c>
    4750:	00c7e7b3          	or	a5,a5,a2
    4754:	04079c63          	bnez	a5,47ac <__gedf2+0xf0>
    4758:	fed590e3          	bne	a1,a3,4738 <__gedf2+0x7c>
    475c:	00000513          	li	a0,0
    4760:	00008067          	ret
    4764:	fa0808e3          	beqz	a6,4714 <__gedf2+0x58>
    4768:	fcd598e3          	bne	a1,a3,4738 <__gedf2+0x7c>
    476c:	0280006f          	j	4794 <__gedf2+0xd8>
    4770:	fc0504e3          	beqz	a0,4738 <__gedf2+0x7c>
    4774:	fcd592e3          	bne	a1,a3,4738 <__gedf2+0x7c>
    4778:	fd1540e3          	blt	a0,a7,4738 <__gedf2+0x7c>
    477c:	00a8cc63          	blt	a7,a0,4794 <__gedf2+0xd8>
    4780:	fa67ece3          	bltu	a5,t1,4738 <__gedf2+0x7c>
    4784:	00f31863          	bne	t1,a5,4794 <__gedf2+0xd8>
    4788:	fbdf68e3          	bltu	t5,t4,4738 <__gedf2+0x7c>
    478c:	00000513          	li	a0,0
    4790:	f9eef6e3          	bgeu	t4,t5,471c <__gedf2+0x60>
    4794:	00100513          	li	a0,1
    4798:	f80592e3          	bnez	a1,471c <__gedf2+0x60>
    479c:	fff00513          	li	a0,-1
    47a0:	00008067          	ret
    47a4:	f8081ae3          	bnez	a6,4738 <__gedf2+0x7c>
    47a8:	00008067          	ret
    47ac:	ffe00513          	li	a0,-2
    47b0:	00008067          	ret
    47b4:	fcd586e3          	beq	a1,a3,4780 <__gedf2+0xc4>
    47b8:	f81ff06f          	j	4738 <__gedf2+0x7c>

000047bc <__ledf2>:
    47bc:	0145d893          	srli	a7,a1,0x14
    47c0:	001007b7          	lui	a5,0x100
    47c4:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf8fcf>
    47c8:	0146d713          	srli	a4,a3,0x14
    47cc:	7ff8f893          	andi	a7,a7,2047
    47d0:	7ff00313          	li	t1,2047
    47d4:	00b7fe33          	and	t3,a5,a1
    47d8:	00050813          	mv	a6,a0
    47dc:	00050e93          	mv	t4,a0
    47e0:	00d7f7b3          	and	a5,a5,a3
    47e4:	01f5d593          	srli	a1,a1,0x1f
    47e8:	00060f13          	mv	t5,a2
    47ec:	7ff77513          	andi	a0,a4,2047
    47f0:	01f6d693          	srli	a3,a3,0x1f
    47f4:	04688a63          	beq	a7,t1,4848 <__ledf2+0x8c>
    47f8:	02650463          	beq	a0,t1,4820 <__ledf2+0x64>
    47fc:	06089863          	bnez	a7,486c <__ledf2+0xb0>
    4800:	010e6833          	or	a6,t3,a6
    4804:	08051e63          	bnez	a0,48a0 <__ledf2+0xe4>
    4808:	00c7e633          	or	a2,a5,a2
    480c:	0a060463          	beqz	a2,48b4 <__ledf2+0xf8>
    4810:	0a081663          	bnez	a6,48bc <__ledf2+0x100>
    4814:	00100513          	li	a0,1
    4818:	08068063          	beqz	a3,4898 <__ledf2+0xdc>
    481c:	00008067          	ret
    4820:	00c7e633          	or	a2,a5,a2
    4824:	00200513          	li	a0,2
    4828:	fe061ae3          	bnez	a2,481c <__ledf2+0x60>
    482c:	00089663          	bnez	a7,4838 <__ledf2+0x7c>
    4830:	010e6e33          	or	t3,t3,a6
    4834:	fe0e00e3          	beqz	t3,4814 <__ledf2+0x58>
    4838:	04d58c63          	beq	a1,a3,4890 <__ledf2+0xd4>
    483c:	04059e63          	bnez	a1,4898 <__ledf2+0xdc>
    4840:	00100513          	li	a0,1
    4844:	00008067          	ret
    4848:	010e6e33          	or	t3,t3,a6
    484c:	060e1063          	bnez	t3,48ac <__ledf2+0xf0>
    4850:	ff1516e3          	bne	a0,a7,483c <__ledf2+0x80>
    4854:	00c7e7b3          	or	a5,a5,a2
    4858:	00200513          	li	a0,2
    485c:	fc0790e3          	bnez	a5,481c <__ledf2+0x60>
    4860:	fcd59ee3          	bne	a1,a3,483c <__ledf2+0x80>
    4864:	00000513          	li	a0,0
    4868:	00008067          	ret
    486c:	fc0508e3          	beqz	a0,483c <__ledf2+0x80>
    4870:	fcd596e3          	bne	a1,a3,483c <__ledf2+0x80>
    4874:	fd1544e3          	blt	a0,a7,483c <__ledf2+0x80>
    4878:	00a8cc63          	blt	a7,a0,4890 <__ledf2+0xd4>
    487c:	fdc7e0e3          	bltu	a5,t3,483c <__ledf2+0x80>
    4880:	00fe1863          	bne	t3,a5,4890 <__ledf2+0xd4>
    4884:	fbdf6ce3          	bltu	t5,t4,483c <__ledf2+0x80>
    4888:	00000513          	li	a0,0
    488c:	f9eef8e3          	bgeu	t4,t5,481c <__ledf2+0x60>
    4890:	00100513          	li	a0,1
    4894:	f80594e3          	bnez	a1,481c <__ledf2+0x60>
    4898:	fff00513          	li	a0,-1
    489c:	00008067          	ret
    48a0:	f6080ae3          	beqz	a6,4814 <__ledf2+0x58>
    48a4:	f8d59ce3          	bne	a1,a3,483c <__ledf2+0x80>
    48a8:	fe9ff06f          	j	4890 <__ledf2+0xd4>
    48ac:	00200513          	li	a0,2
    48b0:	00008067          	ret
    48b4:	f80814e3          	bnez	a6,483c <__ledf2+0x80>
    48b8:	00008067          	ret
    48bc:	fcd580e3          	beq	a1,a3,487c <__ledf2+0xc0>
    48c0:	f7dff06f          	j	483c <__ledf2+0x80>

000048c4 <__muldf3>:
    48c4:	fd010113          	addi	sp,sp,-48
    48c8:	0145d793          	srli	a5,a1,0x14
    48cc:	02812423          	sw	s0,40(sp)
    48d0:	02912223          	sw	s1,36(sp)
    48d4:	03212023          	sw	s2,32(sp)
    48d8:	01312e23          	sw	s3,28(sp)
    48dc:	01512a23          	sw	s5,20(sp)
    48e0:	00c59493          	slli	s1,a1,0xc
    48e4:	02112623          	sw	ra,44(sp)
    48e8:	01412c23          	sw	s4,24(sp)
    48ec:	01612823          	sw	s6,16(sp)
    48f0:	01712623          	sw	s7,12(sp)
    48f4:	01812423          	sw	s8,8(sp)
    48f8:	7ff7f793          	andi	a5,a5,2047
    48fc:	00050413          	mv	s0,a0
    4900:	00060a93          	mv	s5,a2
    4904:	00068993          	mv	s3,a3
    4908:	00c4d493          	srli	s1,s1,0xc
    490c:	01f5d913          	srli	s2,a1,0x1f
    4910:	42078463          	beqz	a5,4d38 <__muldf3+0x474>
    4914:	7ff00713          	li	a4,2047
    4918:	0ae78663          	beq	a5,a4,49c4 <__muldf3+0x100>
    491c:	00349693          	slli	a3,s1,0x3
    4920:	01d55713          	srli	a4,a0,0x1d
    4924:	00d76733          	or	a4,a4,a3
    4928:	008006b7          	lui	a3,0x800
    492c:	00d764b3          	or	s1,a4,a3
    4930:	00351a13          	slli	s4,a0,0x3
    4934:	c0178c13          	addi	s8,a5,-1023
    4938:	00000b13          	li	s6,0
    493c:	00000b93          	li	s7,0
    4940:	0149d793          	srli	a5,s3,0x14
    4944:	00c99713          	slli	a4,s3,0xc
    4948:	7ff7f793          	andi	a5,a5,2047
    494c:	000a8f13          	mv	t5,s5
    4950:	00c75413          	srli	s0,a4,0xc
    4954:	01f9d993          	srli	s3,s3,0x1f
    4958:	0a078063          	beqz	a5,49f8 <__muldf3+0x134>
    495c:	7ff00713          	li	a4,2047
    4960:	14e78e63          	beq	a5,a4,4abc <__muldf3+0x1f8>
    4964:	00341713          	slli	a4,s0,0x3
    4968:	01dad593          	srli	a1,s5,0x1d
    496c:	00e5e5b3          	or	a1,a1,a4
    4970:	c0178793          	addi	a5,a5,-1023
    4974:	00800737          	lui	a4,0x800
    4978:	00e5e433          	or	s0,a1,a4
    497c:	003a9f13          	slli	t5,s5,0x3
    4980:	018788b3          	add	a7,a5,s8
    4984:	00000313          	li	t1,0
    4988:	00a00713          	li	a4,10
    498c:	00188513          	addi	a0,a7,1
    4990:	0b674c63          	blt	a4,s6,4a48 <__muldf3+0x184>
    4994:	013945b3          	xor	a1,s2,s3
    4998:	00200793          	li	a5,2
    499c:	00058813          	mv	a6,a1
    49a0:	1567c663          	blt	a5,s6,4aec <__muldf3+0x228>
    49a4:	fffb0b13          	addi	s6,s6,-1
    49a8:	00100713          	li	a4,1
    49ac:	17676063          	bltu	a4,s6,4b0c <__muldf3+0x248>
    49b0:	3cf30a63          	beq	t1,a5,4d84 <__muldf3+0x4c0>
    49b4:	00040493          	mv	s1,s0
    49b8:	000f0a13          	mv	s4,t5
    49bc:	00030b93          	mv	s7,t1
    49c0:	09c0006f          	j	4a5c <__muldf3+0x198>
    49c4:	00a4ea33          	or	s4,s1,a0
    49c8:	3c0a1863          	bnez	s4,4d98 <__muldf3+0x4d4>
    49cc:	0149d793          	srli	a5,s3,0x14
    49d0:	00c99713          	slli	a4,s3,0xc
    49d4:	7ff7f793          	andi	a5,a5,2047
    49d8:	00000493          	li	s1,0
    49dc:	00800b13          	li	s6,8
    49e0:	7ff00c13          	li	s8,2047
    49e4:	00200b93          	li	s7,2
    49e8:	000a8f13          	mv	t5,s5
    49ec:	00c75413          	srli	s0,a4,0xc
    49f0:	01f9d993          	srli	s3,s3,0x1f
    49f4:	f60794e3          	bnez	a5,495c <__muldf3+0x98>
    49f8:	015467b3          	or	a5,s0,s5
    49fc:	3c078263          	beqz	a5,4dc0 <__muldf3+0x4fc>
    4a00:	4a040063          	beqz	s0,4ea0 <__muldf3+0x5dc>
    4a04:	00040513          	mv	a0,s0
    4a08:	110010ef          	jal	5b18 <__clzsi2>
    4a0c:	00050893          	mv	a7,a0
    4a10:	ff550713          	addi	a4,a0,-11
    4a14:	01d00793          	li	a5,29
    4a18:	ff888f13          	addi	t5,a7,-8
    4a1c:	40e787b3          	sub	a5,a5,a4
    4a20:	00fad7b3          	srl	a5,s5,a5
    4a24:	01e41733          	sll	a4,s0,t5
    4a28:	00e7e433          	or	s0,a5,a4
    4a2c:	01ea9f33          	sll	t5,s5,t5
    4a30:	411c08b3          	sub	a7,s8,a7
    4a34:	c0d88893          	addi	a7,a7,-1011
    4a38:	00a00713          	li	a4,10
    4a3c:	00000313          	li	t1,0
    4a40:	00188513          	addi	a0,a7,1
    4a44:	f56758e3          	bge	a4,s6,4994 <__muldf3+0xd0>
    4a48:	00090593          	mv	a1,s2
    4a4c:	00200793          	li	a5,2
    4a50:	32fb8a63          	beq	s7,a5,4d84 <__muldf3+0x4c0>
    4a54:	00300793          	li	a5,3
    4a58:	48fb8c63          	beq	s7,a5,4ef0 <__muldf3+0x62c>
    4a5c:	00100793          	li	a5,1
    4a60:	00058813          	mv	a6,a1
    4a64:	46fb9a63          	bne	s7,a5,4ed8 <__muldf3+0x614>
    4a68:	00000793          	li	a5,0
    4a6c:	00000693          	li	a3,0
    4a70:	00000713          	li	a4,0
    4a74:	02c12083          	lw	ra,44(sp)
    4a78:	02812403          	lw	s0,40(sp)
    4a7c:	01479793          	slli	a5,a5,0x14
    4a80:	00d7e7b3          	or	a5,a5,a3
    4a84:	01f81693          	slli	a3,a6,0x1f
    4a88:	00d7e7b3          	or	a5,a5,a3
    4a8c:	02412483          	lw	s1,36(sp)
    4a90:	02012903          	lw	s2,32(sp)
    4a94:	01c12983          	lw	s3,28(sp)
    4a98:	01812a03          	lw	s4,24(sp)
    4a9c:	01412a83          	lw	s5,20(sp)
    4aa0:	01012b03          	lw	s6,16(sp)
    4aa4:	00c12b83          	lw	s7,12(sp)
    4aa8:	00812c03          	lw	s8,8(sp)
    4aac:	00070513          	mv	a0,a4
    4ab0:	00078593          	mv	a1,a5
    4ab4:	03010113          	addi	sp,sp,48
    4ab8:	00008067          	ret
    4abc:	01546733          	or	a4,s0,s5
    4ac0:	7ffc0893          	addi	a7,s8,2047
    4ac4:	30070a63          	beqz	a4,4dd8 <__muldf3+0x514>
    4ac8:	00001737          	lui	a4,0x1
    4acc:	01394833          	xor	a6,s2,s3
    4ad0:	80070713          	addi	a4,a4,-2048 # 800 <CUSTOM2+0x7a5>
    4ad4:	003b6b13          	ori	s6,s6,3
    4ad8:	00a00693          	li	a3,10
    4adc:	00080593          	mv	a1,a6
    4ae0:	00ec0533          	add	a0,s8,a4
    4ae4:	3966c063          	blt	a3,s6,4e64 <__muldf3+0x5a0>
    4ae8:	00300313          	li	t1,3
    4aec:	00100613          	li	a2,1
    4af0:	01661633          	sll	a2,a2,s6
    4af4:	53067713          	andi	a4,a2,1328
    4af8:	f4071ae3          	bnez	a4,4a4c <__muldf3+0x188>
    4afc:	24067793          	andi	a5,a2,576
    4b00:	3c079463          	bnez	a5,4ec8 <__muldf3+0x604>
    4b04:	08867613          	andi	a2,a2,136
    4b08:	2e061263          	bnez	a2,4dec <__muldf3+0x528>
    4b0c:	00010fb7          	lui	t6,0x10
    4b10:	ffff8e93          	addi	t4,t6,-1 # ffff <__freertos_irq_stack_top+0x8fcf>
    4b14:	01da77b3          	and	a5,s4,t4
    4b18:	010a5693          	srli	a3,s4,0x10
    4b1c:	01df7eb3          	and	t4,t5,t4
    4b20:	010f5e13          	srli	t3,t5,0x10
    4b24:	03d78733          	mul	a4,a5,t4
    4b28:	03d68333          	mul	t1,a3,t4
    4b2c:	01075593          	srli	a1,a4,0x10
    4b30:	02fe0633          	mul	a2,t3,a5
    4b34:	00660633          	add	a2,a2,t1
    4b38:	00c585b3          	add	a1,a1,a2
    4b3c:	03c68f33          	mul	t5,a3,t3
    4b40:	0065f463          	bgeu	a1,t1,4b48 <__muldf3+0x284>
    4b44:	01ff0f33          	add	t5,t5,t6
    4b48:	000103b7          	lui	t2,0x10
    4b4c:	fff38613          	addi	a2,t2,-1 # ffff <__freertos_irq_stack_top+0x8fcf>
    4b50:	00c5f333          	and	t1,a1,a2
    4b54:	01045f93          	srli	t6,s0,0x10
    4b58:	00c77733          	and	a4,a4,a2
    4b5c:	00c47433          	and	s0,s0,a2
    4b60:	01031313          	slli	t1,t1,0x10
    4b64:	028782b3          	mul	t0,a5,s0
    4b68:	00e30333          	add	t1,t1,a4
    4b6c:	0105d593          	srli	a1,a1,0x10
    4b70:	02868733          	mul	a4,a3,s0
    4b74:	0102d613          	srli	a2,t0,0x10
    4b78:	02ff87b3          	mul	a5,t6,a5
    4b7c:	00e787b3          	add	a5,a5,a4
    4b80:	00f60633          	add	a2,a2,a5
    4b84:	03f687b3          	mul	a5,a3,t6
    4b88:	00e67463          	bgeu	a2,a4,4b90 <__muldf3+0x2cc>
    4b8c:	007787b3          	add	a5,a5,t2
    4b90:	00010937          	lui	s2,0x10
    4b94:	fff90993          	addi	s3,s2,-1 # ffff <__freertos_irq_stack_top+0x8fcf>
    4b98:	01367733          	and	a4,a2,s3
    4b9c:	0104d393          	srli	t2,s1,0x10
    4ba0:	0134f6b3          	and	a3,s1,s3
    4ba4:	0132f2b3          	and	t0,t0,s3
    4ba8:	01071713          	slli	a4,a4,0x10
    4bac:	02de84b3          	mul	s1,t4,a3
    4bb0:	00570733          	add	a4,a4,t0
    4bb4:	01065613          	srli	a2,a2,0x10
    4bb8:	00f60633          	add	a2,a2,a5
    4bbc:	00e585b3          	add	a1,a1,a4
    4bc0:	02de02b3          	mul	t0,t3,a3
    4bc4:	0104d793          	srli	a5,s1,0x10
    4bc8:	03d38eb3          	mul	t4,t2,t4
    4bcc:	01d282b3          	add	t0,t0,t4
    4bd0:	005787b3          	add	a5,a5,t0
    4bd4:	027e0e33          	mul	t3,t3,t2
    4bd8:	01d7f463          	bgeu	a5,t4,4be0 <__muldf3+0x31c>
    4bdc:	012e0e33          	add	t3,t3,s2
    4be0:	000109b7          	lui	s3,0x10
    4be4:	fff98e93          	addi	t4,s3,-1 # ffff <__freertos_irq_stack_top+0x8fcf>
    4be8:	01d7f2b3          	and	t0,a5,t4
    4bec:	0107d793          	srli	a5,a5,0x10
    4bf0:	01c787b3          	add	a5,a5,t3
    4bf4:	01d4feb3          	and	t4,s1,t4
    4bf8:	01029293          	slli	t0,t0,0x10
    4bfc:	02d40933          	mul	s2,s0,a3
    4c00:	01d282b3          	add	t0,t0,t4
    4c04:	02838433          	mul	s0,t2,s0
    4c08:	01095e13          	srli	t3,s2,0x10
    4c0c:	02df86b3          	mul	a3,t6,a3
    4c10:	008686b3          	add	a3,a3,s0
    4c14:	00de0e33          	add	t3,t3,a3
    4c18:	027f8eb3          	mul	t4,t6,t2
    4c1c:	008e7463          	bgeu	t3,s0,4c24 <__muldf3+0x360>
    4c20:	013e8eb3          	add	t4,t4,s3
    4c24:	00010fb7          	lui	t6,0x10
    4c28:	ffff8f93          	addi	t6,t6,-1 # ffff <__freertos_irq_stack_top+0x8fcf>
    4c2c:	01fe76b3          	and	a3,t3,t6
    4c30:	01069693          	slli	a3,a3,0x10
    4c34:	01f97933          	and	s2,s2,t6
    4c38:	01e585b3          	add	a1,a1,t5
    4c3c:	012686b3          	add	a3,a3,s2
    4c40:	00c68633          	add	a2,a3,a2
    4c44:	00e5b733          	sltu	a4,a1,a4
    4c48:	00e60733          	add	a4,a2,a4
    4c4c:	00558f33          	add	t5,a1,t0
    4c50:	00f707b3          	add	a5,a4,a5
    4c54:	00bf35b3          	sltu	a1,t5,a1
    4c58:	00b785b3          	add	a1,a5,a1
    4c5c:	00d636b3          	sltu	a3,a2,a3
    4c60:	00c73633          	sltu	a2,a4,a2
    4c64:	00c6e6b3          	or	a3,a3,a2
    4c68:	00e7b733          	sltu	a4,a5,a4
    4c6c:	010e5e13          	srli	t3,t3,0x10
    4c70:	00f5b7b3          	sltu	a5,a1,a5
    4c74:	01c686b3          	add	a3,a3,t3
    4c78:	00f76733          	or	a4,a4,a5
    4c7c:	009f1793          	slli	a5,t5,0x9
    4c80:	00d70733          	add	a4,a4,a3
    4c84:	0067e7b3          	or	a5,a5,t1
    4c88:	01d70733          	add	a4,a4,t4
    4c8c:	00f037b3          	snez	a5,a5
    4c90:	017f5613          	srli	a2,t5,0x17
    4c94:	00971713          	slli	a4,a4,0x9
    4c98:	0175d693          	srli	a3,a1,0x17
    4c9c:	00c7e7b3          	or	a5,a5,a2
    4ca0:	00959593          	slli	a1,a1,0x9
    4ca4:	00b7ea33          	or	s4,a5,a1
    4ca8:	00771793          	slli	a5,a4,0x7
    4cac:	00d764b3          	or	s1,a4,a3
    4cb0:	0207d063          	bgez	a5,4cd0 <__muldf3+0x40c>
    4cb4:	001a5713          	srli	a4,s4,0x1
    4cb8:	001a7793          	andi	a5,s4,1
    4cbc:	01f49693          	slli	a3,s1,0x1f
    4cc0:	00f767b3          	or	a5,a4,a5
    4cc4:	00d7ea33          	or	s4,a5,a3
    4cc8:	0014d493          	srli	s1,s1,0x1
    4ccc:	00050893          	mv	a7,a0
    4cd0:	3ff88613          	addi	a2,a7,1023
    4cd4:	12c05663          	blez	a2,4e00 <__muldf3+0x53c>
    4cd8:	007a7793          	andi	a5,s4,7
    4cdc:	02078063          	beqz	a5,4cfc <__muldf3+0x438>
    4ce0:	00fa7793          	andi	a5,s4,15
    4ce4:	00400713          	li	a4,4
    4ce8:	00e78a63          	beq	a5,a4,4cfc <__muldf3+0x438>
    4cec:	004a0713          	addi	a4,s4,4
    4cf0:	014737b3          	sltu	a5,a4,s4
    4cf4:	00f484b3          	add	s1,s1,a5
    4cf8:	00070a13          	mv	s4,a4
    4cfc:	00749793          	slli	a5,s1,0x7
    4d00:	0007da63          	bgez	a5,4d14 <__muldf3+0x450>
    4d04:	ff0007b7          	lui	a5,0xff000
    4d08:	fff78793          	addi	a5,a5,-1 # feffffff <__freertos_irq_stack_top+0xfeff8fcf>
    4d0c:	00f4f4b3          	and	s1,s1,a5
    4d10:	40088613          	addi	a2,a7,1024
    4d14:	7fe00793          	li	a5,2046
    4d18:	1cc7c463          	blt	a5,a2,4ee0 <__muldf3+0x61c>
    4d1c:	003a5793          	srli	a5,s4,0x3
    4d20:	01d49713          	slli	a4,s1,0x1d
    4d24:	00949693          	slli	a3,s1,0x9
    4d28:	00f76733          	or	a4,a4,a5
    4d2c:	00c6d693          	srli	a3,a3,0xc
    4d30:	7ff67793          	andi	a5,a2,2047
    4d34:	d41ff06f          	j	4a74 <__muldf3+0x1b0>
    4d38:	00a4ea33          	or	s4,s1,a0
    4d3c:	060a0863          	beqz	s4,4dac <__muldf3+0x4e8>
    4d40:	12048e63          	beqz	s1,4e7c <__muldf3+0x5b8>
    4d44:	00048513          	mv	a0,s1
    4d48:	5d1000ef          	jal	5b18 <__clzsi2>
    4d4c:	00050613          	mv	a2,a0
    4d50:	ff550693          	addi	a3,a0,-11
    4d54:	01d00713          	li	a4,29
    4d58:	ff860793          	addi	a5,a2,-8 # 7fff8 <__freertos_irq_stack_top+0x78fc8>
    4d5c:	40d70733          	sub	a4,a4,a3
    4d60:	00e45733          	srl	a4,s0,a4
    4d64:	00f496b3          	sll	a3,s1,a5
    4d68:	00d764b3          	or	s1,a4,a3
    4d6c:	00f41a33          	sll	s4,s0,a5
    4d70:	c0d00793          	li	a5,-1011
    4d74:	40c78c33          	sub	s8,a5,a2
    4d78:	00000b13          	li	s6,0
    4d7c:	00000b93          	li	s7,0
    4d80:	bc1ff06f          	j	4940 <__muldf3+0x7c>
    4d84:	00058813          	mv	a6,a1
    4d88:	7ff00793          	li	a5,2047
    4d8c:	00000693          	li	a3,0
    4d90:	00000713          	li	a4,0
    4d94:	ce1ff06f          	j	4a74 <__muldf3+0x1b0>
    4d98:	00050a13          	mv	s4,a0
    4d9c:	00c00b13          	li	s6,12
    4da0:	7ff00c13          	li	s8,2047
    4da4:	00300b93          	li	s7,3
    4da8:	b99ff06f          	j	4940 <__muldf3+0x7c>
    4dac:	00000493          	li	s1,0
    4db0:	00400b13          	li	s6,4
    4db4:	00000c13          	li	s8,0
    4db8:	00100b93          	li	s7,1
    4dbc:	b85ff06f          	j	4940 <__muldf3+0x7c>
    4dc0:	001b6b13          	ori	s6,s6,1
    4dc4:	000c0893          	mv	a7,s8
    4dc8:	00000413          	li	s0,0
    4dcc:	00000f13          	li	t5,0
    4dd0:	00100313          	li	t1,1
    4dd4:	bb5ff06f          	j	4988 <__muldf3+0xc4>
    4dd8:	002b6b13          	ori	s6,s6,2
    4ddc:	00000413          	li	s0,0
    4de0:	00000f13          	li	t5,0
    4de4:	00200313          	li	t1,2
    4de8:	ba1ff06f          	j	4988 <__muldf3+0xc4>
    4dec:	00040493          	mv	s1,s0
    4df0:	000f0a13          	mv	s4,t5
    4df4:	00030b93          	mv	s7,t1
    4df8:	00098593          	mv	a1,s3
    4dfc:	c51ff06f          	j	4a4c <__muldf3+0x188>
    4e00:	00100713          	li	a4,1
    4e04:	10061063          	bnez	a2,4f04 <__muldf3+0x640>
    4e08:	41e88893          	addi	a7,a7,1054
    4e0c:	011a1633          	sll	a2,s4,a7
    4e10:	00c03633          	snez	a2,a2
    4e14:	011498b3          	sll	a7,s1,a7
    4e18:	00ea57b3          	srl	a5,s4,a4
    4e1c:	01166633          	or	a2,a2,a7
    4e20:	00f66633          	or	a2,a2,a5
    4e24:	00767793          	andi	a5,a2,7
    4e28:	00e4d5b3          	srl	a1,s1,a4
    4e2c:	02078063          	beqz	a5,4e4c <__muldf3+0x588>
    4e30:	00f67793          	andi	a5,a2,15
    4e34:	00400713          	li	a4,4
    4e38:	00e78a63          	beq	a5,a4,4e4c <__muldf3+0x588>
    4e3c:	00460793          	addi	a5,a2,4
    4e40:	00c7b633          	sltu	a2,a5,a2
    4e44:	00c585b3          	add	a1,a1,a2
    4e48:	00078613          	mv	a2,a5
    4e4c:	00859513          	slli	a0,a1,0x8
    4e50:	00100793          	li	a5,1
    4e54:	00000693          	li	a3,0
    4e58:	00000713          	li	a4,0
    4e5c:	c0054ce3          	bltz	a0,4a74 <__muldf3+0x1b0>
    4e60:	10c0006f          	j	4f6c <__muldf3+0x6a8>
    4e64:	00f00713          	li	a4,15
    4e68:	12eb1063          	bne	s6,a4,4f88 <__muldf3+0x6c4>
    4e6c:	00000813          	li	a6,0
    4e70:	000806b7          	lui	a3,0x80
    4e74:	00000713          	li	a4,0
    4e78:	bfdff06f          	j	4a74 <__muldf3+0x1b0>
    4e7c:	49d000ef          	jal	5b18 <__clzsi2>
    4e80:	01550693          	addi	a3,a0,21
    4e84:	01c00793          	li	a5,28
    4e88:	02050613          	addi	a2,a0,32
    4e8c:	ecd7d4e3          	bge	a5,a3,4d54 <__muldf3+0x490>
    4e90:	ff850513          	addi	a0,a0,-8
    4e94:	00000a13          	li	s4,0
    4e98:	00a414b3          	sll	s1,s0,a0
    4e9c:	ed5ff06f          	j	4d70 <__muldf3+0x4ac>
    4ea0:	000a8513          	mv	a0,s5
    4ea4:	475000ef          	jal	5b18 <__clzsi2>
    4ea8:	01550713          	addi	a4,a0,21
    4eac:	01c00793          	li	a5,28
    4eb0:	02050893          	addi	a7,a0,32
    4eb4:	b6e7d0e3          	bge	a5,a4,4a14 <__muldf3+0x150>
    4eb8:	ff850513          	addi	a0,a0,-8
    4ebc:	00000f13          	li	t5,0
    4ec0:	00aa9433          	sll	s0,s5,a0
    4ec4:	b6dff06f          	j	4a30 <__muldf3+0x16c>
    4ec8:	00000813          	li	a6,0
    4ecc:	7ff00793          	li	a5,2047
    4ed0:	000806b7          	lui	a3,0x80
    4ed4:	ba1ff06f          	j	4a74 <__muldf3+0x1b0>
    4ed8:	00050893          	mv	a7,a0
    4edc:	df5ff06f          	j	4cd0 <__muldf3+0x40c>
    4ee0:	7ff00793          	li	a5,2047
    4ee4:	00000693          	li	a3,0
    4ee8:	00000713          	li	a4,0
    4eec:	b89ff06f          	j	4a74 <__muldf3+0x1b0>
    4ef0:	00000813          	li	a6,0
    4ef4:	7ff00793          	li	a5,2047
    4ef8:	000806b7          	lui	a3,0x80
    4efc:	00000713          	li	a4,0
    4f00:	b75ff06f          	j	4a74 <__muldf3+0x1b0>
    4f04:	40c70733          	sub	a4,a4,a2
    4f08:	03800793          	li	a5,56
    4f0c:	b4e7cee3          	blt	a5,a4,4a68 <__muldf3+0x1a4>
    4f10:	01f00793          	li	a5,31
    4f14:	eee7dae3          	bge	a5,a4,4e08 <__muldf3+0x544>
    4f18:	fe100793          	li	a5,-31
    4f1c:	40c787b3          	sub	a5,a5,a2
    4f20:	02000693          	li	a3,32
    4f24:	00f4d7b3          	srl	a5,s1,a5
    4f28:	00d70863          	beq	a4,a3,4f38 <__muldf3+0x674>
    4f2c:	43e88893          	addi	a7,a7,1086
    4f30:	011498b3          	sll	a7,s1,a7
    4f34:	011a6a33          	or	s4,s4,a7
    4f38:	01403633          	snez	a2,s4
    4f3c:	00f66633          	or	a2,a2,a5
    4f40:	00767713          	andi	a4,a2,7
    4f44:	00000693          	li	a3,0
    4f48:	02070863          	beqz	a4,4f78 <__muldf3+0x6b4>
    4f4c:	00f67793          	andi	a5,a2,15
    4f50:	00400713          	li	a4,4
    4f54:	00000593          	li	a1,0
    4f58:	00e78a63          	beq	a5,a4,4f6c <__muldf3+0x6a8>
    4f5c:	00460793          	addi	a5,a2,4
    4f60:	00c7b633          	sltu	a2,a5,a2
    4f64:	00c035b3          	snez	a1,a2
    4f68:	00078613          	mv	a2,a5
    4f6c:	00959693          	slli	a3,a1,0x9
    4f70:	01d59713          	slli	a4,a1,0x1d
    4f74:	00c6d693          	srli	a3,a3,0xc
    4f78:	00365613          	srli	a2,a2,0x3
    4f7c:	00e66733          	or	a4,a2,a4
    4f80:	00000793          	li	a5,0
    4f84:	af1ff06f          	j	4a74 <__muldf3+0x1b0>
    4f88:	00040493          	mv	s1,s0
    4f8c:	000a8a13          	mv	s4,s5
    4f90:	00300b93          	li	s7,3
    4f94:	00098593          	mv	a1,s3
    4f98:	ab5ff06f          	j	4a4c <__muldf3+0x188>

00004f9c <__subdf3>:
    4f9c:	001007b7          	lui	a5,0x100
    4fa0:	fff78793          	addi	a5,a5,-1 # fffff <__freertos_irq_stack_top+0xf8fcf>
    4fa4:	fe010113          	addi	sp,sp,-32
    4fa8:	00b7f8b3          	and	a7,a5,a1
    4fac:	00d7f833          	and	a6,a5,a3
    4fb0:	0146d793          	srli	a5,a3,0x14
    4fb4:	00389893          	slli	a7,a7,0x3
    4fb8:	00812c23          	sw	s0,24(sp)
    4fbc:	01312623          	sw	s3,12(sp)
    4fc0:	01f5d413          	srli	s0,a1,0x1f
    4fc4:	0145d993          	srli	s3,a1,0x14
    4fc8:	01d55713          	srli	a4,a0,0x1d
    4fcc:	00381813          	slli	a6,a6,0x3
    4fd0:	01d65593          	srli	a1,a2,0x1d
    4fd4:	00112e23          	sw	ra,28(sp)
    4fd8:	00912a23          	sw	s1,20(sp)
    4fdc:	01212823          	sw	s2,16(sp)
    4fe0:	7ff7ff13          	andi	t5,a5,2047
    4fe4:	7ff00313          	li	t1,2047
    4fe8:	01176733          	or	a4,a4,a7
    4fec:	7ff9f993          	andi	s3,s3,2047
    4ff0:	00040e13          	mv	t3,s0
    4ff4:	00351893          	slli	a7,a0,0x3
    4ff8:	01f6d693          	srli	a3,a3,0x1f
    4ffc:	0105e5b3          	or	a1,a1,a6
    5000:	00361e93          	slli	t4,a2,0x3
    5004:	206f0c63          	beq	t5,t1,521c <__subdf3+0x280>
    5008:	0016c693          	xori	a3,a3,1
    500c:	41e987b3          	sub	a5,s3,t5
    5010:	16d40263          	beq	s0,a3,5174 <__subdf3+0x1d8>
    5014:	00f05ae3          	blez	a5,5828 <__subdf3+0x88c>
    5018:	240f0a63          	beqz	t5,526c <__subdf3+0x2d0>
    501c:	3c698463          	beq	s3,t1,53e4 <__subdf3+0x448>
    5020:	03800693          	li	a3,56
    5024:	00100513          	li	a0,1
    5028:	02f6ce63          	blt	a3,a5,5064 <__subdf3+0xc8>
    502c:	008006b7          	lui	a3,0x800
    5030:	00d5e5b3          	or	a1,a1,a3
    5034:	01f00693          	li	a3,31
    5038:	4ef6c463          	blt	a3,a5,5520 <__subdf3+0x584>
    503c:	02000693          	li	a3,32
    5040:	40f686b3          	sub	a3,a3,a5
    5044:	00d59533          	sll	a0,a1,a3
    5048:	00fed633          	srl	a2,t4,a5
    504c:	00de96b3          	sll	a3,t4,a3
    5050:	00c56533          	or	a0,a0,a2
    5054:	00d036b3          	snez	a3,a3
    5058:	00f5d7b3          	srl	a5,a1,a5
    505c:	00d56533          	or	a0,a0,a3
    5060:	40f70733          	sub	a4,a4,a5
    5064:	40a88533          	sub	a0,a7,a0
    5068:	00a8b633          	sltu	a2,a7,a0
    506c:	00050493          	mv	s1,a0
    5070:	40c70933          	sub	s2,a4,a2
    5074:	00891793          	slli	a5,s2,0x8
    5078:	3407d863          	bgez	a5,53c8 <__subdf3+0x42c>
    507c:	008007b7          	lui	a5,0x800
    5080:	fff78793          	addi	a5,a5,-1 # 7fffff <__freertos_irq_stack_top+0x7f8fcf>
    5084:	00f97933          	and	s2,s2,a5
    5088:	2e090663          	beqz	s2,5374 <__subdf3+0x3d8>
    508c:	00090513          	mv	a0,s2
    5090:	289000ef          	jal	5b18 <__clzsi2>
    5094:	ff850793          	addi	a5,a0,-8
    5098:	02000693          	li	a3,32
    509c:	40f68733          	sub	a4,a3,a5
    50a0:	00e4d733          	srl	a4,s1,a4
    50a4:	00f91933          	sll	s2,s2,a5
    50a8:	01276733          	or	a4,a4,s2
    50ac:	00f494b3          	sll	s1,s1,a5
    50b0:	3f37c463          	blt	a5,s3,5498 <__subdf3+0x4fc>
    50b4:	413787b3          	sub	a5,a5,s3
    50b8:	00178793          	addi	a5,a5,1
    50bc:	40f686b3          	sub	a3,a3,a5
    50c0:	00d49633          	sll	a2,s1,a3
    50c4:	00f4d933          	srl	s2,s1,a5
    50c8:	00c03633          	snez	a2,a2
    50cc:	00c96633          	or	a2,s2,a2
    50d0:	00d716b3          	sll	a3,a4,a3
    50d4:	00c6e4b3          	or	s1,a3,a2
    50d8:	00f75933          	srl	s2,a4,a5
    50dc:	00000993          	li	s3,0
    50e0:	0074f793          	andi	a5,s1,7
    50e4:	02078063          	beqz	a5,5104 <__subdf3+0x168>
    50e8:	00f4f793          	andi	a5,s1,15
    50ec:	00400713          	li	a4,4
    50f0:	00e78a63          	beq	a5,a4,5104 <__subdf3+0x168>
    50f4:	00448793          	addi	a5,s1,4
    50f8:	0097b533          	sltu	a0,a5,s1
    50fc:	00a90933          	add	s2,s2,a0
    5100:	00078493          	mv	s1,a5
    5104:	00891793          	slli	a5,s2,0x8
    5108:	6c07d063          	bgez	a5,57c8 <__subdf3+0x82c>
    510c:	00198793          	addi	a5,s3,1
    5110:	7ff00713          	li	a4,2047
    5114:	24e78663          	beq	a5,a4,5360 <__subdf3+0x3c4>
    5118:	ff800737          	lui	a4,0xff800
    511c:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8fcf>
    5120:	00e97733          	and	a4,s2,a4
    5124:	7ff7f793          	andi	a5,a5,2047
    5128:	01d71813          	slli	a6,a4,0x1d
    512c:	0034d513          	srli	a0,s1,0x3
    5130:	00971713          	slli	a4,a4,0x9
    5134:	00a86833          	or	a6,a6,a0
    5138:	00c75713          	srli	a4,a4,0xc
    513c:	00147e13          	andi	t3,s0,1
    5140:	01c12083          	lw	ra,28(sp)
    5144:	01812403          	lw	s0,24(sp)
    5148:	01479793          	slli	a5,a5,0x14
    514c:	00e7e7b3          	or	a5,a5,a4
    5150:	01fe1713          	slli	a4,t3,0x1f
    5154:	00e7e7b3          	or	a5,a5,a4
    5158:	01412483          	lw	s1,20(sp)
    515c:	01012903          	lw	s2,16(sp)
    5160:	00c12983          	lw	s3,12(sp)
    5164:	00080513          	mv	a0,a6
    5168:	00078593          	mv	a1,a5
    516c:	02010113          	addi	sp,sp,32
    5170:	00008067          	ret
    5174:	70f05263          	blez	a5,5878 <__subdf3+0x8dc>
    5178:	1c0f1663          	bnez	t5,5344 <__subdf3+0x3a8>
    517c:	01d5e6b3          	or	a3,a1,t4
    5180:	26068e63          	beqz	a3,53fc <__subdf3+0x460>
    5184:	fff78693          	addi	a3,a5,-1
    5188:	46068863          	beqz	a3,55f8 <__subdf3+0x65c>
    518c:	24678c63          	beq	a5,t1,53e4 <__subdf3+0x448>
    5190:	03800793          	li	a5,56
    5194:	00100913          	li	s2,1
    5198:	02d7cc63          	blt	a5,a3,51d0 <__subdf3+0x234>
    519c:	00068793          	mv	a5,a3
    51a0:	01f00693          	li	a3,31
    51a4:	48f6ca63          	blt	a3,a5,5638 <__subdf3+0x69c>
    51a8:	02000693          	li	a3,32
    51ac:	40f686b3          	sub	a3,a3,a5
    51b0:	00d59933          	sll	s2,a1,a3
    51b4:	00fed633          	srl	a2,t4,a5
    51b8:	00de96b3          	sll	a3,t4,a3
    51bc:	00c96933          	or	s2,s2,a2
    51c0:	00d036b3          	snez	a3,a3
    51c4:	00f5d7b3          	srl	a5,a1,a5
    51c8:	00d96933          	or	s2,s2,a3
    51cc:	00f70733          	add	a4,a4,a5
    51d0:	01190633          	add	a2,s2,a7
    51d4:	01263933          	sltu	s2,a2,s2
    51d8:	00060493          	mv	s1,a2
    51dc:	00e90933          	add	s2,s2,a4
    51e0:	00891793          	slli	a5,s2,0x8
    51e4:	1e07d263          	bgez	a5,53c8 <__subdf3+0x42c>
    51e8:	00198993          	addi	s3,s3,1
    51ec:	7ff00793          	li	a5,2047
    51f0:	16f98863          	beq	s3,a5,5360 <__subdf3+0x3c4>
    51f4:	ff8007b7          	lui	a5,0xff800
    51f8:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8fcf>
    51fc:	0014f513          	andi	a0,s1,1
    5200:	00f977b3          	and	a5,s2,a5
    5204:	0014d713          	srli	a4,s1,0x1
    5208:	00a76733          	or	a4,a4,a0
    520c:	01f79513          	slli	a0,a5,0x1f
    5210:	00e564b3          	or	s1,a0,a4
    5214:	0017d913          	srli	s2,a5,0x1
    5218:	ec9ff06f          	j	50e0 <__subdf3+0x144>
    521c:	01d5e833          	or	a6,a1,t4
    5220:	80198313          	addi	t1,s3,-2047
    5224:	06080863          	beqz	a6,5294 <__subdf3+0x2f8>
    5228:	06d40a63          	beq	s0,a3,529c <__subdf3+0x300>
    522c:	0e030463          	beqz	t1,5314 <__subdf3+0x378>
    5230:	26098e63          	beqz	s3,54ac <__subdf3+0x510>
    5234:	00361513          	slli	a0,a2,0x3
    5238:	00355513          	srli	a0,a0,0x3
    523c:	00068413          	mv	s0,a3
    5240:	00058713          	mv	a4,a1
    5244:	01d71813          	slli	a6,a4,0x1d
    5248:	00a86833          	or	a6,a6,a0
    524c:	00375713          	srli	a4,a4,0x3
    5250:	01076733          	or	a4,a4,a6
    5254:	10070663          	beqz	a4,5360 <__subdf3+0x3c4>
    5258:	00000e13          	li	t3,0
    525c:	7ff00793          	li	a5,2047
    5260:	00080737          	lui	a4,0x80
    5264:	00000813          	li	a6,0
    5268:	ed9ff06f          	j	5140 <__subdf3+0x1a4>
    526c:	01d5e6b3          	or	a3,a1,t4
    5270:	18068663          	beqz	a3,53fc <__subdf3+0x460>
    5274:	fff78693          	addi	a3,a5,-1
    5278:	3a068263          	beqz	a3,561c <__subdf3+0x680>
    527c:	16678463          	beq	a5,t1,53e4 <__subdf3+0x448>
    5280:	03800793          	li	a5,56
    5284:	00100513          	li	a0,1
    5288:	dcd7cee3          	blt	a5,a3,5064 <__subdf3+0xc8>
    528c:	00068793          	mv	a5,a3
    5290:	da5ff06f          	j	5034 <__subdf3+0x98>
    5294:	0016c693          	xori	a3,a3,1
    5298:	f8d41ae3          	bne	s0,a3,522c <__subdf3+0x290>
    529c:	18030863          	beqz	t1,542c <__subdf3+0x490>
    52a0:	2c099063          	bnez	s3,5560 <__subdf3+0x5c4>
    52a4:	7ff00793          	li	a5,2047
    52a8:	011766b3          	or	a3,a4,a7
    52ac:	48068863          	beqz	a3,573c <__subdf3+0x7a0>
    52b0:	fff78693          	addi	a3,a5,-1
    52b4:	34068263          	beqz	a3,55f8 <__subdf3+0x65c>
    52b8:	7ff00513          	li	a0,2047
    52bc:	2aa78263          	beq	a5,a0,5560 <__subdf3+0x5c4>
    52c0:	03800793          	li	a5,56
    52c4:	00100913          	li	s2,1
    52c8:	02d7ca63          	blt	a5,a3,52fc <__subdf3+0x360>
    52cc:	01f00793          	li	a5,31
    52d0:	4cd7c663          	blt	a5,a3,579c <__subdf3+0x800>
    52d4:	02000793          	li	a5,32
    52d8:	40d787b3          	sub	a5,a5,a3
    52dc:	00f71933          	sll	s2,a4,a5
    52e0:	00d8d633          	srl	a2,a7,a3
    52e4:	00f897b3          	sll	a5,a7,a5
    52e8:	00c96933          	or	s2,s2,a2
    52ec:	00f037b3          	snez	a5,a5
    52f0:	00d756b3          	srl	a3,a4,a3
    52f4:	00f96933          	or	s2,s2,a5
    52f8:	00d585b3          	add	a1,a1,a3
    52fc:	01d90733          	add	a4,s2,t4
    5300:	01273933          	sltu	s2,a4,s2
    5304:	00070493          	mv	s1,a4
    5308:	00b90933          	add	s2,s2,a1
    530c:	000f0993          	mv	s3,t5
    5310:	ed1ff06f          	j	51e0 <__subdf3+0x244>
    5314:	00198793          	addi	a5,s3,1
    5318:	7fe7f793          	andi	a5,a5,2046
    531c:	14079463          	bnez	a5,5464 <__subdf3+0x4c8>
    5320:	01d5e833          	or	a6,a1,t4
    5324:	011767b3          	or	a5,a4,a7
    5328:	2a099463          	bnez	s3,55d0 <__subdf3+0x634>
    532c:	38078e63          	beqz	a5,56c8 <__subdf3+0x72c>
    5330:	3c081063          	bnez	a6,56f0 <__subdf3+0x754>
    5334:	00351513          	slli	a0,a0,0x3
    5338:	00355913          	srli	s2,a0,0x3
    533c:	00000793          	li	a5,0
    5340:	1140006f          	j	5454 <__subdf3+0x4b8>
    5344:	0a698063          	beq	s3,t1,53e4 <__subdf3+0x448>
    5348:	03800693          	li	a3,56
    534c:	00100913          	li	s2,1
    5350:	e8f6c0e3          	blt	a3,a5,51d0 <__subdf3+0x234>
    5354:	008006b7          	lui	a3,0x800
    5358:	00d5e5b3          	or	a1,a1,a3
    535c:	e45ff06f          	j	51a0 <__subdf3+0x204>
    5360:	00147e13          	andi	t3,s0,1
    5364:	7ff00793          	li	a5,2047
    5368:	00000713          	li	a4,0
    536c:	00000813          	li	a6,0
    5370:	dd1ff06f          	j	5140 <__subdf3+0x1a4>
    5374:	00048513          	mv	a0,s1
    5378:	7a0000ef          	jal	5b18 <__clzsi2>
    537c:	01850793          	addi	a5,a0,24
    5380:	01f00693          	li	a3,31
    5384:	d0f6dae3          	bge	a3,a5,5098 <__subdf3+0xfc>
    5388:	ff850713          	addi	a4,a0,-8
    538c:	00e49733          	sll	a4,s1,a4
    5390:	1b37ce63          	blt	a5,s3,554c <__subdf3+0x5b0>
    5394:	413789b3          	sub	s3,a5,s3
    5398:	00198793          	addi	a5,s3,1
    539c:	42f6de63          	bge	a3,a5,57d8 <__subdf3+0x83c>
    53a0:	fe198993          	addi	s3,s3,-31
    53a4:	02000693          	li	a3,32
    53a8:	013754b3          	srl	s1,a4,s3
    53ac:	00d78c63          	beq	a5,a3,53c4 <__subdf3+0x428>
    53b0:	04000693          	li	a3,64
    53b4:	40f687b3          	sub	a5,a3,a5
    53b8:	00f71733          	sll	a4,a4,a5
    53bc:	00e03733          	snez	a4,a4
    53c0:	00e4e4b3          	or	s1,s1,a4
    53c4:	00000993          	li	s3,0
    53c8:	0074f793          	andi	a5,s1,7
    53cc:	d0079ee3          	bnez	a5,50e8 <__subdf3+0x14c>
    53d0:	00098793          	mv	a5,s3
    53d4:	0034d513          	srli	a0,s1,0x3
    53d8:	00090713          	mv	a4,s2
    53dc:	0280006f          	j	5404 <__subdf3+0x468>
    53e0:	e6081ce3          	bnez	a6,5258 <__subdf3+0x2bc>
    53e4:	00351513          	slli	a0,a0,0x3
    53e8:	01d71813          	slli	a6,a4,0x1d
    53ec:	00355513          	srli	a0,a0,0x3
    53f0:	00a86833          	or	a6,a6,a0
    53f4:	00375713          	srli	a4,a4,0x3
    53f8:	e59ff06f          	j	5250 <__subdf3+0x2b4>
    53fc:	00351513          	slli	a0,a0,0x3
    5400:	00355513          	srli	a0,a0,0x3
    5404:	01d71813          	slli	a6,a4,0x1d
    5408:	7ff00693          	li	a3,2047
    540c:	00a86833          	or	a6,a6,a0
    5410:	00375713          	srli	a4,a4,0x3
    5414:	e2d78ee3          	beq	a5,a3,5250 <__subdf3+0x2b4>
    5418:	00c71713          	slli	a4,a4,0xc
    541c:	00c75713          	srli	a4,a4,0xc
    5420:	7ff7f793          	andi	a5,a5,2047
    5424:	00147e13          	andi	t3,s0,1
    5428:	d19ff06f          	j	5140 <__subdf3+0x1a4>
    542c:	00198693          	addi	a3,s3,1
    5430:	7fe6f793          	andi	a5,a3,2046
    5434:	12079e63          	bnez	a5,5570 <__subdf3+0x5d4>
    5438:	011767b3          	or	a5,a4,a7
    543c:	24099a63          	bnez	s3,5690 <__subdf3+0x6f4>
    5440:	30078663          	beqz	a5,574c <__subdf3+0x7b0>
    5444:	01d5e7b3          	or	a5,a1,t4
    5448:	30079a63          	bnez	a5,575c <__subdf3+0x7c0>
    544c:	00351513          	slli	a0,a0,0x3
    5450:	00355913          	srli	s2,a0,0x3
    5454:	01d71813          	slli	a6,a4,0x1d
    5458:	01286833          	or	a6,a6,s2
    545c:	00375713          	srli	a4,a4,0x3
    5460:	fb9ff06f          	j	5418 <__subdf3+0x47c>
    5464:	41d88833          	sub	a6,a7,t4
    5468:	0108b7b3          	sltu	a5,a7,a6
    546c:	40b70933          	sub	s2,a4,a1
    5470:	40f90933          	sub	s2,s2,a5
    5474:	00891793          	slli	a5,s2,0x8
    5478:	00080493          	mv	s1,a6
    547c:	1207c263          	bltz	a5,55a0 <__subdf3+0x604>
    5480:	01286833          	or	a6,a6,s2
    5484:	c00812e3          	bnez	a6,5088 <__subdf3+0xec>
    5488:	00000e13          	li	t3,0
    548c:	00000793          	li	a5,0
    5490:	00000713          	li	a4,0
    5494:	cadff06f          	j	5140 <__subdf3+0x1a4>
    5498:	ff800937          	lui	s2,0xff800
    549c:	fff90913          	addi	s2,s2,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8fcf>
    54a0:	40f989b3          	sub	s3,s3,a5
    54a4:	01277933          	and	s2,a4,s2
    54a8:	c39ff06f          	j	50e0 <__subdf3+0x144>
    54ac:	7ff00793          	li	a5,2047
    54b0:	01176533          	or	a0,a4,a7
    54b4:	10050463          	beqz	a0,55bc <__subdf3+0x620>
    54b8:	fff78813          	addi	a6,a5,-1
    54bc:	1e080263          	beqz	a6,56a0 <__subdf3+0x704>
    54c0:	7ff00513          	li	a0,2047
    54c4:	d6a788e3          	beq	a5,a0,5234 <__subdf3+0x298>
    54c8:	03800793          	li	a5,56
    54cc:	00068413          	mv	s0,a3
    54d0:	00100513          	li	a0,1
    54d4:	0307ca63          	blt	a5,a6,5508 <__subdf3+0x56c>
    54d8:	01f00793          	li	a5,31
    54dc:	1907c463          	blt	a5,a6,5664 <__subdf3+0x6c8>
    54e0:	02000793          	li	a5,32
    54e4:	410787b3          	sub	a5,a5,a6
    54e8:	00f71533          	sll	a0,a4,a5
    54ec:	0108d6b3          	srl	a3,a7,a6
    54f0:	00f897b3          	sll	a5,a7,a5
    54f4:	00d56533          	or	a0,a0,a3
    54f8:	00f037b3          	snez	a5,a5
    54fc:	01075833          	srl	a6,a4,a6
    5500:	00f56533          	or	a0,a0,a5
    5504:	410585b3          	sub	a1,a1,a6
    5508:	40ae8533          	sub	a0,t4,a0
    550c:	00aeb733          	sltu	a4,t4,a0
    5510:	00050493          	mv	s1,a0
    5514:	40e58933          	sub	s2,a1,a4
    5518:	000f0993          	mv	s3,t5
    551c:	b59ff06f          	j	5074 <__subdf3+0xd8>
    5520:	fe078693          	addi	a3,a5,-32
    5524:	02000613          	li	a2,32
    5528:	00d5d6b3          	srl	a3,a1,a3
    552c:	00c78a63          	beq	a5,a2,5540 <__subdf3+0x5a4>
    5530:	04000613          	li	a2,64
    5534:	40f607b3          	sub	a5,a2,a5
    5538:	00f597b3          	sll	a5,a1,a5
    553c:	00feeeb3          	or	t4,t4,a5
    5540:	01d03533          	snez	a0,t4
    5544:	00d56533          	or	a0,a0,a3
    5548:	b1dff06f          	j	5064 <__subdf3+0xc8>
    554c:	ff8006b7          	lui	a3,0xff800
    5550:	fff68693          	addi	a3,a3,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8fcf>
    5554:	40f987b3          	sub	a5,s3,a5
    5558:	00d77733          	and	a4,a4,a3
    555c:	ef9ff06f          	j	5454 <__subdf3+0x4b8>
    5560:	00361513          	slli	a0,a2,0x3
    5564:	00355513          	srli	a0,a0,0x3
    5568:	00058713          	mv	a4,a1
    556c:	cd9ff06f          	j	5244 <__subdf3+0x2a8>
    5570:	7ff00793          	li	a5,2047
    5574:	def686e3          	beq	a3,a5,5360 <__subdf3+0x3c4>
    5578:	01d88eb3          	add	t4,a7,t4
    557c:	011eb633          	sltu	a2,t4,a7
    5580:	00b707b3          	add	a5,a4,a1
    5584:	00c787b3          	add	a5,a5,a2
    5588:	01f79513          	slli	a0,a5,0x1f
    558c:	001ede93          	srli	t4,t4,0x1
    5590:	01d564b3          	or	s1,a0,t4
    5594:	0017d913          	srli	s2,a5,0x1
    5598:	00068993          	mv	s3,a3
    559c:	b45ff06f          	j	50e0 <__subdf3+0x144>
    55a0:	411e8633          	sub	a2,t4,a7
    55a4:	40e587b3          	sub	a5,a1,a4
    55a8:	00ceb733          	sltu	a4,t4,a2
    55ac:	00060493          	mv	s1,a2
    55b0:	40e78933          	sub	s2,a5,a4
    55b4:	00068413          	mv	s0,a3
    55b8:	ad1ff06f          	j	5088 <__subdf3+0xec>
    55bc:	00361613          	slli	a2,a2,0x3
    55c0:	00365513          	srli	a0,a2,0x3
    55c4:	00068413          	mv	s0,a3
    55c8:	00058713          	mv	a4,a1
    55cc:	e39ff06f          	j	5404 <__subdf3+0x468>
    55d0:	e00798e3          	bnez	a5,53e0 <__subdf3+0x444>
    55d4:	22080663          	beqz	a6,5800 <__subdf3+0x864>
    55d8:	0035d713          	srli	a4,a1,0x3
    55dc:	00361613          	slli	a2,a2,0x3
    55e0:	01d59593          	slli	a1,a1,0x1d
    55e4:	00b76733          	or	a4,a4,a1
    55e8:	00365613          	srli	a2,a2,0x3
    55ec:	00c76733          	or	a4,a4,a2
    55f0:	00068413          	mv	s0,a3
    55f4:	c61ff06f          	j	5254 <__subdf3+0x2b8>
    55f8:	01d88eb3          	add	t4,a7,t4
    55fc:	00b705b3          	add	a1,a4,a1
    5600:	011eb633          	sltu	a2,t4,a7
    5604:	00c58933          	add	s2,a1,a2
    5608:	00891793          	slli	a5,s2,0x8
    560c:	000e8493          	mv	s1,t4
    5610:	0a07d863          	bgez	a5,56c0 <__subdf3+0x724>
    5614:	00200993          	li	s3,2
    5618:	bddff06f          	j	51f4 <__subdf3+0x258>
    561c:	41d88eb3          	sub	t4,a7,t4
    5620:	40b705b3          	sub	a1,a4,a1
    5624:	01d8b633          	sltu	a2,a7,t4
    5628:	000e8493          	mv	s1,t4
    562c:	40c58933          	sub	s2,a1,a2
    5630:	00100993          	li	s3,1
    5634:	a41ff06f          	j	5074 <__subdf3+0xd8>
    5638:	fe078693          	addi	a3,a5,-32
    563c:	02000613          	li	a2,32
    5640:	00d5d6b3          	srl	a3,a1,a3
    5644:	00c78a63          	beq	a5,a2,5658 <__subdf3+0x6bc>
    5648:	04000613          	li	a2,64
    564c:	40f607b3          	sub	a5,a2,a5
    5650:	00f597b3          	sll	a5,a1,a5
    5654:	00feeeb3          	or	t4,t4,a5
    5658:	01d03933          	snez	s2,t4
    565c:	00d96933          	or	s2,s2,a3
    5660:	b71ff06f          	j	51d0 <__subdf3+0x234>
    5664:	fe080793          	addi	a5,a6,-32
    5668:	02000693          	li	a3,32
    566c:	00f757b3          	srl	a5,a4,a5
    5670:	00d80a63          	beq	a6,a3,5684 <__subdf3+0x6e8>
    5674:	04000693          	li	a3,64
    5678:	410686b3          	sub	a3,a3,a6
    567c:	00d71733          	sll	a4,a4,a3
    5680:	00e8e8b3          	or	a7,a7,a4
    5684:	01103533          	snez	a0,a7
    5688:	00f56533          	or	a0,a0,a5
    568c:	e7dff06f          	j	5508 <__subdf3+0x56c>
    5690:	ec0788e3          	beqz	a5,5560 <__subdf3+0x5c4>
    5694:	01d5eeb3          	or	t4,a1,t4
    5698:	bc0e90e3          	bnez	t4,5258 <__subdf3+0x2bc>
    569c:	d49ff06f          	j	53e4 <__subdf3+0x448>
    56a0:	411e8633          	sub	a2,t4,a7
    56a4:	40e585b3          	sub	a1,a1,a4
    56a8:	00ceb733          	sltu	a4,t4,a2
    56ac:	00060493          	mv	s1,a2
    56b0:	40e58933          	sub	s2,a1,a4
    56b4:	00068413          	mv	s0,a3
    56b8:	00100993          	li	s3,1
    56bc:	9b9ff06f          	j	5074 <__subdf3+0xd8>
    56c0:	00100793          	li	a5,1
    56c4:	d11ff06f          	j	53d4 <__subdf3+0x438>
    56c8:	dc0800e3          	beqz	a6,5488 <__subdf3+0x4ec>
    56cc:	00361613          	slli	a2,a2,0x3
    56d0:	00365793          	srli	a5,a2,0x3
    56d4:	01d59813          	slli	a6,a1,0x1d
    56d8:	00959713          	slli	a4,a1,0x9
    56dc:	00f86833          	or	a6,a6,a5
    56e0:	00c75713          	srli	a4,a4,0xc
    56e4:	00068e13          	mv	t3,a3
    56e8:	00000793          	li	a5,0
    56ec:	a55ff06f          	j	5140 <__subdf3+0x1a4>
    56f0:	41d88933          	sub	s2,a7,t4
    56f4:	0128b7b3          	sltu	a5,a7,s2
    56f8:	40b70633          	sub	a2,a4,a1
    56fc:	40f60633          	sub	a2,a2,a5
    5700:	00861793          	slli	a5,a2,0x8
    5704:	0e07d263          	bgez	a5,57e8 <__subdf3+0x84c>
    5708:	411e8633          	sub	a2,t4,a7
    570c:	40e58733          	sub	a4,a1,a4
    5710:	00cebeb3          	sltu	t4,t4,a2
    5714:	41d70733          	sub	a4,a4,t4
    5718:	00871793          	slli	a5,a4,0x8
    571c:	00060493          	mv	s1,a2
    5720:	1207de63          	bgez	a5,585c <__subdf3+0x8c0>
    5724:	ff8007b7          	lui	a5,0xff800
    5728:	fff78793          	addi	a5,a5,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8fcf>
    572c:	00f77733          	and	a4,a4,a5
    5730:	00068413          	mv	s0,a3
    5734:	00100793          	li	a5,1
    5738:	9f1ff06f          	j	5128 <__subdf3+0x18c>
    573c:	00361613          	slli	a2,a2,0x3
    5740:	00365513          	srli	a0,a2,0x3
    5744:	00058713          	mv	a4,a1
    5748:	cbdff06f          	j	5404 <__subdf3+0x468>
    574c:	00361613          	slli	a2,a2,0x3
    5750:	00365913          	srli	s2,a2,0x3
    5754:	00058713          	mv	a4,a1
    5758:	cfdff06f          	j	5454 <__subdf3+0x4b8>
    575c:	01d886b3          	add	a3,a7,t4
    5760:	00b707b3          	add	a5,a4,a1
    5764:	0116b633          	sltu	a2,a3,a7
    5768:	00c787b3          	add	a5,a5,a2
    576c:	00879713          	slli	a4,a5,0x8
    5770:	0036d813          	srli	a6,a3,0x3
    5774:	08075e63          	bgez	a4,5810 <__subdf3+0x874>
    5778:	ff800737          	lui	a4,0xff800
    577c:	fff70713          	addi	a4,a4,-1 # ff7fffff <__freertos_irq_stack_top+0xff7f8fcf>
    5780:	00e7f7b3          	and	a5,a5,a4
    5784:	01d79713          	slli	a4,a5,0x1d
    5788:	00979793          	slli	a5,a5,0x9
    578c:	01076833          	or	a6,a4,a6
    5790:	00c7d713          	srli	a4,a5,0xc
    5794:	00100793          	li	a5,1
    5798:	9a9ff06f          	j	5140 <__subdf3+0x1a4>
    579c:	fe068793          	addi	a5,a3,-32
    57a0:	02000613          	li	a2,32
    57a4:	00f757b3          	srl	a5,a4,a5
    57a8:	00c68a63          	beq	a3,a2,57bc <__subdf3+0x820>
    57ac:	04000613          	li	a2,64
    57b0:	40d606b3          	sub	a3,a2,a3
    57b4:	00d71733          	sll	a4,a4,a3
    57b8:	00e8e8b3          	or	a7,a7,a4
    57bc:	01103933          	snez	s2,a7
    57c0:	00f96933          	or	s2,s2,a5
    57c4:	b39ff06f          	j	52fc <__subdf3+0x360>
    57c8:	0034d513          	srli	a0,s1,0x3
    57cc:	00098793          	mv	a5,s3
    57d0:	00090713          	mv	a4,s2
    57d4:	c31ff06f          	j	5404 <__subdf3+0x468>
    57d8:	02000693          	li	a3,32
    57dc:	40f686b3          	sub	a3,a3,a5
    57e0:	00000613          	li	a2,0
    57e4:	8e9ff06f          	j	50cc <__subdf3+0x130>
    57e8:	00c96833          	or	a6,s2,a2
    57ec:	c8080ee3          	beqz	a6,5488 <__subdf3+0x4ec>
    57f0:	00395913          	srli	s2,s2,0x3
    57f4:	00000793          	li	a5,0
    57f8:	00060713          	mv	a4,a2
    57fc:	c59ff06f          	j	5454 <__subdf3+0x4b8>
    5800:	00000e13          	li	t3,0
    5804:	7ff00793          	li	a5,2047
    5808:	00080737          	lui	a4,0x80
    580c:	935ff06f          	j	5140 <__subdf3+0x1a4>
    5810:	01d79713          	slli	a4,a5,0x1d
    5814:	00979793          	slli	a5,a5,0x9
    5818:	01076833          	or	a6,a4,a6
    581c:	00c7d713          	srli	a4,a5,0xc
    5820:	00000793          	li	a5,0
    5824:	91dff06f          	j	5140 <__subdf3+0x1a4>
    5828:	ae0786e3          	beqz	a5,5314 <__subdf3+0x378>
    582c:	413f0833          	sub	a6,t5,s3
    5830:	00080793          	mv	a5,a6
    5834:	c6098ee3          	beqz	s3,54b0 <__subdf3+0x514>
    5838:	03800793          	li	a5,56
    583c:	0107ca63          	blt	a5,a6,5850 <__subdf3+0x8b4>
    5840:	008007b7          	lui	a5,0x800
    5844:	00f76733          	or	a4,a4,a5
    5848:	00068413          	mv	s0,a3
    584c:	c8dff06f          	j	54d8 <__subdf3+0x53c>
    5850:	00068413          	mv	s0,a3
    5854:	00100513          	li	a0,1
    5858:	cb1ff06f          	j	5508 <__subdf3+0x56c>
    585c:	01d71813          	slli	a6,a4,0x1d
    5860:	00365613          	srli	a2,a2,0x3
    5864:	00c86833          	or	a6,a6,a2
    5868:	00375713          	srli	a4,a4,0x3
    586c:	00000793          	li	a5,0
    5870:	00068413          	mv	s0,a3
    5874:	ba5ff06f          	j	5418 <__subdf3+0x47c>
    5878:	ba078ae3          	beqz	a5,542c <__subdf3+0x490>
    587c:	413f06b3          	sub	a3,t5,s3
    5880:	00099663          	bnez	s3,588c <__subdf3+0x8f0>
    5884:	00068793          	mv	a5,a3
    5888:	a21ff06f          	j	52a8 <__subdf3+0x30c>
    588c:	03800793          	li	a5,56
    5890:	00100913          	li	s2,1
    5894:	a6d7c4e3          	blt	a5,a3,52fc <__subdf3+0x360>
    5898:	008007b7          	lui	a5,0x800
    589c:	00f76733          	or	a4,a4,a5
    58a0:	a2dff06f          	j	52cc <__subdf3+0x330>

000058a4 <__fixdfsi>:
    58a4:	0145d793          	srli	a5,a1,0x14
    58a8:	001006b7          	lui	a3,0x100
    58ac:	fff68713          	addi	a4,a3,-1 # fffff <__freertos_irq_stack_top+0xf8fcf>
    58b0:	7ff7f793          	andi	a5,a5,2047
    58b4:	3fe00613          	li	a2,1022
    58b8:	00b77733          	and	a4,a4,a1
    58bc:	01f5d593          	srli	a1,a1,0x1f
    58c0:	00f65e63          	bge	a2,a5,58dc <__fixdfsi+0x38>
    58c4:	41d00613          	li	a2,1053
    58c8:	00f65e63          	bge	a2,a5,58e4 <__fixdfsi+0x40>
    58cc:	80000537          	lui	a0,0x80000
    58d0:	fff50513          	addi	a0,a0,-1 # 7fffffff <__freertos_irq_stack_top+0x7fff8fcf>
    58d4:	00a58533          	add	a0,a1,a0
    58d8:	00008067          	ret
    58dc:	00000513          	li	a0,0
    58e0:	00008067          	ret
    58e4:	43300613          	li	a2,1075
    58e8:	40f60633          	sub	a2,a2,a5
    58ec:	01f00813          	li	a6,31
    58f0:	00d76733          	or	a4,a4,a3
    58f4:	02c85063          	bge	a6,a2,5914 <__fixdfsi+0x70>
    58f8:	41300693          	li	a3,1043
    58fc:	40f687b3          	sub	a5,a3,a5
    5900:	00f75733          	srl	a4,a4,a5
    5904:	40e00533          	neg	a0,a4
    5908:	fc059ce3          	bnez	a1,58e0 <__fixdfsi+0x3c>
    590c:	00070513          	mv	a0,a4
    5910:	00008067          	ret
    5914:	bed78793          	addi	a5,a5,-1043 # 7ffbed <__freertos_irq_stack_top+0x7f8bbd>
    5918:	00f71733          	sll	a4,a4,a5
    591c:	00c55533          	srl	a0,a0,a2
    5920:	00a76733          	or	a4,a4,a0
    5924:	fe1ff06f          	j	5904 <__fixdfsi+0x60>

00005928 <__fixunsdfsi>:
    5928:	0145d793          	srli	a5,a1,0x14
    592c:	00100637          	lui	a2,0x100
    5930:	fff60713          	addi	a4,a2,-1 # fffff <__freertos_irq_stack_top+0xf8fcf>
    5934:	7ff7f793          	andi	a5,a5,2047
    5938:	3fe00813          	li	a6,1022
    593c:	00050693          	mv	a3,a0
    5940:	00b77733          	and	a4,a4,a1
    5944:	00000513          	li	a0,0
    5948:	01f5d593          	srli	a1,a1,0x1f
    594c:	00f85463          	bge	a6,a5,5954 <__fixunsdfsi+0x2c>
    5950:	00058463          	beqz	a1,5958 <__fixunsdfsi+0x30>
    5954:	00008067          	ret
    5958:	41e00593          	li	a1,1054
    595c:	fff00513          	li	a0,-1
    5960:	fef5cae3          	blt	a1,a5,5954 <__fixunsdfsi+0x2c>
    5964:	43300593          	li	a1,1075
    5968:	40f585b3          	sub	a1,a1,a5
    596c:	01f00513          	li	a0,31
    5970:	00c76733          	or	a4,a4,a2
    5974:	00b54c63          	blt	a0,a1,598c <__fixunsdfsi+0x64>
    5978:	bed78793          	addi	a5,a5,-1043
    597c:	00f71733          	sll	a4,a4,a5
    5980:	00b6d533          	srl	a0,a3,a1
    5984:	00a76533          	or	a0,a4,a0
    5988:	00008067          	ret
    598c:	41300513          	li	a0,1043
    5990:	40f50533          	sub	a0,a0,a5
    5994:	00a75533          	srl	a0,a4,a0
    5998:	00008067          	ret

0000599c <__floatsidf>:
    599c:	ff010113          	addi	sp,sp,-16
    59a0:	00112623          	sw	ra,12(sp)
    59a4:	00812423          	sw	s0,8(sp)
    59a8:	00912223          	sw	s1,4(sp)
    59ac:	04050a63          	beqz	a0,5a00 <__floatsidf+0x64>
    59b0:	41f55713          	srai	a4,a0,0x1f
    59b4:	00a744b3          	xor	s1,a4,a0
    59b8:	40e484b3          	sub	s1,s1,a4
    59bc:	00050793          	mv	a5,a0
    59c0:	00048513          	mv	a0,s1
    59c4:	01f7d413          	srli	s0,a5,0x1f
    59c8:	150000ef          	jal	5b18 <__clzsi2>
    59cc:	41e00793          	li	a5,1054
    59d0:	40a787b3          	sub	a5,a5,a0
    59d4:	00a00713          	li	a4,10
    59d8:	7ff7f793          	andi	a5,a5,2047
    59dc:	06a74063          	blt	a4,a0,5a3c <__floatsidf+0xa0>
    59e0:	00b00713          	li	a4,11
    59e4:	40a70733          	sub	a4,a4,a0
    59e8:	00e4d733          	srl	a4,s1,a4
    59ec:	01550513          	addi	a0,a0,21
    59f0:	00c71713          	slli	a4,a4,0xc
    59f4:	00a494b3          	sll	s1,s1,a0
    59f8:	00c75713          	srli	a4,a4,0xc
    59fc:	0140006f          	j	5a10 <__floatsidf+0x74>
    5a00:	00000413          	li	s0,0
    5a04:	00000793          	li	a5,0
    5a08:	00000713          	li	a4,0
    5a0c:	00000493          	li	s1,0
    5a10:	01479793          	slli	a5,a5,0x14
    5a14:	01f41413          	slli	s0,s0,0x1f
    5a18:	00e7e7b3          	or	a5,a5,a4
    5a1c:	00c12083          	lw	ra,12(sp)
    5a20:	0087e7b3          	or	a5,a5,s0
    5a24:	00812403          	lw	s0,8(sp)
    5a28:	00048513          	mv	a0,s1
    5a2c:	00078593          	mv	a1,a5
    5a30:	00412483          	lw	s1,4(sp)
    5a34:	01010113          	addi	sp,sp,16
    5a38:	00008067          	ret
    5a3c:	ff550513          	addi	a0,a0,-11
    5a40:	00a49733          	sll	a4,s1,a0
    5a44:	00c71713          	slli	a4,a4,0xc
    5a48:	00c75713          	srli	a4,a4,0xc
    5a4c:	00000493          	li	s1,0
    5a50:	fc1ff06f          	j	5a10 <__floatsidf+0x74>

00005a54 <__floatunsidf>:
    5a54:	ff010113          	addi	sp,sp,-16
    5a58:	00812423          	sw	s0,8(sp)
    5a5c:	00112623          	sw	ra,12(sp)
    5a60:	00050413          	mv	s0,a0
    5a64:	04050c63          	beqz	a0,5abc <__floatunsidf+0x68>
    5a68:	0b0000ef          	jal	5b18 <__clzsi2>
    5a6c:	41e00793          	li	a5,1054
    5a70:	40a787b3          	sub	a5,a5,a0
    5a74:	00a00713          	li	a4,10
    5a78:	7ff7f793          	andi	a5,a5,2047
    5a7c:	06a74463          	blt	a4,a0,5ae4 <__floatunsidf+0x90>
    5a80:	00b00713          	li	a4,11
    5a84:	40a70733          	sub	a4,a4,a0
    5a88:	01550513          	addi	a0,a0,21
    5a8c:	00e45733          	srl	a4,s0,a4
    5a90:	00a41433          	sll	s0,s0,a0
    5a94:	00c12083          	lw	ra,12(sp)
    5a98:	00040513          	mv	a0,s0
    5a9c:	00c71713          	slli	a4,a4,0xc
    5aa0:	00812403          	lw	s0,8(sp)
    5aa4:	00c75713          	srli	a4,a4,0xc
    5aa8:	01479793          	slli	a5,a5,0x14
    5aac:	00e7e7b3          	or	a5,a5,a4
    5ab0:	00078593          	mv	a1,a5
    5ab4:	01010113          	addi	sp,sp,16
    5ab8:	00008067          	ret
    5abc:	00c12083          	lw	ra,12(sp)
    5ac0:	00040513          	mv	a0,s0
    5ac4:	00000793          	li	a5,0
    5ac8:	00812403          	lw	s0,8(sp)
    5acc:	00000713          	li	a4,0
    5ad0:	01479793          	slli	a5,a5,0x14
    5ad4:	00e7e7b3          	or	a5,a5,a4
    5ad8:	00078593          	mv	a1,a5
    5adc:	01010113          	addi	sp,sp,16
    5ae0:	00008067          	ret
    5ae4:	ff550513          	addi	a0,a0,-11
    5ae8:	00a41733          	sll	a4,s0,a0
    5aec:	00000413          	li	s0,0
    5af0:	00c12083          	lw	ra,12(sp)
    5af4:	00040513          	mv	a0,s0
    5af8:	00c71713          	slli	a4,a4,0xc
    5afc:	00812403          	lw	s0,8(sp)
    5b00:	00c75713          	srli	a4,a4,0xc
    5b04:	01479793          	slli	a5,a5,0x14
    5b08:	00e7e7b3          	or	a5,a5,a4
    5b0c:	00078593          	mv	a1,a5
    5b10:	01010113          	addi	sp,sp,16
    5b14:	00008067          	ret

00005b18 <__clzsi2>:
    5b18:	000107b7          	lui	a5,0x10
    5b1c:	02f57a63          	bgeu	a0,a5,5b50 <__clzsi2+0x38>
    5b20:	10053793          	sltiu	a5,a0,256
    5b24:	0017b793          	seqz	a5,a5
    5b28:	00379793          	slli	a5,a5,0x3
    5b2c:	02000713          	li	a4,32
    5b30:	40f70733          	sub	a4,a4,a5
    5b34:	00f55533          	srl	a0,a0,a5
    5b38:	00000797          	auipc	a5,0x0
    5b3c:	34878793          	addi	a5,a5,840 # 5e80 <__clz_tab>
    5b40:	00a787b3          	add	a5,a5,a0
    5b44:	0007c503          	lbu	a0,0(a5)
    5b48:	40a70533          	sub	a0,a4,a0
    5b4c:	00008067          	ret
    5b50:	010007b7          	lui	a5,0x1000
    5b54:	02f57463          	bgeu	a0,a5,5b7c <__clzsi2+0x64>
    5b58:	01000793          	li	a5,16
    5b5c:	00f55533          	srl	a0,a0,a5
    5b60:	00000797          	auipc	a5,0x0
    5b64:	32078793          	addi	a5,a5,800 # 5e80 <__clz_tab>
    5b68:	00a787b3          	add	a5,a5,a0
    5b6c:	0007c503          	lbu	a0,0(a5)
    5b70:	01000713          	li	a4,16
    5b74:	40a70533          	sub	a0,a4,a0
    5b78:	00008067          	ret
    5b7c:	01800793          	li	a5,24
    5b80:	00f55533          	srl	a0,a0,a5
    5b84:	00000797          	auipc	a5,0x0
    5b88:	2fc78793          	addi	a5,a5,764 # 5e80 <__clz_tab>
    5b8c:	00a787b3          	add	a5,a5,a0
    5b90:	0007c503          	lbu	a0,0(a5)
    5b94:	00800713          	li	a4,8
    5b98:	40a70533          	sub	a0,a4,a0
    5b9c:	00008067          	ret
