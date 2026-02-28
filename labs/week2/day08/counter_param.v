// Parameterized N-bit counter
module counter_param #(parameter WIDTH = 8) (
    input  wire               i_clk, i_reset, i_enable,
    output reg  [WIDTH-1:0]   o_count,
    output wire               o_max
);
    assign o_max = &o_count;  // all 1s

    always @(posedge i_clk) begin
        if (i_reset)
            o_count <= {WIDTH{1'b0}};
        else if (i_enable)
            o_count <= o_count + 1;
    end
endmodule
