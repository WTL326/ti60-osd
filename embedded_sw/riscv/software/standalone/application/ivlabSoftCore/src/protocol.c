/******************************************************************************
*
* @file protocol.c: 0xBB 协议的"策略层"
*
* @note 分层与判断顺序的设计理由见 protocol.h。
*
******************************************************************************/
#include "protocol.h"
#include "crc16.h"

/* 长度字段的"通配"标记：表示这条命令的长度不固定，改用下面的 min_length 判断。
 *
 * 为什么需要它：掩膜分块（子项 0x02）的 payload 是位图原始字节，长度取决于
 * 这一次要传多少，协议只要求"至少 4 字节偏移 + 若干数据"，没有固定值。
 * 用 0xFFFF 而不是 0 之类的值，是因为 0 可能是一个合法的长度，用它当标记会歧义。*/
#define LEN_ANY 0xFFFFU

/* 子项处理函数的类型。
 * 参数是要处理的帧，返回值是应答状态（PROTOCOL_STATUS_OK / _FAIL）。
 * 单独 typedef 出来，是为了让下面的表看起来清爽，也方便将来统一换签名。*/
typedef uint8_t (*protocol_handler_t)(const frame_t *frame);

/******************************************************************************
* @brief 所有子项共用、暂时什么都不做的处理函数。
*
* @param frame 要处理的帧。本函数用不到它，所以显式标注 (void)frame。
*
* @return 恒为 PROTOCOL_STATUS_FAIL。
*
* @note 关于 `(void)frame;` 这一句：C 语言没有"未使用参数"的语法，函数签名里
*       必须写出参数名。如果写了却不用，编译器（开 -Wextra 时）会警告。把参数
*       强制转换成 void 是告诉编译器"我知道有这个参数，是故意不用的"。
*       本工程的测试是开 -Wall -Wextra 编译的。
*
* @note 本函数**故意返回失败**。要实现某个子项时，做法是在下面的分派表里把
*       那一行的 handler 换成真正的实现函数——帧格式、CRC、应答这些通路
*       一行都不用改。这就是"用表分派"而不是"用 switch 分派"的收益。
******************************************************************************/
static uint8_t handler_not_implemented(const frame_t *frame)
{
    (void)frame;
    return PROTOCOL_STATUS_FAIL;
}

/******************************************************************************
* 掩膜子项分派表里的一行。
*
* 关于 const char *name：指向的是一串只读的常量字符串。用指针而不是把名字
* 存成数组，是为了让表本身保持小尺寸——每个名字在 Flash 里只存一份，表里只放
* 一个地址。这些字符串只用于调试输出，不参与任何协议逻辑。
******************************************************************************/
typedef struct {
    uint8_t             command;      /* 子项号 */
    uint16_t            body_length;  /* 精确长度，或 LEN_ANY 表示长度不固定 */
    uint16_t            min_length;   /* body_length 为 LEN_ANY 时的最小长度 */
    const char         *name;         /* 子项名，仅用于日志 */
    protocol_handler_t  handler;      /* 处理函数 */
} protocol_entry_t;

/******************************************************************************
* 掩膜子项分派表（大类 0x00）。
*
* 长度取值来自 docs/测试说明.md 的「掩膜子项」表，并且与
* tools/send_mask_via_adb.py 里 packet() 的构造方式一一对得上：
*     0x01 开始上传 -> 3 + 2+2+4 = 11
*     0x02 分块写入 -> 3 + 4 + n，n 至少 1，所以 > 7
*     0x03 设置位置 -> 3 + 2+2   = 7
*     0x04 开关     -> 3 + 1     = 4
*     0x05 保存Flash-> 3         = 3
*
* 为什么用表而不是 switch：长度校验从此成了"数据"而不是"代码"。将来加子项
* 只需加一行，不会出现"加了 case 却忘了加长度判断"这类遗漏；而且长度不符
* 这条要求能被表结构本身覆盖（见 entry_length_ok），不必在每个 case 里重复写。
*
* 关于 0x05（保存到 Flash）：本表收录它、并按协议校验长度，但 handler 仍是
* "未实现"。原因是 Flash 持久化需要独立的驱动支持，不在本次范围内；把它留在
* 表里是为了让帧被识别为"本协议的合法命令但尚未实现"，而不是被当成未知命令。
*
* static 在这里有两层意思：函数内可见 + 存放在只读段。因为内容全部是常量，
* 编译器会把它放进 Flash/ROM，不占 RAM。
******************************************************************************/
static const protocol_entry_t s_table[] = {
    { FRAME_CMD_BEGIN,    11U,     0U, "begin",    handler_not_implemented },
    { FRAME_CMD_CHUNK,    LEN_ANY, 8U, "chunk",    handler_not_implemented },
    { FRAME_CMD_POSITION, 7U,      0U, "position", handler_not_implemented },
    { FRAME_CMD_ENABLE,   4U,      0U, "enable",   handler_not_implemented },
    { FRAME_CMD_PERSIST,  3U,      0U, "persist",  handler_not_implemented }
};

/* 表里有多少行。用 sizeof(整个数组)/sizeof(一行) 算出来，而不是写死数字。
 * 这样往表里加一行，这个数字自动跟着变，不会出现"表改了、循环次数没改"
 * 导致最后一行永远不被检查的低级错误。*/
#define TABLE_ENTRIES (sizeof(s_table) / sizeof(s_table[0]))

/******************************************************************************
* @brief 按子项号在表里查找。
*
* @param command 子项号。
* @return 指向表项的指针；找不到时返回 0（空指针）。
*
* @note 返回值用"指针或空指针"表达"找到/没找到"，而不是返回一个下标加一个
*       是否有效的标志位。调用者只要判断指针是否为空即可，少一个变量。
*       这是 C 里表达"可能不存在"的惯用手法。
*
* @note 线性查找而不是二分或哈希：表只有 5 行，几次比较的开销可以忽略，
*       而线性代码最简单、最不容易写错。
******************************************************************************/
static const protocol_entry_t *table_lookup(uint8_t command)
{
    uint32_t i;

    for (i = 0U; i < TABLE_ENTRIES; i++) {
        if (s_table[i].command == command) {
            return &s_table[i];
        }
    }
    return 0;
}

/******************************************************************************
* @brief 检查帧长度是否与该子项相符。
*
* @param entry       表项。
* @param body_length 帧里声明的 body 长度。
* @return 1 表示相符。
******************************************************************************/
static int entry_length_ok(const protocol_entry_t *entry, uint16_t body_length)
{
    if (entry->body_length == LEN_ANY) {
        return (body_length >= entry->min_length) ? 1 : 0;
    }
    return (body_length == entry->body_length) ? 1 : 0;
}

/******************************************************************************
* @brief 清零收包计数。
*
* @param stats 统计结构，允许为空。
******************************************************************************/
void protocol_init(protocol_stats_t *stats)
{
    if (stats == 0) {
        return;
    }
    stats->accepted_count = 0U;
    stats->bad_packet_count = 0U;
    stats->other_category_count = 0U;
}

/******************************************************************************
* @brief 构造 10 字节应答。
*
* @param ack      至少 10 字节的输出缓冲。
* @param category 大类，从命令帧回显。
* @param command  子项，从命令帧回显。
* @param status   状态字节。
*
* @note 顺序上先算 CRC、再逐字段填。CRC 的四次累加顺序（大类 → 子项 → 类型 →
*       状态）必须与协议一致，否则上位机算出的 CRC 会对不上。
*       文档里的说法是"只对 dalei | zixiang | type | payload 计算"，对应到应答
*       就是这 4 个字节。
*
* @note 第 7、8 字节取 CRC 的高/低字节，用移位和掩码手工拆开——协议规定大端，
*       不能直接把 16 位值写进两个字节。
******************************************************************************/
void protocol_build_ack(uint8_t *ack, uint8_t category, uint8_t command,
                        uint8_t status)
{
    uint16_t crc = 0U;

    if (ack == 0) {
        return;
    }

    crc = crc16_ccitt_update(crc, category);
    crc = crc16_ccitt_update(crc, command);
    crc = crc16_ccitt_update(crc, PROTOCOL_ACK_TYPE);
    crc = crc16_ccitt_update(crc, status);

    ack[0] = FRAME_HEADER;              /* 帧头 0xBB */
    ack[1] = 0x00U;                     /* body_length 高字节 */
    ack[2] = 0x04U;                     /* body_length 低字节，应答体固定 4 字节 */
    ack[3] = category;                  /* 应答体第 0 字节：回显大类 */
    ack[4] = command;                   /* 应答体第 1 字节：回显子项 */
    ack[5] = PROTOCOL_ACK_TYPE;         /* 应答体第 2 字节：0x02 表示应答 */
    ack[6] = status;                    /* 应答体第 3 字节 */
    ack[7] = (uint8_t)(crc >> 8);       /* CRC 高字节 */
    ack[8] = (uint8_t)(crc & 0xFFU);    /* CRC 低字节 */
    ack[9] = FRAME_FOOTER;              /* 帧尾 0xAA */
}

/******************************************************************************
* @brief 判断一帧该不该由本端点处理、该回什么，并更新统计。
*
* @param stats    统计结构，会被更新。
* @param frame    解析结果。
* @param response 输出结构，会被完整填写。
*
* @note 判断顺序见 protocol.h 的详细说明。这里只强调两条最容易写错的：
*         - 完整性不过 → 不应答。字节都不可信，无从判断归属，贸然回应可能
*           撞进别的模块的通信；
*         - 大类不是掩膜 → 不应答、只计数。这是"按协议实现、不强行校验大类"
*           的落点：变倍/热点/UI 的帧是合法帧，只是不归本端点管。
******************************************************************************/
void protocol_handle(protocol_stats_t *stats, const frame_t *frame,
                     protocol_response_t *response)
{
    const protocol_entry_t *entry;

    if ((stats == 0) || (frame == 0) || (response == 0)) {
        return;
    }

    /* 先给出默认结论：不发应答、失败、子项名未知。
     * 先把"最保守的默认值"铺好，后面每个分支只需要覆盖它要改的字段，
     * 这样就不会出现"某个分支漏填了某字段、结果带着上一次的残留值发出去"。*/
    response->send_ack = 0;
    response->status = PROTOCOL_STATUS_FAIL;
    response->reason = PROTO_REASON_BAD_INTEGRITY;
    response->command_name = "?";

    /* 第 1 关：完整性。CRC 或帧尾任一不对，就认为帧被破坏了。
     * 不应答——理由见函数头。*/
    if ((frame->crc_ok == 0U) || (frame->footer_ok == 0U)) {
        response->reason = PROTO_REASON_BAD_INTEGRITY;
        response->command_name = "?";
        stats->bad_packet_count++;
        return;
    }

    /* 第 2 关：大类。不是掩膜就说明这一帧属于别的功能模块（电子变倍 0x01、
     * 热点 0x02、伪彩色 0x03、UI 0x04），本端点既不该执行也不该应答。
     * 只记一笔"收到过其它大类的帧"，便于诊断链路上都有谁在说话。*/
    if (frame->category != FRAME_CATEGORY_MASK) {
        response->reason = PROTO_REASON_OTHER_CATEGORY;
        stats->other_category_count++;
        return;
    }

    /* 从这一步起，帧确定是本端点（掩膜）的了：**每一个都会得到应答**。*/
    response->send_ack = 1;

    /* 第 3 关：类型字段必须是"上位机写"。*/
    if (frame->format_ok == 0U) {
        response->reason = PROTO_REASON_BAD_FORMAT;
        stats->bad_packet_count++;
    } else {
        /* 第 4 关：子项是否在表里。*/
        entry = table_lookup(frame->command);
        if (entry == 0) {
            response->reason = PROTO_REASON_UNKNOWN_COMMAND;
            stats->bad_packet_count++;
        } else {
            /* 找到了，顺手把子项名记下来，后面日志会用到。这一步放在长度检查
             * 之前，是为了让"长度不符"的日志里也能带上子项名——排查时知道
             * 是哪个子项长度错了，比只知道编号更直观。*/
            response->command_name = entry->name;

            /* 第 5 关：长度是否与该子项相符。*/
            if (entry_length_ok(entry, frame->body_length) == 0) {
                response->reason = PROTO_REASON_BAD_LENGTH;
                stats->bad_packet_count++;
            } else {
                /* 五关全过，帧本身完全没问题，计入"接受"。
                 * 然后调用处理函数——本次变更里它一定返回失败。*/
                stats->accepted_count++;
                response->status = entry->handler(frame);

                /* 把"处理函数的返回值"翻译成"日志用的原因"：
                 * 成功就是 OK；失败则是因为这个子项还没实现。*/
                response->reason = (response->status == PROTOCOL_STATUS_OK)
                                       ? PROTO_REASON_OK
                                       : PROTO_REASON_NOT_IMPLEMENTED;
            }
        }
    }

    /* 构造应答。只有走到这里（大类是掩膜、完整性通过）才需要发。
     * 大类和子项原样回显，这样上位机能按自己发过的命令去核对。*/
    protocol_build_ack(response->ack, frame->category, frame->command,
                       response->status);
}
