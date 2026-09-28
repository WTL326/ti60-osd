/* =============================================================================
 * L2 UI 状态机 —— 只改状态与字符网格，**绝不写画布**
 *
 * 与上游 ti60-osd-main 的差异（D11 清单第 6/7/8 项）：
 *   6. ui_query_view 只填 8 字节（page_id/sel/flags/四个数值），12 字节 body
 *      由协议层前置 `04 08 02 FF` 后拼成；不再有 item_count 与 fw_version 位。
 *   7. UI_FLAG_SELECTED 改名 UI_FLAG_VISIBLE，语义由"选中"改为"UI 显示"；
 *      选中行的前缀标记改由 selected_item 与 UI_FLAG_EDIT 决定。
 *   8. 删除语言位：文案固定取英文（scene_table 里的俄语列保留，但不再被选中）。
 * =============================================================================
 */
#ifndef OSD_UI_H
#define OSD_UI_H

#include <stdint.h>
#include "osd_config.h"

typedef uint16_t cell_t;

extern cell_t  osd_buf[OSD_GRID_ROWS][OSD_GRID_COLS];
extern unsigned g_font_miss_count;      /* 每次 scene_build 前由调用方决定是否清零 */

void ui_init(void);

/* 命令入口：返回 0 = 接受；<0 = 拒绝（已置 status.bit1，状态不变）。
 *
 * page_id/sel/flags 的校验口径见 ui.c 的 ui_set_view()：页面必须存在于场景表、
 * selected_item 必须落在该页范围内、bit1（编辑态）只允许用在有数值的行上。 */
int  ui_set_view(uint16_t page_id, uint8_t sel, uint8_t flags);
int  ui_set_image_values(const uint8_t v[4]);

/* QUERY_VIEW 的参数段（8 字节，不含前面的 `04 08 02 FF`）：
 *   page_id:u16BE | sel:u8 | flags:u8 | v0 v1 v2 v3
 * 返回值为接受（0）还是拒绝（<0）—— 本函数本身不会失败，返回 0。 */
int  ui_query_view(uint8_t resp[UI_QUERY_PAYLOAD_LEN]);

/* UI 是否应当显示（= flags.bit0）。它落到硬件上是菜单承载路的 CTRL.enable，
 * 由画布提交那一组配置一并写入（D11（六））。注意本模块**不做隐藏动作** ——
 * 隐藏是"关掉那一路 OSD 窗口"，不是"把画布擦干净"：擦画布会闪一帧黑。 */
int  ui_is_visible(void);

int  ui_is_dirty(void);
void ui_clear_dirty(void);
void ui_clear_status(void);   /* 清 status.bit1（测试/自检用） */

/* 状态 → 字符网格。缺字形在此就地归一为 '?' 并计数 */
void scene_build(void);

/* 测试辅助：把网格 dump 成 UTF-8 文本（每行以 '\n' 结尾，末尾补 '\0'） */
void osd_grid_dump(char *out, unsigned out_size);

#endif /* OSD_UI_H */
