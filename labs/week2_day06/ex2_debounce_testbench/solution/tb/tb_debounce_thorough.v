// =============================================================================
// tb_debounce_thorough.v -- Thorough Debounce Testbench (Solution)
// Day 6, Exercise 2
// =============================================================================

`timescale 1ns / 1ps

module tb_debounce_thorough;

    reg  clk, bouncy;
    wire clean;

    localparam THRESHOLD = 20;

    debounce #(.CLKS_TO_STABLE(THRESHOLD)) uut (
        .i_clk(clk), .i_bouncy(bouncy), .o_clean(clean)
    );

    initial clk = 0;
    always #20 clk = ~clk;

    integer test_count = 0, fail_count = 0;

    task wait_clks;
        input integer n;
        begin repeat (n) @(posedge clk); end
    endtask

    task check;
        input expected;
        input [80*8-1:0] label;  // up to 80 chars
    begin
        test_count = test_count + 1;
        #1;  // small delay after clock edge
        if (clean !== expected) begin
            fail_count = fail_count + 1;
            $display("FAIL [%0t]: %0s -- expected clean=%b, got %b",
                     $time, label, expected, clean);
        end else begin
            $display("PASS [%0t]: %0s (clean=%b)", $time, label, clean);
        end
    end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_debounce_thorough);
        bouncy = 1;
        wait_clks(10);

        // Scenario 1: Clean press
        $display("--- Scenario 1: Clean Press ---");
        bouncy = 0;
        wait_clks(THRESHOLD + 5);  // +5 for synchronizer latency
        check(0, "clean should be 0 after threshold");

        // Scenario 2: Bounce rejection
        $display("--- Scenario 2: Bounce Rejection ---");
        bouncy = 1; wait_clks(THRESHOLD + 5);  // release first
        check(1, "clean should be 1 (released)");
        // Now bounce 6 times within threshold, then settle low
        bouncy = 0; wait_clks(3);
        bouncy = 1; wait_clks(2);
        bouncy = 0; wait_clks(4);
        bouncy = 1; wait_clks(2);
        bouncy = 0; wait_clks(3);
        bouncy = 1; wait_clks(2);
        bouncy = 0;  // settle
        wait_clks(THRESHOLD + 5);
        check(0, "clean should be 0 after bouncy press");

        // Scenario 3: Glitch rejection
        $display("--- Scenario 3: Glitch Rejection ---");
        bouncy = 1;
        wait_clks(THRESHOLD + 5);
        check(1, "clean should be 1 (released)");
        bouncy = 0;
        wait_clks(THRESHOLD / 2);  // glitch: shorter than threshold
        bouncy = 1;
        wait_clks(THRESHOLD + 5);
        check(1, "clean should still be 1 (glitch rejected)");

        // Scenario 4: Clean release
        $display("--- Scenario 4: Clean Release ---");
        bouncy = 0;
        wait_clks(THRESHOLD + 5);
        check(0, "clean should be 0 (pressed)");
        bouncy = 1;
        wait_clks(THRESHOLD + 5);
        check(1, "clean should be 1 (released)");

        $display("");
        $display("========================================");
        $display("Debounce: %0d / %0d tests PASSED",
                 test_count - fail_count, test_count);
        if (fail_count > 0)
            $display("  *** %0d FAILURES ***", fail_count);
        else
            $display("  All tests passed!");
        $display("========================================");
        $finish;
    end

endmodule
