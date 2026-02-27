// =============================================================================
// uart_loopback.v — UART Loopback Test (RX → TX Echo)
// Day 12: UART RX, SPI & IP Integration
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Type a character in the terminal → FPGA receives → FPGA echoes back.
// If you see what you typed, both RX and TX are working correctly.

module uart_loopback #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire i_clk,
    input  wire i_uart_rx,    // pin 73 on Go Board
    output wire o_uart_tx,    // pin 74 on Go Board
    output wire o_led1        // heartbeat
);

    // ===== Heartbeat LED =====
    reg [23:0] r_heartbeat;
    always @(posedge i_clk)
        r_heartbeat <= r_heartbeat + 1;
    assign o_led1 = r_heartbeat[23];

    // ===== Internal Wires =====
    wire [7:0] w_rx_data;
    wire       w_rx_valid;

    // ===== UART RX =====
    uart_rx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) rx_inst (
        .i_clk   (i_clk),
        .i_reset (1'b0),
        .i_rx    (i_uart_rx),
        .o_data  (w_rx_data),
        .o_valid (w_rx_valid)
    );

    // ===== UART TX — echo received byte =====
    uart_tx #(
        .CLK_FREQ  (CLK_FREQ),
        .BAUD_RATE (BAUD_RATE)
    ) tx_inst (
        .i_clk   (i_clk),
        .i_reset (1'b0),
        .i_valid (w_rx_valid),
        .i_data  (w_rx_data),
        .o_tx    (o_uart_tx),
        .o_busy  ()
    );

endmodule
