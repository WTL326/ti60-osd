`timescale 1ns / 1ps

// Transaction-level arbiter for the AXI3-shared interface used by the
// Efinix HyperRAM controller.  At most one burst is outstanding, so IDs do
// not need to be remapped.  Master 0 is the live video DMA, master 1 is the
// mask reader and master 2 is reserved for the Sapphire io_ddrA port.
module AxiShared3Arbiter #(
    parameter DATA_WIDTH = 128,
    parameter STRB_WIDTH = DATA_WIDTH/8,
    // Number of consecutive complete bursts granted while a master remains
    // valid.  All weights at one preserve the original round-robin behavior.
    parameter integer M0_WEIGHT = 1,
    parameter integer M1_WEIGHT = 1,
    parameter integer M2_WEIGHT = 1
) (
    input  wire clk,
    input  wire reset,

    input  wire m0_a_valid, output wire m0_a_ready,
    input  wire [31:0] m0_a_addr, input wire [7:0] m0_a_id,
    input  wire [7:0] m0_a_len, input wire [2:0] m0_a_size,
    input  wire [1:0] m0_a_burst, input wire [1:0] m0_a_lock,
    input  wire m0_a_write,
    input  wire m0_w_valid, output wire m0_w_ready,
    input  wire [7:0] m0_w_id, input wire [DATA_WIDTH-1:0] m0_w_data,
    input  wire [STRB_WIDTH-1:0] m0_w_strb, input wire m0_w_last,
    output wire m0_b_valid, input wire m0_b_ready, output wire [7:0] m0_b_id,
    output wire m0_r_valid, input wire m0_r_ready,
    output wire [DATA_WIDTH-1:0] m0_r_data, output wire [7:0] m0_r_id,
    output wire [1:0] m0_r_resp, output wire m0_r_last,

    input  wire m1_a_valid, output wire m1_a_ready,
    input  wire [31:0] m1_a_addr, input wire [7:0] m1_a_id,
    input  wire [7:0] m1_a_len, input wire [2:0] m1_a_size,
    input  wire [1:0] m1_a_burst, input wire [1:0] m1_a_lock,
    input  wire m1_a_write,
    input  wire m1_w_valid, output wire m1_w_ready,
    input  wire [7:0] m1_w_id, input wire [DATA_WIDTH-1:0] m1_w_data,
    input  wire [STRB_WIDTH-1:0] m1_w_strb, input wire m1_w_last,
    output wire m1_b_valid, input wire m1_b_ready, output wire [7:0] m1_b_id,
    output wire m1_r_valid, input wire m1_r_ready,
    output wire [DATA_WIDTH-1:0] m1_r_data, output wire [7:0] m1_r_id,
    output wire [1:0] m1_r_resp, output wire m1_r_last,

    input  wire m2_a_valid, output wire m2_a_ready,
    input  wire [31:0] m2_a_addr, input wire [7:0] m2_a_id,
    input  wire [7:0] m2_a_len, input wire [2:0] m2_a_size,
    input  wire [1:0] m2_a_burst, input wire [1:0] m2_a_lock,
    input  wire m2_a_write,
    input  wire m2_w_valid, output wire m2_w_ready,
    input  wire [7:0] m2_w_id, input wire [DATA_WIDTH-1:0] m2_w_data,
    input  wire [STRB_WIDTH-1:0] m2_w_strb, input wire m2_w_last,
    output wire m2_b_valid, input wire m2_b_ready, output wire [7:0] m2_b_id,
    output wire m2_r_valid, input wire m2_r_ready,
    output wire [DATA_WIDTH-1:0] m2_r_data, output wire [7:0] m2_r_id,
    output wire [1:0] m2_r_resp, output wire m2_r_last,

    output wire s_a_valid, input wire s_a_ready,
    output wire [31:0] s_a_addr, output wire [7:0] s_a_id,
    output wire [7:0] s_a_len, output wire [2:0] s_a_size,
    output wire [1:0] s_a_burst, output wire [1:0] s_a_lock,
    output wire s_a_write,
    output wire s_w_valid, input wire s_w_ready,
    output wire [7:0] s_w_id, output wire [DATA_WIDTH-1:0] s_w_data,
    output wire [STRB_WIDTH-1:0] s_w_strb, output wire s_w_last,
    input  wire s_b_valid, output wire s_b_ready, input wire [7:0] s_b_id,
    input  wire s_r_valid, output wire s_r_ready,
    input  wire [DATA_WIDTH-1:0] s_r_data, input wire [7:0] s_r_id,
    input  wire [1:0] s_r_resp, input wire s_r_last
);
    localparam ST_IDLE = 2'd0, ST_READ = 2'd1, ST_WRITE = 2'd2;
    reg [1:0] state;
    reg [1:0] owner;
    reg [1:0] last_owner;
    reg [7:0] owner_run_count;
    // Buffer the write response.  The HyperRAM wrapper may present BVALID
    // before the selected master raises BREADY; forwarding it combinationally
    // can leave the arbiter permanently in ST_WRITE.  Accept the response as
    // soon as it is available and hold it until its owner consumes it.
    reg       b_pending;
    reg [7:0] b_id_hold;
    // AXI write data and write response are independent channels.  Once the
    // current burst's WLAST is accepted, do not leave WREADY asserted while
    // waiting for BVALID: a pipelined master is allowed to present the next
    // transaction's first W beat early, and consuming it here would orphan
    // the next write address permanently.
    reg       write_data_done;

    // Round-robin choice is only changed between complete bursts.  This is
    // important because video, mask and CPU may reuse the same AXI ID values.
    reg [1:0] choice;
    always @* begin
        choice = 2'd3;
        if ((last_owner == 2'd0) && m0_a_valid &&
            (owner_run_count < M0_WEIGHT)) begin
            choice = 2'd0;
        end else if ((last_owner == 2'd1) && m1_a_valid &&
                     (owner_run_count < M1_WEIGHT)) begin
            choice = 2'd1;
        end else if ((last_owner == 2'd2) && m2_a_valid &&
                     (owner_run_count < M2_WEIGHT)) begin
            choice = 2'd2;
        end else begin
            case (last_owner)
              2'd0: begin
                  if (m1_a_valid) choice = 2'd1;
                  else if (m2_a_valid) choice = 2'd2;
                  else if (m0_a_valid) choice = 2'd0;
              end
              2'd1: begin
                  if (m2_a_valid) choice = 2'd2;
                  else if (m0_a_valid) choice = 2'd0;
                  else if (m1_a_valid) choice = 2'd1;
              end
              default: begin
                  if (m0_a_valid) choice = 2'd0;
                  else if (m1_a_valid) choice = 2'd1;
                  else if (m2_a_valid) choice = 2'd2;
              end
            endcase
        end
    end

    wire idle_m0 = (state == ST_IDLE) && (choice == 2'd0);
    wire idle_m1 = (state == ST_IDLE) && (choice == 2'd1);
    wire idle_m2 = (state == ST_IDLE) && (choice == 2'd2);

    assign s_a_valid = idle_m0 ? m0_a_valid : idle_m1 ? m1_a_valid :
                       idle_m2 ? m2_a_valid : 1'b0;
    assign s_a_addr  = idle_m0 ? m0_a_addr  : idle_m1 ? m1_a_addr  : m2_a_addr;
    assign s_a_id    = idle_m0 ? m0_a_id    : idle_m1 ? m1_a_id    : m2_a_id;
    assign s_a_len   = idle_m0 ? m0_a_len   : idle_m1 ? m1_a_len   : m2_a_len;
    assign s_a_size  = idle_m0 ? m0_a_size  : idle_m1 ? m1_a_size  : m2_a_size;
    assign s_a_burst = idle_m0 ? m0_a_burst : idle_m1 ? m1_a_burst : m2_a_burst;
    assign s_a_lock  = idle_m0 ? m0_a_lock  : idle_m1 ? m1_a_lock  : m2_a_lock;
    assign s_a_write = idle_m0 ? m0_a_write : idle_m1 ? m1_a_write : m2_a_write;

    assign m0_a_ready = idle_m0 && s_a_ready;
    assign m1_a_ready = idle_m1 && s_a_ready;
    assign m2_a_ready = idle_m2 && s_a_ready;

    assign s_w_valid = (state == ST_WRITE) && !write_data_done &&
                       ((owner == 0) ? m0_w_valid : (owner == 1) ? m1_w_valid : m2_w_valid);
    assign s_w_id   = (owner == 0) ? m0_w_id   : (owner == 1) ? m1_w_id   : m2_w_id;
    assign s_w_data = (owner == 0) ? m0_w_data : (owner == 1) ? m1_w_data : m2_w_data;
    assign s_w_strb = (owner == 0) ? m0_w_strb : (owner == 1) ? m1_w_strb : m2_w_strb;
    assign s_w_last = (owner == 0) ? m0_w_last : (owner == 1) ? m1_w_last : m2_w_last;
    assign m0_w_ready = (state == ST_WRITE) && !write_data_done &&
                        (owner == 0) && s_w_ready;
    assign m1_w_ready = (state == ST_WRITE) && !write_data_done &&
                        (owner == 1) && s_w_ready;
    assign m2_w_ready = (state == ST_WRITE) && !write_data_done &&
                        (owner == 2) && s_w_ready;

    assign m0_b_valid = (state == ST_WRITE) && (owner == 0) && b_pending;
    assign m1_b_valid = (state == ST_WRITE) && (owner == 1) && b_pending;
    assign m2_b_valid = (state == ST_WRITE) && (owner == 2) && b_pending;
    assign m0_b_id = b_id_hold; assign m1_b_id = b_id_hold; assign m2_b_id = b_id_hold;
    assign s_b_ready = (state == ST_WRITE) && !b_pending;

    wire owner_b_ready = (owner == 0) ? m0_b_ready :
                         (owner == 1) ? m1_b_ready : m2_b_ready;

    assign m0_r_valid = (state == ST_READ) && (owner == 0) && s_r_valid;
    assign m1_r_valid = (state == ST_READ) && (owner == 1) && s_r_valid;
    assign m2_r_valid = (state == ST_READ) && (owner == 2) && s_r_valid;
    assign m0_r_data = s_r_data; assign m1_r_data = s_r_data; assign m2_r_data = s_r_data;
    assign m0_r_id = s_r_id; assign m1_r_id = s_r_id; assign m2_r_id = s_r_id;
    assign m0_r_resp = s_r_resp; assign m1_r_resp = s_r_resp; assign m2_r_resp = s_r_resp;
    assign m0_r_last = s_r_last; assign m1_r_last = s_r_last; assign m2_r_last = s_r_last;
    assign s_r_ready = (state == ST_READ) &&
                       ((owner == 0) ? m0_r_ready : (owner == 1) ? m1_r_ready : m2_r_ready);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= ST_IDLE;
            owner <= 2'd0;
            last_owner <= 2'd2;
            owner_run_count <= M2_WEIGHT;
            b_pending <= 1'b0;
            b_id_hold <= 8'd0;
            write_data_done <= 1'b0;
        end else begin
            if ((state == ST_WRITE) && s_w_valid && s_w_ready && s_w_last)
                write_data_done <= 1'b1;
            if ((state == ST_WRITE) && s_b_valid && s_b_ready) begin
                b_pending <= 1'b1;
                b_id_hold <= s_b_id;
            end
            if ((state == ST_IDLE) && s_a_valid && s_a_ready) begin
                owner <= choice;
                if (choice == last_owner)
                    owner_run_count <= owner_run_count + 1'b1;
                else
                    owner_run_count <= 8'd1;
                last_owner <= choice;
                state <= s_a_write ? ST_WRITE : ST_READ;
                if (s_a_write)
                    write_data_done <= 1'b0;
            end else if ((state == ST_READ) && s_r_valid && s_r_ready && s_r_last) begin
                state <= ST_IDLE;
            end else if ((state == ST_WRITE) && b_pending && owner_b_ready) begin
                b_pending <= 1'b0;
                write_data_done <= 1'b0;
                state <= ST_IDLE;
            end
        end
    end
endmodule
