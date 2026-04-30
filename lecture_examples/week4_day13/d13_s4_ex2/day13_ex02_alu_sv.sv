// =============================================================================
// day13_ex02_alu_sv.sv — ALU Refactored in SystemVerilog
// Day 13: SystemVerilog for Design
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Demonstrates: logic, always_comb, enum for opcodes.
// Compared to Verilog version: stronger latch checking, typed opcodes.
// =============================================================================
// Build:  iverilog -g2012 -DSIMULATION -o sim day13_ex02_alu_sv.sv && vvp sim
// =============================================================================

module alu_sv #(
    parameter int WIDTH = 4
)(
    input  logic [WIDTH-1:0]  i_a,
    input  logic [WIDTH-1:0]  i_b,
    input  logic [1:0]        i_op,
    output logic [WIDTH-1:0]  o_result,
    output logic              o_carry,
    output logic              o_zero
);

    // ---- Opcode Enum ----
    typedef enum logic [1:0] {
        OP_ADD = 2'b00,
        OP_SUB = 2'b01,
        OP_AND = 2'b10,
        OP_OR  = 2'b11
    } alu_op_t;

    logic [WIDTH:0] full_result;   // extra bit for carry

    // always_comb: auto-sensitivity, catches latches
    always_comb begin
        full_result = '0;   // default prevents latch

        case (i_op)
            OP_ADD: full_result = {1'b0, i_a} + {1'b0, i_b};
            OP_SUB: full_result = {1'b0, i_a} - {1'b0, i_b};
            OP_AND: full_result = {1'b0, i_a & i_b};
            OP_OR:  full_result = {1'b0, i_a | i_b};
            default: full_result = '0;
        endcase
    end

    assign o_result = full_result[WIDTH-1:0];
    assign o_carry  = full_result[WIDTH];
    assign o_zero   = (o_result == '0);

endmodule
