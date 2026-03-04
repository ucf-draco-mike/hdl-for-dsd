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
    typedef enum logic [1:0] {
        OP_ADD = 2'b00, OP_SUB = 2'b01,
        OP_AND = 2'b10, OP_OR  = 2'b11
    } alu_op_t;

    always_comb begin
        o_carry  = 1'b0;
        o_result = '0;
        case (i_opcode)
            OP_ADD:  {o_carry, o_result} = i_a + i_b;
            OP_SUB:  {o_carry, o_result} = i_a - i_b;
            OP_AND:  o_result = i_a & i_b;
            OP_OR:   o_result = i_a | i_b;
        endcase
    end

    assign o_zero = (o_result == '0);
endmodule
