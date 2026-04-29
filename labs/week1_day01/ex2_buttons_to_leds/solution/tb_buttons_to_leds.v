// Minimal testbench for buttons_to_leds — sweeps all 16 input combinations.
`timescale 1ns/1ps

module tb_buttons_to_leds;
    reg  i_switch1, i_switch2, i_switch3, i_switch4;
    wire o_led1, o_led2, o_led3, o_led4;

    buttons_to_leds dut (
        .i_switch1(i_switch1), .i_switch2(i_switch2),
        .i_switch3(i_switch3), .i_switch4(i_switch4),
        .o_led1(o_led1), .o_led2(o_led2),
        .o_led3(o_led3), .o_led4(o_led4)
    );

    integer i;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_buttons_to_leds);
        for (i = 0; i < 16; i = i + 1) begin
            {i_switch4, i_switch3, i_switch2, i_switch1} = i[3:0];
            #5;
        end
        $finish;
    end
endmodule
