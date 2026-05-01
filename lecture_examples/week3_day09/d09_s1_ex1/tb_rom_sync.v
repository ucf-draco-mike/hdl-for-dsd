// =============================================================================
// tb_rom_sync.v -- extracted from day09_ex01_rom_sync.v
// =============================================================================
`timescale 1ns/1ps

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
