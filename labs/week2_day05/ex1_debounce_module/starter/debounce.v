// =============================================================================
// debounce.v — Counter-Based Button Debouncer (Starter)
// Day 5, Exercise 1
// =============================================================================
// Build a reusable debounce module with built-in 2-FF synchronizer.
// The input i_bouncy can be fully asynchronous.

module debounce #(
    parameter CLKS_TO_STABLE = 250_000  // ~10ms at 25 MHz
)(
    input  wire i_clk,
    input  wire i_bouncy,
    output reg  o_clean
);

    reg [$clog2(CLKS_TO_STABLE)-1:0] r_count;
    reg r_sync_0, r_sync_1;

    always @(posedge i_clk) begin
        // ---- TODO: 2-FF Synchronizer ----
        // Stage 0: sample i_bouncy into r_sync_0
        // Stage 1: sample r_sync_0 into r_sync_1
        // r_sync_1 is now safe to use in synchronous logic


        // ---- TODO: Debounce Counter Logic ----
        // If the synchronized input differs from the current clean output:
        //   - Increment r_count
        //   - If r_count reaches CLKS_TO_STABLE - 1:
        //       Accept the new value (o_clean <= r_sync_1)
        //       Reset counter to 0
        // If the synchronized input matches the clean output:
        //   - Reset counter to 0 (input is stable, no change needed)

    end

endmodule
