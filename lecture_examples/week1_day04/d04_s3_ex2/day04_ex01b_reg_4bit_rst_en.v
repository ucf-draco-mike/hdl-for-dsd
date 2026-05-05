//-----------------------------------------------------------------------------
// File:    day04_ex01b_reg_4bit_rst_en.v
// Course:  Accelerated HDL for Digital System Design — Day 4
//
// Description:
//   4-bit register with synchronous reset and clock enable.
//   Companion to day04_ex01_d_flip_flop.v — same pattern at vector width.
//   Synthesizes to 4× SB_DFFESR on iCE40 (zero LUTs).
//-----------------------------------------------------------------------------
module reg_4bit_rst_en (
    input  wire        i_clk,
    input  wire        i_reset,
    input  wire        i_enable,
    input  wire [3:0]  i_d,
    output reg  [3:0]  o_q
);
    always @(posedge i_clk) begin
        if (i_reset)
            o_q <= 4'b0;
        else if (i_enable)
            o_q <= i_d;
        // else: o_q holds — flop hold, NOT a latch
    end
endmodule
