// tb_uart_tx_ai.sv — AI-Generated Constrained-Random Testbench (Starter)
// ============================================================================
// WORKFLOW:
//   1. Read the prompt template in README.md
//   2. Use an AI assistant to generate a constrained-random TB for uart_tx
//   3. Paste the AI output here, then annotate and fix issues
//   4. Run: make sim
// ============================================================================
`timescale 1ns / 1ps

module tb_uart_tx_ai;

    // ────────────────────────────────────────────
    // Parameters — must match shared/lib/uart_tx.v interface
    // uart_tx uses: parameter CLK_FREQ, parameter BAUD_RATE
    //   internally: localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE
    // ────────────────────────────────────────────
    localparam CLK_FREQ  = 25_000_000;
    localparam BAUD_RATE = 115_200;
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // ────────────────────────────────────────────
    // DUT signals
    //   Ports: i_clk, i_data[7:0], i_valid, o_tx, o_busy, o_done
    // ────────────────────────────────────────────
    reg        clk = 0;
    reg  [7:0] tx_data = 8'h00;
    reg        tx_valid = 0;
    wire       tx_out;
    wire       tx_busy;
    wire       tx_done;

    // ────────────────────────────────────────────
    // Clock generation
    // ────────────────────────────────────────────
    always #20 clk = ~clk;  // 25 MHz

    // ────────────────────────────────────────────
    // DUT instantiation
    // ────────────────────────────────────────────
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

    // ────────────────────────────────────────────
    // TODO: Paste AI-generated constrained-random stimulus below
    // ────────────────────────────────────────────
    // REQUIREMENTS for the AI-generated section:
    //   - Send at least 20 random bytes
    //   - Verify each byte by sampling tx_out at mid-bit
    //   - Check start bit = 0, stop bit = 1
    //   - Test back-to-back transmissions (tx_valid while tx_busy)
    //   - Report pass/fail with $display
    //
    // ---- PASTE AI OUTPUT HERE ----

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_uart_tx_ai);

        #100;

        // TODO: Replace with AI-generated stimulus
        $display("ERROR: No AI-generated stimulus yet — see README.md");
        $finish;
    end

endmodule
