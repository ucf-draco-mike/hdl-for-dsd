// =============================================================================
// Exercise 4: Top Module — 7-Seg Display on Go Board
// Day 2 · Combinational Building Blocks
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================

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

    // Collect switches into 4-bit hex value (active-high internally)
    wire [3:0] w_hex = {i_switch1, i_switch2, i_switch3, i_switch4};

    // Decoder output
    wire [6:0] w_seg;

    // TODO: Instantiate hex_to_7seg decoder
    // hex_to_7seg decoder (
    //     .i_hex(w_hex),
    //     .o_seg(w_seg)
    // );

    // Map decoder output to individual segment pins
    assign o_segment1_a = w_seg[6];
    assign o_segment1_b = w_seg[5];
    assign o_segment1_c = w_seg[4];
    assign o_segment1_d = w_seg[3];
    assign o_segment1_e = w_seg[2];
    assign o_segment1_f = w_seg[1];
    assign o_segment1_g = w_seg[0];

endmodule
