`timescale 1ns / 1ps

// Horizontally flips a 720-pixel {C,Y} YUV422 stream one line at a time.
//
// Pixels are buffered as Cb/Y0 + Cr/Y1 pairs.  Reversing individual 16-bit
// pixels would exchange Cb and Cr, so the output pair is deliberately rebuilt
// as Cb/Y1 + Cr/Y0.  Two line banks allow the following input line to be
// accepted while the preceding line is emitted in reverse pair order.
module VideoHorizontalFlipYuv422 #(
    parameter integer FRAME_WIDTH  = 720,
    parameter integer FRAME_HEIGHT = 576
) (
    input  wire        clk,
    input  wire        reset,

    input  wire [15:0] s_data,
    input  wire        s_valid,
    input  wire        s_sof,
    input  wire        s_eol,
    output wire        s_ready,

    output wire [15:0] m_data,
    output wire        m_valid,
    output wire        m_sof,
    output wire        m_eol,
    input  wire        m_ready
);
    localparam integer PAIRS_PER_LINE = FRAME_WIDTH / 2;

    reg [31:0] line_bank0 [0:PAIRS_PER_LINE-1];
    reg [31:0] line_bank1 [0:PAIRS_PER_LINE-1];

    reg        bank0_ready, bank1_ready;
    reg [9:0]  bank0_line, bank1_line;

    reg        wr_active;
    reg        wr_bank;
    reg [9:0]  wr_x;
    reg [9:0]  wr_line;
    reg [15:0] even_pixel;

    reg        rd_active;
    reg        rd_bank;
    reg [9:0]  rd_line;
    reg [8:0]  rd_pair_addr;
    reg [31:0] bank0_read_data, bank1_read_data;
    reg        rd_pair_valid;
    reg        rd_pair_phase;

    wire input_take = s_valid && s_ready;
    wire output_take = m_valid && m_ready;
    wire pair_write = input_take && wr_x[0];
    wire pair_read = rd_active && !rd_pair_valid;
    wire [31:0] selected_pair_data = rd_bank ?
                                            bank1_read_data : bank0_read_data;

    assign s_ready = wr_active;
    assign m_valid = rd_pair_valid;

    // Stored pair layout is {Cr,Y1,Cb,Y0}.  After horizontal reversal the
    // first output pixel still carries Cb and the second still carries Cr.
    assign m_data = !rd_pair_phase ?
                    {selected_pair_data[15:8], selected_pair_data[23:16]} :
                    {selected_pair_data[31:24], selected_pair_data[7:0]};
    assign m_sof = rd_pair_valid && !rd_pair_phase &&
                   (rd_line == 0) &&
                   (rd_pair_addr == PAIRS_PER_LINE-1);
    assign m_eol = rd_pair_valid && rd_pair_phase &&
                   (rd_pair_addr == 0);

    // Keep RAM writes and synchronous reads in separate, canonical processes
    // so Efinity maps both 360x32 banks into embedded RAM instead of LUT/FF
    // storage.  The selected bank remains constant for a complete line.
    always @(posedge clk) begin
        if (pair_write && !wr_bank)
            line_bank0[wr_x[9:1]] <= {s_data,even_pixel};
        if (pair_read && !rd_bank)
            bank0_read_data <= line_bank0[rd_pair_addr];
    end

    always @(posedge clk) begin
        if (pair_write && wr_bank)
            line_bank1[wr_x[9:1]] <= {s_data,even_pixel};
        if (pair_read && rd_bank)
            bank1_read_data <= line_bank1[rd_pair_addr];
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            bank0_ready <= 1'b0;
            bank1_ready <= 1'b0;
            bank0_line <= 0;
            bank1_line <= 0;
            wr_active <= 1'b1;
            wr_bank <= 1'b0;
            wr_x <= 0;
            wr_line <= 0;
            even_pixel <= 0;
            rd_active <= 1'b0;
            rd_bank <= 1'b0;
            rd_line <= 0;
            rd_pair_addr <= PAIRS_PER_LINE-1;
            rd_pair_valid <= 1'b0;
            rd_pair_phase <= 1'b0;
        end else begin
            // Allocate a free line bank to the input side.  Allocation may
            // pause at a line boundary, propagating ready/valid back-pressure.
            if (!wr_active) begin
                if (!bank0_ready && !(rd_active && !rd_bank)) begin
                    wr_active <= 1'b1;
                    wr_bank <= 1'b0;
                    wr_x <= 0;
                end else if (!bank1_ready && !(rd_active && rd_bank)) begin
                    wr_active <= 1'b1;
                    wr_bank <= 1'b1;
                    wr_x <= 0;
                end
            end

            if (input_take) begin
                if (s_sof && (wr_x == 0))
                    wr_line <= 0;

                if (!wr_x[0]) begin
                    even_pixel <= s_data;
                end

                if (s_eol || (wr_x == FRAME_WIDTH-1)) begin
                    if (wr_bank) begin
                        bank1_ready <= 1'b1;
                        bank1_line <= wr_line;
                    end else begin
                        bank0_ready <= 1'b1;
                        bank0_line <= wr_line;
                    end
                    wr_active <= 1'b0;
                    wr_x <= 0;
                    if (wr_line == FRAME_HEIGHT-1)
                        wr_line <= 0;
                    else
                        wr_line <= wr_line + 1'b1;
                end else begin
                    wr_x <= wr_x + 1'b1;
                end
            end

            // Lines are emitted in their original vertical order.  Only the
            // 360 chroma pairs inside each line are visited in reverse order.
            if (!rd_active && !rd_pair_valid) begin
                if (bank0_ready && (bank0_line == rd_line)) begin
                    rd_active <= 1'b1;
                    rd_bank <= 1'b0;
                    rd_pair_addr <= PAIRS_PER_LINE-1;
                    rd_pair_phase <= 1'b0;
                end else if (bank1_ready && (bank1_line == rd_line)) begin
                    rd_active <= 1'b1;
                    rd_bank <= 1'b1;
                    rd_pair_addr <= PAIRS_PER_LINE-1;
                    rd_pair_phase <= 1'b0;
                end
            end

            // Synchronous line-memory read.  A pair is held until both output
            // pixels have completed their valid/ready handshakes.
            if (pair_read) begin
                rd_pair_valid <= 1'b1;
                rd_pair_phase <= 1'b0;
            end else if (output_take) begin
                if (!rd_pair_phase) begin
                    rd_pair_phase <= 1'b1;
                end else begin
                    rd_pair_valid <= 1'b0;
                    rd_pair_phase <= 1'b0;
                    if (rd_pair_addr == 0) begin
                        rd_active <= 1'b0;
                        if (rd_bank)
                            bank1_ready <= 1'b0;
                        else
                            bank0_ready <= 1'b0;
                        if (rd_line == FRAME_HEIGHT-1)
                            rd_line <= 0;
                        else
                            rd_line <= rd_line + 1'b1;
                    end else begin
                        rd_pair_addr <= rd_pair_addr - 1'b1;
                    end
                end
            end
        end
    end
endmodule
