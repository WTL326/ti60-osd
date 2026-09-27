/******************************************************************************
*
* @file test_protocol.c: 0xBB 协议的离机测试
*
* @brief 在 qemu 上测试 ../src 下的 crc16.c、frame.c、protocol.c。
*        这三个模块都是"与硬件无关"的纯逻辑，所以能在没有 FPGA 的情况下
*        完整验证——这正是当初把它们设计成纯逻辑的目的。
*
* @note 测试数据（帧向量）的来源，这点很重要：
*
*       一部分直接取自**本工程的权威文档** docs/adb_test_commands.md ——
*       那些十六进制串是文档里给人工测试用的原始报文，不是我生成的。
*       以它们为期望值，等于拿"系统自己认可的报文"来校准我的实现。
*
*       其余部分由一份**独立的 Python 实现**算出（照协议参数直接写：多项式
*       0x1021、初值 0x0000、不反射、无最终异或），没有运行过被测的 C 代码。
*       那份 Python 的可信度由上面那批文档金标帧反向验证过——它能把文档里的
*       掩膜报文逐字节重算出来，包括 CRC。
*
*       两者合起来，才能发现"一开始就写错了"，而不只是"以后改坏了"。
*
* @note 测试的组织方式：按被测模块分成 T1–T5，每组一个函数，内部用一串
*       h_check 断言，每条断言单独打印 PASS/FAIL，任何一条失败都能立刻定位。
*
******************************************************************************/
#include <stdint.h>

#include "harness.h"
#include "frame.h"
#include "crc16.h"
#include "protocol.h"

/* ===========================================================================
 * 辅助函数
 * =========================================================================== */

/******************************************************************************
* @brief 把一整串字节喂给解析器。
*
* @param parser 解析器。
* @param bytes  字节数组。
* @param len    字节数。
* @param out    若非空，则把**最后一个**解析出的帧复制到这里。
* @return 这一串字节里总共解析出了几个完整的帧。
*
* @note 返回值是"帧的个数"而不是"是否成功"，因为一次喂多个帧时要能分别计数
*       ——T5 就是靠这个验证"两个背靠背的帧产生两个应答"的。
******************************************************************************/
static int feed_all(frame_parser_t *parser, const uint8_t *bytes, uint32_t len,
                    frame_t *out)
{
    uint32_t i;
    int      frames = 0;

    for (i = 0U; i < len; i++) {
        frame_t f;
        if (frame_parser_feed(parser, bytes[i], &f) != 0) {
            frames++;
            if (out != 0) {
                *out = f;
            }
        }
    }
    return frames;
}

/******************************************************************************
* @brief 比较两段字节是否完全相同。
* @return 1 表示相同。
******************************************************************************/
static int bytes_equal(const uint8_t *a, const uint8_t *b, uint32_t len)
{
    uint32_t i;
    for (i = 0U; i < len; i++) {
        if (a[i] != b[i]) {
            return 0;
        }
    }
    return 1;
}

/******************************************************************************
* @brief 比较两个字符串是否相同。
* @return 1 表示相同。
*
* @note 自己写一个，是因为测试台不链接标准库（没有 strcmp）。
*       对空指针返回 0（不相同），因为"拿空指针来比较"本身就该判失败。
******************************************************************************/
static int str_equal(const char *a, const char *b)
{
    if ((a == 0) || (b == 0)) {
        return 0;
    }
    while ((*a != '\0') && (*a == *b)) {
        a++;
        b++;
    }
    return (*a == *b) ? 1 : 0;
}

/******************************************************************************
* @brief 把一段字节按十六进制打印出来，用于断言失败时观察实际值。
******************************************************************************/
static void show_bytes(const char *label, const uint8_t *b, uint32_t len)
{
    uint32_t i;
    h_puts("        ");
    h_puts(label);
    h_puts(": ");
    for (i = 0U; i < len; i++) {
        h_printf("%x ", (uint32_t)b[i]);
    }
    h_puts("\n");
}

/* ===========================================================================
 * 测试用的帧向量
 *
 * 前 6 个**逐字节抄自 docs/adb_test_commands.md**（权威文档里给人工测试用的
 * 原始报文），后 7 个由独立 Python 实现算出。注释标出各自要测什么。
 * =========================================================================== */

/* --- 以下 6 个来自 docs/adb_test_commands.md --- */

/* 掩膜开启：body = 00 04 00 01（大类 0x00，子项 0x04，类型 0x00，payload=1）*/
static const uint8_t F_MASK_ON[] = {
    0xBB, 0x00, 0x04, 0x00, 0x04, 0x00, 0x01, 0xCC, 0xE1, 0xAA
};
/* 掩膜关闭：payload=0 */
static const uint8_t F_MASK_OFF[] = {
    0xBB, 0x00, 0x04, 0x00, 0x04, 0x00, 0x00, 0xDC, 0xC0, 0xAA
};
/* 掩膜位置 (150,178)：body = 00 03 00 00 96 00 B2 */
static const uint8_t F_MASK_POS[] = {
    0xBB, 0x00, 0x07, 0x00, 0x03, 0x00, 0x00, 0x96, 0x00, 0xB2, 0x83, 0xE0, 0xAA
};
/* 电子变倍"全幅1倍"：**大类 0x01**，不是本端点该管的 */
static const uint8_t F_EZOOM[] = {
    0xBB, 0x00, 0x0B, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04,
    0xFF, 0x03, 0xFF, 0xF9, 0x3D, 0xAA
};
/* 热点追踪关闭：**大类 0x02** */
static const uint8_t F_HOT[] = {
    0xBB, 0x00, 0x04, 0x02, 0x01, 0x00, 0x00, 0xDA, 0x58, 0xAA
};
/* UI 显示：**大类 0x04** */
static const uint8_t F_UI[] = {
    0xBB, 0x00, 0x04, 0x04, 0x01, 0x00, 0x01, 0xED, 0xE0, 0xAA
};

/* --- 以下由独立 Python 实现算出 --- */

/* 掩膜开始上传 420x220 total=92400：body 长度 11 */
static const uint8_t F_BEGIN[] = {
    0xBB, 0x00, 0x0B, 0x00, 0x01, 0x00, 0x01, 0xA4, 0x00, 0xDC,
    0x00, 0x01, 0x68, 0xF0, 0xCA, 0x3A, 0xAA
};
/* 掩膜分块写入：body 长度 15（3 + 4 偏移 + 8 数据）*/
static const uint8_t F_CHUNK[] = {
    0xBB, 0x00, 0x0F, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00,
    0x11, 0x22, 0x33, 0x44, 0x55, 0x66, 0x77, 0x88, 0x9A, 0x49, 0xAA
};
/* 分块写入但长度只有 7（协议要求 > 7）：用来测"长度与子项不符" */
static const uint8_t F_CHUNK_SHORT[] = {
    0xBB, 0x00, 0x07, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x8B, 0x40, 0xAA
};
/* 掩膜保存到 Flash：body 长度 3（无 payload）*/
static const uint8_t F_PERSIST[] = {
    0xBB, 0x00, 0x03, 0x00, 0x05, 0x00, 0xFF, 0xF5, 0xAA
};
/* 未定义的掩膜子项 0x99，长度 4 */
static const uint8_t F_UNKNOWN_CMD[] = {
    0xBB, 0x00, 0x04, 0x00, 0x99, 0x00, 0x01, 0xF6, 0x89, 0xAA
};
/* 子项 0x03（应为长度 7）但声明长度 8 */
static const uint8_t F_LEN_MISMATCH[] = {
    0xBB, 0x00, 0x08, 0x00, 0x03, 0x00, 0x00, 0x96, 0x00, 0xB2, 0xFF,
    0x5F, 0x1B, 0xAA
};
/* 类型字段是 0x02（应答）而不是 0x00（上位机写）：格式错 */
static const uint8_t F_BAD_TYPE[] = {
    0xBB, 0x00, 0x07, 0x00, 0x03, 0x02, 0x00, 0x96, 0x00, 0xB2, 0xC7, 0x63, 0xAA
};
/* 分块帧，**payload 里含 0xBB**：验证 body 内的 0xBB 是数据、不是帧头 */
static const uint8_t F_CHUNK_BB[] = {
    0xBB, 0x00, 0x0D, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00,
    0xBB, 0xAA, 0xBB, 0x06, 0xBB, 0xBB, 0xDB, 0x07, 0xAA
};

/* ===========================================================================
 * T1: CRC-16/CCITT（对照独立算出的黄金值）
 * =========================================================================== */
static void test_crc(void)
{
    /* "123456789" 是 CRC 算法最通用的自检字符串。对本参数集（poly 0x1021、
     * init 0、不反射）结果是 0x31C3。*/
    static const uint8_t CHECK[] = { '1','2','3','4','5','6','7','8','9' };
    uint16_t crc = 0U;
    uint32_t i;

    h_puts("T1 CRC-16/CCITT\n");

    for (i = 0U; i < sizeof(CHECK); i++) {
        crc = crc16_ccitt_update(crc, CHECK[i]);
    }
    h_printf("        \"123456789\" -> 0x%x (expected 0x31c3)\n", (uint32_t)crc);
    h_check(crc == 0x31C3U, "check value for \"123456789\"");

    /* 应答体是 {大类, 子项, 0x02, 状态}——这是实际会用到 CRC 的地方
     * （构造应答时算的就是这 4 个字节）。*/
    {
        static const uint8_t cmds[] = { 0x01U, 0x02U, 0x03U, 0x04U, 0x05U, 0x99U };
        static const uint16_t exp_fail[] = { 0x5152U, 0x0802U, 0x3F32U,
                                             0xBAA2U, 0x8D92U, 0x80CAU };
        static const uint16_t exp_ok[]   = { 0x4FA2U, 0x16F2U, 0x21C2U,
                                             0xA452U, 0x9362U, 0x9E3AU };
        uint32_t k;

        for (k = 0U; k < 6U; k++) {
            uint16_t c = 0U;
            c = crc16_ccitt_update(c, FRAME_CATEGORY_MASK);
            c = crc16_ccitt_update(c, cmds[k]);
            c = crc16_ccitt_update(c, PROTOCOL_ACK_TYPE);
            c = crc16_ccitt_update(c, PROTOCOL_STATUS_FAIL);
            h_check(c == exp_fail[k], "ACK body CRC, status 0x00");

            c = 0U;
            c = crc16_ccitt_update(c, FRAME_CATEGORY_MASK);
            c = crc16_ccitt_update(c, cmds[k]);
            c = crc16_ccitt_update(c, PROTOCOL_ACK_TYPE);
            c = crc16_ccitt_update(c, PROTOCOL_STATUS_OK);
            h_check(c == exp_ok[k], "ACK body CRC, status 0xFF");
        }
    }
}

/* ===========================================================================
 * T2: 帧解析状态机
 * =========================================================================== */
static void test_frame(void)
{
    frame_parser_t parser;
    frame_t        f;

    h_puts("T2 frame parser\n");

    /* --- 文档金标帧：掩膜位置 (150,178) --- */
    frame_parser_init(&parser);
    h_check(feed_all(&parser, F_MASK_POS, sizeof(F_MASK_POS), &f) == 1,
            "doc golden frame produces one event");
    h_check(f.category == FRAME_CATEGORY_MASK, "category parsed (mask 0x00)");
    h_check(f.command == FRAME_CMD_POSITION, "command parsed (0x03)");
    h_check(f.type == FRAME_TYPE_WRITE, "type parsed (write 0x00)");
    h_check(f.body_length == 7U, "body_length parsed (7)");
    h_check(f.crc_ok && f.footer_ok && f.format_ok, "golden frame is fully good");

    /* --- 掩膜开关（文档金标帧），顺带覆盖"最短的合法帧" --- */
    frame_parser_init(&parser);
    h_check(feed_all(&parser, F_MASK_ON, sizeof(F_MASK_ON), &f) == 1,
            "mask-enable frame parses");
    h_check(f.command == FRAME_CMD_ENABLE, "enable command parsed");

    frame_parser_init(&parser);
    h_check(feed_all(&parser, F_MASK_OFF, sizeof(F_MASK_OFF), &f) == 1,
            "mask-disable frame parses");

    /* --- 保底 3 字节（子项 0x05）---
     * body 头本身就 3 字节，这是协议允许的下限。*/
    frame_parser_init(&parser);
    h_check(feed_all(&parser, F_PERSIST, sizeof(F_PERSIST), &f) == 1,
            "3-byte body (persist) parses");
    h_check(f.body_length == 3U, "shortest body_length accepted");
    h_check(f.command == FRAME_CMD_PERSIST, "persist command parsed");

    /* --- 前导噪声：帧前面多余的字节应被安静丢掉，不影响后面的解析 --- */
    frame_parser_init(&parser);
    h_check(frame_parser_feed(&parser, 0x01U, &f) == 0, "noise byte 0x01 ignored");
    h_check(frame_parser_feed(&parser, 0xAAU, &f) == 0, "machine header 0xAA ignored");
    h_check(feed_all(&parser, F_MASK_POS, sizeof(F_MASK_POS), &f) == 1,
            "frame after leading noise still parses");
    h_check(f.command == FRAME_CMD_POSITION, "command correct after noise");

    /* --- 关键用例：body 里的 0xBB 必须是数据而不是帧头 ---
     * 分块写入的 payload 是位图原始字节，取值可以是任意 0x00–0xFF。
     * 这里解析器在这里出错，合法帧就会被从中间截断、CRC 必然失败，
     * 表现为"掩膜数据永远传不进来"。*/
    frame_parser_init(&parser);
    h_check(feed_all(&parser, F_CHUNK_BB, sizeof(F_CHUNK_BB), &f) == 1,
            "0xBB inside payload does not split the frame");
    h_check(f.command == FRAME_CMD_CHUNK, "command correct with 0xBB in payload");
    h_check(f.body_length == 13U, "body_length correct with 0xBB in payload");
    h_check(f.crc_ok && f.footer_ok, "frame with 0xBB in payload is fully good");

    /* --- CRC 错误：把金标帧的 CRC 低字节改掉 ---
     * 从好帧复制再改一个字节，而不是硬编码一个坏帧——将来格式调整时
     * 这条测试不用跟着重算。*/
    frame_parser_init(&parser);
    {
        uint8_t bad[sizeof(F_MASK_POS)];
        uint32_t i;
        for (i = 0U; i < sizeof(F_MASK_POS); i++) {
            bad[i] = F_MASK_POS[i];
        }
        bad[11] ^= 0xFFU;                 /* 下标 11 是 CRC 低字节 */
        h_check(feed_all(&parser, bad, sizeof(bad), &f) == 1,
                "CRC error still yields one event");
        h_check(!f.crc_ok, "CRC error detected");
        h_check(f.footer_ok, "footer unaffected by CRC error");
    }

    /* --- 帧尾错误 --- */
    frame_parser_init(&parser);
    {
        uint8_t bad[sizeof(F_MASK_POS)];
        uint32_t i;
        for (i = 0U; i < sizeof(F_MASK_POS); i++) {
            bad[i] = F_MASK_POS[i];
        }
        bad[12] = 0x00U;                  /* 下标 12 是帧尾 */
        h_check(feed_all(&parser, bad, sizeof(bad), &f) == 1,
                "bad footer still yields one event");
        h_check(f.crc_ok, "CRC unaffected by footer error");
        h_check(!f.footer_ok, "footer error detected");
    }

    /* --- 长度越界（下界）：3 是下限，2 应被拒 ---
     * 期望是"一个帧都不产生"，且解析器回到等帧头状态。*/
    frame_parser_init(&parser);
    {
        uint8_t short_len[3] = { 0xBB, 0x00, 0x02 };
        h_check(feed_all(&parser, short_len, sizeof(short_len), 0) == 0,
                "body_length below range produces no frame");
        h_check(parser.bad_length_count == 1U, "bad length counted");
    }
    /* --- 长度越界（上界）：5000 正好是被拒的边界值 --- */
    frame_parser_init(&parser);
    {
        uint8_t big_len[3] = { 0xBB, 0x13, 0x88 };   /* 0x1388 = 5000 */
        h_check(feed_all(&parser, big_len, sizeof(big_len), 0) == 0,
                "body_length at upper bound produces no frame");
        h_check(parser.bad_length_count == 1U, "upper bound bad length counted");
    }

    /* --- 类型字段违规：CRC 是对的，问题出在类型不是"上位机写" ---
     * 注意**大类不参与格式校验**：电子变倍/热点/UI 的大类都是合法帧，
     * 只是不归本端点管（在 T4 里测分流）。*/
    frame_parser_init(&parser);
    h_check(feed_all(&parser, F_BAD_TYPE, sizeof(F_BAD_TYPE), &f) == 1,
            "bad type still yields one event");
    h_check(f.crc_ok && f.footer_ok, "bad type frame is otherwise intact");
    h_check(!f.format_ok, "bad type detected");

    /* --- 非掩膜大类应当被正常解析出来（不判为格式错）--- */
    frame_parser_init(&parser);
    h_check(feed_all(&parser, F_UI, sizeof(F_UI), &f) == 1,
            "UI frame parses");
    h_check(f.category == FRAME_CATEGORY_UI, "UI category parsed");
    h_check(f.format_ok, "other category is NOT a format error");

    /* --- 背靠背两帧：应产生两个事件 --- */
    frame_parser_init(&parser);
    {
        uint8_t two[sizeof(F_MASK_ON) * 2U];
        uint32_t i;
        for (i = 0U; i < sizeof(F_MASK_ON); i++) {
            two[i] = F_MASK_ON[i];
            two[i + sizeof(F_MASK_ON)] = F_MASK_ON[i];
        }
        h_check(feed_all(&parser, two, sizeof(two), &f) == 2,
                "back-to-back frames yield two events");
    }
}

/* ===========================================================================
 * T3: 应答字节序列
 * =========================================================================== */
static void test_ack(void)
{
    uint8_t ack[PROTOCOL_ACK_LEN];

    /* 期望值由独立 Python 实现算出。掩膜位置的应答是 10 字节，逐字节比对。*/
    static const uint8_t EXP_POS_FAIL[] = {
        0xBB, 0x00, 0x04, 0x00, 0x03, 0x02, 0x00, 0x3F, 0x32, 0xAA
    };
    static const uint8_t EXP_POS_OK[] = {
        0xBB, 0x00, 0x04, 0x00, 0x03, 0x02, 0xFF, 0x21, 0xC2, 0xAA
    };
    static const uint8_t EXP_ENABLE_FAIL[] = {
        0xBB, 0x00, 0x04, 0x00, 0x04, 0x02, 0x00, 0xBA, 0xA2, 0xAA
    };

    h_puts("T3 ACK construction\n");

    protocol_build_ack(ack, FRAME_CATEGORY_MASK, FRAME_CMD_POSITION,
                       PROTOCOL_STATUS_FAIL);
    show_bytes("cat 00 cmd 03 status 00", ack, PROTOCOL_ACK_LEN);
    h_check(bytes_equal(ack, EXP_POS_FAIL, PROTOCOL_ACK_LEN),
            "ACK for 0x03/FAIL is byte-exact");

    protocol_build_ack(ack, FRAME_CATEGORY_MASK, FRAME_CMD_POSITION,
                       PROTOCOL_STATUS_OK);
    show_bytes("cat 00 cmd 03 status FF", ack, PROTOCOL_ACK_LEN);
    h_check(bytes_equal(ack, EXP_POS_OK, PROTOCOL_ACK_LEN),
            "ACK for 0x03/OK is byte-exact");

    protocol_build_ack(ack, FRAME_CATEGORY_MASK, FRAME_CMD_ENABLE,
                       PROTOCOL_STATUS_FAIL);
    h_check(bytes_equal(ack, EXP_ENABLE_FAIL, PROTOCOL_ACK_LEN),
            "ACK for 0x04/FAIL is byte-exact");

    /* 结构性字段单独确认：这样将来格式调整时，一眼能看出是哪类字段变了。*/
    h_check(ack[0] == 0xBBU && ack[9] == 0xAAU, "ACK framing bytes");
    h_check(ack[1] == 0x00U && ack[2] == 0x04U, "ACK body_length is 4");
    h_check(ack[3] == FRAME_CATEGORY_MASK, "ACK echoes the category");
    h_check(ack[5] == PROTOCOL_ACK_TYPE, "ACK type byte is 0x02");
}

/* ===========================================================================
 * T4: 归属分流与统计计数
 * =========================================================================== */
static void test_policy(void)
{
    protocol_stats_t    stats;
    protocol_response_t resp;
    frame_parser_t      parser;
    frame_t             f;

    h_puts("T4 routing and counters\n");

    protocol_init(&stats);

    /* --- 掩膜帧、子项已识别、长度正确 ---
     * 期望：**要发应答**、状态失败（还没实现）、原因是"未实现"、
     * 子项名能从表里解析出来、并计入"接受"。*/
    frame_parser_init(&parser);
    feed_all(&parser, F_MASK_POS, sizeof(F_MASK_POS), &f);
    protocol_handle(&stats, &f, &resp);
    h_check(resp.send_ack == 1U, "mask frame asks for an ACK");
    h_check(resp.status == PROTOCOL_STATUS_FAIL, "no command succeeds yet");
    h_check(resp.reason == PROTO_REASON_NOT_IMPLEMENTED,
            "recognised command reports NOT_IMPLEMENTED");
    h_check(str_equal(resp.command_name, "position"),
            "command name resolved from the table");
    h_check(stats.accepted_count == 1U, "well-formed mask frame accepted");
    h_check(stats.bad_packet_count == 0U, "no bad packets yet");

    /* --- 其它大类的帧：不该回应、不该算坏包 ---
     * 这是本次改动的核心行为。电子变倍/热点/UI 的帧是**合法帧**，只是不归
     * 本端点管；如果给它们回一个"大类 0x00"的应答，那些模块的工具会报
     * "ACK 格式错误"，等于把别人撞坏。*/
    {
        /* 三个向量长度各不相同（变倍帧更长），所以长度必须逐个给，
         * 不能共用同一个 sizeof——那会读越界。*/
        const uint8_t *others[3];
        uint32_t       others_len[3];
        uint32_t       k;

        others[0] = F_EZOOM; others_len[0] = sizeof(F_EZOOM);
        others[1] = F_HOT;   others_len[1] = sizeof(F_HOT);
        others[2] = F_UI;    others_len[2] = sizeof(F_UI);

        for (k = 0U; k < 3U; k++) {
            frame_parser_init(&parser);
            feed_all(&parser, others[k], others_len[k], &f);
            protocol_handle(&stats, &f, &resp);
            h_check(resp.send_ack == 0U, "other category: NO ACK");
            h_check(resp.reason == PROTO_REASON_OTHER_CATEGORY,
                    "other category: reason is OTHER_CATEGORY");
        }
        h_check(stats.other_category_count == 3U, "other-category count is 3");
        h_check(stats.bad_packet_count == 0U,
                "other category is NOT counted as bad packet");
        h_check(stats.accepted_count == 1U, "accepted count unchanged");
    }

    /* --- CRC 错误：不发应答，计坏包 ---
     * 字节都不可信，无从判断这一帧属于哪个模块，贸然回应可能撞进别人的通信。*/
    frame_parser_init(&parser);
    {
        uint8_t bad[sizeof(F_MASK_POS)];
        uint32_t i;
        for (i = 0U; i < sizeof(F_MASK_POS); i++) {
            bad[i] = F_MASK_POS[i];
        }
        bad[11] ^= 0xFFU;
        feed_all(&parser, bad, sizeof(bad), &f);
    }
    protocol_handle(&stats, &f, &resp);
    h_check(resp.send_ack == 0U, "CRC error: NO ACK");
    h_check(resp.reason == PROTO_REASON_BAD_INTEGRITY, "CRC error reason");
    h_check(stats.bad_packet_count == 1U, "CRC error counted as bad packet");

    /* --- 未定义子项：要发应答（大类是掩膜），计坏包 --- */
    frame_parser_init(&parser);
    feed_all(&parser, F_UNKNOWN_CMD, sizeof(F_UNKNOWN_CMD), &f);
    protocol_handle(&stats, &f, &resp);
    h_check(resp.send_ack == 1U, "unknown command still gets an ACK");
    h_check(resp.reason == PROTO_REASON_UNKNOWN_COMMAND, "unknown command reason");
    h_check(str_equal(resp.command_name, "?"), "unknown command has no name");
    h_check(stats.bad_packet_count == 2U, "unknown command counted as bad packet");

    /* --- 长度与子项不符：要发应答、计坏包、仍能解析出子项名 --- */
    frame_parser_init(&parser);
    feed_all(&parser, F_LEN_MISMATCH, sizeof(F_LEN_MISMATCH), &f);
    protocol_handle(&stats, &f, &resp);
    h_check(resp.send_ack == 1U, "length mismatch still gets an ACK");
    h_check(resp.reason == PROTO_REASON_BAD_LENGTH, "length mismatch reason");
    h_check(str_equal(resp.command_name, "position"),
            "length mismatch still resolves the command name");
    h_check(stats.bad_packet_count == 3U, "length mismatch counted as bad packet");

    /* --- 分块长度不足（协议要求 > 7，实际 7）--- */
    frame_parser_init(&parser);
    feed_all(&parser, F_CHUNK_SHORT, sizeof(F_CHUNK_SHORT), &f);
    protocol_handle(&stats, &f, &resp);
    h_check(resp.reason == PROTO_REASON_BAD_LENGTH, "short chunk rejected");
    h_check(stats.bad_packet_count == 4U, "short chunk counted as bad packet");

    /* --- 分块长度足够（15 > 7）应当被接受 --- */
    frame_parser_init(&parser);
    feed_all(&parser, F_CHUNK, sizeof(F_CHUNK), &f);
    protocol_handle(&stats, &f, &resp);
    h_check(resp.reason == PROTO_REASON_NOT_IMPLEMENTED, "valid chunk accepted");
    h_check(stats.accepted_count == 2U, "valid chunk counted as accepted");

    /* --- 类型字段违规：要发应答、计坏包 --- */
    frame_parser_init(&parser);
    feed_all(&parser, F_BAD_TYPE, sizeof(F_BAD_TYPE), &f);
    protocol_handle(&stats, &f, &resp);
    h_check(resp.send_ack == 1U, "bad type still gets an ACK");
    h_check(resp.reason == PROTO_REASON_BAD_FORMAT, "bad type reason");
    h_check(stats.bad_packet_count == 5U, "bad type counted as bad packet");

    h_check(resp.status == PROTOCOL_STATUS_FAIL, "failures stay status 0x00");
}

/* ===========================================================================
 * T5: 每个掩膜帧恰好一个应答（背靠背也不丢）
 * =========================================================================== */
static void test_ack_per_frame(void)
{
    frame_parser_t      parser;
    protocol_stats_t    stats;
    frame_t             f;
    protocol_response_t resp;
    uint8_t             two[sizeof(F_MASK_ON) * 2U];
    uint32_t            i;
    int                 frames = 0;
    int                 acks = 0;

    h_puts("T5 one ACK per mask frame\n");

    protocol_init(&stats);
    frame_parser_init(&parser);
    /* 把文档金标帧拼两遍，构造"两个紧挨着的帧"。*/
    for (i = 0U; i < sizeof(F_MASK_ON); i++) {
        two[i] = F_MASK_ON[i];
        two[i + sizeof(F_MASK_ON)] = F_MASK_ON[i];
    }

    /* 逐字节喂进去，每解析出一个帧就处理一次。
     * 这段循环模拟的正是 main.c 主循环的核心逻辑。*/
    for (i = 0U; i < sizeof(two); i++) {
        if (frame_parser_feed(&parser, two[i], &f) != 0) {
            frames++;
            protocol_handle(&stats, &f, &resp);
            if (resp.send_ack != 0) {
                acks++;
                h_check(resp.ack[0] == 0xBBU && resp.ack[9] == 0xAAU,
                        "back-to-back ACK framing");
            }
        }
    }
    /* 两个帧、两个应答，一个都不能少——这就是在验证"ACK 不丢失"。
     * RTL 端点在这个场景下会丢掉第二个应答，软件侧不应复现该缺陷。*/
    h_check(frames == 2, "two frames parsed");
    h_check(acks == 2, "two ACKs produced, none dropped");
}

/* ===========================================================================
 * 本组用例的入口，由 test_main.c 调用
 * =========================================================================== */
void test_protocol(void)
{
    test_crc();
    test_frame();
    test_ack();
    test_policy();
    test_ack_per_frame();
}
