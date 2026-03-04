// =============================================================================
// Exercise 4 SOLUTION: Top Module — 7-Seg Display
// Day 2 · Combinational Building Blocks
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

    wire [3:0] w_hex = ~{i_switch1, i_switch2, i_switch3, i_switch4};
    wire [6:0] w_seg;

    hex_to_7seg decoder (
        .i_hex(w_hex),
        .o_seg(w_seg)
    );

    assign o_segment1_a = w_seg[6];
    assign o_segment1_b = w_seg[5];
    assign o_segment1_c = w_seg[4];
    assign o_segment1_d = w_seg[3];
    assign o_segment1_e = w_seg[2];
    assign o_segment1_f = w_seg[1];
    assign o_segment1_g = w_seg[0];

endmodule
