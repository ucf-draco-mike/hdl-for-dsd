// top_stopwatch.v — Stopwatch / Lap Timer Project Skeleton
// Features:
//   SW1 = start/stop toggle, SW2 = lap capture, SW3 = cycle display, SW4 = reset
//   7-seg shows time in hex (centiseconds)
//   UART TX logs lap times to PC terminal
//
// Architecture:
//   Control FSM → ms counter → lap register → display mux → UART logger
module top_stopwatch (
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
    // ── Heartbeat ───────────────────────────────────────────────────────
    reg [23:0] r_heartbeat;
    always @(posedge i_clk)
        r_heartbeat <= r_heartbeat + 1;

    // ── Debounce + edge detect ──────────────────────────────────────────
    wire sw1, sw2, sw3, sw4;
    debounce db1 (.i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(sw1));
    debounce db2 (.i_clk(i_clk), .i_bouncy(i_switch2), .o_clean(sw2));
    debounce db3 (.i_clk(i_clk), .i_bouncy(i_switch3), .o_clean(sw3));
    debounce db4 (.i_clk(i_clk), .i_bouncy(i_switch4), .o_clean(sw4));

    // TODO: Edge detectors
    // ---- YOUR CODE HERE ----

    // ── TODO: 10 ms tick generator (25_000_000 / 100 = 250_000) ────────
    // ---- YOUR CODE HERE ----

    // ── TODO: Running counter (centiseconds, 8-bit = 0–255) ────────────
    // ---- YOUR CODE HERE ----
    reg [7:0] r_count;

    // ── TODO: Lap register ──────────────────────────────────────────────
    // ---- YOUR CODE HERE ----
    reg [7:0] r_lap;

    // ── TODO: Control FSM (STOPPED / RUNNING / LAP_DISPLAY) ─────────────
    // ---- YOUR CODE HERE ----

    // ── TODO: UART lap logger ───────────────────────────────────────────
    // On each lap capture, transmit the lap time as 2 hex ASCII chars
    // ---- YOUR CODE HERE ----

    // ── 7-Segment Display ───────────────────────────────────────────────
    reg [3:0] r_disp1, r_disp2;
    wire [6:0] w_seg1, w_seg2;
    hex_to_7seg seg1 (.i_hex(r_disp1), .o_seg(w_seg1));
    hex_to_7seg seg2 (.i_hex(r_disp2), .o_seg(w_seg2));

    // ── Outputs ─────────────────────────────────────────────────────────
    assign o_led1 = 1'b0;  // TODO: running indicator
    assign o_led2 = 1'b0;  // TODO: lap captured
    assign o_led3 = 1'b0;
    assign o_led4 = r_heartbeat[23];
    assign o_uart_tx = 1'b1;

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = w_seg1;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = w_seg2;
endmodule
