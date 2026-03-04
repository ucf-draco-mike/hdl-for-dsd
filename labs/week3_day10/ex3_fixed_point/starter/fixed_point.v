// =============================================================================
// fixed_point.v — Fixed-Point Q4.4 Arithmetic
// Day 10, Exercise 3
// =============================================================================
// Q4.4 format: 4 integer bits, 4 fractional bits = 8 bits total
// Value = raw_integer / 16
// Example: 8'b0010_1000 = 40 decimal → 40/16 = 2.5
//
// TASK:
//   1. Implement Q4.4 addition (straightforward — just add)
//   2. Implement Q4.4 multiplication (Q4.4 × Q4.4 = Q8.8, then extract Q4.4)
//   3. Display the integer part of the result on 7-seg
//   4. Test with known values: 2.5 × 3.0 = 7.5 → integer part = 7
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
    // Q4.4 + Q4.4 = Q4.4 (with potential overflow into bit 8)
    // For simplicity, we'll ignore overflow in this exercise
    // TODO: implement the addition
    // assign o_sum = ???;

    // ---- YOUR CODE HERE ----


    // ---- Multiplication ----
    // Q4.4 × Q4.4 = Q8.8 (16 bits: 8 integer, 8 fractional)
    // To get Q4.4 result: extract bits [11:4] from the 16-bit product
    //
    //   Full product bits: [15:8] = integer part (Q8)
    //                      [7:0]  = fractional part (.8)
    //   But we want Q4.4:  [11:8] = 4 integer bits
    //                      [7:4]  = 4 fractional bits
    //   So: o_prod = full_product[11:4]

    wire [15:0] w_full_product;

    // TODO: compute the full product and extract Q4.4 result
    // assign w_full_product = ???;
    // assign o_prod = ???;

    // ---- YOUR CODE HERE ----


    // ---- Integer part extraction ----
    // The integer part of a Q4.4 number is the upper 4 bits
    // TODO: extract integer part of the product for 7-seg display
    // assign o_prod_int = ???;

    // ---- YOUR CODE HERE ----

endmodule
