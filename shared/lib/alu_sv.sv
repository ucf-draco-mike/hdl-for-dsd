// =============================================================================
// alu_sv.sv — 4-Bit ALU Refactored with SystemVerilog
// Day 13: SystemVerilog for Design
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Demonstrates: logic type, always_comb (catches missing defaults),
//   enum for opcode naming, parameter int.

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

    // Named opcodes via enum
    typedef enum logic [1:0] {
        OP_ADD = 2'b00,
        OP_SUB = 2'b01,
        OP_AND = 2'b10,
        OP_OR  = 2'b11
    } alu_op_t;

    // always_comb: compiler errors if latch would be inferred
    always_comb begin
        o_carry  = 1'b0;
        o_result = '0;

        case (i_opcode)
            OP_ADD:  {o_carry, o_result} = i_a + i_b;
            OP_SUB:  {o_carry, o_result} = i_a - i_b;
            OP_AND:  o_result = i_a & i_b;
            OP_OR:   o_result = i_a | i_b;
            // No default needed — all 2-bit values covered.
            // But if we added a 3rd opcode bit and missed a case,
            // always_comb would ERROR. always @(*) would silently latch.
        endcase
    end

    assign o_zero = (o_result == '0);

endmodule
