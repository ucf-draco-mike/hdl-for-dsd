// =============================================================================
// hex_to_7seg.v — Hexadecimal to 7-Segment Decoder
// Day 2: Combinational Building Blocks
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Description:
//   Converts a 4-bit hexadecimal value to 7-segment display signals.
//   Output is ACTIVE LOW (0 = segment ON) for the Nandland Go Board.
//
// Segment layout:
//      aaaa
//     f    b
//     f    b
//      gggg
//     e    c
//     e    c
//      dddd
//
// Output: o_seg = {a, b, c, d, e, f, g}
// =============================================================================

module hex_to_7seg (
    input  wire [3:0] i_hex,
    output reg  [6:0] o_seg       // {a, b, c, d, e, f, g} — active low
);

    always @(*) begin
        case (i_hex)              //     abcdefg
            4'h0: o_seg = 7'b0000001;  // 0
            4'h1: o_seg = 7'b1001111;  // 1
            4'h2: o_seg = 7'b0010010;  // 2
            4'h3: o_seg = 7'b0000110;  // 3
            4'h4: o_seg = 7'b1001100;  // 4
            4'h5: o_seg = 7'b0100100;  // 5
            4'h6: o_seg = 7'b0100000;  // 6
            4'h7: o_seg = 7'b0001111;  // 7
            4'h8: o_seg = 7'b0000000;  // 8
            4'h9: o_seg = 7'b0000100;  // 9
            4'hA: o_seg = 7'b0001000;  // A
            4'hB: o_seg = 7'b1100000;  // b
            4'hC: o_seg = 7'b0110001;  // C
            4'hD: o_seg = 7'b1000010;  // d
            4'hE: o_seg = 7'b0110000;  // E
            4'hF: o_seg = 7'b0111000;  // F
        endcase
    end

endmodule
