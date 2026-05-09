//-----------------------------------------------------------------------------
// File:    day04_ex03_led_blink_rates.v
// Course:  Accelerated HDL for Digital System Design — Day 4
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   Four LEDs blinking at four different rates from one shared 25 MHz clock.
//   Each LED toggles every N seconds, giving a full ON+OFF blink period of
//   2*N seconds:
//       o_led1: toggle every 1 s   (period 2 s)
//       o_led2: toggle every 2 s   (period 4 s)
//       o_led3: toggle every 3 s   (period 6 s)
//       o_led4: toggle every 4 s   (period 8 s)
//
//   Each rate has its own counter that rolls over at CLK_HZ*N - 1 cycles
//   and toggles the corresponding LED on rollover. This is the canonical
//   "different terminal counts produce different output rates" demo for
//   the Clocks & Edges segment (d04_s1).
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
    output wire o_led1,      // toggles every 1 s
    output wire o_led2,      // toggles every 2 s
    output wire o_led3,      // toggles every 3 s
    output wire o_led4       // toggles every 4 s
);
    // 25 MHz clock; the counters roll over at CLK_HZ*N - 1.
    localparam integer CLK_HZ = 25_000_000;
    localparam integer T1     = CLK_HZ * 1 - 1;   //  24,999,999
    localparam integer T2     = CLK_HZ * 2 - 1;   //  49,999,999
    localparam integer T3     = CLK_HZ * 3 - 1;   //  74,999,999
    localparam integer T4     = CLK_HZ * 4 - 1;   //  99,999,999

    // 27 bits is the smallest width that fits T4 (2^27 = 134,217,728).
    reg [26:0] r_count1 = 27'd0;
    reg [26:0] r_count2 = 27'd0;
    reg [26:0] r_count3 = 27'd0;
    reg [26:0] r_count4 = 27'd0;

    reg r_led1 = 1'b0;
    reg r_led2 = 1'b0;
    reg r_led3 = 1'b0;
    reg r_led4 = 1'b0;

    always @(posedge i_clk) begin
        if (r_count1 == T1[26:0]) begin
            r_count1 <= 27'd0;
            r_led1   <= ~r_led1;
        end else begin
            r_count1 <= r_count1 + 1'b1;
        end

        if (r_count2 == T2[26:0]) begin
            r_count2 <= 27'd0;
            r_led2   <= ~r_led2;
        end else begin
            r_count2 <= r_count2 + 1'b1;
        end

        if (r_count3 == T3[26:0]) begin
            r_count3 <= 27'd0;
            r_led3   <= ~r_led3;
        end else begin
            r_count3 <= r_count3 + 1'b1;
        end

        if (r_count4 == T4[26:0]) begin
            r_count4 <= 27'd0;
            r_led4   <= ~r_led4;
        end else begin
            r_count4 <= r_count4 + 1'b1;
        end
    end

    assign o_led1 = r_led1;
    assign o_led2 = r_led2;
    assign o_led3 = r_led3;
    assign o_led4 = r_led4;
endmodule
