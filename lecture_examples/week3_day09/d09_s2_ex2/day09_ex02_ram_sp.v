// =============================================================================
// day09_ex02_ram_sp.v — Single-Port Synchronous RAM
// Day 9: Memory — RAM, ROM & Block RAM
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Read-before-write behavior. Synchronous read infers block RAM on iCE40.
// One-cycle read latency: address cycle N → data cycle N+1.
// =============================================================================
// Build:  iverilog -DSIMULATION -o sim day09_ex02_ram_sp.v && vvp sim
// Synth:  yosys -p "read_verilog day09_ex02_ram_sp.v; synth_ice40 -top ram_sp"
// =============================================================================

module ram_sp #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 8
)(
    input  wire                    i_clk,
    input  wire                    i_write_en,
    input  wire [ADDR_WIDTH-1:0]  i_addr,
    input  wire [DATA_WIDTH-1:0]  i_write_data,
    output reg  [DATA_WIDTH-1:0]  o_read_data
);

    reg [DATA_WIDTH-1:0] r_mem [0:(1<<ADDR_WIDTH)-1];

    // Read-before-write: output gets OLD value during simultaneous read/write
    always @(posedge i_clk) begin
        if (i_write_en)
            r_mem[i_addr] <= i_write_data;
        o_read_data <= r_mem[i_addr];
    end

endmodule
