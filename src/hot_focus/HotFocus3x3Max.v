`timescale 1ns / 1ps

// Frame-based 3x3 luminance tracker for the 1280x1024 pre-zoom stream.
// The public result changes only when the next frame reaches the calculation
// pipeline, so a crosshair can use it for a whole frame without tearing.
module HotFocus3x3Max #(
    parameter integer DATA_WIDTH   = 8,
    parameter integer FRAME_WIDTH  = 1280,
    parameter integer FRAME_HEIGHT = 1024,
    parameter integer X_WIDTH      = 11,
    parameter integer Y_WIDTH      = 10
) (
    input  wire                  clk,
    input  wire                  reset,
    input  wire [DATA_WIDTH-1:0] pixel_y,
    input  wire                  pixel_valid,
    input  wire                  pixel_sof,
    input  wire                  pixel_sol,
    input  wire                  pixel_eol,
    input  wire                  pixel_drop_epoch,
    input  wire                  enable,
    input  wire                  polarity_black_hot,
    input  wire [X_WIDTH-1:0]    roi_left,
    input  wire [X_WIDTH-1:0]    roi_right,
    input  wire [Y_WIDTH-1:0]    roi_top,
    input  wire [Y_WIDTH-1:0]    roi_bottom,
    output reg  [X_WIDTH-1:0]    hot_x,
    output reg  [Y_WIDTH-1:0]    hot_y,
    output reg  [DATA_WIDTH+3:0] hot_sum,
    output reg                   hot_valid,
    output reg  [15:0]           result_count,
    output reg  [15:0]           dropped_result_count
);
    wire pixel_fire = pixel_valid;
    reg [X_WIDTH-1:0] x_count;
    reg [Y_WIDTH-1:0] y_count;
    wire [X_WIDTH-1:0] current_x = (pixel_sof || pixel_sol) ? 0 : x_count;
    wire [Y_WIDTH-1:0] current_y = pixel_sof ? 0 : y_count;

    reg frame_enable;
    reg frame_polarity;
    reg [X_WIDTH-1:0] frame_left, frame_right;
    reg [Y_WIDTH-1:0] frame_top, frame_bottom;
    reg frame_epoch;
    reg frame_corrupt;
    reg completed_frame_corrupt;

    wire [DATA_WIDTH-1:0] row_1_raw;
    wire [DATA_WIDTH-1:0] row_2;
    HotFocusLineBufTi60 #(
        .DATA_WIDTH(DATA_WIDTH), .FRAME_WIDTH(FRAME_WIDTH),
        .ADDR_WIDTH(X_WIDTH)
    ) u_line_1 (
        .clk(clk), .enable(pixel_fire), .address(current_x),
        .data_in(pixel_y), .data_out(row_1_raw)
    );

    reg [DATA_WIDTH-1:0] pixel_y_stage1;
    reg [X_WIDTH-1:0] pixel_x_stage1;
    reg [Y_WIDTH-1:0] pixel_y_coord_stage1;
    reg pixel_stage1_valid, pixel_stage1_sof;
    reg pixel_stage1_enable, pixel_stage1_polarity, pixel_stage1_in_roi;

    HotFocusLineBufTi60 #(
        .DATA_WIDTH(DATA_WIDTH), .FRAME_WIDTH(FRAME_WIDTH),
        .ADDR_WIDTH(X_WIDTH)
    ) u_line_2 (
        .clk(clk), .enable(pixel_stage1_valid), .address(pixel_x_stage1),
        .data_in(row_1_raw), .data_out(row_2)
    );

    reg [DATA_WIDTH-1:0] pixel_y_q;
    reg [DATA_WIDTH-1:0] row_1_q;
    reg [X_WIDTH-1:0] pixel_x_q;
    reg [Y_WIDTH-1:0] pixel_y_coord_q;
    reg pixel_q_valid, pixel_q_sof, pixel_q_enable, pixel_q_polarity;
    reg pixel_q_in_roi;

    wire [X_WIDTH-1:0] selected_left = pixel_sof ? roi_left : frame_left;
    wire [X_WIDTH-1:0] selected_right = pixel_sof ? roi_right : frame_right;
    wire [Y_WIDTH-1:0] selected_top = pixel_sof ? roi_top : frame_top;
    wire [Y_WIDTH-1:0] selected_bottom = pixel_sof ? roi_bottom : frame_bottom;
    wire selected_enable = pixel_sof ? enable : frame_enable;
    wire selected_polarity = pixel_sof ? polarity_black_hot : frame_polarity;
    wire [X_WIDTH-1:0] current_center_x = current_x - 1'b1;
    wire [Y_WIDTH-1:0] current_center_y = current_y - 1'b1;
    wire current_window_complete = (current_x >= 2) && (current_y >= 2);
    wire current_in_roi = current_window_complete &&
        (current_center_x >= selected_left) &&
        (current_center_x <= selected_right) &&
        (current_center_y >= selected_top) &&
        (current_center_y <= selected_bottom);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x_count <= 0; y_count <= 0;
            frame_enable <= 1'b0; frame_polarity <= 1'b0;
            frame_left <= 0; frame_right <= FRAME_WIDTH-1;
            frame_top <= 0; frame_bottom <= FRAME_HEIGHT-1;
            frame_epoch <= 0; frame_corrupt <= 1'b0;
            completed_frame_corrupt <= 1'b1;
            pixel_y_stage1 <= 0; pixel_x_stage1 <= 0;
            pixel_y_coord_stage1 <= 0; pixel_stage1_valid <= 1'b0;
            pixel_stage1_sof <= 1'b0; pixel_stage1_enable <= 1'b0;
            pixel_stage1_polarity <= 1'b0; pixel_stage1_in_roi <= 1'b0;
            pixel_y_q <= 0; row_1_q <= 0;
            pixel_x_q <= 0; pixel_y_coord_q <= 0;
            pixel_q_valid <= 1'b0; pixel_q_sof <= 1'b0;
            pixel_q_enable <= 1'b0; pixel_q_polarity <= 1'b0;
            pixel_q_in_roi <= 1'b0;
        end else begin
            pixel_stage1_valid <= pixel_fire;
            pixel_q_valid <= pixel_stage1_valid;
            if (pixel_stage1_valid) begin
                pixel_y_q <= pixel_y_stage1;
                row_1_q <= row_1_raw;
                pixel_x_q <= pixel_x_stage1;
                pixel_y_coord_q <= pixel_y_coord_stage1;
                pixel_q_sof <= pixel_stage1_sof;
                pixel_q_enable <= pixel_stage1_enable;
                pixel_q_polarity <= pixel_stage1_polarity;
                pixel_q_in_roi <= pixel_stage1_in_roi;
            end else begin
                pixel_q_sof <= 1'b0;
            end
            if (pixel_fire) begin
                pixel_y_stage1 <= pixel_y;
                pixel_x_stage1 <= current_x;
                pixel_y_coord_stage1 <= current_y;
                pixel_stage1_sof <= pixel_sof;
                pixel_stage1_enable <= selected_enable;
                pixel_stage1_polarity <= selected_polarity;
                pixel_stage1_in_roi <= current_in_roi;

                if (pixel_sof) begin
                    completed_frame_corrupt <= frame_corrupt;
                    frame_corrupt <= 1'b0;
                    frame_epoch <= pixel_drop_epoch;
                    frame_enable <= enable;
                    frame_polarity <= polarity_black_hot;
                    frame_left <= roi_left; frame_right <= roi_right;
                    frame_top <= roi_top; frame_bottom <= roi_bottom;
                end else if (pixel_drop_epoch != frame_epoch) begin
                    frame_corrupt <= 1'b1;
                end

                if (pixel_eol) begin
                    x_count <= 0;
                    if (current_y == FRAME_HEIGHT-1)
                        y_count <= 0;
                    else
                        y_count <= current_y + 1'b1;
                end else begin
                    x_count <= current_x + 1'b1;
                    y_count <= current_y;
                end
            end
        end
    end

    wire [DATA_WIDTH-1:0] w11, w12, w13, w21, w22, w23, w31, w32, w33;
    window_mean #(.WIDTH(DATA_WIDTH)) u_window (
        .clk(clk), .reset(reset), .in_valid(pixel_q_valid),
        .line_start(pixel_x_q == 0),
        .w1_in(row_2), .w2_in(row_1_q), .w3_in(pixel_y_q),
        .w11(w11), .w12(w12), .w13(w13),
        .w21(w21), .w22(w22), .w23(w23),
        .w31(w31), .w32(w32), .w33(w33)
    );

    wire [DATA_WIDTH+3:0] filter_sum;
    wire filter_valid;
    Filter_Function_mean #(.WIDTH(DATA_WIDTH)) u_sum (
        .clk(clk), .reset(reset), .in_valid(pixel_q_valid),
        .w11(w11), .w12(w12), .w13(w13),
        .w21(w21), .w22(w22), .w23(w23),
        .w31(w31), .w32(w32), .w33(w33),
        .data_sum_3x3(filter_sum), .out_valid(filter_valid)
    );

    reg [X_WIDTH-1:0] meta_x [0:3];
    reg [Y_WIDTH-1:0] meta_y [0:3];
    reg [3:0] meta_sof, meta_enable, meta_polarity, meta_in_roi;
    integer meta_index;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            meta_sof <= 0; meta_enable <= 0;
            meta_polarity <= 0; meta_in_roi <= 0;
            for (meta_index = 0; meta_index < 4; meta_index = meta_index+1) begin
                meta_x[meta_index] <= 0;
                meta_y[meta_index] <= 0;
            end
        end else begin
            meta_sof <= {meta_sof[2:0], pixel_q_valid && pixel_q_sof};
            meta_enable <= {meta_enable[2:0], pixel_q_enable};
            meta_polarity <= {meta_polarity[2:0], pixel_q_polarity};
            meta_in_roi <= {meta_in_roi[2:0], pixel_q_in_roi};
            meta_x[0] <= pixel_x_q - 1'b1;
            meta_y[0] <= pixel_y_coord_q - 1'b1;
            for (meta_index = 1; meta_index < 4; meta_index = meta_index+1) begin
                meta_x[meta_index] <= meta_x[meta_index-1];
                meta_y[meta_index] <= meta_y[meta_index-1];
            end
        end
    end

    reg [DATA_WIDTH+3:0] candidate_sum;
    reg [X_WIDTH-1:0] candidate_x;
    reg [Y_WIDTH-1:0] candidate_y;
    reg candidate_valid;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            candidate_sum <= 0; candidate_x <= 0; candidate_y <= 0;
            candidate_valid <= 1'b0;
            hot_x <= 0; hot_y <= 0; hot_sum <= 0;
            hot_valid <= 1'b0;
            result_count <= 0; dropped_result_count <= 0;
        end else if (filter_valid) begin
            if (meta_sof[3]) begin
                if (candidate_valid && !completed_frame_corrupt) begin
                    hot_x <= candidate_x;
                    hot_y <= candidate_y;
                    hot_sum <= candidate_sum;
                    hot_valid <= 1'b1;
                    result_count <= result_count + 1'b1;
                end else if (candidate_valid && completed_frame_corrupt) begin
                    // Keep the last complete result visible.  A damaged
                    // source frame must neither move nor hide the crosshair.
                    dropped_result_count <= dropped_result_count + 1'b1;
                end else begin
                    hot_valid <= 1'b0;
                end
                candidate_valid <= 1'b0;
            end

            if (!meta_sof[3] && meta_enable[3] && meta_in_roi[3]) begin
                if (!candidate_valid ||
                    (!meta_polarity[3] && (filter_sum > candidate_sum)) ||
                    ( meta_polarity[3] && (filter_sum < candidate_sum))) begin
                    candidate_sum <= filter_sum;
                    candidate_x <= meta_x[3];
                    candidate_y <= meta_y[3];
                    candidate_valid <= 1'b1;
                end
            end
        end
    end
endmodule
