// =============================================================================
// Exercise 1: Vector Operations Warm-Up
// Day 2 · Combinational Building Blocks
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Use the 4 switches as a 4-bit input, display results on LEDs.
//
// LED1 = OR  reduction (any switch pressed)
// LED2 = AND reduction (all switches pressed)
// LED3 = XOR reduction (odd parity — odd number pressed)
// LED4 = MSB of the 4-bit value (switch1)
// =============================================================================

module vector_ops (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4
);

    // Collect switches into a vector and make active-high
    // i_switch1 is MSB (bit 3), i_switch4 is LSB (bit 0)
    wire [3:0] w_sw;
    assign w_sw = {i_switch1, i_switch2, i_switch3, i_switch4};

    // TODO: Implement the four LED assignments
    // Remember: LEDs are active-high on the Go Board
    // Use the ~() inversion-at-output pattern

    // LED1: OR reduction — any switch pressed?
    // Hint: |w_sw gives OR reduction
    assign o_led1 = 1'b0;  // TODO: replace

    // LED2: AND reduction — all switches pressed?
    // Hint: &w_sw gives AND reduction
    assign o_led2 = 1'b0;  // TODO: replace

    // LED3: XOR reduction — odd number of switches pressed?
    // Hint: ^w_sw gives XOR reduction
    assign o_led3 = 1'b0;  // TODO: replace

    // LED4: MSB (switch1 state)
    assign o_led4 = 1'b0;  // TODO: replace

endmodule
