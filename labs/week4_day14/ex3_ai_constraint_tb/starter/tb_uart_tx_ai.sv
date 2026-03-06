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
    // Parameters
    // ────────────────────────────────────────────
    localparam CLK_FREQ    = 25_000_000;
    localparam BAUD_RATE   = 115_200;
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // ────────────────────────────────────────────
    // DUT signals
    // ────────────────────────────────────────────
    reg        clk = 0;
    reg        rst = 1;
    reg  [7:0] tx_data = 8'h00;
    reg        tx_start = 0;
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
        .CLKS_PER_BIT(CLKS_PER_BIT)
    ) uut (
        .i_clk(clk),
        .i_rst(rst),
        .i_tx_data(tx_data),
        .i_tx_start(tx_start),
        .o_tx_serial(tx_out),
        .o_tx_busy(tx_busy),
        .o_tx_done(tx_done)
    );

    // ────────────────────────────────────────────
    // TODO: Paste AI-generated constrained-random stimulus below
    // ────────────────────────────────────────────
    // REQUIREMENTS for the AI-generated section:
    //   - Send at least 20 random bytes
    //   - Verify each byte by sampling tx_out at mid-bit
    //   - Check start bit = 0, stop bit = 1
    //   - Test back-to-back transmissions (tx_start while tx_busy)
    //   - Report pass/fail with $display
    //
    // ---- PASTE AI OUTPUT HERE ----

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_uart_tx_ai);

        // Reset
        #100;
        rst = 0;
        #100;

        // TODO: Replace with AI-generated stimulus
        $display("ERROR: No AI-generated stimulus yet — see README.md");
        $finish;
    end

endmodule
