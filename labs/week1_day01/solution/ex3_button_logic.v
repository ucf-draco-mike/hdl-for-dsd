// =============================================================================
// Exercise 3 SOLUTION: Logic Between Buttons and LEDs
// Day 1 · Welcome to Hardware Thinking
// =============================================================================

module button_logic (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // LED1: ON when BOTH sw1 AND sw2 pressed
    // OR of active-low = AND of pressed conditions
    assign o_led1 = i_switch1 | i_switch2;

    // LED2: ON when EITHER sw3 OR sw4 pressed
    // AND of active-low = OR of pressed conditions
    assign o_led2 = i_switch3 & i_switch4;

    // LED3: XOR — on when exactly one of sw1/sw2 pressed
    // XOR then invert for active-low output
    assign o_led3 = ~(i_switch1 ^ i_switch2);

    // LED4: Inverted sw1 — LED on when NOT pressed
    assign o_led4 = ~i_switch1;

endmodule
