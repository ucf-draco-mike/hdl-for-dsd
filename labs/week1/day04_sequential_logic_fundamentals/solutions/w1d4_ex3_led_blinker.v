// =============================================================================
// Exercise 3 SOLUTION: LED Blinker
// Day 4 · Sequential Logic Fundamentals
// =============================================================================

module led_blinker (
    input  wire i_clk,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    reg [23:0] r_counter = 24'd0;

    always @(posedge i_clk)
        r_counter <= r_counter + 24'd1;

    // Multi-speed: each LED from a different counter bit
    assign o_led1 = ~r_counter[23];  // ~1.5 Hz
    assign o_led2 = ~r_counter[22];  // ~3 Hz
    assign o_led3 = ~r_counter[21];  // ~6 Hz
    assign o_led4 = ~r_counter[20];  // ~12 Hz

endmodule
