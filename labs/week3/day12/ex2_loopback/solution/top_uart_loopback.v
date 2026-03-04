module top_uart_loopback (
    input  wire i_clk,
    input  wire i_uart_rx,
    output wire o_uart_tx,
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g,
    output wire o_led1, o_led2, o_led3, o_led4
);
    wire [7:0] w_rx_data; wire w_rx_valid;
    uart_rx #(.CLK_FREQ(25_000_000),.BAUD_RATE(115_200)) rx (
        .i_clk(i_clk),.i_reset(1'b0),.i_rx(i_uart_rx),
        .o_data(w_rx_data),.o_valid(w_rx_valid));

    uart_tx #(.CLK_FREQ(25_000_000),.BAUD_RATE(115_200)) tx (
        .i_clk(i_clk),.i_reset(1'b0),
        .i_valid(w_rx_valid),.i_data(w_rx_data),
        .o_tx(o_uart_tx),.o_busy());

    reg [7:0] r_last_rx;
    always @(posedge i_clk)
        if (w_rx_valid) r_last_rx <= w_rx_data;

    hex_to_7seg seg1 (.i_hex(r_last_rx[3:0]),
        .o_seg_a(o_segment1_a),.o_seg_b(o_segment1_b),
        .o_seg_c(o_segment1_c),.o_seg_d(o_segment1_d),
        .o_seg_e(o_segment1_e),.o_seg_f(o_segment1_f),
        .o_seg_g(o_segment1_g));

    reg r_activity;
    always @(posedge i_clk) if (w_rx_valid) r_activity <= ~r_activity;
    assign o_led1 = ~r_activity;
    assign o_led2 = 1'b1; assign o_led3 = 1'b1; assign o_led4 = 1'b1;
endmodule
