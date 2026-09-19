# 架构与数据流详解

本文档详细描述视频管线架构、关键模块和数据流。

## 完整像素路径追踪

```
BT.1120 物理引脚 (80 MHz, 16-bit DDR)
    ↓
Bt1120Decoder (bt1120_clk 域)
    - 识别 FF FF 00 00 00 00 XY 时序码
    - 提取 Y[7:0], C[7:0], pixel_x[10:0], pixel_line[10:0]
    - 生成 SOF/EOF/SOL/EOL 边界标记
    ↓
PreZoomVideoIngress (bt1120_clk → clk CDC)
    - 13 位深度异步 FIFO (8192 字)
    - 传输 {drop_epoch, SOF, EOF, SOL, EOL, C, Y}
    - FIFO 满时翻转 drop_epoch（标记损坏帧）
    ↓
HotFocusCal (clk 域, 100 MHz)
    - 两行缓存 (1280×8 × 2)
    - 3×3 窗口 + 四级加法树
    - 逐帧搜索最大 Y 和（ROI 内）
    - 帧结束发布上一帧结果
    ↓
HotFocusCrosshairYuv422 (clk 域)
    - SOF 锁存坐标
    - 命中检测：十字臂矩形并集
    - 仅修改命中像素的 Y/C
    ↓
ElectronicZoomFrameBuffer (clk 域)
    - 输入写入 HyperRAM 源帧三缓冲 (0x0100_0000/0x0128_0000/0x0150_0000)
    - [变倍关闭] 输出完整 1280×1024 坐标
    - [变倍开启] 输出稀疏 ROI 双三次插值结果
    - AXI 写：256 字节突发 (16×128-bit)
    - AXI 读：ROI 源行
    - 四行缓存 + Catmull-Rom 内核
    ↓
ElectronicZoomRasterBuffer (clk 域)
    - 接收稀疏结果，写入 HyperRAM 结果帧三缓冲 (0x0180_0000/0x01A8_0000/0x01D0_0000)
    - 连续读取生成完整 1280×1024 光栅流 (native_*)
    - AXI 写：提交完整帧
    - AXI 读：持续光栅扫描
    ↓
native_* 信号 (1280×1024 @ 100 MHz, clk 域) ━━━━━ 分叉点 ━━━━━
    ├─→ DvpFormatter (clk → clk_dvp CDC)
    │      - 11 位深度异步 FIFO (2048 字)
    │      - 16-bit → 8-bit 序列化
    │      - SOL 预填充 32 字（容忍 CDC 延迟）
    │      → DVP 输出 (8-bit, 100 MHz clk_dvp) → X2000
    │
    └─→ Downsample2xYuv422 (clk 域)
           - 640 深度行缓存（存储前一行 2×1 和）
           - 2×2 盒滤波（四像素平均）
           - 输出 640×512
           ↓
        VideoAsyncFifo (clk → clk_scaler CDC)
           - 2048 深度
           - 100 MHz → 160 MHz
           ↓
        BicubicScaler640x512 (clk_scaler 域, 160 MHz)
           - 固定 9:8 比例（累加器生成相位）
           - 四行循环缓存（Y: 4×640, Cb/Cr: 各 4×320）
           - Catmull-Rom 双三次内核
           - 水平 4-tap → 垂直 4-tap
           - 输出 720×576
           ↓
        VideoAsyncFifo (clk_scaler → clk CDC)
           - 2048 深度
           - 160 MHz → 100 MHz
           ↓
        VideoHorizontalFlipYuv422 (clk 域)
           - 720 像素行缓存
           - 逆序输出（水平翻转）
           ↓
        VideoCrosshairYuv422 (clk 域)
           - 遗留调试十字丝（通常禁用）
           ↓
        HyperRamMaskOverlayYuv422 (clk 域)
           - 从 HyperRAM 读取掩膜
           - Ping-pong 预取缓存（2×256 字节）
           - Alpha 混合或替换
           ↓
        HyperRamVideoBt656 (clk 域 → clk_da CDC)
           - AXI 写三缓冲 (100 MHz)
           - 仅在 PAL 帧边界切换显示缓冲
           - 2048 深度读 FIFO (100 MHz → 27 MHz)
           - BT.656 格式化：EAV/SAV 插入
           - PAL 625i 场序组织
           ↓
        Adv7391Top (clk_da 域, 27 MHz)
           - I2C 配置 DAC (25 MHz adv_ctrl_clk)
           - BT.656 → CVBS 模拟输出
```

## 时钟域交叉点

| 源时钟域 | 目标时钟域 | CDC 机制 | 模块 | 深度 | 备注 |
|---------|-----------|---------|------|------|------|
| bt1120_clk (80 MHz) | clk (100 MHz) | VideoAsyncFifo | PreZoomVideoIngress | 8192 | 主视频路径 |
| clk (100 MHz) | clk_dvp (100 MHz) | VideoAsyncFifo | DvpFormatter | 2048 | DVP 输出（异步域） |
| clk (100 MHz) | clk_scaler (160 MHz) | VideoAsyncFifo | Downsample→Scaler | 2048 | 降采样后 |
| clk_scaler (160 MHz) | clk (100 MHz) | VideoAsyncFifo | Scaler→Overlay | 2048 | 缩放后 |
| clk (100 MHz) | clk_da (27 MHz) | 2048 深度 FIFO | HyperRamVideoBt656 | 2048 | PAL 输出 |
| clk50M (50 MHz) | clk (100 MHz) | ConfigSnapshotCdc | 控制寄存器 | — | 配置跨域 |
| clk (100 MHz) | clk50M (50 MHz) | Toggle + 快照 | 状态回读 | — | 结果跨域 |

**注意**：DvpFormatter 在 native_* 光栅流之后分叉，不在 Bt1120Decoder 之后。

## 关键模块详解

### 输入层（input/）

#### Bt1120Decoder — BT.1120 协议解码器

唯一识别 SAV/EAV（帧/行起止标记）的模块。

**功能**：
- 状态机识别 `FFFF 0000 0000 XY` 时序码序列
- 从 BT.1120 嵌入式同步流中提取 1280×1024 有效像素区域
- 输出规范化的 Y/C 分离、像素坐标和时序信号

**关键特性**：
- `y_from_high` 参数控制 Y 数据在高低字节的位置
- 计数器驱动的几何生成：行内不搜索新 TRS（防止全范围图像数据触发误同步）
- 诊断信号：`sync_locked`、`protocol_error`

**输出**：
- `y_out[7:0]`, `c_out[7:0]` — 分离的亮度/色度
- `pixel_x[10:0]`, `pixel_line[10:0]` — 像素坐标
- `SOF`, `EOF`, `SOL`, `EOL` — 帧/行边界标记

#### PreZoomVideoIngress — 输入时钟域跨越

将 BT.1120 的 80 MHz 跨入主处理时钟域 100 MHz。

**损坏帧标记机制**：
- BT.1120 是不可回压的推送源
- FIFO 满时翻转 `drop_epoch` 标记整个溢出帧
- 下游消费者携带 epoch 并独立抑制损坏帧的结果

**数据包格式**：21 位 `{drop_epoch, SOF, EOF, SOL, EOL, C[7:0], Y[7:0]}`

**FIFO 参数**：8192 深度（13 位地址），支持 ready/valid 流控

### 热点追踪层（hot_focus/）

#### HotFocus3x3Max — 3×3 最大值滤波核心

基于 Y 亮度的滑动窗口最大值检测。

**算法**：
- 两个行缓存形成连续三行窗口
- `window_mean` 构建 3×3 像素窗口
- 四级加法树计算九点和（9×255=2295，需 12 位）
- 在 ROI 内逐帧搜索最大和位置

**极性支持**：
- 白热模式：搜索最大和
- 黑热模式：搜索最小和（`polarity_black_hot=1`）

**输出时序**：
- 帧完成后发布上一帧的结果
- `hot_valid` 在下一帧边界置位
- 损坏帧不发布结果

**输出信号**：
- `hot_x[10:0]`, `hot_y[9:0]` — 热点坐标
- `hot_sum[11:0]` — 3×3 和
- `hot_valid` — 结果有效标志

#### HotFocusCrosshairYuv422 — 十字丝绘制

在热点坐标处绘制橙色十字丝。

**参数**：
- 颜色：Y=81, Cb=90, Cr=240（橙色）
- 尺寸：`HALF_LENGTH=10`, `HALF_WIDTH=2`

**关键特性**：
- SOF 时锁存使能和坐标，整帧使用同一配置（避免撕裂）
- 仅修改命中像素的 Y/C，其他完全透传
- Ready/valid 流控完全透明（`s_ready = m_ready`）

**重要**：热点检测监听十字丝前的 Y 流，避免检测到自己绘制的亮像素。

#### HotFocusLineBufTi60 — 行缓存适配器

Ti60F225 专用的同步读 RAM 封装。

**要求**：
- 同步读延迟（推断为 BRAM）
- 定义的读期间写行为
- `pixel_fire=0` 时地址和输出保持
- 必须连接复位

**实现选项**：
- `EFX_RAM10` 原语
- 生成的 BRAM IP

### 电子变倍层（scaler/）

#### ElectronicZoomFrameBuffer — 1280×1024 电子变倍核心

**三缓冲捕获**：
- HyperRAM 地址：0x01000000 / 0x01280000 / 0x01500000
- 每帧 2.5 MiB（1280×1024×2 字节）
- 256 字节 AXI 突发（16 拍 128 位）
- 所有权协议：writer / committed / reader

**工作模式**：
- 变倍关闭：直通原始 1280×1024
- 变倍开启：从 HyperRAM 读取 ROI + 双三次插值重建 1280×1024

**ROI 约束**：
- 最小尺寸：320×256
- 水平对齐：起始/宽度取偶数（保持 YUV422 相位）

**双三次插值**：
- 四行源缓存（同步 256 位 RAM 读 + 32 像素寄存器窗口）
- Catmull-Rom 内核权重
- 水平 4-tap → 垂直 4-tap

**配置生效**：SOF 边界生效，避免帧内撕裂

**诊断输出**：
- `captured_frame_count` — 捕获帧数
- `zoom_output_frame_count` — 输出帧数
- `axi_error_count` — AXI 错误计数

#### Downsample2xYuv422 — 2×2 盒式降采样

1280×1024 → 640×512 降采样。

**算法**：
- 纯 2×2 盒滤波器（四像素平均）
- 保留 YUV422 色度采样结构
- 640 深度行缓存存储前一行的 2×1 和
- 奇数行产生输出

**输出**：640×512 流 + SOF/EOL 标记

#### BicubicScaler640x512 — 固定比例双三次缩放

640×512 → 720×576 双三次缩放。

**特性**：
- 固定 9:8 缩放比（水平和垂直均为 9/8）
- 累加器生成坐标和分数相位（无需除法器）
- Catmull-Rom 内核权重

**行缓存**：
- Y: 4×640 样本
- Cb/Cr: 各 4×320 样本（分离以避免混淆）

**状态机**：SYNC → LOAD → CHECK → RD0-4 → H → V → OUT

**诊断**：输出帧计数器、丢帧计数器

#### T120BicubicKernel — 双三次插值权重计算

根据分数相位计算 Catmull-Rom 内核权重。

**输出**：4 个有符号权重

**共享使用**：`BicubicScaler640x512` 和 `ElectronicZoomFrameBuffer`

### 覆盖层（overlay/）

#### VideoHorizontalFlipYuv422 — 水平翻转

- 720 像素行缓存
- 逆序输出
- 保持 YUV422 Cb/Cr 相位对齐

#### VideoCrosshairYuv422 — 遗留十字丝

- 固定位置的白色十字丝（720×576 坐标系）
- 生产环境通常禁用（热点十字丝已在变倍前绘制）

#### HyperRamMaskOverlayYuv422 — 掩膜叠加

从 HyperRAM 读取半透明掩膜并叠加到视频流。

**模式**：
- 遗留模式：720×576 全屏掩膜 @ 0x00A00000/0x00B00000
- 原始模式：420×220 掩膜，支持有符号偏移和裁剪

**特性**：
- 双缓冲（A/B 切换）
- Ping-pong 预取缓存：256 字节突发，避免单拍读阻塞视频流
- 可选垂直坐标翻转

**诊断**：`frame_count`, `read_error_count`, `active`

### 内存层（memory/）

#### HyperRamVideoBt656 — PAL 帧缓冲和 BT.656 输出

**三缓冲**：
- 720×576 YUV422 帧 @ 0x00C00000/0x00D00000/0x00E00000
- 所有权模型：display / latest_complete / writer
- 仅在 PAL 完整帧边界切换显示缓冲（避免撕裂）

**写入路径**：
- 100 MHz AXI 时钟域
- 16 拍突发
- 可变突发长度（PAL 场序需要跳行）
- 可选垂直翻转写入（`FLIP_LIVE_VIDEO_VERTICAL`）

**读取路径**：
- 27 MHz 像素时钟域
- 2048 深度 FIFO
- 检测欠载

**BT.656 PAL 625i 时序**：
- EAV/SAV 插入
- 场序组织（偶场/奇场）

**完整性检查**：
- 每帧读回并校验
- 双 HyperRAM 的低 64/高 64 位独立统计

**诊断**：`frame_good`, `frame_error`, `read_fifo_underflow_count`, `frame_switch_count`

#### AxiSharedFlatFabric — AXI 仲裁器

**仲裁**：
- 三主控：电子变倍源/结果 + 掩膜读 + 帧缓冲读写
- 优先级仲裁（防止视频流饿死）
- 地址路由到单个或双 HyperRAM 控制器

**特性**：
- 写响应始终接收（`BREADY=1`，避免阻塞）

#### Axi4MonitorShared — AXI 性能监控

- 监控 AXI 传输活动和带宽
- 检测长时间空闲（约 128 个时钟周期无传输）
- 输出：`status`, 带宽/效率计数器

### DVP 输出（dvp/）

#### DvpFormatter — 16 位到 8 位 DVP 转换

**功能**：
- 1280×1024 @ 16 位 YUV422 → 8 位 DVP 流
- 异步 FIFO CDC：`bt1120_clk` → `clk_dvp`（均为 100 MHz 但异步）
- 16 位字序列化为两个 8 位字节

**时序特性**：
- SOL 预填充：每行开始时暂停，让 FIFO 积累约 32 个字
- VSYNC 在 SOF 到达 FIFO 头时提前置位（在行空白期间）
- HSYNC = line_active（有效行期间为高）

**诊断**：检测 DVP 时钟过快（FIFO 欠载）

**目标**：直接输出到 X2000 处理器

### PAL 输出（output/）

#### Adv7391Top — ADV7391 DAC 控制

- 生成的 IP 模块（不要手动编辑）
- I2C 配置 ADV7391 视频 DAC
- 接收 BT.656 并输出 PAL CVBS 模拟信号
- 工作在 27 MHz 像素时钟和 25 MHz I2C 控制时钟

### 控制层（control/）

#### Ti60AxiControlFabric — AXI 控制总线顶层

RISC-V 软核 `axiA` 外设主控的唯一从端。

**地址解码**：
- `0xE1000000`: `Ti60SystemControlRegs` — 系统/能力寄存器
- `0xE1013000`: `ElectronicZoomControlRegs` — 电子变倍控制
- `0xE1040000`: `HotFocusControlRegs` — 热点追踪控制
- `0xE1043000`: `MaskControlRegs` — 掩膜控制

**实现**：使用 T120 风格的互连和优先级仲裁器路由单拍 AXI 事务

#### Ti60SystemControlRegs — 系统寄存器端点

**寄存器**：
- `BUILD_ID` — 识别固件版本
- `CAPABILITY` — 指示支持的功能：
  - bit0: 电子变倍
  - bit1: 掩膜
  - bit2: 热点追踪

#### ElectronicZoomControlRegs — 电子变倍寄存器

**寄存器**：
- `COMMAND`：enable, commit
- ROI 几何：`left`, `top`, `width`, `height`（11 位）
- `STATUS`：active, pending
- 统计：accepted_count, rejected_count

**配置协议**：
- 通过 `zoom_cfg_toggle` 提交
- `zoom_applied_toggle` 反馈生效

#### HotFocusControlRegs — 热点追踪寄存器

**寄存器**：
- `COMMAND`：enable, polarity (black_hot), commit
- `STATUS`：active, pending, result_valid
- `RESULT_XY`：hot_x[10:0], hot_y[9:0]
- `RESULT_SUM`：3×3 和[11:0], 帧序号
- 统计：result_count, dropped_result_count

**配置协议**：
- 通过 `hot_cfg_toggle` 提交
- `hot_applied_toggle` 反馈生效

#### MaskControlRegs — 掩膜控制寄存器

**寄存器**：
- `COMMAND`：enable, buffer_select (A/B), commit
- `STATUS`：active, pending
- 统计：commit_count

**配置协议**：
- 通过 `mask_cfg_toggle` 提交
- `mask_applied_toggle` 反馈生效

#### ConfigSnapshotCdc — 跨时钟域配置同步

- 将 clk50M 域（RISC-V）的寄存器跨到目标时钟域
- 使用 toggle 同步 + 快照机制
- 保证多位配置原子性更新

#### UartMachineForwarder — UART 路由器

- 将 X2000 的 UART 指令路由到 RISC-V 软核
- RISC-V TX 可选接管返回 X2000 的串口（`s13_RiscvReplyEnable`）

#### RtlMaskUartAxiWriter — 掩膜上传状态机

- 接收 UART 字节流并通过 AXI 写入 HyperRAM 掩膜区
- 支持分包传输和 CRC 校验

### 通用模块（common/）

#### VideoAsyncFifo — 异步 FIFO

**特性**：
- 参数化宽度和深度（`WIDTH`, `ADDR_W`）
- Gray 码指针同步（两级同步器）
- Ready/valid 接口
- 写侧溢出标志（BT.1120 等不可回压源）
- 读侧注册输出（减少组合路径）

#### ConfigSnapshotCdc — 配置跨时钟域

- Toggle 同步机制（慢→快时钟域）
- 多位数据快照（保证原子性）
- 常用于 clk50M（RISC-V）→ clk（视频）

#### EfxFifoStorage128x32 — 小型 FIFO 存储

- 128 深度 × 32 位
- 用于控制路径的小缓冲

### 调试层（debug/）

#### RiscvVioMonitor — RISC-V 诊断

**监控内容**：
- 心跳计数器（每秒 AXI 活动）
- UART RX/TX 字节计数和最后字节
- AXI 错误计数和最后错误码
- 启动标志：HyperRAM 就绪、CPU 门控、复位状态
- 最后 AXI 地址记录
- 粘滞活动位：UART RX/GPIO/AXI 写/读

#### efx_clk_monitor — 时钟频率监控

- 使用参考时钟测量目标时钟频率
- 用于验证 HyperRAM 时钟和 PLL 锁定

## Ready/Valid 流控链

热点追踪和电子变倍在 `clk` 域形成严格的 ready/valid 握手链：

```
PreZoomVideoIngress.output_ready
    ← HotFocusCal.s_ready (= HotFocusCrosshair.s_ready)
    ← HotFocusCrosshair.m_ready (= ElectronicZoom.input_ready)
    ← ElectronicZoomFrameBuffer.input_ready
```

**关键规则**：
- 状态推进条件：`fire = valid && ready`
- 当 `valid=1, ready=0` 时，**禁止**推进任何状态：
  - X/Y 计数器保持
  - 行缓存地址保持
  - 3×3 窗口寄存器保持
  - 加法流水线 valid 保持
- 违反此规则会导致像素与坐标/窗口错位，产生随机热点或变倍伪影

## 损坏帧传播

```
BT.1120 FIFO 溢出
    ↓
PreZoomVideoIngress: 翻转 drop_epoch (写时钟域)
    ↓
异步 FIFO: 传输 drop_epoch bit
    ↓
HotFocusCal (读时钟域):
    - SOF 锁存 frame_epoch
    - 检测 epoch 变化 → frame_corrupt = 1
    - 继续排空帧但不发布 hot_valid
    - 下一个干净 SOF 清除候选值
    ↓
HotFocusCrosshair:
    - 透传 drop_epoch（不参与决策）
    ↓
ElectronicZoomFrameBuffer:
    - SOF 锁存 capture_epoch
    - 检测 epoch 变化 → frame_corrupt = 1
    - 继续 HyperRAM 写入但不提交缓冲
    - 不切换 committed_buffer（读端继续使用旧帧）
    - 下一个干净 SOF 恢复
```

**保证**：损坏帧不会：
- 成为电子变倍的源帧
- 触发热点追踪结果发布
- 影响 HyperRAM 完整性检查

## 配置生效时序

所有功能配置在 SOF 边界生效，避免帧内撕裂：

```
用户命令 (Python via ADB)
    ↓
X2000 UART → FPGA UART_ST_FR
    ↓
UartMachineForwarder → RISC-V RX
    ↓
RISC-V 固件解析命令
    ↓
AXI 写 Ti60AxiControlFabric (clk50M 域)
    ├─ COMMAND 寄存器写入配置
    └─ commit bit → toggle cfg_toggle
    ↓
ConfigSnapshotCdc (clk50M → clk)
    - 检测 toggle 边沿
    - 快照多位配置（原子性）
    - pending_config = new_config
    ↓
功能模块 (clk 域):
    if (SOF && pending_config != active_config) {
        active_config = pending_config;
        applied_toggle = ~applied_toggle;
    }
    ↓
ConfigSnapshotCdc (clk → clk50M)
    - applied_toggle 回传
    ↓
RISC-V 固件检测应用完成
    ↓
UART 回复 X2000 → ADB → Python
```

**生效延迟**：
- 最坏情况：当前帧剩余时间 + 1 个 SOF（< 2 帧 = 67 ms @ 30 fps）
- 最好情况：下一个 SOF（< 1 帧 = 33 ms）
