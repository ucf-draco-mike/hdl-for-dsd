// =============================================================================
// uart_tx.v — UART Transmitter (8N1)
// Day 11, Exercise 2
// =============================================================================
// FSM + PISO shift register + baud counter.
// Frame: IDLE(high) → START(low) → 8 data bits (LSB first) → STOP(high)

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

    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam BAUD_CNT_W   = $clog2(CLKS_PER_BIT);

    // State encoding
    localparam S_IDLE  = 2'd0;
    localparam S_START = 2'd1;
    localparam S_DATA  = 2'd2;
    localparam S_STOP  = 2'd3;

    reg [1:0]            r_state;
    reg [BAUD_CNT_W-1:0] r_baud_cnt;
    reg [7:0]            r_shift;
    reg [2:0]            r_bit_idx;

    wire w_baud_tick = (r_baud_cnt == CLKS_PER_BIT - 1);

    assign o_busy = (r_state != S_IDLE);

    // TODO: Implement the FSM
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
                        r_shift <= i_data;
                        r_state <= S_START;
                    end
                end

                S_START: begin
                    // TODO: Drive o_tx low (start bit)
                    //       Count baud cycles
                    //       On baud_tick, transition to S_DATA

                    // ---- YOUR CODE HERE ----
                end

                S_DATA: begin
                    // TODO: Drive o_tx with r_shift[0] (LSB first)
                    //       Count baud cycles
                    //       On baud_tick:
                    //         Shift r_shift right by 1
                    //         Increment r_bit_idx
                    //         If r_bit_idx == 7, go to S_STOP

                    // ---- YOUR CODE HERE ----
                end

                S_STOP: begin
                    // TODO: Drive o_tx high (stop bit)
                    //       Count baud cycles
                    //       On baud_tick, return to S_IDLE

                    // ---- YOUR CODE HERE ----
                end
            endcase
        end
    end

endmodule
