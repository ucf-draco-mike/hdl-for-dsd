// =============================================================================
// day13_ex01_uart_tx_sv.sv — UART TX Refactored in SystemVerilog
// Day 13: SystemVerilog for Design
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Same functionality as day11_ex01_uart_tx.v, refactored with:
//   - logic (replaces wire/reg)
//   - always_ff / always_comb (intent-based)
//   - typedef enum (type-safe FSM states)
//   - Dropped r_ prefix (always_ff declares register intent)
// =============================================================================
// Build:  iverilog -g2012 -DSIMULATION -o sim day13_ex01_uart_tx_sv.sv && vvp sim
// Synth:  yosys -p "read_verilog -sv day13_ex01_uart_tx_sv.sv; synth_ice40 -top uart_tx_sv"
// =============================================================================

module uart_tx_sv #(
    `ifdef SIMULATION
    parameter int CLK_FREQ  = 1_000,
    parameter int BAUD_RATE = 100
    `else
    parameter int CLK_FREQ  = 25_000_000,
    parameter int BAUD_RATE = 115_200
    `endif
)(
    input  logic       i_clk,
    input  logic       i_reset,
    input  logic       i_valid,
    input  logic [7:0] i_data,
    output logic       o_busy,
    output logic       o_tx
);

    // ---- Parameters ----
    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam int CNT_W        = $clog2(CLKS_PER_BIT);

    // ---- State Type (enum replaces localparam) ----
    typedef enum logic [1:0] {
        S_IDLE  = 2'b00,
        S_START = 2'b01,
        S_DATA  = 2'b10,
        S_STOP  = 2'b11
    } uart_state_t;

    uart_state_t state, next_state;

    // ---- Datapath Registers ----
    logic [CNT_W-1:0]  baud_cnt;
    logic [2:0]         bit_idx;
    logic [9:0]         shift;

    logic baud_tick;
    assign baud_tick = (baud_cnt == CNT_W'(CLKS_PER_BIT - 1));

    // ============================================================
    // Baud Counter — always_ff enforces sequential semantics
    // ============================================================
    always_ff @(posedge i_clk) begin
        if (i_reset || state == S_IDLE)
            baud_cnt <= '0;
        else if (baud_tick)
            baud_cnt <= '0;
        else
            baud_cnt <= baud_cnt + 1;
    end

    // ============================================================
    // Block 1 — State Register (always_ff)
    // ============================================================
    always_ff @(posedge i_clk) begin
        if (i_reset)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // ============================================================
    // Block 2 — Next-State Logic (always_comb catches latches!)
    // ============================================================
    always_comb begin
        next_state = state;     // default: hold (prevents latch)

        case (state)
            S_IDLE:
                if (i_valid)
                    next_state = S_START;

            S_START:
                if (baud_tick)
                    next_state = S_DATA;

            S_DATA:
                if (baud_tick && bit_idx == 3'd7)
                    next_state = S_STOP;

            S_STOP:
                if (baud_tick)
                    next_state = S_IDLE;

            default: next_state = S_IDLE;
        endcase
    end

    // ---- Shift Register & Bit Counter ----
    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            shift   <= 10'h3FF;
            bit_idx <= '0;
        end else if (state == S_IDLE && i_valid) begin
            shift   <= {1'b1, i_data, 1'b0};  // {stop, data, start}
            bit_idx <= '0;
        end else if (baud_tick) begin
            shift <= {1'b1, shift[9:1]};
            if (state == S_DATA)
                bit_idx <= bit_idx + 1;
        end
    end

    // ---- Output Logic (always_comb) ----
    always_comb begin
        o_tx   = (state == S_IDLE) ? 1'b1 : shift[0];
        o_busy = (state != S_IDLE);
    end

endmodule

// =============================================================================
// Self-Checking Testbench — Same protocol-aware capture as Day 11
// =============================================================================
`ifdef SIMULATION
module tb_uart_tx_sv;

    localparam int CLK_FREQ     = 1_000;
    localparam int BAUD_RATE    = 100;
    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    logic       clk = 0, reset = 1, valid = 0;
    logic [7:0] data;
    logic       busy, tx;

    uart_tx_sv #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .i_clk(clk), .i_reset(reset),
        .i_valid(valid), .i_data(data),
        .o_busy(busy), .o_tx(tx)
    );

    always #5 clk = ~clk;

    int test_count = 0, fail_count = 0;

    task automatic capture_and_check(input logic [7:0] expected, input string name);
        logic [7:0] captured;
    begin
        test_count++;

        @(negedge tx);  // start bit falling edge
        repeat (CLKS_PER_BIT / 2) @(posedge clk);  // center of start

        if (tx !== 1'b0) begin
            $error("FAIL: %s — start bit not 0", name);
            fail_count++;
        end

        for (int i = 0; i < 8; i++) begin
            repeat (CLKS_PER_BIT) @(posedge clk);
            captured[i] = tx;
        end

        repeat (CLKS_PER_BIT) @(posedge clk);
        if (tx !== 1'b1) begin
            $error("FAIL: %s — stop bit not 1", name);
            fail_count++;
        end

        if (captured !== expected) begin
            $error("FAIL: %s — expected %h, captured %h", name, expected, captured);
            fail_count++;
        end else
            $display("PASS: %s — TX byte %h ('%c') correct", name, captured, captured);
    end
    endtask

    initial begin
        $dumpfile("tb_uart_tx_sv.vcd");
        $dumpvars(0, tb_uart_tx_sv);

        $display("\n=== UART TX (SystemVerilog) Testbench ===\n");

        repeat(5) @(posedge clk); reset = 0;
        repeat(5) @(posedge clk);

        // Test 1: 'H'
        fork
            begin data = 8'h48; valid = 1; @(posedge clk); valid = 0; end
            begin capture_and_check(8'h48, "SV Byte 'H'"); end
        join
        repeat(CLKS_PER_BIT * 2) @(posedge clk);

        // Test 2: 0x00
        fork
            begin data = 8'h00; valid = 1; @(posedge clk); valid = 0; end
            begin capture_and_check(8'h00, "SV Byte 0x00"); end
        join
        repeat(CLKS_PER_BIT * 2) @(posedge clk);

        // Test 3: 0xFF
        fork
            begin data = 8'hFF; valid = 1; @(posedge clk); valid = 0; end
            begin capture_and_check(8'hFF, "SV Byte 0xFF"); end
        join

        $display("\n=== SUMMARY ===");
        $display("Tests: %0d  Passed: %0d  Failed: %0d",
                 test_count, test_count - fail_count, fail_count);
        if (fail_count == 0) $display("\n*** ALL TESTS PASSED ***\n");
        else                 $display("\n*** %0d FAILURES ***\n", fail_count);
        $finish;
    end
endmodule
`endif
