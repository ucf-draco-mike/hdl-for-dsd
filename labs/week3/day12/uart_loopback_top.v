// UART Loopback: RX → TX echo
module uart_loopback_top (
    input  wire i_clk,
    input  wire i_uart_rx,
    output wire o_uart_tx,
    output wire o_led1
);
    wire [7:0] w_rx_data;
    wire       w_rx_valid;
    wire       w_tx_busy;

    uart_rx #(.CLK_FREQ(25_000_000)) rx (
        .i_clk(i_clk), .i_reset(1'b0),
        .i_rx(i_uart_rx),
        .o_data(w_rx_data), .o_valid(w_rx_valid)
    );

    uart_tx #(.CLK_FREQ(25_000_000)) tx (
        .i_clk(i_clk), .i_reset(1'b0),
        .i_valid(w_rx_valid), .i_data(w_rx_data),
        .o_tx(o_uart_tx), .o_busy(w_tx_busy)
    );

    assign o_led1 = ~w_tx_busy;
endmodule
