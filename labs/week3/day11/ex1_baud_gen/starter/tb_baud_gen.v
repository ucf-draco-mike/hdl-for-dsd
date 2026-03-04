// =============================================================================
// tb_baud_gen.v — Testbench for Baud Rate Generator
// Day 11, Exercise 1
// =============================================================================

`timescale 1ns / 1ps

module tb_baud_gen;

    reg  clk, reset, enable;
    wire tick;

    // Use small values for fast simulation
    localparam CLK_FREQ  = 100;
    localparam BAUD_RATE = 10;
    // Expected: tick every 10 clock cycles

    baud_gen #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .i_clk(clk), .i_reset(reset),
        .i_enable(enable), .o_tick(tick)
    );

    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz sim clock

    integer tick_count, cycle_count;
    integer test_count = 0, fail_count = 0;

    initial begin
        $dumpfile("baud_gen.vcd");
        $dumpvars(0, tb_baud_gen);

        reset = 1; enable = 0;
        repeat (3) @(posedge clk);
        reset = 0; enable = 1;

        // TODO: Count cycles between ticks
        //   Run for 50 clock cycles, count how many ticks occur
        //   Expected: 5 ticks in 50 cycles (one every 10 cycles)
        //   Verify tick is exactly 1 cycle wide

        // ---- YOUR TEST CODE HERE ----

        tick_count = 0;
        for (cycle_count = 0; cycle_count < 50; cycle_count = cycle_count + 1) begin
            @(posedge clk); #1;
            if (tick) tick_count = tick_count + 1;
        end

        test_count = test_count + 1;
        if (tick_count != 5) begin
            fail_count = fail_count + 1;
            $display("FAIL: Expected 5 ticks in 50 cycles, got %0d", tick_count);
        end else begin
            $display("PASS: Tick count correct (%0d ticks)", tick_count);
        end

        // Test disable
        enable = 0;
        tick_count = 0;
        for (cycle_count = 0; cycle_count < 20; cycle_count = cycle_count + 1) begin
            @(posedge clk); #1;
            if (tick) tick_count = tick_count + 1;
        end

        test_count = test_count + 1;
        if (tick_count != 0) begin
            fail_count = fail_count + 1;
            $display("FAIL: Ticks while disabled (%0d)", tick_count);
        end else begin
            $display("PASS: No ticks while disabled");
        end

        $display("\n========================================");
        $display("Baud Gen: %0d/%0d tests passed",
                 test_count - fail_count, test_count);
        $display("========================================");
        $finish;
    end

endmodule
