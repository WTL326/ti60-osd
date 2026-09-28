#!/usr/bin/env bash
# =============================================================================
# run_cdc_tb.sh —— 编译并运行配置快照通路的自检测试平台（任务 4.2 / 7.9）
#
# 用法：
#     bash sim/run_cdc_tb.sh              # 默认几何（180x144 + 四路 64x48）
#     bash sim/run_cdc_tb.sh big          # 360x288 + 四路 128x96
#
# 与 run_tb.sh 分开而不是加一个模式，有两个理由：
#   1) 编译文件清单不同 —— 本平台多编 ConfigSnapshotCdc.v；
#   2) 它回答的是另一个问题（配置怎么到达），失败时的排查路径完全不同。
#      混在一个脚本里，看输出的人要先分辨"这次失败属于哪一类"。
#
# 退出码：0 = PASS，1 = FAIL，2 = 环境/编译问题。
# =============================================================================
set -u

SIM_BIN="${VSIM_BIN:-H:/modeltech64_10.4/win64}"
VLOG="$SIM_BIN/vlog.exe"
VSIM="$SIM_BIN/vsim.exe"

if [ ! -x "$VLOG" ] || [ ! -x "$VSIM" ]; then
    echo "找不到仿真器：$SIM_BIN" >&2
    echo "用 VSIM_BIN=<bin 目录> 指定，例如 H:/questasim64_10.6c/win64" >&2
    exit 2
fi

cd "$(dirname "$0")" || exit 2

MODE="${1:-fast}"
shift || true

if [ "$MODE" = "big" ]; then
    DEFINES=""
else
    DEFINES="+define+FAST_FRAME"
fi
DEFINES="$DEFINES ${EXTRA_DEFINES:-}"

rm -rf work_cdc
vlib work_cdc > /dev/null 2>&1
out="$("$VLOG" -quiet -sv -work work_cdc $DEFINES \
       ../src/common/ConfigSnapshotCdc.v \
       ../src/overlay/HyperRamMaskOverlayYuv422.v \
       tb_mask_cfg_cdc.v 2>&1)"
if echo "$out" | grep -q '\*\* Error'; then
    echo "$out"
    echo "FAIL: 编译出错" >&2
    exit 2
fi

LOG="$(mktemp)"
timeout 900 "$VSIM" -c -quiet -do "run -all; quit -f" \
        work_cdc.tb_mask_cfg_cdc "$@" > "$LOG" 2>&1
rc=$?

grep -E '^#   (PASS|FAIL)' "$LOG" | sed 's/^#   //'
awk '/^# -+$/{p=1} p' "$LOG" | sed 's/^# \{0,1\}//'
grep -E '^# MISMATCH' "$LOG" | head -10 | sed 's/^# //'

if [ "$rc" -eq 124 ]; then
    echo "FAIL: 仿真超时" >&2
    rm -f "$LOG"
    exit 1
fi
if grep -q '^# PASS' "$LOG"; then
    rm -f "$LOG"
    exit 0
fi
echo "（完整 transcript: $LOG）" >&2
exit 1
