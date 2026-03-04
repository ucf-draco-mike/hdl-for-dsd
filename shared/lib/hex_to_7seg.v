// =============================================================================
// hex_to_7seg.v — Hexadecimal to 7-Segment Decoder
// Accelerated HDL for Digital System Design · UCF · shared/lib
// =============================================================================
// Description:
//   Maps a 4-bit hexadecimal value (0x0–0xF) to the 7 segment enable signals
//   for the Nandland Go Board's common-anode displays.
//   Segment encoding: o_seg[6:0] = {g, f, e, d, c, b, a}
//   ACTIVE LOW: o_seg bit = 0 means segment is ON.
//
// Ports:
//   i_hex   [3:0]  4-bit hex digit input
//   o_seg   [6:0]  {g,f,e,d,c,b,a} active-low segment outputs
//
// Introduced: Day 2
// =============================================================================
module hex_to_7seg (
    input  wire [3:0] i_hex,
    output reg  [6:0] o_seg   // {g,f,e,d,c,b,a} active-low
);
    //  Segment layout:
    //   _
    //  |_|   a=top, b=top-right, c=bot-right
    //  |_|   d=bottom, e=bot-left, f=top-left, g=middle
    //
    // Active-high encoding, then invert for active-low board:
    //  Digit |  gfedcba  | hex
    //  ------+-----------+-----
    //    0   | 0111111   | 3F
    //    1   | 0000110   | 06
    //    2   | 1011011   | 5B
    //    3   | 1001111   | 4F
    //    4   | 1100110   | 66
    //    5   | 1101101   | 6D
    //    6   | 1111101   | 7D
    //    7   | 0000111   | 07
    //    8   | 1111111   | 7F
    //    9   | 1101111   | 6F
    //    A   | 1110111   | 77
    //    b   | 1111100   | 7C
    //    C   | 0111001   | 39
    //    d   | 1011110   | 5E
    //    E   | 1111001   | 79
    //    F   | 1110001   | 71

    always @(*) begin
        case (i_hex)
            4'h0: o_seg = ~7'h3F;  // 0
            4'h1: o_seg = ~7'h06;  // 1
            4'h2: o_seg = ~7'h5B;  // 2
            4'h3: o_seg = ~7'h4F;  // 3
            4'h4: o_seg = ~7'h66;  // 4
            4'h5: o_seg = ~7'h6D;  // 5
            4'h6: o_seg = ~7'h7D;  // 6
            4'h7: o_seg = ~7'h07;  // 7
            4'h8: o_seg = ~7'h7F;  // 8
            4'h9: o_seg = ~7'h6F;  // 9
            4'hA: o_seg = ~7'h77;  // A
            4'hB: o_seg = ~7'h7C;  // b
            4'hC: o_seg = ~7'h39;  // C
            4'hD: o_seg = ~7'h5E;  // d
            4'hE: o_seg = ~7'h79;  // E
            4'hF: o_seg = ~7'h71;  // F
            default: o_seg = 7'h7F; // all on (active-low: all off ... inverted below)
        endcase
    end
endmodule
