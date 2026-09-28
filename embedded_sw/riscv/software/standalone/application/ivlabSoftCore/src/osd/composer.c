/* =============================================================================
 * L4 光栅化实现 —— 字符网格 → 1 bit/像素位图（唯一的写画布者）
 *
 * 语义锁定（沿用上游 C-4/决策树 R1）：**每次全量重画整个菜单区**，不做增量 patch。
 *   原因：透明底（无底色铺就要 diff 补 0）+ 位图乒乓 → 增量会露出上一块的旧内容。
 * 无 multiplicative 分支：字库查不到由 scene_build 提前换成 '?'，此处不存在失败路径。
 *
 * 坐标变换（画布即窗口，故只有一次线性映射）：
 *   字符格 (r, c)  →  位图行 y = r*16 + gy，列起始 = c*16 像素 = c*2 字节
 *   字节偏移       =  y * 68 + c*2
 *
 * 为什么这里**没有逐像素循环**（这是相对上游最实质的一处改动，D11 第 2 项）：
 *   上游是 8 bit/像素，字形的一位要展开成一个字节，所以必须 16 次循环。
 *   现在位图本身就是 1 bit/像素、且"bit 7 最左"，而 font_row_bits() 给的
 *   16 位字形行恰好是"bit 15 最左" —— 两者**位序天然一致**，于是整行字形
 *   直接就是两个字节，按 (高字节, 低字节) 存进去即可，无需任何移位或循环。
 *   34 列 × 2 字节 = 68 字节，正好等于行跨距。
 * =============================================================================
 */
#include "composer.h"
#include "canvas.h"
#include "font.h"
#include "ui.h"
#include "osd_config.h"

void composer_render(void)
{
    /* 一行位图 = 68 字节。放在栈上：这与画布大小无关，永远只是两行的量级，
     * 不会因为将来改画布尺寸而变成一个大数组。*/
    uint8_t  line[OSD_ROW_STRIDE];
    unsigned r, c, gy;

    for (r = 0u; r < OSD_GRID_ROWS; r++) {
        const cell_t *row_cells = osd_buf[r];

        for (gy = 0u; gy < OSD_GLYPH_H; gy++) {
            unsigned y = r * OSD_GLYPH_H + gy;

            for (c = 0u; c < OSD_GRID_COLS; c++) {
                int idx = font_lookup(row_cells[c]);
                uint16_t bits;

                /* 理论不可达：scene_build 已把缺字形归一为 '?'。
                 * 真到了这里也不能返回空行——那会静默丢一个字，不如画 '?'。*/
                if (idx < 0) idx = font_lookup((uint16_t)'?');
                if (idx < 0) {
                    line[c * 2u]      = OSD_PIXEL_KEY;
                    line[c * 2u + 1u] = OSD_PIXEL_KEY;
                    continue;
                }

                bits = font_row_bits(font_glyph(idx), gy);

                /* 高字节在前：bit 15..8 先落盘，于是"bit 7 最左"这条位图约定
                 * 与"bit 15 最左"的字形约定自动对齐。*/
                line[c * 2u]      = (uint8_t)(bits >> 8);
                line[c * 2u + 1u] = (uint8_t)(bits & 0xFFu);
            }

            canvas_write((uint32_t)y * (uint32_t)OSD_ROW_STRIDE, line,
                         (uint32_t)OSD_ROW_STRIDE);
        }
    }
}
