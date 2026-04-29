// =============================================================================
// lfsr_generic.v — Parameterized LFSR (Solution)
// Day 8, Exercise 4 (Stretch)
// =============================================================================

module lfsr_generic #(
    parameter WIDTH = 8,
    parameter SEED  = 1
)(
    input  wire              i_clk,
    input  wire              i_reset,
    input  wire              i_enable,
    output reg [WIDTH-1:0]   o_lfsr
);

    wire w_feedback;

    generate
        if (WIDTH == 4)
            assign w_feedback = o_lfsr[3] ^ o_lfsr[2];
        else if (WIDTH == 8)
            assign w_feedback = o_lfsr[7] ^ o_lfsr[5] ^ o_lfsr[4] ^ o_lfsr[3];
        else if (WIDTH == 16)
            assign w_feedback = o_lfsr[15] ^ o_lfsr[14] ^ o_lfsr[12] ^ o_lfsr[3];
        else if (WIDTH == 32)
            assign w_feedback = o_lfsr[31] ^ o_lfsr[21] ^ o_lfsr[1] ^ o_lfsr[0];
        else
            assign w_feedback = ^o_lfsr;
    endgenerate

    always @(posedge i_clk) begin
        if (i_reset)
            o_lfsr <= SEED[WIDTH-1:0];
        else if (i_enable)
            o_lfsr <= {o_lfsr[WIDTH-2:0], w_feedback};
    end

endmodule
