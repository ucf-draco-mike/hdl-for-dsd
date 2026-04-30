// =============================================================================
// tb_debounce.v — Smoke testbench for debounce
// The DUT has no explicit reset, so we initialize internal state via force/
// release to put the synchronizer + counter in a known state at t=0.
// =============================================================================
`timescale 1ns/1ps

module tb_debounce;
    reg  clk = 1'b0;
    reg  bouncy = 1'b1;
    wire clean;

    debounce #(.CLKS_TO_STABLE(10)) uut (
        .i_clk(clk), .i_bouncy(bouncy), .o_clean(clean)
    );

    always #20 clk = ~clk;

    integer fails = 0;
    integer i;

    initial begin
        $dumpfile("tb_debounce.vcd");
        $dumpvars(0, tb_debounce);

        // Force a known idle state (button released, output high)
        force uut.r_sync_0 = 1'b1;
        force uut.r_sync_1 = 1'b1;
        force uut.o_clean  = 1'b1;
        force uut.r_count  = 0;
        @(posedge clk);
        release uut.r_sync_0;
        release uut.r_sync_1;
        release uut.o_clean;
        release uut.r_count;
        @(posedge clk);

        // Bounce a press: toggle bouncy several times
        for (i = 0; i < 5; i = i + 1) begin
            bouncy = 1'b0; repeat (2) @(posedge clk);
            bouncy = 1'b1; repeat (2) @(posedge clk);
        end

        // Stable press for >= CLKS_TO_STABLE cycles
        bouncy = 1'b0;
        repeat (20) @(posedge clk);
        #1;
        if (clean !== 1'b0) begin
            $display("FAIL: clean should be 0 after stable press, got %b", clean);
            fails = fails + 1;
        end else
            $display("PASS: debounced press detected");

        // Stable release
        bouncy = 1'b1;
        repeat (20) @(posedge clk);
        #1;
        if (clean !== 1'b1) begin
            $display("FAIL: clean should be 1 after release, got %b", clean);
            fails = fails + 1;
        end else
            $display("PASS: debounced release detected");

        if (fails == 0) $display("=== 2 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
