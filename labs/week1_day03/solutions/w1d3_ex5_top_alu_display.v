// =============================================================================
// Exercise 5 SOLUTION (Stretch): ALU + 7-Seg Integration
// Day 3 · Procedural Combinational Logic
// =============================================================================

module top_alu_display (
    input  wire i_switch1,
    input  wire i_switch2,
    output wire o_led1,
    output wire o_led2,
    output wire o_segment1_a,
    output wire o_segment1_b,
    output wire o_segment1_c,
    output wire o_segment1_d,
    output wire o_segment1_e,
    output wire o_segment1_f,
    output wire o_segment1_g
);

    wire [1:0] w_opcode = ~{i_switch1, i_switch2};
    wire [3:0] w_result;
    wire       w_zero, w_carry;

    alu_4bit alu (
        .i_a(4'd7), .i_b(4'd3), .i_opcode(w_opcode),
        .o_result(w_result), .o_zero(w_zero), .o_carry(w_carry)
    );

    wire [6:0] w_seg;
    hex_to_7seg decoder (.i_hex(w_result), .o_seg(w_seg));

    assign o_led1 = ~w_carry;
    assign o_led2 = ~w_zero;
    assign o_segment1_a = w_seg[6];
    assign o_segment1_b = w_seg[5];
    assign o_segment1_c = w_seg[4];
    assign o_segment1_d = w_seg[3];
    assign o_segment1_e = w_seg[2];
    assign o_segment1_f = w_seg[1];
    assign o_segment1_g = w_seg[0];

endmodule
