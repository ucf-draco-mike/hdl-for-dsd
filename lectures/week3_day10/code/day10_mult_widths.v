// =============================================================================
// day10_mult_widths.v — Combinational Multiplier at Multiple Widths
// Day 10: Numerical Architectures & Design Trade-offs
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Synthesize each module independently to see LUT explosion:
//   yosys -p "read_verilog day10_mult_widths.v; synth_ice40 -top mult_4bit;  stat"
//   yosys -p "read_verilog day10_mult_widths.v; synth_ice40 -top mult_8bit;  stat"
//   yosys -p "read_verilog day10_mult_widths.v; synth_ice40 -top mult_16bit; stat"
//
// Compare: adder LUTs grow linearly; multiplier LUTs grow quadratically.
// iCE40 has NO DSP blocks — every * is pure LUT logic.
// =============================================================================

module mult_4bit (
    input  wire [3:0] i_a, i_b,
    output wire [7:0] o_product
);
    assign o_product = i_a * i_b;
endmodule

module mult_8bit (
    input  wire [7:0]  i_a, i_b,
    output wire [15:0] o_product
);
    assign o_product = i_a * i_b;
endmodule

module mult_16bit (
    input  wire [15:0] i_a, i_b,
    output wire [31:0] o_product
);
    assign o_product = i_a * i_b;
endmodule
