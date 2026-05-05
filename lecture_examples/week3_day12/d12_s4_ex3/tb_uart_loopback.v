// =============================================================================
// tb_uart_loopback.v — Functional self-check for uart_loopback (RX→TX echo).
//
// Drives a serial byte onto i_uart_rx at the configured baud rate, then
// samples o_uart_tx and decodes the echoed byte. PASS when the byte that
// went in matches the byte that came back. This is the simulation-side
// version of the "host terminal types, board echoes" hardware demo.
// =============================================================================
`timescale 1ns/1ps

module tb_uart_loopback;
    // Tiny clock/baud so RX oversampling math (CLKS_PER_BIT/16) stays >= 1.
    localparam CLK_FREQ  = 1_600;
    localparam BAUD_RATE = 100;
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    reg  clk = 1'b0;
    reg  rx_line = 1'b1;          // idle high
    wire tx_line;
    wire l1, l2, l3, l4;
    wire s1a,s1b,s1c,s1d,s1e,s1f,s1g, s2a,s2b,s2c,s2d,s2e,s2f,s2g;

    uart_loopback #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) dut (
        .i_clk(clk), .i_uart_rx(rx_line), .o_uart_tx(tx_line),
        .o_led1(l1), .o_led2(l2), .o_led3(l3), .o_led4(l4),
        .o_segment1_a(s1a), .o_segment1_b(s1b), .o_segment1_c(s1c),
        .o_segment1_d(s1d), .o_segment1_e(s1e), .o_segment1_f(s1f),
        .o_segment1_g(s1g),
        .o_segment2_a(s2a), .o_segment2_b(s2b), .o_segment2_c(s2c),
        .o_segment2_d(s2d), .o_segment2_e(s2e), .o_segment2_f(s2f),
        .o_segment2_g(s2g)
    );

    always #5 clk = ~clk;

    integer i;
    reg [7:0] echoed;

    // ---- Drive a byte onto rx_line in 8N1 framing (LSB first) ----
    task send_byte;
        input [7:0] b;
        integer j;
    begin
        rx_line = 0;                                    // start
        repeat (CLKS_PER_BIT) @(posedge clk);
        for (j = 0; j < 8; j = j + 1) begin
            rx_line = b[j];
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
        rx_line = 1;                                    // stop
        repeat (CLKS_PER_BIT) @(posedge clk);
    end
    endtask

    // ---- Decode tx_line back into a byte (LSB first, 8N1) ----
    task recv_byte;
        output [7:0] b;
        integer j;
    begin
        // Wait for start bit (line goes low)
        @(negedge tx_line);
        // Step to mid-bit, then sample 8 data bits at full bit periods
        repeat (CLKS_PER_BIT + CLKS_PER_BIT/2) @(posedge clk);
        for (j = 0; j < 8; j = j + 1) begin
            b[j] = tx_line;
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
    end
    endtask

    initial begin
        $dumpfile("tb_uart_loopback.vcd");
        $dumpvars(0, tb_uart_loopback);
        $display("\n=== UART loopback echo test ===\n");

        repeat (10) @(posedge clk);

        fork
            send_byte(8'h41);    // 'A'
            recv_byte(echoed);
        join

        if (echoed === 8'h41)
            $display("PASS: rx 0x41 -> tx 0x%02h ('%c')", echoed, echoed);
        else
            $display("FAIL: rx 0x41 -> tx 0x%02h (expected 0x41)", echoed);

        $display("=== %0d passed, %0d failed ===",
                 (echoed === 8'h41) ? 1 : 0,
                 (echoed === 8'h41) ? 0 : 1);
        $finish;
    end

    // safety net
    initial begin
        #(20 * CLKS_PER_BIT * 20);
        $display("FAIL: simulation timeout");
        $finish;
    end
endmodule
