// =============================================================================
// button_counter.v — Debounced Button Counter (Provided)
// Day 5, Exercise 3
// =============================================================================
// This module is provided complete. Your task:
//   1. Build and program it — verify clean counting (0..F)
//   2. Modify to bypass debounce — observe erratic counting
//   3. Record your comparison results

module button_counter (
    input  wire i_clk,
    input  wire i_switch1,   // reset
    input  wire i_switch2,   // count button
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f,
    output wire o_segment1_g,
    output wire o_led1       // heartbeat
);

    // --- Debounce both buttons ---
    wire w_reset_clean, w_count_clean;

    debounce #(.CLKS_TO_STABLE(250_000)) db_reset (
        .i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(w_reset_clean)
    );
    debounce #(.CLKS_TO_STABLE(250_000)) db_count (
        .i_clk(i_clk), .i_bouncy(i_switch2), .o_clean(w_count_clean)
    );

    // --- Edge detector: press = rising edge of active-high ---
    reg r_count_prev;
    always @(posedge i_clk)
        r_count_prev <= w_count_clean;

    wire w_count_press = w_count_clean & ~r_count_prev;

    // --- 4-bit counter ---
    wire w_reset = w_reset_clean;
    reg [3:0] r_count;

    always @(posedge i_clk) begin
        if (w_reset)
            r_count <= 4'd0;
        else if (w_count_press)
            r_count <= r_count + 4'd1;
    end

    // --- 7-segment display ---
    wire [6:0] w_seg;
    hex_to_7seg decoder (.i_hex(r_count), .o_seg(w_seg));

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f,
            o_segment1_g} = w_seg;

    // --- Heartbeat ---
    reg [23:0] r_hb_count;
    always @(posedge i_clk)
        r_hb_count <= r_hb_count + 1;
    assign o_led1 = r_hb_count[23];

endmodule
