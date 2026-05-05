// =============================================================================
// day12_ex02_spi_master.v — SPI Master, Mode 0 (CPOL=0, CPHA=0)
// Day 12: UART RX, SPI & IP Integration
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Single-byte SPI master targeting an ADC-style slave (e.g. AD7476 family).
// FSM + shift-register split (same shape as the UART TX from Day 11):
//
//   IDLE ──i_start──► ASSERT_CS ──► SHIFT (8×) ──► DEASSERT ──► IDLE
//
//   * MSB-first   * MOSI changes on falling SCK    * MISO sampled on rising SCK
//   * SCK idles low (CPOL=0)                       * Phase 0 (CPHA=0)
//
// The clock divider (CLKS_PER_HALF_SCLK) sets SCK frequency:
//   SCK = CLK_FREQ / (2 * CLKS_PER_HALF_SCLK)
// At 25 MHz / 1 MHz SCK that's 12 clocks per half-period.
// =============================================================================
// Build:  iverilog -DSIMULATION -o sim day12_ex02_spi_master.v tb_spi_master.v && vvp sim
// Synth:  yosys -p "read_verilog day12_ex02_spi_master.v; synth_ice40 -top spi_master"
// =============================================================================
`timescale 1ns/1ps

module spi_master #(
    `ifdef SIMULATION
    parameter CLK_FREQ  = 1_000,
    parameter SPI_FREQ  = 100,
    `else
    parameter CLK_FREQ  = 25_000_000,
    parameter SPI_FREQ  =  1_000_000,
    `endif
    parameter DATA_BITS = 8
)(
    input  wire                  i_clk,
    input  wire                  i_reset,
    input  wire                  i_start,    // pulse to launch a transaction
    input  wire [DATA_BITS-1:0]  i_tx_data,  // byte to send (MSB first)
    output reg  [DATA_BITS-1:0]  o_rx_data,  // byte captured from MISO
    output reg                   o_done,     // 1-cycle pulse on completion
    output wire                  o_busy,     // high while a transaction is active
    // SPI bus (Mode 0)
    output reg                   o_sclk,
    output reg                   o_mosi,
    input  wire                  i_miso,
    output reg                   o_cs_n
);

    // ---- Clock divider ----
    localparam CLKS_PER_HALF_SCLK = (CLK_FREQ / (SPI_FREQ * 2));
    localparam DIV_W              = (CLKS_PER_HALF_SCLK <= 1)
                                        ? 1 : $clog2(CLKS_PER_HALF_SCLK);

    // ---- State encoding ----
    localparam S_IDLE = 2'd0;
    localparam S_RUN  = 2'd1;
    localparam S_DONE = 2'd2;

    reg [1:0]                       r_state;
    reg [DIV_W-1:0]                 r_sclk_cnt;
    reg [$clog2(DATA_BITS+1)-1:0]   r_bit_cnt;
    reg [DATA_BITS-1:0]             r_tx_shift;
    reg [DATA_BITS-1:0]             r_rx_shift;
    reg                             r_phase;     // 0 = next edge is rising

    assign o_busy = (r_state != S_IDLE);

    always @(posedge i_clk) begin
        if (i_reset) begin
            r_state    <= S_IDLE;
            o_cs_n     <= 1'b1;
            o_sclk     <= 1'b0;
            o_mosi     <= 1'b0;
            o_done     <= 1'b0;
            r_sclk_cnt <= {DIV_W{1'b0}};
            r_bit_cnt  <= 0;
            r_phase    <= 1'b0;
            r_tx_shift <= {DATA_BITS{1'b0}};
            r_rx_shift <= {DATA_BITS{1'b0}};
            o_rx_data  <= {DATA_BITS{1'b0}};
        end else begin
            o_done <= 1'b0;             // default: 1-cycle pulse

            case (r_state)
                S_IDLE: begin
                    o_cs_n <= 1'b1;
                    o_sclk <= 1'b0;
                    if (i_start) begin
                        r_tx_shift <= i_tx_data;
                        r_rx_shift <= {DATA_BITS{1'b0}};
                        r_bit_cnt  <= 0;
                        r_sclk_cnt <= {DIV_W{1'b0}};
                        r_phase    <= 1'b0;
                        o_cs_n     <= 1'b0;             // assert CS
                        o_mosi     <= i_tx_data[DATA_BITS-1]; // MSB first
                        r_state    <= S_RUN;
                    end
                end

                S_RUN: begin
                    if (r_sclk_cnt == CLKS_PER_HALF_SCLK - 1) begin
                        r_sclk_cnt <= {DIV_W{1'b0}};
                        if (!r_phase) begin
                            // Rising SCK edge: sample MISO into r_rx_shift
                            o_sclk     <= 1'b1;
                            r_rx_shift <= {r_rx_shift[DATA_BITS-2:0], i_miso};
                            r_phase    <= 1'b1;
                        end else begin
                            // Falling SCK edge: shift out next MOSI bit
                            o_sclk    <= 1'b0;
                            r_phase   <= 1'b0;
                            r_bit_cnt <= r_bit_cnt + 1'b1;
                            if (r_bit_cnt == DATA_BITS - 1) begin
                                r_state <= S_DONE;
                            end else begin
                                r_tx_shift <= {r_tx_shift[DATA_BITS-2:0], 1'b0};
                                o_mosi     <= r_tx_shift[DATA_BITS-2];
                            end
                        end
                    end else begin
                        r_sclk_cnt <= r_sclk_cnt + 1'b1;
                    end
                end

                S_DONE: begin
                    o_cs_n    <= 1'b1;
                    o_sclk    <= 1'b0;
                    o_rx_data <= r_rx_shift;
                    o_done    <= 1'b1;
                    r_state   <= S_IDLE;
                end

                default: r_state <= S_IDLE;
            endcase
        end
    end

endmodule
