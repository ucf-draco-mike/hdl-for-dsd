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
