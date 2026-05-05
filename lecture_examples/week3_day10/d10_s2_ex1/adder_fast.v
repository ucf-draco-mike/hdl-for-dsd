// =============================================================================
// adder_fast.v — Pipelined Wide Adder (passes 25 MHz timing)
// Day 10: Numerical Architectures & Design Trade-offs
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Same function as adder_slow.v, but with a pipeline register splitting the
// long carry chain in half. Higher Fmax at the cost of 1 cycle of latency.
//
// `make timing` should now report Fmax > 25 MHz on iCE40 HX1K.
// =============================================================================

module adder_fast (
    input  wire         i_clk,
    input  wire [31:0]  i_a, i_b, i_c, i_d,
    output reg  [31:0]  o_sum
);
    reg [31:0] r_ab;     // pipeline stage 1: i_a + i_b
    reg [31:0] r_cd;     // pipeline stage 1: i_c + i_d

    always @(posedge i_clk) begin
        r_ab  <= i_a + i_b;
        r_cd  <= i_c + i_d;
        o_sum <= r_ab + r_cd;   // pipeline stage 2: combine
    end
endmodule
