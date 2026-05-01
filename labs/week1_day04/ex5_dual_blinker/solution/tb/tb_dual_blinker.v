// Minimal testbench for dual_blinker -- drives a clock and dumps outputs.
`timescale 1ns/1ps

module tb_dual_blinker;
    reg  i_clk = 0;
    wire o_led1, o_led2, o_led3, o_led4;

    always #20 i_clk = ~i_clk;  // 25 MHz

    dual_blinker dut (
        .i_clk(i_clk),
        .o_led1(o_led1), .o_led2(o_led2),
        .o_led3(o_led3), .o_led4(o_led4)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_dual_blinker);
        #10000;
        $finish;
    end
endmodule
