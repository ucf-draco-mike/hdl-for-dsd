// =============================================================================
// Exercise 5: Dual-Speed Blinker
// Day 4 · Sequential Logic Fundamentals
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Two independent clock dividers driving two LED pairs at different rates.
// =============================================================================

module dual_blinker (
    input  wire i_clk,
    output wire o_led1,    // ~1 Hz
    output wire o_led2,    // ~1 Hz (inverted)
    output wire o_led3,    // ~4 Hz
    output wire o_led4     // ~4 Hz (inverted)
);

    // TODO: Counter 1 — ~1 Hz (count to ~12.5M)
    // TODO: Counter 2 — ~4 Hz (count to ~3.125M)
    // LED pairs show complementary patterns (one on, one off)

    assign o_led1 = 1'b0;  // TODO
    assign o_led2 = 1'b0;  // TODO
    assign o_led3 = 1'b0;  // TODO
    assign o_led4 = 1'b0;  // TODO

endmodule
