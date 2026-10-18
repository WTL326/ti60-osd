/* =============================================================================
 * ivlabSoftCore OSD — 软核侧全局配置
 *
 * 本文件是**软硬契约的唯一落点**：改这里是改合同，不是改实现。
 * 内容来自变更 add-quad-osd-overlay 的 design.md D1/D3/D6/D11 与
 * docs/osd_bitmap_contract.md。改动前请先核对那两份。
 *
 * 与上游 ti60-osd-main 的差异（D11 的 8 项清单，逐项标在下面）：
 *   1. 画布由 720 宽收窄到 272（= 34 列 × 8 px）
 *   2. 像素格式由 8 bit/像素改为 1 bit/像素，行跨距 34 字节
 *   3. 块基址改到 OSD1（菜单承载路）的 0x00A4_0000 / 0x00B4_0000
 *   4. 寄存器映射改为 MaskControlRegs 的 12 字表；删除 BASE_LO/HI
 *   5. 画布切换收敛为 OSD[1].CTRL.buffer_select
 *   6. QUERY_VIEW 应答体改为 12 字节（本文件的 UI_QUERY_PAYLOAD_LEN = 8）
 *   7. UI_FLAG_SELECTED 改名为 UI_FLAG_VISIBLE，语义由"选中"改为"UI 显示"
 *   8. 删除语言位（UI_FLAG_LANG_RU / bit2），UI_FLAG_MASK 由 0x07 改为 0x03
 * =============================================================================
 */
#ifndef OSD_CONFIG_H
#define OSD_CONFIG_H

#include <stdint.h>

/* ---------------- 字符网格（L2/L4 之间数据契约） ---------------- */
#define OSD_GRID_ROWS        13      /* 13 行：边框/标题/分隔/9 项/边框       */
#define OSD_GRID_COLS        34      /* 34 列：1 边框 + 32 内容 + 1 边框      */

#define OSD_ROW_BORDER_TOP     0
#define OSD_ROW_TITLE          1
#define OSD_ROW_SEPARATOR      2
#define OSD_ROW_ITEM0          3     /* sel=0 落在这一行                      */
#define OSD_ROW_BORDER_BOTTOM 12
#define OSD_MAX_ITEMS          9     /* 行 3..11 共 9 行给菜单项              */

#define OSD_COL_BORDER_L       0
#define OSD_COL_PREFIX         1     /* 前缀占 2 列："> " / "* " / "  "       */
#define OSD_COL_LABEL          3     /* 标签起点                              */
#define OSD_COL_LABEL_END     28     /* 有数值时标签到此截断（给数值留列）     */
#define OSD_COL_VALUE_LAST    32     /* 数值最后一个字符落在这一列（右对齐）   */
#define OSD_COL_BORDER_R      33

/* ---------------- 字形（L3） ---------------- */
/* 字符格 8×16：**宽减半、高不变**。为什么不是 8×8（现场要"小字"时的第一反应）：
 * 等宽字体的宽高比约 0.6，格高只有 8 px 时字号被迫压到 4~6 px —— 笔画细到 3 px、
 * 标点（, . : ; | '）直接渲染成空，而字符间空白反而比 8×16 更大。
 * 实测三档见 tools/gen_font.py 的 [ink] 输出与 docs/osd_bitmap_contract.md。*/
#define OSD_GLYPH_W           8      /* 字符格宽 = 列间距（位图一列 = 1 字节）*/
#define OSD_GLYPH_H           16     /* 字符格高 = 行间距                     */
#define OSD_GLYPH_BYTES       16     /* 8×16×1bpp，行优先，每行 1 字节        */
#define OSD_EM_HEIGHT         14     /* em=14：在 16 行格内上下各留 1 px      */

/* ---------------- 画布（L5 / 与 RTL 的契约） ----------------
 *
 * 菜单承载路 = OSD1，位图尺寸 272×208（见 design.md D3 表第 2 行）。
 * 尺寸是**软硬契约**：RTL 侧 src/top.v 的 OSD1_WIDTH/HEIGHT 必须与此一致。
 * 这一路的位图**就是画布本身**：画布左上角与窗口左上角重合，所以
 * FRAME_X0/FRAME_Y0 恒为 0，行跨距 = 272/8 = 34 字节。
 *
 * 位图格式（D1）：1 bit/像素、行内紧凑打包、**bit 7 对应最左像素**、
 * 位 = 1 → RTL 输出纯白 16'h80EB、位 = 0 → 视频透传。 */
#define OSD_CANVAS_W         272     /* = 34 列 × 8 px                        */
#define OSD_CANVAS_H         208     /* = 13 行 × 16 px                       */
#define OSD_FRAME_X0           0
#define OSD_FRAME_Y0           0
#define OSD_FRAME_W     (OSD_GRID_COLS * OSD_GLYPH_W)   /* 272              */
#define OSD_FRAME_H     (OSD_GRID_ROWS * OSD_GLYPH_H)   /* 208              */

/* 行跨距（字节）= 画布宽 ÷ 8。逐行写画布时按它步进。 */
#define OSD_ROW_STRIDE  (OSD_CANVAS_W / 8)              /* 34               */

/* 一个块（一块位图缓冲）的字节数：272×208/8 = 7,072。
 * 注意这是**位图字节数**，不是像素数 —— 1 bpp 下差 8 倍，改错会直接越界。 */
#define OSD_BLOCK_BYTES ((OSD_CANVAS_W * OSD_CANVAS_H) / 8)   /* 7,072      */

/* 8 个固定基址中属于菜单承载路的那一对（design.md D3 表第 2 行）。
 * 基址是**综合期参数**，软核只能按约定使用，无法回读。 */
#define OSD_BLOCK0_ADDR  0x00A40000u   /* OSD1 Buffer A */
#define OSD_BLOCK1_ADDR  0x00B40000u   /* OSD1 Buffer B */

/* 位 = 1 时 RTL 输出的颜色（仅作说明，软核不写像素值）。 */
#define OSD_PIXEL_KEY    0x00u
#define OSD_PIXEL_FG     0x01u

/* ---------------- 控制寄存器（MaskControlRegs，0xE1043000） ----------------
 *
 * 12 字映射见 design.md D6（二）。这里只列出软核用到的部分。
 * 注意：**没有尺寸寄存器、也没有基址寄存器** —— 尺寸与基址是综合期参数。 */
#define OSD_REG_BASE      0xE1043000u
#define OSD_REG_COMMAND   0x00u   /* W  bit31 提交，bit0 全局使能             */
#define OSD_REG_STATUS    0x04u   /* R  {commit_count, .., pending, .., g_en} */
#define OSD_REG_CANVAS    0x08u   /* R  画面尺寸，与窗口无关                  */
#define OSD_REG_ACTIVE    0x0Cu   /* R  {.., enable[3:0], buffer[3:0]}        */
#define OSD_REG_POS(i)    (0x10u + 8u * (uint32_t)(i))       /* W 有符号 */
#define OSD_REG_CTRL(i)   (0x10u + 8u * (uint32_t)(i) + 4u)  /* W        */

#define OSD_CMD_COMMIT    0x80000000u   /* COMMAND.bit31：提交暂存区        */
#define OSD_CMD_GLOBAL_EN 0x00000001u   /* COMMAND.bit0：全局使能           */
#define OSD_CTRL_ENABLE   0x00000001u   /* CTRL.bit0：该路使能              */
#define OSD_CTRL_BUFFER   0x00000002u   /* CTRL.bit1：A/B 选择              */

#define OSD_STATUS_PENDING 0x00000004u  /* STATUS.bit2：有待生效配置        */

/* 菜单承载路的路号（D3 表第 2 行 = OSD1）。
 * 这是"UI 显示"落到硬件上的那一路：flags.bit0 就是它的 CTRL.enable。 */
#define OSD_MENU_ROUTE    1u
/* 菜单窗口的位置（画面 720×576 内的左上角）。
 * **它是运行期的，不是综合期参数**：canvas_commit 把这两个值写进 OSD[1].POS，
 * 改这里只需重编固件，**不必重出位流**（重出位流的是画布尺寸 OSD_CANVAS_W/H）。
 * 两个值都刻意不居中（居中分别是 224 / 184），按现场观感定的：
 * 横向贴左留 32 px，纵向下移 128 px，给上方的画面内容让位。
 * 越界由 RTL 侧的负偏移裁剪兜底（见 docs/architecture.md 的窗口位置一节）。*/
#define OSD_MENU_LEFT     32u    /* (720-272)/2 = 224 是居中值，这里取小      */
#define OSD_MENU_TOP     128u    /* (576-208)/2 = 184 是居中值；128+208=336 ≤ 576 */

/* ---------------- 帧协议 ----------------
 *
 * 帧头/帧尾、大类号、子项号**都不在这里定义** —— 它们的归属是协议层
 * （src/frame.h 的 FRAME_HEADER / FRAME_CATEGORY_* / FRAME_CMD_UI_*）。
 * 本文件只放"UI 状态怎么落到画布与寄存器上"这一侧的东西。
 * 曾经在这里重复定义过一份 PROTO_SOF/PROTO_CAT_UI/PROTO_SUB_*，那是两个
 * 真相源，改一处漏一处只是时间问题，已删除。
 *
 * 唯一保留的协议相关常量是下面这个应答体长度：它同时是"协议约定的长度"与
 * "本层输出缓冲的大小"，放在这里可以让 ui.c 不依赖 protocol.h。*/

/* QUERY_VIEW 应答体里、跟在状态字节之后的部分：page_id(2) + sel(1) + flags(1)
 * + 四个数值 = 8 字节。加上 4 字节的公共头（大类|子项|02|状态）得 12 字节 body，
 * 整帧 18 字节 —— 与 tools/send_ui_via_adb.py 的 `18 if sub == 8 else 10` 一致。 */
#define UI_QUERY_PAYLOAD_LEN  8u

/* SET_VIEW.flags 位定义（D11（二））。
 *
 * bit2–bit7 是**保留位**：软核按 UI_FLAG_MASK 取值后静默丢弃，不报错、不影响
 * 其余字段，回读时也为 0。这比"保留位必须为 0、否则失败"宽容，是刻意的 ——
 * 让上位机将来可以先行占用高位而不必与软核同步发版。 */
#define UI_FLAG_VISIBLE   0x01u   /* bit0 UI 显示（原 UI_FLAG_SELECTED，语义已改） */
#define UI_FLAG_EDIT      0x02u   /* bit1 数值编辑态                              */
#define UI_FLAG_MASK      0x03u

/* UI 内部状态位。
 *
 * 注意：它**不进协议应答**。协议的状态字段是二值的（0xFF/0x00），失败的具体
 * 原因从调试通道输出 —— 这是 docs/测试说明.md 的明文规定，见 D11（一）。
 * 之所以还留一个状态字，是为了让"因为参数非法而拒绝"这件事在固件内部可查
 * （测试直接看它），而不是靠日志猜。
 *
 * 上游还有 UI_STATUS_BUSY 与 UI_STATUS_FW_VERSION 两位，本变更都删掉了：
 * 前者表达的是"画布还没提交完"，而提交是同步完成的（commit 置位即返回）；
 * 后者是固件版本号，协议文档与上位机工具都不认这个字段（D11 第 6 项）。*/
#define UI_STATUS_BAD_PARAM 0x02u

/* SET_IMAGE_VALUES 四个数值的合法范围（docs/x2000_ui_protocol.md §3.2）。
 * 四项一次提交，任意一项越界则**整条命令失败、四个值全部不变**。 */
#define UI_V_ENHANCE_MAX  5u      /* image_enhance：0..5                          */
#define UI_V_OTHER_MAX    10u     /* contrast / image_brightness / screen_brightness */

#endif /* OSD_CONFIG_H */
