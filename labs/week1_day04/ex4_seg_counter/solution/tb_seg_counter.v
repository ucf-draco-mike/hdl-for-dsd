// Minimal testbench for seg_counter — drives a clock and observes outputs.
// The internal divider counts to ~12.5M, so we shorten observation to a few
// ticks of the raw clock just to produce a viewable waveform.
`timescale 1ns/1ps

module tb_seg_counter;
    reg  i_clk = 0;
    wire o_led1;
    wire o_segment1_a, o_segment1_b, o_segment1_c, o_segment1_d;
    wire o_segment1_e, o_segment1_f, o_segment1_g;

    always #20 i_clk = ~i_clk;  // 25 MHz

    seg_counter dut (
        .i_clk(i_clk),
        .o_led1(o_led1),
        .o_segment1_a(o_segment1_a), .o_segment1_b(o_segment1_b),
        .o_segment1_c(o_segment1_c), .o_segment1_d(o_segment1_d),
        .o_segment1_e(o_segment1_e), .o_segment1_f(o_segment1_f),
        .o_segment1_g(o_segment1_g)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_seg_counter);
        #10000;
        $finish;
    end
endmodule
