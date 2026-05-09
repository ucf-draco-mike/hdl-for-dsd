//-----------------------------------------------------------------------------
// File:    day04_ex03_led_blink_rates.v
// Course:  Accelerated HDL for Digital System Design — Day 4
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   One LED blinks 1 second ON, 1 second OFF from a shared 25 MHz clock
//   (toggle every 1 s, full ON+OFF period 2 s). The remaining three LEDs
//   are tied OFF so the board only shows the single blinker.
//
//   This is the simplest live-hardware preview for the Clocks & Edges
//   segment (d04_s1): one counter, one terminal value, one toggle.
//
// Build:
//   yosys -p "synth_ice40 -top led_blink_rates -json led_blink_rates.json" \
//         day04_ex03_led_blink_rates.v
//   nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf \
//                 --json led_blink_rates.json --asc led_blink_rates.asc
//   icepack led_blink_rates.asc led_blink_rates.bin
//   iceprog led_blink_rates.bin
//-----------------------------------------------------------------------------
module led_blink_rates (
    input  wire i_clk,       // 25 MHz crystal
    output wire o_led1,      // toggles every 1 s (1 s ON, 1 s OFF)
    output wire o_led2,      // tied OFF
    output wire o_led3,      // tied OFF
    output wire o_led4       // tied OFF
);
    // 25 MHz clock; the counter rolls over at CLK_HZ - 1, giving a 1 s
    // toggle period (2 s full blink).
    localparam integer CLK_HZ = 25_000_000;
    localparam integer T      = CLK_HZ - 1;       // 24,999,999

    // 25 bits is the smallest width that fits T (2^25 = 33,554,432).
    reg [24:0] r_count = 25'd0;
    reg        r_led   = 1'b0;

    always @(posedge i_clk) begin
        if (r_count == T[24:0]) begin
            r_count <= 25'd0;
            r_led   <= ~r_led;
        end else begin
            r_count <= r_count + 1'b1;
        end
    end

    assign o_led1 = r_led;
    assign o_led2 = 1'b0;
    assign o_led3 = 1'b0;
    assign o_led4 = 1'b0;
endmodule
