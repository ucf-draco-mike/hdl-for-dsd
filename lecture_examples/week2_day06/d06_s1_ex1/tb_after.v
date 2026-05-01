// =============================================================================
// tb_after.v -- d06_s3 demo, "AFTER" snapshot
// =============================================================================
//   Same 12 cases as tb_before.v, but the repetitive stimulus + check
//   pattern is collapsed into a `check` task. Half the line count, and
//   adding a 13th case is one line.
// =============================================================================
`timescale 1ns/1ps

module tb_after;
    reg  [7:0] a, b;
    wire [8:0] sum;
    integer passes = 0;
    integer fails  = 0;

    adder #(.WIDTH(8)) dut (.a(a), .b(b), .sum(sum));

    task check(input [7:0] aa, input [7:0] bb, input [8:0] expected,
               input [255:0] label);
        begin
            a = aa; b = bb; #5;
            if (sum === expected) begin
                $display("PASS: %0s", label);
                passes = passes + 1;
            end else begin
                $display("FAIL: %0s expected=%0d got=%0d",
                         label, expected, sum);
                fails = fails + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_after.vcd");
        $dumpvars(0, tb_after);

        check(  0,   0,   0, "0+0");
        check(  1,   2,   3, "1+2");
        check(  5,   7,  12, "5+7");
        check( 10,  20,  30, "10+20");
        check(100,  50, 150, "100+50");
        check(200, 100, 300, "200+100");
        check(255,   0, 255, "FF+0");
        check(255,   1, 256, "FF+1");
        check(255, 255, 510, "FF+FF");
        check(128, 128, 256, "128+128");
        check( 15,  15,  30, "0F+0F");
        check( 85, 170, 255, "55+AA");

        $display("=== %0d passed, %0d failed ===", passes, fails);
        $finish;
    end
endmodule
