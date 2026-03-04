module uart_rx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_rx,
    output reg  [7:0] o_data,
    output reg        o_valid
);
    localparam CLKS_PER_BIT    = CLK_FREQ / BAUD_RATE;
    localparam CLKS_PER_SAMPLE = CLKS_PER_BIT / 16;

    localparam S_IDLE=3'd0, S_START=3'd1, S_DATA=3'd2,
               S_STOP=3'd3, S_CLEANUP=3'd4;

    reg r_rx_sync1, r_rx_sync2;
    always @(posedge i_clk) begin
        r_rx_sync1 <= i_rx;
        r_rx_sync2 <= r_rx_sync1;
    end

    reg [2:0]  r_state;
    reg [$clog2(CLKS_PER_SAMPLE)-1:0] r_sample_cnt;
    reg [3:0]  r_oversample_cnt;
    reg [2:0]  r_bit_idx;
    reg [7:0]  r_shift;

    wire w_sample_tick = (r_sample_cnt == CLKS_PER_SAMPLE - 1);

    always @(posedge i_clk) begin
        if (i_reset) begin
            r_state <= S_IDLE; r_sample_cnt <= 0;
            r_oversample_cnt <= 0; r_bit_idx <= 0;
            r_shift <= 0; o_data <= 0; o_valid <= 0;
        end else begin
            o_valid <= 1'b0;

            case (r_state)
                S_IDLE: begin
                    r_sample_cnt <= 0; r_oversample_cnt <= 0; r_bit_idx <= 0;
                    if (r_rx_sync2 == 1'b0)
                        r_state <= S_START;
                end
                S_START: begin
                    if (w_sample_tick) begin
                        r_sample_cnt <= 0;
                        if (r_oversample_cnt == 4'd7) begin
                            r_oversample_cnt <= 0;
                            if (r_rx_sync2 == 1'b0)
                                r_state <= S_DATA;
                            else
                                r_state <= S_IDLE;
                        end else
                            r_oversample_cnt <= r_oversample_cnt + 1;
                    end else
                        r_sample_cnt <= r_sample_cnt + 1;
                end
                S_DATA: begin
                    if (w_sample_tick) begin
                        r_sample_cnt <= 0;
                        if (r_oversample_cnt == 4'd15) begin
                            r_oversample_cnt <= 0;
                            r_shift <= {r_rx_sync2, r_shift[7:1]};
                            if (r_bit_idx == 3'd7)
                                r_state <= S_STOP;
                            else
                                r_bit_idx <= r_bit_idx + 1;
                        end else
                            r_oversample_cnt <= r_oversample_cnt + 1;
                    end else
                        r_sample_cnt <= r_sample_cnt + 1;
                end
                S_STOP: begin
                    if (w_sample_tick) begin
                        r_sample_cnt <= 0;
                        if (r_oversample_cnt == 4'd15) begin
                            r_oversample_cnt <= 0;
                            o_data  <= r_shift;
                            o_valid <= 1'b1;
                            r_state <= S_CLEANUP;
                        end else
                            r_oversample_cnt <= r_oversample_cnt + 1;
                    end else
                        r_sample_cnt <= r_sample_cnt + 1;
                end
                S_CLEANUP: r_state <= S_IDLE;
            endcase
        end
    end
endmodule
