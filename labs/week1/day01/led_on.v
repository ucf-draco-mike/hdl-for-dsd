// Exercise 1: Simplest possible design — drive LED1 on
module led_on (
    output wire o_led1
);
    // Go Board LEDs are active low: 0 = on, 1 = off
    assign o_led1 = 1'b0;
endmodule
