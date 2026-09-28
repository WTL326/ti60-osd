#!/usr/bin/env python3
"""Extract a TI60 mask Flash dump and compare it with the source BMP."""

import argparse
import hashlib
import pathlib
import struct
import zlib

from PIL import Image, ImageDraw


FLASH_HEADER_BYTES = 32
FLASH_DATA_OFFSET = 0x1000
MASK_MAGIC = 0x4D41534B


def read_byte_per_line_hex(path: pathlib.Path) -> bytes:
    values = []
    for line_number, text in enumerate(path.read_text(encoding="ascii").splitlines(), 1):
        text = text.strip()
        if not text:
            continue
        if len(text) != 2:
            raise ValueError(f"{path}:{line_number}: expected one hex byte, got {text!r}")
        try:
            values.append(int(text, 16))
        except ValueError as exc:
            raise ValueError(f"{path}:{line_number}: invalid hex byte {text!r}") from exc
    return bytes(values)


def threshold_bmp(path: pathlib.Path, width: int, height: int, threshold: int) -> bytes:
    """二值化参考图并**按 1 bit/像素打包**，与 flash 里存的形式一致。

    位序：每字节 **bit7 是行内最左**（与 send_mask_via_adb.py、RTL 的
    `pbitsel <= 7 - dx[2:0]`、以及字库的 bit15=最左 一致）。
    不打包就没法比 —— flash 里存的是打包后的字节。
    """
    if width % 8:
        raise ValueError(f"宽度必须是 8 的倍数（1 bit/像素按字节打包），当前 {width}")
    with Image.open(path) as image:
        rgb = image.convert("RGB")
        if rgb.size != (width, height):
            raise ValueError(f"reference BMP is {rgb.width}x{rgb.height}, expected {width}x{height}")
        bytes_per_row = width // 8
        packed = bytearray(bytes_per_row * height)
        for y in range(height):
            for x in range(width):
                if min(rgb.getpixel((x, y))) >= threshold:
                    packed[y * bytes_per_row + (x >> 3)] |= 0x80 >> (x & 7)
        return bytes(packed)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("dump", type=pathlib.Path)
    parser.add_argument("reference", type=pathlib.Path)
    parser.add_argument("--threshold", type=int, default=240)
    parser.add_argument("--output-dir", type=pathlib.Path)
    args = parser.parse_args()

    raw = read_byte_per_line_hex(args.dump)
    if len(raw) < FLASH_DATA_OFFSET:
        raise ValueError(f"dump too short: {len(raw)} bytes")

    header = raw[:FLASH_HEADER_BYTES]
    magic, version, header_size, width, height, left, top = struct.unpack(">IHHHHhh", header[:16])
    enabled = header[16]
    length, expected_crc = struct.unpack(">II", header[20:28])
    if magic != MASK_MAGIC:
        raise ValueError(f"bad magic: 0x{magic:08X}")
    if header_size != FLASH_HEADER_BYTES:
        raise ValueError(f"bad header size: {header_size}")
    # 1 bit/像素按字节打包：载荷长度是 宽*高/8
    expect_len = width * height // 8
    if length != expect_len:
        raise ValueError(
            f"payload length {length} does not match {width}x{height}/8 = {expect_len}")
    if len(raw) < FLASH_DATA_OFFSET + length:
        raise ValueError(f"dump has {len(raw)} bytes, need {FLASH_DATA_OFFSET + length}")

    payload = raw[FLASH_DATA_OFFSET:FLASH_DATA_OFFSET + length]
    actual_crc = zlib.crc32(payload) & 0xFFFFFFFF
    reference = threshold_bmp(args.reference, width, height, args.threshold)
    mismatch_indices = [index for index, pair in enumerate(zip(reference, payload)) if pair[0] != pair[1]]

    output_dir = args.output_dir or args.dump.parent
    output_dir.mkdir(parents=True, exist_ok=True)
    payload_path = output_dir / "Ti60_mask_flash_payload.bmp"
    diff_path = output_dir / "Ti60_mask_flash_difference.png"
    comparison_path = output_dir / "Ti60_mask_flash_comparison.png"

    reference_image = Image.frombytes("L", (width, height), reference)
    payload_image = Image.frombytes("L", (width, height), payload)
    payload_image.save(payload_path)

    diff_image = Image.new("RGB", (width, height), "black")
    diff_pixels = diff_image.load()
    for index in mismatch_indices:
        diff_pixels[index % width, index // width] = (255, 0, 0)
    diff_image.save(diff_path)

    label_height = 24
    comparison = Image.new("RGB", (width * 3, height + label_height), "white")
    comparison.paste(reference_image.convert("RGB"), (0, label_height))
    comparison.paste(payload_image.convert("RGB"), (width, label_height))
    comparison.paste(diff_image, (width * 2, label_height))
    draw = ImageDraw.Draw(comparison)
    draw.text((5, 5), "Reference mask.bmp (thresholded)", fill="black")
    draw.text((width + 5, 5), "Flash payload", fill="black")
    draw.text((width * 2 + 5, 5), "Difference (red)", fill="black")
    comparison.save(comparison_path)

    if mismatch_indices:
        xs = [index % width for index in mismatch_indices]
        ys = [index // width for index in mismatch_indices]
        mismatch_box = f"({min(xs)},{min(ys)})-({max(xs)},{max(ys)})"
    else:
        mismatch_box = "none"

    print(f"dump_bytes={len(raw)}")
    print(f"magic=0x{magic:08X} version={version} header_size={header_size}")
    print(f"width={width} height={height} left={left} top={top} enabled={enabled}")
    print(f"payload_length={length}")
    print(f"header_crc32=0x{expected_crc:08X}")
    print(f"payload_crc32=0x{actual_crc:08X} crc_match={actual_crc == expected_crc}")
    print(f"payload_sha256={hashlib.sha256(payload).hexdigest()}")
    print(f"reference_sha256={hashlib.sha256(reference).hexdigest()}")
    print(f"different_pixels={len(mismatch_indices)} total_pixels={length}")
    print(f"different_percent={len(mismatch_indices) * 100.0 / length:.6f}")
    print(f"difference_bbox={mismatch_box}")
    print(f"payload_image={payload_path}")
    print(f"difference_image={diff_path}")
    print(f"comparison_image={comparison_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
