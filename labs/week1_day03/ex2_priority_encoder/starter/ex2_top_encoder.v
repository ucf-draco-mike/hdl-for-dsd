// =============================================================================
// Exercise 2: Top Module — Priority Encoder on Go Board
// Day 3 · Procedural Combinational Logic
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================

module top_encoder (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,      // encoded[1]
    output wire o_led2,      // encoded[0]
    output wire o_led3,      // valid
    output wire o_led4       // unused
);

    wire [3:0] w_req = {i_switch1, i_switch2, i_switch3, i_switch4};
    wire [1:0] w_enc;
    wire       w_valid;

    priority_encoder enc (
        .i_request(w_req),
        .o_encoded(w_enc),
        .o_valid(w_valid)
    );

    assign o_led1 = w_enc[1];
    assign o_led2 = w_enc[0];
    assign o_led3 = w_valid;
    assign o_led4 = 1'b0;       // off

endmodule
