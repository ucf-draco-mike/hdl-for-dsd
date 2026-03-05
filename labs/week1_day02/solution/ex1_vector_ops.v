// =============================================================================
// Exercise 1 SOLUTION: Vector Operations
// Day 2 · Combinational Building Blocks
// =============================================================================

module vector_ops (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    wire [3:0] w_sw;
    assign w_sw = ~{i_switch1, i_switch2, i_switch3, i_switch4};

    // OR reduction — any switch pressed
    assign o_led1 = ~(|w_sw);

    // AND reduction — all switches pressed
    assign o_led2 = ~(&w_sw);

    // XOR reduction — odd number pressed
    assign o_led3 = ~(^w_sw);

    // MSB — switch1 state
    assign o_led4 = ~w_sw[3];

endmodule
