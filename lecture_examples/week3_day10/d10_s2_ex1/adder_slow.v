// =============================================================================
// adder_slow.v — Single-Cycle Wide Adder (timing-marginal at 25 MHz)
// Day 10: Numerical Architectures & Design Trade-offs
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// 32-bit sum cascaded through a chain of additions in one cycle. Long carry
// chain → tight timing slack on iCE40. Compare against adder_fast.v which
// inserts a pipeline register.
//
// `make timing` reports nextpnr Fmax; this version typically falls below the
// 25 MHz target on iCE40 HX1K once the cascade is wide enough.
// =============================================================================

module adder_slow (
    input  wire         i_clk,
    input  wire [31:0]  i_a, i_b, i_c, i_d,
    output reg  [31:0]  o_sum
);
    // Single-cycle 4-input add: deep carry chain.
    always @(posedge i_clk)
        o_sum <= i_a + i_b + i_c + i_d;
endmodule
