#!/usr/bin/env python3
"""Test the X2000 -> FPGA -> machine UART command forwarding path."""

import argparse
import pathlib
import subprocess
import tempfile
import time


ROOT = pathlib.Path(__file__).resolve().parents[2]
DEFAULT_ADB = ROOT / "1280图传测试" / "platform-tools" / "adb.exe"

TESTS = (
    (
        "基础通信",
        bytes.fromhex("AA 05 01 01 01 00 B2 EB AA"),
        bytes.fromhex("55 04 01 33 01 8E EB AA"),
    ),
    (
        "快门控制",
        bytes.fromhex("AA 05 01 02 02 01 B5 EB AA"),
        bytes.fromhex("55 04 02 33 01 8F EB AA"),
    ),
)


def run(adb: pathlib.Path, *args: str, check: bool = True) -> subprocess.CompletedProcess:
    return subprocess.run(
        [str(adb), *args],
        check=check,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )


def hex_text(data: bytes) -> str:
    return " ".join(f"{byte:02X}" for byte in data)


def test_command(
    adb: pathlib.Path,
    device: str,
    timeout: int,
    retries: int,
    directory: pathlib.Path,
    name: str,
    command: bytes,
    expected_reply: bytes,
) -> bool:
    remote_command = "/tmp/fpga_machine_test_cmd.bin"
    remote_reply = "/tmp/fpga_machine_test_reply.bin"
    local_command = directory / "machine_cmd.bin"
    local_reply = directory / "machine_reply.bin"
    local_command.write_bytes(command)

    print(f"\n[{name}]")
    print(f"发送：{hex_text(command)}")
    print(f"期望：{hex_text(expected_reply)}")
    print(run(adb, "push", str(local_command), remote_command)
          .stdout.decode(errors="replace"), end="")

    for attempt in range(1, retries + 1):
        # Start the receiver before transmitting so a fast machine reply
        # cannot be lost.  The final ':' makes a timeout non-fatal to adb.
        shell = (
            f"stty -F {device} 115200 cs8 -cstopb -parenb "
            f"-crtscts raw -echo; "
            f"rm -f {remote_reply}; "
            f"(timeout {timeout} dd if={device} bs=1 count=8 "
            f"of={remote_reply} 2>/dev/null) & reader=$!; "
            f"sleep 0.10; cat {remote_command} > {device}; "
            f"wait $reader; chmod 644 {remote_reply} 2>/dev/null; :"
        )
        run(adb, "shell", shell, check=False)
        if local_reply.exists():
            local_reply.unlink()
        run(adb, "pull", remote_reply, str(local_reply), check=False)
        received = local_reply.read_bytes() if local_reply.exists() else b""

        print(f"第{attempt}次收到（{len(received)}字节）："
              f"{hex_text(received) if received else '<无数据>'}")
        if received == expected_reply:
            print(f"{name}测试通过。")
            return True

        if attempt != retries:
            time.sleep(0.5)

    print(f"{name}测试失败：未收到完整的预期返回。")
    return False


def main() -> int:
    parser = argparse.ArgumentParser(
        description="通过ADB和X2000 UART测试FPGA至机芯的0xAA指令转发"
    )
    parser.add_argument("--adb", type=pathlib.Path, default=DEFAULT_ADB)
    parser.add_argument("--device", default="/dev/ttyS1")
    parser.add_argument("--timeout", type=int, default=3,
                        help="每次等待返回的秒数，默认3")
    parser.add_argument("--retries", type=int, default=3,
                        help="无返回或返回错误时的尝试次数，默认3")
    args = parser.parse_args()

    if not args.adb.is_file():
        raise FileNotFoundError(f"找不到adb：{args.adb}")
    if args.timeout < 1 or args.retries < 1:
        raise ValueError("--timeout和--retries必须大于0")

    devices = run(args.adb, "devices").stdout.decode(errors="replace")
    if "\tdevice" not in devices:
        raise RuntimeError("ADB未检测到X2000设备")

    with tempfile.TemporaryDirectory() as directory:
        workdir = pathlib.Path(directory)
        first_name, first_command, first_reply = TESTS[0]
        if not test_command(args.adb, args.device, args.timeout, args.retries,
                            workdir, first_name, first_command, first_reply):
            print("基础通信未通过，不发送快门命令。")
            return 1

        print("基础通信正确，下一步发送快门命令，请观察机芯动作。")
        time.sleep(0.5)
        second_name, second_command, second_reply = TESTS[1]
        if not test_command(args.adb, args.device, args.timeout, args.retries,
                            workdir, second_name, second_command, second_reply):
            return 1

    print("全部测试通过：两条返回均正确，请同时确认机芯完成快门动作。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
