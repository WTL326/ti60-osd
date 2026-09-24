/* =============================================================================
 * PC 后端（sim 目标）—— port/canvas_host.c
 * 与 port/canvas_target.c 二选一链接（C-8 已决：文件级替换）
 * 画布只是一块 static 数组；commit 在 PC 下无对应硬件动作。
 * =============================================================================
 */
#include "canvas.h"
#include "platform.h"
#include "osd_config.h"
#include <stdio.h>

static uint8_t s_fb[OSD_BLOCK_BYTES];   /* 单例：乒乓在 PC 下不可观测也无需观测 */
static int     s_block = 0;

/* ---------------- 环回缓冲（供测试驱动） ---------------- */
static uint8_t  s_rx[1024];
static uint32_t s_rx_len, s_rx_rd;

uint8_t  g_plat_tx[256];
uint32_t g_plat_tx_len;

void platform_tx_reset(void) { g_plat_tx_len = 0u; }

void platform_rx_inject(const uint8_t *buf, uint32_t len)
{
    uint32_t i;
    for (i = 0u; i < len && (s_rx_len + i) < sizeof(s_rx); i++)
        s_rx[s_rx_len + i] = buf[i];
    s_rx_len += i;
}

int platform_poll_byte(void)
{
    if (s_rx_rd >= s_rx_len) return -1;
    return (int)s_rx[s_rx_rd++];
}

void platform_send(const uint8_t *buf, uint32_t len)
{
    uint32_t i;
    for (i = 0u; i < len && g_plat_tx_len < sizeof(g_plat_tx); i++)
        g_plat_tx[g_plat_tx_len++] = buf[i];
}

void platform_debug(const char *s)
{
    fputs(s, stdout);
}

/* ---------------- 画布 ---------------- */

void canvas_select_block(int idx) { s_block = idx; }

void canvas_write(uint32_t off, const uint8_t *src, uint32_t len)
{
    uint32_t i;
    for (i = 0u; i < len; i++) {
        uint32_t a = off + i;
        if (a < OSD_BLOCK_BYTES) s_fb[a] = src[i];
    }
}

void canvas_fill(uint32_t off, uint8_t v, uint32_t len)
{
    uint32_t i;
    for (i = 0u; i < len; i++) {
        uint32_t a = off + i;
        if (a < OSD_BLOCK_BYTES) s_fb[a] = v;
    }
}

void canvas_commit(void) { /* PC 无 RTL；语义上停在"已置位"，不需要 ack */ }

void canvas_flush(const char *path)
{
    FILE *f = fopen(path, "wb");
    if (f == 0) return;
    fprintf(f, "P5\n%d %d\n255\n", OSD_CANVAS_W, OSD_CANVAS_H);
    fwrite(s_fb, 1u, OSD_BLOCK_BYTES, f);
    fclose(f);
}
