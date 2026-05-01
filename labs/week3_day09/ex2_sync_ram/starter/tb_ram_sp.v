// tb_ram_sp.v -- Testbench for single-port synchronous RAM
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
    always #20 clk = ~clk;  // 25 MHz

    integer i, test_count = 0, fail_count = 0;

    task check_read(input [7:0] exp, input [255:0] msg);
        begin
            test_count = test_count + 1;
            if (rdata !== exp) begin
                fail_count = fail_count + 1;
                $display("FAIL [%0s]: got 0x%02X, expected 0x%02X",
                         msg, rdata, exp);
            end
        end
    endtask

    initial begin
        $dumpfile("ram.vcd");
        $dumpvars(0, tb_ram_sp);
        we = 0; addr = 0; wdata = 0;
        #100;

        // -- Test 1: Write XOR pattern to all 256 addresses --
        // TODO: Set we=1, loop i from 0 to 255
        //       addr = i, wdata = i ^ 8'hA5
        //       One @(posedge clk); #1; per iteration
        //       Then set we=0
        //
        // ---- YOUR CODE HERE ----

        // -- Test 2: Read back and verify all 256 addresses --
        // TODO: Loop i from 0 to 255
        //       Set addr = i
        //       Wait @(posedge clk); #1;  <-- THIS IS THE KEY!
        //       One-cycle read latency means data appears NEXT cycle.
        //       Use check_read(i ^ 8'hA5, "readback") to verify
        //
        // ---- YOUR CODE HERE ----

        // -- Test 3: Overwrite and verify --
        // TODO: Write a different pattern (e.g., i ^ 8'h5A) to
        //       addresses 0-15 only, then verify those changed
        //       while addresses 16+ still have old pattern.
        //
        // ---- YOUR CODE HERE ----

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
