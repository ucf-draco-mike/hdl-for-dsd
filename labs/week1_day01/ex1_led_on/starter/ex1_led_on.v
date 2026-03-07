// =============================================================================
// Exercise 1: LED On — The Simplest Possible Design
// Day 1 · Welcome to Hardware Thinking
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Goal: Drive LED1 permanently on. Confirm the full toolchain works.
//
// Go Board: LEDs are active-high (1 = on, 0 = off)
// =============================================================================

module led_on (
    output wire o_led1
);

    // Drive LED1 on: active-high means assign 1 to turn on
    assign o_led1 = 1'b1;

endmodule
