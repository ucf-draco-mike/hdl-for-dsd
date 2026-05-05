//-----------------------------------------------------------------------------
// File:    day03_ex04_mux_assign.v
// Course:  Accelerated HDL for Digital System Design — Day 3, Topic 3.1
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   4:1 multiplexer written with a single `assign` and nested ternary.
//   Companion to day03_ex05_mux_always.v (same hardware, different syntax).
//   Demonstrates the slide claim: `assign` and `always @(*)` produce
//   identical synthesized hardware.
//-----------------------------------------------------------------------------
module mux_assign (
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire [3:0] i_c,
    input  wire [3:0] i_d,
    input  wire [1:0] i_sel,
    output wire [3:0] o_y
);
    assign o_y = (i_sel == 2'b00) ? i_a :
                 (i_sel == 2'b01) ? i_b :
                 (i_sel == 2'b10) ? i_c : i_d;
endmodule
