// Exercise 3: Hex digit to 7-segment decoder
// Go Board has active-high segments: 1 = segment ON
// Segment mapping: {a,b,c,d,e,f,g} = o_seg[6:0]
//      ─a─
//     |   |
//     f   b
//     |   |
//      ─g─
//     |   |
//     e   c
//     |   |
//      ─d─
module hex_to_7seg (
    input  wire [3:0] i_hex,
    output reg  [6:0] o_seg   // {a,b,c,d,e,f,g}
);
    // TODO: Implement using case statement
    always @(*) begin
        case (i_hex)
            4'h0: o_seg = 7'b1111110;  // 0
            4'h1: o_seg = 7'b0110000;  // 1
            4'h2: o_seg = 7'b1101101;  // 2
            4'h3: o_seg = 7'b1111001;  // 3
            4'h4: o_seg = 7'b0110011;  // 4
            4'h5: o_seg = 7'b1011011;  // 5
            4'h6: o_seg = 7'b1011111;  // 6
            4'h7: o_seg = 7'b1110000;  // 7
            4'h8: o_seg = 7'b1111111;  // 8
            4'h9: o_seg = 7'b1111011;  // 9
            4'hA: o_seg = 7'b1110111;  // A
            4'hB: o_seg = 7'b0011111;  // b
            4'hC: o_seg = 7'b1001110;  // C
            4'hD: o_seg = 7'b0111101;  // d
            4'hE: o_seg = 7'b1001111;  // E
            4'hF: o_seg = 7'b1000111;  // F
            default: o_seg = 7'b0000000;
        endcase
    end
endmodule
