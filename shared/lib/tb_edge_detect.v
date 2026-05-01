// =============================================================================
// tb_edge_detect.v -- Self-checking testbench for edge_detect
// Accelerated HDL for Digital System Design - Dr. Mike Borowczak - ECE - CECS - UCF
// =============================================================================
// Verifies:
//   1. Rising edge produces one-cycle pulse on o_rising
//   2. Falling edge produces one-cycle pulse on o_falling
//   3. Any edge produces one-cycle pulse on o_any
//   4. Steady-state signal produces no pulses
//   5. Pulses are exactly one clock cycle wide
// =============================================================================
`timescale 1ns/1ps

module tb_edge_detect;

    parameter CLK_PERIOD = 40;  // 25 MHz

    reg  clk = 0;
    reg  signal = 0;
    wire rising, falling, any_edge;

    edge_detect dut (
        .i_clk(clk),
        .i_signal(signal),
        .o_rising(rising),
        .o_falling(falling),
        .o_any(any_edge)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    integer pass_count = 0, fail_count = 0;

    task check;
        input exp_rise, exp_fall, exp_any;
        input [8*40-1:0] label;
        begin
            @(posedge clk); #1;
            if (rising === exp_rise && falling === exp_fall && any_edge === exp_any) begin
                $display("PASS: %0s -- rise=%b fall=%b any=%b",
                         label, rising, falling, any_edge);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s -- rise=%b(exp %b) fall=%b(exp %b) any=%b(exp %b)",
                         label, rising, exp_rise, falling, exp_fall, any_edge, exp_any);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_edge_detect);

        // Let r_prev initialize
        @(posedge clk); @(posedge clk);

        // Steady low -- no edges
        signal = 0;
        check(0, 0, 0, "steady low");

        // Rising edge: 0 -> 1
        signal = 1;
        check(1, 0, 1, "0->1 rising");

        // Steady high -- no edges (pulse should be gone)
        check(0, 0, 0, "steady high");

        // Falling edge: 1 -> 0
        signal = 0;
        check(0, 1, 1, "1->0 falling");

        // Steady low again
        check(0, 0, 0, "steady low again");

        // Rapid toggle: 0->1->0 across two cycles
        signal = 1;
        check(1, 0, 1, "rapid toggle rise");
        signal = 0;
        check(0, 1, 1, "rapid toggle fall");

        // One more rising to confirm
        signal = 1;
        check(1, 0, 1, "final rise");

        $display("");
        $display("=== tb_edge_detect: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
