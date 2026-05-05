// =============================================================================
// day05_ex04_debounce.v — Counter-Based Button Debouncer
// Day 5: Counters, Shift Registers & Debouncing
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Pure debounce stage. The slide pipeline puts a 2-FF synchronizer in front
// of this module; the top-level demo (day05_ex04_top.v) wires that up so the
// raw button line is sync'd before reaching i_noisy.
//
// Algorithm: count consecutive clock cycles where i_noisy disagrees with the
// stable o_clean output. Only when the input persists for CLKS_STABLE cycles
// is the new value accepted. Bounces reset the counter.
// =============================================================================
// Build:  iverilog -o sim day05_ex04_debounce.v && vvp sim
// Synth:  yosys -p "read_verilog day05_ex04_debounce.v; synth_ice40 -top debounce"
// =============================================================================

module debounce #(
    parameter CLKS_STABLE = 500_000   // 20 ms at 25 MHz
)(
    input  wire i_clk,
    input  wire i_reset,
    input  wire i_noisy,
    output reg  o_clean
);

    reg [$clog2(CLKS_STABLE)-1:0] r_count;

    always @(posedge i_clk) begin
        if (i_reset) begin
            r_count <= 0;
            o_clean <= 1'b0;
        end else if (i_noisy != o_clean) begin
            // Input differs from output — count how long.
            if (r_count == CLKS_STABLE - 1) begin
                o_clean <= i_noisy;     // persisted long enough, accept
                r_count <= 0;
            end else
                r_count <= r_count + 1'b1;
        end else begin
            // Input matches output — reset counter (bounce filter).
            r_count <= 0;
        end
    end

endmodule
