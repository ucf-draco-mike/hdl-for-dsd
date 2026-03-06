// tb_uart_tx_ai.sv — AI-Generated Constrained-Random Testbench (Reference)
// ============================================================================
// This is an EXAMPLE of what a corrected AI-generated TB might look like.
// Students should produce their own version via the prompt workflow.
// ============================================================================
`timescale 1ns / 1ps

module tb_uart_tx_ai;

    localparam CLK_FREQ     = 25_000_000;
    localparam BAUD_RATE    = 115_200;
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam BIT_PERIOD   = CLKS_PER_BIT * 40; // ns per bit at 25 MHz

    reg        clk = 0;
    reg  [7:0] tx_data;
    reg        tx_valid;
    wire       tx_out;
    wire       tx_busy;
    wire       tx_done;

    always #20 clk = ~clk;

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .i_clk(clk),
        .i_data(tx_data),
        .i_valid(tx_valid),
        .o_tx(tx_out),
        .o_busy(tx_busy),
        .o_done(tx_done)
    );

    // ── Bit sampler: capture tx_out at mid-bit ──────────────────────────
    task automatic sample_byte(output [7:0] sampled);
        integer i;
        begin
            // Wait for start bit (falling edge)
            @(negedge tx_out);
            #(BIT_PERIOD / 2); // mid-start-bit
            if (tx_out !== 1'b0) begin
                $display("FAIL: start bit not low");
                $finish;
            end
            // Sample 8 data bits (LSB first)
            for (i = 0; i < 8; i = i + 1) begin
                #BIT_PERIOD;
                sampled[i] = tx_out;
            end
            // Check stop bit
            #BIT_PERIOD;
            if (tx_out !== 1'b1) begin
                $display("FAIL: stop bit not high");
                $finish;
            end
        end
    endtask

    // ── Stimulus ────────────────────────────────────────────────────────
    integer seed, pass_count, fail_count, test_num;
    reg [7:0] expected, received;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_uart_tx_ai);

        tx_data    = 8'h00;
        tx_valid   = 0;
        pass_count = 0;
        fail_count = 0;
        seed       = 42;

        #200;

        // Send 20 random bytes
        for (test_num = 0; test_num < 20; test_num = test_num + 1) begin
            expected = $random(seed) & 8'hFF;
            tx_data  = expected;

            @(posedge clk);
            tx_valid = 1;
            @(posedge clk);
            tx_valid = 0;

            // Sample the transmitted byte
            sample_byte(received);

            if (received === expected) begin
                $display("PASS [%0d]: sent 0x%02h, received 0x%02h",
                         test_num, expected, received);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL [%0d]: sent 0x%02h, received 0x%02h",
                         test_num, expected, received);
                fail_count = fail_count + 1;
            end

            // Wait for tx_done before next byte
            @(posedge tx_done);
            #100;
        end

        // Back-to-back test: assert tx_valid while still busy
        $display("--- Back-to-back test ---");
        tx_data  = 8'hA5;
        @(posedge clk);
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;
        #(BIT_PERIOD * 3); // mid-transmission
        tx_data  = 8'h5A;
        @(posedge clk);
        tx_valid = 1;
        @(posedge clk);
        tx_valid = 0;
        sample_byte(received);
        if (received === 8'hA5)
            $display("PASS: first back-to-back byte correct (0x%02h)", received);
        else
            $display("FAIL: first back-to-back byte wrong (expected A5, got %02h)", received);

        #(BIT_PERIOD * 12);

        $display("===========================");
        $display("Results: %0d passed, %0d failed out of 20", pass_count, fail_count);
        if (fail_count == 0)
            $display("ALL TESTS PASSED");
        else
            $display("SOME TESTS FAILED");
        $display("===========================");
        $finish;
    end

endmodule
