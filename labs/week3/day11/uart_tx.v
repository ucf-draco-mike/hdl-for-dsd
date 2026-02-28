// UART Transmitter — 8N1, parameterized baud rate
module uart_tx #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       i_clk, i_reset,
    input  wire       i_valid,
    input  wire [7:0] i_data,
    output reg        o_tx,
    output wire       o_busy
);
    localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

    localparam S_IDLE  = 2'd0, S_START = 2'd1,
               S_DATA  = 2'd2, S_STOP  = 2'd3;

    reg [1:0] r_state;
    reg [$clog2(CLKS_PER_BIT)-1:0] r_baud_cnt;
    reg [7:0] r_shift;
    reg [2:0] r_bit_idx;

    wire w_baud_tick = (r_baud_cnt == CLKS_PER_BIT - 1);
    assign o_busy = (r_state != S_IDLE);

    always @(posedge i_clk) begin
        if (i_reset) begin
            r_state    <= S_IDLE;
            o_tx       <= 1'b1;
            r_baud_cnt <= 0;
            r_bit_idx  <= 0;
        end else begin
            case (r_state)
                S_IDLE: begin
                    o_tx <= 1'b1;
                    r_baud_cnt <= 0;
                    r_bit_idx  <= 0;
                    if (i_valid) begin
                        r_shift <= i_data;
                        r_state <= S_START;
                    end
                end
                S_START: begin
                    o_tx <= 1'b0;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        r_state    <= S_DATA;
                    end else
                        r_baud_cnt <= r_baud_cnt + 1;
                end
                S_DATA: begin
                    o_tx <= r_shift[0];
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        r_shift    <= {1'b0, r_shift[7:1]};
                        if (r_bit_idx == 7)
                            r_state <= S_STOP;
                        else
                            r_bit_idx <= r_bit_idx + 1;
                    end else
                        r_baud_cnt <= r_baud_cnt + 1;
                end
                S_STOP: begin
                    o_tx <= 1'b1;
                    if (w_baud_tick) begin
                        r_baud_cnt <= 0;
                        r_state    <= S_IDLE;
                    end else
                        r_baud_cnt <= r_baud_cnt + 1;
                end
            endcase
        end
    end
endmodule
