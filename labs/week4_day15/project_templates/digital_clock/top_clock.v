// top_clock.v — Digital Clock / Timer Project Skeleton
// Displays MM:SS on the two 7-segment displays (ones of minutes : tens of seconds)
// Switch1 = start/stop, Switch2 = reset, Switch3/4 = set time
//
// Architecture:
//   25 MHz clock → 1 Hz prescaler → seconds counter → display driver
//   Switches → debounce → edge detect → control FSM
module top_clock (
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
    // Debounce all switches
    // ────────────────────────────────────────────
    wire sw1, sw2, sw3, sw4;
    debounce db1 (.i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(sw1));
    debounce db2 (.i_clk(i_clk), .i_bouncy(i_switch2), .o_clean(sw2));
    debounce db3 (.i_clk(i_clk), .i_bouncy(i_switch3), .o_clean(sw3));
    debounce db4 (.i_clk(i_clk), .i_bouncy(i_switch4), .o_clean(sw4));

    // ────────────────────────────────────────────
    // 1 Hz Prescaler
    // ────────────────────────────────────────────
    // TODO: Create a counter that produces a single-cycle tick every second
    //       25_000_000 clocks = 1 second
    //
    // ---- YOUR CODE HERE ----
    reg r_one_hz_tick;

    // ────────────────────────────────────────────
    // Time Counter
    // ────────────────────────────────────────────
    // TODO: Maintain minutes (0–9) and seconds (0–59) counters
    //       Increment on r_one_hz_tick when running
    //       sw1 rising edge: toggle run/pause
    //       sw2 rising edge: reset to 00:00
    //       sw3 rising edge: increment minutes (when paused)
    //       sw4 rising edge: increment seconds (when paused)
    //
    // ---- YOUR CODE HERE ----
    reg [3:0] r_minutes;
    reg [5:0] r_seconds;
    reg r_running;

    // ────────────────────────────────────────────
    // Display: show minutes on seg1, tens-of-seconds on seg2
    // ────────────────────────────────────────────
    wire [6:0] w_seg1, w_seg2;
    hex_to_7seg seg1 (.i_hex(r_minutes),          .o_seg(w_seg1));
    hex_to_7seg seg2 (.i_hex(r_seconds[5:2]),      .o_seg(w_seg2));
    // NOTE: The above is a placeholder. You may want to display
    //       seconds as two digits using multiplexing or a different mapping.

    // ────────────────────────────────────────────
    // Outputs
    // ────────────────────────────────────────────
    assign o_led1 = r_running;         // LED1 = running indicator
    assign o_led2 = 1'b0;
    assign o_led3 = 1'b0;
    assign o_led4 = r_heartbeat[23];

    assign o_uart_tx = 1'b1;            // UART unused — idle high

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = w_seg1;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = w_seg2;
endmodule
