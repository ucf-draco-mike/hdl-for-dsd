// =============================================================================
// Exercise 1 SOLUTION: Latch Hunting (Fixed)
// Day 3 · Procedural Combinational Logic
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

    // Bug 1 FIX: Added else clause
    always @(*) begin
        if (i_enable)
            o_result = i_a + i_b;
        else
            o_result = 4'b0000;
    end

    // Bug 2 FIX: Added default case
    always @(*) begin
        case (i_sel)
            2'b00:   o_flag = 1'b0;
            2'b01:   o_flag = 1'b1;
            2'b10:   o_flag = 1'b0;
            default: o_flag = 1'b0;
        endcase
    end

    // Bug 3: NO LATCH — default assignment at top covers all bits
    always @(*) begin
        o_encoded = 3'b000;
        case (i_sel)
            2'b00: o_encoded = 3'b001;
            2'b01: o_encoded[2] = 1'b1;  // [1:0] keep default 00
            2'b10: o_encoded = 3'b100;
            default: o_encoded = 3'b000;
        endcase
    end

endmodule
