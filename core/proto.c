/* =============================================================================
 * L1 协议实现 —— 成帧状态机 + CRC16 + 4 深帧队列
 * 不用动态内存；body 超长（> PROTO_BODY_MAX）即丢弃该帧。
 * =============================================================================
 */
#include "proto.h"
#include "platform.h"
#include "osd_config.h"

uint16_t crc16_ccitt(const uint8_t *d, uint32_t n)
{
    uint16_t crc = 0x0000u;
    uint32_t i;

    for (i = 0u; i < n; i++) {
        uint8_t b;
        crc ^= (uint16_t)((uint16_t)d[i] << 8);
        for (b = 0u; b < 8u; b++) {
            crc = (crc & 0x8000u) ? (uint16_t)((uint16_t)(crc << 1) ^ 0x1021u)
                                  : (uint16_t)(crc << 1);
        }
    }
    return crc;
}

/* ---------------------------------------------------------------- 状态机 */

typedef enum { ST_SOF = 0, ST_LEN_HI, ST_LEN_LO, ST_BODY, ST_CRC_HI, ST_CRC_LO, ST_EOF } rx_st_t;

static rx_st_t  s_st  = ST_SOF;
static uint32_t s_len = 0u;        /* body_len */
static uint32_t s_idx = 0u;
static uint8_t  s_len_hi;
static uint16_t s_crc;
static uint8_t  s_body[PROTO_BODY_MAX];

/* 帧队列（单生产者/单消费者，深度 4） */
static uint8_t  s_q[PROTO_QUEUE_DEPTH][PROTO_BODY_MAX];
static uint32_t s_q_len[PROTO_QUEUE_DEPTH];
static unsigned s_rd = 0u, s_wr = 0u;

void proto_reset(void)
{
    s_st = ST_SOF; s_len = 0u; s_idx = 0u; s_crc = 0u;
    s_rd = 0u; s_wr = 0u;
}

static void q_push(void)
{
    unsigned next = (unsigned)((s_wr + 1u) % PROTO_QUEUE_DEPTH);
    if (next == s_rd) return;                      /* 队列满：丢弃最新帧 */
    s_q_len[s_wr] = s_len;
    {
        uint32_t i;
        for (i = 0u; i < s_len && i < PROTO_BODY_MAX; i++) s_q[s_wr][i] = s_body[i];
    }
    s_wr = next;
    s_len = 0u;
}

int proto_try_pop(const uint8_t **body, uint32_t *len)
{
    if (s_rd == s_wr) return 0;
    *body = s_q[s_rd];
    *len  = s_q_len[s_rd];
    s_rd = (unsigned)((s_rd + 1u) % PROTO_QUEUE_DEPTH);
    return 1;
}

void proto_feed_byte(uint8_t b)
{
    switch (s_st) {
    case ST_SOF:
        if (b == PROTO_SOF) s_st = ST_LEN_HI;
        break;

    case ST_LEN_HI:
        s_len_hi = b;
        s_st = ST_LEN_LO;
        break;

    case ST_LEN_LO:
        s_len = ((uint32_t)s_len_hi << 8) | (uint32_t)b;
        if (s_len < 3u || s_len > PROTO_BODY_MAX) { proto_reset(); break; }  /* 非法长度 */
        s_idx = 0u;
        s_st = ST_BODY;
        break;

    case ST_BODY:
        s_body[s_idx++] = b;
        if (s_idx == s_len) { s_crc = crc16_ccitt(s_body, s_len); s_st = ST_CRC_HI; }
        break;

    case ST_CRC_HI:
        if (b != (uint8_t)(s_crc >> 8)) { proto_reset(); break; }   /* CRC 不符：整帧丢弃 */
        s_st = ST_CRC_LO;
        break;

    case ST_CRC_LO:
        if (b != (uint8_t)(s_crc & 0xFFu)) { proto_reset(); break; }
        s_st = ST_EOF;
        break;

    case ST_EOF:
        if (b == PROTO_EOF) q_push();              /* 收尾正确才入队 */
        else proto_reset();
        s_st = ST_SOF;
        break;

    default:
        proto_reset();
        break;
    }
}

/* ---------------------------------------------------------------- 发送 */

void proto_tx(uint8_t cat, uint8_t sub, uint8_t type,
              const uint8_t *payload, uint32_t plen)
{
    uint8_t  frame[PROTO_FRAME_MAX];
    uint32_t body_len = plen + 3u;
    uint16_t crc;
    uint32_t k = 0u, i;

    if (body_len > PROTO_BODY_MAX) return;

    frame[k++] = PROTO_SOF;
    frame[k++] = (uint8_t)(body_len >> 8);
    frame[k++] = (uint8_t)(body_len & 0xFFu);
    frame[k++] = cat;
    frame[k++] = sub;
    frame[k++] = type;
    for (i = 0u; i < plen; i++) frame[k++] = payload[i];

    crc = crc16_ccitt(&frame[3], body_len);        /* 覆盖 cat..payload */
    frame[k++] = (uint8_t)(crc >> 8);
    frame[k++] = (uint8_t)(crc & 0xFFu);
    frame[k++] = PROTO_EOF;

    platform_send(frame, k);
}
