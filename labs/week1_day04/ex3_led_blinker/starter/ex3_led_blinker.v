// =============================================================================
// Exercise 3: Free-Running Counter + LED Blinker
// Day 4 · Sequential Logic Fundamentals
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// The Go Board has a 25 MHz clock. To blink an LED at ~1 Hz:
//   25,000,000 / 2 = 12,500,000 cycles per half-period
//   Need a counter that counts to 12,500,000 - 1, then toggles
//
// Part A: Single LED blink at ~1 Hz
// Part B: Multi-speed — different LEDs from different counter bits
// =============================================================================

module led_blinker (
    input  wire i_clk,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // TODO: Create a 24-bit counter
    // reg [23:0] r_counter = 24'd0;
    //
    // always @(posedge i_clk) begin
    //     r_counter <= r_counter + 24'd1;
    // end

    // TODO: Toggle an LED register at terminal count
    // Or simpler: just use counter bits directly!
    //
    // Part B (multi-speed):
    //   o_led1 <- r_counter[23]  (~1.5 Hz)
    //   o_led2 <- r_counter[22]  (~3 Hz)
    //   o_led3 <- r_counter[21]  (~6 Hz)
    //   o_led4 <- r_counter[20]  (~12 Hz)

    // Placeholder — replace with your implementation
    assign o_led1 = 1'b0;
    assign o_led2 = 1'b0;
    assign o_led3 = 1'b0;
    assign o_led4 = 1'b0;

endmodule
