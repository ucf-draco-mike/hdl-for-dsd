// =============================================================================
// tb_mux.v — Baseline TB for mux2to1 and mux4to1 (Day 2, Ex 2)
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
`timescale 1ns/1ps

module tb_mux;
    // --- 2:1 mux ---
    reg  a, b, sel;
    wire y_2to1;

    mux2to1 dut_2to1 (
        .i_a(a), .i_b(b), .i_sel(sel), .o_y(y_2to1)
    );

    // --- 4:1 mux ---
    reg  d0, d1, d2, d3;
    reg  [1:0] sel4;
    wire y_4to1;

    mux4to1 dut_4to1 (
        .i_d0(d0), .i_d1(d1), .i_d2(d2), .i_d3(d3),
        .i_sel(sel4), .o_y(y_4to1)
    );

    integer pass_count = 0, fail_count = 0;
    integer i;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_mux);

        // --- Test mux2to1: all 8 input combinations ---
        $display("--- mux2to1 ---");
        for (i = 0; i < 8; i = i + 1) begin
            {sel, b, a} = i[2:0];
            #1;
            if (y_2to1 === (sel ? b : a)) begin
                $display("PASS: sel=%b a=%b b=%b -> y=%b", sel, a, b, y_2to1);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: sel=%b a=%b b=%b -> y=%b (expected %b)",
                         sel, a, b, y_2to1, sel ? b : a);
                fail_count = fail_count + 1;
            end
        end

        // --- Test mux4to1: walk each select with distinct inputs ---
        $display("--- mux4to1 ---");
        // Set inputs to known distinct values
        d0 = 1; d1 = 0; d2 = 1; d3 = 0;

        sel4 = 2'b00; #1;
        if (y_4to1 === d0) begin $display("PASS: sel=00 -> d0=%b", d0); pass_count=pass_count+1; end
        else begin $display("FAIL: sel=00 -> %b (expected %b)", y_4to1, d0); fail_count=fail_count+1; end

        sel4 = 2'b01; #1;
        if (y_4to1 === d1) begin $display("PASS: sel=01 -> d1=%b", d1); pass_count=pass_count+1; end
        else begin $display("FAIL: sel=01 -> %b (expected %b)", y_4to1, d1); fail_count=fail_count+1; end

        sel4 = 2'b10; #1;
        if (y_4to1 === d2) begin $display("PASS: sel=10 -> d2=%b", d2); pass_count=pass_count+1; end
        else begin $display("FAIL: sel=10 -> %b (expected %b)", y_4to1, d2); fail_count=fail_count+1; end

        sel4 = 2'b11; #1;
        if (y_4to1 === d3) begin $display("PASS: sel=11 -> d3=%b", d3); pass_count=pass_count+1; end
        else begin $display("FAIL: sel=11 -> %b (expected %b)", y_4to1, d3); fail_count=fail_count+1; end

        // Flip all inputs and retest
        d0 = 0; d1 = 1; d2 = 0; d3 = 1;
        sel4 = 2'b00; #1;
        if (y_4to1 === d0) begin $display("PASS: sel=00 flipped -> d0=%b", d0); pass_count=pass_count+1; end
        else begin $display("FAIL: sel=00 flipped -> %b (expected %b)", y_4to1, d0); fail_count=fail_count+1; end

        sel4 = 2'b11; #1;
        if (y_4to1 === d3) begin $display("PASS: sel=11 flipped -> d3=%b", d3); pass_count=pass_count+1; end
        else begin $display("FAIL: sel=11 flipped -> %b (expected %b)", y_4to1, d3); fail_count=fail_count+1; end

        $display("\n=== tb_mux: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
