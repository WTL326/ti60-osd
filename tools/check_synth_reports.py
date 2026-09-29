#!/usr/bin/env python3
"""check_synth_reports.py —— 综合报告的自动判定（任务 8.1 / 8.2 的验收）

上板前要看的三个东西，人工翻报告既慢又容易漏：
  1. **时序余量**：outflow/<name>.timing.rpt 的"Maximum possible analyzed clocks
     frequency"给出每个时钟**实际需要**的周期；与"User target constrained clocks"
     里的约束周期相减就是该时钟的余量（正=满足）。
  2. **资源**：outflow/<name>.res.csv 里 `top:top` 那一行的总计。
  3. **memory block 与信号保留**：outflow/EFX.warn.log。
     · `EFX-0657 Mapping into logic memory block '<层次>/cacheN_data'` —— 两个缓存
       仍被识别为 memory（这是期望的；若变成触发器，资源会明显增长）。
     · `Removing redundant signal : <名字>` —— **综合删掉了这个信号**。
       这条对本次上板特别关键：待观测的诊断信号（`mask_stall_count` 等）在 top.v 里
       是**没有消费者**的顶层 wire，而 VIO 调试核是在 `efx_map` **之后**才合并的 ——
       第一次综合就可能把它们当冗余删掉，删掉了调试核就选不到网。
       这份报告能在打开 EDB 之前就回答"探针挂得上去吗"。

用法：
    # 1) 改动前先留基线（本仓库的 outflow/ 现在就是改动前的，正是留基线的时候）
    python tools/check_synth_reports.py --save-baseline

    # 2) 综合之后判定（与基线比）
    python tools/check_synth_reports.py

    # 3) 只看当前值、不与基线比
    python tools/check_synth_reports.py --no-baseline

    # 4) 指定另一套报告（例如调试位流那一版）
    python tools/check_synth_reports.py --dir outflow_dbg --no-baseline

退出码：0 = 全部满足；1 = 有判定不通过；2 = 找不到报告文件。
"""
import argparse
import json
import pathlib
import re
import sys

# 输出兜底：Windows 控制台多为 GBK，脚本里万一混进一个编不出的字符（例如 U+2212），
# print 会直接抛 UnicodeEncodeError 把整个判定打断 —— 而那时报告可能已经读完了。
# 换成 errors="replace" 只是让个别字符显示成 ?，判定结果照样出得来。
try:
    sys.stdout.reconfigure(errors="replace")
except Exception:      # 老版本 Python 没有 reconfigure；那就保持原样
    pass

# 需要盯住的信号：本变更新增/新增暴露的掩膜诊断 + 回归清单要看的视频计数器。
# 它们必须**不出现在** "Removing redundant signal" 列表里，否则 VIO 探针挂不上。
WATCHED_SIGNALS = [
    "mask_frame_count", "mask_read_error_count", "mask_reader_active",
    "mask_active_buffer_select", "mask_applied_enable_out", "mask_stall_count",
    "mask_cfg_pending", "mask_cfg_apply",
    "scaler_dropped_frame_count", "read_fifo_underflow_count",
]


def find_reports(d: pathlib.Path) -> dict:
    """在一套 outflow 产物里找需要的三份报告。

    优先取**布线后**的时序报告（`<name>.timing.rpt`，与 .bit 同一批生成），
    它才是有签核意义的；`<name>.place.timing.rpt` 是布线前的，只作兜底。
    """
    timing = sorted(d.glob("*.timing.rpt"),
                    key=lambda p: (".place." in p.name, p.name))
    # 上面把含 .place. 的排到后面；取第一个非 place 的
    pick = None
    for p in timing:
        if ".place." not in p.name:
            pick = p
            break
    if pick is None and timing:
        pick = timing[0]

    res = None
    for cand in ("ivlab239_c.res.csv", "top.res.csv"):
        if (d / cand).exists():
            res = d / cand
            break
    if res is None:
        allres = sorted(d.glob("*.res.csv"))
        res = allres[0] if allres else None

    warn = d / "EFX.warn.log"
    # 综合后的网表报告：用来做"信号到底在不在设计里"的存在性检查。
    # 注意它只是摘要报告、不是完整网表，所以"查不到"只作警告、不作失败判据
    # （见 main 里的说明）。
    mp = None
    for cand in ("ivlab239_c.map.rpt", "top.map.rpt"):
        if (d / cand).exists():
            mp = d / cand
            break
    return {"timing": pick, "res": res,
            "warn": warn if warn.exists() else None, "map": mp}


def parse_clocks(path: pathlib.Path) -> dict:
    """从时序报告里取 {时钟名: {"target_ns":.., "achieved_ns":..}}。

    报告里有两张同构的表，靠小节标题区分：
      "User target constrained clocks"        -> 约束周期
      "Maximum possible analyzed clocks frequency" -> 实际需要的周期
    两表的行格式都是 `名字 周期 频率 ...`，所以同一个解析器能吃两张表。
    """
    text = path.read_text(encoding="utf-8", errors="replace")
    out = {}

    def grab(section: str) -> dict:
        m = re.search(re.escape(section) + r"\s*\n(.*?)(?:\n\s*\n|\Z)", text,
                      re.S)
        if not m:
            return {}
        found = {}
        for line in m.group(1).splitlines():
            f = line.split()
            # 形如: clk  10.000  100.000  {0.000 5.000}  {clk}
            if len(f) >= 3 and re.fullmatch(r"[\d.]+", f[1]) and \
               re.fullmatch(r"[\d.]+", f[2]):
                found[f[0]] = float(f[1])
        return found

    targets = grab("User target constrained clocks")
    achieved = grab("Maximum possible analyzed clocks frequency")
    for name, tgt in targets.items():
        if name in achieved:
            out[name] = {"target_ns": tgt, "achieved_ns": achieved[name],
                         "slack_ns": round(tgt - achieved[name], 3)}
    return out


def parse_resources(path: pathlib.Path) -> dict:
    """取资源报告里顶层那一行（`top:top`）的总计。

    列顺序在表头里，不写死：先读表头行定位列，再读数据行取值 ——
    写死列序的话，换个 Efinity 版本改了列顺序就会静默读错列。
    """
    header = None
    cols = []
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        f = line.split("\t")
        if f and f[0].strip().startswith("Module") and "FFs" in line:
            header = [c.strip() for c in f if c.strip()]
            continue
        if line.startswith("top:top"):
            cells = [c.strip() for c in line.split("\t")][1:]
            vals = [c for c in cells if c]
            out = {}
            for name, v in zip(header[1:] if header else [], vals):
                m = re.match(r"(\d+)", v)
                if m:
                    out[name] = int(m.group(1))
            return out
    return {}


def parse_warn(path: pathlib.Path) -> dict:
    """从告警日志里取两类信息：memory 映射、被删掉的冗余信号。"""
    text = path.read_text(encoding="utf-8", errors="replace")
    # warn.log 可能含多次综合的结果（追加写），同一信号会出现多次 —— 去重后再报，
    # 否则"缓存相关 4 条"看起来像有四个缓存。
    mem, seen = [], set()
    for m in re.finditer(r"EFX-0657 WARNING\] (Mapping into logic memory block '([^']+)' "
                         r"\((\d+) bits\))[^.]*\.", text):
        key = (m.group(2), int(m.group(3)))
        if key in seen:
            continue
        seen.add(key)
        mem.append({"what": m.group(1), "signal": m.group(2),
                    "bits": int(m.group(3))})
    # 行格式是 `... Removing redundant signal : <名字>. (<路径>:<行号>)` ——
    # **名字后面跟着源位置**，所以不能要求"名字之后就是行尾"（首版就是这么写的，
    # 结果一条都匹配不到、打印出"0 个"，而那正是要盯的东西被删掉的时候）。
    # 按 ". (" 收尾：名字里可能有 [] 甚至点号（层次名），但不含 ". ("。
    removed = set(re.findall(r"Removing redundant signal\s*:\s*(.+?)\.\s*\(", text))
    return {"memory": mem, "removed": sorted(removed)}


def main() -> int:
    ap = argparse.ArgumentParser(description="综合报告自动判定（8.1/8.2）")
    ap.add_argument("--dir", default="outflow", help="报告所在目录（默认 outflow）")
    ap.add_argument("--baseline", default="tools/out/synth_baseline.json",
                    help="基线 JSON 的路径")
    ap.add_argument("--save-baseline", action="store_true",
                    help="把当前读数写成基线（改动前跑一次）")
    ap.add_argument("--no-baseline", action="store_true", help="不与基线比较")
    ap.add_argument("--slack-tol", type=float, default=0.2,
                    help="允许的时序余量退化（ns，默认 0.2）")
    ap.add_argument("--res-tol", type=float, default=0.05,
                    help="允许的资源增长比例（默认 5%%）")
    a = ap.parse_args()

    d = pathlib.Path(a.dir)
    if not d.is_dir():
        print(f"FAIL: 找不到报告目录 {d}", file=sys.stderr)
        return 2
    rep = find_reports(d)
    if not rep["timing"] or not rep["res"]:
        print(f"FAIL: {d} 里缺时序或资源报告（找到 {rep}）", file=sys.stderr)
        return 2

    clocks = parse_clocks(rep["timing"])
    res = parse_resources(rep["res"])
    warn = parse_warn(rep["warn"]) if rep["warn"] else {"memory": [], "removed": []}

    print(f"报告目录：{d}")
    print(f"  时序：{rep['timing'].name}")
    print(f"  资源：{rep['res'].name}")
    print(f"  告警：{rep['warn'].name if rep['warn'] else '（无）'}")
    print()

    print("时钟余量（约束周期 - 实际需要周期，正数=满足）：")
    for name, c in sorted(clocks.items(), key=lambda kv: kv[1]["slack_ns"]):
        print(f"    {name:<18} {c['slack_ns']:+8.3f} ns "
              f"(约束 {c['target_ns']:.3f} / 实际 {c['achieved_ns']:.3f})")
    print()

    print("顶层资源：" + "  ".join(f"{k}={v}" for k, v in res.items()))
    print()

    cache_mem = [m for m in warn["memory"] if "cache" in m["signal"]]
    print(f"memory 映射条目：{len(warn['memory'])} 条，其中缓存相关 {len(cache_mem)} 条")
    for m in cache_mem:
        print(f"    {m['signal']}（{m['bits']} bits）-> logic memory block")
    print()

    missing = []
    if rep["map"]:
        map_text = rep["map"].read_text(encoding="utf-8", errors="replace")
        missing = [s for s in WATCHED_SIGNALS if s not in map_text]
        print(f"存在性检查（综合后网表报告 {rep['map'].name}）：")
        if missing:
            print(f"    查不到：{missing}")
            print("    （这份报告是摘要、不是完整网表，查不到不等于被优化；"
                  "但若是新加的信号一个都查不到，先怀疑名字写错或整个模块没进来）")
        else:
            print("    全部待观测信号都能在网表报告里找到")
        print()

    hit = [s for s in WATCHED_SIGNALS if s in warn["removed"]]
    print(f"被综合删掉的冗余信号：{len(warn['removed'])} 个")
    if hit:
        print(f"    **待观测信号里被删掉的：{hit}**")
        print("    → 这些信号在 top.v 里没有消费者，调试核注不上去。"
              "先按计划阶段 0.4 让它们挺过优化（给消费者，或确认可用的 keep 属性），"
              "再重综合。")
    print()

    if a.save_baseline:
        pathlib.Path(a.baseline).parent.mkdir(parents=True, exist_ok=True)
        pathlib.Path(a.baseline).write_text(json.dumps(
            {"clocks": clocks, "resources": res}, indent=2, sort_keys=True,
            ensure_ascii=False), encoding="utf-8")
        print(f"基线已写入：{a.baseline}")
        return 0

    problems = []
    for name, c in clocks.items():
        if c["slack_ns"] < 0:
            problems.append(f"{name} 时序不满足：余量 {c['slack_ns']:+.3f} ns")
    # 8.2 的判据是**二选一**，不是"必须看到警告"。
    # 改动前那两条警告的理由是 "read port is not synchronous"，而本次已把缓存的读改成
    # 同步读（HyperRamMaskOverlayYuv422.v:515-516）—— 于是警告**消失、缓存变成真正的
    # RAM10** 是更好的结局，不该判失败（首版就是这么写的：只要看不到警告就报错，
    # 会把最好的结果判成红的）。
    # 三种结局：
    #   甲 警告仍在                        -> 通过（与改动前等价，行为与仿真一致）
    #   乙 警告消失且 RAM10 上涨            -> 通过（更好）
    #   丙 警告消失但 RAM10 不动            -> **失败**（被展开成离散逻辑/触发器）
    cache_ok = True
    if cache_mem:
        cache_note = "甲：仍映射为 logic memory block（与改动前等价）"
    else:
        base_rams = None
        bp0 = pathlib.Path(a.baseline)
        if bp0.exists():
            try:
                base_rams = json.loads(bp0.read_text(encoding="utf-8"))
                base_rams = base_rams.get("resources", {}).get("RAMs")
            except Exception:
                base_rams = None
        if base_rams is not None and res.get("RAMs", 0) > base_rams:
            cache_note = (f"乙：警告消失且 RAM10 由 {base_rams} 涨到 {res.get('RAMs')}"
                          f" —— 缓存变成了真正的 RAM10（更好）")
        elif base_rams is None:
            cache_note = ("？：警告消失，但没有基线可比 —— 请核对 EFX_RAM10 是否上涨、"
                          "u_hyperram_mask_overlay 的 LUT4 是否下降，两者都不动即为失败态")
            cache_ok = False
            problems.append(cache_note)
        else:
            cache_note = (f"丙（失败态）：警告消失但 RAM10 仍是 {res.get('RAMs')}、"
                          f"未比基线 {base_rams} 上涨 —— 缓存被展开成了离散逻辑/触发器。"
                          f"按计划 R1 加 syn_ramstyle（先例 HotFocusLineBufTi60.v:17）")
            cache_ok = False
            problems.append(cache_note)
    print(f"8.2 判定：{cache_note}")
    print()
    if hit:
        problems.append(f"待观测信号被综合删掉：{hit}")

    if not a.no_baseline:
        bp = pathlib.Path(a.baseline)
        if bp.exists():
            base = json.loads(bp.read_text(encoding="utf-8"))
            print("与基线比较：")
            for name, c in clocks.items():
                b = base.get("clocks", {}).get(name)
                if not b:
                    print(f"    {name:<18} （基线里没有，新型时钟？）")
                    continue
                d_ns = round(c["slack_ns"] - b["slack_ns"], 3)
                flag = "  <== 退化超阈值" if d_ns < -a.slack_tol else ""
                print(f"    {name:<18} {b['slack_ns']:+.3f} -> "
                      f"{c['slack_ns']:+.3f}  ({d_ns:+.3f}){flag}")
                if d_ns < -a.slack_tol:
                    problems.append(f"{name} 余量比基线退化 {d_ns:+.3f} ns"
                                    f"（阈值 -{a.slack_tol}）")
            for k, v in res.items():
                b = base.get("resources", {}).get(k)
                if not b:
                    continue
                pct = (v - b) / b * 100.0 if b else 0.0
                flag = "  <== 增长超阈值" if pct > a.res_tol * 100 else ""
                print(f"    {k:<10} {b} -> {v}  ({pct:+.1f}%){flag}")
                if pct > a.res_tol * 100:
                    problems.append(f"{k} 比基线增长 {pct:+.1f}%（阈值 "
                                    f"{a.res_tol * 100:.0f}%）")
        else:
            print(f"（没有基线 {bp}；改动前先跑一次 --save-baseline）")
    print()

    if problems:
        print("FAIL：")
        for p in problems:
            print(f"    - {p}")
        return 1
    print("PASS：时序全部满足、缓存仍映射为 memory、待观测信号未被删")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
