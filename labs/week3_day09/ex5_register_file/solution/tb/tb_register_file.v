// tb_register_file.v — Testbench for register file (SOLUTION)
`timescale 1ns / 1ps

module tb_register_file;

    reg        clk, we;
    reg  [2:0] waddr, raddr_a, raddr_b;
    reg  [7:0] wdata;
    wire [7:0] rdata_a, rdata_b;

    register_file #(.N_REGS(8), .DATA_WIDTH(8)) uut (
        .i_clk         (clk),
        .i_write_en    (we),
        .i_write_addr  (waddr),
        .i_write_data  (wdata),
        .i_read_addr_a (raddr_a),
        .i_read_addr_b (raddr_b),
        .o_read_data_a (rdata_a),
        .o_read_data_b (rdata_b)
    );

    initial clk = 0;
    always #20 clk = ~clk;

    integer i, test_count = 0, fail_count = 0;

    task check_ab(input [7:0] exp_a, exp_b, input [255:0] msg);
        begin
            test_count = test_count + 1;
            if (rdata_a !== exp_a || rdata_b !== exp_b) begin
                fail_count = fail_count + 1;
                $display("FAIL [%0s]: A=0x%02X(exp 0x%02X) B=0x%02X(exp 0x%02X)",
                         msg, rdata_a, exp_a, rdata_b, exp_b);
            end else
                $display("PASS [%0s]", msg);
        end
    endtask

    initial begin
        $dumpfile("regfile.vcd");
        $dumpvars(0, tb_register_file);
        we = 0; waddr = 0; wdata = 0; raddr_a = 0; raddr_b = 0;
        #100;

        // Write unique values to all 8 registers
        $display("--- Writing all registers ---");
        we = 1;
        for (i = 0; i < 8; i = i + 1) begin
            waddr = i[2:0];
            wdata = (i * 16 + 5);   // 0x05, 0x15, 0x25, ...
            @(posedge clk); #1;
        end
        we = 0;

        // Read pairs and verify (async — no latency)
        $display("\n--- Dual-port read verification ---");
        raddr_a = 3'd0; raddr_b = 3'd7; #1;
        check_ab(8'h05, 8'h75, "regs 0,7");

        raddr_a = 3'd3; raddr_b = 3'd4; #1;
        check_ab(8'h35, 8'h45, "regs 3,4");

        raddr_a = 3'd1; raddr_b = 3'd1; #1;
        check_ab(8'h15, 8'h15, "same reg both ports");

        // Write-then-read same address (forwarding test)
        $display("\n--- Write-then-read ---");
        we = 1; waddr = 3'd2; wdata = 8'hFF;
        raddr_a = 3'd2; raddr_b = 3'd5;
        @(posedge clk); #1;
        we = 0;
        // After the clock edge, reg 2 should have 8'hFF
        // (async read sees the NEWLY written value on next #1 settling)
        raddr_a = 3'd2; #1;
        check_ab(8'hFF, 8'h55, "write-then-read");

        $display("\n=================================");
        if (fail_count == 0)
            $display("ALL %0d TESTS PASSED", test_count);
        else
            $display("FAILED %0d / %0d tests", fail_count, test_count);
        $display("=================================\n");
        $finish;
    end
endmodule
