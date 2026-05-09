// =============================================================================
// tb_led_blink_rates.v -- Self-checking testbench for led_blink_rates.
//
// Verifies the observable properties of the single-LED blinker:
//   (a) the counter increments by 1 each clock,
//   (b) the counter rolls over to 0 at terminal value T = CLK_HZ - 1,
//   (c) o_led1 toggles on that rollover,
//   (d) o_led2, o_led3, o_led4 are tied OFF (always 0).
//
// We use `force` to jump the counter near rollover so simulation completes
// in microseconds instead of waiting 25M cycles.
// =============================================================================
`timescale 1ns/1ps

module tb_led_blink_rates;
    reg  clk = 1'b0;
    wire l1, l2, l3, l4;

    led_blink_rates dut (
        .i_clk(clk), .o_led1(l1), .o_led2(l2), .o_led3(l3), .o_led4(l4)
    );

    always #5 clk = ~clk;  // 100 MHz tb clock (sim only)

    integer fails = 0;
    reg [24:0] before_count;
    reg        led_before;

    task check(input cond, input [255:0] name);
        if (!cond) begin $display("FAIL: %0s", name); fails = fails + 1; end
        else      $display("PASS: %0s", name);
    endtask

    initial begin
        $dumpfile("tb_led_blink_rates.vcd");
        $dumpvars(0, tb_led_blink_rates);

        // ------------------------------------------------------------------
        // (a) Counter increments by 1 each clock
        // ------------------------------------------------------------------
        force dut.r_count = 25'd0;
        @(posedge clk); #1;
        release dut.r_count;

        before_count = dut.r_count;
        @(posedge clk); #1;
        check(dut.r_count === before_count + 25'd1, "count increments by 1");

        // ------------------------------------------------------------------
        // (b)+(c) Counter rolls over at T and o_led1 toggles
        // ------------------------------------------------------------------
        force dut.r_count = 25'd24_999_998;
        force dut.r_led   = 1'b0;
        @(posedge clk); #1;
        release dut.r_count; release dut.r_led;
        @(posedge clk); #1;
        check(dut.r_count === 25'd24_999_999, "count reaches terminal T");
        led_before = dut.r_led;
        @(posedge clk); #1;
        check(dut.r_count === 25'd0,         "count rolls over to 0 at T");
        check(dut.r_led   === ~led_before,   "o_led1 toggles at T rollover");

        // ------------------------------------------------------------------
        // (d) o_led2, o_led3, o_led4 are tied OFF
        // ------------------------------------------------------------------
        check(l2 === 1'b0, "o_led2 tied off");
        check(l3 === 1'b0, "o_led3 tied off");
        check(l4 === 1'b0, "o_led4 tied off");

        // Run several more cycles to confirm the off LEDs never wiggle
        repeat (10) @(posedge clk);
        #1;
        check(l2 === 1'b0, "o_led2 stays off");
        check(l3 === 1'b0, "o_led3 stays off");
        check(l4 === 1'b0, "o_led4 stays off");

        if (fails == 0) $display("=== 10 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
