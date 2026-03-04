// =============================================================================
// Exercise 3 SOLUTION: Top Module — ALU on Go Board
// Day 3 · Procedural Combinational Logic
// =============================================================================

module top_alu (
    input  wire i_switch1,
    input  wire i_switch2,
    input  wire i_switch3,
    input  wire i_switch4,
    output wire o_led1,
    output wire o_led2,
    output wire o_led3,
    output wire o_led4,
    output wire o_segment1_a,
    output wire o_segment1_b,
    output wire o_segment1_c,
    output wire o_segment1_d,
    output wire o_segment1_e,
    output wire o_segment1_f,
    output wire o_segment1_g
);

    wire [1:0] w_opcode = ~{i_switch1, i_switch2};
    wire [3:0] w_a = 4'd7;
    wire [3:0] w_b = {2'b00, ~i_switch3, ~i_switch4};
    wire [3:0] w_result;
    wire       w_zero, w_carry;

    alu_4bit alu (
        .i_a(w_a), .i_b(w_b), .i_opcode(w_opcode),
        .o_result(w_result), .o_zero(w_zero), .o_carry(w_carry)
    );

    assign o_led1 = ~w_carry;
    assign o_led2 = ~w_zero;
    assign o_led3 = ~w_result[1];
    assign o_led4 = ~w_result[0];

    // 7-seg display of result (using simple decoder inline)
    reg [6:0] r_seg;
    always @(*) begin
        case (w_result)
            4'h0: r_seg = 7'b0000001;  4'h1: r_seg = 7'b1001111;
            4'h2: r_seg = 7'b0010010;  4'h3: r_seg = 7'b0000110;
            4'h4: r_seg = 7'b1001100;  4'h5: r_seg = 7'b0100100;
            4'h6: r_seg = 7'b0100000;  4'h7: r_seg = 7'b0001111;
            4'h8: r_seg = 7'b0000000;  4'h9: r_seg = 7'b0000100;
            4'hA: r_seg = 7'b0001000;  4'hB: r_seg = 7'b1100000;
            4'hC: r_seg = 7'b0110001;  4'hD: r_seg = 7'b1000010;
            4'hE: r_seg = 7'b0110000;  4'hF: r_seg = 7'b0111000;
            default: r_seg = 7'b1111111;
        endcase
    end

    assign o_segment1_a = r_seg[6];
    assign o_segment1_b = r_seg[5];
    assign o_segment1_c = r_seg[4];
    assign o_segment1_d = r_seg[3];
    assign o_segment1_e = r_seg[2];
    assign o_segment1_f = r_seg[1];
    assign o_segment1_g = r_seg[0];

endmodule
