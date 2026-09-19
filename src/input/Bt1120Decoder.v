// Unified 16-bit BT.1120 embedded-sync decoder.
//
// This module is the only block that recognizes SAV/EAV timing words.  It
// emits one canonical native-resolution pixel stream which may be consumed by
// independent DVP and CVBS branches without duplicating protocol state.
module Bt1120Decoder #(
    parameter integer FRAME_WIDTH  = 1280,
    parameter integer FRAME_HEIGHT = 1024
) (
    input  wire        clk,
    input  wire        reset,
    input  wire [15:0] bt_data,
    input  wire        y_from_high,

    output wire [15:0] pixel_word,
    output wire [7:0]  pixel_y,
    output wire [7:0]  pixel_c,
    output wire [10:0] pixel_x,
    output wire [10:0] pixel_line,
    output wire        pixel_valid,
    output wire        pixel_sof,
    output wire        pixel_eof,
    output wire        pixel_sol,
    output wire        pixel_eol,

    output reg         frame_active,
    output reg         sync_locked,
    output reg         protocol_error,
    output reg  [11:0] error_info
);

    localparam [1:0] TR_IDLE = 2'd0;
    localparam [1:0] TR_FF   = 2'd1;
    localparam [1:0] TR_00_1 = 2'd2;
    localparam [1:0] TR_00_2 = 2'd3;

    reg [1:0]  tr_state;
    reg        active_line;
    reg [10:0] x_count;
    reg [10:0] y_count;

    wire trs_complete = (tr_state == TR_00_2);
    wire sav_image    = trs_complete && (bt_data == 16'h8080);
    wire sav_blank    = trs_complete && (bt_data == 16'habab);
    wire eav_image    = trs_complete && (bt_data == 16'h9d9d);
    wire eav_blank    = trs_complete && (bt_data == 16'hb6b6);

    // Like the T120 sensor front end, geometry is counter-driven after the
    // line boundary has been acquired.  Do not search for a new TRS inside
    // the configured active width: full-range image samples can equal FFFF
    // and must not silently shorten the line presented to the frame writer.
    wire active_payload = active_line && (x_count < FRAME_WIDTH);
    assign pixel_valid = active_payload;
    assign pixel_word  = bt_data;
    assign pixel_y     = y_from_high ? bt_data[15:8] : bt_data[7:0];
    assign pixel_c     = y_from_high ? bt_data[7:0]  : bt_data[15:8];
    assign pixel_x     = x_count;
    assign pixel_line  = y_count;
    assign pixel_sof   = pixel_valid && (x_count == 0) && (y_count == 0);
    assign pixel_eof   = pixel_valid && (x_count == FRAME_WIDTH-1) &&
                         (y_count == FRAME_HEIGHT-1);
    assign pixel_sol   = pixel_valid && (x_count == 0);
    assign pixel_eol   = pixel_valid && (x_count == FRAME_WIDTH-1);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tr_state       <= TR_IDLE;
            active_line    <= 1'b0;
            x_count        <= 0;
            y_count        <= 0;
            frame_active   <= 1'b0;
            sync_locked    <= 1'b0;
            protocol_error <= 1'b0;
            error_info     <= 0;
        end else begin
            if (active_payload) begin
                tr_state <= TR_IDLE;
            end else begin
                case (tr_state)
                    TR_IDLE: begin
                        if (bt_data == 16'hffff)
                            tr_state <= TR_FF;
                    end
                    TR_FF: begin
                        if (bt_data == 16'h0000)
                            tr_state <= TR_00_1;
                        else if (bt_data != 16'hffff)
                            tr_state <= TR_IDLE;
                    end
                    TR_00_1: begin
                        if (bt_data == 16'h0000)
                            tr_state <= TR_00_2;
                        else if (bt_data == 16'hffff)
                            tr_state <= TR_FF;
                        else
                            tr_state <= TR_IDLE;
                    end
                    default: tr_state <= TR_IDLE;
                endcase
            end

            if (sav_blank || eav_blank) begin
                active_line  <= 1'b0;
                frame_active <= 1'b0;
                if (sav_blank)
                    y_count <= 0;
            end

            if (sav_image) begin
                active_line  <= 1'b1;
                x_count      <= 0;
                sync_locked  <= 1'b1;
                if (!frame_active) begin
                    frame_active <= 1'b1;
                    y_count      <= 0;
                end
            end else if (eav_image) begin
                if (active_line) begin
                    active_line <= 1'b0;
                    if (x_count != FRAME_WIDTH) begin
                        if (!protocol_error)
                            error_info <= {1'b0, x_count};
                        protocol_error <= 1'b1;
                    end
                    if (y_count == FRAME_HEIGHT-1) begin
                        y_count      <= 0;
                        frame_active <= 1'b0;
                    end else begin
                        y_count <= y_count + 1'b1;
                    end
                end
            end else if (active_payload) begin
                if (x_count < FRAME_WIDTH) begin
                    x_count <= x_count + 1'b1;
                end else begin
                    if (!protocol_error)
                        error_info <= {1'b1, x_count};
                    protocol_error <= 1'b1;
                end
            end
        end
    end

endmodule
