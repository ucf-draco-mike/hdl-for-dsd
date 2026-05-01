// =============================================================================
// tb_uart_tx.v -- Self-checking testbench for uart_tx
// =============================================================================
`timescale 1ns/1ps
module tb_uart_tx;
    parameter CLK_FREQ  = 25_000_000;
    parameter BAUD_RATE = 115200;     // Fast baud for simulation speed
    parameter CLK_PERIOD = 1_000_000_000 / CLK_FREQ;  // ns
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    parameter BIT_PERIOD   = CLK_PERIOD * CLKS_PER_BIT;

    reg        i_clk  = 0;
    reg  [7:0] i_data = 0;
    reg        i_valid = 0;
    wire       o_tx, o_busy, o_done;

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) dut (
        .i_clk(i_clk), .i_data(i_data), .i_valid(i_valid),
        .o_tx(o_tx), .o_busy(o_busy), .o_done(o_done)
    );

    always #(CLK_PERIOD/2) i_clk = ~i_clk;

    integer pass_count = 0, fail_count = 0;
    integer i;

    // Task: send a byte and verify the serialized bits
    task send_and_check;
        input [7:0] data;
        reg [7:0] received;
        begin
            // Send
            @(negedge i_clk);
            i_data  = data;
            i_valid = 1'b1;
            @(posedge i_clk); #1;
            i_valid = 1'b0;

            // Wait for start bit
            @(negedge o_tx);
            #(BIT_PERIOD / 2);  // sample midpoint

            // Verify start bit
            if (o_tx !== 1'b0) begin
                $display("FAIL: start bit not low for data=%h", data);
                fail_count = fail_count + 1;
            end

            // Sample 8 data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                #BIT_PERIOD;
                received[i] = o_tx;
            end

            if (received !== data) begin
                $display("FAIL: send %h -- received %h (serial decode)", data, received);
                fail_count = fail_count + 1;
            end else begin
                $display("PASS: uart_tx sent byte %h correctly", data);
                pass_count = pass_count + 1;
            end

            // Wait for stop bit
            #BIT_PERIOD;
            if (o_tx !== 1'b1) begin
                $display("FAIL: stop bit not high after data %h", data);
                fail_count = fail_count + 1;
            end

            // Wait for done
            @(posedge o_done);
        end
    endtask

    initial begin
        $dumpfile("dump.vcd"); $dumpvars(0, tb_uart_tx);

        // Verify idle state
        #100;
        if (o_tx !== 1'b1) begin
            $display("FAIL: TX not idle-high at startup");
            fail_count = fail_count + 1;
        end else begin
            $display("PASS: TX idle-high");
            pass_count = pass_count + 1;
        end

        send_and_check(8'h41);  // 'A'
        send_and_check(8'h55);  // alternating bits 01010101
        send_and_check(8'hAA);  // alternating bits 10101010
        send_and_check(8'h00);  // all zeros
        send_and_check(8'hFF);  // all ones

        #1000;
        $display("\n=== uart_tx: %0d passed, %0d failed ===", pass_count, fail_count);
        $finish;
    end
endmodule
