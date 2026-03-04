// =============================================================================
// tb_uart_rx.v — Self-checking testbench for uart_rx
// =============================================================================
`timescale 1ns/1ps
module tb_uart_rx;
    parameter CLK_FREQ     = 25_000_000;
    parameter BAUD_RATE    = 115200;
    parameter CLK_HALF     = 20;
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;  // 217

    reg        i_clk = 0;
    reg        i_rx  = 1;
    wire [7:0] o_data;
    wire       o_valid, o_error;

    uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) dut (
        .i_clk(i_clk), .i_rx(i_rx),
        .o_data(o_data), .o_valid(o_valid), .o_error(o_error)
    );

    always #CLK_HALF i_clk = ~i_clk;

    integer pass_count = 0, fail_count = 0;
    integer captured_valid;
    reg     [7:0] captured_data;
    reg           captured_error;

    // Capture valid pulses asynchronously
    always @(posedge i_clk) begin
        if (o_valid) begin
            captured_valid <= captured_valid + 1;
            captured_data  <= o_data;
            captured_error <= o_error;
        end
    end

    task send_and_check;
        input [7:0] data;
        integer     bit_idx;
        integer     prev_valid;
        integer     wait_cnt;
        begin
            prev_valid = captured_valid;

            // Start bit
            i_rx = 1'b0;
            repeat(CLKS_PER_BIT) @(posedge i_clk);
            // 8 data bits LSB first
            for (bit_idx = 0; bit_idx < 8; bit_idx = bit_idx + 1) begin
                i_rx = data[bit_idx];
                repeat(CLKS_PER_BIT) @(posedge i_clk);
            end
            // Stop bit + extra
            i_rx = 1'b1;
            repeat(CLKS_PER_BIT * 2) @(posedge i_clk);

            // Check that a new valid pulse was captured
            if (captured_valid == prev_valid) begin
                $display("FAIL: no valid pulse for byte %h", data);
                fail_count = fail_count + 1;
            end else if (captured_data !== data || captured_error) begin
                $display("FAIL: sent %h got data=%h error=%b",
                          data, captured_data, captured_error);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: uart_rx received byte %h", data);
                pass_count = pass_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("dump.vcd"); $dumpvars(0, tb_uart_rx);
        captured_valid = 0; captured_data = 0; captured_error = 0;

        repeat(10) @(posedge i_clk);

        send_and_check(8'h41);
        send_and_check(8'h55);
        send_and_check(8'hAA);
        send_and_check(8'h00);
        send_and_check(8'hFF);

        $display("\n=== uart_rx: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count == 0) $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
