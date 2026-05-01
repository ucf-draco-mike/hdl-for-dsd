//-----------------------------------------------------------------------------
// File: tb_wire_vs_reg.v
// Testbench for day02_ex04_wire_vs_reg.v.
//
// Exercises each of the four declaration cases from slide 3 of
// d02_s1_data_types_and_vectors.html and prints PASS/FAIL per check.
//
//   Case 1 -- combinational adder responds in zero simulated time
//   Case 2 -- clocked counter increments exactly once per posedge clk
//   Case 3 -- combinational mux selects the right input (no clock!)
//   Case 4 -- inferred latch is transparent when enable=1, holds when enable=0
//-----------------------------------------------------------------------------
`timescale 1ns/1ps

module tb_wire_vs_reg;
    localparam WIDTH = 8;

    reg              clk = 1'b0;
    reg              rst_n;
    reg  [WIDTH-1:0] a, b;
    reg              sel;
    reg              enable;
    reg  [3:0]       data;

    wire [WIDTH-1:0] sum;
    wire [WIDTH-1:0] counter;
    wire [3:0]       mux_out;
    wire [3:0]       latch_out;

    wire_vs_reg #(.WIDTH(WIDTH)) dut (
        .i_clk     (clk),
        .i_rst_n   (rst_n),
        .i_a       (a),
        .i_b       (b),
        .i_sel     (sel),
        .i_enable  (enable),
        .i_data    (data),
        .o_sum     (sum),
        .o_counter (counter),
        .o_mux     (mux_out),
        .o_latch   (latch_out)
    );

    always #5 clk = ~clk;  // 100 MHz simulation clock

    integer pass = 0;
    integer fail = 0;
    reg [WIDTH-1:0] snap;

    task check(input [1023:0] label, input ok);
        begin
            if (ok) begin
                pass = pass + 1;
                $display("PASS: %0s", label);
            end else begin
                fail = fail + 1;
                $display("FAIL: %0s", label);
            end
        end
    endtask

    initial begin
        $dumpfile("wire_vs_reg.vcd");
        $dumpvars(0, tb_wire_vs_reg);

        // Defaults; assert reset for two edges so the counter starts at 0.
        rst_n  = 1'b0;
        a      = '0;
        b      = '0;
        sel    = 1'b0;
        enable = 1'b0;
        data   = 4'h0;
        @(posedge clk); @(posedge clk);
        rst_n  = 1'b1;

        // -- Case 1: combinational adder reacts in zero (delta) time ------
        a = 8'h12; b = 8'h34; #1;
        check("case1 adder: 0x12 + 0x34 == 0x46", sum === 8'h46);
        a = 8'hFF; b = 8'h01; #1;
        check("case1 adder: 0xFF + 0x01 wraps to 0x00", sum === 8'h00);

        // -- Case 3: combinational mux switches with sel, no clock needed -
        a = 8'h0A; b = 8'h0B;
        sel = 1'b1; #1;
        check("case3 mux: sel=1 -> a[3:0] (0xA)", mux_out === 4'hA);
        sel = 1'b0; #1;
        check("case3 mux: sel=0 -> b[3:0] (0xB)", mux_out === 4'hB);

        // -- Case 4: inferred latch is transparent when enable=1, ---------
        //           and holds its last value when enable=0.
        enable = 1'b1; data = 4'h7; #1;
        check("case4 latch: transparent when enable=1", latch_out === 4'h7);
        enable = 1'b0; data = 4'hF; #1;
        check("case4 latch: HOLDS old value when enable=0", latch_out === 4'h7);

        // -- Case 2: clocked counter advances by exactly one per posedge --
        @(negedge clk);             // step away from the next posedge
        snap = counter;
        @(posedge clk); #1;
        check("case2 counter: increments by 1 each posedge", counter === snap + 8'd1);
        @(posedge clk); #1;
        check("case2 counter: increments by 2 after two posedges", counter === snap + 8'd2);

        $display("=== %0d passed, %0d failed ===", pass, fail);
        if (fail == 0) $display("ALL TESTS PASSED");
        else           $display("SOME TESTS FAILED");
        $finish;
    end
endmodule
