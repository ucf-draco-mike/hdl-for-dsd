// =============================================================================
// tb_latch_demo.v -- Smoke testbench that EXPOSES the inferred latches.
//
// We drive the inputs that aren't covered by the if/case, then assert that
// the output retains its previous value (the signature of a latch).
// =============================================================================
`timescale 1ns/1ps

module tb_latch_demo;
    reg        sel, enable;
    reg  [3:0] a, b;
    reg  [1:0] opcode;
    wire [3:0] bug1, bug2;

    latch_demo dut (
        .i_sel(sel), .i_enable(enable),
        .i_a(a), .i_b(b), .i_opcode(opcode),
        .o_bug1(bug1), .o_bug2(bug2)
    );

    integer fails = 0;
    reg [3:0] hold;

    initial begin
        $dumpfile("tb_latch_demo.vcd");
        $dumpvars(0, tb_latch_demo);

        // Bug 1: load bug1, then take sel low -> bug1 should hold (latch)
        a = 4'hA; b = 4'h5; sel = 1'b1; opcode = 2'b00; #5;
        hold = bug1;
        sel = 1'b0; a = 4'h0; #5;
        if (bug1 !== hold) begin
            $display("FAIL: bug1 changed when sel=0 (no latch?)"); fails = fails + 1;
        end else
            $display("PASS: bug1 latched (held=%h)", bug1);

        // Bug 2: load bug2 via opcode=00, then drive opcode=10 (uncovered) -> hold
        opcode = 2'b00; a = 4'hC; #5;
        hold = bug2;
        opcode = 2'b10; a = 4'h3; b = 4'h7; #5;
        if (bug2 !== hold) begin
            $display("FAIL: bug2 changed when opcode=10 (no latch?)"); fails = fails + 1;
        end else
            $display("PASS: bug2 latched (held=%h)", bug2);

        if (fails == 0) $display("=== 2 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
