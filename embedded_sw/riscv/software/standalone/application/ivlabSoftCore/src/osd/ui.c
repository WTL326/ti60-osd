/* =============================================================================
 * L2 UI 状态机实现
 *
 * 职责边界：**只改状态和 osd_buf，绝不写画布**；渲染由调用方（main 循环）触发。
 * 唯一例外：scene_build 里的缺字形归一允许查 L3 字库（只读）。
 *
 * 与上游 ti60-osd-main 的三处实质差异见 ui.h 的说明（D11 第 6/7/8 项）。
 * =============================================================================
 */
#include "ui.h"
#include "scene_table.h"
#include "font.h"
#include "osd_config.h"
#include "utf8.h"

cell_t   osd_buf[OSD_GRID_ROWS][OSD_GRID_COLS];
unsigned g_font_miss_count;

typedef struct {
    uint16_t page_id;
    uint8_t  sel;
    uint8_t  flags;
    uint8_t  v[4];
    uint8_t  status;
    uint8_t  dirty;
} ui_state_t;

static ui_state_t s_state;

/* ---------------------------------------------------------------- helpers */

/******************************************************************************
* @brief 取一条双语文案的**英文**列。
*
* @param s 双语字符串。
* @return 英文（UTF-8）。
*
* @note 上游按 UI_FLAG_LANG_RU 在 en/ru 之间选；本变更删除了语言位（D11 第 8 项），
*       语言不再是 UI 状态的一部分，于是这里固定取英文。
*       场景表里的俄语列**保留不动**：它是数据、不是状态，将来若把语言做成
*       编译期或独立配置项，那一列直接可用，不必回头补数据。
******************************************************************************/
static const char *pick(const i18n_t *s)
{
    return s->en;
}

/******************************************************************************
* @brief 把整个网格填成空格。
*
* @note 全量重画语义的一部分：不清空的话，上一页残留的字符会在新页的空白处露出来。
******************************************************************************/
static void grid_clear(void)
{
    unsigned r, c;
    for (r = 0u; r < OSD_GRID_ROWS; r++)
        for (c = 0u; c < OSD_GRID_COLS; c++)
            osd_buf[r][c] = (cell_t)' ';
}

/******************************************************************************
* @brief 往一个格子里写一个码点，缺字形就地归一为 '?'。
*
* @param row 行号（越界即忽略）。
* @param col 列号（越界即忽略）。
* @param cp  Unicode 码点。
*
* @note 越界静默忽略而不是裁剪：调用方的列号来自固定的排版常量，越界属编程错误，
*       裁到边上反而会把错误画成一个看似合理的画面。
*
* @note 归一化放在这里（而不是渲染时）是为了让"画面上出现的字符"与
*       "g_font_miss_count 报告的缺字数"始终一致 —— 渲染层看不到码点，
*       它只看到字库下标。
******************************************************************************/
static void grid_put(unsigned row, unsigned col, uint32_t cp)
{
    if (row >= OSD_GRID_ROWS || col >= OSD_GRID_COLS) return;

    if (cp > 0xFFFFu) cp = '?';
    if (font_lookup((uint16_t)cp) < 0) {
        g_font_miss_count++;
        cp = '?';
    }
    osd_buf[row][col] = (cell_t)cp;
}

static unsigned utf8_str_cells(const char *s)
{
    unsigned n = 0u;
    const unsigned char *p = (const unsigned char *)s;
    unsigned remain = 0u, i;
    for (i = 0u; s[i] != '\0'; i++) remain++;
    while (*p != '\0') {
        unsigned adv;
        osd_utf8_decode(p, remain, &adv);
        p += adv; remain -= adv;
        n++;
    }
    return n;
}

/******************************************************************************
* @brief 从 start_col 起写一个 UTF-8 串，最多写到 end_col（含）。
*
* @note 被截断时在末列写 '?'：否则肉眼无法判断"标签就这么长"还是"被切了"。
******************************************************************************/
static void grid_put_str(unsigned row, unsigned start_col, const char *str, unsigned end_col)
{
    const unsigned char *p = (const unsigned char *)str;
    unsigned len = 0u, remain = 0u;
    unsigned col = start_col;

    while (str[len] != '\0') len++;
    remain = len;

    while (*p != '\0' && remain > 0u) {
        unsigned adv;
        uint32_t cp = osd_utf8_decode(p, remain, &adv);
        p += adv; remain -= adv;
        if (col > end_col) break;
        grid_put(row, col, cp);
        col++;
    }

    if (remain > 0u) grid_put(row, end_col, '?');
}

static void grid_fill_row(unsigned row, char ch)
{
    unsigned c;
    for (c = 0u; c < OSD_GRID_COLS; c++) grid_put(row, c, (uint32_t)ch);
}

static void grid_put_centered(unsigned row, const char *str)
{
    unsigned n = utf8_str_cells(str);
    unsigned span = OSD_COL_BORDER_R - OSD_COL_BORDER_L - 1u;   /* 32 列内容宽 */
    unsigned start;

    if (n >= span) { grid_put_str(row, OSD_COL_PREFIX, str, OSD_COL_VALUE_LAST); return; }
    start = OSD_COL_PREFIX + (span - n) / 2u;
    grid_put_str(row, start, str, OSD_COL_VALUE_LAST);
}

/* 手写 itoa：无 libc / 无浮点 */
static unsigned u8_to_dec(uint8_t v, char *dst)
{
    char tmp[4];
    unsigned n = 0u, i;

    do { tmp[n++] = (char)('0' + (v % 10u)); v = (uint8_t)(v / 10u); } while (v != 0u);
    for (i = 0u; i < n; i++) dst[i] = tmp[n - 1u - i];
    return n;
}

/* 数值右对齐：最后一个字符落在 OSD_COL_VALUE_LAST（[n] 形式） */
static void grid_put_value(unsigned row, uint8_t val)
{
    char buf[8];
    unsigned len = 0u, start;

    buf[len++] = '[';
    len += u8_to_dec(val, &buf[len]);
    buf[len++] = ']';
    buf[len] = '\0';

    if (len > OSD_COL_VALUE_LAST) len = OSD_COL_VALUE_LAST;
    start = OSD_COL_VALUE_LAST + 1u - len;
    grid_put_str(row, start, buf, OSD_COL_VALUE_LAST);
}

/* ---------------------------------------------------------------- API */

void ui_init(void)
{
    s_state.page_id = 0x0000u;
    s_state.sel     = 0u;
    s_state.flags   = UI_FLAG_VISIBLE;   /* 上电即显示主菜单（bit0 = UI 显示）*/
    s_state.v[0]    = 3u;      /* 默认值取自 UI 规格 P2 原型 */
    s_state.v[1]    = 5u;
    s_state.v[2]    = 7u;
    s_state.v[3]    = 5u;
    s_state.status  = 0u;
    s_state.dirty   = 1u;
    grid_clear();
}

/******************************************************************************
* @brief 处理 SET_VIEW：切页面、选行、改 flags。
*
* @param page_id 目标页面 ID（必须来自场景表）。
* @param sel     该页内的绝对子项序号。
* @param flags   bit0 = UI 显示，bit1 = 编辑态；其余位保留、静默丢弃。
* @return 0 = 接受；-1 = 页面不存在；-2 = 选中项越界；-3 = 该行不支持编辑态。
*
* @note 为什么要校验"编辑态只允许用在有数值的行"：文档 §3.1 写的是"编辑状态只
*       允许用于图像设置页的前四项"。这里没有把页面号写死成 0x0100、也没有写死
*       序号 < 4，而是用**该行是否有数值槽**（value_slot >= 0）来表达 ——
*       两者在 P2 页上恰好等价（前四项有数值、后两项是跳转项），但换成"数值行"
*       这个条件后，将来往别的页加数值行不必回头改这条校验。
*
* @note 失败时**状态完全不变**（含 flags）：这是"整帧拒绝"的口径 —— 部分生效会
*       让上位机回读到的状态既不是旧的也不是它要的新的，比直接失败更难排查。
******************************************************************************/
int ui_set_view(uint16_t page_id, uint8_t sel, uint8_t flags)
{
    const scene_page_t *pg = scene_find(page_id);
    uint8_t f;

    if (pg == 0)               { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    if (sel >= pg->item_count) { s_state.status |= UI_STATUS_BAD_PARAM; return -2; }

    f = (uint8_t)(flags & UI_FLAG_MASK);        /* 保留位静默丢弃、不报错 */
    if ((f & UI_FLAG_EDIT) && (pg->value_slot[sel] < 0)) {
        s_state.status |= UI_STATUS_BAD_PARAM;
        return -3;
    }

    s_state.page_id = page_id;
    s_state.sel     = sel;
    s_state.flags   = f;
    s_state.dirty   = 1u;
    return 0;
}

/******************************************************************************
* @brief 处理 SET_IMAGE_VALUES：四个数值一次提交。
*
* @param v 四个值，顺序为 image_enhance / contrast / image_brightness /
*          screen_brightness。
* @return 0 = 接受；-1 = 越界。
*
* @note **整条命令失败则四个值全部不变**（文档 §3.2）。所以校验必须在写入之前
*       全部做完 —— 先写前两个再发现第三个越界，就会留下一组半新半旧的参数，
*       而上位机收到的是"失败"、它会认为一个都没生效。
*
* @note 本函数只改显示状态，**不产生任何 AXI / 寄存器写入**：这四个值目前仅用于
*       菜单回显与前端的 QUERY_VIEW 回读，没有连到任何图像处理通路。
*       这是本期明确的范围（任务 6.10），也是"改了参数画面没变"的原因。
******************************************************************************/
int ui_set_image_values(const uint8_t v[4])
{
    if (v[0] > UI_V_ENHANCE_MAX) { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    if ((v[1] > UI_V_OTHER_MAX) || (v[2] > UI_V_OTHER_MAX) || (v[3] > UI_V_OTHER_MAX)) {
        s_state.status |= UI_STATUS_BAD_PARAM;
        return -1;
    }

    s_state.v[0] = v[0];
    s_state.v[1] = v[1];
    s_state.v[2] = v[2];
    s_state.v[3] = v[3];
    s_state.dirty = 1u;
    return 0;
}

/******************************************************************************
* @brief 填 QUERY_VIEW 应答的参数段（8 字节，不含前面的 `04 08 02 FF`）。
*
* @param resp 输出缓冲，至少 UI_QUERY_PAYLOAD_LEN 字节。
* @return 恒为 0。
*
* @note 这里的字段顺序与上位机工具 `tools/send_ui_via_adb.py` 的解析**逐字段
*       对齐**（它按 `body[4:6]`/`[6]`/`[7]`/`[8:12]` 取），所以本函数产出的
*       8 字节正好落在那个位置上。改动这个顺序会让工具报"UI命令失败"。
*
* @note **不再有 item_count 与 fw_version**（D11 第 6 项）：协议文档 §3.3 与工具
*       都只认这 8 个字节，多写两个会直接变成 CRC 对不上的 14 字节 body。
******************************************************************************/
int ui_query_view(uint8_t resp[UI_QUERY_PAYLOAD_LEN])
{
    resp[0] = (uint8_t)(s_state.page_id >> 8);
    resp[1] = (uint8_t)(s_state.page_id & 0xFFu);
    resp[2] = s_state.sel;
    resp[3] = s_state.flags;
    resp[4] = s_state.v[0];
    resp[5] = s_state.v[1];
    resp[6] = s_state.v[2];
    resp[7] = s_state.v[3];
    return 0;
}

int  ui_is_visible(void)  { return (s_state.flags & UI_FLAG_VISIBLE) ? 1 : 0; }
int  ui_is_dirty(void)    { return (int)s_state.dirty; }
void ui_clear_dirty(void) { s_state.dirty = 0u; }
void ui_clear_status(void){ s_state.status = 0u; }

/* ---------------------------------------------------------------- 排版 */

void scene_build(void)
{
    const scene_page_t *pg = scene_find(s_state.page_id);
    unsigned i;

    grid_clear();
    if (pg == 0) return;                       /* 命令层已保证不会走到这里 */

    /* 外框：顶/底横线（-），分隔线（-） */
    grid_fill_row(OSD_ROW_BORDER_TOP,    '-');
    grid_fill_row(OSD_ROW_SEPARATOR,     '-');
    grid_fill_row(OSD_ROW_BORDER_BOTTOM, '-');

    /* 标题居中 */
    grid_put_centered(OSD_ROW_TITLE, pick(&pg->title));

    for (i = 0u; i < pg->item_count; i++) {
        unsigned row  = OSD_ROW_ITEM0 + i;
        unsigned end  = (pg->value_slot[i] >= 0) ? OSD_COL_LABEL_END : OSD_COL_VALUE_LAST;

        /* 左/右边框 */
        grid_put(row, OSD_COL_BORDER_L, '|');
        grid_put(row, OSD_COL_BORDER_R, '|');

        /* 前缀：当前行按编辑态取 '*' 或 '>'，其余行留空。
         *
         * 上游用的是 (UI_FLAG_SELECTED | UI_FLAG_EDIT) 这一对位，而现在 bit0 的
         * 含义是"UI 显示"（整块菜单的显隐），与"哪一行是选中行"无关了 ——
         * 选中行由 sel 唯一决定。若照搬上游的写法，菜单一显示就会所有行都带
         * 选中标记，那是把"窗口可见"误当成"这一行被选中"（D11 第 7 项）。*/
        if (i == s_state.sel) {
            grid_put(row, OSD_COL_PREFIX, (s_state.flags & UI_FLAG_EDIT) ? '*' : '>');
            grid_put(row, OSD_COL_PREFIX + 1u, ' ');
        } else {
            grid_put(row, OSD_COL_PREFIX, ' ');
            grid_put(row, OSD_COL_PREFIX + 1u, ' ');
        }

        /* 标签（超长截断） */
        grid_put_str(row, OSD_COL_LABEL, pick(&pg->items[i]), end);

        /* 数值（v[slot] 右对齐，这是 SET_IMAGE_VALUES 在画面上的唯一出口） */
        if (pg->value_slot[i] >= 0)
            grid_put_value(row, s_state.v[pg->value_slot[i]]);
    }
}

/* ---------------------------------------------------------------- dump */

static unsigned cp_to_utf8(uint32_t cp, char *out)
{
    if (cp < 0x80u) { out[0] = (char)cp; return 1u; }
    if (cp < 0x800u) {
        out[0] = (char)(0xC0u | (cp >> 6));
        out[1] = (char)(0x80u | (cp & 0x3Fu));
        return 2u;
    }
    out[0] = (char)(0xE0u | (cp >> 12));
    out[1] = (char)(0x80u | ((cp >> 6) & 0x3Fu));
    out[2] = (char)(0x80u | (cp & 0x3Fu));
    return 3u;
}

void osd_grid_dump(char *out, unsigned out_size)
{
    unsigned r, c, k = 0u;

    for (r = 0u; r < OSD_GRID_ROWS; r++) {
        for (c = 0u; c < OSD_GRID_COLS; c++) {
            k += cp_to_utf8(osd_buf[r][c], &out[k]);
        }
        if (k + 1u < out_size) out[k++] = '\n';
    }
    if (k < out_size) out[k] = '\0';
}
