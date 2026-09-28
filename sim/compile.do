# =============================================================================
# compile.do —— 编译叠加模块
#
# 用法（在 sim/ 目录下）：
#     vsim -c -do compile.do            # 命令行
#     或在本目录启动 ModelSim/Questa 后： do compile.do
#
# 为什么单独建一个"只编译、不仿真"的脚本：任务的验收标准是"该文件能被 vlog
# 无错误编译"，这是一个比"能跑通仿真"廉价得多的冒烟检查。每次改完 RTL 先跑它，
# 可以把语法/位宽类错误挡在仿真之前，不必等 testbench 编译完才发现。
#
# 注意 vlog 的退出码不可靠（在 Windows 上即使有 error 也可能返回 0），
# 所以下面显式统计 error 的条数并以它决定成败 —— 见 sim/check_compile.sh。
# =============================================================================

# WORK 库：每次重建，避免上一次编译的残留单元掩盖本次的错误。
if {[file exists work]} {
    vdel -all -lib work
}
vlib work
vmap work work

# 只编译叠加模块本身。它不例化其它本工程模块，因此可以独立编译。
vlog -quiet -sv ../src/overlay/HyperRamMaskOverlayYuv422.v
