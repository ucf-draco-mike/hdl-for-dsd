// ram_init.v — Synchronous RAM with $readmemh initialization
// Combines ROM (initial data) + RAM (writeable) in one module.
// After programming, the RAM contains the hex file's data.
// Writes update individual addresses without affecting others.
module ram_init #(
    parameter ADDR_WIDTH = 4,     // 2^4 = 16 addresses
    parameter DATA_WIDTH = 8,
    parameter INIT_FILE  = "init_data.hex"
)(
    input  wire                    i_clk,
    input  wire                    i_write_en,
    input  wire [ADDR_WIDTH-1:0]  i_addr,
    input  wire [DATA_WIDTH-1:0]  i_write_data,
    output reg  [DATA_WIDTH-1:0]  o_read_data
);

    reg [DATA_WIDTH-1:0] r_mem [0:(1 << ADDR_WIDTH)-1];

    // TODO: Load initial contents from hex file
    //       Use: initial $readmemh(INIT_FILE, r_mem);
    //
    // ---- YOUR CODE HERE ----

    // TODO: Implement synchronous read-before-write (same as ram_sp)
    //
    // ---- YOUR CODE HERE ----

endmodule
