// =============================================================================
// tb_traffic_light.v -- extracted from day07_ex01_fsm_template.v
// =============================================================================
`timescale 1ns/1ps

module tb_traffic_light;
    reg  clk = 0, reset = 1;
    wire red, yellow, green;

    traffic_light uut (
        .i_clk(clk), .i_reset(reset),
        .o_red(red), .o_yellow(yellow), .o_green(green)
    );

    always #20 clk = ~clk;  // 25 MHz

    integer test_count = 0, fail_count = 0;

    task check_state;
        input exp_r, exp_y, exp_g;
        input [8*20-1:0] name;
    begin
        test_count = test_count + 1;
        if (red !== exp_r || yellow !== exp_y || green !== exp_g) begin
            $display("FAIL: %0s -- R=%b Y=%b G=%b (expected R=%b Y=%b G=%b)",
                     name, red, yellow, green, exp_r, exp_y, exp_g);
            fail_count = fail_count + 1;
        end else
            $display("PASS: %0s -- R=%b Y=%b G=%b", name, red, yellow, green);
    end
    endtask

    task wait_cycles;
        input integer n;
        integer i;
        for (i = 0; i < n; i = i + 1) @(posedge clk);
    endtask

    initial begin
        $dumpfile("tb_traffic_light.vcd");
        $dumpvars(0, tb_traffic_light);

        $display("\n=== Traffic Light FSM Testbench ===\n");

        // Reset
        wait_cycles(3);
        reset = 0;
        @(posedge clk); #1;
        check_state(0, 0, 1, "After reset: GREEN");

        // Wait for GREEN -> YELLOW transition (GREEN_TIME = 10 cycles)
        wait_cycles(10);
        @(posedge clk); #1;
        check_state(0, 1, 0, "GREEN->YELLOW");

        // Wait for YELLOW -> RED transition (YELLOW_TIME = 4 cycles)
        wait_cycles(4);
        @(posedge clk); #1;
        check_state(1, 0, 0, "YELLOW->RED");

        // Wait for RED -> GREEN transition (RED_TIME = 10 cycles)
        wait_cycles(10);
        @(posedge clk); #1;
        check_state(0, 0, 1, "RED->GREEN (cycle 2)");

        // Test mid-cycle reset
        wait_cycles(5);
        reset = 1;
        @(posedge clk); #1;
        reset = 0;
        @(posedge clk); #1;
        check_state(0, 0, 1, "Mid-cycle reset -> GREEN");

        // Summary
        $display("\n=== %0d passed, %0d failed ===",
                 test_count - fail_count, fail_count);
        if (fail_count == 0)
            $display("*** ALL TESTS PASSED ***");
        else
            $display("*** %0d FAILURES ***", fail_count);
        $finish;
    end
endmodule
