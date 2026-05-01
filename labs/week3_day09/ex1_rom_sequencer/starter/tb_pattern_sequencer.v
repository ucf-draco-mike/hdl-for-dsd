// tb_pattern_sequencer.v -- Testbench for ROM pattern sequencer
`timescale 1ns / 1ps

module tb_pattern_sequencer;

    reg        clk, reset, next, auto_mode;
    wire [7:0] pattern;
    wire [3:0] index;

    // Fast simulation: CLK_FREQ=100, AUTO_RATE_HZ=10 -> 10 clocks per tick
    pattern_sequencer #(
        .CLK_FREQ     (100),
        .N_PATTERNS   (16),
        .AUTO_RATE_HZ (10)
    ) uut (
        .i_clk       (clk),
        .i_reset     (reset),
        .i_next      (next),
        .i_auto_mode (auto_mode),
        .o_pattern   (pattern),
        .o_index     (index)
    );

    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz sim clock

    integer test_count = 0, fail_count = 0;

    task check(input [3:0] exp_idx, input [7:0] exp_pat, input [159:0] msg);
        begin
            test_count = test_count + 1;
            if (index !== exp_idx || pattern !== exp_pat) begin
                fail_count = fail_count + 1;
                $display("FAIL [%0s]: idx=%0d (exp %0d) pat=0x%02X (exp 0x%02X)",
                         msg, index, exp_idx, pattern, exp_pat);
            end
        end
    endtask

    initial begin
        $dumpfile("pattern_seq.vcd");
        $dumpvars(0, tb_pattern_sequencer);

        reset = 1; next = 0; auto_mode = 0;
        @(posedge clk); @(posedge clk);
        reset = 0;
        @(posedge clk); #1;

        // -- Test 1: Reset state --
        // TODO: Verify index=0, pattern=0x01 after reset
        //       Use: check(4'd0, 8'h01, "reset state");
        //
        // ---- YOUR CODE HERE ----

        // -- Test 2: Manual advance through all 16 patterns --
        // TODO: Pulse i_next for one clock, then check each pattern
        //       Expected sequence from patterns.hex:
        //       idx 0=0x01, 1=0x12, 2=0x24, 3=0x38, ...
        //       After idx 15 (0xF0), should wrap to idx 0 (0x01)
        //
        // ---- YOUR CODE HERE ----

        // -- Test 3: Auto-advance mode --
        // TODO: Set auto_mode=1, wait for tick period (10 clocks),
        //       verify pattern advances automatically.
        //       Run for several ticks and check at least 3 advances.
        //
        // ---- YOUR CODE HERE ----

        // -- Report --
        $display("\n=================================");
        if (fail_count == 0)
            $display("ALL %0d TESTS PASSED", test_count);
        else
            $display("FAILED %0d / %0d tests", fail_count, test_count);
        $display("=================================\n");
        $finish;
    end
endmodule
