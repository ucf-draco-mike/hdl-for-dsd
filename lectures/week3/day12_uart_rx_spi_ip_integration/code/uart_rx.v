// =============================================================================
// uart_rx.v — UART Receiver (8N1) with 16× Oversampling
// Day 12: UART RX, SPI & IP Integration
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Built-in 2-FF synchronizer (RX is asynchronous).
// 16× oversampling for center-of-bit sampling.
// o_valid pulses for one cycle when a byte is received.

module uart_rx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_rx,          // serial input (asynchronous!)
    output reg  [7:0] o_data,        // received byte
    output reg        o_valid        // one-cycle pulse when byte ready
);

    // ===== Derived Parameters =====
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam BAUD_CNT_W   = $clog2(CLKS_PER_BIT);

    // ===== State Encoding =====
    localparam S_IDLE  = 2'd0;
    localparam S_START = 2'd1;
    localparam S_DATA  = 2'd2;
    localparam S_STOP  = 2'd3;

    // ===== 2-FF Synchronizer =====
    reg r_rx_sync_0, r_rx_sync;

    always @(posedge i_clk) begin
        r_rx_sync_0 <= i_rx;
        r_rx_sync   <= r_rx_sync_0;
    end

    // ===== Registers =====
    reg [1:0]            r_state;
    reg [BAUD_CNT_W-1:0] r_baud_cnt;
    reg [7:0]            r_shift;
    reg [2:0]            r_bit_idx;

    // Tick at the center of each bit (count to CLKS_PER_BIT-1)
    wire w_baud_tick = (r_baud_cnt == CLKS_PER_BIT - 1);
    // Tick at half-bit (for start-bit center alignment)
    wire w_half_tick = (r_baud_cnt == (CLKS_PER_BIT / 2) - 1);

    // ===== Main Sequential Logic =====
    always @(posedge i_clk) begin
        if (i_reset) begin
            r_state    <= S_IDLE;
            r_baud_cnt <= 0;
            r_bit_idx  <= 0;
            r_shift    <= 8'h00;
            o_data     <= 8'h00;
            o_valid    <= 1'b0;
        end else begin
            o_valid <= 1'b0;  // default: no valid pulse

            case (r_state)
                S_IDLE: begin
                    r_baud_cnt <= 0;
                    r_bit_idx  <= 0;
                    // Detect falling edge → possible start bit
                    if (r_rx_sync == 1'b0)
                        r_state <= S_START;
                end

                S_START: begin
                    // Count to half-bit to reach center of start bit
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_half_tick) begin
                        r_baud_cnt <= 0;
                        if (r_rx_sync == 1'b0)
                            // Still low → valid start bit, now aligned
                            r_state <= S_DATA;
                        else
                            // Noise — abort
                            r_state <= S_IDLE;
                    end
                end

                S_DATA: begin
                    // Count full bit period to reach center of each data bit
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        // Sample at center — shift in from MSB (LSB arrives first)
                        r_shift    <= {r_rx_sync, r_shift[7:1]};
                        r_bit_idx  <= r_bit_idx + 1;
                        if (r_bit_idx == 3'd7)
                            r_state <= S_STOP;
                    end
                end

                S_STOP: begin
                    // Wait for center of stop bit
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        if (r_rx_sync == 1'b1) begin
                            // Valid stop bit — output the received byte
                            o_data  <= r_shift;
                            o_valid <= 1'b1;
                        end
                        // else: framing error — discard
                        r_state <= S_IDLE;
                    end
                end

                default: r_state <= S_IDLE;
            endcase
        end
    end

endmodule
