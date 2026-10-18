/* =============================================================================
 * L2 UI 状态机实现
 *
 * 职责边界：**只改状态和 osd_buf，绝不写画布**；渲染由 osd_engine 触发。
 * 唯一例外：scene_build 里的缺字形归一允许查 L3 字库（只读）。
 *
 * 与上游 ti60-osd-main 的三处实质差异见 ui.h 的说明（D11 第 6/7/8 项）。
 *
 * 2026-10-18 全菜单变更（对应已决 Q1–Q3）：
 *   - 页面条目值类型 value_kind（NUM/ONOFF/ENUM/EDIT/ACTION/NONE），渲染规则见
 *     scene_table.h 头注释与样例文档 TI60_OSD_附录A全菜单显示样例_v0.1.html。
 *   - 超长页（SETTING 0x0500 有 10 项 > 9 可见行）采用"窗口最小移动"（Q1）：
 *     窗口随 sel 平移，sel 始终可见。
 *   - 新增 SET_ITEM_VALUE（子项 0x09）设置任意页任意条目的运行期值；运行期值
 *     镜像 g_rt 按 scene 页索引存储，上电由 def 初始化。
 *   - SET_IMAGE_VALUES（子项 0x07）保留原有语义与范围校验，但它只影响 QUERY
 *     回报，不再驱动菜单数值渲染（菜单值改由 SET_ITEM_VALUE 写）。
 *
 * 本文件与 PC 仿真侧（osd/core/ui.c）的渲染规则**逐条一致**：两端共用同一套
 * 排版常量与窗口规则，渲染结果才能逐格比对。改排版请两边同步。
 * =============================================================================
 */
#include "ui.h"
#include "scene_table.h"
#include "font.h"
#include "osd_config.h"
#include "utf8.h"

cell_t   osd_buf[OSD_GRID_ROWS][OSD_GRID_COLS];
unsigned g_font_miss_count;

/* 运行期值镜像：按 scene 页索引存储；SET_ITEM_VALUE 改写，上电由 def 初始化。
 *
 * OSD_RT_PAGES 必须 >= scene_page_count()（现为 37），取 64 是给后续加页留余量。
 * 体积 64 × (12 + 12×16) ≈ 13 KB，落在外挂 HyperRAM（SYSTEM_DDR_BMB_SIZE =
 * 64 MB）的 .bss 里，不构成压力；这里刻意与 PC 仿真侧保持同构，好让两端渲染
 * 结果能逐格比对，不为省这点空间引入一层间接寻址。 */
#define OSD_RT_PAGES 64u
#define OSD_EDIT_LEN 16u

typedef struct {
    uint8_t val[OSD_ITEMS_CAP];                 /* NUM/ONOFF/ENUM 当前值 */
    char    edit[OSD_ITEMS_CAP][OSD_EDIT_LEN];  /* EDIT 文本缓冲 */
} page_rt_t;

static page_rt_t g_rt[OSD_RT_PAGES];

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
* @brief 求字符串长度。
*
* @note 本模块**不依赖 libc**（与 frame.c 一样保持零依赖），所以不能用 strlen，
*       这里自己数。见 ui.c 顶部与 harness 的说明：被测代码是刻意做成零依赖的
*       纯逻辑，拉进 string.h 会把库依赖算到固件头上。
******************************************************************************/
static unsigned osd_strlen(const char *s)
{
    unsigned n = 0u;
    while (s[n] != '\0') n++;
    return n;
}

/******************************************************************************
* @brief 该条目是否"带值"。
*
* @note 编辑态（UI_FLAG_EDIT）只允许落在带值的行上：这是文档 §3.1"编辑状态只
*       允许用于有数值的行"的口径。旧实现用 value_slot >= 0 表达，换成
*       value_kind 后这里改成"类型不是 NONE/ACTION"——语义等价，但换成按类型
*       判之后，将来加一种带值类型不必回来改这条校验。
******************************************************************************/
static int item_takes_value(uint8_t kind)
{
    return (kind == OSD_VAL_NUM || kind == OSD_VAL_ONOFF ||
            kind == OSD_VAL_ENUM || kind == OSD_VAL_EDIT) ? 1 : 0;
}

static const char *title_of(const scene_page_t *pg)
{
    return (s_state.flags & UI_FLAG_LANG_RU) ? pg->title_ru : pg->title_en;
}

static const char *label_of(const scene_item_t *it)
{
    return (s_state.flags & UI_FLAG_LANG_RU) ? it->ru : it->en;
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
* @note 归一化放在这里（而不是渲染时）是为了让"画面上出现的字符"与
*       g_font_miss_count 报告的缺字数始终一致 —— 渲染层看不到码点，
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
    unsigned remain = osd_strlen(s);

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
    unsigned remain = osd_strlen(str);
    unsigned col = start_col;

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

/******************************************************************************
* @brief 把条目值写入第 row 行的值列（右对齐，末列 = OSD_COL_VALUE_LAST）。
*
* @return 1 = 写了值（NUM/ONOFF/ENUM/EDIT），0 = 无值（NONE/ACTION）。
*
* @note 先渲染值、再定标签的截断列：标签要不要给值让列，取决于这行**有没有值**，
*       而不是值的类型在表里怎么写。所以由本函数的返回值决定 end 列，
*       调用方不必再判一次类型。
******************************************************************************/
static unsigned render_value(unsigned row, const scene_item_t *it,
                             unsigned page_idx, unsigned item_idx)
{
    char buf[24];
    const char *s = 0;
    unsigned len = 0u;

    switch (it->kind) {
    case OSD_VAL_NUM: {
        unsigned nd = u8_to_dec(g_rt[page_idx].val[item_idx], &buf[1]);
        buf[0] = '[';
        buf[1u + nd] = ']';
        buf[2u + nd] = '\0';
        s = buf; len = 2u + nd;
        break;
    }
    case OSD_VAL_ONOFF:
        s = (g_rt[page_idx].val[item_idx] != 0u) ? "On" : "Off";
        len = osd_strlen(s);
        break;
    case OSD_VAL_ENUM: {
        unsigned v = g_rt[page_idx].val[item_idx];
        unsigned n = scene_enum_count(it);
        const char *const *tbl;
        if (v >= n) v = 0u;
        tbl = (s_state.flags & UI_FLAG_LANG_RU) ? it->vals_ru : it->vals_en;
        s = (tbl && tbl[v]) ? tbl[v] : "?";
        len = osd_strlen(s);
        break;
    }
    case OSD_VAL_EDIT:
        s = g_rt[page_idx].edit[item_idx];
        len = osd_strlen(s);
        break;
    default:
        return 0u;   /* NONE / ACTION：无值列 */
    }

    {
        unsigned start = (len <= OSD_COL_VALUE_LAST)
                            ? (OSD_COL_VALUE_LAST + 1u - len)
                            : OSD_COL_PREFIX;
        grid_put_str(row, start, s, OSD_COL_VALUE_LAST);
    }
    return 1u;
}

/******************************************************************************
* @brief 0x0710 十字分划调节概念屏。
*
* @note 十字是**叠加层**画出来的，不在本模块 —— 这里只是用 '+' 搭一个占位十字，
*       让上位机在没有叠加层的情况下也能看到页面结构与坐标行。真实十字上线后
*       本函数可以直接删掉，页面表不用改。
******************************************************************************/
static void render_reticle_adjust(const scene_page_t *pg, unsigned page_idx)
{
    unsigned r, c;

    grid_fill_row(OSD_ROW_BORDER_TOP,    '-');
    grid_fill_row(OSD_ROW_SEPARATOR,     '-');
    grid_fill_row(OSD_ROW_BORDER_BOTTOM, '-');
    grid_put_centered(OSD_ROW_TITLE, title_of(pg));

    for (r = 4u; r <= 10u; r++) grid_put(r, 16u, '+');
    for (c = 10u; c <= 22u; c++) grid_put(7u, c, '+');
    grid_put(7u, 16u, '+');

    grid_put_str(4u, OSD_COL_LABEL, g_rt[page_idx].edit[0], OSD_COL_VALUE_LAST);

    {
        const char *hint = (s_state.flags & UI_FLAG_LANG_RU)
            ? "Движение: стрелки   OK: подтвердить"
            : "Move: arrows   OK: confirm";
        grid_put_str(11u, OSD_COL_LABEL, hint, OSD_COL_VALUE_LAST);
    }
}

/* ---------------------------------------------------------------- API */

void ui_init(void)
{
    unsigned i, j;

    /* 运行期值镜像从 scene def 初始化 */
    for (i = 0u; i < scene_page_count() && i < OSD_RT_PAGES; i++) {
        const scene_page_t *pg = scene_at(i);
        for (j = 0u; j < pg->item_count && j < OSD_ITEMS_CAP; j++) {
            const scene_item_t *it = &pg->items[j];
            g_rt[i].val[j] = it->def;
            if (it->kind == OSD_VAL_EDIT && it->edit_def) {
                unsigned k = 0u;
                while (it->edit_def[k] != '\0' && (k + 1u) < OSD_EDIT_LEN) {
                    g_rt[i].edit[j][k] = it->edit_def[k]; k++;
                }
                g_rt[i].edit[j][k] = '\0';
            } else {
                g_rt[i].edit[j][0] = '\0';
            }
        }
    }

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
* @param flags   bit0 = UI 显示，bit1 = 编辑态，bit2 = 语言；其余位保留、静默丢弃。
* @return 0 = 接受；-1 = 页面不存在；-2 = 选中项越界；-3 = 该行不支持编辑态。
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
    if ((f & UI_FLAG_EDIT) && !item_takes_value(pg->items[sel].kind)) {
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
* @return 0 = 接受；-1 = 越界（四个值全部不变）。
*
* @note **整条命令失败则四个值全部不变**（文档 §3.2）。所以校验必须在写入之前
*       全部做完 —— 先写前两个再发现第三个越界，就会留下一组半新半旧的参数。
*
* @note 全菜单上线后，这四个值**不再驱动菜单数值渲染**（菜单值由 SET_ITEM_VALUE
*       按页按条目写），但仍原样进 QUERY_VIEW 的回报——那是与上位机工具的
*       既有约定，不能因为菜单改版就断掉。
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
* @brief 处理 SET_ITEM_VALUE：设置一页内一条目的运行期值。
*
* 返回值与取值规则见 ui.h 的声明。要点：value 的长度与含义由条目的 value_kind
* 决定，不由命令字决定。
******************************************************************************/
int ui_set_item_value(uint16_t page_id, uint8_t item_idx,
                      const uint8_t *val, uint32_t vlen)
{
    const scene_page_t *pg = scene_find(page_id);
    unsigned idx;
    const scene_item_t *it;

    if (pg == 0)                    { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    if (item_idx >= pg->item_count) { s_state.status |= UI_STATUS_BAD_PARAM; return -2; }
    idx = scene_index(page_id);
    if (idx >= OSD_RT_PAGES)        { s_state.status |= UI_STATUS_BAD_PARAM; return -3; }

    it = &pg->items[item_idx];
    if (!item_takes_value(it->kind)) {
        s_state.status |= UI_STATUS_BAD_PARAM; return -6;   /* NONE / ACTION 不接受值 */
    }

    switch (it->kind) {
    case OSD_VAL_ENUM:
        if (vlen < 1u) { s_state.status |= UI_STATUS_BAD_PARAM; return -4; }
        if (val[0] >= scene_enum_count(it)) {
            s_state.status |= UI_STATUS_BAD_PARAM; return -5;
        }
        g_rt[idx].val[item_idx] = val[0];
        break;

    case OSD_VAL_NUM:
    case OSD_VAL_ONOFF:
        if (vlen < 1u) { s_state.status |= UI_STATUS_BAD_PARAM; return -4; }
        g_rt[idx].val[item_idx] = val[0];
        break;

    case OSD_VAL_EDIT: {
        unsigned n = (vlen < OSD_EDIT_LEN) ? (unsigned)vlen : (OSD_EDIT_LEN - 1u);
        unsigned k;
        for (k = 0u; k < n; k++) g_rt[idx].edit[item_idx][k] = (char)val[k];
        g_rt[idx].edit[item_idx][n] = '\0';
        break;
    }

    default:
        s_state.status |= UI_STATUS_BAD_PARAM; return -6;
    }

    s_state.dirty = 1u;
    return 0;
}

/******************************************************************************
* @brief 填 QUERY_VIEW 应答的参数段（8 字节，不含前面的 `04 08 02 FF`）。
*
* @note 字段顺序与上位机工具 `tools/send_ui_via_adb.py` 的解析**逐字段对齐**
*       （它按 `body[4:6]`/`[6]`/`[7]`/`[8:12]` 取）。全菜单上线后本函数**长度与
*       顺序都没变** —— 加字段会让它变成 14 字节 body，工具按
*       `18 if sub == 8 else 10` 解析会直接 CRC 对不上。
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
uint8_t ui_status(void)   { return s_state.status; }

/* ---------------------------------------------------------------- 排版 */

void scene_build(void)
{
    const scene_page_t *pg = scene_find(s_state.page_id);
    unsigned page_idx;

    grid_clear();
    if (pg == 0) return;                       /* 命令层已保证不会走到这里 */

    page_idx = scene_index(s_state.page_id);
    if (page_idx >= OSD_RT_PAGES) return;      /* 防御：不应发生 */

    if (pg->page_id == 0x0710u) { render_reticle_adjust(pg, page_idx); return; }

    /* 外框：顶/底横线（-），分隔线（-） */
    grid_fill_row(OSD_ROW_BORDER_TOP,    '-');
    grid_fill_row(OSD_ROW_SEPARATOR,     '-');
    grid_fill_row(OSD_ROW_BORDER_BOTTOM, '-');

    /* 标题居中 */
    grid_put_centered(OSD_ROW_TITLE, title_of(pg));

    /* 窗口：最小移动跟随 sel（与样例文档同规则，Q1）。
     * sel 一定落在 [win, win+vis) 内，所以选中行恒可见；页内条目不足 vis 时
     * win 恒为 0，表现与旧版"从第 0 项画到底"完全一致。 */
    {
        unsigned vis = OSD_MAX_ITEMS;   /* 9 可见行 */
        unsigned win = (s_state.sel < vis) ? 0u : (s_state.sel - vis + 1u);
        unsigned k;

        for (k = 0u; k < vis; k++) {
            unsigned i = win + k;
            unsigned row;
            const scene_item_t *it;

            if (i >= pg->item_count) break;
            row = OSD_ROW_ITEM0 + k;
            it  = &pg->items[i];

            /* 左/右边框 */
            grid_put(row, OSD_COL_BORDER_L, '|');
            grid_put(row, OSD_COL_BORDER_R, '|');

            /* 前缀：当前行按编辑态取 '*' 或 '>'，其余行留空。
             *
             * 上游用 (UI_FLAG_SELECTED | UI_FLAG_EDIT) 这一对位，而现在 bit0 的
             * 含义是"UI 显示"（整块菜单的显隐），与"哪一行是选中行"无关 ——
             * 选中行由 sel 唯一决定。若照搬上游写法，菜单一显示就会所有行都带
             * 选中标记（D11 第 7 项）。*/
            if (i == s_state.sel) {
                grid_put(row, OSD_COL_PREFIX,
                         (s_state.flags & UI_FLAG_EDIT) ? '*' : '>');
                grid_put(row, OSD_COL_PREFIX + 1u, ' ');
            } else {
                grid_put(row, OSD_COL_PREFIX, ' ');
                grid_put(row, OSD_COL_PREFIX + 1u, ' ');
            }

            {
                unsigned wrote = render_value(row, it, page_idx, i);
                unsigned end   = (wrote != 0u) ? OSD_COL_LABEL_END : OSD_COL_VALUE_LAST;
                grid_put_str(row, OSD_COL_LABEL, label_of(it), end);
            }
        }
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
