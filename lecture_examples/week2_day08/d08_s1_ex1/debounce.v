// =============================================================================
// debounce.v — Counter-Based Mechanical Switch Debouncer
// Day 8: Hierarchy, Parameters & Generate
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Takes a (synchronized) potentially bouncing input and produces a clean
// version that only changes after CLKS_STABLE consecutive matching cycles.
// Assumes the input has already been synchronized (use sync_2ff upstream).
//
// Parameters:
//   CLKS_STABLE : cycles to wait before accepting a new value
//                 (default 250_000 = 10 ms @ 25 MHz; override low for sim)
// =============================================================================

module debounce #(
    parameter CLKS_STABLE = 250_000
)(
    input  wire i_clk,
    input  wire i_noisy,
    output reg  o_clean = 1'b0
);

    // Width of the stability counter.
    localparam W = (CLKS_STABLE <= 1) ? 1 : $clog2(CLKS_STABLE);

    reg [W-1:0] r_count = {W{1'b0}};

    always @(posedge i_clk) begin
        if (i_noisy != o_clean) begin
            // Input differs from output — count how long it persists.
            if (r_count == CLKS_STABLE - 1) begin
                o_clean <= i_noisy;
                r_count <= 0;
            end else begin
                r_count <= r_count + 1'b1;
            end
        end else begin
            // Input matches output — reset stability counter.
            r_count <= 0;
        end
    end

endmodule
