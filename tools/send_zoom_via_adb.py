#!/usr/bin/env python3
"""Send FPGA electronic-zoom commands through X2000 /dev/ttyS1.

Unified TI60 frame:
  BB | len_hi len_lo | dalei(0x01) zixiang(0x01) type(0x00) |
  x_left:u16 y_top:u16 x_right:u16 y_bottom:u16 | crc16 | AA
"""

import argparse
import pathlib
import subprocess
import tempfile


HEADER = 0xBB
FOOTER = 0xAA
DALEI_EZOOM = 0x01
ZIXIANG_EZOOM = 0x01
TYPE_WRITE = 0x00


def crc16_ccitt(data: bytes) -> int:
    crc = 0
    for value in data:
        crc ^= value << 8
        for _ in range(8):
            crc = ((crc << 1) ^ 0x1021) & 0xFFFF if crc & 0x8000 else (crc << 1) & 0xFFFF
    return crc


def u16(value: int) -> bytes:
    return int(value).to_bytes(2, "big", signed=False)


def packet(left: int, top: int, right: int, bottom: int) -> bytes:
    payload = u16(left) + u16(top) + u16(right) + u16(bottom)
    body = bytes((DALEI_EZOOM, ZIXIANG_EZOOM, TYPE_WRITE)) + payload
    crc = crc16_ccitt(body)
    return (bytes((HEADER,)) + len(body).to_bytes(2, "big") + body +
            crc.to_bytes(2, "big") + bytes((FOOTER,)))


def adb(adb_exe: str, *args: str, **kwargs) -> subprocess.CompletedProcess:
    capture = kwargs.get("capture", False)
    return subprocess.run(
        [adb_exe, *args],
        check=True,
        stdout=subprocess.PIPE if capture else None,
        stderr=subprocess.PIPE if capture else None,
    )


def hex_text(data: bytes) -> str:
    return " ".join("%02x" % value for value in data)


def main() -> int:
    ap = argparse.ArgumentParser(description="控制TI60电子变倍")
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument("--center", action="store_true", help="中心+半宽/半高模式")
    mode.add_argument("--corners", action="store_true", help="左上+右下模式")
    mode.add_argument("--disable", action="store_true", help="恢复全幅1x")
    ap.add_argument("--x", type=int, default=640)
    ap.add_argument("--y", type=int, default=512)
    ap.add_argument("--half-width", type=int, default=320)
    ap.add_argument("--half-height", type=int, default=256)
    ap.add_argument("--x0", type=int, default=0)
    ap.add_argument("--y0", type=int, default=0)
    ap.add_argument("--x1", type=int, default=1279)
    ap.add_argument("--y1", type=int, default=1023)
    ap.add_argument("--adb", default="adb", help="adb.exe路径或命令名")
    ap.add_argument("--device", default="/dev/ttyS1")
    ap.add_argument("--timeout", type=float, default=5.0)
    ns = ap.parse_args()

    if ns.disable:
        left, top, right, bottom = 0, 0, 1279, 1023
        description = "关闭电子变倍（恢复全幅1x）"
    elif ns.center:
        left = ns.x - ns.half_width
        top = ns.y - ns.half_height
        right = ns.x + ns.half_width - 1
        bottom = ns.y + ns.half_height - 1
        description = (f"中心=({ns.x},{ns.y}) 半宽={ns.half_width} "
                       f"半高={ns.half_height}")
    else:
        left, top, right, bottom = ns.x0, ns.y0, ns.x1, ns.y1
        description = f"左上=({ns.x0},{ns.y0}) 右下=({ns.x1},{ns.y1})"

    if not (0 <= left < right <= 1279 and 0 <= top < bottom <= 1023):
        raise RuntimeError(
            f"ROI 非法：需 0<=left<right<=1279 且 0<=top<bottom<=1023，"
            f"当前=({left},{top})-({right},{bottom})")

    command_packet = packet(left, top, right, bottom)
    with tempfile.TemporaryDirectory() as td:
        local_tx = pathlib.Path(td) / "zoom_command.bin"
        local_rx = pathlib.Path(td) / "zoom_ack.bin"
        local_tx.write_bytes(command_packet)
        adb(ns.adb, "push", str(local_tx), "/tmp/fpga_zoom_command.bin")
        # Start the reader first so a short FPGA ACK cannot be lost.
        shell = (
            f"stty -F {ns.device} 115200 cs8 -cstopb -parenb -crtscts raw -echo; "
            f"rm -f /tmp/fpga_zoom_ack.bin; "
            f"(timeout {max(1, int(ns.timeout))} dd if={ns.device} bs=1 count=10 "
            f"of=/tmp/fpga_zoom_ack.bin 2>/dev/null) & "
            f"reader=$!; sleep 0.1; "
            f"cat /tmp/fpga_zoom_command.bin > {ns.device}; wait $reader"
        )
        adb(ns.adb, "shell", shell)
        adb(ns.adb, "pull", "/tmp/fpga_zoom_ack.bin", str(local_rx))
        ack = local_rx.read_bytes()

    if len(ack) != 10:
        raise RuntimeError(f"ACK长度错误：收到{len(ack)}字节，预期10字节")
    if (ack[0] != HEADER or ack[1:3] != b"\x00\x04" or
            ack[3] != DALEI_EZOOM or ack[4] != ZIXIANG_EZOOM):
        raise RuntimeError(f"ACK格式错误：{hex_text(ack)}")
    if (ack[-1] != FOOTER or
            crc16_ccitt(ack[3:7]) != int.from_bytes(ack[7:9], "big")):
        raise RuntimeError(f"ACK CRC/帧尾错误：{hex_text(ack)}")
    if ack[5] != 0x02 or ack[6] != 0xFF:
        raise RuntimeError(f"FPGA拒绝命令，状态=0x{ack[6]:02X}")
    print(f"成功：{description}")
    print("发送：", hex_text(command_packet))
    print("返回：", hex_text(ack))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
