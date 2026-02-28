// Synchronous single-port RAM
module ram_sync #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8
)(
    input  wire                  i_clk,
    input  wire                  i_we,
    input  wire [ADDR_WIDTH-1:0] i_addr,
    input  wire [DATA_WIDTH-1:0] i_wdata,
    output reg  [DATA_WIDTH-1:0] o_rdata
);
    reg [DATA_WIDTH-1:0] r_mem [0:(1<<ADDR_WIDTH)-1];

    always @(posedge i_clk) begin
        if (i_we)
            r_mem[i_addr] <= i_wdata;
        o_rdata <= r_mem[i_addr];
    end
endmodule
