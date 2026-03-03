// =============================================================================
// Exercise 3: Logic Between Buttons and LEDs
// Day 1 · Welcome to Hardware Thinking
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Goal: Implement combinational logic between buttons and LEDs.
//       All assign statements execute CONCURRENTLY — this is hardware!
//
// Remember: Active low on Go Board
//   Button pressed = 0, LED on = 0
//   Think through the truth tables carefully with active-low signals.
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
    // Truth table (active low):
    //   sw1  sw2  | led1 (0=on)
    //    0    0   |  0    (both pressed -> LED on)
    //    0    1   |  1    (only sw1 -> LED off)
    //    1    0   |  1    (only sw2 -> LED off)
    //    1    1   |  1    (neither -> LED off)
    //
    // TODO: What single gate operation on active-low signals
    //       gives us AND-of-pressed behavior?
    //       Hint: OR of active-low = AND of pressed
    assign o_led1 = 1'b1;  // TODO: replace with correct logic

    // LED2: ON when EITHER switch3 OR switch4 is pressed
    //
    // TODO: What gate gives us OR-of-pressed with active-low signals?
    //       Hint: AND of active-low = OR of pressed
    assign o_led2 = 1'b1;  // TODO: replace with correct logic

    // LED3: ON when exactly ONE of switch1/switch2 is pressed (XOR)
    //
    // TODO: XOR of active-low inputs, then invert for active-low output
    assign o_led3 = 1'b1;  // TODO: replace with correct logic

    // LED4: INVERTED behavior of switch1 (LED on when NOT pressed)
    //
    // TODO: Simply invert switch1
    assign o_led4 = 1'b1;  // TODO: replace with correct logic

endmodule
