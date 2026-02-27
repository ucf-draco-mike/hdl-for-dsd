// =============================================================================
// latch_fixed.v — Latch-Free Version (Default Assignment Pattern)
// Day 3: Procedural Combinational Logic
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================

module latch_fixed (
    input  wire       i_sel,
    input  wire [3:0] i_a,
    output reg  [3:0] o_y
);

    // FIXED: Default assignment at top covers all paths
    always @(*) begin
        o_y = 4'b0000;     // default — prevents latch
        if (i_sel)
            o_y = i_a;     // override when needed
    end

endmodule
