// =============================================================================
// tb_alu_4bit_ext.v -- Self-checking testbench for alu_4bit_ext
// =============================================================================
`timescale 1ns/1ps

module tb_alu_4bit_ext;
    reg  [3:0] a, b;
    reg  [2:0] op;
    reg  [2:0] shamt;
    wire [3:0] result;
    wire       zero, carry;

    alu_4bit_ext dut (
        .i_a(a), .i_b(b), .i_op(op), .i_shamt(shamt),
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
        $dumpfile("tb_alu_4bit_ext.vcd");
        $dumpvars(0, tb_alu_4bit_ext);

        shamt = 3'd0;
        a=4'd3;  b=4'd5;  op=3'b000; #5; check(4'd8,  1'b0, "ADD 3+5");
        a=4'd15; b=4'd1;  op=3'b000; #5; check(4'd0,  1'b1, "ADD 15+1 (carry)");
        a=4'd7;  b=4'd3;  op=3'b001; #5; check(4'd4,  1'b0, "SUB 7-3");
        a=4'hA;  b=4'hC;  op=3'b010; #5; check(4'h8,  1'b0, "AND A&C");
        a=4'hA;  b=4'hC;  op=3'b011; #5; check(4'hE,  1'b0, "OR  A|C");
        a=4'hA;  b=4'hC;  op=3'b100; #5; check(4'h6,  1'b0, "XOR A^C");

        // Variable shift - this is where the barrel shifter earns its LUTs
        a=4'b1010; shamt=3'd0; op=3'b101; #5; check(4'b1010, 1'b0, "SHL 1010<<0");
        a=4'b1010; shamt=3'd1; op=3'b101; #5; check(4'b0100, 1'b0, "SHL 1010<<1");
        a=4'b1010; shamt=3'd2; op=3'b101; #5; check(4'b1000, 1'b0, "SHL 1010<<2");
        a=4'b0001; shamt=3'd3; op=3'b101; #5; check(4'b1000, 1'b0, "SHL 0001<<3");

        // Unmapped opcode hits default - must produce 4'b0000, no latch
        a=4'hF;  b=4'hF;  op=3'b110; shamt=3'd0; #5;
        check(4'b0000, 1'b0, "default branch");

        // Zero flag check
        a=4'd0;  b=4'd0;  op=3'b000; #5;
        if (zero !== 1'b1) begin $display("FAIL: zero flag"); fails = fails + 1; end
        else $display("PASS: zero flag");

        if (fails == 0) $display("=== 12 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
