// top_tone.v — Music / Tone Generator Project Skeleton
// Generates square-wave tones via a PMOD pin (connect speaker/buzzer)
// Plays melodies stored in a ROM or programmed via switches
//
// Architecture:
//   Note ROM → Frequency Divider → PWM/Square wave → PMOD output
//   Sequencer FSM steps through ROM at tempo rate
//   Switches: SW1 = play/pause, SW2 = restart, SW3/SW4 = tempo
module top_tone (
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
    // PMOD pin 1 — audio output
    // (directly drives a small speaker or piezo buzzer via resistor)
    reg r_audio_out;

    // ────────────────────────────────────────────
    // Heartbeat
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
    // Note Frequency Table (ROM)
    // ────────────────────────────────────────────
    // Half-period in clock cycles for each note at 25 MHz
    // half_period = 25_000_000 / (2 * frequency)
    //
    // TODO: Expand this table with more notes
    // ---- YOUR CODE HERE ----
    function [15:0] note_half_period;
        input [3:0] note_idx;
        case (note_idx)
            4'd0:  note_half_period = 16'd0;      // REST (silence)
            4'd1:  note_half_period = 16'd47778;   // C4  (261.63 Hz)
            4'd2:  note_half_period = 16'd42566;   // D4  (293.66 Hz)
            4'd3:  note_half_period = 16'd37922;   // E4  (329.63 Hz)
            4'd4:  note_half_period = 16'd35793;   // F4  (349.23 Hz)
            4'd5:  note_half_period = 16'd31888;   // G4  (392.00 Hz)
            4'd6:  note_half_period = 16'd28409;   // A4  (440.00 Hz)
            4'd7:  note_half_period = 16'd25310;   // B4  (493.88 Hz)
            4'd8:  note_half_period = 16'd23889;   // C5  (523.25 Hz)
            default: note_half_period = 16'd0;     // REST
        endcase
    endfunction

    // ────────────────────────────────────────────
    // Melody ROM — sequence of note indices
    // ────────────────────────────────────────────
    // TODO: Store a melody as a sequence of note indices
    //       Each entry = {note_idx[3:0], duration[3:0]}
    //       Duration in units of tempo ticks
    //
    // Example: "Twinkle Twinkle" opening = C C G G A A G
    //
    // ---- YOUR CODE HERE ----
    reg [7:0] r_melody [0:15];
    initial begin
        r_melody[0]  = {4'd1, 4'd2};  // C4, 2 beats
        r_melody[1]  = {4'd1, 4'd2};  // C4, 2 beats
        r_melody[2]  = {4'd5, 4'd2};  // G4, 2 beats
        r_melody[3]  = {4'd5, 4'd2};  // G4, 2 beats
        r_melody[4]  = {4'd6, 4'd2};  // A4, 2 beats
        r_melody[5]  = {4'd6, 4'd2};  // A4, 2 beats
        r_melody[6]  = {4'd5, 4'd4};  // G4, 4 beats (half note)
        r_melody[7]  = {4'd0, 4'd1};  // REST, 1 beat
        r_melody[8]  = {4'd0, 4'd0};  // END marker
    end

    // ────────────────────────────────────────────
    // Tone Generator — frequency divider for square wave
    // ────────────────────────────────────────────
    // TODO: Count up to note_half_period, toggle r_audio_out
    //       When note = REST (half_period = 0), output stays low
    //
    // ---- YOUR CODE HERE ----

    // ────────────────────────────────────────────
    // Sequencer FSM
    // ────────────────────────────────────────────
    // TODO: Step through melody ROM at tempo rate
    //       Tempo tick = ~4 Hz default (adjustable with SW3/SW4)
    //       On each tempo tick, decrement current note duration
    //       When duration reaches 0, advance to next note
    //       At END marker, loop or stop
    //
    // ---- YOUR CODE HERE ----
    reg [3:0] r_mel_addr;
    reg r_playing;

    // ────────────────────────────────────────────
    // Display: note index on seg1, melody address on seg2
    // ────────────────────────────────────────────
    wire [6:0] w_seg1, w_seg2;
    hex_to_7seg seg1 (.i_hex(r_melody[r_mel_addr][7:4]), .o_seg(w_seg1));
    hex_to_7seg seg2 (.i_hex(r_mel_addr),                .o_seg(w_seg2));

    // ────────────────────────────────────────────
    // Outputs
    // ────────────────────────────────────────────
    assign o_led1 = r_playing;
    assign o_led2 = r_audio_out;       // Visual feedback of tone
    assign o_led3 = 1'b0;
    assign o_led4 = r_heartbeat[23];

    assign o_uart_tx = 1'b1;

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = w_seg1;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = w_seg2;
endmodule
