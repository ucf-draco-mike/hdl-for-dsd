// =============================================================================
// tb_led_blink_rates.v -- Self-checking testbench for led_blink_rates.
//
// Verifies the four observable properties of the multi-rate blinker:
//   (a) every counter increments by 1 each clock,
//   (b) each counter rolls over to 0 at its own terminal value,
//   (c) the matching LED toggles on that rollover,
//   (d) the four rates differ — counter widths/terminals stay independent.
//
// We use `force` to jump each counter near its rollover so simulation
// completes in microseconds instead of waiting 100M cycles.
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
    reg [26:0] before_count;
    reg        led_before;

    task check(input cond, input [255:0] name);
        if (!cond) begin $display("FAIL: %0s", name); fails = fails + 1; end
        else      $display("PASS: %0s", name);
    endtask

    initial begin
        $dumpfile("tb_led_blink_rates.vcd");
        $dumpvars(0, tb_led_blink_rates);

        // ------------------------------------------------------------------
        // (a) Every counter increments by 1 each clock
        // ------------------------------------------------------------------
        force dut.r_count1 = 27'd0;
        force dut.r_count2 = 27'd0;
        force dut.r_count3 = 27'd0;
        force dut.r_count4 = 27'd0;
        @(posedge clk); #1;
        release dut.r_count1; release dut.r_count2;
        release dut.r_count3; release dut.r_count4;

        before_count = dut.r_count1;
        @(posedge clk); #1;
        check(dut.r_count1 === before_count + 27'd1, "count1 increments by 1");
        check(dut.r_count2 === before_count + 27'd1, "count2 increments by 1");
        check(dut.r_count3 === before_count + 27'd1, "count3 increments by 1");
        check(dut.r_count4 === before_count + 27'd1, "count4 increments by 1");

        // ------------------------------------------------------------------
        // (b)+(c) Rate 1: counter1 rolls over at T1 and led1 toggles
        // ------------------------------------------------------------------
        force dut.r_count1 = 27'd24_999_998;
        force dut.r_led1   = 1'b0;
        @(posedge clk); #1;
        release dut.r_count1; release dut.r_led1;
        @(posedge clk); #1;
        check(dut.r_count1 === 27'd24_999_999, "count1 reaches terminal T1");
        led_before = dut.r_led1;
        @(posedge clk); #1;
        check(dut.r_count1 === 27'd0,           "count1 rolls over to 0 at T1");
        check(dut.r_led1   === ~led_before,     "led1 toggles at T1 rollover");

        // ------------------------------------------------------------------
        // Rate 2: counter2 rolls over at T2 and led2 toggles
        // ------------------------------------------------------------------
        force dut.r_count2 = 27'd49_999_998;
        force dut.r_led2   = 1'b0;
        @(posedge clk); #1;
        release dut.r_count2; release dut.r_led2;
        @(posedge clk); #1;
        check(dut.r_count2 === 27'd49_999_999, "count2 reaches terminal T2");
        led_before = dut.r_led2;
        @(posedge clk); #1;
        check(dut.r_count2 === 27'd0,           "count2 rolls over to 0 at T2");
        check(dut.r_led2   === ~led_before,     "led2 toggles at T2 rollover");

        // ------------------------------------------------------------------
        // Rate 3: counter3 rolls over at T3 and led3 toggles
        // ------------------------------------------------------------------
        force dut.r_count3 = 27'd74_999_998;
        force dut.r_led3   = 1'b0;
        @(posedge clk); #1;
        release dut.r_count3; release dut.r_led3;
        @(posedge clk); #1;
        check(dut.r_count3 === 27'd74_999_999, "count3 reaches terminal T3");
        led_before = dut.r_led3;
        @(posedge clk); #1;
        check(dut.r_count3 === 27'd0,           "count3 rolls over to 0 at T3");
        check(dut.r_led3   === ~led_before,     "led3 toggles at T3 rollover");

        // ------------------------------------------------------------------
        // Rate 4: counter4 rolls over at T4 and led4 toggles
        // ------------------------------------------------------------------
        force dut.r_count4 = 27'd99_999_998;
        force dut.r_led4   = 1'b0;
        @(posedge clk); #1;
        release dut.r_count4; release dut.r_led4;
        @(posedge clk); #1;
        check(dut.r_count4 === 27'd99_999_999, "count4 reaches terminal T4");
        led_before = dut.r_led4;
        @(posedge clk); #1;
        check(dut.r_count4 === 27'd0,           "count4 rolls over to 0 at T4");
        check(dut.r_led4   === ~led_before,     "led4 toggles at T4 rollover");

        // ------------------------------------------------------------------
        // (d) Rates are independent — toggling led1 must NOT toggle led4
        // ------------------------------------------------------------------
        force dut.r_count1 = 27'd24_999_998;
        force dut.r_count4 = 27'd0;
        force dut.r_led1   = 1'b0;
        force dut.r_led4   = 1'b0;
        @(posedge clk); #1;
        release dut.r_count1; release dut.r_count4;
        release dut.r_led1;   release dut.r_led4;
        @(posedge clk); #1;   // count1 -> T1
        @(posedge clk); #1;   // count1 wraps, led1 toggles; count4 still small
        check(dut.r_led1 === 1'b1, "led1 toggled (rate 1 fired)");
        check(dut.r_led4 === 1'b0, "led4 unchanged (rate 4 not yet fired)");

        if (fails == 0) $display("=== 17 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
