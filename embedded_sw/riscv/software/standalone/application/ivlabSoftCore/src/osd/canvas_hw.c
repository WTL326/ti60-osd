/* =============================================================================
 * L5 画布后端 —— 板级（ivlabSoftCore 固件目标）
 *
 * 与 src/osd/canvas_mem.c 二选一链接。本文件是**唯一**碰 MMIO 的地方。
 *
 * 地址来源（已核对，不是猜的）：
 *   * HyperRAM 对软核是**同地址直通**：BSP 的 `soc.h` 里
 *     `SYSTEM_DDR_BMB = 0x1000`、大小 64 MiB，而软核自己的链接脚本
 *     `ORIGIN = 0x00400000` 正落在这一段里 —— 也就是说软核看到的地址
 *     与 RTL 用的是同一套，位图基址 `0x00A4_0000` 直接可用，不需要任何基址换算。
 *   * 控制寄存器在 `SYSTEM_AXI_A_BMB = 0xE1000000` 这个 16 MiB 窗口内；
 *     `src/control/Ti60AxiControlFabric.v:135` 的 `M_BASE_ADDR` 列出了
 *     `0xe104_3000`，即 `MaskControlRegs` 的绝对地址就是 `0xE1043000`，
 *     窗口大小 4 KB（`M_ADDR_WIDTH` 给的是 12 位）。
 *   * AXI 主控数据位宽 32（`ip/riscv/riscv.v:87` 的 `axiA_wstrb[3:0]`），
 *     所以窄写（单字节 WSTRB）是支持的；但整字写能把事务数降到 1/4。
 *
 * 为什么要整字快路径：一次全屏渲染是 208 行 × 68 字节 = 14,144 字节。
 * 逐字节写就是 14,144 次 AXI 写事务，而这批数据量虽小、事务开销却是主角。
 * 行跨距 68 与基址都是 4 的倍数，所以渲染路径**永远**走整字分支，
 * 字节分支只作兜底（例如将来有人传一个未对齐的偏移进来）。
 * =============================================================================
 */
#include "canvas.h"
#include "osd_config.h"

static int s_block;
static int s_visible;

/* 软件最近一次提交写下去的 POS/CTRL。
 * 为什么要自己记一份：这两个寄存器**只写**，回读恒 0（MaskControlRegs.v:177），
 * 所以"我们写了什么"只能靠这两个变量与硬件回读值配对着看。*/
static uint32_t s_pos_written;
static uint32_t s_ctrl_written;

/* 累计被写进来的字节数。见 canvas_bytes_written()：它是"composer 到底画了没有"
 * 的直证 —— 现场读到全零时，靠它把"没画"与"画了写不进去"分开。*/
static uint32_t s_bytes_written;

/******************************************************************************
* @brief 写一个控制寄存器（绝对地址 = 基址 + 偏移）。
*
* @note volatile 不能省：这几条写是**有副作用**的（RTL 侧会据此改行为），
*       没有 volatile 编译器有权把它们优化掉或合并。
******************************************************************************/
static void reg_write(uint32_t off, uint32_t val)
{
    *(volatile uint32_t *)(OSD_REG_BASE + off) = val;
}

/******************************************************************************
* @brief 读一个控制寄存器（绝对地址 = 基址 + 偏移）。
*
* @note 同样要 volatile：地址里的值会被 RTL 随时改动（applied_* 在帧边界更新），
*       没有 volatile 编译器可以把两次读合并成一次。
******************************************************************************/
static uint32_t reg_read(uint32_t off)
{
    return *(volatile uint32_t *)(OSD_REG_BASE + off);
}

void canvas_select_block(int idx) { s_block = (idx == 1) ? 1 : 0; }

void canvas_set_visible(int on) { s_visible = (on != 0) ? 1 : 0; }

/******************************************************************************
* @brief 把一段字节写进当前后台块的指定偏移。
*
* @param off 块内字节偏移。
* @param src 源数据。
* @param len 字节数。
*
* @note 小端：源字节 0 落到目的字的 bit 7:0，这是 RISC-V 的字节序，
*       也是 RTL 侧按字节读回时看到的顺序。写反了画面会变成每 4 个像素
*       一组错位 —— 这种错在"看起来像图像噪声"里最难认。
******************************************************************************/
void canvas_write(uint32_t off, const uint8_t *src, uint32_t len)
{
    volatile uint8_t *dst = (volatile uint8_t *)((s_block ? OSD_BLOCK1_ADDR
                                                          : OSD_BLOCK0_ADDR) + off);
    uint32_t i = 0U;

    if (src == 0) {
        return;
    }

    s_bytes_written += len;

    if ((off & 3U) == 0U) {
        for (; i + 4U <= len; i += 4U) {
            uint32_t w = (uint32_t)src[i]
                       | ((uint32_t)src[i + 1U] << 8)
                       | ((uint32_t)src[i + 2U] << 16)
                       | ((uint32_t)src[i + 3U] << 24);
            *(volatile uint32_t *)(dst + i) = w;
        }
    }
    for (; i < len; i++) {
        dst[i] = src[i];
    }
}

/******************************************************************************
* @brief 用同一个字节填充一段区域（上电清屏用）。
*
* @note 清屏是 14,144 字节 × 2 块，走整字能把事务数从 28,288 降到 7,072。
******************************************************************************/
void canvas_fill(uint32_t off, uint8_t v, uint32_t len)
{
    volatile uint8_t *dst = (volatile uint8_t *)((s_block ? OSD_BLOCK1_ADDR
                                                          : OSD_BLOCK0_ADDR) + off);
    uint32_t i = 0U;

    s_bytes_written += len;

    if ((off & 3U) == 0U) {
        uint32_t pat = (uint32_t)v | ((uint32_t)v << 8)
                     | ((uint32_t)v << 16) | ((uint32_t)v << 24);
        for (; i + 4U <= len; i += 4U) {
            *(volatile uint32_t *)(dst + i) = pat;
        }
    }
    for (; i < len; i++) {
        dst[i] = v;
    }
}

/******************************************************************************
* @brief 提交：把菜单承载路的整组配置一次写下去，再置提交位。
*
* @note **三步必须在同一个函数里、按这个顺序**（D11（六））：
*         1) 位置（POS）—— 窗口放哪儿。它与其他几项同属"暂存区"，
*            写 COMMAND 的提交位才会一起生效；
*         2) 控制（CTRL）—— 使能位（= flags.bit0）与缓冲选择（乒乓）。
*            这两项**必须同一次提交**：分两次写会多出一次提交，
*            画面上会闪一下（先按旧缓冲显示新使能，或反之）；
*         3) COMMAND —— bit31 提交，bit0 全局使能。
*
* @note 另外三路 OSD 的暂存区本函数不碰：它们在复位后是 0（即不使能），
*       跟着这一次提交一起生效也就等于"保持关闭"。软核若要启用它们，
*       应当在同一组里补写 POS/CTRL —— 但那是 §6 范围之外的事。
*
* @note 提交是"置位即返回"，不等 pending 清、不读 ack：RTL 在帧边界整体切换。
*       要确认生效就读 STATUS 的 pending 位（本工程目前不需要，
*       因为下一步操作都在帧率尺度之外）。
******************************************************************************/
void canvas_commit(void)
{
    uint32_t ctrl = (s_visible ? OSD_CTRL_ENABLE : 0U)
                  | (s_block   ? OSD_CTRL_BUFFER : 0U);

    uint32_t pos = ((uint32_t)((uint32_t)OSD_MENU_TOP & 0xFFFU) << 12)
                 |  (uint32_t)((uint32_t)OSD_MENU_LEFT & 0xFFFU);

    /* 先记下这一组值再写下去：POS/CTRL 只写、回读恒 0，事后想看"写了什么"
     * 就只有这一份记录（见 canvas_read_regs）。*/
    s_pos_written  = pos;
    s_ctrl_written = ctrl;

    reg_write(OSD_REG_POS(OSD_MENU_ROUTE), pos);
    reg_write(OSD_REG_CTRL(OSD_MENU_ROUTE), ctrl);
    reg_write(OSD_REG_COMMAND, OSD_CMD_COMMIT | OSD_CMD_GLOBAL_EN);
}

void canvas_flush(const char *path) { (void)path; }

const uint8_t *canvas_block_data(int idx) { (void)idx; return 0; }

/* ---------------------------------------------------------------------------
 * 回读
 * ------------------------------------------------------------------------ */

/******************************************************************************
* @brief 把 MaskControlRegs 里**可读**的那几个字读回来。
*
* @note 字段偏移与位域按 RTL 的读复用器写死（MaskControlRegs.v:171-178），
*       不按文档 —— 文档描述的是契约，这里要的是"这个位流实际怎么接的"。
*       POS/CTRL 也照读一遍并保留在结构体里：它们的值应当恒为 0，打出来
*       正是为了证明"只写"这件事在板级也成立。
******************************************************************************/
void canvas_read_regs(canvas_regs_t *out)
{
    if (out == 0) {
        return;
    }

    out->command   = reg_read(OSD_REG_COMMAND);
    out->status    = reg_read(OSD_REG_STATUS);
    out->canvas    = reg_read(OSD_REG_CANVAS);
    out->active    = reg_read(OSD_REG_ACTIVE);
    out->pos_read  = reg_read(OSD_REG_POS(OSD_MENU_ROUTE));
    out->ctrl_read = reg_read(OSD_REG_CTRL(OSD_MENU_ROUTE));
    out->pos_last  = s_pos_written;
    out->ctrl_last = s_ctrl_written;
}

/******************************************************************************
* @brief 把一整块位图从 HyperRAM 读回来。
*
* @param idx  0 = A 块（0x00A4_0000）、1 = B 块（0x00B4_0000）。
* @param dst  目标缓冲，至少 OSD_BLOCK_BYTES 字节。
* @return 读到的字节数（= OSD_BLOCK_BYTES）。
*
* @note 整字读：14,144 字节 = 3,536 个字，正好整除，所以尾循环只是兜底
*       （将来有人改了画布尺寸就会用上）。
* @note 字节序与 canvas_write **对称**：写时源字节 0 落到字的 bit 7:0，
*       读时也按这个顺序拆回去。写读不对称的话回读出来的图会每 4 字节一组
*       错位，而那种错在缩略图上表现为"整块花纹"、极难反推。
******************************************************************************/
uint32_t canvas_read_block(int idx, uint8_t *dst)
{
    volatile const uint32_t *src = (volatile const uint32_t *)
        ((idx == 1) ? OSD_BLOCK1_ADDR : OSD_BLOCK0_ADDR);
    uint32_t i = 0U;

    if (dst == 0) {
        return 0U;
    }

    for (; i + 4U <= (uint32_t)OSD_BLOCK_BYTES; i += 4U) {
        uint32_t w = src[i >> 2];
        dst[i]      = (uint8_t)(w & 0xFFU);
        dst[i + 1U] = (uint8_t)((w >> 8) & 0xFFU);
        dst[i + 2U] = (uint8_t)((w >> 16) & 0xFFU);
        dst[i + 3U] = (uint8_t)((w >> 24) & 0xFFU);
    }
    for (; i < (uint32_t)OSD_BLOCK_BYTES; i++) {
        dst[i] = ((volatile const uint8_t *)src)[i];
    }

    return (uint32_t)OSD_BLOCK_BYTES;
}

/* ---------------------------------------------------------------------------
 * 诊断专用的裸访问与计数
 * ------------------------------------------------------------------------ */

uint32_t canvas_peek(uint32_t addr)
{
    return *(volatile uint32_t *)addr;
}

/******************************************************************************
* @brief 写一个字后立刻读回，返回回读值。
*
* @note 这是"这个地址能不能写"的最小实验。读回的是同一个地址，所以地址映射
*       若有偏移也不会影响结论 —— 偏移会同时作用于写与读、往返照样成立；
*       往返**不成立**就说明写根本没落到那个位置（或读根本读不到）。
******************************************************************************/
uint32_t canvas_poke(uint32_t addr, uint32_t val)
{
    *(volatile uint32_t *)addr = val;
    return *(volatile uint32_t *)addr;
}

uint32_t canvas_bytes_written(void)
{
    return s_bytes_written;
}
