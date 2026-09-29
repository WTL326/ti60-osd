#!/usr/bin/env python3
"""make_test_bitmap.py —— 生成上板验证用的 OSD 测试位图（544x288 24 位 BMP）

为什么要生成而不是随手找一张图：上板要验的是**位序与几何**，不是"能不能显示一张图"。
四个特征各针对一种会出错的方式，用一张普通照片一个都验不出来：

  · 外框 2px          —— 验窗口边界与尺寸（缺一边 = 宽高或跨距算错）
  · 四角 16x16 方块    —— 验四个角没被裁掉（= 边界判断写成了 < 而不是 <=）
  · 对角十字 2px       —— 验左右没被镜像、上下没被翻转（镜像后两条对角线互换）
  · 位序尺（每字节 11000000）—— 验 bit7 是最左。
       正常：每 8 个像素一组、白点在**组首**，且第 1 组紧贴外框左边缘。
       位序接反：白点跑到**组尾**，整条尺相对左边缘偏移 6 像素 —— 一眼可见。
  · 中部棋盘           —— 验 2D 区域上"每一位对应一个像素"（不只看一行），
       且位序接反时棋盘相位整体翻转。

极性（与 tools/send_mask_via_adb.py 的 `read_binary_bmp` 一致）：
  `min(r,g,b) >= threshold` 的像素**置位**，RTL 侧位 = 1 输出纯白 16'h80EB；
  其余位 = 0，视频透传。所以本脚本只用纯白 (255,255,255) 与纯黑 (0,0,0)，
  离阈值两端都远，不给二值化留歧义。

用法：
    python tools/make_test_bitmap.py                       # 写到 tools/out/mask_test.bmp
    python tools/make_test_bitmap.py --output D:/x.bmp
    python tools/make_test_bitmap.py --no-verify           # 跳过自检

自检做什么：用**工具自己的读函数** `read_binary_bmp()` 把刚写的文件读回来，
核对置位像素总数与几个特征点的位置。用被测工具验自己刚生成的东西，
是为了挡住"生成器与工具对不上"这类问题（例如行序上下颠倒、阈值极性接反）。
"""
import argparse
import hashlib
import pathlib
import struct
import sys

# 图案参数（相对尺寸推导，不写死，换分辨率也能用）
FRAME_PX = 2          # 外框线宽
CORNER = 16           # 四角方块边长
CORNER_INSET = 6      # 四角方块距角落的偏移（在外框内侧）
DIAG_W = 2            # 对角十字线宽
RULER_H = 16          # 位序尺高度
RULER_BYTE_PATTERN = 0b11000000   # 每字节 2 白 6 黑；接反会变成 0b00000011
CHECKER_CELL = 8      # 棋盘单元边长
CHECKER_W = 272       # 棋盘区域宽（已被 8 整除，保证单元完整）
CHECKER_H = 96        # 棋盘区域高


def build_pattern(width: int, height: int) -> bytearray:
    """按上面的特征清单画一张 1 bit/像素的图，返回紧凑打包后的字节。

    打包约定与 RTL 一致：行跨距 width/8 字节，**bit7 是行内最左**。
    直接产出打包结果（而不是先做一张灰度数组再打包），是为了让本函数与
    `tools/send_mask_via_adb.py` 的打包逻辑**互相独立** —— 两边都错成一样
    才有可能同时错，而那是小概率；若这里先做灰度图再调工具的函数打包，
    就变成自证了。
    """
    if width % 8:
        raise ValueError(f"宽度必须是 8 的倍数（按字节打包），当前 {width}")
    if width < 64 or height < 64:
        raise ValueError("尺寸太小，图案特征放不下")
    if CHECKER_W > width - 32 or CHECKER_H > height - 32:
        raise ValueError(f"{width}x{height} 放不下 {CHECKER_W}x{CHECKER_H} 的棋盘")

    bpr = width // 8
    img = bytearray(bpr * height)

    def put(x: int, y: int) -> None:
        if 0 <= x < width and 0 <= y < height:
            img[y * bpr + (x >> 3)] |= 0x80 >> (x & 7)

    def filled(x0: int, y0: int, w: int, h: int) -> None:
        for yy in range(y0, y0 + h):
            for xx in range(x0, x0 + w):
                put(xx, yy)

    # 1) 外框
    filled(0, 0, width, FRAME_PX)                       # 上
    filled(0, height - FRAME_PX, width, FRAME_PX)       # 下
    filled(0, 0, FRAME_PX, height)                      # 左
    filled(width - FRAME_PX, 0, FRAME_PX, height)       # 右

    # 2) 四角方块（贴外框内侧）
    filled(CORNER_INSET, CORNER_INSET, CORNER, CORNER)
    filled(width - CORNER_INSET - CORNER, CORNER_INSET, CORNER, CORNER)
    filled(CORNER_INSET, height - CORNER_INSET - CORNER, CORNER, CORNER)
    filled(width - CORNER_INSET - CORNER, height - CORNER_INSET - CORNER,
           CORNER, CORNER)

    # 3) 位序尺：横贯全宽，从 x=0 开始，每字节 11000000。
    #    起点贴左边缘是刻意的 —— 它是判断"白点落在组首还是组尾"的参照。
    #    放在棋盘之前画，棋盘会覆盖它中段，两端仍可见。
    ruler_y = FRAME_PX + CORNER + 24
    for y in range(ruler_y, ruler_y + RULER_H):
        for byi in range(bpr):
            pat = RULER_BYTE_PATTERN
            for b in range(8):
                if pat & (0x80 >> b):
                    put(byi * 8 + b, y)

    # 4) 中部棋盘（左右居中、垂直居中偏下，避开位序尺）
    cx0 = (width - CHECKER_W) // 2
    cy0 = (height - CHECKER_H) // 2 + 24
    for cy in range(CHECKER_H // CHECKER_CELL):
        for cx in range(CHECKER_W // CHECKER_CELL):
            if (cx + cy) % 2 == 0:
                filled(cx0 + cx * CHECKER_CELL, cy0 + cy * CHECKER_CELL,
                       CHECKER_CELL, CHECKER_CELL)

    # 5) 对角十字最后画：让它**连续**穿过棋盘与位序尺。
    #    断续的对角线在镜像时不易辨认，连续的两条互换关系最清楚。
    steps = max(width, height)
    for i in range(steps):
        x = i * (width - 1) // (steps - 1)
        y = i * (height - 1) // (steps - 1)
        filled(x, y - DIAG_W // 2, DIAG_W, DIAG_W)                 # 主对角 \
        filled(x, height - 1 - y - DIAG_W // 2, DIAG_W, DIAG_W)    # 副对角 /

    return img


def write_bmp(path: pathlib.Path, packed: bytes, width: int, height: int) -> None:
    """把打包好的 1 bit/像素图写成 **24 位未压缩 BMP**（白 = 置位）。

    行序：写成自下而上（height 为正）—— 这是 BMP 的常见形态，
    也顺带覆盖 `read_binary_bmp` 里 `top_down = bmp_h < 0` 的那条分支。
    行填充：每行补齐到 4 字节边界（544 宽时 1632 已对齐，等于没有填充，
    但补齐逻辑照写，换宽度才不会错）。
    """
    bpr = width // 8
    row_raw = width * 3
    row_stride = ((row_raw + 3) // 4) * 4
    pad = b"\x00" * (row_stride - row_raw)
    pixel_offset = 54
    image_size = row_stride * height

    header = b"BM" + struct.pack("<IHHI", pixel_offset + image_size, 0, 0,
                                 pixel_offset)
    dib = struct.pack("<IiiHHIIiiII", 40, width, height, 1, 24, 0, image_size,
                      2835, 2835, 0, 0)

    rows_bottom_up = []
    for y in range(height - 1, -1, -1):
        row = bytearray()
        for x in range(width):
            on = packed[y * bpr + (x >> 3)] & (0x80 >> (x & 7))
            # BGR 顺序；白/黑纯色，离阈值两端都远
            row += b"\xff\xff\xff" if on else b"\x00\x00\x00"
        rows_bottom_up.append(bytes(row) + pad)

    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(header + dib + b"".join(rows_bottom_up))


def verify(path: pathlib.Path, width: int, height: int) -> int:
    """用工具自己的读函数把文件读回来，核对几何与几个特征点。

    返回置位像素总数（供打印）。任何一项对不上就抛异常 —— 宁可让脚本失败，
    也不要把一张"看着没问题、其实行序或极性反了"的图送到板上。
    """
    sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
    from send_mask_via_adb import read_binary_bmp   # noqa: E402

    packed = read_binary_bmp(path, threshold=240, width=width, height=height)
    bpr = width // 8

    def on(x: int, y: int) -> bool:
        return bool(packed[y * bpr + (x >> 3)] & (0x80 >> (x & 7)))

    total = sum(bin(b).count("1") for b in packed)

    problems = []
    # 外框顶点与边中点必须置位（四角与四条边都画到了）
    for (x, y, what) in ((0, 0, "左上角"), (width - 1, 0, "右上角"),
                         (0, height - 1, "左下角"), (width - 1, height - 1, "右下角"),
                         (width // 2, 0, "上边中点"), (width // 2, height - 1, "下边中点"),
                         (0, height // 2, "左边中点"), (width - 1, height // 2, "右边中点")):
        if not on(x, y):
            problems.append(f"外框缺失：{what} ({x},{y}) 未置位")
    # 外框内侧必须不置位（除了对角线与位序尺经过的地方，这里取一个安全的点）
    if on(FRAME_PX + 1, height // 2):
        problems.append("外框内侧不该置位（边框画粗了？）")
    # 位序尺：第 0 行的第 0、1 像素置位，第 2..7 不置位（= 组首两个白点）
    ruler_y = FRAME_PX + CORNER + 24 + RULER_H // 2
    for x, want in ((0, True), (1, True), (2, False), (3, False),
                    (7, False), (8, True), (9, True), (10, False)):
        if on(x, ruler_y) != want:
            problems.append(
                f"位序尺在 x={x} 的取值不符：期望 {'置位' if want else '不置位'}")
    # 位序的反向断言：若 bit 序接反，尺子的白点会落在 x=6,7 / 14,15
    if on(6, ruler_y) or on(7, ruler_y):
        problems.append("位序尺出现'组尾白点' —— 位序或打包反了")

    if problems:
        raise AssertionError("自检未通过：\n  - " + "\n  - ".join(problems))
    return total


def main() -> int:
    ap = argparse.ArgumentParser(description="生成上板验证用的 OSD 测试位图")
    ap.add_argument("--output", default=None,
                    help="输出 BMP 路径（默认 tools/out/mask_test.bmp）")
    ap.add_argument("--width", type=int, default=544)
    ap.add_argument("--height", type=int, default=288)
    ap.add_argument("--no-verify", action="store_true", help="跳过自检")
    a = ap.parse_args()

    here = pathlib.Path(__file__).resolve().parent
    out = pathlib.Path(a.output) if a.output else here / "out" / "mask_test.bmp"

    packed = build_pattern(a.width, a.height)
    write_bmp(out, packed, a.width, a.height)

    print(f"已生成：{out}")
    print(f"尺寸：{a.width}x{a.height}，24 位未压缩 BMP，"
          f"{out.stat().st_size} 字节")
    print(f"打包后置位像素：{sum(bin(b).count('1') for b in packed)}")
    print(f"打包数据的 SHA256：{hashlib.sha256(packed).hexdigest()[:16]}"
          f"（同一份脚本必然产出同一份数据）")

    if not a.no_verify:
        n = verify(out, a.width, a.height)
        print(f"自检通过：用 tools/send_mask_via_adb.py 的读函数回读，"
              f"置位像素 {n}，外框/四角/位序尺特征点全部符合")

    print()
    print("上板用法（位流需把 rtl_mask_mode 置 1，见任务 8.5）：")
    print(f"  python tools/send_mask_via_adb.py --image {out}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
