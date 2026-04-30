// =============================================================================
// tb_synchronizer.v — Smoke testbench for the 2-FF synchronizer
// Confirms 2-cycle latency from input change to synced output.
// =============================================================================
`timescale 1ns/1ps

module tb_synchronizer;
    reg  clk = 1'b0, async_in = 1'b0;
    wire sync_out;

    synchronizer dut (
        .i_clk(clk), .i_async_in(async_in), .o_sync_out(sync_out)
    );

    always #5 clk = ~clk;

    integer fails = 0;
    task check(input act, input exp, input [255:0] name);
        if (act !== exp) begin
            $display("FAIL: %0s — expected %b, got %b", name, exp, act);
            fails = fails + 1;
        end else
            $display("PASS: %0s = %b", name, act);
    endtask

    initial begin
        $dumpfile("tb_synchronizer.vcd");
        $dumpvars(0, tb_synchronizer);

        // async_in=0 for 3 posedges -> r_meta=0, r_sync=0 settled
        async_in = 1'b0;
        repeat (3) @(posedge clk);
        #1;
        check(sync_out, 1'b0, "settled idle");

        // Drive async_in high; observe 2-cycle latency
        async_in = 1'b1;
        @(posedge clk); #1;
        check(sync_out, 1'b0, "1 cycle after rise (still 0)");
        @(posedge clk); #1;
        check(sync_out, 1'b1, "2 cycles after rise (synced)");

        // Drive low; check 2-cycle latency for fall
        async_in = 1'b0;
        @(posedge clk); #1;
        check(sync_out, 1'b1, "1 cycle after fall (still 1)");
        @(posedge clk); #1;
        check(sync_out, 1'b0, "2 cycles after fall (synced)");

        if (fails == 0) $display("=== 5 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
