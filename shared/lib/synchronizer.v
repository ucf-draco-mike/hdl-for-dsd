// =============================================================================
// synchronizer.v — 2-FF Metastability Synchronizer
// Day 5: Counters, Shift Registers & Debouncing
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================

module synchronizer (
    input  wire i_clk,
    input  wire i_async_in,
    output wire o_sync_out
);

    reg r_meta;
    reg r_sync;

    always @(posedge i_clk) begin
        r_meta <= i_async_in;
        r_sync <= r_meta;
    end

    assign o_sync_out = r_sync;

endmodule
