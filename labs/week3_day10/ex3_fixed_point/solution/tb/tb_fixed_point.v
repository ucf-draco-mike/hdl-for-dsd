// =============================================================================
// tb_fixed_point.v -- Testbench for Q4.4 Fixed-Point Arithmetic
// Day 10, Exercise 3
// =============================================================================
`timescale 1ns/1ps

module tb_fixed_point;

    reg        clk;
    reg  [7:0] a, b;
    wire [7:0] sum, prod;
    wire [3:0] prod_int;

    fixed_point_demo uut (
        .i_clk(clk), .i_a(a), .i_b(b),
        .o_sum(sum), .o_prod(prod), .o_prod_int(prod_int)
    );

    always #5 clk = ~clk;

    integer pass_count, fail_count;

    // Helper: convert Q4.4 to real for display
    // Q4.4 value = raw / 16.0
    task test_fixed;
        input [7:0] ta, tb;
        input [3:0] expected_int;  // expected integer part of product
        real ra, rb, rprod;
        begin
            a = ta;
            b = tb;
            #20;  // let combinational logic settle

            ra = ta / 16.0;
            rb = tb / 16.0;
            rprod = ra * rb;

            if (prod_int === expected_int) begin
                $display("PASS: %.2f * %.2f = %.2f (int part = %0d, got %0d)",
                         ra, rb, rprod, expected_int, prod_int);
                pass_count = pass_count + 1;
            end else begin
                $display("FAIL: %.2f * %.2f = %.2f (int part expected %0d, got %0d, raw prod=0x%02h)",
                         ra, rb, rprod, expected_int, prod_int, prod);
                fail_count = fail_count + 1;
            end
        end
    endtask

    initial begin
        $dumpfile("fixed_point.vcd");
        $dumpvars(0, tb_fixed_point);

        clk = 0;
        pass_count = 0;
        fail_count = 0;

        // Q4.4 encoding: value * 16
        // 2.5  = 40  = 8'h28
        // 3.0  = 48  = 8'h30
        // 1.0  = 16  = 8'h10
        // 0.5  = 8   = 8'h08
        // 4.25 = 68  = 8'h44
        // 7.5  -> int part = 7

        test_fixed(8'h28, 8'h30, 4'd7);   // 2.5 * 3.0 = 7.5  -> int 7
        test_fixed(8'h10, 8'h10, 4'd1);   // 1.0 * 1.0 = 1.0  -> int 1
        test_fixed(8'h20, 8'h20, 4'd4);   // 2.0 * 2.0 = 4.0  -> int 4
        test_fixed(8'h30, 8'h10, 4'd3);   // 3.0 * 1.0 = 3.0  -> int 3
        test_fixed(8'h08, 8'h08, 4'd0);   // 0.5 * 0.5 = 0.25 -> int 0
        test_fixed(8'h44, 8'h20, 4'd8);   // 4.25 * 2.0 = 8.5 -> int 8
        test_fixed(8'h00, 8'hFF, 4'd0);   // 0.0 * max  = 0   -> int 0

        $display("");
        $display("========================================");
        $display("  %0d/%0d tests passed", pass_count, pass_count + fail_count);
        if (fail_count == 0) $display("  ALL TESTS PASSED");
        else $display("  %0d TESTS FAILED", fail_count);
        $display("========================================");

        $finish;
    end

endmodule
