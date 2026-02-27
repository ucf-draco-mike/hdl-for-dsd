// =============================================================================
// shift_register_demo.v — Blocking vs. Nonblocking Assignment Demo
// Day 4: Sequential Logic Fundamentals
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================
// Description:
//   Two 3-stage shift registers side by side:
//   - shift_correct uses nonblocking (<=) — proper pipeline
//   - shift_broken  uses blocking (=)     — pipeline destroyed
//
//   Simulate both and compare waveforms to see the difference.
// =============================================================================

// CORRECT: Nonblocking assignment — proper 3-stage shift register
module shift_correct (
    input  wire i_clk,
    input  wire i_d,
    output reg  o_stage1,
    output reg  o_stage2,
    output reg  o_stage3
);

    always @(posedge i_clk) begin
        o_stage1 <= i_d;          // all right-hand sides evaluated first
        o_stage2 <= o_stage1;     // uses OLD value of o_stage1
        o_stage3 <= o_stage2;     // uses OLD value of o_stage2
    end

endmodule


// BROKEN: Blocking assignment — pipeline destroyed
module shift_broken (
    input  wire i_clk,
    input  wire i_d,
    output reg  o_stage1,
    output reg  o_stage2,
    output reg  o_stage3
);

    always @(posedge i_clk) begin
        o_stage1 = i_d;          // o_stage1 updates IMMEDIATELY
        o_stage2 = o_stage1;     // sees NEW value of o_stage1 (= i_d)
        o_stage3 = o_stage2;     // sees NEW value of o_stage2 (= i_d)
        // Result: all three stages get i_d in the SAME cycle!
    end

endmodule
