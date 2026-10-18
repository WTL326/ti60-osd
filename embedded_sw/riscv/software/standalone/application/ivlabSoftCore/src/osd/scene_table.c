/* =============================================================================
 * 场景表内容 —— 《技术协议-2》附录A 全菜单树（37 页）
 *
 * 文案与结构逐条对应样例文档 TI60_OSD_附录A全菜单显示样例_v0.1.html（已评审
 * 2026-10-18）。俄语译文为常用译法，待产品侧校订（不影响任何接口）。
 *
 * 本文件与 PC 仿真侧（osd/core/scene_table.c）的页面数据**逐字一致**：两端
 * 共用同一份菜单树，渲染结果才能逐格比对。改文案请两边同步。
 * =============================================================================
 */
#include "scene_table.h"

/* ------------------------------------------------------------ 枚举值表 */
/* ONOFF 渲染为固定 On/Off（样例文档 §1），不占用枚举表 */
/* 每张表必须以 0 结尾：scene_enum_count() 靠 NULL 哨兵数出长度（无长度字段），
 * 缺哨兵会越界读并给出错误长度，ENUM 越界校验随之失效。 */
static const char *const v_zoom[]       = { "x1", "x2", "x4", "x8", 0 };
static const char *const v_pos[]        = { "A", "B", "C", "D", "E", 0 };
static const char *const v_unit_myd[]   = { "M", "Yd", 0 };
static const char *const v_angle[]      = { "MIL", "MOA", 0 };

static const char *const v_fonts_en[]   = { "Font1", "Font2", "Font3", 0 };
static const char *const v_fonts_ru[]   = { "шрифт1", "шрифт2", "шрифт3", 0 };

static const char *const v_fsize_en[]   = { "Extra Small", "Small", "Medium",
                                            "Large", "Extra Large", "XX-Large", 0 };
static const char *const v_fsize_ru[]   = { "Очень маленький", "Маленький", "Средний",
                                            "Большой", "Очень большой", "Сверхбольшой", 0 };

static const char *const v_scfn_en[]    = { "Image Enhance", "Palette", "Zoom", "PIP",
                                            "Take Picture", "Take Video", "TMO", "None", 0 };
static const char *const v_scfn_ru[]    = { "Улучшение", "Палитра", "Зум", "PIP",
                                            "Сделать фото", "Снять видео", "TMO", "Нет", 0 };

#define I(en, ru, kind, def, child, ven, vru, edef) \
    { en, ru, (kind), (def), (child), (ven), (vru), (edef) }

/* ------------------------------------------------------------ 页面表 */
static const scene_page_t s_pages[] = {

    /* ============ L1 根 ============ */
    { 0x0000u, "MAIN MENU", "ГЛАВНОЕ МЕНЮ", 9u, {
        I("Image Setting",   "Настройки изображения", OSD_VAL_NONE, 0, 0x0100u, 0, 0, 0),
        I("Image Mode",      "Палитра",               OSD_VAL_NONE, 0, 0x0200u, 0, 0, 0),
        I("Zoom",            "Зум",                   OSD_VAL_NONE, 0, 0x0300u, 0, 0, 0),
        I("Function",        "Функции",               OSD_VAL_NONE, 0, 0x0400u, 0, 0, 0),
        I("Setting",         "Настройки",             OSD_VAL_NONE, 0, 0x0500u, 0, 0, 0),
        I("Measure",         "Измерение",             OSD_VAL_NONE, 0, 0x0600u, 0, 0, 0),
        I("Zeroing",         "Пристрелка",            OSD_VAL_NONE, 0, 0x0700u, 0, 0, 0),
        I("Ballistic",       "Баллистика",            OSD_VAL_NONE, 0, 0x0800u, 0, 0, 0),
        I("Display Setting", "Настройки дисплея",     OSD_VAL_NONE, 0, 0x0900u, 0, 0, 0),
    }},

    /* ============ 1 图像设置 ============ */
    { 0x0100u, "IMAGE SETTING", "НАСТРОЙКА ИЗОБРАЖЕНИЯ", 6u, {
        I("Image Enhance",      "Улучшение изображения",    OSD_VAL_NUM, 3, 0, 0, 0, 0),
        I("Contrast",           "Контраст",                 OSD_VAL_NUM, 5, 0, 0, 0, 0),
        I("Image Brightness",   "Яркость изображения",      OSD_VAL_NUM, 7, 0, 0, 0, 0),
        I("Screen Brightness",  "Яркость экрана",           OSD_VAL_NUM, 5, 0, 0, 0, 0),
        I("PIP >",              "PIP >",                    OSD_VAL_NONE, 0, 0x0101u, 0, 0, 0),
        I("Image Correction >", "Коррекция изображения >",  OSD_VAL_NONE, 0, 0x0102u, 0, 0, 0),
    }},

    { 0x0101u, "PIP", "PIP", 2u, {
        I("PIP",         "PIP",                   OSD_VAL_ONOFF, 0, 0, 0, 0, 0),
        I("Display Pos", "Положение отображения", OSD_VAL_ENUM,  0, 0, v_pos, v_pos, 0),
    }},

    { 0x0102u, "IMAGE CORRECTION", "КОРРЕКЦИЯ ИЗОБРАЖЕНИЯ", 3u, {
        I("Auto Correction",   "Автокоррекция",       OSD_VAL_ONOFF, 0, 0, 0, 0, 0),
        I("Manual Correction", "Ручная коррекция",    OSD_VAL_ACTION, 0, 0, 0, 0, 0),
        I("Lens Correction",   "Коррекция объектива", OSD_VAL_NONE,  0, 0, 0, 0, 0),
    }},

    /* ============ 2 图像模式 ============ */
    { 0x0200u, "IMAGE MODE", "РЕЖИМ ИЗОБРАЖЕНИЯ", 7u, {
        I("White Hot", "Белый горячий",   OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Black Hot", "Чёрный горячий",  OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Red Hot",   "Красное горячее", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Iron Red",  "Железо-красный",  OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Rainbow",   "Радуга",          OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Green Hot", "Зелёное горячее", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Outline",   "Контур",          OSD_VAL_NONE, 0, 0, 0, 0, 0),
    }},

    /* ============ 3 放大 ============ */
    { 0x0300u, "ZOOM", "ЗУМ", 4u, {
        I("x1", "x1", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("x2", "x2", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("x4", "x4", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("x8", "x8", OSD_VAL_NONE, 0, 0, 0, 0, 0),
    }},

    /* ============ 4 功能 ============ */
    { 0x0400u, "FUNCTION", "ФУНКЦИИ", 7u, {
        I("Wi-Fi Setting",    "Настройка WiFi",          OSD_VAL_NONE,  0, 0x0401u, 0, 0, 0),
        I("Compass",          "Компас",                  OSD_VAL_ONOFF, 1, 0, 0, 0, 0),
        I("Pitch Angle",      "Угол наклона",            OSD_VAL_ONOFF, 1, 0, 0, 0, 0),
        I("Take Photo",       "Сделать фото",            OSD_VAL_ACTION, 0, 0, 0, 0, 0),
        I("Take Video",       "Снять видео",             OSD_VAL_ACTION, 0, 0, 0, 0, 0),
        I("Shooting Moment >", "Момент съёмки >",        OSD_VAL_NONE,  0, 0x0402u, 0, 0, 0),
        I("Lift To Wake",     "Поднять для пробуждения", OSD_VAL_ONOFF, 0, 0, 0, 0, 0),
    }},

    { 0x0401u, "WI-FI SETTING", "НАСТРОЙКА WIFI", 2u, {
        I("Wi-Fi",    "Wi-Fi",  OSD_VAL_ONOFF, 1, 0, 0, 0, 0),
        I("Password", "Пароль", OSD_VAL_EDIT,  0, 0, 0, 0, "12345678"),
    }},

    { 0x0402u, "SHOOTING MOMENT", "МОМЕНТ СЪЁМКИ", 2u, {
        I("Impact Detect", "Обнаружение удара", OSD_VAL_ONOFF, 1, 0, 0, 0, 0),
        I("Impact Force",  "Сила удара",        OSD_VAL_EDIT,  0, 0, 0, 0, "87654321"),
    }},

    /* ============ 5 设置 ============ */
    { 0x0500u, "SETTING", "НАСТРОЙКИ", 10u, {
        I("Language",         "Язык",                OSD_VAL_NONE,  0, 0x0501u, 0, 0, 0),
        I("Appearance",       "Внешний вид",         OSD_VAL_NONE,  0, 0x0502u, 0, 0, 0),
        I("Time & Date",      "Время и дата",        OSD_VAL_NONE,  0, 0x0503u, 0, 0, 0),
        I("Storage",          "Хранилище",           OSD_VAL_NONE,  0, 0x0504u, 0, 0, 0),
        I("Shortcuts",        "Назначение кнопок",   OSD_VAL_NONE,  0, 0x0505u, 0, 0, 0),
        I("Auto Shutdown",    "Авто-выключение",     OSD_VAL_NONE,  0, 0x0506u, 0, 0, 0),
        I("Factory Settings", "Заводские настройки", OSD_VAL_NONE,  0, 0x0507u, 0, 0, 0),
        I("Pixel Repair",     "Ремонт пикселей",     OSD_VAL_NONE,  0, 0x0508u, 0, 0, 0),
        I("System Unit",      "Единицы измерения",   OSD_VAL_ENUM,  0, 0, v_unit_myd, v_unit_myd, 0),
        I("About",            "О программе",         OSD_VAL_NONE,  0, 0, 0, 0, 0),
    }},

    { 0x0501u, "LANGUAGE", "ЯЗЫК", 3u, {
        I("Chinese", "Chinese", OSD_VAL_NONE, 0, 0, 0, 0, 0),   /* Q2 已决：本期占位 */
        I("Russian", "Русский", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("English", "English", OSD_VAL_NONE, 0, 0, 0, 0, 0),
    }},

    { 0x0502u, "APPEARANCE", "ВНЕШНИЙ ВИД", 2u, {
        I("Fonts",     "Шрифты",        OSD_VAL_ENUM, 0, 0x0510u, v_fonts_en, v_fonts_ru, 0),
        I("Font Size", "Размер шрифта", OSD_VAL_ENUM, 2, 0x0511u, v_fsize_en, v_fsize_ru, 0),
    }},

    { 0x0510u, "FONTS", "ШРИФТЫ", 3u, {
        I("Font1", "шрифт1", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Font2", "шрифт2", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Font3", "шрифт3", OSD_VAL_NONE, 0, 0, 0, 0, 0),
    }},

    { 0x0511u, "FONT SIZE", "РАЗМЕР ШРИФТА", 6u, {
        I("Extra Small", "Очень маленький", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Small",       "Маленький",       OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Medium",      "Средний",         OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Large",       "Большой",         OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Extra Large", "Очень большой",   OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("XX-Large",    "Сверхбольшой",    OSD_VAL_NONE, 0, 0, 0, 0, 0),
    }},

    { 0x0503u, "TIME & DATE", "ВРЕМЯ И ДАТА", 4u, {
        I("Time Display", "Отображение времени", OSD_VAL_ONOFF, 1, 0, 0, 0, 0),
        I("Time Setting", "Настройка времени",   OSD_VAL_EDIT,  0, 0, 0, 0, "12:34:56"),
        I("Date Display", "Отображение даты",    OSD_VAL_ONOFF, 1, 0, 0, 0, 0),
        I("Date Setting", "Настройка даты",      OSD_VAL_EDIT,  0, 0, 0, 0, "2026/10/18"),
    }},

    { 0x0504u, "FORMAT STORAGE", "ФОРМАТИРОВАНИЕ", 2u, {
        I("Yes", "Да",  OSD_VAL_ACTION, 0, 0, 0, 0, 0),
        I("No",  "Нет", OSD_VAL_ACTION, 0, 0, 0, 0, 0),
    }},

    { 0x0505u, "SHORTCUTS", "НАЗНАЧЕНИЕ КНОПОК", 7u, {
        I("Allow Shortcuts", "Разрешить назначения", OSD_VAL_ONOFF, 1, 0,       0, 0, 0),
        I("Up-Short",        "Вверх-коротко",        OSD_VAL_ENUM,  2, 0x0512u, v_scfn_en, v_scfn_ru, 0),
        I("Up-Long",         "Вверх-долго",          OSD_VAL_ENUM,  1, 0x0512u, v_scfn_en, v_scfn_ru, 0),
        I("Down-Short",      "Вниз-коротко",         OSD_VAL_ENUM,  3, 0x0512u, v_scfn_en, v_scfn_ru, 0),
        I("Down-Long",       "Вниз-долго",           OSD_VAL_ENUM,  7, 0x0512u, v_scfn_en, v_scfn_ru, 0),
        I("Right-Short",     "Вправо-кратко",        OSD_VAL_ENUM,  4, 0x0512u, v_scfn_en, v_scfn_ru, 0),
        I("Right-Long",      "Вправо-долго",         OSD_VAL_ENUM,  5, 0x0512u, v_scfn_en, v_scfn_ru, 0),
    }},

    { 0x0512u, "SHORTCUT FUNCTION", "ФУНКЦИЯ КНОПКИ", 8u, {
        I("Image Enhance", "Улучшение",           OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Palette",       "Палитра",             OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Zoom",          "Зум",                 OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("PIP",           "PIP",                 OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Take Picture",  "Сделать фото",        OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Take Video",    "Снять видео",         OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("TMO",           "TMO",                 OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("None",          "Нет",                 OSD_VAL_NONE, 0, 0, 0, 0, 0),
    }},

    { 0x0506u, "AUTO SHUTDOWN", "АВТО-ВЫКЛЮЧЕНИЕ", 2u, {
        I("Auto Shutdown", "Авто-выключение",   OSD_VAL_ONOFF, 1, 0, 0, 0, 0),
        I("Shutdown Time", "Время выключения",  OSD_VAL_EDIT,  0, 0, 0, 0, "05min"),
    }},

    { 0x0507u, "FACTORY SETTINGS", "ЗАВОДСКИЕ НАСТРОЙКИ", 2u, {
        I("Yes", "Да",  OSD_VAL_ACTION, 0, 0, 0, 0, 0),
        I("No",  "Нет", OSD_VAL_ACTION, 0, 0, 0, 0, 0),
    }},

    { 0x0508u, "PIXEL REPAIR", "РЕМОНТ ПИКСЕЛЕЙ", 3u, {
        I("Auto Repair", "Автовосстановление", OSD_VAL_ONOFF,  1, 0, 0, 0, 0),
        I("Manual Add",  "Ручное добавление",  OSD_VAL_ACTION, 0, 0, 0, 0, 0),
        I("Clear Tag",   "Очистить метку",     OSD_VAL_ACTION, 0, 0, 0, 0, 0),
    }},

    /* ============ 6 测量 ============ */
    { 0x0600u, "MEASURE", "ИЗМЕРЕНИЕ", 5u, {
        I("Laser Measure", "Лазерный дальномер",      OSD_VAL_ONOFF, 0, 0,       0, 0, 0),
        I("Distance Scan", "Сканирование расстояния", OSD_VAL_ONOFF, 0, 0,       0, 0, 0),
        I("Cursor Style",  "Стиль курсора",           OSD_VAL_NONE,  0, 0x0601u, 0, 0, 0),
        I("Cursor Color",  "Цвет курсора",            OSD_VAL_NONE,  0, 0x0602u, 0, 0, 0),
        I("Cursor Adjust", "Юстировка курсора",       OSD_VAL_NONE,  0, 0x0603u, 0, 0, 0),
    }},

    { 0x0601u, "CURSOR STYLE", "СТИЛЬ КУРСОРА", 3u, {
        I("Style1", "Стиль1", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Style2", "Стиль2", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Style3", "Стиль3", OSD_VAL_NONE, 0, 0, 0, 0, 0),
    }},

    { 0x0602u, "CURSOR COLOR", "ЦВЕТ КУРСОРА", 4u, {
        I("Red",    "Красный", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Yellow", "Жёлтый",  OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Blue",   "Синий",   OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Black",  "Чёрный",  OSD_VAL_NONE, 0, 0, 0, 0, 0),
    }},

    { 0x0603u, "CURSOR ADJUST", "ЮСТИРОВКА КУРСОРА", 2u, {
        I("Manual Adjust", "Ручная корректировка", OSD_VAL_ACTION, 0, 0, 0, 0, 0),
        I("Cancel",        "Отмена",               OSD_VAL_ACTION, 0, 0, 0, 0, 0),
    }},

    /* ============ 7 归零 ============ */
    { 0x0700u, "ZEROING", "ПРИСТРЕЛКА", 4u, {
        I("Zeroing Adjust", "Корректировка пристрелки", OSD_VAL_NONE, 0, 0x0701u, 0, 0, 0),
        I("Zeroing Group",  "Группа пристрелки",        OSD_VAL_NONE, 0, 0x0702u, 0, 0, 0),
        I("Reticle Style",  "Стиль прицела",            OSD_VAL_NONE, 0, 0x0703u, 0, 0, 0),
        I("Reticle Color",  "Цвет прицела",             OSD_VAL_NONE, 0, 0x0704u, 0, 0, 0),
    }},

    { 0x0701u, "ZEROING ADJUST", "КОРРЕКТИРОВКА ПРИСТРЕЛКИ", 4u, {
        I("Zoom",        "Зум",                 OSD_VAL_ENUM,  1, 0,       v_zoom, v_zoom, 0),
        I("Freeze",      "Заморозить",          OSD_VAL_ONOFF, 0, 0,       0, 0, 0),
        I("Reticle Adj", "Регулировка прицела", OSD_VAL_NONE,  0, 0x0710u, 0, 0, 0),
        I("Cancel Adj",  "Отмена регулировки",  OSD_VAL_ACTION, 0, 0,      0, 0, 0),
    }},

    { 0x0710u, "RETICLE ADJUST", "РЕЖИМ ЮСТИРОВКИ", 3u, {
        I("X 0320  Y 0104", "X 0320  Y 0104", OSD_VAL_EDIT, 0, 0, 0, 0, "X 0320  Y 0104"),
        I("Confirm",        "Подтвердить",    OSD_VAL_ACTION, 0, 0, 0, 0, 0),
        I("Cancel",         "Отмена",         OSD_VAL_ACTION, 0, 0, 0, 0, 0),
    }},

    { 0x0702u, "ZEROING GROUP", "ГРУППА ПРИСТРЕЛКИ", 5u, {
        I("Group Name",   "Имя группы",       OSD_VAL_ENUM, 0, 0, v_pos, v_pos, 0),
        I("Distance",     "Расстояние",       OSD_VAL_EDIT, 0, 0, 0, 0, "300"),
        I("Temperature",  "Температура",      OSD_VAL_EDIT, 0, 0, 0, 0, "15"),
        I("Humidity",     "Влажность",        OSD_VAL_EDIT, 0, 0, 0, 0, "45"),
        I("Air Pressure", "Давление воздуха", OSD_VAL_EDIT, 0, 0, 0, 0, "101"),
    }},

    { 0x0703u, "RETICLE STYLE", "СТИЛЬ ПРИЦЕЛА", 6u, {
        I("Style1", "Стиль1", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Style2", "Стиль2", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Style3", "Стиль3", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Style4", "Стиль4", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Style5", "Стиль5", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("None",   "Нет",    OSD_VAL_NONE, 0, 0, 0, 0, 0),
    }},

    { 0x0704u, "RETICLE COLOR", "ЦВЕТ ПРИЦЕЛА", 7u, {
        I("Red",    "Красный",   OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Yellow", "Жёлтый",    OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Blue",   "Синий",     OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Black",  "Чёрный",    OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("White",  "Белый",     OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Purple", "Пурпурный", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Green",  "Зелёный",   OSD_VAL_NONE, 0, 0, 0, 0, 0),
    }},

    /* ============ 8 弹道 ============ */
    { 0x0800u, "BALLISTIC", "БАЛЛИСТИКА", 6u, {
        I("Ballistic Calc",     "Баллистический калькулятор", OSD_VAL_ONOFF, 0, 0,       0, 0, 0),
        I("Ballistic Setting >", "Настройка баллистики >",    OSD_VAL_NONE,  0, 0x0801u, 0, 0, 0),
        I("Impact Style >",     "Вид маркера >",              OSD_VAL_NONE,  0, 0x0802u, 0, 0, 0),
        I("Impact Color >",     "Цвет маркера >",             OSD_VAL_NONE,  0, 0x0803u, 0, 0, 0),
        I("Angle Unit",         "Единица угла",               OSD_VAL_ENUM,  0, 0, v_angle, v_angle, 0),
        I("Motion Comp",        "Компенсация движения",       OSD_VAL_ONOFF, 0, 0,       0, 0, 0),
    }},

    { 0x0801u, "BALLISTIC SETTING", "НАСТРОЙКА БАЛЛИСТИКИ", 1u, {
        I("(TBD)", "(ОЖИДАЕТ)", OSD_VAL_NONE, 0, 0, 0, 0, 0),   /* 协议注明后续单独补充 */
    }},

    { 0x0802u, "IMPACT STYLE", "ВИД МАРКЕРА", 3u, {
        I("Style1", "Стиль1", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Style2", "Стиль2", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Style3", "Стиль3", OSD_VAL_NONE, 0, 0, 0, 0, 0),
    }},

    { 0x0803u, "IMPACT COLOR", "ЦВЕТ МАРКЕРА", 7u, {
        I("Red",    "Красный",   OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Yellow", "Жёлтый",    OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Blue",   "Синий",     OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Black",  "Чёрный",    OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("White",  "Белый",     OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Purple", "Пурпурный", OSD_VAL_NONE, 0, 0, 0, 0, 0),
        I("Green",  "Зелёный",   OSD_VAL_NONE, 0, 0, 0, 0, 0),
    }},

    /* ============ 9 模式切换 ============ */
    { 0x0900u, "DISPLAY SETTING", "НАСТРОЙКИ ДИСПЛЕЯ", 4u, {
        I("Display Position", "Положение отображения", OSD_VAL_ENUM,  0, 0,       v_pos, v_pos, 0),
        I("Moving >",         "Перемещение >",         OSD_VAL_NONE,  0, 0x0901u, 0, 0, 0),
        I("Analog Video",     "Аналоговое видео",      OSD_VAL_ONOFF, 0, 0,       0, 0, 0),
        I("Clip-On",          "Клиповый",              OSD_VAL_ONOFF, 0, 0,       0, 0, 0),
    }},

    { 0x0901u, "MOVING", "ПЕРЕМЕЩЕНИЕ", 3u, {
        I("Image",            "Изображение",            OSD_VAL_ACTION, 0, 0, 0, 0, 0),
        I("Default Position", "Положение по умолчанию", OSD_VAL_ACTION, 0, 0, 0, 0, 0),
        I("Cancel Moving",    "Отменить перемещение",   OSD_VAL_ACTION, 0, 0, 0, 0, 0),
    }},
};

unsigned scene_page_count(void) { return (unsigned)(sizeof(s_pages) / sizeof(s_pages[0])); }
const scene_page_t *scene_at(unsigned i) { return &s_pages[i]; }

unsigned scene_index(uint16_t page_id)
{
    unsigned i;
    for (i = 0u; i < scene_page_count(); i++) {
        if (s_pages[i].page_id == page_id) return i;
    }
    return scene_page_count();   /* 越界哨兵 */
}

unsigned scene_enum_count(const scene_item_t *it)
{
    unsigned n = 0u;
    if (it->vals_en == 0) return 0u;
    while (it->vals_en[n] != 0) n++;
    return n;
}

const scene_page_t *scene_find(uint16_t page_id)
{
    unsigned i;
    for (i = 0u; i < scene_page_count(); i++) {
        if (s_pages[i].page_id == page_id) return &s_pages[i];
    }
    return 0;   /* 未知 page_id：由命令层判非法（统一口径），不做兜底渲染 */
}
