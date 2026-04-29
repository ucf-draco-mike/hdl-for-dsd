// =============================================================================
// tb_shift_add_mult.v — Testbench for Shift-and-Add Multiplier
// Day 10, Exercise 2
// =============================================================================
`timescale 1ns/1ps

module tb_shift_add_mult;

    reg        clk, rst, start;
    reg  [7:0] a, b;
    wire [15:0] product;
    wire        done, busy;

    shift_add_mult uut (
        .i_clk(clk), .i_rst(rst), .i_start(start),
        .i_a(a), .i_b(b),
        .o_product(product), .o_done(done), .o_busy(busy)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    integer pass_count, fail_count;
    reg [15:0] expected;

    task test_multiply;
        input [7:0] ta, tb;
        begin
            a = ta;
            b = tb;
            expected = ta * tb;
            @(posedge clk);
            start = 1;
            @(posedge clk);
            start = 0;

            // Wait for done
            wait (done == 1);
            @(posedge clk);

            if (product === expected) begin
                $display("PASS: %0d * %0d = %0d", ta, tb, product);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0d * %0d = %0d (expected %0d)", ta, tb, product, expected);
                fail_count = fail_count + 1;
            end

            // Wait a cycle before next test
            @(posedge clk);
        end
    endtask

    initial begin
        $dumpfile("shift_add_mult.vcd");
        $dumpvars(0, tb_shift_add_mult);

        clk = 0; rst = 1; start = 0; a = 0; b = 0;
        pass_count = 0; fail_count = 0;

        // Reset
        repeat (3) @(posedge clk);
        rst = 0;
        @(posedge clk);

        // Test cases
        test_multiply(8'd0,   8'd0);     // 0 * 0
        test_multiply(8'd1,   8'd1);     // 1 * 1
        test_multiply(8'd0,   8'd100);   // 0 * N
        test_multiply(8'd100, 8'd0);     // N * 0
        test_multiply(8'd1,   8'd255);   // 1 * max
        test_multiply(8'd255, 8'd1);     // max * 1
        test_multiply(8'd3,   8'd7);     // 3 * 7 = 21
        test_multiply(8'd12,  8'd13);    // 12 * 13 = 156
        test_multiply(8'd15,  8'd15);    // 15 * 15 = 225
        test_multiply(8'd255, 8'd255);   // max * max = 65025

        // Summary
        $display("");
        $display("========================================");
        $display("  %0d/%0d tests passed", pass_count, pass_count + fail_count);
        if (fail_count == 0)
            $display("  ALL TESTS PASSED");
        else
            $display("  %0d TESTS FAILED", fail_count);
        $display("========================================");

        $finish;
    end

endmodule
