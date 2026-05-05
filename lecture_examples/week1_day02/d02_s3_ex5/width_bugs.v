//-----------------------------------------------------------------------------
// File:    width_bugs.v
// Course:  Accelerated HDL for Digital System Design — Day 2
// Slide:   d02_s3 "Width Mismatch — Compiler & Synthesis Warnings" Live Demo
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   DELIBERATELY BUGGY MODULE — every assignment below produces a width
//   warning under verilator --lint-only -Wall and yosys synth_ice40, and a
//   silently wrong runtime value when driven by tb_width_bugs.v. The s3 demo
//   shows all three: compiler warning, synth warning, wrong waveform.
//
//   Note: iverilog has no width-mismatch warning category, so it compiles
//   this file silently even with -Wall. Use verilator for the lint demo.
//
//   Run from this directory:
//     make lint        # verilator --lint-only -Wall — surfaces width warnings
//     make synth-warn  # yosys synth_ice40 — surfaces width warnings
//     make sim         # runs tb_width_bugs.v, prints expected vs got
//
//   Each output port maps to one slide bullet:
//     sum_truncated  Bug 1: unsized literal `1` is 32-bit; sum truncated to 4 bits
//     sum_overflow   Bug 2: 5-bit add result assigned back to 4-bit reg
//     widened        Bug 3: 4-bit input zero-extended into 8-bit reg
//     narrowed       Bug 4: 8-bit input dropped into 4-bit reg
//-----------------------------------------------------------------------------

module width_bugs (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [7:0] big,
    output reg  [3:0] sum_truncated,
    output reg  [3:0] sum_overflow,
    output reg  [7:0] widened,
    output reg  [3:0] narrowed
);

    // Bug 1: unsized literal `1` is 32-bit; adding to 4-bit result truncates.
    always @(*) sum_truncated = a + b + 1;

    // Bug 2: 5-bit add result assigned back to 4-bit reg.
    always @(*) sum_overflow  = {1'b0, a} + {1'b0, b};

    // Bug 3: 4-bit input zero-extended into 8-bit reg without explicit pad.
    always @(*) widened       = a;

    // Bug 4: 8-bit input dropped into 4-bit reg.
    always @(*) narrowed      = big;

endmodule
