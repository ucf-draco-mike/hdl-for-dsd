// =============================================================================
// ram_sp.v — Single-Port Synchronous RAM (Block RAM Inference)
// Day 9: Memory — RAM, ROM & Block RAM
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Read-before-write behavior maps cleanly to iCE40 EBR.

module ram_sp #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input  wire                  i_clk,
    input  wire                  i_write_en,
    input  wire [ADDR_WIDTH-1:0] i_addr,
    input  wire [DATA_WIDTH-1:0] i_write_data,
    output reg  [DATA_WIDTH-1:0] o_read_data
);

    reg [DATA_WIDTH-1:0] r_mem [0:(1<<ADDR_WIDTH)-1];

    always @(posedge i_clk) begin
        if (i_write_en)
            r_mem[i_addr] <= i_write_data;

        o_read_data <= r_mem[i_addr];  // read-before-write
    end

endmodule
