#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""OSD 字库离线取模生成器 —— TTF → osd/font<W>x<H>_bin.{h,c}

为什么要有它（而不是一份手写的字库表）：
  字库是**生成物**，就和 `tools/make_test_bitmap.py` 造的那张位图一样 —— 生成器
  在库里、参数写清楚，同一份输入必然产出同一份数据，改字号/改格子只改参数。

来源：上游 `ti60-osd-main/tools/gen_font.py`（16×16 版）收编并参数化。
**它必须能重现仓库里那份 16×16 字库**，这是它没写错的最硬证据：
    python tools/gen_font.py --box-w 16 --box-h 16 --em 14 --out-dir <临时目录>
    与 firmware 的 src/osd/font16_bin.c 逐字节比对（tools/test_font_table.py 会做）。

## 为什么宽度和高度是两个参数

等宽字体的宽高比约 0.6，正方形格子（如 8×8）装不进这个比例：要把 8 px 的格宽
填满，字号得大到字高约 13 px，那又超出 8 px 的格高。16×16 的菜单之所以"字与字
之间空一大截"（笔画 6 px、格宽 16 px），根子就是这个几何矛盾。所以本工具把宽高
分开：**8 宽 × 12 高**这类比例才能既填满宽度、又把菜单压矮。

## 输出格式（与固件的 `font.c` 约定一致）

    每字形 BOX_H 行，行优先；每行 (BOX_W+7)//8 字节，**大端**；
    行内 **bit(BOX_W-1) = 最左像素**。BOX_W=8 时每行 1 字节、bit7 最左 ——
    正好等于 1 bit/像素位图的位序，composer 因此不需要任何移位。
    码点表升序（供 font.c 二分查找），位图数组与码点表一一对应。

用法：
    pip install Pillow                       # 唯一硬依赖
    python tools/gen_font.py --box-w 8 --box-h 12 --em 11 --strict
    然后**目检** tools/out/font_preview.png（小字号下字形能不能认，只有人眼能判）

默认字体：tools/assets/PTMono-Regular.ttf（OFL，随仓库分发，许可文件在旁边）。
回退到系统 Consolas/Courier 只为自测 —— 微软字体不可随固件分发。
"""

import argparse
import os
import sys

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
DEFAULT_OUT = os.path.join(ROOT, "embedded_sw", "riscv", "software", "standalone",
                           "application", "ivlabSoftCore", "src", "osd")
OUT_DIR = os.path.join(HERE, "out")     # 预览图；tools/.gitignore 已排除 out/

BOX_W = 8           # 字符格宽（像素）—— 决定行跨距 = 列数 × BOX_W / 8 字节
BOX_H = 12          # 字符格高（像素）—— 决定画布高 = 行数 × BOX_H
EM_TARGET = 11      # em 盒目标高度（≤ BOX_H）


# --------------------------------------------------------------------------
def build_charset(extra_symbols=True):
    """字符集：与上游一致（171 个码点）。

    为什么含西里尔：菜单文案上游是俄文；字库少了它，整片会渲染成 '?'。
    """
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
    """按优先级挑字体。仓内 OFL 字体优先，系统字体只作自测回退。"""
    if user_font:
        if not os.path.exists(user_font):
            sys.exit("字体不存在: %s" % user_font)
        return user_font, "user"
    candidates = [
        (os.path.join(HERE, "assets", "PTMono-Regular.ttf"), "PT Mono (OFL, 仓内)"),
        (os.path.join(ROOT, "embedded_sw", "riscv", "software", "standalone",
                      "ti60-osd-main", "assets", "PTMono-Regular.ttf"),
         "PT Mono (OFL, 上游参考树)"),
        (r"C:\Windows\Fonts\consola.ttf", "Consolas（自测用，禁止随固件分发）"),
        (r"C:\Windows\Fonts\cour.ttf", "Courier New（自测用，禁止随固件分发）"),
    ]
    for path, tag in candidates:
        if os.path.exists(path):
            return path, tag
    sys.exit("没有可用字体，请用 --font 指定 TTF")


def coverage(font_path, cps):
    """该字体缺失的码点列表。没有 fontTools 时返回 []（跳过体检）。"""
    if TTFont is None:
        return []
    ttf = TTFont(font_path, fontNumber=0, lazy=True)
    cmap = set(ttf.getBestCmap().keys())
    return [c for c in cps if c not in cmap]


def pick_size(font_path, cps, em_target, box_w):
    """挑**最大**字号，使该字号的自然 em(ascent+descent) ≤ em_target，
    且所有字形墨迹高 ≤ em_target、宽 ≤ box_w。

    为什么这么挑：按字体原生 metrics 定位基线，字形之间才不会相对漂移；
    再大就装不进格子的高度预算。
    搜索下限取到 3：小格子（8×12 / em=11）合适的字号会落到 6～9 这一带，
    上游 16×16 版的 `range(30, 6, -1)` 够不到 —— 这是本工具的参数化点之一。
    """
    for size in range(40, 2, -1):
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
            if (bbox[2] - bbox[0]) > box_w or (bbox[3] - bbox[1]) > em_target:
                ok = False
                break
        if ok:
            return (size, asc, desc, em)
    return None


def render_glyph(f, ch, size_info, box_w, box_h, stretch=0):
    """把单个字符渲染成 BOX_W×BOX_H 的 0/1 网格，并报告是否被格边界裁切。

    定位方式（与上游一致，别改）：先按 em 盒在格内垂直居中算出基线，再把墨迹
    按"相对基线的偏移"贴进去 —— 这样大写、下降部、变音符号之间的相对高度才正确。
    水平方向按墨迹宽度居中（stretch 时改为拉宽填满）。
    """
    size, asc, desc, em = size_info
    # 画布 3×格子见方，字形从 (pad, pad) 起画。pad **必须随格子缩放**：
    # 上游 16×16 时代 pad=24 恰好合适，但格子变小后字形会被画到画布外面去 ——
    # 现象是 getbbox() 返回 None、每个字形都是全零，而"无字形被裁切"的报告
    # 照样是绿的（它只看墨迹有没有越出格子，不看有没有墨迹）。所以下面另有
    # 一条"有墨迹字形数"的体检来兜这个坑。
    pad = max(box_w, box_h)
    img = Image.new("L", (box_w * 3, box_h * 3), 0)
    ImageDraw.Draw(img).text((pad, pad), ch, font=f, fill=255)
    ink = img.getbbox()
    if ink is None:
        return [[0] * box_w for _ in range(box_h)], 0

    top_pad = (box_h - (asc + desc)) // 2
    baseline = top_pad + asc                 # 基线所在行
    dst_top = baseline + (ink[1] - (pad + asc))
    dst_left = (box_w - (ink[2] - ink[0])) // 2

    crop = img.crop(ink)
    if stretch:
        # 把墨迹横向拉宽填满格子（两侧各留 1 px）。
        # 只在"格子宽高比与字体不符、又不想换字库"时用：笔画会不等宽，观感一般。
        crop = crop.resize((max(1, box_w - 2), ink[3] - ink[1]), Image.LANCZOS)
        dst_left = 1
    target = Image.new("L", (box_w, box_h), 0)
    target.paste(crop, (dst_left, dst_top))

    px = target.load()
    grid = [[1 if px[x, y] > 110 else 0 for x in range(box_w)] for y in range(box_h)]

    overflow = 0
    if dst_top < 0 or dst_top + (ink[3] - ink[1]) > box_h:
        overflow = 1
    if dst_left < 0 or dst_left + (ink[2] - ink[0]) > box_w:
        overflow = 1
    return grid, overflow


def pack_rows(grid, box_w, box_h):
    """网格 → 字节流：每行 (box_w+7)//8 字节，大端，行内 bit(box_w-1) = 最左像素。

    BOX_W=8 时每行 1 字节、bit7 最左，与 1 bit/像素位图的位序天然一致；
    BOX_W=16 时每行 2 字节，与上游那份 16×16 字库逐字节相同（自证用）。
    """
    nbytes = (box_w + 7) // 8
    data = []
    for y in range(box_h):
        bits = 0
        for x in range(box_w):
            if grid[y][x]:
                bits |= 1 << (box_w - 1 - x)
        for k in range(nbytes - 1, -1, -1):      # 大端：先高字节
            data.append((bits >> (8 * k)) & 0xFF)
    return data


def symbol_prefix(box_w, box_h):
    """C 符号前缀：只跟**格子尺寸**走（font16 / font8x12），与文件名分开。

    为什么要分开：仓库里那份是 `font16_bin.h` 里放 `font16_codepoints` /
    `FONT16_COUNT`。把符号绑到文件名上会变成 `font16_bin_codepoints` —— 与仓库里
    那份头文件不符，而 16×16 自证（逐字节比对）会当场失败。
    """
    return "font%d" % box_w if box_w == box_h else "font%dx%d" % (box_w, box_h)


def default_name(box_w, box_h):
    return symbol_prefix(box_w, box_h) + "_bin"


def write_binary(out_dir, name, sym, box_w, box_h, cps, grids, meta_lines):
    os.makedirs(out_dir, exist_ok=True)
    n = len(cps)
    nbytes = (box_w + 7) // 8
    up = sym.upper()                  # FONT16 / FONT8X12
    guard = up + "_BIN_H"             # 与仓库里那份一致

    with open(os.path.join(out_dir, name + ".h"), "w", encoding="utf-8") as fp:
        fp.write("/* 由 tools/gen_font.py 生成，请勿手改 */\n")
        fp.write("#ifndef %s\n#define %s\n\n" % (guard, guard))
        fp.write("#include <stdint.h>\n\n")
        for line in meta_lines:
            fp.write("/* %s */\n" % line)
        fp.write("#define %s_COUNT %d\n\n" % (up, n))
        fp.write("extern const uint16_t %s_codepoints[%s_COUNT];\n" % (sym, up))
        fp.write("extern const uint8_t  %s_bitmap[%s_COUNT][%d];\n\n"
                 % (sym, up, box_h * nbytes))
        fp.write("#endif /* %s */\n" % guard)

    with open(os.path.join(out_dir, name + ".c"), "w", encoding="utf-8") as fp:
        fp.write("/* 由 tools/gen_font.py 生成，请勿手改 */\n")
        fp.write('#include "%s.h"\n\n' % name)
        fp.write("const uint16_t %s_codepoints[%s_COUNT] = {\n" % (sym, up))
        for i in range(0, n, 12):
            fp.write("    " + ", ".join("0x%04X" % c for c in cps[i:i + 12]) + ",\n")
        fp.write("};\n\n")
        fp.write("const uint8_t %s_bitmap[%s_COUNT][%d] = {\n"
                 % (sym, up, box_h * nbytes))
        for i, cp in enumerate(cps):
            data = pack_rows(grids[i], box_w, box_h)
            line = ", ".join("0x%02X" % b for b in data)
            fp.write("    /* U+%04X %s */ {%s},\n"
                     % (cp, chr(cp) if cp >= 0x20 else "?", line))
        fp.write("};\n")


def write_preview(box_w, box_h, cps, grids, cols=24):
    """字形总览图。小字号下字形只有几个像素，要放大画 —— 这是唯一需要人眼的一步。"""
    os.makedirs(OUT_DIR, exist_ok=True)
    zoom = max(1, 16 // max(box_w, box_h))   # 16→1 倍，12→1 倍，8→2 倍
    cell = box_w * zoom + 6
    rows = (len(cps) + cols - 1) // cols
    img = Image.new("RGB", (cols * cell, rows * cell), (18, 18, 20))
    d = ImageDraw.Draw(img)
    for i, cp in enumerate(cps):
        ox, oy = (i % cols) * cell, (i // cols) * cell
        d.rectangle([ox, oy, ox + cell - 1, oy + cell - 1], outline=(40, 40, 46))
        for y in range(box_h):
            for x in range(box_w):
                if grids[i][y][x]:
                    px, py = ox + 3 + x * zoom, oy + 3 + y * zoom
                    d.rectangle([px, py, px + zoom - 1, py + zoom - 1],
                                fill=(235, 235, 235))
    path = os.path.join(OUT_DIR, "font_preview.png")
    img.save(path)
    return path


def main():
    ap = argparse.ArgumentParser(description="OSD 字库取模生成器")
    ap.add_argument("--box-w", type=int, default=BOX_W, help="字符格宽，默认 %d" % BOX_W)
    ap.add_argument("--box-h", type=int, default=BOX_H, help="字符格高，默认 %d" % BOX_H)
    ap.add_argument("--em", type=int, default=None,
                    help="em 盒目标高度，默认 = --box-h")
    ap.add_argument("--name", default=None,
                    help="输出基名（默认 font<W>_bin 或 font<W>x<H>_bin）")
    ap.add_argument("--font", default=None, help="TTF 路径（默认按优先级自动挑选）")
    ap.add_argument("--out-dir", default=DEFAULT_OUT, help="生成的 .h/.c 输出目录")
    ap.add_argument("--strict", action="store_true",
                    help="存在缺字形或被裁切字形时以非零码退出（当门禁用）")
    ap.add_argument("--no-symbols", action="store_true", help="字符集不含装饰符号")
    ap.add_argument("--stretch", action="store_true",
                    help="把字形横向拉宽填满格子（笔画会不等宽；只在格子宽高比与"
                         "字体不符时用。关闭时行为与上游 16×16 字库逐字节一致）")
    args = ap.parse_args()

    em_target = args.em if args.em is not None else args.box_h
    sym = symbol_prefix(args.box_w, args.box_h)
    name = args.name or (sym + "_bin")
    if em_target > args.box_h:
        sys.exit("--em 不能大于 --box-h（em 盒要装进格子里）")

    font_path, tag = resolve_font(args.font)
    cps = build_charset(extra_symbols=not args.no_symbols)
    print("[font ] %s  (%s)" % (font_path, tag))
    print("[grid ] %d×%d  em≤%d" % (args.box_w, args.box_h, em_target))

    if TTFont is None:
        # 不能静默通过：没装 fontTools 时 coverage() 只能返回空表，
        # "缺失 0 个"会被误读成"体检通过"。这里把"没体检"说出来。
        print("[cover] 未装 fontTools → **跳过** cmap 体检（缺失数不可信；"
              "pip install fonttools 可开启）")
    missing = coverage(font_path, cps)
    print("[cover] 目标 %d 字形，字体缺失 %d 个" % (len(cps), len(missing)))
    if missing:
        print("[cover] 缺失清单: " + ", ".join("U+%04X %s" % (c, chr(c)) for c in missing))
        print("[cover] 提示: PT 系列不保证覆盖 Arrows/Geometric Shapes 区；"
              "UI 文案请用 ASCII 替代（-> 代替 →）。")

    keep = [c for c in cps if c not in missing]
    if not keep:
        sys.exit("全部字形缺失，终止")

    info = pick_size(font_path, keep, em_target, args.box_w)
    if info is None:
        sys.exit("找不到合适字号：em≤%d 且所有字形都装得进 %d×%d —— "
                 "把 --em 调大（上限等于 --box-h）再试"
                 % (em_target, args.box_w, args.box_h))
    size, asc, desc, em = info
    print("[size ] %d px  (ascent=%d descent=%d em=%d → 目标 %d)"
          % (size, asc, desc, em, em_target))

    f = ImageFont.truetype(font_path, size)
    grids, clipped = [], []
    for cp in keep:
        g, ov = render_glyph(f, chr(cp), info, args.box_w, args.box_h,
                             stretch=args.stretch)
        grids.append(g)
        if ov:
            clipped.append(cp)

    # 墨迹体检。为什么必须有这一条：渲染参数写错（例如 pad 没跟着格子缩放）的
    # 后果是**每个字形都全零**，而"无字形被裁切"照样是绿的 —— 它只看墨迹有没有
    # 越出格子，不看有没有墨迹。所以这里直接数"有多少字形有墨迹"。
    blank, widths = [], []
    for i, cp in enumerate(keep):
        xs = [x for y in range(args.box_h) for x in range(args.box_w)
              if grids[i][y][x]]
        if not xs:
            blank.append(cp)
        elif cp != 0x20:
            widths.append(max(xs) - min(xs) + 1)
    print("[ink  ] 有墨迹字形 %d/%d（空字形 %d 个%s）"
          % (len(keep) - len(blank), len(keep), len(blank),
             "：" + ", ".join("U+%04X" % c for c in blank[:6]) if blank else ""))
    if widths:
        widths.sort()
        med = widths[len(widths) // 2]
        print("[ink  ] 笔画宽 min/中位/max = %d/%d/%d px（格宽 %d → 中位两侧各余 %d px）"
              % (widths[0], med, widths[-1], args.box_w, (args.box_w - med) // 2))
    if len(keep) - len(blank) <= 1:
        sys.exit("几乎所有字形都是空的 —— 渲染参数有问题（先查 pad 是否随格子缩放）")

    nbytes = (args.box_w + 7) // 8
    meta = [
        "源字体: %s" % os.path.basename(font_path),
        "字号: %d px  ascent=%d descent=%d em=%d" % (size, asc, desc, em),
        "布局: %dx%d 格，em=%d 垂直居中，水平%s"
        % (args.box_w, args.box_h, em_target, "拉伸填满" if args.stretch else "居中"),
        "位序: 行优先 MSB first，bit%d = 最左像素，每行 %d 字节大端"
        % (args.box_w - 1, nbytes),
    ]
    write_binary(args.out_dir, name, sym, args.box_w, args.box_h, keep, grids, meta)
    prev = write_preview(args.box_w, args.box_h, keep, grids)

    print("[out  ] %s  (%d 字形 × %d B = %d B)"
          % (os.path.join(args.out_dir, name + ".c"), len(keep),
             args.box_h * nbytes, len(keep) * args.box_h * nbytes))
    print("[out  ] %s  （字形总览图，务必目检）" % prev)
    if clipped:
        print("[warn ] 被 %d×%d 格裁切的字形 %d 个: %s"
              % (args.box_w, args.box_h, len(clipped),
                 ", ".join("U+%04X" % c for c in clipped)))
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
