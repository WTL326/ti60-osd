#include "dispatch.h"
#include "proto.h"
#include "ui.h"
#include "osd_config.h"

/* SET_VIEW payload: page_id u16BE | sel u8 | flags u8 */
static int handle_set_view(const uint8_t *p, uint32_t n)
{
    uint16_t page_id;
    if (n != 4u) return -1;
    page_id = (uint16_t)(((uint16_t)p[0] << 8) | p[1]);
    return ui_set_view(page_id, p[2], p[3]);
}

void dispatch_frame(const uint8_t *body, uint32_t body_len)
{
    uint8_t  cat, sub, type;
    const uint8_t *payload;
    uint32_t plen;
    uint8_t  resp[PROTO_QUERY_RESP_LEN];

    if (body_len < 3u) return;             /* 短帧：直接丢弃 */
    cat = body[0];
    sub = body[1];
    type = body[2];
    payload = &body[3];
    plen = body_len - 3u;

    if (cat != PROTO_CAT_UI) return;       /* 非 UI 类：不认识，忽略 */

    switch (sub) {
    case PROTO_SUB_SET_VIEW:
        (void)handle_set_view(payload, plen);
        break;

    case PROTO_SUB_SET_IMG_VALUES:
        if (plen != 4u) return;            /* 长度不符即非法 */
        (void)ui_set_image_values(payload);
        break;

    case PROTO_SUB_QUERY_VIEW:
        ui_query_view(resp);
        proto_tx(PROTO_CAT_UI, PROTO_SUB_QUERY_VIEW, type, resp, PROTO_QUERY_RESP_LEN);
        break;

    default:
        return;                            /* 未知 sub：忽略 */
    }
}
