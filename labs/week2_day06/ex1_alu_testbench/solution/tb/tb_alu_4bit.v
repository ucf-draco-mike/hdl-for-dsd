// =============================================================================
// tb_alu_4bit.v -- Self-Checking ALU Testbench (Solution)
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

    task check_alu;
        input [3:0] t_a, t_b;
        input [1:0] t_op;
        input [3:0] exp_result;
        input       exp_carry, exp_zero;
    begin
        a = t_a; b = t_b; opcode = t_op;
        #10;
        test_count = test_count + 1;
        if (result !== exp_result || carry !== exp_carry || zero !== exp_zero) begin
            fail_count = fail_count + 1;
            $display("FAIL: op=%b a=%h b=%h | exp r=%h c=%b z=%b | got r=%h c=%b z=%b",
                     t_op, t_a, t_b, exp_result, exp_carry, exp_zero,
                     result, carry, zero);
        end else begin
            $display("PASS: op=%b a=%h b=%h = %h (c=%b z=%b)",
                     t_op, t_a, t_b, result, carry, zero);
        end
    end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_alu_4bit);

        $display("=== ALU 4-bit Self-Checking Testbench ===");
        $display("");

        // ADD tests (opcode = 2'b00)
        check_alu(4'h0, 4'h0, 2'b00, 4'h0, 1'b0, 1'b1);
        check_alu(4'h3, 4'h5, 2'b00, 4'h8, 1'b0, 1'b0);
        check_alu(4'hF, 4'h1, 2'b00, 4'h0, 1'b1, 1'b1);
        check_alu(4'h8, 4'h8, 2'b00, 4'h0, 1'b1, 1'b1);
        check_alu(4'h7, 4'h8, 2'b00, 4'hF, 1'b0, 1'b0);

        // SUB tests (opcode = 2'b01)
        check_alu(4'h5, 4'h3, 2'b01, 4'h2, 1'b0, 1'b0);
        check_alu(4'h3, 4'h3, 2'b01, 4'h0, 1'b0, 1'b1);
        check_alu(4'h0, 4'h1, 2'b01, 4'hF, 1'b1, 1'b0);
        check_alu(4'hF, 4'hF, 2'b01, 4'h0, 1'b0, 1'b1);

        // AND tests (opcode = 2'b10)
        check_alu(4'hA, 4'hC, 2'b10, 4'h8, 1'b0, 1'b0);
        check_alu(4'hF, 4'hF, 2'b10, 4'hF, 1'b0, 1'b0);
        check_alu(4'hA, 4'h5, 2'b10, 4'h0, 1'b0, 1'b1);

        // OR tests (opcode = 2'b11)
        check_alu(4'hA, 4'h5, 2'b11, 4'hF, 1'b0, 1'b0);
        check_alu(4'h0, 4'h0, 2'b11, 4'h0, 1'b0, 1'b1);
        check_alu(4'hF, 4'hF, 2'b11, 4'hF, 1'b0, 1'b0);

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
