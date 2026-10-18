/* =============================================================================
 * L2 UI 状态机 —— 只改状态与字符网格，**绝不写画布**
 *
 * 与上游 ti60-osd-main 的差异（D11 清单第 6/7/8 项）：
 *   6. ui_query_view 只填 8 字节（page_id/sel/flags/四个数值），12 字节 body
 *      由协议层前置 `04 08 02 FF` 后拼成；不再有 item_count 与 fw_version 位。
 *   7. UI_FLAG_SELECTED 改名 UI_FLAG_VISIBLE，语义由"选中"改为"UI 显示"；
 *      选中行的前缀标记改由 selected_item 与 UI_FLAG_EDIT 决定。
 *   8. 删除语言位 —— **2026-10-18 变更：bit2 已按《技术协议-2》附录A 的双语
 *      要求恢复为语言位（UI_FLAG_LANG_RU），UI_FLAG_MASK 回到 0x07。** 详见
 *      osd_config.h 里 D11 第 8 项的变更说明。
 *
 * 2026-10-18 全菜单变更：由 3 页原型扩为附录A 的 37 页，条目值改为按
 * value_kind（NUM/ONOFF/ENUM/EDIT/ACTION/NONE）渲染；新增 SET_ITEM_VALUE
 * （子项 0x09）设置任意页任意条目的运行期值。
 * =============================================================================
 */
#ifndef OSD_UI_H
#define OSD_UI_H

#include <stdint.h>
#include "osd_config.h"

typedef uint16_t cell_t;

extern cell_t  osd_buf[OSD_GRID_ROWS][OSD_GRID_COLS];
extern unsigned g_font_miss_count;      /* 每次 scene_build 前由调用方决定是否清零 */

void ui_init(void);

/* 命令入口：返回 0 = 接受；<0 = 拒绝（已置 status.bit1，状态不变）。
 *
 * page_id/sel/flags 的校验口径见 ui.c 的 ui_set_view()：页面必须存在于场景表、
 * selected_item 必须落在该页范围内、bit1（编辑态）只允许用在有值的行上。 */
int  ui_set_view(uint16_t page_id, uint8_t sel, uint8_t flags);
int  ui_set_image_values(const uint8_t v[4]);

/******************************************************************************
* @brief 设置**任意页任意条目**的运行期值（SET_ITEM_VALUE，子项 0x09）。
*
* @param page_id  目标页面 ID（必须来自场景表）。
* @param item_idx 该页内的条目序号（必须 < item_count）。
* @param val      值字节流。
* @param vlen     val 的长度。
* @return 0 = 接受；<0 = 拒绝（已置 status.bit1，状态不变）：
*           -1 页面不存在     -2 条目越界     -3 页索引越界
*           -4 NUM/ONOFF/ENUM 缺值字节       -5 ENUM 值越界
*           -6 该条目不接受值（NONE / ACTION）
*
* @note value 的长度与含义由**条目的 value_kind** 决定，不由命令字决定：
 *        NUM / ONOFF / ENUM 取 1 字节；EDIT 取文本字节流（截断到 OSD_EDIT_LEN-1）。
*       这样加一种值类型不必动协议，只动场景表与本函数。
*
* @note 只改显示状态，**不产生任何 AXI / 寄存器写入**：与 SET_IMAGE_VALUES 一样，
*       这些值目前仅用于菜单回显，没有连到任何图像处理通路。
******************************************************************************/
int  ui_set_item_value(uint16_t page_id, uint8_t item_idx,
                       const uint8_t *val, uint32_t vlen);

/* QUERY_VIEW 的参数段（8 字节，不含前面的 `04 08 02 FF`）：
 *   page_id:u16BE | sel:u8 | flags:u8 | v0 v1 v2 v3
 * 返回值为接受（0）还是拒绝（<0）—— 本函数本身不会失败，返回 0。
 *
 * 注意：全菜单上线后**长度仍是 8 字节、字段顺序不变**。多写 item_count 之类
 * 会让它变成 14 字节 body，上位机按 `18 if sub == 8 else 10` 解析会直接 CRC
 * 对不上。要加字段得先改协议文档与上位机工具，不能只改这里。 */
int  ui_query_view(uint8_t resp[UI_QUERY_PAYLOAD_LEN]);

/* UI 是否应当显示（= flags.bit0）。它落到硬件上是菜单承载路的 CTRL.enable，
 * 由画布提交那一组配置一并写入（D11（六））。注意本模块**不做隐藏动作** ——
 * 隐藏是"关掉那一路 OSD 窗口"，不是"把画布擦干净"：擦画布会闪一帧黑。 */
int  ui_is_visible(void);

int  ui_is_dirty(void);
void ui_clear_dirty(void);
void ui_clear_status(void);   /* 清 status.bit1（测试/自检用） */

/* 内部状态位（UI_STATUS_BAD_PARAM）。它不进协议应答，只供固件内部与离机测试查。 */
uint8_t ui_status(void);

/* 状态 → 字符网格。缺字形在此就地归一为 '?' 并计数 */
void scene_build(void);

/* 测试辅助：把网格 dump 成 UTF-8 文本（每行以 '\n' 结尾，末尾补 '\0'） */
void osd_grid_dump(char *out, unsigned out_size);

#endif /* OSD_UI_H */
