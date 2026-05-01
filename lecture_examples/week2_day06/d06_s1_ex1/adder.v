//-----------------------------------------------------------------------------
// File:    adder.v
// Course:  Accelerated HDL for Digital System Design — Day 6
// Slides:  d06_s1..s4 (Testbench-anatomy progression)
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   Plain unsigned 8-bit ripple adder used as the device under test for
//   every Day-6 testbench demo. Kept deliberately tiny so the testbenches
//   are the focus of the lesson, not the DUT.
//-----------------------------------------------------------------------------

module adder #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] a,
    input  wire [WIDTH-1:0] b,
    output wire [WIDTH:0]   sum   // WIDTH+1 bits to capture the carry
);
    assign sum = {1'b0, a} + {1'b0, b};
endmodule
