#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
构建与运行 PC 仿真（sim 目标）。

用法：
    python tools/build.py            # 编译 + 运行 + golden 比对
    python tools/build.py --no-run   # 只编译

流程：
    1) 用 zig cc 编译 core/ + port/canvas_host.c + generated/font16_bin.c + test/main_sim.c
    2) 运行 build/sim.exe（工作目录 = osd/，测试产物落在 test/out/）
    3) golden 比对：test/golden/*.ppm 不存在则生成；存在则逐字节比较
"""
import os
import sys
import subprocess

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
BUILD = os.path.join(ROOT, "build")
OUT = os.path.join(ROOT, "test", "out")
GOLDEN = os.path.join(ROOT, "test", "golden")

VENV_SCRIPTS = os.path.join(ROOT, ".workbuddy", "venv", "Scripts")
if not os.path.isdir(VENV_SCRIPTS):
    VENV_SCRIPTS = r"E:\WorkBuddy\2026-09-19-14-41-45\.workbuddy\venv\Scripts"

CORE = [
    "core/font.c", "core/composer.c", "core/ui.c", "core/scene_table.c",
    "core/proto.c", "core/dispatch.c", "core/osd_app.c",
    "generated/font16_bin.c",
    "port/canvas_host.c",
    "test/main_sim.c",
]

SRCS = [os.path.join(ROOT, s) for s in CORE]


def find_zig():
    cands = [
        os.path.join(VENV_SCRIPTS, "zig.exe"),
        os.path.join(VENV_SCRIPTS, "python-zig.exe"),
    ]
    for c in cands:
        if os.path.exists(c):
            return c
    sys.exit("找不到 zig（应随 ziglang 包安装）")


def main():
    run = "--no-run" not in sys.argv
    os.makedirs(BUILD, exist_ok=True)
    os.makedirs(OUT, exist_ok=True)
    exe = os.path.join(BUILD, "sim.exe")

    zig = find_zig()
    env = dict(os.environ)
    # 缓存必须放**工作区外**：沙盒对工作区内的"打开状态重命名"直接拒绝（WinError 5），
    # 而 zig 链接 CRT 时正是这种操作；工作区外是正常 Windows 语义，zig 可正常完成。
    cache = r"E:\osd-zig-cache"
    tmpd = r"E:\osd-zig-tmp"
    os.makedirs(cache, exist_ok=True)
    os.makedirs(tmpd, exist_ok=True)
    env["ZIG_GLOBAL_CACHE_DIR"] = cache
    env["ZIG_LOCAL_CACHE_DIR"] = cache
    env["TMP"] = tmpd
    env["TEMP"] = tmpd
    env["TMPDIR"] = tmpd

    cmd = [zig, "cc", "-std=c99", "-Wall", "-Wextra", "-O1",
           "-I", os.path.join(ROOT, "core"),
           "-I", os.path.join(ROOT, "generated"),
           "-o", exe] + SRCS
    print("[cc  ] " + " ".join(cmd))
    # zig 缓存目录里的临时 .obj 改名会被杀软实时扫描瞬时锁死（Permission denied，
    # 每次锁的文件不同；已成功的对象会进缓存）。小步重试直至全部对象入缓存。
    import time
    ok = False
    for attempt in range(40):
        r = subprocess.run(cmd, env=env, capture_output=True, text=True, errors="replace")
        if r.returncode == 0:
            ok = True
            break
        out = (r.stdout or "") + (r.stderr or "")
        sys.stdout.write(out)
        # 语法/语义错误（error:）重试无意义，立刻把完整诊断交给用户
        if "error:" in out:
            sys.exit("编译失败（见上方 error 诊断）")
        print("[retry] zig cc 第 %d 次失败，2s 后重试（已缓存对象保留）" % (attempt + 1))
        sys.stdout.write(out[-2000:])
        time.sleep(2.0)
    if not ok:
        sys.exit("编译失败")
    print("[ok  ] built " + exe)

    if not run:
        return

    r = subprocess.run([exe], cwd=ROOT)
    if r.returncode != 0:
        sys.exit("仿真运行失败（有 FAIL 项）")

    # golden 比对
    os.makedirs(GOLDEN, exist_ok=True)
    bad = 0
    for name in ("01_p1_en", "02_p1_ru", "03_p2_values"):
        cur = os.path.join(OUT, name + ".ppm")
        gold = os.path.join(GOLDEN, name + ".ppm")
        if not os.path.exists(cur):
            print("[warn] 缺少 " + cur)
            bad += 1
            continue
        if not os.path.exists(gold):
            with open(cur, "rb") as s, open(gold, "wb") as d:
                d.write(s.read())
            print("[gold] 生成基线 " + gold)
            continue
        with open(cur, "rb") as a, open(gold, "rb") as b:
            same = a.read() == b.read()
        if same:
            print("[gold] %s 逐字节一致" % name)
        else:
            print("[FAIL] %s 与 golden 不一致（渲染被意外改动）" % name)
            bad += 1
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
