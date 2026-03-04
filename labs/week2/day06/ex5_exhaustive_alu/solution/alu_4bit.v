// =============================================================================
// alu_4bit.v — 4-bit ALU (from Day 3, provided for testbench exercises)
// =============================================================================

module alu_4bit (
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire [1:0] i_opcode,
    output reg  [3:0] o_result,
    output reg        o_carry,
    output wire       o_zero
);

    reg [4:0] r_temp;  // 5 bits for carry detection

    always @(*) begin
        r_temp = 5'd0;
        case (i_opcode)
            2'b00: r_temp = {1'b0, i_a} + {1'b0, i_b};  // ADD
            2'b01: r_temp = {1'b0, i_a} - {1'b0, i_b};  // SUB
            2'b10: r_temp = {1'b0, i_a & i_b};           // AND
            2'b11: r_temp = {1'b0, i_a | i_b};           // OR
        endcase
        o_result = r_temp[3:0];
        o_carry  = r_temp[4];
    end

    assign o_zero = (o_result == 4'd0);

endmodule
