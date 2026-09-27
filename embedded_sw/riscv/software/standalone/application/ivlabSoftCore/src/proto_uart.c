/******************************************************************************
*
* @file proto_uart.c: uart1 协议端点的硬件层
*
* @note 设计理由与接口说明见 proto_uart.h。本文件里没有任何一行输出调试信息
*       的代码——这条界限是刻意的，不要在这里加日志。
*
******************************************************************************/
#include <stdint.h>

#include "bsp.h"
#include "uart.h"
#include "plic.h"
#include "riscv.h"
#include "proto_uart.h"

/* 只有 SoC 提供了 uart1 时才编译下面这些实现。
 * 否则走文件末尾那一组空实现（见 .c 末尾的 #else 分支）。*/
#if PROTO_ENDPOINT_AVAILABLE

/* UART 状态寄存器里"接收 FIFO 非空中断使能"这一位的掩码。
 *
 * 为什么是这个值：UART 的状态/控制寄存器在偏移 0x04 处，bit0 是"发送 FIFO 空中断
 * 使能"，bit1 是"接收 FIFO 非空中断使能"。这里要操作的是 bit1，所以掩码是 0x02。
 * 数值来自 driver/uart.h 里 uart_RX_NotemptyInterruptEna() 的实现。*/
#define UART_STATUS_RX_NOTEMPTY_INT_EN 0x02U

/* UART 错误寄存器：偏移 0x10，bit1 是"读溢出"（FIFO 满了还在收）。写 1 清零。
 *
 * driver/uart.h 只封装到偏移 0x0C（数据/状态/分频/帧格式），错误寄存器没有封装，
 * 所以这里直接用 io.h 的 read_u32/write_u32 访问。
 * 偏移与位定义来自 BSP 自带的寄存器描述文件
 * bsp/efinix/EfxSapphireSoc/openocd/sapphire_soc_xsvd.json 中 uart 外设的
 * errorBreak 寄存器（addressOffset 0x0010；readOverflow 在 bitOffset 1）。*/
#define UART_ERROR_REG                 0x10U
#define UART_ERR_READ_OVERFLOW         0x02U

/* 粘滞累计的 FIFO 溢出次数（见 proto_uart_fifo_overflow 的说明）。*/
static uint32_t s_fifo_overflow_seen;

/* ---------------------------------------------------------------------------
 * 接收环形缓冲
 *
 * 三个变量都加了 volatile，这个关键字在这里是必需的，不是可有可无的修饰：
 * 中断服务程序会改 s_head，主循环会读它；主循环会改 s_tail，中断服务程序也会
 * 读它。如果它们不是 volatile，编译器可能会认为"这个变量在这段代码里没被改过"，
 * 从而把它的值缓存进寄存器、不再每次都去内存里读——结果就是主循环永远看不到
 * 中断更新后的值，程序逻辑莫名其妙地不对。volatile 就是告诉编译器"这个变量
 * 可能在你看不见的地方被改，每次都老老实实去内存读写"。
 *
 * 分工（这是不需要关中断就能保证正确性的关键）：
 *   s_head 只由中断服务程序写、主循环只读；
 *   s_tail 只由主循环写、中断服务程序只读。
 * 两个指针各只有一个写入者，所以不存在"两边同时改同一个变量"的竞争。
 * ------------------------------------------------------------------------ */
static volatile uint8_t  s_ring[PROTO_RX_RING_SIZE];
static volatile uint32_t s_head;      /* 生产者（中断）的写指针 */
static volatile uint32_t s_tail;      /* 消费者（主循环）的读指针 */
static volatile uint32_t s_dropped;   /* 因环满而丢弃的字节数 */

/******************************************************************************
* @brief 初始化 uart1：配置 115200 8N1，并使能接收中断。
*
* @note 配置部分的写法和 bsp_init() 对 uart0 的处理完全相同——包括分频系数的
*       算式。这样两条串口的波特率算法只有一处需要理解，也避免"uart0 改了
*       算法、uart1 忘了跟着改"这种不一致。
*
* @note 调用顺序上，本函数要在 isr_init() 之前调用（见 main.c）：先把中断源
*       配好，再全局开中断。反过来的话，开中断后到中断源配置好之间可能出现
*       一个"中断已使能但没有正确处理程序"的窗口。
******************************************************************************/
void proto_uart_init(void)
{
    Uart_Config config;

    config.dataLength   = BITS_8;   /* 8 位数据 */
    config.parity       = NONE;     /* 无校验 */
    config.stop         = ONE;      /* 1 位停止位 */
    /* 分频系数 = 时钟频率 / (波特率 × 每字符位数) - 1
     * 这里的算式与 bsp.h 里 bsp_init() 的一字不差。*/
    config.clockDivider = BSP_CLINT_HZ / (BSP_UART_BAUDRATE * BSP_UART_DATA_LEN) - 1;

    uart_applyConfig(PROTO_UART_BASE, &config);

    /* 清空接收环和计数。*/
    s_head = 0U;
    s_tail = 0U;
    s_dropped = 0U;
    s_fifo_overflow_seen = 0U;
    /* 上电时硬件里可能留有之前（比如复位前）的溢出标志，先清掉，
     * 否则第一份汇总就会报一个不属于本次运行的溢出。*/
    write_u32(UART_ERR_READ_OVERFLOW, PROTO_UART_BASE + UART_ERROR_REG);

    /* 使能"接收 FIFO 非空"中断：FIFO 里一有数据就产生中断。*/
    uart_RX_NotemptyInterruptEna(PROTO_UART_BASE, 1);

    /* 把该中断接到本核（CPU 0）上。
     * threshold = 0 表示"优先级高于 0 的中断都接受"，即全部接受。
     * 这三步（threshold / enable / priority）是 PLIC 的标准配置顺序。*/
    plic_set_threshold(BSP_PLIC, BSP_PLIC_CPU_0, 0);
    plic_set_enable(BSP_PLIC, BSP_PLIC_CPU_0,
                    SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT, 1);
    plic_set_priority(BSP_PLIC, SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT, 1);
}

/******************************************************************************
* @brief 从接收环里取出一个字节。
*
* @param byte 输出：取到的字节。调用者必须保证不是空指针。
* @return 1 表示取到了；0 表示环是空的。
*
* @note “环空”的判断是 s_head == s_tail，即写指针追上读指针。
*       这里先把 s_tail 处的字节复制出来，**再**推进 s_tail。顺序不能颠倒：
*       如果先推进指针再读数据，中断可能在这两步之间又写入了新字节，我们就会
*       读到下一个字节、把当前这个漏掉。
******************************************************************************/
int proto_uart_rx_pop(uint8_t *byte)
{
    if (s_head == s_tail) {
        return 0;              /* 环空 */
    }
    *byte = s_ring[s_tail];
    s_tail = (s_tail + 1U) & (PROTO_RX_RING_SIZE - 1U);
    return 1;
}

/******************************************************************************
* @brief 当前接收环里积压的字节数。
*
* @return 字节数。
*
* @note 这个减法在 s_head < s_tail（指针回绕过一圈）时也不会出错，原因是
*       无符号整数的减法会自动"借位回绕"，结果正好等于实际积压量。
*       末尾的 & 掩码把结果限制在环容量范围内，同时也顺带处理了回绕。
*       这是环形缓冲用无符号数 + 2 的幂容量时的经典写法。
******************************************************************************/
uint32_t proto_uart_rx_pending(void)
{
    return (s_head - s_tail) & (PROTO_RX_RING_SIZE - 1U);
}

/******************************************************************************
* @brief 因接收环满而丢弃的字节数。
******************************************************************************/
uint32_t proto_uart_rx_dropped(void)
{
    return s_dropped;
}

/******************************************************************************
* @brief uart1 硬件接收 FIFO 累计溢出次数（粘滞）。
*
* @note 读硬件错误寄存器；一旦发现"读溢出"置位，就累计一次并写 1 清零。
*       因为硬件标志是"置位后保持到清除"的，所以本函数什么时候被调用都不影响
*       统计结果——这正是"粘滞"的含义：只关心"发生过没有"，不要求恰好在那
*       一刻读到。
*
* @note 清零是必要的：不清的话下一次读还会读到同一个置位，把一次溢出数成多次。
******************************************************************************/
uint32_t proto_uart_fifo_overflow(void)
{
    uint32_t err = read_u32(PROTO_UART_BASE + UART_ERROR_REG);

    if ((err & UART_ERR_READ_OVERFLOW) != 0U) {
        s_fifo_overflow_seen++;
        /* 写 1 清零（不是读-改-写：这个寄存器是"写 1 清除对应标志"的语义）。*/
        write_u32(UART_ERR_READ_OVERFLOW, PROTO_UART_BASE + UART_ERROR_REG);
    }
    return s_fifo_overflow_seen;
}

/******************************************************************************
* @brief 把 uart1 接收 FIFO 里的字节全部搬进接收环，然后重新使能中断。
*
* @note 这段的处理步骤参考了 BSP 示例 uartInterruptDemo 的写法，分三步：
*       先屏蔽中断源 → 排空 FIFO → 再使能中断。为什么先屏蔽：本 UART 的中断是
*       电平触发（FIFO 非空就持续有效），在排空过程中反复触发没有意义；先屏蔽
*       再排空、最后重新使能，可以把一次中断处理收敛成"一次性搬完当前所有字节"。
*
* @note 首先判断 uart_readOccupancy() 是否非零，然后才调用 uart_read()。
*       这一点很关键：driver 里的 uart_read() 实现是"FIFO 空就一直等"，是个
*       阻塞函数。如果在中断里不判断就调用它，一旦 FIFO 恰好被取空，中断服务
*       程序就会永远卡在那里，整个系统死掉。
*
* @note 环满时只递增丢弃计数、**继续把 FIFO 排空**。为什么要继续排空而不是
*       直接退出：FIFO 里剩下的字节如果不取走，中断会被反复触发，等于卡在
*       中断里出不去。宁可丢掉这些字节并计数，也要让中断能正常结束。
*
* @note 中断服务程序里只做"搬字节"这一件事，不做解析、不做任何输出。
*       解析放在主循环（见 main.c），这样中断的执行时间恒定且极短。
******************************************************************************/
void proto_uart_isr(void)
{
    uint32_t status;

    /* 第一步：读出状态寄存器，把"接收非空中断使能"这一位清掉（屏蔽中断源）。*/
    status = uart_status_read(PROTO_UART_BASE);
    uart_status_write(PROTO_UART_BASE,
                      (char)(status & ~UART_STATUS_RX_NOTEMPTY_INT_EN));

    /* 第二步：把 FIFO 里现有的字节全部搬进接收环。*/
    while (uart_readOccupancy(PROTO_UART_BASE) != 0U) {
        /* 先把字节读出来，同时算出"如果写入，写指针会到哪"。*/
        uint8_t  b    = (uint8_t)uart_read(PROTO_UART_BASE);
        uint32_t next = (s_head + 1U) & (PROTO_RX_RING_SIZE - 1U);

        if (next == s_tail) {
            /* 写指针再前进就会追上读指针，说明环满了。丢掉这个字节并计数。
             * 注意这里**不推进** s_head——推进了就等于覆盖掉还没被读走的数据。*/
            s_dropped++;
        } else {
            s_ring[s_head] = b;
            s_head = next;
        }
    }

    /* 第三步：重新使能中断，准备接收下一批。
     * 重新读一次状态寄存器再置位，而不是直接用第一步读到的 status：
     * 因为排空过程中硬件可能改了状态寄存器里的其它位（比如溢出标志），
     * 用旧值回写会把这些变化抹掉。*/
    uart_status_write(PROTO_UART_BASE,
                      (char)(uart_status_read(PROTO_UART_BASE) |
                             UART_STATUS_RX_NOTEMPTY_INT_EN));
}

/******************************************************************************
* @brief 在 uart1 上发送一段字节，等待空间时有上限。
*
* @param data 要发送的数据，允许为空。
* @param len  字节数。
* @return 1 表示全部发出；0 表示某个字节等超时了。
*
* @note 这里没有直接调用 driver 里的 uart_write()，而是自己写了一遍循环。
*       原因就是本文件开头提到的：driver 的版本是无限等待的，而我们需要一个
*       上限（PROTO_TX_TIMEOUT_SPINS），以免 UART 异常时把主循环卡死。
*       写入动作本身还是直接写 UART 的数据寄存器（偏移 UART_DATA），
*       与 driver 的行为一致。
*
* @note 为什么要等待"发送 FIFO 有空间"：UART 发送 FIFO 满了以后继续写会丢数据。
*       判断依据是状态寄存器里的 availability 字段（见 driver/uart.h 的
*       uart_writeAvailability），它表示 FIFO 还能再塞几个字节。
*
* @note 用 uint32_t guard 做倒计数，而不是用 `for (i = 0; i < 100000; i++)`：
*       倒计数到 0 只需要一条比较指令（和 0 比），正向计数要多一条比较。
*       这类微小差别在这种"每个字节都要等"的热点路径上有意义。
******************************************************************************/
int proto_uart_write(const uint8_t *data, uint32_t len)
{
    uint32_t i;
    uint32_t guard;

    if (data == 0) {
        return 0;
    }

    for (i = 0U; i < len; i++) {
        /* 每个字节单独重置一次自旋预算——等待是按"这一个字节"计的。*/
        guard = PROTO_TX_TIMEOUT_SPINS;
        while (uart_writeAvailability(PROTO_UART_BASE) == 0U) {
            if (guard == 0U) {
                return 0;   /* 等太久了，放弃这一帧的剩余部分 */
            }
            guard--;
        }
        /* 直接把字节写到 UART 的数据寄存器。用 write_u32（来自 driver/io.h）
         * 而不是给指针赋值，是为了沿用 driver 里统一的"内存映射寄存器访问"
         * 写法，将来若要加内存屏障之类只需改一处。*/
        write_u32(data[i], PROTO_UART_BASE + UART_DATA);
    }
    return 1;
}

/* ---------------------------------------------------------------------------
 * 以下是"SoC 没有 uart1"时的空实现。
 *
 * 为什么需要它们：所有调用点（main.c 等）是无条件调用这些函数的。如果这里
 * 什么都不提供，链接阶段会因为找不到符号而失败。提供一组签名完全相同的空
 * 函数，调用点一行都不用改，也能正常构建。
 *
 * 这些函数体里统一把参数转成 void，避免编译器报"参数未使用"的警告。
 * ------------------------------------------------------------------------ */
#else /* !PROTO_ENDPOINT_AVAILABLE */

void proto_uart_init(void)
{
}

int proto_uart_rx_pop(uint8_t *byte)
{
    (void)byte;
    return 0;      /* 永远"没有数据" */
}

uint32_t proto_uart_rx_pending(void)
{
    return 0U;
}

uint32_t proto_uart_rx_dropped(void)
{
    return 0U;
}

uint32_t proto_uart_fifo_overflow(void)
{
    return 0U;
}

void proto_uart_isr(void)
{
}

int proto_uart_write(const uint8_t *data, uint32_t len)
{
    (void)data;
    (void)len;
    return 0;
}

#endif /* PROTO_ENDPOINT_AVAILABLE */
