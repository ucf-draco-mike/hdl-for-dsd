// top_compute.v — Numerical Compute Engine Project Skeleton
// Operation:
//   Receives operands and opcode via UART
//   Computes using parameterized ALU + sequential multiplier + fixed-point
//   Returns result via UART, shows status on 7-seg and LEDs
//
// Protocol: [opcode 1B] [operand_a 2B] [operand_b 2B] → [result 4B]
//   Opcodes: 0x01=ADD, 0x02=SUB, 0x03=MUL, 0x04=AND, 0x05=OR, 0x06=XOR
//            0x10=FPMUL (Q8.8 fixed-point multiply)
//
// Architecture:
//   UART RX → command parser → ALU / multiplier / fixed-point → UART TX
module top_compute (
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

    localparam CLKS_PER_BIT = 217;

    // ── TODO: UART RX/TX ────────────────────────────────────────────────
    // ---- YOUR CODE HERE ----

    // ── TODO: Command parser FSM ────────────────────────────────────────
    // Read 5-byte command, dispatch to appropriate compute unit
    // ---- YOUR CODE HERE ----

    // ── TODO: Parameterized ALU (reuse from Day 3/13) ───────────────────
    // ---- YOUR CODE HERE ----

    // ── TODO: Sequential multiplier (reuse from Day 10) ─────────────────
    // ---- YOUR CODE HERE ----

    // ── TODO: Fixed-point multiplier (Q8.8, reuse from Day 10) ──────────
    // ---- YOUR CODE HERE ----

    // ── TODO: Result transmitter FSM ────────────────────────────────────
    // ---- YOUR CODE HERE ----

    reg [3:0] r_disp1, r_disp2;
    wire [6:0] w_seg1, w_seg2;
    hex_to_7seg seg1 (.i_hex(r_disp1), .o_seg(w_seg1));
    hex_to_7seg seg2 (.i_hex(r_disp2), .o_seg(w_seg2));

    assign o_led1 = 1'b0;  // TODO: busy indicator
    assign o_led2 = 1'b0;  // TODO: error indicator
    assign o_led3 = 1'b0;
    assign o_led4 = r_heartbeat[23];

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = w_seg1;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = w_seg2;
endmodule
