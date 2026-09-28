/* =============================================================================
 * L5 画布后端 —— 主机（qemu 测试）
 *
 * 与 src/canvas_hw.c 二选一链接。画布只是两块静态数组，commit 在主机上无对应
 * 硬件动作，但要**记录被提交过的配置**，否则测试无法断言
 * "flags.bit0 确实落到了菜单承载路的使能位、且与缓冲选择同组提交"（任务 6.6）。
 *
 * 为什么保留两块（而不是像上游 canvas_host.c 那样只留一块）：D3 的双缓冲是
 * 本变更的契约之一，测试要能验证"写 B 块时 A 块逐字节不变"。只留一块就把这条
 * 性质测没了。
 * =============================================================================
 */
#include "canvas.h"
#include "osd_config.h"

static uint8_t s_blk[2][OSD_BLOCK_BYTES];
static int     s_block = 0;

uint8_t  s_last_ctrl;     /* 最近一次提交时写给 OSD[1].CTRL 的值 */
uint32_t s_last_pos;      /* 最近一次提交时写给 OSD[1].POS 的值 */
uint32_t s_commit_count;  /* 提交次数，用于断言"渲染了多少次就提交了多少次" */

void canvas_select_block(int idx) { s_block = (idx == 1) ? 1 : 0; }

void canvas_write(uint32_t off, const uint8_t *src, uint32_t len)
{
    uint32_t i;
    if (src == 0) return;
    for (i = 0u; i < len; i++) {
        uint32_t a = off + i;
        if (a < OSD_BLOCK_BYTES) s_blk[s_block][a] = src[i];
    }
}

void canvas_fill(uint32_t off, uint8_t v, uint32_t len)
{
    uint32_t i;
    for (i = 0u; i < len; i++) {
        uint32_t a = off + i;
        if (a < OSD_BLOCK_BYTES) s_blk[s_block][a] = v;
    }
}

void canvas_set_visible(int on)
{
    if (on) s_last_ctrl |= OSD_CTRL_ENABLE;
    else    s_last_ctrl &= (uint8_t)~OSD_CTRL_ENABLE;
}

void canvas_commit(void)
{
    /* 与板级后端**同构**：位置、使能、缓冲选择三者一起算出来写下去。
     * 这样"UI 显示与画布乒乓是不是同组提交"在主机上也能被断言（任务 6.6），
     * 而不必等到上板看画面闪不闪。 */
    s_last_pos  = (((uint32_t)OSD_MENU_TOP & 0xFFFu) << 12)
                |  ((uint32_t)OSD_MENU_LEFT & 0xFFFu);
    s_last_ctrl = (uint8_t)((s_last_ctrl & OSD_CTRL_ENABLE) |
                            (s_block ? OSD_CTRL_BUFFER : 0u));
    s_commit_count++;
}

const uint8_t *canvas_block_data(int idx) { return s_blk[(idx == 1) ? 1 : 0]; }

void canvas_flush(const char *path)
{
    /* 需要人眼看画布时，把 PGM 写到 semihosting 的主机上没有意义（无文件系统）。
     * 保留空实现，测试改用 canvas_block_data() 做逐字节断言。 */
    (void)path;
}
