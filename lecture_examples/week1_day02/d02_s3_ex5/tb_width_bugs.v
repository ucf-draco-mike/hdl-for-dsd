// =============================================================================
// tb_width_bugs.v -- Width-Mismatch Live Demo Testbench
// =============================================================================
//   Slide: d02_s3 "Width Mismatch — Compiler & Synthesis Warnings" Live Demo
//
//   Companion to width_bugs.v. Drives stimulus chosen so each bug shows up
//   as a silent wrong answer at runtime — the exact failure mode the slide
//   warns about ("your simulation passes... your waveform will lie").
//
//   The four bugs map 1:1 to slide bullets:
//     Bug 1  sum_truncated  a + b + 1 with bare `1` (32-bit literal)
//     Bug 2  sum_overflow   5-bit add stuffed into 4-bit reg
//     Bug 3  widened        4-bit input implicitly zero-padded to 8 bits
//     Bug 4  narrowed       8-bit input truncated to 4 bits
//
//   Pair this output with `make lint` so students see the warning AND the
//   wrong answer for the same line of code.
// =============================================================================
`timescale 1ns/1ps

module tb_width_bugs;
    reg  [3:0] a, b;
    reg  [7:0] big;
    wire [3:0] sum_truncated, sum_overflow, narrowed;
    wire [7:0] widened;

    width_bugs dut (
        .a            (a),
        .b            (b),
        .big          (big),
        .sum_truncated(sum_truncated),
        .sum_overflow (sum_overflow),
        .widened      (widened),
        .narrowed     (narrowed)
    );

    initial begin
        $dumpfile("width_bugs.vcd");
        $dumpvars(0, tb_width_bugs);

        $display("");
        $display("=== d02_s3 width_bugs runtime demo ===");
        $display("Bug                              | inputs        | expected | got");
        $display("---------------------------------+---------------+----------+--------");

        // Bug 1: a + b + 1 with bare `1` — 32-bit add silently truncated to 4 bits.
        a = 4'd15; b = 4'd0; big = 8'd0; #1;
        $display("1 trunc  sum_truncated=a+b+1     | a=15 b=0      | 16       | %0d", sum_truncated);

        // Bug 2: {1'b0,a}+{1'b0,b} is 5-bit, assigned to 4-bit reg.
        a = 4'd9;  b = 4'd9; #1;
        $display("2 wrap   sum_overflow={0,a}+{0,b}| a=9  b=9      | 18       | %0d", sum_overflow);

        // Bug 3: 4-bit a assigned to 8-bit reg — upper nibble silently zero-padded.
        a = 4'b1010; #1;
        $display("3 pad    widened=a               | a=4'b1010     | explicit | 8'b%b (upper nibble auto-zero)", widened);

        // Bug 4: 8-bit big truncated to 4-bit reg.
        big = 8'hAB; #1;
        $display("4 narrow narrowed=big            | big=8'hAB     | 8'hAB    | 4'h%h (upper nibble lost)", narrowed);

        $display("");
        $display("Every 'got' above is what synthesis will build. -Wall warned you.");
        $display("");
        $finish;
    end
endmodule
