/* =============================================================================
 * L5 画布抽象 —— 可移植边界
 *
 * core/（composer、ui、scene_table、font）只能通过这几个函数落画布，
 * **禁止直接访问 MMIO**。两个后端二选一链接：
 *     板级：src/osd/canvas_hw.c （写真 MMIO：HyperRAM 位图 + MaskControlRegs）
 *     主机：test/canvas_mem.c   （一块静态数组）。放在 test/ 下是因为固件的
 *                               makefile 用 wildcard 收 src/osd/*.c，两个后端
 *                               都定义同一组 canvas_* 符号，同时进链接会撞重定义。
 *
 * 位图块的含义（D3/D6）：
 *     菜单承载路 = OSD1，两块缓冲分别在 0x00A4_0000（A）与 0x00B4_0000（B）。
 *     一块 = 544×208 @ 1 bpp = 14,144 字节，行跨距 68 字节。
 *     前台块正被 RTL 扫描，**任何时候都不要写前台块** —— 选择后台块是调用方
 *     的责任（见 main 循环里的乒乓翻转）。
 * =============================================================================
 */
#ifndef OSD_CANVAS_H_INCLUDED
#define OSD_CANVAS_H_INCLUDED

#include <stdint.h>

/* 选择后台块（0 = A / 1 = B）。下一次 canvas_commit() 后由 RTL 在帧边界切到前台。
 * 板级实现：写菜单承载路的 OSD[1].CTRL.buffer_select。 */
void canvas_select_block(int idx);

/* 按**块内字节偏移**写入位图数据（off 相对当前后台块起点）。
 * 偏移与长度都按字节计 —— 1 bpp 下"字节"与"像素"差 8 倍，别混。 */
void canvas_write(uint32_t off, const uint8_t *src, uint32_t len);

/* 区域填充（上电整体清零用） */
void canvas_fill(uint32_t off, uint8_t v, uint32_t len);

/* UI 是否显示（= flags.bit0）。它落到菜单承载路的 CTRL.enable，
 * 与 buffer_select 在**同一次 commit 的同一组配置**里写入（D11（六））——
 * 分两次写会多出一次提交，画面会闪一下。 */
void canvas_set_visible(int on);

/* 置提交位后**立即返回**，不等 ack、无超时。
 * 板级：先写 OSD[1].CTRL（使能 + 缓冲），再写 COMMAND 的 bit31 与 bit0。 */
void canvas_commit(void);

/* 主机后端专用：把块内容导出成 PGM（板级为空实现）。 */
void canvas_flush(const char *path);

/* --- 主机后端专用：把"最近一次提交写了什么"暴露出来供断言 ---
 *
 * 板级后端不定义这三个符号（它写的是真寄存器，没有可读回的地方）。
 * 放在这里的理由：它们描述的是**提交的语义**（写了哪些配置位、提交了几次），
 * 与 canvas_block_data() 同类，属于"抽象层对测试的可见面"，不是某个实现的内务。*/
extern uint8_t  s_last_ctrl;     /* 最近一次提交写给 OSD[1].CTRL 的值 */
extern uint32_t s_last_pos;      /* 最近一次提交写给 OSD[1].POS 的值  */
extern uint32_t s_commit_count;  /* 累计提交次数                     */

/* 主机后端专用：把某一块的字节读出来做断言（板级为空实现，返回 0）。 */
const uint8_t *canvas_block_data(int idx);

#endif /* OSD_CANVAS_H_INCLUDED */
