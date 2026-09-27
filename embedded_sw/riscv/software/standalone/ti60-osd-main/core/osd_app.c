/* =============================================================================
 * L6 主循环实现
 * =============================================================================
 */
#include "osd_app.h"
#include "platform.h"
#include "proto.h"
#include "dispatch.h"
#include "ui.h"
#include "composer.h"
#include "canvas.h"
#include "osd_config.h"

static int s_back = 0;

static void render_and_commit(void)
{
    scene_build();              /* 状态 → 字符网格 */
    canvas_select_block(s_back);/* 写后台块（前台块正被 RTL 扫描，永不被写） */
    composer_render();          /* 网格 → 像素 */
    canvas_commit();            /* 置位后**立即返回**，不等 ack（C-7） */
    s_back ^= 1;                 /* 翻转：下一次写另一块 */
    ui_clear_dirty();
}

void osd_boot(void)
{
    proto_reset();
    ui_init();

    /* 两块掩膜都整体清零：透明底要求"框外必须恒为 0"，否则会露出旧内容 */
    canvas_select_block(0); canvas_fill(0u, OSD_PIXEL_KEY, (uint32_t)OSD_BLOCK_BYTES);
    canvas_select_block(1); canvas_fill(0u, OSD_PIXEL_KEY, (uint32_t)OSD_BLOCK_BYTES);

    s_back = 0;
    render_and_commit();        /* 上电即有画面：P1 主菜单 */
}

void osd_step(void)
{
    int                 b;
    const uint8_t      *body;
    uint32_t            len;

    while ((b = platform_poll_byte()) >= 0) proto_feed_byte((uint8_t)b);
    while (proto_try_pop(&body, &len)) dispatch_frame(body, len);

    if (ui_is_dirty()) render_and_commit();   /* 无命令 → 无 dirty → 零写入 */
}

int osd_back_block(void) { return s_back; }
