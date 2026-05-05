// =============================================================================
// pattern_sequencer.v — ROM-Driven LED Pattern Player
// Day 9 · Topic 9.4: Practical Memory Applications · Demo example 3
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Composition: step timer  →  address counter  →  rom_array  →  o_leds.
// Edit pattern.hex and rebuild for a new animation — RTL doesn't change.
//
// At STEP_LEN = 10_000_000 (default), each step lasts 0.4 s @ 25 MHz, so a
// 16-step pattern wraps every 6.4 s.
// =============================================================================

module pattern_sequencer #(
    parameter STEP_LEN    = 10_000_000,    // cycles per pattern step (0.4 s @ 25 MHz)
    parameter PATTERN_LEN = 16,            // number of steps in the sequence
    parameter INIT_FILE   = "pattern.hex"
) (
    input  wire       i_clk,
    input  wire       i_reset,
    output wire [7:0] o_leds
);
    localparam STEP_W = (STEP_LEN    <= 1) ? 1 : $clog2(STEP_LEN);
    localparam ADDR_W = (PATTERN_LEN <= 1) ? 1 : $clog2(PATTERN_LEN);

    // ---- Step timer: pulses w_step_tick once every STEP_LEN cycles ----
    reg  [STEP_W-1:0] r_step_counter;
    wire              w_step_tick = (r_step_counter == STEP_LEN - 1);

    always @(posedge i_clk) begin
        if (i_reset)         r_step_counter <= 0;
        else if (w_step_tick) r_step_counter <= 0;
        else                  r_step_counter <= r_step_counter + 1'b1;
    end

    // ---- Address counter: advances on each step_tick, wraps at PATTERN_LEN ----
    reg [ADDR_W-1:0] r_addr;
    always @(posedge i_clk) begin
        if (i_reset)
            r_addr <= 0;
        else if (w_step_tick)
            r_addr <= (r_addr == PATTERN_LEN - 1) ? {ADDR_W{1'b0}} : r_addr + 1'b1;
    end

    // ---- ROM: 16 x 8 patterns loaded from pattern.hex ----
    rom_array #(
        .ADDR_W(ADDR_W), .DATA_W(8), .INIT_FILE(INIT_FILE)
    ) u_rom (
        .i_clk(i_clk), .i_addr(r_addr), .o_data(o_leds)
    );

endmodule
