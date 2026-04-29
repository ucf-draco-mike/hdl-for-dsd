`timescale 1ns/1ps
module tb_alu_sv;
    logic [1:0] opcode;
    logic [3:0] a, b, result;
    logic carry, zero;

    alu_sv #(.WIDTH(4)) uut (
        .i_opcode(opcode),.i_a(a),.i_b(b),
        .o_result(result),.o_carry(carry),.o_zero(zero));

    integer test_count=0, fail_count=0;

    task check(input [3:0] exp_r, input exp_c, input [63:0] label);
    begin
        #10;
        test_count=test_count+1;
        if (result!==exp_r || carry!==exp_c) begin
            fail_count=fail_count+1;
            $display("FAIL [%0s]: got r=%h c=%b exp r=%h c=%b",
                     label, result, carry, exp_r, exp_c);
        end else
            $display("PASS [%0s]",label);
    end endtask

    initial begin
        $dumpfile("alu_sv.vcd"); $dumpvars(0,tb_alu_sv);
        opcode=2'b00; a=4'h3; b=4'h5; check(4'h8, 1'b0, "ADD 3+5 ");
        opcode=2'b00; a=4'hF; b=4'h1; check(4'h0, 1'b1, "ADD F+1 ");
        opcode=2'b01; a=4'h5; b=4'h3; check(4'h2, 1'b0, "SUB 5-3 ");
        opcode=2'b10; a=4'hF; b=4'h3; check(4'h3, 1'b0, "AND F&3 ");
        opcode=2'b11; a=4'hA; b=4'h5; check(4'hF, 1'b0, "OR  A|5 ");

        // Zero flag test
        opcode=2'b01; a=4'h7; b=4'h7; #10;
        test_count=test_count+1;
        if (!zero) begin fail_count=fail_count+1; $display("FAIL: zero flag"); end
        else $display("PASS [ZERO   ]");

        $display("\nALU SV: %0d/%0d passed",test_count-fail_count,test_count);
        $finish;
    end
endmodule
