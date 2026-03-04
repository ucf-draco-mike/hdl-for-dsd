// =============================================================================
// day10_ex01_top_pll_demo.v — PLL Blinker: 25 MHz → 50 MHz
// Day 10: Timing, Clocking & Constraints
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Demonstrates SB_PLL40_CORE on iCE40 Go Board.
// LED1 blinks from PLL clock, LED2 = LOCK indicator.
// =============================================================================
// Synth:  yosys -p "read_verilog day10_ex01_top_pll_demo.v; synth_ice40 -top top_pll_demo"
// PnR:    nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf --freq 50 ...
// =============================================================================

module top_pll_demo (
    input  wire i_clk,       // 25 MHz from crystal
    output wire o_led1,      // PLL-clocked blinker
    output wire o_led2,      // PLL LOCK indicator
    output wire o_led3,      // Reference blinker (25 MHz)
    output wire o_led4       // Unused
);

    wire w_pll_clk;
    wire w_pll_locked;

    // ---- PLL: 25 MHz → 50 MHz ----
    // Parameters from: icepll -i 25 -o 50
    SB_PLL40_CORE #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),          // DIVR = 0
        .DIVF(7'b0011111),       // DIVF = 31
        .DIVQ(3'b100),           // DIVQ = 4
        .FILTER_RANGE(3'b010)
    ) pll_inst (
        .REFERENCECLK(i_clk),
        .PLLOUTCORE(w_pll_clk),
        .LOCK(w_pll_locked),
        .RESETB(1'b1),
        .BYPASS(1'b0)
    );

    // ---- PLL-domain blinker (50 MHz) ----
    reg [25:0] r_pll_counter;

    always @(posedge w_pll_clk) begin
        if (!w_pll_locked)
            r_pll_counter <= 0;
        else
            r_pll_counter <= r_pll_counter + 1;
    end

    // ---- Reference blinker (25 MHz) ----
    reg [24:0] r_ref_counter;

    always @(posedge i_clk) begin
        r_ref_counter <= r_ref_counter + 1;
    end

    // ---- Outputs ----
    assign o_led1 = ~r_pll_counter[25];   // ~0.67 sec period at 50 MHz
    assign o_led2 = ~w_pll_locked;         // ON when locked (active-low LEDs)
    assign o_led3 = ~r_ref_counter[24];    // ~0.67 sec period at 25 MHz
    assign o_led4 = 1'b1;                  // OFF

endmodule
