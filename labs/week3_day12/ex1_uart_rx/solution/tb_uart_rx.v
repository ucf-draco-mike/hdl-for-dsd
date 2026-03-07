`timescale 1ns / 1ps
module tb_uart_rx;
    reg clk, reset;
    localparam CLK_FREQ = 1_000, BAUD_RATE = 100;
    localparam CLK_PERIOD = 500;

    wire tx_line;
    reg [7:0] tx_data; reg tx_valid; wire tx_busy;

    uart_tx #(.CLK_FREQ(CLK_FREQ),.BAUD_RATE(BAUD_RATE)) utx (
        .i_clk(clk),.i_valid(tx_valid),
        .i_data(tx_data),.o_tx(tx_line),.o_busy(tx_busy));

    wire [7:0] rx_data; wire rx_valid;
    uart_rx #(.CLK_FREQ(CLK_FREQ),.BAUD_RATE(BAUD_RATE)) urx (
        .i_clk(clk),.i_reset(reset),
        .i_rx(tx_line),.o_data(rx_data),.o_valid(rx_valid));

    initial clk=0; always #(CLK_PERIOD/2) clk=~clk;
    integer test_count=0, fail_count=0;

    task send_and_check;
        input [7:0] byte_val; input [63:0] label;
    begin
        @(posedge clk); tx_data=byte_val; tx_valid=1;
        @(posedge clk); tx_valid=0;
        // Wait for rx_valid or timeout
        fork : wait_block
            begin @(posedge rx_valid); end
            begin repeat(200) @(posedge clk); $display("TIMEOUT: %0s",label); end
        join_any
        disable wait_block;
        @(posedge clk); #1;
        test_count=test_count+1;
        if (rx_data !== byte_val) begin
            fail_count=fail_count+1;
            $display("FAIL [%0s]: sent=%h got=%h",label,byte_val,rx_data);
        end else
            $display("PASS [%0s]: %h OK",label,byte_val);
        @(negedge tx_busy); repeat(5) @(posedge clk);
    end endtask

    initial begin
        $dumpfile("uart_rx.vcd"); $dumpvars(0,tb_uart_rx);
        reset=1; tx_valid=0; repeat(10) @(posedge clk);
        reset=0; repeat(10) @(posedge clk);
        send_and_check(8'h41,"Letter A");
        send_and_check(8'h00,"NULL    ");
        send_and_check(8'hFF,"All 1s  ");
        send_and_check(8'h55,"Alt 0101");
        send_and_check(8'h48,"H       ");
        send_and_check(8'h45,"E       ");
        send_and_check(8'h4C,"L       ");
        send_and_check(8'h4C,"L       ");
        send_and_check(8'h4F,"O       ");
        $display("\n========================================");
        $display("UART RX: %0d/%0d passed",test_count-fail_count,test_count);
        $display("========================================");
        $finish;
    end
endmodule
