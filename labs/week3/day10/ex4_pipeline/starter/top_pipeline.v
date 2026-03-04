// =============================================================================
// top_pipeline.v — Pipeline Timing Fix
// Day 10, Exercise 4
// =============================================================================
// A deliberately deep combinational chain. Add pipeline registers to
// break the critical path and improve Fmax.

module top_pipeline (
    input  wire        i_clk,
    input  wire [3:0]  i_data,   // from switches
    output wire [3:0]  o_result  // to LEDs
);

    // UNPIPELINED VERSION — long combinational chain
    wire [7:0] stage1 = i_data * i_data;          // 4×4 multiply
    wire [7:0] stage2 = stage1 + {4'b0, i_data};
    wire [7:0] stage3 = stage2 * stage2[3:0];     // another multiply
    wire [7:0] stage4 = stage3 ^ {stage3[3:0], stage3[7:4]};
    wire [7:0] stage5 = stage4 + stage1;

    reg [3:0] r_out;
    always @(posedge i_clk)
        r_out <= stage5[3:0];

    assign o_result = r_out;

    // TODO: Create a PIPELINED version of the above.
    //   Insert pipeline registers between stages to break
    //   the critical path. Compare Fmax before and after.
    //
    // Approach:
    //   reg [7:0] r_pipe1;  // after stage1
    //   reg [7:0] r_pipe2;  // after stage2
    //   ... etc
    //
    //   always @(posedge i_clk) begin
    //       r_pipe1 <= i_data * i_data;
    //       r_pipe2 <= r_pipe1 + {4'b0, ???};  // note: need pipelined i_data too!
    //       ...
    //   end
    //
    // IMPORTANT: If stage2 uses i_data, you need to pipeline i_data
    //            alongside stage1 to maintain correct behavior.

endmodule
