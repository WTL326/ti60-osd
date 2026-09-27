# 测试与仿真

本文档描述测试策略、仿真环境和工具链配置。

## 测试策略概览

### 分层测试方法

1. **单元测试**（Verilog testbench + Cocotb）
   - 独立模块功能验证
   - 快速迭代（< 5 分钟）
   - 边界条件和错误注入

2. **集成测试**（Verilog testbench）
   - 多模块协同验证
   - CDC 功能测试
   - 数据流完整性

3. **板级验证**（主要方法）
   - 真实硬件测试
   - VIO 探针监控
   - Python 工具控制
   - 完整系统验证

### 测试覆盖率矩阵

| 模块 | 单元测试 | 集成测试 | 板级验证 | 覆盖率 | 测试文件 |
|------|---------|---------|---------|--------|---------|
| Bt1120Decoder | ✓ | ✓ | ✓ | 高 | tb_bt1120_realistic.v |
| PreZoomVideoIngress | ✓ | ✓ | ✓ | 高 | tb_ezfb_fullpath.v |
| HotFocus3x3Max | ✓ | — | ✓ | 高 | tb_hot_focus_tracker.v |
| HotFocusCrosshair | ✓ | — | ✓ | 中 | tb_hot_focus_tracker.v |
| ElectronicZoomFB | ✓ | ✓ | ✓ | 高 | cocotb/test_ezfb_frame |
| Downsample2xYuv422 | — | — | ✓ | 低 | — |
| BicubicScaler640x512 | ✓ | — | ✓ | 中 | tb_scaler_160.v |
| VideoHorizontalFlip | — | — | ✓ | 低 | — |
| HyperRamMaskOverlay | ✓ | — | ✓ | 中 | tb_hyperram_mask_overlay.v |
| HyperRamVideoBt656 | — | — | ✓ | 低 | — |
| DvpFormatter | ✓ | — | ✓ | 高 | tb_dvp_formatter_frames.v |
| Ti60AxiControlFabric | ✓ | — | ✓ | 高 | cocotb/test_control_fabric |
| AxiSharedFlatFabric | ✓ | — | ✓ | 高 | tb_axi_shared_flat_fabric.v |
| T120BicubicKernel | ✓ | — | ✓ | 高 | cocotb/test_t120_bicubic_kernel |

**缺失的顶层集成仿真**：
- 无完整 `top.v` 测试平台
- 原因：RISC-V 加密 IP、HyperRAM vendor IP、仿真时间过长（> 10 小时/帧）

## 仿真环境

### sim 目录结构

```
sim/
├── cocotb/                          # Python Cocotb 测试套件
│   ├── test_control_fabric/        # AXI 控制结构测试
│   │   ├── Makefile
│   │   ├── run.py                  # Windows 运行器
│   │   ├── test_control_fabric.py  # 端点寻址、仲裁
│   │   └── test_zoom_image.py      # 电子变倍寄存器验证
│   ├── test_ezfb_frame/            # 电子变倍帧级测试
│   │   ├── tb_ezfb_frame.v         # Verilog 包装器
│   │   ├── test_ezfb_frame.py      # 帧捕获位精确验证
│   │   ├── test_ezfb_capture.py    # 捕获状态机测试
│   │   ├── test_ezfb_recovery.py   # 损坏帧恢复测试
│   │   └── test_ezfb_unity.py      # 1× 直通测试
│   └── test_t120_bicubic_kernel/   # 双三次内核验证
│       ├── Makefile
│       └── test_t120_bicubic_kernel.py
│
├── tb_bt1120_realistic.v           # BT.1120 解码器真实时序测试
├── tb_ezfb_fullpath.v              # ★ 电子变倍端到端测试
├── tb_hot_focus_tracker.v          # 热点追踪单元测试
├── tb_scaler_160.v                 # 160 MHz 缩放器测试
├── tb_dvp_formatter_frames.v       # DVP 多帧协议验证
├── tb_axi_shared_flat_fabric.v     # AXI 仲裁器测试
├── tb_hyperram_mask_overlay.v      # 掩膜叠加测试
├── tb_video_crosshair_yuv422.v     # 十字丝绘制测试
│
├── modelsim_hot_focus.do           # Questa Sim 脚本
├── modelsim_bt1120.do
├── modelsim_scaler.do
├── modelsim_dvp.do
├── modelsim_axi_arbiter.do
├── modelsim_ezfb_fullpath.do
│
├── run_modelsim_batch.bat          # 批量回归测试
├── run_modelsim_batch.sh
├── modelsim.ini                    # Questa Sim 配置
└── transcript                      # 仿真日志
```

## 关键测试平台详解

### tb_ezfb_fullpath.v — 电子变倍端到端测试 ★★★

**最接近完整管线的仿真测试**（289 行）

#### 覆盖范围

```
BT.1120 时序生成器 (80 MHz)
    ↓
Bt1120Decoder
    ↓
PreZoomVideoIngress (CDC FIFO: 80→100 MHz)
    ↓
ElectronicZoomFrameBuffer
    ↓
HyperRAM AXI 模型 (100 MHz)
```

#### 测试内容

- **真实 LGCS123 时序**：2370 字/行 × 1125 行，1280×1024 有效区
- **80 MHz → 100 MHz CDC 功能**：验证异步 FIFO 正确性
- **源帧捕获到 HyperRAM 三缓冲**：256 字节突发
- **验证 `captured_frame_count` 按 30 fps 递增**
- **检查 `input_fifo_overflow=0`**（8192 深度足够）
- **观察三缓冲 writer/committed/reader 切换**

#### 运行

```bash
cd sim
H:\questasim64_10.6c\win64\vsim -do modelsim_ezfb_fullpath.do
```

**仿真时间**：~2 小时（2 帧完整捕获）

#### 局限性

- 仅测试捕获路径，未测试插值输出
- 无热点追踪集成
- HyperRAM 模型简化（无延迟随机化）

### tb_hot_focus_tracker.v — 热点追踪单元测试

**8×6 小帧快速验证**（131 行）

#### 测试场景

**1. 白热模式（默认）**：
```
图像：8×6 像素，中心 3×3 块值为 200，其余为 50

期望结果：
    hot_x = 3
    hot_y = 2
    hot_sum = 1800 (200 × 9)
    hot_valid = 1
```

**2. 黑热模式**：
```
图像：8×6 像素，偏右下 3×3 块值为 2，其余为 100

期望结果：
    hot_x = 5
    hot_y = 3
    hot_sum = 18 (2 × 9)
    hot_valid = 1
```

**3. 损坏帧恢复**：
```
帧 1：正常图像
帧 2：在坐标 (4,2) drop_epoch 翻转（模拟 FIFO 溢出）
    → 不发布结果
    → dropped_result_count++
帧 3：恢复正常
    → 发布正确结果
```

**4. Valid bubble 测试**：
```
注入停顿条件：(x + y) % 3 == 0 时 valid=0

验证：
    - X/Y 计数器保持
    - 窗口寄存器保持
    - 加法流水线不推进
    - 最终结果仍然正确
```

#### 运行

```bash
cd sim
H:\questasim64_10.6c\win64\vsim -do modelsim_hot_focus.do
```

**仿真时间**：~1 分钟

#### 关键验证点

- `pixel_fire = pixel_valid && pixel_ready` 规则
- 损坏帧不发布结果
- 黑热/白热极性切换
- Ready/valid 流控正确性

### cocotb/test_control_fabric — AXI 控制结构测试

**Python 驱动的协议验证**

#### 测试用例

**test_endpoint_addressing**：
```python
# 验证四个端点地址解码
await axi.write(0xE1000000, 0x12345678)  # SYS
await axi.write(0xE1013000, 0xABCDEF00)  # ZOOM
await axi.write(0xE1040000, 0x11111111)  # HOT
await axi.write(0xE1043000, 0x22222222)  # MASK

# 读回验证
assert await axi.read(0xE1000000) == 0x12345678
```

**test_priority_arbitration**：
```python
# 同时发起四个端点事务
tasks = [
    axi.write(0xE1000000, 0xAAAAAAAA),
    axi.write(0xE1013000, 0xBBBBBBBB),
    axi.write(0xE1040000, 0xCCCCCCCC),
    axi.write(0xE1043000, 0xDDDDDDDD),
]
await asyncio.gather(*tasks)

# 验证所有事务完成且响应正确
```

**test_zoom_register_toggle**：
```python
# 写入电子变倍配置
await axi.write(ZOOM_BASE + OFFSET_LEFT, 320)
await axi.write(ZOOM_BASE + OFFSET_TOP, 256)
await axi.write(ZOOM_BASE + OFFSET_WIDTH, 640)
await axi.write(ZOOM_BASE + OFFSET_HEIGHT, 512)
await axi.write(ZOOM_BASE + OFFSET_CMD, CMD_ENABLE | CMD_COMMIT)

# 等待 applied_toggle 回传
for _ in range(100):
    status = await axi.read(ZOOM_BASE + OFFSET_STATUS)
    if status & STATUS_ACTIVE:
        break
    await Timer(100, units='ns')

assert status & STATUS_ACTIVE
```

**test_axi_backpressure**：
```python
# 随机化 AWREADY/WREADY/ARREADY
axi.enable_backpressure(probability=0.3)

# 验证协议在回压下仍然正确
for addr in [0xE1000000, 0xE1013000, 0xE1040000, 0xE1043000]:
    data = random.randint(0, 0xFFFFFFFF)
    await axi.write(addr, data)
    assert await axi.read(addr) == data
```

#### 运行

```bash
cd sim/cocotb/test_control_fabric
python run.py  # Windows
make           # Linux
```

**仿真时间**：5–10 分钟

#### 自定义 Python 类

**AxiMaster**：
```python
class AxiMaster:
    def __init__(self, dut):
        self.dut = dut
        
    async def write(self, addr, data):
        # AXI4 完整协议
        # 独立 AW/W 通道
        await self._write_address(addr)
        await self._write_data(data)
        await self._get_response()
        
    async def read(self, addr):
        await self._read_address(addr)
        return await self._get_read_data()
```

### cocotb/test_ezfb_frame — 电子变倍帧级验证

**位精确输出对比**（与 T120 Q10 参考）

#### 测试结构

**Verilog 部分**（tb_ezfb_frame.v）：
```verilog
// 确定性图案生成器
pattern_gen #(
    .WIDTH(1280),
    .HEIGHT(1024)
) gen (
    .clk(clk),
    .pixel_x(x),
    .pixel_y(y),
    .y_out(y_pattern),
    .c_out(c_pattern)
);

// DUT
ElectronicZoomFrameBuffer ezfb (
    .clk(clk),
    .input_valid(valid),
    .input_y(y_pattern),
    .input_c(c_pattern),
    // ... AXI 到 HyperRAM 模型
);
```

**Python 部分**（test_ezfb_frame.py）：
```python
import numpy as np
from bicubic_reference import catmull_rom_interpolate

@cocotb.test()
async def test_capture_and_zoom(dut):
    # 1. 捕获完整帧到 HyperRAM 模型
    await capture_frame(dut, pattern='checkerboard')
    
    # 2. 配置 ROI
    await set_roi(dut, left=320, top=256, width=640, height=512)
    
    # 3. 读取插值输出
    output = await read_output_frame(dut)
    
    # 4. NumPy 参考模型
    reference = catmull_rom_interpolate(
        source=hyperram_model.read_buffer(0),
        roi=(320, 256, 640, 512),
        output_size=(1280, 1024)
    )
    
    # 5. 位精确对比
    diff = np.abs(output.astype(int) - reference.astype(int))
    assert np.max(diff) <= 1  # 允许 ±1 舍入误差
```

#### Python HyperRAM 模型

```python
class HyperRamModel:
    def __init__(self):
        self.memory = bytearray(32 * 1024 * 1024)  # 32 MiB
        
    def axi_write(self, addr, data, strb):
        # 随机 ready/valid 回压
        if random.random() < 0.2:
            return False  # WREADY=0
        
        for i, byte_en in enumerate(strb):
            if byte_en:
                self.memory[addr + i] = (data >> (i*8)) & 0xFF
        return True
        
    def axi_read(self, addr, size):
        # 随机延迟 0-10 周期
        delay = random.randint(0, 10)
        for _ in range(delay):
            yield
            
        data = 0
        for i in range(size):
            data |= self.memory[addr + i] << (i*8)
        return data
```

#### 测试用例

- **test_ezfb_capture**：验证捕获状态机和三缓冲切换
- **test_ezfb_recovery**：损坏帧不提交缓冲
- **test_ezfb_unity**：1× 直通模式（无插值）
- **test_ezfb_fast**：快速模式（无完整性检查）

#### 运行

```bash
cd sim/cocotb/test_ezfb_frame
python run.py
```

**仿真时间**：~30 分钟

### tb_scaler_160.v — 160 MHz 缩放器测试

**BicubicScaler640x512 时序验证**

#### 测试内容

- 640×512 → 720×576 缩放
- 160 MHz 时钟时序满足
- 固定 9:8 比例验证
- 输出帧计数器递增

#### 图案

- 渐变图案（验证插值平滑性）
- 棋盘图案（验证边缘锐度）
- 纯色图案（验证无伪影）

#### 运行

```bash
cd sim
H:\questasim64_10.6c\win64\vsim -do modelsim_scaler.do
```

**仿真时间**：~20 分钟

### tb_dvp_formatter_frames.v — DVP 协议验证

**多帧 DVP 时序测试**

#### 验证点

- 16-bit → 8-bit 序列化正确性
- SOL 预填充（32 字）
- VSYNC 提前置位（行空白期间）
- HSYNC = line_active
- FIFO 欠载检测

#### 测试场景

- 正常帧序列（3 帧）
- FIFO 接近满（验证流控）
- DVP 时钟略快于 BT.1120（验证 CDC）

#### 运行

```bash
cd sim
H:\questasim64_10.6c\win64\vsim -do modelsim_dvp.do
```

**仿真时间**：~10 分钟

## 仿真工具链

### Icarus Verilog（开源）

**版本**：0.10+ (支持部分 SystemVerilog)

**优点**：
- 开源免费
- 快速编译
- Cocotb 原生支持
- 跨平台（Windows/Linux/Mac）

**局限**：
- 无法解析加密 IP（RISC-V、HyperRAM vendor IP）
- 部分 SV 特性不支持（接口、类）
- 仿真速度较慢（纯解释执行）

**安装**（Windows）：
```bash
# 使用预编译包
# http://bleyer.org/icarus/

# 或通过 MSYS2
pacman -S mingw-w64-x86_64-iverilog
```

**编译示例**：
```bash
iverilog -g2012 -Wall \
    -DTOP_EXTERNAL_RISCV \
    -I../src/common \
    -I../src/input \
    tb_hot_focus_tracker.v \
    ../src/hot_focus/*.v \
    -o sim.vvp

vvp sim.vvp
```

### Questa Sim（商业）

**版本**：10.6c+

**安装路径**：`H:\questasim64_10.6c`

**优点**：
- 完整 SystemVerilog 支持
- 强大调试（波形、断点、覆盖率）
- 快速仿真（编译 + 优化）
- 支持加密 IP

**局限**：
- 需要商业许可证
- Windows/Linux 专用

#### 快速运行

**GUI 模式**：
```bash
cd sim
H:\questasim64_10.6c\win64\vsim -do modelsim_hot_focus.do
```

**命令行批量回归**：
```bash
cd sim
run_modelsim_batch.bat  # Windows
./run_modelsim_batch.sh  # Linux/Git Bash
```

#### 可用脚本

| 脚本 | 测试内容 | 仿真时间 |
|------|---------|---------|
| modelsim_hot_focus.do | 热点追踪 | ~1 分钟 |
| modelsim_bt1120.do | BT.1120 解码器 | ~5 分钟 |
| modelsim_scaler.do | 双三次缩放器 | ~20 分钟 |
| modelsim_dvp.do | DVP 格式化器 | ~10 分钟 |
| modelsim_axi_arbiter.do | AXI 仲裁器 | ~2 分钟 |
| modelsim_ezfb_fullpath.do | 电子变倍端到端 | ~2 小时 |

#### 脚本结构

```tcl
# modelsim_hot_focus.do

# 创建工作库
vlib work
vmap work work

# 编译源文件
vlog -sv -work work \
    +incdir+../src/common \
    +incdir+../src/hot_focus \
    ../src/hot_focus/HotFocus3x3Max.v \
    ../src/hot_focus/HotFocusCal.v \
    ../src/hot_focus/HotFocusLineBufTi60.v \
    ../src/common/VideoAsyncFifo.v \
    tb_hot_focus_tracker.v

# 仿真
vsim -t ps work.tb_hot_focus_tracker

# 添加波形
add wave -radix unsigned sim:/tb_hot_focus_tracker/hot_x
add wave -radix unsigned sim:/tb_hot_focus_tracker/hot_y
add wave -radix unsigned sim:/tb_hot_focus_tracker/hot_sum
add wave sim:/tb_hot_focus_tracker/hot_valid
add wave sim:/tb_hot_focus_tracker/result_count
add wave sim:/tb_hot_focus_tracker/dropped_result_count

# 运行
run -all
```

#### 批量回归脚本

```bash
# run_modelsim_batch.bat

@echo off
set VSIM=H:\questasim64_10.6c\win64\vsim

echo Running Hot Focus Test...
%VSIM% -c -do "do modelsim_hot_focus.do; quit -f"

echo Running BT.1120 Test...
%VSIM% -c -do "do modelsim_bt1120.do; quit -f"

echo Running AXI Arbiter Test...
%VSIM% -c -do "do modelsim_axi_arbiter.do; quit -f"

echo All tests completed.
pause
```

### Cocotb（Python 测试框架）

**版本**：1.6+，Python 3.7+

**优点**：
- Python 编写测试（不需要 Verilog testbench）
- 随机化和约束支持
- 覆盖率收集
- 易于复杂协议验证（AXI、HyperRAM）

**安装**：
```bash
pip install cocotb cocotb-test
```

**Makefile 示例**：
```makefile
# sim/cocotb/test_control_fabric/Makefile

TOPLEVEL_LANG = verilog
SIM = icarus

VERILOG_SOURCES = \
    ../../../src/control/Ti60AxiControlFabric.v \
    ../../../src/control/Ti60SystemControlRegs.v \
    ../../../src/control/ElectronicZoomControlRegs.v \
    ../../../src/control/HotFocusControlRegs.v \
    ../../../src/control/MaskControlRegs.v

TOPLEVEL = Ti60AxiControlFabric
MODULE = test_control_fabric

include $(shell cocotb-config --makefiles)/Makefile.sim
```

**Python 测试示例**：
```python
# test_control_fabric.py

import cocotb
from cocotb.triggers import RisingEdge, Timer
from cocotb.clock import Clock

@cocotb.test()
async def test_endpoint_addressing(dut):
    # 启动时钟
    cocotb.start_soon(Clock(dut.clk, 10, units='ns').start())
    
    # 复位
    dut.rst_n.value = 0
    await Timer(100, units='ns')
    dut.rst_n.value = 1
    await Timer(100, units='ns')
    
    # AXI 写事务
    axi = AxiMaster(dut)
    await axi.write(0xE1000000, 0x12345678)
    
    # AXI 读事务
    data = await axi.read(0xE1000000)
    assert data == 0x12345678
```

## 板级验证

### 硬件连接

**必需连接**：
1. **BT.1120 输入源**：LGCS123 或其他 1280×1024@30Hz 源
2. **CVBS 输出监视器**：PAL 制式显示器
3. **X2000 UART**：ADB 连接（用于控制命令）
4. **Efinity EDB 调试器**：USB JTAG（用于 VIO 探针）

**可选连接**：
5. **DVP 输出**：X2000 处理器（验证 DVP 路径）
6. **逻辑分析仪**：验证时钟频率和时序

### VIO 探针监控

#### 启用 VIO 调试

在 `ivlab239.xml` 中设置：
```xml
<efx:design_define name="ENABLE_VIO_DEBUG" value="1"/>
```

或在 `top.v` 顶部定义：
```verilog
`define ENABLE_VIO_DEBUG
```

#### 关键探针

| 探针 | 期望值 | 含义 | 异常诊断 |
|-----|--------|------|---------|
| p2_Status | 5 | HyperRAM 校准通过 + 帧良好 | 1=校准但无帧, 0=未校准 |
| p16_ScalerInFrames | 递增 | 缩放器输入帧计数 | 停滞=上游阻塞 |
| p17_ScalerOutFrames | 递增 | 缩放器输出帧计数 | 停滞=缩放器卡死 |
| p18_ScalerDroppedFrames | 0 | 缩放器输入 FIFO 溢出 | >0=处理太慢 |
| p19_ReadFifoUnderflows | 0 | PAL FIFO 欠载 | >0=HyperRAM 读太慢 |
| p21_ScalerCdcOverflow | 0 | 160→100 MHz CDC 溢出 | >0=缩放输出太快 |
| p49_ZoomCapturedFrames | 递增 | 电子变倍捕获帧数 | 停滞=变倍未工作 |
| p50_ZoomOutputFrames | 递增 | 电子变倍输出帧数 | <p49=插值未启用 |
| p51_ZoomAxiErrors | 0 | AXI 错误计数 | >0=HyperRAM 访问错误 |
| p54_HotResultCount | 递增 | 热点追踪结果计数 | 停滞=热点未启用 |
| p55_HotDroppedCount | 0 | 热点追踪丢弃帧 | >0=损坏帧频繁 |
| p56_HotX | 0–1279 | 热点 X 坐标 | 验证十字丝位置 |
| p57_HotY | 0–1023 | 热点 Y 坐标 | 验证十字丝位置 |
| p58_HotSum | 0–2295 | 热点 3×3 和 | 验证亮度阈值 |
| p59_HotValid | 1 | 热点结果有效 | 0=无热点或禁用 |

#### 稳定条件

视频稳定运行的充要条件：
```
p2_Status == 5
p18_ScalerDroppedFrames == 0
p19_ReadFifoUnderflows == 0
p21_ScalerCdcOverflow == 0
p16_ScalerInFrames 持续递增（~30 fps）
```

### Python 工具测试

#### 电子变倍控制

```bash
# 启用变倍，ROI 640×512 @ (320, 256)
python tools/send_zoom_via_adb.py --enable \
    --left 320 --top 256 \
    --width 640 --height 512

# 禁用变倍
python tools/send_zoom_via_adb.py --disable
```

**验证**：
- CVBS 显示从全景切换到放大视图
- DVP 输出同步切换
- VIO: p49/p50 继续递增

#### 热点追踪控制

```bash
# 启用热点追踪（白热模式）
python tools/send_hot_focus_via_adb.py --enable

# 启用热点追踪（黑热模式）
python tools/send_hot_focus_via_adb.py --enable --black-hot

# 禁用热点追踪
python tools/send_hot_focus_via_adb.py --disable
```

**验证**：
- CVBS 和 DVP 显示橙色十字丝
- 十字丝跟随场景中最热（或最冷）点
- VIO: p54 递增, p56/p57 更新, p59=1

#### 掩膜上传

```bash
# 上传 PNG 掩膜到缓冲 A
python tools/send_mask_via_adb.py mask.png --buffer A

# 切换到缓冲 A
python tools/send_mask_via_adb.py --enable --buffer A

# 禁用掩膜
python tools/send_mask_via_adb.py --disable
```

**验证**：
- CVBS 显示掩膜叠加（非零字节替换为纯白 `16'h80EB`，**无 alpha 混合**）
- 掩膜位置和颜色正确
- 切换缓冲无撕裂

### 回归测试清单

修改视频管线后，按此清单验证：

#### 1. 帧计数器验证
- [ ] `p16_ScalerInFrames` 持续递增
- [ ] `p17_ScalerOutFrames` 持续递增
- [ ] `p49_ZoomCapturedFrames` 持续递增（如启用变倍）
- [ ] `p50_ZoomOutputFrames` 持续递增（如启用变倍）
- [ ] `p54_HotResultCount` 持续递增（如启用热点）

#### 2. FIFO 健康检查
- [ ] `p18_ScalerDroppedFrames` 保持 0
- [ ] `p19_ReadFifoUnderflows` 保持 0
- [ ] `p21_ScalerCdcOverflow` 保持 0
- [ ] `p51_ZoomAxiErrors` 保持 0

#### 3. 视频输出质量
- [ ] CVBS 显示稳定图像（无撕裂、闪烁、黑屏）
- [ ] DVP 输出稳定（X2000 正常接收）
- [ ] 电子变倍启用/禁用无损坏帧
- [ ] 热点十字丝位置正确（如启用）

#### 4. 功能验证
- [ ] 电子变倍：ROI 配置立即生效（< 2 帧）
- [ ] 热点追踪：十字丝跟随热点移动
- [ ] 掩膜叠加：掩膜显示正确，切换无撕裂
- [ ] 水平/垂直翻转：图像方向正确

#### 5. 特定路径验证
- [ ] 如修改变倍前路径：热点十字丝保持对齐
- [ ] 如修改 CDC：无丢帧或溢出
- [ ] 如修改 AXI：无访问错误

## 故障排查

### 常见问题

#### 问题：`p2_Status` 卡在 1（已校准但无有效帧）

**原因**：
- BT.1120 输入信号缺失或时序错误
- Bt1120Decoder 未锁定同步

**诊断**：
- 检查 BT.1120 源是否通电
- 验证输入时钟 80 MHz
- 观察 `sync_locked` 信号

**解决**：
- 重新连接 BT.1120 线缆
- 检查源设备输出配置（1280×1024@30Hz）

#### 问题：`p18_ScalerDroppedFrames` 持续增加

**原因**：
- 缩放器输入 FIFO（2048 深度）溢出
- 缩放器处理太慢，无法跟上 100 MHz 输入

**诊断**：
- 检查 160 MHz 缩放器时钟是否正常
- 观察 `BicubicScaler640x512` 状态机

**解决**：
- 验证 PLL 锁定
- 检查时序报告（WNS 应为正值）
- 减少缩放器组合逻辑深度

#### 问题：`p19_ReadFifoUnderflows` 持续增加

**原因**：
- PAL FIFO（2048 深度）欠载
- HyperRAM 读取太慢，无法跟上 27 MHz PAL 输出

**诊断**：
- 检查 AXI 仲裁优先级
- 观察 HyperRAM 带宽使用
- 查看是否有 AXI 停顿

**解决**：
- 提高帧缓冲写入优先级
- 增加 PAL FIFO 深度到 4096
- 使用双 HyperRAM 模式

#### 问题：热点十字丝位置不正确

**原因**：
- Ready/valid 流控违规
- 修改破坏了 `pixel_fire` 规则

**诊断**：
- 波形观察 `valid && ready` 信号
- 检查 X/Y 计数器在 `ready=0` 时是否保持

**解决**：
- 审查修改的模块，确保状态仅在 `fire` 时推进
- 参考 `HotFocus3x3Max` 的正确实现

#### 问题：电子变倍输出黑屏或伪影

**原因**：
- 三缓冲协议破坏
- 插值器读取正在写入的缓冲

**诊断**：
- 观察 `write_buffer`, `committed_buffer`, `read_buffer`（及 `committed_valid`）
- 检查是否有两个索引相同的情况

**解决**：
- 确保帧完成（计数器判定）时正确更新 `committed_buffer` 并置 `committed_valid`
- 确保 Z_WAIT 且 SOF 时 `read_buffer = committed_buffer`
- 损坏帧不更新 `committed_buffer`（且会立即中止本帧）

## 性能基准

### 仿真性能

| 测试 | 仿真器 | 仿真时间 | 覆盖帧数 | 时间/帧 |
|-----|-------|---------|---------|---------|
| tb_hot_focus_tracker | Questa | 1 分钟 | 4 帧 | 15 秒 |
| tb_ezfb_fullpath | Questa | 2 小时 | 2 帧 | 1 小时 |
| cocotb/test_control_fabric | Icarus | 10 分钟 | N/A | N/A |
| cocotb/test_ezfb_frame | Icarus | 30 分钟 | 1 帧 | 30 分钟 |
| tb_scaler_160 | Questa | 20 分钟 | 1 帧 | 20 分钟 |

### 编译性能

| 工具 | 源文件数 | 编译时间 | 内存使用 |
|-----|---------|---------|---------|
| Icarus Verilog | ~50 | ~30 秒 | ~500 MB |
| Questa Sim | ~50 | ~2 分钟 | ~1 GB |
| Efinity Synthesis | ~60 | ~10 分钟 | ~3 GB |
| Efinity P&R | — | ~30 分钟 | ~8 GB |

### 板级性能

- **构建位流**：~40 分钟（综合 + 布局布线）
- **下载位流**：~20 秒（via EDB）
- **上电到稳定视频**：~2 秒（HyperRAM 校准 + 锁定同步）
- **配置生效延迟**：< 67 ms（< 2 帧 @ 30 fps）

## 测试自动化

### CI/CD 集成（未实现）

**建议流程**：
```yaml
# .github/workflows/fpga_test.yml (示例)

name: FPGA Tests

on: [push, pull_request]

jobs:
  unit_tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Install Icarus Verilog
        run: sudo apt-get install iverilog
      - name: Install Cocotb
        run: pip install cocotb
      - name: Run Cocotb Tests
        run: |
          cd sim/cocotb/test_control_fabric
          make
```

### 回归测试脚本

**全自动回归**（需要 Questa Sim 许可证）：
```bash
#!/bin/bash
# sim/run_regression.sh

TESTS=(
    "modelsim_hot_focus.do"
    "modelsim_bt1120.do"
    "modelsim_axi_arbiter.do"
    "modelsim_dvp.do"
)

FAILED=0

for test in "${TESTS[@]}"; do
    echo "Running $test..."
    if vsim -c -do "do $test; quit -f"; then
        echo "✓ $test PASSED"
    else
        echo "✗ $test FAILED"
        FAILED=$((FAILED + 1))
    fi
done

if [ $FAILED -eq 0 ]; then
    echo "All tests passed!"
    exit 0
else
    echo "$FAILED test(s) failed."
    exit 1
fi
```
