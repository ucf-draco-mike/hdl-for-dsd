// =============================================================================
// Exercise 2: Buttons to LEDs — Wires in Hardware
// Day 1 · Welcome to Hardware Thinking
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Goal: Wire each button directly to its corresponding LED using assign.
//
// Go Board: Buttons and LEDs are both active-high.
//   Button pressed = 0, LED on = 0
//   Direct connection gives intuitive behavior (press → light)
// =============================================================================

module buttons_to_leds (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // Direct connection: each button drives its LED
    // Both are active high, so this gives intuitive behavior
    assign o_led1 = i_switch1;
    assign o_led2 = i_switch2;
    assign o_led3 = i_switch3;
    assign o_led4 = i_switch4;

endmodule
