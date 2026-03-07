// =============================================================================
// Exercise 3: 4-Bit ALU
// Day 3 · Procedural Combinational Logic
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Operations:
//   00 → ADD    01 → SUB    10 → AND    11 → OR
//
// Outputs:
//   o_result : 4-bit result
//   o_zero   : 1 if result is zero
//   o_carry  : carry/borrow output (ADD/SUB only)
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
        // TODO: Default assignments (prevent latches on ALL outputs)

        case (i_opcode)
            2'b00: begin   // ADD
                // TODO: Use concatenation to capture carry
                // {o_carry, o_result} = i_a + i_b;
            end
            2'b01: begin   // SUB
                // TODO: Implement subtraction with borrow
                // {o_carry, o_result} = i_a - i_b;
            end
            2'b10: begin   // AND
                // TODO: Bitwise AND
            end
            2'b11: begin   // OR
                // TODO: Bitwise OR
            end
        endcase

        // TODO: Zero flag — use NOR reduction
        // o_zero = ~(|o_result);
    end

endmodule
