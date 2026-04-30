// =============================================================================
// day09_ex03_pattern_sequencer.v — ROM-Based LED Pattern Player
// Day 9: Memory — RAM, ROM & Block RAM
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Steps through a ROM loaded from a .mem file.
// i_next advances the address. o_pattern drives LEDs / 7-seg.
// =============================================================================
// Build:  iverilog -DSIMULATION -o sim day09_ex03_pattern_sequencer.v && vvp sim
// Synth:  yosys -p "read_verilog day09_ex03_pattern_sequencer.v; synth_ice40 -top pattern_sequencer"
// =============================================================================

module pattern_sequencer #(
    parameter DEPTH    = 16,
    parameter WIDTH    = 8,
    parameter MEM_FILE = "pattern.mem"
)(
    input  wire             i_clk,
    input  wire             i_reset,
    input  wire             i_next,     // advance one step
    output wire [WIDTH-1:0] o_pattern
);

    reg [WIDTH-1:0] r_mem [0:DEPTH-1];

    initial begin
        $readmemb(MEM_FILE, r_mem);
    end

    reg [$clog2(DEPTH)-1:0] r_addr;

    always @(posedge i_clk) begin
        if (i_reset)
            r_addr <= 0;
        else if (i_next)
            r_addr <= (r_addr == DEPTH - 1) ? 0 : r_addr + 1;
    end

    // Async read is fine for 16 entries (LUT-based)
    assign o_pattern = r_mem[r_addr];

endmodule
