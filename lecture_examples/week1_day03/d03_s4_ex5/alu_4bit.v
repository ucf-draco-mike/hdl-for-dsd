//-----------------------------------------------------------------------------
// File:    alu_4bit.v
// Course:  Accelerated HDL for Digital System Design - Day 3
// Demo:    d03_s4 - Combinational Capstone (baseline)
//
// Description:
//   Baseline 4-bit ALU - 4 ops (ADD, SUB, AND, OR). Mirrors d03_s2_ex1 so the
//   capstone session can stat-compare it against alu_4bit_ext side by side.
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
        o_carry  = 1'b0;
        o_result = 4'b0000;
        case (i_op)
            2'b00: {o_carry, o_result} = i_a + i_b;
            2'b01: {o_carry, o_result} = i_a - i_b;
            2'b10: o_result = i_a & i_b;
            2'b11: o_result = i_a | i_b;
            default: o_result = 4'b0000;
        endcase
    end

    assign o_zero = (o_result == 4'b0000);
endmodule
