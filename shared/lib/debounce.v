// =============================================================================
// debounce.v — Counter-based Button Debouncer (parameterized)
// Accelerated HDL for Digital System Design · UCF · shared/lib
// =============================================================================
// Description:
//   Eliminates switch bounce by requiring the input to be stable for
//   DEBOUNCE_CNT consecutive clock cycles before passing the value through.
//   Clean, synthesis-friendly, no timing hacks.
//
// Parameters:
//   DEBOUNCE_CNT  Number of stable cycles required (default 250000 = 10ms @ 25MHz)
//
// Ports:
//   i_clk     Clock input (any frequency — set DEBOUNCE_CNT accordingly)
//   i_switch  Raw (bouncy) switch input
//   o_switch  Debounced output (follows input only after stable for DEBOUNCE_CNT cycles)
//
// Introduced: Day 5
// =============================================================================
module debounce #(
    parameter DEBOUNCE_CNT = 250_000  // 10 ms @ 25 MHz
) (
    input  wire i_clk,
    input  wire i_switch,
    output wire o_switch
);
    // Synchronize input to clock domain (2-FF synchronizer)
    reg r_sync0, r_sync1;
    always @(posedge i_clk) begin
        r_sync0 <= i_switch;
        r_sync1 <= r_sync0;
    end

    // Counter — resets whenever the synchronized input changes
    reg [$clog2(DEBOUNCE_CNT+1)-1:0] r_count = 0;
    reg r_prev = 0, r_stable = 0;

    always @(posedge i_clk) begin
        r_prev <= r_sync1;
        if (r_sync1 !== r_prev) begin
            // Input changed — restart counter
            r_count <= 0;
        end else if (r_count < DEBOUNCE_CNT) begin
            r_count <= r_count + 1'b1;
        end else begin
            // Stable for DEBOUNCE_CNT cycles — latch the value
            r_stable <= r_sync1;
        end
    end

    assign o_switch = r_stable;

endmodule
