/* =============================================================================
 * L6 主循环 —— 唯一的执行链条
 *   poll → feed → pop → dispatch → if(dirty){ scene_build → 选后台块 → render
 *           → commit → flip }
 * 一次变更 = 一次渲染 = 一次 commit；无命令则零写入（共识 #8）
 * =============================================================================
 */
#ifndef OSD_APP_H
#define OSD_APP_H

#include <stdint.h>

void osd_boot(void);
void osd_step(void);        /* 迭代一次；fw 侧 while(1) 调用，sim 侧显式驱动 */
int  osd_back_block(void);  /* 当前后台块（测试用） */

#endif /* OSD_APP_H */
