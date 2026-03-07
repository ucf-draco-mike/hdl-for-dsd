// =============================================================================
// tb_led_blinker.v — Baseline TB for led_blinker — verifies counter toggles (Day 4, Ex 3)
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
`timescale 1ns/1ps

module tb_led_blinker;
    parameter CLK_PERIOD = 40;  // 25 MHz

    reg  clk = 0;
    wire led1, led2, led3, led4;

    led_blinker dut (
        .i_clk(clk),
        .o_led1(led1), .o_led2(led2), .o_led3(led3), .o_led4(led4)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    integer pass_count = 0, fail_count = 0;
    reg [3:0] prev_leds;
    integer toggle_count;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_led_blinker);

        // Run for enough cycles to see LED4 (fastest) toggle several times
        // LED4 = bit[20] at 25 MHz would be too slow to sim; but the solution
        // uses bit[20..23], so let's just verify the outputs aren't stuck.
        // We run 2^12 cycles and check that at least one LED changed.

        prev_leds = {led1, led2, led3, led4};
        toggle_count = 0;

        repeat (4096) begin
            @(posedge clk); #1;
            if ({led1, led2, led3, led4} !== prev_leds) begin
                toggle_count = toggle_count + 1;
                prev_leds = {led1, led2, led3, led4};
            end
        end

        if (toggle_count > 0) begin
            $display("PASS: LEDs toggled %0d times in 4096 cycles", toggle_count);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: LEDs never toggled in 4096 cycles — counter stuck?");
            fail_count = fail_count + 1;
        end

        // Verify all outputs are valid logic levels
        if (led1 !== 1'bx && led2 !== 1'bx && led3 !== 1'bx && led4 !== 1'bx) begin
            $display("PASS: all LED outputs are valid logic levels");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: one or more LED outputs are X");
            fail_count = fail_count + 1;
        end

        $display("\n=== tb_led_blinker: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
