// =============================================================================
// spi_master.v — SPI Master Module (Mode 0)
// Day 12, Exercise 3
// =============================================================================

module spi_master #(
    parameter CLK_FREQ  = 25_000_000,
    parameter SPI_FREQ  = 1_000_000,
    parameter DATA_BITS = 8
)(
    input  wire                  i_clk,
    input  wire                  i_reset,
    input  wire                  i_start,
    input  wire [DATA_BITS-1:0]  i_tx_data,
    output reg  [DATA_BITS-1:0]  o_rx_data,
    output reg                   o_done,
    output wire                  o_busy,
    output reg                   o_sclk,
    output reg                   o_mosi,
    input  wire                  i_miso,
    output reg                   o_cs_n
);

    localparam CLKS_PER_HALF_SCLK = CLK_FREQ / (SPI_FREQ * 2);

    localparam S_IDLE    = 2'b00;
    localparam S_RUNNING = 2'b01;
    localparam S_DONE    = 2'b10;

    reg [1:0] r_state;
    reg [$clog2(CLKS_PER_HALF_SCLK)-1:0] r_sclk_count;
    reg [$clog2(DATA_BITS)-1:0] r_bit_count;
    reg [DATA_BITS-1:0] r_tx_shift, r_rx_shift;
    reg r_sclk_edge;

    assign o_busy = (r_state != S_IDLE);

    // TODO: Implement the SPI master FSM (Mode 0: CPOL=0, CPHA=0)
    //   IDLE: CS high, SCLK low. On i_start: assert CS, load shift reg
    //   RUNNING: Toggle SCLK at SPI_FREQ rate
    //     - Falling SCLK: shift out MOSI (MSB first)
    //     - Rising SCLK: sample MISO into shift reg
    //     - After DATA_BITS clocks: go to DONE
    //   DONE: Deassert CS, pulse o_done, return to IDLE

    // ---- YOUR CODE HERE ----

endmodule
