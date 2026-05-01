// tb_ram_sp.v -- Testbench for single-port synchronous RAM (SOLUTION)
`timescale 1ns / 1ps

module tb_ram_sp;

    reg        clk, we;
    reg  [7:0] addr, wdata;
    wire [7:0] rdata;

    ram_sp #(.ADDR_WIDTH(8), .DATA_WIDTH(8)) uut (
        .i_clk        (clk),
        .i_write_en   (we),
        .i_addr       (addr),
        .i_write_data (wdata),
        .o_read_data  (rdata)
    );

    initial clk = 0;
    always #20 clk = ~clk;

    integer i, test_count = 0, fail_count = 0;

    task check_read(input [7:0] exp, input [255:0] msg);
        begin
            test_count = test_count + 1;
            if (rdata !== exp) begin
                fail_count = fail_count + 1;
                $display("FAIL [%0s]: addr=%0d got 0x%02X, expected 0x%02X",
                         msg, addr, rdata, exp);
            end
        end
    endtask

    initial begin
        $dumpfile("ram.vcd");
        $dumpvars(0, tb_ram_sp);
        we = 0; addr = 0; wdata = 0;
        #100;

        // Test 1: Write XOR pattern to all 256 addresses
        $display("--- Writing all 256 addresses ---");
        we = 1;
        for (i = 0; i < 256; i = i + 1) begin
            addr  = i[7:0];
            wdata = i[7:0] ^ 8'hA5;
            @(posedge clk); #1;
        end
        we = 0;

        // Test 2: Read back and verify all 256 addresses
        $display("--- Reading and verifying ---");
        for (i = 0; i < 256; i = i + 1) begin
            addr = i[7:0];
            @(posedge clk); #1;  // one-cycle read latency!
            check_read(i[7:0] ^ 8'hA5, "full readback");
        end

        // Test 3: Overwrite addresses 0-15 with new pattern
        $display("--- Overwriting addresses 0-15 ---");
        we = 1;
        for (i = 0; i < 16; i = i + 1) begin
            addr  = i[7:0];
            wdata = i[7:0] ^ 8'h5A;
            @(posedge clk); #1;
        end
        we = 0;

        // Verify overwritten addresses
        $display("--- Verifying overwrites ---");
        for (i = 0; i < 16; i = i + 1) begin
            addr = i[7:0];
            @(posedge clk); #1;
            check_read(i[7:0] ^ 8'h5A, "overwrite verify");
        end

        // Verify untouched addresses still have original data
        $display("--- Verifying untouched data ---");
        for (i = 16; i < 32; i = i + 1) begin
            addr = i[7:0];
            @(posedge clk); #1;
            check_read(i[7:0] ^ 8'hA5, "untouched verify");
        end

        // Test 4: Boundary addresses
        $display("--- Boundary tests ---");
        addr = 8'h00; @(posedge clk); #1;
        check_read(8'h00 ^ 8'h5A, "addr 0x00");
        addr = 8'hFF; @(posedge clk); #1;
        check_read(8'hFF ^ 8'hA5, "addr 0xFF");

        // Report
        $display("\n=================================");
        if (fail_count == 0)
            $display("ALL %0d TESTS PASSED", test_count);
        else
            $display("FAILED %0d / %0d tests", fail_count, test_count);
        $display("=================================\n");
        $finish;
    end
endmodule
