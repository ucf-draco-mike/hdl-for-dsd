// =============================================================================
// counter_4bit.v — Simple 4-bit Counter (Provided — DUT for Exercise 3)
// Day 6, Exercise 3
// =============================================================================

module counter_4bit (
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_enable,
    output reg  [3:0] o_count,
    output wire       o_zero
);

    always @(posedge i_clk) begin
        if (i_reset)
            o_count <= 4'd0;
        else if (i_enable)
            o_count <= o_count + 4'd1;
    end

    assign o_zero = (o_count == 4'd0);

endmodule
