//-----------------------------------------------------------------------------
// File:    day03_ex03_alu_4bit.v
// Course:  Accelerated HDL for Digital System Design — Day 3
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   4-bit ALU demonstrating case statement pattern.
//   Operations: ADD, SUB, AND, OR selected by 2-bit opcode.
//   Includes zero flag and carry output.
//
// Build:
//   yosys -p "synth_ice40 -top alu_4bit -json day03_ex03_alu_4bit.json" day03_ex03_alu_4bit.v
//-----------------------------------------------------------------------------
module alu_4bit (
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire [1:0] i_op,
    output reg  [3:0] o_result,
    output wire       o_zero,
    output reg        o_carry
);
    always @(*) begin
        o_carry  = 1'b0;       // default
        o_result = 4'b0000;    // default
        case (i_op)
            2'b00: {o_carry, o_result} = i_a + i_b;  // ADD
            2'b01: {o_carry, o_result} = i_a - i_b;  // SUB
            2'b10: o_result = i_a & i_b;              // AND
            2'b11: o_result = i_a | i_b;              // OR
            default: o_result = 4'b0000;
        endcase
    end

    assign o_zero = (o_result == 4'b0000);
endmodule
