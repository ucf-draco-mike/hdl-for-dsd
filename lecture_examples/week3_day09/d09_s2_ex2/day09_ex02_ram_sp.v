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

// =============================================================================
// Self-Checking Testbench
// =============================================================================
`ifdef SIMULATION
module tb_ram_sp;
    reg        clk = 0, we;
    reg  [7:0] addr, wdata;
    wire [7:0] rdata;

    ram_sp #(.ADDR_WIDTH(8), .DATA_WIDTH(8)) uut (
        .i_clk(clk), .i_write_en(we),
        .i_addr(addr), .i_write_data(wdata),
        .o_read_data(rdata)
    );

    always #20 clk = ~clk;

    integer i, test_count = 0, fail_count = 0;

    task check;
        input [7:0] expected;
        input [8*30-1:0] name;
    begin
        test_count = test_count + 1;
        if (rdata !== expected) begin
            $display("FAIL: %0s — expected %h, got %h", name, expected, rdata);
            fail_count = fail_count + 1;
        end else
            $display("PASS: %0s = %h", name, rdata);
    end
    endtask

    initial begin
        $dumpfile("tb_ram_sp.vcd");
        $dumpvars(0, tb_ram_sp);
        we = 0; addr = 0; wdata = 0;
        #100;

        $display("\n=== RAM Single-Port Testbench ===\n");

        // Write XOR pattern to 16 addresses
        we = 1;
        for (i = 0; i < 16; i = i + 1) begin
            addr  = i[7:0];
            wdata = i[7:0] ^ 8'hA5;
            @(posedge clk); #1;
        end
        we = 0;

        // Read back and verify (remember: 1-cycle latency!)
        for (i = 0; i < 16; i = i + 1) begin
            addr = i[7:0];
            @(posedge clk);    // present address
            @(posedge clk); #1;  // data available next cycle
            check(i[7:0] ^ 8'hA5, "read-back");
        end

        // Boundary test: address 255
        we = 1; addr = 8'hFF; wdata = 8'h42;
        @(posedge clk); #1;
        we = 0; addr = 8'hFF;
        @(posedge clk);
        @(posedge clk); #1;
        check(8'h42, "addr 255 boundary");

        $display("\n=== SUMMARY: %0d/%0d passed ===",
                 test_count - fail_count, test_count);
        if (fail_count == 0) $display("*** ALL TESTS PASSED ***\n");
        else $display("*** %0d FAILURES ***\n", fail_count);
        $finish;
    end
endmodule
`endif
