# CLAUDE.md

本文件为 Claude Code 在此代码仓库中工作时提供核心指导。详细技术参考见 `docs/` 目录。

## 项目概述

基于 Ti60F225 的 FPGA 视频处理系统：BT.1120 1280×1024@30Hz 输入 → 电子变倍 + 热点追踪 → 双三次缩放 → PAL BT.656/CVBS 输出 + DVP 输出。

**工具链**：Efinix Efinity 2025.2.288.4.15（也适用于 2026.1）

**关键约束**：实时视频管线。帧边界、时钟域跨越和 ready/valid 流控至关重要。破坏视频时序意味着丢帧。

## 构建命令

使用易灵思IDE进行编译

### 位流 + 软核固件 → 单一 flash 镜像（掉电自启）

**`work_*/run_*.sh` 都是 bash 脚本** —— PowerShell 里 `export` 和 `bash` 都不认
（分别报 `无法将"export"项识别为 cmdlet`、`无法将"bash"项识别为 cmdlet`）。
按你所在的 shell 二选一：

PowerShell：

```powershell
$env:EFINITY_HOME = "H:/Efinity/2026.1"
& "C:\Program Files\Git\bin\bash.exe" H:/Project/ivlab-239/work_pnr/run_merge_flash_image.sh
```

Git Bash：

```bash
export EFINITY_HOME="H:/Efinity/2026.1"     # 不设则 efx_* 一启动就崩
bash work_syn/run_efx_map.sh
bash work_pnr/run_efx_pnr_formal.sh          # 正式版：用 outflow/ivlab239_c.vdb
bash work_pnr/run_efx_pgm.sh                 # → outflow/ivlab239_c.hex（active 模式）
bash work_pnr/run_merge_flash_image.sh       # 编固件 + 合并 + 逐字节复验
                                             # → outflow/ivlab239_boot.hex
```

> 两个脚本的环境要求不同：`run_merge_flash_image.sh` **不设 `EFINITY_HOME` 也能跑**
> （自带默认值 `H:/Efinity/2026.1`，并会自己补 `EFXPGM_HOME`/`EFXDBG_HOME`/
> `PYTHONHOME` 与 RISC-V IDE 的工具链）；上面三条 `efx_*` 则必须显式给
> `EFINITY_HOME`，否则一启动就崩。
>
> **脚本路径要不依赖当前目录，就写绝对路径。** 脚本*内部*全用绝对路径（所以
> 跑起来之后的读写与 cwd 无关），但**你传给 bash 的那个脚本路径本身**是相对 cwd
> 解析的 —— 在 `H:\Efinity\2026.1\bin` 下敲 `bash work_pnr/run_merge_flash_image.sh`
> 会报 `No such file or directory`。两种写法任选：先 `cd H:\Project\ivlab-239`，
> 或路径直接写全（正斜杠 `H:/...` 与反斜杠 `H:\...` 都行）。下面 Git Bash 那段
> 的相对路径同样要求 cwd 在仓库根目录。

再用 Efinity Programmer（USB JTAG）烧 `outflow/ivlab239_boot.hex`，然后**整机断电重上电**。

**flash 布局是 bootloader 定死的硬契约**（`bootloader/src/bootloaderConfig.h:17-19`）：
位流 `0x000000`，固件 `0x00380000`（上限 `0x1F000` = 124 KB），
上电由位流内那 4 KB 片上 ROM（CPU `0xF9000000`）的 bootloader 搬到 CPU `0x1000` 再跳转。
固件放错地址不会报错，只会起不来。

**另一个硬约束**：ROM 里那份 bootloader 必须是用本仓库 BSP 编的。
`ip/riscv/settings.json` 的 `HexFile_PathEnable=1'b0` 会让 Efinity 灌入**它自己的默认
bootloader**，那份按另一套 SoC 地址映射编（SPI 用 `0xF8014000`，本 SoC 是
`0xF8006000`），结果是**flash 自启永远失败而 JTAG 下载一切正常**。
改 ROM 初始化 = 重出位流，步骤见
[OSD 菜单测试命令](osd_menu_test_commands.md) §1.2c。

**第三个硬约束：烧进 flash 的那份固件必须用 `LOG=off` 编**（`run_merge_flash_image.sh`
已经这么做了）。日志默认走 semihosting，而本核在没有调试器时会把 semihosting 的
`ebreak` 变成"挂住等调试器"——固件会停在第一次输出日志的地方：菜单画得出来，但
`proto_uart_init()`/`isr_init()` 永远轮不到，ADB 全哑。`LOG=off` 让日志只丢弃、不碰硬件。
需要看日志时用默认的 `LOG=semihosting` 编、走 §1.2b 的 JTAG 流程。

验收与细节见 [OSD 菜单测试命令](osd_menu_test_commands.md) §1.2a。

### 测试

```bash
cd sim/cocotb/test_control_fabric
python run.py  # Windows
make           # Linux
```

## 架构速览

### 视频管线

```
BT.1120 输入 (80 MHz)
  ↓ Bt1120Decoder
  ↓ PreZoomVideoIngress (CDC: 80→100 MHz)
  ↓ HotFocusCal (3×3 最大值检测，clk 域)
  ↓ HotFocusCrosshairYuv422 (绘制十字丝)
  ↓ ElectronicZoomFrameBuffer (写入 HyperRAM 源帧缓冲 A/B/C)
  ↓ ElectronicZoomRasterBuffer (写入 HyperRAM 结果帧缓冲 A/B/C，读取生成连续光栅)
  ↓ native_* 信号 (1280×1024@100MHz 连续光栅流)
  ├→ DvpFormatter → DVP 输出到 X2000 (CDC: 100→100 MHz DVP)
  └→ Downsample2xYuv422 (1280×1024 → 640×512)
      ↓ VideoAsyncFifo (CDC: 100→160 MHz)
      ↓ BicubicScaler640x512 (640×512 → 720×576)
      ↓ VideoAsyncFifo (CDC: 160→100 MHz)
      ↓ VideoHorizontalFlipYuv422
      ↓ HyperRamMaskOverlayYuv422 (四区域 OSD 叠加：1 bit/像素位图，二值键控无 alpha)
      ↓ HyperRamVideoBt656 (三缓冲 + PAL 格式化)
      ↓ Adv7391Top → CVBS 输出 (27 MHz)
```

**关键点**：
- DVP 分支在 `ElectronicZoomRasterBuffer` **之后**从 `native_*` 光栅流分叉
- CVBS 分支同样从 `native_*` 光栅流分叉，经过降采样和缩放
- 电子变倍使用双缓冲架构：源帧三缓冲（0x0100_0000）+ 结果帧三缓冲（0x0180_0000）
- 热点追踪在 CDC 之后、电子变倍之前，与变倍共享 ROI 配置

### 控制管线（RISC-V 软核）
   
```
外部控制（X2000 via ADB）
  ↓ UART (115200 baud)
  ↓ UartMachineForwarder (UART 路由)
  ↓ RISC-V 软核 (50 MHz, clk50M 域)
      - CPU: VexRiscv (RV32IM)
      - 存储: DDR 窗口自 0x1000 起（soc.h SYSTEM_DDR_BMB），即外挂 HyperRAM
      - 固件: ivlabSoftCore —— build/ivlabSoftCore.bin，烧在 SPI flash 0x00380000，
              上电由位流内烤着的 bootloader 搬到 CPU 0x1000 执行
      - AXI 主接口: 访问控制寄存器
  ↓ Ti60AxiControlFabric (AXI 控制总线)
  ↓ ConfigSnapshotCdc (CDC: 50 MHz → 100 MHz)
  ↓ 功能模块配置
      ├→ ElectronicZoomControlRegs (变倍 ROI)
      ├→ HotFocusControlRegs (热点启用/极性)
      ├→ MaskControlRegs (OSD 4 路使能/位置/缓冲选择，原子提交)
      └→ Ti60SystemControlRegs (系统状态)
  ↓ 反馈路径 (状态/结果回读)
  ↓ ConfigSnapshotCdc (CDC: 100 MHz → 50 MHz)
  ↓ RISC-V 软核
  ↓ UART TX → X2000 → ADB → Python 工具
```

**RISC-V 职责**：
- 解析外部 UART 命令（变倍、热点、UI/掩膜）
- 通过 AXI 写入 RTL 控制寄存器
- 读取 RTL 状态和诊断计数器
- 位图上传：经 `MaskControlRegs` 提交后写入 OSD 位图区（1 bit/像素、紧凑跨距）
- 管理配置提交协议（toggle 同步）
- 格式化 UART 响应返回外部

### 时钟域

- `bt1120_clk` (80 MHz): BT.1120 输入
- `clk` (100 MHz): 主 AXI/HyperRAM、控制、热点追踪、电子变倍
- `clk_scaler` (160 MHz): 双三次缩放管线
- `clk50M` (50 MHz): RISC-V 软核
- `clk_dvp` (100 MHz): DVP 输出
- `clk_da` (27 MHz): PAL 像素时钟

**所有 CDC 必须使用 `VideoAsyncFifo` 或 `ConfigSnapshotCdc`。**

### 源码目录

- `src/input/` — BT.1120 解码、CDC 到主时钟域
  - `Bt1120Decoder.v` — BT.1120 时序码识别和像素提取
  - `PreZoomVideoIngress.v` — 输入 CDC FIFO (80→100 MHz)
- `src/hot_focus/` — 热点检测和十字丝（生产代码）
  - `HotFocusCal.v` — 热点检测顶层
  - `HotFocus3x3Max.v` — 3×3 最大值滤波核心
  - `HotFocusCrosshairYuv422.v` — 十字丝绘制
  - `HotFocusLineBufTi60.v` — Ti60 BRAM 行缓存封装
  - `window_mean.v`, `Filter_Function_mean.v` — 窗口构建
- `src/pre_hot_focus/` — 早期热点检测原型（已废弃，仅供参考）
  - `hot_focus_cal.v`, `add_up_3x3_max.v`, `hot_focus_haircross.v` — 原型代码
- `src/scaler/` — 电子变倍和缩放
  - `ElectronicZoomFrameBuffer.v` — 变倍源帧捕获 + 双三次插值
  - `ElectronicZoomRasterBuffer.v` — 变倍结果帧缓冲 + 光栅生成
  - `Downsample2xYuv422.v` — 2×2 盒式降采样 (1280×1024 → 640×512)
  - `BicubicScaler640x512.v` — 双三次缩放 (640×512 → 720×576)
  - `T120BicubicKernel.v` — Catmull-Rom 权重计算
- `src/overlay/` — 视频叠加层
  - `VideoHorizontalFlipYuv422.v` — 水平翻转
  - `VideoCrosshairYuv422.v` — 固定十字丝（遗留，通常禁用）
  - `HyperRamMaskOverlayYuv422.v` — 四区域 OSD 叠加（1 bit/像素位图，
    行跨距 `width/8`、bit 7 最左、bit=1 → 纯白 `16'h80EB`；4 路互不重叠，
    每路独立 A/B 双缓冲）
- `src/memory/` — AXI 仲裁和 HyperRAM 帧缓冲
  - `AxiSharedFlatFabric.v` — AXI 总线顶层（3主机仲裁 + 路由）
  - `AxiShared3Arbiter.v` — 加权轮询仲裁器
  - `Axi4MonitorShared.v` — AXI 带宽监控
  - `HyperRamVideoBt656.v` — PAL 三缓冲 + BT.656 格式化
- `src/output/` — PAL 输出
  - `Adv7391Top.v` — ADV7391 DAC 控制（生成的 IP）
- `src/dvp/` — DVP 输出
  - `DvpFormatter.v` — 16-bit → 8-bit DVP 转换（到 X2000）
- `src/control/` — 控制接口和寄存器
  - `Ti60AxiControlFabric.v` — AXI 控制总线顶层
  - `Ti60SystemControlRegs.v` — 系统/能力寄存器
  - `ElectronicZoomControlRegs.v` — 电子变倍控制
  - `HotFocusControlRegs.v` — 热点追踪控制
  - `MaskControlRegs.v` — OSD 控制寄存器（12 字映射，暂存 + 原子提交）
  - `UartMachineForwarder.v` — UART 路由（X2000 ↔ RISC-V）
  - `RtlMaskUartAxiWriter.v` — 位图 UART 上传状态机（544×288 @ 1bpp，
    位打包在上位机侧完成，目标固定为 OSD0 槽位）
  - `axi/` — AXI 互连原语
    - `arbiter.v`, `axi_interconnect.v`, `priority_encoder.v`
    - `AxiSingleBeatEndpoint.v` — 单拍 AXI 寄存器端点
- `src/common/` — 通用原语
  - `VideoAsyncFifo.v` — 异步 FIFO（Gray 码同步）
  - `ConfigSnapshotCdc.v` — 配置跨时钟域（toggle 同步）
  - `EfxFifoStorage128x32.v` — 小型 FIFO 存储
- `src/debug/` — 调试和监控
  - `RiscvVioMonitor.v` — RISC-V 诊断（VIO 探针）
  - `efx_clk_monitor.v` — 时钟频率监控

`top.v` 直接连接所有功能阶段，无子系统包装器。

## 关键约束

### Ready/Valid 流控

`clk` 域中所有模块形成 ready/valid 链。**状态仅在 `pixel_fire = pixel_valid && pixel_ready` 时推进。**

当 `valid=1, ready=0` 时，禁止推进：
- X/Y 计数器
- 行缓存地址
- 窗口寄存器
- 流水线状态

违反此规则会导致像素错位、随机热点或变倍伪影。

### 损坏帧处理

`PreZoomVideoIngress` 用 `drop_epoch` 翻转标记 FIFO 溢出。下游模块必须：
1. 在干净 SOF 处锁存 epoch
2. 检测帧中 epoch 变化 → 设置 `frame_corrupt`
3. 继续排空损坏帧但**不提交结果**（不切换 HyperRAM 缓冲、不发布热点结果）
4. 等待下一个干净 SOF 恢复

### RAM 推断要求（Ti60F225 特定）

**必须使用同步读 RAM**：

```verilog
// ✓ 正确：同步读（推断为 BRAM）
always @(posedge clk) begin
    if (enable) begin
        addr_q <= addr;
        data_out <= mem[addr_q];
    end
end

// ✗ 错误：异步读（消耗大量 LUT）
assign data_out = mem[addr];
```

`ElectronicZoomFrameBuffer` 的四行缓存（4×1280×256-bit）如改为异步读会超出 Ti60 容量。

### 时序收敛

- 100 MHz AXI/HyperRAM: WNS 正值
- **160 MHz 缩放器域: WNS 0.292 ns（关键路径）**
- 80 MHz BT.1120: WNS 正值

修改 160 MHz 路径时必须重新验证时序。

## 常见修改

### 添加控制寄存器

1. 创建 `src/control/<Feature>ControlRegs.v`
2. 在 `Ti60AxiControlFabric` 中添加地址映射
3. 更新 `Ti60SystemControlRegs.CAPABILITY` 位
4. 使用 `ConfigSnapshotCdc` 跨时钟域（clk50M → clk）
5. 添加 RISC-V 处理程序（在软核项目中）
6. 创建 Python 工具 `tools/send_<feature>_via_adb.py`

### 添加视频处理阶段

1. 确保模块支持 ready/valid 流控
2. 透明转发 SOF/EOF/SOL/EOL/drop_epoch 信号
3. 在 `top.v` 中插入管线
4. 验证 ready/valid 链无组合循环
5. 测试损坏帧注入（FIFO 溢出）

### 修改禁忌

1. ❌ **不要改为异步读 RAM** — 会超出 LUT 容量
2. ❌ **不要跨时钟域直接采样** — 必须用 CDC 原语
3. ❌ **不要在 ready=0 时推进状态** — 会导致像素错位
4. ❌ **不要在帧中切换配置** — 必须在 SOF 边界生效
5. ❌ **不要将十字丝 Y 反馈给热点检测** — 会自锁

## VIO 调试

使用 `ENABLE_VIO_DEBUG` 构建以启用 EDB VIO 探针。

关键诊断：
- `p2_Status=5` — HyperRAM 校准通过 + 帧良好
- `p18_ScalerDroppedFrames=0` — 缩放器输入无溢出
- `p19_ReadFifoUnderflows=0` — PAL FIFO 无欠载
- `p21_ScalerCdcOverflow=0` — 160→100 MHz CDC 无溢出
- 帧计数器持续递增 — 管线畅通

## 测试

### 快速验证

```bash
cd sim
H:\questasim64_10.6c\win64\vsim -do modelsim_hot_focus.do  # ~1 分钟
```

### 板级验证（主要方法）

1. 构建并烧写位流
2. 连接 BT.1120 源（LGCS123, 1280×1024@30Hz）
3. 通过 Efinity EDB 检查 VIO 探针
4. 验证 CVBS 输出
5. 测试 Python 工具（变倍/热点/位图上传/UI 命令）

### 回归测试清单

修改视频管线后：
1. ✓ 帧计数器递增（`p16`, `p17`）
2. ✓ `p18_ScalerDroppedFrames` 保持 0
3. ✓ CVBS 显示稳定（无撕裂）
4. ✓ DVP 输出工作
5. ✓ 电子变倍启用/禁用无损坏帧
6. ✓ 热点十字丝对齐（如修改变倍前路径）

## 详细文档

- [架构与数据流](docs/architecture.md) — 完整管线追踪、模块详解
- [内存映射与 AXI](docs/memory_axi.md) — HyperRAM 布局、三缓冲协议、AXI 拓扑
- [测试与仿真](docs/testing.md) — Cocotb 测试、Questa Sim 脚本、工具链
- [时序与资源](docs/timing_resources.md) — 时序约束、资源使用、DSP 添加指南
- [OSD 菜单测试命令](osd_menu_test_commands.md) — 现场手册：前置、启动自检、正向/负向命令与判据（`0x04` UI）

## 控制接口

**AXI 寄存器映射**：
- `0xE1000000` — 系统/能力寄存器
- `0xE1013000` — 电子变倍控制
- `0xE1040000` — 热点追踪控制
- `0xE1043000` — OSD 控制（12 字映射：COMMAND/STATUS/CANVAS/ACTIVE + 4 路 POS/CTRL）

**Python 工具**（via ADB → X2000 UART → FPGA）：
- `tools/send_zoom_via_adb.py` — 电子变倍 ROI
- `tools/send_hot_focus_via_adb.py` — 热点追踪启用/禁用
- `tools/send_mask_via_adb.py` — 上传位图（1 bit/像素，打包在工具侧完成）
- `tools/send_ui_via_adb.py` — OSD 菜单（`0x04` UI）：切页/选中/编辑态/显隐/数值/回读
- `tools/check_ui_end_to_end.py` — `0x04` 端到端验收（`--dry-run` 可离机自检）

## HyperRAM 内存映射

- `0x00000000–0x003FFFFF`: RISC-V 固件 (4 MiB)。固件本体从 `0x1000` 起、实际 38274 字节
  （`_start`=`0x1000`，到 `.data` 末尾 `0xA582`）。上电由 SPI flash `0x00380000` 搬来。
  **注意**：SoC 的 4 KB 片上 RAM（装 bootloader）不在这一段，它在
  `0xF9000000`（`soc.h SYSTEM_RAM_A_CTRL`），也是 CPU 的复位向量
- `0x00400000–0x007FFFFF`: RISC-V 工作区 (4 MiB)。改造前起始处放过 720×576 8-bit
  掩膜画布（`0x00400000`/`0x00500000`），**本次改造后 RTL 不再从本段读画布**
- `0x00800000–0x009FFFFF`: 保留 (2 MiB)，无 RTL 访问者（软件约定，非硬件禁访）
- `0x00A00000–0x00BFFFFF`: **OSD 位图区** (2 MiB)：`0xA0` 段装 4 路的 A 缓冲、
  `0xB0` 段装 4 路的 B 缓冲，各 256 KB 槽位（`0xA0`/`0xA4`/`0xA8`/`0xAC`
  与 `0xB0`/`0xB4`/`0xB8`/`0xBC`）。1 bit/像素、行跨距 `width/8`，
  位流实际尺寸 544×288（掩膜上传路）与 272×208（菜单承载路，字符格 8×16），一缓冲 7~20 KB
- `0x00C00000–0x00EFFFFF`: CVBS 显示缓冲 0/1/2 (3 MiB)
- `0x01000000–0x0177FFFF`: 电子变倍源帧 A/B/C (7.5 MiB)
- `0x01800000–0x01F7FFFF`: 电子变倍结果帧 A/B/C (7.5 MiB)

**数据路径是 6 主控加权轮询**（`AxiSharedFlatFabric`），权重
`{cpu:1, zr:4, ze:4, rtl:1, mask_rd:1, vid:2}` —— 变倍源/栅格权重最高，视频 2，
位图读与 CPU 最低。**没有**固定优先级、饥饿检测或 PAL 欠载短路径；
`AxiShared3Arbiter.v` 是未被实例化的死代码。

详见 [docs/memory_axi.md](docs/memory_axi.md)。

## 热点追踪集成

热点追踪位于异步 FIFO **之后**、电子变倍**之前**（`clk` 域）：
- 与电子变倍共享 ROI 配置（无需额外 CDC）
- 在变倍前的源图像绘制十字丝（DVP 和 CVBS 都可见）
- 热点搜索自动遵循变倍 ROI

**热点检测监听十字丝前的 Y 流** — 避免检测到自己绘制的亮像素。

最小 ROI：320×256（3×3 窗口需要有效上下文）。
