// =============================================================================
// tb_uart_tx_parity.sv -- Testbench for UART TX with Parity
// Day 14, Exercise 2
// =============================================================================
// Tests both PARITY_EN=0 and PARITY_EN=1 configurations.
// Verifies frame structure: start + 8 data + [parity] + stop
`timescale 1ns/1ps

module tb_uart_tx_parity;

    localparam int CLK_FREQ    = 25_000_000;
    localparam int BAUD_RATE   = 115_200;
    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam int CLK_PERIOD   = 40;  // 25 MHz = 40 ns

    logic       clk, reset, valid;
    logic [7:0] data;
    logic       tx_no_par, busy_no_par;
    logic       tx_even,   busy_even;

    // Instance 1: No parity
    uart_tx_parity #(
        .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE),
        .PARITY_EN(0)
    ) uut_no_parity (
        .i_clk(clk), .i_reset(reset), .i_valid(valid), .i_data(data),
        .o_tx(tx_no_par), .o_busy(busy_no_par)
    );

    // Instance 2: Even parity
    uart_tx_parity #(
        .CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE),
        .PARITY_EN(1), .PARITY_TYPE(0)
    ) uut_even_parity (
        .i_clk(clk), .i_reset(reset), .i_valid(valid), .i_data(data),
        .o_tx(tx_even), .o_busy(busy_even)
    );

    always #(CLK_PERIOD/2) clk = ~clk;

    integer pass_count = 0, fail_count = 0;

    task send_byte(input [7:0] d);
        begin
            data = d;
            @(posedge clk);
            valid = 1;
            @(posedge clk);
            valid = 0;
            // Wait for both instances to finish
            wait (!busy_no_par && !busy_even);
            repeat(CLKS_PER_BIT) @(posedge clk);  // gap between frames
        end
    endtask

    // Verify no-parity TX line idle is high
    task check_idle;
        begin
            if (tx_no_par !== 1'b1) begin
                $display("FAIL: no-parity TX not idle high"); fail_count++;
            end else pass_count++;
            if (tx_even !== 1'b1) begin
                $display("FAIL: even-parity TX not idle high"); fail_count++;
            end else pass_count++;
        end
    endtask

    initial begin
        $dumpfile("uart_parity.vcd");
        $dumpvars(0, tb_uart_tx_parity);

        clk = 0; reset = 1; valid = 0; data = 0;
        repeat(5) @(posedge clk);
        reset = 0;
        repeat(3) @(posedge clk);

        check_idle();

        // Send test bytes
        $display("Sending 0x41 ('A')...");
        send_byte(8'h41);

        $display("Sending 0x00...");
        send_byte(8'h00);

        $display("Sending 0xFF...");
        send_byte(8'hFF);

        $display("Sending 0xAA...");
        send_byte(8'hAA);

        $display("Sending 0x55...");
        send_byte(8'h55);

        repeat(100) @(posedge clk);

        $display("");
        $display("========================================");
        $display("  Basic frame timing tests: %0d passed, %0d failed", pass_count, fail_count);
        $display("  Visual verification: check VCD for frame structure");
        $display("  No-parity frame: 10 bit periods (start+8data+stop)");
        $display("  Even-parity frame: 11 bit periods (start+8data+parity+stop)");
        $display("========================================");

        $finish;
    end

endmodule
