// Exercise 2: Single-bit full adder
module full_adder (
    input  wire i_a, i_b, i_cin,
    output wire o_sum, o_cout
);
    assign o_sum  = i_a ^ i_b ^ i_cin;
    assign o_cout = (i_a & i_b) | (i_a & i_cin) | (i_b & i_cin);
endmodule
