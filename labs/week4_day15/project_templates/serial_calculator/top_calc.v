// top_calc.v — Serial Calculator Project Skeleton
// Operation:
//   User sends expressions via UART terminal: "12+34\n"
//   Calculator parses, computes, and sends result back: "= 46\n"
//   Supported ops: +, -, *, & (AND), | (OR), ^ (XOR)
//   Current operand echoed on 7-seg displays
//
// Architecture:
//   UART RX → input parser FSM → ALU → result formatter → UART TX
module top_calc (
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

    localparam CLKS_PER_BIT = 217; // 25 MHz / 115200

    // ── TODO: UART RX/TX instantiation ──────────────────────────────────
    // ---- YOUR CODE HERE ----

    // ── TODO: Parser FSM ────────────────────────────────────────────────
    // States: IDLE → READ_A → READ_OP → READ_B → COMPUTE → SEND_RESULT
    // ASCII '0'-'9' = digits, accumulate into operand
    // '+','-','*','&','|','^' = operator
    // '\n' or '\r' = compute and transmit result
    // ---- YOUR CODE HERE ----

    // ── TODO: ALU (8-bit operands, 16-bit result for multiply) ──────────
    // ---- YOUR CODE HERE ----

    // ── TODO: Result formatter (binary → ASCII decimal via UART TX) ─────
    // ---- YOUR CODE HERE ----

    // ── 7-Segment Display (current operand) ─────────────────────────────
    reg [3:0] r_disp1, r_disp2;
    wire [6:0] w_seg1, w_seg2;
    hex_to_7seg seg1 (.i_hex(r_disp1), .o_seg(w_seg1));
    hex_to_7seg seg2 (.i_hex(r_disp2), .o_seg(w_seg2));

    assign o_led1 = 1'b0;  // TODO: RX activity
    assign o_led2 = 1'b0;  // TODO: TX activity
    assign o_led3 = 1'b0;  // TODO: error
    assign o_led4 = r_heartbeat[23];

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = w_seg1;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = w_seg2;
endmodule
