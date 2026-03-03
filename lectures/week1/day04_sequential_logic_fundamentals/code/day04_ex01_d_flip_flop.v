//-----------------------------------------------------------------------------
// File:    day04_ex01_d_flip_flop.v
// Course:  Accelerated HDL for Digital System Design — Day 4
//
// Description:
//   D flip-flop with synchronous reset and optional clock enable.
//   This is the fundamental sequential building block.
//
// Simulate:
//   iverilog -o d_ff_tb day04_ex01_d_flip_flop.v tb_d_ff.v
//   vvp d_ff_tb
//   gtkwave d_ff_tb.vcd
//-----------------------------------------------------------------------------
module d_flip_flop (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_enable,
    input  wire i_d,
    output reg  o_q
);
    always @(posedge i_clk) begin
        if (i_reset)
            o_q <= 1'b0;
        else if (i_enable)
            o_q <= i_d;
        // else: o_q holds — NOT a latch (this is sequential)
    end
endmodule
