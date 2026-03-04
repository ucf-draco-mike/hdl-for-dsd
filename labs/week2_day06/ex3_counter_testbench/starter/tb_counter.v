// =============================================================================
// tb_counter.v — Counter Testbench (Starter)
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

    // ---- TODO: Implement check_count task ----
    // task check_count;
    //   input [3:0] expected;
    //   input       exp_zero;
    //   input [8*32-1:0] label;
    // begin
    //   @(posedge clk); #1;
    //   test_count = test_count + 1;
    //   if (count !== expected || zero !== exp_zero) begin
    //     fail_count = fail_count + 1;
    //     $display("FAIL %0s: expected count=%h zero=%b, got count=%h zero=%b",
    //              label, expected, exp_zero, count, zero);
    //   end else
    //     $display("PASS %0s: count=%h zero=%b", label, count, zero);
    // end
    // endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_counter);

        $display("=== Counter Testbench ===");

        // ---- TODO: Test 1 — Reset ----
        // Apply reset, verify count=0 and zero=1
        reset = 1; enable = 0;
        repeat (3) @(posedge clk);
        // check_count(4'h0, 1'b1, "Reset");

        // ---- TODO: Test 2 — Count up sequence ----
        // Release reset, enable counting, verify 0→1→2→...
        reset = 0; enable = 1;
        // check_count(4'h1, 1'b0, "Count to 1");
        // check_count(4'h2, 1'b0, "Count to 2");

        // ---- TODO: Test 3 — Enable hold ----
        // Disable enable for 5 cycles, verify count holds
        enable = 0;
        repeat (5) @(posedge clk); #1;
        // Verify count hasn't changed

        // ---- TODO: Test 4 — Rollover from F to 0 ----
        // Enable counting, run until rollover
        // Reset and manually count to 4'hF, then one more

        // ---- TODO: Print summary ----
        $display("\n========================================");
        $display("Counter: %0d/%0d tests passed",
                 test_count - fail_count, test_count);
        $display("========================================");
        $finish;
    end

endmodule
