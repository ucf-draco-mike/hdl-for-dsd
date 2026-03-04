// top_pattern.v — Go Board top module for ROM pattern sequencer
// SW1 = reset, SW2 = manual advance, SW3 = auto/manual toggle
// LEDs = lower 4 bits, 7-seg1 = upper nibble (hex), 7-seg2 = index
module top_pattern (
    input  wire i_clk,
    input  wire i_switch1, i_switch2, i_switch3, i_switch4,
    output wire o_led1, o_led2, o_led3, o_led4,
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g,
    output wire o_segment2_a, o_segment2_b, o_segment2_c,
    output wire o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g
);
    // Debounce switches
    wire sw1, sw2, sw3;
    debounce db1 (.i_clk(i_clk), .i_switch(i_switch1), .o_switch(sw1));
    debounce db2 (.i_clk(i_clk), .i_switch(i_switch2), .o_switch(sw2));
    debounce db3 (.i_clk(i_clk), .i_switch(i_switch3), .o_switch(sw3));

    // Edge detect for manual step
    reg r_sw2_prev;
    always @(posedge i_clk) r_sw2_prev <= sw2;
    wire w_step = sw2 & ~r_sw2_prev;

    // Pattern sequencer
    wire [7:0] w_pattern;
    wire [3:0] w_index;

    pattern_sequencer #(
        .CLK_FREQ     (25_000_000),
        .N_PATTERNS   (16),
        .AUTO_RATE_HZ (2)
    ) u_seq (
        .i_clk       (i_clk),
        .i_reset     (sw1),
        .i_next      (w_step),
        .i_auto_mode (sw3),
        .o_pattern   (w_pattern),
        .o_index     (w_index)
    );

    // 7-segment decoders
    wire [6:0] w_seg1, w_seg2;
    hex_to_7seg seg1 (.i_hex(w_pattern[7:4]), .o_seg(w_seg1));
    hex_to_7seg seg2 (.i_hex(w_index),        .o_seg(w_seg2));

    // Outputs (LEDs are active-low)
    assign o_led1 = ~w_pattern[0];
    assign o_led2 = ~w_pattern[1];
    assign o_led3 = ~w_pattern[2];
    assign o_led4 = ~w_pattern[3];

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = w_seg1;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = w_seg2;
endmodule
