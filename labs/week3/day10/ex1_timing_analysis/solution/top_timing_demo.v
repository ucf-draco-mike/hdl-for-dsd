// =============================================================================
// top_timing_demo.v — SOLUTION
// Day 10, Exercise 1
// =============================================================================

module top_timing_demo (
    input  wire i_clk,
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1, o_led2, o_led3, o_led4,
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g
);

    wire [3:0] w_btn = ~{i_switch4, i_switch3, i_switch2, i_switch1};

    // Multi-stage combinational chain
    wire [3:0] w_result1 = w_btn + 4'b0011;
    wire [3:0] w_result2 = w_result1 ^ {w_result1[2:0], w_result1[3]};
    wire [7:0] w_result3 = w_result2 * w_result1;
    wire [3:0] w_final   = w_result3[3:0] + w_result2;

    reg [3:0] r_display;
    always @(posedge i_clk)
        r_display <= w_final;

    assign {o_led4, o_led3, o_led2, o_led1} = ~r_display;

    hex_to_7seg seg1 (
        .i_hex(r_display),
        .o_seg_a(o_segment1_a), .o_seg_b(o_segment1_b),
        .o_seg_c(o_segment1_c), .o_seg_d(o_segment1_d),
        .o_seg_e(o_segment1_e), .o_seg_f(o_segment1_f),
        .o_seg_g(o_segment1_g)
    );

endmodule
