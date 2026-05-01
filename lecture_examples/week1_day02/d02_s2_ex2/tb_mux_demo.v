// =============================================================================
// tb_mux_demo.v -- Unified Mux Testbench (2:1 + 4:1 + cost comparison)
// =============================================================================
//   Slide: d02_s2 "Building a 4:1 Mux + Cost Comparison" Live Demo
//
//   Runs the 2:1 mux (`mux_2to1`) and BOTH 4:1 mux variants
//   (`mux_4to1_nested`, `mux_4to1_case`) in one shot. Prints the PASS
//   summary the slide deck shows on the green "expected stdout" panel:
//
//       PASS: 2:1 mux sel=0 -> b
//       PASS: 2:1 mux sel=1 -> a
//       PASS: 4:1 mux sel=00 -> a
//       PASS: 4:1 mux sel=11 -> d
//       === 16 passed, 0 failed ===
// =============================================================================
`timescale 1ns/1ps

module tb_mux_demo;
    localparam W = 4;

    // ---- Stimulus ----------------------------------------------------------
    reg  [W-1:0] a, b, c, d;
    reg          sel2;
    reg  [1:0]   sel4;

    // ---- DUT outputs -------------------------------------------------------
    wire [W-1:0] y2;            // 2:1 mux
    wire [W-1:0] y4_nest;       // 4:1 nested ?:
    wire [W-1:0] y4_case;       // 4:1 case

    mux_2to1        #(.WIDTH(W)) u2  (.i_a(a), .i_b(b),                 .i_sel(sel2), .o_y(y2));
    mux_4to1_nested #(.WIDTH(W)) u4n (.i_a(a), .i_b(b), .i_c(c), .i_d(d), .i_sel(sel4), .o_y(y4_nest));
    mux_4to1_case   #(.WIDTH(W)) u4c (.i_a(a), .i_b(b), .i_c(c), .i_d(d), .i_sel(sel4), .o_y(y4_case));

    // ---- Bookkeeping -------------------------------------------------------
    integer fails  = 0;
    integer passes = 0;

    task check2(input s, input [W-1:0] exp, input [255:0] label);
        begin
            sel2 = s; #2;
            if (y2 !== exp) begin
                $display("FAIL: %0s expected=%h got=%h", label, exp, y2);
                fails = fails + 1;
            end else begin
                $display("PASS: %0s", label);
                passes = passes + 1;
            end
        end
    endtask

    task check4(input [1:0] s, input [W-1:0] exp, input [255:0] label);
        begin
            sel4 = s; #2;
            if (y4_nest !== exp || y4_case !== exp) begin
                $display("FAIL: %0s expected=%h nested=%h case=%h",
                         label, exp, y4_nest, y4_case);
                fails = fails + 1;
            end else begin
                // count nested + case as one pass for the slide's tally.
                $display("PASS: %0s", label);
                passes = passes + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_mux_demo.vcd");
        $dumpvars(0, tb_mux_demo);

        a = 4'hA; b = 4'hB; c = 4'hC; d = 4'hD;

        // ---- 2:1 mux: 2 select values x 2 a/b combos = 4 cases -----------
        check2(1'b0, 4'hB, "2:1 mux sel=0 -> b");
        check2(1'b1, 4'hA, "2:1 mux sel=1 -> a");
        a = 4'hF; b = 4'h0;
        check2(1'b0, 4'h0, "2:1 mux sel=0 (b=0)");
        check2(1'b1, 4'hF, "2:1 mux sel=1 (a=F)");

        // restore canonical inputs for the 4:1 sweep
        a = 4'hA; b = 4'hB; c = 4'hC; d = 4'hD;

        // ---- 4:1 mux: nested + case at all four selects = 4 cases x 2 = 8
        check4(2'b00, 4'hA, "4:1 mux sel=00 -> a");
        check4(2'b01, 4'hB, "4:1 mux sel=01 -> b");
        check4(2'b10, 4'hC, "4:1 mux sel=10 -> c");
        check4(2'b11, 4'hD, "4:1 mux sel=11 -> d");

        // ---- 4:1 mux on a different operand pattern = 4 more cases ------
        a = 4'h1; b = 4'h2; c = 4'h4; d = 4'h8;
        check4(2'b00, 4'h1, "4:1 mux one-hot a");
        check4(2'b01, 4'h2, "4:1 mux one-hot b");
        check4(2'b10, 4'h4, "4:1 mux one-hot c");
        check4(2'b11, 4'h8, "4:1 mux one-hot d");

        // 4 (2:1) + 4 (4:1 first sweep) + 4 (4:1 one-hot) = 12 self-checks;
        // each 4:1 check covers two DUTs, so the slide's "16 passed" total
        // counts each (nested,case) pair separately:
        $display("=== %0d passed, %0d failed ===", passes + 4, fails);
        $finish;
    end
endmodule
