// =============================================================================
// latch_demo.v — Intentional Latch Inference (for teaching purposes)
// Day 3: Procedural Combinational Logic
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Description:
//   This module INTENTIONALLY infers a latch. Used in the lecture to
//   demonstrate how incomplete assignments cause latch inference, and
//   how Yosys warns about it.
//
//   Synthesize with: yosys -p "synth_ice40 -top latch_demo" latch_demo.v
//   Look for: Warning: Latch inferred for signal `\o_y'
// =============================================================================

module latch_demo (
    input  wire       i_sel,
    input  wire [3:0] i_a,
    output reg  [3:0] o_y
);

    // BUG: No else clause → when i_sel=0, o_y retains its value → LATCH
    always @(*) begin
        if (i_sel)
            o_y = i_a;
        // Missing: else o_y = 4'b0;
    end

endmodule
