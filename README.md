# TI60 软核 OSD — MCU 侧 C 代码（P1 渲染链路）

> 契约基线：《TI60_OSD_MCU接口契约细化_v0.1.md》（C-1…C-8 已决，仅 C-9 寄存器偏移待 RTL）

## 目录

```
osd/
  core/          共享代码（零硬件访问，板级/PC 完全同一份）
    osd_config.h   软硬契约唯一落点（所有常量）
    canvas.h       L5 画布抽象接口（可移植边界）
    platform.h     平台抽象（串口收发/调试输出）
    font.h/.c      L3 查码点 + 取行位（二分查找）
    composer.h/.c  L4 网格→像素（全量重画菜单区）
    ui.h/.c        L2 状态机 + scene_build（只改状态和网格）
    scene_table.h/.c  页面静态数据（P1/P2/P3，EN/RU）
    proto.h/.c     L1 BB..AA 成帧 + CRC16-CCITT + 4 深帧队列
    dispatch.h/.c  命令派发（统一非法口径）
    osd_app.h/.c   L6 主循环（poll→dispatch→render→commit→flip）
    utf8.h         UTF-8 解码（i18n 字符串→码点）
  generated/     gen_font.py 的产物（勿手改）
    font16_bin.h/.c  171 字形 × 32B = 5,472 B
  port/          后端二选一链接（C-8：文件级替换）
    canvas_host.c    PC：数组画布 + PPM 导出 + 字节环回注入
    canvas_target.c  板级：HyperRAM + OsdControlRegs（C-9 偏移待 RTL）
  test/
    main_sim.c     仿真主程序（T1–T9）
    out/           运行产物（ppm + 网格 dump）
    golden/        基线（首次运行自动生成）
  tools/
    gen_font.py    离线取模（阶段 A）
    build.py       编译(zig cc) + 运行 + golden 比对
    ppm2png.py     预览转换
  assets/         字体（量产必须放 PT Mono OFL）
```

## 快速开始

```bash
# 1) 生成字库（有 PT Mono 就放 assets/PTMono-Regular.ttf，否则回落 Consolas——仅自测）
python tools/gen_font.py --strict

# 2) 编译 + 运行 + golden 比对
python tools/build.py
```

## 已验证内容（test/main_sim.c）

| # | 用例 |
|---|---|
| T1 | CRC16-CCITT 已知向量 → 0x5C06 |
| T2 | 上电渲染 P1 EN：标题居中 / `>` 前缀 / 外框 / miss=0 |
| T3 | 设计文档 §7 示例帧（CRC 0x5C06）→ page/sel/flags 生效 |
| T4 | 未知 page_id → 统一非法口径（状态不变 + status.bit1） |
| T5 | sel 越界 → 同上 |
| T6 | QUERY_VIEW 应答回环（应答字节喂回解析器，解出同字段） |
| T7 | 俄语切换（flags.bit2）→ Cyrillic 全覆盖 |
| T8 | P2 数值页：`[8]` 右对齐 col30–32；纯标签行无数值 |
| T9 | CRC 坏帧丢弃，状态不受影响 |

## 字库注意事项

- 位序：行优先 MSB first，**bit15 = 最左像素**，每行 2 字节大端 —— 与 composer 约定一致
- em=14 在 16 行格内垂直居中；俄文下降部（д/ц/щ/р/у）完整保留
- `→ ← ▲ ▼` 等 Arrows/Geometric 区字形：PT 系列不保证覆盖，UI 文案请用 ASCII 替代
- **当前回落字体是 Consolas（仅可本机自测，禁止随固件分发）**；量产必须用 PT Mono（OFL）

## 待办

- C-9：RTL 提供 OsdControlRegs 偏移 → 填 `port/canvas_target.c` 的 REG_* 宏
- 板级 bsp/（hram_write 32bit 突发对齐、UART 轮询）按目标平台实现
- 交叉验证：软核 RTL 仿真里抓 HyperRAM 写事务，与 golden.ppm 对比
