/* =============================================================================
 * 板级后端（fw 目标）—— port/canvas_target.c
 * 与 port/canvas_host.c 二选一链接（C-8 已决：文件级替换）
 *
 * 依赖 L0 bsp（hram_* / osd_reg_* / uart_*），其偏移常量来自 RTL 的
 * OsdControlRegs 定义【C-9 待 RTL 提供，见 TODO 标记】。
 * =============================================================================
 */
#include "canvas.h"
#include "platform.h"
#include "osd_config.h"

/* ---- L0 BSP 原型（实现在 bsp/，fw 目标链接） ---- */
extern void     hram_write(uint32_t byte_off, const uint8_t *src, uint32_t len);
extern void     hram_fill (uint32_t byte_off, uint8_t v, uint32_t len);
extern void     osd_reg_write(uint32_t off, uint32_t val);
extern int      uart_poll_byte(void);
extern void     uart_send(const uint8_t *b, uint32_t len);

/* TODO(C-9): 等 RTL 提供 OsdControlRegs 偏移后替换，纯常量、不影响上层 */
#define REG_OSD_COMMIT   0x00u   /* 占位：写 1 触发，硬件在 SOF 生效并回 ack */
#define REG_OSD_BASE_LO  0x04u   /* 占位 */
#define REG_OSD_BASE_HI  0x08u   /* 占位 */

static const uint32_t s_block_addr[2] = { OSD_BLOCK0_ADDR, OSD_BLOCK1_ADDR };
static int s_block = 0;

/* ---------------- 环回缓冲占位（板级为空实现，接口对齐 host） ---------------- */
uint8_t  g_plat_tx[256];
uint32_t g_plat_tx_len;

void platform_tx_reset(void) { g_plat_tx_len = 0u; }
void platform_rx_inject(const uint8_t *buf, uint32_t len) { (void)buf; (void)len; }

int platform_poll_byte(void) { return uart_poll_byte(); }

void platform_send(const uint8_t *buf, uint32_t len) { uart_send(buf, len); }

void platform_debug(const char *s) { (void)s; }   /* 需要时接调试串口 */

/* ---------------- 画布 ---------------- */

void canvas_select_block(int idx) { s_block = (idx == 1) ? 1 : 0; }

void canvas_write(uint32_t off, const uint8_t *src, uint32_t len)
{
    /* off 是块内偏移； HyperRAM 内部 32bit 突发对齐由 bsp 实现 */
    hram_write(s_block_addr[s_block] + off, src, len);
}

void canvas_fill(uint32_t off, uint8_t v, uint32_t len)
{
    hram_fill(s_block_addr[s_block] + off, v, len);
}

void canvas_commit(void)
{
    /* C-7：只置位一次，立即返回；RTL 在 SOF 生效并翻转 ack（ack 仅诊断用） */
    osd_reg_write(REG_OSD_COMMIT, 1u);
}

void canvas_flush(const char *path) { (void)path; }   /* 板级无意义 */
