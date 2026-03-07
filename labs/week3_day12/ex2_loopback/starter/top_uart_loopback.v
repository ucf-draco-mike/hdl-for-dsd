// =============================================================================
// top_uart_loopback.v — UART Loopback (RX → TX echo)
// Day 12, Exercise 2
// =============================================================================
// Type on PC terminal → echoes back. Crown jewel of Week 3.

module top_uart_loopback (
    input  wire i_clk,
    input  wire i_uart_rx,
    output wire o_uart_tx,
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g,
    output wire o_led1, o_led2, o_led3, o_led4
);

    wire [7:0] w_rx_data;
    wire       w_rx_valid;

    uart_rx #(.CLK_FREQ(25_000_000), .BAUD_RATE(115_200)) rx (
        .i_clk(i_clk),
        .i_rx(i_uart_rx),
        .o_data(w_rx_data), .o_valid(w_rx_valid)
    );

    // TODO: Connect RX output to TX input for echo
    //   When rx asserts o_valid, feed w_rx_data into the TX

    uart_tx #(.CLK_FREQ(25_000_000), .BAUD_RATE(115_200)) tx (
        .i_clk(i_clk),
        // TODO: Connect i_valid and i_data
        .i_valid(/* ---- YOUR CODE ---- */),
        .i_data(/* ---- YOUR CODE ---- */),
        .o_tx(o_uart_tx), .o_busy()
    );

    // TODO: Display last received byte on 7-segment
    //   Latch w_rx_data when w_rx_valid is high
    //   Show lower nibble on segment1

    // ---- YOUR CODE HERE ----

    // LED activity indicator
    reg r_activity;
    always @(posedge i_clk) begin
        if (w_rx_valid) r_activity <= ~r_activity;
    end
    assign o_led1 = r_activity;
    assign o_led2 = 1'b0;
    assign o_led3 = 1'b0;
    assign o_led4 = 1'b0;

endmodule
