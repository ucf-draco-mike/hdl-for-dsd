// pattern_sequencer.v — ROM-based LED + 7-seg pattern player (SOLUTION)
module pattern_sequencer #(
    parameter CLK_FREQ     = 25_000_000,
    parameter N_PATTERNS   = 16,
    parameter AUTO_RATE_HZ = 2
)(
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_next,
    input  wire       i_auto_mode,
    output wire [7:0] o_pattern,
    output wire [3:0] o_index
);

    // ROM
    reg [7:0] r_patterns [0:N_PATTERNS-1];
    initial $readmemh("patterns.hex", r_patterns);

    // Auto-advance tick generator
    localparam TICK_COUNT = CLK_FREQ / AUTO_RATE_HZ;
    reg [$clog2(TICK_COUNT)-1:0] r_tick_counter;
    wire w_auto_tick;

    always @(posedge i_clk) begin
        if (i_reset || r_tick_counter == TICK_COUNT - 1)
            r_tick_counter <= 0;
        else
            r_tick_counter <= r_tick_counter + 1;
    end
    assign w_auto_tick = (r_tick_counter == TICK_COUNT - 1);

    // Advance selection
    wire w_advance = i_auto_mode ? w_auto_tick : i_next;

    // Address counter
    reg [3:0] r_addr;

    always @(posedge i_clk) begin
        if (i_reset)
            r_addr <= 0;
        else if (w_advance)
            r_addr <= (r_addr == N_PATTERNS - 1) ? 4'd0 : r_addr + 1;
    end

    // ROM read (async)
    assign o_pattern = r_patterns[r_addr];
    assign o_index   = r_addr;

endmodule
