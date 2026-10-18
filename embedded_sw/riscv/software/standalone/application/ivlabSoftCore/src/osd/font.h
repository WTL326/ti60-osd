/* =============================================================================
 * L3 字库 —— 查码点，取行位。
 * 数据源：src/osd/font8x16_bin.{h,c}（由 tools/gen_font.py 离线取模生成，**别手改**）
 * 约定：8×16 格，em=14 垂直居中，1bpp，行优先，**每行 1 字节**，bit7=最左像素
 * 换字符格尺寸＝重新生成字库 + 改 include 与本文件的类型（见 tools/gen_font.py）
 * =============================================================================
 */
#ifndef OSD_FONT_H
#define OSD_FONT_H

#include <stdint.h>
#include "osd_config.h"

uint16_t        font_count(void);
int             font_lookup(uint16_t cp);                  /* 索引，-1 = 无此字形 */
const uint8_t  *font_glyph(int idx);                       /* 16 字节点阵         */
uint8_t         font_row_bits(const uint8_t *g, unsigned row); /* 该行 8 bit       */

#endif /* OSD_FONT_H */
