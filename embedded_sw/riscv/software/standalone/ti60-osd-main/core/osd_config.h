/* =============================================================================
 * TI60 软核 OSD — MCU 侧全局配置
 * 本文件是**软硬契约的唯一落点**：改这里是改合同，不是改实现。
 * 全部常量来自《TI60_OSD_MCU接口契约细化_v0.1.md》已决条款。
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
#define OSD_GLYPH_W           16     /* 字符格宽 = 列间距                     */
#define OSD_GLYPH_H           16     /* 字符格高 = 行间距                     */
#define OSD_GLYPH_BYTES       32     /* 16×16×1bpp，行优先，每行 2 字节       */
#define OSD_EM_HEIGHT         14     /* em=14：在 16 行格内上下各留 1 px      */

/* ---------------- 画布（L5 / 与 RTL 的契约） ---------------- */
#define OSD_CANVAS_W         720
#define OSD_CANVAS_H         208     /* = 13 行 × 16 px                       */
#define OSD_FRAME_X0           0     /* 菜单框在画布内的左上角（框高=画布高）  */
#define OSD_FRAME_Y0           0
#define OSD_FRAME_W     (OSD_GRID_COLS * OSD_GLYPH_W)   /* 544              */
#define OSD_FRAME_H     (OSD_GRID_ROWS * OSD_GLYPH_H)   /* 208              */
#define OSD_BLOCK_BYTES (OSD_CANVAS_W  * OSD_CANVAS_H)   /* 149,760         */

#define OSD_BLOCK0_ADDR  0x00F00000u
#define OSD_BLOCK1_ADDR  0x00F24900u   /* 0x00F00000 + 149760 = 0x00F24900   */

/* 像素语义：0x00 = 透明（透视频）；非零 = 叠加白 {Y=235, C=128}（RTL 侧常量） */
#define OSD_PIXEL_KEY    0x00u
#define OSD_PIXEL_FG     0xFFu

/* ---------------- 帧协议（L1，沿用既有） ---------------- */
#define PROTO_SOF         0xBBu
#define PROTO_EOF         0xAAu
#define PROTO_CAT_UI      0x04u
#define PROTO_SUB_SET_VIEW        0x06u
#define PROTO_SUB_SET_IMG_VALUES  0x07u
#define PROTO_SUB_QUERY_VIEW      0x08u
#define PROTO_QUERY_RESP_LEN      14u
#define PROTO_BODY_MAX    32u      /* cat+sub+type+payload                   */
#define PROTO_FRAME_MAX   (PROTO_BODY_MAX + 6u)
#define PROTO_QUEUE_DEPTH 4u

/* SET_VIEW.flags 位定义（C-1 已决） */
#define UI_FLAG_SELECTED  0x01u    /* bit0 选中 '*'                          */
#define UI_FLAG_EDIT      0x02u    /* bit1 编辑态闪烁                        */
#define UI_FLAG_LANG_RU   0x04u    /* bit2 语言 0=EN 1=RU                    */
#define UI_FLAG_MASK      0x07u

/* QUERY_VIEW.status 位定义（C-2 已决） */
#define UI_STATUS_BUSY       0x01u
#define UI_STATUS_BAD_PARAM  0x02u
#define UI_STATUS_FW_VERSION   1u

#endif /* OSD_CONFIG_H */
