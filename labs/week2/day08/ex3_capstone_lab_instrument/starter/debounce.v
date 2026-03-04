// =============================================================================
// debounce.v — Counter-Based Button Debouncer (Solution)
// Day 5, Exercise 1
// =============================================================================

module debounce #(
    parameter CLKS_TO_STABLE = 250_000
)(
    input  wire i_clk,
    input  wire i_bouncy,
    output reg  o_clean
);

    reg [$clog2(CLKS_TO_STABLE)-1:0] r_count;
    reg r_sync_0, r_sync_1;

    always @(posedge i_clk) begin
        // 2-FF synchronizer
        r_sync_0 <= i_bouncy;
        r_sync_1 <= r_sync_0;

        // Debounce logic
        if (r_sync_1 != o_clean) begin
            r_count <= r_count + 1;
            if (r_count == CLKS_TO_STABLE - 1) begin
                o_clean <= r_sync_1;
                r_count <= 0;
            end
        end else begin
            r_count <= 0;
        end
    end

endmodule
