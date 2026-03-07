// =============================================================================
// Exercise 3: Logic Between Buttons and LEDs
// Day 1 · Welcome to Hardware Thinking
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Goal: Implement combinational logic between buttons and LEDs.
//       All assign statements execute CONCURRENTLY — this is hardware!
//
// Remember: Active high on Go Board
//   Button pressed = 1, LED on = 1
//   Think through the truth tables with active-high signals.
// =============================================================================

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

    // LED1: ON when BOTH switch1 AND switch2 are pressed
    //
    // Truth table (active high):
    //   sw1  sw2  | led1 (1=on)
    //    1    1   |  1    (both pressed -> LED on)
    //    1    0   |  0    (only sw1 -> LED off)
    //    0    1   |  0    (only sw2 -> LED off)
    //    0    0   |  0    (neither -> LED off)
    //
    // TODO: What single gate operation on active-high signals
    //       gives us AND-of-pressed behavior?
    assign o_led1 = 1'b0;  // TODO: replace with correct logic

    // LED2: ON when EITHER switch3 OR switch4 is pressed
    //
    // TODO: What gate gives us OR-of-pressed with active-high signals?
    assign o_led2 = 1'b0;  // TODO: replace with correct logic

    // LED3: ON when exactly ONE of switch1/switch2 is pressed (XOR)
    //
    // TODO: XOR of active-high inputs — direct for active-high output
    assign o_led3 = 1'b0;  // TODO: replace with correct logic

    // LED4: INVERTED behavior of switch1 (LED on when NOT pressed)
    //
    // TODO: Simply invert switch1
    assign o_led4 = 1'b0;  // TODO: replace with correct logic

endmodule
