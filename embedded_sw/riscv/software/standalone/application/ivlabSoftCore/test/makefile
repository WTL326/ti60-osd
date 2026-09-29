# 0xBB 协议的离机测试（在 qemu 上跑）
#
# 关于测试方式：原计划是"用主机上的 gcc 编译"，但本机没有装任何 x86 平台的 C
# 编译器（gcc / cc / clang / cl 都没有）。机器上有的是 Efinity 自带的 RISC-V
# 工具链和它自带的 qemu-system-riscv32，于是改成"编译成 rv32im 目标、在 qemu
# 上执行"。
#
# 这样其实比主机编译更有价值：
#   1) 跑的是目标同款指令集（rv32im），连整数溢出、字节序这些细节都一致；
#   2) 被测模块是直接从 ../src 原封不动拿过来编译链接的，没有为测试改过一行。
#
# 用法：
#   make -C test                                   # 编译并运行
#   make -C test CC=<前缀>gcc QEMU=<qemu 的路径>    # 换工具链或 qemu 位置

# RISC-V 工具链的可执行文件前缀。BSP 的公共 makefile 里默认也是这个值，
# 保持一致。用 ?= 是因为调用者可能想换成别的（比如系统里装的是 riscv64-unknown-elf-）。
RISCV_BIN ?= riscv-none-elf-

# 这里必须用 := 无条件赋值，不能写 ?=。
# 原因是 make 内置了一个默认变量 CC=cc，用 ?= 的话"变量已有值"、
# 赋值会被跳过，最后还是会去调用不存在的 cc。
# 而命令行上传入的 CC=... 优先级高于 makefile 里的赋值，所以依然可以覆盖。
CC := $(RISCV_BIN)gcc

# qemu 的路径写成绝对路径，有两个原因：
#   1) qemu 一般不在 PATH 里；
#   2) make 调用的是 Windows 下的 shell，它认不出 /h/... 这种 POSIX 风格路径
#      （会被错误地解析成 C:/h/...）。这里用 H:/ 开头的写法。
# Efinity 装在别处的话，用 QEMU=<路径> 覆盖即可。
QEMU ?= H:/Efinity/efinity-riscv-ide-2026.1/qemu/qemu-system-riscv32.exe

# 被测源码所在目录
SRC = ../src

# 编译选项说明：
#   -march / -mabi   目标指令集与 ABI（rv32im + 32 位整数 ABI），与真实软核一致
#   -msmall-data-limit=0
#                    关掉"小数据区"优化。默认情况下编译器会把小变量放在 gp
#                    寄存器附近、用 gp 相对寻址访问，而 gp 需要在启动时先设置。
#                    本测试的启动代码很简单、不设 gp，所以要关掉这个优化，
#                    否则一上电第一条访问全局变量的指令就会跑飞。
#   -nostdlib -nostartfiles
#                    不链接标准库、也不用编译器自带的启动代码——启动流程由
#                    harness.c 里的 _start 自己负责。
#   -Wall -Wextra    打开警告。测试代码自己先要干净。
#   -g3 -Og          带调试信息、轻度优化，方便出问题时看。
#   -I. -I$(SRC) -I$(SRC)/osd
#                    头文件搜索路径：当前目录（harness.h）、被测源码目录，
#                    以及 osd/ 子目录。**-I$(SRC)/osd 不能省**：canvas_mem.c
#                    是画布的主机后端、被放在本目录下，而它 include 的是
#                    "canvas.h"（靠"同目录"解析）—— 少了这一条它找不到
#                    ../src/osd/canvas.h，现象是 canvas_mem.c:13 报没有该文件。
CFLAGS = -march=rv32im_zicsr_zifencei -mabi=ilp32 -msmall-data-limit=0 \
         -nostdlib -nostartfiles -Wall -Wextra -g3 -Og -I. -I$(SRC) -I$(SRC)/osd

# -T qemu32.lds 用自定义链接脚本（说明见该文件）。
# --no-warn-rwx-segments 关掉"代码段同时可写可执行"的警告——裸机程序本来就
# 是这样，这个警告在这里没有意义。
LDFLAGS = -T qemu32.lds -Wl,--no-warn-rwx-segments

OBJDIR = build

# 目标文件清单：测试台 + 测试用例 + 被测模块。
# 被测模块（frame/crc16/protocol/app_log）是从 ../src 编进来的，
# 用的是它们自己的 .c 文件，没有为测试改过一行。
OBJS = $(OBJDIR)/harness.o $(OBJDIR)/test_main.o $(OBJDIR)/test_protocol.o \
       $(OBJDIR)/test_app_log.o \
       $(OBJDIR)/frame.o $(OBJDIR)/crc16.o $(OBJDIR)/protocol.o \
       $(OBJDIR)/app_log.o \
       $(OBJDIR)/ui.o $(OBJDIR)/font.o $(OBJDIR)/scene_table.o \
       $(OBJDIR)/composer.o $(OBJDIR)/font16_bin.o \
       $(OBJDIR)/osd_engine.o $(OBJDIR)/canvas_mem.o

.PHONY: all run clean

all: run

# | $(OBJDIR) 是"顺序前置条件"：它保证先建好目录，但目录的时间戳变化不会
# 触发重新编译。对"目录"这种目标，这是正确的写法。
$(OBJDIR):
	@mkdir -p $(OBJDIR)

# 两条模式规则，分别对应"本目录下的源文件"和"../src 下的源文件"。
# $@ 是目标文件名，$< 是第一个前置条件。
$(OBJDIR)/%.o: %.c | $(OBJDIR)
	$(CC) $(CFLAGS) -c -o $@ $<

$(OBJDIR)/%.o: $(SRC)/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) -c -o $@ $<

# osd/ 是本次变更新增的子目录（从 ti60-osd-main 移植的构图层）。
# 单独一条规则而不是把文件摊到 src/ 下：那批文件有共同的来源与风格，
# 放在一起将来才好整体对照上游。
$(OBJDIR)/%.o: $(SRC)/osd/%.c | $(OBJDIR)
	$(CC) $(CFLAGS) -c -o $@ $<

# app_log.c 需要特殊处理：它 `#include "bsp.h"`，而真正的 bsp.h 会一路拖进
# semihosting、打印库、SoC 寄存器定义等一大串只在上板时才有意义的东西。
# 测试用 stub/bsp.h 这个替身把 bsp_printf 换成"写进内存缓冲"，从而能断言
# 到底发出了哪些字节。
#
# 把 -Istub 放在最前面，是为了让替身**优先**被找到。"x.h" 形式的 include
# 先找源文件自己所在目录（../src，里面没有 bsp.h），再按 -I 顺序找，
# 所以 stub 排在前面就命中替身。这条规则单独写，是因为其它模块（frame、
# crc16、protocol）都不 include bsp.h，不该被牵连。
$(OBJDIR)/app_log.o: $(SRC)/app_log.c | $(OBJDIR)
	$(CC) -Istub $(CFLAGS) -c -o $@ $<

$(OBJDIR)/test.elf: $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(OBJS)

# 运行测试。命令行说明：
#   -machine virt       用 virt 机型（RAM 在 0x80000000）
#   -bios none          不加载固件，直接把我们的程序当裸机程序跑
#   -kernel <elf>       指定要加载的程序
#   -display none       不要图形窗口
#   -serial stdio       串口接到标准输出，测试的打印才会显示在终端上
#
# 测试程序结束时会让 qemu 带着"失败条数"退出，所以这里的退出码直接反映结果：
# 0 表示全部通过。每行前面的 @ 表示不回显命令本身，让输出干净些。
run: $(OBJDIR)/test.elf
	@$(QEMU) -machine virt -bios none -kernel $(OBJDIR)/test.elf \
	         -display none -serial stdio
	@echo "exit status: $$?"

clean:
	@rm -rf $(OBJDIR)
