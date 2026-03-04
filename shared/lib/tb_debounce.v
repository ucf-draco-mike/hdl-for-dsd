// =============================================================================
// tb_debounce.v — Self-checking testbench for debounce module
// =============================================================================
`timescale 1ns/1ps
module tb_debounce;
    parameter CLK_PERIOD    = 40;    // 25 MHz
    parameter DEBOUNCE_CNT  = 20;    // Small for fast simulation

    reg  i_clk, i_switch;
    wire o_switch;

    debounce #(.DEBOUNCE_CNT(DEBOUNCE_CNT)) dut (
        .i_clk    (i_clk),
        .i_switch (i_switch),
        .o_switch (o_switch)
    );

    initial i_clk = 0;
    always #(CLK_PERIOD/2) i_clk = ~i_clk;

    integer pass_count = 0, fail_count = 0;

    task check;
        input     expected;
        input [8*40-1:0] name;
        begin
            if (o_switch !== expected) begin
                $display("FAIL: %0s — expected %b got %b", name, expected, o_switch);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: %0s", name);
                pass_count = pass_count + 1;
            end
        end
    endtask

    task wait_cycles;
        input integer n;
        repeat(n) @(posedge i_clk);
    endtask

    initial begin
        $dumpfile("dump.vcd"); $dumpvars(0, tb_debounce);
        i_switch = 0;
        wait_cycles(5);
        check(0, "Initial output low");

        // Test 1: Stable press (hold > DEBOUNCE_CNT cycles)
        i_switch = 1;
        wait_cycles(DEBOUNCE_CNT + 5);
        check(1, "Stable press detected");

        // Test 2: Glitch (pulse shorter than DEBOUNCE_CNT)
        i_switch = 0;
        wait_cycles(DEBOUNCE_CNT / 2);  // only halfway
        i_switch = 1;                    // bounce back
        wait_cycles(5);
        check(1, "Glitch rejected (still high)");

        // Test 3: Stable release
        i_switch = 0;
        wait_cycles(DEBOUNCE_CNT + 5);
        check(0, "Stable release detected");

        // Test 4: Multiple rapid bounces
        repeat(5) begin
            i_switch = ~i_switch;
            wait_cycles(DEBOUNCE_CNT / 3);
        end
        i_switch = 0;
        wait_cycles(DEBOUNCE_CNT + 5);
        check(0, "Output stable after rapid bouncing");

        $display("\n=== debounce: %0d passed, %0d failed ===", pass_count, fail_count);
        $finish;
    end
endmodule
