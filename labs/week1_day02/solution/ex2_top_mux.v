// =============================================================================
// Exercise 2 SOLUTION, Part C: Top Module for Mux
// Day 2 · Combinational Building Blocks
// =============================================================================

module top_mux (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1
);

    wire [1:0] w_sel = ~{i_switch1, i_switch2};
    wire w_d0 = 1'b0;
    wire w_d1 = ~i_switch3;
    wire w_d2 = ~i_switch4;
    wire w_d3 = 1'b1;
    wire w_result;

    mux4to1 mux (
        .i_d0(w_d0), .i_d1(w_d1), .i_d2(w_d2), .i_d3(w_d3),
        .i_sel(w_sel),
        .o_y(w_result)
    );

    assign o_led1 = ~w_result;

endmodule
