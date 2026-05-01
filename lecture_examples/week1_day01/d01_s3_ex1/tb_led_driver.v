// =============================================================================
// tb_led_driver.v -- Smoke testbench for led_driver
// =============================================================================
`timescale 1ns/1ps

module tb_led_driver;
    reg  switch1;
    wire led1;

    led_driver dut (
        .i_switch1 (switch1),
        .o_led1    (led1)
    );

    integer fails = 0;

    task check(input exp, input act, input [255:0] name);
        if (act !== exp) begin
            $display("FAIL: %0s -- expected %b, got %b", name, exp, act);
            fails = fails + 1;
        end else
            $display("PASS: %0s = %b", name, act);
    endtask

    initial begin
        $dumpfile("tb_led_driver.vcd");
        $dumpvars(0, tb_led_driver);

        switch1 = 1'b0; #10; check(1'b0, led1, "switch=0 -> led=0");
        switch1 = 1'b1; #10; check(1'b1, led1, "switch=1 -> led=1");
        switch1 = 1'b0; #10; check(1'b0, led1, "switch=0 -> led=0 (toggle)");

        if (fails == 0) $display("=== 3 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
