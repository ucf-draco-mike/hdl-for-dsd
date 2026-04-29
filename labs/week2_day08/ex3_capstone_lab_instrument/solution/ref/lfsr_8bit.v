// =============================================================================
// lfsr_8bit.v — 8-bit LFSR (Solution — same as starter, provided complete)
// =============================================================================

module lfsr_8bit (
    input  wire       i_clk,
    input  wire       i_reset,
    input  wire       i_enable,
    output reg  [7:0] o_lfsr,
    output wire       o_valid
);

    wire w_feedback = o_lfsr[7] ^ o_lfsr[5] ^ o_lfsr[4] ^ o_lfsr[3];

    always @(posedge i_clk) begin
        if (i_reset)
            o_lfsr <= 8'h01;
        else if (i_enable)
            o_lfsr <= {o_lfsr[6:0], w_feedback};
    end

    assign o_valid = |o_lfsr;

endmodule
