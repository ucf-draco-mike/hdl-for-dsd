// =============================================================================
// tb_shift_register_demo.v -- Compares blocking vs nonblocking pipeline.
//
// Drives a single 1-cycle pulse on `d` and prints the (a, b, c) state of
// the blocking and nonblocking pipelines after each rising edge. With
// nonblocking the pulse walks through the chain (staircase pattern); with
// blocking it collapses to a single cycle on the first edge.
// =============================================================================
`timescale 1ns/1ps

module tb_shift_register_demo;
    reg  clk = 1'b0, d = 1'b0;
    wire q_block, q_nonblock;

    shift_blocking    dut_b (.i_clk(clk), .i_d(d), .o_q(q_block));
    shift_nonblocking dut_n (.i_clk(clk), .i_d(d), .o_q(q_nonblock));

    always #5 clk = ~clk;  // 100 MHz tb clock

    integer fails = 0;
    task check(input ok, input [255:0] name);
        if (!ok) begin $display("FAIL: %0s", name); fails = fails + 1; end
        else      $display("PASS: %0s", name);
    endtask

    initial begin
        $dumpfile("tb_shift_register_demo.vcd");
        $dumpvars(0, tb_shift_register_demo);

        // Settle through reset-equivalent — drive d=0 for 2 edges
        @(posedge clk); #1;
        @(posedge clk); #1;

        // Single-cycle pulse on d
        d = 1'b1;
        @(posedge clk); #1;
        $display("Cycle 1: blocking a=%0b b=%0b c=%0b | nb a=%0b b=%0b c=%0b",
                 dut_b.r_a, dut_b.r_b, q_block,
                 dut_n.r_a, dut_n.r_b, q_nonblock);
        // Blocking collapses: a=b=c=1 on this very edge.
        check(q_block === 1'b1,  "blocking collapses (c=1 on cycle 1)");
        check(q_nonblock === 1'b0,"nonblocking holds (c=0 on cycle 1)");

        d = 1'b0;
        @(posedge clk); #1;
        $display("Cycle 2: blocking a=%0b b=%0b c=%0b | nb a=%0b b=%0b c=%0b",
                 dut_b.r_a, dut_b.r_b, q_block,
                 dut_n.r_a, dut_n.r_b, q_nonblock);
        check(dut_n.r_b === 1'b1, "nonblocking pulse reached b on cycle 2");

        @(posedge clk); #1;
        $display("Cycle 3: blocking a=%0b b=%0b c=%0b | nb a=%0b b=%0b c=%0b",
                 dut_b.r_a, dut_b.r_b, q_block,
                 dut_n.r_a, dut_n.r_b, q_nonblock);
        check(q_nonblock === 1'b1,"nonblocking pulse reached c on cycle 3");

        @(posedge clk); #1;
        $display("Cycle 4: blocking a=%0b b=%0b c=%0b | nb a=%0b b=%0b c=%0b",
                 dut_b.r_a, dut_b.r_b, q_block,
                 dut_n.r_a, dut_n.r_b, q_nonblock);
        check(q_nonblock === 1'b0,"nonblocking pulse cleared on cycle 4");

        if (fails == 0) $display("=== 5 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
