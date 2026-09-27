#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""PPM(P5) → PNG 预览。用法: python tools/ppm2png.py [文件...]（缺省转 test/out 全部）"""
import os
import sys
import glob

from PIL import Image

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)


def convert(src, dst):
    with open(src, "rb") as f:
        data = f.read()
    # 解析 P5 头：P5\n<width> <height>\n<max>\n<binary>
    parts = data.split(b"\n", 3)
    w, h = map(int, parts[1].split())
    raw = parts[3]
    if len(raw) < w * h:
        raise ValueError("PPM 数据不足")
    img = Image.frombytes("L", (w, h), raw[: w * h])
    # 透明底放大 2 倍并反相成"白字黑底"观感，叠一个浅色背景便于看透明区
    rgb = Image.merge("RGB", (img.point(lambda v: 255 - v),
                              img.point(lambda v: 255 - v),
                              img.point(lambda v: 235 - v * 0.9)))
    rgb = rgb.resize((w * 2, h * 2), Image.NEAREST)
    rgb.save(dst)
    print("[png ] %s" % dst)


def main():
    args = sys.argv[1:]
    if not args:
        args = sorted(glob.glob(os.path.join(ROOT, "test", "out", "*.ppm")))
    for p in args:
        dst = os.path.splitext(p)[0] + ".png"
        convert(p, dst)


if __name__ == "__main__":
    main()
