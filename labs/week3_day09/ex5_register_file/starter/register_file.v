// =============================================================================
// register_file.v — Small Register File (Starter)
// Day 9, Exercise 5 (Stretch)
// =============================================================================
// 1 write port (synchronous), 2 read ports (combinational/async)
// Async reads infer distributed RAM (LUTs), not block RAM.
//
// TODO: Implement the register file with:
//   - Parameterized number of registers and data width
//   - Synchronous write: on posedge clk, if i_write_en, write i_write_data to i_write_addr
//   - Async read: o_read_data_a = regs[i_read_addr_a] (combinational)

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

    // TODO: Declare the register array

    // TODO: Synchronous write

    // TODO: Async (combinational) reads

endmodule
