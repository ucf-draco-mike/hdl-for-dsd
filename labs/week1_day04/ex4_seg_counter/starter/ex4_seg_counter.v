// =============================================================================
// Exercise 4: 7-Segment Counter (Week 1 Capstone)
// Day 4 · Sequential Logic Fundamentals
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Display a running hex counter (0-F) on the 7-segment display.
// Count rate: slow enough to read (~2 Hz)
//
// This exercise integrates:
//   - Sequential logic (counter)
//   - Combinational logic (7-seg decoder)
//   - Clock division (tick generation)
// =============================================================================

module seg_counter (
    input  wire i_clk,
    output wire o_led1,        // heartbeat (fast blink)
    output wire o_segment1_a,
    output wire o_segment1_b,
    output wire o_segment1_c,
    output wire o_segment1_d,
    output wire o_segment1_e,
    output wire o_segment1_f,
    output wire o_segment1_g
);

    // ---- Clock Divider: generate a ~2 Hz tick ----
    // TODO: Count to 12,500,000 - 1, then assert a one-cycle tick
    //
    // reg [23:0] r_clk_count = 24'd0;
    // reg        r_tick      = 1'b0;
    //
    // always @(posedge i_clk) begin
    //     if (r_clk_count == 24'd12_499_999) begin
    //         r_clk_count <= 24'd0;
    //         r_tick      <= 1'b1;
    //     end else begin
    //         r_clk_count <= r_clk_count + 24'd1;
    //         r_tick      <= 1'b0;
    //     end
    // end

    // ---- 4-bit Display Counter ----
    // TODO: Increment on each tick (0 → F → 0 → ...)
    //
    // reg [3:0] r_display = 4'd0;
    //
    // always @(posedge i_clk) begin
    //     if (r_tick)
    //         r_display <= r_display + 4'd1;
    // end

    // ---- 7-Segment Decoder ----
    // TODO: Decode r_display to segment pattern
    // You can inline the case statement or instantiate hex_to_7seg

    // ---- Heartbeat ----
    // TODO: Blink LED1 from a counter bit for visual feedback

    // Placeholder outputs — replace with your implementation
    assign o_led1 = 1'b0;
    assign o_segment1_a = 1'b1;
    assign o_segment1_b = 1'b1;
    assign o_segment1_c = 1'b1;
    assign o_segment1_d = 1'b1;
    assign o_segment1_e = 1'b1;
    assign o_segment1_f = 1'b1;
    assign o_segment1_g = 1'b1;

endmodule
