# 上板验证清单 —— 四路 OSD 窗口（变更 `add-quad-osd-overlay` 的 §8）

本清单只覆盖**必须上板**的部分。离机验证（4 个自检测试平台 + 固件 204 项断言）已全部通过，
见 `sim/` 与 `openspec/changes/add-quad-osd-overlay/tasks.md` 的 1–7 节。

**本次范围**：8.1 综合与时序、8.2 memory block、8.3 VIO 诊断、8.4 CVBS 目视 + 回归清单、
8.5 的 **RTL 上传路径**。
**不在本次范围**：8.5 的软核上传路径（固件侧没有"把位图写进某一路"的入口）、
8.6（0x04 端到端，需要重建固件）。

三处改动只有上板能证伪，本清单的重心就在它们：
① 删掉了 `top.v` 的 3 拍 settle（配置路径）；② 预取改为扫描序（组合逻辑变深）；
③ 两个缓存 bank 的 memory 映射可能变化。

---

## 前置

- [ ] `EFINITY_HOME` 已设（`efx_*` 脚本与 `binGen.py` 都依赖它）。
      阶段 6 的 `run_merge_flash_image.sh` 还会自己导出 `EFXPGM_HOME`/`EFXDBG_HOME`/
      `PYTHONHOME` —— 官方 `multi_image_merger.py` 少了这几个会以各种方式报错
      （KeyError、`No module named 'encodings'`），脚本里已一并处理，不必手工设。
- [ ] 已备份改动前的 `outflow/`（时序/资源/warn.log 的对照基线）

> **基线是"调试位流"的数字，比对时要按这个口径。** 现有 `outflow/` 里那份产物
> **含调试核**（`ivlab239_c.hier_util.rpt` 里有 `edb_top_autodbg_inst__` 与
> `debug_hub_inst`），因为 `work_pnr/run_efx_pnr.sh` 显式带
> `--vdb_file outflow/ivlab239_c.dbg.vdb --use_vdb_file on`，而 `ivlab239.xml`
> 的 `<efx:debugger>` 里 `auto_instantiation="on"`。
> **本工程此前根本没有跑过"不含调试核"的位流**，所以正式位流的资源应当比基线
> **低**（大约少 `xlr_lut4 717+32`、`FF 323+87`、`mem 1`），而不是"不高于基线"。
> 判定脚本的 5% 容差对这种"应当变低"的比对是宽松的，够用；但**别把"资源少了"
> 当成异常**。
- [ ] 已生成测试位图：`python tools/make_test_bitmap.py`
      → `tools/out/mask_test.bmp`（544×288、24 位、自检通过）
- [ ] 待观测信号能挺过综合优化（见下）

### 待观测信号会不会被综合清掉

`mask_frame_count`、`mask_read_error_count`、`mask_reader_active`、`mask_stall_count`
在 `top.v` 里**没有消费者**（只有声明与例化两处引用）。而 `mask_active_buffer_select`
与 `mask_applied_enable_out` 有消费者（它们进 `MaskControlRegs` 的 ACTIVE 回读），不受影响。

**结论：走对探针源就不需要改 RTL。** 本工程的探针合并走的是
`--vdb outflow/ivlab239_c.elab.vdb`（**综合前**的网表），在那一层做连接时
LA 的探针输入端口本身就是该信号的负载，于是即便它原本会被优化掉，
连上之后重新 map 时也会被保留。详见阶段 3.1。

**验证手段（不必等 EDB）**：综合后跑 `python tools/check_synth_reports.py`，
看它报的"待观测信号里被删掉的"与"存在性检查"。改前的网表里
`mask_frame_count` 与 `scaler_dropped_frame_count` 查得到、其余查不到 ——
这正是"新加的信号还没进设计"应有的样子。

## 阶段 1：位流 A 的报告判定（可脚本化）

位流 A = `rtl_mask_mode = 1'b0`、**不含调试核**，它是正式位流，时序结论以它为准。

**关键**：不跑 `work_dbg/` 脚本**并不等于**得到正式位流 —— `run_efx_pnr.sh` 里写死了
`--vdb_file outflow/ivlab239_c.dbg.vdb`（调试核的 vdb）。必须：

```bash
cp work_pnr/run_efx_pnr.sh work_pnr/run_efx_pnr_formal.sh
# 把 --vdb_file ".../outflow/ivlab239_c.dbg.vdb" 改成 ".../outflow/ivlab239_c.vdb"
# 其余参数一字不改（--use_vdb_file on、--prj、--sdc_file、--seed 1 都保留）
```

> **判定**：`outflow/ivlab239_c.route.rpt` 的 `GBUFCE Assignments` 表里
> **不出现** `edb_top_autodbg_inst__/bscan_TCK_buffered`。出现了就是误带了 `.dbg.vdb`。

- [ ] **1.1** `bash work_syn/run_efx_map.sh`（**两条路线共用这一次综合**）
- [ ] **1.2** `bash work_pnr/run_efx_pnr_formal.sh`（见上，用 `ivlab239_c.vdb`）
- [ ] **1.3** `bash work_pnr/run_efx_pgm.sh` → `outflow/ivlab239_c.hex`
- [ ] **1.4** `python tools/check_synth_reports.py`

**判定**：脚本输出 `PASS`。它逐项检查：所有时钟余量为正；`clk` 域的余量不比基线退化
超过 0.2 ns；资源不比基线增长超过 5%；两个缓存仍映射为 memory；待观测信号没被删。

**当前基线（改动前实测，2026-09-22 位流，已存 `tools/out/synth_baseline.json`）**：

| 时钟 | 约束 | 实际需要 | 余量 |
|---|---|---|---|
| `clk` (100 MHz) | 10.000 ns | 9.723 ns | **+0.277 ns（最紧）** |
| `clk_scaler` (160 MHz) | 6.250 ns | 5.579 ns | +0.671 ns |
| `hbramClk` (200 MHz) | 5.000 ns | 3.997 ns | +1.003 ns |
| `bt1120_clk` (80 MHz) | 12.502 ns | 5.056 ns | +7.446 ns |
| `clk50M` (50 MHz) | 20.000 ns | 7.763 ns | +12.237 ns |

资源：FFs 22492、LUTs 25903、RAMs 181、DSP/MULTs 152。

> **注意**：`docs/timing_resources.md` 里那组数字来自更早的分支，与这份报告不一致
> （它说最紧的是 `clk_scaler` +0.292 ns，实际最紧的是 `clk` +0.277 ns）。
> **以本次报告为准**，并把新数字回填进那份文档。

> **归档是强制的**：`run_efx_pnr.sh` 与 `run_efx_pgm.sh` 靠**文件名**串联
> （pgm 读 `work_pnr/ivlab239_c.lbf`），两条路线会互相覆盖。每跑完一条就立刻把
> `timing.rpt`/`res.csv`/`.hex`/`.bit`/`work_pnr/*.lbf` 拷进 `outflow/formal/`
> 或 `outflow/dbg/`，并把 `git rev-parse HEAD` 记在一个 README 里。
> **顺序强制：正式位流跑完并归档后，才允许跑调试位流。**

**失败时先查什么**：`clk` 域的余量只有 0.277 ns，而本次新增的比较/mux 正好在 `clk` 域。
若退化超标，按 design.md 的预案把"下一块地址"打一拍寄存（预取本就提前若干拍发起，
寄存不影响正确性），再综合一次。

- [ ] **1.5（8.2）** 单独确认 memory 映射：`grep -n "EFX-0657" outflow/EFX.warn.log`

**判定是三选一，不是"必须看到警告"**（本次已把缓存的读改成同步读
`HyperRamMaskOverlayYuv422.v:515-516`，于是警告消失、缓存变成真 RAM10 是**更好的**结局）：

| 结局 | 现象 | 判定 |
|---|---|---|
| 甲 | 警告仍在（行号由 `:61,62` 变成 `:297-298`） | **通过**，与改动前等价、行为与仿真一致 |
| 乙 | 警告消失 **且** `EFX_RAM10` 上涨 | **通过，更好**（缓存变成真 RAM10） |
| 丙 | 警告消失 **但** `RAM10` 不动、`LUT4` 也不降 | **失败**，缓存被展开成了离散逻辑/触发器 |

判定脚本已按这三种结局实现（首版写的是"看不到警告就报错"，会把最好的结局判成红的）。

**失败时先查什么**：若缓存不再出现在 EFX-0657 里、且资源明显增长，用本仓库现成的手段
`(* syn_ramstyle = "block_ram" *)`（先例 `src/hot_focus/HotFocusLineBufTi60.v:17`）。

---

## 阶段 2：位流 A 上板（8.4，目视 + VIO）

- [ ] **2.1** EDB 烧写位流 A（USB JTAG，约 20 秒）
- [ ] **2.2** 接 BT.1120 源（1280×1024@30）
- [ ] **2.3 回归清单**（逐条，判定标准见括号）

| 项 | 观测 | 判定 |
|---|---|---|
| 帧计数 | 各帧计数器 | 持续递增，不停在某值 |
| FIFO 健康 | `scaler_dropped_frame_count`、`read_fifo_underflow_count` 及其余溢出计数 | **全部保持 0**（这一条正对本次改动：删 settle 改了配置路径） |
| CVBS | 画面 | 稳定、无撕裂、无闪烁、无黑屏 |
| DVP | X2000 侧 | 能正常收到画面 |
| 电子变倍 | 启用/禁用 | 无损坏帧 |
| 热点十字丝 | 位置 | 对齐（若启用） |

- [ ] **2.4 CVBS 目视（本阶段的重点）**

本轮位流里四路都还没有位图（软核路径不验、RTL 上传要切到阶段 4 的位流），
所以这里确认的是 **"无 OSD 时画面与改动前一致"**：
视频透传、不叠加、不花屏、不丢行、无撕裂。
**判定**：与改动前的画面相比无可观察差异。

> "4 路 OSD 位置正确、叠加为纯白"这条在阶段 4 只能部分看到（位流 B 里只有 OSD0 有图）。
> 若要求四路都有图再目视，需要另找一条写入手段 —— 与"软核路径本轮不验"冲突，需另行商量。

- [ ] **2.5** 记录本阶段的 VIO 读数（若有）供阶段 3 对照

---

## 阶段 3：调试位流（8.3，VIO 观测）

调试位流含调试核，**它的时序与资源数字不代表正式位流**，不做签核。

- [ ] **3.1** 在 EDB 的 Debug Wizard 里选信号。**关键：`Signals from` 必须选
      `Elaborated Netlist`，不要选 `Post-Map`。**

      本工程的探针合并走的是 `--vdb outflow/ivlab239_c.elab.vdb`（**综合前**的网表，
      见 `work_dbg/run_efinity_auto_dbg.sh` 第 2 条命令），`debug_profile.wizard.json`
      里的 `session.wizard.src = "elaborate"` 与之吻合。这一点很重要：
      **在 elaborate 层做连接时，LA 的探针输入端口本身就成了该信号的负载**，
      于是即便它原本会被优化掉，连上之后在重新 map 时也会被保留。
      走 `Post-Map` 则只能列出 post-map 里还活着的信号 —— 而
      `mask_frame_count` / `mask_read_error_count` / `mask_reader_active` /
      `mask_stall_count` 四条在 post-map 里已经被清掉了（实证：改前的
      `work_dbg/ivlab239_c.dbg.map.core.v` 里 `mask_frame_count` 出现 0 次）。

      > 因此"给信号加消费者"并不是必须的 —— 只要走 elaborate 源。
      > 若想让它们同时出现在批量 mark_debug 流里（可选保险），可以在
      > `src/top.v:206-210` 的 wire 声明上加 `(* mark_debug = "true" *)`，
      > 综合后检查 `outflow/debug_profile.mark_debug.json` 的 `selected_nets`
      > 是否被填上（**这可以当作一个 gate**：仍是空数组说明属性没被识别）。

      > **探针的时钟域选 `clk`（100 MHz），不要用现在的 `clk50M`**：
      > 叠加模块例在 `.clk(clk)`，计数器和 `active` 都在 100 MHz 域。
      > **建议把 `data_depth` 从 1024 降到 256**（本次总位宽约 73 bit，
      > 1024 深会明显吃 `EFX_RAM10`），`mask_stall_count` 设 Data Only，
      > `capture_control` 保持 false。

      **这一步必须走 GUI**：`debug_top.v` 是 Wizard 生成的，手改
      `debug_profile.wizard.json` 的连接段而不重生成它，`efx_map --conn` 会静默丢连接
      或报 `VERI-1927 port remains unconnected`。
- [ ] **3.2** `bash work_dbg/run_efinity_auto_dbg.sh` → 烧写
      **判定**：`outflow/ivlab239_c.dbg.map.out` 里出现
      `compiling module 'edb_la_top_<uuid>(NUM_PROBES=6,...)'`

- [ ] **3.2b（Gate A）** EDB 能扫到 `la0` 并列出全部探针，位宽与预期一致
      **失败先查什么**：JTAG user tap。`ivlab239.peri.xml` 里**只有 `JTAG_USER1`**，
      `JTAG_USER2` 只出现在 `outflow/ivlab239_c.dbg.peri.xml` 里，
      而 `run_efinity_auto_dbg.sh` 第 3 条命令的目标路径
      `H:/Project/ivlab-239/ivlab239_c.dbg.peri.xml`（工程根目录）**当前不存在**。
      **这是路径/JTAG 问题，不要去怀疑探针定义或 RTL。**
- [ ] **3.3 观测并记录**

| 观测量 | 判定 |
|---|---|
| `mask_frame_count` | 逐帧递增 |
| `mask_read_error_count` | **保持 0**（非 0 = AXI 读响应异常或 ID 不匹配） |
| `mask_stall_count` | 记录**量级**即可，**不设阈值**（design.md Open Question 6 的口径）。仿真里 2×2 并排布局是 832 周期/帧，可作为量级参照 |
| `mask_cfg_pending` / `mask_cfg_apply` | 提交后 pending 抬起、帧边界处 apply 脉冲一次、随后 pending 归零 |
| **探针是否真的连上了** | 顺手 `grep -c mask_frame_count work_dbg/ivlab239_c.dbg.map.core.v`：**0 = 探针没连上**（不是帧源的问题）；>0 且板上恒 0 才是真的没帧 |

- [ ] **3.4 ACTIVE 回读走 ADB（不走 VIO）**

`MaskControlRegs` 的 `+0x0C` 读回 `{24'd0, applied_enable[3:0], applied_buffer_select[3:0]}`
（使能在**高半字节**）。写一组配置 → 提交 → 回读。
**判定**：回读值与刚提交的一致，且与 VIO 看到的 `mask_applied_enable_out` /
`mask_active_buffer_select` 相同。
这一条同时验证了 9 位那条反向快照 CDC（它是 D6 的 `ACTIVE` 回读能成立的前提）。

---

## 阶段 4：位流 B（8.5，RTL 上传路径）

> ### ⚠ 4.0 先补一个上位机工具（这是 8.5 的硬阻塞，不是可选项）
>
> **`tools/send_mask_via_adb.py` 与 RTL 端点说的不是同一套协议**，直接拿它跑必然失败：
>
> | | 工具发的（软核端点） | RTL 端点要的 |
> |---|---|---|
> | body 头 | `0x00` | **`0x06`** |
> | 命令 | `0x01`–`0x05` | **`0x86`–`0x89`** |
> | 应答 body | `00 cmd 02 status` | **`06 cmd 02 status`** |
>
> RTL 侧的解析在 `src/control/RtlMaskUartAxiWriter.v:300-322`，回包格式
> `BB 00 04 06 cmd 02 status crc AA`。**仓库里没有任何 0x86–0x89 的上位机实现**
> （`docs/adb_test_commands.md` 里只有手写 `echo -ne` 的单帧示例）。
>
> 所以先新增 `tools/send_mask_rtl_via_adb.py`：复用现成的 `read_binary_bmp()`
> （1 bpp、MSB-first 打包，`tools/test_mask_packing.py` 的 5 条位序断言照旧成立）
> 与 `crc16_ccitt()`；只换 body 头与命令码，`verify_ack()` 的期望帧头由
> `(0x00,cmd,0x02)` 改成 `(0x06,cmd,0x02)`。
> **RTL 端没有 Flash 持久化对应项，所以 `--persist` 在 RTL 模式下不可用。**
> **判定**：先用 `python tools/test_mask_packing.py` 确认打包位序没被改坏，
> 再对 RTL 发一帧最小位图（如 8×1）拿回一个合法 ACK。

- [ ] **4.1** 把 `src/top.v:504` 改为 `assign rtl_mask_mode = 1'b1;`
- [ ] **4.2** 重跑 1.1–1.3 → 位流 B。签核已在阶段 1 完成，这里只需确认**没有新增违例**
- [ ] **4.3** 烧写位流 B。**此时软核的 ADB 命令通道失效** —— 预期行为（见下）
- [ ] **4.4** `python tools/send_mask_rtl_via_adb.py --image tools/out/mask_test.bmp`
      （**不是** `send_mask_via_adb.py` —— 见 4.0）

**判定**：逐包的 10 字节 ACK 全部校验通过（帧头、长度、命令 CRC、状态 = 0xFF）。
工具会在任一包 ACK 对不上时报错；`0x04`/`0x05` 那两类的等待超时是 30 秒，别的 2 秒。

- [ ] **4.5 目视**

| 项 | 判定 |
|---|---|
| OSD0 显示 | 出现 `mask_test.bmp` 的图案：外框、四角方块、两条对角线、位序尺、中部棋盘 |
| 位置 | 与工具下发的 `--x`/`--y` 一致（默认 150/178） |
| 颜色 | **纯白**（Y=235），不是灰、不是半透明 |
| **位序** | 位序尺的白点落在**每 8 像素一组的最左**、第 1 组紧贴内容左边缘。若白点跑到组尾、整体偏移 6 像素 → **位序接反** |
| **镜像** | 两条对角线方向正确（左上→右下 与 左下→右上）。若互换了 → 左右镜像 |
| **菜单区** | OSD1 区域**没有被覆盖** —— 这是 D11「上传路 ≠ 菜单路」的现场确认 |
| 四角 | 四个角的小方块都完整可见（缺一个 = 边界判断把 `<=` 写成了 `<`） |

- [ ] **4.6** 再传一次切到 B 缓冲（`--image` 同一张，观察切换），确认**切换无撕裂**
- [ ] **4.7** 改回 `assign rtl_mask_mode = 1'b0;` —— **位流 B 那一版不要提交进仓库**
- [ ] **4.8** 重烧正式位流（阶段 1 的产物），把板子留在已知状态；
      `git status --short` 确认 `src/top.v` 干净

> 位流 B 因为 `mask_cfg_rtl` 是常量，**路 1/2/3 结构性不可能显示**（D7 的设计，
> 不是缺陷）—— 这一版只用来看路 0。

---

## 阶段 5：回填

- [ ] **5.1** 把实测值填进 `tasks.md` 的 8.1–8.5
- [ ] **5.2** 8.5 只勾到"RTL 路径已验证"，软核路径留未完成并注明原因
- [ ] **5.3** 用本次综合的报告刷新 `docs/timing_resources.md`（它现在是旧分支的数字）

---

## 阶段 6：固化位流 + 固件到 flash（掉电自启）

前面几个阶段都是「JTAG 烧位流 + GDB 下载固件」，掉电即失效。这一阶段把两者合并成
**一个**镜像写进 SPI flash，让板子脱离调试器也能起来。

- [ ] **6.0** ROM 里的 bootloader 是**用本仓库 BSP 编的那份**（不是 Efinity 的默认 init）。
      判定与修法见 `docs/osd_menu_test_commands.md` §1.2c —— **漏了这一步，后面全白做**：
      Efinity 默认灌入的 bootloader 用了另一套 SoC 地址映射（SPI `0xF8014000`，本 SoC 是
      `0xF8006000`），会让 flash 自启永远失败
- [ ] **6.1** 位流三连已跑完，且 `outflow/ivlab239_c.hex` 是**本次**的产物
      （判定同 1.3：头部是 `Mode: active`，且 `ivlab239_c.route.rpt` 里没有调试核）
- [ ] **6.2** `bash work_pnr/run_merge_flash_image.sh` → `outflow/ivlab239_boot.hex`。
      脚本会自己编固件、合并、并**逐字节复验**；只有退出码 0 才算过
      （`multi_image_merger.py` 自身出错也退 0，不能只看它）
- [ ] **6.3** 核对 `outflow/ivlab239_boot.rpt` 两行：位流 `0x00000000`、
      固件 `0x00380000` / `0x00009582`（38274 字节；固件改了这行会变）
- [ ] **6.4** Efinity Programmer（USB JTAG）烧 `outflow/ivlab239_boot.hex`，**active 模式**
- [ ] **6.5** **整机断电**（不要只按复位），重上电，**不接调试器、不下载固件**
- [ ] **6.6** `python tools/check_ui_end_to_end.py --dry-run` 自检，再
      `python tools/check_ui_end_to_end.py` 应全绿

6.2 是 bash 脚本。PowerShell 里这么调（**不必设 `EFINITY_HOME`**，脚本自带默认值；
路径写全就不要求当前目录在仓库根）：

```powershell
& "C:\Program Files\Git\bin\bash.exe" H:/Project/ivlab-239/work_pnr/run_merge_flash_image.sh
```

**判据为什么成立**：`check_ui_end_to_end.py` 不幂等，依赖 `ui_init()` 的数值初值
`[3,5,7,5]`（只在上电初始化时存在，`SET_VIEW` 不复位它们）。它能跑过 = 软核确实
冷启动过一次 = 固件是从 flash 被 bootloader 搬进 `0x1000` 起来的，
而不是上一次 JTAG 下载的残留。

**注意**：自启时**看不到启动横幅是正常的** —— 日志走 semihosting，不接调试器时
`ebreak` 被 `src/main.c` 的 `trap()` 静默吞掉（那是为"现场不接调试器运行"专门写的）。
别用"有没有横幅"判断自启成败。要在自启后看横幅，按 §2 的说明用
`monitor reset halt` + `continue`，**不要 `load`**。

> **归档**：`outflow/ivlab239_boot.hex` 与 `.rpt` 也要随正式位流一起归档，
> 并在 `outflow/formal/README` 里记下 `git rev-parse HEAD`。它约 11 MB，且可由两个
> 输入完全复现，所以**不入库**（根目录 `.gitignore` 已忽略；真要入库用 `git add -f`）。

---

## 看起来像故障但不是故障

- **`send_ui_via_adb.py` 的 `--show`/`--hide`/`--key`/`--clear`/`--marker` 超时**：
  走本期不纳入的 sub `0x01`–`0x05`，软核按契约"只解析、不应答"。设计如此。
  （8.6 本轮也不做，所以这三条路径本轮都不验。）
- **位流 B 里一切经软核的 ADB 命令都没反应**：`rtl_mask_mode=1` 把 `riscv_uart_rx_1`
  切成常量，软核收不到 UART。预期行为。
- **旧固件的掩膜上传在位流 A 上没有画面变化**：它写的是 `0x0040_0000` 的老画布，
  新 RTL 已不读那一段；位流里那 4 KB 片上 RAM 装的始终是 Efinix 的 SPI-flash
  bootloader（不是本工程的固件——固件在 flash `0x00380000`，或由 GDB 下到 `0x1000`）。
- **`tools/generate_ui_menu.py` / `generate_ui_font.py` 直接失败**：前者输出路径写死在
  不存在的 `D:\Desktop\...`，后者依赖 PIL 且 `src/ui/` 不存在。属后续"26 页菜单"那条路。
- **`EFX.warn.log` 里的 `Re-wiring to GND non-driven net`**：`hbram_top` 的 `native_*`
  端口与调试核的探针位，改动前就有，不是本次引入的。
- **`efx_map` 一启动就 `EXCEPTION_ACCESS_VIOLATION`（段错误），日志里连工程都没读**：
  先查 **`EFINITY_HOME` 有没有设**。`work_syn/run_efx_map.sh` 用的是绝对路径调
  `H:/Efinity/2026.1/bin/efx_map`，所以看起来"不需要环境变量"，但**工具自己要它**
  去找器件/器件库数据 —— 少了就直接崩在启动处，栈是 `libefx.dll`，看不出跟工程有关。
  实测：`export EFINITY_HOME="H:/Efinity/2026.1"` 后同一条命令 59 秒跑完、退出码 0。
  同样的坑对 `efx_pnr` / `efx_pgm` 一样。
- **OSD0 / OSD2 / OSD3 三路"没有内容"或"使能恒 0"**：当前位流里
  `rtl_mask_mode = 1'b0` 把掩膜上传状态机旁路了（OSD0 因此无写入方），而固件只写 OSD1；
  另三路的暂存值一直是复位值 0，**每次 UI 提交都会把它们按 0 推出去**。
  所以这不是"叠加坏了"，也不代表哪一路的窗口配置错了 ——
  详见 `docs/osd_bitmap_contract.md` §3 的「当前实现下的实际可用窗口」。
  **推论**：阶段 2.4 与阶段 4.5 能看到的叠加都只可能出现在内容被写过的那一路上。
- **某一路被使能却没写过位图 → 杂乱白点**：HyperRAM 上电不初始化。
  当前"提交即清零"恰好避开了它，但**一旦有了写路 0/2/3 的入口、把它们使能起来却没写位图，
  就一定会看到**。这不是叠加缺陷，是读到了未初始化的内存。

---

## 失败时的排查方向

| 症状 | 先查 | 再查 |
|---|---|---|
| OSD 位置/使能**偶发错一位**、切换后某一帧花 | `mask_cfg_pending`/`mask_cfg_apply` 的 VIO 波形 | `ACTIVE` 回读是否与提交一致；与"位图内容整块错"区分：那是整块错，这是个别位 |
| 位图**整块**位置偏 | 8 个基址参数与位图格式契约（`docs/osd_bitmap_contract.md`） | 工具的 `--width/--height` 是否等于 RTL 的编译期参数 |
| 画面**卡顿**、帧计数不递增 | `mask_stall_count` 的量级、`mask_read_error_count` | 预取是否真的命中（`clk` 域时序是否收敛） |
| 上传后画面**完全不动** | `rtl_mask_mode` 常量是否真的改成 1 | ACK 是否回来（工具会报）、BMP 是否 544×288 且宽度是 8 的倍数 |
| 资源**明显增长**、时序变差 | `EFX.warn.log` 里两个缓存还在不在 EFX-0657 | 按 R1 加 `syn_ramstyle` |
| 探针**挂不上**、EDB 里选不到网 | `tools/check_synth_reports.py` 的"被删掉的信号" | 给信号加消费者后重综合 |
