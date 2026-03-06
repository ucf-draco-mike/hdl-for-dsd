// top_cpu.v — Simple 4-bit Processor Project Skeleton
// Architecture:
//   4-bit data path, 8-bit instructions
//   4 general-purpose registers (R0–R3)
//   16-entry instruction ROM (loaded from .hex file)
//   FSM sequencer: FETCH → DECODE → EXECUTE → WRITEBACK
//
// Instruction format: [opcode:4][reg_dst:2][reg_src:2]
//   0000 = NOP            0100 = AND Rd, Rs
//   0001 = LOAD Rd, imm4  0101 = OR  Rd, Rs
//   0010 = ADD Rd, Rs     0110 = XOR Rd, Rs
//   0011 = SUB Rd, Rs     0111 = NOT Rd
//   1000 = MOV Rd, Rs     1111 = HALT
//
// Output: R0 on 7-seg display 1, PC on display 2, R1[3:0] on LEDs
//   SW1 = single-step, SW4 = reset
module top_cpu (
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

    wire sw1;
    debounce db1 (.i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(sw1));

    // ── TODO: Instruction ROM (16 × 8-bit) ─────────────────────────────
    // reg [7:0] rom [0:15];
    // initial $readmemh("program.hex", rom);
    // ---- YOUR CODE HERE ----

    // ── TODO: Program counter (4-bit) ───────────────────────────────────
    // reg [3:0] pc;
    // ---- YOUR CODE HERE ----

    // ── TODO: Register file (4 × 4-bit) ─────────────────────────────────
    // reg [3:0] regfile [0:3];
    // ---- YOUR CODE HERE ----

    // ── TODO: ALU ───────────────────────────────────────────────────────
    // ---- YOUR CODE HERE ----

    // ── TODO: Sequencer FSM (FETCH → DECODE → EXECUTE → WRITEBACK) ──────
    // Use a slow clock divider so execution is visible on LEDs/7-seg
    // SW1 = single-step mode, SW4 = reset
    // ---- YOUR CODE HERE ----

    // ── 7-Segment Display ───────────────────────────────────────────────
    wire [6:0] w_seg1, w_seg2;
    hex_to_7seg seg1 (.i_hex(4'h0), .o_seg(w_seg1)); // TODO: connect to R0
    hex_to_7seg seg2 (.i_hex(4'h0), .o_seg(w_seg2)); // TODO: connect to PC

    assign o_led1 = 1'b0;  // TODO: R1[0]
    assign o_led2 = 1'b0;  // TODO: R1[1]
    assign o_led3 = 1'b0;  // TODO: R1[2]
    assign o_led4 = r_heartbeat[23];
    assign o_uart_tx = 1'b1;

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = w_seg1;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = w_seg2;
endmodule
