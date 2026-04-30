// =============================================================================
// day10_adder_widths.v — Behavioral Adder at Multiple Widths
// Day 10: Numerical Architectures & Design Trade-offs
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Synthesize each module independently to compare LUT scaling:
//   yosys -p "read_verilog day10_adder_widths.v; synth_ice40 -top adder_4bit;  stat"
//   yosys -p "read_verilog day10_adder_widths.v; synth_ice40 -top adder_8bit;  stat"
//   yosys -p "read_verilog day10_adder_widths.v; synth_ice40 -top adder_16bit; stat"
//   yosys -p "read_verilog day10_adder_widths.v; synth_ice40 -top adder_32bit; stat"
// =============================================================================

module adder_4bit (
    input  wire [3:0]  i_a, i_b,
    output wire [4:0]  o_sum
);
    assign o_sum = i_a + i_b;
endmodule

module adder_8bit (
    input  wire [7:0]  i_a, i_b,
    output wire [8:0]  o_sum
);
    assign o_sum = i_a + i_b;
endmodule

module adder_16bit (
    input  wire [15:0] i_a, i_b,
    output wire [16:0] o_sum
);
    assign o_sum = i_a + i_b;
endmodule

module adder_32bit (
    input  wire [31:0] i_a, i_b,
    output wire [32:0] o_sum
);
    assign o_sum = i_a + i_b;
endmodule
