//-----------------------------------------------------------------------------
// File:    op_compare.v
// Course:  Accelerated HDL for Digital System Design — Day 2
// Slide:   d02_s2 "Operator Cost Showdown" Live Demo
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   Three single-line 8-bit modules — one per operator — written so that
//   `yosys synth_ice40 stat` makes the cost ratio obvious. Each module's
//   body is a single `assign`, so every LUT/carry the tool reports is
//   attributable to the operator on that line and nothing else.
//
//   This is the deck's "What Did the Tool Build?" table, materialized.
//   Run `make stat-ops` to print all three side by side.
//
//   Expected synth_ice40 stat (HX1K, no DSP blocks):
//
//     bitwise_and :  ~8 SB_LUT4   ·   0 SB_CARRY     ─ Cheap
//     adder       :  ~8 SB_LUT4   ·  ~8 SB_CARRY     ─ Moderate
//     multiplier  : ~80 SB_LUT4   · ~24 SB_CARRY     ─ Expensive
//
//   The ratio is the lesson, not the absolute count. Edit the WIDTH on
//   any module and re-stat to watch the multiplier blow up quadratically
//   while the AND stays linear.
//-----------------------------------------------------------------------------

// ----- Cheap: per-bit AND, no carry chain ----------------------------------
module bitwise_and #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] i_a,
    input  wire [WIDTH-1:0] i_b,
    output wire [WIDTH-1:0] o_y
);
    assign o_y = i_a & i_b;
endmodule


// ----- Moderate: ripple-carry add, one carry cell per bit ------------------
module adder #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] i_a,
    input  wire [WIDTH-1:0] i_b,
    output wire [WIDTH-1:0] o_y
);
    assign o_y = i_a + i_b;
endmodule


// ----- Expensive: N×N partial-product grid, no DSP block on HX1K -----------
module multiplier #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0]     i_a,
    input  wire [WIDTH-1:0]     i_b,
    output wire [2*WIDTH-1:0]   o_y
);
    assign o_y = i_a * i_b;
endmodule
