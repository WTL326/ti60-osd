/* =============================================================================
 * UTF-8 解码 —— i18n 字符串是 UTF-8，网格存 Unicode 码点（u16）
 * 无 libc 依赖；不支持 >U+FFFF 的码点（按无法渲染处理，返回替换码点）。
 * =============================================================================
 */
#ifndef OSD_UTF8_H
#define OSD_UTF8_H

#include <stdint.h>

#define OSD_UTF8_BAD  0xFFFDu   /* 非法字节的替换码点 */

static unsigned osd_utf8_seq_len(unsigned char c)
{
    if (c < 0x80u) return 1u;
    if ((c & 0xE0u) == 0xC0u) return 2u;
    if ((c & 0xF0u) == 0xE0u) return 3u;
    if ((c & 0xF8u) == 0xF0u) return 4u;
    return 0u;                       /* 孤立续字节：非法 */
}

/* 解码 s[0..] 处的一个字符；*adv = 消耗的字节数。
 * 调用方保证至少还剩 1 字节；不足按非法处理（前进 1 字节）。 */
static uint32_t osd_utf8_decode(const unsigned char *s, unsigned remain, unsigned *adv)
{
    unsigned n = osd_utf8_seq_len(s[0]);
    uint32_t cp;

    if (n == 0u || n > remain) { *adv = 1u; return OSD_UTF8_BAD; }
    if (n > 3u) { *adv = n; return OSD_UTF8_BAD; }   /* 超出 BMP：字库不含 */

    switch (n) {
    case 1u: cp = s[0]; break;
    case 2u: cp = ((uint32_t)(s[0] & 0x1Fu) << 6)  | (uint32_t)(s[1] & 0x3Fu); break;
    default: cp = ((uint32_t)(s[0] & 0x0Fu) << 12) | ((uint32_t)(s[1] & 0x3Fu) << 6)
                   | (uint32_t)(s[2] & 0x3Fu); break;
    }
    *adv = n;
    return cp;
}

#endif /* OSD_UTF8_H */
