// =============================================================================
// tb_d_flip_flop.v -- Smoke testbench for d_flip_flop with sync reset + enable
// =============================================================================
`timescale 1ns/1ps

module tb_d_flip_flop;
    reg  clk = 1'b0, reset = 1'b1, enable = 1'b0, d = 1'b0;
    wire q;

    d_flip_flop dut (
        .i_clk(clk), .i_reset(reset), .i_enable(enable), .i_d(d), .o_q(q)
    );

    always #5 clk = ~clk;

    integer fails = 0;
    task check(input ok, input [255:0] name);
        if (!ok) begin $display("FAIL: %0s", name); fails = fails + 1; end
        else      $display("PASS: %0s", name);
    endtask

    initial begin
        $dumpfile("tb_d_flip_flop.vcd");
        $dumpvars(0, tb_d_flip_flop);

        @(posedge clk); #1; check(q===1'b0, "reset -> q=0");

        reset = 1'b0; enable = 1'b1; d = 1'b1;
        @(posedge clk); #1; check(q===1'b1, "en+d=1 -> q=1");

        d = 1'b0;
        @(posedge clk); #1; check(q===1'b0, "en+d=0 -> q=0");

        d = 1'b1; enable = 1'b0;
        @(posedge clk); #1; check(q===1'b0, "en=0 -> hold q=0 (no latch warning)");

        reset = 1'b1; enable = 1'b1;
        @(posedge clk); #1; check(q===1'b0, "sync reset clears q");

        if (fails == 0) $display("=== 5 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
