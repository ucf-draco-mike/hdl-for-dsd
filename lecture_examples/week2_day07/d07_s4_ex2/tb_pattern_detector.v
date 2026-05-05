// =============================================================================
// tb_pattern_detector.v -- self-checking testbench for "1011" Moore detector
// =============================================================================
// Covers:
//   1. Reset -> S0
//   2. Exact match: "1011"
//   3. Near-miss:   "1010" (no match)
//   4. Overlap:     "10110111" (two back-to-back matches)
//   5. Long gap:    runs of zeros and ones do not trigger
// =============================================================================
`timescale 1ns/1ps

module tb_pattern_detector;

    reg  clk = 1'b0;
    reg  reset = 1'b1;
    reg  bit_in = 1'b0;
    wire detected;

    pattern_detector uut (
        .i_clk      (clk),
        .i_reset    (reset),
        .i_bit      (bit_in),
        .o_detected (detected)
    );

    always #5 clk = ~clk;   // 100 MHz sim clock

    integer fails = 0;
    integer passes = 0;

    // Drive a bit on the next clock edge, then settle.
    task send;
        input val;
        begin
            bit_in = val;
            @(posedge clk);
            #1;
        end
    endtask

    // Check o_detected after the bit just sent has been registered.
    task expect_detected;
        input         exp;
        input [511:0] label;     // 64 chars — long enough for any label
        begin
            if (detected !== exp) begin
                $display("FAIL: %0s -- got %b, expected %b", label, detected, exp);
                fails = fails + 1;
            end else begin
                $display("PASS: %0s", label);
                passes = passes + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_pattern_detector.vcd");
        $dumpvars(0, tb_pattern_detector);

        $display("\n=== Pattern Detector ('1011', Moore) Testbench ===\n");

        // ---- Reset ----
        @(posedge clk); @(posedge clk);
        reset = 1'b0;
        @(posedge clk); #1;
        expect_detected(1'b0, "reset -> S0 (no detect)");

        // ---- Exact match: "1011" ----
        send(1'b1); expect_detected(1'b0, "after '1'   (S1)");
        send(1'b0); expect_detected(1'b0, "after '10'  (S10)");
        send(1'b1); expect_detected(1'b0, "after '101' (S101)");
        send(1'b1); expect_detected(1'b1, "detects '1011'");

        // ---- Near-miss: "1010" should NOT detect after the prior match ----
        // Currently in SMATCH; sending '0' -> S10
        send(1'b0); expect_detected(1'b0, "after match + '0' (S10)");
        send(1'b1); expect_detected(1'b0, "after '...101' (S101)");
        send(1'b0); expect_detected(1'b0, "ignores '1010' (no match)");

        // ---- Reset back to S0 to re-arm cleanly ----
        reset = 1'b1; bit_in = 1'b0;
        @(posedge clk); @(posedge clk);
        reset = 1'b0;
        @(posedge clk); #1;

        // ---- Overlap: "10110111" should detect TWICE ----
        send(1'b1); expect_detected(1'b0, "overlap: after '1'");
        send(1'b0); expect_detected(1'b0, "overlap: after '10'");
        send(1'b1); expect_detected(1'b0, "overlap: after '101'");
        send(1'b1); expect_detected(1'b1, "overlap: detects first '1011'");
        send(1'b0); expect_detected(1'b0, "overlap: after match + '0' (S10)");
        send(1'b1); expect_detected(1'b0, "overlap: after '...101' (S101)");
        send(1'b1); expect_detected(1'b1, "overlap: detects second '1011'");

        // ---- Long runs do not trigger ----
        send(1'b0); expect_detected(1'b0, "after long-run '0'");
        send(1'b0); expect_detected(1'b0, "after '00'");
        send(1'b0); expect_detected(1'b0, "after '000' (no match)");

        // ---- Summary ----
        $display("\n=== %0d passed, %0d failed ===", passes, fails);
        if (fails == 0)
            $display("*** ALL TESTS PASSED ***");
        else
            $display("*** %0d FAILURES ***", fails);
        $finish;
    end

endmodule
