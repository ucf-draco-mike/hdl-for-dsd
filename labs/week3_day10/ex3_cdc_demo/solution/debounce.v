module debounce #(
    parameter CLKS_TO_STABLE = 250_000
)(
    input  wire i_clk,
    input  wire i_bouncy,
    output reg  o_clean
);
    reg r_sync1, r_sync2;
    always @(posedge i_clk) begin
        r_sync1 <= i_bouncy;
        r_sync2 <= r_sync1;
    end

    reg [$clog2(CLKS_TO_STABLE)-1:0] r_count;
    always @(posedge i_clk) begin
        if (r_sync2 != o_clean) begin
            r_count <= r_count + 1;
            if (r_count == CLKS_TO_STABLE - 1) begin
                o_clean <= r_sync2;
                r_count <= 0;
            end
        end else begin
            r_count <= 0;
        end
    end
endmodule
