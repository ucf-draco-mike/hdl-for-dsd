// =============================================================================
// Exercise 1: D Flip-Flop
// Day 4 · Sequential Logic Fundamentals
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Part A: Basic D-FF with synchronous reset
// Part B: D-FF with clock enable (d_ff_en — uncomment below)
// =============================================================================

module d_ff (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_d,
    output reg  o_q
);

    // TODO: Implement the D flip-flop
    // On posedge i_clk:
    //   if i_reset: o_q <= 0
    //   else: o_q <= i_d
    //
    // always @(posedge i_clk) begin
    //     ...
    // end

endmodule

// Part B: D-FF with clock enable — uncomment and implement
//
// module d_ff_en (
//     input  wire i_clk,
//     input  wire i_reset,
//     input  wire i_enable,
//     input  wire i_d,
//     output reg  o_q
// );
//
//     // On posedge i_clk:
//     //   if reset: clear
//     //   else if enable: capture i_d
//     //   else: hold (no latch — this is sequential!)
//
//     always @(posedge i_clk) begin
//         // TODO
//     end
//
// endmodule
