module top_uart_hello (
    input  wire i_clk,
    input  wire i_switch1,
    output wire o_uart_tx,
    output wire o_led1, o_led2, o_led3, o_led4
);
    wire w_btn_clean;
    debounce #(.CLKS_TO_STABLE(250_000)) db (
        .i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(w_btn_clean)
    );

    reg r_btn_prev;
    always @(posedge i_clk) r_btn_prev <= w_btn_clean;
    wire w_btn_press = r_btn_prev & ~w_btn_clean; // falling edge = press

    wire w_tx_busy;
    reg  [7:0] r_tx_data;
    reg        r_tx_valid;

    uart_tx #(.CLK_FREQ(25_000_000), .BAUD_RATE(115_200)) tx (
        .i_clk(i_clk), .i_reset(1'b0),
        .i_valid(r_tx_valid), .i_data(r_tx_data),
        .o_tx(o_uart_tx), .o_busy(w_tx_busy)
    );

    reg [7:0] r_message [0:6];
    initial begin
        r_message[0]=8'h48; r_message[1]=8'h45; r_message[2]=8'h4C;
        r_message[3]=8'h4C; r_message[4]=8'h4F; r_message[5]=8'h0D;
        r_message[6]=8'h0A;
    end

    localparam ST_IDLE = 2'd0, ST_SEND = 2'd1, ST_WAIT = 2'd2;
    reg [1:0] r_state;
    reg [2:0] r_msg_idx;

    always @(posedge i_clk) begin
        r_tx_valid <= 1'b0;
        case (r_state)
            ST_IDLE: begin
                r_msg_idx <= 0;
                if (w_btn_press)
                    r_state <= ST_SEND;
            end
            ST_SEND: begin
                if (!w_tx_busy) begin
                    r_tx_data  <= r_message[r_msg_idx];
                    r_tx_valid <= 1'b1;
                    r_state    <= ST_WAIT;
                end
            end
            ST_WAIT: begin
                if (!w_tx_busy) begin
                    if (r_msg_idx == 3'd6)
                        r_state <= ST_IDLE;
                    else begin
                        r_msg_idx <= r_msg_idx + 1;
                        r_state   <= ST_SEND;
                    end
                end
            end
            default: r_state <= ST_IDLE;
        endcase
    end

    assign o_led1 = ~w_btn_press;
    assign o_led2 = ~w_tx_busy;
    assign o_led3 = ~(r_state != ST_IDLE);
    assign o_led4 = 1'b1;
endmodule
