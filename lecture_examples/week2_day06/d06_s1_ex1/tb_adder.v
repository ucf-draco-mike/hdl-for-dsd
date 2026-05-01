// =============================================================================
// tb_adder.v -- d06_s1 "Build a Testbench from Scratch" Live Demo
// =============================================================================
//   Bare-bones testbench, the version Mike types live during d06_s1.
//   Just stimulus + $display. No checks, no PASS/FAIL -- that comes in s2.
// =============================================================================
`timescale 1ns/1ps

module tb_adder;
    reg  [7:0] a, b;
    wire [8:0] sum;

    adder #(.WIDTH(8)) dut (.a(a), .b(b), .sum(sum));

    initial begin
        $dumpfile("tb_adder.vcd");
        $dumpvars(0, tb_adder);

        a = 8'd0;   b = 8'd0;   #5;
        $display("a=%0d b=%0d -> sum=%0d", a, b, sum);

        a = 8'd1;   b = 8'd2;   #5;
        $display("a=%0d b=%0d -> sum=%0d", a, b, sum);

        a = 8'd200; b = 8'd100; #5;
        $display("a=%0d b=%0d -> sum=%0d", a, b, sum);

        a = 8'hFF;  b = 8'h01;  #5;
        $display("a=%0d b=%0d -> sum=%0d (carry expected)", a, b, sum);

        $finish;
    end
endmodule
