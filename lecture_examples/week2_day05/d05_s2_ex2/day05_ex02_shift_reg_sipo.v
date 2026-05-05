// =============================================================================
// day05_ex02_shift_reg_sipo.v — Serial-In Parallel-Out Shift Register
// Day 5: Counters, Shift Registers & Debouncing
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// This is the core building block for UART RX (Week 3).
// One serial bit enters per clock cycle (when i_shift_en=1); after WIDTH
// cycles, the parallel output holds the assembled word (first bit in -> MSB).
// =============================================================================
// Build:  iverilog -o sim day05_ex02_shift_reg_sipo.v && vvp sim
// Synth:  yosys -p "read_verilog day05_ex02_shift_reg_sipo.v; synth_ice40 -top shift_reg_sipo"
// =============================================================================

module shift_reg_sipo #(
    parameter WIDTH = 8
)(
    input  wire              i_clk,
    input  wire              i_reset,
    input  wire              i_shift_en,
    input  wire              i_serial_in,
    output reg  [WIDTH-1:0]  o_parallel_out
);

    always @(posedge i_clk) begin
        if (i_reset)
            o_parallel_out <= {WIDTH{1'b0}};
        else if (i_shift_en)
            // Shift left, new bit enters at LSB. After WIDTH shifts the
            // first bit received sits in the MSB.
            o_parallel_out <= {o_parallel_out[WIDTH-2:0], i_serial_in};
    end

endmodule
