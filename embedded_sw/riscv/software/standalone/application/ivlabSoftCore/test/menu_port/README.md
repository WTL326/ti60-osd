# 附录A 全菜单 —— 主机端渲染验证

`verify_menu.c` 把 `src/osd` 的菜单渲染代码在**主机**上编成一个小程序，把
37 页菜单 × EN/RU 全部渲染成字符网格 dump，并统计缺字。

不需要硬件、不需要 qemu、不需要 RISC-V 工具链。

## 为什么单独搞一套

`test/` 下那套用例（`make -C test`）跑在 qemu 模拟的 rv32im 上，验的是
**协议与画布链路**。菜单画得对不对则是另一件事：它只取决于**字符网格**，
与字库像素、与目标指令集都无关。所以这一套能在主机上跑、几秒出结果，
改文案或加页面时随手可验，与 qemu 那套互补。

## 编译运行

任选一个 C99 编译器（`cc` / `gcc` / `clang` / `zig cc` 都行）：

```sh
cd test/menu_port
cc -std=c99 -I../src/osd -o verify_menu \
   verify_menu.c ../src/osd/ui.c ../src/osd/scene_table.c \
   ../src/osd/font.c ../src/osd/font8x16_bin.c

mkdir -p out && ./verify_menu out
```

### Windows 上没有 cc 时

用 `zig cc` —— 它是单个可执行文件，不需要装 MinGW/VS：

```bat
zig cc -std=c99 -o verify_menu.exe ^
   verify_menu.c ..\..\src\osd\ui.c ..\..\src\osd\scene_table.c ^
   ..\..\src\osd\font.c ..\..\src\osd\font8x16_bin.c
mkdir out & verify_menu.exe out
```

## 输出与退出码

- 每页两个文件：`out/dump_EN_XXXX.txt`、`out/dump_RU_XXXX.txt`（`XXXX` = page_id）
- 标准输出：`pages=37 font_miss=0`
- 退出码：`0` = 全部渲染且**零缺字**；`2` = 写文件失败；`3` = 有缺字

`font_miss != 0` 说明场景表里出现了 8x16 字库没有的字符（会被就地替换成 `?`）。
此时应先用工具核对码点，再决定是改文案还是重取字模 —— 字模由
`src/osd/../../../../../../tools/gen_font.py` 离线生成，**不要手改**
`font8x16_bin.c`。

## 与样例文档对照

`out/dump_*.txt` 可与《技术协议-2》附录A 的显示样例
（`TI60_OSD_附录A全菜单显示样例_v0.1.html`）**逐格比对**：一个是 C 代码跑出来的
真实网格，一个是样例文档的排版，两者应完全一致。

## 注意

**不要**把 `../src/osd/canvas_hw.c` 编进来：它直接打硬件寄存器，主机上跑不了；
而网格渲染根本用不到画布那一层。
