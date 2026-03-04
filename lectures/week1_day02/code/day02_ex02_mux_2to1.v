//-----------------------------------------------------------------------------
// File:    day02_ex02_mux_2to1.v
// Course:  Accelerated HDL for Digital System Design — Day 2
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   Parameterized 2-to-1 multiplexer using the conditional operator.
//   When sel=1, output is a; when sel=0, output is b.
//
// Build:
//   yosys -p "synth_ice40 -top mux_2to1 -json day02_ex02_mux_2to1.json" day02_ex02_mux_2to1.v
//-----------------------------------------------------------------------------
module mux_2to1 #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] i_a,
    input  wire [WIDTH-1:0] i_b,
    input  wire             i_sel,
    output wire [WIDTH-1:0] o_y
);
    assign o_y = i_sel ? i_a : i_b;
endmodule
