#!/usr/bin/env bash
# =============================================================================
# check_compile.sh —— 编译叠加模块并判定成败（任务 1.1 的验收脚本）
#
# 为什么不能只看 vlog 的退出码：ModelSim 在 Windows 上遇到 error 时退出码
# 仍可能是 0，只有 stdout 里会出现 "** Error:"。所以本脚本以"输出中是否有
# ** Error"作为判据，退出码只作辅助。
#
# 用法：
#     bash sim/check_compile.sh                 # 用默认的 ModelSim
#     VSIM_BIN=.../questasim64_10.6c/win64 bash sim/check_compile.sh
# =============================================================================
set -u

SIM_BIN="${VSIM_BIN:-H:/modeltech64_10.4/win64}"
VLOG="$SIM_BIN/vlog.exe"

if [ ! -x "$VLOG" ]; then
    echo "找不到 vlog：$VLOG" >&2
    echo "用 VSIM_BIN=<仿真器 bin 目录> 指定，例如 H:/questasim64_10.6c/win64" >&2
    exit 2
fi

# 切到本脚本所在目录，这样 ../src/... 的相对路径才成立。
cd "$(dirname "$0")" || exit 2

rm -rf work
out="$("$VLOG" -quiet -sv ../src/overlay/HyperRamMaskOverlayYuv422.v 2>&1)"
rc=$?
echo "$out"

if echo "$out" | grep -q '\*\* Error'; then
    echo "FAIL: 编译出现 error" >&2
    exit 1
fi
if [ "$rc" -ne 0 ]; then
    echo "FAIL: vlog 退出码 $rc" >&2
    exit 1
fi
if [ ! -f work/_lib1_0.qdb ]; then
    echo "FAIL: 未生成任何设计单元（work 库为空）" >&2
    exit 1
fi

echo "PASS: 编译无 error，work 库已生成 1 个设计单元"
