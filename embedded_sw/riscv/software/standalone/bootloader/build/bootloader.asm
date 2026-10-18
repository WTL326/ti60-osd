
build/bootloader.elf:     file format elf32-littleriscv


Disassembly of section .init:

f9000000 <_start>:

_start:
#ifdef USE_GP
.option push
.option norelax
	la gp, __global_pointer$
f9000000:	00001197          	auipc	gp,0x1
f9000004:	f7018193          	addi	gp,gp,-144 # f9000f70 <__global_pointer$>
.global smp_lottery_target
.global smp_lottery_lock
.global smp_slave


  sw x0, smp_lottery_lock, a1
f9000008:	8201a023          	sw	zero,-2016(gp) # f9000790 <smp_lottery_lock>

f900000c <smp_tyranny>:

smp_tyranny:
  csrr a0, mhartid
f900000c:	f1402573          	csrr	a0,mhartid
  beqz a0, init
f9000010:	02050e63          	beqz	a0,f900004c <init>

f9000014 <smp_slave>:

smp_slave:
	lw a0, smp_lottery_lock
f9000014:	8201a503          	lw	a0,-2016(gp) # f9000790 <smp_lottery_lock>
	beqz a0, smp_slave
f9000018:	fe050ee3          	beqz	a0,f9000014 <smp_slave>

	fence r, r
f900001c:	0220000f          	fence	r,r
f9000020:	0000100f          	.word	0x0000100f
	//li a1, -1
	//amoadd.w x0, a1,(a0)

	.word(0x100F) //i$ flush
	lw a5, smp_lottery_target
f9000024:	81c1a783          	lw	a5,-2020(gp) # f900078c <__bss_start>
	li a0, 0
f9000028:	00000513          	li	a0,0
	li a1, 0
f900002c:	00000593          	li	a1,0
	li a2, 0
f9000030:	00000613          	li	a2,0
	jr a5
f9000034:	00078067          	jr	a5

f9000038 <smp_unlock>:

.global   smp_unlock
.type    smp_unlock,%function
smp_unlock:
	sw a0, smp_lottery_target, a1
f9000038:	80a1ae23          	sw	a0,-2020(gp) # f900078c <__bss_start>
	fence w, w
f900003c:	0110000f          	fence	w,w
	li a0, 1
f9000040:	00100513          	li	a0,1
	sw a0, smp_lottery_lock, a1
f9000044:	82a1a023          	sw	a0,-2016(gp) # f9000790 <smp_lottery_lock>
    ret
f9000048:	00008067          	ret

f900004c <init>:
#endif

init:
	la sp, _sp
f900004c:	00001117          	auipc	sp,0x1
f9000050:	85410113          	addi	sp,sp,-1964 # f90008a0 <_sp>

	/* Load data section */
	la a0, _data_lma
f9000054:	00000517          	auipc	a0,0x0
f9000058:	72850513          	addi	a0,a0,1832 # f900077c <_data>
	la a1, _data
f900005c:	00000597          	auipc	a1,0x0
f9000060:	72058593          	addi	a1,a1,1824 # f900077c <_data>
	la a2, _edata
f9000064:	00000617          	auipc	a2,0x0
f9000068:	72860613          	addi	a2,a2,1832 # f900078c <__bss_start>
	bgeu a1, a2, 2f
f900006c:	00c5fc63          	bgeu	a1,a2,f9000084 <init+0x38>
1:
	lw t0, (a0)
f9000070:	00052283          	lw	t0,0(a0)
	sw t0, (a1)
f9000074:	0055a023          	sw	t0,0(a1)
	addi a0, a0, 4
f9000078:	00450513          	addi	a0,a0,4
	addi a1, a1, 4
f900007c:	00458593          	addi	a1,a1,4
	bltu a1, a2, 1b
f9000080:	fec5e8e3          	bltu	a1,a2,f9000070 <init+0x24>
2:

	/* Clear bss section */
	la a0, __bss_start
f9000084:	00000517          	auipc	a0,0x0
f9000088:	70850513          	addi	a0,a0,1800 # f900078c <__bss_start>
	la a1, _end
f900008c:	00000597          	auipc	a1,0x0
f9000090:	70c58593          	addi	a1,a1,1804 # f9000798 <_end>
	bgeu a0, a1, 2f
f9000094:	00b57863          	bgeu	a0,a1,f90000a4 <init+0x58>
1:
	sw zero, (a0)
f9000098:	00052023          	sw	zero,0(a0)
	addi a0, a0, 4
f900009c:	00450513          	addi	a0,a0,4
	bltu a0, a1, 1b
f90000a0:	feb56ce3          	bltu	a0,a1,f9000098 <init+0x4c>
2:

#ifndef NO_LIBC_INIT_ARRAY
	call __libc_init_array
f90000a4:	644000ef          	jal	f90006e8 <__libc_init_array>
#endif

	call main
f90000a8:	624000ef          	jal	f90006cc <main>

f90000ac <mainDone>:
mainDone:
    j mainDone
f90000ac:	0000006f          	j	f90000ac <mainDone>

f90000b0 <_init>:


	.globl _init
_init:
    ret
f90000b0:	00008067          	ret

Disassembly of section .text:

f90000b4 <uart_applyConfig>:
*          value using data length, parity, and stop bit settings from the configuration
*          structure, and writes this value to the UART frame configuration register.
*
******************************************************************************/
    static void uart_applyConfig(u32 reg, Uart_Config *config){
        write_u32(config->clockDivider, reg + UART_CLOCK_DIVIDER);
f90000b4:	00c5a783          	lw	a5,12(a1)
    static inline u32 read_u32(u32 address){
        return *((volatile u32*) address);
    }
    
    static inline void write_u32(u32 data, u32 address){
        *((volatile u32*) address) = data;
f90000b8:	00f52423          	sw	a5,8(a0)
        write_u32(((config->dataLength-1) << 0) | (config->parity << 8) | (config->stop << 16), reg + UART_FRAME_CONFIG);
f90000bc:	0005a783          	lw	a5,0(a1)
f90000c0:	fff78793          	addi	a5,a5,-1
f90000c4:	0045a703          	lw	a4,4(a1)
f90000c8:	00871713          	slli	a4,a4,0x8
f90000cc:	00e7e7b3          	or	a5,a5,a4
f90000d0:	0085a703          	lw	a4,8(a1)
f90000d4:	01071713          	slli	a4,a4,0x10
f90000d8:	00e7e7b3          	or	a5,a5,a4
f90000dc:	00f52623          	sw	a5,12(a0)
    }
f90000e0:	00008067          	ret

f90000e4 <clint_uDelay>:
*          and the time limit is non-negative, indicating that the delay has
*          not yet elapsed.
*
******************************************************************************/
    static void clint_uDelay(u32 usec, u32 hz, u32 reg){
        u32 mTimePerUsec = hz/1000000;
f90000e4:	000f47b7          	lui	a5,0xf4
f90000e8:	24078793          	addi	a5,a5,576 # f4240 <__stack_size+0xf4140>
f90000ec:	02f5d5b3          	divu	a1,a1,a5
    readReg_u32 (clint_getTimeLow , CLINT_TIME_ADDR)
f90000f0:	0000c7b7          	lui	a5,0xc
f90000f4:	ff878793          	addi	a5,a5,-8 # bff8 <__stack_size+0xbef8>
f90000f8:	00f60633          	add	a2,a2,a5
        return *((volatile u32*) address);
f90000fc:	00062783          	lw	a5,0(a2)
        u32 limit = clint_getTimeLow(reg) + usec*mTimePerUsec;
f9000100:	02a585b3          	mul	a1,a1,a0
f9000104:	00f58733          	add	a4,a1,a5
f9000108:	00062783          	lw	a5,0(a2)
        while((int32_t)(limit-(clint_getTimeLow(reg))) >= 0);
f900010c:	40f707b3          	sub	a5,a4,a5
f9000110:	fe07dce3          	bgez	a5,f9000108 <clint_uDelay+0x24>
f9000114:	00008067          	ret

f9000118 <bsp_init>:
    *   1. UART baudrate
    *   2. 
    */
////////////////////////////////////////////////////////////////////////////////
    static void bsp_init()
    {
f9000118:	fe010113          	addi	sp,sp,-32
f900011c:	00112e23          	sw	ra,28(sp)
        Uart_Config uartConfig;
        uartConfig.dataLength   = BITS_8;
f9000120:	00800793          	li	a5,8
f9000124:	00f12023          	sw	a5,0(sp)
        uartConfig.parity       = NONE;
f9000128:	00012223          	sw	zero,4(sp)
        uartConfig.stop         = ONE;
f900012c:	00012423          	sw	zero,8(sp)
        uartConfig.clockDivider = BSP_CLINT_HZ/(BSP_UART_BAUDRATE*BSP_UART_DATA_LEN)-1;
f9000130:	03500793          	li	a5,53
f9000134:	00f12623          	sw	a5,12(sp)
        uart_applyConfig(BSP_UART_TERMINAL, &uartConfig);    
f9000138:	00010593          	mv	a1,sp
f900013c:	f8001537          	lui	a0,0xf8001
f9000140:	f75ff0ef          	jal	f90000b4 <uart_applyConfig>
    }
f9000144:	01c12083          	lw	ra,28(sp)
f9000148:	02010113          	addi	sp,sp,32
f900014c:	00008067          	ret

f9000150 <spi_cmdAvailability>:
f9000150:	00452503          	lw	a0,4(a0) # f8001004 <__stack_size+0xf8000f04>
 * @return The availability of command buffer space (lower 16 bits of SPI buffer)
 *
 ******************************************************************************/
    static u32 spi_cmdAvailability(u32 reg){
        return read_u32(reg + SPI_BUFFER) & 0xFFFF;
    }
f9000154:	01051513          	slli	a0,a0,0x10
f9000158:	01055513          	srli	a0,a0,0x10
f900015c:	00008067          	ret

f9000160 <spi_rspOccupancy>:
f9000160:	00452503          	lw	a0,4(a0)
 * @return The occupancy of response buffer space (upper 16 bits of SPI buffer)
 *
 ******************************************************************************/
    static u32 spi_rspOccupancy(u32 reg){
        return read_u32(reg + SPI_BUFFER) >> 16;
    }
f9000164:	01055513          	srli	a0,a0,0x10
f9000168:	00008067          	ret

f900016c <spi_write>:
 * @param reg The base address of the SPI register
 *
 * @param data The data to be written
 *
 ******************************************************************************/
    static void spi_write(u32 reg, u8 data){
f900016c:	ff010113          	addi	sp,sp,-16
f9000170:	00112623          	sw	ra,12(sp)
f9000174:	00812423          	sw	s0,8(sp)
f9000178:	00912223          	sw	s1,4(sp)
f900017c:	00050413          	mv	s0,a0
f9000180:	00058493          	mv	s1,a1
        while(spi_cmdAvailability(reg) == 0);
f9000184:	00040513          	mv	a0,s0
f9000188:	fc9ff0ef          	jal	f9000150 <spi_cmdAvailability>
f900018c:	fe050ce3          	beqz	a0,f9000184 <spi_write+0x18>
        write_u32(data | SPI_CMD_WRITE, reg + SPI_DATA);
f9000190:	1004e493          	ori	s1,s1,256
        *((volatile u32*) address) = data;
f9000194:	00942023          	sw	s1,0(s0)
    }
f9000198:	00c12083          	lw	ra,12(sp)
f900019c:	00812403          	lw	s0,8(sp)
f90001a0:	00412483          	lw	s1,4(sp)
f90001a4:	01010113          	addi	sp,sp,16
f90001a8:	00008067          	ret

f90001ac <spi_read>:
 * @param reg The base address of the SPI register
 *
 * @return The data read from the SPI data register
 *
 ******************************************************************************/   
    static u8 spi_read(u32 reg){
f90001ac:	ff010113          	addi	sp,sp,-16
f90001b0:	00112623          	sw	ra,12(sp)
f90001b4:	00812423          	sw	s0,8(sp)
f90001b8:	00050413          	mv	s0,a0
        while(spi_cmdAvailability(reg) == 0);
f90001bc:	00040513          	mv	a0,s0
f90001c0:	f91ff0ef          	jal	f9000150 <spi_cmdAvailability>
f90001c4:	fe050ce3          	beqz	a0,f90001bc <spi_read+0x10>
f90001c8:	20000793          	li	a5,512
f90001cc:	00f42023          	sw	a5,0(s0)
        write_u32(SPI_CMD_READ, reg + SPI_DATA);
        while(spi_rspOccupancy(reg) == 0);
f90001d0:	00040513          	mv	a0,s0
f90001d4:	f8dff0ef          	jal	f9000160 <spi_rspOccupancy>
f90001d8:	fe050ce3          	beqz	a0,f90001d0 <spi_read+0x24>
        return *((volatile u32*) address);
f90001dc:	00042503          	lw	a0,0(s0)
        return read_u32(reg + SPI_DATA);
    }
f90001e0:	0ff57513          	zext.b	a0,a0
f90001e4:	00c12083          	lw	ra,12(sp)
f90001e8:	00812403          	lw	s0,8(sp)
f90001ec:	01010113          	addi	sp,sp,16
f90001f0:	00008067          	ret

f90001f4 <spi_select>:
 *
 * @param reg The base address of the SPI register
 * @param slaveId The ID of the slave device to select
 *
 ******************************************************************************/
    static void spi_select(u32 reg, u32 slaveId){
f90001f4:	ff010113          	addi	sp,sp,-16
f90001f8:	00112623          	sw	ra,12(sp)
f90001fc:	00812423          	sw	s0,8(sp)
f9000200:	00912223          	sw	s1,4(sp)
f9000204:	00050413          	mv	s0,a0
f9000208:	00058493          	mv	s1,a1
        while(spi_cmdAvailability(reg) == 0);
f900020c:	00040513          	mv	a0,s0
f9000210:	f41ff0ef          	jal	f9000150 <spi_cmdAvailability>
f9000214:	fe050ce3          	beqz	a0,f900020c <spi_select+0x18>
        write_u32(slaveId | 0x80 | SPI_CMD_SS, reg + SPI_DATA);
f9000218:	000017b7          	lui	a5,0x1
f900021c:	88078793          	addi	a5,a5,-1920 # 880 <__stack_size+0x780>
f9000220:	00f4e4b3          	or	s1,s1,a5
        *((volatile u32*) address) = data;
f9000224:	00942023          	sw	s1,0(s0)
    }
f9000228:	00c12083          	lw	ra,12(sp)
f900022c:	00812403          	lw	s0,8(sp)
f9000230:	00412483          	lw	s1,4(sp)
f9000234:	01010113          	addi	sp,sp,16
f9000238:	00008067          	ret

f900023c <spi_diselect>:
 *
 * @param reg The base address of the SPI register
 * @param slaveId The ID of the slave device to deselect
 *
 ******************************************************************************/  
    static void spi_diselect(u32 reg, u32 slaveId){
f900023c:	ff010113          	addi	sp,sp,-16
f9000240:	00112623          	sw	ra,12(sp)
f9000244:	00812423          	sw	s0,8(sp)
f9000248:	00912223          	sw	s1,4(sp)
f900024c:	00050413          	mv	s0,a0
f9000250:	00058493          	mv	s1,a1
        while(spi_cmdAvailability(reg) == 0);
f9000254:	00040513          	mv	a0,s0
f9000258:	ef9ff0ef          	jal	f9000150 <spi_cmdAvailability>
f900025c:	fe050ce3          	beqz	a0,f9000254 <spi_diselect+0x18>
        write_u32(slaveId | 0x00 | SPI_CMD_SS, reg + SPI_DATA);
f9000260:	000017b7          	lui	a5,0x1
f9000264:	80078793          	addi	a5,a5,-2048 # 800 <__stack_size+0x700>
f9000268:	00f4e4b3          	or	s1,s1,a5
f900026c:	00942023          	sw	s1,0(s0)
    }
f9000270:	00c12083          	lw	ra,12(sp)
f9000274:	00812403          	lw	s0,8(sp)
f9000278:	00412483          	lw	s1,4(sp)
f900027c:	01010113          	addi	sp,sp,16
f9000280:	00008067          	ret

f9000284 <spi_applyConfig>:
 * @param reg The base address of the SPI register
 * @param config Pointer to a Spi_Config structure containing the configuration settings
 *
 ******************************************************************************/
    static void spi_applyConfig(u32 reg, Spi_Config *config){
        write_u32((config->cpol << 0) | (config->cpha << 1) | (config->mode << 4), reg + SPI_CONFIG);
f9000284:	0005a783          	lw	a5,0(a1)
f9000288:	0045a703          	lw	a4,4(a1)
f900028c:	00171713          	slli	a4,a4,0x1
f9000290:	00e7e7b3          	or	a5,a5,a4
f9000294:	0085a703          	lw	a4,8(a1)
f9000298:	00471713          	slli	a4,a4,0x4
f900029c:	00e7e7b3          	or	a5,a5,a4
f90002a0:	00f52423          	sw	a5,8(a0)
        write_u32(config->clkDivider, reg + SPI_CLK_DIVIDER);
f90002a4:	00c5a783          	lw	a5,12(a1)
f90002a8:	02f52023          	sw	a5,32(a0)
        write_u32(config->ssSetup, reg + SPI_SS_SETUP);
f90002ac:	0105a783          	lw	a5,16(a1)
f90002b0:	02f52223          	sw	a5,36(a0)
        write_u32(config->ssHold, reg + SPI_SS_HOLD);
f90002b4:	0145a783          	lw	a5,20(a1)
f90002b8:	02f52423          	sw	a5,40(a0)
        write_u32(config->ssDisable, reg + SPI_SS_DISABLE);
f90002bc:	0185a783          	lw	a5,24(a1)
f90002c0:	02f52623          	sw	a5,44(a0)
    }
f90002c4:	00008067          	ret

f90002c8 <spi_waitXferBusy>:
* @brief This function wait for SPI Transfer to complete.
    * 
    * @param reg SPI base address 
*
******************************************************************************/
    static void spi_waitXferBusy(u32 reg){
f90002c8:	ff010113          	addi	sp,sp,-16
f90002cc:	00112623          	sw	ra,12(sp)
f90002d0:	00812423          	sw	s0,8(sp)
f90002d4:	00050413          	mv	s0,a0

#ifdef SYSTEM_SPI_2_IO_CTRL
    	if(reg == SYSTEM_SPI_2_IO_CTRL) cmdFifo_depth = SYSTEM_SPI_2_IO_PARAMETER_CMD_FIFO_DEPTH;
#endif

    	bsp_uDelay(1);
f90002d8:	f8b00637          	lui	a2,0xf8b00
f90002dc:	02faf5b7          	lui	a1,0x2faf
f90002e0:	08058593          	addi	a1,a1,128 # 2faf080 <__stack_size+0x2faef80>
f90002e4:	00100513          	li	a0,1
f90002e8:	dfdff0ef          	jal	f90000e4 <clint_uDelay>
    	while(spi_cmdAvailability(reg) != cmdFifo_depth);
f90002ec:	00040513          	mv	a0,s0
f90002f0:	e61ff0ef          	jal	f9000150 <spi_cmdAvailability>
f90002f4:	10000793          	li	a5,256
f90002f8:	fef51ae3          	bne	a0,a5,f90002ec <spi_waitXferBusy+0x24>
    }
f90002fc:	00c12083          	lw	ra,12(sp)
f9000300:	00812403          	lw	s0,8(sp)
f9000304:	01010113          	addi	sp,sp,16
f9000308:	00008067          	ret

f900030c <spiFlash_select>:
    * @param spi SPI port base address 
    * @param cs 32-bit bitwise setting. Set 1 to enable particular bit. 
*
******************************************************************************/

    static void spiFlash_select(u32 spi, u32 cs){
f900030c:	ff010113          	addi	sp,sp,-16
f9000310:	00112623          	sw	ra,12(sp)
        spi_select(spi, cs);
f9000314:	ee1ff0ef          	jal	f90001f4 <spi_select>
    }
f9000318:	00c12083          	lw	ra,12(sp)
f900031c:	01010113          	addi	sp,sp,16
f9000320:	00008067          	ret

f9000324 <spiFlash_diselect>:
    * 
    * @param spi SPI port base address 
    * @param cs 32-bit bitwise setting. Set 1 to disable particular bit. 
*
******************************************************************************/
    static void spiFlash_diselect(u32 spi, u32 cs){
f9000324:	ff010113          	addi	sp,sp,-16
f9000328:	00112623          	sw	ra,12(sp)
        spi_diselect(spi, cs);
f900032c:	f11ff0ef          	jal	f900023c <spi_diselect>
    }
f9000330:	00c12083          	lw	ra,12(sp)
f9000334:	01010113          	addi	sp,sp,16
f9000338:	00008067          	ret

f900033c <spiFlash_init_>:
* @brief This function initialize SPI port with default settings
    * 
    * @param spi SPI port base address
*
******************************************************************************/
    static void spiFlash_init_(u32 spi){
f900033c:	fd010113          	addi	sp,sp,-48
f9000340:	02112623          	sw	ra,44(sp)
f9000344:	02812423          	sw	s0,40(sp)
f9000348:	00050413          	mv	s0,a0
        Spi_Config spiCfg;
        spiCfg.cpol = 0;
f900034c:	00012223          	sw	zero,4(sp)
        spiCfg.cpha = 0;
f9000350:	00012423          	sw	zero,8(sp)
        spiCfg.mode = 0;
f9000354:	00012623          	sw	zero,12(sp)
        spiCfg.clkDivider = 2;
f9000358:	00200793          	li	a5,2
f900035c:	00f12823          	sw	a5,16(sp)
        spiCfg.ssSetup = 5;
f9000360:	00500713          	li	a4,5
f9000364:	00e12a23          	sw	a4,20(sp)
        spiCfg.ssHold = 2;
f9000368:	00f12c23          	sw	a5,24(sp)
        spiCfg.ssDisable = 7;
f900036c:	00700793          	li	a5,7
f9000370:	00f12e23          	sw	a5,28(sp)
        spi_applyConfig(spi, &spiCfg);
f9000374:	00410593          	addi	a1,sp,4
f9000378:	f0dff0ef          	jal	f9000284 <spi_applyConfig>
        spi_waitXferBusy(spi); 
f900037c:	00040513          	mv	a0,s0
f9000380:	f49ff0ef          	jal	f90002c8 <spi_waitXferBusy>
    }
f9000384:	02c12083          	lw	ra,44(sp)
f9000388:	02812403          	lw	s0,40(sp)
f900038c:	03010113          	addi	sp,sp,48
f9000390:	00008067          	ret

f9000394 <spiFlash_init>:
    * @param spi SPI port base address
    * @param gpio GPIO port base address 
    * @param cs 32-bit bitwise chip select setting.
*
******************************************************************************/
    static void spiFlash_init(u32 spi, u32 cs){
f9000394:	ff010113          	addi	sp,sp,-16
f9000398:	00112623          	sw	ra,12(sp)
f900039c:	00812423          	sw	s0,8(sp)
f90003a0:	00912223          	sw	s1,4(sp)
f90003a4:	00050413          	mv	s0,a0
f90003a8:	00058493          	mv	s1,a1
        spiFlash_init_(spi);
f90003ac:	f91ff0ef          	jal	f900033c <spiFlash_init_>
        spiFlash_diselect(spi, cs);
f90003b0:	00048593          	mv	a1,s1
f90003b4:	00040513          	mv	a0,s0
f90003b8:	f6dff0ef          	jal	f9000324 <spiFlash_diselect>
    }
f90003bc:	00c12083          	lw	ra,12(sp)
f90003c0:	00812403          	lw	s0,8(sp)
f90003c4:	00412483          	lw	s1,4(sp)
f90003c8:	01010113          	addi	sp,sp,16
f90003cc:	00008067          	ret

f90003d0 <spiFlash_manufacturer_id_>:
    *
    * @param spi SPI port base address
    * @param cs 32-bit bitwise chip select setting.
*
******************************************************************************/
    static inline u8 spiFlash_manufacturer_id_(u32 spi, u32 cs){
f90003d0:	ff010113          	addi	sp,sp,-16
f90003d4:	00112623          	sw	ra,12(sp)
f90003d8:	00812423          	sw	s0,8(sp)
f90003dc:	00050413          	mv	s0,a0
#if defined(GD25_FLASH)
        spi_write(spi, 0x9E);
#else
        spi_write(spi, READ_MANUFACTURER);
f90003e0:	09f00593          	li	a1,159
f90003e4:	d89ff0ef          	jal	f900016c <spi_write>
        // spi_write(spi, 0x00);
        // spi_write(spi, 0x00);
        // spi_write(spi, 0x00);
#endif
        u8 mid = spi_read(spi);
f90003e8:	00040513          	mv	a0,s0
f90003ec:	dc1ff0ef          	jal	f90001ac <spi_read>
f90003f0:	00050413          	mv	s0,a0
        bsp_uDelay(300);
f90003f4:	f8b00637          	lui	a2,0xf8b00
f90003f8:	02faf5b7          	lui	a1,0x2faf
f90003fc:	08058593          	addi	a1,a1,128 # 2faf080 <__stack_size+0x2faef80>
f9000400:	12c00513          	li	a0,300
f9000404:	ce1ff0ef          	jal	f90000e4 <clint_uDelay>
        return mid;
    }
f9000408:	00040513          	mv	a0,s0
f900040c:	00c12083          	lw	ra,12(sp)
f9000410:	00812403          	lw	s0,8(sp)
f9000414:	01010113          	addi	sp,sp,16
f9000418:	00008067          	ret

f900041c <spiFlash_wake_>:
*        start communicating with the device.
    * 
    * @param spi SPI port base address
*
******************************************************************************/
    static void spiFlash_wake_(u32 spi){
f900041c:	ff010113          	addi	sp,sp,-16
f9000420:	00112623          	sw	ra,12(sp)
        spi_write(spi, 0xAB);        
f9000424:	0ab00593          	li	a1,171
f9000428:	d45ff0ef          	jal	f900016c <spi_write>
    }
f900042c:	00c12083          	lw	ra,12(sp)
f9000430:	01010113          	addi	sp,sp,16
f9000434:	00008067          	ret

f9000438 <spiFlash_exit4ByteAddr_>:
    * @param spi SPI port base address
    * @param cs 32-bit bitwise chip select setting
    * @param mid 8-bit SPI Flash Manufacturer ID.
*
******************************************************************************/
    static void spiFlash_exit4ByteAddr_(u32 spi, u32 cs, u8 mid){
f9000438:	ff010113          	addi	sp,sp,-16
f900043c:	00112623          	sw	ra,12(sp)
        switch(mid){
f9000440:	09d00793          	li	a5,157
f9000444:	00f60c63          	beq	a2,a5,f900045c <spiFlash_exit4ByteAddr_+0x24>
            case 0x9D: 
                spi_write(spi, 0x29);
                break; 
            default: 
                spi_write(spi, 0xE9);
f9000448:	0e900593          	li	a1,233
f900044c:	d21ff0ef          	jal	f900016c <spi_write>
                break; 
        }
    }
f9000450:	00c12083          	lw	ra,12(sp)
f9000454:	01010113          	addi	sp,sp,16
f9000458:	00008067          	ret
                spi_write(spi, 0x29);
f900045c:	02900593          	li	a1,41
f9000460:	d0dff0ef          	jal	f900016c <spi_write>
                break; 
f9000464:	fedff06f          	j	f9000450 <spiFlash_exit4ByteAddr_+0x18>

f9000468 <spiFlash_exit4ByteAddr>:
*
* @param spi SPI port base address
* @param cs 32-bit bitwise chip select setting
*
******************************************************************************/
    static void spiFlash_exit4ByteAddr(u32 spi, u32 cs){
f9000468:	ff010113          	addi	sp,sp,-16
f900046c:	00112623          	sw	ra,12(sp)
f9000470:	00812423          	sw	s0,8(sp)
f9000474:	00912223          	sw	s1,4(sp)
f9000478:	01212023          	sw	s2,0(sp)
f900047c:	00050413          	mv	s0,a0
f9000480:	00058493          	mv	s1,a1
        spiFlash_select(spi,cs);
f9000484:	e89ff0ef          	jal	f900030c <spiFlash_select>
        u8 mid = spiFlash_manufacturer_id_(spi, cs); 
f9000488:	00048593          	mv	a1,s1
f900048c:	00040513          	mv	a0,s0
f9000490:	f41ff0ef          	jal	f90003d0 <spiFlash_manufacturer_id_>
f9000494:	00050913          	mv	s2,a0
        spiFlash_diselect(spi,cs);
f9000498:	00048593          	mv	a1,s1
f900049c:	00040513          	mv	a0,s0
f90004a0:	e85ff0ef          	jal	f9000324 <spiFlash_diselect>
        spi_waitXferBusy(spi);
f90004a4:	00040513          	mv	a0,s0
f90004a8:	e21ff0ef          	jal	f90002c8 <spi_waitXferBusy>
        spiFlash_select(spi,cs);
f90004ac:	00048593          	mv	a1,s1
f90004b0:	00040513          	mv	a0,s0
f90004b4:	e59ff0ef          	jal	f900030c <spiFlash_select>
        spiFlash_exit4ByteAddr_(spi, cs, mid); 
f90004b8:	00090613          	mv	a2,s2
f90004bc:	00048593          	mv	a1,s1
f90004c0:	00040513          	mv	a0,s0
f90004c4:	f75ff0ef          	jal	f9000438 <spiFlash_exit4ByteAddr_>
        spiFlash_diselect(spi,cs);
f90004c8:	00048593          	mv	a1,s1
f90004cc:	00040513          	mv	a0,s0
f90004d0:	e55ff0ef          	jal	f9000324 <spiFlash_diselect>
        spi_waitXferBusy(spi);
f90004d4:	00040513          	mv	a0,s0
f90004d8:	df1ff0ef          	jal	f90002c8 <spi_waitXferBusy>
    }
f90004dc:	00c12083          	lw	ra,12(sp)
f90004e0:	00812403          	lw	s0,8(sp)
f90004e4:	00412483          	lw	s1,4(sp)
f90004e8:	00012903          	lw	s2,0(sp)
f90004ec:	01010113          	addi	sp,sp,16
f90004f0:	00008067          	ret

f90004f4 <spiFlash_wake>:
*
* @param spi SPI port base address
* @param cs 32-bit bitwise chip select setting.
*
******************************************************************************/
    static void spiFlash_wake(u32 spi, u32 cs){
f90004f4:	ff010113          	addi	sp,sp,-16
f90004f8:	00112623          	sw	ra,12(sp)
f90004fc:	00812423          	sw	s0,8(sp)
f9000500:	00912223          	sw	s1,4(sp)
f9000504:	00050413          	mv	s0,a0
f9000508:	00058493          	mv	s1,a1
        spiFlash_select(spi,cs);
f900050c:	e01ff0ef          	jal	f900030c <spiFlash_select>
        spiFlash_wake_(spi);
f9000510:	00040513          	mv	a0,s0
f9000514:	f09ff0ef          	jal	f900041c <spiFlash_wake_>
        spiFlash_diselect(spi,cs);
f9000518:	00048593          	mv	a1,s1
f900051c:	00040513          	mv	a0,s0
f9000520:	e05ff0ef          	jal	f9000324 <spiFlash_diselect>
        spi_waitXferBusy(spi);
f9000524:	00040513          	mv	a0,s0
f9000528:	da1ff0ef          	jal	f90002c8 <spi_waitXferBusy>
        bsp_uDelay(100); // make sure the Flash fully awake
f900052c:	f8b00637          	lui	a2,0xf8b00
f9000530:	02faf5b7          	lui	a1,0x2faf
f9000534:	08058593          	addi	a1,a1,128 # 2faf080 <__stack_size+0x2faef80>
f9000538:	06400513          	li	a0,100
f900053c:	ba9ff0ef          	jal	f90000e4 <clint_uDelay>
    }
f9000540:	00c12083          	lw	ra,12(sp)
f9000544:	00812403          	lw	s0,8(sp)
f9000548:	00412483          	lw	s1,4(sp)
f900054c:	01010113          	addi	sp,sp,16
f9000550:	00008067          	ret

f9000554 <spiFlash_f2m_>:
    * @param flashAddress The flash address to read the data
    * @param memoryAddress The RAM address to write the data
    * @param size The size of data to copy
*
******************************************************************************/
    static void spiFlash_f2m_(u32 spi, u32 flashAddress, u32 memoryAddress, u32 size){
f9000554:	fe010113          	addi	sp,sp,-32
f9000558:	00112e23          	sw	ra,28(sp)
f900055c:	00812c23          	sw	s0,24(sp)
f9000560:	00912a23          	sw	s1,20(sp)
f9000564:	01212823          	sw	s2,16(sp)
f9000568:	01312623          	sw	s3,12(sp)
f900056c:	00050913          	mv	s2,a0
f9000570:	00058493          	mv	s1,a1
f9000574:	00060413          	mv	s0,a2
f9000578:	00068993          	mv	s3,a3
        spi_write(spi, 0x0B);
f900057c:	00b00593          	li	a1,11
f9000580:	bedff0ef          	jal	f900016c <spi_write>
        spi_write(spi, flashAddress >> 16);
f9000584:	0104d593          	srli	a1,s1,0x10
f9000588:	0ff5f593          	zext.b	a1,a1
f900058c:	00090513          	mv	a0,s2
f9000590:	bddff0ef          	jal	f900016c <spi_write>
        spi_write(spi, flashAddress >>  8);
f9000594:	0084d593          	srli	a1,s1,0x8
f9000598:	0ff5f593          	zext.b	a1,a1
f900059c:	00090513          	mv	a0,s2
f90005a0:	bcdff0ef          	jal	f900016c <spi_write>
        spi_write(spi, flashAddress >>  0);
f90005a4:	0ff4f593          	zext.b	a1,s1
f90005a8:	00090513          	mv	a0,s2
f90005ac:	bc1ff0ef          	jal	f900016c <spi_write>
        spi_write(spi, 0);
f90005b0:	00000593          	li	a1,0
f90005b4:	00090513          	mv	a0,s2
f90005b8:	bb5ff0ef          	jal	f900016c <spi_write>
        uint8_t *ram = (uint8_t *) memoryAddress;
        for(u32 idx = 0;idx < size;idx++){
f90005bc:	00000493          	li	s1,0
f90005c0:	0180006f          	j	f90005d8 <spiFlash_f2m_+0x84>
            u8 value = spi_read(spi);
f90005c4:	00090513          	mv	a0,s2
f90005c8:	be5ff0ef          	jal	f90001ac <spi_read>
            *ram++ = value;
f90005cc:	00a40023          	sb	a0,0(s0)
        for(u32 idx = 0;idx < size;idx++){
f90005d0:	00148493          	addi	s1,s1,1
            *ram++ = value;
f90005d4:	00140413          	addi	s0,s0,1
        for(u32 idx = 0;idx < size;idx++){
f90005d8:	ff34e6e3          	bltu	s1,s3,f90005c4 <spiFlash_f2m_+0x70>
        }
    }
f90005dc:	01c12083          	lw	ra,28(sp)
f90005e0:	01812403          	lw	s0,24(sp)
f90005e4:	01412483          	lw	s1,20(sp)
f90005e8:	01012903          	lw	s2,16(sp)
f90005ec:	00c12983          	lw	s3,12(sp)
f90005f0:	02010113          	addi	sp,sp,32
f90005f4:	00008067          	ret

f90005f8 <spiFlash_f2m>:
* @param flashAddress The flash address to read the data
* @param memoryAddress The RAM address to write the data
* @param size The size of data to copy
*
******************************************************************************/
    static void spiFlash_f2m(u32 spi, u32 cs, u32 flashAddress, u32 memoryAddress, u32 size){
f90005f8:	fe010113          	addi	sp,sp,-32
f90005fc:	00112e23          	sw	ra,28(sp)
f9000600:	00812c23          	sw	s0,24(sp)
f9000604:	00912a23          	sw	s1,20(sp)
f9000608:	01212823          	sw	s2,16(sp)
f900060c:	01312623          	sw	s3,12(sp)
f9000610:	01412423          	sw	s4,8(sp)
f9000614:	00050413          	mv	s0,a0
f9000618:	00058493          	mv	s1,a1
f900061c:	00060913          	mv	s2,a2
f9000620:	00068993          	mv	s3,a3
f9000624:	00070a13          	mv	s4,a4
        spiFlash_select(spi,cs);
f9000628:	ce5ff0ef          	jal	f900030c <spiFlash_select>
        spiFlash_f2m_(spi, flashAddress, memoryAddress, size);
f900062c:	000a0693          	mv	a3,s4
f9000630:	00098613          	mv	a2,s3
f9000634:	00090593          	mv	a1,s2
f9000638:	00040513          	mv	a0,s0
f900063c:	f19ff0ef          	jal	f9000554 <spiFlash_f2m_>
        spiFlash_diselect(spi,cs);
f9000640:	00048593          	mv	a1,s1
f9000644:	00040513          	mv	a0,s0
f9000648:	cddff0ef          	jal	f9000324 <spiFlash_diselect>
    }
f900064c:	01c12083          	lw	ra,28(sp)
f9000650:	01812403          	lw	s0,24(sp)
f9000654:	01412483          	lw	s1,20(sp)
f9000658:	01012903          	lw	s2,16(sp)
f900065c:	00c12983          	lw	s3,12(sp)
f9000660:	00812a03          	lw	s4,8(sp)
f9000664:	02010113          	addi	sp,sp,32
f9000668:	00008067          	ret

f900066c <bspMain>:
#define USER_SOFTWARE_FLASH  0x00380000
#define USER_SOFTWARE_SIZE	   0x01F000

#define SINGLE_SPI 1 //define DUAL_SPI for dual data SPI or QUAD_SPI for quad data SPI

void bspMain() {
f900066c:	ff010113          	addi	sp,sp,-16
f9000670:	00112623          	sw	ra,12(sp)
#ifndef SIM
	spiFlash_init(SPI, SPI_CS);
f9000674:	00000593          	li	a1,0
f9000678:	f8006537          	lui	a0,0xf8006
f900067c:	d19ff0ef          	jal	f9000394 <spiFlash_init>
	spiFlash_wake(SPI, SPI_CS);
f9000680:	00000593          	li	a1,0
f9000684:	f8006537          	lui	a0,0xf8006
f9000688:	e6dff0ef          	jal	f90004f4 <spiFlash_wake>
	spiFlash_exit4ByteAddr(SPI, SPI_CS);
f900068c:	00000593          	li	a1,0
f9000690:	f8006537          	lui	a0,0xf8006
f9000694:	dd5ff0ef          	jal	f9000468 <spiFlash_exit4ByteAddr>
#ifdef SINGLE_SPI
	spiFlash_f2m(SPI, SPI_CS, USER_SOFTWARE_FLASH, USER_SOFTWARE_MEMORY, USER_SOFTWARE_SIZE);
f9000698:	0001f737          	lui	a4,0x1f
f900069c:	000016b7          	lui	a3,0x1
f90006a0:	00380637          	lui	a2,0x380
f90006a4:	00000593          	li	a1,0
f90006a8:	f8006537          	lui	a0,0xf8006
f90006ac:	f4dff0ef          	jal	f90005f8 <spiFlash_f2m>
#endif
#endif

	void (*userMain)() = (void (*)())USER_SOFTWARE_MEMORY;
    #ifdef SMP
        smp_unlock(userMain);
f90006b0:	00001537          	lui	a0,0x1
f90006b4:	985ff0ef          	jal	f9000038 <smp_unlock>
    #endif
	userMain();
f90006b8:	000017b7          	lui	a5,0x1
f90006bc:	000780e7          	jalr	a5 # 1000 <__stack_size+0xf00>
}
f90006c0:	00c12083          	lw	ra,12(sp)
f90006c4:	01010113          	addi	sp,sp,16
f90006c8:	00008067          	ret

f90006cc <main>:
******************************************************************************/
#include "type.h"
#include "bsp.h"
#include "bootloaderConfig.h"

void main() {
f90006cc:	ff010113          	addi	sp,sp,-16
f90006d0:	00112623          	sw	ra,12(sp)
    bsp_init();
f90006d4:	a45ff0ef          	jal	f9000118 <bsp_init>
    bspMain();
f90006d8:	f95ff0ef          	jal	f900066c <bspMain>
}
f90006dc:	00c12083          	lw	ra,12(sp)
f90006e0:	01010113          	addi	sp,sp,16
f90006e4:	00008067          	ret

f90006e8 <__libc_init_array>:
f90006e8:	ff010113          	addi	sp,sp,-16
f90006ec:	00812423          	sw	s0,8(sp)
f90006f0:	01212023          	sw	s2,0(sp)
f90006f4:	00000797          	auipc	a5,0x0
f90006f8:	08878793          	addi	a5,a5,136 # f900077c <_data>
f90006fc:	00000417          	auipc	s0,0x0
f9000700:	08040413          	addi	s0,s0,128 # f900077c <_data>
f9000704:	00112623          	sw	ra,12(sp)
f9000708:	00912223          	sw	s1,4(sp)
f900070c:	40878933          	sub	s2,a5,s0
f9000710:	02878063          	beq	a5,s0,f9000730 <__libc_init_array+0x48>
f9000714:	40295913          	srai	s2,s2,0x2
f9000718:	00000493          	li	s1,0
f900071c:	00042783          	lw	a5,0(s0)
f9000720:	00148493          	addi	s1,s1,1
f9000724:	00440413          	addi	s0,s0,4
f9000728:	000780e7          	jalr	a5
f900072c:	ff24e8e3          	bltu	s1,s2,f900071c <__libc_init_array+0x34>
f9000730:	00000797          	auipc	a5,0x0
f9000734:	04c78793          	addi	a5,a5,76 # f900077c <_data>
f9000738:	00000417          	auipc	s0,0x0
f900073c:	04440413          	addi	s0,s0,68 # f900077c <_data>
f9000740:	40878933          	sub	s2,a5,s0
f9000744:	40295913          	srai	s2,s2,0x2
f9000748:	00878e63          	beq	a5,s0,f9000764 <__libc_init_array+0x7c>
f900074c:	00000493          	li	s1,0
f9000750:	00042783          	lw	a5,0(s0)
f9000754:	00148493          	addi	s1,s1,1
f9000758:	00440413          	addi	s0,s0,4
f900075c:	000780e7          	jalr	a5
f9000760:	ff24e8e3          	bltu	s1,s2,f9000750 <__libc_init_array+0x68>
f9000764:	00c12083          	lw	ra,12(sp)
f9000768:	00812403          	lw	s0,8(sp)
f900076c:	00412483          	lw	s1,4(sp)
f9000770:	00012903          	lw	s2,0(sp)
f9000774:	01010113          	addi	sp,sp,16
f9000778:	00008067          	ret
