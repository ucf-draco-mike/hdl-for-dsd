//-----------------------------------------------------------------------------
// File:    day01_ex01_led_driver.v
// Course:  Accelerated HDL for Digital System Design — Day 1
// Board:   Nandland Go Board (Lattice iCE40 HX1K, VQ100)
//
// Description:
//   Simplest possible Verilog module. Connects an input switch directly
//   to an output LED using continuous assignment (assign).
//
//   This is your "Hello World" — a permanent wire from switch to LED.
//   When the switch is pressed (active-high on Go Board), the LED lights.
//
// Build & program:
//   yosys -p "synth_ice40 -top led_driver -json day01_ex01_led_driver.json" day01_ex01_led_driver.v
//   nextpnr-ice40 --hx1k --package vq100 --pcf go_board.pcf \
//                  --json day01_ex01_led_driver.json --asc day01_ex01_led_driver.asc
//   icepack day01_ex01_led_driver.asc day01_ex01_led_driver.bin
//   iceprog day01_ex01_led_driver.bin
//-----------------------------------------------------------------------------

module led_driver (
    input  wire i_switch1,   // active-high pushbutton (directly from pin)
    output wire o_led1       // LED output (active high on Go Board)
);

    // Continuous assignment: o_led1 is ALWAYS connected to i_switch1.
    // This is not a one-time computation — it's a permanent wire.
    // Changing i_switch1 instantly changes o_led1 (after propagation delay).
    assign o_led1 = i_switch1;

endmodule
