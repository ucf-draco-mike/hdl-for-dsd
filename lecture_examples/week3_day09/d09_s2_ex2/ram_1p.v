// =============================================================================
// ram_1p.v — Single-Port Synchronous RAM (read-before-write)
// Day 9 · Topic 9.2: RAM in Verilog · Demo example 2
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Idiomatic block-RAM RAM: one clock, sync write, sync read with registered
// output. yosys synth_ice40 infers SB_RAM40_4K from this exact pattern.
// One-cycle read latency: address cycle N -> data cycle N+1.
// On simultaneous read/write to the same address, the read returns the OLD
// value (read-before-write) — natural EBR behavior.
// =============================================================================

module ram_1p #(
    parameter ADDR_W = 10,           // 1024 entries
    parameter DATA_W = 8
) (
    input  wire              i_clk,
    input  wire              i_we,    // write enable
    input  wire [ADDR_W-1:0] i_addr,
    input  wire [DATA_W-1:0] i_din,
    output reg  [DATA_W-1:0] o_dout
);

    reg [DATA_W-1:0] mem [0:(2**ADDR_W)-1];

    always @(posedge i_clk) begin
        if (i_we) mem[i_addr] <= i_din;   // synchronous write
        o_dout <= mem[i_addr];             // synchronous read (old value)
    end

endmodule
