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

/* 累计被写进来的字节数。放在这里（而不是尾部）是因为下面的 canvas_write /
 * canvas_fill 要用它 —— C 里静态变量必须先声明后使用。*/
static uint32_t s_bytes_written;

void canvas_select_block(int idx) { s_block = (idx == 1) ? 1 : 0; }

void canvas_write(uint32_t off, const uint8_t *src, uint32_t len)
{
    uint32_t i;
    if (src == 0) return;
    s_bytes_written += len;
    for (i = 0u; i < len; i++) {
        uint32_t a = off + i;
        if (a < OSD_BLOCK_BYTES) s_blk[s_block][a] = src[i];
    }
}

void canvas_fill(uint32_t off, uint8_t v, uint32_t len)
{
    uint32_t i;
    s_bytes_written += len;
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

/* ---------------------------------------------------------------------------
 * 诊断专用的裸访问与计数（与板级同构）
 *
 * 主机后端只认识两块位图所在的地址区间，其它地址一律返回 0 —— **不假装成功**：
 * 假装成功会让"探针能往返"这件事在离机上失去意义。
 * ------------------------------------------------------------------------ */
uint32_t canvas_peek(uint32_t addr)
{
    uint32_t i;

    /* 未对齐直接返回 0：下面按 4 字节拆字，i+3 会越出数组。
     * 板级那边同理（未对齐的 MMIO 访问本来就不该有）。*/
    if ((addr & 3u) != 0u) return 0u;

    if (addr >= OSD_BLOCK0_ADDR && addr < OSD_BLOCK0_ADDR + OSD_BLOCK_BYTES) {
        i = addr - OSD_BLOCK0_ADDR;
        return (uint32_t)s_blk[0][i] | ((uint32_t)s_blk[0][i + 1u] << 8)
             | ((uint32_t)s_blk[0][i + 2u] << 16)
             | ((uint32_t)s_blk[0][i + 3u] << 24);
    }
    if (addr >= OSD_BLOCK1_ADDR && addr < OSD_BLOCK1_ADDR + OSD_BLOCK_BYTES) {
        i = addr - OSD_BLOCK1_ADDR;
        return (uint32_t)s_blk[1][i] | ((uint32_t)s_blk[1][i + 1u] << 8)
             | ((uint32_t)s_blk[1][i + 2u] << 16)
             | ((uint32_t)s_blk[1][i + 3u] << 24);
    }
    return 0u;
}

uint32_t canvas_poke(uint32_t addr, uint32_t val)
{
    uint32_t i;
    int      which = -1;

    if ((addr & 3u) != 0u) return 0u;

    if (addr >= OSD_BLOCK0_ADDR && addr < OSD_BLOCK0_ADDR + OSD_BLOCK_BYTES) {
        which = 0;
        i     = addr - OSD_BLOCK0_ADDR;
    } else if (addr >= OSD_BLOCK1_ADDR && addr < OSD_BLOCK1_ADDR + OSD_BLOCK_BYTES) {
        which = 1;
        i     = addr - OSD_BLOCK1_ADDR;
    } else {
        return 0u;
    }

    s_blk[which][i]      = (uint8_t)(val & 0xFFu);
    s_blk[which][i + 1u] = (uint8_t)((val >> 8) & 0xFFu);
    s_blk[which][i + 2u] = (uint8_t)((val >> 16) & 0xFFu);
    s_blk[which][i + 3u] = (uint8_t)((val >> 24) & 0xFFu);
    return canvas_peek(addr);
}

uint32_t canvas_bytes_written(void)
{
    return s_bytes_written;
}

/* ---------------------------------------------------------------------------
 * 回读：主机上没有 MMIO 寄存器，用提交时记下的 s_last_* 与提交次数回填。
 *
 * 为什么主机也要实现：两个后端必须**同构**，否则"回读接口本身写错了"
 * 只能等上板才发现。active 的位域按 RTL 的定义拼：enable 在高半字节、
 * buffer_select 在低半字节（D6）。
 * ------------------------------------------------------------------------ */
void canvas_read_regs(canvas_regs_t *out)
{
    if (out == 0) return;

    out->command   = 0U;                 /* 主机没有 COMMAND 回读 */
    out->status    = s_commit_count;     /* 借用该字表示"提交了几次" */
    out->canvas    = 0U;
    /* 位域按 D6：applied_enable[3:0] 在 bit7:4、applied_buffer_select[3:0]
     * 在 bit3:0。**路号必须跟着 OSD_MENU_ROUTE 走** —— 菜单承载路是 1 路，
     * 写成 0x10/0x01 就变成"0 路使能"，回读出来的位域与板上实际不符。*/
    out->active    = (uint32_t)(((s_last_ctrl & OSD_CTRL_ENABLE)
                                     ? (0x10U << OSD_MENU_ROUTE) : 0U)
                              | ((s_last_ctrl & OSD_CTRL_BUFFER)
                                     ? (0x01U << OSD_MENU_ROUTE) : 0U));
    out->pos_read  = 0U;                 /* 只写寄存器的回读值 */
    out->ctrl_read = 0U;
    out->pos_last  = s_last_pos;
    out->ctrl_last = (uint32_t)s_last_ctrl;
}

uint32_t canvas_read_block(int idx, uint8_t *dst)
{
    const uint8_t *src = s_blk[(idx == 1) ? 1 : 0];
    uint32_t i;

    if (dst == 0) return 0U;
    for (i = 0u; i < (uint32_t)OSD_BLOCK_BYTES; i++) {
        dst[i] = src[i];
    }
    return (uint32_t)OSD_BLOCK_BYTES;
}

void canvas_flush(const char *path)
{
    /* 需要人眼看画布时，把 PGM 写到 semihosting 的主机上没有意义（无文件系统）。
     * 保留空实现，测试改用 canvas_block_data() 做逐字节断言。 */
    (void)path;
}
