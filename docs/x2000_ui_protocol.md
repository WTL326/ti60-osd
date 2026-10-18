# X2000 → TI60 UI 状态协议

## 1. 目的

X2000 不再通过重复模拟 `up/down/enter/back` 来同步页面，而是直接向 TI60 下发“当前应显示的页面状态”。旧按键命令继续保留用于调试和人工操作。

## 2. 公共报文

```text
BB | body_len:u16BE | category | subcommand | type | payload | crc16:u16BE | AA
```

- `category = 0x04`：UI；
- X2000 写命令 `type = 0x00`；
- TI60 应答 `type = 0x02`；
- CRC 为 CRC16-CCITT，初值 `0x0000`，覆盖完整 body；
- 普通应答 body 为 `04 | subcommand | 02 | status`，成功值 `status=FF`。

## 3. UI 状态命令

### 3.1 SET_VIEW（0x06）

```text
payload = page_id:u16BE | selected_item:u8 | flags:u8
```

- `selected_item` 是该页面中的绝对子项序号，从 0 开始；
- `flags.bit0`：UI 显示；
- `flags.bit1`：进入数值编辑状态；
- `flags.bit2`–`bit7`：保留位，发送方应置 0。**TI60 对保留位静默丢弃**
  （内部按 `flags & UI_FLAG_MASK` 取值），因此"保留位非 0"**不构成失败** ——
  不返回错误、不影响页面切换，也不会被回读进 `QUERY_VIEW` 的应答；
- 编辑状态只允许用于图像设置页的前四项；
- 页面或选中项非法（含在非图像设置页、或在该页前四项之外请求编辑状态）时
  TI60 返回失败，不切换页面。

> 保留位的宽容行为是**有意**的：它让上位机将来可以先行占用高位而不必与 TI60 同步发版。
> 上一条"应置 0"是发送方的**约定**，不是 TI60 的**校验**——两者并存，
> 不要据此认为保留位非 0 会失败。

### 3.2 SET_IMAGE_VALUES（0x07）

```text
payload = image_enhance:u8 | contrast:u8 | image_brightness:u8 | screen_brightness:u8
```

- `image_enhance` 范围 0～5；
- 其余三项范围 0～10；
- 四项一次提交，任意一项越界则整条命令失败。

### 3.3 QUERY_VIEW（0x08）

无 payload。成功回包 body：

```text
04 | 08 | 02 | FF | page_id:u16BE | selected_item:u8 | flags:u8 |
image_enhance:u8 | contrast:u8 | image_brightness:u8 | screen_brightness:u8
```

这里的 flags 与 `SET_VIEW` 相同。完整成功回包固定 18 字节。

## 4. 稳定页面 ID

| page_id | 页面 |
|---:|---|
| `0x0000` | 一级菜单 |
| `0x0100` | 图像设置 |
| `0x0101` | 画中画 |
| `0x0102` | 图像校正 |
| `0x0200` | 调色板 |
| `0x0300` | 电子变倍 |
| `0x0400` | 功能 |
| `0x0401` | WiFi 设置 |
| `0x0402` | 拍摄时刻 |
| `0x0500` | 系统设置 |
| `0x0501` | 语言 |
| `0x0502` | 时间和日期 |
| `0x0503` | 按键分配 |
| `0x0504` | 自动关机 |
| `0x0505` | 坏点修复 |
| `0x0600` | 测量 |
| `0x0601` | 光标颜色 |
| `0x0700` | 校准 |
| `0x0701` | 校准调整 |
| `0x0702` | 校准组 |
| `0x0703` | 准星样式 |
| `0x0704` | 准星颜色 |
| `0x0800` | 弹道 |
| `0x0801` | 弹道标记颜色 |
| `0x0900` | 显示设置 |
| `0x0901` | 画面移动 |

> **实现范围（当前固件）**：上表是**协议侧保留的稳定 ID 全集**，但 TI60 固件目前只实现了 3 页 ——
> `0x0000` 一级菜单（9 项）、`0x0100` 图像设置（6 项，前 4 项是数值行）、`0x0200` 图像模式
> （规格里叫“调色板”，固件标题是 `IMAGE MODE`，4 项）。
> 对其余页发 `SET_VIEW` 一律返回失败（10 字节应答、`status=0x00`），且不改变当前状态。
> 逐页对照与测试命令见 [osd_menu_test_commands.md](osd_menu_test_commands.md)。

页面 ID 在菜单文字或生成数组顺序变化后保持不变。完整映射由 `tools/generate_ui_menu.py` 中的 `PAGE_PATH_IDS` 维护。

## 5. X2000 推荐刷新顺序

1. 页面切换时发送一次 `SET_VIEW`，同时给出正确的选中项；
2. 四个图像参数变化时发送一次 `SET_IMAGE_VALUES`；
3. 如需核对 TI60 状态，发送 `QUERY_VIEW`；
4. 串口超时或返回失败时重发完整目标状态，不依赖上一条按键是否成功。

同一命令可重复发送，显示结果保持一致。TI60 在完成字符页非活动 bank 写入并提交后才返回成功，因此画面按整页刷新，不产生半页菜单。
