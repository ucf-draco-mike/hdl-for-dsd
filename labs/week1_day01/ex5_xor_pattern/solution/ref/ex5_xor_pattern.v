// =============================================================================
// Exercise 5 SOLUTION (Stretch): XOR Pattern
// Day 1 · Welcome to Hardware Thinking
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

    // Invert at boundary
    wire w_b1 = i_switch1;
    wire w_b2 = i_switch2;
    wire w_b3 = i_switch3;
    wire w_b4 = i_switch4;

    // LED1: XOR all 4 (odd parity — on when odd number pressed)
    assign o_led1 = (w_b1 ^ w_b2 ^ w_b3 ^ w_b4);

    // LED2: XNOR of btn1 and btn3 (on when both same state)
    assign o_led2 = (w_b1 ~^ w_b3);

    // LED3: Majority — on when 3 or more pressed
    assign o_led3 = ~((w_b1 & w_b2 & w_b3) |
                      (w_b1 & w_b2 & w_b4) |
                      (w_b1 & w_b3 & w_b4) |
                      (w_b2 & w_b3 & w_b4));

    // LED4: NOR — on only when NO buttons pressed
    assign o_led4 = (~(w_b1 | w_b2 | w_b3 | w_b4));

endmodule
