// =============================================================================
// tb_pipelined_adder.v -- self-checking testbench for the pipelined adder.
// =============================================================================
`timescale 1ns/1ps
`default_nettype none

`ifndef PIPE
  `define PIPE 0
`endif
`ifndef W
  `define W 32
`endif

module tb_pipelined_adder;

    localparam integer W      = `W;
    localparam integer PIPE   = `PIPE;
    localparam integer LAT    = (PIPE == 0) ? 0 : PIPE + 1;
    localparam integer NTESTS = 64;
    localparam integer LATP1  = (LAT == 0) ? 1 : LAT + 1;

    reg              clk;
    reg              rst;
    reg  [W-1:0]     a;
    reg  [W-1:0]     b;
    wire [W:0]       sum;

    // Reference shift register so we can compare the DUT's output against the
    // input pair from LAT cycles earlier.
    reg [W-1:0] a_ref [0:LATP1-1];
    reg [W-1:0] b_ref [0:LATP1-1];

    integer i;
    integer j;
    integer errors;

    pipelined_adder #(.W(W), .PIPE(PIPE)) dut (
        .clk   (clk),
        .rst   (rst),
        .i_a   (a),
        .i_b   (b),
        .o_sum (sum)
    );

    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_pipelined_adder.vcd");
        $dumpvars(0, tb_pipelined_adder);

        errors = 0;
        rst    = 1'b1;
        a      = {W{1'b0}};
        b      = {W{1'b0}};

        for (j = 0; j < LATP1; j = j + 1) begin
            a_ref[j] = {W{1'b0}};
            b_ref[j] = {W{1'b0}};
        end

        repeat (4) @(posedge clk);
        rst = 1'b0;

        for (i = 0; i < NTESTS; i = i + 1) begin
            a = $random;
            b = $random;
            @(posedge clk);

            for (j = LATP1 - 1; j > 0; j = j - 1) begin
                a_ref[j] = a_ref[j-1];
                b_ref[j] = b_ref[j-1];
            end
            a_ref[0] = a;
            b_ref[0] = b;

            if (i >= LAT) begin
                if (sum !== (a_ref[LAT] + b_ref[LAT])) begin
                    $display("[FAIL] cycle %0d: %h + %h => %h (expected %h)",
                             i, a_ref[LAT], b_ref[LAT], sum, a_ref[LAT] + b_ref[LAT]);
                    errors = errors + 1;
                end
            end
        end

        for (i = 0; i < LAT; i = i + 1) begin
            @(posedge clk);
            for (j = LATP1 - 1; j > 0; j = j - 1) begin
                a_ref[j] = a_ref[j-1];
                b_ref[j] = b_ref[j-1];
            end
            a_ref[0] = {W{1'b0}};
            b_ref[0] = {W{1'b0}};
        end

        $display("=== tb_pipelined_adder PIPE=%0d W=%0d : %0d errors over %0d samples ===",
                 PIPE, W, errors, NTESTS);
        if (errors == 0) $display("PASS");
        else             $display("FAIL");

        $finish;
    end

endmodule

`default_nettype wire
