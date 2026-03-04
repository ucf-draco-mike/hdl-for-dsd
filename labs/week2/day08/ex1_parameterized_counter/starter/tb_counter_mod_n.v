// =============================================================================
// tb_counter_mod_n.v — Parameterized Counter Testbench (Starter)
// Day 8, Exercise 1
// =============================================================================

`timescale 1ns / 1ps

module tb_counter_mod_n;

    reg clk, reset, enable;

    // Config 1: N=10
    wire [3:0] count_10;
    wire wrap_10;
    counter_mod_n #(.N(10)) uut_10 (
        .i_clk(clk), .i_reset(reset), .i_enable(enable),
        .o_count(count_10), .o_wrap(wrap_10)
    );

    // Config 2: N=16
    wire [3:0] count_16;
    wire wrap_16;
    counter_mod_n #(.N(16)) uut_16 (
        .i_clk(clk), .i_reset(reset), .i_enable(enable),
        .o_count(count_16), .o_wrap(wrap_16)
    );

    // Config 3: N=60
    wire [5:0] count_60;
    wire wrap_60;
    counter_mod_n #(.N(60)) uut_60 (
        .i_clk(clk), .i_reset(reset), .i_enable(enable),
        .o_count(count_60), .o_wrap(wrap_60)
    );

    initial clk = 0;
    always #20 clk = ~clk;

    integer test_count = 0, fail_count = 0;

    // ---- TODO: Implement test tasks ----
    // Task: verify a counter wraps at exactly N-1 and resets to 0

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_counter_mod_n);

        reset = 1; enable = 1;
        repeat (3) @(posedge clk);
        reset = 0;

        // ---- TODO: Test N=10 counter ----
        // Run 10 cycles, verify wrap at count==9, count returns to 0

        // ---- TODO: Test N=16 counter ----

        // ---- TODO: Test N=60 counter ----

        // ---- TODO: Enable test — disable for 5 cycles, verify hold ----

        $display("");
        $display("========================================");
        $display("Counter tests: %0d / %0d passed",
                 test_count - fail_count, test_count);
        $display("========================================");
        $finish;
    end

endmodule
