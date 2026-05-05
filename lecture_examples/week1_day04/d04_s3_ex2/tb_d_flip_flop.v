// =============================================================================
// tb_d_flip_flop.v -- Self-checking testbench for the bare D flip-flop.
//
// Drives `d` through several patterns and verifies that `q` only updates on
// rising clock edges and otherwise holds. Used by the d04_s1 "One-Flop,
// Two-Flop in GTKWave" demo.
// =============================================================================
`timescale 1ns/1ps

module tb_d_flip_flop;
    reg  clk = 1'b0, d = 1'b0;
    wire q;

    d_flip_flop dut (.i_clk(clk), .i_d(d), .o_q(q));

    always #5 clk = ~clk;  // 100 MHz tb clock

    integer fails = 0;
    task check(input ok, input [255:0] name);
        if (!ok) begin $display("FAIL: %0s", name); fails = fails + 1; end
        else      $display("PASS: %0s", name);
    endtask

    initial begin
        $dumpfile("tb_d_flip_flop.vcd");
        $dumpvars(0, tb_d_flip_flop);

        // Capture d=1 on next edge
        d = 1'b1;
        @(posedge clk); #1; check(q === 1'b1, "d=1 -> q=1 after edge");

        // Capture d=0 on next edge
        d = 1'b0;
        @(posedge clk); #1; check(q === 1'b0, "d=0 -> q=0 after edge");

        // q holds through several cycles while d is stable high
        d = 1'b1;
        @(posedge clk); #1; check(q === 1'b1, "d=1 -> q=1 (cycle 1)");
        @(posedge clk); #1; check(q === 1'b1, "q stays through cycle 2");
        @(posedge clk); #1; check(q === 1'b1, "q stays through cycle 3");
        @(posedge clk); #1; check(q === 1'b1, "q stays through cycle 4");

        // Mid-cycle change to d should NOT propagate until next posedge
        #2 d = 1'b0;     // change between edges
        #1 check(q === 1'b1, "q ignores mid-cycle d change (still 1)");
        @(posedge clk); #1; check(q === 1'b0, "next posedge captures d=0");

        if (fails == 0) $display("=== 8 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
