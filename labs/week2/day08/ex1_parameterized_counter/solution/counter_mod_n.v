// =============================================================================
// counter_mod_n.v — Parameterized Modulo-N Counter (Solution)
// Day 8, Exercise 1
// =============================================================================

module counter_mod_n #(
    parameter N = 10
)(
    input  wire                      i_clk,
    input  wire                      i_reset,
    input  wire                      i_enable,
    output reg  [$clog2(N)-1:0]      o_count,
    output wire                      o_wrap
);

    always @(posedge i_clk) begin
        if (i_reset)
            o_count <= 0;
        else if (i_enable) begin
            if (o_count == N - 1)
                o_count <= 0;
            else
                o_count <= o_count + 1;
        end
    end

    assign o_wrap = (i_enable && o_count == N - 1);

endmodule
