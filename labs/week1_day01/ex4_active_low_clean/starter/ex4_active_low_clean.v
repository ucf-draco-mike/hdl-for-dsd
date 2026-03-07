// =============================================================================
// Exercise 4: Clean Boundary Pattern
// Day 1 · Welcome to Hardware Thinking
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Goal: Develop a clean boundary pattern for readable designs.
//
// Pattern:
//   1. Name inputs clearly at the boundary -> descriptive internal wires
//   2. Write all internal logic with clear wire names (readable)
//   3. Drive outputs from the internal logic
//
// With active-high buttons and LEDs, no inversion is needed — but
// naming signals clearly at boundaries keeps your design readable.
// =============================================================================

module active_low_clean (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // ---- Step 1: Name inputs clearly at the boundary ----
    // TODO: Create descriptive wires from the switches
    wire w_btn1, w_btn2, w_btn3, w_btn4;
    // assign w_btn1 = ???;
    // assign w_btn2 = ???;
    // assign w_btn3 = ???;
    // assign w_btn4 = ???;

    // ---- Step 2: Internal logic in active-high (reads naturally!) ----
    wire w_both_12;     // true when BOTH buttons 1 and 2 pressed
    wire w_either_34;   // true when EITHER button 3 or 4 pressed
    wire w_xor_12;      // true when exactly one of 1/2 pressed
    wire w_not_1;       // true when button 1 is NOT pressed

    // TODO: Implement using the named wires
    // assign w_both_12   = ???;
    // assign w_either_34 = ???;
    // assign w_xor_12    = ???;
    // assign w_not_1     = ???;

    // ---- Step 3: Drive active-high LEDs from logic ----
    // TODO: Connect outputs
    // assign o_led1 = ???;
    // assign o_led2 = ???;
    // assign o_led3 = ???;
    // assign o_led4 = ???;

endmodule
