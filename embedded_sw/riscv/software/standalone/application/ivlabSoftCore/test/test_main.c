/******************************************************************************
*
* @file test_main.c: 测试总入口
*
* @brief 依次调用各组用例，最后汇总结果并让 qemu 退出。
*
* @note 为什么把入口单独放一个文件：各组用例（test_protocol.c、test_app_log.c）
*       只负责"测什么"，不负责"怎么跑、以什么顺序跑"。分开之后，加一组新用例
*       只需在下面加一行，不必翻进某个用例文件去改它的入口函数。
*
* @note 这个文件的函数由 harness.c 里的 _start 跳转进来执行——也就是说它是
*       整个测试程序真正的"main"，只是名字不叫 main 而已（叫 main 会和启动
*       代码的约定混淆）。它不会返回：h_done() 会让 qemu 直接结束进程。
*
******************************************************************************/
#include "harness.h"

/* 各组用例的入口，分别定义在各自的文件里。
 * 这里显式声明一下：C 要求函数先声明后使用，否则编译器会假设它返回 int、
 * 参数不确定，一旦类型对不上就是难查的问题。*/
void test_protocol(void);
void test_app_log(void);

int test_main(void)
{
    h_puts("\nivlabSoftCore off-target tests\n\n");

    test_protocol();     /* 0xBB 协议：CRC、帧解析、ACK、分发表、计数 */
    test_app_log();      /* 调试通道：换行展开、分段边界、长消息完整性 */

    h_puts("\n");
    h_done();            /* 内部不会返回：它会让 qemu 带着失败条数退出 */
    return 0;
}
