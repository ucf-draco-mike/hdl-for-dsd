// =============================================================================
// tb_uart_tx_sv.sv -- Smoke testbench for uart_tx_sv
// SystemVerilog version of the UART TX smoke test.
// Assumes -DSIMULATION (CLKS_PER_BIT = 10).
// =============================================================================
`timescale 1ns/1ps

module tb_uart_tx_sv;
    localparam int CLK_FREQ     = 1_000;
    localparam int BAUD_RATE    = 100;
    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    logic       clk = 1'b0, reset = 1'b1, valid = 1'b0;
    logic [7:0] data = 8'h00;
    logic       busy, tx;

    uart_tx_sv #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) uut (
        .i_clk(clk), .i_reset(reset),
        .i_valid(valid), .i_data(data),
        .o_busy(busy), .o_tx(tx)
    );

    always #5 clk = ~clk;

    int       fails = 0;
    logic [7:0] captured;
    int       i;

    initial begin
        $dumpfile("tb_uart_tx_sv.vcd");
        $dumpvars(0, tb_uart_tx_sv);
        $display("=== UART TX (SV) testbench ===");

        @(posedge clk); @(posedge clk); reset = 1'b0;
        @(posedge clk);

        data  = 8'h53;            // 'S'
        valid = 1'b1;
        @(posedge clk);
        valid = 1'b0;

        @(negedge tx);
        repeat (CLKS_PER_BIT / 2) @(posedge clk);
        if (tx !== 1'b0) begin $display("FAIL: start bit"); fails++; end
        else                $display("PASS: start bit = 0");

        for (i = 0; i < 8; i++) begin
            repeat (CLKS_PER_BIT) @(posedge clk);
            captured[i] = tx;
        end

        repeat (CLKS_PER_BIT) @(posedge clk);
        if (tx !== 1'b1) begin $display("FAIL: stop bit"); fails++; end
        else                $display("PASS: stop bit = 1");

        if (captured !== 8'h53) begin
            $display("FAIL: got %h, expected 53", captured); fails++;
        end else
            $display("PASS: captured byte = %h", captured);

        if (fails == 0) $display("=== 3 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end

    initial begin
        #50_000;
        $display("FAIL: watchdog timeout");
        $finish;
    end
endmodule
