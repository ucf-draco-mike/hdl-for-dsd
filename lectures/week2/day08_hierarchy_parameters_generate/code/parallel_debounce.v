// =============================================================================
// parallel_debounce.v — Generate-Based Multi-Button Debouncer
// Day 8: Hierarchy, Parameters & Generate
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Demonstrates generate-for to stamp out N debounce instances.

module parallel_debounce #(
    parameter N_BUTTONS      = 4,
    parameter CLKS_TO_STABLE = 250_000
)(
    input  wire                    i_clk,
    input  wire [N_BUTTONS-1:0]    i_buttons,
    output wire [N_BUTTONS-1:0]    o_clean
);

    genvar g;
    generate
        for (g = 0; g < N_BUTTONS; g = g + 1) begin : gen_debounce
            debounce #(
                .CLKS_TO_STABLE(CLKS_TO_STABLE)
            ) debounce_inst (
                .i_clk    (i_clk),
                .i_bouncy (i_buttons[g]),
                .o_clean  (o_clean[g])
            );
        end
    endgenerate

endmodule
