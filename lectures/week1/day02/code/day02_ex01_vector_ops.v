//-----------------------------------------------------------------------------
// File:    day02_ex01_vector_ops.v
// Course:  Accelerated HDL for Digital System Design — Day 2
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   Demonstrates vector operations: bit selection, concatenation,
//   replication, and sign extension. Connect switches to i_data[3:0]
//   and observe results on LEDs and 7-segment display.
//
// Build:
//   yosys -p "synth_ice40 -top vector_ops -json day02_ex01_vector_ops.json" day02_ex01_vector_ops.v
//   nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf \
//                 --json day02_ex01_vector_ops.json --asc day02_ex01_vector_ops.asc
//   icepack day02_ex01_vector_ops.asc day02_ex01_vector_ops.bin
//   iceprog day02_ex01_vector_ops.bin
//-----------------------------------------------------------------------------
module vector_ops (
    input  wire [7:0] i_data,
    input  wire [3:0] i_nibble_a,
    input  wire [3:0] i_nibble_b,
    output wire [7:0] o_concat,
    output wire [7:0] o_replicate,
    output wire [7:0] o_sign_ext,
    output wire [3:0] o_upper,
    output wire [3:0] o_lower,
    output wire       o_msb
);
    // Bit selection
    assign o_msb   = i_data[7];
    assign o_upper = i_data[7:4];
    assign o_lower = i_data[3:0];

    // Concatenation: join two 4-bit values → one 8-bit value
    assign o_concat = {i_nibble_a, i_nibble_b};

    // Replication: 8 copies of bit 0
    assign o_replicate = {8{i_data[0]}};

    // Sign extension: extend 4-bit signed value to 8 bits
    assign o_sign_ext = {{4{i_nibble_a[3]}}, i_nibble_a};
endmodule
