// =============================================================================
// Exercise 4 SOLUTION: Hex-to-7-Segment Decoder
// Day 2 · Combinational Building Blocks
// =============================================================================

module hex_to_7seg (
    input  wire [3:0] i_hex,
    output wire [6:0] o_seg   // {a,b,c,d,e,f,g} active low
);

    assign o_seg = (i_hex == 4'h0) ? 7'b0000001 :
                   (i_hex == 4'h1) ? 7'b1001111 :
                   (i_hex == 4'h2) ? 7'b0010010 :
                   (i_hex == 4'h3) ? 7'b0000110 :
                   (i_hex == 4'h4) ? 7'b1001100 :
                   (i_hex == 4'h5) ? 7'b0100100 :
                   (i_hex == 4'h6) ? 7'b0100000 :
                   (i_hex == 4'h7) ? 7'b0001111 :
                   (i_hex == 4'h8) ? 7'b0000000 :
                   (i_hex == 4'h9) ? 7'b0000100 :
                   (i_hex == 4'hA) ? 7'b0001000 :
                   (i_hex == 4'hB) ? 7'b1100000 :
                   (i_hex == 4'hC) ? 7'b0110001 :
                   (i_hex == 4'hD) ? 7'b1000010 :
                   (i_hex == 4'hE) ? 7'b0110000 :
                                     7'b0111000 ;

endmodule
