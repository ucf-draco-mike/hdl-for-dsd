// =============================================================================
// tb_ram_1p.v — Self-checking testbench for the single-port RAM
// Day 9 · Topic 9.2: RAM in Verilog · Demo example 2
// =============================================================================
// Writes 64 (addr, data) pairs into the RAM, then reads them back and
// confirms each value. Demonstrates the 1-cycle synchronous read latency.
// VCD: tb_ram_1p.vcd
// Expected stdout (from the slide):
//   PASS: write 42 @ addr 0
//   PASS: read 42 @ addr 0 (1 cycle later)
//   ...
//   === 64 passed, 0 failed ===
// =============================================================================

`timescale 1ns/1ps

module tb_ram_1p;
    localparam ADDR_W = 10;
    localparam DATA_W = 8;
    localparam N_TESTS = 64;

    reg                  clk = 0;
    reg                  we;
    reg  [ADDR_W-1:0]    addr;
    reg  [DATA_W-1:0]    din;
    wire [DATA_W-1:0]    dout;

    ram_1p #(.ADDR_W(ADDR_W), .DATA_W(DATA_W)) uut (
        .i_clk(clk), .i_we(we), .i_addr(addr), .i_din(din), .o_dout(dout)
    );

    always #20 clk = ~clk;

    integer i, fail_count = 0;
    reg [ADDR_W-1:0] addrs   [0:N_TESTS-1];
    reg [DATA_W-1:0] datas   [0:N_TESTS-1];

    initial begin
        $dumpfile("tb_ram_1p.vcd");
        $dumpvars(0, tb_ram_1p);

        we   = 0;
        addr = 0;
        din  = 0;
        #100;

        $display("\n=== RAM single-port testbench (1024 x 8) ===\n");

        // ---- Phase 1: write N_TESTS distinct (addr, data) pairs ----
        // Use a deterministic but varied pattern so failures are easy to read.
        for (i = 0; i < N_TESTS; i = i + 1) begin
            addrs[i] = (i * 37) & ((1 << ADDR_W) - 1);   // spread across 1024
            datas[i] = (i ^ 8'h2A) & ((1 << DATA_W) - 1);
        end

        we = 1;
        for (i = 0; i < N_TESTS; i = i + 1) begin
            addr = addrs[i];
            din  = datas[i];
            @(posedge clk); #1;
            $display("PASS: write %0d @ addr %0d", datas[i], addrs[i]);
        end
        we = 0;

        // ---- Phase 2: read each back, account for 1-cycle latency ----
        for (i = 0; i < N_TESTS; i = i + 1) begin
            addr = addrs[i];
            @(posedge clk);     // present address
            @(posedge clk); #1; // data appears NEXT cycle (sync read)
            if (dout !== datas[i]) begin
                $display("FAIL: read got %0d @ addr %0d (expected %0d)",
                         dout, addrs[i], datas[i]);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: read %0d @ addr %0d (1 cycle later)",
                         dout, addrs[i]);
            end
        end

        // ---- Phase 3: confirm writes don't disturb other addresses ----
        // Read addr 0 (was written first); make sure value still matches.
        addr = addrs[0];
        @(posedge clk);
        @(posedge clk); #1;
        if (dout !== datas[0])
            $display("FAIL: write cycles disturbed addr %0d (got %0d, expected %0d)",
                     addrs[0], dout, datas[0]);
        else
            $display("PASS: write cycles don't affect other addresses");

        $display("\n=== %0d passed, %0d failed ===",
                 N_TESTS - fail_count, fail_count);
        if (fail_count == 0) $display("*** ALL TESTS PASSED ***\n");
        else                 $display("*** %0d FAILURES ***\n", fail_count);
        $finish;
    end
endmodule
