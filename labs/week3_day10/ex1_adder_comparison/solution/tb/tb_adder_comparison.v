// Minimal testbench -- exercises the 8-bit ripple-carry and behavioral adders
// with a few sample inputs to produce a viewable VCD.
`timescale 1ns/1ps

module tb_adder_comparison;
    reg  [7:0] a = 8'h00;
    reg  [7:0] b = 8'h00;
    reg        cin = 0;

    wire [7:0] rc_sum;
    wire       rc_cout;
    wire [8:0] beh_sum;

    ripple_carry_8 rc8 (.i_a(a), .i_b(b), .i_cin(cin),
                        .o_sum(rc_sum), .o_cout(rc_cout));
    behavioral_8   bh8 (.i_a(a), .i_b(b), .i_cin(cin), .o_sum(beh_sum));

    integer i;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_adder_comparison);
        for (i = 0; i < 32; i = i + 1) begin
            a   = $random;
            b   = $random;
            cin = $random;
            #5;
        end
        $finish;
    end
endmodule
