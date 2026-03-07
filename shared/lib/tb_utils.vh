// =============================================================================
// tb_utils.vh — Shared Testbench Utilities
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
//
// Include this file at the top of any testbench:
//     `include "tb_utils.vh"
//
// Provides:
//   - Standard timescale
//   - Pass/fail counters and summary task
//   - CHECK_EQ / CHECK_NEQ assertion tasks
//   - Clock generator parameters
//
// ASIC vs. FPGA note:
//   These testbenches are technology-neutral.  The same TB works whether the
//   DUT is behavioral RTL (pre-synthesis), a Yosys gate-level netlist
//   (post-synthesis FPGA), or a generic gate-level netlist (ASIC flow).
//   For gate-level sims, add +define+GATE_LEVEL on the iverilog command line
//   and use `ifdef GATE_LEVEL to adjust timing tolerances.
// =============================================================================

`ifndef TB_UTILS_VH
`define TB_UTILS_VH

`timescale 1ns / 1ps

// ── Pass / Fail Counters ─────────────────────────────────────────────────────
// Declare these in every testbench module that uses CHECK_* tasks:
//   integer pass_count = 0, fail_count = 0;

// ── Assertion Tasks ──────────────────────────────────────────────────────────
// Use these from within your testbench.  They update pass_count / fail_count
// and print PASS/FAIL messages with the test label and values.
//
// Example:
//   check_eq(8, o_result, expected, "ADD 3+5");

// check_eq — assert actual === expected (handles x/z correctly)
task check_eq;
    input integer width;       // bit-width (for display formatting)
    input [255:0] actual;
    input [255:0] expected;
    input [8*80-1:0] label;
    begin
        if (actual === expected) begin
            $display("PASS: %0s — got 0x%0h", label, actual[width-1:0]);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: %0s — expected 0x%0h, got 0x%0h",
                     label, expected[width-1:0], actual[width-1:0]);
            fail_count = fail_count + 1;
        end
    end
endtask

// check_eq_1 — single-bit convenience wrapper
task check_eq_1;
    input actual;
    input expected;
    input [8*80-1:0] label;
    begin
        if (actual === expected) begin
            $display("PASS: %0s — got %b", label, actual);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: %0s — expected %b, got %b", label, expected, actual);
            fail_count = fail_count + 1;
        end
    end
endtask

// ── Summary Task ─────────────────────────────────────────────────────────────
// Call at the end of every testbench to print a clean summary line.
task tb_summary;
    input [8*64-1:0] tb_name;
    begin
        $display("");
        $display("============================================================");
        $display("%0s: %0d passed, %0d failed", tb_name, pass_count, fail_count);
        if (fail_count > 0)
            $display(">>> SOME TESTS FAILED <<<");
        else
            $display("ALL TESTS PASSED");
        $display("============================================================");
    end
endtask

// ── Clock Generator Snippet ──────────────────────────────────────────────────
// Copy-paste into your TB and adjust CLK_PERIOD:
//
//   parameter CLK_PERIOD = 40;   // 25 MHz (Go Board default)
//   reg clk = 0;
//   always #(CLK_PERIOD/2) clk = ~clk;

// ── Reset Generator Snippet ──────────────────────────────────────────────────
// Synchronous active-high reset held for N cycles:
//
//   task apply_reset;
//       input integer cycles;
//       begin
//           rst = 1'b1;
//           repeat (cycles) @(posedge clk);
//           @(negedge clk);
//           rst = 1'b0;
//       end
//   endtask

// ── Gate-Level Timing ────────────────────────────────────────────────────────
// When running post-synthesis simulation, propagation delays may cause
// outputs to settle later than in behavioral simulation.  Use:
//
//   `ifdef GATE_LEVEL
//       parameter PROP_DELAY = 5;   // adjust per technology
//   `else
//       parameter PROP_DELAY = 1;
//   `endif
//
//   // Then after changing inputs:
//   #PROP_DELAY;
//   check_eq(...);

`endif // TB_UTILS_VH
