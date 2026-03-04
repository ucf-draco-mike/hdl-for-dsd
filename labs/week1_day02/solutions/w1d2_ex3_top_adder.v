// =============================================================================
// Exercise 3 SOLUTION, Part C: Top Module — Adder on Go Board
// Day 2 · Combinational Building Blocks
// =============================================================================

module top_adder (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    wire [3:0] w_a = {2'b00, ~i_switch1, ~i_switch2};
    wire [3:0] w_b = {2'b00, ~i_switch3, ~i_switch4};
    wire [3:0] w_sum;
    wire       w_cout;

    ripple_adder_4bit adder (
        .i_a(w_a), .i_b(w_b), .i_cin(1'b0),
        .o_sum(w_sum), .o_cout(w_cout)
    );

    assign o_led1 = ~w_sum[2];
    assign o_led2 = ~w_sum[1];
    assign o_led3 = ~w_sum[0];
    assign o_led4 = ~w_cout;

endmodule
