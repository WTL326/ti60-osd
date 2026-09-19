# RISC-V 软核设计文档

## 1. 系统概述

### 1.1 定位与职责

RISC-V 软核（VexRiscv RV32IM）作为 **控制处理器**，是外部控制接口（X2000 via UART）与 FPGA RTL 视频管线之间的桥梁。

**核心职责**：
- 解析外部 UART 命令并转换为 AXI 寄存器操作
- 处理大数据量上传（掩膜图像）到 HyperRAM
- 管理配置跨时钟域同步（50 MHz ↔ 100 MHz）
- 监控系统状态并反馈诊断信息
- 实现固件 OTA 升级与 Bootloader 机制

### 1.2 硬件参数

| 参数 | 值 | 说明 |
|------|----|----|
| CPU 核心 | VexRiscv | RV32IM 指令集 |
| 时钟频率 | 50 MHz | `clk50M` 域，独立于视频管线 |
| 内存空间 | 8 MiB | HyperRAM `0x0000_0000-0x007F_FFFF` |
| 固件容量 | 4 MiB | `0x0000_0000-0x003F_FFFF` |
| 工作区 | 4 MiB | `0x0040_0000-0x007F_FFFF` |
| 固件文件 | `ivlabIspSoftCore.hex` | Intel HEX 格式 |
| AXI 接口 | 32-bit 主机 | 访问控制寄存器 |
| UART 接口 | 115200 8N1 | 与 X2000 通信 |

### 1.3 系统拓扑

```
外部控制（Python 工具 + ADB）
    ↓ USB ADB 连接
X2000 SoC（Android 主控）
    ↓ UART @ 115200 baud
UartMachineForwarder（RTL 路由模块）
    ↓ UART RX/TX 信号
┌────────────────────────────────────────────┐
│  RISC-V 软核（clk50M 域）                   │
│  ┌──────────────────────────────────────┐  │
│  │  Bootloader                          │  │
│  │  - Flash 固件加载                     │  │
│  │  - 完整性校验                         │  │
│  │  - 启动主固件                         │  │
│  └──────────────────────────────────────┘  │
│  ┌──────────────────────────────────────┐  │
│  │  主固件（ivlabIspSoftCore）           │  │
│  │  ├─ UART 协议栈                       │  │
│  │  ├─ 命令解析器                        │  │
│  │  ├─ AXI 主机驱动                      │  │
│  │  ├─ 掩膜上传引擎                      │  │
│  │  ├─ 状态监控服务                      │  │
│  │  └─ 固件升级处理                      │  │
│  └──────────────────────────────────────┘  │
│           ↓ AXI 主接口（32-bit）            │
└────────────────────────────────────────────┘
    ↓
Ti60AxiControlFabric（AXI 控制总线）
    ↓
ConfigSnapshotCdc（50 MHz → 100 MHz）
    ↓
RTL 功能模块
    ├─ ElectronicZoomControlRegs (0xE1013000)
    ├─ HotFocusControlRegs       (0xE1040000)
    ├─ MaskControlRegs           (0xE1043000)
    └─ Ti60SystemControlRegs     (0xE1000000)
```

---

## 2. 功能需求

### 2.1 UART 命令处理

#### 2.1.1 命令集
| 命令名称 | 功能 | 优先级 |
|---------|------|--------|
| `CMD_ZOOM` | 电子变倍 ROI 设置 | 🔴 必需 |
| `CMD_HOT_FOCUS` | 热点追踪启用/禁用 | 🔴 必需 |
| `CMD_MASK_UPLOAD` | 掩膜 UART 上传 | 🔴 必需 |
| `CMD_MASK_SELECT` | 切换掩膜 A/B | 🔴 必需 |
| `CMD_STATUS_QUERY` | 系统状态查询 | 🟡 重要 |
| `CMD_FIRMWARE_UPGRADE` | 固件 OTA 升级 | 🟡 重要 |
| `CMD_FACTORY_RESET` | 恢复出厂设置 | 🟢 可选 |

#### 2.1.2 协议特性
- **帧格式**：`[Header][Length][Command][Payload][CRC16]`
- **超时处理**：接收超时 5 秒，发送超时 2 秒
- **错误重传**：支持 NAK 应答触发重传（最多 3 次）
- **流控**：大数据包使用分片传输 + ACK 确认

### 2.2 AXI 寄存器操作

#### 2.2.1 控制寄存器映射
```c
// AXI 地址空间
#define AXI_BASE_SYSTEM         0xE1000000  // 系统/能力寄存器
#define AXI_BASE_ZOOM           0xE1013000  // 电子变倍控制
#define AXI_BASE_HOT_FOCUS      0xE1040000  // 热点追踪控制
#define AXI_BASE_MASK           0xE1043000  // 掩膜控制

// 系统寄存器偏移
#define REG_CAPABILITY          0x00        // 能力位（只读）
#define REG_FRAME_COUNT         0x04        // 帧计数器（只读）
#define REG_STATUS              0x08        // 系统状态（只读）

// 电子变倍寄存器偏移
#define REG_ZOOM_ENABLE         0x00        // 启用标志
#define REG_ZOOM_ROI_X          0x04        // ROI 左上角 X
#define REG_ZOOM_ROI_Y          0x08        // ROI 左上角 Y
#define REG_ZOOM_ROI_WIDTH      0x0C        // ROI 宽度
#define REG_ZOOM_ROI_HEIGHT     0x10        // ROI 高度
#define REG_ZOOM_COMMIT         0x14        // 配置提交 toggle

// 热点追踪寄存器偏移
#define REG_HOT_FOCUS_ENABLE    0x00        // 启用标志
#define REG_HOT_FOCUS_POLARITY  0x04        // 极性（0=热点/1=冷点）
#define REG_HOT_FOCUS_RESULT_X  0x08        // 检测到的 X 坐标（只读）
#define REG_HOT_FOCUS_RESULT_Y  0x0C        // 检测到的 Y 坐标（只读）
#define REG_HOT_FOCUS_RESULT_VAL 0x10       // 峰值（只读）

// 掩膜寄存器偏移
#define REG_MASK_ENABLE         0x00        // 启用标志
#define REG_MASK_SELECT         0x04        // 选择 A(0)/B(1)
#define REG_MASK_UPLOAD_STATUS  0x08        // 上传状态（只读）
```

#### 2.2.2 AXI 事务要求
- **单拍写**：配置寄存器使用单拍 AXI 写事务
- **突发写**：掩膜数据使用 AXI INCR 突发（长度 8-16）
- **超时**：AXI 事务超时 100 µs（5000 时钟周期 @ 50 MHz）
- **错误处理**：SLVERR/DECERR 记录日志并返回 UART 错误码

### 2.3 掩膜上传引擎

#### 2.3.1 上传流程
```
Python 工具发起上传命令
    ↓
软核准备接收（清空缓冲区，设置状态）
    ↓
Python 分片传输掩膜数据（每片 1-4 KB）
    ↓
软核接收 → 缓存到工作区 → 发送 ACK
    ↓ （循环直到所有分片完成）
    ↓
软核校验完整性（CRC32）
    ↓
通过 AXI 突发写入 HyperRAM 掩膜区
    ↓ （0x00A00000 = 掩膜 A / 0x00B00000 = 掩膜 B）
    ↓
更新 MaskControlRegs（启用新掩膜）
    ↓
返回成功响应
```

#### 2.3.2 性能指标
- **UART 带宽**：115200 baud ≈ 14 KB/s（理论）
- **实际吞吐**：~10 KB/s（考虑协议开销）
- **典型掩膜大小**：640×512×1-bit ≈ 40 KB
- **上传时间**：~4 秒（单个掩膜）

#### 2.3.3 HyperRAM 掩膜布局与格式

**内存格式**：
- **每像素 1 字节**（8-bit 灰度）
- **线性存储**：`地址 = BASE + (y × width + x)`
- **值语义**：`0x00` = 透明（显示原视频），`!= 0x00` = 白色覆盖（Y=235, CbCr=128）

**Legacy 模式**（全屏掩膜，默认）：
```
分辨率: 720×576（固定，与 PAL 输出匹配）
大小: 414,720 字节 (≈ 405 KB)

0x00A00000-0x00A656FF  掩膜 A（414,720 字节）
    ├─ 0x00A00000: Row 0 (720 字节)
    ├─ 0x00A002D0: Row 1 (720 字节)
    ├─ ...
    └─ 0x00A65430: Row 575 (720 字节)

0x00B00000-0x00B656FF  掩膜 B（414,720 字节）
    └─ （同上结构）
```

**Raw 模式**（可定位小掩膜，可选）：
```
分辨率: 420×220（固定）
大小: 92,400 字节 (≈ 90 KB)
位置: 通过 mask_left/mask_top 控制（支持负值裁剪）

基地址同 Legacy，但通过寄存器 raw_mode=1 切换
```

**掩膜处理示例**（Python）：
```python
import numpy as np
from PIL import Image

# 加载图像并二值化
img = Image.open("mask.bmp").convert('L')
mask = (np.array(img) > 128).astype(np.uint8) * 0xFF

# 粘贴到 720×576 画布
canvas = np.zeros((576, 720), dtype=np.uint8)
canvas[y:y+h, x:x+w] = mask[0:h, 0:w]

# 展平为字节流（414,720 字节）
mask_data = canvas.flatten().tobytes()
```

### 2.4 配置同步机制

#### 2.4.1 Toggle 同步协议
RTL 使用 `ConfigSnapshotCdc` 模块跨时钟域：

```verilog
// 软核写入（clk50M 域）
reg config_toggle;
always @(posedge clk50M) begin
    if (commit_command) begin
        config_toggle <= ~config_toggle;  // 翻转 toggle 位
    end
end

// RTL 检测（clk 域）
// ConfigSnapshotCdc 检测 toggle 变化 → 在下一个 SOF 应用配置
```

**关键约束**：
- 配置变更必须在帧边界（SOF）生效
- Toggle 翻转后，软核必须等待 RTL 确认（通过读取影子寄存器）
- 最大同步延迟：2 帧周期（~66 ms @ 30 fps）

#### 2.4.2 多模块配置协调
同时修改变倍 + 热点时：
1. 写入所有配置寄存器
2. **最后**写入任一模块的 `commit` 寄存器
3. ConfigSnapshotCdc 捕获所有配置的快照
4. 在同一个 SOF 边界统一生效

### 2.5 状态监控服务

#### 2.5.1 监控指标
| 指标 | 来源 | 更新频率 |
|------|------|---------|
| 帧计数器 | Ti60SystemControlRegs | 实时 |
| 丢帧计数 | ScalerDroppedFrames | 实时 |
| 热点坐标 | HotFocusControlRegs | 每帧 |
| AXI 带宽 | Axi4MonitorShared | 1 Hz |
| FIFO 溢出 | 各 FIFO 模块 | 事件触发 |
| VIO 调试状态 | RiscvVioMonitor | 按需 |

#### 2.5.2 日志与诊断
- **UART 日志输出**：ERROR/WARN/INFO 三级
- **环形缓冲区**：保留最近 256 条事件记录
- **崩溃转储**：保存最后 10 条 AXI 事务到工作区

### 2.6 固件升级机制

#### 2.6.1 Bootloader 设计
```
上电复位
    ↓
Bootloader 启动（ROM/Flash 固定区）
    ↓
检查升级标志（Flash 魔数）
    ↓ YES
从 Flash Bank B 加载新固件 → 校验 CRC
    ↓ 失败
回退到 Bank A（旧固件）
    ↓ 成功
清除升级标志，设置"新固件运行中"标志
    ↓
启动主固件
    ↓
主固件启动后定期"喂看门狗"（清除"新固件运行中"标志）
    ↓ 超时未喂狗（10 秒）
Bootloader 认为新固件启动失败 → 回退到 Bank A
    ↓ 正常喂狗
标记新固件为有效，复制 Bank B → Bank A
```

#### 2.6.2 升级流程
```c
// 伪代码
void handle_firmware_upgrade() {
    // 1. 接收新固件
    uint8_t *buf = malloc(4MB);
    uart_receive_firmware(buf, &size);
    
    // 2. 校验完整性
    if (crc32(buf, size) != expected_crc) {
        return ERROR_CRC_MISMATCH;
    }
    
    // 3. 写入 Flash Bank B
    flash_erase(FLASH_BANK_B);
    flash_write(FLASH_BANK_B, buf, size);
    
    // 4. 验证写入
    if (!flash_verify(FLASH_BANK_B, buf, size)) {
        return ERROR_FLASH_WRITE;
    }
    
    // 5. 设置升级标志
    flash_write_magic(UPGRADE_FLAG);
    
    // 6. 软复位
    uart_send_response(SUCCESS);
    delay_ms(100);
    soft_reset();
}
```

#### 2.6.3 Flash 分区（推测布局）
```
Flash（假设 16 MB SPI Flash）
├─ 0x000000-0x3FFFFF: FPGA 位流 Bank A（4 MB）
├─ 0x400000-0x7FFFFF: FPGA 位流 Bank B（4 MB，备份）
├─ 0x800000-0xBFFFFF: RISC-V 固件 Bank A（4 MB）
├─ 0xC00000-0xDFFFFF: RISC-V 固件 Bank B（2 MB，备份）
├─ 0xE00000-0xE0FFFF: 掩膜持久化 A（64 KB）
├─ 0xE10000-0xE1FFFF: 掩膜持久化 B（64 KB）
├─ 0xE20000-0xE2FFFF: 配置数据（64 KB）
│   ├─ 默认变倍 ROI
│   ├─ 默认热点配置
│   └─ 工厂校准参数
└─ 0xE30000-0xFFFFFF: 日志/统计（1.8 MB）
```

---

## 3. 架构设计

### 3.1 软件分层

```
┌───────────────────────────────────────────┐
│  应用层（Application Layer）               │
│  ├─ 命令处理器（Command Handlers）         │
│  ├─ 状态机（State Machines）              │
│  └─ 业务逻辑（Business Logic）            │
├───────────────────────────────────────────┤
│  服务层（Service Layer）                   │
│  ├─ 配置管理器（Config Manager）          │
│  ├─ 掩膜引擎（Mask Engine）               │
│  ├─ 升级管理器（Upgrade Manager）         │
│  └─ 监控服务（Monitor Service）           │
├───────────────────────────────────────────┤
│  驱动层（Driver Layer）                    │
│  ├─ UART 驱动（UART Driver）              │
│  ├─ AXI 主机驱动（AXI Master Driver）     │
│  ├─ Flash 驱动（Flash Driver）            │
│  └─ 定时器/中断控制（Timer/IRQ）          │
├───────────────────────────────────────────┤
│  硬件抽象层（HAL）                         │
│  ├─ 寄存器定义（Register Defs）           │
│  ├─ 内存映射（Memory Map）                │
│  └─ 中断向量表（IRQ Vector Table）        │
└───────────────────────────────────────────┘
```

### 3.2 主循环结构

```c
int main(void) {
    // 初始化阶段
    hal_init();
    uart_init(115200);
    axi_master_init();
    flash_init();
    
    // 加载持久化配置
    load_config_from_flash();
    
    // 应用默认配置到 RTL
    apply_default_config();
    
    // 主事件循环
    while (1) {
        // 1. 处理 UART 接收
        if (uart_has_data()) {
            handle_uart_command();
        }
        
        // 2. 定时任务（1 Hz）
        if (timer_tick_1hz()) {
            read_system_status();
            update_watchdog();
        }
        
        // 3. 处理 AXI 回读（异步完成）
        if (axi_transaction_complete()) {
            process_axi_response();
        }
        
        // 4. 空闲时低功耗
        wfi();  // Wait For Interrupt
    }
}
```

### 3.3 关键数据结构

```c
// 配置快照
typedef struct {
    // 电子变倍
    uint8_t  zoom_enable;
    uint16_t zoom_roi_x;
    uint16_t zoom_roi_y;
    uint16_t zoom_roi_width;
    uint16_t zoom_roi_height;
    
    // 热点追踪
    uint8_t  hot_focus_enable;
    uint8_t  hot_focus_polarity;  // 0=热点, 1=冷点
    
    // 掩膜
    uint8_t  mask_enable;
    uint8_t  mask_select;  // 0=A, 1=B
    
    // CRC 校验
    uint32_t crc;
} SystemConfig_t;

// 系统状态
typedef struct {
    uint32_t frame_count;
    uint32_t dropped_frames;
    uint16_t hot_focus_x;
    uint16_t hot_focus_y;
    uint8_t  hot_focus_value;
    uint32_t axi_bandwidth_mbps;
    uint8_t  error_flags;
} SystemStatus_t;

// 掩膜上传上下文
typedef struct {
    enum {
        IDLE,
        RECEIVING,
        VERIFYING,
        WRITING_FLASH,
        COMPLETE,
        ERROR
    } state;
    
    uint8_t  target_bank;      // 0=A, 1=B
    uint32_t total_size;
    uint32_t received_bytes;
    uint32_t expected_crc;
    uint8_t *buffer;           // 工作区缓冲
} MaskUploadContext_t;
```

---

## 4. UART 协议规范

### 4.1 帧格式

```
┌──────┬────────┬─────────┬─────────────┬────────┐
│ 魔数 │ 长度   │ 命令码  │  有效载荷   │ CRC16  │
│ 2B   │ 2B     │ 1B      │  0-4096B    │ 2B     │
└──────┴────────┴─────────┴─────────────┴────────┘

魔数（Magic）：0x5AA5（固定，用于帧同步）
长度（Length）：有效载荷长度（不含头部和 CRC）
命令码（Command）：见命令表
有效载荷（Payload）：命令相关数据
CRC16：CRC-16/MODBUS（整个帧，不含 CRC 本身）
```

### 4.2 命令码定义

```c
// 系统命令
#define CMD_PING                0x01  // 心跳检测
#define CMD_GET_VERSION         0x02  // 获取固件版本
#define CMD_GET_STATUS          0x03  // 获取系统状态
#define CMD_SOFT_RESET          0x0F  // 软复位

// 电子变倍
#define CMD_ZOOM_SET_ROI        0x10  // 设置 ROI
#define CMD_ZOOM_ENABLE         0x11  // 启用变倍
#define CMD_ZOOM_DISABLE        0x12  // 禁用变倍

// 热点追踪
#define CMD_HOT_FOCUS_ENABLE    0x20  // 启用热点
#define CMD_HOT_FOCUS_DISABLE   0x21  // 禁用热点
#define CMD_HOT_FOCUS_SET_POLAR 0x22  // 设置极性
#define CMD_HOT_FOCUS_GET_RESULT 0x23 // 读取结果

// 掩膜控制
#define CMD_MASK_UPLOAD_START   0x30  // 开始上传
#define CMD_MASK_UPLOAD_DATA    0x31  // 上传数据片段
#define CMD_MASK_UPLOAD_FINISH  0x32  // 完成上传
#define CMD_MASK_SELECT         0x33  // 选择掩膜 A/B
#define CMD_MASK_ENABLE         0x34  // 启用掩膜
#define CMD_MASK_DISABLE        0x35  // 禁用掩膜

// 固件升级
#define CMD_UPGRADE_START       0xF0  // 开始升级
#define CMD_UPGRADE_DATA        0xF1  // 升级数据片段
#define CMD_UPGRADE_FINISH      0xF2  // 完成升级
#define CMD_UPGRADE_ABORT       0xF3  // 中止升级
```

### 4.3 响应格式

```
┌──────┬────────┬─────────┬─────────────┬────────┐
│ 魔数 │ 长度   │ 状态码  │  响应数据   │ CRC16  │
│ 2B   │ 2B     │ 1B      │  0-4096B    │ 2B     │
└──────┴────────┴─────────┴─────────────┴────────┘

状态码：
    0x00 = SUCCESS
    0x01 = ERROR_INVALID_COMMAND
    0x02 = ERROR_INVALID_PARAM
    0x03 = ERROR_CRC_MISMATCH
    0x04 = ERROR_TIMEOUT
    0x05 = ERROR_AXI_FAULT
    0x06 = ERROR_FLASH_WRITE
    0x07 = ERROR_BUSY
```

### 4.4 命令示例

#### 设置电子变倍 ROI
```
请求：
    [5A A5] [08 00] [10] [00 64 00 32 01 40 02 00] [CRC]
    魔数     长度=8   CMD  X=100 Y=50  W=320 H=512
    
响应：
    [5A A5] [00 00] [00] [CRC]
    魔数     长度=0   成功
```

#### 掩膜上传（分片）
```
开始：
    [5A A5] [08 00] [30] [00 00 A0 00 00 00 00 01] [CRC]
    魔数     长度=8   START Bank_A  Size=64KB
    
数据片段（循环）：
    [5A A5] [00 10] [31] [片段0数据4KB...] [CRC]
    魔数     长度=4096 DATA
    
    响应 ACK：
    [5A A5] [04 00] [00] [已接收字节数] [CRC]
    
完成：
    [5A A5] [04 00] [32] [CRC32期望值] [CRC]
    
    响应：
    [5A A5] [00 00] [00] [CRC]  // 成功
```

---

## 5. 开发指南

### 5.1 工具链

| 工具 | 版本 | 用途 |
|------|------|------|
| GCC | riscv32-unknown-elf-gcc 12.2.0 | 编译器 |
| Newlib | 4.3.0 | C 标准库 |
| OpenOCD | 0.12.0 | 调试器 |
| srec_cat | 1.64 | HEX 文件生成 |

### 5.2 构建流程

```bash
# 编译固件
cd embedded_sw
make clean
make all

# 输出文件
# ivlabIspSoftCore.elf  - ELF 可执行文件（调试符号）
# ivlabIspSoftCore.bin  - 原始二进制
# ivlabIspSoftCore.hex  - Intel HEX 格式（用于 FPGA 综合）
# ivlabIspSoftCore.map  - 链接映射
```

### 5.3 内存布局

```
链接脚本（link.ld）：

MEMORY {
    FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 4M   /* 固件代码 */
    RAM   (rwx) : ORIGIN = 0x00400000, LENGTH = 4M   /* 工作区 */
}

SECTIONS {
    .text : {
        *(.text.boot)      /* Bootloader 入口 */
        *(.text*)          /* 代码段 */
    } > FLASH
    
    .rodata : {
        *(.rodata*)        /* 只读数据 */
    } > FLASH
    
    .data : {
        *(.data*)          /* 初始化数据 */
    } > RAM AT > FLASH
    
    .bss : {
        *(.bss*)           /* 未初始化数据 */
    } > RAM
    
    .heap : {
        . = ALIGN(4);
        _heap_start = .;
        . = . + 2M;        /* 2 MB 堆空间 */
        _heap_end = .;
    } > RAM
    
    .stack : {
        . = ALIGN(8);
        . = . + 256K;      /* 256 KB 栈空间 */
        _stack_top = .;
    } > RAM
}
```

### 5.4 调试方法

#### UART 日志
```c
// 使用独立的调试 UART（如果硬件支持）
#define DEBUG_UART_BAUD 115200

void debug_log(const char *fmt, ...) {
    char buf[256];
    va_list args;
    va_start(args, fmt);
    vsnprintf(buf, sizeof(buf), fmt, args);
    va_end(args);
    uart_debug_send(buf, strlen(buf));
}

// 使用示例
debug_log("[INFO] AXI write: addr=0x%08X, data=0x%08X\n", addr, data);
```

#### VIO 探针
```c
// 通过 RiscvVioMonitor 暴露给 Efinity EDB
volatile uint32_t *vio_debug = (uint32_t *)0xE1FF_F000;

vio_debug[0] = current_state;        // 状态机状态
vio_debug[1] = uart_rx_count;        // UART 接收计数
vio_debug[2] = axi_error_code;       // AXI 错误码
vio_debug[3] = last_command;         // 最后一条命令
```

#### 断点调试（OpenOCD）
```bash
# 启动 OpenOCD
openocd -f interface/jlink.cfg -f target/ti60f225.cfg

# GDB 连接
riscv32-unknown-elf-gdb ivlabIspSoftCore.elf
(gdb) target remote :3333
(gdb) load
(gdb) break main
(gdb) continue
```

### 5.5 测试策略

#### 单元测试（主机端）
```bash
# 使用 Spike RISC-V 模拟器
make test
spike --isa=RV32IM ivlabIspSoftCore.elf
```

#### 集成测试（板级）
```python
# tools/test_softcore.py
import serial
import struct

def test_zoom_command():
    ser = serial.Serial('/dev/ttyUSB0', 115200, timeout=2)
    
    # 构造命令
    cmd = struct.pack('<HHBHHHH', 
        0x5AA5,         # 魔数
        8,              # 长度
        0x10,           # CMD_ZOOM_SET_ROI
        100, 50,        # X, Y
        320, 512        # W, H
    )
    cmd += calc_crc16(cmd)
    
    # 发送并验证响应
    ser.write(cmd)
    resp = ser.read(7)
    assert resp[4] == 0x00  # 状态码 = SUCCESS
    
if __name__ == '__main__':
    test_zoom_command()
    print("✓ 电子变倍命令测试通过")
```

---

## 6. 性能与资源

### 6.1 CPU 占用率（估算）

| 任务 | CPU 占用 | 频率 |
|------|---------|------|
| UART 接收中断 | ~5% | 按需 |
| 命令解析 | ~10% | 按需 |
| AXI 事务 | ~15% | 按需 |
| 掩膜上传 | ~60% | 短暂峰值 |
| 状态监控 | ~5% | 1 Hz |
| 空闲 | ~5% | - |

### 6.2 内存使用（估算）

| 区域 | 大小 | 说明 |
|------|------|------|
| 代码段 | ~200 KB | 包含 Bootloader |
| 只读数据 | ~50 KB | 字符串、查找表 |
| 数据段 | ~20 KB | 全局变量 |
| BSS | ~100 KB | 未初始化数据 |
| 堆 | 2 MB | 动态分配（掩膜缓冲） |
| 栈 | 256 KB | 函数调用栈 |
| **总计** | **~2.6 MB** | 剩余 ~5.4 MB 可扩展 |

### 6.3 延迟指标

| 操作 | 延迟 | 说明 |
|------|------|------|
| UART 命令响应 | <10 ms | 简单寄存器操作 |
| 配置生效 | <66 ms | 等待下一个 SOF |
| 掩膜上传 | ~4 s | 40 KB @ 10 KB/s |
| 固件升级 | ~5 min | 4 MB @ 14 KB/s |
| 状态查询 | <5 ms | AXI 读事务 |

---

## 7. 错误处理

### 7.1 错误分类

| 类别 | 错误码 | 处理策略 |
|------|--------|---------|
| 协议错误 | 0x01-0x03 | 返回 NAK，等待重传 |
| 超时 | 0x04 | 清空缓冲，返回错误 |
| 硬件故障 | 0x05-0x06 | 记录日志，返回错误，可能复位 |
| 忙状态 | 0x07 | 返回 BUSY，客户端重试 |

### 7.2 恢复机制

```c
// 看门狗复位
void watchdog_reset() {
    // 硬件看门狗 30 秒超时
    // 主循环每 1 秒喂狗
    *(volatile uint32_t *)WDT_FEED_ADDR = 0x5A5A;
}

// AXI 超时恢复
bool axi_write_with_timeout(uint32_t addr, uint32_t data) {
    uint32_t timeout = 5000;  // 100 µs @ 50 MHz
    
    axi_start_write(addr, data);
    while (!axi_done() && timeout--) {
        __asm__ volatile ("nop");
    }
    
    if (timeout == 0) {
        axi_abort();
        error_log("AXI timeout: addr=0x%08X", addr);
        return false;
    }
    return true;
}
```

---

## 8. 未来扩展

### 8.1 网络接口（可选）
- 添加以太网 MAC 支持（如果硬件提供）
- 实现 TCP/IP 栈（lwIP）
- 支持远程调试和固件升级

### 8.2 安全增强
- 固件签名验证（RSA/ECDSA）
- 安全启动（Secure Boot）
- 加密通信（AES-128）

### 8.3 功能扩展
- 视频参数调优（亮度/对比度）
- 多区域热点追踪（最多 4 个）
- 录像触发控制

---

## 9. 参考文档

| 文档 | 路径 | 说明 |
|------|------|------|
| RTL 架构 | `docs/architecture.md` | 完整视频管线说明 |
| 内存映射 | `docs/memory_axi.md` | HyperRAM 布局 |
| 测试指南 | `docs/testing.md` | 仿真和板级测试 |
| Python 工具 | `tools/send_*_via_adb.py` | 控制命令示例 |
| VexRiscv 手册 | [SpinalHDL GitHub](https://github.com/SpinalHDL/VexRiscv) | CPU 核心文档 |

---

**文档版本**：1.0  
**最后更新**：2025-01-XX  
**作者**：FPGA 团队  
**审核状态**：草稿
