#!/usr/bin/env python3
"""compare_baseline.py —— 改造前后的输出像素序列回归对比（任务 2.7）

基线是**改造前**（叠加色 16'h8010、字节内 LSB 为最左、4 个基址参数由 A 推导）导出的
一帧输出；对比对象是改造后的同一帧。两者有三处**预期之内**的差异，脚本负责把它们
与真正的回归区分开：

  1. 叠加色         0x8010 -> 0x80EB      （任务 2.1）
  2. 位图打包约定   LSB -> MSB first       （任务 2.8）
     —— 两次运行各自"按自己的约定打包、按自己的约定解释"，所以**被叠加的像素集合
        应当逐个相同**；这一点由本脚本验证，而不是放过。
  3. 位序探针行     窗口 0 的第 0 行被测试平台改写成探针字节（8'h80 / 8'h01），
     只影响扫描最后一行（disp_y = 0）的 x=0..15。

判据：
  - 透传像素必须**逐字节相同**；
  - 被叠加的像素必须是 0x8010(旧) 与 0x80EB(新) 的一一对应；
  - 除探针行外不允许出现其它差异。

用法：
    python sim/compare_baseline.py sim/baseline_before.txt sim/out_after.txt [帧宽]
"""
import sys

OLD_COLOR = 0x8010
NEW_COLOR = 0x80EB


def main() -> int:
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    before_path, after_path = sys.argv[1], sys.argv[2]
    frame_w = int(sys.argv[3]) if len(sys.argv) > 3 else 720

    with open(before_path) as f:
        before = [int(line, 16) for line in f if line.strip()]
    with open(after_path) as f:
        after = [int(line, 16) for line in f if line.strip()]

    if len(before) != len(after):
        print(f"FAIL: 样本数不同：{len(before)} vs {len(after)}")
        return 1

    # 探针行 = 扫描最后一行（disp_y = 0，即窗口 0 的第 0 行）。
    # 测试平台把窗口 0 的这一行**整行**改写成探针（前两字节 8'h80/8'h01，其余清零），
    # 所以该行 x=0..W0-1 的叠加分布与基线本就不同 —— 整行跳过。
    # 代价是 720/414720 ≈ 0.17% 的样本不参与对比，可接受。
    height = len(before) // frame_w
    probe_row_start = (height - 1) * frame_w
    probe_row_end = probe_row_start + frame_w

    passthrough_same = 0
    recolored = 0
    probe_row_skipped = 0
    bad = []

    for i, (b, a) in enumerate(zip(before, after)):
        if probe_row_start <= i < probe_row_end:
            probe_row_skipped += 1
            continue
        if b == a:
            passthrough_same += 1
        elif b == OLD_COLOR and a == NEW_COLOR:
            recolored += 1
        else:
            if len(bad) < 10:
                bad.append((i, b, a))

    print(f"样本总数            : {len(before)}")
    print(f"逐像素相同(透传)    : {passthrough_same}")
    print(f"叠加色重映射 8010->80EB : {recolored}")
    print(f"探针行跳过          : {probe_row_skipped}")
    print(f"**非预期差异**      : {len(bad)}")
    for i, b, a in bad:
        print(f"  idx={i} (x={i % frame_w}, y={i // frame_w}) 基线={b:04x} 现在={a:04x}")

    if bad:
        print("FAIL: 存在超出预期的回归差异")
        return 1
    if recolored == 0:
        print("FAIL: 一个被叠加的像素都没有 —— 说明叠加整个失效了，而不是「没差异」")
        return 1
    print("PASS: 透传像素逐字节一致，叠加像素仅色值按预期变化")
    return 0


if __name__ == "__main__":
    sys.exit(main())
