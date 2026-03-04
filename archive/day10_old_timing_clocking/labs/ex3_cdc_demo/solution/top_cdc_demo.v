// =============================================================================
// top_cdc_demo.v — SOLUTION
// Day 10, Exercise 3
// =============================================================================

module top_cdc_demo (
    input  wire i_clk,
    input  wire i_switch1,
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g,
    output wire o_led1, o_led2, o_led3, o_led4
);

    wire w_pll_clk, w_pll_locked;
    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000), .DIVF(7'b0011111),
        .DIVQ(3'b100),  .FILTER_RANGE(3'b010)
    ) pll_inst (
        .REFERENCECLK(i_clk), .PLLOUTCORE(w_pll_clk),
        .LOCK(w_pll_locked), .RESETB(1'b1), .BYPASS(1'b0)
    );

    wire w_btn_clean;
    debounce #(.CLKS_TO_STABLE(250_000)) db (
        .i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(w_btn_clean)
    );
    wire w_btn_active = ~w_btn_clean;

    // 2-FF synchronizer: 25 MHz → 50 MHz
    reg r_sync1_pll, r_sync2_pll;
    always @(posedge w_pll_clk) begin
        r_sync1_pll <= w_btn_active;
        r_sync2_pll <= r_sync1_pll;
    end

    // Edge detector in PLL domain
    reg r_sync_prev;
    always @(posedge w_pll_clk)
        r_sync_prev <= r_sync2_pll;

    wire w_btn_press_pll = r_sync2_pll & ~r_sync_prev;

    // Counter in PLL domain
    reg [3:0] r_count_pll;
    always @(posedge w_pll_clk) begin
        if (!w_pll_locked)
            r_count_pll <= 4'd0;
        else if (w_btn_press_pll)
            r_count_pll <= r_count_pll + 1;
    end

    // Synchronize count back to 25 MHz (simple 2-FF per bit)
    reg [3:0] r_count_sync1, r_count_sync2;
    always @(posedge i_clk) begin
        r_count_sync1 <= r_count_pll;
        r_count_sync2 <= r_count_sync1;
    end

    hex_to_7seg seg1 (
        .i_hex(r_count_sync2),
        .o_seg_a(o_segment1_a), .o_seg_b(o_segment1_b),
        .o_seg_c(o_segment1_c), .o_seg_d(o_segment1_d),
        .o_seg_e(o_segment1_e), .o_seg_f(o_segment1_f),
        .o_seg_g(o_segment1_g)
    );

    assign o_led1 = ~w_btn_active;
    assign o_led2 = ~w_pll_locked;
    assign o_led3 = ~r_count_pll[0];
    assign o_led4 = ~r_count_pll[1];

endmodule
