// =============================================================================
// top_cdc_demo.v — Clock Domain Crossing Demo (Stretch Exercise)
// Day 10, Exercise 5
// =============================================================================
// Debounce a button in the 25 MHz domain, synchronize into the 50 MHz PLL
// domain, count button presses, and display on 7-seg.

module top_cdc_demo (
    input  wire i_clk,       // 25 MHz
    input  wire i_switch1,   // button
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g,
    output wire o_led1, o_led2, o_led3, o_led4
);

    // PLL: 50 MHz
    wire w_pll_clk, w_pll_locked;
    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000), .DIVF(7'b0011111),
        .DIVQ(3'b100),  .FILTER_RANGE(3'b010)
    ) pll_inst (
        .REFERENCECLK(i_clk), .PLLOUTCORE(w_pll_clk),
        .LOCK(w_pll_locked), .RESETB(1'b1), .BYPASS(1'b0)
    );

    // 25 MHz: debounce the button (reuse your debounce module)
    wire w_btn_clean;
    debounce #(.CLKS_TO_STABLE(250_000)) db (
        .i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(w_btn_clean)
    );
    wire w_btn_active = w_btn_clean;

    // TODO: 2-FF synchronizer: 25 MHz → 50 MHz
    // TODO: Edge detector in PLL domain
    // TODO: 4-bit counter in PLL domain (reset when !locked)
    // TODO: Synchronize count back to 25 MHz for display
    // TODO: Instantiate hex_to_7seg for display

    // ---- YOUR CODE HERE ----

    assign o_led1 = w_btn_active;
    assign o_led2 = w_pll_locked;
    assign o_led3 = 1'b0;
    assign o_led4 = 1'b0;

endmodule
