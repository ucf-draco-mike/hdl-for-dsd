// Exercise 1: 2-to-1 multiplexer using conditional operator
module mux2to1 #(parameter WIDTH = 4) (
    input  wire [WIDTH-1:0] i_a, i_b,
    input  wire             i_sel,
    output wire [WIDTH-1:0] o_y
);
    // TODO: Implement using assign and ternary operator
    assign o_y = i_sel ? i_b : i_a;
endmodule
