//-----------------------------------------------------------------------------
// File:    day04_ex02_led_blinker.v
// Course:  Accelerated HDL for Digital System Design — Day 4
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   Counter-based 1 Hz LED blinker. Divides 25 MHz clock to ~1 Hz
//   by counting to 12,500,000 per half-period, then toggling.
//   Also demonstrates MSB-tap trick for multi-speed blink.
//
// Build:
//   yosys -p "synth_ice40 -top led_blinker -json day04_ex02_led_blinker.json" day04_ex02_led_blinker.v
//   nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf \
//                 --json day04_ex02_led_blinker.json --asc day04_ex02_led_blinker.asc
//   icepack day04_ex02_led_blinker.asc day04_ex02_led_blinker.bin
//   iceprog day04_ex02_led_blinker.bin
//-----------------------------------------------------------------------------
module led_blinker (
    input  wire i_clk,       // 25 MHz
    output wire o_led1,      // ~1 Hz  (active-high)
    output wire o_led2,      // ~1.5 Hz (counter bit tap)
    output wire o_led3,      // ~3 Hz
    output wire o_led4       // ~6 Hz
);
    // --- 1 Hz toggle via explicit count ---
    reg [23:0] r_counter = 24'd0;
    reg        r_led     = 1'b0;

    always @(posedge i_clk) begin
        if (r_counter == 24'd12_499_999) begin
            r_counter <= 24'd0;
            r_led     <= ~r_led;
        end else begin
            r_counter <= r_counter + 1;
        end
    end

    assign o_led1 = r_led;   // active-high

    // --- Multi-speed via MSB taps (approximate) ---
    reg [23:0] r_free = 24'd0;
    always @(posedge i_clk)
        r_free <= r_free + 1;

    assign o_led2 = r_free[23];  // ~1.5 Hz
    assign o_led3 = r_free[22];  // ~3 Hz
    assign o_led4 = r_free[21];  // ~6 Hz
endmodule
