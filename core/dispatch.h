/* =============================================================================
 * 命令派发 —— 校验帧 → 调 L2 → 组织应答
 * 统一非法口径（C-4 确立）：任何参数非法 → 整帧丢弃、状态不变、status.bit1 = 1
 * =============================================================================
 */
#ifndef OSD_DISPATCH_H
#define OSD_DISPATCH_H

#include <stdint.h>

void dispatch_frame(const uint8_t *body, uint32_t body_len);

#endif /* OSD_DISPATCH_H */
