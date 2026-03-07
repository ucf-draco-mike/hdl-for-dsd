// =============================================================================
// Exercise 6 (Stretch): Up/Down Counter with 7-Seg Display
// Day 4 · Sequential Logic Fundamentals
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Button-controlled counter displayed on 7-segment.
// sw1 = count up, sw2 = count down (raw, undebounced — will be bouncy!)
// This previews the need for debouncing (Week 2, Day 5).
// =============================================================================

module updown_counter (
    input  wire i_clk,
    input  wire i_switch1,   // count up (raw, active-high)
    input  wire i_switch2,   // count down (raw, active-high)
    output wire o_segment1_a,
    output wire o_segment1_b,
    output wire o_segment1_c,
    output wire o_segment1_d,
    output wire o_segment1_e,
    output wire o_segment1_f,
    output wire o_segment1_g
);

    // TODO:
    // 1. Simple edge detection on buttons (will be imperfect without debounce)
    // 2. 4-bit up/down counter
    // 3. 7-seg decoder
    //
    // Note: Without debouncing, the counter will sometimes skip values.
    // This is expected and motivates Day 5's debounce module!

endmodule
