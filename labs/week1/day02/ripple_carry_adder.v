// Exercise 2: 4-bit ripple-carry adder from full adders
module ripple_carry_adder (
    input  wire [3:0] i_a, i_b,
    input  wire       i_cin,
    output wire [3:0] o_sum,
    output wire       o_cout
);
    wire [3:1] w_carry;

    full_adder fa0 (.i_a(i_a[0]), .i_b(i_b[0]), .i_cin(i_cin),      .o_sum(o_sum[0]), .o_cout(w_carry[1]));
    full_adder fa1 (.i_a(i_a[1]), .i_b(i_b[1]), .i_cin(w_carry[1]), .o_sum(o_sum[1]), .o_cout(w_carry[2]));
    full_adder fa2 (.i_a(i_a[2]), .i_b(i_b[2]), .i_cin(w_carry[2]), .o_sum(o_sum[2]), .o_cout(w_carry[3]));
    full_adder fa3 (.i_a(i_a[3]), .i_b(i_b[3]), .i_cin(w_carry[3]), .o_sum(o_sum[3]), .o_cout(o_cout));
endmodule
