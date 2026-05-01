// =============================================================================
// tb_alu_4bit.v -- Self-checking testbench for alu_4bit
// =============================================================================
`timescale 1ns/1ps

module tb_alu_4bit;
    reg  [3:0] a, b;
    reg  [1:0] op;
    wire [3:0] result;
    wire       zero, carry;

    alu_4bit dut (
        .i_a(a), .i_b(b), .i_op(op),
        .o_result(result), .o_zero(zero), .o_carry(carry)
    );

    integer fails = 0;
    task check(input [3:0] exp_r, input exp_c, input [255:0] name);
        if (result !== exp_r || carry !== exp_c) begin
            $display("FAIL: %0s -- expected r=%h c=%b, got r=%h c=%b",
                     name, exp_r, exp_c, result, carry);
            fails = fails + 1;
        end else
            $display("PASS: %0s r=%h c=%b", name, result, carry);
    endtask

    initial begin
        $dumpfile("tb_alu_4bit.vcd");
        $dumpvars(0, tb_alu_4bit);

        a=4'd3;  b=4'd5;  op=2'b00; #5; check(4'd8,  1'b0, "ADD 3+5");
        a=4'd15; b=4'd1;  op=2'b00; #5; check(4'd0,  1'b1, "ADD 15+1 (carry)");
        a=4'd7;  b=4'd3;  op=2'b01; #5; check(4'd4,  1'b0, "SUB 7-3");
        a=4'hA;  b=4'hC;  op=2'b10; #5; check(4'h8,  1'b0, "AND A&C");
        a=4'hA;  b=4'hC;  op=2'b11; #5; check(4'hE,  1'b0, "OR  A|C");
        a=4'd0;  b=4'd0;  op=2'b00; #5;
        if (zero !== 1'b1) begin $display("FAIL: zero flag"); fails = fails + 1; end
        else $display("PASS: zero flag");

        if (fails == 0) $display("=== 6 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
