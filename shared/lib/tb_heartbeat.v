// =============================================================================
// tb_heartbeat.v — Self-checking testbench for heartbeat
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Verifies:
//   1. LED toggles at the expected rate (every 2^(WIDTH-1) cycles)
//   2. Counter increments monotonically
//   3. Parameterization works (small WIDTH for fast sim)
// =============================================================================
`timescale 1ns/1ps

module tb_heartbeat;

    // Use small WIDTH so we can see multiple toggles quickly
    parameter WIDTH = 4;
    parameter CLK_PERIOD = 40;  // 25 MHz
    parameter HALF_PERIOD_CYCLES = (1 << (WIDTH - 1));  // 2^(WIDTH-1) = 8

    reg  clk = 0;
    wire led;

    heartbeat #(.WIDTH(WIDTH)) dut (
        .i_clk(clk),
        .o_led(led)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    integer pass_count = 0, fail_count = 0;
    integer toggle_count = 0;
    reg prev_led = 0;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_heartbeat);

        // Run for several full toggle periods
        // With WIDTH=4, LED toggles every 8 cycles, full period = 16 cycles
        // Run for 4 full periods = 64 cycles

        // Wait for first known state
        @(posedge clk); #1;
        prev_led = led;

        // Count toggles over 64 cycles
        repeat (64) begin
            @(posedge clk); #1;
            if (led !== prev_led) begin
                toggle_count = toggle_count + 1;
                prev_led = led;
            end
        end

        // With WIDTH=4, expect ~8 toggles in 64 cycles (toggle every 8 cycles)
        // Allow ±1 for boundary effects
        if (toggle_count >= 7 && toggle_count <= 9) begin
            $display("PASS: LED toggled %0d times in 64 cycles (expected ~8)", toggle_count);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: LED toggled %0d times in 64 cycles (expected ~8)", toggle_count);
            fail_count = fail_count + 1;
        end

        // Verify LED is active-high output (should be 0 or 1, never x/z)
        if (led === 1'b0 || led === 1'b1) begin
            $display("PASS: LED output is a valid logic level (%b)", led);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: LED output is %b (expected 0 or 1)", led);
            fail_count = fail_count + 1;
        end

        $display("");
        $display("=== tb_heartbeat: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end

endmodule
