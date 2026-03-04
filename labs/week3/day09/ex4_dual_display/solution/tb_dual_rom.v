// tb_dual_rom.v — Testbench for dual-display ROM player (SOLUTION)
`timescale 1ns / 1ps

module tb_dual_rom;

    reg  clk, reset, speed_up;
    wire [7:0] data1, data2;
    wire [3:0] addr;

    dual_rom #(.CLK_FREQ(40), .N_ENTRIES(16)) uut (
        .i_clk      (clk),
        .i_reset    (reset),
        .i_speed_up (speed_up),
        .o_data1    (data1),
        .o_data2    (data2),
        .o_addr     (addr)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    integer test_count = 0, fail_count = 0;

    initial begin
        $dumpfile("dual_rom.vcd");
        $dumpvars(0, tb_dual_rom);

        reset = 1; speed_up = 0;
        @(posedge clk); @(posedge clk);
        reset = 0;
        @(posedge clk); #1;

        // Verify first pattern: rom1[0]=0x00, rom2[0]=0x0F
        test_count = test_count + 1;
        if (data1 !== 8'h00 || data2 !== 8'h0F) begin
            fail_count = fail_count + 1;
            $display("FAIL: initial data1=0x%02X data2=0x%02X", data1, data2);
        end else
            $display("PASS: initial data correct");

        // Wait for a tick (40 clocks at 1x speed) then verify advance
        repeat(40) @(posedge clk); #1;
        test_count = test_count + 1;
        if (addr !== 4'd1) begin
            fail_count = fail_count + 1;
            $display("FAIL: after tick addr=%0d (expected 1)", addr);
        end else
            $display("PASS: auto-advance to addr 1");

        // Verify complementary data
        test_count = test_count + 1;
        if (data1 !== 8'h01 || data2 !== 8'h0E) begin
            fail_count = fail_count + 1;
            $display("FAIL: addr1 data1=0x%02X data2=0x%02X", data1, data2);
        end else
            $display("PASS: complementary data correct");

        $display("\n=================================");
        if (fail_count == 0)
            $display("ALL %0d TESTS PASSED", test_count);
        else
            $display("FAILED %0d / %0d tests", fail_count, test_count);
        $display("=================================\n");
        $finish;
    end
endmodule
