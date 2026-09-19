// Pure 2x2 box downsampler: 1280x1024 YUV422 -> 640x512 YUV422.
// BT.1120 timing recognition belongs to Bt1120Decoder; this block consumes
// only canonical active pixels and their decoded coordinates.
module Downsample2xYuv422 (
    input  wire        clk,
    input  wire        reset,
    input  wire [7:0]  in_y,
    input  wire [7:0]  in_c,
    input  wire [10:0] in_x,
    input  wire [10:0] in_line,
    input  wire        in_valid,

    output reg  [7:0]  out_y,
    output reg  [7:0]  out_c,
    output reg         out_valid,
    output reg         out_sof,
    output reg         out_eol
);

    reg [7:0] first_y;
    reg [7:0] first_c;
    reg [9:0] previous_y_pair [0:639];
    reg [8:0] previous_c_pair [0:639];
    reg [9:0] previous_y_q;
    reg [8:0] previous_c_q;
    reg [9:0] pending_y_pair;
    reg [8:0] pending_c_pair;
    reg       output_pending;
    reg       pending_sof;
    reg       pending_eol;

    wire [9:0] horizontal_y_sum = {2'b00, first_y} + {2'b00, in_y};
    // Preserve the proven chroma choice used by Bt1120Downsample2x.
    wire [7:0] selected_c = in_x[1] ? in_c : first_c;
    wire [8:0] horizontal_c_sum = {1'b0, selected_c} +
                                  {1'b0, selected_c};
    wire [10:0] four_y_sum = {1'b0, previous_y_q} +
                             {1'b0, pending_y_pair};
    wire [9:0] four_c_sum = {1'b0, previous_c_q} +
                            {1'b0, pending_c_pair};

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            first_y         <= 0;
            first_c         <= 8'h80;
            previous_y_q    <= 0;
            previous_c_q    <= 0;
            pending_y_pair  <= 0;
            pending_c_pair  <= 0;
            output_pending  <= 1'b0;
            pending_sof     <= 1'b0;
            pending_eol     <= 1'b0;
            out_y           <= 0;
            out_c           <= 8'h80;
            out_valid       <= 1'b0;
            out_sof         <= 1'b0;
            out_eol         <= 1'b0;
        end else begin
            out_valid <= 1'b0;
            out_sof   <= 1'b0;
            out_eol   <= 1'b0;

            if (output_pending) begin
                out_y          <= (four_y_sum + 11'd2) >> 2;
                out_c          <= (four_c_sum + 10'd2) >> 2;
                out_valid      <= 1'b1;
                out_sof        <= pending_sof;
                out_eol        <= pending_eol;
                output_pending <= 1'b0;
            end

            if (in_valid) begin
                previous_y_q <= previous_y_pair[in_x[10:1]];
                previous_c_q <= previous_c_pair[in_x[10:1]];

                if (!in_x[0]) begin
                    first_y <= in_y;
                    first_c <= in_c;
                end else if (!in_line[0]) begin
                    previous_y_pair[in_x[10:1]] <= horizontal_y_sum;
                    previous_c_pair[in_x[10:1]] <= horizontal_c_sum;
                end else begin
                    pending_y_pair <= horizontal_y_sum;
                    pending_c_pair <= horizontal_c_sum;
                    pending_sof <= (in_line == 11'd1) && (in_x == 11'd1);
                    pending_eol <= (in_x == 11'd1279);
                    output_pending <= 1'b1;
                end
            end
        end
    end

endmodule
