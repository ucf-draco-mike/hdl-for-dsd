// =============================================================================
// Exercise 2 SOLUTION: Priority Encoder
// Day 3 · Procedural Combinational Logic
// =============================================================================

module priority_encoder (
    input  wire [3:0] i_request,
    output reg  [1:0] o_encoded,
    output reg        o_valid
);

    always @(*) begin
        o_encoded = 2'b00;
        o_valid   = 1'b0;

        if (i_request[3]) begin
            o_encoded = 2'd3;
            o_valid   = 1'b1;
        end else if (i_request[2]) begin
            o_encoded = 2'd2;
            o_valid   = 1'b1;
        end else if (i_request[1]) begin
            o_encoded = 2'd1;
            o_valid   = 1'b1;
        end else if (i_request[0]) begin
            o_encoded = 2'd0;
            o_valid   = 1'b1;
        end
    end

endmodule
