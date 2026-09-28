#!/usr/bin/env python3
"""check_ports.py —— 例化端口名对账（静态检查）

**为什么需要这个：** ModelSim 的 `vlog` 只做编译、不做展开，而"例化了一个不存在的
端口名"恰恰要到展开期才报。本工程又因为 `ip/` 下有 Efinity 加密 IP 而无法展开，
于是这类错误在编译期完全静默 —— 实测就漏掉了三个（`raw_mode`/`mask_left`/`mask_top`，
是 D2 删端口时留下的连接）。

本脚本做的是语义上很窄但正好补上这个洞的检查：把每个被例化模块的端口名收集起来，
再核对例化里的具名连接是否都在其中。它不解析表达式，只看名字。

用法：python sim/check_ports.py [顶层文件...]   默认检查 src/top.v
退出码：0 = 无问题，1 = 发现不存在的端口名。
"""
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def strip_comment(line: str) -> str:
    """去掉行尾 // 注释。中文注释里常出现标识符样子的词，不剥会把它们当成端口名。"""
    return line.split("//")[0]


def module_ports(text: str):
    """返回 {模块名: {端口名}}。只处理端口表写在模块头里的常见写法。"""
    out = {}
    for m in re.finditer(r"\bmodule\s+(\w+)", text):
        name = m.group(1)
        try:
            pstart = text.index(") (", m.end()) + 3
        except ValueError:
            continue                      # 没有端口表（或写法不同）
        pend = text.find(");", pstart)
        if pend < 0:
            continue
        ports = set()
        for line in text[pstart:pend].splitlines():
            line = strip_comment(line).strip().rstrip(",")
            if not line:
                continue
            pm = re.match(r"(?:input|output|inout)\b.*?(\w+)$", line)
            if pm:
                ports.add(pm.group(1))
        out[name] = ports
    return out


def instantiations(text: str):
    """返回 [(模块名, {连接名}, 行号)]。"""
    out = []
    for m in re.finditer(r"^\s*(\w+)\s*(?:#\s*\([^;]*?\))?\s*(\w+)\s*\(", text, re.M):
        mod, inst = m.group(1), m.group(2)
        if mod in ("module", "if", "else", "begin", "always", "case", "for", "assign"):
            continue
        # 找到本实例的端口连接段
        i = m.end()
        depth = 1
        j = i
        while j < len(text) and depth:
            if text[j] == "(":
                depth += 1
            elif text[j] == ")":
                depth -= 1
            j += 1
        seg = text[i:j]
        conns = set(re.findall(r"\.(\w+)\s*\(", seg))
        line = text[: m.start()].count("\n") + 1
        out.append((mod, conns, line))
    return out


def main() -> int:
    files = sys.argv[1:] or ["src/top.v"]
    texts = {}
    for f in files:
        p = ROOT / f
        texts[f] = p.read_text(encoding="utf-8")

    # 端口定义：先扫顶层文件，再扫 ivlab239.xml 里列出的全部源文件
    ports = {}
    sources = list(texts.values())
    xml = ROOT / "ivlab239.xml"
    if xml.exists():
        for name in re.findall(r'design_file name="([^"]*)"', xml.read_text(encoding="utf-8")):
            p = ROOT / name
            if p.exists():
                sources.append(p.read_text(encoding="utf-8"))
    for t in sources:
        ports.update(module_ports(t))

    bad = 0
    for f, text in texts.items():
        for mod, conns, line in instantiations(text):
            if mod not in ports:
                continue                  # 未见的模块（如厂商 IP）跳过
            extra = sorted(conns - ports[mod])
            if extra:
                bad += 1
                print(f"{f}:{line}: 例化 {mod} 时连接了不存在的端口: {', '.join(extra)}")

    print(f"检查了 {len(ports)} 个模块的端口定义")
    if bad:
        print(f"FAIL: {bad} 处端口名不匹配（vlog 在编译期看不见这类错误）")
        return 1
    print("PASS: 所有具名连接的端口名都存在")
    return 0


if __name__ == "__main__":
    sys.exit(main())
