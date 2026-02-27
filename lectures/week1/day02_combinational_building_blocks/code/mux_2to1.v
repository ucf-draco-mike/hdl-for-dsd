// =============================================================================
// mux_2to1.v — 2-to-1 Multiplexer
// Day 2: Combinational Building Blocks
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================

module mux_2to1 #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] i_a,
    input  wire [WIDTH-1:0] i_b,
    input  wire             i_sel,
    output wire [WIDTH-1:0] o_y
);

    // Conditional operator: sel=1 → a, sel=0 → b
    assign o_y = i_sel ? i_a : i_b;

endmodule
