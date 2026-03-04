// =============================================================================
// counter_mod_n.v — Parameterized Modulo-N Counter (Starter)
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

    // ---- TODO: Implement counter logic ----
    // On reset: o_count <= 0
    // On enable:
    //   If o_count == N-1: o_count <= 0  (wrap)
    //   Else: o_count <= o_count + 1
    // When not enabled: hold value


    // ---- TODO: Wrap signal ----
    // assign o_wrap = (i_enable && o_count == N-1);

endmodule
