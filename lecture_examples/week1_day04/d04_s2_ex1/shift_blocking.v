//-----------------------------------------------------------------------------
// File:    shift_blocking.v
// Course:  Accelerated HDL for Digital System Design
//
// Description:
//   3-stage pipeline written with BLOCKING assignment inside a clocked
//   always block. This is the WRONG idiom for sequential logic — the three
//   updates execute in source order during the same edge, so r_a, r_b, and
//   o_q all collapse to i_d. Synthesizer reduces the chain to a single flop.
//
// Companion file: shift_nonblocking.v (correct version)
// Synth check:    make stat-blocking   (expect SB_DFF: 1)
//-----------------------------------------------------------------------------
module shift_blocking (
    input  wire i_clk, i_d,
    output reg  o_q
);
    reg r_a, r_b;
    always @(posedge i_clk) begin
        r_a = i_d;    // blocking: r_a gets i_d NOW
        r_b = r_a;    // r_b gets UPDATED r_a (= i_d)
        o_q = r_b;    // o_q gets UPDATED r_b (= i_d)
    end               // Result: all three get i_d — NO pipeline!
endmodule
