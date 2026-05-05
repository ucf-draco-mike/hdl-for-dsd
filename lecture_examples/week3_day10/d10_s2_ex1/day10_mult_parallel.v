// =============================================================================
// day10_mult_parallel.v — Parameterized Combinational (Parallel) Multiplier
// Day 10: Numerical Architectures & Design Trade-offs
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Parallel multiplier — one synthesis pass per WIDTH. Demonstrates LUT
// growth that scales roughly as O(WIDTH^2) on iCE40 (no hard DSP blocks).
//
//   yosys -p "read_verilog -DWIDTH=8  day10_mult_parallel.v; \
//             synth_ice40 -top mult_parallel; stat"
//   yosys -p "read_verilog -DWIDTH=16 day10_mult_parallel.v; \
//             synth_ice40 -top mult_parallel; stat"
//
// Override WIDTH from the Makefile via:  make stat WIDTH=8
// =============================================================================

`ifndef WIDTH
`define WIDTH 8
`endif

module mult_parallel #(
    parameter W = `WIDTH
)(
    input  wire [W-1:0]   i_a,
    input  wire [W-1:0]   i_b,
    output wire [2*W-1:0] o_product
);
    assign o_product = i_a * i_b;
endmodule
