// Native-resolution 16-bit video stream to 8-bit DVP formatter.
// The input stream cannot be back-pressured, so an overflow flag records any
// input loss while the dual-clock FIFO absorbs line blanking differences.
module DvpFormatter (
    input  wire        input_clk,
    input  wire        input_reset,
    input  wire [15:0] input_word,
    input  wire        input_valid,
    input  wire        input_sof,
    input  wire        input_eof,
    input  wire        input_sol,
    input  wire        input_eol,

    input  wire        dvp_clk,
    input  wire        dvp_reset,
    output reg         dvp_vsync,
    output wire        dvp_hsync,
    output reg         dvp_valid,
    output reg  [7:0]  dvp_data,
    output reg         dvp_clk_too_fast,
    output wire        fifo_overflow
);

    wire        fifo_ready;
    wire        fifo_valid;
    wire [19:0] fifo_data;
    reg         emit_low_byte;
    reg [7:0]   saved_low_byte;
    reg         saved_eof;
    reg         saved_eol;
    reg         line_active;
    reg         vs_fall_pending;
    reg  [8:0]  vs_fall_delay;

    // The producer and the 8-bit serializer are nominally matched at one
    // 16-bit word per two clocks.  Starting with an empty CDC FIFO leaves no
    // tolerance for pointer synchronizer latency or a single producer stall.
    // Hold each SOL word briefly so roughly 32 words accumulate before DVP
    // begins the line; normal source blanking repays this delay per line.
    reg  [6:0]  sol_prefill_count;
    reg         sol_prefill_active;
    wire        sol_at_head = fifo_valid && fifo_data[17] && !line_active;
    wire        sol_prefill_block = sol_at_head &&
                                    (!sol_prefill_active ||
                                     (sol_prefill_count != 0));
    wire        fifo_pop = fifo_valid && !emit_low_byte && !sol_prefill_block;

    // The legacy Bt1120toDvp raised VSYNC during line blanking, one line
    // before the first active byte, so receivers that latch VS while HS is
    // low saw clean edges.  Assert VS when the SOF word reaches the FIFO
    // head, i.e. during the SOL pre-fill delay while HS is still low.
    wire        sof_at_head = sol_at_head && fifo_data[19];
    wire        vs_assert_early = sof_at_head && !sol_prefill_active;

    assign dvp_hsync = line_active;

    VideoAsyncFifo #(
        .WIDTH  (20),
        .ADDR_W (11)
    ) u_dvp_cdc (
        .wr_clk   (input_clk),
        .wr_reset (input_reset),
        .wr_data  ({input_sof, input_eof, input_sol, input_eol, input_word}),
        .wr_valid (input_valid),
        .wr_ready (fifo_ready),
        .overflow (fifo_overflow),
        .rd_clk   (dvp_clk),
        .rd_reset (dvp_reset),
        .rd_data  (fifo_data),
        .rd_valid (fifo_valid),
        .rd_ready (!emit_low_byte && !sol_prefill_block)
    );

    always @(posedge dvp_clk or posedge dvp_reset) begin
        if (dvp_reset) begin
            emit_low_byte <= 1'b0;
            saved_low_byte <= 0;
            saved_eof <= 1'b0;
            saved_eol <= 1'b0;
            line_active <= 1'b0;
            dvp_vsync <= 1'b0;
            dvp_valid <= 1'b0;
            dvp_data <= 0;
            dvp_clk_too_fast <= 1'b0;
            sol_prefill_count <= 0;
            sol_prefill_active <= 1'b0;
            vs_fall_pending <= 1'b0;
            vs_fall_delay <= 0;
        end else begin
            dvp_valid <= 1'b0;

            if (vs_assert_early)
                dvp_vsync <= 1'b1;

            if (vs_fall_pending) begin
                if (vs_fall_delay == 9'd401) begin
                    dvp_vsync <= 1'b0;
                    vs_fall_pending <= 1'b0;
                end else begin
                    vs_fall_delay <= vs_fall_delay + 1'b1;
                end
            end

            if (sol_at_head && !sol_prefill_active) begin
                sol_prefill_active <= 1'b1;
                sol_prefill_count <= 7'd63;
            end else if (sol_prefill_active && sol_prefill_count != 0) begin
                sol_prefill_count <= sol_prefill_count - 1'b1;
            end

            if (!emit_low_byte) begin
                if (fifo_pop) begin
                    dvp_valid       <= 1'b1;
                    dvp_data        <= fifo_data[15:8];
                    saved_low_byte  <= fifo_data[7:0];
                    saved_eof       <= fifo_data[18];
                    saved_eol       <= fifo_data[16];
                    emit_low_byte   <= 1'b1;
                    if (fifo_data[19]) begin
                        dvp_clk_too_fast   <= 1'b0;
                    end
                    if (fifo_data[17])
                        line_active <= 1'b1;
                    if (fifo_data[17]) begin
                        sol_prefill_active <= 1'b0;
                        sol_prefill_count <= 0;
                    end
                end else if (line_active) begin
                    dvp_clk_too_fast <= 1'b1;
                end
            end else begin
                dvp_valid     <= 1'b1;
                dvp_data      <= saved_low_byte;
                emit_low_byte <= 1'b0;
                if (saved_eol)
                    line_active <= 1'b0;
                if (saved_eof) begin
                    vs_fall_pending <= 1'b1;
                    vs_fall_delay <= 0;
                end
            end
        end
    end

endmodule
