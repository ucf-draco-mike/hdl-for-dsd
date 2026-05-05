// =============================================================================
// tb_pattern_sequencer.v — Self-checking testbench for pattern_sequencer
// Day 9 · Topic 9.4: Practical Memory Applications · Demo example 3
// =============================================================================
// Uses a tiny STEP_LEN for simulation (so the address counter advances
// quickly), walks through all 16 entries, then confirms wrap-around.
// VCD: tb_pattern_sequencer.vcd
//
// Timing note:
//   With STEP_LEN = 4 and a synchronous ROM (1-cycle read latency), each
//   pattern is visible on o_leds for STEP_LEN cycles. Between two visible
//   patterns there are exactly STEP_LEN clock edges.
// =============================================================================

`timescale 1ns/1ps

module tb_pattern_sequencer;
    localparam STEP_LEN    = 4;
    localparam PATTERN_LEN = 16;

    reg        clk = 0;
    reg        reset;
    wire [7:0] leds;

    pattern_sequencer #(
        .STEP_LEN   (STEP_LEN),
        .PATTERN_LEN(PATTERN_LEN),
        .INIT_FILE  ("pattern.hex")
    ) uut (
        .i_clk(clk), .i_reset(reset), .o_leds(leds)
    );

    always #20 clk = ~clk;   // 40 ns period

    integer i, fail_count = 0;
    reg [7:0] expected [0:PATTERN_LEN-1];

    initial begin
        // Mirror pattern.hex (walking-1 right, then walking-1 left)
        expected[ 0] = 8'h01; expected[ 1] = 8'h02;
        expected[ 2] = 8'h04; expected[ 3] = 8'h08;
        expected[ 4] = 8'h10; expected[ 5] = 8'h20;
        expected[ 6] = 8'h40; expected[ 7] = 8'h80;
        expected[ 8] = 8'h80; expected[ 9] = 8'h40;
        expected[10] = 8'h20; expected[11] = 8'h10;
        expected[12] = 8'h08; expected[13] = 8'h04;
        expected[14] = 8'h02; expected[15] = 8'h01;
    end

    initial begin
        $dumpfile("tb_pattern_sequencer.vcd");
        $dumpvars(0, tb_pattern_sequencer);

        // Hold reset for a few cycles, then release synchronously.
        reset = 1;
        repeat (4) @(posedge clk);
        @(negedge clk);
        reset = 0;

        $display("\n=== pattern_sequencer testbench ===\n");

        // After the first posedge with reset=0, the synchronous ROM clocks
        // mem[0] onto o_leds.
        @(posedge clk); #1;
        if (leds !== expected[0]) begin
            $display("FAIL: step 0 expected %h, got %h", expected[0], leds);
            fail_count = fail_count + 1;
        end else
            $display("PASS: step 0 = %h", leds);

        // Each subsequent step appears STEP_LEN cycles later.
        for (i = 1; i < PATTERN_LEN; i = i + 1) begin
            repeat (STEP_LEN) @(posedge clk);
            #1;
            if (leds !== expected[i]) begin
                $display("FAIL: step %0d expected %h, got %h",
                         i, expected[i], leds);
                fail_count = fail_count + 1;
            end else
                $display("PASS: step %0d = %h", i, leds);
        end

        // Confirm wrap-around to expected[0].
        repeat (STEP_LEN) @(posedge clk);
        #1;
        if (leds !== expected[0]) begin
            $display("FAIL: wrap expected %h, got %h", expected[0], leds);
            fail_count = fail_count + 1;
        end else
            $display("PASS: wrap-around back to step 0 (%h)", leds);

        $display("\n=== %0d/%0d passed ===",
                 (PATTERN_LEN + 1) - fail_count, PATTERN_LEN + 1);
        if (fail_count == 0) $display("*** ALL TESTS PASSED ***\n");
        else                 $display("*** %0d FAILURES ***\n", fail_count);
        $finish;
    end
endmodule
