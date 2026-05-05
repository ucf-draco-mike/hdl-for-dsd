// =============================================================================
// tb_mux.v -- Self-checking testbench for the 4:1 mux written two ways.
//
// Drives mux_assign and mux_always with the same stimulus and proves they
// produce identical outputs (the runtime side of the "same hardware" claim).
// The synthesis side is checked separately via `make stat` on each top.
// =============================================================================
`timescale 1ns/1ps

module tb_mux;
    reg  [3:0] a, b, c, d;
    reg  [1:0] sel;
    wire [3:0] y_assign;
    wire [3:0] y_always;

    mux_assign u_assign (
        .i_a(a), .i_b(b), .i_c(c), .i_d(d),
        .i_sel(sel), .o_y(y_assign)
    );
    mux_always u_always (
        .i_a(a), .i_b(b), .i_c(c), .i_d(d),
        .i_sel(sel), .o_y(y_always)
    );

    integer fails = 0;
    task check(input [1:0] s, input [3:0] exp, input [255:0] name);
        begin
            sel = s; #1;
            if (y_assign !== exp) begin
                $display("FAIL: %0s mux_assign  expected %h, got %h", name, exp, y_assign);
                fails = fails + 1;
            end else
                $display("PASS: %0s mux_assign  = %h", name, y_assign);
            if (y_always !== exp) begin
                $display("FAIL: %0s mux_always  expected %h, got %h", name, exp, y_always);
                fails = fails + 1;
            end else
                $display("PASS: %0s mux_always  = %h", name, y_always);
        end
    endtask

    initial begin
        $dumpfile("tb_mux.vcd");
        $dumpvars(0, tb_mux);

        a = 4'hA; b = 4'hB; c = 4'hC; d = 4'hD;
        check(2'b00, 4'hA, "sel=00 -> a");
        check(2'b01, 4'hB, "sel=01 -> b");
        check(2'b10, 4'hC, "sel=10 -> c");
        check(2'b11, 4'hD, "sel=11 -> d");

        if (fails == 0) $display("=== 8 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
