// =============================================================================
// tb_shift_register_demo.v -- Compares blocking vs nonblocking shift behavior.
// Drives a single 1-cycle pulse and shows how nonblocking creates a pipeline,
// while blocking collapses to a single-cycle latency.
// =============================================================================
`timescale 1ns/1ps

module tb_shift_register_demo;
    reg  clk = 1'b0, d = 1'b0;
    wire q_block, q_nonblock;

    shift_blocking    dut_b (.i_clk(clk), .i_d(d), .o_q(q_block));
    shift_nonblocking dut_n (.i_clk(clk), .i_d(d), .o_q(q_nonblock));

    always #5 clk = ~clk;

    integer fails = 0;
    task check(input act, input exp, input [255:0] name);
        if (act !== exp) begin
            $display("FAIL: %0s exp=%b got=%b", name, exp, act);
            fails = fails + 1;
        end else
            $display("PASS: %0s = %b", name, act);
    endtask

    initial begin
        $dumpfile("tb_shift_register_demo.vcd");
        $dumpvars(0, tb_shift_register_demo);

        // Single pulse on d for one clock period
        @(posedge clk); d = 1'b1;
        @(posedge clk); d = 1'b0;
        // After 1 posedge: blocking shows pulse on q_block (collapsed)
        #1;
        check(q_block,    1'b1, "q_block on first edge (collapsed)");

        // Allow 3 more clocks; nonblocking should ripple through
        @(posedge clk); #1;  // 2nd
        @(posedge clk); #1;  // 3rd: q_nonblock gets pulse here
        check(q_nonblock, 1'b1, "q_nonblock after 3 cycles (pipeline)");

        if (fails == 0) $display("=== 2 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
