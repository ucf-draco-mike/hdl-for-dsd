// Exercise 2 SOLUTION: Same as starter (tests are provided)
`timescale 1ns / 1ps

module tb_register;
    reg        clk, reset, load;
    reg  [3:0] data;
    wire [3:0] q;

    register_4bit uut (
        .i_clk(clk), .i_reset(reset), .i_load(load),
        .i_data(data), .o_q(q)
    );

    always #5 clk = ~clk;

    integer pass_count = 0, fail_count = 0;

    task check;
        input [3:0] expected;
        input [8*40-1:0] name;
    begin
        if (q === expected) begin
            $display("PASS: %0s — q=%h", name, q);
            pass_count = pass_count + 1;
        end else begin
            $display("FAIL: %0s — q=%h (expected %h)", name, q, expected);
            fail_count = fail_count + 1;
        end
    end
    endtask

    initial begin
        $dumpfile("build/ex2.vcd");
        $dumpvars(0, tb_register);

        clk = 0; reset = 1; load = 0; data = 4'h0;

        @(posedge clk); #1; check(4'h0, "After reset");
        reset = 0; load = 1; data = 4'hA;
        @(posedge clk); #1; check(4'hA, "Loaded 0xA");
        load = 0; data = 4'hF;
        @(posedge clk); #1; check(4'hA, "Hold — still 0xA");
        load = 1; data = 4'h5;
        @(posedge clk); #1; check(4'h5, "Loaded 0x5");
        reset = 1;
        @(posedge clk); #1; check(4'h0, "Reset clears");

        $display("");
        $display("========================================");
        $display("Register: %0d passed, %0d failed", pass_count, fail_count);
        $display("========================================");
        #20 $finish;
    end
endmodule
