// =============================================================================
// uart_rx.v — UART Receiver with 16× Oversampling (8N1)
// Day 12, Exercise 1
// =============================================================================

module uart_rx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_rx,        // serial input line
    output reg  [7:0] o_data,      // received byte
    output reg        o_valid      // pulsed high for 1 cycle when byte ready
);

    localparam CLKS_PER_BIT    = CLK_FREQ / BAUD_RATE;
    localparam CLKS_PER_SAMPLE = CLKS_PER_BIT / 16;     // 16× oversample

    localparam S_IDLE    = 3'd0;
    localparam S_START   = 3'd1;
    localparam S_DATA    = 3'd2;
    localparam S_STOP    = 3'd3;
    localparam S_CLEANUP = 3'd4;

    // 2-FF synchronizer for async i_rx
    reg r_rx_sync1, r_rx_sync2;
    always @(posedge i_clk) begin
        r_rx_sync1 <= i_rx;
        r_rx_sync2 <= r_rx_sync1;
    end

    reg [2:0]  r_state;
    reg [$clog2(CLKS_PER_SAMPLE)-1:0] r_sample_cnt;
    reg [3:0]  r_oversample_cnt;   // 0–15 per bit
    reg [2:0]  r_bit_idx;
    reg [7:0]  r_shift;

    wire w_sample_tick = (r_sample_cnt == CLKS_PER_SAMPLE - 1);

    // TODO: Implement the RX FSM
    always @(posedge i_clk) begin
        if (i_reset) begin
            r_state         <= S_IDLE;
            r_sample_cnt    <= 0;
            r_oversample_cnt <= 0;
            r_bit_idx       <= 0;
            r_shift         <= 0;
            o_data          <= 0;
            o_valid         <= 0;
        end else begin
            o_valid <= 1'b0;

            case (r_state)
                S_IDLE: begin
                    r_sample_cnt     <= 0;
                    r_oversample_cnt <= 0;
                    r_bit_idx        <= 0;
                    // TODO: Detect falling edge on r_rx_sync2
                    //       (line goes from high to low = start bit)
                    //       Transition to S_START

                    // ---- YOUR CODE HERE ----
                end

                S_START: begin
                    // TODO: Count oversample ticks
                    //       At tick 7 (center of start bit):
                    //         if r_rx_sync2 is still low → valid start bit → S_DATA
                    //         if r_rx_sync2 is high → glitch → S_IDLE

                    // ---- YOUR CODE HERE ----
                end

                S_DATA: begin
                    // TODO: Count oversample ticks (16 per bit)
                    //       At tick 15 (end of bit period), sample r_rx_sync2
                    //       Shift into r_shift: r_shift <= {r_rx_sync2, r_shift[7:1]}
                    //       After 8 bits (r_bit_idx == 7), go to S_STOP

                    // ---- YOUR CODE HERE ----
                end

                S_STOP: begin
                    // TODO: Count 16 oversample ticks for stop bit
                    //       At tick 15: output r_shift to o_data,
                    //       pulse o_valid, go to S_CLEANUP

                    // ---- YOUR CODE HERE ----
                end

                S_CLEANUP: begin
                    r_state <= S_IDLE;
                end
            endcase
        end
    end

endmodule
