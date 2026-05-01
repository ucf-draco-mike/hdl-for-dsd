// =============================================================================
// tb_uart_tx_assertions.sv -- extracted from day14_ex01_uart_tx_assertions.sv
// =============================================================================
`timescale 1ns/1ps

module tb_uart_tx_assertions;

    localparam int CLK_FREQ     = 1_000;
    localparam int BAUD_RATE    = 100;
    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    logic       clk = 0, reset = 1, valid = 0;
    logic [7:0] data;
    logic       busy, tx;

    uart_tx_asserted #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .i_clk(clk), .i_reset(reset),
        .i_valid(valid), .i_data(data),
        .o_busy(busy), .o_tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_uart_tx_assertions.vcd");
        $dumpvars(0, tb_uart_tx_assertions);

        $display("\n=== UART TX Assertion-Enhanced Testbench ===\n");
        $display("Assertions are monitoring continuously...\n");

        // Reset sequence
        repeat(5) @(posedge clk);
        reset = 0;
        repeat(5) @(posedge clk);

        // Normal transmission -- assertions should NOT fire
        $display("--- Test 1: Normal byte 'A' (0x41) ---");
        data = 8'h41;
        valid = 1;
        @(posedge clk);
        valid = 0;

        // Wait for transmission to complete
        @(negedge busy);
        repeat(CLKS_PER_BIT * 2) @(posedge clk);

        // Normal transmission -- boundary value 0xFF
        $display("--- Test 2: Boundary byte 0xFF ---");
        data = 8'hFF;
        valid = 1;
        @(posedge clk);
        valid = 0;

        @(negedge busy);
        repeat(CLKS_PER_BIT * 2) @(posedge clk);

        // Normal transmission -- boundary value 0x00
        $display("--- Test 3: Boundary byte 0x00 ---");
        data = 8'h00;
        valid = 1;
        @(posedge clk);
        valid = 0;

        @(negedge busy);
        repeat(CLKS_PER_BIT * 2) @(posedge clk);

        $display("\n=== All tests complete. ===");
        $display("If no assertion errors above, all protocol checks passed.\n");
        $finish;
    end
endmodule
