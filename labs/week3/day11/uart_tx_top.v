// Top module: send "HELLO" on button press via UART
module uart_tx_top (
    input  wire i_clk,
    input  wire i_switch1,
    output wire o_uart_tx,
    output wire o_led1
);
    wire w_btn_clean, w_btn_edge;
    wire w_busy;
    reg  r_valid;
    reg  [7:0] r_char;
    reg  [2:0] r_idx;

    // Message: "HELLO\n"
    reg [7:0] r_msg [0:5];
    initial begin
        r_msg[0] = "H"; r_msg[1] = "E";
        r_msg[2] = "L"; r_msg[3] = "L";
        r_msg[4] = "O"; r_msg[5] = 8'h0A;
    end

    debounce #(.CLKS_TO_STABLE(250_000)) db (
        .i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(w_btn_clean)
    );

    edge_detect ed (
        .i_clk(i_clk), .i_signal(~w_btn_clean),
        .o_rising(w_btn_edge), .o_falling()
    );

    uart_tx #(.CLK_FREQ(25_000_000), .BAUD_RATE(115_200)) tx (
        .i_clk(i_clk), .i_reset(1'b0),
        .i_valid(r_valid), .i_data(r_char),
        .o_tx(o_uart_tx), .o_busy(w_busy)
    );

    assign o_led1 = ~w_busy;  // LED on when idle

    // Simple sequencer to send message
    reg [1:0] r_send_state;
    always @(posedge i_clk) begin
        r_valid <= 1'b0;
        case (r_send_state)
            0: if (w_btn_edge) begin
                   r_idx <= 0;
                   r_send_state <= 1;
               end
            1: if (!w_busy) begin
                   r_char  <= r_msg[r_idx];
                   r_valid <= 1'b1;
                   r_send_state <= 2;
               end
            2: if (w_busy) begin
                   if (r_idx == 5)
                       r_send_state <= 0;
                   else begin
                       r_idx <= r_idx + 1;
                       r_send_state <= 1;
                   end
               end
            default: r_send_state <= 0;
        endcase
    end
endmodule
