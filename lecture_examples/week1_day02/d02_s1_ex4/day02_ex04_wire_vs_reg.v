//-----------------------------------------------------------------------------
// File:    day02_ex04_wire_vs_reg.v
// Course:  Accelerated HDL for Digital System Design — Day 2 · Segment 1
// Slide:   d02_s1_data_types_and_vectors.html#/3
//          ("I Do — Four Declarations, Four Meanings")
//
// Description:
//   Runnable companion to slide 3 of the Data Types & Vectors lecture. The
//   slide makes the central claim of Day 2:
//
//       wire vs reg are SYNTAX categories, not hardware categories.
//
//   This module collects all four cases from the slide into one synthesizable
//   block so students can (a) simulate the behavior with the testbench and
//   (b) ask Yosys what each case actually maps to:
//
//       Case 1 │ wire + assign       → combinational adder   (no flop)
//       Case 2 │ reg  + posedge clk  → flip-flop counter      (real flops)
//       Case 3 │ reg  + always @(*)  → combinational mux      (no flop)
//       Case 4 │ reg  + missing else → INFERRED LATCH         (latch — bug)
//
//   The take-away from `make stat` is that Cases 1 and 3 produce identical
//   amounts of sequential logic (zero), even though one is a `wire` and the
//   other is a `reg`. The `reg` keyword does not imply storage.
//
// Run:
//   make sim    # iverilog + vvp; prints PASS/FAIL per case
//   make wave   # open the VCD in gtkwave (set buses to hex)
//   make stat   # ask yosys how many DFF/LATCH/LUT cells each case generates
//-----------------------------------------------------------------------------
module wire_vs_reg #(
    parameter WIDTH = 8
)(
    input  wire             i_clk,
    input  wire             i_rst_n,

    // Operands shared across cases
    input  wire [WIDTH-1:0] i_a,
    input  wire [WIDTH-1:0] i_b,
    input  wire             i_sel,
    input  wire             i_enable,
    input  wire [3:0]       i_data,

    // Case 1 — wire + assign  → combinational adder
    output wire [WIDTH-1:0] o_sum,
    // Case 2 — reg  + posedge → flip-flop counter
    output reg  [WIDTH-1:0] o_counter,
    // Case 3 — reg  + @(*)    → combinational mux
    output reg  [3:0]       o_mux,
    // Case 4 — reg  + missing else → INFERRED LATCH (intentional bug demo)
    output reg  [3:0]       o_latch
);

    // ───────── Case 1 ─────────────────────────────────────────────────────
    // Continuous assignment to a wire is, by definition, combinational.
    // Yosys synthesizes this into a ripple-carry adder — gates, no flops.
    assign o_sum = i_a + i_b;

    // ───────── Case 2 ─────────────────────────────────────────────────────
    // Procedural assignment inside an `always @(posedge ...)` infers a
    // flip-flop. This counter actually has storage.
    always @(posedge i_clk or negedge i_rst_n) begin
        if (!i_rst_n) o_counter <= {WIDTH{1'b0}};
        else          o_counter <= o_counter + 1'b1;
    end

    // ───────── Case 3 ─────────────────────────────────────────────────────
    // Same `reg` keyword as Case 2, but no clock edge in the sensitivity
    // list. Yosys synthesizes this to a 4-bit 2:1 mux — gates, no flops.
    // This is the slide's punchline: `reg` is not a register here.
    always @(*) begin
        o_mux = i_sel ? i_a[3:0] : i_b[3:0];
    end

    // ───────── Case 4 ─────────────────────────────────────────────────────
    // ⚠ Intentional bug. The `if` has no `else`, so when i_enable=0 the
    // signal must hold its previous value. The only hardware that holds a
    // value without a clock is a level-sensitive latch — Yosys will emit
    // a $_DLATCH_ cell here. Run `make stat` and you will see it.
    // (This is the bug pattern Day 3 spends a whole video on.)
    always @(*) begin
        if (i_enable) o_latch = i_data;
    end

endmodule
