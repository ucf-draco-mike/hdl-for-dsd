// =============================================================================
// tb_button_handler.v — Self-checking testbench for the hierarchical pipeline
// Day 8: Hierarchy, Parameters & Generate
// =============================================================================
// Drives a noisy / bouncy button input and verifies:
//   (a) the 2-FF synchronizer settles after one clock,
//   (b) bounces shorter than CLKS_STABLE are filtered out,
//   (c) o_press / o_release pulse for exactly one cycle on accepted edges.
//
// Override CLKS_STABLE small (4) so the simulation runs in microseconds.
// =============================================================================
`timescale 1ns/1ps

module tb_button_handler;

    localparam CLKS_STABLE = 4;

    reg  clk      = 1'b0;
    reg  btn_raw  = 1'b0;
    wire btn_clean;
    wire press;
    wire release_;

    button_handler #(.CLKS_STABLE(CLKS_STABLE)) dut (
        .i_clk       (clk),
        .i_btn_raw   (btn_raw),
        .o_btn_clean (btn_clean),
        .o_press     (press),
        .o_release   (release_)
    );

    always #5 clk = ~clk;             // 100 MHz

    integer pass = 0;
    integer fail = 0;
    integer press_pulses   = 0;
    integer release_pulses = 0;

    // Count one-cycle pulses on the edge outputs.
    always @(posedge clk) begin
        if (press)    press_pulses   <= press_pulses   + 1;
        if (release_) release_pulses <= release_pulses + 1;
    end

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
        $dumpfile("tb_button_handler.vcd");
        $dumpvars(0, tb_button_handler);
        $display("\n=== button_handler hierarchy testbench ===\n");

        // Settle reset state.
        repeat (8) @(posedge clk);

        // (a) Sync stage: a deterministic raw input is visible at o_btn_clean
        //     after sync + debounce latency. Drive a clean stable HIGH.
        btn_raw = 1'b1;
        repeat (CLKS_STABLE + 8) @(posedge clk);
        check(btn_clean === 1'b1, "sync works");

        // Reset counters before bounce test.
        press_pulses   = 0;
        release_pulses = 0;

        // (b) Bounces shorter than CLKS_STABLE must be ignored.
        repeat (CLKS_STABLE - 2) begin
            btn_raw = 1'b0; @(posedge clk);
            btn_raw = 1'b1; @(posedge clk);
        end
        repeat (CLKS_STABLE + 8) @(posedge clk);
        check(btn_clean === 1'b1,    "bounces filtered");
        check(press_pulses   == 0,   "no spurious press pulses during bounce");
        check(release_pulses == 0,   "no spurious release pulses during bounce");

        // (c) Stable LOW for CLKS_STABLE+ cycles must produce one release pulse.
        press_pulses   = 0;
        release_pulses = 0;
        btn_raw = 1'b0;
        repeat (CLKS_STABLE + 8) @(posedge clk);
        check(btn_clean      === 1'b0, "release accepted");
        check(release_pulses == 1,     "1-cycle release pulse");

        // Stable HIGH for CLKS_STABLE+ cycles must produce one press pulse.
        press_pulses   = 0;
        release_pulses = 0;
        btn_raw = 1'b1;
        repeat (CLKS_STABLE + 8) @(posedge clk);
        check(btn_clean    === 1'b1, "press accepted");
        check(press_pulses == 1,     "1-cycle press pulse");

        $display("\n=== %0d passed, %0d failed ===\n", pass, fail);
        if (fail == 0) $display("*** ALL TESTS PASSED ***\n");
        $finish;
    end

    initial begin
        #200_000;
        $display("FAIL: simulation timed out");
        $finish;
    end

endmodule
