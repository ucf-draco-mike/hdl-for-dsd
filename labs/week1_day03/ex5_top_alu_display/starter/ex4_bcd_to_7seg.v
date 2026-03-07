// =============================================================================
// Exercise 4: BCD-to-7-Segment Decoder
// Day 3 · Procedural Combinational Logic
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Only valid for inputs 0–9. Inputs 10–15 display 'E' for error.
// Uses case statement — compare with Day 2's nested conditional approach.
// =============================================================================

module bcd_to_7seg (
    input  wire [3:0] i_bcd,
    output reg  [6:0] o_seg,
    output reg        o_valid
);

    always @(*) begin
        o_valid = 1'b1;
        o_seg   = 7'b1111111;  // default: all off

        case (i_bcd)
            4'd0:    o_seg = 7'b0000001;
            4'd1:    o_seg = 7'b1001111;
            4'd2:    o_seg = 7'b0010010;
            4'd3:    o_seg = 7'b0000110;
            4'd4:    o_seg = 7'b1001100;
            4'd5:    o_seg = 7'b0100100;
            4'd6:    o_seg = 7'b0100000;
            4'd7:    o_seg = 7'b0001111;
            4'd8:    o_seg = 7'b0000000;
            4'd9:    o_seg = 7'b0000100;
            default: begin
                o_seg   = 7'b0110000;  // 'E' for error
                o_valid = 1'b0;
            end
        endcase
    end

endmodule
