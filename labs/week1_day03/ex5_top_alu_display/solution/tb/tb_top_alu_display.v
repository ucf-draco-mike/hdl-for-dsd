// Minimal testbench for top_alu_display -- exercises the 4 opcode combinations.
`timescale 1ns/1ps

module tb_top_alu_display;
    reg  i_switch1, i_switch2;
    wire o_led1, o_led2;
    wire o_segment1_a, o_segment1_b, o_segment1_c, o_segment1_d;
    wire o_segment1_e, o_segment1_f, o_segment1_g;

    top_alu_display dut (
        .i_switch1(i_switch1), .i_switch2(i_switch2),
        .o_led1(o_led1), .o_led2(o_led2),
        .o_segment1_a(o_segment1_a), .o_segment1_b(o_segment1_b),
        .o_segment1_c(o_segment1_c), .o_segment1_d(o_segment1_d),
        .o_segment1_e(o_segment1_e), .o_segment1_f(o_segment1_f),
        .o_segment1_g(o_segment1_g)
    );

    integer i;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top_alu_display);
        for (i = 0; i < 4; i = i + 1) begin
            {i_switch1, i_switch2} = i[1:0];
            #5;
        end
        $finish;
    end
endmodule
