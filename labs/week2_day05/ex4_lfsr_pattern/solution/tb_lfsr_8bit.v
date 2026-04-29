// Minimal testbench for lfsr_8bit — runs the LFSR for a few hundred cycles.
`timescale 1ns/1ps

module tb_lfsr_8bit;
    reg        i_clk = 0;
    reg        i_reset = 1;
    reg        i_enable = 0;
    wire [7:0] o_lfsr;
    wire       o_valid;

    always #20 i_clk = ~i_clk;  // 25 MHz

    lfsr_8bit dut (
        .i_clk(i_clk), .i_reset(i_reset), .i_enable(i_enable),
        .o_lfsr(o_lfsr), .o_valid(o_valid)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_lfsr_8bit);
        #100 i_reset = 0;
        i_enable = 1;
        #20000;
        $finish;
    end
endmodule
