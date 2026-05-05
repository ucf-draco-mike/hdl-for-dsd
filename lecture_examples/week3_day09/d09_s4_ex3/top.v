// =============================================================================
// top.v — Go Board wrapper for pattern_sequencer
// Day 9 · Topic 9.4: Practical Memory Applications · Demo example 3
// =============================================================================
// Maps pattern_sequencer's 8-bit o_leds onto the 4 on-board LEDs of the
// Nandland Go Board. We OR the upper and lower nibbles together so the
// "walking 1" pattern visibly bounces left-and-right across the four LEDs.
// Used by `make prog` only; simulation drives pattern_sequencer directly.
// =============================================================================

module top (
    input  wire i_clk,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    wire [7:0] w_leds;

    pattern_sequencer #(
        .STEP_LEN   (10_000_000),   // ~0.4 s @ 25 MHz
        .PATTERN_LEN(16),
        .INIT_FILE  ("pattern.hex")
    ) u_seq (
        .i_clk  (i_clk),
        .i_reset(1'b0),
        .o_leds (w_leds)
    );

    // 8 -> 4: combine bits so the bounce is visible on the 4 board LEDs.
    assign o_led1 = w_leds[0] | w_leds[7];
    assign o_led2 = w_leds[1] | w_leds[6];
    assign o_led3 = w_leds[2] | w_leds[5];
    assign o_led4 = w_leds[3] | w_leds[4];

endmodule
