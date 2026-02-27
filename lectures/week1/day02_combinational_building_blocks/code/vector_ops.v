// =============================================================================
// vector_ops.v — Vector Operations Examples
// Day 2: Combinational Building Blocks
// Accelerated HDL for Digital System Design · UCF ECE
// =============================================================================

module vector_ops (
    input  wire [7:0] i_data,
    input  wire [3:0] i_nibble_a,
    input  wire [3:0] i_nibble_b,
    output wire [7:0] o_concat,
    output wire [7:0] o_replicate,
    output wire [7:0] o_sign_ext,
    output wire [3:0] o_upper,
    output wire [3:0] o_lower,
    output wire       o_msb
);

    // Bit selection
    assign o_msb   = i_data[7];        // single bit — the MSB
    assign o_upper = i_data[7:4];      // upper nibble
    assign o_lower = i_data[3:0];      // lower nibble

    // Concatenation: join two 4-bit values into one 8-bit value
    assign o_concat = {i_nibble_a, i_nibble_b};

    // Replication: 8 copies of bit 0
    assign o_replicate = {8{i_data[0]}};

    // Sign extension: extend 4-bit signed value to 8 bits
    assign o_sign_ext = {{4{i_nibble_a[3]}}, i_nibble_a};

endmodule
