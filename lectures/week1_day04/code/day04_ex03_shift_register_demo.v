//-----------------------------------------------------------------------------
// File:    day04_ex03_shift_register_demo.v
// Course:  Accelerated HDL for Digital System Design — Day 4
//
// Description:
//   Side-by-side comparison of blocking vs. nonblocking assignment
//   in a 3-stage shift register. Simulate both and compare waveforms.
//
// Simulate:
//   iverilog -o shift_demo day04_ex03_shift_register_demo.v
//   vvp shift_demo
//   gtkwave shift_demo.vcd
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
