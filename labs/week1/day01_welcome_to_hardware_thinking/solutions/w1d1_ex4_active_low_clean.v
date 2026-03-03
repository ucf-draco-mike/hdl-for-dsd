// =============================================================================
// Exercise 4 SOLUTION: Active-Low Clean Pattern
// Day 1 · Welcome to Hardware Thinking
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

    // Step 1: Invert active-low inputs at boundary
    wire w_btn1 = ~i_switch1;
    wire w_btn2 = ~i_switch2;
    wire w_btn3 = ~i_switch3;
    wire w_btn4 = ~i_switch4;

    // Step 2: Internal logic — active-high, reads naturally
    wire w_both_12   = w_btn1 & w_btn2;      // both pressed
    wire w_either_34 = w_btn3 | w_btn4;      // either pressed
    wire w_xor_12    = w_btn1 ^ w_btn2;      // exactly one
    wire w_not_1     = ~w_btn1;              // btn1 NOT pressed

    // Step 3: Invert outputs at boundary (active-low LEDs)
    assign o_led1 = ~w_both_12;
    assign o_led2 = ~w_either_34;
    assign o_led3 = ~w_xor_12;
    assign o_led4 = ~w_not_1;

endmodule
