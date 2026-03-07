// =============================================================================
// Exercise 2, Part A: 2:1 Multiplexer
// Day 2 · Combinational Building Blocks
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================

module mux2to1 (
    input  wire i_a,
    input  wire i_b,
    input  wire i_sel,
    output wire o_y
);

    // sel=0 -> a, sel=1 -> b
    assign o_y = i_sel ? i_b : i_a;

endmodule
