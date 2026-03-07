// =============================================================================
// Exercise 3, Part C: Top Module — Adder on Go Board
// Day 2 · Combinational Building Blocks
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// sw1,sw2 = 2-bit input a   sw3,sw4 = 2-bit input b
// LEDs show the 3-bit sum (2 bits + carry)
// =============================================================================

module top_adder (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,     // sum[2] (carry into bit 2)
    output wire o_led2,     // sum[1]
    output wire o_led3,     // sum[0]
    output wire o_led4      // carry out
);

    // TODO: Invert switches, pad to 4 bits, instantiate adder, drive LEDs
    // Hint: wire [3:0] w_a = {2'b00, i_switch1, i_switch2};

endmodule
