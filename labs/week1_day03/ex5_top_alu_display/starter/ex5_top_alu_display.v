// =============================================================================
// Exercise 5 (Stretch): ALU + 7-Seg Integration
// Day 3 · Procedural Combinational Logic
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Hardcoded operands: a=7, b=3. Switches select opcode.
// Display ALU result on 7-seg, flags on LEDs.
// =============================================================================

module top_alu_display (
    input  wire i_switch1,   // opcode[1]
    input  wire i_switch2,   // opcode[0]
    output wire o_led1,      // carry
    output wire o_led2,      // zero
    output wire o_segment1_a,
    output wire o_segment1_b,
    output wire o_segment1_c,
    output wire o_segment1_d,
    output wire o_segment1_e,
    output wire o_segment1_f,
    output wire o_segment1_g
);

    // TODO:
    // 1. Wire opcode from switches
    // 2. Hardcode i_a = 4'd7, i_b = 4'd3
    // 3. Instantiate alu_4bit
    // 4. Instantiate hex_to_7seg (from Day 2) with the ALU result
    // 5. Drive LEDs from carry and zero flags
    // 6. Map segment outputs to pins

endmodule
