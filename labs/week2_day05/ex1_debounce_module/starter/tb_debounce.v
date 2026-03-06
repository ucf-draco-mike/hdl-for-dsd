// =============================================================================
// tb_debounce.v — Testbench for Debounce Module (Starter)
// Day 5, Exercise 1
// =============================================================================

`timescale 1ns / 1ps

module tb_debounce;

    reg  clk;
    reg  bouncy;
    wire clean;

    // Small threshold for simulation
    debounce #(.CLKS_TO_STABLE(10)) uut (
        .i_clk(clk),
        .i_bouncy(bouncy),
        .o_clean(clean)
    );

    // 25 MHz clock (40 ns period)
    initial clk = 0;
    always #20 clk = ~clk;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_debounce);

        bouncy = 1;  // not pressed (active-high)
        #500;

        // ---- TODO: Simulate a bouncy press ----
        // Toggle bouncy rapidly 5+ times, then settle at 0
        // Example:
        //   bouncy = 0; #60;
        //   bouncy = 1; #40;
        //   bouncy = 0; #80;
        //   ... etc
        //   bouncy = 0;       // final settle
        //   #2000;            // wait beyond threshold


        // ---- TODO: Simulate a bouncy release ----
        // Toggle back to 1 with bouncing, then settle


        // ---- TODO: Verify ----
        // Count transitions on clean — should be exactly 2
        // (one rising edge for press, one rising edge for release)

        $display("=== Debounce simulation complete ===");
        $display("Inspect waveform: clean should have exactly 2 transitions");
        $finish;
    end

endmodule
