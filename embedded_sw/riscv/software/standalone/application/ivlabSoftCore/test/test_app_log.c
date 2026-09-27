/******************************************************************************
*
* @file test_app_log.c: 调试输出通道的离机测试
*
* @brief 测试 ../src/app_log.c —— 重点是"换行有没有正确展开成 \r\n"这段逻辑。
*
* @note 怎么在不上板的情况下测到输出内容：
*       app_log.c 最终通过 bsp_printf 把字节发出去，而 bsp_printf 在正式环境里
*       走的是 semihosting（要接调试器）。测试里用一个替身把它换掉，输出落进
*       内存缓冲（见 test/stub/bsp.h 与 harness.c 的 stub_bsp_printf），
*       于是就能逐字节断言"到底发出去了哪些字节"。
*
*       被测的仍是 ../src/app_log.c 正式那份代码，一行都没有为测试改过。
*
* @note 为什么专门测 '\r'：
*       它是**看不见的字符**。如果只断言"输出里有 hello 和换行"，那么少一个
*       '\r' 的 bug 完全测不出来——而那正是之前真实存在的问题（只发 '\n'，
*       日志呈阶梯状错位）。所以下面的断言比的是完整字节序列，'\r' 少一个就失败。
*
******************************************************************************/
#include <stdint.h>

#include "harness.h"
#include "app_log.h"

/* 造一个全是 'a' 的字符串，用来精确控制消息长度。
 * 不用手写长长的字面量，是因为长度必须和下面的断言严格对上，
 * 数错一个字符测试就会莫名其妙地失败。*/
static void make_a_string(char *buf, uint32_t count)
{
    uint32_t i;
    for (i = 0U; i < count; i++) {
        buf[i] = 'a';
    }
    buf[count] = '\0';
}

/* ===========================================================================
 * T6-1: 普通消息自动补换行，且发出去的是 CR+LF
 * =========================================================================== */
static void test_simple_message(void)
{
    h_puts("T6 app_log: 基本换行\n");

    /* 每个用例开始前把日志环和捕获区都清干净，避免上一条用例的残留
     * 影响这一条——测试之间必须互相独立才行。*/
    app_log_init();
    h_capture_reset();

    app_log("hello");
    h_check(app_log_pending() > 0U, "消息已入队");
    h_check(h_capture_len() == 0U, "入队时不应碰硬件（还没 flush）");

    (void)app_log_flush();

    /* 关键断言：末尾必须是 \r\n 两个字节，不是一个 \n。
     * 少一个 \r，终端上光标不回行首，日志就会阶梯状错位。*/
    h_check_capture("hello\r\n", "hello 后是 CR+LF");
}

/* ===========================================================================
 * T6-2: 消息正文里自带的 '\n' 也要展开
 * =========================================================================== */
static void test_embedded_newline(void)
{
    app_log_init();
    h_capture_reset();

    /* 调用者在消息里自己写了一个换行。展开逻辑放在 flush 里，
     * 所以这个内层换行也必须被正确展开成 \r\n。*/
    app_log("a\nb");
    (void)app_log_flush();

    h_check_capture("a\r\nb\r\n", "正文内的 \\n 也展开成 CR+LF");
}

/* ===========================================================================
 * T6-3: 分段边界不能把 "\r\n" 拆开
 *
 * 这是本次改动最容易写错的地方，所以单独测。
 * =========================================================================== */
static void test_chunk_boundary(void)
{
    char     msg[64];
    uint32_t first;
    uint32_t second;

    app_log_init();
    h_capture_reset();

    /* 造一条 31 字符的消息。加上自动补的 '\n'，环里正好 32 字节，
     * 而 APP_LOG_CHUNK 也是 32 —— 于是第一次 flush 会在离结尾只差
     * 一个 '\n' 时停下，正好把"放不下 CR+LF 时该怎么办"这个分支逼出来。*/
    make_a_string(msg, 31U);
    app_log("%s", msg);

    first = app_log_flush();

    /* 第一次只能发出 31 字节：那个 '\n' 需要两个位置（\r 和 \n），
     * 而剩余空间只剩一个，所以它被留在环里等下一次。
     * 如果实现写错成"先取字节再判断空间"，这里会发出 32 字节，
     * 并且把 '\r' 和 '\n' 拆到两次 flush 里——断言会立刻抓到。*/
    h_printf("        第一次 flush 发出 %u 字节（期望 31）\n", first);
    h_check(first == 31U, "边界处不拆分，'\\n' 留给下一次");

    /* 第二次补齐那对 CR+LF。*/
    second = app_log_flush();
    h_printf("        第二次 flush 发出 %u 字节（期望 2）\n", second);
    h_check(second == 2U, "下一次补发 CR+LF 两个字节");

    /* 拼起来必须恰好是 31 个 'a' 加 CR+LF，一个不多一个不少。*/
    {
        char expect[40];
        uint32_t i;
        for (i = 0U; i < 31U; i++) {
            expect[i] = 'a';
        }
        expect[31] = '\r';
        expect[32] = '\n';
        expect[33] = '\0';
        h_check_capture(expect, "两次 flush 拼接后内容完整正确");
    }

    /* 环已经空了，再 flush 应当什么都不发。*/
    h_check(app_log_flush() == 0U, "队列空时 flush 返回 0");
}

/* ===========================================================================
 * T6-4: 长消息要分很多段发，内容不丢不重
 * =========================================================================== */
static void test_long_message(void)
{
    /* 用测试自己的长度常量，而不是去引用 app_log.c 里的私有上限——
     * 测试不该依赖被测代码的内部实现细节，否则重构一下常量名测试就编不过。
     * 如果这条消息超出了被测代码的内部上限而被截断，下面的断言会立刻发现
     * （捕获长度对不上），所以不需要在这里预先知道那个上限是多少。*/
    #define TEST_LONG_LEN 100U

    char     msg[TEST_LONG_LEN + 1U];
    char     expect[TEST_LONG_LEN + 4U];
    uint32_t rounds = 0U;
    uint32_t i;
    uint32_t n;

    app_log_init();
    h_capture_reset();

    /* 造一条 100 字符的消息。环里共 101 字节，而每次 flush 最多发 32 字节，
     * 所以需要多次才能发完——正好覆盖"内容跨多段发出"这条路径。*/
    make_a_string(msg, TEST_LONG_LEN);
    app_log("%s", msg);

    /* 反复 flush 直到环空。加一个轮数上限，万一实现有 bug 导致
     * "永远发不完"也不会把测试卡死，而是让下面的断言报出来。*/
    while ((app_log_pending() > 0U) && (rounds < 100U)) {
        n = app_log_flush();
        if (n == 0U) {
            break;      /* 没进展，说明实现有问题，交给断言去报 */
        }
        rounds++;
    }
    h_printf("        分 %u 次发完\n", rounds);
    h_check(app_log_pending() == 0U, "长消息最终发完");

    /* 期望内容 = 100 个 'a' + CR+LF。*/
    for (i = 0U; i < TEST_LONG_LEN; i++) {
        expect[i] = 'a';
    }
    expect[TEST_LONG_LEN]      = '\r';
    expect[TEST_LONG_LEN + 1U] = '\n';
    expect[TEST_LONG_LEN + 2U] = '\0';
    h_check_capture(expect, "分段发送后内容不丢不重");
}

/* ===========================================================================
 * T6-5: 队列空时不产生任何输出
 * =========================================================================== */
static void test_empty(void)
{
    app_log_init();
    h_capture_reset();

    h_check(app_log_flush() == 0U, "空队列 flush 返回 0");
    h_check(h_capture_len() == 0U, "空队列不产生任何字节");
}

/* ===========================================================================
 * T7: app_log_once —— 同一类消息只报首次
 *
 * 这条接口是上板实测逼出来的：逐帧打日志的 semihosting 停顿把 uart1 接收环
 * 冲垮，26 个分块包只回了 10 个应答。所以"第二次调用必须一个字节都不产生"
 * 是本组的核心断言——不是"少打点"，而是"完全不打"。
 * =========================================================================== */
static void test_log_once(void)
{
    uint32_t after_first;
    uint32_t before;

    h_puts("T7 app_log_once: 只报首次\n");

    app_log_init();
    h_capture_reset();

    /* 首次调用应当正常输出，格式与 app_log 一致（末尾带 CR+LF）。*/
    app_log_once(3U, "once-a");
    (void)app_log_flush();
    h_check_capture("once-a\r\n", "first call outputs");

    /* 记录此刻的字节数，作为"第二次什么都没产生"的基准。*/
    after_first = h_capture_len();

    /* 同一个位号再来一次：必须一个字节都不产生。
     * 断言比较的是"捕获总长度没变"——这比"输出里没出现某段文字"更强，
     * 因为任何形式的输出都会让长度变化。*/
    app_log_once(3U, "once-a-again");
    (void)app_log_flush();
    h_check(h_capture_len() == after_first,
            "second call with same bitno outputs nothing");

    /* 换一个位号仍应输出：证明是按位独立，而不是"报过一次就永久闭嘴"。*/
    app_log_once(5U, "once-b");
    (void)app_log_flush();
    h_check_capture("once-a\r\nonce-b\r\n", "different bitno still outputs");

    /* 越界位号必须被挡住。C 里 1U << 32 是未定义行为（不是得到 0），
     * 而 bitno 常直接来自枚举值，将来加枚举成员就可能越界。*/
    before = h_capture_len();
    app_log_once(32U, "out-of-range");
    (void)app_log_flush();
    h_check(h_capture_len() == before, "bitno >= 32 is rejected");

    /* 越界调用还不能把掩码搅乱：位号 3 此前已报过，现在仍应保持安静。
     * 若实现写成了 1U << (bitno & 31)，越界就会误设位 0 之外的位置，
     * 这一条能抓出那种"看起来没输出、其实副作用已经发生"的写法。*/
    app_log_once(3U, "once-a-third");
    (void)app_log_flush();
    h_check(h_capture_len() == before,
            "out-of-range call did not disturb the mask");

    /* 复位后同一位号应能再报一次：证明掩码确实被 app_log_init 清掉了。*/
    app_log_init();
    h_capture_reset();
    app_log_once(3U, "after-init");
    (void)app_log_flush();
    h_check_capture("after-init\r\n", "app_log_init clears the once-mask");
}

/* 供 test_main 调用的一组用例。*/
void test_app_log(void)
{
    test_simple_message();
    test_embedded_newline();
    test_chunk_boundary();
    test_long_message();
    test_log_once();
    test_empty();
}
