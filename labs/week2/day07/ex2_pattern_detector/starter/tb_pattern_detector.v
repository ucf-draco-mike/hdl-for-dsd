// =============================================================================
// tb_pattern_detector.v — Pattern Detector Testbench (Starter)
// Day 7, Exercise 2
// =============================================================================

`timescale 1ns / 1ps
`define SIMULATION

module tb_pattern_detector;

    reg clk, reset;
    reg btn1, btn2, btn3;
    wire detected;
    wire [1:0] progress;

    pattern_detector uut (
        .i_clk(clk), .i_reset(reset),
        .i_btn1(btn1), .i_btn2(btn2), .i_btn3(btn3),
        .o_detected(detected), .o_progress(progress)
    );

    initial clk = 0;
    always #20 clk = ~clk;

    integer test_count = 0, fail_count = 0;

    // ---- TODO: Create a press_btn task ----
    // Pulse the appropriate button signal high for one clock cycle

    // ---- TODO: Create a check task ----
    // Compare progress and detected against expected values

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_pattern_detector);
        btn1 = 0; btn2 = 0; btn3 = 0;
        reset = 1; repeat (3) @(posedge clk); reset = 0;

        // ---- TODO: Test 1 — Correct sequence btn1->btn2->btn3 ----

        // ---- TODO: Test 2 — Wrong sequence (btn2 first) ----

        // ---- TODO: Test 3 — Partial correct then btn1 ----

        // ---- TODO: Test 4 — Reset mid-sequence ----

        $display("");
        $display("========================================");
        $display("Pattern Detector: %0d / %0d tests passed",
                 test_count - fail_count, test_count);
        $display("========================================");
        $finish;
    end

endmodule
