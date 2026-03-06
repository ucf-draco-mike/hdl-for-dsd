// top_uart_cmd.v — UART Command Parser Project Skeleton
// Receives ASCII commands via UART, parses them, controls LEDs/display
// Example commands: "LED1 ON", "LED2 OFF", "SHOW XX" (hex value on 7-seg)
//
// Architecture:
//   UART RX → Command Buffer (shift reg) → Parser FSM → LED/7-seg control
//                                        → Response TX → UART TX
module top_uart_cmd (
    input  wire i_clk,
    input  wire i_switch1, i_switch2, i_switch3, i_switch4,
    input  wire i_uart_rx,
    output wire o_uart_tx,
    output wire o_led1, o_led2, o_led3, o_led4,
    output wire o_segment1_a, o_segment1_b, o_segment1_c,
    output wire o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g,
    output wire o_segment2_a, o_segment2_b, o_segment2_c,
    output wire o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g
);
    // ────────────────────────────────────────────
    // Heartbeat — proves FPGA is configured
    // ────────────────────────────────────────────
    reg [23:0] r_heartbeat;
    always @(posedge i_clk)
        r_heartbeat <= r_heartbeat + 1;

    // ────────────────────────────────────────────
    // UART RX
    // ────────────────────────────────────────────
    wire       w_rx_valid;
    wire [7:0] w_rx_data;

    uart_rx #(.CLK_FREQ(25_000_000), .BAUD_RATE(115200)) u_rx (
        .i_clk   (i_clk),
        .i_rx    (i_uart_rx),
        .o_valid (w_rx_valid),
        .o_data  (w_rx_data)
    );

    // ────────────────────────────────────────────
    // UART TX
    // ────────────────────────────────────────────
    reg        r_tx_valid;
    reg  [7:0] r_tx_data;
    wire       w_tx_busy;

    uart_tx #(.CLK_FREQ(25_000_000), .BAUD_RATE(115200)) u_tx (
        .i_clk   (i_clk),
        .i_valid (r_tx_valid),
        .i_data  (r_tx_data),
        .o_tx    (o_uart_tx),
        .o_busy  (w_tx_busy)
    );

    // ────────────────────────────────────────────
    // Command Buffer — shift register for incoming chars
    // ────────────────────────────────────────────
    // TODO: Implement a shift register or small buffer to collect
    //       incoming characters until a newline (0x0D or 0x0A) is received.
    //       Suggested: 8-byte shift register, compare against known commands.
    //
    //       On newline, parse the buffer:
    //         "L1ON"  → LED1 on
    //         "L1OF"  → LED1 off
    //         "L2ON"  → LED2 on
    //         "L2OF"  → LED2 off
    //         "SHxx"  → display hex xx on 7-segment
    //       Send "OK\r\n" or "ERR\r\n" response after each command.
    //
    // ---- YOUR CODE HERE ----

    // ────────────────────────────────────────────
    // LED Control Registers
    // ────────────────────────────────────────────
    reg r_led1_on = 1'b0;
    reg r_led2_on = 1'b0;
    reg r_led3_on = 1'b0;

    // TODO: Set these registers based on parsed commands
    // ---- YOUR CODE HERE ----

    // ────────────────────────────────────────────
    // 7-Segment Display
    // ────────────────────────────────────────────
    reg [3:0] r_display_hi = 4'h0;
    reg [3:0] r_display_lo = 4'h0;

    wire [6:0] w_seg1, w_seg2;
    hex_to_7seg seg1 (.i_hex(r_display_hi), .o_seg(w_seg1));
    hex_to_7seg seg2 (.i_hex(r_display_lo), .o_seg(w_seg2));

    // ────────────────────────────────────────────
    // Output Assignments
    // ────────────────────────────────────────────
    assign o_led1 = r_led1_on;
    assign o_led2 = r_led2_on;
    assign o_led3 = r_led3_on;
    assign o_led4 = r_heartbeat[23];

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = w_seg1;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = w_seg2;
endmodule
