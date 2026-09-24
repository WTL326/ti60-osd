/* 由 tools/gen_font.py 生成，请勿手改 */
#ifndef FONT16_BIN_H
#define FONT16_BIN_H

#include <stdint.h>

/* 源字体: PTMono-Regular.ttf */
/* 字号: 12 px  ascent=11 descent=3 em=14 */
/* 布局: 16x16 格，em=14 垂直居中，水平居中 */
/* 位序: 行优先 MSB first，bit15 = 最左像素，每行 2 字节大端 */
#define FONT16_COUNT 171

extern const uint16_t font16_codepoints[FONT16_COUNT];
extern const uint8_t  font16_bitmap[FONT16_COUNT][32];

#endif /* FONT16_BIN_H */
