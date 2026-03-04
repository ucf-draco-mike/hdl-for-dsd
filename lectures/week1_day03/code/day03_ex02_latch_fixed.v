//-----------------------------------------------------------------------------
// File:    day03_ex02_latch_fixed.v
// Course:  Accelerated HDL for Digital System Design — Day 3
//
// Description:
//   Fixed versions of the latch examples from day03_ex01_latch_demo.v.
//   Uses default assignment and default case to prevent latches.
//   Synthesize and verify: NO latch warnings.
//-----------------------------------------------------------------------------
module latch_fixed (
    input  wire       i_sel,
    input  wire       i_enable,
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire [1:0] i_opcode,
    output reg  [3:0] o_fix1,
    output reg  [3:0] o_fix2
);
    // FIX 1: Default assignment at top
    always @(*) begin
        o_fix1 = 4'b0000;   // default: covers all paths
        if (i_sel)
            o_fix1 = i_a;
    end

    // FIX 2: Complete case with default
    always @(*) begin
        case (i_opcode)
            2'b00:   o_fix2 = i_a;
            2'b01:   o_fix2 = i_b;
            2'b10:   o_fix2 = i_a & i_b;
            2'b11:   o_fix2 = i_a | i_b;
            default: o_fix2 = 4'b0000;
        endcase
    end
endmodule
