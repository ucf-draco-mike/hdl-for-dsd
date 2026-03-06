// =============================================================================
// Exercise 5 SOLUTION: Dual-Speed Blinker
// Day 4 · Sequential Logic Fundamentals
// =============================================================================

module dual_blinker (
    input  wire i_clk,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // Counter 1: ~1 Hz
    reg [23:0] r_cnt1 = 24'd0;
    reg        r_led1 = 1'b0;

    always @(posedge i_clk) begin
        if (r_cnt1 == 24'd12_499_999) begin
            r_cnt1 <= 24'd0;
            r_led1 <= ~r_led1;
        end else begin
            r_cnt1 <= r_cnt1 + 24'd1;
        end
    end

    // Counter 2: ~4 Hz
    reg [21:0] r_cnt2 = 22'd0;
    reg        r_led3 = 1'b0;

    always @(posedge i_clk) begin
        if (r_cnt2 == 22'd3_124_999) begin
            r_cnt2 <= 22'd0;
            r_led3 <= ~r_led3;
        end else begin
            r_cnt2 <= r_cnt2 + 22'd1;
        end
    end

    // Complementary pairs
    assign o_led1 = r_led1;
    assign o_led2 = r_led1;    // inverted from led1
    assign o_led3 = r_led3;
    assign o_led4 = r_led3;    // inverted from led3

endmodule
