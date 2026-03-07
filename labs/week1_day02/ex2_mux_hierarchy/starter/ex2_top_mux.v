// =============================================================================
// Exercise 2, Part C: Top Module for Mux on Go Board
// Day 2 · Combinational Building Blocks
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================

module top_mux (
    input  wire i_switch1,   // sel[1]
    input  wire i_switch2,   // sel[0]
    input  wire i_switch3,   // data input (active-high)
    input  wire i_switch4,   // data input (active-high)
    output wire o_led1       // mux output
);

    // Invert switches at boundary
    wire [1:0] w_sel = {i_switch1, i_switch2};

    // Hardcode two data inputs, use sw3/sw4 for the other two
    wire w_d0 = 1'b0;          // fixed low
    wire w_d1 = i_switch3;    // from button 3
    wire w_d2 = i_switch4;    // from button 4
    wire w_d3 = 1'b1;          // fixed high

    wire w_result;

    // TODO: Instantiate mux4to1 here
    // mux4to1 mux (
    //     .i_d0(w_d0), .i_d1(w_d1), .i_d2(w_d2), .i_d3(w_d3),
    //     .i_sel(w_sel),
    //     .o_y(w_result)
    // );

    assign o_led1 = w_result;  // active-high output

endmodule
