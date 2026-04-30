// =============================================================================
// day09_ex01_rom_sync.v — Parameterized Synchronous ROM (Block RAM Inference)
// Day 9: Memory — RAM, ROM & Block RAM
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Synchronous read enables block RAM (EBR) inference on iCE40.
// One-cycle read latency: address on cycle N, data on cycle N+1.
// =============================================================================
// Build:  iverilog -DSIMULATION -o sim day09_ex01_rom_sync.v && vvp sim
// Synth:  yosys -p "read_verilog day09_ex01_rom_sync.v; synth_ice40 -top rom_sync"
// =============================================================================

module rom_sync #(
    parameter ADDR_WIDTH = 4,
    parameter DATA_WIDTH = 8,
    parameter MEM_FILE   = "pattern.mem"
)(
    input  wire                    i_clk,
    input  wire [ADDR_WIDTH-1:0]  i_addr,
    output reg  [DATA_WIDTH-1:0]  o_data
);

    reg [DATA_WIDTH-1:0] r_mem [0:(1<<ADDR_WIDTH)-1];

    initial begin
        $readmemb(MEM_FILE, r_mem);
    end

    // Synchronous read — key for block RAM inference
    always @(posedge i_clk) begin
        o_data <= r_mem[i_addr];
    end

endmodule

// =============================================================================
// Self-Checking Testbench
// =============================================================================
`ifdef SIMULATION
module tb_rom_sync;
    reg        clk = 0;
    reg  [3:0] addr;
    wire [7:0] data;

    rom_sync #(
        .ADDR_WIDTH(4), .DATA_WIDTH(8),
        .MEM_FILE("pattern.mem")
    ) uut (
        .i_clk(clk), .i_addr(addr), .o_data(data)
    );

    always #20 clk = ~clk;

    integer i, test_count = 0, fail_count = 0;

    // Expected values (must match pattern.mem)
    reg [7:0] expected [0:15];
    initial begin
        expected[ 0] = 8'b00000001;  expected[ 1] = 8'b00000010;
        expected[ 2] = 8'b00000100;  expected[ 3] = 8'b00001000;
        expected[ 4] = 8'b00010000;  expected[ 5] = 8'b00100000;
        expected[ 6] = 8'b01000000;  expected[ 7] = 8'b10000000;
        expected[ 8] = 8'b01000000;  expected[ 9] = 8'b00100000;
        expected[10] = 8'b00010000;  expected[11] = 8'b00001000;
        expected[12] = 8'b00000100;  expected[13] = 8'b00000010;
        expected[14] = 8'b00000001;  expected[15] = 8'b11111111;
    end

    initial begin
        $dumpfile("tb_rom_sync.vcd");
        $dumpvars(0, tb_rom_sync);
        addr = 0; #100;

        $display("\n=== ROM Sync Testbench ===\n");

        for (i = 0; i < 16; i = i + 1) begin
            addr = i[3:0];
            @(posedge clk);   // present address
            @(posedge clk); #1;  // data available NEXT cycle (sync read!)
            test_count = test_count + 1;
            if (data !== expected[i]) begin
                $display("FAIL: addr=%0d expected=%b got=%b", i, expected[i], data);
                fail_count = fail_count + 1;
            end else
                $display("PASS: addr=%0d = %b", i, data);
        end

        $display("\n=== SUMMARY: %0d/%0d passed ===",
                 test_count - fail_count, test_count);
        if (fail_count == 0) $display("*** ALL TESTS PASSED ***\n");
        else $display("*** %0d FAILURES ***\n", fail_count);
        $finish;
    end
endmodule
`endif
