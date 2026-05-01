// tb_pattern_sequencer.v -- Testbench for ROM pattern sequencer (SOLUTION)
`timescale 1ns / 1ps

module tb_pattern_sequencer;

    reg        clk, reset, next, auto_mode;
    wire [7:0] pattern;
    wire [3:0] index;

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
    always #5 clk = ~clk;

    integer test_count = 0, fail_count = 0;

    // Expected pattern data (matches patterns.hex)
    reg [7:0] expected [0:15];
    initial begin
        expected[0]  = 8'h01; expected[1]  = 8'h12;
        expected[2]  = 8'h24; expected[3]  = 8'h38;
        expected[4]  = 8'h4C; expected[5]  = 8'h5A;
        expected[6]  = 8'h69; expected[7]  = 8'h75;
        expected[8]  = 8'h8F; expected[9]  = 8'h9E;
        expected[10] = 8'hAD; expected[11] = 8'hBB;
        expected[12] = 8'hC7; expected[13] = 8'hD3;
        expected[14] = 8'hE1; expected[15] = 8'hF0;
    end

    task check(input [3:0] exp_idx, input [7:0] exp_pat, input [255:0] msg);
        begin
            test_count = test_count + 1;
            if (index !== exp_idx || pattern !== exp_pat) begin
                fail_count = fail_count + 1;
                $display("FAIL [%0s]: idx=%0d (exp %0d) pat=0x%02X (exp 0x%02X)",
                         msg, index, exp_idx, pattern, exp_pat);
            end else begin
                $display("PASS [%0s]: idx=%0d pat=0x%02X", msg, index, pattern);
            end
        end
    endtask

    // Pulse i_next for one clock cycle
    task manual_step;
        begin
            @(posedge clk);
            next = 1;
            @(posedge clk);
            next = 0;
            #1;
        end
    endtask

    integer i;

    initial begin
        $dumpfile("pattern_seq.vcd");
        $dumpvars(0, tb_pattern_sequencer);

        reset = 1; next = 0; auto_mode = 0;
        @(posedge clk); @(posedge clk);
        reset = 0;
        @(posedge clk); #1;

        // Test 1: Reset state
        check(4'd0, 8'h01, "reset state");

        // Test 2: Manual advance through all 16 patterns
        $display("\n--- Manual advance ---");
        for (i = 1; i < 16; i = i + 1) begin
            manual_step;
            check(i[3:0], expected[i], "manual advance");
        end

        // Test 3: Wrap-around
        manual_step;
        check(4'd0, 8'h01, "wrap to 0");

        // Test 4: Auto-advance mode
        $display("\n--- Auto-advance mode ---");
        reset = 1;
        @(posedge clk); @(posedge clk);
        reset = 0;
        @(posedge clk); #1;
        check(4'd0, 8'h01, "auto reset");

        auto_mode = 1;
        // Wait for 3 auto-ticks (10 clocks each = 30 clocks)
        repeat(10) @(posedge clk); #1;
        check(4'd1, 8'h12, "auto tick 1");

        repeat(10) @(posedge clk); #1;
        check(4'd2, 8'h24, "auto tick 2");

        repeat(10) @(posedge clk); #1;
        check(4'd3, 8'h38, "auto tick 3");

        // Report
        $display("\n=================================");
        if (fail_count == 0)
            $display("ALL %0d TESTS PASSED", test_count);
        else
            $display("FAILED %0d / %0d tests", fail_count, test_count);
        $display("=================================\n");
        $finish;
    end
endmodule
