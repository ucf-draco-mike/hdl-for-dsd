// =============================================================================
// shift_add_mult.v — Sequential Shift-and-Add Multiplier
// Day 10, Exercise 2
// =============================================================================
// Implement an 8-bit unsigned multiplier using the shift-and-add algorithm.
// Architecture: FSM + shift register + accumulator
//
// Algorithm:
//   1. Load multiplicand and multiplier
//   2. For each bit of the multiplier (LSB first):
//      - If current multiplier bit is 1, add multiplicand to accumulator
//      - Shift multiplicand left (or shift multiplier right)
//   3. After 8 iterations, accumulator holds the product
//
// Compare resource usage to: assign product = a * b; (combinational)
// =============================================================================

module shift_add_mult (
    input  wire        i_clk,
    input  wire        i_rst,
    input  wire        i_start,    // pulse to begin multiplication
    input  wire [7:0]  i_a,        // multiplicand
    input  wire [7:0]  i_b,        // multiplier
    output reg  [15:0] o_product,  // result
    output reg         o_done,     // pulse when complete
    output reg         o_busy      // high during computation
);

    // FSM states
    localparam IDLE    = 2'b00;
    localparam COMPUTE = 2'b01;
    localparam DONE    = 2'b10;

    reg [1:0]  r_state;
    reg [15:0] r_accumulator;
    reg [7:0]  r_multiplicand_shifted; // or use a wider register
    reg [7:0]  r_multiplier;
    reg [3:0]  r_bit_count;  // counts 0 to 7

    // TODO: Implement the FSM and datapath
    //
    // IDLE state:
    //   - Wait for i_start
    //   - On i_start: load operands, clear accumulator, go to COMPUTE
    //
    // COMPUTE state:
    //   - Check LSB of r_multiplier
    //   - If 1: add r_multiplicand_shifted to r_accumulator
    //   - Shift r_multiplier right by 1
    //   - Shift r_multiplicand_shifted left by 1 (or use a wider shift)
    //   - Increment r_bit_count
    //   - After 8 iterations: go to DONE
    //
    // DONE state:
    //   - Output the product
    //   - Pulse o_done
    //   - Return to IDLE
    //
    // Hint: You can use a 16-bit register for the shifted multiplicand
    //       to avoid overflow: reg [15:0] r_mcand;

    // ---- YOUR CODE HERE ----

endmodule

// ---- For comparison: combinational multiplier ----
module comb_mult (
    input  wire [7:0]  i_a, i_b,
    output wire [15:0] o_product
);
    assign o_product = i_a * i_b;
endmodule
