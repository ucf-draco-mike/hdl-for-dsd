// =============================================================================
// tb_pattern_sequencer.v — extracted from day09_ex03_pattern_sequencer.v
// =============================================================================
`timescale 1ns/1ps

module tb_pattern_sequencer;
    reg        clk = 0, reset = 1, next = 0;
    wire [7:0] pattern;

    pattern_sequencer #(
        .DEPTH(16), .WIDTH(8),
        .MEM_FILE("pattern.mem")
    ) uut (
        .i_clk(clk), .i_reset(reset),
        .i_next(next), .o_pattern(pattern)
    );

    always #20 clk = ~clk;

    integer i, test_count = 0, fail_count = 0;

    initial begin
        $dumpfile("tb_pattern_seq.vcd");
        $dumpvars(0, tb_pattern_sequencer);
        #100; reset = 0;
        @(posedge clk); #1;

        $display("\n=== Pattern Sequencer Testbench ===\n");

        // Verify first pattern at addr 0 (walking 1)
        test_count = test_count + 1;
        if (pattern !== 8'b00000001) begin
            $display("FAIL: addr 0 expected 00000001, got %b", pattern);
            fail_count = fail_count + 1;
        end else
            $display("PASS: addr 0 = %b", pattern);

        // Step through all 16 patterns
        for (i = 1; i < 16; i = i + 1) begin
            next = 1; @(posedge clk); next = 0; @(posedge clk); #1;
            test_count = test_count + 1;
            $display("  addr %0d = %b", i, pattern);
        end

        // Verify wrap-around
        next = 1; @(posedge clk); next = 0; @(posedge clk); #1;
        test_count = test_count + 1;
        if (pattern !== 8'b00000001) begin
            $display("FAIL: wrap — expected 00000001, got %b", pattern);
            fail_count = fail_count + 1;
        end else
            $display("PASS: Wrapped back to addr 0");

        $display("\n=== SUMMARY: %0d/%0d passed ===",
                 test_count - fail_count, test_count);
        if (fail_count == 0) $display("*** ALL TESTS PASSED ***\n");
        else $display("*** %0d FAILURES ***\n", fail_count);
        $finish;
    end
endmodule
