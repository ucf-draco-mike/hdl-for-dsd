// =============================================================================
// day05_ex02_shift_reg_piso.v — Parallel-In Serial-Out Shift Register
// Day 5: Counters, Shift Registers & Debouncing
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// This is the core building block for UART TX (Week 3).
// Load a byte, then shift it out LSB-first one bit per clock.
// =============================================================================
// Build:  iverilog -o sim day05_ex02_shift_reg_piso.v && vvp sim
// Synth:  yosys -p "read_verilog day05_ex02_shift_reg_piso.v; synth_ice40 -top shift_reg_piso"
// =============================================================================

module shift_reg_piso #(
    parameter WIDTH = 8
)(
    input  wire              i_clk,
    input  wire              i_reset,
    input  wire              i_load,
    input  wire              i_shift_en,
    input  wire [WIDTH-1:0]  i_parallel_in,
    output wire              o_serial_out
);

    reg [WIDTH-1:0] r_shift;

    always @(posedge i_clk) begin
        if (i_reset)
            r_shift <= {WIDTH{1'b0}};
        else if (i_load)
            r_shift <= i_parallel_in;       // load wins over shift
        else if (i_shift_en)
            r_shift <= {1'b0, r_shift[WIDTH-1:1]};  // shift right, fill MSB with 0
    end

    assign o_serial_out = r_shift[0];       // LSB first (UART convention)

endmodule
