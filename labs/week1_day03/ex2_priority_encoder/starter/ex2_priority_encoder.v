// =============================================================================
// Exercise 2: Priority Encoder
// Day 3 · Procedural Combinational Logic
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// 4-input priority encoder
// Priority: bit 3 (highest) → bit 0 (lowest)
// =============================================================================

module priority_encoder (
    input  wire [3:0] i_request,
    output reg  [1:0] o_encoded,
    output reg        o_valid
);

    // Part A: Implement using if/else
    always @(*) begin
        // Default assignments — prevent latches
        o_encoded = 2'b00;
        o_valid   = 1'b0;

        // TODO: Use if/else chain
        // Check i_request[3] first (highest priority)
        // Set o_encoded to the bit position, o_valid to 1
        //
        // if (i_request[3]) begin
        //     ...
        // end else if (i_request[2]) begin
        //     ...
        // end ...

    end

endmodule

// Part B: Alternative implementation using casez (uncomment to test)
//
// module priority_encoder_casez (
//     input  wire [3:0] i_request,
//     output reg  [1:0] o_encoded,
//     output reg        o_valid
// );
//
//     always @(*) begin
//         o_encoded = 2'b00;
//         o_valid   = 1'b0;
//
//         casez (i_request)
//             4'b1???: begin o_encoded = 2'd3; o_valid = 1'b1; end
//             4'b01??: begin o_encoded = 2'd2; o_valid = 1'b1; end
//             4'b001?: begin o_encoded = 2'd1; o_valid = 1'b1; end
//             4'b0001: begin o_encoded = 2'd0; o_valid = 1'b1; end
//             default: begin o_encoded = 2'd0; o_valid = 1'b0; end
//         endcase
//     end
//
// endmodule
