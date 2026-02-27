// =============================================================================
// tb_uart_tx.v — Self-Checking UART TX Testbench
// Day 11: UART Transmitter
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Verifies: idle state, start bit, 8 data bits (LSB first), stop bit.
// Uses a task to capture and check a full UART frame.

`timescale 1ns / 1ps

module tb_uart_tx;

    // ===== Parameters =====
    localparam CLK_FREQ  = 25_000_000;
    localparam BAUD_RATE = 115_200;
    localparam CLK_NS    = 40;  // 25 MHz → 40 ns period
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;  // 217
    localparam BIT_PERIOD = CLKS_PER_BIT * CLK_NS;   // ~8680 ns

    // ===== Signals =====
    reg        clk, reset;
    reg        valid;
    reg  [7:0] data;
    wire       tx, busy;

    // ===== DUT =====
    uart_tx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) uut (
        .i_clk   (clk),
        .i_reset (reset),
        .i_valid (valid),
        .i_data  (data),
        .o_tx    (tx),
        .o_busy  (busy)
    );

    // ===== Clock =====
    initial clk = 0;
    always #(CLK_NS/2) clk = ~clk;

    // ===== Dump =====
    initial begin
        $dumpfile("tb_uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);
    end

    // ===== Test Infrastructure =====
    integer test_count = 0;
    integer fail_count = 0;

    // Capture a full UART frame from the TX line
    task capture_and_check;
        input [7:0] expected;
        input [8*20-1:0] name;
        reg [7:0] captured;
        integer i;
    begin
        test_count = test_count + 1;

        // Wait for start bit (falling edge on tx)
        @(negedge tx);

        // Wait to center of start bit
        #(BIT_PERIOD / 2);

        // Verify start bit is low
        if (tx !== 1'b0) begin
            $display("FAIL [%0d]: %0s — start bit not low", test_count, name);
            fail_count = fail_count + 1;
        end

        // Sample 8 data bits at center of each bit period
        for (i = 0; i < 8; i = i + 1) begin
            #(BIT_PERIOD);
            captured[i] = tx;  // LSB first
        end

        // Check stop bit
        #(BIT_PERIOD);
        if (tx !== 1'b1) begin
            $display("FAIL [%0d]: %0s — stop bit not high", test_count, name);
            fail_count = fail_count + 1;
        end

        // Verify data
        if (captured !== expected) begin
            $display("FAIL [%0d]: %0s — expected %h, got %h",
                     test_count, name, expected, captured);
            fail_count = fail_count + 1;
        end else begin
            $display("PASS [%0d]: %0s = 0x%h", test_count, name, captured);
        end
    end
    endtask

    // ===== Send a byte =====
    task send_byte;
        input [7:0] byte_val;
    begin
        @(posedge clk);
        data  = byte_val;
        valid = 1'b1;
        @(posedge clk);
        valid = 1'b0;
    end
    endtask

    // ===== Test Sequence =====
    initial begin
        // Initialize
        reset = 1; valid = 0; data = 0;
        #200; reset = 0; #200;

        // Verify idle state
        test_count = test_count + 1;
        if (tx !== 1'b1) begin
            $display("FAIL [%0d]: TX not high at idle", test_count);
            fail_count = fail_count + 1;
        end else
            $display("PASS [%0d]: TX idle = high", test_count);

        // Test 1: Send 'H' (0x48)
        fork
            send_byte(8'h48);
            capture_and_check(8'h48, "TX 0x48 (H)");
        join
        #(BIT_PERIOD);

        // Test 2: Send 0x00 (all zeros)
        fork
            send_byte(8'h00);
            capture_and_check(8'h00, "TX 0x00 (null)");
        join
        #(BIT_PERIOD);

        // Test 3: Send 0xFF (all ones)
        fork
            send_byte(8'hFF);
            capture_and_check(8'hFF, "TX 0xFF (all 1s)");
        join
        #(BIT_PERIOD);

        // Test 4: Send 0xA5 (alternating)
        fork
            send_byte(8'hA5);
            capture_and_check(8'hA5, "TX 0xA5 (alt)");
        join
        #(BIT_PERIOD);

        // ===== Summary =====
        #1000;
        $display("\n========================================");
        $display("Tests: %0d  |  Passed: %0d  |  Failed: %0d",
                 test_count, test_count - fail_count, fail_count);
        $display("========================================");
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("*** FAILURES DETECTED ***");

        $finish;
    end

endmodule
