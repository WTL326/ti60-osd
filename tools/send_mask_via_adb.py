#!/usr/bin/env python3
"""Upload a BMP mask to the FPGA through X2000 UART and ADB.

载荷是 **1 bit/像素打包** 的位图：每字节 8 个像素、bit7 对应行内最左。
打包放在这里（而不是 FPGA 侧）是因为它是 8 倍的链路时间 —— 以 544x288 为例，
115200 8N1 下 8 bit/像素要约 13.6 秒，1 bit/像素只要约 1.7 秒。

上传目标是**固定的一路**（design.md D11 选择（八））：帧格式里没有区域索引字段，
目标由 RTL 侧的基址参数决定。本工具只负责把位图按约定打包后发出去。
"""

import argparse
import math
import pathlib
import struct
import subprocess
import tempfile
from typing import List


ROOT = pathlib.Path(__file__).resolve().parents[2]
DEFAULT_ADB = ROOT / "1280图传测试" / "platform-tools" / "adb.exe"
DEFAULT_IMAGE = ROOT / "mask.bmp"


def crc16_ccitt(data: bytes) -> int:
    crc = 0
    for byte in data:
        crc ^= byte << 8
        for _ in range(8):
            crc = ((crc << 1) ^ 0x1021) & 0xFFFF if crc & 0x8000 else (crc << 1) & 0xFFFF
    return crc


def packet(command: int, payload: bytes) -> bytes:
    body = bytes((0x00, command, 0x00)) + payload
    crc = crc16_ccitt(body)
    return b"\xBB" + struct.pack(">H", len(body)) + body + struct.pack(">H", crc) + b"\xAA"


def read_binary_bmp(path: pathlib.Path, threshold: int,
                    width: int, height: int) -> bytes:
    """读 24 位未压缩 BMP，二值化后**按 1 bit/像素打包**返回。

    位序约定：每个字节的 **bit7 是行内最左**的像素（与 RTL 的
    `pbitsel <= 7 - dx[2:0]`、以及字库的 bit15=最左 一致）。
    """
    data = path.read_bytes()
    if len(data) < 54 or data[:2] != b"BM":
        raise ValueError("输入文件不是BMP")
    pixel_offset = struct.unpack_from("<I", data, 10)[0]
    # 注意别把 BMP 头里的宽高写进 width/height —— 那是本函数的参数（目标尺寸），
    # 覆盖掉之后后面的校验与打包就会全错。首版就撞了这个名字。
    dib_size, bmp_w, bmp_h, planes, bpp, compression = struct.unpack_from(
        "<IiiHHI", data, 14)
    if dib_size < 40 or planes != 1 or bpp != 24 or compression != 0:
        raise ValueError("目前仅支持未压缩24位BMP")
    if bmp_w != width or abs(bmp_h) != height:
        raise ValueError(f"掩膜必须为{width}x{height}，当前为{bmp_w}x{abs(bmp_h)}")
    row_stride = ((bmp_w * 3 + 3) // 4) * 4
    top_down = bmp_h < 0
    if width % 8:
        raise ValueError(f"宽度必须是 8 的倍数（1 bit/像素按字节打包），当前 {width}")
    bytes_per_row = width // 8
    output = bytearray(bytes_per_row * abs(bmp_h))
    for y in range(abs(bmp_h)):
        file_y = y if top_down else abs(bmp_h) - 1 - y
        row = pixel_offset + file_y * row_stride
        for x in range(bmp_w):
            b, g, r = data[row + x * 3:row + x * 3 + 3]
            if min(r, g, b) >= threshold:
                # bit7 是行内最左：第 x 个像素落在字节 x//8 的第 (7 - x%8) 位
                output[y * bytes_per_row + (x >> 3)] |= 0x80 >> (x & 7)
    return bytes(output)


def run(adb: pathlib.Path, *args: str, check: bool = True) -> subprocess.CompletedProcess:
    return subprocess.run([str(adb), *args], check=check, stdout=subprocess.PIPE,
                          stderr=subprocess.STDOUT)


def verify_ack(data: bytes, commands: List[int]) -> None:
    mask_errors = {
        0x00: "通用错误",
        0x01: "参数错误",
        0x02: "范围错误",
        0x03: "掩膜数据不完整",
        0x04: "协议错误",
        0x05: "Flash头或读写错误",
        0x06: "Flash掩膜CRC错误",
        0x07: "AXI掩膜控制错误",
    }
    expected = len(commands)
    if len(data) != expected * 10:
        raise RuntimeError(f"ACK长度错误：收到{len(data)}字节，预期{expected * 10}字节")
    for index, command in enumerate(commands):
        ack = data[index * 10:(index + 1) * 10]
        if ack[0] != 0xBB or ack[-1] != 0xAA or ack[1:3] != b"\x00\x04":
            raise RuntimeError(f"第{index + 1}个ACK帧格式错误：{ack.hex()}")
        body = ack[3:7]
        received_crc = struct.unpack(">H", ack[7:9])[0]
        if body[:3] != bytes((0x00, command, 0x02)) or received_crc != crc16_ccitt(body):
            raise RuntimeError(f"第{index + 1}个ACK命令或CRC错误：{ack.hex()}")
        if body[3] != 0xFF:
            reason = mask_errors.get(body[3], f"未知错误码0x{body[3]:02X}")
            raise RuntimeError(
                f"FPGA拒绝第{index + 1}个0x{command:02X}命令：{reason}；ACK={ack.hex()}"
            )


def main() -> int:
    parser = argparse.ArgumentParser(description="经ADB和X2000 UART上传HyperRAM掩膜")
    parser.add_argument("--adb", type=pathlib.Path, default=DEFAULT_ADB)
    parser.add_argument("--image", type=pathlib.Path, default=DEFAULT_IMAGE)
    parser.add_argument("--device", default="/dev/ttyS1")
    parser.add_argument("--x", type=int, default=150, help="掩膜左上角X坐标")
    parser.add_argument("--y", type=int, default=178, help="掩膜左上角Y坐标")
    parser.add_argument("--threshold", type=int, default=240)
    # 目标窗口的尺寸必须与 RTL 侧 OSD0_WIDTH/OSD0_HEIGHT 参数一致（D6：编译期定型）
    parser.add_argument("--width", type=int, default=544,
                        help="掩膜宽度，须为 8 的倍数、且等于 RTL 的 OSD0_WIDTH")
    parser.add_argument("--height", type=int, default=288,
                        help="掩膜高度，须等于 RTL 的 OSD0_HEIGHT")
    parser.add_argument("--chunk", type=int, default=4096)
    parser.add_argument("--persist", action="store_true",
                        help="上传完成后用0x05将掩膜、坐标和开关保存到板载Flash")
    mode = parser.add_mutually_exclusive_group()
    mode.add_argument("--position-only", action="store_true",
                      help="仅发送0x03更新坐标，不重新上传掩膜")
    mode.add_argument("--enable", action="store_true",
                      help="仅发送0x04打开掩膜")
    mode.add_argument("--disable", action="store_true",
                      help="仅发送0x04关闭掩膜")
    args = parser.parse_args()
    if args.persist and (args.position_only or args.enable or args.disable):
        parser.error("--persist只能与完整--image上传流程一起使用")
    if not args.adb.is_file():
        raise FileNotFoundError(f"找不到adb：{args.adb}")
    if not -32768 <= args.x <= 32767 or not -32768 <= args.y <= 32767:
        raise ValueError("坐标必须在有符号16位范围内")
    if not 1 <= args.chunk <= 4096:
        raise ValueError("chunk必须在1～4096之间")

    devices = run(args.adb, "devices").stdout.decode(errors="replace")
    if "\tdevice" not in devices:
        raise RuntimeError("ADB未检测到X2000设备")

    commands: List[int] = []
    packets: List[bytes] = []

    if args.enable or args.disable:
        mask = b""
        packets.append(packet(0x04, b"\x01" if args.enable else b"\x00"))
        commands.append(0x04)
    elif args.position_only:
        mask = b""
        packets.append(packet(0x03, struct.pack(">hh", args.x, args.y)))
        commands.append(0x03)
    else:
        mask = read_binary_bmp(args.image, args.threshold,
                               args.width, args.height)
        packets.append(packet(0x01, struct.pack(">HHI", args.width,
                                                args.height, len(mask))))
        commands.append(0x01)
        for offset in range(0, len(mask), args.chunk):
            packets.append(packet(0x02, struct.pack(">I", offset) +
                                  mask[offset:offset + args.chunk]))
            commands.append(0x02)
        packets.append(packet(0x03, struct.pack(">hh", args.x, args.y)))
        commands.append(0x03)
        packets.append(packet(0x04, b"\x01"))
        commands.append(0x04)
        if args.persist:
            packets.append(packet(0x05, b""))
            commands.append(0x05)

    remote_packet_dir = "/tmp/fpga_mask_packets"
    remote_ack = "/tmp/fpga_mask_ack.bin"
    with tempfile.TemporaryDirectory() as directory:
        local_packet_dir = pathlib.Path(directory) / "fpga_mask_packets"
        local_packet_dir.mkdir()
        local_ack = pathlib.Path(directory) / "ack.bin"
        for index, (command, contents) in enumerate(zip(commands, packets)):
            (local_packet_dir / f"{index:03d}_{command:02x}.bin").write_bytes(contents)
        stream_size = sum(len(contents) for contents in packets)
        if args.enable:
            print(f"打开掩膜：命令包1个；串口流：{stream_size}字节")
        elif args.disable:
            print(f"关闭掩膜：命令包1个；串口流：{stream_size}字节")
        elif args.position_only:
            print(f"仅更新位置：命令包1个；串口流：{stream_size}字节")
        else:
            print(f"掩膜数据：{len(mask)}字节；命令包：{len(commands)}个；串口流：{stream_size}字节")
        run(args.adb, "shell", f"rm -rf {remote_packet_dir}")
        print(run(args.adb, "push", str(local_packet_dir), "/tmp/").stdout.decode(errors="replace"), end="")

        # Open the RX side before every packet and do not send the next packet
        # until its ten-byte ACK has completed.  This prevents the X2000 UART
        # receive FIFO from occasionally dropping one ACK during a 92 KiB
        # uninterrupted transfer.
        shell = (
            f"stty -F {args.device} 115200 cs8 -cstopb -parenb -crtscts raw -echo; "
            f"rm -f {remote_ack}; "
            f"for pkt in {remote_packet_dir}/*.bin; do "
            f"wait_s=2; case \"$pkt\" in *_04.bin|*_05.bin) wait_s=30;; esac; "
            f"(timeout $wait_s dd if={args.device} bs=1 count=10 >> {remote_ack} 2>/dev/null) & "
            f"reader=$!; sleep 0.05; cat \"$pkt\" > {args.device}; wait $reader; "
            f"done; chmod 644 {remote_ack}"
        )
        result = run(args.adb, "shell", shell, check=False)
        if result.returncode:
            raise RuntimeError(result.stdout.decode(errors="replace"))
        print(run(args.adb, "pull", remote_ack, str(local_ack)).stdout.decode(errors="replace"), end="")
        verify_ack(local_ack.read_bytes(), commands)

    if args.enable:
        print("掩膜已打开，FPGA返回1个成功ACK")
    elif args.disable:
        print("掩膜已关闭，FPGA返回1个成功ACK")
    elif args.position_only:
        print(f"位置更新成功：({args.x},{args.y})，将在下一帧边界生效")
        print("请检查VIO：p32增加1，p33和p35保持0。")
    else:
        print(f"上传成功：位置=({args.x},{args.y})，FPGA返回{len(commands)}个成功ACK")
        if args.persist:
            print("掩膜已持久化到板载Flash 0x440000，下次上电将自动恢复")
        print("请检查VIO：p34=0x000168F0，p33=0，p35=0。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
