// =============================================================================
// tb_latch_bugs.v -- Baseline TB for latch_bugs -- verifies latch-free behavior (Day 3, Ex 1)
// Accelerated HDL for Digital System Design - Dr. Mike Borowczak - ECE - CECS - UCF
// =============================================================================
`timescale 1ns/1ps

module tb_latch_bugs;
    reg  [1:0] sel;
    reg  [3:0] a, b, c;
    reg        enable;
    wire [3:0] result;
    wire       flag;
    wire [2:0] encoded;

    latch_bugs dut (
        .i_sel(sel), .i_a(a), .i_b(b), .i_c(c),
        .i_enable(enable),
        .o_result(result), .o_flag(flag), .o_encoded(encoded)
    );

    integer pass_count = 0, fail_count = 0;
    integer i;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_latch_bugs);

        // Test Bug 1 fix: enable gating
        a = 4'd5; b = 4'd3; c = 4'd0;

        enable = 1; sel = 0; #1;
        if (result === (a + b)) begin $display("PASS: enable=1 result=%0d", result); pass_count=pass_count+1; end
        else begin $display("FAIL: enable=1 result=%0d expected %0d", result, a+b); fail_count=fail_count+1; end

        enable = 0; #1;
        if (result === 4'b0000) begin $display("PASS: enable=0 result=0"); pass_count=pass_count+1; end
        else begin $display("FAIL: enable=0 result=%0d expected 0", result); fail_count=fail_count+1; end

        // Test Bug 2 fix: all sel values produce valid flag
        enable = 1;
        for (i = 0; i < 4; i = i + 1) begin
            sel = i[1:0]; #1;
            if (flag !== 1'bx) begin
                $display("PASS: sel=%b flag=%b (no X -- no latch)", sel, flag);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: sel=%b flag=%bx (latch detected!)", sel, flag);
                fail_count = fail_count + 1;
            end
        end

        // Test Bug 3 fix: all sel values produce valid encoded
        for (i = 0; i < 4; i = i + 1) begin
            sel = i[1:0]; #1;
            if (encoded !== 3'bxxx && encoded !== 3'bx) begin
                $display("PASS: sel=%b encoded=%b (no X)", sel, encoded);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: sel=%b encoded=%b (X detected -- latch?)", sel, encoded);
                fail_count = fail_count + 1;
            end
        end

        $display("\n=== tb_latch_bugs: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
