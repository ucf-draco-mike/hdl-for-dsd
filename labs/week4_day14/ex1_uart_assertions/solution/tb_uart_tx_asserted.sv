// Minimal SystemVerilog testbench for uart_tx_asserted — sends one byte and
// dumps a VCD. Assertions inside the DUT will check protocol invariants.
`timescale 1ns/1ps

module tb_uart_tx_asserted;
    logic       i_clk = 0;
    logic       i_reset = 1;
    logic       i_valid = 0;
    logic [7:0] i_data  = 8'h00;
    logic       o_tx, o_busy;

    always #20 i_clk = ~i_clk;  // 25 MHz

    uart_tx_asserted #(.CLK_FREQ(25_000_000), .BAUD_RATE(2_500_000)) dut (
        .i_clk(i_clk), .i_reset(i_reset),
        .i_valid(i_valid), .i_data(i_data),
        .o_tx(o_tx), .o_busy(o_busy)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_uart_tx_asserted);
        #200 i_reset = 0;
        #200 i_data = 8'hA5; i_valid = 1;
        #40  i_valid = 0;
        #50000;
        $finish;
    end
endmodule
