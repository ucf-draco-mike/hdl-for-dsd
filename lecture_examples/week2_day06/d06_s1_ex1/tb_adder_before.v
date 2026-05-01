// =============================================================================
// tb_adder_before.v -- d06_s2 demo, "BEFORE" snapshot
// =============================================================================
//   Print-only testbench. Reader has to eyeball stdout / waveforms to
//   decide whether the adder works. This is what s2 shows first; the
//   "after" version (next file) converts every $display into a real check.
// =============================================================================
`timescale 1ns/1ps

module tb_adder_before;
    reg  [7:0] a, b;
    wire [8:0] sum;

    adder #(.WIDTH(8)) dut (.a(a), .b(b), .sum(sum));

    initial begin
        $dumpfile("tb_adder_before.vcd");
        $dumpvars(0, tb_adder_before);

        a = 8'd0;   b = 8'd0;   #5;  $display("Test 1: %0d + %0d = %0d", a, b, sum);
        a = 8'd1;   b = 8'd2;   #5;  $display("Test 2: %0d + %0d = %0d", a, b, sum);
        a = 8'd200; b = 8'd100; #5;  $display("Test 3: %0d + %0d = %0d", a, b, sum);
        a = 8'hFF;  b = 8'h01;  #5;  $display("Test 4: %0d + %0d = %0d", a, b, sum);

        $finish;
    end
endmodule
