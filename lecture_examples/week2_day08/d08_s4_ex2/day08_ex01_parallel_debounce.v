// =============================================================================
// day08_ex01_parallel_debounce.v — Generate-Based N-Button Input Pipeline
// Day 8: Hierarchy, Parameters & Generate
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Demonstrates: generate-for, parameterized instantiation, hierarchy.
// Creates N independent debounce + edge-detect pipelines from one module.
// =============================================================================
// Synth:  yosys -p "read_verilog day08_ex01_parallel_debounce.v debounce.v; \
//          synth_ice40 -top parallel_debounce"
// =============================================================================

module parallel_debounce #(
    parameter N              = 4,          // Number of buttons
    parameter CLKS_TO_STABLE = 250_000     // Debounce threshold (10 ms at 25 MHz)
)(
    input  wire         i_clk,
    input  wire [N-1:0] i_buttons,      // raw button inputs (active-high ok)
    output wire [N-1:0] o_clean,        // debounced levels
    output wire [N-1:0] o_press_edge,   // one-cycle pulse on press
    output wire [N-1:0] o_release_edge  // one-cycle pulse on release
);

    // ---- Generate N debounce + edge detect pipelines ----
    genvar g;
    generate
        for (g = 0; g < N; g = g + 1) begin : gen_input
            // Debouncer (includes built-in 2-FF synchronizer)
            debounce #(
                .CLKS_TO_STABLE(CLKS_TO_STABLE)
            ) db (
                .i_clk    (i_clk),
                .i_bouncy (i_buttons[g]),
                .o_clean  (o_clean[g])
            );

            // Edge detector
            reg r_prev;
            always @(posedge i_clk)
                r_prev <= o_clean[g];

            assign o_press_edge[g]   = o_clean[g] & ~r_prev;   // rising edge
            assign o_release_edge[g] = ~o_clean[g] & r_prev;   // falling edge
        end
    endgenerate

endmodule
