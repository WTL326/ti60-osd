/* =============================================================================
 * L5 画布抽象 —— 可移植边界
 *
 * core/（composer、ui、scene_table、font）只能通过这几个函数落画布，
 * **禁止直接访问 MMIO**。两个后端二选一链接：
 *     板级：src/osd/canvas_hw.c （写真 MMIO：HyperRAM 位图 + MaskControlRegs）
 *     主机：test/canvas_mem.c   （一块静态数组）。放在 test/ 下是因为固件的
 *                               makefile 用 wildcard 收 osd/ 下的 .c，两个后端
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

/* --- 回读（诊断用）--------------------------------------------------------
 *
 * 为什么要有这一组：当"回程"那条线（UART_SR_FT）不通时，上位机收不到应答，
 * 于是"寄存器到底写进去没有""位图真的落到 HyperRAM 了吗"都无从判断。
 * 板级回读是唯一**不依赖那条线**的证据来源：由固件把读回来的东西打到调试通道。
 *
 * 可读回的范围由 RTL 决定（src/control/MaskControlRegs.v:171-178）：
 *     +0x00 COMMAND 回读**暂存**的 global_enable（不是已生效的）
 *     +0x04 STATUS  {commit_count, 13'd0, pending, 1'b0, applied_global_enable}
 *     +0x08 CANVAS  {16'd720, 16'd576}
 *     +0x0C ACTIVE  {24'd0, applied_enable[3:0], applied_buffer_select[3:0]}
 *     其余（POS/CTRL 与 +0x30 以上）**一律读回 0**。
 * 也就是说：**坐标读不回来** —— POS/CTRL 是只写寄存器。所以本结构体里除了
 * 硬件回读值，还并排放了软件最后写下去的那对值，两者一起看才有意义
 * （硬件回读 0 + 软件写入值 = 契约所描述的行为被现场证实）。*/
typedef struct {
    uint32_t command;     /* +0x00 回读（暂存值）                          */
    uint32_t status;      /* +0x04                                        */
    uint32_t canvas;      /* +0x08                                        */
    uint32_t active;      /* +0x0C：四路的**已生效**使能与缓冲选择         */
    uint32_t pos_read;    /* OSD[1].POS 的回读：只写寄存器，恒 0           */
    uint32_t ctrl_read;   /* OSD[1].CTRL 的回读：只写寄存器，恒 0          */
    uint32_t pos_last;    /* 软件最近一次**写入**的 OSD[1].POS             */
    uint32_t ctrl_last;   /* 软件最近一次**写入**的 OSD[1].CTRL            */
} canvas_regs_t;

/* 回读上面那一组。板级读真寄存器；主机后端由 s_last_* 回填 —— 这样"回读接口
 * 本身写错了"也能在 qemu 上被抓到，而不是等到上板。*/
void canvas_read_regs(canvas_regs_t *out);

/* 把第 idx 块（0 = A / 1 = B）的位图**整块**读出来，返回读到的字节数
 * （应为 OSD_BLOCK_BYTES）；dst 至少要有这么多字节。
 *
 * 为什么不复用 canvas_block_data()：那个是主机后端专用的（板级返回 0），
 * 而这里要的正是"从硬件读回来"。*/
uint32_t canvas_read_block(int idx, uint8_t *dst);

/* --- 诊断专用：裸访问与写计数（只给启动回读用，别放进渲染路径）-------------
 *
 * 为什么需要它们：现场读回来"两块位图都是全零"时，**全零有两种病因、读数一模
 * 一样**：所有写都被丢掉，或者"清屏写 0 成功、composer 什么都没画"。要分开只能
 * 靠一次**往返验证**（写图案再读回）与**写字节计数**（composer 到底调过没有）。
 * ------------------------------------------------------------------------- */

/* 读一个字（绝对地址，**必须 4 字节对齐**）。板级 = 真 MMIO 读；主机后端只
 * 认识两块位图，其它地址一律返回 0（并**不会**假装成功）。*/
uint32_t canvas_peek(uint32_t addr);

/* 写一个字后**立刻读回**，返回回读值。往返不一致就说明那个地址写不进去。*/
uint32_t canvas_poke(uint32_t addr, uint32_t val);

/* 累计被写进来的字节数（canvas_write + canvas_fill）。
 * 它是"composer 有没有画东西"的直证：为 0 就是没画。*/
uint32_t canvas_bytes_written(void);

#endif /* OSD_CANVAS_H_INCLUDED */
