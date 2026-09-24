/* =============================================================================
 * 平台抽象 —— 串行收发与调试输出。
 * 由 port/canvas_*.c 与 canvas_* 一起实现（同一份文件提供两个层次，
 * 保持"文件级替换"的后端切换语义：一次链接只放其中一个文件）。
 * =============================================================================
 */
#ifndef OSD_PLATFORM_H
#define OSD_PLATFORM_H

#include <stdint.h>

/* 非阻塞取一个字节；无数据返回 -1 */
int  platform_poll_byte(void);

/* 发送若干字节（UART TX） */
void platform_send(const uint8_t *buf, uint32_t len);

/* 调试输出（PC=stdout，板级=调试串口，可空实现） */
void platform_debug(const char *s);

/* 主机端接收缓冲（PC 下用于回环自检；板级恒空） */
extern uint8_t  g_plat_tx[256];
extern uint32_t g_plat_tx_len;
void platform_tx_reset(void);

/* PC 后端专用：向 RX 队列注入字节（测试驱动串口输入）；板级为空实现 */
void platform_rx_inject(const uint8_t *buf, uint32_t len);

#endif /* OSD_PLATFORM_H */
