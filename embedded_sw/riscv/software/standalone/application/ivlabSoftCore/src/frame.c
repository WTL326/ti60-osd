/******************************************************************************
*
* @file frame.c: FPGA 命令帧状态机（0xBB 协议）
*
* @note 帧格式与设计理由见 frame.h。这里的状态推进顺序与 RTL 解析器一致：
*       帧头 → 长度高字节 → 长度低字节 → body → CRC 高字节 → CRC 低字节 → 帧尾。
*
******************************************************************************/
#include "frame.h"
#include "crc16.h"

/* 状态机的各个状态。
 *
 * 为什么用 enum 而不是 #define：enum 会把这一组常量归为一类，调试器里能看到
 * 名字而不是数字，编译器也能做类型检查。名字以 ST_ 开头，是为了和 frame.h 里
 * 对外的 FRAME_* 区分开——对外的宏是协议规定的一部分，这里的只是实现细节。*/
enum {
    ST_HEADER = 0,   /* 等帧头 0xBB，帧间的任意噪声都在这一步被丢掉 */
    ST_LEN_H,        /* 收 body_length 的高字节 */
    ST_LEN_L,        /* 收 body_length 的低字节，并检查范围 */
    ST_BODY,         /* 收 body，边收边算 CRC */
    ST_CRC_H,        /* 收 CRC 的高字节 */
    ST_CRC_L,        /* 收 CRC 的低字节 */
    ST_FOOTER        /* 收帧尾 0xAA，并产出解析结果 */
};

/******************************************************************************
* @brief 把解析器复位到"等帧头"状态。
*
* @param parser 要复位的解析器，允许为空。
*
* @note 这里逐个字段赋值，而不是用 memset(parser, 0, sizeof(*parser))。
*       两种效果一样，但逐个赋值有几个好处：
*         1) 不依赖 string.h，少一个库依赖（本模块要保持"零依赖"）；
*         2) 将来若给结构体加字段，忘记初始化会立刻看得出来；
*         3) 编译器只生成实际需要的几条指令，比一次 memset 调用更紧凑。
******************************************************************************/
void frame_parser_init(frame_parser_t *parser)
{
    if (parser == 0) {
        return;
    }
    parser->state = ST_HEADER;
    parser->body_length = 0U;
    parser->body_index = 0U;
    parser->body_crc = 0U;
    parser->recv_crc = 0U;
    parser->category = 0U;
    parser->command = 0U;
    parser->type = 0U;
    parser->bad_length_count = 0U;
}

/******************************************************************************
* @brief 在"等帧头"状态下处理一个字节。
*
* @param parser 解析器状态。
* @param byte   本次收到的字节。
* @return 恒为 0——等帧头这一步永远不会产出一个完整的帧。
*
* @note 为什么单独抽成一个 static 函数：把"找到帧头之后要清哪些字段"集中在
*       一处。帧头既是"新帧的开始"，也是"上一帧的收尾"，两个语义叠在一起时
*       最容易漏清字段——比如忘了清 body_crc，就会把上一帧的 CRC 带进新帧。
*
* @note static 是 C 的"文件内可见"修饰：这个函数只在本文件里能调用。
*       好处是链接器不会为它生成对外符号，也不怕和别的文件里的同名函数冲突。
*       本文件里所有辅助函数都用 static。
******************************************************************************/
static int start_frame(frame_parser_t *parser, uint8_t byte)
{
    if (byte != FRAME_HEADER) {
        return 0;   /* 不是帧头，当噪声丢掉，继续等 */
    }
    parser->state = ST_LEN_H;
    parser->body_length = 0U;
    parser->body_index = 0U;
    parser->body_crc = 0U;
    parser->recv_crc = 0U;
    parser->category = 0U;
    parser->command = 0U;
    parser->type = 0U;
    return 0;
}

/******************************************************************************
* @brief 送入一个字节，推动状态机前进一步。
*
* @param parser 解析器状态，允许为空。
* @param byte   刚收到的字节。
* @param out    返回 1 时填入解析结果，允许为空。
* @return 1 表示一个帧到达了帧尾；0 表示还在收。
*
* @note 最外层用 switch 分派到各个状态，每个状态只处理"当前这一字节"，然后
*       要么留在原状态、要么切到下一个状态。这是写状态机的标准做法：任何时刻
*       都只有一个状态在执行，不会有交错的逻辑。
*
* @note 每个 case 都以 return 结束。这样写有两个好处：一是不会出现"忘了写
*       break 导致穿透到下一个 case"这个 C 语言的经典坑；二是每个状态的
*       处理路径互不影响，读代码时不用往回看。
******************************************************************************/
int frame_parser_feed(frame_parser_t *parser, uint8_t byte, frame_t *out)
{
    if ((parser == 0) || (out == 0)) {
        return 0;
    }

    switch (parser->state) {
    /* --- 等帧头：帧与帧之间的所有噪声都在这里被自然丢弃 --- */
    case ST_HEADER:
        return start_frame(parser, byte);

    /* --- 长度高字节：先暂存到 body_length 的高 8 位 --- */
    case ST_LEN_H:
        /* (uint16_t)byte << 8 把这一字节挪到高字节，低字节此时还是 0。
         * 用 = 而不是 |= 是刻意的：这里直接覆盖，避免上一帧的残留值混进来。*/
        parser->body_length = (uint16_t)byte << 8;
        parser->state = ST_LEN_L;
        return 0;

    /* --- 长度低字节：凑成完整长度，并立刻检查是否合法 --- */
    case ST_LEN_L:
        /* |= 把低字节补上，此时 body_length 才是完整的 16 位长度。*/
        parser->body_length |= (uint16_t)byte;

        if ((parser->body_length < FRAME_BODY_LEN_MIN) ||
            (parser->body_length >= FRAME_BODY_LEN_MAX)) {
            /* 长度不合法：直接回到等帧头，**不读 body**。
             *
             * 这个"提前拒绝"很重要：如果长度字段被噪声写成了 60000，而我们
             * 还是傻等 60000 个字节，接下来几秒钟的串口数据都会被当成这一帧
             * 的内容吞掉，期间真正的命令全部丢失。提前拒绝能把误码的影响
             * 限制在一个帧内。
             *
             * 另外注意：这种帧到不了帧尾，所以**不会产生应答**。这与"每个
             * 属于本端点、且完整到达帧尾的帧都应答一次"并不矛盾——它压根
             * 没成为一个帧。*/
            parser->bad_length_count++;
            parser->state = ST_HEADER;
            return 0;
        }
        parser->body_index = 0U;
        parser->state = ST_BODY;
        return 0;

    /* --- body：边收边算 CRC，同时把前 3 个字节记下来 --- */
    case ST_BODY:
        parser->body_crc = crc16_ccitt_update(parser->body_crc, byte);

        /* 前 3 个字节是固定的头结构，第 3 个 if 之后的都是 payload。
         * 注意这里**只记录、不校验**：大类是路由字段，合法性由上层判断
         * （见 frame.h 里"大类是路由字段，不是格式标记"的说明）。
         * 只有"类型"这一位在帧尾阶段会做校验。*/
        if (parser->body_index == 0U) {
            parser->category = byte;
        } else if (parser->body_index == 1U) {
            parser->command = byte;
        } else if (parser->body_index == 2U) {
            parser->type = byte;
        }
        /* 从第 3 字节（payload）起，这里**什么都不做**，只把它折进上面那句
         * CRC 计算里。这就是"整帧不缓存"的体现：payload 算完即丢，所以
         * 掩膜分块的几千字节数据不会占用任何 RAM。
         *
         * 本次变更是"只做协议框架"，没有任何命令需要读 payload；将来若要
         * 实现分块写入（子项 0x02），再针对那一条命令单独缓存即可。*/

        /* 收到第 body_length 个字节时，body 结束，转去收 CRC。
         * body_index 从 0 计，所以最后一个字节的下标是 body_length-1。
         * 这里的减法已经安全：长度在 ST_LEN_L 阶段校验过 >= 3。*/
        if (parser->body_index == (uint16_t)(parser->body_length - 1U)) {
            parser->state = ST_CRC_H;
        } else {
            parser->body_index++;
        }
        return 0;

    /* --- CRC 高字节 --- */
    case ST_CRC_H:
        parser->recv_crc = (uint16_t)byte << 8;
        parser->state = ST_CRC_L;
        return 0;

    /* --- CRC 低字节：凑成完整 CRC，转去收帧尾 --- */
    case ST_CRC_L:
        parser->recv_crc |= (uint16_t)byte;
        parser->state = ST_FOOTER;
        return 0;

    /* --- 帧尾：把这一帧的结论一次性填进 out --- */
    case ST_FOOTER:
    default:
        /* default 和 ST_FOOTER 走同一段代码，是防御性写法：万一 state 被
         * 内存踩坏成了非法值，也只会当成"帧尾"处理并立即复位回 ST_HEADER，
         * 不会卡死在非法状态里。*/

        out->category    = parser->category;
        out->command     = parser->command;
        out->type        = parser->type;
        out->body_length = parser->body_length;

        /* 三个布尔标志都写成 `? 1U : 0U` 而不是直接赋值比较表达式的结果。
         * 因为 C 里比较运算符的结果是 int 类型的 1/0，直接赋给 uint8_t 字段
         * 虽然没问题，但显式写出来能保证字段里只可能是 0 或 1。*/
        out->crc_ok      = (parser->recv_crc == parser->body_crc) ? 1U : 0U;
        out->footer_ok   = (byte == FRAME_FOOTER) ? 1U : 0U;
        /* 格式校验只有这一条：命令帧的类型必须是"上位机写"。
         * 大类**不在这里校验**——它是路由字段，变倍/热点/UI 的大类都是合法的，
         * 只是不该由本应用处理（在上层分流）。*/
        out->format_ok   = (parser->type == FRAME_TYPE_WRITE) ? 1U : 0U;

        /* 无论这一帧是好是坏，解析器都回到等帧头，准备接下一帧。
         * 这样"坏帧"不会让解析器停摆——上位机可以继续发下一条命令。*/
        parser->state = ST_HEADER;
        return 1;
    }
}
