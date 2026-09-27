# Tasks

## 1. 环境与工程骨架

- [x] 1.1 确认工具链可用：执行 `riscv-none-elf-gcc --version`。若不在 PATH，记录实际前缀并在构建时用 `make RISCV_BIN=<前缀>` 覆盖。验证：命令返回版本号，或已记录替代前缀。
      **实测结果**：工具链与本机路径为 `/h/Efinity/efinity-riscv-ide-2026.1/toolchain/bin/`（`riscv-none-elf-gcc` 13.4.0）与 `/h/Efinity/efinity-riscv-ide-2026.1/build_tools/bin/`（GNU Make 4.2.1），二者均不在 PATH，构建前需 `export PATH=<这两个目录>:$PATH`。二进制名与默认 `RISCV_BIN=riscv-none-elf-` 一致，**无需覆盖 `RISCV_BIN`**。
- [x] 1.2 创建 `embedded_sw/riscv/software/standalone/application/ivlabSoftCore/`，含 `makefile` 与 `src/`。`makefile` 沿用 `uartInterruptDemo/makefile` 的结构（`PROJ_NAME=ivlabSoftCore`、`STANDALONE=../..`、`SRCS` 含 `src/*.c` + `common/start.S` + `common/trap.S`、三段 include、`LDSCRIPT=${BSP_PATH}/linker/default.ld`），**不追加 `ENABLE_SEMIHOSTING_PRINT` 的任何覆盖定义**。验证：`make BSP=efinix/EfxSapphireSoc` 产出 `build/ivlabSoftCore.elf/.hex/.bin/.asm/.map` 五个文件，且 `grep ENABLE_SEMIHOSTING_PRINT` 在工程 makefile 中无命中。
      **注意**：`BSP` 必须传 `efinix/EfxSapphireSoc` 而**不是** `EfxSapphireSoc`——`common/bsp.mk:1` 的默认值是 `${STANDALONE}/../../bsp/${BSP}`，不含 `efinix` 层，而实际布局是 `bsp/efinix/EfxSapphireSoc`（Eclipse 工程的 `.cproject` 亦解析到此路径）。
- [x] 1.3 写最小 `main()`（调用 `bsp_init()` 初始化 uart0 并经调试通道打一行），验证工程骨架可独立构建运行，为后续任务提供可编译基线。验证：构建成功且 `.map` 中出现 `main`。

## 2. 调试输出通道（semihosting / JTAG）

- [x] 2.1 实现 `app_log()` 日志封装，内部调用 `bsp_printf`，并在注释中写明"标准 `printf` 不参与调试通道，必须用 `bsp_printf`"（`common/syscalls.c` 的 `_write` 保持 BSP 现状，本工程不改共享文件）。验证：`riscv-none-elf-objdump -d build/ivlabSoftCore.elf` 显示日志路径引用了 `call_host` 的 `ebreak` 序列；工程内无 `_write` 定义（避免与 `standalone.mk:28` 链接的 `syscalls.o` 符号重复）。
      **实测结果**：链路为 `app_log_flush` → `bsp_printf` → `_putchar_s` → `sh_write0` → `slli zero,zero,0x1f; ebreak; srai zero,zero,0x7`，镜像中 `ebreak` 出现 1 次，确认走 semihosting 而非 uart0 硬件。工程内无 `_write` 符号（由共享 `syscalls.o` 提供）。
      **格式化方式**：不用 newlib `vsnprintf`——实测它会拖入 `_svfprintf_r`/`_dtoa_r`/软浮点/`_malloc_r`，RAM 占用从 6.36% 涨到 49.58%（62,960 B vs 8,080 B，124 KB 区域）。改为在 `app_log.c` 内自写极简格式化器（`%s %c %d %u %x %X %p %%`，不支持宽度/精度/浮点）。改用 semihosting（`ENABLE_SEMIHOSTING_PRINT=1` → `print_full.h`）后本步骤为 **26,816 B / 21.12%**，其中约 19 KB 是 BSP 自带的 printf 库（`bsp_printf` 的固有成本，见 design 决策 5）。全部实现完成后的最终占用为 **30,912 B / 24.34%**。
- [x] 2.2 实现 `trap()`，对断点异常只记录并返回，不挂死（design 决策 9）。验证：代码审查确认 `trap()` 在 breakpoint cause 下走到返回路径；无 JTAG 调试器时程序不挂死（可用仿真或断点异常注入验证）。
      **实测结果**：`trap()` 按 `mcause` 分四路——外部中断→`isr_routine()`、其它中断→计数、`cause==3`（`CAUSE_BREAKPOINT`）→计数并返回、其它异常→计数并仅首次经 `app_log` 记录。首版实现只写 `else if (cause == CAUSE_BREAKPOINT) return;`，两个分支行为相同，**被 GCC 折叠掉**（反汇编显示异常路径直接 `ret`，`cause==3` 的判断消失）——已改为各分支行为不同，反汇编现可见显式的 `li a4,3; beq a5,a4` 判断且所有路径 `ret`，无挂死路径。
- [x] 2.3 实现有界日志队列与分段刷新：日志先入队，主循环每次只送出一个短段，**每段之间先排空并解析 uart1 接收缓冲**（design 决策 8）。验证：代码审查确认解析先于日志刷新；确认队列有明确上界且满时有丢弃计数，无无界缓冲。
      **实测结果**：`app_log.c` 的环为 `APP_LOG_RING_SIZE = 512` B（2 的幂），`app_log_flush()` 每次最多送 `APP_LOG_CHUNK = 32` 字符，是唯一触碰调试硬件的函数。`main.c` 主循环顺序为：`while (proto_uart_rx_pop(&byte))` 完整排空并逐帧处理 uart1，之后才调用一次 `app_log_flush()`——解析严格先于日志刷新。消息整体入队、放不下则整条丢弃并递增 `s_dropped`（无部分消息、无无界缓冲）。
      **完成后的补充修正（换行符）**：首版 `app_log_flush()` 把环里的字节原样交给 `bsp_printf`，而 `app_log()` 只补了一个 `'\n'`——**缺 `'\r'`**。终端里 `'\r'` 负责回行首、`'\n'` 只负责下移一行，所以实际输出会呈**阶梯状错位**。本工程既有代码（memTest、uartInterruptDemo）都是显式写 `"\r\n"` 的，BSP 打印库也不做换行转换。已改为在 `app_log_flush()` 里统一把 `'\n'` 展开成 `"\r\n"`：转换只存在于唯一碰硬件的那一处，因此无论 `'\n'` 是自动补的还是调用者写在正文里的都会正确换行；输出上限仍卡在 `APP_LOG_CHUNK`，放不下的那个 `'\n'` 留在环里下次补发（绝不把 `\r\n` 拆到两次发送）。为此给测试台加了 `stub/bsp.h` 替身把 `bsp_printf` 接到内存缓冲，新增 13 条断言（`test/test_app_log.c`）覆盖：基本换行、正文内 `'\n'`、**边界不拆分（首次 flush 必须发 31 字节而非 32）**、长消息跨多段完整性、空队列。应用 RAM 由 30,912 → 30,992 B（+80）。
- [x] 2.4 实现启动日志：初始化完成后输出一行标识，包含协议端点所在 UART 与使能状态（满足 `softcore-uart-protocol` 的"启动日志标识"要求）。验证：上板时 JTAG 调试控制台出现该行；无板时检查字符串常量存在于 `.elf` 中（`strings build/ivlabSoftCore.elf`）。
      **实测结果**：`main()` 输出 `*** ivlabSoftCore ***`、`debug channel: semihosting (JTAG)`，随后按 `PROTO_ENDPOINT_AVAILABLE` 二选一输出 `protocol endpoint: ENABLED on uart1 (base 0x%x)` 或 `protocol endpoint: UNAVAILABLE (SoC exposes no uart1)`。当前 `soc.h` 含 UART1 符号，故实机打印 ENABLED 分支并带上 `PROTO_UART_BASE` 值——正好可用于与 RTL `rtl_mask_mode` 的取值做端点互斥核对。

## 3. uart1 协议端点与条件编译降级

- [x] 3.1 用 `#ifdef SYSTEM_UART_1_IO_CTRL` 包住全部协议端点代码，定义 `PROTO_UART_BASE`；未定义时协议端点编译为空实现并让启动日志报告"协议端点不可用"（design 决策 6）。验证：在当前 `soc.h`（无 UART1 符号）下 `make` 成功，且 `strings` 输出含"协议端点不可用"。
      **实测结果**：`proto_uart.c` 用 `#if PROTO_ENDPOINT_AVAILABLE` 分两支，`proto_uart.h` 由 `SYSTEM_UART_1_IO_CTRL` 派生 `PROTO_UART_BASE` 与 `PROTO_ENDPOINT_AVAILABLE`；`main.c` 据此在启动日志二选一输出。降级分支用 `#include "bsp.h"` + `#undef SYSTEM_UART_1_IO_CTRL` + `#include "proto_uart.c"` 的桩 TU 以 `-fsyntax-only` 编译通过（exit 0），证明 `#else` 桩实现可编译（若误走 `#if` 分支会因 `PROTO_UART_BASE` 未定义而失败）。注意：当前 `soc.h` **已包含** UART1 符号，故实机走的是启用分支，降级路径由上述桩 TU 验证。
- [x] 3.2 初始化 uart1 为 115200 8N1，分频系数按 `BSP_CLINT_HZ/(115200*8)-1` 计算，与 `bsp_init()` 对 uart0 的算法一致（满足 `softcore-uart-protocol` 的"配置与 BSP 一致"要求）。验证：代码中分频算式与 `bsp.h:144` 一致；UART1 未启用时该初始化被条件编译排除。
      **实测结果**：`proto_uart.c` 的 `config.clockDivider = BSP_CLINT_HZ / (BSP_UART_BAUDRATE * BSP_UART_DATA_LEN) - 1`，与 `bsp.h` 中 `bsp_init()` 的算式逐字一致（仅少了空格）；配置项 `BITS_8`/`NONE`/`ONE` 与 `bsp_init()` 相同。整个 `proto_uart_init()` 位于 `#if PROTO_ENDPOINT_AVAILABLE` 内。
- [x] 3.3 实现 RX 环形缓冲（大小取 2 的幂，ISR 单写、主循环单读，索引用掩码取模）与 PLIC 中断注册，注册序列参照 `uartInterruptDemo/src/main.c:130-152`，中断号为 `SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT`。验证：代码审查确认 ISR 只做"读 `uart_read` → 写缓冲 → 推进写指针"，无解析逻辑且无任何打印调用；缓冲满时有丢弃计数。
      **实测结果**：环 512 B（2 的幂，掩码取模），`s_head` 仅 ISR 写、`s_tail` 仅主循环写。`proto_uart_isr()` 只做：读状态→屏蔽 RX 中断→循环（查 `uart_readOccupancy` 非零才 `uart_read`，避免阻塞）→写环→推进 `s_head`；环满时仅递增 `s_dropped` 并继续排空 FIFO；末尾重新使能中断。PLIC 注册为 `plic_set_threshold(...,0)` + `plic_set_enable(..., SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT, 1)` + `plic_set_priority(...,1)`，与 `uartInterruptDemo` 范式一致；CSR（`mtvec`/`mie`/`mstatus`）在 `main.c` 的 `isr_init()` 中最后设置。
- [x] 3.4 确保协议路径与调试通道解耦：协议收发一律用 `uart_read(PROTO_UART_BASE)` / `uart_write(PROTO_UART_BASE, ...)`，协议相关代码 MUST NOT 出现 `bsp_putChar`、`_putchar`、`bsp_printf`（满足 `softcore-uart-protocol` 的"协议路径独立于调试通道配置"要求）。验证：`grep -n "bsp_printf\|bsp_putChar\|_putchar" src/` 在协议收发与 ACK 构造文件中无命中。
      **实测结果**：`grep -n "bsp_printf\|bsp_putChar\|_putchar" src/proto_uart.c src/proto_uart.h` 无命中。收发均直接使用 `uart_read(PROTO_UART_BASE)`、`write_u32(data[i], PROTO_UART_BASE + UART_DATA)`、`uart_writeAvailability(PROTO_UART_BASE)`。首次检查曾命中 `proto_uart.h` 注释里列举这三个名字的那句话（假阳性），已改写注释以保持该 grep 检查可靠。

## 4. 帧解析与 CRC（可在无硬件下验证）

- [x] 4.1 实现 CRC-16/CCITT（多项式 `0x1021`、初值 `0x0000`、不反射、无最终异或），与 `RtlMaskUartAxiWriter.v:66-77` 的算法逐位一致。验证：用独立实现按同一参数对相同输入计算，结果一致；覆盖 ACK body `{06,cmd,02,status}` 的若干组合。
      **实测结果**：`crc16.c` 逐位复刻 RTL 的 `crc16_byte`（`crc ^ (data<<8)`，循环 8 次判 MSB 后移位并条件异或 `0x1021`）。黄金向量由 Python 按参数集独立实现算出、**不是**跑本代码得到的：`"123456789"` → `0x31C3`；ACK body `{06,cmd,02,status}` 的 5 个命令码 × 2 个状态共 10 个值（如 `cmd=0x88,status=0x00` → `0xD300`，`cmd=0x86,status=0xFF` → `0xD6F1`）全部在测试中硬编码比对通过。
- [x] 4.2 把帧解析实现为**与硬件无关的纯函数**（输入字节、输出帧事件，不直接读寄存器），便于在主机上以桩输入驱动测试。验证：解析源文件不 include 任何 UART/PLIC 头文件。
      **实测结果**：`frame.c` 仅 include `frame.h`/`crc16.h`，`frame.h`/`crc16.h` 仅 include `<stdint.h>`——`grep -l "uart.h\|plic.h\|bsp.h\|riscv.h"` 在 `frame.*`/`crc16.*` 上无命中。`protocol.c` 也保持纯净（只 include `protocol.h`/`crc16.h`），把失败原因经 `protocol_response_t.reason` 回传而非就地打印，因此这三个模块都能在测试中链接。
- [x] 4.3 实现帧状态机：`0xBB` 同步、`body_length`(2B 大端)、body(`06|cmd|00|payload`)、CRC 比对、`0xAA` 帧尾、以及异常路径（前导噪声丢弃、帧尾错误、长度越界）。验证：`softcore-uart-protocol` 的"接收合法帧"/"前导噪声被丢弃"/"body 内的 0xBB 是数据而非帧头"/"帧尾错误"等场景各有一个测试用例通过。
      **实测结果**：状态机 `ST_HEADER→ST_LEN_H→ST_LEN_L→ST_BODY→ST_CRC_H→ST_CRC_L→ST_FOOTER`，与 RTL 解析器同序。T2 共 24 条断言全部通过：合法帧解析出 `command=0x88`/`body_length=7`/三个 body 头字段；前导噪声 `0x01 0x00` 被丢弃后仍正确解析；**payload 含 `0xBB` 的 `0x87` 帧被完整解析且 CRC 通过**；CRC 错/帧尾错各产生一个事件且对应标志位为假；长度 2 与 5000 均被拒且 `bad_length_count` 递增、不产生 ACK；marker/direction 违规被 `format_ok` 捕获。
      **实施中修正了 spec 的一处缺陷**：原 scenario"帧内出现新的帧头 → 重同步"是错的——`0x87` 的 payload 是掩膜位图原始字节、可取 `0xBB`，按该 scenario 实现会把合法帧误截断。已改为与 RTL 一致（body 阶段只按 `body_length` 计数，`0xBB` 视为数据；失步靠长度+CRC 检测），并补了 `body[0]`/`body[2]` 校验与长度越界两条 scenario。

## 5. 桩测试与 ACK 应答

- [x] 5.1 在应用目录下建 `test/`，编译 4.2 的解析源文件，以字节数组驱动上述场景。验证：编译并运行测试，断言全部通过；覆盖 4.3 的各场景与"CRC 错误"场景。
      **方法偏离（已记录）**：原任务写"用主机 gcc"，但**本机没有任何 x86 C 编译器**（`gcc`/`cc`/`clang`/`cl` 全部不存在，已全盘搜索）。改用 Efinity 自带的 RISC-V 工具链构建为 rv32im 目标、在 Efinity 自带的 `qemu-system-riscv32` 上执行——比主机编译更强：跑的是目标同款指令集，且 `../src` 下的模块**原封不动**参与编译链接。
      **实测结果**：`test/` 含 `harness.{c,h}`（naked `_start` 设 `sp`、UART 输出、SiFive test device 退出码）、`qemu32.lds`、`test_protocol.c`、`makefile`。`make -C test` 输出 **67 条断言全部 PASS，`exit status: 0`**——测试结果就是进程退出码，可直接用于 gate。
      **qemu 接入踩到的三个坑（已修，记录以免重蹈）**：① `-Ttext=` 会让链接器把 ELF 头放到 RAM 之外并与 FDT 重叠，必须用真正的 linker script；② `.init` 输出段必须放在最前且 `KEEP`，否则 `_start` 不落在镜像基址；③ `_start` 必须 `naked` 且**先设 `sp` 再跳转**——C 函数序言会先 `sw ra,12(sp)`，而复位时 `sp=0`，直接 fault 在 `0xFFFFFFFC`。
- [x] 5.2 实现 ACK 构造：10 字节 `BB 00 04 06 <cmd> 02 <status> <crc_hi> <crc_lo> AA`，CRC 覆盖 ACK body `06|cmd|02|status`。验证：与 `RtlMaskUartAxiWriter.v:438-459` 的 `response_byte` 逐字节比对一致；对已知输入的完整 10 字节序列在测试中硬编码为期望值。
      **实测结果**：`protocol_build_ack()` 的字段顺序与 `response_byte` 逐一对应（含 `ack[5] = 0x02` 这个固定方向/类型码）。T3 断言完整序列逐字节相等：`cmd=0x88,status=0x00` → `BB 00 04 06 88 02 00 D3 00 AA`；`cmd=0x86,status=0xFF` → `BB 00 04 06 86 02 FF D6 F1 AA`（两个 CRC 均由 Python 独立算出）。
- [x] 5.3 实现原子处理序列：解析 → 执行 → 阻塞发送 ACK → 恢复接收，期间不解析新字节（design 决策 4，修正 RTL 的 ACK 丢失缺陷）。验证：测试中连续送入两个背靠背完整帧，断言收到两个 ACK（满足"ACK 不丢失"场景）。
      **实测结果**：`main.c` 的 `handle_frame()` 把"决策→上报→`proto_uart_write` 送 ACK"做成一个不可分割的序列，其间不再从环里取字节；ACK 发送走带超时的 bounded wait（每字节 `PROTO_TX_TIMEOUT_SPINS = 100000` 次自旋上限），不会因 UART 不排空而卡死主循环。T5 送入两个背靠背帧，断言 `frames == 2` 且 `acks == 2`、每个 ACK 的首尾字节为 `0xBB`/`0xAA`——即 RTL 端点那个"上一 ACK 未发完就静默丢弃后到包 ACK"的缺陷在软件侧不复现。
- [x] 5.4 实现命令分发表 `{command, body_length, handler}`，覆盖 `0x86`(len 11)、`0x87`(len >7)、`0x88`(len 7)、`0x89`(len 4)，handler 统一为 `handler_not_implemented`（返回 `0x00` + 调试日志）。验证："已识别但未实现"/"未定义命令码"/"body_length 与命令不符"三个场景各有一个测试用例通过；长度不符时断言未读越界字节。
      **实测结果**：`protocol.c` 的 `s_table[]` 为 `{command, body_length, min_length, name, handler}`，`0x87` 用 `LEN_ANY` + `min_length=8` 表达"长度 > 7"，其余为精确值。handler 统一 `handler_not_implemented`。为保持本模块可在无硬件下链接，"返回 0x00 + 调试日志"拆成两步：`protocol.c` 经 `protocol_response_t.reason` 回传原因（新增 `PROTO_REASON_*` 枚举），由 `main.c` 的 `report_frame()` 落到调试通道——因此 `protocol.c` 不 include 任何 BSP 头。T4 断言 `NOT_IMPLEMENTED`/`UNKNOWN_COMMAND`/`BAD_LENGTH`/`BAD_FORMAT`/`BAD_INTEGRITY` 五种 reason 及命令名解析全部正确。**未读越界字节**由设计保证：解析器把 body 从第 4 字节起只折进 CRC 后丢弃、从不缓存 payload（`frame.c` 的 `ST_BODY` 分支），因此不存在越界读取。
- [x] 5.5 实现诊断计数器（接受帧数、拒绝帧数分开计数）与可读输出。验证：测试中依次送入一个合法帧与一个 CRC 错误帧，断言计数分别为 1 和 1（满足"接收诊断计数器"场景）。
      **实测结果**：`protocol_stats_t` 的 `accepted_count`/`bad_packet_count` 分开计数——"接受"定义为完整性+格式通过、命令已识别且长度正确；其余（含 CRC/帧尾错、格式错、未定义命令、长度不符）计入 bad。T4 的断言序列为：合法 `0x88` → accepted=1/bad=0；CRC 错 → accepted 不变/bad=1；未定义命令 → bad=2；长度不符 → bad=3；marker 违规 → bad=4。**可读输出**：每处理 `STATS_INTERVAL = 100` 帧由 `main.c` 输出一行 `frames/accepted/bad/rx_dropped`，速率受限以免拖垮 semihosting 通道；解析器另暴露 `bad_length_count`（长度阶段即被拒、不产生 ACK 的那类）。

## 6. 回归与上板核对

- [x] 6.1 确认未改动共享源文件：`embedded_sw/riscv/software/standalone/common/` 下 MUST 无改动；`bsp.h` MUST 与提交版一致（`ENABLE_SEMIHOSTING_PRINT` 为 `1`）。验证：`git diff -- embedded_sw/riscv/software/standalone/common/` 为空；`git diff --stat -- .../include/bsp.h` 为空；`grep -n "define ENABLE_SEMIHOSTING_PRINT" .../bsp.h` 输出 `1`。
      **实测结果**：`common/` 无改动；`bsp.h` **无差异**——工作区此前被改成 `0`，本次按 design 决策 5 恢复为提交版的 `1`，因此该文件回到与 HEAD 一致的状态，本次变更最终**没有修改任何共享源文件**。`bsp/` 下仍有 3 个改动文件（`soc.h`、`openocd/ftdi_ti.cfg`、`openocd/sapphire_soc_xsvd.json`），但**全部来自你已完成的 SoC 重新生成**（新增 UART1 符号与调试配置），非本次变更所为。
- [x] 6.2 无硬件下的整体验证：`make BSP=efinix/EfxSapphireSoc` 成功 + 5.1 的桩测试全部通过 + 任务 3.1 的降级路径生效 + 3.4 的解耦 grep 无命中。此为本次变更在仓库内可完成验证的上限。
      **实测结果**：应用 `make BSP=efinix/EfxSapphireSoc` 成功（`ram: 30,912 B / 124 KB = 24.34%`，产出 `.elf/.hex/.bin/.asm/.map` 五个文件）；`make -C test` 67 条断言全通过、退出码 0；降级路径由 `#undef SYSTEM_UART_1_IO_CTRL` 的桩 TU 以 `-fsyntax-only` 验证可编译；协议模块的解耦 grep 无命中。仓库内可验证项已全部完成。
- [ ] 6.3 上板端到端（**阻塞中：依赖仓库外前置条件**，见 `proposal.md` - Impact）：确认 `soc.h` 已出现 `SYSTEM_UART_1_IO_CTRL` 与 `SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT`，且 `src/top.v` 已完成 uart1→X2000 的引脚重接。验证：用外部工具向 uart1 发送一帧合法 `0x86` 命令，收到 `BB 00 04 06 86 02 00 <crc_hi> <crc_lo> AA`；同时在 JTAG 调试控制台出现对应的"未实现"日志，且该日志字节不出现在 uart1 上。
      **当前状态（实施时核实）**：SoC 侧**已完成**——`ip/riscv/settings.json:113` 的 `UART1` 为 `1'b1`，`ip/riscv/source/soc_config:24` 有 `--uart name=system_uart_1_io,address=0x002000,interruptId=2`，`ip/riscv/riscv.v` 已生成 `system_uart_1_io_rxd/txd`，`soc.h` 有 `SYSTEM_UART_1_IO_CTRL 0xf8002000`（size `0x40`）与 irq `2`。**但 `src/top.v:1592-1599` 的 `riscv u_riscv` 例化只接了 `system_uart_0_io_txd/rxd`，uart1 的两个端口仍然悬空**，未接到 X2000，因此本任务无法进行。按已确认的范围，`top.v` 改动不在本次变更内。
- [ ] 6.4 上板核对端点互斥：确认 `src/top.v:493` 的 `rtl_mask_mode` 为 `1'b0`，且 uart1 上观察到的 ACK 只出现一次（无两份重复应答）。验证：连续发送 20 帧，每帧恰好收到一个 ACK，无重复、无丢失。
      **当前状态**：同样阻塞于 6.3 的 `top.v` 接线。可用的辅助判据：本应用的启动日志会打印 `protocol endpoint: ENABLED on uart1 (base 0x%x)`，与 `rtl_mask_mode` 的取值交叉核对即可确认只有一个 endpoint 在应答。

## 7. 上板实测后的协议代次纠正

> 这一节记录的是**任务 6.3 的第一次实机尝试**及其结论。uart1 接线完成后上板实测，
> 26 个掩膜包**全部被拒**，由此定位到一个根本性错误——实现的协议代次不对。
> 这不是新增任务，而是对第 4、5 组产物的一次纠正，纠正内容已在代码与 spec 中落地。

- [x] 7.1 定位上板失败原因：实机日志为 `rx cmd=0x1 bad body header, nak`、随后大量
      `rx cmd=0x2 crc/footer bad, nak`，且上位机工具报"ACK长度错误：收到180字节，预期260字节"。
      排查结论：**不是接线、不是时序、不是丢字节**，而是协议代次不匹配——工具发的大类是
      `0x00`、子项 `0x01`–`0x05`，而实现按 RTL 写的是大类 `0x06`、子项 `0x86`–`0x89`。
      证据：`tools/send_mask_via_adb.py` 的 `packet()` 为 `body = (0x00, command, 0x00) + payload`，
      `verify_ack()` 校验 `body[:3] == (0x00, command, 0x02)`；日志第一行的 `cmd=0x1` 正是工具第 1 个包
      `packet(0x01, ...)` 被误读的结果。
- [x] 7.2 确认权威依据：`docs/测试说明.md` 的「指令构成」定义了 `body = 大类|子项|类型|payload`、
      大类 `0x00` 为掩膜、应答固定 10 字节、状态码二值 `0xFF`/`0x00`；`docs/adb_test_commands.md` 与
      `docs/x2000_ui_protocol.md` 三方一致。**并且 `adb_test_commands.md` 给出的掩膜报文
      `BB 00 07 00 03 00 00 96 00 B2 83 E0 AA` 能被独立 Python 实现逐字节复现**（含 CRC），
      交叉验证通过。
      **调研失误**：这三份文档一直在仓库 `docs/` 下，首次协议调研时只读了 `SOFTCORE_DESIGN.md`
      与 RTL，漏读了它们——把"仓库内可查"误当成了"权威"。
- [x] 7.3 代码改为文档那一代：`frame.h` 的大类/子项常量与 `frame_t.category` 字段、`frame.c` 的
      `format_ok`（改为校验类型字段而非大类）、`protocol.c` 的子项表（`0x01`–`0x05`，含 `0x05` 长度 3）
      与应答构造（回显大类、`body[0]` 由 `0x06` 改为 `0x00`）。应用 RAM 30,992 → 31,152 B。
- [x] 7.4 大类归属改为按协议路由（**用户决策**："按照协议来实现，不应该强行校验 body[0] == 0x00"）：
      只有大类 `0x00`（掩膜）由本端点处理并应答；`0x01` 变倍／`0x02` 热点／`0x03` 伪彩／`0x04` UI
      只解析、**不应答**、不计入坏包，单独计数。理由：给它们回"大类 0x00"的应答会让对应模块的
      上位机工具报"ACK 格式错误"，等于把别人撞坏。CRC/帧尾错误的帧同样不应答——字节不可信，
      无从判断归属。spec 相应新增「大类归属」requirement，并修正了原「完整性校验」里
      "仍返回 ACK"的表述。
- [x] 7.5 测试向量换用文档金标帧并重算期望值：`test_protocol.c` 中 6 个向量逐字节抄自
      `docs/adb_test_commands.md`（掩膜开/关/位置、变倍、热点、UI），其余由已交叉验证的
      Python 实现生成。全套 **107 条断言全 PASS，exit status 0**（含"其它大类不应答"、
      "CRC 错误不应答"、"应答逐字节等于 `BB 00 04 00 03 02 00 3F 32 AA`"）。
- [x] 7.6 顺带修掉一处早前编辑弄坏的 spec 结构：「ACK 应答格式」那条的标题被误删，
      正文成了没有标题的孤立段落（`openspec validate --strict` 未能发现）。重写 spec 时已修复。
- [ ] 7.7 **待重新上板验证**：任务 6.3 需在协议纠正后重跑。预期：掩膜开/关/位置三个命令
      应收到 `status = 0x00`（子项已识别但未实现），**且不再出现 `bad body header`**；
      上位机工具的 ACK 长度校验应从"180 字节"变为 260 字节（26 个应答）。
- [ ] 7.8 旧的 `MEM_*` / `0x86`–`0x89` 表述若出现在其它文档（`docs/SOFTCORE_DESIGN.md`、
      `docs/memory_axi.md` 等）中，需另行订正——不在本次变更范围。

## 8. 上板实测后的日志量纠正

> 7.1–7.7 完成协议代次纠正后再次上板，**子项识别全部正确**
> （`rx cmd=0x1 (begin) len=11`、`0x02 (chunk) len=4103`、`0x03 len=7`、`0x04 len=4`），
> 但暴露出第二个独立问题：日志量把协议接收拖垮。本节记录该问题与修正。

- [x] 8.1 定位：工具发 26 个包（1 begin + 23 chunk + 1 position + 1 enable），软核只回
      **10 个应答**（工具收到 100 字节 = 10×10，与日志里 10 行 `nak` 精确吻合）。拆分块算：
      23 个分块里只有 **7** 个被完整解析、**8** 个变成乱码帧（`crc/footer bad`）、**8** 个整帧消失。
      **根因**：本阶段每个掩膜帧都失败 → 每帧打一行日志 → 日志的 semihosting 停顿期间 uart1
      接收中断不被服务 → 接收环 512 字节（约 44 ms 的量）顶不住一个 4103 字节分块（356 ms）
      的到达 → 溢出丢字节 → 解析器按 `body_length` 傻等、吞掉后续帧。这正是 design 决策 8
      预判、proposal 风险里写过的"日志与协议抢时间"。
- [x] 8.2 治本：新增 `app_log_once(bitno, ...)`（`src/app_log.h/.c`）——同一类失败原因只报
      首次，之后不产生任何字节。`report_frame()` 的五处日志改用它，**整轮上传日志量由 26 行
      降到最多 5 行**。`app_log()` 的入队主体抽成 `static app_log_v()` 供两者共用，避免复制
      一份入队逻辑。实现中显式挡住 `bitno >= 32`——C 里 `1U << 32` 是**未定义行为**（不是
      得到 0），而 bitno 直接取自 `protocol_reason_t`，将来加枚举成员就可能越界。
- [x] 8.3 补可见性（抑制日志会让下次上板"看不出成没成"，必须同步补上）：
      `STATS_INTERVAL` 100 → **16**（26 帧的跑批原本一行汇总都出不来）、汇总行加入 `bad_len`
      （长度阶段即被拒的帧原先完全不可见）、并新增**"首次丢字节"告警行**
      `rx dropped: total=%u` ——把"接收环溢出"这个最难从现象反推的原因变成直接证据。
- [x] 8.4 `app_log_once` 进离机测试（`test/test_app_log.c` 的 T7，6 条断言）：首次有输出、
      **同位号第二次捕获长度不变**（"一个字节都不产生"的直接证据）、换位号仍输出（按位独立）、
      `bitno >= 32` 被拒且不搅乱已有位、`app_log_init()` 后同位号可再报。全套
      **113 条断言全 PASS，exit status 0**；应用 RAM 31,152 → **31,408 B**。
- [x] 8.5 spec `softcore-debug-console` 新增 scenario「重复出现的同类失败不产生无上限输出」，
      把"输出量应与问题**类别数**成正比、而非与帧数成正比"写成行为契约。
- [ ] 8.6 **待重新上板验证**：期望日志总量 ≤ 5 行、不再出现 `bad body header`、出现一行
      `stats: ... rx_dropped=0`、**不出现** `rx dropped:` 告警行，且工具侧的 ACK 长度校验
      由"收到 100 字节"变为 **260 字节**（26 个应答）。
- [x] 8.7 ~~判读准则：若 `rx_dropped` 非 0 就加大接收环（512 → 8192）。~~
      **这条准则是错的，已在 §9.1 作废。** 理由见下：CPU 被 semihosting 停住时中断
      根本不被响应，接收环再大也搬不动硬件 FIFO 里的字节——加大环对那种丢失无效。

## 9. 上板实测后的第二次纠正：FIFO 溢出与环溢出是两回事

> 8.2/8.3 上线后再次上板，工具收到的应答由 100 字节升到 **220 字节（22 个）**，
> 坏帧由 8 个降到 **1 个**，日志也压到了几行。但仍有 4 个包没回应答，而且
> 汇总行显示 **`rx_dropped=0`** —— 这个"0"推翻了 §8 认定的原因。

- [x] 9.1 **纠正 §8.7 的准则**：`rx_dropped` 只统计"**接收环**满导致的丢弃"（ISR 跑了、
      环满了）。它看不见另一种丢失——semihosting 的 `ebreak` 会让 hart 停住在调试模块里，
      **期间任何中断都不被响应**，uart1 的硬件接收 FIFO（128 字节，115200 下约 **11 ms**
      的量）会自己溢出并静默丢字节。**所以 CPU 停住时，接收环再大也没用**——它搬不动
      FIFO 里的字节。加大环（方案 B）从一开始就是错的杠杆。
- [x] 9.2 证据链（三条都与模型吻合）：① `rx_dropped=0` 却仍丢帧 → 丢的不是环是 FIFO；
      ② 停顿次数 26 行→约 5 行、丢失帧数 16→4，**成比例**；③ 每个坏帧互相独立
      （`bad=1`，不连锁）→ 丢掉一个字节使一个 4103 字节帧的 CRC 失败，解析器在下一个
      `0xBB` 重新同步，**只坏一帧**。残余的元凶正是 §8.3 新加的汇总行本身：它落在分块流
      中间，要两次 semihosting 停顿。
- [x] 9.3 治本：**日志发送推迟到串口线路静默之后**（`main.c` 主循环）。静默门槛取
      **200 ms**（上位机工具在包间只静默约 50 ms，所以上传期间该条件根本不成立）→
      **上传期间一次停顿都没有**，日志在环里排队、整批结束后一次性发出。用
      `clint_getTime(BSP_CLINT)` 取时刻，并用自增计数器把"读时间"降频到每 4096 轮一次
      （读 CLINT 是 3 次 MMIO，不能每轮都做）。同时新增"静默后若还有未汇报的帧就补一条
      汇总"，让短跑批也一定有汇总。`STATS_INTERVAL` 16 → 64（短跑批由静默汇总覆盖，
      周期性那条只负责长时间不停的流；且它入队后不会立刻发出，只占日志环）。
- [x] 9.4 补上缺失的仪表——**硬件 FIFO 溢出可见**：新增 `proto_uart_fifo_overflow()`，
      读 UART 错误寄存器（偏移 `0x10`、`readOverflow` 在 bit1、写 1 清零；位定义来自
      `bsp/.../openocd/sapphire_soc_xsvd.json`，`driver/uart.h` 未封装该寄存器），
      做成**粘滞**计数并在初始化时清一次。汇总行与告警行并列输出
      `ring_drop=` 与 `fifo_ovf=`——**这个"两种丢失分开看"的能力，正是本轮排查花了两个
      来回才获得的**。汇总行另加 `log_drop=`（日志环装不下的消息数），避免"消息静默消失"
      再变成一次排查。
- [x] 9.5 日志环 512 → **1024**：推迟发送意味着环要装下"一整批期间的全部消息"，
      抑制重复后约 300 字节，512 够但没余量。应用 RAM 31,408 → **32,384 B**。
- [x] 9.6 离机测试保持 **113 条断言全 PASS**（本轮改动集中在 `main.c`/`proto_uart.c`，
      测试台覆盖不到，其作用是回归护栏）。
- [ ] 9.7 **待重新上板验证**：期望工具侧 ACK 由 220 字节变为 **260 字节**（26 个全到）；
      上传期间日志一行都不出现、结束后一次性出现几条；汇总行 `ring_drop=0` **且**
      `fifo_ovf=0`；不出现 `rx lost:` 告警行。
- [ ] 9.8 **判读准则（修正版）**：
      - 仍缺应答且 `fifo_ovf=1` → 上传期间仍有停顿，继续收紧（必要时改成上传期间完全不输出）；
      - 仍缺应答但 `ring_drop=0` 且 `fifo_ovf=0` → 丢失发生在 FPGA **之外**（X2000 侧 tty
        或物理链路），本应用已无可改之处，需转去查 X2000 侧——工具自己的注释就提到过
        它的 UART RX FIFO 会偶发丢应答；
      - 不再缺应答 → 目标达成。
