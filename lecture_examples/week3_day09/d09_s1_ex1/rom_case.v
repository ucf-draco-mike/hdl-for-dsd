// =============================================================================
// rom_case.v — Case-Based ROM (LUT-Inferred)
// Day 9 · Topic 9.1: ROM in Verilog · Demo example 1
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Tiny ROM written as a combinational case statement. Synthesizes to LUTs.
// Readable for ~16 entries; doesn't scale.
// Pairs with rom_array.v for the "case vs array" comparison demo.
// =============================================================================

module rom_case (
    input  wire [2:0] i_addr,
    output reg  [7:0] o_data
);

    always @(*) begin
        case (i_addr)
            3'd0: o_data = 8'h48;   // 'H'
            3'd1: o_data = 8'h45;   // 'E'
            3'd2: o_data = 8'h4C;   // 'L'
            3'd3: o_data = 8'h4C;   // 'L'
            3'd4: o_data = 8'h4F;   // 'O'
            default: o_data = 8'h00;
        endcase
    end

endmodule
