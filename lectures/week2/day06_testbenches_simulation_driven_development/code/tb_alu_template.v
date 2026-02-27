// =============================================================================
// tb_alu_template.v — Self-Checking Testbench Template
// Day 6: Testbenches & Simulation-Driven Development
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Demonstrates: timescale, clock gen, dumpfile, structured test reporting,
// tasks, and the check_result pattern.

`timescale 1ns / 1ps

module tb_alu_4bit;

    // ========== Signal Declarations ==========
    reg  [3:0] a, b;
    reg  [2:0] opcode;
    wire [3:0] result;
    wire       zero;

    // ========== DUT Instantiation ==========
    alu_4bit uut (
        .i_a      (a),
        .i_b      (b),
        .i_opcode (opcode),
        .o_result (result),
        .o_zero   (zero)
    );

    // ========== Waveform Dump ==========
    initial begin
        $dumpfile("tb_alu_4bit.vcd");
        $dumpvars(0, tb_alu_4bit);
    end

    // ========== Test Infrastructure ==========
    integer test_count = 0;
    integer fail_count = 0;

    task check_result;
        input [3:0] expected;
        input [3:0] actual;
        input [8*30-1:0] test_name;
    begin
        test_count = test_count + 1;
        if (actual !== expected) begin
            $display("FAIL [%0d]: %0s — expected %h, got %h",
                     test_count, test_name, expected, actual);
            fail_count = fail_count + 1;
        end else begin
            $display("PASS [%0d]: %0s", test_count, test_name);
        end
    end
    endtask

    task apply_and_check;
        input [3:0] in_a, in_b;
        input [2:0] in_op;
        input [3:0] expected;
        input [8*30-1:0] name;
    begin
        a = in_a; b = in_b; opcode = in_op;
        #10;
        check_result(expected, result, name);
    end
    endtask

    // ========== Test Cases ==========
    initial begin
        // Initialize
        a = 0; b = 0; opcode = 0;
        #20;

        // Arithmetic
        apply_and_check(4'd3, 4'd5, 3'b000, 4'd8,   "ADD 3+5=8");
        apply_and_check(4'd7, 4'd3, 3'b001, 4'd4,   "SUB 7-3=4");
        apply_and_check(4'hF, 4'h1, 3'b000, 4'h0,   "ADD F+1=0 overflow");

        // Logic
        apply_and_check(4'hA, 4'hC, 3'b010, 4'h8,   "AND A&C=8");
        apply_and_check(4'hA, 4'hC, 3'b011, 4'hE,   "OR  A|C=E");
        apply_and_check(4'hA, 4'hC, 3'b100, 4'h6,   "XOR A^C=6");
        apply_and_check(4'hA, 4'h0, 3'b101, 4'h5,   "NOT ~A=5");

        // Shift
        apply_and_check(4'b0110, 4'd0, 3'b110, 4'b1100, "SHL 0110");
        apply_and_check(4'b0110, 4'd0, 3'b111, 4'b0011, "SHR 0110");

        // Zero flag
        apply_and_check(4'd5, 4'd5, 3'b001, 4'd0,   "SUB 5-5=0 (zero flag)");

        // ========== Summary ==========
        #10;
        $display("\n========================================");
        $display("Tests: %0d  |  Passed: %0d  |  Failed: %0d",
                 test_count, test_count - fail_count, fail_count);
        $display("========================================");
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("*** FAILURES DETECTED ***");

        $finish;
    end

endmodule
