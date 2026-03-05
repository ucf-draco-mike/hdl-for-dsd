// =============================================================================
// Exercise 4 SOLUTION: 7-Segment Counter (Week 1 Capstone)
// Day 4 · Sequential Logic Fundamentals
// =============================================================================

module seg_counter (
    input  wire i_clk,
    output wire o_led1,
    output wire o_segment1_a,
    output wire o_segment1_b,
    output wire o_segment1_c,
    output wire o_segment1_d,
    output wire o_segment1_e,
    output wire o_segment1_f,
    output wire o_segment1_g
);

    // Clock divider: ~2 Hz tick
    reg [23:0] r_clk_count = 24'd0;
    reg        r_tick      = 1'b0;

    always @(posedge i_clk) begin
        if (r_clk_count == 24'd12_499_999) begin
            r_clk_count <= 24'd0;
            r_tick      <= 1'b1;
        end else begin
            r_clk_count <= r_clk_count + 24'd1;
            r_tick      <= 1'b0;
        end
    end

    // 4-bit display counter
    reg [3:0] r_display = 4'd0;

    always @(posedge i_clk) begin
        if (r_tick)
            r_display <= r_display + 4'd1;
    end

    // 7-segment decoder (inline)
    reg [6:0] r_seg;

    always @(*) begin
        case (r_display)
            4'h0: r_seg = 7'b0000001;  4'h1: r_seg = 7'b1001111;
            4'h2: r_seg = 7'b0010010;  4'h3: r_seg = 7'b0000110;
            4'h4: r_seg = 7'b1001100;  4'h5: r_seg = 7'b0100100;
            4'h6: r_seg = 7'b0100000;  4'h7: r_seg = 7'b0001111;
            4'h8: r_seg = 7'b0000000;  4'h9: r_seg = 7'b0000100;
            4'hA: r_seg = 7'b0001000;  4'hB: r_seg = 7'b1100000;
            4'hC: r_seg = 7'b0110001;  4'hD: r_seg = 7'b1000010;
            4'hE: r_seg = 7'b0110000;  4'hF: r_seg = 7'b0111000;
            default: r_seg = 7'b1111111;
        endcase
    end

    // Heartbeat
    assign o_led1 = ~r_clk_count[22];

    // Segment outputs
    assign o_segment1_a = r_seg[6];
    assign o_segment1_b = r_seg[5];
    assign o_segment1_c = r_seg[4];
    assign o_segment1_d = r_seg[3];
    assign o_segment1_e = r_seg[2];
    assign o_segment1_f = r_seg[1];
    assign o_segment1_g = r_seg[0];

endmodule
