//-----------------------------------------------------------------------------
// File:    width_bugs.v
// Course:  Accelerated HDL for Digital System Design — Day 2
// Slide:   d02_s3 "Width Mismatch — Compiler & Synthesis Warnings" Live Demo
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   DELIBERATELY BUGGY MODULE — every assignment below produces a width
//   warning under iverilog -Wall and yosys synth_ice40. The demo on d02_s3
//   compiles this file to make the warnings visible, then talks through
//   each one as a teaching moment.
//
//   Run it with:
//     iverilog -g2012 -Wall -o sim.vvp width_bugs.v
//     yosys -p "read_verilog width_bugs.v; synth_ice40" 2>&1 | grep -i 'warn'
//
//   The expected warnings (paraphrased):
//     line 28: "Operand of 32-bit width added to 4-bit result; truncation"
//     line 30: "Operand of 5-bit width assigned to 4-bit signal; truncation"
//     line 32: "Operand of 4-bit width assigned to 8-bit signal; widened"
//     line 34: "Operand of 8-bit width assigned to 4-bit signal; truncation"
//
//   No port list — this module is consumed only as a synthesis/lint target.
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
