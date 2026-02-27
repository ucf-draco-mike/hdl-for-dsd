// =============================================================================
// led_driver.v — The Simplest Possible Module
// Day 1: Welcome to Hardware Thinking
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Description:
//   Connects a switch directly to an LED. This is a physical wire — no logic.
//   Demonstrates module structure, ports, and continuous assignment.
//
// Go Board: Switches are ACTIVE LOW (pressed = 0).
//           LEDs are ACTIVE LOW (0 = on).
//           So a direct connection means: press switch → LED turns on.
// =============================================================================

module led_driver (
    input  wire i_switch,
    output wire o_led
);

    // Continuous assignment: permanent wire connection
    // When i_switch changes, o_led changes instantly
    assign o_led = i_switch;

endmodule
