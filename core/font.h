/* =============================================================================
 * L3 字库 —— 查码点，取行位。
 * 数据源：generated/font16_bin.{h,c}（由 tools/gen_font.py 离线取模生成）
 * 约定：16×16 格，em=14 居中，1bpp，行优先，**每行 2 字节大端**，bit15=最左像素
 * =============================================================================
 */
#ifndef OSD_FONT_H
#define OSD_FONT_H

#include <stdint.h>
#include "osd_config.h"

uint16_t        font_count(void);
int             font_lookup(uint16_t cp);                  /* 索引，-1 = 无此字形 */
const uint8_t  *font_glyph(int idx);                       /* 32 字节点阵         */
uint16_t        font_row_bits(const uint8_t *g, unsigned row); /* 该行 16 bit      */

#endif /* OSD_FONT_H */
