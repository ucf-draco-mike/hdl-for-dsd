// =============================================================================
// adder_comparison.v — SOLUTION
// Day 10, Exercise 1
// =============================================================================

module full_adder (
    input  wire i_a, i_b, i_cin,
    output wire o_sum, o_cout
);
    assign o_sum  = i_a ^ i_b ^ i_cin;
    assign o_cout = (i_a & i_b) | (i_b & i_cin) | (i_a & i_cin);
endmodule

// ---- Ripple-carry adder, 8-bit ----
module ripple_carry_8 (
    input  wire [7:0] i_a, i_b,
    input  wire       i_cin,
    output wire [7:0] o_sum,
    output wire       o_cout
);
    wire [8:0] carry;
    assign carry[0] = i_cin;

    genvar g;
    generate
        for (g = 0; g < 8; g = g + 1) begin : gen_fa
            full_adder fa (
                .i_a(i_a[g]), .i_b(i_b[g]), .i_cin(carry[g]),
                .o_sum(o_sum[g]), .o_cout(carry[g+1])
            );
        end
    endgenerate

    assign o_cout = carry[8];
endmodule

// ---- Ripple-carry adder, 16-bit ----
module ripple_carry_16 (
    input  wire [15:0] i_a, i_b,
    input  wire        i_cin,
    output wire [15:0] o_sum,
    output wire        o_cout
);
    wire [16:0] carry;
    assign carry[0] = i_cin;

    genvar g;
    generate
        for (g = 0; g < 16; g = g + 1) begin : gen_fa
            full_adder fa (
                .i_a(i_a[g]), .i_b(i_b[g]), .i_cin(carry[g]),
                .o_sum(o_sum[g]), .o_cout(carry[g+1])
            );
        end
    endgenerate

    assign o_cout = carry[16];
endmodule

// ---- Behavioral adder, 8-bit ----
module behavioral_8 (
    input  wire [7:0] i_a, i_b,
    input  wire       i_cin,
    output wire [8:0] o_sum
);
    assign o_sum = i_a + i_b + i_cin;
endmodule

// ---- Behavioral adder, 16-bit ----
module behavioral_16 (
    input  wire [15:0] i_a, i_b,
    input  wire        i_cin,
    output wire [16:0] o_sum
);
    assign o_sum = i_a + i_b + i_cin;
endmodule
