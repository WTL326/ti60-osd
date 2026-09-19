// Flat, scalable read/write-decoupled arbiter for the Efinix HyperRAM shared
// AXI3 port.
//
// The controller exposes one shared address channel (arw), but separate W/B and
// R channels with independent buffering.  Keep one read burst and one write
// burst outstanding independently so a stalled read consumer cannot hold the
// write side of the fabric idle.  The shared address channel alternates between
// ready read/write candidates; the physical HyperRAM controller remains free to
// serialize bus activity internally.
//
// Grant contract:
//   * at most one read owner and one write owner exist at a time;
//   * each owner is retained through RLAST or WLAST+B respectively;
//   * read and write requests have independent weighted round-robin histories;
//   * adding a client only widens the packed buses and appends one WEIGHTS entry.
module AxiSharedFlatFabric #(
    parameter integer PORTS = 6,
    parameter integer DATA_WIDTH = 128,
    parameter integer STRB_WIDTH = DATA_WIDTH/8,
    parameter integer ID_WIDTH = 8,
    // Eight bits of weight per port, port 0 in the least-significant slice.
    parameter [PORTS*8-1:0] WEIGHTS = {PORTS{8'd1}}
) (
    input  wire                         clk,
    input  wire                         reset,

    input  wire [PORTS-1:0]             m_a_valid,
    output wire [PORTS-1:0]             m_a_ready,
    input  wire [PORTS*32-1:0]          m_a_addr,
    input  wire [PORTS*ID_WIDTH-1:0]    m_a_id,
    input  wire [PORTS*8-1:0]           m_a_len,
    input  wire [PORTS*3-1:0]           m_a_size,
    input  wire [PORTS*2-1:0]           m_a_burst,
    input  wire [PORTS*2-1:0]           m_a_lock,
    input  wire [PORTS-1:0]             m_a_write,

    input  wire [PORTS-1:0]             m_w_valid,
    output wire [PORTS-1:0]             m_w_ready,
    input  wire [PORTS*DATA_WIDTH-1:0]  m_w_data,
    input  wire [PORTS*STRB_WIDTH-1:0]  m_w_strb,
    input  wire [PORTS-1:0]             m_w_last,

    output wire [PORTS-1:0]             m_b_valid,
    input  wire [PORTS-1:0]             m_b_ready,
    output wire [PORTS*ID_WIDTH-1:0]    m_b_id,

    output wire [PORTS-1:0]             m_r_valid,
    input  wire [PORTS-1:0]             m_r_ready,
    output wire [PORTS*DATA_WIDTH-1:0]  m_r_data,
    output wire [PORTS*ID_WIDTH-1:0]    m_r_id,
    output wire [PORTS*2-1:0]           m_r_resp,
    output wire [PORTS-1:0]             m_r_last,

    output wire                         s_a_valid,
    input  wire                         s_a_ready,
    output wire [31:0]                  s_a_addr,
    output wire [ID_WIDTH-1:0]          s_a_id,
    output wire [7:0]                   s_a_len,
    output wire [2:0]                   s_a_size,
    output wire [1:0]                   s_a_burst,
    output wire [1:0]                   s_a_lock,
    output wire                         s_a_write,

    output wire                         s_w_valid,
    input  wire                         s_w_ready,
    output wire [DATA_WIDTH-1:0]        s_w_data,
    output wire [STRB_WIDTH-1:0]        s_w_strb,
    output wire                         s_w_last,
    output wire [ID_WIDTH-1:0]          s_w_id,

    input  wire                         s_b_valid,
    output wire                         s_b_ready,
    input  wire [ID_WIDTH-1:0]          s_b_id,

    input  wire                         s_r_valid,
    output wire                         s_r_ready,
    input  wire [DATA_WIDTH-1:0]        s_r_data,
    input  wire [ID_WIDTH-1:0]          s_r_id,
    input  wire [1:0]                   s_r_resp,
    input  wire                         s_r_last
);
    localparam integer OWNER_WIDTH = (PORTS <= 1) ? 1 : $clog2(PORTS);

    reg                       read_busy;
    reg [OWNER_WIDTH-1:0]     read_owner;
    reg [OWNER_WIDTH-1:0]     read_last_owner;
    reg [7:0]                 read_owner_run_count;

    reg                       write_busy;
    reg [OWNER_WIDTH-1:0]     write_owner;
    reg [OWNER_WIDTH-1:0]     write_last_owner;
    reg [7:0]                 write_owner_run_count;
    reg [ID_WIDTH-1:0]        write_owner_id;
    reg       b_pending;
    reg [ID_WIDTH-1:0] b_id_hold;
    reg       write_data_done;
    reg       last_addr_write;

    wire [PORTS-1:0] read_request  = m_a_valid & ~m_a_write;
    wire [PORTS-1:0] write_request = m_a_valid &  m_a_write;
    wire [7:0] read_last_weight =
        WEIGHTS[read_last_owner*8 +: 8];
    wire [7:0] write_last_weight =
        WEIGHTS[write_last_owner*8 +: 8];

    // Independent round-robin candidates.  Constant loop bounds plus found
    // flags are intentional: Efinity rejects variable-assignment loop breaks.
    reg [OWNER_WIDTH-1:0] read_choice;
    reg read_found;
    reg [OWNER_WIDTH-1:0] write_choice;
    reg write_found;
    integer ci;
    always @* begin
        read_choice = {OWNER_WIDTH{1'b0}};
        read_found  = 1'b0;
        if (!read_busy && read_request[read_last_owner] &&
            (read_owner_run_count < read_last_weight)) begin
            read_choice = read_last_owner;
            read_found  = 1'b1;
        end else if (!read_busy) begin
            for (ci = 0; ci < PORTS; ci = ci + 1) begin
                if (!read_found &&
                    read_request[(read_last_owner + 1 + ci) % PORTS]) begin
                    read_choice = (read_last_owner + 1 + ci) % PORTS;
                    read_found  = 1'b1;
                end
            end
        end
    end

    integer wi;
    always @* begin
        write_choice = {OWNER_WIDTH{1'b0}};
        write_found  = 1'b0;
        if (!write_busy && write_request[write_last_owner] &&
            (write_owner_run_count < write_last_weight)) begin
            write_choice = write_last_owner;
            write_found  = 1'b1;
        end else if (!write_busy) begin
            for (wi = 0; wi < PORTS; wi = wi + 1) begin
                if (!write_found &&
                    write_request[(write_last_owner + 1 + wi) % PORTS]) begin
                    write_choice = (write_last_owner + 1 + wi) % PORTS;
                    write_found  = 1'b1;
                end
            end
        end
    end

    // The controller has one combined address channel.  Alternate direction
    // when both candidates are ready so neither read nor write addresses can
    // starve.  Per-direction ownership remains independent after acceptance.
    reg addr_select_write;
    always @* begin
        if (read_found && write_found)
            addr_select_write = !last_addr_write;
        else
            addr_select_write = write_found;
    end

    wire [OWNER_WIDTH-1:0] addr_choice =
        addr_select_write ? write_choice : read_choice;
    assign s_a_valid = addr_select_write ? write_found : read_found;
    assign s_a_addr  = m_a_addr[addr_choice*32 +: 32];
    assign s_a_id    = m_a_id[addr_choice*ID_WIDTH +: ID_WIDTH];
    assign s_a_len   = m_a_len[addr_choice*8 +: 8];
    assign s_a_size  = m_a_size[addr_choice*3 +: 3];
    assign s_a_burst = m_a_burst[addr_choice*2 +: 2];
    assign s_a_lock  = m_a_lock[addr_choice*2 +: 2];
    assign s_a_write = addr_select_write;

    genvar gp;
    generate
        for (gp = 0; gp < PORTS; gp = gp + 1) begin : g_aready
            assign m_a_ready[gp] =
                s_a_valid && (addr_choice == gp) && s_a_ready;
        end
    endgenerate

    assign s_w_valid = write_busy && !write_data_done &&
                       m_w_valid[write_owner];
    assign s_w_data  = m_w_data[write_owner*DATA_WIDTH +: DATA_WIDTH];
    assign s_w_strb  = m_w_strb[write_owner*STRB_WIDTH +: STRB_WIDTH];
    assign s_w_last  = m_w_last[write_owner];
    // The write id must match the address id of the granted transaction; latch
    // it at grant time so a deasserting master cannot disturb it mid-burst.
    assign s_w_id    = write_owner_id;

    generate
        for (gp = 0; gp < PORTS; gp = gp + 1) begin : g_wready
            assign m_w_ready[gp] =
                write_busy && !write_data_done &&
                (write_owner == gp) && s_w_ready;
        end
    endgenerate

    // There is at most one transaction per direction, so responses route to the
    // retained directional owners and no ID remapping is required.
    assign s_b_ready = write_busy && !b_pending;
    generate
        for (gp = 0; gp < PORTS; gp = gp + 1) begin : g_bvalid
            assign m_b_valid[gp] =
                write_busy && (write_owner == gp) && b_pending;
        end
    endgenerate
    assign m_b_id = {PORTS{b_id_hold}};
    wire owner_b_ready = m_b_ready[write_owner];

    generate
        for (gp = 0; gp < PORTS; gp = gp + 1) begin : g_rvalid
            assign m_r_valid[gp] =
                read_busy && (read_owner == gp) && s_r_valid;
        end
    endgenerate
    assign m_r_data = {PORTS{s_r_data}};
    assign m_r_id   = {PORTS{s_r_id}};
    assign m_r_resp = {PORTS{s_r_resp}};
    assign m_r_last = {PORTS{s_r_last}};
    assign s_r_ready = read_busy && m_r_ready[read_owner];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            read_busy             <= 1'b0;
            read_owner            <= {OWNER_WIDTH{1'b0}};
            read_last_owner       <= PORTS - 1;
            read_owner_run_count  <= 8'd0;
            write_busy            <= 1'b0;
            write_owner           <= {OWNER_WIDTH{1'b0}};
            write_last_owner      <= PORTS - 1;
            write_owner_run_count <= 8'd0;
            write_owner_id        <= {ID_WIDTH{1'b0}};
            b_pending             <= 1'b0;
            b_id_hold             <= {ID_WIDTH{1'b0}};
            write_data_done       <= 1'b0;
            last_addr_write       <= 1'b1;
        end else begin
            if (write_busy && s_w_valid && s_w_ready && s_w_last)
                write_data_done <= 1'b1;
            if (write_busy && s_b_valid && s_b_ready) begin
                b_pending <= 1'b1;
                b_id_hold <= s_b_id;
            end

            if (s_a_valid && s_a_ready) begin
                last_addr_write <= s_a_write;
                if (s_a_write) begin
                    write_busy     <= 1'b1;
                    write_owner    <= write_choice;
                    write_owner_id <= s_a_id;
                    if (write_choice == write_last_owner)
                        write_owner_run_count <= write_owner_run_count + 1'b1;
                    else
                        write_owner_run_count <= 8'd1;
                    write_last_owner <= write_choice;
                    write_data_done <= 1'b0;
                end else begin
                    read_busy  <= 1'b1;
                    read_owner <= read_choice;
                    if (read_choice == read_last_owner)
                        read_owner_run_count <= read_owner_run_count + 1'b1;
                    else
                        read_owner_run_count <= 8'd1;
                    read_last_owner <= read_choice;
                end
            end

            if (read_busy && s_r_valid && s_r_ready && s_r_last)
                read_busy <= 1'b0;

            if (write_busy && b_pending && owner_b_ready) begin
                b_pending       <= 1'b0;
                write_data_done <= 1'b0;
                write_busy      <= 1'b0;
            end
        end
    end
endmodule
