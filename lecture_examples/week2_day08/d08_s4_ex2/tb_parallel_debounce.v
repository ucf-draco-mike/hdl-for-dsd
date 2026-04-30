// =============================================================================
// tb_parallel_debounce.v — Smoke testbench for the generate-based pipeline.
// Confirms each lane debounces independently and produces edge pulses.
// =============================================================================
`timescale 1ns/1ps

module tb_parallel_debounce;
    localparam N = 4;
    reg          clk = 1'b0;
    reg  [N-1:0] buttons = {N{1'b1}};   // start with all released
    wire [N-1:0] clean, press_edge, release_edge;

    parallel_debounce #(.N(N), .CLKS_TO_STABLE(10)) dut (
        .i_clk          (clk),
        .i_buttons      (buttons),
        .o_clean        (clean),
        .o_press_edge   (press_edge),
        .o_release_edge (release_edge)
    );

    always #5 clk = ~clk;

    integer fails = 0;

    `define INIT_LANE(L) \
        force dut.gen_input[L].db.r_sync_0 = 1'b1; \
        force dut.gen_input[L].db.r_sync_1 = 1'b1; \
        force dut.gen_input[L].db.o_clean  = 1'b1; \
        force dut.gen_input[L].db.r_count  = 0;    \
        force dut.gen_input[L].r_prev      = 1'b1;

    `define RELEASE_LANE(L) \
        release dut.gen_input[L].db.r_sync_0; \
        release dut.gen_input[L].db.r_sync_1; \
        release dut.gen_input[L].db.o_clean;  \
        release dut.gen_input[L].db.r_count;  \
        release dut.gen_input[L].r_prev;

    initial begin
        $dumpfile("tb_parallel_debounce.vcd");
        $dumpvars(0, tb_parallel_debounce);

        `INIT_LANE(0) `INIT_LANE(1) `INIT_LANE(2) `INIT_LANE(3)
        @(posedge clk);
        `RELEASE_LANE(0) `RELEASE_LANE(1) `RELEASE_LANE(2) `RELEASE_LANE(3)
        @(posedge clk);

        // Press button 0
        buttons[0] = 1'b0;
        repeat (20) @(posedge clk);
        #1;
        if (clean[0] !== 1'b0) begin
            $display("FAIL: lane 0 not debounced low"); fails = fails + 1;
        end else
            $display("PASS: lane 0 debounced low");

        if (clean[1] !== 1'b1 || clean[2] !== 1'b1 || clean[3] !== 1'b1) begin
            $display("FAIL: other lanes disturbed: clean=%b", clean); fails = fails + 1;
        end else
            $display("PASS: other lanes independent (clean=%b)", clean);

        // Release lane 0
        buttons[0] = 1'b1;
        repeat (20) @(posedge clk);
        #1;
        if (clean[0] !== 1'b1) begin
            $display("FAIL: lane 0 didn't return high"); fails = fails + 1;
        end else
            $display("PASS: lane 0 debounced high");

        if (fails == 0) $display("=== 3 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
