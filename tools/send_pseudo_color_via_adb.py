#!/usr/bin/env python3
"""Select/query TI60 FPGA pseudo color through X2000 /dev/ttyS1."""

import argparse
import pathlib
import subprocess
import tempfile


HEADER = 0xBB
FOOTER = 0xAA
CATEGORY = 0x03
SUB_SET = 0x01
SUB_QUERY = 0x02
SUB_THRESHOLD_SET = 0x03
SUB_THRESHOLD_QUERY = 0x04
TYPE_WRITE = 0x00
TYPE_ACK = 0x02
MACHINE_WHITE_HOT = bytes.fromhex("AA 05 01 42 02 00 F4 EB AA")
MODES = {
    "white-hot": 0,
    "black-hot": 1,
    "red-hot": 2,
    "iron-red": 3,
    "rainbow": 4,
    "green-hot": 5,
    "outline": 6,
}


def spaced_hex(data):
    return " ".join("{:02x}".format(value) for value in data)


def crc16_ccitt(data):
    crc = 0
    for value in data:
        crc ^= value << 8
        for _ in range(8):
            crc = ((crc << 1) ^ 0x1021) & 0xFFFF if crc & 0x8000 else (crc << 1) & 0xFFFF
    return crc


def make_packet(subcommand, payload=b""):
    body = bytes((CATEGORY, subcommand, TYPE_WRITE)) + payload
    return (bytes((HEADER,)) + len(body).to_bytes(2, "big") + body +
            crc16_ccitt(body).to_bytes(2, "big") + bytes((FOOTER,)))


def adb(adb_exe, *args):
    subprocess.run([adb_exe, *args], check=True)


def verify_response(data, subcommand):
    if len(data) < 10 or data[0] != HEADER or data[-1] != FOOTER:
        raise RuntimeError("响应帧格式错误：{}".format(spaced_hex(data)))
    body_length = int.from_bytes(data[1:3], "big")
    if len(data) != body_length + 6:
        raise RuntimeError("响应长度错误：声明{}，实际{}".format(
            body_length, len(data)))
    body = data[3:3 + body_length]
    received_crc = int.from_bytes(data[3 + body_length:5 + body_length], "big")
    if crc16_ccitt(body) != received_crc:
        raise RuntimeError("响应CRC错误：{}".format(spaced_hex(data)))
    if body[:3] != bytes((CATEGORY, subcommand, TYPE_ACK)):
        raise RuntimeError("响应命令不匹配：{}".format(spaced_hex(data)))
    if len(body) < 4 or body[3] != 0xFF:
        status = body[3] if len(body) >= 4 else 0
        raise RuntimeError("FPGA拒绝伪彩命令，状态=0x{:02X}".format(status))
    return body


def exchange(args, command, response_bytes):
    with tempfile.TemporaryDirectory() as directory:
        tx_path = pathlib.Path(directory) / "pseudo_color_command.bin"
        rx_path = pathlib.Path(directory) / "pseudo_color_ack.bin"
        tx_path.write_bytes(command)
        adb(args.adb, "push", str(tx_path), "/tmp/fpga_pseudo_color_command.bin")
        shell = (
            "stty -F {0} 115200 cs8 -cstopb -parenb -crtscts raw -echo; "
            "rm -f /tmp/fpga_pseudo_color_ack.bin; "
            "(timeout {1} dd if={0} bs=1 count={2} "
            "of=/tmp/fpga_pseudo_color_ack.bin 2>/dev/null) & "
            "reader=$!; sleep 0.1; "
            "cat /tmp/fpga_pseudo_color_command.bin > {0}; wait $reader"
        ).format(args.device, max(1, int(args.timeout)), response_bytes)
        adb(args.adb, "shell", shell)
        adb(args.adb, "pull", "/tmp/fpga_pseudo_color_ack.bin", str(rx_path))
        return rx_path.read_bytes()


def send_machine_packet(args, packet, remote_name):
    with tempfile.TemporaryDirectory() as directory:
        path = pathlib.Path(directory) / remote_name
        remote_path = "/tmp/{}".format(remote_name)
        path.write_bytes(packet)
        adb(args.adb, "push", str(path), remote_path)
        adb(args.adb, "shell",
            "stty -F {0} 115200 cs8 -cstopb -parenb -crtscts raw -echo; "
            "cat {1} > {0}; sleep 0.15".format(args.device, remote_path))


def force_machine_white(args):
    send_machine_packet(args, MACHINE_WHITE_HOT, "machine_white_hot.bin")


def main():
    parser = argparse.ArgumentParser(description="控制TI60 FPGA伪彩色")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--mode", choices=sorted(MODES))
    group.add_argument("--query", action="store_true")
    group.add_argument("--threshold", type=int,
                       help="设置Sobel轮廓阈值，范围0..255")
    group.add_argument("--query-threshold", action="store_true")
    parser.add_argument("--force-machine-white", action="store_true",
                        help="设置FPGA模式前先向机芯发送一次白热命令")
    parser.add_argument("--adb", default="adb", help="adb.exe路径或命令名")
    parser.add_argument("--device", default="/dev/ttyS1")
    parser.add_argument("--timeout", type=float, default=5.0)
    args = parser.parse_args()

    if args.force_machine_white:
        force_machine_white(args)

    if args.query:
        subcommand = SUB_QUERY
        command = make_packet(subcommand)
        response_bytes = 17
    elif args.query_threshold:
        subcommand = SUB_THRESHOLD_QUERY
        command = make_packet(subcommand)
        response_bytes = 11
    elif args.threshold is not None:
        if not 0 <= args.threshold <= 255:
            parser.error("--threshold 必须在0..255范围内")
        subcommand = SUB_THRESHOLD_SET
        command = make_packet(subcommand, bytes((args.threshold,)))
        response_bytes = 10
    else:
        subcommand = SUB_SET
        command = make_packet(subcommand, bytes((MODES[args.mode],)))
        response_bytes = 10

    response = exchange(args, command, response_bytes)
    body = verify_response(response, subcommand)
    if args.query:
        if len(body) != 11:
            raise RuntimeError("伪彩查询响应长度错误：{}".format(len(body)))
        mode_names = {value: name for name, value in MODES.items()}
        flags = body[5]
        write_count = int.from_bytes(body[7:9], "big")
        commit_count = int.from_bytes(body[9:11], "big")
        print("模式：{}".format(mode_names.get(body[4], "unknown({})".format(body[4]))))
        print("LUT：{}，bank={}，pending={}".format(
            "有效" if flags & 1 else "旁路", 1 if flags & 4 else 0,
            1 if flags & 2 else 0))
        print("DVP应用={}，CVBS应用={}，错误={}，写入={}，提交={}".format(
            1 if flags & 8 else 0, 1 if flags & 16 else 0, body[6],
            write_count, commit_count))
    elif args.query_threshold:
        if len(body) != 5:
            raise RuntimeError("阈值查询响应长度错误：{}".format(len(body)))
        print("Sobel轮廓阈值：{}".format(body[4]))
    elif args.threshold is not None:
        print("Sobel轮廓阈值已设置并保存：{}".format(args.threshold))
    else:
        print("FPGA伪彩模式已切换：{}".format(args.mode))
    print("发送：", spaced_hex(command))
    print("返回：", spaced_hex(response))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
