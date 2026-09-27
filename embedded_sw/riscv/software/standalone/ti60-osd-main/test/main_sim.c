/* =============================================================================
 * PC 仿真主程序（sim 目标专属）
 * 覆盖：CRC 向量 / 示例帧 / 非法参数 / 语言切换 / 数值右对齐 / QUERY 回环
 * 产物：osd/test/out/*.ppm（golden 比对）+ 网格文本 dump（直接 diff）
 * =============================================================================
 */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#include "../core/osd_app.h"
#include "../core/osd_config.h"
#include "../core/proto.h"
#include "../core/ui.h"
#include "../core/platform.h"
#include "../core/canvas.h"

static int s_pass = 0, s_fail = 0;

static void expect(int cond, const char *name)
{
    if (cond) { s_pass++; printf("  [PASS] %s\n", name); }
    else      { s_fail++; printf("  [FAIL] %s\n", name); }
}

static void dump_grid(const char *tag)
{
    char buf[1600];
    osd_grid_dump(buf, sizeof(buf));
    printf("---- grid dump: %s ----\n%s", tag, buf);
    {
        char path[128];
        FILE *f;
        sprintf(path, "test/out/dump_%s.txt", tag);
        f = fopen(path, "wb");
        if (f) { fputs(buf, f); fclose(f); }
    }
}

static void flush_ppm(const char *name)
{
    char path[128];
    sprintf(path, "test/out/%s.ppm", name);
    canvas_flush(path);
    printf("  [ppm ] %s\n", path);
}

/* 组一条 SET_VIEW 命令帧并注入 */
static void inject_set_view(uint16_t page_id, uint8_t sel, uint8_t flags)
{
    uint8_t f[13];
    uint16_t crc;
    uint8_t body[7] = {
        PROTO_CAT_UI, PROTO_SUB_SET_VIEW, 0x00u,
        (uint8_t)(page_id >> 8), (uint8_t)(page_id & 0xFFu), sel, flags
    };
    crc = crc16_ccitt(body, 7u);

    f[0] = PROTO_SOF;
    f[1] = 0x00; f[2] = 0x07;
    memcpy(&f[3], body, 7);
    f[10] = (uint8_t)(crc >> 8);
    f[11] = (uint8_t)(crc & 0xFFu);
    f[12] = PROTO_EOF;
    platform_rx_inject(f, 13u);
}

static void inject_set_values(const uint8_t v[4])
{
    uint8_t f[13];
    uint16_t crc;
    uint8_t body[7] = { PROTO_CAT_UI, PROTO_SUB_SET_IMG_VALUES, 0x00u, v[0], v[1], v[2], v[3] };
    crc = crc16_ccitt(body, 7u);

    f[0] = PROTO_SOF;
    f[1] = 0x00; f[2] = 0x07;
    memcpy(&f[3], body, 7);
    f[10] = (uint8_t)(crc >> 8);
    f[11] = (uint8_t)(crc & 0xFFu);
    f[12] = PROTO_EOF;
    platform_rx_inject(f, 13u);
}

static void inject_query(void)
{
    uint8_t f[10];
    uint16_t crc;
    uint8_t body[3] = { PROTO_CAT_UI, PROTO_SUB_QUERY_VIEW, 0x00u };
    crc = crc16_ccitt(body, 3u);

    f[0] = PROTO_SOF;
    f[1] = 0x00; f[2] = 0x03;
    memcpy(&f[3], body, 3);
    f[6] = (uint8_t)(crc >> 8);
    f[7] = (uint8_t)(crc & 0xFFu);
    f[8] = PROTO_EOF;
    f[9] = 0; (void)f[9];
    platform_rx_inject(f, 9u);
}

int main(void)
{
    uint8_t resp[PROTO_QUERY_RESP_LEN];
    uint8_t vec[7] = { 0x04, 0x06, 0x00, 0x00, 0x00, 0x00, 0x01 };
    static const uint8_t example[13] = {
        0xBB, 0x00, 0x07, 0x04, 0x06, 0x00, 0x00, 0x00, 0x00, 0x01, 0x5C, 0x06, 0xAA
    };

    printf("=== TI60 OSD sim ===\n");

    /* [T1] CRC16-CCITT 已知向量 */
    expect(crc16_ccitt(vec, 7u) == 0x5C06u, "T1 CRC 向量 5C06");

    /* [T2] 上电：直接渲染 P1 EN */
    osd_boot();
    expect(g_font_miss_count == 0u, "T2 字库全覆盖（miss=0）");
    expect(osd_buf[1][12] == 'M' && osd_buf[1][20] == 'U' && osd_buf[1][11] == ' ',
           "T2 标题居中 MAIN MENU");
    expect(osd_buf[3][0] == '|' && osd_buf[3][1] == '>' && osd_buf[3][2] == ' '
           && osd_buf[3][3] == 'I', "T2 焦点前缀 |> Image Setting");
    expect(osd_buf[3][33] == '|' && osd_buf[0][0] == '-', "T2 外框");
    dump_grid("01_p1_en");
    flush_ppm("01_p1_en");

    /* [T3] 示例帧（设计文档 §7）：page=0 sel=0 flags=1 */
    proto_reset();
    platform_rx_inject(example, 13u);
    osd_step();
    ui_query_view(resp);
    expect(resp[0] == 0 && resp[1] == 0 && resp[2] == 0 && resp[3] == 0x01,
           "T3 示例帧生效 page=0 sel=0 flags=1");

    /* [T4] 非法 page_id → 统一非法口径 */
    ui_clear_status();
    inject_set_view(0x9999u, 0u, 0u);
    osd_step();
    ui_query_view(resp);
    expect((resp[9] & UI_STATUS_BAD_PARAM) != 0u && resp[0] == 0 && resp[1] == 0,
           "T4 未知 page_id 判非法且状态不变");

    /* [T5] sel 越界（P1 有 9 项，sel=9 非法） */
    ui_clear_status();
    inject_set_view(0x0000u, 9u, 0u);
    osd_step();
    ui_query_view(resp);
    expect((resp[9] & UI_STATUS_BAD_PARAM) != 0u && resp[2] == 0u,
           "T5 sel 越界判非法且焦点不变");

    /* [T6] QUERY_VIEW 应答回环：应答字节喂回解析器，应解出同字段 */
    {
        const uint8_t *body;
        uint32_t len, i;
        int got = 0;
        proto_reset();
        platform_tx_reset();
        inject_query();
        osd_step();                       /* 产生应答 → g_plat_tx */
        /* 帧长 = SOF(1)+len(2)+body(3+14)+crc(2)+EOF(1) = 23 = RESP_LEN + 9 */
        expect(g_plat_tx_len == PROTO_QUERY_RESP_LEN + 9u,
               "T6 QUERY 有应答且长度=1+2+17+2+1=23");
        /* 回环：把应答字节原样喂回解析器。
         * 注意这里**不能**走 osd_step()，它会自己把帧 pop 掉并 dispatch；
         * 测试要验证的是"帧格式自洽"，所以只驱动协议层。 */
        proto_reset();
        for (i = 0u; i < g_plat_tx_len; i++) proto_feed_byte(g_plat_tx[i]);
        while (proto_try_pop(&body, &len)) {
            int okf = (len == 3u + PROTO_QUERY_RESP_LEN
                       && body[0] == PROTO_CAT_UI
                       && body[1] == PROTO_SUB_QUERY_VIEW
                       && body[3] == 0x00 && body[4] == 0x00    /* page 0 */
                       && body[11] == 9u);                       /* item_count=9 */
            if (okf) got = 1;
        }
        expect(got, "T6 应答回环解出一致字段");
    }

    /* [T7] 俄语：flags.bit2 → 文案切换，字库仍全覆盖 */
    inject_set_view(0x0000u, 0u, UI_FLAG_LANG_RU);
    osd_step();
    expect(osd_buf[1][11] == 0x0413u /* 'Г' */, "T7 俄语标题 ГЛАВНОЕ МЕНЮ 居中");
    expect(osd_buf[3][3] == 0x041Du /* 'Н' */, "T7 俄语首项 Настройки изображения");
    expect(g_font_miss_count == 0u, "T7 俄文字形全覆盖");
    dump_grid("02_p1_ru");
    flush_ppm("02_p1_ru");

    /* [T8] P2 数值页：value_slot 右对齐（[8] 结束于 col32） */
    inject_set_view(0x0100u, 0u, 0u);
    {
        uint8_t v[4] = { 8u, 6u, 4u, 2u };
        inject_set_values(v);
    }
    osd_step();
    expect(osd_buf[3][30] == '[' && osd_buf[3][31] == '8' && osd_buf[3][32] == ']',
           "T8 数值 [8] 右对齐 col30..32");
    expect(osd_buf[7][32] == ' ' && osd_buf[7][3] == 'P', "T8 纯标签行无数值（PIP）");
    expect(g_font_miss_count == 0u, "T8 P2 字形全覆盖");
    dump_grid("03_p2_values");
    flush_ppm("03_p2_values");

    /* [T9] 帧格式鲁棒性：CRC 坏帧必须被丢弃（状态不受影响） */
    {
        uint8_t bad[13];
        memcpy(bad, example, 13);
        bad[10] ^= 0xFFu;
        ui_clear_status();
        proto_reset();
        platform_rx_inject(bad, 13u);
        osd_step();
        ui_query_view(resp);
        expect((resp[9] & UI_STATUS_BAD_PARAM) == 0u && resp[2] == 0u,
               "T9 CRC 坏帧被丢弃");
    }

    printf("\n=== result: %d passed, %d failed ===\n", s_pass, s_fail);
    return (s_fail == 0) ? 0 : 1;
}
