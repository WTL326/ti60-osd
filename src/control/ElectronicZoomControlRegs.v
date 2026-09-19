`timescale 1ns / 1ps

// TI60 electronic-zoom register endpoint.
//
// +0x00 X_ZONE = {left[15:0], right[15:0]}
// +0x04 Y_ZONE = {top [15:0], bottom[15:0]} (atomic commit)
// +0x08 STATUS  = {accepted_count, rejected_count[13:0], pending, enable}
// +0x0c COUNTERS= {accepted_count, rejected_count}
// +0x10 APPLIED_X-compatible command snapshot
// +0x14 APPLIED_Y-compatible command snapshot
//
// The first two registers retain the T120 ZOOM_ADDR software contract.  The
// horizontal ROI is expanded outwards to an even origin and even width so a
// YUV422 Cb/Cr pair is never phase-shifted by a command.
module ElectronicZoomControlRegs (
    input  wire        clk,
    input  wire        reset,

    input  wire [7:0]  s_awid,
    input  wire [31:0] s_awaddr,
    input  wire [7:0]  s_awlen,
    input  wire [2:0]  s_awsize,
    input  wire        s_awvalid,
    output wire        s_awready,
    input  wire [31:0] s_wdata,
    input  wire [3:0]  s_wstrb,
    input  wire        s_wlast,
    input  wire        s_wvalid,
    output wire        s_wready,
    output wire [7:0]  s_bid,
    output wire [1:0]  s_bresp,
    output wire        s_bvalid,
    input  wire        s_bready,
    input  wire [7:0]  s_arid,
    input  wire [31:0] s_araddr,
    input  wire [7:0]  s_arlen,
    input  wire [2:0]  s_arsize,
    input  wire        s_arvalid,
    output wire        s_arready,
    output wire [7:0]  s_rid,
    output wire [31:0] s_rdata,
    output wire [1:0]  s_rresp,
    output wire        s_rlast,
    output wire        s_rvalid,
    input  wire        s_rready,

    output reg         cfg_enable,
    output reg  [10:0] cfg_left,
    output reg  [10:0] cfg_top,
    output reg  [10:0] cfg_width,
    output reg  [10:0] cfg_height,
    output reg         cfg_toggle,
    input  wire        applied_toggle,
    output reg  [15:0] accepted_count,
    output reg  [15:0] rejected_count
);
    wire        write_pulse;
    wire [31:0] write_addr;
    wire [31:0] write_data;
    wire [3:0]  write_strb;
    wire [31:0] read_addr;
    reg  [31:0] read_data;

    reg [31:0] x_zone;
    reg [31:0] y_zone;

    function [31:0] merge_wstrb;
        input [31:0] old_value;
        input [31:0] new_value;
        input [3:0] byte_enable;
        integer i;
        begin
            merge_wstrb = old_value;
            for (i = 0; i < 4; i = i + 1)
                if (byte_enable[i])
                    merge_wstrb[i*8 +: 8] = new_value[i*8 +: 8];
        end
    endfunction

    wire [31:0] merged_x = merge_wstrb(x_zone, write_data, write_strb);
    wire [31:0] merged_y = merge_wstrb(y_zone, write_data, write_strb);
    wire [15:0] candidate_left   = x_zone[31:16];
    wire [15:0] candidate_right  = x_zone[15:0];
    wire [15:0] candidate_top    = merged_y[31:16];
    wire [15:0] candidate_bottom = merged_y[15:0];
    wire geometry_valid = (candidate_left < candidate_right) &&
                          (candidate_top < candidate_bottom) &&
                          (candidate_right < 16'd1280) &&
                          (candidate_bottom < 16'd1024);
    wire [10:0] aligned_left  = {candidate_left[10:1], 1'b0};
    wire [10:0] aligned_right = {candidate_right[10:1], 1'b1};
    wire [11:0] aligned_width = {1'b0, aligned_right} -
                                {1'b0, aligned_left} + 12'd1;
    wire [11:0] candidate_height =
        {1'b0, candidate_bottom[10:0]} -
        {1'b0, candidate_top[10:0]} + 12'd1;
    wire pending = cfg_toggle ^ applied_toggle;

    AxiSingleBeatEndpoint u_endpoint (
        .clk(clk), .reset(reset),
        .s_awid(s_awid), .s_awaddr(s_awaddr), .s_awlen(s_awlen),
        .s_awsize(s_awsize), .s_awvalid(s_awvalid), .s_awready(s_awready),
        .s_wdata(s_wdata), .s_wstrb(s_wstrb), .s_wlast(s_wlast),
        .s_wvalid(s_wvalid), .s_wready(s_wready),
        .s_bid(s_bid), .s_bresp(s_bresp), .s_bvalid(s_bvalid),
        .s_bready(s_bready),
        .s_arid(s_arid), .s_araddr(s_araddr), .s_arlen(s_arlen),
        .s_arsize(s_arsize), .s_arvalid(s_arvalid), .s_arready(s_arready),
        .s_rid(s_rid), .s_rdata(s_rdata), .s_rresp(s_rresp),
        .s_rlast(s_rlast), .s_rvalid(s_rvalid), .s_rready(s_rready),
        .write_pulse(write_pulse), .write_addr(write_addr),
        .write_data(write_data), .write_strb(write_strb),
        .write_resp(2'b00), .read_addr(read_addr),
        .read_data(read_data), .read_resp(2'b00)
    );

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            x_zone <= {16'd0, 16'd1279};
            y_zone <= {16'd0, 16'd1023};
            cfg_enable <= 1'b0;
            cfg_left <= 11'd0;
            cfg_top <= 11'd0;
            cfg_width <= 11'd1280;
            cfg_height <= 11'd1024;
            cfg_toggle <= 1'b0;
            accepted_count <= 16'd0;
            rejected_count <= 16'd0;
        end else if (write_pulse) begin
            case (write_addr[11:2])
                10'd0: x_zone <= merged_x;
                10'd1: begin
                    y_zone <= merged_y;
                    if (pending) begin
                        // Keep the current snapshot stable until the video
                        // domain acknowledges it.
                        rejected_count <= rejected_count + 1'b1;
                    end else if (geometry_valid) begin
                        cfg_left <= aligned_left;
                        cfg_top <= candidate_top[10:0];
                        cfg_width <= aligned_width[10:0];
                        cfg_height <= candidate_height[10:0];
                        cfg_enable <= !((aligned_left == 0) &&
                                        (aligned_right == 1279) &&
                                        (candidate_top == 0) &&
                                        (candidate_bottom == 1023));
                        cfg_toggle <= ~cfg_toggle;
                        accepted_count <= accepted_count + 1'b1;
                    end else begin
                        rejected_count <= rejected_count + 1'b1;
                    end
                end
                default: begin end
            endcase
        end
    end

    always @(*) begin
        case (read_addr[11:2])
            10'd0: read_data = x_zone;
            10'd1: read_data = y_zone;
            10'd2: read_data = {accepted_count, rejected_count[13:0],
                                pending, cfg_enable};
            10'd3: read_data = {accepted_count, rejected_count};
            10'd4: read_data = {5'd0, cfg_left,
                                5'd0, cfg_left + cfg_width - 1'b1};
            10'd5: read_data = {5'd0, cfg_top,
                                5'd0, cfg_top + cfg_height - 1'b1};
            default: read_data = 32'd0;
        endcase
    end
endmodule
