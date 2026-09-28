#!/usr/bin/env python3
"""Control/query TI60 hot-focus tracking through X2000 /dev/ttyS1."""

import argparse
import pathlib
import subprocess
import tempfile


HEADER = 0xBB
FOOTER = 0xAA
CATEGORY = 0x02
SUB_SET = 0x01
SUB_QUERY = 0x02
TYPE_WRITE = 0x00
TYPE_ACK = 0x02


def spaced_hex(data: bytes) -> str:
    """Return a readable dump while remaining compatible with Python 3.6."""
    return " ".join("{:02x}".format(value) for value in data)


def crc16_ccitt(data: bytes) -> int:
    crc = 0
    for value in data:
        crc ^= value << 8
        for _ in range(8):
            crc = ((crc << 1) ^ 0x1021) & 0xFFFF if crc & 0x8000 else (crc << 1) & 0xFFFF
    return crc


def make_packet(subcommand: int, payload: bytes = b"") -> bytes:
    body = bytes((CATEGORY, subcommand, TYPE_WRITE)) + payload
    return (bytes((HEADER,)) + len(body).to_bytes(2, "big") + body +
            crc16_ccitt(body).to_bytes(2, "big") + bytes((FOOTER,)))


def adb(adb_exe: str, *args: str) -> None:
    subprocess.run([adb_exe, *args], check=True)


def verify_response(data: bytes, subcommand: int) -> bytes:
    if len(data) < 10 or data[0] != HEADER or data[-1] != FOOTER:
        raise RuntimeError(f"响应帧格式错误：{spaced_hex(data)}")
    body_length = int.from_bytes(data[1:3], "big")
    if len(data) != body_length + 6:
        raise RuntimeError(f"响应长度错误：帧声明{body_length}字节，实际{len(data)}字节")
    body = data[3:3 + body_length]
    received_crc = int.from_bytes(data[3 + body_length:5 + body_length], "big")
    if crc16_ccitt(body) != received_crc:
        raise RuntimeError(f"响应CRC错误：{spaced_hex(data)}")
    if body[:3] != bytes((CATEGORY, subcommand, TYPE_ACK)):
        raise RuntimeError(f"响应命令不匹配：{spaced_hex(data)}")
    if len(body) < 4 or body[3] != 0xFF:
        status = body[3] if len(body) >= 4 else 0
        raise RuntimeError(f"FPGA拒绝热点命令，状态=0x{status:02X}")
    return body


def main() -> int:
    parser = argparse.ArgumentParser(description="控制TI60热点追踪")
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--enable", action="store_true", help="打开热点追踪")
    mode.add_argument("--disable", action="store_true", help="关闭热点追踪")
    mode.add_argument("--query", action="store_true", help="读取热点状态和坐标")
    parser.add_argument("--black-hot", action="store_true",
                        help="黑热模式（寻找最暗3x3区域）")
    parser.add_argument("--adb", default="adb", help="adb.exe路径或命令名")
    parser.add_argument("--device", default="/dev/ttyS1")
    parser.add_argument("--timeout", type=float, default=5.0)
    args = parser.parse_args()

    if args.black_hot and not args.enable:
        parser.error("--black-hot只能和--enable一起使用")

    if args.query:
        subcommand = SUB_QUERY
        command = make_packet(subcommand)
        response_bytes = 21
    else:
        subcommand = SUB_SET
        flags = (1 if args.enable else 0) | (2 if args.black_hot else 0)
        command = make_packet(subcommand, bytes((flags,)))
        response_bytes = 10

    with tempfile.TemporaryDirectory() as directory:
        tx_path = pathlib.Path(directory) / "hot_focus_command.bin"
        rx_path = pathlib.Path(directory) / "hot_focus_ack.bin"
        tx_path.write_bytes(command)
        adb(args.adb, "push", str(tx_path), "/tmp/fpga_hot_focus_command.bin")
        shell = (
            f"stty -F {args.device} 115200 cs8 -cstopb -parenb -crtscts raw -echo; "
            "rm -f /tmp/fpga_hot_focus_ack.bin; "
            f"(timeout {max(1, int(args.timeout))} dd if={args.device} bs=1 "
            f"count={response_bytes} of=/tmp/fpga_hot_focus_ack.bin 2>/dev/null) & "
            "reader=$!; sleep 0.1; "
            f"cat /tmp/fpga_hot_focus_command.bin > {args.device}; wait $reader"
        )
        adb(args.adb, "shell", shell)
        adb(args.adb, "pull", "/tmp/fpga_hot_focus_ack.bin", str(rx_path))
        response = rx_path.read_bytes()

    body = verify_response(response, subcommand)
    if args.query:
        if len(body) != 15:
            raise RuntimeError(f"热点查询响应长度错误：{len(body)}")
        flags = body[4]
        x = int.from_bytes(body[5:7], "big")
        y = int.from_bytes(body[7:9], "big")
        total = int.from_bytes(body[9:11], "big")
        result_count = int.from_bytes(body[11:13], "big")
        dropped_count = int.from_bytes(body[13:15], "big")
        print(f"热点追踪：{'开' if flags & 1 else '关'}")
        print(f"极性：{'黑热' if flags & 2 else '白热'}")
        print(f"结果：{'有效' if flags & 4 else '无效'}")
        print(f"坐标：({x}, {y})，3x3和={total}")
        print(f"结果帧={result_count}，丢弃帧={dropped_count}")
    else:
        print("热点追踪已打开" if args.enable else "热点追踪已关闭")
        if args.enable:
            print("模式：黑热" if args.black_hot else "模式：白热")
    print("发送：", spaced_hex(command))
    print("返回：", spaced_hex(response))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
