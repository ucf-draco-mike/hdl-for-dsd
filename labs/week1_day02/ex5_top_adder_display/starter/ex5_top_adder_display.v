// =============================================================================
// Exercise 5 (Stretch): Adder + 7-Seg Display Integration
// Day 2 · Combinational Building Blocks
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Combine the adder with the 7-seg decoder.
// sw1,sw2 = 2-bit a    sw3,sw4 = 2-bit b
// 7-seg shows the sum as a hex digit
// =============================================================================

module top_adder_display (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,          // carry out
    output wire o_segment1_a,
    output wire o_segment1_b,
    output wire o_segment1_c,
    output wire o_segment1_d,
    output wire o_segment1_e,
    output wire o_segment1_f,
    output wire o_segment1_g
);

    // TODO: 
    // 1. Invert switches, create 4-bit padded inputs
    // 2. Instantiate ripple_adder_4bit
    // 3. Instantiate hex_to_7seg with the sum
    // 4. Map segment outputs to pins
    // 5. Drive o_led1 from carry (active-high)

endmodule
