// top_pattern.v — LED Pattern Generator / Sequencer Project Skeleton
// Stores LED patterns in a small RAM, plays them in sequence on the 4 LEDs.
// Patterns can be programmed via UART or loaded from a ROM.
//
// Architecture:
//   Pattern RAM (32 entries × 4 bits) → Sequencer FSM → LED driver
//   UART RX → Write Controller → RAM write port
//   Switches: SW1 = play/pause, SW2 = step, SW3/SW4 = speed up/down
module top_pattern (
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
    // Heartbeat (on LED4 until pattern playback takes over)
    // ────────────────────────────────────────────
    reg [23:0] r_heartbeat;
    always @(posedge i_clk)
        r_heartbeat <= r_heartbeat + 1;

    // ────────────────────────────────────────────
    // Debounce
    // ────────────────────────────────────────────
    wire sw1, sw2, sw3, sw4;
    debounce db1 (.i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(sw1));
    debounce db2 (.i_clk(i_clk), .i_bouncy(i_switch2), .o_clean(sw2));
    debounce db3 (.i_clk(i_clk), .i_bouncy(i_switch3), .o_clean(sw3));
    debounce db4 (.i_clk(i_clk), .i_bouncy(i_switch4), .o_clean(sw4));

    // ────────────────────────────────────────────
    // Pattern RAM — 32 entries × 4 bits
    // ────────────────────────────────────────────
    // TODO: Implement a small dual-port or single-port RAM
    //       - Write port: UART controller or switch-based editor
    //       - Read port: sequencer reads current pattern
    //       - Initialize with a default pattern (e.g., walking LED)
    //
    // ---- YOUR CODE HERE ----
    reg [3:0] r_pattern_ram [0:31];
    reg [4:0] r_addr;

    initial begin
        // Default: walking LED pattern
        r_pattern_ram[0]  = 4'b0001;
        r_pattern_ram[1]  = 4'b0010;
        r_pattern_ram[2]  = 4'b0100;
        r_pattern_ram[3]  = 4'b1000;
        r_pattern_ram[4]  = 4'b0100;
        r_pattern_ram[5]  = 4'b0010;
        r_pattern_ram[6]  = 4'b0001;
        r_pattern_ram[7]  = 4'b0000;
    end

    // ────────────────────────────────────────────
    // Sequencer FSM
    // ────────────────────────────────────────────
    // TODO: Play through pattern RAM entries at adjustable speed
    //       SW1 rising edge: toggle play/pause
    //       SW2 rising edge: step to next entry (when paused)
    //       SW3 rising edge: increase speed
    //       SW4 rising edge: decrease speed
    //       Speed: prescaler from 1 Hz to 8 Hz (adjustable)
    //
    // ---- YOUR CODE HERE ----
    reg r_playing;
    reg [2:0] r_speed;       // 0–7, maps to prescaler value
    reg [3:0] r_led_pattern;

    // ────────────────────────────────────────────
    // 7-Segment: show current address on seg1, pattern on seg2
    // ────────────────────────────────────────────
    wire [6:0] w_seg1, w_seg2;
    hex_to_7seg seg1 (.i_hex(r_addr[3:0]),   .o_seg(w_seg1));
    hex_to_7seg seg2 (.i_hex(r_led_pattern),  .o_seg(w_seg2));

    // ────────────────────────────────────────────
    // Outputs
    // ────────────────────────────────────────────
    assign o_led1 = r_led_pattern[0];
    assign o_led2 = r_led_pattern[1];
    assign o_led3 = r_led_pattern[2];
    assign o_led4 = r_led_pattern[3];

    assign o_uart_tx = 1'b1;   // Stub — add echo or status reporting later

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = w_seg1;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = w_seg2;
endmodule
