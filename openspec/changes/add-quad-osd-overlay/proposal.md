# Proposal

## Why

BT.656 输出前目前只有**一路**掩膜叠加（`src/overlay/HyperRamMaskOverlayYuv422.v`），
且实际生效的是 legacy 全屏 720×576 位图模式 —— `src/top.v:493` 把 `rtl_mask_mode`
硬接为 `1'b0`，使模块走 `MASK0_BASE=0x0040_0000` / `MASK1_BASE=0x0050_0000` 的全屏画布分支。

这种形态只能整屏叠加一幅位图，无法在同一画面同时标注多个互不相干的区域
（例如多个目标框、多个状态角标）。现场需要在同一路 CVBS 视频上并行显示
**4 个可独立配置位置与大小的 OSD**。

## What Changes

- **BREAKING** 删除 legacy 全屏 720×576 掩膜模式与 `raw_mode` 双寻址分支，叠加逻辑统一为 4 窗口。
- 新增 4 路互相独立的 OSD 叠加，位置与大小**运行时可调**，单路最大 **512×288**；
  "互不重叠"由软件保证，硬件不做重叠检查。
- 每路**独立 enable**、每路**独立 A/B 双缓冲选择**。
- 混合行为**保持现状不变**：位图字节非零 → 替换为纯白 `16'h80EB`，零 → 原像素透传。
  不引入 alpha 混合（当前 RTL 本就没有 alpha，"半透明掩膜"仅为文档失真表述，见 design.md）。
- 扩展 `MaskControlRegs`（`0xE1043000`）：新增 4 组 `{left, top, width, height}` 与
  `CTRL{enable, buffer_select}` 寄存器，沿用既有 commit/toggle 提交与帧边界生效协议。
- 位图内存布局移至 `0x00A0_0000–0x00BF_FFFF`：4 路 × A/B × 256 KB，**行跨距固定 512 字节**。
- 两条位图上传路径都扩展到 4 区域：RTL 侧 `RtlMaskUartAxiWriter` 与软核 AXI 路径，
  由 `rtl_mask_mode` 选择（该信号语义收窄为"控制权/上传者选择"，不再是寻址模式选择）。
- 缓存架构**保持 2 bank × 256 字节不变**：仅把预取地址由写死的 `block_addr + 256`
  推广为"扫描序上的下一块"，避免 4 窗口跳转导致逐像素阻塞视频流。
- 修正与 RTL 不符的文档表述（掩膜地址、alpha 描述），避免后人继续被误导。

## Capabilities

### New Capabilities

- `video-osd-overlay`: BT.656 输出前的多路 OSD 叠加能力。覆盖 4 路独立窗口的几何/使能/
  双缓冲配置契约、位图在 HyperRAM 中的内存与寻址契约、上位机上传与寄存器提交协议、
  与视频流的握手及阻塞预算约束、以及该模块的诊断可观测性。

### Modified Capabilities

无。项目当前 `openspec/specs/` 为空（尚无任何已建立的 capability），
本次不修改既有 spec 级需求。

## Impact

**RTL 代码**
- `src/overlay/HyperRamMaskOverlayYuv422.v` — 核心改写（4 窗口 + 扫描序预取）
- `src/control/MaskControlRegs.v` — 寄存器扩展
- `src/control/RtlMaskUartAxiWriter.v` — 上传目标由 1 区域扩到 4 区域
- `src/top.v` — 例化改写、`ConfigSnapshotCdc` 位宽 2 → 193、控制源 mux 与注释

**接口 / 契约**
- AXI 寄存器映射 `0xE1043000` 由 4 个字扩展到 20 个字
- HyperRAM 布局：`0x00A0_0000–0x00BF_FFFF` 由"1 区域 × A/B"改为"4 区域 × A/B"
- 上位机 UART 上传协议需新增区域索引/偏移字段

**文档**
- `docs/architecture.md`（`:283` alpha 表述、`:286` 地址、模块描述段）
- `docs/memory_axi.md`（`:11-18` 内存表、`:211` Buffer A/B 段）
- `docs/CLAUDE.md`（`:44`、`:71`、`:120`、`:135`、`:288-289`）、`src/README.md`（管线图与目录说明）

**外部依赖**
- 软核固件源码**不在本仓库**（仅有预编译 `ivlabIspSoftCore.hex`）。本变更只定义 RTL 侧契约
  （区域地址 + 寄存器映射），固件侧改造列为仓库外依赖。

**测试与综合**
- `sim/` 目录为空（本仓库部分检出），`docs/testing.md:40` 记载的 `tb_hyperram_mask_overlay.v`
  不可扩展，需**新写**自检测试平台
- Efinity 综合后需复核 Ti60 资源与时序（overlay 的组合地址逻辑变复杂）

**向后兼容**
- legacy 全屏掩膜功能被移除，上位机与固件必须同步改造，否则现有整屏掩膜能力失效
