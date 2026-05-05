// =============================================================================
// day05_ex04_top.v — Go Board top wrapper for the debounce live demo
// Day 5: Counters, Shift Registers & Debouncing
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Wires up the canonical input pipeline:
//
//   i_switch1 -> [2-FF sync] -> [debounce] -> [edge detect] -> press_count[3:0]
//
// Each clean rising edge on the synchronized + debounced switch increments
// a 4-bit counter shown on o_led1..o_led4. Press SW1 once and exactly one
// LED bit toggles per press (no spurious bounces).
//
// Build with `make prog` from this folder; reads ../go_board.pcf.
// =============================================================================

`ifndef CLKS_STABLE_TOP
// Default: 20 ms at 25 MHz clock = 500_000 cycles.
`define CLKS_STABLE_TOP 500_000
`endif

module ex04_top (
    input  wire i_clk,
    input  wire i_switch1,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // Stage 1: 2-FF synchronizer (inline so this top is self-contained).
    reg r_sync_meta = 1'b0;
    reg r_sync_out  = 1'b0;
    always @(posedge i_clk) begin
        r_sync_meta <= i_switch1;
        r_sync_out  <= r_sync_meta;
    end

    // Stage 2: debouncer (re-uses the example's debounce module).
    wire w_clean;
    debounce #(.CLKS_STABLE(`CLKS_STABLE_TOP)) u_deb (
        .i_clk(i_clk),
        .i_reset(1'b0),         // free-running on the board
        .i_noisy(r_sync_out),
        .o_clean(w_clean)
    );

    // Stage 3: rising-edge detect — one-cycle pulse per debounced press.
    reg  r_clean_d1 = 1'b0;
    always @(posedge i_clk) r_clean_d1 <= w_clean;
    wire w_press_pulse = w_clean & ~r_clean_d1;

    // Increment a 4-bit counter on each press; show on the four LEDs.
    reg [3:0] r_press_count = 4'd0;
    always @(posedge i_clk)
        if (w_press_pulse)
            r_press_count <= r_press_count + 4'd1;

    assign {o_led4, o_led3, o_led2, o_led1} = r_press_count;

endmodule
