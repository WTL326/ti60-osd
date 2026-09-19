///////////////////////////////////////////////////////////////////////////////////
//  Copyright (c) 2025 SaxonSoc contributors
//  SPDX license identifier: MIT
//  Full license header bsp/efinix/EfxSapphireSoc/include/LICENSE.MD
///////////////////////////////////////////////////////////////////////////////////

// 测试RISC-V工作区，避开RTL使用的区域
#define MEM_LOC             ((volatile uint32_t*)0x00400000)
#define MAX_WORDS           (1 * 1024 * 1024)  // 测试4MB
