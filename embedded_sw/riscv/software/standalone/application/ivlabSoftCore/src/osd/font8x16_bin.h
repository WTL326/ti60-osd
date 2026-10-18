/* 由 tools/gen_font.py 生成，请勿手改 */
#ifndef FONT8X16_BIN_H
#define FONT8X16_BIN_H

#include <stdint.h>

/* 源字体: PTMono-Regular.ttf */
/* 字号: 12 px  ascent=11 descent=3 em=14 */
/* 布局: 8x16 格，em=14 垂直居中，水平居中 */
/* 位序: 行优先 MSB first，bit7 = 最左像素，每行 1 字节大端 */
#define FONT8X16_COUNT 171

extern const uint16_t font8x16_codepoints[FONT8X16_COUNT];
extern const uint8_t  font8x16_bitmap[FONT8X16_COUNT][16];

#endif /* FONT8X16_BIN_H */
