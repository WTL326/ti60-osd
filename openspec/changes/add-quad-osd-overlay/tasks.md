# Tasks

## 1. 基线与仿真环境

- [ ] 1.1 在 `sim/`（当前为空）下建立 ModelSim/Questa 编译与运行脚本，使改动前的
      `src/overlay/HyperRamMaskOverlayYuv422.v` 可被 `vlog` 无错误编译。
      验证：`/h/modeltech64_10.4/win64/vlog.exe -quiet -sv` 对该文件返回 0 且无 error。
- [ ] 1.2 记录改动前基线：在 legacy 全屏模式下喂入一幅 720×576 位图，导出输出像素序列。
      验证：基线文件落盘，供 2.4 做逐像素对比。

## 2. RTL：叠加模块四窗口化

- [ ] 2.1 改写 `HyperRamMaskOverlayYuv422` 的端口与参数：删除 `raw_mode`、`mask_left`、
      `mask_top` 端口与 `MASK0/1_BASE`、`RTL_MASK0/1_BASE`、`RAW_MASK_*` 参数；
      新增 `osd_enable`、`osd_buffer_select`、`osd_left`、`osd_top`、`osd_width`、`osd_height`
      与 `OSD_ROW_STRIDE`。
      验证：编译通过，端口位宽与 design.md D3/D6 一致。
- [ ] 2.2 删除 legacy/raw 双寻址分支，实现统一的逐路窗口判定与像素地址生成：
      `base(i,buf) + (display_y - top_i)*512 + (x_count - left_i)`，行首保持 256 字节对齐，
      并实现越界裁剪。
      验证：单元仿真断言窗口内像素取址正确、窗口外不发起任何读取请求。
- [ ] 2.3 把预取地址由写死的 `block_addr + 256` 改为 design.md D4 的"扫描序下一块"
      （规则 1–4），保持 2 bank 乒乓与 `need_read`/`can_prefetch` 原结构不变。
      验证：仿真中断言每行冷缺失 ≤ 1 次，且缓存 bank 数量仍为 2。
- [ ] 2.4 保持输出替换语义不变（`mask_byte != 0` → `16'h80EB`，否则透传），不引入 alpha。
      验证：把某一路配置为占满画面（720×576 视作宽高上限内的裁剪情形）后，
      输出与 1.2 基线在非重叠区域逐像素一致。
- [ ] 2.5 扩展诊断输出：`active_buffer_select` 与新增的 `applied_enable` 各为 4 bit，
      新增因等待位图而阻塞视频流的累计周期数 `stall_count`。
      验证：仿真中 `stall_count` 随使能窗口数增加而合理增长，`read_error_count` 保持 0。

## 3. RTL：控制寄存器

- [ ] 3.1 按 design.md D6 把 `MaskControlRegs` 扩展为 20 个字（4 组 `POS`/`SIZE`/`CTRL`
      加 `COMMAND`/`STATUS`/`CANVAS`/`ACTIVE`），沿用既有 commit 与 `pending` 期间拒绝新提交的语义，
      `left`/`top` 按有符号 12 bit 解码。
      验证：仿真断言各寄存器读回值与写入一致，且 `pending` 未清时的二次提交被忽略、已提交内容不被破坏。
- [ ] 3.2 实现 `ACTIVE` 回读，暴露每路当前实际生效的 `enable` 与 `buffer_select`。
      验证：帧边界后回读值与提交值一致，且帧边界前回读值仍为旧值。

## 4. RTL：上传路径

- [ ] 4.1 扩展 `RtlMaskUartAxiWriter` 由单区域到 4 区域（新增区域索引/目标选择字段），
      写入 design.md D3 的布局与行跨距。
      验证：仿真中不同区域索引的数据分别落在 4 个互不重叠的基址上。
- [ ] 4.2 复核 `rtl_mask_mode` 语义收窄为"控制权/上传者选择"后，
      `src/top.v:504`（`riscv_uart_rx`）、`:742`（上传状态机使能）、`:1417`（`mask_reply_tx`）
      三处使用仍然成立。
      验证：逐处确认逻辑不依赖已在 D2 中删除的寻址语义，且编译通过。

## 5. RTL：top 集成

- [ ] 5.1 改写 `src/top.v:1777-1824` 的例化：替换参数为新基址/行跨距，替换端口为 4 路配置信号。
      验证：`vlog` 编译整个设计通过，无未连接或位宽不匹配告警。
- [ ] 5.2 把 `src/top.v:1053` 的 `ConfigSnapshotCdc` 位宽由 2 改为 193，
      并更新 `src/top.v:1431-1432` 的控制源 mux 以选取新快照的对应位。
      验证：仿真确认 4 路配置能经 CDC 正确到达叠加模块，且控制源切换仍有效。
- [ ] 5.3 复核 `src/top.v:1090-1098` 的 3 拍 settle 逻辑与 `mask_cfg_apply` 在快照加宽后仍成立。
      验证：仿真断言帧中提交时当前帧不变、下一帧整体生效。
- [ ] 5.4 更新 `src/top.v:1774` 附近说明与 `:1827-1829` 的地址避让注释，使其反映新的
      4 路 OSD 布局与控制方式。
      验证：注释中出现的地址与参数值同 design.md D3 完全一致。

## 6. 单元验证：自检测试平台

- [ ] 6.1 新写自检测试平台（`sim/` 为空，`docs/testing.md:40` 记载的
      `tb_hyperram_mask_overlay.v` 在本检出中不存在，无法扩展），内置由数组支撑的
      128-bit AXI 读响应模型。
      验证：平台可运行并输出 pass/fail 汇总。
- [ ] 6.2 覆盖基础语义用例：4 路同显、单路禁用、全局禁用、位图字节非零、位图字节为零、
      像素在所有窗口之外。
      验证：断言全部通过。
- [ ] 6.3 覆盖几何用例：单路 512×288 最大尺寸、贴 `left=0`/`top=0`、
      贴 `left+width=720`/`top+height=576`、负偏移越界裁剪。
      验证：断言全部通过。
- [ ] 6.4 覆盖配置用例：每路独立 A/B（只切换第 2 路时其余三路输出逐像素不变）、
      帧边界原子生效、`pending` 期间拒绝新提交、未提交的写入不生效。
      验证：断言全部通过。
- [ ] 6.5 覆盖性能与错误用例：4 路均配置 512×288 并同时使能时的阻塞预算与读取错误。
      验证：断言每行冷缺失 ≤ 1 次、`read_error_count` 为 0，并把 `stall_count` 实测值
      回填到 design.md 的 Open Question 3 作为板级验收阈值。

## 7. 综合与板级回归

- [ ] 7.1 运行 Efinity 综合，复核 Ti60 资源与时序，重点关注 4 路窗口比较与 mux 的组合深度。
      验证：时序满足 `constraints.sdc`，无新增违例，资源余量与 `docs/timing_resources.md` 相比无实质下降。
- [ ] 7.2 对照 `outflow/EFX.warn.log` 确认两个缓存 bank 仍被识别为 memory block。
      验证：警告日志仍记录为逻辑存储块，未被展开成触发器。
- [ ] 7.3 烧写后经 VIO 观察 `p1x` 帧计数、`read_error_count`、新增 `stall_count`
      与 `ACTIVE` 回读值。
      验证：帧计数逐帧递增、错误计数保持 0、阻塞计数不超过 6.5 回填的阈值。
- [ ] 7.4 CVBS 目视确认 4 路 OSD 位置与尺寸正确、无闪烁与撕裂，并按
      `docs/CLAUDE.md:255-263` 的回归清单逐条确认（含 `p18_ScalerDroppedFrames` 保持 0）。
      验证：清单各项均通过。
- [ ] 7.5 与上位机/固件联调：RTL 上传路径与软核上传路径各完成一次 4 区域位图写入。
      验证：两次上传后对应路显示正确，且两条路径产出的显示结果一致。

## 8. 文档与外部依赖

- [ ] 8.1 修正 `docs/architecture.md`：删除 `:283` 的"半透明掩膜"表述、改正 `:286` 的掩膜地址、
      更新该模块的描述段以反映 4 路窗口。
      验证：描述与 RTL 实际行为及 design.md D1/D3 一致。
- [ ] 8.2 更新 `docs/memory_axi.md:11-18` 的内存表与 `:211` 的 Buffer A/B 段为新的 4×2 布局，
      并修正把 `0x0040_0000` 仅描述为"热点追踪工作区"的措辞（该段同时承载软核掩膜画布）。
      验证：地址表与 design.md D3 逐项一致。
- [ ] 8.3 更新 `docs/CLAUDE.md`（`:44`、`:71`、`:120`、`:135`、`:288-289`）与 `src/README.md`
      的管线图、目录说明与内存映射段。
      验证：文档中不再出现单路掩膜或 legacy 全屏模式的描述。
- [ ] 8.4 确认 Efinity 工程文件列表与实际源文件一致：若本次新增 RTL 文件则同步
      `ivlab239.xml`，若不新增（按 design.md D8 不改名、不新增）则确认无需改动。
      验证：`ivlab239.xml` 中的 `design_file` 条目覆盖全部改动到的源文件。
- [ ] 8.5 向固件与上位机团队书面移交契约：4 区域地址表、寄存器映射、
      位图格式（每像素 1 字节、行跨距 512、非零即纯白）与不重叠的软件责任。
      验证：契约已交接，且联调安排落在 7.5。
