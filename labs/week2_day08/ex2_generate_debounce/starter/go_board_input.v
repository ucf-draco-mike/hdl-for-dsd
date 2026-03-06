// =============================================================================
// go_board_input.v — Generate-Based Multi-Channel Input Processor (Starter — Provided)
// Day 8, Exercise 2 — study this code, then use it in Exercise 3
// =============================================================================

module go_board_input #(
    parameter N_BUTTONS   = 4,
    parameter CLK_FREQ    = 25_000_000,
    parameter DEBOUNCE_MS = 10
)(
    input  wire                  i_clk,
    input  wire [N_BUTTONS-1:0]  i_buttons,  // active-high raw
    output wire [N_BUTTONS-1:0]  o_buttons,     // active-high debounced
    output wire [N_BUTTONS-1:0]  o_press_edge,
    output wire [N_BUTTONS-1:0]  o_release_edge
);

    localparam CLKS_TO_STABLE = (CLK_FREQ / 1000) * DEBOUNCE_MS;

    genvar g;
    generate
        for (g = 0; g < N_BUTTONS; g = g + 1) begin : gen_btn
            wire w_clean;
            debounce #(.CLKS_TO_STABLE(CLKS_TO_STABLE)) db (
                .i_clk(i_clk),
                .i_bouncy(i_buttons[g]),
                .o_clean(w_clean)
            );

            assign o_buttons[g] = ~w_clean;

            reg r_prev;
            always @(posedge i_clk) r_prev <= o_buttons[g];

            assign o_press_edge[g]   = o_buttons[g] & ~r_prev;
            assign o_release_edge[g] = ~o_buttons[g] & r_prev;
        end
    endgenerate

endmodule
