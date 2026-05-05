// =============================================================================
// day13_ex01_debounce_sv.sv -- Counter-Based Button Debouncer (SystemVerilog)
// Day 13: SystemVerilog for Design -- Segment 2 (logic type)
// Accelerated HDL for Digital System Design - Dr. Mike Borowczak - ECE - CECS - UCF
// =============================================================================
// SV-modernised version of shared/lib/debounce.v. The Verilog-2001 version uses
// `wire` and `reg`; this version uses a single `logic` type and the intent
// variants `always_ff`/`always_comb` so the synthesis tool checks our intent.
//
// Pipeline: async_in -> [2-FF sync] -> [debounce counter] -> clean output
// =============================================================================
// Build:  iverilog -g2012 -DSIMULATION -o sim tb_debounce_sv.sv day13_ex01_debounce_sv.sv && vvp sim
// Synth:  yosys -p "read_verilog -sv day13_ex01_debounce_sv.sv; synth_ice40 -top debounce_sv"
// =============================================================================

module debounce_sv #(
    parameter int CLKS_TO_STABLE = 250_000  // 10 ms at 25 MHz (override for sim)
)(
    input  logic i_clk,
    input  logic i_bouncy,
    output logic o_clean
);

    // ---- 2-FF Synchronizer (built-in) ----
    logic r_sync_0, r_sync_1;
    always_ff @(posedge i_clk) begin
        r_sync_0 <= i_bouncy;
        r_sync_1 <= r_sync_0;
    end

    // ---- Debounce Counter ----
    logic [$clog2(CLKS_TO_STABLE)-1:0] r_count;

    always_ff @(posedge i_clk) begin
        if (r_sync_1 != o_clean) begin
            // Input differs from output -- count how long
            if (r_count == CLKS_TO_STABLE - 1) begin
                o_clean <= r_sync_1;    // accept new value
                r_count <= '0;
            end else
                r_count <= r_count + 1;
        end else begin
            // Input matches output -- reset counter
            r_count <= '0;
        end
    end

endmodule
