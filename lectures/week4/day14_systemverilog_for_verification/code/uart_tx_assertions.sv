// =============================================================================
// uart_tx_assertions.sv — UART TX with Embedded Assertions
// Day 14: SystemVerilog for Verification
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Demonstrates: immediate assertions, concurrent assertions (property/assert),
//   protocol-level verification embedded in RTL.
//
// NOTE: Concurrent assertions require commercial tools (Questa, VCS) or
//   Verilator with --assert. Icarus Verilog supports immediate assertions
//   only with -g2012. The concurrent assertions here serve as executable
//   documentation even in toolchains that can't run them.

module uart_tx_assertions #(
    parameter int CLK_FREQ  = 25_000_000,
    parameter int BAUD_RATE = 115_200
)(
    input  logic       i_clk,
    input  logic       i_reset,
    input  logic       i_valid,
    input  logic [7:0] i_data,
    output logic       o_tx,
    output logic       o_busy
);

    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam int BAUD_CNT_W   = $clog2(CLKS_PER_BIT);

    typedef enum logic [1:0] {
        S_IDLE, S_START, S_DATA, S_STOP
    } uart_state_t;

    uart_state_t state;
    logic [BAUD_CNT_W-1:0] baud_cnt;
    logic [7:0]            shift_reg;
    logic [2:0]            bit_idx;
    logic                  baud_tick;

    assign baud_tick = (baud_cnt == BAUD_CNT_W'(CLKS_PER_BIT - 1));
    assign o_busy    = (state != S_IDLE);

    // ===== Main FSM (same as uart_tx_sv.sv) =====
    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            state     <= S_IDLE;
            o_tx      <= 1'b1;
            baud_cnt  <= '0;
            bit_idx   <= '0;
            shift_reg <= '0;
        end else begin
            case (state)
                S_IDLE: begin
                    o_tx     <= 1'b1;
                    baud_cnt <= '0;
                    bit_idx  <= '0;
                    if (i_valid) begin
                        shift_reg <= i_data;
                        state     <= S_START;
                    end
                end
                S_START: begin
                    o_tx     <= 1'b0;
                    baud_cnt <= baud_cnt + 1;
                    if (baud_tick) begin
                        baud_cnt <= '0;
                        state    <= S_DATA;
                    end
                end
                S_DATA: begin
                    o_tx     <= shift_reg[0];
                    baud_cnt <= baud_cnt + 1;
                    if (baud_tick) begin
                        baud_cnt  <= '0;
                        shift_reg <= {1'b0, shift_reg[7:1]};
                        bit_idx   <= bit_idx + 1;
                        if (bit_idx == 3'd7)
                            state <= S_STOP;
                    end
                end
                S_STOP: begin
                    o_tx     <= 1'b1;
                    baud_cnt <= baud_cnt + 1;
                    if (baud_tick) begin
                        baud_cnt <= '0;
                        state    <= S_IDLE;
                    end
                end
                default: begin
                    state <= S_IDLE;
                    o_tx  <= 1'b1;
                end
            endcase
        end
    end

    // =========================================================================
    // ASSERTIONS — Active in simulation, ignored by synthesis
    // =========================================================================
    // synthesis translate_off

    // --- Immediate Assertions ---

    // A1: Don't accept new data while transmitting
    always_ff @(posedge i_clk) begin
        if (!i_reset)
            assert (!(o_busy && i_valid))
                else $warning("[A1] Valid asserted while busy at t=%0t", $time);
    end

    // A2: State should never be undefined
    always_ff @(posedge i_clk) begin
        if (!i_reset)
            assert (state !== 2'bxx)
                else $fatal(1, "[A2] State is X at t=%0t", $time);
    end

    // --- Concurrent Assertions (require Questa/VCS/Verilator --assert) ---

    // P1: TX line must be high when idle
    property p_idle_high;
        @(posedge i_clk) disable iff (i_reset)
        (state == S_IDLE) |-> (o_tx == 1'b1);
    endproperty
    assert property (p_idle_high)
        else $error("[P1] TX not high during IDLE at t=%0t", $time);

    // P2: Start bit must be low
    property p_start_low;
        @(posedge i_clk) disable iff (i_reset)
        (state == S_START) |-> (o_tx == 1'b0);
    endproperty
    assert property (p_start_low)
        else $error("[P2] TX not low during START at t=%0t", $time);

    // P3: Stop bit must be high
    property p_stop_high;
        @(posedge i_clk) disable iff (i_reset)
        (state == S_STOP) |-> (o_tx == 1'b1);
    endproperty
    assert property (p_stop_high)
        else $error("[P3] TX not high during STOP at t=%0t", $time);

    // P4: After valid in idle, must transition to start
    property p_valid_starts_tx;
        @(posedge i_clk) disable iff (i_reset)
        (state == S_IDLE && i_valid) |=> (state == S_START);
    endproperty
    assert property (p_valid_starts_tx)
        else $error("[P4] Did not enter START after valid at t=%0t", $time);

    // P5: After stop + baud_tick, must return to idle
    property p_stop_returns_idle;
        @(posedge i_clk) disable iff (i_reset)
        (state == S_STOP && baud_tick) |=> (state == S_IDLE);
    endproperty
    assert property (p_stop_returns_idle)
        else $error("[P5] Did not return to IDLE after STOP at t=%0t", $time);

    // synthesis translate_on

endmodule
