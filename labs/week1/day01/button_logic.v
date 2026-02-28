// Exercise 3: Combinational logic between buttons and LEDs
// TODO: Fill in the logic for each LED
module button_logic (
    input  wire i_switch1, i_switch2, i_switch3, i_switch4,
    output wire o_led1, o_led2, o_led3, o_led4
);
    // LED1: ON when BOTH sw1 AND sw2 are pressed (active-low)
    assign o_led1 = i_switch1 | i_switch2;

    // LED2: ON when EITHER sw3 OR sw4 is pressed
    assign o_led2 = i_switch3 & i_switch4;

    // LED3: XOR — on when exactly one of sw1,sw2 is pressed
    assign o_led3 = ~(i_switch1 ^ i_switch2);

    // LED4: Inverted sw1
    assign o_led4 = ~i_switch1;
endmodule
