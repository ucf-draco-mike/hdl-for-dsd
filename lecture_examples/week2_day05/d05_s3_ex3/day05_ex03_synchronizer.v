// =============================================================================
// day05_ex03_synchronizer.v — 2-FF Metastability Synchronizer
// Day 5: Counters, Shift Registers & Debouncing
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Use this for EVERY signal entering your clock domain from outside:
//   - Button/switch inputs
//   - External serial data lines (before any processing)
//   - Signals from other clock domains
// =============================================================================
// Synth:  yosys -p "read_verilog day05_ex03_synchronizer.v; synth_ice40 -top synchronizer"
// =============================================================================

module synchronizer (
    input  wire i_clk,
    input  wire i_async_in,
    output wire o_sync_out
);

    reg r_meta;     // First FF — may go metastable
    reg r_sync;     // Second FF — extremely unlikely to be metastable

    always @(posedge i_clk) begin
        r_meta <= i_async_in;    // Stage 1: might go metastable
        r_sync <= r_meta;        // Stage 2: gives stage 1 a full period to resolve
    end

    assign o_sync_out = r_sync;

endmodule
