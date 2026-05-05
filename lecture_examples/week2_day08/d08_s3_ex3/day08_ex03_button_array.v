// =============================================================================
// day08_ex03_button_array.v — Generate-Based N-Button Input Pipeline
// Day 8: Hierarchy, Parameters & Generate
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Demonstrates: generate-for, parameterized instantiation, hierarchy.
// Creates N independent debounce + edge-detect lanes from one source file.
// One Verilog source serves N=4, N=8, N=16, ... — only the parameter changes.
//
// Synth (override N at the command line for the d08_s3 PPA sweep demo):
//   yosys -p "read_verilog day08_ex03_button_array.v debounce.v; \
//             chparam -set N 16 button_array; \
//             synth_ice40 -top button_array; stat"
// =============================================================================

module button_array #(
    parameter N           = 4,          // Number of buttons
    parameter CLKS_STABLE = 250_000     // Debounce threshold (10 ms at 25 MHz)
)(
    input  wire         i_clk,
    input  wire [N-1:0] i_buttons,      // raw button inputs (active-high ok)
    output wire [N-1:0] o_clean,        // debounced levels
    output wire [N-1:0] o_press_edge,   // one-cycle pulse on press
    output wire [N-1:0] o_release_edge  // one-cycle pulse on release
);

    // ---- Generate N debounce + edge-detect lanes ----
    genvar gi;
    generate
        for (gi = 0; gi < N; gi = gi + 1) begin : g_btn
            // Debouncer (includes built-in 2-FF synchronizer).
            debounce #(
                .CLKS_STABLE(CLKS_STABLE)
            ) u_deb (
                .i_clk   (i_clk),
                .i_noisy (i_buttons[gi]),
                .o_clean (o_clean[gi])
            );

            // One-cycle edge pulses on the debounced level.
            reg r_prev = 1'b1;   // idle-high: matches debouncer's reset state
            always @(posedge i_clk)
                r_prev <= o_clean[gi];

            assign o_press_edge[gi]   =  o_clean[gi] & ~r_prev;   // rising
            assign o_release_edge[gi] = ~o_clean[gi] &  r_prev;   // falling
        end
    endgenerate

endmodule
