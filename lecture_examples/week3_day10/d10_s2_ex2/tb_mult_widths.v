// =============================================================================
// tb_mult_widths.v -- Smoke testbench for the three-width multipliers
// =============================================================================
`timescale 1ns/1ps

module tb_mult_widths;
    reg  [3:0]  a4,  b4;   wire [7:0]  p4;
    reg  [7:0]  a8,  b8;   wire [15:0] p8;
    reg  [15:0] a16, b16;  wire [31:0] p16;

    mult_4bit  m4  (.i_a(a4),  .i_b(b4),  .o_product(p4));
    mult_8bit  m8  (.i_a(a8),  .i_b(b8),  .o_product(p8));
    mult_16bit m16 (.i_a(a16), .i_b(b16), .o_product(p16));

    integer fails = 0;
    task check_p4 (input [7:0]  exp, input [7:0]  act, input [255:0] name);
        if (act !== exp) begin $display("FAIL: %0s -- exp %h got %h", name, exp, act); fails = fails + 1; end
        else                  $display("PASS: %0s = %h", name, act);
    endtask
    task check_p8 (input [15:0] exp, input [15:0] act, input [255:0] name);
        if (act !== exp) begin $display("FAIL: %0s -- exp %h got %h", name, exp, act); fails = fails + 1; end
        else                  $display("PASS: %0s = %h", name, act);
    endtask
    task check_p16(input [31:0] exp, input [31:0] act, input [255:0] name);
        if (act !== exp) begin $display("FAIL: %0s -- exp %h got %h", name, exp, act); fails = fails + 1; end
        else                  $display("PASS: %0s = %h", name, act);
    endtask

    initial begin
        $dumpfile("tb_mult_widths.vcd");
        $dumpvars(0, tb_mult_widths);

        a4=4'hF;  b4=4'hF;          #1; check_p4 (8'hE1,         p4,  "4b: F*F = E1");
        a8=8'hFF; b8=8'hFF;         #1; check_p8 (16'hFE01,      p8,  "8b: FF*FF = FE01");
        a16=16'hFFFF; b16=16'hFFFF; #1; check_p16(32'hFFFE0001,  p16, "16b: FFFF*FFFF");
        a16=16'd1234; b16=16'd5678; #1; check_p16(32'd7006652,   p16, "16b: 1234*5678");

        if (fails == 0) $display("=== 4 passed, 0 failed ===");
        else            $display("=== %0d FAILED ===", fails);
        $finish;
    end
endmodule
