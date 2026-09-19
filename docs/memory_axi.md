# 内存映射与 AXI 架构

本文档详细描述 HyperRAM 内存布局、三缓冲协议和 AXI 总线拓扑。

## HyperRAM 内存映射

### 完整地址空间

| 地址范围 | 大小 | 用途 | 访问者 |
|---------|------|------|--------|
| `0x00000000–0x003FFFFF` | 4 MiB | RISC-V 固件 | RISC-V axiM |
| `0x00400000–0x007FFFFF` | 4 MiB | RISC-V 热点追踪工作区 | RISC-V axiM |
| `0x00800000–0x009FFFFF` | 2 MiB | 保留 | — |
| `0x00A00000–0x00AFFFFF` | 1 MiB | RTL 掩膜 A | HyperRamMaskOverlay (读) |
| `0x00B00000–0x00BFFFFF` | 1 MiB | RTL 掩膜 B | HyperRamMaskOverlay (读) |
| `0x00C00000–0x00CFFFFF` | 1 MiB | CVBS 显示缓冲 0 | HyperRamVideoBt656 (读写) |
| `0x00D00000–0x00DFFFFF` | 1 MiB | CVBS 显示缓冲 1 | HyperRamVideoBt656 (读写) |
| `0x00E00000–0x00EFFFFF` | 1 MiB | CVBS 显示缓冲 2 | HyperRamVideoBt656 (读写) |
| `0x01000000–0x0127FFFF` | 2.5 MiB | 电子变倍源帧 A | ElectronicZoomFB (读写) |
| `0x01280000–0x014FFFFF` | 2.5 MiB | 电子变倍源帧 B | ElectronicZoomFB (读写) |
| `0x01500000–0x0177FFFF` | 2.5 MiB | 电子变倍源帧 C | ElectronicZoomFB (读写) |
| `0x01800000–0x01A7FFFF` | 2.5 MiB | 电子变倍栅格结果 A | ElectronicZoomRaster (写) |
| `0x01A80000–0x01CFFFFF` | 2.5 MiB | 电子变倍栅格结果 B | ElectronicZoomRaster (写) |
| `0x01D00000–0x01F7FFFF` | 2.5 MiB | 电子变倍栅格结果 C | ElectronicZoomRaster (写) |

### 帧大小计算

**CVBS 显示帧（720×576 YUV422）**：
- 720 × 576 × 2 字节 = 829,440 字节 ≈ 810 KiB
- 分配 1 MiB（对齐）

**电子变倍源帧（1280×1024 YUV422）**：
- 1280 × 1024 × 2 字节 = 2,621,440 字节 ≈ 2.5 MiB
- 分配 2.5 MiB（精确）

**掩膜（720×576 或 420×220）**：
- 遗留模式：720 × 576 × 2 字节 = 829,440 字节
- 原始模式：420 × 220 × 2 字节 = 184,800 字节
- 分配 1 MiB（允许灵活性）

## AXI 总线拓扑

### 控制路径（clk50M 域）

```
RISC-V Sapphire 软核 (50 MHz)
    ├─ axiM (外存总线)
    │    ↓
    │  访问 HyperRAM 低 4 MiB (固件 + 工作区)
    │    ↓
    │  [通过独立路径到 HyperRAM 控制器]
    │
    └─ axiA (外设总线)
         ↓
       Ti60AxiControlFabric (唯一从端)
         ├─ 0xE1000000: Ti60SystemControlRegs
         ├─ 0xE1013000: ElectronicZoomControlRegs
         ├─ 0xE1040000: HotFocusControlRegs
         └─ 0xE1043000: MaskControlRegs
```

**地址解码**：使用 T120 风格的互连，单拍 AXI 事务

**控制寄存器特性**：
- 读写延迟：1-2 个 clk50M 周期
- 配置通过 `ConfigSnapshotCdc` 跨入视频时钟域
- 状态通过 toggle 同步回读

### 数据路径（clk 域）

```
AxiSharedFlatFabric (100 MHz)
    ├─ 主控 0: ElectronicZoomFrameBuffer
    │           - 写：源帧捕获（1280×1024 → HyperRAM）
    │           - 读：ROI 区域（插值器使用）
    ├─ 主控 1: ElectronicZoomRasterBuffer
    │           - 写：栅格结果帧（保留，未启用）
    ├─ 主控 2: HyperRamMaskOverlayYuv422
    │           - 读：掩膜数据（256 字节突发）
    └─ 主控 3: HyperRamVideoBt656
                - 写：CVBS 显示帧（720×576）
                - 读：完整性检查（读回验证）
    ↓
优先级仲裁器
    - 优先级：帧缓冲写 > 掩膜读 > 电子变倍
    - 防止显示帧写入饿死（避免 PAL FIFO 欠载）
    ↓
地址路由
    ↓
[单 HyperRAM 模式]: hyperram_ctrl (HR1 或 HR2)
[双 HyperRAM 模式]: dual_hyperram_ctrl
    ├─ 低 64 位 → HyperRAM 1
    └─ 高 64 位 → HyperRAM 2
```

### AXI 突发参数

| 主控 | 方向 | 突发长度 | 突发大小 | 典型带宽 |
|------|------|---------|---------|---------|
| ElectronicZoomFB 写 | W | 16 拍 | 128-bit | ~300 MB/s |
| ElectronicZoomFB 读 | R | 16 拍 | 128-bit | ~200 MB/s |
| MaskOverlay | R | 16 拍 | 128-bit | ~50 MB/s |
| VideoBt656 写 | W | 16 拍 | 128-bit | ~80 MB/s |
| VideoBt656 读 | R | 可变 | 128-bit | ~80 MB/s |

**总带宽需求**：~710 MB/s 峰值（远低于 HyperRAM 理论 800 MB/s）

**带宽裕度**：
- 单 HyperRAM：紧张但可行（需要优先级仲裁）
- 双 HyperRAM：充裕（每个 800 MB/s，总 1600 MB/s）

## 三缓冲协议

### 电子变倍源帧（1280×1024）

三缓冲地址：
- Buffer A: `0x01000000`
- Buffer B: `0x01280000`
- Buffer C: `0x01500000`

**状态变量**：
```verilog
reg [1:0] writer_index;      // 当前写入的缓冲
reg [1:0] committed_index;   // 最近完成的完整帧
reg [1:0] reader_index;      // 插值器正在读取的缓冲
```

**写端（捕获）**：
```
每帧开始：
    - 使用 buffer[writer_index]
    
每像素：
    - 写入当前 writer_index 缓冲

EOF 到达且帧完整（1280×1024 像素完整）：
    - committed_index = writer_index
    - writer_index = next_free_buffer()  // 非 committed/reader

损坏帧（drop_epoch 变化）：
    - 继续写入但不更新 committed_index
    - writer_index 不切换（下一帧覆盖损坏数据）
```

**读端（插值器）**：
```
SOF 到达：
    - reader_index = committed_index
    - 锁定整帧使用该缓冲

插值过程：
    - 从 buffer[reader_index] 读取 ROI 源行
    - 不关心 writer 正在哪个缓冲工作
```

**关键特性**：
- 三个缓冲允许：写当前帧 + 读上一帧 + 一个预留
- 永不在同一缓冲同时读写
- 损坏帧不会污染 committed 缓冲

### CVBS 显示帧（720×576）

三缓冲地址：
- Buffer 0: `0x00C00000`
- Buffer 1: `0x00D00000`
- Buffer 2: `0x00E00000`

**状态变量**：
```verilog
reg [1:0] write_buf;       // 缩放输出正在写入的缓冲
reg [1:0] committed_buf;   // 最近完成的完整帧
reg [1:0] display_buf;     // PAL 格式化器正在显示的缓冲
```

**写端（缩放输出）**：
```
每帧开始：
    - 使用 buffer[write_buf]
    - 如果 write_buf == display_buf：
        → rejected_sof_count++（等待 PAL 切换）
        → 继续使用旧 write_buf（丢弃这一帧写入）

EOF 到达且 720×576 完整：
    - committed_buf = write_buf
    - write_buf = next_free_buffer()  // 非 committed/display
```

**PAL 格式化器（读端）**：
```
每个 PAL 像素：
    - 从 buffer[display_buf] 读取

PAL 完整帧边界（625 行场序完成）：
    - 检查 committed_buf != display_buf
    - 如果不同：
        → display_buf = committed_buf
        → frame_switch_count++
```

**关键修复**（三缓冲的好处）：
- 旧版本（双缓冲）：PAL 边界未到达时无法接收新帧 → `rejected_sof_count` 高
- 新版本（三缓冲）：PAL 可以继续显示旧帧，同时接收两个新帧 → `rejected_sof_count` 低

**诊断计数器**：
- `rejected_sof_count`：当 write_buf 忙时收到 SOF
- `frame_switch_count`：PAL 边界切换次数（应 ≈ 帧率）

### 双缓冲（掩膜）

掩膜地址：
- Buffer A: `0x00A00000`
- Buffer B: `0x00B00000`

**状态变量**：
```verilog
reg active_buffer;   // 当前正在读取的缓冲（0=A, 1=B）
```

**读端（叠加器）**：
```
SOF 到达：
    - 锁定 active_buffer（从配置寄存器读取）
    - 整帧使用该缓冲

每行：
    - 256 字节突发读取（ping-pong 缓存）
    - 避免单拍读阻塞视频流
```

**写端（UART 上传）**：
```
Python 工具 → ADB → X2000 UART → FPGA UART
    ↓
RtlMaskUartAxiWriter 状态机：
    - 接收字节流
    - 分包传输
    - CRC 校验
    - AXI 突发写入非活动缓冲
    
完成后：
    - RISC-V 固件更新配置寄存器
    - 切换 buffer_select (A/B)
    - 下一个 SOF 切换到新掩膜
```

**无撕裂保证**：SOF 边界切换，整帧使用同一缓冲

## AXI 仲裁策略

### 优先级设计

**优先级顺序**（高到低）：
1. HyperRamVideoBt656 写（帧缓冲）
2. HyperRamMaskOverlayYuv422 读（掩膜）
3. ElectronicZoomFrameBuffer 读/写（变倍）

**原因**：
- **帧缓冲写优先级最高**：防止 PAL FIFO (2048 深度) 欠载
  - PAL 27 MHz 像素时钟不可停顿
  - FIFO 欠载会导致 CVBS 输出撕裂/黑屏
  
- **掩膜读优先级中等**：ping-pong 缓存可容忍短期停顿
  - 256 字节预取缓存提供缓冲
  - 掩膜叠加器可等待数据

- **电子变倍优先级最低**：四行缓存可容忍较长 AXI 停顿
  - 四行源缓存提供 5120 像素缓冲
  - 双三次插值器可等待源数据

### 仲裁实现

**Round-robin with priority**：
- 默认 round-robin 轮询
- 饥饿检测：某主控等待超过阈值 → 强制授权
- 帧缓冲写有短路径：检测到 FIFO 接近欠载 → 立即授权

**写响应处理**：
- `BREADY=1` 永久置位
- 写响应立即接收，避免阻塞 AXI 总线
- 错误计数器记录 BRESP != OKAY

### 双 HyperRAM 模式

**地址路由**：
```
AXI 地址 [31:0]:
    - [31:7]: 块地址
    - [6:4]: 字选择（128-bit 内的 16-byte 字）
    - [3:0]: 字节选择

数据 [127:0]:
    - [63:0] → HyperRAM 1（低 64 位）
    - [127:64] → HyperRAM 2（高 64 位）
```

**并行访问**：
- 单次 AXI 128-bit 读/写 → 两个 HyperRAM 并行 64-bit 操作
- 理论带宽翻倍（800 → 1600 MB/s）

**完整性检查独立**：
- HyperRamVideoBt656 每帧读回验证
- 统计低 64 位和高 64 位的 good/error 计数独立
- 检测单个 HyperRAM 芯片故障

## 内存访问模式

### 电子变倍捕获（写）

**AXI 突发模式**：
```
地址生成：
    base = buffer_base[writer_index]
    addr = base + (line * 1280 * 2) + (x * 2)

突发参数：
    AWLEN = 15 (16 拍)
    AWSIZE = 4 (128-bit = 16 字节)
    AWBURST = INCR (递增)

数据组织：
    每 128-bit 拍包含 8 个 YUV422 像素（16 字节）
    每突发传输 128 个像素（256 字节）
```

**时序**：
- 1280 像素/行 ÷ 128 像素/突发 = 10 个突发/行
- 1024 行 × 10 突发 = 10,240 个突发/帧
- @ 30 fps = 307,200 个突发/秒

### 电子变倍读取（ROI）

**ROI 行读取**：
```
for (line in roi_top .. roi_top+roi_height-1):
    base = buffer_base[reader_index]
    addr = base + (line * 1280 * 2) + (roi_left * 2)
    
    突发数 = roi_width / 128 (向上取整)
    读取 roi_width 像素
    
    填充四行缓存之一（循环使用）
```

**最坏情况**（最小 ROI 320×256）：
- 320 像素/行 ÷ 128 = 3 个突发/行（实际可能 2-3 个）
- 256 行 × 3 = 768 个突发/ROI
- 双三次需要 4 行预读 → ~12 个突发缓存启动

### CVBS 帧缓冲写入（场序组织）

**PAL 625i 场序**：
```
偶场（Field 0）：第 0, 2, 4, ..., 574 行
奇场（Field 1）：第 1, 3, 5, ..., 575 行

写入顺序：
    先写偶场所有行 → 再写奇场所有行

地址跳跃：
    偶场：addr = base + (line * 2) * 720 * 2
    奇场：addr = base + (line * 2 + 1) * 720 * 2
```

**可变突发长度**：
- 大部分行：16 拍（128 像素）
- 行尾部分：< 16 拍（剩余像素）
- 支持 AWLEN 动态调整

**垂直翻转选项**：
- `FLIP_LIVE_VIDEO_VERTICAL=1` 时反向行序
- 用于 180 度旋转（配合水平翻转）

### 掩膜读取

**Ping-pong 预取**：
```
缓存 A 和 B 各 256 字节

行开始：
    预取缓存 A（256 字节突发）
    
处理缓存 A 像素时：
    并行预取缓存 B
    
处理缓存 B 像素时：
    并行预取缓存 A 的下一块
```

**避免阻塞**：
- 单拍读会每像素停顿等待 HyperRAM 延迟（~100ns）
- 预取突发读：一次读取 256 字节，分摊延迟
- Ping-pong 结构：处理期间准备下一块

## 性能分析

### 带宽计算

**CVBS 帧缓冲写入**：
- 720 × 576 × 2 字节 × 30 fps = 49.77 MB/s

**电子变倍捕获**：
- 1280 × 1024 × 2 字节 × 30 fps = 78.64 MB/s

**电子变倍读取**（最坏情况，最小 ROI 320×256）：
- 需要读取约 4 行上下文 × 1280 像素 × 2 字节 = 10,240 字节/输出行
- 1024 输出行 × 10,240 字节 × 30 fps = 314.57 MB/s（峰值）

**掩膜读取**：
- 720 × 576 × 2 字节 × 30 fps = 49.77 MB/s

**总峰值带宽**：
- 49.77 + 78.64 + 314.57 + 49.77 = 492.75 MB/s

**裕度**：
- 单 HyperRAM (800 MB/s)：62% 利用率，充裕
- 实际测量：VIO 探针显示 ~60-70% AXI 活动

### 时序裕度

**100 MHz AXI 时钟**：
- 时钟周期：10 ns
- 单次 128-bit 传输：10 ns
- 16 拍突发：160 ns
- 256 字节突发：160 ns（理论吞吐 1.6 GB/s）

**HyperRAM 延迟**：
- 初始访问延迟：~40-50 ns
- 突发后续拍：每拍 6.25 ns (160 MHz DDR)
- 16 拍突发总时间：~40 + 16×6.25 = ~140 ns

**瓶颈**：
- HyperRAM 物理速度（DDR 160 MHz = 320 MT/s × 16-bit = ~640 MB/s）
- 双 HyperRAM 并行提升到 ~1280 MB/s

### 优化建议

如需进一步优化带宽：
1. **增加突发长度**：32 拍代替 16 拍（降低初始延迟占比）
2. **流水线 AXI**：发出下一突发前无需等待 RVALID/BVALID
3. **预取深度**：增加掩膜 ping-pong 缓存到 512 字节
4. **ROI 对齐**：强制 ROI 左边界 128 像素对齐（减少突发碎片）
