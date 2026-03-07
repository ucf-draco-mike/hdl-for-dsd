// =============================================================================
// Exercise 2, Part B: 4:1 Multiplexer from 2:1 Muxes
// Day 2 · Combinational Building Blocks
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Build a 4:1 mux by instantiating three 2:1 muxes hierarchically.
//
//   d0 ─┐
//        mux_lo ─┐
//   d1 ─┘        │
//                 mux_final ── o_y
//   d2 ─┐        │
//        mux_hi ─┘
//   d3 ─┘
//
//   sel[0] controls mux_lo and mux_hi
//   sel[1] controls mux_final
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

    // TODO: Instantiate three mux2to1 modules using NAMED port connections
    //
    // mux_lo:    selects between d0 and d1 using sel[0]
    // mux_hi:    selects between d2 and d3 using sel[0]
    // mux_final: selects between mux_lo and mux_hi using sel[1]

endmodule
