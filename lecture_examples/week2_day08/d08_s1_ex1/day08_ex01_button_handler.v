// =============================================================================
// day08_ex01_button_handler.v — Hierarchical Button Pipeline (top-level)
// Day 8: Hierarchy, Parameters & Generate
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Top-level composition for the d08_s1 "Build a Hierarchical Design" demo.
// Wires three reusable sub-modules into one signal pipeline:
//
//   raw_btn ─▶ [sync_2ff] ─▶ [debounce] ─▶ [edge_detect] ─▶ press / release
//
// Demonstrates: named instance prefixes (u_*), named port connections,
// parameter override, and Yosys hierarchy preservation.
//
// Build: see Makefile in this directory ('make sim', 'make stat', 'make prog').
// =============================================================================

module button_handler #(
    parameter CLKS_STABLE = 250_000   // 10 ms @ 25 MHz; override low for sim.
) (
    input  wire i_clk,
    input  wire i_btn_raw,            // asynchronous, bouncy button input
    output wire o_btn_clean,          // debounced, synchronized level
    output wire o_press,              // 1-cycle pulse on press
    output wire o_release             // 1-cycle pulse on release
);

    // ---- Stage 1: 2-FF synchronizer (CDC safety) ----
    wire w_sync;
    sync_2ff u_sync (
        .i_clk      (i_clk),
        .i_async_in (i_btn_raw),
        .o_sync_out (w_sync)
    );

    // ---- Stage 2: debouncer (mechanical switch filtering) ----
    wire w_clean;
    debounce #(.CLKS_STABLE(CLKS_STABLE)) u_debounce (
        .i_clk   (i_clk),
        .i_noisy (w_sync),
        .o_clean (w_clean)
    );

    // ---- Stage 3: edge detection (one-cycle event pulses) ----
    edge_detect u_edge (
        .i_clk   (i_clk),
        .i_level (w_clean),
        .o_rise  (o_press),
        .o_fall  (o_release)
    );

    assign o_btn_clean = w_clean;

endmodule
