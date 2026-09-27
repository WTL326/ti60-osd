/* =============================================================================
 * L5 画布抽象 —— 可移植边界
 * core/ 只能通过这五个函数落画布；禁止直接访问 MMIO。
 * 板级实现：port/canvas_target.c
 * PC  实现：port/canvas_host.c
 * =============================================================================
 */
#ifndef OSD_CANVAS_H_INCLUDED
#define OSD_CANVAS_H_INCLUDED

#include <stdint.h>

/* 选择后台块（0 / 1）。下一次 commit 后由 RTL 在 SOF 切到前台。 */
void canvas_select_block(int idx);

/* 按字节偏移写入像素数据（off 相对当前后台块起点） */
void canvas_write(uint32_t off, const uint8_t *src, uint32_t len);

/* 区域填充（清零 / 铺底色） */
void canvas_fill(uint32_t off, uint8_t v, uint32_t len);

/* 置 commit 位后**立即返回**，不等 ack、无超时（C-7 已决） */
void canvas_commit(void);

/* PC：导出 out*.ppm；板级：空实现 */
void canvas_flush(const char *path);

#endif /* OSD_CANVAS_H_INCLUDED */
