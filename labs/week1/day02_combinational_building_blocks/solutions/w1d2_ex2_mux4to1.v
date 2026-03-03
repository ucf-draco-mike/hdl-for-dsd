// =============================================================================
// Exercise 2 SOLUTION, Part B: 4:1 Multiplexer from 2:1 Muxes
// Day 2 · Combinational Building Blocks
// =============================================================================

module mux4to1 (
    input  wire       i_d0,
    input  wire       i_d1,
    input  wire       i_d2,
    input  wire       i_d3,
    input  wire [1:0] i_sel,
    output wire       o_y
);

    wire w_mux_lo, w_mux_hi;

    mux2to1 mux_lo (
        .i_a(i_d0), .i_b(i_d1), .i_sel(i_sel[0]), .o_y(w_mux_lo)
    );

    mux2to1 mux_hi (
        .i_a(i_d2), .i_b(i_d3), .i_sel(i_sel[0]), .o_y(w_mux_hi)
    );

    mux2to1 mux_final (
        .i_a(w_mux_lo), .i_b(w_mux_hi), .i_sel(i_sel[1]), .o_y(o_y)
    );

endmodule
