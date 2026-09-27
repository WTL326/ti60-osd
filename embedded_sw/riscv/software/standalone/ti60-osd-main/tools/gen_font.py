#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TI60 OSD — 离线取模生成器（阶段 A）

源字体 → osd/generated/font16_bin.{h,c}
    16×16 字符格 / em=14 垂直居中 / 1bpp / 行优先 / 每行 2 字节大端 / bit15 = 最左像素
    → const uint16_t font16_codepoints[N]  (升序，供二分查找)
    → const uint8_t  font16_bitmap[N][32]

附带：
    1) cmap 覆盖率体检（缺字形 → 构建失败，配合 --strict）
    2) 字形总览图 tools/out/font_preview.png（目检：是否在 16×16 格内被切或者有镜像）

默认字体优先级：
    assets/PTMono-Regular.ttf  →  DejaVuSansMono.ttf  →  系统 Consolas（**仅可自测，
    禁止随固件分发**：Microsoft 字体非开源；量产必须用 PT Mono / OFL）
"""
import os
import sys
import argparse

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit("需要 Pillow：pip install Pillow")

try:
    from fontTools.ttLib import TTFont
except ImportError:
    TTFont = None

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
GEN_DIR = os.path.join(ROOT, "generated")
OUT_DIR = os.path.join(HERE, "out")

BOX = 16            # 字符格 16×16
EM_TARGET = 14      # em=14（格内上下各留 1 px，俄文下降部不会被切）


# --------------------------------------------------------------------------
def build_charset(extra_symbols=True):
    cps = []
    cps += list(range(0x20, 0x7F))              # ASCII 可打印 95
    cps += list(range(0x410, 0x450))            # 西里尔 А-я 64
    cps += [0x401, 0x451]                       # Ё ё
    if extra_symbols:
        cps += list(map(ord, "°×•→←▲▼≥≤±"))
    seen, out = set(), []
    for c in cps:
        if c not in seen:
            seen.add(c)
            out.append(c)
    return sorted(out)


def resolve_font(user_font):
    if user_font:
        if not os.path.exists(user_font):
            sys.exit("字体不存在: %s" % user_font)
        return user_font, "user"
    candidates = [
        (os.path.join(ROOT, "assets", "PTMono-Regular.ttf"), "PT Mono (OFL)"),
        (os.path.join(ROOT, "assets", "DejaVuSansMono.ttf"), "DejaVu Sans Mono"),
        (r"C:\Windows\Fonts\consola.ttf", "Consolas（自测用，禁止分发）"),
        (r"C:\Windows\Fonts\cour.ttf", "Courier New（自测用，禁止分发）"),
    ]
    for path, tag in candidates:
        if os.path.exists(path):
            return path, tag
    sys.exit("没有可用字体，请用 --font 指定 TTF")


def coverage(font_path, cps):
    """返回该字体缺失的码点列表。没有 fontTools 时返回 []（跳过体检）。"""
    if TTFont is None:
        return []
    ttf = TTFont(font_path, fontNumber=0, lazy=True)
    cmap = set(ttf.getBestCmap().keys())
    return [c for c in cps if c not in cmap]


def pick_size(font_path, cps, em_target=EM_TARGET, box=BOX):
    """挑**最大**字号，使该字号的自然 em(ascent+descent) ≤ em_target，
    且所有字形墨迹高 ≤ em_target、宽 ≤ box。
    不做事后缩放：按字体的原生 metrics 定位基线，字形之间才不会相对漂移。"""
    for size in range(30, 6, -1):
        try:
            f = ImageFont.truetype(font_path, size)
        except Exception:
            continue
        asc, desc = f.getmetrics()
        em = asc + desc
        if em > em_target:                       # 硬约束：整个 em 盒要装进目标高度
            continue
        ok = True
        for cp in cps:
            bbox = f.getbbox(chr(cp))
            if bbox is None:
                continue
            if (bbox[2] - bbox[0]) > box or (bbox[3] - bbox[1]) > em_target:
                ok = False
                break
        if ok:
            return (size, asc, desc, em)
    return None


def render_glyph(f, ch, size_info):
    """返回 16×16 的 list[list[int]]（0/1）。"""
    size, asc, desc, em = size_info
    pad = 24
    img = Image.new("L", (BOX * 3, BOX * 3), 0)
    ImageDraw.Draw(img).text((pad, pad), ch, font=f, fill=255)
    ink = img.getbbox()
    if ink is None:
        return [[0] * BOX for _ in range(BOX)], 0

    # em 盒在 16 行格内垂直居中 → 基线所在行 = top_pad + ascent
    top_pad = (BOX - (asc + desc)) // 2
    baseline = top_pad + asc

    # 默认 anchor = 'la'（左·ascender 线），绘制原点 y=pad 即 ascender 线，
    # 故墨迹相对基线的偏移 = ink_top - (pad + asc)：
    dst_top = baseline + (ink[1] - (pad + asc))
    dst_left = (BOX - (ink[2] - ink[0])) // 2

    crop = img.crop(ink)
    target = Image.new("L", (BOX, BOX), 0)
    target.paste(crop, (dst_left, dst_top))

    px = target.load()
    grid = [[1 if px[x, y] > 110 else 0 for x in range(BOX)] for y in range(BOX)]

    # 溢出检测：墨迹是否被格边界切掉
    overflow = 0
    if dst_top < 0 or dst_top + (ink[3] - ink[1]) > BOX:
        overflow = 1
    if dst_left < 0 or dst_left + (ink[2] - ink[0]) > BOX:
        overflow = 1
    return grid, overflow


def pack_rows(grid):
    data = []
    for y in range(BOX):
        bits = 0
        for x in range(BOX):
            if grid[y][x]:
                bits |= 1 << (BOX - 1 - x)     # bit15 = 最左像素
        data.append((bits >> 8) & 0xFF)
        data.append(bits & 0xFF)
    return data


def write_binary(cps, grids, meta_lines):
    os.makedirs(GEN_DIR, exist_ok=True)
    n = len(cps)

    with open(os.path.join(GEN_DIR, "font16_bin.h"), "w", encoding="utf-8") as fp:
        fp.write("/* 由 tools/gen_font.py 生成，请勿手改 */\n")
        fp.write("#ifndef FONT16_BIN_H\n#define FONT16_BIN_H\n\n")
        fp.write("#include <stdint.h>\n\n")
        for line in meta_lines:
            fp.write("/* %s */\n" % line)
        fp.write("#define FONT16_COUNT %d\n\n" % n)
        fp.write("extern const uint16_t font16_codepoints[FONT16_COUNT];\n")
        fp.write("extern const uint8_t  font16_bitmap[FONT16_COUNT][32];\n\n")
        fp.write("#endif /* FONT16_BIN_H */\n")

    with open(os.path.join(GEN_DIR, "font16_bin.c"), "w", encoding="utf-8") as fp:
        fp.write("/* 由 tools/gen_font.py 生成，请勿手改 */\n")
        fp.write('#include "font16_bin.h"\n\n')
        fp.write("const uint16_t font16_codepoints[FONT16_COUNT] = {\n")
        for i in range(0, n, 12):
            fp.write("    " + ", ".join("0x%04X" % c for c in cps[i:i + 12]) + ",\n")
        fp.write("};\n\n")
        fp.write("const uint8_t font16_bitmap[FONT16_COUNT][32] = {\n")
        for i, cp in enumerate(cps):
            data = pack_rows(grids[i])
            line = ", ".join("0x%02X" % b for b in data)
            fp.write("    /* U+%04X %s */ {%s},\n" % (cp, chr(cp) if cp >= 0x20 else "?", line))
        fp.write("};\n")


def write_preview(cps, grids, cols=24, cell=24):
    os.makedirs(OUT_DIR, exist_ok=True)
    rows = (len(cps) + cols - 1) // cols
    W, H = cols * cell, rows * cell
    img = Image.new("RGB", (W, H), (18, 18, 20))
    d = ImageDraw.Draw(img)
    for i, cp in enumerate(cps):
        ox, oy = (i % cols) * cell, (i // cols) * cell
        d.rectangle([ox, oy, ox + cell - 1, oy + cell - 1], outline=(40, 40, 46))
        for y in range(BOX):
            for x in range(BOX):
                if grids[i][y][x]:
                    d.rectangle([ox + x, oy + y + 4, ox + x, oy + y + 4], fill=(235, 235, 235))
    path = os.path.join(OUT_DIR, "font_preview.png")
    img.save(path)
    return path


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--font", default=None, help="TTF 路径（默认按优先级自动挑选）")
    ap.add_argument("--strict", action="store_true", help="存在缺字形时以非零码退出（CI 门禁）")
    ap.add_argument("--no-symbols", action="store_true", help="字符集不含装饰符号")
    args = ap.parse_args()

    font_path, tag = resolve_font(args.font)
    cps = build_charset(extra_symbols=not args.no_symbols)
    print("[font ] %s  (%s)" % (font_path, tag))

    missing = coverage(font_path, cps)
    print("[cover] 目标 %d 字形，字体缺失 %d 个" % (len(cps), len(missing)))
    if missing:
        print("[cover] 缺失清单: " + ", ".join("U+%04X %s" % (c, chr(c)) for c in missing))
        print("[cover] 提示: PT 系列不保证覆盖 Arrows/Geometric Shapes 区；"
              "UI 文案请用 ASCII 替代（-> 代替 →）或从同授权字体补字形。")

    keep = [c for c in cps if c not in missing]
    if not keep:
        sys.exit("全部字形缺失，终止")

    info = pick_size(font_path, keep)
    if info is None:
        sys.exit("找不到合适字号")
    size, asc, desc, em = info
    print("[size ] %d px  (ascent=%d descent=%d em=%d → 目标 %d)"
          % (size, asc, desc, em, EM_TARGET))

    f = ImageFont.truetype(font_path, size)
    grids, clipped = [], []
    for cp in keep:
        g, ov = render_glyph(f, chr(cp), info)
        grids.append(g)
        if ov:
            clipped.append(cp)

    meta = [
        "源字体: %s" % os.path.basename(font_path),
        "字号: %d px  ascent=%d descent=%d em=%d" % (size, asc, desc, em),
        "布局: 16x16 格，em=%d 垂直居中，水平居中" % EM_TARGET,
        "位序: 行优先 MSB first，bit15 = 最左像素，每行 2 字节大端",
    ]
    write_binary(keep, grids, meta)
    prev = write_preview(keep, grids)

    print("[out  ] %s  (%d 字形 × 32 B = %d B)"
          % (os.path.join(GEN_DIR, "font16_bin.c"), len(keep), len(keep) * 32))
    print("[out  ] %s  （字形总览图，务必目检）" % prev)
    if clipped:
        print("[warn ] 被 16×16 格裁切的字形 %d 个: %s"
              % (len(clipped), ", ".join("U+%04X" % c for c in clipped)))
    else:
        print("[ok   ] 无字形被裁切")

    if args.strict and missing:
        print("[fail ] --strict：存在缺字形，构建失败")
        sys.exit(2)
    if args.strict and clipped:
        print("[fail ] --strict：存在被裁切字形，构建失败")
        sys.exit(3)


if __name__ == "__main__":
    main()
