// =============================================================================
// uart_tx.v — UART Transmitter (8N1)
// Day 11: UART Transmitter
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Parameterized clock frequency and baud rate.
// Valid/busy handshake. LSB-first transmission.
// Frame: IDLE(high) → START(low) → 8 data bits → STOP(high)

module uart_tx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_valid,      // pulse high for 1 cycle to start TX
    input  wire [7:0] i_data,       // byte to transmit
    output reg        o_tx,         // serial output line
    output wire       o_busy        // high during transmission
);

    // ===== Derived Parameters =====
    localparam CLKS_PER_BIT  = CLK_FREQ / BAUD_RATE;
    localparam BAUD_CNT_W    = $clog2(CLKS_PER_BIT);

    // ===== State Encoding =====
    localparam S_IDLE  = 2'd0;
    localparam S_START = 2'd1;
    localparam S_DATA  = 2'd2;
    localparam S_STOP  = 2'd3;

    // ===== Registers =====
    reg [1:0]            r_state;
    reg [BAUD_CNT_W-1:0] r_baud_cnt;
    reg [7:0]            r_shift;
    reg [2:0]            r_bit_idx;

    wire w_baud_tick = (r_baud_cnt == CLKS_PER_BIT - 1);

    // ===== Main Sequential Logic =====
    always @(posedge i_clk) begin
        if (i_reset) begin
            r_state    <= S_IDLE;
            o_tx       <= 1'b1;     // idle = high
            r_baud_cnt <= 0;
            r_bit_idx  <= 0;
            r_shift    <= 8'h00;
        end else begin
            case (r_state)
                S_IDLE: begin
                    o_tx       <= 1'b1;
                    r_baud_cnt <= 0;
                    r_bit_idx  <= 0;
                    if (i_valid) begin
                        r_shift <= i_data;  // latch the byte
                        r_state <= S_START;
                    end
                end

                S_START: begin
                    o_tx <= 1'b0;           // start bit = low
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        r_state    <= S_DATA;
                    end
                end

                S_DATA: begin
                    o_tx <= r_shift[0];     // LSB first
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        r_shift    <= {1'b0, r_shift[7:1]};  // shift right
                        r_bit_idx  <= r_bit_idx + 1;
                        if (r_bit_idx == 3'd7)
                            r_state <= S_STOP;
                    end
                end

                S_STOP: begin
                    o_tx <= 1'b1;           // stop bit = high
                    r_baud_cnt <= r_baud_cnt + 1;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        r_state    <= S_IDLE;
                    end
                end

                default: begin
                    r_state <= S_IDLE;
                    o_tx    <= 1'b1;
                end
            endcase
        end
    end

    assign o_busy = (r_state != S_IDLE);

endmodule
