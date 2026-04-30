// =============================================================================
// day08_ex02_param_alu.v — Parameterized N-Bit ALU
// Day 8: Hierarchy, Parameters & Generate
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Refactored from the Day 3 hardcoded 4-bit ALU into a reusable,
// parameterized module. Demonstrates parameter, localparam, and $clog2.
// =============================================================================
// Build:  iverilog -DSIMULATION -o sim day08_ex02_param_alu.v && vvp sim
// Synth:  yosys -p "read_verilog day08_ex02_param_alu.v; synth_ice40 -top param_alu"
// =============================================================================

module param_alu #(
    parameter WIDTH = 8
)(
    input  wire [WIDTH-1:0] i_a,
    input  wire [WIDTH-1:0] i_b,
    input  wire [2:0]       i_opcode,
    output reg  [WIDTH-1:0] o_result,
    output reg              o_carry,
    output wire             o_zero
);

    // ---- Opcode Definitions ----
    localparam OP_ADD = 3'b000;
    localparam OP_SUB = 3'b001;
    localparam OP_AND = 3'b010;
    localparam OP_OR  = 3'b011;
    localparam OP_XOR = 3'b100;
    localparam OP_NOT = 3'b101;
    localparam OP_SHL = 3'b110;
    localparam OP_SHR = 3'b111;

    // ---- Combinational ALU ----
    reg [WIDTH:0] r_wide;   // extra bit for carry

    always @(*) begin
        r_wide = {(WIDTH+1){1'b0}};  // default

        case (i_opcode)
            OP_ADD: r_wide = {1'b0, i_a} + {1'b0, i_b};
            OP_SUB: r_wide = {1'b0, i_a} - {1'b0, i_b};
            OP_AND: r_wide = {1'b0, i_a & i_b};
            OP_OR:  r_wide = {1'b0, i_a | i_b};
            OP_XOR: r_wide = {1'b0, i_a ^ i_b};
            OP_NOT: r_wide = {1'b0, ~i_a};
            OP_SHL: r_wide = {i_a, 1'b0};          // shift left (carry = MSB)
            OP_SHR: r_wide = {i_a[0], 1'b0, i_a[WIDTH-1:1]};  // shift right
            default: r_wide = {(WIDTH+1){1'b0}};
        endcase

        o_result = r_wide[WIDTH-1:0];
        o_carry  = r_wide[WIDTH];
    end

    assign o_zero = (o_result == {WIDTH{1'b0}});

endmodule
