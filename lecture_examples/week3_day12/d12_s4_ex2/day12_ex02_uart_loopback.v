// =============================================================================
// day12_ex02_uart_loopback.v — UART RX → TX Echo (Loopback)
// Day 12: UART RX, SPI & IP Integration
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Gold-standard integration test: type on PC terminal → see echo.
// Also displays the received byte on 7-seg and LEDs.
// =============================================================================
// Synth:  yosys -p "read_verilog day12_ex02_uart_loopback.v uart_tx.v uart_rx.v \
//          hex_to_7seg.v; synth_ice40 -top uart_loopback"
// =============================================================================

module uart_loopback #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       i_clk,
    input  wire       i_rx,          // UART RX from FTDI
    output wire       o_tx,          // UART TX to FTDI
    output wire [3:0] o_led,         // lower nibble of last byte
    output wire [6:0] o_seg1,        // upper nibble hex display
    output wire [6:0] o_seg2         // lower nibble hex display
);

    wire [7:0] w_rx_data;
    wire       w_rx_valid;
    wire       w_tx_busy;

    // ---- UART Receiver ----
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) rx_inst (
        .i_clk   (i_clk),
        .i_reset (1'b0),
        .i_rx    (i_rx),
        .o_data  (w_rx_data),
        .o_valid (w_rx_valid)
    );

    // ---- UART Transmitter (echo) ----
    // Hold received byte until TX is free
    reg [7:0] r_tx_data;
    reg       r_tx_pending;

    always @(posedge i_clk) begin
        if (w_rx_valid) begin
            r_tx_data    <= w_rx_data;
            r_tx_pending <= 1;
        end else if (r_tx_pending && !w_tx_busy) begin
            r_tx_pending <= 0;
        end
    end

    wire w_tx_valid = r_tx_pending && !w_tx_busy;

    uart_tx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) tx_inst (
        .i_clk   (i_clk),
        .i_reset (1'b0),
        .i_valid (w_tx_valid),
        .i_data  (r_tx_data),
        .o_busy  (w_tx_busy),
        .o_tx    (o_tx)
    );

    // ---- Display last received byte ----
    reg [7:0] r_display;
    always @(posedge i_clk)
        if (w_rx_valid) r_display <= w_rx_data;

    assign o_led = r_display[3:0];   // active-high LEDs

    // 7-segment decoders (if available in your library)
    // hex_to_7seg seg_hi (.i_hex(r_display[7:4]), .o_seg(o_seg1));
    // hex_to_7seg seg_lo (.i_hex(r_display[3:0]), .o_seg(o_seg2));

    // Placeholder if hex_to_7seg is not yet wired:
    assign o_seg1 = 7'h7F;
    assign o_seg2 = 7'h7F;

endmodule
