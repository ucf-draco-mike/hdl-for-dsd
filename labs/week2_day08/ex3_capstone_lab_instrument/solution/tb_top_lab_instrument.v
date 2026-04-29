// Minimal testbench for top_lab_instrument — drives clock and a few button
// presses to exercise debounce + state changes for waveform viewing.
// Note: real debounce uses 10ms which is impractical in sim; this testbench
// just produces a viewable VCD rather than verifying full behavior.
`timescale 1ns/1ps

module tb_top_lab_instrument;
    reg  i_clk = 0;
    reg  i_switch1 = 0, i_switch2 = 0, i_switch3 = 0, i_switch4 = 0;
    wire o_led1, o_led2, o_led3, o_led4;
    wire o_segment1_a, o_segment1_b, o_segment1_c, o_segment1_d;
    wire o_segment1_e, o_segment1_f, o_segment1_g;
    wire o_segment2_a, o_segment2_b, o_segment2_c, o_segment2_d;
    wire o_segment2_e, o_segment2_f, o_segment2_g;

    always #20 i_clk = ~i_clk;  // 25 MHz

    top_lab_instrument dut (
        .i_clk(i_clk),
        .i_switch1(i_switch1), .i_switch2(i_switch2),
        .i_switch3(i_switch3), .i_switch4(i_switch4),
        .o_led1(o_led1), .o_led2(o_led2),
        .o_led3(o_led3), .o_led4(o_led4),
        .o_segment1_a(o_segment1_a), .o_segment1_b(o_segment1_b),
        .o_segment1_c(o_segment1_c), .o_segment1_d(o_segment1_d),
        .o_segment1_e(o_segment1_e), .o_segment1_f(o_segment1_f),
        .o_segment1_g(o_segment1_g),
        .o_segment2_a(o_segment2_a), .o_segment2_b(o_segment2_b),
        .o_segment2_c(o_segment2_c), .o_segment2_d(o_segment2_d),
        .o_segment2_e(o_segment2_e), .o_segment2_f(o_segment2_f),
        .o_segment2_g(o_segment2_g)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top_lab_instrument);
        #5000;
        i_switch1 = 1; #500; i_switch1 = 0; #500;
        i_switch4 = 1; #500; i_switch4 = 0; #2000;
        $finish;
    end
endmodule
