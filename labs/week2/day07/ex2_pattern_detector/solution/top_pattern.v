// =============================================================================
// top_pattern.v — Go Board Top Level for Pattern Detector (Solution)
// Day 7, Exercise 2
// =============================================================================

module top_pattern (
    input  wire i_clk,
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,  // reset
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // Debounce all 4 buttons
    wire w_sw1_clean, w_sw2_clean, w_sw3_clean, w_reset_clean;

    debounce #(.CLKS_TO_STABLE(250_000)) db1 (
        .i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(w_sw1_clean));
    debounce #(.CLKS_TO_STABLE(250_000)) db2 (
        .i_clk(i_clk), .i_bouncy(i_switch2), .o_clean(w_sw2_clean));
    debounce #(.CLKS_TO_STABLE(250_000)) db3 (
        .i_clk(i_clk), .i_bouncy(i_switch3), .o_clean(w_sw3_clean));
    debounce #(.CLKS_TO_STABLE(250_000)) db_reset (
        .i_clk(i_clk), .i_bouncy(i_switch4), .o_clean(w_reset_clean));

    // Edge detect
    reg r_sw1_prev, r_sw2_prev, r_sw3_prev;
    always @(posedge i_clk) begin
        r_sw1_prev <= w_sw1_clean;
        r_sw2_prev <= w_sw2_clean;
        r_sw3_prev <= w_sw3_clean;
    end
    wire w_btn1 = ~w_sw1_clean & r_sw1_prev;
    wire w_btn2 = ~w_sw2_clean & r_sw2_prev;
    wire w_btn3 = ~w_sw3_clean & r_sw3_prev;

    wire w_reset = ~w_reset_clean;
    wire w_detected;
    wire [1:0] w_progress;

    pattern_detector pd (
        .i_clk(i_clk), .i_reset(w_reset),
        .i_btn1(w_btn1), .i_btn2(w_btn2), .i_btn3(w_btn3),
        .o_detected(w_detected), .o_progress(w_progress)
    );

    assign o_led1 = ~w_progress[1];
    assign o_led2 = ~w_progress[0];
    assign o_led4 = ~w_detected;

    reg [23:0] r_hb;
    always @(posedge i_clk) r_hb <= r_hb + 1;
    assign o_led3 = ~r_hb[23];

endmodule
