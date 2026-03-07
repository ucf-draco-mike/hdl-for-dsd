// =============================================================================
// tb_priority_encoder.v — Baseline TB for priority_encoder — exhaustive (Day 3, Ex 2)
// Accelerated HDL for Digital System Design · Dr. Mike Borowczak · ECE · CECS · UCF
// =============================================================================
`timescale 1ns/1ps

module tb_priority_encoder;
    reg  [3:0] request;
    wire [1:0] encoded;
    wire       valid;

    priority_encoder dut (
        .i_request(request), .o_encoded(encoded), .o_valid(valid)
    );

    integer pass_count = 0, fail_count = 0;
    reg [1:0] exp_enc;
    reg       exp_valid;
    integer i;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_priority_encoder);

        for (i = 0; i < 16; i = i + 1) begin
            request = i[3:0];
            #1;

            // Compute expected: highest set bit wins
            if (request[3])      begin exp_enc = 2'd3; exp_valid = 1; end
            else if (request[2]) begin exp_enc = 2'd2; exp_valid = 1; end
            else if (request[1]) begin exp_enc = 2'd1; exp_valid = 1; end
            else if (request[0]) begin exp_enc = 2'd0; exp_valid = 1; end
            else                 begin exp_enc = 2'd0; exp_valid = 0; end

            if (encoded === exp_enc && valid === exp_valid) begin
                $display("PASS: req=%4b -> enc=%0d valid=%b", request, encoded, valid);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: req=%4b -> enc=%0d valid=%b (expected enc=%0d valid=%b)",
                         request, encoded, valid, exp_enc, exp_valid);
                fail_count = fail_count + 1;
            end
        end

        $display("\n=== tb_priority_encoder: %0d passed, %0d failed ===", pass_count, fail_count);
        if (fail_count > 0) $display("SOME TESTS FAILED");
        else $display("ALL TESTS PASSED");
        $finish;
    end
endmodule
