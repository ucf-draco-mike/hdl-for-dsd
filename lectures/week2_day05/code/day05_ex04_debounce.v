// =============================================================================
// day05_ex04_debounce.v — Counter-Based Button Debouncer
// Day 5: Counters, Shift Registers & Debouncing
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Includes built-in 2-FF synchronizer. Connect directly to raw button input.
// Pipeline: async_in → [2-FF sync] → [debounce counter] → clean output
// =============================================================================
// Build:  iverilog -DSIMULATION -o sim day05_ex04_debounce.v && vvp sim
// Synth:  yosys -p "read_verilog day05_ex04_debounce.v; synth_ice40 -top debounce"
// =============================================================================

module debounce #(
    parameter CLKS_TO_STABLE = 250_000  // 10 ms at 25 MHz (override for sim)
)(
    input  wire i_clk,
    input  wire i_bouncy,
    output reg  o_clean
);

    // ---- 2-FF Synchronizer (built-in) ----
    reg r_sync_0, r_sync_1;
    always @(posedge i_clk) begin
        r_sync_0 <= i_bouncy;
        r_sync_1 <= r_sync_0;
    end

    // ---- Debounce Counter ----
    reg [$clog2(CLKS_TO_STABLE)-1:0] r_count;

    always @(posedge i_clk) begin
        if (r_sync_1 != o_clean) begin
            // Input differs from output — count how long
            if (r_count == CLKS_TO_STABLE - 1) begin
                o_clean <= r_sync_1;    // accept new value
                r_count <= 0;
            end else
                r_count <= r_count + 1;
        end else begin
            // Input matches output — reset counter
            r_count <= 0;
        end
    end

endmodule

// =============================================================================
// Self-test: simulate noisy button input
// =============================================================================
`ifdef SIMULATION
module tb_debounce;
    reg clk = 0, bouncy = 1;
    wire clean;

    // Short threshold for simulation (10 cycles instead of 250K)
    debounce #(.CLKS_TO_STABLE(10)) uut (
        .i_clk(clk), .i_bouncy(bouncy), .o_clean(clean)
    );

    always #20 clk = ~clk;  // 25 MHz

    integer fail_count = 0;

    task bounce_press;
        // Simulate 5 bounces then stable low
        integer i;
        begin
            for (i = 0; i < 5; i = i + 1) begin
                bouncy = 0; repeat (2) @(posedge clk);
                bouncy = 1; repeat (2) @(posedge clk);
            end
            bouncy = 0;  // stable press
        end
    endtask

    initial begin
        $dumpfile("tb_debounce.vcd");
        $dumpvars(0, tb_debounce);

        // Wait for initial state to settle
        repeat (5) @(posedge clk);

        // Should start high (idle)
        #1;
        if (clean !== 1'bx && clean !== 1'b1) begin
            // Accept x or 1 at startup
        end

        // Press with bounces
        bounce_press;
        // Wait for debounce threshold + sync latency
        repeat (20) @(posedge clk);
        #1;
        if (clean !== 1'b0) begin
            $display("FAIL: clean should be 0 after stable press");
            fail_count = fail_count + 1;
        end else
            $display("PASS: Debounced press detected");

        // Hold stable
        repeat (20) @(posedge clk);

        // Release (clean, no bounce for simplicity)
        bouncy = 1;
        repeat (20) @(posedge clk);
        #1;
        if (clean !== 1'b1) begin
            $display("FAIL: clean should be 1 after release");
            fail_count = fail_count + 1;
        end else
            $display("PASS: Debounced release detected");

        if (fail_count == 0) $display("\n*** ALL TESTS PASSED ***");
        else $display("\n*** %0d FAILURES ***", fail_count);
        $finish;
    end
endmodule
`endif
