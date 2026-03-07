// =============================================================================
// uart_tx.v — UART Transmitter (8N1, parameterized baud rate)
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Description:
//   Transmits 8-bit data in 8N1 UART format (1 start bit, 8 data bits, 1 stop bit).
//   Asserts o_busy during transmission; o_done pulses for one cycle when complete.
//   i_valid is sampled only when o_busy is low.
//
// Parameters:
//   CLK_FREQ    Input clock frequency in Hz (default 25_000_000)
//   BAUD_RATE   UART baud rate (default 9600)
//
// Ports:
//   i_clk       Clock
//   i_data      8-bit data byte to transmit
//   i_valid     Strobe: send i_data (ignored while o_busy is high)
//   o_tx        UART TX output (idle = 1)
//   o_busy      High during active transmission
//   o_done      One-cycle pulse when byte transmission completes
//
// Introduced: Day 11
// =============================================================================
module uart_tx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 9600
) (
    input  wire       i_clk,
    input  wire [7:0] i_data,
    input  wire       i_valid,
    output wire       o_tx,
    output wire       o_busy,
    output reg        o_done
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    // State machine
    localparam S_IDLE  = 2'd0,
               S_START = 2'd1,
               S_DATA  = 2'd2,
               S_STOP  = 2'd3;

    reg [1:0]                       r_state     = S_IDLE;
    reg [$clog2(CLKS_PER_BIT)-1:0]  r_baud_cnt  = 0;
    reg [2:0]                       r_bit_idx   = 0;
    reg [7:0]                       r_data      = 0;
    reg                             r_tx        = 1'b1;

    always @(posedge i_clk) begin
        o_done <= 1'b0;
        case (r_state)
            S_IDLE: begin
                r_tx <= 1'b1;
                if (i_valid) begin
                    r_data    <= i_data;
                    r_baud_cnt <= 0;
                    r_state   <= S_START;
                end
            end
            S_START: begin
                r_tx <= 1'b0;  // start bit
                if (r_baud_cnt < CLKS_PER_BIT - 1)
                    r_baud_cnt <= r_baud_cnt + 1'b1;
                else begin
                    r_baud_cnt <= 0;
                    r_bit_idx  <= 0;
                    r_state    <= S_DATA;
                end
            end
            S_DATA: begin
                r_tx <= r_data[r_bit_idx];  // LSB first
                if (r_baud_cnt < CLKS_PER_BIT - 1)
                    r_baud_cnt <= r_baud_cnt + 1'b1;
                else begin
                    r_baud_cnt <= 0;
                    if (r_bit_idx < 3'd7)
                        r_bit_idx <= r_bit_idx + 1'b1;
                    else
                        r_state <= S_STOP;
                end
            end
            S_STOP: begin
                r_tx <= 1'b1;  // stop bit
                if (r_baud_cnt < CLKS_PER_BIT - 1)
                    r_baud_cnt <= r_baud_cnt + 1'b1;
                else begin
                    r_baud_cnt <= 0;
                    o_done     <= 1'b1;
                    r_state    <= S_IDLE;
                end
            end
            default: r_state <= S_IDLE;
        endcase
    end

    assign o_tx   = r_tx;
    assign o_busy = (r_state != S_IDLE);

endmodule
