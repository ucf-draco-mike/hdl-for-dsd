// Minimal testbench for top_pll_demo.
//
// Note: this design uses SB_PLL40_CORE, an iCE40 hard-macro that requires
// the iverilog iCE40 cell library to simulate. Run with:
//   iverilog -g2012 -o sim.vvp tb_top_pll_demo.v top_pll_demo.v \
//       /usr/local/share/yosys/ice40/cells_sim.v
// or provide your own behavioral stub. Without the cell library, this
// testbench compiles only as a structural reference.
`timescale 1ns/1ps

module tb_top_pll_demo;
    reg  i_clk = 0;
    wire o_led1, o_led2, o_led3, o_led4;

    always #20 i_clk = ~i_clk;  // 25 MHz

    top_pll_demo dut (
        .i_clk(i_clk),
        .o_led1(o_led1), .o_led2(o_led2),
        .o_led3(o_led3), .o_led4(o_led4)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_top_pll_demo);
        #50000;
        $finish;
    end
endmodule
