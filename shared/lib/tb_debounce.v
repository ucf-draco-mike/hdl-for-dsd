// =============================================================================
// tb_debounce.v -- Self-checking testbench for debounce module
// Accelerated HDL for Digital System Design - Dr. Mike Borowczak - ECE - CECS - UCF
// =============================================================================
`timescale 1ns/1ps
module tb_debounce;
    parameter CLKS_TO_STABLE = 20;    // Small for fast simulation
    parameter CLK_PERIOD     = 40;    // 25 MHz

    reg  i_clk    = 0;
    reg  i_bouncy = 0;
    wire o_clean;

    debounce #(.CLKS_TO_STABLE(CLKS_TO_STABLE)) dut (
        .i_clk    (i_clk),
        .i_bouncy (i_bouncy),
        .o_clean  (o_clean)
    );

    always #(CLK_PERIOD/2) i_clk = ~i_clk;

    integer pass_count = 0, fail_count = 0;

    task check;
        input expected;
        input [80*8-1:0] name;
        begin
            #1;
            if (o_clean !== expected) begin
                $display("FAIL: %0s -- expected %b got %b", name, expected, o_clean);
                fail_count = fail_count + 1;
            end else begin
                pass_count = pass_count + 1;
            end
        end
    endtask

    task wait_cycles;
        input integer n;
        integer i;
        begin
            for (i = 0; i < n; i = i + 1) @(posedge i_clk);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_debounce);

        i_bouncy = 0;
        wait_cycles(5);

        // Test 1: Stable press (hold > CLKS_TO_STABLE cycles)
        i_bouncy = 1;
        wait_cycles(CLKS_TO_STABLE + 5);
        check(1, "stable press");

        // Test 2: Glitch (pulse shorter than CLKS_TO_STABLE)
        i_bouncy = 0;
        wait_cycles(CLKS_TO_STABLE / 2);
        i_bouncy = 1;
        wait_cycles(2);
        check(1, "glitch rejected");

        // Test 3: Clean release
        i_bouncy = 0;
        wait_cycles(CLKS_TO_STABLE + 5);
        check(0, "stable release");

        // Test 4: Bounce storm
        repeat (8) begin
            i_bouncy = ~i_bouncy;
            wait_cycles(CLKS_TO_STABLE / 3);
        end
        i_bouncy = 0;
        wait_cycles(CLKS_TO_STABLE + 5);
        check(0, "bounce storm resolved");

        $display("\n=== tb_debounce: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
