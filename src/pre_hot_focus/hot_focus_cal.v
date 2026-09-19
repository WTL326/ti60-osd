module hot_focus_cal #(
        parameter BPS               =       14,
        parameter FRAME_WIDTH       =       640,
        parameter FRAME_HEIGHT      =       512
    )
    (
        input                                           clk,
        input                                           rst_n,

        // axi-stream-slave
        input       [BPS-1 : 0]                         s_axis_tdata,
        input                                           s_axis_tlast,
        input                                           s_axis_tvalid,
        input                                           s_axis_tuser,
        output                                          s_axis_tready,
        
        // axi-stream-master
        output      [BPS-1 : 0]                         m_axis_tdata,
        output                                          m_axis_tlast,
        output                                          m_axis_tvalid,
        input                                           m_axis_tready,
        output                                          m_axis_tuser,

        // 热点追踪地址
        output      [10 - 1 : 0]                        hot_x_pos,
        output      [9 - 1 : 0]                         hot_y_pos,

        input       [9 : 0]                             left_out,
        input       [9 : 0]                             right_out,
        input       [8 : 0]                             top_out,
        input       [8 : 0]                             bottom_out,

        input                                           no_scaler
    );


    reg [1 : 0] no_scaler_r;
    always@(posedge clk or negedge rst_n)
        if (!rst_n) begin
            no_scaler_r <= 0;
        end
        else begin
            no_scaler_r <= {no_scaler_r[0],no_scaler};
        end

    // 设置axis
    assign s_axis_tready = m_axis_tready;
    assign m_axis_tdata = s_axis_tdata;
    assign m_axis_tvalid = s_axis_tvalid;
    assign m_axis_tuser = s_axis_tuser;
    assign m_axis_tlast = s_axis_tlast;

    wire s_fire = s_axis_tvalid & s_axis_tready;

    wire [9 : 0] left_out_true = ((FRAME_WIDTH == 384) & no_scaler_r[1])? 10'd0 : left_out;
    wire [9 : 0] right_out_true = ((FRAME_WIDTH == 384) & no_scaler_r[1])? 10'd383 : right_out;
    wire [8 : 0] top_out_true = ((FRAME_WIDTH == 384) & no_scaler_r[1])? 9'd0 : top_out;
    wire [8 : 0] bottom_out_true = ((FRAME_WIDTH == 384) & no_scaler_r[1])? 9'd287 : bottom_out;

    add_up_3x3_max #(
        .DATA_WIDTH     (BPS),
        .FRAME_WIDTH    (FRAME_WIDTH),
        .FRAME_HEIGHT   (FRAME_HEIGHT)
    ) u_add_up_3x3_max (
        .clk        (clk),
        .rst_n      (rst_n),

        .in_valid   (s_fire),
        .in_data    (s_axis_tdata),

        .out_x      (hot_x_pos),
        .out_y      (hot_y_pos),

        .top_out            (top_out_true),
        .bottom_out         (bottom_out_true),
        .left_out           (left_out_true),
        .right_out          (right_out_true)        

    );
    
endmodule