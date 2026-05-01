// =============================================================================
// tb_traffic_light.v -- Traffic Light FSM Testbench (Starter)
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

    // ---- TODO: Implement check_state task ----
    // task check_state;
    //   input [2:0] expected_light;
    //   input [80*8-1:0] label;
    // begin
    //   test_count = test_count + 1;
    //   @(posedge clk); #1;
    //   if (light !== expected_light) begin
    //     fail_count = fail_count + 1;
    //     $display("FAIL [%0t]: %0s -- expected %b, got %b",
    //              $time, label, expected_light, light);
    //   end else begin
    //     $display("PASS [%0t]: %0s (light=%b)", $time, label, light);
    //   end
    // end
    // endtask

    task wait_clks;
        input integer n;
        begin repeat (n) @(posedge clk); end
    endtask

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_light);

        // Reset
        reset = 1;
        wait_clks(3);
        reset = 0;
        @(posedge clk); #1;

        // ---- TODO: Test 1 -- Verify initial state is GREEN ----
        // check_state(3'b001, "After reset: GREEN");

        // ---- TODO: Test 2 -- Wait GREEN_TIME, verify YELLOW ----
        // GREEN_TIME = 10 in simulation
        // wait_clks(10);
        // check_state(3'b010, "After GREEN timer: YELLOW");

        // ---- TODO: Test 3 -- Wait YELLOW_TIME, verify RED ----

        // ---- TODO: Test 4 -- Wait RED_TIME, verify GREEN ----

        // ---- TODO: Test 5 -- Mid-state reset ----
        // wait_clks(3); reset = 1; wait_clks(2); reset = 0;
        // check_state(3'b001, "After mid-state reset: GREEN");

        // Summary
        $display("");
        $display("========================================");
        $display("Traffic Light: %0d / %0d tests passed",
                 test_count - fail_count, test_count);
        $display("========================================");
        $finish;
    end

endmodule
