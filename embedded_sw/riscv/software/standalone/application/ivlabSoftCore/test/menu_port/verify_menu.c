/* =============================================================================
 * 附录A 全菜单 —— 主机端渲染验证（不进固件构建，也不在 qemu 上跑）
 *
 * 干什么：把 src/osd 下的 ui.c / scene_table.c / font.c / font8x16_bin.c 用
 *         **主机上的任意 C99 编译器**编成一个小程序，把 37 页菜单 × EN/RU 全部
 *         渲染成字符网格，写成 dump_EN_XXXX.txt / dump_RU_XXXX.txt，并统计缺字。
 *
 * 为什么要有它：菜单画得对不对，与字库像素、与跑在什么板子上**无关** —— 它只
 *         取决于字符网格。所以不需要硬件、不需要 qemu、不需要 RISC-V 工具链，
 *         在主机上就能证明"文案、值类型渲染、窗口平移、截断规则"全对。
 *         test/ 下那套 qemu 用例（make -C test）验的是协议与画布链路，与本文件
 *         互补：那套跑目标指令集，这套跑得更快、改文案时随手可验。
 *
 * 编译运行（任选一种编译器，产物写到 out 目录）：
 *     cc -std=c99 -I../src/osd -o verify_menu \
 *        verify_menu.c ../src/osd/ui.c ../src/osd/scene_table.c \
 *        ../src/osd/font.c ../src/osd/font8x16_bin.c
 *     ./verify_menu out
 *
 * 退出码：0 = 37 页全部渲染且零缺字；2 = 写文件失败；3 = 有缺字。
 *
 * 注意 **不要**把 ../src/osd/canvas_hw.c 编进来：它直接打硬件寄存器，主机上跑
 * 不了；而网格渲染根本用不到画布那一层。
 * =============================================================================
 */
#include <stdio.h>
/* 本文件在 test/menu_port/ 下，所以回两级才是应用根目录：../../ = ivlabSoftCore/。
 * 用相对路径而不是靠 -I，是为了"随便哪个编译器、不加任何参数也能编过"。 */
#include "../../src/osd/ui.h"
#include "../../src/osd/scene_table.h"

int main(int argc, char **argv)
{
    const char *outdir = (argc > 1) ? argv[1] : ".";
    unsigned i;
    unsigned miss = 0u;
    char buf[4096];
    char path[512];

    ui_init();

    for (i = 0u; i < scene_page_count(); i++) {
        uint16_t pid = scene_at(i)->page_id;
        int lang;

        for (lang = 0; lang < 2; lang++) {
            FILE *f;

            g_font_miss_count = 0u;
            /* sel=0：样例呈现的是"刚进这一页"的样子；flags 只切语言位。 */
            ui_set_view(pid, 0u, (uint8_t)(lang ? UI_FLAG_LANG_RU : 0u));
            scene_build();
            miss += g_font_miss_count;

            osd_grid_dump(buf, (unsigned)sizeof(buf));
            sprintf(path, "%s/dump_%s_%04X.txt", outdir,
                    (lang ? "RU" : "EN"), pid);

            f = fopen(path, "wb");
            if (f == 0) { fprintf(stderr, "cannot write %s\n", path); return 2; }
            fputs(buf, f);
            fclose(f);
        }
    }

    printf("pages=%u font_miss=%u\n", scene_page_count(), miss);
    return (miss == 0u) ? 0 : 3;
}
