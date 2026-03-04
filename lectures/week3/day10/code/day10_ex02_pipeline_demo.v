// =============================================================================
// day10_ex02_pipeline_demo.v — Intentional Timing Violation + Pipeline Fix
// Day 10: Timing, Clocking & Constraints
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Two versions: slow_adder (long critical path) and pipelined_adder (fixed).
// Synthesize both and compare nextpnr timing reports.
// =============================================================================
// Synth:  yosys -p "read_verilog day10_ex02_pipeline_demo.v; synth_ice40 -top slow_adder"
//         yosys -p "read_verilog day10_ex02_pipeline_demo.v; synth_ice40 -top pipelined_adder"
// =============================================================================

// ---- Intentionally slow: 3 chained additions ----
module slow_adder (
    input  wire        i_clk,
    input  wire [15:0] i_a, i_b, i_c, i_d,
    output reg  [15:0] o_result
);
    // All additions in one combinational path
    wire [15:0] w_sum1 = i_a + i_b;
    wire [15:0] w_sum2 = w_sum1 + i_c;
    wire [15:0] w_sum3 = w_sum2 + i_d;

    always @(posedge i_clk)
        o_result <= w_sum3;
endmodule

// ---- Fixed: pipelined (2 stages) ----
module pipelined_adder (
    input  wire        i_clk,
    input  wire [15:0] i_a, i_b, i_c, i_d,
    output reg  [15:0] o_result
);
    reg [15:0] r_sum1, r_sum2;

    // Pipeline stage 1: two parallel additions
    always @(posedge i_clk) begin
        r_sum1 <= i_a + i_b;
        r_sum2 <= i_c + i_d;
    end

    // Pipeline stage 2: combine partial sums
    always @(posedge i_clk)
        o_result <= r_sum1 + r_sum2;
endmodule
