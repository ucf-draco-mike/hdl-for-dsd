// =============================================================================
// hex_to_7seg.v — Hexadecimal to 7-Segment Decoder
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Description:
//   Maps a 4-bit hexadecimal value (0x0-0xF) to the 7 segment enable signals
//   for the Nandland Go Board's common-anode displays.
//   Segment encoding: o_seg[6:0] = {a, b, c, d, e, f, g}
//   ACTIVE LOW: o_seg bit = 0 means segment is ON.
//
// Ports:
//   i_hex   [3:0]  4-bit hex digit input
//   o_seg   [6:0]  {a,b,c,d,e,f,g} active-low segment outputs
//
// Introduced: Day 2
// =============================================================================
module hex_to_7seg (
    input  wire [3:0] i_hex,
    output reg  [6:0] o_seg   // {a,b,c,d,e,f,g} active low
);
    always @(*) begin
        case (i_hex)
            4'h0: o_seg = 7'b0000001;  4'h1: o_seg = 7'b1001111;
            4'h2: o_seg = 7'b0010010;  4'h3: o_seg = 7'b0000110;
            4'h4: o_seg = 7'b1001100;  4'h5: o_seg = 7'b0100100;
            4'h6: o_seg = 7'b0100000;  4'h7: o_seg = 7'b0001111;
            4'h8: o_seg = 7'b0000000;  4'h9: o_seg = 7'b0000100;
            4'hA: o_seg = 7'b0001000;  4'hB: o_seg = 7'b1100000;
            4'hC: o_seg = 7'b0110001;  4'hD: o_seg = 7'b1000010;
            4'hE: o_seg = 7'b0110000;  4'hF: o_seg = 7'b0111000;
        endcase
    end
endmodule
