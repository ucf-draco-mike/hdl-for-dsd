// =============================================================================
// tb_latch_fixed.v -- Confirms the fixes are pure combinational (no holding).
// =============================================================================
`timescale 1ns/1ps

module tb_latch_fixed;
    reg        sel, enable;
    reg  [3:0] a, b;
    reg  [1:0] opcode;
    wire [3:0] fix1, fix2;

    latch_fixed dut (
        .i_sel(sel), .i_enable(enable),
        .i_a(a), .i_b(b), .i_opcode(opcode),
        .o_fix1(fix1), .o_fix2(fix2)
    );

    integer fails = 0;
    task check(input [3:0] exp, input [3:0] act, input [255:0] name);
        if (act !== exp) begin
            $display("FAIL: %0s -- expected %h, got %h", name, exp, act);
            fails = fails + 1;
        end else
            $display("PASS: %0s = %h", name, act);
    endtask

    initial begin
        $dumpfile("tb_latch_fixed.vcd");
        $dumpvars(0, tb_latch_fixed);

        // FIX1: when sel=0, fix1 must be 0 (default), not whatever was last
        a = 4'hA; sel = 1'b1; opcode = 2'b00; #5; check(4'hA, fix1, "fix1 sel=1 -> a");
        sel = 1'b0; a = 4'hF; #5; check(4'h0, fix1, "fix1 sel=0 -> default 0");

        // FIX2: complete case -- no held values
        a = 4'h6; b = 4'h3;
        opcode = 2'b00; #5; check(4'h6, fix2, "fix2 op=00 -> a");
        opcode = 2'b01; #5; check(4'h3, fix2, "fix2 op=01 -> b");
        opcode = 2'b10; #5; check(4'h2, fix2, "fix2 op=10 -> a&b");
        opcode = 2'b11; #5; check(4'h7, fix2, "fix2 op=11 -> a|b");

        if (fails == 0) $display("=== 6 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
