// =============================================================================
// top_pattern.v — Go Board Top Level for Pattern Detector (Starter)
// Day 7, Exercise 2
// =============================================================================

module top_pattern (
    input  wire i_clk,
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,  // reset
    output wire o_led1,     // progress bit 1
    output wire o_led2,     // progress bit 0
    output wire o_led3,     // heartbeat
    output wire o_led4      // DETECTED!
);

    // ---- TODO: Debounce all 4 buttons ----
    wire w_sw1_clean, w_sw2_clean, w_sw3_clean, w_reset_clean;

    // debounce #(.CLKS_TO_STABLE(250_000)) db1 (...);
    // debounce #(.CLKS_TO_STABLE(250_000)) db2 (...);
    // debounce #(.CLKS_TO_STABLE(250_000)) db3 (...);
    // debounce #(.CLKS_TO_STABLE(250_000)) db_reset (...);

    // ---- TODO: Edge detect on buttons 1-3 ----
    // reg r_sw1_prev, r_sw2_prev, r_sw3_prev;
    // wire w_btn1 = w_sw1_clean & ~r_sw1_prev;  // rising edge = press
    // wire w_btn2 = w_sw2_clean & ~r_sw2_prev;
    // wire w_btn3 = w_sw3_clean & ~r_sw3_prev;

    // ---- TODO: Instantiate pattern_detector ----
    wire w_detected;
    wire [1:0] w_progress;

    // pattern_detector pd (...);

    // ---- TODO: Map outputs to LEDs ----
    // assign o_led1 = w_progress[1];    // active-high LED
    // assign o_led2 = w_progress[0];
    // assign o_led4 = w_detected;

    // Heartbeat
    reg [23:0] r_hb;
    always @(posedge i_clk) r_hb <= r_hb + 1;
    assign o_led3 = r_hb[23];

endmodule
