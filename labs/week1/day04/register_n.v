// Exercise 2: N-bit loadable register
module register_n #(parameter WIDTH = 8) (
    input  wire             i_clk, i_reset, i_load,
    input  wire [WIDTH-1:0] i_data,
    output reg  [WIDTH-1:0] o_q
);
    always @(posedge i_clk) begin
        if (i_reset)
            o_q <= {WIDTH{1'b0}};
        else if (i_load)
            o_q <= i_data;
    end
endmodule
