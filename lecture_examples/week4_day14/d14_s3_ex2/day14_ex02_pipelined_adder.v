// =============================================================================
// day14_ex02_pipelined_adder.v -- 32-bit Pipelined Adder for PPA Sweep
// Day 14: Verification, AI-Driven Testing & PPA Analysis
// Accelerated HDL for Digital System Design - Dr. Mike Borowczak - ECE - CECS - UCF
// =============================================================================
// Demonstrates the canonical PPA tradeoff: cutting the carry chain with
// pipeline registers trades latency and area for higher Fmax.
//
// PIPE = 0  -> pure combinational add (longest carry chain, slowest Fmax)
// PIPE = N  -> split the W-bit add into N+1 chunks; insert N register stages
//              between chunks. Latency = N+1 cycles. Fmax improves until the
//              chunk size approaches the per-LUT delay floor.
//
// Build (synthesis sweep):
//   for p in 0 1 2 4; do make all PIPE=$p; done
//   python scripts/plot_ppa.py logs/report_pipe*.txt
// =============================================================================

`default_nettype none

module pipelined_adder #(
    parameter integer W    = 32,
    parameter integer PIPE = 0
) (
    input  wire           clk,
    input  wire           rst,
    input  wire [W-1:0]   i_a,
    input  wire [W-1:0]   i_b,
    output wire [W:0]     o_sum
);

    generate
        if (PIPE == 0) begin : g_comb
            // Pure combinational adder - reference point for the sweep.
            assign o_sum = i_a + i_b;
        end else begin : g_pipe
            // Split the W-bit operands into N = PIPE+1 chunks of CW bits.
            // At stage k (0..N-1) we register the running partial sum after
            // combining chunks 0..k. Chunk k of each operand is delayed k
            // cycles via a shift register so it arrives in lockstep with the
            // partial sum it must be added into.
            localparam integer N  = PIPE + 1;
            localparam integer CW = (W + N - 1) / N;
            localparam integer WP = CW * N;

            wire [WP-1:0] a_pad = {{(WP-W){1'b0}}, i_a};
            wire [WP-1:0] b_pad = {{(WP-W){1'b0}}, i_b};

            // a_dly[k][s] = chunk k of a, delayed s cycles
            reg [CW-1:0] a_dly [0:N-1][0:N-1];
            reg [CW-1:0] b_dly [0:N-1][0:N-1];

            // ps[s] = registered partial sum after stage s (chunks 0..s combined)
            reg [W:0]    ps    [0:N-1];

            integer k, s;
            always @(posedge clk) begin
                if (rst) begin
                    for (k = 0; k < N; k = k + 1) begin
                        for (s = 0; s < N; s = s + 1) begin
                            a_dly[k][s] <= {CW{1'b0}};
                            b_dly[k][s] <= {CW{1'b0}};
                        end
                        ps[k] <= {(W+1){1'b0}};
                    end
                end else begin
                    // Latch each chunk at delay-0
                    for (k = 0; k < N; k = k + 1) begin
                        a_dly[k][0] <= a_pad[k*CW +: CW];
                        b_dly[k][0] <= b_pad[k*CW +: CW];
                    end
                    // Shift each delay line forward
                    for (k = 0; k < N; k = k + 1) begin
                        for (s = 1; s < N; s = s + 1) begin
                            a_dly[k][s] <= a_dly[k][s-1];
                            b_dly[k][s] <= b_dly[k][s-1];
                        end
                    end

                    // Stage 0: combine chunk 0 only. RHS reads a_dly[0][0]'s
                    // pre-edge value, which holds the chunk-0 input from one
                    // cycle ago. ps[0] therefore reflects an input one cycle
                    // older than the live i_a/i_b.
                    ps[0] <= {{(W+1-CW){1'b0}}, a_dly[0][0]} +
                             {{(W+1-CW){1'b0}}, b_dly[0][0]};

                    // Stage s>=1: add chunk s (delayed s cycles) into ps[s-1].
                    // ps[s-1] reflects input from cycle T-s; chunk s must be
                    // delayed by s cycles too. Reading a_dly[s][s] pre-edge
                    // gives chunk s from cycle T-s, keeping every operand on
                    // the same cycle of input.
                    for (s = 1; s < N; s = s + 1) begin
                        ps[s] <= ps[s-1] +
                                 ({{(W+1-CW){1'b0}}, a_dly[s][s]} << (s*CW)) +
                                 ({{(W+1-CW){1'b0}}, b_dly[s][s]} << (s*CW));
                    end
                end
            end

            assign o_sum = ps[N-1];
        end
    endgenerate

endmodule

`default_nettype wire
