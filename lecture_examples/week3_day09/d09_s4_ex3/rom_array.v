// =============================================================================
// rom_array.v — Parameterized Synchronous-Read ROM (Block RAM Inference)
// Day 9 · Topic 9.4: Memory Applications · Demo example 3
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Same module used in d09_s1_ex1 — copied here so this example directory is
// self-contained for `make sim` / `make prog`.
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

    initial $readmemh(INIT_FILE, mem);

    always @(posedge i_clk) o_data <= mem[i_addr];

endmodule
