# Debug UART Direct Connection

## 概述

为了方便 RISC-V SoC 调试，添加了一组独立的 UART 引脚，可通过宏定义直连到 SoC，绕过所有路由逻辑。

## 硬件接口

新增两个顶层端口：

- **`DEBUG_UART_RX`** (input) — 调试 UART 接收，直连 SoC `uart_rx`
- **`DEBUG_UART_TX`** (output) — 调试 UART 发送，直连 SoC `uart_tx`

## 启用调试模式

### 方法 1：在 Efinity GUI 中定义

1. 打开 `ivlab239.xml` 项目
2. 进入 **Tools → Options → Verilog Options**
3. 在 **Verilog Macro Definitions** 中添加：
   ```
   DEBUG_UART_DIRECT_CONNECT
   ```
4. 重新编译

### 方法 2：在构建脚本中定义

编辑 `run.sh`，在 `efx_run_pt` 命令前添加：

```bash
export DEBUG_UART_DIRECT_CONNECT=1
# 或在 XML 中通过脚本注入
```

### 方法 3：在源码顶部临时定义

在 `src/top.v` 开头添加（仅用于快速测试）：

```verilog
`define DEBUG_UART_DIRECT_CONNECT
```

## 工作模式

### 宏未定义（正常模式）

```
X2000 → UART_FPGA_TX → riscv_uart_rx (via UART_ST_FR routing)
        riscv_uart_tx → UART_SR_FT → X2000

DEBUG_UART_TX = 1'b1 (空闲态)
DEBUG_UART_RX = 悬空（未使用）
```

现有的 X2000、UartMachineForwarder、掩膜上传等逻辑**完全不受影响**。

### 宏已定义（调试模式）

```
DEBUG_UART_RX → riscv_uart_rx (直连)
riscv_uart_tx → DEBUG_UART_TX (直连)

X2000 路径保持不变：
  UART_ST_FR → UartMachineForwarder → UART_FPGA_RX
  UART_FPGA_TX → (不连接 SoC)
  UART_SR_FT = UART_FPGA_TX & mask_reply_tx (维持原有逻辑)
```

**关键特性**：
- SoC UART **完全旁路** X2000 路由逻辑
- 无需修改 RISC-V 固件代码
- X2000 通信路径（机器命令、掩膜上传）继续工作
- 可同时使用调试 UART 和 X2000 命令通道

## 典型应用场景

### 1. SoC 固件调试

使用 UART-USB 转换器（如 FT232）连接 `DEBUG_UART_TX/RX`：

```bash
# 串口终端（115200 8N1）
picocom /dev/ttyUSB0 -b 115200

# 或 Windows
putty COM3 -serial -sercfg 115200,8,n,1,N
```

直接看到 SoC 的 `printf()` 输出，无需通过 X2000 ADB。

### 2. GDB 远程调试

通过 OpenOCD + UART GDB 桥连接：

```bash
openocd -f ti60_riscv_uart.cfg
riscv32-unknown-elf-gdb firmware.elf -ex "target remote :3333"
```

### 3. 固件下载和启动监控

观察 bootloader 和 Flash 加载过程的原始输出。

## 引脚约束

**需要在约束文件中分配引脚**（用户自行决定）：

```tcl
# 示例：使用空闲的 GPIO 引脚
set_pin_assignment DEBUG_UART_RX  -io_std LVCMOS33 -loc GPIOL_XX_P
set_pin_assignment DEBUG_UART_TX  -io_std LVCMOS33 -loc GPIOL_XX_N
```

> **注意**：文档要求"不用修改约束文件"意味着引脚分配由用户根据板级设计自行决定，框架代码不预先指定。

## 安全注意事项

1. **调试模式不应用于生产构建** — 宏定义仅用于开发阶段
2. **引脚冲突** — 确保选择的引脚未被其他功能占用
3. **ESD 保护** — 调试引脚如果引出板外，建议添加 ESD 保护

## 验证清单

启用调试模式后验证：

- ✓ SoC 固件可以通过 `DEBUG_UART_TX` 输出 printf
- ✓ 通过 `DEBUG_UART_RX` 可以发送命令到 SoC
- ✓ X2000 通过 `UART_ST_FR` 的机器命令依然工作
- ✓ 掩膜上传（0xBB 帧）依然工作
- ✓ 电子变倍、热点追踪控制依然工作

## 代码实现位置

- **顶层端口**：[src/top.v:85-92](../src/top.v)
- **SoC RX 路由**：[src/top.v:521-531](../src/top.v)
- **SoC TX 路由**：[src/top.v:1380-1394](../src/top.v)

## 相关文档

- [架构与数据流](architecture.md) — 完整 UART 路由架构
- [UART 故障排查](../UART_TROUBLESHOOTING.md) — UART 通信问题诊断
