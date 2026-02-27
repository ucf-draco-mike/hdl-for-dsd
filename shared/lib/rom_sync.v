// =============================================================================
// rom_sync.v — Parameterized Synchronous ROM (Block RAM Inference)
// Day 9: Memory — RAM, ROM & Block RAM
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Synchronous read enables block RAM (EBR) inference on iCE40.
// One-cycle read latency: address on cycle N, data on cycle N+1.

module rom_sync #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8,
    parameter MEM_FILE   = "rom_data.hex"
)(
    input  wire                  i_clk,
    input  wire [ADDR_WIDTH-1:0] i_addr,
    output reg  [DATA_WIDTH-1:0] o_data
);

    reg [DATA_WIDTH-1:0] r_mem [0:(1<<ADDR_WIDTH)-1];

    initial begin
        $readmemh(MEM_FILE, r_mem);
    end

    // Synchronous read — key for block RAM inference
    always @(posedge i_clk) begin
        o_data <= r_mem[i_addr];
    end

endmodule
