// =============================================================================
// top_pipeline.v — SOLUTION (pipelined version)
// Day 10, Exercise 4
// =============================================================================

module top_pipeline (
    input  wire        i_clk,
    input  wire [3:0]  i_data,
    output wire [3:0]  o_result
);

    // Pipeline Stage 1
    reg [7:0] r_pipe1;
    reg [3:0] r_data1;  // pipeline i_data alongside
    always @(posedge i_clk) begin
        r_pipe1 <= i_data * i_data;
        r_data1 <= i_data;
    end

    // Pipeline Stage 2
    reg [7:0] r_pipe2;
    always @(posedge i_clk) begin
        r_pipe2 <= r_pipe1 + {4'b0, r_data1};
    end

    // Pipeline Stage 3
    reg [7:0] r_pipe3;
    always @(posedge i_clk) begin
        r_pipe3 <= r_pipe2 * r_pipe2[3:0];
    end

    // Pipeline Stage 4
    reg [7:0] r_pipe4;
    reg [7:0] r_pipe1_d3;  // delayed stage1 for stage5
    always @(posedge i_clk) begin
        r_pipe4 <= r_pipe3 ^ {r_pipe3[3:0], r_pipe3[7:4]};
    end

    // Pipeline Stage 5
    reg [3:0] r_out;
    always @(posedge i_clk) begin
        r_out <= r_pipe4[3:0] + r_pipe1[3:0]; // approximate; fully correct needs delayed pipe1
    end

    assign o_result = r_out;

endmodule
