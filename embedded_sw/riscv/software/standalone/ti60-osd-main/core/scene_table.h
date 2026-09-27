/* =============================================================================
 * L2 场景表 —— 页面静态数据（C-5 已决：编译期静态表 + 线性查找）
 * page_id 约定：根 0x0000；子页 0x0100 / 0x0200 …
 * value_slot：-1 = 纯标签行；0..3 = 该行显示 v[slot]（右对齐）
 * =============================================================================
 */
#ifndef OSD_SCENE_TABLE_H
#define OSD_SCENE_TABLE_H

#include <stdint.h>
#include "osd_config.h"

typedef struct {
    const char *en;
    const char *ru;
} i18n_t;

typedef struct {
    uint16_t  page_id;
    i18n_t    title;
    unsigned  item_count;
    i18n_t    items[OSD_MAX_ITEMS];
    int8_t    value_slot[OSD_MAX_ITEMS];
} scene_page_t;

const scene_page_t *scene_find(uint16_t page_id);
unsigned            scene_page_count(void);
const scene_page_t *scene_at(unsigned i);

#endif /* OSD_SCENE_TABLE_H */
