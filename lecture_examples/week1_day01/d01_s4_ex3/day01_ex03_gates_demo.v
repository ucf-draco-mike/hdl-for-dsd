//-----------------------------------------------------------------------------
// File:    day01_ex03_gates_demo.v
// Course:  Accelerated HDL for Digital System Design — Day 1
// Slide:   d01_s4 "Gates in Verilog" Live Demo
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   Walks the four gates from the Day 1 digital-logic refresher and shows
//   how each maps directly to a continuous-assignment in Verilog. The
//   bottom output is a sum-of-products / DeMorgan equivalent — proof that
//   "write for readability, the synthesizer flattens the algebra".
//
//   o_and  = a & b
//   o_or   = a | b
//   o_xor  = a ^ b
//   o_sop  = (a & b) | (~a & ~b)              // XNOR sum-of-products form
//   o_dem  = ~(~(a & b) & ~(~a & ~b))         // Same logic, DeMorgan's
//
//   The point of the demo: o_sop and o_dem are bit-identical at every
//   instant. The synthesizer reduces both to one LUT4.
//
// Build:
//   yosys -p "synth_ice40 -top gates_demo -json gates_demo.json" \
//         day01_ex03_gates_demo.v
//-----------------------------------------------------------------------------

module gates_demo (
    input  wire i_a,
    input  wire i_b,
    output wire o_and,
    output wire o_or,
    output wire o_xor,
    output wire o_sop,
    output wire o_dem
);

    // Three primitive gates — one assign each.
    assign o_and = i_a & i_b;
    assign o_or  = i_a | i_b;
    assign o_xor = i_a ^ i_b;

    // Compound expression — sum-of-products form of XNOR.
    assign o_sop = (i_a & i_b) | (~i_a & ~i_b);

    // Same compound expression rewritten via DeMorgan's law —
    // identical hardware after synthesis.
    assign o_dem = ~(~(i_a & i_b) & ~(~i_a & ~i_b));

endmodule
