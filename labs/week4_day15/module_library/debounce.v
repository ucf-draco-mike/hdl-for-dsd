// debounce.v — Switch debouncer for the Go Board
// 2-FF synchronizer + counter-based debounce
// Default: ~10 ms debounce at 25 MHz (DEBOUNCE_LIMIT = 250000)
module debounce #(
    parameter DEBOUNCE_LIMIT = 250000
)(
    input  wire i_clk,
    input  wire i_switch,    // Raw switch input (active-high on Go Board)
    output reg  o_switch     // Debounced output (active-high)
);

    // 2-FF synchronizer
    reg r_sync_0, r_sync_1;
    always @(posedge i_clk) begin
        r_sync_0 <= i_switch;     // Active-high: no inversion needed
        r_sync_1 <= r_sync_0;
    end

    reg [$clog2(DEBOUNCE_LIMIT)-1:0] r_count;
    reg r_state;

    always @(posedge i_clk) begin
        if (r_sync_1 != r_state && r_count < DEBOUNCE_LIMIT - 1)
            r_count <= r_count + 1;
        else if (r_count == DEBOUNCE_LIMIT - 1) begin
            r_state <= r_sync_1;
            r_count <= 0;
        end else
            r_count <= 0;

        o_switch <= r_state;
    end
endmodule
