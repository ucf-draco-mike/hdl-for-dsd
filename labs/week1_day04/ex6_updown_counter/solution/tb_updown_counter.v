// Minimal testbench for updown_counter — toggles up/down buttons across a
// short clock window so the counter produces visible activity.
`timescale 1ns/1ps

module tb_updown_counter;
    reg  i_clk = 0;
    reg  i_switch1 = 0;
    reg  i_switch2 = 0;
    wire o_segment1_a, o_segment1_b, o_segment1_c, o_segment1_d;
    wire o_segment1_e, o_segment1_f, o_segment1_g;

    always #20 i_clk = ~i_clk;  // 25 MHz

    updown_counter dut (
        .i_clk(i_clk),
        .i_switch1(i_switch1), .i_switch2(i_switch2),
        .o_segment1_a(o_segment1_a), .o_segment1_b(o_segment1_b),
        .o_segment1_c(o_segment1_c), .o_segment1_d(o_segment1_d),
        .o_segment1_e(o_segment1_e), .o_segment1_f(o_segment1_f),
        .o_segment1_g(o_segment1_g)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_updown_counter);
        #200 i_switch1 = 1; #200 i_switch1 = 0;
        #200 i_switch1 = 1; #200 i_switch1 = 0;
        #400 i_switch2 = 1; #200 i_switch2 = 0;
        #400;
        $finish;
    end
endmodule
