// heartbeat.v — Heartbeat LED blinker
// Default: ~1.3 Hz blink at 25 MHz (bit 23 toggle)
// Use this to prove the FPGA is configured and running
module heartbeat #(
    parameter WIDTH = 24
)(
    input  wire i_clk,
    output wire o_led    // Connect to Go Board LED (active-low)
);
    reg [WIDTH-1:0] r_count = 0;

    always @(posedge i_clk)
        r_count <= r_count + 1;

    assign o_led = ~r_count[WIDTH-1];  // Active-low for Go Board
endmodule
