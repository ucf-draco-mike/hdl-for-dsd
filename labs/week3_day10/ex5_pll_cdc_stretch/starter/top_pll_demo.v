// =============================================================================
// top_pll_demo.v — PLL Clock Generation Demo (Stretch Exercise)
// Day 10, Exercise 5
// =============================================================================
// Use icepll to find parameters: icepll -i 25 -o 50

module top_pll_demo (
    input  wire i_clk,       // 25 MHz
    output wire o_led1,      // blinks from 25 MHz domain
    output wire o_led2,      // blinks from PLL domain
    output wire o_led3,      // PLL lock indicator
    output wire o_led4       // heartbeat (25 MHz domain)
);

    wire w_pll_clk, w_pll_locked;

    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        // TODO: Run `icepll -i 25 -o 50` and fill in these parameters
        .DIVR(4'b0000),
        .DIVF(7'b0000000),     // TODO
        .DIVQ(3'b000),         // TODO
        .FILTER_RANGE(3'b000)  // TODO
    ) pll_inst (
        .REFERENCECLK(i_clk),
        .PLLOUTCORE(w_pll_clk),
        .LOCK(w_pll_locked),
        .RESETB(1'b1),
        .BYPASS(1'b0)
    );

    // 25 MHz domain blinker
    reg [23:0] r_count_25;
    always @(posedge i_clk)
        r_count_25 <= r_count_25 + 1;
    assign o_led1 = r_count_25[23];

    // TODO: PLL domain blinker
    //   - Reset when PLL is not locked
    //   - Use bit [24] for ~1.5 Hz at 50 MHz
    //   - Assign to o_led2 (active-high)

    // ---- YOUR CODE HERE ----

    assign o_led3 = w_pll_locked;
    assign o_led4 = r_count_25[22];

endmodule
