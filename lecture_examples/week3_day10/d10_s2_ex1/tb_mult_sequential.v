// =============================================================================
// tb_mult_sequential.v — Smoke test for shift-and-add sequential multiplier
// Day 10: Numerical Architectures & Design Trade-offs
// =============================================================================
// Verifies the W-cycle handshake and the final product across a handful of
// representative cases. Defaults to W=8 to keep waveforms readable; override
// with -DTB_W=16 from the Makefile.
// =============================================================================
`timescale 1ns/1ps

`ifndef TB_W
`define TB_W 8
`endif

module tb_mult_sequential;
    localparam W = `TB_W;

    reg              clk = 1'b0;
    reg              rst = 1'b1;
    reg              start = 1'b0;
    reg  [W-1:0]     a = 0;
    reg  [W-1:0]     b = 0;
    wire [2*W-1:0]   product;
    wire             done;

    integer pass = 0;
    integer fail = 0;

    mult_sequential #(.W(W)) dut (
        .i_clk     (clk),
        .i_reset   (rst),
        .i_start   (start),
        .i_a       (a),
        .i_b       (b),
        .o_product (product),
        .o_done    (done)
    );

    always #5 clk = ~clk;

    task run_case;
        input [W-1:0]   ta, tb;
        input [2*W-1:0] expected;
    begin
        @(posedge clk); #1;
        a     = ta;
        b     = tb;
        start = 1'b1;
        @(posedge clk); #1;
        start = 1'b0;
        // Wait for done (W cycles + handshake)
        wait (done == 1'b1);
        @(posedge clk); #1;
        if (product === expected) begin
            $display("PASS: %0d * %0d = %0d", ta, tb, product);
            pass = pass + 1;
        end else begin
            $display("FAIL: %0d * %0d = %0d (expected %0d)",
                     ta, tb, product, expected);
            fail = fail + 1;
        end
    end
    endtask

    initial begin
        $dumpfile("tb_mult_sequential.vcd");
        $dumpvars(0, tb_mult_sequential);
        $display("\n=== mult_sequential testbench (W=%0d) ===\n", W);

        // Release reset.
        repeat (3) @(posedge clk);
        rst = 1'b0;
        @(posedge clk);

        run_case(8'd0,   8'd0,   16'd0);
        run_case(8'd1,   8'd0,   16'd0);
        run_case(8'd3,   8'd5,   16'd15);
        run_case(8'd13,  8'd17,  16'd221);
        run_case(8'd255, 8'd255, 16'd65025);

        $display("\n=== %0d passed, %0d failed ===\n", pass, fail);
        if (fail == 0) $display("*** ALL TESTS PASSED ***\n");
        $finish;
    end

    initial begin
        #200_000;
        $display("FAIL: simulation timed out");
        $finish;
    end

endmodule
