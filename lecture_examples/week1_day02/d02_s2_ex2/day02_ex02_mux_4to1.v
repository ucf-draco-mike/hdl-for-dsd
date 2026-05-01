//-----------------------------------------------------------------------------
// File:    day02_ex02_mux_4to1.v
// Course:  Accelerated HDL for Digital System Design — Day 2
// Slide:   d02_s2 "Building a 4:1 Mux + Cost Comparison" Live Demo
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   Two ways to build a 4-to-1 multiplexer in pure combinational Verilog:
//
//     (1) mux_4to1_nested  — nested conditional ?: chain
//     (2) mux_4to1_case    — `always @(*)` with a `case` statement
//
//   Both modules are bit-identical at synthesis. The demo shows
//   `make stat` producing the same LUT count for each — proof that the
//   way you SPELL combinational logic doesn't matter; what matters is
//   the truth table.
//-----------------------------------------------------------------------------

// ----- Variant (1): nested conditional -------------------------------------
module mux_4to1_nested #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] i_a,
    input  wire [WIDTH-1:0] i_b,
    input  wire [WIDTH-1:0] i_c,
    input  wire [WIDTH-1:0] i_d,
    input  wire [1:0]       i_sel,
    output wire [WIDTH-1:0] o_y
);
    assign o_y = (i_sel == 2'b00) ? i_a :
                 (i_sel == 2'b01) ? i_b :
                 (i_sel == 2'b10) ? i_c :
                                    i_d;
endmodule


// ----- Variant (2): `case` statement in always @(*) ------------------------
module mux_4to1_case #(
    parameter WIDTH = 4
)(
    input  wire [WIDTH-1:0] i_a,
    input  wire [WIDTH-1:0] i_b,
    input  wire [WIDTH-1:0] i_c,
    input  wire [WIDTH-1:0] i_d,
    input  wire [1:0]       i_sel,
    output reg  [WIDTH-1:0] o_y
);
    always @(*) begin
        case (i_sel)
            2'b00:   o_y = i_a;
            2'b01:   o_y = i_b;
            2'b10:   o_y = i_c;
            default: o_y = i_d;
        endcase
    end
endmodule
