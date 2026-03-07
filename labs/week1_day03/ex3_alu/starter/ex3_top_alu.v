// =============================================================================
// Exercise 3: Top Module — ALU on Go Board
// Day 3 · Procedural Combinational Logic
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// With only 4 switches, we can't fully control a + b + opcode.
// Design choice: Hardcode i_a = 4'd7, use sw1-sw2 as opcode, sw3-sw4 as i_b[1:0]
// =============================================================================

module top_alu (
    input  wire i_switch1,   // opcode[1]
    input  wire i_switch2,   // opcode[0]
    input  wire i_switch3,   // b[1]
    input  wire i_switch4,   // b[0]
    output wire o_led1,      // carry
    output wire o_led2,      // zero flag
    output wire o_led3,      // result[1]
    output wire o_led4,      // result[0]
    output wire o_segment1_a,
    output wire o_segment1_b,
    output wire o_segment1_c,
    output wire o_segment1_d,
    output wire o_segment1_e,
    output wire o_segment1_f,
    output wire o_segment1_g
);

    wire [1:0] w_opcode = {i_switch1, i_switch2};
    wire [3:0] w_a = 4'd7;   // hardcoded operand a
    wire [3:0] w_b = {2'b00, i_switch3, i_switch4};

    wire [3:0] w_result;
    wire       w_zero, w_carry;

    // TODO: Instantiate alu_4bit
    // alu_4bit alu (
    //     .i_a(w_a), .i_b(w_b), .i_opcode(w_opcode),
    //     .o_result(w_result), .o_zero(w_zero), .o_carry(w_carry)
    // );

    // TODO: Drive LEDs (active-high) from carry, zero, result bits
    assign o_led1 = 1'b0;  // TODO: w_carry
    assign o_led2 = 1'b0;  // TODO: w_zero
    assign o_led3 = 1'b0;  // TODO: w_result[1]
    assign o_led4 = 1'b0;  // TODO: w_result[0]

    // TODO: Optionally drive 7-seg from result using hex_to_7seg from Day 2
    assign o_segment1_a = 1'b1;
    assign o_segment1_b = 1'b1;
    assign o_segment1_c = 1'b1;
    assign o_segment1_d = 1'b1;
    assign o_segment1_e = 1'b1;
    assign o_segment1_f = 1'b1;
    assign o_segment1_g = 1'b1;

endmodule
