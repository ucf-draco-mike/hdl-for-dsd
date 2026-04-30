// =============================================================================
// tb_counter_mod_n.v — extracted from day05_ex01_counter_mod_n.v
// =============================================================================
`timescale 1ns/1ps

module tb_counter_mod_n;
    reg clk = 0, reset = 1, enable = 0;
    wire [3:0] count;
    wire       wrap;

    counter_mod_n #(.N(10)) uut (
        .i_clk(clk), .i_reset(reset), .i_enable(enable),
        .o_count(count), .o_wrap(wrap)
    );

    always #20 clk = ~clk;

    integer fail_count = 0;

    initial begin
        $dumpfile("tb_counter_mod_n.vcd");
        $dumpvars(0, tb_counter_mod_n);

        #100; reset = 0; enable = 1;

        // Let it count through two full cycles (20 clocks for mod-10)
        repeat (20) @(posedge clk);
        #1;
        if (count !== 0) begin
            $display("FAIL: Expected 0 after 20 clocks, got %0d", count);
            fail_count = fail_count + 1;
        end else
            $display("PASS: Counter wrapped correctly after 20 clocks");

        // Check wrap pulse
        repeat (8) @(posedge clk);  // count = 8
        @(posedge clk); #1;        // count = 9
        if (wrap !== 1) begin
            $display("FAIL: wrap should be 1 at count 9");
            fail_count = fail_count + 1;
        end else
            $display("PASS: wrap asserted at count 9");

        if (fail_count == 0) $display("\n*** ALL TESTS PASSED ***");
        else $display("\n*** %0d FAILURES ***", fail_count);
        $finish;
    end
endmodule
