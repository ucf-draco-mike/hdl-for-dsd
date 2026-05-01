// =============================================================================
// tb_uart_tx.v -- Protocol-Aware UART TX Testbench
// Day 11, Exercise 2
// =============================================================================

`timescale 1ns / 1ps

module tb_uart_tx;

    reg        clk, reset, valid;
    reg  [7:0] data;
    wire       tx, busy;

    localparam CLK_FREQ  = 1_000;  // 1 kHz for fast simulation
    localparam BAUD_RATE = 100;    // 100 baud -> 10 clocks per bit
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam CLK_PERIOD   = 500; // 500ns for 1 kHz

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) uut (
        .i_clk(clk), .i_reset(reset),
        .i_valid(valid), .i_data(data),
        .o_tx(tx), .o_busy(busy)
    );

    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    integer test_count = 0, fail_count = 0;

    // Task: capture one UART frame from the tx line
    task capture_uart_byte;
        output [7:0] captured;
        integer bit_idx;
    begin
        @(negedge tx);                           // wait for start bit
        #(CLKS_PER_BIT * CLK_PERIOD / 2);       // move to center of start bit

        if (tx !== 1'b0)
            $display("WARNING: Start bit not low at center");

        for (bit_idx = 0; bit_idx < 8; bit_idx = bit_idx + 1) begin
            #(CLKS_PER_BIT * CLK_PERIOD);        // advance to center of data bit
            captured[bit_idx] = tx;
        end

        #(CLKS_PER_BIT * CLK_PERIOD);            // move to center of stop bit
        if (tx !== 1'b1)
            $display("WARNING: Stop bit not high");
    end
    endtask

    // Task: send a byte and verify it
    task send_and_check;
        input [7:0] tx_byte;
        input [63:0] label;   // 8-char label
        reg [7:0] captured;
    begin
        @(posedge clk);
        data  = tx_byte;
        valid = 1;
        @(posedge clk);
        valid = 0;

        capture_uart_byte(captured);

        test_count = test_count + 1;
        if (captured !== tx_byte) begin
            fail_count = fail_count + 1;
            $display("FAIL [%0s]: sent=%h captured=%h", label, tx_byte, captured);
        end else begin
            $display("PASS [%0s]: %h OK", label, tx_byte);
        end

        @(negedge busy);
        repeat (5) @(posedge clk);
    end
    endtask

    initial begin
        $dumpfile("uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);

        reset = 1; valid = 0; data = 0;
        repeat (5) @(posedge clk);
        reset = 0;
        repeat (5) @(posedge clk);

        // Test suite
        send_and_check(8'h41, "Letter A");
        send_and_check(8'h00, "NULL    ");
        send_and_check(8'hFF, "All 1s  ");
        send_and_check(8'h55, "Alt 0101");
        send_and_check(8'hAA, "Alt 1010");

        // Spell "HELLO"
        send_and_check(8'h48, "H       ");
        send_and_check(8'h45, "E       ");
        send_and_check(8'h4C, "L       ");
        send_and_check(8'h4C, "L       ");
        send_and_check(8'h4F, "O       ");

        $display("\n========================================");
        $display("UART TX: %0d/%0d tests passed",
                 test_count - fail_count, test_count);
        $display("========================================");
        $finish;
    end

endmodule
