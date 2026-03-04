// =============================================================================
// tb_hex_file.v — File-Driven Hex-to-7seg Testbench (Starter)
// Day 6, Exercise 4 (Stretch)
// =============================================================================
// Uses $readmemh to load test vectors from hex_vectors.hex

`timescale 1ns / 1ps

module tb_hex_file;

    reg  [3:0] hex_in;
    wire [6:0] seg_out;

    hex_to_7seg uut (
        .i_hex(hex_in),
        .o_seg(seg_out)
    );

    // ---- TODO: Storage for test vectors ----
    // reg [10:0] vectors [0:15];  // 11 bits: {4-bit input, 7-bit expected}
    // integer i;
    // integer test_count = 0, fail_count = 0;

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, tb_hex_file);

        $display("=== File-Driven Hex-to-7seg Testbench ===");

        // ---- TODO: Load vectors from file ----
        // $readmemh("hex_vectors.hex", vectors);

        // ---- TODO: Loop through all 16 vectors ----
        // for (i = 0; i < 16; i = i + 1) begin
        //     hex_in = vectors[i][10:7];           // upper 4 bits = input
        //     #10;
        //     test_count = test_count + 1;
        //     if (seg_out !== vectors[i][6:0]) begin
        //         fail_count = fail_count + 1;
        //         $display("FAIL: hex=%h expected seg=%07b got=%07b",
        //                  hex_in, vectors[i][6:0], seg_out);
        //     end else
        //         $display("PASS: hex=%h seg=%07b", hex_in, seg_out);
        // end

        // ---- TODO: Print summary ----

        $finish;
    end

endmodule
