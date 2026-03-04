// =============================================================================
// uart_tx_sv.sv — UART TX Refactored with SystemVerilog
// Day 13, Exercise 3
// =============================================================================
// Refactor the Day 11 UART TX using all SV features:
//   logic, always_ff, enum states, '0 shorthand, parameter int

module uart_tx_sv #(
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

    // TODO: Replace localparam states with typedef enum
    // typedef enum logic [1:0] { ... } uart_state_t;
    // uart_state_t state;

    // ---- YOUR ENUM HERE ----

    logic [BAUD_CNT_W-1:0] baud_cnt;
    logic [7:0]            shift_reg;
    logic [2:0]            bit_idx;

    // TODO: Replace wire with logic, use '0 for zero constants
    // logic baud_tick;
    // assign baud_tick = (baud_cnt == BAUD_CNT_W'(CLKS_PER_BIT - 1));

    // ---- YOUR CODE HERE ----

    // TODO: Convert the main always block to always_ff
    //   The FSM logic is the same as Day 11, just with SV syntax:
    //   - Use enum state names
    //   - Use '0 for zero initialization
    //   - Use always_ff @(posedge i_clk)

    // ---- YOUR FSM HERE ----

endmodule
