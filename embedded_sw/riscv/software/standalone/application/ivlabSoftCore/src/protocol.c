/******************************************************************************
*
* @file protocol.c: 0xBB 协议的"策略层"
*
* @note 分层与判断顺序的设计理由见 protocol.h。
*
* @note 2026-09 新增 0x04（UI）大类。结构上的做法是**把"哪张大类"变成数据**：
*       两张子项表 + 一张"大类 → 表"的描述表，判断流程一行都不复制。这样
*       再来一个归本端点管的大类，只需要加一张表、加一行描述。
*
* @note 依赖上的一点说明：本模块原本只 include frame.h 与 crc16.h。现在还要
*       include ui.h（UI 命令的落点）与 osd_config.h（flags 位定义与应答体长度）。
*       这不违反"策略层不碰硬件"—— ui.c 只改状态、不写寄存器，真正碰 MMIO 的
*       是另一些 .c。分层看的是"谁碰硬件"，不是"include 了哪个头文件"。
*
******************************************************************************/
#include "protocol.h"
#include "crc16.h"
#include "osd/ui.h"
#include "osd/osd_config.h"

/* 长度字段的"通配"标记：表示这条命令的长度不固定，改用下面的 min_length 判断。
 *
 * 为什么需要它：掩膜分块（子项 0x02）的 payload 是位图原始字节，长度取决于
 * 这一次要传多少，协议只要求"至少 4 字节偏移 + 若干数据"，没有固定值。
 * 用 0xFFFF 而不是 0 之类的值，是因为 0 可能是一个合法的长度，用它当标记会歧义。*/
#define LEN_ANY 0xFFFFU

/* 子项处理函数的类型。
 *   frame   要处理的帧（命令参数从 frame->payload 取，长度 frame->payload_len）
 *   out     输出：应答体里跟在状态字节之后的参数段
 *   out_len 输出：参数段的字节数（0 表示这就是个 10 字节的定长应答）
 *   返回    应答状态字节（PROTOCOL_STATUS_OK / _FAIL）
 * 单独 typedef 出来，是为了让下面的表看起来清爽，也方便将来统一换签名。*/
typedef uint8_t (*protocol_handler_t)(const frame_t *frame, uint8_t *out,
                                      uint16_t *out_len);

/******************************************************************************
* 某张大类的子项分派表里的一行。
*
* 关于 const char *name：指向的是一串只读的常量字符串。用指针而不是把名字
* 存成数组，是为了让表本身保持小尺寸——每个名字在 Flash 里只存一份，表里只放
* 一个地址。这些字符串只用于调试输出，不参与任何协议逻辑。
******************************************************************************/
typedef struct {
    uint8_t             command;      /* 子项号 */
    uint16_t            body_length;  /* 精确长度，或 LEN_ANY 表示长度不固定 */
    uint16_t            min_length;   /* body_length 为 LEN_ANY 时的最小长度 */
    uint8_t             reply;        /* 0 = 只解析，不应答、不计入坏包 */
    uint8_t             defer;        /* 1 = 成功后要等画布提交完成再回应答 */
    const char         *name;         /* 子项名，仅用于日志 */
    protocol_handler_t  handler;      /* 处理函数 */
} protocol_entry_t;

/******************************************************************************
* 大类描述表里的一行：一个归本端点管的大类，以及它的子项表。
******************************************************************************/
typedef struct {
    uint8_t                 category;   /* 大类号 */
    const protocol_entry_t *entries;    /* 子项表 */
    uint32_t                count;      /* 子项表的行数 */
} protocol_category_t;

/* ===========================================================================
 * 掩膜大类（0x00）的处理函数
 * =========================================================================== */

/******************************************************************************
* @brief 所有掩膜子项共用、暂时什么都不做的处理函数。
*
* @param frame   要处理的帧。本函数用不到它，所以显式标注 (void)frame。
* @param out     参数段输出，不用。
* @param out_len 参数段长度输出，置 0（应答就是定长 10 字节）。
* @return 恒为 PROTOCOL_STATUS_FAIL。
*
* @note 关于 `(void)frame;` 这一类语句：C 语言没有"未使用参数"的语法，函数签名里
*       必须写出参数名。如果写了却不用，编译器（开 -Wextra 时）会警告。把参数
*       强制转换成 void 是告诉编译器"我知道有这个参数，是故意不用的"。
*       本工程的测试是开 -Wall -Wextra 编译的。
*
* @note 本函数**故意返回失败**。要实现某个子项时，做法是在下面的分派表里把
*       那一行的 handler 换成真正的实现函数——帧格式、CRC、应答这些通路
*       一行都不用改。这就是"用表分派"而不是"用 switch 分派"的收益。
******************************************************************************/
static uint8_t handler_not_implemented(const frame_t *frame, uint8_t *out,
                                       uint16_t *out_len)
{
    (void)frame;
    (void)out;
    *out_len = 0U;
    return PROTOCOL_STATUS_FAIL;
}

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
static const protocol_entry_t s_mask_table[] = {
    { FRAME_CMD_BEGIN,    11U,     0U, 1U, 0U, "begin",    handler_not_implemented },
    { FRAME_CMD_CHUNK,    LEN_ANY, 8U, 1U, 0U, "chunk",    handler_not_implemented },
    { FRAME_CMD_POSITION, 7U,      0U, 1U, 0U, "position", handler_not_implemented },
    { FRAME_CMD_ENABLE,   4U,      0U, 1U, 0U, "enable",   handler_not_implemented },
    { FRAME_CMD_PERSIST,  3U,      0U, 1U, 0U, "persist",  handler_not_implemented }
};

/* ===========================================================================
 * UI 大类（0x04）的处理函数
 * =========================================================================== */

/******************************************************************************
* @brief 处理 SET_VIEW（子项 0x06）：切页面、选行、改 flags。
*
* @param frame 要处理的帧。payload = `page_id:u16BE | sel:u8 | flags:u8`。
* @return 成功 PROTOCOL_STATUS_OK，失败 PROTOCOL_STATUS_FAIL。
*
* @note 长度由表结构保证是 4，所以这里可以放心地按下标取。这一条很关键：
*       "长度对不对"是表的职责，"怎么用这几个字节"才是 handler 的职责，
*       两者不重复判断，也不会出现"表里写了 4、handler 里却按 8 取"这种错位。
******************************************************************************/
static uint8_t handler_ui_set_view(const frame_t *frame, uint8_t *out,
                                   uint16_t *out_len)
{
    uint16_t page_id;
    uint8_t  sel, flags;

    (void)out;
    *out_len = 0U;                    /* SET_VIEW 的应答是定长 10 字节 */

    page_id = (uint16_t)(((uint16_t)frame->payload[0] << 8) |
                          (uint16_t)frame->payload[1]);
    sel     = frame->payload[2];
    flags   = frame->payload[3];

    return (ui_set_view(page_id, sel, flags) == 0) ? PROTOCOL_STATUS_OK
                                                   : PROTOCOL_STATUS_FAIL;
}

/******************************************************************************
* @brief 处理 SET_IMAGE_VALUES（子项 0x07）：四个数值一次提交。
*
* @param frame 要处理的帧。payload = 四个 u8。
* @return 成功 PROTOCOL_STATUS_OK，失败 PROTOCOL_STATUS_FAIL。
*
* @note 范围校验在 ui_set_image_values() 里做，不在这里 —— 那里才知道"哪些值
*       算合法"（依赖 UI 规格），协议层只该管"这一帧是不是这条命令"。
******************************************************************************/
static uint8_t handler_ui_set_image_values(const frame_t *frame, uint8_t *out,
                                           uint16_t *out_len)
{
    (void)out;
    *out_len = 0U;
    return (ui_set_image_values(frame->payload) == 0) ? PROTOCOL_STATUS_OK
                                                      : PROTOCOL_STATUS_FAIL;
}

/******************************************************************************
* @brief 处理 SET_ITEM_VALUE（子项 0x09）：设置任意页任意条目的运行期值。
*
* @param frame 要处理的帧。payload = `page_id:u16BE | item_idx:u8 | value…`。
* @return 成功 PROTOCOL_STATUS_OK，失败 PROTOCOL_STATUS_FAIL。
*
* @note value 的长度与含义由条目的 value_kind 决定（NUM/ONOFF/ENUM 取 1 字节，
*       EDIT 取文本），所以这里**只负责切出 value 这一段、不做语义校验**——
*       越界与否只有 UI 层知道。与 handler_ui_set_image_values 是同一个分工：
*       协议层管"这一帧是不是这条命令"，UI 层管"这几个字节算不算合法值"。
*
* @note payload_len 是**帧里声明**的长度，payload[] 里实际只留了前
*       FRAME_PAYLOAD_MAX 个（见 frame.h）——两者是独立的数。所以这里按
*       min(payload_len, FRAME_PAYLOAD_MAX) 取可用长度，超出的部分从来没被
*       抄进窗口，不会读越界；被调用方据此决定是截断还是拒绝。
******************************************************************************/
static uint8_t handler_ui_set_item_value(const frame_t *frame, uint8_t *out,
                                         uint16_t *out_len)
{
    uint16_t page_id;
    uint8_t  item_idx;
    uint32_t avail, vlen;

    (void)out;
    *out_len = 0U;                    /* 定长 10 字节应答 */

    page_id  = (uint16_t)(((uint16_t)frame->payload[0] << 8) |
                          (uint16_t)frame->payload[1]);
    item_idx = frame->payload[2];

    avail = (uint32_t)frame->payload_len;
    if (avail > (uint32_t)FRAME_PAYLOAD_MAX) avail = (uint32_t)FRAME_PAYLOAD_MAX;
    if (avail < 3U) return PROTOCOL_STATUS_FAIL;   /* 表已保证 >= 3，防御 */
    vlen = avail - 3U;

    return (ui_set_item_value(page_id, item_idx, &frame->payload[3], vlen) == 0)
               ? PROTOCOL_STATUS_OK
               : PROTOCOL_STATUS_FAIL;
}

/******************************************************************************
* @brief 处理 QUERY_VIEW（子项 0x08）：把当前状态填进应答参数段。
*
* @param frame   要处理的帧（无 payload，用不到）。
* @param out     输出：8 字节参数段（page_id/sel/flags/四个数值）。
* @param out_len 输出：8。
* @return 恒为 PROTOCOL_STATUS_OK。
*
* @note 这是本协议里**唯一**一个应答长度不是 10 字节的命令（整帧 18）。
*       参数段的 8 字节由 ui_query_view() 填，协议层负责在前面补
*       `04 08 02 FF` 并算 CRC —— 这样"应答体长什么样"只在协议层一处决定。
******************************************************************************/
static uint8_t handler_ui_query_view(const frame_t *frame, uint8_t *out,
                                     uint16_t *out_len)
{
    (void)frame;
    (void)ui_query_view(out);
    *out_len = UI_QUERY_PAYLOAD_LEN;
    return PROTOCOL_STATUS_OK;
}

/******************************************************************************
* 未纳入本端点范围的 UI 子项（0x01–0x05）共用的处理函数：什么都不做。
*
* @note 这些行在表里 reply = 0，所以**本函数根本不会被调用**（见 protocol_handle
*       的第 6 关）。留一个具名的空函数而不是填 0，是为了让表里每一行都指向
*       一个真函数 —— 填 0 的话，将来有人把 reply 误改成 1 就会跳到空指针。
******************************************************************************/
static uint8_t handler_ui_not_in_scope(const frame_t *frame, uint8_t *out,
                                       uint16_t *out_len)
{
    (void)frame;
    (void)out;
    *out_len = 0U;
    return PROTOCOL_STATUS_FAIL;
}

/******************************************************************************
* UI 子项分派表（大类 0x04）。
*
* 只有 0x06 / 0x07 / 0x08 三个子项由本端点处理；0x01–0x05 的 reply = 0，
* 按协议"只解析、不应答、不计入坏包"。
*
* 注意本表的 body_length 是**帧里长度字段的值**，也就是"3 字节 body 头 + payload"，
* 不是 payload 的长度。写这一列时踩过一次坑：SET_VIEW 的 payload 是 4 字节，
* 但这一列必须写 7 —— 写成 4 的话长度校验恒不通过，命令会被判成坏包，
* 而现象只是"命令没反应"，很容易误以为是 UI 那一侧没实现。
*
* 关于 0x01–0x05 的长度为什么写 LEN_ANY + 最小 3：
*   本端点不实现这些子项，也就**没有依据判断它们的长度对不对** —— 那五个工具的
*   payload 长度要么来自工具、要么来自协议草案，写死一个值等于把"猜的长度"变成
*   校验规则：一旦猜错，工具发来的合法帧会被判成坏包，`bad_packet_count` 会持续
*   增长、把真正的链路问题淹没。而 body_length >= 3 是解析层已经保证过的
*   （见 frame.h 的 FRAME_BODY_LEN_MIN），所以 LEN_ANY + 3 恒成立、等于不校验。
*
* 依据 docs/x2000_ui_protocol.md §3 与 tools/send_ui_via_adb.py 的子项取值。*/
static const protocol_entry_t s_ui_table[] = {
    { FRAME_CMD_UI_SHOW_HIDE,        LEN_ANY, FRAME_BODY_LEN_MIN, 0U, 0U,
      "ui-show-hide",     handler_ui_not_in_scope },
    { FRAME_CMD_UI_KEY,              LEN_ANY, FRAME_BODY_LEN_MIN, 0U, 0U,
      "ui-key",           handler_ui_not_in_scope },
    { FRAME_CMD_UI_ATTITUDE,         LEN_ANY, FRAME_BODY_LEN_MIN, 0U, 0U,
      "ui-attitude",      handler_ui_not_in_scope },
    { FRAME_CMD_UI_CLEAR,            LEN_ANY, FRAME_BODY_LEN_MIN, 0U, 0U,
      "ui-clear",         handler_ui_not_in_scope },
    { FRAME_CMD_UI_RANGE_MARK,       LEN_ANY, FRAME_BODY_LEN_MIN, 0U, 0U,
      "ui-range-mark",    handler_ui_not_in_scope },
    /* payload 4（page_id:u16BE + sel:u8 + flags:u8）→ body 7。
     * defer = 1：成功应答要等 composer_render() + canvas_commit() 之后才发
     * （协议 §5.5 的"提交后才返回成功"）。*/
    { FRAME_CMD_UI_SET_VIEW,         7U,      0U, 1U, 1U,
      "set-view",         handler_ui_set_view },
    { FRAME_CMD_UI_SET_IMAGE_VALUES, 7U,      0U, 1U, 1U,
      "set-image-values", handler_ui_set_image_values },
    /* payload 变长（page_id:u16BE + item_idx:u8 + value…）→ LEN_ANY，
     * 最小 3 字节 payload（只给 page_id 与 item_idx、value 为空，对 EDIT 即
     * "清空"），对应 body >= 6。
     * defer = 1：与 SET_VIEW 同——值改了要重画，成功应答必须排在
     * composer_render() + canvas_commit() 之后（协议 §5.5）。*/
    { FRAME_CMD_UI_SET_ITEM_VALUE,   LEN_ANY, FRAME_BODY_LEN_MIN + 3U, 1U, 1U,
      "set-item-value",   handler_ui_set_item_value },
    /* payload 0 → body 3；应答 18 字节。查询不改画面，所以不 defer。*/
    { FRAME_CMD_UI_QUERY_VIEW,       3U,      0U, 1U, 0U,
      "query-view",       handler_ui_query_view }
};

/******************************************************************************
* 大类描述表 —— 归本端点管的大类都在这里。
*
* 加一个大类只需加一行；protocol_handle 的判断流程不用动。
* 不在表里的大类（0x01 变倍 / 0x02 热点 / 0x03 伪彩色）= 不归本端点管。
******************************************************************************/
static const protocol_category_t s_categories[] = {
    { FRAME_CATEGORY_MASK, s_mask_table,
      (uint32_t)(sizeof(s_mask_table) / sizeof(s_mask_table[0])) },
    { FRAME_CATEGORY_UI,   s_ui_table,
      (uint32_t)(sizeof(s_ui_table) / sizeof(s_ui_table[0])) }
};

#define CATEGORY_ENTRIES (sizeof(s_categories) / sizeof(s_categories[0]))

/******************************************************************************
* @brief 按大类号找它的描述项。
*
* @param category 大类号。
* @return 指向描述项的指针；不归本端点管时返回 0（空指针）。
*
* @note 线性查找：只有两行，比哈希或二分都简单，且不会写错。
******************************************************************************/
static const protocol_category_t *category_lookup(uint8_t category)
{
    uint32_t i;

    for (i = 0U; i < CATEGORY_ENTRIES; i++) {
        if (s_categories[i].category == category) {
            return &s_categories[i];
        }
    }
    return 0;
}

/******************************************************************************
* @brief 按子项号在某张大类的表里查找。
*
* @param cat     大类描述项。
* @param command 子项号。
* @return 指向表项的指针；找不到时返回 0（空指针）。
*
* @note 返回值用"指针或空指针"表达"找到/没找到"，而不是返回一个下标加一个
*       是否有效的标志位。调用者只要判断指针是否为空即可，少一个变量。
*       这是 C 里表达"可能不存在"的惯用手法。
*
* @note 线性查找而不是二分或哈希：掩膜表 5 行、UI 表 8 行，几次比较的开销可以
*       忽略，而线性代码最简单、最不容易写错。
******************************************************************************/
static const protocol_entry_t *table_lookup(const protocol_category_t *cat,
                                            uint8_t command)
{
    uint32_t i;

    for (i = 0U; i < cat->count; i++) {
        if (cat->entries[i].command == command) {
            return &cat->entries[i];
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
* @brief 构造应答的公共实现（4 参数版本与带 payload 的版本都走这里）。
*
* @param ack         输出缓冲，至少 PROTOCOL_ACK_MAX 字节。
* @param category    大类，从命令帧回显。
* @param command     子项，从命令帧回显。
* @param status      状态字节。
* @param payload     应答体里跟在状态字节之后的参数段，允许为空。
* @param payload_len 参数段的字节数。
* @return 整帧字节数。
*
* @note 顺序上先算 CRC、再逐字段填。CRC 的累加顺序（大类 → 子项 → 类型 → 状态
*       → 参数段）必须与协议一致，否则上位机算出的 CRC 会对不上。
*       文档里的说法是"只对 dalei | zixiang | type | payload 计算"，对应到应答
*       就是这 4 + payload_len 个字节。
*
* @note 第 7、8 字节取 CRC 的高/低字节，用移位和掩码手工拆开——协议规定大端，
*       不能直接把 16 位值写进两个字节。
*
* @note body_length 是**算出来的**，不是写死的 4：QUERY_VIEW 的 body 是 12。
*       参数字节数越界这一条不在这里防 —— 它是编译期常量决定的（最大 8），
*       加运行时检查只会掩盖"有人把 UI_QUERY_PAYLOAD_LEN 改大了"这个真问题。
******************************************************************************/
static uint16_t build_ack_common(uint8_t *ack, uint8_t category, uint8_t command,
                                 uint8_t status, const uint8_t *payload,
                                 uint16_t payload_len)
{
    uint16_t crc = 0U;
    uint16_t body_len;
    uint16_t i;

    body_len = (uint16_t)(4U + payload_len);

    crc = crc16_ccitt_update(crc, category);
    crc = crc16_ccitt_update(crc, command);
    crc = crc16_ccitt_update(crc, PROTOCOL_ACK_TYPE);
    crc = crc16_ccitt_update(crc, status);
    for (i = 0U; i < payload_len; i++) {
        crc = crc16_ccitt_update(crc, payload[i]);
    }

    ack[0] = FRAME_HEADER;                 /* 帧头 0xBB */
    ack[1] = (uint8_t)(body_len >> 8);     /* body_length 高字节 */
    ack[2] = (uint8_t)(body_len & 0xFFU);  /* body_length 低字节 */
    ack[3] = category;                     /* 应答体第 0 字节：回显大类 */
    ack[4] = command;                      /* 应答体第 1 字节：回显子项 */
    ack[5] = PROTOCOL_ACK_TYPE;            /* 应答体第 2 字节：0x02 表示应答 */
    ack[6] = status;                       /* 应答体第 3 字节 */
    for (i = 0U; i < payload_len; i++) {
        ack[7U + i] = payload[i];
    }
    ack[7U + payload_len] = (uint8_t)(crc >> 8);      /* CRC 高字节 */
    ack[8U + payload_len] = (uint8_t)(crc & 0xFFU);   /* CRC 低字节 */
    ack[9U + payload_len] = FRAME_FOOTER;             /* 帧尾 0xAA */

    return (uint16_t)(10U + payload_len);
}

void protocol_build_ack(uint8_t *ack, uint8_t category, uint8_t command,
                        uint8_t status)
{
    if (ack == 0) {
        return;
    }
    (void)build_ack_common(ack, category, command, status, 0, 0U);
}

uint16_t protocol_build_ack_payload(uint8_t *ack, uint8_t category, uint8_t command,
                                    uint8_t status, const uint8_t *payload,
                                    uint16_t payload_len)
{
    if (ack == 0) {
        return 0U;
    }
    return build_ack_common(ack, category, command, status, payload, payload_len);
}

/******************************************************************************
* @brief 判断一帧该不该由本端点处理、该回什么，并更新统计。
*
* @param stats    统计结构，会被更新。
* @param frame    解析结果。
* @param response 输出结构，会被完整填写。
*
* @note 判断顺序见 protocol.h 的详细说明。这里只强调三条最容易写错的：
*         - 完整性不过 → 不应答。字节都不可信，无从判断归属，贸然回应可能
*           撞进别的模块的通信；
*         - 大类不归本端点 → 不应答、只计数。这是"按协议实现、不强行校验大类"
*           的落点；
*         - UI 的 0x01–0x05 → **不应答，但也不计坏包**（与上一条不同：那五个
*           子项确实是发给本端点的，只是本期不实现；计成坏包会让链路上真实
*           存在的工具帧把坏包率顶高）。
******************************************************************************/
void protocol_handle(protocol_stats_t *stats, const frame_t *frame,
                     protocol_response_t *response)
{
    const protocol_category_t *cat;
    const protocol_entry_t *entry;
    /* 应答体的参数段。8 字节是编译期常量（UI_QUERY_PAYLOAD_LEN），
     * 只有 QUERY_VIEW 会用到，其余子项 out_len 都是 0。*/
    uint8_t  out[UI_QUERY_PAYLOAD_LEN];
    uint16_t out_len = 0U;

    if ((stats == 0) || (frame == 0) || (response == 0)) {
        return;
    }

    /* 先给出默认结论：不发应答、失败、子项名未知。
     * 先把"最保守的默认值"铺好，后面每个分支只需要覆盖它要改的字段，
     * 这样就不会出现"某个分支漏填了某字段、结果带着上一次的残留值发出去"。*/
    response->send_ack = 0;
    response->defer_ack = 0;
    response->status = PROTOCOL_STATUS_FAIL;
    response->reason = PROTO_REASON_BAD_INTEGRITY;
    response->command_name = "?";
    response->ack_len = 0U;

    /* 第 1 关：完整性。CRC 或帧尾任一不对，就认为帧被破坏了。
     * 不应答——理由见函数头。*/
    if ((frame->crc_ok == 0U) || (frame->footer_ok == 0U)) {
        response->reason = PROTO_REASON_BAD_INTEGRITY;
        response->command_name = "?";
        stats->bad_packet_count++;
        return;
    }

    /* 第 2 关：大类归属。不归本端点管的大类（电子变倍 0x01、热点 0x02、
     * 伪彩色 0x03）既不该执行也不该应答，只记一笔"收到过其它大类的帧"，
     * 便于诊断链路上都有谁在说话。*/
    cat = category_lookup(frame->category);
    if (cat == 0) {
        response->reason = PROTO_REASON_OTHER_CATEGORY;
        stats->other_category_count++;
        return;
    }

    /* 从这一步起，帧确定是本端点的了：**默认每一个都会得到应答**。
     * 唯一的例外是 UI 的 0x01–0x05，它们在下面第 6 关把 send_ack 改回 0。*/
    response->send_ack = 1;

    /* 第 3 关：类型字段必须是"上位机写"。*/
    if (frame->format_ok == 0U) {
        response->reason = PROTO_REASON_BAD_FORMAT;
        stats->bad_packet_count++;
    } else {
        /* 第 4 关：子项是否在该大类的表里。*/
        entry = table_lookup(cat, frame->command);
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
            } else if (entry->reply == 0U) {
                /* 第 6 关：本端点不实现的子项（UI 的 0x01–0x05）。
                 * **只解析**：不调用 handler（也就不会改任何状态）、不应答、
                 * 不计入坏包，也不计入"被接受"。*/
                response->send_ack = 0;
                response->reason = PROTO_REASON_UI_IGNORED;
                response->command_name = entry->name;
            } else {
                /* 五关全过，帧本身完全没问题，计入"接受"。
                 * 然后调用处理函数，由它给出状态与应答参数段。*/
                stats->accepted_count++;
                response->status = entry->handler(frame, out, &out_len);

                /* 把"处理函数的返回值"翻译成"日志用的原因"。
                 * 成功且该子项要求延迟应答（SET_VIEW / SET_IMAGE_VALUES）时，
                 * 标记 defer_ack —— 由 main 循环在画布提交完成后再真正发出。*/
                if (response->status == PROTOCOL_STATUS_OK) {
                    response->reason = PROTO_REASON_OK;
                    response->defer_ack = entry->defer;
                    if (entry->defer != 0U) {
                        response->reason = PROTO_REASON_DEFERRED;
                    }
                } else {
                    response->reason = PROTO_REASON_NOT_IMPLEMENTED;
                }
            }
        }
    }

    /* 构造应答。只有"大类归本端点、完整性通过、且该子项要应答"才需要发。
     * 大类和子项原样回显，这样上位机能按自己发过的命令去核对。
     *
     * 参数段为空时走定长 10 字节那一支 —— 两条路都落到同一个 build_ack_common，
     * 所以 CRC 覆盖范围与字节序只有一处实现。*/
    if (response->send_ack != 0) {
        if (out_len == 0U) {
            protocol_build_ack(response->ack, frame->category, frame->command,
                               response->status);
            response->ack_len = PROTOCOL_ACK_LEN;
        } else {
            response->ack_len = (uint8_t)protocol_build_ack_payload(
                response->ack, frame->category, frame->command,
                response->status, out, out_len);
        }
    }
}
