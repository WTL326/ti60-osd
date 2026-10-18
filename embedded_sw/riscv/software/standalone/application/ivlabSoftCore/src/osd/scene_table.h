/* =============================================================================
 * L2 场景表 —— 页面静态数据（C-5 已决：编译期静态表 + 线性查找）
 *
 * 2026-10-18 变更：由 3 页原型扩为《技术协议-2》附录A 的 37 页全菜单树。
 * 文案与结构逐条对应已评审的样例文档 TI60_OSD_附录A全菜单显示样例_v0.1.html。
 *
 * page_id 分配（u16 层级化，样例文档 §0）：
 *   L1 根          0x0000
 *   L2 二级        0xNN00   NN = 一级菜单序号 01..09
 *   L3 三级        0xNN0k   k  = 1..F
 *   L4 四级        0xNN1k
 *
 * 条目值类型（Q3 已决：以 value_kind 取代原先的 value_slot）：
 *   NUM    强度/数值，渲染 [n]，SET_ITEM_VALUE 的 value 为 1 字节
 *   ONOFF  开关，渲染 On/Off（附录B：开关类直接显示 on/off）
 *   ENUM   枚举单选，渲染 vals[lang][val]
 *   EDIT   文本编辑值，渲染运行时缓冲（密码/时间/日期/数值输入）
 *   ACTION 动作项（拍照/录像/清除…），确认由设备端执行，无值列
 *   NONE   纯标签 / 导航
 *
 * 为什么换掉 value_slot：它只能表达"这行显示 v[0..3] 里的哪一个"，而那四个
 * 槽位是 SET_IMAGE_VALUES 的图像四参数。附录A 的值分布在几十个页面、类型有
 * NUM/ONOFF/ENUM/EDIT 四类，没有一项能塞进那四个槽位。改成"每行自带类型与
 * 一份运行期镜像"之后，加一页不再需要动协议。
 * =============================================================================
 */
#ifndef OSD_SCENE_TABLE_H
#define OSD_SCENE_TABLE_H

#include <stdint.h>
#include "osd_config.h"

/* 值类型 */
enum {
    OSD_VAL_NONE = 0,    /* 纯标签 / 导航 */
    OSD_VAL_NUM,         /* [n] 数值 */
    OSD_VAL_ONOFF,       /* On / Off */
    OSD_VAL_ENUM,        /* 枚举表索引 */
    OSD_VAL_EDIT,        /* 文本编辑缓冲 */
    OSD_VAL_ACTION       /* 动作项 */
};

typedef struct {
    const char *en;               /* 英文标签 */
    const char *ru;               /* 俄文标签 */
    uint8_t     kind;             /* OSD_VAL_* */
    uint8_t     def;              /* NUM/ONOFF/ENUM 初始值 */
    uint16_t    child;            /* 子页 page_id，0 = 无 */
    const char *const *vals_en;   /* ENUM 取值表（EN） */
    const char *const *vals_ru;   /* ENUM 取值表（RU） */
    const char *edit_def;         /* EDIT 初始串（0 = 空串） */
} scene_item_t;

typedef struct {
    uint16_t     page_id;
    const char  *title_en;
    const char  *title_ru;
    unsigned     item_count;
    scene_item_t items[OSD_ITEMS_CAP];
} scene_page_t;

const scene_page_t *scene_find(uint16_t page_id);
unsigned            scene_page_count(void);
const scene_page_t *scene_at(unsigned i);

/******************************************************************************
* @brief 按 page_id 查页**序号**。
*
* @param page_id 目标页面 ID。
* @return 页在 s_pages 里的下标；不存在时返回 scene_page_count()（越界哨兵）。
*
* @note 运行期值镜像 g_rt 是按页下标索引的，而命令层手里只有 page_id，所以需要
*       这一个"id → 下标"的换算。它和 scene_find 是同一趟线性查找、两份返回值：
*       一个给指针、一个给下标。不合并成一个"返回指针 + 出参下标"，是因为调用
*       方基本只需要其中一个，多一个出参会逼着每个调用点都声明一个变量。
******************************************************************************/
unsigned            scene_index(uint16_t page_id);

/******************************************************************************
* @brief 数出一条 ENUM 条目的取值个数。
*
* @param it 条目指针。
* @return 取值表长度；无表（vals_en == 0）时为 0。
*
* @note 靠 **NULL 哨兵**数长度，表本身不带长度字段——带长度字段就得在每张表
*       旁边再维护一个数字，改文案时很容易忘了同步。代价是：每张表**必须**以
*       0 结尾，漏了会一直读到数组外（越界读，结果不可预测），而 SET_ITEM_VALUE
*       的"枚举值越界"校验也会随之失效。scene_table.c 里每张表末尾的 0 不是
*       装饰，别删。
******************************************************************************/
unsigned            scene_enum_count(const scene_item_t *it);

#endif /* OSD_SCENE_TABLE_H */
