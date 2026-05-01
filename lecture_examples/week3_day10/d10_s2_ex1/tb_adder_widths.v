// =============================================================================
// tb_adder_widths.v -- Smoke testbench for the four-width adders
// =============================================================================
`timescale 1ns/1ps

module tb_adder_widths;
    reg  [3:0]  a4,  b4;   wire [4:0]  s4;
    reg  [7:0]  a8,  b8;   wire [8:0]  s8;
    reg  [15:0] a16, b16;  wire [16:0] s16;
    reg  [31:0] a32, b32;  wire [32:0] s32;

    adder_4bit  d4  (.i_a(a4),  .i_b(b4),  .o_sum(s4));
    adder_8bit  d8  (.i_a(a8),  .i_b(b8),  .o_sum(s8));
    adder_16bit d16 (.i_a(a16), .i_b(b16), .o_sum(s16));
    adder_32bit d32 (.i_a(a32), .i_b(b32), .o_sum(s32));

    integer fails = 0;
    task check5(input [4:0]  exp, input [4:0]  act, input [255:0] name);
        if (act !== exp) begin $display("FAIL: %0s -- exp %h got %h", name, exp, act); fails = fails + 1; end
        else                  $display("PASS: %0s = %h", name, act);
    endtask
    task check9(input [8:0]  exp, input [8:0]  act, input [255:0] name);
        if (act !== exp) begin $display("FAIL: %0s -- exp %h got %h", name, exp, act); fails = fails + 1; end
        else                  $display("PASS: %0s = %h", name, act);
    endtask
    task check17(input [16:0] exp, input [16:0] act, input [255:0] name);
        if (act !== exp) begin $display("FAIL: %0s -- exp %h got %h", name, exp, act); fails = fails + 1; end
        else                  $display("PASS: %0s = %h", name, act);
    endtask
    task check33(input [32:0] exp, input [32:0] act, input [255:0] name);
        if (act !== exp) begin $display("FAIL: %0s -- exp %h got %h", name, exp, act); fails = fails + 1; end
        else                  $display("PASS: %0s = %h", name, act);
    endtask

    initial begin
        $dumpfile("tb_adder_widths.vcd");
        $dumpvars(0, tb_adder_widths);

        a4=4'hF;  b4=4'h1;          #1; check5 (5'h10,        s4,  "4b: F+1 -> 10");
        a8=8'hFF; b8=8'h01;         #1; check9 (9'h100,       s8,  "8b: FF+1 -> 100");
        a16=16'hFFFF; b16=16'h0001; #1; check17(17'h10000,    s16, "16b: FFFF+1");
        a32=32'hFFFFFFFF; b32=32'h1;#1; check33(33'h100000000, s32, "32b: FFFFFFFF+1");

        if (fails == 0) $display("=== 4 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
