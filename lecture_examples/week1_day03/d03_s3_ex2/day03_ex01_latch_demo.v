//-----------------------------------------------------------------------------
// File:    day03_ex01_latch_demo.v
// Course:  Accelerated HDL for Digital System Design — Day 3
//
// Description:
//   INTENTIONAL latch inference examples for educational purposes.
//   Synthesize with: yosys -p "synth_ice40 -top latch_demo" day03_ex01_latch_demo.v
//   Observe the latch warnings in Yosys output.
//   Then compare with day03_ex02_latch_fixed.v
//-----------------------------------------------------------------------------
module latch_demo (
    input  wire       i_sel,
    input  wire       i_enable,
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire [1:0] i_opcode,
    output reg  [3:0] o_bug1,
    output reg  [3:0] o_bug2
);
    // BUG 1: Missing else — latch on o_bug1
    always @(*) begin
        if (i_sel)
            o_bug1 = i_a;
        // no else! → LATCH
    end

    // BUG 2: Incomplete case — latch on o_bug2
    always @(*) begin
        case (i_opcode)
            2'b00: o_bug2 = i_a;
            2'b01: o_bug2 = i_b;
            // 2'b10, 2'b11 missing → LATCH
        endcase
    end
endmodule
