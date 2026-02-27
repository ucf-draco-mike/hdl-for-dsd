// =============================================================================
// button_logic.v — Multiple Concurrent Gates
// Day 1: Welcome to Hardware Thinking
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Description:
//   Demonstrates that multiple assign statements create parallel hardware.
//   Three gates (AND, OR, XOR) operate simultaneously on two switch inputs.
//
// Go Board mapping:
//   i_switch1 → pin 53 (Switch 1)
//   i_switch2 → pin 51 (Switch 2)
//   o_led1    → pin 56 (LED 1) — AND result
//   o_led2    → pin 57 (LED 2) — OR result
//   o_led3    → pin 59 (LED 3) — XOR result
//   o_led4    → pin 60 (LED 4) — NOT of switch 1
// =============================================================================

module button_logic (
    input  wire i_switch1,
    input  wire i_switch2,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // All four gates exist simultaneously — order doesn't matter
    assign o_led1 = i_switch1 & i_switch2;   // AND gate
    assign o_led2 = i_switch1 | i_switch2;   // OR gate
    assign o_led3 = i_switch1 ^ i_switch2;   // XOR gate
    assign o_led4 = ~i_switch1;              // NOT (inverter)

endmodule
