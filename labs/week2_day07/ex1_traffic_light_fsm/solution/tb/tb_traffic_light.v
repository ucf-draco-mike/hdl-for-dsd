// =============================================================================
// tb_traffic_light.v -- Traffic Light FSM Testbench (Solution)
// Day 7, Exercise 1
// =============================================================================

`timescale 1ns / 1ps
`define SIMULATION

module tb_traffic_light;

    reg  clk, reset;
    wire [2:0] light;

    traffic_light uut (
        .i_clk(clk), .i_reset(reset), .o_light(light)
    );

    initial clk = 0;
    always #20 clk = ~clk;

    integer test_count = 0, fail_count = 0;

    task check_state;
        input [2:0] expected_light;
        input [80*8-1:0] label;
    begin
        test_count = test_count + 1;
        @(posedge clk); #1;
        if (light !== expected_light) begin
            fail_count = fail_count + 1;
            $display("FAIL [%0t]: %0s -- expected %b, got %b",
                     $time, label, expected_light, light);
        end else begin
            $display("PASS [%0t]: %0s (light=%b)", $time, label, light);
        end
    end
    endtask

    task wait_clks;
        input integer n;
        begin repeat (n) @(posedge clk); end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_light);

        reset = 1;
        wait_clks(3);
        reset = 0;
        @(posedge clk); #1;

        // Test 1: Initial state
        check_state(3'b001, "After reset: GREEN");

        // Test 2: GREEN -> YELLOW
        wait_clks(9);  // already 1 cycle in, need 9 more to hit GREEN_TIME=10
        check_state(3'b010, "After GREEN timer: YELLOW");

        // Test 3: YELLOW -> RED
        wait_clks(3);  // YELLOW_TIME = 4, already 1 cycle
        check_state(3'b100, "After YELLOW timer: RED");

        // Test 4: RED -> GREEN
        wait_clks(7);  // RED_TIME = 8, already 1 cycle
        check_state(3'b001, "After RED timer: GREEN (full cycle)");

        // Test 5: Mid-state reset
        wait_clks(3);
        reset = 1;
        wait_clks(2);
        reset = 0;
        check_state(3'b001, "After mid-state reset: GREEN");

        $display("");
        $display("========================================");
        $display("Traffic Light: %0d / %0d tests passed",
                 test_count - fail_count, test_count);
        if (fail_count > 0)
            $display("  *** %0d FAILURES ***", fail_count);
        else
            $display("  All tests passed!");
        $display("========================================");
        $finish;
    end

endmodule
