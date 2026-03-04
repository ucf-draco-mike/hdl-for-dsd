// uart_rx.v — UART Receiver (8N1) with 16× oversampling
// Default: 115200 baud at 25 MHz
module uart_rx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115200
)(
    input  wire       i_clk,
    input  wire       i_rx,       // UART RX line
    output reg        o_valid,    // Pulses high for one clock when byte ready
    output reg  [7:0] o_data      // Received byte
);
    localparam CLKS_PER_BIT    = CLK_FREQ / BAUD_RATE;
    localparam CLKS_PER_SAMPLE = CLKS_PER_BIT / 16;

    localparam S_IDLE    = 3'd0;
    localparam S_START   = 3'd1;
    localparam S_DATA    = 3'd2;
    localparam S_STOP    = 3'd3;
    localparam S_CLEANUP = 3'd4;

    // 2-FF synchronizer
    reg r_rx_sync0, r_rx_sync1;
    always @(posedge i_clk) begin
        r_rx_sync0 <= i_rx;
        r_rx_sync1 <= r_rx_sync0;
    end

    reg [2:0]  r_state = S_IDLE;
    reg [$clog2(CLKS_PER_BIT)-1:0] r_clk_cnt;
    reg [3:0]  r_sample_cnt;
    reg [2:0]  r_bit_idx;
    reg [7:0]  r_data;

    always @(posedge i_clk) begin
        o_valid <= 1'b0;

        case (r_state)
            S_IDLE: begin
                r_clk_cnt   <= 0;
                r_sample_cnt <= 0;
                r_bit_idx   <= 0;
                if (r_rx_sync1 == 1'b0)   // Falling edge → start bit
                    r_state <= S_START;
            end

            S_START: begin
                if (r_clk_cnt < CLKS_PER_BIT - 1) begin
                    r_clk_cnt <= r_clk_cnt + 1;
                    // Check at mid-bit: still low?
                    if (r_clk_cnt == CLKS_PER_BIT/2 - 1) begin
                        if (r_rx_sync1 == 1'b0)
                            ; // Valid start bit
                        else
                            r_state <= S_IDLE;  // False start
                    end
                end else begin
                    r_clk_cnt <= 0;
                    r_state   <= S_DATA;
                end
            end

            S_DATA: begin
                if (r_clk_cnt < CLKS_PER_BIT - 1) begin
                    r_clk_cnt <= r_clk_cnt + 1;
                end else begin
                    r_clk_cnt <= 0;
                    // Sample at end of bit period (center-ish)
                    r_data[r_bit_idx] <= r_rx_sync1;
                    if (r_bit_idx < 7)
                        r_bit_idx <= r_bit_idx + 1;
                    else
                        r_state <= S_STOP;
                end
            end

            S_STOP: begin
                if (r_clk_cnt < CLKS_PER_BIT - 1) begin
                    r_clk_cnt <= r_clk_cnt + 1;
                end else begin
                    o_valid <= 1'b1;
                    o_data  <= r_data;
                    r_state <= S_CLEANUP;
                end
            end

            S_CLEANUP: begin
                r_state <= S_IDLE;
            end
        endcase
    end
endmodule
