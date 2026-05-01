// =============================================================================
// tb_button_logic.v -- Baseline TB for button_logic (Day 1, Ex 3)
// Accelerated HDL for Digital System Design - Dr. Mike Borowczak - ECE - CECS - UCF
// =============================================================================
// Exhaustively tests all 16 switch combinations for AND, OR, XOR, NOT outputs.
`timescale 1ns/1ps

module tb_button_logic;
    reg  sw1, sw2, sw3, sw4;
    wire led1, led2, led3, led4;

    button_logic dut (
        .i_switch1(sw1), .i_switch2(sw2),
        .i_switch3(sw3), .i_switch4(sw4),
        .o_led1(led1), .o_led2(led2),
        .o_led3(led3), .o_led4(led4)
    );

    integer pass_count = 0, fail_count = 0;

    task check;
        input exp1, exp2, exp3, exp4;
        begin
            #1;
            if (led1===exp1 && led2===exp2 && led3===exp3 && led4===exp4) begin
                $display("PASS: sw=%b%b%b%b -> led=%b%b%b%b",
                         sw1,sw2,sw3,sw4, led1,led2,led3,led4);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: sw=%b%b%b%b -> led=%b%b%b%b (expected %b%b%b%b)",
                         sw1,sw2,sw3,sw4, led1,led2,led3,led4, exp1,exp2,exp3,exp4);
                fail_count = fail_count + 1;
            end
        end
    endtask

    integer i;
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_button_logic);

        for (i = 0; i < 16; i = i + 1) begin
            {sw1, sw2, sw3, sw4} = i[3:0];
            // LED1 = sw1 AND sw2, LED2 = sw3 OR sw4,
            // LED3 = sw1 XOR sw2, LED4 = NOT sw1
            check(sw1 & sw2, sw3 | sw4, sw1 ^ sw2, ~sw1);
        end

        $display("\n=== tb_button_logic: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
