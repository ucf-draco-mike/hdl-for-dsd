#!/usr/bin/env python3
"""
Repository Build Script — Accelerated HDL for Digital System Design
Generates lab scaffolding, shared library stubs, and project specs.

Run from repo root: python3 scripts/build_repo.py
"""

import os
import textwrap

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

def write_file(rel_path, content):
    full = os.path.join(BASE, rel_path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, 'w') as f:
        f.write(textwrap.dedent(content).lstrip('\n'))
    print(f"  ✓ {rel_path}")


# =============================================================================
# LAB SCAFFOLDING — Starter code, Makefiles, and READMEs for each day
# =============================================================================

LAB_DAYS = {
    # (week, day, topic, project_name, top_module, starter_files)
    1: (1, 1, "Welcome to Hardware Thinking", "button_logic", "button_logic", {
        "led_on.v": """\
            // Exercise 1: Simplest possible design — drive LED1 on
            module led_on (
                output wire o_led1
            );
                // Go Board LEDs are active low: 0 = on, 1 = off
                assign o_led1 = 1'b0;
            endmodule
        """,
        "buttons_to_leds.v": """\
            // Exercise 2: Direct button-to-LED mapping
            module buttons_to_leds (
                input  wire i_switch1, i_switch2, i_switch3, i_switch4,
                output wire o_led1, o_led2, o_led3, o_led4
            );
                assign o_led1 = i_switch1;
                assign o_led2 = i_switch2;
                assign o_led3 = i_switch3;
                assign o_led4 = i_switch4;
            endmodule
        """,
        "button_logic.v": """\
            // Exercise 3: Combinational logic between buttons and LEDs
            // TODO: Fill in the logic for each LED
            module button_logic (
                input  wire i_switch1, i_switch2, i_switch3, i_switch4,
                output wire o_led1, o_led2, o_led3, o_led4
            );
                // LED1: ON when BOTH sw1 AND sw2 are pressed (active-low)
                assign o_led1 = i_switch1 | i_switch2;

                // LED2: ON when EITHER sw3 OR sw4 is pressed
                assign o_led2 = i_switch3 & i_switch4;

                // LED3: XOR — on when exactly one of sw1,sw2 is pressed
                assign o_led3 = ~(i_switch1 ^ i_switch2);

                // LED4: Inverted sw1
                assign o_led4 = ~i_switch1;
            endmodule
        """,
    }),

    2: (1, 2, "Combinational Building Blocks", "hex_7seg", "hex_7seg_top", {
        "mux2to1.v": """\
            // Exercise 1: 2-to-1 multiplexer using conditional operator
            module mux2to1 #(parameter WIDTH = 4) (
                input  wire [WIDTH-1:0] i_a, i_b,
                input  wire             i_sel,
                output wire [WIDTH-1:0] o_y
            );
                // TODO: Implement using assign and ternary operator
                assign o_y = i_sel ? i_b : i_a;
            endmodule
        """,
        "full_adder.v": """\
            // Exercise 2: Single-bit full adder
            module full_adder (
                input  wire i_a, i_b, i_cin,
                output wire o_sum, o_cout
            );
                assign o_sum  = i_a ^ i_b ^ i_cin;
                assign o_cout = (i_a & i_b) | (i_a & i_cin) | (i_b & i_cin);
            endmodule
        """,
        "ripple_carry_adder.v": """\
            // Exercise 2: 4-bit ripple-carry adder from full adders
            module ripple_carry_adder (
                input  wire [3:0] i_a, i_b,
                input  wire       i_cin,
                output wire [3:0] o_sum,
                output wire       o_cout
            );
                wire [3:1] w_carry;

                full_adder fa0 (.i_a(i_a[0]), .i_b(i_b[0]), .i_cin(i_cin),      .o_sum(o_sum[0]), .o_cout(w_carry[1]));
                full_adder fa1 (.i_a(i_a[1]), .i_b(i_b[1]), .i_cin(w_carry[1]), .o_sum(o_sum[1]), .o_cout(w_carry[2]));
                full_adder fa2 (.i_a(i_a[2]), .i_b(i_b[2]), .i_cin(w_carry[2]), .o_sum(o_sum[2]), .o_cout(w_carry[3]));
                full_adder fa3 (.i_a(i_a[3]), .i_b(i_b[3]), .i_cin(w_carry[3]), .o_sum(o_sum[3]), .o_cout(o_cout));
            endmodule
        """,
        "hex_to_7seg.v": """\
            // Exercise 3: Hex digit to 7-segment decoder
            // Go Board has active-high segments: 1 = segment ON
            // Segment mapping: {a,b,c,d,e,f,g} = o_seg[6:0]
            //      ─a─
            //     |   |
            //     f   b
            //     |   |
            //      ─g─
            //     |   |
            //     e   c
            //     |   |
            //      ─d─
            module hex_to_7seg (
                input  wire [3:0] i_hex,
                output reg  [6:0] o_seg   // {a,b,c,d,e,f,g}
            );
                // TODO: Implement using case statement
                always @(*) begin
                    case (i_hex)
                        4'h0: o_seg = 7'b1111110;  // 0
                        4'h1: o_seg = 7'b0110000;  // 1
                        4'h2: o_seg = 7'b1101101;  // 2
                        4'h3: o_seg = 7'b1111001;  // 3
                        4'h4: o_seg = 7'b0110011;  // 4
                        4'h5: o_seg = 7'b1011011;  // 5
                        4'h6: o_seg = 7'b1011111;  // 6
                        4'h7: o_seg = 7'b1110000;  // 7
                        4'h8: o_seg = 7'b1111111;  // 8
                        4'h9: o_seg = 7'b1111011;  // 9
                        4'hA: o_seg = 7'b1110111;  // A
                        4'hB: o_seg = 7'b0011111;  // b
                        4'hC: o_seg = 7'b1001110;  // C
                        4'hD: o_seg = 7'b0111101;  // d
                        4'hE: o_seg = 7'b1001111;  // E
                        4'hF: o_seg = 7'b1000111;  // F
                        default: o_seg = 7'b0000000;
                    endcase
                end
            endmodule
        """,
    }),

    3: (1, 3, "Procedural Combinational Logic", "alu_4bit", "alu_4bit", {
        "alu_4bit.v": """\
            // Exercise: 4-bit ALU with 4 operations
            module alu_4bit (
                input  wire [3:0] i_a, i_b,
                input  wire [1:0] i_opcode,
                output reg  [3:0] o_result,
                output wire       o_zero,
                output reg        o_carry
            );
                // Opcodes: 00=ADD, 01=SUB, 10=AND, 11=OR
                localparam OP_ADD = 2'b00,
                           OP_SUB = 2'b01,
                           OP_AND = 2'b10,
                           OP_OR  = 2'b11;

                reg [4:0] r_wide_result;

                always @(*) begin
                    r_wide_result = 5'd0;  // default
                    case (i_opcode)
                        OP_ADD: r_wide_result = {1'b0, i_a} + {1'b0, i_b};
                        OP_SUB: r_wide_result = {1'b0, i_a} - {1'b0, i_b};
                        OP_AND: r_wide_result = {1'b0, i_a & i_b};
                        OP_OR:  r_wide_result = {1'b0, i_a | i_b};
                        default: r_wide_result = 5'd0;
                    endcase
                    o_result = r_wide_result[3:0];
                    o_carry  = r_wide_result[4];
                end

                assign o_zero = (o_result == 4'd0);
            endmodule
        """,
        "priority_encoder.v": """\
            // Exercise: Priority encoder — find highest active input
            module priority_encoder (
                input  wire [7:0] i_request,
                output reg  [2:0] o_index,
                output reg        o_valid
            );
                // TODO: Implement using casez or if-else chain
                always @(*) begin
                    o_valid = 1'b1;
                    casez (i_request)
                        8'b1???????: o_index = 3'd7;
                        8'b01??????: o_index = 3'd6;
                        8'b001?????: o_index = 3'd5;
                        8'b0001????: o_index = 3'd4;
                        8'b00001???: o_index = 3'd3;
                        8'b000001??: o_index = 3'd2;
                        8'b0000001?: o_index = 3'd1;
                        8'b00000001: o_index = 3'd0;
                        default: begin o_index = 3'd0; o_valid = 1'b0; end
                    endcase
                end
            endmodule
        """,
    }),

    4: (1, 4, "Sequential Logic Fundamentals", "led_blinker", "led_blinker", {
        "d_flip_flop.v": """\
            // Exercise 1: D flip-flop with synchronous reset
            module d_flip_flop (
                input  wire i_clk,
                input  wire i_reset,
                input  wire i_d,
                output reg  o_q
            );
                always @(posedge i_clk) begin
                    if (i_reset)
                        o_q <= 1'b0;
                    else
                        o_q <= i_d;
                end
            endmodule
        """,
        "register_n.v": """\
            // Exercise 2: N-bit loadable register
            module register_n #(parameter WIDTH = 8) (
                input  wire             i_clk, i_reset, i_load,
                input  wire [WIDTH-1:0] i_data,
                output reg  [WIDTH-1:0] o_q
            );
                always @(posedge i_clk) begin
                    if (i_reset)
                        o_q <= {WIDTH{1'b0}};
                    else if (i_load)
                        o_q <= i_data;
                end
            endmodule
        """,
        "led_blinker.v": """\
            // Exercise 3: LED blinker — 25 MHz to ~1 Hz
            module led_blinker (
                input  wire i_clk,
                output reg  o_led1
            );
                // 25 MHz / 2 = 12,500,000 cycles per toggle for 1 Hz
                localparam COUNT_MAX = 12_500_000 - 1;

                reg [23:0] r_counter;

                always @(posedge i_clk) begin
                    if (r_counter == COUNT_MAX) begin
                        r_counter <= 24'd0;
                        o_led1    <= ~o_led1;
                    end else begin
                        r_counter <= r_counter + 1;
                    end
                end
            endmodule
        """,
    }),

    5: (2, 5, "Counters, Shift Registers & Debouncing", "led_chase", "led_chase_top", {
        "counter_mod_n.v": """\
            // Modulo-N counter — counts 0 to N-1, then wraps
            module counter_mod_n #(parameter N = 10) (
                input  wire i_clk, i_reset, i_enable,
                output reg  [$clog2(N)-1:0] o_count,
                output wire o_tick
            );
                assign o_tick = (o_count == N - 1) && i_enable;

                always @(posedge i_clk) begin
                    if (i_reset)
                        o_count <= 0;
                    else if (i_enable) begin
                        if (o_count == N - 1)
                            o_count <= 0;
                        else
                            o_count <= o_count + 1;
                    end
                end
            endmodule
        """,
        "debounce.v": """\
            // Counter-based button debouncer
            module debounce #(parameter CLKS_TO_STABLE = 250_000) (
                input  wire i_clk,
                input  wire i_bouncy,
                output reg  o_clean
            );
                reg r_sync_0, r_sync_1;  // 2-FF synchronizer
                reg [$clog2(CLKS_TO_STABLE)-1:0] r_count;

                always @(posedge i_clk) begin
                    r_sync_0 <= i_bouncy;
                    r_sync_1 <= r_sync_0;
                end

                always @(posedge i_clk) begin
                    if (r_sync_1 != o_clean) begin
                        if (r_count == CLKS_TO_STABLE - 1) begin
                            o_clean <= r_sync_1;
                            r_count <= 0;
                        end else
                            r_count <= r_count + 1;
                    end else
                        r_count <= 0;
                end
            endmodule
        """,
        "shift_reg_piso.v": """\
            // Parallel-In Serial-Out shift register
            module shift_reg_piso #(parameter WIDTH = 8) (
                input  wire             i_clk, i_reset,
                input  wire             i_load, i_shift,
                input  wire [WIDTH-1:0] i_data,
                output wire             o_serial
            );
                reg [WIDTH-1:0] r_shift;

                assign o_serial = r_shift[0];

                always @(posedge i_clk) begin
                    if (i_reset)
                        r_shift <= {WIDTH{1'b0}};
                    else if (i_load)
                        r_shift <= i_data;
                    else if (i_shift)
                        r_shift <= {1'b0, r_shift[WIDTH-1:1]};
                end
            endmodule
        """,
        "edge_detect.v": """\
            // Rising-edge detector
            module edge_detect (
                input  wire i_clk,
                input  wire i_signal,
                output wire o_rising,
                output wire o_falling
            );
                reg r_prev;

                always @(posedge i_clk)
                    r_prev <= i_signal;

                assign o_rising  = i_signal & ~r_prev;
                assign o_falling = ~i_signal & r_prev;
            endmodule
        """,
    }),

    6: (2, 6, "Testbenches & Simulation-Driven Development", "alu_tb", "alu_4bit", {
        "tb_alu_4bit.v": """\
            // Self-checking ALU testbench template
            `timescale 1ns / 1ps

            module tb_alu_4bit;

                reg  [3:0] r_a, r_b;
                reg  [1:0] r_opcode;
                wire [3:0] w_result;
                wire       w_zero, w_carry;

                integer pass_count = 0, fail_count = 0;

                alu_4bit uut (
                    .i_a(r_a), .i_b(r_b), .i_opcode(r_opcode),
                    .o_result(w_result), .o_zero(w_zero), .o_carry(w_carry)
                );

                task check_alu;
                    input [3:0] a, b;
                    input [1:0] op;
                    input [3:0] exp_result;
                    input       exp_carry, exp_zero;
                    begin
                        r_a = a; r_b = b; r_opcode = op;
                        #10;
                        if (w_result === exp_result && w_carry === exp_carry && w_zero === exp_zero) begin
                            pass_count = pass_count + 1;
                        end else begin
                            $display("FAIL: a=%h b=%h op=%b | got r=%h c=%b z=%b | exp r=%h c=%b z=%b",
                                     a, b, op, w_result, w_carry, w_zero, exp_result, exp_carry, exp_zero);
                            fail_count = fail_count + 1;
                        end
                    end
                endtask

                initial begin
                    $dumpfile("dump.vcd");
                    $dumpvars(0, tb_alu_4bit);

                    // TODO: Add test vectors using check_alu task
                    // Example: check_alu(4'h3, 4'h5, 2'b00, 4'h8, 1'b0, 1'b0);  // ADD: 3+5=8

                    #10;
                    $display("\\n=== Test Summary: %0d passed, %0d failed ===", pass_count, fail_count);
                    if (fail_count == 0) $display("ALL TESTS PASSED");
                    else                 $display("SOME TESTS FAILED");
                    $finish;
                end
            endmodule
        """,
        "tb_debounce.v": """\
            // Debounce module testbench template
            `timescale 1ns / 1ps

            module tb_debounce;
                reg  r_clk = 0;
                reg  r_bouncy;
                wire w_clean;

                // Use small threshold for simulation speed
                debounce #(.CLKS_TO_STABLE(10)) uut (
                    .i_clk(r_clk), .i_bouncy(r_bouncy), .o_clean(w_clean)
                );

                always #20 r_clk = ~r_clk;  // 25 MHz

                initial begin
                    $dumpfile("dump.vcd");
                    $dumpvars(0, tb_debounce);
                    r_bouncy = 1; // unpressed

                    // TODO: Test clean press, bounce rejection, glitch rejection
                    #1000;

                    $display("Debounce testbench complete — inspect waveforms");
                    $finish;
                end
            endmodule
        """,
    }),

    7: (2, 7, "Finite State Machines", "traffic_light", "traffic_light", {
        "traffic_light.v": """\
            // Traffic light controller FSM — 3-always-block style
            module traffic_light (
                input  wire       i_clk, i_reset,
                output reg  [2:0] o_light  // {RED, YELLOW, GREEN}
            );
                // State encoding
                localparam S_GREEN  = 2'd0,
                           S_YELLOW = 2'd1,
                           S_RED    = 2'd2;

                // Timing (use small values for sim; parameterize for board)
                localparam GREEN_TIME  = 5_000_000;  // ~200ms at 25MHz
                localparam YELLOW_TIME = 1_250_000;  // ~50ms
                localparam RED_TIME    = 5_000_000;   // ~200ms

                reg [1:0] r_state, r_next_state;
                reg [22:0] r_timer;

                // Block 1: State register
                always @(posedge i_clk) begin
                    if (i_reset)
                        r_state <= S_RED;
                    else
                        r_state <= r_next_state;
                end

                // Block 2: Next-state logic
                always @(*) begin
                    r_next_state = r_state;  // default: stay
                    case (r_state)
                        S_GREEN:  if (r_timer == 0) r_next_state = S_YELLOW;
                        S_YELLOW: if (r_timer == 0) r_next_state = S_RED;
                        S_RED:    if (r_timer == 0) r_next_state = S_GREEN;
                        default:  r_next_state = S_RED;
                    endcase
                end

                // Block 3: Output logic
                always @(*) begin
                    case (r_state)
                        S_GREEN:  o_light = 3'b001;
                        S_YELLOW: o_light = 3'b010;
                        S_RED:    o_light = 3'b100;
                        default:  o_light = 3'b100;
                    endcase
                end

                // Timer (counts down to 0)
                always @(posedge i_clk) begin
                    if (i_reset)
                        r_timer <= RED_TIME - 1;
                    else if (r_state != r_next_state) begin
                        case (r_next_state)
                            S_GREEN:  r_timer <= GREEN_TIME - 1;
                            S_YELLOW: r_timer <= YELLOW_TIME - 1;
                            S_RED:    r_timer <= RED_TIME - 1;
                            default:  r_timer <= RED_TIME - 1;
                        endcase
                    end else if (r_timer != 0)
                        r_timer <= r_timer - 1;
                end
            endmodule
        """,
        "pattern_detector.v": """\
            // Button-press pattern detector FSM
            // Detects sequence: SW1, SW2, SW1 -> lights LED
            module pattern_detector (
                input  wire i_clk, i_reset,
                input  wire i_btn1, i_btn2,
                output reg  o_detected
            );
                localparam S_IDLE = 3'd0,
                           S_GOT1 = 3'd1,
                           S_GOT2 = 3'd2,
                           S_DONE = 3'd3;

                reg [2:0] r_state, r_next;

                // Block 1: State register
                always @(posedge i_clk)
                    if (i_reset) r_state <= S_IDLE;
                    else         r_state <= r_next;

                // Block 2: Next-state logic
                always @(*) begin
                    r_next = r_state;
                    case (r_state)
                        S_IDLE: if (i_btn1) r_next = S_GOT1;
                        S_GOT1: if (i_btn2) r_next = S_GOT2;
                                else if (i_btn1) r_next = S_GOT1;  // stay
                                else r_next = S_IDLE;  // timeout/wrong button
                        S_GOT2: if (i_btn1) r_next = S_DONE;
                                else if (i_btn2) r_next = S_GOT2;
                                else r_next = S_IDLE;
                        S_DONE: r_next = S_IDLE;  // auto-return
                        default: r_next = S_IDLE;
                    endcase
                end

                // Block 3: Output logic
                always @(*) begin
                    o_detected = (r_state == S_DONE);
                end
            endmodule
        """,
    }),

    8: (2, 8, "Hierarchy, Parameters & Generate", "param_counter", "top_hierarchy", {
        "counter_param.v": """\
            // Parameterized N-bit counter
            module counter_param #(parameter WIDTH = 8) (
                input  wire               i_clk, i_reset, i_enable,
                output reg  [WIDTH-1:0]   o_count,
                output wire               o_max
            );
                assign o_max = &o_count;  // all 1s

                always @(posedge i_clk) begin
                    if (i_reset)
                        o_count <= {WIDTH{1'b0}};
                    else if (i_enable)
                        o_count <= o_count + 1;
                end
            endmodule
        """,
        "blink_n.v": """\
            // Parameterized LED blinker — generate N instances at different rates
            module blink_n #(
                parameter NUM_LEDS = 4,
                parameter CLK_FREQ = 25_000_000
            )(
                input  wire              i_clk,
                output wire [NUM_LEDS-1:0] o_leds
            );
                genvar g;
                generate
                    for (g = 0; g < NUM_LEDS; g = g + 1) begin : gen_blink
                        reg [$clog2(CLK_FREQ)-1:0] r_cnt;
                        reg r_led;

                        localparam HALF_PERIOD = CLK_FREQ / (2 * (g + 1));

                        always @(posedge i_clk) begin
                            if (r_cnt >= HALF_PERIOD - 1) begin
                                r_cnt <= 0;
                                r_led <= ~r_led;
                            end else
                                r_cnt <= r_cnt + 1;
                        end

                        assign o_leds[g] = r_led;
                    end
                endgenerate
            endmodule
        """,
    }),

    9: (3, 9, "Memory: RAM, ROM & Block RAM", "memory_demo", "rom_demo_top", {
        "rom_16x8.v": """\
            // 16x8 ROM using $readmemh
            module rom_16x8 (
                input  wire [3:0] i_addr,
                output wire [7:0] o_data
            );
                reg [7:0] r_mem [0:15];

                initial $readmemh("rom_data.hex", r_mem);

                assign o_data = r_mem[i_addr];
            endmodule
        """,
        "ram_sync.v": """\
            // Synchronous single-port RAM
            module ram_sync #(
                parameter ADDR_WIDTH = 4,
                parameter DATA_WIDTH = 8
            )(
                input  wire                  i_clk,
                input  wire                  i_we,
                input  wire [ADDR_WIDTH-1:0] i_addr,
                input  wire [DATA_WIDTH-1:0] i_wdata,
                output reg  [DATA_WIDTH-1:0] o_rdata
            );
                reg [DATA_WIDTH-1:0] r_mem [0:(1<<ADDR_WIDTH)-1];

                always @(posedge i_clk) begin
                    if (i_we)
                        r_mem[i_addr] <= i_wdata;
                    o_rdata <= r_mem[i_addr];
                end
            endmodule
        """,
        "rom_data.hex": """\
            48 65 6C 6C
            6F 20 57 6F
            72 6C 64 21
            0A 00 00 00
        """,
    }),

    10: (3, 10, "Timing, Clocking & Constraints", "timing_demo", "pll_blink_top", {
        "pll_blink.v": """\
            // PLL-based clock generation example
            // Use icepll to generate parameters: icepll -i 25 -o 50
            module pll_blink_top (
                input  wire i_clk,      // 25 MHz from oscillator
                output wire o_led1,     // blink at 25 MHz rate
                output wire o_led2      // blink at 50 MHz rate
            );
                wire w_pll_clk;
                wire w_pll_locked;

                // iCE40 PLL — parameters from icepll tool
                SB_PLL40_CORE #(
                    .FEEDBACK_PATH("SIMPLE"),
                    .DIVR(4'b0000),
                    .DIVF(7'b0111111),
                    .DIVQ(3'b100),
                    .FILTER_RANGE(3'b001)
                ) pll_inst (
                    .REFERENCECLK(i_clk),
                    .PLLOUTCORE(w_pll_clk),
                    .LOCK(w_pll_locked),
                    .RESETB(1'b1),
                    .BYPASS(1'b0)
                );

                // Blinker on original 25 MHz clock
                reg [23:0] r_cnt_25;
                always @(posedge i_clk)
                    r_cnt_25 <= r_cnt_25 + 1;
                assign o_led1 = r_cnt_25[23];

                // Blinker on PLL-generated clock
                reg [23:0] r_cnt_pll;
                always @(posedge w_pll_clk)
                    r_cnt_pll <= r_cnt_pll + 1;
                assign o_led2 = r_cnt_pll[23];
            endmodule
        """,
    }),

    11: (3, 11, "UART Transmitter", "uart_tx", "uart_tx_top", {
        "uart_tx.v": """\
            // UART Transmitter — 8N1, parameterized baud rate
            module uart_tx #(
                parameter CLK_FREQ  = 25_000_000,
                parameter BAUD_RATE = 115_200
            )(
                input  wire       i_clk, i_reset,
                input  wire       i_valid,
                input  wire [7:0] i_data,
                output reg        o_tx,
                output wire       o_busy
            );
                localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;

                localparam S_IDLE  = 2'd0, S_START = 2'd1,
                           S_DATA  = 2'd2, S_STOP  = 2'd3;

                reg [1:0] r_state;
                reg [$clog2(CLKS_PER_BIT)-1:0] r_baud_cnt;
                reg [7:0] r_shift;
                reg [2:0] r_bit_idx;

                wire w_baud_tick = (r_baud_cnt == CLKS_PER_BIT - 1);
                assign o_busy = (r_state != S_IDLE);

                always @(posedge i_clk) begin
                    if (i_reset) begin
                        r_state    <= S_IDLE;
                        o_tx       <= 1'b1;
                        r_baud_cnt <= 0;
                        r_bit_idx  <= 0;
                    end else begin
                        case (r_state)
                            S_IDLE: begin
                                o_tx <= 1'b1;
                                r_baud_cnt <= 0;
                                r_bit_idx  <= 0;
                                if (i_valid) begin
                                    r_shift <= i_data;
                                    r_state <= S_START;
                                end
                            end
                            S_START: begin
                                o_tx <= 1'b0;
                                if (w_baud_tick) begin
                                    r_baud_cnt <= 0;
                                    r_state    <= S_DATA;
                                end else
                                    r_baud_cnt <= r_baud_cnt + 1;
                            end
                            S_DATA: begin
                                o_tx <= r_shift[0];
                                if (w_baud_tick) begin
                                    r_baud_cnt <= 0;
                                    r_shift    <= {1'b0, r_shift[7:1]};
                                    if (r_bit_idx == 7)
                                        r_state <= S_STOP;
                                    else
                                        r_bit_idx <= r_bit_idx + 1;
                                end else
                                    r_baud_cnt <= r_baud_cnt + 1;
                            end
                            S_STOP: begin
                                o_tx <= 1'b1;
                                if (w_baud_tick) begin
                                    r_baud_cnt <= 0;
                                    r_state    <= S_IDLE;
                                end else
                                    r_baud_cnt <= r_baud_cnt + 1;
                            end
                        endcase
                    end
                end
            endmodule
        """,
        "uart_tx_top.v": """\
            // Top module: send "HELLO" on button press via UART
            module uart_tx_top (
                input  wire i_clk,
                input  wire i_switch1,
                output wire o_uart_tx,
                output wire o_led1
            );
                wire w_btn_clean, w_btn_edge;
                wire w_busy;
                reg  r_valid;
                reg  [7:0] r_char;
                reg  [2:0] r_idx;

                // Message: "HELLO\\n"
                reg [7:0] r_msg [0:5];
                initial begin
                    r_msg[0] = "H"; r_msg[1] = "E";
                    r_msg[2] = "L"; r_msg[3] = "L";
                    r_msg[4] = "O"; r_msg[5] = 8'h0A;
                end

                debounce #(.CLKS_TO_STABLE(250_000)) db (
                    .i_clk(i_clk), .i_bouncy(i_switch1), .o_clean(w_btn_clean)
                );

                edge_detect ed (
                    .i_clk(i_clk), .i_signal(~w_btn_clean),
                    .o_rising(w_btn_edge), .o_falling()
                );

                uart_tx #(.CLK_FREQ(25_000_000), .BAUD_RATE(115_200)) tx (
                    .i_clk(i_clk), .i_reset(1'b0),
                    .i_valid(r_valid), .i_data(r_char),
                    .o_tx(o_uart_tx), .o_busy(w_busy)
                );

                assign o_led1 = ~w_busy;  // LED on when idle

                // Simple sequencer to send message
                reg [1:0] r_send_state;
                always @(posedge i_clk) begin
                    r_valid <= 1'b0;
                    case (r_send_state)
                        0: if (w_btn_edge) begin
                               r_idx <= 0;
                               r_send_state <= 1;
                           end
                        1: if (!w_busy) begin
                               r_char  <= r_msg[r_idx];
                               r_valid <= 1'b1;
                               r_send_state <= 2;
                           end
                        2: if (w_busy) begin
                               if (r_idx == 5)
                                   r_send_state <= 0;
                               else begin
                                   r_idx <= r_idx + 1;
                                   r_send_state <= 1;
                               end
                           end
                        default: r_send_state <= 0;
                    endcase
                end
            endmodule
        """,
    }),

    12: (3, 12, "UART RX, SPI & IP Integration", "uart_loopback", "uart_loopback_top", {
        "uart_rx.v": """\
            // UART Receiver — 16x oversampling, 8N1
            module uart_rx #(
                parameter CLK_FREQ  = 25_000_000,
                parameter BAUD_RATE = 115_200
            )(
                input  wire       i_clk, i_reset,
                input  wire       i_rx,
                output reg  [7:0] o_data,
                output reg        o_valid
            );
                localparam CLKS_PER_BIT  = CLK_FREQ / BAUD_RATE;
                localparam HALF_BIT      = CLKS_PER_BIT / 2;

                localparam S_IDLE  = 2'd0, S_START = 2'd1,
                           S_DATA  = 2'd2, S_STOP  = 2'd3;

                reg [1:0] r_state;
                reg [$clog2(CLKS_PER_BIT)-1:0] r_clk_cnt;
                reg [7:0] r_shift;
                reg [2:0] r_bit_idx;
                reg r_rx_sync0, r_rx_sync1;

                // 2-FF synchronizer
                always @(posedge i_clk) begin
                    r_rx_sync0 <= i_rx;
                    r_rx_sync1 <= r_rx_sync0;
                end

                always @(posedge i_clk) begin
                    if (i_reset) begin
                        r_state  <= S_IDLE;
                        o_valid  <= 1'b0;
                    end else begin
                        o_valid <= 1'b0;
                        case (r_state)
                            S_IDLE: begin
                                r_clk_cnt <= 0;
                                r_bit_idx <= 0;
                                if (r_rx_sync1 == 1'b0)
                                    r_state <= S_START;
                            end
                            S_START: begin
                                if (r_clk_cnt == HALF_BIT - 1) begin
                                    if (r_rx_sync1 == 1'b0) begin
                                        r_clk_cnt <= 0;
                                        r_state   <= S_DATA;
                                    end else
                                        r_state <= S_IDLE;
                                end else
                                    r_clk_cnt <= r_clk_cnt + 1;
                            end
                            S_DATA: begin
                                if (r_clk_cnt == CLKS_PER_BIT - 1) begin
                                    r_clk_cnt <= 0;
                                    r_shift   <= {r_rx_sync1, r_shift[7:1]};
                                    if (r_bit_idx == 7)
                                        r_state <= S_STOP;
                                    else
                                        r_bit_idx <= r_bit_idx + 1;
                                end else
                                    r_clk_cnt <= r_clk_cnt + 1;
                            end
                            S_STOP: begin
                                if (r_clk_cnt == CLKS_PER_BIT - 1) begin
                                    o_data  <= r_shift;
                                    o_valid <= 1'b1;
                                    r_state <= S_IDLE;
                                end else
                                    r_clk_cnt <= r_clk_cnt + 1;
                            end
                        endcase
                    end
                end
            endmodule
        """,
        "uart_loopback_top.v": """\
            // UART Loopback: RX → TX echo
            module uart_loopback_top (
                input  wire i_clk,
                input  wire i_uart_rx,
                output wire o_uart_tx,
                output wire o_led1
            );
                wire [7:0] w_rx_data;
                wire       w_rx_valid;
                wire       w_tx_busy;

                uart_rx #(.CLK_FREQ(25_000_000)) rx (
                    .i_clk(i_clk), .i_reset(1'b0),
                    .i_rx(i_uart_rx),
                    .o_data(w_rx_data), .o_valid(w_rx_valid)
                );

                uart_tx #(.CLK_FREQ(25_000_000)) tx (
                    .i_clk(i_clk), .i_reset(1'b0),
                    .i_valid(w_rx_valid), .i_data(w_rx_data),
                    .o_tx(o_uart_tx), .o_busy(w_tx_busy)
                );

                assign o_led1 = ~w_tx_busy;
            endmodule
        """,
    }),
}

# Days 13-16 are special: SV labs and project days
SV_DAYS = {
    13: (4, 13, "SystemVerilog for Design", "sv_refactor", None),
    14: (4, 14, "SystemVerilog for Verification", "sv_verify", None),
    15: (4, 15, "Final Project Build Day", None, None),
    16: (4, 16, "Demos, Reflection & Next Steps", None, None),
}


def generate_lab_makefile(day_num, project_name, top_module):
    """Generate a per-day Makefile."""
    pcf_path = "../../../../shared/pcf/go_board.pcf" if day_num < 13 else "../../../../shared/pcf/go_board.pcf"
    return f"""\
# Lab {day_num} Makefile — Accelerated HDL Course
PROJECT  = {project_name}
TOP      = {top_module}
PCF      = {pcf_path}

SRCS     = $(filter-out tb_%.v, $(wildcard *.v))
TB       = tb_$(PROJECT).v

DEVICE   = hx1k
PACKAGE  = vq100

all: $(PROJECT).bin

$(PROJECT).json: $(SRCS)
\tyosys -p "synth_ice40 -top $(TOP) -json $@" $(SRCS)

$(PROJECT).asc: $(PROJECT).json $(PCF)
\tnextpnr-ice40 --$(DEVICE) --package $(PACKAGE) --pcf $(PCF) --json $< --asc $@

$(PROJECT).bin: $(PROJECT).asc
\ticepack $< $@

prog: $(PROJECT).bin
\ticeprog $<

sim: $(TB) $(SRCS)
\tiverilog -g2012 -Wall -o sim.vvp $(TB) $(SRCS)
\tvvp sim.vvp
\t@echo "\\n=== Open waveforms: gtkwave dump.vcd ==="

wave: sim
\tgtkwave dump.vcd &

show: $(SRCS)
\tyosys -p "read_verilog $(SRCS); synth_ice40 -top $(TOP); show"

clean:
\trm -f *.json *.asc *.bin *.vvp *.vcd

.PHONY: all prog sim wave show clean
"""


def generate_lab_readme(day_num, week_num, topic, project_name, files):
    """Generate a per-day lab README."""
    file_list = "\n".join(f"| `{f}` | Starter code |" for f in sorted(files.keys()) if f.endswith('.v'))
    return f"""\
# Day {day_num}: {topic}

**Week {week_num} · Lab Session**

## Objectives

See `docs/day{day_num:02d}_*.md` for detailed learning objectives and exercises.

## Files

| File | Description |
|------|-------------|
{file_list}
| `Makefile` | Build automation |

## Quick Start

```bash
# Simulate
make sim

# Synthesize and program the Go Board
make prog

# View waveforms
make wave
```

## Deliverables

Complete the exercises in the daily plan document and demonstrate working hardware.
"""


def build_labs():
    """Generate all lab scaffolding."""
    print("\n=== Building Lab Scaffolding ===\n")

    for day_num, (week, _, topic, project, top, files) in LAB_DAYS.items():
        day_dir = f"labs/week{week}/day{day_num:02d}"

        # Starter code files
        for filename, content in files.items():
            write_file(f"{day_dir}/{filename}", content)

        # Makefile
        if project and top:
            write_file(f"{day_dir}/Makefile", generate_lab_makefile(day_num, project, top))

        # README
        write_file(f"{day_dir}/README.md", generate_lab_readme(day_num, week, topic, project, files))

    # Week 4 lab stubs (SV and project days)
    for day_num, (week, _, topic, _, _) in SV_DAYS.items():
        day_dir = f"labs/week{week}/day{day_num:02d}"
        readme = f"# Day {day_num}: {topic}\n\n**Week {week} · Lab Session**\n\nSee `docs/day{day_num:02d}_*.md` for detailed session guide.\n"
        write_file(f"{day_dir}/README.md", readme)


# =============================================================================
# SHARED MODULE LIBRARY — Verified reusable modules
# =============================================================================

SHARED_MODULES = {
    "hex_to_7seg.v": """\
        // Hex-to-7-segment decoder — Go Board compatible
        // Built: Day 2 | Tested: Day 6
        module hex_to_7seg (
            input  wire [3:0] i_hex,
            output reg  [6:0] o_seg
        );
            always @(*) begin
                case (i_hex)
                    4'h0: o_seg = 7'b1111110;
                    4'h1: o_seg = 7'b0110000;
                    4'h2: o_seg = 7'b1101101;
                    4'h3: o_seg = 7'b1111001;
                    4'h4: o_seg = 7'b0110011;
                    4'h5: o_seg = 7'b1011011;
                    4'h6: o_seg = 7'b1011111;
                    4'h7: o_seg = 7'b1110000;
                    4'h8: o_seg = 7'b1111111;
                    4'h9: o_seg = 7'b1111011;
                    4'hA: o_seg = 7'b1110111;
                    4'hB: o_seg = 7'b0011111;
                    4'hC: o_seg = 7'b1001110;
                    4'hD: o_seg = 7'b0111101;
                    4'hE: o_seg = 7'b1001111;
                    4'hF: o_seg = 7'b1000111;
                    default: o_seg = 7'b0000000;
                endcase
            end
        endmodule
    """,
    "debounce.v": """\
        // Counter-based button debouncer with 2-FF synchronizer
        // Built: Day 5 | Tested: Day 6
        module debounce #(parameter CLKS_TO_STABLE = 250_000) (
            input  wire i_clk, i_bouncy,
            output reg  o_clean
        );
            reg r_sync_0, r_sync_1;
            reg [$clog2(CLKS_TO_STABLE)-1:0] r_count;
            always @(posedge i_clk) begin
                r_sync_0 <= i_bouncy;
                r_sync_1 <= r_sync_0;
            end
            always @(posedge i_clk) begin
                if (r_sync_1 != o_clean) begin
                    if (r_count == CLKS_TO_STABLE - 1) begin
                        o_clean <= r_sync_1;
                        r_count <= 0;
                    end else r_count <= r_count + 1;
                end else r_count <= 0;
            end
        endmodule
    """,
    "edge_detect.v": """\
        // Rising/falling edge detector
        // Built: Day 5 | Tested: Day 6
        module edge_detect (
            input  wire i_clk, i_signal,
            output wire o_rising, o_falling
        );
            reg r_prev;
            always @(posedge i_clk) r_prev <= i_signal;
            assign o_rising  = i_signal & ~r_prev;
            assign o_falling = ~i_signal & r_prev;
        endmodule
    """,
    "counter_mod_n.v": """\
        // Modulo-N counter
        // Built: Day 5 | Tested: Day 6
        module counter_mod_n #(parameter N = 10) (
            input  wire i_clk, i_reset, i_enable,
            output reg  [$clog2(N)-1:0] o_count,
            output wire o_tick
        );
            assign o_tick = (o_count == N - 1) && i_enable;
            always @(posedge i_clk) begin
                if (i_reset) o_count <= 0;
                else if (i_enable)
                    o_count <= (o_count == N - 1) ? 0 : o_count + 1;
            end
        endmodule
    """,
    "shift_reg_piso.v": """\
        // Parallel-In Serial-Out shift register
        // Built: Day 5 | Used: Day 11 (UART TX)
        module shift_reg_piso #(parameter WIDTH = 8) (
            input  wire             i_clk, i_reset, i_load, i_shift,
            input  wire [WIDTH-1:0] i_data,
            output wire             o_serial
        );
            reg [WIDTH-1:0] r_shift;
            assign o_serial = r_shift[0];
            always @(posedge i_clk) begin
                if (i_reset)     r_shift <= {WIDTH{1'b0}};
                else if (i_load) r_shift <= i_data;
                else if (i_shift) r_shift <= {1'b0, r_shift[WIDTH-1:1]};
            end
        endmodule
    """,
    "uart_tx.v": """\
        // UART Transmitter — 8N1, parameterized
        // Built: Day 11 | Tested: Day 11
        module uart_tx #(
            parameter CLK_FREQ  = 25_000_000,
            parameter BAUD_RATE = 115_200
        )(
            input  wire       i_clk, i_reset, i_valid,
            input  wire [7:0] i_data,
            output reg        o_tx,
            output wire       o_busy
        );
            localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
            localparam S_IDLE=0, S_START=1, S_DATA=2, S_STOP=3;
            reg [1:0] r_state;
            reg [$clog2(CLKS_PER_BIT)-1:0] r_baud_cnt;
            reg [7:0] r_shift;
            reg [2:0] r_bit_idx;
            wire w_tick = (r_baud_cnt == CLKS_PER_BIT - 1);
            assign o_busy = (r_state != S_IDLE);
            always @(posedge i_clk) begin
                if (i_reset) begin r_state<=S_IDLE; o_tx<=1; r_baud_cnt<=0; r_bit_idx<=0; end
                else case (r_state)
                    S_IDLE:  begin o_tx<=1; r_baud_cnt<=0; r_bit_idx<=0;
                             if (i_valid) begin r_shift<=i_data; r_state<=S_START; end end
                    S_START: begin o_tx<=0; if(w_tick) begin r_baud_cnt<=0; r_state<=S_DATA; end
                             else r_baud_cnt<=r_baud_cnt+1; end
                    S_DATA:  begin o_tx<=r_shift[0]; if(w_tick) begin r_baud_cnt<=0;
                             r_shift<={1'b0,r_shift[7:1]};
                             if(r_bit_idx==7) r_state<=S_STOP; else r_bit_idx<=r_bit_idx+1; end
                             else r_baud_cnt<=r_baud_cnt+1; end
                    S_STOP:  begin o_tx<=1; if(w_tick) begin r_baud_cnt<=0; r_state<=S_IDLE; end
                             else r_baud_cnt<=r_baud_cnt+1; end
                endcase
            end
        endmodule
    """,
    "uart_rx.v": """\
        // UART Receiver — 8N1 with oversampling
        // Built: Day 12 | Tested: Day 12
        module uart_rx #(
            parameter CLK_FREQ  = 25_000_000,
            parameter BAUD_RATE = 115_200
        )(
            input  wire       i_clk, i_reset, i_rx,
            output reg  [7:0] o_data,
            output reg        o_valid
        );
            localparam CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;
            localparam HALF_BIT     = CLKS_PER_BIT / 2;
            localparam S_IDLE=0, S_START=1, S_DATA=2, S_STOP=3;
            reg [1:0] r_state;
            reg [$clog2(CLKS_PER_BIT)-1:0] r_clk_cnt;
            reg [7:0] r_shift;
            reg [2:0] r_bit_idx;
            reg r_rx0, r_rx1;
            always @(posedge i_clk) begin r_rx0<=i_rx; r_rx1<=r_rx0; end
            always @(posedge i_clk) begin
                if (i_reset) begin r_state<=S_IDLE; o_valid<=0; end
                else begin
                    o_valid <= 0;
                    case (r_state)
                        S_IDLE:  begin r_clk_cnt<=0; r_bit_idx<=0;
                                 if (!r_rx1) r_state<=S_START; end
                        S_START: if (r_clk_cnt==HALF_BIT-1) begin
                                     if (!r_rx1) begin r_clk_cnt<=0; r_state<=S_DATA; end
                                     else r_state<=S_IDLE;
                                 end else r_clk_cnt<=r_clk_cnt+1;
                        S_DATA:  if (r_clk_cnt==CLKS_PER_BIT-1) begin
                                     r_clk_cnt<=0; r_shift<={r_rx1,r_shift[7:1]};
                                     if (r_bit_idx==7) r_state<=S_STOP;
                                     else r_bit_idx<=r_bit_idx+1;
                                 end else r_clk_cnt<=r_clk_cnt+1;
                        S_STOP:  if (r_clk_cnt==CLKS_PER_BIT-1) begin
                                     o_data<=r_shift; o_valid<=1; r_state<=S_IDLE;
                                 end else r_clk_cnt<=r_clk_cnt+1;
                    endcase
                end
            end
        endmodule
    """,
}


def build_shared_lib():
    """Generate the shared module library."""
    print("\n=== Building Shared Module Library ===\n")

    readme = """\
        # Shared Module Library

        Verified, reusable Verilog modules built across the course.
        Each module has been tested with a self-checking testbench.

        ## Modules

        | Module | Description | Built | Tested |
        |--------|-------------|-------|--------|
        | `hex_to_7seg` | Hex digit to 7-segment decoder | Day 2 | Day 6 |
        | `debounce` | Counter-based button debouncer | Day 5 | Day 6 |
        | `edge_detect` | Rising/falling edge detector | Day 5 | Day 6 |
        | `counter_mod_n` | Parameterized modulo-N counter | Day 5 | Day 6 |
        | `shift_reg_piso` | Parallel-in serial-out shift register | Day 5 | Day 6 |
        | `uart_tx` | UART transmitter (8N1, parameterized) | Day 11 | Day 11 |
        | `uart_rx` | UART receiver with oversampling | Day 12 | Day 12 |

        ## Usage

        Copy or reference modules from this library into your project:
        ```bash
        cp ../../shared/lib/debounce.v .
        ```

        Or include in your Makefile SRCS path.
    """
    write_file("shared/lib/README.md", readme)

    for filename, content in SHARED_MODULES.items():
        write_file(f"shared/lib/{filename}", content)


# =============================================================================
# PROJECT SPECS
# =============================================================================

def build_projects():
    """Generate final project specifications."""
    print("\n=== Building Project Specifications ===\n")

    write_file("projects/README.md", """\
        # Final Project — Week 4

        Choose one project (or propose your own with instructor approval).
        All projects must include a testbench for at least one nontrivial module.

        ## Project Options

        | Project | Key Concepts | Difficulty |
        |---------|-------------|------------|
        | **VGA Pattern Generator** | VGA timing, counters, ROM, pixel addressing | ★★☆ |
        | **Digital Clock** | Counters, 7-seg multiplexing, UART time-set | ★★☆ |
        | **Reaction Time Game** | FSM, counters, RNG (LFSR), 7-seg display | ★★☆ |
        | **UART Command Parser** | UART RX/TX, FSM, string matching, LED control | ★★★ |
        | **SPI Sensor Interface** | SPI master, data formatting, display | ★★★ |
        | **Simple 4-bit Processor** | ALU + register file + sequencer + ROM program | ★★★ |
        | **Conway's Game of Life** | Block RAM grid, FSM update logic, LED/VGA | ★★★ |
        | **Music/Tone Generator** | Counters, frequency dividers, PWM, sequencer | ★★☆ |
        | **Stopwatch / Lap Timer** | Precision counters, debounce, 7-seg, UART log | ★★☆ |

        ## Requirements

        1. **Functional demonstration** on the Go Board
        2. **Clean module hierarchy** — no monolithic designs
        3. **Self-checking testbench** for at least one key module
        4. **5-minute presentation**: live demo + architecture diagram + lessons learned

        ## Grading Rubric

        | Component | Weight | Description |
        |-----------|--------|-------------|
        | Functionality | 30% | Does the project work as specified? |
        | Design Quality | 25% | Clean hierarchy, parameterization, naming |
        | Verification | 20% | Testbench quality, assertions, coverage |
        | Integration | 15% | Proper use of learned techniques |
        | Presentation | 10% | Clear demo, good architectural explanation |

        ## Timeline

        | Day | Milestone |
        |-----|-----------|
        | Day 13 | Project design document due (block diagram + module list) |
        | Day 15 | Build day — working prototype or demonstrable progress |
        | Day 16 | Final demo and presentation |
    """)


# =============================================================================
# GITIGNORE
# =============================================================================

def build_gitignore():
    write_file(".gitignore", """\
        # Build artifacts
        *.json
        *.asc
        *.bin
        *.vvp
        *.vcd
        *.log
        *.blif

        # Editor files
        *.swp
        *~
        .vscode/
        .idea/

        # OS files
        .DS_Store
        Thumbs.db

        # Python
        __pycache__/
        *.pyc
    """)


# =============================================================================
# MAIN
# =============================================================================

def main():
    print("=" * 60)
    print("  HDL Course Repository Builder")
    print("=" * 60)

    build_labs()
    build_shared_lib()
    build_projects()
    build_gitignore()

    print("\n" + "=" * 60)
    print("  Build complete!")
    print("=" * 60)


if __name__ == "__main__":
    main()
