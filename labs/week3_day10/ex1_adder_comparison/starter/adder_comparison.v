// =============================================================================
// adder_comparison.v — Adder Architecture Comparison
// Day 10, Exercise 1: Compare ripple-carry vs behavioral adder
// =============================================================================
// TASK: Implement both adder variants, synthesize at 8-bit and 16-bit,
//       and fill in the PPA comparison table in ppa_worksheet.md
//
// Commands:
//   yosys -p "read_verilog adder_comparison.v; synth_ice40 -top ripple_carry_8; stat"
//   yosys -p "read_verilog adder_comparison.v; synth_ice40 -top behavioral_8; stat"
//   (repeat for 16-bit variants)
//
//   For Fmax, add a registered wrapper and use nextpnr:
//   nextpnr-ice40 --hx1k --package vq100 --json adder.json --asc adder.asc --freq 25
// =============================================================================

// ---- Full adder (reuse from Day 2 or implement here) ----
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
    wire [7:0] carry;

    // TODO: Instantiate 8 full_adder modules, chaining carry signals
    // full_adder fa0 (.i_a(i_a[0]), .i_b(i_b[0]), .i_cin(i_cin),    .o_sum(o_sum[0]), .o_cout(carry[0]));
    // full_adder fa1 (.i_a(i_a[1]), .i_b(i_b[1]), .i_cin(carry[0]), .o_sum(o_sum[1]), .o_cout(carry[1]));
    // ... continue for all 8 bits

    // ---- YOUR CODE HERE ----

endmodule

// ---- Ripple-carry adder, 16-bit ----
module ripple_carry_16 (
    input  wire [15:0] i_a, i_b,
    input  wire        i_cin,
    output wire [15:0] o_sum,
    output wire        o_cout
);
    // TODO: Instantiate 16 full_adder modules (or chain two ripple_carry_8)

    // ---- YOUR CODE HERE ----

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
