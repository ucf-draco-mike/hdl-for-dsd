// =============================================================================
// day08_ex02_counter.v — Parameterized N-Bit Counter
// Day 8: Hierarchy, Parameters & Generate
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// One source file → any-width counter. Demonstrates `parameter`, named
// override at instantiation (#(.WIDTH(N))), and synchronous reset/enable.
//
// Used by top_with_three_counters.v to produce 4-bit, 8-bit, and 16-bit
// instances from this single module.
// =============================================================================

module counter #(
    parameter WIDTH = 8
)(
    input  wire             i_clk,
    input  wire             i_reset,    // synchronous, active-high
    input  wire             i_enable,
    output reg  [WIDTH-1:0] o_count,
    output wire             o_rollover  // pulses when count wraps to 0
);

    localparam [WIDTH-1:0] MAX_VAL = {WIDTH{1'b1}};

    always @(posedge i_clk) begin
        if (i_reset)
            o_count <= {WIDTH{1'b0}};
        else if (i_enable)
            o_count <= o_count + 1'b1;
    end

    assign o_rollover = i_enable & (o_count == MAX_VAL);

endmodule
