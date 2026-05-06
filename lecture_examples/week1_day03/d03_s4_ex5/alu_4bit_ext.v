//-----------------------------------------------------------------------------
// File:    alu_4bit_ext.v
// Course:  Accelerated HDL for Digital System Design - Day 3
// Demo:    d03_s4 - Combinational Capstone (extended ALU)
//
// Description:
//   Extended 4-bit ALU - 6 ops: ADD, SUB, AND, OR, XOR, SHL.
//   The shift uses a variable amount (i_shamt) to demonstrate barrel-shifter
//   cost vs. constant-shift "free" cost from the D2.2 operator table.
//
// Capstone techniques in use:
//   - D2.1 vectors / concatenation       ({o_carry, o_result} = a + b)
//   - D2.2 operator costs                (XOR cheap, variable << expensive)
//   - D2.3 sized literals                (4'b0000 defaults)
//   - D3.1 always @(*)                   (combinational block)
//   - D3.2 case (parallel mux topology)
//   - D3.3 default assignments + case-default (latch-free)
//-----------------------------------------------------------------------------
module alu_4bit_ext (
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire [2:0] i_op,
    input  wire [2:0] i_shamt,      // variable shift amount -> barrel shifter
    output reg  [3:0] o_result,
    output wire       o_zero,
    output reg        o_carry
);
    always @(*) begin
        o_carry  = 1'b0;            // D3.3: default every output
        o_result = 4'b0000;         // D2.3 sized literal default
        case (i_op)
            3'b000: {o_carry, o_result} = i_a + i_b;     // ADD - carry chain
            3'b001: {o_carry, o_result} = i_a - i_b;     // SUB - carry chain
            3'b010: o_result = i_a & i_b;                 // AND - cheap
            3'b011: o_result = i_a | i_b;                 // OR  - cheap
            3'b100: o_result = i_a ^ i_b;                 // XOR - cheap
            3'b101: o_result = i_a << i_shamt;            // SHL - barrel shifter (expensive)
            default: o_result = 4'b0000;                  // D3.2 case-default safety
        endcase
    end

    assign o_zero = (o_result == 4'b0000);
endmodule
