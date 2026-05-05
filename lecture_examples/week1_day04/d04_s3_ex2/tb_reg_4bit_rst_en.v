// =============================================================================
// tb_reg_4bit_rst_en.v -- Self-checking testbench for the 4-bit register with
// synchronous reset and clock enable. Drives reset, enable, and a sequence of
// data values, then verifies the register holds when disabled and clears on
// reset. Used by the d04_s3 "Reset + Enable Register in Action" demo.
// =============================================================================
`timescale 1ns/1ps

module tb_reg_4bit_rst_en;
    reg        clk = 1'b0, reset = 1'b1, enable = 1'b0;
    reg  [3:0] d = 4'h0;
    wire [3:0] q;

    reg_4bit_rst_en dut (
        .i_clk(clk), .i_reset(reset), .i_enable(enable), .i_d(d), .o_q(q)
    );

    always #5 clk = ~clk;  // 100 MHz tb clock

    integer fails = 0;
    task check(input cond, input [255:0] name);
        if (!cond) begin $display("FAIL: %0s (q=%h)", name, q); fails = fails + 1; end
        else      $display("PASS: %0s", name);
    endtask

    initial begin
        $dumpfile("tb_reg_4bit_rst_en.vcd");
        $dumpvars(0, tb_reg_4bit_rst_en);

        // 1) Synchronous reset
        @(posedge clk); #1; check(q === 4'h0, "reset -> q=0");

        // 2) Disabled register holds through arbitrary d
        reset = 1'b0; enable = 1'b0; d = 4'hA;
        @(posedge clk); #1; check(q === 4'h0, "en=0, d=A -> q unchanged (hold)");
        d = 4'h5;
        @(posedge clk); #1; check(q === 4'h0, "en=0, d=5 -> q still unchanged");
        d = 4'hF;
        @(posedge clk); #1; check(q === 4'h0, "en=0, d=F -> still hold");

        // 3) Enable + load
        enable = 1'b1; d = 4'h5;
        @(posedge clk); #1; check(q === 4'h5, "en=1, d=5 -> q=5");
        d = 4'h9;
        @(posedge clk); #1; check(q === 4'h9, "en=1, d=9 -> q=9");
        d = 4'hC;
        @(posedge clk); #1; check(q === 4'hC, "en=1, d=C -> q=C");

        // 4) Disable holds the new value
        enable = 1'b0; d = 4'h0;
        @(posedge clk); #1; check(q === 4'hC, "en=0 after load -> q holds C");
        @(posedge clk); #1; check(q === 4'hC, "en=0 next cycle -> still C");

        // 5) Reset wins over enable
        reset = 1'b1; enable = 1'b1; d = 4'hF;
        @(posedge clk); #1; check(q === 4'h0, "reset+en -> q=0 again (reset wins)");

        // 6) Resume normal operation after reset
        reset = 1'b0; d = 4'h7;
        @(posedge clk); #1; check(q === 4'h7, "post-reset, en=1 -> q=7");

        // 7) Disable again to confirm the new value also holds cleanly
        enable = 1'b0; d = 4'h0;
        @(posedge clk); #1; check(q === 4'h7, "en=0 after post-reset load -> q holds 7");

        if (fails == 0) $display("=== 12 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
