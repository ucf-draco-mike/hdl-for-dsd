// =============================================================================
// day05_ex01_counter_mod_n.v — Parameterized Modulo-N Counter
// Day 5: Counters, Shift Registers & Debouncing
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Build:  iverilog -o sim day05_ex01_counter_mod_n.v && vvp sim
// Synth:  yosys -p "read_verilog day05_ex01_counter_mod_n.v; synth_ice40 -top counter_mod_n"
// =============================================================================

module counter_mod_n #(
    parameter N = 10
)(
    input  wire                     i_clk,
    input  wire                     i_reset,
    input  wire                     i_enable,
    output reg  [$clog2(N)-1:0]     o_count,
    output wire                     o_wrap
);

    always @(posedge i_clk) begin
        if (i_reset)
            o_count <= 0;
        else if (i_enable) begin
            if (o_count == N - 1)
                o_count <= 0;
            else
                o_count <= o_count + 1;
        end
    end

    assign o_wrap = i_enable && (o_count == N - 1);

endmodule
