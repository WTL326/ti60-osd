/* =============================================================================
 * L1 协议层 —— 全部沿用既有帧格式，本轮不改一个字节（整体方案决议 ③）
 *   BB | body_len:u16BE | cat | sub | type | payload | crc16:u16BE | AA
 *   body_len = 3 + len(payload)
 *   CRC16-CCITT: poly 0x1021, init 0x0000, 不取反，覆盖 cat+sub+type+payload
 * =============================================================================
 */
#ifndef OSD_PROTO_H
#define OSD_PROTO_H

#include <stdint.h>
#include "osd_config.h"

uint16_t crc16_ccitt(const uint8_t *d, uint32_t n);

void proto_reset(void);
void proto_feed_byte(uint8_t b);

/* 取出一帧成功时不返回整帧，而是返回 **body**（cat|sub|type|payload）+ 长度，
 * 因为 CRC 与边界已在层内校验完毕，命令层不需要再认识 BB/AA/CRC。 */
int  proto_try_pop(const uint8_t **body, uint32_t *len);

/* 组帧并发送（应答用） */
void proto_tx(uint8_t cat, uint8_t sub, uint8_t type,
              const uint8_t *payload, uint32_t plen);

#endif /* OSD_PROTO_H */
