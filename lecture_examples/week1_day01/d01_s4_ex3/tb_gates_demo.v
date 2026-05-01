// =============================================================================
// tb_gates_demo.v -- Exhaustive 2-input truth-table check for gates_demo
// =============================================================================
//   Walks all 4 (a,b) input combinations, prints the truth table, and asserts
//   that the SOP and DeMorgan forms produce identical outputs for every case.
// =============================================================================
`timescale 1ns/1ps

module tb_gates_demo;
    reg  a, b;
    wire and_o, or_o, xor_o, sop_o, dem_o;

    gates_demo dut (
        .i_a   (a),
        .i_b   (b),
        .o_and (and_o),
        .o_or  (or_o),
        .o_xor (xor_o),
        .o_sop (sop_o),
        .o_dem (dem_o)
    );

    integer fails = 0;
    integer i;

    initial begin
        $dumpfile("tb_gates_demo.vcd");
        $dumpvars(0, tb_gates_demo);

        $display("a b | and or xor | sop dem  (sop ?== dem)");
        $display("---------------------------------------");

        for (i = 0; i < 4; i = i + 1) begin
            {a, b} = i[1:0];
            #1;
            $display("%0b %0b |  %0b  %0b  %0b  |  %0b   %0b   %s",
                     a, b, and_o, or_o, xor_o, sop_o, dem_o,
                     (sop_o === dem_o) ? "PASS" : "FAIL");
            if (sop_o !== dem_o) fails = fails + 1;
        end

        if (fails == 0) $display("=== 4 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
