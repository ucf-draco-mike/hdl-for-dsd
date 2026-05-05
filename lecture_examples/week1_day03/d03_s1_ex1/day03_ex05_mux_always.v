//-----------------------------------------------------------------------------
// File:    day03_ex05_mux_always.v
// Course:  Accelerated HDL for Digital System Design — Day 3, Topic 3.1
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   4:1 multiplexer written with `always @(*)` + `case`.
//   Functionally identical to day03_ex04_mux_assign.v — `synth_ice40 stat`
//   reports the same SB_LUT4 / SB_DFF counts. Same hardware, different RTL
//   style.
//-----------------------------------------------------------------------------
module mux_always (
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire [3:0] i_c,
    input  wire [3:0] i_d,
    input  wire [1:0] i_sel,
    output reg  [3:0] o_y
);
    always @(*) begin
        o_y = 4'b0000;          // default at top — latch-free habit
        case (i_sel)
            2'b00: o_y = i_a;
            2'b01: o_y = i_b;
            2'b10: o_y = i_c;
            2'b11: o_y = i_d;
        endcase
    end
endmodule
