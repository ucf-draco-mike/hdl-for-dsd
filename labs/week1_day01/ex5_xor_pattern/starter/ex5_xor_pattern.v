// =============================================================================
// Exercise 5 (Stretch): XOR Pattern
// Day 1 · Welcome to Hardware Thinking
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Goal: Create interesting LED patterns using gate combinations.
//
// Challenge: Make each LED respond to a UNIQUE combination of buttons.
// =============================================================================

module xor_pattern (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // Invert at boundary (active-high internally)
    wire w_b1 = i_switch1;
    wire w_b2 = i_switch2;
    wire w_b3 = i_switch3;
    wire w_b4 = i_switch4;

    // TODO: Design 4 unique logic functions
    // Ideas:
    //   - XOR of all 4 buttons (odd parity)
    //   - XNOR of pairs
    //   - Majority function (3 of 4 pressed)
    //   - Any creative combination!

    assign o_led1 = 1'b0;  // TODO
    assign o_led2 = 1'b0;  // TODO
    assign o_led3 = 1'b0;  // TODO
    assign o_led4 = 1'b0;  // TODO

endmodule
