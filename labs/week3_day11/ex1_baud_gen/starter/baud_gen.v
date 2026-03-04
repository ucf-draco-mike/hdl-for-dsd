// =============================================================================
// baud_gen.v — Parameterized Baud Rate Generator
// Day 11, Exercise 1
// =============================================================================
// Produces a single-cycle tick at the baud rate.
// At 25 MHz / 115200 baud = 217 clocks per bit.

module baud_gen #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_enable,
    output wire o_tick
);

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam CNT_WIDTH    = $clog2(CLKS_PER_BIT);

    // TODO: Implement a counter that:
    //   - Resets to 0 when i_reset or !i_enable
    //   - Counts up to CLKS_PER_BIT - 1, then wraps to 0
    //   - o_tick is high for exactly 1 cycle at the wrap point

    // ---- YOUR CODE HERE ----

endmodule
