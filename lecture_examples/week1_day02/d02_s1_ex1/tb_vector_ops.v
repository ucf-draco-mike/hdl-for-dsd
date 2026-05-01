// =============================================================================
// tb_vector_ops.v -- Self-checking testbench for vector_ops
//
// Note: replicate uses i_data[0]; concat/sign_ext use nibble inputs.
// We exercise two stimulus sets so every output is observed both ways.
// =============================================================================
`timescale 1ns/1ps

module tb_vector_ops;
    reg  [7:0] data;
    reg  [3:0] nibble_a, nibble_b;
    wire [7:0] concat, replicate, sign_ext;
    wire [3:0] upper, lower;
    wire       msb;

    vector_ops dut (
        .i_data       (data),
        .i_nibble_a   (nibble_a),
        .i_nibble_b   (nibble_b),
        .o_concat     (concat),
        .o_replicate  (replicate),
        .o_sign_ext   (sign_ext),
        .o_upper      (upper),
        .o_lower      (lower),
        .o_msb        (msb)
    );

    integer fails = 0;
    task expect_eq8(input [7:0] exp, input [7:0] act, input [255:0] name);
        if (act !== exp) begin
            $display("FAIL: %0s -- expected 8'h%02h, got 8'h%02h", name, exp, act);
            fails = fails + 1;
        end else
            $display("PASS: %0s = 8'h%02h", name, act);
    endtask
    task expect_eq4(input [3:0] exp, input [3:0] act, input [255:0] name);
        if (act !== exp) begin
            $display("FAIL: %0s -- expected 4'h%01h, got 4'h%01h", name, exp, act);
            fails = fails + 1;
        end else
            $display("PASS: %0s = 4'h%01h", name, act);
    endtask

    initial begin
        $dumpfile("tb_vector_ops.vcd");
        $dumpvars(0, tb_vector_ops);

        // Stimulus 1: matches slide's nibble values (D, 2) and data nibbles
        data     = 8'hD2;
        nibble_a = 4'b1101;     // D
        nibble_b = 4'b0010;     // 2
        #10;
        expect_eq8(8'hD2, concat,   "concat    {D,2}");
        expect_eq8(8'hFD, sign_ext, "sign_ext  D->FD");
        expect_eq4(4'hD,  upper,    "upper     ");
        expect_eq4(4'h2,  lower,    "lower     ");

        // Stimulus 2: data[0]=1 to observe replicate=8'hFF
        data     = 8'h01;
        #10;
        expect_eq8(8'hFF, replicate, "replicate data[0]=1");

        // Stimulus 3: data[0]=0 to observe replicate=8'h00
        data     = 8'h00;
        #10;
        expect_eq8(8'h00, replicate, "replicate data[0]=0");

        if (fails == 0) $display("=== %0d passed, 0 failed ===", 6);
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
