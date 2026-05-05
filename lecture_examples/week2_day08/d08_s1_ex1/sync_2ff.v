// =============================================================================
// sync_2ff.v — 2-Flop Metastability Synchronizer
// Day 8: Hierarchy, Parameters & Generate
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Sub-module of button_handler. Two back-to-back flops give the first stage
// a full clock period to resolve any metastability before its value is sampled.
// Used here as the first stage of the button_handler hierarchy demo.
// =============================================================================

module sync_2ff (
    input  wire i_clk,
    input  wire i_async_in,
    output wire o_sync_out
);

    reg r_meta = 1'b0;     // First FF — may go metastable on async input
    reg r_sync = 1'b0;     // Second FF — extremely unlikely to be metastable

    always @(posedge i_clk) begin
        r_meta <= i_async_in;
        r_sync <= r_meta;
    end

    assign o_sync_out = r_sync;

endmodule
