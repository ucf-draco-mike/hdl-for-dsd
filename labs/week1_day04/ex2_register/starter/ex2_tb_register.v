// =============================================================================
// Exercise 2: Register Testbench
// Day 4 · Sequential Logic Fundamentals
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================

`timescale 1ns / 1ps

module tb_register;

    reg        clk, reset, load;
    reg  [3:0] data;
    wire [3:0] q;

    register_4bit uut (
        .i_clk(clk), .i_reset(reset), .i_load(load),
        .i_data(data), .o_q(q)
    );

    always #5 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;

    task check;
        input [3:0] expected;
        input [8*40-1:0] name;
    begin
        if (q === expected) begin
            $display("PASS: %0s — q=%h (expected %h)", name, q, expected);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: %0s — q=%h (expected %h)", name, q, expected);
            fail_count = fail_count + 1;
        end
    end
    endtask

    initial begin
        $dumpfile("build/ex2.vcd");
        $dumpvars(0, tb_register);

        clk = 0; reset = 1; load = 0; data = 4'h0;

        // TODO: Add test sequence:
        // 1. Reset the register — verify o_q == 0
        // 2. Load 4'hA — verify o_q == A
        // 3. Deassert load, present new data — verify hold
        // 4. Load 4'h5 — verify it changes
        // 5. Reset again — verify o_q == 0

        @(posedge clk); #1;
        check(4'h0, "After reset");

        // Release reset, load A
        reset = 0; load = 1; data = 4'hA;
        @(posedge clk); #1;
        check(4'hA, "Loaded 0xA");

        // Hold test
        load = 0; data = 4'hF;
        @(posedge clk); #1;
        check(4'hA, "Hold — should still be 0xA");

        // Load 5
        load = 1; data = 4'h5;
        @(posedge clk); #1;
        check(4'h5, "Loaded 0x5");

        // Reset
        reset = 1;
        @(posedge clk); #1;
        check(4'h0, "Reset clears to 0");

        $display("");
        $display("========================================");
        $display("Register: %0d passed, %0d failed", pass_count, fail_count);
        $display("========================================");

        #20 $finish;
    end

endmodule
