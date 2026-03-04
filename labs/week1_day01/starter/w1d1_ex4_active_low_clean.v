// =============================================================================
// Exercise 4: Active-Low Clean Pattern
// Day 1 · Welcome to Hardware Thinking
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Goal: Develop the "invert at boundaries" pattern for active-low signals.
//
// Pattern:
//   1. Invert active-low inputs at the top (boundary) -> active-high wires
//   2. Write all internal logic in active-high (natural, readable)
//   3. Invert outputs at the bottom (boundary) -> active-low for LEDs
//
// This keeps your logic clean and readable — the messiness is contained.
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

    // ---- Step 1: Invert active-low inputs at the boundary ----
    // TODO: Create active-high wires from the active-low switches
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

    // TODO: Implement using the active-high wires
    // assign w_both_12   = ???;
    // assign w_either_34 = ???;
    // assign w_xor_12    = ???;
    // assign w_not_1     = ???;

    // ---- Step 3: Invert outputs at the boundary ----
    // TODO: Drive active-low LEDs from active-high logic
    // assign o_led1 = ???;
    // assign o_led2 = ???;
    // assign o_led3 = ???;
    // assign o_led4 = ???;

endmodule
