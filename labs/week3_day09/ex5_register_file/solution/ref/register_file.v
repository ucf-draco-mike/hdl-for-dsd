// register_file.v — Small register file (1 write port, 2 read ports)
// Async reads (combinational) — infers distributed RAM (LUTs), not block RAM
// This is intentional: CPUs need read data in the same cycle for the ALU
module register_file #(
    parameter N_REGS     = 8,
    parameter DATA_WIDTH = 8
)(
    input  wire                          i_clk,
    input  wire                          i_write_en,
    input  wire [$clog2(N_REGS)-1:0]    i_write_addr,
    input  wire [DATA_WIDTH-1:0]         i_write_data,
    input  wire [$clog2(N_REGS)-1:0]    i_read_addr_a,
    input  wire [$clog2(N_REGS)-1:0]    i_read_addr_b,
    output wire [DATA_WIDTH-1:0]         o_read_data_a,
    output wire [DATA_WIDTH-1:0]         o_read_data_b
);

    reg [DATA_WIDTH-1:0] r_regs [0:N_REGS-1];

    // Synchronous write
    always @(posedge i_clk) begin
        if (i_write_en)
            r_regs[i_write_addr] <= i_write_data;
    end

    // Async reads — combinational, no latency
    assign o_read_data_a = r_regs[i_read_addr_a];
    assign o_read_data_b = r_regs[i_read_addr_b];

endmodule
