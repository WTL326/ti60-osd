#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""字库生成物自检：font<W>x<H>_bin.{c,h} 必须与 osd_config.h 的字符格约定一致。

## 为什么需要它

字库是**生成物**，而它的形状由两个**互相独立**的数字决定：

    生成端  tools/gen_font.py --box-w 8 --box-h 16
    固件端  src/osd/osd_config.h 的 OSD_GLYPH_W / OSD_GLYPH_H / OSD_GLYPH_BYTES

两边写歪了**不会报任何错**：composer 会按错误的步长/位序去读点阵，现象是画面
花掉或者整体错位，而编译、链接、其余测试全都照样通过。这个脚本把两者钉在一起。

顺带抽查几个字形（'I' 的竖笔、空格的空白、标点非全零）并统计笔画宽度 ——
"所有字形都全零"这类渲染参数写错的后果，就是靠这一条抓出来的
（tools/gen_font.py 里也有同名的 [ink] 体检，两处互为印证）。

用法：
    python tools/test_font_table.py            # 默认查 8×16
    python tools/test_font_table.py --box-w 16 --box-h 16
退出码：0 = 通过，1 = 不一致（会打印具体哪一条）。
"""

import argparse
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
OSD_DIR = ROOT / "embedded_sw" / "riscv" / "software" / "standalone" / "application" / "ivlabSoftCore" / "src" / "osd"

# 字符集应与 tools/gen_font.py 的 build_charset() 一致：ASCII + 西里尔 + 装饰符
EXPECT_MIN_COUNT = 171


def parse_defines(header_text):
    out = {}
    for m in re.finditer(r"^#define\s+(\w+)\s+(\d+)", header_text, re.M):
        out[m.group(1)] = int(m.group(2))
    return out


def parse_bitmap_array(text):
    """抽出 `/* U+XXXX c */ {b0, b1, ...},` 形式的条目 → [(codepoint, [bytes]), ...]"""
    out = []
    for m in re.finditer(r"/\* U\+([0-9A-Fa-f]{4}).*?\*/\s*\{([^}]*)\}", text, re.S):
        cp = int(m.group(1), 16)
        data = [int(x, 16) for x in re.findall(r"0x([0-9A-Fa-f]{2})", m.group(2))]
        out.append((cp, data))
    return out


def ink_bbox(data, box_w, box_h):
    """返回 (min_x, max_x)，无墨迹返回 None。每行 (box_w+7)//8 字节，大端，bit(box_w-1) 最左。"""
    nbytes = (box_w + 7) // 8
    xs = []
    for y in range(box_h):
        row = 0
        for k in range(nbytes):
            row = (row << 8) | data[y * nbytes + k]
        for x in range(box_w):
            if (row >> (box_w - 1 - x)) & 1:
                xs.append(x)
    return (min(xs), max(xs)) if xs else None


def main() -> int:
    ap = argparse.ArgumentParser(description="字库生成物与 osd_config.h 的一致性自检")
    ap.add_argument("--box-w", type=int, default=8)
    ap.add_argument("--box-h", type=int, default=16)
    args = ap.parse_args()

    cfg = parse_defines((OSD_DIR / "osd_config.h").read_text(encoding="utf-8"))
    box = f"font{args.box_w}x{args.box_h}" if args.box_w != args.box_h else f"font{args.box_w}"
    hdr_path, src_path = OSD_DIR / (box + "_bin.h"), OSD_DIR / (box + "_bin.c")
    if not hdr_path.exists() or not src_path.exists():
        print(f"[fail] 找不到 {hdr_path.name} / {src_path.name} —— "
              f"先用 tools/gen_font.py 生成（--box-w {args.box_w} --box-h {args.box_h}）")
        return 1
    hdr = hdr_path.read_text(encoding="utf-8")
    src = src_path.read_text(encoding="utf-8")

    fails = []

    def check(ok, msg):
        print(("  PASS  " if ok else "  FAIL  ") + msg)
        if not ok:
            fails.append(msg)

    print(f"字库自检：{box}_bin  vs  osd_config.h")
    print("-- 字符格约定 --")
    # 1) 生成参数必须等于固件配置：这是本脚本存在的理由
    check(cfg.get("OSD_GLYPH_W") == args.box_w,
          f"OSD_GLYPH_W({cfg.get('OSD_GLYPH_W')}) == --box-w({args.box_w})")
    check(cfg.get("OSD_GLYPH_H") == args.box_h,
          f"OSD_GLYPH_H({cfg.get('OSD_GLYPH_H')}) == --box-h({args.box_h})")

    per_glyph = args.box_h * ((args.box_w + 7) // 8)
    check(cfg.get("OSD_GLYPH_BYTES") == per_glyph,
          f"OSD_GLYPH_BYTES({cfg.get('OSD_GLYPH_BYTES')}) == box_h × ceil(box_w/8) = {per_glyph}")

    # 2) 头文件里的数组维度
    m = re.search(r"bitmap\s*\[\s*\w+\s*\]\s*\[\s*(\d+)\s*\]", hdr)
    check(m is not None and int(m.group(1)) == per_glyph,
          f"头文件数组第二维 == {per_glyph}（实为 {m.group(1) if m else '?'}）")

    hdr_def = parse_defines(hdr)
    count = hdr_def.get(f"{box.upper()}_COUNT")
    check(count is not None and count >= EXPECT_MIN_COUNT,
          f"{box.upper()}_COUNT = {count}（应 ≥ {EXPECT_MIN_COUNT}）")

    print("-- 数据体 --")
    cps = [int(x, 16) for x in re.findall(r"0x([0-9A-Fa-f]{4})",
                                          src.split("};\n\nconst")[0].split("= {")[1])]
    check(count is not None and len(cps) == count,
          f"码点表条数 {len(cps)} == COUNT {count}")
    check(cps == sorted(cps), "码点表升序（font.c 的二分查找依赖它）")
    check(cps == sorted(set(cps)), "码点表无重复")

    glyphs = parse_bitmap_array(src)
    check(len(glyphs) == (count or 0), f"位图条目数 {len(glyphs)} == COUNT {count}")
    check([g[0] for g in glyphs] == cps, "位图顺序与码点表一一对应")
    bad_len = [cp for cp, d in glyphs if len(d) != per_glyph]
    check(not bad_len, f"每个字形 {per_glyph} 字节（异常：{bad_len[:5]}）")

    print("-- 抽查字形与墨迹 --")
    by_cp = dict(glyphs)
    blank = [cp for cp, d in glyphs if not any(d)]
    check(blank == [0x20], f"只有空格是空字形（实际空的：{[hex(c) for c in blank[:6]]}）")

    mi = ink_bbox(by_cp.get(0x49, []), args.box_w, args.box_h)      # 'I'
    check(mi is not None, f"'I'(U+0049) 有墨迹（bbox={mi}）")

    # 墨迹横向居中的不变量：生成器按"墨迹宽度居中"摆放（tools/gen_font.py 的
    # dst_left = (box_w - w) // 2），所以每个字形的墨迹框中心都该落在格子中心附近，
    # 误差只来自整除取整（≤1 px）。把它断言下来，任何"整体左/右移一列"的位序或
    # 取模错误都会在这里露出来 —— 那种错在画面上只表现为"字整体偏了一点"，很难看出来。
    off = []
    for cp, d in glyphs:
        bb = ink_bbox(d, args.box_w, args.box_h)
        if bb is None:
            continue
        center2 = bb[0] + bb[1]                    # 2×中心，避免半像素
        want2 = args.box_w - 1
        if abs(center2 - want2) > 2:
            off.append((cp, bb))
    check(not off,
          f"每个字形的墨迹都横向居中（偏离的：{[(hex(c), b) for c, b in off[:5]]}）")

    widths = []
    for cp, d in glyphs:
        if cp == 0x20:
            continue
        bb = ink_bbox(d, args.box_w, args.box_h)
        if bb:
            widths.append(bb[1] - bb[0] + 1)
    widths.sort()
    med = widths[len(widths) // 2]
    check(med >= 3, f"笔画宽中位数 {med} px ≥ 3（太小说明字号或渲染参数错了）")
    print(f"  ..    笔画宽 min/中位/max = {widths[0]}/{med}/{widths[-1]} px（格宽 {args.box_w}）")

    print("-- 结论 --")
    if fails:
        print(f"FAIL：{len(fails)} 条不一致")
        return 1
    print("PASS：字库与 osd_config.h 一致")
    return 0


if __name__ == "__main__":
    sys.exit(main())
