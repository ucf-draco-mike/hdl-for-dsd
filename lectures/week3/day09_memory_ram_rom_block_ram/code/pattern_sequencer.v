// =============================================================================
// pattern_sequencer.v — ROM-Based LED Pattern Player
// Day 9: Memory — RAM, ROM & Block RAM
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Reads LED patterns from a memory file and cycles through them.
// Uses $readmemb for binary pattern data.

module pattern_sequencer #(
    parameter PATTERN_LEN = 16,
    parameter MEM_FILE    = "pattern.mem"
)(
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_tick,    // advance rate (from clock divider)
    output wire [3:0] o_leds
);

    reg [$clog2(PATTERN_LEN)-1:0] r_addr;
    reg [3:0] r_pattern [0:PATTERN_LEN-1];

    initial begin
        $readmemb(MEM_FILE, r_pattern);
    end

    always @(posedge i_clk) begin
        if (i_reset)
            r_addr <= 0;
        else if (i_tick)
            r_addr <= (r_addr == PATTERN_LEN - 1) ? 0 : r_addr + 1;
    end

    assign o_leds = r_pattern[r_addr];

endmodule
