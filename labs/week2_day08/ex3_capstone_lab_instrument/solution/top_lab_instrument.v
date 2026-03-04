// =============================================================================
// top_lab_instrument.v — Week 2 Capstone: Digital Lab Instrument (Solution)
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

    // --- Input Processing (matches curriculum spec: sw1=MSB, sw4=LSB) ---
    wire [3:0] w_buttons, w_press;

    go_board_input #(
        .N_BUTTONS(4), .CLK_FREQ(25_000_000), .DEBOUNCE_MS(10)
    ) inputs (
        .i_clk(i_clk),
        .i_buttons_n({i_switch1, i_switch2, i_switch3, i_switch4}),
        .o_buttons(w_buttons),
        .o_press_edge(w_press),
        .o_release_edge()
    );

    wire w_reset = w_buttons[3];   // sw1 held = reset
    wire w_inc   = w_press[2];     // sw2 press = increment
    wire w_load  = w_press[1];     // sw3 press = load from LFSR
    wire w_step  = w_press[0];     // sw4 press = step LFSR

    // --- LFSR ---
    wire [7:0] w_lfsr_val;

    lfsr_8bit lfsr (
        .i_clk(i_clk), .i_reset(w_reset),
        .i_enable(w_step), .o_lfsr(w_lfsr_val), .o_valid()
    );

    // --- Main Counter (8-bit, loadable) ---
    reg [7:0] r_counter;

    always @(posedge i_clk) begin
        if (w_reset)
            r_counter <= 8'd0;
        else if (w_load)
            r_counter <= w_lfsr_val;
        else if (w_inc)
            r_counter <= r_counter + 8'd1;
    end

    // --- Display 1: lower nibble ---
    wire [6:0] w_seg1;
    hex_to_7seg disp1 (.i_hex(r_counter[3:0]), .o_seg(w_seg1));
    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f,
            o_segment1_g} = w_seg1;

    // --- Display 2: upper nibble ---
    wire [6:0] w_seg2;
    hex_to_7seg disp2 (.i_hex(r_counter[7:4]), .o_seg(w_seg2));
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f,
            o_segment2_g} = w_seg2;

    // --- LEDs: heartbeat at different rates ---
    reg [24:0] r_hb;
    always @(posedge i_clk) r_hb <= r_hb + 1;

    assign o_led1 = ~r_hb[24];
    assign o_led2 = ~r_hb[23];
    assign o_led3 = ~r_hb[22];
    assign o_led4 = ~r_hb[21];

endmodule
