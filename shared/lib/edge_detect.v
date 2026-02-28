// Rising/falling edge detector
// Built: Day 5 | Tested: Day 6
module edge_detect (
    input  wire i_clk, i_signal,
    output wire o_rising, o_falling
);
    reg r_prev;
    always @(posedge i_clk) r_prev <= i_signal;
    assign o_rising  = i_signal & ~r_prev;
    assign o_falling = ~i_signal & r_prev;
endmodule
