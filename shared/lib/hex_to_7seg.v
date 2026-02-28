// Hex-to-7-segment decoder — Go Board compatible
// Built: Day 2 | Tested: Day 6
module hex_to_7seg (
    input  wire [3:0] i_hex,
    output reg  [6:0] o_seg
);
    always @(*) begin
        case (i_hex)
            4'h0: o_seg = 7'b1111110;
            4'h1: o_seg = 7'b0110000;
            4'h2: o_seg = 7'b1101101;
            4'h3: o_seg = 7'b1111001;
            4'h4: o_seg = 7'b0110011;
            4'h5: o_seg = 7'b1011011;
            4'h6: o_seg = 7'b1011111;
            4'h7: o_seg = 7'b1110000;
            4'h8: o_seg = 7'b1111111;
            4'h9: o_seg = 7'b1111011;
            4'hA: o_seg = 7'b1110111;
            4'hB: o_seg = 7'b0011111;
            4'hC: o_seg = 7'b1001110;
            4'hD: o_seg = 7'b0111101;
            4'hE: o_seg = 7'b1001111;
            4'hF: o_seg = 7'b1000111;
            default: o_seg = 7'b0000000;
        endcase
    end
endmodule
