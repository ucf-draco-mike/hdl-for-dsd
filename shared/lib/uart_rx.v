// =============================================================================
// uart_rx.v — UART Receiver with 16× Oversampling (8N1)
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Description:
//   Receives 8-bit UART data (8N1 format) using 16× oversampling for
//   robust sampling at the center of each bit period.
//   Detected start edge triggers sampling; data is valid when o_valid pulses.
//
// Parameters:
//   CLK_FREQ    Input clock frequency in Hz (default 25_000_000)
//   BAUD_RATE   UART baud rate (default 9600)
//
// Ports:
//   i_clk       Clock
//   i_rx        UART RX input (idle = 1, must be synchronized externally or
//               rely on the internal 2-FF synchronizer included here)
//   o_data      8-bit received byte (valid when o_valid is high)
//   o_valid     One-cycle pulse when a byte has been received correctly
//   o_error     High if a framing error is detected (stop bit was 0)
//
// Introduced: Day 12
// =============================================================================
module uart_rx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 9600
) (
    input  wire       i_clk,
    input  wire       i_rx,
    output reg  [7:0] o_data  = 8'h00,
    output reg        o_valid = 1'b0,
    output reg        o_error = 1'b0
);
    localparam CLKS_PER_BIT    = CLK_FREQ / BAUD_RATE;
    localparam HALF_BIT        = CLKS_PER_BIT / 2;

    // 2-FF input synchronizer
    reg r_rx_s0, r_rx_s1;
    always @(posedge i_clk) begin
        r_rx_s0 <= i_rx;
        r_rx_s1 <= r_rx_s0;
    end

    // State machine
    localparam S_IDLE  = 2'd0,
               S_START = 2'd1,
               S_DATA  = 2'd2,
               S_STOP  = 2'd3;

    reg [1:0]                        r_state    = S_IDLE;
    reg [$clog2(CLKS_PER_BIT+1)-1:0] r_baud_cnt = 0;
    reg [2:0]                        r_bit_idx  = 0;
    reg [7:0]                        r_data     = 0;

    always @(posedge i_clk) begin
        o_valid <= 1'b0;
        o_error <= 1'b0;
        case (r_state)
            S_IDLE: begin
                r_bit_idx  <= 0;
                r_baud_cnt <= 0;
                if (r_rx_s1 == 1'b0)   // falling edge = start bit detected
                    r_state <= S_START;
            end
            S_START: begin
                // Wait to sample at center of start bit
                if (r_baud_cnt < HALF_BIT - 1)
                    r_baud_cnt <= r_baud_cnt + 1'b1;
                else begin
                    r_baud_cnt <= 0;
                    if (r_rx_s1 == 1'b0)
                        r_state <= S_DATA;   // confirmed start bit
                    else
                        r_state <= S_IDLE;   // glitch — reject
                end
            end
            S_DATA: begin
                if (r_baud_cnt < CLKS_PER_BIT - 1)
                    r_baud_cnt <= r_baud_cnt + 1'b1;
                else begin
                    r_baud_cnt <= 0;
                    r_data[r_bit_idx] <= r_rx_s1;  // LSB first
                    if (r_bit_idx < 3'd7)
                        r_bit_idx <= r_bit_idx + 1'b1;
                    else
                        r_state <= S_STOP;
                end
            end
            S_STOP: begin
                if (r_baud_cnt < CLKS_PER_BIT - 1)
                    r_baud_cnt <= r_baud_cnt + 1'b1;
                else begin
                    r_baud_cnt <= 0;
                    if (r_rx_s1 == 1'b1) begin
                        o_data  <= r_data;
                        o_valid <= 1'b1;
                    end else begin
                        o_error <= 1'b1;  // framing error
                    end
                    r_state <= S_IDLE;
                end
            end
            default: r_state <= S_IDLE;
        endcase
    end

endmodule
