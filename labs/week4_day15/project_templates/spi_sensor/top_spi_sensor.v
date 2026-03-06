// top_spi_sensor.v — SPI Sensor Interface Project Skeleton
// Operation:
//   Periodically reads a SPI sensor (e.g., temperature, accelerometer)
//   Displays formatted value on 7-seg and transmits via UART
//   SW1 = manual trigger, SW2 = toggle auto/manual mode
//   LED1–LED3 = value magnitude bar graph
//
// Architecture:
//   Timer → SPI master → data formatter → display + UART TX
module top_spi_sensor (
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
    reg [23:0] r_heartbeat;
    always @(posedge i_clk)
        r_heartbeat <= r_heartbeat + 1;

    wire sw1, sw2;
    debounce db1 (.i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(sw1));
    debounce db2 (.i_clk(i_clk), .i_bouncy(i_switch2), .o_clean(sw2));

    // ── TODO: SPI master instantiation ──────────────────────────────────
    // Connect SCLK, MOSI, MISO, CS to PMOD header pins
    // ---- YOUR CODE HERE ----

    // ── TODO: Sample timer (e.g., 1 Hz auto-read) ──────────────────────
    // ---- YOUR CODE HERE ----

    // ── TODO: Read FSM ──────────────────────────────────────────────────
    // States: IDLE → SEND_CMD → WAIT_RESPONSE → STORE → DISPLAY
    // ---- YOUR CODE HERE ----

    // ── TODO: Data formatter + UART TX ──────────────────────────────────
    // ---- YOUR CODE HERE ----

    reg [3:0] r_disp1, r_disp2;
    wire [6:0] w_seg1, w_seg2;
    hex_to_7seg seg1 (.i_hex(r_disp1), .o_seg(w_seg1));
    hex_to_7seg seg2 (.i_hex(r_disp2), .o_seg(w_seg2));

    assign o_led1 = 1'b0;
    assign o_led2 = 1'b0;
    assign o_led3 = 1'b0;
    assign o_led4 = r_heartbeat[23];
    assign o_uart_tx = 1'b1;

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = w_seg1;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = w_seg2;
endmodule
