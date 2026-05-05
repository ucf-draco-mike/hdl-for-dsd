// =============================================================================
// tb_button_array.v — generate-based pipeline smoke test
// Day 8: Hierarchy, Parameters & Generate
// =============================================================================
// Confirms each lane debounces independently. Exercises lane 0 as the
// canonical lane and verifies the remaining lanes stay quiet — regardless
// of N. Override N from the Makefile with `-DTB_N=8` etc.
// =============================================================================
`timescale 1ns/1ps

`ifndef TB_N
`define TB_N 4
`endif

`ifndef TB_CLKS_STABLE
`define TB_CLKS_STABLE 10
`endif

module tb_button_array;

    localparam N           = `TB_N;
    localparam CLKS_STABLE = `TB_CLKS_STABLE;

    reg          clk     = 1'b0;
    reg  [N-1:0] buttons = {N{1'b1}};   // start with all released (HIGH = idle)
    wire [N-1:0] clean;
    wire [N-1:0] press_edge;
    wire [N-1:0] release_edge;

    button_array #(.N(N), .CLKS_STABLE(CLKS_STABLE)) dut (
        .i_clk          (clk),
        .i_buttons      (buttons),
        .o_clean        (clean),
        .o_press_edge   (press_edge),
        .o_release_edge (release_edge)
    );

    always #5 clk = ~clk;

    integer pass = 0;
    integer fail = 0;
    integer other_ok;
    integer k;

    task check;
        input        cond;
        input [511:0] msg;
    begin
        if (cond) begin
            $display("PASS: %0s", msg);
            pass = pass + 1;
        end else begin
            $display("FAIL: %0s", msg);
            fail = fail + 1;
        end
    end
    endtask

    initial begin
        $dumpfile("tb_button_array.vcd");
        $dumpvars(0, tb_button_array);
        $display("\n=== button_array testbench (N=%0d) ===\n", N);

        // Settle: keep all buttons idle (HIGH) for long enough that the
        // debouncer accepts HIGH on every lane.
        repeat (CLKS_STABLE * 2 + 8) @(posedge clk);
        check(&clean, "all lanes settle high");

        // Press lane 0 only; hold it stable long enough to debounce.
        buttons[0] = 1'b0;
        repeat (CLKS_STABLE * 2 + 8) @(posedge clk);
        #1;
        check(clean[0] === 1'b0, "lane 0 debounced low");

        // Other lanes must be unaffected. Loop bit-by-bit so the test works
        // for any N >= 1 without requiring a width-conditional bit slice.
        other_ok = 1;
        for (k = 1; k < N; k = k + 1)
            if (clean[k] !== 1'b1) other_ok = 0;
        check(other_ok == 1, "other lanes independent (still high)");

        // Release lane 0 again.
        buttons[0] = 1'b1;
        repeat (CLKS_STABLE * 2 + 8) @(posedge clk);
        #1;
        check(clean[0] === 1'b1, "lane 0 debounced high");

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
