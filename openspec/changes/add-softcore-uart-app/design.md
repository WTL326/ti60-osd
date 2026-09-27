# Design

## Context

参见 `proposal.md` - Why。

影响本设计的技术现状（均已核对 RTL/BSP 源码）：

- **SoC 只有 1 个 UART 实例**：`ip/riscv/source/soc_config:29` 仅有一行 `--uart name=system_uart_0_io,address=0x001000,interruptId=1,fifoDepth=128`；`ip/riscv/settings.json:113` 中 `UART1: "1'b0"` 为禁用；生成的 `ip/riscv/riscv.v:154-156` 顶层只有 `system_uart_0_io_txd/rxd`。`soc.h:58-59` 给出 `SYSTEM_UART_0_IO_CTRL 0xf8001000`、irq `1`。UART1 启用后按生成器的地址表应对应为 APB `0xF8002000`、irq `2`（`settings.json:94,112`）。
- **uart0 是 BSP 的默认 terminal**：`bsp.h:29` `#define BSP_UART_TERMINAL SYSTEM_UART_0_IO_CTRL`；`bsp.h:30` `bsp_putChar(c)` 直接就是 `uart_write(BSP_UART_TERMINAL, c)`。`bsp_init()`（`bsp.h:139-147`）只配置这一个 UART。
- **调试输出只能走 semihosting**：`bsp.h:98` 无条件 `#define ENABLE_SEMIHOSTING_PRINT 1`，`print.h:24-30` 的 `_putchar()` 据此调用 `sh_writec`；`semihosting.h:88-108` 的 `call_host` 发出 `slli x0,x0,0x1f; ebreak; srai x0,x0,7` 序列，由调试器截获并服务——**每个字符一次主机往返，期间 CPU 停滞**。`bsp_putChar` 是宏 `uart_write(BSP_UART_TERMINAL, c)`（`bsp.h:30`），恒定指向 uart0，与 semihosting 开关无关。标准 newlib `printf` 不走此通路：`common/syscalls.c:45-49` 的 `_write` 直接 `return len` 丢弃输出，且 `standalone.mk:28` 无条件链接 `syscalls.o`。`trap.S` 的 `trap_entry` 调用用户自定义的 `trap()`，各 demo 在各自 `main.c` 中提供，BSP 无默认实现。
- **可复用的中断范式**：`standalone/uart/uartInterruptDemo/src/main.c:130-152` 给出完整的 PLIC 注册序列（`uart_RX_NotemptyInterruptEna` → `plic_set_threshold` → `plic_set_enable` → `plic_set_priority` → `csr_write(mtvec, trap_entry)` → `csr_set(mie, MIE_MEIE)`）；`driver/uart.h` 提供 `uart_read`/`uart_write`/`uart_writeAvailability`/`uart_readOccupancy`；`driver/plic.h` 提供 `plic_claim`/`plic_release`。
- **构建骨架**：`makefile` 三段 include（`bsp.mk`/`riscv64-unknown-elf.mk`/`standalone.mk`），`common/start.S` 提供 `_start`，`uartInterruptDemo` 还额外引入 `common/trap.S`。`BSP` 变量在任何 makefile 中都未赋值，必须命令行传入。链接脚本为 `${BSP_PATH}/linker/default.ld`（`ram ORIGIN = 0x00001000, LENGTH = 124K`，栈 4K）。
- **RTL 侧已有同一协议的端点**：`src/control/RtlMaskUartAxiWriter.v` 实现了完整的 `0xBB` 协议与 ACK 发送器；`src/top.v:496-498` 的注释要求同一时刻只有一个 endpoint 执行并应答。

## Goals / Non-Goals

**Goals:**

- 交付一个**在依赖落地前也能构建通过**的软核应用工程，使协议解析与调试输出两条通路的代码可以先行评审与单元验证。
- 协议行为与 RTL 端点**逐字节兼容**，使两个端点可在同一上位机协议下互换。
- 修正 RTL 端点已知的 ACK 丢失缺陷（见 Decisions 第 4 条），在软件侧不给同一问题留位置。
- 让 uart1 的协议正确性**与调试通道的配置和停滞无关**（见 Decisions 第 5、8 条）。

**Non-Goals:**

- 不实现任何业务命令；不写 HyperRAM 掩膜画布；不做固件 OTA。
- 不支持 `docs/SOFTCORE_DESIGN.md` 第 4 章的 `0x5AA5` 协议。
- 不修改 `ip/`、`src/`、约束文件与 `docs/`。
- 不在软件侧做 A/B 双缓冲或原子提交——那是 `MaskControlRegs` 的职责，且掩膜上传不在本次范围。

## Decisions

### 1. 采纳上位机文档那一代 `0xBB` 协议，RTL 端点是上一代

**选择**：按 `docs/测试说明.md` 的「指令构成」实现——帧头 `0xBB`／帧尾 `0xAA`、CRC-16/CCITT(`0x1021`) 只覆盖 body、body 为 `大类 | 子项 | 类型 | payload`、掩膜大类 `0x00`、子项 `0x01`–`0x05`、应答固定 10 字节、状态码二值 `0xFF`/`0x00`。该格式同时被 `docs/adb_test_commands.md`、`docs/x2000_ui_protocol.md` 与 `tools/send_*_via_adb.py` 三个工具印证。

**理由**：**这是运行中的契约**。上位机工具就是这么发报文的，而 `rtl_mask_mode = 1'b0` 已经把 RTL 端点关掉了——软核是正在应答的那一方。协议再"在仓库里可查"，对不上工具就是不能工作。

**这条决策经过一次纠正，过程值得记下来**：最初本决策选的是"按 RTL 实现"，理由写在下面（作为反例保留）。按 RTL 实现后上板实测，26 个掩膜包**全部被拒**，日志显示 `rx cmd=0x1 bad body header, nak`、`rx cmd=0x2 crc/footer bad, nak`……原因是两代协议不兼容：

| | 本实现（按 RTL，旧一代） | 上位机工具／文档（新一代） |
|---|---|---|
| `body[0]` | `0x06` 固定标记 | `0x00` = 掩膜**大类**（`0x01` 变倍／`0x02` 热点／`0x03` 伪彩／`0x04` UI） |
| `body[1]` | 大类与子项**打包**：`0x86`–`0x89` | 子项独立编号：`0x01`–`0x05` |
| 存 Flash | 无 | `0x05`（`body_length = 3`） |
| 状态码 | 只用 `0xFF`/`0x00` | 文档规定也是 `0xFF`/`0x00`（二值），一致 |

对应关系是 `0x01↔0x86`、`0x02↔0x87`、`0x03↔0x88`、`0x04↔0x89`、大类 `0x00↔0x06`。

**当时为什么会选错**：`tools/` 与上位机侧代码都不在本仓库（本仓库是部分检出），调研时只看到 RTL 那一代，就把"仓库内可查"当成了"权威"。这是把**可验证性**误当成了**权威性**——真正该问的是"运行中的对端说的是哪一套"。`docs/` 下的三份协议文档一直在仓库里，是调研时漏读的。

**备选（已排除）**：两代都支持、按大类字节自动判别——兼容性最好，但 spec 与测试面翻倍，而且旧一代的 `0x06` 标记与新一代的大类 `0x00`/`0x01`… 语义完全重叠，自动判别本身就是个易错的启发式；改上位机工具去迁就 RTL——方向错了，工具是运行中的接口，而且不在本仓库。

### 2. uart1 独占协议端点，uart0 保留初始化但不承载输出

**选择**：协议端点独占新增的 uart1。uart0（`SYSTEM_UART_0_IO_CTRL`）保持 BSP 的既有配置——`BSP_UART_TERMINAL` 不变、`bsp_init()` 照常初始化它——但由于 `ENABLE_SEMIHOSTING_PRINT=1`，打印栈走 `sh_writec` 而永不调用 `bsp_putChar`，因此 uart0 硬件在本变更中不产生任何输出。

**理由**：uart0 不改动就保留了"日后接上串口适配器即可启用"的能力，同时不引入 `BSP_UART_TERMINAL`/`bsp_init()` 的改动。协议端点放在**物理独立的 uart1** 上，是满足 `softcore-debug-console` 隔离要求最直接的方式——两者不共享任何寄存器或发送 FIFO，调试文本不可能混进 uart1 的字节流。

**备选**：反过来（uart0 接协议、uart1 做调试）——沿用现有接线风险更低，但与需求描述的分配相反，且需要把 `BSP_UART_TERMINAL` 指向新 UART 并同步改 `bsp_init()`；完全不启用 uart0——省掉一次初始化，但失去日后接串口的能力。

### 3. 接收采用 PLIC 中断 + 软件环形缓冲

**选择**：uart1 的 RX 用 `uart_RX_NotemptyInterruptEna` 开中断，ISR 只从 UART 数据寄存器搬字节进环形缓冲，帧解析在主循环中进行。

**理由**：RX FIFO 深度 128（`soc.h:36`），而 `0x87` 分片帧的 payload 可达数千字节，在 115200 下持续几十毫秒。轮询方案要么占满 CPU，要么在解析耗时超过 FIFO 深度时丢字节，而丢字节会让 CRC 失败——表现为难以定位的"偶发坏帧"。

**备选**：纯轮询（简单但上述缺陷）；DMA（Sapphire 配置中无可用 DMA 通道）。

### 4. 发送采用阻塞发送，且应答期间不丢弃任何完整帧

**选择**：ACK 用阻塞方式逐字节写入，写前等待 `uart_writeAvailability`，带有限超时。**接收解析在发送期间暂停**，即一个完整帧的处理是原子的：解析 → 执行 → 应答 → 恢复接收。

**理由**：ACK 固定 10 字节，115200 下约 868 µs，阻塞时间可接受，且天然满足 `softcore-uart-protocol` 的"每个完整帧恰好一个 ACK"要求，无需引入应答队列。这一条是**有意修正 RTL 端点的缺陷**：`RtlMaskUartAxiWriter.v:253` 每个周期清零 `ack_request`、只在 `P_FOOTER` 单拍置位，而 TX 只在 `!tx_busy` 时采样（`:476-478`），同时解析器在 `:418` 立刻回到 `P_HEADER` 收下一包——结果是上一 ACK 未发完时到达的包，其 ACK 被**静默丢弃**且无任何指示。

**备选**：中断发送 + ACK 队列（为 10 字节引入队列与并发状态，不值得）；照搬 RTL 的"发送与接收并行"（即引入同一缺陷）。

### 5. 调试输出保持 semihosting（JTAG），与协议端点在寄存器层面解耦

**选择**：把 `bsp.h:98` 的 `ENABLE_SEMIHOSTING_PRINT` 置为 `1`（仓库提交版即为 `1`，工作区曾被改为 `0`），调试统一用 `bsp_printf`，输出经 `_putchar` → `sh_writec` → `call_host` 的 `ebreak` 序列送达 JTAG。协议端点的收发一律直接操作 uart1 寄存器（`uart_write(PROTO_UART_BASE, ...)` / `uart_read(PROTO_UART_BASE)`），不经过 `bsp_putChar`、`_putchar` 或 `bsp_printf`。

该宏取值是**实测确认**的硬前提，不是风格偏好：为 `0` 时 `print.h` 的 `_putchar()` 走 `bsp_putChar` 分支，反汇编可见 `_putchar` 变成 `uart_write(0xf8001000, c)`（uart0 硬件），二进制中 `ebreak` 出现 **0 次**——即 semihosting 完全没进镜像，调试输出到现场接不出来的 uart0 引脚上。本工程因此把"该宏为 `1`"写进了 `softcore-debug-console` 的 requirement 与 scenario。

**理由**：现场没有可用的硬件串口适配器，uart0 的引脚接不出来，semihosting/JTAG 是唯一可用的观测通路。而 `call_host`（`semihosting.h:88-108`）的 `ebreak` 序列会让 CPU 停滞等待主机服务，期间 uart1 的 RX 中断也不执行。把协议输出与调试输出在**寄存器层面**分开，是让"uart1 不受该设置影响"成立的唯一可靠方式——`bsp_putChar` 的定义就是 `uart_write(BSP_UART_TERMINAL, c)`（`bsp.h:30`），**只要 ACK 走 `bsp_putChar`，semihosting 开关就会改变协议行为**。

**备选**：关掉 semihosting 改走 uart0 硬件（现场无串口适配器，不可用）；让标准 `printf` 也进调试通道（需要改共享文件 `common/syscalls.c` 的 `_write`，或把它改成 weak 符号——因为 `standalone.mk:28` 无条件链接 `syscalls.o`，应用无法直接覆盖同名强符号；且调试统一用 `bsp_printf` 已足够，故不引入共享文件改动）。

### 6. 用 `#ifdef` 让 UART1 缺失时仍可构建

**选择**：协议端点相关代码用 `#ifdef SYSTEM_UART_1_IO_CTRL` 包住。当 SoC 尚未重新生成、`soc.h` 中无 UART1 符号时，工程编译为**仅调试输出的降级固件**，并在启动日志明确报告协议端点不可用。

**理由**：UART1 的启用与 IP 重新生成是仓库外依赖（见 `proposal.md` - Impact）。若不做条件编译，本工程在依赖落地前**一行都编译不过**，交付物无法评审、无法验证调试输出通路。加条件编译后，"调试输出"这一半能力现在就可构建验证，协议解析逻辑也可在缺少 UART1 时以桩函数驱动做离线验证。

**备选**：无条件依赖 UART1（交付物在依赖落地前不可构建）；把 UART1 的启用也纳入本次变更（需要重新生成加密 IP，超出软核应用的范围）。

### 7. 命令分发表为静态表，handler 本次全为"未实现"

**选择**：`{command, body_length, handler}` 的静态表，覆盖 `0x86`(len 11)、`0x87`(len > 7)、`0x88`(len 7)、`0x89`(len 4)，`handler` 本次统一指向 `handler_not_implemented`（返回 `0x00` + 调试日志）。

**理由**：把 `body_length` 与命令的绑定放进数据而非 `switch` 分支，正好承载 `softcore-uart-protocol` 中"body_length 与命令不符"的要求，也避免后续实现各命令时改错长度校验。后续变更只需替换 handler 指针，不动解析骨架。

**备选**：`switch (command)` 直接分派（可行，但长度校验会散落在各 case 中）。

### 8. 调试输出经有界队列分段送出，协议正常路径静默

**选择**：调试输出不内联打印，而是先写入一个有界的日志队列，由主循环每次送出至多一个短段；**每段之间先排空 uart1 的接收环形缓冲并完成解析**。uart1 的 ISR 只搬字节，绝不打印。协议的正常路径（合法帧被正确处理）不产生任何调试输出，仅在异常（CRC 错、未定义命令、长度不符）时输出一格短日志。

**理由**：`ebreak` 的服务时间完全取决于主机，单次停滞无法在软件侧界定上界——因此"零丢帧"不可证明。可行的做法是**把停滞切碎**：把最坏情况从"一次打印 N 个字符就停 N×T"降到"每段之间都能服务一次接收"，从而把丢帧概率压到最低。同时把日志量本身降到接近零（正常路径静默），使这条路径在稳态下根本不触发。

**备选**：内联打印（停滞不可控，直接放弃）；在 ISR 内打印（会阻塞中断，明确禁止）；要求零丢帧（主机响应时间未知时无法证明，故 spec 的契约改为"可重同步"）。

**上板实测后的补充（本决策的第一版不够）**：上面写的"正常路径静默"只覆盖了**命令被成功执行**的情况。但本变更是"只做协议框架"，**每个掩膜帧都会失败**（子项未实现），于是每一帧都落进"异常"分支、每帧打一行日志——26 个包就是 26 行。实测结果：**工具发出 26 个包，软核只回了 10 个应答**（工具收到 100 字节 = 10×10，与日志里 10 行 `nak` 精确吻合）；23 个分块里只有 7 个被完整解析，8 个变成乱码帧，8 个整帧消失。

链条是：日志每段经 semihosting 停顿（CPU 停住、中断不被响应）→ 上位机一收到应答就发下一个包 → 4103 字节的分块**正在到达时软核正卡在停顿里** → uart1 的硬件接收 FIFO 只有 128 字节（约 11 ms 的量）而一个分块要 356 ms 才收完 → **FIFO 自己溢出丢字节** → 解析器按 `body_length` 傻等、把后续帧的开头当成自己的 body 吞掉。

**补充措施之一（第一批）**：

1. **输出量改为与"出现了几类问题"成正比，而不是与"收到了几帧"成正比**：新增 `app_log_once(bitno, ...)`，同一类失败原因只报首次。整轮上传的日志量从 26 行降到几行。
2. **补上"丢字节"的可见性**：`STATS_INTERVAL` 由 100 降到 16（否则 26 帧的跑批一行汇总都没有）、汇总行加入 `bad_len`（长度阶段被拒的帧原先完全不可见）、并在丢弃计数从 0 变为非 0 的那一刻报一行告警。

效果：应答数 10 → **22**，坏帧 8 → **1**。**但仍缺 4 个应答，而汇总行显示 `rx_dropped=0`。**

**第二批补充——上面那套的因果关系只对了一半**：

`rx_dropped` 只统计"**接收环**满导致的丢弃"（ISR 跑了、环满了）。它看不见另一种丢失：semihosting 的 `ebreak` 会让 hart **停住在调试模块里**，**期间任何中断都不被响应**；uart1 的硬件接收 FIFO 只有 128 字节深（115200 下约 **11 ms** 的量），停住超过这个时间，**硬件自己丢字节**。

三条证据与这个模型吻合：① `rx_dropped=0` 却仍丢帧 → 丢的不是环是 FIFO；② 停顿次数与丢失帧数**成比例**（52 次→16 帧，约 10 次→4 帧）；③ 每个坏帧互相独立（丢 1 个字节使一个 4103 字节帧的 CRC 失败，解析器在下一个 `0xBB` 重新同步，只坏一帧）。

**这条结论推翻了一个直觉**：加大接收环**不会有用**——CPU 停住时 ISR 根本不执行，环再大也搬不动 FIFO 里的字节。所以修法只能是**彻底消除接收期间的停顿**：

3. **日志发送推迟到串口线路静默之后**（`main.c` 主循环，门槛 200 ms，依据是上位机在包间只静默约 50 ms）。上传期间该条件不成立 → 日志留在环里排队，整批结束后一次性发出，**上传期间一次停顿都没有**。另在静默后补一条汇总，使短跑批也一定有可见结果。日志环 512 → 1024 以容纳一批的消息。
4. **把两种丢失分开报出来**：新增 `proto_uart_fifo_overflow()`（读 UART 错误寄存器偏移 `0x10` 的 `readOverflow` 位，粘滞计数），汇总行并列显示 `ring_drop=` 与 `fifo_ovf=`。

**判读准则**：若仍缺应答且 `fifo_ovf=1`，说明上传期间仍有停顿，继续收紧；若 `ring_drop=0` 且 `fifo_ovf=0` 却仍缺应答，则丢失发生在 FPGA **之外**（X2000 侧 tty 或物理链路），本应用已无可改之处。详见 `tasks.md` §9.8。**接收环容量未作为补偿手段改动。**

### 9. 应用提供 `trap()` 并容忍 semihosting 异常

**选择**：应用实现自己的 `trap()`，对 `ebreak` 引发的断点异常只记录并返回，不挂死。

**理由**：`semihosting.h:94-107` 的 `ebreak` 在**无调试器连接**时不会落到调试模块，而是触发断点异常进入 `trap_entry` → `trap()`（`trap.S:69`），BSP 没有默认 `trap()` 实现——各 demo 都在自己的 `main.c` 里提供。若 `trap()` 挂死，无调试器时整个软核停摆，uart1 协议也随之失效。返回后 `mret` 会落到 `ebreak` 之后的那条 `srai x0,x0,7`（写 `x0`，无副作用），因此 semihosting 调用自然降级为空操作。

**备选**：`trap()` 挂死等待调试器（无调试器时不可用，且与"uart1 必须持续可用"冲突）。

## Risks / Trade-offs

- **[两个 endpoint 同时应答]** → `src/top.v:496-498` 要求同一时刻只有一个 endpoint 执行并应答。uart1 启用后必须保持 `rtl_mask_mode = 1'b0` 使 RTL 端点停用；两个端点同时工作会在 `top.v:1425` 的线与回线上撞车并破坏帧。缓解：启动日志报告协议端点已启用（spec 已要求），并在 tasks 中列为上板核对项。
- **[成功码语义与文档相反]** → 若有人按 `docs/SOFTCORE_DESIGN.md:530` 的 `0x00 = SUCCESS` 读本实现的 ACK，会把每个失败读成成功。缓解：在 spec 与 design 中显式标注；文档订正另开变更，不在本次范围。
- **[仓库内无法端到端验证]** → 无 UART1 符号、无软核仿真环境、`tools/` 不在仓库。缓解：决策 6 的条件编译保证可构建；协议解析可在离线用桩输入验证；端到端验证依赖上板或仓库外的 RISC-V 仿真。
- **[工具链缺失]** → `${RISCV_BIN}` 默认 `riscv-none-elf-`（`common/riscv64-unknown-elf.mk:1`），本机是否安装未知。缓解：tasks 第一步做工具链可用性检查；缺失时属环境问题，不影响交付物评审。
- **[semihosting 停滞导致协议丢帧]** → `call_host` 的 `ebreak` 使 CPU 停摆等待主机，期间 uart1 的 RX 中断不执行；RX FIFO 仅 128 字节（`soc.h:36`），115200 下约 11 ms 填满。单次停滞时长取决于主机响应，软件侧无法给出上界，**零丢帧不可保证**。缓解：决策 8 的分段刷新 + 正常路径静默，把停滞切碎并使其在稳态下不触发；spec 的契约相应定义为"能从字节流缺口重同步"；上位机需容忍偶发 NAK/重试。
- **[标准 printf 静默丢弃]** → 开发者可能用标准 `printf` 却发现没有任何输出。缓解：spec 明确"标准 `printf` 不是调试通道"；应用入口与日志封装处注释说明必须使用 `bsp_printf`。
- **[无调试器时的异常路径]** → 无调试器连接时 `ebreak` 触发断点异常。缓解：决策 9 的 `trap()` 容忍并返回，使 semihosting 调用降级为空操作；spec 已就此立出场景。
- **[`soc.mk` 的死符号]** → `soc.mk:10` 定义 `-DSYSTEM_UART_A_APB=SYSTEM_UART_0_IO_APB`，但 `soc.h` 中无 `SYSTEM_UART_0_IO_APB`（Eclipse 工程用的是 `SYSTEM_UART_0_IO_CTRL`）。缓解：实现时确认该符号是否被任何代码引用；若需要 UART1 的同类符号，在工程 makefile 中补充而非改 BSP。
- **[ISR 与主循环的环形缓冲竞争]** → 单生产者（ISR）单消费者（主循环）需保证索引访问原子。缓解：读写指针各自单写者，用 `volatile` 并保证单字节读写原子（RV32 上 8-bit 访问原子）；缓冲大小取 2 的幂以便用掩码取模。

## Migration Plan

本变更不改变任何现有行为，无需迁移。

部署顺序受仓库外依赖约束，必须按此顺序：

1. 在 `ip/riscv/settings.json:113` 启用 `UART1`，重新生成 Sapphire IP，确认 `soc.h` 出现 `SYSTEM_UART_1_IO_CTRL`（预期 APB `0xF8002000`）与 `SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT`（预期 `2`）。
2. 在 `src/top.v` 重接引脚：uart1 ↔ X2000 协议线（现由 `system_uart_0_io` 承担的 `UART_ST_FR`/`UART_SR_FT`）。uart0 的引脚是否保留由后续决定——调试输出已走 JTAG，uart0 硬件不承载输出。
3. 确认 `rtl_mask_mode` 保持 `1'b0`，使 RTL 端点停用。
4. 构建并烧写本应用。调试输出需要 JTAG 调试器连接并启用 semihosting 支持才能看到；无调试器时 semihosting 调用降级为空操作（决策 9），uart1 协议仍可用。

回滚：撤销第 1、2 步的改动即可回到当前单 UART 状态；本应用在缺 UART1 时会自行降级为仅调试输出的固件，不会因回滚而无法运行。

## Open Questions

- SoC 重新生成后 UART1 的确切实例名与引脚分配（预期 `system_uart_1_io`，APB `0xF8002000`）。这不影响本设计的结构——决策 6 的条件编译已经按"符号可能不存在或命名不同"做好了隔离，落地时按实际符号名调整宏即可。
- 主机端 semihosting 单字符响应的实测延时的量级。它决定决策 8 中"日志段"取多少字符最合适（段太短则日志本身被拖慢，段太长则单次停滞更久）。可后置测量，不改变 spec、方案与任务拆分。
