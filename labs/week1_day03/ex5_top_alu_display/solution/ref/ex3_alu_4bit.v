// =============================================================================
// Exercise 3 SOLUTION: 4-Bit ALU
// Day 3 · Procedural Combinational Logic
// =============================================================================

module alu_4bit (
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire [1:0] i_opcode,
    output reg  [3:0] o_result,
    output reg        o_zero,
    output reg        o_carry
);

    always @(*) begin
        o_result = 4'b0000;
        o_carry  = 1'b0;

        case (i_opcode)
            2'b00: {o_carry, o_result} = i_a + i_b;    // ADD
            2'b01: {o_carry, o_result} = i_a - i_b;    // SUB
            2'b10: o_result = i_a & i_b;                // AND
            2'b11: o_result = i_a | i_b;                // OR
        endcase

        o_zero = ~(|o_result);
    end

endmodule
