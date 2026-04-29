// =============================================================================
// tb_alu_4bit.v — Baseline TB for alu_4bit — sampled vectors (Day 3, Ex 3)
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
`timescale 1ns/1ps

module tb_alu_4bit;
    reg  [3:0] a, b;
    reg  [1:0] opcode;
    wire [3:0] result;
    wire       zero, carry;

    alu_4bit dut (
        .i_a(a), .i_b(b), .i_opcode(opcode),
        .o_result(result), .o_zero(zero), .o_carry(carry)
    );

    integer pass_count = 0, fail_count = 0;
    reg [4:0] expected;
    reg       exp_zero;

    task check_alu;
        input [3:0] ta, tb;
        input [1:0] top;
        input [8*20-1:0] label;
        begin
            a = ta; b = tb; opcode = top; #1;
            case (top)
                2'b00: expected = ta + tb;
                2'b01: expected = ta - tb;
                2'b10: expected = {1'b0, ta & tb};
                2'b11: expected = {1'b0, ta | tb};
            endcase
            exp_zero = (expected[3:0] == 4'd0) ? 1'b1 : 1'b0;

            if (result === expected[3:0] && zero === exp_zero) begin
                $display("PASS: %0s a=%0d b=%0d -> result=%0d zero=%b",
                         label, ta, tb, result, zero);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s a=%0d b=%0d -> result=%0d(exp %0d) zero=%b(exp %b)",
                         label, ta, tb, result, expected[3:0], zero, exp_zero);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_alu_4bit);

        // ADD tests
        check_alu(4'd3,  4'd5,  2'b00, "ADD 3+5=8");
        check_alu(4'd0,  4'd0,  2'b00, "ADD 0+0=0 (zero)");
        check_alu(4'd15, 4'd1,  2'b00, "ADD 15+1 overflow");
        check_alu(4'd7,  4'd8,  2'b00, "ADD 7+8=15");

        // SUB tests
        check_alu(4'd8,  4'd3,  2'b01, "SUB 8-3=5");
        check_alu(4'd5,  4'd5,  2'b01, "SUB 5-5=0 (zero)");
        check_alu(4'd0,  4'd1,  2'b01, "SUB 0-1 underflow");

        // AND tests
        check_alu(4'hF,  4'hA,  2'b10, "AND F&A=A");
        check_alu(4'h5,  4'hA,  2'b10, "AND 5&A=0 (zero)");
        check_alu(4'hF,  4'hF,  2'b10, "AND F&F=F");

        // OR tests
        check_alu(4'h5,  4'hA,  2'b11, "OR 5|A=F");
        check_alu(4'h0,  4'h0,  2'b11, "OR 0|0=0 (zero)");
        check_alu(4'h3,  4'hC,  2'b11, "OR 3|C=F");

        $display("\n=== tb_alu_4bit: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
