// =============================================================================
// day14_ex01_uart_tx_assertions.sv — UART TX with Assertion-Enhanced Verification
// Day 14: SystemVerilog for Verification
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Demonstrates:
//   - Immediate assertions (inline design checks)
//   - Concurrent assertions (multi-cycle protocol verification)
//   - How assertions catch deliberately injected bugs
// =============================================================================
// Build:  iverilog -g2012 -DSIMULATION -o sim day14_ex01_uart_tx_assertions.sv && vvp sim
// Note:   Concurrent assertions (assert property) require Verilator or commercial tools.
//         Immediate assertions work in Icarus with -g2012.
// =============================================================================

module uart_tx_asserted #(
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

    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam int CNT_W        = $clog2(CLKS_PER_BIT);

    typedef enum logic [1:0] {
        S_IDLE, S_START, S_DATA, S_STOP
    } uart_state_t;

    uart_state_t state, next_state;
    logic [CNT_W-1:0] baud_cnt;
    logic [2:0]        bit_idx;
    logic [9:0]        shift;
    logic              baud_tick;

    assign baud_tick = (baud_cnt == CNT_W'(CLKS_PER_BIT - 1));

    // ---- Baud Counter ----
    always_ff @(posedge i_clk) begin
        if (i_reset || state == S_IDLE)
            baud_cnt <= '0;
        else if (baud_tick)
            baud_cnt <= '0;
        else
            baud_cnt <= baud_cnt + 1;
    end

    // ---- State Register ----
    always_ff @(posedge i_clk) begin
        if (i_reset)
            state <= S_IDLE;
        else
            state <= next_state;
    end

    // ---- Next-State Logic ----
    always_comb begin
        next_state = state;
        case (state)
            S_IDLE:  if (i_valid)                     next_state = S_START;
            S_START: if (baud_tick)                    next_state = S_DATA;
            S_DATA:  if (baud_tick && bit_idx == 3'd7) next_state = S_STOP;
            S_STOP:  if (baud_tick)                    next_state = S_IDLE;
            default: next_state = S_IDLE;
        endcase
    end

    // ---- Shift Register ----
    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            shift   <= 10'h3FF;
            bit_idx <= '0;
        end else if (state == S_IDLE && i_valid) begin
            shift   <= {1'b1, i_data, 1'b0};
            bit_idx <= '0;
        end else if (baud_tick) begin
            shift <= {1'b1, shift[9:1]};
            if (state == S_DATA)
                bit_idx <= bit_idx + 1;
        end
    end

    // ---- Outputs ----
    always_comb begin
        o_tx   = (state == S_IDLE) ? 1'b1 : shift[0];
        o_busy = (state != S_IDLE);
    end

    // =================================================================
    // ASSERTIONS — Executable Specifications
    // =================================================================

    // ---- Immediate Assertion 1: No valid while busy ----
    // Protocol rule: producer must not assert valid during transmission
    always_ff @(posedge i_clk) begin
        if (!i_reset) begin
            assert (!(o_busy && i_valid))
                else $error("[A1] i_valid asserted while o_busy at time %0t", $time);
        end
    end

    // ---- Immediate Assertion 2: TX must be high in IDLE ----
    always_ff @(posedge i_clk) begin
        if (!i_reset) begin
            assert (!(state == S_IDLE && o_tx !== 1'b1))
                else $error("[A2] TX not high during IDLE at time %0t", $time);
        end
    end

    // ---- Immediate Assertion 3: TX must be low during START ----
    always_ff @(posedge i_clk) begin
        if (!i_reset) begin
            assert (!(state == S_START && o_tx !== 1'b0))
                else $error("[A3] TX not low during START at time %0t", $time);
        end
    end

    // ---- Immediate Assertion 4: bit_idx must be in range ----
    always_ff @(posedge i_clk) begin
        if (!i_reset && state == S_DATA) begin
            assert (bit_idx <= 3'd7)
                else $error("[A4] bit_idx out of range: %0d at time %0t", bit_idx, $time);
        end
    end

    // ---- Immediate Assertion 5: baud counter must not exceed limit ----
    always_ff @(posedge i_clk) begin
        if (!i_reset) begin
            assert (baud_cnt <= CNT_W'(CLKS_PER_BIT - 1))
                else $error("[A5] baud_cnt overflow: %0d at time %0t", baud_cnt, $time);
        end
    end

    // =================================================================
    // CONCURRENT ASSERTIONS (require Verilator or commercial tools)
    // Uncomment if your tool supports them.
    // =================================================================
    /*
    // After reset deasserts, TX must be idle (high) within 2 cycles
    property p_post_reset_idle;
        @(posedge i_clk)
        $fell(i_reset) |=> ##[0:1] (o_tx == 1'b1);
    endproperty
    assert property (p_post_reset_idle)
        else $error("[C1] TX not idle after reset deassert");

    // Start bit must be followed by exactly 8 data bit periods
    // then a stop bit period
    property p_frame_length;
        @(posedge i_clk) disable iff (i_reset)
        (state == S_START && baud_tick) |=>
            (state == S_DATA) ##1 (state == S_DATA)[*0:$]
            ##1 (state == S_STOP);
    endproperty
    assert property (p_frame_length)
        else $error("[C2] Frame length violation");
    */

endmodule

// =============================================================================
// Testbench — Demonstrates assertion-driven bug detection
// =============================================================================
`ifdef SIMULATION
module tb_uart_tx_assertions;

    localparam int CLK_FREQ     = 1_000;
    localparam int BAUD_RATE    = 100;
    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    logic       clk = 0, reset = 1, valid = 0;
    logic [7:0] data;
    logic       busy, tx;

    uart_tx_asserted #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .i_clk(clk), .i_reset(reset),
        .i_valid(valid), .i_data(data),
        .o_busy(busy), .o_tx(tx)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_uart_tx_assertions.vcd");
        $dumpvars(0, tb_uart_tx_assertions);

        $display("\n=== UART TX Assertion-Enhanced Testbench ===\n");
        $display("Assertions are monitoring continuously...\n");

        // Reset sequence
        repeat(5) @(posedge clk);
        reset = 0;
        repeat(5) @(posedge clk);

        // Normal transmission — assertions should NOT fire
        $display("--- Test 1: Normal byte 'A' (0x41) ---");
        data = 8'h41;
        valid = 1;
        @(posedge clk);
        valid = 0;

        // Wait for transmission to complete
        @(negedge busy);
        repeat(CLKS_PER_BIT * 2) @(posedge clk);

        // Normal transmission — boundary value 0xFF
        $display("--- Test 2: Boundary byte 0xFF ---");
        data = 8'hFF;
        valid = 1;
        @(posedge clk);
        valid = 0;

        @(negedge busy);
        repeat(CLKS_PER_BIT * 2) @(posedge clk);

        // Normal transmission — boundary value 0x00
        $display("--- Test 3: Boundary byte 0x00 ---");
        data = 8'h00;
        valid = 1;
        @(posedge clk);
        valid = 0;

        @(negedge busy);
        repeat(CLKS_PER_BIT * 2) @(posedge clk);

        $display("\n=== All tests complete. ===");
        $display("If no assertion errors above, all protocol checks passed.\n");
        $finish;
    end
endmodule
`endif
