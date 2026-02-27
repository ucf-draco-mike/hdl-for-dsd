// =============================================================================
// shift_reg_piso.v — Parallel In, Serial Out Shift Register
// Day 5: Counters, Shift Registers & Debouncing
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// UART TX core building block: load a byte, shift out one bit at a time.

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
            r_shift <= i_parallel_in;
        else if (i_shift_en)
            r_shift <= {1'b0, r_shift[WIDTH-1:1]};
    end

    assign o_serial_out = r_shift[0];

endmodule
