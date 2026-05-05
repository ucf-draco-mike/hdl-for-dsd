// =============================================================================
// tb_debounce_sv.sv -- Smoke testbench for debounce_sv
// SystemVerilog version of the Day-5 debouncer testbench. Exercises:
//   * stable 1 passes through        (after the 2-FF sync + stability window)
//   * stable 0 passes through
//   * 1-cycle glitch is filtered     (counter resets, no edge propagates)
//   * a noisy "bouncing" sequence eventually settles to the steady value
// CLKS_TO_STABLE is shrunk to a small value so the test runs in <50 us.
// =============================================================================
`timescale 1ns/1ps

module tb_debounce_sv;
    localparam int CLKS_TO_STABLE = 8;          // tiny window for sim

    logic clk = 1'b0;
    logic bouncy = 1'b0;
    logic clean;

    debounce_sv #(.CLKS_TO_STABLE(CLKS_TO_STABLE)) uut (
        .i_clk(clk),
        .i_bouncy(bouncy),
        .o_clean(clean)
    );

    always #5 clk = ~clk;

    int  fails = 0;
    int  passes = 0;

    task automatic check(input logic exp, input string label);
        if (clean !== exp) begin
            $display("FAIL: %s -- got %0b, expected %0b", label, clean, exp);
            fails++;
        end else begin
            $display("PASS: %s", label);
            passes++;
        end
    endtask

    initial begin
        $dumpfile("tb_debounce_sv.vcd");
        $dumpvars(0, tb_debounce_sv);
        $display("=== debounce_sv smoke testbench ===");

        // Let the 2-FF sync settle on 0
        bouncy = 1'b0;
        repeat (CLKS_TO_STABLE + 4) @(posedge clk);
        check(1'b0, "stable 0 passes through");

        // Drive 1 stably; wait for sync + stability window
        bouncy = 1'b1;
        repeat (CLKS_TO_STABLE + 4) @(posedge clk);
        check(1'b1, "stable 1 passes through");

        // 1-cycle glitch back to 0 -- must NOT propagate
        bouncy = 1'b0;
        @(posedge clk);
        bouncy = 1'b1;
        repeat (CLKS_TO_STABLE + 4) @(posedge clk);
        check(1'b1, "1-cycle glitch filtered");

        // Bouncing sequence: alternates a few times, then settles to 0
        repeat (4) begin
            bouncy = 1'b0; @(posedge clk);
            bouncy = 1'b1; @(posedge clk);
        end
        bouncy = 1'b0;
        repeat (CLKS_TO_STABLE + 6) @(posedge clk);
        check(1'b0, "bouncing settles after window");

        $display("=== %0d passed, %0d failed ===", passes, fails);
        $finish;
    end

    initial begin
        #50_000;
        $display("FAIL: watchdog timeout");
        $finish;
    end
endmodule
