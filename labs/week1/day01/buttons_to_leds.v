// Exercise 2: Direct button-to-LED mapping
module buttons_to_leds (
    input  wire i_switch1, i_switch2, i_switch3, i_switch4,
    output wire o_led1, o_led2, o_led3, o_led4
);
    assign o_led1 = i_switch1;
    assign o_led2 = i_switch2;
    assign o_led3 = i_switch3;
    assign o_led4 = i_switch4;
endmodule
