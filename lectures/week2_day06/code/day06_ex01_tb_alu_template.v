// =============================================================================
// day06_ex01_tb_alu_template.v — Self-Checking ALU Testbench Template
// Day 6: Testbenches & Simulation-Driven Development
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Demonstrates: timescale, clock gen, $dumpfile/$dumpvars, structured test
// reporting with tasks, case-equality operators, and summary report.
// =============================================================================
// Build:  iverilog -o sim day06_ex01_tb_alu_template.v alu_4bit.v && vvp sim
// View:   gtkwave tb_alu.vcd
// =============================================================================

`timescale 1ns / 1ps

module tb_alu;

    // ---- DUT interface signals ----
    reg  [3:0] a, b;
    reg  [2:0] opcode;
    wire [3:0] result;
    wire       carry_out, zero;

    // ---- Instantiate DUT ----
    // (Replace with your actual ALU module name and ports)
    // alu_4bit uut (
    //     .i_a(a), .i_b(b), .i_opcode(opcode),
    //     .o_result(result), .o_carry(carry_out), .o_zero(zero)
    // );

    // ---- Placeholder for standalone demo ----
    // Simple combinational ALU for the template to compile
    reg [4:0] r_wide;
    always @(*) begin
        case (opcode)
            3'b000: r_wide = a + b;       // ADD
            3'b001: r_wide = a - b;       // SUB
            3'b010: r_wide = {1'b0, a & b}; // AND
            3'b011: r_wide = {1'b0, a | b}; // OR
            3'b100: r_wide = {1'b0, a ^ b}; // XOR
            3'b101: r_wide = {1'b0, ~a};    // NOT A
            default: r_wide = 5'd0;
        endcase
    end
    assign result    = r_wide[3:0];
    assign carry_out = r_wide[4];
    assign zero      = (result == 4'd0);

    // ---- Test counters ----
    integer test_count = 0;
    integer fail_count = 0;

    // ---- Check task ----
    task check_result;
        input [3:0] expected;
        input [3:0] actual;
        input [8*30-1:0] test_name;
    begin
        test_count = test_count + 1;
        if (actual !== expected) begin
            $display("FAIL: %0s — expected %h, got %h at time %0t",
                     test_name, expected, actual, $time);
            fail_count = fail_count + 1;
        end else begin
            $display("PASS: %0s = %h", test_name, actual);
        end
    end
    endtask

    // ---- Apply and check task (combines stimulus + verification) ----
    task apply_and_check;
        input [3:0] in_a, in_b;
        input [2:0] in_op;
        input [3:0] expected;
        input [8*30-1:0] name;
    begin
        a = in_a;
        b = in_b;
        opcode = in_op;
        #100;  // combinational settle time
        check_result(expected, result, name);
    end
    endtask

    // ---- Stimulus ----
    initial begin
        $dumpfile("tb_alu.vcd");
        $dumpvars(0, tb_alu);

        // Initialize
        a = 0; b = 0; opcode = 0;
        #50;

        $display("\n=== ALU Testbench ===\n");

        // Arithmetic tests
        apply_and_check(4'd3,  4'd5,  3'b000, 4'd8,   "ADD  3 + 5 = 8");
        apply_and_check(4'd15, 4'd1,  3'b000, 4'd0,   "ADD 15 + 1 = 0 (overflow)");
        apply_and_check(4'd7,  4'd3,  3'b001, 4'd4,   "SUB  7 - 3 = 4");
        apply_and_check(4'd0,  4'd1,  3'b001, 4'hF,   "SUB  0 - 1 = F (underflow)");

        // Logic tests
        apply_and_check(4'hA,  4'hC,  3'b010, 4'h8,   "AND  A & C = 8");
        apply_and_check(4'hA,  4'hC,  3'b011, 4'hE,   "OR   A | C = E");
        apply_and_check(4'hA,  4'h5,  3'b100, 4'hF,   "XOR  A ^ 5 = F");
        apply_and_check(4'hF,  4'h0,  3'b101, 4'h0,   "NOT  ~F = 0");

        // Edge cases
        apply_and_check(4'd0,  4'd0,  3'b000, 4'd0,   "ADD  0 + 0 = 0 (zero)");
        apply_and_check(4'hF,  4'hF,  3'b010, 4'hF,   "AND  F & F = F (identity)");

        // ---- Summary Report ----
        $display("\n=== TEST SUMMARY ===");
        $display("Tests run:    %0d", test_count);
        $display("Tests passed: %0d", test_count - fail_count);
        $display("Tests failed: %0d", fail_count);
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** %0d FAILURES — FIX BEFORE PROCEEDING ***\n", fail_count);

        $finish;
    end

endmodule
