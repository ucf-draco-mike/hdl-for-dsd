// =============================================================================
// Exercise 2 SOLUTION: Buttons to LEDs
// Day 1 · Welcome to Hardware Thinking
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

    assign o_led1 = i_switch1;
    assign o_led2 = i_switch2;
    assign o_led3 = i_switch3;
    assign o_led4 = i_switch4;

endmodule
