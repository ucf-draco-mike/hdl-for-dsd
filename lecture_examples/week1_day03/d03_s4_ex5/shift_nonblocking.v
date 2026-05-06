//-----------------------------------------------------------------------------
// File:    shift_nonblocking.v
// Course:  Accelerated HDL for Digital System Design
//
// Description:
//   3-stage pipeline written with NONBLOCKING assignment inside a clocked
//   always block. All RHS values are sampled before any LHS is updated, so
//   the chain i_d → r_a → r_b → o_q behaves as a true 3-deep shift register.
//
// Companion file: shift_blocking.v (incorrect version, for comparison)
// Synth check:    make stat-nonblocking   (expect SB_DFF: 3)
//-----------------------------------------------------------------------------
module shift_nonblocking (
    input  wire i_clk, i_d,
    output reg  o_q
);
    reg r_a, r_b;
    always @(posedge i_clk) begin
        r_a <= i_d;   // scheduled: r_a ← i_d(current)
        r_b <= r_a;   // scheduled: r_b ← r_a(current, old value)
        o_q <= r_b;   // scheduled: o_q ← r_b(current, old value)
    end               // Result: data shifts through — 3-cycle delay
endmodule
