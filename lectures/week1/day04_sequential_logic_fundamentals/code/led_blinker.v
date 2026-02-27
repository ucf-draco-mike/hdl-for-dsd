// =============================================================================
// led_blinker.v — Counter-Based LED Blinker
// Day 4: Sequential Logic Fundamentals
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Description:
//   Blinks an LED at approximately 1 Hz using the Go Board's 25 MHz clock.
//   Demonstrates: counter, comparison, toggle, clock division.
//
// Calculation:
//   25 MHz = 25,000,000 cycles/sec
//   1 Hz blink = toggle every 0.5 sec = 12,500,000 cycles per half-period
//   log2(12,500,000) ≈ 24 bits needed
// =============================================================================

module led_blinker (
    input  wire i_clk,        // 25 MHz
    output wire o_led1         // ~1 Hz blink
);

    // Counter needs 24 bits to hold 12,500,000
    reg [23:0] r_counter;
    reg        r_led;

    always @(posedge i_clk) begin
        if (r_counter == 24'd12_499_999) begin
            r_counter <= 24'd0;
            r_led     <= ~r_led;        // toggle LED
        end else begin
            r_counter <= r_counter + 1;
        end
    end

    // Active-low LED: invert the register output
    assign o_led1 = ~r_led;

endmodule
