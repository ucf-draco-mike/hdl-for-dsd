// =============================================================================
// top_timing_demo.v — Timing Analysis Target Design
// Day 10, Exercise 1: Timing Analysis Practice
// =============================================================================
// Synthesize this design at different frequency constraints and analyze reports.

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

    // Active-high buttons
    wire [3:0] w_btn = ~{i_switch4, i_switch3, i_switch2, i_switch1};

    // A moderate combinational chain for timing analysis
    // TODO: Implement a multi-stage computation
    //   Stage 1: result1 = w_btn + 4'b0011
    //   Stage 2: result2 = result1 ^ {result1[2:0], result1[3]}
    //   Stage 3: result3 = result2 * result1 (4-bit multiply)
    //   Stage 4: final  = result3[3:0] + result2
    //
    // These are ALL combinational (assign statements).
    // The long chain should show up in timing analysis.

    wire [3:0] w_result1;
    wire [3:0] w_result2;
    wire [7:0] w_result3;
    wire [3:0] w_final;

    // ---- YOUR CODE HERE (4 assign statements) ----

    // Register the final result for display
    reg [3:0] r_display;
    always @(posedge i_clk)
        r_display <= w_final;

    // LED output
    assign {o_led4, o_led3, o_led2, o_led1} = ~r_display;

    // 7-segment display (reuse your hex_to_7seg or instantiate inline)
    // ---- YOUR CODE HERE ----
    // Instantiate hex_to_7seg to show r_display on segment1

endmodule
