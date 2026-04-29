// Minimal testbench for top_uart_hello — drives clk and one button press.
// Note: real debounce uses 250k cycles; this stub mainly produces a VCD.
`timescale 1ns/1ps

module tb_top_uart_hello;
    reg  i_clk = 0;
    reg  i_switch1 = 0;
    wire o_uart_tx, o_led1, o_led2, o_led3, o_led4;

    always #20 i_clk = ~i_clk;  // 25 MHz

    top_uart_hello dut (
        .i_clk(i_clk), .i_switch1(i_switch1),
        .o_uart_tx(o_uart_tx),
        .o_led1(o_led1), .o_led2(o_led2),
        .o_led3(o_led3), .o_led4(o_led4)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top_uart_hello);
        #10000 i_switch1 = 1;
        #10000 i_switch1 = 0;
        #50000;
        $finish;
    end
endmodule
