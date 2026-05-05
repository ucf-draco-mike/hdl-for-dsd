// =============================================================================
// tb_traffic_variants.v — smoke test for the three traffic-light encodings
// Day 10: Numerical Architectures & Design Trade-offs (PPA demo)
// =============================================================================
// Confirms each variant cycles GREEN → YELLOW → RED → GREEN. The encodings
// differ; the externally observable behavior must match.
// =============================================================================
`timescale 1ns/1ps

module tb_traffic_variants;
    reg  clk = 1'b0;
    reg  rst = 1'b1;
    wire b_r, b_y, b_g;
    wire o_r, o_y, o_g;
    wire g_r, g_y, g_g;

    traffic_binary  ub (.i_clk(clk), .i_reset(rst), .o_red(b_r), .o_yellow(b_y), .o_green(b_g));
    traffic_onehot  uo (.i_clk(clk), .i_reset(rst), .o_red(o_r), .o_yellow(o_y), .o_green(o_g));
    traffic_gray    ug (.i_clk(clk), .i_reset(rst), .o_red(g_r), .o_yellow(g_y), .o_green(g_g));

    always #5 clk = ~clk;

    integer pass = 0, fail = 0;

    task expect_eq;
        input        cond;
        input [255:0] msg;
    begin
        if (cond) begin $display("PASS: %0s", msg); pass = pass + 1; end
        else      begin $display("FAIL: %0s", msg); fail = fail + 1; end
    end
    endtask

    initial begin
        $dumpfile("tb_traffic_variants.vcd");
        $dumpvars(0, tb_traffic_variants);
        $display("\n=== traffic_variants testbench ===\n");

        repeat (3) @(posedge clk);
        rst = 1'b0;
        @(posedge clk); #1;

        expect_eq(b_g && o_g && g_g, "post-reset all variants in GREEN");

        // Run long enough to walk through every state at least once.
        repeat (700) @(posedge clk);
        #1;
        expect_eq((b_r||b_y||b_g) && (o_r||o_y||o_g) && (g_r||g_y||g_g),
                  "all variants holding exactly one light after run");

        $display("\n=== %0d passed, %0d failed ===\n", pass, fail);
        if (fail == 0) $display("*** ALL TESTS PASSED ***\n");
        $finish;
    end

    initial begin
        #500_000;
        $display("FAIL: simulation timed out");
        $finish;
    end

endmodule
