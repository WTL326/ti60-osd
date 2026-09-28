#!/usr/bin/env bash
# =============================================================================
# check_param_guards.sh —— 展开期参数检查的反向验证（任务 7.7）
#
# 为什么需要它：`HyperRamMaskOverlayYuv422.v` 的 12 个 generate 检查（宽度对齐、
# 宽度/高度上下限）在**合法参数**下永远不触发。只跑正常仿真的话，"检查存在与否"
# 完全看不出来 —— 把它整段删掉，所有测试照样 PASS。所以要专门喂非法参数，
# 要求它必须报错、而且报出的是**哪一路的哪个参数**。
#
# 每个用例都是一次完整的 vlog + vsim：
#   vlog 只做编译、不做展开，所以非法参数能通过编译（这一点在 design.md D6 里
#   写明了：检查在 vsim 展开期与综合期报错，不在 vlog 期）；
#   vsim 展开时才实例化那个"名字就是诊断信息"的不存在模块，于是报错。
#
# 每个非法用例都配一个**合法对照**（把同一路改回合法值）：没有对照的话，
# "反正都失败"看起来也像成功 —— 一个从不通过的检查等于没有检查。
#
# 用法：bash sim/check_param_guards.sh
# 退出码：0 = 全部符合预期，1 = 有不符合，2 = 环境问题。
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
RTL="../src/overlay/HyperRamMaskOverlayYuv422.v"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# 生成一个小包装：只覆盖一个参数，其余端口不接（命名例化允许省略端口）。
# 端口不接会产生 vlog 的"未连接"告警，但**不是** error，不影响本脚本的判据。
mk_wrapper() {
    local name="$1" param="$2" value="$3"
    cat > "$TMP/$name.v" <<EOF
// 由 check_param_guards.sh 生成，不要手改
module $name;
    HyperRamMaskOverlayYuv422 #(
        .$param ($value)
    ) u_dut ();
endmodule
EOF
}

# 跑一个用例。
#   $1 用例名（也是模块名）  $2 参数名  $3 取值
#   $4 expect: fail | pass   $5 期望在输出里出现的字样（expect=fail 时）
run_case() {
    local name="$1" param="$2" value="$3" expect="$4" want="${5:-}"
    local log="$TMP/$name.log"
    local ok=1

    mk_wrapper "$name" "$param" "$value"

    ( cd "$TMP" && rm -rf work && "$VLOG" -quiet -sv "$OLDPWD/$RTL" "$name.v" ) > "$log" 2>&1
    # 展开：vsim 带 -c 时若展开失败会直接报错退出，不需要 run
    ( cd "$TMP" && "$VSIM" -c -quiet -do "quit -f" "work.$name" ) >> "$log" 2>&1

    if grep -q '\*\* Error' "$log"; then
        if [ "$expect" = "pass" ]; then
            echo "FAIL  $name：期望通过，却报了错"
            grep -m3 '\*\* Error' "$log" | sed 's/^/        /'
            return 1
        fi
        if [ -n "$want" ] && ! grep -q "$want" "$log"; then
            echo "FAIL  $name：报了错，但错误信息里没有 '$want'"
            echo "      （诊断信息必须指出是哪一路的哪个参数）"
            grep -m3 '\*\* Error' "$log" | sed 's/^/        /'
            return 1
        fi
        echo "PASS  $name：$param=$value 被拒（$want）"
    else
        if [ "$expect" = "fail" ]; then
            echo "FAIL  $name：$param=$value **没有**被拒 —— 这条参数检查没生效"
            return 1
        fi
        echo "PASS  $name：$param=$value 合法，正常展开"
    fi
    return 0
}

echo "=== 展开期参数检查的反向验证（任务 7.7）==="
bad=0

# 三种非法配置，分别放在三路：既验检查生效，也验诊断信息能指明是哪一路。
run_case w_not_aligned   OSD0_WIDTH  540 fail OSD0_WIDTH_must_be_a_multiple_of_8 || bad=1
run_case w_over_max      OSD2_WIDTH  545 fail OSD2_WIDTH_must_be_within_8_to_544  || bad=1
run_case h_over_max      OSD3_HEIGHT 289 fail OSD3_HEIGHT_must_be_within_1_to_288 || bad=1

# 合法对照：同样这三路，取边界内的值（含上限本身）——必须全部正常展开。
run_case ok_aligned_max  OSD0_WIDTH  544 pass || bad=1
run_case ok_w_bound      OSD2_WIDTH  8   pass || bad=1
run_case ok_h_bound      OSD3_HEIGHT 288 pass || bad=1

echo "--------------------------------------------------"
if [ "$bad" -eq 0 ]; then
    echo "PASS: 3 个非法配置全部被拒、且诊断信息指名到路与参数；3 个合法对照全部通过"
else
    echo "FAIL: 有 $bad 个用例不符合预期"
fi
exit "$bad"
