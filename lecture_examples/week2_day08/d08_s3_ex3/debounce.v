// =============================================================================
// debounce.v — Counter-Based Button Debouncer (with built-in 2-FF sync)
// Day 8: Hierarchy, Parameters & Generate
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Includes built-in 2-FF synchronizer. Connect directly to raw button input.
// Pipeline: async_in → [2-FF sync] → [debounce counter] → clean output.
//
// Same module as day05_ex04_debounce.v, copied here so the d08_s3 example
// is self-contained for `make sim` / `make stat`.
// =============================================================================

module debounce #(
    parameter CLKS_STABLE = 250_000   // 10 ms at 25 MHz (override low for sim)
)(
    input  wire i_clk,
    input  wire i_noisy,
    output reg  o_clean = 1'b1         // idle-high: matches a released button
);

    // ---- 2-FF Synchronizer (built-in) ----
    reg r_sync_0 = 1'b1;
    reg r_sync_1 = 1'b1;
    always @(posedge i_clk) begin
        r_sync_0 <= i_noisy;
        r_sync_1 <= r_sync_0;
    end

    // ---- Debounce Counter ----
    localparam W = (CLKS_STABLE <= 1) ? 1 : $clog2(CLKS_STABLE);
    reg [W-1:0] r_count = {W{1'b0}};

    always @(posedge i_clk) begin
        if (r_sync_1 != o_clean) begin
            // Input differs from output — count how long it persists.
            if (r_count == CLKS_STABLE - 1) begin
                o_clean <= r_sync_1;
                r_count <= 0;
            end else begin
                r_count <= r_count + 1'b1;
            end
        end else begin
            // Input matches output — reset counter.
            r_count <= 0;
        end
    end

endmodule
