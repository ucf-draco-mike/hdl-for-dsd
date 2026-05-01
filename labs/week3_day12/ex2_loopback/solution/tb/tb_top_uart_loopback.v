// Minimal testbench for top_uart_loopback -- drives clk and an idle UART RX line.
// Note: this design instantiates uart_tx, uart_rx, hex_to_7seg from shared/lib.
// To run sim, ensure those source files are visible (see Makefile SRCS list).
`timescale 1ns/1ps

module tb_top_uart_loopback;
    reg  i_clk = 0;
    reg  i_uart_rx = 1;  // idle high
    wire o_uart_tx;
    wire o_segment1_a, o_segment1_b, o_segment1_c, o_segment1_d;
    wire o_segment1_e, o_segment1_f, o_segment1_g;
    wire o_led1, o_led2, o_led3, o_led4;

    always #20 i_clk = ~i_clk;  // 25 MHz

    top_uart_loopback dut (
        .i_clk(i_clk), .i_uart_rx(i_uart_rx),
        .o_uart_tx(o_uart_tx),
        .o_segment1_a(o_segment1_a), .o_segment1_b(o_segment1_b),
        .o_segment1_c(o_segment1_c), .o_segment1_d(o_segment1_d),
        .o_segment1_e(o_segment1_e), .o_segment1_f(o_segment1_f),
        .o_segment1_g(o_segment1_g),
        .o_led1(o_led1), .o_led2(o_led2),
        .o_led3(o_led3), .o_led4(o_led4)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top_uart_loopback);
        #100000;
        $finish;
    end
endmodule
