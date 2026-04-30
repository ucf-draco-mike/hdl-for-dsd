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
//   Go Board mapping (matches go_board.pcf):
//     i_switch1 = Switch 1 (active-high)   o_led1 = LED 1
//     i_switch2 = Switch 2 (active-high)   o_led2 = LED 2
//     i_switch3 = Switch 3 (active-high)   o_led3 = LED 3
//     i_switch4 = Switch 4 (active-high)   o_led4 = LED 4
//
// Build & program:
//   yosys -p "synth_ice40 -top button_logic -json day01_ex02_button_logic.json" day01_ex02_button_logic.v
//   nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf \
//                  --json day01_ex02_button_logic.json --asc day01_ex02_button_logic.asc
//   icepack day01_ex02_button_logic.asc day01_ex02_button_logic.bin
//   iceprog day01_ex02_button_logic.bin
//-----------------------------------------------------------------------------

module button_logic (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // Each assign creates one logic gate.
    // All four gates exist simultaneously in hardware.
    // Rearranging these lines produces IDENTICAL hardware.

    assign o_led1 = i_switch1;                 // Direct: LED mirrors switch
    assign o_led2 = ~i_switch2;                // NOT:    LED is inverted switch
    assign o_led3 = i_switch1 & i_switch2;     // AND:    LED on when BOTH pressed
    assign o_led4 = i_switch3 ^ i_switch4;     // XOR:    LED on when exactly one pressed

    // Try it: press buttons in different combinations.
    // Each LED responds independently — that's parallelism.

endmodule
