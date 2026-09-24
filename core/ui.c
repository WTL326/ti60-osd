/* =============================================================================
 * L2 UI 状态机实现
 *
 * 职责边界（规则 2）：**只改状态和 osd_buf，绝不写画布**；渲染由 L6 触发。
 * 唯一例外：调用 scene_build 里的缺字形归一允许查 L3 字库（只读），依据 C-6。
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

static const char *pick(const i18n_t *s)
{
    return (s_state.flags & UI_FLAG_LANG_RU) ? s->ru : s->en;
}

static void grid_clear(void)
{
    unsigned r, c;
    for (r = 0u; r < OSD_GRID_ROWS; r++)
        for (c = 0u; c < OSD_GRID_COLS; c++)
            osd_buf[r][c] = (cell_t)' ';
}

/* 单格写入 + 缺字形归一（C-6）：查不到就地替换 '?' 并计数 */
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

/* 从 start_col 起写字符串，最多写到 end_col（含）；超出即截断 */
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

    /* 被截断：在末列写 '?' 作为可见提示（否则肉眼无法判断是"就这样"还是"被切了"） */
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
    s_state.flags   = 0u;
    s_state.v[0]    = 3u;      /* 默认值取自 UI 规格 P2 原型 */
    s_state.v[1]    = 5u;
    s_state.v[2]    = 7u;
    s_state.v[3]    = 5u;
    s_state.status  = 0u;
    s_state.dirty   = 1u;
    grid_clear();
}

int ui_set_view(uint16_t page_id, uint8_t sel, uint8_t flags)
{
    const scene_page_t *pg = scene_find(page_id);

    /* 统一非法口径（C-4/C-5）：整帧拒绝、状态不变、status.bit1 */
    if (pg == 0)            { s_state.status |= UI_STATUS_BAD_PARAM; return -1; }
    if (sel >= pg->item_count) { s_state.status |= UI_STATUS_BAD_PARAM; return -2; }

    s_state.page_id = page_id;
    s_state.sel     = sel;
    s_state.flags   = (uint8_t)(flags & UI_FLAG_MASK);   /* 保留位忽略、不报错 */
    s_state.dirty   = 1u;
    return 0;
}

int ui_set_image_values(const uint8_t v[4])
{
    unsigned i;
    for (i = 0u; i < 4u; i++) s_state.v[i] = v[i];
    s_state.dirty = 1u;
    return 0;
}

void ui_query_view(uint8_t resp[PROTO_QUERY_RESP_LEN])
{
    const scene_page_t *pg = scene_find(s_state.page_id);
    unsigned i;

    for (i = 0u; i < PROTO_QUERY_RESP_LEN; i++) resp[i] = 0u;

    resp[0] = (uint8_t)(s_state.page_id >> 8);
    resp[1] = (uint8_t)(s_state.page_id & 0xFFu);
    resp[2] = s_state.sel;
    resp[3] = s_state.flags;
    resp[4] = s_state.v[0];
    resp[5] = s_state.v[1];
    resp[6] = s_state.v[2];
    resp[7] = s_state.v[3];
    resp[8] = (pg != 0) ? (uint8_t)pg->item_count : 0u;
    resp[9] = (uint8_t)((s_state.dirty ? UI_STATUS_BUSY : 0u) | s_state.status);
    resp[10] = UI_STATUS_FW_VERSION;
}

int  ui_is_dirty(void)   { return (int)s_state.dirty; }
void ui_clear_dirty(void){ s_state.dirty = 0u; }
void ui_clear_status(void){ s_state.status = 0u; }

/* ---------------------------------------------------------------- 排版 */

void scene_build(void)
{
    const scene_page_t *pg = scene_find(s_state.page_id);
    unsigned i;

    grid_clear();
    if (pg == 0) return;                       /* 命令层已保证不会走到这里 */

    /* 外框：顶/底横线（-），左右边框（|） */
    grid_fill_row(OSD_ROW_BORDER_TOP,    '-');
    grid_fill_row(OSD_ROW_SEPARATOR,     '-');
    grid_fill_row(OSD_ROW_BORDER_BOTTOM, '-');

    /* 标题居中（大写） */
    grid_put_centered(OSD_ROW_TITLE, pick(&pg->title));

    for (i = 0u; i < pg->item_count; i++) {
        unsigned row  = OSD_ROW_ITEM0 + i;
        unsigned end  = (pg->value_slot[i] >= 0) ? OSD_COL_LABEL_END : OSD_COL_VALUE_LAST;

        /* 左/右边框 */
        grid_put(row, OSD_COL_BORDER_L, '|');
        grid_put(row, OSD_COL_BORDER_R, '|');

        /* 前缀："> " 焦点 / "* " 选中·编辑 / 两空格普通 */
        if (i == s_state.sel) {
            char marker = (s_state.flags & (UI_FLAG_SELECTED | UI_FLAG_EDIT)) ? '*' : '>';
            grid_put(row, OSD_COL_PREFIX, (uint32_t)marker);
            grid_put(row, OSD_COL_PREFIX + 1u, ' ');
        } else {
            grid_put(row, OSD_COL_PREFIX, ' ');
            grid_put(row, OSD_COL_PREFIX + 1u, ' ');
        }

        /* 标签（超长截断） */
        grid_put_str(row, OSD_COL_LABEL, pick(&pg->items[i]), end);

        /* 数值（v[slot] 右对齐，到此 set_image_values 才有出口） */
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
