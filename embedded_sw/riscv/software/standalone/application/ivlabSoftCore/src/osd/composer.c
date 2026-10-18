/* =============================================================================
 * L4 光栅化实现 —— 字符网格 → 1 bit/像素位图（唯一的写画布者）
 *
 * 语义锁定（沿用上游 C-4/决策树 R1）：**每次全量重画整个菜单区**，不做增量 patch。
 *   原因：透明底（无底色铺就要 diff 补 0）+ 位图乒乓 → 增量会露出上一块的旧内容。
 * 无 multiplicative 分支：字库查不到由 scene_build 提前换成 '?'，此处不存在失败路径。
 *
 * 坐标变换（画布即窗口，故只有一次线性映射）：
 *   字符格 (r, c)  →  位图行 y = r*16 + gy，列起始 = c*8 像素 = c*1 字节
 *   字节偏移       =  y * 34 + c
 *
 * 为什么这里**没有逐像素循环**（这是相对上游最实质的一处改动，D11 第 2 项）：
 *   上游是 8 bit/像素，字形的一位要展开成一个字节，所以必须 16 次循环。
 *   现在位图本身就是 1 bit/像素、且"bit 7 最左"，而字库每行恰好是 8 位、
 *   同样"bit 7 最左" —— 两者**位序天然一致**，于是**一个字符格就是一个字节**，
 *   直接存进去即可，无需任何移位或循环。
 *   34 列 × 1 字节 = 34 字节，正好等于行跨距。
 * =============================================================================
 */
#include "composer.h"
#include "canvas.h"
#include "font.h"
#include "ui.h"
#include "osd_config.h"

void composer_render(void)
{
    /* 一行位图 = 34 字节（272/8）。放在栈上：这与画布大小无关，永远只是两行的量级，
     * 不会因为将来改画布尺寸而变成一个大数组。*/
    uint8_t  line[OSD_ROW_STRIDE];
    unsigned r, c, gy;

    for (r = 0u; r < OSD_GRID_ROWS; r++) {
        const cell_t *row_cells = osd_buf[r];

        for (gy = 0u; gy < OSD_GLYPH_H; gy++) {
            unsigned y = r * OSD_GLYPH_H + gy;

            for (c = 0u; c < OSD_GRID_COLS; c++) {
                int idx = font_lookup(row_cells[c]);
                uint8_t bits;

                /* 理论不可达：scene_build 已把缺字形归一为 '?'。
                 * 真到了这里也不能返回空行——那会静默丢一个字，不如画 '?'。*/
                if (idx < 0) idx = font_lookup((uint16_t)'?');
                if (idx < 0) {
                    line[c] = OSD_PIXEL_KEY;
                    continue;
                }

                bits = font_row_bits(font_glyph(idx), gy);

                /* 一个字符格 = 一个字节：字形行的 bit7 最左与位图的 bit7 最左
                 * 是同一条约定，直接落盘即可。*/
                line[c] = bits;
            }

            canvas_write((uint32_t)y * (uint32_t)OSD_ROW_STRIDE, line,
                         (uint32_t)OSD_ROW_STRIDE);
        }
    }
}
