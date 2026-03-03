// =============================================================================
// Exercise 2 SOLUTION: 4-Bit Loadable Register
// Day 4 · Sequential Logic Fundamentals
// =============================================================================

module register_4bit (
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_load,
    input  wire [3:0] i_data,
    output reg  [3:0] o_q
);

    always @(posedge i_clk) begin
        if (i_reset)
            o_q <= 4'b0000;
        else if (i_load)
            o_q <= i_data;
    end

endmodule
