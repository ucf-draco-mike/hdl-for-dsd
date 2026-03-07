// =============================================================================
// Exercise 3, Part A: Full Adder
// Day 2 · Combinational Building Blocks
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================

module full_adder (
    input  wire i_a,
    input  wire i_b,
    input  wire i_cin,
    output wire o_sum,
    output wire o_cout
);

    assign o_sum  = i_a ^ i_b ^ i_cin;
    assign o_cout = (i_a & i_b) | (i_a & i_cin) | (i_b & i_cin);

endmodule
