// =============================================================================
// Exercise 1 SOLUTION: D Flip-Flop Testbench
// Day 4 · Sequential Logic Fundamentals
// =============================================================================

`timescale 1ns / 1ps

module tb_d_ff;

    reg  clk, reset, d;
    wire q;

    d_ff uut (.i_clk(clk), .i_reset(reset), .i_d(d), .o_q(q));

    always #5 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;

    task check;
        input expected;
        input [8*30-1:0] name;
    begin
        if (q === expected) begin
            $display("PASS: %0s — q=%b", name, q);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: %0s — q=%b (expected %b)", name, q, expected);
            fail_count = fail_count + 1;
        end
    end
    endtask

    initial begin
        $dumpfile("build/ex1.vcd");
        $dumpvars(0, tb_d_ff);

        clk = 0; reset = 1; d = 0;

        @(posedge clk); #1; check(0, "After reset, q=0");
        reset = 0; d = 1;
        @(posedge clk); #1; check(1, "d=1 captured");
        d = 0;
        @(posedge clk); #1; check(0, "d=0 captured");
        d = 1;
        @(posedge clk); #1; check(1, "d=1 captured again");
        reset = 1;
        @(posedge clk); #1; check(0, "Reset overrides d=1");

        $display("");
        $display("========================================");
        $display("D Flip-Flop: %0d passed, %0d failed", pass_count, fail_count);
        $display("========================================");
        #20 $finish;
    end

endmodule
