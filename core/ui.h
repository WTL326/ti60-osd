/* =============================================================================
 * L2 UI 状态机 —— 只改状态与字符网格，**绝不写画布**（规则 2）
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

/* 命令入口：返回 0 = 接受；<0 = 拒绝（已置 status.bit1，状态不变） */
int  ui_set_view(uint16_t page_id, uint8_t sel, uint8_t flags);
int  ui_set_image_values(const uint8_t v[4]);

/* QUERY_VIEW 应答（14 B，方案 A 已决） */
void ui_query_view(uint8_t resp[PROTO_QUERY_RESP_LEN]);

int  ui_is_dirty(void);
void ui_clear_dirty(void);
void ui_clear_status(void);   /* 清 status.bit1（测试/自检用） */

/* 状态 → 字符网格。缺字形在此就地归一为 '?' 并计数（C-6 已决） */
void scene_build(void);

/* 测试辅助：把网格 dump 成 UTF-8 文本（每行以 '\0' 结尾需调用方处理） */
void osd_grid_dump(char *out, unsigned out_size);

#endif /* OSD_UI_H */
