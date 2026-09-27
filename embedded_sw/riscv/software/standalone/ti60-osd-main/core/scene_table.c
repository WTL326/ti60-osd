/* =============================================================================
 * 场景表内容 —— 文案取自《OSD_UI设计规格_v20260911》P1 / P2 / P3
 * 俄语译文为占位级常用译法，待产品侧校订（不影响任何接口）
 * =============================================================================
 */
#include "scene_table.h"

static const scene_page_t s_pages[] = {
    /* ---- P1 主菜单（ROOT） ---- */
    {
        0x0000u,
        { "MAIN MENU", "ГЛАВНОЕ МЕНЮ" },
        9u,
        {
            { "Image Setting",   "Настройки изображения" },
            { "Image Mode",      "Режим изображения"     },
            { "Zoom",            "Зум"                   },
            { "Function",        "Функция"               },
            { "Setting",         "Настройки"             },
            { "Measure",         "Измерение"             },
            { "Zeroing",         "Пристрелка"            },
            { "Ballistic",       "Баллистика"            },
            { "Display Setting", "Настройки экрана"      },
        },
        { -1, -1, -1, -1, -1, -1, -1, -1, -1 }
    },

    /* ---- P2 数值子菜单 IMAGE SETTING ---- */
    {
        0x0100u,
        { "IMAGE SETTING", "НАСТРОЙКА ИЗОБРАЖЕНИЯ" },
        6u,
        {
            { "Image Enhance",     "Улучшение"        },
            { "Contrast",          "Контраст"         },
            { "Image Brightness",  "Яркость"          },
            { "Screen Brightness", "Яркость экрана"   },
            { "PIP >",             "PIP >"            },
            { "Image Correction >","Коррекция >"      },
        },
        { 0, 1, 2, 3, -1, -1 }
    },

    /* ---- P3 单选列表 IMAGE MODE ---- */
    {
        0x0200u,
        { "IMAGE MODE", "РЕЖИМ ИЗОБРАЖЕНИЯ" },
        4u,
        {
            { "White Hot",  "Белый горячий" },
            { "Black Hot",  "Чёрный горячий"},
            { "Iron Red",   "Красный"       },
            { "Rainbow",    "Радуга"        },
        },
        { -1, -1, -1, -1 }
    },
};

unsigned scene_page_count(void) { return (unsigned)(sizeof(s_pages) / sizeof(s_pages[0])); }
const scene_page_t *scene_at(unsigned i) { return &s_pages[i]; }

const scene_page_t *scene_find(uint16_t page_id)
{
    unsigned i;
    for (i = 0u; i < scene_page_count(); i++) {
        if (s_pages[i].page_id == page_id) return &s_pages[i];
    }
    return 0;   /* 未知 page_id：由命令层判非法（统一口径），不做兜底渲染 */
}
