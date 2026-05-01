// =============================================================================
// tb_adder_after.v -- d06_s2 demo, "AFTER" snapshot
// =============================================================================
//   Same stimulus as tb_adder_before.v but every check is now self-checking:
//   each test computes the expected value, compares it to the DUT, and
//   prints PASS/FAIL. The bottom of the run prints a "X passed, Y failed"
//   banner so a green run is unambiguous.
// =============================================================================
`timescale 1ns/1ps

module tb_adder_after;
    reg  [7:0] a, b;
    wire [8:0] sum;

    adder #(.WIDTH(8)) dut (.a(a), .b(b), .sum(sum));

    integer passes = 0;
    integer fails  = 0;

    task check(input [7:0] aa, input [7:0] bb, input [8:0] expected);
        begin
            a = aa; b = bb; #5;
            if (sum === expected) begin
                $display("PASS: %0d + %0d = %0d", aa, bb, expected);
                passes = passes + 1;
            end else begin
                $display("FAIL: %0d + %0d expected=%0d got=%0d",
                         aa, bb, expected, sum);
                fails = fails + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_adder_after.vcd");
        $dumpvars(0, tb_adder_after);

        check(8'd0,   8'd0,   9'd0);
        check(8'd1,   8'd2,   9'd3);
        check(8'd200, 8'd100, 9'd300);
        check(8'hFF,  8'h01,  9'd256);

        $display("=== %0d passed, %0d failed ===", passes, fails);
        $finish;
    end
endmodule
