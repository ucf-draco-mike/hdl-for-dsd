// Minimal testbench for led_on — drives no inputs (none exist),
// observes the constant output, and dumps a VCD for waveform viewing.
`timescale 1ns/1ps

module tb_led_on;
    wire o_led1;

    led_on dut (.o_led1(o_led1));

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_led_on);
        #20;
        $display("[tb_led_on] o_led1 = %b (expected 1)", o_led1);
        $finish;
    end
endmodule
