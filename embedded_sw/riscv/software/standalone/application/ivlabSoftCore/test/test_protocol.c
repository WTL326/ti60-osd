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
#include "osd/ui.h"      /* ui_init / ui_query_view：T6 直接查 UI 状态 */
#include "osd/font.h"    /* T7 的参考实现要自己查字库 */
#include "osd/canvas.h"  /* T7 读回位图做逐字节比对 */
#include "osd/osd_engine.h"

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
        /* 两个向量长度各不相同（变倍帧更长），所以长度必须逐个给，
         * 不能共用同一个 sizeof——那会读越界。
         *
         * 2026-09 变更：这里原本还有第三个向量 F_UI（大类 0x04）。0x04 现在
         * 归本端点管（见变更 add-quad-uart-app 的 spec「大类归属」），它不再
         * 计入"其它大类"；而它的子项 0x01 属于"只解析不应答"的那一组。
         * 新的期望（不应答、不计入 other、也不计坏包）在 T6 里逐条验证，
         * 这里把它移出列表，避免同一件事有两个互相矛盾的断言。*/
        const uint8_t *others[2];
        uint32_t       others_len[2];
        uint32_t       k;

        others[0] = F_EZOOM; others_len[0] = sizeof(F_EZOOM);
        others[1] = F_HOT;   others_len[1] = sizeof(F_HOT);

        for (k = 0U; k < 2U; k++) {
            frame_parser_init(&parser);
            feed_all(&parser, others[k], others_len[k], &f);
            protocol_handle(&stats, &f, &resp);
            h_check(resp.send_ack == 0U, "other category: NO ACK");
            h_check(resp.reason == PROTO_REASON_OTHER_CATEGORY,
                    "other category: reason is OTHER_CATEGORY");
        }
        h_check(stats.other_category_count == 2U, "other-category count is 2");
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
 * T6 UI 大类（0x04）—— 变更 add-quad-osd-overlay 的 §6 验收
 *
 * 帧向量的来源与 T1–T5 一致：由一份**独立的 Python 实现**算出（照协议参数直接
 * 写：多项式 0x1021、初值 0x0000、不反射、无最终异或），没有运行过被测的 C 代码。
 * 应答金标同样如此 —— 尤其是 EXP_QUERY_OK 那 18 个字节，它是"上位机工具按
 * tools/send_ui_via_adb.py 的规则应当收到的东西"，逐字节写死。
 * =========================================================================== */

/* SET_VIEW：页 0x0100、选中第 2 项、flags = bit0（UI 显示） */
static const uint8_t F_UI_SET_VIEW[] = {
    0xBB, 0x00, 0x07, 0x04, 0x06, 0x00, 0x01, 0x00, 0x02, 0x01,
    0x4C, 0xD0, 0xAA
};
/* SET_VIEW：同上，但 flags = 0xFF（保留位 2–7 全置 1） */
static const uint8_t F_UI_SET_VIEW_RSV[] = {
    0xBB, 0x00, 0x07, 0x04, 0x06, 0x00, 0x01, 0x00, 0x02, 0xFF,
    0x42, 0x01, 0xAA
};
/* SET_VIEW：body_length = 5，比该子项要求的 7 短 */
static const uint8_t F_UI_SET_VIEW_BADLEN[] = {
    0xBB, 0x00, 0x05, 0x04, 0x06, 0x00, 0x01, 0x00, 0x9D, 0xAE,
    0xAA
};
/* SET_VIEW：页 0x9999 不在场景表里 */
static const uint8_t F_UI_SET_VIEW_BADPAGE[] = {
    0xBB, 0x00, 0x07, 0x04, 0x06, 0x00, 0x99, 0x99, 0x00, 0x00,
    0x9F, 0x67, 0xAA
};
/* SET_VIEW：页 0x0100 的第 5 项（PIP >）没有数值，不该允许编辑态 */
static const uint8_t F_UI_SET_VIEW_BADEDIT[] = {
    0xBB, 0x00, 0x07, 0x04, 0x06, 0x00, 0x01, 0x00, 0x05, 0x02,
    0xE5, 0x24, 0xAA
};
/* SET_IMAGE_VALUES：3/5/7/5，全部在范围内 */
static const uint8_t F_UI_SET_IMG[] = {
    0xBB, 0x00, 0x07, 0x04, 0x07, 0x00, 0x03, 0x05, 0x07, 0x05,
    0xB0, 0x99, 0xAA
};
/* SET_IMAGE_VALUES：首项 6 超出上限 5，整条应失败 */
static const uint8_t F_UI_SET_IMG_RANGE[] = {
    0xBB, 0x00, 0x07, 0x04, 0x07, 0x00, 0x06, 0x05, 0x07, 0x05,
    0x0C, 0xDC, 0xAA
};
/* QUERY_VIEW：无 payload */
static const uint8_t F_UI_QUERY[] = {
    0xBB, 0x00, 0x03, 0x04, 0x08, 0x00, 0x55, 0x69, 0xAA
};
/* 本期不纳入的五个子项（0x01–0x05），各带 2 字节 payload */
static const uint8_t F_UI_SUB1[] = {
    0xBB, 0x00, 0x05, 0x04, 0x01, 0x00, 0x00, 0x00, 0xFF, 0xB2,
    0xAA
};
static const uint8_t F_UI_SUB2[] = {
    0xBB, 0x00, 0x05, 0x04, 0x02, 0x00, 0x00, 0x00, 0x64, 0x6E,
    0xAA
};
static const uint8_t F_UI_SUB3[] = {
    0xBB, 0x00, 0x05, 0x04, 0x03, 0x00, 0x00, 0x00, 0x12, 0xDA,
    0xAA
};
static const uint8_t F_UI_SUB4[] = {
    0xBB, 0x00, 0x05, 0x04, 0x04, 0x00, 0x00, 0x00, 0x43, 0xF7,
    0xAA
};
static const uint8_t F_UI_SUB5[] = {
    0xBB, 0x00, 0x05, 0x04, 0x05, 0x00, 0x00, 0x00, 0x35, 0x43,
    0xAA
};

/* 应答金标（同样由独立 Python 实现算出） */
static const uint8_t EXP_SET_VIEW_OK[] = {
    0xBB, 0x00, 0x04, 0x04, 0x06, 0x02, 0xFF, 0x00, 0xC3, 0xAA
};
static const uint8_t EXP_SET_IMG_OK[] = {
    0xBB, 0x00, 0x04, 0x04, 0x07, 0x02, 0xFF, 0x37, 0xF3, 0xAA
};
static const uint8_t EXP_SET_IMG_FAIL[] = {
    0xBB, 0x00, 0x04, 0x04, 0x07, 0x02, 0x00, 0x29, 0x03, 0xAA
};
/* SET_VIEW 成功之后的 QUERY_VIEW：18 字节，正好是上位机工具期待的形状 */
static const uint8_t EXP_QUERY_OK[] = {
    0xBB, 0x00, 0x0C, 0x04, 0x08, 0x02, 0xFF, 0x01, 0x00, 0x02,
    0x01, 0x03, 0x05, 0x07, 0x05, 0x22, 0x31, 0xAA
};
/* 再来一次 SET_VIEW 但 flags = 0xFF：保留位应被丢弃，回读只剩 0x03 */
static const uint8_t EXP_QUERY_VIS[] = {
    0xBB, 0x00, 0x0C, 0x04, 0x08, 0x02, 0xFF, 0x01, 0x00, 0x02,
    0x03, 0x03, 0x05, 0x07, 0x05, 0x66, 0xB2, 0xAA
};

/******************************************************************************
* @brief 把一帧完整喂进去并处理。
*
* @return 1 = 解析出了一个帧并已处理；0 = 没解析出帧。
******************************************************************************/
static int ui_feed(protocol_stats_t *stats, const uint8_t *bytes, uint32_t len,
                   protocol_response_t *resp)
{
    frame_parser_t parser;
    frame_t        f;

    frame_parser_init(&parser);
    if (feed_all(&parser, bytes, len, &f) != 1) {
        return 0;
    }
    protocol_handle(stats, &f, resp);
    return 1;
}

/******************************************************************************
* @brief 按**上位机工具的规则**校验一个应答。
*
* @param ack      应答字节。
* @param ack_len  应答整帧长度（数出来的）。
* @param cat      期望的大类。
* @param sub      期望的子项。
* @param status   期望的状态字节。
* @param body_len 期望的 body 长度。
* @return 1 = 完全合规。
*
* @note 这几条正是 tools/send_ui_via_adb.py 的 `:104-107` 在做的事：
*       整帧长度 == body_length + 6、帧头帧尾、body[:3] == (cat, sub, 0x02)、
*       body[3] == 状态、以及 `crc16(完整 body)` 相符。用工具的规则而不是
*       我自己的规则来验，才能保证"联调时工具不会报 UI命令失败"。
******************************************************************************/
static int ack_wellformed(const uint8_t *ack, uint8_t ack_len, uint8_t cat,
                          uint8_t sub, uint8_t status, uint16_t body_len)
{
    uint16_t crc_recv, crc_calc;
    uint16_t i;

    if ((uint16_t)ack_len != (uint16_t)(body_len + 6U))          return 0;
    if (ack[0] != 0xBBU || ack[ack_len - 1U] != 0xAAU)           return 0;
    if (ack[1] != 0U || ack[2] != (uint8_t)body_len)             return 0;
    if (ack[3] != cat || ack[4] != sub || ack[5] != 0x02U)       return 0;
    if (ack[6] != status)                                        return 0;

    crc_recv = (uint16_t)(((uint16_t)ack[3U + body_len] << 8) |
                           (uint16_t)ack[4U + body_len]);
    crc_calc = 0U;
    for (i = 0U; i < body_len; i++) {
        crc_calc = crc16_ccitt_update(crc_calc, ack[3U + i]);
    }
    return (crc_recv == crc_calc) ? 1 : 0;
}

/******************************************************************************
* @brief T6：UI 大类的命令处理与应答口径。
******************************************************************************/
static void test_ui_channel(void)
{
    protocol_stats_t    stats;
    protocol_response_t resp;

    h_puts("T6 UI category 0x04\n");

    /* ---- 6.1/6.2：SET_VIEW 合法帧进入表中处理，应答为定长 10 字节 ---- */
    protocol_init(&stats);
    ui_init();
    h_check(ui_feed(&stats, F_UI_SET_VIEW, sizeof(F_UI_SET_VIEW), &resp) == 1,
            "SET_VIEW parsed");
    h_check(resp.send_ack == 1U, "SET_VIEW asks for an ACK");
    h_check(resp.status == PROTOCOL_STATUS_OK, "SET_VIEW accepted");
    h_check(resp.defer_ack == 1U, "SET_VIEW defers its ACK until commit");
    h_check(resp.ack_len == PROTOCOL_ACK_LEN, "SET_VIEW ACK is 10 bytes");
    h_check(bytes_equal(resp.ack, EXP_SET_VIEW_OK, PROTOCOL_ACK_LEN),
            "SET_VIEW ACK matches the golden vector");
    h_check(ack_wellformed(resp.ack, resp.ack_len, 0x04U, 0x06U,
                           PROTOCOL_STATUS_OK, 4U),
            "SET_VIEW ACK passes the host tool's checks");
    h_check(stats.accepted_count == 1U, "SET_VIEW counted as accepted");
    h_check(stats.other_category_count == 0U, "SET_VIEW not counted as other");

    /* ---- 6.1：长度不符则失败，且不应答成功 ---- */
    protocol_init(&stats);
    ui_init();
    h_check(ui_feed(&stats, F_UI_SET_VIEW_BADLEN, sizeof(F_UI_SET_VIEW_BADLEN),
                    &resp) == 1, "bad-length SET_VIEW parsed");
    h_check(resp.status == PROTOCOL_STATUS_FAIL, "bad-length SET_VIEW fails");
    h_check(resp.reason == PROTO_REASON_BAD_LENGTH, "reason is BAD_LENGTH");
    h_check(stats.bad_packet_count == 1U, "bad-length counted as bad packet");
    h_check(stats.accepted_count == 0U, "bad-length not counted as accepted");
    h_check(resp.ack_len == PROTOCOL_ACK_LEN, "bad-length ACK is 10 bytes");

    /* ---- 6.1：页面非法 / 编辑态用在无数值的行上，都失败 ---- */
    protocol_init(&stats);
    ui_init();
    (void)ui_feed(&stats, F_UI_SET_VIEW_BADPAGE, sizeof(F_UI_SET_VIEW_BADPAGE), &resp);
    h_check(resp.status == PROTOCOL_STATUS_FAIL, "unknown page fails");
    ui_init();
    (void)ui_feed(&stats, F_UI_SET_VIEW_BADEDIT, sizeof(F_UI_SET_VIEW_BADEDIT), &resp);
    h_check(resp.status == PROTOCOL_STATUS_FAIL, "edit on a non-value row fails");

    /* ---- 6.2：QUERY_VIEW 是 18 字节，且与上位机工具的解析逐字段对齐 ---- */
    protocol_init(&stats);
    ui_init();
    (void)ui_feed(&stats, F_UI_SET_VIEW, sizeof(F_UI_SET_VIEW), &resp);
    h_check(ui_feed(&stats, F_UI_QUERY, sizeof(F_UI_QUERY), &resp) == 1,
            "QUERY_VIEW parsed");
    h_check(resp.ack_len == PROTOCOL_ACK_MAX, "QUERY_VIEW ACK is 18 bytes");
    h_check(bytes_equal(resp.ack, EXP_QUERY_OK, PROTOCOL_ACK_MAX),
            "QUERY_VIEW ACK matches the golden vector");
    h_check(ack_wellformed(resp.ack, resp.ack_len, 0x04U, 0x08U,
                           PROTOCOL_STATUS_OK, 12U),
            "QUERY_VIEW ACK passes the host tool's checks (CRC over 12 bytes)");
    h_check(resp.defer_ack == 0U, "QUERY_VIEW replies immediately");
    /* 12 字节的 body ≠ 4 字节：这里顺带钉死"不能按定长 10 发" */
    h_check(resp.ack_len != PROTOCOL_ACK_LEN, "QUERY_VIEW is NOT the 10-byte form");

    /* ---- 6.3：保留位静默丢弃 —— 帧仍被接受，回读时保留位为 0 ---- */
    ui_init();
    h_check(ui_feed(&stats, F_UI_SET_VIEW_RSV, sizeof(F_UI_SET_VIEW_RSV), &resp) == 1,
            "SET_VIEW with reserved flags parsed");
    h_check(resp.status == PROTOCOL_STATUS_OK,
            "reserved flags are dropped silently, not an error");
    (void)ui_feed(&stats, F_UI_QUERY, sizeof(F_UI_QUERY), &resp);
    h_check(bytes_equal(resp.ack, EXP_QUERY_VIS, PROTOCOL_ACK_MAX),
            "read-back flags keep only bit0..bit1");

    /* ---- 6.10：SET_IMAGE_VALUES 只改显示状态 ---- */
    protocol_init(&stats);
    ui_init();
    h_check(ui_feed(&stats, F_UI_SET_IMG, sizeof(F_UI_SET_IMG), &resp) == 1,
            "SET_IMAGE_VALUES parsed");
    h_check(resp.status == PROTOCOL_STATUS_OK, "in-range values accepted");
    h_check(bytes_equal(resp.ack, EXP_SET_IMG_OK, PROTOCOL_ACK_LEN),
            "SET_IMAGE_VALUES ACK matches the golden vector");
    /* 越界：整条失败，且四个值一个都不许变 */
    h_check(ui_feed(&stats, F_UI_SET_IMG_RANGE, sizeof(F_UI_SET_IMG_RANGE),
                    &resp) == 1, "out-of-range frame parsed");
    h_check(resp.status == PROTOCOL_STATUS_FAIL, "out-of-range rejected");
    h_check(bytes_equal(resp.ack, EXP_SET_IMG_FAIL, PROTOCOL_ACK_LEN),
            "failure ACK matches the golden vector");
    (void)ui_feed(&stats, F_UI_QUERY, sizeof(F_UI_QUERY), &resp);
    h_check(resp.ack[11] == 0x03U && resp.ack[12] == 0x05U &&
            resp.ack[13] == 0x07U && resp.ack[14] == 0x05U,
            "four values unchanged after a rejected batch");

    /* ---- 6.9：未纳入的 0x01–0x05 只解析，不应答、不计入任何计数 ---- */
    {
        static const struct { const uint8_t *f; uint32_t n; } kSubs[] = {
            { F_UI_SUB1, sizeof(F_UI_SUB1) }, { F_UI_SUB2, sizeof(F_UI_SUB2) },
            { F_UI_SUB3, sizeof(F_UI_SUB3) }, { F_UI_SUB4, sizeof(F_UI_SUB4) },
            { F_UI_SUB5, sizeof(F_UI_SUB5) }
        };
        uint32_t k;

        protocol_init(&stats);
        ui_init();
        for (k = 0U; k < 5U; k++) {
            h_check(ui_feed(&stats, kSubs[k].f, kSubs[k].n, &resp) == 1,
                    "out-of-scope UI sub parsed");
            h_check(resp.send_ack == 0U, "out-of-scope UI sub: NO ACK");
            h_check(resp.reason == PROTO_REASON_UI_IGNORED, "reason is UI_IGNORED");
        }
        h_check(stats.accepted_count == 0U, "out-of-scope subs are not accepted");
        h_check(stats.bad_packet_count == 0U, "out-of-scope subs are not bad packets");
        h_check(stats.other_category_count == 0U, "out-of-scope subs are not 'other'");
    }

    /* ---- 6.4：三类大类的计数口径 ---- */
    {
        /* F_MASK_ON 大类 0x00、F_UI_SET_VIEW 大类 0x04、F_EZOOM 大类 0x01 */
        static const uint8_t F_MASK[] = {
            0xBB, 0x00, 0x04, 0x00, 0x04, 0x00, 0x01, 0xCC, 0xE1, 0xAA
        };
        static const uint8_t F_EZOOM[] = {
            0xBB, 0x00, 0x0B, 0x01, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04,
            0xFF, 0x03, 0xFF, 0xF9, 0x3D, 0xAA
        };

        protocol_init(&stats);
        ui_init();
        (void)ui_feed(&stats, F_MASK, sizeof(F_MASK), &resp);
        (void)ui_feed(&stats, F_UI_SET_VIEW, sizeof(F_UI_SET_VIEW), &resp);
        (void)ui_feed(&stats, F_EZOOM, sizeof(F_EZOOM), &resp);
        h_check(stats.accepted_count == 2U, "0x00 and 0x04 are both accepted");
        h_check(stats.other_category_count == 1U, "0x01 is the only 'other'");
        h_check(stats.bad_packet_count == 0U, "no bad packets in this mix");
    }

    /* ---- 大类 0x04 的未知子项（如 0x09）仍按"未知命令"处理 ---- */
    {
        static const uint8_t F_UI_UNKNOWN[] = {
            0xBB, 0x00, 0x03, 0x04, 0x09, 0x00, 0x66, 0x58, 0xAA
        };
        protocol_init(&stats);
        ui_init();
        (void)ui_feed(&stats, F_UI_UNKNOWN, sizeof(F_UI_UNKNOWN), &resp);
        h_check(resp.send_ack == 1U, "unknown UI sub still gets an ACK");
        h_check(resp.reason == PROTO_REASON_UNKNOWN_COMMAND, "reason is UNKNOWN_COMMAND");
        h_check(stats.bad_packet_count == 1U, "unknown UI sub counts as a bad packet");
    }
}

/* ===========================================================================
 * T7 引擎层：渲染 / 提交 / 应答的时序（任务 6.5 / 6.6 / 6.8 / 6.10）
 *
 * 这组用例跑的是 osd_engine + composer + canvas_mem 三层的组合。它们都不碰硬件，
 * 所以能在 qemu 上把"提交后才应答"这条顺序规则的**可观测后果**钉住。
 *
 * 关于"顺序"能测到什么程度，先说清楚，免得高估这组用例：
 *   单线程的离机测试里，"A 在 B 之前发生"只能通过**副作用**观察，不能直接观察
 *   时序。所以这里验的是：命令成功返回时画布**已经是新的**（用"先投毒再检查"
 *   的办法）、且恰好提交了一次；失败与查询则一次都不提交。真正端到端的那一句
 *   ——"上位机收到成功时画面已就绪"——要等联调（8.6）。
 * =========================================================================== */

/* 参考实现：把字符网格**逐像素**展开成 1 bit/像素位图的一行。
 *
 * 它是 composer.c 改造前那条路径的等价物（那次是 8 bpp，这里按 1 bpp 写）。
 * 写法与被测实现**刻意不同**：被测的是"一格字形 = 两个字节直接落盘"，
 * 这里是"逐位判断、按位或进目标字节"。位序或字节序错一处，两者就会不一致，
 * 所以逐字节比对是有意义的，不是把同一段代码抄两遍。 */
static void ref_render_row(unsigned r, unsigned gy, uint8_t *out /* 68 字节 */)
{
    unsigned c, gx;

    for (c = 0u; c < OSD_ROW_STRIDE; c++) out[c] = 0u;

    for (c = 0u; c < OSD_GRID_COLS; c++) {
        int      idx = font_lookup(osd_buf[r][c]);
        uint16_t bits;

        if (idx < 0) idx = font_lookup((uint16_t)'?');
        bits = (idx < 0) ? 0u : font_row_bits(font_glyph(idx), gy);

        for (gx = 0u; gx < OSD_GLYPH_W; gx++) {
            unsigned x = c * OSD_GLYPH_W + gx;
            if ((bits & (uint16_t)(1u << (OSD_GLYPH_W - 1u - gx))) != 0u) {
                out[x >> 3] |= (uint8_t)(0x80u >> (x & 7u));   /* bit 7 最左 */
            }
        }
    }
}

/* 整块字节的简单累加。只用来回答"两次渲染的结果是否不同" —— 不是校验和，
 * 不需要抗碰撞。*/
static uint32_t block_sum(const uint8_t *blk)
{
    uint32_t i;
    uint32_t s = 0U;

    for (i = 0u; i < (uint32_t)OSD_BLOCK_BYTES; i++) {
        s += blk[i];
    }
    return s;
}

/* 刚被渲染过的那一块。引擎在提交后翻转了后台块，所以是 back ^ 1。 */
static const uint8_t *just_rendered_block(void)
{
    return canvas_block_data(osd_engine_back_block() ^ 1);
}

/******************************************************************************
* @brief 把一帧交给引擎处理。
*
* @return 待发应答的字节数（0 = 不应答）；-1 = 压根没解析出帧（测试向量错了）。
******************************************************************************/
static int engine_feed(protocol_stats_t *stats, const uint8_t *bytes, uint32_t len,
                       protocol_response_t *resp, uint8_t *ack)
{
    frame_parser_t parser;
    frame_t        f;

    frame_parser_init(&parser);
    if (feed_all(&parser, bytes, len, &f) != 1) {
        return -1;
    }
    return (int)osd_engine_handle(stats, &f, resp, ack);
}

/******************************************************************************
* @brief 把某一块整体填成固定值（"投毒"），用来证明渲染确实发生了。
******************************************************************************/
static void poison_block(int idx, uint8_t v)
{
    int save = osd_engine_back_block();

    /* canvas_fill 只作用于"当前后台块"，所以要先切过去再切回来。 */
    canvas_select_block(idx);
    canvas_fill(0U, v, (uint32_t)OSD_BLOCK_BYTES);
    canvas_select_block(save);
}

static void test_engine(void)
{
    protocol_stats_t    stats;
    protocol_response_t resp;
    uint8_t             ack[PROTOCOL_ACK_MAX];
    uint32_t            commits;
    uint32_t            boot_sum;
    int                 renders;
    int                 n;
    uint32_t            i;

    h_puts("T7 engine: render / commit / ACK ordering\n");

    /* ---- 上电：渲染并提交第一屏 ---- */
    osd_engine_boot();
    h_check(osd_engine_render_count() == 1, "boot renders the first screen");
    h_check(s_commit_count == 1U, "boot commits exactly once");
    h_check(s_last_ctrl & OSD_CTRL_ENABLE,
            "boot leaves the menu window enabled (flags.bit0 = 1)");

    /* ---- 上电那一帧必须**真的有内容** ----
     *
     * 这三条是后补的，补的是一个"223 条断言全绿、画面却一片空白"的缺陷：
     * L3（ui/scene_build）→ L4（composer）这一步的调用当时漏掉了，网格一直是
     * 全空格，composer 于是忠实地把空格渲染成一张全零位图 —— 窗口开着、位置对、
     * 提交也生效了，**但内容是空的**，现场表现就是"叠加什么都没有"。
     *
     * 为什么原来的断言全都漏过：
     *   "boot renders the first screen" 只数渲染次数，
     *   "boot commits exactly once" 只数提交次数，
     *   而那条"1bpp 打包与逐像素展开逐字节一致"比较的是**同一个网格**的两条
     *   展开路径 —— 网格为空时两边同时为空，一致，照样通过。
     * 所以这里必须换成**与网格内容无关**的性质：这一帧长什么样。*/
    {
        const uint8_t *boot_blk = just_rendered_block();
        uint32_t       nz       = 0U;
        uint32_t       k;
        int            title_ink = 0;

        for (k = 0U; k < (uint32_t)OSD_BLOCK_BYTES; k++) {
            if (boot_blk[k] != 0U) nz++;
        }
        boot_sum = block_sum(boot_blk);

        h_check(nz > 0U, "boot frame is not blank (scene_build ran before render)");
        /* 两列边框 13 行 × 16 扫描行 × 2 字节，加上下边框，至少几百字节。
         * 500 这个门槛远高于"个别杂散位"，又远低于真实的菜单量。*/
        h_check(nz >= 500U, "boot frame looks like a menu-sized drawing");
        /* 标题行（第 1 个字形行）必须有笔画：与具体字形无关，有文字就必然成立 */
        for (k = (uint32_t)OSD_ROW_TITLE * (uint32_t)OSD_GLYPH_H
                 * (uint32_t)OSD_ROW_STRIDE;
             k < (uint32_t)(OSD_ROW_TITLE + 1U) * (uint32_t)OSD_GLYPH_H
                 * (uint32_t)OSD_ROW_STRIDE;
             k++) {
            if (boot_blk[k] != 0U) { title_ink = 1; break; }
        }
        h_check(title_ink, "boot frame carries title text");
    }

    /* ---- 6.5/6.6：SET_VIEW 成功 → 先渲染提交，再把成功应答交出来 ---- */
    protocol_init(&stats);
    poison_block(osd_engine_back_block(), 0xA5U);   /* 投毒：当前后台块整块 0xA5 */
    commits = s_commit_count;
    renders = osd_engine_render_count();

    n = engine_feed(&stats, F_UI_SET_VIEW, sizeof(F_UI_SET_VIEW), &resp, ack);
    h_check(n == (int)PROTOCOL_ACK_LEN, "SET_VIEW returns a 10-byte ACK");
    h_check(ack[6] == PROTOCOL_STATUS_OK, "ACK carries success");
    h_check(osd_engine_last_deferred() == 1, "ACK was deferred until after commit");
    h_check(s_commit_count == commits + 1U, "SET_VIEW commits exactly once");
    h_check(osd_engine_render_count() == renders + 1, "SET_VIEW renders exactly once");
    /* 换的页与上电页不同（0x0100 vs 0x0000），所以这一帧必须与上电帧不同 ——
     * 堵住"网格只在启动时建一次、之后不再重建"这另一半缺陷。*/
    h_check(block_sum(just_rendered_block()) != boot_sum,
            "a page change actually changes the rendered frame");

    /* 投毒被覆盖 = 渲染确实在应答交出来之前发生了 */
    {
        const uint8_t *blk = just_rendered_block();
        int still_poisoned = 1;
        for (i = 0U; i < OSD_BLOCK_BYTES; i++) {
            if (blk[i] != 0xA5U) { still_poisoned = 0; break; }
        }
        h_check(!still_poisoned, "canvas was rewritten before the ACK was handed out");
    }

    /* ---- 6.6：使能与缓冲选择在同一次提交里 ---- */
    h_check((s_last_ctrl & OSD_CTRL_ENABLE) != 0U, "bit0 = 1 -> CTRL.enable set");
    h_check(((s_last_ctrl & OSD_CTRL_BUFFER) != 0U) ==
            ((osd_engine_back_block() ^ 1) == 1),
            "CTRL.buffer_select matches the block just written (same commit)");
    h_check(s_last_pos == ((((uint32_t)OSD_MENU_TOP) << 12) | (uint32_t)OSD_MENU_LEFT),
            "menu position written in the same commit group");

    /* ---- 6.5：失败的 SET_VIEW 不渲染、不提交 ---- */
    commits = s_commit_count;
    renders = osd_engine_render_count();
    n = engine_feed(&stats, F_UI_SET_VIEW_BADPAGE, sizeof(F_UI_SET_VIEW_BADPAGE),
                    &resp, ack);
    h_check(n == (int)PROTOCOL_ACK_LEN, "failed SET_VIEW still answers");
    h_check(ack[6] == PROTOCOL_STATUS_FAIL, "failed SET_VIEW answers with failure");
    h_check(osd_engine_last_deferred() == 0, "failed SET_VIEW is not deferred");
    h_check(s_commit_count == commits, "failed SET_VIEW does NOT commit");
    h_check(osd_engine_render_count() == renders, "failed SET_VIEW does NOT render");

    /* ---- 6.5：QUERY_VIEW 不渲染、不提交（无命令则零写入） ---- */
    commits = s_commit_count;
    renders = osd_engine_render_count();
    n = engine_feed(&stats, F_UI_QUERY, sizeof(F_UI_QUERY), &resp, ack);
    h_check(n == (int)PROTOCOL_ACK_MAX, "QUERY_VIEW returns an 18-byte ACK");
    h_check(s_commit_count == commits, "QUERY_VIEW does NOT commit");
    h_check(osd_engine_render_count() == renders, "QUERY_VIEW does NOT render");

    /* ---- 6.9：未纳入的子项一律不产生应答，也不碰画布 ---- */
    commits = s_commit_count;
    renders = osd_engine_render_count();
    n = engine_feed(&stats, F_UI_SUB2, sizeof(F_UI_SUB2), &resp, ack);
    h_check(n == 0, "out-of-scope UI sub produces NO bytes at all");
    h_check(s_commit_count == commits && osd_engine_render_count() == renders,
            "out-of-scope UI sub leaves the canvas alone");

    /* ---- 6.6：bit0 = 0 时把菜单窗口关掉（同一个提交组里） ---- */
    {
        /* 页 0x0100、选中第 2 项、flags = 0（bit0 = 0 → 不显示） */
        static const uint8_t F_HIDE[] = {
            0xBB, 0x00, 0x07, 0x04, 0x06, 0x00, 0x01, 0x00, 0x02, 0x00,
            0x5C, 0xF1, 0xAA
        };
        protocol_init(&stats);
        n = engine_feed(&stats, F_HIDE, sizeof(F_HIDE), &resp, ack);
        h_check(n == (int)PROTOCOL_ACK_LEN && ack[6] == PROTOCOL_STATUS_OK,
                "SET_VIEW with bit0 = 0 is accepted");
        h_check((s_last_ctrl & OSD_CTRL_ENABLE) == 0U,
                "bit0 = 0 -> CTRL.enable cleared in the same commit");
        /* 置回 1，菜单恢复 */
        (void)engine_feed(&stats, F_UI_SET_VIEW, sizeof(F_UI_SET_VIEW), &resp, ack);
        h_check((s_last_ctrl & OSD_CTRL_ENABLE) != 0U, "bit0 = 1 -> menu comes back");
    }

    /* ---- 6.10：SET_IMAGE_VALUES 只改显示状态，不动路由/使能 ---- */
    {
        uint8_t ctrl_before;
        uint32_t pos_before;

        protocol_init(&stats);
        ctrl_before = s_last_ctrl;
        pos_before  = s_last_pos;
        commits = s_commit_count;

        n = engine_feed(&stats, F_UI_SET_IMG, sizeof(F_UI_SET_IMG), &resp, ack);
        h_check(n == (int)PROTOCOL_ACK_LEN && ack[6] == PROTOCOL_STATUS_OK,
                "SET_IMAGE_VALUES accepted");
        h_check(s_commit_count == commits + 1U, "values change redraws the canvas once");
        /* 只比使能位。**缓冲选择必须翻**（乒乓就是每渲染一次换一块），
         * 要求它不变等于要求禁用双缓冲 —— 首版就是这么写错的。
         * 使能位不变才是这条用例要证明的：改数值不该改变菜单的显隐。 */
        h_check((s_last_ctrl & OSD_CTRL_ENABLE) == (ctrl_before & OSD_CTRL_ENABLE),
                "SET_IMAGE_VALUES leaves CTRL.enable untouched");
        h_check(((s_last_ctrl & OSD_CTRL_BUFFER) != 0U) ==
                ((osd_engine_back_block() ^ 1) == 1),
                "SET_IMAGE_VALUES ping-pongs the buffer as usual");
        h_check(s_last_pos == pos_before,
                "SET_IMAGE_VALUES leaves the window position untouched");

        /* 越界：不渲染、不提交，四个值全部不变 */
        commits = s_commit_count;
        renders = osd_engine_render_count();
        n = engine_feed(&stats, F_UI_SET_IMG_RANGE, sizeof(F_UI_SET_IMG_RANGE),
                        &resp, ack);
        h_check(n == (int)PROTOCOL_ACK_LEN && ack[6] == PROTOCOL_STATUS_FAIL,
                "out-of-range values rejected");
        h_check(s_commit_count == commits, "rejected values do NOT commit");
        h_check(osd_engine_render_count() == renders, "rejected values do NOT render");
        /* 回读仍是上一次的合法值 */
        n = engine_feed(&stats, F_UI_QUERY, sizeof(F_UI_QUERY), &resp, ack);
        h_check(n == (int)PROTOCOL_ACK_MAX &&
                ack[11] == 0x03U && ack[12] == 0x05U &&
                ack[13] == 0x07U && ack[14] == 0x05U,
                "four values survive a rejected batch");
    }

    /* ---- 6.8：1 bit/像素的打包与"逐像素展开"参考实现逐字节一致 ---- */
    {
        const uint8_t *blk = just_rendered_block();
        uint8_t        ref[OSD_ROW_STRIDE];
        unsigned       r, gy;
        int            mismatch = 0;

        for (r = 0u; (r < OSD_GRID_ROWS) && !mismatch; r++) {
            for (gy = 0u; gy < OSD_GLYPH_H; gy++) {
                unsigned y  = r * OSD_GLYPH_H + gy;
                unsigned c;

                ref_render_row(r, gy, ref);
                for (c = 0u; c < OSD_ROW_STRIDE; c++) {
                    if (blk[y * OSD_ROW_STRIDE + c] != ref[c]) {
                        h_printf("        row y=%u byte %u: got %x want %x\n",
                                 y, c, (uint32_t)blk[y * OSD_ROW_STRIDE + c],
                                 (uint32_t)ref[c]);
                        mismatch = 1;
                        break;
                    }
                }
                if (mismatch) break;
            }
        }
        h_check(!mismatch, "1bpp packed bitmap == per-pixel expansion, byte for byte");
    }

    /* ---- 6.8/6.6：写 B 块时 A 块逐字节不变（双缓冲不被破坏） ---- */
    {
        /* 先问引擎"这一次会写哪一块"，再对**另一块**取快照。
         * 直接假定写 A 或写 B 都会写错——乒乓的下一次落点取决于此前渲染了几次。*/
        int            victim = osd_engine_back_block();
        const uint8_t *safe   = canvas_block_data(victim ^ 1);
        uint8_t        snapshot[OSD_ROW_STRIDE];
        int            same = 1;

        for (i = 0u; i < OSD_ROW_STRIDE; i++) snapshot[i] = safe[i];
        (void)engine_feed(&stats, F_UI_SET_VIEW, sizeof(F_UI_SET_VIEW), &resp, ack);
        safe = canvas_block_data(victim ^ 1);
        for (i = 0u; i < OSD_ROW_STRIDE && same; i++) {
            if (safe[i] != snapshot[i]) same = 0;
        }
        h_check(same, "the other bank is left byte-identical by a render");
    }
}


/* ===========================================================================
 * T8 回读（启动诊断用的那条路）
 *
 * 为什么单独测：canvas_read_regs() / canvas_read_block() 是本次新增的**可移植
 * 边界上的公开接口**（canvas.h）。板级那份读的是真寄存器、离机测不到；但接口的
 * **语义**可以在主机上钉死 —— 尤其是"回读出来的位域与提交时写下去的一致"这条：
 * enable/buffer 的高低位写反、或者路号用错，在上板时只表现为"诊断输出看着不对"，
 * 很难往接口实现上想。这不是假设：主机后端的初版就把 0x10/0x01（**0 路**的位）
 * 当成了菜单承载路的位，是这一组用例把它逼出来的。
 * =========================================================================== */
void test_readback(void)
{
    protocol_stats_t    stats;
    protocol_response_t resp;
    uint8_t             ack[PROTOCOL_ACK_MAX];
    static uint8_t      buf[OSD_BLOCK_BYTES];   /* 14 KB：走 .bss，别占栈 */
    canvas_regs_t       regs;
    const uint8_t      *ref;
    uint32_t            i;
    int                 n;
    int                 same;

    h_puts("T8 readback: what we read back matches what we committed\n");

    protocol_init(&stats);
    n = engine_feed(&stats, F_UI_SET_VIEW, sizeof(F_UI_SET_VIEW), &resp, ack);
    h_check(n == (int)PROTOCOL_ACK_LEN, "readback: SET_VIEW still succeeds");

    canvas_read_regs(&regs);

    /* ---- POS：只写寄存器，回读恒 0；写入值应等于 {top[11:0], left[11:0]} ---- */
    h_check(regs.pos_read == 0U, "readback: POS reads back 0 (write-only)");
    h_check(regs.pos_last == (((uint32_t)OSD_MENU_TOP << 12)
                              | (uint32_t)OSD_MENU_LEFT),
            "readback: POS last_written = {top[11:0], left[11:0]}");

    /* ---- CTRL：同上；使能位必须与那次提交一致 ---- */
    h_check(regs.ctrl_read == 0U, "readback: CTRL reads back 0 (write-only)");
    h_check(regs.ctrl_last == (uint32_t)s_last_ctrl,
            "readback: CTRL last_written matches the committed value");
    h_check((regs.ctrl_last & OSD_CTRL_ENABLE) != 0U,
            "readback: committed CTRL has enable set (flags.bit0 = 1)");

    /* ---- ACTIVE：enable 在高半字节、buffer 在低半字节，且只有菜单承载路 ---- */
    h_check(((regs.active >> 4) & 0xFU) == (0x1U << OSD_MENU_ROUTE),
            "readback: ACTIVE enable nibble holds only the menu route");
    h_check((regs.active & 0xFU) == ((s_last_ctrl & OSD_CTRL_BUFFER)
                                         ? (0x1U << OSD_MENU_ROUTE) : 0U),
            "readback: ACTIVE buffer nibble mirrors CTRL.buffer_select");
    h_check((regs.active >> 8) == 0U, "readback: ACTIVE upper bits are zero");

    /* ---- 内容回读：与 canvas_block_data() 逐字节相同 ---- */
    h_check(canvas_read_block(0, buf) == (uint32_t)OSD_BLOCK_BYTES,
            "readback: block read returns the whole block");
    ref = canvas_block_data(0);
    same = 1;
    for (i = 0u; i < (uint32_t)OSD_BLOCK_BYTES; i++) {
        if (ref[i] != buf[i]) { same = 0; break; }
    }
    h_check(same, "readback: block A content matches canvas_block_data()");

    /* ---- 两块各读各的：把 B 整块投毒，A 的回读结果不应受影响 ---- */
    poison_block(1, 0x5AU);
    (void)canvas_read_block(0, buf);
    same = 1;
    for (i = 0u; i < (uint32_t)OSD_BLOCK_BYTES; i++) {
        if (ref[i] != buf[i]) { same = 0; break; }
    }
    h_check(same, "readback: block A read is unaffected by poisoning block B");
    h_check(canvas_read_block(1, buf) == (uint32_t)OSD_BLOCK_BYTES,
            "readback: block B read returns the whole block");
    h_check(buf[0] == 0x5AU, "readback: block B read sees the poisoned bytes");

    /* ---- 诊断用的裸访问：把语义钉死。
     * 这几条的价值在于**它们是板上那套探针的离机对照**：现场看到"往返 NO MATCH"
     * 时，先看这里过不过 —— 这里过，说明接口语义没写错，问题在板上那条路。 ---- */
    h_check(canvas_bytes_written() > 2u * (uint32_t)OSD_BLOCK_BYTES,
            "readback: composer wrote bytes beyond the two boot clears");
    h_check(canvas_poke(OSD_BLOCK1_ADDR + 0x100u, 0x5A5A1234u) == 0x5A5A1234u,
            "readback: poke inside a block round-trips");
    h_check(canvas_peek(OSD_BLOCK1_ADDR + 0x100u) == 0x5A5A1234u,
            "readback: peek sees what poke wrote");
    h_check(canvas_poke(OSD_BLOCK0_ADDR + 0x101u, 0xFFFFFFFFu) == 0u,
            "readback: unaligned poke is refused");
    h_check(canvas_peek(0x00C00000u) == 0u,
            "readback: peek outside the blocks returns 0 (no fake success)");
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
    test_ui_channel();
    test_engine();
    test_readback();
}
