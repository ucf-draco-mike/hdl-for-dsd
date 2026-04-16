//-----------------------------------------------------------------------------
// File:    day01_ex02_button_logic.v
// Course:  Accelerated HDL for Digital System Design — Day 1
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   Demonstrates that Verilog describes concurrent hardware.
//   All four assign statements create four independent logic gates.
//   They ALL operate simultaneously — the order of the assign
//   statements does NOT matter.
//
//   Go Board mapping:
//     i_sw[0] = Switch 1 (active-high)   o_led[0] = LED 1
//     i_sw[1] = Switch 2 (active-high)   o_led[1] = LED 2
//     i_sw[2] = Switch 3 (active-high)   o_led[2] = LED 3
//     i_sw[3] = Switch 4 (active-high)   o_led[3] = LED 4
//
// Build & program:
//   yosys -p "synth_ice40 -top button_logic -json day01_ex02_button_logic.json" day01_ex02_button_logic.v
//   nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf \
//                  --json day01_ex02_button_logic.json --asc day01_ex02_button_logic.asc
//   icepack day01_ex02_button_logic.asc day01_ex02_button_logic.bin
//   iceprog day01_ex02_button_logic.bin
//-----------------------------------------------------------------------------

module button_logic (
    input  wire [3:0] i_sw,    // 4 push-button switches
    output wire [3:0] o_led    // 4 LEDs
);

    // Each assign creates one logic gate.
    // All four gates exist simultaneously in hardware.
    // Rearranging these lines produces IDENTICAL hardware.

    assign o_led[0] = i_sw[0];             // Direct: LED mirrors switch
    assign o_led[1] = ~i_sw[1];            // NOT:    LED is inverted switch
    assign o_led[2] = i_sw[0] & i_sw[1];   // AND:    LED on when BOTH pressed
    assign o_led[3] = i_sw[2] ^ i_sw[3];   // XOR:    LED on when exactly one pressed

    // Try it: press buttons in different combinations.
    // Each LED responds independently — that's parallelism.

endmodule
