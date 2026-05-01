// =============================================================================
// tb_param_alu.v -- extracted from day08_ex02_param_alu.v
// =============================================================================
`timescale 1ns/1ps

module tb_param_alu;
    // ---- 4-bit instance ----
    reg  [3:0] a4, b4;
    reg  [2:0] op;
    wire [3:0] result4;
    wire       carry4, zero4;

    param_alu #(.WIDTH(4)) alu4 (
        .i_a(a4), .i_b(b4), .i_opcode(op),
        .o_result(result4), .o_carry(carry4), .o_zero(zero4)
    );

    // ---- 8-bit instance ----
    reg  [7:0] a8, b8;
    wire [7:0] result8;
    wire       carry8, zero8;

    param_alu #(.WIDTH(8)) alu8 (
        .i_a(a8), .i_b(b8), .i_opcode(op),
        .o_result(result8), .o_carry(carry8), .o_zero(zero8)
    );

    integer test_count = 0, fail_count = 0;

    task check4;
        input [3:0] exp;
        input [8*30-1:0] name;
    begin
        test_count = test_count + 1;
        if (result4 !== exp) begin
            $display("FAIL [4-bit]: %0s -- expected %h, got %h", name, exp, result4);
            fail_count = fail_count + 1;
        end else
            $display("PASS [4-bit]: %0s = %h", name, result4);
    end
    endtask

    task check8;
        input [7:0] exp;
        input [8*30-1:0] name;
    begin
        test_count = test_count + 1;
        if (result8 !== exp) begin
            $display("FAIL [8-bit]: %0s -- expected %h, got %h", name, exp, result8);
            fail_count = fail_count + 1;
        end else
            $display("PASS [8-bit]: %0s = %h", name, result8);
    end
    endtask

    initial begin
        $dumpfile("tb_param_alu.vcd");
        $dumpvars(0, tb_param_alu);
        $display("\n=== Parameterized ALU Testbench ===\n");

        // 4-bit tests
        op = 3'b000;  // ADD
        a4 = 4'd3; b4 = 4'd5; a8 = 8'd3; b8 = 8'd5;
        #100;
        check4(4'd8, "ADD 3+5");
        check8(8'd8, "ADD 3+5");

        a4 = 4'hF; b4 = 4'h1; a8 = 8'hFF; b8 = 8'h01;
        #100;
        check4(4'h0, "ADD F+1 overflow");
        check8(8'h0, "ADD FF+1 overflow");

        op = 3'b010;  // AND
        a4 = 4'hA; b4 = 4'hC; a8 = 8'hAA; b8 = 8'hCC;
        #100;
        check4(4'h8, "AND A&C");
        check8(8'h88, "AND AA&CC");

        op = 3'b101;  // NOT
        a4 = 4'h0; a8 = 8'h0;
        #100;
        check4(4'hF, "NOT 0=F");
        check8(8'hFF, "NOT 00=FF");

        // Summary
        $display("\n=== TEST SUMMARY ===");
        $display("Tests: %0d  Passed: %0d  Failed: %0d",
                 test_count, test_count - fail_count, fail_count);
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** %0d FAILURES ***\n", fail_count);
        $finish;
    end
endmodule
