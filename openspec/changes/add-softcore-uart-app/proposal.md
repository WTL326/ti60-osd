# Proposal

## Why

本工程有 RTL 侧完整的视频管线，但软核侧**没有面向本工程的产品固件**——`embedded_sw/riscv/software/standalone/` 下只有 BSP 自带的 `coremark`/`dhrystone`/`memTest` 三个 demo。`docs/SOFTCORE_DESIGN.md` 描述了软核应承担的职责（UART 命令解析、控制寄存器写入、掩膜上传、返回 ACK），但对应固件源码与 `ivlabIspSoftCore.hex` **均不在本仓库**，所以该文档描述的协议行为至今无法验证。

同时软核的调试观测条件受现场限制：没有可用的硬件串口适配器，`system_uart_0_io` 的引脚接不出来，因此调试输出只能沿用 BSP 的 semihosting 通路（`ENABLE_SEMIHOSTING_PRINT=1`，`bsp.h:98`）经 JTAG 打印。这带出一个新约束：semihosting 每写一个字符都要等主机响应（`semihosting.h:88-108` 的 `ebreak` 魔法序列），期间 CPU 停滞，**uart1 的 RX 中断也不会被服务**；而 uart1 的 RX FIFO 只有 128 字节深（`soc.h:36`），必须继续正确处理协议。标准 newlib `printf` 不经此通路（`common/syscalls.c:45-49` 的 `_write` 丢弃输出），调试统一使用 `bsp_printf`。

因此需要先落一个**可构建、可验证的软核应用骨架**：uart1 上做协议端点（解析 X2000 命令并回 ACK），并让调试输出经 semihosting/JTAG 与协议端点互不干扰。业务命令的实现与掩膜上传留待后续变更。

## What Changes

- 新增软核应用工程 `embedded_sw/riscv/software/standalone/application/ivlabSoftCore/`，沿用现有工程的构建骨架（`makefile` 三段 include、`common/start.S`、`BSP_PATH/linker/default.ld`），产物为 `.elf/.hex/.bin/.asm/.map`。
- **uart1 协议端点**：实现与上位机文档一致的 `0xBB` 协议帧收发——帧头 `0xBB`、`body_length`(2B)、body `{大类, 子项, 类型, payload}`、CRC-16/CCITT（多项式 `0x1021`，仅覆盖 body）、帧尾 `0xAA`。协议格式依据 `docs/测试说明.md` 的「指令构成」，与 `docs/adb_test_commands.md`、`docs/x2000_ui_protocol.md` 及 `tools/send_*_via_adb.py` 三方一致。
- **大类归属**：同一根串口线上并存所有功能模块的帧（`0x00` 掩膜／`0x01` 电子变倍／`0x02` 热点／`0x03` 伪彩色／`0x04` UI）。**只有掩膜大类由本端点处理并应答**；其它大类只解析、不应答、不计入坏包——回一个"大类 0x00"的应答会让对应模块的上位机工具报"ACK 格式错误"。
- **ACK 应答**：对每个属于掩膜大类、且完整性通过的帧回应 10 字节 `BB 00 04 <大类> <子项> 02 <status> <crc_hi> <crc_lo> AA`；`status` 为二值，**`0xFF` = 成功、`0x00` = 失败**。CRC 或帧尾错误的帧**不应答**（字节不可信，无从判断归属，贸然回应可能撞进别的模块的通信）。
- **掩膜子项分发表（框架）**：识别子项 `0x01` 开始上传、`0x02` 分块写入、`0x03` 设置位置、`0x04` 开关、`0x05` 保存 Flash，但本次**全部返回失败**（`status = 0x00`），并在调试日志中记录子项号、名称与失败原因。业务实现（含 HyperRAM 写入与 Flash 持久化）不在本次范围。
- **调试输出通道**：保持 BSP 默认的 `ENABLE_SEMIHOSTING_PRINT=1`，调试输出经 semihosting/JTAG（`bsp_printf`）而非 uart0 硬件；uart0 仍由 `bsp_init()` 初始化但不承载输出。标准 newlib `printf` 不在调试通道内（`_write` 保持 BSP 现状），调试统一使用 `bsp_printf`。
- **调试通道与协议端点解耦**：协议端点的收发 MUST 直接操作 uart1 寄存器，不经过 `bsp_putChar`/`_putchar`/`bsp_printf`，使 semihosting 开关的任何变化都无法影响协议行为。
- 协议端点采用**中断驱动接收 + 阻塞发送**，波特率 115200 8N1。

## Capabilities

### New Capabilities

- `softcore-uart-protocol`: 软核在 uart1 上对 X2000 提供命令通道的行为契约——帧格式与同步规则、CRC 校验、ACK 应答格式与状态码语义、命令分发与未实现命令的失败应答、接收缓冲，以及协议路径对调试通道配置的独立性。
- `softcore-debug-console`: 软核调试输出通道的契约——经 semihosting/JTAG 的输出路径、输出与协议通道的隔离、以及调试停滞（semihosting 写字符时 CPU 停摆）下的输出分段与协议恢复行为。

### Modified Capabilities

无。项目当前 `openspec/specs/` 为空（尚无任何已建立的 capability），本次不修改既有 spec 级需求。

## Impact

**新增代码**
- `embedded_sw/riscv/software/standalone/application/ivlabSoftCore/`（`makefile` + `src/`），工程命名对齐 `docs/SOFTCORE_DESIGN.md:25` 的固件名 `ivlabIspSoftCore`。

**依赖的现有资产（复用，不新建）**
- 构建骨架：`common/bsp.mk`、`common/riscv64-unknown-elf.mk`、`common/standalone.mk`、`common/start.S`、`common/trap.S`、`common/syscalls.c`
- 驱动：`driver/uart.h`（`uart_read`/`uart_write`/`uart_applyConfig`/`uart_RX_NotemptyInterruptEna` 等）、`driver/plic.h`（`plic_claim`/`plic_release`/`plic_set_enable`/`plic_set_priority`/`plic_set_threshold`）、`driver/io.h`（`read_u32`/`write_u32`）、`driver/riscv.h`（CSR 宏）
- 中断注册范式参考：`standalone/uart/uartInterruptDemo/src/main.c:130-152`
- BSP 头文件 `bsp/efinix/EfxSapphireSoc/include/`（`soc.h`、`bsp.h`、`print.h`）

**仓库外前置依赖（本次只定义契约，不实施）**
- `ip/riscv/settings.json:113` 的 `UART1` 由 `1'b0` 改为 `1'b1`，并重新生成 Sapphire IP，使其暴露 `system_uart_1_io`。生成的 `soc.h` 应新增 `SYSTEM_UART_1_IO_CTRL`（APB 基址 `0xF8002000`）与 `SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT`（`2`）。
- `src/top.v` 引脚重接：uart1 接 X2000 协议线（现由 `system_uart_0_io` 承担的 `UART_ST_FR`/`UART_SR_FT` 路径）。uart0 的引脚是否保留由后续决定——调试输出现走 JTAG，uart0 硬件不再承载输出。**本次不修改 `ip/`、`src/` 与约束文件。**
- 在依赖落地前，本应用**无法在本仓库内构建验证**（`soc.h` 中不存在 UART1 符号）。

**已知风险与不一致**
- **semihosting 停滞会波及 uart1 接收**：`call_host`（`semihosting.h:88-108`）发出 `ebreak` 魔法序列后 CPU 等待主机响应，期间 uart1 的 RX 中断不被服务；RX FIFO 仅 128 字节深，115200 下约 11 ms 即填满。单次停滞时长取决于主机响应，软件侧无法给出上界，因此**零丢帧不可保证**。本次的应对是：ISR 内绝不打印、日志经队列在主循环分段送出（每段之间先排空 RX）、正常协议路径不产生日志，并把 spec 的契约定义为"能从字节流缺口重同步"而非"零丢失"。上层需容忍偶发 NAK/重试。
- **RTL 端点与上位机工具不兼容（上一代协议）**：`src/control/RtlMaskUartAxiWriter.v` 用的是旧一代报文约定——大类字节固定 `0x06`、子项打包成 `0x86`–`0x89`；而上位机工具发的是大类 `0x00`、子项 `0x01`–`0x05`。**两者互不兼容**，这一点在旧检出里同样成立（其 RTL 与本仓库一致，工具却是新的）。当前位流 `rtl_mask_mode = 1'b0` 已把 RTL 端点关闭，运行中的应答方是软核；`src/top.v:496-498` 要求同一时刻只有一个 endpoint 应答，因此该位必须保持 `1'b0`，否则两个 endpoint 会同时解析同一个包并在 `top.v:1425` 的线与回线上撞车。
- `docs/SOFTCORE_DESIGN.md` 第 4 章描述的协议（魔数 `0x5AA5`、CRC-16/MODBUS、`0x00 = SUCCESS`）与运行中的 `0xBB` 协议是**第三套、也是不一致的**表述，且成功码语义相反（该文档 `0x00` 表示成功，运行协议 `0x00` 表示失败）。本变更是以 `docs/测试说明.md` + 上位机工具为准；`SOFTCORE_DESIGN.md` 的订正另行处理。
- `bsp/efinix/EfxSapphireSoc/include/soc.mk:10` 定义了 `-DSYSTEM_UART_A_APB=SYSTEM_UART_0_IO_APB`，但 `soc.h` 中并无 `SYSTEM_UART_0_IO_APB` 符号（Eclipse 工程用的是 `SYSTEM_UART_0_IO_CTRL`）。该 define 目前是死符号，需在实现阶段确认是否影响新工程。

**构建与验证**
- 构建：`cd embedded_sw/riscv/software/standalone/application/ivlabSoftCore && make BSP=efinix/EfxSapphireSoc`（`BSP` 未在任何 makefile 中赋值，必须命令行传入；且需含 `efinix/` 层以匹配 `bsp/efinix/EfxSapphireSoc` 的实际布局）。工具链与 make 在本机位于 `/h/Efinity/efinity-riscv-ide-2026.1/` 下的 `toolchain/bin` 与 `build_tools/bin`，构建前需加入 PATH。
- 工具链：`riscv-none-elf-`（`common/riscv64-unknown-elf.mk:1`），`rv32im_zicsr_zifencei`/`ilp32`。
- 调试输出需要 JTAG 调试器连接并支持 semihosting；无调试器时 `ebreak` 会走 `trap_entry`，应用需在 `trap()` 中容忍并返回（各 demo 的 `trap()` 均为自定义，本工程同样需要提供）。
- 本仓库无软核仿真环境，功能验证依赖上板或仓库外的 RISC-V 仿真。
