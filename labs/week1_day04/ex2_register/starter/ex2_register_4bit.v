// =============================================================================
// Exercise 2: 4-Bit Loadable Register
// Day 4 · Sequential Logic Fundamentals
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================

module register_4bit (
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_load,
    input  wire [3:0] i_data,
    output reg  [3:0] o_q
);

    // TODO: Implement the register
    // On posedge clk:
    //   if reset: clear to 0
    //   else if load: capture i_data
    //   else: hold current value

endmodule
