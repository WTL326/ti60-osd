/******************************************************************************
*
* @file frame.h: FPGA 命令帧状态机（0xBB 协议）
*
* @brief 从字节流里识别并解析出完整的命令帧。线格式为：
*
*            BB | body_length[15:8] | body_length[7:0] |
*            body | crc[15:8] | crc[7:0] | AA
*
*        其中 body = 大类 | 子项 | 类型 | payload，即：
*
*            第 0 字节   dalei  大类（功能模块）
*            第 1 字节   zixiang 子项（该大类下的命令号）
*            第 2 字节   type   类型：0x00 上位机写、0x02 设备应答
*            第 3 字节起 payload
*
*  @note 本格式的依据是 docs/测试说明.md 的「指令构成」一节，并与
*        docs/adb_test_commands.md、docs/x2000_ui_protocol.md 及
*        tools/send_*_via_adb.py 三方一致。几个要点：
*          - body_length 是 body 的字节数，**含它自己那 3 个字节的头**，
*            所以 len = 3 + payload 字节数；
*          - 多字节字段一律**大端**；
*          - CRC 只覆盖 body。
*
* @note 关于"大类"这一段的理解很关键：**大类是路由字段，不是格式标记**。
*       同一条串口线上跑着所有功能模块的帧——掩膜 0x00、电子变倍 0x01、
*       热点 0x02、伪彩色 0x03、UI 0x04。所以这一层**不做**"大类必须等于
*       某个值"的校验；它只把大类解析出来交给上层，由上层决定这一帧是不是
*       自己该管的。
*       早期版本在这里硬校验过大类必须是掩膜（0x00），那是错的：变倍或 UI 的
*       合法帧会被判成"格式错误"，那些模块的工具就会收到一个格式不符的应答，
*       反而把别人撞坏。
*
* @note 这个模块刻意做成"与硬件无关"：不 include 任何 UART、PLIC 或 BSP 头文件，
*       输入是字节、输出是"解析出一个帧"的事件。这样协议解析（最容易出错、
*       也最需要测试的部分）可以在 qemu 上喂构造好的字节数组完整验证，
*       不需要 FPGA——见 test/ 目录。
*
* @note 另一个设计点：**整帧从不缓存**。CRC 边收边算，只保留 body 头 3 个字节。
*       所以一个 4103 字节的分块帧和 4 字节的开关帧，占用 RAM 完全一样。
*
******************************************************************************/
#ifndef IVLAB_FRAME_H
#define IVLAB_FRAME_H

#include <stdint.h>

/* body_length 的合法区间。
 *
 * 下限 3：body 头本身（大类/子项/类型）就 3 个字节，比这短说明长度字段本身
 * 就是错的，或者是噪声凑出来的。
 * 上限 5000：掩膜分块默认 4096 字节 payload，对应 len = 4103；留到 5000 足够，
 * 同时防止"长度字段被噪声填成一个大数"后解析器傻等几千字节、把后续真正的
 * 命令全吞掉。*/
#define FRAME_BODY_LEN_MIN 3U
#define FRAME_BODY_LEN_MAX 5000U

/* 帧头与帧尾。
 *
 * 帧头 0xBB 用于区分 FPGA 命令帧；同一条线上还有"机芯"帧，它的帧头是 0xAA，
 * 是另一套完全独立的封装。看到 0xAA 就说明不是我们的帧，当作噪声跳过即可。*/
#define FRAME_HEADER         0xBBU
#define FRAME_FOOTER         0xAAU

/* body[2] 类型字段：0x00 表示上位机下发的写命令，0x02 表示设备应答。
 * 这一位是命令帧里**唯一**有格式约束的字段——收到一个"类型不是写命令"的帧，
 * 说明它不是发给设备的命令，属于格式错误。*/
#define FRAME_TYPE_WRITE     0x00U
#define FRAME_TYPE_ACK       0x02U

/* 功能大类（body[0]）。
 *
 * 列出全部取值是为了让代码能读懂"这一帧是谁的"，但解析层不据此拒绝任何帧。
 * 只有 MASK 一类由本应用负责。*/
#define FRAME_CATEGORY_MASK       0x00U   /* 掩膜      —— 本应用负责 */
#define FRAME_CATEGORY_EZOOM      0x01U   /* 电子变倍  —— 其他模块负责 */
#define FRAME_CATEGORY_HOT_FOCUS  0x02U   /* 热点追踪  —— 其他模块负责 */
#define FRAME_CATEGORY_PSEUDO     0x03U   /* FPGA 伪彩色 —— 其他模块负责 */
#define FRAME_CATEGORY_UI         0x04U   /* UI 菜单   —— 其他模块负责 */

/* 掩膜大类（0x00）下的子项。取值与 docs/测试说明.md 的「掩膜子项」表一致。
 * U 后缀表示无符号常量（见 crc16.c 的说明）。*/
#define FRAME_CMD_BEGIN    0x01U   /* 开始上传：width/height/total */
#define FRAME_CMD_CHUNK    0x02U   /* 分块写入：offset + 原始字节 */
#define FRAME_CMD_POSITION 0x03U   /* 设置位置：left_x / top_y */
#define FRAME_CMD_ENABLE   0x04U   /* 开关：enable */
#define FRAME_CMD_PERSIST  0x05U   /* 保存到 Flash：无 payload */

/* UI 大类（0x04）下的子项。
 *
 * 本端点只处理 0x06 / 0x07 / 0x08 / 0x09 四个；其余五个子项**只解析、不应答、不计入
 * 坏包**——它们的业务实现（按键模拟、测距标记、方位角显示……）在协议文档与
 * 两份参考实现里都不存在，本期不纳入。把这些常量收进来，是为了让"这是 UI 的
 * 哪个子项"在代码与日志里可读，不是为了处理它们。
 *
 * 依据 docs/x2000_ui_protocol.md §3 与 tools/send_ui_via_adb.py 的子项取值，
 * 两者一致；ti60-osd-main 只实现 3 个子项，不构成依据。*/
#define FRAME_CMD_UI_SHOW_HIDE        0x01U   /* 菜单显隐          —— 本期不纳入 */
#define FRAME_CMD_UI_KEY              0x02U   /* 模拟按键          —— 本期不纳入 */
#define FRAME_CMD_UI_ATTITUDE         0x03U   /* 方位角/LRF/俯仰/横滚 —— 本期不纳入 */
#define FRAME_CMD_UI_CLEAR            0x04U   /* 清除标记          —— 本期不纳入 */
#define FRAME_CMD_UI_RANGE_MARK       0x05U   /* 测距标记坐标      —— 本期不纳入 */
#define FRAME_CMD_UI_SET_VIEW         0x06U   /* 设置页面/选中项/flags */
#define FRAME_CMD_UI_SET_IMAGE_VALUES 0x07U   /* 四个图像参数 */
#define FRAME_CMD_UI_QUERY_VIEW       0x08U   /* 查询当前状态（无 payload） */

/* 设置**任意页任意条目**的运行期值（附录A 全菜单新增，2026-10-18）。
 *
 * 为什么必须新增，而不是继续用 0x07：0x07 的语义是"图像四参数"，它写死
 * image_enhance/contrast/image_brightness/screen_brightness 四项。附录A 的
 * 37 页菜单里，条目值类型有 NUM/ONOFF/ENUM/EDIT 四类、分布在几十个页面上
 * （弹道参数、校零坐标、时间日期、密码……），没有一项能塞进那四个槽位。
 * 硬把 0x07 的 payload 扩写成带 page_id 的形式，会让 0x07 的既有语义被改写、
 * 与已经发出的上位机脚本不兼容——那比多一个子项号代价大得多。
 *
 * payload（变长）：page_id:u16BE | item_idx:u8 | value…
 *   NUM / ONOFF / ENUM：value 为 1 字节
 *   EDIT              ：value 为文本字节流（截断到 OSD_EDIT_LEN-1）
 * 变长 + 末尾无长度字段，是因为帧层已经给出了 body 长度，协议层据此推算
 * value 长度——再加一个长度字节就同一份长度出现两处，改一处漏一处。 */
#define FRAME_CMD_UI_SET_ITEM_VALUE   0x09U   /* 设置条目值 */

/* payload 窗口的大小。
 *
 * 为什么需要它：UI 子项的参数全在 payload 里（SET_VIEW 的 page_id/sel/flags、
 * SET_IMAGE_VALUES 的四个数值），一个字节都不留就无从处理命令。
 * 为什么是 20：纳入范围的子项里最长的是 **0x09 SET_ITEM_VALUE**——
 * page_id(2) + item_idx(1) + EDIT 文本（最多 OSD_EDIT_LEN-1 = 15）= 18 字节；
 * 取 20 覆盖它并留 2 字节余量。（原来是 12，够当时的 0x03 方位角帧 9 字节，
 * 但装不下 EDIT 文本：日期 "2026/10/18" 要 10、坐标 "X 0320  Y 0104" 要 14，
 * 会被静默截断成 9 个字符——参数被截断比直接拒绝更难查，所以抬高而不是将就。）
 * 为什么不是"缓存整帧"：掩膜分块的 payload 是位图原始字节、可达 4096 字节，
 * 它不需要被上层看到，仍然算完即丢——"整帧不缓存"这条性质没有被破坏。
 * 抬高它只多占 frame_t / frame_parser_t 各几字节，与帧长无关，是常量开销。*/
#define FRAME_PAYLOAD_MAX 20U

/******************************************************************************
* 一个"到达帧尾"的帧的解析结果。
*
* 注意 *_ok 三个字段是独立的布尔标志（用 uint8_t 存 0 或 1），而不是一个状态
* 枚举。这样调用者可以自己决定"哪些错误可以合并处理、哪些需要分别上报"，
* 解析器不必预先替它分类。
******************************************************************************/
typedef struct {
    uint8_t  category;     /* body[0] 大类 */
    uint8_t  command;      /* body[1] 子项 */
    uint8_t  type;         /* body[2] 类型 */
    uint16_t body_length;  /* body 的字节数（含 3 字节头） */
    uint8_t  crc_ok;       /* 收到的 CRC 与本地算出的 CRC 是否相同 */
    uint8_t  footer_ok;    /* 最后一字节是否为 FRAME_FOOTER */
    uint8_t  format_ok;    /* 类型字段是否为"上位机写" */

    /* payload 的前若干字节（最多 FRAME_PAYLOAD_MAX 个）。
     * 超长帧（如掩膜分块）只留前 FRAME_PAYLOAD_MAX 个；payload_len 仍是
     * body_length-3，即"帧里声明有多少"与"本地留了多少"是两个数 ——
     * 分开表达，调用者才能判断参数是否被截断，而不是误以为 payload 就这么短。*/
    uint16_t payload_len;  /* body_length - 3 */
    uint8_t  payload[FRAME_PAYLOAD_MAX];
} frame_t;

/******************************************************************************
* 解析器的运行状态。
*
* 这个结构由调用者分配、持有，解析器本身不保存任何全局变量：一是可重入
* （将来若要同时解析两路串口就直接开两个实例），二是测试时可以随意造很多个
* 实例、互不干扰。
******************************************************************************/
typedef struct {
    uint8_t  state;        /* 当前处在状态机的哪一步 */
    uint16_t body_length;  /* 从长度字段读到的 body 字节数 */
    uint16_t body_index;   /* body 里已经收了多少字节（从 0 开始计） */
    uint16_t body_crc;     /* 边收边算的 body CRC */
    uint16_t recv_crc;     /* 从帧里读出的 CRC */
    uint8_t  category;     /* body[0] */
    uint8_t  command;      /* body[1] */
    uint8_t  type;         /* body[2] */

    /* body_length 越界时，解析器在"长度阶段"就直接拒绝、不读 body，
     * 所以这种帧根本到不了帧尾、也就不会产生应答。这个计数用于诊断。*/
    uint32_t bad_length_count;

    /* payload 窗口（见 frame_t 的同名字段）。payload_len 每帧在帧头处清零，
     * 缓冲区**不逐帧清零** —— 调用者必须先看 payload_len 再读 payload，
     * 否则看到的是上一帧的残留。这样省掉每帧 12 字节的写，且语义更严格：
     * "有几个字节有效"只由 payload_len 决定。*/
    uint16_t payload_len;
    uint8_t  payload[FRAME_PAYLOAD_MAX];
} frame_parser_t;

/******************************************************************************
* @brief 把解析器复位到"等帧头"的初始状态。
*
* @param parser 要复位的解析器。允许传 NULL（空指针），此时函数什么都不做。
*
* @note 为什么所有公开函数都要判 NULL：C 里对空指针解引用会直接跑飞（在裸机上
*       就是死机），不会有任何提示。软核没有操作系统兜底，所以对外接口都加
*       一道判断——代价是一条比较指令，换来的是"用错也不会崩"。
******************************************************************************/
void frame_parser_init(frame_parser_t *parser);

/******************************************************************************
* @brief 送入一个收到的字节，推动状态机前进一步。
*
* @param parser 解析器状态。
* @param byte   刚从串口收到的那个字节。
* @param out    当返回值为 1 时，这里会被填入解析结果。
* @return 1 表示"这一字节让一个帧到达了帧尾"，out 有效；0 表示还在收。
*
* @note 调用方式是"每收到一个字节就调一次"，而不是"攒够一帧再调"。这正是
*       流式解析：不需要缓存整帧，也不怕帧有多长。
*
* @note 重要：**body 里出现的 0xBB 是普通数据，不是帧头**。
*       掩膜分块（子项 0x02）的 payload 是位图原始字节，取值范围是整个
*       0x00–0xFF，里面完全可能出现 0xBB。如果解析器在 body 阶段一见到
*       0xBB 就当作"新帧开始"，合法的分块帧就会被从中间截断、CRC 必然算错、
*       于是每帧都被误判为坏帧，掩膜数据永远传不进来。
*       所以 body 阶段**只按 body_length 计数**，不识别任何特殊字节。
*
*       那丢字节导致失步了怎么办？靠长度字段 + CRC 两道校验来发现：一旦对齐
*       错位，CRC 必然对不上，解析器就回到"等帧头"状态，从下一个真正的 0xBB
*       重新开始。最多损失一帧，不需要重启。
******************************************************************************/
int frame_parser_feed(frame_parser_t *parser, uint8_t byte, frame_t *out);

#endif /* IVLAB_FRAME_H */
