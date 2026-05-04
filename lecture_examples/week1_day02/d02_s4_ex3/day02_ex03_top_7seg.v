//-----------------------------------------------------------------------------
// File:    day02_ex03_top_7seg.v
// Course:  Accelerated HDL for Digital System Design — Day 2
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   Top-level wrapper for the hex_to_7seg decoder. Collects the four
//   on-board switches into a 4-bit hex value and fans the decoder's
//   active-low segment vector out to the individual segment pins
//   defined in go_board.pcf. Without this wrapper the bare decoder
//   leaves o_segment1_* unconstrained at place-and-route.
//
// Build:
//   yosys -p "synth_ice40 -top top_7seg -json top_7seg.json" \
//         day02_ex03_hex_to_7seg.v day02_ex03_top_7seg.v
//-----------------------------------------------------------------------------
module top_7seg (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_segment1_a,
    output wire o_segment1_b,
    output wire o_segment1_c,
    output wire o_segment1_d,
    output wire o_segment1_e,
    output wire o_segment1_f,
    output wire o_segment1_g
);

    // Pack switches into a 4-bit hex nibble (switch1 = MSB)
    wire [3:0] w_hex = {i_switch1, i_switch2, i_switch3, i_switch4};

    // Decoder output: {a, b, c, d, e, f, g}, active-low
    wire [6:0] w_seg;

    hex_to_7seg u_decoder (
        .i_hex (w_hex),
        .o_seg (w_seg)
    );

    // Fan segment vector out to the individual board pins
    assign o_segment1_a = w_seg[6];
    assign o_segment1_b = w_seg[5];
    assign o_segment1_c = w_seg[4];
    assign o_segment1_d = w_seg[3];
    assign o_segment1_e = w_seg[2];
    assign o_segment1_f = w_seg[1];
    assign o_segment1_g = w_seg[0];

endmodule
