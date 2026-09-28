# Spec Delta

## Purpose

定义软核在 uart1 上对 X2000 提供的命令通道行为：按本工程既有的 `0xBB` 帧协议接收命令、校验完整性、按功能大类判断归属，并对属于自己的每一帧返回格式确定的应答，使上位机能够可靠地判断命令是否被接受。

> 协议格式的依据是 `docs/测试说明.md` 的「指令构成」一节，并与
> `docs/adb_test_commands.md`、`docs/x2000_ui_protocol.md` 以及
> `tools/send_*_via_adb.py` 三个上位机工具一致。本 spec 描述**掩膜大类（`0x00`）与
> UI 大类（`0x04`）**的行为；其余大类在同一根线上并存，但不归本端点管。

## ADDED Requirements

### Requirement: 协议帧格式

软核 MUST 按以下字节序解析 uart1 上的命令帧：

```
BB | body_length[15:8] | body_length[7:0] |
body | crc[15:8] | crc[7:0] | AA
```

其中 `body` MUST 为 `大类 | 子项 | 类型 | payload`：

| 字节 | 字段 | 含义 |
|---|---|---|
| `body[0]` | 大类 | 功能模块：`0x00` 掩膜、`0x01` 电子变倍、`0x02` 热点、`0x03` 伪彩色、`0x04` UI |
| `body[1]` | 子项 | 该大类下的命令号 |
| `body[2]` | 类型 | `0x00` 上位机写、`0x02` 设备应答 |
| `body[3..]` | payload | 子项参数 |

`body_length` MUST 等于 `body` 的字节数（含 3 字节 body 头），即 `3 + payload 字节数`。
帧头 MUST 为 `0xBB`（用于区别于机台的 `0xAA` 帧），帧尾 MUST 为 `0xAA`。
多字节字段 MUST 为大端序。

#### Scenario: 接收合法帧

- **WHEN** uart1 收到 `BB 00 07 00 03 00 00 96 00 B2 83 E0 AA`
- **THEN** 软核将其识别为 `大类 = 0x00`、`子项 = 0x03`、`类型 = 0x00`、`body_length = 7`、payload 为 `00 96 00 B2`

> 这一串取自 `docs/adb_test_commands.md`（掩膜位置 150,178 的原始报文），
> 不是本实现生成的——以系统自己认可的报文作为依据。

#### Scenario: 前导噪声被丢弃

- **WHEN** uart1 依次收到若干非 `0xBB` 字节后跟一个合法帧
- **THEN** 软核丢弃前导噪声字节，并从 `0xBB` 处开始组装帧

#### Scenario: body 内的 0xBB 是数据而非帧头

- **WHEN** 在组装 body 期间收到一个 `0xBB` 字节
- **THEN** 软核 MUST 将其当作普通 body 字节计入 CRC 与字节计数，MUST NOT 据此重新开始组装帧

> 这一条必须如此：掩膜分块（子项 `0x02`）的 payload 是位图原始字节，取值范围
> 是整个 `0x00`–`0xFF`，**包含 `0xBB`**。若在 body 阶段识别帧头，合法帧会被
> 误截断。缺字节造成的失步由"长度前缀 + CRC"检测（见下一条），不靠 body 内的
> 帧头识别。

#### Scenario: 失步后由长度与 CRC 检测并恢复

- **WHEN** 因字节丢失导致 body 与长度前缀失去对齐
- **THEN** 该帧的 CRC 校验失败，软核回到等待帧头的状态，并在下一个 `0xBB` 处重新开始组装；MUST NOT 需要重启或人工干预

### Requirement: 完整性校验

软核 MUST 对 `body` 计算 CRC-16/CCITT（多项式 `0x1021`，初值 `0x0000`，不反射，无最终异或），并与帧内 `crc` 字段比较；同时 MUST 校验帧尾为 `0xAA`。校验不通过时软核 MUST NOT 执行该命令，并且 **MUST NOT 发送应答**。

#### Scenario: CRC 正确

- **WHEN** 帧内 `crc` 字段与软核计算值一致且帧尾为 `0xAA`
- **THEN** 软核进入归属判断

#### Scenario: CRC 错误时不产生任何发送

- **WHEN** 帧内 `crc` 字段与软核计算值不一致
- **THEN** 软核不执行该命令，`bad_packet_count` 递增，并且 **MUST NOT 在 uart1 上发送任何字节**

#### Scenario: 帧尾错误时不产生任何发送

- **WHEN** body 与 CRC 均正确，但 CRC 之后的字节不是 `0xAA`
- **THEN** 软核不执行该命令，`bad_packet_count` 递增，并且 MUST NOT 在 uart1 上发送任何字节

> 为什么坏帧不应答：字节既然不可信，就无法判断这一帧属于哪个功能模块。
> 同一条线上并存着变倍、热点、伪彩色、UI 的通信，对一个身份不明的损坏帧
> 贸然回应，可能正好撞进别的模块正在进行的应答里。

### Requirement: 大类归属

软核 MUST 按 `body[0]` 判断帧的归属：**大类 `0x00`（掩膜）与 `0x04`（UI）的帧由本端点处理**。
其它大类（`0x01` 电子变倍、`0x02` 热点、`0x03` 伪彩色）MUST NOT 被当作格式错误，
也 MUST NOT 得到应答。

#### Scenario: 掩膜帧由本端点处理

- **WHEN** 收到一个大类为 `0x00` 的帧，且完整性校验通过
- **THEN** 软核按掩膜子项分发表处理，并返回应答

#### Scenario: UI 帧由本端点处理

- **WHEN** 收到一个大类为 `0x04`、且子项在本端点范围内的完整帧
- **THEN** 软核按 UI 子项分发表处理，并按该子项的应答长度返回应答（见"UI 大类的应答口径"）

#### Scenario: 其它大类的帧不得到应答

- **WHEN** 收到一个大类为 `0x01`（电子变倍）、`0x02`（热点）或 `0x03`（伪彩色）的帧
- **THEN** 软核 MUST NOT 发送任何字节，MUST NOT 计入 `bad_packet_count`，只递增"其它大类"计数

> 这一条是"按协议实现、不强行校验大类"的落点。这些帧是**合法帧**，只是不归
> 本端点管。若给它们回一个"大类 0x00"的应答，对应的上位机工具会把它读成
> "ACK 格式错误"——等于把别的模块撞坏。
>
> `0x04` 从这一组里移出，是因为它现在归本端点管（见下一节）。这是一次**契约变更**：
> 本 spec 的早期版本规定"只有 `0x00` 应答"。

### Requirement: UI 大类的应答口径

`0x04` 大类的应答 MUST 按子项区分长度：子项 `0x08`（QUERY_VIEW）的应答 MUST 为整帧 **18 字节**
（body 12 字节），该大类其余子项的应答 MUST 为整帧 **10 字节**（body 4 字节）。
应答的成功判据 MUST 为 body 第 4 字节等于 `0xFF`；CRC MUST 覆盖完整 body
（`0x08` 覆盖 12 字节，其余覆盖 4 字节）。

`0x04` 大类内**未纳入本端点范围的子项**（`0x01`–`0x05`）MUST 只解析、
MUST NOT 应答、MUST NOT 计入 `bad_packet_count`。

`0x04` 大类的收包 MUST 计入"被接受"计数，MUST NOT 计入"其它大类"计数。

> 依据：`docs/x2000_ui_protocol.md` §2 与 §3.3，以及上位机工具
> `tools/send_ui_via_adb.py`（`:99` 的 `18 if sub==8 else 10`、`:104-107` 的逐字节校验）。
> 三者的口径一致；`ti60-osd-main` 的 14 字节 QUERY_VIEW 回应是**偏离**该口径的，
> 不作为依据。

#### Scenario: QUERY_VIEW 的 18 字节应答

- **WHEN** 收到无 payload 的 `0x04`/`0x08`
- **THEN** 应答整帧为 18 字节，body 为 `04 08 02 FF | page_id(2) | sel | flags | 4 个数值`，
  且 CRC 与收到的 body 相符

#### Scenario: UI 其它子项的 10 字节应答

- **WHEN** 收到 `0x04`/`0x06`（SET_VIEW）或 `0x04`/`0x07`（SET_IMAGE_VALUES）
- **THEN** 应答整帧为 10 字节，body 为 `04 子项 02 状态`——与掩膜大类的应答格式相同

#### Scenario: 未纳入的 UI 子项不应答

- **WHEN** 收到 `0x04` 大类中 `0x01`–`0x05` 任一子项的完整帧
- **THEN** 软核 MUST NOT 发送任何字节，MUST NOT 计入 `bad_packet_count`
- **AND** 上位机工具 `send_ui_via_adb.py` 的 `--show`/`--hide`/`--key`/`--clear`/`--marker`
  会因此超时，这是预期行为而非缺陷

### Requirement: 类型字段校验

掩膜大类的命令帧，其 `body[2]`（类型）MUST 为 `0x00`（上位机写）。不符时软核 MUST NOT 执行该命令。

#### Scenario: 类型不是"上位机写"

- **WHEN** 收到 CRC 正确、大类为 `0x00`，但 `body[2] != 0x00` 的帧
- **THEN** 软核不执行该命令，`bad_packet_count` 递增，并返回 `status = 0x00` 的应答

#### Scenario: body_length 超出可接受范围

- **WHEN** 收到的 `body_length` 小于 `3` 或大于等于 `5000`
- **THEN** 软核不读取 body，`bad_packet_count` 递增，并回到等待下一个帧头；该帧 MUST NOT 产生应答

### Requirement: 应答格式

对**每一个属于掩膜大类、且完整性校验通过的帧**（无论子项是否被接受），软核 MUST 恰好返回一个 10 字节应答：

```
BB | 00 04 | 大类 | 子项 | 02 | 状态 | crc[15:8] | crc[7:0] | AA
```

`大类` 与 `子项` MUST 从收到的帧原样回显，第 5 字节 MUST 为 `0x02`（表示应答），
`crc` MUST 为对应答体（`大类 | 子项 | 02 | 状态` 这 4 个字节）计算的 CRC-16/CCITT。

#### Scenario: 应答逐字节确定

- **WHEN** 收到掩膜位置帧并返回失败
- **THEN** 应答为 `BB 00 04 00 03 02 00 3F 32 AA`

#### Scenario: 无帧时不发送

- **WHEN** uart1 上没有属于掩膜大类的完整帧到达
- **THEN** 软核 MUST NOT 在 uart1 上发送任何字节（发送线保持空闲）

#### Scenario: 应答不丢失

- **WHEN** 上位机在软核上一个应答尚未发送完毕时连续送入下一个掩膜帧
- **THEN** 软核 MUST 为后一个帧也返回应答（例如通过在应答期间暂停接收解析），MUST NOT 静默丢弃任何掩膜帧的应答

### Requirement: 状态码语义

应答的 `status` 字段 MUST 为二值：`0xFF` 表示命令已被接受并成功执行，`0x00` 表示未成功。软核 MUST NOT 在该字段中编码错误分类。

#### Scenario: 成功

- **WHEN** 命令通过校验且执行成功
- **THEN** `status = 0xFF`

#### Scenario: 失败

- **WHEN** 命令未通过校验、子项未定义、或命令执行失败
- **THEN** `status = 0x00`，且失败的具体原因 MUST 通过调试通道（`softcore-debug-console`）输出，MUST NOT 写入 `status` 字段

> 二值状态是 `docs/测试说明.md` 的明文规定（"`status`：`0xFF` 成功，
> `0x00` 失败"）。上位机工具里另有一张 `0x00`–`0x07` 的错误码表，那只是那个
> 工具对返回值的解读，不是协议规定。

### Requirement: 掩膜子项分发表

软核 MUST 维护掩膜大类的子项分发表。本次变更 MUST 识别以下子项，并对**每一个**都返回 `status = 0x00`（业务实现尚未提供）：

| 子项 | 名称 | payload | `body_length` |
|---|---|---|---|
| `0x01` | 开始上传 | `width:u16 height:u16 total:u32` | `11` |
| `0x02` | 分块写入 | `offset:u32 + bytes[]` | `> 7` |
| `0x03` | 设置位置 | `left_x:s16 top_y:s16` | `7` |
| `0x04` | 开关 | `enable:u8` | `4` |
| `0x05` | 保存 Flash | 无 | `3` |

#### Scenario: 已识别但未实现

- **WHEN** 收到一个掩膜帧，子项为 `0x02`、长度合法
- **THEN** 软核返回 `status = 0x00`，并在调试通道输出该子项号、名称与"未实现"原因

#### Scenario: 未定义子项

- **WHEN** 收到一个掩膜帧，子项为上位机可能使用但本表未收录的值（如 `0x99`）
- **THEN** 软核返回 `status = 0x00`，`bad_packet_count` 递增，并在调试通道输出该子项号

#### Scenario: body_length 与子项不符

- **WHEN** 收到子项为 `0x03` 但 `body_length != 7` 的帧
- **THEN** 软核返回 `status = 0x00`，`bad_packet_count` 递增，且 MUST NOT 读取超出 body 的 payload 字节

### Requirement: 接收诊断计数器

软核 MUST 维护可读的包计数，用于判断链路健康度。至少 MUST 把以下三类**分开**计数：
被接受的本端点帧（`0x00` 的全部，以及 `0x04` 中纳入范围的完整帧）、被拒绝的帧、
以及被静默忽略的其它大类帧。

#### Scenario: 计数分别递增

- **WHEN** 依次收到一个完整性正确的掩膜帧与一个 CRC 错误的帧
- **THEN** 被接受计数为 1，被拒绝计数为 1

#### Scenario: UI 帧计入被接受

- **WHEN** 收到一个完整性正确、子项在范围内的 `0x04` 帧
- **THEN** 被接受计数递增，"其它大类"计数与被拒绝计数均不变

#### Scenario: 其它大类不污染坏包计数

- **WHEN** 收到一个大类为 `0x01` 的完好帧
- **THEN** 其它大类计数递增，被接受计数与被拒绝计数均不变

> 为什么必须分开：同一条线上跑着所有功能模块的帧。若把其它大类混进
> "坏包"里，坏包率会永远很高、完全失去诊断意义。

### Requirement: UART 通道分配与参数

协议端点 MUST 独占 uart1。软核 MUST NOT 在 uart1 上输出任何非协议内容（包括调试文本）。uart1 MUST 配置为 115200 baud、8 数据位、无校验、1 停止位。

#### Scenario: 调试文本不污染协议通道

- **WHEN** 协议端点正在运行且软核产生调试输出
- **THEN** 所有调试字节只出现在调试通道上，uart1 上只出现协议帧

#### Scenario: 配置与 BSP 一致

- **WHEN** 软核初始化 uart1
- **THEN** 其分频系数按 `clk / (115200 × 8) - 1` 计算，与 `bsp_init()` 对 uart0 的处理一致

### Requirement: 协议路径独立于调试通道配置

协议端点的收发 MUST 直接操作 uart1 的数据寄存器，MUST NOT 经由 `bsp_putChar`、`_putchar`、`bsp_printf` 或任何随 `ENABLE_SEMIHOSTING_PRINT` 改变行为的接口。

#### Scenario: 调试通道开关不影响协议行为

- **WHEN** `ENABLE_SEMIHOSTING_PRINT` 被设为 `0` 或 `1` 并重新构建
- **THEN** 协议端点的帧解析、CRC 校验结果与应答字节序列完全一致，两种配置下的应答逐字节相同

#### Scenario: 协议应答不经打印栈

- **WHEN** 软核发送一个应答
- **THEN** 该应答的每个字节都由写 uart1 数据寄存器产生，MUST NOT 经过 `bsp_printf` 或 semihosting 调用

### Requirement: 端点互斥约束

软核协议端点 MUST NOT 与 RTL 的 `RtlMaskUartAxiWriter` 端点同时应答同一命令流。该互斥由 RTL 侧 `rtl_mask_mode` 的选择决定，软核 MUST 在启动日志中报告自身的协议端点已启用，以便现场核对只有一个端点在应答。

#### Scenario: 启动日志标识

- **WHEN** 软核完成初始化
- **THEN** 调试通道上输出一行标识，包含协议端点、所在 UART 与使能状态

> 注意：`RtlMaskUartAxiWriter` 使用的是**上一代**报文约定（大类字节固定 `0x06`、
> 子项打包成 `0x86`–`0x89`），与上位机工具不兼容。当前位流里
> `rtl_mask_mode = 1'b0` 已把它关闭，运行中的应答方是软核。详见 `design.md`。
