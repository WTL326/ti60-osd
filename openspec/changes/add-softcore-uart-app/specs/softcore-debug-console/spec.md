# Spec Delta

## Purpose

定义软核的调试输出通道：在无硬件串口适配器的条件下，经 BSP 的 semihosting 通路（JTAG）输出调试信息，并保证该通道的存在与配置不影响 uart1 上的协议端点。

## ADDED Requirements

### Requirement: 调试输出经 semihosting 通道

软核 MUST 使用 BSP 的 `bsp_printf` 作为调试输出接口，并保持 `ENABLE_SEMIHOSTING_PRINT` 为 BSP 默认值 `1`，使输出经 semihosting 通路送达 JTAG 调试器。软核 MUST NOT 依赖 uart0 硬件承载调试输出。标准 newlib `printf` MUST NOT 被当作调试通道。

#### Scenario: bsp_printf 经 JTAG 输出

- **WHEN** 应用调用 `bsp_printf` 且 JTAG 调试器已连接并支持 semihosting
- **THEN** 输出出现在调试器控制台上，且这些字节 MUST NOT 出现在 uart0 的硬件发送线上

#### Scenario: 标准 printf 不是调试通道

- **WHEN** 应用调用标准 newlib `printf`
- **THEN** 输出被丢弃（`common/syscalls.c` 的 `_write` 保持 BSP 现状），MUST NOT 出现在 JTAG 控制台，也 MUST NOT 出现在 uart1 上

#### Scenario: semihosting 保持 BSP 默认

- **WHEN** 检查本工程的构建配置与 `bsp.h`
- **THEN** `ENABLE_SEMIHOSTING_PRINT` 为 `1`，且本工程 MUST NOT 通过命令行定义覆盖它

### Requirement: 调试输出与协议通道隔离

调试输出 MUST 只经调试通道送出。软核 MUST NOT 向 uart1 写入任何调试字节。

#### Scenario: 协议解析日志不进入协议通道

- **WHEN** 软核在解析 uart1 上的命令时产生诊断信息
- **THEN** 该诊断信息只出现在调试通道上，uart1 上除 ACK 应答外无任何字节

#### Scenario: 上位机只看到协议帧

- **WHEN** 上位机监听 uart1
- **THEN** 其收到的字节流中每一个 `0xBB` 都属于一个格式完整的协议帧，不存在被调试文本打断的情况

### Requirement: 调试停滞的边界与协议恢复

semihosting 每写一个字符都会使 CPU 停滞等待主机，期间 uart1 的 RX 中断不被服务。软核 MUST 把调试输出限制在可界定范围内，并在字节流出现缺口后继续服务协议。

#### Scenario: 中断服务例程不打印

- **WHEN** uart1 收到字节并触发中断
- **THEN** 中断服务例程只把字节搬入接收缓冲，MUST NOT 调用任何打印接口

#### Scenario: 输出分段且先服务接收

- **WHEN** 存在待送出的调试输出
- **THEN** 主循环每次只送出一个短段，且每段之间 MUST 先排空并解析 uart1 的接收缓冲

#### Scenario: 正常协议路径静默

- **WHEN** 收到一个合法且被正确处理的帧
- **THEN** 除 ACK 应答外不产生任何调试输出；调试输出只在该帧出现异常（CRC 错、未定义命令、长度不符）时产生

#### Scenario: 重复出现的同类失败不产生无上限输出

- **WHEN** 连续收到大量帧，且它们以**同一种**原因失败（例如某个子项尚未实现，整批上传的每一帧都会走同一条路径）
- **THEN** 软核对该类原因的调试输出 MUST 有上限（例如只报首次出现），MUST NOT 随帧数线性增长

> 这一条是上板实测逼出来的，不是理论推演：本应用在"只做协议框架"阶段每个帧都
> 失败，于是每帧打一行日志；这些日志的 semihosting 停顿会让 CPU 停住、期间 uart1
> 的接收中断不被服务，**实测 26 个分块包只回了 10 个应答**。压成"每类一行"之后
> 回到 22 个，剩下的缺口来自"停顿发生在数据仍在到达时"。
> 输出量必须与"出现了几类问题"成正比，而不是与"收到了几帧"成正比。
> 规模信息由统计汇总行承担。

### Requirement: 输出时机不得与数据接收重叠

软核 MUST 只在 uart1 线路持续静默之后才把调试输出送往调试通道。判定静默的门槛 MUST 大于上位机在包与包之间的最大间隔。

#### Scenario: 数据到达期间的输出被推迟

- **WHEN** uart1 上正在连续接收数据（例如一次多包上传），且期间产生了调试输出
- **THEN** 该输出 MUST 留在内存队列中，MUST NOT 在此期间送往调试通道；待线路静默超过门槛后一次性发出

#### Scenario: 静默门槛高于包间间隔

- **WHEN** 上位机在包与包之间保持约 50 ms 的静默
- **THEN** 静默门槛 MUST 大于该间隔，使整批传输期间不产生任何调试通道写入

> 为什么必须做到"零重叠"而不是"少重叠"：调试通道（semihosting）的写入会让 CPU
> 停住，**期间 uart1 的接收中断不被响应**，硬件接收 FIFO（128 字节）会自己溢出并
> 静默丢字节。这种丢失不经过软件，接收缓冲的丢弃计数看不到它，只能通过"输出与
> 接收在时间上完全不重叠"来根除。

#### Scenario: 字节流缺口后重同步

- **WHEN** 因调试停滞导致 uart1 的字节流出现缺口，某个帧被破坏
- **THEN** 软核 MUST 在后续字节上重新同步，并正确应答其后到达的完整帧，MUST NOT 需要重启或人工干预

### Requirement: 无调试器连接时的行为

软核 MUST 在无调试器连接时继续正常运行，MUST NOT 因 semihosting 调用而挂死。

#### Scenario: 无调试器时降级为空操作

- **WHEN** 软核在无 JTAG 调试器连接的情况下运行并调用 `bsp_printf`
- **THEN** semihosting 调用产生的异常被应用的 `trap()` 容忍并返回，程序继续执行，uart1 的协议端点仍正常应答
