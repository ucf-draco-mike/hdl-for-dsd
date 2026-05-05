// =============================================================================
// rom_array.v — Parameterized Synchronous-Read ROM (Block RAM Inference)
// Day 9 · Topic 9.1: ROM in Verilog · Demo example 1
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Idiomatic block-RAM ROM: array + $readmemh + clocked read.
// On iCE40, yosys infers SB_RAM40_4K (an EBR) from this exact pattern.
// One-cycle read latency: address on cycle N, data on cycle N+1.
// =============================================================================

module rom_array #(
    parameter ADDR_W    = 8,
    parameter DATA_W    = 8,
    parameter INIT_FILE = "rom_contents.hex"
) (
    input  wire              i_clk,
    input  wire [ADDR_W-1:0] i_addr,
    output reg  [DATA_W-1:0] o_data
);

    reg [DATA_W-1:0] mem [0:(2**ADDR_W)-1];

    initial $readmemh(INIT_FILE, mem);   // synth-time content load

    always @(posedge i_clk) o_data <= mem[i_addr];   // synchronous read

endmodule
