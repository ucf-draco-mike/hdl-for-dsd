// ram_sp.v — Single-port synchronous RAM
// Synchronous read → will infer block RAM (EBR) on iCE40
// Read-before-write behavior: on simultaneous read+write to same
// address, the read returns the OLD value.
module ram_sp #(
    parameter ADDR_WIDTH = 8,    // 2^8 = 256 addresses
    parameter DATA_WIDTH = 8     // 8-bit data
)(
    input  wire                    i_clk,
    input  wire                    i_write_en,
    input  wire [ADDR_WIDTH-1:0]  i_addr,
    input  wire [DATA_WIDTH-1:0]  i_write_data,
    output reg  [DATA_WIDTH-1:0]  o_read_data
);

    // Memory array
    reg [DATA_WIDTH-1:0] r_mem [0:(1 << ADDR_WIDTH)-1];

    // TODO: Implement synchronous read-before-write behavior
    //
    //       On every rising edge of i_clk:
    //         1. If i_write_en is high, write i_write_data to r_mem[i_addr]
    //         2. Always read r_mem[i_addr] into o_read_data
    //
    //       IMPORTANT: The read happens on the SAME clock edge.
    //       This means the read data appears ONE CYCLE AFTER the
    //       address is presented. This one-cycle latency is what
    //       allows Yosys to infer block RAM instead of LUTs.
    //
    //       Pattern:
    //         always @(posedge i_clk) begin
    //             if (i_write_en)
    //                 r_mem[i_addr] <= i_write_data;
    //             o_read_data <= r_mem[i_addr];
    //         end
    //
    // ---- YOUR CODE HERE ----

endmodule
