// Self-checking ALU testbench template
`timescale 1ns / 1ps

module tb_alu_4bit;

    reg  [3:0] r_a, r_b;
    reg  [1:0] r_opcode;
    wire [3:0] w_result;
    wire       w_zero, w_carry;

    integer pass_count = 0, fail_count = 0;

    alu_4bit uut (
        .i_a(r_a), .i_b(r_b), .i_opcode(r_opcode),
        .o_result(w_result), .o_zero(w_zero), .o_carry(w_carry)
    );

    task check_alu;
        input [3:0] a, b;
        input [1:0] op;
        input [3:0] exp_result;
        input       exp_carry, exp_zero;
        begin
            r_a = a; r_b = b; r_opcode = op;
            #10;
            if (w_result === exp_result && w_carry === exp_carry && w_zero === exp_zero) begin
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: a=%h b=%h op=%b | got r=%h c=%b z=%b | exp r=%h c=%b z=%b",
                         a, b, op, w_result, w_carry, w_zero, exp_result, exp_carry, exp_zero);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_alu_4bit);

        // TODO: Add test vectors using check_alu task
        // Example: check_alu(4'h3, 4'h5, 2'b00, 4'h8, 1'b0, 1'b0);  // ADD: 3+5=8

        #10;
        $display("\n=== Test Summary: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        else                 $display("SOME TESTS FAILED");
        $finish;
    end
endmodule
