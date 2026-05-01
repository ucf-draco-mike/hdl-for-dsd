// =============================================================================
// tb_alu_4bit.v -- Self-Checking ALU Testbench (Starter)
// Day 6, Exercise 1
// =============================================================================

`timescale 1ns / 1ps

module tb_alu_4bit;

    reg  [3:0] a, b;
    reg  [1:0] opcode;
    wire [3:0] result;
    wire       carry, zero;

    alu_4bit uut (
        .i_a(a), .i_b(b), .i_opcode(opcode),
        .o_result(result), .o_carry(carry), .o_zero(zero)
    );

    integer test_count = 0;
    integer fail_count = 0;

    // ---- TODO: Implement check_alu task ----
    // task check_alu;
    //   input [3:0] t_a, t_b;
    //   input [1:0] t_op;
    //   input [3:0] exp_result;
    //   input       exp_carry, exp_zero;
    // begin
    //   a = t_a; b = t_b; opcode = t_op;
    //   #10;
    //   test_count = test_count + 1;
    //   if (result !== exp_result || carry !== exp_carry || zero !== exp_zero) begin
    //     fail_count = fail_count + 1;
    //     $display("FAIL: op=%b a=%h b=%h | expected r=%h c=%b z=%b | got r=%h c=%b z=%b",
    //              t_op, t_a, t_b, exp_result, exp_carry, exp_zero,
    //              result, carry, zero);
    //   end else begin
    //     $display("PASS: op=%b a=%h b=%h = %h (c=%b z=%b)",
    //              t_op, t_a, t_b, result, carry, zero);
    //   end
    // end
    // endtask


    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_alu_4bit);

        $display("=== ALU 4-bit Self-Checking Testbench ===");
        $display("");

        // ---- TODO: ADD tests (opcode = 2'b00) ----
        // check_alu(4'h0, 4'h0, 2'b00, 4'h0, 1'b0, 1'b1);  // 0+0=0, z=1
        // check_alu(4'h3, 4'h5, 2'b00, 4'h8, 1'b0, 1'b0);  // 3+5=8
        // check_alu(4'hF, 4'h1, 2'b00, 4'h0, 1'b1, 1'b1);  // F+1=0, c=1, z=1
        // check_alu(4'h8, 4'h8, 2'b00, 4'h0, 1'b1, 1'b1);  // 8+8=0, c=1, z=1
        // check_alu(4'h7, 4'h8, 2'b00, 4'hF, 1'b0, 1'b0);  // 7+8=F

        // ---- TODO: SUB tests (opcode = 2'b01) ----

        // ---- TODO: AND tests (opcode = 2'b10) ----

        // ---- TODO: OR tests (opcode = 2'b11) ----


        // ---- Summary ----
        $display("");
        $display("========================================");
        $display("  %0d / %0d tests PASSED", test_count - fail_count, test_count);
        if (fail_count > 0)
            $display("  *** %0d FAILURES ***", fail_count);
        else
            $display("  All tests passed!");
        $display("========================================");
        $finish;
    end

endmodule
