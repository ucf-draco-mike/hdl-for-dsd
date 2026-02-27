// =============================================================================
// top_pll_demo.v — PLL Clock Generation Demo
// Day 10: Timing, Clocking & Constraints
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Generates 50 MHz from the 25 MHz crystal using the iCE40 PLL.
// LED blinks at a rate determined by the PLL output clock.
// Use: icepll -i 25 -o 50 → DIVR=0, DIVF=31, DIVQ=4, FILTER_RANGE=2

module top_pll_demo (
    input  wire i_clk,       // 25 MHz crystal
    output wire o_led1       // blink at PLL-derived rate
);

    wire w_pll_clk;
    wire w_pll_locked;

    // ===== PLL Instance =====
    // Values from: icepll -i 25 -o 50
    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),         // DIVR = 0
        .DIVF(7'b0011111),      // DIVF = 31
        .DIVQ(3'b100),          // DIVQ = 4
        .FILTER_RANGE(3'b010)   // FILTER_RANGE = 2
    ) pll_inst (
        .REFERENCECLK(i_clk),
        .PLLOUTCORE(w_pll_clk),
        .LOCK(w_pll_locked),
        .RESETB(1'b1),
        .BYPASS(1'b0)
    );

    // ===== Counter on PLL clock domain =====
    reg [25:0] r_counter;

    always @(posedge w_pll_clk) begin
        if (!w_pll_locked)
            r_counter <= 0;
        else
            r_counter <= r_counter + 1;
    end

    assign o_led1 = r_counter[25];  // ~0.75 Hz at 50 MHz

endmodule
