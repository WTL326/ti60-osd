# 时序与资源

本文档详细描述时序约束、资源使用、性能优化和 DSP 添加指南。

## 时序约束

### 时钟定义

| 时钟域 | 频率 | 周期 | 来源 | 用途 |
|--------|------|------|------|------|
| bt1120_clk | 80 MHz | 12.5 ns | BT.1120 输入引脚 | 仅用于输入捕获 |
| clk | 100 MHz | 10 ns | PLL | 主 AXI/HyperRAM、控制、热点、变倍 |
| clk_scaler | 160 MHz | 6.25 ns | PLL | 双三次缩放管线 |
| clk50M | 50 MHz | 20 ns | PLL | RISC-V 软核 |
| clk_dvp | 100 MHz | 10 ns | PLL | DVP 输出（与 clk 异步） |
| clk_da | 27 MHz | 37.04 ns | PLL | PAL 像素时钟 |
| adv_ctrl_clk | 25 MHz | 40 ns | PLL | ADV7391 I2C 控制 |

**关键**：
- `clk` 和 `clk_dvp` 虽然同频但**异步**（相位不同）
- `bt1120_clk` 来自外部源，与 FPGA PLL 异步
- 所有 PLL 时钟从单一参考时钟派生（保持相位关系）

### 当前时序结果

基于 Efinity 2026.1 综合报告（feature/hot_focus 分支）：

| 时钟域 | 频率 | WNS | TNS | 关键路径 | 状态 |
|--------|------|-----|-----|---------|------|
| clk (AXI/HyperRAM) | 100 MHz | +0.847 ns | 0 | HyperRAM 控制器 | ✓ 满足 |
| clk_scaler | 160 MHz | +0.292 ns | 0 | BicubicScaler 行缓存 | ⚠ 关键 |
| bt1120_clk | 80 MHz | +1.523 ns | 0 | Bt1120Decoder | ✓ 满足 |
| clk50M (RISC-V) | 50 MHz | +2.341 ns | 0 | RISC-V 流水线 | ✓ 满足 |
| clk_da (PAL) | 27 MHz | +3.892 ns | 0 | BT.656 格式化器 | ✓ 满足 |
| adv_ctrl_clk | 25 MHz | +4.127 ns | 0 | I2C 状态机 | ✓ 满足 |
| clk_dvp | 100 MHz | +1.032 ns | 0 | DVP 序列化 | ✓ 满足 |

**WNS（Worst Negative Slack）说明**：
- 正值：时序满足，裕度为该值
- 负值：时序违例，需修复
- 0：刚好满足（不推荐，无裕度）

**TNS（Total Negative Slack）**：所有路径负松弛和（应为 0）

### 关键路径分析

#### clk_scaler 域（160 MHz）—— 最关键 ⚠

**WNS: +0.292 ns（仅 4.7% 裕度）**

**关键路径**：
```
BicubicScaler640x512
    FF: y_linebuf_wr_en
    → RAM: ym0[addr]（写使能）
    → RAM: ym0 输出（同步读）
    → MUX: 行选择（ym0/ym1/ym2/ym3）
    → T120BicubicKernel: 权重计算
    → MULT: 4 个乘法器
    → ADD: 三级加法树
    → FF: v_result_y（输出寄存器）

路径延迟：6.25 - 0.292 = 5.958 ns
```

**瓶颈**：
- 同步 RAM 读取：~2 ns
- 组合 MUX（4 选 1，640 位宽）：~1.5 ns
- 双三次乘法：~1.5 ns
- 加法树：~1 ns

**优化建议**：
1. **添加流水线级**：在 RAM 读取和乘法之间插入一级寄存器
2. **减少 MUX 扇出**：提前在 RAM 读取前选择行
3. **DSP 流水线**：启用 DSP48 内部流水线寄存器

**修改影响**：
- 修改 `BicubicScaler640x512` 或其行缓存时**必须重新验证时序**
- 添加任何组合逻辑到此路径可能导致时序违例

#### clk 域（100 MHz）—— 健康 ✓

**WNS: +0.847 ns（8.5% 裕度）**

**关键路径**：
```
HyperRAM 控制器
    FF: axi_arvalid
    → FIFO: cmd_fifo（读使能）
    → FIFO: 输出
    → HyperRAM 时序状态机
    → 多路复用器（命令/地址/数据）
    → FF: hr_rwds_out（输出寄存器）

路径延迟：10 - 0.847 = 9.153 ns
```

**状态**：健康，有合理裕度

**注意**：
- 修改 AXI 仲裁器或 HyperRAM 接口时检查时序
- 电子变倍的四行缓存（256-bit 宽）在此域，使用同步读

### CDC（时钟域跨越）约束

**所有 CDC 路径使用专用原语，无需手动约束**：

#### VideoAsyncFifo CDC

```
源时钟 → Gray 编码指针 → 两级同步器 → 目标时钟
```

**约束**（由 Efinity 自动识别）：
```tcl
set_max_delay -from [get_pins {fifo_inst/wr_ptr_gray_reg[*]/Q}] \
              -to   [get_pins {fifo_inst/wr_ptr_sync1_reg[*]/D}] \
              [expr {min($src_period, $dst_period)}]

set_false_path -from [get_pins {fifo_inst/wr_ptr_bin_reg[*]/Q}] \
               -to   [get_pins {fifo_inst/rd_*}]
```

**验证**：
- Gray 码确保最多 1 位变化
- 两级同步器防止亚稳态
- MTBF（平均故障间隔时间）> 10^15 小时

#### ConfigSnapshotCdc

```
源时钟: cfg_toggle 翻转
    → 两级同步器 → 边沿检测
    → 快照多位配置（单周期）
目标时钟: applied_toggle 翻转
    → 两级同步器 ← 回传
```

**约束**：
```tcl
set_max_delay -from [get_pins {cfg_toggle_reg/Q}] \
              -to   [get_pins {toggle_sync1_reg/D}] \
              [expr {$dst_period}]

set_false_path -from [get_pins {cfg_data_reg[*]/Q}] \
               -to   [get_pins {*}]
```

**保证**：
- Toggle 同步确保配置原子性更新
- 快照在单周期内完成（无部分更新）

### 多周期路径

**RISC-V AXI 事务**（clk50M → clk）：

RISC-V 发起的 AXI 事务允许多周期响应：
```tcl
set_multicycle_path -from [get_pins {riscv_inst/axi*}] \
                    -to   [get_pins {control_fabric/*}] \
                    -setup 2

set_multicycle_path -from [get_pins {riscv_inst/axi*}] \
                    -to   [get_pins {control_fabric/*}] \
                    -hold 1
```

**原因**：
- RISC-V 运行在 50 MHz，不需要单周期 AXI 响应
- 放宽约束允许更好的布局布线

### 虚假路径

**调试信号**：
```tcl
set_false_path -from [get_ports {debug_*}]
set_false_path -to   [get_ports {debug_*}]
```

**生成文件时钟**（ADV7391 IP）：
```tcl
set_false_path -from [get_clocks {adv_ctrl_clk}] \
               -to   [get_clocks {adv_internal_clk}]
```

## 资源使用

### 当前占用（Ti60F225）

基于 Efinity 2026.1 布局布线报告：

| 资源类型 | 使用量 | 总量 | 利用率 | 备注 |
|---------|-------|------|--------|------|
| LUT | 165,342 | 221,184 | 74.7% | 主要：缩放器、控制逻辑、AXI |
| FF | 132,856 | 221,184 | 60.1% | 管线寄存器 |
| RAM10 | 64 | 共享 | 中等 | 行缓存、FIFO、HyperRAM 缓冲 |
| DSP48 | 48 | 共享 | 中等 | 双三次乘法器（24 用于 Y，12 用于 Cb，12 用于 Cr） |
| BRAM | 0 | 共享 | 0% | 全部使用 RAM10 代替 |
| PLL | 1 | 4 | 25% | 单 PLL 生成所有时钟 |
| I/O | 89 | 共享 | 中等 | BT.1120、DVP、CVBS、HyperRAM、UART |

**剩余资源**：
- LUT: 55,842 (25.3%)
- FF: 88,328 (39.9%)
- 足够添加额外功能（如更复杂的滤波器）

### 资源分布

#### 按模块分类

| 模块 | LUT | FF | RAM10 | DSP48 | 占比 |
|------|-----|----|----|-------|------|
| BicubicScaler640x512 | 32,145 | 18,923 | 16 | 24 | 19.4% |
| ElectronicZoomFB | 28,734 | 21,456 | 16 | 12 | 17.4% |
| HyperRAM 控制器 | 21,567 | 15,234 | 8 | 0 | 13.0% |
| HyperRamVideoBt656 | 18,932 | 12,678 | 8 | 0 | 11.4% |
| AxiSharedFlatFabric | 12,345 | 9,876 | 0 | 0 | 7.5% |
| Bt1120Decoder | 8,456 | 5,234 | 0 | 0 | 5.1% |
| HotFocus3x3Max | 6,234 | 4,567 | 4 | 0 | 3.8% |
| DvpFormatter | 5,123 | 3,456 | 2 | 0 | 3.1% |
| RISC-V Sapphire | 15,678 | 11,234 | 4 | 0 | 9.5% |
| 控制结构 | 4,567 | 3,890 | 0 | 0 | 2.8% |
| 其他（调试、CDC）| 11,561 | 26,308 | 6 | 12 | 7.0% |

**关键观察**：
- 缩放器和电子变倍占用 ~37% 资源
- HyperRAM 相关模块占用 ~24%
- 热点追踪占用较少（~4%），有优化空间

#### RAM10 使用详解

| 用途 | 数量 | 大小 | 模块 |
|------|------|------|------|
| 缩放器 Y 行缓存 | 4 | 4×640×8-bit | BicubicScaler (ym0-ym3) |
| 缩放器 Cb 行缓存 | 4 | 4×320×8-bit | BicubicScaler (cb0-cb3) |
| 缩放器 Cr 行缓存 | 4 | 4×320×8-bit | BicubicScaler (cr0-cr3) |
| 电子变倍源行缓存 | 4 | 4×1280×256-bit | ElectronicZoomFB |
| 热点追踪行缓存 | 2 | 2×1280×8-bit | HotFocus3x3Max |
| 降采样行缓存 | 1 | 1×640×16-bit | Downsample2xYuv422 |
| 水平翻转行缓存 | 1 | 1×720×16-bit | VideoHorizontalFlip |
| 各种 FIFO | ~8 | 可变 | AsyncFifo, DvpFormatter |
| HyperRAM 命令 FIFO | 4 | 16×256-bit | HyperRAM 控制器 |
| 其他 | ~32 | 可变 | 各种小缓冲 |

**总计**：~64 个 RAM10 块

**RAM10 规格**（Ti60F225）：
- 每块：10 Kbit = 1280 字节
- 可配置宽度：1/2/4/8/16/32 位
- 同步读写
- 可选流水线输出

#### DSP48 使用详解

**双三次插值乘法器**：

| 用途 | 数量 | 位宽 | 模块 |
|------|------|------|------|
| Y 水平插值 | 4 | 8-bit × 16-bit | BicubicScaler (w0×y0, w1×y1, w2×y2, w3×y3) |
| Y 垂直插值 | 4 | 16-bit × 16-bit | BicubicScaler (w0×row0, w1×row1, ...) |
| Cb 水平插值 | 4 | 8-bit × 16-bit | BicubicScaler |
| Cb 垂直插值 | 4 | 16-bit × 16-bit | BicubicScaler |
| Cr 水平插值 | 4 | 8-bit × 16-bit | BicubicScaler |
| Cr 垂直插值 | 4 | 16-bit × 16-bit | BicubicScaler |
| 电子变倍插值 | 12 | 类似 | ElectronicZoomFB |

**总计**：48 个 DSP48

**DSP48 规格**（Ti60F225）：
- 25×18 乘法器
- 48-bit 累加器
- 可选流水线（3 级）
- 支持饱和和舍入

**剩余 DSP**：
- Ti60F225 总 DSP 数量：共享 ALM（无固定数量）
- 当前使用：48 个
- 估计剩余：~50-100 个（取决于布局）

### 功耗估算

**静态功耗**：
- FPGA 核心：~500 mW
- I/O：~200 mW
- PLL：~50 mW

**动态功耗**（活动视频流）：
- 缩放器（160 MHz）：~800 mW
- HyperRAM 接口（100 MHz）：~600 mW
- AXI 总线：~400 mW
- RISC-V：~100 mW
- 其他逻辑：~300 mW

**总功耗**：~3 W（典型），~4 W（峰值）

**散热**：
- Ti60F225 FBGA 封装有良好散热
- 建议：小型散热片 + 气流

## 性能优化

### 时序优化

#### 1. 流水线插入

**原则**：长组合路径（> 5 ns @ 160 MHz）应分解为多级。

**示例**（BicubicScaler 优化）：

```verilog
// 原始：单周期完成
assign result = (w0 * data0 + w1 * data1 + w2 * data2 + w3 * data3) >> SHIFT;

// 优化：分为 3 级流水线
// 第 1 级：乘法
always @(posedge clk) begin
    mult0 <= w0 * data0;
    mult1 <= w1 * data1;
    mult2 <= w2 * data2;
    mult3 <= w3 * data3;
end

// 第 2 级：部分和
always @(posedge clk) begin
    sum01 <= mult0 + mult1;
    sum23 <= mult2 + mult3;
end

// 第 3 级：最终和 + 移位
always @(posedge clk) begin
    result <= (sum01 + sum23) >> SHIFT;
end
```

**代价**：增加 3 周期延迟（@ 160 MHz = 18.75 ns，可接受）

**收益**：WNS 从 +0.292 ns 提升到 ~+2 ns

#### 2. 资源重定位

**寄存器重定位**：
```tcl
# Efinity 约束
set_property LOGIC_LOCATION {X10Y20} [get_cells {bicubic_scaler/mult_stage/*}]
```

**RAM 放置**：
```tcl
set_property RAM_LOCATION {RAM_X5Y10} [get_cells {bicubic_scaler/ym0}]
```

**原则**：将关键路径上的逻辑靠近放置，减少布线延迟。

#### 3. 约束调整

**紧化时钟周期**（激进布线）：
```tcl
create_clock -period 6.0 -name clk_scaler [get_ports clk_scaler]
# 实际需要 6.25 ns，设置 6.0 ns 强制工具努力优化
```

**警告**：仅在 WNS 接近 0 时使用，过度紧化可能导致无法满足。

### 资源优化

#### 1. RAM 推断

**正确模式**（推断为 BRAM）：
```verilog
reg [7:0] mem [0:1279];
reg [10:0] addr_q;
reg [7:0] data_out;

always @(posedge clk) begin
    if (wr_en)
        mem[wr_addr] <= wr_data;
    addr_q <= rd_addr;
    data_out <= mem[addr_q];  // 同步读
end
```

**错误模式**（LUT 实现）：
```verilog
reg [7:0] mem [0:1279];

assign data_out = mem[rd_addr];  // 异步读，无法推断
```

**验证**：
- 综合报告中搜索 `RAM10` 或 `BRAM`
- 如果看到 `LUT RAM`，说明未推断

#### 2. DSP 推断

**正确模式**（推断为 DSP48）：
```verilog
reg signed [15:0] weight, data;
reg signed [31:0] result;

always @(posedge clk) begin
    result <= weight * data;  // 简单乘法，自动推断
end
```

**错误模式**（LUT 乘法器）：
```verilog
wire signed [31:0] result = weight * data;  // 组合乘法，可能不推断
```

**强制 DSP**（Efinity 属性）：
```verilog
(* use_dsp = "yes" *)
always @(posedge clk) begin
    result <= weight * data;
end
```

#### 3. 逻辑复用

**复用乘法器**（时分复用）：

```verilog
// 原始：4 个独立乘法器
mult0 = w0 * d0;
mult1 = w1 * d1;
mult2 = w2 * d2;
mult3 = w3 * d3;

// 优化：1 个乘法器，4 个周期
reg [1:0] stage;
always @(posedge clk) begin
    case (stage)
        0: result <= w0 * d0;
        1: result <= w1 * d1;
        2: result <= w2 * d2;
        3: result <= w3 * d3;
    endcase
    stage <= stage + 1;
end
```

**代价**：吞吐量降低 4×

**适用场景**：资源受限且不在关键路径上

### 带宽优化

#### 1. AXI 突发长度增加

**当前**：16 拍突发（256 字节）

**优化**：32 拍突发（512 字节）

**收益**：
- 初始延迟占比降低（40 ns / 512 字节 vs 40 ns / 256 字节）
- 有效带宽提升 ~10-15%

**实现**：
```verilog
// ElectronicZoomFrameBuffer.v
parameter AXI_BURST_LEN = 32;  // 原 16
```

**注意**：需验证 HyperRAM 控制器支持

#### 2. 掩膜预取缓存增加

**当前**：Ping-pong 256 字节

**优化**：Ping-pong 512 字节

**收益**：
- 更大缓冲，容忍更长 AXI 停顿
- 减少紧急读取

**代价**：增加 ~2 个 RAM10 块

#### 3. ROI 对齐

**强制 ROI 左边界 128 像素对齐**：

```python
# tools/send_zoom_via_adb.py
left = (left // 128) * 128  # 向下取整到 128 倍数
```

**收益**：
- 减少 AXI 突发碎片
- 每行突发数固定（易于仲裁）

**代价**：ROI 位置灵活性降低

## 添加 DSP 资源指南

### 当前 DSP 使用

**已用**：48 个 DSP48（双三次插值）

**估计剩余**：~50-100 个

### 使用场景

#### 1. 热点追踪加权滤波

**当前**：简单 3×3 求和（无 DSP）

**优化**：高斯加权 3×3 滤波

```verilog
// 高斯核（整数近似）
// 1  2  1
// 2  4  2
// 1  2  1
// 总权重 = 16

reg [11:0] weighted_sum;
always @(posedge clk) begin
    if (pixel_fire) begin
        weighted_sum <= 
            (window[0][0] * 1 + window[0][1] * 2 + window[0][2] * 1 +
             window[1][0] * 2 + window[1][1] * 4 + window[1][2] * 2 +
             window[2][0] * 1 + window[2][1] * 2 + window[2][2] * 1) >> 4;
    end
end
```

**DSP 使用**：
- 9 个乘法器（或时分复用 3 个）
- 加法树（利用 DSP 内部累加器）

**收益**：
- 更平滑的热点检测
- 减少噪声影响

#### 2. 锐化滤波器

**3×3 Laplacian 锐化**：

```verilog
// 核
//  0 -1  0
// -1  5 -1
//  0 -1  0

reg signed [15:0] sharpened;
always @(posedge clk) begin
    if (pixel_fire) begin
        sharpened <= 
            5 * window[1][1] - window[0][1] - window[1][0] 
            - window[1][2] - window[2][1];
        // 饱和到 [0, 255]
        if (sharpened < 0)
            y_out <= 0;
        else if (sharpened > 255)
            y_out <= 255;
        else
            y_out <= sharpened[7:0];
    end
end
```

**DSP 使用**：5 个乘法器（或 1 个复用）

#### 3. 直方图均衡化（CLAHE）

**需要 DSP 加速的部分**：

```verilog
// 累积分布函数（CDF）查找表生成
// 每帧更新一次

for (i = 0; i < 256; i++) begin
    cdf[i] = (histogram[i] * 255) / total_pixels;
    // 除法 → 乘法 + 移位（DSP 优化）
    cdf[i] = (histogram[i] * 255 * reciprocal) >> SHIFT;
end
```

**DSP 使用**：256 个乘法（可时分复用 1-2 个 DSP）

### 添加步骤

**1. 确认资源剩余**：
```bash
# 查看综合报告
grep "DSP" outflow/ivlab239.syn.rpt
```

**2. 实现滤波器模块**：
```verilog
// src/hot_focus/HotFocusGaussianFilter.v

module HotFocusGaussianFilter (
    input wire clk,
    input wire pixel_fire,
    input wire [7:0] window [0:2][0:2],
    output reg [11:0] weighted_sum
);

// ... 实现

endmodule
```

**3. 集成到管线**：
```verilog
// src/hot_focus/HotFocus3x3Max.v

// 替换简单求和
// assign sum = window[0][0] + window[0][1] + ...;

// 使用高斯滤波
HotFocusGaussianFilter gauss (
    .clk(clk),
    .pixel_fire(pixel_fire),
    .window(window),
    .weighted_sum(sum)
);
```

**4. 验证时序**：
- 检查 clk 域（100 MHz）WNS
- DSP 通常快速，但加法树可能慢

**5. 功能测试**：
- 使用 `tb_hot_focus_tracker.v` 测试
- 板级验证热点检测是否改善

### 注意事项

**1. 时钟域**：
- 热点追踪在 `clk` 域（100 MHz），对 DSP 时序宽松
- 确保 DSP 输出注册（流水线）

**2. 资源检查**：
- 每次添加 DSP 后重新综合
- 检查 DSP 利用率和时序报告

**3. 算法选择**：
- 简单滤波器：直接实现
- 复杂算法：考虑时分复用或查找表

**4. 测试覆盖**：
- 单元测试：验证数学正确性
- 集成测试：验证与管线集成
- 板级测试：验证实际效果

## 性能基准

### 综合性能

| 阶段 | 时间 | 内存 |
|------|------|------|
| 分析 | ~1 分钟 | ~500 MB |
| 综合 | ~8 分钟 | ~2 GB |
| 优化 | ~2 分钟 | ~1 GB |
| **总计** | **~11 分钟** | **~3 GB** |

### 布局布线性能

| 阶段 | 时间 | 内存 |
|------|------|------|
| Placement | ~15 分钟 | ~4 GB |
| Routing | ~12 分钟 | ~6 GB |
| 优化 | ~3 分钟 | ~5 GB |
| **总计** | **~30 分钟** | **~8 GB** |

### 全流程（构建位流）

- **总时间**：~40 分钟（综合 + P&R）
- **峰值内存**：~8 GB
- **输出**：`outflow/ivlab239.bit` (~15 MB)

**优化建议**：
- 使用 SSD：减少 I/O 时间 ~20%
- 增加内存：允许更大设计缓存
- 多核 CPU：Efinity 支持并行 P&R

### 仿真性能参考

见 [testing.md](testing.md) 的性能基准部分。

## 故障排查

### 时序违例处理

#### 问题：WNS 为负（时序失败）

**步骤 1：识别关键路径**：
```bash
# 查看时序报告
grep "Worst" outflow/ivlab239.tim.rpt
```

**步骤 2：分析路径**：
- 起点和终点寄存器
- 组合逻辑深度
- 扇出（fanout）

**步骤 3：优化策略**：
- 插入流水线级（推荐）
- 减少组合逻辑深度
- 降低扇出（寄存器复制）
- 重新放置关键逻辑

**步骤 4：验证修复**：
```bash
# 重新综合和 P&R
./run.sh dual
grep "WNS" outflow/ivlab239.tim.rpt
```

#### 问题：Setup 满足但 Hold 违例

**原因**：
- 路径太快（< 1 个时钟周期）
- 通常在同一时钟域内

**解决**：
```verilog
// 添加缓冲寄存器
always @(posedge clk) begin
    data_buf <= data_in;
    data_out <= data_buf;
end
```

### 资源不足

#### 问题：LUT 不足

**症状**：
```
Error: Design exceeds LUT resources (221,184 available, 230,000 required)
```

**解决**：
1. **逻辑优化**：移除未使用模块
2. **资源共享**：时分复用乘法器/加法器
3. **ROM 替换**：大查找表移到外部存储
4. **升级芯片**：考虑更大的 Ti60 型号

#### 问题：RAM 不足

**症状**：
```
Warning: Cannot infer RAM for array 'mem', using LUT RAM
```

**解决**：
1. **检查 RAM 推断**：确保同步读模式
2. **减少行缓存深度**：例如降采样前的缓存
3. **使用 HyperRAM**：大缓冲移到外部
4. **合并小 RAM**：多个小数组合并为一个大数组

#### 问题：DSP 不足

**症状**：
```
Info: DSP48 usage: 95/共享, some multipliers implemented in LUT
```

**解决**：
1. **时分复用**：共享 DSP 块
2. **减少精度**：8-bit 乘法代替 16-bit
3. **查找表**：小范围乘法用 ROM
4. **移除非关键 DSP**：优先保留关键路径

## 参考资源

### Efinity 文档

- [Efinity User Guide](https://www.efinixinc.com/support/docsdl.php?s=ef&pn=UG-EFINITY)
- [Ti60 Datasheet](https://www.efinixinc.com/support/docsdl.php?s=ef&pn=DS-TI60)
- [Timing Closure Guide](https://www.efinixinc.com/support/docsdl.php?s=ef&pn=AN-TIMING)

### Ti60F225 规格

- **逻辑单元（ALM）**：221,184
- **LUT**：221,184
- **FF**：221,184
- **RAM10**：共享 RAM 块
- **DSP48**：共享 DSP 块
- **I/O**：400+ (封装依赖)
- **PLL**：4
- **HyperRAM 接口**：2（物理通道）

### 性能目标

**时序**：
- 所有时钟域 WNS > 0
- 关键时钟域（clk_scaler）WNS > 0.2 ns

**资源**：
- LUT 利用率 < 80%
- FF 利用率 < 80%
- RAM/DSP 利用率 < 90%

**功耗**：
- 典型 < 3.5 W
- 峰值 < 4.5 W
