// =============================================================================
// tb_debounce_thorough.v — Thorough Debounce Testbench (Starter)
// Day 6, Exercise 2
// =============================================================================

`timescale 1ns / 1ps

module tb_debounce_thorough;

    reg  clk, bouncy;
    wire clean;

    localparam THRESHOLD = 20;  // short for simulation

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

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_debounce_thorough);
        bouncy = 1;
        wait_clks(10);

        // ---- TODO: Scenario 1 — Clean press ----
        // Set bouncy=0, wait THRESHOLD + sync latency cycles
        // Verify clean transitions to 0

        // ---- TODO: Scenario 2 — Bounce rejection ----
        // First release to 1, then toggle 6+ times within threshold
        // Then settle at 0. Verify clean transitions only once

        // ---- TODO: Scenario 3 — Glitch rejection ----
        // Release bouncy=1, wait for clean=1
        // Then glitch: bouncy=0 for fewer than THRESHOLD clocks, bouncy=1
        // Verify clean never goes to 0

        // ---- TODO: Scenario 4 — Clean release ----
        // Ensure a stable press (clean=0), then release bouncy=1
        // Wait and verify clean returns to 1

        $display("");
        $display("========================================");
        $display("Debounce: %0d / %0d tests PASSED",
                 test_count - fail_count, test_count);
        $display("========================================");
        $finish;
    end

endmodule
