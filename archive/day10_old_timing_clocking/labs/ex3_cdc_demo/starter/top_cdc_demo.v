// =============================================================================
// top_cdc_demo.v — Clock Domain Crossing Demo
// Day 10, Exercise 3
// =============================================================================
// A button debounced in the 25 MHz domain triggers a counter in the
// PLL 50 MHz domain. Demonstrates 2-FF synchronizer for CDC.

module top_cdc_demo (
    input  wire i_clk,       // 25 MHz
    input  wire i_switch1,   // button
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g,
    output wire o_led1, o_led2, o_led3, o_led4
);

    // --- PLL: 50 MHz ---
    wire w_pll_clk, w_pll_locked;
    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),
        .DIVF(7'b0011111),
        .DIVQ(3'b100),
        .FILTER_RANGE(3'b010)
    ) pll_inst (
        .REFERENCECLK(i_clk),
        .PLLOUTCORE(w_pll_clk),
        .LOCK(w_pll_locked),
        .RESETB(1'b1),
        .BYPASS(1'b0)
    );

    // --- 25 MHz domain: debounce the button ---
    wire w_btn_clean;
    debounce #(.CLKS_TO_STABLE(250_000)) db (
        .i_clk(i_clk),
        .i_bouncy(i_switch1),
        .o_clean(w_btn_clean)
    );
    wire w_btn_active = ~w_btn_clean;  // active-high

    // --- CDC: 25 MHz → 50 MHz ---
    // TODO: Implement a 2-FF synchronizer for w_btn_active
    //       into the PLL clock domain
    //
    // reg r_sync1_pll, r_sync2_pll;
    // always @(posedge w_pll_clk) begin
    //     r_sync1_pll <= ???;
    //     r_sync2_pll <= ???;
    // end

    // ---- YOUR CODE HERE ----

    // --- 50 MHz domain: edge detect and count ---
    // TODO: Detect the rising edge of the synchronized button signal
    //       Increment a 4-bit counter on each press
    //       Use !w_pll_locked as reset

    // ---- YOUR CODE HERE ----

    // --- Display: show count on 7-seg (25 MHz domain) ---
    // TODO: Synchronize the 4-bit count back to 25 MHz domain
    //       (or accept the CDC risk for this simple display)
    //       Then decode through hex_to_7seg

    // ---- YOUR CODE HERE ----

    // LED indicators
    assign o_led1 = ~w_btn_active;
    assign o_led2 = ~w_pll_locked;
    // TODO: assign o_led3, o_led4 to show count bits

endmodule
