// =============================================================================
// edge_detect.v — Rising/Falling Edge Detector
// Day 8: Hierarchy, Parameters & Generate
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Produces a one-cycle pulse on the rising and falling edges of a level
// input. Designed to follow a debouncer in the button_handler pipeline.
// =============================================================================

module edge_detect (
    input  wire i_clk,
    input  wire i_level,
    output wire o_rise,
    output wire o_fall
);

    reg r_prev = 1'b0;

    always @(posedge i_clk)
        r_prev <= i_level;

    assign o_rise =  i_level & ~r_prev;
    assign o_fall = ~i_level &  r_prev;

endmodule
