module uart_tx_sv #(
    parameter int CLK_FREQ  = 25_000_000,
    parameter int BAUD_RATE = 115_200
)(
    input  logic       i_clk, i_reset, i_valid,
    input  logic [7:0] i_data,
    output logic       o_tx, o_busy
);
    localparam int CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam int BAUD_CNT_W   = $clog2(CLKS_PER_BIT);

    typedef enum logic [1:0] {
        S_IDLE=2'd0, S_START=2'd1, S_DATA=2'd2, S_STOP=2'd3
    } uart_state_t;

    uart_state_t state;
    logic [BAUD_CNT_W-1:0] baud_cnt;
    logic [7:0] shift_reg;
    logic [2:0] bit_idx;

    logic baud_tick;
    assign baud_tick = (baud_cnt == BAUD_CNT_W'(CLKS_PER_BIT - 1));
    assign o_busy = (state != S_IDLE);

    always_ff @(posedge i_clk) begin
        if (i_reset) begin
            state <= S_IDLE; o_tx <= 1'b1;
            baud_cnt <= '0; bit_idx <= '0; shift_reg <= '0;
        end else begin
            case (state)
                S_IDLE: begin
                    o_tx <= 1'b1; baud_cnt <= '0; bit_idx <= '0;
                    if (i_valid) begin
                        shift_reg <= i_data; state <= S_START;
                    end
                end
                S_START: begin
                    o_tx <= 1'b0; baud_cnt <= baud_cnt + 1;
                    if (baud_tick) begin baud_cnt <= '0; state <= S_DATA; end
                end
                S_DATA: begin
                    o_tx <= shift_reg[0]; baud_cnt <= baud_cnt + 1;
                    if (baud_tick) begin
                        baud_cnt <= '0;
                        shift_reg <= {1'b0, shift_reg[7:1]};
                        if (bit_idx == 3'd7) state <= S_STOP;
                        else bit_idx <= bit_idx + 1;
                    end
                end
                S_STOP: begin
                    o_tx <= 1'b1; baud_cnt <= baud_cnt + 1;
                    if (baud_tick) begin baud_cnt <= '0; state <= S_IDLE; end
                end
            endcase
        end
    end
endmodule
