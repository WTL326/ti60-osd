/* =============================================================================
 * L3 字库实现
 * 二分查找（码点升序）；对渲染层**永不失败**——调用方负责先做缺字形替换（C-6）
 * =============================================================================
 */
#include "font.h"
#include "osd_config.h"
#include "../generated/font16_bin.h"

uint16_t font_count(void) { return (uint16_t)FONT16_COUNT; }

int font_lookup(uint16_t cp)
{
    int lo = 0, hi = (int)FONT16_COUNT - 1;

    while (lo <= hi) {
        int mid = (lo + hi) >> 1;
        uint16_t v = font16_codepoints[mid];
        if (v == cp) return mid;
        if (v < cp) lo = mid + 1; else hi = mid - 1;
    }
    return -1;
}

const uint8_t *font_glyph(int idx)
{
    if (idx < 0 || idx >= (int)FONT16_COUNT) return font16_bitmap[0];
    return font16_bitmap[idx];
}

uint16_t font_row_bits(const uint8_t *g, unsigned row)
{
    if (row >= OSD_GLYPH_H) row = OSD_GLYPH_H - 1u;   /* 越界保护：永远给合法数据 */
    return (uint16_t)(((uint16_t)g[row * 2u] << 8) | g[row * 2u + 1u]);
}
