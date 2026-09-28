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

    reg_write(OSD_REG_POS(OSD_MENU_ROUTE),
              ((uint32_t)((uint32_t)OSD_MENU_TOP & 0xFFFU) << 12)
            |  (uint32_t)((uint32_t)OSD_MENU_LEFT & 0xFFFU));
    reg_write(OSD_REG_CTRL(OSD_MENU_ROUTE), ctrl);
    reg_write(OSD_REG_COMMAND, OSD_CMD_COMMIT | OSD_CMD_GLOBAL_EN);
}

void canvas_flush(const char *path) { (void)path; }

const uint8_t *canvas_block_data(int idx) { (void)idx; return 0; }
