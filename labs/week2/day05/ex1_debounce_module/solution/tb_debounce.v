// =============================================================================
// tb_debounce.v — Testbench for Debounce Module (Solution)
// Day 5, Exercise 1
// =============================================================================

`timescale 1ns / 1ps

module tb_debounce;

    reg  clk;
    reg  bouncy;
    wire clean;

    debounce #(.CLKS_TO_STABLE(10)) uut (
        .i_clk(clk),
        .i_bouncy(bouncy),
        .o_clean(clean)
    );

    initial clk = 0;
    always #20 clk = ~clk;

    // Transition counter
    integer clean_transitions = 0;
    reg     clean_prev = 1;

    always @(posedge clk) begin
        if (clean !== clean_prev) begin
            clean_transitions = clean_transitions + 1;
            $display("[%0t] clean transitioned: %b -> %b (transition #%0d)",
                     $time, clean_prev, clean, clean_transitions);
        end
        clean_prev <= clean;
    end

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_debounce);

        bouncy = 1;  // not pressed
        #500;

        // Bouncy press: toggle 5 times, then settle low
        bouncy = 0; #60;
        bouncy = 1; #40;
        bouncy = 0; #80;
        bouncy = 1; #30;
        bouncy = 0; #50;
        bouncy = 1; #20;
        bouncy = 0;        // final press — stays low
        #2000;             // wait well beyond threshold

        // Bouncy release: toggle, then settle high
        bouncy = 1; #40;
        bouncy = 0; #30;
        bouncy = 1; #60;
        bouncy = 0; #20;
        bouncy = 1;        // final release — stays high
        #2000;

        // Report
        $display("");
        $display("========================================");
        if (clean_transitions == 2)
            $display("PASS: clean had exactly 2 transitions (press + release)");
        else
            $display("FAIL: expected 2 transitions, got %0d", clean_transitions);
        $display("========================================");
        $finish;
    end

endmodule
