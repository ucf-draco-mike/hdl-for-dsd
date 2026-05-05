//-----------------------------------------------------------------------------
// File:    day04_ex01_d_flip_flop.v
// Course:  Accelerated HDL for Digital System Design — Day 4
//
// Description:
//   Bare D flip-flop. The fundamental sequential primitive.
//   Synthesizes to a single SB_DFF on iCE40.
//
//   For the reset + enable variant covered in segment s3, see the
//   companion module reg_4bit_rst_en in day04_ex01b_reg_4bit_rst_en.v.
//-----------------------------------------------------------------------------
module d_flip_flop (
    input  wire i_clk,
    input  wire i_d,
    output reg  o_q
);
    always @(posedge i_clk)
        o_q <= i_d;
endmodule
