// =============================================================================
// top_with_three_counters.v — Parameterized Counter, Three Sizes
// Day 8: Hierarchy, Parameters & Generate
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Live demo for d08_s2 "One Module, Three Instances, Three Sizes":
// instantiates the counter module from day08_ex02_counter.v at WIDTH=4,
// 8, and 16 from one source. Each instance synthesizes to its own
// independently sized hardware (4 / 8 / 16 DFFs + matching carry chain).
// =============================================================================

module top (
    input  wire        i_clk,
    input  wire        i_reset,
    input  wire        i_enable,
    output wire [3:0]  o_cnt_4bit,
    output wire [7:0]  o_cnt_8bit,
    output wire [15:0] o_cnt_16bit,
    output wire        o_rollover_4,
    output wire        o_rollover_8,
    output wire        o_rollover_16
);

    counter #(.WIDTH(4)) u_cnt_4bit (
        .i_clk     (i_clk),
        .i_reset   (i_reset),
        .i_enable  (i_enable),
        .o_count   (o_cnt_4bit),
        .o_rollover(o_rollover_4)
    );

    counter #(.WIDTH(8)) u_cnt_8bit (
        .i_clk     (i_clk),
        .i_reset   (i_reset),
        .i_enable  (i_enable),
        .o_count   (o_cnt_8bit),
        .o_rollover(o_rollover_8)
    );

    counter #(.WIDTH(16)) u_cnt_16b (
        .i_clk     (i_clk),
        .i_reset   (i_reset),
        .i_enable  (i_enable),
        .o_count   (o_cnt_16bit),
        .o_rollover(o_rollover_16)
    );

endmodule
