// =============================================================================
// Exercise 4: Hex-to-7-Segment Decoder
// Day 2 · Combinational Building Blocks
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Input:  4-bit hex value (0-F)
// Output: 7 segment signals (active low for Go Board)
//         o_seg = {a, b, c, d, e, f, g}
//
// Segment layout:
//     ─a─
//    |   |
//    f   b
//    |   |
//     ─g─
//    |   |
//    e   c
//    |   |
//     ─d─
//
// Active low: 0 = segment on, 1 = segment off
// =============================================================================

module hex_to_7seg (
    input  wire [3:0] i_hex,
    output wire [6:0] o_seg   // {a, b, c, d, e, f, g} — active low
);

    // TODO: Implement using nested conditional operator
    // Each 7-bit pattern encodes which segments are on (0) or off (1)
    //
    //                              abcdefg
    // 0: segments a,b,c,d,e,f on = 0000001
    // 1: segments b,c on         = 1001111
    // 2: segments a,b,d,e,g on   = 0010010
    // ... complete all 16 values (0-F)

    assign o_seg = (i_hex == 4'h0) ? 7'b0000001 :  // 0
                   (i_hex == 4'h1) ? 7'b1001111 :  // 1
                   // TODO: Complete entries for 2-E
                                     7'b0111000 ;  // F (default/last)

endmodule
