// pattern_sequencer.v — ROM-based LED + 7-seg pattern player
// Loads 16 × 8-bit patterns from patterns.hex
// Lower 4 bits → LEDs, upper 4 bits → 7-seg hex digit
//
// Modes: manual advance (button press) or auto-advance (configurable rate)
module pattern_sequencer #(
    parameter CLK_FREQ     = 25_000_000,
    parameter N_PATTERNS   = 16,
    parameter AUTO_RATE_HZ = 2
)(
    input  wire       i_clk,
    input  wire       i_reset,     // synchronous reset
    input  wire       i_next,      // manual advance (single pulse)
    input  wire       i_auto_mode, // 0 = manual, 1 = auto-advance
    output wire [7:0] o_pattern,   // current pattern word
    output wire [3:0] o_index      // current pattern index
);

    // ────────────────────────────────────────────
    // ROM — loaded from hex file
    // ────────────────────────────────────────────
    reg [7:0] r_patterns [0:N_PATTERNS-1];
    initial $readmemh("patterns.hex", r_patterns);

    // ────────────────────────────────────────────
    // Auto-advance tick generator
    // ────────────────────────────────────────────
    localparam TICK_COUNT = CLK_FREQ / AUTO_RATE_HZ;
    reg [$clog2(TICK_COUNT)-1:0] r_tick_counter;
    wire w_auto_tick;

    // TODO: Implement the tick counter
    //       Count from 0 to TICK_COUNT-1, then wrap
    //       w_auto_tick should pulse high for one cycle when count wraps
    //       Reset the counter on i_reset
    //
    // ---- YOUR CODE HERE ----

    // ────────────────────────────────────────────
    // Advance selection: auto tick or manual button
    // ────────────────────────────────────────────
    wire w_advance = i_auto_mode ? w_auto_tick : i_next;

    // ────────────────────────────────────────────
    // Address counter
    // ────────────────────────────────────────────
    reg [3:0] r_addr;

    // TODO: Implement the address counter
    //       On i_reset: r_addr <= 0
    //       On w_advance: r_addr <= (r_addr == N_PATTERNS-1) ? 0 : r_addr + 1
    //
    // ---- YOUR CODE HERE ----

    // ────────────────────────────────────────────
    // ROM read (async — fine for 16-entry LUT ROM)
    // ────────────────────────────────────────────
    assign o_pattern = r_patterns[r_addr];
    assign o_index   = r_addr;

endmodule
