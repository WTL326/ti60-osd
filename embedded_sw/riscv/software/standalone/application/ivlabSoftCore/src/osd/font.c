/* =============================================================================
 * L3 字库实现
 * 二分查找（码点升序）；对渲染层**永不失败**——调用方负责先做缺字形替换（C-6）
 * =============================================================================
 */
#include "font.h"
#include "osd_config.h"
#include "font8x16_bin.h"

uint16_t font_count(void) { return (uint16_t)FONT8X16_COUNT; }

int font_lookup(uint16_t cp)
{
    int lo = 0, hi = (int)FONT8X16_COUNT - 1;

    while (lo <= hi) {
        int mid = (lo + hi) >> 1;
        uint16_t v = font8x16_codepoints[mid];
        if (v == cp) return mid;
        if (v < cp) lo = mid + 1; else hi = mid - 1;
    }
    return -1;
}

const uint8_t *font_glyph(int idx)
{
    if (idx < 0 || idx >= (int)FONT8X16_COUNT) return font8x16_bitmap[0];
    return font8x16_bitmap[idx];
}

uint8_t font_row_bits(const uint8_t *g, unsigned row)
{
    if (row >= OSD_GLYPH_H) row = OSD_GLYPH_H - 1u;   /* 越界保护：永远给合法数据 */
    /* 一行就是一个字节：字符格宽 8 px、1 bpp，且**行内 bit7 = 最左像素** ——
     * 与位图的位序约定完全相同，所以取出来直接可用，不做任何移位。
     * （16×16 时代是每行 2 字节大端，要移位拼接；格宽改 8 之后这一段就没了。）*/
    return g[row];
}
