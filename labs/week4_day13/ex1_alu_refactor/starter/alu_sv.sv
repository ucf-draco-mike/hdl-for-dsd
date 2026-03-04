// =============================================================================
// alu_sv.sv — ALU Refactored with SystemVerilog
// Day 13, Exercise 1
// =============================================================================
// Refactor the Day 3 ALU to use: logic, always_comb, enum opcodes

module alu_sv #(
    parameter int WIDTH = 4
)(
    input  logic [1:0]       i_opcode,
    input  logic [WIDTH-1:0] i_a,
    input  logic [WIDTH-1:0] i_b,
    output logic [WIDTH-1:0] o_result,
    output logic             o_carry,
    output logic             o_zero
);

    // TODO: Define an enum for opcodes
    // typedef enum logic [1:0] {
    //     OP_ADD = 2'b00,
    //     OP_SUB = 2'b01,
    //     OP_AND = 2'b10,
    //     OP_OR  = 2'b11
    // } alu_op_t;

    // ---- YOUR CODE HERE ----

    // TODO: Replace always @(*) with always_comb
    //   - Set defaults for o_carry and o_result at the top
    //   - Use the enum names in the case statement
    //   - Benefit: if you miss a case, the compiler ERRORS
    //     (unlike Verilog which silently infers a latch)

    // ---- YOUR CODE HERE ----

    assign o_zero = (o_result == '0);  // Note: '0 is SV shorthand for all-zeros

endmodule
