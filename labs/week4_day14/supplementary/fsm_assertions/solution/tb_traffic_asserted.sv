// Minimal SystemVerilog testbench for traffic_asserted -- runs the FSM through
// a few cycles of the timer so assertions exercise transitions.
`timescale 1ns/1ps

module tb_traffic_asserted;
    logic       i_clk = 0;
    logic       i_reset = 1;
    logic [2:0] o_light;

    always #20 i_clk = ~i_clk;  // 25 MHz

    traffic_asserted dut (
        .i_clk(i_clk), .i_reset(i_reset),
        .o_light(o_light)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_traffic_asserted);
        #200 i_reset = 0;
        #5000;
        $finish;
    end
endmodule
