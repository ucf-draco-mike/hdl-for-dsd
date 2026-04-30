// =============================================================================
// tb_mux_2to1.v — Smoke testbench for mux_2to1
// =============================================================================
`timescale 1ns/1ps

module tb_mux_2to1;
    localparam W = 4;
    reg  [W-1:0] a, b;
    reg          sel;
    wire [W-1:0] y;

    mux_2to1 #(.WIDTH(W)) dut (
        .i_a (a), .i_b (b), .i_sel (sel), .o_y (y)
    );

    integer fails = 0;
    task check(input [W-1:0] exp, input [W-1:0] act, input [255:0] name);
        if (act !== exp) begin
            $display("FAIL: %0s — expected %h, got %h", name, exp, act);
            fails = fails + 1;
        end else
            $display("PASS: %0s = %h", name, act);
    endtask

    initial begin
        $dumpfile("tb_mux_2to1.vcd");
        $dumpvars(0, tb_mux_2to1);

        a = 4'hA; b = 4'h5;
        sel = 1'b0; #5; check(4'h5, y, "mux sel=0 -> b");
        sel = 1'b1; #5; check(4'hA, y, "mux sel=1 -> a");

        a = 4'hF; b = 4'h0;
        sel = 1'b0; #5; check(4'h0, y, "mux sel=0 (b=0)");
        sel = 1'b1; #5; check(4'hF, y, "mux sel=1 (a=F)");

        if (fails == 0) $display("=== 4 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
