/******************************************************************************
*
* @file main.c: ivlabSoftCore
*
* @brief IVLAB 239 视频管线的软核应用。在 uart1 上提供 0xBB 命令协议端点，
*        调试输出走 semihosting（JTAG）通道。
*
* @note 2026-09：本端点现在管**两个**大类 —— 0x00（掩膜）与 0x04（UI 菜单）。
*       UI 那一侧还要把菜单画布渲染进 HyperRAM 并提交，于是"协议判断 →
*       渲染 → 提交 → 应答"这条链被抽到 osd_engine 里，本文件只负责取字节、
*       解析、把引擎给出的应答写出去。抽出这一层的目的是可测：main.c 依赖
*       bsp.h，在 qemu 上跑不了，而那条链里恰恰藏着"提交后才应答"这条
*       最容易写错的顺序规则（见 osd_engine.h）。
*
* @note 调试输出走 BSP 的 semihosting 通路（受 bsp.h 里的
*       ENABLE_SEMIHOSTING_PRINT 控制，取值必须为 1），因此打到 JTAG 调试
*       控制台，而不是 uart0 的硬件串口引脚。
*       标准 C 库的 printf **不是**本工程的调试通道：common/syscalls.c 里的
*       _write 是个空壳，printf 的输出会被静默丢弃。要看东西就用 app_log()。
*
* @note 主循环的顺序很关键，不能随意调整：
*       先完整排空并处理 uart1 → 再输出一小段日志。
*       理由是 semihosting 每输出一个字符都要让 CPU 停顿等主机响应，这期间
*       uart1 的接收中断不会被服务。把协议放在前面，就保证了"停顿只发生在
*       没有待处理数据的时候"。
*
* @note 本文件是"胶水层"：把 frame（解析）、protocol（策略）、proto_uart（硬件）、
*       app_log（日志）四块拼起来，并决定什么时候输出什么信息。
*       它自己不实现任何协议逻辑。这样分层是为了让前三块都能脱离硬件做测试。
*
******************************************************************************/
#include <stdint.h>
#include "bsp.h"
#include "riscv.h"
#include "plic.h"
#include "clint.h"

#include "app_log.h"
#include "proto_uart.h"
#include "frame.h"
#include "protocol.h"
#include "osd/osd_engine.h"     /* 渲染/提交/应答的时序都在这层 */
#include "osd/osd_config.h"     /* 位图基址等契约常量（横幅里要打出来） */

/* RISC-V 的"断点异常"编号。
 * BSP 的头文件里只定义了 2/7/9/11 号异常，我们依赖的这一个没有，所以在这里
 * 自己定义。这个编号的用途见下面 trap() 里的说明。*/
#define CAUSE_BREAKPOINT 3

/* 周期性汇总的间隔（帧）。它只负责"长时间不停的流"这种场景——短跑批由
 * 下面的"线路静默后补一条汇总"覆盖，所以这个值可以取得宽松些。
 *
 * 注意这两条汇总消息入队后**不会立刻发出**（发送被推迟到线路静默期，见主循环），
 * 所以它们的数量只影响日志环的占用，不影响协议时序。*/
#define STATS_INTERVAL 64U

/* app_log_once() 的位号分配。
 * 失败原因（protocol_reason_t）直接用自己的值占 0–6 位，所以这里取一个不会
 * 撞车的位号。将来新增的"只报首次"类别也往这后面排。*/
#define ONCE_BIT_RX_DROPPED 16U

/* 串口线路"静默多久"才允许输出调试日志。
 *
 * 为什么必须有这个门槛：semihosting 的 ebreak 会让 hart 停住在调试模块里，
 * 期间**任何中断都不被响应**，uart1 的 128 字节接收 FIFO（115200 下约 11 ms 的
 * 量）会自己溢出并静默丢字节。所以只要在"数据还在来"的时候输出日志，就一定会
 * 丢数据——接收环计数看不见这一种丢失，排查时极难定位。
 *
 * 200 ms 的依据：上位机工具在包与包之间只静默约 50 ms（它自己的 shell 循环里
 * 有 sleep 0.05，外加读取应答的时间）。取 200 ms 既能保证"包间绝不输出"，
 * 又能在整批结束后及时给出结果。*/
#define APP_LOG_IDLE_MS     200U
#define APP_LOG_IDLE_TICKS  ((uint64_t)(BSP_CLINT_HZ / 1000U) * (uint64_t)APP_LOG_IDLE_MS)

/* 读 CLINT 时间要 3 次 MMIO，不能每轮都读。用自增计数器做粗降频：每 4096 轮
 * 才真正读一次时间（约几十到一百多微秒一次）。对 200 ms 级别的门槛来说，
 * 这点量化误差无关紧要。（必须是 2 的幂——取模用位与实现。）*/
#define IDLE_TICKS_DIVIDER  4096U

/* ---------------------------------------------------------------------------
 * 全局状态
 *
 * 这些变量都定义在文件作用域（而不是函数内部），因为中断服务程序也要访问
 * 其中一部分（s_isr_unknown_source 在中断上下文里被改）。如果定义成局部变量，
 * 中断程序就够不着了。
 *
 * 关于 static：这四个变量只在本文件可见。软核程序通常只有一条执行路径，
 * 用全局变量比到处传参数更直接；但加上 static 至少能防止别的文件误用重名。
 * ------------------------------------------------------------------------ */
static frame_parser_t   s_parser;          /* 帧解析器状态 */
static protocol_stats_t s_stats;           /* 收包统计 */
static uint32_t         s_frames_processed;/* 已处理的帧总数 */

/* 异常诊断计数。
 * 为什么用"计数"而不是"直接打印"：如果某个异常反复触发，每触发一次就打一条
 * 日志会把日志环冲爆、反而掩盖真正的问题。所以这里只累加计数，异常类型中
 * 只把"非预期异常"的第一条打到日志里（见 trap()）。*/
static uint32_t s_semihosting_breakpoints;      /* semihosting 调用产生的断点 */
static uint32_t s_unexpected_interrupts;        /* 非预期的中断源 */
static uint32_t s_unexpected_exceptions;        /* 非预期的异常 */
static uint8_t  s_unexpected_exception_logged;  /* 是否已经打过第一条异常日志 */

static uint32_t s_isr_unknown_source;           /* PLIC 报出的未知中断源次数 */

/* --- 日志发送的门控状态（见主循环里"线路静默才输出"的说明）--- */

/* 最后一次从 uart1 收到字节的时刻（CLINT tick）。初值 0 是刻意的：
 * 上电后第一次进入主循环时 (now - 0) 已经很大，于是启动横幅会立刻发出，
 * 不必等 200 ms。*/
static uint64_t s_last_rx_ticks;

/* 上一次输出汇总时已经处理到第几帧。与 s_frames_processed 比较即可知道
 * "这一批还有没有没汇报过的帧"。*/
static uint32_t s_reported_frames;

/* 空闲轮计数，用于给"读时间"降频（见 IDLE_TICKS_DIVIDER）。*/
static uint32_t s_idle_spins;

/* 上次看到的两种"丢字节"计数。
 * 它们必须分开记：ring_drop 是接收环满（主循环太慢），fifo_ovf 是硬件 FIFO 溢出
 * （CPU 被 semihosting 停住、中断没被响应）。病因不同、修法也不同。*/
static uint32_t s_ring_drop_seen;
static uint32_t s_fifo_ovf_seen;

/* 这三个函数定义在别处，但要在使用前声明：
 *   trap()        本文件下方定义，被汇编启动代码 trap.S 调用；
 *   trap_entry()  定义在 ../common/trap.S，是 CPU 的异常/中断入口；
 *   isr_routine() 本文件下方定义。
 * 在 C 里，函数必须先声明后使用，否则编译器会假设它返回 int、参数不确定，
 * 这在 32 位平台上碰巧能工作，但一旦类型对不上就是难查的 bug。*/
void trap();
void trap_entry();
void isr_routine();

/******************************************************************************
* @brief 处理 PLIC 上报的中断，直到没有待处理的中断为止。
*
* @note PLIC 的标准处理流程是一个循环：claim（认领一个待处理中断，拿到它的
*       编号）→ 处理 → release（告诉 PLIC 处理完了）。循环到 claim 返回 0
*       说明没有更多待处理中断了。
*       为什么必须 release：不释放的话 PLIC 会认为这个中断还在处理中，
*       同源的中断再也不会送上来，uart1 就此失聪。
*
* @note 本工程只使能了 uart1 接收这一个中断源。如果 claim 报出别的编号，
*       说明配置有问题——但这里只计数、不打印、不崩溃。理由：一旦某段代码
*       跑不到预期路径，先保住系统继续运行、把线索留下来，比立刻停机更容易
*       排查。而且这里在中断上下文里，绝对不能输出日志。
******************************************************************************/
void isr_routine(){
    uint32_t claim;

    /* 注意这个循环的写法：把"赋值"和"判断非零"合并在一句里。
     * plic_claim 返回 0 表示没有待处理中断，循环自然结束。*/
    while ((claim = plic_claim(BSP_PLIC, BSP_PLIC_CPU_0)) != 0U) {
        if (claim == SYSTEM_PLIC_SYSTEM_UART_1_IO_INTERRUPT) {
            proto_uart_isr();      /* 把收到的字节搬进接收环 */
        } else {
            s_isr_unknown_source++;
        }
        plic_release(BSP_PLIC, BSP_PLIC_CPU_0, claim);
    }
}

/******************************************************************************
* @brief 异常与中断的统一入口。
*
* @note 这个函数由 ../common/trap.S 里的 trap_entry 调用。CPU 遇到任何异常
*       （除零、非法指令、断点……）或中断，都会先跳到 trap_entry 保存寄存器，
*       再调用这里判断该怎么办。
*
* @note 关于 mcause 的编码规则：最高位为 1 表示"中断"，为 0 表示"异常"；
*       低几位是具体的原因编号。所以：
*         mcause < 0        → 最高位是 1 → 这是一次中断
*         mcause & 0xF      → 取出原因编号（低 4 位）
*       代码里就是按这个规则拆的。
*
* @note 为什么"断点异常"要容忍而不是当错误处理：
*       调试输出用的 semihosting，其底层是往代码里插一条特殊指令序列
*       （slli x0,x0,0x1f; ebreak; srai x0,x0,7，见 BSP 的 semihosting.h）。
*       ebreak 这条指令会让 CPU 停下、等调试器来处理。
*       但如果**没有连接调试器**，就没人处理它，ebreak 会变成一个普通的
*       "断点异常"跳进这里。这时候如果像其它异常一样停机，整个软核就死了、
*       协议端点也随之失效——而现场完全可能不接调试器运行。
*       所以这里对它特殊处理：只计数、直接返回。
*       返回之后 CPU 会接着执行 ebreak 的下一条指令（srai x0,x0,7，这条
*       只是往 x0 里写值，没有副作用），于是这次 semihosting 调用就安静地
*       变成了"什么都不做"，程序继续正常跑。
*
* @note 其它异常是真故障（比如非法指令），既不吞掉也不停机：计数 + 只把第一条
*       打到日志里，然后继续运行。这样既留下了线索，又不会因为一个偶发异常
*       让整个视频管线停摆。
*       在这里调用 app_log 是安全的——app_log 只往内存里的环写数据，不碰硬件；
*       真正会停顿的 app_log_flush 只在主循环里调用。
******************************************************************************/
void trap(){
    int32_t mcause = csr_read(mcause);   /* 读 CSR 寄存器，得到异常/中断原因 */
    int32_t interrupt = mcause < 0;      /* 最高位为 1 → 中断 */
    int32_t cause     = mcause & 0xF;    /* 低 4 位 → 具体原因编号 */

    if (interrupt) {
        if (cause == CAUSE_MACHINE_EXTERNAL) {
            /* 11 号中断 = 外部中断，也就是 PLIC 上报的那些。*/
            isr_routine();
        } else {
            s_unexpected_interrupts++;
        }
        return;
    }

    if (cause == CAUSE_BREAKPOINT) {
        /* semihosting 调用、且没有调试器接管：忽略。详见上面的说明。*/
        s_semihosting_breakpoints++;
        return;
    }

    /* 其余都是真异常。每次计数，但只把第一条打进日志，
     * 免得一个反复触发的故障把日志环冲爆。*/
    s_unexpected_exceptions++;
    if (!s_unexpected_exception_logged) {
        s_unexpected_exception_logged = 1;
        app_log("trap: unexpected exception mcause=0x%x", (uint32_t)mcause);
    }
}

/******************************************************************************
* @brief 设置异常入口并使能外部中断。
*
* @note 三步缺一不可：
*         mtvec  —— 告诉 CPU "发生异常/中断时跳到哪"，这里填 trap_entry；
*         mie    —— 允许"机器模式外部中断"这一类中断；
*         mstatus—— 把 CPU 的中断总开关打开。
*       顺序上必须**最后**才打开总开关（mstatus 的 MIE 位），否则在处理器
*       还没准备好的窗口里就可能进来一个中断。
*
* @note csr_set / csr_read 是 BSP 提供的 CSR 访问宏（driver/riscv.h）。
*       用它们而不是直接写内联汇编，是为了让代码在不同 RISC-V 编译器下都能用。
*
* @note 本函数必须在 proto_uart_init() 之后调用：先把中断源配置好，
*       再让中断有机会进来。
******************************************************************************/
static void isr_init(){
    csr_write(mtvec, trap_entry);        /* 异常/中断入口，定义在 ../common/trap.S */

    /* 允许机器模式外部中断。1 << 11，对应上面 CAUSE_MACHINE_EXTERNAL。*/
    csr_set(mie, MIE_MEIE);

    /* 打开中断总开关。MSTATUS_MPP 是设置"陷入时保存的特权级"，
     * 保证返回之后仍工作在机器模式。*/
    csr_write(mstatus, csr_read(mstatus) | MSTATUS_MPP | MSTATUS_MIE);
}

/******************************************************************************
* @brief 把一个帧的处理结果输出到调试通道。
*
* @param frame    解析结果，用来报出命令码和长度。
* @param response 处理决定，用来判断该不该输出、输出什么原因。
*
* @note 只有"异常情况"才输出。一个被成功执行的帧**完全不产生输出**。
*       为什么这样设计：正常业务不应该和调试通道抢时间。如果每帧都打日志，
*       而日志会让 CPU 停顿，那么"帧率越高、系统越卡"，形成恶性循环。
*       保持正常路径安静，日志就只在真正出问题时出现。
*
* @note 本次变更是"只做协议框架"，所有命令都返回"未实现"，所以实际上每个帧
*       都会走到 NOT_IMPLEMENTED 那一支、都会打一行日志。等某条命令真正实现
*       之后，那条命令的成功帧就会安静下来。
*
* @note switch 里把 PROTO_REASON_OK 写成空分支（只有一个 break），是刻意的：
*       让"成功时什么都不做"这个决定在代码里显式可见，而不是靠"忘了写这个
*       case"来实现。default 兜到"完整性错误"那一支，保证即使将来加了新的
*       原因码，也一定会有日志输出、不会静默。
******************************************************************************/
static void report_frame(const frame_t *frame, const protocol_response_t *response){
    /* 按"失败原因"分位：同一类原因整轮只报首次。
     *
     * 为什么必须这样：本阶段每个掩膜帧都会失败（子项未实现），逐帧打日志的
     * 代价是真实的——实测 26 个分块包只回了 10 个应答，原因就是日志的
     * semihosting 停顿把 512 字节的接收环冲垮了。详见 app_log.h 的说明。*/
    const uint32_t bit = (uint32_t)response->reason;

    switch (response->reason) {
    case PROTO_REASON_OK:
        break;                 /* 成功：保持安静 */

    case PROTO_REASON_OTHER_CATEGORY:
        /* 电子变倍/热点/伪彩色的帧：同一根串口线上正常的、持续发生的
         * 流量，不是异常。逐条打出来会把日志刷爆，还会因为 semihosting 的
         * 停顿挤掉真正有用的输出。所以这里不打日志，只由统计行体现。
         * （0x04 已从这一组移出 —— 它现在归本端点管。）*/
        break;

    case PROTO_REASON_DEFERRED:
        /* UI 命令成功，且应答已经等画布提交完成才发出。成功路径保持安静，
         * 理由与 PROTO_REASON_OK 相同：正常业务不该和调试通道抢时间。*/
        break;

    case PROTO_REASON_UI_IGNORED:
        /* UI 的 0x01–0x05：本端点不实现、按协议只解析不应答。这同样是
         * "链路上正常的流量"而不是异常 —— `send_ui_via_adb.py --show` 之类
         * 会走到这里，它超时是预期行为。逐条打日志只会刷屏。*/
        break;

    case PROTO_REASON_NOT_IMPLEMENTED:
        app_log_once(bit, "rx cmd=0x%x (%s) len=%u -> not implemented, nak",
                     (uint32_t)frame->command, response->command_name,
                     (uint32_t)frame->body_length);
        break;
    case PROTO_REASON_UNKNOWN_COMMAND:
        app_log_once(bit, "rx cmd=0x%x unknown, nak", (uint32_t)frame->command);
        break;
    case PROTO_REASON_BAD_LENGTH:
        app_log_once(bit, "rx cmd=0x%x (%s) len=%u wrong, nak",
                     (uint32_t)frame->command, response->command_name,
                     (uint32_t)frame->body_length);
        break;
    case PROTO_REASON_BAD_FORMAT:
        app_log_once(bit, "rx cmd=0x%x bad type, nak", (uint32_t)frame->command);
        break;
    case PROTO_REASON_BAD_INTEGRITY:
    default:
        /* 这一支**不发应答**：字节都不可信，无从判断这一帧属于哪个模块，
         * 贸然回应可能撞进别的模块的通信。所以写 no-ack 而不是 nak。*/
        app_log_once(bit, "rx cmd=0x%x crc/footer bad -> no-ack",
                     (uint32_t)frame->command);
        break;
    }
}

/******************************************************************************
* @brief 输出一行收包汇总，并记下"汇报到第几帧了"。
*
* @note 汇总里每个计数的含义，以及为什么必须**分开**报：
*         accepted  完整性/格式通过、子项已识别、长度正确的掩膜帧
*         bad       掩膜帧里不合格的（CRC 错、格式错、子项未知、长度不符）
*         other     收到但不属于本端点的帧（变倍/热点/伪彩色/UI），不算错误
*         bad_len   长度字段越界、在长度阶段就被拒的帧（连 body 都没读）
*         ring_drop 接收环满导致的丢字节——**主循环太慢**
*         fifo_ovf  硬件接收 FIFO 溢出导致的丢字节——**CPU 被 semihosting 停住**
*         log_drop  因日志环装不下而被整条丢弃的日志消息
*       最后三项都是"东西悄悄没了"，但病因完全不同：ring_drop 要查主循环，
*       fifo_ovf 要查调试输出，log_drop 要查日志环大小。混在一起就没法定位。
******************************************************************************/
static void log_stats(void)
{
    app_log("stats: frames=%u accepted=%u bad=%u other=%u bad_len=%u "
            "ring_drop=%u fifo_ovf=%u log_drop=%u",
            s_frames_processed, s_stats.accepted_count,
            s_stats.bad_packet_count, s_stats.other_category_count,
            s_parser.bad_length_count,
            proto_uart_rx_dropped(), proto_uart_fifo_overflow(),
            app_log_dropped());
    s_reported_frames = s_frames_processed;
}

/******************************************************************************
* @brief 检查两种"丢字节"计数，一旦从没丢变成开始丢就报一次警。
*
* @note 这是本应用里最有诊断价值的一行。"帧莫名其妙少了"这个现象看起来像协议
*       错误或接线问题，实际上最容易的原因是丢字节，而丢字节又分两种、都发生在
*       正常视线之外：
*         - 接收环满（主循环被慢操作拖住）；
*         - 硬件 FIFO 溢出（CPU 被 semihosting 停住、中断没被响应）。
*       把两个数一起打出来，就不必再从现象反推。
*
* @note 用 app_log_once：溢出一旦发生就会连续发生，逐次打印会把刚修好的
*       "日志拖垮协议"问题又请回来。
******************************************************************************/
static void poll_rx_loss(void)
{
    uint32_t ring_drop = proto_uart_rx_dropped();
    uint32_t fifo_ovf  = proto_uart_fifo_overflow();

    if ((ring_drop != s_ring_drop_seen) || (fifo_ovf != s_fifo_ovf_seen)) {
        s_ring_drop_seen = ring_drop;
        s_fifo_ovf_seen = fifo_ovf;
        app_log_once(ONCE_BIT_RX_DROPPED,
                     "rx lost: ring_drop=%u fifo_ovf=%u (debug pause too long?)",
                     ring_drop, fifo_ovf);
    }
}

/******************************************************************************
* @brief 处理一个已经收完整的帧：判断 → 上报 → 应答。
*
* @param frame 解析好的帧。
*
* @note 这个函数是**原子**的：从判断到把 ACK 交给 UART 为止，中间不会再去接收
*       环里取字节。这是有意为之，而且是在修正 RTL 端点的一个缺陷——
*       RTL 那边的做法是"发应答的同时继续收下一帧"，而它的应答请求信号只维持
*       一个时钟周期、发送器又只在空闲时才看这个信号；结果就是：
*       如果上一帧的应答还没发完，紧接着到达的下一帧，它的应答会被**静默丢掉**，
*       而且没有任何错误提示。软件侧用"发送期间不接收"就把这个问题从根上消掉了。
*
* @note 代价是发送这段字节期间（10 字节在 115200 下约 868 微秒，
*       QUERY_VIEW 的 18 字节约 1.56 毫秒）不解析新字节。
*       但这期间到达的字节并不会丢——uart1 的接收中断照常把它们搬进接收环
*       （中断不受主循环阻塞的影响），只是解析要等这一帧处理完。接收环有
*       512 字节的余量，足够覆盖这段时间。
*
* @note **渲染与提交发生在 osd_engine_handle() 里面**，而且排在成功应答之前。
*       UI 的 SET_VIEW / SET_IMAGE_VALUES 要"提交后才应答"（协议 §5.5），
*       这条顺序规则属于引擎，不属于这里 —— 本函数只管把引擎给的字节发出去。
******************************************************************************/
static void handle_frame(const frame_t *frame){
    protocol_response_t response;
    uint8_t             ack[PROTOCOL_ACK_MAX];
    uint8_t             ack_len;

    ack_len = osd_engine_handle(&s_stats, frame, &response, ack);
    s_frames_processed++;

    report_frame(frame, &response);

    if (ack_len != 0U) {
        /* 把引擎拼好的应答直接发出去。返回值表示是否发送成功，
         * 这里刻意忽略——发送失败只可能是 UART 异常，而那种情况下也没有
         * 更好的补救办法。长度是变量：UI 的 QUERY_VIEW 是 18 字节，
         * 其余都是 10 字节，写死 PROTOCOL_ACK_LEN 会把那个应答截断。*/
        (void)proto_uart_write(ack, ack_len);
    }

    poll_rx_loss();

    if ((s_frames_processed % STATS_INTERVAL) == 0U) {
        log_stats();
    }
}

/******************************************************************************
* @brief 程序入口。
*
* @note main 返回类型是 void、没有参数。裸机环境下这是 BSP 的约定
*       （../common/start.S 里是 `call main`），不需要 argc/argv，
*       也不会返回——后面是个死循环。
*
* @note 初始化顺序是有依赖的：
*         bsp_init()      配置 uart0（BSP 的既有行为，调试通道的寄存器基础）
*         app_log_init()  清日志环，必须在任何 app_log 调用之前
*         frame_parser_init / protocol_init  清协议状态
*         proto_uart_init()  配置 uart1 和它的中断源
*         isr_init()      最后才打开中断总开关
*       把 isr_init() 放在最后是关键的：如果先开中断再配 uart1，
*       中间那个窗口里进来的中断会找不到正确的处理路径。
******************************************************************************/
void main() {
    bsp_init();                 /* BSP 的通用初始化，其中包含 uart0 的配置 */
    app_log_init();
    frame_parser_init(&s_parser);
    protocol_init(&s_stats);
    /* 引擎初始化会清两块画布、渲染并提交第一屏，所以上电即有菜单。
     * 它排在 isr_init() 之前：这期间要写几千次 AXI，中断还没开就不会有
     * 字节挤在接收环里等 —— 虽然不会丢，但没必要留这个尾巴。*/
    osd_engine_boot();

    /* 启动横幅。这几行主要是给现场确认"固件确实跑起来了"用的。
     * 把协议出处一并打出来：这条串口线上跑着好几个功能模块的帧，出问题时
     * 第一件要确认的就是"两端说的是不是同一代协议"。*/
    app_log("*** ivlabSoftCore ***");
    app_log("debug channel: semihosting (JTAG)");
    app_log("protocol: BB frame, categories 0x00 (mask) + 0x04 (UI)");
    app_log("osd: menu on OSD1 544x208 1bpp, canvas A/B = 0x%x / 0x%x",
            (uint32_t)OSD_BLOCK0_ADDR, (uint32_t)OSD_BLOCK1_ADDR);

    /* 协议端点可用与否，取决于 SoC 是否生成了 uart1（见 proto_uart.h）。
     * 这里把结果明确打出来：一是让现场知道协议能不能用，二是它的 base 地址
     * 可以和 RTL 侧的 rtl_mask_mode 取值交叉核对，确认"只有一个端点在应答"。*/
    if (PROTO_ENDPOINT_AVAILABLE) {
        proto_uart_init();
        isr_init();
        app_log("protocol endpoint: ENABLED on uart1 (base 0x%x)",
                (uint32_t)PROTO_UART_BASE);
    } else {
        app_log("protocol endpoint: UNAVAILABLE (SoC exposes no uart1)");
    }

    /* 主循环：先服务协议，再考虑输出日志。顺序不能颠倒，理由见下面第二段。*/
    while (1) {
        uint8_t byte;

        /* 第一段：把接收环里现有的字节全部取出来处理掉。
         * 内层 while 用 proto_uart_rx_pop 的返回值当条件：取到就继续，
         * 环空了自然退出。这样"排空"这件事不需要额外的计数变量。
         *
         * 每取到一个字节就记下时刻——"线路是否静默"就是靠它判断的。*/
        while (proto_uart_rx_pop(&byte)) {
            frame_t frame;

            s_last_rx_ticks = clint_getTime(BSP_CLINT);

            /* 每喂一个字节，解析器可能吐出 0 或 1 个完整帧。
             * 只有返回 1 时才需要处理。*/
            if (frame_parser_feed(&s_parser, byte, &frame) != 0) {
                handle_frame(&frame);
            }
        }

        /* 第二段：只有在**串口线路持续静默**之后才输出日志。
         *
         * 这是本文件里最容易被改坏的一处，务必看懂再动：
         *
         * semihosting 的 ebreak 会让 hart 停住在调试模块里，**期间任何中断都不被
         * 响应**。uart1 的接收 FIFO 只有 128 字节（115200 下约 11 ms 的量），
         * 停住超过这个时间，硬件就自己丢字节——而这件事接收环的计数看不见
         * （中断根本没跑），所以现象会是"帧莫名其妙少了"，极难定位。
         *
         * 实测数据：日志每轮 26 行时，工具发 26 个包只回来 10 个应答；压到
         * 每类只报一次（约 5 行）后回来 22 个；残余的几行里还有落在分块流中间
         * 的汇总行。结论是**只要在数据还在来的时候输出，就一定会丢**。
         *
         * 所以门槛设在"静默 200 ms"：上位机工具在包与包之间只静默约 50 ms，
         * 因此一次上传期间这个条件根本不会成立，日志会一直待在环里，等整批
         * 结束后一次性发出，上传期间一次停顿都没有。
         *
         * 这样做的代价是日志不再"实时"——但换来的是协议本身可靠，而且那批
         * 日志会在结束后的 200 ms 内完整出现，排查并不受影响。
         *
         * 另外注意：**画布渲染不在这个循环里**，它随命令在 osd_engine_handle()
         * 里同步完成。所以"线路静默"这条门槛只推迟日志、不推迟画面。*/
        if ((app_log_pending() != 0U) || (s_frames_processed != s_reported_frames)) {
            /* 读 CLINT 时间是 3 次 MMIO，不能每轮都做；用计数器粗降频。*/
            s_idle_spins++;
            if ((s_idle_spins & (IDLE_TICKS_DIVIDER - 1U)) == 0U) {
                if ((clint_getTime(BSP_CLINT) - s_last_rx_ticks) >= APP_LOG_IDLE_TICKS) {
                    /* 线路静默够久，说明这一批数据结束了。先补一条汇总，
                     * 保证"这一批收了多少、丢了多少"一定可见——短跑批够不到
                     * STATS_INTERVAL，没有这一条就什么都看不到。*/
                    if (s_frames_processed != s_reported_frames) {
                        log_stats();
                    }
                    (void)app_log_flush();
                }
            }
        }
    }
}
