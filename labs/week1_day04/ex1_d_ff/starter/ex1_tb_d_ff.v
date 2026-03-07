// =============================================================================
// Exercise 1: D Flip-Flop Testbench
// Day 4 · Sequential Logic Fundamentals
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Verify: D is captured on posedge clk, reset clears output.
// Use GTKWave to mark the moment i_d changes vs. the moment o_q changes.
// =============================================================================

`timescale 1ns / 1ps

module tb_d_ff;

    reg  clk, reset, d;
    wire q;

    d_ff uut (
        .i_clk(clk), .i_reset(reset), .i_d(d), .o_q(q)
    );

    // 10 ns clock period (100 MHz for easy reading)
    always #5 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;

    task check;
        input expected;
        input [8*30-1:0] name;
    begin
        if (q === expected) begin
            $display("PASS: %0s — q=%b (expected %b)", name, q, expected);
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

        // Initialize
        clk = 0; reset = 1; d = 0;

        // Reset
        @(posedge clk); #1;
        check(0, "After reset, q=0");

        // Release reset, set d=1
        reset = 0; d = 1;
        @(posedge clk); #1;
        check(1, "d=1 captured");

        // d=0
        d = 0;
        @(posedge clk); #1;
        check(0, "d=0 captured");

        // Toggle d rapidly
        d = 1;
        @(posedge clk); #1;
        check(1, "d=1 captured again");

        // Reset while d=1
        reset = 1;
        @(posedge clk); #1;
        check(0, "Reset overrides d=1");

        // Summary
        $display("");
        $display("========================================");
        $display("D Flip-Flop: %0d passed, %0d failed", pass_count, fail_count);
        $display("========================================");

        #20 $finish;
    end

endmodule
