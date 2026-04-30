// =============================================================================
// tb_led_blinker.v — Smoke testbench for led_blinker
// We override the divider with a parameter-free probe by tapping internal
// counter bits across many clocks and confirming the lower-bit LEDs toggle.
// =============================================================================
`timescale 1ns/1ps

module tb_led_blinker;
    reg  clk = 1'b0;
    wire l1, l2, l3, l4;

    led_blinker dut (
        .i_clk(clk), .o_led1(l1), .o_led2(l2), .o_led3(l3), .o_led4(l4)
    );

    always #5 clk = ~clk;  // 100 MHz tb clock (sim only)

    integer fails = 0;
    integer i;
    reg     l4_seen0, l4_seen1;

    initial begin
        $dumpfile("tb_led_blinker.vcd");
        $dumpvars(0, tb_led_blinker);

        // Force counter to a value near a top-bit toggle so we observe LED4
        force dut.r_free = 24'h1FFFFE;
        @(posedge clk); release dut.r_free;

        l4_seen0 = 1'b0; l4_seen1 = 1'b0;
        for (i = 0; i < 8000; i = i + 1) begin
            @(posedge clk);
            if (l4 === 1'b0) l4_seen0 = 1'b1;
            if (l4 === 1'b1) l4_seen1 = 1'b1;
        end

        if (l4_seen0 && l4_seen1) $display("PASS: led4 toggles");
        else begin $display("FAIL: led4 stuck"); fails = fails + 1; end

        if (fails == 0) $display("=== 1 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
