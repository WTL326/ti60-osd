# TI60-239 后处理控制平面与电子变倍重构计划

## 1. 目标与产品边界

本工程不是 T120 完整 ISP 的另一个构建版本。T120 从传感器数据开始完成
ISP、缩放和显示处理；TI60-239 接收的是机芯已经完成 ISP 后输出的
1280×1024 YUV422 BT.1120 图像，并在产品输出端增加自定义功能。

本次重构的目标是：

1. 恢复 RISC-V 已经导出的 `axiA` 外设控制总线；
2. 建立可扩展的 AXI 地址译码与响应结构；
3. 将 mask 的控制面从 GPIO/独立 RTL UART 迁移到 `axiA`；
4. 将 T120 `scaler_bicubic` 的算法与控制语义适配到 1280×1024
   YUV422 电子变倍；
5. 将电子变倍放在 BT.1120 解码之后、native/CVBS 两条输出路径分流之前；
6. 保证配置按帧原子生效，并消除帧缓存读写冲突。

默认验收目标是保持 1280×1024、30 fps 输出时序，稳定状态下不撕裂、
不混合不同源帧。若资源或 HyperRAM 实测带宽不能支持每帧更新，必须明确
记录降帧策略，不能用未上报的旧帧重复掩盖吞吐不足。

## 2. 已确认的现状

### 2.1 串口包头分工

| 包头 | 所有者 | 用途 |
|---|---|---|
| `0xAA` | `UartMachineForwarder` | 验证后转发给机芯 |
| `0xBB` | RISC-V 软核 | mask、电子变倍及后续自定义功能 |

`feature/mask_force` 已将软核 `TRANSMIT_HEADER` 改为 `0xBB`，包尾仍为
`0xAA`。BB 协议格式保持：

```text
BB | length[15:8] | length[7:0] |
dalei | zixiang | type | payload | CRC16 | AA
```

所有新增功能只在软核的 BB 命令分派器中增加 handler。FPGA 中不再为每个
功能增加 UART receiver/parser。

### 2.2 RISC-V 总线

当前 RISC-V IP 已导出：

- 32-bit `axiA` 外设 master；
- `0xE100_0000 ~ 0xE1FF_FFFF` 外设地址窗口；
- 128-bit `io_ddrA` HyperRAM 数据 master。

239 `top.v` 当前将 `axiA` 响应绑为常量，导致任何 `0xE1xx_xxxx`
访问永久等待。`feature/mask_force` 因此跳过 `fpgaInit()`，并通过
`io_ddrA + GPIO` 实现 mask。这是临时绕过方案，不是最终控制架构。

### 2.3 视频格式

输入是 16-bit BT.1120 active word，每个有效像素包含一个 8-bit Y 和一个
8-bit C；C 按像素奇偶交替表示 Cb/Cr，即 YUV422。`Bt1120Decoder` 输出
`pixel_y`、`pixel_c` 和坐标/帧标志。Y 所在的高低字节由板级
`bt_y_from_high` 配置选择。

T120 scaler 的数据端是单通道 8-bit，不能把 `{C,Y}` 当作一个 16-bit
数直接插值。TI60 版本必须保持 Cb/Cr 相位并对各分量独立计算。

## 3. 总体结构

```text
X2000 UART_ST_FR
  +-- AA --> UartMachineForwarder --> 机芯
  `-- BB --> RISC-V parser --> command handlers
                              +-- axiA --> AXI control interconnect
                              `-- io_ddrA --> HyperRAM data fabric

BT.1120 decoder (1280x1024 YUV422)
  --> ingress frame DMA
  --> T120-derived YUV422 bicubic core
  --> committed output frame/raster
  --> common post-zoom stream
        +-- native 1280x1024 DVP
        `-- CVBS downsample/scale --> overlay/mask --> ADV7391
```

控制面和数据面使用两套不同结构：

- `axiA control interconnect`：一个软核 master 对多个小寄存器 slave；
- `HyperRAM data fabric`：CPU、视频 DMA、mask reader 等多个大数据 master
  对一个 HyperRAM 控制器。

## 4. AXI 控制平面

### 4.1 复用范围

复用 T120 `axi_interconnect` 及依赖文件，初期配置为一个 slave-side master
和三个 downstream endpoint。interconnect 负责完整 AXI 通道的地址译码、
响应路由和未映射地址 `DECERR`。

不得让某一个 endpoint 对整个 `0xE1xx_xxxx` 窗口返回 `OKAY`，否则会吞掉
后续外设访问。

### 4.2 地址图

| 基地址 | 大小 | 模块 | 兼容性 |
|---:|---:|---|---|
| `0xE100_0000` | 4 KiB | System/Capability | TI60 新增 |
| `0xE101_3000` | 4 KiB | Electronic Zoom | 保持 T120 `ZOOM_ADDR` |
| `0xE104_3000` | 4 KiB | Mask Control | 保持当前软核 `MASK_ADDR` |

其他地址保留给后续功能，未映射访问返回 `DECERR`。

### 4.3 System/Capability 寄存器

| 偏移 | 名称 | 内容 |
|---:|---|---|
| `0x00` | `ID` | 固定平台 magic，例如 `I239` |
| `0x04` | `VERSION` | 控制接口版本 |
| `0x08` | `CAPABILITY` | bit0=ezoom、bit1=mask |
| `0x0C` | `BUILD_ID` | RTL build ID |
| `0x10` | `SCRATCH` | 软核读写连通性测试 |

### 4.4 Electronic Zoom 寄存器

| 偏移 | 名称 | 内容 |
|---:|---|---|
| `0x00` | `X_ZONE` | `{left_x[15:0], right_x[15:0]}` |
| `0x04` | `Y_ZONE` | `{top_y[15:0], bottom_y[15:0]}`；写入时提交 |
| `0x08` | `STATUS` | pending/applied/error 和配置序号 |
| `0x0C` | `COUNTERS` | accepted/rejected 计数 |
| `0x10` | `APPLIED_X` | 当前实际生效 X 范围 |
| `0x14` | `APPLIED_Y` | 当前实际生效 Y 范围 |

坐标为包含端点的矩形；合法范围为 X `0..1279`、Y `0..1023`。软件先写
`X_ZONE`，再写 `Y_ZONE`。全幅矩形 `(0,0)-(1279,1023)` 表示 1×，即软件
语义上的“关闭变倍”，但数据仍经过统一的 source/scaler/raster 路径。

### 4.5 Mask Control 寄存器

mask 图像仍通过 `io_ddrA` 写入 HyperRAM A/B canvas。`axiA` 只承担：

- enable；
- active buffer；
- 原子 publish；
- applied sequence/status。

软件完成 inactive canvas 后执行 `fence iorw, iorw`，再写一次 commit；
视频域只在 SOF 更新 active canvas。

## 5. 跨时钟配置提交

`axiA` 工作在 `clk50M`，视频控制工作在 `clk`。所有配置通过通用
`ConfigSnapshotCdc` 传递：

1. AXI 域更新 shadow registers；
2. 完整校验配置；
3. 保持配置总线稳定并翻转 request toggle；
4. 视频域同步 toggle，并一次锁存整个配置快照；
5. 在安全帧边界应用；
6. 返回 acknowledge toggle/applied sequence。

禁止对 ROI 各字段分别做无握手的两级同步。

## 6. Mask 迁移

第一步保留 `feature/mask_force` 已验证的数据方式：

- 420×220 source mask；
- 软件按位置绘制到 720×576 full canvas；
- canvas A/B 保持在 `0x0040_0000`、`0x0050_0000`；
- overlay 保持 full-canvas 读取模式。

只迁移控制权：GPIO1/GPIO2 改为 `MaskControlRegs`。板上验证通过后删除：

- `RtlMaskUartAxiWriter`；
- `rtl_mask_mode`；
- mask GPIO 控制；
- FPGA 内重复的 BB parser。

## 7. Bicubic 与帧传输

### 7.1 T120 可复用部分

- 4×4 bicubic 窗口；
- coordinate generator；
- 定点系数与饱和处理；
- AXI-stream valid/ready 语义；
- `ZX0_EZOOM=0x20` 和 ROI packing。

不能原样复用的部分：

- 640×512/10-bit 坐标硬编码；
- 原始 AXI-Lite slave；
- 独立多位同步 CDC；
- 单通道 8-bit 数据路径；
- T120 的 `SENSOR_DIRECTION_ERROR` 坐标翻转。

### 7.2 YUV422 处理

- Y 按 1280×1024 栅格 bicubic；
- Cb、Cr 按各自 640×1024 栅格 bicubic；
- Cb/Cr 不得相互参与插值；
- 输出重新按像素奇偶打包为 YUV422。

变倍关闭不建立独立 raw bypass，也不在顶层切换 raw/raster 数据源。关闭命令
转换为 `(left,top,width,height)=(0,0,1280,1024)`，X/Y 步长均为 1.0；1×
与其他 ROI 都写入完整 destination raster，再由同一读出流分岔到 DVP 和
CVBS。复位后等待第一幅完整 raster 发布，因此统一接受帧缓存带来的固定延迟。

实现前综合比较“三个独立 lane”和“Y lane + Cb/Cr 双分量 lane”，按
DSP、BRAM 和 Fmax 选择。

### 7.3 帧所有权

由于 BT.1120 输入不能反压，source buffer 必须有明确状态：

```text
FREE -> CAPTURING -> READY -> PROCESSING -> FREE
```

禁止捕获端写 `PROCESSING` buffer。无空闲 buffer 时丢弃整帧并计数，不能
覆盖半帧。容量允许时使用 source 三缓冲，否则使用双缓冲加整帧丢弃策略；
destination 使用双缓冲，只发布完整写入的帧。

### 7.4 带宽门槛

1280×1024、16-bit、30 fps 单向有效数据约 78.6 MB/s。完整 source/dest
帧缓存结构至少需要约 314.6 MB/s，尚未包含 CVBS、mask 和 CPU 流量。

实现前必须测量 HyperRAM 有效带宽和最坏仲裁延迟。若带宽不足，应优先
减少一次整帧搬运或提高 scaler 吞吐；若必须重复旧帧，应提供明确计数与
产品级降级说明。

## 8. 软核重构

在 `feature/mask_force` 上建立 TI60 平台配置，而不是继续扩大
`TI60_HYPERRAM_MASK_ONLY`：

```text
platform/ti60_post_isp.h
platform/ti60_post_isp.c
```

仅链接本产品支持的命令：

- BB parser/CRC/response；
- mask `DL_RDP 0x86..0x8A`；
- electronic zoom `DL_GENERAL_IMAGE / ZX0_EZOOM=0x20`。

不执行 T120 全 ISP `fpgaInit()`，不访问不存在的 NUC/DPC/NLM/TFilter 等
外设。启动时读取 System/Capability，检查固件与 bitstream 接口版本。

电子变倍 payload 保持 T120 顺序：

```text
x_left:u16 | y_top:u16 | x_right:u16 | y_bottom:u16
```

所有字段为大端。坐标定义为机芯 ISP 输出后、两路分流前的 1280×1024
坐标，不默认套用 T120 传感器方向翻转。

## 9. 分阶段实施与验收

仿真目录沿用 T120 的 cocotb 分块方式。当前 control-fabric 回归位于
`sim/cocotb/test_control_fabric`，从该目录执行 `make`；Linux 使用标准
cocotb Makefile，原生 Windows 使用同一 testcase 的 Python runner。

### Phase 0：冻结接口

- 记录 FPGA/软核基线 commit；
- 固定协议、坐标、YUV422 相位和内存地址图；
- 建立功能开关，保证每阶段可回退。

### Phase 1：恢复 axiA

- 移植 control interconnect；
- 接通 RISC-V `axiA`；
- 增加 System/Capability endpoint；
- 对未映射地址返回 `DECERR`。

验收：AXI testbench 覆盖 AW/W 不同到达顺序、WSTRB、B/R backpressure、
读写和未映射地址；板上软核读到平台 magic。

当前实现状态：RTL 与 cocotb 已完成；Icarus 回归为 3/3 PASS。板上 magic
读取仍需配套软核更新和新 bitstream，未完成前不得把 Phase 1 标为板验通过。

### Phase 2：迁移 mask 控制

- 增加 MaskControl endpoint 和 CDC；
- 软件以 AXI commit 替换 GPIO publish；
- 验证上传、移动、开关和 Flash 恢复；
- 删除重复 UART/RTL mask 控制路径。

### Phase 3：TI60 软核命令层

- 建立 platform init 和 capability probe；
- 加入独立 ezoom handler；
- 保留 BB 包头并拒绝无效命令；
- 保持固件在 124 KiB 链接区内。

### Phase 4：bicubic 算法适配

- 移植并参数化 T120 bicubic；
- 增加 Y/Cb/Cr 正确处理；
- 用软件黄金模型验证随机 ROI、边界 ROI 和全幅 1× 恒等缩放。

当前实现状态：T120 kernel 定向回归 211/211 PASS；640×512 ROI 的完整
1280×1024 随机背压帧回归 Y/C mismatch 均为 0。顶层重复的 raw bypass
已移除；`enable=0` 已由定向用例确认锁存全幅 ROI 和 1.0 坐标步长。全幅
1× 前 64 个 Y/C 输出像素也已与输入公式逐像素一致。后续继续使用“恒等
缩放”表述，不再称为旁路。

### Phase 5：安全帧 DMA

- 实现 source/destination 所有权；
- 随机 HyperRAM backpressure 仿真；
- 断言任何 buffer 不会同时读写；
- 增加 overflow/drop/collision 计数。

### Phase 6：接入两路输出

- 在分流之前接入 zoom；
- 只在帧边界切换 bypass/zoom；
- 验证 native 与 CVBS 显示同一个 ROI；
- 保持 mask 位于 CVBS 后级。

### Phase 7：产品级验证

- Efinity 全量综合、布局布线和时序；
- 记录 LUT/FF/BRAM/DSP 增量；
- HyperRAM 带宽压力测试；
- AA/BB 交替命令测试；
- mask 上传期间 zoom 稳定性；
- 连续运行、复位和掉电恢复测试。

## 10. 最终扩展规则

后续功能统一采用：

```text
新增 BB handler
  -> 分配 4 KiB axiA 地址窗口
  -> 挂接独立寄存器 endpoint
  -> 使用 ConfigSnapshotCdc 原子提交到数据面
```

不再增加新的 FPGA UART parser，不再借用 GPIO 充当可扩展寄存器总线。
