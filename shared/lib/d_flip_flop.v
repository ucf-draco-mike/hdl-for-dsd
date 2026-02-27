// =============================================================================
// d_flip_flop.v — D Flip-Flop with Synchronous Reset
// Day 4: Sequential Logic Fundamentals
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================

module d_flip_flop (
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_d,
    output reg  o_q
);

    always @(posedge i_clk) begin
        if (i_reset)
            o_q <= 1'b0;
        else
            o_q <= i_d;
    end

endmodule
