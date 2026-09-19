`timescale 1ns / 1ps

// Small, reusable AXI4 endpoint front-end for memory-mapped control registers.
//
// The Sapphire peripheral bridge emits single-beat accesses, but AXI permits
// AW and W to arrive independently.  This block queues one address and one
// data beat, returns exactly one B response, and holds R/B until accepted.
// Bursts are acknowledged with SLVERR and are never presented to the register
// logic.  The downstream register bank is combinational on read and consumes
// a one-cycle write_pulse.
module AxiSingleBeatEndpoint #(
    parameter integer ADDR_WIDTH = 32,
    parameter integer DATA_WIDTH = 32,
    parameter integer ID_WIDTH   = 8
) (
    input  wire                  clk,
    input  wire                  reset,

    input  wire [ID_WIDTH-1:0]   s_awid,
    input  wire [ADDR_WIDTH-1:0] s_awaddr,
    input  wire [7:0]            s_awlen,
    input  wire [2:0]            s_awsize,
    input  wire                  s_awvalid,
    output wire                  s_awready,

    input  wire [DATA_WIDTH-1:0] s_wdata,
    input  wire [DATA_WIDTH/8-1:0] s_wstrb,
    input  wire                  s_wlast,
    input  wire                  s_wvalid,
    output wire                  s_wready,

    output reg  [ID_WIDTH-1:0]   s_bid,
    output reg  [1:0]            s_bresp,
    output reg                   s_bvalid,
    input  wire                  s_bready,

    input  wire [ID_WIDTH-1:0]   s_arid,
    input  wire [ADDR_WIDTH-1:0] s_araddr,
    input  wire [7:0]            s_arlen,
    input  wire [2:0]            s_arsize,
    input  wire                  s_arvalid,
    output wire                  s_arready,

    output reg  [ID_WIDTH-1:0]   s_rid,
    output reg  [DATA_WIDTH-1:0] s_rdata,
    output reg  [1:0]            s_rresp,
    output reg                   s_rlast,
    output reg                   s_rvalid,
    input  wire                  s_rready,

    output wire                  write_pulse,
    output wire [ADDR_WIDTH-1:0] write_addr,
    output wire [DATA_WIDTH-1:0] write_data,
    output wire [DATA_WIDTH/8-1:0] write_strb,
    input  wire [1:0]            write_resp,

    output wire [ADDR_WIDTH-1:0] read_addr,
    input  wire [DATA_WIDTH-1:0] read_data,
    input  wire [1:0]            read_resp
);
    localparam [2:0] EXPECTED_SIZE = $clog2(DATA_WIDTH/8);

    reg                  aw_pending;
    reg [ID_WIDTH-1:0]   awid_q;
    reg [ADDR_WIDTH-1:0] awaddr_q;
    reg [7:0]            awlen_q;
    reg [2:0]            awsize_q;

    reg                    w_pending;
    reg [DATA_WIDTH-1:0]   wdata_q;
    reg [DATA_WIDTH/8-1:0] wstrb_q;
    reg                    wlast_q;

    wire write_complete = aw_pending && w_pending && !s_bvalid;
    wire write_well_formed = (awlen_q == 0) &&
                             (awsize_q == EXPECTED_SIZE) && wlast_q;

    assign s_awready = !aw_pending && !s_bvalid;
    assign s_wready  = !w_pending && !s_bvalid;
    assign s_arready = !s_rvalid;

    assign write_pulse = write_complete && write_well_formed;
    assign write_addr  = awaddr_q;
    assign write_data  = wdata_q;
    assign write_strb  = wstrb_q;
    assign read_addr   = s_araddr;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            aw_pending <= 1'b0;
            awid_q <= {ID_WIDTH{1'b0}};
            awaddr_q <= {ADDR_WIDTH{1'b0}};
            awlen_q <= 8'd0;
            awsize_q <= 3'd0;
            w_pending <= 1'b0;
            wdata_q <= {DATA_WIDTH{1'b0}};
            wstrb_q <= {(DATA_WIDTH/8){1'b0}};
            wlast_q <= 1'b0;
            s_bid <= {ID_WIDTH{1'b0}};
            s_bresp <= 2'b00;
            s_bvalid <= 1'b0;
        end else begin
            if (s_awvalid && s_awready) begin
                aw_pending <= 1'b1;
                awid_q <= s_awid;
                awaddr_q <= s_awaddr;
                awlen_q <= s_awlen;
                awsize_q <= s_awsize;
            end

            if (s_wvalid && s_wready) begin
                w_pending <= 1'b1;
                wdata_q <= s_wdata;
                wstrb_q <= s_wstrb;
                wlast_q <= s_wlast;
            end

            if (s_bvalid && s_bready)
                s_bvalid <= 1'b0;

            if (write_complete) begin
                aw_pending <= 1'b0;
                w_pending <= 1'b0;
                s_bid <= awid_q;
                s_bresp <= write_well_formed ? write_resp : 2'b10;
                s_bvalid <= 1'b1;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            s_rid <= {ID_WIDTH{1'b0}};
            s_rdata <= {DATA_WIDTH{1'b0}};
            s_rresp <= 2'b00;
            s_rlast <= 1'b1;
            s_rvalid <= 1'b0;
        end else begin
            if (s_rvalid && s_rready)
                s_rvalid <= 1'b0;

            if (s_arvalid && s_arready) begin
                s_rid <= s_arid;
                s_rdata <= read_data;
                s_rresp <= ((s_arlen == 0) &&
                            (s_arsize == EXPECTED_SIZE)) ? read_resp : 2'b10;
                s_rlast <= 1'b1;
                s_rvalid <= 1'b1;
            end
        end
    end
endmodule
