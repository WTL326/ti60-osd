#!/usr/bin/env python3
"""Generate the compact CP1251 8x16 UI font ROM used by the CVBS OSD."""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "src" / "ui" / "UiFontRom8x16.v"
FONT = Path(r"C:\Windows\Fonts\consolab.ttf")
FONT_SIZE = 13
RASTER_THRESHOLD = 96


def render(code: int, font: ImageFont.FreeTypeFont) -> list[int]:
    char = bytes([code]).decode("cp1251")
    image = Image.new("L", (8, 16), 0)
    draw = ImageDraw.Draw(image)
    box = draw.textbbox((0, 0), char, font=font)
    width, height = box[2] - box[0], box[3] - box[1]
    x = (8 - width) // 2 - box[0]
    y = (16 - height) // 2 - box[1]
    draw.text((x, y), char, font=font, fill=255)
    rows = []
    for y in range(16):
        bits = sum(1 << (7 - x) for x in range(8)
                   if image.getpixel((x, y)) >= RASTER_THRESHOLD)
        # Consolas Bold already produces mostly two-pixel stems. Reinforce only
        # isolated one-pixel runs so CVBS filtering cannot erase thin diagonals.
        isolated = bits & ~((bits << 1) & 0xFF) & ~(bits >> 1)
        bits |= isolated >> 1
        bits |= (isolated & 1) << 1
        rows.append(bits & 0xFF)
    return rows


def main() -> None:
    font = ImageFont.truetype(str(FONT), FONT_SIZE)
    codes = list(range(0x20, 0x7F)) + [0xA8, 0xB0, 0xB8] + list(range(0xC0, 0x100))
    lines = [
        "`timescale 1ns / 1ps",
        "",
        "// Generated from Consolas Bold with CVBS-oriented stroke reinforcement.",
        "// Fixed 8x16 CP1251/ASCII cells; UI geometry is unchanged.",
        "module UiFontRom8x16(input wire [7:0] char_code,",
        "                      input wire [3:0] row,",
        "                      output reg [7:0] bits);",
        "  always @(*) begin",
        "    bits = 8'h00;",
        "    case ({char_code,row})",
    ]
    for code in codes:
        for row, bits in enumerate(render(code, font)):
            if bits:
                lines.append(f"      12'h{code:02x}{row:x}: bits = 8'h{bits:02x};")
    lines += ["      default: bits = 8'h00;", "    endcase", "  end", "endmodule", ""]
    OUTPUT.write_text("\n".join(lines), encoding="ascii")


if __name__ == "__main__":
    main()
