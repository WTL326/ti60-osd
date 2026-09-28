#!/usr/bin/env bash
# =============================================================================
# compile_all.sh —— 编译**整个设计**（任务 4.1/4.4 的验收脚本）
#
# 为什么需要它：`top.v` 的 `include` 覆盖整个工程，且例化了 ip/ 下的模块。
# 单独编译 top.v 会缺 include 与子模块，必须按 ivlab239.xml 的 design_file
# 列表把全部源文件连同 include 目录一起交给 vlog。
#
# 文件列表**从 ivlab239.xml 现场解析**，而不是在脚本里另抄一份 ——
# 抄一份就会有"工程加了文件、脚本忘了加"的漂移。
#
# 用法：bash sim/compile_all.sh
#============================================================================
set -u

SIM_BIN="${VSIM_BIN:-H:/modeltech64_10.4/win64}"
VLOG="$SIM_BIN/vlog.exe"

if [ ! -x "$VLOG" ]; then
    echo "找不到 vlog：$VLOG" >&2
    exit 2
fi

cd "$(dirname "$0")" || exit 2            # 到 sim/
ROOT=".."

# 注意 vlog 的 -work 接的是**逻辑库名**（经 modelsim.ini 映射），不是路径。
# 传 "-work sim/work" 既不建库、又可能往 modelsim.ini 里写映射 —— 别那么用。
# 正确做法是在 sim/ 下 vlib work，然后让 vlog 用默认的 work。
rm -rf work
vlib work > /dev/null

# 从 ivlab239.xml 取 design_file 列表（路径是仓库根相对，这里补上 ../）
mapfile -t FILES < <(grep -o 'design_file name="[^"]*"' "$ROOT/ivlab239.xml" \
                     | sed 's/design_file name="//; s/"$//' \
                     | sed "s|^|$ROOT/|")

if [ "${#FILES[@]}" -eq 0 ]; then
    echo "FAIL: ivlab239.xml 里没解析到 design_file" >&2
    exit 2
fi

# include 目录：**只取真正含 .svh/.vh 的目录**。
# 不要用 "find src ip -type d" —— ip/riscv/ 下是整棵厂商目录树，会产出 400+
# 个 +incdir+，命令行直接爆掉（表现为 vlog 退出码 126）。
INCDIRS=()
while IFS= read -r d; do INCDIRS+=("+incdir+$ROOT/$d"); done < <(
    find "$ROOT/src" "$ROOT/ip" -type f -name '*.svh' -o -type f -name '*.vh' |
        xargs -n1 dirname | sed "s|^$ROOT/||" | sort -u
)

# ip/ 下有两个 top.v 例化、但本脚本**故意不编译**的文件，原因各不相同：
#   ip/dual_hyperram_ctrl/dual_hyperram_ctrl.sv —— Efinity 加密的 IP
#       （vlog 报 "syntax error in protected region"，需要厂商解密支持）
#   ip/riscv/riscv.v —— 生成文件，且依赖 EFX_RAM10 等厂商原语
# 因此本脚本只做**编译**、不做展开（elaboration）：
#   展开需要 Efinity 的仿真原语库，那套库不在本检出内。
# 结论：这两个模块在本流程里当黑盒，编译检查覆盖其余全部源文件。
# 端口名对账：vlog 在编译期**不会**报"例化了一个不存在的端口名"（那要到展开期），
# 而本工程因 ip/ 下是加密 IP 无法展开 —— 所以这道检查必须单独做。
# 实测它抓到过 D2 删端口时留下的 raw_mode/mask_left/mask_top 三个连接。
if ! python ./check_ports.py src/top.v | tail -1 | grep -q '^PASS'; then
    python ./check_ports.py src/top.v
    echo "FAIL: 端口名对账未通过" >&2
    exit 1
fi

out="$("$VLOG" -quiet -sv "${INCDIRS[@]}" "${FILES[@]}" 2>&1)"
rc=$?
echo "$out" | grep -E '\*\* Error' | head -20

if echo "$out" | grep -q '\*\* Error'; then
    echo "FAIL: 全设计编译出现 error（文件数 ${#FILES[@]}）" >&2
    exit 1
fi
if [ "$rc" -ne 0 ]; then
    echo "FAIL: vlog 退出码 $rc" >&2
    exit 1
fi

# 库要真有内容才算编译过：只看 "没有 ** Error" 是不够的
# （文件列表为空时也不会有 error）。ModelSim 按库分片，库内文件数是个位数，
# 所以判据取"存在 _lib1_0.qdb"而不是数文件个数。
if [ ! -f work/_lib1_0.qdb ]; then
    echo "FAIL: 未生成设计单元（work/_lib1_0.qdb 不存在）" >&2
    exit 1
fi

# 4.1 要求"无未连接或位宽不匹配告警"：把这两类单独报出来
warn_conn=$(echo "$out" | grep -cE 'vlog-2275|vlog-2241|vlog-2682' || true)
echo "连接类告警（未连接/位宽不匹配/端口不存在）：$warn_conn"
echo "$out" | grep -E 'vlog-2275|vlog-2241|vlog-2682' | head -10
if [ "$warn_conn" -ne 0 ]; then
    echo "FAIL: 存在连接类告警" >&2
    exit 1
fi
echo "PASS: 全设计编译通过（${#FILES[@]} 个 design_file，ip/ 的两个加密/生成文件按黑盒跳过；无连接类告警）"
