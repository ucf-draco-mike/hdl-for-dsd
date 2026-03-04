// =============================================================================
// top_pll_demo.v — SOLUTION
// Day 10, Exercise 2
// =============================================================================

module top_pll_demo (
    input  wire i_clk,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    wire w_pll_clk, w_pll_locked;

    // icepll -i 25 -o 50 gives these parameters
    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),
        .DIVF(7'b0011111),    // 50 MHz output
        .DIVQ(3'b100),
        .FILTER_RANGE(3'b010)
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
    assign o_led1 = ~r_count_25[23];

    // PLL domain blinker
    reg [24:0] r_count_pll;
    always @(posedge w_pll_clk) begin
        if (!w_pll_locked)
            r_count_pll <= 0;
        else
            r_count_pll <= r_count_pll + 1;
    end
    assign o_led2 = ~r_count_pll[24];

    assign o_led3 = ~w_pll_locked;
    assign o_led4 = ~r_count_25[22];

endmodule
