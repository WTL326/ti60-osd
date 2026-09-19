module hot_focus_haircross #(
        parameter BPS               =       8,
        parameter FRAME_WIDTH       =       640,
        parameter FRAME_HEIGHT      =       512
    )
    (
        input                                           clk,
        input                                           rst_n,

        // axi-stream-slave
        input       [3*BPS-1 : 0]                       s_axis_tdata,
        input                                           s_axis_tlast,
        input                                           s_axis_tvalid,
        input                                           s_axis_tuser,
        output                                          s_axis_tready,
        
        // axi-stream-master
        output      [3*BPS-1 : 0]                       m_axis_tdata,
        output                                          m_axis_tlast,
        output                                          m_axis_tvalid,
        input                                           m_axis_tready,
        output                                          m_axis_tuser,

        // 热点追踪地址
        input       [10 - 1 : 0]                        hot_x_pos,
        input       [9 - 1 : 0]                         hot_y_pos,

        input       [9 : 0]                             left_out,
        input       [9 : 0]                             right_out,
        input       [8 : 0]                             top_out,
        input       [8 : 0]                             bottom_out,

        input                                           no_scaler,

        input       [10 : 0]                            x_offset,
        input       [9 : 0]                             y_offset,

        input                                           hot_haircross_on,

        input                                           is_black_hot,

        input                                           if_flip_h,
        input                                           if_flip_v,

        input [2 : 0]                                   producting_model
        
    );

    localparam cross_length_half = 10;
    localparam cross_width_half = 2; 

    localparam red = {8'd81,8'd240,8'd90};
    localparam black = {8'h00,8'h80,8'h80};

	function [10-1:0] limited_add;
		input [10-1:0] a, b, limit;
		begin
			limited_add = (a + b >= limit) ? (limit - 1) : (a + b);
		end
	endfunction

	function [10-1:0] limited_sub;
		input [10-1:0] a, b;
		begin
			limited_sub = (a < b) ? 0 : (a-b);
		end
	endfunction


    wire s_fire = s_axis_tvalid & s_axis_tready;

    reg  [10 - 1 : 0]   in_hcnt;
    reg  [9 - 1 : 0]    in_vcnt;

    always@(posedge clk or negedge rst_n)
        if (!rst_n) begin
            in_hcnt <= 0;
            in_vcnt <= 0;
        end
        else if (s_fire) begin
            if (in_hcnt == FRAME_WIDTH - 1) begin
                if (in_vcnt == FRAME_HEIGHT - 1) begin
                    in_hcnt <= 0;
                    in_vcnt <= 0;
                end
                else begin
                    in_hcnt <= 0;
                    in_vcnt <= in_vcnt + 1;
                end
            end
            else begin
                in_hcnt <= in_hcnt + 1;
                in_vcnt <= in_vcnt;
            end
        end

    // 打拍同步
    reg [9 : 0] hot_x_pos_r[1:0];
    reg [8 : 0] hot_y_pos_r[1:0];

    reg [9 : 0] left_out_r[1:0];
    reg [9 : 0] right_out_r[1:0];
    reg [8 : 0] top_out_r[1:0];
    reg [8 : 0] bottom_out_r[1:0];

    reg [1 : 0] no_scaler_r;

    reg [11 : 0] x_offset_r[1:0];
    reg [10 : 0] y_offset_r[1:0];

    reg [1:0] hot_haircross_on_r;
    reg [1:0] is_black_hot_r;
    reg [1:0]if_flip_h_r;
    reg [1:0]if_flip_v_r;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            hot_x_pos_r[0]   <= 10'd0;  
            hot_x_pos_r[1]   <= 10'd0;
            hot_y_pos_r[0]   <=  9'd0;  
            hot_y_pos_r[1]   <=  9'd0;

            left_out_r[0]    <= 10'd0;  
            left_out_r[1]    <= 10'd0;
            right_out_r[0]   <= 10'd639;  
            right_out_r[1]   <= 10'd639;
            top_out_r[0]     <=  9'd0;  
            top_out_r[1]     <=  9'd0;
            bottom_out_r[0]  <=  9'd511;  
            bottom_out_r[1]  <=  9'd511;

            no_scaler_r      <=  2'd0;

            x_offset_r[0]    <= 12'd640;  
            x_offset_r[1]    <= 12'd640;
            y_offset_r[0]    <=  11'd512;  
            y_offset_r[1]    <=  11'd512;

            hot_haircross_on_r <= 2'd0;

            is_black_hot_r   <= 2'd0;

            if_flip_h_r <= 2'd0;
            if_flip_v_r <= 2'd0;

        end 
        else begin
            hot_x_pos_r[0]   <= hot_x_pos;
            hot_x_pos_r[1]   <= hot_x_pos_r[0];

            hot_y_pos_r[0]   <= hot_y_pos;
            hot_y_pos_r[1]   <= hot_y_pos_r[0];

            left_out_r[0]    <= left_out;
            left_out_r[1]    <= left_out_r[0];

            right_out_r[0]   <= right_out;
            right_out_r[1]   <= right_out_r[0];

            top_out_r[0]     <= top_out;
            top_out_r[1]     <= top_out_r[0];

            bottom_out_r[0]  <= bottom_out;
            bottom_out_r[1]  <= bottom_out_r[0];

            no_scaler_r[0]      <= no_scaler;
            no_scaler_r[1]      <= no_scaler_r[0];

            x_offset_r[0]    <= x_offset;
            x_offset_r[1]    <= x_offset_r[0];

            y_offset_r[0]    <= y_offset;
            y_offset_r[1]    <= y_offset_r[0];

            hot_haircross_on_r[0]      <= hot_haircross_on;
            hot_haircross_on_r[1]      <= hot_haircross_on_r[0];

            is_black_hot_r[0] <= is_black_hot;
            is_black_hot_r[1] <= is_black_hot_r[0];

            if_flip_h_r[0]   <= if_flip_h;
            if_flip_h_r[1]   <= if_flip_h_r[0];

            if_flip_v_r[0]   <= if_flip_v;
            if_flip_v_r[1]   <= if_flip_v_r[0];
        end
    end

    wire [10 + 10 - 1 : 0] numer_x;
    assign numer_x = (hot_x_pos_r[1] - left_out_r[1]) * 10'd639;
    wire [10 - 1 : 0] denom_x;
    assign denom_x = right_out_r[1] - left_out_r[1];

    wire [9 + 9 - 1 : 0] numer_y;
    assign numer_y = (hot_y_pos_r[1] - top_out_r[1]) * 9'd511;
    wire [9 - 1 : 0] denom_y;
    assign denom_y = bottom_out_r[1] - top_out_r[1];

    wire [10 - 1 : 0] q_x;
    wire [10 - 1 : 0] q_y;

    wire [10 - 1 : 0] q_x_consider_noscaler;
    assign q_x_consider_noscaler = no_scaler_r[1] ? hot_x_pos_r[1] : q_x;
    wire [10 - 1 : 0] q_y_consider_noscaler;
    assign q_y_consider_noscaler = no_scaler_r[1] ? hot_y_pos_r[1] : q_y;

    wire [10 - 1 : 0] q_x_consider_flip;
    assign q_x_consider_flip = if_flip_h_r[1] ? (10'd639 - q_x_consider_noscaler) : q_x_consider_noscaler;
    wire [10 - 1 : 0] q_y_consider_flip;
    assign q_y_consider_flip = if_flip_v_r[1] ? (9'd511 - q_y_consider_noscaler) : q_y_consider_noscaler;    

    localparam LPM_DREPRESENTATION  = "UNSIGNED";
    localparam LPM_HINT             = "";
    localparam LPM_NREPRESENTATION  = "UNSIGNED";
    localparam LPM_TYPE             = "LPM_DIVIDE";
    localparam LPM_PIPELINE         = 7; 
    lpm_divide#(
        .lpm_drepresentation    (LPM_DREPRESENTATION ),
        .lpm_hint               (LPM_HINT            ),
        .lpm_nrepresentation    (LPM_NREPRESENTATION ),
        .lpm_pipeline           (LPM_PIPELINE        ),
        .lpm_type               (LPM_TYPE            ),
        .lpm_widthd             (10                 ),
        .lpm_widthn             (20                 )
    )
    lpm_divide_x
    (
        .aclr          (!rst_n),
        .clken         (s_fire),
        .clock         (clk),
        .denom         (denom_x),  
        .numer         (numer_x),
        
        .quotient      (q_x),
        .remain        ()
    );    

    lpm_divide#(
        .lpm_drepresentation    (LPM_DREPRESENTATION ),
        .lpm_hint               (LPM_HINT            ),
        .lpm_nrepresentation    (LPM_NREPRESENTATION ),
        .lpm_pipeline           (LPM_PIPELINE        ),
        .lpm_type               (LPM_TYPE            ),
        .lpm_widthd             (9                  ),
        .lpm_widthn             (19                 )
    )
    lpm_divide_y
    (
        .aclr          (!rst_n),
        .clken         (s_fire),
        .clock         (clk),
        .denom         (denom_y),  
        .numer         (numer_y),
        
        .quotient      (q_y),
        .remain        ()
    ); 

    wire in_screen;
    assign in_screen = (x_offset_r[1] + q_x_consider_flip >= 10'd640) & (x_offset_r[1] + q_x_consider_flip < 11'd1280) 
                            & (y_offset_r[1] + q_y_consider_flip >= 10'd512) & (y_offset_r[1] + q_y_consider_flip < 11'd1024) 
                            & hot_haircross_on_r[1];

    wire [10 - 1 : 0] target_x;
    assign target_x = x_offset_r[1] + q_x_consider_flip - 10'd640;
    wire [10 - 1 : 0] target_y;
    assign target_y = y_offset_r[1] + q_y_consider_flip - 10'd512;

    reg in_screen_sync,is_black_hot_sync;
    reg [10 - 1 : 0]target_x_sync, target_y_sync;

    always @(posedge clk or negedge rst_n)
        if (!rst_n) begin
            in_screen_sync <= 0;
            target_x_sync <= 0;
            target_y_sync <= 0;
            is_black_hot_sync <= 0;
            
        end
        else if (s_fire & s_axis_tuser) begin
            in_screen_sync <= in_screen;
            target_x_sync <= target_x;
            target_y_sync <= target_y;
            is_black_hot_sync <= is_black_hot_r[1];
        end

    wire in_cross_h;
    assign in_cross_h = (   (in_hcnt >= limited_sub(target_x,cross_length_half)) & 
                            (in_hcnt <= limited_add(target_x,cross_length_half,FRAME_WIDTH)) &
                            (in_vcnt >= limited_sub(target_y,cross_width_half)) &
                            (in_vcnt <= limited_add(target_y,cross_width_half,FRAME_HEIGHT))
    );

    wire in_cross_v;
    assign in_cross_v = (   (in_hcnt >= limited_sub(target_x,cross_width_half)) & 
                            (in_hcnt <= limited_add(target_x,cross_width_half,FRAME_WIDTH)) &
                            (in_vcnt >= limited_sub(target_y,cross_length_half)) &
                            (in_vcnt <= limited_add(target_y,cross_length_half,FRAME_HEIGHT))
    );    

    wire is_cross;
    assign is_cross = (in_cross_h ^ in_cross_v) & in_screen_sync;


// 输出
    reg [2:0] producting_model_r[1:0];
    always@(posedge clk or negedge rst_n)
        if (!rst_n) begin
            producting_model_r[0] <= 0;
            producting_model_r[1] <= 0;
        end
        else begin
            producting_model_r[0] <= producting_model;
            producting_model_r[1] <= producting_model_r[0];
        end

    wire [3*BPS-1 : 0] m_axis_tdata_product;    // 模式0为正常模式，模式1为冷本底采集，模式2为热本底采集，模式3为处理冷热本底，模式4为自动调节工作点
    wire [3*BPS-1 : 0] cold_save;
    assign cold_save = in_hcnt[7] ? red : black;
    wire [3*BPS-1 : 0] hot_save;
    assign hot_save = in_hcnt[6] ? red : black;
    wire [3*BPS-1 : 0] computing;
    assign computing = in_hcnt[5] ? red : black;
    wire [3*BPS-1 : 0] workpoint;
    wire [BPS - 1 : 0] wenli;
    assign wenli = in_hcnt + in_vcnt;
    assign workpoint = {wenli,8'h80,8'h80};
    assign m_axis_tdata_product = (producting_model_r[1] == 4) ? workpoint : (producting_model_r[1] == 3) ? computing :(producting_model_r[1] == 2) ? hot_save : (producting_model_r[1] == 1) ? cold_save : 0;

    wire [3*BPS-1 : 0] normal = !is_cross ? s_axis_tdata : is_black_hot_sync ? {8'hFF,8'h80,8'h80} : {8'h00,8'h80,8'h80};

    assign s_axis_tready = m_axis_tready;
    assign m_axis_tdata = (producting_model_r[1] == 0) ? normal : m_axis_tdata_product;
    assign m_axis_tvalid = s_axis_tvalid;
    assign m_axis_tuser = s_axis_tuser;
    assign m_axis_tlast = s_axis_tlast;

endmodule