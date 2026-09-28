/* =============================================================================
 * OSD 引擎实现
 *
 * 链条只有一条：
 *     帧 → protocol_handle → 若"已接受且要渲染" → 选后台块 → 渲染 → 提交
 *        → 发应答（成功的那一支必须排在上面几步之后）
 *
 * 掉电/复位后进 osd_engine_boot()，它把上面的链条走一遍，于是上电就有画面。
 * =============================================================================
 */
#include "osd_engine.h"
#include "canvas.h"
#include "composer.h"
#include "ui.h"
#include "osd_config.h"

static int s_back;          /* 当前后台块（下一次写它） */
static int s_renders;       /* 累计渲染+提交次数 */
static int s_last_deferred; /* 上一次应答是否延迟到提交之后 */

/******************************************************************************
* @brief 渲染当前 UI 状态到后台块并提交。
*
* @note 四步的顺序不能换：
*         1) `canvas_set_visible()` —— 把 flags.bit0 转成菜单承载路的使能位。
*            必须在提交**之前**调用：板级后端在 commit 里把"使能 + 缓冲选择"
*            作为**同一组配置**写下去（D11（六）），分成两次写会多出一次提交，
*            画面上会闪一下。
*         2) 选后台块 —— 前台块正被 RTL 扫描，任何时候都不能写它。
*         3) 渲染 —— 把字符网格展开成 1 bit/像素位图。
*         4) 提交 —— 置位后立即返回，由 RTL 在帧边界整体切换。
*       之后翻转后台块，下一次写另一块。
******************************************************************************/
static void render_and_commit(void)
{
    canvas_set_visible(ui_is_visible());   /* 见上：必须排在 commit 之前 */
    canvas_select_block(s_back);
    composer_render();
    canvas_commit();

    s_back ^= 1;
    s_renders++;
    ui_clear_dirty();
}

void osd_engine_boot(void)
{
    ui_init();

    /* 两块都清零：位图是透明底，只清一块的话另一块上前台时会露出旧内容。 */
    canvas_select_block(0);
    canvas_fill(0U, 0U, (uint32_t)OSD_BLOCK_BYTES);
    canvas_select_block(1);
    canvas_fill(0U, 0U, (uint32_t)OSD_BLOCK_BYTES);

    s_back = 0;
    s_renders = 0;
    s_last_deferred = 0;
    render_and_commit();            /* 上电即有画面（P1 主菜单） */
}

uint8_t osd_engine_handle(protocol_stats_t *stats, const frame_t *frame,
                          protocol_response_t *resp, uint8_t *ack)
{
    uint8_t n;

    s_last_deferred = 0;

    protocol_handle(stats, frame, resp);
    if ((resp->send_ack == 0U) || (ack == 0)) {
        return 0U;
    }

    if (resp->defer_ack != 0U) {
        /* 成功且需要等画布：先把画面做出来、提交掉，再把应答交出去。
         * 失败时 handler 返回 FAIL，defer_ack 为 0，直接走下面那支立即回。 */
        render_and_commit();
        s_last_deferred = 1;
    } else if (ui_is_dirty()) {
        /* 这里覆盖的是"命令被接受但没有要求延迟应答"的情况。当前三条命令里
         * QUERY_VIEW 不改状态、也不会把 dirty 置起来，所以这一支实际上不会
         * 触发；留着它是为了让"状态脏了就渲染"这条不变量在引擎层始终成立，
         * 将来加一条"改了状态但不要求延迟应答"的命令时不会静默丢一帧。*/
        render_and_commit();
    }

    n = resp->ack_len;
    {
        uint8_t i;
        for (i = 0U; i < n; i++) {
            ack[i] = resp->ack[i];
        }
    }
    return n;
}

int osd_engine_render_count(void)  { return s_renders; }
int osd_engine_back_block(void)    { return s_back; }
int osd_engine_last_deferred(void) { return s_last_deferred; }
