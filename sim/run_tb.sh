#!/usr/bin/env bash
# =============================================================================
# run_tb.sh —— 编译并运行叠加模块的自检测试平台
#
# 用法：
#     bash sim/run_tb.sh                    # 快速冒烟（180x144 + 四路 64x48）
#     bash sim/run_tb.sh full               # 全画幅（720x576 + 四路 256x128，慢）
#     bash sim/run_tb.sh menu               # 菜单承载路实参 544x208
#     bash sim/run_tb.sh max                # 单路最大尺寸 544x288
#     bash sim/run_tb.sh full +BASELINE=sim/baseline_before.txt
#
# 退出码：0 = PASS，1 = FAIL，2 = 环境/编译问题。
# 之所以自己判 PASS/FAIL 而不看 vsim 的退出码：ModelSim 在运行期报错时
# 退出码也常常是 0，只有 transcript 里的结论才可信。
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

# 几何由**编译期宏**选择：位图尺寸决定了测试平台内部内存模型的槽位布局，
# 改不了运行时。四种几何覆盖任务 7.2-7.6 需要的全部尺寸组合。
case "$MODE" in
    full) DEFINES="+define+TB_FULLWIN" ;;   # 720x576 + 四路 256x128（2x2 并排）
    menu) DEFINES="+define+TB_MENU"    ;;   # 720x576 + 四路 544x208（菜单承载路实参）
    max)  DEFINES="+define+TB_MAXWIN"  ;;   # 720x576 + 四路 544x288（D6 上限）
    *)    DEFINES="+define+FAST_FRAME" ;;   # 180x144 + 四路 64x48（冒烟）
esac
# EXTRA_DEFINES 用于一次性诊断（例如 +define+TB_LSB_FIRST 反向验证位序探针）
DEFINES="$DEFINES ${EXTRA_DEFINES:-}"

rm -rf work
out="$("$VLOG" -quiet -sv $DEFINES ../src/overlay/HyperRamMaskOverlayYuv422.v \
       tb_hyperram_mask_overlay.v 2>&1)"
if echo "$out" | grep -q '\*\* Error'; then
    echo "$out"
    echo "FAIL: 编译出错" >&2
    exit 2
fi

# 超时给足：全尺寸一次跑几百万周期。用 timeout 防止死锁挂住终端。
LOG="$(mktemp)"
timeout 1800 "$VSIM" -c -quiet -do "run -all; quit -f" \
        work.tb_hyperram_mask_overlay "$@" > "$LOG" 2>&1
rc=$?

# 回显仿真结论：取分隔线之后的内容（ModelSim 自己的抬头与中文行编码混杂，
# 用"分隔线之后"这种位置判据比匹配中文更稳）。
# 先回显**逐用例**的结论，再回显末尾的汇总。用例行是主要输出 ——
# 只说"整体 FAIL"而不说哪个用例红，等于把定位工作全留给看日志的人。
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
