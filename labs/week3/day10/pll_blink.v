// PLL-based clock generation example
// Use icepll to generate parameters: icepll -i 25 -o 50
module pll_blink_top (
    input  wire i_clk,      // 25 MHz from oscillator
    output wire o_led1,     // blink at 25 MHz rate
    output wire o_led2      // blink at 50 MHz rate
);
    wire w_pll_clk;
    wire w_pll_locked;

    // iCE40 PLL — parameters from icepll tool
    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),
        .DIVF(7'b0111111),
        .DIVQ(3'b100),
        .FILTER_RANGE(3'b001)
    ) pll_inst (
        .REFERENCECLK(i_clk),
        .PLLOUTCORE(w_pll_clk),
        .LOCK(w_pll_locked),
        .RESETB(1'b1),
        .BYPASS(1'b0)
    );

    // Blinker on original 25 MHz clock
    reg [23:0] r_cnt_25;
    always @(posedge i_clk)
        r_cnt_25 <= r_cnt_25 + 1;
    assign o_led1 = r_cnt_25[23];

    // Blinker on PLL-generated clock
    reg [23:0] r_cnt_pll;
    always @(posedge w_pll_clk)
        r_cnt_pll <= r_cnt_pll + 1;
    assign o_led2 = r_cnt_pll[23];
endmodule
