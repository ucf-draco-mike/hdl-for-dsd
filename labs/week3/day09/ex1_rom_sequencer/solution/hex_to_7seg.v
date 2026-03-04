// hex_to_7seg.v — 4-bit hex to 7-segment decoder (active-low for Go Board)
module hex_to_7seg (
    input  wire [3:0] i_hex,
    output reg  [6:0] o_seg   // {a, b, c, d, e, f, g}
);
    reg [6:0] seg_active;
    always @(*) begin
        case (i_hex)
            4'h0: seg_active = 7'b1111110;
            4'h1: seg_active = 7'b0110000;
            4'h2: seg_active = 7'b1101101;
            4'h3: seg_active = 7'b1111001;
            4'h4: seg_active = 7'b0110011;
            4'h5: seg_active = 7'b1011011;
            4'h6: seg_active = 7'b1011111;
            4'h7: seg_active = 7'b1110000;
            4'h8: seg_active = 7'b1111111;
            4'h9: seg_active = 7'b1111011;
            4'hA: seg_active = 7'b1110111;
            4'hB: seg_active = 7'b0011111;
            4'hC: seg_active = 7'b1001110;
            4'hD: seg_active = 7'b0111101;
            4'hE: seg_active = 7'b1001111;
            4'hF: seg_active = 7'b1000111;
            default: seg_active = 7'b0000000;
        endcase
        o_seg = ~seg_active;
    end
endmodule
