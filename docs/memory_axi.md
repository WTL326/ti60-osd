# 内存映射与 AXI 架构

本文档详细描述 HyperRAM 内存布局、三缓冲协议和 AXI 总线拓扑。

> 本文与 RTL 逐条对齐，依据为 `src/top.v` 的参数实参与各模块实现。
> 凡无法从本仓库核实的条目（软核固件行为、HyperRAM 器件实测参数）均已显式标注。

## HyperRAM 内存映射

### 完整地址空间

| 地址范围 | 大小 | 用途 | 访问者 |
|---------|------|------|--------|
| `0x00000000–0x003FFFFF` | 4 MiB | RISC-V 固件 | RISC-V axiM |
| `0x00400000–0x007FFFFF` | 4 MiB | RISC-V 软核工作区，**含 legacy 掩膜画布 A/B** | RISC-V axiM + HyperRamMaskOverlay (读) |
| `0x00800000–0x009FFFFF` | 2 MiB | 保留 | — |
| `0x00A00000–0x00AFFFFF` | 1 MiB | RTL **raw 模式**掩膜 A | HyperRamMaskOverlay (读)、RtlMaskUartAxiWriter (写) |
| `0x00B00000–0x00BFFFFF` | 1 MiB | RTL **raw 模式**掩膜 B | HyperRamMaskOverlay (读)、RtlMaskUartAxiWriter (写) |
| `0x00C00000–0x00CFFFFF` | 1 MiB | CVBS 显示缓冲 0 | HyperRamVideoBt656 (读写) |
| `0x00D00000–0x00DFFFFF` | 1 MiB | CVBS 显示缓冲 1 | HyperRamVideoBt656 (读写) |
| `0x00E00000–0x00EFFFFF` | 1 MiB | CVBS 显示缓冲 2 | HyperRamVideoBt656 (读写) |
| `0x01000000–0x0127FFFF` | 2.5 MiB | 电子变倍源帧 A | ElectronicZoomFrameBuffer (读写) |
| `0x01280000–0x014FFFFF` | 2.5 MiB | 电子变倍源帧 B | ElectronicZoomFrameBuffer (读写) |
| `0x01500000–0x0177FFFF` | 2.5 MiB | 电子变倍源帧 C | ElectronicZoomFrameBuffer (读写) |
| `0x01800000–0x01A7FFFF` | 2.5 MiB | 电子变倍栅格结果 A | ElectronicZoomRasterBuffer (读写) |
| `0x01A80000–0x01CFFFFF` | 2.5 MiB | 电子变倍栅格结果 B | ElectronicZoomRasterBuffer (读写) |
| `0x01D00000–0x01F7FFFF` | 2.5 MiB | 电子变倍栅格结果 C | ElectronicZoomRasterBuffer (读写) |

**基地址实参一览**（全部来自 `src/top.v`）：

| 参数 | 值 | 参数 | 值 |
|------|-----|------|-----|
| `MASK0_BASE` | `0x0040_0000` | `RTL_MASK0_BASE` | `0x00A0_0000` |
| `MASK1_BASE` | `0x0050_0000` | `RTL_MASK1_BASE` | `0x00B0_0000` |
| `FRAME0_BASE` | `0x00C0_0000` | `FRAME_A/B/C`（源帧） | `0x0100_0000` / `0x0128_0000` / `0x0150_0000` |
| `FRAME1_BASE` | `0x00D0_0000` | `FRAME_A/B/C`（栅格） | `0x0180_0000` / `0x01A8_0000` / `0x01D0_0000` |
| `FRAME2_BASE` | `0x00E0_0000` | `MASK_A/MASK_B_BASE` | `0x00A0_0000` / `0x00B0_0000` |

### 软核工作区内部划分（`0x0040_0000–0x007F_FFFF`）

该 4 MiB 段由软核与掩膜叠加器**共用**，legacy 掩膜画布占据其起始两个 1 MiB 窗口：

| 地址范围 | 大小 | 用途 |
|---------|------|------|
| `0x0040_0000–0x0046_53FF` | 414,720 B | legacy 掩膜画布 A（`MASK0_BASE`） |
| `0x0046_5400–0x004F_FFFF` | 619 KiB | 未使用（画布 A 之后的窗口填充） |
| `0x0050_0000–0x0056_53FF` | 414,720 B | legacy 掩膜画布 B（`MASK1_BASE`） |
| `0x0056_5400–0x005F_FFFF` | 619 KiB | 未使用（画布 B 之后的窗口填充） |
| `0x0060_0000–0x007F_FFFF` | 2 MiB | 工作区其余部分 |

> **待核实**：画布 A/B 之外的区域由软核如何使用，**无法从本仓库确认** ——
> 软核应用源码不在检出内（`embedded_sw/riscv/software/standalone/application/` 下只有
> BSP 与 coremark/dhrystone/memTest 等 demo），实际固件为预编译镜像 `outflow/ivlab239_c.hex`。
> "软核写入完整 8-bit 掩膜画布" 这一结论目前仅来自 `src/top.v:1774` 的 RTL 注释。

> **注意**：`0x00800000–0x009FFFFF` 标为"保留"仅是**软件约定**。
> `AxiSharedFlatFabric` 只做仲裁，不做地址过滤，硬件不会拒绝任何主控访问该区间；
> 实际只是当前没有任何 RTL 模块把地址指向这里。

### 帧大小计算

**CVBS 显示帧（720×576 YUV422）**：
- 720 × 576 × 2 字节 = 829,440 字节 ≈ 810 KiB
- 实际占用 0x00C0_0000–0x00CC_A7FF / 0x00D0_0000–0x00DC_A7FF / 0x00E0_0000–0x00EC_A7FF，
  每个分配 1 MiB（对齐）

**电子变倍源帧 / 栅格结果帧（1280×1024 YUV422）**：
- 1280 × 1024 × 2 字节 = 2,621,440 字节 = 2.5 MiB（精确对齐）

**掩膜（8-bit/像素，非 YUV422）**：

掩膜画布每像素仅 **1 字节**（`HyperRamMaskOverlayYuv422.v:134` 的 `mask_byte` 为 `[7:0]`），
行跨距即行像素数：

| 模式 | 分辨率 | 行跨距 | 大小 | 占用范围 |
|------|--------|--------|------|---------|
| legacy 全屏 | 720×576 | 720 B | 414,720 B ≈ 405 KiB | 见上「软核工作区内部划分」 |
| raw 小图 | 420×220 | 420 B | 92,400 B ≈ 90 KiB | `0x00A0_0000–0x00A1_68EF` / `0x00B0_0000–0x00B1_68EF` |

两种模式都按 1 MiB 对齐分配基地址（留有大量裕量）。

> **当前位流状态**：`src/top.v:493` 把 `rtl_mask_mode` 硬接为 `1'b0`，该信号同时驱动
> 叠加器的 `raw_mode`（`top.v:1792`）与 `RtlMaskUartAxiWriter` 的 `enable`（`top.v:742`）。
> 因此 **legacy 分支生效、raw 分支完全不可达**：`0x00A0_0000`/`0x00B0_0000` 在当前位流中
> **既无写入方也无读取方**（`RtlMaskUartAxiWriter` 在 `!enable` 时 parser 复位、不解析任何包），
> 这 2 MiB 实际处于闲置状态。

## AXI 总线拓扑

### 控制路径（clk50M 域）

```
RISC-V Sapphire 软核 (50 MHz)
    ├─ axiM (外存总线, 即 Sapphire 的 io_ddrA)
    │    ↓
    │  作为共享 fabric 的第 5 号主控槽接入（受 riscv_cpu_bus_enable 门控）
    │  地址 1:1 映射到 HyperRAM，无地址重映射
    │
    └─ axiA (外设总线)
         ↓
       Ti60AxiControlFabric (唯一从端)
         ├─ 0xE1000000: Ti60SystemControlRegs
         ├─ 0xE1013000: ElectronicZoomControlRegs
         ├─ 0xE1040000: HotFocusControlRegs
         └─ 0xE1043000: MaskControlRegs
```

**地址解码**：使用 T120 风格的互连，单拍 AXI 事务（`Ti60AxiControlFabric.v:79-83,129-132`：
`M_COUNT=4`，索引 `SYS=0, ZOOM=1, HOT=2, MASK=3`）

**控制寄存器特性**：
- 读写延迟：1-2 个 clk50M 周期
- 配置通过 `ConfigSnapshotCdc` 跨入视频时钟域
- 状态通过 toggle 同步回读

> `axiM` **不**走独立路径：它与其余 5 个视频主控共用同一个 `AxiSharedFlatFabric`。

### 数据路径（clk 域）

```
AxiSharedFlatFabric (100 MHz, PORTS=6, 加权轮询)
    ├─ 槽 0: HyperRamVideoBt656            (aid 8'h00)
    │           - 写：CVBS 显示帧（720×576）
    │           - 读：完整性校验读回
    ├─ 槽 1: HyperRamMaskOverlayYuv422     (aid 8'hA1, 只读)
    │           - 读：掩膜数据（256 字节突发）
    ├─ 槽 2: RtlMaskUartAxiWriter          (aid 8'hB2, 只写)
    │           - 写：UART 上传的掩膜字节（单拍单字节）
    ├─ 槽 3: ElectronicZoomFrameBuffer     (aid 写 8'hD0 / 读 8'hD1)
    │           - 写：源帧捕获（1280×1024 → HyperRAM）
    │           - 读：ROI 区域（插值器使用）
    ├─ 槽 4: ElectronicZoomRasterBuffer    (aid 写 8'hE0 / 读 8'hE1)
    │           - 写：栅格结果帧
    │           - 读：生成连续光栅（DVP 与 CVBS 两条支路的共同源头）
    └─ 槽 5: RISC-V axiM (Sapphire io_ddrA)（aid 由软核产生）
    ↓
加权轮询仲裁（读写各自独立）
    ↓
dual_hyperram_ctrl AXI3 共享接口
```

槽位顺序（MSB→LSB）见 `src/top.v:792-795` 的注释与 `796-812` 的打包赋值：
`{cpu, zr, ze, rtl, mask_rd, vid}`，槽 0 在最低位。

> **`AxiShared3Arbiter.v` 是未被实例化的死代码**（仅自身文件定义，全仓库无实例化）。
> 其名字中的 "3" 与当前 6 主控结构无关，请勿据其推断拓扑。

### AXI 突发参数

所有主控的 `asize` 均为 `3'd4`（128-bit = 16 字节），`aburst` 均为 `2'b01`（INCR）。

| 主控 | 方向 | 突发长度 | 说明 |
|------|------|---------|------|
| ElectronicZoomFrameBuffer | W | 16 拍 | 固定 |
| ElectronicZoomFrameBuffer | R | 16 拍 | 固定 |
| ElectronicZoomRasterBuffer | W | 16 拍 | 固定 |
| ElectronicZoomRasterBuffer | R | 16 拍 | 固定 |
| HyperRamMaskOverlayYuv422 | R | 16 拍 | `CACHE_BEATS=16`，按 256 字节块对齐 |
| HyperRamVideoBt656 | W | **可变** | 在 90 拍（720 像素）行边界截断为短突发 |
| HyperRamVideoBt656 | R | **16 拍** | 固定 |
| RtlMaskUartAxiWriter | W | **单拍** | `AWLEN=0`，且 `WSTRB` 每次仅 1 位（单字节窄写） |
| RISC-V CPU | W/R | 由软核决定 | 软件发起，RTL 侧不做约束 |

`HyperRamVideoBt656` 的可变写突发由 `video_burst_len` 与 `write_beats_to_eol = 90 - write_line_beat`
共同决定（`HyperRamVideoBt656.v:98-100,219-222`）。注意**读写方向与常见假设相反**：
可变的是**写**，**读**固定 16 拍。

## 三缓冲协议

### 电子变倍源帧（1280×1024）

三缓冲地址：
- Buffer A: `0x01000000`
- Buffer B: `0x01280000`
- Buffer C: `0x01500000`

**状态变量**（`ElectronicZoomFrameBuffer.v:160-163`）：
```verilog
reg [1:0] write_buffer;      // 当前写入的缓冲
reg       committed_valid;   // committed_buffer 是否有效
reg [1:0] committed_buffer;  // 最近完成的完整帧
reg [1:0] read_buffer;       // 插值器正在读取的缓冲
```

**写端（捕获）**：
```
每帧开始：
    - 使用 buffer[write_buffer]（capture_started 置位）

每像素：
    - 写入当前 write_buffer 缓冲

帧完成（由计数器判定，非 EOF 引脚）：
    - wr_burst_is_eof 在包含像素 FRAME_PIXELS-1 的突发处置位
    - committed_buffer = write_buffer；committed_valid = 1
    - write_buffer = third_source_buffer(read_buffer, write_buffer)
                    // 取既非 read 也非 write 的第三个缓冲

损坏帧（capture_drop_epoch 变化）：
    - 立即中止本帧（capture_started <= 0），丢弃后续像素
    - 直到下一个干净 SOF 才恢复捕获
    - committed_buffer / write_buffer 均不变
```

**读端（插值器）**：
```
Z_WAIT 且 committed_valid && SOF：
    - read_buffer = committed_buffer
    - read_epoch = wr_epoch
    - 锁定整帧使用该缓冲
```

**关键特性**：
- 三个缓冲允许：写当前帧 + 读上一帧 + 一个已完成待消费帧
- 永不在同一缓冲同时读写
- 损坏帧不会污染 committed 缓冲

### CVBS 显示帧（720×576）

三缓冲地址：
- Buffer 0: `0x00C00000`
- Buffer 1: `0x00D00000`
- Buffer 2: `0x00E00000`

**状态变量**（`HyperRamVideoBt656.v:198,234-237`）：
```verilog
reg [1:0] write_buffer;      // 缩放输出正在写入的缓冲
reg       frame_pending;     // 是否有已完成帧待显示
reg [1:0] pending_buffer;    // 已完成待显示帧所在的缓冲
reg [1:0] display_buffer;    // PAL 格式化器正在显示的缓冲
reg       display_valid;     // display_buffer 是否有效
```

注意这里**没有 `committed_buffer`**：最近完成帧由 `frame_pending` + `pending_buffer`
这一对变量表达。

**写端（缩放输出）**：
```
每帧开始（can_start_frame 条件满足才启动）：
    - can_start_frame = display_valid && !write_frame_active
                        && (write_buffer != display_buffer)
                        && (!frame_pending || (write_buffer != pending_buffer))
    - 条件不满足时收到 SOF → rejected_sof_count++

帧完成（720×576 完整，计数器判定）：
    - frame_pending = 1；pending_buffer = write_buffer
```

**PAL 格式化器（读端）**：
```
每个 PAL 像素：
    - 从 buffer[display_buffer] 读取

PAL 完整帧边界：
    - 像素域在帧末翻转 output_frame_toggle
    - 经两级同步器同步到 AXI 域（pal_toggle_a1/a2），
      与 pal_toggle_seen 异或得到 pal_frame_boundary_axi
    - 置 pal_boundary_pending，并递增 pal_frame_boundary_count

ST_RUN 且 read_frame_complete && pal_boundary_pending：
    - if (frame_pending):
        display_buffer = pending_buffer
        if (!write_frame_active) write_buffer = display_buffer
        frame_pending = 0
        frame_switch_count++
```

边界检测用的是 **toggle CDC**，不是 625 行计数器。

**诊断计数器**：
- `rejected_sof_count`：SOF 到达但 `can_start_frame` 不满足（含捕获中途再遇 SOF）
- `frame_switch_count`：**显示缓冲切换次数**（不是 PAL 边界次数）
- `pal_frame_boundary_count`：PAL 帧边界次数（独立的第二个计数器）

**三缓冲的好处**：
- 双缓冲下 PAL 边界未到达时无法接收新帧，`rejected_sof_count` 会很高
- 三缓冲下 PAL 可继续显示旧帧，同时接收两个新帧，`rejected_sof_count` 显著降低
- 注：这属于设计意图叙述，**旧双缓冲版本已不在本检出中**，无法从当前 RTL 直接验证

### 双缓冲（掩膜）

掩膜基地址由 `raw_mode` 与 `active_buffer` 两个维度共同选择
（`HyperRamMaskOverlayYuv422.v:106-108`）：

```verilog
wire [31:0] selected_base = pixel_raw ?
    (pixel_buffer ? RTL_MASK1_BASE : RTL_MASK0_BASE) :   // 0x00B0_0000 / 0x00A0_0000
    (pixel_buffer ? MASK1_BASE    : MASK0_BASE);         // 0x0050_0000 / 0x0040_0000
```

- `pixel_raw`（`raw_mode`）：legacy 全屏画布 vs raw 小图
- `pixel_buffer`（`mask_buffer_select`）：A/B 双缓冲

**状态变量**：
```verilog
reg active_buffer_select;   // 整帧锁定的读取缓冲（0=A, 1=B）
```

**读端（叠加器）**：
```
SOF 到达那一拍：
    - active_buffer_select <= cfg_buffer（同时锁存 enable/raw/left/top）
    - SOF 像素本身即用新配置

SOF 之后：
    - 整帧使用已锁存的 active_buffer_select，配置不再可变

每块：
    - 命中时预取扫描序上的下一个 256 字节块到另一个 bank
```

**写端（UART 上传，当前位流未使能）**：
```
Python 工具 → ADB → X2000 UART → FPGA UART
    ↓
RtlMaskUartAxiWriter 状态机：
    - 命令 0x86 (begin)：校验 width/height/total，upload_buffer <= ~active_buffer
    - 命令 0x87 (chunk)：单字节窄写（AWLEN=0、WSTRB 单比特），写入非活动缓冲
    - 命令 0x88 (position)：写 left/top；若字节数已收齐则
                            active_buffer <= upload_buffer（RTL 自主切换，无需软核参与）
    - 命令 0x89 (enable)：写 mask_enable
    - 校验：CRC-16/CCITT（多项式 0x1021）覆盖 BODY，校验失败不执行命令

协议帧：BB | body_length[15:0] | 06 | command | 00 | payload | crc[15:0] | AA
```

**无撕裂保证**：SOF 边界切换，整帧使用同一缓冲。

> **当前位流说明**：上述纯 RTL 上传与寻址路径由 `rtl_mask_mode` 使能，而它被硬接为
> `1'b0`（`src/top.v:493`）。因此实际生效的是 RISC-V AXI 路径：
> `mask_enable = mask_cfg_video[1]`、`mask_buffer_select = mask_cfg_video[0]`
> （`src/top.v:1431-1432`），且 `raw_mode` 恒为 0（走 legacy 分支）。
> `RtlMaskUartAxiWriter` 在 `!enable` 时 parser 复位、不解析任何包
> （`RtlMaskUartAxiWriter.v:257-261`），`top.v:1429-1430` 的注释称其为板级验证前的
> commissioning fallback。

## AXI 仲裁策略

### 加权轮询

`AxiSharedFlatFabric` 对**读通道与写通道各自独立**做加权轮询，权重表示
"连续授权多少次完整突发后才轮转到下一主控"（`AxiSharedFlatFabric.v:113-148`）：

```
if (!busy && request[last_owner] && (owner_run_count < WEIGHTS[last_owner]))
    保持 last_owner
else
    从 (last_owner + 1) 起顺序搜索第一个有请求的主控
```

**权重表**（`src/top.v:856-858`，槽序 MSB→LSB）：

| 槽 | 主控 | 权重 | 占比 |
|----|------|------|------|
| 5 | cpu（RISC-V axiM） | 1 | 1/13 ≈ 7.7% |
| 4 | zr（栅格缓冲） | **4** | 4/13 ≈ 30.8% |
| 3 | ze（变倍源帧） | **4** | 4/13 ≈ 30.8% |
| 2 | rtl（UART 掩膜写） | 1 | 1/13 ≈ 7.7% |
| 1 | mask_rd（掩膜读） | 1 | 1/13 ≈ 7.7% |
| 0 | vid（视频 DMA） | 2 | 2/13 ≈ 15.4% |

> **与旧版文档的差异**：本模块**没有**固定优先级、**没有**饥饿检测/超时强制授权、
> **没有**针对 PAL FIFO 欠载的短路径。原文档所述"帧缓冲写 > 掩膜读 > 电子变倍"的
> 优先级顺序与 RTL 相反：按权重，**电子变倍源帧/栅格缓冲最高（4），视频 DMA 居中（2），
> 掩膜读与 CPU 最低（1）**。

**唯一的方向性公平机制**：共享地址通道在读写候选同时就绪时交替方向
（`addr_select_write = !last_addr_write`，`AxiSharedFlatFabric.v:153-159`），
防止读/写地址互相饿死。每个方向的 owner 在接收后仍各自独立。

### 权重与带宽配额的观察

按上表权重，各主控的稳态带宽配额与其实际需求并不对齐，值得在改动仲裁权重时留意：

| 主控 | 需求（按 RTL 结构推导，见下节） | 权重配额 |
|------|-------------------------------|---------|
| ze（源帧捕获写 + ROI 读） | 78.6 + 78.6 = 157.2 MB/s | 30.8% |
| zr（栅格写 + 读） | 与 ze 同量级 | 30.8% |
| vid（显示帧写 + 回读校验） | 24.9 + 24.9 = 49.8 MB/s | 15.4% |
| mask_rd | 2.8 MB/s（raw）/ 12.4 MB/s（legacy） | 7.7% |

观察：在总需求接近 HyperRAM 可用带宽时，配额按权重成比例分配意味着
**视频 DMA 只能拿到约 15%**。若要让视频路径（PAL FIFO 欠载最敏感）获得更高保障，
需要提高 `vid` 权重，而不是依赖某个并不存在的短路径。
HyperRAM 的实际可用带宽取决于器件与时序，**无法从本仓库核实**，故此处不做定量结论。

### 写响应处理

- `HyperRamVideoBt656` 恒置 `bready=1'b1`（`HyperRamVideoBt656.v:110-112`），注释说明
  拉低 BREADY 会让响应永久挂起并最终阻塞后续写。
- 其余主控**条件置位** `bready`（在各自的响应状态等待）：如
  `RtlMaskUartAxiWriter.v:157` 的 `bready = (axi_state == AXI_RESP)`。
- **数据路径没有 BRESP 信号**：`AxiSharedFlatFabric` 的 B 通道与
  `dual_hyperram_ctrl` 的 AXI3 共享接口都不携带 `bresp`，因此也不存在
  "记录 BRESP != OKAY" 的计数器。`RiscvVioMonitor` 中确有一个 b_resp 错误计数器，
  但它监视的是 RISC-V CPU 总线，且其 `axi_b_resp` 在 `src/top.v:1499` 被硬接为
  `2'b00`，永不触发。

## 双片 HyperRAM 配置

当前设计**始终使用双片 HyperRAM**，不存在单/双模式选择信号
（`src/top.v:924` 实例化 `dual_hyperram_ctrl`，`DUAL_RAM=1`、`INDIVI_DUAL_CAL=1`；
`top.v:102-136` 连接 `hbc_*`（片 1）与 `hbc_*_2`（片 2）两组物理引脚）。

**数据分拆**：
- 单次 AXI 128-bit 访问 → 两片各承担 64-bit
- `HyperRamVideoBt656.v:60-61` 的注释明确："在双 HyperRAM 模式下，128-bit 字的高、低
  64 位分别对应两条内存通道"

> **待核实**：低 64 位 → 片 1、高 64 位 → 片 2 的实际路由，以及文档中常见的地址位划分
> （`[31:7]` 块 / `[6:4]` 字 / `[3:0]` 字节），**实现在加密的 Efinity IP 内部**
> （`ip/dual_hyperram_ctrl/dual_hyperram_ctrl.sv` 大量 `pragma protect`），
> 可读 RTL 无法验证。

**完整性检查独立于双片结构**：
- `HyperRamVideoBt656` 对每帧写入时折叠出 16-bit XOR 签名（每 128-bit 字的高、低 64 位各一个）
- 线性读回路径重算签名并在帧末比较
- 只有 **error** 计数是独立的：`integrity_low64_errors` / `integrity_high64_errors`
  （声明 `HyperRamVideoBt656.v:63-64`，递增 `566-571`），另有 `integrity_checked_frames`（`:62`）
- **没有独立的 "good" 计数器**（good 可由 checked − errors 推出）
- 首错现场被捕获到 `integrity_first_expected/actual_low64/high64`（`67-70,572-581`）

## 内存访问模式

### 电子变倍捕获（写）

**AXI 突发模式**：
```
地址生成：
    base = source_frame_base(write_buffer)
    addr = base + (line * 1280 * 2) + (x * 2)      // 行跨距 2560 字节

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

**四行缓存结构**（`ElectronicZoomFrameBuffer.v:307-316`）：
```
line0..line3，每个 160 × 128-bit 条目
= 160 × 16 字节 = 2560 字节 = 1280 像素 × 2 字节（一整条源行）
```
条目宽度与 AXI 位宽一致（128-bit）。代码注释说明这样避免了重打包寄存器，
且相比早先的 256-bit 条目把每个插值窗口的 mux 规模减半。

**ROI 行读取**：
```
每输出行需要的源行上下文（固定 4 行）：
    need_y0..y3 = sy_int-1 .. sy_int+2（在 0..1023 处钳位）

四行缓存跨行复用：仅当某行 tag 未命中才发起读取
    - 每次读取一整条 1280 像素源行（10 个 256 字节突发）
    - 缓存只在帧开始/换帧时整体失效

因此每输出行的实际读取量取决于变倍倍率，而非固定 4 行：
    - 1x（sy_int 每输出行 +1）：每输出行补读 1 条新行 = 2560 字节
    - 放大（sy_int 增长慢于输出行）：每输出行补读量更少
```

**最坏情况**：1x 全帧，即每输出行 2560 字节。

### CVBS 帧缓冲写入（场序组织）

**PAL 625i 场序**（`HyperRamVideoBt656.v:203-212`）：
```
渐进帧在内存中重排为"先偶场、后奇场"：
    内存行 0..287   = 源行 0, 2, 4, ..., 574
    内存行 288..575 = 源行 1, 3, 5, ..., 575

线性读回该帧即可得到正确的两个 PAL 场。

地址计算：
    target_line = FLIP_LIVE_VIDEO_VERTICAL ? (575 - write_line) : write_line
    field_line  = target_line[9:1] + (target_line[0] ? 288 : 0)
    offset      = field_line * 1440 + write_line_beat * 16
```

**可变突发长度**：
- 行内大部分位置：16 拍（128 像素 = 256 字节）
- 接近行尾：`write_beats_to_eol = 90 - write_line_beat`，不足 16 拍时按剩余拍数截断

**垂直翻转选项**：
- `FLIP_LIVE_VIDEO_VERTICAL=1` 时反向行序
- 用于 180 度旋转（配合水平翻转）

### 掩膜读取

**预取机制**（`HyperRamMaskOverlayYuv422.v:45-50,115-119,208-218`）：
```
两个 bank，各 16 拍 × 128-bit = 256 字节

命中（cache_hit）时：
    - 服务当前像素的 bank 不动
    - 把"扫描序上的下一个 256 字节块"（block_addr + 256）预取进另一个 bank

缺失（cache miss）时：
    - 必须停下等读，用 replace_bank 轮换选择被替换的 bank

块地址按 256 字节对齐：block_addr = {pixel_addr[31:8], 8'b0}
```

注意预取目标是**扫描序下一块**（不区分该块来自哪一行），不是"A 缓存 / B 缓存"这种
按缓存编号的乒乓；粒度也是**每块 256 字节**而非"每行 256 字节"
（一条 420 字节的 raw 行会跨越两块，一条 720 字节的 legacy 行会跨越三块）。

**避免阻塞**：
- 单拍读会每像素停顿等待 HyperRAM 延迟
- 预取突发读一次取 256 字节，把延迟分摊到 256 个像素上
- 缺失时仍会阻塞视频流，因此缓存命中率直接决定有无 FIFO 溢出风险

### 掩膜混合语义

**纯替换，无 alpha 混合**（`HyperRamMaskOverlayYuv422.v:160-162`）：

```verilog
m_data = (use_mask_pixel && cache_hit && (mask_byte != 8'h00)) ?
         16'h80EB : s_data;
```

- 掩膜字节**非零** → 替换为纯白（`16'h80EB`，即 studio-range 的 Y=235, Cb=Cr=128）
- 掩膜字节**为零** → 原像素透传
- **不存在**半透明/透明度/alpha 混合的任何通路

## 性能分析

> 本节数字**全部按 RTL 结构推导**（`宽 × 高 × 每像素字节 × 帧率`），
> 帧率按 30 fps 计。凡涉及器件实测（HyperRAM 延迟、实际总线占用率）的条目
> 均标注为无法在本仓库核实。

### 带宽计算

| 流量 | 算式 | 结果 |
|------|------|------|
| 电子变倍捕获写 | 1280×1024×2×30 | 78.64 MB/s |
| 电子变倍 ROI 读（1x） | 1024 行 × 2560 B × 30 | 78.64 MB/s |
| CVBS 显示帧写 | 720×576×2×30 | 24.88 MB/s |
| CVBS 完整性读回 | 同显示帧数据量 | 24.88 MB/s |
| 掩膜读（legacy，当前不可达） | 720×576×**1**×30 | 12.44 MB/s |
| 掩膜读（raw） | 420×220×**1**×30 | 2.77 MB/s |

**视频四客户端合计**（1x 变倍、raw 掩膜）：
- 78.64 + 78.64 + 24.88 + 24.88 + 2.77 ≈ **210 MB/s**

**外加上**：
- `ElectronicZoomRasterBuffer` 的栅格写 + 读（栅格结果帧同样 1280×1024，量级与源帧同级）
- RISC-V CPU 的固件/工作区访问（软件发起，无法从 RTL 推导）
- HyperRAM 刷新开销

> 原文档给出的 492.75 MB/s 与 "VIO 实测 ~60-70% 占用率" 已删除：
> 前者基于掩膜 ×2 字节与"每输出行读 4 行"两个错误假设，后者无法从本仓库核实。

### 时序裕度

**100 MHz AXI 时钟**：
- 时钟周期：10 ns
- 16 拍突发：160 ns，传输 256 字节 → 理论吞吐 1.6 GB/s

**HyperRAM 侧**：
- `dual_hyperram_ctrl` 的 DDR 速率、初始访问延迟、突发后续拍时序
  **由加密 IP 与时序约束决定，本仓库无法核实**，故不给具体纳秒值。

### 优化建议

按上述推导，带宽压力最集中在电子变倍路径（捕获写 + ROI 读合计约 157 MB/s），
且其在仲裁中的权重已是最高的 4。可考虑的方向：

1. **提高视频 DMA 权重**：当前 `vid` 权重 2（约 15% 配额），而其写 + 回读校验合计
   约 50 MB/s。若 PAL FIFO 欠载成为实际问题，调整权重比寻找短路径更直接——
   后者在 RTL 中并不存在。
2. **缩短 ROI 读的过取**：每条源行按整条 1280 像素读取（2560 字节），
   而 ROI 可能只用到其中一小段。按 ROI 边界收窄读取可显著降低该路径流量。
3. **掩膜预取深度**：预取已是"下一顺序块"，若要进一步抗缺失，需增加 bank 数或块大小，
   但这会挤占 BRAM；当前 2×256 字节在 legacy 720 字节行跨三块时余量有限。
4. **突发长度**：16 拍已把初始延迟摊到 256 字节；加大到 32 拍可再降低延迟占比，
   但会拉长单主控占用时间，与加权轮询的公平性存在权衡。
