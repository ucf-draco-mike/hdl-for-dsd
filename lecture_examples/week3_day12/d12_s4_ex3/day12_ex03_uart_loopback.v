// =============================================================================
// day12_ex03_uart_loopback.v — UART RX → TX Echo (Loopback)
// Day 12: UART RX, SPI & IP Integration
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Gold-standard integration test: type on PC terminal → see echo.
// Also displays the received byte on 7-seg and LEDs.
// =============================================================================
// Synth:  yosys -p "read_verilog day12_ex03_uart_loopback.v uart_tx.v uart_rx.v \
//          hex_to_7seg.v; synth_ice40 -top uart_loopback"
// =============================================================================
`timescale 1ns/1ps

module uart_loopback #(
    parameter CLK_FREQ  = 25_000_000,
    parameter BAUD_RATE = 115_200
)(
    input  wire       i_clk,
    input  wire       i_uart_rx,     // UART RX from FTDI
    output wire       o_uart_tx,     // UART TX to FTDI
    output wire       o_led1,        // bit 0 of last byte
    output wire       o_led2,        // bit 1 of last byte
    output wire       o_led3,        // bit 2 of last byte
    output wire       o_led4,        // bit 3 of last byte
    // 7-segment display 1 (upper nibble) — active-low segments
    output wire       o_segment1_a,
    output wire       o_segment1_b,
    output wire       o_segment1_c,
    output wire       o_segment1_d,
    output wire       o_segment1_e,
    output wire       o_segment1_f,
    output wire       o_segment1_g,
    // 7-segment display 2 (lower nibble) — active-low segments
    output wire       o_segment2_a,
    output wire       o_segment2_b,
    output wire       o_segment2_c,
    output wire       o_segment2_d,
    output wire       o_segment2_e,
    output wire       o_segment2_f,
    output wire       o_segment2_g
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
        .i_rx    (i_uart_rx),
        .o_data  (w_rx_data),
        .o_valid (w_rx_valid)
    );

    // ---- UART Transmitter (echo) ----
    // Hold received byte until TX is free
    reg [7:0] r_tx_data;
    reg       r_tx_pending;

    initial begin
        r_tx_data    = 8'h00;
        r_tx_pending = 1'b0;
    end

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
        .o_tx    (o_uart_tx)
    );

    // ---- Display last received byte ----
    reg [7:0] r_display;
    initial r_display = 8'h00;
    always @(posedge i_clk)
        if (w_rx_valid) r_display <= w_rx_data;

    assign o_led1 = r_display[0];   // active-high LEDs
    assign o_led2 = r_display[1];
    assign o_led3 = r_display[2];
    assign o_led4 = r_display[3];

    // 7-segment decoders — show received byte as two hex digits
    wire [6:0] w_seg1, w_seg2;
    hex_to_7seg seg_hi (.i_hex(r_display[7:4]), .o_seg(w_seg1));
    hex_to_7seg seg_lo (.i_hex(r_display[3:0]), .o_seg(w_seg2));
    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = w_seg1;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = w_seg2;

endmodule
