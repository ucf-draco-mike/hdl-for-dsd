// =============================================================================
// tb_uart_rx.v -- extracted from day12_ex01_uart_rx.v
// =============================================================================
`timescale 1ns/1ps

module tb_uart_rx;

    localparam CLK_FREQ  = 1_600;
    localparam BAUD_RATE = 100;
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;  // 16

    reg  clk = 0, reset = 1;
    wire [7:0] rx_data;
    wire       rx_valid;

    // ---- Serial line (driven by our bit-banger) ----
    reg r_serial = 1;  // idle high

    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .i_clk(clk), .i_reset(reset),
        .i_rx(r_serial),
        .o_data(rx_data), .o_valid(rx_valid)
    );

    always #5 clk = ~clk;

    integer test_count = 0, fail_count = 0;

    // ---- Bit-Banger: Transmit a byte on r_serial ----
    task send_byte;
        input [7:0] b;
        integer i;
    begin
        // Start bit
        r_serial = 0;
        repeat (CLKS_PER_BIT) @(posedge clk);
        // Data bits (LSB first)
        for (i = 0; i < 8; i = i + 1) begin
            r_serial = b[i];
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
        // Stop bit
        r_serial = 1;
        repeat (CLKS_PER_BIT) @(posedge clk);
        // Inter-frame gap
        repeat (CLKS_PER_BIT) @(posedge clk);
    end
    endtask

    task check_rx;
        input [7:0] expected;
        input [8*20-1:0] name;
    begin
        test_count = test_count + 1;
        // Wait for valid pulse (with timeout)
        repeat (CLKS_PER_BIT * 12) @(posedge clk);
        if (rx_data !== expected) begin
            $display("FAIL: %0s -- expected %h, got %h", name, expected, rx_data);
            fail_count = fail_count + 1;
        end else
            $display("PASS: %0s -- received %h ('%c')", name, rx_data, rx_data);
    end
    endtask

    initial begin
        $dumpfile("tb_uart_rx.vcd");
        $dumpvars(0, tb_uart_rx);

        $display("\n=== UART RX Testbench ===\n");

        repeat(10) @(posedge clk);
        reset = 0;
        repeat(10) @(posedge clk);

        // Test 1: 'H' (0x48)
        fork
            send_byte(8'h48);
            check_rx(8'h48, "Byte 'H'");
        join

        // Test 2: 0xA5
        fork
            send_byte(8'hA5);
            check_rx(8'hA5, "Byte 0xA5");
        join

        // Test 3: 0x00
        fork
            send_byte(8'h00);
            check_rx(8'h00, "Byte 0x00");
        join

        // Test 4: 0xFF
        fork
            send_byte(8'hFF);
            check_rx(8'hFF, "Byte 0xFF");
        join

        $display("\n=== SUMMARY ===");
        $display("Tests: %0d  Passed: %0d  Failed: %0d",
                 test_count, test_count - fail_count, fail_count);
        if (fail_count == 0)
            $display("\n*** ALL TESTS PASSED ***\n");
        else
            $display("\n*** %0d FAILURES ***\n", fail_count);
        $finish;
    end
endmodule
