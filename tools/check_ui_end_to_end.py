#!/usr/bin/env python3
"""8.6 的可复现验收：0x04 UI 三条路径 + 回读一致性。

判据来自 `docs/osd_bitmap_contract.md` §7 的联调项与
`openspec/changes/add-quad-osd-overlay/tasks.md` 的 8.6：
    `--view` / `--image-values` / `--query-view` 三条路径全部返回"UI命令成功"，
    且 `--query-view` 回读的 页面 / 选中项 / 显示 / 编辑 / 数值 与下发一致。

为什么单独写一个脚本，而不是手敲几条 `send_ui_via_adb.py`：
  8.6 的判据是"逐字段一致"，手工做要敲 6~8 条命令并逐条比对回包，很容易看走眼；
  而要把实测值回填进 `tasks.md` 又必须**逐字节准确**。这里把整串动作固定下来，
  每步的发送帧与回包都记进一条记录，跑完直接给出一段可粘贴的实测块。

复用与不复用（这是本文件唯一需要解释的取舍）：
  * **复用** `send_ui_via_adb` 的纯函数（`packet` / `crc16` / `PAGES` / 常量）——
    帧构造与 CRC 必须只有一份实现，否则 `--dry-run` 校验的是另一套编码，等于没校验。
    注意那个模块里叫 `crc16`，不是 `crc16_ccitt`。
  * **不复用**它的 `exchange()`：那里是 `subprocess.run(..., check=True)`，而 shell 末尾是
    `wait $reader`，超时会以 `dd` 的退出码 124 结束整条 shell、直接抛 `CalledProcessError`，
    而且没有重试。传输层照 `test_machine_command_via_adb.py` 的既有范式写：
    `check=False` + shell 末尾补 `:` + 重试循环。

三条边界（都不是猜的，写下来免得下一个人重踩）：
  ① **只认三页**。固件的场景表只有 `0x0000` / `0x0100` / `0x0200`
     （`src/osd/scene_table.c:8-57`），而 `PAGES` 有 26 个键
     （`tools/send_ui_via_adb.py:11-24`）。`--view zoom` 之类在工具层合法、到固件会被拒
     —— 本脚本只用 root / image / palette，并把 zoom 当**负向用例**。
  ② **`0x0200` 的语义与文档不符**：`docs/x2000_ui_protocol.md` §4 叫它"调色板"，
     固件实际实现成 `IMAGE MODE`（`scene_table.c:44-56`）。断言只保证
     "ID 为 0x0200 的页面被切过去了"，**不代表调色板页跑通了**。
  ③ **脚本不幂等**：`ui_init()` 的四个数值初值 `[3,5,7,5]`（`src/osd/ui.c:179-182`）
     只在冷启动后存在，而 `SET_VIEW` **不复位**它们（`ui.c:219-221`）。所以基线那一步
     只记录、不断言，末尾再用 `--image-values 3 5 7 5` 复原。

不涉及的子项：`0x01`–`0x05`（`--show` / `--hide` / `--key` / `--clear` / `--marker`）在固件里是
"只解析、不应答、不计入坏包"（`src/osd/protocol.c:230-240`），**必然超时是预期行为**，
所以本脚本不给它们留入口。
"""

import argparse
import pathlib
import subprocess
import sys
import tempfile
import time

# 与 send_mask_via_adb.py:21 同口径（parents[2] = H:/Project，再拼 1280图传测试）。
# 注意本目录里同名常量有两个不同值：tools/test_mask_packing.py 用的是 parents[1]。
ROOT = pathlib.Path(__file__).resolve().parents[2]
DEFAULT_ADB = ROOT / "1280图传测试" / "platform-tools" / "adb.exe"

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parent))
import send_ui_via_adb as sui  # noqa: E402  （要先改完 sys.path 才能 import）

REMOTE_TX = "/tmp/fpga_ui_check_cmd.bin"
REMOTE_RX = "/tmp/fpga_ui_check_ack.bin"

# 已知好帧：由 packet() 生成后与上板实测对过。
# 其中 QUERY 那一帧是**硬件锚点** —— 它逐字节等于首次成功往返时实际发出的帧
# （回包 `bb000c040802ff0000000103050705eea2aa`，CRC 已核 MATCH）。
KNOWN_GOOD = {
    "query":              "bb00030408005569aa",
    "view_palette":       "bb000704060002000001b16eaa",
    "view_image_edit":    "bb0007040600010000030af0aa",
    "image_values_0555":  "bb0007040700000505054d27aa",
    "view_root":          "bb0007040600000000015c06aa",
    "image_values_3575":  "bb000704070003050705b099aa",
}


def run(adb: pathlib.Path, *args: str, check: bool = True) -> subprocess.CompletedProcess:
    """统一的 adb 调用。check=False 用于**允许超时**的那几条 shell 命令。"""
    return subprocess.run(
        [str(adb), *args],
        check=check,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
    )


def hex_text(data: bytes) -> str:
    return data.hex()


def parse_ack(frame: bytes, sub: int, expect_len: int) -> bytes:
    """严格三重校验：帧长 + 帧头尾/长度字段自洽 + CRC + body[:3]，返回 body。

    为什么要四道：残包（上一步没读完的字节）会被下一步的 dd 吃进第一帧，
    只校验长度的话可能"假 PASS"。任何一条不过都当失败。
    """
    if len(frame) != expect_len:
        raise ValueError(f"ACK长度错误：收到{len(frame)}字节，预期{expect_len}字节")
    body_len = int.from_bytes(frame[1:3], "big")
    if frame[0] != sui.HEADER or frame[-1] != sui.FOOTER:
        raise ValueError(f"ACK帧头/帧尾错误：{frame.hex()}")
    if expect_len != body_len + 6:
        raise ValueError(f"ACK长度字段与整帧不符：body_len={body_len} 整帧={expect_len}")
    body = frame[3:3 + body_len]
    crc_have = int.from_bytes(frame[3 + body_len:5 + body_len], "big")
    if sui.crc16(body) != crc_have:
        raise ValueError(f"ACK CRC错误：算得0x{sui.crc16(body):04X} 帧内0x{crc_have:04X}")
    if body[:3] != bytes((sui.CATEGORY, sub, sui.TYPE_ACK)):
        raise ValueError(f"ACK命令字不匹配：{body[:3].hex()} 期望"
                         f"{bytes((sui.CATEGORY, sub, sui.TYPE_ACK)).hex()}")
    return body


def exchange(adb, device, frame, expect_len, timeout, retries):
    """发一帧、收一帧，返回收到的原始字节（可能为空）。

    只在"长度不对"时重试 —— 那属于链路抖动；语义错误由调用方判、且**不重试**
    （重试会把"命令被拒"变成"命令成功"，掩盖真实行为）。
    """
    with tempfile.TemporaryDirectory() as directory:
        tx = pathlib.Path(directory) / "ui_cmd.bin"
        rx = pathlib.Path(directory) / "ui_ack.bin"
        tx.write_bytes(frame)
        run(adb, "push", str(tx), REMOTE_TX, check=False)

        received = b""
        for attempt in range(1, retries + 1):
            # 先起收端再发，否则快到没边的应答会丢。末尾的 ':' 让超时对 adb 非致命。
            shell = (
                f"stty -F {device} 115200 cs8 -cstopb -parenb -crtscts raw -echo; "
                f"rm -f {REMOTE_RX}; "
                f"(timeout {timeout} dd if={device} bs=1 count={expect_len} "
                f"of={REMOTE_RX} 2>/dev/null) & reader=$!; "
                f"sleep 0.10; cat {REMOTE_TX} > {device}; "
                f"wait $reader; chmod 644 {REMOTE_RX} 2>/dev/null; :"
            )
            run(adb, "shell", shell, check=False)
            if rx.exists():
                rx.unlink()
            run(adb, "pull", REMOTE_RX, str(rx), check=False)
            received = rx.read_bytes() if rx.exists() else b""
            if len(received) == expect_len:
                break
            if attempt != retries:
                time.sleep(0.5)
        return received


def make_frame(sub, payload=b""):
    return sui.packet(sub, payload)


def frame_set_view(page_key, selected=0, edit=False, hidden=False):
    flags = (0 if hidden else 1) | (2 if edit else 0)
    return make_frame(6, sui.PAGES[page_key].to_bytes(2, "big")
                         + bytes((selected, flags)))


def frame_image_values(values):
    return make_frame(7, bytes(values))


FRAME_QUERY = make_frame(8)


def read_query(adb, device, timeout, retries):
    """发一帧 QUERY_VIEW，返回 (解析结果 dict, 原始回包)。"""
    rx = exchange(adb, device, FRAME_QUERY, 18, timeout, retries)
    body = parse_ack(rx, 8, 18)              # 抛异常即失败
    if body[3] != 0xFF:
        raise ValueError(f"QUERY_VIEW 返回失败：status=0x{body[3]:02X} 帧={rx.hex()}")
    return {
        "page": int.from_bytes(body[4:6], "big"),
        "sel": body[6],
        "visible": bool(body[7] & 0x01),
        "edit": bool(body[7] & 0x02),
        "values": list(body[8:12]),
    }, rx


def send_set_view(adb, device, frame, timeout, retries):
    """发 SET_VIEW，期望成功（status=0xFF）。返回回包。"""
    rx = exchange(adb, device, frame, 10, timeout, retries)
    body = parse_ack(rx, 6, 10)
    if body[3] != 0xFF:
        raise ValueError(f"SET_VIEW 被拒：status=0x{body[3]:02X} 帧={rx.hex()}")
    return rx


def send_image_values(adb, device, values, timeout, retries):
    rx = exchange(adb, device, frame_image_values(values), 10, timeout, retries)
    body = parse_ack(rx, 7, 10)
    if body[3] != 0xFF:
        raise ValueError(f"SET_IMAGE_VALUES 被拒：status=0x{body[3]:02X} 帧={rx.hex()}")
    return rx


def describe(state):
    return (f"页面=0x{state['page']:04X} 选中项={state['sel']} "
            f"显示={state['visible']} 编辑={state['edit']} 数值={state['values']}")


def dry_run():
    """不上板：把本脚本会发出的每一帧打出来，并与已知好帧逐字节比对。

    这是唯一能在没有 X2000/板子时证明"脚本没写错"的办法 —— 所以它必须在
    任何 adb 调用**之前**返回。
    """
    cases = [
        ("query-view", FRAME_QUERY, "query"),
        ("view palette", frame_set_view("palette"), "view_palette"),
        ("view image --selected 0 --edit", frame_set_view("image", 0, edit=True),
         "view_image_edit"),
        ("image-values 0 5 5 5", frame_image_values([0, 5, 5, 5]), "image_values_0555"),
        ("view root", frame_set_view("root"), "view_root"),
        ("image-values 3 5 7 5（结尾复原）", frame_image_values([3, 5, 7, 5]),
         "image_values_3575"),
    ]
    bad = 0
    print("--dry-run：发送帧与已知好帧比对（不发任何 ADB 命令）")
    for label, frame, key in cases:
        want = KNOWN_GOOD[key]
        ok = frame.hex() == want
        bad += 0 if ok else 1
        print(f"  [{'OK ' if ok else 'BAD'}] {label:<34} {frame.hex()}")
        if not ok:
            print(f"        期望 {want}")

    # 负向用例的帧不属于"已知好帧"，只打印出来供人核对字段
    print("  负向用例（固件应当拒绝，故不比对已知好帧）：")
    print(f"    --view palette --edit  {frame_set_view('palette', 0, edit=True).hex()}")
    print(f"    --view zoom            {frame_set_view('zoom').hex()}")

    print("--dry-run 结果：", "全部与已知好帧一致" if bad == 0 else f"{bad} 条不一致")
    return 1 if bad else 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description="0x04 UI 端到端验收（8.6）：三条路径 + 回读一致性")
    parser.add_argument("--adb", type=pathlib.Path, default=DEFAULT_ADB)
    parser.add_argument("--device", default="/dev/ttyS1")
    parser.add_argument("--timeout", type=int, default=5,
                        help="每次等待回包的秒数，默认 5（不要低于 3）")
    parser.add_argument("--retries", type=int, default=2,
                        help="链路层重试次数（仅在长度不对时重试）")
    parser.add_argument("--dry-run", action="store_true",
                        help="只校验将要发送的帧，不接触设备")
    args = parser.parse_args()

    if args.dry_run:
        return dry_run()

    # 这三条校验放在 dry-run 之后：没有设备时也能自测脚本本身。
    if not args.adb.is_file():
        raise FileNotFoundError(f"找不到adb：{args.adb}")
    if args.timeout < 3:
        raise ValueError("--timeout 不要低于 3 秒：SET_VIEW/SET_IMAGE_VALUES 的应答是"
                         "等画布提交之后才发的")
    if args.retries < 1:
        raise ValueError("--retries 必须大于0")

    devices = run(args.adb, "devices").stdout.decode(errors="replace")
    if "\tdevice" not in devices:
        raise RuntimeError("ADB未检测到X2000设备")

    adb, dev, to, rt = args.adb, args.device, args.timeout, args.retries
    records = []          # (说明, 发送帧 hex, 回包 hex, 解析/判定)

    def record(label, tx, rx, note):
        records.append((label, tx.hex() if isinstance(tx, bytes) else tx,
                        rx.hex() if isinstance(rx, bytes) else rx, note))

    def fail(label, exc):
        r"""任一步失败**立即中止**：不做后续步，避免残包被下一步吃进第一帧造成假 PASS。"""
        print(f"\n[FAIL] {label}：{exc}")
        print("\n（已中止。若刚出现过「全哑」，先重烧位流/复位再跑一遍——"
              "本变更调试期间遇到过：位流重烧后回程才恢复。）")
        print_report(records)
        return 1

    print("0x04 UI 端到端验收（8.6）")
    try:
        # ---- 步 1：基线，只记录不断言（脚本不幂等，见文件头 ③） ----
        base, rx = read_query(adb, dev, to, rt)
        record("1 基线（只记录）", FRAME_QUERY, rx, describe(base))
        print(f"  基线       {describe(base)}")

        # ---- 步 2/3：切到 0x0200，回读断言 ----
        tx = frame_set_view("palette")
        rx = send_set_view(adb, dev, tx, to, rt)
        record("2 --view palette", tx, rx, "ACK 成功")
        st, rx = read_query(adb, dev, to, rt)
        record("3 QUERY 回读", FRAME_QUERY, rx, describe(st))
        assert st["page"] == sui.PAGES["palette"], f"页面应为0x0200，实为0x{st['page']:04X}"
        assert st["sel"] == 0, f"选中项应为0，实为{st['sel']}"
        assert st["visible"], "显示应为True"
        assert not st["edit"], "0x0200 不是图像设置页，编辑位应为False"
        print(f"  切页后     {describe(st)}")

        # ---- 步 4/5：切到图像设置页并进编辑态 ----
        tx = frame_set_view("image", 0, edit=True)
        rx = send_set_view(adb, dev, tx, to, rt)
        record("4 --view image --selected 0 --edit", tx, rx, "ACK 成功")
        st, rx = read_query(adb, dev, to, rt)
        record("5 QUERY 回读", FRAME_QUERY, rx, describe(st))
        assert st["page"] == sui.PAGES["image"], f"页面应为0x0100，实为0x{st['page']:04X}"
        assert st["edit"], "编辑位应为True（图像设置页前四项允许编辑）"
        print(f"  进编辑态   {describe(st)}")
        before_values = st

        # ---- 步 6/7：改四个数值并回读 ----
        tx = frame_image_values([0, 5, 5, 5])
        rx = send_image_values(adb, dev, [0, 5, 5, 5], to, rt)
        record("6 --image-values 0 5 5 5", tx, rx, "ACK 成功")
        st, rx = read_query(adb, dev, to, rt)
        record("7 QUERY 回读", FRAME_QUERY, rx, describe(st))
        assert st["values"] == [0, 5, 5, 5], f"数值应为[0,5,5,5]，实为{st['values']}"
        assert st["page"] == before_values["page"], "改数值不应换页"
        assert st["edit"] == before_values["edit"], "改数值不应改编辑态"
        print(f"  改数值后   {describe(st)}")

        # ---- 步 8：负向 1 —— 在非图像设置页请求编辑态，必须整帧被拒 ----
        tx = frame_set_view("palette", 0, edit=True)
        rx = exchange(adb, dev, tx, 10, to, rt)
        body = parse_ack(rx, 6, 10)
        assert body[3] == 0x00, f"0x0200 上请求编辑态应被拒，却返回0x{body[3]:02X}"
        record("8 负向：--view palette --edit", tx, rx, "被拒 status=0x00")
        st_after, rx = read_query(adb, dev, to, rt)
        record("8′ QUERY 回读", FRAME_QUERY, rx, describe(st_after))
        assert st_after == st, "被拒的命令不应改变任何状态"
        print(f"  负向1      被拒，状态未变")

        # ---- 步 9：负向 2 —— 工具层合法但固件没有这一页 ----
        tx = frame_set_view("zoom")
        rx = exchange(adb, dev, tx, 10, to, rt)
        body = parse_ack(rx, 6, 10)
        assert body[3] == 0x00, f"固件无0x0300，应被拒，却返回0x{body[3]:02X}"
        record("9 负向：--view zoom（固件无此页）", tx, rx, "被拒 status=0x00")
        st_after2, rx = read_query(adb, dev, to, rt)
        record("9′ QUERY 回读", FRAME_QUERY, rx, describe(st_after2))
        assert st_after2 == st, "被拒的命令不应改变任何状态"
        print(f"  负向2      被拒，状态未变")

        # ---- 步 10：复原四个数值，便于下次冷启动对照 ----
        tx = frame_image_values([3, 5, 7, 5])
        rx = send_image_values(adb, dev, [3, 5, 7, 5], to, rt)
        record("10 复原 --image-values 3 5 7 5", tx, rx, "ACK 成功")
        print(f"  已复原")
    except Exception as exc:            # noqa: BLE001  （验收脚本要给出结论而不是堆栈）
        return fail("某一步失败", exc)

    print("\n全部通过：三条路径均返回成功，且回读与下发一致。")
    print_report(records)
    return 0


def print_report(records):
    """打印可直接粘进 tasks.md 的实测块。"""
    print("\n----- 以下可直接粘进 tasks.md 的 8.6 实测段 -----")
    print("| 步 | 发送帧 | 回包 | 解析 |")
    print("|---|---|---|---|")
    for label, tx, rx, note in records:
        print(f"| {label} | `{tx}` | `{rx}` | {note} |")
    print("----- 实测块结束 -----")


if __name__ == "__main__":
    raise SystemExit(main())
