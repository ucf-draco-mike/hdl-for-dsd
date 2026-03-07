// top_reaction.v — Reaction Time Game Project Skeleton
// Game flow:
//   1. Press SW1 to start → all LEDs off
//   2. Random delay (LFSR-based, 1–5 seconds) → LED1 lights up
//   3. Player presses SW2 as fast as possible
//   4. Reaction time (in ms) shown on 7-segment displays
//   5. Press SW1 to play again
//
// Architecture:
//   Control FSM → LFSR (random delay) → ms counter → display driver
module top_reaction (
    input  wire i_clk,
    input  wire i_switch1, i_switch2, i_switch3, i_switch4,
    input  wire i_uart_rx,
    output wire o_uart_tx,
    output wire o_led1, o_led2, o_led3, o_led4,
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g,
    output wire o_segment2_a, o_segment2_b, o_segment2_c,
    output wire o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g
);
    // ────────────────────────────────────────────
    // Heartbeat
    // ────────────────────────────────────────────
    reg [23:0] r_heartbeat;
    always @(posedge i_clk)
        r_heartbeat <= r_heartbeat + 1;

    // ────────────────────────────────────────────
    // Debounce switches
    // ────────────────────────────────────────────
    wire sw1, sw2;
    debounce db1 (.i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(sw1));
    debounce db2 (.i_clk(i_clk), .i_bouncy(i_switch2), .o_clean(sw2));

    // Edge detectors
    // TODO: Detect rising edge of sw1 and sw2
    // ---- YOUR CODE HERE ----

    // ────────────────────────────────────────────
    // LFSR — 16-bit pseudo-random number generator
    // ────────────────────────────────────────────
    // TODO: Implement a 16-bit LFSR for random delay generation
    //       Taps for maximal-length: bits 15, 14, 12, 3
    //       Polynomial: x^16 + x^15 + x^13 + x^4 + 1
    //       Use lower bits to set random delay (1–5 seconds range)
    //
    // ---- YOUR CODE HERE ----
    reg [15:0] r_lfsr;

    // ────────────────────────────────────────────
    // Game FSM
    // ────────────────────────────────────────────
    // States: IDLE → WAITING → REACT → DISPLAY
    //   IDLE:    Show last score or "00". Wait for SW1 press.
    //   WAITING: Count down random delay. All LEDs off.
    //   REACT:   LED1 on. Start ms counter. Wait for SW2.
    //   DISPLAY: Show reaction time on 7-seg. Wait for SW1.
    //
    // TODO: Implement the game FSM
    //       - 1 ms tick: 25_000_000 / 1000 = 25000 clocks per ms
    //       - ms counter: counts milliseconds while in REACT state
    //       - Cheat detection: if SW2 pressed during WAITING, show "EE" (error)
    //
    // ---- YOUR CODE HERE ----
    localparam S_IDLE    = 2'd0;
    localparam S_WAITING = 2'd1;
    localparam S_REACT   = 2'd2;
    localparam S_DISPLAY = 2'd3;

    reg [1:0]  r_state;
    reg [7:0]  r_reaction_ms;    // 0–255 ms (8-bit fits 2 hex digits)

    // ────────────────────────────────────────────
    // 7-Segment Display
    // ────────────────────────────────────────────
    wire [6:0] w_seg1, w_seg2;
    hex_to_7seg seg1 (.i_hex(r_reaction_ms[7:4]), .o_seg(w_seg1));
    hex_to_7seg seg2 (.i_hex(r_reaction_ms[3:0]), .o_seg(w_seg2));

    // ────────────────────────────────────────────
    // Outputs
    // ────────────────────────────────────────────
    // TODO: Drive LEDs based on game state
    //       LED1 = stimulus indicator (on in REACT state)
    //       LED2 = "game active" (on in WAITING or REACT)
    //       LED3 = "cheat detected" (on if player pressed early)
    //       LED4 = heartbeat
    //
    // ---- YOUR CODE HERE ----
    assign o_led1 = 1'b0;
    assign o_led2 = 1'b0;
    assign o_led3 = 1'b0;
    assign o_led4 = r_heartbeat[23];

    assign o_uart_tx = 1'b1;   // UART unused — idle high

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = w_seg1;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = w_seg2;
endmodule
