// =============================================================================
// tb_baud_gen.v -- Self-checking testbench for baud_gen
// Accelerated HDL for Digital System Design - Dr. Mike Borowczak - ECE - CECS - UCF
// =============================================================================
// Verifies:
//   1. Tick occurs at the expected period (CLK_FREQ / BAUD_RATE cycles)
//   2. Tick is exactly one clock cycle wide
//   3. Reset clears the counter and output
//   4. Multiple consecutive ticks have consistent spacing
// =============================================================================
`timescale 1ns/1ps

module tb_baud_gen;

    // Use small values so simulation completes quickly
    parameter CLK_FREQ  = 1000;     // 1 kHz "clock"
    parameter BAUD_RATE = 100;      // 100 baud -> expect tick every 10 cycles
    parameter CLK_PERIOD = 1_000_000_000 / CLK_FREQ;  // 1 ms = 1_000_000 ns
    parameter EXPECTED_PERIOD = CLK_FREQ / BAUD_RATE;  // 10 cycles

    reg  clk = 0;
    reg  rst = 1;
    wire tick;

    baud_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) dut (
        .i_clk(clk),
        .i_rst(rst),
        .o_tick(tick)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    integer pass_count = 0, fail_count = 0;
    integer tick_count = 0;
    integer cycle_count = 0;
    integer last_tick_cycle = -1;

    // Monitor ticks
    always @(posedge clk) begin
        if (!rst) cycle_count = cycle_count + 1;
        if (tick) begin
            tick_count = tick_count + 1;
            if (last_tick_cycle >= 0) begin
                if ((cycle_count - last_tick_cycle) == EXPECTED_PERIOD) begin
                    $display("PASS: tick %0d at cycle %0d (spacing=%0d, expected=%0d)",
                             tick_count, cycle_count, cycle_count - last_tick_cycle, EXPECTED_PERIOD);
                    pass_count = pass_count + 1;
                end else begin
                    $display("FAIL: tick %0d at cycle %0d (spacing=%0d, expected=%0d)",
                             tick_count, cycle_count, cycle_count - last_tick_cycle, EXPECTED_PERIOD);
                    fail_count = fail_count + 1;
                end
            end
            last_tick_cycle = cycle_count;
        end
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_baud_gen);

        // Hold reset for 3 cycles
        repeat (3) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Wait for 5 ticks (50+ cycles at our parameters)
        wait (tick_count >= 5);
        @(posedge clk);

        // Test reset mid-operation
        rst = 1;
        @(posedge clk); #1;
        if (tick === 1'b0) begin
            $display("PASS: tick deasserted during reset");
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: tick should be 0 during reset");
            fail_count = fail_count + 1;
        end

        $display("");
        $display("=== tb_baud_gen: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end

    // Safety timeout
    initial begin
        #(CLK_PERIOD * 200);
        $display("TIMEOUT: test did not complete");
        $finish;
    end

endmodule
