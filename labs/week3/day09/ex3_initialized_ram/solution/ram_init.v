// ram_init.v — Synchronous RAM with $readmemh initialization (SOLUTION)
module ram_init #(
    parameter ADDR_WIDTH = 4,
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

    // Load initial contents
    initial $readmemh(INIT_FILE, r_mem);

    // Synchronous read-before-write
    always @(posedge i_clk) begin
        if (i_write_en)
            r_mem[i_addr] <= i_write_data;
        o_read_data <= r_mem[i_addr];
    end

endmodule
