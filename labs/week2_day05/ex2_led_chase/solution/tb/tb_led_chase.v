// Minimal testbench for led_chase -- drives clk, exercises reset and direction.
`timescale 1ns/1ps

module tb_led_chase;
    reg  i_clk = 0;
    reg  i_switch1 = 0;  // reset
    reg  i_switch2 = 0;  // direction
    wire o_led1, o_led2, o_led3, o_led4;

    always #20 i_clk = ~i_clk;  // 25 MHz

    led_chase dut (
        .i_clk(i_clk),
        .i_switch1(i_switch1), .i_switch2(i_switch2),
        .o_led1(o_led1), .o_led2(o_led2),
        .o_led3(o_led3), .o_led4(o_led4)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_led_chase);
        i_switch1 = 1; #200; i_switch1 = 0;
        #20000;
        i_switch2 = 1;
        #20000;
        $finish;
    end
endmodule
