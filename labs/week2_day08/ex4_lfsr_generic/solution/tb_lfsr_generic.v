// Minimal testbench for lfsr_generic — runs default 8-bit configuration.
`timescale 1ns/1ps

module tb_lfsr_generic;
    localparam WIDTH = 8;
    reg              i_clk = 0;
    reg              i_reset = 1;
    reg              i_enable = 0;
    wire [WIDTH-1:0] o_lfsr;

    always #20 i_clk = ~i_clk;  // 25 MHz

    lfsr_generic #(.WIDTH(WIDTH), .SEED(1)) dut (
        .i_clk(i_clk), .i_reset(i_reset), .i_enable(i_enable),
        .o_lfsr(o_lfsr)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_lfsr_generic);
        #100 i_reset = 0;
        i_enable = 1;
        #20000;
        $finish;
    end
endmodule
