// =============================================================================
// day05_ex04_debounce.v — Counter-Based Button Debouncer
// Day 5: Counters, Shift Registers & Debouncing
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Includes built-in 2-FF synchronizer. Connect directly to raw button input.
// Pipeline: async_in → [2-FF sync] → [debounce counter] → clean output
// =============================================================================
// Build:  iverilog -DSIMULATION -o sim day05_ex04_debounce.v && vvp sim
// Synth:  yosys -p "read_verilog day05_ex04_debounce.v; synth_ice40 -top debounce"
// =============================================================================

module debounce #(
    parameter CLKS_TO_STABLE = 250_000  // 10 ms at 25 MHz (override for sim)
)(
    input  wire i_clk,
    input  wire i_bouncy,
    output reg  o_clean
);

    // ---- 2-FF Synchronizer (built-in) ----
    reg r_sync_0, r_sync_1;
    always @(posedge i_clk) begin
        r_sync_0 <= i_bouncy;
        r_sync_1 <= r_sync_0;
    end

    // ---- Debounce Counter ----
    reg [$clog2(CLKS_TO_STABLE)-1:0] r_count;

    always @(posedge i_clk) begin
        if (r_sync_1 != o_clean) begin
            // Input differs from output — count how long
            if (r_count == CLKS_TO_STABLE - 1) begin
                o_clean <= r_sync_1;    // accept new value
                r_count <= 0;
            end else
                r_count <= r_count + 1;
        end else begin
            // Input matches output — reset counter
            r_count <= 0;
        end
    end

endmodule
