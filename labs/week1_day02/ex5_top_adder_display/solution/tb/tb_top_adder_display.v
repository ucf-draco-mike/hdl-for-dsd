// Minimal testbench for top_adder_display -- sweeps all 16 input combinations
// and dumps the 7-seg outputs to a VCD.
`timescale 1ns/1ps

module tb_top_adder_display;
    reg  i_switch1, i_switch2, i_switch3, i_switch4;
    wire o_led1;
    wire o_segment1_a, o_segment1_b, o_segment1_c, o_segment1_d;
    wire o_segment1_e, o_segment1_f, o_segment1_g;

    top_adder_display dut (
        .i_switch1(i_switch1), .i_switch2(i_switch2),
        .i_switch3(i_switch3), .i_switch4(i_switch4),
        .o_led1(o_led1),
        .o_segment1_a(o_segment1_a), .o_segment1_b(o_segment1_b),
        .o_segment1_c(o_segment1_c), .o_segment1_d(o_segment1_d),
        .o_segment1_e(o_segment1_e), .o_segment1_f(o_segment1_f),
        .o_segment1_g(o_segment1_g)
    );

    integer i;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top_adder_display);
        for (i = 0; i < 16; i = i + 1) begin
            {i_switch4, i_switch3, i_switch2, i_switch1} = i[3:0];
            #5;
        end
        $finish;
    end
endmodule
