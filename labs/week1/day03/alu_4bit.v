// Exercise: 4-bit ALU with 4 operations
module alu_4bit (
    input  wire [3:0] i_a, i_b,
    input  wire [1:0] i_opcode,
    output reg  [3:0] o_result,
    output wire       o_zero,
    output reg        o_carry
);
    // Opcodes: 00=ADD, 01=SUB, 10=AND, 11=OR
    localparam OP_ADD = 2'b00,
               OP_SUB = 2'b01,
               OP_AND = 2'b10,
               OP_OR  = 2'b11;

    reg [4:0] r_wide_result;

    always @(*) begin
        r_wide_result = 5'd0;  // default
        case (i_opcode)
            OP_ADD: r_wide_result = {1'b0, i_a} + {1'b0, i_b};
            OP_SUB: r_wide_result = {1'b0, i_a} - {1'b0, i_b};
            OP_AND: r_wide_result = {1'b0, i_a & i_b};
            OP_OR:  r_wide_result = {1'b0, i_a | i_b};
            default: r_wide_result = 5'd0;
        endcase
        o_result = r_wide_result[3:0];
        o_carry  = r_wide_result[4];
    end

    assign o_zero = (o_result == 4'd0);
endmodule
