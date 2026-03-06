// =============================================================================
// Exercise 6 SOLUTION (Stretch): Up/Down Counter
// Day 4 · Sequential Logic Fundamentals
// =============================================================================
// Note: Without debouncing, button presses will cause multiple counts.
// This intentionally previews the need for Day 5's debounce module.
// =============================================================================

module updown_counter (
    input  wire i_clk,
    input  wire i_switch1,
    input  wire i_switch2,
    output wire o_segment1_a,
    output wire o_segment1_b,
    output wire o_segment1_c,
    output wire o_segment1_d,
    output wire o_segment1_e,
    output wire o_segment1_f,
    output wire o_segment1_g
);

    // Simple edge detection (imperfect without debounce)
    reg r_sw1_prev, r_sw2_prev;

    always @(posedge i_clk) begin
        r_sw1_prev <= i_switch1;
        r_sw2_prev <= i_switch2;
    end

    // Rising edge = button press (active-high)
    wire w_up_press   = ~r_sw1_prev & i_switch1;
    wire w_down_press = ~r_sw2_prev & i_switch2;

    // 4-bit counter
    reg [3:0] r_count = 4'd0;

    always @(posedge i_clk) begin
        if (w_up_press)
            r_count <= r_count + 4'd1;
        else if (w_down_press)
            r_count <= r_count - 4'd1;
    end

    // 7-segment decoder
    reg [6:0] r_seg;

    always @(*) begin
        case (r_count)
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

    assign o_segment1_a = r_seg[6];
    assign o_segment1_b = r_seg[5];
    assign o_segment1_c = r_seg[4];
    assign o_segment1_d = r_seg[3];
    assign o_segment1_e = r_seg[2];
    assign o_segment1_f = r_seg[1];
    assign o_segment1_g = r_seg[0];

endmodule
