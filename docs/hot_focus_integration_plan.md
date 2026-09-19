# TI60-239 热点追踪集成方案

## 1. 文档目的

本文档给出热点追踪功能在 TI60-239 工程中的完整集成方案。方案基于
`src/pre_hot_focus` 中的 T120 参考代码，但不直接照搬其器件例化、分辨率、
数据格式和时钟结构。

本文档只描述实施方案，不包含 RTL 修改。正式开发以本文档中的时钟边界、
数据流、帧完整性和接口定义为准。

## 2. 已确认的设计约束

1. 热点检测位于 `Bt1120Decoder` 之后、电子变倍之前。
2. 十字丝绘制也位于电子变倍之前。
3. `Bt1120Decoder` 输出为 1280×1024、8-bit Y + 8-bit C 的 YUV422
   有效像素流。
4. 热点检测、十字丝绘制和电子变倍输入处理统一使用内部 `clk`，不直接使用
   外部 `bt1120_clk`。
5. 现有 Decoder 到电子变倍之间的异步 FIFO 边界需要前移到热点模块之前。
6. T120 的 `LineBuf`、`window_mean`、`Filter_Function_mean` 和
   `lpm_divide` 可以作为移植来源；其中 RAM 相关例化必须针对 TI60F225
   重新确认或重新生成。
7. 允许增加 DSP，但仍需通过综合和布局布线报告确认资源及频率满足要求。
8. 热点结果允许以相邻帧结果驱动当前帧十字丝，不要求热点元数据与
   HyperRAM 中的显示帧做严格帧号配对。

## 3. 当前工程输入路径

当前数据路径为：

```text
BT.1120 pins
    |
    | bt1120_clk
    v
Bt1120Decoder
    |- 识别 SAV/EAV
    |- 提取 1280x1024 有效区
    |- 根据 y_from_high 拆分 Y/C
    |- 生成 pixel_x/pixel_line
    `- 生成 valid/SOF/EOF/SOL/EOL
    |
    v
ElectronicZoomFrameBuffer 内部输入前端
    |- VideoAsyncFifo: bt1120_clk -> clk
    |- input_drop_epoch/input_drop_episode
    |- FIFO overflow 检测
    |- 损坏帧放弃及 SOF 恢复
    `- HyperRAM source frame 捕获
```

电子变倍之前不存在额外的 ISP、位宽压缩或图像增强。公共输入处理主要由
`Bt1120Decoder` 完成；电子变倍模块内部还包含一段与帧完整性绑定的 CDC
输入前端。

`ElectronicZoomFrameBuffer` 当前并不直接使用 `bt_dec_word`，而是使用已经
标准化的独立 `bt_dec_y` 和 `bt_dec_c`。热点模块也必须使用这两个信号，不能
再次判断 BT.1120 高低字节。

## 4. 目标总体架构

### 4.1 数据路径

```text
                         bt1120_clk domain

BT.1120 -> Bt1120Decoder -> PreZoomVideoIngress 写端
                                      |
                                      | async FIFO
                                      v
                              clk domain

                         PreZoomVideoIngress 读端
                                      |
                                      v
                              HotFocusCal
                         监听叠加前的 Y 数据
                                      |
                                      v
                         HotFocusCrosshairYuv422
                                      |
                                      v
                    ElectronicZoomFrameBufferCapture
                                      |
                          HyperRAM source buffers
                                      |
                         电子变倍与 raster 输出
                                      |
                         DVP/CVBS 公共后续路径
```

热点计算和十字丝绘制都位于电子变倍之前，但位于异步 FIFO 之后。因此二者和
电子变倍输入捕获核心使用相同的内部 `clk`。

### 4.2 选择内部 `clk` 的原因

- 外部 `bt1120_clk` 只负责采集和写入 FIFO，后处理逻辑与外部时钟隔离。
- 热点检测、十字丝、电子变倍配置和 HyperRAM 写入位于同一时钟域。
- T120 参考模块原有的 ready/valid 流控可以继续使用。
- 热点检测处理的是已经成功进入 FIFO、准备交给电子变倍的像素流。
- 热点坐标不需要从 `bt1120_clk` 跨入 `clk`。
- 电子变倍 ROI 可以直接提供给热点搜索逻辑，不需要新增配置 CDC。

代价是需要重构 `ElectronicZoomFrameBuffer` 的输入边界。该重构必须保持原有
溢出帧处理语义，不能只移动 `VideoAsyncFifo` 实例。

## 5. PreZoomVideoIngress 设计

建议新增：

```text
src/input/PreZoomVideoIngress.v
```

该模块从 `ElectronicZoomFrameBuffer` 中抽取以下现有逻辑：

- `VideoAsyncFifo #(.WIDTH(21), .ADDR_W(13))`；
- `input_drop_epoch`；
- `input_drop_episode`；
- 写侧 `input_fifo_overflow` 检测；
- 完整视频数据包的跨时钟传输。

跨时钟数据包保持现有格式：

```text
bit 20     drop_epoch
bit 19     SOF
bit 18     EOF
bit 17     SOL
bit 16     EOL
bit 15:8   C
bit 7:0    Y
```

建议的读侧接口为：

```verilog
output [7:0] m_y;
output [7:0] m_c;
output       m_valid;
output       m_sof;
output       m_eof;
output       m_sol;
output       m_eol;
output       m_drop_epoch;
input        m_ready;
```

BT.1120 是不可回压源。FIFO 写满时继续使用 epoch 翻转标记受损帧，而不是
尝试向 Decoder 施加 ready。

## 6. 内部 `clk` 域流控

FIFO 读侧、热点计算、十字丝和电子变倍捕获端组成一条 ready/valid 链：

```text
ElectronicZoom capture_ready
    -> Crosshair s_ready
    -> HotFocusCal s_ready
    -> PreZoomVideoIngress m_ready
```

所有模块只在以下条件成立时推进状态：

```verilog
pixel_fire = pixel_valid && pixel_ready;
```

包括：

- X/Y 计数；
- 行缓存地址；
- 3×3 窗口寄存器；
- 加法流水线 valid；
- 最大值搜索；
- 十字丝像素坐标；
- 电子变倍输入像素计数。

禁止出现 `valid=1, ready=0` 时像素不移动但热点窗口或坐标继续移动的情况。

## 7. 损坏帧处理

原工程通过 `drop_epoch` 标记 FIFO 溢出事件。FIFO 前移后，电子变倍捕获核心
仍需保留当前行为：

1. 只从干净 SOF 开始捕获；
2. 当前帧内发现 epoch 改变时放弃整帧；
3. 不发布未完整写入的 HyperRAM source frame；
4. 等待后续干净 SOF 恢复。

热点计算模块也必须接收 `drop_epoch`：

- 在 SOF 锁存本帧 epoch；
- 帧内 epoch 改变时设置 `frame_corrupt`；
- 损坏帧可以继续排空，但不得发布其热点结果；
- 下一次干净 SOF 清除候选最大值并重新统计。

这样十字丝不会使用 FIFO 溢出造成的错误热点坐标。

## 8. 热点计算模块

### 8.1 文件组织

正式代码建议整理为：

```text
src/hot_focus/
    HotFocusCal.v
    HotFocus3x3Max.v
    HotFocusLineBufTi60.v
    window_mean.v
    Filter_Function_mean.v
    lpm_divide.v
```

`lpm_divide.v` 作为已验证的通用依赖保留时，应由工程文件明确纳入，但只有在
实际存在坐标除法需求时才实例化。当前“检测和绘制都在变倍前”的坐标路径不
需要除法器，不能为了复用而增加无功能用途的逻辑。

### 8.2 参数适配

当前输入为 1280×1024、8-bit Y：

```text
DATA_WIDTH       = 8
FRAME_WIDTH      = 1280
FRAME_HEIGHT     = 1024
FRAME_WIDTH_BIT  = 11
FRAME_HEIGHT_BIT = 10
```

热点坐标接口必须为：

```verilog
hot_x[10:0]  // 0..1279
hot_y[9:0]   // 0..1023
```

参考代码中的 10-bit X 和 9-bit Y 不足以表示当前分辨率。

### 8.3 计算方法

保留 T120 算法语义：

1. 两级行缓存形成连续三行；
2. `window_mean` 形成 3×3 窗口；
3. `Filter_Function_mean` 通过流水加法树计算九点和；
4. 在有效搜索区域内寻找一帧最大值；
5. 在下一帧边界发布上一完整帧结果。

8-bit 输入的 3×3 最大和为：

```text
9 * 255 = 2295
```

12 bit 可以完整表示，但可保留参考加法树更宽的结果接口以减少修改。

相同最大值建议继续使用严格 `>` 比较，使扫描顺序中第一个最大点获胜，结果
具有确定性。

### 8.4 数据语义

本工程在 Decoder 后只能获得 8-bit YUV 亮度，不是 T120 原始 14-bit
辐射数据。因此该功能检测的是显示亮度意义上的热点：

- 白热模式：搜索最大 3×3 Y 和；
- 如需黑热支持：增加 polarity，并搜索最小 3×3 Y 和。

如果机芯伪彩或 LUT 与实际温度不保持单调关系，检测结果不能等同于物理温度
最高点。这是输入数据源的能力边界，不是 3×3 算法能够修正的问题。

## 9. T120 依赖的 TI60 适配

### 9.1 `window_mean`

该模块是纯 RTL，可以保留三级水平移位结构。适配内容：

- `WIDTH=8`；
- 所有寄存器增加明确复位；
- 仅在 `pixel_fire` 时移动窗口。

### 9.2 `Filter_Function_mean`

四级加法树可以复用。需要将数据 valid、坐标和帧状态按相同拍数延迟，不能
只延迟计算结果。

### 9.3 `LineBuf`

控制接口可以复用，但底层 RAM 需要针对 TI60F225 重新例化或生成。

热点算法至少需要两个 1280×8 行缓存。若继续保留参考代码用 LineBuf 延迟
坐标的结构，还需要约 1282 深度的 X/Y 延迟缓存。所有实例必须连接 reset；
参考 `add_up_3x3_max.v` 中未连接 LineBuf reset 的写法不能保留。

TI60 RAM 适配必须验证：

- `EFX_RAM10` 或生成 BRAM IP 的端口宽度和深度；
- 同步读延迟；
- read-during-write 模式；
- `pixel_fire=0` 时地址及输出保持；
- 复位后首次两行数据的有效性；
- RTL 仿真模型与综合 RAM 行为一致。

可参考 T120 工程中已有的 `Ti60F225_devkit/BRAM_16x1024` 等生成文件，但不
直接复制整个生成目录。正式工程只保留本功能实际需要的最小封装和仿真模型。

### 9.4 `lpm_divide`

T120 的 `lpm_divide.v` 包含 RTL 流水除法实现，不是必须依赖 Intel/Altera
器件原语，可以在 TI60 上综合。

当前架构中热点坐标和十字丝坐标都是变倍前的 1280×1024 坐标，因此：

```text
cross_x = hot_x
cross_y = hot_y
```

不需要坐标除法。若未来把十字丝移动到变倍后，才使用 `lpm_divide` 完成 ROI
到输出画面的坐标映射。

## 10. 十字丝绘制模块

### 10.1 数据格式

参考 `hot_focus_haircross.v` 使用 24-bit YUV444，而当前路径是 16-bit
YUV422，不能直接串接。

应复用并参数化当前工程的 `VideoCrosshairYuv422`，或基于它建立：

```text
src/hot_focus/HotFocusCrosshairYuv422.v
```

接口需要透传完整数据和边界标志：

```verilog
input  [7:0] s_y;
input  [7:0] s_c;
input        s_valid;
input        s_sof;
input        s_eof;
input        s_sol;
input        s_eol;
output       s_ready;

output [7:0] m_y;
output [7:0] m_c;
output       m_valid;
output       m_sof;
output       m_eof;
output       m_sol;
output       m_eol;
input        m_ready;
```

仅在十字丝命中时修改 Y/C，其他像素和所有时序标志原样传递。

### 10.2 绘制顺序

热点计算必须监听十字丝叠加前的 Y：

```text
FIFO output
    |- HotFocusCal 监听原始 Y
    `- HotFocusCrosshair 修改 Y/C -> ElectronicZoom
```

不能用十字丝输出 Y 作为下一帧检测输入，否则高亮十字丝可能参与最大值搜索并
造成自锁。

### 10.3 坐标和帧稳定性

十字丝坐标采用 11-bit X、10-bit Y。热点结果在完整帧结束后发布，十字丝可在
后续 SOF 锁存一次，也可以直接使用帧级稳定结果。考虑到实现成本很低，建议
保留 SOF 锁存，但不建立复杂的输入帧/显示帧元数据队列。

### 10.4 下游效果

十字丝在电子变倍前写入图像，因此：

- 电子变倍会同时缩放图像和十字丝；
- DVP 和 CVBS 都能看到同一个十字丝；
- CVBS 后续水平、垂直翻转会同时翻转图像和十字丝；
- 不需要再对 CVBS 十字丝坐标单独执行 719-X 或 575-Y；
- CVBS 末端原有十字丝实例应从正式路径删除，或只保留为显式 VIO 调试模式。

## 11. 热点搜索区域与电子变倍

第一版不提供独立热点 ROI 命令。热点搜索区域自动跟随电子变倍配置：

- 电子变倍关闭：搜索 `(0,0)-(1279,1023)`；
- 电子变倍打开：搜索电子变倍 ROI。

这样可以避免全画面热点位于变倍 ROI 外，导致十字丝在变倍输出中被裁掉。

热点模块和电子变倍配置均在 `clk` 域。ROI 在干净输入 SOF 处锁存，保证一帧
热点搜索使用同一组边界。必须对 ROI 做合法性检查：

```text
0 <= left <= right < 1280
0 <= top <= bottom < 1024
```

边界处理需结合 3×3 窗口实际中心坐标验证，不能依赖未填充的行缓存数据。

原先讨论的命令：

```text
python tools/send_hot_focus_via_adb.py --roi 0 0 719 575
```

不纳入第一版方案。该命令原意是设置独立热点搜索矩形，而且 720×576 与当前
变倍前的 1280×1024 坐标域不一致。

## 12. 电子变倍模块重构边界

建议将当前 `ElectronicZoomFrameBuffer` 拆分为逻辑上的两层：

```text
PreZoomVideoIngress
    - 外部时钟写入
    - async FIFO
    - overflow epoch

ElectronicZoomFrameBuffer
    - clk 域 ready/valid 输入
    - 损坏帧识别
    - source frame HyperRAM 写入
    - ROI 计算与变倍输出
```

修改后的电子变倍输入接口建议为：

```verilog
input  [7:0] input_y;
input  [7:0] input_c;
input        input_valid;
input        input_sof;
input        input_eof;
input        input_sol;
input        input_eol;
input        input_drop_epoch;
output       input_ready;
```

删除其内部重复的 `input_clk/input_reset/VideoAsyncFifo`，避免出现两个 CDC
入口。原有 HyperRAM 捕获、三缓冲、受损帧放弃和变倍计算逻辑继续保留。

## 13. Enable 行为

热点关闭时：

- 视频仍通过 FIFO、热点模块和十字丝模块；
- 数据完全透明传递；
- 热点行缓存和搜索逻辑可以停止更新或在 SOF 复位；
- 十字丝不绘制；
- 电子变倍行为不受影响。

热点打开时：

1. 在下一次干净 SOF 开始统计；
2. 第一幅完整帧期间不显示尚未有效的十字丝；
3. 第一幅完整帧结束后发布 `hot_valid` 和热点坐标；
4. 从下一幅输入帧开始绘制十字丝；
5. 后续每幅完整帧更新一次坐标；
6. 遇到 drop epoch 变化时保持上一次有效结果或暂时隐藏十字丝，第一版建议
   保持上一次有效结果并增加 `dropped_result_count` 便于诊断。

该功能与 mask Flash 无关，enable 不触发任何 Flash 读取。

## 14. AXI 控制方案

建议新增热点控制 endpoint，历史空闲地址可使用：

```text
HOT_FOCUS_BASE = 0xE104_0000
```

`Ti60AxiControlFabric` 从 3 个 endpoint 扩展到 4 个：

| 基地址 | 模块 |
|---:|---|
| `0xE100_0000` | System/Capability |
| `0xE101_3000` | Electronic Zoom |
| `0xE104_0000` | Hot Focus |
| `0xE104_3000` | Mask |

热点寄存器建议如下：

| 偏移 | 名称 | 内容 |
|---:|---|---|
| `0x00` | `COMMAND` | bit31=commit，bit1=polarity，bit0=enable |
| `0x04` | `STATUS` | active、pending、result_valid、frame_corrupt |
| `0x08` | `RESULT_XY` | 原始热点 X/Y |
| `0x0C` | `RESULT_SUM` | 3×3 和、结果帧序号 |
| `0x10` | `COUNTERS` | 完整结果数、丢弃结果数 |

热点控制寄存器和视频模块都在 `clk` 域；RISC-V `axiA` 仍位于 `clk50M`
域，因此控制配置需要沿用工程的 `ConfigSnapshotCdc`。热点结果返回 AXI 域时
也必须使用稳定快照或 toggle CDC，不能直接采样异步多位坐标。

`Ti60SystemControlRegs.CAPABILITY` 增加：

```text
bit2 = hot focus
```

## 15. 软核与主机工具

软核工程：

```text
D:/Desktop/szkriscv_tongyi_dpc/software/standalone/ivlabIspSoftCore
```

建议新增 BB 协议类别：

```text
category 0x02 = hot focus
```

第一版命令：

| 子命令 | 功能 |
|---:|---|
| `0x01` | enable/disable，并设置 polarity |
| `0x02` | 查询状态和热点结果 |

主机工具接口：

```bash
python tools/send_hot_focus_via_adb.py --enable
python tools/send_hot_focus_via_adb.py --enable --black-hot
python tools/send_hot_focus_via_adb.py --disable
python tools/send_hot_focus_via_adb.py --query
```

第一版不提供 `--roi`，搜索区域自动跟随电子变倍 ROI。

查询结果至少包含：

```text
enable
result_valid
raw_hot_x
raw_hot_y
sum_3x3
frame_sequence
dropped_result_count
```

## 16. 去除的参考冗余

正式实现不保留以下与当前工程无关的参考功能：

- 24-bit YUV444 数据接口；
- `producting_model` 及生产测试色块；
- `no_scaler` 的 384×288 特判；
- T120 固定 640×512 坐标宽度；
- 模块内部水平/垂直翻转；
- T120 输出位置 `x_offset/y_offset`；
- 变倍后坐标映射除法器实例；
- CVBS 路径重复十字丝；
- 未使用的 AXI-Lite 控制壳。

保留的核心内容：

- 两级 LineBuf；
- 3×3 窗口；
- 九点流水加法树；
- ROI 内帧最大值搜索；
- 帧级热点结果；
- YUV422 十字丝叠加。

## 17. 预计代码改动

### 17.1 FPGA 工程

新增：

```text
src/input/PreZoomVideoIngress.v
src/hot_focus/HotFocusCal.v
src/hot_focus/HotFocus3x3Max.v
src/hot_focus/HotFocusLineBufTi60.v
src/hot_focus/window_mean.v
src/hot_focus/Filter_Function_mean.v
src/hot_focus/HotFocusCrosshairYuv422.v
src/control/HotFocusControlRegs.v
```

按实际需要引入：

```text
src/hot_focus/lpm_divide.v
```

修改：

```text
src/top.v
src/scaler/ElectronicZoomFrameBuffer.v
src/control/Ti60AxiControlFabric.v
src/control/Ti60SystemControlRegs.v
工程源文件清单
仿真源文件清单
```

### 17.2 软核工程

新增或修改：

```text
src/hot_focus_controller.c
src/hot_focus_controller.h
src/ti60_239_config.h
src/ti60_control.c
src/ti60_control.h
src/transmit.c
```

### 17.3 主机工具

新增：

```text
tools/send_hot_focus_via_adb.py
```

## 18. 验证计划

### 18.1 单元仿真

热点计算：

- 单个高亮像素与 3×3 高亮区域竞争；
- 最大值位于中央、边缘和四角；
- ROI 内外热点竞争；
- 两个相同最大值的确定性选择；
- valid 连续及随机停顿；
- enable/disable 帧边界；
- FIFO drop epoch 改变后禁止发布结果；
- 白热和黑热模式。

十字丝：

- 1280×1024 坐标范围；
- 左右边界和上下边界裁剪；
- YUV422 Cb/Cr 奇偶相位；
- ready/valid 停顿；
- SOF/EOL 与像素对齐；
- disabled 时逐像素透明。

### 18.2 输入 CDC 与电子变倍回归

- 异步 FIFO 正常跨时钟；
- 人为制造 FIFO overflow；
- epoch 每次 overflow episode 只翻转一次；
- 受损帧不进入 committed source buffer；
- 下一干净 SOF 自动恢复；
- 热点关闭时输出与重构前逐像素一致；
- 电子变倍 1× 和 ROI 模式均保持现有功能。

### 18.3 集成仿真

- 热点十字丝同时出现在 DVP 和 CVBS；
- 电子变倍后十字丝与目标保持重合；
- CVBS 水平/垂直翻转后仍与图像共同变换；
- mask 开关不影响热点计算；
- 十字丝不会被热点计算再次检测；
- 第一帧未产生有效结果时不显示错误坐标。

### 18.4 AXI 和软核测试

- capability bit；
- enable/disable/polarity；
- pending/applied；
- result snapshot；
- query 应答长度和 CRC；
- 不支持 capability 时返回明确错误；
- 原 mask 和电子变倍命令回归。

### 18.5 综合与板级验证

- 记录新增 XLR、RAM10、DSP；
- 检查 `bt1120_clk` 写侧和内部 `clk` 读侧时序；
- 检查热点加法流水线 Fmax；
- 检查所有 CDC 报告；
- 1280×1024 连续输入下无新增 FIFO overflow；
- 白热/黑热实景跟踪；
- 电子变倍切换时热点搜索范围和十字丝行为；
- DVP、CVBS、mask、电子变倍并行运行。

## 19. 实施顺序

1. 抽取并仿真 `PreZoomVideoIngress`，确保电子变倍关闭和开启时视频回归一致；
2. 将 `ElectronicZoomFrameBuffer` 改为内部 `clk` ready/valid 输入；
3. 适配 TI60 LineBuf、窗口和加法树并完成热点单元仿真；
4. 接入 drop epoch 和电子变倍 ROI；
5. 接入变倍前 YUV422 十字丝；
6. 删除或隔离 CVBS 末端重复十字丝；
7. 增加 AXI endpoint 和 capability；
8. 增加软核命令与 ADB 工具；
9. 完成全链路回归、综合、布局布线和板测。

## 20. 验收标准

功能完成需同时满足：

1. 热点计算和十字丝均运行在内部 `clk` 域；
2. 异步 FIFO 位于 Decoder 与热点模块之间；
3. FIFO 溢出不会发布错误热点，也不会提交损坏视频帧；
4. 热点关闭时视频链路逐像素透明；
5. 热点开启后首幅完整有效帧结束才显示十字丝；
6. 十字丝经过电子变倍和后续翻转后仍与目标重合；
7. DVP 和 CVBS 均显示同一热点十字丝；
8. 热点搜索区域自动跟随电子变倍 ROI；
9. mask、电子变倍和原有 UART 命令无功能回退；
10. 综合资源不超器件容量，所有相关时钟满足时序。

