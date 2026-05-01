// =============================================================================
// tb_counter.v -- Counter Testbench (Solution)
// Day 6, Exercise 3
// =============================================================================

`timescale 1ns / 1ps

module tb_counter;

    reg        clk, reset, enable;
    wire [3:0] count;
    wire       zero;

    counter_4bit uut (
        .i_clk(clk), .i_reset(reset), .i_enable(enable),
        .o_count(count), .o_zero(zero)
    );

    initial clk = 0;
    always #20 clk = ~clk;

    integer test_count = 0;
    integer fail_count = 0;

    task check_count;
        input [3:0] expected;
        input       exp_zero;
        input [8*32-1:0] label;
    begin
        @(posedge clk); #1;
        test_count = test_count + 1;
        if (count !== expected || zero !== exp_zero) begin
            fail_count = fail_count + 1;
            $display("FAIL %0s: expected count=%h zero=%b, got count=%h zero=%b",
                     label, expected, exp_zero, count, zero);
        end else
            $display("PASS %0s: count=%h zero=%b", label, count, zero);
    end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_counter);

        $display("=== Counter Testbench ===");

        // Test 1: Reset
        reset = 1; enable = 0;
        repeat (3) @(posedge clk);
        check_count(4'h0, 1'b1, "Reset to 0");

        // Test 2: Count up sequence
        reset = 0; enable = 1;
        check_count(4'h1, 1'b0, "Count to 1");
        check_count(4'h2, 1'b0, "Count to 2");
        check_count(4'h3, 1'b0, "Count to 3");
        check_count(4'h4, 1'b0, "Count to 4");

        // Test 3: Enable hold
        enable = 0;
        @(posedge clk); #1;
        test_count = test_count + 1;
        if (count !== 4'h5) begin
            fail_count = fail_count + 1;
            $display("FAIL Hold: count changed to %h (expected 5)", count);
        end else
            $display("PASS Hold: count stayed at 5");

        repeat (4) @(posedge clk); #1;
        test_count = test_count + 1;
        if (count !== 4'h5) begin
            fail_count = fail_count + 1;
            $display("FAIL Hold 5cyc: count=%h (expected 5)", count);
        end else
            $display("PASS Hold 5cyc: count=5 after 5 disabled cycles");

        // Test 4: Rollover F->0
        reset = 1;
        @(posedge clk); reset = 0; enable = 1;
        // Count from 0 to F (15 clocks), then one more for rollover
        repeat (15) @(posedge clk);
        check_count(4'h0, 1'b1, "Rollover F->0");

        // Test 5: Reset mid-count
        repeat (5) @(posedge clk); #1;  // count is now 5
        reset = 1;
        @(posedge clk); #1;
        check_count(4'h0, 1'b1, "Mid-count reset");
        reset = 0;

        $display("\n========================================");
        $display("Counter: %0d/%0d tests passed",
                 test_count - fail_count, test_count);
        $display("========================================");
        $finish;
    end

endmodule
