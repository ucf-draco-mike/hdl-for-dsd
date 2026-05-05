// =============================================================================
// tb_synchronizer.v -- Smoke testbench for the 2-FF synchronizer
// Verifies 2-cycle latency on rising and falling edges, multi-cycle settling,
// and that brief glitches on the async input do not propagate to o_sync_out.
// Mirrors the slide demo: ends with "=== 10 passed, 0 failed ===".
// =============================================================================
`timescale 1ns/1ps

module tb_synchronizer;
    reg  clk = 1'b0, async_in = 1'b0;
    wire sync_out;

    synchronizer dut (
        .i_clk(clk), .i_async_in(async_in), .o_sync_out(sync_out)
    );

    always #5 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;
    task check;
        input        cond;
        input [511:0] msg;
        begin
            if (cond) begin
                $display("PASS: %0s", msg);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s", msg);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_synchronizer.vcd");
        $dumpvars(0, tb_synchronizer);

        // 1) Settled idle: async=0 long enough to clear both flops.
        async_in = 1'b0;
        repeat (3) @(posedge clk); #1;
        check(sync_out === 1'b0, "settled idle = 0");

        // 2-3) Rising edge propagates with 2-cycle latency.
        async_in = 1'b1;
        @(posedge clk); #1;
        check(sync_out === 1'b0, "1 cycle after rise (still 0)");
        @(posedge clk); #1;
        check(sync_out === 1'b1, "2 cycles after rise (synced high)");

        // 4) Held high — output stays high.
        repeat (3) @(posedge clk); #1;
        check(sync_out === 1'b1, "stable while async held high");

        // 5-6) Falling edge propagates with 2-cycle latency.
        async_in = 1'b0;
        @(posedge clk); #1;
        check(sync_out === 1'b1, "1 cycle after fall (still 1)");
        @(posedge clk); #1;
        check(sync_out === 1'b0, "2 cycles after fall (synced low)");

        // 7) Held low — output stays low.
        repeat (3) @(posedge clk); #1;
        check(sync_out === 1'b0, "stable while async held low");

        // 8) Sub-cycle glitch on async does NOT propagate.
        async_in = 1'b1; #2; async_in = 1'b0;   // narrow pulse, < clock period
        @(posedge clk); #1;
        check(sync_out === 1'b0, "narrow async glitch does not propagate");

        // 9-10) After glitch, two real rising-edge cycles still produce
        //       a clean synchronized high output.
        async_in = 1'b1;
        @(posedge clk); @(posedge clk); #1;
        check(sync_out === 1'b1, "clean rise after glitch settles to 1");
        async_in = 1'b0;
        @(posedge clk); @(posedge clk); #1;
        check(sync_out === 1'b0, "clean fall after glitch settles to 0");

        if (fail_count == 0) $display("\n=== %0d passed, 0 failed ===", pass_count);
        else                 $display("\n=== %0d passed, %0d failed ===", pass_count, fail_count);
        $finish;
    end
endmodule
