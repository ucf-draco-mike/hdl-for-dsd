//-----------------------------------------------------------------------------
// File:    day02_ex03_hex_to_7seg.v
// Course:  Accelerated HDL for Digital System Design — Day 2
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   Hexadecimal to 7-segment decoder. Maps 4-bit input (0-F) to
//   active-low segment outputs {a,b,c,d,e,f,g} for Go Board display.
//   0 = segment ON, 1 = segment OFF.
//
// Build:
//   yosys -p "synth_ice40 -top hex_to_7seg -json day02_ex03_hex_to_7seg.json" day02_ex03_hex_to_7seg.v
//-----------------------------------------------------------------------------
module hex_to_7seg (
    input  wire [3:0] i_hex,
    output reg  [6:0] o_seg   // {a,b,c,d,e,f,g} active low
);
    always @(*) begin
        case (i_hex)       //     abcdefg
            4'h0: o_seg = 7'b0000001;
            4'h1: o_seg = 7'b1001111;
            4'h2: o_seg = 7'b0010010;
            4'h3: o_seg = 7'b0000110;
            4'h4: o_seg = 7'b1001100;
            4'h5: o_seg = 7'b0100100;
            4'h6: o_seg = 7'b0100000;
            4'h7: o_seg = 7'b0001111;
            4'h8: o_seg = 7'b0000000;
            4'h9: o_seg = 7'b0000100;
            4'hA: o_seg = 7'b0001000;
            4'hB: o_seg = 7'b1100000;
            4'hC: o_seg = 7'b0110001;
            4'hD: o_seg = 7'b1000010;
            4'hE: o_seg = 7'b0110000;
            4'hF: o_seg = 7'b0111000;
            default: o_seg = 7'b1111111;
        endcase
    end
endmodule
