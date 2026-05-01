// Minimal testbench for button_counter -- drives clk and toggles count button.
// Note: the debounce stage requires hundreds of thousands of clocks to settle,
// so this stub mainly produces a viewable VCD rather than verifying counts.
`timescale 1ns/1ps

module tb_button_counter;
    reg  i_clk = 0;
    reg  i_switch1 = 0;  // reset
    reg  i_switch2 = 0;  // count
    wire o_segment1_a, o_segment1_b, o_segment1_c, o_segment1_d;
    wire o_segment1_e, o_segment1_f, o_segment1_g;
    wire o_led1;

    always #20 i_clk = ~i_clk;  // 25 MHz

    button_counter dut (
        .i_clk(i_clk),
        .i_switch1(i_switch1), .i_switch2(i_switch2),
        .o_segment1_a(o_segment1_a), .o_segment1_b(o_segment1_b),
        .o_segment1_c(o_segment1_c), .o_segment1_d(o_segment1_d),
        .o_segment1_e(o_segment1_e), .o_segment1_f(o_segment1_f),
        .o_segment1_g(o_segment1_g),
        .o_led1(o_led1)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_button_counter);
        i_switch1 = 1; #200; i_switch1 = 0;
        #1000;
        i_switch2 = 1; #1000; i_switch2 = 0; #500;
        i_switch2 = 1; #1000; i_switch2 = 0; #500;
        $finish;
    end
endmodule
