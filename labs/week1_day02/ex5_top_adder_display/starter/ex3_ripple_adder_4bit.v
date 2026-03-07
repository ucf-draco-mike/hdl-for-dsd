// =============================================================================
// Exercise 3, Part B: 4-Bit Ripple-Carry Adder
// Day 2 · Combinational Building Blocks
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Instantiate four full_adder modules to create a 4-bit adder.
// The carry output of each stage feeds into the carry input of the next.
// =============================================================================

module ripple_adder_4bit (
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire       i_cin,
    output wire [3:0] o_sum,
    output wire       o_cout
);

    wire [3:1] w_carry;  // internal carry chain

    // TODO: Instantiate four full_adder modules
    // Use named port connections!
    //
    // full_adder fa0 (.i_a(i_a[0]), .i_b(i_b[0]), .i_cin(i_cin),       .o_sum(o_sum[0]), .o_cout(w_carry[1]));
    // full_adder fa1 ( ... );
    // full_adder fa2 ( ... );
    // full_adder fa3 (.i_a(i_a[3]), .i_b(i_b[3]), .i_cin(w_carry[3]),  .o_sum(o_sum[3]), .o_cout(o_cout));

endmodule
