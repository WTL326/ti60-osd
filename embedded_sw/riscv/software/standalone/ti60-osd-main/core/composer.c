/* =============================================================================
 * L4 光栅化实现
 *
 * 三级坐标变换（与架构文档 §L5.1 一致）：
 *   ① 字符格  (r, c)                      → osd_buf[r][c]（一个 Unicode 码点）
 *   ② 画布像素 x = FRAME_X0 + c*16 + gx
 *              y = FRAME_Y0 + r*16 + gy
 *   ③ 线性地址 off = y * 720 + x          （1 B/px）
 *
 * 行缓冲 544 B（= 34 列 × 16 px），逐扫行写；不清空多余列（画布右侧 176 列
 * 在上电 canvas_clear 后恒为 0x00=透明，永不需要写）。
 * =============================================================================
 */
#include "composer.h"
#include "canvas.h"
#include "font.h"
#include "ui.h"
#include "osd_config.h"
#include <string.h>

void composer_render(void)
{
    uint8_t line[OSD_FRAME_W];
    unsigned r, c, gy, gx;

    for (r = 0u; r < OSD_GRID_ROWS; r++) {
        const cell_t *row_cells = osd_buf[r];

        for (gy = 0u; gy < OSD_GLYPH_H; gy++) {
            unsigned y = r * OSD_GLYPH_H + gy;

            for (c = 0u; c < OSD_GRID_COLS; c++) {
                int idx = font_lookup(row_cells[c]);
                if (idx < 0) idx = font_lookup((uint16_t)'?');   /* 理论不可达：scene_build 已归一 */
                if (idx < 0) {
                    memset(line + c * OSD_GLYPH_W, OSD_PIXEL_KEY, OSD_GLYPH_W);
                    continue;
                }

                uint16_t bits = font_row_bits(font_glyph(idx), gy);
                uint8_t *p = line + c * OSD_GLYPH_W;

                for (gx = 0u; gx < OSD_GLYPH_W; gx++) {
                    /* bit15 = 最左像素 */
                    p[gx] = (bits & (uint16_t)(1u << (OSD_GLYPH_W - 1u - gx)))
                                ? OSD_PIXEL_FG : OSD_PIXEL_KEY;
                }
            }

            canvas_write((uint32_t)(y * OSD_CANVAS_W + OSD_FRAME_X0), line,
                         (uint32_t)OSD_FRAME_W);
        }
    }
}
