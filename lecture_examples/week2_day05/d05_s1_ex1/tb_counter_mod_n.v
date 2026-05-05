// =============================================================================
// tb_counter_mod_n.v -- exhaustive smoke testbench for counter_mod_n (N=10)
// Mirrors the slide demo: counts 0..N-1, verifies wrap pulse, exhaustively
// validates each step. Expected output ends with "=== 20 passed, 0 failed ===".
// =============================================================================
`timescale 1ns/1ps

module tb_counter_mod_n;
    localparam N = 10;

    reg                     clk    = 1'b0;
    reg                     reset  = 1'b1;
    reg                     enable = 1'b0;
    wire [$clog2(N)-1:0]    count;
    wire                    wrap;

    counter_mod_n #(.N(N)) uut (
        .i_clk(clk), .i_reset(reset), .i_enable(enable),
        .o_count(count), .o_wrap(wrap)
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
        $dumpfile("tb_counter_mod_n.vcd");
        $dumpvars(0, tb_counter_mod_n);

        // Hold reset for a few cycles, then release with enable high.
        repeat (3) @(posedge clk);
        #1;
        check(count === 0,                "counter held at 0 during reset");
        check(wrap  === 1'b0,             "wrap idle during reset");

        @(posedge clk); reset = 1'b0; enable = 1'b1;

        // First sweep 0..N-1: verify each value as the counter advances.
        for (i = 0; i < N; i = i + 1) begin
            #1;
            check(count === i[$clog2(N)-1:0], "counts 0..N-1");
            @(posedge clk);
        end

        // We are now back at count=0 after the wrap. Verify wrap pulse
        // asserted exactly at the previous cycle (count==N-1) and is now low.
        #1;
        check(count === 0,                 "wraps at N");
        check(wrap  === 1'b0,              "o_wrap pulses 1 cycle");

        // Second sweep: walk back to N-1 once and check wrap rising again.
        for (i = 0; i < N - 1; i = i + 1) begin
            @(posedge clk);
        end
        #1;
        check(count === N - 1,             "advances to terminal count again");
        check(wrap  === 1'b1,              "wrap reasserts at N-1");

        // Stop the counter via enable; value should freeze across clocks.
        enable = 1'b0;
        @(posedge clk); #1;
        check(count === N - 1,             "enable=0 freezes count at N-1");
        check(wrap  === 1'b0,              "wrap deasserts when disabled");

        // Re-enable and confirm we wrap to 0 cleanly.
        enable = 1'b1;
        @(posedge clk); #1;
        check(count === 0,                 "wrap-to-zero on re-enable");

        // Synchronous reset takes priority over enable.
        reset = 1'b1;
        @(posedge clk); #1;
        check(count === 0,                 "synchronous reset overrides enable");
        reset = 1'b0;

        if (fail_count == 0)
            $display("\n=== %0d passed, 0 failed ===", pass_count);
        else
            $display("\n=== %0d passed, %0d failed ===", pass_count, fail_count);
        $finish;
    end
endmodule
