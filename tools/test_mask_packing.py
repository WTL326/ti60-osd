#!/usr/bin/env python3
"""验证掩膜工具的 1 bit/像素打包位序（任务 5.1/5.3 的联合验收）。

位序约定必须是 **bit7 = 行内最左像素**。它与另外两处是同一件事的三面：
  * RTL: pbitsel <= 7 - dx[2:0]
  * spec: 位图内存布局契约「第 (7 - m%8) 位」
  * 字库: ti60 的 font_row_bits 同样是 bit15 = 最左
任何一面接反都会让画面左右镜像，而三面各自自洽、单看一处测不出来 —— 所以这里
用"构造已知图像 -> 检查打包出的字节"来钉死它。

用法：python tools/test_mask_packing.py
"""
import importlib.util
import pathlib
import struct
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location(
    "send_mask", ROOT / "tools" / "send_mask_via_adb.py")
send_mask = importlib.util.module_from_spec(spec)
spec.loader.exec_module(send_mask)

W, H = 8, 1
TMP = pathlib.Path(tempfile.gettempdir()) / "mask_packing_test.bmp"


def make_bmp(rows):
    """最小 24 位未压缩 BMP（自顶向下）。"""
    stride = ((W * 3 + 3) // 4) * 4
    px = bytearray()
    for row in rows:
        line = bytearray()
        for v in row:
            line += bytes((v, v, v))
        line += b"\x00" * (stride - len(line))
        px += line
    dib = struct.pack("<IiiHHI", 40, W, -H, 1, 24, 0)
    dib += b"\x00" * (40 - len(dib))
    hdr = b"BM" + struct.pack("<IHHI", 14 + len(dib) + len(px), 0, 0, 14 + len(dib))
    return hdr + dib + bytes(px)


def pack(row):
    TMP.write_bytes(make_bmp([row]))
    return send_mask.read_binary_bmp(TMP, 240, W, H)[0]


CASES = [
    ([255] + [0] * 7, 0x80, "只有最左像素亮 -> bit7"),
    ([0] * 7 + [255], 0x01, "只有最右像素亮 -> bit0"),
    ([255] * 8, 0xFF, "整行亮"),
    ([0] * 8, 0x00, "整行暗"),
    ([255, 0, 255, 0, 255, 0, 255, 0], 0xAA, "交替亮（从最左起）"),
]


def main() -> int:
    bad = 0
    for row, want, why in CASES:
        got = pack(row)
        ok = got == want
        bad += 0 if ok else 1
        print(f"{'OK ' if ok else 'BAD'} {why}: 得到 0x{got:02X} 期望 0x{want:02X}")
    print("PASS" if bad == 0 else f"FAIL: {bad} 处位序不符")
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
