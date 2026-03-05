// =============================================================================
// Exercise 1: LED On — The Simplest Possible Design
// Day 1 · Welcome to Hardware Thinking
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Goal: Drive LED1 permanently on. Confirm the full toolchain works.
//
// Go Board: LEDs are active low (0 = on, 1 = off)
// =============================================================================

module led_on (
    output wire o_led1
);

    // Drive LED1 on: active low means assign 0 to turn on
    assign o_led1 = 1'b0;

endmodule
