// =============================================================================
// tb_alu_exhaustive.v — Exhaustive ALU Test (Starter)
// Day 6, Exercise 5 (Stretch)
// =============================================================================
// Tests all 1024 input combinations: 16 × 16 × 4 opcodes

`timescale 1ns / 1ps

module tb_alu_exhaustive;

    reg  [3:0] a, b;
    reg  [1:0] opcode;
    wire [3:0] result;
    wire       carry, zero;

    alu_4bit uut (
        .i_a(a), .i_b(b), .i_opcode(opcode),
        .o_result(result), .o_carry(carry), .o_zero(zero)
    );

    integer ia, ib, iop;
    integer test_count = 0, fail_count = 0;
    reg [4:0] expected;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_alu_exhaustive);

        $display("=== Exhaustive ALU Test (1024 vectors) ===");

        // ---- TODO: Triple-nested loop over all inputs ----
        // for (iop = 0; iop < 4; iop = iop + 1) begin
        //   for (ia = 0; ia < 16; ia = ia + 1) begin
        //     for (ib = 0; ib < 16; ib = ib + 1) begin
        //       a = ia[3:0]; b = ib[3:0]; opcode = iop[1:0];
        //       #10;
        //
        //       // Compute expected result
        //       case (iop[1:0])
        //         2'b00: expected = ia[3:0] + ib[3:0];
        //         2'b01: expected = ia[3:0] - ib[3:0];
        //         2'b10: expected = {1'b0, ia[3:0] & ib[3:0]};
        //         2'b11: expected = {1'b0, ia[3:0] | ib[3:0]};
        //       endcase
        //
        //       test_count = test_count + 1;
        //       if (result !== expected[3:0]) begin
        //         fail_count = fail_count + 1;
        //         $display("FAIL: op=%b a=%h b=%h exp=%h got=%h",
        //                  iop[1:0], ia[3:0], ib[3:0], expected[3:0], result);
        //       end
        //     end
        //   end
        // end

        $display("\n========================================");
        $display("Exhaustive: %0d vectors, %0d failures", test_count, fail_count);
        if (fail_count == 0)
            $display("ALL PASS!");
        $display("========================================");
        $finish;
    end

endmodule
