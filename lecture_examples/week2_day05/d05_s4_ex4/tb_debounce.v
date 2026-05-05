// =============================================================================
// tb_debounce.v -- Smoke testbench for debounce module
// Drives a noisy "press" with simulated bounces, then a stable hold, and
// confirms o_clean only flips after CLKS_STABLE cycles of agreement.
// =============================================================================
`timescale 1ns/1ps

module tb_debounce;
    localparam CLKS_STABLE = 10;

    reg  clk    = 1'b0;
    reg  reset  = 1'b1;
    reg  noisy  = 1'b0;
    wire clean;

    debounce #(.CLKS_STABLE(CLKS_STABLE)) uut (
        .i_clk(clk), .i_reset(reset), .i_noisy(noisy), .o_clean(clean)
    );

    always #20 clk = ~clk;

    integer pass_count = 0;
    integer fail_count = 0;
    integer i;
    task check;
        input        cond;
        input [511:0] msg;
        begin
            if (cond) begin
                $display("PASS: %0s", msg);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %0s", msg);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("tb_debounce.vcd");
        $dumpvars(0, tb_debounce);

        // Hold reset, then release with noisy=0.
        repeat (3) @(posedge clk);
        @(posedge clk); reset = 1'b0;
        #1;
        check(clean === 1'b0, "idle low after reset");

        // Bounce a press: short alternating pulses, none of them long enough
        // to satisfy CLKS_STABLE. Output must stay 0.
        for (i = 0; i < 5; i = i + 1) begin
            noisy = 1'b1; repeat (2) @(posedge clk);
            noisy = 1'b0; repeat (2) @(posedge clk);
        end
        #1;
        check(clean === 1'b0, "bounces do not propagate");

        // Stable press: hold high for >= CLKS_STABLE cycles.
        noisy = 1'b1;
        repeat (CLKS_STABLE + 2) @(posedge clk);
        #1;
        check(clean === 1'b1, "synced follows async with stable hold");

        // Release with bounces: short alternating pulses.
        for (i = 0; i < 5; i = i + 1) begin
            noisy = 1'b0; repeat (2) @(posedge clk);
            noisy = 1'b1; repeat (2) @(posedge clk);
        end
        #1;
        check(clean === 1'b1, "release bounces do not propagate");

        // Stable release.
        noisy = 1'b0;
        repeat (CLKS_STABLE + 2) @(posedge clk);
        #1;
        check(clean === 1'b0, "stable release accepted");

        // Reset clears the clean output mid-press.
        noisy = 1'b1;
        repeat (CLKS_STABLE + 2) @(posedge clk);
        #1;
        check(clean === 1'b1, "second press accepted");
        reset = 1'b1;
        @(posedge clk); #1;
        check(clean === 1'b0, "reset clears clean output");
        reset = 1'b0;

        // Sub-window noise burst followed by long settle: confirm no
        // accidental acceptance during partial counts.
        noisy = 1'b0;
        repeat (CLKS_STABLE + 2) @(posedge clk);
        // Brief noise (less than CLKS_STABLE high cycles) then back to 0.
        noisy = 1'b1; repeat (CLKS_STABLE - 2) @(posedge clk);
        noisy = 1'b0;
        repeat (CLKS_STABLE + 2) @(posedge clk);
        #1;
        check(clean === 1'b0, "partial-window noise rejected");

        // Final clean press confirms recovery.
        noisy = 1'b1;
        repeat (CLKS_STABLE + 2) @(posedge clk);
        #1;
        check(clean === 1'b1, "recovery: clean press still works");

        if (fail_count == 0)
            $display("\n=== %0d passed, 0 failed ===", pass_count);
        else
            $display("\n=== %0d passed, %0d failed ===", pass_count, fail_count);
        $finish;
    end
endmodule
