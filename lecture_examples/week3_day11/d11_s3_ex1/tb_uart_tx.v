// =============================================================================
// tb_uart_tx.v -- Smoke testbench for uart_tx
// Drives a single byte ('A' = 0x41) and samples the serial frame at bit
// centers. Mirrors the d11_s3 Live Demo: "self-checks byte = 'A'".
// Assumes -DSIMULATION (CLKS_PER_BIT = 10).
// =============================================================================
`timescale 1ns/1ps

module tb_uart_tx;
    localparam CLK_FREQ     = 1_000;
    localparam BAUD_RATE    = 100;
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;  // 10

    reg        clk = 1'b0, reset = 1'b1, valid = 1'b0;
    reg  [7:0] data = 8'h00;
    wire       busy, tx;

    uart_tx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) uut (
        .i_clk(clk), .i_reset(reset),
        .i_valid(valid), .i_data(data),
        .o_busy(busy), .o_tx(tx)
    );

    always #5 clk = ~clk;

    integer fails = 0;
    reg [7:0] captured;
    integer   i;

    initial begin
        $dumpfile("tb_uart_tx.vcd");
        $dumpvars(0, tb_uart_tx);
        $display("=== UART TX testbench ===");

        // Hold reset for a few cycles
        @(posedge clk); @(posedge clk); reset = 1'b0;
        @(posedge clk);

        // Pulse valid for one cycle with the byte to send
        data  = 8'h41;            // 'A' (0x41 = 01000001, LSB-first: 1,0,0,0,0,0,1,0)
        valid = 1'b1;
        @(posedge clk);
        valid = 1'b0;

        // Wait for start bit (tx falls)
        @(negedge tx);

        // Move to center of start bit
        repeat (CLKS_PER_BIT / 2) @(posedge clk);
        if (tx !== 1'b0) begin $display("FAIL: start bit not 0"); fails = fails + 1; end
        else                $display("PASS: start bit = 0");

        // Sample 8 data bits, LSB first, at next bit centers
        for (i = 0; i < 8; i = i + 1) begin
            repeat (CLKS_PER_BIT) @(posedge clk);
            captured[i] = tx;
        end

        // Stop bit
        repeat (CLKS_PER_BIT) @(posedge clk);
        if (tx !== 1'b1) begin $display("FAIL: stop bit not 1"); fails = fails + 1; end
        else                $display("PASS: stop bit = 1");

        if (captured !== 8'h41) begin
            $display("FAIL: captured %h, expected 41", captured); fails = fails + 1;
        end else
            $display("PASS: captured byte = %h ('A')", captured);

        if (fails == 0) $display("=== 3 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end

    // Watchdog to prevent runaway sim
    initial begin
        #50_000;
        $display("FAIL: watchdog timeout");
        $finish;
    end
endmodule
