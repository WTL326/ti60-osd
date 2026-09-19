`timescale 1ns / 1ps

// Coherent multi-bit configuration transfer using a request/acknowledge
// toggle.  src_data must remain stable while src_toggle != src_ack_toggle;
// the AXI register endpoints enforce that rule by rejecting another commit.
//
// The destination latches a complete snapshot and raises dst_pending.  The
// consumer asserts dst_apply only at its safe boundary.  The acknowledge is
// returned after that boundary, so software STATUS.pending has useful
// frame-level meaning rather than merely reporting synchronizer arrival.
module ConfigSnapshotCdc #(
    parameter integer WIDTH = 1
) (
    input  wire             src_clk,
    input  wire             src_reset,
    input  wire [WIDTH-1:0] src_data,
    input  wire             src_toggle,
    output wire             src_ack_toggle,

    input  wire             dst_clk,
    input  wire             dst_reset,
    output reg  [WIDTH-1:0] dst_data,
    output reg              dst_pending,
    input  wire             dst_apply,
    output reg              dst_apply_pulse
);
    (* async_reg = "true" *) reg [WIDTH-1:0] data_meta;
    (* async_reg = "true" *) reg [WIDTH-1:0] data_sync;
    (* async_reg = "true" *) reg [1:0] request_sync;
    reg request_seen;
    reg ack_toggle_dst;
    (* async_reg = "true" *) reg [1:0] ack_sync;

    assign src_ack_toggle = ack_sync[1];

    always @(posedge dst_clk or posedge dst_reset) begin
        if (dst_reset) begin
            data_meta <= {WIDTH{1'b0}};
            data_sync <= {WIDTH{1'b0}};
            request_sync <= 2'b00;
            request_seen <= 1'b0;
            ack_toggle_dst <= 1'b0;
            dst_data <= {WIDTH{1'b0}};
            dst_pending <= 1'b0;
            dst_apply_pulse <= 1'b0;
        end else begin
            data_meta <= src_data;
            data_sync <= data_meta;
            request_sync <= {request_sync[0], src_toggle};
            dst_apply_pulse <= 1'b0;

            if (!dst_pending && request_sync[1] != request_seen) begin
                dst_data <= data_sync;
                request_seen <= request_sync[1];
                dst_pending <= 1'b1;
            end

            if (dst_pending && dst_apply) begin
                dst_pending <= 1'b0;
                ack_toggle_dst <= request_seen;
                dst_apply_pulse <= 1'b1;
            end
        end
    end

    always @(posedge src_clk or posedge src_reset) begin
        if (src_reset)
            ack_sync <= 2'b00;
        else
            ack_sync <= {ack_sync[0], ack_toggle_dst};
    end
endmodule
