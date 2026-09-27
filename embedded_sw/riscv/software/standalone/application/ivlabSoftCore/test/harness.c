/******************************************************************************
*
* @file harness.c: 最小裸机测试台
*
* @note 设计说明见 harness.h。
*
******************************************************************************/
#include <stdarg.h>
#include <stdint.h>
#include "harness.h"

/* qemu "virt" 机型的两个特殊地址：
 *   UART0_TX    —— NS16550 串口的数据寄存器，写一个字节就输出一个字符；
 *   SIFIVE_TEST —— SiFive 关机设备，写特定值可以让 qemu 结束运行。
 * 这两个地址是 qemu 这个机型固定的，与真实硬件无关——本测试只在 qemu 上跑。*/
#define UART0_TX     0x10000000U
#define SIFIVE_TEST  0x100000U

/* 关机设备的两个魔数：
 *   0x5555 表示"正常结束"（对应退出码 0）；
 *   0x3333 表示"异常结束"；把失败条数放到高 16 位，它就成了进程退出码。*/
#define TEST_PASS    0x5555U
#define TEST_FAIL    0x3333U

static int s_failures;   /* 累计失败数，最后变成退出码 */

/******************************************************************************
* @brief 输出单个字符。
*
* @param c 要输出的字符。
*
* @note `*(volatile unsigned char *)UART0_TX = c;` 这一行的读法：
*       UART0_TX 是个整数常量，先把它转成"指向易变无符号字符的指针"，
*       再解引用并赋值——也就是"往那个地址写一个字节"。
*
*       为什么必须加 volatile：这是编译器不知道的硬件副作用。如果没写
*       volatile，编译器看到"往一个固定地址写值、之后再也不读它"，
*       完全可能认为这次写没有意义而把它优化掉——串口就一个字符都出不来。
*       volatile 的作用就是告诉编译器"这个写有外部效果，不许删"。
******************************************************************************/
static void h_putc(char c)
{
    *(volatile unsigned char *)UART0_TX = (unsigned char)c;
}

/******************************************************************************
* @brief 输出一个字符串。
*
* @param s 以 '\0' 结尾的字符串。
*
* @note 遇到 '\n' 时先补一个 '\r'，把换行变成回车+换行。
*       串口的终端软件通常按这个约定处理，只发 '\n' 的话光标会换到下一行但
*       停在原来那一列，输出看起来是阶梯状的。
******************************************************************************/
void h_puts(const char *s)
{
    while (*s != '\0') {
        if (*s == '\n') {
            h_putc('\r');
        }
        h_putc(*s);
        s++;
    }
}

/******************************************************************************
* @brief 把无符号整数按指定进制输出。
*
* @param value 要输出的值。
* @param base  进制（10 或 16）。
* @param upper 十六进制时是否用大写。
*
* @note 与 src/app_log.c 里的 emit_uint 是同一套算法：取余得到低位、
*       存进临时数组、再倒序输出。这里独立实现一份，理由见 harness.h。
******************************************************************************/
static void h_putu(uint32_t value, uint32_t base, int upper)
{
    const char *digits = upper ? "0123456789ABCDEF" : "0123456789abcdef";
    char        tmp[11];
    uint32_t    n = 0U;

    if (value == 0U) {
        h_putc('0');
        return;
    }
    while ((value != 0U) && (n < sizeof(tmp))) {
        tmp[n] = digits[value % base];
        value /= base;
        n++;
    }
    while (n > 0U) {
        n--;
        h_putc(tmp[n]);
    }
}

/******************************************************************************
* @brief 格式化输出。
*
* @param format 格式串。
*
* @note 实现思路与 src/app_log.c 的 app_vformat 相同：扫描格式串，
*       普通字符直接输出，遇到 '%' 就按下一个字符决定取哪个参数、怎么打印。
*       关于 va_arg 取参数时的类型要求，见 app_log.c 里的详细说明。
******************************************************************************/
void h_printf(const char *format, ...)
{
    va_list ap;

    va_start(ap, format);
    while (*format != '\0') {
        if (*format != '%') {
            if (*format == '\n') {
                h_putc('\r');   /* 与 h_puts 一致：换行前补回车 */
            }
            h_putc(*format);
            format++;
            continue;
        }
        format++;
        switch (*format) {
        case 's': {
            const char *s = va_arg(ap, const char *);
            h_puts((s != 0) ? s : "(null)");
            break;
        }
        case 'c':
            h_putc((char)va_arg(ap, int));
            break;
        case 'd': {
            int32_t v = va_arg(ap, int32_t);
            if (v < 0) {
                h_putc('-');
                /* 同样用无符号运算求绝对值，避免 INT32_MIN 取负溢出。*/
                h_putu((uint32_t)0 - (uint32_t)v, 10U, 0);
            } else {
                h_putu((uint32_t)v, 10U, 0);
            }
            break;
        }
        case 'u':
            h_putu(va_arg(ap, uint32_t), 10U, 0);
            break;
        case 'x':
            h_putu(va_arg(ap, uint32_t), 16U, 0);
            break;
        case '%':
            h_putc('%');
            break;
        default:
            /* 不认识的格式符原样输出，便于发现格式串写错。*/
            h_putc('%');
            h_putc(*format);
            break;
        }
        format++;
    }
    va_end(ap);
}

/******************************************************************************
* @brief 记录一条断言的结果。
*
* @param ok   是否成立。
* @param name 断言的名字。
*
* @note 成功和失败都打印，而且马上打印——理由见 harness.h。
******************************************************************************/
void h_check(int ok, const char *name)
{
    if (ok) {
        h_printf("  PASS  %s\n", name);
    } else {
        s_failures++;
        h_printf("  FAIL  %s\n", name);
    }
}

/******************************************************************************
* @brief 累计失败数。
******************************************************************************/
int h_failures(void)
{
    return s_failures;
}

/******************************************************************************
* @brief 打印总结，并让 qemu 退出。
*
* @note 写 SIFIVE_TEST 会让 qemu 立刻结束。两种写法：
*         全部通过 → 写 0x5555，qemu 以退出码 0 结束；
*         有失败   → 把失败条数放在高 16 位、低 16 位写 0x3333，
*                    qemu 会把高 16 位当作退出码。
*       最后的无限循环只是保险——正常情况下上面那次写就已经让 qemu 停了，
*       永远不会执行到这里。但保留它可以让"如果模拟器不支持关机设备"这种情况
*       表现为"卡住"而不是"跑飞执行随机内存"。
******************************************************************************/
void h_done(void)
{
    if (s_failures == 0) {
        h_puts("ALL TESTS PASSED\n");
        *(volatile unsigned int *)SIFIVE_TEST = TEST_PASS;
    } else {
        h_printf("FAILURES: %d\n", (uint32_t)s_failures);
        *(volatile unsigned int *)SIFIVE_TEST =
            ((uint32_t)s_failures << 16) | TEST_FAIL;
    }
    for (;;) {
    }
}

/* ---------------------------------------------------------------------------
 * 输出捕获区
 *
 * 被测代码 app_log.c 调用的 bsp_printf 被 stub/bsp.h 换成了下面的
 * stub_bsp_printf，输出落进这块缓冲。测试再从缓冲里取出字节做断言。
 * ------------------------------------------------------------------------ */
#define CAPTURE_MAX 768U

static char     s_capture[CAPTURE_MAX];
static uint32_t s_capture_len;

void h_capture_reset(void)
{
    s_capture_len = 0U;
    s_capture[0] = '\0';
}

const char *h_capture_text(void)
{
    return s_capture;
}

uint32_t h_capture_len(void)
{
    return s_capture_len;
}

/* 往捕获区追加一个字节。满了就丢掉多余的——测试断言本来也不可能去检查
 * 几百字节以上的输出，所以这里不做出错处理，留一个 '\0' 位置即可。*/
static void capture_push(char c)
{
    if ((s_capture_len + 1U) < CAPTURE_MAX) {
        s_capture[s_capture_len] = c;
        s_capture_len++;
        s_capture[s_capture_len] = '\0';
    }
}

/******************************************************************************
* @brief 打印替身：把输出收进捕获区。
*
* @note 只实现 %s —— app_log.c 只用到这一种（它把整条消息格式化好后，
*       用 bsp_printf("%s", buf) 发出去，见 app_log_flush）。替身不做格式化，
*       因为格式化由被测代码自己完成，替身不该替它做。
*
* @note 捕获的是**原始字节**：'\r'、'\n' 都原样收下，一个都不转换。
*       这正是能验证"换行有没有展开成 CR+LF"的前提。
******************************************************************************/
void stub_bsp_printf(const char *format, ...)
{
    va_list ap;

    va_start(ap, format);
    while (*format != '\0') {
        if ((*format == '%') && (*(format + 1) == 's')) {
            const char *s = va_arg(ap, const char *);
            while (*s != '\0') {
                capture_push(*s);
                s++;
            }
            format += 2;
        } else {
            capture_push(*format);   /* 不含格式符的普通文本 */
            format++;
        }
    }
    va_end(ap);
}

/******************************************************************************
* @brief 把一段字节按"可见形式"打印出来：'\r' 打成 \r、'\n' 打成 \n。
*
* @note 为什么需要它：断言失败时如果直接把原始字节打出来，'\r' 和 '\n' 会在
*       终端上真的产生回车换行，看起来就是一行错位的乱码，根本判断不出到底是
*       多了还是少了哪个控制字符。转义之后一眼可辨。
******************************************************************************/
static void print_escaped(const char *s)
{
    while (*s != '\0') {
        if (*s == '\r') {
            h_puts("\\r");
        } else if (*s == '\n') {
            h_puts("\\n");
        } else {
            h_putc(*s);
        }
        s++;
    }
}

void h_check_capture(const char *expected, const char *name)
{
    const char *actual = s_capture;
    const char *e = expected;
    const char *a = actual;
    int ok = 1;

    /* 逐字节比到任一方结束；任一位置不同或长度不同都算失败。*/
    while ((*e != '\0') && (*a != '\0')) {
        if (*e != *a) {
            ok = 0;
            break;
        }
        e++;
        a++;
    }
    if ((*e != '\0') || (*a != '\0')) {
        ok = 0;
    }

    if (ok) {
        h_printf("  PASS  %s\n", name);
    } else {
        s_failures++;
        h_printf("  FAIL  %s\n", name);
        h_puts("        expected: ");
        print_escaped(expected);
        h_puts("\n        actual  : ");
        print_escaped(actual);
        h_puts("\n");
    }
}

/* ---------------------------------------------------------------------------
 * 启动代码
 *
 * 这是整个测试程序的第一条指令所在的地方。有两个细节必须注意，否则程序
 * 一上电就跑飞：
 *
 * 1) 必须用 __attribute__((naked))。
 *    普通 C 函数编译出来会先在开头插入一段"序言"（保存寄存器、调整栈指针）。
 *    而在复位那一刻，栈指针 sp 还是 0——序言里保存寄存器那一步会往地址
 *    0xFFFFFFFC 附近写东西，直接触发 fault。加 naked 让编译器**不要**生成
 *    序言，函数体就是我们写的这几条汇编。
 *
 * 2) 必须先设置 sp，再跳到 C 函数。
 *    因为任何普通 C 函数都可能用栈，所以栈必须在进入 C 代码之前就准备好。
 *    下面第一条汇编指令 `la sp, _sp` 就是做这件事，_sp 由链接脚本
 *    (qemu32.lds) 在 RAM 顶端算出来。
 *
 * section(".init") 把这段代码放进 .init 段，链接脚本会把它排在镜像最前面，
 * 从而落在 qemu 的入口地址上。
 * ------------------------------------------------------------------------ */
int test_main(void);

__attribute__((naked, used, section(".init"))) void _start(void)
{
    __asm__ volatile(
        "la sp, _sp\n\t"    /* 先把栈指针设好，后面才能调用 C 函数 */
        "j test_main\n"     /* 跳到测试主函数（用 j 而不是 call，不需要返回） */
    );
}
