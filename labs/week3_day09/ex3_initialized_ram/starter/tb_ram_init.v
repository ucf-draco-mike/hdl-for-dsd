// tb_ram_init.v — Testbench for initialized RAM
`timescale 1ns / 1ps

module tb_ram_init;

    reg        clk, we;
    reg  [3:0] addr;
    reg  [7:0] wdata;
    wire [7:0] rdata;

    ram_init #(
        .ADDR_WIDTH (4),
        .DATA_WIDTH (8),
        .INIT_FILE  ("init_data.hex")
    ) uut (
        .i_clk        (clk),
        .i_write_en   (we),
        .i_addr       (addr),
        .i_write_data (wdata),
        .o_read_data  (rdata)
    );

    initial clk = 0;
    always #20 clk = ~clk;

    integer i, test_count = 0, fail_count = 0;

    // Expected initial data (triangular wave from init_data.hex)
    reg [7:0] init_vals [0:15];
    initial begin
        init_vals[0]  = 8'h00; init_vals[1]  = 8'h20;
        init_vals[2]  = 8'h40; init_vals[3]  = 8'h60;
        init_vals[4]  = 8'h80; init_vals[5]  = 8'hA0;
        init_vals[6]  = 8'hC0; init_vals[7]  = 8'hE0;
        init_vals[8]  = 8'hFF; init_vals[9]  = 8'hE0;
        init_vals[10] = 8'hC0; init_vals[11] = 8'hA0;
        init_vals[12] = 8'h80; init_vals[13] = 8'h60;
        init_vals[14] = 8'h40; init_vals[15] = 8'h20;
    end

    task check(input [7:0] exp, input [255:0] msg);
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
        $dumpfile("ram_init.vcd");
        $dumpvars(0, tb_ram_init);
        we = 0; addr = 0; wdata = 0;
        #100;

        // TODO: Test 1 — Verify all 16 initial values
        //       Loop through addresses, read each, compare to init_vals[]
        //       Remember the one-cycle read latency!
        //
        // ---- YOUR CODE HERE ----

        // TODO: Test 2 — Write new values to addresses 2 and 5
        //       addr=2, wdata=8'hBE; addr=5, wdata=8'hEF
        //
        // ---- YOUR CODE HERE ----

        // TODO: Test 3 — Verify writes took effect at addr 2 and 5
        //       AND verify untouched addresses still hold initial values
        //       (Check at least addresses 0, 1, 3, 4 are unchanged)
        //
        // ---- YOUR CODE HERE ----

        $display("\n=================================");
        if (fail_count == 0)
            $display("ALL %0d TESTS PASSED", test_count);
        else
            $display("FAILED %0d / %0d tests", fail_count, test_count);
        $display("=================================\n");
        $finish;
    end
endmodule
