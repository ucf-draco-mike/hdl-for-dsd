// Counter-based button debouncer
module debounce #(parameter CLKS_TO_STABLE = 250_000) (
    input  wire i_clk,
    input  wire i_bouncy,
    output reg  o_clean
);
    reg r_sync_0, r_sync_1;  // 2-FF synchronizer
    reg [$clog2(CLKS_TO_STABLE)-1:0] r_count;

    always @(posedge i_clk) begin
        r_sync_0 <= i_bouncy;
        r_sync_1 <= r_sync_0;
    end

    always @(posedge i_clk) begin
        if (r_sync_1 != o_clean) begin
            if (r_count == CLKS_TO_STABLE - 1) begin
                o_clean <= r_sync_1;
                r_count <= 0;
            end else
                r_count <= r_count + 1;
        end else
            r_count <= 0;
    end
endmodule
