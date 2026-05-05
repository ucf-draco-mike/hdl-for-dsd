// =============================================================================
// day12_ex01_uart_rx.v — UART Receiver (8N1, 16× Oversampling)
// Day 12: UART RX, SPI & IP Integration
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Built-in 2-FF synchronizer on i_rx. 16× oversampling for center-of-bit
// sampling. Outputs o_valid pulse for one cycle when a byte is received.
// =============================================================================
// Build:  iverilog -DSIMULATION -o sim day12_ex01_uart_rx.v && vvp sim
// Synth:  yosys -p "read_verilog day12_ex01_uart_rx.v; synth_ice40 -top uart_rx"
// =============================================================================
`timescale 1ns/1ps

module uart_rx #(
    `ifdef SIMULATION
    parameter CLK_FREQ  = 1_600,       // tiny for fast sim
    parameter BAUD_RATE = 100
    `else
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
    `endif
)(
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_rx,           // serial input (external, async)
    output reg  [7:0] o_data,         // received byte
    output reg        o_valid         // one-cycle pulse when byte ready
);

    // ---- Oversampling Parameters ----
    localparam CLKS_PER_BIT  = CLK_FREQ / BAUD_RATE;
    localparam OS_RATE       = 16;
    localparam CLKS_PER_TICK = CLKS_PER_BIT / OS_RATE;
    localparam TICK_W        = $clog2(CLKS_PER_TICK + 1);

    // ---- State Encoding ----
    localparam S_IDLE  = 2'd0;
    localparam S_START = 2'd1;
    localparam S_DATA  = 2'd2;
    localparam S_STOP  = 2'd3;

    reg [1:0]       r_state, r_next_state;

    // ---- Built-in 2-FF Synchronizer ----
    reg r_rx_sync0, r_rx_sync1;
    always @(posedge i_clk) begin
        r_rx_sync0 <= i_rx;
        r_rx_sync1 <= r_rx_sync0;
    end

    // ---- Oversample Tick Generator ----
    reg [TICK_W-1:0] r_tick_cnt;
    wire w_os_tick = (r_tick_cnt == CLKS_PER_TICK - 1);

    always @(posedge i_clk) begin
        if (i_reset || r_state == S_IDLE)
            r_tick_cnt <= 0;
        else if (w_os_tick)
            r_tick_cnt <= 0;
        else
            r_tick_cnt <= r_tick_cnt + 1;
    end

    // ---- Oversample Counter (0..15 per bit) ----
    reg [3:0] r_os_cnt;

    // ---- Bit Index (0..7) ----
    reg [2:0] r_bit_idx;

    // ---- Data Shift Register ----
    reg [7:0] r_data;

    // ============================================================
    // Block 1 — State Register
    // ============================================================
    always @(posedge i_clk) begin
        if (i_reset)
            r_state <= S_IDLE;
        else
            r_state <= r_next_state;
    end

    // ============================================================
    // Block 2 — Next-State Logic
    // ============================================================
    always @(*) begin
        r_next_state = r_state;

        case (r_state)
            S_IDLE: begin
                if (!r_rx_sync1)            // falling edge: possible start
                    r_next_state = S_START;
            end
            S_START: begin
                if (w_os_tick && r_os_cnt == 7) begin
                    if (!r_rx_sync1)         // verified at center
                        r_next_state = S_DATA;
                    else
                        r_next_state = S_IDLE; // glitch
                end
            end
            S_DATA: begin
                if (w_os_tick && r_os_cnt == 15 && r_bit_idx == 7)
                    r_next_state = S_STOP;
            end
            S_STOP: begin
                if (w_os_tick && r_os_cnt == 15)
                    r_next_state = S_IDLE;
            end
            default: r_next_state = S_IDLE;
        endcase
    end

    // ---- Oversample Counter & Bit Index Management ----
    always @(posedge i_clk) begin
        if (i_reset) begin
            r_os_cnt  <= 0;
            r_bit_idx <= 0;
            r_data    <= 0;
            o_data    <= 0;
            o_valid   <= 0;
        end else begin
            o_valid <= 0;   // default: clear valid pulse

            case (r_state)
                S_IDLE: begin
                    r_os_cnt  <= 0;
                    r_bit_idx <= 0;
                end

                S_START: begin
                    if (w_os_tick)
                        r_os_cnt <= r_os_cnt + 1;
                    // Reset on entering DATA
                    if (w_os_tick && r_os_cnt == 7 && !r_rx_sync1) begin
                        r_os_cnt  <= 0;
                        r_bit_idx <= 0;
                    end
                end

                S_DATA: begin
                    if (w_os_tick) begin
                        if (r_os_cnt == 7) begin
                            // Center of bit — sample!
                            r_data[r_bit_idx] <= r_rx_sync1;
                        end
                        if (r_os_cnt == 15) begin
                            r_os_cnt <= 0;
                            r_bit_idx <= r_bit_idx + 1;
                        end else
                            r_os_cnt <= r_os_cnt + 1;
                    end
                end

                S_STOP: begin
                    if (w_os_tick) begin
                        if (r_os_cnt == 7) begin
                            // Center of stop bit — output the byte
                            o_data  <= r_data;
                            o_valid <= 1;
                        end
                        if (r_os_cnt == 15)
                            r_os_cnt <= 0;
                        else
                            r_os_cnt <= r_os_cnt + 1;
                    end
                end
            endcase
        end
    end

endmodule
