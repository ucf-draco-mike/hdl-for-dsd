// top_life.v — Conway's Game of Life Project Skeleton
// Implementation:
//   8×8 grid stored in registers or block RAM (64 bits)
//   FSM iterates through each cell, counts neighbors, applies rules
//   SW1 = step (manual advance), SW2 = run/pause, SW4 = reset to seed
//   7-seg shows generation number (hex), LEDs show grid corner cells
//   Optional: UART dumps grid state to terminal as '#' and '.' characters
//
// Architecture:
//   Grid RAM (ping-pong) → neighbor counter → rule engine → display
module top_life (
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

    wire sw1, sw2, sw4;
    debounce db1 (.i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(sw1));
    debounce db2 (.i_clk(i_clk), .i_bouncy(i_switch2), .o_clean(sw2));
    debounce db4 (.i_clk(i_clk), .i_bouncy(i_switch4), .o_clean(sw4));

    // ── TODO: Edge detectors ────────────────────────────────────────────
    // ---- YOUR CODE HERE ----

    // ── TODO: Grid storage (ping-pong buffers) ──────────────────────────
    // Two 64-bit registers, or use block RAM with 8-bit rows
    // reg [7:0] grid_a [0:7];  // current generation
    // reg [7:0] grid_b [0:7];  // next generation
    // ---- YOUR CODE HERE ----

    // ── TODO: Seed pattern (loaded on reset) ────────────────────────────
    // Classic patterns: glider, blinker, toad, beacon
    // Use $readmemh("seed.hex", grid_a) or hardcode
    // ---- YOUR CODE HERE ----

    // ── TODO: Update FSM ────────────────────────────────────────────────
    // For each cell (row, col):
    //   1. Count 8 neighbors (wrap edges or treat boundary as dead)
    //   2. Apply rules:
    //      - alive + (2 or 3 neighbors) → alive
    //      - dead  + 3 neighbors        → alive
    //      - otherwise                  → dead
    //   3. Write to next-gen buffer
    // After all 64 cells: swap buffers, increment generation counter
    // ---- YOUR CODE HERE ----

    // ── TODO: Generation counter ────────────────────────────────────────
    reg [7:0] r_generation;
    // ---- YOUR CODE HERE ----

    // ── TODO: UART grid dump (optional stretch goal) ────────────────────
    // Print 8 rows of '#' and '.' characters to terminal each generation
    // ---- YOUR CODE HERE ----

    // ── 7-Segment Display (generation count) ────────────────────────────
    wire [6:0] w_seg1, w_seg2;
    hex_to_7seg seg1 (.i_hex(r_generation[7:4]), .o_seg(w_seg1));
    hex_to_7seg seg2 (.i_hex(r_generation[3:0]), .o_seg(w_seg2));

    assign o_led1 = 1'b0;  // TODO: grid[0][0]
    assign o_led2 = 1'b0;  // TODO: grid[0][7]
    assign o_led3 = 1'b0;  // TODO: grid[7][0]
    assign o_led4 = r_heartbeat[23];
    assign o_uart_tx = 1'b1;

    assign {o_segment1_a, o_segment1_b, o_segment1_c,
            o_segment1_d, o_segment1_e, o_segment1_f, o_segment1_g} = w_seg1;
    assign {o_segment2_a, o_segment2_b, o_segment2_c,
            o_segment2_d, o_segment2_e, o_segment2_f, o_segment2_g} = w_seg2;
endmodule
