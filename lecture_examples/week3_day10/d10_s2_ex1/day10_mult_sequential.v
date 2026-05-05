// =============================================================================
// day10_mult_sequential.v — Shift-and-Add Sequential Multiplier
// Day 10: Numerical Architectures & Design Trade-offs
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
// Sequential multiplier: trades latency (W cycles) for area (~6× smaller than
// the equivalent parallel multiplier). Classic "right-shift + conditional-add"
// algorithm.
//
//   yosys -p "read_verilog -DWIDTH=16 day10_mult_sequential.v; \
//             synth_ice40 -top mult_sequential; stat"
//
// Override WIDTH from the Makefile via:  make stat_seq WIDTH=16
//
// Protocol:
//   1. Drive i_a, i_b; assert i_start for one cycle.
//   2. Wait for o_done = 1 (W cycles later).
//   3. Read o_product (latched until next i_start).
// =============================================================================

`ifndef WIDTH
`define WIDTH 16
`endif

module mult_sequential #(
    parameter W = `WIDTH
)(
    input  wire           i_clk,
    input  wire           i_reset,
    input  wire           i_start,
    input  wire [W-1:0]   i_a,
    input  wire [W-1:0]   i_b,
    output reg  [2*W-1:0] o_product,
    output reg            o_done
);

    // Working state
    reg [2*W-1:0]      r_acc;        // running accumulator (2W bits)
    reg [W-1:0]        r_b;          // shifted version of i_b
    reg [$clog2(W):0]  r_count;      // step counter (0..W)
    reg                r_busy;

    always @(posedge i_clk) begin
        if (i_reset) begin
            r_acc     <= {2*W{1'b0}};
            r_b       <= {W{1'b0}};
            r_count   <= {($clog2(W)+1){1'b0}};
            r_busy    <= 1'b0;
            o_done    <= 1'b0;
            o_product <= {2*W{1'b0}};
        end else if (i_start && !r_busy) begin
            // Load operands; first partial sum if LSB(b)==1.
            r_acc   <= i_b[0] ? {{W{1'b0}}, i_a} : {2*W{1'b0}};
            r_b     <= i_b >> 1;
            r_count <= 1;
            r_busy  <= 1'b1;
            o_done  <= 1'b0;
        end else if (r_busy) begin
            if (r_count == W) begin
                o_product <= r_acc;
                o_done    <= 1'b1;
                r_busy    <= 1'b0;
            end else begin
                // Add (a << count) when current bit of b is 1.
                if (r_b[0])
                    r_acc <= r_acc + ({{W{1'b0}}, i_a} << r_count);
                r_b     <= r_b >> 1;
                r_count <= r_count + 1'b1;
            end
        end else begin
            o_done <= 1'b0;
        end
    end

endmodule
