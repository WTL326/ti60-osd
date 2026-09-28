# ivlabSoftCore —— IVLAB 239 视频管线的软核应用
#
# 这个 makefile 的结构与工程里既有的应用（uartInterruptDemo、memTest）保持一致，
# 三段 include 分别是：BSP 相关配置、工具链配置、通用构建规则。它们的说明见下。
#
# 构建命令（BSP 变量必须从命令行传入，因为没有任何 makefile 给它赋过值）：
#   make BSP=efinix/EfxSapphireSoc
#
# 注意 BSP 的值必须带 efinix/ 这一层。原因：common/bsp.mk 里 BSP_PATH 的默认
# 写法是 ${STANDALONE}/../../bsp/${BSP}，其中并不包含 efinix 这一层，而 BSP
# 在本仓库里的实际位置是 bsp/efinix/EfxSapphireSoc。只传 EfxSapphireSoc 会
# 找不到 bsp.mk 要 include 的 soc.mk。

PROJ_NAME=ivlabSoftCore

# 相对本目录回到 standalone 目录（本文件位于 application/ivlabSoftCore/ 下）。
# 后面的 include 与源码路径都基于这个变量。
STANDALONE=../..

# 打开 SMP 宏。这是沿用工程里其它应用的写法。本 SoC 目前是单核（soc.h 中只有
# SYSTEM_CORES_0），所以这个宏实际不起作用；保留它是为了与新建工程的习惯一致。
CFLAGS+=-DSMP

# src/osd/osd_engine.h 同时依赖协议层（frame.h / protocol.h，在 src/ 下）
# 与 OSD 层（ui.h / canvas.h 等，在 src/osd/ 下）。编译器找 "x.h" 时只会看
# "包含它的那个文件所在目录" 与 -I 列表，所以要把 src/ 也加进来 ——
# 少了这一行，报错是 src/osd/osd_engine.h 找不到 frame.h。
CFLAGS+=-Isrc

# 参与编译的源文件：
#   src/ 下的全部 .c / .cpp / .S —— 本项目自己的代码
#   common/start.S              —— 启动代码（设置栈、拷贝数据段、调用 main）
#   common/trap.S               —— 异常/中断入口，会调用 main.c 里的 trap()
# 这里用 wildcard 而不是逐个列文件名：往 src/ 里加一个新 .c 文件不必改 makefile。
# src/osd/ 是 OSD 构图层（从 ti60-osd-main 移植），单独列一行 —— wildcard 不递归，
# 少了这一行那批文件不会被编进来，症状是一堆 undefined reference。
# 代价是编译顺序不确定，所以文件之间不能依赖"谁先初始化"——本项目的初始化
# 顺序由 main() 显式控制，不依赖编译顺序。
SRCS = 	$(wildcard src/*.c) \
		$(wildcard src/osd/*.c) \
		$(wildcard src/*.cpp) \
		$(wildcard src/*.S) \
        ${STANDALONE}/common/start.S \
        ${STANDALONE}/common/trap.S

# 三段公共配置，顺序不能换：
#   bsp.mk                 展开 BSP 的路径、加入 BSP 头文件搜索路径，
#                          并 include BSP 自带的 soc.mk（里面定义了一些 -D）
#   riscv64-unknown-elf.mk 定义编译器/objcopy/objdump 的名字和 -march/-mabi
#   standalone.mk          定义编译规则、链接选项、以及最终的 .elf/.hex/.bin 产物
include ${STANDALONE}/common/bsp.mk
include ${STANDALONE}/common/riscv64-unknown-elf.mk
include ${STANDALONE}/common/standalone.mk

# 链接脚本沿用 BSP 的默认脚本（ram 从 0x00001000 开始，长度 124 KB）。
# 这里显式再写一次是因为 standalone.mk 里用的是 ?=，允许工程覆盖。
LDSCRIPT = ${BSP_PATH}/linker/default.ld
