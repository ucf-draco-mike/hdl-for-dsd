// =============================================================================
// alu_4bit.v — 4-Bit ALU with Case Statement
// Day 3: Procedural Combinational Logic
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Description:
//   A simple 4-bit ALU that demonstrates the case statement pattern.
//   Supports 8 operations selected by a 3-bit opcode.
//
// Operations:
//   000 → ADD       001 → SUB       010 → AND       011 → OR
//   100 → XOR       101 → NOT A     110 → SHL       111 → SHR
// =============================================================================

module alu_4bit (
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire [2:0] i_opcode,
    output reg  [3:0] o_result,
    output reg        o_zero       // flag: result == 0
);

    always @(*) begin
        // Default assignments prevent latches
        o_result = 4'b0000;
        o_zero   = 1'b0;

        case (i_opcode)
            3'b000:  o_result = i_a + i_b;      // ADD
            3'b001:  o_result = i_a - i_b;      // SUB
            3'b010:  o_result = i_a & i_b;      // AND
            3'b011:  o_result = i_a | i_b;      // OR
            3'b100:  o_result = i_a ^ i_b;      // XOR
            3'b101:  o_result = ~i_a;            // NOT A
            3'b110:  o_result = i_a << 1;        // Shift left
            3'b111:  o_result = i_a >> 1;        // Shift right
            default: o_result = 4'b0000;         // safety net
        endcase

        // Zero flag — set when result is all zeros
        o_zero = (o_result == 4'b0000);
    end

endmodule
