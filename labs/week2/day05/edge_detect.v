// Rising-edge detector
module edge_detect (
    input  wire i_clk,
    input  wire i_signal,
    output wire o_rising,
    output wire o_falling
);
    reg r_prev;

    always @(posedge i_clk)
        r_prev <= i_signal;

    assign o_rising  = i_signal & ~r_prev;
    assign o_falling = ~i_signal & r_prev;
endmodule
