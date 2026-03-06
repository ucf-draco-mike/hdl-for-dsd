// =============================================================================
// top_lab_instrument.v — Week 2 Capstone: Digital Lab Instrument (Starter)
// Day 8, Exercise 3
// =============================================================================

module top_lab_instrument (
    input  wire i_clk,
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1, o_led2, o_led3, o_led4,
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g,
    output wire o_segment2_a, o_segment2_b, o_segment2_c,
    output wire o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g
);

    // --- Input Processing ---
    wire [3:0] w_buttons, w_press;

    go_board_input #(
        .N_BUTTONS(4),
        .CLK_FREQ(25_000_000),
        .DEBOUNCE_MS(10)
    ) inputs (
        .i_clk(i_clk),
        .i_buttons({i_switch1, i_switch2, i_switch3, i_switch4}),
        .o_buttons(w_buttons),
        .o_press_edge(w_press),
        .o_release_edge()        // unused
    );

    wire w_reset  = w_buttons[3];   // sw1 held = reset
    wire w_inc    = w_press[2];     // sw2 press = increment
    wire w_load   = w_press[1];     // sw3 press = load from LFSR
    wire w_step   = w_press[0];     // sw4 press = step LFSR

    // --- TODO: LFSR ---
    // Instantiate lfsr_8bit with reset and step enable

    // --- TODO: Main Counter (8-bit, loadable) ---
    // reg [7:0] r_counter;
    // always @(posedge i_clk) begin
    //   if (w_reset)     → clear to 0
    //   else if (w_load) → load LFSR value
    //   else if (w_inc)  → increment
    // end

    // --- TODO: Display 1 — lower nibble of r_counter ---
    // hex_to_7seg disp1 (...)

    // --- TODO: Display 2 — upper nibble of r_counter ---
    // hex_to_7seg disp2 (...)

    // --- TODO: LEDs — heartbeat at different rates ---
    // reg [24:0] r_hb;
    // always @(posedge i_clk) r_hb <= r_hb + 1;
    // assign o_led1 = r_hb[24]; ...

endmodule
