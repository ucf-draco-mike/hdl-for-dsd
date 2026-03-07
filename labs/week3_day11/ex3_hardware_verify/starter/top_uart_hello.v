// =============================================================================
// top_uart_hello.v — Send "HELLO" on Button Press
// Day 11, Exercise 3: Hardware Verification
// =============================================================================

module top_uart_hello (
    input  wire i_clk,
    input  wire i_switch1,
    output wire o_uart_tx,
    output wire o_led1, o_led2, o_led3, o_led4
);

    // Debounce the button
    wire w_btn_clean;
    debounce #(.CLKS_TO_STABLE(250_000)) db (
        .i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(w_btn_clean)
    );

    wire w_btn_press;
    // TODO: Edge detect — one-cycle pulse on button press
    //   Hint: reg r_prev; w_btn_press = ~w_btn_clean & ~r_prev_inverted
    //   (remember: active-high button, so pressed = 1)

    // ---- YOUR CODE HERE ----

    // UART TX instance
    wire w_tx_busy;
    reg  [7:0] r_tx_data;
    reg        r_tx_valid;

    uart_tx #(.CLK_FREQ(25_000_000), .BAUD_RATE(115_200)) tx (
        .i_clk(i_clk),
        .i_valid(r_tx_valid), .i_data(r_tx_data),
        .o_tx(o_uart_tx), .o_busy(w_tx_busy)
    );

    // Message ROM: "HELLO\r\n"
    reg [7:0] r_message [0:6];
    initial begin
        r_message[0] = 8'h48;  // H
        r_message[1] = 8'h45;  // E
        r_message[2] = 8'h4C;  // L
        r_message[3] = 8'h4C;  // L
        r_message[4] = 8'h4F;  // O
        r_message[5] = 8'h0D;  // \r
        r_message[6] = 8'h0A;  // \n
    end

    // TODO: Implement a sequencer FSM
    //   States: IDLE, SEND, WAIT
    //   IDLE: wait for button press, then start sending
    //   SEND: assert r_tx_valid with r_message[index]
    //   WAIT: wait for !w_tx_busy, advance index
    //         if index == 7, return to IDLE

    // ---- YOUR CODE HERE ----

    // LED indicators
    assign o_led1 = w_btn_press;
    assign o_led2 = w_tx_busy;
    assign o_led3 = 1'b0;  // off
    assign o_led4 = 1'b0;  // off

endmodule
