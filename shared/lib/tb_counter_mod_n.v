// =============================================================================
// tb_counter_mod_n.v -- Self-checking testbench for counter_mod_n
// =============================================================================
`timescale 1ns/1ps
module tb_counter_mod_n;
    parameter N   = 4;
    parameter MAX = 10;
    parameter CLK_PERIOD = 10;

    reg  i_clk, i_reset, i_enable;
    wire [N-1:0] o_count;
    wire         o_tick;

    counter_mod_n #(.N(N), .MAX(MAX)) dut (
        .i_clk(i_clk), .i_reset(i_reset), .i_enable(i_enable),
        .o_count(o_count), .o_tick(o_tick)
    );

    initial i_clk = 0;
    always #(CLK_PERIOD/2) i_clk = ~i_clk;

    integer pass_count = 0, fail_count = 0;

    task check_count;
        input [N-1:0] expected;
        input [8*40-1:0] name;
        @(posedge i_clk); #1;
        if (o_count !== expected) begin
            $display("FAIL: %0s -- expected %0d got %0d", name, expected, o_count);
            fail_count = fail_count + 1;
        end else begin
            $display("PASS: %0s (count=%0d)", name, o_count);
            pass_count = pass_count + 1;
        end
    endtask

    integer i;
    initial begin
        $dumpfile("dump.vcd"); $dumpvars(0, tb_counter_mod_n);
        i_reset = 1; i_enable = 0;
        @(posedge i_clk); #1;
        i_reset = 0;

        // Test 1: Count to MAX-1 and wrap
        i_enable = 1;
        for (i = 0; i < MAX - 1; i = i + 1) begin
            @(posedge i_clk); #1;
        end
        // Should be at MAX-1 now, tick should be high
        if (o_count !== MAX-1 || o_tick !== 1'b1) begin
            $display("FAIL: Expected count=%0d and tick=1 at rollover, got count=%0d tick=%b",
                      MAX-1, o_count, o_tick);
            fail_count = fail_count + 1;
        end else begin
            $display("PASS: Count reached MAX-1 with tick asserted");
            pass_count = pass_count + 1;
        end

        // After one more cycle, should wrap to 0
        @(posedge i_clk); #1;
        if (o_count !== 0) begin
            $display("FAIL: Expected wrap to 0, got %0d", o_count);
            fail_count = fail_count + 1;
        end else begin
            $display("PASS: Counter wrapped to 0");
            pass_count = pass_count + 1;
        end

        // Test 2: Reset mid-count
        i_enable = 1;
        @(posedge i_clk); @(posedge i_clk); @(posedge i_clk); #1;
        i_reset = 1;
        @(posedge i_clk); #1;
        i_reset = 0;
        if (o_count !== 0) begin
            $display("FAIL: Reset did not clear counter -- got %0d", o_count);
            fail_count = fail_count + 1;
        end else begin
            $display("PASS: Synchronous reset works");
            pass_count = pass_count + 1;
        end

        // Test 3: Enable = 0 should freeze count
        i_enable = 0;
        @(posedge i_clk); @(posedge i_clk); #1;
        if (o_count !== 0) begin
            $display("FAIL: Counter advanced with enable=0");
            fail_count = fail_count + 1;
        end else begin
            $display("PASS: Enable=0 freezes counter");
            pass_count = pass_count + 1;
        end

        $display("\n=== counter_mod_n: %0d passed, %0d failed ===", pass_count, fail_count);
        $finish;
    end
endmodule
