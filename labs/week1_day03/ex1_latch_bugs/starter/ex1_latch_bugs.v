// =============================================================================
// Exercise 1: Latch Hunting
// Day 3 · Procedural Combinational Logic
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// BUGGY CODE — intentional latches for learning!
// Your job: synthesize, read the warnings, find and fix every latch.
//
// Steps:
//   1. Run: make ex1_synth
//   2. Read every Yosys warning — which signals have latches?
//   3. Fix each bug
//   4. Re-synthesize until all latch warnings are gone
// =============================================================================

module latch_bugs (
    input  wire [1:0] i_sel,
    input  wire [3:0] i_a,
    input  wire [3:0] i_b,
    input  wire [3:0] i_c,
    input  wire       i_enable,
    output reg  [3:0] o_result,
    output reg        o_flag,
    output reg  [2:0] o_encoded
);

    // --- Bug 1: Missing else ---
    // What happens to o_result when i_enable is 0?
    always @(*) begin
        if (i_enable)
            o_result = i_a + i_b;
        // TODO: Fix this — what value should o_result have when not enabled?
    end

    // --- Bug 2: Incomplete case ---
    // What happens when i_sel == 2'b11?
    always @(*) begin
        case (i_sel)
            2'b00: o_flag = 1'b0;
            2'b01: o_flag = 1'b1;
            2'b10: o_flag = 1'b0;
            // TODO: Fix — add the missing case or a default
        endcase
    end

    // --- Bug 3 (Trick Question!): Partial assignment in one branch ---
    // Is there a latch here? Explain why or why not.
    always @(*) begin
        o_encoded = 3'b000;          // default assignment at top
        case (i_sel)
            2'b00: o_encoded = 3'b001;
            2'b01: begin
                o_encoded[2] = 1'b1;
                // o_encoded[1:0] not explicitly assigned in this branch
                // But the default at top already assigned them...
            end
            2'b10: o_encoded = 3'b100;
            default: o_encoded = 3'b000;
        endcase
    end

endmodule
