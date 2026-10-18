# 通过 X2000 测试 OSD 菜单显示 —— 命令清单与判据

本文是**现场手册**：从零开始把 Ti60 的 OSD 菜单显示测出来，一条一条给命令、给判据。
协议字段与边界见 [x2000_ui_protocol.md](x2000_ui_protocol.md)；全模块（掩膜/伪彩/变倍/…）的
裸命令见 [adb_test_commands.md](adb_test_commands.md)；位流与固件的前置细节见
[board_bringup_quad_osd.md](board_bringup_quad_osd.md)。

## 0. 本文怎么用

**链路**：PC → USB adb → X2000（Android 主控）→ `/dev/ttyS1` @115200 8N1 → Ti60 软核 uart1
（base `0xf8002000`）。PC 侧只做两件事：把帧推进 `/dev/ttyS1`，从同一个口读回包。

**先说三件"不是故障"的事**，否则现场一定会把它们当成故障：

1. **固件只实现了 3 个菜单页**：`0x0000` MAIN MENU（9 项）、`0x0100` IMAGE SETTING（6 项，
   前 4 项是数值行）、`0x0200` IMAGE MODE（4 项）。规格里另外 23 页（`0x0101`、`0x0300`…）
   **发过去一律返回失败**（`status=0x00`）。**不要照 [adb_test_commands.md](adb_test_commands.md)
   或 x2000_ui_protocol.md §4 的 26 页清单去逐页敲。**
2. **子项 `0x01`–`0x05`（`--show`/`--hide`/`--key`/`--status`/`--clear`/`--marker`）
   只解析、不应答、也不改变任何状态** —— 手敲必然超时。**要显示/隐藏菜单请用 `--view`
   的 `flags.bit0`（即 `--hidden` 与否），不是 `--show`/`--hide`。**
3. **菜单显示英文**。场景表里保留了俄语列，但本变更删掉了语言位，渲染固定取英文。

**两条判据必须分开看，只满足前一条不算通过**：

| 判据 | 看什么 |
|---|---|
| **回包判据** | 10 字节（写命令）或 18 字节（`--query-view`），`status=0xFF` 才是成功 |
| **画面判据** | 屏幕上真的出现了对应的页面/选中项/数值变化 |

**约定**：下面 Python 形式里的 `$ADB` 指 adb 可执行文件，脚本路径都是**相对仓库根**的。
先在 PowerShell 里进仓库、设一次变量：

```powershell
cd H:\Project\ivlab-239                      # 必须：下面所有 python tools/... 都相对这个目录
$ADB = "H:/Project/1280图传测试/platform-tools/adb.exe"
```

> 工作目录不对的报错长这样：`can't open file 'C:\Users\…\tools\send_ui_via_adb.py'`。
> **`adb shell …` 单行不受工作目录影响**（它只用 adb），只有 `python tools/…` 那几行需要 cd。

> 两个脚本的默认值不同，注意别踩：
> `tools/send_ui_via_adb.py` 默认是裸 `adb`（依赖 PATH），**必须**带 `--adb $ADB` 或自己配 PATH；
> `tools/check_ui_end_to_end.py` 默认已经写死上面那个路径，可以不带。

**两种命令形式**：Python 工具（`send_ui_via_adb.py`）会**严格校验回包**并在成功时打印收发
十六进制，**推荐用它**；`adb shell …` 单行只负责发送、**看不到回包**，用于现场快速手敲。

---

## 1. 前置（按顺序，缺一条后面全不通）

### 1.1 位流：OSD1 尺寸必须是 272

菜单承载路（OSD1）的位图尺寸是**综合期参数**，必须与固件的 `OSD_CANVAS_W/H`（272×208）一致。
当前板上如果是旧位流（544），菜单会被**横向拉伸**、位置也不对。

```bash
export EFINITY_HOME="H:/Efinity/2026.1"     # 不设这一句，efx_map/efx_pnr 一启动就崩
bash work_syn/run_efx_map.sh
bash work_pnr/run_efx_pnr_formal.sh          # 正式版：用 outflow/ivlab239_c.vdb
bash work_pnr/run_efx_pgm.sh                 # 生成 outflow/ivlab239_c.hex
```

然后用 Efinity EDB Programmer（USB JTAG）烧写。**确认用的是新网表**：`outflow/ivlab239_c.route.rpt`
的 `GBUFCE Assignments` 表里**不应出现** `edb_top_autodbg_inst__/bscan_TCK_buffered`。
（`run_efx_pnr.sh` 是调试版、用的是三天前的 `.dbg.vdb`，别拿它出正式位流。）

### 1.2 固件：两条加载路径

#### 1.2a 烧进 flash（掉电自启，交付与验收走这条）

位流里烤着一份 SPI-flash bootloader —— 它是 SoC 那 4 KB 片上 ROM 的初始化内容，
**CPU 地址 `0xF9000000`**（不是 `0x0`；复位向量由 `ip/riscv/riscv.v` 的
`IBusCachedPlugin_fetchPc_pcReg <= 32'hf9000000` 决定），上电后从 flash
`0x00380000` 搬 `0x1F000` 字节到 CPU `0x1000` 再跳过去。这三个数是 bootloader 与
固件之间的硬契约，写在
`embedded_sw/riscv/software/standalone/bootloader/src/bootloaderConfig.h:17-19`。

> **前置硬条件：ROM 里那份 bootloader 必须是用本仓库的 BSP 编出来的。**
> 详见 §1.2c —— 这里踩过一个大坑：Efinity IP 默认灌进去的是**另一份 SoC 地址映射**的
> bootloader，它轮询的 SPI 地址在本 SoC 里根本不存在，会导致 flash 自启**永远失败**。

满足前置后，把位流与固件合并成一个镜像烧进 flash：

Git Bash：

```bash
bash work_pnr/run_merge_flash_image.sh      # 编固件 + 合并 + 逐字节复验
# → outflow/ivlab239_boot.hex（约 11 MB）与 outflow/ivlab239_boot.rpt
```

PowerShell（这是 bash 脚本，PowerShell 里要经 bash.exe 转发）：

```powershell
& "C:\Program Files\Git\bin\bash.exe" H:/Project/ivlab-239/work_pnr/run_merge_flash_image.sh
```

> **不必设 `EFINITY_HOME`** —— 本脚本自带默认值 `H:/Efinity/2026.1`，并会自己补上
> `EFXPGM_HOME`/`EFXDBG_HOME`/`PYTHONHOME` 和 RISC-V IDE 的工具链（缺哪样补哪样）。
> 但 §1.1 那三条 `efx_*` 脚本必须显式 `export EFINITY_HOME`，否则一启动就崩。
>
> 路径写全就不用管当前目录。脚本*内部*虽用绝对路径，但**传给 bash 的脚本路径**
> 是按 cwd 解析的 —— 在别处敲相对路径会报 `No such file or directory`。
> 上面 Git Bash 那段同理，要么先 `cd H:\Project\ivlab-239`。

再用 Efinity Programmer（USB JTAG）烧 `outflow/ivlab239_boot.hex`（**active 模式**）。
烧完**整机断电重上电**，不接调试器、不下载固件，直接跑 §5 的验收。

> **重上电后要等几秒再发第一条命令 —— 期间无应答是预期的，不是没起来。**
> 从加电到"软核开始听串口"要串完这几段：HyperRAM 校准（稳定视频本身约 2 秒）
> → RTL 的 `RISCV_BOOT_DELAY_CYCLES`（校准通过后再等 5 ms 才放 CPU）
> → bootloader 从 SPI flash 搬 124 KB 到 HyperRAM
> → 固件渲染并提交菜单 → `proto_uart_init()` + `isr_init()`（**最后一步**）。
> 在最后一步之前发命令，软核还没开始收 —— 实测就是"空应答"，很容易误判成故障。
> 现象对照：菜单已经出现但命令不应答，就再等几秒重发；一直不应答才去查 §6。

> **`0x1000` 不是片上 RAM。** 它是 SoC 的 DDR 窗口（`soc.h:87 SYSTEM_DDR_BMB 0x1000`，
> 大小 64 MB），也就是外挂的 HyperRAM。位流里唯一的片上 RAM 是 **CPU `0xF9000000`**
> 那 4 KB（`soc.h:67 SYSTEM_RAM_A_CTRL`），只装 bootloader。
> 这两处地址（`0x0` 与 `0xF9000000`）以前记反过，会让人误以为固件跑在 BRAM 里、
> 也会让人以为复位向量是 `0x0`。以 `ip/riscv/riscv.v` 的
> `IBusCachedPlugin_fetchPc_pcReg <= 32'hf9000000` 为准。

> **不接调试器时启动横幅是看不到的** —— 但原因不是"没人打印"，而是 semihosting 的
> `ebreak` 会把核**挂住**（见 §1.2d）：固件会停在第一次真正输出日志的地方，
> 后面的 `proto_uart_init()` / `isr_init()` 都轮不到，于是菜单有、ADB 全哑。
> **所以"不接调试器也能跑"的前提，是先按 §1.2d 把日志从 semihosting 上摘掉。**

#### 1.2b 开发期：openocd + gdb 下载（改了固件要快速迭代时用）

不重烧 flash，直接把 ELF 灌进 CPU `0x1000`。**掉电即失效**，每次上电都要重来。

```bash
make BSP=efinix/EfxSapphireSoc               # 工具链在 H:/Efinity/efinity-riscv-ide-2026.1/{toolchain,build_tools}/bin
```

再按 `ivlabSoftCore_ti.launch` 的等价手敲流程（终端 1 起 OpenOCD，终端 2 用 gdb）：

**先设 `workspace_loc`** —— `debug_ti.cfg:101` 要读它来拼 `$workspace/cpu$i.yaml`
（`cpu0.yaml` 在 `embedded_sw/riscv/` 下）。**在 Eclipse IDE 里跑时这个变量由 Eclipse
提供，纯 shell 里必须自己设**，否则 OpenOCD 直接退出并报
`can't read "::env(workspace_loc)": no such element in array`。

```powershell
$env:workspace_loc = "H:/Project/ivlab-239/embedded_sw/riscv"   # Git Bash 用 export workspace_loc=...
& "<efinity-riscv-ide>\openocd\bin\openocd.exe" `
  -f 'H:\Project\ivlab-239\embedded_sw\riscv\bsp\efinix\EfxSapphireSoc\openocd\ftdi_ti.cfg' `
  -f 'H:\Project\ivlab-239\embedded_sw\riscv\bsp\efinix\EfxSapphireSoc\openocd\debug_ti.cfg'
```

> 上面这句命令里**没有** `-c 'set bsp_loc ...'`：`bsp_loc` 在 `openocd/` 整个目录里
> 没有任何 cfg 引用它（原来的写法是从 Eclipse 的调用里抄来的，属于无用的残留）。

```bash
riscv-none-elf-gdb embedded_sw/riscv/software/standalone/application/ivlabSoftCore/build/ivlabSoftCore.elf
(gdb) set mem inaccessible-by-default off
(gdb) set arch riscv:rv32
(gdb) target remote :3333
(gdb) monitor arm semihosting_redirect tcp 50051 all   # 调试打印从这条通道出来
(gdb) load
(gdb) continue
```

#### 1.2c ROM 里的 bootloader 必须与本 SoC 匹配（掉电自启失败的头号原因）

**症状**：位流烧进 flash、固件也在 `0x380000`（Programmer verify 通过）、CVBS 有画面，
但**软核不应答、菜单不出现**；用 JTAG 单独下载位流 + GDB 下载固件却一切正常。

**判据**（一条就够）：用 OpenOCD 批量读 HyperRAM 与 ROM：

```powershell
$env:workspace_loc = "H:/Project/ivlab-239/embedded_sw/riscv"
& "H:\Efinity\efinity-riscv-ide-2026.1\openocd\bin\openocd.exe" `
  -f 'H:\Project\ivlab-239\embedded_sw\riscv\bsp\efinix\EfxSapphireSoc\openocd\ftdi_ti.cfg' `
  -f 'H:\Project\ivlab-239\embedded_sw\riscv\bsp\efinix\EfxSapphireSoc\openocd\debug_ti.cfg' `
  -c "halt" -c "reg pc" -c "mdw 0xf9000000 3" -c "mdw 0x1000 8" -c "shutdown"
```

- `mdw 0x1000 8` 若是 `aaaaaaaa` 一类（**不是**固件内容）→ bootloader 没搬成功
- `mdw 0xf9000000 3` 应读到 ROM 内容，可与下面对账

**根因**：`ip/riscv/settings.json` 里 `HexFile_PathEnable = "1'b0"` —— 从没指定用哪份
bootloader，于是 Efinity 灌了它**自己的默认 init**。那份是按**另一份 SoC 地址映射**
编的，地址对不上（实例）：

| 外设 | 本 SoC（`bsp/.../include/soc.h`） | Efinity 默认灌进去的那份 |
|---|---|---|
| SPI0 | `0xF8006000` | `0xF8014000` ✗ |
| CLINT | `0xF8B00000` | `0xF8B0C000` ✗ |

bootloader 的流程是"配 SPI → 轮询 `0xF8014004` 的状态位非 0 → 读 flash"。未译码地址
恒返回 0，于是**卡在轮询循环里死等**，固件一个字节都搬不过来。（这一条可以从 ROM 内容
直接看出来：把它反解成 binary、用 `riscv-none-elf-objdump -D -b binary -m riscv:rv32`
反汇编即可。）

**修法**（bootloader 是位流的一部分，必须重新综合）：

```bash
# 1) 用本仓库的 BSP 编 bootloader（它的 bootloaderConfig.h 用 SYSTEM_SPI_0_IO_CTRL，即本 SoC 的真地址）
cd embedded_sw/riscv/software/standalone/bootloader
make BSP=efinix/EfxSapphireSoc            # → build/bootloader.bin

# 2) 生成 ROM 初始化文件（README-binGen.txt 就是为这件事写的）
#    -s 4096 对应本 SoC 的 OCRSize=4096；生成的每份是 1024 行
cd ../../../tool
python3 binGen.py -b ../software/standalone/bootloader/build/bootloader.bin -f 0 -s 4096
# → rom/EfxSapphireSoc.v_toplevel_system_ramA_logic_ram_symbol{0..3}.bin

# 3) 覆盖 ip/riscv/ 下那 4 份（**注意**：binGen 在 Windows 上以文本模式写文件，
#    会带 CRLF，每份 10240 字节；仓库原有的都是 LF、9216 字节。要转成 LF 再放进去，
#    否则每行末尾多一个 CR。）
```

然后重新综合出位流（§1.1 那三条 `efx_*` 脚本）→ 重新合并 → 重烧 flash。

> 综合只读 **`ip/riscv/`** 下那 4 份（`ip/riscv/riscv.v:10012-10015` 的 `$readmemb`，
> 综合日志里会打印实际路径）。`ip/riscv/` 下另有 `Ti60F225_devkit/`、`T120F324_devkit/`、
> `Testbench/`、`source/hardware/netlist/` 四份副本，改它们没用。
>
> 回滚：那 4 份都是 git 跟踪的，`git checkout -- ip/riscv/EfxSapphireSoc*v_toplevel_system_ramA_logic_ram_symbol*.bin` 即可。

#### 1.2d 不接调试器时 semihosting 会把核挂住（掉电自启的头号拦路虎）

**症状**：菜单**出现**（CVBS 正常）、**但 ADB 命令全部空应答**（`RuntimeError: UI命令失败：` 后为空）；
同一份位流、同一份固件，**接上调试器（JTAG 下载那套）就一切正常**。

**根因**（固件侧，与 flash 自启无关，只是以前总插着调试器所以没暴露）：
日志走 semihosting，底层是 `slli x0,x0,0x1f; ebreak; srai x0,x0,7`
（`bsp/efinix/EfxSapphireSoc/include/semihosting.h:97-99`，`call_host()`）。
**本核在没有调试器时，这条 `ebreak` 不会变成断点异常，而是把核挂住等调试器** ——
于是固件永远停在第一次真正输出日志的地方。

**为什么菜单照样出来**：`main()` 的顺序是
`osd_engine_boot()`（清画布 / 渲染 / 提交**菜单**）→ 启动横幅（`app_log` **只入队，不输出**）
→ `osd_boot_diag()` → `diag_drain()` → `app_log_flush()` → `bsp_printf` → **第一次 semihosting**。
菜单排在第一次真正输出之前，所以它画得出来；而 `proto_uart_init()` / `isr_init()`
（协议端点）排在**之后**，永远轮不到 —— ADB 因此全哑。

**判据**（两条读数定死，不用猜；`resume` 不能省，否则核停在 halt 状态、读数永远不变）：

```
-c "halt" -c "mdw 0xa5d8 1" -c "mdw 0xa5b8 1" -c "resume" -c "shutdown"
```

| 地址 | 符号 | 含义 |
|---|---|---|
| `0xA5D8` | `s_semihosting_breakpoints` | **恒为 0** → `trap()` 从未被调用 → `ebreak` 没进异常，是把核挂住了（就是本条）|
| `0xA5B8` | `s_idle_spins` | 恒为 0 → 主循环没跑到 |

两者一起为 0、而菜单能看到 → 锁定在"第一次 semihosting 输出"。

> **别用非 4 字节对齐的 `mdw` 地址**：OpenOCD 会把它**向下对齐**到 4 字节边界，
> 读到的不是你要的那个字（`mdw 0xa582` 实际读的是 `0xA580`——这个坑让我误判过一次）。

**修法（已实现）：加一个构建开关 `LOG`，烧 flash 的那份用 `LOG=off`。**

- `application/ivlabSoftCore/makefile`：`LOG ?= semihosting`；`LOG=off` 时加 `-DAPP_LOG_OFF`
- `src/app_log.c`：`app_log_flush()` 里**唯一**那次 `bsp_printf` 被 `#ifndef APP_LOG_OFF`
  包住 —— 只跳过硬件写，其余队列逻辑照旧（`app_log_pending()` 语义不变，调用方的
  排空循环照常结束）
- `work_pnr/run_merge_flash_image.sh` 固定用 `LOG=off` 编 —— **烧 flash 的那份必须自带这个开关**

效果（实测）：`LOG=off` 的 `.bin` 里 `ebreak` 出现 **0 次**（`LOG=semihosting` 是 1 次），
即整条 semihosting 序列被删掉、核不可能再被挂住；顺带因为不再引用 `bsp_printf`，
链接器丢掉了整套 printf 库，`.bin` 从 **38290 → 18370 字节**（RAM 占用 41% → 25%）。

**代价**：`LOG=off` 那份**看不到任何日志**。需要那串启动横幅/回读日志时，用默认
（`LOG=semihosting`）编、按 §1.2b 的 JTAG 流程跑同一份源码 —— 一个开关，两边都留着。

**判据**：烧完自启后，`mdw 0x5700 1` 应读到 `0x00004738`（`LOG=off` 固件；带 semihosting
的那份在同一地址是 `0x0000d7b7`）。随后**等几秒**（见 §1.2a 的时序说明再发命令 ——
`proto_uart_init()` 是启动链的最后一步），`send_ui_via_adb.py --query-view` 应返回冷启动锚点。

**已实测通过**（2026-10-08）：`LOG=off` + 修好的 ROM bootloader + 本 BSP 编的 bootloader，
烧 flash 后整机断电重上电、不接调试器，菜单出现、ADB 正常应答。

> **排查时用过的一套只读判据**（`LOG=off` 没有日志，这些内存读数就是替代品；
> 顺序不能省：`resume` 不加的话核停在 halt 状态，读数永远不变）：
>
> ```powershell
> & "...\openocd.exe" -f '...\ftdi_ti.cfg' -f '...\debug_ti.cfg' `
>   -c "halt" -c "mdw 0x57e0 12" -c "resume" -c "shutdown"
> ```
>
> 当时（`LOG=off`、18370 字节那版）这一段里比较有用的是：
> `0x57E8` = `s_idle_spins`（主循环每轮 +1）、`0x57F0`(2 字) = `s_last_rx_ticks`
> （收到字节时写入 CLINT 时刻）、`0x580C` = `s_frames_processed`、`0x581C` =
> proto 层的 `s_fifo_overflow_seen`。判读：**`s_idle_spins` 在增长 = 主循环在跑；
> `s_last_rx_ticks` 非 0/在变 = 收到过字节；`s_frames_processed` ≥1 = 完整帧解析过。**
>
> **这些地址是版本相关的**：固件一改（比如加 `LOG` 开关）整批 `.bss` 地址就平移，拿旧
> 地址读会读到别的变量。每次都从 `build/ivlabSoftCore.map` 重新取（符号名 → 紧随其后的
> `0x...` 那行就是地址）。这个坑我踩过一次：`mdw 0xa582` 读到的其实是 `0xA580` 那个字。

> **切换 `LOG` 必须能触发重编**：`LOG` 只改 CFLAGS、不改源文件时间戳，make 察觉不到切换，
> 会拿旧 `.o` 直接链接 —— "用 `LOG=off` 编却拿到带 semihosting 的固件"就是这么来的。
> `makefile` 用 `build/.log_mode` 这个 stamp 记录上次的模式、**内容不符才重写它**，
> 于是 mtime 变新、所有 `.o` 重编；模式没变则一动不动，增量编译不受影响。
> **别改成"每个模式一个 stamp 文件名"**（`build/.log_mode_$(LOG)`）—— 切回去时那个文件
> 早已存在且 mtime 比 `.o` 旧，make 会认为无需重编。这个坑实测踩到过。

> 澄清一处曾经的误判：`src/main.c` 的 `trap()` 里"跳过 ebreak（`mepc += 4`）"那段
> **不是**这个问题的解 —— 实测 `s_semihosting_breakpoints` 恒为 0，说明 semihosting 的
> `ebreak` 根本没进 `trap()`。那段只对"代码里真的出现 ebreak 断点异常"有意义，保留即可。
>
> 另外 `trap()` 末尾"其它异常…然后继续运行"同样没推进 `mepc`，真出非法指令之类的
> 故障时会原地打转（与注释意图不符）。跳过一条不认识的非法指令未必比停住更好，故未改。

### 1.3 adb 连接

```powershell
& $ADB devices          # 输出里必须有一行以 \tdevice 结尾，否则后面全部超时
```

`/dev/ttyS1` 的 raw 模式由脚本内部设置（`stty -F /dev/ttyS1 115200 cs8 -cstopb -parenb -crtscts raw -echo`）；
只有手敲 `adb shell` 单行时才需要自己带那串 `stty`。

### 1.4 菜单窗口位置（可选核对）

菜单窗口左上角在画面 **(left=32, top=128)**，尺寸 272×208（34 列 × 8 px，13 行 × 16 px）。
这两个值是固件里的 `OSD_MENU_LEFT/OSD_MENU_TOP`，**运行期生效、改它只需重编固件、不用重出位流**。

---

## 2. 启动自检（不需要 adb）

**这一段走 JTAG semihosting，不是 adb/ttyS1** —— X2000 那侧读不到。没有 JTAG 就只能靠第 3 节的回包判断。

**固件是烧在 flash 里自启的（§1.2a）怎么复现这串横幅**：接上调试器但**绝不执行
`load`** —— `target remote :3333` 之后用 `monitor reset halt` + `continue`，让 CPU
重新从 ROM 起、由 bootloader 再从 flash 搬一次。这样看到的横幅才属于"从 flash 起来的
固件"；一旦 `load` 过，看到的就是 GDB 灌进去的那份，证明不了 flash 里的内容。
起 OpenOCD 前记得设 `workspace_loc`（见 §1.2b）。

**横幅本身不是可靠判据**（semihosting 那条通道不稳）。要判断"flash 自启到底走没走通"，
用更硬的判据 —— **看 PC 与内存**：

```
(gdb) monitor reset halt
(gdb) info registers pc      # 复位后 PC 应落在 ROM 里
(gdb) x/8xw 0x1000           # 此刻还没搬，内容应为"原样"
(gdb) continue               # 等 2~3 秒后 Ctrl-C 中断
(gdb) info registers pc      # 现在 PC 在哪：ROM / 0x1000 附近 / 异常处理
(gdb) x/8xw 0x1000           # 现在应变成固件的前 8 个字
```

`0x1000` 处固件的头 8 个字（小端）应为：
`0x0000a197 0xcd018193 0x0000b597 0x7e05ae23 0xf1402573 0x04050663 0x0000b517 0x7ec52503`。

- **`0x1000` 变了** → bootloader 搬运成功，故障在固件起跑之后（继续抓横幅看崩在哪）。
- **`0x1000` 没变** → ROM 里的 bootloader 没去搬 flash（或复位向量不在 ROM），
  整个 flash 自启的前提不成立。

固件上电后应打出（`main.c` 的启动横幅 + OSD 启动回读）：

```text
*** ivlabSoftCore ***
debug channel: semihosting (JTAG)
protocol: BB frame, categories 0x00 (mask) + 0x04 (UI)
osd: menu on OSD1 272x208 1bpp 8x16 cell, canvas A/B = 0xa40000 / 0xb40000
--- osd boot readback ---
osd regs: COMMAND(readback)=........ staged_g_en=...
osd regs: STATUS=................ commit_count=1 pending=... applied_g_en=...
osd regs: CANVAS=...
osd regs: ACTIVE=...                       <- 使能半字节只有第 1 路（菜单路）
osd route0: enable=0 buffer=A              <- 其余三路恒 0，这是预期
osd route1: enable=1 buffer=A              <- 菜单路：使能=1，缓冲随乒乓变化
osd route1 POS: last_written=00080020 readback=00000000 (W-only)
osd route1 CTRL: last_written=........ readback=00000000 (W-only)
osd blk A: nonzero=... setbits=... fnv1a=... first=...
osd blk B: nonzero=... setbits=... fnv1a=... first=...
osd probe: bytes_written(total)=...
osd probe: wr ........ <- ........
osd probe: read back ........ (MATCH)
osd probe: [in-bitmap] wr ........ <- ........
osd probe: [in-bitmap] read back now = ........
osd probe: sticky in-bitmap=........ out-bitmap=........ (wrote ........)
--- osd boot readback end ---
protocol endpoint: ENABLED on uart1 (base 0xf8002000)
```

**判据**（逐条都能对上才算这一段通过）。上面几行里的 `...` 是**值随现场而定**的字段
（`pending` 还是瞬态、可能刚好读到 1），别拿它们判 PASS/FAIL —— 只认下面这几条：

| 行 | 判据 | 不满足说明什么 |
|---|---|---|
| `protocol endpoint: ENABLED …` | 必须是 ENABLED。若是 `UNAVAILABLE`，SoC 没生成 uart1，**后面所有命令必然超时** | 位流/SoC IP 的问题，不是接线 |
| `osd route1 POS: last_written=00080020` | **必须是 `00080020`** = `(top 128 << 12) \| left 32` | 值不对 = 载入的还是旧固件（旧值是 `00010020` = top 16） |
| `osd route1: enable=1` | 菜单路使能。`0` = 菜单被藏起来了 | 用第 3.3 节重新显示 |
| `osd route0/2/3: enable=0` | 其余三路恒 0，**预期**（固件只写菜单路） | 没有内容不是故障 |
| `osd blk A/B: nonzero=` | 两块都应非 0（首屏已渲染并落盘） | 0 = 渲染/写内存没发生 |
| `osd probe: … (MATCH)` | 必须 MATCH | `(NO MATCH)` = HyperRAM 读写通路问题 |

**自检的副作用**：`[in-bitmap]` 那一步会往位图里写 4 字节（32 个白像素），
所以**上电后菜单区可能出现一小段白线** —— 这是自检探针，不是菜单内容。
随便发一条第 3 节的 `--view` 命令重画一屏就会消失。

---

## 3. 正向命令（能应答、能改变画面）

> 本节与后面所有 `python tools/…` 都假设工作目录是 `H:\Project\ivlab-239`（见 §0 的 `cd`）。

**最小充分集合**（时间紧就只跑这些）：

| # | 命令 | 为什么要它 |
|---|---|---|
| 1 | `--query-view` | 证明固件活着、协议端点通：18 字节回包，`status=0xFF` |
| 2 | `--view palette` | 切到**项数不同**的页（9 项 → 4 项），是最强的"画面真的变了"证据 |
| 3 | `--view root` | 切回来，证明不是静态残留 |
| 4 | `--view image --selected 0 --edit` + `--image-values 0 5 5 5` | **唯一能证明"像素真的变了"**（数值行重画） |
| 5 | `--query-view` | 回读必须与第 4 步一致（page=0x0100、编辑=1、值=[0,5,5,5]） |
| 6 | `--image-values 3 5 7 5` | **收尾复原**：脚本不幂等，`SET_VIEW` 不复位数值 |

**顺序原则**：先 query 建基线 → 每次写操作后立刻 query 回读 → 写与读成对出现 → 结尾复原。

三种成功应答（写命令都回 10 字节，`--query-view` 回 18 字节）：

| 命令 | 成功回包 |
|---|---|
| `SET_VIEW`（0x06） | `bb0004040602ff00c3aa` |
| `SET_IMAGE_VALUES`（0x07） | `bb0004040702ff37f3aa` |
| 失败（任一种写命令） | `SET_VIEW`: `bb0004040602001e33aa` / 数值: `bb0004040702002903aa` |

### 3.1 切页 + 选中项（19 条 = 固件已实现的全部条目位置）

每一页的 `--selected` 从 0 开始，超过该页条目数即失败（见第 4 节）。

| 动作 | Python 工具 | adb 单行 | 期望回包 | 画面上该看到什么 |
|---|---|---|---|---|
| `0x0000` sel=0 Image Setting | `python tools/send_ui_via_adb.py --adb $ADB --view root --selected 0` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x00\\x01\\x5C\\x06\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **MAIN MENU**，选中第 0 项（`Image Setting`） |
| `0x0000` sel=1 Image Mode | `python tools/send_ui_via_adb.py --adb $ADB --view root --selected 1` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x01\\x01\\x6F\\x37\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **MAIN MENU**，选中第 1 项（`Image Mode`） |
| `0x0000` sel=2 Zoom | `python tools/send_ui_via_adb.py --adb $ADB --view root --selected 2` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x02\\x01\\x3A\\x64\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **MAIN MENU**，选中第 2 项（`Zoom`） |
| `0x0000` sel=3 Function | `python tools/send_ui_via_adb.py --adb $ADB --view root --selected 3` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x03\\x01\\x09\\x55\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **MAIN MENU**，选中第 3 项（`Function`） |
| `0x0000` sel=4 Setting | `python tools/send_ui_via_adb.py --adb $ADB --view root --selected 4` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x04\\x01\\x90\\xC2\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **MAIN MENU**，选中第 4 项（`Setting`） |
| `0x0000` sel=5 Measure | `python tools/send_ui_via_adb.py --adb $ADB --view root --selected 5` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x05\\x01\\xA3\\xF3\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **MAIN MENU**，选中第 5 项（`Measure`） |
| `0x0000` sel=6 Zeroing | `python tools/send_ui_via_adb.py --adb $ADB --view root --selected 6` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x06\\x01\\xF6\\xA0\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **MAIN MENU**，选中第 6 项（`Zeroing`） |
| `0x0000` sel=7 Ballistic | `python tools/send_ui_via_adb.py --adb $ADB --view root --selected 7` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x07\\x01\\xC5\\x91\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **MAIN MENU**，选中第 7 项（`Ballistic`） |
| `0x0000` sel=8 Display Setting | `python tools/send_ui_via_adb.py --adb $ADB --view root --selected 8` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x00\\x00\\x08\\x01\\xD5\\xAF\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **MAIN MENU**，选中第 8 项（`Display Setting`） |
| `0x0100` sel=0 Image Enhance | `python tools/send_ui_via_adb.py --adb $ADB --view image --selected 0` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x00\\x01\\x2A\\xB2\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **IMAGE SETTING**，选中第 0 项（`Image Enhance`） |
| `0x0100` sel=1 Contrast | `python tools/send_ui_via_adb.py --adb $ADB --view image --selected 1` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x01\\x01\\x19\\x83\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **IMAGE SETTING**，选中第 1 项（`Contrast`） |
| `0x0100` sel=2 Image Brightness | `python tools/send_ui_via_adb.py --adb $ADB --view image --selected 2` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x02\\x01\\x4C\\xD0\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **IMAGE SETTING**，选中第 2 项（`Image Brightness`） |
| `0x0100` sel=3 Screen Brightness | `python tools/send_ui_via_adb.py --adb $ADB --view image --selected 3` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x03\\x01\\x7F\\xE1\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **IMAGE SETTING**，选中第 3 项（`Screen Brightness`） |
| `0x0100` sel=4 PIP > | `python tools/send_ui_via_adb.py --adb $ADB --view image --selected 4` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x04\\x01\\xE6\\x76\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **IMAGE SETTING**，选中第 4 项（`PIP >`，跳转行） |
| `0x0100` sel=5 Image Correction > | `python tools/send_ui_via_adb.py --adb $ADB --view image --selected 5` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x05\\x01\\xD5\\x47\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **IMAGE SETTING**，选中第 5 项（`Image Correction >`，跳转行） |
| `0x0200` sel=0 White Hot | `python tools/send_ui_via_adb.py --adb $ADB --view palette --selected 0` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x02\\x00\\x00\\x01\\xB1\\x6E\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **IMAGE MODE**，选中第 0 项（`White Hot`） |
| `0x0200` sel=1 Black Hot | `python tools/send_ui_via_adb.py --adb $ADB --view palette --selected 1` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x02\\x00\\x01\\x01\\x82\\x5F\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **IMAGE MODE**，选中第 1 项（`Black Hot`） |
| `0x0200` sel=2 Iron Red | `python tools/send_ui_via_adb.py --adb $ADB --view palette --selected 2` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x02\\x00\\x02\\x01\\xD7\\x0C\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **IMAGE MODE**，选中第 2 项（`Iron Red`） |
| `0x0200` sel=3 Rainbow | `python tools/send_ui_via_adb.py --adb $ADB --view palette --selected 3` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x02\\x00\\x03\\x01\\xE4\\x3D\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 切到 **IMAGE MODE**，选中第 3 项（`Rainbow`） |

### 3.2 编辑态（4 条，只对 IMAGE SETTING 的前 4 项有效）

`--edit` 置 `flags.bit1`。**只允许用在数值行**上（`0x0100` 的 sel 0..3）；用在别处会失败（见第 4 节）。

| 动作 | Python 工具 | adb 单行 | 期望回包 | 画面上该看到什么 |
|---|---|---|---|---|
| sel=0 进编辑态（Image Enhance） | `python tools/send_ui_via_adb.py --adb $ADB --view image --selected 0 --edit` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x00\\x03\\x0A\\xF0\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 该行进入编辑态（数值被框住/高亮） |
| sel=1 进编辑态（Contrast） | `python tools/send_ui_via_adb.py --adb $ADB --view image --selected 1 --edit` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x01\\x03\\x39\\xC1\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 该行进入编辑态 |
| sel=2 进编辑态（Image Brightness） | `python tools/send_ui_via_adb.py --adb $ADB --view image --selected 2 --edit` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x02\\x03\\x6C\\x92\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 该行进入编辑态 |
| sel=3 进编辑态（Screen Brightness） | `python tools/send_ui_via_adb.py --adb $ADB --view image --selected 3 --edit` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x03\\x03\\x5F\\xA3\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 该行进入编辑态 |

### 3.3 显示 / 隐藏（2 条）

**这是唯一能改菜单显隐的路径**（`flags.bit0`）。`--show`/`--hide` 做不到。

| 动作 | Python 工具 | adb 单行 | 期望回包 | 画面上该看到什么 |
|---|---|---|---|---|
| **隐藏菜单** | `python tools/send_ui_via_adb.py --adb $ADB --view image --selected 0 --hidden` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x00\\x00\\x3A\\x93\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | **菜单整块消失**，视频画面不受影响 |
| 重新显示 | `python tools/send_ui_via_adb.py --adb $ADB --view image --selected 0` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x00\\x01\\x2A\\xB2\\xAA" > /dev/ttyS1'` | `bb0004040602ff00c3aa` | 菜单回到 IMAGE SETTING |

### 3.4 图像数值（4 条）

合法范围：第 1 个（image_enhance）**0..5**，其余三个 **0..10**；四项一起提交，**任一项越界则整条失败、四个值全不变**。

| 动作 | Python 工具 | adb 单行 | 期望回包 | 画面上该看到什么 |
|---|---|---|---|---|
| `0 5 5 5`（改值） | `python tools/send_ui_via_adb.py --adb $ADB --image-values 0 5 5 5` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x07\\x00\\x00\\x05\\x05\\x05\\x4D\\x27\\xAA" > /dev/ttyS1'` | `bb0004040702ff37f3aa` | 在 IMAGE SETTING 页看到四个数值变 `[0][5][5][5]`（**画面亮度不变**，见下注） |
| `3 5 7 5`（**收尾复原**） | `python tools/send_ui_via_adb.py --adb $ADB --image-values 3 5 7 5` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x07\\x00\\x03\\x05\\x07\\x05\\xB0\\x99\\xAA" > /dev/ttyS1'` | `bb0004040702ff37f3aa` | 数值回到 `[3][5][7][5]`（上电初值） |
| `0 0 0 0`（下边界） | `python tools/send_ui_via_adb.py --adb $ADB --image-values 0 0 0 0` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x07\\x00\\x00\\x00\\x00\\x00\\x09\\x87\\xAA" > /dev/ttyS1'` | `bb0004040702ff37f3aa` | 数值变 `[0][0][0][0]` |
| `6 5 5 5`（越界 → **预期失败**） | `python tools/send_ui_via_adb.py --adb $ADB --image-values 6 5 5 5` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x07\\x00\\x06\\x05\\x05\\x05\\x6A\\xBE\\xAA" > /dev/ttyS1'` | `bb0004040702002903aa`（status=0x00） | **数值不变**（命令被拒） |

> **注（本期范围）**：这四个数值只影响菜单里的回显与 `--query-view` 的回读，
> **不接任何图像通路**。所以"改了数值、画面亮度/对比度没变"是**预期**，不是缺陷。
> 能看出像素变化的只有：切页、改选中项、改显隐、以及数值文本本身。

### 3.5 回读（1 条）

| 动作 | Python 工具 | adb 单行 | 期望回包 | 判据 |
|---|---|---|---|---|
| `--query-view` | `python tools/send_ui_via_adb.py --adb $ADB --query-view` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x03\\x04\\x08\\x00\\x55\\x69\\xAA" > /dev/ttyS1'` | 18 字节（见下表） | **回读须与上一条写命令一致**，否则那条写命令没真正生效 |

请求帧：`bb00030408005569aa`（回包恒为 18 字节，body = `04 08 02 FF` + 状态 + CRC）。

回包字段（`body[4..11]`，大端）：

| 字段 | 偏移 | 说明 |
|---|---|---|
| `page_id` | body[4:6] | 当前页 |
| `selected_item` | body[6] | 当前选中项 |
| `flags` | body[7] | bit0=显示 bit1=编辑态；**保留位不会出现在这里** |
| 四个数值 | body[8:12] | image_enhance / contrast / image_brightness / screen_brightness |

典型状态下的完整回包（可逐字节对）：

| 状态 | 预期回包 |
|---|---|
| 上电冷启动 | `bb000c040802ff0000000103050705eea2aa` |
| `--view palette` 之后 | `bb000c040802ff02000001030507056104aa` |
| `--view image --selected 0 --edit` 之后 | `bb000c040802ff0100000303050705edf2aa` |
| `--image-values 0 5 5 5` 之后 | `bb000c040802ff0100000300050505104caa` |

---

## 4. 负向用例（两种"失败"必须分开看）

**第一种：超时**（子项 `0x01`–`0x05`）。固件只解析、不应答、也不改变状态 —— 这是设计，不是故障。

| 命令 | 现象 |
|---|---|
| `--show` / `--hide` / `--key up|down|enter|back` / `--status` / `--clear` / `--marker X Y` | **没有任何回包**；`send_ui_via_adb.py` 会因为超时抛 `CalledProcessError`（脚本用 `check=True`，默认 5 秒） |

改显隐请用 3.3 节的 `--view … [--hidden]`。

**第二种：回 `status=0x00`**（不超时，10 字节应答）。三种情况，都**不改变当前状态**：

| 动作 | Python 工具 | adb 单行 | 期望回包 | 状态是否变化 |
|---|---|---|---|---|
| 未实现页 `0x0300` | `python tools/send_ui_via_adb.py --adb $ADB --view zoom` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x03\\x00\\x00\\x01\\xC7\\xDA\\xAA" > /dev/ttyS1'` | `bb0004040602001e33aa` | 不变 |
| `sel` 越界（IMAGE MODE 只有 4 项） | `python tools/send_ui_via_adb.py --adb $ADB --view palette --selected 4` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x02\\x00\\x04\\x01\\x7D\\xAA\\xAA" > /dev/ttyS1'` | `bb0004040602001e33aa` | 不变 |
| 在非数值行请求编辑（IMAGE MODE 无数值行） | `python tools/send_ui_via_adb.py --adb $ADB --view palette --edit` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x02\\x00\\x00\\x03\\x91\\x2C\\xAA" > /dev/ttyS1'` | `bb0004040602001e33aa` | 不变 |
| 在跳转行请求编辑（`PIP >` 是第 4 项） | `python tools/send_ui_via_adb.py --adb $ADB --view image --selected 4 --edit` | `adb shell 'stty -F /dev/ttyS1 115200 raw -echo & echo -ne "\\xBB\\x00\\x07\\x04\\x06\\x00\\x01\\x00\\x04\\x03\\xC6\\x34\\xAA" > /dev/ttyS1'` | `bb0004040602001e33aa` | 不变 |

`status` 是二值的（0xFF/0x00），**失败的具体原因不在回包里**，要看 JTAG 侧的调试日志。

> **保留位**：`flags` 的 bit2–bit7 由固件**静默丢弃** —— 发非 0 不算失败、也不会被回读到。
> 上位机侧"应置 0"是约定，不是校验。

---

## 5. 一键验收（`tools/check_ui_end_to_end.py`）

第 3 节那些命令的自动化版本，跑完打印一张记录表。

```powershell
# 1) 离机自检：不接板子，只校验 6 条已知好帧的构造是否与固件口径一致
python tools/check_ui_end_to_end.py --dry-run

# 2) 上板跑（默认 adb 路径就是 H:/Project/1280图传测试/platform-tools/adb.exe）
python tools/check_ui_end_to_end.py
```

它的检查顺序（任一步失败即中止并返回退出码 1，成功返回 0）：

1. `QUERY_VIEW` 建基线（**只记录、不断言** —— 脚本不幂等）；
2. `SET_VIEW 0x0200` 切到调色板页；回读 page=0x0200、sel=0、显示=1、编辑=0；
3. `SET_VIEW 0x0100 --selected 0 --edit`；回读编辑=1；
4. `SET_IMAGE_VALUES 0 5 5 5`；回读四值 = [0,5,5,5]、页与编辑态不变；
5. **负向**：`--view palette --edit` 必须被拒（`status=0x00`）、状态不变；
6. **负向**：`--view zoom` 必须被拒（固件里没这页）、状态不变；
7. 收尾 `--image-values 3 5 7 5` 复原。

注意两条：`--timeout` **不得小于 3 秒**（成功应答要等画布提交后才发）；
`--dry-run` 不需要板子、也不需要 adb，是改脚本后的第一道自检。

**它同时是"掉电自启"的验收**（§1.2a 烧完 flash 后这么用）：整机断电重上电，
**不接调试器、不下载固件**，直接跑 `python tools/check_ui_end_to_end.py`。
能跑过就说明固件确实是从 flash 冷启动起来的 —— 因为这个脚本**不幂等**，
它依赖 `ui_init()` 的四个数值初值 `[3,5,7,5]`（只在上电初始化时存在，
`SET_VIEW` 不复位它们，见脚本文件头第 ③ 条）。若固件没真的重新启动，
基线那一步就对不上。

---

## 6. 现象 → 归因

| 现象 | 先查什么 | 依据/判据 |
|---|---|---|
| **完全无应答**，但 JTAG 上有启动横幅 | ① 是不是 `0x01`–`0x05` 这类本就不应答的命令；② 固件有没有真的 load（`protocol endpoint: ENABLED`）；③ 位流的 `rtl_mask_mode` 是不是被改成 `1'b1`（那样软核收不到 UART，**全哑是预期**）；④ X2000 侧 tty 丢字节 | 有横幅 = 固件在跑；`stats:` 行里的 `fifo_ovf` / `ring_drop` 都是 0 却仍丢 → 丢失在 FPGA 之外（X2000 侧） |
| **没有启动横幅** | ① 烧在 flash 里自启且**没接调试器** —— 这是**正常**的，横幅走 semihosting，见 §1.2a；② 接了调试器还没下载（`load` 或 flash 里没固件）；③ SoC 没生成 uart1 | 见 §1.2a / §1.2b / §2 |
| 菜单出现但**宽度不对 / 被拉伸 / 位置不对** | **位流与固件不配套**：位流 OSD1 还是旧的 544，固件是 272 | §1.1；回读 `CANVAS` 只有画面尺寸，位图尺寸回读不到，靠重烧位流 |
| 菜单**斜切/错行/右侧花屏** | 同上：固件按 **34 字节/行** 写，RTL 若按 68 字节/行 读，整块错位 | 同一根因，重烧 272 位流 |
| 字形/间距不对、显示 `?` | 字符格与字库不一致，或字库缺字形 | `OSD_GLYPH_W/H` 为 8×16；缺字形会就地归一为 `?`；`python tools/test_font_table.py` |
| 菜单区出现**一小段白线** | 启动自检的位图内探针 | §2 末注；发一条 `--view` 重画即消失 |
| **回包成功但画面没变** | ① 当前页能否显示该内容（数值只在 IMAGE SETTING 页可见）；② 回读是否与命令一致；③ 启动自检里 `osd blk` 的非零字节数有没有变 | §3.5 |
| 菜单**半页/撕裂** | 不应出现 | 整页写完、提交之后才回 ACK |
| 菜单**不见了** | `flags.bit0` 被置 0（上次发了 `--hidden`） | 发一条不带 `--hidden` 的 `--view` 即恢复 |

---

## 7. 收尾复位

测完把板子留在已知状态（`SET_VIEW` **不会**复位数值，脚本不幂等）：

```powershell
python tools/send_ui_via_adb.py --adb $ADB --image-values 3 5 7 5    # 数值回到上电初值
python tools/send_ui_via_adb.py --adb $ADB --view root               # 回到主菜单第 0 项
python tools/send_ui_via_adb.py --adb $ADB --query-view              # 应回到 bb000c040802ff0000000103050705eea2aa
```

---

## 附录 A：报文格式速查

```text
BB | body_len:u16BE | category | subcommand | type | payload | crc16:u16BE | AA
```

- `category = 0x04`（UI）；写命令 `type = 0x00`，应答 `type = 0x02`；
- `body_len` 含 3 字节头（category/sub/type），即 `body_len = 3 + len(payload)`；
- CRC = CRC-16/CCITT，初值 `0x0000`，多项式 `0x1021`，覆盖完整 body；
- 成功应答 body = `04 | sub | 02 | FF`（10 字节整帧）；`QUERY_VIEW` 的 body 12 字节（18 字节整帧）。

| 子项 | 名称 | payload | 应答 |
|---|---|---|---|
| `0x01` | ui-show-hide | 1 字节 | **不应答** |
| `0x02` | ui-key | 1 字节 | **不应答** |
| `0x03` | ui-status | 9 字节 | **不应答** |
| `0x04` | ui-clear | 0 字节 | **不应答** |
| `0x05` | ui-range-mark | 4 字节 | **不应答** |
| `0x06` | SET_VIEW | `page_id:u16BE \| sel:u8 \| flags:u8` | 10 字节 |
| `0x07` | SET_IMAGE_VALUES | 4 字节 | 10 字节 |
| `0x08` | QUERY_VIEW | 无 | **18 字节** |

## 附录 B：26 个规格页 —— 哪些在固件里

`SET_VIEW` 帧一律是 `page_id + sel + flags` 三个字段，所以**只需换 page_id**。
下表给 sel=0、`flags=0x01`（显示、非编辑）的帧；`sel` 上限按"固件已实现"列。

| page_id | `--view` 键 | 规格页名 | 固件是否实现 | SET_VIEW(sel=0) 帧 | 预期回包 |
|---|---|---|---|---|---|
| `0x0000` | `root` | 一级菜单 | **是**（sel 0..8） | `bb0007040600000000015c06aa` | `bb0004040602ff00c3aa` |
| `0x0100` | `image` | 图像设置 | **是**（sel 0..5） | `bb0007040600010000012ab2aa` | `bb0004040602ff00c3aa` |
| `0x0101` | `image-pip` | 画中画 | **否** | `bb0007040600010100011d82aa` | `bb0004040602001e33aa` |
| `0x0102` | `image-correction` | 图像校正 | **否** | `bb00070406000102000144d2aa` | `bb0004040602001e33aa` |
| `0x0200` | `palette` | 调色板 | **是**（sel 0..3） | `bb000704060002000001b16eaa` | `bb0004040602ff00c3aa` |
| `0x0300` | `zoom` | 电子变倍 | **否** | `bb000704060003000001c7daaa` | `bb0004040602001e33aa` |
| `0x0400` | `functions` | 功能 | **否** | `bb00070406000400000196f7aa` | `bb0004040602001e33aa` |
| `0x0401` | `functions-wifi` | WiFi 设置 | **否** | `bb000704060004010001a1c7aa` | `bb0004040602001e33aa` |
| `0x0402` | `functions-moment` | 拍摄时刻 | **否** | `bb000704060004020001f897aa` | `bb0004040602001e33aa` |
| `0x0500` | `settings` | 系统设置 | **否** | `bb000704060005000001e043aa` | `bb0004040602001e33aa` |
| `0x0501` | `settings-language` | 语言 | **否** | `bb000704060005010001d773aa` | `bb0004040602001e33aa` |
| `0x0502` | `settings-time` | 时间和日期 | **否** | `bb0007040600050200018e23aa` | `bb0004040602001e33aa` |
| `0x0503` | `settings-buttons` | 按键分配 | **否** | `bb000704060005030001b913aa` | `bb0004040602001e33aa` |
| `0x0504` | `settings-auto-off` | 自动关机 | **否** | `bb0007040600050400013c83aa` | `bb0004040602001e33aa` |
| `0x0505` | `settings-pixels` | 坏点修复 | **否** | `bb0007040600050500010bb3aa` | `bb0004040602001e33aa` |
| `0x0600` | `measurement` | 测量 | **否** | `bb0007040600060000017b9faa` | `bb0004040602001e33aa` |
| `0x0601` | `measurement-color` | 光标颜色 | **否** | `bb0007040600060100014cafaa` | `bb0004040602001e33aa` |
| `0x0700` | `zeroing` | 校准 | **否** | `bb0007040600070000010d2baa` | `bb0004040602001e33aa` |
| `0x0701` | `zeroing-adjust` | 校准调整 | **否** | `bb0007040600070100013a1baa` | `bb0004040602001e33aa` |
| `0x0702` | `zeroing-group` | 校准组 | **否** | `bb000704060007020001634baa` | `bb0004040602001e33aa` |
| `0x0703` | `zeroing-style` | 准星样式 | **否** | `bb000704060007030001547baa` | `bb0004040602001e33aa` |
| `0x0704` | `zeroing-color` | 准星颜色 | **否** | `bb000704060007040001d1ebaa` | `bb0004040602001e33aa` |
| `0x0800` | `ballistics` | 弹道 | **否** | `bb000704060008000001d9c5aa` | `bb0004040602001e33aa` |
| `0x0801` | `ballistics-color` | 弹道标记颜色 | **否** | `bb000704060008010001eef5aa` | `bb0004040602001e33aa` |
| `0x0900` | `display` | 显示设置 | **否** | `bb000704060009000001af71aa` | `bb0004040602001e33aa` |
| `0x0901` | `display-move` | 画面移动 | **否** | `bb0007040600090100019841aa` | `bb0004040602001e33aa` |

## 附录 C：本文的命令从哪来

- 所有帧的十六进制都由 `tools/send_ui_via_adb.py` 的 `packet()`/`crc16()` **现算**，
  其中 6 条与 `tools/check_ui_end_to_end.py` 的 `KNOWN_GOOD` 逐字节相同（后者含一条**上板实测过的**硬件锚点）。
  **不要手改 CRC**：改 page/sel 时用脚本生成，别手抄。
- 页面文字、条目数、`sel` 范围、可编辑行来自固件场景表（3 页 19 项）。
- 已知的文档/注释过期点：`docs/adb_test_commands.md` 的 26 页俄文清单（条目文字与数目都按规格写，
  与固件的 3 页不符）、`docs/x2000_ui_protocol.md` §4（规格 ID 表，未标注实现范围）。
  发现别的过期口径请一并回报。
