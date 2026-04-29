// =============================================================================
// fixed_point.v — SOLUTION
// Day 10, Exercise 3
// =============================================================================

module fixed_point_demo (
    input  wire        i_clk,
    input  wire [7:0]  i_a,      // Q4.4 input A
    input  wire [7:0]  i_b,      // Q4.4 input B
    output wire [7:0]  o_sum,    // Q4.4 sum
    output wire [7:0]  o_prod,   // Q4.4 product (truncated from Q8.8)
    output wire [3:0]  o_prod_int // integer part of product (for 7-seg)
);

    // ---- Addition ----
    // Q4.4 + Q4.4: just add the raw values. The fractional point stays aligned.
    assign o_sum = i_a + i_b;

    // ---- Multiplication ----
    // Q4.4 × Q4.4 = Q8.8 (16 bits total)
    // The product has 8 fractional bits (4+4) and 8 integer bits (4+4).
    // To extract Q4.4: take bits [11:4] — 4 integer bits and 4 fractional bits.
    wire [15:0] w_full_product = i_a * i_b;

    // Extract Q4.4 from Q8.8:
    //   Bits [15:12] = upper integer (overflow)
    //   Bits [11:8]  = lower integer → our Q4.4 integer part
    //   Bits [7:4]   = upper fractional → our Q4.4 fractional part
    //   Bits [3:0]   = lower fractional (truncated)
    assign o_prod = w_full_product[11:4];

    // ---- Integer part ----
    // Upper 4 bits of the Q4.4 product result
    assign o_prod_int = o_prod[7:4];

endmodule
